{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdCircle;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes, UdEllipse; // , AxCanvas

type

  // -----------------------------------------------------
  TUdCircle = class(TUdFigure)
  private
    FRadius: Float;
    FCenter: TPoint2D;

  protected
    function GetTypeID(): Integer; override;

    function GetXData: TCircle2D;
    procedure SetXData(const AValue: TCircle2D);

    procedure SetRadius(const AValue: Float);
    procedure SetCenter(const AValue: TPoint2D);

    function GetDiameter: Float;
    procedure SetDiameter(const AValue: Float);

    function GetCenterValue(AIndex: Integer): Float;
    procedure SetCenterValue(AIndex: Integer; const AValue: Float);

    function GetArea: Float;
    procedure SetArea(const AValue: Float);

    function GetCircumference: Float;
    procedure SetCircumference(const AValue: Float);


    function CanFilled(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    procedure CopyFrom(AValue: TUdObject); override;
    
  public
    constructor Create(); override;
    destructor Destroy(); override;

    function AsEllipse(): TUdEllipse;

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
    property Center: TPoint2D  read FCenter write SetCenter;
    property XData: TCircle2D  read GetXData write SetXData;

  published
    property Radius: Float    read FRadius     write SetRadius;
    property Diameter: Float  read GetDiameter write SetDiameter;

    property CenterX: Float index 0 read GetCenterValue write SetCenterValue;
    property CenterY: Float index 1 read GetCenterValue write SetCenterValue;

    property Area: Float   read GetArea write SetArea;
    property Circumference: Float read GetCircumference write SetCircumference;

    property Filled;
    property FillStyle;

    property HasBorder;
    property BorderColor;

  end;

implementation

uses
  SysUtils,
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, {UdCircle,} UdArc;



//==================================================================================================
{ TUdCircle }

constructor TUdCircle.Create();
begin
  inherited;
  FRadius := 0.0;
  FCenter.X := 0.0;
  FCenter.Y := 0.0;
end;

destructor TUdCircle.Destroy;
begin
  inherited;
end;



function TUdCircle.GetTypeID: Integer;
begin
  Result := ID_CIRCLE;
end;

//function TUdCircle.GetCenter(): PPoint2D;
//begin
//  Result := @FCenter;
//end;




//-----------------------------------------------------------------------------------------


function TUdCircle.GetXData: TCircle2D;
begin
  Result := Circle2D(FCenter, FRadius);
end;

procedure TUdCircle.SetXData(const AValue: TCircle2D);
begin
  if Self.RaiseBeforeModifyObject('XData') then
  begin
    FCenter := AValue.Cen;
    FRadius := AValue.R;

    Self.Update();
    Self.RaiseAfterModifyObject('XData');
  end;
end;


procedure TUdCircle.SetCenter(const AValue: TPoint2D);
begin
  if NotEqual(FCenter, AValue) and Self.RaiseBeforeModifyObject('Center') then
  begin
    FCenter := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Center');
  end;
end;




function TUdCircle.GetCenterValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FCenter.X;
    1: Result := FCenter.Y;
  end;
end;

procedure TUdCircle.SetCenterValue(AIndex: Integer; const AValue: Float);
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




procedure TUdCircle.SetRadius(const AValue: Float);
begin
  if NotEqual(AValue, 0.0) and (FRadius <> AValue) and
     Self.RaiseBeforeModifyObject('Radius') then
  begin
    FRadius := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Radius');
  end;
end;


function TUdCircle.GetDiameter: Float;
begin
  Result := FRadius * 2;
end;

procedure TUdCircle.SetDiameter(const AValue: Float);
begin
  if NotEqual(AValue, 0.0) and (FRadius <> (AValue / 2)) and
     Self.RaiseBeforeModifyObject('Diameter'{, (AValue / 2)}) then
  begin
    FRadius := (AValue / 2);
    Self.Update();

    Self.RaiseAfterModifyObject('Diameter');
  end;
end;




function TUdCircle.GetArea: Float;
begin
  Result := PI * FRadius * FRadius;
end;

procedure TUdCircle.SetArea(const AValue: Float);
begin
  if (AValue > 0) and NotEqual(AValue, 0.0) and Self.RaiseBeforeModifyObject('Area') then
  begin
    FRadius := Sqrt(Abs(AValue) / PI);
    Self.Update();

    Self.RaiseAfterModifyObject('Area');
  end;
end;


function TUdCircle.GetCircumference: Float;
begin
  Result := 2 * PI * FRadius;
end;

procedure TUdCircle.SetCircumference(const AValue: Float);
begin
  if (AValue > 0) and NotEqual(AValue, 0.0) and Self.RaiseBeforeModifyObject('Circumference') then
  begin
    FRadius := AValue / (2 * PI);
    Self.Update();

    Self.RaiseAfterModifyObject('Circumference');
  end;
end;




procedure TUdCircle.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdCircle) then Exit; //========>>>

  Self.FRadius := TUdCircle(AValue).FRadius;
  Self.FCenter := TUdCircle(AValue).FCenter;

  Self.Update();
end;


function TUdCircle.AsEllipse(): TUdEllipse;
begin
  Result := TUdEllipse.Create({Self.Document, False});

  Result.BeginUpdate();
  try
    Result.Assign(Self);
    Result.XData := Ellipse2D(FCenter, FRadius, FRadius, 0);
  finally
    Result.EndUpdate();
  end;  
end;






//-----------------------------------------------------------------------------------------

function TUdCircle.CanFilled(): Boolean;
begin
  Result := True;
end;

procedure TUdCircle.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect := UdGeo2D.RectHull(UdGeo2D.Circle2D(FCenter, FRadius));
end;

procedure TUdCircle.UpdateSamplePoints(AAxes: TUdAxes);
var
  N: Integer;
begin
  FSamplePoints := nil;
  if IsEqual(FRadius, 0) then Exit; //=======>>>>

  N := SampleSegmentNum(AAxes.XValuePerPixel, Self.FRadius, 360.0);
  FSamplePoints := UdGeo2D.SamplePoints(Self.GetXData(), N);
end;





function TUdCircle.GetGripPoints(): TUdGripPointArray;
var
  I: Integer;
begin
  System.SetLength(Result, 5);

  Result[0] := MakeGripPoint(Self, gmCenter, 0, FCenter, 0.0);
  for I := 0 to 3 do
    Result[I+1] := MakeGripPoint(Self, gmSize, 0, GetArcPoint(FCenter, FRadius, 90*I), 90*I);
end;

function TUdCircle.GetOSnapPoints: TUdOSnapPointArray;
var
  I: Integer;
begin
  System.SetLength(Result, 5);

  Result[0] := MakeOSnapPoint(Self, OSNP_CEN, FCenter, -1);
  for I := 1 to 4 do
    Result[I] := MakeOSnapPoint(Self, OSNP_QUA, GetArcPoint(FCenter, FRadius, I * 90), -1);
end;






//-----------------------------------------------------------------------------------------

function TUdCircle.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;

  case AGripPnt.Mode of
    gmCenter: Result := Self.Move(FCenter, AGripPnt.Point);
    gmSize  :
      begin
        Self.Radius := Distance(AGripPnt.Point, FCenter);
        Result := True;
      end;
  end;
end;


function TUdCircle.Pick(APoint: TPoint2D): Boolean;
var
  E, D: Float;
  LAxes: TUdAxes;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;

  D := UdGeo2D.Distance(FCenter, APoint);
  Result := (D < E);

  if not Result then
    Result := UdGeo2D.IsPntOnCircle(APoint, Self.GetXData(), E);

  if not Result and Self.CanFilled() and FFilled then
    Result := UdGeo2D.IsPntInCircle(APoint, Self.GetXData(), E);
end;

function TUdCircle.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
var
  LIc: TInclusion;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LIc := UdGeo2D.Inclusion(FBoundsRect, ARect);
  Result := LIc = irOvered;

  if not Result and ACrossingMode then
    Result := UdGeo2D.IsIntersect(ARect, Self.GetXData()) and (LIc <> irOutside);
end;

function TUdCircle.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter := UdGeo2D.Translate(Dx, Dy, FCenter);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdCircle.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LTheCir, LNewCir: TCircle2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LTheCir := UdGeo2D.Circle2D(FCenter, FRadius);
  LNewCir := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LTheCir);

  FRadius := LNewCir.R;
  FCenter := LNewCir.Cen;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdCircle.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
var
  LNewR: Float;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ADis, 0.0)) then Exit; //======>>>>

  if UdGeo2D.IsPntInCircle(ASidePnt, UdGeo2D.Circle2D(FCenter, FRadius)) then
    LNewR := FRadius - ADis
  else
    LNewR := FRadius + ADis;

  if LNewR <= 0 then Exit;

  Self.RaiseBeforeModifyObject('');

  FRadius := LNewR;
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdCircle.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
var
  LNewCir: TCircle2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LNewCir := UdGeo2D.Rotate(ABase, ARota, UdGeo2D.Circle2D(FCenter, FRadius));

  FRadius := LNewCir.R;
  FCenter := LNewCir.Cen;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdCircle.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
var
  LNewCir: TCircle2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LNewCir := UdGeo2D.Scale(ABase, AFactor, UdGeo2D.Circle2D(FCenter, FRadius));

  FRadius := LNewCir.R;
  FCenter := LNewCir.Cen;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;



function TUdCircle.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEll: TEllipse2D;
  LEntity: TUdEntity;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  if IsEqual(XFactor, YFactor) then
  begin
    LEntity := TUdCircle.Create({Self.Document, False});

    LEntity.BeginUpdate();
    try
      LEntity.Assign(Self);
      TUdCircle(LEntity).XData := UdGeo2D.Scale(ABase, XFactor, Self.GetXData());
    finally
      LEntity.EndUpdate();
    end;

    System.SetLength(Result, 1);
    Result[0] := LEntity;
  end
  else begin
    LEntity := TUdEllipse.Create({Self.Document, False});

    LEntity.BeginUpdate();
    try
      LEntity.Assign(Self);

      if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
      begin
        LEll := UdGeo2D.Scale(ABase, XFactor, YFactor, Self.GetXData());
        TUdEllipse(LEntity).XData := LEll;
      end;
    finally
      LEntity.EndUpdate();
    end;

    System.SetLength(Result, 1);
    Result[0] := LEntity;
  end;
end;

function TUdCircle.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  LArc: TArc2D;
  LCir: TCircle2D;
  LArcObj: TUdArc;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>

  LCir := UdGeo2D.Circle2D(FCenter, FRadius);
  LArc := UdGeo2D.BreakAt(LCir, APnt1, APnt2);

  if LArc.R <= 0 then Exit; ////======>>>> Arc cannot be full 360 degrees

  LArcObj := TUdArc.Create({Self.Document, False});
  LArcObj.Assign(Self);
  LArcObj.XData := LArc;

  System.SetLength(Result, System.Length(Result) + 1);
  Result[High(Result)] := LArcObj;
end;


function TUdCircle.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;
var
  I: Integer;
  LCir: TCircle2D;
  LPnt: TPoint2D;
  LAng1, LAng2: Float;
  LFound: Boolean;
  LP1, LP2: TPoint2D;
  LInctPnts: TPoint2DArray;
begin
  Result := nil;

  LInctPnts := UdUtils.EntitiesIntersection(Self, ASelectedEntities);
  if System.Length(LInctPnts) <= 0 then Exit; //======>>>>

  LCir := Self.GetXData();

  LPnt := ClosestCirclePoint(APnt, LCir);
  LAng1 := GetAngle(FCenter, LPnt);

  LFound := False;

  UdGeo2D.SortPoints(LInctPnts, Arc2D(FCenter, FRadius, 0.0, 360.0, False));

  for I := 0 to System.Length(LInctPnts) - 1 do
  begin
    LAng2 := GetAngle(FCenter, LInctPnts[I]);
    if LAng2 > LAng1 then
    begin
      LFound := True;
      if I > 0 then
        LP1 := LInctPnts[I-1]
      else
        LP1 := GetArcPoint(FCenter, FRadius, 0);

      LP2 := LInctPnts[I];
      Break;
    end;
  end;

  if not LFound then
  begin
    LP1 := LInctPnts[High(LInctPnts)];
    LP2 := GetArcPoint(FCenter, FRadius, 360.0);
  end;

  Result := Self.BreakAt(LP1, LP2);
end;



function TUdCircle.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;

  if not Self.IsVisible or Self.IsLock() then Exit; //======>>>>
  if not Assigned(AOther) or not AOther.IsVisible or AOther.IsLock() then Exit; //======>>>>

  Result := UdUtils.EntitiesIntersection(Self.GetXData(), AOther);
end;

function TUdCircle.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  LLn: TLine2D;
begin
  LLn := UdGeo2D.Line2D(APnt, FCenter);
  Result := UdGeo2D.Intersection(LLn, Self.GetXData());
end;






//-----------------------------------------------------------------------------------------

procedure TUdCircle.SaveToStream(AStream: TStream);
begin
  inherited;

  FloatToStream(AStream, FRadius);
  FloatToStream(AStream, FCenter.X);
  FloatToStream(AStream, FCenter.Y);
end;

procedure TUdCircle.LoadFromStream(AStream: TStream);
begin
  inherited;

  FRadius := FloatFromStream(AStream);
  FCenter.X := FloatFromStream(AStream);
  FCenter.Y := FloatFromStream(AStream);

  Update();
end;





procedure TUdCircle.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Radius']  := FloatToStr(FRadius);
  LXmlNode.Prop['Center']  := Point2DToStr(FCenter);
end;

procedure TUdCircle.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FRadius := StrToFloatDef(LXmlNode.Prop['Radius'], 0);
  FCenter := StrToPoint2D(LXmlNode.Prop['Center']);

  Update();
end;

end.