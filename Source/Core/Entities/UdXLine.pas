{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdXLine;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes;

type

  //-----------------------------------------------------
  TUdXLine = class(TUdFigure)
  private
    FBasePoint: TPoint2D;
    FSecondPoint: TPoint2D;

    FViewSeg: TSegment2D;
    FViewBound: TRect2D;

  protected
    function GetTypeID(): Integer; override;

    function GetAngle: Float;
    procedure SetAngle(const AValue: Float);

    function GetXData: TLine2D;
    procedure SetXData(const AValue: TLine2D);

    procedure SetPoint(AIndex: Integer; const AValue: TPoint2D);

    function GetBasePoint(AIndex: Integer): Float;
    function GetSecondPoint(AIndex: Integer): Float;

    procedure SetBasePoint(AIndex: Integer; const AValue: Float);
    procedure SetSecondPoint(AIndex: Integer; const AValue: Float);


    function CanFilled(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    {....}
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

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;
    function Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray; override;
    function BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray; override;

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

    property XData: TLine2D  read GetXData write SetXData;

  published
    property Angle: Float read GetAngle write SetAngle;

    property BasePointX: Float index 0 read GetBasePoint write SetBasePoint;
    property BasePointY: Float index 1 read GetBasePoint write SetBasePoint ;

    property SecondPointX: Float index 0 read GetSecondPoint write SetSecondPoint;
    property SecondPointY: Float index 1 read GetSecondPoint write SetSecondPoint;
  end;


implementation

uses
  SysUtils, UdRay,
  UdMath, UdGeo2D, UdUtils, UdStrConverter, UdStreams, UdXml;




//==================================================================================================
{ TUdXLine }

constructor TUdXLine.Create();
begin
  inherited;

  FBasePoint.X := 0.0;
  FBasePoint.Y := 0.0;
  FSecondPoint.X := 0.0;
  FSecondPoint.Y := 0.0;

  FViewSeg := Segment2D(0, 0, 0, 0);
  FViewBound := Rect2D(0, 0, 0, 0);
end;

destructor TUdXLine.Destroy;
begin
  inherited;
end;




function TUdXLine.GetTypeID: Integer;
begin
  Result := ID_XLINE;
end;



//-----------------------------------------------------------------------------------------

function TUdXLine.GetAngle: Float;
begin
  Result := UdGeo2D.GetAngle(FBasePoint, FSecondPoint);
end;

procedure TUdXLine.SetAngle(const AValue: Float);
begin
  if Self.RaiseBeforeModifyObject('Angle') then
  begin
    FSecondPoint := ShiftPoint(FBasePoint, AValue, 100);
    Self.Update();
    Self.RaiseAfterModifyObject('Angle');
  end;
end;


function TUdXLine.GetBasePoint(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FBasePoint.X;
    1: Result := FBasePoint.Y;
  end;
end;


function TUdXLine.GetSecondPoint(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FSecondPoint.X;
    1: Result := FSecondPoint.Y;
  end;
end;



procedure TUdXLine.SetBasePoint(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FBasePoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  Self.BasePoint := LPnt;
end;

procedure TUdXLine.SetSecondPoint(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FSecondPoint;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  Self.SecondPoint := LPnt;
end;


function TUdXLine.GetXData: TLine2D;
begin
  Result := Line2D(FBasePoint, FSecondPoint);
end;


procedure TUdXLine.SetXData(const AValue: TLine2D);
begin
  if Self.RaiseBeforeModifyObject('XData') then
  begin
    FBasePoint   := AValue.P1;
    FSecondPoint := AValue.P2;

    Self.Update();
    Self.RaiseAfterModifyObject('XData');
  end;
end;

procedure TUdXLine.SetPoint(AIndex: Integer; const AValue: TPoint2D);
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





procedure TUdXLine.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdXLine) then Exit; //========>>>

  Self.FBasePoint   := TUdXLine(AValue).FBasePoint;
  Self.FSecondPoint := TUdXLine(AValue).FSecondPoint;

  Self.Update();
end;

function TUdXLine.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
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

function TUdXLine.CanFilled(): Boolean;
begin
  Result := False;
end;

procedure TUdXLine.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect := UdGeo2D.RectHull(FViewSeg.P1, FViewSeg.P2);
end;

procedure TUdXLine.UpdateSamplePoints(AAxes: TUdAxes);
var
  LInctPnts: TPoint2DArray;
begin
  FSamplePoints := nil;
  if IsEqual(FBasePoint, FSecondPoint) then Exit;

  LInctPnts := UdGeo2D.Intersection(Line2D(FBasePoint, FSecondPoint), FViewBound);
  if System.Length(LInctPnts) = 2 then
  begin
    FViewSeg.P1 := LInctPnts[0];
    FViewSeg.P2 := LInctPnts[1];

    FSamplePoints := UdGeo2D.SamplePoints(FViewSeg, 0);
  end;
end;



function TUdXLine.GetGripPoints(): TUdGripPointArray;
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

    System.SetLength(Result, 3);
    Result[0] := MakeGripPoint(Self, gmPoint, 0, FBasePoint, 0);
    Result[1] := MakeGripPoint(Self, gmPoint, 1, ShiftPoint(FBasePoint, LAng, +LDis), 0);
    Result[2] := MakeGripPoint(Self, gmPoint, 2, ShiftPoint(FBasePoint, LAng, -LDis), 0);
  end;
end;

function TUdXLine.GetOSnapPoints: TUdOSnapPointArray;
begin
  Result := nil;
end;






//-----------------------------------------------------------------------------------------


function TUdXLine.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  LAng: Float;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    if AGripPnt.Index = 0 then
    begin
      Result := Self.Move(FBasePoint, AGripPnt.Point);
    end
    else begin
      LAng := UdGeo2D.GetAngle(FBasePoint, AGripPnt.Point);
      Self.SetXData(Line2D(FBasePoint, ShiftPoint(FBasePoint, LAng, 100)));
      Result := True;
    end;
  end;
end;


function TUdXLine.Pick(APoint: TPoint2D): Boolean;
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
    D := DistanceToLine(APoint, Self.GetXData());
    Result := (D < FPenWidth/2) or IsEqual(D, FPenWidth/2, E);
  end
  else
    Result := UdGeo2D.IsPntOnLine(APoint, Self.GetXData(), E);
end;

function TUdXLine.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.Inclusion(FBoundsRect, ARect) = irOvered;

  if not Result and ACrossingMode then
    Result := UdGeo2D.IsIntersect(Self.GetXData(), ARect);
end;

function TUdXLine.Move(Dx, Dy: Float): Boolean;
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


function TUdXLine.Mirror(APnt1, APnt2: TPoint2D): Boolean;
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

function TUdXLine.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
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

function TUdXLine.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
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

function TUdXLine.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
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




function TUdXLine.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LSeg: TSegment2D;
  LEntity: TUdXLine;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdXLine.Create({Self.Document, False});

  LEntity.BeginUpdate();
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      LSeg := Segment2D(FBasePoint, FSecondPoint);
      LSeg := UdGeo2D.Scale(ABase, XFactor, YFactor, LSeg);

      LEntity.XData := Line2D(LSeg.P1, LSeg.P2);
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;

function TUdXLine.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  LRay: TUdRay;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>

  if IsEqual(APnt2.X, _ErrValue) then
  begin
    if NotEqual(APnt2.Y, _ErrValue) then
    begin
      System.SetLength(Result, 1);

      LRay := TUdRay.Create({Self.Document, False});
      LRay.BeginUpdate();
      try
        LRay.BasePoint := APnt1;
        LRay.SecondPoint := ShiftPoint(LRay.BasePoint, APnt2.Y, 100);
      finally
        LRay.EndUpdate();
      end;

      Result[0] := LRay;
    end;
  end

  else begin
    System.SetLength(Result, 2);

    LRay := TUdRay.Create({Self.Document, False});
    LRay.BeginUpdate();
    try
      LRay.BasePoint := APnt2;
      LRay.SecondPoint := ShiftPoint(LRay.BasePoint, UdGeo2D.GetAngle(APnt1, APnt2), 100);
    finally
      LRay.EndUpdate();
    end;
    Result[0] := LRay;

    LRay := TUdRay.Create({Self.Document, False});
    LRay.BeginUpdate();
    try
      LRay.BasePoint := APnt1;
      LRay.SecondPoint := ShiftPoint(LRay.BasePoint, UdGeo2D.GetAngle(APnt2, APnt1), 100);
    finally
      LRay.EndUpdate();
    end;
    Result[1] := LRay;
  end;
end;






function GetLineTrimBreakPnts(ABasePnt: TPoint2D; ALnAng: Float; var APnt: TPoint2D; var AInctPnts: TPoint2DArray; var AP1, AP2: TPoint2D): Boolean;
var
  I: Integer;
  LAng: Float;
  LFound: Boolean;
  LP1, LP2: TPoint2D;
begin
  Result := False;
  if System.Length(AInctPnts) <= 0 then Exit; //======>>>>

  APnt := ClosestLinePoint(APnt, LineK(ABasePnt, ALnAng));
  LAng := GetAngle(ABasePnt, APnt);

  LFound := False;

  UdGeo2D.SortPoints(AInctPnts, ABasePnt, LAng);
  for I := 0 to System.Length(AInctPnts) - 2 do
  begin
    LP1 := AInctPnts[I];
    LP2 := AInctPnts[I+1];
    if IsPntOnSegment(APnt, Segment2D(LP1, LP2)) then
    begin
      LFound := True;
      AP1 := LP1;
      AP2 := LP2;
      Break;
    end;
  end;

  if not LFound then
  begin
    if Distance(APnt, AInctPnts[0]) < Distance(APnt, AInctPnts[High(AInctPnts)]) then
      AP1 := AInctPnts[0]
    else
      AP1 := AInctPnts[High(AInctPnts)];

    AP2 := Point2D(_ErrValue, _ErrValue);
  end;

  Result := True;
end;


function TUdXLine.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;
var
  LPnt: TPoint2D;
  LP1, LP2: TPoint2D;
  LInctPnts: TPoint2DArray;
begin
  Result := nil;

  LPnt := APnt;
  LInctPnts := UdUtils.EntitiesIntersection(Self, ASelectedEntities);
  if GetLineTrimBreakPnts(FBasePoint, UdGeo2D.GetAngle(FBasePoint, FSecondPoint), LPnt, LInctPnts, LP1, LP2) then
  begin
    if IsEqual(LP2, Point2D(_ErrValue, _ErrValue)) then
    begin
      if System.Length(LInctPnts) > 1 then
      begin
        if IsEqual(LP1, LInctPnts[0]) then
          LP2.Y := UdGeo2D.GetAngle(LInctPnts[0], LInctPnts[High(LInctPnts)])
        else if IsEqual(LP1, LInctPnts[High(LInctPnts)]) then
          LP2.Y := UdGeo2D.GetAngle(LInctPnts[High(LInctPnts)], LInctPnts[0]);
      end
      else begin
        LP2.Y := UdGeo2D.GetAngle(LPnt, LInctPnts[0]);
      end;
    end;

    Result := Self.BreakAt(LP1, LP2);
  end;
end;





function TUdXLine.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  if not Self.IsVisible or Self.IsLock() then Exit;
  if not AOther.IsVisible or AOther.IsLock() then Exit;

  Result := UdUtils.EntitiesIntersection(Self.GetXData(), AOther);
end;

function TUdXLine.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  LLn: TLine2D;
begin
  LLn := UdGeo2D.Line2D(FBasePoint, FSecondPoint);

  System.SetLength(Result, 1);
  Result[0] := UdGeo2D.ClosestLinePoint(APnt, LLn);
end;




//-----------------------------------------------------------------------------------------

procedure TUdXLine.SaveToStream(AStream: TStream);
begin
  inherited;

  FloatToStream(AStream, FBasePoint.X);
  FloatToStream(AStream, FBasePoint.Y);
  FloatToStream(AStream, FSecondPoint.X);
  FloatToStream(AStream, FSecondPoint.Y);
end;

procedure TUdXLine.LoadFromStream(AStream: TStream);
begin
  inherited;

  FBasePoint.X  := FloatFromStream(AStream);
  FBasePoint.Y  := FloatFromStream(AStream);
  FSecondPoint.X  := FloatFromStream(AStream);
  FSecondPoint.Y  := FloatFromStream(AStream);

  FViewBound := Self.GetLayoutViewBound();

  Update();
end;




procedure TUdXLine.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['BasePoint']   := Point2DToStr(FBasePoint);
  LXmlNode.Prop['SecondPoint'] := Point2DToStr(FSecondPoint);
end;

procedure TUdXLine.LoadFromXml(AXmlNode: TObject);
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