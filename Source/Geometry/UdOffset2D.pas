{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdOffset2D;

{$I UdGeoDefs.INC}

interface

uses
  {$IFDEF UdTypes}UdTypes ,{$ENDIF} UdGTypes;

type
  TUdOffset2D = class
  public
    class function OffsetSegment(Seg: TSegment2D; Dis: Float; ALeftSide: Boolean): TSegment2D; overload;
    class function OffsetSegment(Seg: TSegment2D; Wid: Float; out Seg1, Seg2: TSegment2D): Boolean; overload;

    class function OffsetArc(Arc: TArc2D; Dis: Float; ALeftSide: Boolean): TArc2D; overload;
    class function OffsetArc(Arc: TArc2D; Wid: Float; out Arc1, Arc2: TArc2D): Boolean; overload;

    class function OffsetEllipse(Ell: TEllipse2D; Dis: Float; ALeftSide: Boolean): TEllipse2D; overload;
    class function OffsetEllipse(Ell: TEllipse2D; Wid: Float; out Ell1, Ell2: TEllipse2D): Boolean; overload;

    class function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float; ALeftSide: Boolean): TSegarc2DArray;  overload;
    class function OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray; ALeftSide: Boolean): TSegarc2DArray; overload;

    class function OffsetPoints(Poly: TPoint2DArray; Dis: Float; ALeftSide: Boolean): TPoint2DArray;  overload;
    class function OffsetPoints(Poly: TPoint2DArray; Dises: TFloatArray; ALeftSide: Boolean): TPoint2DArray;  overload;

    class function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float): TSegarc2DArray;  overload;
    class function OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray): TSegarc2DArray; overload;

    class function OffsetPolygon(Poly: TPoint2DArray; Dis: Float): TPoint2DArray;  overload;
    class function OffsetPolygon(Poly: TPoint2DArray; Dises: TFloatArray): TPoint2DArray;  overload;

    class function OffsetSegarc(Segarc: TSegarc2D; Dis: Float; ALeftSide: Boolean): TSegarc2D; //overload;

    class function OffsetSegment(Seg: TSegment2D; Dis: Float; ASidePnt: TPoint2D): TSegment2D; overload;
    class function OffsetArc(Arc: TArc2D; Dis: Float; ASidePnt: TPoint2D): TArc2D; overload;
    class function OffsetEllipse(Ell: TEllipse2D; Dis: Float; ASidePnt: TPoint2D): TEllipse2D; overload;
    class function OffsetPoints(Poly: TPoint2DArray; Dis: Float; ASidePnt: TPoint2D): TPoint2DArray;  overload;
    class function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float; ASidePnt: TPoint2D): TSegarc2DArray;  overload;
  end;

implementation

uses
  UdMath, UdGeo2D;



class function TUdOffset2D.OffsetSegment(Seg: TSegment2D; Dis: Float; ALeftSide: Boolean): TSegment2D;
var
  A, Ang: Float;
begin
  Ang := GetAngle(Seg.P1, Seg.P2);
  if ALeftSide then A := 90.0 else A := -90.0;

  Result.P1 := ShiftPoint(Seg.P1, Ang + A, Dis);
  Result.P2 := ShiftPoint(Seg.P2, Ang + A, Dis);
end;

class function TUdOffset2D.OffsetSegment(Seg: TSegment2D; Wid: Float; out Seg1, Seg2: TSegment2D): Boolean;
var
  Ang: Float;
begin
  Ang := GetAngle(Seg.P1, Seg.P2);

  Seg1.P1 := ShiftPoint(Seg.P1, Ang + 90, (Wid / 2));
  Seg1.P2 := ShiftPoint(Seg.P2, Ang + 90, (Wid / 2));

  Seg2.P1 := ShiftPoint(Seg.P1, Ang - 90, (Wid / 2));
  Seg2.P2 := ShiftPoint(Seg.P2, Ang - 90, (Wid / 2));

  Result := True;
end;


class function TUdOffset2D.OffsetArc(Arc: TArc2D; Dis: Float; ALeftSide: Boolean): TArc2D;
begin
  Result := Arc;

  if ALeftSide = Arc.IsCW then
    Result.R := Result.R + Dis
  else
    Result.R := Result.R - Dis;
end;

class function TUdOffset2D.OffsetArc(Arc: TArc2D; Wid: Float; out Arc1, Arc2: TArc2D): Boolean;
begin
  Arc1 := Arc;
  Arc1.R := Arc1.R - Wid / 2;

  Arc2 := Arc;
  Arc2.R := Arc2.R + Wid / 2;

  Result := True;
end;




class function TUdOffset2D.OffsetEllipse(Ell: TEllipse2D; Dis: Float; ALeftSide: Boolean): TEllipse2D;
begin
  Result := Ell;

  if ALeftSide = Ell.IsCW then
  begin
    Result.Rx := Result.Rx + Dis;
    Result.Ry := Result.Ry + Dis;
  end
  else begin
    Result.Rx := Result.Rx - Dis;
    Result.Ry := Result.Ry - Dis;
  end;
end;

class function TUdOffset2D.OffsetEllipse(Ell: TEllipse2D; Wid: Float; out Ell1, Ell2: TEllipse2D): Boolean;
begin
  Ell1 := OffsetEllipse(Ell, -Wid / 2, True);
  Ell2 := OffsetEllipse(Ell, +Wid / 2, True);
  Result := True;
end;








//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


class function TUdOffset2D.OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray; ALeftSide: Boolean): TSegarc2DArray;
const
  PARALLEL_ANG_EPSION = 0.5;

  //1 is Line;  2 is Arc

  function _Calc11(var ASegarc1, ASegarc2: TSegarc2D): Integer;
  var
    A1, A2: Float;
    LInctPnts: TPoint2DArray;
  begin
    A1 := UdMath.SgnAngle(GetAngle(ASegarc1.Seg.P1, ASegarc1.Seg.P2));
    A2 := UdMath.SgnAngle(GetAngle(ASegarc2.Seg.P1, ASegarc2.Seg.P2));

    LInctPnts := Intersection(ASegarc1.Seg.P1, ASegarc1.Seg.P2, ASegarc2.Seg.P1, ASegarc2.Seg.P2);

    if System.Length(LInctPnts) = 1 then
    begin
      if not IsEqual(A1, A2, PARALLEL_ANG_EPSION) {and
      ((Distance(Segarc1.Seg.P2, InctPnts[0]) <  2 * (D1 + D2)) or (Distance(Segarc2.Seg.P1, InctPnts[0]) <  2* (D1 + D2)))}then
      begin
        ASegarc1.Seg.P2 := LInctPnts[0];
        ASegarc2.Seg.P1 := LInctPnts[0];
      end;
    end;

    Result := 1;
  end;

  function _Calc12(var ASegarc1, ASegarc2: TSegarc2D): Integer;
  var
    A: Float;
    LArc: TArc2D;
    LPnt: TPoint2D;
    LInctPnts: TPoint2DArray;
  begin
    LArc := ASegarc2.Arc;

    LInctPnts := Intersection(Line2D(ASegarc1.Seg.P1, ASegarc1.Seg.P2), ASegarc2.Arc);
    if System.Length(LInctPnts) <= 0 then
      LInctPnts := Intersection(Line2D(ASegarc1.Seg.P1, ASegarc1.Seg.P2), Circle2D(ASegarc2.Arc.Cen, ASegarc2.Arc.R));

    if System.Length(LInctPnts) = 2 then
    begin
      LPnt := ASegarc1.Seg.P1;
      if Distance(LPnt, LInctPnts[0]) > Distance(LPnt, LInctPnts[1]) then LInctPnts[0] := LInctPnts[1];
      System.SetLength(LInctPnts, 1);
    end;

    if System.Length(LInctPnts) = 1 then
    begin
      ASegarc1.Seg.P2 := LInctPnts[0];

      A := GetAngle(LArc.Cen, LInctPnts[0]);
      if LArc.IsCW then
        LArc.Ang2 := A
      else
        LArc.Ang1 := A;
      ASegarc2 := Segarc2D(LArc);
    end;

    Result := 1;
  end;

  function _Calc21(var ASegarc1, ASegarc2: TSegarc2D): Integer;
  var
    A: Float;
    LArc: TArc2D;
    LPnt: TPoint2D;
    LInctPnts: TPoint2DArray;
  begin
    LArc := ASegarc1.Arc;

    LInctPnts := Intersection(Line2D(ASegarc2.Seg.P1, ASegarc2.Seg.P2), ASegarc1.Arc);
    if System.Length(LInctPnts) <= 0 then
      LInctPnts := Intersection(Line2D(ASegarc2.Seg.P1, ASegarc2.Seg.P2), Circle2D(ASegarc1.Arc.Cen, ASegarc1.Arc.R));

    if System.Length(LInctPnts) = 2 then
    begin
      LPnt := ASegarc1.Seg.P2;
      if Distance(LPnt, LInctPnts[0]) > Distance(LPnt, LInctPnts[1]) then LInctPnts[0] := LInctPnts[1];
      System.SetLength(LInctPnts, 1);
    end;

    if System.Length(LInctPnts) = 1 then
    begin
      ASegarc2.Seg.P1 := LInctPnts[0];

      A := GetAngle(LArc.Cen, LInctPnts[0]);
      if LArc.IsCW then
        LArc.Ang1 := A
      else
        LArc.Ang2 := A;
      ASegarc1 := Segarc2D(LArc);
    end;

    Result := 1;
  end;

  function _Calc22(var ASegarc1, ASegarc2: TSegarc2D): Integer;
  var
    A: Float;
    LPnt: TPoint2D;
    LArc1, LArc2: TArc2D;
    LInctPnts: TPoint2DArray;
  begin
    LArc1 := ASegarc1.Arc;
    LArc2 := ASegarc2.Arc;

    LInctPnts := Intersection(Circle2D(LArc1.Cen, LArc1.R), Circle2D(LArc2.Cen, LArc2.R));

    if System.Length(LInctPnts) = 2 then
    begin
      if LArc1.IsCW then
        A := LArc1.Ang1
      else
        A := LArc1.Ang2;
      LPnt := ShiftPoint(LArc1.Cen, A, LArc1.R);

      if Distance(LPnt, LInctPnts[0]) > Distance(LPnt, LInctPnts[1]) then LInctPnts[0] := LInctPnts[1];
      System.SetLength(LInctPnts, 1);
    end;

    if System.Length(LInctPnts) = 1 then
    begin
      A := GetAngle(LArc1.Cen, LInctPnts[0]);
      if LArc1.IsCW then
        LArc1.Ang1 := A
      else
        LArc1.Ang2 := A;
      ASegarc1 := Segarc2D(LArc1);

      A := GetAngle(LArc2.Cen, LInctPnts[0]);
      if LArc2.IsCW then
        LArc2.Ang2 := A
      else
        LArc2.Ang1 := A;
      ASegarc2 := Segarc2D(LArc2);
    end;

    Result := 1;
  end;

  function _CalcSegarc(var ASegarc1, ASegarc2: TSegarc2D): Integer;
  begin
    if not ASegarc1.IsArc and not ASegarc2.IsArc then
      Result := _Calc11(ASegarc1, ASegarc2)
    else if not ASegarc1.IsArc and ASegarc2.IsArc then
      Result := _Calc12(ASegarc1, ASegarc2)
    else if ASegarc1.IsArc and not ASegarc2.IsArc then
      Result := _Calc21(ASegarc1, ASegarc2)
    else
      Result := _Calc22(ASegarc1, ASegarc2);
  end;

  function _CalcSegarcs(var AReturn: TSegarc2DArray; AClosed: Boolean): Boolean;
  var
    I: Integer;
  begin
    I := 0;
    while I < System.Length(AReturn) - 1 do
      I := I + _CalcSegarc(AReturn[I], AReturn[I + 1]);

    if AClosed then
      _CalcSegarc(AReturn[High(AReturn)], AReturn[0]);
    Result := True;
  end;

var
  I, L, N: Integer;
  LClosed: Boolean;
  LSegarcs: TSegarc2DArray;
  LSegarc1, LSegarc2: TSegarc2D;  
begin
  Result := nil;
  if System.Length(Segarcs) <= 0 then Exit;

  if System.Length(Dises) <= 0 then
  begin
    Result := Segarcs;
    Exit; //======>>>>
  end;

  if System.Length(Dises) < System.Length(Segarcs) then
  begin
    L := System.Length(Dises);

    System.SetLength(Dises, System.Length(Segarcs));
    for I := L to System.Length(Segarcs) - 1 do Dises[I] := Dises[L-1];
  end;

  System.SetLength(LSegarcs, System.Length(Segarcs));
  for I := 0 to System.Length(Segarcs) - 1 do
    LSegarcs[I] := OffsetSegarc(Segarcs[I], Dises[I], ALeftSide);

  LClosed := UdMath.IsEqual(Segarcs[0].Seg.P1, Segarcs[High(Segarcs)].Seg.P2);
  _CalcSegarcs(LSegarcs, LClosed);

  L := 0;
  System.SetLength(Result, System.Length(LSegarcs)*2 );

  for I := 0 to System.Length(LSegarcs) - 1 do
  begin
    N := (I+1) mod System.Length(LSegarcs);
    
    LSegarc1 := LSegarcs[I];
    LSegarc2 := LSegarcs[N];

    Result[L] := LSegarc1;

    if (N <> 0) or (LClosed and (N = 0)) then
    begin
      if NotEqual(LSegarc1.Seg.P2, LSegarc2.Seg.P1) then
      begin
        Result[L+1] := Segarc2D(LSegarc1.Seg.P2, LSegarc2.Seg.P1);
        L := L + 1;
      end;
    end;

    L := L + 1;
  end;

  System.SetLength(Result, L);   
end;



class function TUdOffset2D.OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float; ALeftSide: Boolean): TSegarc2DArray;
var
  I: Integer;
  Dises: TFloatArray;
begin
  System.SetLength(Dises, System.Length(Segarcs));
  for I := 0 to System.Length(Segarcs) - 1 do Dises[I] := Dis;
  Result := OffsetSegarcs(Segarcs, Dises, ALeftSide);
end;




class function TUdOffset2D.OffsetPoints(Poly: TPoint2DArray; Dises: TFloatArray; ALeftSide: Boolean): TPoint2DArray;
var
  I: Integer;
  LSegarcs: TSegarc2DArray;
begin
  System.SetLength(LSegarcs, System.Length(Poly) - 1);
  for I := 0 to System.Length(Poly) - 2 do
    LSegarcs[I] := Segarc2D(Poly[I], Poly[I+1]);
  LSegarcs := OffsetSegarcs(LSegarcs, Dises, ALeftSide);

  System.SetLength(Result, System.Length(LSegarcs)+1);

  Result[0] := LSegarcs[0].Seg.P1;
  for I := 0 to System.Length(LSegarcs) -1 do
    Result[I+1] := LSegarcs[I].Seg.P2;
end;


class function TUdOffset2D.OffsetPoints(Poly: TPoint2DArray; Dis: Float; ALeftSide: Boolean): TPoint2DArray;
var
  I, L: Integer;
  LDises: TFloatArray;
begin
  Result := nil;

  L := System.Length(Poly);
  if UdMath.IsEqual(Dis, 0.0) or (L <= 0) then
  begin
    Result := Poly;
    Exit; //====>>>>
  end;

  System.SetLength(LDises, L);
  for I := 0 to L - 1 do LDises[I] := Dis;

  Result := OffsetPoints(Poly, LDises, ALeftSide);
end;






class function TUdOffset2D.OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray): TSegarc2DArray;
var
  LPoly: TPolygon2D;
  LLeftSide: Boolean;
begin
  LPoly := SamplePoints(Segarcs, True);
  LLeftSide := IsClockWise(LPoly);
//  LLeftSide := IsPntInSegarcs(....)
  Result := OffsetSegarcs(Segarcs, Dises, LLeftSide);
end;

class function TUdOffset2D.OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float): TSegarc2DArray;
var
  I: Integer;
  Dises: TFloatArray;
begin
  System.SetLength(Dises, System.Length(Segarcs));
  for I := 0 to System.Length(Segarcs) - 1 do Dises[I] := Dis;
  Result := OffsetSegarcs(Segarcs, Dises);
end;



class function TUdOffset2D.OffsetPolygon(Poly: TPoint2DArray; Dises: TFloatArray): TPoint2DArray;
var
  I: Integer;
  LSegarcs: TSegarc2DArray;
begin
  System.SetLength(LSegarcs, System.Length(Poly) - 1);
  for I := 0 to System.Length(Poly) - 2 do
    LSegarcs[I] := Segarc2D(Poly[I], Poly[I+1]);
  LSegarcs := OffsetSegarcs(LSegarcs, Dises);

  System.SetLength(Result, System.Length(LSegarcs)+1);

  Result[0] := LSegarcs[0].Seg.P1;
  for I := 0 to System.Length(LSegarcs) -1 do
    Result[I+1] := LSegarcs[I].Seg.P2;
end;

class function TUdOffset2D.OffsetPolygon(Poly: TPoint2DArray; Dis: Float): TPoint2DArray;
var
  I, L: Integer;
  LDises: TFloatArray;
begin
  Result := nil;

  L := System.Length(Poly);
  if UdMath.IsEqual(Dis, 0.0) or (L <= 0) then
  begin
    Result := Poly;
    Exit; //====>>>>
  end;

  System.SetLength(LDises, L);
  for I := 0 to L - 1 do LDises[I] := Dis;

  Result := OffsetPolygon(Poly, LDises);
end;





class function TUdOffset2D.OffsetSegarc(Segarc: TSegarc2D; Dis: Float; ALeftSide: Boolean): TSegarc2D;
begin
  if Segarc.IsArc then
    Result := Segarc2D(OffsetArc(Segarc.Arc, Dis, ALeftSide))
  else
    Result := Segarc2D(OffsetSegment(Segarc.Seg, Dis, ALeftSide));
end;


//================================================================================================




class function TUdOffset2D.OffsetSegment(Seg: TSegment2D; Dis: Float; ASidePnt: TPoint2D): TSegment2D;
begin
  Result := OffsetSegment(Seg, Dis, UdGeo2D.IsPntOnLeftSide(ASidePnt, Seg.P1, Seg.P2)); 
end;

class function TUdOffset2D.OffsetArc(Arc: TArc2D; Dis: Float; ASidePnt: TPoint2D): TArc2D;
begin
  Result := OffsetArc(Arc, Dis, UdGeo2D.IsPntOnLeftSide(ASidePnt, Arc));
end;

class function TUdOffset2D.OffsetEllipse(Ell: TEllipse2D; Dis: Float; ASidePnt: TPoint2D): TEllipse2D;
begin
  Result := OffsetEllipse(Ell, Dis, UdGeo2D.IsPntOnLeftSide(ASidePnt, Ell));
end;

class function TUdOffset2D.OffsetPoints(Poly: TPoint2DArray; Dis: Float; ASidePnt: TPoint2D): TPoint2DArray;
var
  N: Integer;
  LLeftSide: Boolean;
begin
  ClosestPointsPoint(ASidePnt, Poly, N);
  LLeftSide := IsPntOnLeftSide(ASidePnt, Poly[N], Poly[N+1]);
  Result := OffsetPoints(Poly, Dis, LLeftSide);
end;

class function TUdOffset2D.OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float; ASidePnt: TPoint2D): TSegarc2DArray;
var
  N: Integer;
  LSegarc: TSegarc2D;
  LLeftSide: Boolean;
begin
  ClosestSegarcsPoint(ASidePnt, Segarcs, N);
  LSegarc := Segarcs[N];

  LLeftSide := IsPntOnLeftSide(ASidePnt, LSegarc);
  Result := OffsetSegarcs(Segarcs, Dis, LLeftSide);
end;


end.