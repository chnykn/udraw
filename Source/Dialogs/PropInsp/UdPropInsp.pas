{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPropInsp;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Types, TypInfo,
  StdCtrls, Grids,

  UdPropEditors;

type
  TUdPropsPage = class;
  TUdPropsPageItems = class;


  TUdPropItemByProc = procedure(AItem: TObject; AData: Pointer; var AResult: Boolean) of object;


  //*** TUdPropsObjectList ***//
  TUdPropsObjectList = class(TObject)
  private
    FItems: TList;
    FChangingCount: Boolean;

  protected
    function GetItems(AIndex: Integer): TObject;
    function GetCount: Integer;
    procedure SetCount(const Value: Integer);

    function DoFind(AData: Pointer; AItemByProc: TUdPropItemByProc): TObject;
    function DoSearch(AData: Pointer; AItemByProc: TUdPropItemByProc): TObject;

    function CreateItem: TObject; virtual;
    procedure ValidateAddition; virtual;
    procedure ValidateDeletion; virtual;

    procedure Change; virtual;
    procedure Added; virtual;
    procedure Deleted; virtual;

  public
    constructor Create;
    destructor Destroy; override;

    function Add: Integer;
    procedure Remove(AItem: TObject);
    procedure Delete(AIndex: Integer);
    procedure Clear;
    function IndexOf(AItem: TObject): Integer;

  public
    property Items[AIndex: Integer]: TObject read GetItems; default;
    property Count: Integer read GetCount write SetCount;
  end;




  //*** TUdPropsPageInplaceEdit ***//
  TUdPropsPageInplaceEdit = class(TInplaceEditList)
  private
    FChangingBounds: Boolean;
    FReadOnlyStyle: Boolean;

  protected
    procedure CreateParams(var Params: TCreateParams); override;

    procedure PickListMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
    procedure PickListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure WMLButtonDblClk(var Message: TWMMouse); message WM_LBUTTONDBLCLK;

    procedure DoEditButtonClick; override;
    procedure DoGetPickListItems; override;

    procedure DropDown; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure CloseUp(Accept: Boolean); override;
    procedure DblClick; override;

    procedure UpdateContents; override;
    procedure BoundsChanged; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    property ReadOnlyStyle: Boolean read FReadOnlyStyle;
  end;




  TUdPropsPageItemExpandable = (mieAuto, mieYes, mieNo);

  //*** TUdPropsPageItem ***//
  TUdPropsPageItem = class(TUdPropsObjectList)
  private
    FOwner: TUdPropsPage;
    FParent: TUdPropsPageItem;
    FExpanded: Boolean;
    FExpandable: TUdPropsPageItemExpandable;
    FCaption: string;
    FDisplayValue: string;
    FEditStyle: TEditStyle;
    FRow: Integer;
    FReadOnly: Boolean;
    FAutoUpdate: Boolean;
    FOwnerDrawPickList: Boolean;
    FDropDownList: Boolean;

  protected
    function CanExpand: Boolean;
    function Ident: Integer;
    function IsOnExpandButton(AX: Integer): Boolean;
    function GetItems(AIndex: Integer): TUdPropsPageItem;
    procedure SetExpandable(const Value: TUdPropsPageItemExpandable);
    procedure SetCaption(const Value: string);
    function GetLevel: Integer;
    procedure SetEditStyle(const Value: TEditStyle);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetAutoUpdate(const Value: Boolean);
    procedure SetOwnerDrawPickList(const Value: Boolean);
    procedure SetDropDownList(const Value: Boolean);
    function GetFullCaption: string;

  protected
    function CreateItem: TObject; override;
    procedure Change; override;
    procedure Deleted; override;
    function GetDisplayValue: string; virtual;
    procedure SetDisplayValue(const Value: string); virtual;
    procedure EditButtonClick; dynamic;
    procedure EditDblClick; dynamic;
    procedure GetEditPickList(APickList: TStrings); virtual;
    procedure PickListMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); virtual;
    procedure PickListMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); virtual;
    procedure PickListDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); virtual;

  public
    constructor Create(AOwner: TUdPropsPage; AParent: TUdPropsPageItem); virtual;
    destructor Destroy; override;
    procedure Expand;
    procedure Collapse;

  public
    property FullCaption: string read GetFullCaption;
    property Owner: TUdPropsPage read FOwner;
    property Parent: TUdPropsPageItem read FParent;
    property Expandable: TUdPropsPageItemExpandable read FExpandable write SetExpandable;
    property Expanded: Boolean read FExpanded;
    property Level: Integer read GetLevel;
    property Caption: string read FCaption write SetCaption;
    property DisplayValue: string read GetDisplayValue write SetDisplayValue;
    property EditStyle: TEditStyle read FEditStyle write SetEditStyle;
    property DropDownList: Boolean read FDropDownList write SetDropDownList;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property AutoUpdate: Boolean read FAutoUpdate write SetAutoUpdate;
    property OwnerDrawPickList: Boolean read FOwnerDrawPickList write SetOwnerDrawPickList;
    property Items[AIndex: Integer]: TUdPropsPageItem read GetItems; default;
  end;


  //*** TUdPropsPageItems ***//
  TUdPropsPageItems = class(TUdPropsObjectList)
  private
    FOwner: TUdPropsPage;

  protected
    function GetItems(AIndex: Integer): TUdPropsPageItem;
    function CreateItem: TObject; override;
    procedure Change; override;

  public
    constructor Create(AOwner: TUdPropsPage);

    property Owner: TUdPropsPage read FOwner;
    property Items[AIndex: Integer]: TUdPropsPageItem read GetItems; default;

  end;





  TUdPropsPageState = set of (ppsMovingSplitter, ppsChanged, ppsDestroying, ppsUpdatingEditorContent);

  //*** TUdPropsPage ***//
  TUdPropsPage = class(TCustomGrid)
  private
    FState          : TUdPropsPageState;
    FOldRow         : Integer;
    FSplitterOffset : Integer;
    FEditText       : string;
    FItems          : TUdPropsPageItems;
    FRows           : array of TUdPropsPageItem;
    FUpdateCount    : Integer;
    FValuesColor    : TColor;
    FValuesBackColor: TColor;
    FBitmap         : Graphics.TBitmap;
    FBitmapBkColor  : TColor;
    FBrush          : HBRUSH;
    FCellBitmap     : TBitmap;

  protected
    procedure ItemsChange;
    function IsOnSplitter(AX: Integer): Boolean;
    procedure UpdateColWidths;
    procedure UpdateScrollBar;
    procedure AdjustTopRow;
    function ItemByRow(ARow: Integer): TUdPropsPageItem;
    procedure UpdateData(ARow: Integer);
    procedure UpdatePattern;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure CMDesignHitTest(var Msg: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMExit(var Message: TMessage); message CM_EXIT;
    function GetSplitter: Integer;
    procedure SetSplitter(const Value: Integer);
    procedure SetValuesColor(const Value: TColor);
    procedure SetValuesBackColor(const Value: TColor);
    function GetActiveItem: TUdPropsPageItem;

  protected
    procedure DoGetCaption(const AItem: TUdPropsPageItem; var APropName: string); virtual;
    procedure DoGetValue(const AItem: TUdPropsPageItem; var APropValue: string); virtual;
    procedure DoBeforeSetValue(const AItem: TUdPropsPageItem; var APropValue: string; var AHandled: Boolean); virtual;
    procedure DoAfterSetValue(const AItem: TUdPropsPageItem; var APropValue: string); virtual;

    function DoGetPickList(const AItem: TUdPropsPageItem; aList: TStrings): Boolean; virtual;

    function CreateItem(AParent: TUdPropsPageItem): TUdPropsPageItem; virtual;
    procedure ItemExpanded(AItem: TUdPropsPageItem); virtual;
    procedure ItemCollapsed(AItem: TUdPropsPageItem); virtual;
    function GetItemCaptionColor(AItem: TUdPropsPageItem): TColor; virtual;

    procedure CheckActiveItem; virtual;
    procedure DrawPropCaption(AItem: TUdPropsPageItem; ACanvas: TCanvas; R: TRect; Str: string); virtual;
    procedure DrawPropValue(AItem: TUdPropsPageItem; ACanvas: TCanvas; R: TRect; Str: string); virtual;


    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
    function CreateEditor: TInplaceEdit; override;
    procedure Paint; override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function GetEditStyle(ACol, ARow: Longint): TEditStyle; override;
    function CanEditModify: Boolean; override;
    function GetEditText(ACol, ARow: Longint): string; override;
    procedure SetEditText(ACol, ARow: Longint; const Value: string); override;
    procedure CreateHandle; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure TopLeftChanged; override;
    procedure SizeChanged(OldColCount, OldRowCount: Longint); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CanFocus: Boolean; override;

    procedure BeginUpdate;
    procedure EndUpdate;

  public
    property Items: TUdPropsPageItems read FItems;
    property ActiveItem: TUdPropsPageItem read GetActiveItem;

  published
    property Splitter: Integer read GetSplitter write SetSplitter;
    property ValuesColor: TColor read FValuesColor write SetValuesColor default clNavy;
    property ValuesBackColor: TColor read FValuesBackColor write SetValuesBackColor default clWhite;

    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color default clBtnFace;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnStartDrag;
  end;




//-----------------------------------------------------------------
{ TUdPropertyInspector }

type
  TUdPropertyInspector = class;

  TUdPropertyInspectorItem = class(TUdPropsPageItem)
  private
    FEditor: TUdPropEditor;
    FDisplayValue: string;

  protected
    procedure EditorModified(Sender: TObject);
    procedure EditorGetComponent(Sender: TObject; const AComponentName: string; var AComponent: TComponent);
    procedure EditorGetComponentNames(Sender: TObject; AClass: TComponentClass; AResult: TStrings);
    procedure EditorGetComponentName(Sender: TObject; AComponent: TComponent; var AName: string);
    procedure DeGetPickList(AResult: TStrings);
    procedure SetEditor(const Value: TUdPropEditor);

    function GetDisplayValue: string; override;
    procedure SetDisplayValue(const Value: string); override;
    procedure GetEditPickList(APickList: TStrings); override;
    procedure EditButtonClick; override;
    procedure EditDblClick; override;
    procedure PickListMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); override;
    procedure PickListMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); override;
    procedure PickListDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;

  public
    destructor Destroy; override;
    procedure UpdateParams;
    property Editor: TUdPropEditor read FEditor write SetEditor; // Editor is destroyed with "Self"

  end;



  TUdPropertyInspectorEditorDescr = record
    TypeInfo: PTypeInfo;
    ObjectClass: TClass;
    PropName: string;
    EditorClass: TUdPropEditorClass;
  end;

  TUdPropFilterPropEvent      = procedure(Sender: TObject; AInstance: TPersistent; APropInfo: PPropInfo; var AIncludeProp: Boolean) of object;
  TUdPropGetCaptionColorEvent = procedure(Sender: TObject; APropTypeInfo: PTypeInfo; APropName: string; var AColor: TColor) of object;
  TUdPropGetEditorClassEvent  = procedure(Sender: TObject; AInstance: TPersistent; APropInfo: PPropInfo; var AEditorClass: TUdPropEditorClass) of object;
  TUdPropGetValueEvent        = procedure(Sender: TObject; APropTypeInfo: PTypeInfo; var AValue: string) of object;
  TUdPropBeforeSetValueEvent  = procedure(Sender: TObject; APropName: string; APropTypeInfo: PTypeInfo; var AValue: string; var AHandled: Boolean) of object;
  TUdPropAfterSetValueEvent   = procedure(Sender: TObject; APropName: string; APropTypeInfo: PTypeInfo; var AValue: string) of object;
  TUdPropGetPickListEvent     = procedure(Sender: TObject; APropTypeInfo: PTypeInfo; AValues: TStrings; var OK: Boolean) of object;
  TUdPropModifyEvent          = procedure(Sender: TObject; APropInfo: PPropInfo) of object;

  TUdPropertyInspectorPropKind = (pkProperties, pkEvents, pkReadOnly);
  TUdPropertyInspectorPropKinds = set of TUdPropertyInspectorPropKind;

  TUdPropertyInspector = class(TUdPropsPage)
  private
    FObjects      : TList;
    FObjectsLocked: Boolean;
    FRecentCount  : Integer;
    FRecentProps  : TStrings;
    FOldProp      : string;
    FOldObjClass  : TPersistentClass;
    FObjectChange : Boolean;
    FSortList     : Boolean;
    FPropKinds    : TUdPropertyInspectorPropKinds;

    FComponentRefColor      : TColor;
    FComponentRefChildColor : TColor;
    FExpandComponentRefs    : Boolean;
    FReadOnly               : Boolean;
    FDesigner               : Pointer;

    FOnGetCaptionColor   : TUdPropGetCaptionColorEvent;
    FOnGetCaption        : TUdPropGetValueEvent;
    FOnGetValue          : TUdPropGetValueEvent;
    FOnBeforeSetValue    : TUdPropBeforeSetValueEvent;
    FOnAfterSetValue     : TUdPropAfterSetValueEvent;
    FOnGetPickList       : TUdPropGetPickListEvent;
    FOnObjectChange      : TNotifyEvent;
    FOnGetComponent      : TUdPropGetComponentEvent;
    FOnGetComponentNames : TUdPropGetComponentNamesEvent;
    FOnModified          : TUdPropModifyEvent;
    FOnGetComponentName  : TUdPropGetComponentNameEvent;
    FOnFilterProp        : TUdPropFilterPropEvent;
    FOnGetEditorClass    : TUdPropGetEditorClassEvent;

  protected
    procedure Change;
    procedure UpdateItems;
    procedure InternalModified(APropInfo: PPropInfo);
    procedure CheckObjectsLock;
    function GetObjects(AIndex: Integer): TPersistent;
    procedure SetObjects(AIndex: Integer; const Value: TPersistent);
    function GetObjectCount: Integer;
    procedure SetPropKinds(const Value: TUdPropertyInspectorPropKinds);
    procedure SetComponentRefColor(const Value: TColor);
    procedure SetComponentRefChildColor(const Value: TColor);
    procedure SetExpandComponentRefs(const Value: Boolean);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetDesigner(const Value: Pointer);
    procedure DoObjectChange;
    procedure SetRecentCount(Value: Integer);
    procedure SetSortList(const Value: Boolean);

    procedure CheckActiveItem; override;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
    function CreateItem(AParent: TUdPropsPageItem): TUdPropsPageItem; override;
    procedure DrawPropValue(AItem: TUdPropsPageItem; ACanvas: TCanvas; R: TRect; Str: string); override;
    procedure ItemExpanded(AItem: TUdPropsPageItem); override;
    procedure ItemCollapsed(AItem: TUdPropsPageItem); override;
    function GetItemCaptionColor(AItem: TUdPropsPageItem): TColor; override;
    function GetEditorClass(AInstance: TPersistent; APropInfo: PPropInfo): TUdPropEditorClass; virtual;
    procedure GetComponent(const AComponentName: string; var AComponent: TComponent); virtual;
    procedure GetComponentNames(AClass: TComponentClass; AResult: TStrings); virtual;
    procedure GetComponentName(AComponent: TComponent; var AName: string); virtual;
    procedure FilterProp(AInstance: TPersistent; APropInfo: PPropInfo; var AIncludeProp: Boolean); virtual;
    procedure GetCaptionColor(APropTypeInfo: PTypeInfo; const APropName: string; var AColor: TColor); virtual;

    procedure DoGetCaption(const AItem: TUdPropsPageItem; var APropName: string); override;
    procedure DoGetValue(const AItem: TUdPropsPageItem; var APropValue: string); override;
    procedure DoBeforeSetValue(const AItem: TUdPropsPageItem; var APropValue: string; var AHandled: Boolean); override;
    procedure DoAfterSetValue(const AItem: TUdPropsPageItem; var APropValue: string); override;
    function DoGetPickList(const AItem: TUdPropsPageItem; aList: TStrings): Boolean; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Add(AObject: TPersistent): Boolean;
    function AddObjects(AObjects: TList): Boolean;
    function Delete(AIndex: Integer): Boolean;
    function Remove(AObject: TPersistent): Boolean;
    function Clear(): Boolean;
    function IndexOf(AObject: TPersistent): Integer;
    function Modified(): Boolean;
    procedure AddRecentProp(ObjClass: TPersistentClass; FullPropName: string);

  public
    property Objects[AIndex: Integer]: TPersistent read GetObjects write SetObjects;
    property ObjectCount: Integer read GetObjectCount;
    property RecentCount: Integer read FRecentCount write SetRecentCount;
    property SortList: Boolean read FSortList write SetSortList default True;
    property Designer: Pointer read FDesigner write SetDesigner;
    property ObjectsLocked: Boolean read FObjectsLocked;

  published
    property PropKinds: TUdPropertyInspectorPropKinds read FPropKinds write SetPropKinds default [pkProperties, pkReadOnly];
    property ComponentRefColor: TColor read FComponentRefColor write SetComponentRefColor default clMaroon;
    property ComponentRefChildColor: TColor read FComponentRefChildColor write SetComponentRefChildColor default clGreen;
    property ExpandComponentRefs: Boolean read FExpandComponentRefs write SetExpandComponentRefs default True;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;

    property OnGetComponent      : TUdPropGetComponentEvent      read FOnGetComponent      write FOnGetComponent;
    property OnGetComponentNames : TUdPropGetComponentNamesEvent read FOnGetComponentNames write FOnGetComponentNames;
    property OnGetComponentName  : TUdPropGetComponentNameEvent  read FOnGetComponentName  write FOnGetComponentName;
    property OnModified          : TUdPropModifyEvent            read FOnModified          write FOnModified;
    property OnGetCaptionColor   : TUdPropGetCaptionColorEvent   read FOnGetCaptionColor   write FOnGetCaptionColor;
    property OnGetCaption        : TUdPropGetValueEvent          read FOnGetCaption        write FOnGetCaption;
    property OnGetValue          : TUdPropGetValueEvent          read FOnGetValue          write FOnGetValue;
    property OnBeforeSetValue    : TUdPropBeforeSetValueEvent    read FOnBeforeSetValue    write FOnBeforeSetValue;
    property OnAfterSetValue     : TUdPropAfterSetValueEvent     read FOnAfterSetValue     write FOnAfterSetValue;
    property OnGetPickList       : TUdPropGetPickListEvent       read FOnGetPickList       write FOnGetPickList;
    property OnObjectChange      : TNotifyEvent                  read FOnObjectChange      write FOnObjectChange;
    property OnFilterProp        : TUdPropFilterPropEvent        read FOnFilterProp        write FOnFilterProp;
    property OnGetEditorClass    : TUdPropGetEditorClassEvent    read FOnGetEditorClass    write FOnGetEditorClass;
  end;


implementation

uses
  SysUtils, Dialogs;


type
  TFriendCustomListBox = class(TCustomListBox);



//==================================================================================================

{ TUdPropsObjectList }

constructor TUdPropsObjectList.Create;
begin
  inherited;
  FItems := TList.Create;
end;

destructor TUdPropsObjectList.Destroy;
begin
  Self.Clear();
  FItems.Free;
  inherited;
end;


//-------------------------------------------------------------------------

function TUdPropsObjectList.GetCount: Integer;
begin
  Result := FItems.Count;
end;


function TUdPropsObjectList.GetItems(AIndex: Integer): TObject;
begin
  Result := FItems[AIndex];
end;


procedure TUdPropsObjectList.SetCount(const Value: Integer);
begin
  FChangingCount := True;
  try
    if Value > Count then
      while Count < Value do Self.Add()
    else if Value < Count then
      while Count > Value do Delete(Count - 1);
  finally
    FChangingCount := False;
  end;
  Change;
end;


//-------------------------------------------------------------------------

function TUdPropsObjectList.DoFind(AData: Pointer; AItemByProc: TUdPropItemByProc): TObject;
var
  I: Integer;
  LResult: Boolean;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    LResult := False;
    AItemByProc(Items[I], AData, LResult);
    if LResult then
    begin
      Result := Items[I];
      Break;
    end;
  end;
end;

function TUdPropsObjectList.DoSearch(AData: Pointer; AItemByProc: TUdPropItemByProc): TObject;
var
  I: Integer;
begin
  Result := DoFind(AData, AItemByProc);
  if Result = nil then
    for I := 0 to Count - 1 do
      if (Items[I] <> nil) and (Items[I] is TUdPropsObjectList) then
      begin
        Result := TUdPropsObjectList(Items[I]).DoSearch(AData, AItemByProc);
        if Result <> nil then Break;
      end;
end;



//-------------------------------------------------------------------------

function TUdPropsObjectList.CreateItem: TObject;
begin
  Result := nil;
end;

procedure TUdPropsObjectList.ValidateAddition;
begin
  // ... ...
end;


procedure TUdPropsObjectList.ValidateDeletion;
begin
  // ... ...
end;


procedure TUdPropsObjectList.Change;
begin
  // ... ...
end;


procedure TUdPropsObjectList.Added;
begin
  // ... ...
end;


procedure TUdPropsObjectList.Deleted;
begin
  // ... ...
end;



//-------------------------------------------------------------------------

function TUdPropsObjectList.Add: Integer;
begin
  ValidateAddition;
  Result := FItems.Add(CreateItem);
  Self.Added();
  if not FChangingCount then Self.Change();
end;

procedure TUdPropsObjectList.Delete(AIndex: Integer);
begin
  ValidateDeletion();
  TObject(FItems[AIndex]).Free;
  FItems.Delete(AIndex);
  Self.Deleted();
  if not FChangingCount then Self.Change();
end;

function TUdPropsObjectList.IndexOf(AItem: TObject): Integer;
begin
  Result := FItems.IndexOf(AItem);
end;

procedure TUdPropsObjectList.Remove(AItem: TObject);
var
  N: Integer;
begin
  N := FItems.IndexOf(AItem);
  if N >= 0 then Delete(N);
end;

procedure TUdPropsObjectList.Clear;
begin
  Self.SetCount(0);
end;




//==================================================================================================
{ TUdPropsPageInplaceEdit }


constructor TUdPropsPageInplaceEdit.Create(AOwner: TComponent);
begin
  inherited;
  Self.DropDownRows := 8;
  Self.ButtonWidth  := 16;
end;

procedure TUdPropsPageInplaceEdit.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and not ES_MULTILINE;
end;


//------------------------------------------------------------------------

procedure TUdPropsPageInplaceEdit.PickListMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
var
  LItem: TUdPropsPageItem;
begin
  LItem := TUdPropsPage(Grid).ActiveItem;
  if (LItem <> nil) and LItem.OwnerDrawPickList then
    LItem.PickListMeasureHeight(PickList.Items[Index], PickList.Canvas, Height);
end;

procedure TUdPropsPageInplaceEdit.PickListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LItem: TUdPropsPageItem;
begin
  LItem := TUdPropsPage(Grid).ActiveItem;
  if (LItem <> nil) and LItem.OwnerDrawPickList then
    LItem.PickListDrawValue(PickList.Items[Index], PickList.Canvas, Rect, odSelected in State);
end;

procedure TUdPropsPageInplaceEdit.WMLButtonDblClk(var Message: TWMMouse);
begin
  if OverButton(Point(Message.XPos, Message.YPos)) then
    PostMessage(Handle, WM_LBUTTONDOWN, TMessage(Message).WParam, TMessage(Message).LParam)
  else
    inherited;
  SelectAll;
end;


//------------------------------------------------------------------------

procedure TUdPropsPageInplaceEdit.BoundsChanged;
begin
  inherited;
  if not FChangingBounds then
  begin
    FChangingBounds := True;
    try
      UpdateLoc(Rect(Left, Top, Left + Width, Top + Height - 2));
      //Move(Rect(Left, Top, Left + Width, Top + Height - 2));
      SendMessage(Handle, EM_SETMARGINS, EC_RIGHTMARGIN,
        MakeLong(0, ButtonWidth * Ord(EditStyle <> esSimple) + 2));
    finally
      FChangingBounds := False;
    end;
  end;
end;


procedure TUdPropsPageInplaceEdit.CloseUp(Accept: Boolean);
begin
  inherited CloseUp(Accept);
  if Accept then
    with TUdPropsPage(Owner) do
    begin
      UpdateData(Row);
      SelectAll;
    end;
end;


procedure TUdPropsPageInplaceEdit.DblClick;
begin
  if TUdPropsPage(Grid).ActiveItem <> nil then
    TUdPropsPage(Grid).ActiveItem.EditDblClick;
end;


procedure TUdPropsPageInplaceEdit.DoEditButtonClick;
begin
  if TUdPropsPage(Grid).ActiveItem <> nil then
    TUdPropsPage(Grid).ActiveItem.EditButtonClick;
end;


procedure TUdPropsPageInplaceEdit.DoGetPickListItems;
begin
  if TUdPropsPage(Grid).ActiveItem <> nil then
  begin
    PickList.Items.Clear;
    TUdPropsPage(Grid).ActiveItem.GetEditPickList(PickList.Items);
    PickList.ItemIndex := PickList.Items.IndexOf(Text);
  end;
end;


procedure TUdPropsPageInplaceEdit.DropDown;
var
  LP: TPoint;
  I, LY, LVisItemCount, LItemHW, LHW: Integer;
  LItem: TUdPropsPageItem;
begin
  LItem := TUdPropsPage(Grid).ActiveItem;
  if not ListVisible and (LItem <> nil) then
  begin
    if LItem.OwnerDrawPickList then
    begin
      TFriendCustomListBox(PickList).Style := lbOwnerDrawVariable;
      TFriendCustomListBox(PickList).OnMeasureItem := PickListMeasureItem;
      TFriendCustomListBox(PickList).OnDrawItem := PickListDrawItem;
    end
    else
    begin
      TFriendCustomListBox(PickList).Style := lbStandard;
      TFriendCustomListBox(PickList).OnMeasureItem := nil;
      TFriendCustomListBox(PickList).OnDrawItem := nil;
    end;

    ActiveList.Width := Width;
    if ActiveList = PickList then
    begin
      { Get values }
      DoGetPickListItems;
      TFriendCustomListBox(PickList).Color := Color;
      TFriendCustomListBox(PickList).Font := Font;
      { Calc initial visible item count }
      if (DropDownRows > 0) and (PickList.Items.Count >= DropDownRows) then
        LVisItemCount := DropDownRows
      else
        LVisItemCount := PickList.Items.Count;
      { Calc PickList height }
      if LItem.OwnerDrawPickList then
      begin
        LHW := 4;
        for I := 0 to LVisItemCount - 1 do
        begin
          LItemHW := TFriendCustomListBox(PickList).ItemHeight;
          LItem.PickListMeasureHeight(PickList.Items[I], PickList.Canvas, LItemHW);
          Inc(LHW, LItemHW);
        end;
      end
      else
        LHW := LVisItemCount * TFriendCustomListBox(PickList).ItemHeight + 4;
      if PickList.Items.Count > 0 then
        PickList.Height := LHW
      else
        PickList.Height := 20;
      { Set PickList selected item }
      if Text = '' then
        PickList.ItemIndex := -1
      else
        PickList.ItemIndex := PickList.Items.IndexOf(Text);
      { Calc PickList width }
      LHW := PickList.ClientWidth;
      for I := 0 to PickList.Items.Count - 1 do
      begin
        LItemHW := PickList.Canvas.TextWidth(PickList.Items[I]);
        if LItem.OwnerDrawPickList then
          LItem.PickListMeasureWidth(PickList.Items[I], PickList.Canvas, LItemHW);
        if LItemHW > LHW then LHW := LItemHW;
      end;
      PickList.ClientWidth := LHW;
    end;
    LP := Parent.ClientToScreen(Point(Left, Top));
    LY := LP.Y + Height;
    if LY + ActiveList.Height > Screen.Height then LY := LP.Y - ActiveList.Height;
    SetWindowPos(ActiveList.Handle, HWND_TOP, LP.X, LY, 0, 0, SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
    ListVisible := True;
    Invalidate;
    Windows.SetFocus(Handle);
  end;
end;


procedure _KillMessage(AWnd: HWnd; AMsg: Integer);
var
  LM: TMsg;
begin
  LM.Message := 0;
  if PeekMessage(LM, AWnd, AMsg, AMsg, pm_Remove) and (LM.Message = WM_QUIT) then
    PostQuitMessage(LM.wparam);
end;


procedure TUdPropsPageInplaceEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      begin
        TUdPropsPage(Grid).UpdateData(TUdPropsPage(Grid).Row);
        if Shift = [ssCtrl] then
        begin
          _KillMessage(Handle, WM_CHAR);
          DblClick;
          SelectAll;
        end;
        Key := 0;
      end;
    VK_ESCAPE: if TUdPropsPage(Grid).ActiveItem <> nil then
      begin
        Text := TUdPropsPage(Grid).ActiveItem.DisplayValue;
        CloseUp(False);
        SelectAll;
        Key := 0;
      end;
    VK_HOME: if (SelStart = 0) and (SelLength > 0) then
        SelLength := 0;
    VK_END: if (SelStart + SelLength = System.Length(Text)) and (SelLength > 0) then
        SelLength := 0;
  end;
  if TUdPropsPage(Grid).ActiveItem <> nil then
    if TUdPropsPage(Grid).ActiveItem.DropDownList then
    begin
      //Self.DropDown;
      _KillMessage(Handle, WM_CHAR);
      Exit;
    end;

  if Key <> 0 then inherited;
end;



procedure TUdPropsPageInplaceEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if ListVisible and (not OverButton(Point(x, y))) then
    CloseUp(False);
  TUdPropsPage(Grid).ShowEditor;
end;


procedure TUdPropsPageInplaceEdit.UpdateContents;
begin
  Include(TUdPropsPage(Grid).FState, ppsUpdatingEditorContent);
  try
    inherited;
    if not EditCanModify then
    begin
      Color := TUdPropsPage(Owner).Color;
      Font.Color := TUdPropsPage(Owner).ValuesColor;
    end
    else
    begin
      Color := clWindow;
      Font.Color := clWindowText;
    end;
    FReadOnlyStyle := not EditCanModify;
  finally
    Exclude(TUdPropsPage(Grid).FState, ppsUpdatingEditorContent);
  end;
end;






//==================================================================================================
{ TUdPropsPageItem }

constructor TUdPropsPageItem.Create(AOwner: TUdPropsPage; AParent: TUdPropsPageItem);
begin
  inherited Create;
  FOwner := AOwner;
  FParent := AParent;
  FRow := -1;
end;

destructor TUdPropsPageItem.Destroy;
begin
  if FRow <> -1 then
  begin
    FOwner.FRows[FRow] := nil;
    FRow := -1;
  end;
  inherited;
end;


procedure TUdPropsPageItem.Expand;
begin
  if not FExpanded and CanExpand then
  begin
    Owner.BeginUpdate;
    try
      FExpanded := True;
      Owner.ItemExpanded(Self);
      Change;
    finally
      Owner.EndUpdate;
    end;
  end;
end;

procedure TUdPropsPageItem.Collapse;
begin
  if FExpanded then
  begin
    Owner.BeginUpdate;
    try
      FExpanded := False;
      Owner.ItemCollapsed(Self);
      Change;
    finally
      Owner.EndUpdate;
    end;
  end;
end;


//------------------------------------------------------------------------

function TUdPropsPageItem.CanExpand: Boolean;
begin
  Result := (Expandable = mieYes) or ((Expandable = mieAuto) and (Count > 0));
end;

function TUdPropsPageItem.Ident: Integer;
begin
  Result := Level * 10;
end;

function TUdPropsPageItem.IsOnExpandButton(AX: Integer): Boolean;
begin
  Result := (AX >= Ident) and (AX <= Ident + 13);
end;

function TUdPropsPageItem.GetItems(AIndex: Integer): TUdPropsPageItem;
begin
  Result := TUdPropsPageItem(inherited Items[AIndex]);
end;

procedure TUdPropsPageItem.SetExpandable(const Value: TUdPropsPageItemExpandable);
begin
  if FExpandable <> Value then
  begin
    FExpandable := Value;
    FExpanded := FExpanded and CanExpand;
    Change;
  end;
end;

procedure TUdPropsPageItem.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Change;
  end;
end;

function TUdPropsPageItem.GetLevel: Integer;
var
  LParent: TUdPropsPageItem;
begin
  Result := 0;
  LParent := Parent;
  while LParent <> nil do
  begin
    Inc(Result);
    LParent := LParent.Parent;
  end;
end;

procedure TUdPropsPageItem.SetEditStyle(const Value: TEditStyle);
begin
  if FEditStyle <> Value then
  begin
    FEditStyle := Value;
    Change;
  end;
end;

procedure TUdPropsPageItem.SetReadOnly(const Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    Change;
  end;
end;

procedure TUdPropsPageItem.SetAutoUpdate(const Value: Boolean);
begin
  if FAutoUpdate <> Value then
  begin
    FAutoUpdate := Value;
    Change;
  end;
end;


procedure TUdPropsPageItem.SetOwnerDrawPickList(const Value: Boolean);
begin
  if FOwnerDrawPickList <> Value then
  begin
    FOwnerDrawPickList := Value;
    Change;
  end;
end;

procedure TUdPropsPageItem.SetDropDownList(const Value: Boolean);
begin
  FDropDownList := Value;
  Change;
end;


function TUdPropsPageItem.GetFullCaption: string;
var
  LParent: TUdPropsPageItem;
begin
  Result := Caption;
  LParent := Parent;
  while LParent <> nil do
  begin
    Result := LParent.Caption + '.' + Result;
    LParent := LParent.Parent;
  end;
end;



//------------------------------------------------------------------------

procedure TUdPropsPageItem.Change;
begin
  Owner.ItemsChange;
end;

function TUdPropsPageItem.CreateItem: TObject;
begin
  Result := FOwner.CreateItem(Self);
end;

procedure TUdPropsPageItem.Deleted;
begin
  FExpanded := FExpanded and CanExpand;
end;

function TUdPropsPageItem.GetDisplayValue: string;
begin
  Result := FDisplayValue;
end;

procedure TUdPropsPageItem.SetDisplayValue(const Value: string);
begin
  if FDisplayValue <> Value then
  begin
    FDisplayValue := Value;
    Change;
  end;
end;


procedure TUdPropsPageItem.EditButtonClick;
begin
  // ... ...
end;

procedure TUdPropsPageItem.EditDblClick;
begin
  // ... ...
end;

procedure TUdPropsPageItem.GetEditPickList(APickList: TStrings);
begin
  // ... ...
end;

procedure TUdPropsPageItem.PickListDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
begin
  // ... ...
end;

procedure TUdPropsPageItem.PickListMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer);
begin
  // ... ...
end;

procedure TUdPropsPageItem.PickListMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer);
begin
  // ... ...
end;





//==================================================================================================
{ TUdPropsPageItems }

constructor TUdPropsPageItems.Create(AOwner: TUdPropsPage);
begin
  inherited Create;
  FOwner := AOwner;
end;


function TUdPropsPageItems.GetItems(AIndex: Integer): TUdPropsPageItem;
begin
  Result := TUdPropsPageItem(inherited Items[AIndex]);
end;


procedure TUdPropsPageItems.Change;
begin
  Owner.ItemsChange;
end;

function TUdPropsPageItems.CreateItem: TObject;
begin
  Result := FOwner.CreateItem(nil);
end;






//==================================================================================================
{ TUdPropsPage }

constructor TUdPropsPage.Create(AOwner: TComponent);
begin
  inherited;
  Width := 200;
  Height := 300;
  DefaultColWidth  := 84;
  DefaultRowHeight := 16;
  ColCount := 2;
  RowCount := 0;
  FixedRows := 0;
  FixedCols := 1;
  Color := clBtnFace;
  Options := [goEditing, goAlwaysShowEditor, goThumbTracking];
  DesignOptionsBoost := [];
  FSaveCellExtents := False;
  ScrollBars := ssNone;
  DefaultDrawing := False;
  FItems := TUdPropsPageItems.Create(Self);
  FValuesColor := clNavy;
  FValuesBackColor := clWhite;
  FBitmap := Graphics.TBitmap.Create;
  UpdatePattern;
  FCellBitmap := Graphics.TBitmap.Create;
end;

destructor TUdPropsPage.Destroy;
begin
  Include(FState, ppsDestroying);
  FItems.Free;
  FBitmap.Free;
  FCellBitmap.Free;
  if FBrush <> 0 then
    DeleteObject(FBrush);
  inherited;
end;

function TUdPropsPage.CanFocus: Boolean;
var
  LParentForm: TCustomForm;
begin
  Result := inherited CanFocus();
  if Result then
  begin
    LParentForm := GetParentForm(Self);
    Result := Pos('FloatingWindowParent', LParentForm.ClassName) <= 0;
  end;
end;



function TUdPropsPage.CreateEditor: TInplaceEdit;
begin
  Result := TUdPropsPageInplaceEdit.Create(Self);
end;

procedure TUdPropsPage.DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);

  procedure _DrawExpandButton(AX, AY: Integer; AExpanded: Boolean);
  begin
    with FCellBitmap.Canvas do
    begin
      Pen.Color := clBlack;
      Brush.Color := clWhite;
      Rectangle(AX, AY, AX + 9, AY + 9);
      Polyline([Point(AX + 2, AY + 4), Point(AX + 7, AY + 4)]);
      if not AExpanded then
        Polyline([Point(AX + 4, AY + 2), Point(AX + 4, AY + 7)]);
    end;
  end;

var
  LS: string;
  LIdent: Integer;
  LItem: TUdPropsPageItem;
  LExpanded: Boolean;
  LExpandButton: Boolean;
  LCaptionColor: TColor;
begin
  if (ACol <> Col) or (ARow <> Row) or (InplaceEditor = nil) then
  begin
    FCellBitmap.Width := ARect.Right - ARect.Left;
    FCellBitmap.Height := ARect.Bottom - ARect.Top;

    { Fill }
    with FCellBitmap.Canvas do
    begin
      LItem := ItemByRow(ARow);

      Brush.Color := Color;
      Font := Self.Font;
      if LItem <> nil then
      begin
        LExpandButton := LItem.CanExpand;
        LExpanded := LItem.Expanded;
        LIdent := LItem.Ident;
        LCaptionColor := GetItemCaptionColor(LItem);

        if ACol = 0 then
        begin
          LS := LItem.Caption;
          DoGetCaption(LItem, LS);
          Font.Color := LCaptionColor;
          DrawPropCaption(LItem, FCellBitmap.Canvas, Rect(0, 0, FCellBitmap.Width, FCellBitmap.Height), LS);
        end
        else
        begin
          if not LItem.ReadOnly then Brush.Color := FValuesBackColor;

          LS := LItem.DisplayValue;
          Font.Color := ValuesColor;
          DrawPropValue(LItem, FCellBitmap.Canvas, Rect(0, 0, FCellBitmap.Width, FCellBitmap.Height), LS);
        end;
      end
      else
      begin
        LS := '';
        LExpandButton := False;
        LExpanded := False;
        LIdent := 0;

        TextRect(
          Rect(0, 0, FCellBitmap.Width, FCellBitmap.Height),
          1 + (12 + LIdent) * Ord(ACol = 0),
          1,
          LS
          );
      end;

      if LExpandButton and (ACol = 0) then
        _DrawExpandButton(2 + LIdent, 3, LExpanded);

      if ACol = 0 then
      begin
        { Splitter }
        Pen.Color := clBtnShadow;
        Polyline([Point(FCellBitmap.Width - 2, 0), Point(FCellBitmap.Width - 2, FCellBitmap.Height)]);
        Pen.Color := clBtnHighlight;
        Polyline([Point(FCellBitmap.Width - 1, 0), Point(FCellBitmap.Width - 1, FCellBitmap.Height)]);
      end;
      if ARow = Row - 1 then
      begin
        { Selected row ages }
        Pen.Color := cl3DDkShadow;
        Polyline([Point(0, FCellBitmap.Height - 2), Point(FCellBitmap.Width, FCellBitmap.Height - 2)]);
        Pen.Color := clBtnShadow;
        Polyline([Point(0, FCellBitmap.Height - 1), Point(FCellBitmap.Width, FCellBitmap.Height - 1)]);
      end
      else if ARow = Row then
      begin
        { Selected row ages }
        if ACol = 0 then
        begin
          Pen.Color := cl3DDkShadow;
          Polyline([Point(0, 0), Point(0, FCellBitmap.Height)]);
          Pen.Color := clBtnShadow;
          Polyline([Point(1, 0), Point(1, FCellBitmap.Height)]);
        end;
        Pen.Color := clBtnHighlight;
        Polyline([Point(0, FCellBitmap.Height - 2), Point(FCellBitmap.Width, FCellBitmap.Height - 2)]);
        Pen.Color := cl3DLight;
        Polyline([Point(0, FCellBitmap.Height - 1), Point(FCellBitmap.Width, FCellBitmap.Height - 1)]);
      end
      else
      begin
        { Row line }
        if FBitmapBkColor <> Color then
          UpdatePattern;
        Windows.FillRect(Handle, Rect(0, FCellBitmap.Height - 1, FCellBitmap.Width, FCellBitmap.Height), FBrush);
      end;
    end;
    Canvas.Draw(ARect.Left, ARect.Top, FCellBitmap);
  end
  else begin
    with Canvas do
    begin
      Pen.Color := clBtnHighlight;
      Polyline([Point(ARect.Left, ARect.Bottom - 2), Point(ARect.Right, ARect.Bottom - 2)]);
      Pen.Color := cl3DLight;
      Polyline([Point(ARect.Left, ARect.Bottom - 1), Point(ARect.Right, ARect.Bottom - 1)]);
    end;
  end;
end;


function TUdPropsPage.SelectCell(ACol, ARow: Integer): Boolean;
begin
  UpdateData(FOldRow);
  Result := inherited SelectCell(ACol, ARow);
  InvalidateRow(FOldRow - 1);
  InvalidateRow(FOldRow);
  InvalidateRow(FOldRow + 1);
  InvalidateRow(ARow - 1);
  InvalidateRow(ARow);
  InvalidateRow(ARow + 1);
  FOldRow := ARow;
end;


procedure TUdPropsPage.Paint;
begin
  inherited;
  DrawCell(Col, Row, CellRect(Col, Row), []);
end;


function TUdPropsPage.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := True;
  if TopRow < RowCount - VisibleRowCount then
    TopRow := TopRow + 1;
end;


function TUdPropsPage.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := True;
  if TopRow > FixedRows then
    TopRow := TopRow - 1;
end;


procedure TUdPropsPage.CreateHandle;
begin
  inherited;
  UpdateScrollBar;
  ShowEditor;
  UpdateColWidths;
end;


function TUdPropsPage.GetEditStyle(ACol, ARow: Integer): TEditStyle;
var
  LItem: TUdPropsPageItem;
begin
  LItem := ItemByRow(ARow);
  if LItem <> nil then
    Result := LItem.EditStyle
  else
    Result := esSimple;
end;


procedure TUdPropsPage.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LGridCoord: TGridCoord;
begin
  if not (ppsMovingSplitter in FState) then
  begin
    inherited;
    if MouseCapture then
    begin
      LGridCoord := MouseCoord(X, Y);
      if (LGridCoord.X <> -1) and (LGridCoord.Y <> -1) and
        (LGridCoord.Y < TopRow + VisibleRowCount) then
        Row := LGridCoord.Y;
    end;
  end;
  if ppsMovingSplitter in FState then
    Splitter := X - FSplitterOffset;
end;


function TUdPropsPage.IsOnSplitter(AX: Integer): Boolean;
begin
  Result := (AX >= ColWidths[0] - 4) and (AX <= ColWidths[0]);
end;


procedure TUdPropsPage.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LGridCoord: TGridCoord;
  LCellRect: TRect;
  LItem: TUdPropsPageItem;
begin
  if ssLeft in Shift then
  begin
    if IsOnSplitter(X) then
    begin
      Include(FState, ppsMovingSplitter);
      FSplitterOffset := X - ColWidths[0];
    end
    else
    begin
      inherited;
      LGridCoord := MouseCoord(X, Y);
      if (LGridCoord.X = 0) and (LGridCoord.Y <> -1) then
      begin
        LCellRect := CellRect(LGridCoord.X, LGridCoord.Y);
        LItem := ItemByRow(LGridCoord.Y);
        if (LItem <> nil) and LItem.CanExpand and LItem.IsOnExpandButton(X) then
        begin
          Row := LGridCoord.Y;
          if LItem.Expanded then
            LItem.Collapse
          else
            LItem.Expand;
        end
        else if (LGridCoord.Y < TopRow + VisibleRowCount) then
          Row := LGridCoord.Y;
      end;
    end;
  end;
end;


procedure TUdPropsPage.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LForm: TCustomForm;
begin
  if ppsMovingSplitter in FState then
    if csDesigning in ComponentState then
    begin
      LForm := GetParentForm(Self);
      if (LForm <> nil) and (LForm.Designer <> nil) then LForm.Designer.Modified;
    end
    else
      inherited;
  Exclude(FState, ppsMovingSplitter);
end;


procedure TUdPropsPage.UpdateColWidths;
begin
  ColWidths[1] := Width - ColWidths[0];
end;


procedure TUdPropsPage.UpdateScrollBar;
var
  LSI: TScrollInfo;
begin
  if HandleAllocated then
  begin
    LSI.cbSize := SizeOf(LSI);
    LSI.fMask := SIF_ALL;
    GetScrollInfo(Self.Handle, SB_VERT, LSI);
    LSI.nPage := VisibleRowCount;
    LSI.nMin := 0;
    LSI.nMax := RowCount - 1;
    LSI.nPos := TopRow;
    SetScrollInfo(Self.Handle, SB_VERT, LSI, True);
  end;
end;


procedure TUdPropsPage.WMVScroll(var Message: TWMVScroll);
var
  LTopRow: Integer;
  LSI: TScrollInfo;
begin
  LTopRow := TopRow;
  with Message do
    case ScrollCode of
      SB_LINEUP: LTopRow := LTopRow - 1;
      SB_LINEDOWN: LTopRow := LTopRow + 1;
      SB_PAGEUP: LTopRow := LTopRow - VisibleRowCount;
      SB_PAGEDOWN: LTopRow := LTopRow + VisibleRowCount;
      SB_THUMBPOSITION, SB_THUMBTRACK:
        begin
          LSI.cbSize := SizeOf(LSI);
          LSI.fMask := SIF_ALL;
          GetScrollInfo(Self.Handle, SB_VERT, LSI);
          LTopRow := LSI.nTrackPos;
        end;
      SB_BOTTOM: LTopRow := RowCount - 1;
      SB_TOP: LTopRow := 0;
    end;
  if LTopRow < 0 then LTopRow := 0;
  if LTopRow > RowCount - VisibleRowCount then LTopRow := RowCount - VisibleRowCount;
  TopRow := LTopRow;
  UpdateScrollBar;
  Message.Result := 0;
end;


procedure TUdPropsPage.TopLeftChanged;
begin
  inherited;
  UpdateScrollBar;
end;


procedure TUdPropsPage.SizeChanged(OldColCount, OldRowCount: Integer);
begin
  inherited;
  AdjustTopRow;
  UpdateScrollBar;
  ShowEditor;
end;


procedure TUdPropsPage.WMSize(var Message: TWMSize);
begin
  inherited;
  AdjustTopRow;
  UpdateScrollBar;
  Splitter := Splitter; // Include UpdateColWidths;
  ShowEditor;
end;


procedure TUdPropsPage.AdjustTopRow;
var
  I: Integer;
begin
  if HandleAllocated then
  begin
    I := ClientHeight div DefaultRowHeight;
    if RowCount - TopRow < I then
    begin
      I := RowCount - I;
      if I < 0 then I := 0;
      TopRow := I;
    end;
  end;
end;

procedure TUdPropsPage.ItemsChange;

  procedure _FillRows(AList: TUdPropsObjectList);
  var
    I: Integer;
  begin
    for I := 0 to AList.Count - 1 do
    begin
      System.SetLength(FRows, System.Length(FRows) + 1);
      FRows[High(FRows)] := TUdPropsPageItem(AList[I]);
      TUdPropsPageItem(AList[I]).FRow := High(FRows);
      if TUdPropsPageItem(AList[I]).Expanded then _FillRows(TUdPropsObjectList(AList[I]));
    end;
  end;

var
  I: Integer;
  LActiveItem: TUdPropsPageItem;
begin
  if (FUpdateCount <= 0) and not (ppsDestroying in FState) then
  begin
    for I := 0 to High(FRows) do
      if FRows[I] <> nil then FRows[I].FRow := -1;
    System.SetLength(FRows, 0);
    _FillRows(Items);

    CheckActiveItem;
    RowCount := System.Length(FRows);

    Invalidate;

    LActiveItem := ActiveItem;
    if InplaceEditor <> nil then
    begin
      if LActiveItem <> nil then
      begin
        if (TUdPropsPageInplaceEdit(InplaceEditor).ReadOnlyStyle <> LActiveItem.ReadOnly) or
           (TUdPropsPageInplaceEdit(InplaceEditor).EditStyle <> LActiveItem.EditStyle) then
          InvalidateEditor;
        InplaceEditor.Text := LActiveItem.DisplayValue;
      end
      else begin
        if not TUdPropsPageInplaceEdit(InplaceEditor).ReadOnlyStyle or
          (TUdPropsPageInplaceEdit(InplaceEditor).EditStyle <> esSimple) then
          InvalidateEditor;
        InplaceEditor.Text := '';
      end;
      FEditText := InplaceEditor.Text;
    end;
    Update;
  end
  else
    Include(FState, ppsChanged);
end;


function TUdPropsPage.GetActiveItem: TUdPropsPageItem;
var
  LItem: TUdPropsPageItem;
begin
  LItem := ItemByRow(Row);
  if LItem <> nil then
    Result := LItem
  else
    Result := nil;
end;


procedure TUdPropsPage.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  LItem: TUdPropsPageItem;
  LCellRect: TRect;
  LGridCoord: TGridCoord;
begin
  inherited;
  LGridCoord := MouseCoord(Message.XPos, Message.YPos);
  if (LGridCoord.X = 0) and (LGridCoord.Y <> -1) then
  begin
    LCellRect := CellRect(LGridCoord.X, LGridCoord.Y);
    LItem := ItemByRow(LGridCoord.Y);
    if (LItem <> nil) and not LItem.IsOnExpandButton(Message.XPos) then
      if LItem.Expanded then
        LItem.Collapse
      else
        LItem.Expand;
  end;
end;


function TUdPropsPage.CreateItem(AParent: TUdPropsPageItem): TUdPropsPageItem;
begin
  Result := TUdPropsPageItem.Create(Self, AParent);
end;


function TUdPropsPage.CanEditModify: Boolean;
begin
  Result := (ActiveItem <> nil) and not ActiveItem.ReadOnly;
end;


function TUdPropsPage.GetEditText(ACol, ARow: Integer): string;
var
  LItem: TUdPropsPageItem;
begin
  LItem := ItemByRow(ARow);
  if (ACol = 1) and (LItem <> nil) then
    Result := LItem.DisplayValue;
  FEditText := Result;
end;


procedure TUdPropsPage.SetEditText(ACol, ARow: Integer; const Value: string);
var
  LItem: TUdPropsPageItem;
begin
  if not (ppsUpdatingEditorContent in FState) then
  begin
    LItem := ItemByRow(ARow);
    if (ACol = 1) and (LItem <> nil) and LItem.AutoUpdate then
      LItem.DisplayValue := Value;
    FEditText := Value;
  end;
end;


function TUdPropsPage.ItemByRow(ARow: Integer): TUdPropsPageItem;
begin
  if (ARow >= 0) and (ARow <= High(FRows)) then
    Result := FRows[ARow]
  else
    Result := nil;
end;


procedure TUdPropsPage.UpdateData(ARow: Integer);
var
  LItem: TUdPropsPageItem;
begin
  LItem := ItemByRow(ARow);
  if LItem <> nil then
  try
    LItem.DisplayValue := FEditText;
    FEditText := LItem.DisplayValue;
  finally
    if (InplaceEditor <> nil) then
      TUdPropsPageInplaceEdit(InplaceEditor).UpdateContents;
  end;
end;


procedure TUdPropsPage.CMExit(var Message: TMessage);
begin
  UpdateData(Row);
  inherited;
end;


procedure TUdPropsPage.BeginUpdate;
begin
  Inc(FUpdateCount);
end;


procedure TUdPropsPage.EndUpdate;
begin
  Dec(FUpdateCount);
  if (FUpdateCount <= 0) and (ppsChanged in FState) then
  begin
    ItemsChange;
    Exclude(FState, ppsChanged);
  end;
end;


procedure TUdPropsPage.ItemCollapsed(AItem: TUdPropsPageItem);
begin
  // ... ...
end;


procedure TUdPropsPage.ItemExpanded(AItem: TUdPropsPageItem);
begin
  // ... ...
end;


procedure TUdPropsPage.WMSetCursor(var Message: TWMSetCursor);
var
  LP: TPoint;
begin
  GetCursorPos(LP);
  LP := ScreenToClient(LP);
  if IsOnSplitter(LP.X) then
    Windows.SetCursor(Screen.Cursors[crHSplit])
  else
    inherited;
end;


procedure TUdPropsPage.CMDesignHitTest(var Msg: TCMDesignHitTest);
begin
  Msg.Result := Ord(IsOnSplitter(Msg.XPos) or (ppsMovingSplitter in FState));
end;


procedure TUdPropsPage.SetSplitter(const Value: Integer);
var
  LNewVal: Integer;
begin
  if Width > 0 then
  begin
    LNewVal := Value;
    if LNewVal > Width - 40 then LNewVal := Width - 40;
    if LNewVal < 40 then LNewVal := 40;
    ColWidths[0] := LNewVal;
    UpdateColWidths;
  end;
end;


function TUdPropsPage.GetSplitter: Integer;
begin
  Result := ColWidths[0];
end;


procedure TUdPropsPage.SetValuesColor(const Value: TColor);
begin
  if FValuesColor <> Value then
  begin
    FValuesColor := Value;
    Invalidate;
  end;
end;

procedure TUdPropsPage.SetValuesBackColor(const Value: TColor);
begin
  if FValuesBackColor <> Value then
  begin
    FValuesBackColor := Value;
    Invalidate;
  end;
end;


function TUdPropsPage.GetItemCaptionColor(AItem: TUdPropsPageItem): TColor;
begin
  Result := Font.Color;
end;


procedure TUdPropsPage.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Canvas.Font := Font;
  DefaultRowHeight := Canvas.TextHeight('Ud') + 3;
end;


procedure TUdPropsPage.UpdatePattern;
var
  I: Integer;
begin
  FBitmapBkColor := Color;
  with FBitmap do
  begin
    Width := 8;
    Height := 1;
    Canvas.Brush.Color := FBitmapBkColor;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(Rect(0, 0, FBitmap.Width, FBitmap.Height));
    I := 0;
    while I < Width do
    begin
      Canvas.Pixels[I, 0] := clBtnShadow;
      Inc(I, 2);
    end;
  end;
  if FBrush <> 0 then DeleteObject(FBrush);
  FBrush := CreatePatternBrush(FBitmap.Handle);
end;



procedure TUdPropsPage.DoGetCaption(const AItem: TUdPropsPageItem; var APropName: string);
begin

end;


procedure TUdPropsPage.DoGetValue(const AItem: TUdPropsPageItem; var APropValue: string);
begin

end;


procedure TUdPropsPage.DoBeforeSetValue(const AItem: TUdPropsPageItem; var APropValue: string; var AHandled: Boolean);
begin

end;

procedure TUdPropsPage.DoAfterSetValue(const AItem: TUdPropsPageItem; var APropValue: string); 
begin

end;


function TUdPropsPage.DoGetPickList(const AItem: TUdPropsPageItem; aList: TStrings): Boolean;
begin
  Result := False;
end;

procedure TUdPropsPage.DrawPropValue(AItem: TUdPropsPageItem; ACanvas: TCanvas; R: TRect; Str: string);
begin
  ACanvas.TextRect(R, 1 + R.Left, 1 + R.Top, Str);
end;

procedure TUdPropsPage.DrawPropCaption(AItem: TUdPropsPageItem; ACanvas: TCanvas; R: TRect; Str: string);
begin
  ACanvas.TextRect(R, 1 + (12 + AItem.Ident) + R.Left, 1 + R.Top, Str);
end;

procedure TUdPropsPage.CheckActiveItem;
begin
end;





//==================================================================================================
{ TUdPropertyInspectorItem }


procedure TUdPropertyInspectorItem.DeGetPickList(AResult: TStrings);
var
  LList: TStringList;
begin
  if FEditor <> nil then
  begin
    LList := TStringList.Create;
    try
      if not FOwner.DoGetPickList(Self, LList) then
        FEditor.GetValues(LList);
      if praSortList in FEditor.GetAttrs then LList.Sort;
      AResult.Assign(LList);
    finally
      LList.Free;
    end;
  end;
end;


destructor TUdPropertyInspectorItem.Destroy;
begin
  if FEditor <> nil then FEditor.Free;
  inherited;
end;


procedure TUdPropertyInspectorItem.EditButtonClick;
begin
  if (FEditor <> nil) and not Self.ReadOnly {TUdPropertyInspector(Owner).ReadOnly} then FEditor.Edit;
end;


procedure TUdPropertyInspectorItem.EditDblClick;
var
  LAttrs: TUdPropAttrs;
  LValues: TStringList;
  LIndex: Integer;
begin
  if (FEditor <> nil) and not Self.ReadOnly {not TUdPropertyInspector(Owner).ReadOnly} then
  begin
    LAttrs := FEditor.GetAttrs;
    if (praValueList in LAttrs) and not (praDialog in LAttrs) then
    begin
      LValues := TStringList.Create;
      try
        DeGetPickList(LValues);
        if LValues.Count > 0 then
        begin
          LIndex := LValues.IndexOf(DisplayValue) + 1;
          if LIndex > LValues.Count - 1 then LIndex := 0;
          DisplayValue := LValues[LIndex];
        end;
      finally
        LValues.Free;
      end;
    end
    else if praDialog in LAttrs then
      EditButtonClick;
  end;
end;


procedure TUdPropertyInspectorItem.EditorGetComponent(Sender: TObject; const AComponentName: string; var AComponent: TComponent);
begin
  TUdPropertyInspector(Owner).GetComponent(AComponentName, AComponent);
end;


procedure TUdPropertyInspectorItem.EditorGetComponentName(Sender: TObject; AComponent: TComponent; var AName: string);
begin
  TUdPropertyInspector(Owner).GetComponentName(AComponent, AName);
end;


procedure TUdPropertyInspectorItem.EditorGetComponentNames(Sender: TObject; AClass: TComponentClass; AResult: TStrings);
begin
  TUdPropertyInspector(Owner).GetComponentNames(AClass, AResult);
end;


procedure TUdPropertyInspectorItem.EditorModified(Sender: TObject);
begin
  TUdPropertyInspector(Owner).InternalModified(FEditor.GetPropInfo(0));
end;


function TUdPropertyInspectorItem.GetDisplayValue: string;
begin
  FOwner.DoGetValue(Self, FDisplayValue);
  Result := FDisplayValue;
end;


procedure TUdPropertyInspectorItem.GetEditPickList(APickList: TStrings);
begin
  DeGetPickList(APickList);
end;


procedure TUdPropertyInspectorItem.PickListDrawValue(const AValue: string;
  ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
begin
  if FEditor <> nil then FEditor.ValuesDrawValue(AValue, ACanvas, ARect, ASelected);
end;


procedure TUdPropertyInspectorItem.PickListMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer);
begin
  if FEditor <> nil then FEditor.ValuesMeasureHeight(AValue, ACanvas, AHeight);
end;


procedure TUdPropertyInspectorItem.PickListMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer);
begin
  if FEditor <> nil then FEditor.ValuesMeasureWidth(AValue, ACanvas, AWidth);
end;


procedure TUdPropertyInspectorItem.SetDisplayValue(const Value: string);
var
  LOldValue: string;
  LNewValue: string;
  LHandled: Boolean;
begin
  if Value <> FDisplayValue then
  begin
    LOldValue := FDisplayValue;
    TUdPropertyInspector(Owner).FObjectsLocked := True;
    try
      LNewValue := Value;
      LHandled := False;
      FOwner.DoBeforeSetValue(Self, LNewValue, LHandled);
      if not LHandled then
        FEditor.Value := LNewValue; // May raise an exception
      FOwner.DoAfterSetValue(Self, LNewValue);
    finally
      TUdPropertyInspector(Owner).FObjectsLocked := False;
    end;
    FDisplayValue := FEditor.Value; // FEditor.Value may be not equal with Value
    if LOldValue <> FDisplayValue then
    begin
      Owner.BeginUpdate;
      try
        Change;
        if Expanded and (praVolatileSubProperties in FEditor.GetAttrs) then
        begin
          Collapse;
          Expand;
        end;
      finally
        Owner.EndUpdate;
      end;
    end;
  end;
end;


procedure TUdPropertyInspectorItem.SetEditor(const Value: TUdPropEditor);
begin
  FEditor := Value;
  FEditor.OnModified := EditorModified;
  FEditor.OnGetComponent := EditorGetComponent;
  FEditor.OnGetComponentNames := EditorGetComponentNames;
  FEditor.OnGetComponentName := EditorGetComponentName;

  UpdateParams;
end;


procedure TUdPropertyInspectorItem.UpdateParams;
const
  LExpandables: array[Boolean] of TUdPropsPageItemExpandable = (mieNo, mieYes);

var
  LPropAttrs: TUdPropAttrs;
  LStr: string;
begin
  if FEditor <> nil then
  begin
    Owner.BeginUpdate;
    try
      LPropAttrs := FEditor.GetAttrs;

      Caption := FEditor.PropName;
      Expandable := LExpandables[(praSubProperties in LPropAttrs) and not ((praComponentRef in LPropAttrs) and not TUdPropertyInspector(Owner).ExpandComponentRefs)];
      ReadOnly := FEditor.IsAnyReadonly or (praReadOnly in LPropAttrs) or TUdPropertyInspector(Owner).ReadOnly;
      AutoUpdate := praAutoUpdate in LPropAttrs;
      OwnerDrawPickList := praOwnerDrawValues in LPropAttrs;

      if (praValueList in LPropAttrs) and not Self.ReadOnly {TUdPropertyInspector(Owner).ReadOnly} then
        EditStyle := esPickList
      else if (praDialog in LPropAttrs) and not Self.ReadOnly {TUdPropertyInspector(Owner).ReadOnly} then
        EditStyle := esEllipsis
      else
        EditStyle := esSimple;

      if (praDropDownList in LPropAttrs) and not Self.ReadOnly {TUdPropertyInspector(Owner).ReadOnly} then
        DropDownList := True
      else
        DropDownList := False;

      LStr := FEditor.Value;
      if FDisplayValue <> LStr then
      begin
        FDisplayValue := LStr;
        Change;
      end;
    finally
      Owner.EndUpdate;
    end;
  end;
end;




//==================================================================================================
{ TUdPropertyInspector }

constructor TUdPropertyInspector.Create(AOwner: TComponent);
begin
  inherited;
  FObjects := TList.Create;
  FPropKinds := [pkProperties, pkReadOnly];
  FComponentRefColor := clMaroon;
  FComponentRefChildColor := clGreen;
  FExpandComponentRefs := True;
  FRecentProps := TStringList.Create;
  FRecentCount := 20;
  FSortList := False;
end;

destructor TUdPropertyInspector.Destroy;
begin
  FObjects.Free;
  FRecentProps.Free;
  inherited;
end;


function TUdPropertyInspector.CreateItem(AParent: TUdPropsPageItem): TUdPropsPageItem;
begin
  Result := TUdPropertyInspectorItem.Create(Self, AParent);
end;

function TUdPropertyInspector.GetObjectCount: Integer;
begin
  Result := FObjects.Count;
end;

function TUdPropertyInspector.GetObjects(AIndex: Integer): TPersistent;
begin
  Result := FObjects[AIndex];
end;


function TUdPropertyInspector.IndexOf(AObject: TPersistent): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FObjects.Count - 1 do
    if FObjects[I] = AObject then
    begin
      Result := I;
      Break;
    end;
end;


procedure TUdPropertyInspector.Change;
var
  LEditors: TList;
  I: Integer;
begin
  BeginUpdate;
  try
    if Assigned(FOldObjClass) and (FOldProp <> '') then
    begin
      AddRecentProp(FOldObjClass, FOldProp);
      FOldObjClass := nil;
    end;
    Items.Clear;
    if FObjects.Count > 0 then
    begin
      LEditors := TList.Create;
      try
        UdGetObjectsProps(FDesigner, FObjects, tkAny, False, GetEditorClass, LEditors, FSortList);
        Items.Count := LEditors.Count;
        for I := 0 to LEditors.Count - 1 do
          TUdPropertyInspectorItem(Items[I]).Editor := LEditors[I];
      finally
        LEditors.Free;
      end;
      FOldObjClass := TPersistentClass(Objects[0].ClassType);
    end;
    FObjectChange := True;
  finally
    EndUpdate;
  end;
  DoObjectChange;
end;




function TUdPropertyInspector.Add(AObject: TPersistent): Boolean;
begin
  Result := False;
  if not Assigned(AObject) then Exit;

  CheckObjectsLock;
  FObjects.Add(AObject);

  Change;
  Result := True;
end;

function TUdPropertyInspector.AddObjects(AObjects: TList): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not Assigned(AObjects) then Exit;

  CheckObjectsLock;
  FObjects.Clear;
  for I := 0 to AObjects.Count - 1 do FObjects.Add(AObjects[I]);
  Change;

  Result := True;
end;


function TUdPropertyInspector.Delete(AIndex: Integer): Boolean;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= FObjects.Count) then Exit;

  CheckObjectsLock;
  FObjects.Delete(AIndex);
  if FUpdateCount <= 0 then Change;

  Result := True;
end;

function TUdPropertyInspector.Remove(AObject: TPersistent): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not Assigned(AObject) then Exit;

  I := IndexOf(AObject);
  if I <> -1 then
   Result := Self.Delete(I);
end;

function TUdPropertyInspector.Clear;
begin
  CheckObjectsLock;
  FObjects.Clear;
  Change;

  Result := True;
end;

procedure TUdPropertyInspector.SetObjects(AIndex: Integer; const Value: TPersistent);
begin
  FObjects[AIndex] := Value;
  Change;
end;

function TUdPropertyInspector.Modified(): Boolean;
begin
  Result := False;
  if not FObjectsLocked then
  begin
    Self.UpdateItems();
    Result := True;
  end;
end;

function TUdPropertyInspector.GetEditorClass(AInstance: TPersistent; APropInfo: PPropInfo): TUdPropEditorClass;
var
  LTypeInfo: PTypeInfo;
  LFilterReturn: Boolean;
begin
  Result := nil;

  if Assigned(FOnGetEditorClass) then
  begin
    FOnGetEditorClass(Self, AInstance, APropInfo, Result);
    if Result <> nil then Exit;
  end;

  LTypeInfo := APropInfo.PropType^;

  if not (((pkProperties in PropKinds) and (LTypeInfo.Kind in tkProperties)) or ((pkEvents in PropKinds) and (LTypeInfo.Kind in tkMethods))) or
     not Assigned(APropInfo.GetProc) or
    (not (pkReadOnly in FPropKinds) and not Assigned(APropInfo.SetProc) and (APropInfo.PropType^.Kind <> tkClass)) then
  begin
    Result := nil;
    Exit; //========>>>>>
  end;

  LFilterReturn := True;
  FilterProp(AInstance, APropInfo, LFilterReturn);
  if not LFilterReturn then
  begin
    Result := nil;
    Exit; //========>>>>>
  end;

//  Result := GetPropertyEditManager().GetEditClass(LTypeInfo, LClass, APropInfo);

  if Result = nil then
  begin
    if LTypeInfo = TypeInfo(TComponentName) then
      Result := TUdComponentNamePropEditor
    else if LTypeInfo = TypeInfo(TDate) then
      Result := TUdDatePropEditor
    else if LTypeInfo = TypeInfo(TTime) then
      Result := TUdTimePropEditor
    else if LTypeInfo = TypeInfo(TDateTime) then
      Result := TUdDateTimePropEditor
    else if LTypeInfo = TypeInfo(TCaption) then
      Result := TUdCaptionPropEditor
    else if LTypeInfo = TypeInfo(TColor) then
      Result := TUdColorPropEditor
    else if LTypeInfo = TypeInfo(TCursor) then
      Result := TUdCursorPropEditor
    else if LTypeInfo = TypeInfo(TFontCharset) then
      Result := TUdFontCharsetPropEditor
    else if LTypeInfo = TypeInfo(TFontName) then
      Result := TUdFontNamePropEditor
    else if LTypeInfo = TypeInfo(TImeName) then
      Result := TUdImeNamePropEditor
    else if (LTypeInfo = TypeInfo(TFont)) or
      ((LTypeInfo.Kind = tkClass) and
      GetTypeData(LTypeInfo).ClassType.InheritsFrom(TFont)) then
      Result := TUdFontPropEditor
    else if LTypeInfo = TypeInfo(TModalResult) then
      Result := TUdModalResultPropEditor
    else if LTypeInfo = TypeInfo(TPenStyle) then
      Result := TUdPenStylePropEditor
    else if LTypeInfo = TypeInfo(TBrushStyle) then
      Result := TUdBrushStylePropEditor
    else if LTypeInfo = TypeInfo(TTabOrder) then
      Result := TUdTabOrderPropEditor
    else if LTypeInfo = TypeInfo(TShortCut) then
      Result := TUdShortCutPropEditor
    else if (LTypeInfo = TypeInfo(TStrings)) or
            ((LTypeInfo.Kind = tkClass) and GetTypeData(LTypeInfo).ClassType.InheritsFrom(TStrings)) then
      Result := TUdStringsPropEditor;
  end;

  if Result = nil then
  begin
    case LTypeInfo.Kind of
      tkInteger     : Result := TUdIntegerPropEditor;
      tkChar        : Result := TUdCharPropEditor;
      tkEnumeration : Result := TUdEnumPropEditor;
      tkFloat       : Result := TUdFloatPropEditor;
      tkString,
       tkLString    : Result := TUdStringPropEditor;
      tkWString{$IF COMPILERVERSION >= 20.0 },tkUString{$IFEND}
                    : Result := TUdStringPropEditor;
      tkSet         : Result := TUdSetPropEditor;
      tkClass       :
        if (LTypeInfo = TypeInfo(TComponent)) or GetTypeData(LTypeInfo).ClassType.InheritsFrom(TComponent) then
          Result    := TUdComponentPropEditor
        else
          Result    := TUdClassPropEditor;
      tkVariant     : Result := TUdVariantPropEditor;
      tkInt64       : Result := TUdInt64PropEditor;
    else
      Result := TUdPropEditor;
    end;
  end;


end;


procedure TUdPropertyInspector.ItemCollapsed(AItem: TUdPropsPageItem);
begin
  BeginUpdate;
  try
    AItem.Clear;
  finally
    EndUpdate;
  end;
end;


procedure TUdPropertyInspector.ItemExpanded(AItem: TUdPropsPageItem);
var
  I: Integer;
  LEditor: TUdPropEditor;
  LSubProps: TList;
begin
  LEditor := TUdPropertyInspectorItem(AItem).Editor;
  if LEditor <> nil then
  begin
    LSubProps := TList.Create;
    try
      if not ((praComponentRef in LEditor.GetAttrs) and not ExpandComponentRefs) then
      begin
        LEditor.GetSubProps(GetEditorClass, LSubProps, SortList);
        BeginUpdate;
        try
          for I := 0 to LSubProps.Count - 1 do
            TUdPropertyInspectorItem(AItem[AItem.Add]).Editor := LSubProps[I];
        finally
          EndUpdate;
        end;
      end;
    finally
      LSubProps.Free;
    end;
  end;
end;

procedure TUdPropertyInspector.GetComponent(const AComponentName: string; var AComponent: TComponent);
begin
  if Assigned(FOnGetComponent) then FOnGetComponent(Self, AComponentName, AComponent);
end;

procedure TUdPropertyInspector.GetComponentNames(AClass: TComponentClass; AResult: TStrings);
begin
  if Assigned(FOnGetComponentNames) then FOnGetComponentNames(Self, AClass, AResult);
end;

procedure TUdPropertyInspector.GetComponentName(AComponent: TComponent; var AName: string);
begin
  if Assigned(FOnGetComponentName) then FOnGetComponentName(Self, AComponent, AName);
end;


procedure TUdPropertyInspector.SetPropKinds(const Value: TUdPropertyInspectorPropKinds);
begin
  if FPropKinds <> Value then
  begin
    FPropKinds := Value;
    Change;
  end;
end;


procedure TUdPropertyInspector.FilterProp(AInstance: TPersistent; APropInfo: PPropInfo; var AIncludeProp: Boolean);
begin
  if Assigned(FOnFilterProp) then
    FOnFilterProp(Self, AInstance, APropInfo, AIncludeProp);
end;


function TUdPropertyInspector.GetItemCaptionColor(AItem: TUdPropsPageItem): TColor;
begin
  if (TUdPropertyInspectorItem(AItem).FEditor <> nil) and (praComponentRef in TUdPropertyInspectorItem(AItem).FEditor.GetAttrs) then
    Result := ComponentRefColor
  else if (AItem.Parent <> nil) and (TUdPropertyInspectorItem(AItem.Parent).FEditor <> nil) and (praComponentRef in TUdPropertyInspectorItem(AItem.Parent).FEditor.GetAttrs) then
    Result := ComponentRefChildColor
  else
    Result := inherited GetItemCaptionColor(AItem);

  if (TUdPropertyInspectorItem(AItem).FEditor <> nil) then
    GetCaptionColor(TUdPropertyInspectorItem(AItem).FEditor.PropTypeInfo, TUdPropertyInspectorItem(AItem).FEditor.PropName, Result);
end;


procedure TUdPropertyInspector.SetComponentRefColor(
  const Value: TColor);
begin
  if FComponentRefColor <> Value then
  begin
    FComponentRefColor := Value;
    Invalidate;
  end;
end;


procedure TUdPropertyInspector.SetComponentRefChildColor(
  const Value: TColor);
begin
  if FComponentRefChildColor <> Value then
  begin
    FComponentRefChildColor := Value;
    Invalidate;
  end;
end;


procedure TUdPropertyInspector.SetExpandComponentRefs(
  const Value: Boolean);
begin
  if FExpandComponentRefs <> Value then
  begin
    FExpandComponentRefs := Value;
    Change;
  end;
end;


procedure TUdPropertyInspector.SetReadOnly(const Value: Boolean);
begin
  if FReadOnly <> Value then
  begin
    FReadOnly := Value;
    Change;
  end;
end;


procedure TUdPropertyInspector.SetDesigner(const Value: Pointer);
begin
  if FDesigner <> Value then
  begin
    FDesigner := Value;
    Change;
  end;
end;


procedure TUdPropertyInspector.GetCaptionColor(APropTypeInfo: PTypeInfo; const APropName: string; var AColor: TColor);
begin
  if Assigned(FOnGetCaptionColor) then FOnGetCaptionColor(Self, APropTypeInfo, APropName, AColor);
end;


procedure TUdPropertyInspector.InternalModified(APropInfo: PPropInfo);
begin
  UpdateItems;
  if Assigned(FOnModified) then FOnModified(Self, APropInfo);
end;


procedure TUdPropertyInspector.UpdateItems;

  procedure _UpdateItems(AList: TUdPropsObjectList);
  var
    I: Integer;
  begin
    for I := 0 to AList.Count - 1 do
    begin
      TUdPropertyInspectorItem(AList[I]).UpdateParams;
      _UpdateItems(TUdPropertyInspectorItem(AList[I]));
    end;
  end;

begin
  BeginUpdate;
  try
    _UpdateItems(Items);
  finally
    EndUpdate;
  end;
end;


procedure TUdPropertyInspector.CheckObjectsLock;
begin
  if FObjectsLocked then
    raise Exception.Create('Property inspector is changing property value. ' + #13#10 +
                           'Can not change objects');
end;



procedure TUdPropertyInspector.DoGetCaption(const AItem: TUdPropsPageItem; var APropName: string);
begin
  inherited;
  if Assigned(FOnGetCaption) then
    FOnGetCaption(Self, TUdPropertyInspectorItem(AItem).FEditor.PropTypeInfo, APropName);
end;


procedure TUdPropertyInspector.DoGetValue(const AItem: TUdPropsPageItem; var APropValue: string);
begin
  inherited;
  if Assigned(FOnGetValue) then
    FOnGetValue(Self, TUdPropertyInspectorItem(AItem).FEditor.PropTypeInfo, APropValue);
end;


procedure TUdPropertyInspector.DoBeforeSetValue(const AItem: TUdPropsPageItem; var APropValue: string; var AHandled: Boolean);
begin
  inherited;
  if Assigned(FOnBeforeSetValue) then
    FOnBeforeSetValue(Self, TUdPropertyInspectorItem(AItem).FEditor.PropName, TUdPropertyInspectorItem(AItem).FEditor.PropTypeInfo, APropValue, AHandled);
end;

procedure TUdPropertyInspector.DoAfterSetValue(const AItem: TUdPropsPageItem; var APropValue: string);
begin
  inherited;
  if Assigned(FOnAfterSetValue) then
    FOnAfterSetValue(Self, TUdPropertyInspectorItem(AItem).FEditor.PropName, TUdPropertyInspectorItem(AItem).FEditor.PropTypeInfo, APropValue);
end;

function TUdPropertyInspector.DoGetPickList(const AItem: TUdPropsPageItem; aList: TStrings): Boolean;
begin
  Result := inherited DoGetPickList(AItem, aList);
  if Assigned(FOnGetPickList) then
    FOnGetPickList(Self, TUdPropertyInspectorItem(AItem).FEditor.PropTypeInfo, aList, Result);
end;


procedure TUdPropertyInspector.DrawPropValue(AItem: TUdPropsPageItem; ACanvas: TCanvas; R: TRect; Str: string);
begin
  if Assigned(TUdPropertyInspectorItem(AItem).Editor) then
    TUdPropertyInspectorItem(AItem).Editor.ValuesDrawValue(Str, ACanvas, R, False)
  else
    inherited;
end;



procedure TUdPropertyInspector.DoObjectChange;
begin
  if Assigned(FOnObjectChange) then
    FOnObjectChange(Self)
end;


procedure TUdPropertyInspector.CheckActiveItem;

  function _GetRecentActiveItem(FullPropName: string): TUdPropsPageItem;
  var
    I, LII, P: Integer;
    LChild: TUdPropsPageItem;
    LFound: Boolean;
    LNameLevel: Integer;
    LOldNamPaths: array of string;
    LTempPath, LTemp: string;
  begin
    LTempPath := FullPropName;
    while LTempPath <> '' do
    begin
      P := Pos('.', LTempPath);
      if P > 0 then
      begin
        LTemp := Copy(LTempPath, 1, P - 1);
        System.Delete(LTempPath, 1, P);
      end
      else
      begin
        LTemp := LTempPath;
        LTempPath := '';
      end;
      System.SetLength(LOldNamPaths, High(LOldNamPaths) + 2);
      LOldNamPaths[High(LOldNamPaths)] := LTemp;
    end;

    LNameLevel := 0;
    LChild := nil;
    if High(LOldNamPaths) >= 0 then
      for I := 0 to Items.Count - 1 do
        if SameText(Items[I].Caption, LOldNamPaths[LNameLevel]) then
        begin
          LChild := Items[I];
          Inc(LNameLevel);
          while LNameLevel < System.Length(LOldNamPaths) do
          begin
            LChild.Expand;
            LFound := False;
            for LII := 0 to LChild.Count - 1 do
              if SameText(LChild[LII].Caption, LOldNamPaths[LNameLevel]) then
              begin
                LChild := LChild[LII];
                Inc(LNameLevel);
                LFound := True;
                Break;
              end;
            if not LFound then
            begin
              LChild := nil;
              Break;
            end;
          end;
          Break;
        end;
    Result := LChild;
  end;

var
  I: Integer;
  RecentIndex: Integer;
  LActiveItem: TUdPropsPageItem;
begin
  if FObjectChange then
  begin
    //if FUpdateCount<=0 then
    FObjectChange := False;
    if ObjectCount < 1 then Exit;

    LActiveItem := nil;
    if FOldProp <> '' then //上次使用的
      LActiveItem := _GetRecentActiveItem(FOldProp)
    else
    begin //相同类最近使用的
      RecentIndex := FRecentProps.IndexOfName(Objects[0].ClassName);
      if RecentIndex <> -1 then
        LActiveItem := _GetRecentActiveItem(FRecentProps.ValueFromIndex[RecentIndex])
    end;
    if not Assigned(LActiveItem) then //任意最近使用的
      for I := FRecentProps.Count - 1 downto 0 do
      begin
        LActiveItem := _GetRecentActiveItem(FRecentProps.ValueFromIndex[I]);
        if Assigned(LActiveItem) then Break;
      end;
    RowCount := System.Length(FRows);
    if Assigned(LActiveItem) and (Row <> LActiveItem.FRow) then
    begin
      FOldRow := -1; //不修改属性
      Row := LActiveItem.FRow;
    end;
  end;
end;


procedure TUdPropertyInspector.AddRecentProp(ObjClass: TPersistentClass; FullPropName: string);
var
  NewIndex: Integer;
begin
  if FullPropName <> '' then
  begin
    if Assigned(ObjClass) then
    begin
      NewIndex := FRecentProps.IndexOfName(ObjClass.ClassName);
      if NewIndex <> -1 then
        FRecentProps.Delete(NewIndex);
      FRecentProps.Add(ObjClass.ClassName + '=' + FullPropName);
    end
    else
      FRecentProps.Add('=' + FullPropName);
  end;
  while FRecentProps.Count > FRecentCount do
    FRecentProps.Delete(0);
end;


function TUdPropertyInspector.SelectCell(ACol, ARow: Integer): Boolean;
var
  LItem: TUdPropsPageItem;
begin
  Result := inherited SelectCell(ACol, ARow);

  if Result then
  begin
    LItem := ItemByRow(ARow);
    if Assigned(LItem) then
      FOldProp := LItem.FullCaption;
  end;
end;


procedure TUdPropertyInspector.SetRecentCount(Value: Integer);
begin
  if Value < 0 then Value := 0;
  if FRecentCount = Value then Exit;

  FRecentCount := Value;
  while FRecentProps.Count > FRecentCount do
    FRecentProps.Delete(0);
end;


procedure TUdPropertyInspector.SetSortList(const Value: Boolean);
begin
  if FSortList <> Value then
  begin
    FSortList := Value;
    Change;
  end;
end;



end.