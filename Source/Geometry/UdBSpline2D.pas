{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdBSpline2D;

{$I UdDefs.Inc}

interface

uses
  UdGTypes;



function GetFittingBSplineSamplePoints(AFittingPoints: TPoint2DArray; ASegments: Integer; AClosed: Boolean): TPoint2DArray; overload;
function GetFittingBSplineSamplePoints(AFittingPoints: TPoint2DArray; ASegments: Integer; AClosed: Boolean;
                                       var AKnots: TFloatArray; var ACtrlPoints: TPoint2DArray): TPoint2DArray; overload;

function GetQuadraticSPlineSamplePoints(ACtrlPoints: TPoint2DArray; ASegments: Integer;
                                       AClosed: Boolean; AKnots: TFloatArray = nil): TPoint2DArray;
function GetCubicSPlineSamplePoints(ACtrlPoints: TPoint2DArray; ASegments: Integer;
                                    AClosed: Boolean; AKnots: TFloatArray = nil): TPoint2DArray;
{
function GetQuadraticBezierSPlineSamplePoints(ACtrlPoints: TPoint2DArray; ASegments: Integer): TPoint2DArray; overload;
function GetQuadraticBezierSPlineSamplePoints(ACtrlPoints: TPoint2DArray; ASegments: Integer;
                                              AClosed: Boolean): TPoint2DArray; overload;
}

implementation


uses
  UdMath, UdGeo2D, UdColls;





 //=================================================================================================
{ TBSpline2D }

type

  TBSpline2D = class(TObject)
  private
    FCtrlPoints: TPoint2DArray;
    FPerSegment: Integer; //8
    FDegree: Integer;     //3
    FClosed: Boolean;

    FKnots: TFloatArray;
    FFittingPoints: TPoint2DArray;

  protected
    procedure SetPerSegment(const Value: Integer);
//    procedure SetClosed(const Value: Boolean);
//    procedure SetCtrlPoints(const Value: TPoint2DArray);

    function GetKnot(AIndex: Integer): Float;
    function GetCtrlPoint(AIndex: Integer): TPoint2D;

    function Evaluate(U: double; N: integer): TPoint2D;

    class function T(k: Integer; t: TFloatArray): Double; {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class procedure SolveLUSystem(ALow, AUp, AGamma, D: TFloatArray; var X: TFloatArray); {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class procedure LUAnalysis(AAlpha, ABeta, AGamma: TFloatArray; var ALow, AUp: TFloatArray); {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class function EvaluateBasis(nS: Integer; rAt: Double; AKnots: TFloatArray): TFloatArray;  {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}

    class function NormalParameterization(ACtrlPoints: TPoint2DArray; ADegree: Integer): TFloatArray; {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class function ArcLengthParameterization(APoints: TPoint2DArray; ADegree: Integer): TFloatArray; {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}

  public
    constructor Create(ACtrlPoints: TPoint2DArray; APerSegment: Integer; ADegree: Integer; AClosed: Boolean; AKnots: TFloatArray = nil);
    destructor Destroy; override;

    function GetSamplePoints(): TPoint2DArray;
    class function CalculateFittingBSpline(AFittingPoints: TPoint2DArray; AClosed: Boolean): TBSpline2D;  //; AStartTangent, AEndTangent: TPoint2D
    class function GetInterpolatedCubicBSpline(AFittingPoints: TPoint2DArray; AClosed: Boolean; AResolution: Integer): TBSpline2D;

  public
//    property Knots: TFloatArray read FKnots;
//    property Closed: Boolean read FClosed write SetClosed;
//    property PerSegment: Integer read FPerSegment write SetPerSegment;
//    property CtrlPoints: TPoint2DArray read FCtrlPoints write SetCtrlPoints;
  end;



  

constructor TBSpline2D.Create(ACtrlPoints: TPoint2DArray; APerSegment, ADegree: Integer;  AClosed: Boolean; AKnots: TFloatArray = nil);
var
  L: Integer;
  LDegree: Integer;
begin
	FCtrlPoints := ACtrlPoints;
  L := System.Length(FCtrlPoints);

  FPerSegment := APerSegment;
  if FPerSegment < 8 then FPerSegment := 8;

  FDegree := Min(L - 1, ADegree);

  FClosed := AClosed and (L > 2);
  if FClosed then
  begin
    if IsEqual(FCtrlPoints[0], FCtrlPoints[L-1]) then
    begin
      System.SetLength(FCtrlPoints, L + 2);
      FCtrlPoints[L] := FCtrlPoints[1];
      FCtrlPoints[L+1] := FCtrlPoints[2];
    end
    else begin
      System.SetLength(FCtrlPoints, L + 3);
      FCtrlPoints[L] := FCtrlPoints[0];
      FCtrlPoints[L+1] := FCtrlPoints[1];
      FCtrlPoints[L+2] := FCtrlPoints[2];
    end;

    LDegree := 0;
  end
  else
    LDegree := FDegree;

  if Length(AKnots) > Length(FCtrlPoints) then
    FKnots := AKnots
  else
    FKnots := NormalParameterization(FCtrlPoints, LDegree);
end;

destructor TBSpline2D.Destroy;
begin

  inherited;
end;


procedure TBSpline2D.SetPerSegment(const Value: Integer);
begin
  if Value >= 8 then
    FPerSegment := Value;
end;

(*
procedure TBSpline2D.SetClosed(const Value: Boolean);
begin
  if Value <> FClosed then
  begin
    FClosed := Value;

    if System.Length(FCtrlPoints) > 0 then
    begin
      if FClosed then
        FKnots := NormalParameterization(FCtrlPoints, 0)
      else
        FKnots := NormalParameterization(FCtrlPoints, {ADegree ?} FDegree);
    end;
  end;
end;

procedure TBSpline2D.SetCtrlPoints(const Value: TPoint2DArray);
begin
  FCtrlPoints := Value;

  if FClosed then
    FKnots := NormalParameterization(FCtrlPoints, 0)
  else
    FKnots := NormalParameterization(FCtrlPoints, {ADegree ?} FDegree);
end;
*)


//-----------------------------------------------------------------------------------------------

class function TBSpline2D.NormalParameterization(ACtrlPoints: TPoint2DArray; ADegree: Integer): TFloatArray;
var
  I: Integer;
  L, N: Integer;
begin
  L := System.Length(ACtrlPoints);
  N := L + 1;

  System.SetLength(Result, N);
  for I := 0 to ADegree do
    Result[I] := 0.0;

  for I := ADegree + 1 to L - 1 do
    Result[I] := (I - ADegree);

  for I := L to N - 1 do
    Result[I] := Result[L - 1] + 1.0;
end;

class function TBSpline2D.ArcLengthParameterization(APoints: TPoint2DArray; ADegree: Integer): TFloatArray;
var
  I: Integer;
  L, N: Integer;
  LDis: Float;
  LArr: TFloatArray;
  LPnt1, LPnt2: TPoint2D;
begin
  L := System.Length(APoints);

  System.SetLength(LArr, L);

  LPnt1 := APoints[0];
  LArr[0] := 0.0;

  for I := 1 to L - 1 do
  begin
    LPnt2 := APoints[I];
    LDis := Distance(LPnt1, LPnt2);
    LArr[I] := LArr[I - 1] + LDis;
    LPnt1 := LPnt2;
  end;

  N := L + 2 * ADegree;
  System.SetLength(Result, N);

  for I := 0 to ADegree - 1 do
    Result[I] := LArr[0];

  for I := 0 to L - 1 do
    Result[I + ADegree] := LArr[I];

  for I := 1 to ADegree do
    Result[N - I] := LArr[L - 1];
end;



class function TBSpline2D.T(K: Integer; T: TFloatArray): Double;
var
  N: Integer;
begin
  N := 3;
  Result := T[((N - 1) + K)]
end;

class procedure TBSpline2D.SolveLUSystem(ALow, AUp, AGamma, D: TFloatArray; var X: TFloatArray);
var
  I, L: Integer;
  LArr: TFloatArray;
begin
  L := System.Length(ALow);

  System.SetLength(X, L);

  System.SetLength(LArr, L);
  LArr[0] := D[0];

  I := 1;
  while (I < L) do
  begin
    LArr[I] := (D[I] - (ALow[I] * LArr[(I - 1)]));
    Inc(I)
  end;

  X[(L - 1)] := (LArr[(L - 1)] / AUp[(L - 1)]);

  I := (L - 2);
  while (I >= 0) do
  begin
    X[I] := (LArr[I] - (AGamma[I] * X[(I + 1)])) / AUp[I];
    Dec(I)
  end
end;

class procedure TBSpline2D.LUAnalysis(AAlpha, ABeta, AGamma: TFloatArray; var ALow, AUp: TFloatArray);
var
  I, L: Integer;
begin
  L := System.Length(ABeta);

  System.SetLength(AUp, L);
  System.SetLength(ALow, L);

  AUp[0] := ABeta[0];
  I := 1;
  while (I < L) do
  begin
    ALow[I] := (AAlpha[I] / AUp[(I - 1)]);
    AUp[I]  := (ABeta[I] - (ALow[I] * AGamma[(I - 1)]));

    Inc(I);
  end
end;



class function TBSpline2D.EvaluateBasis(nS: Integer; rAt: Double; AKnots: TFloatArray): TFloatArray;
var
  I, J: Integer;
  LIndex, N: Integer;
  LArr: TFloatArray;
  LA, LB: Float;
  LArrs: array[0..3] of TFloatArray;
begin
  LIndex := 3;
  System.SetLength(LArr, LIndex * 2);

  I := 0;
  N := ((nS - LIndex) + 1);

  while ((I < (2 * LIndex))) do
  begin
    LArr[I] := AKnots[N];
    Inc(N);
    Inc(I)
  end;

  System.SetLength(LArrs[0], 1);
  LArrs[0][0] := 1.0;

  I := 1;
  while ((I <= LIndex)) do
  begin
    System.SetLength(LArrs[I], (I + 1));

    LArrs[I][0] := (LArrs[(I - 1)][0] * ((T(1, LArr) - rAt) / (T(1, LArr) - T((-I + 1), LArr))));
    J := 1;
    while ((J < I)) do
    begin
      LA := T(J, LArr) - T(J - I, LArr);
      LB := T(J + 1, LArr) - T(J - I + 1, LArr);

      LArrs[I][J] :=  (LArrs[(I - 1)][(J - 1)] * ((rAt - T((-I + J), LArr)) / LA )) +
                      (LArrs[(I - 1)][J] * ((T((J + 1), LArr) - rAt) / LB ));
      Inc(J)
    end;

    LArrs[I][I] := (LArrs[(I - 1)][(I - 1)] * ((rAt - T(0, LArr)) / (T(I, LArr) - T(0, LArr))));
    Inc(I)
  end;

  Result := LArrs[LIndex];
end;



//-------------------------------------------------------------------------------------------------

function TBSpline2D.GetKnot(AIndex: Integer): Float;
var
  N, M: Integer;
begin
  N := 0;
  M := System.Length(FKnots) - 1;

  while (AIndex >= M) do
  begin
    AIndex := AIndex - M;
    Inc(N);
  end;

  while (AIndex < 0) do
  begin
    AIndex := AIndex + M;
    Dec(N);
  end;

  Result := FKnots[AIndex] + N * FKnots[M];
end;

function TBSpline2D.GetCtrlPoint(AIndex: Integer): TPoint2D;
var
  L: Integer;
begin
  L := System.Length(FKnots);

  while (AIndex >= L) do
    AIndex := AIndex - L;

  while (AIndex < 0) do
    AIndex := AIndex + L;

  Result := FCtrlPoints[AIndex];
end;





//-------------------------------------------------------------------------------------------------

function TBSpline2D.Evaluate(U: double; N: integer): TPoint2D;
var
  I, J, K: Integer;
  LValue: Float;
  LPnt: TPoint2D;  
  LPnts: TPoint2DArray;
  LVals1, LVals2: TFloatArray;
begin
  System.SetLength(LPnts, FDegree + 1);
  System.SetLength(LVals1, FDegree + 1);
  System.SetLength(LVals2, 2 * (FDegree + 1));

  for I := 0 to FDegree do
  begin
    LVals1[I] := 1.0;
    LPnts[I]  := GetCtrlPoint(N + I - FDegree);
  end;

  for I := 0 to 2 * FDegree + 1 do
    LVals2[I] := GetKnot(N - FDegree + I);

  for I := FDegree downto 1 do
  begin
    for J := 1 to I do
    begin
      LValue := (U - LVals2[FDegree - I + J]) / (LVals2[FDegree + J] - LVals2[FDegree - I + J]);
      LVals1[J - 1] := LVals1[J - 1] + (LVals1[J] - LVals1[J - 1]) * LValue;
      K := J - 1;

      LPnt.X := LPnts[J].X - LPnts[J - 1].X;
      LPnt.Y := LPnts[J].Y - LPnts[J - 1].Y;

      LPnt.X := LPnt.X * LValue;
      LPnt.Y := LPnt.Y * LValue;

      LPnts[K].X := LPnts[K].X + LPnt.X;
      LPnts[K].Y := LPnts[K].Y + LPnt.Y;
    end;
  end;

  Result.X := LPnts[0].X / LVals1[0];
  Result.Y := LPnts[0].Y / LVals1[0];
end;


function TBSpline2D.GetSamplePoints(): TPoint2DArray;
var
  I, M: Integer;
  LLast, LKnot, LKnot2, LGKnot, LDKnot: Float;
  LPntList: TPoint2DList;
begin
  Result := nil;
  if (System.Length(FCtrlPoints) < 2) then Exit; //=======>>>>

  LPntList := TPoint2DList.Create(300);
  try
    LLast := FKnots[High(FKnots)];


    if FClosed and (System.Length(FFittingPoints) > 0) then
    begin
      M := FDegree + 2;
      LKnot := FKnots[M];
    end
    else begin
      if FClosed then M := 3 else M := FDegree;
      LKnot := FKnots[M];
    end;

    while (LKnot < LLast) do
    begin
      LGKnot := GetKnot(M + 1);
      if (LLast < LGKnot) then
        LGKnot := LLast;

      LKnot2 := LKnot;
      LPntList.Add( Evaluate(LKnot2, M) );

      LDKnot := (LGKnot - LKnot2) / FPerSegment;

      for I := 1 to FPerSegment do
      begin
        LKnot2 := LKnot2 + LDKnot;
        LPntList.Add( Evaluate(LKnot2, M) );
      end;

      LKnot := LGKnot;
      Inc(M);
    end;

    Result := LPntList.ToArray();    
  finally
    LPntList.Free;
  end;
end;



class function TBSpline2D.CalculateFittingBSpline(AFittingPoints: TPoint2DArray; AClosed: Boolean): TBSpline2D;
var
  LCtrlPonts: TPoint2DArray;
  I, N, LCount, LLen: Integer;
  LNum1, LNum2, LNum3: Float;
  LKnots, LAlpha, LBeta, LGamma, LD: TFloatArray;
  LNums1, LNums2, LNums3, LNums4, LNums5: TFloatArray;
  LFittingPoints: TPoint2DArray;
begin
  LFittingPoints := AFittingPoints;
  if AClosed then
  begin
    N := System.Length(LFittingPoints);
    if IsEqual(LFittingPoints[0], LFittingPoints[N-1]) then
    begin
      System.SetLength(LFittingPoints, N + 2);
      LFittingPoints[N] := LFittingPoints[1];
      LFittingPoints[N+1] := LFittingPoints[2];
    end
    else begin
      System.SetLength(LFittingPoints, N + 3);
      LFittingPoints[N] := LFittingPoints[0];
      LFittingPoints[N+1] := LFittingPoints[1];
      LFittingPoints[N+2] := LFittingPoints[2];
    end;
  end;

  LCount := System.Length(LFittingPoints);
  LLen := (LCount + 2);

  LKnots := ArcLengthParameterization(LFittingPoints, 3);

  System.SetLength(LAlpha, LLen);
  System.SetLength(LBeta , LLen);
  System.SetLength(LGamma, LLen);

  LNum1 := (LKnots[4] - LKnots[3]);
  LNum2 := (LKnots[5] - LKnots[3]);
  LNum3 := (LNum1 + LNum2);
  LAlpha[1] := (-LNum2 / LNum3);
  LGamma[1] := (-LNum1 / LNum3);

  LBeta[0] := 1;
  LBeta[1] := 1;
  I := 2;

  while ((I < (LLen - 2))) do
  begin
    LNums1 := EvaluateBasis((I + 1), LKnots[(I + 2)], LKnots);
    LAlpha[I] := LNums1[1];
    LBeta[I] := LNums1[2];
    LGamma[I] := LNums1[3];
    Inc(I)
  end;

  LNum1 := (LKnots[LLen] - LKnots[(LLen - 1)]);
  LNum2 := (LKnots[LLen] - LKnots[(LLen - 2)]);
  LNum3 := (LNum1 + LNum2);
  LAlpha[(LLen - 2)] := (-LNum1 / LNum3);
  LGamma[(LLen - 2)] := (-LNum2 / LNum3);


  LBeta[(LLen - 2)] := 1;
  LBeta[(LLen - 1)] := 1;
  LUAnalysis(LAlpha, LBeta, LGamma, LNums2, LNums3);

  System.SetLength(LD, LLen);
  LD[0] := LFittingPoints[0].X;
  LD[1] := 0.0;

  I := 1;
  while ((I < (LCount - 1))) do
  begin
    LD[(I + 1)] := LFittingPoints[I].x;
    Inc(I)
  end;
  LD[(LLen - 2)] := 0.0;
  LD[(LLen - 1)] := LFittingPoints[(LCount - 1)].x;

  SolveLUSystem(LNums2, LNums3, LGamma, LD, LNums4);

  LD[0] := LFittingPoints[0].Y;
  LD[1] := 0.0;

  I := 1;
  while ((I < (LCount - 1))) do
  begin
    LD[(I + 1)] := LFittingPoints[I].y;
    Inc(I)
  end;

  LD[(LLen - 2)] := 0.0;
  LD[(LLen - 1)] := LFittingPoints[(LCount - 1)].y;

  SolveLUSystem(LNums2, LNums3, LGamma, LD, LNums5);

  System.SetLength(LCtrlPonts, LLen);
  N := 0;
  while ((N < LLen)) do
  begin
    LCtrlPonts[N] := Point2D(LNums4[N], LNums5[N]);
    Inc(N);
  end;

  Result := TBSpline2D.Create(LCtrlPonts, 8, 3, AClosed);
  Result.FKnots := LKnots;
  Result.FFittingPoints := AFittingPoints;
end;


class function TBSpline2D.GetInterpolatedCubicBSpline(AFittingPoints: TPoint2DArray; AClosed: Boolean; AResolution: Integer): TBSpline2D;
var
  I, J, L: Integer;
  LPoints: TPoint2DArray;
  LFittingPoints: TPoint2DArray;
begin
  LPoints := AFittingPoints;
    
  L := System.Length(LPoints);
    
  if AClosed and IsEqual(LPoints[0], LPoints[(L-1)], 1E-08) then
  begin
    System.SetLength(LPoints, L - 1);
    Dec(L)
  end;

  if (L < 3) then
  begin
    Result := nil;
    Exit; //=======>>>>>
  end;

  if (AResolution < 8) then AResolution := 8;

  System.SetLength(LFittingPoints, 1);
  LFittingPoints[0] := LPoints[0];

  I := 1;
  J := 0;
  while (I < System.Length(LPoints)) do
  begin
    if NotEqual(LFittingPoints[J], LPoints[I], 1E-08) then
    begin
      System.SetLength(LFittingPoints, J + 2);
      LFittingPoints[J + 1] := LPoints[I];

      Inc(J)
    end;

    Inc(I)
  end;

  if AClosed then
  begin
    System.SetLength(LFittingPoints, System.Length(LFittingPoints) + 1);
    LFittingPoints[High(LFittingPoints)] := LFittingPoints[0];
  end;

  Result := CalculateFittingBSpline(LFittingPoints, AClosed);
  Result.FPerSegment := AResolution;
end;





//==================================================================================================

function GetFittingBSplineSamplePoints(AFittingPoints: TPoint2DArray; ASegments: Integer; AClosed: Boolean;
                                       var AKnots: TFloatArray; var ACtrlPoints: TPoint2DArray): TPoint2DArray;
var
  LBSpline: TBSpline2D;
begin
  if System.Length(AFittingPoints) < 3 then
  begin
    Result := AFittingPoints;
    Exit; //=====>>>>
  end;

  LBSpline := TBSpline2D.GetInterpolatedCubicBSpline(AFittingPoints, AClosed, ASegments);
  try
    AKnots := LBSpline.FKnots;
    ACtrlPoints := LBSpline.FCtrlPoints;
    Result := LBSpline.GetSamplePoints();
  finally
    LBSpline.Free;
  end;
end;


function GetFittingBSplineSamplePoints(AFittingPoints: TPoint2DArray; ASegments: Integer; AClosed: Boolean): TPoint2DArray;
var
  LKnots: TFloatArray;
  LCtrlPoints: TPoint2DArray;
begin
  Result := GetFittingBSplineSamplePoints(AFittingPoints, ASegments, AClosed, LKnots, LCtrlPoints);
end;



//------------------------------------------------------------------------------------------------------------

function GetQuadraticSPlineSamplePoints(ACtrlPoints: TPoint2DArray; ASegments: Integer; AClosed: Boolean; AKnots: TFloatArray = nil): TPoint2DArray;
var
  LBSpline: TBSpline2D;
begin
  LBSpline := TBSpline2D.Create(ACtrlPoints, ASegments, 2, AClosed, AKnots);
  try
    Result := LBSpline.GetSamplePoints();
  finally
    LBSpline.Free;
  end;
end;

function GetCubicSPlineSamplePoints(ACtrlPoints: TPoint2DArray; ASegments: Integer; AClosed: Boolean; AKnots: TFloatArray = nil): TPoint2DArray;
var
  LBSpline: TBSpline2D;
begin
  LBSpline := TBSpline2D.Create(ACtrlPoints, ASegments, 3, AClosed, AKnots);
  try
    Result := LBSpline.GetSamplePoints();
  finally
    LBSpline.Free;
  end;
end;






//----------------------------------------------------------------------------------------------------------------
(*
procedure AddQuadraticBezierSPLineSegmentPoints(var ARePnts: TPoint2DArray; ASegments: Integer; P1, P2, P3: TPoint2D);
var
  I, L: Integer;
  LNum, LX, LY: Float;
begin
  I := 1;

  L := System.Length(ARePnts);
  System.SetLength(ARePnts, L + ASegments - 1);

  while (I < (ASegments - 1)) do
  begin
    LNum := (I / ASegments);
    LX := (((((P1.X - (2 * P2.X)) + P3.X) * LNum) * LNum) + (((2 * P2.X) - (2 * P1.X)) * LNum)) + P1.X;
    LY := (((((P1.Y - (2 * P2.Y)) + P3.Y) * LNum) * LNum) + (((2 * P2.Y) - (2 * P1.Y)) * LNum)) + P1.Y;

    ARePnts[L + I - 1] := Point2D(LX, LY);

    Inc(I)
  end;

  ARePnts[L + ASegments - 2] := P3;
end;

function GetQuadraticBezierSPlineSamplePoints(ACtrlPoints: TPoint2DArray; ASegments: Integer): TPoint2DArray;
var
  I, L: Integer;
  LRePnts: TPoint2DArray;
  LPoints: array[0..2] of TPoint2D;
begin
  LPoints[0] := ACtrlPoints[0];

  I := 1;
  while (I < System.Length(ACtrlPoints)) do
  begin
    LPoints[1] := ACtrlPoints[I];

    L := System.Length(LRePnts);
    System.SetLength(LRePnts, L + 1);
    LRePnts[L] := LPoints[0];

    if (I >= (System.Length(ACtrlPoints) - 1)) then
    begin
      Result := LRePnts;
      Exit;  //=========>>>>>>
    end;

    LPoints[2] := ACtrlPoints[(I + 1)];

    if (I + 1) <> (System.Length(ACtrlPoints) - 1) then
      LPoints[2] := MidPoint(LPoints[1], LPoints[2]);

    AddQuadraticBezierSPLineSegmentPoints(LRePnts, ASegments, LPoints[0], LPoints[1], LPoints[2]);
    
    LPoints[0] := LPoints[2];
    Inc(I)
  end;

  Result := LRePnts;
end;

function GetQuadraticBezierSPlineSamplePoints(ACtrlPoints: TPoint2DArray; ASegments: Integer; AClosed: Boolean): TPoint2DArray;
var
  I, L: Integer;
  LRePnts: TPoint2DArray;
  LPoints: array[0..2] of TPoint2D;
begin
  if not AClosed then
  begin
    Result := GetQuadraticBezierSPlineSamplePoints(ACtrlPoints, ASegments);
    Exit; //======>>>>>>
  end;

  LPoints[0] := ACtrlPoints[0];

  I := 1;
  while (I < System.Length(ACtrlPoints)) do
  begin
    LPoints[1] := ACtrlPoints[I];
    LPoints[0] := MidPoint(LPoints[0], LPoints[1]);

    L := System.Length(LRePnts);
    System.SetLength(LRePnts, L + 1);
    LRePnts[L] := LPoints[0];

    if I < (System.Length(ACtrlPoints) - 1) then
    begin
      LPoints[2] := ACtrlPoints[(I + 1)];
      LPoints[2] := MidPoint(LPoints[1], LPoints[2]);
    end
    else begin
      LPoints[1] := ACtrlPoints[System.Length(ACtrlPoints) - 1];
      LPoints[2] := ACtrlPoints[0];
      LPoints[2] := MidPoint(LPoints[1], LPoints[2]);
      AddQuadraticBezierSPLineSegmentPoints(LRePnts, ASegments, LPoints[0], LPoints[1], LPoints[2]);

      LPoints[0] := LPoints[2];
      LPoints[1] := ACtrlPoints[0];
      LPoints[2] := LRePnts[0];
      AddQuadraticBezierSPLineSegmentPoints(LRePnts, ASegments, LPoints[0], LPoints[1], LPoints[2]);

      Break;
    end;

    AddQuadraticBezierSPLineSegmentPoints(LRePnts, ASegments, LPoints[0], LPoints[1], LPoints[2]);
    LPoints[0] := LPoints[2];
    
    Inc(I)
  end;

  Result := LRePnts;
end;
*)



end.