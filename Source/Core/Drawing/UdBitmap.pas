{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdBitmap;

{$I UdDefs.inc}

interface

{$IFDEF CPUX86_64}
  // target is a 64-bit processor (AMD or INTEL).
  {$DEFINE TARGET_X64}
{$ENDIF}

{$IFNDEF WIN32}
  {$DEFINE USENATIVECODE}
{$ENDIF}


uses
  Windows, Controls, Graphics, Types,
  Classes, UdObject, UdThreadObject {$IFNDEF D2010}, UdCanvas{$ENDIF};


type
  PColor32 = ^TColor32;
  TColor32 = type Cardinal;

  PColor32Array = ^TColor32Array;
  TColor32Array = array of TColor32;

  PPalette32 = ^TPalette32;
  TPalette32 = array [Byte] of TColor32;

  PColor32StaticArray = ^TColor32StaticArray;
  TColor32StaticArray = array [0..0] of TColor32;


const
  // Some predefined color constants
  clBlack32     = TColor32($FF000000);
  clGray32      = TColor32($FF7F7F7F);
  clWhite32     = TColor32($FFFFFFFF);
  clMaroon32    = TColor32($FF7F0000);
  clGreen32     = TColor32($FF007F00);
  clOlive32     = TColor32($FF7F7F00);
  clNavy32      = TColor32($FF00007F);
  clPurple32    = TColor32($FF7F007F);
  clTeal32      = TColor32($FF007F7F);
  clRed32       = TColor32($FFFF0000);
  clLime32      = TColor32($FF00FF00);
  clYellow32    = TColor32($FFFFFF00);
  clBlue32      = TColor32($FF0000FF);
  clFuchsia32   = TColor32($FFFF00FF);
  clAqua32      = TColor32($FF00FFFF);


type

  TUdBitmap = class(TUdThreadObject)
  private
    FHeight: Integer;
    FWidth: Integer;

    FBits: PColor32StaticArray;

    FStipplePos: Integer;
    FStippleBits: TByteDynArray;


    FClipRect: TRect;
    FClipping: Boolean;

    FHDC: HDC;
    FBitmapInfo: TBitmapInfo;
    FBitmapHandle: HBITMAP;
    FCanvas: TCanvas;

    FOuterColor: TColor32;

    FOnResize: TNotifyEvent;
    FOnHandleChanged: TNotifyEvent;

  protected
    procedure DoHandleChanged(); virtual;
    procedure ChangeSize(var AWidth, AHeight: Integer; ANewWidth, ANewHeight: Integer);

    procedure SetWidth(const AValue: Integer);
    procedure SetHeight(const AValue: Integer);

    procedure OnCanvasChanged(Sender: TObject);
    function  GetCanvas: TCanvas;
    procedure DeleteCanvas();

    function  GetPixel(X, Y: Integer): TColor32;
    function  GetPixelS(X, Y: Integer): TColor32;
    procedure SetPixel(X, Y: Integer; AValue: TColor32);
    procedure SetPixelS(X, Y: Integer; AValue: TColor32);

    function  GetPixelPtr(X, Y: Integer): PColor32;
    function  GetScanLine(Y: Integer): PColor32StaticArray;

    procedure SetClipRect(const AValue: TRect);

    procedure FFillRect(const X1, Y1, X2, Y2: Integer; const AValue: TColor32);

    procedure CanvasMoveTo(X, Y: Integer);
    procedure CanvasLineTo(X, Y: Integer);

  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(ASource: TPersistent); override;
    function SetSize(ANewWidth, ANewHeight: Integer): Boolean;

    function Empty(): Boolean;
    procedure Clear(); overload;
    procedure Clear(FillColor: TColor32); overload;

    procedure Draw(const ADstRect, ASrcRect: TRect; hSrc: HDC);

    procedure HorzLine(X1, Y, X2: Integer; const AValue: TColor32);
    procedure VertLine(X, Y1, Y2: Integer; const AValue: TColor32);
    procedure Line(X1, Y1, X2, Y2: Integer; const AValue: TColor32; L: Boolean = False);

    procedure FillRect(X1, Y1, X2, Y2: Integer; const AValue: TColor32); overload;

    procedure FrameRect(X1, Y1, X2, Y2: Integer; const AValue: TColor32); overload;
    procedure FrameRect(const ARect: TRect; const AValue: TColor32); overload;

    procedure ResetClipRect;
    procedure SetStipples(const AValue: TIntegerDynArray);

    function BoundsRect: TRect;
    function CanvasAllocated: Boolean;

  public
    property Canvas: TCanvas read GetCanvas;

    property Pixel[X, Y: Integer]: TColor32 read GetPixel write SetPixel;
    property PixelS[X, Y: Integer]: TColor32 read GetPixelS write SetPixelS;

    property Bits: PColor32StaticArray read FBits;

    property Handle: HDC read FHDC;
    property BitmapHandle: HBITMAP read FBitmapHandle;
    property BitmapInfo: TBitmapInfo read FBitmapInfo;

    property ClipRect: TRect read FClipRect write SetClipRect;
    property Clipping: Boolean read FClipping;

    property PixelPtr[X, Y: Integer]: PColor32 read GetPixelPtr;
    property ScanLine[Y: Integer]: PColor32StaticArray read GetScanLine;

//    property Stipples: TIntegerDynArray read FStipples write SetStipples;

  published
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;

    property OuterColor: TColor32 read FOuterColor write FOuterColor default 0;

    property OnChange;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
    property OnHandleChanged: TNotifyEvent read FOnHandleChanged write FOnHandleChanged;
  end;




  TUdCanvas32 = class({$IFDEF D2010UP} TCanvas {$ELSE} TUdCanvas {$ENDIF})
  private
    FOwnerBmp: TUdBitmap;
    FRasterX, FRasterY: Integer;
    FUserPenStyle: TByteDynArray;

  protected
    {$IF COMPILERVERSION <= 17 }
    FUserPenMode: Boolean;
    procedure CreateHandle; override;
    {$IFEND}
    
  public
    constructor Create;
    destructor Destroy; override;
      
  {$IFDEF D2010UP}
    procedure MoveTo(X, Y: Integer); override;
    procedure LineTo(X, Y: Integer); override;
  {$ELSE}
    procedure MoveToEx(X, Y: Integer); override;
    procedure LineToEx(X, Y: Integer); override;
  {$ENDIF}

   {$IF COMPILERVERSION <= 17 }
   property UserPenMode: Boolean read FUserPenMode write FUserPenMode;
   {$IFEND}
   property UserPenStyle: TByteDynArray read FUserPenStyle write FUserPenStyle;
  end;

  

// Color construction and conversion functions
function Color32(WinColor: TColor): TColor32; overload;
function Color32(R, G, B: Byte; A: Byte = $FF): TColor32; overload;
function WinColor(Color32: TColor32): TColor;




implementation

uses
  SysUtils, Math, Dialogs;


type
  TFGraphic = class(TGraphic);


var
  DASH_STYLE      : TByteDynArray; //array[0..23] of Byte = (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0);
  DOT_STYLE       : TByteDynArray; //array[0..5]  of Byte = (1, 1, 1, 0, 0, 0);
  DASHDOT_STYLE   : TByteDynArray; //array[0..23] of Byte = (1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0);
  DASHDOTDOT_STYLE: TByteDynArray; //array[0..23] of Byte = (1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0);



//==================================================================================================


{$IFDEF USENATIVECODE}
  procedure FillLongword(var X; Count: Integer; AValue: Longword);  {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}
  var
    I: Integer;
    P: PIntegerArray;
  begin
    P := PIntegerArray(@X);
    for I := Count - 1 downto 0 do
      P[I] := Integer(AValue);
  end;
{$ELSE}
  procedure FillLongword(var X; Count: Integer; AValue: Longword); // {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}
  asm
  {$IFDEF TARGET_X64}
          // ECX = X;   EDX = Count;   R8 = AValue
          PUSH    RDI

          MOV     EDI,ECX  // Point EDI to destination
          MOV     RAX,R8   // copy value from R8 to RAX (EAX)
          MOV     ECX,EDX  // copy count to ECX
          TEST    ECX,ECX
          JS      @exit

          REP     STOSD    // Fill count dwords
  @exit:
          POP     RDI
  {$ELSE}
          // EAX = X;   EDX = Count;   ECX = AValue
          PUSH    EDI

          MOV     EDI,EAX  // Point EDI to destination
          MOV     EAX,ECX
          MOV     ECX,EDX
          TEST    ECX,ECX
          JS      @exit

          REP     STOSD    // Fill count dwords
  @exit:
          POP     EDI
  {$ENDIF}
  end;
{$ENDIF}





//==================================================================================================

procedure Swap(var A, B: Integer);  {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}
var
  T: Integer;
begin
  T := A;
  A := B;
  B := T;
end;


procedure TestSwap(var A, B: Integer);  {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}
var
  T: Integer;
begin
  if B < A then
  begin
    T := A;
    A := B;
    B := T;
  end;
end;


function TestClip(var A, B: Integer; const Start, Stop: Integer): Boolean;
begin
  TestSwap(A, B);
  if A < Start then A := Start;
  if B >= Stop then B := Stop - 1;
  Result := B >= A;
end;




//==================================================================================================
{ Color construction and conversion functions }

function Color32(WinColor: TColor): TColor32; overload;
{$IFDEF WIN_COLOR_FIX}
var
  I: Longword;
{$ENDIF}
begin
  if WinColor < 0 then WinColor := GetSysColor(WinColor and $000000FF);

{$IFDEF WIN_COLOR_FIX}
  Result := $FF000000;
  I := (WinColor and $00FF0000) shr 16;
  if I <> 0 then Result := Result or TColor32(Integer(I) - 1);
  I := WinColor and $0000FF00;
  if I <> 0 then Result := Result or TColor32(Integer(I) - $00000100);
  I := WinColor and $000000FF;
  if I <> 0 then Result := Result or TColor32(Integer(I) - 1) shl 16;
{$ELSE}
  {$IFDEF USENATIVECODE}
    Result := $FF shl 24 + (WinColor and $FF0000) shr 16 + (WinColor and $FF00) +
      (WinColor and $FF) shl 16;
  {$ELSE}
    asm
          MOV    EAX,WinColor
          BSWAP  EAX
          MOV    AL,$FF
          ROR    EAX,8
          MOV    Result,EAX
    end;
  {$ENDIF}
{$ENDIF}
end;

function Color32(R, G, B: Byte; A: Byte = $FF): TColor32; overload;
{$IFDEF USENATIVECODE}
begin
  Result := (A shl 24) or (R shl 16) or (G shl  8) or B;
{$ELSE}
asm
        MOV     AH, A
        SHL     EAX, 16
        MOV     AH, DL
        MOV     AL, CL
{$ENDIF}
end;

function WinColor(Color32: TColor32): TColor;
{$IFDEF USENATIVECODE}
begin
  Result := ((Color32 and $00FF0000) shl 16) or
             (Color32 and $0000FF00) or
            ((Color32 and $000000FF) shr 16);
{$ELSE}
asm
  {$IFDEF TARGET_X64}
        MOV     EAX, ECX
  {$ENDIF}
        // the alpha channel byte is set to zero!
        ROL     EAX, 8  // ABGR  ->  BGRA
        XOR     AL, AL  // BGRA  ->  BGR0
        BSWAP   EAX     // BGR0  ->  0RGB
{$ENDIF}
end;







//==================================================================================================
{ TCanvas32 }


constructor TUdCanvas32.Create;
begin
  inherited;
  FUserPenStyle := nil;

{$IF COMPILERVERSION <= 17 }
  FUserPenMode := False;
{$IFEND}
end;

destructor TUdCanvas32.Destroy;
begin
  FUserPenStyle := nil;
  inherited;
end;

{$IF COMPILERVERSION <= 17 }
procedure TUdCanvas32.CreateHandle;
begin
  inherited;
  FUserPenMode := False;
end;
{$IFEND}


{$IFDEF D2010UP}

procedure TUdCanvas32.MoveTo(X, Y: Integer);
begin
  if (Self.Pen.Width > 1) then inherited;
  FOwnerBmp.FStipplePos := 0;
  FRasterX := X;
  FRasterY := Y;
end;

procedure TUdCanvas32.LineTo(X, Y: Integer);
var
  LBits: TByteDynArray;
begin
  if (Self.Pen.Width > 1) then
    inherited
  else begin
    if Self.Pen.Style <> psClear then
    begin
      LBits := FOwnerBmp.FStippleBits;

      case Self.Pen.Style of
        psDash       : FOwnerBmp.FStippleBits := DASH_STYLE;
        psDot        : FOwnerBmp.FStippleBits := DOT_STYLE;
        psDashDot    : FOwnerBmp.FStippleBits := DASHDOT_STYLE;
        psDashDotDot : FOwnerBmp.FStippleBits := DASHDOTDOT_STYLE;
        psUserStyle  : FOwnerBmp.FStippleBits := FUserPenStyle;
        else
         FOwnerBmp.FStippleBits := nil;
      end;
      FOwnerBmp.Line(FRasterX, FRasterY, X, Y, Color32(Self.Pen.Color), True);

      FOwnerBmp.FStippleBits := LBits;
    end;
  end;

  FRasterX := X;
  FRasterY := Y;
end;

{$ELSE}

procedure TUdCanvas32.MoveToEx(X, Y: Integer);
begin
  if (Self.Pen.Width <> 1) then inherited;
  FOwnerBmp.FStipplePos := 0;
  FRasterX := X;
  FRasterY := Y;
end;

procedure TUdCanvas32.LineToEx(X, Y: Integer);
var
  LBits: TByteDynArray;
begin
  if (Self.Pen.Width <> 1) then
    inherited
  else begin
    if Self.Pen.Style <> psClear then
    begin
      LBits := FOwnerBmp.FStippleBits;

      case Self.Pen.Style of
        psDash       : FOwnerBmp.FStippleBits := DASH_STYLE;
        psDot        : FOwnerBmp.FStippleBits := DOT_STYLE;
        psDashDot    : FOwnerBmp.FStippleBits := DASHDOT_STYLE;
        psDashDotDot : FOwnerBmp.FStippleBits := DASHDOTDOT_STYLE;
        {$IF COMPILERVERSION > 17 }
        psUserStyle  : FOwnerBmp.FStippleBits := FUserPenStyle;
        {$IFEND}

        else begin
        {$IF COMPILERVERSION <= 17 }

          if FUserPenMode then
            FOwnerBmp.FStippleBits := FUserPenStyle
          else
            FOwnerBmp.FStippleBits := nil;
        {$ELSE}
          FOwnerBmp.FStippleBits := nil;
        {$IFEND}
        end;
      end;
      FOwnerBmp.Line(FRasterX, FRasterY, X, Y, Color32(Self.Pen.Color), True);

      FOwnerBmp.FStippleBits := LBits;
    end;
  end;

  FRasterX := X;
  FRasterY := Y;
end;

{$ENDIF}


//==================================================================================================
{ TUdBitmap }

constructor TUdBitmap.Create;
begin
  inherited;

  FHeight := 0;
  FWidth  := 0;

  FBits := nil;
  FStippleBits := nil;

  FClipRect := Rect(0, 0, 0, 0);
  FClipping := False;

  FHDC := 0;
  FBitmapHandle := 0;
  FCanvas := nil;

  FillChar(FBitmapInfo, SizeOf(TBitmapInfo), 0);
  with FBitmapInfo.bmiHeader do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
  end;

  FOuterColor := $00000000;  // by default as full transparency black
end;

destructor TUdBitmap.Destroy;
begin
//  BeginUpdate;
  Lock;
  try
    DeleteCanvas();
    SetSize(0, 0);
  finally
    Unlock;
  end;
  inherited;
end;




//------------------------------------------------------------------------------

procedure TUdBitmap.Assign(ASource: TPersistent);
var
  DstColor: TColor32;
  DstP, SrcP: PColor32;

  procedure _CopyFromBitmap(ASrcBmp: TBitmap);
  var
    I: integer;
    LColor: TColor32;
  begin
    SetSize(ASrcBmp.Width, ASrcBmp.Height);
    if Empty() then Exit;

    ASrcBmp.Canvas.Lock; // lock to avoid GDI memory leaks, eg. when calling from threads
    try
      BitBlt(Handle, 0, 0, Width, FHeight, ASrcBmp.Canvas.Handle, 0, 0, SRCCOPY);
    finally
      ASrcBmp.Canvas.UnLock;
    end;

//    if ASrcBmp.PixelFormat <> pf32bit then ResetAlpha;
    if ASrcBmp.Transparent then
    begin
      LColor := Color32(ASrcBmp.TransparentColor) and $00FFFFFF;
      DstP := @FBits[0];
      for I := 0 to Width * FHeight - 1 do
      begin
        DstColor := DstP^ and $00FFFFFF;
        if DstColor = LColor then
          DstP^ := DstColor;
        inc(DstP);
      end;
    end;
  end;

var
  I: integer;
  LCanvas: TCanvas;
  LBtimap: TUdBitmap;
//  LPicture: TPicture;
begin
  Self.BeginUpdate();
  try
    if ASource = nil then
    begin
      SetSize(0, 0);
    end
    else if ASource is TUdBitmap then
    begin
      SetSize(TUdBitmap(ASource).Width, TUdBitmap(ASource).FHeight);
      if Empty() then Exit;
      BitBlt(Handle, 0, 0, Width, FHeight, TUdBitmap(ASource).Handle, 0, 0, SRCCOPY);
      //Move(TUdBitmap(ASource).FBits[0], FBits[0], FWidth * FHeight * 4);
      //Move is up to 2x faster with FastMove by the FastCode Project
      FOuterColor := TUdBitmap(ASource).FOuterColor;
    end
    else if ASource is TBitmap then
    begin
      _CopyFromBitmap(TBitmap(ASource));
    end
    else if ASource is TGraphic then
    begin
      SetSize(TGraphic(ASource).Width, TGraphic(ASource).Height);
      if Empty() then Exit;
      LCanvas := TCanvas.Create;
      try
        LCanvas.Handle := Self.Handle;
        TFGraphic(ASource).Draw(LCanvas, Rect(0, 0, Width, FHeight));
//        ResetAlpha;
      finally
        LCanvas.Free;
      end;
    end
    else if ASource is TPicture then
    begin
      with TPicture(ASource) do
      begin
        if TPicture(ASource).Graphic is TBitmap then
          _CopyFromBitmap(TBitmap(TPicture(ASource).Graphic))
        else if (TPicture(ASource).Graphic is TIcon) or
                (TPicture(ASource).Graphic is TMetaFile) then
        begin
          // icons, metafiles etc...
          SetSize(TPicture(ASource).Graphic.Width, TPicture(ASource).Graphic.Height);
          if Empty() then Exit;

          LBtimap := TUdBitmap.Create;
          LCanvas := TCanvas.Create;
          try
            Self.Clear(clWhite32);  // mask on white;
            LCanvas.Handle := Self.Handle;
            TFGraphic(Graphic).Draw(LCanvas, Rect(0, 0, Width, FHeight));

            LBtimap.SetSize(TPicture(ASource).Graphic.Width, TPicture(ASource).Graphic.Height);
            LBtimap.Clear(clRed32); // mask on red;
            LCanvas.Handle := LBtimap.Handle;
            TFGraphic(Graphic).Draw(LCanvas, Rect(0, 0, Width, FHeight));

            DstP := @FBits[0];
            SrcP := @LBtimap.FBits[0];
            for I := 0 to FWidth * FHeight - 1 do
            begin
              DstColor := DstP^ and $00FFFFFF;
              // this checks for transparency by comparing the pixel-color of the
              // temporary bitmap (red masked) with the pixel of our
              // bitmap (white masked). If they match, make that pixel opaque
              if DstColor = (SrcP^ and $00FFFFFF) then
                DstP^ := DstColor or $FF000000
              else
              // if the colors don't match (that is the case if there is a
              // match "is clRed32 = clBlue32 ?"), just make that pixel
              // transparent:
                DstP^ := DstColor;

               Inc(SrcP); inc(DstP);
            end;
          finally
            LBtimap.Free;
            LCanvas.Free;
          end;
        end
        else
        begin
          // anything else...
          SetSize(TPicture(ASource).Graphic.Width, TPicture(ASource).Graphic.Height);
          if Empty() then Exit;
          LCanvas := TCanvas.Create;
          try
            LCanvas.Handle := Self.Handle;
            TFGraphic(Graphic).Draw(LCanvas, Rect(0, 0, Width, FHeight));
//            ResetAlpha;
          finally
            LCanvas.Free;
          end;
        end;
      end;
    end
//    else if ASource is TClipboard then
//    begin
//      LPicture := TPicture.Create;
//      try
//        LPicture.Assign(TClipboard(ASource));
//        SetSize(LPicture.Width, LPicture.FHeight);
//        if Empty() then Exit;
//        LCanvas := TCanvas.Create;
//        try
//          LCanvas.Handle := Self.Handle;
//          TFGraphic(LPicture.Graphic).Draw(LCanvas, Rect(0, 0, Width, FHeight));
//          ResetAlpha;
//        finally
//          LCanvas.Free;
//        end;
//      finally
//        LPicture.Free;
//      end;
//    end
    else
      inherited; // default handler
  finally;
    Self.EndUpdate();
    Self.Changed();
  end;
end;



procedure TUdBitmap.DoHandleChanged();
begin
  if FCanvas <> nil then FCanvas.Handle := Self.Handle;
  if Assigned(FOnHandleChanged) then FOnHandleChanged(Self);
end;

procedure TUdBitmap.ChangeSize(var AWidth, AHeight: Integer; ANewWidth, ANewHeight: Integer);
begin
  try
    Self.DeleteCanvas(); // Patch by Thomas Bauer.....

    if FHDC <> 0 then DeleteDC(FHDC);
    FHDC := 0;
    if FBitmapHandle <> 0 then DeleteObject(FBitmapHandle);
    FBitmapHandle := 0;

    FBits := nil;
    AWidth := 0;
    AHeight := 0;
    if (ANewWidth > 0) and (ANewHeight > 0) then
    begin
      with FBitmapInfo.bmiHeader do
      begin
        biWidth := ANewWidth;
        biHeight := -ANewHeight;
      end;
      FBitmapHandle := CreateDIBSection(0, FBitmapInfo, DIB_RGB_COLORS, Pointer(FBits), 0, 0);

      if FBits = nil then raise Exception.Create('Can''t allocate the DIB handle');

      FHDC := CreateCompatibleDC(0);
      if FHDC = 0 then
      begin
        DeleteObject(FBitmapHandle);
        FBitmapHandle := 0;
        FBits := nil;
        raise Exception.Create('Can''t create compatible DC');
      end;

      if SelectObject(FHDC, FBitmapHandle) = 0 then
      begin
        DeleteDC(FHDC);
        DeleteObject(FBitmapHandle);
        FHDC := 0;
        FBitmapHandle := 0;
        FBits := nil;
        raise Exception.Create('Can''t select an object into DC');
      end;
    end;

    AWidth  := ANewWidth;
    AHeight := ANewHeight;

    Self.ResetClipRect();

  finally
    Self.DoHandleChanged();
  end;
end;

function TUdBitmap.SetSize(ANewWidth, ANewHeight: Integer): Boolean;
begin
  if ANewWidth < 0 then ANewWidth := 0;
  if ANewHeight < 0 then ANewHeight := 0;

  Result := (ANewWidth <> FWidth) or (ANewHeight <> FHeight);

  if Result then
  begin
    Self.ChangeSize(FWidth, FHeight, ANewWidth, ANewHeight);
    Self.Changed();
    if Assigned(FOnResize) then FOnResize(Self);
  end;
end;

procedure TUdBitmap.SetWidth(const AValue: Integer);
begin
  Self.SetSize(AValue, FHeight);
end;

procedure TUdBitmap.SetHeight(const AValue: Integer);
begin
  Self.SetSize(FWidth, AValue);
end;

procedure TUdBitmap.SetStipples(const AValue: TIntegerDynArray);

  function _Sign(const AInt: Integer): Byte;
  begin
    if AInt < 0 then Result := 0 else Result := 1;
  end;

  function _StippleBitsLen(AInts: TIntegerDynArray): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to Length(AInts) - 1 do
    begin
      if AInts[I] = 0 then Inc(Result) else Inc(Result, Abs(AInts[I]));
    end;
  end;

var
  I, J: Integer;
  L, N: Integer;
  LLastSgn: Byte;
  LCurrSgn: Byte;
  LStipples: TIntegerDynArray;
begin
  if Length(AValue) <= 1 then
  begin
    FStippleBits := nil;
    Exit; //======>>>>>>>
  end;

  SetLength(LStipples, 1);
  LStipples[0] := AValue[0];

  L := 1;
  LLastSgn := _Sign(AValue[0]);

  for I := 1 to Length(AValue) - 1 do
  begin
    LCurrSgn := _Sign(AValue[I]);

    if LCurrSgn = LLastSgn then
    begin
      LStipples[L-1] := LStipples[L-1] + AValue[I];
    end
    else begin
      Inc(L);
      SetLength(LStipples, L);
      LStipples[L-1] := AValue[I];
    end;

    LLastSgn := LCurrSgn;
  end;

  if Length(LStipples) <= 1 then
  begin
    FStippleBits := nil;
  end
  else begin
    L := _StippleBitsLen(LStipples);
    SetLength(FStippleBits, L);

    N := 0;
    for I := 0 to Length(LStipples) - 1 do
    begin
      if LStipples[I] = 0 then
      begin
        FStippleBits[N] := 1;
        Inc(N);
      end
      else begin
        LCurrSgn := _Sign(LStipples[I]);

        for J := 0 to Abs(LStipples[I]) - 1 do
          FStippleBits[N+J] := LCurrSgn;

        Inc(N, Abs(LStipples[I]));
      end;
    end;
  end;
end;



//------------------------------------------------------------------------------


type
  PJump = ^TJump;
  TJump = packed record
    OpCode: Byte;
    Distance: Pointer;
  end;

procedure FastcodeAddressPatch(const ASource, ADestination: Pointer);
const
  Size = SizeOf(TJump);
var
  NewJump: PJump;
  OldProtect: Cardinal;
begin
  if VirtualProtect(ASource, Size, PAGE_EXECUTE_READWRITE, OldProtect) then
  begin
    NewJump := PJump(ASource);
    NewJump.OpCode := $E9;
    NewJump.Distance := Pointer(Integer(ADestination) - Integer(ASource) - 5);

    FlushInstructionCache(GetCurrentProcess, ASource, SizeOf(TJump));
    VirtualProtect(ASource, Size, OldProtect, @OldProtect);
  end;
end;



procedure TUdBitmap.CanvasMoveTo(X, Y: Integer);
begin

end;

procedure TUdBitmap.CanvasLineTo(X, Y: Integer);
begin

end;

procedure TUdBitmap.OnCanvasChanged(Sender: TObject);
begin
  Self.Changed();
end;

function TUdBitmap.GetCanvas: TCanvas;
begin
  if FCanvas = nil then
  begin
    FCanvas := TUdCanvas32.Create;
    TUdCanvas32(FCanvas).FOwnerBmp := Self;
    FCanvas.Handle := Self.Handle;
    FCanvas.OnChange := OnCanvasChanged;
  end;
  Result := FCanvas;
end;

procedure TUdBitmap.DeleteCanvas();
begin
  if FCanvas <> nil then
  begin
    FCanvas.Handle := 0;
    FCanvas.Free;
    FCanvas := nil;
  end;
end;





//------------------------------------------------------------------------------

function TUdBitmap.GetPixel(X, Y: Integer): TColor32;
begin
  Result := FBits[X + Y * FWidth];
end;

function TUdBitmap.GetPixelS(X, Y: Integer): TColor32;
begin
  if (X >= FClipRect.Left) and (X < FClipRect.Right) and
     (Y >= FClipRect.Top) and (Y < FClipRect.Bottom) then
    Result := FBits[X + Y * FWidth]
  else
    Result := FOuterColor;
end;

procedure TUdBitmap.SetPixel(X, Y: Integer; AValue: TColor32);
begin
  FBits[X + Y * FWidth] := AValue;
end;

procedure TUdBitmap.SetPixelS(X, Y: Integer; AValue: TColor32);
begin
  if (X >= FClipRect.Left) and (X < FClipRect.Right) and
     (Y >= FClipRect.Top) and (Y < FClipRect.Bottom) then
    FBits[X + Y * FWidth] := AValue;
end;




//------------------------------------------------------------------------------

function TUdBitmap.GetScanLine(Y: Integer): PColor32StaticArray;
begin
  Result := @FBits[Y * FWidth];
end;

function TUdBitmap.GetPixelPtr(X, Y: Integer): PColor32;
begin
  Result := nil;
  if (X >= FClipRect.Left) and (X < FClipRect.Right) and
     (Y >= FClipRect.Top) and (Y < FClipRect.Bottom) then
    Result := @FBits[X + Y * Width];
end;



procedure TUdBitmap.SetClipRect(const AValue: TRect);
const
  ZERO_RECT: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);

  function _IntersectRect(out Dst: TRect; const R1, R2: TRect): Boolean;
  begin
    if R1.Left >= R2.Left     then Dst.Left := R1.Left     else Dst.Left := R2.Left;
    if R1.Right <= R2.Right   then Dst.Right := R1.Right   else Dst.Right := R2.Right;
    if R1.Top >= R2.Top       then Dst.Top := R1.Top       else Dst.Top := R2.Top;
    if R1.Bottom <= R2.Bottom then Dst.Bottom := R1.Bottom else Dst.Bottom := R2.Bottom;
    Result := (Dst.Right >= Dst.Left) and (Dst.Bottom >= Dst.Top);
    if not Result then Dst := ZERO_RECT;
  end;

begin
  _IntersectRect(FClipRect, AValue, BoundsRect);
  FClipping := not EqualRect(FClipRect, BoundsRect);
end;

procedure TUdBitmap.ResetClipRect;
begin
  FClipRect.Left := 0;
  FClipRect.Top := 0;
  FClipRect.Right := FWidth;
  FClipRect.Bottom := FHeight;

  FClipping := not EqualRect(FClipRect, BoundsRect);
end;




//------------------------------------------------------------------------------

function TUdBitmap.Empty(): Boolean;
begin
  Result := (FBitmapHandle = 0) or (FWidth = 0) or (FHeight = 0);
end;

procedure TUdBitmap.Clear();
begin
  Self.Clear(clBlack32);
end;

procedure TUdBitmap.Clear(FillColor: TColor32);
begin
  if Self.Empty() then Exit;

  if Self.Clipping then
    FFillRect(FClipRect.Left, FClipRect.Top, FClipRect.Right, FClipRect.Bottom, FillColor)
  else
    FillLongword(FBits[0], FWidth * FHeight, FillColor);

  Self.Changed();
end;




//--------------------------------------------------------------------------------------------
(*
procedure TUdBitmap.ResetAlpha;
begin
  Self.ResetAlpha($FF);
end;

procedure TUdBitmap.ResetAlpha(const AlphaValue: Byte);
var
  I: Integer;
  P: PByte;
  NH, NL: Integer;
begin
  P := Pointer(FBits);
  Inc(P, 3); // shift the pointer to 'alpha' component of the first pixel

  { Enroll the loop 4 times }
  I := Width * FHeight;
  NH := I shr 2;
  NL := I and $3;
  for I := 0 to NH - 1 do
  begin
    P^ := AlphaValue; Inc(P, 4);
    P^ := AlphaValue; Inc(P, 4);
    P^ := AlphaValue; Inc(P, 4);
    P^ := AlphaValue; Inc(P, 4);
  end;
  for I := 0 to NL - 1 do
  begin
    P^ := AlphaValue; Inc(P, 4);
  end;
  Self.Changed();
end;
*)



//--------------------------------------------------------------------------------------------

procedure TUdBitmap.Draw(const ADstRect, ASrcRect: TRect; hSrc: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF});
begin
  if Self.Empty() then Exit;
  StretchBlt(Handle, ADstRect.Left, ADstRect.Top, ADstRect.Right - ADstRect.Left, ADstRect.Bottom - ADstRect.Top,
             hSrc,   ASrcRect.Left, ASrcRect.Top, ASrcRect.Right - ASrcRect.Left, ASrcRect.Bottom - ASrcRect.Top,
             SRCCOPY);
  Self.Changed();
end;


procedure TUdBitmap.HorzLine(X1, Y, X2: Integer; const AValue: TColor32);
begin
  if (Y >= FClipRect.Top) and (Y < FClipRect.Bottom) and TestClip(X1, X2, FClipRect.Left, FClipRect.Right) then
  begin
    FillLongword(FBits[X1 + Y * FWidth], X2 - X1 + 1, AValue);
  end;
end;

procedure TUdBitmap.VertLine(X, Y1, Y2: Integer; const AValue: TColor32);
var
  I: Integer;
  P: PColor32;
  NH, NL: Integer;
begin
  if (X >= FClipRect.Left) and (X < FClipRect.Right) and TestClip(Y1, Y2, FClipRect.Top, FClipRect.Bottom) then
  begin
    if Y2 < Y1 then Exit; //=========>>>>

    P := GetPixelPtr(X, Y1);
    if P = nil then Exit;  //=======>>>>>>

    I := Y2 - Y1 + 1;

    NH := I shr 2;
    NL := I and $03;

    for I := 0 to NH - 1 do
    begin
      P^ := AValue; Inc(P, Width);
      P^ := AValue; Inc(P, Width);
      P^ := AValue; Inc(P, Width);
      P^ := AValue; Inc(P, Width);
    end;

    for I := 0 to NL - 1 do
    begin
      P^ := AValue;
      Inc(P, Width);
    end;
  end;
end;




//--------------------------------------------------------------------------------------------
(*
procedure TUdBitmap.Line(X1, Y1, X2, Y2: Integer; const AValue: TColor32; L: Boolean = False);
var
  I: Integer;
  P: PColor32;
  N, M: Integer;
  Delta: Integer;
  HasStps: Boolean;
  Dy, Dx, Sy, Sx: Integer;
begin
  HasStps := Length(FStipples) > 1;

  Dx := X2 - X1;
  Dy := Y2 - Y1;

  if not HasStps then
  begin
    // check for trivial cases...
    if Dx = 0 then // vertical line?
    begin
      if Dy > 0 then VertLineS(X1, Y1, Y2 - 1, AValue)
      else if Dy < 0 then VertLineS(X1, Y2 + 1, Y1, AValue);
      if L then PixelS[X2, Y2] := AValue;
      Changed;
      Exit; //======>>>>>
    end
    else if Dy = 0 then // horizontal line?
    begin
      if Dx > 0 then HorzLineS(X1, Y1, X2 - 1, AValue)
      else if Dx < 0 then HorzLineS(X2 + 1, Y1, X1, AValue);
      if L then PixelS[X2, Y2] := AValue;
      Changed;
      Exit; //======>>>>>
    end;
  end;


  Sx := 1;
  Sy := 1;

  if Dx < 0 then
  begin
    Dx := -Dx;
    Sx := -1;
  end;

  if Dy < 0 then
  begin
    Dy := -Dy;
    Sy := -1;
  end;

  N := 0;
  M := Length(FStippleBits);

  P := Self.GetPixelPtr(X1, Y1);
  Sy := Sy * FWidth;

  if Dx > Dy then
  begin
    Delta := Dx shr 1;
    for I := 0 to Dx - 1 do
    begin
      if HasStps then
      begin
        if N >= M then N := 0;
        if FStippleBits[N] = 1 then P^ := AValue else P^ := 0;
      end
      else
        P^ := AValue;

      Inc(P, Sx);
      Inc(Delta, Dy);
      if Delta >= Dx then
      begin
        Inc(P, Sy);
        Dec(Delta, Dx);
      end;

      Inc(N);
    end;
  end
  else begin  // Dx < Dy
    Delta := Dy shr 1;
    for I := 0 to Dy - 1 do
    begin
      if HasStps then
      begin
        if N >= M then N := 0;
        if FStippleBits[N] = 1 then P^ := AValue else P^ := 0;
      end
      else
        P^ := AValue;

      Inc(P, Sy);
      Inc(Delta, Dx);
      if Delta >= Dy then
      begin
        Inc(P, Sx);
        Dec(Delta, Dy);
      end;

      Inc(N);
    end;
  end;

  if L then P^ := AValue;

  Self.Changed();
end;
*)

procedure TUdBitmap.Line(X1, Y1, X2, Y2: Integer; const AValue: TColor32; L: Boolean = False);
var
  P: PColor32;
  OC: Int64;
  N, M: Integer; //I, J, 
  Fct: Extended;
  Swapped, CheckAux, HasStps: Boolean;  //Stipples
  Pw, Sx, Sy, Xd, Yd, Rem, Term, Ed: Integer;
  Dx, Dy, Dx2, Dy2, Cx1, Cx2, Cy1, Cy2: Integer;
begin
  Dx := X2 - X1;
  Dy := Y2 - Y1;

  M := Length(FStippleBits);
  HasStps := (Length(FStippleBits) > 1); //  and ((Abs(Dx) > 1) or (Abs(Dy) > 1))

  if HasStps then
  begin
    if (Dx = 0) then
    begin
      if Abs(Dy) < 2 then
      begin
        if FStipplePos = 0 then
        begin
          if FStippleBits[FStipplePos] = 1 then
            Self.SetPixelS(X1, Y1, AValue)
          else
            Self.SetPixelS(X1, Y1, 0);

          Inc(FStipplePos);
        end;

        if Dy <> 0 then
        begin
          if FStipplePos >= M then FStipplePos := 0;

          if FStippleBits[FStipplePos] = 1 then
            Self.SetPixelS(X2, Y2, AValue)
          else
            Self.SetPixelS(X2, Y2, 0);

          Inc(FStipplePos);
        end;

        Self.Changed();
        Exit; //======>>>>>
      end;
    end
    else if (Dy = 0) then
    begin
      if Abs(Dx) < 2 then
      begin
        if FStipplePos = 0 then
        begin
          if FStippleBits[FStipplePos] = 1 then
            Self.SetPixelS(X1, Y1, AValue)
          else
            Self.SetPixelS(X1, Y1, 0);

          Inc(FStipplePos);
        end;

        if Dx <> 0 then
        begin
          if FStipplePos >= M then FStipplePos := 0;

          if FStippleBits[FStipplePos] = 1 then
            Self.SetPixelS(X2, Y2, AValue)
          else
            Self.SetPixelS(X2, Y2, 0);

          Inc(FStipplePos);
        end;

        Self.Changed();
        Exit; //======>>>>>
      end;
    end;
  end
  else begin
    // check for trivial cases...
    if (Dx = 0) then // vertical line?
    begin
      if Dy > 0 then Self.VertLine(X1, Y1, Y2 - 1, AValue)
      else if Dy < 0 then Self.VertLine(X1, Y2 + 1, Y1, AValue);
      if L then Self.SetPixelS(X2, Y2, AValue);
      Self.Changed();
      Exit; //======>>>>>
    end
    else if (Dy = 0) then // horizontal line?
    begin
      if Dx > 0 then Self.HorzLine(X1, Y1, X2 - 1, AValue)
      else if Dx < 0 then Self.HorzLine(X2 + 1, Y1, X1, AValue);
      if L then Self.SetPixelS(X2, Y2, AValue);
      Self.Changed();
      Exit; //======>>>>>
    end;
  end;

  Cx1 := FClipRect.Left;
  Cx2 := FClipRect.Right  - 1;
  Cy1 := FClipRect.Top;
  Cy2 := FClipRect.Bottom - 1;


  Sx := 1;
  Sy := 1;

  if Abs(Dx) > Abs(Dy) then
  begin
    if Dx > 0 then
    begin
      If (X1 > Cx2) or (X2 < Cx1) then Exit; //======>>>>> segment not visible
    end
    else
    begin
      If (X2 > Cx2) or (X1 < Cx1) then Exit; //======>>>>> segment not visible

      Swap(X1, X2);
      Swap(Y1, Y2);
      Dx := X2 - X1;
      Dy := Y2 - Y1;
    end;


    Fct := Dy / Dx;

    if (X1 < Cx1) then
    begin
      Y1 := Y1 + Trunc((Cx1 - X1) * Fct);
      X1 := Cx1;
    end;

    if (X2 > Cx2) then
    begin
      Y2 := Y2 - Trunc((X2 - CX2) * Fct);
      X2 := Cx2;
    end;

    Dx := X2 - X1;
    Dy := Y2 - Y1;

    if Dy > 0 then
    begin
      If (Y1 > Cy2) or (Y2 < Cy1) then Exit; //======>>>>> segment not visible
    end
    else
    begin
      If (Y2 > Cy2) or (Y1 < Cy1) then Exit; //======>>>>> segment not visible
      Sy := -1;
      Y1 := -Y1;   Y2 := -Y2;   Dy := -Dy;
      Cy1 := -Cy1; Cy2 := -Cy2;
      Swap(Cy1, Cy2);
    end;

  end
  else begin
    if Dy > 0 then
    begin
      If (Y1 > Cy2) or (Y2 < Cy1) then Exit; //======>>>>> segment not visible
    end
    else
    begin
      If (Y2 > Cy2) or (Y1 < Cy1) then Exit; //======>>>>> segment not visible

      Swap(X1, X2);
      Swap(Y1, Y2);
      Dx := X2 - X1;
      Dy := Y2 - Y1;
    end;


    Fct := Dx / Dy;

    if (Y1 < Cy1) then
    begin
      X1 := X1 + Trunc((Cy1 - Y1) * Fct);
      Y1 := Cy1;
    end;

    if (Y2 > Cy2) then
    begin
      X2 := X2 - Trunc((Y2 - CY2) * Fct);
      Y2 := Cy2;
    end;

    Dy := Y2 - Y1;
    Dx := X2 - X1;

    if Dx > 0 then
    begin
      If (X1 > Cx2) or (X2 < Cx1) then Exit; //======>>>>> segment not visible
    end
    else
    begin
      If (X2 > Cx2) or (X1 < Cx1) then Exit; //======>>>>> segment not visible
      Sx := -1;
      X1 := -X1;   X2 := -X2;   Dx := -Dx;
      Cx1 := -Cx1; Cx2 := -Cx2;
      Swap(Cx1, Cx2);
    end;
  end;


  if Dx < Dy then
  begin
    Swapped := True;
    Swap(X1, Y1); Swap(X2, Y2); Swap(Dx, Dy);
    Swap(Cx1, Cy1); Swap(Cx2, Cy2); Swap(Sx, Sy);
  end
  else
    Swapped := False;

  // Bresenham's set up:
  Dx2 := Dx shl 1;
  Dy2 := Dy shl 1;
  Xd := X1; Yd := Y1; Ed := Dy2 - Dx; Term := X2;
  CheckAux := True;

  // clipping rect horizontal entry
  if Y1 < Cy1 then
  begin
    OC := Int64(Dx2) * (Cy1 - Y1) - Dx;
    Inc(Xd, OC div Dy2);
    Rem := OC mod Dy2;

    if Xd > Cx2 then Exit; //======>>>>>

    if Xd >= Cx1 then
    begin
      Yd := Cy1;
      Dec(Ed, Rem + Dx);
      if Rem > 0 then
      begin
        Inc(Xd);
        Inc(Ed, Dy2);
      end;
      CheckAux := False; // to avoid ugly labels we set this to omit the next check
    end;
  end;

  // clipping rect vertical entry
  if CheckAux and (X1 < Cx1) then
  begin
    OC := Int64(Dy2) * (Cx1 - X1);
    Inc(Yd, OC div Dx2);
    Rem := OC mod Dx2;

    if (Yd > Cy2) or (Yd = Cy2) and (Rem >= Dx) then Exit; //======>>>>>

    Xd := Cx1;
    Inc(Ed, Rem);
    if (Rem >= Dx) then
    begin
      Inc(Yd);
      Dec(Ed, Dx2);
    end;
  end;

  // set auxiliary var to indicate that temp is not clipped, since
  // temp still has the unclipped value assigned at setup.
  CheckAux := False;

  // is the segment exiting the clipping rect?
  if Y2 > Cy2 then
  begin
    OC := Dx2 * (Cy2 - Y1) + Dx;
    Term := X1 + OC div Dy2;
    Rem := OC mod Dy2;
    if Rem = 0 then Dec(Term);
    CheckAux := True; // set auxiliary var to indicate that temp is clipped
  end;

  if Term > Cx2 then
  begin
    Term := Cx2;
    CheckAux := True; // set auxiliary var to indicate that temp is clipped
  end;

  Inc(Term);

  if Sy = -1 then
    Yd := -Yd;

  if Sx = -1 then
  begin
    Xd := -Xd;
    Term := -Term;
  end;

  Dec(Dx2, Dy2);

  if Swapped then
  begin
    Pw := Sx * FWidth;
    P := @FBits[Yd + Xd * FWidth];
  end
  else
  begin
    Pw := Sx;
    Sy := Sy * FWidth;
    P := @FBits[Xd + Yd * FWidth];
  end;

  // do we need to skip the last pixel of the line and is temp not clipped?
  if not(L or CheckAux) then
  begin
    if Xd < Term then
      Dec(Term)
    else
      Inc(Term);
  end;

  N := FStipplePos;
  M := Length(FStippleBits);
  if N >= M then N := 0;

  if FStipplePos <> 0 then Inc(Xd, Sx);

  while Xd <> Term do
  begin
    Inc(Xd, Sx);

    if HasStps then
    begin
      if N >= M then N := 0;
      if FStippleBits[N] = 1 then P^ := AValue else P^ := 0;
    end
    else
      P^ := AValue;

    Inc(P, Pw);
    if Ed >= 0 then
    begin
      Inc(P, Sy);
      Dec(Ed, Dx2);
    end
    else
      Inc(Ed, Dy2);

    Inc(N);
  end;

  FStipplePos := N;
  Self.Changed();
end;



//--------------------------------------------------------------------------------------------

procedure TUdBitmap.FFillRect(const X1, Y1, X2, Y2: Integer; const AValue: TColor32);
var
  J: Integer;
  P: PColor32StaticArray;
begin
  for J := Y1 to Y2 - 1 do
  begin
    P := Pointer(GetScanLine(J));
    FillLongword(P[X1], X2 - X1, AValue);
  end;
  Self.Changed();
end;

procedure TUdBitmap.FillRect(X1, Y1, X2, Y2: Integer; const AValue: TColor32);
begin
  if (X2 > X1) and (Y2 > Y1) and
     (X1 < FClipRect.Right) and (Y1 < FClipRect.Bottom) and
     (X2 > FClipRect.Left) and (Y2 > FClipRect.Top) then
  begin
    if X1 < FClipRect.Left   then X1 := FClipRect.Left;
    if Y1 < FClipRect.Top    then Y1 := FClipRect.Top;
    if X2 > FClipRect.Right  then X2 := FClipRect.Right;
    if Y2 > FClipRect.Bottom then Y2 := FClipRect.Bottom;

    Self.FFillRect(X1, Y1, X2, Y2, AValue);
  end;
end;




//--------------------------------------------------------------------------------------------

procedure TUdBitmap.FrameRect(X1, Y1, X2, Y2: Integer; const AValue: TColor32);
begin
  if (X2 > X1) and (Y2 > Y1) and
     (X1 < FClipRect.Right) and (Y1 < FClipRect.Bottom) and
     (X2 > FClipRect.Left)  and (Y2 > FClipRect.Top) then
  begin
    Dec(Y2);
    Dec(X2);
    Self.HorzLine(X1, Y1, X2, AValue);

    if Y2 > Y1 then Self.HorzLine(X1, Y2, X2, AValue);
    if Y2 > Y1 + 1 then
    begin
      Self.VertLine(X1, Y1 + 1, Y2 - 1, AValue);
      if X2 > X1 then Self.VertLine(X2, Y1 + 1, Y2 - 1, AValue);
    end;

    Self.Changed();
  end;
end;

procedure TUdBitmap.FrameRect(const ARect: TRect; const AValue: TColor32);
begin
  with ARect do Self.FrameRect(Left, Top, Right, Bottom, AValue);
end;






//--------------------------------------------------------------------------------------------

function TUdBitmap.CanvasAllocated: Boolean;
begin
  Result := FCanvas <> nil;
end;

function TUdBitmap.BoundsRect: TRect;
begin
  Result.Left  := 0;
  Result.Top   := 0;
  Result.Right := FWidth;
  Result.Bottom:= FHeight;
end;




//==================================================================================================


procedure SetupPenStyles();

  procedure _AssignBits(var ADst: TByteDynArray; ASrc: array of Byte);
  var
    I: Integer;
  begin
    SetLength(ADst, Length(ASrc));
    for I := 0 to Length(ASrc) - 1 do ADst[I] := ASrc[I];
  end;

begin
  _AssignBits(DASH_STYLE,       [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0]);
  _AssignBits(DOT_STYLE,        [1, 1, 1, 0, 0, 0]);
  _AssignBits(DASHDOT_STYLE,    [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0]);
  _AssignBits(DASHDOTDOT_STYLE, [1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0]);
end;

initialization
  SetupPenStyles();

finalization



end.