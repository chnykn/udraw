{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimAligned;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes, UdConsts, UdObject, UdAxes, UdEntity, UdText,
  UdColor, UdDimProps, UdDimension;


type
  //*** TUdDimAligned ***//
  TUdDimAligned = class(TUdDimension, IUdDimLineSupport)
  protected
    FExtLine1Point: TPoint2D;
    FExtLine2Point: TPoint2D;

    FTextPoint: TPoint2D;

    //--------------------------

    FDimLine1Point: TPoint2D;
    FDimLine2Point: TPoint2D;

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; override;

    procedure SetTextPoint(const AValue: TPoint2D); override;
    procedure SetExtLinePoint(AIndex: Integer; const AValue: TPoint2D);

    function GetTextPointValue(AIndex: Integer): Float;
    procedure SetTextPointValue(AIndex: Integer; const AValue: Float);

    function GetExtLine1PointValue(AIndex: Integer): Float;
    procedure SetExtLine1PointValue(AIndex: Integer; const AValue: Float);

    function GetExtLine2PointValue(AIndex: Integer): Float;
    procedure SetExtLine2PointValue(AIndex: Integer; const AValue: Float);



    function GetDimLinePnts(var ADimP1, ADimP2: TPoint2D): Boolean; virtual;
    function UpdateDimLines(ATextPnt: TPoint2D; ATextSide: Integer; ATextWidth: Float; AInctBound: Boolean; ATextBound: TPoint2DArray;
                            ADimP1, ADimP2: TPoint2D): Boolean;

    function UpdateDim(AAxes: TUdAxes): Boolean; override;

    {IUdDimLineSupport ...}
    function GetDimLine1Point(): TPoint2D;
    function GetDimLine2Point(): TPoint2D;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;
        
  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetRotation(): Float; virtual;
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

    property TextPoint: TPoint2D     read FTextPoint  write SetTextPoint;
    property ExtLine1Point: TPoint2D index 0 read FExtLine1Point write SetExtLinePoint;
    property ExtLine2Point: TPoint2D index 1 read FExtLine2Point write SetExtLinePoint;

  published
    property TextPointX: Float index 0 read GetTextPointValue write SetTextPointValue;
    property TextPointY: Float index 1 read GetTextPointValue write SetTextPointValue;

    property ExtLine1PointX: Float index 0 read GetExtLine1PointValue write SetExtLine1PointValue;
    property ExtLine1PointY: Float index 1 read GetExtLine1PointValue write SetExtLine1PointValue;

    property ExtLine2PointX: Float index 0 read GetExtLine2PointValue write SetExtLine2PointValue;
    property ExtLine2PointY: Float index 1 read GetExtLine2PointValue write SetExtLine2PointValue;

  end;


implementation


uses
  SysUtils,
  UdMath, UdGeo2D, UdStreams, UdXml, UdUtils, UdStrConverter;



//=================================================================================================
{ TUdDimAligned }

constructor TUdDimAligned.Create();
begin
  inherited;

  FExtLine1Point := Point2D(0, 0);
  FExtLine2Point := Point2D(0, 0);


  FDimLine1Point := Point2D(0, 0);
  FDimLine2Point := Point2D(0, 0);

  FTextPoint := Point2D(0, 0);
end;

destructor TUdDimAligned.Destroy;
begin

  inherited;
end;

function TUdDimAligned.GetTypeID: Integer;
begin
  Result := ID_DIMALIGNED;
end;

function TUdDimAligned.GetDimTypeID: Integer;
begin
  Result := 1;
end;



procedure TUdDimAligned.SetTextPoint(const AValue: TPoint2D);
begin
  if NotEqual(FTextPoint, AValue) and Self.RaiseBeforeModifyObject('TextPoint') then
  begin
    FTextPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('TextPoint');
  end;
end;



procedure TUdDimAligned.SetExtLinePoint(AIndex: Integer; const AValue: TPoint2D);
begin
  case AIndex of
    0:
    begin
      if NotEqual(FExtLine1Point, AValue) and Self.RaiseBeforeModifyObject('ExtLine1Point') then
      begin
        FExtLine1Point := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('ExtLine1Point');
      end;
    end;
    1:
    begin
      if NotEqual(FExtLine2Point, AValue) and Self.RaiseBeforeModifyObject('ExtLine2Point') then
      begin
        FExtLine2Point := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('ExtLine2Point');
      end;
    end;
  end;
end;


function TUdDimAligned.GetDimLine1Point(): TPoint2D;
begin
  Result := FDimLine1Point;
end;

function TUdDimAligned.GetDimLine2Point(): TPoint2D;
begin
  Result := FDimLine2Point;
end;




//---------------------------------------------------------------------------------


function TUdDimAligned.GetTextPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FTextPoint.X;
    1: Result := FTextPoint.Y;
  end;
end;

procedure TUdDimAligned.SetTextPointValue(AIndex: Integer; const AValue: Float);
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



function TUdDimAligned.GetExtLine1PointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine1Point.X;
    1: Result := FExtLine1Point.Y;
  end;
end;

procedure TUdDimAligned.SetExtLine1PointValue(AIndex: Integer; const AValue: Float);
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



function TUdDimAligned.GetExtLine2PointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine2Point.X;
    1: Result := FExtLine2Point.Y;
  end;
end;

procedure TUdDimAligned.SetExtLine2PointValue(AIndex: Integer; const AValue: Float);
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









procedure TUdDimAligned.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDimAligned) then Exit;

  FExtLine1Point := TUdDimAligned(AValue).FExtLine1Point;
  FExtLine2Point := TUdDimAligned(AValue).FExtLine2Point;

  FTextPoint     := TUdDimAligned(AValue).FTextPoint;

  if Self.ClassType = TUdDimAligned then Self.Update();
end;




//----------------------------------------------------------------------------------------

function TUdDimAligned.UpdateDimLines(ATextPnt: TPoint2D; ATextSide: Integer; ATextWidth: Float; AInctBound: Boolean; ATextBound: TPoint2DArray;
                                      ADimP1, ADimP2: TPoint2D): Boolean;
var
  I: Integer;
  LAng: Float;
  LPnt, LPnt1, LPnt2: TPoint2D;
  LInctPnts: TPoint2DArray;
  LDimEntities: TUdEntityArray;
begin
  Result := False;
  if FLinesProp.SuppressLine1 and FLinesProp.SuppressLine2 then Exit; //======>>>>

  LAng := GetAngle(ADimP1, ADimP2);

  LInctPnts := UdGeo2D.Intersection(Line2D(ADimP1, ADimP2), ATextBound);

  if AInctBound and (System.Length(LInctPnts) = 2) then
  begin
    LPnt1 := LInctPnts[0];
    LPnt2 := LInctPnts[1];
    if NotEqual(LAng, GetAngle(LPnt1, LPnt2), 1) then Swap(LPnt1, LPnt2);
  end
  else begin
    LPnt1 := ShiftPoint(ATextPnt, LAng, -(ATextWidth/2));
    LPnt2 := ShiftPoint(ATextPnt, LAng, +(ATextWidth/2));
  end;


  LDimEntities := nil;

  if ATextSide = 0 then
  begin
    if FLinesProp.SuppressLine1 then
    begin
      if AInctBound then
        LPnt := LPnt2
      else
        LPnt := LPnt1;//ShiftPoint(ATextPnt, LAng, -(ATextWidth/2));

      LDimEntities := CreateDimLineWithArrow(ADimP2, LPnt, TUdArrowStyle(FArrowsProp.ArrowSecond), asNone);
      for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);
    end else
    if FLinesProp.SuppressLine2 then
    begin
      if AInctBound then
        LPnt := LPnt1
      else
        LPnt := LPnt2; //ShiftPoint(ATextPnt, LAng, +(ATextWidth/2));

      LDimEntities := CreateDimLineWithArrow(ADimP1, LPnt, TUdArrowStyle(FArrowsProp.ArrowFirst), asNone);
      for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);
    end
    else begin
      if AInctBound then
      begin
        LDimEntities := CreateDimLineWithArrow(ADimP1, LPnt1, TUdArrowStyle(FArrowsProp.ArrowFirst), asNone);
        for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);

        LDimEntities := CreateDimLineWithArrow(ADimP2, LPnt2, TUdArrowStyle(FArrowsProp.ArrowSecond), asNone);
        for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);
      end
      else begin
        LDimEntities := CreateDimLineWithArrow(ADimP1, ADimP2, TUdArrowStyle(FArrowsProp.ArrowFirst), TUdArrowStyle(FArrowsProp.ArrowSecond));
        for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);
      end;
    end;
  end else

  if ATextSide = 1 then
  begin
    LDimEntities := nil;

    if FLinesProp.SuppressLine1 then
    begin
      LDimEntities := CreateDimLineWithArrow(ADimP2, ADimP1, TUdArrowStyle(FArrowsProp.ArrowSecond), asNone);
    end else
    if FLinesProp.SuppressLine2 then
    begin
      LPnt := ShiftPoint(ADimP1, LAng, FArrowsProp.ArrowSize*2);
      LDimEntities := CreateDimLineWithArrow(ADimP1, LPnt, TUdArrowStyle(FArrowsProp.ArrowFirst), asNone);
    end
    else begin
      LDimEntities := CreateDimLineWithArrow(ADimP1, ADimP2, TUdArrowStyle(FArrowsProp.ArrowFirst), TUdArrowStyle(FArrowsProp.ArrowSecond));
    end;

    for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);

    LPnt := LPnt1;
//    if AInctBound then
//      LPnt := ShiftPoint(ATextPnt, LAng, +(ATextWidth/2) )
//    else
//      LPnt := ShiftPoint(ATextPnt, LAng, -(ATextWidth/2) );

    FEntityList.Add( CreateDimLine(ADimP1, LPnt, False) );
  end else

  if ATextSide = 2 then
  begin
    LDimEntities := nil;
    if FLinesProp.SuppressLine1 then
    begin
      LPnt := ShiftPoint(ADimP2, FixAngle(LAng + 180), FArrowsProp.ArrowSize*2);
      LDimEntities := CreateDimLineWithArrow(ADimP2, LPnt, TUdArrowStyle(FArrowsProp.ArrowSecond), asNone);
    end else
    if FLinesProp.SuppressLine2 then
    begin
      LDimEntities := CreateDimLineWithArrow(ADimP1, ADimP2, TUdArrowStyle(FArrowsProp.ArrowFirst), asNone);
    end
    else begin
      LDimEntities := CreateDimLineWithArrow(ADimP1, ADimP2, TUdArrowStyle(FArrowsProp.ArrowFirst), TUdArrowStyle(FArrowsProp.ArrowSecond));
    end;

    for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);


    LPnt := LPnt2;
//    if AInctBound then
//      LPnt := ShiftPoint(ATextPnt, LAng, -(ATextWidth/2) )
//    else
//      LPnt := ShiftPoint(ATextPnt, LAng, +(ATextWidth/2) );

    FEntityList.Add(  CreateDimLine(ADimP2, LPnt, False) );
  end;

  Result := True;
end;



function TUdDimAligned.GetRotation(): Float;
begin
  Result := GetAngle(FExtLine1Point, FExtLine2Point);
end;

function TUdDimAligned.GetDimLinePnts(var ADimP1, ADimP2: TPoint2D): Boolean;
var
  LDimLn: TLineK;
begin
  LDimLn := LineK(FTextPoint, GetRotation());

  ADimP1 := UdGeo2D.ClosestLinePoint(FExtLine1Point, LDimLn);
  ADimP2 := UdGeo2D.ClosestLinePoint(FExtLine2Point, LDimLn);

  Result := True;
end;


function TUdDimAligned.UpdateDim(AAxes: TUdAxes): Boolean;
var
  I: Integer;
  LLn: TLineK;
  LPnt: TPoint2D;
  LTextPnt: TPoint2D;
  LTextEnt: TUdText;
  LTextSide: Integer;
  LInctBound: Boolean;
  LInctPnts: TPoint2DArray;
  LTextWidth, LTextAngle, LAngle: Float;
  LDimEntities: TUdEntityArray;
  LUserAngled: Boolean;
  LOverallScale: Float;
begin
  ClearObjectList(FEntityList);

  Self.GetDimLinePnts(FDimLine1Point, FDimLine2Point);

  LAngle := Self.GetRotation();
  if NotEqual(GetAngle(FDimLine1Point, FDimLine2Point), LAngle, 1.0) then LAngle := FixAngle(LAngle + 180.0);

  FMeasurement := Distance(FDimLine2Point, FDimLine1Point);


  if FTextProp.InsideAlign then LTextAngle := LAngle else LTextAngle := 0.0;
  LUserAngled := TextAngleValid(LTextAngle);


  LOverallScale := 1.0;
  if Assigned(FDimStyle) then LOverallScale := FDimStyle.OverallScale;

  //-------------------------------------------

  LTextEnt := TUdText.Create(Self.Document, False);

  LTextEnt.BeginUpdate();
  try
    LTextEnt.Owner := Self;
    LTextEnt.Alignment := taMiddleCenter;
    if Assigned(Self.TextStyles) then
      LTextEnt.TextStyle := Self.TextStyles.GetItem(FTextProp.TextStyle);
    LTextEnt.Height := FTextProp.TextHeight * LOverallScale;
    LTextEnt.Color.Assign(FTextProp.TextColor);
    LTextEnt.DrawFrame := FTextProp.DrawFrame;
    LTextEnt.FillColor := FTextProp.FillColor;


    LTextEnt.Contents := GetDimText(FMeasurement, dtkNormal);
  finally
    LTextEnt.EndUpdate();
  end;

  LTextWidth := LTextEnt.TextWidth + (FTextProp.TextHeight * TEXT_BOUND_OFFSET_FACTOR) * 2;

  if LUserAngled then
  begin
    LTextEnt.Rotation := LTextAngle;

    LLn := LineK(LTextEnt.Position, LTextAngle);
    LInctPnts := UdGeo2D.Intersection(LLn, LTextEnt.TextBound);
    if System.Length(LInctPnts) < 2 then FTextAngle := -1
    else begin
      if System.Length(LInctPnts) > 2 then
        UdGeo2D.SortPoints(LInctPnts, LefterPoint(LTextEnt.TextBound));
      LTextWidth := Distance(LInctPnts[0], LInctPnts[High(LInctPnts)]);
    end;
  end;



  FEntityList.Add(LTextEnt);

  //-------------------------------------------

  LTextPnt := FTextPoint;

  case FTextProp.HorizontalPosition of
    htpCentered           : LTextPnt := MidPoint(FDimLine1Point, FDimLine2Point);
    htpFirstExtensionLine : LTextPnt := ShiftPoint(FDimLine1Point, LAngle, (LTextWidth / 2 + FArrowsProp.ArrowSize));
    htpSecondExtensionLine: LTextPnt := ShiftPoint(FDimLine2Point, FixAngle(LAngle + 180), (LTextWidth / 2 + FArrowsProp.ArrowSize));
  end;


  LTextSide := 0;

  if not Assigned(FDimStyle) or (Assigned(FDimStyle) and FDimStyle.BestFit) then
  begin
    if LTextWidth >= FMeasurement * 1.2 then
    begin
      LPnt := ClosestLinePoint(FTextPoint, Line2D(FDimLine1Point, FDimLine2Point));
      if IsEqual(LAngle, GetAngle(MidPoint(FDimLine1Point, FDimLine2Point), LPnt), 5) then
      begin
        LTextPnt := ShiftPoint(FDimLine2Point, LAngle, (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 );
        LTextSide := 2;
      end
      else begin
        LTextPnt := ShiftPoint(FDimLine1Point, LAngle+180, (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 );
        LTextSide := 1;
      end;
    end
    else begin
      if Distance(FDimLine1Point, LTextPnt) <= (LTextWidth / 2) then
      begin
        LTextPnt := ShiftPoint(FDimLine1Point, FixAngle(LAngle - 180), (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 );
        LTextSide := 1;
      end
      else if Distance(FDimLine2Point, LTextPnt) <= (LTextWidth / 2) then
      begin
        LTextPnt := ShiftPoint(FDimLine2Point, LAngle, (LTextWidth + DIM_TEXT_SIDE_OFFSET)/ 2 );
        LTextSide := 2;
      end
      else begin
        if not IsPntOnSegment(LTextPnt, Segment2D(FDimLine1Point, FDimLine2Point)) then
        begin
          if IsEqual(LAngle, GetAngle(FDimLine2Point, LTextPnt), 1) then
          begin
            LTextSide := 2;
            if Distance(FDimLine2Point, LTextPnt) <=  (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 then
              LTextPnt := ShiftPoint(FDimLine2Point, LAngle, (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 );
          end
          else begin
            LTextSide := 1;
            if Distance(FDimLine1Point, LTextPnt) <=  (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 then
              LTextPnt := ShiftPoint(FDimLine1Point, FixAngle(LAngle - 180), (LTextWidth + DIM_TEXT_SIDE_OFFSET) / 2 );
          end;
        end;
      end;
    end;
  end;

  //-------------------------------------------

  Self.UpdateInsideTextPosition(LTextEnt, LTextPnt, LAngle, False, LInctBound);

  Self.UpdateDimLines(LTextPnt, LTextSide, LTextWidth, LInctBound, LTextEnt.TextBound,  FDimLine1Point, FDimLine2Point);

  LDimEntities := Self.CreateExtLines(FExtLine1Point, FExtLine2Point, FDimLine1Point, FDimLine2Point);
  for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);

  FGripTextPnt := LTextPnt;
  Result := True;
end;





//----------------------------------------------------------------------------------------

function TUdDimAligned.GetGripPoints: TUdGripPointArray;
var
  N: Integer;
begin
  System.SetLength(Result, 5);

  Result[0] := MakeGripPoint(Self, gmPoint, 0, FGripTextPnt, 0);

  Result[1] := MakeGripPoint(Self, gmPoint, 1, FDimLine1Point, 0);
  Result[2] := MakeGripPoint(Self, gmPoint, 2, FDimLine2Point, 0);


  N := 3;
  if not IsEqual(FExtLine1Point, FDimLine1Point) then
  begin
    Result[N] := MakeGripPoint(Self, gmPoint, 3, FExtLine1Point, 0);
    N := N + 1;
  end;

  if not IsEqual(FExtLine1Point, FDimLine1Point) then
  begin
    Result[N] := MakeGripPoint(Self, gmPoint, 4, FExtLine2Point, 0);
    N := N + 1;
  end;

  if N <> System.Length(Result) then System.SetLength(Result, N);
end;


function TUdDimAligned.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  LLnK: TLineK;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    case AGripPnt.Index of
      0:
        begin
          Self.RaiseBeforeModifyObject('');

          FTextPoint := AGripPnt.Point;
          FTextProp.HorizontalPosition := htpCustom;
          Self.Update();

          Self.RaiseAfterModifyObject('');
        end;
      1, 2:
        begin
          Self.RaiseBeforeModifyObject('');

          LLnK := LineK(AGripPnt.Point, Self.GetRotation());
          FTextPoint := ClosestLinePoint(FTextPoint, LLnK);
          Self.Update();

          Self.RaiseAfterModifyObject('');
        end;
      3:
        begin
          if NotEqual(FExtLine1Point, AGripPnt.Point) then
          begin
            Self.RaiseBeforeModifyObject('');

            FExtLine1Point := AGripPnt.Point;
            Self.Update();

            Self.RaiseAfterModifyObject('');
          end;
        end;
      4:
        begin
          if NotEqual(FExtLine2Point, AGripPnt.Point) then
          begin
            Self.RaiseBeforeModifyObject('');

            FExtLine2Point := AGripPnt.Point;
            Self.Update();

            Self.RaiseAfterModifyObject('');
          end;
        end;
    end;
  end;
end;




//----------------------------------------------------------------------------------------

function TUdDimAligned.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FExtLine1Point := UdGeo2D.Translate(Dx, Dy, FExtLine1Point);
  FExtLine2Point := UdGeo2D.Translate(Dx, Dy, FExtLine2Point);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Translate(Dx, Dy, FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimAligned.Mirror(APnt1, APnt2: TPoint2D): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FExtLine1Point := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine1Point);
  FExtLine2Point := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine2Point);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimAligned.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FExtLine1Point := UdGeo2D.Rotate(ABase, ARota, FExtLine1Point);
  FExtLine2Point := UdGeo2D.Rotate(ABase, ARota, FExtLine2Point);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Rotate(ABase, ARota, FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimAligned.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FExtLine1Point := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine1Point);
  FExtLine2Point := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine2Point);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Scale(ABase, AFactor, AFactor, FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;



function TUdDimAligned.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdDimAligned;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdDimAligned.Create(Self.Document, False);

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      with LEntity do
      begin
        FExtLine1Point := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine1Point);
        FExtLine2Point := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine2Point);

        if IsValidPoint(Self.FTextPoint) then
          FTextPoint := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FTextPoint);
      end;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;



function TUdDimAligned.Intersect(AOther: TUdEntity): TPoint2DArray;
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

function TUdDimAligned.Perpend(APnt: TPoint2D): TPoint2DArray;
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

procedure TUdDimAligned.SaveToStream(AStream: TStream);
begin
  inherited;

  Point2DToStream(AStream, FExtLine1Point);
  Point2DToStream(AStream, FExtLine2Point);

  Point2DToStream(AStream, FTextPoint);
end;

procedure TUdDimAligned.LoadFromStream(AStream: TStream);
begin
  inherited;

  FExtLine1Point := Point2DFromStream(AStream);
  FExtLine2Point := Point2DFromStream(AStream);

  FTextPoint  := Point2DFromStream(AStream);

  if Self.ClassType = TUdDimAligned then Self.Update();
end;




procedure TUdDimAligned.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['ExtLine1Point']  := Point2DToStr(FExtLine1Point);
  LXmlNode.Prop['ExtLine2Point']  := Point2DToStr(FExtLine2Point);
  LXmlNode.Prop['TextPoint']      := Point2DToStr(FTextPoint);
end;

procedure TUdDimAligned.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FExtLine1Point := StrToPoint2D(LXmlNode.Prop['ExtLine1Point']);
  FExtLine2Point := StrToPoint2D(LXmlNode.Prop['ExtLine2Point']);
  FTextPoint     := StrToPoint2D(LXmlNode.Prop['TextPoint']);

  if Self.ClassType = TUdDimAligned then Self.Update();
end;



end.