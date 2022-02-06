
{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdVector2D;

{$I UdDefs.INC}

interface

uses
  UdGTypes;


function Vector2D(X, Y: Float): TVector2D; overload;
function Vector2D(Pnt: TPoint2D): TVector2D; overload;

procedure Normalize(var AVec: TVector2D);

function Extrusion(P1, P2: TPoint2D): TVector2D;

function Addition(A: TVector2D; B: TVector2D): TVector2D;
function Subtraction(A: TVector2D; B: TVector2D): TVector2D;
function Multiply(A: TVector2D; Len: Double): TVector2D;
function Division(P: TVector2D; Value: Double): TVector2D;


implementation

uses
  UdMath;


function Vector2D(X, Y: Float): TVector2D;
begin
  Result.X := X;
  Result.Y := Y;
end;

function Vector2D(Pnt: TPoint2D): TVector2D;
begin
  Result.X := Pnt.X;
  Result.Y := Pnt.Y;
end;

procedure Normalize(var AVec: TVector2D);
var
  LNum: Double;
begin
  LNum := Sqrt(AVec.X * AVec.X + AVec.Y * AVec.Y);

  if IsEqual(LNum, 0.0) then
  begin
    AVec.X := 0;
    AVec.Y := 0;
  end
  else begin
    AVec.X := (AVec.X / LNum);
    AVec.Y := (AVec.Y / LNum);

    if (IsEqual(AVec.X, 0, 1E-08)) then AVec.X := 0;
    if (IsEqual(AVec.X, 1, 1E-08)) then AVec.X := 1;
    if (IsEqual(AVec.Y, 0, 1E-08)) then AVec.Y := 0;
    if (IsEqual(AVec.Y, 1, 1E-08)) then AVec.Y := 1;
  end;
end;

function Extrusion(P1, P2: TPoint2D): TVector2D;
begin
  Result.X := (P2.X - P1.X);
  Result.Y := (P2.Y - P1.Y);
  Normalize(Result);
end;

 

 

function Addition(A: TVector2D; B: TVector2D): TVector2D;
begin
   Result := Vector2D((A.X + B.X), (A.y + B.y));
end;

function Subtraction(A: TVector2D; B: TVector2D): TVector2D;
begin
  Result := Vector2D((A.X - B.X), (A.y - B.y))
end;


function Multiply(A: TVector2D; Len: Double): TVector2D;
begin
  Result := Vector2D((A.X * Len), (A.y * Len))
end;

function Division(P: TVector2D; Value: Double): TVector2D;
begin
  Result := Vector2D((P.X / Value), (P.y / Value));
end;




 


 

end.