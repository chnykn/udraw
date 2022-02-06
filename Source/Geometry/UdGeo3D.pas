unit UdGeo3D;

{$I UdGeoDefs.INC}

interface


uses
  UdGTypes;


function Orientation(Px, Py, Pz: Float; x1, Y1, Z1, X2, Y2, Z2, X3, y3, Z3: Float): Integer; overload;
function Orientation(PntP: TPoint3D; Pnt1, Pnt2, Pnt3: TPoint3D): Integer; overload;

function Signed(Px, Py, Pz: Float; x1, Y1, Z1, X2, Y2, Z2, X3, y3, Z3: Float): Float; overload;
function Signed(PntP: TPoint3D; Pnt1, Pnt2, Pnt3: TPoint3D): Float; overload;


function IsCollinear(x1, Y1, Z1, X2, Y2, Z2, X3, y3, Z3: Float): Boolean; overload;
function IsCollinear(Pnt1, Pnt2, Pnt3: TPoint3D): Boolean; overload;


function IsPntCollinear(Px, Py, Pz: Float; x1, Y1, Z1, X2, Y2, Z2: Float): Boolean; overload;
function IsPntCollinear(PntP: TPoint3D; Pnt1, Pnt2: TPoint3D): Boolean; overload;


function Distance(X1,Y1,Z1, X2,Y2,Z2: Float): Float; overload;
function Distance(Pnt1, Pnt2: TPoint3D): Float;  overload;

function VectorAngleZ(Pnt1, Pnt2: TPoint3D): Float;
function Point3D(X, Y, Z: Float): TPoint3D; overload;
function Point3D(APnt: TPoint2D; Z: Float): TPoint3D; overload;

function Point3DArray(APnts: TPoint2DArray; Z: Float): TPoint3DArray;

function DivPnt(Pnt: TPoint3D; Divisor: Float): TPoint3D;
function DivPnts(Pnts: TPoint3DArray; Divisor: Float): TPoint3DArray;
function DivPntsArray(PntsArray: TPoint3DArrays; Divisor: Float): TPoint3DArrays;

//function DiscreteHelicoid(const AHelicoid: THelicoid; const AAngleSlices: Float = 5; const AYAxisSlices: Float = 0.4): TPoint3DArrays;


implementation

uses
  UdMath, UdGeo2D; //, SysUtils, Windows;



function Orientation(Px, Py, Pz: Float; X1, Y1, Z1, X2, Y2, Z2, X3, y3, Z3: Float): Integer;
var
  PX1: Float;
  PX2: Float;
  PX3: Float;
  PY1: Float;
  PY2: Float;
  Py3: Float;
  PZ1: Float;
  PZ2: Float;
  PZ3: Float;
  Orin: Float;
begin
  PX1 := X1 - px;
  PX2 := X2 - px;
  PX3 := X3 - px;
  PY1 := Y1 - py;
  PY2 := Y2 - py;
  Py3 := y3 - py;
  PZ1 := Z1 - pz;
  PZ2 := Z2 - pz;
  PZ3 := Z3 - pz;

  Orin := PX1 * (PY2 * PZ3 - PZ2 * Py3) +
    PX2 * (Py3 * PZ1 - PZ3 * PY1) +
    PX3 * (PY1 * PZ2 - PZ1 * PY2);

  if Orin < 0.0 then
    Result := _LeftHandSide
  else if Orin > 0.0 then
    Result := _RightHandSide
  else
    Result := _NeutralOfSide;
end;

function Orientation(PntP: TPoint3D; Pnt1, Pnt2, Pnt3: TPoint3D): Integer;
begin
  Result := Orientation(PntP.X, PntP.Y, PntP.Z,
    Pnt1.X, Pnt1.Y, Pnt1.Z,
    Pnt2.X, Pnt2.Y, Pnt2.Z,
    Pnt3.X, Pnt3.Y, Pnt3.Z);
end;





function Signed(Px, Py, Pz: Float; X1, Y1, Z1, X2, Y2, Z2, X3, y3, Z3: Float): Float;
var
  PX1: Float;
  PX2: Float;
  PX3: Float;
  PY1: Float;
  PY2: Float;
  Py3: Float;
  PZ1: Float;
  PZ2: Float;
  PZ3: Float;
begin
  PX1 := X1 - px;
  PX2 := X2 - px;
  PX3 := X3 - px;
  PY1 := Y1 - py;
  PY2 := Y2 - py;
  Py3 := y3 - py;
  PZ1 := Z1 - pz;
  PZ2 := Z2 - pz;
  PZ3 := Z3 - pz;

  Result := PX1 * (PY2 * PZ3 - PZ2 * Py3) +
    PX2 * (Py3 * PZ1 - PZ3 * PY1) +
    PX3 * (PY1 * PZ2 - PZ1 * PY2);
end;


function Signed(PntP: TPoint3D; Pnt1, Pnt2, Pnt3: TPoint3D): Float;
begin
  Result := Signed(PntP.X, PntP.Y, PntP.Z,
    Pnt1.X, Pnt1.Y, Pnt1.Z,
    Pnt2.X, Pnt2.Y, Pnt2.Z,
    Pnt3.X, Pnt3.Y, Pnt3.Z);
end;




function IsCollinear(X1, Y1, Z1, X2, Y2, Z2, X3, y3, Z3: Float): Boolean;
var
  DX1: Float;
  DX2: Float;
  DY1: Float;
  DY2: Float;
  DZ1: Float;
  DZ2: Float;
  Cx: Float;
  Cy: Float;
  Cz: Float;
begin
  DX1 := X2 - X1;
  DY1 := Y2 - Y1;
  DZ1 := Z2 - Z1;
  DX2 := X3 - X1;
  DY2 := y3 - Y1;
  DZ2 := Z3 - Z1;

  Cx := (DY1 * DZ2) - (DY2 * DZ1);
  Cy := (DX2 * DZ1) - (DX1 * DZ2);
  Cz := (DX1 * DY2) - (DX2 * DY1);
  Result := IsEqual(Cx * Cx + Cy * Cy + Cz * Cz, 0.0);
end;


function IsCollinear(Pnt1, Pnt2, Pnt3: TPoint3D): Boolean; overload;
begin
  Result := IsCollinear(Pnt1.X, Pnt1.Y, Pnt1.Z,
    Pnt2.X, Pnt2.Y, Pnt2.Z,
    Pnt3.X, Pnt3.Y, Pnt3.Z);
end;






function IsPntCollinear(Px, Py, Pz: Float; X1, Y1, Z1, X2, Y2, Z2: Float): Boolean;
begin
  if (((X1 <= px) and (px <= X2)) or ((X2 <= px) and (px <= X1))) and
     (((Y1 <= py) and (py <= Y2)) or ((Y2 <= py) and (py <= Y1))) and
     (((Z1 <= pz) and (pz <= Z2)) or ((Z2 <= pz) and (pz <= Z1))) then
  begin
    Result := IsCollinear(X1, Y1, Z1, X2, Y2, Z2, Px, Py, Pz);
  end
  else
    Result := False;
end;

function IsPntCollinear(PntP: TPoint3D; Pnt1, Pnt2: TPoint3D): Boolean;
begin
  Result := IsPntCollinear(PntP.X, PntP.Y, PntP.Z,
    Pnt1.X, Pnt1.Y, Pnt1.Z,
    Pnt2.X, Pnt2.Y, Pnt2.Z );
end;




function Distance(X1,Y1,Z1, X2,Y2,Z2: Float): Float;
var
  Dx : Float;
  Dy : Float;
  Dz : Float;
begin
  Dx := X2 - X1;
  Dy := Y2 - Y1;
  Dz := Z2 - Z1;
  Result := Sqrt(Dx * Dx + Dy * Dy + Dz * Dz);
end;


function Distance(Pnt1, Pnt2: TPoint3D): Float;
begin
  Result := Distance(Pnt1.X, Pnt1.Y, Pnt1.Z,  Pnt2.X, Pnt2.Y, Pnt2.Z );
end;



function VectorAngleZ(Pnt1, Pnt2: TPoint3D): Float;
var
  HD, VD: Float;
begin
  VD := Pnt2.Z - Pnt1.Z;
  HD := UdGeo2D.Distance(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y);
  if UdMath.IsEqual(HD, 0.0) then
  begin
    if VD > 0 then Result := 90 else Result := 270;
  end
  else
    Result := UdMath.ArcTanD(VD / HD)
end;

function Point3D(X, Y, Z: Float): TPoint3D;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

function Point3D(APnt: TPoint2D; Z: Float): TPoint3D;
begin
  Result.X := APnt.X;
  Result.Y := APnt.Y;
  Result.Z := Z;
end;

function Point3DArray(APnts: TPoint2DArray; Z: Float): TPoint3DArray;
var
  I: Integer;
begin
  SetLength(Result, Length(APnts));
  for I := 0 to Length(APnts) - 1 do
  begin
    Result[I].X := APnts[I].X;
    Result[I].Y := APnts[I].Y;
    Result[I].Z := Z;
  end;
end;

function DivPnt(Pnt: TPoint3D; Divisor: Float): TPoint3D;
begin
  if (Divisor = 0) or (Divisor = 1)then
    Result := Pnt
  else
  begin
    Result.X := Pnt.X / Divisor;
    Result.Y := Pnt.Y / Divisor;
    Result.Z := Pnt.Z / Divisor;
  end;
end;

function DivPnts(Pnts: TPoint3DArray; Divisor: Float): TPoint3DArray;
var
  I: Integer;
begin
  if (Divisor = 0) or (Divisor = 1)then
    Result := Pnts
  else
  begin
    SetLength(Result, Length(Pnts));   
    for I := 0 to Length(Pnts) - 1 do
      Result[I] := DivPnt(Pnts[I], Divisor);
  end;
end;

function DivPntsArray(PntsArray: TPoint3DArrays; Divisor: Float): TPoint3DArrays;
var
  I: Integer;
begin
  if (Divisor = 0) or (Divisor = 1)then
    Result := PntsArray
  else
  begin
    SetLength(Result, Length(PntsArray)); 
    for I := 0 to Length(PntsArray) - 1 do
       Result[I] := DivPnts(PntsArray[I], Divisor);
  end;
end;


(*
function DiscreteHelicoid(const AHelicoid: THelicoid; const AAngleSlices: Float = 5; const AYAxisSlices: Float = 0.4): TPoint3DArrays;
  function DiscretePnt(AAngle: Float; ARadius: Float; ACenter: TPoint2D): TPoint2D;
  var
    LSin, LCos: Float;
  begin
    LSin := SinD(AAngle);
    LCos := CosD(AAngle);

    Result.X := ARadius * LCos + ACenter.X;
    Result.Y := ARadius * LSin + ACenter.Y;
  end;
var
  LPnt: TPoint2D;
  LCenter: TPoint2D;
  LPolygon: TPolygon2D;
  LRadius: TFloatArray;
  LPnts: TPoint3DArrays;
  I, J, L, LSlices: Integer;
  LHigh, LStartHigh, LStepHigh, LMinAngle, LMaxAngle, LValue: Float;
begin
  LCenter.X := AHelicoid.Arc.Cen.X;
  LCenter.Y := AHelicoid.Arc.Cen.Y;

  //LMinAngle := Min(AHelicoid.Arc.Ang1, AHelicoid.Arc.Ang2);
  //LMaxAngle := Max(AHelicoid.Arc.Ang1, AHelicoid.Arc.Ang2);
  LMinAngle := AHelicoid.Arc.Ang1;  
  if not AHelicoid.Arc.IsCW then
  begin
    LStartHigh := AHelicoid.StartHigh;
    LHigh := AHelicoid.EndHigh - AHelicoid.StartHigh;
  end
  else
  begin
    LStartHigh := AHelicoid.EndHigh;
    LHigh := - AHelicoid.EndHigh + AHelicoid.StartHigh;
  end;
  LMaxAngle := AngleDelta(AHelicoid.Arc.Ang1, AHelicoid.Arc.Ang2);
  LMaxAngle := LMinAngle + LMaxAngle;


  LSlices := 0;
  LValue := LMinAngle - AAngleSlices;
  while LValue < LMaxAngle do
  begin
    LValue := LValue + AAngleSlices;
    Inc(LSlices);
  end;
  if LSlices > 1 then
    LStepHigh := LHigh / (LSlices - 1)
  else
    LStepHigh := LHigh;

    
  LPolygon := UdGeo2D.DivisionPnt(AHelicoid.Section, AYAxisSlices);

  L := Length(LPolygon) - 1;
  SetLength(LPnts, L);
  SetLength(LRadius, L);
  for I := 0 to L - 1 do
  begin
    //
    SetLength(LPnts[I], LSlices);
    LRadius[I] := AHelicoid.Arc.R + (LPolygon[I].X - AHelicoid.Center.X);

    J := 0;
    LValue := LMinAngle - AAngleSlices;
    while LValue < LMaxAngle do
    begin
      LValue := LValue + AAngleSlices;
      if LValue > LMaxAngle then
        LValue := LMaxAngle;
      LPnt := DiscretePnt(LValue, LRadius[I], LCenter);
      LPnts[I][J] := Point3D(LPnt.X, LPnt.Y, LStartHigh + LStepHigh * J + (LPolygon[I].Y - AHelicoid.Center.Y));
      Inc(J);
    end;
  end;
  Result := LPnts;
end;
*)

end.

