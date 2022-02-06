                     {
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimRadial;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes, UdConsts, UdObject, UdAxes, UdEntity,
  UdColor, UdDimProps, UdDimension;


type
  //*** TUdDimRadial ***//
  TUdDimRadial = class(TUdDimension)
  protected
    FCenter     : TPoint2D;
    FChordPoint : TPoint2D;
    FLeaderLen  : Float;

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; override;

    procedure SetTextPoint(const AValue: TPoint2D); override;

    procedure SetCenter(const AValue: TPoint2D);
    procedure SetChordPoint(const AValue: TPoint2D);
    procedure SetLeaderLen(const AValue: Float);

    function GetCenterValue(AIndex: Integer): Float;
    procedure SetCenterValue(AIndex: Integer; const AValue: Float);

    function GetChordPointValue(AIndex: Integer): Float;
    procedure SetChordPointValue(AIndex: Integer; const AValue: Float);


    function IsDiametric(): Boolean; virtual;
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

  published
    property CenterX    : Float index 0 read GetCenterValue  write SetCenterValue;
    property CenterY    : Float index 1 read GetCenterValue  write SetCenterValue;

    property ChordPointX: Float index 0 read GetChordPointValue write SetChordPointValue;
    property ChordPointY: Float index 1 read GetChordPointValue write SetChordPointValue;

    property LeaderLen  : Float    read FLeaderLen  write SetLeaderLen ;

  end;


implementation


uses
  SysUtils, UdText,
  UdMath, UdGeo2D, UdStreams, UdXml, UdUtils, UdStrConverter;



//=================================================================================================
{ TUdDimRadial }

constructor TUdDimRadial.Create();
begin
  inherited;

  FCenter     := Point2D(0, 0);
  FChordPoint := Point2D(0, 0);
  FLeaderLen  := 0;
end;

destructor TUdDimRadial.Destroy;
begin

  inherited;
end;


function TUdDimRadial.GetTypeID: Integer;
begin
  Result := ID_DIMRADIAL;
end;


function TUdDimRadial.GetDimTypeID: Integer;
begin
  Result := 4;
end;



//--------------------------------------------------------------------------------------------

procedure TUdDimRadial.SetTextPoint(const AValue: TPoint2D);
var
  LPnt: TPoint2D;
  LCir: TCircle2D;
begin
  LPnt := ClosestLinePoint(AValue, Line2D(FCenter, FChordPoint));
  LCir := Circle2D(FCenter, Distance(FCenter, FChordPoint) );

  if UdGeo2D.IsPntOnCircle(LPnt, LCir) then
  begin
    FLeaderLen := -5;
  end
  else begin
    if UdGeo2D.IsPntInCircle(LPnt, LCir) then
      FLeaderLen := -Distance(FChordPoint, LPnt)
    else
      FLeaderLen := +Distance(FChordPoint, LPnt);
  end;

  Self.Update();
end;


procedure TUdDimRadial.SetCenter(const AValue: TPoint2D);
begin
  if NotEqual(FCenter, AValue) and Self.RaiseBeforeModifyObject('Center') then
  begin
    FCenter := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Center');
  end;
end;

procedure TUdDimRadial.SetChordPoint(const AValue: TPoint2D);
begin
  if NotEqual(FChordPoint, AValue) and Self.RaiseBeforeModifyObject('ChordPoint') then
  begin
    FChordPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ChordPoint');
  end;
end;

procedure TUdDimRadial.SetLeaderLen(const AValue: Float);
begin
  if NotEqual(FLeaderLen, AValue) and Self.RaiseBeforeModifyObject('LeaderLen') then
  begin
    FLeaderLen := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('LeaderLen');
  end;
end;




function TUdDimRadial.GetCenterValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FCenter.X;
    1: Result := FCenter.Y;
  end;
end;

procedure TUdDimRadial.SetCenterValue(AIndex: Integer; const AValue: Float);
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


function TUdDimRadial.GetChordPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FChordPoint.X;
    1: Result := FChordPoint.Y;
  end;
end;

procedure TUdDimRadial.SetChordPointValue(AIndex: Integer; const AValue: Float);
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



procedure TUdDimRadial.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDimRadial) then Exit;

  FCenter     := TUdDimRadial(AValue).FCenter;
  FChordPoint := TUdDimRadial(AValue).FChordPoint;
  FLeaderLen  := TUdDimRadial(AValue).FLeaderLen;

  Self.Update();
end;





//----------------------------------------------------------------------------------------

function TUdDimRadial.IsDiametric(): Boolean;
begin
  Result := False;
end;


function TUdDimRadial.UpdateDim(AAxes: TUdAxes): Boolean;
var
  I: Integer;
  LLn: TLineK;
  LDimPnt: TPoint2D;
  LLineEnt: TUdEntity;
  LTextPnt: TPoint2D;
  LTextEnt: TUdText;
  LAngle, LRadius: Float;
  LLeaderLen, LTextWidth: Float;
  LInctPnts: TPoint2DArray;
  LInctBound: Boolean;
  LOverallScale: Float;
  LDimEntities: TUdEntityArray;
begin
  ClearObjectList(FEntityList);

  LRadius := Distance(FCenter, FChordPoint);

  if Self.IsDiametric() then FMeasurement := LRadius * 2 else FMeasurement := LRadius;

  if FLeaderLen > 0 then
  begin
    if Self.IsDiametric() then
      LLineEnt := Self.CreateDimLine(ShiftPoint(FCenter, GetAngle(FChordPoint, FCenter), LRadius), FChordPoint, False)
    else
      LLineEnt := Self.CreateDimLine(FCenter, FChordPoint, False);

    FEntityList.Add(LLineEnt);
  end;


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

    if Self.IsDiametric() then
      LTextEnt.Contents := GetDimText(FMeasurement, dtkDiameter)
    else
      LTextEnt.Contents := GetDimText(FMeasurement, dtkRaidus);
  finally
    LTextEnt.EndUpdate();
  end;
  
  LTextWidth := LTextEnt.TextWidth + (FTextProp.TextHeight * TEXT_BOUND_OFFSET_FACTOR) * 2;
  FEntityList.Add(LTextEnt);


  //----------------------------------------------------

  LAngle := GetAngle(FCenter, FChordPoint);
  LLeaderLen := Abs(FLeaderLen);

  if FLeaderLen < 0 then
  begin
    LAngle := FixAngle(LAngle + 180);
    while LLeaderLen > LRadius * 2 do LLeaderLen := LLeaderLen - LRadius * 2;
    if LLeaderLen > LRadius then LLeaderLen := LRadius * 2 - LLeaderLen;
  end;

  if FTextProp.OutsideAlign and (FTextAngle < 0)  then
  begin
    if LLeaderLen <= ((LTextWidth / 2) + FArrowsProp.ArrowSize) then
      LLeaderLen := ((LTextWidth / 2) + FArrowsProp.ArrowSize);

    if FTextProp.VerticalPosition = vtpCentered then
      LDimPnt := ShiftPoint(FChordPoint, LAngle, LLeaderLen - (LTextWidth / 2))
    else
      LDimPnt := ShiftPoint(FChordPoint, LAngle, LLeaderLen + (LTextWidth / 2));

    LDimEntities := Self.CreateDimLineWithArrow(LDimPnt, FChordPoint, asNone, TUdArrowStyle(FArrowsProp.ArrowLeader));
    for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);

    LTextPnt := ShiftPoint(FChordPoint, LAngle, LLeaderLen);
  end
  else begin
    LDimPnt := ShiftPoint(FChordPoint, LAngle, LLeaderLen);

    LDimEntities := Self.CreateDimLineWithArrow(LDimPnt, FChordPoint, asNone, TUdArrowStyle(FArrowsProp.ArrowLeader));
    for I := 0 to System.Length(LDimEntities) - 1 do FEntityList.Add(LDimEntities[I]);

    if (LAngle > 90.0) and (LAngle <= 270.0) then LAngle := 180 else LAngle := 0;


    if FTextAngle >= 0.0 then
    begin
      LTextEnt.Rotation := FTextAngle;

      LLn := LineK(LTextEnt.Position, LAngle);
      LInctPnts := UdGeo2D.Intersection(LLn, LTextEnt.TextBound);
      if System.Length(LInctPnts) < 2 then FTextAngle := -1
      else begin
        if System.Length(LInctPnts) > 2 then
          UdGeo2D.SortPoints(LInctPnts, FChordPoint);
        LTextWidth := Distance(LInctPnts[0], LInctPnts[High(LInctPnts)]);
      end;
    end;

    if (FTextProp.VerticalPosition = vtpCentered) or (FLeaderLen < 0) then
    begin
      LLineEnt := Self.CreateDimLine(LDimPnt, ShiftPoint(LDimPnt, LAngle, DIM_TEXT_SIDE_OFFSET), False);
      FEntityList.Add(LLineEnt);
    end
    else begin
      LLineEnt := Self.CreateDimLine(LDimPnt, ShiftPoint(LDimPnt, LAngle, LTextWidth + DIM_TEXT_SIDE_OFFSET), False);
      FEntityList.Add(LLineEnt);
    end;

    LTextPnt := ShiftPoint(LDimPnt, LAngle, (LTextWidth / 2) + DIM_TEXT_SIDE_OFFSET);
  end;


  //------------------------------------------------------

  if FTextAngle >= 0.0 then
    UpdateTextPosition(LTextEnt, False, LTextPnt, FTextAngle)
  else
    UpdateOutsideTextPosition(LTextEnt, LTextPnt, LAngle, FLeaderLen < 0, LInctBound);


  FGripTextPnt := LTextPnt;
  Result := True;
end;



//----------------------------------------------------------------------------------------

function TUdDimRadial.GetGripPoints: TUdGripPointArray;
begin
  System.SetLength(Result, 3);

  Result[0] := MakeGripPoint(Self, gmPoint, 0, FCenter , 0);
  Result[1] := MakeGripPoint(Self, gmPoint, 1, FChordPoint, 0);
  Result[2] := MakeGripPoint(Self, gmPoint, 2, FGripTextPnt, 0);
end;


function TUdDimRadial.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  LCir: TCircle2D;
  LRad, LAng: Float;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    case AGripPnt.Index of
      0:
        begin
          Self.Move(FCenter, AGripPnt.Point);
        end;
      1:
        begin
          LAng := GetAngle(FCenter, AGripPnt.Point);
          LRad := Distance(FCenter, FChordPoint);

          SetChordPoint( ShiftPoint(FCenter, LAng, LRad) );
          Result := True;
        end;
      2:
        begin
          Self.RaiseBeforeModifyObject('');

          LAng := GetAngle(FCenter, AGripPnt.Point);
          LRad := Distance(FCenter, FChordPoint);

          FChordPoint := ShiftPoint(FCenter, LAng, LRad);

          LCir := Circle2D(FCenter, LRad);

          if UdGeo2D.IsPntOnCircle(AGripPnt.Point, LCir) then
          begin
            FLeaderLen := -5;
          end
          else begin
            if UdGeo2D.IsPntInCircle(AGripPnt.Point, LCir) then
              FLeaderLen := -Distance(FChordPoint, AGripPnt.Point)
            else
              FLeaderLen := +Distance(FChordPoint, AGripPnt.Point);
          end;

          Self.Update();

          Self.RaiseAfterModifyObject('');
        end;
    end;
  end;
end;




//----------------------------------------------------------------------------------------

function TUdDimRadial.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter := UdGeo2D.Translate(Dx, Dy, FCenter);
  FChordPoint := UdGeo2D.Translate(Dx, Dy, FChordPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimRadial.Mirror(APnt1, APnt2: TPoint2D): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FCenter);
  FChordPoint := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FChordPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimRadial.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter := UdGeo2D.Rotate(ABase, ARota, FCenter);
  FChordPoint := UdGeo2D.Rotate(ABase, ARota, FChordPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimRadial.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter := UdGeo2D.Scale(ABase, AFactor, AFactor, FCenter);
  FChordPoint := UdGeo2D.Scale(ABase, AFactor, AFactor, FChordPoint);

  FLeaderLen := FLeaderLen * AFactor;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdDimRadial.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdDimRadial;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdDimRadial.Create(Self.Document, False);

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      with LEntity do
      begin
        FCenter := UdGeo2D.Scale(ABase,  XFactor, YFactor, Self.FCenter);
        FChordPoint := UdGeo2D.Scale(ABase,  XFactor, YFactor, Self.FChordPoint);

        FLeaderLen := Self.FLeaderLen * Max(XFactor, YFactor);
      end;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;


function TUdDimRadial.Intersect(AOther: TUdEntity): TPoint2DArray;
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

function TUdDimRadial.Perpend(APnt: TPoint2D): TPoint2DArray;
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

procedure TUdDimRadial.SaveToStream(AStream: TStream);
begin
  inherited;

  Point2DToStream(AStream, FCenter    );
  Point2DToStream(AStream, FChordPoint);
  FloatToStream(AStream, FLeaderLen );
end;

procedure TUdDimRadial.LoadFromStream(AStream: TStream);
begin
  inherited;

  FCenter      := Point2DFromStream(AStream);
  FChordPoint  := Point2DFromStream(AStream);
  FLeaderLen   := FloatFromStream(AStream);

  if Self.ClassType = TUdDimRadial then Self.Update();
end;





procedure TUdDimRadial.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Center']         := Point2DToStr(FCenter    );
  LXmlNode.Prop['ChordPoint']     := Point2DToStr(FChordPoint);
  LXmlNode.Prop['LeaderLen']      := FloatToStr(FLeaderLen   );
end;

procedure TUdDimRadial.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FCenter         := StrToPoint2D(LXmlNode.Prop['Center']         );
  FChordPoint     := StrToPoint2D(LXmlNode.Prop['ChordPoint']     );
  FLeaderLen      := StrToFloatDef(LXmlNode.Prop['LeaderLen'], 0  );

  if Self.ClassType = TUdDimRadial then Self.Update();
end;

end.