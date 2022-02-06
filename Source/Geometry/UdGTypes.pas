{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdGTypes;

{$I UdGeoDefs.INC}


{$IFNDEF UdTypes}
  {$IFNDEF ExtendedPrecision}
    {$IFNDEF SinglePrecision}
      {$IFNDEF DoublePrecision}
         {$DEFINE DoublePrecision}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}


interface

uses
  Types {$IFDEF UdTypes}, UdTypes {$ENDIF};



{$IFDEF UdTypes}    //UdTypes

const
   _Epsilon   = UdTypes._Epsilon;
   _ErrValue  = UdTypes._ErrValue;

type
  Float       = UdTypes.Float;
  TFloatArray = UdTypes.TFloatArray;
  PFloat      = UdTypes.PFloat;


{$ELSE}

const
   _Epsilon   = 1.0E-8;
   _ErrValue  = -280223983524810;  //-$FEDBCAFEDBCA

type
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

{$ENDIF}





const
  _RightHandSide {: Longint} = -1;
  _LeftHandSide  {: Longint} = +1;
  _NeutralOfSide {: LongInt} = 00;

  _HighiEpsilon         = 1.0E-15;


  _OVERLAP   = -1;  //重叠
  _PARALLEL  = -2;  //平行
  _NEARNESS  = -3;  //接近

  DEF_ANG_STEP  = 2;


//  DEF_ANG_REPAIR  = 9.5177841814223759628378059668E-4;
//  DEF_ANG_FACTOR  = 1 + DEF_ANG_REPAIR;



type
{$IFDEF UdTypes}    //UdTypes
  TArcKind = UdTypes.TUdArcKind;
{$ELSE}
  TArcKind = (akCurve, akSector, akChord);
{$ENDIF}

  TInclusion = (irOutside, irIntsct, irEqual, irCovered, irOvered);  //inclusion relation




const
  _Sqrt2: Float       = 1.4142135623730950488016887242097;      // Sqrt(2)
  _Sqrt3: Float       = 1.7320508075688772935274463415059;      // Sqrt(3)
  _Sqrt5: Float       = 2.2360679774997896964091736687313;      // Sqrt(5)
  _Sqrt10: Float      = 3.1622776601683793319988935444327;      // Sqrt(10)
  _SqrtPi: Float      = 1.7724538509055160272981674833411;      // Sqrt(PI)

  _2Pi: Float         = 6.283185307179586476925286766559;       // 2 * PI
  _3Pi: Float         = 9.4247779607693797153879301498385;      // 3 * PI
  _PiDiv2: Float      = 1.5707963267948966192313216916398;      // PI / 2

  _PiDiv180: Float    = 0.017453292519943295769236907684886;    // Pi / 180
  _180DivPi: Float    = 57.2957795130823208767981548141050;     // 180 / Pi

  _E: Float           = 2.7182818284590452353602874713527;      // Natural constant

  _Ln2: Float         = 0.69314718055994530941723212145818;     // Ln(2)
  _Ln10: Float        = 2.3025850929940456840179914546844;      // Ln(10)
  _LnPi: Float        = 1.1447298858494001741434273513531;      // Ln(PI)

  _Log2: Float        = 0.30102999566398119521373889472449;     // Log10(2)
  _Log3: Float        = 0.47712125471966243729502790325512;     // Log10(3)
  _LogPi: Float       = 0.4971498726941338543512682882909;      // Log10(PI)
  _LogE: Float        = 0.43429448190325182765112891891661;     // Log10(E)










//============================================================================================
{Base Geometry types...}

type


{$IFDEF UdTypes}    //UdTypes

  TBound2D = UdTypes.TBound2D;

  //---------- Vertex Type -----------------
  PPoint2D = UdTypes.PPoint2D;
  TPoint2D = UdTypes.TPoint2D;

  TPoint2DArray  = UdTypes.TPoint2DArray ;
  PPoint2DArray  = UdTypes.PPoint2DArray ;
  TPoint2DArrays = UdTypes.TPoint2DArrays;


  PPoint3D = UdTypes.PPoint3D;
  TPoint3D = UdTypes.TPoint3D;

  TPoint3DArray  = UdTypes.TPoint3DArray ;
  PPoint3DArray  = UdTypes.PPoint3DArray ;
  TPoint3DArrays = UdTypes.TPoint3DArrays;



  //---------- Rectangle Type ---------------

  PRect2D = UdTypes.PRect2D;
  TRect2D = UdTypes.TRect2D;
  TRect2DArray = UdTypes.TRect2DArray;

{$ELSE}

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

{$ENDIF}





  //---------- Vector Type -------------------

  PVector2D = ^TVector2D;
  TVector2D = packed record
    X, Y: Float;
  end;
  TVector2DArray = array of TVector2D;


  PVector3D = ^TVector3D;
  TVector3D = packed record
    X, Y, Z: Float;
  end;
  TVector3DArray = array of TVector3D;




  //---------- Line Type ---------------------

  PLineK = ^TLineK;
  TLineK = {packed} record
    K: Float;
    B: Float;
    HasK: Boolean;
  end;

  PRay2D = ^TRay2D;
  TRay2D = record
    Base: TPoint2D;
    Ang: Float;
  end;


  PLine2D = ^TLine2D;
  TLine2D = {packed} record
    P1, P2: TPoint2D;
  end;
  TLine2DArray = array of TLine2D;



  PLine3D = ^TLine3D;
  TLine3D = {packed} record
    P1, P2: TPoint3D;
  end;
  TLine3DArray = array of TLine3D;




  //---------- Segment Type ------------------

  PSegment2D = ^TSegment2D;
  TSegment2D = {packed} record
    P1, P2: TPoint2D;
  end;
  TSegment2DArray = array of TSegment2D;
  PSegment2DArray = ^TSegment2DArray;


  PSegment3D = ^TSegment3D;
  TSegment3D = {packed} record
    P1, P2: TPoint3D;
  end;
  TSegment3DArray = array of TSegment3D;
  PSegment3DArray = ^TSegment3DArray;





  //---------- Circle Type ------------------

  PCircle2D = ^TCircle2D;
  TCircle2D = {packed} record
    Cen: TPoint2D;
    R: Float;
  end;
  TCircle2DArray = array of TCircle2D;
  PCircle2DArray = ^TCircle2DArray;


  PCircle3D = ^TCircle3D;
  TCircle3D = {packed} record
    Cen: TPoint3D;
    R: Float;
    Dirct: TVector3D;
  end;
  TCircle3DArray = array of TCircle3D;
  PCircle3DArray = ^TCircle3DArray;


  //---------- Arc Type ---------------------

  PArc2D = ^TArc2D;
  TArc2D = {packed} record
    Cen: TPoint2D;
    R: Float;
    Ang1, Ang2: Float;
    IsCW: Boolean; //is clockwise ?
    Kind: TArcKind;
  end;
  TArc2DArray = array of TArc2D;
  PArc2DArray = ^TArc2DArray;


  PArc3D = ^TArc3D;
  TArc3D = {packed} record
    Cen: TPoint3D;
    R: Float;
    Ang1, Ang2: Float;
    Dirct: TVector3D;
  end;
  TArc3DArray = array of TArc3D;
  PArc3DArray = ^TArc3DArray;



  //---------- Ellipse Type ------------------

  PEllipse2D = ^TEllipse2D;
  TEllipse2D = {packed} record
    Cen: TPoint2D;
    Rx, Ry: Float;
    Ang1, Ang2: Float;
    Rot: Float;
    IsCW: Boolean; //is clockwise ?
    Kind: TArcKind;
  end;
  TEllipse2DArray = array of TEllipse2D;
  PEllipse2DArray = ^TEllipse2DArray;


  PEllipse3D = ^TEllipse3D;
  TEllipse3D = {packed} record
    Cen: TPoint3D;
    R1, R2: Float;
    Rot, Ang1, Ang2: Float;
    Dirct: TVector3D;
  end;
  TEllipse3DArray = array of TEllipse3D;
  PEllipse3DArray = ^TEllipse3DArray;




  //---------- Spline Type ------------------

  TSpline2D = {packed} record
    Degree: Integer;
    Knots: TFloatArray;
    CtlPnts: TPoint2DArray;
  end;
  PSpline2D = ^TSpline2D;
  





  //---------- Polygon Type ------------------

  PPolygon2D = PPoint2DArray;
  TPolygon2D = TPoint2DArray;

  TPolygon2DArray = TPoint2DArrays;
  TPolygon2DArrays = array of TPolygon2DArray;


  PPolygon3D = ^TPolygon3D;
  TPolygon3D = TPoint3DArray;

  TPolygon3DArray = array of TPolygon3D;
  TPolygon3DArrays = array of TPolygon3DArray;




  TMatrix = array of TFloatArray;





//============================================================================================
{Complex Geometry types...}

type
  PVertex2D = ^TVertex2D;
  TVertex2D = {packed} record
    Point: TPoint2D;
    Bulge: Float;
  end;
  TVertexes2D = array of TVertex2D;
  PVertexes2D = ^TVertexes2D;

  TVertexes2DArray = array of TVertexes2D;
  PVertexes2DArray = ^TVertexes2DArray;

  PSegarc2D = ^TSegarc2D;
  TSegarc2D = record
    Arc: TArc2D;
    Seg: TSegment2D;
    IsArc: Boolean;
  end;
  TSegarc2DArray = array of TSegarc2D;
  TSegarc2DArrays = array of TSegarc2DArray;
  TSegarcs2DArray = TSegarc2DArrays;



  //---------- Curve Type ------------------


  TCurveKind = (ckPolyline,  // PVertexes2D
                ckLine    ,  // PSegment2D
                ckArc     ,  // PArc2D
                ckEllipse ,  // PEllipse2D
                ckSpline   );// PSpline2D

  TCurve2D = record
    Kind: TCurveKind;
    Data: Pointer;
  end;

  TCurve2DArray = array of TCurve2D;
  TCurve2DArrays = array of TCurve2DArray;





function FreeCurveArray(var AValue: TCurve2DArray): Boolean;
procedure AssignCurveArray(var ADest: TCurve2DArray; const ASrc: TCurve2DArray);




implementation


function FreeCurveArray(var AValue: TCurve2DArray): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Length(AValue) <= 0 then Exit;

  for I := Length(AValue) - 1 downto 0 do
  begin
    if AValue[I].Data <> nil then
    begin
      case AValue[I].Kind of
        ckPolyline: Dispose(PVertexes2D(AValue[I].Data  ));
        ckLine    : Dispose(PSegment2D( AValue[I].Data  ));
        ckArc     : Dispose(PArc2D(     AValue[I].Data  ));
        ckEllipse : Dispose(PEllipse2D( AValue[I].Data  ));
        ckSpline  : Dispose(PSpline2D(  AValue[I].Data  ));
      end;
    end;
  end;

  SetLength(AValue, 0);
  Result := True;
end;

procedure AssignCurveArray(var ADest: TCurve2DArray; const ASrc: TCurve2DArray);
var
  I: Integer;  // , J

  LVertexes  : TVertexes2D;
  LSegment   : TSegment2D;
  LArc       : TArc2D;
  LEll       : TEllipse2D;
  LSpline    : TSpline2D;

  LPVertexes : PVertexes2D;
  LPSegment  : PSegment2D;
  LPArc      : PArc2D;
  LPEll      : PEllipse2D;
  LPSpline   : PSpline2D;
begin
  FreeCurveArray(ADest);
  if Length(ASrc) <= 0 then Exit;

  SetLength(ADest, Length(ASrc));
  for I := 0 to Length(ASrc) - 1 do
  begin
    ADest[I].Kind := ASrc[I].Kind;

    case ASrc[I].Kind of
      ckPolyline:
      begin
        LVertexes     := PVertexes2D(ASrc[I].Data)^;
        LPVertexes    := New(PVertexes2D);

        LPVertexes^   := LVertexes;
//        SetLength(LPVertexes^, Length(LVertexes));
//        for J := 0 to Length(LVertexes) - 1 do LPVertexes^[J] := LVertexes[J];

        ADest[I].Data := LPVertexes;
      end;

      ckLine:
      begin
        LSegment      := PSegment2D( ASrc[I].Data)^;
        LPSegment     := New(PSegment2D);
        LPSegment^    := LSegment;
        ADest[I].Data := LPSegment;
      end;

      ckArc:
      begin
        LArc          := PArc2D(     ASrc[I].Data)^;
        LPArc         := New(PArc2D);
        LPArc^        := LArc;
        ADest[I].Data := LPArc;
      end;

      ckEllipse :
      begin
        LEll          := PEllipse2D( ASrc[I].Data)^;
        LPEll         := New(PEllipse2D);
        LPEll^        := LEll;
        ADest[I].Data := LPEll;
      end;

      ckSpline  :
      begin
        LSpline       := PSpline2D(  ASrc[I].Data)^;
        LPSpline      := New(PSpline2D);

        LPSpline^     := LSpline;
//        SetLength(LPSpline^.Knots, Length(LSpline.Knots));
//        for J := 0 to Length(LSpline.Knots) - 1 do LPSpline^.Knots[J] := LSpline.Knots[J];
        
//        SetLength(LPSpline^.CtlPnts, Length(LSpline.CtlPnts));
//        for J := 0 to Length(LSpline.CtlPnts) - 1 do LPSpline^.CtlPnts[J] := LSpline.CtlPnts[J];


        ADest[I].Data := LPSpline;
      end;
    end;

    {
    case ASrc[I].Kind of
      ckPolyline: begin ADest[I].Data := New(PVertexes2D);  PVertexes2D(ADest[I].Data)^ := PVertexes2D(ASrc[I].Data)^; end;
      ckLine    : begin ADest[I].Data := New(PSegment2D);   PSegment2D( ADest[I].Data)^ := PSegment2D( ASrc[I].Data)^; end;
      ckArc     : begin ADest[I].Data := New(PArc2D);       PArc2D(     ADest[I].Data)^ := PArc2D(     ASrc[I].Data)^; end;
      ckEllipse : begin ADest[I].Data := New(PEllipse2D);   PEllipse2D( ADest[I].Data)^ := PEllipse2D( ASrc[I].Data)^; end;
      ckSpline  : begin ADest[I].Data := New(PSpline2D);    PSpline2D(  ADest[I].Data)^ := PSpline2D(  ASrc[I].Data)^; end;
    end;
    }

  end;
end;






end.