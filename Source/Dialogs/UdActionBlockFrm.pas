{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionBlockFrm;

{$I UdDefs.INC}

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons,

  UdTypes, UdObject;

type
  TUdBlockApply = (baNone, baOk, baCancel, baPickPnts, baSelObjs);


  TUdActionBlockForm = class(TForm)
    lblName: TLabel;
    lblPick: TLabel;
    lblSelect: TLabel;
    lblX: TLabel;
    lblY: TLabel;
    lblDescription: TLabel;

    cbxName: TComboBox;
    gpbBasePoint: TGroupBox;
    gpbObjects: TGroupBox;

    btnPickPoint: TSpeedButton;
    edtX: TEdit;
    edtY: TEdit;

    btnSelectObjs: TSpeedButton;
    rdbRetain: TRadioButton;
    rdbConvert: TRadioButton;
    rdbDelete: TRadioButton;

    memDescription: TMemo;
    btnOK: TButton;
    btnCancel: TButton;
    lblSelObjs: TLabel;
    Label7: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure btnPickPointClick(Sender: TObject);
    procedure btnSelectObjsClick(Sender: TObject);

    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);


  private
    FDocument: TUdObject;
    FApplyResult: TUdBlockApply;

  protected
    function GetBlockName: string;
    procedure SetBlockName(const AValue: string);

    function GetBlockDescription: string;
    procedure SetBlockDescription(const AValue: string);

    function GetBlockOrigin: TPoint2D;
    procedure SetBlockOrigin(const AValue: TPoint2D);

    function GetSelObjsAcn: Integer;
    procedure SetSelObjsAcn(const AValue: Integer);

    procedure SetDocument(const AValue: TUdObject);

  public
    property ApplyResult: TUdBlockApply read FApplyResult;

    property BlockName: string read GetBlockName write SetBlockName;
    property BlockOrigin: TPoint2D read GetBlockOrigin write SetBlockOrigin;
    property BlockDescription: string read GetBlockDescription write SetBlockDescription;

    property SelObjsAcn: Integer read GetSelObjsAcn write SetSelObjsAcn;

    property Document: TUdObject read FDocument write SetDocument;

  end;


implementation

{$R *.dfm}

uses
  SysUtils, UdDocument, UdBlock, UdInsert;



//=================================================================================================

procedure TUdActionBlockForm.FormCreate(Sender: TObject);
begin
  FDocument := nil;
  btnSelectObjs.Glyph.Assign(btnPickPoint.Glyph);
end;

procedure TUdActionBlockForm.FormDestroy(Sender: TObject);
begin
  FDocument := nil;
end;

procedure TUdActionBlockForm.FormShow(Sender: TObject);
var
  N: Integer;
begin
  if Assigned(FDocument) and FDocument.InheritsFrom(TUdDocument) then
  begin
    N := TUdDocument(FDocument).ActiveLayout.Selection.Count;
    if N > 0 then
      lblSelObjs.Caption := IntToStr(N) + '个对象被选中'//' object selected'
    else
      lblSelObjs.Caption := '没有对象被选中';//'No object selected';
  end;
end;





//------------------------------------------------------------------------------------

procedure TUdActionBlockForm.SetDocument(const AValue: TUdObject);
var
  I: Integer;
  LBlock: TUdBlock;
begin
  if (FDocument <> AValue) and (AValue <> nil) and AValue.InheritsFrom(TUdDocument) then
  begin
    cbxName.Clear();

    FDocument := AValue;
    for I := 0 to TUdDocument(FDocument).Blocks.Count - 1 do
    begin
      LBlock := TUdDocument(FDocument).Blocks.Items[I];
      cbxName.Items.AddObject(LBlock.Name, LBlock);
    end;
  end;
end;



function TUdActionBlockForm.GetBlockName: string;
begin
  Result := Trim(cbxName.Text);
end;

procedure TUdActionBlockForm.SetBlockName(const AValue: string);
begin
  cbxName.Text := AValue;
end;


function TUdActionBlockForm.GetBlockDescription: string;
begin
  Result := Trim(memDescription.Text);
end;

procedure TUdActionBlockForm.SetBlockDescription(const AValue: string);
begin
  memDescription.Text := AValue;
end;



function TUdActionBlockForm.GetBlockOrigin: TPoint2D;
begin
  Result.X := StrToFloat(edtX.Text);
  Result.Y := StrToFloat(edtY.Text);
end;

procedure TUdActionBlockForm.SetBlockOrigin(const AValue: TPoint2D);
begin
  edtX.Text := FloatToStr(AValue.X);
  edtY.Text := FloatToStr(AValue.Y);
end;



function TUdActionBlockForm.GetSelObjsAcn: Integer;
begin
  Result := 0;
  if rdbConvert.Checked then Result := 1 else
  if rdbDelete.Checked  then Result := 1 else;
end;

procedure TUdActionBlockForm.SetSelObjsAcn(const AValue: Integer);
begin
  case AValue of
    0: rdbRetain.Checked := True;
    1: rdbConvert.Checked := True;
    2: rdbDelete.Checked := True;
  end;
end;





//------------------------------------------------------------------------------------

procedure TUdActionBlockForm.btnPickPointClick(Sender: TObject);
begin
  FApplyResult := baPickPnts;
  Self.Close();
end;

procedure TUdActionBlockForm.btnSelectObjsClick(Sender: TObject);
begin
  FApplyResult := baSelObjs;
  Self.Close();
end;



procedure TUdActionBlockForm.btnOKClick(Sender: TObject);
var
  I: Integer;
  LList: TList;
  Lx, Ly: Double;
begin
  if Trim(cbxName.Text) = '' then
  begin
    MessageBox(Self.Handle, 'You must specify a block name.', 'Message', MB_ICONWARNING or MB_OK);
    cbxName.SetFocus();
    Exit;  //========>>>>
  end;

  LList := TUdDocument(FDocument).ActiveLayout.SelectedList;
  for I := 0 to LList.Count - 1 do
  begin
    if TObject(LList[I]).InheritsFrom(TUdInsert) and
      (TUdInsert(LList[I]).Block = cbxName.Items.Objects[cbxName.ItemIndex]) then
    begin
      MessageBox(Self.Handle, PChar('Block "' + Trim(cbxName.Text) +'" references itself.'), 'Message', MB_ICONWARNING or MB_OK);
      cbxName.SetFocus();
      Exit; //======>>>>>
    end;
  end;

  if not TryStrToFloat(edtX.Text, Lx) then
  begin
    MessageBox(Self.Handle, 'Invalid X-coordinate value.', 'Message', MB_ICONWARNING or MB_OK);
    edtX.SetFocus();
    Exit;  //========>>>>
  end;

  if not TryStrToFloat(edtY.Text, Ly) then
  begin
    MessageBox(Self.Handle, 'Invalid Y-coordinate value.', 'Message', MB_ICONWARNING or MB_OK);
    edtX.SetFocus();
    Exit;  //========>>>>
  end;

  FApplyResult := baOK;
  Self.Close();
end;

procedure TUdActionBlockForm.btnCancelClick(Sender: TObject);
begin
  FApplyResult := baCancel;
  Self.Close();
end;



end.