{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdTTF;

interface

uses
  Windows, Classes, Graphics, Forms,
  Types, UdTypes;

type

  PUdTTFStroke = ^TUdTTFStroke;
  TUdTTFStroke = record
    GlyphNumber: Integer;
    Pt1, Pt2: TPoint;
   { Note: Strokes[i].Pt2=Strokes[i+1].Pt1
      also Strokes[i].Pt1=Strokes[i-1].Pt2)
      when Strokes[i].GlyphNumber = Strokes[i+1].GlyphNumber }
  end;

  TUdTTFEnumStrokesEvent = function(Idx: Integer; const Stroke: TUdTTFStroke): Boolean of object;


  //*** TUdTTFStrokes ***//
  TUdTTFStrokes = class(TList)
  private
    FWidth : Integer;
    FHeight: Integer;

    FBoxWidth : Integer;
    FBoxHeight: Integer;
    FBoxOrigin: TPoint;

  protected
    function GetNumGlyphs(): Integer;

    function GetStroke(Idx: Integer): TUdTTFStroke;
    procedure ClearStrokes();

  public
    constructor Create;
    destructor Destroy; override;

    { Returns the smallest rectangle that completely bounds all glyphs }
    function GetBounds(): TRect;

    { Returns the index of the first stroke for the glyph number GlyphNumber }
    function StartOfGlyph(AGlyphNumber: Integer): Integer;

    { Returns the count of strokes for the glyph number GlyphNumber. }
    function GlyphNumStrokes(AGlyphNumber: Integer): Integer;

    { Enumerates all strokes of all glyphs }
    procedure EnumStrokes(ACallback: TUdTTFEnumStrokesEvent);

  public
    { Returns the number of glyphs }
    property NumGlyphs: Integer read GetNumGlyphs;

    { Returns the stroke number Idx. Use StrartOfGlyph to determine  the index of the first stroke
      for a given glyph. Use GlyphNumStrokes to determine the number of strokes a glyph is. }
    property Stroke[Idx: Integer]: TUdTTFStroke read GetStroke;
  end;


  TUdTTFPolygon = record
    Polys: TPoint2DArray;
    Counts: TIntegerDynArray;
  end;
  PUdTTFPolygon = ^TUdTTFPolygon;

  TUdTTFPolygonArray = array of TUdTTFPolygon;
  PUdTTFPolygonArray = ^TUdTTFPolygonArray;



  //*** TUdTTF ***//
  TUdTTF = class(TObject)
  private
    FFont: TFont;
    FSplinePrecision: Integer;

    FUnicode: Boolean;

  protected
    procedure SetFont(Value: TFont); virtual;
    procedure SetSplinePrecision(Value: Integer);

    function GetCharPolys(ACharCode: Integer; var AOfsX, AOfsY: Float; AHeight: Double; AWidthFactor: Double = 1.0): TUdTTFPolygon; overload;
    function GetCharPolys(AChar: WideChar; var AOfsX, AOfsY: Float; AHeight: Double; AWidthFactor: Double = 1.0): TUdTTFPolygon; overload;

  public
    constructor Create();
    destructor Destroy; override;

    function CreateCharGlyphs(ACharCode: Integer): TUdTTFStrokes;
    function GetCharRegion(ACharCode: Integer; ASizeX, ASizeY: Integer; AOfsX, AOfsY: Integer): HRGN;

    function GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec): TUdTTFPolygonArray; overload;
    function GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec; var ATextBound: TPoint2DArray): TUdTTFPolygonArray;  overload;
    function GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec; var ATextWidth, ATextHeight: Float; var ATextBound: TPoint2DArray): TUdTTFPolygonArray;  overload;

  public
    property Font: TFont read FFont write SetFont;
    property Precision: Integer read FSplinePrecision write SetSplinePrecision;
  end;


  

implementation


uses
  SysUtils,
  UdShx, UdUtils, UdGTypes, UdMath, UdGeo2D;



  
//=================================================================================================
var
//  GDefFontDir: string;
  GGdtTTF    : TUdTTF; // AIGDT
  GIsoCpTTF  : TUdTTF; // ISOCPEUR




//procedure SetDefFontDir(const AValue: string);
//begin
//  GDefFontDir := AValue;
//end;

function GetDefGdtTTF(): TUdTTF;
begin
  if not Assigned(GGdtTTF) then
  begin
    GGdtTTF := TUdTTF.Create;
    GGdtTTF.Font.Name := 'AIGDT';
  end;

  Result := GGdtTTF;
end;

function GetDefIsoCpeurTTF(): TUdTTF;
begin
  if not Assigned(GIsoCpTTF) then
  begin
    GIsoCpTTF := TUdTTF.Create;
    GIsoCpTTF.Font.Name := 'ISOCPEUR'; //
  end;

  Result := GIsoCpTTF;
end;





//=================================================================================================
{ TUdTTFStrokes }

constructor TUdTTFStrokes.Create;
begin
  inherited Create;
  
  FWidth  := 0;
  FHeight := 0;

  FBoxWidth  := 0;
  FBoxHeight := 0;
  FBoxOrigin := Point(0, 0);
end;

destructor TUdTTFStrokes.Destroy;
begin
  ClearStrokes();
  inherited Destroy;
end;

procedure TUdTTFStrokes.ClearStrokes;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    FreeMem(Items[I]);
    Items[I] := nil;
  end;
  Self.Pack();
end;



//----------------------------------------------------------------------------------------

function TUdTTFStrokes.GetBounds: TRect;
var
  I: Integer;
  LStroke: PUdTTFStroke;
begin
  if Self.Count = 0 then
  begin
    Result := Rect(0, 0, 0, 0);
    Exit;
  end;

  Result := Rect(MaxInt, MaxInt, -MaxInt, -MaxInt);

  for I := 0 to Self.Count - 1 do
  begin
    LStroke := Self.Items[I];

    if LStroke^.Pt1.X < Result.Left   then Result.Left   := LStroke^.Pt1.X;
    if LStroke^.Pt1.X > Result.Right  then Result.Right  := LStroke^.Pt1.X;
    if LStroke^.Pt2.X < Result.Left   then Result.Left   := LStroke^.Pt2.X;
    if LStroke^.Pt2.X > Result.Right  then Result.Right  := LStroke^.Pt2.X;
    
    if LStroke^.Pt1.Y < Result.Top    then Result.Top    := LStroke^.Pt1.Y;
    if LStroke^.Pt1.Y > Result.Bottom then Result.Bottom := LStroke^.Pt1.Y;
    if LStroke^.Pt2.Y < Result.Top    then Result.Top    := LStroke^.Pt2.Y;
    if LStroke^.Pt2.Y > Result.Bottom then Result.Bottom := LStroke^.Pt2.Y;
  end;
end;

function TUdTTFStrokes.GetNumGlyphs: Integer;
begin
  if Self.Count = 0 then
    Result := 0
  else
    Result := PUdTTFStroke(Items[Count - 1])^.GlyphNumber + 1;
end;


function TUdTTFStrokes.GetStroke(Idx: Integer): TUdTTFStroke;
begin
  Assert((Idx >= 0) and (Idx < Count));

  if (Idx >= 0) and (Idx < Count) then
    Result := PUdTTFStroke(Items[Idx])^
end;




//----------------------------------------------------------------------------------------

function TUdTTFStrokes.StartOfGlyph(AGlyphNumber: Integer): Integer;
var
  I, LNg: Integer;
begin
  LNg := GetNumGlyphs();
  if (AGlyphNumber < 0) or (AGlyphNumber >= LNg) then
    Result := -1
  else begin
    for I := 0 to Count - 1 do
      if PUdTTFStroke(Items[I])^.GlyphNumber = AGlyphNumber then
        Break;
    Result := I;
  end;
end;

function TUdTTFStrokes.GlyphNumStrokes(AGlyphNumber: Integer): Integer;
var
  LSog, LEog: Integer;
begin
  LSog := StartOfGlyph(AGlyphNumber);
  if LSog < 0 then
    Result := -1
  else
  begin
    LEog := StartOfGlyph(AGlyphNumber + 1);
    if LEog < 0 then
      LEog := Count;
    Result := LEog - LSog;
  end;
end;

procedure TUdTTFStrokes.EnumStrokes(ACallback: TUdTTFEnumStrokesEvent);
var
  I: Integer;
begin
  if not Assigned(ACallback) then Exit;

  for I := 0 to Count - 1 do
    if not ACallback(I, PUdTTFStroke(Items[I])^) then
      Break;
end;






//=================================================================================================
{ TUdTTF }

constructor TUdTTF.Create();
begin
  inherited;

  FFont := TFont.Create;
  FFont.Name := 'Arial';
  FFont.Size := 10;

  FSplinePrecision := 2;
{$IF COMPILERVERSION >= 20.0 } { Delphi 2009 and above }
  FUnicode := True;
{$ELSE}
  FUnicode := False;
{$IFEND}
end;

destructor TUdTTF.Destroy;
begin
  FFont.Free;

  inherited;
end;

procedure TUdTTF.SetFont(Value: TFont);
begin
  if Assigned(Value) then
    FFont.Assign(Value);
end;



procedure TUdTTF.SetSplinePrecision(Value: Integer);
begin
  if (Value >= 1) and (Value <= 100) then
    FSplinePrecision := Value;
end;




//----------------------------------------------------------------------------------------

type
  TPointFxArray = array[0..MaxInt div SizeOf(TPointFx) - 1] of TPointFx;
  PPointFxArray = ^TPointFxArray;

//  TPoint2D = record
//    X, Y: Double;
//  end;


function TUdTTF.CreateCharGlyphs(ACharCode: Integer): TUdTTFStrokes;
const
  EMSIZE = 1024;
  SIZEX  = 1024;
  SIZEY  = 1024;


  function _Fix2Double(AFix: TFixed): Double;
  begin
    Result := AFix.fract / 65536.0 + AFix.value;
  end;

  procedure _NewStroke(AStrokes: TUdTTFStrokes; GlyphNumber: Integer; var APt1, APt2: TPoint2D);
  var
    LPs: PUdTTFStroke;
  begin
    LPs := AllocMem(SizeOf(TUdTTFStroke));
    LPs^.GlyphNumber := GlyphNumber;
    LPs^.Pt1.X := Round(APt1.X / EMSIZE * SIZEX);
    LPs^.Pt1.Y := Round(APt1.Y / EMSIZE * SIZEY);
    LPs^.Pt2.X := Round(APt2.X / EMSIZE * SIZEX);
    LPs^.Pt2.Y := Round(APt2.Y / EMSIZE * SIZEY);
    AStrokes.Add(LPs);
  end;

  procedure _DrawQSpline(AStrokes: TUdTTFStrokes; APolyN: Integer; var APa, APb, APc: TPoint2D);
  var
    I, LDi: Double;
    LP1, LP2: TPoint2D;
  begin
    LDi := 1.0 / FSplinePrecision;
    I := LDi;
    LP2 := APa;
    while I <= 1.0 do
    begin
      if I - LDi / 2 > 1.0 - LDi then I := 1.0;
      LP1 := LP2;
      LP2.X := (APa.X - 2 * APb.X + APc.X) * sqr(I) + (2 * APb.X - 2 * APa.X) * I + APa.X;
      LP2.Y := (APa.Y - 2 * APb.Y + APc.Y) * sqr(I) + (2 * APb.Y - 2 * APa.Y) * I + APa.Y;
      if not IsEqual(LP1, LP2) then
        _NewStroke(AStrokes, APolyN, LP1, LP2);
      I := I + LDi;
    end;
    APc := LP2;
  end;


var
  I, N: Integer;
  LMat2: TMat2;
  LDC, LMDC: HDC;
  LPolyCurve: PTTPolyCurve;
  LOFont: HFONT;
  LGlyphMet: TGlyphMetrics;
  LTextMetric: TTextMetric;
  LRes: Cardinal;
  LBufSize, LOffSize, LOffSize2, LPcSize: DWORD;
  LBufPtr, LBuf: PTTPolygonHeader;
  LPs, LP1, LP2, LPntA, LPntB, LPntC: TPoint2D;
  LPointFxs: PPointFxArray;
  LPcType: Integer;
  LDone: Boolean;
begin
  Result := nil;
  if Font.Handle = 0 then Exit;  //========>>>>>>

  LDC := GetDC(0);
  LMDC := CreateCompatibleDC(LDC);
  ReleaseDC(0, LDC);

  FFont.Size := EMSIZE;
  LOFont := SelectObject(LMDC, FFont.Handle);

  LMat2.eM11.value := 1;
  LMat2.eM11.fract := 1; { Identity matrix }
  LMat2.eM12.value := 0;
  LMat2.eM12.fract := 1; { |1,0|           }
  LMat2.eM21.value := 0;
  LMat2.eM21.fract := 1; { |0,1|           }
  LMat2.eM22.value := 1;
  LMat2.eM22.fract := 1;


  if not FUnicode then
    LBufSize := GetGlyphOutline(LMDC, ACharCode, GGO_NATIVE, LGlyphMet, 0, nil, LMat2)
  else
    LBufSize := GetGlyphOutlineW(LMDC, ACharCode, GGO_NATIVE, LGlyphMet, 0, nil, LMat2);

  if (LBufSize = GDI_ERROR) or (LBufSize = 0) then
  begin
    SelectObject(LMDC, LOFont);
    DeleteDC(LMDC);
    Exit; //========>>>>>>
  end;

  LBufPtr := AllocMem(LBufSize);
  LBuf := LBufPtr;

  if not FUnicode then
    LRes := GetGlyphOutline(LMDC, ACharCode, GGO_NATIVE, LGlyphMet, LBufSize, PAnsiChar(LBuf), LMat2)
  else
    LRes := GetGlyphOutlineW(LMDC, ACharCode, GGO_NATIVE, LGlyphMet, LBufSize, PAnsiChar(LBuf), LMat2);

  GetTextMetrics(LMDC, LTextMetric);

  SelectObject(LMDC, LOFont);
  DeleteDC(LMDC);

  if (LRes = GDI_ERROR) or (LBuf^.dwType <> TT_POLYGON_TYPE) then
  begin
    FreeMem(LBufPtr);
    Exit; //========>>>>>>
  end;


  Result := TUdTTFStrokes.Create;
  
  Result.FWidth  := LGlyphMet.gmCellIncX;
  Result.FHeight := LTextMetric.tmHeight;

  Result.FBoxWidth  := LGlyphMet.gmBlackBoxX;
  Result.FBoxHeight := LGlyphMet.gmBlackBoxY;

  Result.FBoxOrigin := Point(LGlyphMet.gmptGlyphOrigin.X,
                             LGlyphMet.gmptGlyphOrigin.Y - Integer(LGlyphMet.gmBlackBoxY) + LTextMetric.tmDescent);



  N := 0;
  LOffSize := 0;
  LDone := False;


  while not LDone do
  begin
    LPs.X := _Fix2Double(LBuf^.pfxStart.X);
    LPs.Y := _Fix2Double(LBuf^.pfxStart.Y);

    LPcSize := LBuf^.cb - SizeOf(TTTPOLYGONHEADER);
    PAnsiChar(LPolyCurve) := PAnsiChar(LBuf) + SizeOf(TTTPOLYGONHEADER);

    LOffSize2 := 0;
    LP2 := LPs;

    while not LDone and (LOffSize2 < LPcSize) do
    begin
      LPcType := LPolyCurve^.wType;

      case LPcType of

        TT_PRIM_LINE:
          begin
            LPointFxs := @LPolyCurve^.apfx[0];
            for I := 0 to LPolyCurve^.cpfx - 1 do
            begin
              LP1 := LP2;
              LP2.X := _Fix2Double(LPointFxs^[I].X);
              LP2.Y := _Fix2Double(LPointFxs^[I].Y);
              if not IsEqual(LP1, LP2) then
                _NewStroke(Result, N, LP1, LP2);
            end;
          end;

        TT_PRIM_QSPLINE:
          begin
            LPointFxs := @LPolyCurve^.apfx[0];
            LPntA := LP2;
            for I := 0 to LPolyCurve^.cpfx - 2 do
            begin
              LPntB.X := _Fix2Double(LPointFxs^[I].X);
              LPntB.Y := _Fix2Double(LPointFxs^[I].Y);
              if I < LPolyCurve^.cpfx - 2 then
              begin
                LPntC.X := _Fix2Double(LPointFxs^[I + 1].X);
                LPntC.Y := _Fix2Double(LPointFxs^[I + 1].Y);
                LPntC.X := (LPntC.X + LPntB.X) / 2;
                LPntC.Y := (LPntC.Y + LPntB.Y) / 2;
              end
              else
              begin
                LPntC.X := _Fix2Double(LPointFxs^[I + 1].X);
                LPntC.Y := _Fix2Double(LPointFxs^[I + 1].Y);
              end;
              _DrawQSpline(Result, N, LPntA, LPntB, LPntC);
              LPntA := LPntC;
            end;
            LP2 := LPntC;
          end;
      end;
      LOffSize2 := LOffSize2 + DWORD(SizeOf(TTTPOLYCURVE) + (LPolyCurve^.cpfx - 1) * SizeOf(TPointFx));
      PAnsiChar(LPolyCurve) := PAnsiChar(LPolyCurve) + SizeOf(TTTPOLYCURVE) + (LPolyCurve^.cpfx - 1) * SizeOf(TPointFx);
    end;

    if not LDone then
    begin
      LP1 := LP2;
      LP2 := LPs;
      if not IsEqual(LP1, LP2) then
        _NewStroke(Result, N, LP1, LP2);
      LOffSize := LOffSize + LPcSize + SizeOf(TTTPOLYGONHEADER);
      LDone := LOffSize >= (LBufSize - SizeOf(TTTPolygonHeader));
      PAnsiChar(LBuf) := PAnsiChar(LPolyCurve);
      Inc(N);
    end;
  end;

  FreeMem(LBufPtr);
end;



function TUdTTF.GetCharRegion(ACharCode: Integer; ASizeX, ASizeY: Integer; AOfsX, AOfsY: Integer): HRGN;
var
  I, J: Integer;
  LSog: Integer;
  LBounds: TRect;
  LOfsX, LOfsY: Integer;
  LStroke: TUdTTFStroke;
  LStrokes: TUdTTFStrokes;
  LPolys, LPps: ^TPoint;
  LPolyCount, LPpCount: ^LongWord;
  LScaleX, LScaleY: Double; { Scaling factors }
begin
  // Convert to polilines
  LStrokes := CreateCharGlyphs(ACharCode);

  if LStrokes = nil then
  begin
    Result := 0;
    Exit; //========>>>>>>
  end;

  LBounds := LStrokes.GetBounds();

//  LScaleX := SizeX / (LBounds.Right - LBounds.Left + 1);
//  LScaleY := SizeY / (LBounds.Bottom - LBounds.Top + 1);

  LScaleX := ASizeX / LStrokes.FWidth;
  LScaleY := ASizeY / LStrokes.FHeight;

  LOfsX := Trunc(AOfsX + LStrokes.FBoxOrigin.X * LScaleX);
  LOfsY := Trunc(AOfsY + LStrokes.FBoxOrigin.Y * LScaleY);


   // Allocate memory for (all) the points
  LPolys := AllocMem(SizeOf(TPoint) * LStrokes.Count);

  // Allocate memory for the "points per polygon" counters }
  LPolyCount := AllocMem(SizeOf(LongWord) * LStrokes.NumGlyphs);
  try
    // Copy glyphs' points to the allocated buffers
    LPps := LPolys;
    LPpCount := LPolyCount;
    for I := 0 to LStrokes.NumGlyphs - 1 do
    begin
      LPpCount^ := LStrokes.GlyphNumStrokes(I);
      LSog := LStrokes.StartOfGlyph(I);
      for J := 0 to LPpCount^ - 1 do
      begin
        LStroke := LStrokes.Stroke[LSog + J];

        LPps^.x := LOfsX + Round((LStroke.Pt1.X - LBounds.Left) * LScaleX);
        LPps^.y := LOfsY + Round((LBounds.Bottom - LStroke.Pt1.Y) * LScaleY); {  Flip vertically! }

        LPps := Pointer(PAnsiChar(LPps) + SizeOf(TPoint));
      end;
      LPpCount := Pointer(PAnsiChar(LPpCount) + SizeOf(LPpCount^));
    end;

    Result := CreatePolyPolygonRgn(LPolys^, LPolyCount^, LStrokes.NumGlyphs, WINDING);
  finally
    FreeMem(LPolys);
    FreeMem(LPolyCount);

    LStrokes.Free;
  end;
end;



//===================================================================================================

function TTFCharCode(AValue: WideChar): LongWord;
var
  LValue: string;
begin
  LValue := AValue;

  if System.Length(LValue) = 1 then
    Result := Ord(LValue[1])
{$IF COMPILERVERSION >= 21.0 }
  else if (System.Length(LValue) = 2) and CharInSet(LValue[1], LeadBytes) then
{$ELSE}
  else if (System.Length(LValue) = 2) and (LValue[1] in LeadBytes) then
{$IFEND}
    Result := (Ord(LValue[1]) shl 8) or Ord(LValue[2])
  else
    Result := 0; //Raise(Exception.Create(LValue + ' is not a valid char'));
end;

function TUdTTF.GetCharPolys(ACharCode: Integer; var AOfsX, AOfsY: Float; AHeight: Double; AWidthFactor: Double = 1.0): TUdTTFPolygon;
var
  I, J, N: Integer;
  LOfsX, LOfsY: Float;
  LSog: Integer;
  LBounds: TRect;
  LStroke: TUdTTFStroke;
  LStrokes: TUdTTFStrokes;
  LScaleX, LScaleY: Double; { Scaling factors }
begin
  Result.Polys := nil;
  Result.Counts := nil;

  LStrokes := CreateCharGlyphs(ACharCode);
  if LStrokes = nil then Exit; //========>>>>>>

 
  LBounds := LStrokes.GetBounds();

  LScaleY := AHeight / LStrokes.FHeight;
  LScaleX := AWidthFactor * LScaleY;

  LOfsX := AOfsX + LStrokes.FBoxOrigin.X * LScaleX;
  LOfsY := AOfsY + LStrokes.FBoxOrigin.Y * LScaleY;


  System.SetLength(Result.Polys, LStrokes.Count);
  System.SetLength(Result.Counts, LStrokes.NumGlyphs);

  try
    N := 0;
    for I := 0 to LStrokes.NumGlyphs - 1 do
    begin
      Result.Counts[I] := LStrokes.GlyphNumStrokes(I);

      LSog := LStrokes.StartOfGlyph(I);
      for J := 0 to Result.Counts[I] {LPpCount^} - 1 do
      begin
        LStroke := LStrokes.Stroke[LSog + J];

        Result.Polys[N].X := LOfsX + (LStroke.Pt1.X - LBounds.Left) * LScaleX;
        Result.Polys[N].Y := LOfsY + (LStroke.Pt1.Y - LBounds.Top)  * LScaleY;

        Inc(N);
      end;
    end;

    AOfsX := AOfsX + LStrokes.FWidth * LScaleX;
  finally
    LStrokes.Free;
  end;
end;

function TUdTTF.GetCharPolys(AChar: WideChar; var AOfsX, AOfsY: Float; AHeight: Double; AWidthFactor: Double = 1.0): TUdTTFPolygon;
var
  LCharCode: Integer;
begin
  LCharCode := TTFCharCode(AChar);
  Result := Self.GetCharPolys(LCharCode, AOfsX, AOfsY, AHeight, AWidthFactor);
end;





function TUdTTF.GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec;
  var ATextWidth, ATextHeight: Float; var ATextBound: TPoint2DArray): TUdTTFPolygonArray;

  function _CalcOffset(ALinesWidth: TFloatArray): TPoint2DArray;
  var
    I, L: Integer;
    LCenH, LMaxW: Float;
  begin
    Result := nil;

    L := System.Length(ALinesWidth);
    if L <= 0 then Exit;

    System.SetLength(Result, L);
    for I := 0 to L - 1 do Result[I] := Point2D(0, 0);

    if AStyle.Align in [taTopLeft, taTopCenter, taTopRight] then
    begin
      for I := 0 to L - 1 do
        Result[I].Y := (- I) * AHeight * AStyle.LineSpaceFactor - AHeight;
    end else
    if AStyle.Align in [taMiddleLeft, taMiddleCenter, taMiddleRight] then
    begin
      LCenH := (L * AHeight + (L - 1) * AHeight * AStyle.LineSpaceFactor) / 2;
      for I := 0 to L - 1 do
        Result[I].Y := (L - 1 - I) * AHeight * AStyle.LineSpaceFactor - LCenH;
    end else
    if AStyle.Align in [taBottomLeft, taBottomCenter, taBottomRight] then
    begin
      for I := 0 to L - 1 do
        Result[I].Y := (L - 1 - I) * AHeight * AStyle.LineSpaceFactor;
    end;

    LMaxW := ALinesWidth[0];
    for I := 1 to L - 1 do if ALinesWidth[I] > LMaxW then LMaxW := ALinesWidth[I];

    if AStyle.Align in [taTopCenter, taMiddleCenter, taBottomCenter] then
    begin
      for I := 0 to L - 1 do
        Result[I].X :=  (LMaxW - ALinesWidth[I]) / 2 - LMaxW/2;
    end else
    if AStyle.Align in [taTopRight, taMiddleRight, taBottomRight] then
    begin
      for I := 0 to L - 1 do
        Result[I].X :=  - ALinesWidth[I];
    end;
  end;


var
  L, N: Integer;
  I, J, K: Integer;
  LTTFObj: TUdTTF;
  LShxObj: TUdShx;
  LLn: TLine2D;
  LOfsX, LOfsY, LOfsY2: Float;
  LText: WideString;
  LStrings: TStringList;
  LLinesIndex: TPointArray;
  LLinesWidth: TFloatArray;
  LLinesOffset: TPoint2DArray;
  LCharCodes: TUdCharCodeArray;
  LReturn: TUdTTFPolygonArray;
  LTxtBound: TPoint2DArray;
  LTxtLeft, LTxtRight, LTxtBottom, LTxtTop, LTxtWidth: Float;
  LShxPolys: TPoint2DArrays;
  LTTFPoly: TUdTTFPolygon;
  LTTFPolys: PUdTTFPolygonArray;
  LTTFPolysList: TList;
begin
  Result := nil;
  LReturn := nil;
  if AText = '' then Exit;

  LStrings := TStringList.Create;
  LTTFPolysList := TList.Create;  
  try
    LStrings.Text := AText;

    if LStrings.Count > 0 then
    begin
      System.SetLength(LLinesWidth, LStrings.Count);
      System.SetLength(LLinesIndex, LStrings.Count);

      for I := 0 to LStrings.Count - 1 do
      begin
        LText := LStrings[I];
        LCharCodes := UdShx._GetCharCodes(LText, TTFCharCode);

        LOfsX := 0.0;
        LOfsY := 0.0;

        LLinesIndex[I].X := LTTFPolysList.Count;

        for J := 0 to Length(LCharCodes) - 1 do
        begin
          LTTFObj := nil;
          case LCharCodes[J].Kind of
            1: LTTFObj := GetDefGdtTTF();
            2: LTTFObj := GetDefIsoCpeurTTF();
          end;
          if not Assigned(LTTFObj) then LTTFObj := Self;


          LTTFPoly := LTTFObj.GetCharPolys(LCharCodes[J].Value, LOfsX, LOfsY, AHeight, AStyle.WidthFactor);

          if Length(LTTFPoly.Polys) > 0 then
          begin
            LTTFPolys := New(PUdTTFPolygonArray);
            SetLength(LTTFPolys^, 1);
            LTTFPolys^[0] := LTTFPoly;

            LTTFPolysList.Add(LTTFPolys);
          end
          else begin
            LShxObj := nil;
            case LCharCodes[J].Kind of
              1: LShxObj := UdShx.GetDefGdtShx();
              2: LShxObj := UdShx.GetDefSimplexShx();
            end;

            if Assigned(LShxObj) then
            begin
              LOfsY2 := LOfsY + AHeight * 0.2;
              LShxPolys := LShxObj.GetCharPolys(LCharCodes[J].Value, LOfsX, LOfsY2, AHeight * 0.6, AStyle.WidthFactor);
              
              LTTFPolys := New(PUdTTFPolygonArray);
              SetLength(LTTFPolys^, Length(LShxPolys));

              for K := 0 to Length(LShxPolys) - 1 do
              begin
                LTTFPolys^[K].Counts := nil;
                LTTFPolys^[K].Polys  := LShxPolys[K];
              end;

              LTTFPolysList.Add(LTTFPolys);
            end;
          end;
        end;

        LLinesIndex[I].Y := LTTFPolysList.Count - 1; //System.Length(LReturn) - 1;

        if LLinesIndex[I].Y >= LLinesIndex[I].X then
          LLinesWidth[I] := LOfsX
        else
          LLinesWidth[I] := 0;
      end; {end for I}

      LLinesOffset := _CalcOffset(LLinesWidth);

      for I := 0 to System.Length(LLinesOffset) - 1 do
      begin
        for J := LLinesIndex[I].X to LLinesIndex[I].Y do
        begin
          LTTFPolys := PUdTTFPolygonArray(LTTFPolysList[J]);

          for K := 0 to Length(LTTFPolys^) - 1 do
          begin
            for L := 0 to System.Length(LTTFPolys^[K].Polys) - 1 do
            begin
              LTTFPolys^[K].Polys[L].X := APosition.X + LTTFPolys^[K].Polys[L].X + LLinesOffset[I].X;
              LTTFPolys^[K].Polys[L].Y := APosition.Y + LTTFPolys^[K].Polys[L].Y + LLinesOffset[I].Y;
            end;
          end;
        end;
      end;

      L := 0;
      for I := 0 to LTTFPolysList.Count - 1 do
      begin
        LTTFPolys := PUdTTFPolygonArray(LTTFPolysList[I]);
        L := L + Length(LTTFPolys^);
      end;

      N := 0;
      SetLength(LReturn, L);
      for I := 0 to LTTFPolysList.Count - 1 do
      begin
        LTTFPolys := PUdTTFPolygonArray(LTTFPolysList[I]);
        for J := 0 to Length(LTTFPolys^) - 1 do
        begin
          LReturn[N] := LTTFPolys^[J];
          Inc(N);
        end;
      end;
            
      {
      for I := 0 to System.Length(LLinesOffset) - 1 do
      begin
        for J := LLinesIndex[I].X to LLinesIndex[I].Y do
        begin
          for K := 0 to System.Length(LReturn[J].Polys) - 1 do
          begin
            LReturn[J].Polys[K].X := APosition.X + LReturn[J].Polys[K].X + LLinesOffset[I].X;
            LReturn[J].Polys[K].Y := APosition.Y + LReturn[J].Polys[K].Y + LLinesOffset[I].Y;
          end;
        end;
      end;
      }

      LTxtLeft := LLinesOffset[0].X;
      for I := 1 to System.Length(LLinesOffset) - 1 do
        if LLinesOffset[I].X < LTxtLeft then LTxtLeft := LLinesOffset[I].X;
      LTxtLeft  := APosition.X + LTxtLeft;

      LTxtWidth := LLinesWidth[0];
      for I := 1 to System.Length(LLinesWidth) - 1 do if LLinesWidth[I] > LTxtWidth then LTxtWidth := LLinesWidth[I];
      LTxtRight := LTxtLeft + LTxtWidth;

      LTxtTop    := APosition.Y + LLinesOffset[0].Y + AHeight;
      LTxtBottom := APosition.Y + LLinesOffset[High(LLinesOffset)].Y;

      System.SetLength(LTxtBound, 4);
      LTxtBound[0] := Point2D(LTxtLeft, LTxtBottom);
      LTxtBound[1] := Point2D(LTxtLeft, LTxtTop);
      LTxtBound[2] := Point2D(LTxtRight, LTxtTop);
      LTxtBound[3] := Point2D(LTxtRight, LTxtBottom);


      if NotEqual(AStyle.Rotation, 0.0) then
      begin
        for I := 0 to System.Length(LReturn) - 1 do
          LReturn[I].Polys := UdGeo2D.Rotate(APosition, AStyle.Rotation, LReturn[I].Polys);
        LTxtBound := UdGeo2D.Rotate(APosition, AStyle.Rotation, LTxtBound);
      end;

      if AStyle.Backward then
      begin
        LLn := Line2D(APosition, UdGeo2D.ShiftPoint(APosition, AStyle.Rotation + 90, 100));
        for I := 0 to System.Length(LReturn) - 1 do
          LReturn[I].Polys := UdGeo2D.Mirror(LLn, LReturn[I].Polys);
        LTxtBound := UdGeo2D.Mirror(LLn, LTxtBound);
      end;

      if AStyle.Upsidedown then
      begin
        LLn := Line2D(APosition, UdGeo2D.ShiftPoint(APosition, AStyle.Rotation, 100));
        for I := 0 to System.Length(LReturn) - 1 do
          LReturn[I].Polys := UdGeo2D.Mirror(LLn, LReturn[I].Polys);
        LTxtBound := UdGeo2D.Mirror(LLn, LTxtBound);
      end;

      ATextBound := LTxtBound;
      ATextWidth := Abs(LTxtRight - LTxtLeft);
      ATextHeight := Abs(LTxtBottom - LTxtTop);

      Result := LReturn;
    end;
  finally
    LStrings.Free;
    for I := LTTFPolysList.Count - 1 downto 0 do Dispose(PUdTTFPolygonArray(LTTFPolysList[I]));
    LTTFPolysList.Free;
  end;
end;


function TUdTTF.GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec; var ATextBound: TPoint2DArray): TUdTTFPolygonArray;
var
  LTextWidth, LTextHeight: Float;
begin
  Result := GetTextPolys(AText, APosition, AHeight, AStyle, LTextWidth, LTextHeight, ATextBound);
end;

function TUdTTF.GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec): TUdTTFPolygonArray;
var
  LTxtBound: TPoint2DArray;
begin
  Result := GetTextPolys(AText, APosition, AHeight, AStyle, LTxtBound);
end;









//==================================================================================================


initialization
//  GDefFontDir := SysUtils.ExtractFilePath(Application.ExeName) + 'Fonts';
  GGdtTTF   := nil;
  GIsoCpTTF := nil;


finalization
  if Assigned(GGdtTTF) then GGdtTTF.Free;
  GGdtTTF := nil;
  
  if Assigned(GIsoCpTTF) then GIsoCpTTF.Free;
  GIsoCpTTF := nil;


  

end.