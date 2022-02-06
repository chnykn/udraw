
{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdDrawUtil;

interface

{$I UdDefs.INC}

uses
  Windows, Graphics, Types,
  UdConsts, UdTypes, UdAxes;



const
  MAX_ARC_PTS_COUNT = 13;

  MAX_HUE: Integer = 180;
  MAX_SAT: Integer = 180;
  MAX_LUM: Integer = 180;


type
  TGDIArcPoints = array[0..MAX_ARC_PTS_COUNT - 1] of TPoint2D;
  TGDIBezierPoints = array[0..3] of TPoint2D;



//-----------------------------------------------------------------------------------------------

function NotColor(AColor: TColor): TColor;
function ColorLight(AColor: TColor): Byte;

function HSLToRGB(H, S, L : Integer): TColor;
procedure RGBtoHSL(RGB: TColor; var H, S, L: Integer);


function ExtCreateStylePen(APen: TPen; AColor: TColor; ABrushStyle: TBrushStyle;
  APenStyle: TPenStyle; APenWidth: Integer; ASquareEnd: Boolean = True): Boolean;
function ExtCreateUserStylePen(APen: TPen; AColor: TColor; AUserStyle: TSingleArray;
  APenWidth: Integer; ASquareEnd: Boolean = True): Boolean;

function ExtCreateHatchPen(APen: TPen; AHatchBmp: TBitmap; APenStyle: TPenStyle;
  APenWidth: Integer; ASquareEnd: Boolean = True): Boolean;


//-----------------------------------------------------------------------------------------------

function DrawPoints(ACanvas: TCanvas; AAxes: TUdAxes; const APoints: TPoint2DArray; ASelMode: Boolean = False): Boolean;// {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}
function DrawPolygon(ACanvas: TCanvas; AAxes: TUdAxes; const APoints: TPoint2DArray): Boolean;// {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}
function DrawLtData(ACanvas: TCanvas; AAxes: TUdAxes; ALtData: PLtData): Boolean; {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}

function DrawGripPoint(ACanvas: TCanvas; AAxes: TUdAxes; AGripPoint: TUdGripPoint; AColor: TColor = clBlue): Boolean;  {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}
function DrawGripPoints(ACanvas: TCanvas; AAxes: TUdAxes; AGripPoints: TUdGripPointArray; AColor: TColor = clBlue): Boolean; {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}


//-----------------------------------------------------------------------------------------------

procedure DrawRect(ACanvas: TCanvas; X, Y: Integer; R: Integer; AFill: Boolean = False);
procedure DrawCircle(ACanvas: TCanvas; X, Y: Integer; R: Integer; AFill: Boolean = False);
procedure DrawQuare(ACanvas: TCanvas; X, Y: Integer; R: Integer);
procedure DrawCross(ACanvas: TCanvas; X, Y: Integer; R: Integer);
procedure DrawXCross(ACanvas: TCanvas; X, Y: Integer; R: Integer);
procedure DrawTrigon(ACanvas: TCanvas; X, Y: Integer; R: Integer);

procedure DrawOSnap(ACanvas: TCanvas; X, Y: Integer; AMode: Integer; ASnapColor: TColor = clYellow);


function DrawLineType(ACanvas: TCanvas; ARect: TRect; const AValue: TSingleArray): Boolean;
function DrawLineWeight(ACanvas: TCanvas; ARect: TRect; APenWidth: Integer): Boolean;



implementation

uses
  UdMath, UdGeo2D {$IFNDEF D2010}, UdCanvas{$ENDIF};//, UdEntity;


const
  PEN_STYLES: array[TPenStyle] of Word =
  (PS_SOLID, PS_DASH, PS_DOT, PS_DASHDOT, PS_DASHDOTDOT, PS_NULL,
    PS_INSIDEFRAME {$IF COMPILERVERSION > 17 }, PS_USERSTYLE, PS_ALTERNATE {$IFEND});


//=================================================================================================


procedure RGBtoHSL(RGB: TColor; var H, S, L: Integer);
var
  LMax, LMin: Double;
  H2, S2, L2: Double;
  R, G, B, D: Double;
begin
//  H2 := H;
//  S2 := S;
//  L2 := L;

  R := GetRValue(RGB) / 255;
  G := GetGValue(RGB) / 255;
  B := GetBValue(RGB) / 255;

  LMax := Max(R, Max (G, B));
  LMin := Min(R, Min (G, B));
  L2 := (LMax + LMin) / 2;

  if IsEqual(LMax, LMin) then
  begin
    H2 := 0;
    S2 := 0;
  end
  else begin
    D := LMax - LMin;
    //calc L2
    if L2 < 0.5 then
      S2 := D / (LMax + LMin)
    else
      S2 := D / (2 - LMax - LMin);

    //calc H2
    if R = LMax then
      H2 := (G - B) / D
    else if G = LMax then
      H2  := 2 + (B - R) /D
    else
      H2 := 4 + (R - G) / D;

    H2 := H2 / 6;
    if H2 < 0 then H2 := H2 + 1;
  end;

  H := Round(H2 * MAX_HUE);
  S := Round(S2 * MAX_SAT);
  L := Round(L2 * MAX_LUM);
end;




function _HSLtoRGB(H, S, L: Double): TColor;
var
  M1, M2: Double;

  function _HueToColorValue(Hue: Double): Byte;
  var
    V: Double;
  begin
    if Hue < 0 then
      Hue := Hue + 1
    else if Hue > 1 then
      Hue := Hue - 1;

    if 6 * Hue < 1 then
      V := M1 + (M2 - M1) * Hue * 6
    else if 2 * Hue < 1 then
      V := M2
    else if 3 * Hue < 2 then
      V := M1 + (M2 - M1) * (2/3 - Hue) * 6
    else
      V := M1;
      
    Result := Round(255 * V)
  end;

var
  N: Integer;
  R, G, B: byte;
begin
  if IsEqual(S, 0) then
  begin
    //R := Round (MAX_LUM * L);
    
    N := Round(255 * L);
    if N > 255 then N := 255;
    R := N;
    
    G := R;
    B := R
  end
  else begin
    if L <= 0.5 then
      M2 := L * (1 + S)
    else
      M2 := L + S - L * S;

    M1 := 2 * L - M2;
    R  := _HueToColorValue(H + 1/3);
    G  := _HueToColorValue(H);
    B  := _HueToColorValue(H - 1/3)
  end;

  Result := RGB(R, G, B)
end;

function HSLToRGB(H, S, L : Integer): TColor;
begin
  if S > MAX_SAT then S := MAX_SAT;
  if S < 0 then S := 0;

  if L > MAX_LUM then L := MAX_LUM;
  if L < 0 then L := 0;

  Result := _HSLToRGB(H / MAX_HUE, S / MAX_SAT, L / MAX_LUM);
end;





//---------------------------------------------------------------------------


function NotColor(AColor: TColor): TColor;
begin
  if (AColor = clAppWorkSpace) or (AColor = clNone) then
  begin
    Result := clBlack;
    Exit; //===>>>
  end;

  AColor := ColorToRGB(AColor);
  Result := RGB(MAXBYTE-GetRValue(AColor), MAXBYTE-GetGValue(AColor), MAXBYTE-GetBValue(AColor));
end;

function ColorLight(AColor: TColor): Byte;
var
  LValue: Double;
begin
  AColor := ColorToRGB(AColor);
  LValue := GetRValue(AColor) * 0.299 +
    GetGValue(AColor) * 0.587 +
    GetBValue(AColor) * 0.114;
  Result := Trunc(LValue);
end;



function ExtCreateStylePen(APen: TPen; AColor: TColor; ABrushStyle: TBrushStyle;
  APenStyle: TPenStyle; APenWidth: Integer; ASquareEnd: Boolean = True): Boolean;
var
  LPenStyle: Cardinal;
  LLogBrush: TLogBrush;
begin
  Result := False;
  if not Assigned(APen) then Exit;


  with LLogBrush do
  begin
    lbHatch := 0;
    case ABrushStyle of
      bsSolid: lbStyle := BS_SOLID;
      bsClear: lbStyle := BS_HOLLOW;
    else
      lbStyle := BS_HATCHED;
      lbHatch := Ord(ABrushStyle) - Ord(bsHorizontal);
    end;

    lbColor := ColorToRGB(AColor);
  end;

  LPenStyle := PS_GEOMETRIC or PEN_STYLES[APenStyle];
  if ASquareEnd then LPenStyle := LPenStyle or PS_ENDCAP_SQUARE;

  APen.Handle := ExtCreatePen(LPenStyle, APenWidth, LLogBrush, 0, nil);

  Result := True;
end;

function ExtCreateUserStylePen(APen: TPen; AColor: TColor; AUserStyle: TSingleArray;
  APenWidth: Integer; ASquareEnd: Boolean = True): Boolean;
var
  I: Integer;
  LLogBrush: TLogBrush;
  LPenStyle: Cardinal;
  LUserPen: array of Integer;
begin
  Result := False;
  if not Assigned(APen) then Exit;

  System.SetLength(LUserPen, System.Length(AUserStyle));
  for I := 0 to System.Length(AUserStyle) - 1 do
    LUserPen[I] := Trunc(AUserStyle[I]);

  LLogBrush.lbStyle := BS_SOLID;
  LLogBrush.lbColor := AColor;
  LLogBrush.lbHatch := 0;

  LPenStyle := PS_GEOMETRIC or PS_USERSTYLE or PS_SOLID;
  if ASquareEnd then LPenStyle := LPenStyle or PS_ENDCAP_SQUARE;

  APen.Handle := ExtCreatePen(LPenStyle, APenWidth, LLogBrush, System.Length(LUserPen), LUserPen);
  Result := True;
end;

function ExtCreateHatchPen(APen: TPen; AHatchBmp: TBitmap; APenStyle: TPenStyle; APenWidth: Integer;
  ASquareEnd: Boolean = True): Boolean;
var
  LPenStyle: Cardinal;
  LLogBrush: TLogBrush;
begin
  Result := False;
  if not Assigned(APen) or not Assigned(AHatchBmp) then Exit;

  LLogBrush.lbStyle := BS_PATTERN;
  LLogBrush.lbColor := DIB_RGB_COLORS;
  LLogBrush.lbHatch := AHatchBmp.Handle;

  LPenStyle := PS_GEOMETRIC or PEN_STYLES[APenStyle];
  if ASquareEnd then LPenStyle := LPenStyle or PS_ENDCAP_SQUARE;

  APen.Handle := ExtCreatePen(LPenStyle, APenWidth, LLogBrush, 0, nil);
  Result := True;
end;



//--------------------------------------------------------------------------------------


function DrawPoints(ACanvas: TCanvas; AAxes: TUdAxes; const APoints: TPoint2DArray; ASelMode: Boolean = False): Boolean;
var
  I, L: Integer;
  LX, LY: Integer;
  {$IFNDEF D2010}LExFunc: Boolean; {$ENDIF}
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //======>>>>

  {$IFNDEF D2010}LExFunc := ACanvas.InheritsFrom(TUdCanvas); {$ENDIF}
  
  
  L := System.Length(APoints);
  if L > 1 then
  begin
    LX := AAxes.XPixel(APoints[0].X);
    LY := AAxes.YPixel(APoints[0].Y);

  {$IFDEF D2010}
    ACanvas.MoveTo(LX, LY);
  {$ELSE}
    if LExFunc then TUdCanvas(ACanvas).MoveToEx(LX, LY) else ACanvas.MoveTo(LX, LY);
  {$ENDIF}


    for I := 1 to L - 1 do
    begin
      LX := AAxes.XPixel(APoints[I].X);
      LY := AAxes.YPixel(APoints[I].Y);

    {$IFDEF D2010}
      ACanvas.LineTo(LX, LY);
    {$ELSE}
      if LExFunc then TUdCanvas(ACanvas).LineToEx(LX, LY) else ACanvas.LineTo(LX, LY);
    {$ENDIF}
    end;
  end;

  Result := True;
end;


function DrawPolygon(ACanvas: TCanvas; AAxes: TUdAxes; const APoints: TPoint2DArray): Boolean;
var
  I, L: Integer;
  LX, LY: Integer;
  LPoints: array of TPoint;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //======>>>>

  L := System.Length(APoints);

  System.SetLength(LPoints, L);
  for I := 0 to L - 1 do
  begin
    LX := AAxes.XPixel(APoints[I].X);
    LY := AAxes.YPixel(APoints[I].Y);

    LPoints[I].X := LX;
    LPoints[I].Y := LY;
  end;

  if L > 2 then ACanvas.Polygon(LPoints);

  Result := True;
end;


function DrawLtData(ACanvas: TCanvas; AAxes: TUdAxes; ALtData: PLtData): Boolean;
var
  V: Float;
  LLtData: PLtData;
  LP1, LP2: TPoint;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) or not Assigned(ALtData) then Exit; //======>>>>

//  ACanvas.Pen.Style := psSolid;

  LLtData := ALtData;
  repeat
    with AAxes.XAxis do
    begin
      V := (LLtData.Data^.P1.X - Min) * PixelPerValue;
      LP1.X := Trunc(Pan + V) + AAxes.Margin;
    end;

    with AAxes.YAxis do
    begin
      V := (LLtData.Data^.P1.Y - Min) * PixelPerValue;
      LP1.Y := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
    end;

    with AAxes.XAxis do
    begin
      V := (LLtData.Data^.P2.X - Min) * PixelPerValue;
      LP2.X := Trunc(Pan + V) + AAxes.Margin;
    end;

    with AAxes.YAxis do
    begin
      V := (LLtData.Data^.P2.Y - Min) * PixelPerValue;
      LP2.Y := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
    end;

    if (LP1.X = LP2.X) and (LP1.Y = LP2.Y) then
    begin
      ACanvas.Pixels[LP1.X, LP1.Y] := ACanvas.Pen.Color;
    end
    else begin
      ACanvas.MoveTo(LP1.X, LP1.Y);
      ACanvas.LineTo(LP2.X, LP2.Y);
    end;

    LLtData := LLtData.Next;
  until LLtData = nil;

  Result := True;
end;


function DrawGripPoint(ACanvas: TCanvas; AAxes: TUdAxes; AGripPoint: TUdGripPoint; AColor: TColor = clBlue): Boolean;
var
  V: Float;
  R: Integer;
  LX, LY: Integer;
  LR, LAng: Float;
  LBase, LPnt: TPoint2D;
  LPnts: array of TPoint;  
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //======>>>>

  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := clGray;
  ACanvas.Pen.Style := psSolid;

  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := AColor;

  R := DEFAULT_PICK_SIZE;
  LR := AAxes.XValuePerPixel * R;

  System.SetLength(LPnts, 4);

  with AAxes.XAxis do
  begin
    V := (AGripPoint.Point.X - Min) * PixelPerValue;
    LX := Trunc(Pan + V) + AAxes.Margin;
  end;

  with AAxes.YAxis do
  begin
    V := (AGripPoint.Point.Y - Min) * PixelPerValue;
    LY := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
  end;

  case AGripPoint.Mode of
    gmAngle, gmRadius:
      begin
        LAng := AGripPoint.Angle;
        if AGripPoint.Mode = gmAngle then
        begin
          if AGripPoint.Index = 1 then
            LAng := FixAngle(LAng - 90)
          else
            LAng := FixAngle(LAng + 90);
        end;

        LBase := ShiftPoint(AGripPoint.Point, FixAngle(LAng+180), LR);

        LPnt := ShiftPoint(LBase, FixAngle(LAng+90), LR);
        LPnts[0] := AAxes.PointPixel(LPnt);

        LPnt := ShiftPoint(LBase, FixAngle(LAng-90), LR);
        LPnts[1] := AAxes.PointPixel(LPnt);

        LPnt := ShiftPoint(LBase, LAng, LR*3);
        LPnts[2] := AAxes.PointPixel(LPnt);

        LPnts[3] := LPnts[0];
      end
    else begin
      LPnts[0] := Point(LX - R, LY - R);
      LPnts[1] := Point(LX + R, LY - R);
      LPnts[2] := Point(LX + R, LY + R);
      LPnts[3] := Point(LX - R, LY + R);
    end;
  end;

  ACanvas.Polygon(LPnts);

  Result := True;
end;

function DrawGripPoints(ACanvas: TCanvas; AAxes: TUdAxes; AGripPoints: TUdGripPointArray; AColor: TColor = clBlue): Boolean;
var
  I: Integer;
  V: Float;
  R: Integer;
  LX, LY: Integer;
  LR, LAng: Float;
  LBase, LPnt: TPoint2D;
  LPnts: array of TPoint;  
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //======>>>>

  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := clGray;
  ACanvas.Pen.Style := psSolid;

  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := AColor;

  R := DEFAULT_PICK_SIZE;
  LR := AAxes.XValuePerPixel * R;

  System.SetLength(LPnts, 4);

  for I := 0 to System.Length(AGripPoints) - 1 do
  begin
    with AAxes.XAxis do
    begin
      V := (AGripPoints[I].Point.X - Min) * PixelPerValue;
      LX := Trunc(Pan + V) + AAxes.Margin;
    end;

    with AAxes.YAxis do
    begin
      V := (AGripPoints[I].Point.Y - Min) * PixelPerValue;
      LY := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
    end;

    case AGripPoints[I].Mode of
      gmAngle, gmRadius:
        begin
          LAng := AGripPoints[I].Angle;
          if AGripPoints[I].Mode = gmAngle then
          begin
            if AGripPoints[I].Index = 1 then
              LAng := FixAngle(LAng - 90)
            else
              LAng := FixAngle(LAng + 90);
          end;

          LBase := ShiftPoint(AGripPoints[I].Point, FixAngle(LAng+180), LR);

          LPnt := ShiftPoint(LBase, FixAngle(LAng+90), LR);
          LPnts[0] := AAxes.PointPixel(LPnt);

          LPnt := ShiftPoint(LBase, FixAngle(LAng-90), LR);
          LPnts[1] := AAxes.PointPixel(LPnt);

          LPnt := ShiftPoint(LBase, LAng, LR*3);
          LPnts[2] := AAxes.PointPixel(LPnt);

          LPnts[3] := LPnts[0];
        end
      else begin
        LPnts[0] := Point(LX - R, LY - R);
        LPnts[1] := Point(LX + R, LY - R);
        LPnts[2] := Point(LX + R, LY + R);
        LPnts[3] := Point(LX - R, LY + R);
      end;
    end;

    ACanvas.Polygon(LPnts);
  end;

  Result := True;
end;







//--------------------------------------------------------------------------------------

procedure DrawRect(ACanvas: TCanvas; X, Y: Integer; R: Integer; AFill: Boolean = False);
begin
  if AFill then
    ACanvas.Brush.Style := bsSolid
  else
    ACanvas.Brush.Style := bsClear;

  ACanvas.Rectangle(X - R, Y - R, X + R, Y + R);
end;

procedure DrawCircle(ACanvas: TCanvas; X, Y: Integer; R: Integer; AFill: Boolean = False);
begin
  if AFill then
    ACanvas.Brush.Style := bsSolid
  else
    ACanvas.Brush.Style := bsClear;

  ACanvas.Ellipse(X - R, Y - R, X + R, Y + R);
end;

procedure DrawQuare(ACanvas: TCanvas; X, Y: Integer; R: Integer);
var
  LPnts: array of TPoint;
begin
  System.SetLength(LPnts, 5);
  LPnts[0] := Point(X, Y + R);
  LPnts[1] := Point(X + R, Y);
  LPnts[2] := Point(X, Y - R);
  LPnts[3] := Point(X - R, Y);
  LPnts[4] := Point(X, Y + R);
  ACanvas.Polyline(LPnts);
end;

procedure DrawCross(ACanvas: TCanvas; X, Y: Integer; R: Integer);
var
  N: Integer;
begin
  if Odd(ACanvas.Pen.Width) then
    N := 1
  else
    N := 0;

  ACanvas.MoveTo(X - R, Y);
  ACanvas.LineTo(X + R + N, Y);

  ACanvas.MoveTo(X, Y - R);
  ACanvas.LineTo(X, Y + R + N);
end;

procedure DrawXCross(ACanvas: TCanvas; X, Y: Integer; R: Integer);
var
  N: Integer;
begin
  if Odd(ACanvas.Pen.Width) then
    N := 1
  else
    N := 0;

  ACanvas.MoveTo(X - R, Y - R);
  ACanvas.LineTo(X + R + N, Y + R + N);

  ACanvas.MoveTo(X - R, Y + R);
  ACanvas.LineTo(X + R + N, Y - R - N);
end;

procedure DrawTrigon(ACanvas: TCanvas; X, Y: Integer; R: Integer);
var
  Dx, Dy: Integer;
begin
  Dy := Round(R / 2);
  Dx := Round((R / 2) * Sqrt(3));

  ACanvas.MoveTo(X + Dx, Y + Dy);
  ACanvas.LineTo(X - Dx, Y + Dy);
  ACanvas.LineTo(X, Y - R);
  ACanvas.LineTo(X + Dx, Y + Dy);
end;




procedure DrawOSnap(ACanvas: TCanvas; X, Y: Integer; AMode: Integer; ASnapColor: TColor = clYellow);

  procedure _DrawCross();
  begin
    ACanvas.Pen.Width := 2;
    DrawXCross(ACanvas, X, Y, 6);
  end;

  procedure _DrawRect();
  begin
    ACanvas.Pen.Width := 2;
    DrawRect(ACanvas, X, Y, 6, False);
  end;

  procedure _DrawQuare();
  begin
    ACanvas.Pen.Width := 2;
    DrawQuare(ACanvas, X, Y, 7);
  end;

  procedure _DrawCircle();
  begin
    ACanvas.Pen.Width := 1;
    DrawCircle(ACanvas, X, Y, 7, False);
  end;

  procedure _DrawNode();
  begin
    ACanvas.Pen.Width := 1;
    DrawCircle(ACanvas, X, Y, 7, False);
    DrawXCross(ACanvas, X, Y, 6);
  end;

  procedure _DrawTrigon();
  begin
    ACanvas.Pen.Width := 2;
    DrawTrigon(ACanvas, X, Y, 8);
  end;

  procedure _DrawPerpend();
  const
    PERP_SIZE = 6;
  var
    LX, LY: Integer;
  begin
    ACanvas.Pen.Width := 2;

    LX := X - PERP_SIZE;
    LY := Y + PERP_SIZE;

    ACanvas.MoveTo(LX, LY);
    ACanvas.LineTo(LX, LY - PERP_SIZE * 2);

    ACanvas.MoveTo(LX, LY);
    ACanvas.LineTo(LX + PERP_SIZE * 2, LY);

    ACanvas.MoveTo(X, Y);
    ACanvas.LineTo(X - PERP_SIZE, Y);

    ACanvas.MoveTo(X, Y);
    ACanvas.LineTo(X, Y + PERP_SIZE);
  end;

  procedure _DrawTang();
  const
    PERP_SIZE = 7;
  begin
    ACanvas.Pen.Width := 2;

    ACanvas.MoveTo(X - PERP_SIZE, Y - 3);
    ACanvas.LineTo(X + PERP_SIZE, Y - 3);

    ACanvas.Pen.Width := 1;
    ACanvas.Ellipse(X - 5, Y - 2, X + 6, Y + 9)
  end;

  procedure _DrawInsert();
  var
    LX, LY: Integer;
    LPnts: array of TPoint;
  begin
    LX := X - 7;
    LY := Y - 6;

    System.SetLength(LPnts, 9);
    LPnts[0] := Point(LX + 0, LY + 1);
    LPnts[1] := Point(LX + 7, LY + 1);
    LPnts[2] := Point(LX + 7, LY + 5);
    LPnts[3] := Point(LX + 12, LY + 5);
    LPnts[4] := Point(LX + 12, LY + 12);
    LPnts[5] := Point(LX + 6, LY + 12);
    LPnts[6] := Point(LX + 6, LY + 8);
    LPnts[7] := Point(LX + 1, LY + 8);
    LPnts[8] := Point(LX + 1, LY + 0);

    ACanvas.Pen.Width := 2;
    ACanvas.Polyline(LPnts);
  end;

  procedure _DrawNear();
  begin
    ACanvas.Pen.Width := 1;

    ACanvas.MoveTo(X - 5, Y - 6);
    ACanvas.LineTo(X + 5, Y + 6);

    ACanvas.MoveTo(X + 5, Y - 6);
    ACanvas.LineTo(X - 5, Y + 6);


    ACanvas.Pen.Width := 2;
    ACanvas.MoveTo(X - 5, Y - 6);
    ACanvas.LineTo(X + 5, Y - 6);

    ACanvas.MoveTo(X - 5, Y + 6);
    ACanvas.LineTo(X + 5, Y + 6);
  end;

begin
  if not Assigned(ACanvas) or (AMode = OSNP_NUL) then Exit;

  ACanvas.Pen.Color := ASnapColor;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Mode := pmCopy;

  ACanvas.Brush.Style := bsClear;

  case AMode of
    OSNP_END: _DrawRect();
    OSNP_MID: _DrawTrigon();
    OSNP_CEN: _DrawCircle();
    OSNP_INS: _DrawInsert();
    OSNP_QUA: _DrawQuare();
    OSNP_NOD: _DrawNode();

    OSNP_PER: _DrawPerpend();
    OSNP_NEA: _DrawNear();
    OSNP_INT: _DrawCross();
    OSNP_TAN: _DrawTang();
  end;
end;






function DrawLineType(ACanvas: TCanvas; ARect: TRect; const AValue: TSingleArray): Boolean;
var
  I, N, L: Integer;
  X1, X2, Y, Dis: Integer;
  LMin, LMax: Single;
  LFactor: Double;
  LValue: TSingleArray;
begin
  Result := False;
  if not Assigned(ACanvas) then Exit;


  Y := (ARect.Top + ARect.Bottom) div 2;

  ACanvas.Pen.Color := clBlack;
  ACanvas.Pen.Style := psSolid;

  L := Length(AValue);

  if L < 2 then
  begin
    ACanvas.MoveTo(ARect.Left, Y);
    ACanvas.LineTo(ARect.Right, Y);
  end
  else begin
    LMin := MaxInt;

    SetLength(LValue, Length(AValue));
    for I := 0 to Length(AValue) - 1 do
    begin
      LValue[I] := AValue[I];
      if NotEqual(AValue[I], 0.0) then
        if (Abs(AValue[I]) < LMin) then LMin := Abs(AValue[I]);
    end;

    LFactor := (1.0 / LMin);
    for I := 0 to Length(LValue) - 1 do
      LValue[I] := LValue[I] * LFactor;

    LMax := 0.0;
    for I := 0 to Length(LValue) - 1 do
      if (Abs(LValue[I]) > LMax) then LMax := Abs(LValue[I]);

    LFactor := 20 / LMax;
    for I := 0 to Length(LValue) - 1 do
      LValue[I] := LValue[I] * LFactor;

    N := 0;
    X1 := ARect.Left;
    Dis := ARect.Right - ARect.Left - Abs(Round(LValue[0]));

    while Dis > 0 do
    begin
      X2 := X1 + Abs(Round(LValue[N]));

      if LValue[N] >= 0 then
      begin
        ACanvas.MoveTo(X1, Y);
        if X2 = X1 then
          ACanvas.Pixels[X1, Y] := clBlack
        else
          ACanvas.LineTo(X2, Y);
      end;

      X1 := X2;

      N := N + 1;
      if N >= L then N := 0;

      Dis := Dis - Abs(Round(LValue[N]));
    end;

    if LValue[N] > 0 then
    begin
      ACanvas.MoveTo(X1, Y);
      ACanvas.LineTo(ARect.Right, Y);
    end;
  end;

  Result := True;
end;


function DrawLineWeight(ACanvas: TCanvas; ARect: TRect; APenWidth: Integer): Boolean;

  function _CreatePen(AWidth: Integer; AColor: TColor): HPen;
  var
    ALogBrush: TLogBrush;
  begin
    ALogBrush.lbColor := AColor;
    ALogBrush.lbStyle := BS_SOLID;
    ALogBrush.lbHatch := BS_SOLID;
    Result := ExtCreatePen(PS_GEOMETRIC or PS_ENDCAP_SQUARE or PS_SOLID, AWidth, ALogBrush, 0, nil); // or PS_JOIN_BEVEL
  end;

var
  Y: Integer;
begin
  Result := False;
  if not Assigned(ACanvas) then Exit;

  Y := (ARect.Top + ARect.Bottom) div 2;

  ACanvas.Pen.Handle := _CreatePen(APenWidth, clBlack);

  ACanvas.MoveTo(ARect.Left, Y);   // + AWidth div 2
  ACanvas.LineTo(ARect.Right, Y);  // - AWidth div 2

  Result := True;
end;



end.