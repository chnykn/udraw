{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdXml;

{$I UdDefs.INC}

{$IFDEF D2009UP}
   {$DEFINE Delphi12}
{$ENDIF}

interface

uses
  Windows, Classes
{$IFDEF Delphi12}
  , AnsiStrings
{$ENDIF};

type

  //*** TUdXmlNode ***//
  TUdXmlNode = class(TObject)
  private
    FData: Pointer;       // optional item data
    FItems: TList;        // subitems
    FName: string;        // item name
    FParent: TUdXmlNode;  // item parent
    FText: string;        // item attributes

  protected
    function GetRoot(): TUdXmlNode;
    function GetCount(): Integer;
    function GetItems(Index: Integer): TUdXmlNode;

    function GetProp(AIndex: string): string;
    procedure SetProp(AName: string; const AValue: string);
    procedure SetParent(const Value: TUdXmlNode);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure Assign(ANode: TUdXmlNode);

    function Add: TUdXmlNode;
    procedure AddItem(ANode: TUdXmlNode);
    procedure InsertItem(AIndex: Integer; ANode: TUdXmlNode);

    function Find(const AName: string): Integer;
    function FindItem(const AName: string; ACreateIfNoExists: Boolean = False): TUdXmlNode;

    function IndexOf(ANode: TUdXmlNode): Integer;
    function PropExists(const AName: string): Boolean;

  public
    property Root: TUdXmlNode read GetRoot;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TUdXmlNode read GetItems; default;

    property Name: string read FName write FName;
    property Parent: TUdXmlNode read FParent write SetParent;

    property Prop[Name: string]: string read GetProp write SetProp;
    property Text: string read FText write FText;

    property Data: Pointer read FData write FData;
  end;



  //*** TUdXMLDocument ***//
  TUdXMLDocument = class(TObject)
  private
    FRoot: TUdXmlNode;    // root item
    FAutoIndent: Boolean; // use indents when writing document to a file

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear();

    procedure SaveToStream(AStream: TStream);
    procedure LoadFromStream(AStream: TStream);

    procedure SaveToFile(const AFileName: string);
    procedure LoadFromFile(const AFileName: string);

  public
    property Root: TUdXmlNode read FRoot;
    property AutoIndent: Boolean read FAutoIndent write FAutoIndent;
  end;




  //------------------------------------------------------------

  //*** TUdXMLReader ***//
  TUdXMLReader = class(TObject)
  private
    FBuffer: PAnsiChar;
    FBufPos: Integer;
    FBufEnd: Integer;
    FPosition: Int64;
    FSize: Int64;
    FStream: TStream;

  protected
    procedure RaiseException;
    procedure SetPosition(const AValue: Int64);
    procedure ReadBuffer;
    procedure ReadItem(var AName: string; var AText: string);

  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;

    procedure ReadHeader();
    procedure ReadRootNode(ANode: TUdXmlNode);

    property Size: Int64 read FSize;
    property Position: Int64 read FPosition write SetPosition;
  end;



  //*** TUdXMLWriter ***//
  TUdXMLWriter = class(TObject)
  private
    FAutoIndent: Boolean;
    FBuffer: Ansistring;
    FStream: TStream;
    FTempStream: TStream;

  protected
    procedure FlushBuffer;
    procedure WriteLn(const AStr: Ansistring);
    procedure WriteItem(ANode: TUdXmlNode; ALevel: Integer = 0);

  public
    constructor Create(AStream: TStream);
    procedure WriteHeader;
    procedure WriteRootNode(ANode: TUdXmlNode);

    property TempStream: TStream read FTempStream write FTempStream;
  end;


// StrToXML changes '<', '>', '"', cr, lf symbols to its ascii codes
function StrToXML(const AStr: string): string;

// XMLToStr is opposite to StrToXML function
function XMLToStr(const AStr: string): string;

// ValueToXML convert a value to the valid XML string
function ValueToXML(const AValue: Variant): string;


implementation

uses
  SysUtils;



//==================================================================================================

function StrToXML(const AStr: string): string;
const
  SPEC_CHARS = ['<', '>', '"', #10, #13, '&'];
var
  I: Integer;

  procedure _ReplaceChars(var AStr: string; I: Integer);
  begin
    Insert('#' + IntToStr(Ord(AStr[I])) + ';', AStr, I + 1);
    AStr[I] := '&';
  end;

begin
  Result := AStr;

  for I := Length(AStr) downto 1 do
  begin
  {$IFDEF Delphi12}
    if CharInSet(AStr[I], SPEC_CHARS) then
  {$ELSE}
    if AStr[I] in SPEC_CHARS then
  {$ENDIF}
    begin
      if AStr[I] <> '&' then
        _ReplaceChars(Result, I)
      else
      begin
        if Copy(AStr, I + 1, 5) = 'quot;' then
        begin
          Delete(Result, I, 6);
          Insert('&#34;', Result, I);
        end;
      end;
    end;
  end;
end;

function XMLToStr(const AStr: string): string;
var
  I, J: Integer;
  N, L: Integer;
begin
  Result := AStr;

  I := 1;
  L := Length(AStr);
  while I < L do
  begin
    if Result[I] = '&' then
    begin
      if (I + 3 <= L) and (Result[I + 1] = '#') then
      begin
        J := I + 3;
        while Result[J] <> ';' do
          Inc(J);
        N := StrToInt(Copy(Result, I + 2, J - I - 2));
        Delete(Result, I, J - I);
        Result[I] := Chr(N);
        Dec(L, J - I);
      end
      else if Copy(Result, I + 1, 5) = 'quot;' then
      begin
        Delete(Result, I, 6);
        Result[I] := '"';
        Dec(L, 6);
      end;
    end;
    Inc(I);
  end;
end;

function ValueToXML(const AValue: Variant): string;
begin
  case TVarData(AValue).VType of
    varSmallint, varInteger, varByte:
      Result := IntToStr(Integer(AValue));

    varSingle, varDouble, varCurrency:
      Result := FloatToStr(Double(AValue));

    varDate:
      Result := DateToStr(TDateTime(AValue));

    varOleStr, varstring, varVariant{$IFDEF Delphi12}, varUstring{$ENDIF}:
      Result := StrToXML(AValue);

    varBoolean:
      if AValue = True then Result := '1' else Result := '0';

    else
      Result := '';
  end;
end;



//==================================================================================================
{ TUdXmlNode }

constructor TUdXmlNode.Create;
begin
  inherited;
  //....
end;


destructor TUdXmlNode.Destroy;
begin
  Self.Clear();
  if FParent <> nil then
    FParent.FItems.Remove(Self);
  inherited;
end;


procedure TUdXmlNode.Clear();
begin
  if FItems <> nil then
  begin
    while FItems.Count > 0 do
      TUdXmlNode(FItems[0]).Free;
    FItems.Free;
    FItems := nil;
  end;
end;

procedure TUdXmlNode.Assign(ANode: TUdXmlNode);

  procedure _Assign(AItemFrom, AItemTo: TUdXmlNode);
  var
    I: Integer;
  begin
    AItemTo.Name := AItemFrom.Name;
    AItemTo.Text := AItemFrom.Text;
    AItemTo.Data := AItemFrom.Data;
    for I := 0 to AItemFrom.Count - 1 do
      _Assign(AItemFrom[I], AItemTo.Add);
  end;

begin
  Self.Clear;
  if ANode <> nil then
    _Assign(ANode, Self);
end;



//-----------------------------------------------------------------------------

function TUdXmlNode.GetRoot(): TUdXmlNode;
begin
  Result := Self;
  while Result.Parent <> nil do
    Result := Result.Parent;
end;

function TUdXmlNode.GetCount(): Integer;
begin
  if FItems = nil then Result := 0 else Result := FItems.Count;
end;

function TUdXmlNode.GetItems(Index: Integer): TUdXmlNode;
begin
  Result := TUdXmlNode(FItems[Index]);
end;



function TUdXmlNode.GetProp(AIndex: string): string;
var
  I: Integer;
begin
  I := Pos(' ' + AnsiUppercase(AIndex) + '="', AnsiUppercase(' ' + FText));
  if I <> 0 then
  begin
    Result := Copy(FText, I + Length(AIndex + '="'), MaxInt);
    Result := XMLToStr(Copy(Result, 1, Pos('"', Result) - 1));
  end
  else
    Result := '';
end;

procedure TUdXmlNode.SetProp(AName: string; const AValue: string);
var
  I, J: Integer;
  LStr: string;
begin
  I := Pos(' ' + AnsiUppercase(AName) + '="', AnsiUppercase(' ' + FText));
  if I <> 0 then
  begin
    J := I + Length(AName + '="');
    while (J <= Length(FText)) and (FText[J] <> '"') do
      Inc(J);
    Delete(FText, I, J - I + 1);
  end
  else
    I := Length(FText) + 1;

  LStr := AName + '="' + StrToXML(AValue) + '"';
  if (I > 1) and (FText[I - 1] <> ' ') then LStr := ' ' + LStr;
  Insert(LStr, FText, I);
end;


procedure TUdXmlNode.SetParent(const Value: TUdXmlNode);
begin
  if FParent <> nil then
    FParent.FItems.Remove(Self);
  FParent := Value;
end;




//-----------------------------------------------------------------------------

function TUdXmlNode.Add(): TUdXmlNode;
begin
  Result := TUdXmlNode.Create;
  AddItem(Result);
end;

procedure TUdXmlNode.AddItem(ANode: TUdXmlNode);
begin
  if FItems = nil then
    FItems := TList.Create;

  FItems.Add(ANode);
  if ANode.FParent <> nil then
    ANode.FParent.FItems.Remove(ANode);

  ANode.FParent := Self;
end;

procedure TUdXmlNode.InsertItem(AIndex: Integer; ANode: TUdXmlNode);
begin
  AddItem(ANode);
  FItems.Delete(FItems.Count - 1);
  FItems.Insert(AIndex, ANode);
end;




//-----------------------------------------------------------------------------


function TUdXmlNode.Find(const AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if AnsiCompareText(Items[I].Name, AName) = 0 then
    begin
      Result := I;
      Break;
    end;
end;

function TUdXmlNode.FindItem(const AName: string; ACreateIfNoExists: Boolean = False): TUdXmlNode;
var
  N: Integer;
begin
  Result := nil;

  N := Self.Find(AName);
  if N = -1 then
  begin
    if ACreateIfNoExists then
    begin
      Result := Self.Add();
      Result.Name := AName;
    end;
  end
  else
    Result := Self.Items[N];
end;


function TUdXmlNode.IndexOf(ANode: TUdXmlNode): Integer;
begin
  Result := FItems.IndexOf(ANode);
end;

function TUdXmlNode.PropExists(const AName: string): Boolean;
begin
  Result := Pos(' ' + AnsiUppercase(AName) + '="', ' ' + AnsiUppercase(FText)) > 0;
end;





//==================================================================================================
{ TUdXMLDocument }

constructor TUdXMLDocument.Create;
begin
  FRoot := TUdXmlNode.Create;
  FAutoIndent := False;
end;

destructor TUdXMLDocument.Destroy;
begin
  FRoot.Free;
  inherited;
end;

procedure TUdXMLDocument.Clear;
begin
  FRoot.Clear();
end;


procedure TUdXMLDocument.SaveToStream(AStream: TStream);
var
  LWriter: TUdXMLWriter;
begin
  LWriter := TUdXMLWriter.Create(AStream);
  LWriter.FAutoIndent := FAutoIndent;

  try
    LWriter.WriteHeader;
    LWriter.WriteRootNode(FRoot);
  finally
    LWriter.Free;
  end;
end;

procedure TUdXMLDocument.LoadFromStream(AStream: TStream);
var
  LReader: TUdXMLReader;
begin
  LReader := TUdXMLReader.Create(AStream);
  try
    FRoot.Clear();
    LReader.ReadHeader;
    LReader.ReadRootNode(FRoot);
  finally
    LReader.Free;
  end;
end;

procedure TUdXMLDocument.SaveToFile(const AFileName: string);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(LFileStream);
  finally
    LFileStream.Free;
  end;
end;

procedure TUdXMLDocument.LoadFromFile(const AFileName: string);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(LFileStream);
  finally
    LFileStream.Free;
  end;
end;






//==================================================================================================
{ TUdXMLReader }

constructor TUdXMLReader.Create(AStream: TStream);
begin
  FStream := AStream;
  FSize := AStream.Size;
  FPosition := AStream.Position;
  GetMem(FBuffer, 4096);
end;

destructor TUdXMLReader.Destroy;
begin
  FreeMem(FBuffer, 4096);
  FStream.Position := FPosition;
  inherited;
end;

procedure TUdXMLReader.RaiseException;
begin
  raise Exception.Create('Invalid file format');
end;

procedure TUdXMLReader.SetPosition(const AValue: Int64);
begin
  FPosition := AValue;
  FStream.Position := AValue;
  FBufPos := 0;
  FBufEnd := 0;
end;


procedure TUdXMLReader.ReadBuffer;
begin
  FBufEnd := FStream.Read(FBuffer^, 4096);
  FBufPos := 0;
end;

procedure TUdXMLReader.ReadHeader;
var
  LStr1: string;
  LStr2: string;
begin
  ReadItem(LStr1, LStr2);
  if Pos('?xml', LStr1) <> 1 then
    Self.RaiseException();
end;

procedure TUdXMLReader.ReadItem(var AName: string; var AText: string);
var
  I: Integer;
  LByte: Byte;
  LCurPos, LLen, LComment: Integer;
  LState: (FindLeft, FindRight, FindComment, Done);
  LAnsiChar: PAnsiChar;
  LName: AnsiString;
begin
  AText := '';
  LComment := 0;
  LState := FindLeft;
  LCurPos := 0;
  LLen := 4096;
  SetLength(LName, LLen);
  LAnsiChar := @LName[1];

  while FPosition < FSize do
  begin
    if FBufPos = FBufEnd then
      ReadBuffer;
    LByte := Ord(FBuffer[FBufPos]);
    Inc(FBufPos);
    Inc(FPosition);

    if LState = FindLeft then
    begin
      if LByte = Ord('<') then
        LState := FindRight
    end
    else if LState = FindRight then
    begin
      if LByte = Ord('>') then
      begin
        LState := Done;
        Break;
      end
      else if LByte = Ord('<') then
        RaiseException
      else
      begin
        LAnsiChar[LCurPos] := AnsiChar(Chr(LByte));
        Inc(LCurPos);
        if (LCurPos = 3) and (Pos(Ansistring('!--'), LName) = 1) then
        begin
          LState := FindComment;
          LComment := 0;
          LCurPos := 0;
        end;
        if LCurPos >= LLen - 1 then
        begin
          Inc(LLen, 4096);
          SetLength(LName, LLen);
          LAnsiChar := @LName[1];
        end;
      end;
    end
    else if LState = FindComment then
    begin
      if LComment = 2 then
      begin
        if LByte = Ord('>') then
          LState := FindLeft
        else
          LComment := 0;
      end
      else begin
        if LByte = Ord('-') then
          Inc(LComment)
        else
          LComment := 0;
      end;
    end;
  end;

  LLen := LCurPos;
  SetLength(LName, LLen);

  if LState = FindRight then
    RaiseException;
  if (LName <> '') and (LName[LLen] = ' ') then
    SetLength(LName, LLen - 1);

  I := Pos(Ansistring(' '), LName);

  if I <> 0 then
  begin
  {$IFDEF Delphi12}
    AText := UTF8ToWideString(Copy(LName, I + 1, LLen - I));
  {$ELSE}
    AText := UTF8Decode(Copy(LName, I + 1, LLen - I));
  {$ENDIF}
    Delete(LName, I, LLen - I + 1);
  end;

{$IFDEF Delphi12}
  AName := string(LName);
{$ELSE}
  AName := LName;
{$ENDIF}
end;

procedure TUdXMLReader.ReadRootNode(ANode: TUdXmlNode);
var
  LastName: string;

  function _Read(ARootNode: TUdXmlNode): Boolean;
  var
    L: Integer;
    LDone: Boolean;
    LChildItem: TUdXmlNode;
  begin
    Result := False;
    ReadItem(ARootNode.FName, ARootNode.FText);
    LastName := ARootNode.FName;

    if (ARootNode.Name = '') or (ARootNode.Name[1] = '/') then
    begin
      Result := True;
      Exit;
    end;

    L := Length(ARootNode.Name);
    if ARootNode.Name[L] = '/' then
    begin
      SetLength(ARootNode.FName, L - 1);
      Exit;
    end;

    L := Length(ARootNode.Text);
    if (L > 0) and (ARootNode.Text[L] = '/') then
    begin
      SetLength(ARootNode.FText, L - 1);
      Exit;
    end;

    repeat
      LChildItem := TUdXmlNode.Create;
      LDone := _Read(LChildItem);
      if not LDone then
        ARootNode.AddItem(LChildItem) else
        LChildItem.Free;
    until LDone;

    if (LastName <> '') and (AnsiCompareText(LastName, '/' + ARootNode.Name) <> 0) then
      Self.RaiseException();
  end;

begin
  _Read(ANode);
end;





//==================================================================================================
{ TUdXMLWriter }

constructor TUdXMLWriter.Create(AStream: TStream);
begin
  FStream := AStream;
end;

procedure TUdXMLWriter.FlushBuffer;
begin
  if FBuffer <> '' then
    FStream.Write(FBuffer[1], Length(FBuffer));
  FBuffer := '';
end;

procedure TUdXMLWriter.WriteLn(const AStr: Ansistring);
begin
  if not FAutoIndent then
    Insert(AStr, FBuffer, MaxInt) else
    Insert(AStr + #13#10, FBuffer, MaxInt);
  if Length(FBuffer) > 4096 then
    FlushBuffer;
end;

procedure TUdXMLWriter.WriteHeader;
begin
  WriteLn('<?xml version="1.0"?>'); //<?xml version="1.0" encoding="UTF-8"?>
end;


function Dup(L: Integer): Ansistring; {$IFDEF SUPPORTS_INLINE} inline {$ENDIF}
begin
  SetLength(Result, L);
  FillChar(Result[1], L, ' ');
end;

procedure TUdXMLWriter.WriteItem(ANode: TUdXmlNode; ALevel: Integer = 0);
var
  LStr: Ansistring;
begin
  if ANode.FText <> '' then
  begin
//  {$IFDEF Delphi12}
    LStr := UTF8Encode(ANode.FText);
//  {$ELSE}
//    LStr := ANode.FText;
//  {$ENDIF}
    if (LStr = '') or (LStr[1] <> ' ') then
      LStr := ' ' + LStr;
  end
  else
    LStr := '';

  if ANode.Count = 0 then LStr := LStr + '/>' else LStr := LStr + '>';

  if not FAutoIndent then
    LStr := '<' + Ansistring(ANode.Name) + LStr
  else
    LStr := Dup(ALevel) + '<' + Ansistring(ANode.Name) + LStr;

  WriteLn(LStr);
end;

procedure TUdXMLWriter.WriteRootNode(ANode: TUdXmlNode);

  procedure _Write(ARootNode: TUdXmlNode; ALevel: Integer = 0);
  var
    I: Integer;
    LNeedClear: Boolean;
  begin
    LNeedClear := False;
    if not FAutoIndent then
      ALevel := 0;

    Self.WriteItem(ARootNode, ALevel);

    for I := 0 to ARootNode.Count - 1 do
      _Write(ARootNode[I], ALevel + 2);

    if ARootNode.Count > 0 then
    begin
      if not FAutoIndent then
        Self.WriteLn('</' + Ansistring(ARootNode.Name) + '>')
      else
        Self.WriteLn(Dup(ALevel) + '</' + Ansistring(ARootNode.Name) + '>');
    end;

    if LNeedClear then
      ARootNode.Clear;
  end;

begin
  _Write(ANode);
  Self.FlushBuffer();
end;



end.