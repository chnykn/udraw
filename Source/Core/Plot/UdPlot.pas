{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPlot;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics, Controls, Forms,
  UdTypes, UdConsts, UdEvents, UdObject,

  UdLayout, UdPlotConfig, UdPlotFrm;

type
  TUdPlot = class(TObject)
  private
    FDocument: TUdObject;
    FLayout: TUdLayout;

    FPlotForm: TUdPlotForm;
    FPickWindowEvent: TUdPickWindowEvent;

  protected
    function CreatePlotLayout(AConfig: TUdPlotConfig; AScale: TPoint2D; AOffset: TPoint2D): TUdLayout;

    procedure OnPreviewFormPrint(Sender: TObject);
    procedure OnPlotFormPreview(Sender: TObject; AConfig: TUdPlotConfig);
    procedure OnPlotFormPickWindow(Sender: TObject);
    procedure OnPlotFormApplyToLayout(Sender: TObject; AConfig: TUdPlotConfig);

  public
    constructor Create(ADocument: TUdObject; ALayout: TUdLayout);
    destructor Destroy; override;

    function Print(AConfig: TUdPlotConfig): Boolean;
    function ExportFile(AConfig: TUdPlotConfig; AFileName: string): Boolean;

    procedure ShowForm(AConfig: PUdPlotConfig; APickWindowEvent: TUdPickWindowEvent);

  public
    property PlotForm: TUdPlotForm read FPlotForm;

  end;


implementation

uses
  SysUtils, Dialogs,
  UdGeo2D, UdMath, UdActionPickWindow, UdPrinters, UdPreviewFrm;


//==================================================================================================
{ TUdPlot }

constructor TUdPlot.Create(ADocument: TUdObject; ALayout: TUdLayout);
begin
  FDocument := ADocument;
  FLayout   := ALayout;
  FPlotForm := nil;
end;

destructor TUdPlot.Destroy;
begin
  if Assigned(FPlotForm) then FPlotForm.Free;
  FPlotForm := nil;

  inherited;
end;



//-------------------------------------------------------------------------------------------------

function TUdPlot.CreatePlotLayout(AConfig: TUdPlotConfig; AScale: TPoint2D; AOffset: TPoint2D): TUdLayout;
var
  LLayout: TUdLayout;
  LPlotWidth, LPlotHeight: Integer;
  LPaperWidth, LPaperHeight: Float;
begin
  Result := nil;
  if not Assigned(FLayout) then Exit; //========>>>>>

  LLayout := TUdLayout.Create(FDocument, False);

  if not FLayout.ModelType then
  begin
    LLayout.Assign(FLayout);
    LLayout.PlotConfig := AConfig;
  end
  else begin
    LLayout.PlotConfig := AConfig;
    LLayout.ModelType := False;
  end;

  LLayout.BackColor := clWhite;

  LPaperWidth  := Abs(LLayout.PaperLimMax.X - LLayout.PaperLimMin.X);
  LPaperHeight := Abs(LLayout.PaperLimMax.Y - LLayout.PaperLimMin.Y);

  LPlotWidth  := Round(LPaperWidth * AScale.X);
  LPlotHeight := Round(LPaperHeight * AScale.Y);

  LLayout.Axes.CalcAxis(LPlotWidth, LPlotHeight,
    Rect2D(AOffset.X, -AOffset.Y, LPaperWidth + AOffset.X, LPaperHeight - AOffset.Y));

  if Assigned(LLayout.ViewPort) then LLayout.ViewPort.UpdateAxes();

  LLayout.UpdateVisibleList();

  Result := LLayout;
end;


function TUdPlot.Print(AConfig: TUdPlotConfig): Boolean;
var
  N: Integer;
  LFlag: Cardinal;
  LLayout: TUdLayout;
  LPrinter: TUdCustomPrinter;
  LScale, LOffset: TPoint2D;
begin
  Result := False;

  if not Assigned(FLayout) then Exit; //========>>>>>
  if not GlobalPrinters.HasPhysicalPrinters then Exit; //========>>>>>

  N := GlobalPrinters.IndexOf(AConfig.PrinterName);
  LPrinter := UdPrinters.GlobalPrinters.Items[N];
  if not Assigned(LPrinter) then LPrinter := UdPrinters.GlobalPrinters.Printer;
  if not Assigned(LPrinter) then Exit; //=====>>>>>>


  LScale  := Point2D((LPrinter.DPI.X / 25.4), (LPrinter.DPI.X / 25.4));
  LOffset := Point2D(LPrinter.LeftMargin, LPrinter.TopMargin);

  LLayout := CreatePlotLayout(AConfig, LScale, LOffset);
  if not Assigned(LLayout) then Exit;  //=====>>>>>>

  LPrinter.SetPrintParams(AConfig.PaperSize, 0, 0, TUdPrinterOrientation(AConfig.Orientation),
                          DMBIN_AUTO, 0, AConfig.CopiesNumber);

  LPrinter.BeginDoc();
  LPrinter.BeginPage();
  try
    LFlag := PRINT_PAINT;
    if AConfig.ForceColorBlock then LFlag := LFlag or BLACK_PAINT;

    LLayout.Paint(LLayout, LPrinter.Canvas, LFlag);
  finally
    LPrinter.EndPage();
    LPrinter.EndDoc();
    LLayout.Free();
  end;
end;

function TUdPlot.ExportFile(AConfig: TUdPlotConfig; AFileName: string): Boolean;
var
  LFlag: Cardinal;
  LLayout: TUdLayout;
  LExportBitmap: TBitmap;
  LPixelsPerMM: Float;
begin
  Result := False;
  if not Assigned(FLayout) then Exit; //========>>>>>


  LPixelsPerMM := Screen.PixelsPerInch / 25.4;
  LLayout := CreatePlotLayout(AConfig, Point2D(LPixelsPerMM, LPixelsPerMM), Point2D(0, 0));
  if not Assigned(LLayout) then Exit;   //=====>>>>>>

  LExportBitmap := TBitmap.Create;
  try
    LFlag := PRINT_PAINT;
    if AConfig.ForceColorBlock then LFlag := LFlag or BLACK_PAINT;

    LExportBitmap.Width  := Round(LLayout.Axes.XSize);
    LExportBitmap.Height := Round(LLayout.Axes.YSize);

    with LExportBitmap do
    begin
      Canvas.Pen.Style := psClear;
      Canvas.Brush.Color := clWhite;
      Canvas.Brush.Style := bsSolid;
      Canvas.FillRect(Rect(0, 0, Width, Height));
    end;

    LLayout.Paint(LLayout, LExportBitmap.Canvas, LFlag);

    LExportBitmap.SaveToFile(AFileName);
  finally
    LExportBitmap.Free;
    LLayout.Free();
  end;
end;





//-------------------------------------------------------------------------------------------------

procedure TUdPlot.OnPreviewFormPrint(Sender: TObject);
begin
  if Assigned(FPlotForm) then
    Self.Print(FPlotForm.Config);
end;

procedure TUdPlot.OnPlotFormPreview(Sender: TObject; AConfig: TUdPlotConfig);
var
  LLayout: TUdLayout;
  LPreviewForm: TUdPreviewForm;
begin
  LLayout := CreatePlotLayout(AConfig, Point2D(1, 1), Point2D(0, 0));
  LPreviewForm := TUdPreviewForm.Create(nil);
  try
    LPreviewForm.Layout := LLayout;
    LPreviewForm.OnPrint := OnPreviewFormPrint;
    LPreviewForm.ShowModal();
  finally
    LPreviewForm.Free();
    LLayout.Free;
  end;
end;

procedure TUdPlot.OnPlotFormPickWindow(Sender: TObject);
begin
  FPlotForm.Close();

  if Assigned(FLayout) then
  begin
    FLayout.RemoveAllSelected();
    FLayout.ActionClear();
    FLayout.ActionAdd(TUdActionPickWindow);

    TUdActionPickWindow(FLayout.ActiveAction).OnPickWindow := FPickWindowEvent;
  end;
end;

procedure TUdPlot.OnPlotFormApplyToLayout(Sender: TObject; AConfig: TUdPlotConfig);
begin
  if Assigned(FLayout) and FLayout.InheritsFrom(TUdLayout) then
  begin
    FLayout.PlotConfig := AConfig;
  end;
end;


procedure TUdPlot.ShowForm(AConfig: PUdPlotConfig; APickWindowEvent: TUdPickWindowEvent);
var
  LDialog: TSaveDialog;
  LFileFormat: string;
begin
  if not Assigned(FLayout) then Exit; //========>>>>>

  FPickWindowEvent := APickWindowEvent;

  if not Assigned(FPlotForm) then
  begin
    FPlotForm := TUdPlotForm.Create(nil);
    FPlotForm.ModelType := FLayout.ModelType;
    if Assigned(AConfig) then FPlotForm.Config := AConfig^;

    FPlotForm.OnPreview := OnPlotFormPreview;
    FPlotForm.OnPickWindow := OnPlotFormPickWindow;
    FPlotForm.OnApplyToLayout := OnPlotFormApplyToLayout;
  end;

  if FPlotForm.ShowModal() = mrOk then
  begin
    if FPlotForm.Config.PlotToFile then
    begin
      case FPlotForm.Config.FileFormat of
        pifBmp: LFileFormat := 'BMP';
        pifJpg: LFileFormat := 'JPG';
      end;

      LDialog := TSaveDialog.Create(nil);
      try
        LDialog.DefaultExt := LFileFormat;
        LDialog.Filter := LFileFormat + '(*.' + LFileFormat + ')' + '|' + '*.' + LFileFormat;
        if LDialog.Execute({$IF COMPILERVERSION > 15 } FPlotForm.Handle {$IFEND}) then
          Self.ExportFile(FPlotForm.Config, LDialog.FileName);
      finally
        LDialog.Free;
      end;
    end
    else
      Self.Print(FPlotForm.Config);
  end;
end;








end.