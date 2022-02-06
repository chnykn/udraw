unit UdUtils;

{$I UdDefs.Inc}


interface

uses
  Windows, Classes, Types, SysUtils,
  UdConsts, UdTypes, UdGTypes, UdEntity;



//------------------------------------------------------------------------------------------------

function GetGUID(AShort: Boolean; ACompact: Boolean = True): string;
function LoadResourceToStream(AInstance: hInst; AResName, AResType: PChar; AStream: TStream): Boolean;

function GetTempPath: string;
function GetWindowsPath: string;
function GetSystemPath: string;
function ForceDeleteDirectory(ADir: string): Boolean;


function IsUTF8Memory(AMem: PByte; ASize: Int64): Boolean; overload;
function IsUTF8Memory(AStream: TMemoryStream): Boolean; overload;
function IsUTF8File(AFileName: string): Boolean;


{ Inline if }
function iif(const AExpr: Boolean; const ATrueValue: Integer; const AFalseValue: Integer = 0): Integer; overload; {$IFDEF UNICODE} inline; {$ENDIF}
function iif(const AExpr: Boolean; const ATrueValue: Int64; const AFalseValue: Int64 = 0): Int64; overload;  {$IFDEF UNICODE} inline; {$ENDIF}
function iif(const AExpr: Boolean; const ATrueValue: Extended; const AFalseValue: Extended = 0.0): Extended; overload; {$IFDEF UNICODE} inline; {$ENDIF}
function iif(const AExpr: Boolean; const ATrueValue: string; const AFalseValue: string = ''): string; overload;  {$IFDEF UNICODE} inline; {$ENDIF}
function iif(const AExpr: Boolean; const ATrueValue: Boolean; const AFalseValue: Boolean): Boolean; overload; {$IFDEF UNICODE} inline; {$ENDIF}
function iif(const AExpr: Boolean; const ATrueValue: TObject; const AFalseValue: TObject = nil): TObject; overload;  {$IFDEF UNICODE} inline; {$ENDIF}



function ValidateName(AValue: string): string;

function OrdNoCase(C: Char): Integer; {$IFDEF UNICODE} inline; {$ENDIF}

{$IFNDEF D2009UP}
function CharInSet(C: AnsiChar; const CharSet: TSysCharSet): Boolean;
{$ENDIF}

function CopyRange(const S: string; const AStartIndex, AStopIndex: Integer): string;
function CopyFrom(const S: string; const AIndex: Integer): string;
function PosStr(const F, S: string; const AIndex: Integer = 1; const ACaseSensitive: Boolean = True): Integer;
function StrSplit(const S, D: string): TStringDynArray;




procedure SortFloatArray(var A: TFloatArray; Ascend: Boolean = True);

function IsInt(Str: string): Boolean;
function IsNum(Str: string): Boolean;
function HexToInt(const AHexStr: string): Integer;




//-----------------------------------------------------------------------------------------------

function GetEntityClass(ATypeID: Integer): TUdEntityClass;

function CanEntityPick(AEntity: TUdEntity): Boolean;
function ParseCoord(const AValue: string; var APnt: TPoint2D; var AIsOpp: Boolean): Boolean;


function ClearObjectList(AList: TList): Boolean;

function GetEntitiesList(AEntityArray: TUdEntityArray; var AList: TList): Boolean;
function GetEntitiesArray(AEntityList: TList; var AArray: TUdEntityArray): Boolean;

function GetEntitiesBound(AEntities: TList; AOnlyVisible: Boolean = True): TRect2D; overload;
function GetEntitiesBound(AEntities: TUdEntityArray; AOnlyVisible: Boolean = True): TRect2D; overload;


function EntitiesIntersection(Ray: TRay2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function EntitiesIntersection(Ln: TLine2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function EntitiesIntersection(Seg: TSegment2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function EntitiesIntersection(Cir: TCircle2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function EntitiesIntersection(Arc: TArc2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function EntitiesIntersection(Ell: TEllipse2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function EntitiesIntersection(Poly: TPoint2DArray; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function EntitiesIntersection(Segarc: TSegarc2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function EntitiesIntersection(Segarcs: TSegarc2DArray; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function EntitiesIntersection(AEntity: TUdEntity; AOtherEntities: TUdEntityArray): TPoint2DArray; overload;

function GetEntityClosestPoint(APnt: TPoint2D; AEntity: TUdEntity; var AReturn: TPoint2D): Boolean;


implementation

uses
  Dialogs, ShellAPI, ActiveX,
  UdGeo2D, UdMath, UdColls,

  UdPoint, UdLine, UdXLine, UdRay, UdRect, UdCircle, UdArc, UdEllipse, UdPolyline,
  UdSolid, UdText, UdLeader, UdHatch, UdInsert, UdImage,

  UdSpline, UdTolerance,

  UdDimAligned, UdDimRotated, UdDimArclength, UdDimOrdinate, UdDimRadial, UdDimRadiallarge,
  UdDimDiametric, UdDim2LineAngular, UdDim3PointAngular ;



//-----------------------------------------------------------------------------------------------

function GetGUID(AShort: Boolean; ACompact: Boolean = True): string;
var
  I, N: Integer;
  Id: array[0..15] of Byte;      //0..3   4..5  6..7  8..9 10..15
begin                            //4       2     2     2   6
  CoCreateGuid(TGUID(Id));  // ['{CA12A3C4-1B51-4F8D-9240-D1D71330CC6E}']
  Result := '';

  if ACompact then
  begin
    if AShort then N := 7 else N := 15;
    for I := 0 to N do
      Result := Result + IntToHex(Id[I], 2);
  end
  else begin
    Result := '{';

    for I := 0 to 3 do
      Result := Result + IntToHex(Id[I], 2);
    Result := Result + '-';

    for I := 4 to 5 do
      Result := Result + IntToHex(Id[I], 2);
    Result := Result + '-';

    for I := 6 to 7 do
      Result := Result + IntToHex(Id[I], 2);

    if not AShort then
    begin
      Result := Result + '-';

      for I := 8 to 9 do
        Result := Result + IntToHex(Id[I], 2);
      Result := Result + '-';

      for I := 10 to 15 do
        Result := Result + IntToHex(Id[I], 2);
    end;

    Result := Result + '}';
  end;
end;



{ Loads the resource to stream }
function LoadResourceToStream(AInstance: hInst; AResName, AResType: PChar; AStream: TStream): Boolean;
var
  LResSrc: hRSrc;
  LResGlobal: hGlobal;
  LResAddr: Pointer;
  LResLen: DWord;
begin
  Result := False;
  if AStream = nil then Exit;

  LResSrc := FindResource(AInstance, AResName, AResType);
  if LResSrc = 0 then Exit;

  LResGlobal := LoadResource(AInstance, LResSrc);
  if LResGlobal = 0 then Exit;

  LResAddr := LockResource(LResGlobal);
  FreeResource(LResGlobal);
  if LResAddr = nil then Exit;

  LResLen := SizeOfResource(AInstance, LResSrc);
  if LResLen = 0 then Exit;

  try
    AStream.WriteBuffer(LResAddr^, LResLen);
    Result := True;
  except
    //...
  end;
end;


{ Windows Paths  }

procedure FEnsurePathSuffix(var Path: string);
var L : Integer;
begin
  L := Length(Path);
  if (L > 0) and (Path[L] <> '\') then
    begin
      SetLength(Path, L + 1);
      Path[L + 1] := '\';
    end;
end;

function GetTempPath: string;
const
  MaxTempPathLen = MAX_PATH + 1;
var
  I : LongWord;
begin
  SetLength(Result, MaxTempPathLen);
  I := Windows.GetTempPath(MaxTempPathLen, PChar(Result));
  if I > 0 then
    SetLength(Result, I)
  else
    Result := GetEnvironmentVariable('TEMP');
  FEnsurePathSuffix(Result);
end;

function GetWindowsPath: string;
const
  MaxWinPathLen = MAX_PATH + 1;
var
  I : LongWord;
begin
  SetLength(Result, MaxWinPathLen);
  I := GetWindowsDirectory(PChar(Result), MaxWinPathLen);
  if I > 0 then
    SetLength(Result, I)
  else
    Result := GetEnvironmentVariable('SystemRoot');
  FEnsurePathSuffix(Result);
end;

function GetSystemPath: string;
const
  MaxWinSysPathLen = MAX_PATH + 1;
var
  I : LongWord;
begin
  SetLength(Result, MaxWinSysPathLen);
  I := GetSystemDirectory(PChar(Result), MaxWinSysPathLen);
  if I > 0 then
    SetLength(Result, I)
  else
    Result := '';
  FEnsurePathSuffix(Result);
end;

function ForceDeleteDirectory(ADir: string): Boolean;
var
  fo: TSHFILEOPSTRUCT;
  LDir: string;
begin
  Result := False;
  if not SysUtils.DirectoryExists(ADir) then Exit;

  LDir := ADir;
  while LDir[Length(LDir)] = '\' do
    Delete(LDir, Length(LDir), 1);

  FillChar(fo, SizeOf(fo), 0);
  with fo do
  begin
    Wnd := 0;
    wFunc := FO_DELETE;
    pFrom := PChar(LDir + #0);
    pTo := #0#0;
    fFlags := FOF_NOCONFIRMATION + FOF_SILENT;
  end;
  Result := (SHFileOperation(fo) = 0);
end;





//-----------------------------------------------------------------------------------------------

function UTF8CharLength(const C: Byte): Integer;
begin
  // First Byte: 0xxxxxxx
  if ((C and $80) = $00) then
  begin
    Result := 1;
  end
    // First Byte: 110yyyyy
  else if ((C and $E0) = $C0) then
  begin
    Result := 2;
  end
    // First Byte: 1110zzzz
  else if ((C and $F0) = $E0) then
  begin
    Result := 3;
  end
    // First Byte: 11110uuu
  else if ((C and $F8) = $F0) then
  begin
    Result := 4;
  end
    // not valid, return the error value
  else
  begin
    Result := -1;
  end;
end;

//After than you check all the trail bytes for that characters(if any) for conformity with this:
function UTF8IsTrailChar(const C: Byte): BOOLEAN;
begin
  // trail bytes have this form: 10xxxxxx
  Result := ((C and $C0) = $80);
end;


//You can easily go over any byte stream to check if it is valid UTF - 8,  like this:
function IsUTF8Memory(AMem: PByte; ASize: Int64): Boolean;
var
  I: Int64;
  C: Integer;
begin
  Result := True;
  I := 0;

  while (I < ASize) do
  begin
    // get the length if the current UTF-8 character
    C := UTF8CharLength(AMem^);
    // check if it is valid and fits into ASize
    if ((C >= 1) and (C <= 4) and ((I + C - 1) < ASize)) then
    begin
      Inc(I, C);
      Inc(AMem);
      // if it is a multi-byte character, check the trail bytes
      while (C > 1) do
      begin
        if (not UTF8IsTrailChar(AMem^)) then
        begin
          Result := FALSE;
          break;
        end
        else
        begin
          Dec(C);
          Inc(AMem);
        end;
      end;
    end
    else
    begin
      Result := False;
    end;

    if (not Result) then break;
  end;
end;



function IsUTF8Memory(AStream: TMemoryStream): Boolean;
var
  LOldPos: Int64;
begin
  LOldPos := AStream.Position;
  try
    AStream.Position := 0;
    Result := IsUTF8Memory(AStream.Memory, AStream.Size);
  finally
    AStream.Position := LOldPos;
  end;
end;


function IsUTF8File(AFileName: string): Boolean;
var
  LStream: TMemoryStream;
begin
  LStream := TMemoryStream.Create();
  try
    LStream.LoadFromFile(AFileName);
    Result := IsUTF8Memory(LStream);
  finally
    LStream.Free;
  end;
end;



//-----------------------------------------------------------------------------------------------

function GetEntityClass(ATypeID: Integer): TUdEntityClass;
begin
  Result := nil;
  case ATypeID of
    ID_LINE           : Result := TUdLine;
    ID_XLINE          : Result := TUdXLine;
    ID_RAY            : Result := TUdRay;
    ID_RECT           : Result := TUdRect;
    ID_CIRCLE         : Result := TUdCircle;
    ID_ARC            : Result := TUdArc;
    ID_ELLIPSE        : Result := TUdEllipse;
    ID_POLYLINE       : Result := TUdPolyline;

    ID_POINT          : Result := TUdPoint;

    ID_SOLID          : Result := TUdSolid;
    ID_TEXT           : Result := TUdText;
//  ID_MTEXT          : Result := TUdText;
    ID_IMAGE          : Result := TUdImage;
    ID_LEADER         : Result := TUdLeader;
    ID_HATCH          : Result := TUdHatch;

    ID_SPLINE         : Result := TUdSpline;

    ID_TOLERANCE      : Result := TUdTolerance;


    ID_DIMALIGNED     : Result := TUdDimAligned;
    ID_DIMROTATED     : Result := TUdDimRotated;
    ID_DIMARCLENGTH   : Result := TUdDimArclength;
    ID_DIMORDINATE    : Result := TUdDimOrdinate;
    ID_DIMRADIAL      : Result := TUdDimRadial;
    ID_DIMRADIALLARGE : Result := TUdDimRadiallarge;
    ID_DIMDIAMETRIC   : Result := TUdDimDiametric;
    ID_DIMANGULAR     : Result := TUdDim2LineAngular;
    ID_DIM3PANGULAR   : Result := TUdDim3PointAngular;
    ID_INSERT         : Result := TUdInsert;
  end;
end;



//-----------------------------------------------------------------------------------------------
{ iif }

function iif(const AExpr: Boolean; const ATrueValue: Integer; const AFalseValue: Integer = 0): Integer;
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function iif(const AExpr: Boolean; const ATrueValue: Int64; const AFalseValue: Int64 = 0): Int64;
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function iif(const AExpr: Boolean; const ATrueValue: Extended; const AFalseValue: Extended = 0.0): Extended;
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function iif(const AExpr: Boolean; const ATrueValue: string; const AFalseValue: string = ''): string;
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function iif(const AExpr: Boolean; const ATrueValue: Boolean; const AFalseValue: Boolean): Boolean;
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

function iif(const AExpr: Boolean; const ATrueValue: TObject; const AFalseValue: TObject = nil): TObject;
begin
  if AExpr then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;



//-----------------------------------------------------------------------------------------------

function ValidateName(AValue: string): string;
const
  INVALID_CHARS: array[0..10] of Char = ( '<', '>', '/', '\', ':', '?', '*', '|', ';', '=', '`' );
var
  I, N: Integer;
  LChar: Char;
  LValue: string;
begin
  LValue := AValue;

  for I := Low(INVALID_CHARS) to High(INVALID_CHARS) do
  begin
    LChar := INVALID_CHARS[I];
    N := PosStr(LChar, LValue);
    while N > 0 do
    begin
      LValue[N] := '_';
      N := PosStr(LChar, LValue, N + 1);
    end;
  end;

  Result := LValue;
end;


function OrdNoCase(C: Char): Integer; {$IFDEF UNICODE} inline; {$ENDIF}
begin
  Result := Ord(C);
  if (Result in [97..122]) then Result := Result - 32;
end;


{$IFNDEF D2009UP}
function CharInSet(C: AnsiChar; const CharSet: TSysCharSet): Boolean;
begin
  Result := C in CharSet;
end;
{$ENDIF}



procedure SortFloatArray(var A: TFloatArray; Ascend: Boolean = True);
var
  I: Integer;
  J: Integer;
  T: Float;
begin
  if System.Length(A) <= 0 then Exit;

  for I := Low(A) to High(A) - 1 do
  begin
    for J := High(A) downto I + 1 do
    begin
      if (Ascend and (A[I] > A[J])) or
         (not Ascend and (A[I] < A[J])) then
      begin
        T := A[I];
        A[I] := A[J];
        A[J] := T;
      end;
    end;
  end;
end;





//-----------------------------------------------------------------------------------------------

function CopyRange(const S: string; const AStartIndex, AStopIndex: Integer): string;
var
  L, I: Integer;
begin
  L := System.Length(S);
  if (AStartIndex > AStopIndex) or (AStopIndex < 1) or (AStartIndex > L) or (L = 0) then
    Result := ''
  else
  begin
    if AStartIndex <= 1 then
      if AStopIndex >= L then
      begin
        Result := S;
        Exit;
      end
      else
        I := 1
    else
      I := AStartIndex;
    Result := Copy(S, I, AStopIndex - I + 1);
  end;
end;

function CopyFrom(const S: string; const AIndex: Integer): string;
var
  L: Integer;
begin
  if AIndex <= 1 then
    Result := S
  else
  begin
    L := System.Length(S);
    if (L = 0) or (AIndex > L) then
      Result := ''
    else
      Result := Copy(S, AIndex, L - AIndex + 1);
  end;
end;


function StrPMatch(const A, B: PChar; const ALen: Integer; const ACaseSensitive: Boolean = True): Boolean;
var
  P, Q: PChar;
  I: Integer;
begin
  P := A;
  Q := B;

  if P <> Q then
    for I := 1 to ALen do
      if iif(ACaseSensitive, P^ = Q^, OrdNoCase(P^) = OrdNoCase(Q^)) then
      begin
        Inc(P);
        Inc(Q);
      end
      else
      begin
        Result := False;
        Exit;
      end;
  Result := True;
end;

function PosStr(const F, S: string; const AIndex: Integer = 1; const ACaseSensitive: Boolean = True): Integer;
var
  P, Q: PChar;
  L, M, I: Integer;
begin
  L := System.Length(S);
  M := System.Length(F);
  if (L = 0) or (AIndex > L) or (M = 0) or (M > L) then
  begin
    Result := 0;
    Exit;
  end;
  Q := Pointer(F);
  if AIndex < 1 then
    I := 1
  else
    I := AIndex;
  P := Pointer(S);
  Inc(P, I - 1);
  Dec(L, M - 1);

  while I <= L do
    if StrPMatch(P, Q, M, ACaseSensitive) then
    begin
      Result := I;
      Exit;
    end
    else
    begin
      Inc(P);
      Inc(I);
    end;

  Result := 0;
end;

function StrSplit(const S, D: string): TStringDynArray;
var
  I, J, L, M: Integer;
begin
  // Check valid parameters
  if S = '' then
  begin
    Result := nil;
    Exit;
  end;
  M := System.Length(D);
  if M = 0 then
  begin
    System.SetLength(Result, 1);
    Result[0] := S;
    Exit;
  end;
  // Count
  L := 0;
  I := 1;
  repeat
    I := PosStr(D, S, I);
    if I = 0 then
      Break;
    Inc(L);
    Inc(I, M);
  until False;
  System.SetLength(Result, L + 1);
  if L = 0 then
  begin
    // No split
    Result[0] := S;
    Exit;
  end;
  // Split
  L := 0;
  I := 1;
  repeat
    J := PosStr(D, S, I);
    if J = 0 then
    begin
      Result[L] := CopyFrom(S, I);
      Break;
    end;
    Result[L] := CopyRange(S, I, J - 1);
    Inc(L);
    I := J + M;
  until False;
end;


//-----------------------------------------------------------------------------------------------

function IsInt(Str: string): Boolean;
var
  I: Longint;
  E: Longint;
begin
  Val(Str, I, E);
  Result := E = 0;
  E := Round(I); //void hint
end;

function IsNum(Str: string): Boolean;
var
  I: Double;
  E: Longint;
begin
  Val(Str, I, E);
  Result := E = 0;
  E := Round(I); //void hint
end;


{$WARNINGS OFF}
function HexToInt(const AHexStr: string): Integer;
var
  I, L, K: Integer;
begin
  Result := 0;
  if AHexStr = ' ' then Exit;

  K := 0;
  L := Length(AHexStr);
  for I := 1 to L do
  begin
    if (not (AHexStr[I] in ['A'..'F'])) and (not (AHexStr[I] in ['a'..'f'])) then
      K := K + Trunc(StrToInt(AHexStr[I]) * Power(16, L - I))
    else
      case AHexStr[I] of
       'a','A': K := K + Trunc(10 * Power(16, L - I));
       'b','B': K := K + Trunc(11 * Power(16, L - I));
       'c','C': K := K + Trunc(12 * Power(16, L - I));
       'd','D': K := K + Trunc(13 * Power(16, L - I));
       'e','E': K := K + Trunc(14 * Power(16, L - I));
       'f','F': K := K + Trunc(15 * Power(16, L - I));
      end;
  end;

  Result := K;
end;
{$WARNINGS ON}



function ClearObjectList(AList: TList): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not Assigned(AList) then Exit;

  for I := AList.Count - 1 downto 0 do
  begin
    try
      TObject(AList.Items[I]).Free;
    except
      //...
    end;
  end;
  AList.Clear();

  Result := True;
end;


function GetEntitiesBound(AEntities: TList; AOnlyVisible: Boolean = True): TRect2D;
var
  I: Integer;
  N: Integer;
  LRect: TRect2D;
  LEntity: TUdEntity;
begin
  InitRect(Result);
  if not Assigned(AEntities) or (AEntities.Count <= 0) then Exit;

  N := 0;

  for I := 0 to AEntities.Count - 1 do
  begin
    LEntity := TUdEntity(AEntities.Items[I]);

    try
      if not Assigned(LEntity) then Continue;
      if AOnlyVisible and not LEntity.IsVisible() then Continue;
    except
      {$IFDEF DEBUG}
      MessageDlg('GetEntitiesRect(Entities: TList) Error: AEntity.ClassName=' + LEntity.ClassName, mtWarning, [mbOK], 0);
      {$ENDIF}
      Continue;
    end;

    LRect := LEntity.BoundsRect;
    if not IsValidRect(LRect) then Continue;

    if N = 0 then
    begin
      Result.X1 := LRect.X1;
      Result.X2 := LRect.X2;
      Result.Y1 := LRect.Y1;
      Result.Y2 := LRect.Y2;
    end
    else
    begin
      if Result.X1 > LRect.X1 then Result.X1 := LRect.X1;
      if Result.X2 < LRect.X2 then Result.X2 := LRect.X2;
      if Result.Y1 > LRect.Y1 then Result.Y1 := LRect.Y1;
      if Result.Y2 < LRect.Y2 then Result.Y2 := LRect.Y2;
    end;
    N := N + 1;
  end;
end;

function GetEntitiesBound(AEntities: TUdEntityArray; AOnlyVisible: Boolean = True): TRect2D;
var
  I: Integer;
  N: Integer;
  LRect: TRect2D;
  LEntity: TUdEntity;
begin
  InitRect(Result);
  if System.Length(AEntities) <= 0 then Exit;

  N := 0;

  for I := 0 to System.Length(AEntities) - 1 do
  begin
    LEntity := AEntities[I];

    try
      if not Assigned(LEntity) then Continue;
      if AOnlyVisible and not LEntity.IsVisible() then Continue;
    except
      {$IFDEF DEBUG}
      MessageDlg('GetEntitiesRect(Entities: TUdEntityArray) Error: AEntity.ClassName=' + LEntity.ClassName, mtWarning, [mbOK], 0);
      {$ENDIF}
      Continue;
    end;

    LRect := LEntity.BoundsRect;
    if not IsValidRect(LRect) then Continue;

    if N = 0 then
    begin
      Result.X1 := LRect.X1;
      Result.X2 := LRect.X2;
      Result.Y1 := LRect.Y1;
      Result.Y2 := LRect.Y2;
    end
    else
    begin
      if Result.X1 > LRect.X1 then Result.X1 := LRect.X1;
      if Result.X2 < LRect.X2 then Result.X2 := LRect.X2;
      if Result.Y1 > LRect.Y1 then Result.Y1 := LRect.Y1;
      if Result.Y2 < LRect.Y2 then Result.Y2 := LRect.Y2;
    end;
    N := N + 1;
  end;
end;



function GetEntitiesArray(AEntityList: TList; var AArray: TUdEntityArray): Boolean;
var
  I: Integer;
begin
  AArray := nil;

  Result := False;
  if not Assigned(AEntityList) or (AEntityList.Count <= 0) then Exit;

  System.SetLength(AArray, AEntityList.Count);
  for I := 0 to AEntityList.Count - 1 do AArray[I] := TUdEntity(AEntityList[I]);

  Result := True;
end;

function GetEntitiesList(AEntityArray: TUdEntityArray; var AList: TList): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (System.Length(AEntityArray) <= 0) or not Assigned(AList) then Exit;

  for I := 0 to System.Length(AEntityArray) - 1 do AList.Add(AEntityArray[I]);
  Result := True;
end;


function CanEntityPick(AEntity: TUdEntity): Boolean;
begin
  Result := False;
  if not Assigned(AEntity) then Exit;

  if not AEntity.IsVisible() or not AEntity.CanSelected or AEntity.IsLock()  then Exit;

  Result := True;
end;




function ParseCoord(const AValue: string; var APnt: TPoint2D; var AIsOpp: Boolean): Boolean;
var
  N: Integer;
  LInStr, A, B: string;
begin
  Result := False;
  LInStr := Trim(AValue);

  if LInStr = '@' then LInStr := LInStr + '0,0';
  if System.Length(LInStr) < 3 then Exit; //至少也必须是 1,1 或者 1<1 这种形式  三个字符

  AIsOpp := LInStr[1] = '@';
  if AIsOpp then Delete(LInStr, 1, 1);

  if (System.Length(LInStr) < 3) then Exit;

  if Pos(',', LInStr) > 0 then
  begin
    N := Pos(',', LInStr);

    A := Copy(LInStr, 1, N - 1);
    A := Trim(A);
    Delete(LInStr, 1, N);
    B := Trim(LInStr);

    Result := IsNum(A) and IsNum(B);

    if Result then
    begin
      APnt.X := StrToFloat(A);
      APnt.Y := StrToFloat(B);
    end;
  end

  else if Pos('<', LInStr) > 0 then
  begin
    N := Pos('<', LInStr);

    A := Copy(LInStr, 1, N - 1);
    A := Trim(A);
    Delete(LInStr, 1, N);
    B := Trim(LInStr);

    Result := IsNum(A) and IsNum(B);

    if Result then
    begin
      APnt.X := StrToFloat(A) * CosD(StrToFloat(B));
      APnt.Y := StrToFloat(A) * SinD(StrToFloat(B));
    end;
  end;
end;



//----------------------------------------------------------------------------------------------

function EntitiesIntersection(Ray: TRay2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdLine(AEntity).XData,Epsilon);
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdXLine(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdRay(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdLeader) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdLeader(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdRect(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdCircle(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdArc(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdEllipse(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    if TUdPolyline(AEntity).SplineFlag = sfStandard then
      Result := UdGeo2D.Intersection(Ray, TUdPolyline(AEntity).XData, Epsilon)
    else
      Result := UdGeo2D.Intersection(Ray, TUdPolyline(AEntity).SamplePoints, Epsilon)
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdSpline(AEntity).SamplePoints, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdSolid) then
  begin
    Result := UdGeo2D.Intersection(Ray, TUdSolid(AEntity).SamplePoints, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdInsert) then
  begin
    for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      FAddArray(Result, EntitiesIntersection(Ray, TUdInsert(AEntity).Entities.Items[I], Epsilon) );
  end;
end;

function EntitiesIntersection(Ln: TLine2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    Result := UdGeo2D.Intersection(Ln, TUdLine(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    Result := UdGeo2D.Intersection(Ln, TUdXLine(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    Result := UdGeo2D.Intersection(TUdRay(AEntity).XData, Ln, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdLeader) then
  begin
    Result := UdGeo2D.Intersection(Ln, TUdLeader(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    Result := UdGeo2D.Intersection(Ln, TUdRect(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    Result := UdGeo2D.Intersection(Ln, TUdCircle(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    Result := UdGeo2D.Intersection(Ln, TUdArc(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    Result := UdGeo2D.Intersection(Ln, TUdEllipse(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    if TUdPolyline(AEntity).SplineFlag = sfStandard then
      Result := UdGeo2D.Intersection(Ln, TUdPolyline(AEntity).XData, Epsilon)
    else
      Result := UdGeo2D.Intersection(Ln, TUdPolyline(AEntity).SamplePoints, Epsilon)
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    Result := UdGeo2D.Intersection(Ln, TUdSpline(AEntity).SamplePoints, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdSolid) then
  begin
    Result := UdGeo2D.Intersection(Ln, TUdSolid(AEntity).SamplePoints, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdInsert) then
  begin
    for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      FAddArray(Result, EntitiesIntersection(Ln, TUdInsert(AEntity).Entities.Items[I], Epsilon) );
  end;
end;

function EntitiesIntersection(Seg: TSegment2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    Result := UdGeo2D.Intersection(Seg, TUdLine(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    Result := UdGeo2D.Intersection(TUdXLine(AEntity).XData, Seg, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    Result := UdGeo2D.Intersection(TUdRay(AEntity).XData, Seg, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdLeader) then
  begin
    Result := UdGeo2D.Intersection(Seg, TUdLeader(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    Result := UdGeo2D.Intersection(Seg, TUdRect(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    Result := UdGeo2D.Intersection(Seg, TUdCircle(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    Result := UdGeo2D.Intersection(Seg, TUdArc(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    Result := UdGeo2D.Intersection(Seg, TUdEllipse(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    if TUdPolyline(AEntity).SplineFlag = sfStandard then
      Result := UdGeo2D.Intersection(Seg, TUdPolyline(AEntity).XData, Epsilon)
    else
      Result := UdGeo2D.Intersection(Seg, TUdPolyline(AEntity).SamplePoints, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    Result := UdGeo2D.Intersection(Seg, TUdSpline(AEntity).SamplePoints, Epsilon)
  end else

  if AEntity.InheritsFrom(TUdSolid) then
  begin
    Result := UdGeo2D.Intersection(Seg, TUdSolid(AEntity).SamplePoints, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdInsert) then
  begin
    for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      FAddArray(Result, EntitiesIntersection(Seg, TUdInsert(AEntity).Entities.Items[I], Epsilon) );
  end;
end;

function EntitiesIntersection(Cir: TCircle2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    Result := UdGeo2D.Intersection(TUdLine(AEntity).XData, Cir, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    Result := UdGeo2D.Intersection(TUdXLine(AEntity).XData, Cir, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    Result := UdGeo2D.Intersection(TUdRay(AEntity).XData, Cir, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    Result := UdGeo2D.Intersection(Cir, TUdRect(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    Result := UdGeo2D.Intersection(Cir, TUdCircle(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    Result := UdGeo2D.Intersection(Cir, TUdArc(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    Result := UdGeo2D.Intersection(Cir, TUdEllipse(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    if TUdPolyline(AEntity).SplineFlag = sfStandard then
      Result := UdGeo2D.Intersection(Cir, TUdPolyline(AEntity).XData, Epsilon)
    else
      Result := UdGeo2D.Intersection(Cir, TUdPolyline(AEntity).SamplePoints, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    Result := UdGeo2D.Intersection(Cir, TUdSpline(AEntity).SamplePoints, Epsilon)
  end else

  if AEntity.InheritsFrom(TUdLeader) then
  begin
    Result := UdGeo2D.Intersection(Cir, TUdLeader(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdSolid) then
  begin
    Result := UdGeo2D.Intersection(Cir, TUdSolid(AEntity).SamplePoints, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdInsert) then
  begin
    for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      FAddArray(Result, EntitiesIntersection(Cir, TUdInsert(AEntity).Entities.Items[I], Epsilon) );
  end;
end;

function EntitiesIntersection(Arc: TArc2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    Result := UdGeo2D.Intersection(TUdLine(AEntity).XData, Arc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    Result := UdGeo2D.Intersection(TUdXLine(AEntity).XData, Arc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    Result := UdGeo2D.Intersection(TUdRay(AEntity).XData, Arc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    Result := UdGeo2D.Intersection(Arc, TUdRect(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    Result := UdGeo2D.Intersection(TUdCircle(AEntity).XData, Arc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    Result := UdGeo2D.Intersection(Arc, TUdArc(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    Result := UdGeo2D.Intersection(Arc, TUdEllipse(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    if TUdPolyline(AEntity).SplineFlag = sfStandard then
      Result := UdGeo2D.Intersection(Arc, TUdPolyline(AEntity).XData, Epsilon)
    else
      Result := UdGeo2D.Intersection(Arc, TUdPolyline(AEntity).SamplePoints, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    Result := UdGeo2D.Intersection(Arc, TUdSpline(AEntity).SamplePoints, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdLeader) then
  begin
    Result := UdGeo2D.Intersection(Arc, TUdLeader(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdSolid) then
  begin
    Result := UdGeo2D.Intersection(Arc, TUdSolid(AEntity).SamplePoints, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdInsert) then
  begin
    for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      FAddArray(Result, EntitiesIntersection(Arc, TUdInsert(AEntity).Entities.Items[I], Epsilon) );
  end;
end;

function EntitiesIntersection(Ell: TEllipse2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    Result := UdGeo2D.Intersection(TUdLine(AEntity).XData, Ell, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    Result := UdGeo2D.Intersection(TUdXLine(AEntity).XData, Ell, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    Result := UdGeo2D.Intersection(TUdRay(AEntity).XData, Ell, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    Result := UdGeo2D.Intersection(Ell, TUdRect(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    Result := UdGeo2D.Intersection(TUdCircle(AEntity).XData, Ell, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    Result := UdGeo2D.Intersection(TUdArc(AEntity).XData, Ell, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    Result := UdGeo2D.Intersection(Ell, TUdEllipse(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    if TUdPolyline(AEntity).SplineFlag = sfStandard then
      Result := UdGeo2D.Intersection(Ell, TUdPolyline(AEntity).XData, Epsilon)
    else
      Result := UdGeo2D.Intersection(Ell, TUdPolyline(AEntity).SamplePoints, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    Result := UdGeo2D.Intersection(Ell, TUdSpline(AEntity).SamplePoints, Epsilon)
  end else

  if AEntity.InheritsFrom(TUdLeader) then
  begin
    Result := UdGeo2D.Intersection(Ell, TUdLeader(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdSolid) then
  begin
    Result := UdGeo2D.Intersection(Ell, TUdSolid(AEntity).SamplePoints, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdInsert) then
  begin
    for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      FAddArray(Result, EntitiesIntersection(Ell, TUdInsert(AEntity).Entities.Items[I], Epsilon) );
  end;
end;

function EntitiesIntersection(Poly: TPoint2DArray; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    Result := UdGeo2D.Intersection(TUdLine(AEntity).XData, Poly, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    Result := UdGeo2D.Intersection(TUdXLine(AEntity).XData, Poly, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    Result := UdGeo2D.Intersection(TUdRay(AEntity).XData, Poly, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    Result := UdGeo2D.Intersection(Poly, TUdRect(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    Result := UdGeo2D.Intersection(TUdCircle(AEntity).XData, Poly, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    Result := UdGeo2D.Intersection(TUdArc(AEntity).XData, Poly, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    Result := UdGeo2D.Intersection(TUdEllipse(AEntity).XData, Poly, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    if TUdPolyline(AEntity).SplineFlag = sfStandard then
      Result := UdGeo2D.Intersection(Poly, TUdPolyline(AEntity).XData, Epsilon)
    else
      Result := UdGeo2D.Intersection(Poly, TUdPolyline(AEntity).SamplePoints, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    Result := UdGeo2D.Intersection(Poly, TUdSpline(AEntity).SamplePoints, Epsilon)
  end else

  if AEntity.InheritsFrom(TUdLeader) then
  begin
    Result := UdGeo2D.Intersection(Poly, TUdLeader(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdSolid) then
  begin
    Result := UdGeo2D.Intersection(Poly, TUdSolid(AEntity).SamplePoints, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdInsert) then
  begin
    for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      FAddArray(Result, EntitiesIntersection(Poly, TUdInsert(AEntity).Entities.Items[I], Epsilon) );
  end;
end;

function EntitiesIntersection(Segarc: TSegarc2D; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    Result := UdGeo2D.Intersection(TUdLine(AEntity).XData, Segarc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    Result := UdGeo2D.Intersection(TUdXLine(AEntity).XData, Segarc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    Result := UdGeo2D.Intersection(TUdRay(AEntity).XData, Segarc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    Result := UdGeo2D.Intersection(Segarc, TUdRect(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    Result := UdGeo2D.Intersection(TUdCircle(AEntity).XData, Segarc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    Result := UdGeo2D.Intersection(TUdArc(AEntity).XData, Segarc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    Result := UdGeo2D.Intersection(TUdEllipse(AEntity).XData, Segarc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    if TUdPolyline(AEntity).SplineFlag = sfStandard then
      Result := UdGeo2D.Intersection(Segarc, TUdPolyline(AEntity).XData, Epsilon)
    else
      Result := UdGeo2D.Intersection(TUdPolyline(AEntity).SamplePoints, Segarc, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    Result := UdGeo2D.Intersection(TUdSpline(AEntity).SamplePoints, Segarc, Epsilon)
  end else

  if AEntity.InheritsFrom(TUdLeader) then
  begin
    Result := UdGeo2D.Intersection(TUdLeader(AEntity).XData, Segarc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdSolid) then
  begin
    Result := UdGeo2D.Intersection(TUdSolid(AEntity).SamplePoints, Segarc, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdInsert) then
  begin
    for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      FAddArray(Result, EntitiesIntersection(Segarc, TUdInsert(AEntity).Entities.Items[I], Epsilon) );
  end;
end;

function EntitiesIntersection(Segarcs: TSegarc2DArray; AEntity: TUdEntity; const Epsilon: Float = _Epsilon): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    Result := UdGeo2D.Intersection(TUdLine(AEntity).XData, Segarcs, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    Result := UdGeo2D.Intersection(TUdXLine(AEntity).XData, Segarcs, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    Result := UdGeo2D.Intersection(TUdRay(AEntity).XData, Segarcs, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    Result := UdGeo2D.Intersection(Segarcs, TUdRect(AEntity).XData, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    Result := UdGeo2D.Intersection(TUdCircle(AEntity).XData, Segarcs, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    Result := UdGeo2D.Intersection(TUdArc(AEntity).XData, Segarcs, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    Result := UdGeo2D.Intersection(TUdEllipse(AEntity).XData, Segarcs, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    if TUdPolyline(AEntity).SplineFlag = sfStandard then
      Result := UdGeo2D.Intersection(Segarcs, TUdPolyline(AEntity).XData, Epsilon)
    else
      Result := UdGeo2D.Intersection(TUdPolyline(AEntity).SamplePoints, Segarcs, Epsilon);
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    Result := UdGeo2D.Intersection(TUdSpline(AEntity).SamplePoints, Segarcs, Epsilon)
  end else

  if AEntity.InheritsFrom(TUdLeader) then
  begin
    Result := UdGeo2D.Intersection(TUdLeader(AEntity).XData, Segarcs, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdSolid) then
  begin
    Result := UdGeo2D.Intersection(TUdSolid(AEntity).SamplePoints, Segarcs, Epsilon);
  end else
  if AEntity.InheritsFrom(TUdInsert) then
  begin
    for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      FAddArray(Result, EntitiesIntersection(Segarcs, TUdInsert(AEntity).Entities.Items[I], Epsilon) );
  end;
end;


function EntitiesIntersection(AEntity: TUdEntity; AOtherEntities: TUdEntityArray): TPoint2DArray;
var
  I, J: Integer;
  LInctPnts: TPoint2DArray;
  LInctPntList: TPoint2DList;
begin
  Result := nil;

  LInctPnts := nil;
  LInctPntList := TPoint2DList.Create(MAXBYTE);
  try
    for I := 0 to System.Length(AOtherEntities) - 1 do
    begin
      if Assigned(AOtherEntities[I]) and (AOtherEntities[I] <> AEntity) then
      begin
        LInctPnts := AEntity.Intersect(AOtherEntities[I]);
        for J := 0 to System.Length(LInctPnts) - 1 do LInctPntList.Add(LInctPnts[J]);
      end;
    end;
    Result := LInctPntList.ToArray();
  finally
    LInctPntList.Free;
  end;
end;


function GetEntityClosestPoint(APnt: TPoint2D; AEntity: TUdEntity; var AReturn: TPoint2D): Boolean;
begin
  Result := False;
  if not Assigned(AEntity) then Exit;

  if AEntity.InheritsFrom(TUdLine) then
  begin
    AReturn := UdGeo2D.ClosestSegmentPoint(APnt, TUdLine(AEntity).XData);
    Result := True;
  end else
  if AEntity.InheritsFrom(TUdXLine) then
  begin
    AReturn := UdGeo2D.ClosestLinePoint(APnt, TUdXLine(AEntity).XData);
    Result := True;
  end else
  if AEntity.InheritsFrom(TUdRay) then
  begin
    AReturn := UdGeo2D.ClosestLinePoint(APnt, Line2D(TUdRay(AEntity).BasePoint, TUdRay(AEntity).SecondPoint));
    Result := IsEqual(GetAngle(TUdRay(AEntity).BasePoint, AReturn), GetAngle(TUdRay(AEntity).BasePoint, TUdRay(AEntity).SecondPoint), 1);
  end else
  if AEntity.InheritsFrom(TUdRect) then
  begin
    AReturn := UdGeo2D.ClosestSegarcsPoint(APnt, TUdRect(AEntity).XData);
    Result := True;
  end else
  if AEntity.InheritsFrom(TUdCircle) then
  begin
    AReturn := UdGeo2D.ClosestCirclePoint(APnt, TUdCircle(AEntity).XData);
    Result := True;
  end else
  if AEntity.InheritsFrom(TUdArc) then
  begin
    AReturn := UdGeo2D.ClosestArcPoint(APnt, TUdArc(AEntity).XData);
    Result := True;
  end else
  if AEntity.InheritsFrom(TUdEllipse) then
  begin
    AReturn := UdGeo2D.ClosestEllipsePoint(APnt, TUdEllipse(AEntity).XData);
    Result := True;
  end else
  if AEntity.InheritsFrom(TUdPolyline) then
  begin
    AReturn := UdGeo2D.ClosestSegarcsPoint(APnt, TUdPolyline(AEntity).XData);
    Result := True;
  end else

  if AEntity.InheritsFrom(TUdSpline) then
  begin
    AReturn := UdGeo2D.ClosestPointsPoint(APnt, TUdSpline(AEntity).SamplePoints);
    Result := True;
  end else

  if AEntity.InheritsFrom(TUdLeader) then
  begin
    AReturn := UdGeo2D.ClosestPointsPoint(APnt, TUdLeader(AEntity).SamplePoints);
    Result := True;
  end else
  if AEntity.InheritsFrom(TUdSolid) then
  begin
    AReturn := UdGeo2D.ClosestPointsPoint(APnt, TUdSolid(AEntity).SamplePoints);
    Result := True;
  end;
end;

end.