{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdSolid;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes, UdColor;


type

  //-----------------------------------------------------
  TUdSolid = class(TUdFigure)
  private
    FP1: TPoint2D;
    FP2: TPoint2D;
    FP3: TPoint2D;
    FP4: TPoint2D;

  protected
    function GetTypeID(): Integer; override;

    function GetPoint(const Index: Integer): TPoint2D;
    function GetPointValue(const Index: Integer): Float;
    procedure SetPoint(const Index: Integer; const AValue: TPoint2D);
    procedure SetPointValue(const Index: Integer; const AValue: Float);

    function CanFilled(): Boolean; override;
    function CanLinetype(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetGripPoints(): TUdGripPointArray; override;
    function GetOSnapPoints(): TUdOSnapPointArray; override;

    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;


    { operation... }
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;

    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;

    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;

    function Intersect(AOther: TUdEntity): TPoint2DArray; override;
    function Perpend(APnt: TPoint2D): TPoint2DArray; override;

  public
    property P1: TPoint2D index 0 read GetPoint write SetPoint;
    property P2: TPoint2D index 1 read GetPoint write SetPoint;
    property P3: TPoint2D index 2 read GetPoint write SetPoint;
    property P4: TPoint2D index 3 read GetPoint write SetPoint;

  published
    property P1X: Float index 0 read GetPointValue write SetPointValue;
    property P1Y: Float index 1 read GetPointValue write SetPointValue;

    property P2X: Float index 2 read GetPointValue write SetPointValue;
    property P2Y: Float index 3 read GetPointValue write SetPointValue;

    property P3X: Float index 4 read GetPointValue write SetPointValue;
    property P3Y: Float index 5 read GetPointValue write SetPointValue;

    property P4X: Float index 6 read GetPointValue write SetPointValue;
    property P4Y: Float index 7 read GetPointValue write SetPointValue;
  end;

implementation


uses
  SysUtils,
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, UdDrawUtil;




//==================================================================================================
{ TUdSolid }

constructor TUdSolid.Create();
begin
  inherited;

  FP1 := Point2D(0.0, 0.0);
  FP2 := Point2D(0.0, 0.0);
  FP3 := Point2D(0.0, 0.0);
  FP4 := Point2D(0.0, 0.0);

  FFilled := True;
end;

destructor TUdSolid.Destroy;
begin
  inherited;
end;



function TUdSolid.GetTypeID: Integer;
begin
  Result := ID_SOLID;
end;



//-----------------------------------------------------------------------------------------



function TUdSolid.GetPoint(const Index: Integer): TPoint2D;
begin
  Result := Point2D(0, 0);
  case Index of
    0: Result := FP1;
    1: Result := FP2;
    2: Result := FP3;
    3: Result := FP4;
  end;
end;

function TUdSolid.GetPointValue(const Index: Integer): Float;
begin
  Result := 0;
  case Index of
    0: Result := FP1.X;
    1: Result := FP1.Y;

    2: Result := FP2.X;
    3: Result := FP2.Y;

    4: Result := FP3.X;
    5: Result := FP3.Y;

    6: Result := FP4.X;
    7: Result := FP4.Y;
  end;
end;


procedure TUdSolid.SetPoint(const Index: Integer; const AValue: TPoint2D);
begin
  case Index of
    0: if NotEqual(FP1, AValue) and Self.RaiseBeforeModifyObject('P1') then
       begin
         FP1 := AValue;
         Self.Update();
       end;
    1: if NotEqual(FP2, AValue) and Self.RaiseBeforeModifyObject('P2') then
       begin
         FP2 := AValue;
         Self.Update();
       end;
    2: if NotEqual(FP3, AValue) and Self.RaiseBeforeModifyObject('P3') then
       begin
         FP3 := AValue;
         Self.Update();
       end;
    3: if NotEqual(FP4, AValue) and Self.RaiseBeforeModifyObject('P4') then
       begin
         FP4 := AValue;
         Self.Update();
       end;
  end;
end;

procedure TUdSolid.SetPointValue(const Index: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
  LProp: string;
begin
  case Index of
    0,1: LPnt := FP1;
    2,3: LPnt := FP2;
    4,5: LPnt := FP3;
    6,7: LPnt := FP4;
  end;

  case Index of
    0: begin LPnt.X := AValue; LProp := 'P1X'; end;
    1: begin LPnt.Y := AValue; LProp := 'P1Y'; end;

    2: begin LPnt.X := AValue; LProp := 'P2X'; end;
    3: begin LPnt.Y := AValue; LProp := 'P2Y'; end;

    4: begin LPnt.X := AValue; LProp := 'P3X'; end;
    5: begin LPnt.Y := AValue; LProp := 'P3Y'; end;

    6: begin LPnt.X := AValue; LProp := 'P4X'; end;
    7: begin LPnt.Y := AValue; LProp := 'P4Y'; end;
  end;

  Self.RaiseBeforeModifyObject(LProp);

  case Index of
    0,1: FP1 := LPnt;
    2,3: FP1 := LPnt;
    4,5: FP1 := LPnt;
    6,7: FP1 := LPnt;
  end;

  Self.Update();

  Self.RaiseAfterModifyObject(LProp);
end;




procedure TUdSolid.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdSolid) then Exit; //========>>>

  FP1 := TUdSolid(AValue).FP1;
  FP2 := TUdSolid(AValue).FP2;
  FP3 := TUdSolid(AValue).FP3;
  FP4 := TUdSolid(AValue).FP4;

  Self.Update();
end;



//-----------------------------------------------------------------------------------------

function TUdSolid.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>

  FDrawPolygon(ACanvas, AAxes, Self.ActualTrueColor(AFlag), FFillStyle, FSamplePoints);

  Result := True;
end;






//-----------------------------------------------------------------------------------------

function TUdSolid.CanFilled(): Boolean;
begin
  Result := True;
end;

function TUdSolid.CanLinetype(): Boolean;
begin
  Result := False;
end;

procedure TUdSolid.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect := UdGeo2D.RectHull(FSamplePoints);
end;

procedure TUdSolid.UpdateSamplePoints(AAxes: TUdAxes);
var
  L: Integer;
begin
  if IsEqual(FP3, FP4) then L := 4 else L := 5;
  SetLength(FSamplePoints, L);

  FSamplePoints[0] := FP1;
  FSamplePoints[1] := FP2;
  if L = 4 then
  begin
    FSamplePoints[2] := FP3;
    FSamplePoints[3] := FP1;
  end
  else begin
    FSamplePoints[2] := FP4;
    FSamplePoints[3] := FP3;
    FSamplePoints[4] := FP1;
  end;
end;



function TUdSolid.GetGripPoints(): TUdGripPointArray;
begin
  SetLength(Result, 4);
  Result[0] := MakeGripPoint(Self, gmPoint, 0, FP1, 0.0);
  Result[1] := MakeGripPoint(Self, gmPoint, 1, FP2, 0.0);
  Result[2] := MakeGripPoint(Self, gmPoint, 2, FP3, 0.0);
  Result[3] := MakeGripPoint(Self, gmPoint, 3, FP4, 0.0);
end;

function TUdSolid.GetOSnapPoints: TUdOSnapPointArray;
begin
  SetLength(Result, 8);

  Result[0] := MakeOSnapPoint(Self, OSNP_END, FP1, -1);
  Result[1] := MakeOSnapPoint(Self, OSNP_END, FP2, -1);
  Result[2] := MakeOSnapPoint(Self, OSNP_NOD, FP4, -1);
  Result[3] := MakeOSnapPoint(Self, OSNP_NOD, FP3, -1);

  Result[4] := MakeOSnapPoint(Self, OSNP_MID, MidPoint(FP1, FP2), -1);
  Result[5] := MakeOSnapPoint(Self, OSNP_MID, MidPoint(FP1, FP3), -1);
  Result[6] := MakeOSnapPoint(Self, OSNP_MID, MidPoint(FP3, FP4), -1);
  Result[7] := MakeOSnapPoint(Self, OSNP_MID, MidPoint(FP4, FP1), -1);
end;









//-----------------------------------------------------------------------------------------

function TUdSolid.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    case AGripPnt.Index of
      0: Self.P1 := AGripPnt.Point;
      1: Self.P2 := AGripPnt.Point;
      2: Self.P3 := AGripPnt.Point;
      3: Self.P4 := AGripPnt.Point;
    end;
  end;
end;


function TUdSolid.Pick(APoint: TPoint2D): Boolean;
var
  E: Float;
  LAxes: TUdAxes;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;

  Result := IsPntOnPolygon(APoint, FSamplePoints, E);
end;

function TUdSolid.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
var
  LIc: TInclusion;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LIc := UdGeo2D.Inclusion(FBoundsRect, ARect);
  Result := LIc = irOvered;

  if not Result and ACrossingMode then
  begin
    Result := UdGeo2D.IsIntersect(ARect, FSamplePoints);
  end;
end;

function TUdSolid.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FP1 := UdGeo2D.Translate(Dx, Dy, FP1);
  FP2 := UdGeo2D.Translate(Dx, Dy, FP2);
  FP4 := UdGeo2D.Translate(Dx, Dy, FP4);
  FP3 := UdGeo2D.Translate(Dx, Dy, FP3);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdSolid.Mirror(APnt1, APnt2: TPoint2D): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FP1 := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FP1);
  FP2 := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FP2);
  FP3 := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FP3);
  FP4 := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FP4);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdSolid.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FP1 := UdGeo2D.Rotate(ABase, ARota, FP1);
  FP2 := UdGeo2D.Rotate(ABase, ARota, FP2);
  FP3 := UdGeo2D.Rotate(ABase, ARota, FP3);
  FP4 := UdGeo2D.Rotate(ABase, ARota, FP4);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdSolid.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FP1 := UdGeo2D.Scale(ABase, AFactor, AFactor, FP1);
  FP2 := UdGeo2D.Scale(ABase, AFactor, AFactor, FP2);
  FP3 := UdGeo2D.Scale(ABase, AFactor, AFactor, FP3);
  FP4 := UdGeo2D.Scale(ABase, AFactor, AFactor, FP4);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;



function TUdSolid.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdSolid;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>


  LEntity := TUdSolid.Create({Self.Document, False});

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if IsEqual(XFactor, YFactor) then
      LEntity.Scale(ABase, XFactor)
    else begin
      with LEntity do
      begin
        FP1 := UdGeo2D.Scale(ABase, XFactor, YFactor, FP1);
        FP2 := UdGeo2D.Scale(ABase, XFactor, YFactor, FP2);
        FP3 := UdGeo2D.Scale(ABase, XFactor, YFactor, FP3);
        FP4 := UdGeo2D.Scale(ABase, XFactor, YFactor, FP4);
      end;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;


function TUdSolid.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;

  if not Self.IsVisible or Self.IsLock() then Exit; //======>>>>
  if not Assigned(AOther) or not AOther.IsVisible or AOther.IsLock() then Exit; //======>>>>

  Result := UdUtils.EntitiesIntersection(FSamplePoints, AOther);
end;

function TUdSolid.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  I: Integer;
  LLn: TLine2D;
  LPnt: TPoint2D;
begin
    for I := 0 to System.Length(FSamplePoints) - 2 do
    begin
      if IsEqual(FSamplePoints[I], FSamplePoints[I+1]) then
      begin
        LLn := UdGeo2D.Line2D(FSamplePoints[I], FSamplePoints[I+1]);

        LPnt := UdGeo2D.ClosestLinePoint(APnt, LLn);
        if UdGeo2D.IsPntOnSegment(LPnt, Segment2D(FSamplePoints[I], FSamplePoints[I+1])) then
        begin
          System.SetLength(Result, 1);
          Result[0] := LPnt;

          Break;
        end;
      end;
    end;
end;





//-----------------------------------------------------------------------------------------

procedure TUdSolid.SaveToStream(AStream: TStream);
begin
  inherited;

  Point2DToStream(AStream, FP1);
  Point2DToStream(AStream, FP2);
  Point2DToStream(AStream, FP3);
  Point2DToStream(AStream, FP4);
end;

procedure TUdSolid.LoadFromStream(AStream: TStream);
begin
  inherited;

  FP1 := Point2DFromStream(AStream);
  FP2 := Point2DFromStream(AStream);
  FP3 := Point2DFromStream(AStream);
  FP4 := Point2DFromStream(AStream);

  Update();
end;




procedure TUdSolid.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['P1'] := Point2DToStr(FP1);
  LXmlNode.Prop['P2'] := Point2DToStr(FP2);
  LXmlNode.Prop['P3'] := Point2DToStr(FP3);
  LXmlNode.Prop['P4'] := Point2DToStr(FP4);
end;

procedure TUdSolid.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FP1 := StrToPoint2D(LXmlNode.Prop['P1']);
  FP2 := StrToPoint2D(LXmlNode.Prop['P2']);
  FP3 := StrToPoint2D(LXmlNode.Prop['P3']);
  FP4 := StrToPoint2D(LXmlNode.Prop['P4']);

  Update();
end;

end.