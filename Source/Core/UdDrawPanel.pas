{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDrawPanel;

{$I UdDefs.INC}
//{$DEFINE GR32}

interface

uses
  Windows, Messages, Classes, Controls, Graphics, StdCtrls, ExtCtrls, Tabs, Types,
  UdConsts, UdTypes, UdIntfs, UdEvents, UdCursor, {$IFDEF GR32} GR32 {$ELSE} UdBitmap {$ENDIF};


const
  DEFAULT_WIDTH = 400;
  DEFAULT_HEIGHT = 300;


type
  TGetCanPopMenuEvent = procedure(Sender: TObject; var AAllow: Boolean) of object;

  //*** TUdDrawPanel ***//
  TUdDrawPanel = class(TWinControl, IUdCanvasSupport)
  private
    FCanvas: TCanvas;
    FBitmap: {$IFDEF GR32} TBitmap32 {$ELSE} TUdBitmap {$ENDIF};

    FXCursor: TUdCursor;
    FReadOnly: Boolean;

    FScrollSize: Integer;
    FScrollBars: TScrollStyle;

    FXScrollBar: TScrollBar;
    FYScrollBar: TScrollBar;

    FLayoutTabs : TTabSet;
    FScrSplitter: TSplitter;

    FRightPanel: TWinControl;
    FBottomPanel: TWinControl;
    FCornerPanel: TWinControl;

    FDblClicking: Boolean;
    FLastPaintTick: Cardinal;


    FOnPaint     : TUdPaintEvent;
    FOnScroll    : TUdScrollEvent;
    FOnDblClick  : TUdClickEvent;
    FOnKeyEvent  : TUdKeyEvent;
    FOnMouseEvent: TUdMouseEvent;
    FOnMouseWheel: TUdMouseWheelEvent;

    FOnResized   : TNotifyEvent;

    FOnTabChange : TTabChangeEvent;
    F_OnTabChange: TTabChangeEvent;
    FOnGetCanPopMenu: TGetCanPopMenuEvent;


  protected
    function GetCanvas: TCanvas;
    procedure SetScrollBars(const AValue: TScrollStyle);

    procedure SetReadOnly(const AValue: Boolean);
    
    function CreateControls: Boolean;
    function LayoutControls: Boolean;

    procedure OnScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure OnCornerPanelClick(Sender: TObject);

    procedure OnScrSplitterMoved(Sender: TObject);
    procedure OnLayoutTabsChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
    procedure OnLayoutTabsCustomDraw(Sender: TObject; TabCanvas: TCanvas; R: TRect; Index: Integer; Selected: Boolean);

    function GetLayoutTabsVisible: Boolean;
    procedure SetLayoutTabsVisible(const AValue: Boolean);    

    {IUdCanvasSupport...}
    function GetBitmapCanvas(): TObject;
    function GetControlCanvas(): TObject;
        
  protected
    procedure Resize(); override;
    procedure CreateWnd; override;
    procedure CreateParams(var AParams: TCreateParams); override;

    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMMouseWheel(var AMessage: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;


    property _OnResized    : TNotifyEvent       read FOnResized    write FOnResized;
    property _OnPaint      : TUdPaintEvent      read FOnPaint      write FOnPaint;
    property _OnScroll     : TUdScrollEvent     read FOnScroll     write FOnScroll;
    property _OnDblClick   : TUdClickEvent      read FOnDblClick   write FOnDblClick;
    property _OnKeyEvent   : TUdKeyEvent        read FOnKeyEvent   write FOnKeyEvent;
    property _OnMouseEvent : TUdMouseEvent      read FOnMouseEvent write FOnMouseEvent;
    property _OnMouseWheel : TUdMouseWheelEvent read FOnMouseWheel write FOnMouseWheel;
    property _OnTabChange  : TTabChangeEvent    read F_OnTabChange write F_OnTabChange;
    property _LayoutTabs   : TTabSet            read FLayoutTabs;
    property _OnGetCanPopMenu: TGetCanPopMenuEvent read FOnGetCanPopMenu write FOnGetCanPopMenu;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateScroll(ABound: TRect2D; APan: TPoint2D; AScale: Float);

    function AddLayoutTab(ATabName: string = ''): Boolean;
    function RemoveLayoutTab(ATabIndex: Integer): Boolean;
    function RenameLayoutTab(ATabIndex: Integer; ANewName: string): Boolean;

    property XCursor: TUdCursor read FXCursor;
    property ScrollSize: Integer read FScrollSize;

    property Canvas: TCanvas read GetCanvas;
    property Bitmap: {$IFDEF GR32} TBitmap32 {$ELSE} TUdBitmap {$ENDIF} read FBitmap;
    property DblClicking: Boolean read FDblClicking;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;


  published
    property Align;
    property Anchors;
    property Caption;
    property Color;
    property Constraints;
    property Ctl3D;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;

    property PopupMenu;

    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;

  published
    property XScrollBar : TScrollBar      read FXScrollBar;
    property YScrollBar : TScrollBar      read FYScrollBar;
    property ScrollBars : TScrollStyle    read FScrollBars  write SetScrollBars;
    property LayoutTabsVisible: Boolean   read GetLayoutTabsVisible write SetLayoutTabsVisible;

    property OnTabChange: TTabChangeEvent read FOnTabChange write FOnTabChange;
  end;



implementation


uses
  SysUtils, Forms, Math
  {$IFDEF GR32} ,GR32_Backends_VCL {$ENDIF};





const
  CANVAS_LIST_CACHE_SIZE = 4;
  DEF_TABS_WIDTH         = 160;

type
  TFriendControl = class(TWinControl);


  
(*

var
  GCanvasList: TThreadList;


// Free the first available device context
procedure FreeDeviceContext;
var
  I: Integer;
begin
  with GCanvasList.LockList do
  try
    for I := 0 to Count-1 do
      with TControlCanvas(Items[I]) do
        if TryLock then
        try
          FreeHandle;
          Exit;
        finally
          Unlock;
        end;
  finally
    GCanvasList.UnlockList;
  end;
end;

procedure FreeDeviceContexts;
var
  I: Integer;
begin
  with GCanvasList.LockList do
  try
    for I := Count-1 downto 0 do
      with TUdCtrlCanvas(Items[I]) do
        if TryLock then
        try
          FreeHandle;
        finally
          Unlock;
        end;
  finally
    GCanvasList.UnlockList;
  end;
end;
*)


  

//==================================================================================================
{ TInnerScrollBar }

type
  //*** TInnerScrollBar ***//
  TInnerScrollBar = class(TScrollBar)
  private
    FFactor: Integer;

    procedure RaiseScroll(var AMessage: TWMScroll);
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure CNHScroll(var AMessage: TWMHScroll); message CN_HSCROLL;
    procedure CNVScroll(var AMessage: TWMVScroll); message CN_VSCROLL;

  public
    constructor Create(AOwner: TComponent); override;
  end;



constructor TInnerScrollBar.Create(AOwner: TComponent);
begin
  inherited;
end;


procedure TInnerScrollBar.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  if (not IsRightToLeft) or (Kind = sbVertical) then
    FFactor := 1
  else
    FFactor := -1;
  AParams.WinClassName := 'ATL:9212D5694E33';
end;

procedure TInnerScrollBar.RaiseScroll(var AMessage: TWMScroll);
var
  LNewPos: Longint;
  LScrollInfo: TScrollInfo;
begin
  with AMessage do
  begin
    LNewPos := Position;
    case TScrollCode(ScrollCode) of
      scLineUp: Dec(LNewPos, SmallChange * FFactor);
      scLineDown: Inc(LNewPos, SmallChange * FFactor);
      scPageUp: Dec(LNewPos, LargeChange * FFactor);
      scPageDown: Inc(LNewPos, LargeChange * FFactor);
      scPosition, scTrack:
        with LScrollInfo do
        begin
          cbSize := SizeOf(LScrollInfo);
          fMask := SIF_ALL;
          GetScrollInfo(Handle, SB_CTL, LScrollInfo);
          LNewPos := nTrackPos;
          if IsRightToLeft and (Kind <> sbVertical) then LNewPos := Max - LNewPos;
        end;
      scTop: LNewPos := Min;
      scBottom: LNewPos := Max;
    end;

    if LNewPos < Min then
      SetParams(LNewPos, LNewPos, Max)
    else if LNewPos > Max then
      SetParams(LNewPos, Min, LNewPos)
    else
      SetParams(LNewPos, Min, Max);

    Scroll(TScrollCode(ScrollCode), LNewPos);
  end;
end;

procedure TInnerScrollBar.CNHScroll(var AMessage: TWMHScroll);
begin
  RaiseScroll(AMessage);
end;

procedure TInnerScrollBar.CNVScroll(var AMessage: TWMVScroll);
begin
  RaiseScroll(AMessage);
end;




(*
//=================================================================================================
type
  //*** TUdCtrlCanvas ***//
  TUdCtrlCanvas = class(TCanvas)
  private
    FControl: TControl;
    FDeviceContext: HDC;
    FWindowHandle: HWnd;

  protected
    procedure SetControl(AControl: TControl);
    procedure CreateHandle; override;

  public
    constructor Create;
    destructor Destroy; override;

    procedure FreeHandle;
    procedure UpdateTextFlags;

  public
    property Control: TControl read FControl write SetControl;

  end;




constructor TUdCtrlCanvas.Create;
begin
  inherited;
  FControl := nil;
  FDeviceContext := 0;
  FWindowHandle := 0;
end;


destructor TUdCtrlCanvas.Destroy;
begin
  FreeHandle;
  inherited Destroy;
end;


type
  TFControl = class(TControl);

procedure TUdCtrlCanvas.CreateHandle;
begin
  if FControl = nil then inherited CreateHandle else
  begin
    if FDeviceContext = 0 then
    begin
      with GCanvasList.LockList do
      try
        if Count >= CANVAS_LIST_CACHE_SIZE then FreeDeviceContext;
        FDeviceContext := TFControl(FControl).GetDeviceContext(FWindowHandle);
        Add(Self);
      finally
        GCanvasList.UnlockList;
      end;
    end;

    Handle := FDeviceContext;
    UpdateTextFlags;
  end;
end;

procedure TUdCtrlCanvas.FreeHandle;
begin
  if FDeviceContext <> 0 then
  begin
    Handle := 0;
    GCanvasList.Remove(Self);
    ReleaseDC(FWindowHandle, FDeviceContext);
    FDeviceContext := 0;
  end;

end;



procedure TUdCtrlCanvas.SetControl(AControl: TControl);
begin
  if FControl <> AControl then
  begin
    FreeHandle;
    FControl := AControl;
  end;
end;

procedure TUdCtrlCanvas.UpdateTextFlags;
begin
  if Control = nil then Exit;
  if Control.UseRightToLeftReading then
    TextFlags := TextFlags or ETO_RTLREADING
  else
    TextFlags := TextFlags and not ETO_RTLREADING;
end;

{$IFDEF GR32}
type
  TFBitmap32 = class(TBitmap32);
{$ENDIF}

*)

//=================================================================================================
{ TUdDrawPanel }

constructor TUdDrawPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FReadOnly := False; 
  FLastPaintTick := 0;

  Color :=  clBlack;  // RGB(0,16,48);//

  ControlStyle := ControlStyle - [csOpaque];
  ControlStyle := ControlStyle + [csAcceptsControls, csCaptureMouse, csClickEvents, csDoubleClicks];

  FScrollSize := Min(GetSystemMetrics(SM_CXVSCROLL), GetSystemMetrics(SM_CYHSCROLL));
  FScrollBars := ssBoth;
  CreateControls;

  FBitmap := {$IFDEF GR32} TBitmap32.Create() {$ELSE} TUdBitmap.Create() {$ENDIF};
{$IFDEF GR32}
  TFBitmap32(FBitmap).SetBackend(TGDIMMFBackend.Create(FBitmap));
{$ENDIF}

  FCanvas := TControlCanvas.Create();
  TControlCanvas(FCanvas).Control := Self;


  Screen.Cursors[crNone] := LoadCursor(Hinstance, 'CNONE');
  Screen.Cursors[crIdle] := LoadCursor(Hinstance, 'CIDLE');
  Screen.Cursors[crDraw] := LoadCursor(Hinstance, 'CDRAW');
  Screen.Cursors[crPick] := LoadCursor(Hinstance, 'CPICK');
  Screen.Cursors[crPan ] := LoadCursor(Hinstance, 'CPAN' );
  Screen.Cursors[crZoom] := LoadCursor(Hinstance, 'CZOOM');
    
  FXCursor := TUdCursor.Create(Self);
  FXCursor.Color := Windows.RGB(255, 255, 255);//UdDrawUtil.NotColor(Self.Color);

  FDblClicking := False;
//  Self.DoubleBuffered := True;
end;



destructor TUdDrawPanel.Destroy;
begin
  FOnPaint := nil;
  FOnScroll := nil;
  FOnKeyEvent := nil;
  FOnMouseEvent := nil;

  if Assigned(FXCursor) then FXCursor.Free;
  FXCursor := nil;

  if Assigned(FLayoutTabs) then FLayoutTabs.Free();
  FLayoutTabs := nil;

  if Assigned(FScrSplitter) then FScrSplitter.Free();
  FScrSplitter := nil;

  if Assigned(FXScrollBar) then FXScrollBar.Free();
  FXScrollBar := nil;

  if Assigned(FYScrollBar) then FYScrollBar.Free();
  FYScrollBar := nil;

  if Assigned(FCornerPanel) then FCornerPanel.Free();
  FCornerPanel := nil;

  if Assigned(FRightPanel)  then FRightPanel.Free();
  FRightPanel := nil;

  if Assigned(FBottomPanel) then FBottomPanel.Free();
  FBottomPanel := nil;

  if Assigned(FBitmap) then FBitmap.Free();
  FBitmap := nil;

  if Assigned(FCanvas) then FCanvas.Free();
  FCanvas := nil;

  inherited Destroy;
end;






procedure TUdDrawPanel.SetReadOnly(const AValue: Boolean);
begin
  if FReadOnly <> AValue then
  begin
    FReadOnly := AValue;
    if FReadOnly then Self.Cursor :=0; 
  end;
end;



function TUdDrawPanel.GetCanvas: TCanvas;
begin
  Result := nil;
  if Assigned(FBitmap) then Result := FBitmap.Canvas;
end;


function TUdDrawPanel.GetControlCanvas: TObject;
begin
  Result := FCanvas;
end;

function TUdDrawPanel.GetBitmapCanvas: TObject;
begin
  Result := nil;
  if Assigned(FBitmap) then Result := FBitmap.Canvas;
end;




function TUdDrawPanel.GetLayoutTabsVisible: Boolean;
begin
  Result := FLayoutTabs.Visible;
end;


procedure TUdDrawPanel.SetLayoutTabsVisible(const AValue: Boolean);
begin
  FLayoutTabs.Visible := AValue;
  if AValue then
  begin
    FScrSplitter.Visible := True;
    FScrSplitter.Left := FLayoutTabs.Left + FLayoutTabs.Width + 1;
  end
  else
    FScrSplitter.Visible := False;
end;


//-------------------------------------------------------------------------------------------------

procedure TUdDrawPanel.Resize;
var
  LFactor: Double;
begin
  inherited Resize;

  FBitmap.SetSize(Self.Width, Self.Height);

//  FBitmap.Canvas.Brush.Color := Self.Color;
//  FBitmap.Canvas.Brush.Style := bsSolid;
//  FBitmap.Canvas.FillRect(Self.ClientRect);

  if FScrSplitter.Tag <= 0 then
  begin
    FLayoutTabs.Width := Trunc( (Self.Width - FScrollSize) * 0.6);
    FScrSplitter.Tag := -Self.Width;
  end
  else begin
    LFactor := FLayoutTabs.Width / FScrSplitter.Tag;
    FLayoutTabs.Width := Round(LFactor * Self.Width);
    
    FScrSplitter.Tag := Self.Width;
  end;

  FScrSplitter.Left  := FLayoutTabs.Width + 1;
  if Assigned(FOnResized) then FOnResized(Self);
end;

procedure TUdDrawPanel.CreateWnd;
begin
  inherited CreateWnd;
  
  if Self.HasParent then
  begin
    if Handle <> INVALID_HANDLE_VALUE then
      SetClassLong(Handle, GCL_HCURSOR, 0);
  end;
end;

procedure TUdDrawPanel.CreateParams(var AParams: TCreateParams);
begin
  inherited CreateParams(AParams);
  AParams.WinClassName := 'ATL:70627D725BDFE';
end;


procedure TUdDrawPanel.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Assigned(FOnKeyEvent) then FOnKeyEvent(Self, kkKeyDown, Shift, Key);
end;

procedure TUdDrawPanel.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Assigned(FOnKeyEvent) then FOnKeyEvent(Self, kkKeyUp, Shift, Key);
end;

procedure TUdDrawPanel.KeyPress(var Key: Char);
var
  LWord: Word;
begin
  inherited;
  if FReadOnly then Exit; //======>>>>>
  
  LWord := Ord(Key);
  if Assigned(FOnKeyEvent) then FOnKeyEvent(Self, kkPress, [], LWord);
  Key := Char(LWord);
end;


procedure TUdDrawPanel.DblClick;
var
  LPnt: TPoint;
begin
  inherited;

  FDblClicking := True;

  GetCursorPos(LPnt);
  LPnt := ScreenToClient(LPnt);
  if Assigned(FOnDblClick) then FOnDblClick(Self, LPnt);
end;

procedure TUdDrawPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LPnt: TPoint;
  LAllowPopMenu: Boolean;
begin
  inherited;
  if FReadOnly then Exit; //======>>>>>

  if Self.CanFocus then Self.SetFocus;


  LAllowPopMenu := True;
  if Assigned(FOnGetCanPopMenu) then FOnGetCanPopMenu(Self, LAllowPopMenu);


  //if ( Assigned(PopupMenu) and (Button = mbRight) and (ssRight in Shift) ) then

  if (not Assigned(PopupMenu) or (not LAllowPopMenu) or (Button <> mbRight) or (not (ssRight in Shift)) ) then
  begin
    LPnt := Point(X, Y);
    if Assigned(FOnMouseEvent) then FOnMouseEvent(Self, mkMouseDown, Button, Shift, LPnt);
  end;

  if FDblClicking then FDblClicking := False;
end;

procedure TUdDrawPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LPnt: TPoint;
begin
  inherited;
  if FReadOnly then Exit; //======>>>>>
  
  if Self.CanFocus then Self.SetFocus; 

  LPnt := Point(X, Y);
  if Assigned(FOnMouseEvent) then FOnMouseEvent(Self, mkMouseMove, mbLeft, Shift, LPnt);

  FXCursor.ShowCursor(FCanvas, LPnt);
end;

procedure TUdDrawPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LPnt: TPoint;
begin
  inherited;
  if FReadOnly then Exit; //======>>>>>
  
  LPnt := Point(X, Y);  
  if Assigned(FOnMouseEvent) then FOnMouseEvent(Self, mkMouseUp, Button, Shift, LPnt);

  if FDblClicking then FDblClicking := False;
end;






//-------------------------------------------------------------------------------------------------


procedure TUdDrawPanel.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  PS: TPaintStruct;
begin
  DC := BeginPaint(Handle, PS);

  FBitmap.Lock();
  FBitmap.Canvas.Lock();
  try
    with FBitmap.Canvas do
    begin
      Pen.Style   := psClear;
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;

      FillRect(Self.ClientRect);
    end;

    if Assigned(FOnPaint) then FOnPaint(Self, FBitmap.Canvas);

    Windows.BitBlt(DC,
      PS.rcPaint.Left, PS.rcPaint.Top, PS.rcPaint.Right - PS.rcPaint.Left, PS.rcPaint.Bottom - PS.rcPaint.Top,
      FBitmap.Handle,
      PS.rcPaint.Left, PS.rcPaint.Top,
      SRCCOPY);

  finally
    FBitmap.Canvas.Unlock();
    FBitmap.Unlock();
  end;


//  Windows.StretchBlt(DC,
//    PS.rcPaint.Left, PS.rcPaint.Top, PS.rcPaint.Right - PS.rcPaint.Left, PS.rcPaint.Bottom - PS.rcPaint.Top,
//    FBitmap.Handle,
//    PS.rcPaint.Left, PS.rcPaint.Top, PS.rcPaint.Right - PS.rcPaint.Left, PS.rcPaint.Bottom - PS.rcPaint.Top,
//    SRCCOPY);

  if not FReadOnly then
  begin
    FCanvas.Lock;
    FCanvas.Handle := DC;
    try
      FXCursor.HideCursor(FCanvas);
    finally
      FCanvas.Handle := 0;
      FCanvas.Unlock;
    end;
  end;


  EndPaint(Handle, PS);
end;


procedure TUdDrawPanel.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if (TMessage(Message).wParam = TMessage(Message).lParam) then
     FillRect(Message.DC, ClientRect, Brush.Handle);

  Message.Result := 1;
end;

procedure TUdDrawPanel.WMMouseWheel(var AMessage: TWMMouseWheel);
begin
  inherited;

  if FReadOnly then Exit; //======>>>>>
  
  if Assigned(FOnMouseWheel) then
    FOnMouseWheel(Self, AMessage.Keys, AMessage.WheelDelta, AMessage.XPos, AMessage.YPos);
end;


procedure TUdDrawPanel.WMContextMenu(var Message: TWMContextMenu);
var
  LAllowPopMenu: Boolean;
begin
  LAllowPopMenu := True;
  if Assigned(FOnGetCanPopMenu) then FOnGetCanPopMenu(Self, LAllowPopMenu);

  if LAllowPopMenu then
  begin
    inherited;
  end;

end;





//-------------------------------------------------------------------------------------------------

function TUdDrawPanel.CreateControls: Boolean;
begin
  FBottomPanel := TWinControl.Create(Self);
  with FBottomPanel do
  begin
    Height := FScrollSize;
    Align := alBottom;
    ParentColor := False;
    BevelOuter  := bvNone;
    BevelInner  := bvNone;
    Ctl3D       := False;

    Parent := Self;    
  end;

  FRightPanel := TWinControl.Create(Self);
  with FRightPanel do
  begin
    Width := FScrollSize;
    Align := alRight;
    ParentColor := False;
    BevelOuter  := bvNone;
    BevelInner  := bvNone;
    Ctl3D       := False;

    Parent := Self;
  end;

  FCornerPanel := TWinControl.Create(FBottomPanel);
  with FCornerPanel do
  begin
    Width := FScrollSize - 1;
    Align := alRight;
    ParentColor := False;
    BevelOuter  := bvNone;
    BevelInner  := bvNone;
    Ctl3D       := False;

    Parent      := FBottomPanel;
  end;

  FLayoutTabs := TTabSet.Create(FBottomPanel);
  with FLayoutTabs do
  begin
    Width := DEF_TABS_WIDTH;
    Align := alLeft;
    TabHeight := FScrollSize;

    Style := tsOwnerDraw;
    SoftTop := True;

    AddLayoutTab(sLayoutMode);
    AddLayoutTab();
    AddLayoutTab();
    TabIndex := 0;

    Parent := FBottomPanel;
    OnChange := OnLayoutTabsChange;
    OnDrawTab := OnLayoutTabsCustomDraw;
  end;

  FScrSplitter := TSplitter.Create(FBottomPanel);
  with FScrSplitter do
  begin
    Tag := 0;
    Left := DEF_TABS_WIDTH + 1;
    Align := alLeft;
    Width := 6;
    Color := clBtnHighlight;
    ParentColor := False;
    Parent := FBottomPanel;
    OnMoved := OnScrSplitterMoved;
  end;

  FXScrollBar := TInnerScrollBar.Create(Self);
  FYScrollBar := TInnerScrollBar.Create(Self);

  with FYScrollBar do
  begin
    Tag := SB_VERT;
    TabStop := False;
    Align := alClient;
    Kind := sbVertical;
    Width := FScrollSize;
    Parent := FRightPanel;
    ParentColor := False;
    Visible := True;
    Cursor := crArrow;
    OnScroll := OnScrollBarScroll;
  end;

  with FXScrollBar do
  begin
    Tag := SB_HORZ;
    TabStop := False;
    Align := alClient;
    Kind := sbHorizontal;
    Height := FScrollSize;
    Parent := FBottomPanel;
    ParentColor := False;
    Visible := True;
    Cursor := crArrow;
    OnScroll := OnScrollBarScroll;
  end;

  Result := True;
end;


function TUdDrawPanel.LayoutControls: Boolean;
var
  LHorzVisible, LVertVisible: Boolean;
begin
  Result := False;
  if not Assigned(FRightPanel) or not Assigned(FBottomPanel) then Exit;

  LVertVisible := FRightPanel.Visible;
  LHorzVisible := FBottomPanel.Visible;

  FRightPanel.Visible := False;
  FBottomPanel.Visible := False;
  FCornerPanel.Visible := LVertVisible;

  FBottomPanel.Visible := LHorzVisible;
  FRightPanel.Visible := LVertVisible;

  Self.Invalidate;
  Result := True;
end;


procedure TUdDrawPanel.SetScrollBars(const AValue: TScrollStyle);
begin
  if FScrollBars <> AValue then
  begin
    FScrollBars := AValue;

    case FScrollBars of
      ssNone:
        begin
          FBottomPanel.Visible := False;
          FRightPanel.Visible := False;
        end;
      ssHorizontal:
        begin
          FBottomPanel.Visible := True;
          FRightPanel.Visible := False;
        end;
      ssVertical:
        begin
          FBottomPanel.Visible := False;
          FRightPanel.Visible := True;
        end;
      ssBoth:
        begin
          FBottomPanel.Visible := True;
          FRightPanel.Visible := True;
        end;
    end;
    LayoutControls;
  end;
end;



procedure TUdDrawPanel.OnScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
var
  LScrollBar: TScrollBar;
begin
  LScrollBar := TScrollBar(Sender);

  if Assigned(FOnScroll) then
    FOnScroll(Self, LScrollBar.Tag, ScrollCode, LScrollBar.Position);

{
  case LScrollBar.Tag of
    SB_HORZ: XAxis.Pan := -Round(LScrollBar.Position * XAxis.PixelPerValue);
    SB_VERT: YAxis.Pan := +Round(LScrollBar.Position * YAxis.PixelPerValue);
  end;

  StartAxisChangedTimer();
  DoAxisChange();
}
  Self.Invalidate;
end;

procedure TUdDrawPanel.OnCornerPanelClick(Sender: TObject);
begin
  //  Application.MessageBox('OnCornerPanelClick', 'TAxViewPort', MB_ICONINFORMATION or MB_OK)
end;


procedure TUdDrawPanel.OnScrSplitterMoved(Sender: TObject);
begin
  FScrSplitter.Tag := Self.Width;
end;

procedure TUdDrawPanel.OnLayoutTabsChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
begin
  if Assigned(F_OnTabChange) then F_OnTabChange(Sender, NewTab, AllowChange);
  if Assigned(FOnTabChange) then FOnTabChange(Sender, NewTab, AllowChange);
end;

{$IF COMPILERVERSION <= 15 }
type
  TTextFormats = (tfBottom, tfCalcRect, tfCenter, tfEditControl, tfEndEllipsis,
    tfPathEllipsis, tfExpandTabs, tfExternalLeading, tfLeft, tfModifyString,
    tfNoClip, tfNoPrefix, tfRight, tfRtlReading, tfSingleLine, tfTop,
    tfVerticalCenter, tfWordBreak);
  TTextFormat = set of TTextFormats;
  
procedure TextRectExt(ACanvas: TCanvas; var Rect: TRect; var Text: string;
  TextFormat: TTextFormat = []);
const
  cTextFormats: array[TTextFormats] of Integer =
  (DT_BOTTOM, DT_CALCRECT, DT_CENTER, DT_EDITCONTROL, DT_END_ELLIPSIS,
   DT_PATH_ELLIPSIS, DT_EXPANDTABS, DT_EXTERNALLEADING, DT_LEFT,
   DT_MODIFYSTRING, DT_NOCLIP, DT_NOPREFIX, DT_RIGHT, DT_RTLREADING,
   DT_SINGLELINE, DT_TOP, DT_VCENTER, DT_WORDBREAK);
var
  Format: Integer;
  F: TTextFormats;
begin
  Format := 0;
  for F := Low(TTextFormats) to High(TTextFormats) do
    if F in TextFormat then
      Format := Format or cTextFormats[F];
  DrawTextEx(ACanvas.Handle, PChar(Text), Length(Text), Rect, Format, nil);
  if tfModifyString in TextFormat then
    SetLength(Text, StrLen(PChar(Text)));
end;
{$IFEND}

procedure TUdDrawPanel.OnLayoutTabsCustomDraw(Sender: TObject; TabCanvas: TCanvas; R: TRect; Index: Integer; Selected: Boolean);
var
  S: string;
begin
  with TabCanvas do
  begin
    Inc(R.Top, 1);
    Inc(R.Left, 1);
    Inc(R.Right, 1);

    if Selected then
    begin
      Font.Color := clBlack;
    end
    else begin
      Font.Color := clGrayText;
    end;

    S := Trim(FLayoutTabs.Tabs[Index]);

  {$IF COMPILERVERSION <= 15 }
    TextRectExt(TabCanvas, R, S, [tfCenter, tfEndEllipsis, tfNoClip]);
  {$ELSE}
    TextRect(R, S, [tfCenter, tfEndEllipsis, tfNoClip]);
  {$IFEND}
  end;
end;



//-----------------------------------------------------------------------------------

procedure TUdDrawPanel.UpdateScroll(ABound: TRect2D; APan: TPoint2D; AScale: Float);
var
  LScrollMin, LScrollMax: Double;
  LLogWidth, LLogHeight, LPanValue: Double;

  procedure _UpdateScrollbar(AScrBar: TScrollBar);
  var
    LScrBarChange: TNotifyEvent;
  begin
    LScrBarChange := AScrBar.OnChange;
    try
      AScrBar.OnChange := nil;
      
      AScrBar.Min := Trunc(Max(-MaxInt + 1.0, Round(Min(LPanValue, LScrollMin))));
      AScrBar.Max := Trunc(Min(MaxInt -1.0, Round(Max(LPanValue, LScrollMax))));
      AScrBar.LargeChange := Min(MaxInt div 6, Round(LLogWidth / 6));
      AScrBar.SmallChange := Min(MaxInt div 50, Round(LLogWidth / 50));
      AScrBar.Position := Trunc(Min(MaxInt -1.0, Round(LPanValue)));
    finally
      AScrBar.OnChange := LScrBarChange;
    end;
  end;

begin
  LLogWidth := ABound.X2 - ABound.X1;
  LLogHeight := ABound.Y2 - ABound.Y1;

  if (LLogWidth  = 0) then LLogWidth := Self.Width   - (FScrollSize);
  if (LLogHeight = 0) then LLogHeight := Self.Height - (FScrollSize);

  LScrollMin := -LLogWidth * AScale / 100;
  LScrollMax := +LLogWidth * AScale / 100;
  if LScrollMin < -MAXLONG then LScrollMin := -MAXLONG;
  if LScrollMax > +MAXLONG then LScrollMax := +MAXLONG;
  LPanValue := -APan.X;

  _UpdateScrollbar(FXScrollBar);


  LScrollMin := -LLogHeight * AScale / 100;
  LScrollMax := +LLogHeight * AScale / 100;
  if LScrollMin < -MAXLONG then LScrollMin := -MAXLONG;
  if LScrollMax > +MAXLONG then LScrollMax := +MAXLONG;
  LPanValue := APan.Y; 

  _UpdateScrollbar(FYScrollBar);
end;




//-----------------------------------------------------------------------------------

function TUdDrawPanel.AddLayoutTab(ATabName: string = ''): Boolean;

  function _AutoTabName(): string;
  var
    I: Integer;
    N, M: Integer;
    LStr, LNum: string;
  begin
    M := 0;
    for I := 1 to FLayoutTabs.Tabs.Count - 1 do
    begin
      LStr := Trim(FLayoutTabs.Tabs[I]);

      if Pos(sLayoutName, LStr) = 1 then
      begin
        LNum := Copy(LStr, System.Length(sLayoutName) + 1, System.Length(LStr));
        if TryStrToInt(LNum, N) then
          if N > M then M := N;
      end;
    end;

    Result := sLayoutName + IntToStr(M + 1);
  end;
  
var
  LTabName: string;
begin
  LTabName := Trim(ATabName);
  if LTabName = '' then LTabName := _AutoTabName();
  LTabName := ' ' + LTabName + ' ';

  FLayoutTabs.Tabs.Add(LTabName);
  Result := True;
end;

function TUdDrawPanel.RemoveLayoutTab(ATabIndex: Integer): Boolean;
begin
  Result := False;

  //就是小于等于0 等于0的时候是Model 不能删除
  if (ATabIndex <= 0) or (ATabIndex >= FLayoutTabs.Tabs.Count) then Exit;  //=====>>>>

  FLayoutTabs.Tabs.Delete(ATabIndex);
  Result := True;
end;

function TUdDrawPanel.RenameLayoutTab(ATabIndex: Integer; ANewName: string): Boolean;
var
  I: Integer;
  LStr, LTabName: string;
begin
  Result := False;

  LTabName := Trim(ANewName);
  if LTabName = '' then Exit;

  //就是小于等于0 等于0的时候是Model 不能删除
  if (ATabIndex <= 0) or (ATabIndex >= FLayoutTabs.Tabs.Count) then Exit;  //=====>>>>

  for I := 0 to FLayoutTabs.Tabs.Count - 1 do
  begin
    LStr := Trim(FLayoutTabs.Tabs[I]);
    if LStr = LTabName then Exit; //=====>>>>
  end;

  FLayoutTabs.Tabs.Strings[ATabIndex] := ANewName;
  Result := True;
end;








end.