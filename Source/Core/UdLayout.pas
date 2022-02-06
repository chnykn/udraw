{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLayout;

{$I UdDefs.INC}
{$DEFINE UD_TIMER}

interface

uses
  Windows, Classes, Contnrs, Controls, Graphics, StdCtrls, 
  UdTypes, UdGTypes, UdConsts, UdIntfs, UdObject, UdEvents, UdAxes, UdEntity,
  UdEntities, UdSelection, UdDrafting, UdViewPort, UdAction, UdDrawPanel,  UdPlotConfig
  {$IFDEF UD_TIMER}, UdTimer {$ELSE}, ExtCtrls {$ENDIF} ;

type
  TUdLayout = class;

  TUdLayoutEvent = procedure(Sender: TObject; Layout: TUdLayout) of object;
  TUdLayoutAllowEvent = procedure(Sender: TObject; Layout: TUdLayout; var Allow: Boolean) of object;



  //*** TUdLayout ***//
  TUdLayout = class(TUdObject, IUdObjectItem, IUdAxesSupport)
  private
    FName: string;
    FModelType: Boolean;
    FBackColor: TColor;

    FAxes: TUdAxes;
    FDrafting: TUdDrafting;
    FEntities: TUdEntities;
    FViewPort: TUdViewPort;

    FPlotConfig: TUdPlotConfig;
    FPaperLimMin: TPoint2D;
    FPaperLimMax: TPoint2D;


    FDrawPanel: TUdDrawPanel;

    //--------------------------------------

    FActions: TStack;
    FIdleAction: TUdAction;

    FUpdating: Boolean;
    FVisibleList: TList;
    FPartialList: TList;
    FSelection: TUdSelection;

    FCurrPoint: TPoint2D;
    FPrevPoint: PPoint2D;

    FPreviewing: Boolean;
    FTempPlotConfig: PUdPlotConfig;


    FEnableGrip: Boolean;
    FAutoRestOSnap: Boolean;

    FActionIdleClass: TUdActionClass;

    //--------------------------------------

    FAxesChangingTimer: {$IFDEF UD_TIMER} TUdTimer {$ELSE} TTimer {$ENDIF};

    FOnAddEntities: TUdEntitiesEvent;
    FOnRemoveEntities: TUdEntitiesEvent;
    FOnRemovedEntities: TNotifyEvent;

    FOnAddSelectedEntities: TUdEntitiesEvent;
    FOnRemoveSelectedEntities: TUdEntitiesEvent;
    FOnRemoveAllSelecteEntities: TNotifyEvent;


    FOnActionChanged: TNotifyEvent;

    FOnAxesChanging: TNotifyEvent;
    FOnAxesChanged : TNotifyEvent;



    procedure SetActionIdleClass(const Value: TUdActionClass);


  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function GetIdleAction(): TUdAction;
    function GetPrevAngle(): Float;

    function ZoomAllViewport(): Boolean;
    function InitViewport(): Boolean;

    procedure SetName(const AValue: string);
    procedure SetModelType(const AValue: Boolean);
    
    procedure SetPaperLimMax(const AValue: TPoint2D);
    procedure SetPaperLimMin(const AValue: TPoint2D);
    function GetPaperLimSize(const Index: Integer): Float;

    procedure SetPlotConfig(const AValue: TUdPlotConfig);

    function GetPlotWindow(): TRect2D;
    procedure SetPlotWindow(const AValue: TRect2D);

    procedure SetPreviewing(const AValue: Boolean);
    procedure SetDrawPanel(const AValue: TUdDrawPanel);

    function GetXCursorStyle: TUdCursorStyle;
    procedure SetXCursorStyle(const AValue: TUdCursorStyle);


    function GetViewBound(): TRect2D;
    function GetAxesBound(): TRect2D;
    function GetEntitiesBound(): TRect2D;

    function GetActiveAction: TUdAction;
    function GetUpdating: Boolean;
    function GetVisibleList: TList;
    function GetSelectedList: TList;

    function UpdateDrawPanelScroll(): Boolean;


    { Link Events... }
    procedure OnAxesChangingTimer(Sender: TObject);
    procedure OnAxesObjectChanging(Sender: TObject);
    procedure OnAxesObjectChanged(Sender: TObject);

    procedure OnEntitiesAddEntities(Sender: TObject; AEntities: TUdEntityArray);
    procedure OnEntitiesRemoveEntities(Sender: TObject; AEntities: TUdEntityArray);
    procedure OnEntitiesRemovedEntities(Sender: TObject);

    procedure OnSelectionAddEntities(Sender: TObject; AEntities: TUdEntityArray);
    procedure OnSelectionRemoveEntities(Sender: TObject; AEntities: TUdEntityArray);
    procedure OnSelectionRemoveAll(Sender: TObject);

    procedure OnViewPortBoundsChanged(Sender: TObject);
    procedure OnPlotPickWindow(Sender: TObject; ARect: TRect2D);

    procedure OnDraftingChanged(Sender: TObject; APropName: string);


    { IUdAxesSupport... }
    function GetAxes(): TObject;

    function GetCurrAxes(): TUdAxes;
    function GetEntities(): TUdEntities;
    function GetDrafting(): TUdDrafting;
    function GetViewPort(): TUdViewPort;
    function GetSelection(): TUdSelection;
    function GetViewPortActived(): Boolean;


    { IUdLayout... }
    function GetGridSpace(AIndex: Integer): Double;
    procedure SetGridSpace(AIndex: Integer; const AValue: Double);

    function GetSnapSpace(AIndex: Integer): Double;
    procedure SetSnapSpace(AIndex: Integer; const AValue: Double);

    function GetOSnapMode: Cardinal;
    procedure SetOSnapMode(const AValue: Cardinal);

    function GetDraftValue(AIndex: Integer): Boolean;
    procedure SetDraftValue(AIndex: Integer; const AValue: Boolean);

    procedure SetBackColor(const AValue: TColor);


    { Other... }
    function MousePoint2D(AAction: TUdAction; APoint: TPoint; AApplySnap: Boolean; out AOSnapKind: Integer): TPoint2D;


    property _Axes: TUdAxes read FAxes;

    property IdleAction: TUdAction read GetIdleAction;
    property PrevAngle: Float read GetPrevAngle;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure Clear();

    function GetGripPoints(APnt: TPoint2D; AMaxCount: Integer): TUdGripPointArray;
    function GetPartialEntities(APnt: TPoint2D; AEps: Float = 0.1): TList;

    function ReInitViewport(): Boolean;
    function UpdateVisibleList(): Boolean;
    function UpdateEntities(): Boolean;


    { IUdLayout... }
    procedure Paint(Sender: TObject; ACanvas: TCanvas; AFlag: Cardinal = 0);
    procedure PaintAction(Sender: TObject; ACanvas: TCanvas);

    procedure Scroll(Sender: TObject; AKind: Integer; AScrollCode: TScrollCode; AScrollPos: Integer);
    procedure DblClick( Sender: TObject; APoint: TPoint);
    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; var AKey: Word);
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState; var APoint: TPoint);
    procedure MouseWheel(Sender: TObject; AKeys: SmallInt; AWheelDelta: SmallInt; XPos, YPos: Smallint);

    procedure Resize(ANewWidth, ANewHeight: Integer);

    function Invalidate(): Boolean;
    function InvalidateRect(ARect: TRect; AErase: Boolean = False): Boolean; overload;
    function InvalidateRect(ARect: TRect2D; AErase: Boolean = False): Boolean; overload;

    { IUdZoom... }
    function Pan(DX, DY: Integer): Boolean;
    function ZoomIn(): Boolean;
    function ZoomOut(): Boolean;
    function ZoomAll(): Boolean;
    function ZoomExtends(): Boolean;
    function ZoomWindow(ARect: TRect2D; AExtends: Boolean): Boolean;
    function ZoomScale(const AValue: Double): Boolean;
    function ZoomPrevious(): Boolean;
    function ZoomCenter(ACen: TPoint2D): Boolean;


    { Selection... }
    function PickEntity(APoint: TPoint2D; AForce: Boolean = False): TUdEntity; overload;
    function PickEntity(ARect: TRect2D; ACrossingMode: Boolean; AForce: Boolean = False): TUdEntityArray; overload;

    function AddSelectedEntity(AEntity: TUdEntity): Boolean;
    function AddSelectedEntities(AEntities: TUdEntityArray): Boolean;

    function SelectEntity(APoint: TPoint2D): Boolean;
    function SelectEntities(ARect: TRect2D; ACrossingMode: Boolean): Boolean;

    function RemoveAllSelected(): Boolean;
    function RemoveSelectedEntity(AEntity: TUdEntity): Boolean;
    function RemoveSelectedEntities(AEntities: TUdEntityArray): Boolean;

    function EraseSelectedEntities(): Boolean;

    { Entities... }
    function AddEntity(AEntity: TUdEntity): Boolean;
    function AddEntities(AEntities: TUdEntityArray): Boolean;

    function InsertdEntity(AIndex: Integer; AEntity: TUdEntity): Boolean;

    function RemoveEntityAt(AIndex: Integer): Boolean;
    function RemoveEntity(AEntity: TUdEntity): Boolean;
    function RemoveEntities(AEntities: TUdEntityArray): Boolean;

    function IndexOfEntity(AEntity: TUdEntity): Integer;


    { Actions... }
    function ActionAdd(AClass: TUdActionClass; Args: string = ''): Boolean; overload;
    function ActionRemoveLast(): Boolean;
    function ActionClear(): Boolean;
    function ActionParse(AText: string): Boolean;

    function IsIdleAction(): Boolean;
    function IsGripAction(): Boolean;

    procedure SetPrevPoint(APnt: TPoint2D);
    procedure DeletePrevPoint();

    
    {Print}
    procedure ShowPlotForm();
    function Print(): Boolean;
    function ExportFile(AFileName: string; AFileFormat: TUdPlotImageFormat = pifBmp): Boolean;


    { Save&Load... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Axes: TUdAxes read GetCurrAxes;
    property Entities : TUdEntities  read GetEntities;
    property ViewPort : TUdViewPort  read GetViewPort;
    property Selection: TUdSelection read GetSelection;

    property ViewPortActived: Boolean read GetViewPortActived;

    property Updating: Boolean read GetUpdating;
    property VisibleList: TList read GetVisibleList;

    property CurrPoint: TPoint2D read FCurrPoint;
    property ViewBound: TRect2D  read GetViewBound;
    property AxesBound: TRect2D  read GetAxesBound;

    property SelectedList: TList read GetSelectedList;
    property ActiveAction: TUdAction read GetActiveAction;

    
    property DrawPanel: TUdDrawPanel read FDrawPanel write SetDrawPanel;
    property ModelType: Boolean      read FModelType write SetModelType;

    property PaperWidth : Float index 0 read GetPaperLimSize;
    property PaperHeight: Float index 1 read GetPaperLimSize;
        
    property PaperLimMin: TPoint2D read FPaperLimMin write SetPaperLimMin;
    property PaperLimMax: TPoint2D read FPaperLimMax write SetPaperLimMax;


    property PlotConfig : TUdPlotConfig read FPlotConfig   write SetPlotConfig;
    property PlotWindow : TRect2D       read GetPlotWindow write SetPlotWindow;
    property Previewing : Boolean       read FPreviewing   write SetPreviewing;

    property EnableGrip: Boolean read FEnableGrip write FEnableGrip;
    property AutoRestOSnap: Boolean read FAutoRestOSnap write FAutoRestOSnap;
    property ActionIdleClass: TUdActionClass read FActionIdleClass write SetActionIdleClass;


  public
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
    property Name: string read FName write SetName;

    property Drafting: TUdDrafting  read GetDrafting;
    
    property GridSpaceX: Double index 0 read GetGridSpace write SetGridSpace;
    property GridSpaceY: Double index 1 read GetGridSpace write SetGridSpace;

    property SnapSpaceX: Double index 0 read GetSnapSpace write SetSnapSpace;
    property SnapSpaceY: Double index 1 read GetSnapSpace write SetSnapSpace;
    property OSnapMode : Cardinal      read GetOSnapMode  write SetOSnapMode;

    property GridOn : Boolean index 0 read GetDraftValue  write SetDraftValue;
    property SnapOn : Boolean index 1 read GetDraftValue  write SetDraftValue;
    property OrthoOn: Boolean index 2 read GetDraftValue  write SetDraftValue;
    property PolarOn: Boolean index 3 read GetDraftValue  write SetDraftValue;
    property OSnapOn: Boolean index 4 read GetDraftValue  write SetDraftValue;
    property LwtDisp: Boolean index 5 read GetDraftValue  write SetDraftValue;


    property BackColor: TColor read FBackColor write SetBackColor;
    property XCursorStyle: TUdCursorStyle read GetXCursorStyle write SetXCursorStyle;

  end;

implementation

uses
  SysUtils,
  UdDocument, UdLayouts, UdBaseActions,  UdActionIdle, UdActionGrip, UdPlot,
  UdMath, UdGeo2D, UdUtils, UdStrConverter, UdStreams, UdXml, UdPrinters;


const
  AXES_CHANGING_DELAY = 12;


type
  TFStack = class(TStack);
  TFUdAxes = class(TUdAxes);
  TFUdAction = class(TUdAction);
  TFWinControl = class(TWinControl);

type
  TUdActionStack = class(TStack)
  protected
    procedure PushItem(AItem: Pointer); override;
    function PopItem: Pointer; override;
    function PeekItem: Pointer; override;
  end;

{ TUdActionStack }

function TUdActionStack.PeekItem: Pointer;
begin
  Result := nil;
  if Self.List.Count <= 0 then Exit; //===>>>

  Result := inherited PeekItem();
end;

function TUdActionStack.PopItem: Pointer;
begin
  Result := nil;
  if Self.List.Count <= 0 then Exit; //===>>>

  Result := inherited PopItem();
end;

procedure TUdActionStack.PushItem(AItem: Pointer);
begin
  if Self.List.IndexOf(AItem) < 0 then
    inherited;
end;






function FGetPaperSize(APlotConfig: TUdPlotConfig): TSize;
var
  N: Integer;
  LValid: Boolean;
  LPrinter: TUdCustomPrinter;
  LPaperWidth, LPaperHeight: Float;
begin
  N := UdPrinters.GlobalPrinters.IndexOf(APlotConfig.PrinterName);
  LPrinter := UdPrinters.GlobalPrinters.Items[N];
  if not Assigned(LPrinter) then
    LPrinter := UdPrinters.GlobalPrinters.Printer;

  if Assigned(LPrinter) then
  begin
    LPrinter.Init();
    LPrinter.SetViewParams(APlotConfig.PaperSize, 0, 0, TUdPrinterOrientation(APlotConfig.Orientation));

    Result.CX := Round(LPrinter.PaperWidth);
    Result.CY := Round(LPrinter.PaperHeight);
  end
  else begin
    LValid := UdPrinters.GetPaperDimensions(APlotConfig.PaperSize, LPaperWidth, LPaperHeight);

    if LValid then
    begin
      Result.CX := Round(LPaperWidth);
      Result.CY := Round(LPaperHeight);
    end
    else begin
      Result.CX := 297;
      Result.CY := 210;
//      APlotConfig.PaperSize := DMPAPER_A4;
    end;

    if APlotConfig.Orientation <> 0 then Swap(Result.CX, Result.CY);
  end;

end;


//================================================================================================
{ TUdLayout }

constructor TUdLayout.Create();
var
  LPaperSize: TSize;
begin
  inherited;

  FName := '';
  FModelType := True;

  FActions := TUdActionStack.Create;
  FActionIdleClass := TUdActionIdle;
  FIdleAction := nil; //TUdActionIdle.Create(ADocument);

//  FEntities := nil;

//  if Assigned(Self.Document) and Assigned(TUdDocument(Self.Document).ModelSpace) and (TUdDocument(Self.Document).ModelSpace <> Self) then
//  begin
//    FEntities := TUdDocument(Self.Document).ModelSpace.Entities;
//  end
//  else begin
    FEntities := TUdEntities.Create();
    FEntities.Owner := Self;

    FEntities.OnAddEntities := OnEntitiesAddEntities;
    FEntities.OnRemoveEntities := OnEntitiesRemoveEntities;
    FEntities.OnRemovedEntities := OnEntitiesRemovedEntities;
//  end;


  FEnableGrip := True;
  FAutoRestOSnap := True;

  FUpdating := False;
  FVisibleList := TList.Create();
  FPartialList := TList.Create();
  FSelection := TUdSelection.Create(Self);

  FSelection.OnAddEntities    := OnSelectionAddEntities;
  FSelection.OnRemoveEntities := OnSelectionRemoveEntities;
  FSelection.OnRemoveAll      := OnSelectionRemoveAll;


  FAxes := TUdAxes.Create();  // ADocument, False
  FAxes.Owner := Self;
  TFUdAxes(FAxes)._OnAxesChanging := OnAxesObjectChanging;
  TFUdAxes(FAxes)._OnAxesChanged  := OnAxesObjectChanged;

  FDrafting := TUdDrafting.Create();  // ADocument, False
  FDrafting.Owner := Self;
  FDrafting.OnChanged := OnDraftingChanged;

  FBackColor := clBlack;

  FViewPort := nil;
  FPrevPoint := nil;
  FPreviewing := False;
  FTempPlotConfig := nil;

  InitPlotConfig(FPlotConfig);

  LPaperSize   := FGetPaperSize(FPlotConfig);
  FPaperLimMin := Point2D(0.0, 0.0);
  FPaperLimMax := Point2D(LPaperSize.cx, LPaperSize.cy);
  FAxes.LimRect:= Rect2D(FPaperLimMin, FPaperLimMax);


  FAxesChangingTimer := {$IFDEF UD_TIMER} TUdTimer.Create() {$ELSE} TTimer.Create(nil) {$ENDIF};
  FAxesChangingTimer.Enabled  := False;
  FAxesChangingTimer.Interval := AXES_CHANGING_DELAY;
  FAxesChangingTimer.OnTimer  := OnAxesChangingTimer;
end;

destructor TUdLayout.Destroy;
var
  I: Integer;
  LObj: TObject;
begin

  if Assigned(FIdleAction) then FIdleAction.Free;
  FIdleAction := nil;

  if Assigned(FActions) then
  begin
    for I := FActions.Count - 1 downto 0 do
    begin
      LObj := FActions.Pop;
      if Assigned(LObj) then LObj.Free;
    end;
    FActions.Free;
  end;
  FActions := nil;

  if Assigned(Self.Document) then
  begin
    if (not FModelType) or (TUdDocument(Self.Document).ModelSpace = Self) then
    begin
      if Assigned(FEntities) then FEntities.Free;
    end;
  end
  else begin
    if Assigned(FEntities) then FEntities.Free;
  end;
  FEntities := nil;

  if Assigned(FViewPort) then FViewPort.Free;
  FViewPort := nil;


  if Assigned(FAxes) then FAxes.Free;
  FAxes := nil;

  if Assigned(FDrafting) then FDrafting.Free;
  FDrafting := nil;

  if Assigned(FSelection) then FSelection.Free;
  FSelection := nil;


  if Assigned(FPartialList) then FPartialList.Free;
  FPartialList := nil;

  if Assigned(FVisibleList) then FVisibleList.Free;
  FVisibleList := nil;

  if Assigned(FPrevPoint) then Dispose(FPrevPoint);
  FPrevPoint := nil;

  if Assigned(FTempPlotConfig) then Dispose(FTempPlotConfig);
  FTempPlotConfig := nil;

  if Assigned(FAxesChangingTimer) then
  begin
    FAxesChangingTimer.Enabled := False;
    FAxesChangingTimer.Free;
  end;
  FAxesChangingTimer := nil;

  inherited;
end;



//--------------------------------------------------------------------------------

function TUdLayout.GetTypeID: Integer;
begin
  Result := ID_LAYOUT;
end;


procedure TUdLayout.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

  if FModelType then
  begin
    if Assigned(Self.Document) and
       Assigned(TUdDocument(Self.Document).ModelSpace) and (TUdDocument(Self.Document).ModelSpace <> Self) then
    begin
      if Assigned(FEntities) then
      begin
        FEntities.Free;
        FEntities := nil;
      end;
      FEntities := TUdDocument(Self.Document).ModelSpace.Entities;
    end
    else
      FEntities.SetDocument(Self.Document, Self.IsDocRegister);
  end
  else begin
    FEntities.SetDocument(Self.Document, Self.IsDocRegister);
  end;

  FAxes.SetDocument(Self.Document, False);
  FDrafting.SetDocument(Self.Document, False);

  if Assigned(FViewPort) then
  begin
    FViewPort.SetDocument(Self.Document, Self.IsDocRegister);

    if Assigned(Self.Document) and Assigned(TUdDocument(Self.Document).ModelSpace) then
    begin
      Self.ReinitViewport();
      Self.AddDocObject(FViewPort, False);
    end;
  end;
end;




function TUdLayout.GetIdleAction: TUdAction;
begin
  Result := nil;
  if FPreviewing then Exit;

  if not Assigned(FIdleAction) then
    FIdleAction := FActionIdleClass.Create(Self.Document, Self);
  Result := FIdleAction;
end;


function TUdLayout.GetPrevAngle: Float;
var
  LAction: TUdAction;
begin
  Result := -1;
  LAction := Self.GetActiveAction();
  if Assigned(LAction) then Result := LAction.PrevAngle;
end;


procedure TUdLayout.SetName(const AValue: string);
begin
  if (FName <> AValue) and Self.RaiseBeforeModifyObject('Name' ) then
  begin
    FName := AValue;
    Self.RaiseAfterModifyObject('Name');
  end;
end;




function TUdLayout.ZoomAllViewport(): Boolean;
const
  VIEW_BOUND_MARGIN = 1;
var
  LBound: TRect2D;
  LFactor, LXFactor, LDelta: Float;
begin
  Result := False;
  if not Assigned(FViewPort) or not FViewPort.Inited or not Assigned(Self.Document) then Exit;

  if IsValidRect(FPlotConfig.PlotWindow) then
  begin
    LBound := FPlotConfig.PlotWindow;
  end
  else begin
    LBound := FViewPort.Entities.BoundsRect;// UdUtils.GetEntitiesBound(FViewPort.Entities.List);

    if (LBound.X2 > LBound.X1) or (LBound.Y2 > LBound.Y1) then
    begin
      LFactor := FViewPort.Height / FViewPort.Width;

      if IsEqual(LBound.X1, LBound.X2) then
      begin
        LDelta := (LBound.Y2 - LBound.Y1) / LFactor;
        LBound.X1 := LBound.X1 - LDelta / 2;
        LBound.X2 := LBound.X2 + LDelta / 2;
      end
      else if IsEqual(LBound.Y1, LBound.Y2) then
      begin
        LDelta := (LBound.X2 - LBound.X1) * LFactor;
        LBound.Y1 := LBound.Y1 - LDelta / 2;
        LBound.Y2 := LBound.Y2 + LDelta / 2;
      end
      else begin
        LXFactor := (LBound.Y2 - LBound.Y1) / (LBound.X2 - LBound.X1);

        if LXFactor > LFactor then
        begin
          LDelta :=  (LBound.Y2 - LBound.Y1) / LFactor - (LBound.X2 - LBound.X1);
          LBound.X1 := LBound.X1 - LDelta / 2;
          LBound.X2 := LBound.X2 + LDelta / 2;
        end
        else begin
          LDelta :=  (LBound.X2 - LBound.X1) * LFactor - (LBound.Y2 - LBound.Y1);
          LBound.Y1 := LBound.Y1 - LDelta / 2;
          LBound.Y2 := LBound.Y2 + LDelta / 2;
        end;
      end;
    end
    else begin
      LBound.X1 := 0;
      LBound.Y1 := 0;
      LBound.X2 := FViewPort.Width * 2;
      LBound.Y2 := FViewPort.Height * 2;
    end;
  end;

  LBound.X1 := LBound.X1 - VIEW_BOUND_MARGIN;
  LBound.X2 := LBound.X2 + VIEW_BOUND_MARGIN;
  LBound.Y1 := LBound.Y1 - VIEW_BOUND_MARGIN * (FViewPort.Height / FViewPort.Width);
  LBound.Y2 := LBound.Y2 + VIEW_BOUND_MARGIN * (FViewPort.Height / FViewPort.Width);

  FViewPort.UpdateAxes(LBound);
  FViewPort.UpdateVisibleList();
  Self.Invalidate();

  Result := True;
end;

function TUdLayout.InitViewport(): Boolean;
const
  VIEW_PORT_MARGIN = 20{mm};
var
  LPapFactor, LWinFactor: Float;
  LWinWidth, LWinHeight: Float;
  LPaperWidth, LPaperHeight: Float;
  LPaperWidth2, LPaperHeight2: Float;
begin
  Result := False;
  if not Assigned(FViewPort) or not Assigned(Self.Document) then Exit;

  LPaperWidth  := Self.PaperWidth;
  LPaperHeight := Self.PaperHeight;
  
  LPaperWidth2  := LPaperWidth  - 2 * VIEW_PORT_MARGIN;
  LPaperHeight2 := LPaperHeight - 2 * VIEW_PORT_MARGIN * (LPaperHeight / LPaperWidth);

  if IsValidRect(FPlotConfig.PlotWindow) then
  begin
    LWinWidth  := Abs(FPlotConfig.PlotWindow.X2 - FPlotConfig.PlotWindow.X1);
    LWinHeight := Abs(FPlotConfig.PlotWindow.Y2 - FPlotConfig.PlotWindow.Y1);

    if IsEqual(LWinWidth, 0) then
    begin
      LPaperWidth2  := 0;
      LPaperHeight2 := LPaperHeight - 2 * VIEW_PORT_MARGIN;
    end
    else if IsEqual(LWinHeight, 0) then
    begin
      LPaperWidth2  := LPaperWidth  - 2 * VIEW_PORT_MARGIN;
      LPaperHeight2 := 0;
    end
    else begin
      LWinFactor := LWinHeight / LWinWidth;
      LPapFactor := LPaperHeight2 / LPaperWidth2;

      if LWinFactor > LPapFactor then
      begin
        LPaperHeight2 := LPaperHeight - 2 * VIEW_PORT_MARGIN;
        LPaperWidth2  := LPaperHeight2 / LWinFactor;
      end
      else begin
        LPaperWidth2  := LPaperWidth - 2 * VIEW_PORT_MARGIN;
        LPaperHeight2 := LPaperWidth2 * LWinFactor;
      end;
    end;
  end;

  FViewPort.InitSize(MidPoint(FPaperLimMax, FPaperLimMin), LPaperWidth2, LPaperHeight2);

  Result := ZoomAllViewport();
  Self.ZoomAll();
end;

function TUdLayout.ReInitViewport(): Boolean;
var
  LPaperSize: TSize;
begin
  Result := False;
  if not Assigned(FViewPort) then Exit;

  {
  if not Assigned(FViewPort.Entities) and
     Assigned(Self.Document) and Assigned(TUdDocument(Self.Document).ModelSpace) then
    FViewPort.Entities := TUdDocument(Self.Document).ModelSpace.Entities;
  }
  
  LPaperSize   := FGetPaperSize(FPlotConfig);
  FPaperLimMax := Point2D(FPaperLimMin.X + LPaperSize.cx, FPaperLimMin.Y + LPaperSize.cy);

  FAxes.LimRect:= Rect2D(FPaperLimMin, FPaperLimMax);

  Result := Self.InitViewport();
end;


procedure TUdLayout.SetPaperLimMin(const AValue: TPoint2D);
begin
  FPaperLimMin := AValue;
  FAxes.LimRect:= Rect2D(FPaperLimMin, FPaperLimMax);
end;

procedure TUdLayout.SetPaperLimMax(const AValue: TPoint2D);
begin
  FPaperLimMax := AValue;
  FAxes.LimRect:= Rect2D(FPaperLimMin, FPaperLimMax);
end;

function TUdLayout.GetPaperLimSize(const Index: Integer): Float;
begin
  Result := 0;
  case Index of
    0: Result := Abs(FPaperLimMax.X - FPaperLimMin.X);
    1: Result := Abs(FPaperLimMax.Y - FPaperLimMin.Y);
  end;
end;


procedure TUdLayout.SetPlotConfig(const AValue: TUdPlotConfig);
var
  LPaperSize: TSize;
begin
  FPlotConfig := AValue;
  LPaperSize  := FGetPaperSize(FPlotConfig);

  if Assigned(FViewPort) and
    (NotEqual(Self.PaperWidth, LPaperSize.cx) or NotEqual(Self.PaperHeight, LPaperSize.cy)) then
  begin
    FPaperLimMax := Point2D(FPaperLimMin.X + LPaperSize.cx, FPaperLimMin.Y + LPaperSize.cy);
    FAxes.LimRect:= Rect2D(FPaperLimMin, FPaperLimMax);

    {
    if not Assigned(FViewPort.Entities) and
       Assigned(Self.Document) and Assigned(TUdDocument(Self.Document).ModelSpace) then
      FViewPort.Entities := TUdDocument(Self.Document).ModelSpace.Entities;
    }
      
    Self.InitViewPort();
  end
  else
    Self.Invalidate();
end;

procedure TUdLayout.SetModelType(const AValue: Boolean);
var
  LDoc: TUdDocument;
  LPaperSize: TSize;
begin
  if (FModelType = AValue) then Exit;
  if Assigned(Self.Document) and (TUdDocument(Self.Document).ModelSpace = Self) then Exit;


//  if (FModelType <> AValue) and Assigned(Self.Document) and (TUdDocument(Self.Document).ModelSpace <> Self) then
//  begin

  LDoc := TUdDocument(Self.Document);
  FModelType := AValue;

  if not FModelType then
  begin
    if not Assigned(FEntities) or
      (Assigned(LDoc) and Assigned(LDoc.ModelSpace) and (LDoc.ModelSpace.Entities = FEntities)) then
    begin
      FEntities := TUdEntities.Create(Self.Document, Self.IsDocRegister);
      FEntities.Owner := Self;

      FEntities.OnAddEntities := OnEntitiesAddEntities;
      FEntities.OnRemoveEntities := OnEntitiesRemoveEntities;
      FEntities.OnRemovedEntities := OnEntitiesRemovedEntities;
      if Assigned(LDoc) then Self.AddDocObject(FEntities, False);
    end;

    FViewPort := TUdViewPort.Create(LDoc, True);
    FViewPort.Owner := Self;
    FViewPort.OnAxesChanging := OnAxesObjectChanging;
    FViewPort.OnBoundsChanged := OnViewPortBoundsChanged;
      
    if Assigned(LDoc) and Assigned(LDoc.ModelSpace) then
    begin
      //FViewPort.Entities := TUdDocument(Self.Document).ModelSpace.Entities;
      Self.ReinitViewport();
      Self.AddDocObject(FViewPort, False);
    end;

    FBackColor := clAppWorkSpace;
  end
  else begin
    //if Assigned(FEntities) then
    //  Self.RemoveDocObject(FEntities, False);

    if Assigned(LDoc) then
      FEntities := LDoc.ModelSpace.Entities
    else
      FEntities := nil;

    Self.RemoveDocObject(FViewPort, False);
//    FViewPort.Free;
    FViewPort := nil;

    InitPlotConfig(FPlotConfig);

    LPaperSize   := FGetPaperSize(FPlotConfig);
    FPaperLimMin := Point2D(0.0, 0.0);
    FPaperLimMax := Point2D(LPaperSize.cx, LPaperSize.cy);
    FAxes.LimRect:= Rect2D(FPaperLimMin, FPaperLimMax);

    FBackColor := clBlack;
  end;

//  end;
end;


function TUdLayout.GetPlotWindow(): TRect2D;
begin
  Result := FPlotConfig.PlotWindow;
end;

procedure TUdLayout.SetPlotWindow(const AValue: TRect2D);
begin
  FPlotConfig.PlotWindow := AValue;
  Self.ReInitViewport();
end;


procedure TUdLayout.SetPreviewing(const AValue: Boolean);
begin
  if FPreviewing <> AValue then
  begin
    FPreviewing := AValue;

  end;
end;





procedure TUdLayout.SetDrawPanel(const AValue: TUdDrawPanel);
begin
  FDrawPanel := AValue;

  if Assigned(FDrawPanel) then
  begin
    FDrawPanel.Color := FBackColor;

    if FDrawPanel.ScrollBars = ssNone then
      FAxes.Margin := 0
    else
      FAxes.Margin := FDrawPanel.ScrollSize;

    Self.Resize(FDrawPanel.Width, FDrawPanel.Height);
    Self.UpdateDrawPanelScroll();
  end;
end;


function TUdLayout.GetXCursorStyle: TUdCursorStyle;
begin
  Result := csIdle;
  if Assigned(Self.DrawPanel) then
    Result := Self.DrawPanel.XCursor.Style;
end;

procedure TUdLayout.SetXCursorStyle(const AValue: TUdCursorStyle);
begin
  if Assigned(Self.DrawPanel) then
    Self.DrawPanel.XCursor.Style := AValue;
end;


procedure TUdLayout.CopyFrom(AValue: TUdObject);
begin
  inherited;
  if not AValue.InheritsFrom(TUdLayout) then Exit; //===>>>

//  if (FModelType <> TUdLayout(AValue).ModelType) then Exit; //===>>>

  Self.SetModelType(TUdLayout(AValue).ModelType);

  FName       := TUdLayout(AValue).FName;
  FModelType  := TUdLayout(AValue).FModelType;
  FBackColor  := TUdLayout(AValue).FBackColor;

  FPlotConfig  := TUdLayout(AValue).FPlotConfig;
  FPaperLimMin := TUdLayout(AValue).FPaperLimMin;
  FPaperLimMax := TUdLayout(AValue).FPaperLimMax;

  FAxes.Assign( TUdLayout(AValue).FAxes );
  FDrafting.Assign( TUdLayout(AValue).FDrafting );

  if (not FModelType) then
  begin
    FEntities.Assign(TUdLayout(AValue).FEntities);
    FViewPort.Assign(TUdLayout(AValue).FViewPort);
  end;
end;


procedure TUdLayout.Clear();
var
  LPaperSize: TSize;
begin
  FVisibleList.Clear();
  FSelection.List.Clear();

  if (not FModelType) or
     (Assigned(Self.Document) and (TUdDocument(Self.Document).ModelSpace = Self)) then
    FEntities.Clear();

  InitPlotConfig(FPlotConfig);

  LPaperSize   := FGetPaperSize(FPlotConfig);
  FPaperLimMin := Point2D(0.0, 0.0);
  FPaperLimMax := Point2D(LPaperSize.cx, LPaperSize.cy);
  FAxes.LimRect:= Rect2D(FPaperLimMin, FPaperLimMax);
      
  if Assigned(FViewPort) then
  begin
    FViewPort.InitSize(Point2D(0.0, 0.0), 0.0, 0.0);
    FViewPort.Actived := False;
    FViewPort.VisibleList.Clear();
  end;

  Self.ZoomAll();
end;



//----------------------------------------------------------------------------------

function TUdLayout.GetViewBound: TRect2D;
begin
  InitRect(Result);
  if Assigned(Self.DrawPanel) then
  begin
    Result.X1 := FAxes.XValue(0);
    Result.X2 := FAxes.XValue(Self.DrawPanel.Width);

    Result.Y1 := FAxes.YValue(Self.DrawPanel.Height);
    Result.Y2 := FAxes.YValue(0);
  end
  else
    Result := Rect2D(FAxes.XMin, FAxes.YMin, FAxes.XMax, FAxes.YMax);
end;

function TUdLayout.GetAxesBound(): TRect2D;
begin
  with Self.Axes do
  begin
    Result.X1 := XMin;
    Result.X2 := XMax;
    Result.Y1 := YMin;
    Result.Y2 := YMax;
  end;
end;

function TUdLayout.GetEntitiesBound(): TRect2D;
begin
  Result := FEntities.BoundsRect;
  if Assigned(FViewPort) and FViewPort.Inited then
  begin
    Result := UdGeo2D.MergeRect(Result, FViewPort.BoundsRect);
    if FPreviewing then
      Result := UdGeo2D.MergeRect(Result, Rect2D(FPaperLimMin, FPaperLimMax));
  end;
end;



function TUdLayout.GetUpdating: Boolean;
begin
  Result := FUpdating;
  if Self.ViewPortActived then
    Result := FViewPort.Updating;
end;


function TUdLayout.GetVisibleList: TList;
begin
  Result := FVisibleList;
  if Self.ViewPortActived then
    Result := FViewPort.VisibleList;
end;

function TUdLayout.GetSelectedList: TList;
begin
  Result := FSelection.List;
end;



function TUdLayout.UpdateVisibleList(): Boolean;
var
  I: Integer;
  LEntity: TUdEntity;
  LViewBound: TRect2D;
begin
  FUpdating := True;
  try
    LViewBound := Self.GetViewBound();
    FVisibleList.Clear();

    for I := 0 to FEntities.Count - 1 do
    begin
      LEntity := FEntities.Items[I];
      if not Assigned(LEntity) or not LEntity.IsVisible() then Continue;

      if UdGeo2D.IsIntersect(LEntity.BoundsRect, LViewBound) then
        FVisibleList.Add(LEntity)
    end;

    if Assigned(FViewPort) and FViewPort.Inited then
      FViewPort.UpdateVisibleList();
  finally
    FUpdating := False;
  end;

  Result := True;
end;

function TUdLayout.UpdateDrawPanelScroll(): Boolean;
var
  LPan: TPoint2D;
  LBound: TRect2D;
begin
  Result := False;
  if not Assigned(Self.DrawPanel) then Exit;

  LBound := Self.GetAxesBound();

  // Is such "FAxes", because DrawPanel's scrollbar only for Layout, not for FViewPort
  with FAxes do
  begin
    LPan.X := XPan * XValuePerPixel;
    LPan.Y := YPan * YValuePerPixel;

    Self.DrawPanel.UpdateScroll(LBound, LPan, Scale);
  end;

  Self.DrawPanel.Invalidate;
  Result := True;
end;

function TUdLayout.UpdateEntities(): Boolean;
begin
  Result := True;
  if (not FModelType) or
     (Assigned(Self.Document) and (TUdDocument(Self.Document).ModelSpace = Self)) then
  begin
    FEntities.Update();
    Result := True;
  end;
end;



//----------------------------------------------------------------------------------

procedure TUdLayout.OnAxesChangingTimer(Sender: TObject);
begin
  FAxesChangingTimer.Enabled := False;

  if Assigned(FViewPort) and FViewPort.Inited then FViewPort.UpdateAxes();
  Self.UpdateVisibleList();

  if Assigned(FOnAxesChanging) then FOnAxesChanging(Self);
  Self.Invalidate();
end;

procedure TUdLayout.OnAxesObjectChanging(Sender: TObject);
begin
  FDrafting.Reset();
  
  FAxesChangingTimer.Enabled := False;
  FAxesChangingTimer.Enabled := True;

//  Self.UpdateVisibleList();
//
//  if Assigned(FOnAxesChanging) then FOnAxesChanging(Self);
//  Self.Invalidate();
end;

procedure TUdLayout.OnAxesObjectChanged(Sender: TObject);
begin
  UpdateDrawPanelScroll();
  if Assigned(FOnAxesChanged) then FOnAxesChanged(Self);
end;


procedure TUdLayout.OnEntitiesAddEntities(Sender: TObject; AEntities: TUdEntityArray);
var
  I: Integer;
  LVisibleList: TList;
begin
  if Self.ViewPortActived then
    LVisibleList := FViewPort.VisibleList
  else begin
    if Assigned(Self.Document) and (Self = TUdDocument(Self.Document).ModelSpace) then
    begin
      if (TUdDocument(Self.Document).ActiveLayout <> Self) or (TUdDocument(Self.Document).ActiveLayout.ViewPortActived) then
        LVisibleList := TUdDocument(Self.Document).ActiveLayout.ViewPort.VisibleList
      else
        LVisibleList := FVisibleList;
    end
    else
      LVisibleList := FVisibleList;
  end;

  for I := 0 to System.Length(AEntities) - 1 do
    LVisibleList.Add(AEntities[I]);

  if Assigned(FOnAddEntities) then FOnAddEntities(Sender, AEntities);
end;

procedure TUdLayout.OnEntitiesRemoveEntities(Sender: TObject; AEntities: TUdEntityArray);
var
  I: Integer;
  LVisibleList: TList;
begin
  if Self.ViewPortActived then
    LVisibleList := FViewPort.VisibleList
  else begin
    if Assigned(Self.Document) and (Self = TUdDocument(Self.Document).ModelSpace) then
    begin
      if (TUdDocument(Self.Document).ActiveLayout <> Self) or (TUdDocument(Self.Document).ActiveLayout.ViewPortActived) then
        LVisibleList := TUdDocument(Self.Document).ActiveLayout.ViewPort.VisibleList
      else
        LVisibleList := FVisibleList;
    end
    else
      LVisibleList := FVisibleList;
  end;

  for I := 0 to System.Length(AEntities) - 1 do
    LVisibleList.Remove(AEntities[I]);

  FSelection.RemoveEntities(AEntities);

  if Assigned(FOnRemoveEntities) then FOnRemoveEntities(Sender, AEntities);
end;

procedure TUdLayout.OnEntitiesRemovedEntities(Sender: TObject);
begin
  if Assigned(FOnRemovedEntities) then FOnRemovedEntities(Sender);
end;


procedure TUdLayout.OnSelectionAddEntities(Sender: TObject; AEntities: TUdEntityArray);
begin
  if Assigned(FOnAddSelectedEntities) then FOnAddSelectedEntities(Sender, AEntities);
end;

procedure TUdLayout.OnSelectionRemoveEntities(Sender: TObject; AEntities: TUdEntityArray);
begin
  if Assigned(FOnRemoveSelectedEntities) then FOnRemoveSelectedEntities(Sender, AEntities);
end;

procedure TUdLayout.OnSelectionRemoveAll(Sender: TObject);
begin
  if Assigned(FOnRemoveAllSelecteEntities) then FOnRemoveAllSelecteEntities(Sender);
end;

procedure TUdLayout.OnViewPortBoundsChanged(Sender: TObject);
var
  LCenter: TPoint2D;
  LWidth, LHeight: Float;
  LAxesBound: TRect2D;
  LX1, LY1, LX2, LY2: Float;
begin
  LCenter := FViewPort.BoundsShape.Center;
  LWidth  := FViewPort.BoundsShape.Width;
  LHeight := FViewPort.BoundsShape.Height;

  LX1 := FAxes.XPixelF(LCenter.X - LWidth/2 );
  LX2 := FAxes.XPixelF(LCenter.X + LWidth/2 );
  LY1 := FAxes.YPixelF(LCenter.Y - LHeight/2);
  LY2 := FAxes.YPixelF(LCenter.Y + LHeight/2);

  LAxesBound.X1 := FViewPort.Axes.XValue(LX1);
  LAxesBound.X2 := FViewPort.Axes.XValue(LX2);
  LAxesBound.Y1 := FViewPort.Axes.YValue(LY1);
  LAxesBound.Y2 := FViewPort.Axes.YValue(LY2);

  Self.ViewPort.UpdateAxes(LAxesBound);
  Self.ViewPort.UpdateVisibleList();

  Self.Invalidate();
end;




procedure TUdLayout.OnDraftingChanged(Sender: TObject; APropName: string);
begin

end;


//----------------------------------------------------------------------------------

function TUdLayout.GetAxes(): TObject;
begin
  Result := Self.GetCurrAxes();
end;

function TUdLayout.GetCurrAxes(): TUdAxes;
begin
  if Self.ViewPortActived then
    Result := FViewPort.Axes
  else begin
    if Assigned(Self.Document) and (Self = TUdDocument(Self.Document).ModelSpace) and
      (TUdDocument(Self.Document).ActiveLayout.ViewPortActived) then
      Result := TUdDocument(Self.Document).ActiveLayout.ViewPort.Axes
    else
      Result := Self.FAxes;
  end;
end;


function TUdLayout.GetEntities(): TUdEntities;
begin
  Result := nil;
  if Self.ViewPortActived then
  begin
    if Assigned(Self.Document) then
      Result := TUdDocument(Self.Document).ModelSpace.Entities;
  end
  else
    Result := FEntities;
end;

function TUdLayout.GetDrafting(): TUdDrafting;
begin
  Result := FDrafting;
end;

function TUdLayout.GetViewPort(): TUdViewPort;
begin
  Result := FViewPort;
end;

function TUdLayout.GetSelection(): TUdSelection;
begin
  Result := FSelection;
end;

function TUdLayout.GetViewPortActived(): Boolean;
begin
  Result := Assigned(FViewPort) and FViewPort.Actived;
end;




//----------------------------------------------------------------------------------
{ IUdLayout... }

function TUdLayout.GetGridSpace(AIndex: Integer): Double;
begin
  Result := -1;
  case AIndex of
    0: Result := FDrafting.SnapGrid.GridSpace.X;
    1: Result := FDrafting.SnapGrid.GridSpace.Y;
  end;
end;

procedure TUdLayout.SetGridSpace(AIndex: Integer; const AValue: Double);
var
  LSpace: TPoint2D;
begin
  if AValue <= 0 then Exit;

  LSpace := FDrafting.SnapGrid.GridSpace;

  case AIndex of
    0:
    if NotEqual(LSpace.X, AValue) and Self.RaiseBeforeModifyObject('GridSpaceX') then
    begin
      LSpace.X := AValue;
      FDrafting.SnapGrid.GridSpace := LSpace;
      Self.RaiseAfterModifyObject('GridSpaceX');
    end;

    1:
    if NotEqual(LSpace.Y, AValue) and Self.RaiseBeforeModifyObject('GridSpaceY') then
    begin
      LSpace.Y := AValue;
      FDrafting.SnapGrid.GridSpace := LSpace;
      Self.RaiseAfterModifyObject('GridSpaceY');
    end;
  end;
end;



function TUdLayout.GetSnapSpace(AIndex: Integer): Double;
begin
  Result := -1;
  case AIndex of
    0: Result := FDrafting.SnapGrid.SnapSpace.X;
    1: Result := FDrafting.SnapGrid.SnapSpace.Y;
  end;
end;

procedure TUdLayout.SetSnapSpace(AIndex: Integer; const AValue: Double);  //GridSpaceX
var
  LSpace: TPoint2D;
begin
  if AValue <= 0 then Exit;

  LSpace := FDrafting.SnapGrid.SnapSpace;

  case AIndex of
    0:
    if NotEqual(LSpace.X, AValue) and Self.RaiseBeforeModifyObject('SnapSpaceX') then
    begin
      LSpace.X := AValue;
      FDrafting.SnapGrid.SnapSpace := LSpace;
      Self.RaiseAfterModifyObject('SnapSpaceX');
    end;

    1:
    if NotEqual(LSpace.Y, AValue) and Self.RaiseBeforeModifyObject('SnapSpaceY') then
    begin
      LSpace.Y := AValue;
      FDrafting.SnapGrid.SnapSpace := LSpace;
      Self.RaiseAfterModifyObject('SnapSpaceY');
    end;
  end;
end;



function TUdLayout.GetOSnapMode: Cardinal;
begin
  Result := FDrafting.ObjectSnap.CurrMode;
end;

procedure TUdLayout.SetOSnapMode(const AValue: Cardinal);
begin
  FDrafting.ObjectSnap.CurrMode := AValue;
end;


function TUdLayout.GetDraftValue(AIndex: Integer): Boolean;
begin
  Result := False;
  case AIndex of
    0: Result := FDrafting.GridOn ;
    1: Result := FDrafting.SnapOn;
    2: Result := FDrafting.OrthoOn;
    3: Result := FDrafting.PolarOn;
    4: Result := FDrafting.OSnapOn;
    5: Result := FDrafting.LwtDisp;
  end;
end;


procedure TUdLayout.SetDraftValue(AIndex: Integer; const AValue: Boolean);
begin
  case AIndex of
    0:
      if (GetDraftValue(AIndex) <> AValue) and Self.RaiseBeforeModifyObject('GridOn') then
      begin
        FDrafting.GridOn := AValue;
        Self.RaiseAfterModifyObject('GridOn');
      end;
    1:
      if (GetDraftValue(AIndex) <> AValue) and Self.RaiseBeforeModifyObject('SnapOn') then
      begin
        FDrafting.SnapOn := AValue;
        Self.RaiseAfterModifyObject('SnapOn');
      end;
    2:
      if (GetDraftValue(AIndex) <> AValue) and Self.RaiseBeforeModifyObject('OrthoOn') then
      begin
        FDrafting.OrthoOn := AValue;
        Self.RaiseAfterModifyObject('OrthoOn');
      end;
    3:
      if (GetDraftValue(AIndex) <> AValue) and Self.RaiseBeforeModifyObject('PolarOn') then
      begin
        FDrafting.PolarOn := AValue;
        Self.RaiseAfterModifyObject('PolarOn');
      end;
    4:
      if (GetDraftValue(AIndex) <> AValue) and Self.RaiseBeforeModifyObject('OSnapOn') then
      begin
        FDrafting.OSnapOn := AValue;
        Self.RaiseAfterModifyObject('OSnapOn');
      end;
    5:
      if (GetDraftValue(AIndex) <> AValue) and Self.RaiseBeforeModifyObject('LwtDisp') then
      begin
        FDrafting.LwtDisp := AValue;
        Self.RaiseAfterModifyObject('LwtDisp');
      end;
  end;
  Self.Invalidate;
end;


procedure TUdLayout.SetActionIdleClass(const Value: TUdActionClass);
begin
  if (Value <> nil) and (FActionIdleClass <> Value) then
  begin
    FActionIdleClass := Value;
    if Assigned(FIdleAction) then FIdleAction.Free;
    FIdleAction := FActionIdleClass.Create(Self.Document, Self);
  end;
end;

procedure TUdLayout.SetBackColor(const AValue: TColor);
begin
  FBackColor := AValue;
  if Assigned(FDrawPanel) then FDrawPanel.Color := FBackColor;
end;



//----------------------------------------------------------------------------------
{ IUdLayout... }

function TUdLayout.GetGripPoints(APnt: TPoint2D; AMaxCount: Integer): TUdGripPointArray;
var
  E: Float;
  I, J, N: Integer;
  LEntity: TUdEntity;
  LEntityList: TList;
  LGripPoints: TUdGripPointArray;
begin
  Result := nil;
  if (AMaxCount <= 0) or (FSelection.List.Count <= 0) or not FSelection.ShowGrips then Exit;

  LEntityList := FSelection.List;

  if not Assigned(LEntityList) or (LEntityList.Count <= 0) then Exit; //=======>>>

  E := DEFAULT_PICK_SIZE / Self.Axes.XPixelPerValue;

  N := 0;
  System.SetLength(Result, AMaxCount);

  for I := 0 to LEntityList.Count - 1 do
  begin
    LEntity := TUdEntity(LEntityList[I]);
    if not Assigned(LEntity) or (not LEntity.Selected) then Continue;

    LGripPoints := LEntity.GetGripPoints();
    for J := 0 to System.Length(LGripPoints) - 1 do
    begin
      if (N = 0) then
      begin
        if IsEqual(LGripPoints[J].Point, APnt, E) then
        begin
          Result[0] := LGripPoints[J];
          N := 1;
        end;
      end
      else begin
        if IsEqual(LGripPoints[J].Point, Result[0].Point, 1E-3) then
        begin
          Result[N] := LGripPoints[J];
          N := N + 1;
        end;
      end;

      if N = AMaxCount then Break;
    end;

    if N = AMaxCount then Break;
  end;

  if N <> AMaxCount then System.SetLength(Result, N);
end;


function TUdLayout.GetPartialEntities(APnt: TPoint2D; AEps: Float = 0.1): TList;
var
  I: Integer;
  LEps: Float;
  LEntity: TUdEntity;
  LVisibleList: TList;
begin
  FPartialList.Clear;

  LEps := Abs(AEps);

  LVisibleList := Self.GetVisibleList();

  if Assigned(LVisibleList) then
  for I := 0 to LVisibleList.Count - 1 do
  begin
    LEntity := TUdEntity(LVisibleList[I]);
    if Assigned(LEntity) and IsPntInRect(APnt, LEntity.BoundsRect, LEps)  then
      FPartialList.Add(LEntity);
  end;

  if Assigned(FViewPort) and FViewPort.Inited and FViewPort.Visible and not FViewPort.Actived then
    if IsPntInRect(APnt, FViewPort.BoundsShape.BoundsRect, LEps) then
      FPartialList.Add(FViewPort.BoundsShape);

  Result := FPartialList;
end;




//----------------------------------------------------------------------------------------------


procedure TUdLayout.Paint(Sender: TObject; ACanvas: TCanvas; AFlag: Cardinal = 0);

  function _Rect2D(X1, Y1, X2, Y2: Float): TRect2D;  {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
  begin
    Result.P1.X := X1;
    Result.P2.X := X2;
    Result.P1.Y := Y1;
    Result.P2.Y := Y2;
  end;

  procedure _DrawPaperBackground();
  var
    LRect: TRect;
  begin
    ACanvas.Pen.Style := psClear;
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := clWhite;

    LRect := Rect(FAxes.XPixel(FPaperLimMin.X), FAxes.YPixel(FPaperLimMax.Y),
                  FAxes.XPixel(FPaperLimMax.X), FAxes.YPixel(FPaperLimMin.Y));
    ACanvas.FillRect(LRect);
  end;

  procedure _DrawPaperCliping(AInRect, AOutRect: TRect2D; AColor: TColor);
  var
    LBottomRect, LTopRect: TRect2D;
    LLeftRect, LRightRect: TRect2D;
  begin
    LBottomRect := _Rect2D(AOutRect.X1, AOutRect.Y1, AOutRect.X2, AInRect.Y1);
    LTopRect    := _Rect2D(AOutRect.X1, AInRect.Y2, AOutRect.X2, AOutRect.Y2);

    LLeftRect   := _Rect2D(AOutRect.X1, AInRect.Y1, AInRect.X1, AInRect.Y2);
    LRightRect  := _Rect2D(AInRect.X2, AInRect.Y1, AOutRect.X2, AInRect.Y2);

    ACanvas.Pen.Style   := psClear;
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := AColor;

    if IsValidRect(LBottomRect) then
      ACanvas.FillRect(Rect(FAxes.XPixel(LBottomRect.X1), FAxes.YPixel(LBottomRect.Y2),
                            FAxes.XPixel(LBottomRect.X2), FAxes.YPixel(LBottomRect.Y1)));

    if IsValidRect(LTopRect) then
      ACanvas.FillRect(Rect(FAxes.XPixel(LTopRect.X1), FAxes.YPixel(LTopRect.Y2),
                            FAxes.XPixel(LTopRect.X2), FAxes.YPixel(LTopRect.Y1)));

    if IsValidRect(LLeftRect) then
      ACanvas.FillRect(Rect(FAxes.XPixel(LLeftRect.X1), FAxes.YPixel(LLeftRect.Y2),
                            FAxes.XPixel(LLeftRect.X2), FAxes.YPixel(LLeftRect.Y1)));

    if IsValidRect(LRightRect) then
      ACanvas.FillRect(Rect(FAxes.XPixel(LRightRect.X1), FAxes.YPixel(LRightRect.Y2),
                            FAxes.XPixel(LRightRect.X2), FAxes.YPixel(LRightRect.Y1)));
  end;

  procedure _DrawPaperCover();
  var
    LRect: TRect;
    LBound1, LBound2: TRect2D;
  begin
    LBound1 := FViewPort.BoundsRect;
    LBound2 := Rect2D(FPaperLimMin, FPaperLimMax);

    _DrawPaperCliping(LBound1, LBound2, clWhite);
    _DrawPaperCliping(LBound2, Self.GetViewBound(), FBackColor);


    //Border
    ACanvas.Pen.Style := psSolid;
    ACanvas.Pen.Color := clBlack;
    ACanvas.Pen.Width := 1;
    ACanvas.Brush.Style := bsClear;

    LRect := Rect(FAxes.XPixel(FPaperLimMin.X), FAxes.YPixel(FPaperLimMax.Y),
                  FAxes.XPixel(FPaperLimMax.X), FAxes.YPixel(FPaperLimMin.Y));
    ACanvas.Rectangle(LRect);


    //Border Shadow
    ACanvas.Pen.Style := psClear;
    ACanvas.Brush.Color := cl3DDkShadow;
    ACanvas.Brush.Style := bsSolid;

    LRect := Rect(FAxes.XPixel(FPaperLimMin.X)+5, FAxes.YPixel(FPaperLimMin.Y),
                  FAxes.XPixel(FPaperLimMax.X)+5, FAxes.YPixel(FPaperLimMin.Y) + 5);
    ACanvas.Rectangle(LRect);


    LRect := Rect(FAxes.XPixel(FPaperLimMax.X), FAxes.YPixel(FPaperLimMax.Y)+5,
                  FAxes.XPixel(FPaperLimMax.X)+5, FAxes.YPixel(FPaperLimMin.Y)+5);                   
    ACanvas.Rectangle(LRect);
  end;



var
  I: Integer;
  LUsrClip: Boolean;
  LLwFactor: Float;
  LEntity: TUdEntity;
  LSelectedList: TList;
begin
  LUsrClip := (not FModelType) and Assigned(FViewPort) and ((AFlag and PRINT_PAINT = 0) or FPreviewing);

  if LUsrClip then
    _DrawPaperBackground();

  if not FModelType then
    LLwFactor := FAxes.XPixelPerValue  / ( 96 / 25.4)
  else
    LLwFactor := 1.0;

  if Assigned(FViewPort) and FViewPort.Inited then
    FViewPort.Paint(ACanvas, AFlag, LLwFactor, LUsrClip) ;

  if LUsrClip then
    _DrawPaperCover();

  if (not FModelType) and Assigned(FViewPort) and Assigned(FViewPort.BoundsShape) then
    FViewPort.BoundsShape.Draw(ACanvas, FAxes, AFlag);

  for I := 0 to FVisibleList.Count - 1 do
  begin
    LEntity := TUdEntity(FVisibleList[I]);
    if Assigned(LEntity) and not LEntity.Selected then
      LEntity.Draw(ACanvas, FAxes, AFlag, LLwFactor);
  end;

  if not Self.ViewPortActived then
  begin
    LSelectedList := Self.GetSelectedList();

    for I := 0 to LSelectedList.Count - 1 do
    begin
      LEntity := TUdEntity(LSelectedList[I]);
      if Assigned(LEntity) then
        LEntity.Draw(ACanvas, FAxes, AFlag, LLwFactor);
    end;

    FSelection.DrawGrips(ACanvas);
  end;
end;

procedure TUdLayout.PaintAction(Sender: TObject; ACanvas: TCanvas);
var
  LActiveAction: TUdAction;
begin
  FDrafting.Draw(ACanvas);
  
  LActiveAction := GetActiveAction();
  if Assigned(LActiveAction) then LActiveAction.Paint(Self, ACanvas);
end;

procedure TUdLayout.Scroll(Sender: TObject; AKind: Integer; AScrollCode: TScrollCode; AScrollPos: Integer);
begin
  // Is such "FAxes", because DrawPanel's scrollbar only for Layout, not for FViewPort
  with FAxes do
  begin
    case AKind of
      SB_HORZ: SetPan(-Round(AScrollPos * XPixelPerValue), YPan);
      SB_VERT: SetPan(XPan, Round(AScrollPos * YPixelPerValue));
    end;
  end;

  if AScrollCode = scEndScroll then
  begin
    if Self.FActions.Count > 0 then ;
  end;
end;

procedure TUdLayout.DblClick( Sender: TObject; APoint: TPoint);
var
  LPnt: TPoint2D;
  LBool: Boolean;
  LActiveAction: TUdAction;
begin
  LActiveAction := GetActiveAction();

  if not Assigned(LActiveAction) or LActiveAction.InheritsFrom(FActionIdleClass) then
  begin
    if Assigned(FViewPort) and FViewPort.Inited then
    begin
      LPnt := FAxes.PointValue(APoint);
      LBool := UdGeo2D.IsPntInRect(LPnt, FViewPort.BoundsRect);

      if FViewPort.Actived <> LBool then
      begin
        FViewPort.Actived := LBool;
        FViewPort.Axes.ClearZoomLog();

        Self.RemoveAllSelected();
        Self.Invalidate();

        Exit; //=====>>>>
      end;
    end;
  end;

  if Assigned(LActiveAction) then
  begin
    LActiveAction.DblClick(Self, APoint);
  end;
end;

procedure TUdLayout.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; var AKey: Word);
var
  LActiveAction: TUdAction;
begin
  LActiveAction := GetActiveAction();
  if Assigned(LActiveAction) then
    LActiveAction.KeyEvent(Self, AKind, AShift, AKey);
end;


function TUdLayout.MousePoint2D(AAction: TUdAction; APoint: TPoint; AApplySnap: Boolean; out AOSnapKind: Integer): TPoint2D;
var
  LPrevPnt: PPoint2D;
  LGripPnts: TUdGripPointArray;
  LActiveAction: TUdAction;
  LOrthoed, LOSnaped: Boolean;
  LPoint, LOrthoPoint, LSnapPoint: TPoint2D;
begin
  LPoint := Self.Axes.PointValue(APoint);
  AOSnapKind := 0;

  LActiveAction := AAction;
  if not Assigned(LActiveAction) then
  begin
    Result := LPoint;
    Exit; //=======>>>>>
  end;

  if LActiveAction.InheritsFrom(FActionIdleClass) then
  begin
    LGripPnts := Self.GetGripPoints(LPoint, 1);

    if System.Length(LGripPnts) > 0 then
      Result := LGripPnts[0].Point
    else begin
      if FDrafting.SnapOn and LActiveAction.CanSnap then
        Result := FDrafting.GetSnapPoint(@LPoint)
      else
        Result := LPoint;
    end;
  end
  else begin
    LOSnaped := False;
    LOrthoed := False;


    LPrevPnt := FPrevPoint;

    if not LActiveAction.MustOSnap and FDrafting.SnapOn and LActiveAction.CanSnap then
      LPoint := FDrafting.GetSnapPoint(@LPoint);

    if Assigned(LPrevPnt) and FDrafting.OrthoOn and LActiveAction.CanOrtho then
    begin
      LOrthoPoint := FDrafting.GetOrthoPoint(LPrevPnt, @LPoint);
      LOrthoed := True;
    end;

    if LActiveAction.MustOSnap or LActiveAction.CanOSnap then
    begin
      FDrafting.ObjectSnap.CanPerpend := LActiveAction.CanPerpend;
      LSnapPoint := FDrafting.GetOSnapPoint(LPrevPnt, @LPoint, AOSnapKind);
      LOSnaped := AOSnapKind <> OSNP_NUL;
    end;


    Result := LPoint;
    
    if AApplySnap then
    begin
      if LOSnaped then Result := LSnapPoint;
    end
    else begin
      if LOrthoed then Result := LOrthoPoint;
    end;
  end;
end;

procedure TUdLayout.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState; var APoint: TPoint);
var
  LOSnapKind: Integer;
  LPolared: Boolean;
  LPolarPoint: TPoint2D;
  LActiveAction: TUdAction;
begin
  LActiveAction := GetActiveAction();
  if not Assigned(LActiveAction) then Exit;

  FCurrPoint := Self.MousePoint2D(LActiveAction, APoint, (AKind = mkMouseDown), LOSnapKind);
  APoint := Self.Axes.PointPixel(FCurrPoint);


  if not LActiveAction.MustOSnap and FDrafting.PolarOn and not LActiveAction.InheritsFrom(FActionIdleClass) then
  begin
    if LActiveAction.CanPolar then
    begin
      LPolarPoint := FDrafting.GetPolarPoint(FPrevPoint, @FCurrPoint, LPolared);
      if LPolared then FCurrPoint := LPolarPoint;
    end;
  end;

  if (AKind = mkMouseDown) and (AButton = mbLeft) and
     not LActiveAction.InheritsFrom(FActionIdleClass) and
     not LActiveAction.InheritsFrom(TUdViewAction) then
  begin
    if not Assigned(FPrevPoint) then FPrevPoint := New(PPoint2D);
    FPrevPoint^ := FCurrPoint;

    if FAutoRestOSnap then Self.SetOSnapMode(0);
  end;

  if (AKind = mkMouseDown) and not (ssRight in AShift) then
  begin
    if LActiveAction.MustOSnap then
    begin
      if LOSnapKind <> 0 then
        LActiveAction.MouseEvent(Self, AKind, AButton, AShift, FCurrPoint, APoint);
    end
    else
      LActiveAction.MouseEvent(Self, AKind, AButton, AShift, FCurrPoint, APoint);
  end
  else
    LActiveAction.MouseEvent(Self, AKind, AButton, AShift, FCurrPoint, APoint);
end;

procedure TUdLayout.MouseWheel(Sender: TObject; AKeys: SmallInt; AWheelDelta: SmallInt; XPos, YPos: Smallint);
const
  WHEEL_FACTOR = 200;
var
  LDelta: Double;
  LPoint: TPoint;
  LBasePnt: TPoint2D;
begin
  if Assigned(Self.Document) and Assigned(FDrawPanel) and
    (FPreviewing or (Self = TUdDocument(Self.Document).ActiveLayout)) then
  begin
    LPoint := Point(XPos, YPos);
    Windows.ScreenToClient(FDrawPanel.Handle, LPoint);

    with Self.Axes do
    begin
      LDelta := AWheelDelta * (Scale / WHEEL_FACTOR);
      LBasePnt := PointValue(LPoint);

      DyncScale(Scale + LDelta, LBasePnt);
    end;
  end;
end;

procedure TUdLayout.Resize(ANewWidth, ANewHeight: Integer);
var
  LDelta: Float;
  XBound, YBound: TPoint2D;
begin
  if not Assigned(Self.DrawPanel) then Exit;
  if (ANewWidth < 0) or (ANewHeight < 0) then Exit;

  LDelta := (FAxes.XValuePerPixel * (ANewWidth - FAxes.Margin * 2)) - (FAxes.XMax - FAxes.XMin);
  XBound := Point2D(FAxes.XMin - LDelta / 2, FAxes.XMax + LDelta / 2);

  LDelta := (FAxes.YValuePerPixel * (ANewHeight - FAxes.Margin * 2)) - (FAxes.YMax - FAxes.YMin);
  YBound := Point2D(FAxes.YMin - LDelta / 2, FAxes.YMax + LDelta / 2);

  FAxes.CalcAxis(ANewWidth, ANewHeight, XBound, YBound);
  if Assigned(FViewPort) and FViewPort.Inited then FViewPort.UpdateAxes();
  
  Self.UpdateVisibleList();
end;



//----------------------------------------------------------------------------------

function TUdLayout.Invalidate(): Boolean;
begin
  Result := False;

  if Assigned(Self.Document) and Assigned(FDrawPanel) and
    (FPreviewing or (Self = TUdDocument(Self.Document).ActiveLayout)) then
//  if Assigned(Self.Document) and Assigned(FDrawPanel) then
  begin
    FDrawPanel.Invalidate;
    Result := True;
  end;
end;

function TUdLayout.InvalidateRect(ARect: TRect; AErase: Boolean = False): Boolean;
begin
  Result := False;

  if Assigned(FDrawPanel) then
  begin
    Result := True;

    if Assigned(Self.Document) then
      Result :=  (FPreviewing or (Self = TUdDocument(Self.Document).ActiveLayout));

     if Result then
        Windows.InvalidateRect(FDrawPanel.Handle, @ARect, AErase);
  end;
end;

function TUdLayout.InvalidateRect(ARect: TRect2D; AErase: Boolean = False): Boolean;
var
  LRect: TRect;
  V1, V2: Integer;
begin
  V1 := FAxes.XPixel(ARect.X1);
  V2 := FAxes.XPixel(ARect.X2);

  if V1 > V2 then Swap(V1, V2);
  LRect.Left   := V1;
  LRect.Right  := V2;

  V1 := FAxes.YPixel(ARect.Y1);
  V2 := FAxes.YPixel(ARect.Y2);

  if V1 < V2 then Swap(V1, V2);
  LRect.Bottom := V1;
  LRect.Top    := V2;

  Result := InvalidateRect(LRect, AErase);
end;





//----------------------------------------------------------------------------------

function TUdLayout.Pan(DX, DY: Integer): Boolean;
begin
  if Self.ViewPortActived then
  begin
    with FViewPort.Axes do
    begin
      XMin := XMin - Dx * XValuePerPixel;
      XMax := XMax - Dx * XValuePerPixel;

      YMin := YMin + Dy * YValuePerPixel;
      YMax := YMax + Dy * YValuePerPixel;
    end;

    FViewPort.UpdateAxes();
    FViewPort.UpdateVisibleList();

    Self.Invalidate();
  end
  else begin
    FAxes.Pan(DX, DY);
  end;

  Result := True;
end;

function TUdLayout.ZoomIn(): Boolean;
begin
  Self.Axes.ZoomIn();
  Result := True;
end;

function TUdLayout.ZoomOut(): Boolean;
begin
  Self.Axes.ZoomOut();
  Result := True;
end;

function TUdLayout.ZoomAll(): Boolean;
var
  LRect: TRect2D;
begin
  if Self.ViewPortActived then
    Self.ZoomAllViewport()
  else begin
    LRect := Self.GetEntitiesBound();
    if not IsValidRect(LRect) then LRect := FAxes.LimRect;
    FAxes.ZoomWindow(LRect, False);
  end;

  Result := True;
end;

function TUdLayout.ZoomExtends(): Boolean;
begin
  if Self.ViewPortActived then
    Self.ZoomAllViewport()
  else
    FAxes.ZoomWindow(Self.GetEntitiesBound(), True);
  Result := True;
end;

function TUdLayout.ZoomScale(const AValue: Double): Boolean;
begin
  Self.Axes.ZoomScale(AValue);
  Result := True;
end;

function TUdLayout.ZoomWindow(ARect: TRect2D; AExtends: Boolean): Boolean;
begin
  Self.Axes.ZoomWindow(ARect, AExtends);
  Result := True;
end;

function TUdLayout.ZoomPrevious(): Boolean;
begin
  Result := False;
  if Assigned(Self.DrawPanel) then
  begin
    Self.Axes.ZoomPrevious();
    Result := True;
  end;
end;

function TUdLayout.ZoomCenter(ACen: TPoint2D): Boolean;
begin
  Self.Axes.ZoomCenter(ACen);
  Result := True;
end;



//----------------------------------------------------------------------------------

function TUdLayout.PickEntity(APoint: TPoint2D; AForce: Boolean = False): TUdEntity;
begin
  Result := FSelection.PickEntity(APoint, AForce);

  if not Assigned(Result) and Assigned(FViewPort) and FViewPort.Inited and FViewPort.Visible and not FViewPort.Actived then
  begin
    if FViewPort.BoundsShape.Pick(APoint) then
      Result := FViewPort.BoundsShape;
  end;
end;

function TUdLayout.PickEntity(ARect: TRect2D; ACrossingMode: Boolean; AForce: Boolean = False): TUdEntityArray;
begin
  Result := FSelection.PickEntity(ARect, ACrossingMode, AForce);

  if Assigned(FViewPort) and FViewPort.Inited and FViewPort.Visible and not FViewPort.Actived then
  begin
    if FViewPort.BoundsShape.Pick(ARect, ACrossingMode) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := FViewPort.BoundsShape;
    end;
  end;
end;


function TUdLayout.AddSelectedEntity(AEntity: TUdEntity): Boolean;
begin
  Result := FSelection.AddEntity(AEntity, True{ARaiseEvent});
end;


function TUdLayout.AddSelectedEntities(AEntities: TUdEntityArray): Boolean;
begin
  Result := FSelection.AddEntities(AEntities, True{ARaiseEvent});
end;


function TUdLayout.SelectEntity(APoint: TPoint2D): Boolean;
begin
  Result := FSelection.SelectEntity(APoint, True{ARaiseEvent});
end;

function TUdLayout.SelectEntities(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := FSelection.SelectEntities(ARect, ACrossingMode, True{ARaiseEvent});
end;


function TUdLayout.RemoveAllSelected(): Boolean;
begin
  Result := FSelection.RemoveAll(True{ARaiseEvent});
end;

function TUdLayout.RemoveSelectedEntity(AEntity: TUdEntity): Boolean;
begin
  Result := FSelection.RemoveEntity(AEntity, True{ARaiseEvent});
end;

function TUdLayout.RemoveSelectedEntities(AEntities: TUdEntityArray): Boolean;
begin
  Result := FSelection.RemoveEntities(AEntities, True{ARaiseEvent});
end;

function TUdLayout.EraseSelectedEntities(): Boolean;
var
  N: Integer;
  LEntities: TUdEntityArray;
begin
  Result := False;

  if Assigned(FViewPort) and FViewPort.Inited and FViewPort.Visible and not FViewPort.Actived then
  begin
    N := FSelection.List.IndexOf(FViewPort.BoundsShape);
    if N >= 0 then
    begin
      FSelection.RemoveEntity(FViewPort.BoundsShape, False);
      FViewPort.Visible := False;
    end;
  end;

  if UdUtils.GetEntitiesArray(FSelection.List, LEntities) then
  begin
    FSelection.RemoveAll();
    Result := Self.Entities.Remove(LEntities);
  end;
end;



//----------------------------------------------------------------------------------
{ Entities... }

function FInitEntity(ADoc: TUdDocument; AEntity: TUdEntity): Boolean;
begin
  Result := False;
  if not Assigned(ADoc) or not Assigned(AEntity) then Exit;

//  if AEntity.Color.ByKind = bkNone then AEntity.Color.Assign(ADoc.ActiveColor);
//  if AEntity.LineType.ByKind = bkNone then AEntity.LineType.Assign(ADoc.ActiveLineType);

//  with AEntity do
//  begin
//    Layer := ADoc.ActiveLayer;
//    Color.Assign(ADoc.ActiveColor);
//    LineType.Assign(ADoc.ActiveLineType);
//    LineTypeScale := ADoc.LineTypes.CurrentScale;
//    LineWeight := ADoc.ActiveLineWeight;
//  end;

  AEntity.Finished := True;
  AEntity.Visible := True;

  Result := True;
end;

function TUdLayout.AddEntity(AEntity: TUdEntity): Boolean;
begin
  Result := False;
  if not Assigned((AEntity)) then Exit;

  FInitEntity(TUdDocument(Self.Document), AEntity);
  Result := Self.Entities.Add(AEntity);
end;

function TUdLayout.AddEntities(AEntities: TUdEntityArray): Boolean;
var
  I: Integer;
begin
  Result := False;
  if System.Length(AEntities) <= 0 then Exit;

  for I := 0 to System.Length(AEntities) - 1 do
    FInitEntity(TUdDocument(Self.Document), AEntities[I]);

  Result := Self.Entities.Add(AEntities);
end;


function TUdLayout.InsertdEntity(AIndex: Integer; AEntity: TUdEntity): Boolean;
begin
  Result := False;
  if not Assigned((AEntity)) then Exit;

  FInitEntity(TUdDocument(Self.Document), AEntity);
  Result := Self.Entities.Insert(AIndex, AEntity);
end;


function TUdLayout.RemoveEntityAt(AIndex: Integer): Boolean;
begin
  Result := Self.Entities.RemoveAt(AIndex);
end;

function TUdLayout.RemoveEntity(AEntity: TUdEntity): Boolean;
begin
  Result := Self.Entities.Remove(AEntity);
end;

function TUdLayout.RemoveEntities(AEntities: TUdEntityArray): Boolean;
begin
  Result := Self.Entities.Remove(AEntities);
end;


function TUdLayout.IndexOfEntity(AEntity: TUdEntity): Integer;
begin
  Result := Self.Entities.IndexOf(AEntity);
end;



//----------------------------------------------------------------------------------

function TUdLayout.GetActiveAction: TUdAction;
begin
  Result := TUdAction(FActions.Peek());
  if not Assigned(Result) then Result := Self.IdleAction;
end;


function TUdLayout.ActionAdd(AClass: TUdActionClass; Args: string = ''): Boolean;
var
  LAction: TUdAction;
  LLastAction: TUdAction;
begin
  Result := False;
  if not Assigned(AClass) or (AClass = FActionIdleClass) then Exit; //==========>>>>>>

  LLastAction := TUdAction(FActions.Peek());
  if Assigned(LLastAction) and (LLastAction.ClassType = AClass) then Exit; //==========>>>>>>

  if Assigned(LLastAction) then
    LLastAction.Visible := False
  else
    if Assigned(Self.IdleAction) then Self.IdleAction.Reset();

  if Assigned(Self.Document) then
    TUdDocument(Self.Document).BeginUndo(AClass.CommandName);

  LAction := AClass.Create(Self.Document, Self, Args);
  if LAction.Aborted then
  begin
    LAction.Free;

    if Assigned(Self.Document) then
      TUdDocument(Self.Document).EndUndo();
    
    if Assigned(LLastAction) then
      LLastAction.Visible := True
    else
      Self.SetXCursorStyle(csIdle);
  end
  else begin
    FActions.Push(LAction);
    if Assigned(FOnActionChanged) then FOnActionChanged(Self);
  end;

  Self.Invalidate;
  Result := True;
end;

function TUdLayout.ActionParse(AText: string): Boolean;
begin
  Result := Self.ActiveAction.Parse(AText);
end;

function TUdLayout.ActionRemoveLast: Boolean;
var
  LAction: TUdAction;
begin
  Result := False;

  FDrafting.Reset(True);

  LAction := TUdAction(FActions.Pop());
  if not Assigned(LAction) then Exit; //=======>>>>>

  LAction.Free;

  LAction := TUdAction(FActions.Peek());
  if Assigned(LAction) then
  begin
    //... ...
    LAction.Visible := True;
  end
  else begin
    if Assigned(Self.Document) then
       TUdDocument(Self.Document).EndUndo();

    if Assigned(Self.IdleAction) then
      Self.IdleAction.Reset()
    else
      if FPreviewing then FDrawPanel.Cursor := crArrow;

    if Assigned(FPrevPoint) then Dispose(FPrevPoint);
    FPrevPoint := nil;
  end;

  Self.Invalidate;
  Self.SetOSnapMode(0);

  if Assigned(FOnActionChanged) then FOnActionChanged(Self);

  Result := True;
end;

function TUdLayout.ActionClear(): Boolean;
var
  LAction: TUdAction;
begin
  LAction := Self.ActiveAction;
  if ( Assigned(LAction) and LAction.InheritsFrom(TUdViewAction) ) then
  begin
    Result := Self.ActionRemoveLast();
    Exit; //============>>>>>>
  end;
  
  FDrafting.Reset(True);

  LAction := TUdAction(FActions.Pop());
  while LAction <> nil do
  begin
    LAction.Free;
    LAction := TUdAction(FActions.Pop());
  end;

  TUdDocument(Self.Document).EndUndo();

  if Assigned(FPrevPoint) then Dispose(FPrevPoint);
  FPrevPoint := nil;

  if FPreviewing then FDrawPanel.Cursor := crArrow else Self.SetXCursorStyle(csIdle);
  Self.Invalidate;
  Self.SetOSnapMode(0);

  if Assigned(FOnActionChanged) then FOnActionChanged(Self);

  Result := True;
end;


function TUdLayout.IsIdleAction(): Boolean;
var
  LAction: TUdAction;
begin
  LAction := GetActiveAction();
  Result := not Assigned(LAction) or LAction.InheritsFrom(FActionIdleClass);
end;

function TUdLayout.IsGripAction(): Boolean;
var
  LAction: TUdAction;
begin
  LAction := GetActiveAction();
  Result := not Assigned(LAction) or LAction.InheritsFrom(TUdActionGrip);
end;

procedure TUdLayout.SetPrevPoint(APnt: TPoint2D);
begin
  if not Assigned(FPrevPoint) then FPrevPoint := New(PPoint2D);
  FPrevPoint^ :=  APnt;
end;

procedure TUdLayout.DeletePrevPoint();
begin
  if Assigned(FPrevPoint) then Dispose(FPrevPoint);
  FPrevPoint := nil;
end;



//---------------------------------------------------------------------------------------------

procedure TUdLayout.SaveToStream(AStream: TStream);
var
  LHasEntities: Boolean;
begin
  inherited;

  StrToStream(AStream, FName);
  BoolToStream(AStream, FModelType);
  IntToStream(AStream, FBackColor);

  PlotConfigToStream(AStream, FPlotConfig);
  Point2DToStream(AStream, FPaperLimMin);
  Point2DToStream(AStream, FPaperLimMax);

  FAxes.SaveToStream(AStream);
  FDrafting.SaveToStream(AStream);

  LHasEntities := (not FModelType) or
                  (Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdLayouts) and (TUdLayouts(Self.Owner).IndexOf(Self) = 0)) or
                  (Assigned(Self.Document) and (TUdDocument(Self.Document).ModelSpace = Self));

  BoolToStream(AStream, LHasEntities);
  if LHasEntities then FEntities.SaveToStream(AStream);

  BoolToStream(AStream, Assigned(FViewPort));
  if Assigned(FViewPort) then FViewPort.SaveToStream(AStream);


end;

procedure TUdLayout.LoadFromStream(AStream: TStream);
var
  LBool: Boolean;
  LHasEntities: Boolean;
begin
  inherited;

  Self.RemoveAllSelected();

  FName := StrFromStream(AStream);
  FModelType := BoolFromStream(AStream);
  FBackColor := TColor(IntFromStream(AStream));

  FPlotConfig  := PlotConfigFromStream(AStream);
  FPaperLimMin := Point2DFromStream(AStream);
  FPaperLimMax := Point2DFromStream(AStream);

  FAxes.LoadFromStream(AStream);
  FDrafting.LoadFromStream(AStream);

  LHasEntities := BoolFromStream(AStream);
  if LHasEntities then
  begin
    if not FModelType then
    begin
      FEntities := TUdEntities.Create(Self.Document, Self.IsDocRegister);
      FEntities.Owner := Self;
      FEntities.OnAddEntities := OnEntitiesAddEntities;
      FEntities.OnRemoveEntities := OnEntitiesRemoveEntities;
      FEntities.OnRemovedEntities := OnEntitiesRemovedEntities;
    end;

    FEntities.LoadFromStream(AStream);
  end;

  LBool := BoolFromStream(AStream);
  if LBool then
  begin
    if not Assigned(FViewPort) then
    begin
      FViewPort := TUdViewPort.Create(Self.Document, Self.IsDocRegister);
      //FViewPort.Entities := TUdDocument(Self.Document).ModelSpace.Entities;
      FViewPort.Owner := Self;

      FViewPort.OnAxesChanging := OnAxesObjectChanging;
      FViewPort.OnBoundsChanged := OnViewPortBoundsChanged;
      
      Self.AddDocObject(FViewPort, False);
    end;

    FViewPort.LoadFromStream(AStream);
  end
  else begin
    if Assigned(FViewPort) then FViewPort.Free;
    FViewPort := nil;
  end;

  if Assigned(FViewPort) and FViewPort.Inited then FViewPort.UpdateAxes();
  Self.UpdateVisibleList();
end;





procedure TUdLayout.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
  LHasEntities: Boolean;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Name']      := FName;
  LXmlNode.Prop['ModelType'] := BoolToStr(FModelType, True);//IntToStr(Ord(FModelType));
  LXmlNode.Prop['BackColor'] := IntToStr(FBackColor);

  PlotConfigToXml(LXmlNode.Add(), FPlotConfig);
  LXmlNode.Prop['PaperLimMin'] := Point2DtoStr(FPaperLimMin);
  LXmlNode.Prop['PaperLimMax'] := Point2DtoStr(FPaperLimMax);

  FAxes.SaveToXml(LXmlNode.Add());
  FDrafting.SaveToXml(LXmlNode.Add());

  LHasEntities := (not FModelType) or
                  (Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdLayouts) and (TUdLayouts(Self.Owner).IndexOf(Self) = 0)) or
                  (Assigned(Self.Document) and (TUdDocument(Self.Document).ModelSpace = Self));

  LXmlNode.Prop['HasEntities'] := BoolToStr(LHasEntities, True);
  if LHasEntities then FEntities.SaveToXml(LXmlNode.Add());

  LXmlNode.Prop['HasViewPort'] := BoolToStr(Assigned(FViewPort), True);
  if Assigned(FViewPort) then FViewPort.SaveToXml(LXmlNode.Add());
end;

procedure TUdLayout.LoadFromXml(AXmlNode: TObject);
var
  LHasEntities: Boolean;
  LHasViewPort: Boolean;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);


  Self.RemoveAllSelected();

  FName      := LXmlNode.Prop['Name'];
  FModelType := StrToBoolDef(LXmlNode.Prop['ModelType'], True);//Boolean(StrToIntDef(LXmlNode.Prop['ModelType'], 0));
  FBackColor := StrToIntDef(LXmlNode.Prop['BackColor'], clBlack);

  FPlotConfig  := PlotConfigFromXml(LXmlNode.FindItem('PlotConfig'));
  FPaperLimMin := StrToPoint2D(LXmlNode.Prop['PaperLimMin']);
  FPaperLimMax := StrToPoint2D(LXmlNode.Prop['PaperLimMax']);

  FAxes.LoadFromXml(LXmlNode.FindItem('Axes'));
  FDrafting.LoadFromXml(LXmlNode.FindItem('Drafting'));

  LHasEntities := StrToBoolDef(LXmlNode.Prop['HasEntities'], True);

  if LHasEntities then
  begin
    if not FModelType then
    begin
      FEntities := TUdEntities.Create(Self.Document, Self.IsDocRegister);
      FEntities.Owner := Self;
      FEntities.OnAddEntities := OnEntitiesAddEntities;
      FEntities.OnRemoveEntities := OnEntitiesRemoveEntities;
      FEntities.OnRemovedEntities := OnEntitiesRemovedEntities;
    end;

    FEntities.LoadFromXml(LXmlNode.FindItem('Entities'));
  end;

  LHasViewPort := StrToBoolDef(LXmlNode.Prop['HasViewPort'], False);
  if LHasViewPort then
  begin
    if not Assigned(FViewPort) then
    begin
      FViewPort := TUdViewPort.Create(Self.Document, Self.IsDocRegister);
      //FViewPort.Entities := TUdDocument(Self.Document).ModelSpace.Entities;
      FViewPort.Owner := Self;

      FViewPort.OnAxesChanging := OnAxesObjectChanging;
      FViewPort.OnBoundsChanged := OnViewPortBoundsChanged;
      
      Self.AddDocObject(FViewPort, False);
    end;

    FViewPort.LoadFromXml(LXmlNode.FindItem('ViewPort'));
  end
  else begin
    if Assigned(FViewPort) then FViewPort.Free;
    FViewPort := nil;
  end;

  if Assigned(FViewPort) and FViewPort.Inited then FViewPort.UpdateAxes();
  Self.UpdateVisibleList();
end;




//---------------------------------------------------------------------------------------------
{Print}

procedure TUdLayout.OnPlotPickWindow(Sender: TObject; ARect: TRect2D);
var
  LPlot: TUdPlot;
  LPlotConfig: TUdPlotConfig;
begin
  if Assigned(FTempPlotConfig) then
  begin
    LPlotConfig := FTempPlotConfig^;

    if IsValidRect(ARect) then
    begin
      LPlotConfig.PlotWindow.X1 := ARect.X1;
      LPlotConfig.PlotWindow.Y1 := ARect.Y1;
      LPlotConfig.PlotWindow.X2 := ARect.X2;
      LPlotConfig.PlotWindow.Y2 := ARect.Y2;
    end;

    Dispose(FTempPlotConfig);
    FTempPlotConfig := nil;
  end
  else begin
    InitPlotConfig(LPlotConfig);
  end;

  LPlot := TUdPlot.Create(Self.Document, Self);
  try
    LPlot.ShowForm(@LPlotConfig, OnPlotPickWindow);
    if LPlot.PlotForm.Tag = 1 then
    begin
      if not Assigned(FTempPlotConfig) then FTempPlotConfig := New(PUdPlotConfig);
      FTempPlotConfig^ := LPlot.PlotForm.Config;
    end;
  finally
    LPlot.Free;
  end;
end;

procedure TUdLayout.ShowPlotForm();
var
  LPlot: TUdPlot;
begin
  LPlot := TUdPlot.Create(Self.Document, Self);
  try
    LPlot.ShowForm(nil, OnPlotPickWindow);
    if LPlot.PlotForm.Tag = 1 then
    begin
      if not Assigned(FTempPlotConfig) then FTempPlotConfig := New(PUdPlotConfig);
      FTempPlotConfig^ := LPlot.PlotForm.Config;
    end;
  finally
    LPlot.Free;
  end;
end;

function TUdLayout.Print(): Boolean;
var
  LPlot: TUdPlot;
begin
  LPlot := TUdPlot.Create(Self.Document, Self);
  try
    Result := LPlot.Print(FPlotConfig);
  finally
    LPlot.Free;
  end;
end;

function TUdLayout.ExportFile(AFileName: string; AFileFormat: TUdPlotImageFormat = pifBmp): Boolean;
var
  LPlot: TUdPlot;
  LPlotConfig: TUdPlotConfig;
begin
  LPlot := TUdPlot.Create(Self.Document, Self);
  try
    LPlotConfig := FPlotConfig;
    LPlotConfig.PlotToFile := True;
    LPlotConfig.FileFormat := AFileFormat;
    Result := LPlot.ExportFile(LPlotConfig, AFileName);
  finally
    LPlot.Free;
  end;
end;



end.