{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdLeader;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Types,
  UdConsts, UdTypes, UdGTypes, UdLineWeight,
  UdObject, UdEntity, UdFigure, UdAxes, UdDimStyle;

type

  //-----------------------------------------------------
  TUdLeader = class(TUdFigure)
  private
    FDimStyle: TUdDimStyle;
    FPoints: TPoint2DArray;

    FSpline: Boolean;
    FShowArrow: Boolean;

    FArrowSize1: Float;
    FArrowSize2: Float;

    FArrowStyle1: TUdArrowStyle;
    FArrowStyle2: TUdArrowStyle;


    FArrow1Flag: Cardinal;
    FArrow2Flag: Cardinal;

    FArrow1Ponts: TPoint2DArray;
    FArrow1Ponts2: TPoint2DArray;

    FArrow2Ponts: TPoint2DArray;
    FArrow2Ponts2: TPoint2DArray;


  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;
    
    function GetXData: TPoint2DArray;
    procedure SetXData(const AValue: TPoint2DArray);

    procedure SetSpline(const AValue: Boolean);
    procedure SetShowArrow(const AValue: Boolean);

    procedure FSetDimStyle(const AValue: TUdDimStyle);
    procedure SetDimStyle(const AValue: TUdDimStyle);

    procedure SetPoints(const AValue: TPoint2DArray);
    procedure SetArrowSize(AIndex: Integer; const AValue: Float);
    procedure SetArrowStyle(AIndex: Integer; const AValue: TUdArrowStyle);


    function CanFilled(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

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
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;override;

    function Intersect(AOther: TUdEntity): TPoint2DArray; override;
    function Perpend(APnt: TPoint2D): TPoint2DArray; override;


    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;


  public
    property Points: TPoint2DArray read FPoints write SetPoints;
    property XData: TPoint2DArray  read GetXData  write SetXData;

  published
    property Spline: Boolean read FSpline write SetSpline;
    property ShowArrow: Boolean read FShowArrow write SetShowArrow;
    property DimStyle: TUdDimStyle read FDimStyle write SetDimStyle;

    property ArrowSize1: Float index 0 read FArrowSize1 write SetArrowSize;
    property ArrowSize2: Float index 1 read FArrowSize2 write SetArrowSize;

    property ArrowStyle1: TUdArrowStyle index 0 read FArrowStyle1 write SetArrowStyle;
    property ArrowStyle2: TUdArrowStyle index 1 read FArrowStyle2 write SetArrowStyle;

  end;


implementation


uses
  SysUtils,
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml , UdBSpline2D;


const
  ARROW_CLOSED = 1;
  ARROW_FILLED = 2;

  DEF_ARROW_SIZE: Float        = 2.5;
  DEF_ARROW_KIND: TUdArrowStyle = asClosedFilled;


//==================================================================================================
{ TUdLeader }

constructor TUdLeader.Create();
begin
  inherited;

  FDimStyle  := nil;
  FPoints    := nil;

  FSpline := False;
  FShowArrow := True;

  FArrowSize1   := DEF_ARROW_SIZE;
  FArrowSize2   := DEF_ARROW_SIZE;

  FArrowStyle1   := DEF_ARROW_KIND;
  FArrowStyle2   := asNone;


  FArrow1Flag   := 0;
  FArrow2Flag   := 0;

  FArrow1Ponts  := nil;
  FArrow1Ponts2 := nil;

  FArrow2Ponts  := nil;
  FArrow2Ponts2 := nil;
end;

destructor TUdLeader.Destroy;
begin
  FArrow1Ponts  := nil;
  FArrow1Ponts2 := nil;

  FArrow2Ponts  := nil;
  FArrow2Ponts2 := nil;

  inherited;
end;



function TUdLeader.GetTypeID: Integer;
begin
  Result := ID_LEADER;
end;


procedure TUdLeader.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;
  if Assigned(Self.Document) then Self.FSetDimStyle(Self.DimStyles.Active);
end;



//-----------------------------------------------------------------------------------------


function TUdLeader.GetXData: TPoint2DArray;
begin
  Result := FPoints;
end;

procedure TUdLeader.SetXData(const AValue: TPoint2DArray);
begin
//  if Self.RaiseBeforeModifyObject('XData') then
//  begin
    Self.SetPoints(AValue);
//    Self.RaiseAfterModifyObject('XData');
//  end;
end;



procedure TUdLeader.SetSpline(const AValue: Boolean);
begin
  if (FSpline <> AValue) and Self.RaiseBeforeModifyObject('Spline') then
  begin
    FSpline := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Spline');
  end;
end;

procedure TUdLeader.SetShowArrow(const AValue: Boolean);
begin
  if (FShowArrow <> AValue) and Self.RaiseBeforeModifyObject('ShowArrow') then
  begin
    FShowArrow := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ShowArrow');
  end;
end;



procedure TUdLeader.FSetDimStyle(const AValue: TUdDimStyle);
begin
  FDimStyle := AValue;
  if Assigned(FDimStyle) then
  begin
    FArrowSize1 := FDimStyle.ArrowsProp.ArrowSize;
    FArrowStyle1 := TUdArrowStyle(FDimStyle.ArrowsProp.ArrowLeader);

//    FArrowSize2 := FDimStyle.ArrowsProp.ArrowSize;
//    FArrowStyle2 := FDimStyle.ArrowsProp.ArrowSize;
  end;
end;

procedure TUdLeader.SetDimStyle(const AValue: TUdDimStyle);
begin
  if (FDimStyle <> AValue) and Self.RaiseBeforeModifyObject('DimStyle') then
  begin
    Self.BeginUpdate();
    try
      FSetDimStyle(AValue);
    finally
      Self.EndUpdate();
    end;
    Self.RaiseAfterModifyObject('DimStyle');
  end;
end;


procedure TUdLeader.SetPoints(const AValue: TPoint2DArray);
var
  LPnts: TPoint2DArray;
begin
  LPnts := UdMath.TrimPoints(AValue);
  if System.Length(LPnts) < 2 then Exit;  //========>>>>

  if Self.RaiseBeforeModifyObject('Points') then
  begin
    FPoints := LPnts;
    Self.Update();
    Self.RaiseAfterModifyObject('Points');
  end;
end;

procedure TUdLeader.SetArrowSize(AIndex: Integer; const AValue: Float);
begin
  if IsEqual(AValue, 0.0) or (AValue < 0) then Exit;

  case AIndex of
    0:
      if NotEqual(FArrowSize1, AValue) and Self.RaiseBeforeModifyObject('ArrowSize1') then
      begin
        FArrowSize1 := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('ArrowSize1');
      end;
    1:
      if NotEqual(FArrowSize2, AValue) and Self.RaiseBeforeModifyObject('ArrowSize2') then
      begin
        FArrowSize2 := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('ArrowSize2');
      end;
  end;
end;

procedure TUdLeader.SetArrowStyle(AIndex: Integer; const AValue: TUdArrowStyle);
begin
  case AIndex of
    0:
      if (FArrowStyle1 <> AValue) and Self.RaiseBeforeModifyObject('ArrowStyle1') then
      begin
        FArrowStyle1 := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('ArrowStyle1');
      end;
    1:
      if (FArrowStyle2 <> AValue) and Self.RaiseBeforeModifyObject('ArrowStyle2') then
      begin
        FArrowStyle2 := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('ArrowStyle2');
      end;
  end;
end;








procedure TUdLeader.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdLeader) then Exit; //========>>>

  Self.FDimStyle    := TUdLeader(AValue).FDimStyle;
  Self.FPoints      := TUdLeader(AValue).FPoints;

  Self.FSpline      := TUdLeader(AValue).FSpline;
  Self.FShowArrow   := TUdLeader(AValue).FShowArrow;

  Self.FArrowSize1  := TUdLeader(AValue).FArrowSize1;
  Self.FArrowSize2  := TUdLeader(AValue).FArrowSize2;

  Self.FArrowStyle1  := TUdLeader(AValue).FArrowStyle1;
  Self.FArrowStyle2  := TUdLeader(AValue).FArrowStyle2;

  Self.Update();
end;





//-----------------------------------------------------------------------------------------

function TUdLeader.CanFilled(): Boolean;
begin
  Result := False;
end;

procedure TUdLeader.UpdateBoundsRect(AAxes: TUdAxes);
var
  LArrowSize: Float;
begin
  FBoundsRect := UdGeo2D.RectHull(FPoints);

  LArrowSize := Max(FArrowSize1, FArrowSize2);

  FBoundsRect.X1 := FBoundsRect.X1 - LArrowSize;
  FBoundsRect.Y1 := FBoundsRect.Y1 - LArrowSize;
  FBoundsRect.X2 := FBoundsRect.X2 + LArrowSize;
  FBoundsRect.Y2 := FBoundsRect.Y2 + LArrowSize;
end;



function FCalcArrow(var ASeg: TSegment2D; AArrowSize: Float; AArrowStyle: TUdArrowStyle;
                    var AFlag: Cardinal; var APoints, APoints2: TPoint2DArray): Boolean;

  function _CalcTrianglePnts(var ASeg: TSegment2D; ATrimSeg: Boolean; AClosed: Boolean; AAngle: Float = 9): TPoint2DArray;
  var
    LAng, H: Float;
  begin
    LAng := GetAngle(ASeg.P1, ASeg.P2);

    H := AArrowSize * UdMath.TanD(AAngle);

    if AClosed then
    begin
      System.SetLength(Result, 4);

      Result[0] := ASeg.P1;
      Result[1] := ShiftPoint(ShiftPoint(ASeg.P1, LAng, AArrowSize), FixAngle(LAng + 90), H);
      Result[2] := ShiftPoint(ShiftPoint(ASeg.P1, LAng, AArrowSize), FixAngle(LAng - 90), H);
      Result[3] := Result[0];
    end
    else begin
      System.SetLength(Result, 3);

      Result[0] := ShiftPoint(ShiftPoint(ASeg.P1, LAng, AArrowSize), FixAngle(LAng + 90), H);
      Result[1] := ASeg.P1;
      Result[2] := ShiftPoint(ShiftPoint(ASeg.P1, LAng, AArrowSize), FixAngle(LAng - 90), H);
    end;

    if ATrimSeg then
    begin
      if Distance(ASeg) <= AArrowSize then
        ASeg.P1 := ASeg.P2
      else
        ASeg.P1 := ShiftPoint(ASeg.P1, LAng, AArrowSize);
    end;
  end;

  function _CalcTriangle2Pnts(var ASeg: TSegment2D; ATrimSeg: Boolean; AAngle: Float = 30): TPoint2DArray;
  var
    LAng, H: Float;
  begin
    LAng := GetAngle(ASeg.P1, ASeg.P2);

    H := AArrowSize * UdMath.TanD(AAngle);

    System.SetLength(Result, 4);

    Result[0] := ShiftPoint(ASeg.P1, LAng, AArrowSize);
    Result[1] := ShiftPoint(ASeg.P1, FixAngle(LAng + 90), H);
    Result[2] := ShiftPoint(ASeg.P1, FixAngle(LAng - 90), H);
    Result[3] := Result[0];

    if ATrimSeg then
    begin
      if Distance(ASeg) <= AArrowSize then
        ASeg.P1 := ASeg.P2
      else
        ASeg.P1 := ShiftPoint(ASeg.P1, LAng, AArrowSize);
    end;
  end;

  function _CalcDotPnts(var ASeg: TSegment2D; ATrimSeg: Boolean; AIsSmall: Boolean): TPoint2DArray;
  var
    LRad: Float;
  begin
    if AIsSmall then LRad := AArrowSize/4 else LRad := AArrowSize/2;

    Result := UdGeo2D.SamplePoints(Circle2D(ASeg.P1, LRad), 36);

    if ATrimSeg then
    begin
      if Distance(ASeg) <= LRad then
        ASeg.P1 := ASeg.P2
      else
        ASeg.P1 := ShiftPoint(ASeg.P1, GetAngle(ASeg.P1, ASeg.P2), LRad);
    end;
  end;

  function _CalcObliquePnts(var ASeg: TSegment2D): TPoint2DArray;
  var
    LAng, LRid: Float;
  begin
    LAng := GetAngle(ASeg.P1, ASeg.P2);
    LRid := Sqrt((AArrowSize/2) * (AArrowSize/2) * 2);

    System.SetLength(Result, 2);
    Result[0] := ShiftPoint(ASeg.P1, FixAngle(LAng+45), LRid);
    Result[1] := ShiftPoint(ASeg.P1, FixAngle(LAng+45+180), LRid);
  end;


  function _CalcArchTickPnts(var ASeg: TSegment2D): TPoint2DArray;
  var
    LAng, LRid: Float;
    LTickSeg: TSegment2D;
  begin
    LAng := GetAngle(ASeg.P1, ASeg.P2);
    LRid := Sqrt((AArrowSize/2) * (AArrowSize/2) * 2);

    LTickSeg.P1 := ShiftPoint(ASeg.P1, FixAngle(LAng+45), LRid);
    LTickSeg.P2 := ShiftPoint(ASeg.P1, FixAngle(LAng+45+180), LRid);

    Result := UdGeo2D.SamplePoints(LTickSeg, 0.15 * AArrowSize);
  end;

  function _CalcIntegralPnts(var ASeg: TSegment2D): TPoint2DArray;
  var
    LAng, LRad: Float;
    LArc1, LArc2: TArc2D;
  begin
    LAng := GetAngle(ASeg.P1, ASeg.P2);
    LRad := Sqrt((AArrowSize/2) * (AArrowSize/2)) * CosD(45);

    LArc1 := Arc2D(ShiftPoint(ASeg.P1, LAng, LRad), LRad, FixAngle(LAng+90), FixAngle(LAng+180), False);
    LArc2 := Arc2D(ShiftPoint(ASeg.P1, (LAng+180), LRad), LRad, FixAngle(LAng-90), LAng, True);

    Result := UdGeo2D.SamplePoints(LArc1, 9);
    FAddArray(Result, UdGeo2D.SamplePoints(LArc2, 9));
  end;

  function _CalcBoxPnts(var ASeg: TSegment2D; ATrimSeg: Boolean): TPoint2DArray;
  var
    LAng, LRid: Float;
  begin
    LAng := GetAngle(ASeg.P1, ASeg.P2);
    LRid := Sqrt((AArrowSize / 2) * (AArrowSize / 2) * 2);

    System.SetLength(Result, 5);
    Result[0] := ShiftPoint(ASeg.P1, FixAngle(LAng + 45), LRid);
    Result[1] := ShiftPoint(ASeg.P1, FixAngle(LAng + 135), LRid);
    Result[2] := ShiftPoint(ASeg.P1, FixAngle(LAng + 225), LRid);
    Result[3] := ShiftPoint(ASeg.P1, FixAngle(LAng + 315), LRid);
    Result[4] := Result[0];

    if ATrimSeg then
    begin
      if Distance(ASeg) <= (AArrowSize/2) then
        ASeg.P1 := ASeg.P2
      else
        ASeg.P1 := ShiftPoint(ASeg.P1, GetAngle(ASeg.P1, ASeg.P2), (AArrowSize/2));
    end;
  end;


begin
  Result := False;

  APoints := nil;
  APoints2 := nil;

  AFlag := 0;
  if IsEqual(ASeg.P1, ASeg.P2) then Exit;  //=======>>>

  case AArrowStyle of
    asClosedFilled,
      asClosedBlank    : APoints := _CalcTrianglePnts(ASeg, True, True);
    asClosed           : APoints := _CalcTrianglePnts(ASeg, False, True);
    asDot,
      asDotBlank       : APoints := _CalcDotPnts(ASeg, True, False);
    asArchTick         : APoints := _CalcArchTickPnts(ASeg);
    asOblique          : APoints := _CalcObliquePnts(ASeg);
    asOpen             : APoints := _CalcTrianglePnts(ASeg, False, False);
    asOriginIndicator  : APoints := _CalcDotPnts(ASeg, False, False);
    asOriginIndicator2 : begin
                           APoints2 := _CalcDotPnts(ASeg, False, True);
                           APoints  := _CalcDotPnts(ASeg, True, False);
                         end;
    asRightAngle       : APoints := _CalcTrianglePnts(ASeg, False, False, 45);
    asOpen30           : APoints := _CalcTrianglePnts(ASeg, False, False, 15);
    asDotSmall,
      asDotSmallBlank  : APoints := _CalcDotPnts(ASeg, False, True);
    asBox,
      asBoxFilled      : APoints := _CalcBoxPnts(ASeg, True);
    asDutumTriangle,
      asDutumTriFilled : APoints := _CalcTriangle2Pnts(ASeg, True);
    asIntegral         : APoints := _CalcIntegralPnts(ASeg);
    asNone             : ;
  end;


  case AArrowStyle of
    asClosedFilled     : AFlag := ARROW_CLOSED or ARROW_FILLED;
    asClosedBlank      : AFlag := ARROW_CLOSED;
    asClosed           : AFlag := ARROW_CLOSED;
    asDot              : AFlag := ARROW_CLOSED or ARROW_FILLED;
    asDotBlank         : AFlag := ARROW_CLOSED;
    asArchTick         : AFlag := ARROW_CLOSED or ARROW_FILLED;
    asOblique          : AFlag := 0;
    asOpen             : AFlag := 0;
    asOriginIndicator  : AFlag := ARROW_CLOSED;
    asOriginIndicator2 : AFlag := ARROW_CLOSED;
    asRightAngle       : AFlag := 0;
    asOpen30           : AFlag := 0;
    asDotSmall         : AFlag := ARROW_CLOSED or ARROW_FILLED;
    asDotSmallBlank    : AFlag := ARROW_CLOSED;
    asBox              : AFlag := ARROW_CLOSED;
    asBoxFilled        : AFlag := ARROW_CLOSED or ARROW_FILLED;
    asDutumTriangle    : AFlag := ARROW_CLOSED;
    asDutumTriFilled   : AFlag := ARROW_CLOSED or ARROW_FILLED;
    asIntegral         : AFlag := 0;
    asNone             : AFlag := 0;
  end;
end;

procedure TUdLeader.UpdateSamplePoints(AAxes: TUdAxes);
var
  I, L: Integer;
  LPnts: TPoint2DArray;
  LSeg1, LSeg2: TSegment2D;
  LPoints, LPoints2: TPoint2DArray;
begin
  FSamplePoints := nil;
  FArrow1Ponts := nil;  FArrow1Ponts2 := nil;
  FArrow2Ponts := nil;  FArrow2Ponts2 := nil;

  L := System.Length(FPoints);
  if L < 2 then Exit;


  if FShowArrow then
  begin
    LSeg1 := Segment2D(FPoints[0], FPoints[1]);
    FCalcArrow(LSeg1, FArrowSize1, FArrowStyle1, FArrow1Flag, LPoints, LPoints2);

    FArrow1Ponts  := LPoints;
    FArrow1Ponts2 := LPoints2;


    LSeg2 := Segment2D(FPoints[L-1], FPoints[L-2]);
    FCalcArrow(LSeg2, FArrowSize2, FArrowStyle2, FArrow2Flag, LPoints, LPoints2);

    FArrow2Ponts  := LPoints;
    FArrow2Ponts2 := LPoints2;
  end;


  if FSpline then
  begin
    System.SetLength(LPnts, System.Length(FPoints));
    for I := 0 to System.Length(FPoints) - 1 do LPnts[I] := FPoints[I];

    LPnts[0] := LSeg1.P1;
    LPnts[L-1] := LSeg2.P1;

    FSamplePoints := UdBSpline2D.GetFittingBSplineSamplePoints(LPnts, 24, False);
  end
  else
  begin
    System.SetLength(FSamplePoints, System.Length(FPoints));
    for I := 0 to System.Length(FPoints) - 1 do FSamplePoints[I] := FPoints[I];

    FSamplePoints[0].X := LSeg1.P1.X;
    FSamplePoints[0].Y := LSeg1.P1.Y;
    FSamplePoints[L-1].X := LSeg2.P1.X;
    FSamplePoints[L-1].Y := LSeg2.P1.Y;
  end;
end;



function TUdLeader.GetGripPoints(): TUdGripPointArray;
var
  I: Integer;
begin
  System.SetLength(Result, System.Length(FPoints));
  for I := 0 to System.Length(FPoints) - 1 do
    Result[I] := MakeGripPoint(Self, gmPoint, I, FPoints[I], 0);
end;

function TUdLeader.GetOSnapPoints: TUdOSnapPointArray;
var
  I, L: Integer;
begin
  L := System.Length(FPoints);
  System.SetLength(Result,  L * 2 - 1);

  for I := 0 to L - 1 do
    Result[I] := MakeOSnapPoint(Self, OSNP_END, FPoints[I], -1);

  for I := 0 to L - 2 do
    Result[L + I] := MakeOSnapPoint(Self, OSNP_MID, UdGeo2D.MidPoint(FPoints[I], FPoints[I+1]), -1 );
end;




function TUdLeader.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
var
  LAxes: TUdAxes;
  LFilled: Boolean;
  LOldFillStyle: Integer;
begin
  Result := inherited DoDraw(ACanvas, AAxes, AFlag, 0);

  if Result then
  begin
    LAxes := EnsureAxes(AAxes);

    LOldFillStyle := FFillStyle;
    try
      LFilled := (FArrow1Flag and ARROW_FILLED) > 0;
      if LFilled then FFillStyle := 0;

      if System.Length(FArrow1Ponts) > 0 then
      begin
        if LFilled then
          FDrawPolygon(ACanvas, LAxes, Self.ActualTrueColor(AFlag), 0, FArrow1Ponts)
        else
          FDrawPoints(ACanvas, LAxes, Self.ActualTrueColor(AFlag), Self.ActualLineType(), LW_DEFAULT, 1, FArrow1Ponts, nil);
      end;
      if System.Length(FArrow1Ponts2) > 0 then
      begin
        if LFilled then
          FDrawPolygon(ACanvas, LAxes, Self.ActualTrueColor(AFlag), 0, FArrow1Ponts2)
        else
          FDrawPoints(ACanvas, LAxes, Self.ActualTrueColor(AFlag), Self.ActualLineType(), LW_DEFAULT, 1, FArrow1Ponts2, nil);
      end;


      LFilled := (FArrow2Flag and ARROW_FILLED) > 0;
      if LFilled then FFillStyle := 0;

      if System.Length(FArrow2Ponts) > 0 then
      begin
        if LFilled then
          FDrawPolygon(ACanvas, LAxes, Self.ActualTrueColor(AFlag), 0, FArrow2Ponts)
        else
          FDrawPoints(ACanvas, LAxes, Self.ActualTrueColor(AFlag), Self.ActualLineType(), LW_DEFAULT, 2, FArrow2Ponts, nil);
      end;
      if System.Length(FArrow2Ponts2) > 0 then
      begin
        if LFilled then
          FDrawPolygon(ACanvas, LAxes, Self.ActualTrueColor(AFlag), 0, FArrow2Ponts2)
        else
          FDrawPoints(ACanvas, LAxes, Self.ActualTrueColor(AFlag), Self.ActualLineType(), LW_DEFAULT, 2, FArrow2Ponts2, nil);
      end;

    finally
      FFillStyle := LOldFillStyle;
    end;
  end;
end;



//-----------------------------------------------------------------------------------------


function TUdLeader.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  I: Integer;
  LPnts: TPoint2DArray;
  LOvered: Boolean;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    LOvered := False;
    for I := 0 to System.Length(FPoints) - 1 do
    begin
      if IsEqual(FPoints[I], AGripPnt.Point) then
      begin
        LOvered := True;
        Break;
      end;
    end;

    if not LOvered then
    begin
      System.SetLength(LPnts, System.Length(FPoints));
      for I := 0 to System.Length(FPoints) - 1 do LPnts[I] := FPoints[I];

      LPnts[AGripPnt.Index] := AGripPnt.Point;
      Self.SetPoints( LPnts );

      Result := True;
    end;
  end;
end;


function TUdLeader.Pick(APoint: TPoint2D): Boolean;
var
  D, E: Float;
  LAxes: TUdAxes;
  LPnts: TPoint2DArray;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;

  if FSpline then
    LPnts := FSamplePoints
  else
    LPnts := FPoints;

  if FPenWidth > 0.0 then
  begin
    D := DistanceToPolygon(APoint, LPnts);
    Result := (D < FPenWidth/2) or IsEqual(D, FPenWidth/2, E);
  end
  else
    Result := UdGeo2D.IsPntOnPolygon(APoint, LPnts, E);

  if not Result then
  begin
    if (FArrow1Flag and ARROW_FILLED) > 0 then
    begin
      Result := UdGeo2D.IsPntInPolygon(APoint, FArrow1Ponts, E);
    end
    else begin
      Result := UdGeo2D.IsPntOnPolygon(APoint, FArrow1Ponts, E) or
                UdGeo2D.IsPntOnPolygon(APoint, FArrow1Ponts2, E)  ;
    end;
  end;

  if not Result then
  begin
    if (FArrow2Flag and ARROW_FILLED) > 0 then
    begin
      Result := UdGeo2D.IsPntInPolygon(APoint, FArrow2Ponts, E);
    end
    else begin
      Result := UdGeo2D.IsPntOnPolygon(APoint, FArrow2Ponts, E) or
                UdGeo2D.IsPntOnPolygon(APoint, FArrow2Ponts2, E)  ;
    end;
  end;
end;

function TUdLeader.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
var
  LPnts: TPoint2DArray;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.Inclusion(FBoundsRect, ARect) = irOvered;

  if not Result and ACrossingMode then
  begin
    if FSpline then
      LPnts := FSamplePoints
    else
      LPnts := FPoints;

    Result := UdGeo2D.IsIntersect(ARect, LPnts);
  end;
end;

function TUdLeader.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPoints := UdGeo2D.Translate(Dx, Dy, FPoints);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdLeader.Mirror(APnt1, APnt2: TPoint2D): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPoints := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FPoints);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdLeader.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPoints := UdGeo2D.Rotate(ABase, ARota, FPoints );
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdLeader.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPoints := UdGeo2D.Scale(ABase, AFactor, AFactor, FPoints );
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdLeader.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdLeader;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdLeader.Create({Self.Document, False});

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);
    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      LEntity.FPoints := UdGeo2D.Scale(ABase, XFactor, YFactor, FPoints );
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;



function TUdLeader.Intersect(AOther: TUdEntity): TPoint2DArray;
var
  LPnts: TPoint2DArray;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  if not Self.IsVisible or Self.IsLock() then Exit;
  if not AOther.IsVisible or AOther.IsLock() then Exit;

  if FSpline then
    LPnts := FSamplePoints
  else
    LPnts := FPoints;

  Result := UdUtils.EntitiesIntersection(LPnts, AOther);
end;

function TUdLeader.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  I: Integer;
  LLn: TLine2D;
  LPnt: TPoint2D;
begin
  Result := nil;

  for I := 0 to System.Length(FPoints) - 2 do
  begin
    LLn := UdGeo2D.Line2D(FPoints[I], FPoints[I+1]);

    LPnt := UdGeo2D.ClosestLinePoint(APnt, LLn);
    if UdGeo2D.IsPntOnSegment(LPnt, Segment2D(FPoints[I], FPoints[I+1])) then
    begin
      System.SetLength(Result, 1);
      Result[0] := LPnt;

      Break;
    end;
  end;
end;






//-----------------------------------------------------------------------------------------

procedure TUdLeader.SaveToStream(AStream: TStream);
var
  LStyleName: string;
begin
  inherited;

  LStyleName := '';
  if Assigned(FDimStyle) then LStyleName := FDimStyle.Name;
  StrToStream(AStream, LStyleName);

  PointsToStream(AStream, FPoints);

  BoolToStream(AStream, FSpline);
  BoolToStream(AStream, FShowArrow);

  FloatToStream(AStream, FArrowSize1);
  FloatToStream(AStream, FArrowSize2);

  IntToStream(AStream, Ord(FArrowStyle1));
  IntToStream(AStream, Ord(FArrowStyle2));
end;

procedure TUdLeader.LoadFromStream(AStream: TStream);
var
  LStyleName: string;
begin
  inherited;

  FDimStyle := nil;

  LStyleName := StrFromStream(AStream);
  if Assigned(Self.Document) then
    FDimStyle := Self.DimStyles.GetItem(LStyleName);

  FPoints     := PointsFromStream(AStream);

  FSpline     := BoolFromStream(AStream);
  FShowArrow  := BoolFromStream(AStream);

  FArrowSize1    := FloatFromStream(AStream);
  FArrowSize2    := FloatFromStream(AStream);

  FArrowStyle1   := TUdArrowStyle(IntFromStream(AStream));
  FArrowStyle2   := TUdArrowStyle(IntFromStream(AStream));

  Update();
end;





procedure TUdLeader.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I, N: Integer;
  LStr: string;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);


  if Assigned(FDimStyle) then
    LXmlNode.Prop['DimStyle'] := FDimStyle.Name;

  if System.Length(FPoints) > 0 then
  begin
    N := System.Length(FPoints) -1;
    for I := 0 to N do
    begin
      LStr := LStr + Point2DToStr(FPoints[I]);
      if I <> N then LStr := LStr + ';';
    end;
    LXmlNode.Prop['Points']  := LStr;
  end;


  LXmlNode.Prop['Spline']    := BoolToStr(FSpline, True);
  LXmlNode.Prop['ShowArrow'] := BoolToStr(FShowArrow, True);

  LXmlNode.Prop['ArrowSize']   := FloatToStr(FArrowSize1);
  LXmlNode.Prop['ArrowStyle']  := IntToStr(Ord(ArrowStyle1));

  LXmlNode.Prop['ArrowSize2']  := FloatToStr(FArrowSize2);
  LXmlNode.Prop['ArrowStyle2'] := IntToStr(Ord(ArrowStyle2));
end;

procedure TUdLeader.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  LStrs: TStringDynArray;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FDimStyle := nil;
  if Assigned(Self.Document) then
    FDimStyle := Self.DimStyles.GetItem(LXmlNode.Prop['DimStyle']);

  LStrs := UdUtils.StrSplit(LXmlNode.Prop['Points'], ';');
  SetLength(FPoints, System.Length(LStrs));
  for I := 0 to System.Length(LStrs) - 1 do
    FPoints[I] := StrToPoint2D(LStrs[I]);

  FSpline    := StrToBoolDef(LXmlNode.Prop['Spline'], False);
  FShowArrow := StrToBoolDef(LXmlNode.Prop['ShowArrow'], True);

  FArrowSize1  := StrToFloatDef(LXmlNode.Prop['ArrowSize'], DEF_ARROW_SIZE);
  FArrowStyle1 := TUdArrowStyle(StrToIntDef(LXmlNode.Prop['ArrowStyle'], Ord(DEF_ARROW_KIND)) );

  FArrowSize2  := StrToFloatDef(LXmlNode.Prop['ArrowSize2'], DEF_ARROW_SIZE);
  FArrowStyle2 := TUdArrowStyle(StrToIntDef(LXmlNode.Prop['ArrowStyle2'], Ord(asNone)) );

  Update();
end;

end.