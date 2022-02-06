{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDim2LineAngular;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes, UdConsts, UdObject, UdAxes, UdEntity,
  UdColor, UdDimProps, UdDimension;


type
  //*** TUdDim2LineAngular ***//
  TUdDim2LineAngular = class(TUdDimension, IUdDimLineSupport)
  protected
    FExtLine1StartPoint: TPoint2D;
    FExtLine1EndPoint  : TPoint2D;
    FExtLine2StartPoint: TPoint2D;
    FExtLine2EndPoint  : TPoint2D;

    FArcPoint : TPoint2D;
    FTextPoint: TPoint2D;

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; override;

    procedure SetExtLine1StartPoint(const AValue: TPoint2D);
    procedure SetExtLine1EndPoint(const AValue: TPoint2D);
    procedure SetExtLine2StartPoint(const AValue: TPoint2D);
    procedure SetExtLine2EndPoint(const AValue: TPoint2D);

    procedure SetArcPoint(const AValue: TPoint2D);
    procedure SetTextPoint(const AValue: TPoint2D); override;


    function GetExtLine1StartPointValue(AIndex: Integer): Float;
    procedure SetExtLine1StartPointValue(AIndex: Integer; const AValue: Float);

    function GetExtLine1EndPointValue(AIndex: Integer): Float;
    procedure SetExtLine1EndPointValue(AIndex: Integer; const AValue: Float);

    function GetExtLine2StartPointValue(AIndex: Integer): Float;
    procedure SetExtLine2StartPointValue(AIndex: Integer; const AValue: Float);

    function GetExtLine2EndPointValue(AIndex: Integer): Float;
    procedure SetExtLine2EndPointValue(AIndex: Integer; const AValue: Float);

    function GetArcPointValue(AIndex: Integer): Float;
    procedure SetArcPointValue(AIndex: Integer; const AValue: Float);

    function GetTextPointValue(AIndex: Integer): Float;
    procedure SetTextPointValue(AIndex: Integer; const AValue: Float);


    function GetDimArc(AArcPnt: TPoint2D): TArc2D; overload;
    function GetDimArcs(AArcPnt: TPoint2D; var Arc0, Arc1, Arc2, Arc3: TArc2D): Boolean;

    function CreateAngularExtLines(ADimArc: TArc2D): TUdEntityArray;
    function UpdateDim(AAxes: TUdAxes): Boolean; override;

    {IUdDimLineSupport ...}
    function GetDimLine1Point(): TPoint2D;
    function GetDimLine2Point(): TPoint2D;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;


    function GetDimArc(): TArc2D; overload;
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

    property ExtLine1StartPoint : TPoint2D read FExtLine1StartPoint write SetExtLine1StartPoint ;
    property ExtLine1EndPoint   : TPoint2D read FExtLine1EndPoint   write SetExtLine1EndPoint  ;
    property ExtLine2StartPoint : TPoint2D read FExtLine2StartPoint write SetExtLine2StartPoint;
    property ExtLine2EndPoint   : TPoint2D read FExtLine2EndPoint   write SetExtLine2EndPoint  ;

    property ArcPoint           : TPoint2D read FArcPoint  write SetArcPoint;
    property TextPoint          : TPoint2D read FTextPoint write SetTextPoint;

  published
    property ExtLine1StartPointX: Float index 0 read GetExtLine1StartPointValue write SetExtLine1StartPointValue;
    property ExtLine1StartPointY: Float index 1 read GetExtLine1StartPointValue write SetExtLine1StartPointValue;

    property ExtLine1EndPointX  : Float index 0 read GetExtLine1EndPointValue   write SetExtLine1EndPointValue  ;
    property ExtLine1EndPointY  : Float index 1 read GetExtLine1EndPointValue   write SetExtLine1EndPointValue  ;

    property ExtLine2StartPointX: Float index 0 read GetExtLine2StartPointValue write SetExtLine2StartPointValue;
    property ExtLine2StartPointY: Float index 1 read GetExtLine2StartPointValue write SetExtLine2StartPointValue;

    property ExtLine2EndPointX  : Float index 0 read GetExtLine2EndPointValue   write SetExtLine2EndPointValue  ;
    property ExtLine2EndPointY  : Float index 1 read GetExtLine2EndPointValue   write SetExtLine2EndPointValue  ;

    property ArcPointX : Float index 0 read GetArcPointValue  write SetArcPointValue;
    property ArcPointY : Float index 1 read GetArcPointValue  write SetArcPointValue;

    property TextPointX: Float index 0 read GetTextPointValue write SetTextPointValue;
    property TextPointY: Float index 1 read GetTextPointValue write SetTextPointValue;
  end;


implementation

uses
  SysUtils, UdText, UdDimArcLength,
  UdMath, UdGeo2D, UdStreams, UdXml, UdUtils, UdStrConverter;



//=================================================================================================
{ TUdDim2LineAngular }

constructor TUdDim2LineAngular.Create();
begin
  inherited;

  FExtLine1StartPoint:= Point2D(0, 0);
  FExtLine1EndPoint  := Point2D(0, 0);
  FExtLine2StartPoint:= Point2D(0, 0);
  FExtLine2EndPoint  := Point2D(0, 0);

  FArcPoint    := Point2D(0, 0);
  FTextPoint   := Point2D(0, 0);
end;

destructor TUdDim2LineAngular.Destroy;
begin

  inherited;
end;


function TUdDim2LineAngular.GetTypeID: Integer;
begin
  Result := ID_DIMANGULAR;
end;

function TUdDim2LineAngular.GetDimTypeID: Integer;
begin
  Result := 2;
end;


//----------------------------------------------------------------------------------------

procedure TUdDim2LineAngular.SetExtLine1StartPoint(const AValue: TPoint2D);
begin
  if NotEqual(FExtLine1StartPoint, AValue) and Self.RaiseBeforeModifyObject('ExtLine1StartPoint') then
  begin
    FExtLine1StartPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLine1StartPoint');
  end;
end;

procedure TUdDim2LineAngular.SetExtLine1EndPoint(const AValue: TPoint2D);
begin
  if NotEqual(FExtLine1EndPoint, AValue) and Self.RaiseBeforeModifyObject('ExtLine1EndPoint') then
  begin
    FExtLine1EndPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLine1EndPoint');
  end;
end;


procedure TUdDim2LineAngular.SetExtLine2StartPoint(const AValue: TPoint2D);
begin
  if NotEqual(FExtLine2StartPoint, AValue) and Self.RaiseBeforeModifyObject('ExtLine2StartPoint') then
  begin
    FExtLine2StartPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLine2StartPoint');
  end;
end;



procedure TUdDim2LineAngular.SetExtLine2EndPoint(const AValue: TPoint2D);
begin
  if NotEqual(FExtLine2EndPoint, AValue) and Self.RaiseBeforeModifyObject('ExtLine2EndPoint') then
  begin
    FExtLine2EndPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLine2EndPoint');
  end;
end;




procedure TUdDim2LineAngular.SetArcPoint(const AValue: TPoint2D);
begin
  if NotEqual(FArcPoint, AValue) and Self.RaiseBeforeModifyObject('ArcPoint') then
  begin
    FArcPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ArcPoint');
  end;
end;


procedure TUdDim2LineAngular.SetTextPoint(const AValue: TPoint2D);
begin
  if NotEqual(FTextPoint, AValue) and Self.RaiseBeforeModifyObject('TextPoint') then
  begin
    FTextPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('TextPoint');
  end;
end;




function TUdDim2LineAngular.GetExtLine1StartPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine1StartPoint.X;
    1: Result := FExtLine1StartPoint.Y;
  end;
end;

procedure TUdDim2LineAngular.SetExtLine1StartPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FExtLine1StartPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FExtLine1StartPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('ExtLine1StartPointX');
    1: Self.RaiseBeforeModifyObject('ExtLine1StartPointY');
  end;

  FExtLine1StartPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('ExtLine1StartPointX');
    1: Self.RaiseAfterModifyObject('ExtLine1StartPointY');
  end;
end;


function TUdDim2LineAngular.GetExtLine1EndPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine1EndPoint.X;
    1: Result := FExtLine1EndPoint.Y;
  end;
end;

procedure TUdDim2LineAngular.SetExtLine1EndPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FExtLine1EndPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FExtLine1EndPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('ExtLine1EndPointX');
    1: Self.RaiseBeforeModifyObject('ExtLine1EndPointY');
  end;

  FExtLine1EndPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('ExtLine1EndPointX');
    1: Self.RaiseAfterModifyObject('ExtLine1EndPointY');
  end;
end;



function TUdDim2LineAngular.GetExtLine2StartPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine2StartPoint.X;
    1: Result := FExtLine2StartPoint.Y;
  end;
end;

procedure TUdDim2LineAngular.SetExtLine2StartPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FExtLine2StartPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FExtLine2StartPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('ExtLine2StartPointX');
    1: Self.RaiseBeforeModifyObject('ExtLine2StartPointY');
  end;

  FExtLine2StartPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('ExtLine2StartPointX');
    1: Self.RaiseAfterModifyObject('ExtLine2StartPointY');
  end;
end;


function TUdDim2LineAngular.GetExtLine2EndPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine2EndPoint.X;
    1: Result := FExtLine2EndPoint.Y;
  end;
end;

procedure TUdDim2LineAngular.SetExtLine2EndPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FExtLine2EndPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FExtLine2EndPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('ExtLine2EndPointX');
    1: Self.RaiseBeforeModifyObject('ExtLine2EndPointY');
  end;

  FExtLine2EndPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('ExtLine2EndPointX');
    1: Self.RaiseAfterModifyObject('ExtLine2EndPointY');
  end;
end;



function TUdDim2LineAngular.GetArcPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FArcPoint.X;
    1: Result := FArcPoint.Y;
  end;
end;

procedure TUdDim2LineAngular.SetArcPointValue(AIndex: Integer; const AValue: Float);
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


function TUdDim2LineAngular.GetTextPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FTextPoint.X;
    1: Result := FTextPoint.Y;
  end;
end;

procedure TUdDim2LineAngular.SetTextPointValue(AIndex: Integer; const AValue: Float);
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



procedure TUdDim2LineAngular.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDim2LineAngular) then Exit;

  FExtLine1StartPoint := TUdDim2LineAngular(AValue).FExtLine1StartPoint ;
  FExtLine1EndPoint   := TUdDim2LineAngular(AValue).FExtLine1EndPoint  ;
  FExtLine2StartPoint := TUdDim2LineAngular(AValue).FExtLine2StartPoint;
  FExtLine2EndPoint   := TUdDim2LineAngular(AValue).FExtLine2EndPoint  ;

  FArcPoint    := TUdDim2LineAngular(AValue).FArcPoint;
  FTextPoint   := TUdDim2LineAngular(AValue).FTextPoint;


  Self.Update();
end;





//----------------------------------------------------------------------------------------


function TUdDim2LineAngular.GetDimArcs(AArcPnt: TPoint2D; var Arc0, Arc1, Arc2, Arc3: TArc2D): Boolean;
var
  I, N: Integer;
  LRadius: Float;
  LCenter: TPoint2D;
  LInctPnts: TPoint2DArray;
  LAngles: TFloatArray;
  LAng1, LAng2, LPntAng: Float;
  LArcs: array[0..3] of TArc2D;
begin
  Result := False;

  if IsEqual(FExtLine1StartPoint, FExtLine1EndPoint) or
     IsEqual(FExtLine2StartPoint, FExtLine2EndPoint) then Exit; //========>>>


  LInctPnts := UdGeo2D.Intersection(Line2D(FExtLine1StartPoint, FExtLine1EndPoint),
                                    Line2D(FExtLine2StartPoint, FExtLine2EndPoint));
  if (System.Length(LInctPnts) <> 1) then Exit; //========>>>

  LCenter := LInctPnts[0];
  LRadius := Distance(LCenter, AArcPnt);

  if IsEqual(LRadius, 0.0) then Exit; //========>>>

  System.SetLength(LAngles, 4);
  for I := 0 to System.Length(LAngles) - 1 do LAngles[I] := -1;

  if NotEqual(LCenter, FExtLine1StartPoint) then
    LAngles[0] := GetAngle(LCenter, FExtLine1StartPoint)
  else
    LAngles[0] := GetAngle(LCenter, FExtLine1EndPoint);

  LAngles[1] := FixAngle(LAngles[0] + 180);

  if NotEqual(LCenter, FExtLine2StartPoint) then
    LAngles[2] := GetAngle(LCenter, FExtLine2StartPoint)
  else
    LAngles[2] := GetAngle(LCenter, FExtLine2EndPoint);

  LAngles[3] := FixAngle(LAngles[2] + 180);

  SortFloatArray(LAngles);

  LPntAng := GetAngle(LCenter, AArcPnt);

  N := 0;
  for I := 0 to 3 do
  begin
    LAng1 := LAngles[I mod 4];
    LAng2 := LAngles[(I + 1) mod 4];

    if UdMath.IsInAngles(LPntAng, LAng1, LAng2) then
    begin
      N := I;
      Break;
    end;
  end;

  for I := 0 to 3 do
  begin
    LAng1 := LAngles[(N + I) mod 4];
    LAng2 := LAngles[(N + I + 1) mod 4];

    LArcs[I] := Arc2D(LCenter, LRadius, LAng1, LAng2);
  end;

  Arc0 := LArcs[0];
  Arc1 := LArcs[1];
  Arc2 := LArcs[2];
  Arc3 := LArcs[3];

  Result := True;
end;


function TUdDim2LineAngular.GetDimLine1Point: TPoint2D;
var
  LDimArc: TArc2D;
begin
  LDimArc := GetDimArc(FArcPoint);
  Result := ShiftPoint(LDimArc.Cen, LDimArc.Ang1, LDimArc.R);
end;

function TUdDim2LineAngular.GetDimLine2Point: TPoint2D;
var
  LDimArc: TArc2D;
begin
  LDimArc := GetDimArc(FArcPoint);
  Result := ShiftPoint(LDimArc.Cen, LDimArc.Ang2, LDimArc.R);
end;



function TUdDim2LineAngular.GetDimArc(AArcPnt: TPoint2D): TArc2D;
var
  LArc0, LArc1, LArc2, LArc3: TArc2D;
begin
  Result.R := -1;
  if GetDimArcs(AArcPnt, LArc0, LArc1, LArc2, LArc3) then Result := LArc0;
end;


function TUdDim2LineAngular.GetDimArc: TArc2D;
begin
  Result := Self.GetDimArc(FArcPoint);
end;


function TUdDim2LineAngular.CreateAngularExtLines(ADimArc: TArc2D): TUdEntityArray;
var
  LAng: Float;
  LSeg: TSegment2D;
  LSeg1, LSeg2: TSegment2D;
  LDimP1, LDimP2: TPoint2D;
  LExtP1, LExtP2: TPoint2D;
  LEqAng1, LEqAng2: Boolean;
begin
  Result := nil;
  if FLinesProp.ExtSuppressLine1 and FLinesProp.ExtSuppressLine2 then Exit; //========>>>

  if (ADimArc.R < 0) or IsEqual(ADimArc.R, 0.0) then Exit;  //========>>>

  LDimP1 := ShiftPoint(ADimArc.Cen, ADimArc.Ang1, ADimArc.R);
  LDimP2 := ShiftPoint(ADimArc.Cen, ADimArc.Ang2, ADimArc.R);

  LSeg1 := Segment2D(FExtLine1StartPoint, FExtLine1EndPoint);
  LSeg2 := Segment2D(FExtLine2StartPoint, FExtLine2EndPoint);

  if not IsPntOnLine(LDimP1, Line2D(FExtLine1StartPoint, FExtLine1EndPoint)) then
  begin
    LSeg := LSeg1;
    LSeg1 := LSeg2;
    LSeg2 := LSeg;
  end;

  if IsPntOnSegment(LDimP1, LSeg1) then LExtP1 := LDimP1 else
  begin
    LAng := GetAngle(ADimArc.Cen, LDimP1);
    LEqAng1 := IsEqual(LAng, GetAngle(ADimArc.Cen, LSeg1.P1));
    LEqAng2 := IsEqual(LAng, GetAngle(ADimArc.Cen, LSeg1.P2));

    if LEqAng1 or LEqAng2 then
    begin
      if Distance(LDimP1, LSeg1.P1) < Distance(LDimP1, LSeg1.P2) then
        LExtP1 := LSeg1.P1
      else
        LExtP1 := LSeg1.P2;
    end
    else begin
      LExtP1 := ADimArc.Cen;
    end;
  end;

  if IsPntOnSegment(LDimP2, LSeg2) then LExtP2 := LDimP2 else
  begin
    LAng := GetAngle(ADimArc.Cen, LDimP2);
    LEqAng1 := IsEqual(LAng, GetAngle(ADimArc.Cen, LSeg2.P1));
    LEqAng2 := IsEqual(LAng, GetAngle(ADimArc.Cen, LSeg2.P2));

    if LEqAng1 or LEqAng2 then
    begin
      if Distance(LDimP2, LSeg2.P1) < Distance(LDimP2, LSeg2.P2) then
        LExtP2 := LSeg2.P1
      else
        LExtP2 := LSeg2.P2;
    end
    else begin
      LExtP2 := ADimArc.Cen;
    end;
  end;

  Result := Self.CreateExtLines(LExtP1, LExtP2, LDimP1, LDimP2);
end;

function TUdDim2LineAngular.UpdateDim(AAxes: TUdAxes): Boolean;
var
  I: Integer;
  LDimArc: TArc2D;
  LTextPnt: TPoint2D;
  LTextEnt: TUdText;
  LInctBound: Boolean;
  LTextOutSide: Integer;
  LDimP1, LDimP2: TPoint2D;
  LTextWidth, LTextAngle, LRadAngle: Float; //, LMidAngle
  LDimEntities: TUdEntityArray;
  LOverallScale: Float;
begin
  Result := False;

  ClearObjectList(FEntityList);

  LDimArc := GetDimArc(FArcPoint);
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
      LTextEnt.TextStyle := Self.TextStyles.GetItem(FTextProp.TextStyle);
    LTextEnt.Height    := FTextProp.TextHeight * LOverallScale;
    LTextEnt.Color.Assign(FTextProp.TextColor);
    LTextEnt.DrawFrame := FTextProp.DrawFrame;
    LTextEnt.FillColor := FTextProp.FillColor;

    LTextEnt.Contents := GetDimText(FMeasurement, dtkAngle);
  finally
    LTextEnt.EndUpdate(AAxes);
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
//      LRadAngle := GetAngle(LDimArc.Cen, LTextPnt);
//      LMidAngle := MidAngle(LDimArc.Ang1, LDimArc.Ang2);

//      if FixAngle(LDimArc.Ang1 - LRadAngle) <  FixAngle(LRadAngle - LDimArc.Ang2) then
//      begin
//        LTextOutSide := 1;
//        LTextAngle := FixAngle(LDimArc.Ang1 - 90);
//        LTextPnt   := ShiftPoint(LDimP2, LTextAngle, (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 );
//      end
//      else begin
//        LTextOutSide := 2;
//        LTextAngle := FixAngle(LDimArc.Ang2 + 90);
//        LTextPnt   := ShiftPoint(LDimP2, LTextAngle, (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 );
//      end;

      LTextAngle := FixAngle(LDimArc.Ang2 + 90);
      LTextPnt  := ShiftPoint(LDimP2, LTextAngle, (LTextWidth / 2 + DIM_TEXT_SIDE_OFFSET) );

      LTextOutSide := 2;
    end
    else begin
      LRadAngle := GetAngle(LDimArc.Cen, LTextPnt);

      if not UdMath.IsInAngles(LRadAngle, LDimArc.Ang1, LDimArc.Ang2) then
      begin
        if FixAngle(LDimArc.Ang1 - LRadAngle) <  FixAngle(LRadAngle - LDimArc.Ang2) then
        begin
          LTextOutSide := 1
        end
        else begin
          LTextOutSide := 2;
        end;
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


  LDimEntities := CreateAngularExtLines(LDimArc);
  for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);

  FArcPoint := ShiftPoint(LDimArc.Cen,
                          FixAngle(LDimArc.Ang1 + FixAngle(LDimArc.Ang2 - LDimArc.Ang1) / 3 ),
                          LDimArc.R);
  Result := True;
end;





//----------------------------------------------------------------------------------------

function TUdDim2LineAngular.GetGripPoints: TUdGripPointArray;
begin
  System.SetLength(Result, 6);

  Result[0] := MakeGripPoint(Self, gmPoint, 0, FExtLine1StartPoint, 0);
  Result[1] := MakeGripPoint(Self, gmPoint, 1, FExtLine1EndPoint  , 0);
  Result[2] := MakeGripPoint(Self, gmPoint, 2, FExtLine2StartPoint, 0);
  Result[3] := MakeGripPoint(Self, gmPoint, 3, FExtLine2EndPoint  , 0);

  Result[4] := MakeGripPoint(Self, gmPoint, 4, FArcPoint , 0);
  Result[5] := MakeGripPoint(Self, gmPoint, 5, FGripTextPnt, 0);
end;


function TUdDim2LineAngular.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  LDimArc: TArc2D;
  LArcPnt: TPoint2D;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    Self.RaiseBeforeModifyObject('');

    LArcPnt := FArcPoint;

    case AGripPnt.Index of
      0: FExtLine1StartPoint := AGripPnt.Point;
      1: FExtLine1EndPoint   := AGripPnt.Point;
      2: FExtLine2StartPoint := AGripPnt.Point;
      3: FExtLine2EndPoint   := AGripPnt.Point;

      4:
        begin
          LArcPnt := AGripPnt.Point;
          FArcPoint := AGripPnt.Point;
        end;
      5:
        begin
          LArcPnt := AGripPnt.Point;
          FTextProp.HorizontalPosition := htpCustom;
          FTextPoint := AGripPnt.Point;
        end;

    end;

    if AGripPnt.Index in [0..5] then
    begin
      Self.BeginUpdate();
      try
        LDimArc := Self.GetDimArc(LArcPnt);
        if LDimArc.R > 0 then
        begin
          if AGripPnt.Index <> 5 then
          begin
            FTextProp.HorizontalPosition := htpCentered;
            FTextPoint := ShiftPoint(LDimArc.Cen, FixAngle(LDimArc.Ang1 + FixAngle(LDimArc.Ang2 - LDimArc.Ang1)/ 2), LDimArc.R);
          end;
          FArcPoint  := ShiftPoint(LDimArc.Cen, FixAngle(LDimArc.Ang1 + FixAngle(LDimArc.Ang2 - LDimArc.Ang1)/ 3), LDimArc.R);
        end;
      finally
        Self.EndUpdate();
      end;
    end;

    Self.RaiseAfterModifyObject('');
  end;
end;




//----------------------------------------------------------------------------------------

function TUdDim2LineAngular.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FArcPoint    := UdGeo2D.Translate(Dx, Dy, FArcPoint   );
  FTextPoint   := UdGeo2D.Translate(Dx, Dy, FTextPoint     );

  FExtLine1StartPoint := UdGeo2D.Translate(Dx, Dy, FExtLine1StartPoint );
  FExtLine1EndPoint   := UdGeo2D.Translate(Dx, Dy, FExtLine1EndPoint  );
  FExtLine2StartPoint := UdGeo2D.Translate(Dx, Dy, FExtLine2StartPoint);
  FExtLine2EndPoint   := UdGeo2D.Translate(Dx, Dy, FExtLine2EndPoint  );

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDim2LineAngular.Mirror(APnt1, APnt2: TPoint2D): Boolean;
//var
//  LPnt1, LPnt2: TPoint2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

//  LPnt1 := FFirstEndPoint;
//  LPnt2 := FSecondEndPoint;

  Self.RaiseBeforeModifyObject('');

  FArcPoint    := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FArcPoint);
  FTextPoint   := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FTextPoint);

  FExtLine1StartPoint := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine1StartPoint );
  FExtLine1EndPoint   := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine1EndPoint  );
  FExtLine2StartPoint := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine2StartPoint);
  FExtLine2EndPoint   := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine2EndPoint  );

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDim2LineAngular.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FArcPoint    := UdGeo2D.Rotate(ABase, ARota, FArcPoint   );
  FTextPoint      := UdGeo2D.Rotate(ABase, ARota, FTextPoint     );

  FExtLine1StartPoint := UdGeo2D.Rotate(ABase, ARota, FExtLine1StartPoint );
  FExtLine1EndPoint   := UdGeo2D.Rotate(ABase, ARota, FExtLine1EndPoint  );
  FExtLine2StartPoint := UdGeo2D.Rotate(ABase, ARota, FExtLine2StartPoint);
  FExtLine2EndPoint   := UdGeo2D.Rotate(ABase, ARota, FExtLine2EndPoint  );

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDim2LineAngular.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FArcPoint    := UdGeo2D.Scale(ABase, AFactor, AFactor, FArcPoint   );
  FTextPoint   := UdGeo2D.Scale(ABase, AFactor, AFactor, FTextPoint     );

  FExtLine1StartPoint := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine1StartPoint );
  FExtLine1EndPoint   := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine1EndPoint  );
  FExtLine2StartPoint := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine2StartPoint);
  FExtLine2EndPoint   := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine2EndPoint  );

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdDim2LineAngular.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdDim2LineAngular;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdDim2LineAngular.Create(Self.Document, False);

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      with LEntity do
      begin
        FArcPoint    := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FArcPoint );
        FTextPoint   := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FTextPoint);

        FExtLine1StartPoint := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine1StartPoint);
        FExtLine1EndPoint   := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine1EndPoint  );
        FExtLine2StartPoint := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine2StartPoint);
        FExtLine2EndPoint   := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine2EndPoint  );
      end;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;




function TUdDim2LineAngular.Intersect(AOther: TUdEntity): TPoint2DArray;
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

function TUdDim2LineAngular.Perpend(APnt: TPoint2D): TPoint2DArray;
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

procedure TUdDim2LineAngular.SaveToStream(AStream: TStream);
begin
  inherited;

  Point2DToStream(AStream, FExtLine1StartPoint );
  Point2DToStream(AStream, FExtLine1EndPoint   );
  Point2DToStream(AStream, FExtLine2StartPoint );
  Point2DToStream(AStream, FExtLine2EndPoint   );

  Point2DToStream(AStream, FArcPoint   );
  Point2DToStream(AStream, FTextPoint  ) ;
end;

procedure TUdDim2LineAngular.LoadFromStream(AStream: TStream);
begin
  inherited;

  FExtLine1StartPoint := Point2DFromStream(AStream);
  FExtLine1EndPoint   := Point2DFromStream(AStream);
  FExtLine2StartPoint := Point2DFromStream(AStream);
  FExtLine2EndPoint   := Point2DFromStream(AStream);

  FArcPoint    := Point2DFromStream(AStream);
  FTextPoint   := Point2DFromStream(AStream);

  Self.Update();
end;




procedure TUdDim2LineAngular.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['ExtLine1StartPoint']  := Point2DToStr(FExtLine1StartPoint);
  LXmlNode.Prop['ExtLine1EndPoint'  ]  := Point2DToStr(FExtLine1EndPoint  );
  LXmlNode.Prop['ExtLine2StartPoint']  := Point2DToStr(FExtLine2StartPoint);
  LXmlNode.Prop['ExtLine2EndPoint'  ]  := Point2DToStr(FExtLine2EndPoint  );

  LXmlNode.Prop['ArcPoint']       := Point2DToStr(FArcPoint);
  LXmlNode.Prop['TextPoin']       := Point2DToStr(FTextPoint);
end;

procedure TUdDim2LineAngular.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FExtLine1StartPoint := StrToPoint2D(LXmlNode.Prop['ExtLine1StartPoint'] );
  FExtLine1EndPoint   := StrToPoint2D(LXmlNode.Prop['ExtLine1EndPoint'  ] );
  FExtLine2StartPoint := StrToPoint2D(LXmlNode.Prop['ExtLine2StartPoint'] );
  FExtLine2EndPoint   := StrToPoint2D(LXmlNode.Prop['ExtLine2EndPoint'  ] );

  FArcPoint      := StrToPoint2D(LXmlNode.Prop['ArcPoint'] );
  FTextPoint     := StrToPoint2D(LXmlNode.Prop['TextPoint'] );

  Self.Update();
end;

end.