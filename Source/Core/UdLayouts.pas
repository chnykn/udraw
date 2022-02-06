{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLayouts;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics,
  UdConsts, UdIntfs, UdObject, UdEntity, UdLayout, UdDrawPanel;

type
  //*** TUdLayouts ***//
  TUdLayouts = class(TUdObject, IUdObjectCollection , IUdActiveSupport)
  private
    FList: TList;

    FModel: TUdLayout;
    FActive: TUdLayout;

    FOnAdd: TUdLayoutEvent;
    FOnSelect: TUdLayoutEvent;
    FOnRemove: TUdLayoutAllowEvent;

    FOnAddEntities: TUdEntitiesEvent;
    FOnRemoveEntities: TUdEntitiesEvent;
    FOnRemovedEntities: TNotifyEvent;

    FOnAddSelectedEntities: TUdEntitiesEvent;
    FOnRemoveSelectedEntities: TUdEntitiesEvent;
    FOnRemoveAllSelecteEntities: TNotifyEvent;

    FOnActionChanged: TNotifyEvent;
    FOnAxesChanging: TNotifyEvent;
    FOnAxesChanged : TNotifyEvent;


  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function GetCount: Integer;

    procedure SetItem(AIndex: Integer; const AValue: TUdLayout);

    procedure FSetActive(ALayout: TUdLayout);
    procedure SetActive_(const AValue: TUdLayout);

    function GetDrawPanel(): TUdDrawPanel;
    procedure SetDrawPanel(const AValue: TUdDrawPanel);

    procedure OnLayoutAddEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnLayoutRemoveEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnLayoutRemovedEntities(Sender: TObject);

    procedure OnLayoutAddSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnLayoutRemoveSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnLayoutRemoveAllSelectedEntities(Sender: TObject);
    procedure OnLayoutActionChanged(Sender: TObject);
    procedure OnLayoutAxesChanging(Sender: TObject);
    procedure OnLayoutAxesChanged(Sender: TObject);

    procedure InitLayoutEvents(ALayout: TUdLayout);
    procedure UnInitLayoutEvents(ALayout: TUdLayout);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

    {$IFNDEF D2005UP}
    function GetItem_(AIndex: Integer): TUdLayout;
    {$ENDIF}

  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure Clear(All: Boolean = False);

    function IndexOf(AName: string): Integer; overload;
    function IndexOf(AObject: TUdLayout): Integer; overload;


    function Add(AObject: TUdLayout): Boolean; overload;
    function Add(AName: string; AMode: Boolean): Boolean; overload;

    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AName: string): Boolean; overload;
    function Remove(AObject: TUdLayout): Boolean; overload;

    function GetItem(AIndex: Integer): TUdLayout; overload;
    function GetItem(AName: string): TUdLayout; overload;

    function SetActive(AIndex: Integer): Boolean; overload;
    function SetActive(AName: string): Boolean; overload;
    function SetActive(AObject: TUdLayout): Boolean; overload;

    function GetActiveIndex(): Integer;

    //IUdObjectCollection ------------------
    function Add(AObj: TUdObject): Boolean; overload;

    function Insert(AIndex: Integer; AObj: TUdObject): Boolean; overload;

    function Remove(AObj: TUdObject): Boolean; overload;
    function RemoveAt(AIndex: Integer): Boolean;

    function IndexOf(AObj: TUdObject): Integer; overload;
    function Contains(AObj: TUdObject): Boolean;


    //-----------------------------------

    function UpdateEntities(): Boolean;

    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Items[Index: Integer]: TUdLayout read {$IFDEF D2005UP} GetItem {$ELSE} GetItem_ {$ENDIF} write SetItem;
    property DrawPanel: TUdDrawPanel read GetDrawPanel write SetDrawPanel;


    property OnAdd   : TUdLayoutEvent read FOnAdd write FOnAdd;
    property OnSelect: TUdLayoutEvent read FOnSelect write FOnSelect;
    property OnRemove: TUdLayoutAllowEvent read FOnRemove write FOnRemove;


    property OnAddEntities: TUdEntitiesEvent read FOnAddEntities write FOnAddEntities;
    property OnRemoveEntities: TUdEntitiesEvent read FOnRemoveEntities write FOnRemoveEntities;
    property OnRemovedEntities: TNotifyEvent read FOnRemovedEntities write FOnRemovedEntities;

    property OnAddSelectedEntities: TUdEntitiesEvent read FOnAddSelectedEntities write FOnAddSelectedEntities;
    property OnRemoveSelectedEntities: TUdEntitiesEvent read FOnRemoveSelectedEntities write FOnRemoveSelectedEntities;
    property OnRemoveAllSelecteEntities: TNotifyEvent read FOnRemoveAllSelecteEntities write FOnRemoveAllSelecteEntities;

    property OnActionChanged: TNotifyEvent read FOnActionChanged write FOnActionChanged;

    property OnAxesChanging: TNotifyEvent read FOnAxesChanging write FOnAxesChanging;
    property OnAxesChanged : TNotifyEvent read FOnAxesChanged  write FOnAxesChanged;


  published
    property Model: TUdLayout read FModel;
    property Active: TUdLayout read FActive write SetActive_;

    property Count: Integer read GetCount;

  end;


implementation

uses
  SysUtils,
  UdDocument, UdStreams, UdXml;


const
  SLAYOUT = 'Layout';


type
  TFLayout = class(TUdLayout);


//==================================================================================================
{ TUdLayouts }

constructor TUdLayouts.Create();
var
  LPaper: TUdLayout;
begin
  inherited;

  FList := TList.Create();


  FModel := TUdLayout.Create();
  FModel.Name := sLayoutMode;
  FModel.Owner := Self;
  
  FActive := FModel;
  InitLayoutEvents(FModel);

  FList.Add(FModel);


  //---------------------------

  LPaper := TUdLayout.Create();
  LPaper.ModelType := False;
  LPaper.Name := sLayoutName + '1';
  LPaper.Owner := Self;
  
  InitLayoutEvents(LPaper);

  FList.Add(LPaper);


  //---------------------------

  LPaper := TUdLayout.Create();
  LPaper.ModelType := False;
  LPaper.Name := sLayoutName + '2';
  LPaper.Owner := Self;
  
  InitLayoutEvents(LPaper);

  FList.Add(LPaper);
end;

destructor TUdLayouts.Destroy;
begin
  Self.Clear(True);

  if Assigned(FList) then FList.Free;
  FList := nil;

  FModel := nil;

  inherited;
end;





function TUdLayouts.GetCount: Integer;
begin
  Result := FList.Count;
end;


function TUdLayouts.GetTypeID: Integer;
begin
  Result := ID_LAYOUTS;
end;

procedure TUdLayouts.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
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



procedure TUdLayouts.Clear(All: Boolean = False);
var
  I, N: Integer;
begin
  Self.FSetActive(FModel);

  FActive := nil;

  if All then N := 0 else N := 2;
  for I := FList.Count - 1 downto N do
  begin
    Self.RemoveDocObject(TUdObject(FList[I]), False);
    FList.Delete(I);
  end;

  if All then
    FModel := nil
  else begin
    for I := 0 to N - 1 do TUdLayout(FList[I]).Clear();
    FActive := FModel;
  end;

  Self.RaiseChanged();
end;


procedure TUdLayouts.CopyFrom(AValue: TUdObject);
var
  I, N: Integer;
  LSrcItem, LDstItem: TUdLayout;
begin
  inherited;

  if not AValue.InheritsFrom(TUdLayouts) then Exit;

  if (TUdLayouts(AValue).FList.Count > 0) then
  begin
    Self.Clear(True);

    for I := 0 to TUdLayouts(AValue).FList.Count - 1 do
    begin
      LSrcItem := TUdLayout(TUdLayouts(AValue).FList[I]);
      if not Assigned(LSrcItem) then Continue;

      LDstItem := TUdLayout.Create();
      LDstItem.Assign(LSrcItem);

      LDstItem.Owner := Self;
      LDstItem.SetDocument(Self.Document, Self.IsDocRegister);
      
      FList.Add(LDstItem);
      Self.AddDocObject(LDstItem, False);
    end;

    if FList.Count > 0 then FModel := FList.Items[0];

    N := TUdLayouts(AValue).IndexOf(TUdLayouts(AValue).Active);
    if N >= 0 then
      FActive := GetItem(N)
    else
      FActive := FModel;
  end;
end;




{$IFNDEF D2005UP}
function TUdLayouts.GetItem_(AIndex: Integer): TUdLayout;
begin
  Result := Self.GetItem(AIndex);
end;
{$ENDIF}


//--------------------------------------------------------

procedure TUdLayouts.OnLayoutAddEntities(Sender: TObject; Entities: TUdEntityArray);
begin
  if Assigned(FOnAddEntities) then FOnAddEntities(Sender, Entities);
end;

procedure TUdLayouts.OnLayoutRemoveEntities(Sender: TObject; Entities: TUdEntityArray);
begin
  if Assigned(FOnRemoveEntities) then FOnRemoveEntities(Sender, Entities);
end;

procedure TUdLayouts.OnLayoutRemovedEntities(Sender: TObject);
begin
  if Assigned(FOnRemovedEntities) then FOnRemovedEntities(Sender);
end;


procedure TUdLayouts.OnLayoutAddSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
begin
  if Assigned(FOnAddSelectedEntities) then FOnAddSelectedEntities(Sender, Entities);
end;

procedure TUdLayouts.OnLayoutRemoveSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
begin
  if Assigned(FOnRemoveSelectedEntities) then FOnRemoveSelectedEntities(Sender, Entities);
end;

procedure TUdLayouts.OnLayoutRemoveAllSelectedEntities(Sender: TObject);
begin
  if Assigned(FOnRemoveAllSelecteEntities) then FOnRemoveAllSelecteEntities(Sender);
end;


procedure TUdLayouts.OnLayoutActionChanged(Sender: TObject);
begin
  if Assigned(FOnActionChanged) then FOnActionChanged(Sender);
end;

procedure TUdLayouts.OnLayoutAxesChanging(Sender: TObject);
begin
  if Assigned(FOnAxesChanging) then FOnAxesChanging(Sender);
end;

procedure TUdLayouts.OnLayoutAxesChanged(Sender: TObject);
begin
  if Assigned(FOnAxesChanged) then FOnAxesChanged(Sender);
end;



procedure TUdLayouts.InitLayoutEvents(ALayout: TUdLayout);
begin
  if Assigned(ALayout) then
  begin
    ALayout.OnAddEntities              := OnLayoutAddEntities;
    ALayout.OnRemoveEntities           := OnLayoutRemoveEntities;
    ALayout.OnRemovedEntities          := OnLayoutRemovedEntities;

    ALayout.OnAddSelectedEntities      := OnLayoutAddSelectedEntities;
    ALayout.OnRemoveSelectedEntities   := OnLayoutRemoveSelectedEntities;
    ALayout.OnRemoveAllSelecteEntities := OnLayoutRemoveAllSelectedEntities;
    ALayout.OnActionChanged            := OnLayoutActionChanged;
    ALayout.OnAxesChanging             := OnLayoutAxesChanging;
    ALayout.OnAxesChanged              := OnLayoutAxesChanged;

  end;
end;

procedure TUdLayouts.UnInitLayoutEvents(ALayout: TUdLayout);
begin
  if Assigned(ALayout) then
  begin
    ALayout.OnAddEntities              := nil;
    ALayout.OnRemoveEntities           := nil;
    ALayout.OnAddSelectedEntities      := nil;
    ALayout.OnRemoveSelectedEntities   := nil;
    ALayout.OnRemoveAllSelecteEntities := nil;
    ALayout.OnActionChanged            := nil;
  end;
end;





//-------------------------------------------------------

function TUdLayouts.IndexOf(AName: string): Integer;
var
  I: Integer;
  LName: string;
  LLayout: TUdLayout;
begin
  Result := -1;

  LName := LowerCase(Trim(AName));

  for I := 0 to FList.Count - 1 do
  begin
    LLayout := TUdLayout(FList[I]);

    if LowerCase(Trim(LLayout.Name)) = LName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TUdLayouts.IndexOf(AObject: TUdLayout): Integer;
begin
  Result := FList.IndexOf(AObject);
end;





//-------------------------------------------------------

function TUdLayouts.Add(AObject: TUdLayout): Boolean;
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

function TUdLayouts.Add(AName: string; AMode: Boolean): Boolean;
var
  LLayout: TUdLayout;
begin
//  Result := False;
//  if Self.IndexOf(AName) >= 0 then Exit;

  LLayout := TUdLayout.Create();
  LLayout.Owner := Self;
  LLayout.Name := AName;
  LLayout.ModelType := AMode;

  Result := Self.Add(LLayout);
end;



//-------------------------------------------------------

function TUdLayouts.Remove(AIndex: Integer): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  if (AIndex <= 1) or (AIndex >= FList.Count) then Exit;

  LLayout := TUdLayout(FList.Items[AIndex]);

  if FActive <> LLayout then
  begin
    Result := True;

    UnInitLayoutEvents(LLayout);
    if Assigned(FOnRemove) then FOnRemove(Self, LLayout, Result);

    if Result then
    begin
      Self.RemoveDocObject(LLayout);
      FList.Delete(AIndex);
    end;
  end;
end;

function TUdLayouts.Remove(AName: string): Boolean;
begin
  Result := Remove(IndexOf(AName));
end;

function TUdLayouts.Remove(AObject: TUdLayout): Boolean;
begin
  Result := Remove(IndexOf(AObject));
end;





//-------------------------------------------------------

function TUdLayouts.GetItem(AIndex: Integer): TUdLayout;
begin
  Result := nil;

  if (AIndex >= 0) and (AIndex < FList.Count) then
    Result := TUdLayout(FList.Items[AIndex]);
end;

function TUdLayouts.GetItem(AName: string): TUdLayout;
begin
  Result := GetItem(IndexOf(AName));
end;





//-------------------------------------------------------

procedure TUdLayouts.FSetActive(ALayout: TUdLayout);
begin
  if not Assigned(ALayout) or (ALayout = FActive) then Exit;

  if Assigned(FActive) then
  begin
    FActive.ActionClear();
    FActive.RemoveAllSelected();
    FActive.Axes.ClearZoomLog();
    if Assigned(FActive.ViewPort) then FActive.ViewPort.Actived := False;
  end;

  FActive := ALayout;
  FActive.Axes.ClearZoomLog();
  FActive.DrawPanel := Self.GetDrawPanel();

  if Assigned(FActive.ViewPort) then
  begin
    if not FActive.ViewPort.Inited then
      FActive.ReInitViewport();
    FActive.UpdateVisibleList();
  end;

  if Assigned(FOnSelect) then FOnSelect(Self, FActive);
end;


function TUdLayouts.SetActive(AIndex: Integer): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;

  LLayout := GetItem(AIndex);

  if Assigned(LLayout) and (LLayout <> FActive) and Self.RaiseBeforeModifyObject('Active') then
  begin
    FSetActive(LLayout);
    Self.RaiseAfterModifyObject('Active');
    Result := True;
  end;
end;

function TUdLayouts.SetActive(AName: string): Boolean;
begin
  Result := SetActive(IndexOf(AName));
end;

function TUdLayouts.SetActive(AObject: TUdLayout): Boolean;
begin
  Result := SetActive(IndexOf(AObject));
end;

procedure TUdLayouts.SetActive_(const AValue: TUdLayout);
begin
  Self.SetActive(AValue);
end;


function TUdLayouts.GetActiveIndex(): Integer;
begin
  Result := Self.IndexOf(FActive);
end;


procedure TUdLayouts.SetItem(AIndex: Integer; const AValue: TUdLayout);
var
  LLayout: TUdLayout;
begin
  LLayout := TUdLayout(FList.Items[AIndex]);

  if Assigned(LLayout) and Assigned(AValue) and (LLayout <> AValue) then
    LLayout.Assign(AValue);
end;




function TUdLayouts.GetDrawPanel(): TUdDrawPanel;
begin
  Result := nil;
  if Assigned(Self.Document) then
    Result := TUdDocument(Self.Document).DrawPanel;
end;

procedure TUdLayouts.SetDrawPanel(const AValue: TUdDrawPanel);
begin
  if Assigned(FActive) then FActive.DrawPanel := AValue;
end;





//------------------------------------------------------------------------------

function TUdLayouts.Add(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLayout) then
    Result := Self.Add(TUdLayout(AObj));
end;


function TUdLayouts.Insert(AIndex: Integer; AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLayout) and (FList.IndexOf(AObj) < 0) then
  begin
    if AIndex < 0 then AIndex := AIndex + FList.Count;
    if AIndex > FList.Count then AIndex := FList.Count;

    FList.Insert(AIndex, AObj);

    InitLayoutEvents(TUdLayout(AObj));
    if Assigned(FOnAdd) then FOnAdd(Self, TUdLayout(AObj));

    Self.AddDocObject(AObj);
    Result := True;
  end;
end;

function TUdLayouts.Remove(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLayout) then
    Result := Self.Remove(TUdLayout(AObj));
end;

function TUdLayouts.RemoveAt(AIndex: Integer): Boolean;
begin
  Result := Self.Remove(AIndex);
end;

function TUdLayouts.IndexOf(AObj: TUdObject): Integer;
begin
  Result := -1;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLayout) then
    Result := FList.IndexOf(TUdLayout(AObj));
end;

function TUdLayouts.Contains(AObj: TUdObject): Boolean;
begin
  Result := Self.IndexOf(AObj) >= 0;
end;






//------------------------------------------------------------------------------


function TUdLayouts.UpdateEntities(): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not Assigned(FList) then Exit;

  for I := 0 to FList.Count - 1 do
    TUdLayout(FList[I]).UpdateEntities();

  Result := True;
end;


procedure TUdLayouts.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  inherited;

  IntToStream(AStream, FList.Count);

  for I := 0 to FList.Count - 1 do
    TUdLayout(FList[I]).SaveToStream(AStream);

  IntToStream(AStream, IndexOf(FActive));
end;

procedure TUdLayouts.LoadFromStream(AStream: TStream);
var
  I, LCount: Integer;
  LLayout: TUdLayout;
begin
  Self.Clear(True);

  inherited;

  LCount := IntFromStream(AStream);
  for I := 0 to LCount - 1 do
  begin
    LLayout := TUdLayout.Create(Self.Document, Self.IsDocRegister);
    LLayout.Owner := Self;
    LLayout.LoadFromStream(AStream);

    InitLayoutEvents(LLayout);

    FList.Add(LLayout);
    Self.AddDocObject(LLayout, False);

    if I = 0 then FModel := FList[0];
  end;


  I := IntFromStream(AStream);
  if (I >= 0) and (I < FList.Count) then
    Self.SetActive(I)
  else
    FActive := FModel;

  if Assigned(FActive) then FActive.Invalidate();
//  Self.RaiseChanged();
end;





procedure TUdLayouts.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I: Integer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to FList.Count - 1 do
  begin
    TUdLayout(FList[I]).SaveToXml(LXmlNode.Add());
  end;

  LXmlNode.Prop['ActiveIndex'] := IntToStr(IndexOf(FActive));
end;

procedure TUdLayouts.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  LLayout: TUdLayout;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  Self.Clear(True);

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to LXmlNode.Count - 1 do
  begin
    LLayout := TUdLayout.Create(Self.Document, Self.IsDocRegister);
    LLayout.Owner := Self;
    LLayout.LoadFromXml(LXmlNode.Items[I]);

    InitLayoutEvents(LLayout);

    FList.Add(LLayout);
    Self.AddDocObject(LLayout, False);

    if I = 0 then FModel := FList[0];
  end;

  I := StrToIntDef(LXmlNode.Prop['ActiveIndex'], -1);
  if (I >= 0) and (I < FList.Count) then
    Self.SetActive(I)
  else
    FActive := FModel;

  if Assigned(FActive) then FActive.Invalidate();
//  Self.RaiseChanged();
end;



end.