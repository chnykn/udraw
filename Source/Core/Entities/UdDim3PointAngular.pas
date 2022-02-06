{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDim3PointAngular;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes, UdConsts, UdObject, UdAxes, UdEntity,
  UdColor, UdDimProps, UdDimension;


type
  //*** TUdDim3PointAngular ***//
  TUdDim3PointAngular = class(TUdDimension, IUdDimLineSupport)
  protected
    FCenterPoint   : TPoint2D;
    FExtLine1Point : TPoint2D;
    FExtLine2Point : TPoint2D;

    FArcPoint      : TPoint2D;
    FTextPoint     : TPoint2D;

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; override;

    procedure SetCenterPoint(const AValue: TPoint2D);
    procedure SetExtLine1Point(const AValue: TPoint2D);
    procedure SetExtLine2Point(const AValue: TPoint2D);

    procedure SetArcPoint(const AValue: TPoint2D);
    procedure SetTextPoint(const AValue: TPoint2D);  override;


    function GetCenterPointValue(AIndex: Integer): Float;
    procedure SetCenterPointValue(AIndex: Integer; const AValue: Float);

    function GetExtLine1PointValue(AIndex: Integer): Float;
    procedure SetExtLine1PointValue(AIndex: Integer; const AValue: Float);

    function GetExtLine2PointValue(AIndex: Integer): Float;
    procedure SetExtLine2PointValue(AIndex: Integer; const AValue: Float);

    function GetArcPointValue(AIndex: Integer): Float;
    procedure SetArcPointValue(AIndex: Integer; const AValue: Float);

    function GetTextPointValue(AIndex: Integer): Float;
    procedure SetTextPointValue(AIndex: Integer; const AValue: Float);



    function UpdateDim(AAxes: TUdAxes): Boolean; override;

    {IUdDimLineSupport ...}
    function GetDimLine1Point(): TPoint2D;
    function GetDimLine2Point(): TPoint2D;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetDimArc(): TArc2D;
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
    property DimLine1Point: TPoint2D read GetDimLine1Point;
    property DimLine2Point: TPoint2D read GetDimLine2Point;

    property CenterPoint   : TPoint2D read FCenterPoint   write SetCenterPoint   ;
    property ExtLine1Point : TPoint2D read FExtLine1Point write SetExtLine1Point  ;
    property ExtLine2Point : TPoint2D read FExtLine2Point write SetExtLine2Point  ;

    property ArcPoint  : TPoint2D read FArcPoint       write SetArcPoint  ;
    property TextPoint : TPoint2D read FTextPoint      write SetTextPoint ;


  published
    property CenterPointX   : Float index 0 read GetCenterPointValue   write SetCenterPointValue  ;
    property CenterPointY   : Float index 1 read GetCenterPointValue   write SetCenterPointValue  ;

    property ExtLine1PointX : Float index 0 read GetExtLine1PointValue write SetExtLine1PointValue;
    property ExtLine1PointY : Float index 1 read GetExtLine1PointValue write SetExtLine1PointValue;

    property ExtLine2PointX : Float index 0 read GetExtLine2PointValue write SetExtLine2PointValue;
    property ExtLine2PointY : Float index 1 read GetExtLine2PointValue write SetExtLine2PointValue;


    property ArcPointX      : Float index 0 read GetArcPointValue   write SetArcPointValue ;
    property ArcPointY      : Float index 1 read GetArcPointValue   write SetArcPointValue ;

    property TextPointX     : Float index 0 read GetTextPointValue  write SetTextPointValue;
    property TextPointY     : Float index 1 read GetTextPointValue  write SetTextPointValue;

  end;


implementation



uses
  SysUtils, UdText, UdDimArcLength,
  UdMath, UdGeo2D, UdStreams, UdXml, UdUtils, UdStrConverter;



//=================================================================================================
{ TUdDim3PointAngular }

constructor TUdDim3PointAngular.Create();
begin
  inherited;

  FCenterPoint   := Point2D(0, 0);
  FExtLine1Point := Point2D(0, 0);
  FExtLine2Point := Point2D(0, 0);

  FArcPoint      := Point2D(0, 0);
  FTextPoint     := Point2D(0, 0);
end;

destructor TUdDim3PointAngular.Destroy;
begin

  inherited;
end;

function TUdDim3PointAngular.GetTypeID: Integer;
begin
  Result := ID_DIM3PANGULAR;
end;

function TUdDim3PointAngular.GetDimTypeID: Integer;
begin
  Result := 5;
end;



//----------------------------------------------------------------------------------------

procedure TUdDim3PointAngular.SetCenterPoint(const AValue: TPoint2D);
begin
  if NotEqual(FCenterPoint, AValue) and Self.RaiseBeforeModifyObject('CenterPoint') then
  begin
    FCenterPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('CenterPoint');
  end;
end;

procedure TUdDim3PointAngular.SetExtLine1Point(const AValue: TPoint2D);
begin
  if NotEqual(FExtLine1Point, AValue) and Self.RaiseBeforeModifyObject('ExtLine1Point') then
  begin
    FExtLine1Point := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLine1Point');
  end;
end;

procedure TUdDim3PointAngular.SetExtLine2Point(const AValue: TPoint2D);
begin
  if NotEqual(FExtLine2Point, AValue) and Self.RaiseBeforeModifyObject('ExtLine2Point') then
  begin
    FExtLine2Point := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLine2Point');
  end;
end;



procedure TUdDim3PointAngular.SetArcPoint(const AValue: TPoint2D);
begin
  if NotEqual(FArcPoint, AValue) and Self.RaiseBeforeModifyObject('ArcPoint') then
  begin
    FArcPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ArcPoint');
  end;
end;


procedure TUdDim3PointAngular.SetTextPoint(const AValue: TPoint2D);
begin
  if NotEqual(FTextPoint, AValue) and Self.RaiseBeforeModifyObject('TextPoint') then
  begin
    FTextPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('TextPoint');
  end;
end;








function TUdDim3PointAngular.GetCenterPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FCenterPoint.X;
    1: Result := FCenterPoint.Y;
  end;
end;

procedure TUdDim3PointAngular.SetCenterPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FCenterPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FCenterPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('CenterX');
    1: Self.RaiseBeforeModifyObject('CenterY');
  end;

  FCenterPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('CenterX');
    1: Self.RaiseAfterModifyObject('CenterY');
  end;
end;


function TUdDim3PointAngular.GetExtLine1PointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine1Point.X;
    1: Result := FExtLine1Point.Y;
  end;
end;

procedure TUdDim3PointAngular.SetExtLine1PointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FExtLine1Point;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FExtLine1Point) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('ExtLine1PointX');
    1: Self.RaiseBeforeModifyObject('ExtLine1PointY');
  end;

  FExtLine1Point := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('ExtLine1PointX');
    1: Self.RaiseAfterModifyObject('ExtLine1PointY');
  end;
end;


function TUdDim3PointAngular.GetExtLine2PointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine2Point.X;
    1: Result := FExtLine2Point.Y;
  end;
end;

procedure TUdDim3PointAngular.SetExtLine2PointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FExtLine2Point;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FExtLine2Point) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('ExtLine2PointX');
    1: Self.RaiseBeforeModifyObject('ExtLine2PointY');
  end;

  FExtLine2Point := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('ExtLine2PointX');
    1: Self.RaiseAfterModifyObject('ExtLine2PointY');
  end;
end;


function TUdDim3PointAngular.GetArcPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FArcPoint.X;
    1: Result := FArcPoint.Y;
  end;
end;

procedure TUdDim3PointAngular.SetArcPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FArcPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FArcPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('ArcPointX');
    1: Self.RaiseBeforeModifyObject('ArcPointY');
  end;

  FArcPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('ArcPointX');
    1: Self.RaiseAfterModifyObject('ArcPointY');
  end;
end;


function TUdDim3PointAngular.GetTextPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FTextPoint.X;
    1: Result := FTextPoint.Y;
  end;
end;

procedure TUdDim3PointAngular.SetTextPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FTextPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FTextPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('TextPointX');
    1: Self.RaiseBeforeModifyObject('TextPointY');
  end;

  FTextPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('TextPointX');
    1: Self.RaiseAfterModifyObject('TextPointY');
  end;
end;




procedure TUdDim3PointAngular.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDim3PointAngular) then Exit;

  FCenterPoint      := TUdDim3PointAngular(AValue).FCenterPoint   ;
  FExtLine1Point    := TUdDim3PointAngular(AValue).FExtLine1Point  ;
  FExtLine2Point    := TUdDim3PointAngular(AValue).FExtLine2Point  ;

  FArcPoint         := TUdDim3PointAngular(AValue).FArcPoint      ;
  FTextPoint        := TUdDim3PointAngular(AValue).FTextPoint     ;

  Self.Update();
end;





//----------------------------------------------------------------------------------------

function TUdDim3PointAngular.GetDimArc: TArc2D;
begin
  Result := Arc2D(FCenterPoint,
                  Distance(FCenterPoint, FArcPoint),
                  GetAngle(FCenterPoint, FExtLine1Point),
                  GetAngle(FCenterPoint, FExtLine2Point)
                  );
end;


function TUdDim3PointAngular.GetDimLine1Point: TPoint2D;
begin
  Result := ShiftPoint(FCenterPoint, GetAngle(FCenterPoint, FExtLine1Point), Distance(FCenterPoint, FArcPoint));
end;

function TUdDim3PointAngular.GetDimLine2Point: TPoint2D;
begin
  Result := ShiftPoint(FCenterPoint, GetAngle(FCenterPoint, FExtLine2Point), Distance(FCenterPoint, FArcPoint));
end;



function TUdDim3PointAngular.UpdateDim(AAxes: TUdAxes): Boolean;
var
  I: Integer;
  LDimArc: TArc2D;
  LTextPnt: TPoint2D;
  LTextEnt: TUdText;
  LInctBound: Boolean;
  LTextOutSide: Integer;
  LDimP1, LDimP2: TPoint2D;
  LTextWidth, LTextAngle, LRadAngle: Float;
  LDimEntities: TUdEntityArray;
  LOverallScale: Float;
begin
  Result := False;

  ClearObjectList(FEntityList);

  LDimArc.R := -1;
  LDimArc := Arc2D(FCenterPoint, Distance(FCenterPoint, FArcPoint),
                GetAngle(FCenterPoint, FExtLine1Point), GetAngle(FCenterPoint, FExtLine2Point));

  if (LDimArc.R < 0) or IsEqual(LDimArc.R, 0.0) then Exit; //========>>>>>


  LDimP1 := ShiftPoint(LDimArc.Cen, LDimArc.Ang1, LDimArc.R);
  LDimP2 := ShiftPoint(LDimArc.Cen, LDimArc.Ang2, LDimArc.R);

  FMeasurement := FixAngle(LDimArc.Ang2 - LDimArc.Ang1);

  LOverallScale := 1.0;
  if Assigned(FDimStyle) then LOverallScale := FDimStyle.OverallScale;

  //------------------------------------------------------

  LTextEnt := TUdText.Create(Self.Document, False);

  LTextEnt.BeginUpdate();
  try
    LTextEnt.Owner := Self;

    LTextEnt.Alignment := taMiddleCenter;
    if Assigned(Self.TextStyles) then
      LTextEnt.TextStyle  := Self.TextStyles.GetItem(FTextProp.TextStyle);
    LTextEnt.Height := FTextProp.TextHeight * LOverallScale;
    LTextEnt.Color.Assign(FTextProp.TextColor);
    LTextEnt.DrawFrame := FTextProp.DrawFrame;
    LTextEnt.FillColor := FTextProp.FillColor;

    LTextEnt.Contents := GetDimText(FMeasurement, dtkAngle);
  finally
    LTextEnt.EndUpdate();
  end;

  LTextWidth := LTextEnt.TextWidth + (FTextProp.TextHeight * TEXT_BOUND_OFFSET_FACTOR) * 2;
  FEntityList.Add(LTextEnt);



  //------------------------------------------------------

  LTextPnt := FTextPoint;

  case FTextProp.HorizontalPosition of
    htpCentered           : LTextPnt := MidPoint(LDimArc);
    htpFirstExtensionLine : LTextPnt := ShiftArcPoint(LDimArc, True,  -(LTextWidth / 2 + FArrowsProp.ArrowSize));
    htpSecondExtensionLine: LTextPnt := ShiftArcPoint(LDimArc, False, -(LTextWidth / 2 + FArrowsProp.ArrowSize));
    htpCustom             : LTextPnt := ClosestArcPoint(FTextPoint, LDimArc);
  end;

  FGripTextPnt := LTextPnt;



  //-------------------------------------------------------

  LTextOutSide := 0;

  if not Assigned(FDimStyle) or (Assigned(FDimStyle) and FDimStyle.BestFit) then
  begin
    if LTextWidth >= Distance(LDimArc) * 1.2 then
    begin
      LTextAngle := FixAngle(LDimArc.Ang2 + 90);
      LTextPnt  := ShiftPoint(LDimP2, LTextAngle, (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 );

      LTextOutSide := 2;
    end
    else begin
      LRadAngle := GetAngle(LDimArc.Cen, LTextPnt);

      if not UdMath.IsInAngles(LRadAngle, LDimArc.Ang1, LDimArc.Ang2) then
      begin
        if FixAngle(LDimArc.Ang1 - LRadAngle) <  FixAngle(LRadAngle - LDimArc.Ang2) then
          LTextOutSide := 1
        else
          LTextOutSide := 2;
      end;

      LTextAngle := FixAngle(GetAngle(LDimArc.Cen, LTextPnt) + 90.0);
    end;
  end
  else
    LTextAngle := FixAngle(GetAngle(LDimArc.Cen, LTextPnt) + 90.0);

  if FTextAngle >= 0.0 then
  begin
    UpdateTextPosition(LTextEnt, False, LTextPnt, FTextAngle);
    LInctBound := True;
  end
  else
    UpdateInsideTextPosition(LTextEnt, LTextPnt, LTextAngle, True, LInctBound);


  //------------------------------------------------------

  UdDimArcLength.FCreateDimLines(Self, LTextPnt, LTextOutSide, LTextWidth, LInctBound, LTextEnt.TextBound, LDimArc, LDimEntities);
  for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);


  LDimEntities := Self.CreateExtLines(FExtLine1Point, FExtLine2Point, LDimP1, LDimP2);
  for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);


  FArcPoint := ShiftPoint(LDimArc.Cen,
                          FixAngle(LDimArc.Ang1 + FixAngle(LDimArc.Ang2 - LDimArc.Ang1) / 3 ),
                          LDimArc.R);
  Result := True;
end;





//----------------------------------------------------------------------------------------

function TUdDim3PointAngular.GetGripPoints: TUdGripPointArray;
begin
  System.SetLength(Result, 5);

  Result[0] := MakeGripPoint(Self, gmPoint, 0, FCenterPoint , 0);
  Result[1] := MakeGripPoint(Self, gmPoint, 1, FExtLine1Point, 0);
  Result[2] := MakeGripPoint(Self, gmPoint, 2, FExtLine2Point, 0);
  Result[3] := MakeGripPoint(Self, gmPoint, 3, FArcPoint , 0);
  Result[4] := MakeGripPoint(Self, gmPoint, 4, FGripTextPnt, 0);
end;


function TUdDim3PointAngular.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  LDimRad: Float;
  LArcPnt: TPoint2D;
  LAng1, LAng2, LAng: Float;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    LArcPnt := FArcPoint;

    case AGripPnt.Index of
      0:
        begin
          Self.Move(FCenterPoint, AGripPnt.Point);
        end;
      1:
        begin
          Self.RaiseBeforeModifyObject('');
          FExtLine1Point := AGripPnt.Point;
          Self.RaiseAfterModifyObject('');
        end;
      2:
        begin
          Self.RaiseBeforeModifyObject('');
          FExtLine2Point := AGripPnt.Point;
          Self.RaiseAfterModifyObject('');
        end;
      3:
        begin
          Self.RaiseBeforeModifyObject('');

          LArcPnt := AGripPnt.Point;

          LAng1 := GetAngle(FCenterPoint, FExtLine1Point);
          LAng2 := GetAngle(FCenterPoint, FExtLine2Point);

          LAng := GetAngle(FCenterPoint, AGripPnt.Point);
          if not UdMath.IsInAngles(LAng, LAng1, LAng2) then
            Swap(FExtLine1Point, FExtLine2Point);

          Self.RaiseAfterModifyObject('');
        end;
      4:
        begin
          Self.RaiseBeforeModifyObject('');

          LArcPnt := AGripPnt.Point;

          FTextProp.HorizontalPosition := htpCustom;
          FTextPoint := AGripPnt.Point;

          Self.RaiseAfterModifyObject('');
        end;

    end;

    if AGripPnt.Index in [1..4] then
    begin
      LAng1 := GetAngle(FCenterPoint, FExtLine1Point);
      LAng2 := GetAngle(FCenterPoint, FExtLine2Point);
      LDimRad := Distance(FCenterPoint, LArcPnt);

      Self.BeginUpdate();
      try
        if AGripPnt.Index <> 4 then
        begin
          FTextProp.HorizontalPosition := htpCentered;
          FTextPoint := ShiftPoint(FCenterPoint, FixAngle(LAng1 + FixAngle(LAng2 - LAng1)/ 2), LDimRad);
        end;

        FArcPoint  := ShiftPoint(FCenterPoint, FixAngle(LAng1 + FixAngle(LAng2 - LAng1)/ 3), LDimRad);
      finally
        Self.EndUpdate();
      end;
    end;
  end;
end;




//----------------------------------------------------------------------------------------

function TUdDim3PointAngular.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenterPoint      := UdGeo2D.Translate(Dx, Dy, FCenterPoint   );
  FExtLine1Point    := UdGeo2D.Translate(Dx, Dy, FExtLine1Point  );
  FExtLine2Point    := UdGeo2D.Translate(Dx, Dy, FExtLine2Point  );

  FArcPoint         := UdGeo2D.Translate(Dx, Dy, FArcPoint);
  FTextPoint        := UdGeo2D.Translate(Dx, Dy, FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDim3PointAngular.Mirror(APnt1, APnt2: TPoint2D): Boolean;
//var
//  LPnt1, LPnt2: TPoint2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenterPoint      := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FCenterPoint);
  FExtLine1Point    := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine1Point  );
  FExtLine2Point    := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine2Point  );

  FArcPoint         := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FArcPoint);
  FTextPoint        := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDim3PointAngular.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenterPoint      := UdGeo2D.Rotate(ABase, ARota, FCenterPoint   );
  FExtLine1Point    := UdGeo2D.Rotate(ABase, ARota, FExtLine1Point  );
  FExtLine2Point    := UdGeo2D.Rotate(ABase, ARota, FExtLine2Point  );

  FArcPoint         := UdGeo2D.Rotate(ABase, ARota, FArcPoint);
  FTextPoint        := UdGeo2D.Rotate(ABase, ARota, FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDim3PointAngular.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenterPoint   := UdGeo2D.Scale(ABase, AFactor, AFactor, FCenterPoint   );
  FExtLine1Point := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine1Point  );
  FExtLine2Point := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine2Point  );

  FArcPoint      := UdGeo2D.Scale(ABase, AFactor, AFactor, FArcPoint );
  FTextPoint     := UdGeo2D.Scale(ABase, AFactor, AFactor, FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdDim3PointAngular.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdDim3PointAngular;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdDim3PointAngular.Create(Self.Document, False);

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      with LEntity do
      begin
        FCenterPoint   := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FCenterPoint   );
        FExtLine1Point := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine1Point  );
        FExtLine2Point := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine2Point  );

        FArcPoint      := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FArcPoint );
        FTextPoint     := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FTextPoint);
      end;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;


function TUdDim3PointAngular.Intersect(AOther: TUdEntity): TPoint2DArray;
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

function TUdDim3PointAngular.Perpend(APnt: TPoint2D): TPoint2DArray;
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

procedure TUdDim3PointAngular.SaveToStream(AStream: TStream);
begin
  inherited;

  Point2DToStream(AStream, FCenterPoint   );
  Point2DToStream(AStream, FExtLine1Point);
  Point2DToStream(AStream, FExtLine2Point) ;

  Point2DToStream(AStream, FArcPoint      ) ;
  Point2DToStream(AStream, FTextPoint     ) ;
end;

procedure TUdDim3PointAngular.LoadFromStream(AStream: TStream);
begin
  inherited;

  FCenterPoint   := Point2DFromStream(AStream);
  FExtLine1Point := Point2DFromStream(AStream);
  FExtLine2Point := Point2DFromStream(AStream);

  FArcPoint     := Point2DFromStream(AStream);
  FTextPoint    := Point2DFromStream(AStream);

  Self.Update();
end;



procedure TUdDim3PointAngular.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['CenterPoint']    := Point2DToStr(FCenterPoint);
  LXmlNode.Prop['ExtLine1Point']  := Point2DToStr(FExtLine1Point);
  LXmlNode.Prop['ExtLine2Point']  := Point2DToStr(FExtLine2Point);

  LXmlNode.Prop['ArcPoint']       := Point2DToStr(FArcPoint);
  LXmlNode.Prop['TextPoin']       := Point2DToStr(FTextPoint);
end;

procedure TUdDim3PointAngular.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FCenterPoint   := StrToPoint2D(LXmlNode.Prop['CenterPoint'] );
  FExtLine1Point := StrToPoint2D(LXmlNode.Prop['ExtLine1Point'] );
  FExtLine2Point := StrToPoint2D(LXmlNode.Prop['ExtLine2Point'] );

  FArcPoint      := StrToPoint2D(LXmlNode.Prop['ArcPoint'] );
  FTextPoint     := StrToPoint2D(LXmlNode.Prop['TextPoint'] );

  Self.Update();
end;

end.