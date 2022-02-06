{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdRela2D;

{$I UdGeoDefs.INC}

interface

uses
  {$IFDEF UdTypes}UdTypes ,{$ENDIF} UdGTypes;

type
  TUdRela2D = class
  public
    class function IsPntInSegment(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInSegment(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntInRect(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInRect(Pnt: TPoint2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): Boolean; overload;


    class function IsPntInCircle(Px,Py, Cx,Cy, Radius: Float; const Epsilon: Float = _Epsilon): Boolean;  overload;
    class function IsPntInCircle(Px, Py: Float; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInCircle(Pnt: TPoint2D; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean; overload;


    class function FastIsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function FastIsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

    //class function IsPntInPolygon(Pnt: TPoint2D; Poly: TPointsF; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function AbsIsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function AbsIsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function FastIsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function FastIsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function FastIsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function FastIsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;


    class function IsCircleInCircle(Cir1, Cir2: TCircle2D): Boolean;

    class function IsPntInArc(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInArc(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntInChord(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInChord(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;


    class function IsPntInSegarcs(Px, Py: Float; Segarcs: TSegarc2DArray; OnIsValid: Boolean = True; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray; OnIsValid: Boolean = True; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntInEllipse(Px, Py: Float; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntInEllipse(Pnt: TPoint2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean; overload;



    //--------------------------------------------------------------------------------

    class function IsPntOnRay(Pnt: TPoint2D; Ray: TRay2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnRay(Px, Py: Float; Ray: TRay2D; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntOnLine(Pnt: TPoint2D; Ln: TLineK; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnLine(Pnt: TPoint2D; Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnLine(Px, Py: Float; Ln: TLineK; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnLine(Px, Py: Float; Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntOnSegment(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnSegment(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntOnRect(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnRect(Pnt: TPoint2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntOnCircle(Px, Py: Float; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnCircle(Px, Py: Float; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnCircle(Pnt: TPoint2D; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntOnArc(Px, Py: Float; Cx, Cy, Radius, Ang1, Ang2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnArc(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnArc(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntOnPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntOnPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntOnSegarc(Pnt: TPoint2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnSegarcs(Px, Py: Float; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsPntOnEllipse(Px, Py: Float; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsPntOnEllipse(Pnt: TPoint2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean; overload;

  end;

implementation

uses
  UdMath, UdGeo2D;




class function TUdRela2D.IsPntInSegment(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean;
var
  OK: Boolean;
  LowEpsilon: Float;
begin
  Result := False;

  LowEpsilon := Epsilon * 10;

  if IsEqual(X1, X2, LowEpsilon) then
    OK := IsEqual(X1, Px, LowEpsilon)
  else
    OK := ((X1 <= Px + LowEpsilon) and (Px - LowEpsilon <= X2)) or
          ((X2 <= Px + LowEpsilon) and (Px - LowEpsilon <= X1));

  if not OK then Exit;  //=====>>>>>

  if IsEqual(Y1, Y2, LowEpsilon) then
    OK := IsEqual(Y1, Py, LowEpsilon)
  else
    OK := ((Y1 <= Py + LowEpsilon) and (Py - LowEpsilon <= Y2)) or
          ((Y2 <= Py + LowEpsilon) and (Py - LowEpsilon <= Y1));

  if not OK then Exit; //=====>>>>>

  Result := IsCollinear(Px, Py, X1, Y1, X2, Y2, Epsilon);
end;

class function TUdRela2D.IsPntInSegment(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInSegment(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Epsilon);
end;



class function TUdRela2D.IsPntInRect(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := (X1 <= Px + Epsilon) and (X2 >= Px - Epsilon) and
            (Y1 <= Py + Epsilon) and (Y2 >= Py - Epsilon);
end;

class function TUdRela2D.IsPntInRect(Pnt: TPoint2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInRect(Pnt.X, Pnt.Y, Rect.X1, Rect.Y1, Rect.X2, Rect.Y2, Epsilon);
end;



class function TUdRela2D.IsPntInCircle(Px,Py, Cx,Cy, Radius: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  //Result := (LayDistance(Px,Py, Cx,Cy) <= (Radius * Radius));
  Result := LayDistance(Px,Py, Cx,Cy) < (Radius * Radius) + Epsilon;
end;

class function TUdRela2D.IsPntInCircle(Px, Py: Float; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInCircle(Px, Py, Circle.Cen.X, Circle.Cen.Y, Circle.R, Epsilon);
end;

class function TUdRela2D.IsPntInCircle(Pnt: TPoint2D; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInCircle(Pnt.X, Pnt.Y, Circle, Epsilon);
end;


class function TUdRela2D.FastIsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  I, J: Longint;
begin
  Result := False;
  if System.Length(Poly) < 3 then Exit; //---->>>>

  I := High(Poly);
  for J := Low(Poly) to High(Poly) do
  begin
    if ((Poly[J].Y <= Py) and (Py < Poly[I].Y)) or
       ((Poly[I].Y <= Py) and (Py < Poly[J].Y)) then
    begin
      if Px - Poly[J].X < (Poly[I].X - Poly[J].X) * (Py - Poly[J].Y) / (Poly[I].Y - Poly[J].Y) then
        Result := not Result;
    end;
    I := J;
  end;
end;


class function TUdRela2D.FastIsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := FastIsPntInPolygon(Pnt.X, Pnt.Y, Poly, Epsilon);
end;



class function TUdRela2D.IsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := False;
  If System.Length(Poly) < 3 then Exit; //---->>>>

  Result := FastIsPntInPolygon(Px, Py, Poly, Epsilon);

  if not Result and (Epsilon > _HighiEpsilon) then
    Result := IsPntOnPolygon(Px, Py, Poly, Epsilon);
end;

class function TUdRela2D.IsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInPolygon(Pnt.X, Pnt.Y, Poly, Epsilon);
end;


class function TUdRela2D.AbsIsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := False;
  If System.Length(Poly) < 3 then Exit; //---->>>>

  Result := FastIsPntInPolygon(Px, Py, Poly, Epsilon);

  if Result and (Epsilon > _HighiEpsilon) then
    Result := not IsPntOnPolygon(Px, Py, Poly, Epsilon);
end;

class function TUdRela2D.AbsIsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := AbsIsPntInPolygon(Pnt.X, Pnt.Y, Poly, Epsilon);
end;



class function TUdRela2D.IsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Integer;
begin
  Index := -1;
  Result := False;

  for I := Low(Polygons) to High(Polygons) do
  begin
    if IsPntInPolygon(X, Y, Polygons[I], Epsilon) then
    begin
      Index := I;
      Result := True;
      Break;
    end;
  end;
end;

class function TUdRela2D.IsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInPolygons(Pnt.X, Pnt.Y, Polygons, Index, Epsilon);
end;


class function TUdRela2D.IsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  N: Integer;
begin
  Result := IsPntInPolygons(X, Y, Polygons, N, Epsilon) and (N >= 0);
end;

class function TUdRela2D.IsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInPolygons(Pnt.X, Pnt.Y, Polygons, Epsilon);
end;




class function TUdRela2D.FastIsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Integer;
begin
  Index := -1;
  Result := False;

  for I := Low(Polygons) to High(Polygons) do
  begin
    if FastIsPntInPolygon(X, Y, Polygons[I], Epsilon) then
    begin
      Index := I;
      Result := True;
      Break;
    end;
  end;
end;

class function TUdRela2D.FastIsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := FastIsPntInPolygons(Pnt.X, Pnt.Y, Polygons, Index, Epsilon);
end;


class function TUdRela2D.FastIsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  N: Integer;
begin
  Result := FastIsPntInPolygons(X, Y, Polygons, N, Epsilon) and (N >= 0);
end;

class function TUdRela2D.FastIsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := FastIsPntInPolygons(Pnt.X, Pnt.Y, Polygons, Epsilon);
end;







class function TUdRela2D.IsCircleInCircle(Cir1, Cir2: TCircle2D):Boolean;
begin
 Result := IsPntInCircle(Cir1.Cen, Cir2) and (Cir1.R < Cir2.R);
end;


class function TUdRela2D.IsPntInArc(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
var
  D, A: Float;
  LPnts: TPoint2DArray;
begin
  Result := False;

  LPnts := nil;
  if Arc.Kind = akCurve then
  begin
    Result := IsPntOnArc(Px, Py, Arc, Epsilon);
    Exit; //=======>>>>
  end;

  D := Distance(Px, Py, Arc.Cen.X, Arc.Cen.Y);

  if IsEqual(D, Arc.R, Epsilon) or (D < Arc.R) then
  begin
    A := GetAngle(Arc.Cen, Point2D(Px, Py));
    Result := UdMath.IsInAngles(A, Arc.Ang1, Arc.Ang2, Epsilon);
  end;

  if Result and (Arc.Kind = akChord) then
  begin
    LPnts := ArcEndPnts(Arc);
    System.SetLength(LPnts, System.Length(LPnts) + 1);
    LPnts[High(LPnts)] := Arc.Cen;
    Result := not FastIsPntInPolygon(Px, Py, LPnts, Epsilon);
  end;
end;

class function TUdRela2D.IsPntInArc(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInArc(Pnt.X, Pnt.Y, Arc, Epsilon);
end;


class function TUdRela2D.IsPntInChord(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
var
  LArc: TArc2D;
begin
  LArc := Arc;
  LArc.Kind := akChord;
  Result := IsPntInArc(Px, Py, LArc, Epsilon);
end;

class function TUdRela2D.IsPntInChord(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInChord(Pnt.X, Pnt.Y, Arc, Epsilon);
end;

class function TUdRela2D.IsPntInSegarcs(Px, Py: Float; Segarcs: TSegarc2DArray; OnIsValid: Boolean = True; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Integer;
  LPnt: TPoint2D;
  LPolygon: TPolygon2D;
begin
  LPolygon := SamplePoints(Segarcs, True);
  Result := FastIsPntInPolygon(Px, Py, LPolygon);

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    if not Segarcs[I].IsArc then Continue;

    LPnt := MidPoint(Segarcs[I].Arc);
    if FastIsPntInPolygon(LPnt, LPolygon) then
    begin
      if Result then
      begin
        if IsPntInChord(Px, Py, Segarcs[I].Arc, 0) then
        begin
          Result := False;
          Break;
        end;
      end;
    end
    else begin
      if not Result then
      begin
        if IsPntInChord(Px, Py, Segarcs[I].Arc, Epsilon) then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;

  case Result of
    True : if not OnIsValid then Result := not IsPntOnSegarcs(Px, Py, Segarcs, Epsilon);
    False: if OnIsValid     then Result := IsPntOnSegarcs(Px, Py, Segarcs, Epsilon);
  end;
end;

class function TUdRela2D.IsPntInSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray; OnIsValid: Boolean = True; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInSegarcs(Pnt.X, Pnt.Y, Segarcs, OnIsValid, Epsilon);
end;


//-------------------------------------------------------------------------------------------------



class function TUdRela2D.IsPntOnRay(Px, Py: Float; Ray: TRay2D; const Epsilon: Float): Boolean;
begin
  Result := False;
  if IsPntOnLine(Px, Py, LineK(Ray.Base, Ray.Ang), Epsilon) then
    Result := IsEqual(GetAngle(Ray.Base.X, Ray.Base.Y, Px, Py), Ray.Ang, 1);
end;


class function TUdRela2D.IsPntOnRay(Pnt: TPoint2D; Ray: TRay2D; const Epsilon: Float): Boolean;
begin
  Result := IsPntOnRay(Pnt.X, Pnt.Y, Ray, Epsilon);
end;


class function TUdRela2D.IsPntOnLine(Px, Py: Float; Ln: TLineK; const Epsilon: Float = _Epsilon): Boolean;
begin
  if Ln.HasK then
    Result := IsEqual((Ln.K * Px + Ln.B), Py, Epsilon)
  else
    Result := IsEqual(Px, Ln.B, Epsilon);
end;

class function TUdRela2D.IsPntOnLine(Px, Py: Float; Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnLine(Px, Py, LineK(Ln.P1, Ln.P2), Epsilon);
end;

class function TUdRela2D.IsPntOnLine(Pnt: TPoint2D; Ln: TLineK; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnLine(Pnt.X, Pnt.Y, Ln, Epsilon);
end;

class function TUdRela2D.IsPntOnLine(Pnt: TPoint2D; Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnLine(Pnt.X, Pnt.Y, LineK(Ln.P1, Ln.P2), Epsilon);
end;



class function TUdRela2D.IsPntOnSegment(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean;
var
  OK: Boolean;
begin
  Result := False;

  if IsEqual(X1, X2, Epsilon) then
    OK := IsEqual(X1, Px, Epsilon)
  else
    OK := ((X1 <= Px + Epsilon) and (Px - Epsilon <= X2)) or
          ((X2 <= Px + Epsilon) and (Px - Epsilon <= X1));

  if not OK then Exit;  //=====>>>>>

  if IsEqual(Y1, Y2, Epsilon) then
    OK := IsEqual(Y1, Py, Epsilon)
  else
    OK := ((Y1 <= Py + Epsilon) and (Py - Epsilon <= Y2)) or
          ((Y2 <= Py + Epsilon) and (Py - Epsilon <= Y1));

  if not OK then Exit;  //=====>>>>>

  Result := DistanceToSegment(Px, Py, X1, Y1, X2, Y2) <= Epsilon;

  //Result := IsPntInSegment(Px, Py, X1, Y1, X2, Y2, Epsilon);
end;

class function TUdRela2D.IsPntOnSegment(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnSegment(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Epsilon);
end;



class function TUdRela2D.IsPntOnRect(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
 Result := (
            ((IsEqual(Px, X1, Epsilon) or IsEqual(Px, X2, Epsilon)) and ((Py >= Min(Y1, Y2)) and (Py <= Max(Y1, Y2)))) or
            ((IsEqual(Py, Y1, Epsilon) or IsEqual(Py, Y2, Epsilon)) and ((Px >= Min(X1, X2)) and (Px <= Max(X1, X2))))
           );
end;

class function TUdRela2D.IsPntOnRect(Pnt: TPoint2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnRect(Pnt.X, Pnt.Y, Rect.X1, Rect.Y1, Rect.X2, Rect.Y2, Epsilon);
end;



class function TUdRela2D.IsPntOnCircle(Px, Py: Float; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): Boolean;
var
  LayDis: Float;
  MinR, MaxR: Float;
begin
  MinR := Radius - Epsilon;
  MaxR := Radius + Epsilon;
  LayDis := LayDistance(Px, Py, Cx, Cy);
  Result := (LayDis <= (MaxR * MaxR)) and (LayDis >= (MinR * MinR));
end;

class function TUdRela2D.IsPntOnCircle(Px, Py: Float; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnCircle(Px, Py, Circle.Cen.X, Circle.Cen.Y, Circle.R, Epsilon);
end;

class function TUdRela2D.IsPntOnCircle(Pnt: TPoint2D; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnCircle(Pnt.X, Pnt.Y, Circle.Cen.X, Circle.Cen.Y, Circle.R, Epsilon);
end;



class function TUdRela2D.IsPntOnArc(Px, Py: Float; Cx, Cy, Radius, Ang1, Ang2: Float; const Epsilon: Float = _Epsilon): Boolean;
var
  MinR, MaxR: Float;
  LayDis, Ang: Float;
begin
  Result := False;

  Ang := GetAngle(Cx, Cy, Px, Py);
  if IsEqual(Ang2, 360.0) and IsEqual(Ang, 0.0) then
  begin
    Result := True;
    Exit; //=====>>>>>
  end;

  if (Ang < 0.0) or not IsInAngles(Ang, Ang1, Ang2, Epsilon) then Exit;   //=====>>>>>

  MinR := Radius - Epsilon;
  MaxR := Radius + Epsilon;
  LayDis := LayDistance(Px, Py, Cx, Cy);
  Result := (LayDis <= (MaxR * MaxR)) and (LayDis >= (MinR * MinR));
end;

class function TUdRela2D.IsPntOnArc(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
var
  P1, P2: TPoint2D;
begin
  Result := IsPntOnArc(Px, Py, Arc.Cen.X, Arc.Cen.Y, Arc.R, Arc.Ang1, Arc.Ang2, Epsilon);

  if not Result and (Arc.Kind in [akSector, akChord]) then
  begin
    P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
    P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
    if Arc.Kind = akChord then
      Result := IsPntOnSegment(Point2D(Px, Py), Segment2D(P1, P2))
    else
      Result := IsPntOnSegment(Point2D(Px, Py), Segment2D(P1, Arc.Cen)) or
                IsPntOnSegment(Point2D(Px, Py), Segment2D(P2, Arc.Cen));
  end;
end;

class function TUdRela2D.IsPntOnArc(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnArc(Pnt.X, Pnt.Y, Arc, Epsilon);
end;



class function TUdRela2D.IsPntOnPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Longint;
begin
  Result := False;

  for I := 0 to System.Length(Poly) - 2 do
  begin
    Result := Result or IsPntOnSegment(
                                         Px, Py,
                                         Poly[I].X, Poly[I].Y,
                                         Poly[(I + 1)].X, Poly[(I + 1)].Y,
                                         Epsilon
                                      );
    if Result then Break;
  end;
end;

class function TUdRela2D.IsPntOnPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnPolygon(Pnt.X, Pnt.Y, Poly, Epsilon);
end;





class function TUdRela2D.IsPntOnPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Integer;
begin
  Index := -1;
  Result := False;

  for I := Low(Polygons) to High(Polygons) do
  begin
    if IsPntOnPolygon(X, Y, Polygons[I], Epsilon) then
    begin
      Index := I;
      Result := True;
      Break;
    end;
  end;
end;

class function TUdRela2D.IsPntOnPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnPolygons(Pnt.X, Pnt.Y, Polygons, Index, Epsilon);
end;


class function TUdRela2D.IsPntOnPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  N: Integer;
begin
  Result := IsPntOnPolygons(X, Y, Polygons, N, Epsilon) and (N >= 0);
end;

class function TUdRela2D.IsPntOnPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnPolygons(Pnt.X, Pnt.Y, Polygons, Epsilon);
end;



class function TUdRela2D.IsPntOnSegarc(Pnt: TPoint2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  if Segarc.IsArc then
    Result := IsPntOnArc(Pnt, Segarc.Arc, Epsilon)
  else
    Result := IsPntOnSegment(Pnt, Segarc.Seg, Epsilon);
end;


class function TUdRela2D.IsPntOnSegarcs(Px, Py: Float; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Longint;
begin
  Result := False;

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    if Segarcs[I].IsArc then
      Result := IsPntOnArc(Point2D(Px, Py), Segarcs[I].Arc, Epsilon)
    else
      Result := IsPntOnSegment(Point2D(Px, Py), Segarcs[I].Seg, Epsilon);

    if Result then Break;
  end;
end;

class function TUdRela2D.IsPntOnSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnSegarcs(Pnt.X, Pnt.Y, Segarcs, Epsilon);
end;






class function TUdRela2D.IsPntInEllipse(Px, Py: Float; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean;
var
  Eq: TEqResult;
  RoCos, RoSin: Float;
  A1, A2, A3, B1, B2, B3: Float;
begin
  RoCos := CosD(Ell.Rot);
  RoSin := SinD(Ell.Rot);

  A1 := Ell.Rx * RoCos;
  A2 := Ell.Ry * RoSin;
  A3 := Ell.Cen.X - Px;

  B1 := Ell.Rx * RoSin;
  B2 := Ell.Ry * RoCos;
  B3 := Ell.Cen.Y - Py;

  Eq := Equation(
                 (A1 * A1 + A2 * A2 + B1 * B1 + B2 * B2),
                 (2 * A1 * A3 + 2 * B1 * B3),
                 (A3 * A3 - A2 * A2 + B3 * B3 - B2 * B2)
                );
  Result := Eq.L > 0;
end;

class function TUdRela2D.IsPntInEllipse(Pnt: TPoint2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntInEllipse(Pnt.X, Pnt.Y, Ell, Epsilon);
end;


class function TUdRela2D.IsPntOnEllipse(Px, Py: Float; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean;
var
  A: Float;
  P: TPoint2D;
begin
  Result := False;
  A := GetAngle(Ell.Cen.X, Ell.Cen.Y, Px, Py) - Ell.Rot;
  A := CenAngToEllAng(Ell.Rx, Ell.Ry, A);
  if IsInAngles(A, Ell.Ang1, Ell.Ang2) then
  begin
    P := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, A);
    Result := IsEqual(P, Point2D(Px, Py), Epsilon);
  end;
end;

class function TUdRela2D.IsPntOnEllipse(Pnt: TPoint2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPntOnEllipse(Pnt.X, Pnt.Y, Ell, Epsilon);
end;







end.