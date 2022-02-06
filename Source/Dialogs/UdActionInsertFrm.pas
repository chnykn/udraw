{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionInsertFrm;

{$I UdDefs.INC}

{$DEFINE HIDE_SYS_BLOCK}

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls,

  UdTypes, UdObject, UdAxes, UdEntity, UdEntities, UdDrawPanel;

type
  TUdActionInsertForm = class(TForm)
    lblName: TLabel;
    cbxName: TComboBox;
    gpbInsPoint: TGroupBox;
    lblInsX: TLabel;
    lblInsY: TLabel;
    edtPointX: TEdit;
    edtPointY: TEdit;
    ckbSpeInsPnt: TCheckBox;
    grbScale: TGroupBox;
    lblScaleX: TLabel;
    lblScaleY: TLabel;
    edtScaleX: TEdit;
    edtScaleY: TEdit;
    ckbSpeScale: TCheckBox;
    ckbUniformScale: TCheckBox;
    grbRoatation: TGroupBox;
    lblAngle: TLabel;
    edtAngle: TEdit;
    ckbSpeAngle: TCheckBox;
    pnlPreview: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    ckbExplode: TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpecifyOnSecreenClick(Sender: TObject);
    procedure ckbUniformScaleClick(Sender: TObject);
    procedure edtScaleXChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cbxNameChange(Sender: TObject);

  private
    FDocument: TUdObject;
    
    FAxes: TUdAxes;
    FEntities2: TUdEntities;
    FDrawPanel: TUdDrawPanel;

  protected
    procedure SetDocument(const AValue: TUdObject);
    function GetBlockName: string;
    function GetCurrBlock(): TObject;

    function GetSpecify(AIndex: Integer): Boolean;
    procedure SetSpecify(AIndex: Integer; const AValue: Boolean);

    function GetUniformScale: Boolean;
    procedure SetUniformScale(const AValue: Boolean);


    function GetScale: TPoint2D;
    procedure SetScale(const AValue: TPoint2D);

    procedure SetInsPoint(const AValue: TPoint2D);
    function GetInsPoint: TPoint2D;

    function GetRoatation: Float;
    procedure SetRoatation(const AValue: Float);

    function GetExplode: Boolean;
    procedure SetExplode(const AValue: Boolean);

    procedure UpdatePrivewBlock();
    procedure OnDrawPanelPaint(Sender: TObject; ACanvas: TCanvas);
    
  public
    property Document: TUdObject read FDocument write SetDocument;

    property BlockName: string read GetBlockName;

    property SpecifyInsPoint : Boolean index 0 read GetSpecify write SetSpecify;
    property SpecifScaleY    : Boolean index 1 read GetSpecify write SetSpecify;
    property SpecifyRoatation: Boolean index 2 read GetSpecify write SetSpecify;

    property InsPoint : TPoint2D  read GetInsPoint  write SetInsPoint ;
    property Scale    : TPoint2D  read GetScale     write SetScale    ;
    property Roatation: Float     read GetRoatation write SetRoatation;

    property Explode: Boolean read GetExplode write SetExplode;
    property UniformScale: Boolean read GetUniformScale write SetUniformScale;

  end;

implementation

{$R *.dfm}

uses
  SysUtils,
  UdDocument, UdBlock, UdGeo2D, UdMath, UdUtils;


type
  TFDrawPanel = class(TUdDrawPanel);
  

//=================================================================================================
{ TUdActionInsertForm }

procedure TUdActionInsertForm.FormCreate(Sender: TObject);
begin
  FDocument := nil;

  FAxes := TUdAxes.Create;
  FEntities2 := TUdEntities.Create;

  FDrawPanel := TUdDrawPanel.Create(nil);
  FDrawPanel.Parent        := pnlPreview;
  FDrawPanel.Align         := alClient;
  FDrawPanel.ScrollBars    := ssNone;
  FDrawPanel.ReadOnly      := True;
  FDrawPanel.XCursor.Style := csDraw;
  TFDrawPanel(FDrawPanel)._OnPaint := OnDrawPanelPaint;   
end;

procedure TUdActionInsertForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FDrawPanel) then FDrawPanel.Free;
  FDrawPanel := nil;
  
  if Assigned(FEntities2) then FEntities2.Free;
  FEntities2 := nil;
  
  if Assigned(FAxes) then FAxes.Free;
  FAxes := nil;
end;

procedure TUdActionInsertForm.FormShow(Sender: TObject);
begin
  FDrawPanel.Cursor := 0;
  Self.UpdatePrivewBlock();
end;




//------------------------------------------------------------------------------------

procedure TUdActionInsertForm.SetDocument(const AValue: TUdObject);
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
      {$IFDEF HIDE_SYS_BLOCK}
      if not LBlock.IsSys then
      {$ENDIF}
        cbxName.Items.AddObject(LBlock.Name, LBlock);
    end;
  end;
end;



function TUdActionInsertForm.GetBlockName: string;
begin
  Result := cbxName.Text;
end;

function TUdActionInsertForm.GetCurrBlock(): TObject;
begin
  Result := nil;
  if cbxName.ItemIndex >= 0 then
    Result := cbxName.Items.Objects[cbxName.ItemIndex];
end;


function TUdActionInsertForm.GetSpecify(AIndex: Integer): Boolean;
begin
  Result := False;
  case AIndex of
    0: Result := ckbSpeInsPnt.Checked;
    1: Result := ckbSpeScale.Checked;
    2: Result := ckbSpeAngle.Checked;
  end;
end;




procedure TUdActionInsertForm.SetSpecify(AIndex: Integer; const AValue: Boolean);
begin
  case AIndex of
    0: begin ckbSpeInsPnt.Checked := AValue; SpecifyOnSecreenClick(ckbSpeInsPnt) end;
    1: begin ckbSpeScale.Checked  := AValue; SpecifyOnSecreenClick(ckbSpeScale)  end;
    2: begin ckbSpeAngle.Checked  := AValue; SpecifyOnSecreenClick(ckbSpeAngle)  end;
  end;
end;




function TUdActionInsertForm.GetUniformScale: Boolean;
begin
  Result := ckbUniformScale.Checked;
end;

procedure TUdActionInsertForm.SetUniformScale(const AValue: Boolean);
begin
  ckbUniformScale.Checked := AValue;
  ckbUniformScaleClick(ckbUniformScale);
end;




function TUdActionInsertForm.GetExplode: Boolean;
begin
  Result := ckbExplode.Checked;
end;

procedure TUdActionInsertForm.SetExplode(const AValue: Boolean);
begin
  ckbExplode.Checked := AValue;
end;



function TUdActionInsertForm.GetScale: TPoint2D;
begin
  Result := Point2D(1, 1);
  if not Self.SpecifScaleY then
    Result := Point2D(StrToFloat(edtScaleX.Text), StrToFloat(edtScaleY.Text))
end;

procedure TUdActionInsertForm.SetScale(const AValue: TPoint2D);
begin
  edtScaleX.Text := FloatToStr(AValue.X);
  edtScaleY.Text := FloatToStr(AValue.Y);
end;


function TUdActionInsertForm.GetInsPoint: TPoint2D;
begin
  Result := Point2D(0, 0);
  if not Self.SpecifyInsPoint then
    Result := Point2D(StrToFloat(edtPointX.Text), StrToFloat(edtPointY.Text))
end;

procedure TUdActionInsertForm.SetInsPoint(const AValue: TPoint2D);
begin
  edtPointX.Text := FloatToStr(AValue.X);
  edtPointY.Text := FloatToStr(AValue.Y);
end;


function TUdActionInsertForm.GetRoatation: Float;
begin
  Result := 0;
  if not Self.SpecifyRoatation then
    Result := StrToFloat(edtAngle.Text)
end;

procedure TUdActionInsertForm.SetRoatation(const AValue: Float);
begin
  edtAngle.Text := FloatToStr(AValue);
end;




//------------------------------------------------------------------------------------

procedure TUdActionInsertForm.UpdatePrivewBlock();
var
  I: Integer;  //, J
//  LBase: TPoint2D;
  E: Float;
  LBound: TRect2D;
  LBlock: TUdBlock;
  LEntity, LEntity2: TUdEntity;
begin
  LBlock := TUdBlock(Self.GetCurrBlock());
  if not Assigned(LBlock) then Exit;

  FEntities2.Clear();

  for I := 0 to LBlock.Entities.Count - 1 do
  begin
    LEntity := LBlock.Entities.Items[I];
    LEntity2 := LEntity.Clone();
    FEntities2.Add(LEntity2);
  end;

  for I := 0 to FEntities2.Count - 1 do
  begin
    LEntity := FEntities2.Items[I];
    LEntity.SetDocument(FDocument, False);

//    if LEntity.InheritsFrom(TUdDimension) then
//    begin
//      TUdDimension(LEntity).DimStyle := nil;
//      TUdDimension(LEntity).DimStyle := TUdDocument(FDocument).DimStyles.Active;
//      
//      LEntity.Update(FAxes);
//      for J := 0 to TUdDimension(LEntity).EntityList.Count - 1 do
//      begin
//        LEntity2 := TUdEntity(TUdDimension(LEntity).EntityList[J]);
//        LEntity2.Update(FAxes);
//      end;
//
//      TFEntity(LEntity).FBoundsRect := UdUtils.GetEntitiesBound(TUdDimension(LEntity).EntityList);
//    end
//    else
      LEntity.Update(FAxes);
  end;
  LBound := UdUtils.GetEntitiesBound(FEntities2.List);

  E := UdMath.Max(Abs(LBound.X2 - LBound.X1), Abs(LBound.Y2 - LBound.Y1)) / 10;

  LBound.X1 := LBound.X1 - E;  LBound.X2 := LBound.X2 + E;
  LBound.Y1 := LBound.Y1 - E;  LBound.Y2 := LBound.Y2 + E;

  FAxes.CalcAxis(pnlPreview.Width, pnlPreview.Height, LBound);
  FDrawPanel.Invalidate();
end;

procedure TUdActionInsertForm.OnDrawPanelPaint(Sender: TObject; ACanvas: TCanvas);
var
  I: Integer;
  LEntity: TUdEntity;
begin
  for I := 0 to FEntities2.Count - 1 do
  begin
    LEntity := FEntities2.Items[I];
    LEntity.Draw(ACanvas, FAxes);
  end;
end;







//------------------------------------------------------------------------------------


procedure TUdActionInsertForm.SpecifyOnSecreenClick(Sender: TObject);
var
  LBool: Boolean;
begin
  if not Assigned(Sender) or not Sender.InheritsFrom(TComponent) then Exit;

  LBool := False;
  if Sender.InheritsFrom(TCheckBox) then LBool := TCheckBox(Sender).Checked;

  case TComponent(Sender).Tag of
    0: begin edtPointX.Enabled := not LBool; edtPointY.Enabled := not LBool; end;
    1: begin edtScaleX.Enabled := not LBool; edtScaleY.Enabled := not (LBool or ckbUniformScale.Checked);  end;
    2: begin edtAngle.Enabled := not LBool;  end;
  end;
end;


procedure TUdActionInsertForm.cbxNameChange(Sender: TObject);
begin
  UpdatePrivewBlock();
end;

procedure TUdActionInsertForm.ckbUniformScaleClick(Sender: TObject);
begin
  edtScaleY.Enabled := not ckbUniformScale.Checked;
  if not edtScaleY.Enabled then edtScaleY.Text := edtScaleX.Text;
end;


procedure TUdActionInsertForm.edtScaleXChange(Sender: TObject);
begin
  if not edtScaleY.Enabled then edtScaleY.Text := edtScaleX.Text;
end;


procedure TUdActionInsertForm.btnOKClick(Sender: TObject);
var
  Lx, Ly: Double;
begin
  if Trim(cbxName.Text) = '' then
  begin
    MessageBox(Self.Handle, 'You must specify a block name.', 'Message', MB_ICONWARNING or MB_OK);
    cbxName.SetFocus();
    Exit;  //========>>>>
  end;

  if not Self.SpecifyInsPoint then
  begin
    if not TryStrToFloat(edtPointX.Text, Lx) then
    begin
      MessageBox(Self.Handle, 'Invalid X-coordinate value.', 'Message', MB_ICONWARNING or MB_OK);
      edtPointX.SetFocus();
      Exit;  //========>>>>
    end;

    if not TryStrToFloat(edtPointY.Text, Ly) then
    begin
      MessageBox(Self.Handle, 'Invalid Y-coordinate value.', 'Message', MB_ICONWARNING or MB_OK);
      edtPointX.SetFocus();
      Exit;  //========>>>>
    end;
  end;

  if not Self.SpecifScaleY then
  begin
    if not TryStrToFloat(edtScaleX.Text, Lx) then
    begin
      MessageBox(Self.Handle, 'Invalid X-scale value.', 'Message', MB_ICONWARNING or MB_OK);
      edtScaleX.SetFocus();
      Exit;  //========>>>>
    end;

    if not TryStrToFloat(edtScaleY.Text, Ly) then
    begin
      MessageBox(Self.Handle, 'Invalid Y-scale value.', 'Message', MB_ICONWARNING or MB_OK);
      edtScaleX.SetFocus();
      Exit;  //========>>>>
    end;
  end;

  if not Self.SpecifyRoatation then
  begin
    if not TryStrToFloat(edtAngle.Text, Lx) then
    begin
      MessageBox(Self.Handle, 'Invalid rotation value.', 'Message', MB_ICONWARNING or MB_OK);
      edtAngle.SetFocus();
      Exit;  //========>>>>
    end;
  end;

  Self.ModalResult := mrOk;
end;



end.