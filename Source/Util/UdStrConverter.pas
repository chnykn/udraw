{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdStrConverter;

{$I UdGeoDefs.INC}

interface

uses
  UdTypes, UdGTypes;



  
function Point2DToStr(const AValue: TPoint2D): string;
function StrToPoint2D(const AValue: string): TPoint2D;

function Line2DToStr(const AValue: TLine2D): string;
function StrToLine2D(const AValue: string): TLine2D;

function Segment2DToStr(const AValue: TSegment2D): string;
function StrToSegment2D(const AValue: string): TSegment2D;

function Circle2DToStr(const AValue: TCircle2D): string;
function StrToCircle2D(const AValue: string): TCircle2D;

function Arc2DToStr(const AValue: TArc2D): string;
function StrToArc2D(const AValue: string): TArc2D;

function Ellipse2DToStr(const AValue: TEllipse2D): string;
function StrToEllipse2D(const AValue: string): TEllipse2D;

function Segarc2DToStr(const AValue: TSegarc2D): string;
function StrToSegarc2D(const AValue: string): TSegarc2D;


function Vertexes2DToStr(const AValue: TVertexes2D): string;
function StrToVertexes2D(const AValue: string): TVertexes2D;

function Spline2DToStr(const AValue: TSpline2D): string;
function StrToSpline2D(const AValue: string): TSpline2D;

function Curve2DToStr(const AValue: TCurve2D): string;
function StrToCurve2D(const AValue: string): TCurve2D;



function ArrayToStr(const AValue: TFloatArray): string;  overload;
function ArrayToStr(const AValue: TPoint2DArray): string;  overload;
function ArrayToStr(const AValue: TPoint2DArrays): string; overload;
function ArrayToStr(const AValue: TSegment2DArray): string; overload;
function ArrayToStr(const AValue: TSegarc2DArray): string; overload;
function ArrayToStr(const AValue: TCurve2DArray): string; overload;

function StrToArray(const AValue: string; var Return: TFloatArray): Boolean;  overload;
function StrToArray(const AValue: string; var Return: TPoint2DArray): Boolean;  overload;
function StrToArray(const AValue: string; var Return: TPoint2DArrays): Boolean; overload;
function StrToArray(const AValue: string; var Return: TSegment2DArray): Boolean; overload;
function StrToArray(const AValue: string; var Return: TSegarc2DArray): Boolean; overload;
function StrToArray(const AValue: string; var Return: TCurve2DArray): Boolean; overload;


  

implementation

uses
  SysUtils, UdUtils;



function Point2DToStr(const AValue: TPoint2D): string;
begin
  Result := '(' + FloatToStr(AValue.X) + ',' +  FloatToStr(AValue.Y) + ')';
end;

function StrToPoint2D(const AValue: string): TPoint2D;
var
  S: string;
  N: Integer;
begin
  Result.X := 0;
  Result.Y := 0;

  S := Trim(AValue);
  if S = '' then Exit;

  Delete(S, 1, 1);
  Delete(S, System.Length(S), 1);

  N := Pos(',', S);

  Result.X := StrToFloat(Trim(Copy(S, 1, N - 1)));
  Result.Y := StrToFloat(Trim(Copy(S, N + 1, System.Length(S))));
end;



function Line2DToStr(const AValue: TLine2D): string;
begin
  Result := '(' + Point2DToStr(AValue.P1) + ',' + Point2DToStr(AValue.P2) + ')';
end;

function StrToLine2D(const AValue: string): TLine2D;
var
  S: string;
  N: Integer;
begin
  Result.P1.X := 0;
  Result.P1.Y := 0;

  Result.P2.X := 0;
  Result.P2.Y := 0;

  S := Trim(AValue);
  if S = '' then Exit;

  Delete(S, 1, 1);
  Delete(S, System.Length(S), 1);

  N := Pos(',', S);

  Result.P1 := StrToPoint2D(Trim(Copy(S, 1, N - 1)));
  Result.P2 := StrToPoint2D(Trim(Copy(S, N + 1, System.Length(S))));
end;



function Segment2DToStr(const AValue: TSegment2D): string;
begin
  Result := '(' + Point2DToStr(AValue.P1) + ',' + Point2DToStr(AValue.P2) + ')';
end;

function StrToSegment2D(const AValue: string): TSegment2D;
var
  S: string;
  N: Integer;
begin
  Result.P1.X := 0;
  Result.P1.Y := 0;

  Result.P2.X := 0;
  Result.P2.Y := 0;

  S := Trim(AValue);
  if S = '' then Exit;

  Delete(S, 1, 1);
  Delete(S, System.Length(S), 1);

  N := Pos('),', S);

  Result.P1 := StrToPoint2D(Trim(Copy(S, 1, N)));
  Result.P2 := StrToPoint2D(Trim(Copy(S, N + 2, System.Length(S))));
end;



function Circle2DToStr(const AValue: TCircle2D): string;
begin
  Result := '(' +  Point2DToStr(AValue.Cen) + ',' +
                   FloatToStr(AValue.R) +

             ')';
end;

function StrToCircle2D(const AValue: string): TCircle2D;
var
  S: string;
  N: Integer;
begin
  Result.R := 0.0;
  Result.Cen.X := 0;
  Result.Cen.Y := 0;

  S := Trim(AValue);
  if S = '' then Exit;

  Delete(S, 1, 1);
  Delete(S, System.Length(S), 1);


  N := Pos('),', S);
  if N > 0 then Result.Cen := StrToPoint2D(Trim(Copy(S, 1, N))) else Exit;

  Delete(S, 1, N + 1);

  N := Pos(',', S);
  if N > 0 then Result.R := StrToFloat(Trim(Copy(S, 1, N - 1))) else Exit;
end;


function Arc2DToStr(const AValue: TArc2D): string;
begin
  Result := '(' + Point2DToStr(AValue.Cen) + ',' +
                  FloatToStr(AValue.R) + ',' +
                  FloatToStr(AValue.Ang1) + ',' +
                  FloatToStr(AValue.Ang2) + ',' +
                  BoolToStr(AValue.IsCW, True) + ',' +
                  IntToStr(Ord(AValue.Kind)) +
             ')';
end;

function StrToArc2D(const AValue: string): TArc2D;
var
  S: string;
  N: Integer;
begin
  Result.R := 0.0;
  Result.Cen.X := 0;
  Result.Cen.Y := 0;
  Result.Ang1 := 0;
  Result.Ang2 := 0;
  Result.IsCW := False;
  Result.Kind := akCurve;

  S := Trim(AValue);
  if S = '' then Exit;

  Delete(S, 1, 1);
  Delete(S, System.Length(S), 1);


  N := Pos('),', S);
  if N > 0 then Result.Cen := StrToPoint2D(Trim(Copy(S, 1, N))) else Exit;

  Delete(S, 1, N + 1);


  N := Pos(',', S);
  if N > 0 then Result.R := StrToFloat(Trim(Copy(S, 1, N - 1))) else Exit;

  Delete(S, 1, N);

  N := Pos(',', S);
  if N > 0 then Result.Ang1 := StrToFloat(Trim(Copy(S, 1, N - 1))) else Exit;

  Delete(S, 1, N);

  N := Pos(',', S);
  if N > 0 then Result.Ang2 := StrToFloat(Trim(Copy(S, 1, N - 1))) else Exit;


  Delete(S, 1, N);
  
  N := Pos(',', S);
  Result.IsCW := StrToBoolDef(Copy(S, 1, N - 1), False);

  Delete(S, 1, N);
  S := Trim(S);
  Result.Kind := TArcKind(StrToIntDef(S, 0));
end;


function Ellipse2DToStr(const AValue: TEllipse2D): string;
begin
  Result := '(' + Point2DToStr(AValue.Cen) + ',' +
                  FloatToStr(AValue.Rx) + ',' +
                  FloatToStr(AValue.Ry) + ',' +
                  FloatToStr(AValue.Ang1) + ',' +
                  FloatToStr(AValue.Ang2) + ',' +
                  BoolToStr(AValue.IsCW, True)  + ',' +
                  IntToStr(Ord(AValue.Kind))  +
             ')';
end;

function StrToEllipse2D(const AValue: string): TEllipse2D;
var
  S: string;
  N: Integer;
begin
  Result.Rx := 0.0;
  Result.Ry := 0.0;
  Result.Cen.X := 0;
  Result.Cen.Y := 0;
  Result.Ang1 := 0;
  Result.Ang2 := 0;
  Result.IsCW := False;

  S := Trim(AValue);
  if S = '' then Exit;

  Delete(S, 1, 1);
  Delete(S, System.Length(S), 1);


  N := Pos('),', S);
  if N > 0 then Result.Cen := StrToPoint2D(Trim(Copy(S, 1, N))) else Exit;

  Delete(S, 1, N + 1);


  N := Pos(',', S);
  if N > 0 then Result.Rx := StrToFloat(Trim(Copy(S, 1, N - 1))) else Exit;

  Delete(S, 1, N);


  N := Pos(',', S);
  if N > 0 then Result.Ry := StrToFloat(Trim(Copy(S, 1, N - 1))) else Exit;

  Delete(S, 1, N);


  N := Pos(',', S);
  if N > 0 then Result.Ang1 := StrToFloat(Trim(Copy(S, 1, N - 1))) else Exit;

  Delete(S, 1, N);

  N := Pos(',', S);
  if N > 0 then Result.Ang2 := StrToFloat(Trim(Copy(S, 1, N - 1))) else Exit;

  Delete(S, 1, N);
  
  N := Pos(',', S);
  Result.IsCW := StrToBoolDef(Copy(S, 1, N - 1), False);

  Delete(S, 1, N);
  S := Trim(S);
  Result.Kind := TArcKind(StrToIntDef(S, 0));
end;



function Segarc2DToStr(const AValue: TSegarc2D): string;
begin
  Result := '(' +
               BoolToStr(AValue.IsArc, True) + ',' +
               Segment2DToStr(AValue.Seg) + ',' +
               Arc2DToStr(AValue.Arc) +
             ')';
end;

function StrToSegarc2D(const AValue: string): TSegarc2D;
var
  N: Integer;
  S: string;
  S1, S2: string;
begin
  Result.IsArc := False;
  Result.Seg.P1.X := 0;  Result.Seg.P1.Y := 0; Result.Seg.P2.X := 0;  Result.Seg.P2.Y := 0;
  Result.Arc.R := 0.0;  Result.Arc.Cen.X := 0; Result.Arc.Cen.Y := 0; Result.Arc.Ang1 := 0; Result.Arc.Ang2 := 0; Result.Arc.IsCW := False;


  S := Trim(AValue);
  if S = '' then Exit;

  Delete(S, 1, 1);
  Delete(S, System.Length(S), 1);


  N := Pos(',', S);
  S1 := Copy(S, 1, N-1);

  Delete(S, 1, N);

  S := Trim(S);
  N := Pos(')),', S);
  S2 := Copy(S, 1, N+1);

  Delete(S, 1, N+2);
  S := Trim(S);


  if N > 0 then
  begin
    Result.IsArc := StrToBool(S1);
    Result.Seg := StrToSegment2D(S2);
    Result.Arc := StrToArc2D(S);
  end;
end;









function Vertexes2DToStr(const AValue: TVertexes2D): string;
var
  I, L: Integer;
begin
  Result := '';

  L := System.Length(AValue);
  if L <= 0 then Exit;

  Result := '(';
  for I := 0 to L - 1 do
  begin
    Result := Result + '(' + FloatToStr(AValue[I].Point.X) + ',' +
                             FloatToStr(AValue[I].Point.Y) + ',' +
                             FloatToStr(AValue[I].Bulge) + ')';
    if I <> L - 1 then Result := Result + ',';
  end;
  Result := Result + ')';
end;

function StrToVertexes2D(const AValue: string): TVertexes2D;
var
  S, V, X, Y, B: string;
  I, N, N1, N2, M: Integer;
begin
  Result := nil;

  S := Trim(AValue);
  if S = '' then Exit;

  if S[1] = '(' then Delete(S, 1, 1);
  if S[System.Length(S)] = ')' then Delete(S, System.Length(S), 1);

  I := 0;

  N1 := Pos('(', S);
  N2 := Pos(')', S);

  V := Trim(Copy(S, N1 + 1, N2 - N1 - 1));
  N := Pos(',', V);

  while (N1 > 0) and (N2 > 0) and (N2 > N1) and (N > 0) do
  begin
    X := Trim(Copy(V, 1, N - 1));
    Y := Trim(Copy(V, N + 1, System.Length(V)));

    M := Pos(',', Y);
    if M > 0 then
    begin
      B := Trim(Copy(Y, M + 1, System.Length(Y)));
      Delete(Y, M, System.Length(Y));
    end
    else
      B := '';
    

    if IsNum(X) and IsNum(Y) then
    begin
      System.SetLength(Result, I + 1);

      Result[I].Point.X := StrToFloat(X);
      Result[I].Point.Y := StrToFloat(Y);

      if IsNum(B) then
        Result[I].Bulge := StrToFloat(B)
      else
        Result[I].Bulge := 0; 

      I := I + 1;
    end;

    Delete(S, 1, N2);

    N1 := Pos('(', S);
    N2 := Pos(')', S);

    V := Trim(Copy(S, N1 + 1, N2 - N1 - 1));
    N := Pos(',', V);
  end;
end;


function Spline2DToStr(const AValue: TSpline2D): string;
begin
  Result := '(' +
    IntToStr(AValue.Degree) + ',' +
    ArrayToStr(AValue.Knots) + ',' +
    ArrayToStr(AValue.CtlPnts) + ')';
end;

function StrToSpline2D(const AValue: string): TSpline2D;
var
  S, V: string;
  N: Integer;
begin
  S := Trim(AValue);
  if S = '' then Exit;

  if S[1] = '(' then Delete(S, 1, 1);
  if S[System.Length(S)] = ')' then Delete(S, System.Length(S), 1);

  N := Pos(',', S);
  V := Trim(Copy(S, 1, N - 1));
  Result.Degree := StrToInt(V);

  Delete(S, 1, N);
  
  N := Pos('),', S);
  V := Trim(Copy(S, 1, N));
  StrToArray(V, Result.Knots);
  
  V := Trim(S);
  StrToArray(V, Result.CtlPnts);
end;






function Curve2DToStr(const AValue: TCurve2D): string;
begin
  Result := '(' +  IntToStr(Ord(AValue.Kind)) + ',';
  case AValue.Kind of
    ckPolyline: Result := Result + Vertexes2DToStr(PVertexes2D(AValue.Data)^);
    ckLine    : Result := Result + Segment2DToStr(PSegment2D(AValue.Data)^);
    ckArc     : Result := Result + Arc2DToStr(PArc2D(AValue.Data)^);
    ckEllipse : Result := Result + Ellipse2DToStr(PEllipse2D(AValue.Data)^);
    ckSpline  : Result := Result + Spline2DToStr(PSpline2D(AValue.Data)^);
  end;
  Result := Result + ')';
end;

function StrToCurve2D(const AValue: string): TCurve2D;
var
  S: string;
  S1: string;
  N: Integer;
begin
  S := Trim(AValue);
  if S = '' then Exit;

  Delete(S, 1, 1);
  Delete(S, System.Length(S), 1);

  N := Pos(',', S);
  S1 := Copy(S, 1, N-1);

  Result.Kind := TCurveKind(StrToInt(S1));


  Delete(S, 1, N);

  S := Trim(S);
  if S[1] = ',' then
  begin
    Delete(S, 1, 1);
    S := Trim(S);
  end;

  case Result.Kind of
    ckPolyline: begin Result.Data := New(PVertexes2D); PVertexes2D(Result.Data)^ := StrToVertexes2D(S); end;
    ckLine    : begin Result.Data := New(PSegment2D);  PSegment2D(Result.Data)^  := StrToSegment2D(S); end;
    ckArc     : begin Result.Data := New(PArc2D);      PArc2D(Result.Data)^      := StrToArc2D(S); end;
    ckEllipse : begin Result.Data := New(PEllipse2D);  PEllipse2D(Result.Data)^  := StrToEllipse2D(S); end;
    ckSpline  : begin Result.Data := New(PSpline2D);   PSpline2D(Result.Data)^   := StrToSpline2D(S); end;
  end;

end;










//-------------------------------------------------------------------------------

function ArrayToStr(const AValue: TFloatArray): string;
var
  I, L: Integer;
begin
  Result := '';

  L := System.Length(AValue);
  if L <= 0 then Exit;

  Result := '(';
  for I := 0 to L - 1 do
  begin
    Result := Result + FloatToStr(AValue[I]);
    if I <> L - 1 then Result := Result + ',';
  end;
  Result := Result + ')';
end;

function ArrayToStr(const AValue: TPoint2DArray): string;
var
  I, L: Integer;
begin
  Result := '';

  L := System.Length(AValue);
  if L <= 0 then Exit;

  Result := '(';
  for I := 0 to L - 1 do
  begin
    Result := Result + '(' + FloatToStr(AValue[I].X) + ',' + FloatToStr(AValue[I].Y) + ')';
    if I <> L - 1 then Result := Result + ',';
  end;
  Result := Result + ')';
end;

function ArrayToStr(const AValue: TPoint2DArrays): string;
var
  I, L: Integer;
begin
  Result := '';

  L := System.Length(AValue);
  if L <= 0 then Exit;

  Result := '(';
  for I := 0 to L - 1 do
  begin
    Result := Result + ArrayToStr(AValue[I]);
    if L <> L - 1 then Result := Result + ',';
  end;
  Result := Result + ')';
end;


function ArrayToStr(const AValue: TSegment2DArray): string;
var
  I, L: Integer;
begin
  Result := '';

  L := System.Length(AValue);
  if L <= 0 then Exit;

  Result := '(';
  for I := 0 to L - 1 do
  begin
    Result := Result + Segment2DToStr(AValue[I]);
    if I <> L - 1 then Result := Result + ',';
  end;
  Result := Result + ')';
end;

function ArrayToStr(const AValue: TSegarc2DArray): string;
var
  I, L: Integer;
begin
  Result := '';

  L := System.Length(AValue);
  if L <= 0 then Exit;

  Result := '(';
  for I := 0 to L - 1 do
  begin
    Result := Result + Segarc2DToStr(AValue[I]);
    if I <> L - 1 then Result := Result + ',';
  end;
  Result := Result + ')';
end;


function ArrayToStr(const AValue: TCurve2DArray): string;
var
  I, L: Integer;
begin
  Result := '';

  L := System.Length(AValue);
  if L <= 0 then Exit;

  Result := '(';
  for I := 0 to L - 1 do
  begin
    Result := Result + Curve2DToStr(AValue[I]);
    if I <> L - 1 then Result := Result + ';';
  end;
  Result := Result + ')';
end;





function StrToArray(const AValue: string; var Return: TFloatArray): Boolean;
var
  S, V: string;
  I, N: Integer;
begin
  Result := False;
  Return := nil;

  S := Trim(AValue);
  if S = '' then Exit;

  if S[1] = '(' then Delete(S, 1, 1);
  if S[System.Length(S)] = ')' then Delete(S, System.Length(S), 1);

  I := 0;


  N := Pos(',', S);

  while (N > 0) do
  begin
    V := Trim(Copy(S, 1, N - 1));

    if IsNum(V) then
    begin
      System.SetLength(Return, I + 1);
      Return[I]:= StrToFloat(V);

      I := I + 1;
    end;

    Delete(S, 1, N);
    N := Pos(',', S);
  end;

  V := Trim(S);
  if IsNum(V) then
  begin
    System.SetLength(Return, I + 1);
    Return[I]:= StrToFloat(V);
  end;
      
  Result := System.Length(Return) > 0;
end;

function StrToArray(const AValue: string; var Return: TPoint2DArray): Boolean;
var
  S, V, X, Y: string;
  I, N, N1, N2, M: Integer;
begin
  Result := False;
  Return := nil;

  S := Trim(AValue);
  if S = '' then Exit;

  if S[1] = '(' then Delete(S, 1, 1);
  if S[System.Length(S)] = ')' then Delete(S, System.Length(S), 1);

  I := 0;

  N1 := Pos('(', S);
  N2 := Pos(')', S);

  V := Trim(Copy(S, N1 + 1, N2 - N1 - 1));
  N := Pos(',', V);

  while (N1 > 0) and (N2 > 0) and (N2 > N1) and (N > 0) do
  begin
    X := Trim(Copy(V, 1, N - 1));
    Y := Trim(Copy(V, N + 1, System.Length(V)));

    M := Pos(',', Y);
    if M > 0 then Delete(Y, M, System.Length(Y));
    

    if IsNum(X) and IsNum(Y) then
    begin
      System.SetLength(Return, I + 1);

      Return[I].X := StrToFloat(X);
      Return[I].Y := StrToFloat(Y);

      I := I + 1;
    end;

    Delete(S, 1, N2);

    N1 := Pos('(', S);
    N2 := Pos(')', S);

    V := Trim(Copy(S, N1 + 1, N2 - N1 - 1));
    N := Pos(',', V);
  end;

  Result := System.Length(Return) > 0;
end;

function StrToArray(const AValue: string; var Return: TPoint2DArrays): Boolean;
var
  S, V: string;
  L, N1, N2: Integer;
begin
  Result := False;
  Return := nil;

  S := Trim(AValue);
  if S = '' then Exit;

  if S[1] = '(' then Delete(S, 1, 1);
  if S[System.Length(S)] = ')' then Delete(S, System.Length(S), 1);

  L := 0;

  N1 := Pos('((', S);
  N2 := Pos('))', S);

  V := Trim(Copy(S, N1, N2 - N1 + 2));

  while (N1 > 0) and (N2 > 0) and (N2 > N1) do
  begin
    System.SetLength(Return, L + 1);
    StrToArray(V, Return[L]);
    L := L + 1;

    Delete(S, N1, N2 - N1 + 2);

    N1 := Pos('((', S);
    N2 := Pos('))', S);

    V := Trim(Copy(S, N1, N2 - N1 + 2));
  end;

  Result := System.Length(Return) > 0;
end;


function StrToArray(const AValue: string; var Return: TSegment2DArray): Boolean;
var
  S, V: string;
  L, N1, N2: Integer;
begin
  Result := False;
  Return := nil;

  S := Trim(AValue);
  if S = '' then Exit;

  if S[1] = '(' then Delete(S, 1, 1);
  if S[System.Length(S)] = ')' then Delete(S, System.Length(S), 1);

  L := 0;

  N1 := Pos('((', S);
  N2 := Pos('))', S);

  V := Trim(Copy(S, N1, N2 - N1 + 2));

  while (N1 > 0) and (N2 > 0) and (N2 > N1) do
  begin
    System.SetLength(Return, L + 1);
    Return[L] := StrToSegment2D(V);
    L := L + 1;

    Delete(S, N1, N2 - N1 + 2);

    N1 := Pos('((', S);
    N2 := Pos('))', S);

    V := Trim(Copy(S, N1, N2 - N1 + 2));
  end;

  Result := System.Length(Return) > 0;
end;



function _GetSegarcStrSepPos(var S: string): Integer;
var
  I, N: Integer;
begin
  Result := -1;
  N := 0;
  for I := 1 to System.Length(S) do
  begin
    if S[I] = ')' then Inc(N);
    if N = 6 then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function StrToArray(const AValue: string; var Return: TSegarc2DArray): Boolean;
var
  S, V: string;
  L, N: Integer;
begin
  Result := False;
  Return := nil;

  S := Trim(AValue);
  if S = '' then Exit;

  if S[1] = '(' then Delete(S, 1, 1);
  if S[System.Length(S)] = ')' then Delete(S, System.Length(S), 1);

  L := 0;

  N := _GetSegarcStrSepPos(S);
  while (N > 0) do
  begin
    V := Trim(Copy(S, 1, N));

    System.SetLength(Return, L + 1);
    Return[L] := StrToSegarc2D(V);
    L := L + 1;

    Delete(S, 1, N + 1);
    N := _GetSegarcStrSepPos(S);
  end;

  Result := System.Length(Return) > 0;
end;


function StrToArray(const AValue: string; var Return: TCurve2DArray): Boolean;
var
  S, V: string;
  L, N: Integer;
begin
  Result := False;
  Return := nil;

  S := Trim(AValue);
  if S = '' then Exit;

  if S[1] = '(' then Delete(S, 1, 1);
  if S[System.Length(S)] = ')' then Delete(S, System.Length(S), 1);

  L := 0;

  N := Pos(';', S);
  while (N > 0) do
  begin
    V := Trim(Copy(S, 1, N-1));

    System.SetLength(Return, L + 1);
    Return[L] := StrToCurve2D(V);
    L := L + 1;

    Delete(S, 1, N);
    N := Pos(';', S);
  end;

  if Trim(S) <> '' then
  begin
    System.SetLength(Return, L + 1);
    Return[L] := StrToCurve2D(Trim(S));
  end;

  Result := System.Length(Return) > 0;
end;




//-------------------------------------------------------------------------------------------


(*
procedure AssignEntityArray(var ADest: TAxEntityArray; const ASource: TAxEntityArray);
var
  I: Integer;
begin
  System.SetLength(ADest, System.Length(ASource));
  for I := Low(ASource) to High(ASource) do
    ADest[I] := ASource[I];
end;

procedure AppendEntityArray(var ADest: TAxEntityArray; const ASource: TAxEntityArray);
var
  I: Integer;
  LD, LS: Integer;
begin
  LD := System.Length(ADest);
  LS := System.Length(ASource);

  if LD <= 0 then
  begin
    ADest := ASource;
  end
  else
  begin
    System.SetLength(ADest, LD + LS);
    for I := 0 to LS - 1 do
      ADest[LD + I] := ASource[I];
  end;
end;

procedure RemoveEntityArray(var ADest: TAxEntityArray; AIndex: Integer);
var
  L, N: Integer;
begin
  L := System.Length(ADest);
  if L <= 0 then Exit;

  N := AIndex;
  if N < 0 then N := N + L;
  if (N < 0) or (N >= L) then Exit;

  System.Move(ADest[N + 1], ADest[N], (L - N) * SizeOf(TAxEntity));
  System.SetLength(ADest, L - 1);
end;

procedure InsertdEntityArray(var ADest: TAxEntityArray; AIndex: Integer; AValue: TAxEntity);
var
  L, N: Integer;
begin
  L := System.Length(ADest);

  N := AIndex;
  if N < 0 then N := N + L;
  if (N < 0) or (N > L) then Exit;

  System.SetLength(ADest, L + 1);

  if L <> N then
    System.Move(ADest[N], ADest[N + 1], (L - N) * SizeOf(TAxEntity));

  ADest[N] := AValue;
end;




*)





end.