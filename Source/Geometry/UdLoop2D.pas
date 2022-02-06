{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLoop2D;

{$I UdGeoDefs.INC}

interface

uses
  Classes, UdGTypes;

function UnionPolygons(APolys: TPoint2DArrays): TPolygon2D; overload;
function UnionPolygons(APoly1, APoly2: TPolygon2D; AOutsideReturnPoly1: Boolean = True): TPolygon2D; overload;
function UnionPolygons(APolys1, APolys2: TPolygon2DArray): TPolygon2DArray; overload;

function SubtractPolygons(APoly1, APoly2: TPolygon2D; var AHolePoly: TPolygon2D): TPolygon2D; overload;
function SubtractPolygons(APoly1, APoly2: TPolygon2D): TPolygon2D; overload;

function SubtractPolygons(APolys1, APolys2: TPolygon2DArray): TPolygon2DArray; overload;
function SubtractPolygons(APolys1, APolys2: TPolygon2DArray; var AHolePolys: TPolygon2DArray): TPolygon2DArray; overload;
function SubtractPolygons(APoly1: TPolygon2D; APolys2: TPolygon2DArray): TPolygon2DArray; overload;

function IntersectPolygons(APoly1, APoly2: TPolygon2D): TPolygon2DArray; overload;
function IntersectPolygons(APolys1, APolys2: TPolygon2DArray): TPolygon2DArray; overload;



function OffsetPolygon(Poly: TPolygon2D; Dises: TFloatArray): TPolygon2D; overload;
function OffsetPolygon(Poly: TPolygon2D; Dis: Float): TPolygon2D; overload;

//比UdGeo2D.OffsetSegarcs~6倍 但是更精确
function OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray): TSegarc2DArray; overload;
function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float): TSegarc2DArray; overload;




implementation

uses
  UdMath, UdGeo2D, UdLoopSearch;

const
  EPSILON_OFFSET = 0.1;



function UnionPolygons(APoly1, APoly2: TPolygon2D; AOutsideReturnPoly1: Boolean = True): TPolygon2D;
var
  R: TInclusion;
  LLoopSearch: TUdLoopSearch;
begin
  Result := nil;

  R := UdGeo2D.Inclusion(APoly1, APoly2);
  if R = irOutside then
  begin
    if AOutsideReturnPoly1 then Result := APoly1;
    Exit;
  end;

  if (R = irOvered) or (R = irEqual) then
    Result := APoly2
  else if (R = irCovered) then
    Result := APoly1
  else if (R = irIntsct) then
  begin
    LLoopSearch := TUdLoopSearch.Create(True, False);
    try
      LLoopSearch.Add(APoly1);
      LLoopSearch.Add(APoly2);
      LLoopSearch.Search();
      if System.Length(LLoopSearch.MaxPolygons) = 1 then
        Result := LLoopSearch.MaxPolygons[0];
    finally
      LLoopSearch.Free;
    end;
  end;
end;

function UnionPolygons(APolys: TPoint2DArrays): TPolygon2D;
var
  I: Integer;
  LLoopSearch: TUdLoopSearch;
begin
  Result := nil;
  if System.Length(APolys) <= 0 then Exit;

  if System.Length(APolys) = 1 then
  begin
    Result := APolys[0];
    Exit;
  end;

  LLoopSearch := TUdLoopSearch.Create(True, False);
  try
    for I := 0 to System.Length(APolys) - 1 do
      LLoopSearch.Add(APolys[I]);
    LLoopSearch.Search();

    if System.Length(LLoopSearch.MaxPolygons) = 1 then
      Result := LLoopSearch.MaxPolygons[0];
  finally
    LLoopSearch.Free;
  end;
end;


function UnionPolygons(APolys1, APolys2: TPolygon2DArray): TPolygon2DArray;
var
  I: Integer;
  LLoopSearch: TUdLoopSearch;
begin
  Result := nil;

  LLoopSearch := TUdLoopSearch.Create(True, False);
  try
    for I := 0 to System.Length(APolys1) - 1 do
      LLoopSearch.Add(APolys1[I]);
    for I := 0 to System.Length(APolys2) - 1 do
      LLoopSearch.Add(APolys2[I]);

    LLoopSearch.Search();
    if System.Length(LLoopSearch.MaxPolygons) > 0 then
    begin
      Result := LLoopSearch.MaxPolygons;
    end
    else begin
      FAddArray(Result, APolys1);
      FAddArray(Result, APolys2);
    end;
  finally
    LLoopSearch.Free;
  end;
end;




function SubtractPolygons(APoly1, APoly2: TPolygon2D; var AHolePoly: TPolygon2D): TPolygon2D;
var
  I: Integer;
  R: TInclusion;
  LLoopSearch: TUdLoopSearch;
begin
  Result := nil;

  R := UdGeo2D.Inclusion(APoly1, APoly2);
  if (R = irOutside) or (R = irOvered) or (R = irEqual) then Exit;  //====>>>

  if (R = irCovered) then
  begin
    AHolePoly := APoly2;
    Exit; //====>>>
  end
  else if (R = irIntsct) then
  begin
    LLoopSearch := TUdLoopSearch.Create(True, False);
    try
      LLoopSearch.Add(APoly1);
      LLoopSearch.Add(APoly2);
      LLoopSearch.Search();

      for I := 0 to System.Length(LLoopSearch.MinPolygons) - 1 do
      begin
        if (UdGeo2D.Inclusion(LLoopSearch.MinPolygons[I], APoly1) = irOvered) and
           (UdGeo2D.Inclusion(LLoopSearch.MinPolygons[I], APoly2) = irIntsct) then
        begin
          Result := LLoopSearch.MinPolygons[I];
          Break;
        end;
      end;
    finally
      LLoopSearch.Free;
    end;
  end;
end;

function SubtractPolygons(APoly1, APoly2: TPolygon2D): TPolygon2D;
var
  LHolePoly: TPolygon2D;
begin
  Result := SubtractPolygons(APoly1, APoly2, LHolePoly);
end;



function SubtractPolygons(APolys1, APolys2: TPolygon2DArray; var AHolePolys: TPolygon2DArray): TPolygon2DArray;
var
  R1, R2: TInclusion;
  I, J, L: Integer;
  LOk, LOk1, LOk2: Boolean;
  LPoints: TPoint2DArray;
  LLoopSearch: TUdLoopSearch;
begin
  Result := nil;
  LPoints := nil;
  AHolePolys := nil;

  L := 0;

  LLoopSearch := TUdLoopSearch.Create(True, False);
  try
    for I := 0 to System.Length(APolys1) - 1 do LLoopSearch.Add(APolys1[I]);
    for I := 0 to System.Length(APolys2) - 1 do LLoopSearch.Add(APolys2[I]);

    LLoopSearch.Search();

    for I := 0 to System.Length(LLoopSearch.MinPolygons) - 1 do
    begin
      LPoints := LLoopSearch.MinPolygons[I];

      R1 := irOutside;
      LOk1 := False;
      for J := 0 to System.Length(APolys1) - 1 do
      begin
        R1 := UdGeo2D.Inclusion(LPoints, APolys1[J], False);

        if (R1 = irOvered) or (R1 = irEqual) then
        begin
          LOk1 := True;
          Break;
        end;
      end; {end for J}

      R2 := irOutside;
      LOk2 := False;
      if LOk1 then
        for J := 0 to System.Length(APolys2) - 1 do
        begin
          R2 := UdGeo2D.Inclusion(LPoints, APolys2[J], False);

          if (R2 = irOvered) or (R2 = irEqual) then
          begin
            LOk2 := True;
            Break;
          end;
        end; {end for J}

      LOk := False;

      if LOk1 then
      begin
        if LOk2 then
        begin
          if (R1 = irOvered) and (R2 = irEqual) then
          begin
            System.SetLength(AHolePolys, System.Length(AHolePolys) + 1);
            AHolePolys[High(AHolePolys)] := LPoints;
          end;
        end
        else LOk := True;
      end;

      if LOk then
      begin
        System.SetLength(Result, L + 1);
        Result[L] := LPoints;

        L := L + 1;
      end;

    end; {end for I}
  finally
    LLoopSearch.Free;
  end;
end;

function SubtractPolygons(APolys1, APolys2: TPolygon2DArray): TPolygon2DArray;
var
  LHolePolygons: TPolygon2DArray;
begin
  Result := SubtractPolygons(APolys1, APolys2, LHolePolygons);
end;

function SubtractPolygons(APoly1: TPolygon2D; APolys2: TPolygon2DArray): TPolygon2DArray;
var
  LPolygons1: TPolygon2DArray;
  LHolePolygons: TPolygon2DArray;
begin
  System.SetLength(LPolygons1, 1);
  LPolygons1[0] := APoly1;

  Result := SubtractPolygons(LPolygons1, APolys2, LHolePolygons);
end;


function IntersectPolygons(APoly1, APoly2: TPolygon2D): TPolygon2DArray;
var
  R: TInclusion;
  I, L: Integer;
  LLoopSearch: TUdLoopSearch;
  LOffsetPoly1, LOffsetPoly2: TPolygon2D;
begin
  Result := nil;

  LOffsetPoly1 := nil;
  LOffsetPoly2 := nil;

  R := UdGeo2D.Inclusion(APoly1, APoly2);
  if (R = irOutside) then Exit;

  if (R = irOvered) or (R = irEqual) then
  begin
    System.SetLength(Result, 1);
    Result[0] := APoly1;
  end
  else if (R = irCovered) then
  begin
    System.SetLength(Result, 1);
    Result[0] := APoly2;
  end
  else if (R = irIntsct) then
  begin
    LOffsetPoly1 := UdLoop2D.OffsetPolygon(APoly1, EPSILON_OFFSET);
    LOffsetPoly2 := UdLoop2D.OffsetPolygon(APoly2, EPSILON_OFFSET);

    LLoopSearch := TUdLoopSearch.Create(True, False);
    try
      LLoopSearch.Add(APoly1);
      LLoopSearch.Add(APoly2);
      LLoopSearch.Search();

      L := 0;
      for I := 0 to System.Length(LLoopSearch.MinPolygons) - 1 do
      begin
        if (UdGeo2D.Inclusion(LLoopSearch.MinPolygons[I], LOffsetPoly1, False) = irOvered) and
           (UdGeo2D.Inclusion(LLoopSearch.MinPolygons[I], LOffsetPoly2, False) = irOvered) then
        begin
          System.SetLength(Result, L + 1);
          Result[L] := LLoopSearch.MinPolygons[I];
          L := L + 1;
        end;
      end;
    finally
      LLoopSearch.Free;
    end;
  end;
end;

function IntersectPolygons(APolys1, APolys2: TPolygon2DArray): TPolygon2DArray;
var
  R: TInclusion;
  I, J, L: Integer;
  OK1, OK2: Boolean;
  Lpoly: TPoint2DArray;
  LLoopSearch: TUdLoopSearch;
begin
  Result := nil;
  Lpoly := nil;

  L := 0;

  LLoopSearch := TUdLoopSearch.Create(True, False);
  try
    for I := 0 to System.Length(APolys1) - 1 do LLoopSearch.Add(APolys1[I]);
    for I := 0 to System.Length(APolys2) - 1 do LLoopSearch.Add(APolys2[I]);

    LLoopSearch.Search();

    for I := 0 to System.Length(LLoopSearch.MinPolygons) - 1 do
    begin
      Lpoly := LLoopSearch.MinPolygons[I];

      OK1 := False;
      for J := 0 to System.Length(APolys1) - 1 do
      begin
        R := UdGeo2D.Inclusion(Lpoly, APolys1[J], False);
        OK1 := (R = irOvered) or (R = irEqual);
        if OK1 then Break;
      end; {end for J}

      OK2 := False;
      if OK1 then
        for J := 0 to System.Length(APolys2) - 1 do
        begin
          R := UdGeo2D.Inclusion(Lpoly, APolys2[J], False);
          OK2 := (R = irOvered) or (R = irEqual);
          if OK2 then Break;
        end; {end for J}

      if OK1 and OK2 then
      begin
        System.SetLength(Result, L + 1);
        Result[L] := Lpoly;
        L := L + 1;
      end;

    end; {end for I}
  finally
    LLoopSearch.Free;
  end;
end;



//-----------------------------------------------------------------------------------------

  procedure _ModifySeg(var ASeg: TSegment2D; APnt: TPoint2D);
  begin
    if not IsPntOnSegment(APnt, ASeg) then
    begin
      if LayDistance(APnt, ASeg.P1) < LayDistance(APnt, ASeg.P2) then
        ASeg.P1 := APnt
      else
        ASeg.P2 := APnt;
    end;
  end;

  procedure _ExtendSeg(var ASeg1, ASeg2: TSegment2D);
  var
    LInctPnts: TPoint2DArray;
  begin
    LInctPnts := UdGeo2D.Intersection(Line2D(ASeg1.P1, ASeg1.P2), Line2D(ASeg2.P1, ASeg2.P2));
    if System.Length(LInctPnts) <= 0 then Exit;

    _ModifySeg(ASeg1, LInctPnts[0]);
    _ModifySeg(ASeg2, LInctPnts[0]);
  end;


  function _GetMaxPerIndex(APolys: TPolygon2DArray): Integer;
  var
    I: Integer;
    LPer, MPer: Float;
  begin
    Result := -1;
    
    MPer := 0.0;
    for I := 0 to System.Length(APolys) - 1 do
    begin
      LPer := Perimeter(APolys[I]);

      if I = 0 then
      begin
        Result := 0;
        MPer := LPer;
      end
      else begin
        if MPer < LPer then
        begin
          Result := I;
          MPer := LPer;
        end;
      end;
    end; {end for I}
  end;

function FOffsetPolygon(Poly: TPolygon2D; Dises: TFloatArray): TPolygon2D;
var
  I: Integer;
  A, D: Float;
  L, N: Integer;
  LIsCW: Boolean;
  LSeg: TSegment2D;
  LSegs: TSegment2DArray;
  LLoopSearch: TUdLoopSearch;
begin
  LSegs := nil;

  if System.Length(Dises) < System.Length(Poly) - 1 then
  begin
    Result := Poly;
    Exit;
  end;

  LIsCW := IsClockWise(Poly);
  System.SetLength(Result, System.Length(Poly));

  L := 0;
  for I := 0 to System.Length(Poly) - 2 do
  begin
    D := Dises[I];

    LSeg := Segment2D(Poly[I], Poly[I + 1]);
    if IsDegenerate(LSeg) then Continue;

    A := GetAngle(LSeg.P1, LSeg.P2);
    if LIsCW then A := A + 90 else A := A - 90;

    System.SetLength(LSegs, L + 1);
    LSegs[L].P1 := ShiftPoint(LSeg.P1, A, D);
    LSegs[L].P2 := ShiftPoint(LSeg.P2, A, D);
    L := L + 1;
  end;

  for I := 0 to System.Length(LSegs) - 2 do
    _ExtendSeg(LSegs[I], LSegs[I + 1]);
  if IsEqual(Poly[0], Poly[System.Length(Poly) - 1]) then
    _ExtendSeg(LSegs[System.Length(LSegs) - 1], LSegs[0]);

  LLoopSearch := TUdLoopSearch.Create(True, False);
  try
    for I := 0 to System.Length(LSegs) - 1 do LLoopSearch.Add(LSegs[I]);
    LLoopSearch.Search();

    N := _GetMaxPerIndex(LLoopSearch.MinPolygons);
    if N >= 0 then Result := LLoopSearch.MinPolygons[N];
  finally
    LLoopSearch.Free;
  end;
end;



function OffsetPolygon(Poly: TPolygon2D; Dises: TFloatArray): TPolygon2D;
begin
  Result := FOffsetPolygon(Poly, Dises);
end;

function OffsetPolygon(Poly: TPolygon2D; Dis: Float): TPolygon2D;
var
  I: Integer;
  Dises: TFloatArray;
begin
  System.SetLength(Dises, System.Length(Poly));
  for I := 0 to System.Length(Poly) - 1 do Dises[I] := Dis;
  Result := UdLoop2D.OffsetPolygon(Poly, Dises);
end;




//-----------------------------------------------------------------------------------------

  procedure _ModifyArc(var Arc: TArc2D; APnt: TPoint2D);
  var
    A: Float;
    LEndPnts: TPoint2DArray;
  begin
    A := GetAngle(Arc.Cen, APnt);
    if UdMath.IsInAngles(A, Arc.Ang1, Arc.Ang2) then Exit;

    LEndPnts := UdGeo2D.ArcEndPnts(Arc);
    if LayDistance(LEndPnts[0], APnt) < LayDistance(LEndPnts[1], APnt) then
      Arc.Ang1 := A
    else
      Arc.Ang2 := A
  end;



function FOffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray): TSegarc2DArray;


  procedure _Extend12(var ASeg: TSegment2D; var AArc: TArc2D; APnt: TPoint2D);
  var
    LInctPnts: TPoint2DArray;
  begin
    LInctPnts := UdGeo2D.Intersection(Line2D(ASeg.P1, ASeg.P2), Circle2D(AArc.Cen, AArc.R));
    if System.Length(LInctPnts) = 2 then
    begin
      if LayDistance(APnt, LInctPnts[0]) > LayDistance(APnt, LInctPnts[1]) then Swap(LInctPnts[0], LInctPnts[1]);
      System.SetLength(LInctPnts, 1);
    end;
    Assert(System.Length(LInctPnts) = 1);
    
    _ModifySeg(ASeg, LInctPnts[0]);
    _ModifyArc(AArc, LInctPnts[0]);
  end;

  procedure _Extend22(var AArc1, AArc2: TArc2D; APnt: TPoint2D);
  var
    LInctPnts: TPoint2DArray;
  begin
    LInctPnts := UdGeo2D.Intersection(Circle2D(AArc1.Cen, AArc1.R), Circle2D(AArc2.Cen, AArc2.R));
    if System.Length(LInctPnts) = 2 then
    begin
      if LayDistance(APnt, LInctPnts[0]) > LayDistance(APnt, LInctPnts[1]) then Swap(LInctPnts[0], LInctPnts[1]);
      System.SetLength(LInctPnts, 1);
    end;
    Assert(System.Length(LInctPnts) = 1);
    
    _ModifyArc(AArc1, LInctPnts[0]);
    _ModifyArc(AArc2, LInctPnts[0]);
  end;

  procedure _ExtendItem(ASeg1, ASeg2: PSegarc2D);
  begin
    if ASeg1^.IsArc then
    begin
      if ASeg2^.IsArc then
        _Extend22(ASeg1^.Arc, ASeg2^.Arc, UdGeo2D.ArcEndPnts(ASeg1^.Arc)[1])
      else
        _Extend12(ASeg2^.Seg, ASeg1^.Arc, ASeg2^.Seg.P1);
    end
    else begin
      if ASeg2^.IsArc then
        _Extend12(ASeg1^.Seg, ASeg2^.Arc, ASeg1^.Seg.P2)
      else
        _ExtendSeg(ASeg1^.Seg, ASeg2^.Seg);
    end;
  end;

  function _PopulateSegarcList(var ASegarcs: TList; AIsClose: Boolean): Boolean;
  var
    I: Integer;
    D, A, R: Float;
    LIsCW: Boolean;
    LPoints: TPolygon2D;
    LItem: PSegarc2D;    
  begin
    Result := False;
    if not Assigned(ASegarcs) then Exit;

    LPoints := SamplePoints(Segarcs, True);
    LIsCW := IsClockWise(LPoints);

    for I := 0 to System.Length(Segarcs) - 1 do
    begin
      D := Dises[I];

      if Segarcs[I].IsArc then
      begin
        if LIsCW <> Segarcs[I].Arc.IsCW then
          R := Segarcs[I].Arc.R - D
        else
          R := Segarcs[I].Arc.R + D;

        if R > 0 then
        begin
          LItem := New(PSegarc2D);
          LItem^ := Segarcs[I];
          LItem^.Arc.R := R;

          ASegarcs.Add(LItem);
        end;
      end
      else begin
        A := GetAngle(Segarcs[I].Seg.P1, Segarcs[I].Seg.P2);
        if LIsCW then A := A + 90 else A := A - 90;

        LItem := New(PSegarc2D);
        LItem^ := Segarcs[I];
        LItem^.Seg.P1 := ShiftPoint(Segarcs[I].Seg.P1, A, D);
        LItem^.Seg.P2 := ShiftPoint(Segarcs[I].Seg.P2, A, D);

        ASegarcs.Add(LItem);
      end;
    end;

    Result := True;
  end;

  procedure _CheckSegarcs(AItem1, AItem2: PSegarc2D);
  var
    LIncPnts: TPoint2DArray;
  begin
    if (AItem1^.IsArc and (AItem1^.Arc.R <= 0)) or
       (AItem2^.IsArc and (AItem2^.Arc.R <= 0)) then Exit;

    if AItem1.IsArc or AItem2.IsArc then
    begin
      if AItem1^.IsArc and AItem2^.IsArc then
        LIncPnts := UdGeo2D.Intersection(Circle2D(AItem1^.Arc.Cen, AItem1^.Arc.R), Circle2D(AItem2^.Arc.Cen, AItem2^.Arc.R))
      else if AItem1^.IsArc and not AItem2.IsArc then
        LIncPnts := UdGeo2D.Intersection(Line2D(AItem2^.Seg.P1, AItem2^.Seg.P2), Circle2D(AItem1^.Arc.Cen, AItem1^.Arc.R))
      else
        LIncPnts := UdGeo2D.Intersection(Line2D(AItem1^.Seg.P1, AItem1^.Seg.P2), Circle2D(AItem2^.Arc.Cen, AItem2^.Arc.R));

      if System.Length(LIncPnts) <= 0 then
      begin
        if AItem1^.IsArc then AItem1.Arc.R := -1;
        if AItem2^.IsArc then AItem2.Arc.R := -1;
      end;
    end;
  end;

  function _CheckSegarcList(var ASegarcs: TList; AIsClose: Boolean): Boolean;
  var
    I: Integer;
    LItem: PSegarc2D;
  begin
    Result := False;
    if not Assigned(ASegarcs) then Exit;

    for I := 0 to ASegarcs.Count - 2 do
      _CheckSegarcs(ASegarcs[I], ASegarcs[I + 1]);

    if AIsClose then
      _CheckSegarcs(ASegarcs[ASegarcs.Count - 1], ASegarcs[0]);

    for I := ASegarcs.Count - 1 downto 0 do
    begin
      LItem := ASegarcs[I];
      if LItem^.IsArc and (LItem^.Arc.R <= 0) then
      begin
        Dispose(LItem);
        ASegarcs.Delete(I);
      end;
    end;

    Result := True;
  end;

var
  I, N: Integer;
  LIsClose: Boolean;
  LSegarcs: TList;
  LLoopSearch: TUdLoopSearch;
begin
  Result := nil;
  
  if System.Length(Dises) < System.Length(Segarcs) - 1 then
  begin
    Result := Segarcs;
    Exit;
  end;

  LIsClose := IsEqual(SegarcEndPnts(Segarcs[Low(Segarcs)])[0], SegarcEndPnts(Segarcs[High(Segarcs)])[1]);

  LSegarcs := TList.Create;
  LLoopSearch := TUdLoopSearch.Create(True, False);
  try
    _PopulateSegarcList(LSegarcs, LIsClose);
    _CheckSegarcList(LSegarcs, LIsClose);

    for I := 0 to LSegarcs.Count - 2 do
      _ExtendItem(LSegarcs[I], LSegarcs[I + 1]);
    if LIsClose then
      _ExtendItem(LSegarcs[LSegarcs.Count - 1], LSegarcs[0]);

    for I := 0 to LSegarcs.Count - 1 do LLoopSearch.Add(PSegarc2D(LSegarcs[I])^);
    LLoopSearch.Search();

    N := _GetMaxPerIndex(LLoopSearch.MinPolygons);
    if N >= 0 then Result := LLoopSearch.MinLoops[N];
  finally
    for I := LSegarcs.Count - 1 downto 0 do
      if Assigned(LSegarcs[I]) then Dispose(PSegarc2D(LSegarcs[I]));
    LSegarcs.Free;
    LLoopSearch.Free;
  end;
end;



function OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray): TSegarc2DArray;
begin
  Result := FOffsetSegarcs(Segarcs, Dises);
end;

function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float): TSegarc2DArray;
var
  I: Integer;
  Dises: TFloatArray;
begin
  System.SetLength(Dises, System.Length(Segarcs));
  for I := 0 to System.Length(Segarcs) - 1 do Dises[I] := Dis;
  Result := FOffsetSegarcs(Segarcs, Dises);
end;







end.