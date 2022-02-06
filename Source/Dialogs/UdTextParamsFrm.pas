{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdTextParamsFrm;

interface

uses
  Windows, Classes, Graphics, Controls, Forms, StdCtrls, Buttons,

  UdTypes, UdText;

type
  TUdTextParamsForm = class(TForm)
    lblTextContents: TLabel;
    memText: TMemo;
    lblHeight: TLabel;
    lblRotation: TLabel;
    lblWidthFactor: TLabel;
    lblAlignment: TLabel;
    lblTextStyle: TLabel;
    edtHeight: TEdit;
    edtRotation: TEdit;
    edtWidthFactor: TEdit;
    cbxAlignment: TComboBox;
    cbxTextStyle: TComboBox;
    gpbInsPoint: TGroupBox;
    ckxSpcHeight: TCheckBox;
    ckxSpcRotation: TCheckBox;
    ckxSpcPoint: TCheckBox;
    lblX: TLabel;
    lblY: TLabel;
    edtX: TEdit;
    edtY: TEdit;
    ckxUpsidedown: TCheckBox;
    ckxBackward: TCheckBox;
    btnOk: TButton;
    btnCancel: TButton;
    btnEditTextStyles: TSpeedButton;
    procedure ckxSpcHeightClick(Sender: TObject);
    procedure ckxSpcRotationClick(Sender: TObject);
    procedure ckxSpcPointClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnEditTextStylesClick(Sender: TObject);

  private
    FTextObj: TUdText;
    FDocument: TObject;

  protected
    procedure SetDocument(const AValue: TObject);
    procedure SetTextObj(const AValue: TUdText);
    
  public
    property TextObj: TUdText read FTextObj write SetTextObj;
    property Document: TObject read FDocument write SetDocument;

  end;


function ShowTextParamsForm(ADoc: TObject; AText: TUdText; var AHeighted, ARotated, APositioned: Boolean; ACaption: string = 'New Text Object'): Boolean;

implementation

{$R *.dfm}

uses
  SysUtils,
  UdDocument, UdTextStyle, UdGeo2D, UdTextStylesFrm;




//==================================================================================================


function ShowTextParamsForm(ADoc: TObject; AText: TUdText; var AHeighted, ARotated, APositioned: Boolean; ACaption: string = 'New Text Object'): Boolean;
var
  LForm: TUdTextParamsForm;
begin
  Result := False;
  
  LForm := TUdTextParamsForm.Create(nil);
  try
    LForm.Document := ADoc;
    LForm.TextObj := AText;

    if LForm.ShowModal = mrOK then
    begin
      AHeighted  := not LForm.ckxSpcHeight.Checked;
      ARotated   := not LForm.ckxSpcRotation.Checked;
      APositioned := not LForm.ckxSpcPoint.Checked;

      Result := True;
    end;
  finally
    LForm.Free;
  end;
end;



//=================================================================================================

procedure TUdTextParamsForm.FormCreate(Sender: TObject);
begin
  FTextObj := nil;
  FDocument := nil;
end;

procedure TUdTextParamsForm.FormDestroy(Sender: TObject);
begin
  FTextObj := nil;
  FDocument := nil;
end;




procedure TUdTextParamsForm.SetDocument(const AValue: TObject);
var
  I: Integer;
  LTextStyle: TUdTextStyle;
begin
  if Assigned(AValue) and AValue.InheritsFrom(TUdDocument) then
  begin;
    FDocument := AValue;

    cbxTextStyle.Clear();
    
    for I := 0 to TUdDocument(FDocument).TextStyles.Count - 1 do
    begin
      LTextStyle := TUdDocument(FDocument).TextStyles.Items[I];
      cbxTextStyle.Items.AddObject(LTextStyle.Name, LTextStyle);
    end;

    cbxTextStyle.ItemIndex := TUdDocument(FDocument).TextStyles.GetActiveIndex();
  end;
end;


procedure TUdTextParamsForm.SetTextObj(const AValue: TUdText);
begin
  FTextObj := AValue;
  if Assigned(FTextObj) then
  begin
    memText.Text := FTextObj.Contents;
    edtHeight.Text := FormatFloat('0.0###', FTextObj.Height);
    edtRotation.Text := FormatFloat('0.0###', FTextObj.Rotation);
    edtWidthFactor.Text := FormatFloat('0.0###', FTextObj.WidthFactor);
    edtX.Text := FormatFloat('0.0###', FTextObj.Position.X);
    edtY.Text := FormatFloat('0.0###', FTextObj.Position.Y);

    if Assigned(FTextObj.TextStyle) then
      cbxTextStyle.Text := FTextObj.TextStyle.Name;
  end;
end;

procedure TUdTextParamsForm.btnEditTextStylesClick(Sender: TObject);
var
  I: Integer;
  LTextStyle: TUdTextStyle;
begin
  if Assigned(FDocument) then
  begin
    if UdTextStylesFrm.ShowTextStylesDialog(TUdDocument(FDocument).TextStyles) then
    begin
      cbxTextStyle.Clear();
      
      for I := 0 to TUdDocument(FDocument).TextStyles.Count - 1 do
      begin
        LTextStyle := TUdDocument(FDocument).TextStyles.Items[I];
        cbxTextStyle.Items.AddObject(LTextStyle.Name, LTextStyle);
      end;

      cbxTextStyle.ItemIndex := TUdDocument(FDocument).TextStyles.GetActiveIndex();
    end;
  end;
end;



procedure TUdTextParamsForm.ckxSpcHeightClick(Sender: TObject);
begin
  edtHeight.Enabled := not ckxSpcHeight.Checked;
  if edtHeight.Enabled then edtHeight.Color := clWindow else edtHeight.Color := clBtnFace;
end;

procedure TUdTextParamsForm.ckxSpcRotationClick(Sender: TObject);
begin
  edtRotation.Enabled := not ckxSpcRotation.Checked;
  if edtRotation.Enabled then edtRotation.Color := clWindow else edtRotation.Color := clBtnFace;
end;

procedure TUdTextParamsForm.ckxSpcPointClick(Sender: TObject);
begin
  edtX.Enabled := not ckxSpcPoint.Checked;
  edtY.Enabled := not ckxSpcPoint.Checked;

  if edtX.Enabled then edtX.Color := clWindow else edtX.Color := clBtnFace;
  if edtY.Enabled then edtY.Color := clWindow else edtY.Color := clBtnFace;
end;



procedure TUdTextParamsForm.btnOkClick(Sender: TObject);
var
  LTxtHeight, LTxtRotation, LX, LY, LWF: Double;
begin
  if Assigned(FTextObj) then
  begin
    if not ckxSpcHeight.Checked then
    begin
      if not TryStrToFloat(edtHeight.Text, LTxtHeight) or (LTxtHeight <= 0.0) then
      begin
        MessageBox(Self.Handle, 'Height must be number and > 0!', '提示', MB_ICONWARNING or MB_OK);
        Exit; //=========>>>>
      end
      else
        FTextObj.Height := LTxtHeight;
    end;

    if not ckxSpcRotation.Checked and edtRotation.Enabled then
    begin
      if not TryStrToFloat(edtRotation.Text, LTxtRotation) then
      begin
        MessageBox(Self.Handle, '旋转角度必须是数值!', '提示', MB_ICONWARNING or MB_OK);
        Exit; //=========>>>>
      end
      else
        FTextObj.Rotation := LTxtRotation;
    end;

    if not ckxSpcPoint.Checked and edtX.Enabled and edtY.Enabled then
    begin
      if not TryStrToFloat(edtX.Text, LX) or not TryStrToFloat(edtY.Text, LY) then
      begin
        MessageBox(Self.Handle, '插入点坐标必须是数值!', '提示', MB_ICONWARNING or MB_OK);
        Exit; //=========>>>>
      end
      else
        FTextObj.Position := Point2D(LX, LY);
    end;

    if edtWidthFactor.Enabled then
    begin
      if not TryStrToFloat(edtWidthFactor.Text, LWF) or (LWF <= 0) then
      begin
        MessageBox(Self.Handle, '宽高比例必须是数值且大于0!', '提示', MB_ICONWARNING or MB_OK);
        Exit; //=========>>>>
      end
      else
        FTextObj.WidthFactor := LWF;
    end;

    if cbxTextStyle.ItemIndex >= 0 then
      FTextObj.TextStyle := TUdTextStyle(cbxTextStyle.Items.Objects[cbxTextStyle.ItemIndex]);

    FTextObj.Alignment := TUdTextAlign(cbxAlignment.ItemIndex);
    FTextObj.Backward := ckxBackward.Checked;
    FTextObj.Upsidedown := ckxUpsidedown.Checked;
    FTextObj.Contents := memText.Lines.Text;
    
    ModalResult := mrOK;
  end
  else ModalResult := mrCancel;
end;



end.