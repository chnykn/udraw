{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimArcLength;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes, UdConsts, UdObject, UdAxes, UdEntity,
  UdColor, UdLineType, UdDimProps, UdDimension;


type
  //*** TUdDimArcLength ***//
  TUdDimArcLength = class(TUdDimension, IUdDimLineSupport)
  protected
    FCenterPoint  : TPoint2D;
    FExtLine1Point: TPoint2D;
    FExtLine2Point: TPoint2D;

    FArcPoint    : TPoint2D;
    FTextPoint   : TPoint2D;

    FShowLeader: Boolean;

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; override;

    procedure SetCenterPoint(const AValue: TPoint2D);
    procedure SetExtLine1Point(const AValue: TPoint2D);
    procedure SetExtLine2Point(const AValue: TPoint2D);

    procedure SetArcPoint(const AValue: TPoint2D);
    procedure SetTextPoint(const AValue: TPoint2D); override;
    procedure SetShowLeader(const AValue: Boolean);


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

    function UpdateByEntity(AEntity: TUdEntity): Boolean; override;

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
    property DimLine1Point : TPoint2D read GetDimLine1Point;
    property DimLine2Point : TPoint2D read GetDimLine2Point;

    property CenterPoint   : TPoint2D read FCenterPoint   write SetCenterPoint  ;
    property ExtLine1Point : TPoint2D read FExtLine1Point write SetExtLine1Point;
    property ExtLine2Point : TPoint2D read FExtLine2Point write SetExtLine2Point;

    property ArcPoint      : TPoint2D read FArcPoint    write SetArcPoint ;
    property TextPoint     : TPoint2D read FTextPoint   write SetTextPoint;

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

    property ShowLeader     : Boolean       read FShowLeader        write SetShowLeader;

  end;


  procedure FCreateDimLines(ADimObj: TUdDimension; ATextPnt: TPoint2D; ATextOutSide: Integer; ATextWidth: Float;
    AInctBound: Boolean; ATextBound: TPoint2DArray; ADimArc: TArc2D; var AReturnEntities: TUdEntityArray);


implementation


uses
  SysUtils, UdArc, UdText,
  UdMath, UdGeo2D, UdStreams, UdXml, UdUtils, UdStrConverter;


type
  TFDimension = class(TUdDimension);


//=================================================================================================


function _CreateArcObj(ADimObj: TUdDimension; AArc: TArc2D): TUdEntity;
var
  LArcObj: TUdArc;
begin
  LArcObj := TUdArc.Create(ADimObj.Document, False);
  LArcObj.Owner := ADimObj;
  LArcObj.Color.Assign(ADimObj.LinesProp.Color);
  LArcObj.LineType.Assign(ADimObj.LinesProp.LineType);
  LArcObj.LineWeight := ADimObj.LinesProp.LineWeight;
  LArcObj.XData := AArc;

  Result := LArcObj;
end;

procedure FCreateDimLines(ADimObj: TUdDimension; ATextPnt: TPoint2D; ATextOutSide: Integer; ATextWidth: Float;
  AInctBound: Boolean; ATextBound: TPoint2DArray; ADimArc: TArc2D; var AReturnEntities: TUdEntityArray);
var
  LArc: TArc2D;
  LAng: Float;
  LInctPnts: TPoint2DArray;
  LDimP1, LDimP2: TPoint2D;
  LPnt, LPnt1, LPnt2: TPoint2D;
begin
  AReturnEntities := nil;
  if ADimObj.LinesProp.SuppressLine1 and ADimObj.LinesProp.SuppressLine2 then Exit; //======>>>>

  LArc := ADimArc;
  LDimP1 := ShiftPoint(LArc.Cen, LArc.Ang1, LArc.R);
  LDimP2 := ShiftPoint(LArc.Cen, LArc.Ang2, LArc.R);

  LInctPnts := UdGeo2D.Intersection(LArc, ATextBound);
  if System.Length(LInctPnts) = 0 then AInctBound := False;

  if AInctBound and (System.Length(LInctPnts) = 2) then
  begin
    LPnt1 := LInctPnts[0];
    LPnt2 := LInctPnts[1];

    if FixAngle(GetAngle(LArc.Cen, LPnt1) - LArc.Ang1) >
       FixAngle(GetAngle(LArc.Cen, LPnt2) - LArc.Ang1) then Swap(LPnt1, LPnt2);
  end
  else begin
    LAng := GetAngle(LArc.Cen, ATextPnt) - LenToAng((ATextWidth/2), LArc.R); // ((ATextWidth/2) / (2 * Pi * LArc.R)) * 360;
    if not UdMath.IsInAngles(LAng, LArc.Ang1, LArc.Ang2) then LAng := LArc.Ang1;
    LPnt1 := ShiftPoint(LArc.Cen, LAng,  LArc.R);

    LAng := GetAngle(LArc.Cen, ATextPnt) + LenToAng((ATextWidth/2), LArc.R); // ((ATextWidth/2) / (2 * Pi * LArc.R)) * 360;
    if not UdMath.IsInAngles(LAng, LArc.Ang1, LArc.Ang2) then LAng := LArc.Ang2;
    LPnt2 := ShiftPoint(LArc.Cen, LAng,  LArc.R);
  end;


  if ATextOutSide = 0 then
  begin
    LInctPnts := UdGeo2D.Intersection(LArc, ATextBound);

    if ADimObj.LinesProp.SuppressLine1 then
    begin
      if AInctBound then
        LPnt := LPnt2
      else
        LPnt := LPnt1;

      System.SetLength(AReturnEntities, 1);
      AReturnEntities[0] := _CreateArcObj(ADimObj, Arc2D(LArc.Cen, LArc.R, GetAngle(LArc.Cen, LPnt), LArc.Ang2));

      LPnt := ShiftArcPoint(LArc, False, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP2, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowSecond), asNone)
        );

    end else
    if ADimObj.LinesProp.SuppressLine2 then
    begin
      if AInctBound then
        LPnt := LPnt1
      else
        LPnt := LPnt2;

      System.SetLength(AReturnEntities, 1);
      AReturnEntities[0] := _CreateArcObj(ADimObj, Arc2D(LArc.Cen, LArc.R, LArc.Ang1, GetAngle(LArc.Cen, LPnt) ));

      LPnt := ShiftArcPoint(LArc, True, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP1, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowFirst), asNone)
      );
    end
    else begin
      if AInctBound then
      begin
        System.SetLength(AReturnEntities, 2);

        AReturnEntities[0] := _CreateArcObj(ADimObj, Arc2D(LArc.Cen, LArc.R, LArc.Ang1, GetAngle(LArc.Cen, LPnt1)) );
        AReturnEntities[1] := _CreateArcObj(ADimObj, Arc2D(LArc.Cen, LArc.R, GetAngle(LArc.Cen, LPnt2), LArc.Ang2) );

        LPnt := ShiftArcPoint(LArc, True, -ADimObj.ArrowsProp.ArrowSize);
        AddEntityArray(
          AReturnEntities,
          TFDimension(ADimObj).CreateDimLineWithArrow(LDimP1, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowFirst), asNone)
        );

        LPnt := ShiftArcPoint(LArc, False, -ADimObj.ArrowsProp.ArrowSize);
        AddEntityArray(
          AReturnEntities,
          TFDimension(ADimObj).CreateDimLineWithArrow(LDimP2, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowSecond), asNone)
        );
      end
      else begin
        System.SetLength(AReturnEntities, 1);
        AReturnEntities[0] := _CreateArcObj(ADimObj, LArc);

        LPnt := ShiftArcPoint(LArc, True, -ADimObj.ArrowsProp.ArrowSize);
        AddEntityArray(
          AReturnEntities,
          TFDimension(ADimObj).CreateDimLineWithArrow(LDimP1, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowFirst), asNone)
        );

        LPnt := ShiftArcPoint(LArc, False, -ADimObj.ArrowsProp.ArrowSize);
        AddEntityArray(
          AReturnEntities,
          TFDimension(ADimObj).CreateDimLineWithArrow(LDimP2, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowSecond), asNone)
        );
      end;
    end;

  end else

  if ATextOutSide = 1 then
  begin
    if ADimObj.LinesProp.SuppressLine1 then
    begin
      System.SetLength(AReturnEntities, 1);

      LAng := LArc.Ang1 + LenToAng(ADimObj.ArrowsProp.ArrowSize, LArc.R);
      if not UdMath.IsInAngles(LAng, LArc.Ang1, LArc.Ang2) then LAng := LArc.Ang1;
      AReturnEntities[0] := _CreateArcObj(ADimObj, Arc2D(LArc.Cen, LArc.R, LAng, LArc.Ang2) );

      LPnt := ShiftArcPoint(LArc, False, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP2, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowSecond), asNone)
      );
    end else
    if ADimObj.LinesProp.SuppressLine2 then
    begin
      System.SetLength(AReturnEntities, 1);

      LAng := LArc.Ang1 + LenToAng(ADimObj.ArrowsProp.ArrowSize * 2, LArc.R);
      if not UdMath.IsInAngles(LAng, LArc.Ang1, LArc.Ang2) then LAng := LArc.Ang2;
      AReturnEntities[0] := _CreateArcObj(ADimObj, Arc2D(LArc.Cen, LArc.R, LArc.Ang1, LAng) );

      LPnt := ShiftArcPoint(LArc, True, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP1, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowFirst), asNone)
      );
    end
    else begin
      System.SetLength(AReturnEntities, 1);
      AReturnEntities[0] := _CreateArcObj(ADimObj, LArc);

      LPnt := ShiftArcPoint(LArc, True, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP1, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowFirst), asNone)
      );

      LPnt := ShiftArcPoint(LArc, False, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP2, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowSecond), asNone)
      );
    end;

  end else

  if ATextOutSide = 2 then
  begin
    if ADimObj.LinesProp.SuppressLine1 then
    begin
      System.SetLength(AReturnEntities, 1);

      LAng := LArc.Ang2 - LenToAng(ADimObj.ArrowsProp.ArrowSize * 2, LArc.R);
      if not UdMath.IsInAngles(LAng, LArc.Ang1, LArc.Ang2) then LAng := LArc.Ang1;
      AReturnEntities[0] := _CreateArcObj(ADimObj, Arc2D(LArc.Cen, LArc.R, LAng, LArc.Ang2) );

      LPnt := ShiftArcPoint(LArc, False, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP2, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowSecond), asNone)
      );
    end else
    if ADimObj.LinesProp.SuppressLine2 then
    begin
      System.SetLength(AReturnEntities, 1);

      LAng := LArc.Ang1 + LenToAng(ADimObj.ArrowsProp.ArrowSize * 2, LArc.R);
      if not UdMath.IsInAngles(LAng, LArc.Ang1, LArc.Ang2) then LAng := LArc.Ang2;
      AReturnEntities[0] := _CreateArcObj(ADimObj, Arc2D(LArc.Cen, LArc.R, LArc.Ang1, LAng) );

      LPnt := ShiftArcPoint(LArc, True, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP1, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowFirst), asNone)
      );
    end
    else begin
      System.SetLength(AReturnEntities, 1);

      AReturnEntities[0] := _CreateArcObj(ADimObj, LArc);

      LPnt := ShiftArcPoint(LArc, True, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP1, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowFirst), asNone)
      );

      LPnt := ShiftArcPoint(LArc, False, -ADimObj.ArrowsProp.ArrowSize);
      AddEntityArray(
        AReturnEntities,
        TFDimension(ADimObj).CreateDimLineWithArrow(LDimP2, LPnt, TUdArrowStyle(ADimObj.ArrowsProp.ArrowSecond), asNone)
      );
    end;
  end;

end;



//=================================================================================================
{ TUdDimArcLength }

constructor TUdDimArcLength.Create();
begin
  inherited;

  FCenterPoint   := Point2D(0, 0);
  FExtLine1Point := Point2D(0, 0);
  FExtLine2Point := Point2D(0, 0);

  FArcPoint      := Point2D(0, 0);
  FTextPoint     := Point2D(0, 0);
  FShowLeader    := False;
end;

destructor TUdDimArcLength.Destroy;
begin

  inherited;
end;


function TUdDimArcLength.GetTypeID: Integer;
begin
  Result := ID_DIMARCLENGTH;
end;

function TUdDimArcLength.GetDimTypeID: Integer;
begin
  Result := 8;
end;



//----------------------------------------------------------------------------------------

procedure TUdDimArcLength.SetCenterPoint(const AValue: TPoint2D);
begin
  if NotEqual(FCenterPoint, AValue) and Self.RaiseBeforeModifyObject('CenterPoint') then
  begin
    FCenterPoint:= AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('CenterPoint');
  end;
end;

procedure TUdDimArcLength.SetExtLine1Point(const AValue: TPoint2D);
begin
  if NotEqual(FExtLine1Point, AValue) and Self.RaiseBeforeModifyObject('ExtLine1Point') then
  begin
    FExtLine1Point := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLine1Point');
  end;
end;


procedure TUdDimArcLength.SetExtLine2Point(const AValue: TPoint2D);
begin
  if NotEqual(FExtLine2Point, AValue) and Self.RaiseBeforeModifyObject('ExtLine2Point') then
  begin
    FExtLine2Point := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLine2Point');
  end;
end;

procedure TUdDimArcLength.SetArcPoint(const AValue: TPoint2D);
begin
  if NotEqual(FArcPoint, AValue) and Self.RaiseBeforeModifyObject('ArcPoint') then
  begin
    FArcPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ArcPoint');
  end;
end;



procedure TUdDimArcLength.SetTextPoint(const AValue: TPoint2D);
begin
  if NotEqual(FTextPoint, AValue) and Self.RaiseBeforeModifyObject('TextPoint') then
  begin
    FTextPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('TextPoint');
  end;
end;


procedure TUdDimArcLength.SetShowLeader(const AValue: Boolean);
begin
  if (FShowLeader <> AValue) and Self.RaiseBeforeModifyObject('ShowLeader') then
  begin
    FShowLeader := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ShowLeader');
  end;
end;



function TUdDimArcLength.GetDimLine1Point: TPoint2D;
var
  LAng, LRad: Float;
  LAng1, LAng2: Float;
begin
  LRad := Distance(FCenterPoint, FArcPoint);
  LAng1 := GetAngle(FCenterPoint, FExtLine1Point);
  LAng2 := GetAngle(FCenterPoint, FExtLine2Point);

  LAng := GetAngle(FCenterPoint, FArcPoint);

  if UdMath.IsInAngles(LAng, LAng1, LAng2) then
    Result := ShiftPoint(FCenterPoint, LAng1, LRad)
  else
    Result := ShiftPoint(FCenterPoint, LAng2, LRad)
end;

function TUdDimArcLength.GetDimLine2Point: TPoint2D;
var
  LAng, LRad: Float;
  LAng1, LAng2: Float;
begin
  LRad := Distance(FCenterPoint, FArcPoint);
  LAng1 := GetAngle(FCenterPoint, FExtLine1Point);
  LAng2 := GetAngle(FCenterPoint, FExtLine2Point);

  LAng := GetAngle(FCenterPoint, FArcPoint);

  if UdMath.IsInAngles(LAng, LAng1, LAng2) then
    Result := ShiftPoint(FCenterPoint, LAng2, LRad)
  else
    Result := ShiftPoint(FCenterPoint, LAng1, LRad)
end;






function TUdDimArcLength.GetCenterPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FCenterPoint.X;
    1: Result := FCenterPoint.Y;
  end;
end;

procedure TUdDimArcLength.SetCenterPointValue(AIndex: Integer; const AValue: Float);
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


function TUdDimArcLength.GetExtLine1PointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine1Point.X;
    1: Result := FExtLine1Point.Y;
  end;
end;

procedure TUdDimArcLength.SetExtLine1PointValue(AIndex: Integer; const AValue: Float);
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


function TUdDimArcLength.GetExtLine2PointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FExtLine2Point.X;
    1: Result := FExtLine2Point.Y;
  end;
end;

procedure TUdDimArcLength.SetExtLine2PointValue(AIndex: Integer; const AValue: Float);
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


function TUdDimArcLength.GetArcPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FArcPoint.X;
    1: Result := FArcPoint.Y;
  end;
end;

procedure TUdDimArcLength.SetArcPointValue(AIndex: Integer; const AValue: Float);
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


function TUdDimArcLength.GetTextPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FTextPoint.X;
    1: Result := FTextPoint.Y;
  end;
end;

procedure TUdDimArcLength.SetTextPointValue(AIndex: Integer; const AValue: Float);
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




procedure TUdDimArcLength.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDimArcLength) then Exit;

  FCenterPoint   := TUdDimArcLength(AValue).FCenterPoint    ;
  FExtLine1Point := TUdDimArcLength(AValue).FExtLine1Point ;
  FExtLine2Point := TUdDimArcLength(AValue).FExtLine2Point;

  FArcPoint       := TUdDimArcLength(AValue).FArcPoint      ;
  FTextPoint   := TUdDimArcLength(AValue).FTextPoint;

  Self.Update();
end;




//----------------------------------------------------------------------------------------

function TUdDimArcLength.UpdateDim(AAxes: TUdAxes): Boolean;
var
  I: Integer;
  LDimArc: TArc2D;
  LTextEnt: TUdText;
  LInctBound: Boolean;
  LTextOutSide: Integer;
  LExtRad, LDimRad: Float;
  LAng1, LAng2, LAngP: Float;
  LTextWidth, LTextAngle, LRadAngle: Float;
  LExtP1, LExtP2, LDimP1, LDimP2, LTextPnt: TPoint2D;
  LDimEntities: TUdEntityArray;
  LOverallScale: Float;
begin
  ClearObjectList(FEntityList);

  LAng1 := GetAngle(FCenterPoint, FExtLine1Point);
  LAng2 := GetAngle(FCenterPoint, FExtLine2Point);
  LAngP := GetAngle(FCenterPoint, FArcPoint);

  LExtRad := Distance(FCenterPoint, FExtLine1Point);
  LDimRad := Distance(FCenterPoint, FArcPoint);

  FMeasurement := (FixAngle(LAng2 - LAng1) / 360.0) * (2* PI * LExtRad);

  LExtP1 := FExtLine1Point;
  LExtP2 := FExtLine2Point;

  LDimP1 := ShiftPoint(FCenterPoint, LAng1, LDimRad);
  LDimP2 := ShiftPoint(FCenterPoint, LAng2, LDimRad);

  if not UdMath.IsInAngles(LAngP, LAng1, LAng2) then
  begin
    Swap(LAng1, LAng2);
    Swap(LDimP1, LDimP2);
    Swap(LExtP1, LExtP2);
  end;

  LDimArc := Arc2D(FCenterPoint, LDimRad, LAng1, LAng2);


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

    LTextEnt.Contents := GetDimText(FMeasurement, dtkArcLen);
  finally
    LTextEnt.EndUpdate();
  end;

  LTextWidth := LTextEnt.TextWidth + (FTextProp.TextHeight * TEXT_BOUND_OFFSET_FACTOR) * 2;
  FEntityList.Add(LTextEnt);


  //---------------------------------------------------

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
      LRadAngle := GetAngle(FCenterPoint, LTextPnt);

      if not UdMath.IsInAngles(LRadAngle, LDimArc.Ang1, LDimArc.Ang2) then
      begin
        if FixAngle(LDimArc.Ang1 - LRadAngle) <  FixAngle(LRadAngle - LDimArc.Ang2) then
          LTextOutSide := 1
        else
          LTextOutSide := 2;
      end;

      LTextAngle := FixAngle(GetAngle(FCenterPoint, LTextPnt) + 90.0);
    end;
  end
  else
    LTextAngle := FixAngle(GetAngle(FCenterPoint, LTextPnt) + 90.0);


  if FTextAngle >= 0.0 then
  begin
    UpdateTextPosition(LTextEnt, False, LTextPnt, FTextAngle);
    LInctBound := True;
  end
  else
    UpdateInsideTextPosition(LTextEnt, LTextPnt, LTextAngle, False, LInctBound);


  if FShowLeader and (LTextOutSide = 0) and (LDimRad - LExtRad > FArrowsProp.ArrowSize) then
  begin
    LRadAngle := GetAngle(FCenterPoint, LTextPnt);

    LDimEntities := Self.CreateDimLineWithArrow(ShiftPoint(FCenterPoint, LRadAngle, LDimRad),
                            ShiftPoint(FCenterPoint, LRadAngle, LExtRad),
                            asNone, TUdArrowStyle(FArrowsProp.ArrowLeader));
    for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);
  end;

  //---------------------------------------------------

  FCreateDimLines(Self, LTextPnt, LTextOutSide, LTextWidth, LInctBound, LTextEnt.TextBound, LDimArc, LDimEntities);
  for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);

  LDimEntities := Self.CreateExtLines(LExtP1, LExtP2, LDimP1, LDimP2);
  for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);


  //---------------------------------------------------

  Result := True;
end;


function TUdDimArcLength.UpdateByEntity(AEntity: TUdEntity): Boolean;
begin
  Result := False;
end;







//----------------------------------------------------------------------------------------

function TUdDimArcLength.GetGripPoints: TUdGripPointArray;
begin
  System.SetLength(Result, 5);

  Result[0] := MakeGripPoint(Self, gmPoint, 0, FCenterPoint, 0);
  Result[1] := MakeGripPoint(Self, gmPoint, 1, FExtLine1Point, 0);
  Result[2] := MakeGripPoint(Self, gmPoint, 2, FExtLine2Point, 0);
  Result[3] := MakeGripPoint(Self, gmPoint, 3, FArcPoint, 0);
  Result[4] := MakeGripPoint(Self, gmPoint, 4, FGripTextPnt, 0);
end;


function TUdDimArcLength.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
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

function TUdDimArcLength.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenterPoint:= UdGeo2D.Translate(Dx, Dy, FCenterPoint);
  FExtLine1Point := UdGeo2D.Translate(Dx, Dy, FExtLine1Point);
  FExtLine2Point := UdGeo2D.Translate(Dx, Dy, FExtLine2Point);

  FArcPoint := UdGeo2D.Translate(Dx, Dy, FArcPoint);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Translate(Dx, Dy, FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimArcLength.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LPnt1, LPnt2: TPoint2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>


  Self.RaiseBeforeModifyObject('');

  LPnt1 := FExtLine1Point;
  LPnt2 := FExtLine2Point;

  FCenterPoint:= UdGeo2D.Mirror(Line2D(APnt1, APnt2), FCenterPoint);
  FExtLine2Point := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LPnt1);
  FExtLine1Point := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LPnt2);

  FArcPoint := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FArcPoint);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimArcLength.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenterPoint:= UdGeo2D.Rotate(ABase, ARota, FCenterPoint);
  FExtLine1Point := UdGeo2D.Rotate(ABase, ARota, FExtLine1Point);
  FExtLine2Point := UdGeo2D.Rotate(ABase, ARota, FExtLine2Point);

  FArcPoint := UdGeo2D.Rotate(ABase, ARota, FArcPoint);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Rotate(ABase, ARota, FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimArcLength.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenterPoint:= UdGeo2D.Scale(ABase, AFactor, AFactor, FCenterPoint);
  FExtLine1Point := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine1Point);
  FExtLine2Point := UdGeo2D.Scale(ABase, AFactor, AFactor, FExtLine2Point);

  FArcPoint := UdGeo2D.Scale(ABase, AFactor, AFactor, FArcPoint);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Scale(ABase, AFactor, AFactor, FTextPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;



function TUdDimArcLength.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdDimArcLength;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdDimArcLength.Create(Self.Document, False);

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      with LEntity do
      begin
        FCenterPoint   := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FCenterPoint);
        FExtLine1Point := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine1Point);
        FExtLine2Point := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FExtLine2Point);

        FArcPoint := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FArcPoint);

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




function TUdDimArcLength.Intersect(AOther: TUdEntity): TPoint2DArray;
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

function TUdDimArcLength.Perpend(APnt: TPoint2D): TPoint2DArray;
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


procedure TUdDimArcLength.SaveToStream(AStream: TStream);
begin
  inherited;

  Point2DToStream(AStream, FCenterPoint    );
  Point2DToStream(AStream, FExtLine1Point );
  Point2DToStream(AStream, FExtLine2Point);

  Point2DToStream(AStream, FArcPoint      );
  Point2DToStream(AStream, FTextPoint);

  BoolToStream(AStream, FShowLeader);
end;

procedure TUdDimArcLength.LoadFromStream(AStream: TStream);
begin
  inherited;

  FCenterPoint   := Point2DFromStream(AStream);
  FExtLine1Point := Point2DFromStream(AStream);
  FExtLine2Point := Point2DFromStream(AStream);

  FArcPoint      := Point2DFromStream(AStream);
  FTextPoint     := Point2DFromStream(AStream);

  FShowLeader    := BoolFromStream(AStream);

  Self.Update();
end;





procedure TUdDimArcLength.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
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

  LXmlNode.Prop['ShowLeader']     := BoolToStr(FShowLeader, True);
end;

procedure TUdDimArcLength.LoadFromXml(AXmlNode: TObject);
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

  FShowLeader    := StrToBoolDef(LXmlNode.Prop['ShowLeader'], False);

  Self.Update();
end;

end.