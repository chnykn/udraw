{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdAxes;

{$I UdDefs.INC}
{$DEFINE UD_TIMER}

interface

uses
  Windows, Classes, Controls,
  UdTypes, UdGTypes, UdConsts, UdIntfs, UdObject
  {$IFDEF UD_TIMER}, UdTimer {$ELSE}, ExtCtrls {$ENDIF} ;

const
  AXIS_X = 1;
  AXIS_Y = 2;
  //AXIS_Z = 4;
  AXIS_ALL = AXIS_X or AXIS_Y {or AXIS_Z};

type

  TUdGetAxesSizeEvent = procedure(Sender: TObject; var AWidth, AHeight: Integer; var ASuccess: Boolean) of object;

  TUdAxisData = record
    Size: Float;          // Pixel count
    Min, Max: Float;      // Cartesian's min and max

    Pan: Float;           // Pan pixel count

    PixelPerValue: Float; // Pixel/Value
    ValuePerPixel: Float; // Value/Pixel
  end;

  //*** TUdAxes ***//
  TUdAxes = class(TUdObject, IUdAxes)
  private
    FXAxis: TUdAxisData;
    FYAxis: TUdAxisData;

    FScale: Float;

    FMargin: Integer;
    FLimRect: TRect2D;

    FWidth : Float;
    FHeight: Float;

    FChangedTimer: {$IFDEF UD_TIMER} TUdTimer {$ELSE} TTimer {$ENDIF};
    FParmsLog: Pointer;
    FParmsLogs: TList;

    FOnAxesChanging: TNotifyEvent;
    FOnAxesChanged : TNotifyEvent;

  protected
    function GetTypeID(): Integer; override;

    procedure SetMargin(const AValue: Integer);
    procedure SetLimRect(const AValue: TRect2D);

    function GetPan(AIndex: Integer): Float;
    procedure SetPan_(AIndex: Integer; const AValue: Float);

    function GetSize(AIndex: Integer): Float;
    procedure SetSize(AIndex: Integer; const AValue: Float);

    function GetXBound(AIndex: Integer): Float;
    procedure SetXBound(AIndex: Integer; const AValue: Float);

    function GetYBound(AIndex: Integer): Float;
    procedure SetYBound(AIndex: Integer; const AValue: Float);

    {IUdAxes...}
    function GetPixelPerValue(AIndex: Integer): Float;
    function GetValuePerPixel(AIndex: Integer): Float;


    procedure GenParmsLog();

    procedure RaiseAxesChanging();
    procedure RaiseAxesChanged();
    procedure OnChangedTimer(Sender: TObject);

    function SetAxis(ABounds: TRect2D; APan: TPoint2D; AScale: Float): Boolean;
    function CalcAxis(AWidth, AHeight: Float; XBound, YBound: PPoint2D; XPan: PFloat = nil; YPan: PFloat = nil): Boolean; overload;

    property _OnAxesChanging : TNotifyEvent read FOnAxesChanging write FOnAxesChanging;
    property _OnAxesChanged  : TNotifyEvent read FOnAxesChanged  write FOnAxesChanged;


    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function CalcAxis(AFlag: LongWord = AXIS_ALL): Boolean; overload;

    function CalcAxis(AWidth, AHeight: Float; XPan: PFloat = nil; YPan: PFloat = nil): Boolean; overload;
    function CalcAxis(AWidth, AHeight: Float; XBound, YBound: TPoint2D; XPan: PFloat = nil; YPan: PFloat = nil): Boolean; overload;
    function CalcAxis(AWidth, AHeight: Float; ABounds: TRect2D; XPan: PFloat = nil; YPan: PFloat = nil): Boolean; overload;

    procedure ClearZoomLog();


    {IUdAxes...}
    function XPixel(const X: Float): Integer;
    function YPixel(const Y: Float): Integer;
    function XValue(const X: Float): Float;
    function YValue(const Y: Float): Float;

    function XPixelF(const X: Float): Float;
    function YPixelF(const Y: Float): Float;

    function PointPixel(const AValuePnt: TPoint2D): TPoint;
    function PointValue(const APixelPnt: TPoint): TPoint2D; overload;

    function PointsPixel(const AValuePnts: TPoint2DArray): TPointArray;
    function PointsValue(const APixelPnts: TPointArray): TPoint2DArray; overload;



    {Zoom...}
    procedure Pan(DX, DY: Float; ARaiseChange: Boolean = True);
    procedure SetPan(X, Y: Float);

    procedure ZoomIn();
    procedure ZoomOut();
    procedure ZoomScale(const AValue: Float);
    procedure ZoomPrevious();
    procedure ZoomWindow(ARect: TRect2D; AExtends: Boolean);
    procedure ZoomCenter(ACen: TPoint2D);

    function DyncScale(const AValue: Float; ABase: TPoint2D): Boolean;

    { Save&Load... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Scale: Float  read FScale write ZoomScale;
    property Margin: Integer  read FMargin  write SetMargin;
    property LimRect: TRect2D read FLimRect write SetLimRect;

    property XSize: Float index 0 read GetSize write SetSize;
    property YSize: Float index 1 read GetSize write SetSize;

    property XPan: Float  index 0 read GetPan write SetPan_;
    property YPan: Float  index 1 read GetPan write SetPan_;

    property XMin: Float index 0 read GetXBound write SetXBound;
    property XMax: Float index 1 read GetXBound write SetXBound;
    property YMin: Float index 0 read GetYBound write SetYBound;
    property YMax: Float index 1 read GetYBound write SetYBound;

    property XPixelPerValue: Float index 0 read GetPixelPerValue;
    property YPixelPerValue: Float index 1 read GetPixelPerValue;
    property XValuePerPixel: Float index 0 read GetValuePerPixel;
    property YValuePerPixel: Float index 1 read GetValuePerPixel;


    property Width : Float read FWidth;
    property Height: Float read FHeight;

    property XAxis: TUdAxisData read FXAxis;
    property YAxis: TUdAxisData read FYAxis;
  end;



//var
//  GPixelCount: Cardinal;
//  GPixelFCount: Cardinal;
//  GValueCount: Cardinal;

implementation

uses
  SysUtils,
  UdLayout, UdMath, UdGeo2D, UdStrConverter, UdStreams, UdXml;

const
  DEFAULE_SIZE = 100;
  AXIS_EPSILON = 1E-4;//  Epsilon
  AXES_CHANGED_DELAY = 30;//0 {ms};


type
  //*** TUdAxesParms ***//
  TUdAxesParms = packed record
    XPan, YPan: Float;
    XMax, YMax: Float;
    XMin, YMin: Float;
  end;
  PUdAxesParms = ^TUdAxesParms;




procedure InitAxes(var AAxis: TUdAxisData);
begin
  AAxis.Size := DEFAULE_SIZE;
  AAxis.Pan  := 0;
  AAxis.Min  := 0;
  AAxis.Max  := DEFAULE_SIZE / 10;
  AAxis.PixelPerValue := AAxis.Size / (AAxis.Max - AAxis.Min);
  AAxis.ValuePerPixel := (AAxis.Max - AAxis.Min) / AAxis.Size;
end;



//===================================================================================================
{ TUdAxes }

constructor TUdAxes.Create();
begin
  inherited;

  FMargin  := 0;
  FScale   := 100;
  FLimRect := Rect2D(0, 0, 420, 297); //A3

  FWidth   := DEFAULE_SIZE;
  FHeight  := DEFAULE_SIZE;

  InitAxes(FXAxis);
  InitAxes(FYAxis);

  FChangedTimer := {$IFDEF UD_TIMER} TUdTimer.Create() {$ELSE} TTimer.Create(nil) {$ENDIF};
  FChangedTimer.Enabled := False;
  FChangedTimer.Interval := AXES_CHANGED_DELAY;
  FChangedTimer.OnTimer := OnChangedTimer;

  FParmsLog  := nil;
  FParmsLogs := TList.Create;
end;

destructor TUdAxes.Destroy;
var
  I: Integer;
begin
  for I := FParmsLogs.Count - 1 downto 0 do Dispose(PUdAxesParms(FParmsLogs[I]));
  FParmsLogs.Free;
  FParmsLogs := nil;

  if Assigned(FParmsLog) then Dispose(FParmsLog);
  FParmsLog := nil;

  if Assigned(FChangedTimer) then
  begin
    FChangedTimer.Enabled := False;
    FChangedTimer.Free;
  end;
  FChangedTimer := nil;


  inherited;
end;

function TUdAxes.GetTypeID: Integer;
begin
  Result := ID_AXIS;
end;




//---------------------------------------------------------------------------------

procedure TUdAxes.SetMargin(const AValue: Integer);
begin
  FMargin := AValue;
end;

procedure TUdAxes.SetLimRect(const AValue: TRect2D);
begin
  FLimRect := AValue;
end;

function TUdAxes.GetPan(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FXAxis.Pan;
    1: Result := FYAxis.Pan;
  end;
end;

procedure TUdAxes.SetPan_(AIndex: Integer; const AValue: Float);
begin
  case AIndex of
    0: FXAxis.Pan := AValue;
    1: FYAxis.Pan := AValue;
  end;
end;



function TUdAxes.GetSize(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FXAxis.Size;
    1: Result := FYAxis.Size;
  end;
end;

procedure TUdAxes.SetSize(AIndex: Integer; const AValue: Float);
begin
  case AIndex of
    0: FXAxis.Size := AValue;
    1: FYAxis.Size := AValue;
  end;
end;


function TUdAxes.GetXBound(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FXAxis.Min;
    1: Result := FXAxis.Max;
  end;
end;

procedure TUdAxes.SetXBound(AIndex: Integer; const AValue: Float);
begin
  case AIndex of
    0: FXAxis.Min := AValue;
    1: FXAxis.Max := AValue;
  end;
end;


function TUdAxes.GetYBound(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FYAxis.Min;
    1: Result := FYAxis.Max;
  end;
end;

procedure TUdAxes.SetYBound(AIndex: Integer; const AValue: Float);
begin
  case AIndex of
    0: FYAxis.Min := AValue;
    1: FYAxis.Max := AValue;
  end;
end;


function TUdAxes.GetPixelPerValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FXAxis.PixelPerValue;
    1: Result := FYAxis.PixelPerValue;
  end;
end;

function TUdAxes.GetValuePerPixel(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FXAxis.ValuePerPixel;
    1: Result := FYAxis.ValuePerPixel;
  end;
end;




procedure TUdAxes.CopyFrom(AValue: TUdObject);
begin
  inherited;
  if not AValue.InheritsFrom(TUdAxes) then Exit;

  FScale  := TUdAxes(AValue).FScale;
  FMargin := TUdAxes(AValue).FMargin;
  FWidth  := TUdAxes(AValue).FWidth;
  FHeight := TUdAxes(AValue).FHeight;

  FXAxis := TUdAxes(AValue).FXAxis;
  FYAxis := TUdAxes(AValue).FYAxis;
end;



//---------------------------------------------------------------------------------

function TUdAxes.CalcAxis(AFlag: LongWord = AXIS_ALL): Boolean;
begin
  if (AFlag and AXIS_X) > 0 then
  begin
    with FXAxis do
    begin
      PixelPerValue := Size / (Max - Min);
      ValuePerPixel := (Max - Min) / Size;
    end;
  end;

  if (AFlag and AXIS_Y) > 0 then
  begin
    with FYAxis do
    begin
      PixelPerValue := Size / (Max - Min);
      ValuePerPixel := (Max - Min) / Size;
    end;
  end;

  Result := True;
end;


function TUdAxes.CalcAxis(AWidth, AHeight: Float; XBound, YBound: PPoint2D; XPan: PFloat = nil; YPan: PFloat = nil): Boolean;
var
  LDelta: Float;
begin
  Result := False;

  if Assigned(XBound) and Assigned(YBound) then
  begin
    if (IsEqual(XBound^.X, XBound^.Y) or (XBound^.X >= XBound^.Y)) and
       (IsEqual(YBound^.X, YBound^.Y) or (YBound^.X >= YBound^.Y)) then Exit;  //======>>>>>
  end
  else begin
    if Assigned(XBound) then
    begin
      if (IsEqual(XBound^.X, XBound^.Y) or (XBound^.X >= XBound^.Y)) then Exit;  //======>>>>>
    end
    else if Assigned(YBound) then
    begin
      if (IsEqual(YBound^.X, YBound^.Y) or (YBound^.X >= YBound^.Y)) then Exit;  //======>>>>>
    end;
  end;


  if (AWidth < (2 * FMargin)) or (AHeight < (2 * FMargin)) then Exit;

  FWidth  := AWidth;
  FHeight := AHeight;

  if Assigned(XBound) then
  begin
    FXAxis.Min := XBound^.X;
    FXAxis.Max := XBound^.Y;
  end;

  if Assigned(YBound) then
  begin
    FYAxis.Min := YBound^.X;
    FYAxis.Max := YBound^.Y;
  end;

  FXAxis.Size := FWidth  - (2 * FMargin);
  FYAxis.Size := FHeight - (2 * FMargin);

  if Assigned(XPan) then FXAxis.Pan := XPan^;
  if Assigned(YPan) then FYAxis.Pan := YPan^;

  with FXAxis do
  begin
    if IsEqual(Max, Min) then
    begin
      ValuePerPixel := -1;
    end
    else begin
      PixelPerValue := Size / (Max - Min);
      ValuePerPixel := (Max - Min) / Size;
    end;
  end;

  with FYAxis do
  begin
    if IsEqual(Max, Min) then
    begin
      ValuePerPixel := -1;
    end
    else begin
      PixelPerValue := Size / (Max - Min);
      ValuePerPixel := (Max - Min) / Size;
    end;
  end;

  if Abs(FXAxis.ValuePerPixel - FYAxis.ValuePerPixel) > AXIS_EPSILON then
  begin
    if FXAxis.ValuePerPixel > FYAxis.ValuePerPixel then
    begin
      LDelta := FYAxis.Size * FXAxis.ValuePerPixel - (FYAxis.Max - FYAxis.Min);
      FYAxis.Max := FYAxis.Max + LDelta / 2;
      FYAxis.Min := FYAxis.Min - LDelta / 2;

      with FYAxis do
      begin
        PixelPerValue := Size / (Max - Min);
        ValuePerPixel := (Max - Min) / Size;
      end;
    end
    else if FXAxis.ValuePerPixel < FYAxis.ValuePerPixel then
    begin
      LDelta := FXAxis.Size * FYAxis.ValuePerPixel - (FXAxis.Max - FXAxis.Min);
      FXAxis.Max := FXAxis.Max + LDelta / 2;
      FXAxis.Min := FXAxis.Min - LDelta / 2;

      with FXAxis do
      begin
        PixelPerValue := Size / (Max - Min);
        ValuePerPixel := (Max - Min) / Size;
      end;
    end;
  end;

  Result := True;
end;

function TUdAxes.CalcAxis(AWidth, AHeight: Float; XPan: PFloat = nil; YPan: PFloat = nil): Boolean;
begin
  Result := Self.CalcAxis(AWidth, AHeight, nil, nil, XPan, YPan);
end;

function TUdAxes.CalcAxis(AWidth, AHeight: Float; XBound, YBound: TPoint2D; XPan: PFloat = nil; YPan: PFloat = nil): Boolean;
begin
  Result := Self.CalcAxis(AWidth, AHeight, @XBound, @YBound, XPan, YPan);
end;

function TUdAxes.CalcAxis(AWidth, AHeight: Float; ABounds: TRect2D; XPan: PFloat = nil; YPan: PFloat = nil): Boolean;
begin
  Result := Self.CalcAxis(AWidth, AHeight, Point2D(ABounds.X1, ABounds.X2), Point2D(ABounds.Y1, ABounds.Y2), XPan, YPan);
end;


procedure TUdAxes.ClearZoomLog();
var
  I: Integer;
begin
  for I := FParmsLogs.Count - 1 downto 0 do Dispose(PUdAxesParms(FParmsLogs[I]));
  FParmsLogs.Clear;

//  if Assigned(FParmsLog) then Dispose(FParmsLog);
//  FParmsLog := nil;
end;


//----------------------------------------------------------------

function TUdAxes.XPixel(const X: Float): Integer;
var
  V: Float;
begin
  with FXAxis do
  begin
    V := (X - Min) * PixelPerValue;
    Result := Trunc(Pan + V) + FMargin;
  end;
end;

function TUdAxes.YPixel(const Y: Float): Integer;
var
  V: Float;
begin
  with FYAxis do
  begin
    V := (Y - Min) * PixelPerValue;
    Result := Trunc(FHeight - Pan - V) - FMargin;
  end;
end;


function TUdAxes.XPixelF(const X: Float): Float;
var
  V: Float;
begin
  with FXAxis do
  begin
    V := (X - Min) * PixelPerValue;
    Result := Pan + V + FMargin;
  end;
end;

function TUdAxes.YPixelF(const Y: Float): Float;
var
  V: Float;
begin
  with FYAxis do
  begin
    V := (Y - Min) * PixelPerValue;
    Result := FHeight - FMargin - Pan - V;
  end;
end;



function TUdAxes.XValue(const X: Float): Float;
begin
  with FXAxis do
    Result := Min + (ValuePerPixel * (X - FMargin - Pan));
end;

function TUdAxes.YValue(const Y: Float): Float;
begin
  with FYAxis do
    Result := Min + (ValuePerPixel * (FHeight - FMargin - Y - Pan));
end;





function TUdAxes.PointPixel(const AValuePnt: TPoint2D): TPoint;
begin
  Result.X := Self.XPixel(AValuePnt.X);
  Result.Y := Self.YPixel(AValuePnt.Y);
end;

function TUdAxes.PointValue(const APixelPnt: TPoint): TPoint2D;
begin
  Result.X := Self.XValue(APixelPnt.X);
  Result.Y := Self.YValue(APixelPnt.Y);
end;




function TUdAxes.PointsPixel(const AValuePnts: TPoint2DArray): TPointArray;
var
  I: Integer;
begin
  System.SetLength(Result, System.Length(AValuePnts));

  for I := Low(AValuePnts) to High(AValuePnts) do
    Result[I] := Self.PointPixel(AValuePnts[I]);
end;


function TUdAxes.PointsValue(const APixelPnts: TPointArray): TPoint2DArray;
var
  I: Integer;
begin
  System.SetLength(Result, System.Length(APixelPnts));

  for I := Low(APixelPnts) to High(APixelPnts) do
    Result[I] := Self.PointValue(APixelPnts[I]);
end;





//----------------------------------------------------------------------------------

procedure TUdAxes.GenParmsLog();
begin
  if not Assigned(FParmsLog) then
  begin
    FParmsLog := New(PUdAxesParms);
    with PUdAxesParms(FParmsLog)^ do
    begin
      XPan := FXAxis.Pan;
      YPan := FYAxis.Pan;
      XMin := FXAxis.Min;
      YMin := FYAxis.Min;
      XMax := FXAxis.Max;
      YMax := FYAxis.Max;
    end;
  end;
end;

procedure TUdAxes.RaiseAxesChanging();
begin
  if Assigned(FOnAxesChanging) then FOnAxesChanging(Self);
end;

procedure TUdAxes.RaiseAxesChanged();
begin
  GenParmsLog();
  FChangedTimer.Enabled := False;
  FChangedTimer.Enabled := True;
end;

procedure TUdAxes.OnChangedTimer(Sender: TObject);
begin
  FParmsLogs.Add(FParmsLog);
  FParmsLog := nil;

  FChangedTimer.Enabled := False;
  if Assigned(FOnAxesChanged) then FOnAxesChanged(Self);
end;

procedure TUdAxes.Pan(DX, DY: Float; ARaiseChange: Boolean = True);
begin
  FXAxis.Pan := FXAxis.Pan + DX;
  FYAxis.Pan := FYAxis.Pan - DY;

  if ARaiseChange then
  begin
    RaiseAxesChanging();
    RaiseAxesChanged();
  end;
end;

procedure TUdAxes.SetPan(X, Y: Float);
begin
  FXAxis.Pan := X;
  FYAxis.Pan := Y;
  RaiseAxesChanging();
  RaiseAxesChanged();
end;

function TUdAxes.DyncScale(const AValue: Float; ABase: TPoint2D): Boolean;
const
  FACTOR_EPSILON = 0.01;
var
  LXDelta, LYDelta: Float;
  LXSize, LYSize, LFactor: Float;
  OXMin, OYMin, OXMax, OYMax: Float;
begin
  Result := False;

  if IsEqual(FScale, AValue) or
    (AValue < ZOOM_LEVLE_ARRAY[Low(ZOOM_LEVLE_ARRAY)]) or
    (AValue > ZOOM_LEVLE_ARRAY[High(ZOOM_LEVLE_ARRAY)]) then Exit;

  LFactor := FScale / AValue;

  LXSize := Self.XMax - Self.XMin;
  LYSize := Self.YMax - Self.YMin;

  LXDelta := LXSize * (LFactor - 1);
  LYDelta := LYSize * (LFactor - 1);

  OXMin := Self.XMin;
  OXMax := Self.XMax;
  OYMin := Self.YMin;
  OYMax := Self.YMax;

  FXAxis.Max := OXMax + LXDelta * (OXMax - ABase.X) / LXSize; //this line will not be exced at sometime incidental
  FXAxis.Min := OXMin - LXDelta * (ABase.X - OXMin) / LXSize;
  FYAxis.Max := OYMax + LYDelta * (OYMax - ABase.Y) / LYSize;
  FYAxis.Min := OYMin - LYDelta * (ABase.Y - OYMin) / LYSize;

  Self.CalcAxis(AXIS_ALL);


  if Abs(Self.XValuePerPixel - Self.YValuePerPixel) > FACTOR_EPSILON then
  begin
    FXAxis.Max := OXMax + LXDelta * (OXMax - ABase.X) / LXSize;
    FXAxis.Min := OXMin - LXDelta * (ABase.X - OXMin) / LXSize;
    FYAxis.Max := OYMax + LYDelta * (OYMax - ABase.Y) / LYSize;
    FYAxis.Min := OYMin - LYDelta * (ABase.Y - OYMin) / LYSize;

    Self.CalcAxis(AXIS_ALL);
  end;

  FScale := AValue;
  RaiseAxesChanging();
  RaiseAxesChanged();

  Result := True;
end;

procedure TUdAxes.ZoomScale(const AValue: Float);
var
  LPnt: TPoint2D;
begin
  if (FScale <> AValue) then
  begin
    LPnt.X := Self.XValue(FWidth / 2  + Self.XPan) ;
    LPnt.Y := Self.YValue(FHeight / 2 - Self.YPan) ;

    Self.DyncScale(AValue, LPnt);
  end;
end;




procedure TUdAxes.ZoomIn();
var
  I: Integer;
begin
  for I := Low(ZOOM_LEVLE_ARRAY) to High(ZOOM_LEVLE_ARRAY) do
    if ZOOM_LEVLE_ARRAY[I] > FScale then
    begin
      Self.ZoomScale(ZOOM_LEVLE_ARRAY[I]);
      Exit;
    end;
end;

procedure TUdAxes.ZoomOut();
var
  I: Integer;
begin
  for I := High(ZOOM_LEVLE_ARRAY) downto Low(ZOOM_LEVLE_ARRAY) do
    if ZOOM_LEVLE_ARRAY[I] < FScale then
    begin
      Self.ZoomScale(ZOOM_LEVLE_ARRAY[I]);
      Exit;
    end;
end;

procedure TUdAxes.ZoomPrevious({AWidth, AHeight: Integer});
var
  N: Integer;
  LParms: PUdAxesParms;
begin
  if FParmsLogs.Count > 0 then
  begin
    N := FParmsLogs.Count - 1;
    LParms := PUdAxesParms(FParmsLogs[N]);
    Self.CalcAxis(FWidth, FHeight,
                  Point2D(LParms^.XMin, LParms^.XMax),
                  Point2D(LParms^.YMin, LParms^.YMax),
                  @(LParms^.XPan), @(LParms^.YPan));

    Dispose(LParms);
    FParmsLogs.Delete(N);

    RaiseAxesChanging();
    RaiseAxesChanged();
  end;
end;



procedure TUdAxes.ZoomWindow(ARect: TRect2D; AExtends: Boolean);
var
  LRect: TRect2D;
//  P1, P2: TPoint2D;
//  LFactor: Float;
//  OX1, OY1, OX2, OY2: Float;
  LX1, LY1, LX2, LY2: Float;
begin
  GenParmsLog();

  if not IsValidRect(ARect) or //(Abs(ARect.P1.X - ARect.P2.X) < 1) or (Abs(ARect.P1.Y - ARect.P2.Y) < 1) or
     IsEqual(FWidth, 0) or IsEqual(FHeight, 0) then Exit;

  LX1 := Min(ARect.P1.X, ARect.P2.X);
  LY1 := Min(ARect.P1.Y, ARect.P2.Y);
  LX2 := Max(ARect.P1.X, ARect.P2.X);
  LY2 := Max(ARect.P1.Y, ARect.P2.Y);

  if AExtends then
  begin
    LRect := Rect2D(LX1, LY1, LX2, LY2);
  end
  else begin
    LRect := FLimRect;

    if LRect.X1 > LX1 then LRect.X1 := LX1;
    if LRect.X2 < LX2 then LRect.X2 := LX2;
    if LRect.Y1 > LY1 then LRect.Y1 := LY1;
    if LRect.Y2 < LY2 then LRect.Y2 := LY2;
  end;

  Self.CalcAxis(FWidth, FHeight, LRect);
  FScale := 100;

  Self.SetPan(0, 0);

//  if AExtends  then
//  begin
//   LRect := Rect2D(LX1, LY1, LX2, LY2);
//  end
//  else begin
//    LRect := Rect2D(0, 0, FWidth, FHeight);
//
//    if LRect.X1 > LX1 then LRect.X1 := LX1;
//    if LRect.X2 < LX2 then LRect.X2 := LX2;
//    if LRect.Y1 > LY1 then LRect.Y1 := LY1;
//    if LRect.Y2 < LY2 then LRect.Y2 := LY2;
//  end;
//
//  Self.CalcAxis(FWidth, FHeight, LRect);
//
//  FScale := 100;

//  if AExtends then
//    Self.SetPan(0, 0)
//  else begin
//    FXAxis.Pan := 0;
//    FYAxis.Pan := 0;
//
//    OX1 := Self.XValue(0);
//    OX2 := Self.XValue(FWidth);
//    OY1 := Self.YValue(FHeight);
//    OY2 := Self.YValue(0);
//
//    P1 := MidPoint(Point2D(OX1, OY1), Point2D(OX2, OY2));
//    P2 := MidPoint(ARect.P1, ARect.P2);
//
//    Self.Pan(
//      (P2.X - P1.X) * Self.XPixelPerValue,
//      (P2.Y - P1.Y) * Self.YPixelPerValue, False);
//
//    LFactor := Max( (LX2 - LX1)/(LRect.X2-LRect.X1), (LY2 - LY1)/(LRect.Y2-LRect.Y1) ) / 0.75;
//    if LFactor < 1 then ZoomScale(Round(FScale/LFactor)) else ZoomScale(Round(FScale*LFactor));
//
//  end;
end;

procedure TUdAxes.ZoomCenter(ACen: TPoint2D);
var
  LCurrCen: TPoint2D;
  OX1, OY1, OX2, OY2: Float;
begin
  OX1 := Self.XValue(0);
  OX2 := Self.XValue(FWidth);

  OY1 := Self.YValue(FHeight);
  OY2 := Self.YValue(0);

  LCurrCen := MidPoint(Point2D(OX1, OY1), Point2D(OX2, OY2));

  Self.Pan(
    (LCurrCen.X - ACen.X) * Self.XPixelPerValue,
    (LCurrCen.Y - ACen.Y) * Self.YPixelPerValue, True);
end;



function TUdAxes.SetAxis(ABounds: TRect2D; APan: TPoint2D; AScale: Float): Boolean;
begin
  Result := False;
  if (ABounds.X2 <= ABounds.X1) or (ABounds.Y2 <= ABounds.Y1) or (AScale <= 0) then Exit;

  FXAxis.Pan := APan.X;
  FXAxis.Min := ABounds.X1;
  FXAxis.Max := ABounds.X2;

  FYAxis.Pan := APan.Y;
  FYAxis.Min := ABounds.Y1;
  FYAxis.Max := ABounds.Y2;

  if (FScale <> AScale) then
    Self.ZoomScale( AScale )
  else
    Self.CalcAxis(AXIS_ALL);

  Self.RaiseAxesChanging();
  Self.RaiseAxesChanged();

  Result := True;
end;




//-------------------------------------------------------------------------------------

procedure TUdAxes.SaveToStream(AStream: TStream);
begin
  inherited;

  IntToStream(AStream,   FMargin);

  Point2DToStream(AStream, FLimRect.P1);
  Point2DToStream(AStream, FLimRect.P2);

  FloatToStream(AStream, FXAxis.Pan);
  FloatToStream(AStream, FXAxis.Min);
  FloatToStream(AStream, FXAxis.Max);

  FloatToStream(AStream, FYAxis.Pan);
  FloatToStream(AStream, FYAxis.Min);
  FloatToStream(AStream, FYAxis.Max);

  FloatToStream(AStream, FScale);
end;

procedure TUdAxes.LoadFromStream(AStream: TStream);
begin
  inherited;

  FMargin := IntFromStream(AStream);

  FLimRect.P1 := Point2DFromStream(AStream);
  FLimRect.P2 := Point2DFromStream(AStream);


  FXAxis.Pan := FloatFromStream(AStream);
  FXAxis.Min := FloatFromStream(AStream);
  FXAxis.Max := FloatFromStream(AStream);

  FYAxis.Pan := FloatFromStream(AStream);
  FYAxis.Min := FloatFromStream(AStream);
  FYAxis.Max := FloatFromStream(AStream);

  FScale := FloatFromStream(AStream);

//  if Assigned(FOwner) and FOwner.InheritsFrom(TUdLayout) and Assigned(TUdLayout(FOwner).DrawPanel) then
//    Self.CalcAxis(TUdLayout(FOwner).DrawPanel.Width, TUdLayout(FOwner).DrawPanel.Height);
end;




procedure TUdAxes.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Margin']  := IntToStr(FMargin);

  LXmlNode.Prop['LimitP1'] := Point2DToStr(FLimRect.P1);
  LXmlNode.Prop['LimitP2'] := Point2DToStr(FLimRect.P2);

  LXmlNode.Prop['XPan']    := FloatToStr(FXAxis.Pan);
  LXmlNode.Prop['XMin']    := FloatToStr(FXAxis.Min);
  LXmlNode.Prop['XMax']    := FloatToStr(FXAxis.Max);

  LXmlNode.Prop['YPan']    := FloatToStr(FYAxis.Pan);
  LXmlNode.Prop['YMin']    := FloatToStr(FYAxis.Min);
  LXmlNode.Prop['YMax']    := FloatToStr(FYAxis.Max);

  LXmlNode.Prop['Scale']   := FloatToStr(FScale);
end;

procedure TUdAxes.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FMargin     := StrToInt(LXmlNode.Prop['Margin']);

  FLimRect.P1 := StrToPoint2D(LXmlNode.Prop['LimitP1']);
  FLimRect.P2 := StrToPoint2D(LXmlNode.Prop['LimitP2']);


  FXAxis.Pan  := StrToFloatDef(LXmlNode.Prop['XPan'], 0);
  FXAxis.Min  := StrToFloatDef(LXmlNode.Prop['XMin'], 0);
  FXAxis.Max  := StrToFloatDef(LXmlNode.Prop['XMax'], 1);

  FYAxis.Pan  := StrToFloatDef(LXmlNode.Prop['YPan'], 0);
  FYAxis.Min  := StrToFloatDef(LXmlNode.Prop['YMin'], 0);
  FYAxis.Max  := StrToFloatDef(LXmlNode.Prop['YMax'], 1);

  FScale      := StrToFloatDef(LXmlNode.Prop['Scale'], 100);
end;

end.