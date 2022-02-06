{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPoint;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics,
  UdConsts, UdTypes, UdGTypes,
  UdObject, UdEntity, UdFigure, UdAxes, UdColor;


type

  //-----------------------------------------------------
  TUdPoint = class(TUdFigure)
  private
    FPosition: TPoint2D;

    FSize: Float;
    FStates: TUdPointStates;
    FDrawingUnits: Boolean;   // [Drawing Units] or [Windows Pixels]

  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;
    
    procedure SetSize(const AValue: Float);
    procedure SetPosition(const AValue: TPoint2D);
    procedure SetStates(const AValue: TUdPointStates);
    procedure SetDrawingUnits(const AValue: Boolean);

    function GetPositionValue(AIndex: Integer): Float;
    procedure SetPositionValue(AIndex: Integer; const AValue: Float);

    function CanFilled(): Boolean; override;
    function CanLinetype(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    function GetRadis(AAxis: TUdAxes): Float;
    function FDrawPoint(ACanvas: TCanvas; AColor: TColor; AAxes: TUdAxes; AFlag: Cardinal = 0): Boolean;

    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetGripPoints(): TUdGripPointArray; override;
    function GetOSnapPoints(): TUdOSnapPointArray; override;

    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;


    { operation... }
    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;

    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;
    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Offset(ADis: Float; ASidePnt: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;override;

  public
    property Position: TPoint2D read FPosition write SetPosition;
    property XData: TPoint2D read FPosition write SetPosition;

  published
    property Size: Float read FSize write SetSize;

    property PositionX: Float index 0 read GetPositionValue write SetPositionValue;
    property PositionY: Float index 1 read GetPositionValue write SetPositionValue;

    property States: TUdPointStates read FStates write SetStates;
    property DrawingUnits: Boolean read FDrawingUnits write SetDrawingUnits;

  end;

implementation


uses
  SysUtils,
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, UdDrawUtil;




//==================================================================================================
{ TUdPoint }

constructor TUdPoint.Create();
begin
  inherited;

  FPosition.X := 0.0;
  FPosition.Y := 0.0;

  FSize := 20.0;
  FStates := [psPoint];
  FDrawingUnits := False;
end;

destructor TUdPoint.Destroy;
begin
  inherited;
end;



function TUdPoint.GetTypeID: Integer;
begin
  Result := ID_POINT;
end;


procedure TUdPoint.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

  if Assigned(Self.PointStyle) then
    with Self.PointStyle do
    begin
      FSize := Size;
      FStates := States;
      FDrawingUnits := DrawingUnits;
    end;
end;


//-----------------------------------------------------------------------------------------

procedure TUdPoint.SetSize(const AValue: Float);
begin
  if (AValue > 0) and (FSize <> AValue) and Self.RaiseBeforeModifyObject('Size') then
  begin
    FSize := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Size');
  end;
end;

procedure TUdPoint.SetPosition(const AValue: TPoint2D);
begin
  if NotEqual(FPosition, AValue) and Self.RaiseBeforeModifyObject('Position') then
  begin
    FPosition := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Position');
  end;
end;


function TUdPoint.GetPositionValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FPosition.X;
    1: Result := FPosition.Y;
  end;
end;

procedure TUdPoint.SetPositionValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FPosition;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FPosition) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('PositionX');
    1: Self.RaiseBeforeModifyObject('PositionY');
  end;

  FPosition := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('PositionX');
    1: Self.RaiseAfterModifyObject('PositionY');
  end;
end;




procedure TUdPoint.SetStates(const AValue: TUdPointStates);
//var
//  I: Integer;
//  N: Cardinal;
begin
//  N := 0;
//  for I := Ord(psNull) to Ord(psXCross) do if TUdPointState(I) in AValue then N := N or (LongWord(1) shr I);

  if (FStates <> AValue) and Self.RaiseBeforeModifyObject('States'{, N}) then
  begin
    FStates := AValue;
    Self.Refresh();
    Self.RaiseAfterModifyObject('States');
  end;
end;

procedure TUdPoint.SetDrawingUnits(const AValue: Boolean);
begin
  if (FDrawingUnits <> AValue) and Self.RaiseBeforeModifyObject('DrawingUnits') then
  begin
    FDrawingUnits := AValue;
    Self.Refresh();
    Self.RaiseAfterModifyObject('DrawingUnits');
  end;
end;






procedure TUdPoint.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdPoint) then Exit; //========>>>

  FPosition   := TUdPoint(AValue).FPosition;
  FSize     := TUdPoint(AValue).FSize;
  FStates   := TUdPoint(AValue).FStates;
  FDrawingUnits := TUdPoint(AValue).FDrawingUnits;

  Self.Update();
end;



//-----------------------------------------------------------------------------------------

function TUdPoint.GetRadis(AAxis: TUdAxes): Float;
begin
  if FDrawingUnits then
    Result := (FSize / 2) * AAxis.XPixelPerValue
  else
    Result := FSize / 2;
end;

function TUdPoint.FDrawPoint(ACanvas: TCanvas; AColor: TColor; AAxes: TUdAxes; AFlag: Cardinal = 0): Boolean;
var
  R: Float;
  X, Y: Integer;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>

  ACanvas.Pen.Mode := pmCopy;
  ACanvas.Pen.Width := 1;

  if Self.Selected then
  begin
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Color := SELECTED_COLOR;
  end
  else begin
    ACanvas.Pen.Style := psSolid;
    ACanvas.Pen.Color := AColor;
  end;

  X := AAxes.XPixel(FPosition.X);
  Y := AAxes.YPixel(FPosition.Y);
  R := Self.GetRadis(AAxes);


  if (psPoint  in FStates) then ACanvas.Pixels[X, Y] := ACanvas.Pen.Color;
  if (psLine   in FStates) then
  begin
    ACanvas.MoveTO(X, Y);
    ACanvas.LineTo(X, Y-Round(R/2));
  end;
  if (psRect   in FStates) then DrawRect(ACanvas,   X, Y, Round(R/2), False);
  if (psQuare  in FStates) then DrawQuare(ACanvas,  X, Y, Round(R/2));
  if (psCircle in FStates) then DrawCircle(ACanvas, X, Y, Round(R/2));
  if (psCross  in FStates) then DrawCross(ACanvas,  X, Y, Round(R/2));
  if (psXCross in FStates) then DrawXCross(ACanvas, X, Y, Round(R/2));


  Result := True;
end;

function TUdPoint.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>

  FDrawPoint(ACanvas, Self.ActualTrueColor(AFlag), AAxes, AFlag);

  Result := True;
end;






//-----------------------------------------------------------------------------------------

function TUdPoint.CanFilled(): Boolean;
begin
  Result := False;
end;

function TUdPoint.CanLinetype(): Boolean;
begin
  Result := False;
end;

procedure TUdPoint.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect.X1 := FPosition.X - FSize;
  FBoundsRect.Y1 := FPosition.Y - FSize;
  FBoundsRect.X2 := FPosition.X + FSize;
  FBoundsRect.Y2 := FPosition.Y + FSize;
end;

procedure TUdPoint.UpdateSamplePoints(AAxes: TUdAxes);
begin
  FSamplePoints := nil;
end;



function TUdPoint.GetGripPoints(): TUdGripPointArray;
begin
  SetLength(Result, 1);
  Result[0] := MakeGripPoint(Self, gmCenter, 0,  FPosition, 0.0);
end;

function TUdPoint.GetOSnapPoints: TUdOSnapPointArray;
begin
  SetLength(Result, 1);
  Result[0] := MakeOSnapPoint(Self, OSNP_NOD, FPosition, -1);
end;








//-----------------------------------------------------------------------------------------

function TUdPoint.Pick(APoint: TPoint2D): Boolean;
var
  E: Float;
  LAxes: TUdAxes;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;

  Result := UdGeo2D.Distance(FPosition, APoint) <= E;
end;

function TUdPoint.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.IsPntInRect(FPosition, ARect);
end;


function TUdPoint.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;

  case AGripPnt.Mode of
    gmCenter: Result := Self.Move(FPosition, AGripPnt.Point);
  end;
end;


function TUdPoint.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('Position');

  FPosition := UdGeo2D.Translate(Dx, Dy, FPosition);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('Position');
end;

function TUdPoint.Mirror(APnt1, APnt2: TPoint2D): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('Position');

  FPosition := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FPosition);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('Position');
end;

function TUdPoint.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
begin
  Result := False;
end;

function TUdPoint.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('Position');

  FPosition := UdGeo2D.Rotate(ABase, ARota, FPosition );
  Result := Self.Update();

  Self.RaiseAfterModifyObject('Position');
end;

function TUdPoint.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('Position');

  FPosition := UdGeo2D.Scale(ABase, AFactor, AFactor, FPosition );
  Result := Self.Update();

  Self.RaiseAfterModifyObject('Position');
end;



function TUdPoint.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  SetLength(Result, 1);
  Result[0] := Self.Clone();

  if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
  begin
    TUdPoint(Result[0]).Position := UdGeo2D.Scale(ABase, XFactor, YFactor, FPosition);
  end;
end;




//-----------------------------------------------------------------------------------------

procedure TUdPoint.SaveToStream(AStream: TStream);
var
  I: Integer;
  N: Cardinal;
begin
  inherited;

  FloatToStream(AStream, FPosition.X);
  FloatToStream(AStream, FPosition.Y);

  FloatToStream(AStream, FSize);
  BoolToStream(AStream, FDrawingUnits);


  N := 0;
  for I := Ord(psNull) to Ord(psXCross) do
    if TUdPointState(I) in FStates then
      N := N or (LongWord(1) shl I);

  CarToStream(AStream, N);
end;

procedure TUdPoint.LoadFromStream(AStream: TStream);
var
  I: Integer;
  N: Cardinal;
begin
  inherited;

  FPosition.X := FloatFromStream(AStream);
  FPosition.Y := FloatFromStream(AStream);

  FSize     := FloatFromStream(AStream);
  FDrawingUnits := BoolFromStream(AStream);

  FStates := [];
  N := CarFromStream(AStream);
  for I := Ord(psNull) to Ord(psXCross) do
    if N and (LongWord(1) shl I) > 0 then
      Include(FStates, TUdPointState(I));

  Update();
end;




procedure TUdPoint.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I: Integer;
  N: Cardinal;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Position']     := Point2DToStr(FPosition);
  LXmlNode.Prop['Size']         := FloatToStr(FSize);
  LXmlNode.Prop['DrawingUnits'] := BoolToStr(FDrawingUnits, True);

  N := 0;
  for I := Ord(psNull) to Ord(psXCross) do
    if TUdPointState(I) in FStates then
      N := N or (LongWord(1) shr I);

  LXmlNode.Prop['States'] := IntToStr(N);
end;

procedure TUdPoint.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  N: Cardinal;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);


  FPosition := StrToPoint2D(LXmlNode.Prop['Position']);
  FSize     := StrToFloatDef(LXmlNode.Prop['FSize'],20.0);
  FDrawingUnits := StrToBoolDef(LXmlNode.Prop['DrawingUnits']  , False);

  N := StrToIntDef(LXmlNode.Prop['States'], 0);

  FStates := [];
  for I := Ord(psNull) to Ord(psXCross) do
    if N and (LongWord(1) shr I) > 0 then
      Include(FStates, TUdPointState(I));

  Update();
end;

end.