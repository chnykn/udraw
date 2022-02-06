{
  This file is part of the DelphiCAD SDK

  Copyright:
  (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPatternLine;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes;

type
  TUdPatternLine = class(TPersistent)
  private
    FAngle: Float;
    FOrigin: TPoint2D;
    FOffset: TPoint2D;
    FDashes: TFloatArray;

  protected

  public
    constructor Create(); overload;
    constructor Create(AAngle: Float; AOriginX, AOriginY: Float; AOffsetX, AOffsetY: Float;
                       ADashes: array of Float); overload;
    destructor Destroy(); override;

    procedure Assign(Source: TPersistent); override;
    function IsEqual(AValue: TUdPatternLine): Boolean;

    function GetDashesLength(): Float;

    function CalcHatchSegments(ASegarcs: TSegarc2DArray; AScale: Float = 1.0; ARotation: Float = 0.0): TSegment2DArray; overload;
    function CalcHatchSegments(ASegarcs: TSegarc2DArray; var ASegmentList: TList; AScale: Float = 1.0; ARotation: Float = 0.0): Boolean; overload;

    function CalcHatchSegments(ASegarcsArray: TSegarc2DArrays; AScale: Float = 1.0; ARotation: Float = 0.0): TSegment2DArray; overload;
    function CalcHatchSegments(ASegarcsArray: TSegarc2DArrays; var ASegmentList: TList; AScale: Float = 1.0; ARotation: Float = 0.0): Boolean; overload;

    procedure Scale(AScale: Float);

  published
    property Angle: Float read FAngle write FAngle;
    property Origin: TPoint2D read FOrigin write FOrigin;
    property Offset: TPoint2D read FOffset write FOffset;
    property Dashes: TFloatArray read FDashes write FDashes;

  end;

implementation

uses
  UdMath, UdGeo2D;



//==================================================================================================

function FTrunc(Value: Double): Integer;
var
  LRound: Integer;
begin
  LRound := System.Round(Value);
  if IsEqual(Value, LRound) then
    Result := LRound
  else
    Result := System.Trunc(Value);
end;



function FIntersection(Ln: TLine2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
var
  J: Integer;
  K, N, M: Integer;
  LPnts: TPoint2DArray;
begin
  Result := nil;
  LPnts := nil;
  if (System.Length(Segarcs) <= 0) then Exit;  //---->>>>

  for J := 0 to System.Length(Segarcs) - 1 do
  begin
    LPnts := Intersection(Ln, Segarcs[J], Epsilon);

    M := System.Length(LPnts);
    if M <= 0 then Continue;

    N := System.Length(Result);
    System.SetLength(Result, M + N);

    for K := 0 to M - 1 do
      Result[N + K] := LPnts[K];
  end;
end;

function FIntersection(Ln: TLine2D; SegarcsArr: TSegarc2DArrays; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
var
  I, J: Integer;
  K, N, M: Integer;
  LPnts: TPoint2DArray;
  LSegarcs: TSegarc2DArray;
begin
  Result := nil;
  LPnts := nil;
  if (System.Length(SegarcsArr) <= 0) then Exit;  //---->>>>

  for I := 0 to System.Length(SegarcsArr) - 1 do
  begin
    LSegarcs := SegarcsArr[I];
    for J := 0 to System.Length(LSegarcs) - 1 do
    begin
      LPnts := Intersection(Ln, LSegarcs[J], Epsilon);

      M := System.Length(LPnts);
      if M <= 0 then Continue;

      N := System.Length(Result);
      System.SetLength(Result, M + N);

      for K := 0 to M - 1 do
        Result[N + K] := LPnts[K];
    end;
  end;
end;




procedure FCalcHatchSegs(AIncPnts: TPoint2DArray; AXPos, AYPos: Float; AAngle: Float;
  ADashes: TFloatArray; ADashsLen: Float; AOffset, AOrigin: TPoint2D; var ASegmentList: TList);
var
  I, J, N: Integer;
  LPnt: TPoint2D;
  LX1, LX2: Float;
  LXPos, LDash: Float;
  LSegment: PSegment2D;
begin
  N := 0;
  for I := 0 to System.Length(AIncPnts) - 2 do
  begin
    LX1 := AIncPnts[I].X;
    LX2 := AIncPnts[I+1].X;

    if (IsEqual(LX1, LX2) or Odd(N)) then
    begin
      Inc(N);
      Continue;
    end;

    if IsEqual(ADashsLen, 0.0) then
    begin
      LSegment := New(PSegment2D);
      LSegment^.P1 := Rotate(AOrigin, AAngle, Point2D(LX1, AYPos));
      LSegment^.P2 := Rotate(AOrigin, AAngle, Point2D(LX2, AYPos));
      ASegmentList.Add(LSegment);
    end
    else begin
      LPnt := Point2D(LX1, AYPos);
      LXPos := AXPos;

      if (LXPos < LX1) then
        LXPos := LX1 - ModFloat((LX1 - LXPos), ADashsLen);

      if (LXPos > LX1) then
        LXPos := LX1 + ModFloat((LXPos - LX1), ADashsLen);

      if LXPos > LX1 then
        LXPos := LXPos - ADashsLen;

      while (LXPos < LX2) do
      begin
        for J := 0 to System.Length(ADashes) - 1 do
        begin
          LDash := ADashes[J];

          LXPos := LXPos + Abs(LDash);

          if (LXPos >= LX1) then
          begin
            if (LXPos > LX2) then LXPos := LX2;

            if IsEqual(LDash, 0.0) then
            begin
              LSegment := New(PSegment2D);
              LSegment^.P1 := Rotate(AOrigin, AAngle, LPnt);
              LSegment^.P2 := Rotate(AOrigin, AAngle, LPnt);
              ASegmentList.Add(LSegment);
            end
            else if (LDash > 0.0) then
            begin
              LSegment := New(PSegment2D);
              LSegment^.P1 := Rotate(AOrigin, AAngle, LPnt);
              LSegment^.P2 := Rotate(AOrigin, AAngle, Point2D(LXPos, AYPos));
              ASegmentList.Add(LSegment);
            end;

            LPnt := Point2D(LXPos, AYPos);

            if (LXPos >= LX2) then Break;
          end;
        end;
      end; {end while}
    end;

    Inc(N);
  end;
end;




//==================================================================================================
{ TUdPatternLine }

constructor TUdPatternLine.Create;
begin
  FAngle := 0.0;
  FOrigin := Point2D(0.0, 0.0);
  FOffset := Point2D(0.0, 0.0);
  FDashes := nil;
end;


constructor TUdPatternLine.Create(AAngle: Float; AOriginX, AOriginY: Float; AOffsetX, AOffsetY: Float;
  ADashes: array of Float);
var
  I: Integer;
begin
  FAngle := AAngle;
  FOrigin.X := AOriginX;
  FOrigin.Y := AOriginY;
  FOffset.X := AOffsetX;
  FOffset.Y := AOffsetY;

  System.SetLength(FDashes, System.Length(ADashes));
  for I := 0 to System.Length(ADashes) - 1 do FDashes[I] := ADashes[I];
end;


destructor TUdPatternLine.Destroy;
begin

  inherited;
end;

procedure TUdPatternLine.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source.InheritsFrom(TUdPatternLine) then
  begin
    FAngle := TUdPatternLine(Source).FAngle;
    FOrigin := TUdPatternLine(Source).FOrigin;
    FOffset := TUdPatternLine(Source).FOffset;

    System.SetLength(FDashes, System.Length(TUdPatternLine(Source).FDashes));
    for I := 0 to System.Length(FDashes) - 1 do
      FDashes[I] := TUdPatternLine(Source).FDashes[I];
  end
  else
    inherited;
end;


function TUdPatternLine.IsEqual(AValue: TUdPatternLine): Boolean;
begin
  Result := False;
  if not Assigned(AValue) then Exit;

  Result := UdMath.IsEqual(FAngle, AValue.FAngle) and
            UdMath.IsEqual(FOrigin, AValue.FOrigin) and
            UdMath.IsEqual(FOffset, AValue.FOffset) and
            UdMath.IsEqual(FDashes, AValue.FDashes);
end;


function TUdPatternLine.GetDashesLength: Float;
var
  I: Integer;
begin
  Result := 0.0;
  if System.Length(FDashes) <= 0 then Exit;

  for I := 0 to System.Length(FDashes) - 1 do
    Result := Result + Abs(FDashes[I]);
end;



procedure TUdPatternLine.Scale(AScale: Float);
var
  I: Integer;
begin
  if NotEqual(AScale, 0) then
    for I := 0 to System.Length(FDashes) - 1 do FDashes[I] := FDashes[I] * AScale;
end;





//-------------------------------------------------------------------------------------------

function TUdPatternLine.CalcHatchSegments(ASegarcs: TSegarc2DArray; var ASegmentList: TList; AScale: Float = 1.0; ARotation: Float = 0.0): Boolean;
var
  LSegarcsArr: TSegarc2DArrays;
begin
  System.SetLength(LSegarcsArr, 1);
  LSegarcsArr[0] := ASegarcs;

  Result := Self.CalcHatchSegments(LSegarcsArr, ASegmentList, AScale, ARotation);
end;
(*
function TUdPatternLine.CalcHatchSegments(ASegarcs: TSegarc2DArray; var ASegmentList: TList; AScale: Float = 1.0; ARotation: Float = 0.0): Boolean;
var
  I, N: Integer;
  LDx, LDy: Float;
  LRect: TRect2D;
  LIncPnts: TPoint2DArray;
  LSegarcs: TSegarc2DArray;

  LDashsLen: Float;
  LDashes: TFloatArray;
  LRotation: Float;
  LOffset, LOrigin: TPoint2D;
begin
  Result := False;
  if (System.Length(ASegarcs) <= 0) or not Assigned(ASegmentList) or
     (System.Length(FDashes) <= 0) or IsEqual(FOffset.Y, 0.0) or IsEqual(AScale, 0.0) then Exit;


  if IsEqual(AScale, 1.0) then
  begin
    LOrigin := FOrigin;
    LOffset := FOffset;
    LDashes := FDashes;
    LDashsLen := Self.GetDashesLength();
  end
  else begin
    LOrigin.X := FOrigin.X * AScale;
    LOrigin.Y := FOrigin.Y * AScale;

    LOffset.X := FOffset.X * AScale;
    LOffset.Y := FOffset.Y * AScale;

    System.SetLength(LDashes, System.Length(FDashes));
    for I := 0 to System.Length(LDashes) - 1 do LDashes[I] := FDashes[I] * AScale;

    LDashsLen := Self.GetDashesLength() * AScale;
  end;

  LRotation := FixAngle(ARotation);
  if IsEqual(LRotation, 0.0) then
    LSegarcs := ASegarcs
  else
    LSegarcs := UdGeo2D.Rotate(-LRotation, ASegarcs);

  LSegarcs := UdGeo2D.Rotate(LOrigin, -FAngle, LSegarcs);

  LRect := RectHull(LSegarcs);

  LDy :=  LOffset.Y + LOrigin.Y;
  if (LDy < LRect.Y1) then
    LDy := LRect.Y1 - ModFloat((LRect.Y1 - LDy), Abs(LOffset.Y));
  if (LDy > LRect.Y1) then
    LDy := LRect.Y1 + ModFloat((LDy - LRect.Y1), Abs(LOffset.Y));

  LDx := LOffset.X * FTrunc((LDy - LOrigin.Y) / LOffset.Y) + LOrigin.X;

  N := ASegmentList.Count;
  while LDy < LRect.Y2 do
  begin
    LIncPnts := FIntersection(Line2D(1.0, LDy, 2.0, LDy), LSegarcs);
    if System.Length(LIncPnts) > 1 then
    begin
      UdGeo2D.SortPoints(LIncPnts, Point2D(LRect.X1, LDy), 0);
      FCalcHatchSegs(LIncPnts, LDx, LDy, FAngle, LDashes, LDashsLen, LOffset, LOrigin, ASegmentList);
    end;

    LDy := LDy + Abs(LOffset.Y);
    if LOffset.Y > 0 then
      LDx := LDx + LOffset.X
    else
      LDx := LDx - LOffset.X;
  end;

  if not IsEqual(LRotation, 0.0) then
  begin
    for I := N to ASegmentList.Count - 1 do
      PSegment2D(ASegmentList[I])^ := UdGeo2D.Rotate(LRotation, PSegment2D(ASegmentList[I])^);
  end;

  Result := True;
end;
*)

function TUdPatternLine.CalcHatchSegments(ASegarcs: TSegarc2DArray; AScale: Float = 1.0; ARotation: Float = 0.0): TSegment2DArray;
var
  I: Integer;
  LSegmentList: TList;
begin
  Result := nil;
  if System.Length(ASegarcs) <= 0 then Exit;

  LSegmentList := TList.Create;
  try
    if CalcHatchSegments(ASegarcs, LSegmentList, AScale, ARotation) then
    begin
      System.SetLength(Result, LSegmentList.Count);
      for I := 0 to LSegmentList.Count - 1 do Result[I] := PSegment2D(LSegmentList[I])^;
    end;
  finally
    for I := LSegmentList.Count - 1 downto 0 do Dispose(PSegment2D(LSegmentList[I]));
    LSegmentList.Free;
  end;
end;





//--------------------------------------------------------------------------------------------------

function FRectHull(ASegarcsArray: TSegarc2DArrays): TRect2D;
var
  I: Integer;
  LRect: TRect2D;
begin
  Result := UdGeo2D.RectHull(ASegarcsArray[0]);

  for I := 1 to System.Length(ASegarcsArray) - 1 do
  begin
    LRect := UdGeo2D.RectHull(ASegarcsArray[I]);

    if Result.X1 > LRect.X1 then Result.X1 := LRect.X1;
    if Result.X2 < LRect.X2 then Result.X2 := LRect.X2;
    if Result.Y1 > LRect.Y1 then Result.Y1 := LRect.Y1;
    if Result.Y2 < LRect.Y2 then Result.Y2 := LRect.Y2;
  end;
end;



var
  GSegarcsArray: TSegarc2DArrays;

function _AllowTrimPnt(APnt: TPoint2D): Boolean;
var
  I, J: Integer;
begin
  Result := False;
  for I := 0 to System.Length(GSegarcsArray) - 1 do
  begin
    for J := 0 to System.Length(GSegarcsArray[I]) - 1 do
    begin
      Result := IsEqual(GSegarcsArray[I][J].Seg.P1, APnt) or
                IsEqual(GSegarcsArray[I][J].Seg.P2, APnt) ;
      if Result then Exit; //=====>>>>
    end;
  end;
end;




function TUdPatternLine.CalcHatchSegments(ASegarcsArray: TSegarc2DArrays; var ASegmentList: TList; AScale: Float = 1.0; ARotation: Float = 0.0): Boolean;
var
  I, M: Integer;
  LDx, LDy: Float;
  LRect: TRect2D;
  LIncPnts: TPoint2DArray;
  LSegarcsArray: TSegarc2DArrays;

  LDashsLen: Float;
  LDashes: TFloatArray;
  LRotation: Float;
  LOffset, LOrigin: TPoint2D;
begin
  Result := False;
  if (System.Length(ASegarcsArray) <= 0) or not Assigned(ASegmentList) or
     {(System.Length(FDashes) <= 0) or} UdMath.IsEqual(FOffset.Y, 0.0) or UdMath.IsEqual(AScale, 0.0) then Exit;


  if UdMath.IsEqual(AScale, 1.0) then
  begin
    LOrigin := FOrigin;
    LOffset := FOffset;
    LDashes := FDashes;
    LDashsLen := Self.GetDashesLength();
  end
  else begin
    LOrigin.X := FOrigin.X * AScale;
    LOrigin.Y := FOrigin.Y * AScale;

    LOffset.X := FOffset.X * AScale;
    LOffset.Y := FOffset.Y * AScale;

    LDashsLen := Self.GetDashesLength();

    if NotEqual(AScale, 1.0) then
    begin
      System.SetLength(LDashes, System.Length(FDashes));
      for I := 0 to System.Length(LDashes) - 1 do LDashes[I] := FDashes[I] * AScale;

      LDashsLen := LDashsLen * AScale;
    end
    else
      LDashes := FDashes;
  end;

  LRotation := FixAngle(ARotation);
  if UdMath.IsEqual(LRotation, 0.0) then
  begin
    System.SetLength(LSegarcsArray, System.Length(ASegarcsArray));
    for I := 0 to System.Length(LSegarcsArray) - 1 do
      LSegarcsArray[I] := ASegarcsArray[I];
  end
  else begin
    System.SetLength(LSegarcsArray, System.Length(ASegarcsArray));
    for I := 0 to System.Length(LSegarcsArray) - 1 do
      LSegarcsArray[I] := UdGeo2D.Rotate(-LRotation, ASegarcsArray[I]);
  end;

  for I := 0 to System.Length(LSegarcsArray) - 1 do
    LSegarcsArray[I] := UdGeo2D.Rotate(LOrigin, -FAngle, LSegarcsArray[I]);

  LRect := FRectHull(LSegarcsArray);

  LDy :=  LOffset.Y + LOrigin.Y;
  if (LDy < LRect.Y1) then
    LDy := LRect.Y1 - ModFloat((LRect.Y1 - LDy), Abs(LOffset.Y));
  if (LDy > LRect.Y1) then
    LDy := LRect.Y1 + ModFloat((LDy - LRect.Y1), Abs(LOffset.Y));

  LDx := LOffset.X * FTrunc((LDy - LOrigin.Y) / LOffset.Y) + LOrigin.X;

  M := ASegmentList.Count;

  while LDy < LRect.Y2 do
  begin
    LIncPnts := FIntersection(Line2D(0.0, LDy, 1.0, LDy), LSegarcsArray);
    if System.Length(LIncPnts) > 1 then
    begin
      UdGeo2D.SortPoints(LIncPnts, Point2D(LRect.X1, LDy), 0);

      GSegarcsArray := ASegarcsArray;
      LIncPnts := UdMath.TrimPoints(LIncPnts, _Epsilon, _AllowTrimPnt);
      GSegarcsArray := nil;

      FCalcHatchSegs(LIncPnts, LDx, LDy, FAngle, LDashes, LDashsLen, LOffset, LOrigin, ASegmentList);
    end;

    LDy := LDy + Abs(LOffset.Y);
    if LOffset.Y > 0 then
      LDx := LDx + LOffset.X
    else
      LDx := LDx - LOffset.X;
  end;

  if not UdMath.IsEqual(LRotation, 0.0) then
  begin
    for I := M to ASegmentList.Count - 1 do
      PSegment2D(ASegmentList[I])^ := UdGeo2D.Rotate(LRotation, PSegment2D(ASegmentList[I])^);
  end;

  Result := True;
end;


function TUdPatternLine.CalcHatchSegments(ASegarcsArray: TSegarc2DArrays; AScale: Float = 1.0; ARotation: Float = 0.0): TSegment2DArray;
var
  I: Integer;
  LSegmentList: TList;
begin
  Result := nil;
  if System.Length(ASegarcsArray) <= 0 then Exit;

  LSegmentList := TList.Create;
  try
    if CalcHatchSegments(ASegarcsArray, LSegmentList, AScale, ARotation) then
    begin
      System.SetLength(Result, LSegmentList.Count);
      for I := 0 to LSegmentList.Count - 1 do Result[I] := PSegment2D(LSegmentList[I])^;
    end;
  finally
    for I := LSegmentList.Count - 1 downto 0 do Dispose(PSegment2D(LSegmentList[I]));
    LSegmentList.Free;
  end;
end;





end.