
{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdFillet2D;

{$I UdDefs.INC}

interface

uses
  Classes, UdTypes, UdGTypes;

const
  FILLET_SUCCESS          = 0;
  FILLET_NO_INCT_PNTS     = 1;
  FILLET_RADIUS_TOO_LARGE = 2;
  FILLET_SEG_COINCIDENT   = 3;     //Coincident
  FILLET_ARC_RADIUS_ERR   = 4;     //Coincident


function Fillet(ARadius: Float; APntOn1, APntOn2: TPoint2D; ASeg1, ASeg2: TSegment2D;
                var AOutSeg1, AOutSeg2: TSegment2D; var AOutFtArc: TArc2D): Integer; overload;

function Fillet(ARadius: Float; APntOn1, APntOn2: TPoint2D; AArc1, AArc2: TArc2D;
                var AOutArc1, AOutArc2: TArc2D; var AOutFtArc: TArc2D): Integer; overload;

function Fillet(ARadius: Float; APntOn1, APntOn2: TPoint2D; ASegarcs: TSegarc2DArray;
                var AOutSegarcs: TSegarc2DArray; var AOutFtArc: TArc2D): Integer; overload;


function Fillet(ARadius: Float; APntOnSeg, APntOnArc: TPoint2D; ASeg: TSegment2D; AArc: TArc2D;
                var AOutSeg: TSegment2D; var AOutArc: TArc2D; var AOutFtArc: TArc2D): Integer; overload;

function Fillet(ARadius: Float; APntOnSeg, APntOnSegarcs: TPoint2D; ASeg: TSegment2D; ASegarcs: TSegarc2DArray;
                var AOutSegarcs: TSegarc2DArray; var AOutFtArc: TArc2D): Integer; overload;

function Fillet(ARadius: Float; APntOnArc, APntOnSegarcs: TPoint2D; AArc: TArc2D; ASegarcs: TSegarc2DArray;
                var AOutSegarcs: TSegarc2DArray; var AOutFtArc: TArc2D): Integer; overload;


function Fillet(ARadius: Float; APntOn1, APntOn2: TPoint2D; ASegarcs1, ASegarcs2: TSegarc2DArray;
                var AOutSegarcs: TSegarc2DArray; var AOutFtArc: TArc2D): Integer; overload;

function Fillet(ARadius: Float; ASegarcs: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray): Integer; overload;





implementation

uses
  UdMath, UdGeo2D, UdVector2D, UdChamfer2D;



function GetFilletEndPnts(ARadius: Float; ASeg1, ASeg2: TSegment2D; out AP1, AP2: TPoint2D): Integer;
var
  A, D: Float;
  D1, D2: Float;
begin
  Result := FILLET_SEG_COINCIDENT;
  if IsEqual(ASeg1.P1, ASeg1.P2) or IsEqual(ASeg2.P1, ASeg2.P2) then Exit; //=====>>>>

  A := Abs(GetAngle(ASeg1.P2, ASeg1.P1) - GetAngle(ASeg2.P2, ASeg2.P1));
  if A > 180 then A := 360 - A;
  A := A / 2;

  D := UdMath.CotD(A) * ARadius;

  D1 := UdGeo2D.Distance(ASeg1.P1, ASeg1.P2);
  D2 := UdGeo2D.Distance(ASeg2.P1, ASeg2.P2);

  if (D1 <= D) or (D2 <= D) then
  begin
    Result := FILLET_RADIUS_TOO_LARGE;
    Exit; //--->>>>
  end;

  AP1.X := ASeg1.P1.X + (ASeg1.P2.X - ASeg1.P1.X) * (1 - D / D1);
  AP1.Y := ASeg1.P1.Y + (ASeg1.P2.Y - ASeg1.P1.Y) * (1 - D / D1);

  AP2.X := ASeg2.P1.X + (ASeg2.P2.X - ASeg2.P1.X) * (1 - D / D2);
  AP2.Y := ASeg2.P1.Y + (ASeg2.P2.Y - ASeg2.P1.Y) * (1 - D / D2);

  Result := FILLET_SUCCESS;
end;





function Fillet(ARadius: Float; APntOn1, APntOn2: TPoint2D; ASeg1, ASeg2: TSegment2D;
                var AOutSeg1, AOutSeg2: TSegment2D; var AOutFtArc: TArc2D): Integer;

  function _GetFilletArc(ARadius: Float; APnt1, APnt2, AInctPnt: TPoint2D): TArc2D;
  begin
    if UdMath.IsClockWise(APnt1, APnt2, AInctPnt) then
    begin
      Result := UdGeo2D.MakeArc(APnt2, APnt1, ARadius, True, False);
      Result.IsCW := False;
    end
    else begin
      Result := UdGeo2D.MakeArc(APnt1, APnt2, ARadius, True, False);
      Result.IsCW := True;
    end;
  end;

var
  LP1, LP2: TPoint2D;
  LInctPnts: TPoint2DArray;
  LSeg1, LSeg2: TSegment2D;
  LPntOn1, LPntOn2: TPoint2D;
begin
  LInctPnts := UdGeo2D.Intersection(Line2D(ASeg1.P1, ASeg1.P2), Line2D(ASeg2.P1, ASeg2.P2));
  if System.Length(LInctPnts) <= 0 then
  begin
    Result := FILLET_NO_INCT_PNTS;
    Exit; //====>>>>
  end;

  LPntOn1 := NormalizePntOnSeg(APntOn1, ASeg1);
  LPntOn2 := NormalizePntOnSeg(APntOn2, ASeg2);

  LSeg1 := NormalizeFilletSegment(ASeg1, LInctPnts[0], LPntOn1);
  LSeg2 := NormalizeFilletSegment(ASeg2, LInctPnts[0], LPntOn2);

  Result := GetFilletEndPnts(ARadius, LSeg1, LSeg2, LP1, LP2);

  if Result = FILLET_SUCCESS then
  begin
    AOutFtArc := _GetFilletArc(ARadius, LP1, LP2, LInctPnts[0]);
    if IsEqual(AOutFtArc.R, 0.0) then AOutFtArc.R := 0.0;

    if AOutFtArc.R >= 0.0 then
    begin
      AOutSeg1 := Segment2D(LSeg1.P1, LP1);
      AOutSeg2 := Segment2D(LSeg2.P1, LP2);

      if NotEqual(GetAngle(AOutSeg1.P1, AOutSeg1.P2), GetAngle(ASeg1.P1, ASeg1.P2), 1) then
        Swap(AOutSeg1.P1, AOutSeg1.P2);

      if NotEqual(GetAngle(AOutSeg2.P1, AOutSeg2.P2), GetAngle(ASeg2.P1, ASeg2.P2), 1) then
        Swap(AOutSeg2.P1, AOutSeg2.P2);
    end
    else
      Result := FILLET_ARC_RADIUS_ERR;
  end
end;






//---------------------------------------------------------------------------------------------

function FFilletArcArc(ARadius: Double; AArc1, AArc2: TArc2D; var AOutArc1, AOutArc2: TArc2D; var AOutFtArc: TArc2D;
                       AArc1Sign: Double; AArc2Sign: Double; ACheckPnt: TPoint2D): Boolean;
var
  LFlag1, LFlag2: Boolean;
  LSignR1, LSignR2: Float;
  LFltCen: TPoint2D;
  LFltAng1, LFltAng2: Float;
  LInctPnts: TPoint2DArray;
begin
  Result := False;

  LFlag1 := False;
  LFlag2 := False;

  LSignR1 := (AArc1.R + (ARadius * AArc1Sign));
  if (AArc1Sign < 0) then LFlag1 := true;

  LSignR2 := (AArc2.R + (ARadius * AArc2Sign));
  if (AArc2Sign < 0) then LFlag2 := true;

  if ((LSignR1 <= 0) or (LSignR2 <= 0)) then Exit;  //=======>>>>>

  LInctPnts := Intersection(Circle2D(AArc1.Cen, LSignR1), Circle2D(AArc2.Cen, LSignR2));
  if System.Length(LInctPnts) <= 0 then Exit;  //=======>>>>>

  if System.Length(LInctPnts) = 2 then
  begin
    if (Distance(LInctPnts[0], ACheckPnt) > Distance(LInctPnts[1], ACheckPnt)) then
      LFltCen := LInctPnts[1]
    else
      LFltCen := LInctPnts[0];
  end
  else
    LFltCen := LInctPnts[0];


  LFltAng1 := 0.0;
  LFltAng2 := 0.0;
  
  if (LFlag1 and not LFlag2) then
    if IsPntOnLeftSide(LFltCen, AArc1.Cen, AArc2.Cen)then
    begin
      LFltAng2 := GetAngle(AArc1.Cen, LFltCen);
      LFltAng1 := GetAngle(LFltCen, AArc2.Cen)
    end
    else
    begin
      LFltAng1 := GetAngle(AArc1.Cen, LFltCen);
      LFltAng2 := GetAngle(LFltCen, AArc2.Cen)
    end;

  if (LFlag2 and not LFlag1) then
    if IsPntOnLeftSide(LFltCen, AArc2.Cen, AArc1.Cen) then
    begin
      LFltAng2 := GetAngle(AArc2.Cen, LFltCen);
      LFltAng1 := GetAngle(LFltCen, AArc1.Cen)
    end
    else
    begin
      LFltAng1 := GetAngle(AArc2.Cen, LFltCen);
      LFltAng2 := GetAngle(LFltCen, AArc1.Cen)
    end;

  if (LFlag1 and LFlag2) then
    if IsPntOnLeftSide(AArc1.Cen, AArc2.Cen, LFltCen) then
    begin
      LFltAng2 := GetAngle(AArc2.Cen, LFltCen);
      LFltAng1 := GetAngle(AArc1.Cen, LFltCen)
    end
    else
    begin
      LFltAng1 := GetAngle(AArc2.Cen, LFltCen);
      LFltAng2 := GetAngle(AArc1.Cen, LFltCen)
    end;

  if (not LFlag1 and not LFlag2) then
    if IsPntOnLeftSide(AArc1.Cen, AArc2.Cen, LFltCen) then
    begin
      LFltAng1 := GetAngle(LFltCen, AArc1.Cen);
      LFltAng2 := GetAngle(LFltCen, AArc2.Cen)
    end
    else
    begin
      LFltAng2 := GetAngle(LFltCen, AArc1.Cen);
      LFltAng1 := GetAngle(LFltCen, AArc2.Cen)
    end;

  AOutFtArc := Arc2D(LFltCen, ARadius, LFltAng1, LFltAng2);


  AOutArc1 := AArc1;
  AOutArc2 := AArc2;

  if IsPntOnLeftSide(AArc1.Cen, AArc2.Cen, LFltCen) then
  begin
    if (LFlag2) then
      AOutArc1.Ang2 := GetAngle(AArc1.Cen, LFltCen)
    else
      AOutArc1.Ang1 := GetAngle(AArc1.Cen, LFltCen);
  end
  else begin
    if (LFlag2) then
      AOutArc1.Ang1 := GetAngle(AArc1.Cen, LFltCen)
    else
      AOutArc1.Ang2 := GetAngle(AArc1.Cen, LFltCen);
  end;


  if IsPntOnLeftSide(LFltCen, AArc2.Cen, AArc1.Cen) then
  begin
    if (LFlag1) then
      AOutArc2.Ang2 := GetAngle(AArc2.Cen, LFltCen)
    else
      AOutArc2.Ang1 := GetAngle(AArc2.Cen, LFltCen)
  end
  else begin
    if (LFlag1) then
      AOutArc2.Ang1 := GetAngle(AArc2.Cen, LFltCen)
    else
      AOutArc2.Ang2 := GetAngle(AArc2.Cen, LFltCen);
  end;

  Result := true;
end;

 


function Fillet(ARadius: Float; APntOn1, APntOn2: TPoint2D; AArc1, AArc2: TArc2D;
                var AOutArc1, AOutArc2: TArc2D; var AOutFtArc: TArc2D): Integer;
var
  LSignR1: Double;
  LSignR2: Double;
  LCheckPnt: TPoint2D;
  LPntOn1, LPntOn2: TPoint2D;
begin
  Result := -1;

  LPntOn1 := NormalizePntOnArc(APntOn1, AArc1);
  LPntOn2 := NormalizePntOnArc(APntOn2, AArc2);
    
  if (Distance(AArc1.Cen, LPntOn2) >= AArc1.R) then
    LSignR1 := 1
  else
    LSignR1 := -1;

  if (Distance(AArc2.Cen, LPntOn1) >= AArc2.R) then
    LSignR2 := 1
  else
    LSignR2 := -1;

  if (LSignR1 > LSignR2) then
    LCheckPnt := LPntOn1
  else
    LCheckPnt := LPntOn2;

  if FFilletArcArc(ARadius, AArc1, AArc2, AOutArc1, AOutArc2, AOutFtArc, LSignR1, LSignR2, LCheckPnt) then
    Result := FILLET_SUCCESS;
end;



//---------------------------------------------------------------------------------------------

function Fillet(ARadius: Float; APntOn1, APntOn2: TPoint2D; ASegarcs: TSegarc2DArray;
                var AOutSegarcs: TSegarc2DArray; var AOutFtArc: TArc2D): Integer;

  function _GenOutSegarcs(ASegarcs: TSegarc2DArray; N: Integer): TSegarc2DArray;
  var
    I: Integer;
  begin
    System.SetLength(Result, System.Length(ASegarcs) + 1);
    for I := 0 to N do Result[I] := ASegarcs[I];
    for I := N + 2 to System.Length(ASegarcs) do Result[I] := ASegarcs[I-1];
  end;

var
  LClosed: Boolean;
  L, N1, N2: Integer;
  LP1, LP2: TPoint2D;
  LArc1, LArc2: TArc2D;
  LSeg1, LSeg2: TSegment2D;
  LPntOn1, LPntOn2: TPoint2D;
  LSegarc1, LSegarc2: TSegarc2D;
begin
  Result := -1;
  if IsEqual(ARadius, 0.0) or (ARadius < 0) then Exit; //=====>>>

  L := System.Length(ASegarcs);
  if L <= 1 then Exit; //=====>>>
    
  LPntOn1 := ClosestSegarcsPoint(APntOn1, ASegarcs, N1);
  LPntOn2 := ClosestSegarcsPoint(APntOn2, ASegarcs, N2);

  LP1 := SegarcEndPnts(ASegarcs[0])[0];
  LP2 := SegarcEndPnts(ASegarcs[L-1])[1];
  LClosed := IsEqual(LP1, LP2);

  if LClosed then
  begin
    if ((N1 = 0) and (N2 = (L-1))) or ((N1 = (L-1)) and (N2 = 0)) then
    begin
      N1 := -1;
      N2 := 0;
    end;
  end;

  if (N1 = N2) or (Abs(N2 - N1) <> 1) then Exit;  //========>>>>

  if N2 < N1 then
  begin
    Swap(N2, N1);
    Swap(LPntOn1, LPntOn2);
  end;

  if N1 = -1 then N1 := L-1;

  LSegarc1 := ASegarcs[N1];
  LSegarc2 := ASegarcs[N2];

  if LSegarc1.IsArc then
  begin
    if LSegarc2.IsArc then
    begin
      Result := Fillet(ARadius, LPntOn1, LPntOn2, LSegarc1.Arc, LSegarc2.Arc, LArc1, LArc2, AOutFtArc);
      if Result = FILLET_SUCCESS then
      begin
        if LArc1.IsCW then
          AOutFtArc.IsCW := IsEqual(ShiftPoint(LArc1.Cen, LArc1.Ang1, LArc1.R), ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R))
        else
          AOutFtArc.IsCW := IsEqual(ShiftPoint(LArc1.Cen, LArc1.Ang2, LArc1.R), ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));

        AOutSegarcs := _GenOutSegarcs(ASegarcs, N1);
        L := System.Length(AOutSegarcs);
        
        AOutSegarcs[N1 mod L]     := Segarc2D(LArc1);
        AOutSegarcs[(N1+1) mod L] := Segarc2D(AOutFtArc);
        AOutSegarcs[(N1+2) mod L] := Segarc2D(LArc2);
      end;
    end
    else begin
      Result := Fillet(ARadius, LPntOn2, LPntOn1, LSegarc2.Seg, LSegarc1.Arc, LSeg2, LArc1, AOutFtArc);
      if Result = FILLET_SUCCESS then
      begin
        if LArc1.IsCW then
          AOutFtArc.IsCW := IsEqual(ShiftPoint(LArc1.Cen, LArc1.Ang1, LArc1.R), ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R))
        else
          AOutFtArc.IsCW := IsEqual(ShiftPoint(LArc1.Cen, LArc1.Ang2, LArc1.R), ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));

        AOutSegarcs  := _GenOutSegarcs(ASegarcs, N1);
        L := System.Length(AOutSegarcs);

        AOutSegarcs[N1 mod L]     := Segarc2D(LArc1);
        AOutSegarcs[(N1+1) mod L] := Segarc2D(AOutFtArc);
        AOutSegarcs[(N1+2) mod L] := Segarc2D(LSeg2);
      end;
    end;
  end
  else begin
    if LSegarc2.IsArc then
    begin
      Result := Fillet(ARadius, LPntOn1, LPntOn2, LSegarc1.Seg, LSegarc2.Arc, LSeg1, LArc2, AOutFtArc);
      if Result = FILLET_SUCCESS then
      begin
        AOutFtArc.IsCW := IsEqual(LSeg1.P2, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));

        AOutSegarcs := _GenOutSegarcs(ASegarcs, N1);
        L := System.Length(AOutSegarcs);

        AOutSegarcs[N1 mod L]     := Segarc2D(LSeg1);
        AOutSegarcs[(N1+1) mod L] := Segarc2D(AOutFtArc);
        AOutSegarcs[(N1+2) mod L] := Segarc2D(LArc2);
      end;
    end
    else begin
      Result := Fillet(ARadius, LPntOn1, LPntOn2, LSegarc1.Seg, LSegarc2.Seg, LSeg1, LSeg2, AOutFtArc);
      if Result = FILLET_SUCCESS then
      begin
        AOutFtArc.IsCW := IsEqual(LSeg1.P2, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));
        
        AOutSegarcs := _GenOutSegarcs(ASegarcs, N1);
        L := System.Length(AOutSegarcs);
        
        AOutSegarcs[N1 mod L]     := Segarc2D(LSeg1);
        AOutSegarcs[(N1+1) mod L] := Segarc2D(AOutFtArc);
        AOutSegarcs[(N1+2) mod L] := Segarc2D(LSeg2);
      end;
    end;  
  end;
end;






//---------------------------------------------------------------------------------------------

function FFilletLineArc1(ARadius: Float; APntOnSeg, APntOnArc: TPoint2D; ASeg: TSegment2D; AArc: TArc2D;
                var AOutSeg: TSegment2D; var AOutArc: TArc2D; var AOutFtArc: TArc2D): Integer;
var
  LIsLeft: Boolean;
  LPerpDis, LCenAng: Float;
  LPerpPnt, LFltCen: TPoint2D;
  LFltAng1, LFltAng2, LArcAng: Float;
  LSegPnt, LArcPnt: TPoint2D;
begin
  Result := -1;

  LPerpPnt := ClosestLinePoint(AArc.Cen, Line2D(ASeg.P1, ASeg.P2));
  LPerpDis := Distance(LPerpPnt, AArc.Cen);

  if (LPerpDis <= AArc.R) or (LPerpDis > (AArc.R + 2*ARadius)) then Exit;  //========>>>>

  LIsLeft := IsPntOnLeftSide(APntOnSeg, AArc.Cen, LPerpPnt);
  LCenAng := ArcCosD((LPerpDis - ARadius) / (AArc.R + ARadius));
  
  if LIsLeft then
    LCenAng := GetAngle(AArc.Cen, LPerpPnt) + LCenAng
  else
    LCenAng := GetAngle(AArc.Cen, LPerpPnt) - LCenAng;

  LFltCen := ShiftPoint(AArc.Cen, LCenAng, (AArc.R + ARadius));

  LSegPnt := ClosestLinePoint(LFltCen, Line2D(ASeg.P1, ASeg.P2));
  LArcPnt := ClosestCirclePoint(LFltCen, Circle2D(AArc.Cen, AArc.R));

  if LIsLeft then
  begin
    LFltAng1 := GetAngle(LFltCen, LArcPnt);
    LFltAng2 := GetAngle(LFltCen, LSegPnt);
  end
  else begin
    LFltAng1 := GetAngle(LFltCen, LSegPnt);
    LFltAng2 := GetAngle(LFltCen, LArcPnt);
  end;

  AOutFtArc := Arc2D(LFltCen, ARadius, LFltAng1, LFltAng2);

  AOutArc := AArc;
  LArcAng := GetAngle(AArc.Cen, LArcPnt);
  if LIsLeft then
    AOutArc.Ang1 := LArcAng
  else
    AOutArc.Ang2 := LArcAng;

  AOutSeg.P1 := LSegPnt;
  if LIsLeft then
  begin
    if IsPntOnLeftSide(ASeg.P1, LFltCen, LSegPnt) then
      AOutSeg.P2 := ASeg.P1
    else if IsPntOnLeftSide(ASeg.P2, LFltCen, LSegPnt) then
      AOutSeg.P2 := ASeg.P2
    else begin
      if Distance(ASeg.P1, LSegPnt) < Distance(ASeg.P2, LSegPnt) then
        AOutSeg.P2 := ASeg.P1
      else
        AOutSeg.P2 := ASeg.P2;
    end;
  end
  else begin
    if IsPntOnRightSide(ASeg.P1, LFltCen, LSegPnt) then
      AOutSeg.P2 := ASeg.P1
    else if IsPntOnRightSide(ASeg.P2, LFltCen, LSegPnt) then
      AOutSeg.P2 := ASeg.P2
    else begin
      if Distance(ASeg.P1, LSegPnt) < Distance(ASeg.P2, LSegPnt) then
        AOutSeg.P2 := ASeg.P1
      else
        AOutSeg.P2 := ASeg.P2;
    end;
  end;

  if NotEqual(GetAngle(AOutSeg.P1, AOutSeg.P2), GetAngle(ASeg.P1, ASeg.P2), 1) then
    Swap(AOutSeg.P1, AOutSeg.P2);

  Result := FILLET_SUCCESS;
end;


function FFilletLineArc2(ARadius: Float; APntOnSeg, APntOnArc, AExtPnt: TPoint2D; ASeg: TSegment2D; AArc: TArc2D;
                var AOutSeg: TSegment2D; var AOutArc: TArc2D; var AOutFtArc: TArc2D): Integer;
var
  LFlag: boolean;
  LVector: TVector2D;
  LInctPnts: TPoint2DArray;
  LArcP1, LArcP2, LArcMPnt: TPoint2D;
  LOren, LAng1, LAng2, LArcAng: Double;
  LRad, LSegAng, LExtAng, LMidAng, LPntOnArcAng: Double;
  LVecUPnt, LVecSP1, LVecSP2, LFtCen, LFtSegPt, LFtArcPt, LVecUPnt1, LFtSegP0: TPoint2D;
begin
  Result := -1;

  LArcP1 := ShiftPoint(AArc.Cen, AArc.Ang1, AArc.R);
  LArcP2 := ShiftPoint(AArc.Cen, AArc.Ang2, AArc.R);

  LMidAng := FixAngle(AArc.Ang1 + (FixAngle(AArc.Ang2 - AArc.Ang1) / 2) );
  LArcMPnt := ShiftPoint(AArc.Cen, LMidAng, AArc.R);

  
  if IsEqual(AExtPnt, APntOnSeg) then
  begin
    if not (IsEqual(ASeg.P1, APntOnSeg) or IsEqual(ASeg.P2, APntOnSeg)) then Exit;  //========>>>>
    APntOnSeg := MidPoint(ASeg.P1, ASeg.P2);
  end;

  if IsEqual(AExtPnt, APntOnArc) then
  begin
    if not (IsEqual(LArcP1, APntOnArc) or IsEqual(LArcP2, APntOnArc)) then  Exit;  //========>>>>
    APntOnArc := LArcMPnt;
  end;


  LSegAng := GetAngle(ASeg.P1, ASeg.P2);
  LVecUPnt := ShiftPoint(APntOnArc, (LSegAng + 90.0), 1.0);

  LInctPnts := Intersection(Line2D(ASeg.P1, ASeg.P2), Line2D(LVecUPnt, APntOnArc));
  if System.Length(LInctPnts) <= 0 then Exit;  //========>>>>

  if IsEqual(LInctPnts[0], APntOnArc) then
    LVector := UdVector2D.Extrusion(LInctPnts[0], LVecUPnt)
  else
    LVector := UdVector2D.Extrusion(LInctPnts[0], APntOnArc);

  if (Distance(AArc.Cen, APntOnSeg) >= AArc.R) then
  begin
    LOren := 1;
    LFlag := False;
  end
  else
  begin
    LOren := -1;
    LFlag := True;
  end;


  if IsEqual(Distance(ASeg.P1, ASeg.P2), 0) then Exit; //====>>>
  
  LRad := (AArc.R + (ARadius * LOren));
  if (LRad <= 0) then Exit; //====>>>

  LVector := UdVector2D.Multiply(LVector, ARadius);

  LVecSP1 := Point2D(ASeg.P1.X + LVector.X, ASeg.P1.Y + LVector.Y);
  LVecSP2 := Point2D(ASeg.P2.X + LVector.X, ASeg.P2.Y + LVector.Y);

  LInctPnts := Intersection(Line2D(LVecSP1, LVecSP2), Circle2D(AArc.Cen, LRad));
  if System.Length(LInctPnts) <= 0 then Exit;  //====>>>

  if System.Length(LInctPnts) = 1 then
    LFtCen := LInctPnts[0]
  else if System.Length(LInctPnts) = 2 then
  begin
    if (Distance(LInctPnts[0], APntOnSeg) <= Distance(LInctPnts[1], APntOnSeg)) then
      LFtCen := LInctPnts[0]
    else
      LFtCen := LInctPnts[1];
  end;


  LFtSegPt := ClosestLinePoint(LFtCen, Line2D(ASeg.P1, ASeg.P2));
  if Distance(LFtSegPt, LFtCen) > (ARadius + _Epsilon) then Exit; //========>>>


  LFtArcPt := ClosestCirclePoint(LFtCen, Circle2D(AArc.Cen, AArc.R));
  if Distance(LFtArcPt, LFtCen) > (ARadius + _Epsilon) then Exit; //========>>>


  LAng1 := GetAngle(LFtCen, LFtSegPt);
  LAng2 := GetAngle(LFtCen, LFtArcPt);
  if (FixAngle(LAng1 - LAng2) > 180.0) then Swap(LAng1, LAng2);

  AOutFtArc := Arc2D(LFtCen, ARadius, LAng2, LAng1);

  LVecUPnt1 := ShiftPoint(AArc.Cen, (LSegAng + 90.0), 1);
  LInctPnts := Intersection(Line2D(ASeg.P1, ASeg.P2), Line2D(LVecUPnt1, AArc.Cen));
  if System.Length(LInctPnts) <= 0 then Exit; //=====>>>

  LFtSegP0 := LInctPnts[0];
  
  AOutSeg := ASeg;
  AOutArc := AArc;

  LArcAng := GetAngle(AArc.Cen, AOutFtArc.Cen);
  LExtAng := GetAngle(AArc.Cen, AExtPnt);
  LPntOnArcAng := GetAngle(AArc.Cen, APntOnArc);

  if IsInAngles(LExtAng, AArc.Ang1, AArc.Ang2)  then
  begin
    if IsInAngles(LPntOnArcAng, AArc.Ang1, LExtAng) then
    begin
      if FixAngle(AArc.Ang2 - AArc.Ang1) > FixAngle(LArcAng - AArc.Ang1) then
        AOutArc.Ang2 := LArcAng
      else
        Exit; //====>>>>        
    end
    else begin
      if FixAngle(AArc.Ang2 - AArc.Ang1) > FixAngle(AArc.Ang2 - LArcAng) then
        AOutArc.Ang1 := LArcAng
      else
        Exit; //====>>>>
    end;
  end
  else begin
    if FixAngle(LArcAng - AArc.Ang2) < FixAngle(AArc.Ang1 - LArcAng) then
      AOutArc.Ang2 := LArcAng
    else
      AOutArc.Ang1 := LArcAng;    
  end;

  if (IsEqual(GetAngle(ASeg.P1, ASeg.P2), GetAngle(LFtSegP0, LFtSegPt), 1E-06)) then
  begin
    if (LFlag) then
      AOutSeg.P2 := LFtSegPt
    else
      AOutSeg.P1 := LFtSegPt
  end
  else begin
    if (LFlag) then
      AOutSeg.P1 := LFtSegPt
    else
      AOutSeg.P2 := LFtSegPt;
  end;

  if NotEqual(GetAngle(AOutSeg.P1, AOutSeg.P2), GetAngle(ASeg.P1, ASeg.P2), 1) then
    Swap(AOutSeg.P1, AOutSeg.P2);  

  Result := FILLET_SUCCESS;
end;

function Fillet(ARadius: Float; APntOnSeg, APntOnArc: TPoint2D; ASeg: TSegment2D; AArc: TArc2D;
                var AOutSeg: TSegment2D; var AOutArc: TArc2D; var AOutFtArc: TArc2D): Integer;
var
  LExtPnt: TPoint2D;
  LInctPnts: TPoint2DArray;
  LPntOnSeg, LPntOnArc: TPoint2D;
begin
  LPntOnSeg := NormalizePntOnSeg(APntOnSeg, ASeg);
  LPntOnArc := NormalizePntOnArc(APntOnArc, AArc);  

  LInctPnts := Intersection(Line2D(ASeg.P1, ASeg.P2), Circle2D(AArc.Cen, AArc.R));
  if System.Length(LInctPnts) <= 0 then
  begin
    Result := FFilletLineArc1(ARadius, LPntOnSeg, LPntOnArc, ASeg, AArc, AOutSeg, AOutArc, AOutFtArc);
  end
  else begin
    if (System.Length(LInctPnts) = 2) then
    begin
      LExtPnt := LInctPnts[0];

      if Distance(LInctPnts[1], LPntOnSeg) < Distance(LInctPnts[0], LPntOnSeg) then
        LExtPnt := LInctPnts[1];
    end
    else
      LExtPnt := LInctPnts[0];

    Result := FFilletLineArc2(ARadius, LPntOnSeg, LPntOnArc, LExtPnt, ASeg, AArc, AOutSeg, AOutArc, AOutFtArc);
  end;
end;



//--------------------------------------------------------------------------------------------------

function Fillet(ARadius: Float; APntOnSeg, APntOnSegarcs: TPoint2D; ASeg: TSegment2D; ASegarcs: TSegarc2DArray;
                var AOutSegarcs: TSegarc2DArray; var AOutFtArc: TArc2D): Integer;
var
  I, N, L: Integer;
  LFlag: Boolean;
  LSegarc: TSegarc2D;
  LExtPnt, LPnt: TPoint2D;
  LInctPnts: TPoint2DArray;
  LSegarcs: TSegarc2DArray;
  LOutSgArc: TArc2D;
  LOutSeg, LOutSgSeg: TSegment2D;
begin
  Result := -1;

  APntOnSeg := ClosestLinePoint(APntOnSeg, Line2D(ASeg.P1, ASeg.P2));
  APntOnSegarcs := ClosestSegarcsPoint(APntOnSegarcs, ASegarcs, N);
  
  LSegarc := ASegarcs[N];
  LInctPnts := Intersection(Line2D(ASeg.P1, ASeg.P2), LSegarc);

  LFlag := False;
  if System.Length(LInctPnts) > 0 then
  begin
    if (System.Length(LInctPnts) = 2) then
    begin
      LExtPnt := LInctPnts[0];

      if Distance(LInctPnts[1], APntOnSeg) < Distance(LInctPnts[0], APntOnSeg) then
        LExtPnt := LInctPnts[1];
    end
    else
      LExtPnt := LInctPnts[0];

    if LSegarc.IsArc then
    begin
      if LSegarc.Arc.IsCW then
        LFlag := IsInAngles(GetAngle(LSegarc.Arc.Cen, APntOnSegarcs), GetAngle(LSegarc.Arc.Cen, LExtPnt), LSegarc.Arc.Ang2)
      else
        LFlag := IsInAngles(GetAngle(LSegarc.Arc.Cen, APntOnSegarcs), LSegarc.Arc.Ang1, GetAngle(LSegarc.Arc.Cen, LExtPnt));
    end
    else
      LFlag := IsPntOnSegment(APntOnSegarcs, Segment2D(LSegarc.Seg.P1, LExtPnt));
  end;

  if (N = 0) or (N = System.Length(ASegarcs) - 1) then
  begin
    if System.Length(LInctPnts) > 0 then
    begin
      if ((N = 0) and LFlag) then
      begin
        APntOnSegarcs := MidPoint(Segment2D(LSegarc.Seg.P2, LExtPnt));
        APntOnSegarcs := ClosestSegarcPoint(APntOnSegarcs, LSegarc);
      end
      else if ((N = System.Length(ASegarcs) - 1) and not LFlag) then
      begin
        APntOnSegarcs := MidPoint(Segment2D(LSegarc.Seg.P1, LExtPnt));
        APntOnSegarcs := ClosestSegarcPoint(APntOnSegarcs, LSegarc);
      end;
    end;

    LFlag := (N = (System.Length(ASegarcs) - 1));
    
    System.SetLength(LSegarcs, System.Length(ASegarcs) - 1);
    if LFlag then
    begin
      for I := 0 to System.Length(ASegarcs) - 2 do LSegarcs[I] := ASegarcs[I];
    end
    else begin
      for I := 1 to System.Length(ASegarcs) - 1 do LSegarcs[I-1] := ASegarcs[I];
    end;
  end
  else begin
    if System.Length(LInctPnts) <= 0 then Exit; //======>>>>

    if LFlag then
    begin
      System.SetLength(LSegarcs, N);
      for I := 0 to N - 1 do LSegarcs[I] := ASegarcs[I];
    end
    else begin
      System.SetLength(LSegarcs, System.Length(ASegarcs) - N - 1);
      for I := N + 1 to System.Length(ASegarcs) - 1 do LSegarcs[I-N-1] := ASegarcs[I];
    end;
  end;

  if LSegarc.IsArc then
  begin
    Result := Fillet(ARadius, APntOnSeg, APntOnSegarcs, ASeg, LSegarc.Arc, LOutSeg, LOutSgArc, AOutFtArc);
    if Result = FILLET_SUCCESS then
    begin
      if LFlag then
      begin
        if LOutSgArc.IsCW then
          LPnt := ShiftPoint(LOutSgArc.Cen, LOutSgArc.Ang1, LOutSgArc.R)
        else
          LPnt := ShiftPoint(LOutSgArc.Cen, LOutSgArc.Ang2, LOutSgArc.R);

        AOutFtArc.IsCW := IsEqual(LPnt, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));
      end
      else begin
        if LOutSgArc.IsCW then
          LPnt := ShiftPoint(LOutSgArc.Cen, LOutSgArc.Ang2, LOutSgArc.R)
        else
          LPnt := ShiftPoint(LOutSgArc.Cen, LOutSgArc.Ang1, LOutSgArc.R);

        AOutFtArc.IsCW := IsEqual(LPnt, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang1, AOutFtArc.R));
      end;
    end;
  end
  else begin
    Result := Fillet(ARadius, APntOnSeg, APntOnSegarcs, ASeg, LSegarc.Seg, LOutSeg, LOutSgSeg, AOutFtArc);
    if Result = FILLET_SUCCESS then
    begin
      if LFlag then
        AOutFtArc.IsCW := IsEqual(LOutSgSeg.P2, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R))
      else
        AOutFtArc.IsCW := IsEqual(LOutSgSeg.P1, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang1, AOutFtArc.R))
    end;
  end;

  if Result = FILLET_SUCCESS then
  begin
    if LFlag then
    begin
      if AOutFtArc.IsCW then
        LPnt := ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang1, AOutFtArc.R)
      else
        LPnt := ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R);

      if NotEqual(LOutSeg.P1, LPnt) then Swap(LOutSeg.P1, LOutSeg.P2);
    end
    else begin
      if AOutFtArc.IsCW then
        LPnt := ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R)
      else
        LPnt := ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang1, AOutFtArc.R);

      if NotEqual(LOutSeg.P2, LPnt) then Swap(LOutSeg.P1, LOutSeg.P2);
    end;

    if LFlag then
    begin
      L := System.Length(LSegarcs);

      System.SetLength(AOutSegarcs, L + 3);
      for I := 0 to L - 1 do AOutSegarcs[I] := LSegarcs[I];

      if LSegarc.IsArc then
        AOutSegarcs[L] := Segarc2D(LOutSgArc)
      else
        AOutSegarcs[L] := Segarc2D(LOutSgSeg);

      AOutSegarcs[L+1] := Segarc2D(AOutFtArc);

      AOutSegarcs[L+2] := Segarc2D(LOutSeg);
    end
    else begin
      L := System.Length(LSegarcs);

      System.SetLength(AOutSegarcs, L + 3);
      for I := 3 to System.Length(AOutSegarcs) - 1 do AOutSegarcs[I] := LSegarcs[I-3];


      AOutSegarcs[0] := Segarc2D(LOutSeg);

      AOutSegarcs[1] := Segarc2D(AOutFtArc);

      if LSegarc.IsArc then
        AOutSegarcs[2] := Segarc2D(LOutSgArc)
      else
        AOutSegarcs[2] := Segarc2D(LOutSgSeg);
    end;
  end;
end;


function Fillet(ARadius: Float; APntOnArc, APntOnSegarcs: TPoint2D; AArc: TArc2D; ASegarcs: TSegarc2DArray;
                var AOutSegarcs: TSegarc2DArray; var AOutFtArc: TArc2D): Integer;
var
  I, N, L: Integer;
  LFlag: Boolean;
  LSegarc: TSegarc2D;
  LExtPnt, LPnt: TPoint2D;
  LInctPnts: TPoint2DArray;
  LSegarcs: TSegarc2DArray;
  LOutSgSeg: TSegment2D;
  LOutArc, LOutSgArc: TArc2D;
begin
  Result := -1;

  APntOnArc := ClosestArcPoint(APntOnArc, AArc);
  APntOnSegarcs := ClosestSegarcsPoint(APntOnSegarcs, ASegarcs, N);
  
  LSegarc := ASegarcs[N];

  LFlag := False;
  LInctPnts := Intersection(Circle2D(AArc.Cen, AArc.R), LSegarc);

  if System.Length(LInctPnts) > 0 then
  begin
    if (System.Length(LInctPnts) = 2) then
    begin
      LExtPnt := LInctPnts[0];

      if Distance(LInctPnts[1], APntOnArc) < Distance(LInctPnts[0], APntOnArc) then
        LExtPnt := LInctPnts[1];
    end
    else
      LExtPnt := LInctPnts[0];

    if LSegarc.IsArc then
    begin
      if LSegarc.Arc.IsCW then
        LFlag := IsInAngles(GetAngle(LSegarc.Arc.Cen, APntOnSegarcs), GetAngle(LSegarc.Arc.Cen, LExtPnt), LSegarc.Arc.Ang2)
      else
        LFlag := IsInAngles(GetAngle(LSegarc.Arc.Cen, APntOnSegarcs), LSegarc.Arc.Ang1, GetAngle(LSegarc.Arc.Cen, LExtPnt));
    end
    else
      LFlag := IsPntOnSegment(APntOnSegarcs, Segment2D(LSegarc.Seg.P1, LExtPnt));      
  end;

  if (N = 0) or (N = System.Length(ASegarcs) - 1) then
  begin
    if System.Length(LInctPnts) > 0 then
    begin
      if ((N = 0) and LFlag) then
      begin
        APntOnSegarcs := MidPoint(Segment2D(LSegarc.Seg.P2, LExtPnt));
        APntOnSegarcs := ClosestSegarcPoint(APntOnSegarcs, LSegarc);
      end
      else if ((N = System.Length(ASegarcs) - 1) and not LFlag) then
      begin
        APntOnSegarcs := MidPoint(Segment2D(LSegarc.Seg.P1, LExtPnt));
        APntOnSegarcs := ClosestSegarcPoint(APntOnSegarcs, LSegarc);
      end;
    end;

    LFlag := (N = (System.Length(ASegarcs) - 1));

    System.SetLength(LSegarcs, System.Length(ASegarcs) - 1);
    if LFlag then
    begin
      for I := 0 to System.Length(ASegarcs) - 2 do LSegarcs[I] := ASegarcs[I];
    end
    else begin
      for I := 1 to System.Length(ASegarcs) - 1 do LSegarcs[I-1] := ASegarcs[I];
    end;
  end
  else begin
    if System.Length(LInctPnts) <= 0 then Exit;  //=======>>>>>
    
    if LFlag then
    begin
      System.SetLength(LSegarcs, N);
      for I := 0 to N - 1 do LSegarcs[I] := ASegarcs[I];
    end
    else begin
      System.SetLength(LSegarcs, System.Length(ASegarcs) - N - 1);
      for I := N + 1 to System.Length(ASegarcs) - 1 do LSegarcs[I-N-1] := ASegarcs[I];
    end;
  end;

  if LSegarc.IsArc then
  begin
    Result := Fillet(ARadius, APntOnArc, APntOnSegarcs, AArc, LSegarc.Arc, LOutArc, LOutSgArc, AOutFtArc);
    if Result = FILLET_SUCCESS then
    begin
      if LFlag then
      begin
        if LOutSgArc.IsCW then
          LPnt := ShiftPoint(LOutSgArc.Cen, LOutSgArc.Ang1, LOutSgArc.R)
        else
          LPnt := ShiftPoint(LOutSgArc.Cen, LOutSgArc.Ang2, LOutSgArc.R);

        AOutFtArc.IsCW := IsEqual(LPnt, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));
      end
      else begin
        if LOutSgArc.IsCW then
          LPnt := ShiftPoint(LOutSgArc.Cen, LOutSgArc.Ang2, LOutSgArc.R)
        else
          LPnt := ShiftPoint(LOutSgArc.Cen, LOutSgArc.Ang1, LOutSgArc.R);

        AOutFtArc.IsCW := IsEqual(LPnt, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang1, AOutFtArc.R));
      end;
    end;
  end
  else begin
    Result := Fillet(ARadius, APntOnSegarcs, APntOnArc, LSegarc.Seg, AArc, LOutSgSeg, LOutArc, AOutFtArc);
    if Result = FILLET_SUCCESS then
    begin
      if LFlag then
        AOutFtArc.IsCW := IsEqual(LOutSgSeg.P2, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R))
      else
        AOutFtArc.IsCW := IsEqual(LOutSgSeg.P1, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang1, AOutFtArc.R))
    end;
  end;

  if Result = FILLET_SUCCESS then
  begin
    if LFlag then
    begin
      if AOutFtArc.IsCW then
        LPnt := ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang1, AOutFtArc.R)
      else
        LPnt := ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R);

      if LOutArc.IsCW then
      begin
        if NotEqual(ShiftPoint(LOutArc.Cen, LOutArc.Ang2, LOutArc.R), LPnt) then LOutArc.IsCW := False;
      end
      else begin
        if NotEqual(ShiftPoint(LOutArc.Cen, LOutArc.Ang1, LOutArc.R), LPnt) then LOutArc.IsCW := True;
      end;
    end
    else begin
      if AOutFtArc.IsCW then
        LPnt := ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R)
      else
        LPnt := ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang1, AOutFtArc.R);

      if LOutArc.IsCW then
      begin
        if NotEqual(ShiftPoint(LOutArc.Cen, LOutArc.Ang1, LOutArc.R), LPnt) then LOutArc.IsCW := False;
      end
      else begin
        if NotEqual(ShiftPoint(LOutArc.Cen, LOutArc.Ang2, LOutArc.R), LPnt) then LOutArc.IsCW := True;
      end;
    end;

    if LFlag then
    begin
      L := System.Length(LSegarcs);

      System.SetLength(AOutSegarcs, L + 3);
      for I := 0 to L - 1 do AOutSegarcs[I] := LSegarcs[I];

      if LSegarc.IsArc then
        AOutSegarcs[L] := Segarc2D(LOutSgArc)
      else
        AOutSegarcs[L] := Segarc2D(LOutSgSeg);

      AOutSegarcs[L+1] := Segarc2D(AOutFtArc);

      AOutSegarcs[L+2] := Segarc2D(LOutArc);
    end
    else begin
      L := System.Length(LSegarcs);

      System.SetLength(AOutSegarcs, L + 3);
      for I := 3 to System.Length(AOutSegarcs) - 1 do AOutSegarcs[I] := LSegarcs[I-3];


      AOutSegarcs[0] := Segarc2D(LOutArc);

      AOutSegarcs[1] := Segarc2D(AOutFtArc);

      if LSegarc.IsArc then
        AOutSegarcs[0] := Segarc2D(LOutSgArc)
      else
        AOutSegarcs[2] := Segarc2D(LOutSgSeg);
    end;
  end;
end;





//---------------------------------------------------------------------------------------------

function Fillet(ARadius: Float; APntOn1, APntOn2: TPoint2D; ASegarcs1, ASegarcs2: TSegarc2DArray;
                var AOutSegarcs: TSegarc2DArray; var AOutFtArc: TArc2D): Integer;

  function _IsStart(AInctPnt, AOnPnt: TPoint2D; ASegarc: TSegarc2D): Boolean;
  var
    LOnAng, LInctAng: Float;
  begin
    if ASegarc.IsArc then
    begin
      LOnAng   := GetAngle(ASegarc.Arc.Cen, AOnPnt);
      LInctAng := GetAngle(ASegarc.Arc.Cen, AInctPnt);

      if IsInAngles(LInctAng, ASegarc.Arc.Ang1, ASegarc.Arc.Ang2) then
      begin
        if NotEqual(ASegarc.Arc.Ang1, LInctAng) then
          Result := IsInAngles(LOnAng, ASegarc.Arc.Ang1, LInctAng)
        else
          Result := not IsInAngles(LOnAng, LInctAng, ASegarc.Arc.Ang2);
      end
      else
        Result := FixAngle(LInctAng - ASegarc.Arc.Ang1) > FixAngle(LInctAng - ASegarc.Arc.Ang2);

      if ASegarc.Arc.IsCW then Result := not Result;
    end
    else begin
      if IsPntOnSegment(AInctPnt, ASegarc.Seg) then
      begin
        if NotEqual(ASegarc.Seg.P1, AInctPnt) then
          Result := IsPntOnSegment(AOnPnt, Segment2D(ASegarc.Seg.P1, AInctPnt))
        else
          Result := not IsPntOnSegment(AOnPnt, Segment2D(AInctPnt, ASegarc.Seg.P2));
      end
      else
        Result := Distance(AInctPnt, ASegarc.Seg.P1) > Distance(AInctPnt, ASegarc.Seg.P2);
    end;
  end;

  function _SplitSegarcs(ASegarcs: TSegarc2DArray; APos: Integer; AStart: Boolean): TSegarc2DArray;
  var
    I: Integer;
  begin
    if AStart then
    begin
      System.SetLength(Result, APos);
      for I := 0 to APos - 1 do Result[I] := ASegarcs[I];
    end
    else begin
      System.SetLength(Result, System.Length(ASegarcs) - APos - 1);
      for I := 0 to System.Length(Result) - 1 do Result[I] := ASegarcs[APos + 1 + I];
    end;  
  end;

  function _SwitchSegarc(ASegarc: TSegarc2D): TSegarc2D;
  begin
    Result := ASegarc;
    if Result.IsArc then
      Result.Arc.IsCW := not Result.Arc.IsCW;
    Swap(Result.Seg.P1, Result.Seg.P2);
  end;

var
  I, N: Integer;
  N1, N2: Integer;
  L1, L2: Integer;
  LIsStart1: Boolean;
  LIsStart2: Boolean;
  LSeg1, LSeg2: TSegment2D;
  LArc1, LArc2: TArc2D;
  LSegarc1, LSegarc2, LFtSegarc: TSegarc2D;
  LInctPnts: TPoint2DArray;
  LSegarcs1, LSegarcs2: TSegarc2DArray;
begin
  Result := -1;

  APntOn1 := ClosestSegarcsPoint(APntOn1, ASegarcs1, N1);
  APntOn2 := ClosestSegarcsPoint(APntOn2, ASegarcs2, N2);

  LSegarc1 := ASegarcs1[N1];
  LSegarc2 := ASegarcs2[N2];

  LInctPnts := Intersection(LSegarc1, LSegarc2);

  if System.Length(LInctPnts) <= 0 then
  begin
    if LSegarc1.IsArc then
      LInctPnts := Intersection(Circle2D(LSegarc1.Arc.Cen, LSegarc1.Arc.R), LSegarc2)
    else
      LInctPnts := Intersection(Line2D(LSegarc1.Seg.P1, LSegarc1.Seg.P2), LSegarc2);

    if System.Length(LInctPnts) = 2 then
    begin
      if Distance(LInctPnts[1], APntOn1) <  Distance(LInctPnts[0], APntOn1) then
      begin
        Swap(LInctPnts[1], LInctPnts[0]);
        System.SetLength(LInctPnts, 1);
      end;
    end;
  end;

  if System.Length(LInctPnts) <= 0 then
  begin
    if LSegarc2.IsArc then
      LInctPnts := Intersection(Circle2D(LSegarc2.Arc.Cen, LSegarc2.Arc.R), LSegarc1)
    else
      LInctPnts := Intersection(Line2D(LSegarc2.Seg.P1, LSegarc2.Seg.P2), LSegarc1);

    if System.Length(LInctPnts) = 2 then
    begin
      if Distance(LInctPnts[1], APntOn2) <  Distance(LInctPnts[0], APntOn2) then
      begin
        Swap(LInctPnts[1], LInctPnts[0]);
        System.SetLength(LInctPnts, 1);
      end;
    end;
  end;

  if System.Length(LInctPnts) <= 0 then
  begin
    if LSegarc1.IsArc then
    begin
      if LSegarc2.IsArc then
        LInctPnts := Intersection(Circle2D(LSegarc1.Arc.Cen, LSegarc1.Arc.R), Circle2D(LSegarc2.Arc.Cen, LSegarc2.Arc.R))
      else
        LInctPnts := Intersection(Line2D(LSegarc2.Seg.P1, LSegarc2.Seg.P2), Circle2D(LSegarc1.Arc.Cen, LSegarc1.Arc.R));
    end
    else begin
      if LSegarc2.IsArc then
        LInctPnts := Intersection(Line2D(LSegarc1.Seg.P1, LSegarc1.Seg.P2), Circle2D(LSegarc2.Arc.Cen, LSegarc2.Arc.R))
      else
        LInctPnts := Intersection(Line2D(LSegarc1.Seg.P1, LSegarc1.Seg.P2), Line2D(LSegarc2.Seg.P1, LSegarc2.Seg.P2));
    end;
  end;

  if System.Length(LInctPnts) = 2 then
  begin
    if (Distance(LInctPnts[1], APntOn1) + Distance(LInctPnts[1], APntOn2)) <
       (Distance(LInctPnts[0], APntOn2) + Distance(LInctPnts[0], APntOn2)) then
    begin
      Swap(LInctPnts[1], LInctPnts[0]);
      System.SetLength(LInctPnts, 1);
    end;
  end;

  if System.Length(LInctPnts) <= 0 then Exit;

  LIsStart1 := _IsStart(LInctPnts[0], APntOn1, LSegarc1);
  LSegarcs1 := _SplitSegarcs(ASegarcs1, N1, LIsStart1);

  LIsStart2 := _IsStart(LInctPnts[0], APntOn2, LSegarc2);
  LSegarcs2 := _SplitSegarcs(ASegarcs2, N2, LIsStart2);

  if LSegarc1.IsArc then
  begin
    if LSegarc2.IsArc then
    begin
      Result := Fillet(ARadius, APntOn1, APntOn2, LSegarc1.Arc, LSegarc2.Arc, LArc1, LArc2, AOutFtArc);
      if Result = FILLET_SUCCESS then
      begin
        if LArc1.IsCW then
          AOutFtArc.IsCW := IsEqual(ShiftPoint(LArc1.Cen, LArc1.Ang1, LArc1.R), ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R))
        else
          AOutFtArc.IsCW := IsEqual(ShiftPoint(LArc1.Cen, LArc1.Ang2, LArc1.R), ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));

        LSegarc1  := Segarc2D(LArc1);
        LSegarc2  := Segarc2D(LArc2);
        LFtSegarc := Segarc2D(AOutFtArc);
      end;
    end
    else begin
      Result := Fillet(ARadius, APntOn2, APntOn1, LSegarc2.Seg, LSegarc1.Arc, LSeg2, LArc1, AOutFtArc);
      if Result = FILLET_SUCCESS then
      begin
        if LArc1.IsCW then
          AOutFtArc.IsCW := IsEqual(ShiftPoint(LArc1.Cen, LArc1.Ang1, LArc1.R), ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R))
        else
          AOutFtArc.IsCW := IsEqual(ShiftPoint(LArc1.Cen, LArc1.Ang2, LArc1.R), ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));      

        LSegarc1  := Segarc2D(LArc1);
        LSegarc2  := Segarc2D(LSeg2);
        LFtSegarc := Segarc2D(AOutFtArc);
      end;
    end;
  end
  else begin
    if LSegarc2.IsArc then
    begin
      Result := Fillet(ARadius, APntOn1, APntOn2, LSegarc1.Seg, LSegarc2.Arc, LSeg1, LArc2, AOutFtArc);
      if Result = FILLET_SUCCESS then
      begin
        AOutFtArc.IsCW := IsEqual(LSeg1.P2, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));

        LSegarc1  := Segarc2D(LSeg1);
        LSegarc2  := Segarc2D(LArc2);
        LFtSegarc := Segarc2D(AOutFtArc);
      end;
    end
    else begin
      Result := Fillet(ARadius, APntOn1, APntOn2, LSegarc1.Seg, LSegarc2.Seg, LSeg1, LSeg2, AOutFtArc);
      if Result = FILLET_SUCCESS then
      begin
        AOutFtArc.IsCW := IsEqual(LSeg1.P2, ShiftPoint(AOutFtArc.Cen, AOutFtArc.Ang2, AOutFtArc.R));
        
        LSegarc1  := Segarc2D(LSeg1);
        LSegarc2  := Segarc2D(LSeg2);
        LFtSegarc := Segarc2D(AOutFtArc);
      end;      
    end;
  end;

  if Result = FILLET_SUCCESS then
  begin
    L1 := System.Length(LSegarcs1);
    L2 := System.Length(LSegarcs2);
    System.SetLength(AOutSegarcs, L1 + L2 + 3); // 3 = LSegarc1, LFtSegarc, LSegarc2

    if LIsStart1 then
    begin
      for I := 0 to L1 - 1 do AOutSegarcs[I] := LSegarcs1[I];
      AOutSegarcs[L1+0] := LSegarc1;
      AOutSegarcs[L1+1] := LFtSegarc;
    end
    else begin
      N := 0;
      for I := L1 - 1 downto 0 do
      begin
        AOutSegarcs[N] := _SwitchSegarc(LSegarcs1[I]);
        N := N + 1;
      end;
      
      AOutSegarcs[L1+0] := _SwitchSegarc(LSegarc1);
      AOutSegarcs[L1+1] := _SwitchSegarc(LFtSegarc);
    end;

    if LIsStart2 then
    begin
      AOutSegarcs[L1+2] := _SwitchSegarc(LSegarc2);

      N := 0;
      for I := L2 - 1 downto 0 do
      begin
        AOutSegarcs[L1+3 + N] := _SwitchSegarc(LSegarcs2[I]);
        N := N + 1;
      end;

    end
    else begin
      AOutSegarcs[L1+2] := LSegarc2;
      for I := 0 to L2 - 1 do AOutSegarcs[L1+3 + I] := LSegarcs2[I];
    end;

  end;
end;



function Fillet(ARadius: Float; ASegarcs: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray): Integer;
var
  I: Integer;
  J, L: Integer;
  LClosed: Boolean;
  LSegarc: PSegarc2D;
  LSegarcList: TList;
  LSegarc1, LSegarc2: TSegarc2D;
  LSeg1, LSeg2: TSegment2D;
  LArc1, LArc2, LChArc: TArc2D;
begin
  Result := -1;
  AOutSegarcs := nil;

  if System.Length(ASegarcs) <= 1 then Exit;

  L := System.Length(ASegarcs);
  LClosed := IsEqual(SegarcEndPnts(ASegarcs[0])[0], SegarcEndPnts(ASegarcs[L-1])[1]);


  LSegarcList := TList.Create();
  try
    for I := 0 to System.Length(ASegarcs) - 1 do
    begin
      LSegarc := New(PSegarc2D);
      LSegarc^ := ASegarcs[I];
      LSegarcList.Add(LSegarc);
    end;

    I := 0;
    while I < LSegarcList.Count do
    begin
      J := (I+1) mod LSegarcList.Count;
      if (J = 0) and not LClosed then Break;
      

      LSegarc1 := PSegarc2D(LSegarcList[I])^;
      LSegarc2 := PSegarc2D(LSegarcList[J])^;

      if LSegarc1.IsArc then
      begin
        if LSegarc2.IsArc then
        begin
          if Fillet(ARadius, LSegarc1.Seg.P2, LSegarc2.Seg.P1,
                     LSegarc1.Arc, LSegarc2.Arc, LArc1, LArc2, LChArc) = FILLET_SUCCESS then
          begin
            PSegarc2D(LSegarcList[I])^ := Segarc2D(LArc1);
            PSegarc2D(LSegarcList[J])^ := Segarc2D(LArc2);

            LChArc.IsCW := IsEqual(
              ShiftPoint(LChArc.Cen, LChArc.Ang1, LChArc.R),
              ShiftPoint(LArc2.Cen, LArc2.Ang1, LArc2.R)
            );

            LSegarc := New(PSegarc2D);
            LSegarc^ := Segarc2D(LChArc);
            LSegarcList.Insert(J, LSegarc);

            Inc(I);
          end;
        end
        else begin
          if Fillet(ARadius, LSegarc2.Seg.P1, LSegarc1.Seg.P2,
                     LSegarc2.Seg, LSegarc1.Arc,  LSeg2, LArc1, LChArc) = FILLET_SUCCESS then
          begin
            PSegarc2D(LSegarcList[I])^ := Segarc2D(LArc1);
            PSegarc2D(LSegarcList[J])^ := Segarc2D(LSeg2);

            LChArc.IsCW := IsEqual(
              ShiftPoint(LChArc.Cen, LChArc.Ang1, LChArc.R),
              LSeg2.P1
            );

            LSegarc := New(PSegarc2D);
            LSegarc^ := Segarc2D(LChArc);
            LSegarcList.Insert(J, LSegarc);

            Inc(I);
          end;
        end;

      end
      else begin
        if LSegarc2.IsArc then
        begin
          if Fillet(ARadius, LSegarc1.Seg.P2, LSegarc2.Seg.P1,
                     LSegarc1.Seg, LSegarc2.Arc, LSeg1, LArc2, LChArc) = FILLET_SUCCESS then
          begin
            PSegarc2D(LSegarcList[I])^ := Segarc2D(LSeg1);
            PSegarc2D(LSegarcList[J])^ := Segarc2D(LArc2);

            LChArc.IsCW := IsEqual(
              ShiftPoint(LChArc.Cen, LChArc.Ang1, LChArc.R),
              ShiftPoint(LArc2.Cen, LArc2.Ang1, LArc2.R)
            );
                        
            LSegarc := New(PSegarc2D);
            LSegarc^ := Segarc2D(LChArc);
            LSegarcList.Insert(J, LSegarc);

            Inc(I);
          end;
        end
        else begin
          if Fillet(ARadius, LSegarc1.Seg.P2, LSegarc2.Seg.P1,
                     LSegarc1.Seg, LSegarc2.Seg, LSeg1, LSeg2, LChArc) = FILLET_SUCCESS then
          begin
            PSegarc2D(LSegarcList[I])^ := Segarc2D(LSeg1);
            PSegarc2D(LSegarcList[J])^ := Segarc2D(LSeg2);

            LChArc.IsCW := IsEqual(
              ShiftPoint(LChArc.Cen, LChArc.Ang1, LChArc.R),
              LSeg2.P1
            );
            
            LSegarc := New(PSegarc2D);
            LSegarc^ := Segarc2D(LChArc);
            LSegarcList.Insert(J, LSegarc);

            Inc(I);
          end;
        end;
      end;

      Inc(I);
    end;

    

    System.SetLength(AOutSegarcs, LSegarcList.Count);
    for I := 0 to LSegarcList.Count - 1 do AOutSegarcs[I] := PSegarc2D(LSegarcList[I])^;

  finally
    for I := LSegarcList.Count - 1 downto 0 do
      Dispose(PSegarc2D(LSegarcList[I]));
    LSegarcList.Free;  
  end;

  Result := FILLET_SUCCESS;

end;

end.