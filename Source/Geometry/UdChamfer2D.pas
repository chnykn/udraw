
{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdChamfer2D;

{$I UdDefs.INC}

interface

uses
  Classes, UdTypes, UdGTypes;

const
  CHAMFER_SUCCESS          = 0;
  CHAMFER_NO_INCT_PNTS     = 1;
  CHAMFER_DIS_TOO_LARGE    = 2;
  CHAMFER_NEED_LINES       = 3;


function Chamfer(AChamfer1, AChamfer2: Float; APntOn1, APntOn2: TPoint2D;
  ASeg1, ASeg2: TSegment2D; var AOutSeg1, AOutSeg2, AOutChSeg: TSegment2D): Integer; overload;

function Chamfer(AChamfer1, AChamfer2: Float; APntOnSeg, APntOnSegarcs: TPoint2D;
  ASeg: TSegment2D; ASegarcs: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray; var AOutChSeg: TSegment2D): Integer; overload;

function Chamfer(AChamfer1, AChamfer2: Float; APntOn1, APntOn2: TPoint2D;
  ASegarcs: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray; var AOutChSeg: TSegment2D): Integer; overload;

function Chamfer(AChamfer1, AChamfer2: Float; APntOn1, APntOn2: TPoint2D;
  ASegarcs1, ASegarcs2: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray; var AOutChSeg: TSegment2D): Integer; overload;

function Chamfer(AChamfer1, AChamfer2: Float; ASegarcs: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray): Integer; overload;





//---------------------------------------------------------------------------

function NormalizePntOnArc(APnt: TPoint2D; AArc: TArc2D): TPoint2D;
function NormalizePntOnSeg(APnt: TPoint2D; ASeg: TSegment2D): TPoint2D;
function NormalizeFilletSegment(ASeg: TSegment2D; AInctPnt, APickPnt: TPoint2D): TSegment2D;


implementation

uses
  UdMath, UdGeo2D;



//---------------------------------------------------------------------------------------------

function NormalizePntOnArc(APnt: TPoint2D; AArc: TArc2D): TPoint2D;
var
  LDis: Float;
  LPnt: TPoint2D;
begin
  LDis := Distance(AArc);
  LPnt := ClosestArcPoint(APnt, AArc);

  if IsEqual(LPnt, ShiftPoint(AArc.Cen, AArc.Ang1, AArc.R)) then
    Result := ShiftArcPoint(AArc, True, -LDis/4)
  else if IsEqual(LPnt, ShiftPoint(AArc.Cen, AArc.Ang2, AArc.R)) then
    Result := ShiftArcPoint(AArc, False, -LDis/4)
  else
    Result := LPnt;
end;


function NormalizePntOnSeg(APnt: TPoint2D; ASeg: TSegment2D): TPoint2D;
var
  LDis: Float;
  LPnt: TPoint2D;  
begin
  LDis := Distance(ASeg);
  LPnt := ClosestSegmentPoint(APnt, ASeg);
  
  if IsEqual(LPnt, ASeg.P1) then
    Result := ShiftPoint(ASeg.P1, GetAngle(ASeg.P1, ASeg.P2), LDis/4)
  else if IsEqual(LPnt, ASeg.P2) then
    Result := ShiftPoint(ASeg.P2, GetAngle(ASeg.P2, ASeg.P1), LDis/4)
  else
    Result := LPnt;
end;


function NormalizeFilletSegment(ASeg: TSegment2D; AInctPnt, APickPnt: TPoint2D): TSegment2D;
var
  M, N: Integer;
  LSeg1, LSeg2: TSegment2D;
begin
  if UdGeo2D.IsPntOnSegment(AInctPnt, ASeg) then
  begin
    N := 0;
    M := 0;

    if Distance(AInctPnt, ASeg.P1) > _Epsilon*100 then
    begin
      N := 1;
      M := M + 1;
      LSeg1 := Segment2D(ASeg.P1, AInctPnt);
    end;
    if Distance(AInctPnt, ASeg.P2) > _Epsilon*100 then
    begin
      N := 2;
      M := M + 1;
      LSeg2 := Segment2D(ASeg.P2, AInctPnt)
    end;

    if M = 1 then
    begin
      case N of
        1: Result := LSeg1;
        2: Result := LSeg2;
      end;
    end
    else if M = 2 then
    begin
      if UdGeo2D.DistanceToSegment(APickPnt, UdGeo2D.Segment2D(LSeg1.P1, LSeg1.P2)) <
         UdGeo2D.DistanceToSegment(APickPnt, UdGeo2D.Segment2D(LSeg2.P1, LSeg2.P2)) then
        Result := LSeg1
      else
        Result := LSeg2;
    end
    else
      Result := Segment2D(0, 0, 0, 0);
  end
  else
  begin
    if Distance(AInctPnt, ASeg.P1) > Distance(AInctPnt, ASeg.P2) then
      Result := Segment2D(ASeg.P1, AInctPnt)
    else
      Result := Segment2D(ASeg.P2, AInctPnt)
  end;
end;




//----------------------------------------------------------------------------------------


function Chamfer(AChamfer1, AChamfer2: Float; APntOn1, APntOn2: TPoint2D;
  ASeg1, ASeg2: TSegment2D; var AOutSeg1, AOutSeg2, AOutChSeg: TSegment2D): Integer;

  function _GetChamferPnts(ASeg1, ASeg2: TSegment2D; out P1, P2: TPoint2D): Integer;
  var
    D1, D2: Double;
  begin
    Result := -1;
    if IsEqual(ASeg1.P1, ASeg1.P2) or IsEqual(ASeg2.P1, ASeg2.P2) then Exit; //--->>>>

    D1 := UdGeo2D.Distance(ASeg1.P1, ASeg1.P2);
    D2 := UdGeo2D.Distance(ASeg2.P1, ASeg2.P2);

    if (D1 <= AChamfer1) or (D2 <= AChamfer2) then
    begin
      Result := CHAMFER_DIS_TOO_LARGE;
      Exit; //--->>>>
    end;

    P1.X := ASeg1.P1.X + (ASeg1.P2.X - ASeg1.P1.X) * (1 - AChamfer1 / D1);
    P1.Y := ASeg1.P1.Y + (ASeg1.P2.Y - ASeg1.P1.Y) * (1 - AChamfer1 / D1);

    P2.X := ASeg2.P1.X + (ASeg2.P2.X - ASeg2.P1.X) * (1 - AChamfer2 / D2);
    P2.Y := ASeg2.P1.Y + (ASeg2.P2.Y - ASeg2.P1.Y) * (1 - AChamfer2 / D2);

    Result := CHAMFER_SUCCESS;
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
    Result := CHAMFER_NO_INCT_PNTS;
    Exit; //====>>>>
  end;

  LPntOn1 := NormalizePntOnSeg(APntOn1, ASeg1);
  LPntOn2 := NormalizePntOnSeg(APntOn2, ASeg2);
    
  LSeg1 := NormalizeFilletSegment(ASeg1, LInctPnts[0], LPntOn1);
  LSeg2 := NormalizeFilletSegment(ASeg2, LInctPnts[0], LPntOn2);

  Result := _GetChamferPnts(LSeg1, LSeg2, LP1, LP2);
  if Result = CHAMFER_SUCCESS then
  begin
    AOutSeg1 := Segment2D(LSeg1.P1, LP1);
    AOutSeg2 := Segment2D(LSeg2.P1, LP2);

    if NotEqual(GetAngle(AOutSeg1.P1, AOutSeg1.P2), GetAngle(ASeg1.P1, ASeg1.P2), 1) then
      Swap(AOutSeg1.P1, AOutSeg1.P2);

    if NotEqual(GetAngle(AOutSeg2.P1, AOutSeg2.P2), GetAngle(ASeg2.P1, ASeg2.P2), 1) then
      Swap(AOutSeg2.P1, AOutSeg2.P2);

    AOutChSeg := Segment2D(LP1, LP2);
  end;
end;


function Chamfer(AChamfer1, AChamfer2: Float; APntOnSeg, APntOnSegarcs: TPoint2D;
  ASeg: TSegment2D; ASegarcs: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray; var AOutChSeg: TSegment2D): Integer;
var
  I, N, L: Integer;
  LFlag: Boolean;
  LSegarc: TSegarc2D;
  LExtPnt: TPoint2D;
  LInctPnts: TPoint2DArray;
  LSegarcs: TSegarc2DArray;
  LOutSeg, LOutSgSeg: TSegment2D;
begin
  Result := -1;

  APntOnSeg := ClosestLinePoint(APntOnSeg, Line2D(ASeg.P1, ASeg.P2));
  APntOnSegarcs := ClosestSegarcsPoint(APntOnSegarcs, ASegarcs, N);
  
  LSegarc := ASegarcs[N];
  if LSegarc.IsArc then
  begin
    Result := CHAMFER_NEED_LINES;
    Exit;  //=======>>>>
  end;

  LInctPnts := Intersection(Line2D(ASeg.P1, ASeg.P2), LSegarc.Seg);

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

  Result := Chamfer(AChamfer1, AChamfer2, APntOnSeg, APntOnSegarcs, ASeg, LSegarc.Seg, LOutSeg, LOutSgSeg, AOutChSeg);

  if Result = CHAMFER_SUCCESS then
  begin
    if LFlag then
    begin
      if IsEqual(AOutChSeg.P2, LOutSgSeg.P2) then Swap(AOutChSeg.P1, AOutChSeg.P2);
      if IsEqual(LOutSeg.P2, AOutChSeg.P2) then Swap(LOutSeg.P1, LOutSeg.P2);
    end
    else begin
      if IsEqual(AOutChSeg.P1, LOutSgSeg.P1) then Swap(AOutChSeg.P1, AOutChSeg.P2);
      if IsEqual(LOutSeg.P1, AOutChSeg.P1) then Swap(LOutSeg.P1, LOutSeg.P2);
    end;

    if LFlag then
    begin
      L := System.Length(LSegarcs);

      System.SetLength(AOutSegarcs, L + 3);
      for I := 0 to L - 1 do AOutSegarcs[I] := LSegarcs[I];

      AOutSegarcs[L] := Segarc2D(LOutSgSeg);
      AOutSegarcs[L+1] := Segarc2D(AOutChSeg);
      AOutSegarcs[L+2] := Segarc2D(LOutSeg);
    end
    else begin
      L := System.Length(LSegarcs);

      System.SetLength(AOutSegarcs, L + 3);
      for I := 3 to System.Length(AOutSegarcs) - 1 do AOutSegarcs[I] := LSegarcs[I-3];

      AOutSegarcs[0] := Segarc2D(LOutSeg);
      AOutSegarcs[1] := Segarc2D(AOutChSeg);
      AOutSegarcs[2] := Segarc2D(LOutSgSeg);
    end;
  end;

end;

function Chamfer(AChamfer1, AChamfer2: Float; APntOn1, APntOn2: TPoint2D;
  ASegarcs: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray; var AOutChSeg: TSegment2D): Integer;

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
  LSeg1, LSeg2: TSegment2D;  
  LPntOn1, LPntOn2: TPoint2D;
  LSegarc1, LSegarc2: TSegarc2D;
begin
  Result := -1;
  if (IsEqual(AChamfer1, 0.0) or (AChamfer1 < 0)) and
     (IsEqual(AChamfer2, 0.0) or (AChamfer2 < 0)) then Exit; //=====>>>

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

  if LSegarc1.IsArc or LSegarc2.IsArc then
  begin
    Result := CHAMFER_NEED_LINES;
    Exit;  //=======>>>>
  end;

  Result := Chamfer(AChamfer1, AChamfer2, LPntOn1, LPntOn2, LSegarc1.Seg, LSegarc2.Seg, LSeg1, LSeg2, AOutChSeg);
  if Result = CHAMFER_SUCCESS then
  begin
    if IsEqual(LSeg1.P2, AOutChSeg.P2) then Swap(AOutChSeg.P1, AOutChSeg.P2);

    AOutSegarcs  := _GenOutSegarcs(ASegarcs, N1);
    L := System.Length(AOutSegarcs);

    AOutSegarcs[N1 mod L]     := Segarc2D(LSeg1);
    AOutSegarcs[(N1+1) mod L] := Segarc2D(AOutChSeg);
    AOutSegarcs[(N1+2) mod L] := Segarc2D(LSeg2);
  end;
end;

function Chamfer(AChamfer1, AChamfer2: Float; APntOn1, APntOn2: TPoint2D;
  ASegarcs1, ASegarcs2: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray; var AOutChSeg: TSegment2D): Integer;

  function _IsStart(AInctPnt, AOnPnt: TPoint2D; ASegarc: TSegarc2D): Boolean;
  begin
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
  LSegarc1, LSegarc2, LChSegarc: TSegarc2D;
  LInctPnts: TPoint2DArray;
  LSegarcs1, LSegarcs2: TSegarc2DArray;
begin
  Result := -1;

  APntOn1 := ClosestSegarcsPoint(APntOn1, ASegarcs1, N1);
  APntOn2 := ClosestSegarcsPoint(APntOn2, ASegarcs2, N2);

  LSegarc1 := ASegarcs1[N1];
  LSegarc2 := ASegarcs2[N2];

  if LSegarc1.IsArc or LSegarc2.IsArc then
  begin
    Result := CHAMFER_NEED_LINES;
    Exit;  //=======>>>>
  end;  

  LInctPnts := Intersection(LSegarc1, LSegarc2);

  if System.Length(LInctPnts) <= 0 then
  begin
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
    LInctPnts := Intersection(Line2D(LSegarc2.Seg.P1, LSegarc2.Seg.P2), LSegarc1);

    if System.Length(LInctPnts) = 2 then
    begin
      if Distance(LInctPnts[1], APntOn2) < Distance(LInctPnts[0], APntOn2) then
      begin
        Swap(LInctPnts[1], LInctPnts[0]);
        System.SetLength(LInctPnts, 1);
      end;
    end;
  end;

  if System.Length(LInctPnts) <= 0 then
  begin
     LInctPnts := Intersection(Line2D(LSegarc1.Seg.P1, LSegarc1.Seg.P2), Line2D(LSegarc2.Seg.P1, LSegarc2.Seg.P2));
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


  Result := Chamfer(AChamfer1, AChamfer2, APntOn1, APntOn2, LSegarc1.Seg, LSegarc2.Seg, LSeg1, LSeg2, AOutChSeg);
  if Result = CHAMFER_SUCCESS then
  begin
    if IsEqual(LSeg1.P2, AOutChSeg.P2) then Swap(AOutChSeg.P1, AOutChSeg.P2);

    LSegarc1  := Segarc2D(LSeg1);
    LSegarc2  := Segarc2D(LSeg2);
    LChSegarc := Segarc2D(AOutChSeg);

    L1 := System.Length(LSegarcs1);
    L2 := System.Length(LSegarcs2);
    System.SetLength(AOutSegarcs, L1 + L2 + 3); // 3 = LSegarc1, LFtSegarc, LSegarc2

    if LIsStart1 then
    begin
      for I := 0 to L1 - 1 do AOutSegarcs[I] := LSegarcs1[I];
      AOutSegarcs[L1+0] := LSegarc1;
      AOutSegarcs[L1+1] := LChSegarc;
    end
    else begin
      N := 0;
      for I := L1 - 1 downto 0 do
      begin
        AOutSegarcs[N] := _SwitchSegarc(LSegarcs1[I]);
        N := N + 1;
      end;
      
      AOutSegarcs[L1+0] := _SwitchSegarc(LSegarc1);
      AOutSegarcs[L1+1] := _SwitchSegarc(LChSegarc);
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



function Chamfer(AChamfer1, AChamfer2: Float; ASegarcs: TSegarc2DArray; var AOutSegarcs: TSegarc2DArray): Integer;
var
  I: Integer;
  J, L: Integer;
  LClosed: Boolean;
  LSegarc: PSegarc2D;
  LSegarcList: TList;
  LSegarc1, LSegarc2: TSegarc2D;
  LSeg1, LSeg2, LChSeg: TSegment2D;
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


      if not LSegarc1.IsArc and not LSegarc2.IsArc then
      begin
        if Chamfer(AChamfer1, AChamfer2, LSegarc1.Seg.P2, LSegarc2.Seg.P1,
                   LSegarc1.Seg, LSegarc2.Seg, LSeg1, LSeg2, LChSeg) = CHAMFER_SUCCESS then
        begin
          PSegarc2D(LSegarcList[I])^ := Segarc2D(LSeg1);
          PSegarc2D(LSegarcList[J])^ := Segarc2D(LSeg2);

          LSegarc := New(PSegarc2D);
          LSegarc^ := Segarc2D(LChSeg);
          LSegarcList.Insert(J, LSegarc);

          Inc(I);
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

  Result := CHAMFER_SUCCESS;
end;


end.