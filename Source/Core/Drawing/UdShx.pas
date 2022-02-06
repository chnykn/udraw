{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdShx;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Forms, Types,
  UdTypes, UdColls;


const
  WIN_CODES: array[0..45] of Integer = (
      0, 0,
      $6faf, $6fb0, $6fb1, $6fb2, $6fb3, $6fb4, $6fb5, $6fb6, $6fb7,
      $1b5, 850, $354, $357, $359, 860, $35d, $35f, $360, $361, $365, $3a4,
      $3e8, 950, $3b5, $551, $362, $4e2, $4e3, $4e4, $51c8,
      $4e5, $4e6, $4e7, $4e8, $4e9, $36a, $3a4, $3a8, $3b5,
      950, $551, 0, $4ea,
      0 );





type

  TUdShxRanges = record
    iBegin: Short;
    iEnd: Short;
  end;

  TUdShxStruct = record
    Num: Word;
    ONum: Word;
    Name: string;
    SpecBytes: TByteDynArray;
  end;

  TUdShxOutLines = class
  public
    Above: Integer;
    Below: Integer;
    Structs: array of TUdShxStruct;
    Ranges : array of TUdShxRanges;

    constructor Create;
  end;



  //*** TUdShx ***//
  TUdShx = class(TObject)
  private
    FBigFile: string;
    FShxFile: string;

    FShxOutLines: TUdShxOutLines;
    FBigOutLines: TUdShxOutLines;

    FCalcBigMode: Boolean;

  protected
    function GetAscent: Double;
    function GetDescent: Double;

    procedure SetBigFile(const AValue: string);
    procedure SetShxFile(const AValue: string);

    class function FindShape(AShapeNum: Word; AOutlines: TUdShxOutLines; AONum: Boolean = False): Integer; {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    procedure DrawShape(AShapeNum: Word; AParam: TObject; AONum: Boolean = False; AMult: PFloat = nil);

  public
    constructor Create;
    destructor Destroy; override;

    class function IsBigFont(AStream: TMemoryStream): Boolean; overload;  {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class function IsBigFont(AFilename: string): Boolean; overload;       {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}

    class function IsNormalFont(AStream: TMemoryStream): Boolean; overload;  {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class function IsNormalFont(AFilename: string): Boolean; overload;       {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}

    class function IsUnicodeFont(AStream: TMemoryStream): Boolean;overload;  {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class function IsUnicodeFont(AFilename: string): Boolean;overload;       {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}

    class function ProcessNormal(AStream: TMemoryStream): TUdShxOutLines;overload;   {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class function ProcessNormal(AFilename: string): TUdShxOutLines; overload;       {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}

    class function ProcessUnicode(AStream: TMemoryStream): TUdShxOutLines; overload;  {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class function ProcessUnicode(AFilename: string): TUdShxOutLines; overload;       {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}

    class function ProcessBig(AStream: TMemoryStream; ACodePage: TUdCodePage): TUdShxOutLines; overload;  {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class function ProcessBig(AFilename: string; ACodePage: TUdCodePage): TUdShxOutLines; overload;       {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}

    function GetCharPolys(ACharCode: Integer; var AOfsX, AOfsY: Float; AHeight: Double; AWidthFactor: Double = 1.0): TPoint2DArrays;

    function GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec): TPoint2DArrays; overload;
    function GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec; var ATextBound: TPoint2DArray): TPoint2DArrays; overload;
    function GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec; var ATextWidth, ATextHeight: Float; var ATextBound: TPoint2DArray): TPoint2DArrays; overload;

  public
    property Ascent: Double read GetAscent;
    property Descent: Double read GetDescent;

    property BigOutLines: TUdShxOutLines read FBigOutLines;
    property ShxOutLines: TUdShxOutLines read FShxOutLines;

    property ShxFile: string read FShxFile write SetShxFile;
    property BigFile: string read FBigFile write SetBigFile;
  end;



procedure SetDefFontDir(const AValue: string);
function GetDefGdtShx(): TUdShx;
function GetDefSimplexShx(): TUdShx;



//------------------------------------------------

type
  TUdCharCode = record
    Kind: Integer;
    Value: Integer;
  end;
  TUdCharCodeArray = array of TUdCharCode;

  TUdGetCharCodeFunc = function(Value: WideChar): LongWord;

function _GetCharCodes(AText: WideString; ACharCodeFunc: TUdGetCharCodeFunc): TUdCharCodeArray;


  
implementation

uses
  SysUtils,
  UdUtils, UdGTypes, UdMath, UdGeo2D, UdStreams;

const
  NUM_DIV: Integer = $10;

  _2Pi: Extended      = 6.283185307179586476925286766559;       // 2 * PI
  _PiDiv2: Extended   = 1.5707963267948966192313216916398;      // PI / 2
  _PiDiv180: Extended = 0.017453292519943295769236907684886;    // Pi / 180

const
  NORMAL_SHAPES_HEAD_1_1 = 'AutoCAD-86 shapes 1.1';
  NORMAL_SHAPES_HEAD_1_0 = 'AutoCAD-86 shapes 1.0';

  BIG_SHAPES_HEAD_1_0    = 'AutoCAD-86 bigfont 1.0';
  UNI_SHAPES_HEAD_1_0    = 'AutoCAD-86 unifont 1.0';




//==================================================================================================

{$WARNINGS OFF}
function _GetCharCodes(AText: WideString; ACharCodeFunc: TUdGetCharCodeFunc): TUdCharCodeArray;
var
  I, J: Integer;
  L, M, N: Integer;
  LText: WideString;
  LValue, LKind: Integer;
  LStr, LHexStr: string;
  LHexValid: Boolean;
begin
  Result := nil;
    
  LText := AText + #32;

  I := 1;
  L := 0;

  while I < System.Length(LText) do
  begin
    LKind  := 0;
    LValue := -1;

    if (LText[I] = '%') and (LText[I+1] = '%') then  //ADTGDT.TTF  %%C = 126   %%P = 96    %%P = 110
    begin
      M := -1;

      //如果%%后为33~255之内的数字 则转为对应的数值
      if (Char(LText[I+2]) in ['1'..'9']) then
      begin
        LStr := Trim(Copy(LText, I+2, 3));
        if IsNum(LStr) then
        begin
          M := 3;
          if StrToInt(LStr) > 255 then
          begin
            Delete(LStr, 3, 1);
            M := 2;
          end;
        end
        else begin
          Delete(LStr, 3, 1);
          if IsNum(LStr) then M := 2 else M := -1;
        end;

        if M > 0 then
        begin
          N := StrToInt(LStr);
          if N in [33..255] then
          begin
            LValue := N;
            I := I + M + 1;
          end
          else
            M := -1;
        end;
      end;

      if (M < 0) and ( (I+2) < System.Length(LText) ) then
      begin
        if Char(LText[I+2]) in ['d', 'D'] then LValue := 126 else
        if Char(LText[I+2]) in ['p', 'P'] then LValue := 96  else
        if Char(LText[I+2]) in ['c', 'C'] then LValue := 110 ;

        if LValue >= 0 then
        begin
          I := I + 2;
          LKind := 1;
        end;
      end;
    end
    else if (LText[I] = '\') and (Char(LText[I+1]) in ['U', 'u']) then  //ISOCPEUR.TTF \U+XXXX
    begin
      if (LText[I+2] = '+') and ((I+6) < System.Length(LText)) then
      begin
        LHexStr := UpperCase(Copy(LText, I+3, 4));
        LHexValid := True;

        for J := 1 to Length(LHexStr) do
        begin
          if not (LHexStr[J] in ['0'..'9', 'A'..'F']) then
          begin
            LHexValid := False;
            Break;
          end;
        end;

        if LHexValid then
        begin
          LValue := HexToInt(LHexStr);
          I := I + 6;
          LKind := 2;
        end;
      end;
    end
    else if (LText[I] = '\') and (Char(LText[I+1]) in ['M', 'm']) then  // \M+XXXXX
    begin
      if (LText[I+2] = '+') and ((I+7) < System.Length(LText)) then
      begin
        LHexStr := UpperCase(Copy(LText, I+3, 5));
        LHexValid := True;

        for J := 1 to Length(LHexStr) do
        begin
          if not (LHexStr[J] in ['0'..'9', 'A'..'F']) then
          begin
            LHexValid := False;
            Break;
          end;
        end;

        if LHexValid then
        begin
          LValue := HexToInt(LHexStr) - $10000;
          I := I + 7;
          LKind := 3;
        end;
      end;
    end;         

    if LValue < 0 then
      LValue := ACharCodeFunc(LText[I]); //TTFCharCode(LText[I]);

    SetLength(Result, L + 1);
    Result[L].Kind := LKind;
    Result[L].Value := LValue;

    Inc(L);
    Inc(I);
  end;
end;
{$WARNINGS ON}


    

//==================================================================================================

var
  GDefFontDir: string;
  GGdtShx    : TUdShx;
  GSimplexShx: TUdShx;



procedure SetDefFontDir(const AValue: string);
begin
  GDefFontDir := AValue;
end;

function GetDefGdtShx(): TUdShx;
var
  LFileName: string;
begin
  if not Assigned(GGdtShx) then
  begin
    LFileName := GDefFontDir + '\' + 'GDT.SHX';
    if SysUtils.FileExists(LFileName) then
    begin
      GGdtShx := TUdShx.Create;
      GGdtShx.ShxFile := LFileName;

      if not Assigned(GGdtShx.FShxOutLines) then
      begin
        GGdtShx.Free;
        GGdtShx := nil;
      end;
    end;
  end;

  Result := GGdtShx;
end;

function GetDefSimplexShx(): TUdShx;
var
  LFileName: string;
begin
  if not Assigned(GSimplexShx) then
  begin
    LFileName := GDefFontDir + '\' + 'Simplex.SHX';
    if SysUtils.FileExists(LFileName) then
    begin
      GSimplexShx := TUdShx.Create;
      GSimplexShx.ShxFile := LFileName;

      if not Assigned(GSimplexShx.FShxOutLines) then
      begin
        GSimplexShx.Free;
        GSimplexShx := nil;
      end;
    end;
  end;

  Result := GSimplexShx;
end;






//==================================================================================================
{ TUdShxOutLines }

constructor TUdShxOutLines.Create;
begin
  Above := 1;
  Below := 0;
  Structs := nil;
  Ranges  := nil;
end;



//==================================================================================================

type
  TUdWideChars = array of WideChar;

function GetCharCount(ACodePage: UINT; Bytes: PByte; ByteCount: Integer): Integer; overload;
begin
  Result := MultiByteToWideChar(ACodePage, 0, PAnsiChar(Bytes), ByteCount, nil, 0);
end;

function GetCharCount(ACodePage: UINT; const ABytes: TByteDynArray; AByteIndex, AByteCount: Integer): Integer; overload;
begin
  if AByteCount > 0 then
    Result := GetCharCount(ACodePage, @ABytes[AByteIndex], AByteCount)
  else
    Result := 0
end;

function GetCharsFromBytes(ACodePage: UINT; Bytes: PByte; ByteCount: Integer; Chars: PWideChar; CharCount: Integer): Integer; overload;
begin
  Result := MultiByteToWideChar(ACodePage, 0, PAnsiChar(Bytes), ByteCount, Chars, CharCount);
end;

function GetCharsFromBytes(ACodePage: UINT; const ABytes: TByteDynArray; AByteIndex, AByteCount: Integer): TUdWideChars; overload;
var
  Len: Integer;
begin
  Len := GetCharCount(ACodePage, ABytes, AByteIndex, AByteCount);
  System.SetLength(Result, Len);
  if Len > 0 then
    GetCharsFromBytes(ACodePage, @ABytes[AByteIndex], AByteCount, PWideChar(Result), Len);
end;





//==================================================================================================
{ TUdShxParams }
type
  TUdShxParams = class(TObject)
  private
    FCurPnts: TPoint2DList;
    FConnLines: TPoint2DArrays;

    FPntsStack: TPoint2DStack;
    FDrawMode: Integer;
    FNextCmd: Boolean;

    FChar: WideChar;
    FOffX: Double;
    FOffY: Double;
    FHeight: Double;
    FMult: Double;

  protected
    function GetCurrPos: PPoint2D;

  public
    constructor Create;
    destructor Destroy; override;

    procedure StartShape;
    procedure FinishShape;
    procedure LineTo(X, Y: Double);

    procedure Scale(Base: TPoint2D; Sx, Sy: Double; N1, N2: Integer);
    procedure Offset(Dx, Dy: Double; N1, N2: Integer);
    procedure Rotate(Base: TPoint2D; Rota: Double; N1, N2: Integer);

  public
    property DrawMode: Integer read FDrawMode write FDrawMode;
    property NextCmd : Boolean read FNextCmd  write FNextCmd;

    property Char: WideChar read FChar write FChar;
    property OffX: Double   read FOffX write FOffX;
    property OffY: Double   read FOffY write FOffY;
    property Height: Double read FHeight write FHeight;
    property Mult: Double   read FMult write FMult;

    property CurrPos: PPoint2D read GetCurrPos;
  end;




constructor TUdShxParams.Create;
begin
  FPntsStack := TPoint2DStack.Create(100);
  FPntsStack.Push(NewPoint2D(0.0, 0.0));
  FDrawMode := 1;
  FNextCmd := True;

  FChar := #0;
  FMult := 1;
  FOffX := 0;
  FOffY := 0;
  FHeight := 16;

  FCurPnts  := TPoint2DList.Create(100);
  FConnLines := nil;
end;

destructor TUdShxParams.Destroy;
begin
  FCurPnts.Free;
  FCurPnts := nil;

  FConnLines := nil;

  FPntsStack.Free;
  FPntsStack := nil;

  inherited;
end;


function TUdShxParams.GetCurrPos: PPoint2D;
begin
  if FPntsStack.Count <= 0 then
    FPntsStack.Push(NewPoint2D(0.0, 0.0));

  Result := FPntsStack.Peek();
end;


procedure TUdShxParams.StartShape();
var
  LPnt: PPoint2D;
begin
  FCurPnts.Clear;

  LPnt := Self.GetCurrPos();
  FCurPnts.Add( Point2D(LPnt^.X + FOffX, LPnt^.Y) );   //    Point2D(0, 0)
end;



procedure TUdShxParams.FinishShape();
begin
  if (FCurPnts.Count > 1) then
  begin
    System.SetLength(FConnLines, System.Length(FConnLines) + 1);
    FConnLines[High(FConnLines)] := FCurPnts.ToArray();
  end;
end;

procedure TUdShxParams.Scale(Base: TPoint2D; Sx, Sy: Double; N1, N2: Integer);
var
  I, J: Integer;
begin
  if (Sx <= 0.0) or (Sy <= 0.0) or (IsEqual(Sx, 1.0) and IsEqual(Sy, 1.0)) then Exit;
  if (N2 < N1) or (N1 < 0) or (N2 >= System.Length(FConnLines)) then Exit;


  for I := N1 to N2 do
  begin
    for J := 0 to System.Length(FConnLines[I]) - 1 do
    begin
      FConnLines[I][J] := UdGeo2D.Scale(Base, Sx, Sy, FConnLines[I][J]);
    end;
  end;
end;

procedure TUdShxParams.Offset(Dx, Dy: Double; N1, N2: Integer);
var
  I, J: Integer;
begin
  if IsEqual(Dx, 0.0) and IsEqual(Dy, 0.0) then Exit;
  if (N2 < N1) or (N1 < 0) or (N2 >= System.Length(FConnLines)) then Exit;


  for I := N1 to N2 do
  begin
    for J := 0 to System.Length(FConnLines[I]) - 1 do
    begin
      FConnLines[I][J].X := FConnLines[I][J].X + Dx;
      FConnLines[I][J].Y := FConnLines[I][J].Y + Dy;
    end;
  end;
end;

procedure TUdShxParams.Rotate(Base: TPoint2D; Rota: Double; N1, N2: Integer);
var
  I: Integer;
begin
  if IsEqual(Rota, 0.0) then Exit;
  if (N2 < N1) or (N1 < 0) or (N2 >= System.Length(FConnLines)) then Exit;

  for I := N1 to N2 do
    FConnLines[I] := UdGeo2D.Rotate(Base, Rota, FConnLines[I]);
end;


procedure TUdShxParams.LineTo(X, Y: Double);
var
  LCurPnt: PPoint2D;
  LPnt, LPnt1, LPnt2: TPoint2D;
begin
  LPnt := Point2D(X, Y);
  LCurPnt := GetCurrPos();

  LPnt1 := LCurPnt^;
  LPnt2 := LPnt;

  LCurPnt^.X := LPnt.X;
  LCurPnt^.Y := LPnt.Y;

  if (FDrawMode = 0) then
  begin
    if (FCurPnts.Count > 0) then
    begin
      System.SetLength(FConnLines, System.Length(FConnLines) + 1);
      FConnLines[High(FConnLines)] := FCurPnts.ToArray();
    end;

    FCurPnts.Clear();

    Exit; //======>>>
  end;

  LPnt1.X := LPnt1.X + FOffX;
  LPnt1.Y := LPnt1.Y {+ FOffY};

  LPnt2.X := LPnt2.X + FOffX;
  LPnt2.Y := LPnt2.Y {+ FOffY};

  if (FCurPnts.Count <= 0) or NotEqual(FCurPnts.GetPoint(FCurPnts.Count-1), LPnt1) then
    FCurPnts.Add( LPnt1 );

  if (FCurPnts.Count <= 0) or NotEqual(FCurPnts.GetPoint(FCurPnts.Count-1), LPnt2) then
    FCurPnts.Add( LPnt2 );
end;




//==================================================================================================
{ TUdShx }

constructor TUdShx.Create;
begin
  FBigFile := '';
  FShxFile := '';

  FBigOutLines := nil;
  FShxOutLines := nil;

  FCalcBigMode := False;
end;

destructor TUdShx.Destroy;
begin
  if Assigned(FBigOutLines) then FBigOutLines.Free;
  if Assigned(FShxOutLines) then FShxOutLines.Free;

  FBigOutLines := nil;
  FShxOutLines := nil;

  FBigFile := '';
  FShxFile := '';

  inherited;
end;



//---------------------------------------------------------------------------------------------

function TUdShx.GetAscent: Double;
begin
  if (FShxOutLines = nil) then
    Result := 1.0
  else
    Result := FShxOutLines.Above;
end;

function TUdShx.GetDescent: Double;
begin
  if (FShxOutLines = nil) then
    Result := 0.0
  else
    Result := FShxOutLines.Below;
end;



procedure TUdShx.SetBigFile(const AValue: string);

  function _CalcBigAbove(AIdx: Integer): Integer;
  var
    I: Integer;
    LRect, LRect1: TRect2D;
    LShxParams: TUdShxParams;
  begin
    Result := 0;
    
    FCalcBigMode := True;
    LShxParams := TUdShxParams.Create;
    try
      LShxParams.FOffX := 0.0;
      LShxParams.FOffY := 0.0;
      LShxParams.FMult := 1.0;

      Self.DrawShape(FBigOutLines.Structs[AIdx].Num, LShxParams);

      if Length(LShxParams.FConnLines) > 0 then
      begin
        LRect := UdGeo2D.RectHull(LShxParams.FConnLines[0]);

        for I := 1 to Length(LShxParams.FConnLines) - 1 do
        begin
          LRect1 := UdGeo2D.RectHull(LShxParams.FConnLines[I]);

          if LRect1.Y1 < LRect.Y1 then LRect.Y1 := LRect1.Y1;
          if LRect1.Y2 > LRect.Y2 then LRect.Y2 := LRect1.Y2;
        end;

        Result := Trunc(LRect.Y2 + LRect.Y1);
      end;
    finally
      LShxParams.Free;
      FCalcBigMode := False;
    end;
  end;

var
  I: Integer;
  LAbove: Integer;
begin
  if Trim(AValue) = '' then
  begin
    if Assigned(FBigOutLines) then FBigOutLines.Free;
    FBigOutLines := nil;

    FBigFile := '';
    Exit; //=======>>>>
  end;

  
  if not SysUtils.FileExists(AValue) then Exit;

  if IsBigFont(AValue) then
  begin
    FBigFile := AValue;
    if Assigned(FBigOutLines) then FBigOutLines.Free;
    FBigOutLines := ProcessBig(AValue, osdefault);
  end;

  if FBigOutLines.Above = 0 then
  begin
    for I := 0 to Min(3, Length(FBigOutLines.Structs)) - 1 do
    begin
      LAbove := _CalcBigAbove(I);
      if I = 0 then FBigOutLines.Above := LAbove else
      begin
        if LAbove > FBigOutLines.Above then FBigOutLines.Above := LAbove;
      end;
    end;
  end;  
end;

procedure TUdShx.SetShxFile(const AValue: string);
begin
  if not SysUtils.FileExists(AValue) then Exit;

  if IsNormalFont(AValue) then
  begin
    FShxFile := AValue;
    if Assigned(FShxOutLines) then FShxOutLines.Free;
    FShxOutLines := ProcessNormal(AValue);
  end
  else
  if IsUnicodeFont(AValue) then
  begin
    FShxFile := AValue;
    if Assigned(FShxOutLines) then FShxOutLines.Free;
    FShxOutLines := ProcessUnicode(AValue);
  end;
end;




//-------------------------------------------------------------------------------------------------

function ReadNullString(AStream: TMemoryStream): string;
var
  N, M: Integer;
  LText: AnsiString;
begin
  N := AStream.Position;
  M := 0;
  while ByteFromStream(AStream) <> 0 do Inc(M);
  AStream.Seek(N, soFromBeginning);

  System.SetLength(LText, M);
  AStream.ReadBuffer(LText[1], M);

  ByteFromStream(AStream);

  Result := string(LText);
end;

class function TUdShx.IsNormalFont(AStream: TMemoryStream): Boolean;
var
  LText: string;
begin
  AStream.Seek(0, soFromBeginning);
  LText := ReadNullString(AStream);
  Result := (Pos(NORMAL_SHAPES_HEAD_1_1, LText) = 1) or (Pos(NORMAL_SHAPES_HEAD_1_0, LText) = 1) ;
end;

class function TUdShx.IsNormalFont(AFilename: string): Boolean;
var
  LStream: TMemoryStream;
begin
  Result := False;
  if not SysUtils.FileExists(AFilename) then Exit;

  LStream := TMemoryStream.Create;
  try
    LStream.LoadFromFile(AFilename);
    Result := IsNormalFont(LStream);
  finally
    LStream.Free;
  end;
end;




class function TUdShx.IsBigFont(AStream: TMemoryStream): Boolean;
var
  LText: string;
begin
  AStream.Seek(0, soFromBeginning);
  LText := ReadNullString(AStream);
  Result := (Pos(BIG_SHAPES_HEAD_1_0, LText) = 1) ;
end;

class function  TUdShx.IsBigFont(AFilename: string): Boolean;
var
  LStream: TMemoryStream;
begin
  Result := False;
  if not SysUtils.FileExists(AFilename) then Exit;

  LStream := TMemoryStream.Create;
  try
    LStream.LoadFromFile(AFilename);
    Result := IsBigFont(LStream);
  finally
    LStream.Free;
  end;
end;

//


class function TUdShx.IsUnicodeFont(AStream: TMemoryStream): Boolean;
var
  LText: string;
begin
  AStream.Seek(0, soFromBeginning);
  LText := ReadNullString(AStream);
  Result := (Pos(UNI_SHAPES_HEAD_1_0, LText) = 1) ;
end;

class function TUdShx.IsUnicodeFont(AFilename: string): Boolean;
var
  LStream: TMemoryStream;
begin
  Result := False;
  if not SysUtils.FileExists(AFilename) then Exit;

  LStream := TMemoryStream.Create;
  try
    LStream.LoadFromFile(AFilename);
    Result := IsUnicodeFont(LStream);
  finally
    LStream.Free;
  end;
end;



//-------------------------------------------------------------------------------------------------

class function TUdShx.ProcessNormal(AStream: TMemoryStream): TUdShxOutLines;
var
  I: Integer;
  LNum, M: Word;
  LText: string;
  LArray: TByteDynArray;
  LShapeStruct: TUdShxStruct;
begin
  Result := TUdShxOutLines.Create;

  AStream.Seek(0, soFromBeginning);

  System.SetLength(LText, 28);
  AStream.ReadBuffer(LText[1], 28);

  LNum := WordFromStream(AStream);
  WordFromStream(AStream);

  System.SetLength(Result.Structs, (LNum - 1));
  System.SetLength(LArray, LNum);

  for I := 0 to LNum - 1 do
  begin
    if (I <> 0) then
    begin
      Result.Structs[I - 1].Num := WordFromStream(AStream);
      Result.Structs[I - 1].ONum := Result.Structs[I - 1].Num;
    end;
    LArray[I] := WordFromStream(AStream);
  end;

  for I := 0 to LNum - 1 do
  begin
    if (I = 0) then
    begin
      LShapeStruct.SpecBytes := BytesFromStream(AStream, LArray[I]);
      if (LArray[I] >= 4) then
      begin
        Result.Above := LShapeStruct.SpecBytes[LArray[I] - 4];
        Result.Below := LShapeStruct.SpecBytes[LArray[I] - 3];
      end;
    end
    else begin
      Result.Structs[I - 1].Name := ReadNullString(AStream);
      M := LArray[I];
      M := M - System.Length(Result.Structs[I - 1].Name) - 1;
      Result.Structs[I - 1].SpecBytes := BytesFromStream(AStream, M);
    end;
  end;
end;

class function TUdShx.ProcessNormal(AFilename: string): TUdShxOutLines;
var
  LStream: TMemoryStream;
begin
  Result := nil;
  LStream := TMemoryStream.Create;
  try
    LStream.LoadFromFile(AFilename);
    try
      Result := ProcessNormal(LStream);
    except
      if Assigned(Result) then Result.Free;
      Result := nil;
    end;
  finally
    LStream.Free;
  end;
end;


class function TUdShx.ProcessUnicode(AStream: TMemoryStream): TUdShxOutLines;
var
  I: Integer;
  M: Word;
  LNum: LongWord;
  LShapeStruct: TUdShxStruct;
begin
  Result := TUdShxOutLines.Create;

  AStream.Seek(25, soFromBeginning);
  LNum := CarFromStream(AStream);

  System.SetLength(Result.Structs, (LNum - 1));
  WordFromStream(AStream);

  ReadNullString(AStream);
  LShapeStruct.SpecBytes := BytesFromStream(AStream, 6);

  Result.Above := LShapeStruct.SpecBytes[0];
  Result.Below := LShapeStruct.SpecBytes[1];

  for I := 1 to LNum - 1 do
  begin
    Result.Structs[(I - 1)].Num := WordFromStream(AStream);
    Result.Structs[(I - 1)].ONum := Result.Structs[(I - 1)].Num;
    
    M := WordFromStream(AStream);
    Result.Structs[(I - 1)].Name := ReadNullString(AStream);

    M := M - System.Length(Result.Structs[(I - 1)].Name) - 1;
    Result.Structs[(I - 1)].SpecBytes := BytesFromStream(AStream, M);

    if (System.Length(Result.Structs[(I - 1)].SpecBytes) < M) then
    begin
      Result.Free;
      Result := nil;

      Break;
    end;
  end;
end;

class function TUdShx.ProcessUnicode(AFilename: string): TUdShxOutLines;
var
  LStream: TMemoryStream;
begin
  Result := nil;

  LStream := TMemoryStream.Create;
  try
    LStream.LoadFromFile(AFilename);
    try
      Result := ProcessUnicode(LStream);
    except
      if Assigned(Result) then Result.Free;
      Result := nil;
    end;
  finally
    LStream.Free;
  end;
end;




function AsWinCodePage(ACodePage: TUdCodePage): Integer;
var
  M, N: Integer;
begin
  M := 45;
  N := Ord(ACodePage);
  N := Max(0, N);
  N := Min(M, N);
  Result := WIN_CODES[N];
end;


function ConvertBigFontNumber(AOldNum: Word; ACodePage: UINT): Word;
var
  LChars: TUdWideChars;
  LBytes: TByteDynArray;
begin
  if (AOldNum < 255) {or (ACodePage = 0)}  then
  begin
    Result := AOldNum;
    Exit;  //=======>>>
  end;

  if (AOldNum > 33090) and (AOldNum < 33402) then
  begin
    if AOldNum > 0 then ;
  end;

  System.SetLength(LBytes, 2);
  LBytes[0] := Byte((AOldNum shr 8) and 255);
  LBytes[1] := Byte(AOldNum);

  LChars := GetCharsFromBytes(ACodePage, LBytes, 0, System.Length(LBytes));

  if (LChars = nil) or (System.Length(LChars) <>  1) then
    Result := AOldNum
  else
    Result := Ord(LChars[0]);
end;



class function TUdShx.ProcessBig(AStream: TMemoryStream; ACodePage: TUdCodePage): TUdShxOutLines;
var
  I: Integer;
  LText: string;
  LPos: Cardinal;
  LNum1: Integer;
  LNum2: Int64;
  LNum3, LNum4, LNum5: LongWord;
  LNum6, LNum7, LCount: Word;
  LShapeStruct: TUdShxStruct;
  LCodePage: Integer;
begin
  LCodePage := AsWinCodePage(ACodePage);

  Result := TUdShxOutLines.Create;

  LNum2 := Cardinal(-1);

  LNum3 := 0;
  LNum4 := 0;

  AStream.Seek(29, soFromBeginning);

  LCount := WordFromStream(AStream);
  System.SetLength(Result.Ranges, LCount);

  for I := 0 to LCount - 1 do
  begin
    Result.Ranges[I].iBegin := SmallIntFromStream(AStream);
    Result.Ranges[I].iEnd   := SmallIntFromStream(AStream);
  end;

  LPos := AStream.Position;

  while (True) do
  begin
    LNum6 := WordFromStream(AStream);
    WordFromStream(AStream);
    LNum5 := CarFromStream(AStream);

    if (LNum4 = 0) then LNum2 := LNum5;

    if (AStream.Position > LNum2) then break;

    if (LNum4 <= 0) or (LNum6 <> 0) then
    begin
      if (LNum6 > 0) then
        LNum3 := LNum3 + 1;
      LNum4 := LNum4 + 1;
    end;
  end;

  System.SetLength(Result.Structs, LNum3);

  AStream.Seek(LPos, soFromBeginning);

  LNum3 := 0;
  LNum4 := 0;
  while (True) do
  begin
    LNum6 := WordFromStream(AStream);
    LNum7 := WordFromStream(AStream);
    LNum5 := CarFromStream(AStream);

    if (LNum4 = 0) then LNum2 := LNum5;

    LPos := AStream.Position;
    if (LPos > LNum2) then break;

    if (LNum4 <= 0) or (LNum6 <> 0) then
    begin
      AStream.Seek(LNum5, soFromBeginning);

      if (LNum6 > 0) then
      begin
        Result.Structs[(LNum3)].Num := ConvertBigFontNumber(LNum6, LCodePage);
        Result.Structs[(LNum3)].ONum := LNum6;
        
        LNum1 := 0;
        while (ByteFromStream(AStream) <> 0) do Inc(LNum1);

        AStream.Seek(-(LNum1 + 1), soFromCurrent);
        if (LNum1 > 0) then
        begin
          System.SetLength(LText, LNum1 + 1);
          AStream.ReadBuffer(LText[1], LNum1 + 1);

          Result.Structs[(LNum3)].Name := Trim(LText);
          LNum7 := LNum7 - (LNum1 + 1);
        end;

        Result.Structs[(LNum3)].SpecBytes := BytesFromStream(AStream, LNum7);
        LNum3 := LNum3 + 1;
      end
      else begin
        LShapeStruct.Num := LNum6;
        LNum1 := 0;
        while (ByteFromStream(AStream) <> 0) do Inc(LNum1);

        AStream.Seek(-(LNum1 + 1), soFromCurrent);
        if (LNum1 > 0) then
        begin
          System.SetLength(LText, LNum1 + 1);
          AStream.ReadBuffer(LText[1], LNum1 + 1);

          LShapeStruct.Name := Trim(LText);
          LNum7 := LNum7 - (LNum1 + 1);
        end;

        LShapeStruct.SpecBytes := BytesFromStream(AStream, LNum7);
        Result.Above := LShapeStruct.SpecBytes[0];
        Result.Below := 0;

//        Result.Below := LShapeStruct.SpecBytes[1];
//        if Result.Below > Result.Above then
//          Swap(Result.Above, Result.Below );
//
//        Result.Above := LShapeStruct.SpecBytes[1];
//        Result.Below := LShapeStruct.SpecBytes[2];
      end;

      AStream.Seek(LPos, soFromBeginning);
      LNum4 := LNum4 + 1;
    end;
  end;
end;

class function TUdShx.ProcessBig(AFilename: string; ACodePage: TUdCodePage): TUdShxOutLines;
var
  LStream: TMemoryStream;
begin
  Result := nil;
  LStream := TMemoryStream.Create;
  try
    LStream.LoadFromFile(AFilename);
    try
      Result := ProcessBig(LStream, ACodePage);
    except
      if Assigned(Result) then Result.Free;
      Result := nil;
    end;
  finally
    LStream.Free;
  end;
end;



//-------------------------------------------------------------------------------------------------

class function TUdShx.FindShape(AShapeNum: Word; AOutlines: TUdShxOutLines; AONum: Boolean = False): Integer;
var
  I: Integer;
begin
  Result := -1;
  if (AOutlines <> nil) then
  begin
    if AONum then
    begin
      for I := 0 to System.Length(AOutlines.Structs) - 1 do
      begin
        if (AOutlines.Structs[I].ONum = AShapeNum) then
        begin
          Result := I;
          Break;
        end;
      end;
    end
    else begin
      for I := 0 to System.Length(AOutlines.Structs) - 1 do
      begin
        if (AOutlines.Structs[I].Num = AShapeNum) then
        begin
          Result := I;
          Break;
        end;
      end;
    end;
  end;

  (*
  if Result < 0 then
  begin
    if (tryANSIconvert and AShapeNum > 255 and this.mOwnerStyle != null) then
    begin
      int num = grTextStyle.asWinCodePage(this.mOwnerStyle.BigShxDrawingCodePage.GetHashCode());
      if (num > 0) then
      begin
        Encoding encoding = Encoding.GetEncoding(num);
        byte[] bytes = encoding.GetBytes(new char[]
          {
            (char)AShapeNum
          }
        );
        if (bytes.Length == 1)
        begin
          return this.FindShape((ushort)bytes[0], outlines, false);
        end;
      end;
    end;
  end;
  *)
end;


function Fixbyte(AByte: Byte): Integer;
begin
  if (AByte < $80) then
    Result := AByte
  else
    Result := (AByte - $100);
end;

function DivRem(X: Double; Y: Double): Integer;
begin
  Result := Trunc(X - ((Trunc(X / Y)) * Y));
end;


procedure TUdShx.DrawShape(AShapeNum: Word; AParam: TObject; AONum: Boolean = False; AMult: PFloat = nil);
var
  _Mult: Double;
  _ShxParam: TUdShxParams;

  procedure _Case12And13(var N: Integer; var ACurrPos: PPoint2D; var AShapestruct: TUdShxStruct);
  var
    I, K: Integer;
    LRad: Double;
    LAltitude: Double;
    LAng1, LAng2: Double;
    LVar1, LVar2: Double;
    LBulge, LChord: Double;
    LDa, LEa, LSa: Double;
    LDx, LDy, LCx, LCy: Double;
  begin
    LBulge := Fixbyte(AShapestruct.SpecBytes[(N + 3)]) / 127.0;
    LDx := Fixbyte(AShapestruct.SpecBytes[(N + 1)]) * _Mult;
    LDy := Fixbyte(AShapestruct.SpecBytes[(N + 2)]) * _Mult;
    LChord := Sqrt(LDx * LDx + LDy * LDy);
    if IsEqual(LBulge, 0.0) then
    begin
      if (_ShxParam.FNextCmd) then
        _ShxParam.LineTo(Fixbyte(AShapestruct.SpecBytes[(N + 1)]) * _Mult + ACurrPos.X,
                         Fixbyte(AShapestruct.SpecBytes[(N + 2)]) * _Mult + ACurrPos.Y);
    end
    else begin
      if (LChord > 1E-08) then
      begin
        LAltitude := Abs(LBulge * LChord / 2.0);
        LVar1 := (LChord / 2.0) * (LChord / 2.0);
        LVar2 := LAltitude * LAltitude;
        LRad := Abs((LVar1 + LVar2) / (LAltitude * 2.0));
        LAng1 := Arctan(Abs(LBulge)) * 4.0;
        LAng1 := RFixAngle(LAng1);
        LAng2 := Arctan2(LDy, LDx);
        if (LAltitude <= LRad) then
        begin
          if (LBulge < 0.0) then
          begin
            LCx := Cos(LAng2 - (PI - LAng1) / 2.0) * LRad + ACurrPos.X;
            LCy := Sin(LAng2 - (PI - LAng1) / 2.0) * LRad + ACurrPos.Y;
          end
          else begin
            LCx := Cos(LAng2 + (PI - LAng1) / 2.0) * LRad + ACurrPos.X;
            LCy := Sin(LAng2 + (PI - LAng1) / 2.0) * LRad + ACurrPos.Y;
          end;
        end
        else begin
          if (LBulge < 0.0) then
          begin
            LCx := Cos(LAng2 - LAng1 / 2.0) * LRad + ACurrPos.X;
            LCy := Sin(LAng2 - LAng1 / 2.0) * LRad + ACurrPos.Y;
          end
          else begin
            LCx := Cos(LAng2 + LAng1 / 2.0) * LRad + ACurrPos.X;
            LCy := Sin(LAng2 + LAng1 / 2.0) * LRad + ACurrPos.Y;
          end;
        end;

        if (LBulge > 0.0) then
        begin
          LSa := Arctan2(ACurrPos.Y - LCy, ACurrPos.X - LCx);
          LEa := Arctan2(ACurrPos.Y + LDy - LCy, ACurrPos.X + LDx - LCx);
        end
        else begin
          LEa := Arctan2(ACurrPos.Y - LCy, ACurrPos.X - LCx);
          LSa := Arctan2(ACurrPos.Y + LDy - LCy, ACurrPos.X + LDx - LCx);
        end;

        LDa := LEa - LSa;
        LDa := RFixAngle(LDa);
        if IsEqual(LDa, 0.0) then
          LDa := LDa + _2PI;

        K := 0;
        if (LBulge < 0.0) then K := NUM_DIV;

        for I := 0 to NUM_DIV do
        begin
          _ShxParam.LineTo(Cos(LSa + LDa * K / NUM_DIV) * LRad + LCx,
                          Sin(LSa + LDa * K / NUM_DIV) * LRad + LCy);
          if (LBulge < 0.0) then Dec(K) else Inc(K);
        end;
        if (LBulge > 0.0) then
        begin
          ACurrPos.X := Cos(LEa) * LRad + LCx;
          ACurrPos.Y := Sin(LEa) * LRad + LCy;
        end
        else begin
          ACurrPos.X := Cos(LSa) * LRad + LCx;
          ACurrPos.Y := Sin(LSa) * LRad + LCy;
        end;
      end
      else
        _ShxParam.FNextCmd := False;
    end;
    Inc(N, 3);
  end;

var
  I: Integer;
  K, N: Integer;
  LType, LMode: Integer;
  LShapeNum: Word;
  LFoct, LNoct: Integer;
  LRad, LCx, LCy: Double;
  LDa, LEa, LSa: Double;
  LAngle, LDirect, LFactor: Double;
  LOffX, LOffY, LLen: Double;
  LCurrPos: PPoint2D;
  LIsNegative: Boolean;
  LShapeStruct: TUdShxStruct;
begin
  if not Assigned(AParam) then Exit;

  _ShxParam := TUdShxParams(AParam);
  if Assigned(AMult) then _Mult := AMult^ else _Mult := _ShxParam.Mult;

  if FCalcBigMode then
  begin
    N := FindShape(AShapeNum, FBigOutLines, AONum);
    if N >= 0 then LShapeStruct := FBigOutLines.Structs[N];
  end
  else begin
    N := FindShape(AShapeNum, FShxOutLines, AONum);

    if (N = -1) then
    begin
      N := FindShape(AShapeNum, FBigOutLines, AONum);
      
      if (N = -1) then
      begin
        if (N = -1) then
          N := FindShape(63, FShxOutLines);

        if (N = -1) then Exit;  //====>>>>

        LShapeStruct := FShxOutLines.Structs[N];
      end
      else begin
        LShapeStruct := FBigOutLines.Structs[N];

        if not Assigned(AMult) and NotEqual(FBigOutLines.Above, 0.0) then
        begin
          LFactor := Abs(FBigOutLines.Above/Self.Ascent);
          _Mult := (_ShxParam.Mult / LFactor);
        end;
      end;
    end
    else begin
      LShapeStruct := FShxOutLines.Structs[N];
    end;
  end;

	if System.Length(LShapeStruct.SpecBytes) <= 0 then Exit;  //====>>>>


	if (_ShxParam.FPntsStack.Count <= 0) then
		_ShxParam.FPntsStack.Push(NewPoint2D(0.0, 0.0));

	N := 0;

	while (N < (System.Length(LShapeStruct.SpecBytes) - 1)) do
	begin
		case LShapeStruct.SpecBytes[N] of
		  0:
			begin
				_ShxParam.FNextCmd := True;
			end;

			1:
			begin
				if (_ShxParam.FDrawMode <> 1) then
				begin
					if (_ShxParam.FNextCmd) then
						_ShxParam.FDrawMode := 1;
					_ShxParam.FNextCmd := True;
				end;
			end;

			2:
			begin
				if (_ShxParam.FNextCmd) then
					_ShxParam.FDrawMode := 0;
				_ShxParam.FNextCmd := True;
			end;

			3:
			begin
				if (_ShxParam.FNextCmd) then
					_Mult := _Mult / Fixbyte(LShapeStruct.SpecBytes[(N + 1)]);
				Inc(N);
				_ShxParam.FNextCmd := True;
			end;

			4:
			begin
				if (_ShxParam.FNextCmd) then
					_Mult := _Mult * Fixbyte(LShapeStruct.SpecBytes[(N + 1)]);
				Inc(N);
				_ShxParam.FNextCmd := True;
			end;

			5:
			begin
				if (_ShxParam.FNextCmd) then
					_ShxParam.FPntsStack.Push(NewPoint2D(_ShxParam.CurrPos.X, _ShxParam.CurrPos.Y));
				_ShxParam.FNextCmd := True;
			end;

			6:
			begin
				if (_ShxParam.FNextCmd) then
        begin
					LCurrPos := _ShxParam.FPntsStack.Pop();
          if Assigned(LCurrPos) then Dispose(LCurrPos);
        end;
				_ShxParam.FNextCmd := True;
			end;

			7:
			begin
				if (LShapeStruct.SpecBytes[(N + 1)] <> 0) then
				begin
					LShapeNum := LShapeStruct.SpecBytes[(N + 1)];
					if (_ShxParam.FNextCmd and (LShapeNum <> AShapeNum)) then
					begin
						LOffX := _ShxParam.FOffX;
						LOffY := _ShxParam.FOffY;
            try
					  	DrawShape(LShapeNum, _ShxParam, AONum, @_Mult);
            finally
					   	_ShxParam.FOffX := LOffX;
						  _ShxParam.FOffY := LOffY;
            end;
					end;
					Inc(N);
				end
				else begin
					LShapeNum := LShapeStruct.SpecBytes[(N + 2)];
					if (_ShxParam.FNextCmd and (LShapeNum <> AShapeNum)) then
					begin
						LOffX := _ShxParam.FOffX;
						LOffY := _ShxParam.FOffY;
            LMode := _ShxParam.FDrawMode;
            try
              _ShxParam.FDrawMode := 1;
					   	DrawShape(LShapeNum, _ShxParam, AONum, @_Mult);
            finally
              _ShxParam.FDrawMode := LMode;
              _ShxParam.FOffX := LOffX;
              _ShxParam.FOffY := LOffY;
            end;
					end;
					Inc(N, 2);
				end;

				_ShxParam.FNextCmd := True;
			end;

			8:
			begin
				if (_ShxParam.FNextCmd) then
				begin
					LCurrPos := _ShxParam.CurrPos;
					_ShxParam.LineTo(Fixbyte(LShapeStruct.SpecBytes[(N + 1)]) * _Mult + LCurrPos.X,
                           Fixbyte(LShapeStruct.SpecBytes[(N + 2)]) * _Mult + LCurrPos.Y);
				end;
				Inc(N, 2);
				_ShxParam.FNextCmd := True;
			end;

			9:
			begin
				repeat
					if (_ShxParam.FNextCmd) then
					begin
						LCurrPos := _ShxParam.CurrPos;
						_ShxParam.LineTo(Fixbyte(LShapeStruct.SpecBytes[(N + 1)]) * _Mult + LCurrPos.X,
                             Fixbyte(LShapeStruct.SpecBytes[(N + 2)]) * _Mult + LCurrPos.Y);
					end;
					Inc(N, 2);
				until ((LShapeStruct.SpecBytes[(N - 1)] = 0) and (LShapeStruct.SpecBytes[N] = 0));
				_ShxParam.FNextCmd := True;
			end;

			10:
			begin
				LCurrPos := _ShxParam.CurrPos;
				LIsNegative := (LShapeStruct.SpecBytes[(N + 2)] > 127);
				if (LIsNegative) then
				begin
					LFoct := Trunc((LShapeStruct.SpecBytes[(N + 2)] - 128) / 16);
					LNoct := DivRem((LShapeStruct.SpecBytes[(N + 2)] - 128), 16.0);
				end
				else begin
					LFoct := Trunc((LShapeStruct.SpecBytes[(N + 2)]) / 16);
					LNoct := DivRem((LShapeStruct.SpecBytes[(N + 2)]), 16.0);
				end;

				LRad := Fixbyte(LShapeStruct.SpecBytes[(N + 1)]) * _Mult;
				LSa := LFoct * PI / 4.0;
				if (LIsNegative) then
					LEa := LSa - LNoct * PI / 4.0
				else
					LEa := LSa + LNoct * PI / 4.0;

				LSa := RFixAngle(LSa);
				LEa := RFixAngle(LEa);
				LCx := Cos(LSa + PI) * LRad + LCurrPos.X;
				LCy := Sin(LSa + PI) * LRad + LCurrPos.Y;

				if (LIsNegative) then Swap(LSa, LEa);

				if (_ShxParam.FNextCmd) then
				begin
					LDa := LEa - LSa;
					LDa := RFixAngle(LDa);
					if IsEqual(LDa, 0.0) then
						LDa := LDa + _2PI;
					K := 0;
					if (LIsNegative) then
						K := NUM_DIV;
					for I := 0 to NUM_DIV do
					begin
						_ShxParam.LineTo(Cos(LSa + LDa * K / NUM_DIV) * LRad + LCx,
                            Sin(LSa + LDa * K / NUM_DIV) * LRad + LCy);

						if (LIsNegative) then Dec(K) else Inc(K)
					end;

					if (LIsNegative) then
					begin
						LCurrPos.X := Cos(LSa) * LRad + LCx;
						LCurrPos.Y := Sin(LSa) * LRad + LCy;
					end
					else begin
						LCurrPos.X := Cos(LEa) * LRad + LCx;
						LCurrPos.Y := Sin(LEa) * LRad + LCy;
					end;
				end;

				Inc(N, 2);
				_ShxParam.FNextCmd := True;
			end;

			11:
			begin
				LCurrPos := _ShxParam.CurrPos;
				LIsNegative := (LShapeStruct.SpecBytes[(N + 5)] > 127);
				if (LIsNegative) then
				begin
					LFoct := Trunc((LShapeStruct.SpecBytes[(N + 5)] - 128) / 16);
					LNoct := DivRem((LShapeStruct.SpecBytes[(N + 5)] - 128), 16.0);
				end
				else begin
					LFoct := Trunc((LShapeStruct.SpecBytes[(N + 5)]) / 16);
					LNoct := DivRem((LShapeStruct.SpecBytes[(N + 5)]), 16.0);
				end;

				LRad := (Fixbyte(LShapeStruct.SpecBytes[(N + 3)]) * 255 + Fixbyte(LShapeStruct.SpecBytes[(N + 4)])) * _Mult;
				LSa := Fixbyte(LShapeStruct.SpecBytes[(N + 1)]) * 45.0 / 256.0 + LFoct * 45.0;
				LEa := Fixbyte(LShapeStruct.SpecBytes[(N + 2)]) * 45.0 / 256.0 + (LFoct + LNoct) * 45.0;
				LSa := Trunc(LSa + 0.5);
				LEa := Trunc(LEa + 0.5);
				LSa := LSa * _PiDiv180;
				LEa := LEa * _PiDiv180;
				LSa := RFixAngle(LSa);
				LEa := RFixAngle(LEa);
				LCx := Cos(LSa + PI) * LRad + LCurrPos.X;
				LCy := Sin(LSa + PI) * LRad + LCurrPos.Y;
				if (LIsNegative) then Swap(LSa, LEa);

				if (_ShxParam.FNextCmd) then
				begin
					LDa := LEa - LSa;
					LDa := RFixAngle(LDa);
					if IsEqual(LDa, 0.0) then LDa := LDa + _2PI;

					K := 0;
					if (LIsNegative) then K := NUM_DIV;

					for I := 0 to NUM_DIV do
					begin
						_ShxParam.LineTo(Cos(LSa + LDa * K / NUM_DIV) * LRad + LCx,
                            Sin(LSa + LDa * K / NUM_DIV) * LRad + LCy);
						if (LIsNegative) then Dec(K) else Inc(K);
					end;
					if (LIsNegative) then
					begin
						LCurrPos.X := Cos(LSa) * LRad + LCx;
						LCurrPos.Y := Sin(LSa) * LRad + LCy;
					end
					else begin
						LCurrPos.X := Cos(LEa) * LRad + LCx;
						LCurrPos.Y := Sin(LEa) * LRad + LCy;
					end;
				end;
				Inc(N, 5);
				_ShxParam.FNextCmd := True;
			end;

			12:
			begin
				LCurrPos := _ShxParam.CurrPos;
        _Case12And13(N, LCurrPos, LShapeStruct);
				_ShxParam.FNextCmd := True;
			end;

			13:
			begin
				LCurrPos := _ShxParam.CurrPos;
				repeat
          _Case12And13(N, LCurrPos, LShapeStruct);
				until ((LShapeStruct.SpecBytes[(N + 1)] = 0) and (LShapeStruct.SpecBytes[(N + 2)] = 0));

				Inc(N, 2);
				_ShxParam.FNextCmd := True;
			end;

			14:
			begin
				_ShxParam.FNextCmd := False;
			end;

			else begin
				LCurrPos := _ShxParam.CurrPos;
				if (_ShxParam.FNextCmd) then
				begin
          LDirect := Fixbyte(LShapeStruct.SpecBytes[N]) and 15;
          LLen :=  ((Fixbyte(LShapeStruct.SpecBytes[N]) and 240) shr 4) * _Mult;

					LAngle := 0.0;
					LType := DivRem(LDirect, 4.0);
					case (LType) of
						0:
						begin
							LAngle := _PiDiv2 * (LDirect / 4.0);
						end;
						1:
						begin
							LLen := LLen * Sqrt(1.25);
							LAngle := _PiDiv2 * ((LDirect - 1.0) / 4.0) + Arctan(0.5);
						end;
						2:
						begin
							LLen := LLen * Sqrt(2.0);
							LAngle := _PiDiv2 * ((LDirect - 2.0) / 4.0) + 0.78539816339745;
						end;
						3:
						begin
							LLen := LLen * Sqrt(1.25);
							LAngle := _PiDiv2 * ((LDirect - 3.0) / 4.0) + _PiDiv2 - Arctan(0.5);
						end;
					end;
					_ShxParam.LineTo(Cos(LAngle) * LLen + LCurrPos.X,
                          Sin(LAngle) * LLen + LCurrPos.Y);
				end;
				_ShxParam.FNextCmd := True;
			end;
		end;

		Inc(N);
	end;

	_ShxParam.FOffX := _ShxParam.FOffX + _ShxParam.CurrPos.X;
	_ShxParam.FOffY := _ShxParam.FOffY + _ShxParam.CurrPos.Y;
end;




function TUdShx.GetCharPolys(ACharCode: Integer; var AOfsX, AOfsY: Float; AHeight: Double; AWidthFactor: Double = 1.0): TPoint2DArrays;
var
  LShxParams: TUdShxParams;
begin
  LShxParams := TUdShxParams.Create;
  try
    LShxParams.FOffX := 0.0;
    LShxParams.FOffY := 0.0;

    LShxParams.FDrawMode := 1;
    LShxParams.FPntsStack.Clear();
    LShxParams.FPntsStack.Push(NewPoint2D(0.0, 0.0));
    LShxParams.FNextCmd := True;
    LShxParams.FHeight := AHeight;
//    LShxParams.FChar := LText[J];
    LShxParams.FMult := AHeight / Self.Ascent;

    LShxParams.StartShape();
    Self.DrawShape(ACharCode, LShxParams);
    LShxParams.FinishShape();

    if Length(LShxParams.FConnLines) > 0 then
    begin
      if (AWidthFactor > 0.0) then
        LShxParams.Scale(Point2D(0, 0), AWidthFactor, 1.0, 0, System.Length(LShxParams.FConnLines) - 1);

      LShxParams.Offset(AOfsX, AOfsY, 0, System.Length(LShxParams.FConnLines) - 1);
      AOfsX := AOfsX + LShxParams.FOffX * AWidthFactor;
    end;

    Result := LShxParams.FConnLines;
  finally
    LShxParams.Free;
  end;
end;


function ShxCharCode(AValue: WideChar): LongWord;
begin
  Result := Ord(AValue);
end;

function TUdShx.GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec;
                             var ATextWidth, ATextHeight: Float; var ATextBound: TPoint2DArray): TPoint2DArrays;


  function _CalcOffset(ALinesWidth: TFloatArray): TPoint2DArray;
  var
    I, L: Integer;
    LCenH, LMaxW: Float;
  begin
    Result := nil;

    L := System.Length(ALinesWidth);
    if L <= 0 then Exit;

    System.SetLength(Result, L);
    for I := 0 to L - 1 do Result[I] := Point2D(0, 0);

    if AStyle.Align in [taTopLeft, taTopCenter, taTopRight] then
    begin
      for I := 0 to L - 1 do
        Result[I].Y := (- I) * AHeight * AStyle.LineSpaceFactor - AHeight;
    end else
    if AStyle.Align in [taMiddleLeft, taMiddleCenter, taMiddleRight] then
    begin
      LCenH := (L * AHeight + (L - 1) * AHeight * AStyle.LineSpaceFactor) / 2;
      for I := 0 to L - 1 do
        Result[I].Y := (L - 1 - I) * AHeight * AStyle.LineSpaceFactor - LCenH;
    end else
    if AStyle.Align in [taBottomLeft, taBottomCenter, taBottomRight] then
    begin
      for I := 0 to L - 1 do
        Result[I].Y := (L - 1 - I) * AHeight * AStyle.LineSpaceFactor;
    end;

    LMaxW := ALinesWidth[0];
    for I := 1 to L - 1 do if ALinesWidth[I] > LMaxW then LMaxW := ALinesWidth[I];

    if AStyle.Align in [taTopCenter, taMiddleCenter, taBottomCenter] then
    begin
      for I := 0 to L - 1 do
        Result[I].X :=  (LMaxW - ALinesWidth[I]) / 2 - LMaxW/2;
    end else
    if AStyle.Align in [taTopRight, taMiddleRight, taBottomRight] then
    begin
      for I := 0 to L - 1 do
        Result[I].X :=  - ALinesWidth[I];
    end;
  end;

var
  I, J: Integer;
  LShxObj: TUdShx;
  LLn: TLine2D;
  LText: WideString;
  LShxParams: TUdShxParams;
  LStrings: TStringList;
  LCharCodes: TUdCharCodeArray;
  LLinesIndex: TPointArray;
  LLinesWidth: TFloatArray;
  LLinesOffset: TPoint2DArray;
  LTxtBound: TPoint2DArray;
  LTxtLeft, LTxtRight, LTxtTop, LTxtBottom, LTxtWidth: Float;
begin
  Result := nil;
  if AText = '' then Exit;

  LStrings := TStringList.Create;
  LShxParams := TUdShxParams.Create;
  try
    LStrings.Text := AText;
    if LStrings.Count > 0 then
    begin
      System.SetLength(LLinesWidth, LStrings.Count);
      System.SetLength(LLinesIndex, LStrings.Count);

      for I := 0 to LStrings.Count - 1 do
      begin
        LText := LStrings[I];
        LCharCodes := UdShx._GetCharCodes(LText, ShxCharCode);

        LShxParams.FOffX := 0.0;
        LShxParams.FOffY := 0.0;
        
        LLinesIndex[I].X := System.Length(LShxParams.FConnLines);


        for J := 0 to Length(LCharCodes) - 1 do
        begin
          LShxObj := nil;
          
          case LCharCodes[J].Kind of
            1: LShxObj := GetDefGdtShx();
            2: LShxObj := GetDefSimplexShx();
          end;
          
          if not Assigned(LShxObj) then LShxObj := Self;


          LShxParams.FDrawMode := 1;
          LShxParams.FPntsStack.Clear();
          LShxParams.FPntsStack.Push(NewPoint2D(0.0, 0.0));
          LShxParams.FNextCmd := True;
          LShxParams.FHeight := AHeight;
          LShxParams.FChar := LText[J];
          LShxParams.FMult := AHeight / LShxObj.Ascent;


          LShxParams.StartShape();
          LShxObj.DrawShape(LCharCodes[J].Value, LShxParams, LCharCodes[J].Kind = 3);
          LShxParams.FinishShape();
        end;


        LLinesIndex[I].Y := System.Length(LShxParams.FConnLines) - 1;

        if LLinesIndex[I].Y >= LLinesIndex[I].X then
          LLinesWidth[I] := LShxParams.FOffX * AStyle.WidthFactor //UdGeo2D.RighterPoint(LShxParams.FConnLines[LLinesIndex[I].Y]).X
        else
          LLinesWidth[I] := 0;
      end; {end for I}

      if AStyle.WidthFactor > 0.0 then
        LShxParams.Scale(Point2D(0, 0), AStyle.WidthFactor, 1.0, 0, System.Length(LShxParams.FConnLines) - 1);

      LLinesOffset := _CalcOffset(LLinesWidth);
      for I := 0 to System.Length(LLinesOffset) - 1 do
      begin
        LShxParams.Offset(APosition.X + LLinesOffset[I].X,  APosition.Y + LLinesOffset[I].Y,
                          LLinesIndex[I].X, LLinesIndex[I].Y);
      end;

      LTxtLeft := LLinesOffset[0].X;
      for I := 1 to System.Length(LLinesOffset) - 1 do
        if LLinesOffset[I].X < LTxtLeft then LTxtLeft := LLinesOffset[I].X;
      LTxtLeft  := APosition.X + LTxtLeft;

      LTxtWidth := LLinesWidth[0];
      for I := 1 to System.Length(LLinesWidth) - 1 do if LLinesWidth[I] > LTxtWidth then LTxtWidth := LLinesWidth[I];
      LTxtRight := LTxtLeft + LTxtWidth;

      LTxtTop    := APosition.Y + LLinesOffset[0].Y + AHeight;
      LTxtBottom := APosition.Y + LLinesOffset[High(LLinesOffset)].Y;

      System.SetLength(LTxtBound, 4);
      LTxtBound[0] := Point2D(LTxtLeft, LTxtBottom);
      LTxtBound[1] := Point2D(LTxtLeft, LTxtTop);
      LTxtBound[2] := Point2D(LTxtRight, LTxtTop);
      LTxtBound[3] := Point2D(LTxtRight, LTxtBottom);


      LTxtBound := UdGeo2D.Rotate(APosition, AStyle.Rotation, LTxtBound);
      LShxParams.Rotate(APosition, AStyle.Rotation, 0, System.Length(LShxParams.FConnLines) - 1);

      if AStyle.Backward then
      begin
        LLn := Line2D(APosition, UdGeo2D.ShiftPoint(APosition, AStyle.Rotation + 90, 100));
        for I := 0 to System.Length(LShxParams.FConnLines) - 1 do
          LShxParams.FConnLines[I] := UdGeo2D.Mirror(LLn, LShxParams.FConnLines[I]);

        LTxtBound := UdGeo2D.Mirror(LLn, LTxtBound);
      end;

      if AStyle.Upsidedown then
      begin
        LLn := Line2D(APosition, UdGeo2D.ShiftPoint(APosition, AStyle.Rotation, 100));
        for I := 0 to System.Length(LShxParams.FConnLines) - 1 do
          LShxParams.FConnLines[I] := UdGeo2D.Mirror(LLn, LShxParams.FConnLines[I]);

        LTxtBound := UdGeo2D.Mirror(LLn, LTxtBound);
      end;

      ATextBound := LTxtBound;
      ATextWidth := Abs(LTxtRight - LTxtLeft);
      ATextHeight := Abs(LTxtBottom - LTxtTop);

      Result := LShxParams.FConnLines;
    end;
  finally
    LStrings.Free;
    LShxParams.Free;
  end;
end;



function TUdShx.GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec; var ATextBound: TPoint2DArray): TPoint2DArrays;
var
  LTextWidth, LTextHeight: Float;
begin
  Result := GetTextPolys(AText, APosition, AHeight, AStyle, LTextWidth, LTextHeight, ATextBound);
end;

function TUdShx.GetTextPolys(AText: string; APosition: TPoint2D; AHeight: Double; AStyle: TUdTextStyleRec): TPoint2DArrays;
var
  LTxtBound: TPoint2DArray;
begin
  Result := GetTextPolys(AText, APosition, AHeight, AStyle, LTxtBound);
end;










//==================================================================================================


initialization
  GDefFontDir := SysUtils.ExtractFilePath(Application.ExeName) + 'Fonts';
  GGdtShx     := nil;
  GSimplexShx := nil;


finalization
  if Assigned(GGdtShx) then GGdtShx.Free;
  GGdtShx := nil;
  
  if Assigned(GSimplexShx) then GSimplexShx.Free;
  GSimplexShx := nil;



end.