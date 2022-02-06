unit UdArrays;


interface

uses
  UdGTypes;//, UdEntity;

procedure AssignArray(var ADest: TPoint2DArray; const ASource: TPoint2DArray); overload;
procedure AssignArray(var ADest: TLine2DArray; const ASource: TLine2DArray); overload;
procedure AssignArray(var ADest: TSegment2DArray; const ASource: TSegment2DArray); overload;
procedure AssignArray(var ADest: TPolygon2DArray; const ASource: TPolygon2DArray); overload;
procedure AssignArray(var ADest: TSegarc2DArray; const ASource: TSegarc2DArray); overload;

procedure RemoveArray(var ADest: TPoint2DArray; AIdx: Integer); overload;
procedure RemoveArray(var ADest: TLine2DArray; AIdx: Integer); overload;
procedure RemoveArray(var ADest: TSegment2DArray; AIdx: Integer); overload;
procedure RemoveArray(var ADest: TPolygon2DArray; AIdx: Integer); overload;
procedure RemoveArray(var ADest: TSegarc2DArray; AIdx: Integer); overload;

procedure InsertArray(var ADest: TPoint2DArray; AIdx: Integer; AValue: TPoint2D); overload;
procedure InsertArray(var ADest: TLine2DArray; AIdx: Integer; AValue: TLine2D); overload;
procedure InsertArray(var ADest: TSegment2DArray; AIdx: Integer; AValue: TSegment2D); overload;
procedure InsertArray(var ADest: TPolygon2DArray; AIdx: Integer; AValue: TPolygon2D); overload;
procedure InsertArray(var ADest: TSegarc2DArray; AIdx: Integer; AValue: TSegarc2D); overload;

function AppendArray(var ADest: TPoint2DArray; const R: TPoint2D): Integer; overload;
function AppendArray(var ADest: TLine2DArray; const R: TLine2D): Integer; overload;
function AppendArray(var ADest: TSegment2DArray; const R: TSegment2D): Integer; overload;
function AppendArray(var ADest: TPolygon2DArray; const R: TPolygon2D): Integer; overload;
function AppendArray(var ADest: TSegarc2DArray; const R: TSegarc2D): Integer; overload;

function AppendArray(var ADest: TPoint2DArray; const ASource: TPoint2DArray): Integer; overload;
function AppendArray(var ADest: TLine2DArray; const ASource: TLine2DArray): Integer; overload;
function AppendArray(var ADest: TSegment2DArray; const ASource: TSegment2DArray): Integer; overload;
function AppendArray(var ADest: TPolygon2DArray; const ASource: TPolygon2DArray): Integer; overload;
function AppendArray(var ADest: TSegarc2DArray; const ASource: TSegarc2DArray): Integer; overload;



//----------------------------------------------------------------

//procedure AssignEntityArray(var ADest: TAxEntityArray; const ASource: TAxEntityArray);
//procedure AppendEntityArray(var ADest: TAxEntityArray; const ASource: TAxEntityArray);
//procedure RemoveEntityArray(var ADest: TAxEntityArray; AIndex: Integer);
//procedure InsertdEntityArray(var ADest: TAxEntityArray; AIndex: Integer; AValue: TAxEntity);


implementation

uses
  SysUtils;



function IsNum(Str: string): Boolean;
var
  I: Float;
  E: Longint;
begin
  Val(Str, I, E);
  Result := E = 0;
  E := Round(I); //void hint
end;



//-------------------------------------------------------------------------------

procedure AssignArray(var ADest: TPoint2DArray; const ASource: TPoint2DArray);
var
  I: Integer;
begin
  System.SetLength(ADest, System.Length(ASource));
  for I := Low(ASource) to High(ASource) do
    ADest[I] := ASource[I];
end;


procedure AssignArray(var ADest: TLine2DArray; const ASource: TLine2DArray);
var
  I: Integer;
begin
  System.SetLength(ADest, System.Length(ASource));
  for I := Low(ASource) to High(ASource) do
    ADest[I] := ASource[I];
end;

procedure AssignArray(var ADest: TSegment2DArray; const ASource: TSegment2DArray);
var
  I: Integer;
begin
  System.SetLength(ADest, System.Length(ASource));
  for I := Low(ASource) to High(ASource) do
    ADest[I] := ASource[I];
end;

procedure AssignArray(var ADest: TPolygon2DArray; const ASource: TPolygon2DArray);
var
  I: Integer;
begin
  System.SetLength(ADest, System.Length(ASource));
  for I := Low(ASource) to High(ASource) do
    ADest[I] := ASource[I];
end;

procedure AssignArray(var ADest: TSegarc2DArray; const ASource: TSegarc2DArray);
var
  I: Integer;
begin
  System.SetLength(ADest, System.Length(ASource));
  for I := Low(ASource) to High(ASource) do
    ADest[I] := ASource[I];
end;




//-------------------------------------------------------------------------------

procedure RemoveArray(var ADest: TPoint2DArray; AIdx: Integer);
var
  L, N: Integer;
begin
  L := System.Length(ADest);
  if L <= 0 then Exit;

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N >= L) then Exit;

  System.Move(ADest[N + 1], ADest[N], (L - N) * SizeOf(TPoint2D));
  System.SetLength(ADest, L - 1);
end;

procedure RemoveArray(var ADest: TLine2DArray; AIdx: Integer);
var
  L, N: Integer;
begin
  L := System.Length(ADest);
  if L <= 0 then Exit;

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N >= L) then Exit;

  System.Move(ADest[N + 1], ADest[N], (L - N) * SizeOf(TLine2D));
  System.SetLength(ADest, L - 1);
end;

procedure RemoveArray(var ADest: TSegment2DArray; AIdx: Integer);
var
  L, N: Integer;
begin
  L := System.Length(ADest);
  if L <= 0 then Exit;

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N >= L) then Exit;

  System.Move(ADest[N + 1], ADest[N], (L - N) * SizeOf(TSegment2D));
  System.SetLength(ADest, L - 1);
end;

procedure RemoveArray(var ADest: TPolygon2DArray; AIdx: Integer);
var
  L, N: Integer;
begin
  L := System.Length(ADest);
  if L <= 0 then Exit;

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N >= L) then Exit;

  System.Move(ADest[N + 1], ADest[N], (L - N) * SizeOf(TPolygon2D));
  System.SetLength(ADest, L - 1);
end;

procedure RemoveArray(var ADest: TSegarc2DArray; AIdx: Integer);
var
  L, N: Integer;
begin
  L := System.Length(ADest);
  if L <= 0 then Exit;

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N >= L) then Exit;

  System.Move(ADest[N + 1], ADest[N], (L - N) * SizeOf(TSegarc2D));
  System.SetLength(ADest, L - 1);
end;





//-------------------------------------------------------------------------------


procedure InsertArray(var ADest: TPoint2DArray; AIdx: Integer; AValue: TPoint2D);
var
  L, N: Integer;
begin
  L := System.Length(ADest);

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N > L) then Exit;

  System.SetLength(ADest, L + 1);

  if L <> N then
    System.Move(ADest[N], ADest[N + 1], (L - N) * SizeOf(TPoint2D));

  ADest[N] := AValue;
end;

procedure InsertArray(var ADest: TLine2DArray; AIdx: Integer; AValue: TLine2D);
var
  L, N: Integer;
begin
  L := System.Length(ADest);

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N > L) then Exit;

  System.SetLength(ADest, L + 1);

  if L <> N then
    System.Move(ADest[N], ADest[N + 1], (L - N) * SizeOf(TLine2D));

  ADest[N] := AValue;
end;

procedure InsertArray(var ADest: TSegment2DArray; AIdx: Integer; AValue: TSegment2D);
var
  L, N: Integer;
begin
  L := System.Length(ADest);

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N > L) then Exit;

  System.SetLength(ADest, L + 1);

  if L <> N then
    System.Move(ADest[N], ADest[N + 1], (L - N) * SizeOf(TSegment2D));

  ADest[N] := AValue;
end;

procedure InsertArray(var ADest: TPolygon2DArray; AIdx: Integer; AValue: TPolygon2D);
var
  L, N: Integer;
begin
  L := System.Length(ADest);

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N > L) then Exit;

  System.SetLength(ADest, L + 1);

  if L <> N then
    System.Move(ADest[N], ADest[N + 1], (L - N) * SizeOf(TPolygon2D));

  ADest[N] := AValue;
end;


procedure InsertArray(var ADest: TSegarc2DArray; AIdx: Integer; AValue: TSegarc2D);
var
  L, N: Integer;
begin
  L := System.Length(ADest);

  N := AIdx;
  if N < 0 then N := N + L;
  if (N < 0) or (N > L) then Exit;

  System.SetLength(ADest, L + 1);

  if L <> N then
    System.Move(ADest[N], ADest[N + 1], (L - N) * SizeOf(TSegarc2D));

  ADest[N] := AValue;
end;




//-------------------------------------------------------------------------------

function AppendArray(var ADest: TPoint2DArray; const R: TPoint2D): Integer;
begin
  Result := System.Length(ADest) + 1;
  System.SetLength(ADest, Result);
  ADest[Result - 1] := R;
end;

function AppendArray(var ADest: TLine2DArray; const R: TLine2D): Integer;
begin
  Result := System.Length(ADest) + 1;
  System.SetLength(ADest, Result);
  ADest[Result - 1] := R;
end;

function AppendArray(var ADest: TSegment2DArray; const R: TSegment2D): Integer;
begin
  Result := System.Length(ADest) + 1;
  System.SetLength(ADest, Result);
  ADest[Result - 1] := R;
end;

function AppendArray(var ADest: TPolygon2DArray; const R: TPolygon2D): Integer;
begin
  Result := System.Length(ADest) + 1;
  System.SetLength(ADest, Result);
  ADest[Result - 1] := R;
end;

function AppendArray(var ADest: TSegarc2DArray; const R: TSegarc2D): Integer;
begin
  Result := System.Length(ADest) + 1;
  System.SetLength(ADest, Result);
  ADest[Result - 1] := R;
end;




//-------------------------------------------------------------------------------


function AppendArray(var ADest: TPoint2DArray; const ASource: TPoint2DArray): Integer;
var
  L: Integer;
begin
  Result := System.Length(ADest);
  L := System.Length(ASource);
  if L > 0 then
  begin
    System.SetLength(ADest, Result + L);
    Move(ASource[0], ADest[Result], Sizeof(TPoint2D) * L);
    Result := Result + L;
  end;
end;

function AppendArray(var ADest: TLine2DArray; const ASource: TLine2DArray): Integer;
var
  L: Integer;
begin
  Result := System.Length(ADest);
  L := System.Length(ASource);
  if L > 0 then
  begin
    System.SetLength(ADest, Result + L);
    Move(ASource[0], ADest[Result], Sizeof(TLine2D) * L);
    Result := Result + L;
  end;
end;

function AppendArray(var ADest: TSegment2DArray; const ASource: TSegment2DArray): Integer;
var
  L: Integer;
begin
  Result := System.Length(ADest);
  L := System.Length(ASource);
  if L > 0 then
  begin
    System.SetLength(ADest, Result + L);
    Move(ASource[0], ADest[Result], Sizeof(TSegment2D) * L);
    Result := Result + L;
  end;
end;

function AppendArray(var ADest: TPolygon2DArray; const ASource: TPolygon2DArray): Integer;
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

  Result := LD + LS;
end;

function AppendArray(var ADest: TSegarc2DArray; const ASource: TSegarc2DArray): Integer;
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

  Result := LD + LS;
end;







end.