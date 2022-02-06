                     {
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimOrdinate;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes, UdConsts, UdObject, UdAxes, UdEntity,
  UdColor, UdDimProps, UdDimension;


type
  //*** TUdDimOrdinate ***//
  TUdDimOrdinate = class(TUdDimension)
  protected
    FOriginPoint     : TPoint2D;
    FDefinitionPoint : TPoint2D;
    FLeaderEndPoint  : TPoint2D;
    FUseXAxis        : Boolean;

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; override;

    procedure SetTextPoint(const AValue: TPoint2D); override;

    procedure SetOriginPoint(const AValue: TPoint2D);
    procedure SetDefinitionPoint(const AValue: TPoint2D);
    procedure SetLeaderEndPoint(const AValue: TPoint2D);
    procedure SetUseXAxis(const AValue: Boolean);


    function GetOriginPointValue(AIndex: Integer): Float;
    procedure SetOriginPointValue(AIndex: Integer; const AValue: Float);

    function GetDefinitionPointValue(AIndex: Integer): Float;
    procedure SetDefinitionPointValue(AIndex: Integer; const AValue: Float);

    function GetLeaderEndPointValue(AIndex: Integer): Float;
    procedure SetLeaderEndPointValue(AIndex: Integer; const AValue: Float);


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
    property OriginPoint     : TPoint2D read FOriginPoint     write SetOriginPoint    ;
    property DefinitionPoint : TPoint2D read FDefinitionPoint write SetDefinitionPoint;
    property LeaderEndPoint  : TPoint2D read FLeaderEndPoint  write SetLeaderEndPoint ;

  published
    property OriginPointX     : Float index 0 read GetOriginPointValue     write SetOriginPointValue    ;
    property OriginPointY     : Float index 1 read GetOriginPointValue     write SetOriginPointValue    ;

    property DefinitionPointX : Float index 0 read GetDefinitionPointValue write SetDefinitionPointValue;
    property DefinitionPointY : Float index 1 read GetDefinitionPointValue write SetDefinitionPointValue;

    property LeaderEndPointX  : Float index 0 read GetLeaderEndPointValue  write SetLeaderEndPointValue ;
    property LeaderEndPointY  : Float index 1 read GetLeaderEndPointValue  write SetLeaderEndPointValue ;

    property UseXAxis        : Boolean  read FUseXAxis        write SetUseXAxis;

  end;


implementation



uses
  SysUtils, UdText,
  UdMath, UdGeo2D, UdStreams, UdXml, UdUtils, UdStrConverter;

const
  LEADER_LENGTH = 5;



//=================================================================================================
{ TUdDimOrdinate }

constructor TUdDimOrdinate.Create();
begin
  inherited;

  FOriginPoint     := Point2D(0, 0);
  FDefinitionPoint := Point2D(0, 0);
  FLeaderEndPoint  := Point2D(0, 0);
  FUseXAxis        := False;
end;

destructor TUdDimOrdinate.Destroy;
begin

  inherited;
end;


function TUdDimOrdinate.GetTypeID: Integer;
begin
  Result := ID_DIMORDINATE;
end;

function TUdDimOrdinate.GetDimTypeID: Integer;
begin
  Result := 6;
end;


//----------------------------------------------------------------------------------------


procedure TUdDimOrdinate.SetTextPoint(const AValue: TPoint2D);
begin
  FLeaderEndPoint := AValue;
  Self.Update();
end;

procedure TUdDimOrdinate.SetOriginPoint(const AValue: TPoint2D);
begin
  if NotEqual(FOriginPoint, AValue) and Self.RaiseBeforeModifyObject('OriginPoint') then
  begin
    FOriginPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('OriginPoint');
  end;
end;

procedure TUdDimOrdinate.SetDefinitionPoint(const AValue: TPoint2D);
begin
  if NotEqual(FDefinitionPoint, AValue) and Self.RaiseBeforeModifyObject('DefinitionPoint') then
  begin
    FDefinitionPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('DefinitionPoint');
  end;
end;


procedure TUdDimOrdinate.SetLeaderEndPoint(const AValue: TPoint2D);
begin
  if NotEqual(FLeaderEndPoint, AValue) and Self.RaiseBeforeModifyObject('LeaderEndPoint') then
  begin
    FLeaderEndPoint := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('LeaderEndPoint');
  end;
end;


procedure TUdDimOrdinate.SetUseXAxis(const AValue: Boolean);
begin
  if (FUseXAxis <> AValue) and Self.RaiseBeforeModifyObject('UseXAxis') then
  begin
    FUseXAxis := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('UseXAxis');
  end;
end;





function TUdDimOrdinate.GetOriginPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FOriginPoint.X;
    1: Result := FOriginPoint.Y;
  end;
end;

procedure TUdDimOrdinate.SetOriginPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FOriginPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FOriginPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('OriginPointX');
    1: Self.RaiseBeforeModifyObject('OriginPointY');
  end;

  FOriginPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('OriginPointX');
    1: Self.RaiseAfterModifyObject('OriginPointY');
  end;
end;



function TUdDimOrdinate.GetLeaderEndPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FLeaderEndPoint.X;
    1: Result := FLeaderEndPoint.Y;
  end;
end;

procedure TUdDimOrdinate.SetLeaderEndPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FLeaderEndPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FLeaderEndPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('LeaderEndPointX');
    1: Self.RaiseBeforeModifyObject('LeaderEndPointY');
  end;

  FLeaderEndPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('LeaderEndPointX');
    1: Self.RaiseAfterModifyObject('LeaderEndPointY');
  end;
end;




function TUdDimOrdinate.GetDefinitionPointValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FDefinitionPoint.X;
    1: Result := FDefinitionPoint.Y;
  end;
end;



procedure TUdDimOrdinate.SetDefinitionPointValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FDefinitionPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FDefinitionPoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('DefinitionPointX');
    1: Self.RaiseBeforeModifyObject('DefinitionPointY');
  end;

  FDefinitionPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('DefinitionPointX');
    1: Self.RaiseAfterModifyObject('DefinitionPointY');
  end;
end;









procedure TUdDimOrdinate.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDimOrdinate) then Exit;

  FOriginPoint     := TUdDimOrdinate(AValue).FOriginPoint    ;
  FDefinitionPoint := TUdDimOrdinate(AValue).FDefinitionPoint;
  FLeaderEndPoint  := TUdDimOrdinate(AValue).FLeaderEndPoint ;
  FUseXAxis        := TUdDimOrdinate(AValue).FUseXAxis       ;

  Self.Update();
end;




//----------------------------------------------------------------------------------------

function TUdDimOrdinate.UpdateDim(AAxes: TUdAxes): Boolean;
var
  LLn: TLineK;
  LPnt: TPoint2D;
  LLnAng: Float;
  LDefLn: TLineK;
  LDefAng: Float;
  LDefPnt, LLeadPnt: TPoint2D;
  LLineEnt: TUdEntity;
  LTextEnt: TUdText;
  LTextPnt: TPoint2D;
  LTextWidth: Float;
  LSgnAng, LTextAng: Float;
  LInctPnts: TPoint2DArray;
  LOverallScale: Float;
begin
  ClearObjectList(FEntityList);

  if FUseXAxis then
  begin
    LLnAng := 90.0;
    FMeasurement := Abs(FDefinitionPoint.X - FOriginPoint.X);
  end
  else begin
    LLnAng := 0.0;
    FMeasurement := Abs(FDefinitionPoint.Y - FOriginPoint.Y);
  end;

  LDefLn := LineK(FDefinitionPoint, LLnAng);

  LPnt := ClosestLinePoint(FLeaderEndPoint, LDefLn);
  if IsEqual(FDefinitionPoint, LPnt) then LDefAng := LLnAng else LDefAng := GetAngle(FDefinitionPoint, LPnt);

  LDefPnt := ShiftPoint(FDefinitionPoint, LDefAng, LEADER_LENGTH);
  LLeadPnt := ShiftPoint(FLeaderEndPoint, FixAngle(LDefAng + 180), LEADER_LENGTH);

  LPnt := ClosestLinePoint(LLeadPnt, LDefLn);
  if NotEqual(LDefPnt, LPnt) and IsEqual(GetAngle(LDefPnt, LPnt), LDefAng, 1) then
  begin
    if Distance(LDefPnt, LPnt) > LEADER_LENGTH then
      LDefPnt := ShiftPoint(LPnt, FixAngle(LDefAng + 180), LEADER_LENGTH);
  end;

  LLineEnt := Self.CreateDimLine(FDefinitionPoint, LDefPnt, False);
  FEntityList.Add(LLineEnt);

  LLineEnt := Self.CreateDimLine(LDefPnt, LLeadPnt, False);
  FEntityList.Add(LLineEnt);

  LLineEnt := Self.CreateDimLine(LLeadPnt, FLeaderEndPoint, False);
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

    LTextEnt.Contents := GetDimText(FMeasurement, dtkNormal);
  finally
    LTextEnt.EndUpdate();
  end;

  LTextWidth := LTextEnt.TextWidth + (FTextProp.TextHeight * TEXT_BOUND_OFFSET_FACTOR) * 2;
  FEntityList.Add(LTextEnt);


  LSgnAng := SgnAngle(LDefAng, 0.01);
  LTextPnt := ShiftPoint(FLeaderEndPoint, LDefAng, LTextWidth/2);

  if FTextAngle >= 0.0 then
  begin
    LTextEnt.Rotation := FTextAngle;
    LTextEnt.Position  := LTextPnt;

    LLn := LineK(LTextEnt.Position, LDefAng);
    LInctPnts := UdGeo2D.Intersection(LLn, LTextEnt.TextBound);

    if System.Length(LInctPnts) > 0 then
    begin
      UdGeo2D.SortPoints(LInctPnts, FLeaderEndPoint);

      LLineEnt := Self.CreateDimLine(FLeaderEndPoint, LInctPnts[0], False);
      FEntityList.Add(LLineEnt);
    end;
  end
  else begin

    if (FTextProp.VerticalPosition = vtpAbove) then
    begin
      if LSgnAng <= 90 then
        LTextEnt.Position := ShiftPoint(LTextPnt, FixAngle(LSgnAng + 90), (LTextEnt.TextHeight/2 + FTextProp.OffsetFromDimLine) )
      else
        LTextEnt.Position := ShiftPoint(LTextPnt, FixAngle(LSgnAng - 90), (LTextEnt.TextHeight/2 + FTextProp.OffsetFromDimLine) );

      LLineEnt := Self.CreateDimLine(FLeaderEndPoint, ShiftPoint(FLeaderEndPoint, LDefAng, LTextWidth), False);
      FEntityList.Add(LLineEnt);
    end
    else begin
      LTextEnt.Position := LTextPnt;
    end;


    LTextAng := LDefAng;
    if (LTextAng > 90) and (LTextAng <= 270) then LTextAng := LTextAng - 180;

    LTextEnt.Rotation := LTextAng;
  end;


  //------------------------------------------------------

  FGripTextPnt := LTextPnt;

  Result := True;
end;



//----------------------------------------------------------------------------------------


function TUdDimOrdinate.GetGripPoints: TUdGripPointArray;
begin
  System.SetLength(Result, 3);

  Result[0] := MakeGripPoint(Self, gmPoint, 0, FOriginPoint , 0);
  Result[1] := MakeGripPoint(Self, gmPoint, 1, FDefinitionPoint, 0);
  Result[2] := MakeGripPoint(Self, gmPoint, 2, FLeaderEndPoint, 0);
//  Result[3] := MakeGripPoint(Self, gmPoint, 3, FGripTextPoint, 0);
end;


function TUdDimOrdinate.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    case AGripPnt.Index of
      0:
        begin
          SetOriginPoint( AGripPnt.Point );
          Result := True;
        end;
      1:
        begin
          SetDefinitionPoint( AGripPnt.Point );
          Result := True;
        end;
      2:
        begin
          SetLeaderEndPoint( AGripPnt.Point );
          Result := True;
        end;
//      3:
//        begin
//          FLeaderEndPoint.X := FLeaderEndPoint.X + (AGripPnt.Point.X - FGripTextPoint.X);
//          FLeaderEndPoint.Y := FLeaderEndPoint.Y + (AGripPnt.Point.Y - FGripTextPoint.Y);
//          Self.Update();
//        end;
    end;
  end;
end;




//----------------------------------------------------------------------------------------

function TUdDimOrdinate.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FDefinitionPoint := UdGeo2D.Translate(Dx, Dy, FDefinitionPoint);
  FLeaderEndPoint  := UdGeo2D.Translate(Dx, Dy, FLeaderEndPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimOrdinate.Mirror(APnt1, APnt2: TPoint2D): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FDefinitionPoint := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FDefinitionPoint);
  FLeaderEndPoint  := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FLeaderEndPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimOrdinate.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FDefinitionPoint := UdGeo2D.Rotate(ABase, ARota, FDefinitionPoint);
  FLeaderEndPoint  := UdGeo2D.Rotate(ABase, ARota, FLeaderEndPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimOrdinate.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FDefinitionPoint := UdGeo2D.Scale(ABase, AFactor, AFactor, FDefinitionPoint);
  FLeaderEndPoint  := UdGeo2D.Scale(ABase, AFactor, AFactor, FLeaderEndPoint);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdDimOrdinate.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdDimOrdinate;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdDimOrdinate.Create(Self.Document, False);

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      with LEntity do
      begin
        FDefinitionPoint := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FDefinitionPoint);
        FLeaderEndPoint  := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.FLeaderEndPoint);
      end;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;


function TUdDimOrdinate.Intersect(AOther: TUdEntity): TPoint2DArray;
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

function TUdDimOrdinate.Perpend(APnt: TPoint2D): TPoint2DArray;
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

procedure TUdDimOrdinate.SaveToStream(AStream: TStream);
begin
  inherited;

  Point2DToStream(AStream, FOriginPoint    );
  Point2DToStream(AStream, FDefinitionPoint);
  Point2DToStream(AStream, FLeaderEndPoint );
  BoolToStream(AStream, FUseXAxis       );
end;

procedure TUdDimOrdinate.LoadFromStream(AStream: TStream);
begin
  inherited;

  FOriginPoint     := Point2DFromStream(AStream);
  FDefinitionPoint := Point2DFromStream(AStream);
  FLeaderEndPoint  := Point2DFromStream(AStream);
  FUseXAxis        := BoolFromStream(AStream);

  Self.Update();
end;




procedure TUdDimOrdinate.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['OriginPoint']     := Point2DToStr(FOriginPoint    );
  LXmlNode.Prop['DefinitionPoint'] := Point2DToStr(FDefinitionPoint);
  LXmlNode.Prop['LeaderEndPoint']  := Point2DToStr(FLeaderEndPoint );
  LXmlNode.Prop['UseXAxis']        := BoolToStr(FUseXAxis, True    );
end;

procedure TUdDimOrdinate.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FOriginPoint     := StrToPoint2D(LXmlNode.Prop['OriginPoint']    );
  FDefinitionPoint := StrToPoint2D(LXmlNode.Prop['DefinitionPoint']);
  FLeaderEndPoint  := StrToPoint2D(LXmlNode.Prop['LeaderEndPoint'] );
  FUseXAxis        := StrToBoolDef(LXmlNode.Prop['UseXAxis'], False);
end;

end.