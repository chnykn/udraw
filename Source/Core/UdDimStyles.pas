{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimStyles;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdConsts, UdTypes, UdIntfs, UdObject, UdDimStyle;

type
  //*** TUdDimStyles ***//
  TUdDimStyles = class(TUdObject, IUdObjectCollection , IUdActiveSupport)
  private
    FList: TList;

    FActive: TUdDimStyle;
    FStandard: TUdDimStyle;

    FOnAdd: TUdDimStyleEvent;
    FOnSelect: TUdDimStyleEvent;
    FOnRemove: TUdDimStyleAllowEvent;

  protected
    function GetTypeID: Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function GetCount: Integer;
    procedure SetItem(AIndex: Integer; const AValue: TUdDimStyle);

    procedure SetActive_(const AValue: TUdDimStyle);

    function InitIso25(ADimStyle: TUdDimStyle): Boolean;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

    {$IFNDEF D2005UP}
    function GetItem_(AIndex: Integer): TUdDimStyle;
    {$ENDIF}

  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure Clear(All: Boolean = False);

    function IndexOf(AName: string): Integer; overload;

    function Add(AObject: TUdDimStyle): Boolean; overload;

    function Remove(AName: string): Boolean; overload;
    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AObject: TUdDimStyle): Boolean; overload;

    function GetItem(AName: string): TUdDimStyle; overload;
    function GetItem(AIndex: Integer): TUdDimStyle; overload;

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

    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Items[Index: Integer]: TUdDimStyle read {$IFDEF D2005UP} GetItem {$ELSE} GetItem_ {$ENDIF} write SetItem;

  published
    property Active  : TUdDimStyle read FActive write SetActive_;
    property Standard: TUdDimStyle read FStandard;

    property Count: Integer read GetCount;

    property OnAdd: TUdDimStyleEvent read FOnAdd write FOnAdd;
    property OnSelect: TUdDimStyleEvent read FOnSelect write FOnSelect;
    property OnRemove: TUdDimStyleAllowEvent read FOnRemove write FOnRemove;

  end;

implementation

uses
  SysUtils,
  UdStreams, UdXml;

const
  NAME_PREFIX = 'DimStyle';


{ TUdDimStyles }

constructor TUdDimStyles.Create();
begin
  inherited;

  FStandard := TUdDimStyle.Create();
  FStandard.Name := 'ISO-25';
  Self.InitIso25(FStandard);
  FStandard.Owner := Self;
  
  FList := TList.Create;

  FList.Add(FStandard);

  FActive := FStandard;
end;

destructor TUdDimStyles.Destroy;
begin
  Self.Clear(True);

  if Assigned(FList) then FList.Free;
  FList := nil;

  FStandard := nil;

  inherited;
end;



function TUdDimStyles.GetTypeID: Integer;
begin
  Result := ID_DIMSTYLE;
end;

procedure TUdDimStyles.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
var
  I: Integer;
begin
  inherited;

  for I := 0 to FList.Count - 1 do
  begin
    TUdObject(FList[I]).SetDocument(Self.Document, Self.IsDocRegister);
    Self.AddDocObject(TUdObject(FList[I]), False);
  end;
end;




procedure TUdDimStyles.Clear(All: Boolean = False);
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

procedure TUdDimStyles.CopyFrom(AValue: TUdObject);
var
  I, N: Integer;
  LSrcItem, LDstItem: TUdDimStyle;
begin
  inherited;

  if not AValue.InheritsFrom(TUdDimStyles) then Exit; //======>>>

  if (TUdDimStyles(AValue).FList.Count > 0) then
  begin
    Self.Clear(True);

    for I := 0 to TUdDimStyles(AValue).FList.Count - 1 do
    begin
      LSrcItem := TUdDimStyle(TUdDimStyles(AValue).FList[I]);
      if not Assigned(LSrcItem) then Continue;

      LDstItem := TUdDimStyle.Create();
      LDstItem.Assign(LSrcItem);
      
      LDstItem.Owner := Self;
      LDstItem.SetDocument(Self.Document, Self.IsDocRegister);
          
      FList.Add(LDstItem);
      Self.AddDocObject(LDstItem, False);
    end;


    if FList.Count > 0 then FStandard := FList.Items[0];

    N := TUdDimStyles(AValue).IndexOf(TUdDimStyles(AValue).Active);
    if N >= 0 then
      FActive := GetItem(N)
    else
      FActive := FStandard;
  end;
end;



function TUdDimStyles.InitIso25(ADimStyle: TUdDimStyle): Boolean;
begin
  Result := False;

//  if (FShxFontNames.Count <= 0) and (FBigFontNames.Count <= 0) then Exit;
//  if not Assigned(ADimStyle) or not Assigned(ADimStyle.ShxFont) then Exit;
//
//  if FShxFontNames.Count > 0 then
//  begin
//    if FShxFontNames.IndexOf('txt.shx') >= 0 then
//      ADimStyle.ShxFont.ShxFile := FFontsDir + '\' + 'txt.shx'
//    else
//      ADimStyle.ShxFont.ShxFile := FFontsDir + '\' + FShxFontNames[0];
//  end;
//
//  if AInitBig and (FBigFontNames.Count > 0) then
//  begin
//    if FBigFontNames.IndexOf('gbcbig.shx') >= 0 then
//      ADimStyle.ShxFont.BigFile := FFontsDir + '\' + 'gbcbig.shx'
//    else
//      ADimStyle.ShxFont.BigFile := FFontsDir + '\' + FBigFontNames[0];
//  end;

//  Result := True;
end;



{$IFNDEF D2005UP}
function TUdDimStyles.GetItem_(AIndex: Integer): TUdDimStyle;
begin
  Result := Self.GetItem(AIndex);
end;
{$ENDIF}


//------------------------------------------------------------------------------------------


function TUdDimStyles.SetActive(AIndex: Integer): Boolean;
var
  LDimStyle: TUdDimStyle;
begin
  Result := False;
  LDimStyle := Self.GetItem(AIndex);

  if Assigned(LDimStyle) and (LDimStyle <> FActive) and Self.RaiseBeforeModifyObject('Active') then
  begin
    FActive := LDimStyle;
    if Assigned(FOnSelect) then FOnSelect(Self, FActive);

    Self.RaiseAfterModifyObject('Active');
    Result := True;
  end;
end;


function TUdDimStyles.SetActive(AName: string): Boolean;
begin
  Result := SetActive(IndexOf(AName));
end;


procedure TUdDimStyles.SetActive_(const AValue: TUdDimStyle);
begin
  SetActive(FList.IndexOf(AValue));
end;



function TUdDimStyles.GetActiveIndex(): Integer;
begin
  Result := Self.IndexOf(FActive);
end;


function TUdDimStyles.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TUdDimStyles.SetItem(AIndex: Integer; const AValue: TUdDimStyle);
var
  LDimStyle: TUdDimStyle;
begin
//  if AIndex < 1 then Exit; // 0 is FStandard

  LDimStyle := TUdDimStyle(FList.Items[AIndex]);

  if Assigned(LDimStyle) and Assigned(AValue) and (LDimStyle <> AValue) then
    LDimStyle.Assign(AValue);
end;




//----------------------------------------------------------------------

function TUdDimStyles.Add(AObject: TUdDimStyle): Boolean;
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



function TUdDimStyles.IndexOf(AName: string): Integer;
var
  I: Integer;
  LName: string;
  LDimStyle: TUdDimStyle;
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
    LDimStyle := TUdDimStyle(FList[I]);

    if LowerCase(LDimStyle.Name) = LName then
    begin
      Result := I;
      Break;
    end;
  end;
end;




function TUdDimStyles.Remove(AIndex: Integer): Boolean;
var
  LDimStyle: TUdDimStyle;
begin
  Result := False;
  if (AIndex < 1) or (AIndex >= FList.Count) then Exit;

  LDimStyle := TUdDimStyle(FList.Items[AIndex]);

  if FActive <> LDimStyle then
  begin
    Result := True;
    if Assigned(FOnRemove) then FOnRemove(Self, LDimStyle, Result);

    if Result then
    begin
      Self.RemoveDocObject(LDimStyle);
      FList.Delete(AIndex);
    end;
  end;
end;

function TUdDimStyles.Remove(AName: string): Boolean;
begin
  Result := Self.Remove(Self.IndexOf(AName));
end;

function TUdDimStyles.Remove(AObject: TUdDimStyle): Boolean;
begin
  Result := Self.Remove(Self.IndexOf(AObject));
end;


function TUdDimStyles.GetItem(AIndex: Integer): TUdDimStyle;
begin
  Result := nil;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  Result := TUdDimStyle(FList.Items[AIndex]);
end;


function TUdDimStyles.GetItem(AName: string): TUdDimStyle;
begin
  Result := Self.GetItem(Self.IndexOf(AName));
end;




//----------------------------------------------------------------------

function TUdDimStyles.Add(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdDimStyle) and (FList.IndexOf(AObj) < 0) then
    Result := Self.Add(TUdDimStyle(AObj));
end;


function TUdDimStyles.Insert(AIndex: Integer; AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdDimStyle) and (FList.IndexOf(AObj) < 0) then
  begin
    if AIndex < 0 then AIndex := AIndex + FList.Count;
    if AIndex > FList.Count then AIndex := FList.Count;

    FList.Insert(AIndex, AObj);
    if Assigned(FOnAdd) then FOnAdd(Self, TUdDimStyle(AObj));

    Self.AddDocObject(AObj);
    Result := True;
  end;
end;


function TUdDimStyles.Remove(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdDimStyle) then
  begin
    Result := Self.Remove(TUdDimStyle(AObj));
  end
end;

function TUdDimStyles.RemoveAt(AIndex: Integer): Boolean;
begin
  Result := Self.Remove(AIndex);
end;


function TUdDimStyles.IndexOf(AObj: TUdObject): Integer;
begin
  Result := -1;
  if Assigned(AObj) and AObj.InheritsFrom(TUdDimStyle) then
    Result := FList.IndexOf(TUdDimStyle(AObj));
end;

function TUdDimStyles.Contains(AObj: TUdObject): Boolean;
begin
  Result := Self.IndexOf(AObj) >= 0;
end;





//----------------------------------------------------------------------

procedure TUdDimStyles.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  inherited;

  IntToStream(AStream, FList.Count);
  for I := 0 to FList.Count - 1 do
    TUdDimStyle(FList[I]).SaveToStream(AStream);

  IntToStream(AStream, FList.IndexOf(FActive));
end;

procedure TUdDimStyles.LoadFromStream(AStream: TStream);
var
  I, LCount: Integer;
  LDimStyle: TUdDimStyle;
begin
  Self.Clear(True);

  inherited;

  LCount := IntFromStream(AStream);
  for I := 0 to LCount - 1 do
  begin
    LDimStyle := TUdDimStyle.Create(Self.Document, Self.IsDocRegister);
    LDimStyle.Owner := Self;
    LDimStyle.LoadFromStream(AStream);

    FList.Add(LDimStyle);
    Self.AddDocObject(LDimStyle, False);

    if I = 0 then FStandard := LDimStyle;
  end;

  I := IntFromStream(AStream);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FStandard;

//  Self.RaiseChanged();
end;






procedure TUdDimStyles.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I: Integer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to FList.Count - 1 do
  begin
    TUdDimStyle(FList[I]).SaveToXml(LXmlNode.Add());
  end;

  LXmlNode.Prop['ActiveIndex'] := IntToStr(IndexOf(FActive));
end;

procedure TUdDimStyles.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  LDimStyle: TUdDimStyle;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  Self.Clear(True);

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to LXmlNode.Count - 1 do
  begin
    LDimStyle := TUdDimStyle.Create(Self.Document, Self.IsDocRegister);
    LDimStyle.Owner := Self;
    LDimStyle.LoadFromXml(LXmlNode.Items[I]);

    FList.Add(LDimStyle);
    Self.AddDocObject(LDimStyle, False);
  end;

  if FList.Count > 0 then FStandard := FList.Items[0];

  I := StrToIntDef(LXmlNode.Prop['ActiveIndex'], -1);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FStandard;
end;


end.