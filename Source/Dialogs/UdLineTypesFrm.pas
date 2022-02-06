{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLineTypesFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids,

  UdConsts, UdIntfs, UdObject, UdLineTypes, UdLineType, UdLntypGrid;

type
  TUdLineTypesForm = class(TForm)
    pnlTop: TPanel;
    pnlStatus: TPanel;
    pnlClient: TPanel;
    pnlBottom: TPanel;

    btnNew: TSpeedButton;
    btnDelete: TSpeedButton;
    btnCurrent: TSpeedButton;

    btnOK: TButton;
    btnCancel: TButton;
    btnApply: TButton;
    pnlDetail: TPanel;
    gpbDetail: TGroupBox;

    edtName: TEdit;
    lblName: TLabel;
    lblDescription: TLabel;
    edtDesc: TEdit;
    lblGlobalScale: TLabel;
    lblCurrentScale: TLabel;
    edtGlobalFactor: TEdit;
    edtCurrentFactor: TEdit;
    lblLoaded: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure btnNewClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnCurrentClick(Sender: TObject);

    procedure btnOKClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);

    procedure edtNameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtDescKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtGlobalFactorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtCurrentFactorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    
  private
    FLineTypes: TUdLineTypes;
    FLineTypes2: TUdLineTypes;
    FLineTypeGrid: TUdLntypGrid;
    
    FManageMode: Boolean;

  protected
    function GetSelectedItem: TUdLineType;
    procedure SetManageMode(const Value: Boolean);
    procedure SetLineTypes(const Value: TUdLineTypes);

    procedure UpdateDetail(AValue: TUdLineType);
    procedure OnLntpSelectItem(Sender: TObject);

  public
    procedure Apply();
    
    property SelectedItem: TUdLineType read GetSelectedItem;
    property LineTypes: TUdLineTypes read FLineTypes write SetLineTypes;
    property ManageMode: Boolean    read FManageMode write SetManageMode;
    
  end;



function ShowLineTypesDialog(ALineTypes: TUdLineTypes): Boolean;


implementation

{$R *.dfm}

uses
  SysUtils, UdDocument, UdLntypLoaderFrm;

type
  TFObject = class(TUdObject);




function ShowLineTypesDialog(ALineTypes: TUdLineTypes): Boolean;
var
  LForm: TUdLineTypesForm;
begin
  Result := False;
  if not Assigned(ALineTypes) then Exit; //===>>>>

  LForm := TUdLineTypesForm.Create(nil);
  try
    //LForm.ManageMode := False;
    LForm.LineTypes := ALineTypes;
    LForm.ShowModal();
  finally
    LForm.Free;
  end;

  Result := True;
end;



//==================================================================================================
{ TUdLntypManagerForm }

procedure TUdLineTypesForm.FormCreate(Sender: TObject);
begin
  FLineTypes := nil;
  FLineTypes2 := nil;
  
  FLineTypeGrid := TUdLntypGrid.Create(Self);
  FLineTypeGrid.Parent := pnlClient;
  FLineTypeGrid.Align := alClient;
  FLineTypeGrid.OnSelectItem := OnLntpSelectItem;

  FManageMode := True;
end;

procedure TUdLineTypesForm.FormDestroy(Sender: TObject);
begin
  FLineTypes := nil;
  
  FLineTypeGrid.Free();
  FLineTypeGrid := nil;

  if Assigned(FLineTypes2) then FLineTypes2.Free;
  FLineTypes2 := nil;
end;

procedure TUdLineTypesForm.FormShow(Sender: TObject);
begin
//
end;




procedure TUdLineTypesForm.SetLineTypes(const Value: TUdLineTypes);
var
  I: Integer;
begin
  if Assigned(FLineTypes2) then FLineTypes2.Free;
  FLineTypes2 := nil;

  FLineTypes := Value;

  if FManageMode then
    if Assigned(FLineTypes.Document) then TUdDocument(FLineTypes.Document).UpdateLineTypesStatus();

  FLineTypes2 := TUdLineTypes.Create();
  FLineTypes2.Assign(FLineTypes);

  for I := 0 to FLineTypes.Count - 1 do
    TFObject(FLineTypes2.Items[I]).SetID( FLineTypes.Items[I].ID );

  FLineTypeGrid.LineTypes := FLineTypes2;
  pnlStatus.Caption := ' 当前线形: ' + FLineTypes2.Active.Name;


  UpdateDetail(Self.GetSelectedItem());
end;


procedure TUdLineTypesForm.SetManageMode(const Value: Boolean);
//var
//  LRect: TGridRect;
begin
  if FManageMode <> Value then
  begin
    FManageMode := Value;

    FLineTypeGrid.StatusVisible  := FManageMode;
    FLineTypeGrid.ByItemsVisible := FManageMode;

    lblLoaded.Visible := not FManageMode;

    btnNew.Visible := FManageMode;
    btnDelete.Visible := FManageMode;
    btnCurrent.Visible := FManageMode;
    pnlStatus.Visible := FManageMode;
    pnlDetail.Visible := FManageMode;

    if FManageMode then
    begin
      pnlTop.Height := 32;
      btnApply.Caption := '应用';
      Self.Caption := '线形管理';
    end
    else begin
      pnlTop.Height := 24;
      btnApply.Caption := '加载...';
      Self.Width := 500;
      Self.Height := Self.Height - pnlDetail.Height;
      Self.Caption := '选择线形';
    end;

    if FManageMode then
      UpdateDetail(Self.GetSelectedItem());
  end;
end;





function TUdLineTypesForm.GetSelectedItem: TUdLineType;
begin
  Result := FLineTypeGrid.SelectedItem;
end;




procedure TUdLineTypesForm.UpdateDetail(AValue: TUdLineType);
var
  LFlag: Boolean;
begin
  if FManageMode and Assigned(AValue) then
  begin
    edtName.Text := AValue.Name;
    edtDesc.Text := AValue.Comment;

    edtGlobalFactor.Text  := FormatFloat('0.0000', FLineTypes2.GlobalScale);
    edtCurrentFactor.Text := FormatFloat('0.0000', FLineTypes2.CurrentScale);

    LFlag := FLineTypes2.IndexOf(AValue) > 2;
    
    edtName.Enabled := LFlag;
    edtDesc.Enabled := LFlag;
    lblName.Enabled := LFlag;
    lblDescription.Enabled := LFlag;
  end;
end;

procedure TUdLineTypesForm.OnLntpSelectItem(Sender: TObject);
begin
  if FManageMode then
    UpdateDetail(FLineTypeGrid.SelectedItem);
end;



//---------------------------------------------------------------------------------------

procedure TUdLineTypesForm.btnNewClick(Sender: TObject);
var
  I, N, R: Integer;
  LFlag: Integer;
  LForm: TUdLntypLoaderForm;
  LItems: TUdLineTypeArray;
  LLineType: TUdLineType;
begin
  LFlag := 0;
  LForm := TUdLntypLoaderForm.Create(nil);
  try
    if LForm.ShowModal() = mrOk then
    begin
      LItems := LForm.SelectedItems;

      for I := 0 to Length(LItems) - 1 do
      begin
        N := FLineTypes2.IndexOf(LItems[I].Name);
        if (N >= 0) and (N <= 2) then Continue;  // [ByLayer ByBlock Continuous]
        
        if N < 0 then
        begin
          LLineType := TUdLineType.Create();
          LLineType.Assign(LItems[I]);
          LLineType.Status := STATUS_NEW or STATUS_USELESS;
          FLineTypes2.Add(LLineType);
        end
        else begin
          case LFlag of
            0:
            begin
              R := MessageDlg('线形 ''' +  LItems[I].Name + ''' 已经加载过. 重新加载吗?',
                              mtWarning, [mbYes, mbYesToAll, mbNo, mbNoToAll, mbCancel], 0);
              case R of
                mrYes     : FLineTypes2.Items[N].Assign(LItems[I]);
                mrYesToAll: begin FLineTypes2.Items[N].Assign(LItems[I]); LFlag := 1; end;
                mrNo      : ;
                mrNoToAll : LFlag := 2;
                mrCancel  : Break;
              end;
            end;
            1: FLineTypes2.Items[N].Assign(LItems[I]); //Yes to ALL
            2: ; //No to ALL
          end;
        end;
      end;

      FLineTypeGrid.LineTypes := FLineTypes2;
      FLineTypeGrid.Invalidate;
    end;
  finally
    LForm.Free;
  end;
end;

procedure TUdLineTypesForm.btnDeleteClick(Sender: TObject);
var
  LLineType: TUdLineType;
begin
  if Assigned(FLineTypeGrid.SelectedItem) then
  begin
    LLineType := FLineTypeGrid.SelectedItem;

    if (FLineTypes2.IndexOf(LLineType) <= 2) or
       (LLineType.Status and STATUS_CURRENT > 0) or
       (LLineType.Status and STATUS_USELESS <= 0) then
    begin
      MessageBox(Self.Handle, PChar('未删除选择的线型.'+#13#10+#13#10+
                                    '不能删除下列线型:'+#13#10+
                                    '	ByLayer、ByBlock 和连续线型'+#13#10+
                                    '	当前线型'+#13#10+
                                    '	依赖外部参照的线型'+#13#10+
                                    '	图层或对象参照的线型'), '', MB_ICONWARNING or MB_OK);
      Exit; //=========>>>>>
    end;

    FLineTypes2.Remove(LLineType);
    FLineTypeGrid.LineTypes := FLineTypes2;
    
//    if LLineType.Status and STATUS_DELETED > 0 then
//      LLineType.Status := LLineType.Status and not STATUS_DELETED
//    else
//      LLineType.Status := LLineType.Status or STATUS_DELETED;

    FLineTypeGrid.Invalidate;
  end;
end;

procedure TUdLineTypesForm.btnCurrentClick(Sender: TObject);
var
  I: Integer;
  LLineType: TUdLineType;
begin
  if Assigned(FLineTypeGrid.SelectedItem) then
  begin
    for I := 0 to FLineTypes2.Count - 1 do
    begin
      LLineType := FLineTypes2.Items[I];
      LLineType.Status := LLineType.Status and not STATUS_CURRENT;
    end;

    LLineType := FLineTypeGrid.SelectedItem;
    LLineType.Status := LLineType.Status or STATUS_CURRENT;

    FLineTypeGrid.Invalidate;

    FLineTypes2.Active := LLineType;
    pnlStatus.Caption := ' 当前线形: ' + FLineTypes2.Active.Name;
  end;
end;




procedure TUdLineTypesForm.Apply;

  function _GetLineType(ALineTypes: TUdLineTypes; AID: Integer): TUdLineType;
  var
    I: Integer;
  begin
    Result := nil;
    if AID <= 0 then Exit;

    for I := 0 to ALineTypes.Count - 1 do
    begin
      if ALineTypes.Items[I].ID = AID then
      begin
        Result := ALineTypes.Items[I];
        Break;
      end;
    end;
  end;


var
  I: Integer;
  LLineType, LLineType2: TUdLineType;
  LUndoRedo: IUdUndoRedo;
begin
  if Assigned(FLineTypes) and Assigned(FLineTypes.Document) and FLineTypes.IsDocRegister then
    FLineTypes.Document.GetInterface(IUdUndoRedo, LUndoRedo);

  if Assigned(LUndoRedo) then LUndoRedo.BeginUndo('');
  try
    for I := FLineTypes.Count - 1 downto 0 do
    begin
      LLineType := FLineTypes.Items[I];
      LLineType2 := _GetLineType(FLineTypes2, LLineType.ID);
      if not Assigned(LLineType2) then FLineTypes.RemoveAt(I);
    end;

    for I := 0 to FLineTypes2.Count - 1 do
    begin
      LLineType2 := FLineTypes2.Items[I];
      LLineType  := _GetLineType(FLineTypes, LLineType2.ID);

      if Assigned(LLineType) then
      begin
        if LLineType2.Status and STATUS_DELETED > 0 then
        begin
          FLineTypes.Remove(LLineType);
        end
        else begin
          LLineType.Assign(LLineType2);
          if LLineType2.Status and STATUS_CURRENT > 0 then FLineTypes.SetActive(LLineType);
        end;
      end
      else begin
        if LLineType2.Status and STATUS_DELETED <= 0 then
        begin
          LLineType := TUdLineType.Create(FLineTypes.Document, True);
          LLineType.Assign(LLineType2);
          FLineTypes.Add(LLineType);

          TFObject(LLineType2).SetID( LLineType.ID );
          if LLineType2.Status and STATUS_CURRENT > 0 then FLineTypes.SetActive(LLineType);
        end;
      end;
    end;
  finally
    if Assigned(LUndoRedo) then LUndoRedo.EndUndo();
  end;

  for I := FLineTypes2.Count - 1 downto 0 do
  begin
    LLineType2 := FLineTypes2.Items[I];
    if LLineType2.Status and STATUS_DELETED > 0 then
      FLineTypes2.RemoveAt(I);
  end;

  FLineTypeGrid.LineTypes := FLineTypes2;
end;


procedure TUdLineTypesForm.btnOKClick(Sender: TObject);
begin
  if FManageMode then Self.Apply();
  Self.ModalResult := mrOk;
end;



//--------------------------------------------------------------------------------------------------

procedure TUdLineTypesForm.edtNameKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LLineTppe: TUdLineType;
begin
  LLineTppe := Self.GetSelectedItem();
  if Assigned(LLineTppe) then
  begin
    if edtName.Text = '' then
    begin
      MessageBox(Self.Handle, PChar('线形名称无效.'+#13+#10+#13+#10+
                                   '线形名称必须至少包含一个字符.'), '', MB_ICONWARNING or MB_OK);

      edtName.Text := LLineTppe.Name;
    end;

    LLineTppe.Name := edtName.Text;
    FLineTypeGrid.Invalidate;
  end;
end;

procedure TUdLineTypesForm.edtDescKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LLineTppe: TUdLineType;
begin
  LLineTppe := Self.GetSelectedItem();
  if Assigned(LLineTppe) then
  begin
    LLineTppe.Comment := edtDesc.Text;
    FLineTypeGrid.Invalidate;
  end;
end;


procedure TUdLineTypesForm.edtGlobalFactorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LValue: Double;
begin
  if TryStrToFloat(edtGlobalFactor.Text, LValue) then FLineTypes2.GlobalScale := LValue;
end;

procedure TUdLineTypesForm.edtCurrentFactorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LValue: Double;
begin
  if TryStrToFloat(edtCurrentFactor.Text, LValue) then FLineTypes2.CurrentScale := LValue;
end;




procedure TUdLineTypesForm.btnApplyClick(Sender: TObject);
begin
  if FManageMode then Self.Apply() else btnNew.Click();
end;

end.