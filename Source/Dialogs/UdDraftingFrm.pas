{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDraftingFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,

  UdTypes, UdDrafting;

type
  TUdDraftingForm = class(TForm)
    PageControl1: TPageControl;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;    
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    ckbSnapOn: TCheckBox;
    ckbGridOn: TCheckBox;
    gpbSnap: TGroupBox;
    lblSnapX: TLabel;
    lblSnapY: TLabel;
    lblBaseX: TLabel;
    lblBaseY: TLabel;
    edtSnapX: TEdit;
    edtSnapY: TEdit;
    edtBaseX: TEdit;
    edtBaseY: TEdit;
    gpbGrid: TGroupBox;
    lblGridX: TLabel;
    lblGridY: TLabel;
    lblCountX: TLabel;
    lblCountY: TLabel;
    edtGridX: TEdit;
    edtGridY: TEdit;
    edtCountX: TEdit;
    edtCountY: TEdit;
    ckbPolarOn: TCheckBox;
    gpbPolarAngle: TGroupBox;
    lblIncAngle: TLabel;
    cbxIncAngle: TComboBox;
    ckbOSnapOn: TCheckBox;
    gpbOSnapModes: TGroupBox;
    ckbEndPoint: TCheckBox;
    ckbMidPoint: TCheckBox;
    ckbCenter: TCheckBox;
    ckbIntersect: TCheckBox;
    ckbQuadrant: TCheckBox;
    ckbNode: TCheckBox;
    ckbPerpend: TCheckBox;
    ckbNearest: TCheckBox;
    ckbInsertion: TCheckBox;
    btnSelectAll: TButton;
    btnClearAll: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure ckbSnapOnClick(Sender: TObject);
    procedure ckbGridOnClick(Sender: TObject);
    procedure ckbPolarOnClick(Sender: TObject);
    procedure ckbOSnapOnClick(Sender: TObject);
        
    procedure edtSnapXExit(Sender: TObject);
    procedure edtSnapYExit(Sender: TObject);
    procedure edtBaseXExit(Sender: TObject);
    procedure edtBaseYExit(Sender: TObject);
    procedure edtGridXExit(Sender: TObject);
    procedure edtGridYExit(Sender: TObject);
    procedure edtCountXExit(Sender: TObject);
    procedure edtCountYExit(Sender: TObject);
    
    procedure cbxIncAngleSelect(Sender: TObject);
    procedure cbxIncAngleExit(Sender: TObject);
    procedure ckbOSnaoModesClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);


  private
    FDrafting: TUdDrafting;
    FDrafting2: TUdDrafting;

  protected
    procedure SetDrafting(const AValue: TUdDrafting);
    
  public
    property Drafting: TUdDrafting read FDrafting write SetDrafting;
  end;




function ShowDraftingDialog(ADrafting: TUdDrafting): Boolean;

  
implementation

{$R *.dfm}

uses
  SysUtils,  UdDocument, UdGeo2D;   //




function ShowDraftingDialog(ADrafting: TUdDrafting): Boolean;
var
  LForm: TUdDraftingForm;
begin
  LForm := TUdDraftingForm.Create(nil);
  try
    LForm.Drafting := ADrafting;
    Result := (LForm.ShowModal() = mrOK);
  finally
    LForm.Free;
  end;
end;




  
//=================================================================================================
{ TUdDraftingForm }


procedure TUdDraftingForm.FormCreate(Sender: TObject);
begin
  FDrafting  := nil;
  FDrafting2 := TUdDrafting.Create();
end;

procedure TUdDraftingForm.FormDestroy(Sender: TObject);
begin
  FDrafting  := nil;
  
  if Assigned(FDrafting2) then FDrafting2.Free;
  FDrafting2 := nil;
end;

procedure TUdDraftingForm.FormShow(Sender: TObject);
begin
//
end;


//-----------------------------------------------------------------------------------

procedure TUdDraftingForm.SetDrafting(const AValue: TUdDrafting);
begin
  FDrafting := AValue;
  if Assigned(FDrafting) then FDrafting2.Assign(FDrafting);

  ckbSnapOn.Checked  := FDrafting2.SnapOn;
  ckbGridOn.Checked  := FDrafting2.GridOn;
  ckbOSnapOn.Checked := FDrafting2.OSnapOn;
  ckbPolarOn.Checked := FDrafting2.PolarOn;

  edtBaseX.Text := FloatToStr(FDrafting2.SnapGrid.Base.X);
  edtBaseY.Text := FloatToStr(FDrafting2.SnapGrid.Base.Y);
    
  edtSnapX.Text := FloatToStr(FDrafting2.SnapGrid.SnapSpace.X);
  edtSnapY.Text := FloatToStr(FDrafting2.SnapGrid.SnapSpace.Y);

  edtGridX.Text := FloatToStr(FDrafting2.SnapGrid.GridSpace.X);
  edtGridY.Text := FloatToStr(FDrafting2.SnapGrid.GridSpace.Y);

  edtCountX.Text := IntToStr(FDrafting2.SnapGrid.Count.X);
  edtCountY.Text := IntToStr(FDrafting2.SnapGrid.Count.Y);

  cbxIncAngle.Text := FloatToStr(FDrafting2.PolarTracking.IncAngle);

  ckbEndPoint.Checked  := FDrafting2.ObjectSnap.EndPoint ;
  ckbMidPoint.Checked  := FDrafting2.ObjectSnap.MidPoint ;
  ckbCenter.Checked    := FDrafting2.ObjectSnap.Center   ;
  ckbInsertion.Checked := FDrafting2.ObjectSnap.Insertion;
  ckbQuadrant.Checked  := FDrafting2.ObjectSnap.Quadrant ;
  ckbNode.Checked      := FDrafting2.ObjectSnap.Node     ;
  ckbPerpend.Checked   := FDrafting2.ObjectSnap.Perpend  ;
  ckbNearest.Checked   := FDrafting2.ObjectSnap.Nearest  ;
  ckbIntersect.Checked := FDrafting2.ObjectSnap.Intersect;
  //ckbTangent.Checked   := FDrafting.ObjectSnap.Tangent  ;
end;





//----------------------------------------------------------------------------------------


procedure TUdDraftingForm.ckbSnapOnClick(Sender: TObject);
begin
  FDrafting2.SnapOn := ckbSnapOn.Checked;
end;



procedure TUdDraftingForm.ckbGridOnClick(Sender: TObject);
begin
  FDrafting2.GridOn := ckbGridOn.Checked;
end;

procedure TUdDraftingForm.ckbPolarOnClick(Sender: TObject);
begin
  FDrafting2.PolarOn := ckbPolarOn.Checked;
end;

procedure TUdDraftingForm.ckbOSnapOnClick(Sender: TObject);
begin
  FDrafting2.OSnapOn := ckbOSnapOn.Checked;
end;




procedure TUdDraftingForm.edtSnapXExit(Sender: TObject);
var
  V: Double;
begin
  if TryStrToFloat(edtSnapX.Text, V) and (V > 0) then
    FDrafting2.SnapGrid.SnapSpace := Point2D(V, FDrafting2.SnapGrid.SnapSpace.Y)
  else
    edtSnapX.Text := FloatToStr(FDrafting2.SnapGrid.SnapSpace.X);
end;

procedure TUdDraftingForm.edtSnapYExit(Sender: TObject);
var
  V: Double;
begin
  if TryStrToFloat(edtSnapY.Text, V) and (V > 0) then
    FDrafting2.SnapGrid.SnapSpace := Point2D(FDrafting2.SnapGrid.SnapSpace.X, V)
  else
    edtSnapY.Text := FloatToStr(FDrafting2.SnapGrid.SnapSpace.Y);
end;


procedure TUdDraftingForm.edtBaseXExit(Sender: TObject);
var
  V: Double;
begin
  if TryStrToFloat(edtBaseX.Text, V) and (V > 0) then
    FDrafting2.SnapGrid.Base := Point2D(V, FDrafting2.SnapGrid.Base.Y)
  else
    edtBaseX.Text := FloatToStr(FDrafting2.SnapGrid.Base.X);
end;

procedure TUdDraftingForm.edtBaseYExit(Sender: TObject);
var
  V: Double;
begin
  if TryStrToFloat(edtBaseY.Text, V) and (V > 0) then
    FDrafting2.SnapGrid.Base := Point2D(FDrafting2.SnapGrid.Base.X, V)
  else
    edtBaseY.Text := FloatToStr(FDrafting2.SnapGrid.Base.Y);
end;



procedure TUdDraftingForm.edtGridXExit(Sender: TObject);
var
  V: Double;
begin
  if TryStrToFloat(edtSnapX.Text, V) and (V > 0) then
    FDrafting2.SnapGrid.GridSpace := Point2D(V, FDrafting2.SnapGrid.GridSpace.Y)
  else
    edtSnapX.Text := FloatToStr(FDrafting2.SnapGrid.GridSpace.X);
end;

procedure TUdDraftingForm.edtGridYExit(Sender: TObject);
var
  V: Double;
begin
  if TryStrToFloat(edtSnapY.Text, V) and (V > 0) then
    FDrafting2.SnapGrid.GridSpace := Point2D(FDrafting2.SnapGrid.GridSpace.X, V)
  else
    edtSnapY.Text := FloatToStr(FDrafting2.SnapGrid.GridSpace.Y);
end;


procedure TUdDraftingForm.edtCountXExit(Sender: TObject);
var
  V: Integer;
begin
  if TryStrToInt(edtCountX.Text, V) and (V > 0) then
    FDrafting2.SnapGrid.Count := Point(V, FDrafting2.SnapGrid.Count.Y)
  else
    edtCountX.Text := IntToStr(FDrafting2.SnapGrid.Count.X);
end;

procedure TUdDraftingForm.edtCountYExit(Sender: TObject);
var
  V: Integer;
begin
  if TryStrToInt(edtCountY.Text, V) and (V > 0) then
    FDrafting2.SnapGrid.Count := Point(V, FDrafting2.SnapGrid.Count.Y)
  else
    edtCountY.Text := IntToStr(FDrafting2.SnapGrid.Count.Y);
end;




procedure TUdDraftingForm.cbxIncAngleSelect(Sender: TObject);
var
  V: Double;
begin
  if TryStrToFloat(cbxIncAngle.Text, V) and (V > 0) then
    FDrafting2.PolarTracking.IncAngle := V
  else
    cbxIncAngle.Text := FloatToStr(FDrafting2.PolarTracking.IncAngle);
end;



procedure TUdDraftingForm.cbxIncAngleExit(Sender: TObject);
var
  V: Double;
begin
  if TryStrToFloat(cbxIncAngle.Text, V) and (V > 0) then
    FDrafting2.PolarTracking.IncAngle := V
  else
    cbxIncAngle.Text := FloatToStr(FDrafting2.PolarTracking.IncAngle);
end;




procedure TUdDraftingForm.ckbOSnaoModesClick(Sender: TObject);
begin
  with TCheckBox(Sender) do
  begin
    case Tag of
      0: FDrafting2.ObjectSnap.EndPoint  := Checked;
      1: FDrafting2.ObjectSnap.MidPoint  := Checked;
      2: FDrafting2.ObjectSnap.Center    := Checked;
      3: FDrafting2.ObjectSnap.Intersect := Checked;
      4: FDrafting2.ObjectSnap.Quadrant  := Checked;
      5: FDrafting2.ObjectSnap.Node      := Checked;
      6: FDrafting2.ObjectSnap.Perpend   := Checked;
      7: FDrafting2.ObjectSnap.Nearest   := Checked;
      8: FDrafting2.ObjectSnap.Insertion := Checked;
    end;
  end;
end;




//----------------------------------------------------------------------------------------

type
  TFDocument = class(TUdDocument);

procedure TUdDraftingForm.btnOKClick(Sender: TObject);
var
  LOK: Boolean;
begin
  if not Assigned(FDrafting) then Exit; //======>>>>
  
  if Assigned(FDrafting.Document) then
    TUdDocument(FDrafting.Document).BeginUndo('');
  try
    LOK := True;
    if Assigned(FDrafting.Document) then
      LOK := TFDocument(FDrafting.Document).RaiseBeforeModifyObject(FDrafting.Owner, 'Drafting');

    if LOK then
      FDrafting.Assign(FDrafting2);

    if LOK and Assigned(FDrafting.Document) then
      TFDocument(FDrafting.Document).RaiseAfterModifyObject(FDrafting.Owner, 'Drafting');
  finally
    if Assigned(FDrafting.Document) then
      TUdDocument(FDrafting.Document).EndUndo();
  end;
end;



end.