{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdBlocks;

{$I UdDefs.INC}

interface

uses
  Classes, Forms,
  UdConsts, UdIntfs, UdObject, UdBlock;

type
  //*** TUdBlocks ***//
  TUdBlocks = class(TUdObject, IUdObjectCollection)
  private
    FList: TList;

    FOnAdd: TUdBlockEvent;
    FOnRemove: TUdBlockAllowEvent;

  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function GetCount: Integer;
    procedure SetItem(AIndex: Integer; const AValue: TUdBlock);

    function InitArrowBlocks(): Boolean;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;


    {$IFNDEF D2005UP}
    function GetItem_(AIndex: Integer): TUdBlock;
    {$ENDIF}

  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure Clear();

    function IndexOf(AName: string): Integer; overload;

//    function Add(): TUdBlock; overload;
//    function Add(AName: string): TUdBlock; overload;
    function Add(AObject: TUdBlock): Boolean; overload;

    function Remove(AName: string): Boolean; overload;
    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AObject: TUdBlock): Boolean; overload;

    function GetItem(AName: string): TUdBlock; overload;
    function GetItem(AIndex: Integer): TUdBlock; overload;


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
    property Items[AIndex: Integer]: TUdBlock read {$IFDEF D2005UP} GetItem {$ELSE} GetItem_ {$ENDIF} write SetItem;

  published
    property Count: Integer read GetCount;

    property OnAdd: TUdBlockEvent read FOnAdd write FOnAdd;
    property OnRemove: TUdBlockAllowEvent read FOnRemove write FOnRemove;

  end;

implementation

uses
  SysUtils,
  UdDocument, UdStreams, UdXml;

const
  NAME_PREFIX = 'Block';
  ARROW_BLOCKS_FILE = 'ArrowBlocks.xml';


type
  TFBlock = class(TUdBlock);


{ TUdBlocks }

constructor TUdBlocks.Create();
begin
  inherited;

  FList := TList.Create;
  InitArrowBlocks();
end;

destructor TUdBlocks.Destroy;
begin
  Self.Clear();

  if Assigned(FList) then FList.Free;
  FList := nil;

  inherited;
end;


function TUdBlocks.GetTypeID: Integer;
begin
  Result := ID_BLOCKS;
end;

procedure TUdBlocks.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
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


function TUdBlocks.InitArrowBlocks: Boolean;
var
  I: Integer;
  LBlock: TUdBlock;
  LXmlNode: TUdXmlNode;
  LXmlDocument: TUdXMLDocument;
  LCurrPath, LBlockFile: string;
begin
  Result := False;

  LCurrPath := SysUtils.ExtractFilePath(Application.ExeName);
  LBlockFile := LCurrPath + ARROW_BLOCKS_FILE;

  if not SysUtils.FileExists(LBlockFile) then
    LBlockFile := LCurrPath + 'Data\' + ARROW_BLOCKS_FILE;

  if not SysUtils.FileExists(LBlockFile) then Exit; //=======>>>>>

  LXmlDocument := TUdXMLDocument.Create;
  try
    LXmlDocument.LoadFromFile(LBlockFile);

    LXmlNode := LXmlDocument.Root;
    for I := 0 to LXmlNode.Count - 1 do
    begin
      LBlock := TUdBlock.Create();
      LBlock.LoadFromXml(LXmlNode.Items[I]);

      LBlock.Owner := Self;
      LBlock.SetDocument(Self.Document, Self.IsDocRegister);

      FList.Add(LBlock);
      Self.AddDocObject(LBlock, False);
    end;
  finally
    LXmlDocument.Free;
  end;
end;



procedure TUdBlocks.Clear();
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do
    Self.RemoveDocObject(TUdObject(FList[I]), False);
  FList.Clear();

  Self.RaiseChanged();
end;

procedure TUdBlocks.CopyFrom(AValue: TUdObject);
var
  I: Integer;
  LSrcItem, LDstItem: TUdBlock;
begin
  inherited;

  if not AValue.InheritsFrom(TUdBlocks) then Exit;

  if (TUdBlocks(AValue).FList.Count > 0) then
  begin
    Self.Clear();

    for I := 0 to TUdBlocks(AValue).FList.Count - 1 do
    begin
      LSrcItem := TUdBlock(TUdBlocks(AValue).FList[I]);
      if not Assigned(LSrcItem) then Continue;

      LDstItem := TUdBlock.Create();
      LDstItem.Assign(LSrcItem);

      LDstItem.Owner := Self;
      LDstItem.SetDocument(Self.Document, Self.IsDocRegister);
      
      FList.Add(LDstItem);
      Self.AddDocObject(LDstItem, False);
    end;
  end;
end;



{$IFNDEF D2005UP}
function TUdBlocks.GetItem_(AIndex: Integer): TUdBlock;
begin
  Result := Self.GetItem(AIndex);
end;
{$ENDIF}
    

//------------------------------------------------------------------------------------------

function TUdBlocks.Add(AObject: TUdBlock): Boolean;
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



function TUdBlocks.IndexOf(AName: string): Integer;
var
  I: Integer;
  LName: string;
  LBlock: TUdBlock;
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
    LBlock := TUdBlock(FList[I]);

    if LowerCase(LBlock.Name) = LName then
    begin
      Result := I;
      Break;
    end;
  end;
end;




function TUdBlocks.Remove(AIndex: Integer): Boolean;
var
  LBlock: TUdBlock;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  LBlock := TUdBlock(FList.Items[AIndex]);

  Result := True;
  if Assigned(FOnRemove) then FOnRemove(Self, LBlock, Result);

  if Result then
  begin
    Self.RemoveDocObject(LBlock);
    FList.Delete(AIndex);
  end;
end;

function TUdBlocks.Remove(AName: string): Boolean;
begin
  Result := Self.Remove(Self.IndexOf(AName));
end;

function TUdBlocks.Remove(AObject: TUdBlock): Boolean;
begin
  Result := Self.Remove(Self.IndexOf(AObject));
end;



function TUdBlocks.GetItem(AIndex: Integer): TUdBlock;
begin
  Result := nil;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  Result := TUdBlock(FList.Items[AIndex]);
end;


function TUdBlocks.GetItem(AName: string): TUdBlock;
begin
  Result := Self.GetItem(Self.IndexOf(AName));
end;


function TUdBlocks.GetCount(): Integer;
begin
  Result := FList.Count;
end;

procedure TUdBlocks.SetItem(AIndex: Integer; const AValue: TUdBlock);
var
  LBlock: TUdBlock;
begin
//  if AIndex < 1 then Exit; // 0 is FStandard

  LBlock := TUdBlock(FList.Items[AIndex]);

  if Assigned(LBlock) and Assigned(AValue) and (LBlock <> AValue) then
    LBlock.Assign(AValue);
end;


//----------------------------------------------------------------------

function TUdBlocks.Add(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdBlock) and (FList.IndexOf(AObj) < 0) then
    Result := Self.Add(TUdBlock(AObj));
end;


function TUdBlocks.Insert(AIndex: Integer; AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdBlock) and (FList.IndexOf(AObj) < 0) then
  begin
    if AIndex < 0 then AIndex := AIndex + FList.Count;
    if AIndex > FList.Count then AIndex := FList.Count;

    FList.Insert(AIndex, AObj);
    if Assigned(FOnAdd) then FOnAdd(Self, TUdBlock(AObj));

    Self.AddDocObject(AObj);
    Result := True;
  end;
end;


function TUdBlocks.Remove(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdBlock) then
  begin
    Result := Self.Remove(TUdBlock(AObj));
  end
end;

function TUdBlocks.RemoveAt(AIndex: Integer): Boolean;
begin
  Result := Self.Remove(AIndex);
end;


function TUdBlocks.IndexOf(AObj: TUdObject): Integer;
begin
  Result := -1;
  if Assigned(AObj) and AObj.InheritsFrom(TUdBlock) then
    Result := FList.IndexOf(TUdBlock(AObj));
end;


function TUdBlocks.Contains(AObj: TUdObject): Boolean;
begin
  Result := Self.IndexOf(AObj) >= 0;
end;




//----------------------------------------------------------------------

procedure TUdBlocks.SaveToStream(AStream: TStream);
var
  I, N: Integer;
  LPos, LStep, LCount: Integer;
begin
  inherited;

  //Self.DoProgress(40~90, 100);

  LCount := FList.Count;
  N := 0;
  LStep := Round(LCount / 50  * 5);

  IntToStream(AStream, LCount);

  for I := 0 to LCount - 1 do
  begin
    if I >= N then
    begin
      LPos := Round(I / LCount * 50);
      if Assigned(Document) then TUdDocument(Document).DoProgress(LPos+40, 100);

      N := N + LStep;
    end;

    TUdBlock(FList[I]).SaveToStream(AStream);
  end;
end;

procedure TUdBlocks.LoadFromStream(AStream: TStream);
var
  I, N: Integer;
  LPos, LStep, LCount: Integer;
  LBlock: TUdBlock;
begin
  Self.Clear();

  inherited;

  //Self.DoProgress(40~90, 100);

  LCount := IntFromStream(AStream);
  N := 0;
  LStep := Round(LCount / 50  * 5);

  for I := 0 to LCount - 1 do
  begin
    if I >= N then
    begin
      LPos := Round(I / LCount * 50);
      if Assigned(Document) then TUdDocument(Document).DoProgress(LPos+40, 100);

      N := N + LStep;
    end;

    LBlock := TUdBlock.Create(Self.Document, True);
    LBlock.Owner := Self;
    LBlock.LoadFromStream(AStream);

//    if not LBlock.IsDocRegister then
//    begin
//      LBlock.SetDocument(Self.Document, Self.IsDocRegister);
//      TFBlock(LBlock).FID := Self.GetNextObjectID();
//    end;

    FList.Add(LBlock);
    Self.AddDocObject(LBlock, False);
  end;
end;






procedure TUdBlocks.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I, N: Integer;
  LPos, LStep, LCount: Integer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>


  //Self.DoProgress(40~90, 100);

  LCount := FList.Count;
  N := 0;
  LStep := Round(LCount / 50  * 5);


  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to FList.Count - 1 do
  begin
    if I >= N then
    begin
      LPos := Round(I / LCount * 50);
      if Assigned(Document) then TUdDocument(Document).DoProgress(LPos+40, 100);

      N := N + LStep;
    end;

    TUdBlock(FList[I]).SaveToXml(LXmlNode.Add());
  end;
end;

procedure TUdBlocks.LoadFromXml(AXmlNode: TObject);
var
  I, N: Integer;
  LPos, LStep, LCount: Integer;
  LBlock: TUdBlock;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  Self.Clear();

  LXmlNode := TUdXmlNode(AXmlNode);


  LCount := LXmlNode.Count;
  N := 0;
  LStep := Round(LCount / 50  * 5);


  for I := 0 to LCount - 1 do
  begin
    if I >= N then
    begin
      LPos := Round(I / LCount * 50);
      if Assigned(Document) then TUdDocument(Document).DoProgress(LPos+40, 100);

      N := N + LStep;
    end;


    LBlock := TUdBlock.Create(Self.Document, True);
    LBlock.Owner := Self;
    LBlock.LoadFromXml(LXmlNode.Items[I]);

    FList.Add(LBlock);
    Self.AddDocObject(LBlock, False);
  end;
end;

end.