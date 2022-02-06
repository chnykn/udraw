{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdTextStyles;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Types,
  UdConsts, UdIntfs, UdObject, UdTextStyle;

const
  DEFAULT_FONTS_DIR = 'Fonts';

type
  //*** TUdTextStyles ***//
  TUdTextStyles = class(TUdObject, IUdObjectCollection, IUdActiveSupport)
  private
    FList: TList;

    FActive: TUdTextStyle;

    FStandard: TUdTextStyle;
    FGdt     : TUdTextStyle;
    FLtype   : TUdTextStyle;

    FFontsDir: string;
    FShxFontNames: TStringList;
    FBigFontNames: TStringList;

    FTTFGdtFile: string;


    FOnAdd: TUdTextStyleEvent;
    FOnSelect: TUdTextStyleEvent;
    FOnRemove: TUdTextStyleAllowEvent;

  protected
    function GetTypeID: Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function GetCount: Integer;
    procedure SetItem(AIndex: Integer; const AValue: TUdTextStyle);

    procedure SetActive_(const AValue: TUdTextStyle);

    function InitShxFont(ATextStyle: TUdTextStyle; AInitBig: Boolean): Boolean;
    function InitFontNames(): Boolean;
    function InitDefaultStyles(): Boolean;

    function Init(): Boolean;

    procedure SetFontsDir(const AValue: string);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

    {$IFNDEF D2005UP}
    function GetItem_(AIndex: Integer): TUdTextStyle;
    {$ENDIF}

  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure Clear(All: Boolean = False);


    function IndexOf(AName: string): Integer; overload;

//    function Add(): TUdTextStyle; overload;
//    function Add(AName: string): TUdTextStyle; overload;
    function Add(AObject: TUdTextStyle): Boolean; overload;

    function Remove(AName: string): Boolean; overload;
    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AObject: TUdTextStyle): Boolean; overload;

    function GetItem(AName: string): TUdTextStyle; overload;
    function GetItem(AIndex: Integer): TUdTextStyle; overload;

    function SetActive(AIndex: Integer): Boolean; overload;
    function SetActive(AName: string): Boolean; overload;

    function GetActiveIndex(): Integer;


    //IUdObjectCollection ------------------
    function Add(AObj: TUdObject): Boolean; overload;
    function Insert(AIndex: Integer; AObj: TUdObject): Boolean; overload;

    function Remove(AObj: TUdObject): Boolean; overload;
    function RemoveAt(AIndex: Integer): Boolean;

    function IndexOf(AObj: TUdObject): Integer; overload;
    function Contains(AObj: TUdObject): Boolean;


    //-----------------------------------

    function GetShxFile(AShxName: string): string;

    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Items[Index: Integer]: TUdTextStyle read {$IFDEF D2005UP} GetItem {$ELSE} GetItem_ {$ENDIF} write SetItem;

    property ShxFontNames: TStringList read FShxFontNames;
    property BigFontNames: TStringList read FBigFontNames;

  published
    property Count: Integer read GetCount;

    property Active: TUdTextStyle read FActive write SetActive_;
    property Standard: TUdTextStyle read FStandard;

    property Gdt     : TUdTextStyle read FGdt;
    property Ltype   : TUdTextStyle read FLtype;

    property FontsDir: string read FFontsDir write SetFontsDir;

    property OnAdd: TUdTextStyleEvent read FOnAdd write FOnAdd;
    property OnSelect: TUdTextStyleEvent read FOnSelect write FOnSelect;
    property OnRemove: TUdTextStyleAllowEvent read FOnRemove write FOnRemove;

  end;

implementation

uses
  SysUtils, Forms,
  UdShx,  UdStreams, UdXml; //  UdTTF,

const
  STANDARD_NAME     = 'Standard';
  GDT_NAME          = '__gdt';
  LTYPE_NAME        = '__ltype';
  LTYPE_NAME2       = 'SHAPE0';

  NAME_PREFIX       = 'Style';

  SHX_GDT_FONT_FILE = 'GDT.SHX';
  TTF_GDT_FONT_FILE = 'AIGDT.TTF';

  SHX_LTYPE_FONT_FILE = 'LTYPESHP.SHX';



{ TUdTextStyles }

constructor TUdTextStyles.Create();
begin
  inherited;

  FTTFGdtFile := SysUtils.ExtractFilePath(Application.ExeName) + 'Fonts\' + TTF_GDT_FONT_FILE;
  if FileExists(FTTFGdtFile) then
  begin
    AddFontResource(PChar(FTTFGdtFile));
//    SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
  end;

  FStandard := nil;
  FGdt      := nil;
  FLtype    := nil;


  FList := TList.Create;
  FShxFontNames := TStringList.Create;
  FBigFontNames := TStringList.Create;

  FFontsDir := SysUtils.ExtractFilePath(Application.ExeName) + DEFAULT_FONTS_DIR;
  Self.Init();
end;

destructor TUdTextStyles.Destroy;
begin
  Clear(True);

  if Assigned(FList) then FList.Free;
  FList := nil;

  FStandard := nil;

  if Assigned(FGdt) then FGdt.Free;
  FGdt := nil;

  if Assigned(FLtype) then FLtype.Free;
  FLtype := nil;

  if Assigned(FList) then FList.Free;
  FList := nil;

  if Assigned(FShxFontNames) then FShxFontNames.Free;
  FShxFontNames := nil;

  if Assigned(FBigFontNames) then FBigFontNames.Free;
  FBigFontNames := nil;

  if FileExists(FTTFGdtFile) then
  begin
    RemoveFontResource(PChar(FTTFGdtFile));
//    SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
  end;

  inherited;
end;


procedure TUdTextStyles.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
var
  I: Integer;
begin
  inherited;

  for I := 0 to FList.Count - 1 do
  begin
    TUdObject(FList[I]).SetDocument(Self.Document, Self.IsDocRegister);
    Self.AddDocObject(TUdObject(FList[I]), False);
  end;

  if Assigned(FGdt) then
  begin
    FGdt.SetDocument(Self.Document, Self.IsDocRegister);
    Self.AddDocObject(FGdt, False);
  end;

  if Assigned(FLtype) then
  begin
    FLtype.SetDocument(Self.Document, Self.IsDocRegister);
    Self.AddDocObject(FLtype, False);
  end;
end;




function TUdTextStyles.GetTypeID: Integer;
begin
  Result := ID_TEXTTYLES;
end;

procedure TUdTextStyles.Clear(All: Boolean = False);
var
  I, N: Integer;
begin
  FActive := nil;

  if All then N := 0 else N := 1;
  for I := FList.Count - 1 downto N do
  begin
    Self.RemoveDocObject(TUdObject(FList[I]), False);
    FList.Delete(I);
  end;

  if All then
    FStandard := nil
  else
    FActive := FStandard;

  Self.RaiseChanged();
end;


{$IFNDEF D2005UP}
function TUdTextStyles.GetItem_(AIndex: Integer): TUdTextStyle;
begin
  Result := Self.GetItem(AIndex);
end;
{$ENDIF}



procedure TUdTextStyles.CopyFrom(AValue: TUdObject);
var
  I, N: Integer;
  LSrcItem, LDstItem: TUdTextStyle;
begin
  inherited;

  if not AValue.InheritsFrom(TUdTextStyles) then Exit; //======>>>

  if (TUdTextStyles(AValue).FList.Count > 0) then
  begin
    Self.Clear(True);

    for I := 0 to TUdTextStyles(AValue).FList.Count - 1 do
    begin
      LSrcItem := TUdTextStyle(TUdTextStyles(AValue).FList[I]);
      if not Assigned(LSrcItem) then Continue;

      LDstItem := TUdTextStyle.Create();
      LDstItem.Assign(LSrcItem);
      
      LDstItem.Owner := Self;
      LDstItem.SetDocument(Self.Document, Self.IsDocRegister);
          
      FList.Add(LDstItem);
      Self.AddDocObject(LDstItem, False);
    end;


    if FList.Count > 0 then FStandard := FList.Items[0];

    N := TUdTextStyles(AValue).IndexOf(TUdTextStyles(AValue).Active);
    if N >= 0 then
      FActive := GetItem(N)
    else
      FActive := FStandard;
  end;
end;



function TUdTextStyles.InitShxFont(ATextStyle: TUdTextStyle; AInitBig: Boolean): Boolean;
begin
  Result := False;

  if (FShxFontNames.Count <= 0) and (FBigFontNames.Count <= 0) then Exit;
  if not Assigned(ATextStyle) or not Assigned(ATextStyle.ShxFont) then Exit;

  if FShxFontNames.Count > 0 then
  begin
    if FShxFontNames.IndexOf('txt.shx') >= 0 then
      ATextStyle.ShxFont.ShxFile := FFontsDir + '\' + 'txt.shx'
    else
      ATextStyle.ShxFont.ShxFile := FFontsDir + '\' + FShxFontNames[0];
  end;

  if AInitBig and (FBigFontNames.Count > 0) then
  begin
    if FBigFontNames.IndexOf('gbcbig.shx') >= 0 then
      ATextStyle.ShxFont.BigFile := FFontsDir + '\' + 'gbcbig.shx'
    else
      ATextStyle.ShxFont.BigFile := FFontsDir + '\' + FBigFontNames[0];
  end;

  Result := True;
end;




function _GetShxFontFiles(ADir: string): TStringDynArray;
var
  I: Integer;
  LStrs: TStrings;
  LFind: Integer;
  LSearchRec: TSearchrec;
begin
  LStrs := TStringList.Create;
  LFind := FindFirst(ADir + '\' + '*.shx', faAnyFile, LSearchRec);
  try
    while LFind = 0 do
    begin
      if (LSearchRec.Name <> '.') and (LSearchRec.Name <> '..') then
        LStrs.Add(ADir + '\' +LSearchRec.Name);
      LFind := FindNext(LSearchRec);
    end;

    System.SetLength(Result, LStrs.Count);
    for I := 0 to LStrs.Count - 1 do Result[I] := LStrs[I];
  finally
    FindClose(LSearchRec);
    LStrs.Free;
  end;
end;


function TUdTextStyles.InitFontNames: Boolean;
var
  I: Integer;
  LFontName: string;
  LFontFile: string;
  LFontFiles: TStringDynArray;
begin
  Result := False;

  FShxFontNames.Clear;
  FBigFontNames.Clear;

  LFontFiles := _GetShxFontFiles(FFontsDir);
  if System.Length(LFontFiles) <= 0 then Exit;

  for I := 0 to System.Length(LFontFiles) - 1 do
  begin
    LFontFile := LFontFiles[I];
    LFontName := LowerCase(SysUtils.ExtractFileName(LFontFile));

    if TUdShx.IsBigFont(LFontFile) then
      FBigFontNames.Add(LFontName)
    else if TUdShx.IsNormalFont(LFontFile) or TUdShx.IsUnicodeFont(LFontFile) then
      FShxFontNames.Add(LFontName);
  end;

  Result := True;
end;



function TUdTextStyles.InitDefaultStyles(): Boolean;
var
  LShxFile: string;
  LTTFStyle: TUdTextStyle;
begin
  Self.Clear(True);


  FStandard := TUdTextStyle.Create();
  FStandard.Name := 'Standard';
  FStandard.FontKind := fkShx;
  FStandard.Owner := Self;
  if not InitShxFont(FStandard, True) then FStandard.FontKind := fkTTF;

  FList.Add(FStandard);

  FActive := FStandard;



  LTTFStyle := TUdTextStyle.Create();
  LTTFStyle.Name := 'TTF';
  LTTFStyle.FontKind := fkTTF;
  LTTFStyle.TTFFont.Font.Name := 'ËÎÌו';
  LTTFStyle.Owner := Self;
  FList.Add(LTTFStyle);

  //---------------------------------------------------------

  FGdt := TUdTextStyle.Create();
  FGdt.Name := GDT_NAME;
  FGdt.FontKind := fkShx;
  FGdt.Owner := Self;


  LShxFile := FFontsDir + '\' + SHX_GDT_FONT_FILE;
  if FileExists(LShxFile) then
    FGdt.ShxFont.ShxFile := LShxFile;

  if not Assigned(FGdt.ShxFont.ShxOutLines) then
  begin
    if FileExists(FTTFGdtFile) then
    begin
      FGdt.FontKind := fkTTF;
      FGdt.TTFFont.Font.Name := 'AIGDT';
    end;
  end;


  //---------------------------------------------------------

  FLtype := TUdTextStyle.Create();
  FLtype.Name := LTYPE_NAME;
  FLtype.FontKind := fkShx;
  FLtype.Owner := Self;

  LShxFile :=  FFontsDir + '\' + SHX_LTYPE_FONT_FILE;
  if FileExists(LShxFile) then
    FLtype.ShxFont.ShxFile := LShxFile;


  Result := FList.Count > 0;
end;


function TUdTextStyles.Init(): Boolean;
begin
  Self.InitFontNames();
  Self.InitDefaultStyles();
  Result := True;
end;


procedure TUdTextStyles.SetFontsDir(const AValue: string);
begin
//  UdTTF.SetDefFontDir(AValue);
  UdShx.SetDefFontDir(AValue);

  FFontsDir := AValue;
  Self.Init();
end;





//------------------------------------------------------------------------------------------


function TUdTextStyles.SetActive(AIndex: Integer): Boolean;
var
  LTextStyle: TUdTextStyle;
begin
  Result := False;
  LTextStyle := Self.GetItem(AIndex);

  if Assigned(LTextStyle) and (LTextStyle <> FActive) and Self.RaiseBeforeModifyObject('Active') then
  begin
    FActive := LTextStyle;
    if Assigned(FOnSelect) then FOnSelect(Self, FActive);

    Self.RaiseAfterModifyObject('Active');
    Result := True;
  end;
end;


function TUdTextStyles.SetActive(AName: string): Boolean;
begin
  Result := SetActive(IndexOf(AName));
end;


procedure TUdTextStyles.SetActive_(const AValue: TUdTextStyle);
begin
  SetActive(FList.IndexOf(AValue));
end;

function TUdTextStyles.GetActiveIndex(): Integer;
begin
  Result := Self.IndexOf(FActive);
end;




function TUdTextStyles.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TUdTextStyles.SetItem(AIndex: Integer; const AValue: TUdTextStyle);
var
  LTextStyle: TUdTextStyle;
begin
//  if AIndex < 1 then Exit; // 0 is FStandard

  LTextStyle := TUdTextStyle(FList.Items[AIndex]);

  if Assigned(LTextStyle) and Assigned(AValue) and (LTextStyle <> AValue) then
    LTextStyle.Assign(AValue);
end;






//----------------------------------------------------------------------

(*
function TUdTextStyles.Add: TUdTextStyle;

  function _AutoGenName(): string;
  var
    N: Integer;
  begin
    N := FList.Count;
    Result := NAME_PREFIX + IntToStr(N);
    while Self.IndexOf(Result) >= 0 do
    begin
      N := N + 1;
      Result := NAME_PREFIX + IntToStr(N);
    end;
  end;

begin
  Result := Self.Add(_AutoGenName());
end;

function TUdTextStyles.Add(AName: string): TUdTextStyle;
var
  N: Integer;
  LTextStyle: TUdTextStyle;
begin
  N := Self.IndexOf(AName);
  if N >= 0 then
  begin
    Result := FList[N];
    Exit; //=======>>>>>
  end;

  LTextStyle := TUdTextStyle.Create(Self.Document, Self);
  LTextStyle.Name := AName;

  FList.Add(LTextStyle);
  if Assigned(FOnAdd) then FOnAdd(Self, LTextStyle);

  Self.AddDocObject(LTextStyle);
  Result := LTextStyle;
end;
*)

function TUdTextStyles.Add(AObject: TUdTextStyle): Boolean;
begin
  Result := False;
  if not Assigned(AObject) and (FList.IndexOf(AObject) < 0) then Exit; //======>>>

  AObject.Owner := Self;
  AObject.SetDocument(Self.Document, Self.IsDocRegister);

  FList.Add(AObject);
  Self.AddDocObject(AObject);
  
  if Assigned(FOnAdd) then FOnAdd(Self, AObject);
  Result := True;
end;




function TUdTextStyles.IndexOf(AName: string): Integer;
var
  I: Integer;
  LName: string;
  LTextStyle: TUdTextStyle;
begin
  LName := LowerCase(Trim(AName));
  if LName = '' then
  begin
    Result := 0;
    Exit; //=====>>>>
  end;

  Result := -1;

  for I := 0 to FList.Count - 1 do
  begin
    LTextStyle := TUdTextStyle(FList[I]);

    if LowerCase(LTextStyle.Name) = LName then
    begin
      Result := I;
      Break;
    end;
  end;
end;




function TUdTextStyles.Remove(AIndex: Integer): Boolean;
var
  LTextStyle: TUdTextStyle;
begin
  Result := False;
  if (AIndex < 1) or (AIndex >= FList.Count) then Exit;  // Just < 1  The First is standard

  LTextStyle := TUdTextStyle(FList.Items[AIndex]);

  if FActive <> LTextStyle then
  begin
    Result := True;
    if Assigned(FOnRemove) then FOnRemove(Self, LTextStyle, Result);

    if Result then
    begin
      Self.RemoveDocObject(LTextStyle);
      FList.Delete(AIndex);
    end;
  end;
end;

function TUdTextStyles.Remove(AName: string): Boolean;
begin
  Result := Self.Remove(Self.IndexOf(AName));
end;

function TUdTextStyles.Remove(AObject: TUdTextStyle): Boolean;
begin
  Result := Self.Remove(Self.IndexOf(AObject));
end;


function TUdTextStyles.GetItem(AIndex: Integer): TUdTextStyle;
begin
  Result := nil;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  Result := TUdTextStyle(FList.Items[AIndex]);
end;

function TUdTextStyles.GetItem(AName: string): TUdTextStyle;
begin
  if LowerCase(AName) = LowerCase(GDT_NAME) then
    Result := FGdt
  else
  if (LowerCase(AName) = LowerCase(LTYPE_NAME)) or
     (LowerCase(AName) = LowerCase(LTYPE_NAME2)) then
    Result := FLtype
  else
    Result := Self.GetItem(Self.IndexOf(AName));
end;



//----------------------------------------------------------------------

function TUdTextStyles.Add(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdTextStyle) and (FList.IndexOf(AObj) < 0) then
    Result := Self.Add(TUdTextStyle(AObj));
end;

function TUdTextStyles.Insert(AIndex: Integer; AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdTextStyle) and (FList.IndexOf(AObj) < 0) then
  begin
    if AIndex < 0 then AIndex := AIndex + FList.Count;
    if AIndex > FList.Count then AIndex := FList.Count;

    FList.Insert(AIndex, AObj);
    if Assigned(FOnAdd) then FOnAdd(Self, TUdTextStyle(AObj));

    Self.AddDocObject(AObj);
    Result := True;
  end;
end;

function TUdTextStyles.Remove(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdTextStyle) then
  begin
    Result := Self.Remove(TUdTextStyle(AObj));
  end;
end;

function TUdTextStyles.RemoveAt(AIndex: Integer): Boolean;
begin
  Result := Self.Remove(AIndex);
end;

function TUdTextStyles.IndexOf(AObj: TUdObject): Integer;
begin
  Result := -1;
  if Assigned(AObj) and AObj.InheritsFrom(TUdTextStyle) then
    Result := FList.IndexOf(TUdTextStyle(AObj));
end;

function TUdTextStyles.Contains(AObj: TUdObject): Boolean;
begin
  Result := Self.IndexOf(AObj) >= 0;
end;




//----------------------------------------------------------------------

function TUdTextStyles.GetShxFile(AShxName: string): string;
var
  LShxName: string;
begin
  Result := '';
  if Trim(AShxName) = '' then Exit;

  LShxName := SysUtils.ExtractFileName(AShxName);
  if UpperCase(SysUtils.ExtractFileExt(AShxName)) <> '.SHX' then LShxName := LShxName + '.SHX';

  Result := FFontsDir + '\' + LShxName;
end;


procedure TUdTextStyles.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  inherited;

  IntToStream(AStream, FList.Count);

  for I := 0 to FList.Count - 1 do
    TUdTextStyle(FList[I]).SaveToStream(AStream);

  IntToStream(AStream, FList.IndexOf(FActive));
end;


procedure TUdTextStyles.LoadFromStream(AStream: TStream);
var
  I, LCount: Integer;
  LTextStyle: TUdTextStyle;
begin
  Self.Clear(True);

  inherited;

  LCount := IntFromStream(AStream);
  for I := 0 to LCount - 1 do
  begin
    LTextStyle := TUdTextStyle.Create(Self.Document, Self.IsDocRegister);
    LTextStyle.Owner := Self;
    LTextStyle.LoadFromStream(AStream);

    FList.Add(LTextStyle);
    Self.AddDocObject(LTextStyle, False);
  end;

  if FList.Count > 0 then FStandard := FList.Items[0];

  I := IntFromStream(AStream);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FStandard;

//  Self.RaiseChanged();
end;




procedure TUdTextStyles.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I: Integer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to FList.Count - 1 do
  begin
    TUdTextStyle(FList[I]).SaveToXml(LXmlNode.Add());
  end;

  LXmlNode.Prop['ActiveIndex'] := IntToStr(IndexOf(FActive));
end;

procedure TUdTextStyles.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  LTextStyle: TUdTextStyle;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  Self.Clear(True);

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to LXmlNode.Count - 1 do
  begin
    LTextStyle := TUdTextStyle.Create(Self.Document, Self.IsDocRegister);
    LTextStyle.Owner := Self;
    LTextStyle.LoadFromXml(LXmlNode.Items[I]);

    FList.Add(LTextStyle);
    Self.AddDocObject(LTextStyle, False);
  end;

  if FList.Count > 0 then FStandard := FList.Items[0];

  I := StrToIntDef(LXmlNode.Prop['ActiveIndex'], -1);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FStandard;
end;






end.