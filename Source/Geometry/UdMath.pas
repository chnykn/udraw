{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdMath;

{$I UdGeoDefs.INC}

interface

uses
  UdGTypes, Types;



type
  TEqResult = packed record
    L: ShortInt;
    X: array[0..3] of Extended;
  end;

  TUdPointBoolFunc = function(APnt: TPoint2D): Boolean;


//-----------------------------------------------------------------------------------------------
{ Equal }

function IsEqual(Val1, Val2: Float; Epsilon: Float = _Epsilon): Boolean; overload;
function IsEqual(Pnt1, Pnt2: TPoint2D; Epsilon: Float = _Epsilon): Boolean; overload;
function IsEqual(Pnt1, Pnt2: TPoint3D; Epsilon: Float = _Epsilon): Boolean; overload;

function NotEqual(Val1, Val2: Float; Epsilon: Float = _Epsilon): Boolean; overload;
function NotEqual(Pnt1, Pnt2: TPoint2D; Epsilon: Float = _Epsilon): Boolean; overload;
function NotEqual(Pnt1, Pnt2: TPoint3D; Epsilon: Float = _Epsilon): Boolean; overload;

function IsEqual(Seg1, Seg2: TSegment2D; SameDr: Boolean = False; Epsilon: Float = _Epsilon): Boolean; overload;
function IsEqual(Segs1, Segs2: TSegment2DArray; SameDr: Boolean = False; Epsilon: Float = _Epsilon): Boolean; overload;
function IsEqual(Arc1, Arc2: TArc2D; SameDr: Boolean = False; Epsilon: Float = _Epsilon): Boolean; overload;

function IsEqual(Segarc1, Segarc2: TSegarc2D; Epsilon: Float = _Epsilon): Boolean; overload;
function IsEqual(Segarcs1, Segarcs2: TSegarc2DArray; Epsilon: Float = _Epsilon): Boolean; overload;

//function IsEqual(Ints1, Ints2: TIntArray): Boolean; overload;
//function IsEqual(Bools1, Bools2: TBoolArray): Boolean; overload;
//function IsEqual(Floats1, Floats2: TFloatArray; Epsilon: Float = _Epsilon): Boolean; overload;


function IsEqual(AVex1, AVex2: TVertex2D; Epsilon: Float = _Epsilon): Boolean; overload;
function IsEqual(AVexes1, AVexes2: TVertexes2D; Epsilon: Float = _Epsilon): Boolean; overload;

function IsEqual(AValues1, AValues2: TFloatArray; Epsilon: Float = _Epsilon): Boolean; overload;
function IsEqual(AValues1, AValues2: TSingleDynArray; Epsilon: Float = _Epsilon): Boolean; overload;


{ Max&Min }

function Max(X, Y: Float): Float; overload;
function Max(X, Y: Longint): Longint; overload

function Min(X, Y: Float): Float; overload;
function Min(X, Y: Longint): Longint; overload;

function IsZero(X: Float): Boolean; overload;
function IsZero(X: Longint): Boolean; overload;

procedure Swap(var X, Y: Integer); overload;
procedure Swap(var X, Y: Float); overload;
procedure Swap(var P1, P2: TPoint2D); overload;
procedure Swap(var P1, P2: TPoint3D); overload;



{Clock Wise}
function IsClockWise(X1, Y1, X2, Y2, X3, Y3: Double; NeutralValue: Boolean = True): Boolean; overload;
function IsClockWise(Pnt1, Pnt2, Pnt3: TPoint2D; NeutralValue: Boolean = True): Boolean; overload;
function IsCCW(X1, Y1, X2, Y2, X3, Y3: Double; NeutralValue: Boolean = True): Boolean; overload;
function IsCCW(Pnt1, Pnt2, Pnt3: TPoint2D; NeutralValue: Boolean = True): Boolean; overload;

{Mirror Degress angle}
function VertMirrorAngle(const Angle : Float) : Float;
function HorzMirrorAngle(const Angle : Float) : Float;



{ Logarithmic }

function LogBase10(X: Extended): Extended;
function LogBase2(X: Extended): Extended;
function LogBaseN(Base, X: Extended): Extended;



{ Coordinate conversion }
function DegToRad(Degs: Extended): Extended;
function RadToDeg(Rads: Extended): Extended;

function DegToFloat(Degs, Mins, Secs: Extended): Extended;
procedure FloatToDeg(X: Extended; var Degs, Mins, Secs: Extended);




{ Transcendental }

function Sin(X: Extended): Extended;
function Cos(X: Extended): Extended;
function Tan(X: Extended): Extended;
function Cot(X: Extended): Extended;
function Sec(X: Extended): Extended;
function Csc(X: Extended): Extended;

function ArcSin(X: Extended): Extended;
function ArcCos(X: Extended): Extended;
function ArcTan(X: Extended): Extended;
function ArcCot(X: Extended): Extended;
function ArcSec(X: Extended): Extended;
function ArcCsc(X: Extended): Extended;
function ArcTan2(Y, X: Extended): Extended;

procedure SinCos(X: Extended; var Sin, Cos: Extended);
procedure SinCosD(X: Extended; var Sin, Cos: Extended);


function SinD(X: Extended): Extended; overload;
function CosD(X: Extended): Extended; overload;
function TanD(X: Extended): Extended; overload;
function CotD(X: Extended): Extended;
function SecD(X: Extended): Extended;
function CscD(X: Extended): Extended;

function ArcSinD(X: Extended): Extended;
function ArcCosD(X: Extended): Extended;
function ArcTanD(X: Extended): Extended;
function ArcCotD(X: Extended): Extended;
function ArcSecD(X: Extended): Extended;
function ArcCscD(X: Extended): Extended;
function ArcTan2D(Y, X: Extended): Extended;


function SinD(X: Longint): Extended; overload;
function CosD(X: Longint): Extended; overload;
function TanD(X: Longint): Extended; overload;




function FixAngle(Value: Longint): Longint; overload;
function FixAngle(Value: Extended): Extended; overload;
function RFixAngle(Value: Extended): Extended;

{ Hyperbolic }

function SinH(X: Extended): Extended;
function CosH(X: Extended): Extended;
function CotH(X: Extended): Extended;
function CscH(X: Extended): Extended;
function SecH(X: Extended): Extended;
function TanH(X: Extended): Extended;

function ArcSinH(X: Extended): Extended;
function ArcCosH(X: Extended): Extended;
function ArcCotH(X: Extended): Extended;
function ArcCscH(X: Extended): Extended;
function ArcSecH(X: Extended): Extended;
function ArcTanH(X: Extended): Extended;





{ Exponential }

function Exp(X: Extended): Extended;
function Power(Base, Exponent: Extended): Extended;
function PowerInt(X: Extended; N: Longint): Extended;
function TenToY(Y: Extended): Extended;
function TruncPower(Base, Exponent: Extended): Extended;
function TwoToY(Y: Extended): Extended;




{ TFloating point numbers support routines }

function ModFloat(X, Y: Extended): Extended;
function RemainderFloat(X, Y: Extended): Extended;




{ Miscellaneous }

function Ceiling(X: Float): Longint;
function Floor(X: Float): Longint;
function RoundEx(Value: Float): Int64; overload;
function RoundEx(Value: Float; Digits: Integer): Float; overload;
function RoundEx(Value: TPoint2D; Digits: Integer = 3): TPoint2D; overload;

function Factorial(N: Longint): Float; //


function GCD(X, Y: Cardinal): Cardinal; //greatest common divisor
function LCM(X, Y: Cardinal): Cardinal; //lowest common multiple
{$IFDEF WIN32}
function ISqrt(I: Smallint): Smallint;
{$ENDIF}
function Sign(X: Float): Longint;

//function Pythagoras(X, Y: Float): Float;
//function Ackermann(A, B: Longint): Longint;
//function Fibonacci(N: Longint): Longint;
//function Signe(X, Y: Float): Float;


{ Ranges }

function EnsureRange(AValue, AMin, AMax: Int64): Int64; overload;
function EnsureRange(AValue, AMin, AMax: Float): Float; overload;
function EnsureRange(AValue, AMin, AMax: Longint): Longint; overload;

function IsInRange(AValue, AMin, AMax: Int64): Boolean; overload;
function IsInRange(AValue, AMin, AMax: Float): Boolean; overload;
function IsInRange(AValue, AMin, AMax: Longint): Boolean; overload;

function IsInAngles(Ang: Float; Ang1, Ang2: Float; const Epsilon: Float = 1.0E-04): Boolean; //ang must in [0 ~ 360]
//function IsRobustInAngles(Ang: Float; Ang1, Ang2: Float; const Epsilon: Float = 1.0E-06): Boolean;

function MidAngle(Ang1, Ang2: Float): Float;

//function IsInArray(const AValue: Longint; AnArray: TIntArray): Boolean; overload;
//function IsInArray(const AValue: Longint; AnArray: TIntArray; out Index: Integer): Boolean; overload;

//function IsInArray(const AValue: Float; AnArray: TFloatArray): Boolean; overload;
//function IsInArray(const AValue: Float; AnArray: TFloatArray; out Index: Integer): Boolean; overload;



{ Algebraic equation }

function Equation(A, B, C: Extended): TEqResult; overload;       // A*X^2 + B*X + C = 0
function Equation(A, B, C, D: Extended): TEqResult; overload;    // A*X^3 + B*X^2 + C*X + D = 0
function Equation(A, B, C, D, E: Extended): TEqResult; overload; // A*X^4 + B*X^3 + C*X^2 + D*X + E = 0

function LenToAng(Len: Float; R: Float): Float;
function SgnAngle(Ang: Float; Epsilon: Float = _Epsilon): Float;


function TrimPoints(APnts: TPoint2DArray; Epsilon: Float = _Epsilon; AAllowFunc: TUdPointBoolFunc = nil): TPoint2DArray;
//function SortPoints(var A: TPoint2DArray; B: TPoint2D): Boolean; overload;
//function SortPoints(var A: TPoint2DArray; Arc: TArc2D): Boolean; overload;
//function SortPoints(var A: TPoint2DArray; Ell: TEllipse2D): Boolean; overload;


{ TPolyseg2D }

function FAddArray(var Dest: TPoint2DArray; Source: TPoint2DArray): Boolean; overload;
function FAddArray(var Dest: TPolygon2DArray; Source: TPolygon2DArray): Boolean; overload;
function FAddArray(var Dest: TPoint3DArray; Source: TPoint3DArray): Boolean; overload;

function FInsertArray(var Dest: TPoint2DArray; Index: Integer; Source: TPoint2DArray): Boolean; overload;
function FInsertArray(var Dest: TPolygon2DArray; Index: Integer; Source: TPolygon2DArray): Boolean; overload;
function FInsertArray(var Dest: TPoint3DArray; Index: Integer; Source: TPoint3DArray): Boolean; overload;


{ TPoint2D&TRect2D}

function InvalidPoint(ErrValue: Float = _ErrValue): TPoint2D;
function IsValidPoint(Pnt: TPoint2D; ErrValue: Float = _ErrValue): Boolean;

procedure InitRect(var ARect: TRect2D);
function IsValidRect(ARect: TRect2D): Boolean;
//function RectEdge(Rect: TRect2D; Edge:Integer): TSegment2D;

procedure InitBound(var ABound: TBound2D);
function IsValidBound(ABound: TBound2D): Boolean;


var
  SinTable: array of Float;
  CosTable: array of Float;
  TanTable: array of Float;


implementation

uses
  SysUtils, Math;

{ Exception constants }

const
  SDomainError        = 'Domain check failure';
  SDivByZero          = 'Division by zero';
  SPowerInfinite      = 'Power Result is infinite';
  SPowerComplex       = 'Power Result is complex';

  ZeroTolerance: Float  = 0.000000001;  // Zero Precision Tolerance


const
  MaxAngle: Float = 9223372036854775808.0;                            // 2^63 Rad

{$IFDEF SinglePrecision}
  MaxFactorial           = 33;
  MaxTanH: Float         = 44.361419555836499802702855773323;       // Ln(2^128)/2
{$ENDIF SinglePrecision}

{$IFDEF DoublePrecision}
  MaxFactorial           = 170;
  MaxTanH: Float         = 354.89135644669199842162284618659;       // Ln(2^1024)/2
{$ENDIF DoublePrecision}

{$IFDEF ExtendedPrecision}
  MaxFactorial           = 1754;
  MaxTanH: Float         = 5678.2617031470719747459655389854;       // Ln(2^16384)/2
{$ENDIF ExtendedPrecision}


const
  doubleRoundLimit: Double = 1E+16;
  maxRoundingDigits: Integer = 15;
  roundPower10Double: array[0..15] of Double =
    (1.0, 10.0, 100.0, 1000.0, 10000.0, 100000.0, 1000000.0, 10000000.0, 100000000.0,
    1000000000.0, 10000000000, 100000000000, 1000000000000, 10000000000000, 100000000000000, 1E+15);




//-------------------------------------------------------------------------------------------------

procedure DomainCheck(Error: Boolean);
begin
  if Error then raise Exception.Create(SDomainError);
end;


//function Point2DToPointF(APnt: TPoint2D): TPointF;
//begin
//  Result.X := APnt.X;
//  Result.Y := APnt.Y;
//end;
//
//function PointFToPoint2D(APnt: TPointF): TPoint2D;
//begin
//  Result.X := APnt.X;
//  Result.Y := APnt.Y;
//end;


function FAddArray(var Dest: TPoint2DArray; Source: TPoint2DArray): Boolean;
var
  I: Integer;
  L1, L2: Integer;
begin
  Result := False;
  if System.Length(Source) = 0 then Exit;

  L1 := System.Length(Dest);
  L2 := System.Length(Source);

  System.SetLength(Dest, L1 + L2);
  for I := L1 to L1 + L2 - 1 do Dest[I] := Source[I - L1];

  Result := True;
end;

function FAddArray(var Dest: TPolygon2DArray; Source: TPolygon2DArray): Boolean;
var
  I: Integer;
  L1, L2: Integer;
begin
  Result := False;
  if System.Length(Source) = 0 then Exit;

  L1 := System.Length(Dest);
  L2 := System.Length(Source);

  System.SetLength(Dest, L1 + L2);
  for I := L1 to L1 + L2 - 1 do Dest[I] := Source[I - L1];

  Result := True;
end;

function FAddArray(var Dest: TPoint3DArray; Source: TPoint3DArray): Boolean;
var
  I: Integer;
  L1, L2: Integer;
begin
  Result := False;
  if System.Length(Source) = 0 then Exit;

  L1 := System.Length(Dest);
  L2 := System.Length(Source);

  System.SetLength(Dest, L1 + L2);
  for I := L1 to L1 + L2 - 1 do Dest[I] := Source[I - L1];

  Result := True;
end;



// 0, 1, 2, 3            // 0, 1, 2, 3
// 0, 1, 2, 3  @, @      // 0, 1, 2, 3  @, @
// 0, 1, 2, 3  @, 3      // 0, 1, 0, 1  2, 3
// 0, 1, 2, a, b, 3      // a, b, 0, 1  2, 3

function FInsertArray(var Dest: TPoint2DArray; Index: Integer; Source: TPoint2DArray): Boolean;
var
  I, N, L: Integer;
  LTemp: TPoint2DArray;
begin
  Result := False;
  if System.Length(Source) = 0 then Exit;

  if Index >= Length(Dest) then
  begin
    Result := FAddArray(Dest, Source);
    Exit;
  end;

  SetLength(LTemp, Length(Dest)-Index);
  for I := 0 to Length(Dest)-Index - 1 do
  begin
    LTemp[I] := Dest[I+Index];
  end;


  L := Length(Source);
  SetLength(Dest, Length(Dest)+L);

  N := 0;
  for I := Index to Length(Dest) - 1 do
  begin
    Dest[I+L] := LTemp[N];
    Inc(N);
  end;

  for I := 0 to L-1 do
    Dest[I+Index] := Source[I];

  Result := True;
end;

function FInsertArray(var Dest: TPolygon2DArray; Index: Integer; Source: TPolygon2DArray): Boolean;
var
  I, N, L: Integer;
  LTemp: TPolygon2DArray;
begin
  Result := False;
  if System.Length(Source) = 0 then Exit;

  if Index >= Length(Dest) then
  begin
    Result := FAddArray(Dest, Source);
    Exit;
  end;

  SetLength(LTemp, Length(Dest)-Index);
  for I := 0 to Length(Dest)-Index - 1 do
  begin
    LTemp[I] := Dest[I+Index];
  end;


  L := Length(Source);
  SetLength(Dest, Length(Dest)+L);

  N := 0;
  for I := Index to Length(Dest) - 1 do
  begin
    Dest[I+L] := LTemp[N];
    Inc(N);
  end;

  for I := 0 to L-1 do
    Dest[I+Index] := Source[I];

  Result := True;
end;

function FInsertArray(var Dest: TPoint3DArray; Index: Integer; Source: TPoint3DArray): Boolean;
var
  I, N, L: Integer;
  LTemp: TPoint3DArray;
begin
  Result := False;
  if System.Length(Source) = 0 then Exit;

  if Index >= Length(Dest) then
  begin
    Result := FAddArray(Dest, Source);
    Exit;
  end;

  SetLength(LTemp, Length(Dest)-Index);
  for I := 0 to Length(Dest)-Index - 1 do
  begin
    LTemp[I] := Dest[I+Index];
  end;


  L := Length(Source);
  SetLength(Dest, Length(Dest)+L);

  N := 0;
  for I := Index to Length(Dest) - 1 do
  begin
    Dest[I+L] := LTemp[N];
    Inc(N);
  end;

  for I := 0 to L-1 do
    Dest[I+Index] := Source[I];

  Result := True;
end;


//==================================================================================================
{Equal}

function IsEqual(Val1, Val2: Float; Epsilon: Float = _Epsilon): Boolean;
var
  Delta: Float;
begin
  Delta  := Abs(Val1 - Val2);
  Result := (Delta <= Epsilon);
end;

function IsEqual(Pnt1, Pnt2: TPoint2D; Epsilon: Float = _Epsilon): Boolean;
begin
  Result := (IsEqual(Pnt1.X, Pnt2.X, Epsilon) and
             IsEqual(Pnt1.Y, Pnt2.Y, Epsilon));
end;

function IsEqual(Pnt1, Pnt2: TPoint3D; Epsilon: Float = _Epsilon): Boolean;
begin
  Result := (IsEqual(Pnt1.X, Pnt2.X, Epsilon) and
             IsEqual(Pnt1.Y, Pnt2.Y, Epsilon) and
             IsEqual(Pnt1.Z, Pnt2.Z, Epsilon));
end;



function NotEqual(Val1, Val2: Float; Epsilon: Float = _Epsilon): Boolean;
var
  Delta: Float;
begin
  Delta  := Abs(Val1 - Val2);
  Result := (Delta > Epsilon);
end;


function NotEqual(Pnt1, Pnt2: TPoint2D; Epsilon: Float = _Epsilon): Boolean;
begin
  Result := (NotEqual(Pnt1.X, Pnt2.X, Epsilon) or
             NotEqual(Pnt1.Y, Pnt2.Y, Epsilon));
end;

function NotEqual(Pnt1, Pnt2: TPoint3D; Epsilon: Float = _Epsilon): Boolean;
begin
  Result := (NotEqual(Pnt1.X, Pnt2.X, Epsilon) or
             NotEqual(Pnt1.Y, Pnt2.Y, Epsilon) or
             NotEqual(Pnt1.Z, Pnt2.Z, Epsilon));
end;


//function IsEqual(Pnt1, Pnt2: TPointF; Epsilon: Float = _Epsilon): Boolean; overload;
//begin
//  Result := (IsEqual(Pnt1.X, Pnt2.X, Epsilon) and
//             IsEqual(Pnt1.Y, Pnt2.Y, Epsilon));
//end;

function IsEqual(Seg1, Seg2: TSegment2D;  SameDr: Boolean = False; Epsilon: Float = _Epsilon): Boolean;
begin
  Result := (IsEqual(Seg1.P1, Seg2.P1, Epsilon) and IsEqual(Seg1.P2, Seg2.P2, Epsilon));
  if not Result and not SameDr then
    Result := (IsEqual(Seg1.P1, Seg2.P2, Epsilon) and IsEqual(Seg1.P2, Seg2.P1, Epsilon));
end;

function IsEqual(Segs1, Segs2: TSegment2DArray; SameDr: Boolean = False; Epsilon: Float = _Epsilon): Boolean;
var
  I, L1, L2: Integer;
begin
  Result := False;
  L1 := System.Length(Segs1);
  L2 := System.Length(Segs2);
  if L1 = L2 then
  begin
    for I := 0 to L1 - 1 do
    begin
      if not IsEqual(Segs1[I], Segs2[I], SameDr, Epsilon) then
        Exit;
    end;
    Result := True;
  end;
end;


function IsEqual(Arc1, Arc2: TArc2D; SameDr: Boolean = False;  Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsEqual(Arc1.Cen, Arc2.Cen, Epsilon) and IsEqual(Arc1.R, Arc2.R, Epsilon) and
            IsEqual(Arc1.Ang1, Arc2.Ang1, Epsilon) and IsEqual(Arc1.Ang2, Arc2.Ang2, Epsilon);
  if Result and SameDr then
    Result := Arc1.IsCW =  Arc2.IsCW;
end;


function IsEqual(Segarc1, Segarc2: TSegarc2D; Epsilon: Float = _Epsilon): Boolean;
begin
  Result := Segarc1.IsArc = Segarc2.IsArc;

  if Result then
  begin
    case Segarc1.IsArc of
      True : Result := IsEqual(Segarc1.Arc, Segarc2.Arc, True, Epsilon);
      False: Result := IsEqual(Segarc1.Seg, Segarc2.Seg, True, Epsilon);
    end;
  end;
end;

function IsEqual(Segarcs1, Segarcs2: TSegarc2DArray; Epsilon: Float = _Epsilon): Boolean;
var
  I, L1, L2: Integer;
begin
  Result := False;
  L1 := System.Length(Segarcs1);
  L2 := System.Length(Segarcs2);
  if L1 = L2 then
  begin
    for I := 0 to L1 - 1 do
    begin
      if not IsEqual(Segarcs1[I], Segarcs2[I], Epsilon) then
        Exit;
    end;
    Result := True;
  end;
end;


(*
function IsEqual(Ints1, Ints2: TIntArray): Boolean;
var
  I: Integer;
  L1, L2: Integer;
begin
  Result := False;

  L1 := System.Length(Ints1);
  L2 := System.Length(Ints2);

  if (L1 <= 0) or (L2 <= 0) or (L1 <> L2) then Exit;

  Result := True;

  for I := 0 to L1 - 1 do
  begin
    if Ints1[I] <> Ints2[I] then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function IsEqual(Bools1, Bools2: TBoolArray): Boolean;
var
  I: Integer;
  L1, L2: Integer;
begin
  Result := False;

  L1 := System.Length(Bools1);
  L2 := System.Length(Bools2);

  if (L1 <= 0) or (L2 <= 0) or (L1 <> L2) then Exit;

  Result := True;

  for I := 0 to L1 - 1 do
  begin
    if Bools1[I] <> Bools2[I] then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function IsEqual(Floats1, Floats2: TFloatArray; Epsilon: Float = _Epsilon): Boolean;
var
  I: Integer;
  L1, L2: Integer;
begin
  Result := False;

  L1 := System.Length(Floats1);
  L2 := System.Length(Floats2);

  if (L1 <= 0) or (L2 <= 0) or (L1 <> L2) then Exit;

  Result := True;

  for I := 0 to L1 - 1 do
  begin
    if not IsEqual(Floats1[I], Floats2[I], Epsilon) then
    begin
      Result := False;
      Break;
    end;
  end;
end;
*)



function IsEqual(AVex1, AVex2: TVertex2D; Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsEqual(AVex1.Point, AVex2.Point, Epsilon) and IsEqual(AVex1.Bulge, AVex2.Bulge, Epsilon);
end;

function IsEqual(AVexes1, AVexes2: TVertexes2D; Epsilon: Float = _Epsilon): Boolean;
var
  I: Integer;
begin
  Result := System.Length(AVexes1) = System.Length(AVexes2);
  if Result then
  begin
    for I := 0 to System.Length(AVexes1) - 1 do
    begin
      if not IsEqual(AVexes1[I], AVexes2[I]) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;

end;



function IsEqual(AValues1, AValues2: TFloatArray; Epsilon: Float = _Epsilon): Boolean;
var
  I: Integer;
  L1, L2: Integer;
begin
  Result := False;

  L1 := System.Length(AValues1);
  L2 := System.Length(AValues2);

  if {(L1 <= 0) or (L2 <= 0) or} (L1 <> L2) then Exit;

  Result := True;

  for I := 0 to L1 - 1 do
  begin
    if not IsEqual(AValues1[I], AValues2[I], Epsilon) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function IsEqual(AValues1, AValues2: TSingleDynArray; Epsilon: Float = _Epsilon): Boolean;
var
  I: Integer;
  L1, L2: Integer;
begin
  Result := False;

  L1 := System.Length(AValues1);
  L2 := System.Length(AValues2);

  if {(L1 <= 0) or (L2 <= 0) or} (L1 <> L2) then Exit;

  Result := True;

  for I := 0 to L1 - 1 do
  begin
    if not IsEqual(AValues1[I], AValues2[I], Epsilon) then
    begin
      Result := False;
      Break;
    end;
  end;
end;



//==================================================================================================
{ Max&Min }

function Max(X, Y: Longint): Longint;
begin
  if X < Y then Result := Y else Result := X;
end;

function Max(X, Y: Float): Float;
begin
  if X < Y then Result := Y else Result := X;
end;


function Min(X, Y: Longint): Longint;
begin
  if X > Y then Result := Y else Result := X;
end;

function Min(X, Y: Float): Float;
begin
  if X > Y then Result := Y else Result := X;
end;


function IsZero(X: Longint): Boolean;
begin
  Result := X = 0;
end;

function IsZero(X: Float): Boolean;
begin
  Result := Abs(X) < ZeroTolerance;
end;


procedure Swap(var X, Y: Integer);
var
  T: Integer;
begin
  T := X;
  X := Y;
  Y := T;
end;

procedure Swap(var X, Y: Float);
var
  T: Float;
begin
  T := X;
  X := Y;
  Y := T;
end;

procedure Swap(var P1, P2: TPoint2D);
var
  TP: TPoint2D;
begin
  TP := P1;
  P1 := P2;
  P2 := TP;
end;

procedure Swap(var P1, P2: TPoint3D);
var
  TP: TPoint3D;
begin
  TP := P1;
  P1 := P2;
  P2 := TP;
end;




function IsClockWise(X1, Y1, X2, Y2, X3, Y3: Double; NeutralValue: Boolean = True): Boolean;
var
  E: Double;
  Dx1, Dy1, Dx2, Dy2: Double;
begin
  Dx1 := X2 - X1;
  Dy2 := Y3 - Y1;

  Dx2 := X3 - X1;
  Dy1 := Y2 - Y1;

  E := (Dy2 * Dx1 - Dx2 * Dy1);

  if IsEqual(E, 0) then
    Result := NeutralValue
  else if E > 0 then
    Result := False
  else
    Result := True;
end;

function IsClockWise(Pnt1, Pnt2, Pnt3: TPoint2D; NeutralValue: Boolean = True): Boolean;
begin
  Result := IsClockWise(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y, NeutralValue);
end;

function IsCCW(X1, Y1, X2, Y2, X3, Y3: Double; NeutralValue: Boolean = True): Boolean;
var
  E: Double;
  Dx1, Dy1, Dx2, Dy2: Double;
begin
  Dx1 := X2 - X1;
  Dy2 := Y3 - Y1;

  Dx2 := X3 - X1;
  Dy1 := Y2 - Y1;

  E := (Dy2 * Dx1 - Dx2 * Dy1);

  if IsEqual(E, 0) then
    Result := NeutralValue
  else if E > 0 then
    Result := True
  else
    Result := False;
end;


function IsCCW(Pnt1, Pnt2, Pnt3: TPoint2D; NeutralValue: Boolean = True): Boolean;
begin
  Result := IsCCW(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y, NeutralValue);
end;



function VertMirrorAngle(const Angle : Float) : Float;
begin
  Result := Angle;
  if IsEqual(Angle,  0.0) or
     IsEqual(Angle,180.0) or
     IsEqual(Angle,360.0) then Exit;
  Result := 360 - FixAngle(Result);
end;


function HorzMirrorAngle(const Angle : Float) : Float;
begin
  Result := Angle;
  if Result <= 180 then
    Result := 180 - FixAngle(Result)
  else
    Result := 540 - FixAngle(Result);
end;




//==================================================================================================
{Logarithmic}

function LogBase10(X: Extended): Extended;
begin
  DomainCheck(X <= 0.0);
  Result := Math.Log10(X)
end;

function LogBase2(X: Extended): Extended;
begin
  DomainCheck(X <= 0.0);
  Result := Math.Log2(X)
end;

function LogBaseN(Base, X: Extended): Extended;
begin
  DomainCheck((X <= 0.0) or (Base <= 0.0) or (Base = 1.0));
  Result := Math.LogN(Base, X)
end;







//==================================================================================================
{Coordinate conversion}

function DegToRad(Degs: Extended): Extended;
begin
  Result := Degs * _PiDiv180;
end;

function RadToDeg(Rads: Extended): Extended;
begin
  Result := Rads * _180DivPi;
end;


function DegToFloat(Degs, Mins, Secs: Extended): Extended; // obsolete
begin
  Result := Degs + (Mins / 60.0) + (Secs / 3600.0);
end;

procedure FloatToDeg(X: Extended; var Degs, Mins, Secs: Extended); // obsolete
var
  Y: Float;
begin
  Degs := System.Int(X);
  Y := Frac(X) * 60;
  Mins := System.Int(Y);
  Secs := Frac(Y) * 60;
end;








//==================================================================================================
{Transcendental}

function Sin(X: Extended): Extended;
begin
  DomainCheck(Abs(X) > MaxAngle);
  Result := System.Sin(X);
end;

function Cos(X: Extended): Extended;
begin
  DomainCheck(Abs(X) > MaxAngle);
  Result := System.Cos(X);
end;

function Tan(X: Extended): Extended;
begin
  DomainCheck(Abs(X) > MaxAngle);
  Result := Math.Tan(X);
end;

function Cot(X: Extended): Extended;  // Cot = 1 / Tan -> Tan(X) <> 0.0
begin
  DomainCheck(Abs(X) > MaxAngle);
  Result := Math.Cot(X);
end;

function Sec(X: Extended): Extended; // Sec = 1 / Cos -> Cos(X) <> 0
begin
  DomainCheck(Abs(X) > MaxAngle);
  Result := Math.Sec(X);
end;

function Csc(X: Extended): Extended;
var
  Y: Extended;
begin
  DomainCheck(Abs(X) > MaxAngle);

  Y := Sin(X);
  DomainCheck(Y = 0.0);
  Result := 1.0 / Y;
end;



function ArcSin(X: Extended): Extended;
begin
  DomainCheck(Abs(X) > 1.0);
  Result := Math.ArcSin(X);
end;

function ArcCos(X: Extended): Extended;
begin
  DomainCheck(Abs(X) > 1.0);
  Result := Math.ArcCos(X);
end;



function ArcCot(X: Extended): Extended;
begin
  DomainCheck(X = 0);
  Result := Math.ArcCot(X);
end;

function ArcSec(X: Extended): Extended;
begin
  Result := Math.ArcSec(X);
end;

function ArcCsc(X: Extended): Extended;
begin
  Result := Math.ArcCsc(X);
end;

function ArcTan(X: Extended): Extended;
begin
  Result := System.ArcTan(X);
end;


function ArcTan2(Y, X: Extended): Extended;
begin
  Result := Math.ArcTan2(Y, X);
end;


procedure SinCos(X: Extended; var Sin, Cos: Extended);
begin
  Math.SinCos(X, Sin, Cos);
end;

procedure SinCosD(X: Extended; var Sin, Cos: Extended);
begin
  Math.SinCos(DegToRad(X), Sin, Cos);
end;





function SinD(X: Extended): Extended;
begin
  Result := Sin(DegToRad(X));
end;

function CosD(X: Extended): Extended;
begin
  Result := Cos(DegToRad(X));
end;

function TanD(X: Extended): Extended;
begin
  Result := Tan(DegToRad(X));
end;

function CotD(X: Extended): Extended;
begin
  Result := Cot(DegToRad(X));
end;

function SecD(X: Extended): Extended;
begin
  Result := Sec(DegToRad(X));
end;

function CscD(X: Extended): Extended;
begin
  Result := Csc(DegToRad(X));
end;




function ArcSinD(X: Extended): Extended;
begin
  Result := RadToDeg(ArcSin(X));
end;

function ArcCosD(X: Extended): Extended;
begin
  Result := RadToDeg(ArcCos(X));
end;

function ArcTanD(X: Extended): Extended;
begin
  Result := RadToDeg(ArcTan(X));
end;

function ArcCotD(X: Extended): Extended;
begin
  Result := RadToDeg(ArcCot(X));
end;

function ArcSecD(X: Extended): Extended;
begin
  Result := RadToDeg(ArcSec(X));
end;

function ArcCscD(X: Extended): Extended;
begin
  Result := RadToDeg(ArcCsc(X));
end;

function ArcTan2D(Y, X: Extended): Extended;
begin
  Result := RadToDeg(ArcTan2(Y, X));
end;





function SinD(X: Longint): Extended;
begin
  Result := SinTable[FixAngle(X)];
end;

function CosD(X: Longint): Extended;
begin
  Result := CosTable[FixAngle(X)];
end;

function TanD(X: Longint): Extended;
begin
  Result := TanTable[FixAngle(X)];
end;





function FixAngle(Value: Longint): Longint;
begin
  Result := Value mod 360;
  if Result < 0 then  Result := Result + 360;
end;


function FixAngle(Value: Extended): Extended;
var
  LEq: Extended;
  LAng: Extended;
begin
  LEq := 1E-05;

  if IsEqual(Value, 360.0, LEq) then
  begin
    Result := 360.0;
    Exit;
  end;

  if IsEqual(Value, 0.0, LEq) then
  begin
    Result := 0.0;
    Exit;
  end;


  LAng := Value;
  LAng := ModFloat(LAng, 360.0);

  if (LAng > (360.0 + LEq)) then
    LAng := LAng - 360.0;

  if ((LAng + LEq) < 0.0) then
    LAng := LAng + 360.0;


  if (IsEqual(LAng, 0.0, LEq)) then
  begin
    Result := 0.0;
    Exit;
  end;

  if (IsEqual(LAng, 90.0, LEq)) then
  begin
    Result := 90.0;
    Exit;
  end;

  if (IsEqual(LAng, 180.0, LEq)) then
  begin
    Result := 180.0;
    Exit;
  end;

  if (IsEqual(LAng, 270.0, LEq)) then
  begin
    Result := 270.0;
    Exit;
  end;

  if (IsEqual(LAng, 360.0, LEq)) then
  begin
    Result := 360.0;
    Exit;
  end;

  Result := LAng;
end;


function RFixAngle(Value: Extended): Extended;
var
  LEq: Extended;
  LAng: Extended;
begin
  LEq := 1E-07;

  if IsEqual(Value, 6.2831853071796, LEq) then
  begin
    Result := 6.2831853071796;
    Exit;
  end;

  LAng := Value;
  LAng := ModFloat(LAng, 6.2831853071796);

  if (LAng > (6.2831853071796 + LEq)) then
    LAng := LAng - 6.2831853071796;

  if ((LAng + LEq) < 0.0) then
    LAng := LAng + 6.2831853071796;


  if IsEqual(LAng, 0.0, LEq) then
  begin
    Result := 0.0;
    Exit;
  end;

  if (IsEqual(LAng, 1.5707963267948, LEq)) then
  begin
    Result := 1.5707963267948;
    Exit;
  end;

  if (IsEqual(LAng, 3.1415926535898, LEq)) then
  begin
    Result := 3.1415926535898;
    Exit;
  end;

  if (IsEqual(LAng, 4.7123889803844, LEq)) then
  begin
    Result := 4.7123889803844;
    Exit;
  end;

  if (IsEqual(LAng, 6.2831853071796, LEq)) then
  begin
    Result := 6.2831853071796;
    Exit;
  end;

  Result := LAng;
end;


//==================================================================================================
{Hyperbolic}

function SinH(X: Extended): Extended;
begin
  Result := Math.Sinh(X);
end;

function CosH(X: Extended): Extended;
begin
  Result := Math.CosH(X);
end;


function CotH(X: Extended): Extended;
begin
  Result := Math.CotH(X);
end;

function CscH(X: Extended): Extended;
begin
  Result := Math.CscH(X);
end;

function SecH(X: Extended): Extended;
begin
  Result := Math.SecH(X);
end;



function TanH(X: Extended): Extended;
begin
  Result := Math.TanH(X);
end;



function ArcSinH(X: Extended): Extended;
begin
  Result := Math.ArcSinH(X);
end;

function ArcCosH(X: Extended): Extended;
begin
  DomainCheck(X < 1.0);
  Result := Math.ArcCosH(X);
end;

function ArcCotH(X: Extended): Extended;
begin
  DomainCheck(Abs(X) = 1.0);
  Result := Math.ArcCotH(X);
end;

function ArcCscH(X: Extended): Extended;
begin
  DomainCheck(X = 0);
  Result := Math.ArcCscH(X);
end;

function ArcSecH(X: Extended): Extended;
begin
  DomainCheck(Abs(X) > 1.0);
  Result := Math.ArcSecH(X);
end;

function ArcTanH(X: Extended): Extended;
begin
  DomainCheck(Abs(X) >= 1.0);
  Result := Math.ArcTanH(X);
end;








//==================================================================================================
{Exponential}


function Exp(X: Extended): Extended;
begin
  Result := System.Exp(X);
end;

function Power(Base, Exponent: Extended): Extended;
begin
  if (Exponent > 0) and (Exponent < 1) and (Base < 0) then
    Result := -Math.Power(Abs(Base), Exponent)
  else
    Result := Math.Power(Base, Exponent);
end;

function PowerInt(X: Extended; N: Longint): Extended;
//var
//  M: Longint;
//  T: Extended;
//  Xc: Extended;
begin
  Result := Math.IntPower(X, N);

//  if X = 0.0 then
//  begin
//    if N = 0 then
//      Result := 1.0
//    else
//    if N > 0 then
//      Result := 0.0
//    else
//      Result := _MaxFloat;
//    Exit;
//  end;
//
//  if N = 0 then
//  begin
//    Result := 1.0;
//    Exit;
//  end;
//
//  // Legendre's algorithm for minimizing the number of multiplications
//  T := 1.0;
//  M := Abs(N);
//  Xc := X;
//  repeat
//    if Odd(M) then
//    begin
//      Dec(M);
//      T := T * Xc;
//    end
//    else
//    begin
//      M := M div 2;
//      Xc := Sqr(Xc);
//    end;
//  until M = 0;
//
//  if N > 0 then Result := T else Result := 1.0 / T;
end;

function TenToY(Y: Extended): Extended;
begin
  if Y = 0.0 then Result := 1.0 else Result := Exp(Y * _Ln10);
end;

function TruncPower(Base, Exponent: Extended): Extended;
begin
  if Base > 0 then Result := Power(Base, Exponent) else Result := 0;
end;

function TwoToY(Y: Extended): Extended;
begin
  if Y = 0.0 then Result := 1.0 else Result := Exp(Y * _Ln2);
end;






//==================================================================================================
{TFloating point support routines}

function ModFloat(X, Y: Extended): Extended;
var
  Z: Extended;
begin
  Result := X / Y;
  Z := System.Int(Result);
  if Frac(Result) < 0.0 then Z := Z - 1.0;
  Result := X - Y * Z;
end;

function RemainderFloat(X, Y: Extended): Extended;
begin
  Result := X - System.Int(X / Y) * Y;
end;







//==================================================================================================
{Miscellaneous}



const
  PreCompFactsCount = 33; // all factorials that fit in a Single

{$IFDEF SinglePrecision}}
  PreCompFacts: array [0..PreCompFactsCount] of Float =
   (
    1.0,
    1.0,
    2.0,
    6.0,
    24.0,
    120.0,
    720.0,
    5040.0,
    40320.0,
    362880.0,
    3628800.0,
    39916800.0,
    479001600.0,
    6227020800.0,
    87178289152.0,
    1307674279936.0,
    20922788478976.0,
    355687414628352.0,
    6.4023735304192E15,
    1.21645096004223E17,
    2.43290202316367E18,
    5.10909408371697E19,
    1.12400072480601E21,
    2.58520174445945E22,
    6.20448454699065E23,
    1.55112110792462E25,
    4.03291499589617E26,
    1.08888704151327E28,
    3.04888371623715E29,
    8.8417630793192E30,
    2.65252889961724E32,
    8.22283968552752E33,
    2.63130869936881E35,
    8.68331850984666E36
   );
{$ENDIF SinglePrecision}

{$IFDEF DoublePrecision}
  PreCompFacts: array [0..PreCompFactsCount] of Float =
   (
    1.0,
    1.0,
    2.0,
    6.0,
    24.0,
    120.0,
    720.0,
    5040.0,
    40320.0,
    362880.0,
    3628800.0,
    39916800.0,
    479001600.0,
    6227020800.0,
    87178291200.0,
    1307674368000.0,
    20922789888000.0,
    355687428096000.0,
    6.402373705728E15,
    1.21645100408832E17,
    2.43290200817664E18,
    5.10909421717094E19,
    1.12400072777761E21,
    2.5852016738885E22,
    6.20448401733239E23,
    1.5511210043331E25,
    4.03291461126606E26,
    1.08888694504184E28,
    3.04888344611714E29,
    8.8417619937397E30,
    2.65252859812191E32,
    8.22283865417792E33,
    2.63130836933694E35,
    8.68331761881189E36
   );
{$ENDIF DoublePrecision}

{$IFDEF ExtendedPrecision}
  PreCompFacts: array [0..PreCompFactsCount] of Float =
   (
    1.0,
    1.0,
    2.0,
    6.0,
    24.0,
    120.0,
    720.0,
    5040.0,
    40320.0,
    362880.0,
    3628800.0,
    39916800.0,
    479001600.0,
    6227020800.0,
    87178291200.0,
    1307674368000.0,
    20922789888000.0,
    355687428096000.0,
    6.402373705728E15,
    1.21645100408832E17,
    2.43290200817664E18,
    5.10909421717094E19,
    1.12400072777761E21,
    2.5852016738885E22,
    6.20448401733239E23,
    1.5511210043331E25,
    4.03291461126606E26,
    1.08888694504184E28,
    3.04888344611714E29,
    8.8417619937397E30,
    2.65252859812191E32,
    8.22283865417792E33,
    2.63130836933694E35,
    8.68331761881189E36
   );
{$ENDIF ExtendedPrecision}



function Ceiling(X: Float): Longint;
begin
  Result := Longint(Trunc(X));
  if Frac(X) > 0 then Inc(Result);
end;

function Floor(X: Float): Longint;
begin
  Result := Longint(Trunc(X));
  if Frac(X) < 0 then Dec(Result);
end;



function RoundEx(Value: Float): Int64;
begin
  Result := Trunc(Value);
  if Frac(Abs(Value)) >= 0.5 then Result := Result + Sign(Value);
end;

function RoundEx(Value: Float; Digits: Integer): Float;
var
  LValue: Float;
  LPower, LFrac: Float;
begin
  LValue := Value;

  if (Abs(LValue) < doubleRoundLimit) then
  begin
    LPower := roundPower10Double[digits];
    LValue := Trunc(LValue * LPower);

    LFrac := Frac(Value * LPower);
    if (Abs(LFrac) >= 0.5) then
        LValue := LValue + Sign(LFrac);

    LValue := (LValue / LPower);
  end;

  Result := LValue;
end;

function RoundEx(Value: TPoint2D; Digits: Integer = 3): TPoint2D;
begin
  Result.X := RoundEx(Value.X, Digits);
  Result.Y := RoundEx(Value.Y, Digits);
end;


(*
function RoundEx(X: Float): Float;
var
  V: Int64;
  S: string;
begin
  Result := Round(X);

  V := Round(X * 10);
  S := IntToStr(V);
  S := S[System.Length(S)];
  V := StrToInt(S);

//  if (V in [0, 1, 2, 3]) then
//  begin
//
//  end else
  if (V in [4, 5, 6]) then
  begin
    if Sign(X) < 0 then
      Result := Result - 0.5
    else
      Result := Result + 0.5;
  end else
  if (V in [7, 8, 9]) then
  begin
    if Sign(X) < 0 then
      Result := Result - 1
    else
      Result := Result + 1;
  end;
end;
*)

function Factorial(N: Longint): Float;
var
  I: Longint;
begin
  if (N < 0) or (N > MaxFactorial) then
    Result := 0.0
  else
  begin
    if N <= PreCompFactsCount then Result := PreCompFacts[N]
    else
    begin
      Result := PreCompFacts[PreCompFactsCount];
      for I := PreCompFactsCount + 1 to N do Result := Result * I;
    end;
  end;
end;



function GCD(X, Y: Cardinal): Cardinal; assembler;
asm
        JMP     @01          // start with EAX <- X, EDX <- Y, and check to see if Y=0
@00:
        MOV     ECX, EDX     // ECX <- EDX prepare for division
        XOR     EDX, EDX     // clear EDX for Division
        DIV     ECX          // EAX <- EDX:EAX div ECX, EDX <- EDX:EAX mod ECX
        MOV     EAX, ECX     // EAX <- ECX, and repeat if EDX <> 0
@01:
        AND     EDX, EDX     // test to see if EDX is zero, without changing EDX
        JNZ     @00          // when EDX is zero EAX has the Result
end;

function LCM(X, Y: Cardinal): Cardinal;
var
  E: Cardinal;
begin
  E := GCD(X, Y);
  if E > 0 then
    Result := (X div E) * Y
  else
    Result := 0;
end;

{$IFDEF WIN32}
function ISqrt(I: Smallint): Smallint; assembler;
asm
        PUSH    EBX

        MOV     CX, AX       // load argument
        MOV     AX, -1       // init Result
        CWD                  // init odd numbers to -1
        XOR     BX, BX       // init perfect squares to 0
@LOOP:
        INC     AX           // increment Result
        INC     DX           // compute
        INC     DX           // next odd number
        ADD     BX, DX       // next perfect square
        CMP     BX, CX       // perfect square > argument ?
        JBE     @LOOP        // until square greater than argument

        POP     EBX
end;
{$ENDIF}

function Sign(X: Float): Longint;
begin
  if X > 0.0 then
    Result := 1
  else
  if X < 0.0 then
    Result := -1
  else
    Result := 0;
end;

(*
function Pythagoras(X, Y: Float): Float;
var
  AbsX, AbsY: Float;
begin
  AbsX := Abs(X);
  AbsY := Abs(Y);

  if AbsX > AbsY then
    Result := AbsX * Sqrt(1.0 + Sqr(AbsY / AbsX))
  else
  if AbsY = 0.0 then
    Result := 0.0
  else
    Result := AbsY * Sqrt(1.0 + Sqr(AbsX / AbsY));
end;

function Signe(X, Y: Float): Float;
begin
  if X > 0.0 then
  begin
    if Y > 0.0 then
      Result := X
    else
      Result := -X;
  end
  else
  begin
    if Y < 0.0 then
      Result := X
    else
      Result := -X;
  end;
end;

function Ackermann(A, B: Longint): Longint;
begin
  if A = 0 then
  begin
    Result := B + 1;
    Exit;
  end;

  if B = 0 then
    Result := Ackermann(A - 1, 1)
  else
    Result := Ackermann(A - 1, Ackermann(A, B - 1));
end;

function Fibonacci(N: Longint): Longint;
var
  I: Longint;
  P1, P2: Longint;
begin
  Assert(N >= 0);
  Result := 0;
  P1 := 1;
  P2 := 1;

  if (N = 1) or (N = 2) then
    Result := 1
  else
    for I := 3 to N do
    begin
      Result := P1 + P2;
      P1 := P2;
      P2 := Result;
    end;
end;
*)





//==================================================================================================
{Ranges}

function EnsureRange(AValue, AMin, AMax: Longint): Longint;
begin
  Result := AValue;
  Assert(AMin <= AMax);
  if Result < AMin then Result := AMin;
  if Result > AMax then Result := AMax;
end;

function EnsureRange(AValue, AMin, AMax: Int64): Int64;
begin
  Result := AValue;
  Assert(AMin <= AMax);
  if Result < AMin then Result := AMin;
  if Result > AMax then Result := AMax;
end;

function EnsureRange(AValue, AMin, AMax: Float): Float;
begin
  Result := AValue;
  Assert(AMin <= AMax);
  if Result < AMin then Result := AMin;
  if Result > AMax then Result := AMax;
end;



function IsInRange(AValue, AMin, AMax: Int64): Boolean;
begin
  Assert(AMin <= AMax);
  Result := (AValue >= AMin) and (AValue <= AMax)
end;

function IsInRange(AValue, AMin, AMax: Float): Boolean;
begin
  Assert(AMin <= AMax);
  Result := (AValue >= AMin) and (AValue <= AMax)
end;

function IsInRange(AValue, AMin, AMax: Longint): Boolean;
begin
  Assert(AMin <= AMax);
  Result := (AValue >= AMin) and (AValue <= AMax)
end;



(*
function IsInAngles(Ang: Float; Ang1, Ang2: Float; {ARobust: Boolean = False;} const Epsilon: Float = 1.0E-03): Boolean;
var
  LIsEq: Boolean;
begin
  Ang  := FixAngle(Ang);
  Ang1 := FixAngle(Ang1);
  Ang2 := FixAngle(Ang2);

  LIsEq := IsEqual(Ang, Ang1, Epsilon) or
           IsEqual(Ang, Ang2, Epsilon);

  if ARobust then
  begin
    if LIsEq then
    begin
      Result := False;
      Exit; //======>>>>>
    end;
  end
  else begin
    Result := LIsEq;
  end;

  if not Result then
  begin
    if Ang1 <= Ang2 then
      Result := (Ang > Ang1) and (Ang < Ang2)
    else
      Result := not ((Ang < Ang1) and (Ang > Ang2));
  end;
end;
*)



function IsInAngles(Ang: Float; Ang1, Ang2: Float; const Epsilon: Float = 1.0E-04): Boolean;
begin
  Ang  := FixAngle(Ang);
  Ang1 := FixAngle(Ang1);
  Ang2 := FixAngle(Ang2);

  Result := IsEqual(Ang, Ang1, Epsilon) or
            IsEqual(Ang, Ang2, Epsilon);

  if not Result then
  begin
    if Ang1 <= Ang2 then
      Result := (Ang > Ang1) and (Ang < Ang2)
    else
      Result := not ((Ang < Ang1) and (Ang > Ang2));
  end;
end;

//function IsRobustInAngles(Ang: Float; Ang1, Ang2: Float; const Epsilon: Float = 1.0E-06): Boolean;
//begin
//  Ang  := FixAngle(Ang);
//  Ang1 := FixAngle(Ang1);
//  Ang2 := FixAngle(Ang2);
//
//  if IsEqual(Ang, Ang1, Epsilon) or
//     IsEqual(Ang, Ang2, Epsilon) then
//  begin
//    Result := False;
//    Exit; //=====>>>
//  end;
//
//  if Ang1 <= Ang2 then
//    Result := (Ang > Ang1) and (Ang < Ang2)
//  else
//    Result := not ((Ang < Ang1) and (Ang > Ang2));
//end;


function MidAngle(Ang1, Ang2: Float): Float;
var
  A: Float;
begin
  A := FixAngle(Ang2 - Ang1);
  Result := FixAngle(Ang1 + A / 2);
end;





//==================================================================================================
{ Algebraic equation }


procedure FInitEqResult(var AVal: TEqResult);   {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
var
  I: Integer;
begin
  AVal.L := 0;
  for I := Low(AVal.X) to High(AVal.X) do AVal.X[I] := 0.0;
end;

// A*X^2 + B*X + C = 0
function Equation(A, B, C: Extended): TEqResult;
var
  Dt, A2: Extended;
begin
  Result.L := 0;
  FInitEqResult(Result);

  if IsEqual(A, 0) then
  begin
    if NotEqual(B, 0) then
    begin
      Result.X[0] := - C / B;
      Result.L := 1;
    end;
    Exit; //=====>>>>
  end;

  Dt := B * B - 4 * A * C;
  if IsEqual(Dt, 0) then Dt := 0;

  if Dt >= 0 then
  begin
    A2 := A + A;
    B := -B;
    if IsEqual(Dt, 0) then
    begin
      Result.X[0] := B / A2;
      Result.L := 1;
    end
    else
    begin
      Dt := Sqrt(Dt);
      Result.X[0] := (B + Dt) / A2;
      Result.X[1] := (B - Dt) / A2;
      Result.L := 2;
    end;
  end;
end;


{
盛金公式:

  一元三次方程aX^3+bX^2+cX+d=0,（a,b,c,d∈R,且a<>0）
  重根判别式：A=b^2－3ac; B=bc－9ad; C=c^2－3bd,
  总判别式：Δ=B^2－4AC

  当A=B=0时,盛金公式1：
  X1=X2=X3=－b/(3a)=－c/b=－3d/c

  当Δ=B^2－4AC>0时,盛金公式2：
  X1 = (－b－(Y1)^(1/3)－(Y2)^(1/3))/(3a);
  X2,X3 = (－2b+(Y1)^(1/3)+(Y2)^(1/3))/(6a) ± i3^(1/2)((Y1)^(1/3)－(Y2)^(1/3))/(6a),
  其中Y1,Y2 = Ab+3a(－B±(B^2－4AC)^(1/2))/2,  i^2=－1

  当Δ=B^2－4AC=0时,盛金公式3：
  X1=－b/a+K; X2=X3=－K/2,　
  其中K=B/A,(A<>0)

  当Δ=B^2－4AC<0时,盛金公式4：
  X1=(－b－2A^(1/2)cos(θ/3))/(3a);
  X2,X3=(－b+A^(1/2)(cos(θ/3)±3^(1/2)sin(θ/3)))/(3a),
  其中θ=ArcCos(T), T=(2Ab－3aB)/(2A^(3/2)),  (A>0,－1<T<1)
}

// A*X^3 + B*X^2 + C*X + D = 0
function Equation(A, B, C, D: Extended): TEqResult;
var
  T, S: Extended;
  Y1, Y2, R, I: Extended;
  LA, LB, LC, LK, Dt: Extended;
begin
  Result.L := 0;
  FInitEqResult(Result);

  if IsEqual(A, 0.0) then
  begin
    Result := Equation(B, C, D);
    Exit; //=====>>>>
  end;

  LA := B*B - 3*A*C;
  LB := B*C - 9*A*D;
  LC := C*C - 3*B*D;
  Dt := LB*LB - 4*LA*LC;

  if IsEqual(LA, 0.0) and IsEqual(LB, 0.0) then // X1=X2=X3=－b/(3a)=－c/b=－3d/c
  begin
    Result.X[0] := -B/(3*A);
    Result.X[1] := -C/B;
    Result.X[2] := -(3*D)/C;
    Result.L := 3;
    Exit; //=====>>>>
  end;


  if IsEqual(Dt, 0) then
  begin
    if NotEqual(LA, 0.0) then
    begin
      LK := LB/LA;
      Result.X[0] := -B/A + LK;
      Result.X[1] := -LK/2;
      Result.X[2] := -LK/2;
      Result.L := 2;
    end
  end
  else if Dt > 0 then
  begin
    Y1 := LA*B + 3*A * (-LB + Sqrt(LB*LB - 4*LA*LC) )/2;
    Y2 := LA*B + 3*A * (-LB - Sqrt(LB*LB - 4*LA*LC) )/2;

    R := (-2*B + Power(Y1, 1/3) + Power(Y2, 1/3)) / (6*A);
    I := Sqrt(3) * (Power(Y1, 1/3) - Power(Y2, 1/3)) / (6*A);

    Result.X[0] := (-B - Power(Y1, 1/3) - Power(Y2, 1/3)) / (3*A);
    Result.X[1] := R + {i}I;
    Result.X[2] := R - {i}I;

    Result.L := 1;
  end
  else if Dt < 0 then
  begin
    T := (2*LA*B - 3*A*LB) / (2*Power(LA,(3/2)));
    if (T >= -1.0) and (T <= 1.0) and (LA > 0) then
    begin
      S := ArcCos(T);
      Result.X[0] := (-B - 2*Sqrt(LA)*Cos(S/3))/(3*A);
      Result.X[1] := (-B + Sqrt(LA) * (Cos(S/3)  +  Sqrt(3)*Sin(S/3))) / (3*A);
      Result.X[2] := (-B + Sqrt(LA) * (Cos(S/3)  -  Sqrt(3)*Sin(S/3))) / (3*A);

      Result.L := 3;
    end;
  end;
end;




{
Ferrari公式:
aX^4 + bX^3 + cX^2 + dX + e = 0

令a=1，则
X^4 + bX^3 + cX^2 + dX + e = 0，

此方程是以下两个一元二次方程的解;
2X^2 + (b+M)X + 2(Y+N/M) = 0;
2X^2 + (b-M)X + 2(Y-N/M) = 0;

其中
M = Sqrt(8Y+b^2-4c);
N = bY-d;   (M<>0);

Y是一元三次方程
8Y^3 - 4cY^2 - (8e-2bd)Y -e(b^2-4c)-d^2 = 0  的任一实根;

}
// A*X^4 + B*X^3 + C*X^2 + D*X + E = 0
function Equation(A, B, C, D, E: Extended): TEqResult;
var
  I: Integer;
  LB, LC, LD, LE: Extended;
  YEq, Eq1, Eq2: TEqResult;
  YB, YC, YD, Y, M, N: Extended;
begin
  Result.L := 0;
  FInitEqResult(Result);

  if IsEqual(A, 0) then
  begin
    Result := Equation(B, C, D, E);
    Exit; //=====>>>>
  end;

  LB := B/A;  LC := C/A;  LD := D/A;  LE := E/A;

  YB := (-4*LC)/8;
  YC := (2*LB*LD - 8*LE)/8;
  YD := (-LE*(LB*LB - 4*LC) - LD*LD)/8;
  YEq := Equation(1, YB, YC, YD);

  N := 0.0;
  M := 0.0;
  Y := 0.0;
  for I := 0 to YEq.L - 1 do
  begin
    Y := YEq.X[I];
    M := Power((8*Y + LB*LB - 4*LC), 1/2);
    N := LB*Y - LD;
    if not IsEqual(M, 0) then Break;
  end;

  if IsEqual(M, 0) then Exit; //=====>>>

  Eq1 := Equation(2, (LB+M), 2*(Y + N/M) );
  Eq2 := Equation(2, (LB-M), 2*(Y - N/M) );

  Result := Eq1;

  if Eq2.L = 1 then
  begin
    Result.L := Result.L + 1;
    case Result.L of
      1: Result.X[0] := Eq2.X[0];
      2: Result.X[1] := Eq2.X[0];
      3: Result.X[2] := Eq2.X[0];
    end;
  end
  else if Eq2.L = 2 then
  begin
    Result.L := Result.L + 2;
    case Result.L of
      2: Result := Eq2;
      3: begin Result.X[1] := Eq2.X[0]; Result.X[2] := Eq2.X[1]; end;
      4: begin Result.X[2] := Eq2.X[0]; Result.X[3] := Eq2.X[1]; end;
    end;
  end;
end;






function LenToAng(Len: Float; R: Float): Float;
var
  Peri: Float;
begin
  Peri := 2 * PI * R;
  if Len > Peri then Result := 360.0 else Result := (Len / Peri) * 360.0;
end;


function SgnAngle(Ang: Float; Epsilon: Float = _Epsilon): Float;
var
  Return: Float;
begin
  Return := Ang;
  if (Return > 180) then Return := Return - 180;
  if IsEqual(Return, 180.0, Epsilon) then Return := 0.0;
  Result := Return;
end;





function TrimPoints(APnts: TPoint2DArray; Epsilon: Float = _Epsilon; AAllowFunc: TUdPointBoolFunc = nil): TPoint2DArray;
type
  TPointerDyncArray = array of Pointer;
var
  L: Integer;
  I, J: Integer;
  IPnt, JPnt: PPoint2D;
  LPnts: TPointerDyncArray;
  LAllow: Boolean;
begin
  Result := nil;

  System.SetLength(LPnts, System.Length(APnts));
  try
    for I := 0 to System.Length(APnts) - 1 do
    begin
      IPnt := New(PPoint2D);
      IPnt^ := APnts[I];

      LPnts[I] := IPnt;
    end;

    for I := 0 to System.Length(LPnts) - 2 do
    begin
      IPnt := LPnts[I];
      if not Assigned(IPnt) then Continue;

      for J := I + 1 to System.Length(LPnts) - 1 do
      begin
        JPnt := LPnts[J];
        if not Assigned(JPnt) then Continue;

        if IsEqual(IPnt^, JPnt^, Epsilon) then
        begin
          LAllow := True;
          if Assigned(AAllowFunc) then LAllow := AAllowFunc(JPnt^);

          if LAllow then
          begin
            Dispose(JPnt);
            LPnts[J] := nil;
          end;
        end;
      end;
    end;

    L := 0;
    for I := 0 to System.Length(LPnts) - 1 do
    begin
      IPnt := LPnts[I];
      if not Assigned(IPnt) then Continue;

      System.SetLength(Result, L + 1);
      Result[L] := IPnt^;

      L := L + 1;
    end;

  finally
    for I := System.Length(LPnts) - 1 downto 0 do
      if LPnts[I] <> nil then Dispose(PPoint2D(LPnts[I]));
    LPnts := nil;
  end;
end;


(*
  function _LayDistance(P1, P2: TPoint2D): Float;
  var
    Dx, Dy: Float;
  begin
    Dx := (P2.X - P1.X);
    Dy := (P2.Y - P1.Y);
    Result := Dx * Dx + Dy * Dy;
  end;

function SortPoints(var A: TPoint2DArray; B: TPoint2D): Boolean;
var
  I: Integer;
  J: Integer;
  T: TPoint2D;
begin
  Result := False;
  if System.Length(A) <= 0 then Exit;

  for I := Low(A) to High(A) - 1 do
  begin
    for J := High(A) downto I + 1 do
    begin
      if _LayDistance(A[I], B) > _LayDistance(A[J], B) then
      begin
        T := A[I];
        A[I] := A[J];
        A[J] := T;
      end;
    end;
  end;

  Result := True;
end;

function SortPoints(var A: TPoint2DArray; Arc: TArc2D): Boolean;

 function _GetAngle(P1, P2: TPoint2D): double;
 begin
   Result := -1;
   if (IsEqual(_LayDistance(P1, P2), 0.0, 1E-04)) then Exit;

   Result := FixAngle(ArcTan2D(P2.Y - P1.Y, P2.X - P1.X));
 end;

var
  I: Integer;
  J: Integer;
  T: TPoint2D;
begin
  Result := False;
  if System.Length(A) <= 0 then Exit;

  if Arc.IsCW then
  begin
    for I := Low(A) to High(A) - 1 do
    begin
      for J := High(A) downto I + 1 do
      begin
        if FixAngle(Arc.Ang2 - _GetAngle(Arc.Cen, A[I]) ) >
           FixAngle(Arc.Ang2 - _GetAngle(Arc.Cen, A[J]) ) then
        begin
          T := A[I];
          A[I] := A[J];
          A[J] := T;
        end;
      end;
    end;
  end
  else begin
    for I := Low(A) to High(A) - 1 do
    begin
      for J := High(A) downto I + 1 do
      begin
        if FixAngle(_GetAngle(Arc.Cen, A[I]) - Arc.Ang1 ) >
           FixAngle(_GetAngle(Arc.Cen, A[J]) - Arc.Ang1 ) then
        begin
          T := A[I];
          A[I] := A[J];
          A[J] := T;
        end;
      end;
    end;
  end;

  Result := True;
end;

function SortPoints(var A: TPoint2DArray; Ell: TEllipse2D): Boolean;
var
  I: Integer;
  J: Integer;
  T: TPoint2D;
begin
  Result := False;
  if System.Length(A) <= 0 then Exit;

  if Ell.IsCW then
  begin
    for I := Low(A) to High(A) - 1 do
    begin
      for J := High(A) downto I + 1 do
      begin
        if FixAngle( Ell.Ang2 - CenAngToEllAng(Ell.Rx, Ell.Ry, GetAngle(Ell.Cen, A[I]) - Ell.Rot) ) >
           FixAngle( Ell.Ang2 - CenAngToEllAng(Ell.Rx, Ell.Ry, GetAngle(Ell.Cen, A[J]) - Ell.Rot) ) then
        begin
          T := A[I];
          A[I] := A[J];
          A[J] := T;
        end;
      end;
    end;
  end
  else begin
    for I := Low(A) to High(A) - 1 do
    begin
      for J := High(A) downto I + 1 do
      begin
        if FixAngle( CenAngToEllAng(Ell.Rx, Ell.Ry, GetAngle(Ell.Cen, A[I]) - Ell.Rot) - Ell.Ang1 ) >
           FixAngle( CenAngToEllAng(Ell.Rx, Ell.Ry, GetAngle(Ell.Cen, A[J]) - Ell.Rot) - Ell.Ang1 ) then
        begin
          T := A[I];
          A[I] := A[J];
          A[J] := T;
        end;
      end;
    end;
  end;

  Result := True;
end;

*)



//---------------------------------------------------------------------

function InvalidPoint(ErrValue: Float = _ErrValue): TPoint2D;
begin
  Result.X := ErrValue;
  Result.Y := ErrValue;
end;

function IsValidPoint(Pnt: TPoint2D; ErrValue: Float = _ErrValue): Boolean;
begin
  Result := NotEqual(Pnt.X, ErrValue) and NotEqual(Pnt.Y, ErrValue);
end;

procedure InitRect(var ARect: TRect2D);
begin
  ARect.X1 := 0; ARect.Y1 := 0;
  ARect.X2 := 0; ARect.Y2 := 0;
end;

function IsValidRect(ARect: TRect2D): Boolean;
begin
  Result := (ARect.X2 >= ARect.X1) and (ARect.Y2 >= ARect.Y1) and
            not (IsEqual(ARect.X2, ARect.X1) and IsEqual(ARect.Y2, ARect.Y1));
end;

//function RectEdge(Rect: TRect2D; Edge:Integer): TSegment2D;
//begin
//  case Edge of
//    1: Result := Segment2D(Rect.X1, Rect.Y1, Rect.X2, Rect.Y1);
//    2: Result := Segment2D(Rect.X2, Rect.Y1, Rect.X2, Rect.Y2);
//    3: Result := Segment2D(Rect.X2, Rect.Y2, Rect.X1, Rect.Y2);
//    4: Result := Segment2D(Rect.X1, Rect.Y2, Rect.X1, Rect.Y1);
//  end;
//end;

procedure InitBound(var ABound: TBound2D);
begin
  ABound[0].X := 0;    ABound[0].Y := 0;
  ABound[1].X := 0;    ABound[1].Y := 0;
  ABound[2].X := 0;    ABound[2].Y := 0;
  ABound[3].X := 0;    ABound[3].Y := 0;
end;

function IsValidBound(ABound: TBound2D): Boolean;
begin
  if IsEqual(ABound[0], ABound[1]) and IsEqual(ABound[1], ABound[2]) and IsEqual(ABound[2], ABound[3]) then
    Result := False
  else
    Result := True;
end;




(*
function IsInArray(const AValue: Longint; AnArray: TIntArray): Boolean;
var
  I: Longint;
begin
  Result := False;

  if System.Length(AnArray) > 0 then
  begin
    for I := Low(AnArray) to High(AnArray) do
    begin
      Result := AValue = AnArray[I];
      if Result then Break;
    end;
  end;
end;

function IsInArray(const AValue: Longint; AnArray: TIntArray; out Index: Integer): Boolean;
var
  I: Longint;
begin
  Result := False;
  Index := -1;

  if System.Length(AnArray) > 0 then
  begin
    for I := Low(AnArray) to High(AnArray) do
    begin
      Index := I;
      Result := AValue = AnArray[I];
      if Result then Break;
    end;
  end;
end;


function IsInArray(const AValue: Float; AnArray: TFloatArray): Boolean;
var
  I: Longint;
begin
  Result := False;

  if System.Length(AnArray) > 0 then
  begin
    for I := Low(AnArray) to High(AnArray) do
    begin
      Result := IsEqual(AValue, AnArray[I]);
      if Result then Break;
    end;
  end;
end;

function IsInArray(const AValue: Float; AnArray: TFloatArray; out Index: Integer): Boolean;
var
  I: Longint;
begin
  Result := False;
  Index := -1;

  if System.Length(AnArray) > 0 then
  begin
    for I := Low(AnArray) to High(AnArray) do
    begin
      Index := I;
      Result := IsEqual(AValue, AnArray[I]);
      if Result then Break;
    end;
  end;
end;
*)


//==================================================================================================

procedure InitTrigonFuncTables;
var
  I: Longint;
begin
  System.SetLength(CosTable, 361);
  System.SetLength(SinTable, 361);
  System.SetLength(TanTable, 361);
  for I := 0 to 360 do
  begin
    CosTable[I] := Cos(I * _PIDiv180);
    SinTable[I] := Sin(I * _PIDiv180);
    TanTable[I] := Tan(I * _PIDiv180);
  end;
end;



initialization
  InitTrigonFuncTables;

finalization
  System.SetLength(SinTable, 0); SinTable := nil;
  System.SetLength(CosTable, 0); CosTable := nil;
  System.SetLength(TanTable, 0); TanTable := nil;


end.