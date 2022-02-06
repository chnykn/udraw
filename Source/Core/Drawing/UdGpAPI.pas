
unit UdGpAPI;

interface

uses
  Windows;

type
  PARGB  = ^ARGB;
  ARGB   = DWORD;


type
  {$EXTERNALSYM TGpStatus}
  TGpStatus = (
    Ok,
    GenericError,
    InvalidParameter,
    OutOfMemory,
    ObjectBusy,
    InsufficientBuffer,
    NotImplemented,
    Win32Error,
    WrongState,
    Aborted,
    FileNotFound,
    ValueOverflow,
    AccessDenied,
    UnknownImageFormat,
    FontFamilyNotFound,
    FontStyleNotFound,
    NotTrueTypeFont,
    UnsupportedGdiplusVersion,
    GdiplusNotInitialized,
    PropertyNotFound,
    PropertyNotSupported
  );

  {$EXTERNALSYM TGpFillMode}
  TGpFillMode = (
    FillModeAlternate,        // 0
    FillModeWinding           // 1
  );


    
type
  PGpPoint = ^TGpPoint;
  TGpPoint = packed record
    X : Integer;
    Y : Integer;
  end;

  PGpPointF = ^TGpPointF;
  TGpPointF = packed record
    X : Single;
    Y : Single;
  end;





type
  TGpPenUnit = (
    UnitWorld,      // 0 -- World coordinate (non-physical unit)
    UnitDisplay,    // 1 -- Variable -- for PageTransform only
    UnitPixel,      // 2 -- Each unit is one device pixel.
    UnitPoint,      // 3 -- Each unit is a printer's point, or 1/72 inch.
    UnitInch,       // 4 -- Each unit is 1 inch.
    UnitDocument,   // 5 -- Each unit is 1/300 inch.
    UnitMillimeter  // 6 -- Each unit is 1 millimeter.
  );

  {$EXTERNALSYM TGpDashStyle}
  TGpDashStyle = (
    DashStyleSolid,          // 0
    DashStyleDash,           // 1
    DashStyleDot,            // 2
    DashStyleDashDot,        // 3
    DashStyleDashDotDot,     // 4
    DashStyleCustom          // 5
  );


type
  {$EXTERNALSYM TGpBrushType}
  TGpBrushType = (
   BrushTypeSolidColor,
   BrushTypeHatchFill,
   BrushTypeTextureFill,
   BrushTypePathGradient,
   BrushTypeLinearGradient 
  );

  {$EXTERNALSYM TGpHatchStyle}
  TGpHatchStyle = (
    HatchStyleHorizontal,                  // = 0,
    HatchStyleVertical,                    // = 1,
    HatchStyleForwardDiagonal,             // = 2,
    HatchStyleBackwardDiagonal,            // = 3,
    HatchStyleCross,                       // = 4,
    HatchStyleDiagonalCross,               // = 5,
    HatchStyle05Percent,                   // = 6,
    HatchStyle10Percent,                   // = 7,
    HatchStyle20Percent,                   // = 8,
    HatchStyle25Percent,                   // = 9,
    HatchStyle30Percent,                   // = 10,
    HatchStyle40Percent,                   // = 11,
    HatchStyle50Percent,                   // = 12,
    HatchStyle60Percent,                   // = 13,
    HatchStyle70Percent,                   // = 14,
    HatchStyle75Percent,                   // = 15,
    HatchStyle80Percent,                   // = 16,
    HatchStyle90Percent,                   // = 17,
    HatchStyleLightDownwardDiagonal,       // = 18,
    HatchStyleLightUpwardDiagonal,         // = 19,
    HatchStyleDarkDownwardDiagonal,        // = 20,
    HatchStyleDarkUpwardDiagonal,          // = 21,
    HatchStyleWideDownwardDiagonal,        // = 22,
    HatchStyleWideUpwardDiagonal,          // = 23,
    HatchStyleLightVertical,               // = 24,
    HatchStyleLightHorizontal,             // = 25,
    HatchStyleNarrowVertical,              // = 26,
    HatchStyleNarrowHorizontal,            // = 27,
    HatchStyleDarkVertical,                // = 28,
    HatchStyleDarkHorizontal,              // = 29,
    HatchStyleDashedDownwardDiagonal,      // = 30,
    HatchStyleDashedUpwardDiagonal,        // = 31,
    HatchStyleDashedHorizontal,            // = 32,
    HatchStyleDashedVertical,              // = 33,
    HatchStyleSmallConfetti,               // = 34,
    HatchStyleLargeConfetti,               // = 35,
    HatchStyleZigZag,                      // = 36,
    HatchStyleWave,                        // = 37,
    HatchStyleDiagonalBrick,               // = 38,
    HatchStyleHorizontalBrick,             // = 39,
    HatchStyleWeave,                       // = 40,
    HatchStylePlaid,                       // = 41,
    HatchStyleDivot,                       // = 42,
    HatchStyleDottedGrid,                  // = 43,
    HatchStyleDottedDiamond,               // = 44,
    HatchStyleShingle,                     // = 45,
    HatchStyleTrellis,                     // = 46,
    HatchStyleSphere,                      // = 47,
    HatchStyleSmallGrid,                   // = 48,
    HatchStyleSmallCheckerBoard,           // = 49,
    HatchStyleLargeCheckerBoard,           // = 50,
    HatchStyleOutlinedDiamond,             // = 51,
    HatchStyleSolidDiamond,                // = 52,

    HatchStyleTotal                        // = 53,
  );



  {$EXTERNALSYM DebugEventLevel}
  DebugEventLevel = (
    DebugEventLevelFatal,
    DebugEventLevelWarning
  );
  TDebugEventLevel = DebugEventLevel;
    
  {$EXTERNALSYM DebugEventProc}
  DebugEventProc = procedure(level: DebugEventLevel; message: PChar); stdcall;
    
  {$EXTERNALSYM TUdGpStartupInput}
  TUdGpStartupInput = packed record
    GdiplusVersion          : Cardinal;       // Must be 1
    DebugEventCallback      : DebugEventProc; // Ignored on free builds
    SuppressBackgroundThread: BOOL;           // FALSE unless you're prepared to call
                                              // the hook/unhook functions properly
    SuppressExternalCodecs  : BOOL;           // FALSE unless you want GDI+ only to use
  end;                                        // its internal image codecs.
  PUdGpStartupInput = ^TUdGpStartupInput;




function GdiplusStartup(out token: ULONG; input: PUdGpStartupInput; output: PUdGpStartupInput): TGpStatus; stdcall;
  {$EXTERNALSYM GdiplusStartup}

procedure GdiplusShutdown(token: ULONG); stdcall;
  {$EXTERNALSYM GdiplusShutdown}

function GdipCreateFromHDC(hdc: HDC; out graphics: Pointer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipCreateFromHDC}

function GdipDeleteGraphics(graphics: Pointer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDeleteGraphics}    




//----------------------------------------------------------------------------

function GdipCreatePen1(color: ARGB; width: Single; unit_: TGpPenUnit; out pen: Pointer): TGpStatus; stdcall;
 {$EXTERNALSYM GdipCreatePen1}

function GdipDeletePen(pen: Pointer): TGpStatus; stdcall;
 {$EXTERNALSYM GdipDeletePen}



function GdipSetPenWidth(pen: Pointer; width: Single): TGpStatus; stdcall;
  {$EXTERNALSYM GdipSetPenWidth}

function GdipGetPenWidth(pen: Pointer; out width: Single): TGpStatus; stdcall;
  {$EXTERNALSYM GdipGetPenWidth}


function GdipSetPenColor(pen: Pointer; argb: ARGB): TGpStatus; stdcall;
  {$EXTERNALSYM GdipSetPenColor}

function GdipGetPenColor(pen: Pointer; out argb: ARGB): TGpStatus; stdcall;
  {$EXTERNALSYM GdipGetPenColor}


function GdipGetPenDashStyle(pen: Pointer; out dashstyle: TGpDashStyle): TGpStatus; stdcall;
  {$EXTERNALSYM GdipGetPenDashStyle}

function GdipSetPenDashStyle(pen: Pointer; dashstyle: TGpDashStyle): TGpStatus; stdcall;
  {$EXTERNALSYM GdipSetPenDashStyle}




//----------------------------------------------------------------------------
  
function GdipGetBrushType(brush: Pointer; out type_: TGpBrushType): TGpStatus; stdcall;
  {$EXTERNALSYM GdipGetBrushType}

function GdipDeleteBrush(brush: Pointer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDeleteBrush}



function GdipCreateSolidFill(color: ARGB; out brush: Pointer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipCreateSolidFill}

function GdipSetSolidFillColor(brush: Pointer; color: ARGB): TGpStatus; stdcall;
  {$EXTERNALSYM GdipSetSolidFillColor}

function GdipGetSolidFillColor(brush: Pointer; out color: ARGB): TGpStatus; stdcall;
  {$EXTERNALSYM GdipGetSolidFillColor}



function GdipCreateHatchBrush(hatchstyle: Integer; forecol: ARGB;
  backcol: ARGB; out brush: Pointer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipCreateHatchBrush}

function GdipGetHatchStyle(brush: Pointer; out hatchstyle: TGpHatchStyle): TGpStatus; stdcall;
  {$EXTERNALSYM GdipGetHatchStyle}

function GdipGetHatchForegroundColor(brush: Pointer; out forecol: ARGB): TGpStatus; stdcall;
  {$EXTERNALSYM GdipGetHatchForegroundColor}

function GdipGetHatchBackgroundColor(brush: Pointer; out backcol: ARGB): TGpStatus; stdcall;
  {$EXTERNALSYM GdipGetHatchBackgroundColor}




//----------------------------------------------------------------------------

function GdipDrawLine(graphics: Pointer; pen: Pointer; x1: Single;
  y1: Single; x2: Single; y2: Single): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDrawLine}

function GdipDrawLineI(graphics: Pointer; pen: Pointer; x1: Integer;
  y1: Integer; x2: Integer; y2: Integer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDrawLineI}


function GdipDrawRectangle(graphics: Pointer; pen: Pointer; x: Single;
  y: Single; width: Single; height: Single): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDrawRectangle}

function GdipDrawRectangleI(graphics: Pointer; pen: Pointer; x: Integer;
  y: Integer; width: Integer; height: Integer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDrawRectangleI}


function GdipDrawArc(graphics: Pointer; pen: Pointer; x: Single; y: Single;
  width: Single; height: Single; startAngle: Single;
  sweepAngle: Single): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDrawArc}

function GdipDrawArcI(graphics: Pointer; pen: Pointer; x: Integer;
  y: Integer; width: Integer; height: Integer; startAngle: Single;
  sweepAngle: Single): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDrawArcI}


function GdipDrawPolygon(graphics: Pointer; pen: Pointer; points: PGpPointF;
  count: Integer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDrawPolygon}

function GdipDrawPolygonI(graphics: Pointer; pen: Pointer; points: PGpPoint;
  count: Integer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipDrawPolygonI}




function GdipFillRectangle(graphics: Pointer; brush: Pointer; x: Single;
  y: Single; width: Single; height: Single): TGpStatus; stdcall;
  {$EXTERNALSYM GdipFillRectangle}

function GdipFillRectangleI(graphics: Pointer; brush: Pointer; x: Integer;
  y: Integer; width: Integer; height: Integer): TGpStatus; stdcall;
  {$EXTERNALSYM GdipFillRectangleI}


function GdipFillPie(graphics: Pointer; brush: Pointer; x: Single;
  y: Single; width: Single; height: Single; startAngle: Single;
  sweepAngle: Single): TGpStatus; stdcall;
  {$EXTERNALSYM GdipFillPie}

function GdipFillPieI(graphics: Pointer; brush: Pointer; x: Integer;
  y: Integer; width: Integer; height: Integer; startAngle: Single;
  sweepAngle: Single): TGpStatus; stdcall;
  {$EXTERNALSYM GdipFillPieI}


function GdipFillPolygon(graphics: Pointer; brush: Pointer;
  points: PGpPointF; count: Integer; fillMode: TGpFillMode): TGpStatus; stdcall;
  {$EXTERNALSYM GdipFillPolygon}

function GdipFillPolygonI(graphics: Pointer; brush: Pointer;
  points: PGpPoint; count: Integer; fillMode: TGpFillMode): TGpStatus; stdcall;
  {$EXTERNALSYM GdipFillPolygonI}




implementation

const
  WINGDIPDLL = 'gdiplus.dll';


//-----------------------------------------------------------------------------

function GdiplusStartup; external WINGDIPDLL name 'GdiplusStartup';
procedure GdiplusShutdown; external WINGDIPDLL name 'GdiplusShutdown';

function GdipCreateFromHDC; external WINGDIPDLL name 'GdipCreateFromHDC';
function GdipDeleteGraphics; external WINGDIPDLL name 'GdipDeleteGraphics';



//-----------------------------------------------------------------------------

function GdipCreatePen1; external WINGDIPDLL name 'GdipCreatePen1';
function GdipDeletePen; external WINGDIPDLL name 'GdipDeletePen';

function GdipSetPenWidth; external WINGDIPDLL name 'GdipSetPenWidth';
function GdipGetPenWidth; external WINGDIPDLL name 'GdipGetPenWidth';

function GdipSetPenColor; external WINGDIPDLL name 'GdipSetPenColor';
function GdipGetPenColor; external WINGDIPDLL name 'GdipGetPenColor';

function GdipGetPenDashStyle; external WINGDIPDLL name 'GdipGetPenDashStyle';
function GdipSetPenDashStyle; external WINGDIPDLL name 'GdipSetPenDashStyle';



//-----------------------------------------------------------------------------

function GdipGetBrushType; external WINGDIPDLL name 'GdipGetBrushType';
function GdipDeleteBrush; external WINGDIPDLL name 'GdipDeleteBrush';

function GdipCreateSolidFill; external WINGDIPDLL name 'GdipCreateSolidFill';
function GdipSetSolidFillColor; external WINGDIPDLL name 'GdipSetSolidFillColor';
function GdipGetSolidFillColor; external WINGDIPDLL name 'GdipGetSolidFillColor';

function GdipCreateHatchBrush; external WINGDIPDLL name 'GdipCreateHatchBrush';
function GdipGetHatchStyle; external WINGDIPDLL name 'GdipGetHatchStyle';
function GdipGetHatchForegroundColor; external WINGDIPDLL name 'GdipGetHatchForegroundColor';
function GdipGetHatchBackgroundColor; external WINGDIPDLL name 'GdipGetHatchBackgroundColor';



//-----------------------------------------------------------------------------


function GdipDrawLine; external WINGDIPDLL name 'GdipDrawLine';
function GdipDrawLineI; external WINGDIPDLL name 'GdipDrawLineI';

function GdipDrawRectangle; external WINGDIPDLL name 'GdipDrawRectangle';
function GdipDrawRectangleI; external WINGDIPDLL name 'GdipDrawRectangleI';

function GdipDrawArc; external WINGDIPDLL name 'GdipDrawArc';
function GdipDrawArcI; external WINGDIPDLL name 'GdipDrawArcI';

function GdipDrawPolygon; external WINGDIPDLL name 'GdipDrawPolygon';
function GdipDrawPolygonI; external WINGDIPDLL name 'GdipDrawPolygonI';


function GdipFillRectangle; external WINGDIPDLL name 'GdipFillRectangle';
function GdipFillRectangleI; external WINGDIPDLL name 'GdipFillRectangleI';

function GdipFillPie; external WINGDIPDLL name 'GdipFillPie';
function GdipFillPieI; external WINGDIPDLL name 'GdipFillPieI';

function GdipFillPolygon; external WINGDIPDLL name 'GdipFillPolygon';
function GdipFillPolygonI; external WINGDIPDLL name 'GdipFillPolygonI';







end.