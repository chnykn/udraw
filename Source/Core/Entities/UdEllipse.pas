{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdEllipse;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes;

type

  //-----------------------------------------------------
  TUdEllipse = class(TUdFigure)
  private
    FCenter      : TPoint2D;
    FMajorRadius : Float;
    FMinorRadius : Float;
    FStartAngle  : Float;
    FEndAngle    : Float;
    FRotation    : Float;

    FArcKind: TUdArcKind;

  protected
    function GetTypeID(): Integer; override;

    function GetXData: TEllipse2D;
    procedure SetXData(const AValue: TEllipse2D);

    procedure SetCenter(const AValue: TPoint2D);

    function GetCenterValue(AIndex: Integer): Float;
    procedure SetCenterValue(AIndex: Integer; const AValue: Float);

    function GetCoodValue(AIndex: Integer): Float;

    procedure SetRadius(AIndex: Integer; const AValue: Float);
    procedure SetAngle(AIndex: Integer; const AValue: Float);

    function GetTotalAngle: Float;
    procedure SetTotalAngle(const AValue: Float);

    procedure SetRotation(const AValue: Float);

    procedure SetArcKind(const AValue: TUdArcKind);

    function GetArcLength: Float;
    function GetArea: Float;

    function Closed(): Boolean;
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
    property Center     : TPoint2D read FCenter   write SetCenter;
    property XData: TEllipse2D    read GetXData write SetXData;

  published
    property CenterX    : Float index 0 read GetCenterValue write SetCenterValue;
    property CenterY    : Float index 1 read GetCenterValue write SetCenterValue;

    property StartX     : Float index 0 read GetCoodValue ;
    property StartY     : Float index 1 read GetCoodValue ;
    property EndX       : Float index 2 read GetCoodValue ;
    property EndY       : Float index 3 read GetCoodValue ;

    property MajorRadius: Float index 0 read FMajorRadius write SetRadius;
    property MinorRadius: Float index 1 read FMinorRadius write SetRadius;

    property StartAngle : Float index 0 read FStartAngle    write SetAngle;
    property EndAngle   : Float index 1 read FEndAngle      write SetAngle;
    property TotalAngle : Float         read GetTotalAngle  write SetTotalAngle;

    property Rotation   : Float         read FRotation    write SetRotation;

    property ArcKind    : TUdArcKind    read FArcKind     write SetArcKind;
    property ArcLength  : Float         read GetArcLength;
    property Area       : Float         read GetArea ;

  end;

implementation

uses
  SysUtils,
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, UdColls;




//==================================================================================================
{ TUdEllipse }

constructor TUdEllipse.Create();
begin
  inherited;

  FCenter      := Point2D(0.0, 0.0);
  FMajorRadius := 10.0;
  FMinorRadius := 8.0;
  FStartAngle  := 0.0;
  FEndAngle    := 360.0;
  FRotation    := 0.0;

  FArcKind     := akCurve;
end;

destructor TUdEllipse.Destroy;
begin
  inherited;
end;



function TUdEllipse.GetTypeID: Integer;
begin
  Result := ID_ELLIPSE;
end;

//function TUdEllipse.GetCenter(): PPoint2D;
//begin
//  Result := @FCenter;
//end;


//-----------------------------------------------------------------------------------------


function TUdEllipse.GetXData: TEllipse2D;
begin
  Result := Ellipse2D(FCenter, FMajorRadius  , FMinorRadius, FStartAngle, FEndAngle, FRotation, False, FArcKind);
end;

procedure TUdEllipse.SetXData(const AValue: TEllipse2D);
begin
  if Self.RaiseBeforeModifyObject('XData') then
  begin
    FCenter  := AValue.Cen ;
    FMajorRadius   := AValue.Rx  ;
    FMinorRadius := AValue.Ry  ;
    FStartAngle  := AValue.Ang1;
    FEndAngle  := AValue.Ang2;
    FRotation:= AValue.Rot ;

    Self.Update();
    Self.RaiseAfterModifyObject('XData');
  end;
end;




procedure TUdEllipse.SetCenter(const AValue: TPoint2D);
begin
  if NotEqual(FCenter, AValue) and Self.RaiseBeforeModifyObject('Center') then
  begin
    FCenter := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Center');
  end;
end;

function TUdEllipse.GetCenterValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FCenter.X;
    1: Result := FCenter.Y;
  end;
end;

procedure TUdEllipse.SetCenterValue(AIndex: Integer; const AValue: Float);
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


function TUdEllipse.GetCoodValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := GetEllipsePoint(Self.GetXData(), FStartAngle).X;
    1: Result := GetEllipsePoint(Self.GetXData(), FStartAngle).Y;
    2: Result := GetEllipsePoint(Self.GetXData(), FEndAngle).X;
    3: Result := GetEllipsePoint(Self.GetXData(), FEndAngle).Y;
  end;
  if IsEqual(Result, 0.0) then Result := 0.0;
end;


procedure TUdEllipse.SetRadius(AIndex: Integer; const AValue: Float);
begin
  case AIndex of
    0:
    begin
      if NotEqual(FMajorRadius, AValue) and Self.RaiseBeforeModifyObject('MajorRadius') then
      begin
        FMajorRadius := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('MajorRadius');
      end;
    end;
    1:
    begin
      if NotEqual(FMajorRadius, AValue) and Self.RaiseBeforeModifyObject('MinorRadius') then
      begin
        FMinorRadius := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('MinorRadius');
      end;
    end;
  end;
end;

procedure TUdEllipse.SetAngle(AIndex: Integer; const AValue: Float);
begin
  case AIndex of
    0:
    begin
      if NotEqual(FStartAngle, AValue) and Self.RaiseBeforeModifyObject('StartAngle') then
      begin
        FStartAngle := FixAngle(AValue);
        if IsEqual(FStartAngle, FEndAngle) then
        begin
          FStartAngle := 0.0;
          FEndAngle := 360.0;
        end;
        Self.Update();
        Self.RaiseAfterModifyObject('StartAngle');
      end;
    end;
    1:
    begin
      if NotEqual(FEndAngle, AValue) and Self.RaiseBeforeModifyObject('EndAngle') then
      begin
        FEndAngle := FixAngle(AValue);
        if IsEqual(FStartAngle, FEndAngle) then
        begin
          FStartAngle := 0.0;
          FEndAngle := 360.0;
        end;
        Self.Update();
        Self.RaiseAfterModifyObject('EndAngle');
      end;
    end;
  end;
end;


function TUdEllipse.GetTotalAngle: Float;
begin
  Result := FixAngle(FEndAngle - FStartAngle);
end;

procedure TUdEllipse.SetTotalAngle(const AValue: Float);
begin
  if (AValue < 0) or (AValue > 360) then
    raise Exception.Create('TotalAngle must in [0-360]');

  if not Self.RaiseBeforeModifyObject('TotalAngle') then Exit; //========>>>

  FEndAngle := FixAngle(FStartAngle + AValue);
  Self.Update();

  Self.RaiseAfterModifyObject('TotalAngle')
end;




procedure TUdEllipse.SetRotation(const AValue: Float);
begin
  if NotEqual(FRotation, AValue) and Self.RaiseBeforeModifyObject('Rotation') then
  begin
    FRotation := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Rotation');
  end;
end;

procedure TUdEllipse.SetArcKind(const AValue: TUdArcKind);
begin
  if (FArcKind <> AValue) and Self.RaiseBeforeModifyObject('ArcKind') then
  begin
    FArcKind := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ArcKind');
  end;
end;


function TUdEllipse.GetArcLength: Float;
var
  N: Integer;
  LPoints: TPoint2DArray;
begin
  if Self.Closed() then N := 360 else N := Trunc(FixAngle(FEndAngle - FStartAngle));
  LPoints := UdGeo2D.SamplePoints(Self.GetXData(), N, 0.0);
  Result := UdGeo2D.Perimeter(LPoints);
end;

function TUdEllipse.GetArea: Float;
var
  N: Integer;
  LPoints: TPoint2DArray;
begin
  if Self.Closed() then N := 360 else N := Trunc(FixAngle(FEndAngle - FStartAngle));

  case FArcKind  of
    akCurve,
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

  Result := UdGeo2D.Area(LPoints);
end;



procedure TUdEllipse.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdEllipse) then Exit; //========>>>

  FCenter      := TUdEllipse(AValue).FCenter;
  FMajorRadius := TUdEllipse(AValue).FMajorRadius;
  FMinorRadius := TUdEllipse(AValue).FMinorRadius;
  FStartAngle  := TUdEllipse(AValue).FStartAngle ;
  FEndAngle    := TUdEllipse(AValue).FEndAngle;
  FRotation    := TUdEllipse(AValue).FRotation;
  FArcKind     := TUdEllipse(AValue).FArcKind;

  Self.Update();
end;




//-----------------------------------------------------------------------------------------

function TUdEllipse.Closed(): Boolean;
begin
  Result := IsEqual(FStartAngle, 0.0) and IsEqual(FEndAngle, 360.0);
end;

function TUdEllipse.CanFilled(): Boolean;
begin
  if Self.Closed() then
    Result := True
  else
    Result := (FArcKind in [akSector, akChord]) ;
end;


procedure TUdEllipse.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect := UdGeo2D.RectHull(GetXData());
end;

procedure TUdEllipse.UpdateSamplePoints(AAxes: TUdAxes);
var
  N: Integer;
  LPoints: TPoint2DArray;
begin
  FSamplePoints := nil;
  if IsEqual(FMajorRadius  , 0.0) and IsEqual(FMinorRadius, 0.0) then Exit; //=======>>>>

  N := SampleSegmentNum(AAxes.XValuePerPixel, Max(Abs(FMajorRadius  ), Abs(FMinorRadius)), FixAngle(FEndAngle - FStartAngle));

  if Self.Closed() then
  begin
    LPoints := UdGeo2D.SamplePoints(Self.GetXData(), N, 0.0);
  end
  else begin
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
  end;

  FSamplePoints := LPoints;
end;



function TUdEllipse.GetGripPoints: TUdGripPointArray;
var
  LDis: Float;
  LAng1, LAng2: Float;
  LAxes: TUdAxes;
  LEll: TEllipse2D;
  LP1, LP2: TPoint2D;
begin
  LEll := Self.GetXData();

  System.SetLength(Result, 7);

  Result[0] := MakeGripPoint(Self, gmCenter, 0, FCenter, 0.0);

  Result[1] := MakeGripPoint(Self, gmSize, 1, GetEllipsePoint(LEll, 0.0),   0.0);
  Result[2] := MakeGripPoint(Self, gmSize, 2, GetEllipsePoint(LEll, 180.0), 180.0);
  Result[3] := MakeGripPoint(Self, gmSize, 3, GetEllipsePoint(LEll, 90.0),  90.0);
  Result[4] := MakeGripPoint(Self, gmSize, 4, GetEllipsePoint(LEll, 270.0), 270.0);

  LDis := 2*DEFAULT_PICK_SIZE;
  LAxes := Self.EnsureAxes(nil);
  if Assigned(LAxes) then LDis := LAxes.XValuePerPixel * LDis;

  LP1 := GetEllipsePoint(LEll, FStartAngle);
  if FMinorRadius > 0 then
  begin
    LP1 := ShiftPoint(LP1, FStartAngle+FRotation - 90, LDis);
  end
  else begin
    LP1 := ShiftPoint(LP1, FStartAngle+FRotation + 90, LDis);
  end;

  LP2 := GetEllipsePoint(LEll, FEndAngle);
  if FMajorRadius > 0 then
  begin
    LP2 := ShiftPoint(LP2, FEndAngle+FRotation + 90, LDis);
  end
  else begin
    LP2 := ShiftPoint(LP2, FEndAngle+FRotation - 90, LDis);
  end;

  LAng1 := CenAngToEllAng(FMajorRadius, FMinorRadius, FStartAngle) + FRotation;
  LAng2 := CenAngToEllAng(FMajorRadius, FMinorRadius, FEndAngle) + FRotation;

  Result[5] := MakeGripPoint(Self, gmAngle, 1, LP1, LAng1);
  Result[6] := MakeGripPoint(Self, gmAngle, 2, LP2, LAng2);
end;

function TUdEllipse.GetOSnapPoints: TUdOSnapPointArray;
var
  I: Integer;
  LEll: TEllipse2D;
  LMidAng: Float;
  LQuaPnts: TPoint2DArray;  
begin
  LEll := Self.GetXData();
  LMidAng := FixAngle(FStartAngle + FixAngle(FEndAngle - FStartAngle)/2);

  LQuaPnts := EllipseQuadPnts(LEll);
  System.SetLength(Result, 4 + System.Length(LQuaPnts));

  Result[0] := MakeOSnapPoint(Self, OSNP_END, GetEllipsePoint(LEll, FStartAngle), FStartAngle);
  Result[1] := MakeOSnapPoint(Self, OSNP_MID, GetEllipsePoint(LEll, LMidAng), LMidAng);
  Result[2] := MakeOSnapPoint(Self, OSNP_END, GetEllipsePoint(LEll, FEndAngle), FEndAngle);
  Result[3] := MakeOSnapPoint(Self, OSNP_CEN, FCenter, -1);

  //-------- Quadrant point --------
  if System.Length(LQuaPnts) > 0 then
  begin
    for I := 0 to System.Length(LQuaPnts) - 1 do
      Result[4 + I] := MakeOSnapPoint(Self, OSNP_QUA, LQuaPnts[I], -1{UdGeo2D.GetAngle(FCenter, LQuaPnts[I])} );
  end;
end;







//------------------------------------------------------------------------------------------

function TUdEllipse.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  LAng, LRad: Float;
begin
  Result := False;
  case AGripPnt.Mode of
    gmCenter: Result := Self.Move(FCenter, AGripPnt.Point);

    gmSize:
      begin
        LRad := Distance(AGripPnt.Point, FCenter);

        if AGripPnt.Index in [1, 2] then
        begin
          if Sign(LRad) <> Sign(FMajorRadius) then LRad := -LRad;
          Self.MajorRadius := LRad;
        end
        else if AGripPnt.Index in [3, 4] then
        begin
          if Sign(LRad) <> Sign(FMinorRadius) then LRad := -LRad;
          Self.MinorRadius := LRad;
        end;

        Result := True;
      end;

    gmAngle:
      begin
        LAng := GetAngle(FCenter, AGripPnt.Point) - FRotation;
        LAng := CenAngToEllAng(FMajorRadius, FMinorRadius, LAng);

        if AGripPnt.Index = 1 then SetAngle(0, LAng) else
        if AGripPnt.Index = 2 then SetAngle(1, LAng) ;

        Result := True;
      end;
  end;
end;



function TUdEllipse.Pick(APoint: TPoint2D): Boolean;
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

  D := UdGeo2D.Distance(FCenter, APoint);
  Result := (D < E);

  if (FPenWidth > 0.0) then
  begin
    A := UdGeo2D.GetAngle(FCenter, APoint);
    if (A < 0.0) or not IsInAngles(A, FStartAngle, FEndAngle, _Epsilon*100) then Exit;   //---->>>>

    D := UdGeo2D.DistanceToEllipse(FCenter, Self.GetXData());
    Result := (D < FPenWidth/2) or IsEqual(D, FPenWidth/2, E);
  end
  else
    Result := UdGeo2D.IsPntOnEllipse(APoint, Self.GetXData(), E);

  if not Result and Self.CanFilled() and FFilled then
    Result := UdGeo2D.IsPntInEllipse(APoint, Self.GetXData(), E);

end;

function TUdEllipse.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
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

function TUdEllipse.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter := UdGeo2D.Translate(Dx, Dy, FCenter);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdEllipse.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LTheEll, LNewEll: TEllipse2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LTheEll := UdGeo2D.Ellipse2D(FCenter, FMajorRadius, FMinorRadius, FStartAngle, FEndAngle, FRotation);
  LNewEll := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LTheEll);

  FMajorRadius := LNewEll.Rx;
  FMinorRadius := LNewEll.Ry;
  FCenter      := LNewEll.Cen;
  FStartAngle  := LNewEll.Ang1;
  FEndAngle    := LNewEll.Ang2;
  FRotation    := LNewEll.Rot;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdEllipse.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
var
  LNewEll: TEllipse2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ADis, 0.0)) then Exit; //======>>>>

  LNewEll := UdGeo2D.OffsetEllipse(Self.GetXData(), ADis, ASidePnt);
  if (LNewEll.Rx <= 0.0) and (LNewEll.Ry <= 0.0) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FMajorRadius := LNewEll.Rx;
  FMinorRadius := LNewEll.Ry;
  FCenter      := LNewEll.Cen;
  FStartAngle  := LNewEll.Ang1;
  FEndAngle    := LNewEll.Ang2;
  FRotation    := LNewEll.Rot;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdEllipse.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
var
  LNewEll: TEllipse2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LNewEll := UdGeo2D.Rotate(ABase, ARota, UdGeo2D.Ellipse2D(FCenter, FMajorRadius  , FMinorRadius, FStartAngle, FEndAngle, FRotation));

  FMajorRadius    := LNewEll.Rx;
  FMinorRadius    := LNewEll.Ry;
  FCenter         := LNewEll.Cen;
  FStartAngle     := LNewEll.Ang1;
  FEndAngle       := LNewEll.Ang2;
  FRotation       := LNewEll.Rot;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdEllipse.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
var
  LNewEll: TEllipse2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LNewEll := UdGeo2D.Scale(ABase, AFactor, AFactor, UdGeo2D.Ellipse2D(FCenter, FMajorRadius , FMinorRadius, FStartAngle, FEndAngle, FRotation));

  FMajorRadius    := LNewEll.Rx;
  FMinorRadius    := LNewEll.Ry;
  FCenter         := LNewEll.Cen;
  FStartAngle     := LNewEll.Ang1;
  FEndAngle       := LNewEll.Ang2;
  FRotation       := LNewEll.Rot;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdEllipse.Extend(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): Boolean;
var
  I, J: Integer;
  LAng: Float;
  LEll: TEllipse2D;
  LIsP1: Boolean;
  LP1, LP2, LPnt: TPoint2D;
  LInctPnts: TPoint2DArray;
  LPointList: TPoint2DList;
begin
  Result := False;
  if IsEqual(FStartAngle, FEndAngle) or Self.Closed() then Exit; //=======>>>>

  LEll := Self.GetXData();
  LEll.Ang1 := 0.0;
  LEll.Ang2 := 360.0;

  LInctPnts := nil;

  LPointList := TPoint2DList.Create(MAXBYTE);
  try
    for I := 0 to System.Length(ASelectedEntities) - 1 do
    begin
      if Assigned(ASelectedEntities[I]) and (ASelectedEntities[I] <> Self) then
      begin
        LInctPnts := UdUtils.EntitiesIntersection(LEll, ASelectedEntities[I]);
        for J := 0 to System.Length(LInctPnts) - 1 do LPointList.Add(LInctPnts[J]);
      end;
    end;

    for I := LPointList.Count - 1 downto 0 do
    begin
      LAng := UdGeo2D.GetAngle(FCenter, LPointList.GetPoint(I));
      LAng := CenAngToEllAng(FMajorRadius  , FMinorRadius, LAng);

      if (LAng < 0) or IsInAngles(LAng, FStartAngle, FEndAngle) then
        LPointList.RemoveAt(I);
    end;

    LInctPnts := LPointList.ToArray();
  finally
    LPointList.Free;
  end;

  if System.Length(LInctPnts) <= 0 then Exit;  //=======>>>>>>


  Self.RaiseBeforeModifyObject('');


  LP1 := UdGeo2D.GetEllipsePoint(FCenter, FMajorRadius  , FMinorRadius, FRotation, FStartAngle);
  LP2 := UdGeo2D.GetEllipsePoint(FCenter, FMajorRadius  , FMinorRadius, FRotation, FEndAngle);

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
  LAng := FixAngle(UdGeo2D.GetAngle(FCenter, LPnt) - FRotation);
  LAng := CenAngToEllAng(FMajorRadius  , FMinorRadius, LAng);

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




function TUdEllipse.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEll: TEllipse2D;
  LEntity: TUdEllipse;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdEllipse.Create({Self.Document, False});

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);
    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      LEll := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.GetXData());
      LEntity.XData := LEll;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;

function TUdEllipse.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  I: Integer;
  LEllObj: TUdEllipse;
  LElls: TEllipse2DArray;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>


  LElls := UdGeo2D.BreakAt( UdGeo2D.Ellipse2D(FCenter, FMajorRadius  , FMinorRadius, FStartAngle, FEndAngle, FRotation) ,  APnt1, APnt2);

  System.SetLength(Result, System.Length(LElls));
  for I := 0 to System.Length(LElls) - 1 do
  begin
    LEllObj := TUdEllipse(Self.Clone());
    LEllObj.SetXData(LElls[I]);

    Result[I] := LEllObj;
  end;
end;

function TUdEllipse.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;
var
  I: Integer;
  LEll: TEllipse2D;
  LPnt: TPoint2D;
  LDis: Float;
  LAng1, LAng2: Float;
  LFound: Boolean;
  LP1, LP2: TPoint2D;
  LInctPnts: TPoint2DArray;
begin
  Result := nil;

  LInctPnts := UdUtils.EntitiesIntersection(Self, ASelectedEntities);
  if System.Length(LInctPnts) <= 0 then Exit; //======>>>>


  LEll := Self.GetXData();
  LEll.IsCW := False; //Important!!!

  LPnt := ClosestEllipsePoint(APnt, LEll);
  LAng1 := CenAngToEllAng(FMajorRadius  , FMinorRadius, GetAngle(FCenter, LPnt) - FRotation);
  LDis := FixAngle(LAng1 - FStartAngle);

  LFound := False;

  UdGeo2D.SortPoints(LInctPnts, LEll);

  for I := 0 to System.Length(LInctPnts) - 1 do
  begin
    LAng2 := CenAngToEllAng(FMajorRadius  , FMinorRadius, GetAngle(FCenter, LInctPnts[I]) - FRotation );
    if FixAngle(LAng2 - FStartAngle) > LDis then
    begin
      LFound := True;
      if I > 0 then
        LP1 := LInctPnts[I-1]
      else
        LP1 := GetEllipsePoint(LEll, FStartAngle);

      LP2 := LInctPnts[I];
      Break;
    end;
  end;

  if not LFound then
  begin
    LP1 := LInctPnts[High(LInctPnts)];
    LP2 := GetEllipsePoint(LEll, FEndAngle);
  end;

  Result := Self.BreakAt(LP1, LP2);
end;





function TUdEllipse.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  if not Self.IsVisible or Self.IsLock() then Exit;
  if not AOther.IsVisible or AOther.IsLock() then Exit;

  Result := UdUtils.EntitiesIntersection(Self.GetXData(), AOther);
end;

function TUdEllipse.Perpend(APnt: TPoint2D): TPoint2DArray;
//var
//  LLn: TLine2D;
begin
  Result := nil;
//  LLn := UdGeo2D.Line2D(APnt, FCenter);
//  Result := UdGeo2D.Intersection(LLn, Self.GetXData());
end;



// ---------------------------------------------------------

procedure TUdEllipse.SaveToStream(AStream: TStream);
begin
  inherited;

  FloatToStream(AStream, FCenter.X);
  FloatToStream(AStream, FCenter.Y);

  FloatToStream(AStream, FMajorRadius  );
  FloatToStream(AStream, FMinorRadius);

  FloatToStream(AStream, FStartAngle);
  FloatToStream(AStream, FEndAngle);

  FloatToStream(AStream, FRotation);
end;


procedure TUdEllipse.LoadFromStream(AStream: TStream);
begin
  inherited;

  FCenter.X := FloatFromStream(AStream);
  FCenter.Y := FloatFromStream(AStream);

  FMajorRadius  := FloatFromStream(AStream);
  FMinorRadius  := FloatFromStream(AStream);

  FStartAngle := FloatFromStream(AStream);
  FEndAngle   := FloatFromStream(AStream);

  FRotation   := FloatFromStream(AStream);

  Update();
end;


procedure TUdEllipse.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['MajorRadius']  := FloatToStr(FMajorRadius);
  LXmlNode.Prop['MinorRadius']  := FloatToStr(FMinorRadius);
  LXmlNode.Prop['Center']       := Point2DToStr(FCenter);

  LXmlNode.Prop['StartAngle'] := FloatToStr(FStartAngle);
  LXmlNode.Prop['EndAngle']   := FloatToStr(FEndAngle);
  LXmlNode.Prop['ArcKind']    := IntToStr(Ord(FArcKind));

  LXmlNode.Prop['Rotation']  := FloatToStr(FRotation);
end;

procedure TUdEllipse.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FMajorRadius := StrToFloatDef(LXmlNode.Prop['MajorRadius'], 0);
  FMinorRadius := StrToFloatDef(LXmlNode.Prop['MinorRadius'], 0);
  FCenter      := StrToPoint2D(LXmlNode.Prop['Center']);

  FStartAngle := StrToFloatDef(LXmlNode.Prop['StartAngle'], 0);
  FEndAngle   := StrToFloatDef(LXmlNode.Prop['EndAngle'], 0);
  FArcKind    := TUdArcKind(StrToIntDef(LXmlNode.Prop['ArcKind'], 0));

  FRotation   := StrToFloatDef(LXmlNode.Prop['Rotation'], 0);

  Update();
end;



end.