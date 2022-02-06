{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdRay;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes;

type

  //-----------------------------------------------------
  TUdRay = class(TUdFigure)
  private
    FBasePoint: TPoint2D;
    FSecondPoint: TPoint2D;

    FViewSeg: TSegment2D;
    FViewBound: TRect2D;

  protected
    function GetTypeID(): Integer; override;

    function GetAngle: Float;
    procedure SetAngle(const AValue: Float);

    function GetXData: TRay2D;
    procedure SetXData(const AValue: TRay2D);

    procedure SetPoint(AIndex: Integer; const AValue: TPoint2D);

    function GetBasePoint(AIndex: Integer): Float;
    function GetSecondPoint(AIndex: Integer): Float;

    procedure SetBasePoint(AIndex: Integer; const AValue: Float);
    procedure SetSecondPoint(AIndex: Integer; const AValue: Float);


    function CanFilled(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;


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
    property BasePoint  : TPoint2D index 0 read FBasePoint   write SetPoint;
    property SecondPoint: TPoint2D index 1 read FSecondPoint write SetPoint;

    property XData: TRay2D  read GetXData write SetXData;

  published
    property Angle: Float read GetAngle write SetAngle;

    property BasePointX: Float index 0 read GetBasePoint write SetBasePoint;
    property BasePointY: Float index 1 read GetBasePoint write SetBasePoint ;

    property SecondPointX: Float index 0 read GetSecondPoint write SetSecondPoint;
    property SecondPointY: Float index 1 read GetSecondPoint write SetSecondPoint;

  end;


implementation

uses
  UdLine,
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, UdColls;




//==================================================================================================
{ TUdRay }

constructor TUdRay.Create();
begin
  inherited;

  FBasePoint.X := 0.0;
  FBasePoint.Y := 0.0;
  FSecondPoint.X := 0.0;
  FSecondPoint.Y := 0.0;

  FViewSeg := Segment2D(0, 0, 0, 0);
  FViewBound := Rect2D(0, 0, 0, 0);
end;

destructor TUdRay.Destroy;
begin
  inherited;
end;




function TUdRay.GetTypeID: Integer;
begin
  Result := ID_RAY;
end;



//-----------------------------------------------------------------------------------------

function TUdRay.GetAngle: Float;
begin
  Result := UdGeo2D.GetAngle(FBasePoint, FSecondPoint);
end;

procedure TUdRay.SetAngle(const AValue: Float);
begin
  if Self.RaiseBeforeModifyObject('Angle') then
  begin
    FSecondPoint := ShiftPoint(FBasePoint, AValue, 100);
    Self.Update();
    Self.RaiseAfterModifyObject('Angle');
  end;
end;


function TUdRay.GetXData: TRay2D;
begin
  Result := Ray2D(FBasePoint, FSecondPoint);
end;

procedure TUdRay.SetXData(const AValue: TRay2D);
begin
  if Self.RaiseBeforeModifyObject('XData') then
  begin
    FBasePoint   := AValue.Base;
    FSecondPoint := ShiftPoint(FBasePoint, AValue.Ang, 100);

    Self.Update();
    Self.RaiseAfterModifyObject('XData');
  end;
end;

procedure TUdRay.SetPoint(AIndex: Integer; const AValue: TPoint2D);
begin
  case AIndex of
    0:
      if NotEqual(FBasePoint, AValue) and Self.RaiseBeforeModifyObject('BasePoint') then
      begin
        FBasePoint := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('BasePoint');
      end;
    1:
      if NotEqual(FSecondPoint, AValue) and Self.RaiseBeforeModifyObject('SecondPoint') then
      begin
        FSecondPoint := AValue;
        Self.Update();
        Self.RaiseAfterModifyObject('SecondPoint');
      end;
  end;
end;


function TUdRay.GetBasePoint(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FBasePoint.X;
    1: Result := FBasePoint.Y;
  end;
end;


function TUdRay.GetSecondPoint(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FSecondPoint.X;
    1: Result := FSecondPoint.Y;
  end;
end;


procedure TUdRay.SetBasePoint(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FBasePoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FBasePoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('BasePointX');
    1: Self.RaiseBeforeModifyObject('BasePointY');
  end;

  FBasePoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('BasePointX');
    1: Self.RaiseAfterModifyObject('BasePointY');
  end;
end;

procedure TUdRay.SetSecondPoint(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FBasePoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FBasePoint) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('SecondPointX');
    1: Self.RaiseBeforeModifyObject('SecondPointY');
  end;

  FSecondPoint := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('SecondPointX');
    1: Self.RaiseAfterModifyObject('SecondPointY');
  end;
end;



procedure TUdRay.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdRay) then Exit; //========>>>

  Self.FBasePoint   := TUdRay(AValue).FBasePoint;
  Self.FSecondPoint := TUdRay(AValue).FSecondPoint;

  Self.Update();
end;

function TUdRay.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
var
  LRect: TRect2D;
begin
  if Assigned(Self.Document) then
  begin
    LRect := Self.GetLayoutViewBound();
    if NotEqual(LRect.P1, FViewBound.P1) or NotEqual(LRect.P2, FViewBound.P2) then
    begin
      FViewBound := LRect;
      Self.Update();
    end;
  end;

  Result := inherited DoDraw(ACanvas, AAxes, AFlag, ALwFactor);
end;




//-----------------------------------------------------------------------------------------

function TUdRay.CanFilled(): Boolean;
begin
  Result := False;
end;

procedure TUdRay.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect := UdGeo2D.RectHull(FViewSeg.P1, FViewSeg.P2);
end;

procedure TUdRay.UpdateSamplePoints(AAxes: TUdAxes);
var
  LInctPnts: TPoint2DArray;
begin
  FSamplePoints := nil;
  if IsEqual(FBasePoint, FSecondPoint) then Exit;

  LInctPnts := UdGeo2D.Intersection(Ray2D(FBasePoint, FSecondPoint), FViewBound);
  if System.Length(LInctPnts) = 1 then
  begin
    FViewSeg.P1 := FBasePoint;
    FViewSeg.P2 := LInctPnts[0];

    FSamplePoints := UdGeo2D.SamplePoints(FViewSeg, 0);
  end
  else if System.Length(LInctPnts) = 2 then
  begin
    FViewSeg.P1 := LInctPnts[0];
    FViewSeg.P2 := LInctPnts[1];

    FSamplePoints := UdGeo2D.SamplePoints(FViewSeg, 0);
  end
end;



function TUdRay.GetGripPoints(): TUdGripPointArray;
var
  LDis, LAng: Float;
  LAxes: TUdAxes;
begin
  Result := nil;

  LAxes := Self.EnsureAxes(nil);
  if Assigned(LAxes) then
  begin
    LDis := LAxes.XValuePerPixel * 50;
    LAng := UdGeo2D.GetAngle(FBasePoint, FSecondPoint);

    System.SetLength(Result, 2);
    Result[0] := MakeGripPoint(Self, gmPoint, 0, FBasePoint, 0);
    Result[1] := MakeGripPoint(Self, gmPoint, 1, ShiftPoint(FBasePoint, LAng, LDis), 0);
  end;
end;

function TUdRay.GetOSnapPoints: TUdOSnapPointArray;
begin
  Result := nil;
end;






//-----------------------------------------------------------------------------------------


function TUdRay.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  LAng: Float;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    if AGripPnt.Index = 0 then
    begin
      Self.Move(FBasePoint, AGripPnt.Point);
    end
    else begin
      LAng := UdGeo2D.GetAngle(FBasePoint, AGripPnt.Point);
      Self.SetXData(Ray2D(FBasePoint, ShiftPoint(FBasePoint, LAng, 100)));
    end;
  end;
end;


function TUdRay.Pick(APoint: TPoint2D): Boolean;
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
    D := DistanceToRay(APoint, Self.GetXData());
    Result := (D < FPenWidth/2) or IsEqual(D, FPenWidth/2, E);
  end
  else
    Result := UdGeo2D.IsPntOnRay(APoint, Self.GetXData(), E);
end;

function TUdRay.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.Inclusion(FBoundsRect, ARect) = irOvered;

  if not Result and ACrossingMode then
    Result := System.Length(UdGeo2D.Intersection(Self.GetXData(), ARect)) > 0;
end;

function TUdRay.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FBasePoint := UdGeo2D.Translate(Dx, Dy, FBasePoint);
  FSecondPoint := UdGeo2D.Translate(Dx, Dy, FSecondPoint);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdRay.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LTheSeg, LNewSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LTheSeg := UdGeo2D.Segment2D(FBasePoint, FSecondPoint);
  LNewSeg := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LTheSeg);

  FBasePoint := LNewSeg.P1;
  FSecondPoint := LNewSeg.P2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdRay.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
var
  LSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ADis, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LSeg := Segment2D(FBasePoint, FSecondPoint);
  LSeg := UdGeo2D.OffsetSegment(LSeg, ADis, ASidePnt);

  FBasePoint   := LSeg.P1;
  FSecondPoint := LSeg.P2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdRay.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
var
  LSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LSeg := Segment2D(FBasePoint, FSecondPoint);
  LSeg := UdGeo2D.Rotate(ABase, ARota, LSeg);

  FBasePoint   := LSeg.P1;
  FSecondPoint := LSeg.P2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdRay.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
var
  LSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LSeg := Segment2D(FBasePoint, FSecondPoint);
  LSeg := UdGeo2D.Scale(ABase, AFactor, AFactor, LSeg);

  FBasePoint   := LSeg.P1;
  FSecondPoint := LSeg.P2;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdRay.Extend(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): Boolean;
var
  I, J: Integer;
  LAng: Float;
  LLine: TLine2D;
  LInctPnts: TPoint2DArray;
  LPointList: TPoint2DList;
begin
  Result := False;

  if IsEqual(FViewSeg.P1, FViewSeg.P2) then Exit;  //======>>>>
  if UdGeo2D.Distance(FViewSeg.P1, APnt) > UdGeo2D.Distance(FViewSeg.P2, APnt) then  Exit;  //======>>>>

  LLine := Line2D(FBasePoint, FSecondPoint);
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

    LAng := UdGeo2D.GetAngle(FBasePoint, FSecondPoint);

    for I := LPointList.Count - 1 downto 0 do
    begin
      if IsEqual(UdGeo2D.GetAngle(FBasePoint, LPointList.GetPoint(I)), LAng, 1)  then
        LPointList.RemoveAt(I);
    end;

    LInctPnts := LPointList.ToArray();
  finally
    LPointList.Free;
  end;

  if System.Length(LInctPnts) <= 0 then Exit;  //=======>>>>>>

  Self.RaiseBeforeModifyObject('');

  FBasePoint :=  UdGeo2D.NearestPoint(LInctPnts, FBasePoint);
  Self.Update();

  Self.RaiseAfterModifyObject('');
  Result := True;
end;



function TUdRay.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LSeg: TSegment2D;
  LEntity: TUdRay;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdRay.Create({Self.Document, False});
  
  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      LSeg := Segment2D(FBasePoint, FSecondPoint);
      LSeg := UdGeo2D.Scale(ABase, XFactor, YFactor, LSeg);

      LEntity.XData := Ray2D(LSeg.P1, LSeg.P2);
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;


function TUdRay.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  LRay: TUdRay;
  LLine: TUdLine;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>
  if IsEqual(APnt1, FBasePoint) and IsEqual(APnt2, Point2D(_ErrValue, _ErrValue)) then Exit;

  if IsEqual(APnt1, FBasePoint) then
  begin
    System.SetLength(Result, 1);
    LRay := TUdRay(Self.Clone());
    LRay.FBasePoint := APnt2;
    LRay.FSecondPoint := ShiftPoint(LRay.FBasePoint, UdGeo2D.GetAngle(FBasePoint, FSecondPoint), 100);
    LRay.Update();
    Result[0] := LRay;
  end else
  if IsEqual(APnt2, Point2D(_ErrValue, _ErrValue)) then
  begin
    System.SetLength(Result, 1);
    LLine := TUdLine.Create({Self.Document, False});
    LLine.BeginUpdate();
    try
      LLine.Assign(Self);
      LLine.StartPoint := FBasePoint;
      LLine.EndPoint   := APnt1;
    finally
      LLine.EndUpdate();
    end;
    Result[0] := LLine;
  end
  else begin
    System.SetLength(Result, 2);

    LLine := TUdLine.Create({Self.Document, False});
    LLine.BeginUpdate();
    try
      LLine.Assign(Self);
      LLine.StartPoint := FBasePoint;
      LLine.EndPoint   := APnt1;
    finally
      LLine.EndUpdate();
    end;
    Result[0] := LLine;

    LRay := TUdRay(Self.Clone());
    LRay.FBasePoint := APnt2;
    LRay.FSecondPoint := ShiftPoint(LRay.FBasePoint, UdGeo2D.GetAngle(FBasePoint, FSecondPoint), 100);
    LRay.Update();
    Result[1] := LRay;
  end;

end;



function GetRayTrimBreakPnts(ARay: TRay2D; APnt: TPoint2D; var AInctPnts: TPoint2DArray; var AP1, AP2: TPoint2D): Boolean;
var
  I: Integer;
  LDis: Float;
  LPnt: TPoint2D;
  LFound: Boolean;
begin
  Result := False;
  if System.Length(AInctPnts) <= 0 then Exit; //======>>>>

  LPnt := ClosestLinePoint(APnt, LineK(ARay.Base, ARay.Ang));
  LDis := Distance(ARay.Base, LPnt);

  LFound := False;

  UdGeo2D.SortPoints(AInctPnts, ARay.Base);
  for I := 0 to System.Length(AInctPnts) - 1 do
  begin
    if Distance(ARay.Base, AInctPnts[I]) > LDis then
    begin
      LFound := True;
      if I > 0 then AP1 := AInctPnts[I-1] else AP1 := ARay.Base;
      AP2 := AInctPnts[I];
      Break;
    end;
  end;

  if not LFound then
  begin
    AP1 := AInctPnts[High(AInctPnts)];
    AP2 := Point2D(_ErrValue, _ErrValue);
  end;

  Result := True;
end;

function TUdRay.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;
var
  LP1, LP2: TPoint2D;
  LInctPnts: TPoint2DArray;
begin
  Result := nil;

  LInctPnts := UdUtils.EntitiesIntersection(Self, ASelectedEntities);
  if GetRayTrimBreakPnts(Ray2D(FBasePoint, FSecondPoint), APnt, LInctPnts, LP1, LP2) then
    Result := Self.BreakAt(LP1, LP2);
end;




function TUdRay.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  if not Self.IsVisible or Self.IsLock() then Exit;
  if not AOther.IsVisible or AOther.IsLock() then Exit;

  Result := UdUtils.EntitiesIntersection(Self.GetXData(), AOther);
end;

function TUdRay.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  LLn: TLine2D;
  LPnt: TPoint2D;
begin
  Result := nil;

  LLn := UdGeo2D.Line2D(FBasePoint, FSecondPoint);

  LPnt := UdGeo2D.ClosestLinePoint(APnt, LLn);
  if UdGeo2D.IsPntOnRay(LPnt, GetXData()) then
  begin
    System.SetLength(Result, 1);
    Result[0] := LPnt;
  end;
end;





//-----------------------------------------------------------------------------------------

procedure TUdRay.SaveToStream(AStream: TStream);
begin
  inherited;

  FloatToStream(AStream, FBasePoint.X);
  FloatToStream(AStream, FBasePoint.Y);
  FloatToStream(AStream, FSecondPoint.X);
  FloatToStream(AStream, FSecondPoint.Y);
end;

procedure TUdRay.LoadFromStream(AStream: TStream);
begin
  inherited;

  FBasePoint.X  := FloatFromStream(AStream);
  FBasePoint.Y  := FloatFromStream(AStream);
  FSecondPoint.X  := FloatFromStream(AStream);
  FSecondPoint.Y  := FloatFromStream(AStream);

  FViewBound := Self.GetLayoutViewBound();

  Update();
end;




procedure TUdRay.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['BasePoint']   := Point2DToStr(FBasePoint);
  LXmlNode.Prop['SecondPoint'] := Point2DToStr(FSecondPoint);
end;

procedure TUdRay.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FBasePoint   := StrToPoint2D(LXmlNode.Prop['BasePoint']);
  FSecondPoint := StrToPoint2D(LXmlNode.Prop['SecondPoint']);

  FViewBound := Self.GetLayoutViewBound();

  Update();
end;





end.