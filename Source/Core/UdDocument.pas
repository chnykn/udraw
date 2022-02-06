{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDocument;

{$I UdDefs.INC}

//{$DEFINE TRIAL}

interface

uses
  Windows, Classes, Controls, StdCtrls, Graphics,
  UdTypes, UdConsts, UdIntfs, UdEvents, UdObject, UdEntity,
  UdLayout, UdLayer, UdColor, UdLineType, UdLineWeight, UdTextStyle, UdDimStyle, UdAction,
  UdLayouts, UdLayers, UdColors, UdLineTypes, UdLineWeights, UdTextStyles, UdDimStyles, UdActions,
  UdOptions, UdPointStyle,  UdUnits, UdBlocks, UdHatchPatterns, UdHashMaps, UdUndoRedo, UdCCP, UdDrawPanel, UdCmdLine;

type
  //*** TUdDocument ***//
  TUdDocument = class(TUdObject, IUdUndoRedo, IUdCCPSupport)
  private
    FVer: Integer;
    FState: Cardinal;

    FIDSeed : Integer;
    FIDTable: TUdIntHashMap;

    FLayers     : TUdLayers;
    FColors     : TUdColors;
    FLineTypes  : TUdLineTypes;
    FLineWeights: TUdLineWeights;

    FPointStyle : TUdPointStyle;
    FTextStyles : TUdTextStyles;
    FDimStyles  : TUdDimStyles;
    FUnits      : TUdUnits;

    FBlocks: TUdBlocks;
    FHatchPatterns: TUdHatchPatterns;

    FLayouts: TUdLayouts;
    FActions: TUdActions;
    FOptions: TUdOptions;

    FCcp: TUdCCP;
    FUndoRedo: TUdUndoRedo;


    FLastCmd: string;
    FCmdLine: TUdCmdLine;
    FDrawPanel: TUdDrawPanel;

    FIdleCanEdit: Boolean;

    //---------------------------------

    FOnPrompt: TUdPromptEvent;
    FOnUserPaint: TUdPaintEvent;
    FOnMousePoint: TUdMousePointEvent;



    //----------- Colors Events ---------------
    FOnColorAdd: TUdColorEvent;
    FOnColorSelect: TUdColorEvent;
    FOnColorRemove: TUdColorAllowEvent;


    //----------- LineTypes Events ---------------
    FOnLineTypeAdd: TUdLineTypeEvent;
    FOnLineTypeSelect: TUdLineTypeEvent;
    FOnLineTypeRemove: TUdLineTypeAllowEvent;


    //----------- LineWeights Events ---------------
    FOnLineWeightSelect: TUdLineWeightEvent;


    //----------- Layers Events ---------------
    FOnLayerAdd: TUdLayerEvent;
    FOnLayerSelect: TUdLayerEvent;
    FOnLayerRemove: TUdLayerAllowEvent;



    //----------- Layouts Events ---------------
    FOnLayoutAdd: TUdLayoutEvent;
    FOnLayoutSelect: TUdLayoutEvent;
    FOnLayoutRemove: TUdLayoutAllowEvent;

    FOnAddEntities: TUdEntitiesEvent;
    FOnRemoveEntities: TUdEntitiesEvent;
    FOnRemovedEntities: TNotifyEvent;

    FOnAddSelectedEntities: TUdEntitiesEvent;
    FOnRemoveSelectedEntities: TUdEntitiesEvent;
    FOnRemoveAllSelecteEntities: TNotifyEvent;

    FOnAxesChanging: TNotifyEvent;
    FOnAxesChanged : TNotifyEvent;
    FOnActionChanged: TNotifyEvent;


    //--------- Objects Events -------------------
    FOnAfterObjectModify: TUdAfterModifyEvent;
    FOnBeforeObjectModify: TUdBeforeModifyEvent;

    //---------- Other Events -------------------

    FOnProgress: TUdProgressEvent;
    FOnGetEntityClass: TUdGetEntityClassEvent;


  protected
    function GetState(const Index: Integer): Boolean;

    {Init Objects...}
    function InitColors(): Boolean;
    function InitLineTypes(): Boolean;
    function InitLineWeights(): Boolean;

    function UpdateByLayer(): Boolean;
    function InitLayers(): Boolean;

    function InitLayouts(): Boolean;


    {Set Objects...}
    procedure SetCmdLine(const AValue: TUdCmdLine);
    procedure InitDrawPanelTabs();
    procedure SetDrawPanel(const AValue: TUdDrawPanel);

    {Active Objects...}
    function GetModelSpace(): TUdLayout;

    function GetActiveAction(): TUdAction;
    
    function GetActiveLayout(): TUdLayout;
    procedure SetActiveLayout(const AValue: TUdLayout);

    function GetActiveLayer: TUdLayer;
    procedure SetActiveLayer(const AValue: TUdLayer);

    function GetActiveColor: TUdColor;
    procedure SetActiveColor(const AValue: TUdColor);

    function GetActiveLineType: TUdLineType;
    procedure SetActiveLineType(const AValue: TUdLineType);

    function GetActiveLineWeight: TUdLineWeight;
    procedure SetActiveLineWeight(const AValue: TUdLineWeight);


    function GetActiveTextStyle: TUdTextStyle;
    procedure SetActiveTextStyle(const AValue: TUdTextStyle);

    function GetActiveDimStyle: TUdDimStyle;
    procedure SetActiveDimStyle(const AValue: TUdDimStyle);





    {FUndoRedo's Event...}
    procedure OnUndoRedoOnGetObjectByID(Sender: TObject; const AID: Integer; var AObject: TUdObject);


    {FDrawPanel's Event...}
    procedure OnDrawPanelPaint(Sender: TObject; ACanvas: TCanvas);
    procedure OnDrawPanelScroll(Sender: TObject; AKind: Integer; AScrollCode: TScrollCode; AScrollPos: Integer);
    procedure OnDrawPanelDblClick(Sender: TObject; APoint: TPoint);
    procedure OnDrawPanelKeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; var AKey: Word);
    procedure OnDrawPanelMouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState; var APoint: TPoint);
    procedure OnDrawPanelMouseWheel(Sender: TObject; AKeys, AWheelDelta, XPos, YPos: Smallint);
    procedure OnDrawPanelResized(Sender: TObject);
    procedure OnDrawPanelTabChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
    procedure _OnDrawPanelGetCanPopMenu(Sender: TObject;  var Allow: Boolean);

    procedure OnCmdLineUserText(Sender: TObject; AText: string);


    {FColors's Event...}
    procedure OnColorsAdd(Sender: TObject; AColor: TUdColor);
    procedure OnColorsSelect(Sender: TObject; AColor: TUdColor);
    procedure OnColorsRemove(Sender: TObject; AColor: TUdColor; var AAllow: Boolean);
    procedure OnColorsChanged(Sender: TObject; APropName: string);

    {FLineTypes's Event...}
    procedure OnLineTypesAdd(Sender: TObject; ALineType: TUdLineType);
    procedure OnLineTypesSelect(Sender: TObject; ALineType: TUdLineType);
    procedure OnLineTypesRemove(Sender: TObject; ALineType: TUdLineType; var AAllow: Boolean);
    procedure OnLineTypesChanged(Sender: TObject; APropName: string);

    {FLineWeights's Event...}
    procedure OnLineWeightsSelect(Sender: TObject; ALineWeight: TUdLineWeight);
    procedure OnLineWeightsChanged(Sender: TObject; APropName: string);


    {FLayers's Event...}
    procedure OnLayersAdd(Sender: TObject; ALayer: TUdLayer);
    procedure OnLayersSelect(Sender: TObject; ALayer: TUdLayer);
    procedure OnLayersRemove(Sender: TObject; ALayer: TUdLayer; var AAllow: Boolean);
    procedure OnLayersChanged(Sender: TObject; APropName: string);


    {Layouts's Event...}
    procedure OnLayoutsAdd(Sender: TObject; ALayout: TUdLayout);
    procedure OnLayoutsSelect(Sender: TObject; ALayout: TUdLayout);
    procedure OnLayoutsRemove(Sender: TObject; ALayout: TUdLayout; var AAllow: Boolean);
    procedure OnLayoutsChanged(Sender: TObject; APropName: string);

    procedure OnLayoutsAddEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnLayoutsRemoveEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnLayoutsRemovedEntities(Sender: TObject);

    procedure OnLayoutsAddSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnLayoutsRemoveSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnLayoutsRemoveAllSelectedEntities(Sender: TObject);
    procedure OnLayoutsActionChanged(Sender: TObject);

    procedure OnLayoutsAxesChanging(Sender: TObject);
    procedure OnLayoutsAxesChanged(Sender: TObject);

    {PointStyle's Event}
    procedure OnPointStyleChanged(Sender: TObject);


    {Raise Event...}
    procedure AddDocObject(Sender: TUdObject; AObj: TUdObject; ANeedUndo: Boolean = True);
    procedure RemoveDocObject(Sender: TUdObject; AObj: TUdObject; ANeedUndo: Boolean = True);

    function RaiseBeforeModifyObject(Sender: TUdObject; APropName: string; ANeedUndo: Boolean = True): Boolean;
    procedure RaiseAfterModifyObject(Sender: TUdObject; APropName: string; ANeedUndo: Boolean = True);

    function DoGetEntityClass(Sender: TUdObject; AEntityId: Integer): TUdEntityClass;


    //---------------------------------------------

    procedure RestIdTable();
    function AddToIDTable(AObj: TUdObject): Boolean;
    function RemoveFromIDTable(AObj: TUdObject): Boolean;

    function GetViewSize(AIndex: Integer): Float;

    
    //--------------------------------------------------
    {IUdCcpSupport...}
    function CutClip(): Boolean;
    function CopyClip(): Boolean;
    function PasteClip(): TUdObjectArray;


  public
    constructor Create(); override; // ADocument: TUdObject; AIsDocRegister: Boolean = True override;
    destructor Destroy; override;

    function ExecCommond(const AValue: string): Boolean;
    function Prompt(const AValue: string; AKind: TUdPromptKind): Boolean;


    {IUdUndoRedo ...}
    function BeginUndo(AName: string): Boolean;
    function EndUndo(): Boolean;

    function PerformUndo(): Boolean;
    function PerformRedo(): Boolean;


    //---------------------------------------------

    function Clear(): Boolean;
    function GetNextObjectID(): Integer;

    {save&load...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    function SaveToFile(AFileName: string): Boolean;
    function LoadFromFile(AFileName: string): Boolean;

    function SaveToDxfFile(AFileName: string): Boolean;
    function LoadFromDxfFile(AFileName: string): Boolean;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = '');  override;
    procedure LoadFromXml(AXmlNode: TObject); override;

    function SaveToXmlFile(AFileName: string): Boolean;
    function LoadFromXmlFile(AFileName: string): Boolean;



    //---------------------------------------------
    procedure UpdateLayersStatus();
    procedure UpdateLineTypesStatus();
    procedure UpdateTextTypesStatus();
    procedure UpdateDimTypesStatus();


    //---------------------------------------------
    procedure DoProgress(AProgress: Integer; const AProgressMax: Integer; AMsg: string = '');

    property IdleCanEdit: Boolean read FIdleCanEdit write FIdleCanEdit;


  public
    property Creating   : Boolean index 0 read GetState;
    property Destroying : Boolean index 1 read GetState;
    property Loading    : Boolean index 2 read GetState;

    property Options    : TUdOptions     read FOptions;
    property UndoRedo   : TUdUndoRedo    read FUndoRedo;


    property Blocks: TUdBlocks read FBlocks;
    property HatchPatterns: TUdHatchPatterns read FHatchPatterns;

    property LastCmd    : string       read FLastCmd;
    property CmdLine    : TUdCmdLine   read FCmdLine   write SetCmdLine;
    property DrawPanel  : TUdDrawPanel read FDrawPanel write SetDrawPanel;

    property ModelSpace : TUdLayout  read GetModelSpace;
    property ActiveAction: TUdAction read GetActiveAction;

  published
    property ActiveLayer     : TUdLayer      read GetActiveLayer      write SetActiveLayer;
    property ActiveColor     : TUdColor      read GetActiveColor      write SetActiveColor;
    property ActiveLineType  : TUdLineType   read GetActiveLineType   write SetActiveLineType;
    property ActiveLineWeight: TUdLineWeight read GetActiveLineWeight write SetActiveLineWeight;
    property ActiveLayout    : TUdLayout     read GetActiveLayout     write SetActiveLayout;

    property ActiveTextStyle : TUdTextStyle  read GetActiveTextStyle  write SetActiveTextStyle;
    property ActiveDimStyle  : TUdDimStyle   read GetActiveDimStyle   write SetActiveDimStyle;


  
    property Layers     : TUdLayers      read FLayers     ;// write FLayers;
    property Colors     : TUdColors      read FColors     ;// write FColors;
    property LineTypes  : TUdLineTypes   read FLineTypes  ;// write FLineTypes;
    property LineWeights: TUdLineWeights read FLineWeights;// write FLineWeights;
    property Layouts    : TUdLayouts     read FLayouts    ;// write FLayouts;

    property TextStyles : TUdTextStyles  read FTextStyles ;//write FTextStyles;
    property DimStyles  : TUdDimStyles   read FDimStyles  ;//write FDimStyles;


    property PointStyle : TUdPointStyle  read FPointStyle ;//write FPointStyle;
    property Units      : TUdUnits       read FUnits      ;//write FUnits;


    property ViewHeight: Float index 0  read GetViewSize;
    property ViewWidth : Float index 1  read GetViewSize;

  published
    property OnPrompt: TUdPromptEvent read FOnPrompt write FOnPrompt;
    property OnUserPaint: TUdPaintEvent read FOnUserPaint write FOnUserPaint;
    property OnMousePoint: TUdMousePointEvent read FOnMousePoint write FOnMousePoint;

    //----------- Colors Events ---------------
    property OnColorAdd    : TUdColorEvent      read FOnColorAdd    write FOnColorAdd;
    property OnColorSelect : TUdColorEvent      read FOnColorSelect write FOnColorSelect;
    property OnColorRemove : TUdColorAllowEvent read FOnColorRemove write FOnColorRemove;


    //----------- LineTypes Events ---------------
    property OnLineTypeAdd    : TUdLineTypeEvent      read FOnLineTypeAdd    write FOnLineTypeAdd;
    property OnLineTypeSelect : TUdLineTypeEvent      read FOnLineTypeSelect write FOnLineTypeSelect;
    property OnLineTypeRemove : TUdLineTypeAllowEvent read FOnLineTypeRemove write FOnLineTypeRemove;


    //----------- LineWeights Events ---------------
    property OnLineWeightSelect: TUdLineWeightEvent read FOnLineWeightSelect write FOnLineWeightSelect;


    //----------- Layers Events ---------------
    property OnLayerAdd    : TUdLayerEvent      read FOnLayerAdd    write FOnLayerAdd;
    property OnLayerSelect : TUdLayerEvent      read FOnLayerSelect write FOnLayerSelect;
    property OnLayerRemove : TUdLayerAllowEvent read FOnLayerRemove write FOnLayerRemove;


    //----------- Layouts Events ---------------
    property OnLayoutAdd      : TUdLayoutEvent      read FOnLayoutAdd      write FOnLayoutAdd;
    property OnLayoutSelect   : TUdLayoutEvent      read FOnLayoutSelect   write FOnLayoutSelect;
    property OnLayoutRemove   : TUdLayoutAllowEvent read FOnLayoutRemove   write FOnLayoutRemove;

    property OnAddEntities    : TUdEntitiesEvent    read FOnAddEntities     write FOnAddEntities;
    property OnRemoveEntities : TUdEntitiesEvent    read FOnRemoveEntities  write FOnRemoveEntities;
    property OnRemovedEntities: TNotifyEvent        read FOnRemovedEntities write FOnRemovedEntities;

    property OnAddSelectedEntities: TUdEntitiesEvent read FOnAddSelectedEntities write FOnAddSelectedEntities;
    property OnRemoveSelectedEntities: TUdEntitiesEvent read FOnRemoveSelectedEntities write FOnRemoveSelectedEntities;
    property OnRemoveAllSelecteEntities: TNotifyEvent read FOnRemoveAllSelecteEntities write FOnRemoveAllSelecteEntities;

    property OnAxesChanging : TNotifyEvent read FOnAxesChanging   write FOnAxesChanging;
    property OnAxesChanged  : TNotifyEvent read FOnAxesChanged    write FOnAxesChanged;
    property OnActionChanged: TNotifyEvent read FOnActionChanged  write FOnActionChanged;


    //----------- Objects Events ---------------
    property OnAfterObjectModify: TUdAfterModifyEvent read FOnAfterObjectModify write FOnAfterObjectModify;
    property OnBeforeObjectModify: TUdBeforeModifyEvent read FOnBeforeObjectModify write FOnBeforeObjectModify;


    //---------- Other Events -------------------
    property OnProgress: TUdProgressEvent read FOnProgress write FOnProgress;
    property OnGetEntityClass: TUdGetEntityClassEvent read FOnGetEntityClass write FOnGetEntityClass;
  end;


implementation

uses
  SysUtils, UdUtils,

  UdAxes, UdEntities, UdBlock, UdInsert, UdText, UdDimension, UdBaseActions, UdStreams,
  UdXml, UdDxfTypes, UdDxfReader, UdDxfWriter, UdPoint,

  UdLayersFrm, UdColorsFrm, UdLineTypesFrm, UdLineWeightsFrm,
  UdTextStylesFrm, UdDimStylesFrm, UdPointStyleFrm, UdDraftingFrm
  ;


const
  FILE_HEAD = 'VDRAW.FILE';
  RESERVED_ID_COUNT = 512; // reserve

  STATE_CREATING   = 1;
  STATE_DESTROYING = 2;
  STATE_LOADING    = 4;

type
  TFObject    = class(TUdObject);
  TFEntity    = class(TUdEntity);
  TFUndoRedo  = class(TUdUndoRedo);
  TFCmdLine   = class(TUdCmdLine);
  TFDrawPanel = class(TUdDrawPanel);
  TFPointStyle    = class(TUdPointStyle);




//=================================================================================================
{ TUdDocument }

constructor TUdDocument.Create();    //
begin
  inherited;

  FLastCmd := '';
  FCmdLine := nil;
  FDrawPanel := nil;
  FIdleCanEdit := True;

  FVer := 0;
  FState := STATE_CREATING;

  FIDSeed := 0;
  FIDTable := TUdIntHashMap.Create();//False

  FCcp := TUdCCP.Create(Self);
  FUndoRedo := TUdUndoRedo.Create(Self);
  TFUndoRedo(FUndoRedo)._OnGetObjectByID := OnUndoRedoOnGetObjectByID;

  FOptions := TUdOptions.Create(Self);
  FLayers := TUdLayers.Create(Self);
  FColors := TUdColors.Create(Self);
  FLineTypes := TUdLineTypes.Create(Self);
  FLineWeights := TUdLineWeights.Create(Self);

  FColors.ByLayer.Assign(FLayers.Active.Color);
  FLineTypes.ByLayer.Assign(FLayers.Active.LineType);
  FLineWeights.Active := FLayers.Active.LineWeight;


  FPointStyle := TUdPointStyle.Create(Self);
  FTextStyles := TUdTextStyles.Create(Self);
  FDimStyles  := TUdDimStyles.Create(Self);
  FUnits := TUdUnits.Create(Self);

  TFPointStyle(FPointStyle).OnChanged := OnPointStyleChanged;


  FBlocks := TUdBlocks.Create(Self);
  FHatchPatterns := TUdHatchPatterns.Create(Self);

  FLayouts := TUdLayouts.Create(Self);

  FActions := TUdActions.Create(Self);

  Self.InitColors();
  Self.InitLineTypes();
  Self.InitLineWeights();
  Self.InitLayers();
  Self.InitLayouts();

  FState := 0;

  Self.RestIdTable();
  FIDSeed := RESERVED_ID_COUNT;
end;

destructor TUdDocument.Destroy;
begin
  FState := STATE_DESTROYING;

  if Assigned(FLayouts) then FLayouts.Free;
  FLayouts := nil;

  if Assigned(FLayers) then FLayers.Free;
  FLayers := nil;

  if Assigned(FColors) then FColors.Free;
  FColors := nil;

  if Assigned(FLineTypes) then FLineTypes.Free;
  FLineTypes := nil;

  if Assigned(FLineWeights) then FLineWeights.Free;
  FLineWeights := nil;


  if Assigned(FPointStyle) then FPointStyle.Free;
  FPointStyle := nil;

  if Assigned(FTextStyles) then FTextStyles.Free;
  FTextStyles := nil;

  if Assigned(FDimStyles) then FDimStyles.Free;
  FDimStyles := nil;

  if Assigned(FUnits) then FUnits.Free;
  FUnits := nil;



  if Assigned(FBlocks) then FBlocks.Free;
  FBlocks := nil;

  if Assigned(FHatchPatterns) then FHatchPatterns.Free;
  FHatchPatterns := nil;


  if Assigned(FActions) then FActions.Free;
  FActions := nil;

  if Assigned(FOptions) then FOptions.Free;
  FOptions := nil;


  if Assigned(FUndoRedo) then FUndoRedo.Free;
  FUndoRedo := nil;

  if Assigned(FIDTable) then FIDTable.Free;
  FIDTable := nil;

  if Assigned(FCcp) then FCcp.Free;
  FCcp := nil;
  
  FState := 0;
  inherited;
end;



function TUdDocument.GetState(const Index: Integer): Boolean;
begin
  Result := False;
  case Index of
    0: Result := (FState and STATE_CREATING) > 0;
    1: Result := (FState and STATE_DESTROYING) > 0;
    2: Result := (FState and STATE_LOADING) > 0;
  end;
end;



//-------------------------------------------------------------------------------------------
{IUdCCPObjects...}

function TUdDocument.CutClip(): Boolean;
begin
  Result := FCcp.CutClip();
end;

function TUdDocument.CopyClip(): Boolean;
begin
  Result := FCcp.CopyClip();
end;

function TUdDocument.PasteClip(): TUdObjectArray;
begin
  Result := FCcp.PasteClip();
end;





//-------------------------------------------------------------------------------------------

function TUdDocument.InitColors: Boolean;
begin
  Result := False;
  if not Assigned(FColors) then Exit;

  FColors.OnAdd    := OnColorsAdd;
  FColors.OnSelect := OnColorsSelect;
  FColors.OnRemove := OnColorsRemove;
  FColors.OnChanged := OnColorsChanged;

  Result := True;
end;


function TUdDocument.InitLineTypes: Boolean;
begin
  Result := False;
  if not Assigned(FLineTypes) then Exit;

  FLineTypes.OnAdd := OnLineTypesAdd;
  FLineTypes.OnSelect := OnLineTypesSelect;
  FLineTypes.OnRemove := OnLineTypesRemove;
  FLineTypes.OnChanged := OnLineTypesChanged;

  Result := True;
end;

function TUdDocument.InitLineWeights: Boolean;
begin
  Result := False;
  if not Assigned(FLineWeights) then Exit;

  FLineWeights.OnSelect := OnLineWeightsSelect;
  FLineWeights.OnChanged := OnLineWeightsChanged;

  Result := True;
end;



function TUdDocument.UpdateByLayer: Boolean;
begin
  Result := False;

  if Assigned(FLayers.Active) then
  begin
    FColors.ByLayer.Assign(FLayers.Active.Color);

    FLineTypes.ByLayer.Assign(FLayers.Active.LineType);
    FLineTypes.ByLayer.Name := sByLayer;

    FLineWeights.ByLayer := FLayers.Active.LineWeight;

    Result := True;
  end;
end;



function TUdDocument.InitLayers: Boolean;
begin
  Result := False;
  if not Assigned(FLayers) then Exit;

  UpdateByLayer();

  FLayers.OnAdd     := OnLayersAdd;
  FLayers.OnSelect  := OnLayersSelect;
  FLayers.OnRemove  := OnLayersRemove;
  FLayers.OnChanged := OnLayersChanged;

  Result := True;
end;

function TUdDocument.InitLayouts(): Boolean;
begin
  Result := False;
  if not Assigned(FLayouts) then Exit;

  FLayouts.OnAdd     := OnLayoutsAdd;
  FLayouts.OnSelect  := OnLayoutsSelect;
  FLayouts.OnRemove  := OnLayoutsRemove;
  FLayouts.OnChanged := OnLayoutsChanged;

  FLayouts.OnAddEntities              := OnLayoutsAddEntities;
  FLayouts.OnRemoveEntities           := OnLayoutsRemoveEntities;
  FLayouts.OnRemovedEntities          := OnLayoutsRemovedEntities;

  FLayouts.OnAddSelectedEntities      := OnLayoutsAddSelectedEntities;
  FLayouts.OnRemoveSelectedEntities   := OnLayoutsRemoveSelectedEntities;
  FLayouts.OnRemoveAllSelecteEntities := OnLayoutsRemoveAllSelectedEntities;
  FLayouts.OnActionChanged            := OnLayoutsActionChanged;

  FLayouts.OnAxesChanging             := OnLayoutsAxesChanging;
  FLayouts.OnAxesChanged              := OnLayoutsAxesChanged;

  Result := True;
end;





//-------------------------------------------------------------------------------------------

procedure TUdDocument.SetCmdLine(const AValue: TUdCmdLine);
begin
  if FCmdLine = AValue then Exit;

  if Assigned(FCmdLine) then
  begin
    TFCmdLine(FCmdLine)._OnUserText   := nil;
  end;

  FCmdLine := AValue;

  if Assigned(FCmdLine) then
  begin
    TFCmdLine(FCmdLine)._OnUserText   := OnCmdLineUserText ;
  end;
end;


procedure TUdDocument.InitDrawPanelTabs();
var
  I: Integer;
begin
  if not Assigned(FDrawPanel) then Exit;
  
  TFDrawPanel(FDrawPanel)._OnTabChange := nil;
  try
    TFDrawPanel(FDrawPanel)._LayoutTabs.Tabs.Clear();
    for I := 0 to FLayouts.Count - 1 do
      TFDrawPanel(FDrawPanel)._LayoutTabs.Tabs.Add(FLayouts.Items[I].Name);
    TFDrawPanel(FDrawPanel)._LayoutTabs.TabIndex := FLayouts.IndexOf(FLayouts.Active);
  finally
    TFDrawPanel(FDrawPanel)._OnTabChange := OnDrawPanelTabChange;
  end;
end;

procedure TUdDocument.SetDrawPanel(const AValue: TUdDrawPanel);
begin
  if FDrawPanel = AValue then Exit;

  if Assigned(FDrawPanel) then
  begin
    TFDrawPanel(FDrawPanel)._OnPaint      := nil;
    TFDrawPanel(FDrawPanel)._OnScroll     := nil;
    TFDrawPanel(FDrawPanel)._OnDblClick   := nil;
    TFDrawPanel(FDrawPanel)._OnKeyEvent   := nil;
    TFDrawPanel(FDrawPanel)._OnMouseEvent := nil;
    TFDrawPanel(FDrawPanel)._OnMouseWheel := nil;
    TFDrawPanel(FDrawPanel)._OnResized    := nil;
    TFDrawPanel(FDrawPanel)._OnTabChange  := nil;
    TFDrawPanel(FDrawPanel)._OnGetCanPopMenu  := nil;
  end;

  FDrawPanel := AValue;
  FLayouts.DrawPanel := AValue;
  Self.InitDrawPanelTabs();

  if Assigned(FDrawPanel) then
  begin
    TFDrawPanel(FDrawPanel)._OnPaint      := OnDrawPanelPaint;
    TFDrawPanel(FDrawPanel)._OnScroll     := OnDrawPanelScroll;
    TFDrawPanel(FDrawPanel)._OnDblClick   := OnDrawPanelDblClick;
    TFDrawPanel(FDrawPanel)._OnKeyEvent   := OnDrawPanelKeyEvent;
    TFDrawPanel(FDrawPanel)._OnMouseEvent := OnDrawPanelMouseEvent;
    TFDrawPanel(FDrawPanel)._OnMouseWheel := OnDrawPanelMouseWheel;
    TFDrawPanel(FDrawPanel)._OnResized    := OnDrawPanelResized;
    TFDrawPanel(FDrawPanel)._OnTabChange  := OnDrawPanelTabChange;
    TFDrawPanel(FDrawPanel)._OnGetCanPopMenu  := _OnDrawPanelGetCanPopMenu;
  end;
end;




//-------------------------------------------------------------------------------------------

function TUdDocument.GetModelSpace(): TUdLayout;
begin
  Result := nil;
  if Assigned(FLayouts) then
    Result := FLayouts.Model;
end;



function TUdDocument.GetActiveAction(): TUdAction;
begin
  Result := nil;
  if Assigned(Self.ActiveLayout) then
    Result := Self.ActiveLayout.ActiveAction;
end;

function TUdDocument.GetActiveLayout(): TUdLayout;
begin
  Result := nil;
  if Assigned(FLayouts) then
    Result := FLayouts.Active;
end;

procedure TUdDocument.SetActiveLayout(const AValue: TUdLayout);
begin
  if Assigned(FLayouts) then
    FLayouts.Active := AValue;
end;

function TUdDocument.GetActiveLayer: TUdLayer;
begin
  Result := nil;
  if Assigned(FLayers) then
    Result := FLayers.Active;
end;

procedure TUdDocument.SetActiveLayer(const AValue: TUdLayer);
begin
  if Assigned(FLayers) then
    FLayers.SetActive(AValue);
end;


function TUdDocument.GetActiveColor: TUdColor;
begin
  Result := nil;
  if Assigned(FColors) then
    Result := FColors.Active;
end;


procedure TUdDocument.SetActiveColor(const AValue: TUdColor);
begin
  if Assigned(FColors) then
    FColors.SetActive(AValue);
end;


function TUdDocument.GetActiveLineType: TUdLineType;
begin
  Result := nil;
  if Assigned(FLineTypes) then
    Result := FLineTypes.Active;
end;

procedure TUdDocument.SetActiveLineType(const AValue: TUdLineType);
begin
  if Assigned(FLineTypes) then
    FLineTypes.SetActive(AValue);
end;


function TUdDocument.GetActiveLineWeight: TUdLineWeight;
begin
  Result := LW_BYLAYER;
  if Assigned(FLineTypes) then
    Result := FLineWeights.Active;
end;

procedure TUdDocument.SetActiveLineWeight(const AValue: TUdLineWeight);
begin
  if Assigned(FLineTypes) then
    FLineWeights.SetActive(AValue);
end;


function TUdDocument.GetActiveTextStyle: TUdTextStyle;
begin
  Result := nil;
  if Assigned(FTextStyles) then
    Result := FTextStyles.Active;
end;

procedure TUdDocument.SetActiveTextStyle(const AValue: TUdTextStyle);
begin
  if Assigned(FTextStyles) then
    FTextStyles.SetActive(AValue.Name);
end;


function TUdDocument.GetActiveDimStyle: TUdDimStyle;
begin
  Result := nil;
  if Assigned(FDimStyles) then
    Result := FDimStyles.Active;
end;

procedure TUdDocument.SetActiveDimStyle(const AValue: TUdDimStyle);
begin
  if Assigned(FDimStyles) then
    FDimStyles.SetActive(AValue.Name);
end;



//------------------------------------------------------------------------------------------------
{FUndoRedo's Event...}

procedure TUdDocument.OnUndoRedoOnGetObjectByID(Sender: TObject; const AID: Integer; var AObject: TUdObject);
begin
  AObject := TUdObject(FIDTable.GetValue(AID));
end;



//------------------------------------------------------------------------------------------------
{FDrawPanel's Event...}

procedure TUdDocument.OnDrawPanelPaint(Sender: TObject; ACanvas: TCanvas);
var
//  T: Cardinal;
  LActiveLayout: TUdLayout;
begin
  LActiveLayout := Self.GetActiveLayout();

//  T := GetTickCount();
  if Assigned(LActiveLayout) then
  begin
    LActiveLayout.Paint(Sender, ACanvas, 0);
    LActiveLayout.PaintAction(Sender, ACanvas);
  end;
//  T := GetTickCount() - T;
//  if T > 0 then ;

{$IFDEF TRIAL}
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Color := clYellow;
  ACanvas.Font.Size := 16;
  ACanvas.TextOut(5, 5, 'www.xinbosoft.com');

  ACanvas.TextOut(FDrawPanel.Width-160, 5, 'QQ: 51581529');
{$ENDIF}

  if Assigned(FOnUserPaint) then FOnUserPaint(Sender, ACanvas);
end;


procedure TUdDocument.OnDrawPanelScroll(Sender: TObject; AKind: Integer; AScrollCode: TScrollCode; AScrollPos: Integer);
begin
  if Assigned(Self.ActiveLayout) then
    Self.ActiveLayout.Scroll(Sender, AKind, AScrollCode, AScrollPos);
end;

procedure TUdDocument.OnDrawPanelDblClick(Sender: TObject; APoint: TPoint);
begin
  if Assigned(Self.ActiveLayout) then
    Self.ActiveLayout.DblClick(Sender, APoint);
end;

procedure TUdDocument.OnDrawPanelKeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; var AKey: Word);
begin
  if Assigned(Self.ActiveLayout) then
    Self.ActiveLayout.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdDocument.OnDrawPanelMouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState; var APoint: TPoint);
begin
  if Assigned(Self.ActiveLayout) then
  begin
    Self.ActiveLayout.MouseEvent(Sender, AKind, AButton, AShift, APoint);
    if Assigned(FOnMousePoint) then FOnMousePoint(Sender, AKind, AButton, AShift, APoint, Self.ActiveLayout.CurrPoint);
  end;
end;

procedure TUdDocument.OnDrawPanelMouseWheel(Sender: TObject; AKeys: SmallInt; AWheelDelta: SmallInt; XPos, YPos: Smallint);
begin
  if Assigned(Self.ActiveLayout) then
    Self.ActiveLayout.MouseWheel(Sender, AKeys, AWheelDelta, XPos, YPos);
end;

procedure TUdDocument.OnDrawPanelResized(Sender: TObject);
begin
  if Assigned(Self.ActiveLayout) then
    Self.ActiveLayout.Resize(TWinControl(Sender).Width, TWinControl(Sender).Height);
end;

procedure TUdDocument.OnDrawPanelTabChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
begin
  AllowChange := False;
  if (NewTab < 0) or (NewTab > FLayouts.Count) or (FLayouts.Count <= 0) then Exit;

  AllowChange := True;
  if (NewTab = FLayouts.Count) then FLayouts.Add(TFDrawPanel(Self.DrawPanel)._LayoutTabs.Tabs[NewTab], False);

  FLayouts.SetActive(NewTab);
end;

procedure TUdDocument._OnDrawPanelGetCanPopMenu(Sender: TObject;  var Allow: Boolean);
var
  LAction: TUdAction;
begin
  Allow := True;
  LAction := Self.GetActiveAction();
  if Assigned(LAction) then Allow := LAction.CanPopMenu;
end;



procedure TUdDocument.OnCmdLineUserText(Sender: TObject; AText: string);
begin
  if Assigned(Self.ActiveLayout) then
  begin
    if AText = '*' then
      Self.ActiveLayout.ActionClear()
    else begin
      if Self.ActiveLayout.IsIdleAction then
        Self.ExecCommond(AText)
      else
        Self.ActiveLayout.ActionParse(AText);
    end;
  end;
end;







//------------------------------------------------------------------
{FColors's Event...}

procedure TUdDocument.OnColorsAdd(Sender: TObject; AColor: TUdColor);
begin
  if Assigned(FOnColorAdd) then FOnColorAdd(Sender, AColor);
end;

procedure TUdDocument.OnColorsSelect(Sender: TObject; AColor: TUdColor);
begin
  if Assigned(FOnColorSelect) then FOnColorSelect(Sender, AColor);
end;

procedure TUdDocument.OnColorsRemove(Sender: TObject; AColor: TUdColor; var AAllow: Boolean);
//var
//  I: Integer;
//  LEntity: TUdEntity;
begin
  AAllow := True;

//  for I := 0 to FContent.AllList.Count - 1 do
//  begin
//    LEntity := TUdEntity(FContent.AllList.Items[I]);
//    if TUdColor(LEntity.Color).Handle = TUdColor(AColor).Handle then
//    begin
//      AAllow := False;
//      Break;
//    end;
//  end;

  if AAllow and Assigned(FOnColorRemove) then FOnColorRemove(Sender, AColor, AAllow);
end;


procedure TUdDocument.OnColorsChanged(Sender: TObject; APropName: string);
begin
  //... ...
end;



//------------------------------------------------------------------
{FLineTypes's Event...}

procedure TUdDocument.OnLineTypesAdd(Sender: TObject; ALineType: TUdLineType);
begin
  if Assigned(FOnLineTypeAdd) then FOnLineTypeAdd(Sender, ALineType);
end;

procedure TUdDocument.OnLineTypesSelect(Sender: TObject; ALineType: TUdLineType);
begin
  if Assigned(FOnLineTypeSelect) then FOnLineTypeSelect(Sender, ALineType);
end;

procedure TUdDocument.OnLineTypesRemove(Sender: TObject; ALineType: TUdLineType; var AAllow: Boolean);
//var
//  I: Integer;
//  LEntity: TUdEntity;
begin
  AAllow := True;

//  for I := 0 to FContent.AllList.Count - 1 do
//  begin
//    LEntity := TUdEntity(FContent.AllList.Items[I]);
//    if TUdLineType(LEntity.LineType).Handle = TUdLineType(ALineType).Handle then
//    begin
//      AAllow := False;
//      Break;
//    end;
//  end;

  if AAllow and Assigned(FOnLineTypeRemove) then FOnLineTypeRemove(Sender, ALineType, AAllow);
end;


procedure TUdDocument.OnLineTypesChanged(Sender: TObject; APropName: string);
begin
  //... ...
end;




//------------------------------------------------------------------
{FLineWeights's Event...}

procedure TUdDocument.OnLineWeightsSelect(Sender: TObject; ALineWeight: TUdLineWeight);
begin
  if Assigned(FOnLineWeightSelect) then FOnLineWeightSelect(Sender, ALineWeight);
end;

procedure TUdDocument.OnLineWeightsChanged(Sender: TObject; APropName: string);
begin
  //... ...
end;







//------------------------------------------------------------------------------------------------
{FLayers's Event...}

procedure TUdDocument.OnLayersAdd(Sender: TObject; ALayer: TUdLayer);
begin
  if Assigned(FOnLayerAdd) then FOnLayerAdd(Sender, ALayer);
end;

procedure TUdDocument.OnLayersSelect(Sender: TObject; ALayer: TUdLayer);
begin
  UpdateByLayer();
  if Assigned(FOnLayerSelect) then FOnLayerSelect(Sender, ALayer);
end;

procedure TUdDocument.OnLayersRemove(Sender: TObject; ALayer: TUdLayer; var AAllow: Boolean);
//var
//  I: Integer;
//  LEntity: TUdEntity;
begin
  AAllow := True;

//  for I := 0 to FContent.AllList.Count - 1 do
//  begin
//    LEntity := TUdEntity(FContent.AllList.Items[I]);
//    if TUdLayer(LEntity.Layer).Handle = TUdLayer(ALayer).Handle then
//    begin
//      AAllow := False;
//      Break;
//    end;
//  end;

  if AAllow and Assigned(FOnLayerRemove) then FOnLayerRemove(Sender, ALayer, AAllow);
end;

procedure TUdDocument.OnLayersChanged(Sender: TObject; APropName: string);
begin
  //... ...
end;




//-----------------------------------------------------------------------------------------------
{Layouts's Event...}

procedure TUdDocument.OnLayoutsAdd(Sender: TObject; ALayout: TUdLayout);
begin
  if FLayouts.IndexOf(ALayout) >= TFDrawPanel(FDrawPanel)._LayoutTabs.Tabs.Count then
    TFDrawPanel(FDrawPanel)._LayoutTabs.Tabs.Add(ALayout.Name);
    
  if Assigned(FOnLayoutAdd) then FOnLayoutAdd(Sender, ALayout);
end;

procedure TUdDocument.OnLayoutsSelect(Sender: TObject; ALayout: TUdLayout);
begin
  TFDrawPanel(FDrawPanel)._LayoutTabs.TabIndex := FLayouts.IndexOf(ALayout);
  
  if Assigned(FOnLayoutSelect) then FOnLayoutSelect(Sender, ALayout);
end;

procedure TUdDocument.OnLayoutsRemove(Sender: TObject; ALayout: TUdLayout; var AAllow: Boolean);
var
  N: Integer;
begin
  AAllow := True;

  if AAllow then
    if Assigned(FOnLayoutRemove) then FOnLayoutRemove(Sender, ALayout, AAllow);

  if AAllow then
  begin
    N := FLayouts.IndexOf(ALayout);
    TFDrawPanel(FDrawPanel)._LayoutTabs.Tabs.Delete(N);
  end;
end;

procedure TUdDocument.OnLayoutsChanged(Sender: TObject; APropName: string);
begin
  //... ...
end;



procedure TUdDocument.OnLayoutsAddEntities(Sender: TObject; Entities: TUdEntityArray);
begin
  if Assigned(FOnAddEntities) then FOnAddEntities(Sender, Entities);
end;

procedure TUdDocument.OnLayoutsRemoveEntities(Sender: TObject; Entities: TUdEntityArray);
begin
  if Assigned(FOnRemoveEntities) then FOnRemoveEntities(Sender, Entities);
end;

procedure TUdDocument.OnLayoutsRemovedEntities(Sender: TObject);
begin
  if Assigned(FOnRemovedEntities) then FOnRemovedEntities(Sender);
end;

procedure TUdDocument.OnLayoutsAddSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
begin
  if Assigned(FOnAddSelectedEntities) then FOnAddSelectedEntities(Sender, Entities);
end;

procedure TUdDocument.OnLayoutsRemoveSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
begin
  if Assigned(FOnRemoveSelectedEntities) then FOnRemoveSelectedEntities(Sender, Entities);
end;

procedure TUdDocument.OnLayoutsRemoveAllSelectedEntities(Sender: TObject);
begin
  if Assigned(FOnRemoveAllSelecteEntities) then FOnRemoveAllSelecteEntities(Sender);
end;



procedure TUdDocument.OnLayoutsActionChanged(Sender: TObject);
var
  LActiveLayout: TUdLayout;
begin
  LActiveLayout := Self.GetActiveLayout();

  if Sender = LActiveLayout then
  begin
    if LActiveLayout.IsIdleAction() then
    begin
      if Assigned(FCmdLine) then FCmdLine.CommandName := sCmdName;
    end;
  end;

  if Assigned(FOnActionChanged) then FOnActionChanged(Self);
end;



procedure TUdDocument.OnLayoutsAxesChanging(Sender: TObject);
begin
  if Assigned(FOnAxesChanging) then FOnAxesChanging(Sender);
end;

procedure TUdDocument.OnLayoutsAxesChanged(Sender: TObject);
begin
  if Assigned(FOnAxesChanged) then FOnAxesChanged(Sender);
end;


procedure TUdDocument.OnPointStyleChanged(Sender: TObject);
var
  I: Integer;
  LEnt: TUdEntity;
begin
  for I := 0 to FLayouts.Model.Entities.Count - 1 do
  begin
    LEnt := FLayouts.Model.Entities.Items[I];
    if LEnt.InheritsFrom(TUdPoint) then
    begin
      TUdPoint(LEnt).Size := FPointStyle.Size;
      TUdPoint(LEnt).States := FPointStyle.States;
      TUdPoint(LEnt).DrawingUnits := FPointStyle.DrawingUnits;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------

procedure TUdDocument.AddDocObject(Sender: TUdObject; AObj: TUdObject; ANeedUndo: Boolean = True);
var
  LObjColl: IUdObjectCollection;
begin
  if Assigned(AObj) then
  begin
    Self.AddToIDTable(AObj);

    if ANeedUndo and (FState = 0) then
    begin
      if not Self.Loading and Assigned(AObj.Owner) and AObj.Owner.GetInterface(IUdObjectCollection, LObjColl) then
        FUndoRedo.DoAddObject(AObj);
    end;
  end;
end;

procedure TUdDocument.RemoveDocObject(Sender: TUdObject; AObj: TUdObject; ANeedUndo: Boolean = True);
var
  LObjColl: IUdObjectCollection;
begin
  if Assigned(AObj) then
  begin
    Self.RemoveFromIDTable(AObj);

    if ANeedUndo and (FState = 0) then
    begin
      if Assigned(AObj.Owner) and AObj.Owner.GetInterface(IUdObjectCollection, LObjColl) then
        FUndoRedo.DoRemoveObject(AObj)
      else
        AObj.Free;
    end
    else AObj.Free;
  end;
end;



function TUdDocument.RaiseBeforeModifyObject(Sender: TUdObject; APropName: string; ANeedUndo: Boolean = True): Boolean;
begin
  Result := True;
  if Assigned(FOnBeforeObjectModify) then FOnBeforeObjectModify(Self, Sender, APropName, Result);

  if not Result then Exit; //======>>>
  if (FIDTable.GetValue(Sender.ID) <> Sender) then Exit; //======>>>

  if Assigned(Sender) and Sender.InheritsFrom(TUdBlock) and (UpperCase(APropName) = 'ENTITIES') then
  begin
    //Check all inserts, allow to change
  end;

  if ANeedUndo and (FState = 0) then
  begin
    FUndoRedo.BeginUndo('');
    FUndoRedo.DoBeforeModifyObject(Sender, APropName);
  end;
end;


procedure TUdDocument.RaiseAfterModifyObject(Sender: TUdObject; APropName: string; ANeedUndo: Boolean = True);
var
  I, J: Integer;
  LEntity: TUdEntity;
  LLayout: TUdLayout;
begin
  if Self.Creating then Exit; //======>>>>
  if not Assigned(Sender) or (FIDTable.GetValue(Sender.ID) <> Sender) then Exit; //======>>>
  

  if Sender.InheritsFrom(TUdBlock) and (UpperCase(APropName) = 'ENTITIES') then
  begin
    for I := 0 to FLayouts.Count - 1 do
    begin
      LLayout := FLayouts.Items[I];
      for J := 0 to LLayout.Entities.Count - 1 do
      begin
        LEntity := LLayout.Entities.Items[J];
        if not Assigned(LEntity) or not LEntity.InheritsFrom(TUdInsert) then Continue;

        LEntity.RaiseBeforeModifyObject('Block');
        LEntity.Update();
        LEntity.RaiseAfterModifyObject('Block');
      end;
    end;
  end;

  if ANeedUndo and (FState = 0) then
  begin
    FUndoRedo.EndUndo();
    if Assigned(FOnAfterObjectModify) then FOnAfterObjectModify(Self, Sender, APropName);
  end;
end;






//------------------------------------------------------------------

function TUdDocument.ExecCommond(const AValue: string): Boolean;

  function _IsShortCmdName(ACmdName, AText: string; var AIsQuot: Boolean): Boolean;
  var
    LCmdName: string;
  begin
    Result := False;
    AIsQuot := False;
    if ACmdName = '' then Exit;

    LCmdName := ACmdName;

    AIsQuot := LCmdName[1] = '''';
    if AIsQuot then Delete(LCmdName, 1, 1);

    while (System.Length(LCmdName) > 1) and (LCmdName[1] = '_') do Delete(LCmdName, 1, 1);
    Result := Pos(LCmdName, AText) <= 0;
  end;

var
  N: Integer;
  LBool: Boolean;
  LMode: Integer;
  LSize: Double;
  LIsQuot: Boolean;
  LText, LArgs: string;
  LActionClass: TUdActionClass;
  LActiveLayout: TUdLayout;
begin
  Result := False;

  LActiveLayout := Self.GetActiveLayout();
  if not Assigned(LActiveLayout) then Exit;


  LArgs := '';
  LText := LowerCase(Trim(AValue));

  if (LText = 'undo') or (LText = '_undo') then
  begin
    LActiveLayout.ActionClear();
    Result := Self.PerformUndo();
    Exit; //====>>>>
  end;

  if (LText = 'redo') or (LText = '_redo') then
  begin
    LActiveLayout.ActionClear();
    Result := Self.PerformRedo();
    Exit; //====>>>>
  end;

  if (LText = 'layer') or (LText = '_layer') then
  begin
    Result := UdLayersFrm.ShowLayersDialog(FLayers);
    FLastCmd := 'layer';
    Exit; //====>>>>
  end;

  if (LText = 'color') or (LText = '_color') then
  begin
    Result := UdColorsFrm.ShowColorsDialog(FColors);
    FLastCmd := 'color';
    Exit; //====>>>>
  end;

  if (LText = 'linetype') or (LText = '_linetype') then
  begin
    Result := UdLineTypesFrm.ShowLineTypesDialog(FLineTypes);
    FLastCmd := 'linetype';
    Exit; //====>>>>
  end;

  if (LText = 'lweight') or (LText = '_lweight') or (LText = 'lineweight') or (LText = '_lineweight') then
  begin
    LBool := Self.ActiveLayout.Drafting.LwtDisp;
    Result := UdLineWeightsFrm.ShowLineWeightsDialog(FLineWeights, LBool);
    if Result then Self.ActiveLayout.Drafting.LwtDisp := LBool;

    FLastCmd := 'lweight';
    Exit; //====>>>>
  end;

  if (LText = 'textstyle') or (LText = '_textstyle') then
  begin
    Result := UdTextStylesFrm.ShowTextStylesDialog(FTextStyles);
    FLastCmd := 'textstyle';
    Exit; //====>>>>
  end;

  if (LText = 'dimstyle') or (LText = '_dimstyle') then
  begin
    Result := UdDimStylesFrm.ShowDimStylesDialog(FDimStyles);
    FLastCmd := 'dimstyle';
    Exit; //====>>>>
  end;

  if (LText = 'dsettings') or (LText = '_dsettings') then
  begin
    Result := UdDraftingFrm.ShowDraftingDialog(Self.ActiveLayout.Drafting);
    FLastCmd := 'dsettings';
    Exit; //====>>>>
  end;

  if (LText = 'ddptype') or (LText = '_ddptype') then
  begin
    LMode := FPointStyle.Mode;
    LSize := FPointStyle.Size;
    LBool := FPointStyle.DrawingUnits;
  
    if UdPointStyleFrm.ShowPointStyleDialog(LMode, LSize, LBool) then
    begin
      if Self.RaiseBeforeModifyObject(Self, 'PointStyle') then
      begin
        FPointStyle.Mode := LMode;
        FPointStyle.Size := LSize;
        FPointStyle.DrawingUnits := LBool;

        Self.RaiseAfterModifyObject(Self, 'PointStyle');
        Result := True;
      end;
    end;

    FLastCmd := 'ddptype';
    Exit; //====>>>>
  end;


  N := Pos(' ', LText);
  if N > 0 then
  begin
    LArgs := SysUtils.Trim( Copy(LText, N + 1, System.Length(LText)) );
    Delete(LText, N, System.Length(LText));
  end;

  if LText = '' then Exit;

  LActionClass := FActions.GetActionClass(LText);
  if not Assigned(LActionClass) and (LText[1] <> '_') then
    LActionClass := FActions.GetActionClass('_' + LText);

  if LActionClass = Self.ActiveLayout.ActiveAction.ClassType then Exit; //========>>>>


  if Assigned(LActionClass) then
  begin
    Self.Prompt(sCmdName + ': ' +  LText, pkLog);

    if _IsShortCmdName(LActionClass.CommandName, LText, LIsQuot) then
      Self.Prompt(LActionClass.CommandName, pkLog);

    if LIsQuot or LActionClass.InheritsFrom(TUdViewAction) then
    begin
      Result := LActiveLayout.ActionAdd(LActionClass, LArgs);
    end
    else begin
      Self.ActiveLayout.ActionClear();
      Result := LActiveLayout.ActionAdd(LActionClass, LArgs);
      FLastCmd := LActionClass.CommandName();
    end;
  end
  else begin
    Self.Prompt(sUnknownCmd +  '"' + AValue + '".', pkLog);
  end;
end;


function TUdDocument.Prompt(const AValue: string; AKind: TUdPromptKind): Boolean;
begin
  if Assigned(FCmdLine) then
  begin
    if AKind = pkLog then FCmdLine.AddLog(AValue) else
    if AKind = pkCmd then FCmdLine.CommandName := AValue;
  end;

  if Assigned(FOnPrompt) then
    FOnPrompt(Self, AValue, AKind);

  Result := True;
end;




function TUdDocument.BeginUndo(AName: string): Boolean;
begin
  Result := FUndoRedo.BeginUndo(AName);
end;

function TUdDocument.EndUndo(): Boolean;
begin
  Result := FUndoRedo.EndUndo();
end;

function TUdDocument.PerformUndo(): Boolean;
begin
  if Assigned(Self.ActiveLayout) then
    Self.ActiveLayout.RemoveAllSelected();
  Result := FUndoRedo.PerformUndo();
end;

function TUdDocument.PerformRedo(): Boolean;
begin
  if Assigned(Self.ActiveLayout) then
    Self.ActiveLayout.RemoveAllSelected();
  Result := FUndoRedo.PerformRedo();
end;



//------------------------------------------------------------------------------------

function TUdDocument.Clear(): Boolean;
var
  N: Cardinal;
begin
  N := FState;
  FState := STATE_DESTROYING;
  try
    FLayers.Clear(False);
    FColors.Clear(False);
    FLineTypes.Clear(False);
  //  FLineWeights.Clear(False);

  //  FPointStyle.Clear(False);
    FTextStyles.Clear(False);
    FDimStyles.Clear(False);
  //  FUnits.Clear(False);

    FBlocks.Clear({False});

  //  FOptions.Clear(False);
    FLayouts.Clear(False);

    FUndoRedo.Clear();

    Self.RestIdTable();
  finally
    FState := N;
  end;

  FLastCmd := '';
  Result := True;
end;

function TUdDocument.GetNextObjectID(): Integer;
begin
  Inc(FIDSeed);
  Result := FIDSeed;
end;




procedure TUdDocument.RestIdTable();
begin
  FIDSeed := 0;

  if not Assigned(FIDTable) then
    FIDTable := TUdIntHashMap.Create()
  else
    FIDTable.Clear();

  Self.AddToIDTable(Self);

  Self.AddToIDTable(FOptions);
  Self.AddToIDTable(FLayers);
  Self.AddToIDTable(FColors);
  Self.AddToIDTable(FLineTypes);
  Self.AddToIDTable(FLineWeights);

  Self.AddToIDTable(FPointStyle);
  Self.AddToIDTable(FTextStyles);
  Self.AddToIDTable(FDimStyles);

  Self.AddToIDTable(FUnits);
  Self.AddToIDTable(FBlocks);
  Self.AddToIDTable(FHatchPatterns);

  Self.AddToIDTable(FLayouts);

  FIDSeed := RESERVED_ID_COUNT;
end;

function TUdDocument.AddToIDTable(AObj: TUdObject): Boolean;
begin
  Result := False;
  if not Assigned(AObj) then Exit;

  if (AObj.ID < 0) or (FIDTable.GetValue(AObj.ID) <> nil) then
    TFObject(AObj).SetID( Self.GetNextObjectID() );

  try
    FIDTable.Add(AObj.ID, AObj);
  except
    if AObj.ID <> 0 then ;
  end;

  Result := True;
end;

function TUdDocument.RemoveFromIDTable(AObj: TUdObject): Boolean;
begin
  Result := False;
  if not Assigned(AObj) then Exit;

  FIDTable.Remove(AObj.ID);
  Result := True;
end;


function TUdDocument.GetViewSize(AIndex: Integer): Float;
begin
  Result := 0;
  if Assigned(FLayouts) and Assigned(FLayouts.Active) then
  begin
    case AIndex of
      0: Result := Abs(FLayouts.Active.ViewBound.Y2 - FLayouts.Active.ViewBound.Y1);
      1: Result := Abs(FLayouts.Active.ViewBound.X2 - FLayouts.Active.ViewBound.X1);
    end;
  end;
end;





    

//------------------------------------------------------------------------------------

procedure TUdDocument.SaveToStream(AStream: TStream);
begin
  inherited;

  try
    StrToStream(AStream, FILE_HEAD);

    IntToStream(AStream, FVer);
    IntToStream(AStream, FIDSeed);

    FLayers.SaveToStream(AStream);
    FColors.SaveToStream(AStream);
    FLineTypes.SaveToStream(AStream);
    FLineWeights.SaveToStream(AStream);
    Self.DoProgress(15, 100);

    FPointStyle.SaveToStream(AStream);
    FTextStyles.SaveToStream(AStream);
    FDimStyles.SaveToStream(AStream);
    FUnits.SaveToStream(AStream);
    Self.DoProgress(30, 100);

    FBlocks.SaveToStream(AStream);
    //Self.DoProgress(40~90, 100);

    FOptions.SaveToStream(AStream);
    Self.DoProgress(100, 100);

    FLayouts.SaveToStream(AStream);
  finally
    Self.DoProgress(-1, 100);
  end;
end;

procedure TUdDocument.LoadFromStream(AStream: TStream);
var
  LVer: Integer;
  LFileHead: string;
begin
  inherited;

  LFileHead := StrFromStream(AStream);
  if LFileHead <> FILE_HEAD then Exit;

  LVer := IntFromStream(AStream);
  FIDSeed := IntFromStream(AStream);;

  FState := STATE_LOADING;
  try
    FCcp.Clear();
    FIDTable.Clear();

    if LVer < FVer then ;

    FLayers.LoadFromStream(AStream);
    FColors.LoadFromStream(AStream);
    FLineTypes.LoadFromStream(AStream);
    FLineWeights.LoadFromStream(AStream);
    Self.DoProgress(15, 100);

    FPointStyle.LoadFromStream(AStream);
    FTextStyles.LoadFromStream(AStream);
    FDimStyles.LoadFromStream(AStream);
    FUnits.LoadFromStream(AStream);
    Self.DoProgress(30, 100);

    FBlocks.LoadFromStream(AStream);
    //Self.DoProgress(40~90, 100);

    FOptions.LoadFromStream(AStream);
    Self.DoProgress(100, 100);

    FLayouts.LoadFromStream(AStream);

    if LVer < FVer then ; //在这里根据版本判断 如果新版本有新加了Document的字段对象的话 分配ID给它
  finally
    FState := 0;
    Self.DoProgress(-1, 100);
  end;

  FUndoRedo.Clear();
  Self.InitDrawPanelTabs();

  Self.ModelSpace.ZoomExtends();
end;



function TUdDocument.SaveToFile(AFileName: string): Boolean;
var
  LMemStream: TMemoryStreamEx;
begin
  Result := True;

  LMemStream := TMemoryStreamEx.Create();
  try
    Self.SaveToStream(LMemStream);
    try
      LMemStream.SaveToFile(AFileName);
    except
      Result := False;
    end;
  finally
    LMemStream.Free;
  end;
end;

function TUdDocument.LoadFromFile(AFileName: string): Boolean;
var
  LMemStream: TMemoryStreamEx;
begin
  Result := False;
  if not FileExists(AFileName) then Exit;

  Result := True;

  LMemStream := TMemoryStreamEx.Create();
  try
    LMemStream.LoadFromFile(AFileName);
    LMemStream.Seek(0, soFromBeginning);

    try
      Self.LoadFromStream(LMemStream);
    except
      Result := False;
    end;
  finally
    LMemStream.Free;
  end;
end;



function TUdDocument.SaveToDxfFile(AFileName: string): Boolean;
var
  LDxfWriter: TUdDxfWriter;
begin
  LDxfWriter := TUdDxfWriter.Create(Self);
  try
//    LDxfWriter.Version := dxf12;
//    LDxfWriter.Version := dxf2000;
    LDxfWriter.Version := dxf2004;
    Result := LDxfWriter.Execute(AFileName);
  finally
    LDxfWriter.Free;
  end;
end;

function TUdDocument.LoadFromDxfFile(AFileName: string): Boolean;
var
  LDxfReader: TUdDxfReader;
begin
  LDxfReader := TUdDxfReader.Create(Self);
  FState := STATE_CREATING or STATE_LOADING;
  try
    Result := LDxfReader.Execute(AFileName);
    Self.ModelSpace.ZoomExtends();
  finally
    FState := 0;
    LDxfReader.Free;
  end;
  Self.InitDrawPanelTabs();
end;


procedure TUdDocument.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXMLNode;
  LRootNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  try
    LRootNode := TUdXmlNode(AXmlNode);
    LRootNode.Prop['Mark'] := 'DelphiCAD';
    LRootNode.Prop['Ver'] := IntToStr(FVer);
    LRootNode.Prop['IDSeed'] := IntToStr(FIDSeed);

    LXmlNode := LRootNode.Add();
    FLayers.SaveToXml(LXmlNode);

    LXmlNode := LRootNode.Add();
    FColors.SaveToXml(LXmlNode);

    LXmlNode := LRootNode.Add();
    FLineTypes.SaveToXml(LXmlNode);

    LXmlNode := LRootNode.Add();
    FLineWeights.SaveToXml(LXmlNode);

    Self.DoProgress(15, 100);


    LXmlNode := LRootNode.Add();
    FPointStyle.SaveToXml(LXmlNode);

    LXmlNode := LRootNode.Add();
    FTextStyles.SaveToXml(LXmlNode);

    LXmlNode := LRootNode.Add();
    FDimStyles.SaveToXml(LXmlNode);

    LXmlNode := LRootNode.Add();
    FUnits.SaveToXml(LXmlNode);

    Self.DoProgress(30, 100);


    LXmlNode := LRootNode.Add();
    FBlocks.SaveToXml(LXmlNode);
    //Self.DoProgress(40~90, 100);


    LXmlNode := LRootNode.Add();
    FOptions.SaveToXml(LXmlNode);
    Self.DoProgress(100, 100);

    LXmlNode := LRootNode.Add();
    FLayouts.SaveToXml(LXmlNode);

  finally
    Self.DoProgress(-1, 100);
  end;
end;

procedure TUdDocument.LoadFromXml(AXmlNode: TObject);
var
  LVer: Integer;
  LMark: string;
  LRootNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LRootNode := TUdXmlNode(AXmlNode);

  LMark := LRootNode.Prop['Mark'];
  LVer := StrToIntDef(LRootNode.Prop['Ver'], -1);
  FIDSeed := StrToIntDef(LRootNode.Prop['IDSeed'], -1);

  if (LMark = '') or (LVer < 0) or (FIDSeed < 0) then
  begin
    raise Exception.Create('Invlid DelphiCAD XML File');
    Exit; //=====>>>>>
  end;
  

  FState := STATE_LOADING;
  try
    FCcp.Clear();
    FIDTable.Clear();

    if LVer < FVer then ;

    FLayers.LoadFromXml(LRootNode.FindItem('Layers'));
    FColors.LoadFromXml(LRootNode.FindItem('Colors'));
    FLineTypes.LoadFromXml(LRootNode.FindItem('LineTypes'));
    FLineWeights.LoadFromXml(LRootNode.FindItem('LineWeights'));
    Self.DoProgress(15, 100);

    FPointStyle.LoadFromXml(LRootNode.FindItem('PointStyle'));
    FTextStyles.LoadFromXml(LRootNode.FindItem('TextStyles'));
    FDimStyles.LoadFromXml(LRootNode.FindItem('DimStyles'));
    FUnits.LoadFromXml(LRootNode.FindItem('Units'));
    Self.DoProgress(30, 100);

    FBlocks.LoadFromXml(LRootNode.FindItem('Blocks'));
    //Self.DoProgress(40~90, 100);

    FOptions.LoadFromXml(LRootNode.FindItem('Options'));
    Self.DoProgress(100, 100);

    FLayouts.LoadFromXml(LRootNode.FindItem('Layouts'));

    if LVer < FVer then ; //在这里根据版本判断 如果新版本有新加了Document的字段对象的话 分配ID给它
  finally
    FState := 0;
    Self.DoProgress(-1, 100);
  end;

  FUndoRedo.Clear();
  Self.InitDrawPanelTabs();

  Self.ModelSpace.ZoomExtends();
end;




function TUdDocument.SaveToXmlFile(AFileName: string): Boolean;
var
  LXmlDocument: TUdXMLDocument;
begin
  Result := True;

  LXmlDocument := TUdXMLDocument.Create;
  try
    LXmlDocument.AutoIndent := True;
    Self.SaveToXml(LXmlDocument.Root);

    try
      LXmlDocument.SaveToFile(AFileName);
    except
      Result := False;
    end;
  finally
    LXmlDocument.Free;
  end;
end;

function TUdDocument.LoadFromXmlFile(AFileName: string): Boolean;
var
  LXmlDocument: TUdXMLDocument;
begin
  Result := False;
  if not FileExists(AFileName) then Exit;

  Result := True;

  LXmlDocument := TUdXMLDocument.Create;
  try
    LXmlDocument.LoadFromFile(AFileName);
    try
      Self.LoadFromXml(LXmlDocument.Root);
    except
      Result := False;
    end;
  finally
    LXmlDocument.Free;
  end;
end;



//---------------------------------------------------------------------------------------

{Layer和LineType是否在使用的检查 应该包含Insert和Block当中的每一个Entity 现在不正确 }

procedure TUdDocument.UpdateLayersStatus();

  function _IsLayerUsed(ALayer: TUdLayer): Boolean;
  var
    I, J, K: Integer;
    LLayout: TUdLayout;
    LEntity, LEntity2: TUdEntity;
    LEntityList: TList;
    LChildEntites: IUdChildEntities;    
  begin
    Result := False;

    for I := 0 to FLayouts.Count - 1 do
    begin
      LLayout := FLayouts.Items[I];
      
      for J := 0 to LLayout.Entities.Count - 1 do
      begin
        LEntity := LLayout.Entities.Items[J];

        if Assigned(LEntity.Layer) and (LEntity.Layer = ALayer) then
        begin
          Result := True;
          Exit; //========>>>>>
        end;

        if LEntity.GetInterface(IUdChildEntities, LChildEntites) then
        begin
          LEntityList := LChildEntites.GetChildEntities();
          for K := 0 to LEntityList.Count - 1 do
          begin
            LEntity2 := LEntityList[K];

            if Assigned(LEntity2.Layer) and (LEntity2.Layer = ALayer) then
            begin
              Result := True;
              Exit; //========>>>>>
            end;
          end;
        end;
      end;
    end;
  end;

var
  I: Integer;
  LLayer: TUdLayer;
begin
  for I := 0 to FLayers.Count - 1 do
  begin
    LLayer := FLayers.Items[I];
    LLayer.Status := 0;

    if FLayers.Active = LLayer then
      LLayer.Status := STATUS_CURRENT;
  end;

  for I := 1 to FLayers.Count - 1 do
  begin
    LLayer := FLayers.Items[I];
    if not _IsLayerUsed(LLayer) then LLayer.Status := LLayer.Status or STATUS_USELESS;
  end;
end;

procedure TUdDocument.UpdateLineTypesStatus();

  function _IsLineTypeUsed(ALineType: TUdLineType): Boolean;
  var
    I, J, K: Integer;
    LLayout: TUdLayout;
    LEntity, LEntity2: TUdEntity;
    LEntityList: TList;
    LChildEntites: IUdChildEntities;
  begin
    Result := False;

    for I := 0 to FLayouts.Count - 1 do
    begin
      LLayout := FLayouts.Items[I];
      
      for J := 0 to LLayout.Entities.Count - 1 do
      begin
        LEntity := LLayout.Entities.Items[J];

        if Assigned(LEntity.LineType) and (LEntity.LineType.Name = ALineType.Name) then
        begin
          Result := True;
          Exit; //========>>>>>
        end;

        if LEntity.GetInterface(IUdChildEntities, LChildEntites) then
        begin
          LEntityList := LChildEntites.GetChildEntities();
          for K := 0 to LEntityList.Count - 1 do
          begin
            LEntity2 := LEntityList[K];

            if Assigned(LEntity2.LineType) and (LEntity2.LineType.Name = ALineType.Name) then
            begin
              Result := True;
              Exit; //========>>>>>
            end;
          end;
        end;
      end;
    end;
  end;

var
  I: Integer;
  LLineType: TUdLineType;
begin
  for I := 0 to FLineTypes.Count - 1 do
  begin
    LLineType := FLineTypes.Items[I];
    LLineType.Status := 0;

    if FLineTypes.Active = LLineType then
      LLineType.Status := STATUS_CURRENT;
  end;

  for I := 3 to FLineTypes.Count - 1 do
  begin
    LLineType := FLineTypes.Items[I];
    if not _IsLineTypeUsed(LLineType) then LLineType.Status := LLineType.Status or STATUS_USELESS;
  end;
end;


procedure TUdDocument.UpdateTextTypesStatus();

  function _IsTextStyleUsed(ATextStyle: TUdTextStyle): Boolean;
  var
    I, J, K: Integer;
    LLayout: TUdLayout;
    LEntity, LEntity2: TUdEntity;
    LEntityList: TList;
    LChildEntites: IUdChildEntities;    
  begin
    Result := False;

    for I := 0 to FLayouts.Count - 1 do
    begin
      LLayout := FLayouts.Items[I];

      for J := 0 to LLayout.Entities.Count - 1 do
      begin
        LEntity := LLayout.Entities.Items[J];

        if LEntity.GetInterface(IUdChildEntities, LChildEntites) then
        begin
          LEntityList := LChildEntites.GetChildEntities();
          for K := 0 to LEntityList.Count - 1 do
          begin
            LEntity2 := LEntityList[K];

            if LEntity2.InheritsFrom(TUdText) and
               Assigned(TUdText(LEntity2).TextStyle) and
               (TUdText(LEntity2).TextStyle = ATextStyle) then
            begin
              Result := True;
              Exit; //========>>>>>
            end;

          end;
        end
        else begin
          if LEntity.InheritsFrom(TUdText) and
             Assigned(TUdText(LEntity).TextStyle) and
             (TUdText(LEntity).TextStyle = ATextStyle) then
          begin
            Result := True;
            Exit; //========>>>>>
          end;
        end;

      end;
    end;
  end;

var
  I: Integer;
  LTextStyle: TUdTextStyle;
begin
  for I := 0 to FTextStyles.Count - 1 do
  begin
    LTextStyle := FTextStyles.Items[I];
    LTextStyle.Status := 0;

    if FTextStyles.Active = LTextStyle then
      LTextStyle.Status := STATUS_CURRENT;
  end;

  for I := 1 to FTextStyles.Count - 1 do
  begin
    LTextStyle := FTextStyles.Items[I];
    if not _IsTextStyleUsed(LTextStyle) then LTextStyle.Status := LTextStyle.Status or STATUS_USELESS;
  end;
end;

procedure TUdDocument.UpdateDimTypesStatus();


  function _IsDimStyleUsed(ADimStyle: TUdDimStyle): Boolean;
  var
    I, J, K: Integer;
    LLayout: TUdLayout;
    LEntity, LEntity2: TUdEntity;
    LEntityList: TList;
    LChildEntites: IUdChildEntities;    
  begin
    Result := False;

    for I := 0 to FLayouts.Count - 1 do
    begin
      LLayout := FLayouts.Items[I];

      for J := 0 to LLayout.Entities.Count - 1 do
      begin
        LEntity := LLayout.Entities.Items[J];

        if LEntity.GetInterface(IUdChildEntities, LChildEntites) then
        begin
          LEntityList := LChildEntites.GetChildEntities();
          for K := 0 to LEntityList.Count - 1 do
          begin
            LEntity2 := LEntityList[K];

            if LEntity2.InheritsFrom(TUdDimension) and
               Assigned(TUdDimension(LEntity2).DimStyle) and
               (TUdDimension(LEntity2).DimStyle = ADimStyle) then
            begin
              Result := True;
              Exit; //========>>>>>
            end;

          end;
        end
        else begin
          if LEntity.InheritsFrom(TUdDimension) and
             Assigned(TUdDimension(LEntity).DimStyle) and
             (TUdDimension(LEntity).DimStyle = ADimStyle) then
          begin
            Result := True;
            Exit; //========>>>>>
          end;
        end;

      end;
    end;
  end;

var
  I: Integer;
  LDimStyle: TUdDimStyle;
begin
  for I := 0 to FDimStyles.Count - 1 do
  begin
    LDimStyle := FDimStyles.Items[I];
    LDimStyle.Status := 0;

    if FDimStyles.Active = LDimStyle then
      LDimStyle.Status := STATUS_CURRENT;
  end;

  for I := 1 to FDimStyles.Count - 1 do
  begin
    LDimStyle := FDimStyles.Items[I];
    if not _IsDimStyleUsed(LDimStyle) then LDimStyle.Status := LDimStyle.Status or STATUS_USELESS;
  end;

end;



function TUdDocument.DoGetEntityClass(Sender: TUdObject; AEntityId: Integer): TUdEntityClass;
begin
  Result := nil;
  if Assigned(FOnGetEntityClass) then
    FOnGetEntityClass(Sender, AEntityId, Result);
end;

procedure TUdDocument.DoProgress(AProgress: Integer; const AProgressMax: Integer; AMsg: string = '');
begin
  if Assigned(FOnProgress) then FOnProgress(Self, AProgress, AProgressMax, AMsg);
end;


(*
procedure TUdDocument.UpdateColorsStatus();

  function _IsColorUsed(AColor: TUdColor): Boolean;
  var
    I, J: Integer;
    LLayout: TUdLayout;
  begin
    Result := False;
    for I := 0 to FLayouts.Count - 1 do
    begin
      LLayout := FLayouts.Items[I];
      for J := 0 to LLayout.Entities.Count - 1 do
      begin
        if LLayout.Entities.Items[J].Color = AColor then
        begin
          Result := True;
          Exit; //========>>>>>
        end;
      end;
    end;
  end;

var
  I: Integer;
  LColor: TUdColor;
begin
  for I := 0 to FColors.Count - 1 do
  begin
    LColor := FColors.Items[I];
    LColor.Status := 0;

    if FColors.Active = LColor then
      LColor.Status := STATUS_CURRENT;
  end;

  for I := 2 to FColors.Count - 1 do
  begin
    LColor := FColors.Items[I];
    if not _IsColorUsed(LColor) then LColor.Status := LColor.Status or STATUS_USELESS;
  end;

end;
*)




end.