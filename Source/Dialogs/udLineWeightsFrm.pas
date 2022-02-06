{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLineWeightsFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,

  UdIntfs, UdLineWeight, UdLineWeights;

type
  TUdLineWeightsForm = class(TForm)
    pnlClient: TPanel;
    pnlRight: TPanel;
    pnlBottom: TPanel;
    Label1: TLabel;
    ckbDisplayLwt: TCheckBox;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    tkbAdjScale: TTrackBar;
    btnOK: TButton;
    btnCancel: TButton;
    cbxDefLwt: TComboBox;
    lstLwts: TListBox;
    lblCurLwtCaption: TLabel;
    lblCurLwt: TLabel;
    
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbxDefLwtDrawItem(AControl: TWinControl; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
    procedure FormResize(Sender: TObject);
    procedure lstLwtsDblClick(Sender: TObject);
    procedure tkbAdjScaleChange(Sender: TObject);
    procedure cbxDefLwtChange(Sender: TObject);
    procedure lstLwtsClick(Sender: TObject);

  private
    FManageMode: Boolean;
    FAdjustScale: Double;

    FByLayerLineWeight: TUdLineWeight;
    FByBlockLineWeight: TUdLineWeight;

  protected
    function GetDisplayLwt: Boolean;
    procedure SetDisplayLwt(const Value: Boolean);

    function GetCurrentLwt: TUdLineWeight;
    procedure SetCurrentLwt(const Value: TUdLineWeight);

    function GetDefaultLwt: TUdLineWeight;
    procedure SetDefaultLwt(const Value: TUdLineWeight);

    function GetSelectedLwt: TUdLineWeight;
    procedure SetManageMode(const Value: Boolean);

    function GetIsAnySelected: Boolean;

    procedure SetAdjustScale(const Value: Double);
    function GetLineWeightWidth(const AValue: TUdLineWeight): Integer;

  public
    property DisplayLwt: Boolean read GetDisplayLwt write SetDisplayLwt;
    property CurrentLwt: TUdLineWeight read GetCurrentLwt write SetCurrentLwt;
    property DefaultLwt: TUdLineWeight read GetDefaultLwt write SetDefaultLwt;

    property AdjustScale: Double read FAdjustScale write SetAdjustScale;

    property SelectedLwt: TUdLineWeight read GetSelectedLwt;
    property IsAnySelected: Boolean read GetIsAnySelected;

    property ManageMode: Boolean read FManageMode write SetManageMode;
  end;



function ShowLineWeightsDialog(ALineWeights: TUdLineWeights; var ADisplayLWT: Boolean): Boolean;


implementation

{$R *.dfm}

uses
  SysUtils, UdDrawUtil;


const
  PIXELS_PER_MM: Double = 96 / 25.4;

  

function ShowLineWeightsDialog(ALineWeights: TUdLineWeights; var ADisplayLWT: Boolean): Boolean;
var
  LForm: TUdLineWeightsForm;
  LUndoRedo: IUdUndoRedo;
begin
  Result := False;
  if not Assigned(ALineWeights) then Exit; //===>>>>

  LForm := TUdLineWeightsForm.Create(nil);
  try
    LForm.ManageMode  := True;
    LForm.DisplayLwt  := ADisplayLWT;
    LForm.CurrentLwt  := ALineWeights.Active;
    LForm.DefaultLwt  := ALineWeights.Default;
    LForm.AdjustScale := ALineWeights.AdjustScale;
    LForm.FByLayerLineWeight := ALineWeights.ByLayer;
    LForm.FByBlockLineWeight := ALineWeights.ByBlock;

    if LForm.ShowModal() = mrOk then
    begin
      if Assigned(ALineWeights) and Assigned(ALineWeights.Document) and ALineWeights.IsDocRegister then
        ALineWeights.Document.GetInterface(IUdUndoRedo, LUndoRedo);

      if Assigned(LUndoRedo) then LUndoRedo.BeginUndo('');
      try
        ADisplayLWT := LForm.DisplayLwt;
        ALineWeights.Active  := LForm.CurrentLwt;
        ALineWeights.Default := LForm.DefaultLwt;
        ALineWeights.AdjustScale := LForm.AdjustScale;
      finally
        if Assigned(LUndoRedo) then LUndoRedo.EndUndo();
      end;

      Result := True;
    end;
  finally
    LForm.Free;
  end;
end;






//==================================================================================================

procedure TUdLineWeightsForm.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FManageMode := True;

  for I := 3 to Length(ALL_LINE_WEIGHTS) - 1 do cbxDefLwt.Items.Add(IntToStr(ALL_LINE_WEIGHTS[I]));
  for I := 0 to Length(ALL_LINE_WEIGHTS) - 1 do lstLwts.Items.Add(IntToStr(ALL_LINE_WEIGHTS[I]));

  cbxDefLwt.ItemIndex := 7; //LW_25
  lstLwts.Selected[0] := True;
  lblCurLwt.Caption := 'ByLayer';

  FAdjustScale := 1.0;
  FByLayerLineWeight := LW_DEFAULT;
  FByBlockLineWeight := LW_DEFAULT;
end;

procedure TUdLineWeightsForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TUdLineWeightsForm.FormResize(Sender: TObject);
begin
  lstLwts.Invalidate;
  cbxDefLwt.Invalidate;
end;

procedure TUdLineWeightsForm.FormShow(Sender: TObject);
begin
//..
end;






//---------------------------------------------------------------------------

procedure TUdLineWeightsForm.SetAdjustScale(const Value: Double);
begin
  if FAdjustScale <> Value then
  begin
    FAdjustScale := Value;
    if FAdjustScale >= 1.5 then FAdjustScale := 1.5;
    if FAdjustScale <= 0.5 then FAdjustScale := 0.5;

    tkbAdjScale.Position := Trunc(FAdjustScale * 10);
  end;
end;

procedure TUdLineWeightsForm.tkbAdjScaleChange(Sender: TObject);
begin
  FAdjustScale := tkbAdjScale.Position / 10;
  lstLwts.Invalidate();
  cbxDefLwt.Invalidate();
end;



function TUdLineWeightsForm.GetLineWeightWidth(const AValue: TUdLineWeight): Integer;
var
  LWidth: Integer;
  LValue: TUdLineWeight;
begin
  LValue := AValue;
  case AValue of
    LW_BYLAYER: LValue := FByLayerLineWeight;
    LW_BYBLOCK: LValue := FByBlockLineWeight;
    LW_DEFAULT: LValue := Self.GetDefaultLwt();
  end;

  LWidth := Integer(LValue);

  if LWidth < 0 then Result := 1 else
    Result := Round(PIXELS_PER_MM * FAdjustScale * LWidth / 100);

  if Result <= 0 then Result := 1;
end;




function TUdLineWeightsForm.GetDisplayLwt: Boolean;
begin
  Result := ckbDisplayLwt.Checked;
end;

procedure TUdLineWeightsForm.SetDisplayLwt(const Value: Boolean);
begin
  ckbDisplayLwt.Checked := Value;
end;



function TUdLineWeightsForm.GetCurrentLwt: TUdLineWeight;
var
  I: Integer;
begin
  Result := LW_DEFAULT;
  for I := 0 to lstLwts.Count - 1 do
  begin
    if lstLwts.Selected[I] then
    begin
      Result := TUdLineWeight(StrToInt(lstLwts.Items[I]));
      Break;
    end;
  end;
end;


procedure TUdLineWeightsForm.SetCurrentLwt(const Value: TUdLineWeight);
var
  I: Integer;
begin
  for I := 0 to lstLwts.Count - 1 do
  begin
    if TUdLineWeight(StrToInt(lstLwts.Items[I])) = Value then
    begin
      lstLwts.Selected[I] := True;
      Break;
    end;
  end;
end;




function TUdLineWeightsForm.GetDefaultLwt: TUdLineWeight;
begin
  Result := LW_25;
  if cbxDefLwt.ItemIndex >= 0 then
    Result := TUdLineWeight(StrToInt(cbxDefLwt.Items[cbxDefLwt.ItemIndex]));
end;

procedure TUdLineWeightsForm.SetDefaultLwt(const Value: TUdLineWeight);
var
  N: Integer;
begin
  N := cbxDefLwt.Items.IndexOf(IntToStr(Value));
  if N >= 0 then cbxDefLwt.ItemIndex := N;
end;





function TUdLineWeightsForm.GetSelectedLwt: TUdLineWeight;
begin
  Result := Self.GetCurrentLwt();
end;


function TUdLineWeightsForm.GetIsAnySelected: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to lstLwts.Count - 1 do
  begin
    if lstLwts.Selected[I] then
    begin
      Result := True;
      Break;
    end;
  end;
end;




procedure TUdLineWeightsForm.SetManageMode(const Value: Boolean);
var
  I, N: Integer;
begin
  if FManageMode <> Value then
  begin
    FManageMode := Value;

    if FManageMode then N := 0 else N := 2;

    lstLwts.Clear();
    for I := N to Length(ALL_LINE_WEIGHTS) - 1 do lstLwts.Items.Add(IntToStr(ALL_LINE_WEIGHTS[I]));

    lblCurLwt.Visible := FManageMode;
    lblCurLwtCaption.Visible := FManageMode;

    pnlRight.Visible := FManageMode;
    
    if FManageMode then
    begin
      Self.Width  := Self.Width  + pnlRight.Width;
      Self.Height := Self.Height - pnlBottom.Height;
      Self.Caption := 'Ïß¿íÉèÖÃ';
    end
    else begin
      Self.Width  := Self.Width  - pnlRight.Width;
      Self.Height := Self.Height + pnlBottom.Height;
      Self.Caption := 'Ïß¿í';
    end;

  end;
end;





//---------------------------------------------------------------------------


procedure TUdLineWeightsForm.cbxDefLwtChange(Sender: TObject);
begin
  lstLwts.Invalidate();
end;

procedure TUdLineWeightsForm.cbxDefLwtDrawItem(AControl: TWinControl; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
var
  LItem: string;
  LName: string;
  LValue: Integer;
  LRect: TRect;
  LBackground: TColor;
  LCanvas: TCanvas;
begin
  LCanvas := nil;
  if AControl.InheritsFrom(TComboBox) then
  begin
    LCanvas := TComboBox(AControl).Canvas;
    if AIndex >= 0 then LItem := TComboBox(AControl).Items[AIndex];
  end
  else if AControl.InheritsFrom(TListBox)  then
  begin
    LCanvas := TListBox(AControl).Canvas;
    if AIndex >= 0 then LItem := TListBox(AControl).Items[AIndex];
  end;

  if not Assigned(LCanvas) then Exit; //======>>>>

  if AIndex >= 0 then
  begin
    LValue := StrToInt(LItem);
    LName := GetLineWeightName(TUdLineWeight(LValue));

    LCanvas.FillRect(ARect);
    LBackground := LCanvas.Brush.Color;

    LRect := ARect;
    LRect.Right := LRect.Left + Round((LRect.Right - LRect.Left) - 72);
    InflateRect(LRect, -2, -2);

    DrawLineWeight(LCanvas, LRect, Self.GetLineWeightWidth(TUdLineWeight(LValue)) );

    LCanvas.Brush.Color := LBackground;
    ARect.Left := LRect.Right + 10;

    LCanvas.TextRect(ARect, ARect.Left,
      ARect.Top + (ARect.Bottom - ARect.Top - LCanvas.TextHeight(LName)) div 2, LName);
  end;
end;


procedure TUdLineWeightsForm.lstLwtsClick(Sender: TObject);
begin
  if FManageMode then lblCurLwt.Caption := GetLineWeightName(Self.GetCurrentLwt());
end;

procedure TUdLineWeightsForm.lstLwtsDblClick(Sender: TObject);
begin
  if not FManageMode then btnOK.Click();
end;



end.