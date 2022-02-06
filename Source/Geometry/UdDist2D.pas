{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDist2D;

{$I UdGeoDefs.INC}

interface

uses
  {$IFDEF UdTypes}UdTypes ,{$ENDIF} UdGTypes;

type
  TUdDist2D = class
  public
    class function Distance(X1, Y1, X2, Y2: Float): Float; overload;
    class function Distance(Pnt1, Pnt2: TPoint2D): Float; overload;
    class function Distance(Seg: TSegment2D): Float; overload;
    class function Distance(Arc: TArc2D): Float; overload;
    class function Distance(R, Ang1, Ang2: Float): Float; overload;
    class function Distance(Seg: TSegarc2D): Float; overload;

    class function LayDistance(X1, Y1, X2, Y2: Float): Float; overload;
    class function LayDistance(Pnt1, Pnt2: TPoint2D): Float; overload;
    class function ManDistance(X1, Y1, X2, Y2: Float): Float; overload;
    class function ManDistance(Pnt1, Pnt2: TPoint2D): Float; overload;

    class function LayDistanceSegments(x1,y1, x2,y2, x3,y3, x4,y4: Float): Float; overload;
    class function LayDistanceSegments(Seg1, Seg2: TSegment2D): Float; overload;
    class function DistanceSegments(Seg1, Seg2: TSegment2D): Float;

    class function LayDistanceLines(x1,y1, x2,y2, x3,y3, x4,y4: Float): Float; overload;
    class function LayDistanceLines(Line1, Line2: TLine2D): Float; overload;
    class function DistanceLines(Line1, Line2: TLine2D): Float;



    //----------------------------------------------------------------

    class function DistanceToRay(Px,Py: Float; Ray: TRay2D): Float; overload;
    class function DistanceToRay(Pnt: TPoint2D; Ray: TRay2D): Float; overload;

    class function DistanceToLine(Px,Py: Float; Ln: TLineK): Float; overload;
    class function DistanceToLine(Pnt: TPoint2D; Ln: TLineK): Float; overload;

    class function DistanceToLine(Px,Py, X1,Y1, X2,Y2: Float): Float; overload;
    class function DistanceToLine(Pnt: TPoint2D; Ln: TLine2D): Float; overload;

    class function DistanceToSegment(Px,Py, X1,Y1, X2,Y2:Float; out Idx: Integer): Float; overload;
    class function DistanceToSegment(Pnt: TPoint2D; Seg: TSegment2D; out Idx: Integer): Float; overload;

    class function DistanceToSegment(Px,Py, X1,Y1, X2,Y2:Float): Float; overload;
    class function DistanceToSegment(Pnt: TPoint2D; Seg: TSegment2D): Float; overload;

    class function DistanceToRect(Px,Py, X1,Y1, X2,Y2:Float): Float; overload;
    class function DistanceToRect(Pnt: TPoint2D; Rect: TRect2D): Float; overload;

    class function DistanceToPolygon(Pnt:TPoint2D; Poly: TPoint2DArray): Float;

    class function DistanceToArc(Pnt: TPoint2D; Arc: TArc2D): Float;
    class function DistanceToCircle(Pnt: TPoint2D; Cir: TCircle2D): Float;
    class function DistanceToEllipse(Pnt: TPoint2D; Ell: TEllipse2D): Float;

    class function DistanceToSegarc(Pnt: TPoint2D; Segarc: TSegarc2D): Float;
    class function DistanceToSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray): Float;

  end;

  
implementation

uses
  UdMath, UdGeo2D;



class function TUdDist2D.Distance(X1, Y1, X2, Y2: Float): Float;
var
  Dx, Dy: Float;
begin
  Dx := (X2 - X1);
  Dy := (Y2 - Y1);
  Result := Sqrt(Dx * Dx + Dy * Dy);
end;

class function TUdDist2D.Distance(Pnt1, Pnt2: TPoint2D): Float;
begin
  Result := Distance(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y);
end;


class function TUdDist2D.Distance(Seg: TSegment2D): Float;
begin
  Result := Distance(Seg.P1, Seg.P2);
end;

class function TUdDist2D.Distance(R, Ang1, Ang2: Float): Float;
var
  DA: Float;
begin
  DA := FixAngle(Ang2 - Ang1);
  Result := (2 * PI * R) * (DA / 360.0);
end;

class function TUdDist2D.Distance(Arc: TArc2D): Float;
begin
  Result := Distance(Arc.R, Arc.Ang1, Arc.Ang2);
end;


class function TUdDist2D.Distance(Seg: TSegarc2D): Float;
begin
  if Seg.IsArc then
    Result := Distance(Seg.Arc)
  else
    Result := Distance(Seg.Seg);
end;







class function TUdDist2D.LayDistance(X1, Y1, X2, Y2: Float): Float;
var
  Dx, Dy: Float;
begin
  Dx := (X2 - X1);
  Dy := (Y2 - Y1);
  Result := Dx * Dx + Dy * Dy;
end;

class function TUdDist2D.LayDistance(Pnt1, Pnt2: TPoint2D): Float;
begin
  Result := LayDistance(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y);
end;



class function TUdDist2D.ManDistance(X1, Y1, X2, Y2: Float): Float;
begin
  Result := Abs(X2 - X1) + Abs(Y2 - Y1);
end;

class function TUdDist2D.ManDistance(Pnt1, Pnt2: TPoint2D): Float;
begin
  Result := ManDistance(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y);
end;




class function TUdDist2D.LayDistanceSegments(X1,Y1, X2,Y2, X3,Y3, X4,Y4: Float): Float;
var
  uX : Float;
  uY : Float;
  vX : Float;
  vY : Float;
  wX : Float;
  wY : Float;
  A  : Float;
  B  : Float;
  C  : Float;
  D  : Float;
  E  : Float;
  Dt : Float;
  sC : Float;
  sN : Float;
  sD : Float;
  tC : Float;
  tN : Float;
  tD : Float;
  dX : Float;
  dY : Float;
begin
  uX := X2 - X1;
  uY := Y2 - Y1;

  vX := X4 - X3;
  vY := Y4 - Y3;

  wX := X1 - X3;
  wY := Y1 - Y3;

  A  := (uX * uX + uY * uY);
  B  := (uX * vX + uY * vY);
  C  := (vX * vX + vY * vY);
  D  := (uX * wX + uY * wY);
  E  := (vX * wX + vY * wY);
  Dt := A * C - B * B;

  sD := Dt;
  tD := Dt;

  if IsEqual(Dt,0.0) then
  begin
    sN := 0.0;
    sD := 1.0;
    tN := E;
    tD := C;
  end
  else
  begin
    sN := (B * E - C * D);
    tN := (A * E - B * D);
    if sN < 0.0 then
    begin
      sN := 0.0;
      tN := E;
      tD := C;
    end
    else if sN > sD then
    begin
      sN := sD;
      tN := E + B;
      tD := C;
    end;
  end;

  if tN < 0.0 then
  begin
    tN := 0.0;
    if -D < 0.0 then
      sN := 0.0
    else if -D > A then
      sN := sD
    else
    begin
      sN := -D;
      sD := A;
    end;
  end
  else if tN > tD  then
  begin
    tN := tD;
    if (-D + B) < 0.0 then
      sN := 0
    else if (-D + B) > A then
      sN := sD
    else
    begin
      sN := (-D + B);
      sD := A;
    end;
  end;

  if IsEqual(sN,0.0) then
    sC := 0.0
  else
    sC := sN / sD;

  if IsEqual(tN,0.0) then
    tC := 0.0
  else
    tC := tN / tD;

  dX := wX + (sC * uX) - (tC * vX);
  dY := wY + (sC * uY) - (tC * vY);
  Result := dX * dX + dY * dY;
end;

class function TUdDist2D.LayDistanceSegments(Seg1, Seg2: TSegment2D): Float;
begin
  Result := LayDistanceSegments(Seg1.P1.X, Seg1.P1.Y, Seg1.P2.X, Seg1.P2.Y,
                                Seg2.P1.X, Seg2.P1.Y, Seg2.P2.X, Seg2.P2.Y);
end;

class function TUdDist2D.DistanceSegments(Seg1, Seg2: TSegment2D): Float;
begin
  Result := Sqrt(LayDistanceSegments(Seg1, Seg2));
end;

class function TUdDist2D.LayDistanceLines(X1,Y1, X2,Y2, X3,Y3, X4,Y4: Float): Float;
var
  uX : Float;
  uY : Float;
  vX : Float;
  vY : Float;
  wX : Float;
  wY : Float;
  A  : Float;
  B  : Float;
  C  : Float;
  D  : Float;
  E  : Float;
  Dt : Float;
  sc : Float;
  tC : Float;
  dX : Float;
  dY : Float;
begin
  uX := X2 - X1;
  uY := Y2 - Y1;

  vX := X4 - X3;
  vY := Y4 - Y3;

  if NotEqual(uX * vY,uY * vX) then
  begin
    Result := 0.0;
    Exit;
  end;

  wX := X1 - X3;
  wY := Y1 - Y3;

  A  := (uX * uX + uY * uY);
  B  := (uX * vX + uY * vY);
  C  := (vX * vX + vY * vY);
  D  := (uX * wX + uY * wY);
  E  := (vX * wX + vY * wY);
  Dt := A * C - B * B;

  if IsEqual(Dt,0.0) then
  begin
    sc := 0.0;
    if B > C then
      tC := D / B
    else
      tC  := E /C;
  end
  else
  begin
    sc := (B * E - C * D) / Dt;
    tC := (A * E - B * D) / Dt;
  end;

  dX := wX + (sc * uX) - (tC * vX);
  dY := wY + (sc * uY) - (tC * vY);
  Result := dX * dX + dY * dY;
end;

class function TUdDist2D.LayDistanceLines(Line1, Line2: TLine2D): Float;
begin
  Result := LayDistanceLines(Line1.P1.X, Line1.P1.Y, Line1.P2.X, Line1.P2.Y,
                             Line2.P1.X, Line2.P1.Y, Line2.P2.X, Line2.P2.Y);
end;

class function TUdDist2D.DistanceLines(Line1, Line2: TLine2D): Float;
begin
  Result := Sqrt(LayDistanceLines(Line1, Line2));
end;









//-------------------------------------------------------------------------------------------------


class function TUdDist2D.DistanceToRay(Px, Py: Float; Ray: TRay2D): Float;
var
  Pnt: TPoint2D;
begin
  Pnt := ClosestLinePoint(Px,Py, LineK(Ray.Base, Ray.Ang));

  if IsEqual(GetAngle(Ray.Base, Pnt), Ray.Ang, 1) then
    Result := Distance(Pnt.X, Pnt.Y, Px, Py)
  else
    Result := Distance(Ray.Base.X, Ray.Base.Y, Px, Py);
end;

class function TUdDist2D.DistanceToRay(Pnt: TPoint2D; Ray: TRay2D): Float;
begin
  Result := DistanceToRay(Pnt.X, Pnt.Y, Ray);
end;


class function TUdDist2D.DistanceToLine(Px,Py: Float; Ln: TLineK): Float;
var
  Pnt: TPoint2D;
begin
  Pnt := ClosestLinePoint(Px,Py, Ln);
  Result := Distance(Pnt.X, Pnt.Y, Px, Py);
end;

class function TUdDist2D.DistanceToLine(Pnt: TPoint2D; Ln: TLineK): Float;
begin
  Result := DistanceToLine(Pnt.X, Pnt.Y, Ln);
end;



class function TUdDist2D.DistanceToLine(Px,Py, X1,Y1, X2,Y2: Float): Float;
var
  Pnt: TPoint2D;
begin
  Pnt := ClosestLinePoint(Px,Py, X1,Y1, X2,Y2);
  Result := Distance(Pnt.X, Pnt.Y, Px, Py);
end;

class function TUdDist2D.DistanceToLine(Pnt: TPoint2D; Ln: TLine2D): Float;
begin
  Result := DistanceToLine(Pnt.X, Pnt.Y, Ln.P1.X,  Ln.P1.Y, Ln.P2.X,  Ln.P2.Y);
end;






class function TUdDist2D.DistanceToSegment(Px,Py, X1,Y1, X2,Y2: Float; out Idx: Integer): Float;
var
  Ratio : Float;
  Dx    : Float;
  Dy    : Float;
begin
  Idx := 0;
  if IsDegenerate(X1, Y1, X2, Y2) then
    Result := Distance(Px, Py, X1, Y1)
  else begin
    Dx    := X2 - X1;
    Dy    := Y2 - Y1;
    Ratio := ((Px - X1) * Dx + (Py - Y1) * Dy) / (Dx * Dx + Dy * Dy);
    if Ratio < 0.0 then
    begin
      Idx := 1;
      Result := Distance(Px, Py, X1, Y1);
    end
    else if Ratio > 1.0 then
    begin
      Idx := 2;
      Result := Distance(Px, Py, X2, Y2);
    end
    else
      Result := Distance(Px, Py, X1 + (Ratio * Dx), Y1 + (Ratio * Dy));
  end;
end;

class function TUdDist2D.DistanceToSegment(Pnt: TPoint2D; Seg: TSegment2D; out Idx: Integer): Float;
begin
  Result := DistanceToSegment(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Idx);
end;


class function TUdDist2D.DistanceToSegment(Px,Py, X1,Y1, X2,Y2: Float): Float;
var
  Idx: Integer;
begin
  Result := DistanceToSegment(Px,Py, X1,Y1, X2,Y2, Idx);
end;

class function TUdDist2D.DistanceToSegment(Pnt: TPoint2D; Seg: TSegment2D): Float;
begin
  Result := DistanceToSegment(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y);
end;


class function TUdDist2D.DistanceToRect(Px,Py, X1,Y1, X2,Y2:Float): Float;
var
  Pnt: TPoint2D;
begin
  Pnt := ClosestRectPoint(Px,Py, X1,Y1, X2,Y2);
  Result := Distance(Pnt, Point2D(Px, Py));
end;


class function TUdDist2D.DistanceToRect(Pnt: TPoint2D; Rect: TRect2D): Float;
var
  P: TPoint2D;
begin
  P := ClosestRectPoint(Pnt, Rect);
  Result := Distance(Pnt, P);
end;


class function TUdDist2D.DistanceToPolygon(Pnt: TPoint2D; Poly: TPoint2DArray): Float;
var
  I: Integer;
  J: Integer;
  TempDist: Float;
begin
  Result := 0.0;
  if System.Length(Poly) < 3 then Exit;   //---->>>>

  I := 0;
  J := High(Poly);

  Result := DistanceToSegment(Pnt.X, Pnt.Y, Poly[I].X, Poly[I].Y, Poly[J].X, Poly[J].Y);

  J := 0;
  for I := 1 to High(Poly) do
  begin
    TempDist := DistanceToSegment(Pnt.X, Pnt.Y, Poly[I].X, Poly[I].Y, Poly[J].X, Poly[J].Y);
    if TempDist < Result then Result := TempDist;
    J := I;
  end;
end;

class function TUdDist2D.DistanceToArc(Pnt: TPoint2D; Arc: TArc2D): Float;
var
  CP: TPoint2D;
begin
  CP := ClosestArcPoint(Pnt, Arc);
  Result := Distance(CP, Pnt);
end;

class function TUdDist2D.DistanceToCircle(Pnt: TPoint2D; Cir: TCircle2D): Float;
var
  CP: TPoint2D;
begin
  CP := ClosestCirclePoint(Pnt, Cir);
  Result := Distance(CP, Pnt);
end;

class function TUdDist2D.DistanceToEllipse(Pnt: TPoint2D; Ell: TEllipse2D): Float;
var
  CP: TPoint2D;
begin
  CP := ClosestEllipsePoint(Pnt, Ell);
  Result := Distance(CP, Pnt);
end;

class function TUdDist2D.DistanceToSegarc(Pnt: TPoint2D; Segarc: TSegarc2D): Float;
begin
  if Segarc.IsArc then
    Result := DistanceToArc(Pnt, Segarc.Arc)
  else
    Result := DistanceToSegment(Pnt, Segarc.Seg);
end;

class function TUdDist2D.DistanceToSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray): Float;
var
  I: Integer;
  D: Float;
begin
  Result := 0.0;
  if System.Length(Segarcs) < 0 then Exit;   //---->>>>

  Result := DistanceToSegarc(Pnt, Segarcs[0]);

  for I := 1 to High(Segarcs) do
  begin
    D := DistanceToSegarc(Pnt, Segarcs[I]);
    if D < Result then Result := D;
  end;
end;



end.