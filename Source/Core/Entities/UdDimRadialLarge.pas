                                                                                 {
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimRadialLarge;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes, UdConsts, UdObject, UdAxes, UdEntity,
  UdColor, UdDimProps, UdDimension;


type
  //*** TUdDimRadialLarge ***//
  TUdDimRadialLarge = class(TUdDimension)
  protected
    FCenter     : TPoint2D;
    FChordPoint : TPoint2D;

    FOverrideCenter: TPoint2D;
    FJogPoint      : TPoint2D;
    FJogAngle      : Float;

    FTextPoint   : TPoint2D;
    FGripJogPoint: TPoint2D;

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; override;

    procedure SetTextPoint(const AValue: TPoint2D); override;

    procedure SetCenter(const AValue: TPoint2D);
    procedure SetChordPoint(const AValue: TPoint2D);
    procedure SetOverrideCenter(const AValue: TPoint2D);
    procedure SetJogPoint(const AValue: TPoint2D);
    procedure SetJogAngle(const AValue: Float);

    function GetCenterValue(AIndex: Integer): Float;
    procedure SetCenterValue(AIndex: Integer; const AValue: Float);

    function GetChordPointValue(AIndex: Integer): Float;
    procedure SetChordPointValue(AIndex: Integer; const AValue: Float);

    function GetJogPointValue(AIndex: Integer): Float;
    procedure SetJogPointValue(AIndex: Integer; const AValue: Float);

    function GetOverrideCenterValue(AIndex: Integer): Float;
    procedure SetOverrideCenterValue(AIndex: Integer; const AValue: Float);

    function UpdateDim(AAxes: TUdAxes): Boolean; override;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetGripPoints(): TUdGripPointArray; override;

    {operation...}
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;

    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;

    function Intersect(AOther: TUdEntity): TPoint2DArray; override;
    function Perpend(APnt: TPoint2D): TPoint2DArray; override;


    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Center     : TPoint2D read FCenter     write SetCenter    ;
    property ChordPoint : TPoint2D read FChordPoint write SetChordPoint;

    property OverrideCenter: TPoint2D read FOverrideCenter write SetOverrideCenter;
    property JogPoint      : TPoint2D read FJogPoint       write SetJogPoint      ;

    property TextPoint   : TPoint2D read FTextPoint;
    property GripJogPoint: TPoint2D read FGripJogPoint;

  published
    property CenterX         : Float index 0 read GetCenterValue     write SetCenterValue;
    property CenterY         : Float index 1 read GetCenterValue     write SetCenterValue;

    property ChordPointX     : Float index 0 read GetChordPointValue write SetChordPointValue;
    property ChordPointY     : Float index 1 read GetChordPointValue write SetChordPointValue;

    property OverrideCenterX : Float index 0 read GetOverrideCenterValue write SetOverrideCenterValue;
    property OverrideCenterY : Float index 1 read GetOverrideCenterValue write SetOverrideCenterValue;

    property JogPointX       : Float index 0 read GetJogPointValue       write SetJogPointValue;
    property JogPointY       : Float index 1 read GetJogPointValue       write SetJogPointValue;

    property JogAngle        : Float  read FJogAngle write SetJogAngle;

  end;


implementation


uses
  SysUtils, UdText,
  UdMath, UdGeo2D, UdStreams, UdXml, UdUtils, UdStrConverter;



//=================================================================================================
{ TUdDimRadialLarge }

constructor TUdDimRadialLarge.Create();
begin
  inherited;

  FCenter     := Point2D(0, 0);
  FChordPoint := Point2D(0, 0);

  FOverrideCenter := Point2D(0, 0);
  FJogPoint       := Point2D(0, 0);
  FJogAngle       := 90;

  FTextPoint     := UdMath.InvalidPoint();
  FGripJogPoint  := UdMath.InvalidPoint();
end;

destructor TUdDimRadialLarge.Destroy;
begin

  inherited;
end;

function TUdDimRadialLarge.GetTypeID: Integer;
begin
  Result := ID_DIMRADIALLARGE;
end;


function TUdDimRadialLarge.GetDimTypeID: Integer;
begin
  Result := 9;
end;



//--------------------------------------------------------------------------------------------


procedure TUdDimRadialLarge.SetTextPoint(const AValue: TPoint2D);
var
  LGripPnt: TUdGripPoint;
begin
  LGripPnt.Mode := gmPoint;
  LGripPnt.Index := 4;
  LGripPnt.Point := AValue;
  Self.MoveGrip(LGripPnt);
end;


procedure TUdDimRadialLarge.SetCenter(const AValue: TPoint2D);
begin
  if NotEqual(FCenter, AValue) and Self.RaiseBeforeModifyObject('Center') then
  begin
    FCenter := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Center');
  end;
end;

procedure TUdDimRadialLarge.SetChordPoint(const AValue: TPoint2D);
begin
  if NotEqual(FChordPoint, AValue) and Self.RaiseBeforeModifyObject('ChordPoint') then
  begin
    FChordPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ChordPoint');
  end;
end;

procedure TUdDimRadialLarge.SetOverrideCenter(const AValue: TPoint2D);
begin
  if NotEqual(FOverrideCenter, AValue) and Self.RaiseBeforeModifyObject('OverrideCenter') then
  begin
    FOverrideCenter := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('OverrideCenter');
  end;
end;

procedure TUdDimRadialLarge.SetJogPoint(const AValue: TPoint2D);
begin
  if NotEqual(FJogPoint, AValue) and Self.RaiseBeforeModifyObject('JogPoint') then
  begin
    FJogPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('JogPoint');
  end;
end;

procedure TUdDimRadialLarge.SetJogAngle(const AValue: Float);
begin
  if NotEqual(FJogAngle, AValue) and Self.RaiseBeforeModifyObject('JogAngle') then
  begin
    FJogAngle := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('JogAngle');
  end;
end;









function TUdDimRadialLarge.GetCenterValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FCenter.X;
    1: Result := FCenter.Y;
  end;
end;

procedure TUdDimRadialLarge.SetCenterValue(AIndex: Integer; const AValue: Float);
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



function TUdDimRadialLarge.GetChordPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FChordPoint.X;
    1: Result := FChordPoint.Y;
  end;
end;


procedure TUdDimRadialLarge.SetChordPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FChordPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FChordPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('ChordPointX');
    1: Self.RaiseBeforeModifyObject('ChordPointY');
  end;

  FChordPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('ChordPointX');
    1: Self.RaiseAfterModifyObject('ChordPointY');
  end;
end;




function TUdDimRadialLarge.GetJogPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FJogPoint.X;
    1: Result := FJogPoint.Y;
  end;
end;

procedure TUdDimRadialLarge.SetJogPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FJogPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FJogPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('JogPointX');
    1: Self.RaiseBeforeModifyObject('JogPointY');
  end;

  FJogPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('JogPointX');
    1: Self.RaiseAfterModifyObject('JogPointY');
  end;
end;




function TUdDimRadialLarge.GetOverrideCenterValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FOverrideCenter.X;
    1: Result := FOverrideCenter.Y;
  end;
end;

procedure TUdDimRadialLarge.SetOverrideCenterValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FOverrideCenter;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FOverrideCenter) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('OverrideCenterX');
    1: Self.RaiseBeforeModifyObject('OverrideCenterY');
  end;

  FOverrideCenter := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('OverrideCenterX');
    1: Self.RaiseAfterModifyObject('OverrideCenterY');
  end;
end;








procedure TUdDimRadialLarge.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDimRadialLarge) then Exit;

  FCenter         := TUdDimRadialLarge(AValue).FCenter;
  FChordPoint     := TUdDimRadialLarge(AValue).FChordPoint;
  FOverrideCenter := TUdDimRadialLarge(AValue).FOverrideCenter;
  FJogPoint       := TUdDimRadialLarge(AValue).FJogPoint      ;
  FJogAngle       := TUdDimRadialLarge(AValue).FJogAngle      ;

  Self.Update();
end;





//----------------------------------------------------------------------------------------

function TUdDimRadialLarge.UpdateDim(AAxes: TUdAxes): Boolean;
var
  I: Integer;
  LLineEnt: TUdEntity;
  LTextPnt: TPoint2D;
  LTextEnt: TUdText;
  LTextWidth: Float;
  LInctBound: Boolean;
  LAngle, LRadius: Float;
  LInctPnts: TPoint2DArray;
  LRadPnt, LOvrPnt, LPnt: TPoint2D;
  LRadLn, LJogLn, LOvrLn: TLineK;
  LOverallScale: Float;
  LDimEntities: TUdEntityArray;
begin
  Result := False;
  ClearObjectList(FEntityList);

  LPnt := UdGeo2D.ClosestSegmentPoint(FJogPoint, Segment2D(FChordPoint, FOverrideCenter), I);
  if (I <> 0) or IsEqual(LPnt, FChordPoint) or IsEqual(LPnt, FOverrideCenter) then
    FJogPoint := MidPoint(FChordPoint, FOverrideCenter);


  LRadius := Distance(FCenter, FChordPoint);
  FMeasurement := LRadius;

  LAngle := GetAngle(FCenter, FChordPoint);

  LRadLn := LineK(FCenter, LAngle);
  LOvrLn := LineK(FOverrideCenter, LAngle);

  if UdGeo2D.IsPntOnLeftSide(FJogPoint, FCenter, FChordPoint) then
    LJogLn := LineK(FJogPoint, LAngle + FJogAngle)
  else
    LJogLn := LineK(FJogPoint, LAngle - FJogAngle);

  LInctPnts := UdGeo2D.Intersection(LRadLn, LJogLn);
  if System.Length(LInctPnts) <= 0 then Exit;

  LRadPnt := LInctPnts[0];


  LInctPnts := UdGeo2D.Intersection(LOvrLn, LJogLn);
  if System.Length(LInctPnts) <= 0 then Exit;

  LOvrPnt := LInctPnts[0];
  LLineEnt := Self.CreateDimLine(FOverrideCenter, LOvrPnt, False);
  FEntityList.Add(LLineEnt);

  LLineEnt := Self.CreateDimLine(LRadPnt, LOvrPnt, False);
  FEntityList.Add(LLineEnt);




  LOverallScale := 1.0;
  if Assigned(FDimStyle) then LOverallScale := FDimStyle.OverallScale;

  //----------------------------------------------------

  LTextEnt := TUdText.Create(Self.Document, False);

  LTextEnt.BeginUpdate();
  try    
    LTextEnt.Owner := Self;

    LTextEnt.Alignment := taMiddleCenter;
    if Assigned(Self.TextStyles) then
      LTextEnt.TextStyle := Self.TextStyles.GetItem(FTextProp.TextStyle);
    LTextEnt.Height    := FTextProp.TextHeight * LOverallScale;
    LTextEnt.Color.Assign(FTextProp.TextColor);
    LTextEnt.DrawFrame := FTextProp.DrawFrame;
    LTextEnt.FillColor := FTextProp.FillColor;

    LTextEnt.Contents := GetDimText(FMeasurement, dtkRaidus);
  finally
    LTextEnt.EndUpdate();
  end;

  LTextWidth := LTextEnt.TextWidth + (FTextProp.TextHeight * TEXT_BOUND_OFFSET_FACTOR) * 2;
  FEntityList.Add(LTextEnt);


  //----------------------------------------------------

  if UdMath.IsValidPoint(FTextPoint) then
  begin
    LPnt := UdGeo2D.ClosestSegmentPoint(FTextPoint, Segment2D(FChordPoint, FOverrideCenter), I);
    if (I <> 0) or IsEqual(LPnt, FChordPoint) or IsEqual(LPnt, FOverrideCenter) then
      FTextPoint := MidPoint(FChordPoint, FOverrideCenter);

    LTextPnt := UdGeo2D.ClosestLinePoint(FTextPoint, LRadLn);
  end
  else
    LTextPnt := ShiftPoint(LRadPnt, LAngle, (LTextWidth/2) + DIM_TEXT_SIDE_OFFSET);


  if FTextAngle >= 0.0 then
  begin
    LTextEnt.Position := LTextPnt;
    LTextEnt.Rotation := FTextAngle;
    LInctBound := True;
  end
  else
    UpdateOutsideTextPosition(LTextEnt, LTextPnt, LAngle, True, LInctBound);


  if FTextProp.OutsideAlign and (FTextProp.VerticalPosition = vtpAbove) then
  begin
    LDimEntities := Self.CreateDimLineWithArrow(FChordPoint, LRadPnt,  TUdArrowStyle(FArrowsProp.ArrowLeader), asNone);
    for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);
  end
  else begin
    LInctPnts := UdGeo2D.Intersection(Segment2D(LRadPnt, FChordPoint), LTextEnt.TextBound);
    UdGeo2D.SortPoints(LInctPnts, LRadPnt);

    if System.Length(LInctPnts) > 1 then
    begin
      LPnt := LInctPnts[0];
      if Distance(LRadPnt, LPnt) <= DIM_TEXT_SIDE_OFFSET then
        LPnt := ShiftPoint(LRadPnt, LAngle, DIM_TEXT_SIDE_OFFSET);

      LLineEnt := Self.CreateDimLine(LRadPnt, LPnt,  False);
      FEntityList.Add(LLineEnt);

      LPnt := LInctPnts[High(LInctPnts)];
      if Distance(FChordPoint, LPnt) <= (FArrowsProp.ArrowSize +DIM_TEXT_SIDE_OFFSET)  then
        LPnt := ShiftPoint(FChordPoint, FixAngle(LAngle + 180), (FArrowsProp.ArrowSize +DIM_TEXT_SIDE_OFFSET));

      LDimEntities := Self.CreateDimLineWithArrow(FChordPoint, LPnt,  TUdArrowStyle(FArrowsProp.ArrowLeader), asNone);
      for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);
    end
    else begin
      LDimEntities := Self.CreateDimLineWithArrow(FChordPoint, LRadPnt,  TUdArrowStyle(FArrowsProp.ArrowLeader), asNone);
      for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);
    end;
  end;



  //------------------------------------------------------

  FGripTextPnt := LTextPnt;
  FGripJogPoint := MidPoint(LRadPnt, LOvrPnt);

  Result := True;
end;


//----------------------------------------------------------------------------------------

function TUdDimRadialLarge.GetGripPoints: TUdGripPointArray;
begin
  System.SetLength(Result, 5);

  Result[0] := MakeGripPoint(Self, gmPoint, 0, FCenter , 0);
  Result[1] := MakeGripPoint(Self, gmPoint, 1, FGripJogPoint, 0);
  Result[2] := MakeGripPoint(Self, gmPoint, 2, FOverrideCenter, 0);

  Result[3] := MakeGripPoint(Self, gmPoint, 3, FGripTextPnt, 0);
  Result[4] := MakeGripPoint(Self, gmPoint, 4, FChordPoint, 0);
end;

function TUdDimRadialLarge.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  LPnt: TPoint2D;
  LRad, LAng: Float;
  LFactor, LDis: Float;
  LRadLn, LOvrLn: TLineK;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    LFactor := 0;

    if AGripPnt.Index in [2, 3, 4] then
    begin
      LAng := GetAngle(FCenter, FChordPoint);

      LRadLn := LineK(FCenter, LAng);
      LOvrLn := LineK(FOverrideCenter, LAng);

      LFactor := Distance(FOverrideCenter, ClosestLinePoint(FJogPoint, LOvrLn)) /
                 Distance(FChordPoint, ClosestLinePoint(FJogPoint, LRadLn));
    end;

    case AGripPnt.Index of
      0:
        begin
          Result := Self.Move(FCenter, AGripPnt.Point);
        end;
      1:
        begin
          LAng := GetAngle(FCenter, FChordPoint);
          LOvrLn := LineK(FOverrideCenter, LAng);

          Self.SetJogPoint(ClosestLinePoint(AGripPnt.Point, LOvrLn));
          Result := True;
        end;

      2:
        begin
          Self.RaiseBeforeModifyObject('');
          FOverrideCenter := AGripPnt.Point;
          Self.RaiseAfterModifyObject('');
        end;

      3:
        begin
          Self.RaiseBeforeModifyObject('');

          FTextPoint := AGripPnt.Point;

          LAng := GetAngle(FCenter, AGripPnt.Point);
          LRad := Distance(FCenter, FChordPoint);
          FChordPoint := ShiftPoint(FCenter, LAng, LRad);

          Self.RaiseAfterModifyObject('');
        end;

      4:
        begin
          Self.RaiseBeforeModifyObject('');

          LAng := GetAngle(FCenter, AGripPnt.Point);
          LRad := Distance(FCenter, FChordPoint);
          FChordPoint := ShiftPoint(FCenter, LAng, LRad);

          Self.RaiseAfterModifyObject('');
        end;
    end;

    if AGripPnt.Index in [2, 3, 4] then
    begin
      if IsEqual(LFactor, 0.0) then Self.Update()
      else begin
        LAng := GetAngle(FCenter, FChordPoint);

        LRadLn := LineK(FCenter, LAng);
        LPnt := ClosestLinePoint(FOverrideCenter, LRadLn);

        LDis := (LFactor / (LFactor + 1)) * Distance(LPnt, FChordPoint);
        LPnt := ShiftPoint(FOverrideCenter, LAng, LDis);

        FJogPoint := LPnt;

        Self.Update();
      end;
    end;
  end;
end;




//----------------------------------------------------------------------------------------

function TUdDimRadialLarge.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter     := UdGeo2D.Translate(Dx, Dy, FCenter);
  FChordPoint := UdGeo2D.Translate(Dx, Dy, FChordPoint);

  FOverrideCenter := UdGeo2D.Translate(Dx, Dy, FOverrideCenter);
  FJogPoint       := UdGeo2D.Translate(Dx, Dy, FJogPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimRadialLarge.Mirror(APnt1, APnt2: TPoint2D): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter     := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FCenter);
  FChordPoint := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FChordPoint);

  FOverrideCenter := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FOverrideCenter);
  FJogPoint       := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FJogPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimRadialLarge.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter     := UdGeo2D.Rotate(ABase, ARota, FCenter);
  FChordPoint := UdGeo2D.Rotate(ABase, ARota, FChordPoint);

  FOverrideCenter := UdGeo2D.Rotate(ABase, ARota, FOverrideCenter);
  FJogPoint       := UdGeo2D.Rotate(ABase, ARota, FJogPoint);

//  FLeaderLen := FLeaderLen * ARota;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimRadialLarge.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter     := UdGeo2D.Scale(ABase, AFactor, AFactor, FCenter);
  FChordPoint := UdGeo2D.Scale(ABase, AFactor, AFactor, FChordPoint);

  FOverrideCenter := UdGeo2D.Scale(ABase, AFactor, AFactor, FOverrideCenter);
  FJogPoint       := UdGeo2D.Scale(ABase, AFactor, AFactor, FJogPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdDimRadialLarge.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdDimRadialLarge;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdDimRadialLarge.Create(Self.Document, False);

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      with LEntity do
      begin
        FCenter     := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FCenter);
        FChordPoint := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FChordPoint);

        FOverrideCenter := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FOverrideCenter);
        FJogPoint       := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FJogPoint);
      end;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;



function TUdDimRadialLarge.Intersect(AOther: TUdEntity): TPoint2DArray;
var
  I: Integer;
  LEntArray: TUdEntityArray;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  if not Self.IsVisible or Self.IsLock() then Exit;
  if not AOther.IsVisible or AOther.IsLock() then Exit;

  System.SetLength(LEntArray, FEntityList.Count);
  for I := 0 to FEntityList.Count - 1 do
    LEntArray[I] := TUdEntity(FEntityList[I]);

  Result := UdUtils.EntitiesIntersection(AOther, LEntArray);
end;

function TUdDimRadialLarge.Perpend(APnt: TPoint2D): TPoint2DArray;
//var
//  LLn: TLine2D;
//  LPnt: TPoint2D;
begin
  Result := nil;
//
//  LLn := UdGeo2D.Line2D(FP1, FP2);
//
//  LPnt := UdGeo2D.ClosestLinePoint(APnt, LLn);
//  if UdGeo2D.IsPntOnSegment(LPnt, Segment2D(FP1, FP2)) then
//  begin
//    System.SetLength(Result, 1);
//    Result[0] := LPnt;
//  end;
end;





//----------------------------------------------------------------------------------------

procedure TUdDimRadialLarge.SaveToStream(AStream: TStream);
begin
  inherited;

  Point2DToStream(AStream, FCenter    );
  Point2DToStream(AStream, FChordPoint);
  Point2DToStream(AStream, FOverrideCenter);
  Point2DToStream(AStream, FJogPoint      );
  FloatToStream(AStream,   FJogAngle      );
end;

procedure TUdDimRadialLarge.LoadFromStream(AStream: TStream);
begin
  inherited;

  FCenter         := Point2DFromStream(AStream);
  FChordPoint     := Point2DFromStream(AStream);
  FOverrideCenter := Point2DFromStream(AStream);
  FJogPoint       := Point2DFromStream(AStream);
  FJogAngle       := FloatFromStream(AStream);

  Self.Update();
end;



procedure TUdDimRadialLarge.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Center']         := Point2DToStr(FCenter        );
  LXmlNode.Prop['ChordPoint']     := Point2DToStr(FChordPoint    );
  LXmlNode.Prop['OverrideCenter'] := Point2DToStr(FOverrideCenter);
  LXmlNode.Prop['JogPoint']       := Point2DToStr(FJogPoint      );
  LXmlNode.Prop['JogAngle']       := FloatToStr(FJogAngle      );
end;

procedure TUdDimRadialLarge.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FCenter         := StrToPoint2D(LXmlNode.Prop['Center']         );
  FChordPoint     := StrToPoint2D(LXmlNode.Prop['ChordPoint']     );
  FOverrideCenter := StrToPoint2D(LXmlNode.Prop['OverrideCenter'] );
  FJogPoint       := StrToPoint2D(LXmlNode.Prop['JogPoint']       );
  FJogAngle       := StrToFloatDef(LXmlNode.Prop['JogAngle'], 90  );

  Self.Update();
end;




end.