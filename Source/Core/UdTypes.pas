{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdTypes;

{$I UdDefs.INC}

{$IFNDEF ExtendedPrecision}
  {$IFNDEF SinglePrecision}
    {$IFNDEF DoublePrecision}
       {$DEFINE DoublePrecision}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}



interface

uses
  Windows, Types;




const
  _Epsilon  = 1.0E-8;
  _ErrValue = -MAXINT*PI;




//------------------------------------------------------------------------------------------

type
  PARGB = ^ARGB;
  ARGB  = DWORD;

  TARGB = packed record
    Blue, Green, Red, Alpha: Byte;
  end;


  PPoint = Types.PPoint;
  TPoint = Types.TPoint;
  TPointArray = array of TPoint;


//  PPoint2S = ^TPoint2S;
//  TPoint2S = packed record
//    X: Single;
//    Y: Single;
//  end;
//  TPoint2SArray = array of TPoint2S;



//------------------------------------------------------------------------------------------

type
  TSingleArray = Types.TSingleDynArray;
  PSingleArray = ^TSingleArray;

{$IFDEF DoublePrecision}
  Float = Double;
  TFloatArray = Types.TDoubleDynArray;
{$ENDIF DoublePrecision}

{$IFDEF SinglePrecision}
  Float = Single;
  TFloatArray = Types.TSingleDynArray;
{$ENDIF SinglePrecision}

{$IFDEF ExtendedPrecision}
  Float = Extended;
  TFloatArray = array of Extended;
{$ENDIF ExtendedPrecision}

  PFloat = ^Float;


type

  //---------- Vertex Type -----------------
  PPoint2D = ^TPoint2D;
  TPoint2D = packed record
    X, Y: Float;
  end;

  TBound2D = array[0..3] of TPoint2D;

  TPoint2DArray = array of TPoint2D;
  PPoint2DArray = ^TPoint2DArray;
  TPoint2DArrays = array of TPoint2DArray;


  PPoint3D = ^TPoint3D;
  TPoint3D = packed record
    X, Y, Z: Float;
  end;
  TPoint3DArray = array of TPoint3D;
  PPoint3DArray = ^TPoint3DArray;
  TPoint3DArrays = array of TPoint3DArray;




  //---------- Rectangle Type ---------------

  PRect2D = ^TRect2D;
  TRect2D = {packed} record
    case Integer of
      0: (X1, Y1, X2, Y2: Float);
      1: (P1, P2: TPoint2D);
    end;
  TRect2DArray = array of TRect2D;





//------------------------------------------------------------------------------------------

type

 TUdCodePage = (
    osdefault, ascii,
    iso8859_1, iso8859_2, iso8859_3, iso8859_4, iso8859_5, iso8859_6, iso8859_7, tiso8859_8, iso8859_9,
    dos437, dos850, dos852, dos855, dos857, dos860, dos861, dos863, dos864, dos865, dos869, dos932,
    mac_roman, big5, ksc5601, johab, dos866, ansi_1250, ansi_1251, ansi_1252, gb2312,
    ansi_1253, ansi_1254, ansi_1255, ansi_1256, ansi_1257, ansi_874, ansi_932, ansi_936, ansi_949,
    ansi_950, ansi_1361, ansi_1200, ansi_1258, DrawingDefault
   );

   
  TUdTextAlign = (taTopLeft,    taTopCenter,    taTopRight,
                  taMiddleLeft, taMiddleCenter, taMiddleRight,
                  taBottomLeft, taBottomCenter, taBottomRight);


  TUdTextStyleRec = packed record
    //Height: Float;
    WidthFactor: Float;
    LineSpaceFactor: Float;
    Rotation: Float;
    Align: TUdTextAlign;
    Backward: Boolean;
    Upsidedown: Boolean;
  end;
  PUdTextStyleRec = ^TUdTextStyleRec;


type
  TUdArrowStyle = (asClosedFilled, asClosedBlank, asClosed, asDot, asArchTick, asOblique, asOpen,
                  asOriginIndicator, asOriginIndicator2, asRightAngle, asOpen30, asDotSmall, asDotBlank,
                  asDotSmallBlank, asBox, asBoxFilled, asDutumTriangle, asDutumTriFilled, asIntegral, asNone);

  TUdPointState = (psNull, psPoint, psLine, psRect, psQuare, psCircle, psCross, psXCross);
  TUdPointStates = set of TUdPointState;



//------------------------------------------------------------------------------------------

type
  TUdArcKind = (akCurve, akSector, akChord);
  TUdByKind = (bkNone, bkByLayer, bkByBlock);


  TUdCursorStyle = (csNone, csIdle, csDraw, csPick, csPan, csZoom);

  TUdEntitiestate = (fsNone=0, fsFinished=1, fsSelected=2, fsHidden=4, fsUnderGrip=8, fsCanSelected=16);


  TUdOSnapPoint = record
    Entity: TObject;
    Mode: Cardinal;
    Point: TPoint2D;
    Angle: Float;
  end;
  TUdOSnapPointArray = array of TUdOSnapPoint;




  TUdGripMode = (gmCenter, gmPoint, gmAngle, gmRotation, gmRadius, gmSize);

  TUdGripPoint = record
    Entity: TObject;
    Mode: TUdGripMode;
    Index: Integer;
    Point: TPoint2D;
    Angle: Float;
  end;
  TUdGripPointArray = array of TUdGripPoint;




type
  PLtSeg = ^TLtSeg;
  TLtSeg = record
    P1: TPoint2D;
    P2: TPoint2D;
  end;

  PLtData = ^TLtData;
  TLtData = record
    Data: PLtSeg;
    Next: PLtData;
  end;
  TLtDataArray = array of PLtData;



//-------------------------------------------------------------------------------
(*
type

  TUdGradientKind = (
    gkHorzSymm,   gkVertSymm, gkFDglSymm,  gkBDglSymm,  // 横向对称过渡/纵向对称过度/斜下对称过度/斜上对称过度
    gkHorizontal, gkVertical, gkFDiagonal, gkBDiagonal, // 横向过渡/纵向过度/斜下过度/斜上过度
    gkTopLeft, gkTopRight, gkBottomLeft, gkBottomRight, // 左上角辐射/右上角辐射/左下角辐射/右上角辐射
    gkSquare, gkElliptic);                              // 中心方辐射/中心圆辐射

  TUdGradientStyle = packed record
    Kind: TUdGradientKind;
    Color1: TColor;
    Color2: TColor;
    Bound: TBound2D;
  end;
  PUdGradientStyle = ^TUdGradientStyle;
*)




function NewPoint2D(): PPoint2D; overload;
function NewPoint2D(X, Y: Double): PPoint2D; overload;


function MakeOSnapPoint(AEntity: TObject; AMode: Integer; {AIndex: Integer;} APoint: TPoint2D; AAngle: Float): TUdOSnapPoint; {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}
function MakeGripPoint(AEntity: TObject;  AMode: TUdGripMode; AIndex: Integer; APoint: TPoint2D; AAngle: Float): TUdGripPoint;   {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}





implementation


//=================================================================================================


function NewPoint2D(): PPoint2D;
begin
  Result := New(PPoint2D);
  Result^.X := 0.0;
  Result^.Y := 0.0;
end;

function NewPoint2D(X, Y: Double): PPoint2D;
begin
  Result := New(PPoint2D);
  Result^.X := X;
  Result^.Y := Y;
end;




function MakeOSnapPoint(AEntity: TObject; AMode: Integer; {AIndex: Integer;} APoint: TPoint2D; AAngle: Float): TUdOSnapPoint;
begin
  Result.Entity := AEntity;
  Result.Mode   := AMode;
  Result.Point  := APoint;
  Result.Angle  := AAngle;
end;

function MakeGripPoint(AEntity: TObject; AMode: TUdGripMode; AIndex: Integer; APoint: TPoint2D; AAngle: Float): TUdGripPoint;
begin
  Result.Entity := AEntity;
  Result.Mode  := AMode;
  Result.Index := AIndex;
  Result.Point := APoint;
  Result.Angle := AAngle;
end;







end.