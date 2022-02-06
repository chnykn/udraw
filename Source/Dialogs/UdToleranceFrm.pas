{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdToleranceFrm;

interface

uses
  Classes, Controls, Forms,
  StdCtrls, ExtCtrls,

  UdShx, UdGdtSymbolPanel;

type
  TUdToleranceForm = class(TForm)
    gpbSym: TGroupBox;
    pnlSym1: TPanel;
    pnlSym2: TPanel;
    gpbTolerance1: TGroupBox;
    pnlTol11: TPanel;
    pnlTol12: TPanel;
    edtTol11: TEdit;
    edtTol12: TEdit;
    pnlMet11: TPanel;
    pnlMet12: TPanel;
    gpbTolerance2: TGroupBox;
    pnlTol21: TPanel;
    pnlTol22: TPanel;
    edtTol21: TEdit;
    edtTol22: TEdit;
    pnlMet21: TPanel;
    pnlMet22: TPanel;
    gpbDatum1: TGroupBox;
    edtDat11: TEdit;
    edtDat12: TEdit;
    pnlDat11: TPanel;
    pnlDat12: TPanel;
    gpbDatum2: TGroupBox;
    edtDat21: TEdit;
    edtDat22: TEdit;
    pnlDat21: TPanel;
    pnlDat22: TPanel;
    gpbDatum3: TGroupBox;
    edtDat31: TEdit;
    edtDat32: TEdit;
    pnlDat31: TPanel;
    pnlDat32: TPanel;
    edtHeight: TEdit;
    lblHeight: TLabel;
    edtDatID: TEdit;
    lblDatumID: TLabel;
    lblProTolZone: TLabel;
    pnlPTZ: TPanel;
    btnOK: TButton;
    btnCancel: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    FGdtShx: TUdShx;
//    FToleranceText: string;

    //-------------------------------
    FSymPanel1: TUdGdtSymbolPanel;
    FSymPanel2: TUdGdtSymbolPanel;

    //-------------------------------

    FTolPanel11: TUdGdtSymbolPanel;
    FTolPanel12: TUdGdtSymbolPanel;

    FMetPanel11: TUdGdtSymbolPanel;
    FMetPanel12: TUdGdtSymbolPanel;



    //-------------------------------

    FTolPanel21: TUdGdtSymbolPanel;
    FTolPanel22: TUdGdtSymbolPanel;

    FMetPanel21: TUdGdtSymbolPanel;
    FMetPanel22: TUdGdtSymbolPanel;


    //-------------------------------

    FDatPanel11: TUdGdtSymbolPanel;
    FDatPanel12: TUdGdtSymbolPanel;

    FDatPanel21: TUdGdtSymbolPanel;
    FDatPanel22: TUdGdtSymbolPanel;

    FDatPanel31: TUdGdtSymbolPanel;
    FDatPanel32: TUdGdtSymbolPanel;

    //-------------------------------

    FPTZPanel: TUdGdtSymbolPanel;

  protected
    procedure SetGdtShx(const AValue: TUdShx);

    procedure OnSymbolPanelClick(Sender: TObject);
    procedure OnMeterialPanelClick(Sender: TObject);
    procedure OnDiameterPanelClick(Sender: TObject);
    procedure OnPTZPanelClick(Sender: TObject);

    function GetToleranceText: string;
    procedure SetToleranceText(const AValue: string);
    
  public
    property GdtShx: TUdShx read FGdtShx write SetGdtShx;
    property ToleranceText: string read GetToleranceText write SetToleranceText;
    
  end;


implementation

{$R *.dfm}

uses

  UdTolerance, UdToleranceSymbolFrm;

procedure TUdToleranceForm.FormCreate(Sender: TObject);
begin
  FGdtShx := nil;
//  FToleranceText := '';

   //-------------------------------

  FSymPanel1 := TUdGdtSymbolPanel.Create(Self);
  FSymPanel1.Parent := pnlSym1;
  FSymPanel1.Align  := alClient;

  FSymPanel2 := TUdGdtSymbolPanel.Create(Self);
  FSymPanel2.Parent := pnlSym2;
  FSymPanel2.Align  := alClient;

  //-------------------------------

  FTolPanel11 := TUdGdtSymbolPanel.Create(Self);
  FTolPanel11.Parent := pnlTol11;
  FTolPanel11.Align  := alClient;

  FTolPanel12 := TUdGdtSymbolPanel.Create(Self);
  FTolPanel12.Parent := pnlTol12;
  FTolPanel12.Align  := alClient;


  FMetPanel11 := TUdGdtSymbolPanel.Create(Self);
  FMetPanel11.Parent := pnlMet11;
  FMetPanel11.Align  := alClient;

  FMetPanel12 := TUdGdtSymbolPanel.Create(Self);
  FMetPanel12.Parent := pnlMet12;
  FMetPanel12.Align  := alClient;



  //-------------------------------

  FTolPanel21 := TUdGdtSymbolPanel.Create(Self);
  FTolPanel21.Parent := pnlTol21;
  FTolPanel21.Align  := alClient;

  FTolPanel22 := TUdGdtSymbolPanel.Create(Self);
  FTolPanel22.Parent := pnlTol22;
  FTolPanel22.Align  := alClient;


  FMetPanel21 := TUdGdtSymbolPanel.Create(Self);
  FMetPanel21.Parent := pnlMet21;
  FMetPanel21.Align  := alClient;

  FMetPanel22 := TUdGdtSymbolPanel.Create(Self);
  FMetPanel22.Parent := pnlMet22;
  FMetPanel22.Align  := alClient;


  //-------------------------------

  FDatPanel11 := TUdGdtSymbolPanel.Create(Self);
  FDatPanel11.Parent := pnlDat11;
  FDatPanel11.Align  := alClient;

  FDatPanel12 := TUdGdtSymbolPanel.Create(Self);
  FDatPanel12.Parent := pnlDat12;
  FDatPanel12.Align  := alClient;


  FDatPanel21 := TUdGdtSymbolPanel.Create(Self);
  FDatPanel21.Parent := pnlDat21;
  FDatPanel21.Align  := alClient;

  FDatPanel22 := TUdGdtSymbolPanel.Create(Self);
  FDatPanel22.Parent := pnlDat22;
  FDatPanel22.Align  := alClient;


  FDatPanel31 := TUdGdtSymbolPanel.Create(Self);
  FDatPanel31.Parent := pnlDat31;
  FDatPanel31.Align  := alClient;

  FDatPanel32 := TUdGdtSymbolPanel.Create(Self);
  FDatPanel32.Parent := pnlDat32;
  FDatPanel32.Align  := alClient;


  //-------------------------------
  FPTZPanel := TUdGdtSymbolPanel.Create(Self);
  FPTZPanel.Parent := pnlPTZ;
  FPTZPanel.Align  := alClient;

end;

procedure TUdToleranceForm.FormDestroy(Sender: TObject);
begin
  FGdtShx := nil;

  //---------

  FSymPanel1.Free;
  FSymPanel2.Free;


  //---------

  FTolPanel11.Free;
  FTolPanel12.Free;

  FMetPanel11.Free;
  FMetPanel12.Free;



  //---------

  FTolPanel21.Free;
  FTolPanel22.Free;

  FMetPanel21.Free;
  FMetPanel22.Free;


  //---------

  FDatPanel11.Free;
  FDatPanel12.Free;

  FDatPanel21.Free;
  FDatPanel22.Free;

  FDatPanel31.Free;
  FDatPanel32.Free;


  //---------

  FPTZPanel.Free;
end;

procedure TUdToleranceForm.FormShow(Sender: TObject);
begin
  FSymPanel1.RefreshSymbol();
  FSymPanel2.RefreshSymbol();

  FSymPanel1.OnClick := OnSymbolPanelClick;
  FSymPanel2.OnClick := OnSymbolPanelClick;

  //---------

  FTolPanel11.RefreshSymbol();
  FTolPanel12.RefreshSymbol();

  FMetPanel11.RefreshSymbol();
  FMetPanel12.RefreshSymbol();


  FTolPanel11.OnClick := OnDiameterPanelClick;
  FTolPanel12.OnClick := OnDiameterPanelClick;

  FMetPanel11.OnClick := OnMeterialPanelClick;
  FMetPanel12.OnClick := OnMeterialPanelClick;



  //---------

  FTolPanel21.RefreshSymbol();
  FTolPanel22.RefreshSymbol();

  FMetPanel21.RefreshSymbol();
  FMetPanel22.RefreshSymbol();


  FTolPanel21.OnClick := OnDiameterPanelClick;
  FTolPanel22.OnClick := OnDiameterPanelClick;

  FMetPanel21.OnClick := OnMeterialPanelClick;
  FMetPanel22.OnClick := OnMeterialPanelClick;

  //---------

  FDatPanel11.RefreshSymbol;
  FDatPanel12.RefreshSymbol;

  FDatPanel21.RefreshSymbol;
  FDatPanel22.RefreshSymbol;

  FDatPanel31.RefreshSymbol;
  FDatPanel32.RefreshSymbol;


  FDatPanel11.OnClick := OnMeterialPanelClick;
  FDatPanel12.OnClick := OnMeterialPanelClick;

  FDatPanel21.OnClick := OnMeterialPanelClick;
  FDatPanel22.OnClick := OnMeterialPanelClick;

  FDatPanel31.OnClick := OnMeterialPanelClick;
  FDatPanel32.OnClick := OnMeterialPanelClick;


  //---------

  FPTZPanel.RefreshSymbol;
  FPTZPanel.OnClick := OnPTZPanelClick;

end;





procedure TUdToleranceForm.SetGdtShx(const AValue: TUdShx);
begin
  FGdtShx := AValue;

  FSymPanel1.GdtShx := FGdtShx;
  FSymPanel2.GdtShx := FGdtShx;


  FTolPanel11.GdtShx := FGdtShx;
  FTolPanel12.GdtShx := FGdtShx;

  FMetPanel11.GdtShx := FGdtShx;
  FMetPanel12.GdtShx := FGdtShx;


  FTolPanel21.GdtShx := FGdtShx;
  FTolPanel22.GdtShx := FGdtShx;

  FMetPanel21.GdtShx := FGdtShx;
  FMetPanel22.GdtShx := FGdtShx;


  FDatPanel11.GdtShx := FGdtShx;
  FDatPanel12.GdtShx := FGdtShx;

  FDatPanel21.GdtShx := FGdtShx;
  FDatPanel22.GdtShx := FGdtShx;

  FDatPanel31.GdtShx := FGdtShx;
  FDatPanel32.GdtShx := FGdtShx;

  FPTZPanel.GdtShx := FGdtShx;  
end;





//-----------------------------------------------------------------------------------

procedure TUdToleranceForm.OnSymbolPanelClick(Sender: TObject);
var
  LSymbolForm: TUdToleranceSymbolForm;
begin
  if Assigned(Sender) and Sender.InheritsFrom(TUdGdtSymbolPanel) then
  begin
    LSymbolForm := TUdToleranceSymbolForm.Create(nil);
    try
      LSymbolForm.Init(FGdtShx, tskSymbol);

      LSymbolForm.Symbol := TUdGdtSymbolPanel(Sender).Symbol;
      if LSymbolForm.ShowModal() = mrOk then
      begin
        TUdGdtSymbolPanel(Sender).Symbol := LSymbolForm.Symbol;
      end;
    finally
      LSymbolForm.Free;
    end;
  end;
end;


procedure TUdToleranceForm.OnMeterialPanelClick(Sender: TObject);
var
  LSymbolForm: TUdToleranceSymbolForm;
begin
  if Assigned(Sender) and Sender.InheritsFrom(TUdGdtSymbolPanel) then
  begin
    LSymbolForm := TUdToleranceSymbolForm.Create(nil);
    try
      LSymbolForm.Init(FGdtShx, tskMeterial);

      LSymbolForm.Symbol := TUdGdtSymbolPanel(Sender).Symbol;
      if LSymbolForm.ShowModal() = mrOk then
      begin
        TUdGdtSymbolPanel(Sender).Symbol := LSymbolForm.Symbol;
      end;
    finally
      LSymbolForm.Free;
    end;
  end;
end;

procedure TUdToleranceForm.OnDiameterPanelClick(Sender: TObject);
begin
  if Assigned(Sender) and Sender.InheritsFrom(TUdGdtSymbolPanel) then
  begin
    if TUdGdtSymbolPanel(Sender).Symbol = #0 then
      TUdGdtSymbolPanel(Sender).Symbol := 'n'
    else
      TUdGdtSymbolPanel(Sender).Symbol := #0;
  end;
end;


procedure TUdToleranceForm.OnPTZPanelClick(Sender: TObject);
begin
  if Assigned(Sender) and Sender.InheritsFrom(TUdGdtSymbolPanel) then
  begin
    if TUdGdtSymbolPanel(Sender).Symbol = #0 then
      TUdGdtSymbolPanel(Sender).Symbol := 'p'
    else
      TUdGdtSymbolPanel(Sender).Symbol := #0;
  end;
end;




//--------------------------------------------------------------------------------------


procedure TUdToleranceForm.SetToleranceText(const AValue: string);
var
  LData: TUdGeoTolData;
begin
  LData := StrToGeoTolData(AValue);

  FSymPanel1.Symbol  := LData.Sym1;
  FSymPanel2.Symbol  := LData.Sym2;



  FTolPanel11.Symbol := LData.Tol1.Dia1;
  FTolPanel12.Symbol := LData.Tol1.Dia2;

  FMetPanel11.Symbol := LData.Tol1.Mat1;
  FMetPanel12.Symbol := LData.Tol1.Mat2;

  edtTol11.Text      := LData.Tol1.Value1;
  edtTol12.Text      := LData.Tol1.Value2;



  FTolPanel21.Symbol := LData.Tol2.Dia1;
  FTolPanel22.Symbol := LData.Tol2.Dia2;

  FMetPanel21.Symbol := LData.Tol2.Mat1;
  FMetPanel22.Symbol := LData.Tol2.Mat2;

  edtTol21.Text      := LData.Tol2.Value1;
  edtTol22.Text      := LData.Tol2.Value2;



  FDatPanel11.Symbol := LData.Datum1.Mat1;
  FDatPanel12.Symbol := LData.Datum1.Mat2;

  FDatPanel21.Symbol := LData.Datum2.Mat1;
  FDatPanel22.Symbol := LData.Datum2.Mat2;

  FDatPanel31.Symbol := LData.Datum3.Mat1;
  FDatPanel32.Symbol := LData.Datum3.Mat2;

  edtDat11.Text      := LData.Datum1.Value1;
  edtDat12.Text      := LData.Datum1.Value2;

  edtDat21.Text      := LData.Datum2.Value1;
  edtDat22.Text      := LData.Datum2.Value2;

  edtDat31.Text      := LData.Datum3.Value1;
  edtDat32.Text      := LData.Datum3.Value2;


  edtHeight.Text     := LData.Height;
  FPTZPanel.Symbol   := LData.ProTolZone;


  edtDatID.Text      := LData.DatumId;
end;



function TUdToleranceForm.GetToleranceText: string;
var
  LData: TUdGeoTolData;
begin
  LData.Sym1          :=  FSymPanel1.Symbol  ;
  LData.Sym2          :=  FSymPanel2.Symbol  ;



  LData.Tol1.Dia1     :=  FTolPanel11.Symbol ;
  LData.Tol1.Dia2     :=  FTolPanel12.Symbol ;

  LData.Tol1.Mat1     :=  FMetPanel11.Symbol ;
  LData.Tol1.Mat2     :=  FMetPanel12.Symbol ;

  LData.Tol1.Value1   :=  edtTol11.Text      ;
  LData.Tol1.Value2   :=  edtTol12.Text      ;



  LData.Tol2.Dia1     :=  FTolPanel21.Symbol ;
  LData.Tol2.Dia2     :=  FTolPanel22.Symbol ;

  LData.Tol2.Mat1     :=  FMetPanel21.Symbol ;
  LData.Tol2.Mat2     :=  FMetPanel22.Symbol ;

  LData.Tol2.Value1   :=  edtTol21.Text      ;
  LData.Tol2.Value2   :=  edtTol22.Text      ;



  LData.Datum1.Mat1   :=  FDatPanel11.Symbol ;
  LData.Datum1.Mat2   :=  FDatPanel12.Symbol ;

  LData.Datum2.Mat1   :=  FDatPanel21.Symbol ;
  LData.Datum2.Mat2   :=  FDatPanel22.Symbol ;

  LData.Datum3.Mat1   :=  FDatPanel31.Symbol ;
  LData.Datum3.Mat2   :=  FDatPanel32.Symbol ;

  LData.Datum1.Value1 :=  edtDat11.Text      ;
  LData.Datum1.Value2 :=  edtDat12.Text      ;

  LData.Datum2.Value1 :=  edtDat21.Text      ;
  LData.Datum2.Value2 :=  edtDat22.Text      ;

  LData.Datum3.Value1 :=  edtDat31.Text      ;
  LData.Datum3.Value2 :=  edtDat32.Text      ;


  LData.Height        :=  edtHeight.Text     ;
  LData.ProTolZone    :=  FPTZPanel.Symbol   ;


  LData.DatumId       :=  edtDatID.Text      ;


  Result := GeoTolDataToStr(LData);
end;


end.