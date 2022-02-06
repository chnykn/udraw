{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLine;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes;

type

  //-----------------------------------------------------
  TUdLine = class(TUdFigure)
  private
    FStartPoint: TPoint2D;
    FEndPoint  : TPoint2D;

  protected
    function GetTypeID(): Integer; override;

    function GetXData: TSegment2D;
    procedure SetXData(const AValue: TSegment2D);

    procedure SetPoint(AIndex: Integer; const AValue: TPoint2D);

    function GetCoodValue(AIndex: Integer): Float;
    procedure SetCoodValue(AIndex: Integer; const AValue: Float);

    function GetDeltaValue(AIndex: Integer): Float;
    procedure SetDeltaValue(AIndex: Integer; const AValue: Float);

    function GetAngle_: Float;
    procedure SetAngle_(const AValue: Float);

    function GetLength_: Float;
    procedure SetLength_(const AValue: Float);


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
    property StartPoint: TPoint2D index 0 read FStartPoint write SetPoint;
    property EndPoint  : TPoint2D index 1 read FEndPoint   write SetPoint;

    property XData: TSegment2D  read GetXData write SetXData;

  published
    property StartX: Float index 0 read GetCoodValue write SetCoodValue;
    property StartY: Float index 1 read GetCoodValue write SetCoodValue;
    property EndX  : Float index 2 read GetCoodValue write SetCoodValue;
    property EndY  : Float index 3 read GetCoodValue write SetCoodValue;

    property DeltaX: Float index 0 read GetDeltaValue write SetDeltaValue;
    property DeltaY: Float index 1 read GetDeltaValue write SetDeltaValue;

    property Length: Float read GetLength_ write SetLength_;
    property Angle : Float read GetAngle_  write SetAngle_;
  end;


  function GetSegTrimBreakPnts(ASeg: TSegment2D; APnt: TPoint2D; var AInctPnts: TPoint2DArray; var AP1, AP2: TPoint2D): Boolean;

implementation

uses
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, UdColls;




//==================================================================================================
{ TUdLine }

constructor TUdLine.Create();
begin
  inherited;
  
  FStartPoint.X := 0.0;
  FStartPoint.Y := 0.0;
  FEndPoint.X   := 0.0;
  FEndPoint.Y   := 0.0;
end;

destructor TUdLine.Destroy;
begin
  inherited;
end;



function TUdLine.GetTypeID: Integer;
begin
  Result := ID_LINE;
end;



//-----------------------------------------------------------------------------------------


function TUdLine.GetXData: TSegment2D;
begin
  Result := Segment2D(FStartPoint, FEndPoint);
end;

procedure TUdLine.SetXData(const AValue: TSegment2D);
begin
  if Self.RaiseBeforeModifyObject('XData') then
  begin
    FStartPoint := AValue.P1;
    FEndPoint := AValue.P2;

    Self.Update();
    Self.RaiseAfterModifyObject('XData');
  end;
end;


procedure TUdLine.SetPoint(AIndex: Integer; const AValue: TPoint2D);
begin
  case AIndex of
    0:
      if NotEqual(FStartPoint, AValue) and Self.RaiseBeforeModifyObject('StartPoint') then
      begin
        FStartPoint := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('StartPoint');
      end;
    1:
      if NotEqual(FEndPoint, AValue) and Self.RaiseBeforeModifyObject('EndPoint') then
      begin
        FEndPoint := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('EndPoint');
      end;
  end;
end;



function TUdLine.GetCoodValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FStartPoint.X;
    1: Result := FStartPoint.Y;
    2: Result := FEndPoint.X;
    3: Result := FEndPoint.Y;
  end;
end;

procedure TUdLine.SetCoodValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
  LValid: Boolean;
begin
  LValid := False;

  case AIndex of
    0, 1:
    begin
      LPnt := FStartPoint;
      if AIndex = 0 then LPnt.X := AValue else LPnt.Y := AValue;
      LValid :=  NotEqual(FStartPoint, LPnt);
      if LValid then
      begin
        if AIndex = 0 then
          LValid := Self.RaiseBeforeModifyObject('StartX')
        else
          LValid := Self.RaiseBeforeModifyObject('StartY')
      end;
    end;
    2, 3:
    begin
      LPnt := FEndPoint;
      if AIndex = 0 then LPnt.X := AValue else LPnt.Y := AValue;
      LValid :=  NotEqual(FEndPoint, LPnt);
      if LValid then
      begin
        if AIndex = 0 then
          LValid := Self.RaiseBeforeModifyObject('EndX')
        else
          LValid := Self.RaiseBeforeModifyObject('EndY')
      end;
    end;
  end;

  if not LValid then Exit; //========>>>

  case AIndex of
    0: FStartPoint.X := AValue;
    1: FStartPoint.Y := AValue;
    2: FEndPoint.X   := AValue;
    3: FEndPoint.Y   := AValue;
  end;

  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('StartX');
    1: Self.RaiseAfterModifyObject('StartY');
    2: Self.RaiseAfterModifyObject('EndX');
    3: Self.RaiseAfterModifyObject('EndY');
  end;

end;





function TUdLine.GetDeltaValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FEndPoint.X - FStartPoint.X;
    1: Result := FEndPoint.Y - FStartPoint.Y;
  end;
end;

procedure TUdLine.SetDeltaValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
  LValid: Boolean;
begin
  if IsEqual(AValue, 0.0) then Exit; //========>>>

  LValid := False;

  case AIndex of
    0: LValid := Self.RaiseBeforeModifyObject('DeltaX');
    1: LValid := Self.RaiseBeforeModifyObject('DeltaY');
  end;

  if not LValid then Exit; //========>>>

  case AIndex of
    0: LPnt.X := FStartPoint.X + AValue;
    1: LPnt.Y := FStartPoint.Y + AValue;
  end;

  FEndPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('DeltaX');
    1: Self.RaiseAfterModifyObject('DeltaY');
  end;
end;



function TUdLine.GetAngle_: Float;
begin
  Result := UdGeo2D.GetAngle(FStartPoint, FEndPoint);
  if Result < 0 then Result := 0;
end;

procedure TUdLine.SetAngle_(const AValue: Float);
var
  LDis: Float;
  LPnt: TPoint2D;
begin
  if not Self.RaiseBeforeModifyObject('Angle') then Exit; //========>>>

  LDis := Distance(FStartPoint, FEndPoint);
  LPnt := UdGeo2D.ShiftPoint(FStartPoint, AValue, LDis);
  Self.EndPoint := LPnt;

  Self.RaiseAfterModifyObject('Angle')
end;



function TUdLine.GetLength_: Float;
begin
  Result := Distance(FStartPoint, FEndPoint);
end;

procedure TUdLine.SetLength_(const AValue: Float);
var
  LAng: Float;
  LPnt: TPoint2D;
begin
  if not Self.RaiseBeforeModifyObject('Length') then Exit; //========>>>

  LAng := UdGeo2D.GetAngle(FStartPoint, FEndPoint);
  LPnt := UdGeo2D.ShiftPoint(FStartPoint, LAng, AValue);

  FEndPoint := LPnt;
  Self.Update();

  Self.RaiseAfterModifyObject('Length')
end;


procedure TUdLine.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdLine) then Exit; //========>>>

  Self.FStartPoint  := TUdLine(AValue).FStartPoint;
  Self.FEndPoint    := TUdLine(AValue).FEndPoint;

  Self.Update();
end;





//-----------------------------------------------------------------------------------------

function TUdLine.CanFilled(): Boolean;
begin
  Result := False;
end;

procedure TUdLine.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect := UdGeo2D.RectHull(FStartPoint, FEndPoint);
end;

procedure TUdLine.UpdateSamplePoints(AAxes: TUdAxes);
begin
  FSamplePoints := UdGeo2D.SamplePoints(Self.GetXData(), 0);
end;



function TUdLine.GetGripPoints(): TUdGripPointArray;
begin
  System.SetLength(Result, 3);
  Result[0] := MakeGripPoint(Self, gmCenter, 0, MidPoint(FStartPoint, FEndPoint), 0);
  Result[1] := MakeGripPoint(Self, gmPoint, 1, FStartPoint, 0);
  Result[2] := MakeGripPoint(Self, gmPoint, 2, FEndPoint, 0);
end;

function TUdLine.GetOSnapPoints: TUdOSnapPointArray;
var
  LAng: Float;
begin
  LAng := UdGeo2D.GetAngle(FStartPoint, FEndPoint);

  System.SetLength(Result, 3);
  Result[0] := MakeOSnapPoint(Self, OSNP_END, FStartPoint, LAng);
  Result[1] := MakeOSnapPoint(Self, OSNP_MID, UdGeo2D.MidPoint(FStartPoint, FEndPoint), LAng);
  Result[2] := MakeOSnapPoint(Self, OSNP_END, FEndPoint, LAng);
end;






//-----------------------------------------------------------------------------------------


function TUdLine.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;

  case AGripPnt.Mode of
    gmCenter: Result := Self.Move(MidPoint(FStartPoint, FEndPoint), AGripPnt.Point);
    gmPoint :
      begin
        if AGripPnt.Index = 1 then Self.StartPoint := AGripPnt.Point else
        if AGripPnt.Index = 2 then Self.EndPoint   := AGripPnt.Point ;
        Result := True;
      end;
  end;
end;


function TUdLine.Pick(APoint: TPoint2D): Boolean;
var
  D, E: Float;
  LAxes: TUdAxes;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;

  if FPenWidth > 0.0 then
  begin
    D := DistanceToSegment(APoint, Self.GetXData());
    Result := (D < FPenWidth/2) or IsEqual(D, FPenWidth/2, E);
  end
  else
    Result := UdGeo2D.IsPntOnSegment(APoint, Self.GetXData(), E);
end;

function TUdLine.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.Inclusion(FBoundsRect, ARect) = irOvered;

  if not Result and ACrossingMode then
    Result := UdGeo2D.IsIntersect(Self.GetXData(), ARect);
end;

function TUdLine.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FStartPoint := UdGeo2D.Translate(Dx, Dy, FStartPoint);
  FEndPoint := UdGeo2D.Translate(Dx, Dy, FEndPoint);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdLine.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LTheSeg, LNewSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LTheSeg := UdGeo2D.Segment2D(FStartPoint, FEndPoint);
  LNewSeg := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LTheSeg);

  FStartPoint := LNewSeg.P1;
  FEndPoint := LNewSeg.P2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdLine.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
var
  LSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ADis, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LSeg := UdGeo2D.OffsetSegment(Self.GetXData(), ADis, ASidePnt);

  FStartPoint := LSeg.P1;
  FEndPoint := LSeg.P2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdLine.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
var
  LNewSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LNewSeg := UdGeo2D.Rotate(ABase, ARota, UdGeo2D.Segment2D(FStartPoint, FEndPoint) );

  FStartPoint := LNewSeg.P1;
  FEndPoint := LNewSeg.P2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdLine.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
var
  LNewSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LNewSeg := UdGeo2D.Scale(ABase, AFactor, AFactor, UdGeo2D.Segment2D(FStartPoint, FEndPoint) );

  FStartPoint := LNewSeg.P1;
  FEndPoint := LNewSeg.P2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdLine.Extend(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): Boolean;
var
  I, J: Integer;
  LAng: Float;
  LPnt: TPoint2D;
  LLine: TLine2D;
  LIsP1: Boolean;
  LInctPnts: TPoint2DArray;
  LPointList: TPoint2DList;
begin
  Result := False;

  if UdGeo2D.Distance(FStartPoint, APnt) < UdGeo2D.Distance(FEndPoint, APnt) then
  begin
    LIsP1 := True;
    LAng := GetAngle(FEndPoint, FStartPoint);
  end
  else begin
    LIsP1 := False;
    LAng := GetAngle(FStartPoint, FEndPoint);
  end;

  LLine := Line2D(FStartPoint, FEndPoint);
  LPointList := TPoint2DList.Create(MAXBYTE);
  try
    for I := 0 to System.Length(ASelectedEntities) - 1 do
    begin
      if Assigned(ASelectedEntities[I]) and (ASelectedEntities[I] <> Self) then
      begin
        LInctPnts := UdUtils.EntitiesIntersection(LLine, ASelectedEntities[I]);
        for J := 0 to System.Length(LInctPnts) - 1 do LPointList.Add(LInctPnts[J]);
      end;
    end;

    LPnt := MidPoint(FStartPoint, FEndPoint);

    for I := LPointList.Count - 1 downto 0 do
    begin
      if NotEqual(UdGeo2D.GetAngle(LPnt, LPointList.GetPoint(I)), LAng, 1) or
         UdGeo2D.IsPntOnSegment(LPointList.GetPoint(I), Segment2D(FStartPoint, FEndPoint)) then
        LPointList.RemoveAt(I);
    end;

    LInctPnts := LPointList.ToArray();
  finally
    LPointList.Free;
  end;

  if System.Length(LInctPnts) <= 0 then Exit;  //=======>>>>>>

  Self.RaiseBeforeModifyObject('');

  if LIsP1 then LPnt := FStartPoint else LPnt := FEndPoint;
  LPnt := UdGeo2D.NearestPoint(LInctPnts, LPnt);

  if LIsP1 then FStartPoint := LPnt else FEndPoint := LPnt;
  Self.Update();

  Self.RaiseAfterModifyObject('');
  Result := True;
end;



function TUdLine.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LSeg: TSegment2D;
  LEntity: TUdLine;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdLine.Create({Self.Document, False});

  LEntity.BeginUpdate();  
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      LSeg := Segment2D(FStartPoint, FEndPoint);
      LSeg := UdGeo2D.Scale(ABase, XFactor, YFactor, LSeg);

      LEntity.XData := LSeg;
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;

function TUdLine.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  I: Integer;
  LLine: TUdLine;
  LSegs: TSegment2DArray;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>

  LSegs := UdGeo2D.BreakAt(Segment2D(FStartPoint, FEndPoint), APnt1, APnt2);

  System.SetLength(Result, System.Length(LSegs));
  for I := 0 to System.Length(LSegs) - 1 do
  begin
    LLine := TUdLine(Self.Clone());
    LLine.SetXData(LSegs[I]);

    Result[I] := LLine;
  end;
end;

function GetSegTrimBreakPnts(ASeg: TSegment2D; APnt: TPoint2D; var AInctPnts: TPoint2DArray; var AP1, AP2: TPoint2D): Boolean;
var
  I: Integer;
  LDis: Float;
  LPnt: TPoint2D;
  LFound: Boolean;
begin
  Result := False;
  if System.Length(AInctPnts) <= 0 then Exit; //======>>>>

  LPnt := ClosestSegmentPoint(APnt, ASeg);
  LDis := Distance(ASeg.P1, LPnt);

  LFound := False;

  UdGeo2D.SortPoints(AInctPnts, ASeg.P1);
  for I := 0 to System.Length(AInctPnts) - 1 do
  begin
    if Distance(ASeg.P1, AInctPnts[I]) > LDis then
    begin
      LFound := True;
      if I > 0 then AP1 := AInctPnts[I-1] else AP1 := ASeg.P1;
      AP2 := AInctPnts[I];
      Break;
    end;
  end;

  if not LFound then
  begin
    AP1 := AInctPnts[High(AInctPnts)];
    AP2 := ASeg.P2;
  end;

  Result := True;
end;

function TUdLine.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;
var
  LP1, LP2: TPoint2D;
  LInctPnts: TPoint2DArray;
begin
  Result := nil;

  LInctPnts := UdUtils.EntitiesIntersection(Self, ASelectedEntities);
  if GetSegTrimBreakPnts(Segment2D(FStartPoint, FEndPoint), APnt, LInctPnts, LP1, LP2) then
    Result := Self.BreakAt(LP1, LP2);
end;



function TUdLine.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  if not Self.IsVisible or Self.IsLock() then Exit;
  if not AOther.IsVisible or AOther.IsLock() then Exit;

  Result := UdUtils.EntitiesIntersection(Self.GetXData(), AOther);
end;

function TUdLine.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  LLn: TLine2D;
  LPnt: TPoint2D;
begin
  Result := nil;

  LLn := UdGeo2D.Line2D(FStartPoint, FEndPoint);

  LPnt := UdGeo2D.ClosestLinePoint(APnt, LLn);
  if UdGeo2D.IsPntOnSegment(LPnt, Segment2D(FStartPoint, FEndPoint)) then
  begin
    System.SetLength(Result, 1);
    Result[0] := LPnt;
  end;
end;











//-----------------------------------------------------------------------------------------

procedure TUdLine.SaveToStream(AStream: TStream);
begin
  inherited;

  FloatToStream(AStream, FStartPoint.X);
  FloatToStream(AStream, FStartPoint.Y);
  FloatToStream(AStream, FEndPoint.X);
  FloatToStream(AStream, FEndPoint.Y);
end;

procedure TUdLine.LoadFromStream(AStream: TStream);
begin
  inherited;

  FStartPoint.X  := FloatFromStream(AStream);
  FStartPoint.Y  := FloatFromStream(AStream);
  FEndPoint.X  := FloatFromStream(AStream);
  FEndPoint.Y  := FloatFromStream(AStream);

  Update();
end;



procedure TUdLine.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['StartPoint'] := Point2DToStr(FStartPoint);
  LXmlNode.Prop['EndPoint']   := Point2DToStr(FEndPoint);
end;


procedure TUdLine.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FStartPoint := StrToPoint2D(LXmlNode.Prop['StartPoint']);
  FEndPoint   := StrToPoint2D(LXmlNode.Prop['EndPoint']);

  Update();
end;

end.