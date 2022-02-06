unit UdPreviewFrm;

interface

uses
  Windows, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls, Buttons,

  UdTypes, UdConsts, UdEvents, 
  UdLayout, UdDrawPanel;

type
  TUdPreviewForm = class(TForm)
    pnlTop: TPanel;
    pnlClient: TPanel;
    btnPrint: TSpeedButton;
    btnPan: TSpeedButton;
    btnZoomReal: TSpeedButton;
    btnZoomWindow: TSpeedButton;
    btnZoomOrg: TSpeedButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnPanClick(Sender: TObject);
    procedure btnZoomRealClick(Sender: TObject);
    procedure btnZoomWindowClick(Sender: TObject);
    procedure btnZoomOrgClick(Sender: TObject);

  private
    FDrawPanel: TUdDrawPanel;
    FLayout: TUdLayout;

    FFormShowed: Boolean;

    FOnPrint: TNotifyEvent;

  protected
    procedure SetLayout(const AValue: TUdLayout);

    procedure OnDrawPanelPaint(Sender: TObject; ACanvas: TCanvas);
    procedure OnDrawPanelKeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; var AKey: Word);
    procedure OnDrawPanelMouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState; var APoint: TPoint);
    procedure OnDrawPanelMouseWheel(Sender: TObject; AKeys, AWheelDelta, XPos, YPos: Smallint);
    procedure OnDrawPanelResized(Sender: TObject);

    procedure ZoomOriginal();

  public
    property Layout: TUdLayout read FLayout write SetLayout;
    property OnPrint: TNotifyEvent read FOnPrint write FOnPrint;

  end;



implementation

{$R *.dfm}

uses
  Dialogs, UdMath,
  UdActionPan, UdActionZoom;


type
  TFDrawPanel = class(TUdDrawPanel);

//==================================================================================================


procedure TUdPreviewForm.FormCreate(Sender: TObject);
begin
  FLayout := nil;

  FDrawPanel := TUdDrawPanel.Create(nil);
  FDrawPanel.Parent := pnlClient;
  FDrawPanel.XCursor.SysCursor := True;
  FDrawPanel.ScrollBars := ssNone;
  FDrawPanel.Align := alClient;

  FFormShowed := False;
  Self.SetBounds(Round(Screen.Width * 0.1), Round(Screen.Height * 0.05),
                 Round(Screen.Width * 0.85), Round(Screen.Height * 0.85));
end;

procedure TUdPreviewForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FDrawPanel) then FDrawPanel.Free;
  FDrawPanel := nil;

  FLayout := nil;
end;

procedure TUdPreviewForm.FormShow(Sender: TObject);
begin
  TFDrawPanel(FDrawPanel)._OnPaint      := OnDrawPanelPaint;
  TFDrawPanel(FDrawPanel)._OnMouseEvent := OnDrawPanelMouseEvent;
  TFDrawPanel(FDrawPanel)._OnMouseWheel := OnDrawPanelMouseWheel;
  TFDrawPanel(FDrawPanel)._OnResized    := OnDrawPanelResized;

  Self.ZoomOriginal();
  FFormShowed := True;
end;



//---------------------------------------------------------------------------------


procedure TUdPreviewForm.OnDrawPanelPaint(Sender: TObject; ACanvas: TCanvas);
begin
  if Assigned(FLayout) then
    FLayout.Paint(Sender, ACanvas, PRINT_PAINT);
end;

procedure TUdPreviewForm.OnDrawPanelKeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; var AKey: Word);
begin
  if Assigned(FLayout) then
    FLayout.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdPreviewForm.OnDrawPanelMouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState; var APoint: TPoint);
begin
  if Assigned(FLayout) then
    FLayout.MouseEvent(Sender, AKind, AButton, AShift, APoint);
end;

procedure TUdPreviewForm.OnDrawPanelMouseWheel(Sender: TObject; AKeys, AWheelDelta, XPos, YPos: Smallint);
begin
  if Assigned(FLayout) then
    FLayout.MouseWheel(Sender, AKeys, AWheelDelta, XPos, YPos);
end;

procedure TUdPreviewForm.OnDrawPanelResized(Sender: TObject);
begin
  if Assigned(FLayout) and FFormShowed then
    FLayout.Resize(FDrawPanel.Width, FDrawPanel.Height);
end;



procedure TUdPreviewForm.SetLayout(const AValue: TUdLayout);
begin
  if (FLayout <> AValue) and Assigned(AValue) then
  begin
    FLayout := AValue;

    FLayout.GridOn := False;
    FLayout.SnapOn := False;
    FLayout.OSnapOn := False;
    FLayout.OrthoOn := False;

    FLayout.BackColor := clAppWorkSpace;
    FLayout.DrawPanel := FDrawPanel;
    FLayout.Previewing := True;
  end;
end;

procedure TUdPreviewForm.ZoomOriginal();
begin
  if not Assigned(FLayout) then Exit; //======>>>>

  FLayout.Resize(FDrawPanel.Width, FDrawPanel.Height);
  FLayout.ZoomExtends();
  FLayout.ZoomScale(90);
end;




//---------------------------------------------------------------------------------------

procedure TUdPreviewForm.btnPrintClick(Sender: TObject);
begin
  if Assigned(FOnPrint) then FOnPrint(Self);
end;


procedure TUdPreviewForm.btnPanClick(Sender: TObject);
begin
  FLayout.ActionClear();
  FLayout.ActionAdd(TUdActionPanReal);
end;


procedure TUdPreviewForm.btnZoomRealClick(Sender: TObject);
begin
  FLayout.ActionClear();
  FLayout.ActionAdd(TUdActionZoom, 'real');
end;

procedure TUdPreviewForm.btnZoomWindowClick(Sender: TObject);
begin
  FLayout.ActionClear();
  FLayout.ActionAdd(TUdActionZoom, 'window');
end;


procedure TUdPreviewForm.btnZoomOrgClick(Sender: TObject);
begin
  ZoomOriginal();
end;



end.