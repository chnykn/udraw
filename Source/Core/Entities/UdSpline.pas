{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdSpline;

{$I UdDefs.INC}

interface

uses
  Classes, Types,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes;

type
  //-----------------------------------------------------
  TUdSpline = class(TUdFigure)
  private
    FClosed: Boolean;
    FFittingPoints: TPoint2DArray;

    FFitIndex: Integer;

  protected
    function GetTypeID(): Longint; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    procedure SetClosed(const AValue: Boolean);
    procedure SetFittingPoints(const AValue: TPoint2DArray);


    function GetFitCount: Integer;

    function GetFitIndex: Integer;
    procedure SetFitIndex(const AValue: Integer);

    function GetFitPointValue(AIndex: Integer): Float;
    procedure SetFitPointValue(AIndex: Integer; const AValue: Float);

    {....}
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
    function BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;
    function Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray; override;

    function Intersect(AOther: TUdEntity): TPoint2DArray; override;
    function Perpend(APnt: TPoint2D): TPoint2DArray; override;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property FittingPoints: TPoint2DArray read FFittingPoints write SetFittingPoints;

  published
    property FitCount  : Integer read GetFitCount;
    property FitIndex  : Integer read GetFitIndex write SetFitIndex;
    property FitPointX : Float index 0 read GetFitPointValue write SetFitPointValue;
    property FitPointY : Float index 1 read GetFitPointValue write SetFitPointValue;

    property Closed: Boolean read FClosed write SetClosed;

  end;



implementation


uses
  SysUtils,
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, UdPolyline, UdBSpline2D;



//=================================================================================================

constructor TUdSpline.Create();
begin
  inherited;

  FClosed := False;
  FFittingPoints := nil;

  FFitIndex := 0;
end;

destructor TUdSpline.Destroy;
begin
  FFittingPoints := nil;

  inherited;
end;



function TUdSpline.GetTypeID: Integer;
begin
  Result := ID_SPLINE;
end;




//---------------------------------------------------------

procedure TUdSpline.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdSpline) then Exit; //========>>>

  FFittingPoints := TUdSpline(AValue).FFittingPoints;
  Self.Update();
end;


procedure TUdSpline.SetClosed(const AValue: Boolean);
begin
  if (FClosed <> AValue) and Self.RaiseBeforeModifyObject('Closed') then
  begin
    FClosed := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Closed');
  end;
end;

procedure TUdSpline.SetFittingPoints(const AValue: TPoint2DArray);
var
  I: Integer;
  LPnts: TPoint2DArray;
begin
  System.SetLength(LPnts, System.Length(AValue));
  for I := 0 to System.Length(AValue) - 1 do LPnts[I] := AValue[I];

  if Self.RaiseBeforeModifyObject('FittingPoints'{, Integer(@LPnts)}) then
  begin
    FFittingPoints := LPnts;
    if (Length(FFittingPoints) <= 0) or (FFitIndex >= Length(FFittingPoints)) then FFitIndex := 0;

    Self.Update();
    Self.RaiseAfterModifyObject('FittingPoints');
  end;
end;




//------------------------------------------------------------------------------------

procedure TUdSpline.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect := UdGeo2D.RectHull(FSamplePoints);
end;


procedure TUdSpline.UpdateSamplePoints(AAxes: TUdAxes);
begin
  FSamplePoints := UdBSpline2D.GetFittingBSplineSamplePoints(FFittingPoints, Length(FFittingPoints) * SEGMENTS_PER_SPLINE_CTLPNT, FClosed);
end;




function TUdSpline.GetGripPoints: TUdGripPointArray;
var
  I, L: Integer;
begin
  L := System.Length(FFittingPoints);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
    Result[I] := MakeGripPoint(Self, gmPoint, I, FFittingPoints[I], 0.0);
end;

function TUdSpline.GetOSnapPoints: TUdOSnapPointArray;
var
  LPnt: TPoint2D;
begin
  Result := nil;

  if System.Length(FSamplePoints) > 0 then
  begin
    System.SetLength(Result, 2);

    LPnt := FSamplePoints[Low(FSamplePoints)];
    Result[0] := MakeOSnapPoint(Self, OSNP_END, Point2D(LPnt.X, LPnt.Y), -1);

    LPnt := FSamplePoints[High(FSamplePoints)];
    Result[1] := MakeOSnapPoint(Self, OSNP_END, Point2D(LPnt.X, LPnt.Y), -1);
  end;
end;







//-------------------------------------------------------------------------------------------

function TUdSpline.GetFitCount: Integer;
begin
  Result := Length(FFittingPoints);
end;


function TUdSpline.GetFitIndex: Integer;
begin
  Result := FFitIndex;
end;


procedure TUdSpline.SetFitIndex(const AValue: Integer);
begin
  if (AValue >= 0) and ((Length(FFittingPoints) <= 0) or (AValue < Length(FFittingPoints))) then
    FFitIndex := AValue
  else
    raise Exception.Create('FFitIndex must in [0-' + IntToStr(Length(FFittingPoints)) + ']');
end;


function TUdSpline.GetFitPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  if (Length(FFittingPoints) > 0) and (FFitIndex >= 0) and (FFitIndex < Length(FFittingPoints)) then
  begin
    case AIndex of
      0: Result := FFittingPoints[FFitIndex].X;
      1: Result := FFittingPoints[FFitIndex].Y;
    end;
  end;
end;

procedure TUdSpline.SetFitPointValue(AIndex: Integer; const AValue: Float);
var
  I: Integer;
  LFitPnts: TPoint2DArray;
begin
  if (Length(FFittingPoints) > 0) and (FFitIndex >= 0) and (FFitIndex < Length(FFittingPoints)) then
  begin
    SetLength(LFitPnts, Length(FFittingPoints));
    for I := 0 to Length(FFittingPoints) - 1 do LFitPnts[I] := FFittingPoints[I];

    case AIndex of
      0: LFitPnts[FFitIndex].X := AValue;
      1: LFitPnts[FFitIndex].Y := AValue;
    end;

    Self.SetFittingPoints(LFitPnts);
  end;
end;




//-------------------------------------------------------------------------------------------

function TUdSpline.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  I: Integer;
  LPnts: TPoint2DArray;
begin
  Result := False;
  if AGripPnt.Mode = gmPoint then
  begin
    if (AGripPnt.Index >= 0) and (AGripPnt.Index < System.Length(FFittingPoints)) then
    begin
      System.SetLength(LPnts, System.Length(FFittingPoints));
      for I := 0 to System.Length(FFittingPoints) - 1 do LPnts[I] := FFittingPoints[I];

      LPnts[AGripPnt.Index] := AGripPnt.Point;
      Self.SetFittingPoints(LPnts);
    end;
    Result := True;
  end;
end;


function TUdSpline.Pick(APoint: TPoint2D): Boolean;
var
  D, E: Float;
  LAxes: TUdAxes;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;

  if FPenWidth > 0.0 then
  begin
    D := DistanceToPolygon(APoint, FSamplePoints);
    Result := (D < FPenWidth/2) or IsEqual(D, FPenWidth/2, E);
  end
  else
    Result := UdGeo2D.IsPntOnPolygon(APoint, FSamplePoints, E);
end;

function TUdSpline.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.Inclusion(FBoundsRect, ARect) = irOvered;

  if not Result and ACrossingMode then
  begin
    Result := UdGeo2D.IsIntersect(ARect, FSamplePoints);
  end;
end;

function TUdSpline.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FFittingPoints := UdGeo2D.Translate(Dx, Dy, FFittingPoints);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdSpline.Mirror(APnt1, APnt2: TPoint2D): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FFittingPoints := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FFittingPoints);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdSpline.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
//var
//  LPnts: TPoint2DArray;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ADis, 0.0)) then Exit; //======>>>>

//  LPnts := MakePoint2DArray(FSamplePoints);
//  if UdGeo2D.IsPntInPolygon(ASidePnt, LPnts) then ADis := -ADis;
//
//  LPnts := UdGeo2D.OffsetPoints(LPnts, ADis);
//
//  Result := Self.Update();
end;

function TUdSpline.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FFittingPoints := UdGeo2D.Rotate(ABase, ARota, FFittingPoints);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdSpline.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FFittingPoints := UdGeo2D.Scale(ABase, AFactor, AFactor, FFittingPoints);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;



function TUdSpline.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdSpline;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdSpline.Create({Self.Document, False});

  LEntity.BeginUpdate();  
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      LEntity.FFittingPoints := UdGeo2D.Scale(ABase, XFactor, YFactor, FFittingPoints);
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;

function TUdSpline.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;
begin
  Result := nil;
end;

function TUdSpline.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  I: Integer;
  LPolyLine: TUdPolyline;
  LPntsArray: TPoint2DArrays;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>

  LPntsArray := UdGeo2D.BreakAt(FSamplePoints, APnt1, APnt2);

  System.SetLength(Result, System.Length(LPntsArray));
  for I := 0 to System.Length(LPntsArray) - 1 do
  begin
    LPolyline := TUdPolyline.Create({Self.Document, False});
    LPolyline.Assign(Self);
    LPolyline.Closed := False;
    LPolyline.SetPoints(LPntsArray[I]);

    Result[I] := LPolyline;
  end;
end;




function TUdSpline.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  if not Self.IsVisible or Self.IsLock() then Exit;
  if not AOther.IsVisible or AOther.IsLock() then Exit;

  Result := UdUtils.EntitiesIntersection(FSamplePoints, AOther);
end;

function TUdSpline.Perpend(APnt: TPoint2D): TPoint2DArray;
//var
//  LLn: TLine2D;
//  LPnt: TPoint2D;
begin
  Result := nil;

//  LLn := UdGeo2D.Line2D(FP1, FP2);
//
//  LPnt := UdGeo2D.ClosestLinePoint(APnt, LLn);
//  if UdGeo2D.IsPntOnSegment(LPnt, Segment2D(FP1, FP2)) then
//  begin
//    System.SetLength(Result, 1);
//    Result[0] := LPnt;
//  end;
end;










//------------------------------------------------------------------------------------

procedure TUdSpline.SaveToStream(AStream: TStream);
var
  I, L: Integer;
begin
  inherited;

  BoolToStream(AStream, FClosed);

  L := System.Length(FFittingPoints);

  IntToStream(AStream, L);
  for I := 0 to L - 1 do
  begin
    FloatToStream(AStream, FFittingPoints[I].X);
    FloatToStream(AStream, FFittingPoints[I].Y);
  end;
end;

procedure TUdSpline.LoadFromStream(AStream: TStream);
var
  I, L: Integer;
begin
  inherited;

  FClosed := BoolFromStream(AStream);

  L := IntFromStream(AStream);
  System.SetLength(FFittingPoints, L);

  for I := 0 to L - 1 do
  begin
    FFittingPoints[I].X := FloatFromStream(AStream);
    FFittingPoints[I].Y := FloatFromStream(AStream);
  end;

  Update();
end;



procedure TUdSpline.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I, N: Integer;
  LStr: string;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Closed']       := BoolToStr(FClosed, True);

  if System.Length(FFittingPoints) > 0 then
  begin
    N := System.Length(FFittingPoints) -1;
    for I := 0 to N do
    begin
      LStr := LStr + Point2DToStr(FFittingPoints[I]);
      if I <> N then LStr := LStr + ';';
    end;
    LXmlNode.Prop['FittingPoints']  := LStr;
  end;
end;

procedure TUdSpline.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  LStrs: TStringDynArray;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FClosed  := StrToBoolDef(LXmlNode.Prop['Closed'], False);

  LStrs := UdUtils.StrSplit(LXmlNode.Prop['FittingPoints'], ';');
  SetLength(FFittingPoints, System.Length(LStrs));
  for I := 0 to System.Length(LStrs) - 1 do
    FFittingPoints[I] := StrToPoint2D(LStrs[I]);

  Update();
end;

end.