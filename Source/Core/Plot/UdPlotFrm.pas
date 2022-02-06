{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPlotFrm;

{$I UdDefs.inc}

interface

uses
  Windows, Classes, Graphics, Controls, Forms, Types,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,

  UdPlotConfig;

type
  TUdPlotForm = class(TForm)
    Label2               : TLabel;
    Label3               : TLabel;
    Label4               : TLabel;
    lblPaperSize: TLabel;
    gpbPrinterPlotter    : TGroupBox;
    gpbPageSize          : TGroupBox;
    gpbOrientation       : TGroupBox;
    cbxPrinter           : TComboBox;
    GroupBox1            : TGroupBox;

    cbxFileFormat        : TComboBox;
    ckbPlotFile          : TCheckBox;
    cbxPaperName         : TComboBox;

    edtCopyCount         : TEdit;
    udCopyCount          : TUpDown;
    btnPrinterProperties : TButton;
    btnPreview           : TButton;
    btnOK                : TButton;
    btnCancel            : TButton;
    btnApplyToLayout     : TButton;

    rdbPortrait          : TRadioButton;
    rdbLandscape         : TRadioButton;
    Image1               : TImage;
    Image2               : TImage;
    ckbScaleLineweights  : TCheckBox;
    ckbForceColorBlack   : TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure edtCopyCountKeyPress(Sender: TObject; var Key: Char);

    procedure cbxPrinterChange(Sender: TObject);
    procedure btnPrinterPropertiesClick(Sender: TObject);
    procedure ckbPlotFileClick(Sender: TObject);
    procedure cbxFileFormatClick(Sender: TObject);

    procedure cbxPaperNameChange(Sender: TObject);
    procedure rdbPortraitClick(Sender: TObject);

    procedure ckbScaleLineweightsClick(Sender: TObject);
    procedure ckbForceColorBlackClick(Sender: TObject);


    procedure btnPreviewClick(Sender: TObject);
    procedure btnApplyToLayoutClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edtCopyCountChange(Sender: TObject);


  private
    FConfig: TUdPlotConfig;
    FModelType: Boolean;

    FOnPreview: TUdPlotConfigEvent;
    FOnPickWindow: TNotifyEvent;
    FOnApplyToLayout: TUdPlotConfigEvent;


  protected
    procedure UpdateUI();

    procedure SetConfig(const AValue: TUdPlotConfig);
    procedure SetModelType(const AValue: Boolean);

  public
    property Config: TUdPlotConfig read FConfig write SetConfig;
    property ModelType: Boolean read FModelType write SetModelType;

    property OnPreview: TUdPlotConfigEvent read FOnPreview write FOnPreview;
    property OnPickWindow: TNotifyEvent read FOnPickWindow write FOnPickWindow;
    property OnApplyToLayout: TUdPlotConfigEvent read FOnApplyToLayout write FOnApplyToLayout;

  end;



implementation

{$R *.dfm}

uses
  SysUtils, UdPrinters;



procedure SetPrinterParams(var AConfig: TUdPlotConfig);   //; AIsView: Boolean = True
var
  N: Integer;
  LPrinter: TUdCustomPrinter;
begin
  if AConfig.PrinterName <> '' then
  begin
    N := GlobalPrinters.IndexOf(AConfig.PrinterName);
    if N >= 0 then GlobalPrinters.PrinterIndex := N;
  end;

  LPrinter := GlobalPrinters.Printer;
  if Assigned(LPrinter) then
  begin
    if AConfig.PrinterName <> LPrinter.Name then
      AConfig.PrinterName := LPrinter.Name;

    LPrinter.SetViewParams(AConfig.PaperSize, 0, 0, TUdPrinterOrientation(AConfig.Orientation));
  end;
end;



//================================================================================================


procedure TUdPlotForm.FormCreate(Sender: TObject);
begin
  InitPlotConfig(FConfig);
  if Assigned(GlobalPrinters.Printer) then
    FConfig.PrinterName := GlobalPrinters.Printer.Name;

  FModelType := False;

  SetPrinterParams(FConfig);
  UpdateUI();
end;

procedure TUdPlotForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TUdPlotForm.FormShow(Sender: TObject);
begin
//
end;




//-------------------------------------------------------------------------------


procedure TUdPlotForm.UpdateUI();
var
  I: Integer;
  LDefPapers: TStringDynArray;
  LPrinter: TUdCustomPrinter;
  LPaperWidth, LPaperHeight: Double;
begin
  cbxPrinter.Items.Assign(GlobalPrinters.Printers);
  cbxPrinter.ItemIndex := cbxPrinter.Items.IndexOf(FConfig.PrinterName);

  LPrinter := GlobalPrinters.Printer;

  if Assigned(LPrinter) then
  begin
    cbxPaperName.Items.Assign(LPrinter.Papers);
    cbxPaperName.ItemIndex := LPrinter.PaperSizeIndex(LPrinter.PaperSize);

    lblPaperSize.Caption := FloatToStr(LPrinter.PaperWidth) +  ' x ' + FloatToStr(LPrinter.PaperHeight) + ' mm';
  end
  else begin
    cbxPaperName.Items.Clear();
    LDefPapers := GetDefPaperNames();
    for I := 0 to Length(LDefPapers) - 1 do cbxPaperName.Items.Add(LDefPapers[I]);
    cbxPaperName.ItemIndex := LPrinter.PaperSizeIndex(LPrinter.PaperSize);

    GetPaperDimensions(FConfig.PaperSize, LPaperWidth, LPaperHeight);

    if FConfig.Orientation = 0 then
      lblPaperSize.Caption := IntToStr(Round(LPaperWidth/10)) + ' x ' + IntToStr(Round(LPaperHeight/10)) + ' mm'
    else
      lblPaperSize.Caption := IntToStr(Round(LPaperHeight/10)) + ' x ' + IntToStr(Round(LPaperWidth/10)) + ' mm'
  end;

  edtCopyCount.Text := IntToStr(FConfig.CopiesNumber);

  rdbPortrait.Checked  := FConfig.Orientation = 0;
  rdbLandscape.Checked := FConfig.Orientation <> 0;
  Image1.Visible := FConfig.Orientation = 0;
  Image2.Visible := FConfig.Orientation = 1;


  ckbScaleLineweights.Checked := FConfig.ScaleLineweights;
  ckbForceColorBlack.Checked  := FConfig.ForceColorBlock;
end;


procedure TUdPlotForm.SetConfig(const AValue: TUdPlotConfig);
begin
  FConfig := AValue;

  SetPrinterParams(FConfig);
  Self.UpdateUI();
end;

procedure TUdPlotForm.SetModelType(const AValue: Boolean);
begin
  FModelType := AValue;
  case FModelType of
    True : btnApplyToLayout.Caption := '< 拾取窗口';
    False: btnApplyToLayout.Caption := '应用到布局';
  end;
  btnApplyToLayout.Tag := Integer(FModelType);
end;


//-------------------------------------------------------------------------------

procedure TUdPlotForm.cbxPrinterChange(Sender: TObject);
begin
  GlobalPrinters.PrinterIndex := cbxPrinter.ItemIndex;

  if Assigned(GlobalPrinters.Printer) then
    FConfig.PrinterName := GlobalPrinters.Printer.Name
  else
    FConfig.PrinterName := '';

  SetPrinterParams(FConfig);
  UpdateUI();
end;


procedure TUdPlotForm.btnPrinterPropertiesClick(Sender: TObject);
var
  LPrinter: TUdCustomPrinter;
begin
  LPrinter := GlobalPrinters.Printer;
  if Assigned(LPrinter) then LPrinter.PropertiesDlg();
end;



procedure TUdPlotForm.ckbPlotFileClick(Sender: TObject);
begin
  FConfig.PlotToFile := ckbPlotFile.Checked;
  cbxFileFormat.Enabled := ckbPlotFile.Checked;
end;



procedure TUdPlotForm.cbxFileFormatClick(Sender: TObject);
begin
  if cbxFileFormat.ItemIndex >= 0 then
    FConfig.FileFormat := TUdPlotImageFormat(cbxFileFormat.ItemIndex);
end;



//-------------------------------------------------------------------------------

procedure TUdPlotForm.cbxPaperNameChange(Sender: TObject);
begin
  FConfig.PaperSize := Integer(cbxPaperName.Items.Objects[cbxPaperName.ItemIndex]);
  SetPrinterParams(FConfig);
  Self.UpdateUI();
end;


procedure TUdPlotForm.rdbPortraitClick(Sender: TObject);
begin
  FConfig.Orientation := TComponent(Sender).Tag;
  SetPrinterParams(FConfig);
  Self.UpdateUI();
end;


procedure TUdPlotForm.ckbScaleLineweightsClick(Sender: TObject);
begin
  FConfig.ScaleLineweights := ckbScaleLineweights.Checked;
end;


procedure TUdPlotForm.ckbForceColorBlackClick(Sender: TObject);
begin
  FConfig.ForceColorBlock := ckbForceColorBlack.Checked;
end;


procedure TUdPlotForm.edtCopyCountKeyPress(Sender: TObject; var Key: Char);
begin
{$IFDEF D2010UP}
  if not CharInSet(Key, ['0'..'9', #8]) then Key := #0;
{$ELSE}
  if not (Key in ['0'..'9', #8]) then Key := #0;
{$ENDIF}
  if (Key = #8) and (Length(edtCopyCount.Text) = 1) then Key := #0;
end;

procedure TUdPlotForm.edtCopyCountChange(Sender: TObject);
var
  N: Integer;
begin
  if TryStrToInt(edtCopyCount.Text, N) then
  begin
    if N <= 0 then
    begin
      N := 1;
      edtCopyCount.Text := '1';
    end;
    FConfig.CopiesNumber := N;
  end
end;





//-------------------------------------------------------------------------------


procedure TUdPlotForm.btnPreviewClick(Sender: TObject);
begin
  Self.Tag := 0;
  if Assigned(FOnPreview) then FOnPreview(Self, FConfig);
end;

procedure TUdPlotForm.btnApplyToLayoutClick(Sender: TObject);
begin
  if Boolean(btnApplyToLayout.Tag) then
  begin
    Self.Tag := 1;
    if Assigned(FOnPickWindow) then FOnPickWindow(Self);
  end
  else begin
    Self.Tag := 0;
    if Assigned(FOnApplyToLayout) then FOnApplyToLayout(Self, FConfig);
  end;
end;

procedure TUdPlotForm.btnCancelClick(Sender: TObject);
begin
  Self.Tag := 0;
  Self.ModalResult := mrCancel;
end;

procedure TUdPlotForm.btnOKClick(Sender: TObject);
var
  N: Integer;
begin
  if TryStrToInt(edtCopyCount.Text, N) then
  begin
    if N <= 0 then
    begin
      N := 1;
      edtCopyCount.Text := '1';
    end;
    FConfig.CopiesNumber := N
  end
  else begin
    MessageBox(Self.Handle, '"份数" 必须是正整数', '', MB_ICONWARNING or MB_OK);
    edtCopyCount.SetFocus;
    Exit; //=======>>>>>>
  end;

  if not FConfig.PlotToFile and not Assigned(GlobalPrinters.Printer) then
  begin
    MessageBox(Self.Handle, '没有选中打印机', '', MB_ICONWARNING or MB_OK);
    Exit; //=======>>>>>>
  end;

  Self.Tag := 0;
  Self.ModalResult := mrOk;
end;




end.