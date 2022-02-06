{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdPrinters;

{$I UdDefs.inc}

interface

uses
  Windows, Classes, Graphics, Forms, Types;

type
  TUdCustomPrinter = class;
  TUdPrinterOrientation = (poPortrait, poLandscape);

  TUdBinNum   = SmallInt;
  TUdPageSize = SmallInt;


  //*** TUdPrinterCanvas ***//
  TUdPrinterCanvas = class(TCanvas)
  private
    FPrinter: TUdCustomPrinter;
    procedure UpdateFont;
  public
    procedure Changing; override;
  end;


  //*** TUdCustomPrinter ***//
  TUdCustomPrinter = class(TObject)
  private
    FName     : string;
    FTitle    : string;
    FFileName : string;

    FDPI   : TPoint;
    FPort  : string;
    FHandle: THandle;
    FCanvas: TUdPrinterCanvas;

    FBins: TStrings;
    FPapers: TStrings;

    FBin        : TUdBinNum;
    FDuplex     : Integer;
    FPaperSize  : TUdPageSize;
    FPaperHeight: Double;
    FPaperWidth : Double;

    FDefBin        : TUdBinNum;
    FDefDuplex     : Integer;
    FDefPaperSize  : TUdPageSize;
    FDefPaperHeight: Double;
    FDefPaperWidth : Double;
    FDefOrientation: TUdPrinterOrientation;

    FLeftMargin  : Double;
    FTopMargin   : Double;
    FRightMargin : Double;
    FBottomMargin: Double;
    FOrientation : TUdPrinterOrientation;

    FPrinting   : Boolean;
    FInitialized: Boolean;

  public
    constructor Create(const AName, APort: string); virtual;
    destructor Destroy; override;

    procedure Init(); virtual;
    procedure Abort(); virtual;
    procedure BeginDoc(); virtual;
    procedure BeginPage(); virtual;
    procedure BeginRAWDoc(); virtual;
    procedure EndDoc(); virtual;
    procedure EndPage(); virtual;
    procedure EndRAWDoc(); virtual;
    procedure WriteRAWDoc(const ABuf: AnsiString); virtual;

    function BinNumIndex(ABinNum: TUdBinNum): Integer;
    function PaperSizeIndex(APaperSize: TUdPageSize): Integer;

    function GetBinNum(ABinName: string): TUdBinNum;
    function GetPaperSize(APaperName: string): TUdPageSize;

    procedure SetViewParams(APaperSize: TUdPageSize; APaperWidth, APaperHeight: Double;
                            AOrientation: TUdPrinterOrientation); virtual;
    procedure SetPrintParams(APaperSize: TUdPageSize; APaperWidth, APaperHeight: Double;
                             AOrientation: TUdPrinterOrientation; ABin: TUdBinNum; ADuplex, ACopies: Integer); virtual;
    procedure PropertiesDlg; virtual;

  public
    property Name: string read FName;
    property Title: string read FTitle write FTitle;
    property FileName: string read FFileName write FFileName;

    property DPI: TPoint read FDPI;
    property Port: string read FPort;
    property Handle: THandle read FHandle;
    property Canvas: TUdPrinterCanvas read FCanvas;


    property Bins: TStrings read FBins;
    property Papers: TStrings read FPapers;

    property Bin   : TUdBinNum read FBin;
    property Duplex: Integer   read FDuplex;
    property PaperSize  : TUdPageSize read FPaperSize;
    property PaperHeight: Double    read FPaperHeight;
    property PaperWidth : Double    read FPaperWidth;


    property DefBin   : TUdBinNum read FDefBin;
    property DefDuplex: Integer   read FDefDuplex;
    property DefPaperSize  : TUdPageSize read FDefPaperSize;
    property DefPaperHeight: Double    read FDefPaperHeight;
    property DefPaperWidth : Double    read FDefPaperWidth;
    property DefOrientation: TUdPrinterOrientation read FDefOrientation;

    property LeftMargin: Double read FLeftMargin;
    property TopMargin: Double read FTopMargin;
    property RightMargin: Double read FRightMargin;
    property BottomMargin: Double read FBottomMargin;
    property Orientation: TUdPrinterOrientation read FOrientation;

    property Initialized: Boolean read FInitialized;
  end;



  TUdPrinter = class(TUdCustomPrinter)
  private
    FDC: HDC;
    FMode: PDeviceMode;
    FDeviceMode: THandle;
    FDriver: string;

  protected
    procedure GetDC;
    procedure CreateDevMode;
    procedure FreeDevMode;

  public
    constructor Create(const AName, APort: string); override;
    destructor Destroy(); override;

    procedure Init(); override;
    procedure RecreateDC();
    procedure Abort(); override;
    procedure BeginDoc(); override;
    procedure BeginPage(); override;
    procedure BeginRAWDoc(); override;
    procedure EndDoc(); override;
    procedure EndPage(); override;
    procedure EndRAWDoc(); override;
    procedure WriteRAWDoc(const ABuf: AnsiString); override;

    procedure SetViewParams(APaperSize: TUdPageSize; APaperWidth, APaperHeight: Double;
                            AOrientation: TUdPrinterOrientation); override;
    procedure SetPrintParams(APaperSize: TUdPageSize; APaperWidth, APaperHeight: Double;
                             AOrientation: TUdPrinterOrientation; ABin: TUdBinNum; ADuplex, ACopies: Integer); override;
    procedure PropertiesDlg(); override;

    function UpdateDeviceCaps(): Boolean;

  public
    property DeviceMode: PDeviceMode read FMode;

  end;


  TUdPrinters = class(TObject)
  private
    FHasPhysicalPrinters: Boolean;
    FPrinters: TStrings;
    FPrinterIndex: Integer;
    FPrinterList: TList;

  protected
    function GetItem(AIndex: Integer): TUdCustomPrinter;
    function GetPrinterCount: Integer;
    function GetDefaultPrinter(): string;
    function GetCurrentPrinter(): TUdCustomPrinter;
    procedure SetPrinterIndex(Value: Integer);

  public
    constructor Create();
    destructor Destroy(); override;

    procedure Clear();
    procedure FillPrinters();

    function IndexOf(AName: string): Integer;

  public
    property Items[Index: Integer]: TUdCustomPrinter read GetItem; default;

    property Printers: TStrings read FPrinters;
    property Printer: TUdCustomPrinter read GetCurrentPrinter;

    property PrinterIndex: Integer read FPrinterIndex write SetPrinterIndex;
    property PrinterCount: Integer read GetPrinterCount;

    property HasPhysicalPrinters: Boolean read FHasPhysicalPrinters;
  end;


function GlobalPrinters: TUdPrinters;

function GetPaperDimensions(APaperName: string; var AWidth, AHeight: Double): Boolean; overload;
function GetPaperDimensions(APaperSize: TUdPageSize; var AWidth, AHeight: Double): Boolean; overload;

function GetDefPaperNames(): TStringDynArray;
function GetDefPaperSize(AIndex: Integer): TUdPageSize;

implementation

uses
  SysUtils, WinSpool;



//==================================================================================================

procedure FSetCommaText(const AText: string; AStrings: TStrings; AComma: Char = ';');

  function _ExtractCommaName(AStr: string; var APos: Integer): string;
  var
    I: Integer;
  begin
    I := APos;
    while (I <= Length(AStr)) and (AStr[I] <> AComma) do Inc(I);
    Result := Copy(AStr, APos, I - APos);
    if (I <= Length(AStr)) and (AStr[I] = AComma) then Inc(I);
    APos := I;
  end;

var
  N: Integer;
begin
  N := 1;
  AStrings.Clear;
  while N <= Length(AText) do
    AStrings.Add(_ExtractCommaName(AText, N));
end;



//==================================================================================================


var
  _GPrinters: TUdPrinters = nil;



type
  TUdPaperInfo = {packed} record
    Size: TUdPageSize;
    Name: string;
    X, Y: Integer;
  end;

const
  PAPER_COUNT = 66;
  PAPERS_INFO: array[0..PAPER_COUNT - 1] of TUdPaperInfo = (
    (Size:1;  Name: 'Letter'         ; X:2159; Y:2794),
    (Size:2;  Name: 'Letter Small'   ; X:2159; Y:2794),
    (Size:3;  Name: 'Tabloid'        ; X:2794; Y:4318),
    (Size:4;  Name: 'Ledger'         ; X:4318; Y:2794),
    (Size:5;  Name: 'Legal'          ; X:2159; Y:3556),
    (Size:6;  Name: 'Statement'      ; X:1397; Y:2159),
    (Size:7;  Name: 'Executive'      ; X:1842; Y:2667),
    (Size:8;  Name: 'A3'             ; X:2970; Y:4200),
    (Size:9;  Name: 'A4'             ; X:2100; Y:2970),
    (Size:10; Name: 'A4 Small'       ; X:2100; Y:2970),
    (Size:11; Name: 'A5'             ; X:1480; Y:2100),
    (Size:12; Name: 'B4 (JIS)'       ; X:2500; Y:3540),
    (Size:13; Name: 'B5 (JIS)'       ; X:1820; Y:2570),
    (Size:14; Name: 'Folio'          ; X:2159; Y:3302),
    (Size:15; Name: 'Quarto'         ; X:2150; Y:2750),
    (Size:16; Name: '10x14'          ; X:2540; Y:3556),
    (Size:17; Name: '11x17'          ; X:2794; Y:4318),
    (Size:18; Name: 'Note'           ; X:2159; Y:2794),
    (Size:19; Name: 'Envelope #9'    ; X:984;  Y:2254),
    (Size:20; Name: 'Envelope #10'   ; X:1048; Y:2413),
    (Size:21; Name: 'Envelope #11'   ; X:1143; Y:2635),
    (Size:22; Name: 'Envelope #12'   ; X:1207; Y:2794),
    (Size:23; Name: 'Envelope #14'   ; X:1270; Y:2921),
    (Size:24; Name: 'C size sheet'   ; X:4318; Y:5588),
    (Size:25; Name: 'D size sheet'   ; X:5588; Y:8636),
    (Size:26; Name: 'E size sheet'   ; X:8636; Y:11176),
    (Size:27; Name: 'Envelope DL'    ; X:1100; Y:2200),
    (Size:28; Name: 'Envelope C5'    ; X:1620; Y:2290),
    (Size:29; Name: 'Envelope C3'    ; X:3240; Y:4580),
    (Size:30; Name: 'Envelope C4'    ; X:2290; Y:3240),
    (Size:31; Name: 'Envelope C6'    ; X:1140; Y:1620),
    (Size:32; Name: 'Envelope C65'   ; X:1140; Y:2290),
    (Size:33; Name: 'Envelope B4'    ; X:2500; Y:3530),
    (Size:34; Name: 'Envelope B5'    ; X:1760; Y:2500),
    (Size:35; Name: 'Envelope B6'    ; X:1760; Y:1250),
    (Size:36; Name: 'Envelope Italy' ; X:1100; Y:2300),
    (Size:37; Name: 'Envelope Monarch'; X:984;  Y:1905),
    (Size:38; Name: '6 3/4 Envelope' ; X:920;  Y:1651),
    (Size:39; Name: 'US Std Fanfold' ; X:3778; Y:2794),
    (Size:40; Name: 'German Std Fanfold'; X:2159; Y:3048),
    (Size:41; Name: 'German Legal Fanfold'; X:2159; Y:3302),
    (Size:42; Name: 'B4 (ISO)'       ; X:2500; Y:3530),
    (Size:43; Name: 'Japanese Postcard'; X:1000; Y:1480),
    (Size:44; Name: '9 x 11'         ; X:2286; Y:2794),
    (Size:45; Name: '10 x 11'        ; X:2540; Y:2794),
    (Size:46; Name: '15 x 11'        ; X:3810; Y:2794),
    (Size:47; Name: 'Envelope Invite'; X:2200; Y:2200),
//  (Size:48; Name: 'RESERVED--DO NOT USE'; X:-1; Y:-1),
//  (Size:49; Name: 'RESERVED--DO NOT USE'; X:-1; Y:-1),
    (Size:50; Name: 'Letter Extra'   ; X:2355; Y:3048),
    (Size:51; Name: 'Legal Extra'    ; X:2355; Y:3810),
    (Size:52; Name: 'Tabloid Extra'  ; X:2969; Y:4572),
    (Size:53; Name: 'A4 Extra'       ; X:2354; Y:3223),
    (Size:54; Name: 'Letter Transverse'; X:2101; Y:2794),
    (Size:55; Name: 'A4 Transverse'  ; X:2100; Y:2970),
    (Size:56; Name: 'Letter Extra Transverse'; X:2355; Y:3048),
    (Size:57; Name: 'SuperASuperAA4' ; X:2270; Y:3560),
    (Size:58; Name: 'SuperBSuperBA3' ; X:3050; Y:4870),
    (Size:59; Name: 'Letter Plus'    ; X:2159; Y:3223),
    (Size:60; Name: 'A4 Plus'        ; X:2100; Y:3300),
    (Size:61; Name: 'A5 Transverse'  ; X:1480; Y:2100),
    (Size:62; Name: 'B5 (JIS) Transverse'; X:1820; Y:2570),
    (Size:63; Name: 'A3 Extra'       ; X:3220; Y:4450),
    (Size:64; Name: 'A5 Extra'       ; X:1740; Y:2350),
    (Size:65; Name: 'B5 (ISO) Extra' ; X:2010; Y:2760),
    (Size:66; Name: 'A2'             ; X:4200; Y:5940),
    (Size:67; Name: 'A3 Transverse'  ; X:2970; Y:4200),
    (Size:68; Name: 'A3 Extra Transverse'; X:3220; Y:4450));




function GetPaperDimensions(APaperName: string; var AWidth, AHeight: Double): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to PAPER_COUNT - 1 do
    if PAPERS_INFO[I].Name = APaperName then
    begin
      AWidth  := PAPERS_INFO[I].X / 10;
      AHeight := PAPERS_INFO[I].Y / 10;
      Result := True;
      Break;
    end;
end;

function GetPaperDimensions(APaperSize: TUdPageSize; var AWidth, AHeight: Double): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to PAPER_COUNT - 1 do
    if PAPERS_INFO[I].Size = APaperSize then
    begin
      AWidth  := PAPERS_INFO[I].X / 10;
      AHeight := PAPERS_INFO[I].Y / 10;
      Result := True;
      Break;
    end;
end;


function GetDefPaperNames(): TStringDynArray;
var
  I: Integer;
begin
  SetLength(Result, PAPER_COUNT);
  for I := 0 to PAPER_COUNT - 1 do Result[I] := PAPERS_INFO[I].Name;
end;

function GetDefPaperSize(AIndex: Integer): TUdPageSize;
begin
  Result := -1;
  if (AIndex >= 0) and (AIndex < PAPER_COUNT) then
    Result := PAPERS_INFO[AIndex].Size;
end;



//==================================================================================================
{ TUdPrinterCanvas }

procedure TUdPrinterCanvas.Changing;
begin
  inherited;
  UpdateFont;
end;

procedure TUdPrinterCanvas.UpdateFont;
var
  FontSize: Integer;
begin
  if FPrinter.DPI.Y <> Font.PixelsPerInch then
  begin
    FontSize := Font.Size;
    Font.PixelsPerInch := FPrinter.DPI.Y;
    Font.Size := FontSize;
  end;
end;





//==================================================================================================
{ TUdCustomPrinter }

constructor TUdCustomPrinter.Create(const AName, APort: string);
begin
  FName     := AName;
  FTitle    := '';
  FFileName := '';

  FBins := TStringList.Create;
  FBins.AddObject('Default', Pointer(DMBIN_AUTO));

  FPapers := TStringList.Create;
  FPapers.AddObject('Custom', Pointer(256));


  FDPI    := Point(-1, -1);
  FPort   := APort;
  FHandle := 0;
  FCanvas := TUdPrinterCanvas.Create;
  FCanvas.FPrinter := Self;

  FBin         := -1;
  FDuplex      := -1;
  FPaperSize   := -1;
  FPaperHeight := -1;
  FPaperWidth  := -1;


  FDefBin         := -1;
  FDefDuplex      := -1;
  FDefPaperSize   := -1;
  FDefPaperHeight := -1;
  FDefPaperWidth  := -1;
  FDefOrientation := poPortrait;


  FLeftMargin   := -1;
  FTopMargin    := -1;
  FRightMargin  := -1;
  FBottomMargin := -1;
  FOrientation  := poPortrait;

  FPrinting    := False;
  FInitialized := False;
end;

destructor TUdCustomPrinter.Destroy;
begin
  FBins.Free;
  FPapers.Free;
  FCanvas.Free;
  inherited;
end;


procedure TUdCustomPrinter.Init;
var
  I: Integer;
begin
  if FInitialized then Exit;

  FDPI := Point(600, 600);
  FDefPaperSize := DMPAPER_A4;
  FDefOrientation := poPortrait;
  FDefPaperWidth := 210;
  FDefPaperHeight := 297;

  for I := 0 to PAPER_COUNT - 1 do
    FPapers.AddObject(PAPERS_INFO[I].Name, Pointer(PAPERS_INFO[I].Size));

  FBin    := -1;
  FDuplex := -1;
  FInitialized := True;
end;


//-------------------------------------------------------------------------------

procedure TUdCustomPrinter.Abort();
begin
  //... ....
end;

procedure TUdCustomPrinter.BeginDoc();
begin
  //... ....
end;

procedure TUdCustomPrinter.BeginPage();
begin
  //... ....
end;

procedure TUdCustomPrinter.EndDoc();
begin
  //... ....
end;

procedure TUdCustomPrinter.EndPage();
begin
  //... ....
end;

procedure TUdCustomPrinter.BeginRAWDoc();
begin
  //... ....
end;

procedure TUdCustomPrinter.EndRAWDoc();
begin
  //... ....
end;

procedure TUdCustomPrinter.WriteRAWDoc(const ABuf: AnsiString);
begin
  //... ....
end;




//-------------------------------------------------------------------------------

function TUdCustomPrinter.BinNumIndex(ABinNum: TUdBinNum): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FBins.Count - 1 do
    if TUdBinNum(FBins.Objects[I]) = ABinNum then
    begin
      Result := I;
      Break;
    end;
end;

function TUdCustomPrinter.PaperSizeIndex(APaperSize: TUdPageSize): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FPapers.Count - 1 do
    if Integer(FPapers.Objects[I]) = APaperSize then
    begin
      Result := I;
      Break;
    end;
end;

function TUdCustomPrinter.GetBinNum(ABinName: string): TUdBinNum;
var
  I: Integer;
begin
  I := FBins.IndexOf(ABinName);
  if I = -1 then I := 0;
  Result := TUdBinNum(FBins.Objects[I]);
end;

function TUdCustomPrinter.GetPaperSize(APaperName: string): TUdPageSize;
var
  I: Integer;
begin
  I := FPapers.IndexOf(APaperName);
  if I = -1 then I := 0;
  Result := TUdPageSize(FPapers.Objects[I]);
end;




//-------------------------------------------------------------------------------

procedure TUdCustomPrinter.SetViewParams(APaperSize: TUdPageSize; APaperWidth, APaperHeight: Double;
  AOrientation: TUdPrinterOrientation);
var
  I: Integer;
  LFound: Boolean;
begin
  LFound := False;
  if APaperSize <> 256 then
  begin
    for I := 0 to PAPER_COUNT - 1 do
    begin
      if PAPERS_INFO[I].Size = APaperSize then
      begin
        if AOrientation = poPortrait then
        begin
          APaperWidth  := PAPERS_INFO[I].X / 10;
          APaperHeight := PAPERS_INFO[I].Y / 10;
        end
        else
        begin
          APaperWidth  := PAPERS_INFO[I].Y / 10;
          APaperHeight := PAPERS_INFO[I].X / 10;
        end;
        LFound := True;
        Break;
      end;
    end;
  end;

  if not LFound then
    APaperSize := 256;

  FOrientation  := AOrientation;
  FPaperSize    := APaperSize;
  FPaperWidth   := APaperWidth;
  FPaperHeight  := APaperHeight;
  FLeftMargin   := 5;
  FTopMargin    := 5;
  FRightMargin  := 5;
  FBottomMargin := 5;
end;

procedure TUdCustomPrinter.SetPrintParams(APaperSize: TUdPageSize; APaperWidth, APaperHeight: Double;
  AOrientation: TUdPrinterOrientation; ABin: TUdBinNum; ADuplex, ACopies: Integer);
begin
  SetViewParams(APaperSize, APaperWidth, APaperHeight, AOrientation);
  FBin := ABin;
end;

procedure TUdCustomPrinter.PropertiesDlg;
begin
  //... ....
end;




//==================================================================================================
{ TUdPrinter }

constructor TUdPrinter.Create(const AName, APort: string);
begin
  inherited;
  //... ...
end;

destructor TUdPrinter.Destroy();
begin
  Self.FreeDevMode();
  inherited;
end;



//----------------------------------------------------------------------------------------------

procedure TUdPrinter.GetDC;
begin
  if FDC = 0 then
  begin
    if FPrinting then
      FDC := CreateDC(PChar(FDriver), PChar(FName), nil, FMode) else
      FDC := CreateIC(PChar(FDriver), PChar(FName), nil, FMode);
    FCanvas.Handle := FDC;
    FCanvas.Refresh;
    FCanvas.UpdateFont;
  end;
end;

procedure TUdPrinter.RecreateDC;
begin
  if FDC <> 0 then
    try
      DeleteDC(FDC);
    except
    end;
  FDC := 0;
  Self.GetDC();
end;



procedure TUdPrinter.CreateDevMode;
var
  LBufSize: Integer;
{$IFNDEF D2009UP}
  LDeviceMode: TDeviceMode;
{$ENDIF}
begin
  if WinSpool.OpenPrinter(PChar(FName), FHandle, nil) then
  begin
  {$IFDEF D2009UP}
    LBufSize := WinSpool.DocumentProperties(0, FHandle, PChar(FName), nil, nil, 0);
  {$ELSE}
    LBufSize := WinSpool.DocumentProperties(0, FHandle, PChar(FName), LDeviceMode, LDeviceMode, 0);
  {$ENDIF}
    if LBufSize > 0 then
    begin
      FDeviceMode := GlobalAlloc(GHND, LBufSize);
      if FDeviceMode <> 0 then
      begin
        FMode := GlobalLock(FDeviceMode);
        if WinSpool.DocumentProperties(0, FHandle, PChar(FName), FMode^, FMode^, DM_OUT_BUFFER) < 0 then
        begin
          GlobalUnlock(FDeviceMode);
          GlobalFree(FDeviceMode);

          FMode := nil;
          FDeviceMode := 0;
        end;
      end;
    end;
  end;
end;

procedure TUdPrinter.FreeDevMode;
begin
  FCanvas.Handle := 0;
  if FDC <> 0 then DeleteDC(FDC);
  if FHandle <> 0 then ClosePrinter(FHandle);

  if FDeviceMode <> 0 then
  begin
    GlobalUnlock(FDeviceMode);
    GlobalFree(FDeviceMode);
  end;

  FDC := 0;
  FHandle := 0;
  FDeviceMode := 0;
end;




//----------------------------------------------------------------------------------------------

procedure TUdPrinter.Init;

  procedure _FillPapers();
  var
    I: Integer;
    LPaperSizesCount: Integer;
    LPaperSizes: array[0..255] of Word;
    LPaperNames: PChar;
  begin
    FillChar(LPaperSizes, SizeOf(LPaperSizes), 0);
    LPaperSizesCount := DeviceCapabilities(PChar(FName), PChar(FPort), DC_PAPERS, @LPaperSizes, FMode);
    GetMem(LPaperNames, LPaperSizesCount * 64 * SizeOf(Char));
    DeviceCapabilities(PChar(FName), PChar(FPort), DC_PAPERNAMES, LPaperNames, FMode);
    for I := 0 to LPaperSizesCount - 1 do
    begin
      if LPaperSizes[I] <> 256 then
      {$IFDEF D2009UP}
        FPapers.AddObject(StrPas(PWideChar(LPaperNames + I * 64)), Pointer(LPaperSizes[I]));
      {$ELSE}
        FPapers.AddObject(StrPas(PAnsiChar(LPaperNames + I * 64)), Pointer(LPaperSizes[I]));
      {$ENDIF}
    end;
    FreeMem(LPaperNames, LPaperSizesCount * 64 * SizeOf(char));
  end;

  procedure _FillBins();
  var
    I: Integer;
    LBinsCount: Integer;
    LBinNames: PChar;
    LBinNumbers: array[0..255] of Word;
  begin
    FillChar(LBinNumbers, SizeOf(LBinNumbers), 0);
    LBinsCount := DeviceCapabilities(PChar(FName), PChar(FPort), DC_BINS, @LBinNumbers[0], FMode);
    GetMem(LBinNames, LBinsCount * 24 * SizeOf(Char));
    try
      DeviceCapabilities(PChar(FName), PChar(FPort), DC_BINNAMES, LBinNames, FMode);
    except

    end;

    for I := 0 to LBinsCount - 1 do
    begin
      if LBinNumbers[I] <> DMBIN_AUTO then
    {$IFDEF D2009UP}
        FBins.AddObject(StrPas(PwideChar(LBinNames + I * 24)), Pointer(LBinNumbers[I]));
    {$ELSE}
        FBins.AddObject(StrPas(LBinNames + I * 24), Pointer(LBinNumbers[I]));
    {$ENDIF}
    end;
    FreeMem(LBinNames, LBinsCount * 24 * SizeOf(char));
  end;

begin
  if FInitialized then Exit; //=====>>>>
  Self.CreateDevMode();

  if FDeviceMode = 0 then Exit; //=====>>>>
  Self.RecreateDC();

  if not UpdateDeviceCaps then
  begin
    Self.FreeDevMode();
    Exit; //=====>>>>
  end;

  FDefPaperSize   := FMode.dmPaperSize;
  FDefBin         := FMode.dmDefaultSource;
  FDefDuplex      := FMode.dmDuplex;
  FPaperSize      := FDefPaperSize;
  FDefPaperWidth  := FPaperWidth;
  FDefPaperHeight := FPaperHeight;

  if FMode.dmOrientation = DMORIENT_PORTRAIT then
    FDefOrientation := poPortrait else FDefOrientation := poLandscape;

  FOrientation := FDefOrientation;
  _FillPapers();
  _FillBins();

  FBin := -1;
  FDuplex := -1;

  FInitialized := True;
end;





//----------------------------------------------------------------------------------------------

procedure TUdPrinter.Abort;
begin
  AbortDoc(FDC);
  Self.EndDoc();
end;

procedure TUdPrinter.BeginDoc;
var
  LDocInfo: TDocInfo;
begin
  FPrinting := True;

  FillChar(LDocInfo, SizeOf(LDocInfo), 0);
  LDocInfo.cbSize := SizeOf(LDocInfo);
  if FTitle <> '' then
    LDocInfo.lpszDocName := PChar(FTitle)
  else
    LDocInfo.lpszDocName := PChar('VDraw Document');

  if FFileName <> '' then
    LDocInfo.lpszOutput := PChar(FFileName);

  Self.RecreateDC();
  StartDoc(FDC, LDocInfo);
end;

procedure TUdPrinter.BeginPage;
begin
  StartPage(FDC);
end;

procedure TUdPrinter.EndDoc;
var
  L8087CW: Word;
begin
  L8087CW := Default8087CW;
  Set8087CW($133F);
  try
    Windows.EndDoc(FDC);
  except
    //...
  end;
  Set8087CW(L8087CW);

  FPrinting := False;

  Self.RecreateDC();
  FBin := -1;
  FDuplex := -1;

  FMode.dmFields := FMode.dmFields or DM_DEFAULTSOURCE or DM_DUPLEX;
  FMode.dmDefaultSource := FDefBin;
  FMode.dmDuplex := FDefDuplex;

  FDC := ResetDC(FDC, FMode^);
end;

procedure TUdPrinter.EndPage;
begin
  Windows.EndPage(FDC);
end;

procedure TUdPrinter.BeginRAWDoc;
var
  LDocInfo: TDocInfo1;
begin
  RecreateDC;
  LDocInfo.pDocName := PChar(FTitle);
  LDocInfo.pOutputFile := nil;
  LDocInfo.pDataType := 'RAW';
  StartDocPrinter(FHandle, 1, @LDocInfo);
  StartPagePrinter(FHandle);
end;

procedure TUdPrinter.EndRAWDoc;
begin
  EndPagePrinter(FHandle);
  EndDocPrinter(FHandle);
end;

procedure TUdPrinter.WriteRAWDoc(const ABuf: AnsiString);
var
  N: DWORD;
begin
  WritePrinter(FHandle, PAnsiChar(ABuf), Length(ABuf), N);
end;



//---------------------------------------------------------------------------------------------

procedure TUdPrinter.SetViewParams(APaperSize: TUdPageSize; APaperWidth, APaperHeight: Double;
  AOrientation: TUdPrinterOrientation);
begin
  if APaperSize <> 256 then
  begin
    FMode.dmFields := DM_PAPERSIZE or DM_ORIENTATION;
    FMode.dmPaperSize := APaperSize;
    if AOrientation = poPortrait then
      FMode.dmOrientation := DMORIENT_PORTRAIT else
      FMode.dmOrientation := DMORIENT_LANDSCAPE;
    RecreateDC;
    if not UpdateDeviceCaps then Exit;
  end
  else
  begin
    // copy the margins from A4 paper
    SetViewParams(DMPAPER_A4, 0, 0, AOrientation);
    FPaperHeight := APaperHeight;
    FPaperWidth  := APaperWidth;
  end;

  FPaperSize := APaperSize;
  FOrientation := AOrientation;
end;

procedure TUdPrinter.SetPrintParams(APaperSize: TUdPageSize; APaperWidth, APaperHeight: Double;
  AOrientation: TUdPrinterOrientation; ABin: TUdBinNum; ADuplex, ACopies: Integer);
begin
  FMode.dmFields := FMode.dmFields or DM_PAPERSIZE or DM_ORIENTATION or DM_COPIES or DM_DEFAULTSOURCE;

  if APaperSize = 256 then
  begin
    FMode.dmFields := FMode.dmFields or DM_PAPERLENGTH or DM_PAPERWIDTH;
    if AOrientation = poLandscape then
    begin
      FMode.dmPaperLength := Round(APaperWidth * 10);
      FMode.dmPaperWidth  := Round(APaperHeight * 10);
    end
    else
    begin
      FMode.dmPaperLength := Round(APaperHeight * 10);
      FMode.dmPaperWidth  := Round(APaperWidth * 10);
    end;
  end
  else
  begin
    FMode.dmPaperLength := 0;
    FMode.dmPaperWidth := 0;
  end;

  FMode.dmPaperSize := APaperSize;
  if AOrientation = poPortrait then
    FMode.dmOrientation := DMORIENT_PORTRAIT else FMode.dmOrientation := DMORIENT_LANDSCAPE;

  FMode.dmCopies := ACopies;
  if FBin <> -1 then ABin := FBin;
  if ABin = DMBIN_AUTO then ABin := FDefBin;
  FMode.dmDefaultSource := ABin;

  if ADuplex = 0 then
    ADuplex := FDefDuplex else Inc(ADuplex);

  if ADuplex =  4  then ADuplex := DMDUP_SIMPLEX;
  if FDuplex <> -1 then ADuplex := FDuplex;
  if ADuplex <> 1  then FMode.dmFields := FMode.dmFields or DM_DUPLEX;
  FMode.dmDuplex := ADuplex;

  FDC := ResetDC(FDC, FMode^);
  FDC := ResetDC(FDC, FMode^);  // needed for some printers

  FCanvas.Refresh;
  if not Self.UpdateDeviceCaps() then Exit; //=============>>>>>

  FPaperSize := APaperSize;
  FOrientation := AOrientation;
end;

function TUdPrinter.UpdateDeviceCaps: Boolean;
var
  LHandle: THandle;
begin
  Result := True;
  if FDC = 0 then GetDC;

  FDPI := Point(GetDeviceCaps(FDC, LOGPIXELSX), GetDeviceCaps(FDC, LOGPIXELSY));
  if (FDPI.X = 0) or (FDPI.Y = 0) then
  begin
    Result := False;

    if Screen.ActiveForm <> nil then
      LHandle := Screen.ActiveForm.Handle else LHandle := Application.Handle;
    Windows.MessageBox(LHandle, 'Printer selected is not valid', '', MB_ICONWARNING or MB_OK);

    Exit; //=============>>>>>
  end;

  FPaperHeight  := Round(GetDeviceCaps(FDC, PHYSICALHEIGHT) / FDPI.Y * 25.4);
  FPaperWidth   := Round(GetDeviceCaps(FDC, PHYSICALWIDTH)  / FDPI.X * 25.4);
  FLeftMargin   := Round(GetDeviceCaps(FDC, PHYSICALOFFSETX) / FDPI.X * 25.4);
  FTopMargin    := Round(GetDeviceCaps(FDC, PHYSICALOFFSETY) / FDPI.Y * 25.4);
  FRightMargin  := FPaperWidth - Round(GetDeviceCaps(FDC, HORZRES) / FDPI.X * 25.4) - FLeftMargin;
  FBottomMargin := FPaperHeight - Round(GetDeviceCaps(FDC, VERTRES) / FDPI.Y * 25.4) - FTopMargin;
end;

procedure TUdPrinter.PropertiesDlg;
var
  LHandle: THandle;
  LPrevDuplex: Integer;
begin
  LPrevDuplex := FMode.dmDuplex;
  if Screen.ActiveForm <> nil then
    LHandle := Screen.ActiveForm.Handle else LHandle := Application.Handle;

  if WinSpool.DocumentProperties(LHandle, FHandle, PChar(FName), FMode^,
                        FMode^, DM_IN_BUFFER or DM_OUT_BUFFER or DM_IN_PROMPT) > 0 then
  begin
    FBin := FMode.dmDefaultSource;
    if LPrevDuplex <> FMode.dmDuplex then FDuplex := FMode.dmDuplex;
    RecreateDC;
  end;
end;




//==================================================================================================
{ TUdPrinters }

constructor TUdPrinters.Create;
begin
  FPrinterList := TList.Create;
  FPrinters := TStringList.Create;

  Self.FillPrinters();
  if FPrinterList.Count = 0 then
  begin
    FPrinterList.Add(TUdCustomPrinter.Create('Virtual Printer', ''));
    FHasPhysicalPrinters := False;
    PrinterIndex := 0;
  end
  else begin
    FHasPhysicalPrinters := True;
    PrinterIndex := IndexOf(GetDefaultPrinter);
    if PrinterIndex = -1 then  // important
      PrinterIndex := 0;
  end;
end;

destructor TUdPrinters.Destroy;
begin
  Self.Clear();
  FPrinterList.Free;
  FPrinters.Free;
  inherited;
end;




//----------------------------------------------------------------------------------

function TUdPrinters.GetItem(AIndex: Integer): TUdCustomPrinter;
begin
  if AIndex >= 0 then
    Result := FPrinterList[AIndex]
  else
    Result := nil
end;

function TUdPrinters.GetCurrentPrinter: TUdCustomPrinter;
begin
  Result := Self.GetItem(FPrinterIndex);
end;


function TUdPrinters.GetPrinterCount: Integer;
begin
  Result := FPrinterList.Count;
end;


function TUdPrinters.GetDefaultPrinter: string;
var
  LPrintName: array[0..255] of Char;
begin
  GetProfileString('windows', 'device', '', LPrintName,  255);
  Result := Copy(LPrintName, 1, Pos(',', LPrintName) - 1);
end;

procedure TUdPrinters.SetPrinterIndex(Value: Integer);
begin
  if Value <> -1 then
    FPrinterIndex := Value
  else
    FPrinterIndex := Self.IndexOf(GetDefaultPrinter());

  if FPrinterIndex <> -1 then
    Self.GetItem(FPrinterIndex).Init();
end;



//----------------------------------------------------------------------------------

procedure TUdPrinters.Clear();
begin
  while FPrinterList.Count > 0 do
  begin
    TObject(FPrinterList[0]).Free;
    FPrinterList.Delete(0);
  end;
  FPrinters.Clear;
end;



procedure TUdPrinters.FillPrinters;

  procedure _AddPrinter(ADevice, APort: string);
  begin
    FPrinterList.Add(TUdPrinter.Create(ADevice, APort));
    FPrinters.Add(ADevice);
  end;

var
  I, J: Integer;
  LLevel: Byte;
  LBuf, LPrnInfo: PByte;
  LFlags, LBufSize, LPrnCount: DWORD;
  LStrings: TStringList;
begin
  Self.Clear();

  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    LFlags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
    LLevel := 4;
  end
  else
  begin
    LFlags := PRINTER_ENUM_LOCAL;
    LLevel := 5;
  end;

  LBufSize := 0;
  EnumPrinters(LFlags, nil, LLevel, nil, 0, LBufSize, LPrnCount);
  if LBufSize = 0 then Exit; //==========>>>>>>

  GetMem(LBuf, LBufSize);
  try
    if not EnumPrinters(LFlags, nil, LLevel, PByte(LBuf), LBufSize, LBufSize, LPrnCount) then
      Exit; //==========>>>>>>

    LPrnInfo := LBuf;
    for I := 0 to LPrnCount - 1 do
    begin
      if LLevel = 4 then
      begin
        with PPrinterInfo4(LPrnInfo)^ do
        begin
          _AddPrinter(pPrinterName, '');
          Inc(LPrnInfo, SizeOf(TPrinterInfo4));
        end
      end
      else begin
        with PPrinterInfo5(LPrnInfo)^ do
        begin
          LStrings := TStringList.Create;
          FSetCommaText(pPortName, LStrings, ',');

          for J := 0 to LStrings.Count - 1 do
           _AddPrinter(pPrinterName, LStrings[J]);

          LStrings.Free;
          Inc(LPrnInfo, SizeOf(TPrinterInfo5));
        end;
      end;
    end;
  finally
    FreeMem(LBuf, LBufSize);
  end;
end;



function TUdPrinters.IndexOf(AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FPrinterList.Count - 1 do
  begin
    if AnsiCompareText(Items[I].Name, AName) = 0 then
    begin
      Result := I;
      Break;
    end;
  end;
end;






//=================================================================================================

function GlobalPrinters: TUdPrinters;
begin
  if _GPrinters = nil then
    _GPrinters := TUdPrinters.Create;
  Result := _GPrinters;
end;

initialization

finalization
  if _GPrinters <> nil then
    _GPrinters.Free;


end.