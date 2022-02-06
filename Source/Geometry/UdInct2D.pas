{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdInct2D;

{$I UdGeoDefs.INC}

interface

uses
  {$IFDEF UdTypes}UdTypes ,{$ENDIF} UdGTypes;

type
  TUdInct2D = class
  public
    class function IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float): Boolean; overload;
    class function IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D): Boolean; overload;
    class function IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out iX, iY: Float): Boolean; overload;
    class function IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D; out iX, iY: Float): Boolean; overload;

    class function IsIntersect(Ln1, Ln2: TLine2D): Boolean; overload;
    class function IsIntersect(Seg1, Seg2: TSegment2D): Boolean; overload;
    class function IsIntersect(Ln: TLine2D; Seg: TSegment2D): Boolean; overload;

    class function IsIntersect(Ln: TLine2D; Rect: TRect2D): Boolean; overload;
    class function IsIntersect(Seg: TSegment2D; Rect: TRect2D): Boolean; overload;

    class function IsIntersect(Ln: TLine2D; Cir: TCircle2D): Boolean; overload;
    class function IsIntersect(Seg: TSegment2D; Cir: TCircle2D): Boolean; overload;

    class function IsIntersect(Ln: TLine2D; Arc: TArc2D): Boolean; overload;
    class function IsIntersect(Seg: TSegment2D; Arc: TArc2D): Boolean; overload;


    class function IsIntersect(Ln: TLine2D; Poly: TPoint2DArray): Boolean; overload;
    class function IsIntersect(Seg: TSegment2D; Poly: TPoint2DArray): Boolean; overload;

    class function IsIntersect(Rect1, Rect2: TRect2D): Boolean; overload;
    class function IsIntersect(Rect: TRect2D; Cir: TCircle2D): Boolean; overload;
    class function IsIntersect(Rect: TRect2D; Arc: TArc2D): Boolean; overload;
    class function IsIntersect(Rect: TRect2D; Ell: TEllipse2D): Boolean; overload;
    class function IsIntersect(Rect: TRect2D; Poly: TPoint2DArray): Boolean; overload;

    class function IsIntersect(Cir1, Cir2: TCircle2D): Boolean; overload;
    class function IsIntersect(Cir: TCircle2D; Arc: TArc2D): Boolean; overload;
    class function IsIntersect(Cir: TCircle2D; Poly: TPoint2DArray): Boolean; overload;

    class function IsIntersect(Arc1, Arc2: TArc2D): Boolean; overload;
    class function IsIntersect(Arc: TArc2D; Poly: TPoint2DArray): Boolean; overload;

    class function IsIntersect(Poly1, Poly2: TPoint2DArray): Boolean; overload;


    class function IsIntersect(Ln: TLine2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Seg: TSegment2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Cir: TCircle2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Arc: TArc2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Rect: TRect2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Segarc1, Segarc2: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsIntersect(Ln: TLine2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Seg: TSegment2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Cir: TCircle2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Arc: TArc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Rect: TRect2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Poly: TPolygon2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
    class function IsIntersect(Segarcs1, Segarcs2: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

    class function IsSelfIntersect(Poly: TPolygon2D): Boolean; overload;
    class function IsSelfIntersect(Segarcs: TSegarc2DArray): Boolean; overload;



    //-------------------------------------------------------------------------

    class function Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(P1, P2, P3, P4: TPoint2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln1, Ln2: TLineK; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln1: TLineK; Ln2: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLineK; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLine2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(P1, P2, P3, P4: TPoint2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln1, Ln2: TLineK; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln1, Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln1: TLineK; Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLineK; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLine2D; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg1, Seg2: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;


    class function Intersection(Ln: TLineK; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLine2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg: TSegment2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(Ln: TLineK; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLineK; Cir: TCircle2D; const Epsilon: Float = _Epsilon) : TPoint2DArray; overload;
    class function Intersection(Ln: TLine2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg: TSegment2D; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg: TSegment2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(Ln: TLineK; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLine2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg: TSegment2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(Ln: TLineK; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLine2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg: TSegment2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(Ray1, Ray2: TRay2D; const Epsilon: Float = _Epsilon): TPoint2DArray;  overload;
    class function Intersection(Ray: TRay2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ray: TRay2D; Ln: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ray: TRay2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ray: TRay2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ray: TRay2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ray: TRay2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ray: TRay2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ray: TRay2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ray: TRay2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(Rect1, Rect2: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Rect: TRect2D; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Rect: TRect2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Rect: TRect2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Rect: TRect2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(Cir1, Cir2: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Cir: TCircle2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Cir: TCircle2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(Arc1, Arc2: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Arc: TArc2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(Poly1, Poly2: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;


    class function Intersection(Ln: TLineK; Cen: TPoint2D; Rx, Ry: Float; Ang1, Ang2: Float;  Rot: Float; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLineK; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLine2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg: TSegment2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Cir: TCircle2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Arc: TArc2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Rect: TRect2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ell1, Ell2: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ell: TEllipse2D; Poly: TPoint2DArray;  const Epsilon: Float = _Epsilon): TPoint2DArray; overload;


    class function Intersection(Ln: TLineK; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLine2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg: TSegment2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Cir: TCircle2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Arc: TArc2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Rect: TRect2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ell: TEllipse2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Poly: TPoint2DArray; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Segarc1, Segarc2: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Segarc: TSegarc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

    class function Intersection(Ln: TLineK; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ln: TLine2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Seg: TSegment2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Cir: TCircle2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Arc: TArc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Rect: TRect2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Ell: TEllipse2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Poly: TPolygon2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
    class function Intersection(Segarcs1, Segarcs2: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

  end;

  

implementation

uses
  UdMath, UdGeo2D;


//=================================================================================================

class function TUdInct2D.IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float): Boolean;
var
  UpperX : Float;
  UpperY : Float;
  LowerX : Float;
  LowerY : Float;
  AX, AY : Float;
  BX, BY : Float;
  CX, CY : Float;
  D, E, F: Float;
begin
  Result := False;
  if IsEqual(X1, X2) and IsEqual(Y1, Y2) then Exit;
  if IsEqual(X3, X4) and IsEqual(Y3, Y4) then Exit;

  AX := X2 - X1;
  BX := X3 - X4;

  if AX < 0.0 then
  begin
    LowerX := X2;
    UpperX := X1;
  end
  else
  begin
    UpperX := X2;
    LowerX := X1;
  end;

  if NotEqual(BX, 0.0) then
  begin
    if BX > 0.0 then
    begin
      if (UpperX < X4) or (X3 < LowerX) then  Exit; //---->>>>
    end
    else
      if (UpperX < X3) or (X4 < LowerX) then Exit;  //---->>>>
  end;

  AY := Y2 - Y1;
  BY := Y3 - Y4;

  if AY < 0.0 then
  begin
    LowerY := Y2;
    UpperY := Y1;
  end
  else
  begin
    UpperY := Y2;
    LowerY := Y1;
  end;


  if NotEqual(BY, 0.0) then
  begin
    if BY > 0.0 then
    begin
      if (UpperY < Y4) or (Y3 < LowerY) then Exit; //---->>>>
    end
    else
      if (UpperY < Y3) or (Y4 < LowerY) then Exit; //---->>>>
  end;

  CX := X1 - X3;
  CY := Y1 - Y3;
  D  := (BY * CX) - (BX * CY);
  F  := (AY * BX) - (AX * BY);

  if IsEqual(D, 0.0) and IsEqual(F, 0.0) and IsEqual(D, F) then
  begin
    Result := True;
    Exit;
  end;

  if F > 0.0 then
  begin
    if (D < 0.0) or (D > F) then Exit;  //---->>>>
  end
  else
    if (D > 0.0) or  (D < F) then Exit; //---->>>>

  E := (AX * CY) - (AY * CX);

  if F > 0.0 then
  begin
    if (E < 0.0) or (E > F) then Exit; //---->>>>
  end
  else
    if(E > 0.0) or (E < F) then Exit;  //---->>>>

  Result := True;

(*
  Result := (Orientation(X1, Y1, X2, Y2, X3, Y3) <> Orientation(X1, Y1, X2, Y2, X4, Y4)) and
            (Orientation(X3, Y3, X4, Y4, X1, Y1) <> Orientation(X3, Y3, X4, Y4, X2, Y2));
*)
end;


class function TUdInct2D.IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out iX, iY: Float): Boolean;
var
  UpperX : Float;
  UpperY : Float;
  LowerX : Float;
  LowerY : Float;
  AX, AY : Float;
  BX, BY : Float;
  CX, CY : Float;
  D, E, F: Float;
  Ratio  : Float;
begin
  Result := False;

  AX := X2 - X1;
  BX := X3 - X4;

  if AX < 0.0 then
  begin
    LowerX := X2;
    UpperX := X1;
  end
  else
  begin
    UpperX := X2;
    LowerX := X1;
  end;

  if BX > 0.0 then
  begin
    if (UpperX < X4) or (X3 < LowerX) then Exit;  //---->>>>
  end
  else
    if (UpperX < X3) or (X4 < LowerX) then Exit;  //---->>>>

  AY := Y2 - Y1;
  BY := Y3 - Y4;

  if AY < 0.0 then
  begin
    LowerY := Y2;
    UpperY := Y1;
  end
  else
  begin
    UpperY := Y2;
    LowerY := Y1;
  end;

  if BY > 0.0 then
  begin
    if (UpperY < Y4) or (Y3 < LowerY) then Exit;  //---->>>>
  end
  else
    if (UpperY < Y3) or (Y4 < LowerY) then Exit;  //---->>>>

  CX := X1 - X3;
  CY := Y1 - Y3;
  D  := (BY * CX) - (BX * CY);
  F  := (AY * BX) - (AX * BY);

  if F > 0.0 then
  begin
    if (D < 0.0) or (D > F) then Exit;   //---->>>>
  end
  else
    if (D > 0.0) or  (D < F) then Exit;  //---->>>>

  E := (AX * CY) - (AY * CX);

  if F > 0.0 then
  begin
    if (E < 0.0) or (E > F) then Exit;  //---->>>>
  end
  else
    if(E > 0.0) or (E < F) then Exit;   //---->>>>

  Result := True;

  Ratio := (Ax * -By) - (Ay * -Bx);

  if NotEqual(Ratio, 0.0) then
  begin
    Ratio := ((Cy * -Bx) - (Cx * -By)) / Ratio;
    iX    := X1 + (Ratio * Ax);
    iY    := Y1 + (Ratio * Ay);
  end
  else
  begin
    //if Collinear(x1,y1,x2,y2,x3,y3) then
    if IsEqual((Ax * -Cy),(-Cx * Ay)) then
    begin
      iX := x3;
      iY := y3;
    end
    else begin
      iX := x4;
      iY := y4;
    end;
  end;
end;

class function TUdInct2D.IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D): Boolean;
begin
  Result := IsIntersect(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y, Pnt4.X, Pnt4.Y);
end;

class function TUdInct2D.IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D; out iX, iY: Float): Boolean;
begin
  Result := IsIntersect(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y, Pnt4.X, Pnt4.Y, iX, iY);
end;



class function TUdInct2D.IsIntersect(Ln1, Ln2: TLine2D): Boolean;
begin
  Result := False;
  if IsDegenerate(Ln1) or IsDegenerate(Ln2) then Exit;

  Result := (Orientation(Ln1.P1, Ln2) * Orientation(Ln1.P2, Ln2) <= 0.0) or
            (Orientation(Ln2.P1, Ln1) * Orientation(Ln2.P2, Ln1) <= 0.0);
end;

class function TUdInct2D.IsIntersect(Seg1, Seg2: TSegment2D): Boolean;
begin
  Result := False;
  if IsDegenerate(Seg1) or IsDegenerate(Seg2) then Exit;

  Result := IsIntersect(Seg1.P1.X, Seg1.P1.Y, Seg1.P2.X, Seg1.P2.Y, Seg2.P1.X, Seg2.P1.Y, Seg2.P2.X, Seg2.P2.Y);
end;

class function TUdInct2D.IsIntersect(Ln: TLine2D; Seg: TSegment2D): Boolean;
begin
  Result := False;
  if IsDegenerate(Ln) or IsDegenerate(Seg) then Exit;

  //Result := IsIntersect(Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y);
   Result := (Orientation(Seg.P1, Ln) * Orientation(Seg.P2, Ln) <= 0.0);
end;



class function TUdInct2D.IsIntersect(Ln: TLine2D; Rect: TRect2D): Boolean;
var
  CO, PO: Longint;
begin
  Result := False;
  if IsDegenerate(Ln) or IsDegenerate(Rect) then Exit;

  Result := True;

  PO := Orientation(Rect.P1.X,Rect.P1.Y,  Ln.P1.X,Ln.P1.Y,  Ln.P2.X,Ln.P2.Y);
  CO := Orientation(Rect.P2.X,Rect.P1.Y,  Ln.P1.X,Ln.P1.Y,  Ln.P2.X,Ln.P2.Y);
  if CO <> PO then Exit; //---->>>>

  PO := CO;
  CO := Orientation(Rect.P2.X,Rect.P2.Y,  Ln.P1.X,Ln.P1.Y,  Ln.P2.X,Ln.P2.Y);
  if CO <> PO then Exit; //---->>>>

  PO := CO;
  CO := Orientation(Rect.P1.X,Rect.P2.Y,  Ln.P1.X,Ln.P1.Y,  Ln.P2.X,Ln.P2.Y);
  if CO <> PO then Exit; //---->>>>

  Result:= False;
end;

class function TUdInct2D.IsIntersect(Seg: TSegment2D; Rect: TRect2D): Boolean;
begin
  Result := IsPntInRect(Seg.P1, Rect) or
            IsPntInRect(Seg.P2, Rect) or
            IsIntersect(Seg, Segment2D(Rect.P1, Rect.P2)) or
            IsIntersect(Seg, Segment2D(Rect.P1.X,Rect.P2.Y, Rect.P2.X,Rect.P1.Y));
end;



class function TUdInct2D.IsIntersect(Ln: TLine2D; Cir: TCircle2D): Boolean;
var
  X1, Y1: Float;
  X2, Y2: Float;
begin
  Result := False;
  if IsDegenerate(Ln) then Exit;

  X1 := Ln.P1.X - Cir.Cen.X;
  Y1 := Ln.P1.Y - Cir.Cen.Y;
  X2 := Ln.P2.X - Cir.Cen.X;
  Y2 := Ln.P2.Y - Cir.Cen.Y;
  Result := (Cir.R * Cir.R) * LayDistance(X1, Y1, X2, Y2) - Sqr(X1 * Y2 - X2 * Y1) >= 0.0;
end;

class function TUdInct2D.IsIntersect(Seg: TSegment2D; Cir: TCircle2D): Boolean;
//var
//  RR: Float;
//  Pnt: TPoint2D;
begin
//  Result := False;
//  if IsDegenerate(Seg) or IsDegenerate(Cir) then Exit;

//  RR := (Cir.R * Cir.R);
//
//  Pnt := ClosestSegmentPoint(Cir.Cen, Seg);
//  Result := (LayDistance(Pnt, Cir.Cen) <= RR);
  Result := System.Length(Intersection(Seg, Cir)) > 0;
end;


class function TUdInct2D.IsIntersect(Ln: TLine2D; Arc: TArc2D): Boolean;
begin
  Result := System.Length(Intersection(Ln, Arc)) > 0;
end;

class function TUdInct2D.IsIntersect(Seg: TSegment2D; Arc: TArc2D): Boolean;
begin
  Result := System.Length(Intersection(Seg, Arc)) > 0;
end;



class function TUdInct2D.IsIntersect(Ln: TLine2D; Poly: TPoint2DArray): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to System.Length(Poly) - 1 do
  begin
    if IsIntersect(Ln, Segment2D(Poly[I], Poly[I+1]) ) then
    begin
      Result := True;
      Exit; //---->>>>
    end;
  end;
end;

class function TUdInct2D.IsIntersect(Seg: TSegment2D; Poly: TPoint2DArray): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to System.Length(Poly) - 1 do
  begin
    if IsIntersect(Seg, Segment2D(Poly[I], Poly[I+1]) ) then
    begin
      Result := True;
      Exit; //---->>>>
    end;
  end;
end;




//------------------------------------------------------

class function TUdInct2D.IsIntersect(Rect1, Rect2: TRect2D): Boolean;
begin
  Result := False;
  if IsDegenerate(Rect1) or IsDegenerate(Rect2) then Exit;

  if (Rect1.X2 < Rect2.X1) or (Rect1.X1 > Rect2.X2) or
     (Rect1.Y2 < Rect2.Y1) or (Rect1.Y1 > Rect2.Y2) then Exit;
  Result := True;
end;

class function TUdInct2D.IsIntersect(Rect: TRect2D; Cir: TCircle2D): Boolean;
begin
  Result := //IsIntersect(Segment2D(Rect.X1, Rect.Y1, Rect.X2, Rect.Y2), Cir) or
            //IsIntersect(Segment2D(Rect.X1, Rect.Y2, Rect.X2, Rect.Y1), Cir) or
            IsIntersect(Segment2D(Rect.X1, Rect.Y1, Rect.X2, Rect.Y1), Cir) or
            IsIntersect(Segment2D(Rect.X2, Rect.Y1, Rect.X2, Rect.Y2), Cir) or
            IsIntersect(Segment2D(Rect.X2, Rect.Y2, Rect.X1, Rect.Y2), Cir) or
            IsIntersect(Segment2D(Rect.X1, Rect.Y2, Rect.X1, Rect.Y1), Cir) ;
end;

//secure, fast, but not exact
class function TUdInct2D.IsIntersect(Rect: TRect2D; Arc: TArc2D): Boolean;
begin
  Result := System.Length(Intersection(Rect, Arc)) > 0;
end;

class function TUdInct2D.IsIntersect(Rect: TRect2D; Ell: TEllipse2D): Boolean;
var
  P1, P2: TPoint2D;
begin
  Result := IsIntersect(Rect, Circle2D(Ell.Cen, Ell.Rx)) or
            IsIntersect(Rect, Circle2D(Ell.Cen, Ell.Ry));

  if not Result and (Ell.Kind in [akSector, akChord]) and
     (NotEqual(Ell.Ang1, 0.0) or NotEqual(Ell.Ang2, 360.0)) then
  begin
    P1 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang1);
    P2 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang2);
    if Ell.Kind = akChord then
      Result := IsIntersect(Segment2D(P1, P2), Rect)
    else
      Result := IsIntersect(Segment2D(P1, Ell.Cen), Rect) or
                IsIntersect(Segment2D(P2, Ell.Cen), Rect);
  end;
end;

class function TUdInct2D.IsIntersect(Rect: TRect2D; Poly: TPoint2DArray): Boolean;
var
  I: Integer;
  ASeg, Seg1, Seg2, Seg3, Seg4: TSegment2D;
begin
  Result := False;
  if IsDegenerate(Rect) then Exit;

  Seg1 := Segment2D(Rect.X1, Rect.Y1, Rect.X2, Rect.Y1);
  Seg2 := Segment2D(Rect.X2, Rect.Y1, Rect.X2, Rect.Y2);
  Seg3 := Segment2D(Rect.X2, Rect.Y2, Rect.X1, Rect.Y2);
  Seg4 := Segment2D(Rect.X1, Rect.Y2, Rect.X1, Rect.Y1);

  for I := 0 to System.Length(Poly) - 2 do
  begin
    ASeg := Segment2D(Poly[I], Poly[I+1]);
    if IsIntersect(Seg1, ASeg) or IsIntersect(Seg2, ASeg) or
       IsIntersect(Seg3, ASeg) or IsIntersect(Seg4, ASeg) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;



//------------------------------------------------------

class function TUdInct2D.IsIntersect(Cir1, Cir2: TCircle2D): Boolean;
begin
  Result := False;
  if IsDegenerate(Cir1) or IsDegenerate(Cir2) then Exit;

  Result := LayDistance(Cir1.Cen, Cir2.Cen) <= ((Cir1.R + Cir2.R) * (Cir1.R + Cir2.R));
end;

//secure, fast, but not exact
class function TUdInct2D.IsIntersect(Cir: TCircle2D; Arc: TArc2D): Boolean;
var
  P1, P2: TPoint2D;
begin
  Result := IsIntersect(Cir, Circle2D(Arc.Cen, Arc.R));

  if not Result and (Arc.Kind in [akSector, akChord]) then
  begin
    P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
    P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
    if Arc.Kind = akChord then
      Result := IsIntersect(Segment2D(P1, P2), Cir)
    else
      Result := IsIntersect(Segment2D(P1, Arc.Cen), Cir) or
                IsIntersect(Segment2D(P2, Arc.Cen), Cir);
  end;
end;

class function TUdInct2D.IsIntersect(Cir: TCircle2D; Poly: TPoint2DArray): Boolean;
var
  I: Integer;
begin
  Result := False;
  if IsDegenerate(Cir) then Exit;

  for I := 0 to System.Length(Poly) - 1 do
  begin
    if IsIntersect(Segment2D(Poly[I], Poly[I+1]), Cir) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;



//------------------------------------------------------

class function TUdInct2D.IsIntersect(Arc1, Arc2: TArc2D): Boolean;
begin
//  Result := IsIntersect(Circle2D(Arc1.Cen, Arc1.R), Circle2D(Arc2.Cen, Arc2.R) );
  Result := System.Length(Intersection(Arc1, Arc2)) > 0;
end;

//secure, fast, but not exact
class function TUdInct2D.IsIntersect(Arc: TArc2D; Poly: TPoint2DArray): Boolean;
begin
//  Result := IsIntersect(Circle2D(Arc.Cen, Arc.R), Poly);
  Result := System.Length(Intersection(Arc, Poly)) > 0;
end;




//------------------------------------------------------

class function TUdInct2D.IsIntersect(Poly1, Poly2: TPoint2DArray): Boolean;
var
  I, J: Longint;
  M, N: Longint;
//  Seg1, Seg2: TSegment2D;
begin
  Result := False;
  if (System.Length(Poly1) < 3) or (System.Length(Poly2) < 3) then Exit;  //---->>>>

  M := System.Length(Poly1) - 1;

  for I := 0 to System.Length(Poly1) - 1 do
  begin
    N := System.Length(Poly2) - 1;

    for J := 0 to System.Length(Poly2) - 1 do
    begin
      if IsIntersect(Poly1[I], Poly1[M], Poly2[J], Poly2[N]) then
      begin
        Result := True;
        Exit; //---->>>>
      end;
      N := J;
    end;
    M := I;
  end;

//  for I := 0 to System.Length(Poly1) -  2 do
//  begin
//    Seg1 := Segment2D(Poly1[I], Poly1[I + 1]);
//
//    for J := 0 to System.Length(Poly2) - 1 do
//    begin
//      Seg2 := Segment2D(Poly2[J], Poly2[J + 1]);
//
//      if IsIntersect(Seg1, Seg2) then
//      begin
//        Result := True;
//        Exit; //---->>>>
//      end;
//    end;
//  end;
end;



class function TUdInct2D.IsIntersect(Ln: TLine2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  if Segarc.IsArc then
    Result := IsIntersect(Ln, Segarc.Arc)
  else
    Result := IsIntersect(Ln, Segarc.Seg);
end;

class function TUdInct2D.IsIntersect(Seg: TSegment2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  if Segarc.IsArc then
    Result := IsIntersect(Seg, Segarc.Arc)
  else
    Result := IsIntersect(Seg, Segarc.Seg);
end;

class function TUdInct2D.IsIntersect(Cir: TCircle2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  if Segarc.IsArc then
    Result := IsIntersect(Cir, Segarc.Arc)
  else
    Result := IsIntersect(Segarc.Seg, Cir);
end;

class function TUdInct2D.IsIntersect(Arc: TArc2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  if Segarc.IsArc then
    Result := IsIntersect(Arc, Segarc.Arc)
  else
    Result := IsIntersect(Segarc.Seg, Arc);
end;

class function TUdInct2D.IsIntersect(Rect: TRect2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
var
  Seg1, Seg2, Seg3, Seg4: TSegment2D;
begin
  Seg1 := Segment2D(Rect.X1, Rect.Y1, Rect.X2, Rect.Y1);
  Seg2 := Segment2D(Rect.X2, Rect.Y1, Rect.X2, Rect.Y2);
  Seg3 := Segment2D(Rect.X2, Rect.Y2, Rect.X1, Rect.Y2);
  Seg4 := Segment2D(Rect.X1, Rect.Y2, Rect.X1, Rect.Y1);

  if Segarc.IsArc then
  begin
    Result := IsIntersect(Seg1, Segarc.Arc) or IsIntersect(Seg2, Segarc.Arc) or
              IsIntersect(Seg3, Segarc.Arc) or IsIntersect(Seg4, Segarc.Arc);
  end
  else begin
    Result := IsIntersect(Seg1, Segarc.Seg) or IsIntersect(Seg2, Segarc.Seg) or
              IsIntersect(Seg3, Segarc.Seg) or IsIntersect(Seg4, Segarc.Seg);
  end;
end;

class function TUdInct2D.IsIntersect(Segarc1, Segarc2: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  if Segarc1.IsArc then
  begin
    if Segarc2.IsArc then
      Result := IsIntersect(Segarc1.Arc, Segarc2.Arc)
    else
      Result := IsIntersect(Segarc2.Seg, Segarc1.Arc);
  end
  else begin
    if Segarc2.IsArc then
      Result := IsIntersect(Segarc1.Seg, Segarc2.Arc)
    else
      Result := IsIntersect(Segarc1.Seg, Segarc2.Seg);
  end;
end;



class function TUdInct2D.IsIntersect(Ln: TLine2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Longint;
begin
  Result := False;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    if IsIntersect(Ln, Segarcs[I]) then
    begin
      Result := True;
      Exit; //---->>>>
    end;
  end;
end;

class function TUdInct2D.IsIntersect(Seg: TSegment2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Longint;
begin
  Result := False;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    if IsIntersect(Seg, Segarcs[I]) then
    begin
      Result := True;
      Exit; //---->>>>
    end;
  end;
end;

class function TUdInct2D.IsIntersect(Cir: TCircle2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Longint;
begin
  Result := False;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    if IsIntersect(Cir, Segarcs[I]) then
    begin
      Result := True;
      Exit; //---->>>>
    end;
  end;
end;

class function TUdInct2D.IsIntersect(Arc: TArc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Longint;
begin
  Result := False;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    if IsIntersect(Arc, Segarcs[I]) then
    begin
      Result := True;
      Exit; //---->>>>
    end;
  end;
end;

class function TUdInct2D.IsIntersect(Rect: TRect2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  I: Longint;
begin
  Result := False;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    if IsIntersect(Rect, Segarcs[I]) then
    begin
      Result := True;
      Exit; //---->>>>
    end;
  end;
end;

class function TUdInct2D.IsIntersect(Poly: TPolygon2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  M: Longint;
  I, J: Longint;
begin
  Result := False;
  if (System.Length(Poly) < 3) or (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  M := System.Length(Poly) - 1;

  for I := 0 to System.Length(Poly) - 1 do
  begin
    for J := 0 to System.Length(Segarcs) - 1 do
    begin
      if IsIntersect(Segment2D(Poly[I], Poly[M]), Segarcs[J]) then
      begin
        Result := True;
        Exit; //---->>>>
      end;
    end;

    M := I;
  end;
end;

class function TUdInct2D.IsIntersect(Segarcs1, Segarcs2: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
var
  I, J: Longint;
begin
  Result := False;
  if (System.Length(Segarcs1) <= 0) or (System.Length(Segarcs2) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs1) - 1 do
  begin
    for J := 0 to System.Length(Segarcs2) - 1 do
    begin
      if IsIntersect(Segarcs1[I], Segarcs2[J]) then
      begin
        Result := True;
        Exit; //---->>>>
      end;
    end;
  end;
end;




//-------------------------------------------------------------------------------------------------

class function TUdInct2D.IsSelfIntersect(Poly: TPolygon2D):Boolean;
var
  I, J: Integer;
  N, M: Integer;
begin
  Result := False;
  if (System.Length(Poly) < 3) then Exit;

  N := System.Length(Poly) - 1;
  for I := 0 to System.Length(Poly) - 1 do
  begin
    M := I + 1;
    for J := I + 2 to System.Length(Poly) - 2 do
    begin
      if (I <> J) and (N <> M) then
      begin
        if IsIntersect(Poly[I], Poly[N], Poly[J],Poly[M]) then
        begin
          Result := True;
          Exit;
        end;
      end;
      M := J;
    end;
    N := I;
  end;
end;

class function TUdInct2D.IsSelfIntersect(Segarcs: TSegarc2DArray): Boolean;
var
  I, J: Integer;
  N, M, L: Integer;
begin
  Result := False;
  if (System.Length(Segarcs) < 3) then Exit;

  L := System.Length(Segarcs);
  M := L - 3;

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    N := I + 2;
    for J := 0 to M - 1 do
    begin
      if IsIntersect(Segarcs[I], Segarcs[(J + N) mod L]) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;





//=================================================================================================


class function TUdInct2D.Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  R: Float;
  N: Integer;
  Dx1, Dx2, Dx3: Float;
  Dy1, Dy2, Dy3: Float;
begin
  E := 0;
  Result := nil;

  Dx1 := X2 - X1;
  Dx2 := X4 - X3;
  Dx3 := X1 - X3;

  Dy1 := Y2 - Y1;
  Dy2 := Y1 - Y3;
  Dy3 := Y4 - Y3;

  R := Dx1 * Dy3 - Dy1 * Dx2;

  if not UdMath.IsEqual(R, 0.0, Epsilon) then
  begin
    R  := (Dy2 * (X4 - X3) - Dx3 * Dy3) / R;

    System.SetLength(Result, 1);
    Result[0] := Point2D(X1 + R * Dx1, Y1 + R * Dy1);
  end
  else begin
    if IsCollinear(X1, Y1, X2, Y2, X3, Y3, Epsilon) then
    begin
      E := _OVERLAP;

      N := 0;
      if (IsEqual(X1, X3) and IsEqual(Y1, Y3)) or
         (IsEqual(X1, X4) and IsEqual(Y1, Y4)) then
        N := 1
      else
      if (IsEqual(X2, X3) and IsEqual(Y2, Y3)) or
         (IsEqual(X2, X4) and IsEqual(Y2, Y4)) then
        N := 2;

      if N > 0 then
      begin
//        System.SetLength(Result, 1);
//        case N of
//          1: Result[0] := Point2D(X1, Y1);
//          2: Result[0] := Point2D(X2, Y2);
//        end;
      end;
    end
    else begin
      E := _PARALLEL;

      //System.SetLength(Result, 1);
      //Result[0] := Point2D(X4, Y4);
    end;
  end;
end;

class function TUdInct2D.Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  E: Integer;
begin
  Result := Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4, E, Epsilon);
end;


class function TUdInct2D.Intersection(Ln1, Ln2: TLineK; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  X, Y: Float;
begin
  E := 0;
  Result := nil;

  if (Ln1.HasK or Ln2.HasK) and not IsEqual(Ln1.K, Ln2.K) then
  begin
    System.SetLength(Result, 1);

    if Ln1.HasK and Ln2.HasK then
    begin
      X := (Ln1.B - Ln2.B) / (Ln2.K - Ln1.K);
      Y := (Ln1.K * X + Ln1.B);
      Result[0] := Point2D(X ,Y);
    end
    else
    if not Ln1.HasK then //Ln1 have not K
    begin
      X := Ln1.B;
      Y := Ln2.K * X + Ln2.B;
      Result[0] := Point2D(X, Y);
    end
    else begin //Ln2 have not K
      X := Ln2.B;
      Y := Ln1.K * X + Ln1.B;
      Result[0] := Point2D(X, Y);
    end;
  end
  else begin
    if IsEqual(Ln1.B, Ln2.B) then E := _OVERLAP else E := _PARALLEL;
  end;
end;

class function TUdInct2D.Intersection(Ln1, Ln2: TLineK; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  E: Integer;
begin
  Result := Intersection(Ln1, Ln2, E, Epsilon);
end;


class function TUdInct2D.Intersection(P1, P2, P3, P4: TPoint2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := Intersection(P1.X, P1.Y, P2.X, P2.Y, P3.X, P3.Y, P4.X, P4.Y, E, Epsilon);
end;

class function TUdInct2D.Intersection(P1, P2, P3, P4: TPoint2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  E: Integer;
begin
  Result := Intersection(P1.X, P1.Y, P2.X, P2.Y, P3.X, P3.Y, P4.X, P4.Y, E, Epsilon);
end;


class function TUdInct2D.Intersection(Ln1, Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := Intersection(Ln1.P1.X, Ln1.P1.Y, Ln1.P2.X, Ln1.P2.Y, Ln2.P1.X, Ln2.P1.Y, Ln2.P2.X, Ln2.P2.Y, E, Epsilon);
end;

class function TUdInct2D.Intersection(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  E: Integer;
begin
  Result := Intersection(Ln1.P1.X, Ln1.P1.Y, Ln1.P2.X, Ln1.P2.Y, Ln2.P1.X, Ln2.P1.Y, Ln2.P2.X, Ln2.P2.Y, E, Epsilon);
end;


class function TUdInct2D.Intersection(Ln1: TLineK; Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := Intersection(Ln1, LineK(Ln2.P1, Ln2.P2), E, Epsilon);
end;

class function TUdInct2D.Intersection(Ln1: TLineK; Ln2: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  E: Integer;
begin
  Result := Intersection(Ln1, LineK(Ln2.P1, Ln2.P2), E, Epsilon);
end;


class function TUdInct2D.Intersection(Ln: TLineK; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  E := 0;
  Result := Intersection(Ln, LineK(Seg.P1, Seg.P2), E, Epsilon);

  if (System.Length(Result) = 1) then
  begin
    if IsEqual(Result[0], Seg.P1) or IsEqual(Result[0], Seg.P2) then
      E := _NEARNESS;

    if not IsPntOnSegment(Result[0], Seg) then
      Result := nil;
  end;
end;

class function TUdInct2D.Intersection(Ln: TLineK; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  E: Integer;
begin
  Result := Intersection(Ln, Seg, E, Epsilon);
end;


class function TUdInct2D.Intersection(Ln: TLine2D; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  E := 0;
  Result := Intersection(Ln, Line2D(Seg.P1, Seg.P2), E, Epsilon);

  if (System.Length(Result) = 1) then
  begin
    if IsEqual(Result[0], Seg.P1) or IsEqual(Result[0], Seg.P2) then
      E := _NEARNESS;

    if not IsPntOnSegment(Result[0], Seg) then
      Result := nil;
  end;
end;

class function TUdInct2D.Intersection(Ln: TLine2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  E: Integer;
begin
  E := 0;
  Result := Intersection(Ln, Line2D(Seg.P1, Seg.P2), E, Epsilon);

  if (System.Length(Result) = 1) then
  begin
    if IsEqual(Result[0], Seg.P1) or IsEqual(Result[0], Seg.P2) then
      E := _NEARNESS;

    if not IsPntOnSegment(Result[0], Seg) then
      Result := nil;
  end;
end;


class function TUdInct2D.Intersection(Seg1, Seg2: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  E := 0;
  Result := Intersection(Seg1.P1.X, Seg1.P1.Y, Seg1.P2.X, Seg1.P2.Y,
                           Seg2.P1.X, Seg2.P1.Y, Seg2.P2.X, Seg2.P2.Y, E, Epsilon);

  if (E = 0) and (System.Length(Result) = 1) then
  begin
    if IsEqual(Result[0], Seg1.P1) or IsEqual(Result[0], Seg1.P2) or
       IsEqual(Result[0], Seg2.P1) or IsEqual(Result[0], Seg2.P2) then
      E := _NEARNESS;

    if not IsPntOnSegment(Result[0], Seg1) or
       not IsPntOnSegment(Result[0], Seg2) then
      Result := nil;
  end;
end;

class function TUdInct2D.Intersection(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  E: Integer;
begin
  Result := Intersection(Seg1, Seg2, E, Epsilon);
end;





//-------------------------------------------------------------

class function TUdInct2D.Intersection(Ln: TLineK; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;

  procedure FIntersection(ASeg: TSegment2D);
  var
    I: Integer;
    LPnts: TPoint2DArray;
  begin
    LPnts := Intersection(Ln, ASeg, Epsilon);
    for I := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[I];
    end;
  end;

begin
  Result := nil;

  with Rect do
  begin
    FIntersection(Segment2D(X1, Y1, X2, Y1));
    FIntersection(Segment2D(X2, Y1, X2, Y2));
    FIntersection(Segment2D(X2, Y2, X1, Y2));
    FIntersection(Segment2D(X1, Y2, X1, Y1));
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Ln: TLine2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;

  procedure FIntersection(ASeg: TSegment2D);
  var
    I: Integer;
    LPnts: TPoint2DArray;
  begin
    LPnts := Intersection(Ln, ASeg, Epsilon);
    for I := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[I];
    end;
  end;

begin
  Result := nil;

  with Rect do
  begin
    FIntersection(Segment2D(X1, Y1, X2, Y1));
    FIntersection(Segment2D(X2, Y1, X2, Y2));
    FIntersection(Segment2D(X2, Y2, X1, Y2));
    FIntersection(Segment2D(X1, Y2, X1, Y1));
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Seg: TSegment2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  P1On, P2On: Boolean;
begin
  Result := Intersection(Line2D(Seg.P1, Seg.P2), Rect, Epsilon);
  if System.Length(Result) = 2 then
  begin
    P1On := IsPntOnSegment(Result[0], Seg);
    P2On := IsPntOnSegment(Result[1], Seg);
    if not P1On and not P2On then Result := nil else if not P2On then System.SetLength(Result, 1)
    else if not P1On then
    begin
      Result[0] := Result[1];
      System.SetLength(Result, 1);
    end;
  end
  else if System.Length(Result) = 1 then
  begin
    if not IsPntOnSegment(Result[0], Seg) then Result := nil;
  end;
end;




//-------------------------------------------------------------

class function TUdInct2D.Intersection(Ln: TLineK; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  EqRet: TEqResult;
  XA, YA, RA: Float;
  AX2, BX, C: Float;
begin
  Result := nil;

  XA := -2 * Cx;
  YA := -2 * Cy;
  RA := Cx * Cx + Cy * Cy - Radius * Radius;

  if Ln.HasK then
  begin
    with Ln do
    begin
      AX2 := 1 + K * K;
      BX := 2 * K * B + XA + YA * K;
      C := B * B + YA * B + RA;
    end;

    EqRet := Equation(AX2, BX, C);

    System.SetLength(Result, EqRet.L);

    if EqRet.L >= 1 then
    begin
      Result[0] := Point2D(
                            EqRet.X[0],
                            Ln.K * EqRet.X[0] + Ln.B
                          );
    end;
    if EqRet.L = 2 then
    begin
      Result[1] := Point2D(
                            EqRet.X[1],
                            Ln.K * EqRet.X[1] + Ln.B
                           );
    end;
  end
  else begin
    with Ln do
    begin
      AX2 := 1;
      BX := YA;
      C := B * B + XA * B + RA;
    end;

    EqRet := Equation(AX2, BX, C);

    System.SetLength(Result, EqRet.L);

    if EqRet.L >= 1 then
    begin
      Result[0] := Point2D(
                            Ln.B,
                            EqRet.X[0]
                          );
    end;
    if EqRet.L = 2 then
    begin
      Result[1] := Point2D(
                            Ln.B,
                            EqRet.X[1]
                           );
    end;
  end;

  if (System.Length(Result) = 2) and IsEqual(Result[0], Result[1]) then System.SetLength(Result, 1);
end;

class function TUdInct2D.Intersection(Ln: TLineK; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := Intersection(Ln, Cir.Cen.X, Cir.Cen.Y, Cir.R, Epsilon);
end;

class function TUdInct2D.Intersection(Ln: TLine2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  LPnt: TPoint2D;
begin
  Result := Intersection(LineK(Ln.P1, Ln.P2), Cir.Cen.X, Cir.Cen.Y, Cir.R, Epsilon);

  if (System.Length(Result) = 0) then
  begin
    LPnt := ClosestLinePoint(Cir.Cen, Ln);
    if IsEqual(Distance(LPnt, Cir.Cen), Cir.R) then
    begin
      System.SetLength(Result, 1);
      Result[0] := LPnt;
    end;
  end;
end;


class function TUdInct2D.Intersection(Seg: TSegment2D; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
//  P: TPoint2D;
//  H, D: Float;
//  P1In, P2In: Boolean;
  P1On, P2On: Boolean;
begin
  Result := Self.Intersection(Line2D(Seg.P1, Seg.P2), Circle2D(Cx, Cy, Radius), Epsilon);
  if (System.Length(Result) = 2) and IsEqual(Result[0], Result[1]) then System.SetLength(Result, 1);

  if System.Length(Result) = 2 then
  begin
    P1On := IsPntInSegment(Result[0], Seg, Epsilon);
    P2On := IsPntInSegment(Result[1], Seg, Epsilon);
    if not P1On and not P2On then Result := nil else if not P2On then System.SetLength(Result, 1)
    else if not P1On then
    begin
      Result[0] := Result[1];
      System.SetLength(Result, 1);
    end;
  end else
  if System.Length(Result) = 1 then
  begin
    P1On := IsPntInSegment(Result[0], Seg, Epsilon);
    if not P1On  then Result := nil;
  end;


(*
  Result := nil;

  P1In := IsPntInCircle(Seg.P1.X, Seg.P1.Y, Cx, Cy, Radius, Epsilon);
  P2In := IsPntInCircle(Seg.P2.X, Seg.P2.Y, Cx, Cy, Radius, Epsilon);

  if P1In and P2In then
  begin
    if IsPntOnCircle(Seg.P1.X, Seg.P1.Y, Cx, Cy, Radius, Epsilon) then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := Seg.P1;
    end;

    if IsPntOnCircle(Seg.P2.X, Seg.P2.Y, Cx, Cy, Radius, Epsilon) then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := Seg.P2;
    end;

    if (System.Length(Result) = 2) and IsEqual(Result[0], Result[1]) then System.SetLength(Result, 1);
    Exit;   //---->>>>
  end;


  if P1In or P2In then
  begin
    System.SetLength(Result, 1);

    P := ClosestLinePoint(Cx, Cy, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y);
    H := Distance(P.X, P.Y, Cx, Cy);
    D := (Radius * Radius) - (H * H);
    if D <= 0.0 then D := 0.0 else D := Sqrt(D);

    if P1In then
    begin
      Result[0] := ShiftPoint(P, Seg.P2, D);

      if IsPntOnCircle(Seg.P1.X, Seg.P1.Y, Cx, Cy, Radius) then
      begin
        System.SetLength(Result, 2);
        Result[1] := Seg.P1;
      end;
    end else
    if P2In then
    begin
      Result[0] := ShiftPoint(P, Seg.P1, D);

      if IsPntOnCircle(Seg.P2.X, Seg.P2.Y, Cx, Cy, Radius, Epsilon) then
      begin
        System.SetLength(Result, 2);
        Result[1] := Seg.P2;
      end;
    end;

    if (System.Length(Result) = 2) and IsEqual(Result[0], Result[1]) then System.SetLength(Result, 1);
    Exit;   //---->>>>
  end;

  P := ClosestSegmentPoint(Point2D(Cx, Cy), Seg);

  if IsEqual(P, Seg.P1) or IsEqual(P, Seg.P2) then
  begin
    H := Distance(P.X, P.Y, Cx, Cy);

    if IsEqual(H, Radius) then
    begin
      System.SetLength(Result, 1);
      Result[0] := P;
    end
    else if IsEqual(H,0.0) then
    begin
      System.SetLength(Result, 2);
      Result[0] := ShiftPoint(Cx,Cy, Seg.P1.X,Seg.P1.Y, Radius);
      Result[1] := ShiftPoint(Cx,Cy, Seg.P2.X,Seg.P2.Y, Radius);
    end
    else if H < Radius then
    begin
      D := Sqrt((Radius * Radius) - (H * H));

      System.SetLength(Result, 2);
      Result[0] := ShiftPoint(P, Seg.P1, D);
      Result[1] := ShiftPoint(P, Seg.P2, D);
    end;
  end;

  if (System.Length(Result) = 2) and IsEqual(Result[0], Result[1]) then System.SetLength(Result, 1);
*)
end;

class function TUdInct2D.Intersection(Seg: TSegment2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := Intersection(Seg, Cir.Cen.X, Cir.Cen.Y, Cir.R, Epsilon);
end;




//-------------------------------------------------------------

class function TUdInct2D.Intersection(Ln: TLineK; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  P1, P2: TPoint2D;
  P1On, P2On: Boolean;
begin
  Result := Intersection(Ln, Arc.Cen.X, Arc.Cen.Y, Arc.R, Epsilon);

  if System.Length(Result) = 2 then
  begin
    P1On := IsPntOnArc(Result[0], Arc, Epsilon);
    P2On := IsPntOnArc(Result[1], Arc, Epsilon);
    if not P1On and not P2On then Result := nil else if not P2On then System.SetLength(Result, 1)
    else if not P1On then
    begin
      Result[0] := Result[1];
      System.SetLength(Result, 1);
    end;
  end
  else if System.Length(Result) = 1 then
  begin
    if not IsPntOnArc(Result[0], Arc) then Result := nil;
  end;

  if Arc.Kind in [akSector, akChord] then
  begin
    P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
    P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
    if Arc.Kind = akChord then
      FAddArray(Result, Intersection(Ln, Segment2D(P1, P2)))
    else begin
      FAddArray(Result, Intersection(Ln, Segment2D(P1, Arc.Cen)));
      FAddArray(Result, Intersection(Ln, Segment2D(P2, Arc.Cen)));
    end;
  end;
end;

class function TUdInct2D.Intersection(Ln: TLine2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := Intersection(LineK(Ln.P1, Ln.P2), Arc, Epsilon);
end;

class function TUdInct2D.Intersection(Seg: TSegment2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  P1, P2: TPoint2D;
  P1On, P2On: Boolean;
begin
  Result := Intersection(Seg, Arc.Cen.X, Arc.Cen.Y, Arc.R, Epsilon);

  if System.Length(Result) = 2 then
  begin
    P1On := IsPntOnArc(Result[0], Arc);
    P2On := IsPntOnArc(Result[1], Arc);
    if not P1On and not P2On then Result := nil else if not P2On then System.SetLength(Result, 1)
    else if not P1On then
    begin
      Result[0] := Result[1];
      System.SetLength(Result, 1);
    end;
  end
  else if System.Length(Result) = 1 then
  begin
    if not IsPntOnArc(Result[0], Arc) then Result := nil;
  end;

  if Arc.Kind in [akSector, akChord] then
  begin
    P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
    P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
    if Arc.Kind = akChord then
      FAddArray(Result, Intersection(Seg, Segment2D(P1, P2)))
    else begin
      FAddArray(Result, Intersection(Seg, Segment2D(P1, Arc.Cen)));
      FAddArray(Result, Intersection(Seg, Segment2D(P2, Arc.Cen)));
    end;
  end;
end;



//-------------------------------------------------------------

class function TUdInct2D.Intersection(Ln: TLineK; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;

  for I := 0 to System.Length(Poly) - 2 do
  begin
    LPnts := Intersection(Ln, Segment2D(Poly[I], Poly[I+1]), Epsilon);
    //if System.Length(LPnts) = 1 then
    for J := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[J];
    end;
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Ln: TLine2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;

  for I := 0 to System.Length(Poly) - 2 do
  begin
    LPnts := Intersection(Ln, Segment2D(Poly[I], Poly[I+1]), Epsilon);
    //if System.Length(LPnts) = 1 then
    for J := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[J];
    end;
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Seg: TSegment2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;

  for I := 0 to System.Length(Poly) - 2 do
  begin
    LPnts := Intersection(Seg, Segment2D(Poly[I], Poly[I+1]), Epsilon);
    //if System.Length(LPnts) = 1 then
    for J := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[J];
    end;
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;



//-------------------------------------------------------------


class function TUdInct2D.Intersection(Ray1, Ray2: TRay2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  LnK1, LnK2: TLineK;
  Pnts: TPoint2DArray;
begin
  Result := nil;

  LnK1 := LineK(Ray1.Base.X, Ray1.Base.Y, Ray1.Ang);
  LnK2 := LineK(Ray2.Base.X, Ray2.Base.Y, Ray2.Ang);

  Pnts := Intersection(LnK1, LnK2, Epsilon);

  if (System.Length(Pnts) = 1) and
      NotEqual(Pnts[0], Ray1.Base) and IsEqual(GetAngle(Ray1.Base, Pnts[0]), Ray1.Ang, 1) and
      NotEqual(Pnts[0], Ray2.Base) and IsEqual(GetAngle(Ray2.Base, Pnts[0]), Ray2.Ang, 1) then
    Result := Pnts;
end;


class function TUdInct2D.Intersection(Ray: TRay2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  LnK: TLineK;
  Pnts: TPoint2DArray;
begin
  Result := nil;

  LnK := LineK(Ray.Base.X, Ray.Base.Y, Ray.Ang);
  Pnts := Intersection(LnK, Seg, Epsilon);

  if (System.Length(Pnts) = 1) and NotEqual(Pnts[0], Ray.Base) and
      IsEqual(GetAngle(Ray.Base, Pnts[0]), Ray.Ang, 1) then Result := Pnts;
end;


class function TUdInct2D.Intersection(Ray: TRay2D; Ln: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  LnK: TLineK;
  Pnts: TPoint2DArray;
begin
  Result := nil;

  LnK := LineK(Ray.Base.X, Ray.Base.Y, Ray.Ang);
  Pnts := Intersection(LnK, Ln, Epsilon);

  if (System.Length(Pnts) = 1) and NotEqual(Pnts[0], Ray.Base) and
      IsEqual(GetAngle(Ray.Base, Pnts[0]), Ray.Ang, 1) then Result := Pnts;
end;

class function TUdInct2D.Intersection(Ray: TRay2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
  LnK: TLineK;
  Pnts: TPoint2DArray;
begin
  Result := nil;

  LnK := LineK(Ray.Base.X, Ray.Base.Y, Ray.Ang);
  Pnts := Intersection(LnK, Cir, Epsilon);

  for I := 0 to System.Length(Pnts) - 1 do
  begin
    if NotEqual(Pnts[I], Ray.Base) and IsEqual(GetAngle(Ray.Base, Pnts[I]), Ray.Ang, 1) then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := Pnts[I];
    end;
  end;
end;

class function TUdInct2D.Intersection(Ray: TRay2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
  LnK: TLineK;
  Pnts: TPoint2DArray;
  P1, P2: TPoint2D;
begin
  Result := nil;

  LnK := LineK(Ray.Base.X, Ray.Base.Y, Ray.Ang);
  Pnts := Intersection(LnK, Arc, Epsilon);

  for I := 0 to System.Length(Pnts) - 1 do
  begin
    if NotEqual(Pnts[I], Ray.Base) and IsEqual(GetAngle(Ray.Base, Pnts[I]), Ray.Ang, 1) then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := Pnts[I];
    end;
  end;

  if Arc.Kind in [akSector, akChord] then
  begin
    P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
    P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
    if Arc.Kind = akChord then
      FAddArray(Result, Intersection(Ray, Segment2D(P1, P2)))
    else begin
      FAddArray(Result, Intersection(Ray, Segment2D(P1, Arc.Cen)));
      FAddArray(Result, Intersection(Ray, Segment2D(P2, Arc.Cen)));
    end;
  end;  
end;


function GetTrimedRayInctPnts(var Ray: TRay2D; var Pnts: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to System.Length(Pnts) - 1 do
  begin
    if NotEqual(Pnts[I], Ray.Base) and IsEqual(GetAngle(Ray.Base, Pnts[I]), Ray.Ang, 1) then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := Pnts[I];
    end;
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;


class function TUdInct2D.Intersection(Ray: TRay2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  LnK: TLineK;
  Pnts: TPoint2DArray;
begin
  Result := nil;

  LnK := LineK(Ray.Base.X, Ray.Base.Y, Ray.Ang);
  Pnts := Intersection(LnK, Ell, Epsilon);

  Result := GetTrimedRayInctPnts(Ray, Pnts, Epsilon);
end;


class function TUdInct2D.Intersection(Ray: TRay2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  LnK: TLineK;
  Pnts: TPoint2DArray;
begin
  Result := nil;

  LnK := LineK(Ray.Base.X, Ray.Base.Y, Ray.Ang);
  Pnts := Intersection(LnK, Poly, Epsilon);

  Result := GetTrimedRayInctPnts(Ray, Pnts);
end;

class function TUdInct2D.Intersection(Ray: TRay2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  LnK: TLineK;
  Pnts: TPoint2DArray;
begin
  Result := nil;

  LnK := LineK(Ray.Base.X, Ray.Base.Y, Ray.Ang);
  Pnts := Intersection(LnK, Rect, Epsilon);

  Result := GetTrimedRayInctPnts(Ray, Pnts);
end;

class function TUdInct2D.Intersection(Ray: TRay2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  LnK: TLineK;
  Pnts: TPoint2DArray;
begin
  Result := nil;

  LnK := LineK(Ray.Base.X, Ray.Base.Y, Ray.Ang);
  Pnts := Intersection(LnK, Segarc, Epsilon);

  Result := GetTrimedRayInctPnts(Ray, Pnts);
end;

class function TUdInct2D.Intersection(Ray: TRay2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  LnK: TLineK;
  Pnts: TPoint2DArray;
begin
  Result := nil;

  LnK := LineK(Ray.Base.X, Ray.Base.Y, Ray.Ang);
  Pnts := Intersection(LnK, Segarcs, Epsilon);

  Result := GetTrimedRayInctPnts(Ray, Pnts);
end;



//-------------------------------------------------------------

class function TUdInct2D.Intersection(Rect1, Rect2: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;

  procedure FIntersection(ASeg: TSegment2D);
  var
    I: Integer;
    LPnts: TPoint2DArray;
  begin
    LPnts := Intersection(ASeg, Rect2, Epsilon);
    for I := 0 to System.Length(LPnts) do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[I];
    end;
  end;

begin
  Result := nil;

  with Rect1 do
  begin
    FIntersection(Segment2D(X1, Y1, X2, Y1));
    FIntersection(Segment2D(X2, Y1, X2, Y2));
    FIntersection(Segment2D(X2, Y2, X1, Y2));
    FIntersection(Segment2D(X1, Y2, X1, Y1));
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Rect: TRect2D; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray;

  procedure FIntersection(ASeg: TSegment2D);
  var
    I: Integer;
    LPnts: TPoint2DArray;
  begin
    LPnts := Intersection(ASeg, Cx, Cy, Radius, Epsilon);
    for I := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[I];
    end;
  end;

begin
  Result := nil;

  with Rect do
  begin
    FIntersection(Segment2D(X1, Y1, X2, Y1));
    FIntersection(Segment2D(X2, Y1, X2, Y2));
    FIntersection(Segment2D(X2, Y2, X1, Y2));
    FIntersection(Segment2D(X1, Y2, X1, Y1));
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Rect: TRect2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := Intersection(Rect, Cir.Cen.X, Cir.Cen.Y, Cir.R, Epsilon);
end;

class function TUdInct2D.Intersection(Rect: TRect2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  P1, P2: TPoint2D;
  P1On, P2On: Boolean;
begin
  Result := Intersection(Rect, Arc.Cen.X, Arc.Cen.Y, Arc.R, Epsilon);

  if System.Length(Result) = 2 then
  begin
    P1On := IsPntOnArc(Result[0], Arc);
    P2On := IsPntOnArc(Result[1], Arc);
    if not P1On and not P2On then Result := nil else if not P2On then System.SetLength(Result, 1)
    else if not P1On then
    begin
      Result[0] := Result[1];
      System.SetLength(Result, 1);
    end;
  end
  else if System.Length(Result) = 1 then
  begin
    if not IsPntOnArc(Result[0], Arc) then Result := nil;
  end;

  if Arc.Kind in [akSector, akChord] then
  begin
    P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
    P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
    if Arc.Kind = akChord then
      FAddArray(Result, Intersection(Segment2D(P1, P2), Rect))
    else begin
      FAddArray(Result, Intersection(Segment2D(P1, Arc.Cen), Rect));
      FAddArray(Result, Intersection(Segment2D(P2, Arc.Cen), Rect));
    end;
  end;   
end;

//class function TUdInct2D.Intersection(Rect: TRect2D; Ell: TEllipse2D): TPoint2DArray;
//begin
//  {$Message 'No Implementation Code'}
//end;

class function TUdInct2D.Intersection(Rect: TRect2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;

  procedure FIntersection(ASeg: TSegment2D);
  var
    I: Integer;
    LPnts: TPoint2DArray;
  begin
    LPnts := Intersection(ASeg, Poly, Epsilon);
    for I := 0 to System.Length(LPnts) do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[I];
    end;
  end;

begin
  Result := nil;

  with Rect do
  begin
    FIntersection(Segment2D(X1, Y1, X2, Y1));
    FIntersection(Segment2D(X2, Y1, X2, Y2));
    FIntersection(Segment2D(X2, Y2, X1, Y2));
    FIntersection(Segment2D(X1, Y2, X1, Y1));
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;




//-------------------------------------------------------------

class function TUdInct2D.Intersection(Cir1, Cir2: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  Ph: TPoint2D;
  RatioA: Float;
  RatioH: Float;
  A, H, T: Float;
  Ds, Dx, Dy: Float;
  R1Sqr, R2Sqr, DsSqr: Float;
begin
  Result := nil;

  Ds := Distance(Cir1.Cen, Cir2.Cen);
  if IsEqual(Ds, 0.0) or ((Ds - 1.0E-08) > (Cir1.R + Cir2.R)) then Exit;   //---->>>>

  DsSqr := Ds * Ds;
  R1Sqr := Cir1.R * Cir1.R;
  R2Sqr := Cir2.R * Cir2.R;

  A := (DsSqr + R1Sqr - R2Sqr) / (2 * Ds);
  T := R1Sqr - A * A;
  if IsEqual(T, 0.0) then T := 0.0;
  
  if T < 0.0 then Exit;   //---->>>>

  H := Sqrt(T);
  RatioA := A / Ds;
  RatioH := H / Ds;

  Dx := Cir2.Cen.X - Cir1.Cen.X;
  Dy := Cir2.Cen.Y - Cir1.Cen.Y;

  Ph.X := Cir1.Cen.X + RatioA * Dx;
  Ph.Y := Cir1.Cen.Y + RatioA * Dy;

  Dx := Dx * RatioH;
  Dy := Dy * RatioH;

  System.SetLength(Result, 2);

  Result[0].X := Ph.X + Dy;
  Result[0].Y := Ph.Y - Dx;

  Result[1].X := Ph.X - Dy;
  Result[1].Y := Ph.Y + Dx;

  if IsEqual(Result[0], Result[1], Epsilon) then System.SetLength(Result, 1);
end;


class function TUdInct2D.Intersection(Cir: TCircle2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  P1, P2: TPoint2D;
  P1On, P2On: Boolean;
begin
  if IsEqual(Arc.Cen, Cir.Cen) and IsEqual(Arc.R, Cir.R) then
  begin
    if not (IsEqual(Arc.Ang1, 0.0) and IsEqual(Arc.Ang2, 360.0)) then
    begin
      System.SetLength(Result, 2);
      Result[0] := ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R);
      Result[1] := ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R);
    end;
  end
  else begin
    Result := Intersection(Cir, Circle2D(Arc.Cen, Arc.R), Epsilon);
    if System.Length(Result) = 2 then
    begin
      P1On := IsPntOnArc(Result[0], Arc, Epsilon);
      P2On := IsPntOnArc(Result[1], Arc, Epsilon);
      if not P1On and not P2On then Result := nil else if not P2On then System.SetLength(Result, 1)
      else if not P1On then
      begin
        Result[0] := Result[1];
        System.SetLength(Result, 1);
      end;
    end
    else if System.Length(Result) = 1 then
    begin
      if not IsPntOnArc(Result[0], Arc, Epsilon) then Result := nil;
    end;
  end;
  
  if Arc.Kind in [akSector, akChord] then
  begin
    P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
    P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
    if Arc.Kind = akChord then
      FAddArray(Result, Intersection(Segment2D(P1, P2), Cir))
    else begin
      FAddArray(Result, Intersection(Segment2D(P1, Arc.Cen), Cir));
      FAddArray(Result, Intersection(Segment2D(P2, Arc.Cen), Cir));
    end;
  end;
end;

//class function TUdInct2D.Intersection(Cir: TCircle2D; Ell: TEllipse2D): TPoint2DArray;
//begin
//  {$Message 'No Implementation Code'}
//end;

class function TUdInct2D.Intersection(Cir: TCircle2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;

  for I := 0 to System.Length(Poly) - 2 do
  begin
    LPnts := Intersection(Segment2D(Poly[I], Poly[I+1]), Cir, Epsilon);
    for J := Low(LPnts) to High(LPnts) do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[J];
    end;
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;




class function TUdInct2D.Intersection(Arc1, Arc2: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  P1, P2: TPoint2D;
  P1On, P2On: Boolean;
  LArc2: TArc2D;
begin
  LArc2 := Arc2;
  LArc2.Kind := akCurve;
  Result := Intersection(Circle2D(Arc1.Cen, Arc1.R), LArc2, Epsilon);

  if System.Length(Result) = 2 then
  begin
    P1On := IsPntOnArc(Result[0], Arc1, Epsilon);
    P2On := IsPntOnArc(Result[1], Arc1, Epsilon);
    if not P1On and not P2On then Result := nil else if not P2On then System.SetLength(Result, 1)
    else if not P1On then
    begin
      Result[0] := Result[1];
      System.SetLength(Result, 1);
    end;
  end
  else if System.Length(Result) = 1 then
  begin
    if not IsPntOnArc(Result[0], Arc1, Epsilon) then Result := nil;
  end
  else begin
    P1 := ShiftPoint(Arc1.Cen, Arc1.Ang1, Arc1.R);
    P2 := ShiftPoint(Arc1.Cen, Arc1.Ang2, Arc1.R);

    if IsPntOnArc(P1, Arc2, Epsilon) then
    begin
      System.SetLength(Result, 1);
      Result[0] := P1;
    end
    else
    if IsPntOnArc(P2, Arc2, Epsilon) then
    begin
      System.SetLength(Result, 1);
      Result[0] := P2;
    end;
  end;

  if Arc1.Kind in [akSector, akChord] then
  begin
    P1 := GetArcPoint(Arc1.Cen, Arc1.R, Arc1.Ang1);
    P2 := GetArcPoint(Arc1.Cen, Arc1.R, Arc1.Ang2);

    if Arc1.Kind = akChord then
      FAddArray(Result, Intersection(Segment2D(P1, P2), Arc2))
    else begin
      FAddArray(Result, Intersection(Segment2D(P1, Arc1.Cen), Arc2));
      FAddArray(Result, Intersection(Segment2D(P2, Arc1.Cen), Arc2));
    end;
  end;

  if Arc2.Kind in [akSector, akChord] then
  begin
    P1 := GetArcPoint(Arc2.Cen, Arc2.R, Arc2.Ang1);
    P2 := GetArcPoint(Arc2.Cen, Arc2.R, Arc2.Ang2);

    if Arc2.Kind = akChord then
      FAddArray(Result, Intersection(Segment2D(P1, P2), Arc1))
    else begin
      FAddArray(Result, Intersection(Segment2D(P1, Arc2.Cen), Arc1));
      FAddArray(Result, Intersection(Segment2D(P2, Arc2.Cen), Arc1));
    end;
  end;
end;

//class function TUdInct2D.Intersection(Arc: TArc2D; Ell: TEllipse2D): TPoint2DArray;
//begin
//  {$Message 'No Implementation Code'}
//end;

class function TUdInct2D.Intersection(Arc: TArc2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;

  for I := 0 to System.Length(Poly) - 2 do
  begin
    LPnts := Intersection(Segment2D(Poly[I], Poly[I+1]), Arc, Epsilon);
    for J := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[J];
    end;
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;




//class function TUdInct2D.Intersection(Ell1, Ell2: TEllipse2D): TPoint2DArray;
//begin
//  {$Message 'No Implementation Code'}
//end;

class function TUdInct2D.Intersection(Poly1, Poly2: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Integer;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;

  for I := 0 to System.Length(Poly1) - 2 do
  begin
    LPnts := Intersection(Segment2D(Poly1[I], Poly1[I + 1]), Poly2, Epsilon);
    for J := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[J];
    end;
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;






  function FIsInEllAnges(EAng: Float; Ell: TEllipse2D): Boolean; overload;
  begin
    Result := IsEqual(Ell.Ang1, 0.0) and IsEqual(Ell.Ang2, 360.0); //IsEqual(Ell.Ang1, Ell.Ang2) or (
    if not Result then
      Result := UdMath.IsInAngles(EAng, Ell.Ang1, Ell.Ang2);
  end;

  function FIsInEllAnges(EAng: Float; Ang1, Ang2: Float): Boolean; overload;
  begin
    Result := IsEqual(Ang1, 0.0) and IsEqual(Ang2, 360.0); //IsEqual(Ell.Ang1, Ell.Ang2) or (
    if not Result then
      Result := UdMath.IsInAngles(EAng, Ang1, Ang2);
  end;



class function TUdInct2D.Intersection(Ln: TLineK; Cen: TPoint2D; Rx, Ry: Float; Ang1, Ang2: Float;  Rot: Float;
                                      const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  L: Integer;
  A, B, C, D: Float;
  LRotSin, LRotCos: Float;
  LCosAng, LTanAng: Float;
  LAng1, LAng2: Float;
begin
  Result := nil;

  LRotSin := SinD(Rot);
  LRotCos := CosD(Rot);

  if not Ln.HasK then
  begin
    A := Ry * LRotSin;
    B := - Rx * LRotCos;
    C := Cen.X - Ln.B;
  end
  else begin
    A := Ry * LRotCos + Ln.K * Ry * LRotSin;
    B := Rx * LRotSin - Ln.K * Rx * LRotCos;
    C := Ln.K * Cen.X - Cen.Y + Ln.B;
  end;

  D := Sqrt(A * A + B * B);

  if Abs(C/D) > 1.0 then Exit;

  if IsEqual(B, 0.0) then LTanAng := 90 else LTanAng := ArcTanD(A/B);
  LCosAng := ArcCosD(C/D);

  if B >= 0 then
  begin
    LAng1 := FixAngle(LTanAng + LCosAng);
    LAng2 := FixAngle(LTanAng - LCosAng);
  end
  else begin
    LAng1 := FixAngle(LTanAng + 180 + LCosAng);
    LAng2 := FixAngle(LTanAng + 180 - LCosAng);
  end;


  System.SetLength(Result, 2);
  L := 0;

  if FIsInEllAnges(LAng1, Ang1, Ang2) then
  begin
    Result[L] := GetEllipsePoint(Cen, Rx, Ry, Rot, LAng1);
    L := L + 1;
  end;

  if FIsInEllAnges(LAng2, Ang1, Ang2)  then
  begin
    Result[L] := GetEllipsePoint(Cen, Rx, Ry, Rot, LAng2);
    L := L + 1;
  end;

  if System.Length(Result) <> L then System.SetLength(Result, L);
  if L > 1 then
    Result := UdMath.TrimPoints(Result, Epsilon);
end;  

class function TUdInct2D.Intersection(Ln: TLineK; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  P1, P2: TPoint2D;
begin
  Result := Intersection(Ln, Ell.Cen, Ell.Rx, Ell.Ry, Ell.Ang1, Ell.Ang2, Ell.Rot, Epsilon);

  if (Ell.Kind in [akSector, akChord]) and (NotEqual(Ell.Ang1, 0.0) or NotEqual(Ell.Ang2, 360.0)) then
  begin
    P1 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang1);
    P2 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang2);
    if Ell.Kind = akChord then
      FAddArray(Result, Intersection(Ln, Segment2D(P1, P2)))
    else begin
      FAddArray(Result, Intersection(Ln, Segment2D(P1, Ell.Cen)));
      FAddArray(Result, Intersection(Ln, Segment2D(P2, Ell.Cen)));
    end;
  end;
end;

class function TUdInct2D.Intersection(Ln: TLine2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := Self.Intersection(LineK(Ln.P1, Ln.P2), Ell, Epsilon);
end;

class function TUdInct2D.Intersection(Seg: TSegment2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  P1On, P2On: Boolean;
  P1, P2: TPoint2D;  
begin
  Result := Intersection(LineK(Seg.P1, Seg.P2), Ell.Cen, Ell.Rx, Ell.Ry, Ell.Ang1, Ell.Ang2, Ell.Rot, Epsilon);

  if System.Length(Result) = 2 then
  begin
    P1On := IsPntOnSegment(Result[0], Seg);
    P2On := IsPntOnSegment(Result[1], Seg);
    if not P1On and not P2On then Result := nil else if not P2On then System.SetLength(Result, 1)
    else if not P1On then
    begin
      Result[0] := Result[1];
      System.SetLength(Result, 1);
    end;
  end
  else if System.Length(Result) = 1 then
  begin
    if not IsPntOnSegment(Result[0], Seg) then Result := nil;
  end;

  if (Ell.Kind in [akSector, akChord]) and (NotEqual(Ell.Ang1, 0.0) or NotEqual(Ell.Ang2, 360.0)) then
  begin
    P1 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang1);
    P2 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang2);
    if Ell.Kind = akChord then
      FAddArray(Result, Intersection(Seg, Segment2D(P1, P2)))
    else begin
      FAddArray(Result, Intersection(Seg, Segment2D(P1, Ell.Cen)));
      FAddArray(Result, Intersection(Seg, Segment2D(P2, Ell.Cen)));
    end;
  end;  
end;







procedure FCalcCirEllEquationParms(Ell: TEllipse2D; CirR: Float; var XA, XB, XC, XD, XE: Extended);
var
  RoSin, RoCos: Extended;
  A1, A2, B1, B2: Float;
  A, B, C, D, E, F: Float;
begin
  SinCosD(Ell.Rot, RoSin, RoCos);

  A1 := Ell.Rx * RoCos;
  B1 := Ell.Ry * RoSin;

  A2 := Ell.Rx * RoSin;
  B2 := Ell.Ry * RoCos;


  A := A1*A1 + A2*A2       ;
  B := B1*B1 + B2*B2       ;
  C := 2*A2*B2 - 2*A1*B1   ;
  D := 2*Ell.Cen.X*A1 + 2*Ell.Cen.Y*A2;
  E := 2*Ell.Cen.Y*B2 - 2*Ell.Cen.X*B1;
  F := Ell.Cen.X*Ell.Cen.X + Ell.Cen.Y*Ell.Cen.Y - CirR*CirR;


  XA := Sqr(A - B) + C*C   ;
  XB := 2*D*(A-B) + 2*E*C  ;
  XC := D*D + 2*(F+B)*(A-B) - C*C + E*E;
  XD := 2*(F+B)*D - 2*E*C  ;
  XE := Sqr(F+B) - E*E     ;
end;


class function TUdInct2D.Intersection(Cir: TCircle2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;

  procedure _AppendResult(var Return: TPoint2DArray; AEll: TEllipse2D; Ang: Float);
  var
    L: Integer;
    Pnt: TPoint2D;
  begin
    if FIsInEllAnges(Ang, AEll) then
    begin
      Pnt := GetEllipsePoint(AEll.Cen, AEll.Rx, AEll.Ry, AEll.Rot, Ang);
      Pnt := Translate(Cir.Cen.X, Cir.Cen.Y, Pnt);

      if IsPntOnCircle(Pnt, Cir, Epsilon) then
      begin
        L := System.Length(Return);
        System.SetLength(Result, L+1);
        Result[L] := Pnt;
      end;
    end;
  end;

var
  I: Integer;
  AA: Float;
  LEll: TEllipse2D;
  EqCosX: TEqResult;
  XA, XB, XC, XD, XE: Extended;
  P1, P2: TPoint2D;
begin
  Result := nil;

  LEll := Ellipse2D(
    Point2D(Ell.Cen.X - Cir.Cen.X, Ell.Cen.y - Cir.Cen.Y),
    Ell.Rx, Ell.Ry,
    FixAngle(Ell.Ang1),
    FixAngle(Ell.Ang2),
    FixAngle(Ell.Rot)
  );

  FCalcCirEllEquationParms(LEll, Cir.R,   XA, XB, XC, XD, XE);

  EqCosX := UdMath.Equation(XA, XB, XC, XD, XE);
  if EqCosX.L <= 0 then
  begin
    if IsEqual(LEll.Cen.X, 0.0) or IsEqual(LEll.Cen.Y, 0.0) then
    begin
      Swap(LEll.RX, LEll.RY);
      LEll.Rot := FixAngle(LEll.Rot + 90);

      FCalcCirEllEquationParms(LEll, Cir.R,   XA, XB, XC, XD, XE);
      EqCosX := UdMath.Equation(XA, XB, XC, XD, XE);
    end;
  end;

  if EqCosX.L <= 0 then Exit; //======>>>

  for I := 0 to EqCosX.L - 1 do
  begin
    if IsEqual(EqCosX.X[I], 1.0) then EqCosX.X[I] := 1.0;
    if Abs(EqCosX.X[I]) > 1.0 then Continue;

    AA := ArcCosD(EqCosX.X[I]);

    _AppendResult(Result, LEll,  AA);
    _AppendResult(Result, LEll, -AA);
  end;

  if (Ell.Kind in [akSector, akChord]) and (NotEqual(Ell.Ang1, 0.0) or NotEqual(Ell.Ang2, 360.0)) then
  begin
    P1 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang1);
    P2 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang2);
    if Ell.Kind = akChord then
      FAddArray(Result, Intersection(Segment2D(P1, P2), Cir))
    else begin
      FAddArray(Result, Intersection(Segment2D(P1, Ell.Cen), Cir));
      FAddArray(Result, Intersection(Segment2D(P2, Ell.Cen), Cir));
    end;
  end;   
end;

class function TUdInct2D.Intersection(Arc: TArc2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, L: Integer;
  LAng: Float;
  LPnts: TPoint2DArray;
  P1, P2: TPoint2D;
begin
  LPnts := Intersection(Circle2D(Arc.Cen, Arc.R), Ell, Epsilon);

  L := 0;
  System.SetLength(Result, System.Length(LPnts));
  for I := 0 to System.Length(LPnts) - 1 do
  begin
    LAng := GetAngle(Arc.Cen, LPnts[I]);
    if IsInAngles(LAng, Arc.Ang1, Arc.Ang2) then
    begin
      Result[L] := LPnts[I];
      L := L + 1;
    end;
  end;
  System.SetLength(Result, L);

  if Arc.Kind in [akSector, akChord] then
  begin
    P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
    P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);

    if Arc.Kind = akChord then
      FAddArray(Result, Intersection(Segment2D(P1, P2), Ell))
    else begin
      FAddArray(Result, Intersection(Segment2D(P1, Arc.Cen), Ell));
      FAddArray(Result, Intersection(Segment2D(P2, Arc.Cen), Ell));
    end;
  end;
end;

class function TUdInct2D.Intersection(Rect: TRect2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;

  procedure FIntersection(ASeg: TSegment2D);
  var
    I: Integer;
    LPnts: TPoint2DArray;
  begin
    LPnts := Intersection(ASeg, Ell, Epsilon);
    for I := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[I];
    end;
  end;

begin
  Result := nil;

  with Rect do
  begin
    FIntersection(Segment2D(X1, Y1, X2, Y1));
    FIntersection(Segment2D(X2, Y1, X2, Y2));
    FIntersection(Segment2D(X2, Y2, X1, Y2));
    FIntersection(Segment2D(X1, Y2, X1, Y1));
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;



procedure FCalcEllEllEquationParms(Ell: TEllipse2D; Ra, Rb: Float; var XA, XB, XC, XD, XE: Extended);
var
  RoSin, RoCos: Extended;
  A1, A2, B1, B2: Float;
  A, B, C, D, E, F: Float;
begin
  SinCosD(Ell.Rot, RoSin, RoCos);

  A1 := Ell.Rx * RoCos;
  B1 := Ell.Ry * RoSin;

  A2 := Ell.Rx * RoSin;
  B2 := Ell.Ry * RoCos;


  A := Rb*Rb*A1*A1 + Ra*Ra*A2*A2    ;
  B := Rb*Rb*B1*B1 + Ra*Ra*B2*B2    ;
  C := 2*Ra*Ra*A2*B2 - 2*Rb*Rb*A1*B1;
  D := 2*Rb*Rb*Ell.Cen.X*A1 + 2*Ra*Ra*Ell.Cen.Y*A2;
  E := 2*Ra*Ra*Ell.Cen.Y*B2 - 2*Rb*Rb*Ell.Cen.X*B1;
  F := Rb*Rb*Ell.Cen.X*Ell.Cen.X + Ra*Ra*Ell.Cen.Y*Ell.Cen.Y - Ra*Ra*Rb*Rb;


  XA := Sqr(A - B) + C*C ;
  XB := 2*D*(A-B) + 2*E*C;
  XC := D*D + 2*(F+B)*(A-B) - C*C + E*E;
  XD := 2*(F+B)*D - 2*E*C;
  XE := Sqr(F+B) - E*E   ;
end;

class function TUdInct2D.Intersection(Ell1, Ell2: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;

  procedure _AppendResult(var Return: TPoint2DArray; AEll1, AEll2: TEllipse2D; ARot: Float; Ang: Float);
  var
    L: Integer;
    Pnt: TPoint2D;
  begin
    if FIsInEllAnges(Ang, AEll2) then
    begin
      Pnt := GetEllipsePoint(AEll2.Cen, AEll2.Rx, AEll2.Ry, AEll2.Rot, Ang);
      if NotEqual(ARot, 0.0) then Pnt := Rotate(ARot, Pnt);
      
      Pnt := Translate(AEll1.Cen.X, AEll1.Cen.Y, Pnt);

      if IsPntOnEllipse(Pnt, AEll1, Epsilon) then
      begin
        L := System.Length(Return);
        System.SetLength(Result, L+1);
        Result[L] := Pnt;
      end;
    end;
  end;

var
  I: Integer;
  Ra, Rb, AA: Float;
  LCen: TPoint2D;
  LRot, LRot1, LRot2: Float;
  LEll1, LEll2: TEllipse2D;
  XA, XB, XC, XD, XE: Extended;
  EqCosX: TEqResult;
  P1, P2: TPoint2D;
begin
  Result := nil;

  LRot := 0.0;
  LRot1 := FixAngle(Ell1.Rot);
  LRot2 := FixAngle(Ell2.Rot);

  if IsEqual(LRot1, 0.0) or IsEqual(LRot1, 90.0) or IsEqual(LRot1, 180.0) or IsEqual(LRot1, 270.0) or IsEqual(LRot1, 360.0) then
  begin
    Ra := Ell1.Rx;
    Rb := Ell1.Ry;
    LEll1 := Ell1;
    LEll2 := Ell2;
    if IsEqual(LRot1, 90.0) or IsEqual(LRot1, 270.0) then Swap(Ra, Rb);
  end else
  if IsEqual(LRot2, 0.0) or IsEqual(LRot2, 90.0) or IsEqual(LRot2, 180.0) or IsEqual(LRot2, 270.0) or IsEqual(LRot2, 360.0) then
  begin
    Ra := Ell2.Rx;
    Rb := Ell2.Ry;
    LEll1 := Ell2;
    LEll2 := Ell1;
    if IsEqual(LRot2, 90.0) or IsEqual(LRot2, 270.0) then Swap(Ra, Rb);
  end
  else begin
    LRot := FixAngle(Ell1.Rot);
    Ra := Ell1.Rx;
    Rb := Ell1.Ry;
    LEll1 := Ell1;
    LEll2 := Ell2;
  end;

  LCen := Point2D(LEll2.Cen.X - LEll1.Cen.X, LEll2.Cen.Y - LEll1.Cen.Y);
  if NotEqual(LRot, 0.0) then LCen := Rotate(-LRot, LCen);

  LEll2 := Ellipse2D(
    LCen,
    LEll2.Rx, LEll2.Ry,
    FixAngle(LEll2.Ang1),
    FixAngle(LEll2.Ang2),
    FixAngle(LEll2.Rot - LRot)
  );


  FCalcEllEllEquationParms(LEll2, Ra, Rb,   XA, XB, XC, XD, XE);

  EqCosX := UdMath.Equation(XA, XB, XC, XD, XE);
  if EqCosX.L <= 0 then
  begin
    if IsEqual(LEll2.Cen.X, 0.0) or IsEqual(LEll2.Cen.Y, 0.0) then
    begin
      Swap(LEll2.RX, LEll2.RY);
      LEll2.Rot := FixAngle(LEll2.Rot + 90);

      if NotEqual(LEll2.Ang1, 0.0) or NotEqual(LEll2.Ang2, 360.0) then
      begin
        LEll2.Ang1 := FixAngle(LEll2.Ang1 - 90);
        LEll2.Ang2 := FixAngle(LEll2.Ang2 - 90);
      end;

      FCalcEllEllEquationParms(LEll2, Ra, Rb,   XA, XB, XC, XD, XE);
      EqCosX := UdMath.Equation(XA, XB, XC, XD, XE);
    end;
  end;

  if EqCosX.L <= 0 then Exit; //======>>>

  for I := 0 to EqCosX.L - 1 do
  begin
    if Abs(EqCosX.X[I]) > 1.0 then Continue;

    AA := ArcCosD(EqCosX.X[I]);

    _AppendResult(Result, LEll1, LEll2, LRot,  AA);
    _AppendResult(Result, LEll1, LEll2, LRot, -AA);
  end;

  if (Ell1.Kind in [akSector, akChord]) and (NotEqual(Ell1.Ang1, 0.0) or NotEqual(Ell1.Ang2, 360.0)) then
  begin
    P1 := GetEllipsePoint(Ell1.Cen, Ell1.Rx, Ell1.Ry, Ell1.Rot, Ell1.Ang1);
    P2 := GetEllipsePoint(Ell1.Cen, Ell1.Rx, Ell1.Ry, Ell1.Rot, Ell1.Ang2);

    if Ell1.Kind = akChord then
      FAddArray(Result, Intersection(Segment2D(P1, P2), Ell2))
    else begin
      FAddArray(Result, Intersection(Segment2D(P1, Ell1.Cen), Ell2));
      FAddArray(Result, Intersection(Segment2D(P2, Ell1.Cen), Ell2));
    end;
  end;

  if (Ell2.Kind in [akSector, akChord]) and (NotEqual(Ell2.Ang1, 0.0) or NotEqual(Ell2.Ang2, 360.0)) then
  begin
    P1 := GetEllipsePoint(Ell2.Cen, Ell2.Rx, Ell2.Ry, Ell2.Rot, Ell2.Ang1);
    P2 := GetEllipsePoint(Ell2.Cen, Ell2.Rx, Ell2.Ry, Ell2.Rot, Ell2.Ang2);

    if Ell2.Kind = akChord then
      FAddArray(Result, Intersection(Segment2D(P1, P2), Ell1))
    else begin
      FAddArray(Result, Intersection(Segment2D(P1, Ell2.Cen), Ell1));
      FAddArray(Result, Intersection(Segment2D(P2, Ell2.Cen), Ell1));
    end;
  end;
end;

class function TUdInct2D.Intersection(Ell: TEllipse2D; Poly: TPoint2DArray;  const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;

  for I := 0 to System.Length(Poly) - 2 do
  begin
    LPnts := Intersection(Segment2D(Poly[I], Poly[I+1]), Ell, Epsilon);
    for J := 0 to System.Length(LPnts) - 1 do
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LPnts[J];
    end;
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;




class function TUdInct2D.Intersection(Ln: TLineK; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc.IsArc then
    Result := Intersection(Ln, Segarc.Arc, Epsilon)
  else
    Result := Intersection(Ln, Segarc.Seg, Epsilon);
end;

class function TUdInct2D.Intersection(Ln: TLine2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc.IsArc then
    Result := Intersection(Ln, Segarc.Arc, Epsilon)
  else
    Result := Intersection(Ln, Segarc.Seg, Epsilon);
end;

class function TUdInct2D.Intersection(Seg: TSegment2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc.IsArc then
    Result := Intersection(Seg, Segarc.Arc, Epsilon)
  else
    Result := Intersection(Seg, Segarc.Seg, Epsilon);
end;

class function TUdInct2D.Intersection(Cir: TCircle2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc.IsArc then
    Result := Intersection(Cir, Segarc.Arc, Epsilon)
  else
    Result := Intersection(Segarc.Seg, Cir, Epsilon);
end;

class function TUdInct2D.Intersection(Arc: TArc2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc.IsArc then
    Result := Intersection(Segarc.Arc, Arc, Epsilon)
  else
    Result := Intersection(Segarc.Seg, Arc, Epsilon);
end;

class function TUdInct2D.Intersection(Rect: TRect2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc.IsArc then
    Result := Intersection(Rect, Segarc.Arc, Epsilon)
  else
    Result := Intersection(Segarc.Seg, Rect, Epsilon);
end;

class function TUdInct2D.Intersection(Ell: TEllipse2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc.IsArc then
    Result := Intersection(Segarc.Arc, Ell, Epsilon)
  else
    Result := Intersection(Segarc.Seg, Ell, Epsilon);
end;

class function TUdInct2D.Intersection(Poly: TPoint2DArray; Segarc: TSegarc2D;const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc.IsArc then
  begin
    Result := Intersection(Segarc.Arc, Poly, Epsilon);
  end
  else begin
    Result := Intersection(Segarc.Seg, Poly, Epsilon);
  end;
end;

class function TUdInct2D.Intersection(Segarc1, Segarc2: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc1.IsArc then
  begin
    if Segarc2.IsArc then
      Result := Intersection(Segarc1.Arc, Segarc2.Arc, Epsilon)
    else
      Result := Intersection(Segarc2.Seg, Segarc1.Arc, Epsilon);
  end
  else begin
    if Segarc2.IsArc then
      Result := Intersection(Segarc1.Seg, Segarc2.Arc, Epsilon)
    else
      Result := Intersection(Segarc1.Seg, Segarc2.Seg, Epsilon);
  end;
end;

class function TUdInct2D.Intersection(Segarc: TSegarc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  if Segarc.IsArc then
  begin
    Result := Intersection(Segarc.Arc, Segarcs, Epsilon);
  end
  else begin
    Result := Intersection(Segarc.Seg, Segarcs, Epsilon);
  end;
end;



class function TUdInct2D.Intersection(Ln: TLineK; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  N, M: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    LPnts := Intersection(Ln, Segarcs[I], Epsilon);

    M := System.Length(LPnts);
    if M <= 0 then Continue;

    N := System.Length(Result);
    System.SetLength(Result, M + N);

    for J := 0 to M - 1 do
      Result[N + J] := LPnts[J];
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Ln: TLine2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  N, M: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    LPnts := Intersection(Ln, Segarcs[I], Epsilon);

    M := System.Length(LPnts);
    if M <= 0 then Continue;

    N := System.Length(Result);
    System.SetLength(Result, M + N);

    for J := 0 to M - 1 do
      Result[N + J] := LPnts[J];
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Seg: TSegment2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  N, M: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    LPnts := Intersection(Seg, Segarcs[I], Epsilon);

    M := System.Length(LPnts);
    if M <= 0 then Continue;

    N := System.Length(Result);
    System.SetLength(Result, M + N);

    for J := 0 to M - 1 do
      Result[N + J] := LPnts[J];
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Cir: TCircle2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  N, M: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    LPnts := Intersection(Cir, Segarcs[I], Epsilon);

    M := System.Length(LPnts);
    if M <= 0 then Continue;

    N := System.Length(Result);
    System.SetLength(Result, M + N);

    for J := 0 to M - 1 do
      Result[N + J] := LPnts[J];
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Arc: TArc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  N, M: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    LPnts := Intersection(Arc, Segarcs[I], Epsilon);

    M := System.Length(LPnts);
    if M <= 0 then Continue;

    N := System.Length(Result);
    System.SetLength(Result, M + N);

    for J := 0 to M - 1 do
      Result[N + J] := LPnts[J];
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Rect: TRect2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  N, M: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    LPnts := Intersection(Rect, Segarcs[I], Epsilon);

    M := System.Length(LPnts);
    if M <= 0 then Continue;

    N := System.Length(Result);
    System.SetLength(Result, M + N);

    for J := 0 to M - 1 do
      Result[N + J] := LPnts[J];
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Ell: TEllipse2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  N, M: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    LPnts := Intersection(Ell, Segarcs[I], Epsilon);

    M := System.Length(LPnts);
    if M <= 0 then Continue;

    N := System.Length(Result);
    System.SetLength(Result, M + N);

    for J := 0 to M - 1 do
      Result[N + J] := LPnts[J];
  end;

  Result := UdMath.TrimPoints(Result, Epsilon);
end;

class function TUdInct2D.Intersection(Poly: TPolygon2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J, K: Longint;
  N, M, L: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  if (System.Length(Poly) < 3) or (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  L := System.Length(Poly) - 1;

  for I := 0 to System.Length(Poly) - 1 do
  begin
    for J := 0 to System.Length(Segarcs) - 1 do
    begin
      LPnts := Intersection(Segment2D(Poly[I], Poly[L]), Segarcs[J], Epsilon);

      M := System.Length(LPnts);
      if M <= 0 then Continue;

      N := System.Length(Result);
      System.SetLength(Result, M + N);

      for K := 0 to M - 1 do
        Result[N + K] := LPnts[K];
    end;

    L := I;
  end;
end;

//class function TUdInct2D.Intersection(Poly: TPolygon2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
//var
//  I: Longint;
//  M, K: Longint;
//  LPnts: TPoint2DArray;
//begin
//  Result := nil;
//  if (System.Length(Segarcs) <= 0) or (System.Length(Poly) <= 0) then Exit;  //---->>>>
//
//  for I := 0 to System.Length(Segarcs) - 1 do
//  begin
//    LPnts := Intersection(Segarcs[I], Poly);
//
//    M := System.Length(LPnts);
//    if M <= 0 then Continue;
//
//    N := System.Length(Result);
//    System.SetLength(Result, M + N);
//
//    for K := 0 to M - 1 do
//      Result[N + K] := LPnts[K];
//  end;
//end;

class function TUdInct2D.Intersection(Segarcs1, Segarcs2: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I, J: Longint;
  N, M, K: Longint;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  if (System.Length(Segarcs1) <= 0) or (System.Length(Segarcs2) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(Segarcs1) - 1 do
  begin
    for J := 0 to System.Length(Segarcs2) - 1 do
    begin
      LPnts := Intersection(Segarcs1[I], Segarcs2[J], Epsilon);

      M := System.Length(LPnts);
      if M <= 0 then Continue;

      N := System.Length(Result);
      System.SetLength(Result, M + N);

      for K := 0 to M - 1 do
        Result[N + K] := LPnts[K];
    end;
  end;
end;





end.