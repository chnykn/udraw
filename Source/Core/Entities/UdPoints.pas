{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPoints;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes;

type

  //-----------------------------------------------------
  TUdPoints = class(TUdFigure)
  private
    FPoints: TPoint2DArray;

  protected
    function GetTypeID(): Integer; override;

    procedure SetXData(const AValue: TPoint2DArray);


    function CanFilled(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetGripPoints(): TUdGripPointArray; override;
    function GetOSnapPoints(): TUdOSnapPointArray; override;

    { operation... }
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;

    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;

    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Offset(ADis: Float; ASidePnt: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;
    function BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray; override;

    function Intersect(AOther: TUdEntity): TPoint2DArray; override;

    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Points: TPoint2DArray read FPoints write SetXData;
    property XData: TPoint2DArray  read FPoints write SetXData;

  end;



implementation

uses
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, UdColls;




//==================================================================================================
{ TUdPoints }

constructor TUdPoints.Create();
begin
  inherited;
  
  FPoints := nil;
end;

destructor TUdPoints.Destroy;
begin
  inherited;
end;



function TUdPoints.GetTypeID: Integer;
begin
  Result := ID_POINTS;
end;



//-----------------------------------------------------------------------------------------


procedure TUdPoints.SetXData(const AValue: TPoint2DArray);
begin
  if Self.RaiseBeforeModifyObject('XData') then
  begin
    FPoints := AValue;

    Self.Update();
    Self.RaiseAfterModifyObject('XData');
  end;
end;


procedure TUdPoints.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdPoints) then Exit; //========>>>

  Self.FPoints  := TUdPoints(AValue).FPoints;

  Self.Update();
end;





//-----------------------------------------------------------------------------------------

function TUdPoints.CanFilled(): Boolean;
begin
  Result := True;
end;

procedure TUdPoints.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect := UdGeo2D.RectHull(FPoints);
  if FPenWidth > 0 then
  begin
    FBoundsRect.X1 := FBoundsRect.X1 - FPenWidth;
    FBoundsRect.Y1 := FBoundsRect.Y1 - FPenWidth;
    FBoundsRect.X2 := FBoundsRect.X2 + FPenWidth;
    FBoundsRect.Y2 := FBoundsRect.Y2 + FPenWidth;
  end;
end;

procedure TUdPoints.UpdateSamplePoints(AAxes: TUdAxes);
begin
  FSamplePoints := FPoints;
end;



function TUdPoints.GetGripPoints(): TUdGripPointArray;
var
  I: Integer;
begin
  System.SetLength(Result, Length(FPoints));
  for I := 0 to Length(FPoints) - 1 do
    Result[I] := MakeGripPoint(Self, gmPoint, I, FPoints[I], 0);
end;

function TUdPoints.GetOSnapPoints: TUdOSnapPointArray;
var
  I: Integer;
  LAng: Float;
begin
  System.SetLength(Result, 2 * Length(FPoints) - 1 );

  for I := 0 to Length(FPoints) - 2 do
  begin
      LAng := UdGeo2D.GetAngle(FPoints[I], FPoints[I+1]);
      Result[I * 2]     := MakeOSnapPoint(Self, OSNP_END, FPoints[I], LAng);
      Result[I * 2 + 1] := MakeOSnapPoint(Self, OSNP_MID, MidPoint(FPoints[I], FPoints[I+1]), LAng);
  end;
end;






//-----------------------------------------------------------------------------------------


function TUdPoints.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;

  case AGripPnt.Mode of
    gmPoint :
      begin
        FPoints[AGripPnt.Index] := AGripPnt.Point;
        Self.Update();
        Result := True;
      end;
  end;
end;


function TUdPoints.Pick(APoint: TPoint2D): Boolean;
var
  E: Float; //D,
  LAxes: TUdAxes;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;

  E := Max(FPenWidth, E);

//  if FPenWidth > 0.0 then
//  begin
//    D := DistanceToPolygon(APoint, FPoints);
//    Result := (D < FPenWidth/2) or IsEqual(D, FPenWidth/2, E);
//  end
//  else
  if Self.FFilled then
    Result := UdGeo2D.IsPntInPolygon(APoint, FPoints, E)
  else
    Result := UdGeo2D.IsPntOnPolygon(APoint, FPoints, E);
end;

function TUdPoints.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.Inclusion(FBoundsRect, ARect) = irOvered;

  if not Result and ACrossingMode then
    Result := UdGeo2D.IsIntersect(ARect, FPoints);
end;

function TUdPoints.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPoints := UdGeo2D.Translate(Dx, Dy, FPoints);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdPoints.Mirror(APnt1, APnt2: TPoint2D): Boolean;
//var
//  LTheSeg, LNewSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPoints := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FPoints);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdPoints.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
//var
//  LSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ADis, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPoints := UdGeo2D.OffsetPoints(FPoints, ADis, ASidePnt);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdPoints.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
//var
//  LNewSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPoints := UdGeo2D.Rotate(ABase, ARota, FPoints );

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdPoints.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
//var
//  LNewSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPoints := UdGeo2D.Scale(ABase, AFactor, AFactor, FPoints );

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdPoints.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
//  LSeg: TSegment2D;
  LEntity: TUdPoints;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdPoints.Create({Self.Document, False});

  LEntity.BeginUpdate();  
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      FPoints := UdGeo2D.Scale(ABase, XFactor, YFactor, FPoints);

      LEntity.Points := FPoints;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;

function TUdPoints.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  I: Integer;
  LLine: TUdPoints;
  LSegs: TPoint2DArrays;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>

  LSegs := UdGeo2D.BreakAt(FPoints, APnt1, APnt2);

  System.SetLength(Result, System.Length(LSegs));
  for I := 0 to System.Length(LSegs) - 1 do
  begin
    LLine := TUdPoints(Self.Clone());
    LLine.SetXData(LSegs[I]);

    Result[I] := LLine;
  end;
end;




function TUdPoints.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  if not Self.IsVisible or Self.IsLock() then Exit;
  if not AOther.IsVisible or AOther.IsLock() then Exit;

  Result := UdUtils.EntitiesIntersection(FPoints, AOther);
end;











//-----------------------------------------------------------------------------------------

procedure TUdPoints.SaveToStream(AStream: TStream);
begin
  inherited;

  PointsToStream(AStream, FPoints);
end;

procedure TUdPoints.LoadFromStream(AStream: TStream);
begin
  inherited;

  FPoints  := PointsFromStream(AStream);
  Update();
end;



procedure TUdPoints.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Points'] := ArrayToStr(FPoints);
end;


procedure TUdPoints.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  StrToArray(LXmlNode.Prop['Points'], FPoints);

  Update();
end;

end.