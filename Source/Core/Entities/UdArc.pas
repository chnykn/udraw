{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdArc;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes, UdEllipse; // , AxCanvas

type


  // -----------------------------------------------------
  TUdArc = class(TUdFigure)
  private
    FRadius     : Float;
    FCenter     : TPoint2D;
    FStartAngle : Float;
    FEndAngle   : Float;

    FArcKind: TUdArcKind;

  protected
    function GetTypeID(): Integer; override;

    function GetXData: TArc2D;
    procedure SetXData(const AValue: TArc2D);

    procedure SetRadius(const AValue: Float);
    procedure SetCenter(const AValue: TPoint2D);

    function GetCenterValue(AIndex: Integer): Float;
    procedure SetCenterValue(AIndex: Integer; const AValue: Float);

    function GetCoodValue(AIndex: Integer): Float;

    procedure SetAngle(AIndex: Integer; const AValue: Float);

    function GetTotalAngle: Float;
    procedure SetTotalAngle(const AValue: Float);

    procedure SetArcKind(const AValue: TUdArcKind);

    function GetArcLength: Float;
    function GetArea: Float;

    function CanFilled(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    procedure CopyFrom(AValue: TUdObject); override;
    
  public
    constructor Create(); override;
    destructor Destroy(); override;

    function AsEllipse(): TUdEllipse;

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
    function Extend(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): Boolean; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;
    function BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray; override;
    function Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray; override;

    function Intersect(AOther: TUdEntity): TPoint2DArray; override;
    function Perpend(APnt: TPoint2D): TPoint2DArray; override;


    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Center: TPoint2D read FCenter  write SetCenter;
    property XData : TArc2D   read GetXData write SetXData;

  published
    property CenterX    : Float index 0 read GetCenterValue write SetCenterValue;
    property CenterY    : Float index 1 read GetCenterValue write SetCenterValue;

    property StartX     : Float index 0 read GetCoodValue ;
    property StartY     : Float index 1 read GetCoodValue ;
    property EndX       : Float index 2 read GetCoodValue ;
    property EndY       : Float index 3 read GetCoodValue ;

    property Radius     : Float         read FRadius        write SetRadius;

    property StartAngle : Float index 0 read FStartAngle    write SetAngle;
    property EndAngle   : Float index 1 read FEndAngle      write SetAngle;
    property TotalAngle : Float         read GetTotalAngle  write SetTotalAngle;

    property ArcKind    : TUdArcKind    read FArcKind       write SetArcKind;
    property ArcLength  : Float read GetArcLength;
    property Area       : Float read GetArea ;

    property Filled;
    property FillStyle;

    property HasBorder;
    property BorderColor;
  end;

  function GetArcTrimBreakPnts(AArc: TArc2D; APnt: TPoint2D; var AInctPnts: TPoint2DArray; var AP1, AP2: TPoint2D): Boolean;

implementation

uses
  SysUtils,
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, UdColls;



//==================================================================================================
{ TUdArc }

constructor TUdArc.Create();
begin
  inherited;

  FRadius     := 0.0;
  FCenter.X   := 0.0;
  FCenter.Y   := 0.0;
  FStartAngle := 0.0;
  FEndAngle   := 0.0;
  FArcKind    := akCurve;
end;

destructor TUdArc.Destroy;
begin
  inherited;
end;




function TUdArc.GetTypeID: Integer;
begin
  Result := ID_ARC;
end;

//function TUdArc.GetCenter(): PPoint2D;
//begin
//  Result := @FCenter;
//end;



//-----------------------------------------------------------------------------------------


function TUdArc.GetXData: TArc2D;
begin
  Result := Arc2D(FCenter, FRadius, FStartAngle, FEndAngle, False, FArcKind);
end;

procedure TUdArc.SetXData(const AValue: TArc2D);
begin
  if Self.RaiseBeforeModifyObject('XData') then
  begin
    FCenter := AValue.Cen;
    FRadius := AValue.R;
    FStartAngle := AValue.Ang1;
    FEndAngle := AValue.Ang2;
    FArcKind := AValue.Kind;

    Self.Update();
    Self.RaiseAfterModifyObject('XData');
  end;
end;

procedure TUdArc.SetCenter(const AValue: TPoint2D);
begin
  if NotEqual(FCenter, AValue) and Self.RaiseBeforeModifyObject('Center') then
  begin
    FCenter := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Center');
  end;
end;


function TUdArc.GetCenterValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FCenter.X;
    1: Result := FCenter.Y;
  end;
end;

procedure TUdArc.SetCenterValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FCenter;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FCenter) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('CenterX');
    1: Self.RaiseBeforeModifyObject('CenterY');
  end;

  FCenter := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('CenterX');
    1: Self.RaiseAfterModifyObject('CenterY');
  end;
end;


function TUdArc.GetCoodValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := ShiftPoint(FCenter, FStartAngle, FRadius).X;
    1: Result := ShiftPoint(FCenter, FStartAngle, FRadius).Y;
    2: Result := ShiftPoint(FCenter, FEndAngle, FRadius).X;
    3: Result := ShiftPoint(FCenter, FEndAngle, FRadius).Y;
  end;
end;


procedure TUdArc.SetRadius(const AValue: Float);
begin
  if NotEqual(AValue, 0.0) and NotEqual(FRadius, AValue) and
     Self.RaiseBeforeModifyObject('Radius') then
  begin
    FRadius := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Radius');
  end;
end;




procedure TUdArc.SetAngle(AIndex: Integer; const AValue: Float);
begin
  case AIndex of
    0: if NotEqual(FStartAngle, AValue) and Self.RaiseBeforeModifyObject('StartAngle') then
      begin
        FStartAngle := FixAngle(AValue);
        Self.Update();
        Self.RaiseAfterModifyObject('StartAngle');
      end;
    1: if NotEqual(FEndAngle, AValue) and Self.RaiseBeforeModifyObject('EndAngle') then
      begin
        FEndAngle := FixAngle(AValue);
        Self.Update();
        Self.RaiseAfterModifyObject('EndAngle');
      end;
  end;
end;


function TUdArc.GetTotalAngle: Float;
begin
  Result := FixAngle(FEndAngle - FStartAngle);
end;

procedure TUdArc.SetTotalAngle(const AValue: Float);
begin
  if (AValue < 0) or (AValue > 360) then
    raise Exception.Create('TotalAngle must in [0-360]');

  if not Self.RaiseBeforeModifyObject('TotalAngle') then Exit; //========>>>

  FEndAngle := FixAngle(FStartAngle + AValue);
  Self.Update();

  Self.RaiseAfterModifyObject('TotalAngle')
end;




procedure TUdArc.SetArcKind(const AValue: TUdArcKind);
begin
  if (FArcKind <> AValue) and Self.RaiseBeforeModifyObject('ArcKind') then
  begin
    FArcKind := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ArcKind');
  end;
end;


function TUdArc.GetArcLength: Float;
begin
  Result := UdGeo2D.Distance(Self.GetXData());
end;

function TUdArc.GetArea: Float;
var
  LKind: TArcKind;
begin
  LKind := FArcKind;
  if LKind = akCurve then LKind := akSector;
  Result := UdGeo2D.Area(Self.GetXData(), LKind);
end;




procedure TUdArc.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdArc) then Exit; //========>>>

  Self.FRadius := TUdArc(AValue).FRadius;
  Self.FCenter := TUdArc(AValue).FCenter;
  Self.FStartAngle := TUdArc(AValue).FStartAngle;
  Self.FEndAngle := TUdArc(AValue).FEndAngle;
  Self.FArcKind := TUdArc(AValue).FArcKind;

  Self.Update();
end;


function TUdArc.AsEllipse(): TUdEllipse;
begin
  Result := TUdEllipse.Create({Self.Document, False});

  Result.BeginUpdate();
  try
    Result.Assign(Self);
    Result.XData := Ellipse2D(FCenter, FRadius, FRadius, FStartAngle, FEndAngle, 0, False, akCurve);
  finally
    Result.EndUpdate();
  end;
end;



//-----------------------------------------------------------------------------------------

function TUdArc.CanFilled(): Boolean;
begin
  Result := FArcKind in [akSector, akChord];
end;

procedure TUdArc.UpdateBoundsRect(AAxes: TUdAxes);
var
  LPnts: TPoint2DArray;
  LArc: TArc2D;
begin
  LArc := Self.GetXData();
  LArc.Kind := akSector;

//  if (FArcKind = akSector) then
//  begin
    LPnts := ArcHullPnts(LArc);
    System.SetLength(LPnts, System.Length(LPnts) + 1);

    LPnts[High(LPnts)] := FCenter;
    FBoundsRect := UdGeo2D.RectHull(LPnts);
//  end
//  else
//    FBoundsRect := UdGeo2D.RectHull(Self.GetXData());
end;

procedure TUdArc.UpdateSamplePoints(AAxes: TUdAxes);
var
  N: Integer;
  LPoints: TPoint2DArray;
begin
  FSamplePoints := nil;
  if IsEqual(FRadius, 0) then Exit; //=======>>>>

  N := SampleSegmentNum(AAxes.XValuePerPixel, Self.FRadius, FixAngle(FEndAngle - FStartAngle));

  case FArcKind  of
    akCurve : LPoints := UdGeo2D.SamplePoints(Self.GetXData(), N, 0.0);
    akSector:
      begin
        System.SetLength(LPoints, 1);
        LPoints[0] := FCenter;
        FAddArray(LPoints, UdGeo2D.SamplePoints(Self.GetXData(), N, 0.0));
        System.SetLength(LPoints, System.Length(LPoints) + 1);
        LPoints[High(LPoints)] := FCenter;
      end;
    akChord :
      begin
        LPoints := UdGeo2D.SamplePoints(Self.GetXData(), N, 0.0);
        System.SetLength(LPoints, System.Length(LPoints) + 1);
        LPoints[High(LPoints)] := LPoints[0];
      end;
  end;

  FSamplePoints := LPoints;
end;





function TUdArc.GetGripPoints(): TUdGripPointArray;
var
  LArc: TArc2D;
  LMidAng: Float;
  LAxes: TUdAxes;
  LP1, LP2: TPoint2D;
  LAngGripDis: Float;
begin
  LArc := Self.GetXData();
  LMidAng := FixAngle(FStartAngle + FixAngle(FEndAngle - FStartAngle)/2);

  System.SetLength(Result, 7);

  Result[0] := MakeGripPoint(Self, gmCenter, 0, FCenter, 0.0);

  Result[1] := MakeGripPoint(Self, gmPoint, 0, GetArcPoint(LArc.Cen, LArc.R, FStartAngle), FStartAngle);
  Result[2] := MakeGripPoint(Self, gmPoint, 1, GetArcPoint(LArc.Cen, LArc.R, LMidAng), LMidAng);
  Result[3] := MakeGripPoint(Self, gmPoint, 2, GetArcPoint(LArc.Cen, LArc.R, FEndAngle), FEndAngle);

  LAngGripDis := ANGLE_GRIP_DIS;
  LAxes := Self.EnsureAxes(nil);
  if Assigned(LAxes) then LAngGripDis := LAngGripDis * LAxes.XValuePerPixel;

  Result[4] := MakeGripPoint(Self, gmRadius,   0, GetArcPoint(LArc.Cen, LArc.R + LAngGripDis, LMidAng), LMidAng);

  LP1 := GetArcPoint(FCenter, FRadius, FStartAngle);
  LP2 := GetArcPoint(FCenter, FRadius, FEndAngle);

  Result[5] := MakeGripPoint(Self, gmAngle, 1, ShiftPoint(LP1, FixAngle(FStartAngle-90), LAngGripDis), FStartAngle);
  Result[6] := MakeGripPoint(Self, gmAngle, 2, ShiftPoint(LP2, FixAngle(FEndAngle+90), LAngGripDis), FEndAngle);

//  Result[7] := MakeGripPoint(gmRotation, 0, FCenter, FStartAngle);
end;

function TUdArc.GetOSnapPoints: TUdOSnapPointArray;
var
  I: Integer;
  LMidAng: Float;
  LQuaPnts: TPoint2DArray;  
begin
  LMidAng := FixAngle(FStartAngle + FixAngle(FEndAngle - FStartAngle) / 2);

  LQuaPnts := ArcQuadPnts(Self.GetXData());
  System.SetLength(Result, 4 + System.Length(LQuaPnts));

  Result[0] := MakeOSnapPoint(Self, OSNP_END, ShiftPoint(FCenter, FStartAngle, FRadius), FStartAngle);
  Result[1] := MakeOSnapPoint(Self, OSNP_MID, ShiftPoint(FCenter, FStartAngle, LMidAng), LMidAng);
  Result[2] := MakeOSnapPoint(Self, OSNP_END, ShiftPoint(FCenter, FEndAngle, FRadius), FEndAngle);
  Result[3] := MakeOSnapPoint(Self, OSNP_CEN, FCenter, -1);

  //-------- Quadrant point --------

  if System.Length(LQuaPnts) > 0 then
  begin
    for I := 0 to System.Length(LQuaPnts) - 1 do
      Result[4 + I] := MakeOSnapPoint(Self, OSNP_QUA, LQuaPnts[I], -1{UdGeo2D.GetAngle(FCenter, LQuaPnts[I])} );
  end;
end;






//-----------------------------------------------------------------------------------------

function TUdArc.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  LAng: Float;
  LArc: TArc2D;
  LP0, LP1, LP2: TPoint2D;
begin
  Result := False;

  case AGripPnt.Mode of
    gmCenter: Result := Self.Move(FCenter, AGripPnt.Point);
    gmPoint:
      begin
        LP0 := GetArcPoint(FCenter, FRadius, FStartAngle);
        LP1 := GetArcPoint(FCenter, FRadius, FixAngle(FStartAngle + FixAngle(FEndAngle-FStartAngle)/2) );
        LP2 := GetArcPoint(FCenter, FRadius, FEndAngle);

        case AGripPnt.Index of
          0: LP0 := AGripPnt.Point;
          1: LP1 := AGripPnt.Point;
          2: LP2 := AGripPnt.Point;
        end;

        LArc := UdGeo2D.MakeArc(LP0, LP1, LP2);
        LArc.Kind := FArcKind;

        if LArc.R > 0 then SetXData(LArc);
        Result := True;
      end;
    gmRadius:
      begin
        Self.Radius := Distance(AGripPnt.Point, FCenter);
        Result := True;
      end;
    gmAngle:
      begin
        LAng := GetAngle(FCenter, AGripPnt.Point);
        if AGripPnt.Index = 1 then SetAngle(0, LAng) else
        if AGripPnt.Index = 2 then SetAngle(1, LAng) ;

        Result := True;
      end;
  end;
end;


function TUdArc.Pick(APoint: TPoint2D): Boolean;
var
  E: Float;
  D, A: Float;
  LAxes: TUdAxes;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;

  if (FPenWidth > 0.0) then
  begin
    A := UdGeo2D.GetAngle(FCenter, APoint);
    if (A < 0.0) or not IsInAngles(A, FStartAngle, FEndAngle, _Epsilon*100) then Exit;   //---->>>>

    D := UdGeo2D.Distance(FCenter, APoint);
    Result := ((D > FRadius-FPenWidth/2) or IsEqual(D, FRadius-FPenWidth/2, E)) and
              ((D < FRadius+FPenWidth/2) or IsEqual(D, FRadius+FPenWidth/2, E)) ;
  end
  else
    Result := UdGeo2D.IsPntOnArc(APoint, Self.GetXData(), E);

  if not Result and Self.CanFilled() and FFilled then
    Result := UdGeo2D.IsPntInArc(APoint, Self.GetXData(), E);
end;

function TUdArc.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
var
  LIc: TInclusion;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LIc := UdGeo2D.Inclusion(FBoundsRect, ARect);
  Result := LIc = irOvered;

  if not Result and ACrossingMode then
    Result := UdGeo2D.IsIntersect(ARect, Self.GetXData()) and (LIc <> irOutside);
end;

function TUdArc.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');
  FCenter := UdGeo2D.Translate(Dx, Dy, FCenter);
  Result := Self.Update();
  Self.RaiseAfterModifyObject('');
end;

function TUdArc.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LTheArc, LNewArc: TArc2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LTheArc := UdGeo2D.Arc2D(FCenter, FRadius, FStartAngle, FEndAngle);
  LNewArc := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LTheArc);

  FRadius     := LNewArc.R;
  FCenter     := LNewArc.Cen;
  FStartAngle := LNewArc.Ang1;
  FEndAngle   := LNewArc.Ang2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdArc.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
var
  LNewArc: TArc2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ADis, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LNewArc := UdGeo2D.OffsetArc(Self.GetXData(), ADis, ASidePnt);

  FRadius     := LNewArc.R;
  FCenter     := LNewArc.Cen;
  FStartAngle := LNewArc.Ang1;
  FEndAngle   := LNewArc.Ang2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdArc.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
var
  LNewArc: TArc2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LNewArc := UdGeo2D.Rotate(ABase, ARota, UdGeo2D.Arc2D(FCenter, FRadius, FStartAngle, FEndAngle));

  FRadius     := LNewArc.R;
  FCenter     := LNewArc.Cen;
  FStartAngle := LNewArc.Ang1;
  FEndAngle   := LNewArc.Ang2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdArc.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
var
  LNewArc: TArc2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LNewArc := UdGeo2D.Scale(ABase, Abs(AFactor), UdGeo2D.Arc2D(FCenter, FRadius, FStartAngle, FEndAngle));

  FRadius     := LNewArc.R;
  FCenter     := LNewArc.Cen;
  FStartAngle := LNewArc.Ang1;
  FEndAngle   := LNewArc.Ang2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdArc.Extend(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): Boolean;
var
  I, J: Integer;
  LAng: Float;
  LCir: TCircle2D;
  LIsP1: Boolean;
  LP1, LP2, LPnt: TPoint2D;
  LInctPnts: TPoint2DArray;
  LPointList: TPoint2DList;
begin
  Result := False;
  if IsEqual(FStartAngle, FEndAngle) or
     (IsEqual(FStartAngle, 0.0) and IsEqual(FEndAngle, 360.0)) then Exit; //=======>>>>

  LCir := Circle2D(FCenter, FRadius);
  LInctPnts := nil;

  LPointList := TPoint2DList.Create(MAXBYTE);
  try
    for I := 0 to System.Length(ASelectedEntities) - 1 do
    begin
      if Assigned(ASelectedEntities[I]) and (ASelectedEntities[I] <> Self) then
      begin
        LInctPnts := UdUtils.EntitiesIntersection(LCir, ASelectedEntities[I]);
        for J := 0 to System.Length(LInctPnts) - 1 do LPointList.Add(LInctPnts[J]);
      end;
    end;

    for I := LPointList.Count - 1 downto 0 do
    begin
      LAng := UdGeo2D.GetAngle(FCenter, LPointList.GetPoint(I));
      if (LAng < 0) or IsInAngles(LAng, FStartAngle, FEndAngle) then
        LPointList.RemoveAt(I);
    end;

    LInctPnts := LPointList.ToArray();
  finally
    LPointList.Free;
  end;

  if System.Length(LInctPnts) <= 0 then Exit;  //=======>>>>>>


  Self.RaiseBeforeModifyObject('');

  LP1 := UdGeo2D.ShiftPoint(FCenter, FStartAngle, FRadius);
  LP2 := UdGeo2D.ShiftPoint(FCenter, FEndAngle, FRadius);

  if UdGeo2D.Distance(LP1, APnt) < UdGeo2D.Distance(LP2, APnt) then
  begin
    LPnt := LP1;
    LIsP1 := True;
  end
  else begin
    LPnt := LP2;
    LIsP1 := False;
  end;

  LPnt := UdGeo2D.NearestPoint(LInctPnts, LPnt);
  LAng := UdGeo2D.GetAngle(FCenter, LPnt);

  if LIsP1 then
  begin
    if UdMath.NotEqual(FEndAngle, LAng) then FStartAngle := LAng;
    Self.Update();
  end
  else begin
    if UdMath.NotEqual(FStartAngle, LAng) then FEndAngle := LAng;
    Self.Update();
  end;

  Self.RaiseAfterModifyObject('');

  Result := True;
end;



function TUdArc.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEll: TEllipse2D;
  LEntity: TUdEntity;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  if IsEqual(XFactor, YFactor) then
  begin
    LEntity := TUdArc.Create({Self.Document, False});

    LEntity.BeginUpdate();
    try
      LEntity.Assign(Self);
      TUdArc(LEntity).XData := UdGeo2D.Scale(ABase, XFactor, Self.GetXData());
    finally
      LEntity.EndUpdate();
    end;

    System.SetLength(Result, 1);
    Result[0] := LEntity;
  end
  else begin
    LEntity := TUdEllipse.Create({Self.Document, False});

    LEntity.BeginUpdate();
    try
      LEntity.Assign(Self);

      if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
      begin
        LEll := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.GetXData());
        TUdEllipse(LEntity).XData := LEll;
      end;
    finally
      LEntity.EndUpdate();
    end;

    System.SetLength(Result, 1);
    Result[0] := LEntity;
  end;
end;

function TUdArc.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  I: Integer;
  LArcObj: TUdArc;
  LArcs: TArc2DArray;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>

  LArcs := UdGeo2D.BreakAt( UdGeo2D.Arc2D(FCenter, FRadius, FStartAngle, FEndAngle) ,  APnt1, APnt2);

  System.SetLength(Result, System.Length(LArcs));
  for I := 0 to System.Length(LArcs) - 1 do
  begin
    LArcObj := TUdArc(Self.Clone());
    LArcObj.SetXData(LArcs[I]);

    Result[I] := LArcObj;
  end;
end;


function GetArcTrimBreakPnts(AArc: TArc2D; APnt: TPoint2D; var AInctPnts: TPoint2DArray; var AP1, AP2: TPoint2D): Boolean;
var
  I: Integer;
  LPnt: TPoint2D;
  LDis: Float;
  LAng1, LAng2: Float;
  LFound: Boolean;
begin
  Result := False;
  if System.Length(AInctPnts) <= 0 then Exit; //======>>>>

  AArc.IsCW := False; //Important!!!

  LPnt := ClosestArcPoint(APnt, AArc);
  LAng1 := GetAngle(AArc.Cen, LPnt);
  LDis := FixAngle(LAng1 - AArc.Ang1);

  LFound := False;

  UdGeo2D.SortPoints(AInctPnts, AArc);

  for I := 0 to System.Length(AInctPnts) - 1 do
  begin
    LAng2 := GetAngle(AArc.Cen, AInctPnts[I]);
    if FixAngle(LAng2 - AArc.Ang1) > LDis then
    begin
      LFound := True;
      if I > 0 then
        AP1 := AInctPnts[I-1]
      else
        AP1 := GetArcPoint(AArc.Cen, AArc.R, AArc.Ang1);

      AP2 := AInctPnts[I];
      Break;
    end;
  end;

  if not LFound then
  begin
    AP1 := AInctPnts[High(AInctPnts)];
    AP2 := GetArcPoint(AArc.Cen, AArc.R, AArc.Ang2);
  end;

  Result := True;
end;

function TUdArc.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;
var
  LArc: TArc2D;
  LP1, LP2: TPoint2D;
  LInctPnts: TPoint2DArray;
begin
  Result := nil;

  LArc := Self.GetXData();
  LArc.IsCW := False; //Important!!!

  LInctPnts := UdUtils.EntitiesIntersection(Self, ASelectedEntities);

  if GetArcTrimBreakPnts(LArc, APnt, LInctPnts, LP1, LP2) then
    Result := Self.BreakAt(LP1, LP2);
end;





function TUdArc.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;

  if not Self.IsVisible or Self.IsLock() then Exit; //======>>>>
  if not Assigned(AOther) or not AOther.IsVisible or AOther.IsLock() then Exit; //======>>>>

  Result := UdUtils.EntitiesIntersection(Self.GetXData(), AOther);
end;

function TUdArc.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  LLn: TLine2D;
begin
  LLn := UdGeo2D.Line2D(APnt, FCenter);
  Result := UdGeo2D.Intersection(LLn, Self.GetXData());
end;








//-----------------------------------------------------------------------------------------

procedure TUdArc.SaveToStream(AStream: TStream);
begin
  inherited;

  FloatToStream(AStream, FRadius);
  FloatToStream(AStream, FCenter.X);
  FloatToStream(AStream, FCenter.Y);
  FloatToStream(AStream, FStartAngle);
  FloatToStream(AStream, FEndAngle);
  IntToStream(AStream, Ord(FArcKind));
end;

procedure TUdArc.LoadFromStream(AStream: TStream);
begin
  inherited;

  FRadius   := FloatFromStream(AStream);
  FCenter.X := FloatFromStream(AStream);
  FCenter.Y := FloatFromStream(AStream);
  FStartAngle := FloatFromStream(AStream);
  FEndAngle   := FloatFromStream(AStream);
  FArcKind  := TUdArcKind(IntFromStream(AStream));

  Update();
end;





procedure TUdArc.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Radius']  := FloatToStr(FRadius);
  LXmlNode.Prop['Center']  := Point2DToStr(FCenter);

  LXmlNode.Prop['StartAngle'] := FloatToStr(FStartAngle);
  LXmlNode.Prop['EndAngle']   := FloatToStr(FEndAngle);
  LXmlNode.Prop['ArcKind']    := IntToStr(Ord(FArcKind));
end;

procedure TUdArc.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FRadius := StrToFloatDef(LXmlNode.Prop['Radius'], 0);
  FCenter := StrToPoint2D(LXmlNode.Prop['Center']);

  FStartAngle := StrToFloatDef(LXmlNode.Prop['StartAngle'], 0);
  FEndAngle   := StrToFloatDef(LXmlNode.Prop['EndAngle'], 0);
  FArcKind    := TUdArcKind(StrToIntDef(LXmlNode.Prop['ArcKind'], 0));

  Update();
end;

end.