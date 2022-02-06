{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdUnitsFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,

  UdUnits;

type
  TUdUnitsForm = class(TForm)
    gpbLength: TGroupBox;
    gpbAngle: TGroupBox;
    lblLenUnit: TLabel;
    cbxLenUnit: TComboBox;
    lblLenPrecision: TLabel;
    cbxLenPrecision: TComboBox;
    lblAngUnit: TLabel;
    lblAngPrecision: TLabel;
    cbxAngPrecision: TComboBox;
    cbxAngUnit: TComboBox;
    ckbClockwise: TCheckBox;
    gpbSample: TGroupBox;
    btnCancel: TButton;
    btnOK: TButton;
    btnDirection: TButton;
    lblSampleLen: TLabel;
    lblSampleAng: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure cbxLenUnitSelect(Sender: TObject);
    procedure cbxLenPrecisionSelect(Sender: TObject);
    procedure cbxAngUnitSelect(Sender: TObject);
    procedure cbxAngPrecisionSelect(Sender: TObject);
    procedure ckbClockwiseClick(Sender: TObject);
    procedure btnDirectionClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    
  private
    FUnits: TUdUnits;
    FUnits2: TUdUnits;

  protected
    procedure SetUnits(const Value: TUdUnits);
    procedure UpdateSample();

  public
    property Units: TUdUnits read FUnits write SetUnits;
  end;


function ShowUnitsDialog(AUnits: TUdUnits): Boolean;
  

implementation

{$R *.dfm}

uses
  SysUtils, UdDocument, UdBaseAngleFrm;


type
  TFDocument = class(TUdDocument);


function ShowUnitsDialog(AUnits: TUdUnits): Boolean;
var
  LForm: TUdUnitsForm;
begin
  LForm := TUdUnitsForm.Create(nil);
  try
    LForm.Units := AUnits;
    Result := (LForm.ShowModal() = mrOK);
  finally
    LForm.Free;
  end;
end;




//=================================================================================================

procedure InitPrecisionCombox(AComboBox: TComboBox; AUnit: TUdLengthUnit; APrecision: Byte); overload;
var
  I: Integer;
begin
  AComboBox.Items.Clear();
  for I := 0 to 8 do
    AComboBox.Items.Add(RToS(0, AUnit, I));
  AComboBox.ItemIndex := APrecision;
end;

procedure InitPrecisionCombox(AComboBox: TComboBox; AUnit: TUdAngleUnit; APrecision: Byte); overload;
var
  I: Integer;
begin
  AComboBox.Items.Clear();
  for I := 0 to 8 do
    AComboBox.Items.Add(AngToS(0, AUnit, I));
  AComboBox.ItemIndex := APrecision;
end;
  

//=================================================================================================

procedure TUdUnitsForm.FormCreate(Sender: TObject);
begin
  FUnits := nil;
  FUnits2 := TUdUnits.Create();
end;

procedure TUdUnitsForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FUnits2) then FUnits2.Free;
  FUnits2 := nil;
end;

procedure TUdUnitsForm.FormShow(Sender: TObject);
begin
  Self.UpdateSample();
end;




procedure TUdUnitsForm.UpdateSample();
begin
  lblSampleLen.Caption := FUnits2.RealToStr(123.123456789);
  lblSampleAng.Caption := FUnits2.AngToStr(123.123456789);
end;

procedure TUdUnitsForm.SetUnits(const Value: TUdUnits);
begin
  FUnits := Value;
  if Assigned(FUnits) then FUnits2.Assign(FUnits);

  cbxLenUnit.ItemIndex := Ord(FUnits2.LenUnit);
  cbxAngUnit.ItemIndex := Ord(FUnits2.AngUnit);

  InitPrecisionCombox(cbxLenPrecision, FUnits2.LenUnit, FUnits2.LenPrecision);
  InitPrecisionCombox(cbxAngPrecision, FUnits2.AngUnit, FUnits2.AngPrecision);
end;




//--------------------------------------------------------------------


procedure TUdUnitsForm.cbxLenUnitSelect(Sender: TObject);
begin
  if not Assigned(FUnits2) then Exit; //=======>>>>
  
  FUnits2.LenUnit := TUdLengthUnit(cbxLenUnit.ItemIndex);
  InitPrecisionCombox(cbxLenPrecision, FUnits2.LenUnit, FUnits2.LenPrecision);

  Self.UpdateSample();
end;

procedure TUdUnitsForm.cbxLenPrecisionSelect(Sender: TObject);
begin
  if not Assigned(FUnits2) then Exit; //=======>>>>

  FUnits2.LenPrecision := cbxLenPrecision.ItemIndex;

  Self.UpdateSample();
end;



procedure TUdUnitsForm.cbxAngUnitSelect(Sender: TObject);
begin
  if not Assigned(FUnits2) then Exit; //=======>>>>
  
  FUnits2.AngUnit := TUdAngleUnit(cbxAngUnit.ItemIndex);
  InitPrecisionCombox(cbxAngPrecision, FUnits2.AngUnit, FUnits2.AngPrecision);

  Self.UpdateSample();
end;

procedure TUdUnitsForm.cbxAngPrecisionSelect(Sender: TObject);
begin
  if not Assigned(FUnits2) then Exit; //=======>>>>

  FUnits2.AngPrecision := cbxAngPrecision.ItemIndex;

  Self.UpdateSample();
end;

procedure TUdUnitsForm.ckbClockwiseClick(Sender: TObject);
begin
  if not Assigned(FUnits2) then Exit; //=======>>>>
  
  FUnits2.AngClockWise := ckbClockwise.Checked;

  Self.UpdateSample();
end;




//--------------------------------------------------------------------

procedure TUdUnitsForm.btnDirectionClick(Sender: TObject);
var
  LForm: TUdBaseAngleForm;
begin
  if not Assigned(FUnits2) then Exit; //=======>>>>

  LForm := TUdBaseAngleForm.Create(nil);
  try
    LForm.Angle := FUnits2.AngBase;
    if LForm.ShowModal() = mrOk then
    begin
      FUnits2.AngBase := LForm.Angle;
      Self.UpdateSample();
    end;
  finally
    LForm.Free;
  end;
end;

procedure TUdUnitsForm.btnOKClick(Sender: TObject);
var
  LOK: Boolean;
begin
  if not Assigned(FUnits) then Exit; //======>>>>
  
  if Assigned(FUnits.Document) then
    TUdDocument(FUnits.Document).BeginUndo('');
  try
    LOK := True;
    if Assigned(FUnits.Document) then
      LOK := TFDocument(FUnits.Document).RaiseBeforeModifyObject(FUnits.Document, 'Units');

    if LOK then
      FUnits.Assign(FUnits2);

    if LOK and Assigned(FUnits.Document) then
      TFDocument(FUnits.Document).RaiseAfterModifyObject(FUnits.Document, 'Units');
  finally
    if Assigned(FUnits.Document) then
      TUdDocument(FUnits.Document).EndUndo();
  end;
end;

procedure TUdUnitsForm.btnCancelClick(Sender: TObject);
begin
//
end;

end.