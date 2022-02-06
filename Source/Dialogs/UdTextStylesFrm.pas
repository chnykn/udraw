{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdTextStylesFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, ExtCtrls, StdCtrls,

  UdConsts, UdTypes, UdObject, UdIntfs,
  UdAxes, UdText, UdTextStyles, UdTextStyle;

type
  TUdTextStylesForm = class(TForm)
    gpbStyleName: TGroupBox;
    cbxStyleName: TComboBox;
    btnNew: TButton;
    btnRename: TButton;
    btnDelete: TButton;
    gpbFont: TGroupBox;
    cbxFontName: TComboBox;
    lblFontName: TLabel;
    lblFontStyle: TLabel;
    cbxFontStyle: TComboBox;
    lblHeight: TLabel;
    edtHeight: TEdit;
    gpbEffects: TGroupBox;
    ckbUpsideDown: TCheckBox;
    ckbBackwards: TCheckBox;
    lblWidthFactor: TLabel;
    edtWidthFactor: TEdit;
    gpbPreview: TGroupBox;
    pnlPreview: TPanel;
    edtPreview: TEdit;
    btnPreview: TButton;
    btnApply: TButton;
    btnCancel: TButton;
    ckbUseBigfont: TCheckBox;
    Image1: TImage;
    Image2: TImage;
    ptbPreview: TPaintBox;
    
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    
    procedure cbxFontNameDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ckbUseBigfontClick(Sender: TObject);
    procedure cbxStyleNameChange(Sender: TObject);
    procedure cbxFontNameChange(Sender: TObject);
    procedure cbxFontStyleChange(Sender: TObject);
    procedure edtHeightKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ckbUpsideDownClick(Sender: TObject);
    procedure ckbBackwardsClick(Sender: TObject);
    procedure edtWidthFactorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ptbPreviewPaint(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);

    procedure btnNewClick(Sender: TObject);
    procedure btnRenameClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);


  private
    FAxes: TUdAxes;
    FText: TUdText;

    FTextStyle: TUdTextStyle;

    FTextStyles: TUdTextStyles;
    FTextStyles2: TUdTextStyles;

  protected
    procedure Apply();
    procedure UpdateUI();

    procedure SetTextStyle(const AValue: TUdTextStyle);
    procedure SetTextStyles(const AValue: TUdTextStyles);

  public
    property TextStyles: TUdTextStyles read FTextStyles write SetTextStyles;
    
  end;



function ShowTextStylesDialog(ATextStyles: TUdTextStyles): Boolean;
  

implementation

{$R *.dfm}

uses
  SysUtils, Dialogs,
  UdDocument, UdGeo2D, UdStyleNameFrm;

type
  TFObject = class(TUdObject);  



  
function ShowTextStylesDialog(ATextStyles: TUdTextStyles): Boolean;
var
  LForm: TUdTextStylesForm;
begin
  Result := False;
  if not Assigned(ATextStyles) then Exit; //===>>>>

  LForm := TUdTextStylesForm.Create(nil);
  try
    //LForm.ManageMode := False;
    LForm.TextStyles := ATextStyles;
    LForm.ShowModal();
  finally
    LForm.Free;
  end;

  Result := True;
end;




//==================================================================================================

procedure FillTTFFontNames(ADest: TStrings; Append: Boolean);

  function EnumFontsProc(EnumLogFontExDV: PEnumLogFontExDV; EnumTextMetric: PEnumTextMetric;
    FontType: DWORD; LParam: LPARAM): Integer; stdcall;
  var
    S: string;
    L: TStrings;
  const
    NTM_PS_OPENTYPE = $00020000;
    NTM_TT_OPENTYPE = $00040000;
  begin
    L := TStrings(LParam);
    
    if FontType = TRUETYPE_FONTTYPE then
    begin
      S := EnumLogFontExDV.elfEnumLogfontEx.elfLogFont.lfFaceName;
      if (Length(S) > 1) and (S[1] <> '@') then
      begin
        if (L.Count = 0) or not SameText(S, L[L.Count - 1]) then
          L.AddObject(S, Pointer(1));
      end;
    end;
    
    Result := 1;
  end;

var
  I: Integer;
  DC: HDC;
  LFont: TLogFont;
  L: TStringList;
begin
  L := TStringList.Create;
  DC := GetDC(0);
  try
    FillChar(LFont, SizeOf(LFont), 0);
    LFont.lfCharset := DEFAULT_CHARSET;
    EnumFontFamiliesEx(DC, LFont, @EnumFontsProc, LongInt(L), 0);
    L.Sort;

    if Append then
      for I := 0 to L.Count - 1 do ADest.AddObject(L[I], L.Objects[I])
    else
      ADest.Assign(L);
  finally
    ReleaseDC(0, DC);
    L.Free;
  end;
end;



//==================================================================================================
{ TUdTextStylesForm }



procedure TUdTextStylesForm.FormCreate(Sender: TObject);
begin
  FTextStyle := nil;
  FTextStyles := nil;
  FTextStyles2 := nil;

  FAxes := TUdAxes.Create;
  FAxes.CalcAxis(pnlPreview.Width, pnlPreview.Height,
                 Point2D(0, pnlPreview.Width), Point2D(0, pnlPreview.Height));

  FText := TUdText.Create();
  FText.Color.TrueColor := RGB(0, 0, 0);
end;

procedure TUdTextStylesForm.FormDestroy(Sender: TObject);
begin
  FTextStyle := nil;
  FTextStyles := nil;
  
  if Assigned(FTextStyles2) then FTextStyles2.Free;
  FTextStyles2 := nil;

  if Assigned(FAxes) then FAxes.Free;
  FAxes := nil;

  if Assigned(FText) then FText.Free;
  FText := nil;  
end;

procedure TUdTextStylesForm.FormShow(Sender: TObject);
begin
//  FillTTFFontNames(cbxFontName.Items, False);
end;




//--------------------------------------------------------------------------------------


function _GetFontFlag(AFont: TFont): Cardinal;
begin
  Result := 3;
  if (fsBold in AFont.Style) and (fsItalic in AFont.Style) then  Result := 1 else
  if (fsBold in AFont.Style) then Result := 0 else
  if (fsItalic in AFont.Style) then Result := 2;
end;

function _GetFontStyle(AIndex: Integer): TFontStyles;
begin
  Result := [];
  case AIndex of
    0: Result := [fsBold];
    1: Result := [fsBold, fsItalic];
    2: Result := [fsItalic];
  end;
end;


procedure TUdTextStylesForm.UpdateUI;
var
  LOldEvent: TNotifyEvent;
begin
  if not Assigned(FTextStyle) then Exit; //======>>>>
  
  if FTextStyle.FontKind = fkShx then
  begin
    LOldEvent := ckbUseBigfont.OnClick;
    try
      ckbUseBigfont.Enabled := True;
      ckbUseBigfont.OnClick := nil;
      ckbUseBigfont.Checked := (FTextStyle.ShxFont.BigFile <> '');
    finally
      ckbUseBigfont.OnClick := LOldEvent;
    end;
    
    if ckbUseBigfont.Checked then
    begin
      lblFontName.Caption  := 'SHX 字体:';
      lblFontStyle.Caption := '大字体:';

      cbxFontName.Items.Assign(FTextStyles.ShxFontNames);

      cbxFontStyle.Enabled := True;
      cbxFontStyle.Style := csOwnerDrawFixed;
      cbxFontStyle.ItemHeight := cbxFontName.ItemHeight;
      cbxFontStyle.OnDrawItem := cbxFontNameDrawItem;
      cbxFontStyle.Items.Assign(FTextStyles.BigFontNames);

      LOldEvent := cbxFontName.OnChange;
      try
        cbxFontName.OnChange := nil;
        cbxFontName.ItemIndex := cbxFontName.Items.IndexOf(ExtractFileName(LowerCase(FTextStyle.ShxFont.ShxFile)));
      finally
        cbxFontName.OnChange := LOldEvent;
      end;

      LOldEvent := cbxFontStyle.OnChange;
      try
        cbxFontStyle.OnChange := nil;
        cbxFontStyle.ItemIndex := cbxFontStyle.Items.IndexOf(ExtractFileName(LowerCase(FTextStyle.ShxFont.BigFile)));
      finally
        cbxFontStyle.OnChange := LOldEvent;
      end;

    end
    else begin
      lblFontName.Caption  := '字体名:';
      lblFontStyle.Caption := '字体样式:';

      LOldEvent := cbxFontName.OnChange;
      try
        cbxFontName.OnChange := nil;
        
        cbxFontName.Items.Assign(FTextStyles.ShxFontNames);
        FillTTFFontNames(cbxFontName.Items, True);

        cbxFontName.ItemIndex := cbxFontName.Items.IndexOf(ExtractFileName(LowerCase(FTextStyle.ShxFont.ShxFile)));
      finally
        cbxFontName.OnChange := LOldEvent;
      end;

      LOldEvent := cbxFontStyle.OnChange;
      try
        cbxFontStyle.OnChange := nil;
        cbxFontStyle.Clear();
        cbxFontStyle.Enabled := False;
      finally
        cbxFontStyle.OnChange := LOldEvent;
      end;
    end;
  end
  else begin
    LOldEvent := ckbUseBigfont.OnClick;
    try
      ckbUseBigfont.Enabled := False;
      ckbUseBigfont.OnClick := nil;
      ckbUseBigfont.Checked := False;
    finally
      ckbUseBigfont.OnClick := LOldEvent;
    end;

    
    lblFontName.Caption  := '字体名:';
    lblFontStyle.Caption := '字体样式:';

    LOldEvent := cbxFontName.OnChange;
    try
      cbxFontName.OnChange := nil;

      cbxFontName.Items.Assign(FTextStyles.ShxFontNames);
      FillTTFFontNames(cbxFontName.Items, True);

      cbxFontName.ItemIndex := cbxFontName.Items.IndexOf(FTextStyle.TTFFont.Font.Name);
    finally
      cbxFontName.OnChange := LOldEvent;
    end;
          

    LOldEvent := cbxFontStyle.OnChange;
    try
      cbxFontStyle.OnChange := nil;

      cbxFontStyle.Enabled := True;
      cbxFontStyle.Clear();
      cbxFontStyle.OnDrawItem := nil;
      cbxFontStyle.Style := csDropDownList;

      cbxFontStyle.Items.Add('粗体');
      cbxFontStyle.Items.Add('粗斜体');
      cbxFontStyle.Items.Add('斜体');
      cbxFontStyle.Items.Add('正规');

      cbxFontStyle.ItemIndex := _GetFontFlag(FTextStyle.TTFFont.Font);
    finally
      cbxFontStyle.OnChange := LOldEvent;
    end;
  end;

  LOldEvent := ckbUpsideDown.OnClick;
  try
    ckbUpsideDown.OnClick := nil;
    ckbUpsideDown.Checked := FTextStyle.Upsidedown;
  finally
    ckbUpsideDown.OnClick := LOldEvent;
  end;

  LOldEvent := ckbBackwards.OnClick;
  try
    ckbBackwards.OnClick := nil;
    ckbBackwards.Checked := FTextStyle.Backward;
  finally
    ckbBackwards.OnClick := LOldEvent;
  end;

  edtHeight.Text := FormatFloat('0.0000##', FTextStyle.Height);
  edtWidthFactor.Text := FormatFloat('0.0000##', FTextStyle.WidthFactor);

  ptbPreview.Invalidate();
end;

procedure TUdTextStylesForm.SetTextStyle(const AValue: TUdTextStyle);
var
  I, N: Integer;
  LOldEvent: TNotifyEvent;
begin
  if FTextStyle = AValue then Exit; //=====>>>

  if Assigned(FTextStyle) then
    FTextStyle.Status := FTextStyle.Status and not STATUS_CURRENT;
  
  N := -1;
  LOldEvent := cbxStyleName.OnChange;
  try
    cbxStyleName.OnChange := nil;
    for I := 0 to cbxStyleName.Items.Count - 1 do
    begin
      if cbxStyleName.Items.Objects[I] = AValue then
      begin
        N := I;
        Break;
      end;
    end;
    cbxStyleName.ItemIndex := N;
  finally
    cbxStyleName.OnChange := LOldEvent;
  end;

  btnRename.Enabled := (N > 0);
  btnDelete.Enabled := (N > 0) and ((AValue.Status and STATUS_USELESS) > 0);

  FTextStyle := AValue;
  FTextStyle.Status := FTextStyle.Status or STATUS_CURRENT;
  
  Self.UpdateUI();
end;

procedure TUdTextStylesForm.SetTextStyles(const AValue: TUdTextStyles);
var
  I: Integer;
begin
  if Assigned(FTextStyles2) then FTextStyles2.Free;
  FTextStyles2 := nil;
  
  FTextStyles := AValue;
  if Assigned(FTextStyles.Document) then TUdDocument(FTextStyles.Document).UpdateTextTypesStatus();

  FTextStyles2 := TUdTextStyles.Create();
  FTextStyles2.Assign(FTextStyles);

  for I := 0 to FTextStyles.Count - 1 do
    TFObject(FTextStyles2.Items[I]).SetID( FTextStyles.Items[I].ID );

  cbxStyleName.Clear();
  for I := 0 to FTextStyles2.Count - 1 do
    cbxStyleName.Items.AddObject(FTextStyles2.Items[I].Name,  FTextStyles2.Items[I]);

  Self.SetTextStyle(FTextStyles2.Active);
end;






//--------------------------------------------------------------------------------------

procedure TUdTextStylesForm.ptbPreviewPaint(Sender: TObject);
var
  X, Y: Double;
begin
  ptbPreview.Canvas.Pen.Color := clBlack;
  ptbPreview.Canvas.Pen.Style := psSolid;
  ptbPreview.Canvas.Brush.Style := bsClear;

  ptbPreview.Canvas.Rectangle(pnlPreview.ClientRect);

//  if FTextStyle.FontKind = fkTTF then
//    FTextStyle.TTFFont.Precision := 90;
    
  FText.TextStyle   := FTextStyle;
  FText.Upsidedown  := ckbUpsideDown.Checked;
  FText.Backward    := ckbBackwards.Checked;
  FText.WidthFactor := StrToFloatDef(edtWidthFactor.Text, 1.0);
  FText.Height      := 20;
  FText.Contents    := edtPreview.Text;
  FText.Update(FAxes);

  Y := 12;
  X := (pnlPreview.Width - FText.TextWidth) / 2;

  if FText.Upsidedown then Y := Y + FText.Height;
  if FText.Backward   then X := X + FText.TextWidth;

  FText.Position := Point2D(X, Y);
  FText.Update(FAxes);
  
  FText.Draw(ptbPreview.Canvas, FAxes);
end;


procedure TUdTextStylesForm.btnPreviewClick(Sender: TObject);
begin
  ptbPreview.Invalidate();
end;





procedure TUdTextStylesForm.cbxFontNameDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LItem: string;
  LKind: Integer;
  LRect: TRect;
  LCanvas: TCanvas;
  LBackground: TColor;
begin
  LKind := 0;
  LCanvas := nil;

  if Control.InheritsFrom(TComboBox) then
  begin
    LCanvas := TComboBox(Control).Canvas;
    if Index >= 0 then
    begin
      LItem := TComboBox(Control).Items[Index];
      LKind := Integer(TComboBox(Control).Items.Objects[Index]);
    end;
  end;

  if not Assigned(LCanvas) then Exit; //======>>>>

  LRect := Rect;

  LCanvas.FillRect(LRect);
  LBackground := Brush.Color;
  
  if Index >= 0 then
  begin
    if LKind = 0 then
      LCanvas.Draw(3, LRect.Top + (LRect.Bottom - LRect.Top - 14) div 2, Image1.Picture.Bitmap)
    else
      LCanvas.Draw(3, LRect.Top + (LRect.Bottom - LRect.Top - 14) div 2, Image2.Picture.Bitmap);

    LRect.Left := LRect.Left + 19;

    Brush.Color := LBackground;
    LCanvas.TextRect(LRect, LRect.Left,
      LRect.Top + 1{(LRect.Bottom - LRect.Top - LCanvas.TextHeight(LItem)) div 2}, LItem);
  end;
end;


procedure TUdTextStylesForm.cbxStyleNameChange(Sender: TObject);
begin
  Self.SetTextStyle(TUdTextStyle(cbxStyleName.Items.Objects[cbxStyleName.ItemIndex]));
end;


procedure TUdTextStylesForm.ckbUseBigfontClick(Sender: TObject);
var
  LShxFont: string;
begin
  if ckbUseBigfont.Checked then
  begin
    if (FTextStyles.BigFontNames.Count > 0) then
    begin
      LShxFont := 'gbcbig.shx';
      
      if (FTextStyles.BigFontNames.IndexOf(LShxFont) < 0) then
        LShxFont := FTextStyles.BigFontNames[0];

      FTextStyle.ShxFont.BigFile := FTextStyles.GetShxFile(LShxFont);
    end;
  end
  else begin
    FTextStyle.ShxFont.BigFile := '';
  end;

  Self.UpdateUI();
end;



procedure TUdTextStylesForm.cbxFontNameChange(Sender: TObject);
var
  N: Integer;
begin
  N := Integer(cbxFontName.Items.Objects[cbxFontName.ItemIndex]);
  FTextStyle.FontKind := TUdFontKind(N);

  case FTextStyle.FontKind of
    fkShx: FTextStyle.ShxFont.ShxFile := FTextStyles.GetShxFile(cbxFontName.Text);
    fkTTF: FTextStyle.TTFFont.Font.Name := cbxFontName.Text;
  end;

  Self.UpdateUI();
end;

procedure TUdTextStylesForm.cbxFontStyleChange(Sender: TObject);
begin
  if (FTextStyle.FontKind = fkShx) then
    FTextStyle.ShxFont.BigFile := FTextStyles.GetShxFile(cbxFontStyle.Text)
  else
    FTextStyle.TTFFont.Font.Style := _GetFontStyle(cbxFontStyle.ItemIndex);
    
  ptbPreview.Invalidate();
end;

procedure TUdTextStylesForm.ckbUpsideDownClick(Sender: TObject);
begin
  FTextStyle.Upsidedown := ckbUpsideDown.Checked;
  ptbPreview.Invalidate();
end;

procedure TUdTextStylesForm.ckbBackwardsClick(Sender: TObject);
begin
  FTextStyle.Backward := ckbBackwards.Checked;
  ptbPreview.Invalidate();
end;

procedure TUdTextStylesForm.edtHeightKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LValue: Double;
begin
  if TryStrToFloat(edtHeight.Text, LValue) and (LValue > 0) then
    FTextStyle.Height := LValue;
end;

procedure TUdTextStylesForm.edtWidthFactorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LValue: Double;
begin
  if TryStrToFloat(edtWidthFactor.Text, LValue) and (LValue > 0) then
  begin
    FTextStyle.WidthFactor := LValue;
    ptbPreview.Invalidate();
  end;
end;





//-------------------------------------------------------------------------------------------


procedure TUdTextStylesForm.btnNewClick(Sender: TObject);
var
  I: Integer;
  LStr: string;
  LTextStyle: TUdTextStyle;
begin
  LStr := '';
  if UdStyleNameFrm.ShowStyleNameDialog(LStr) then
  begin
    if Trim(LStr) = '' then
    begin
      MessageBox(Self.Handle, '无效的样式名称!', '', MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    for I := 0 to FTextStyles2.Count - 1 do
    begin
      if FTextStyles2.Items[I] = FTextStyle then Continue;

      if LowerCase(FTextStyles2.Items[I].Name) = LowerCase(LStr) then
      begin
        MessageBox(Self.Handle, '样式名称已经存在!', '', MB_ICONWARNING or MB_OK);
        Exit; //=====>>>>>
      end;
    end;

    LTextStyle := TUdTextStyle.Create();
    if Assigned(FTextStyle) then LTextStyle.Assign(FTextStyle);

    LTextStyle.Name := LStr;
    LTextStyle.Status := STATUS_NEW or STATUS_USELESS;
    FTextStyles2.Add(LTextStyle);

    FTextStyles2.Active := LTextStyle;

    cbxStyleName.Clear();
    for I := 0 to FTextStyles2.Count - 1 do
      cbxStyleName.Items.AddObject(FTextStyles2.Items[I].Name,  FTextStyles2.Items[I]);

    Self.SetTextStyle(FTextStyles2.Active);
  end;
end;

procedure TUdTextStylesForm.btnRenameClick(Sender: TObject);
var
  I: Integer;
  LStr: string;
begin
  if not Assigned(FTextStyle) then Exit; //======>>>>

  LStr := FTextStyle.Name;

  if UdStyleNameFrm.ShowStyleNameDialog(LStr) then
  begin
    if Trim(LStr) = '' then
    begin
      MessageBox(Self.Handle, '无效的样式名称!', '', MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    for I := 0 to FTextStyles2.Count - 1 do
    begin
      if FTextStyles2.Items[I] = FTextStyle then Continue;

      if LowerCase(FTextStyles2.Items[I].Name) = LowerCase(LStr) then
      begin
        MessageBox(Self.Handle, '样式名称已经存在!', '', MB_ICONWARNING or MB_OK);
        Exit; //=====>>>>>
      end;
    end;

    FTextStyle.Name := LStr;
  end;
end;

procedure TUdTextStylesForm.btnDeleteClick(Sender: TObject);
var
  I: Integer;
begin
  if not Assigned(FTextStyle) then Exit; //======>>>>

  if MessageBox(Self.Handle, PChar('删除文本样式:''' + FTextStyle.Name  + '''吗?'), '',
                MB_ICONQUESTION or MB_YESNO) = mrNo then Exit; //=======>>>>

  FTextStyles2.SetActive(0);
  FTextStyles2.Remove(FTextStyle);

  cbxStyleName.Clear();
  for I := 0 to FTextStyles2.Count - 1 do
    cbxStyleName.Items.AddObject(FTextStyles2.Items[I].Name,  FTextStyles2.Items[I]);

  Self.SetTextStyle(FTextStyles2.Active);  
end;



procedure TUdTextStylesForm.Apply;

  function _GetTextStyle(ATextStyles: TUdTextStyles; AID: Integer): TUdTextStyle;
  var
    I: Integer;
  begin
    Result := nil;
    if AID <= 0 then Exit;

    for I := 0 to ATextStyles.Count - 1 do
    begin
      if ATextStyles.Items[I].ID = AID then
      begin
        Result := ATextStyles.Items[I];
        Break;
      end;
    end;
  end;


var
  I: Integer;
  LTextStyle, LTextStyle2: TUdTextStyle;
  LUndoRedo: IUdUndoRedo;
begin
  if Assigned(FTextStyles) and Assigned(FTextStyles.Document) and FTextStyles.IsDocRegister then
    FTextStyles.Document.GetInterface(IUdUndoRedo, LUndoRedo);

  if Assigned(LUndoRedo) then LUndoRedo.BeginUndo('');
  try
    FTextStyles.SetActive(0);
    
    for I := FTextStyles.Count - 1 downto 0 do
    begin
      LTextStyle := FTextStyles.Items[I];
      LTextStyle2 := _GetTextStyle(FTextStyles2, LTextStyle.ID);
      if not Assigned(LTextStyle2) then FTextStyles.RemoveAt(I);
    end;

    for I := 0 to FTextStyles2.Count - 1 do
    begin
      LTextStyle2 := FTextStyles2.Items[I];
      LTextStyle  := _GetTextStyle(FTextStyles, LTextStyle2.ID);

      if Assigned(LTextStyle) then
      begin
        if LTextStyle2.Status and STATUS_DELETED > 0 then
        begin
          FTextStyles.Remove(LTextStyle);
        end
        else begin
          LTextStyle.Assign(LTextStyle2);
          if LTextStyle2.Status and STATUS_CURRENT > 0 then FTextStyles.SetActive(LTextStyle.Name);
        end;
      end
      else begin
        if LTextStyle2.Status and STATUS_DELETED <= 0 then
        begin
          LTextStyle := TUdTextStyle.Create(FTextStyles.Document, True);
          LTextStyle.Assign(LTextStyle2);
          FTextStyles.Add(LTextStyle);

          if LTextStyle2.Status and STATUS_CURRENT > 0 then FTextStyles.SetActive(LTextStyle.Name);
        end;
      end;
    end;
  finally
    if Assigned(LUndoRedo) then LUndoRedo.EndUndo();
  end;
end;

procedure TUdTextStylesForm.btnApplyClick(Sender: TObject);
begin
  Self.Apply();
  Self.ModalResult := mrOk;
end;






end.