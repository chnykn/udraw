{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLayersFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,

  UdConsts, UdIntfs, UdObject, UdLayers, UdLayer, UdColor,
  UdLayerGrid, UdLineTypesFrm;

type
  TUdLayersForm = class(TForm)
    pnlTop: TPanel;
    pnlClient: TPanel;
    pnlBottom: TPanel;
    btnNew: TSpeedButton;
    btnDelete: TSpeedButton;
    btnCurrent: TSpeedButton;
    pnlStatus: TPanel;

    btnOK: TButton;
    btnCancel: TButton;
    btnApply: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnCurrentClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);

  private
    FLayers: TUdLayers;
    FLayers2: TUdLayers;
    FLayerGrid: TUdLayerGrid;

    FLineTypesForm: TUdLineTypesForm;

  protected
    procedure Apply();
    
    procedure SetLayers(const Value: TUdLayers);

    procedure OnGridLayerRename(Sender: TObject; ALayer: TUdLayer; ANewName: string);
    procedure OnGridSelectColor(Sender: TObject; ALayer: TUdLayer);
    procedure OnGridSelectLineType(Sender: TObject; ALayer: TUdLayer);
    procedure OnGridSelectLineWeight(Sender: TObject; ALayer: TUdLayer);

  public
    property Layers: TUdLayers read FLayers write SetLayers;
    
  end;


function ShowLayersDialog(ALayers: TUdLayers): Boolean;


implementation

{$R *.dfm}

uses
  SysUtils, UdDocument, UdColorsFrm, UdLineWeightsFrm;

type
  TFObject = class(TUdObject);


function ShowLayersDialog(ALayers: TUdLayers): Boolean;
var
  LForm: TUdLayersForm;
begin
  Result := False;
  if not Assigned(ALayers) then Exit; //===>>>>

  LForm := TUdLayersForm.Create(nil);
  try
    LForm.Layers := ALayers;
    LForm.ShowModal();
  finally
    LForm.Free;
  end;

  Result := True;
end;




//=================================================================================================
{ TUdLayerManagerForm }


procedure TUdLayersForm.FormCreate(Sender: TObject);
begin
  FLayers := nil;
  FLayers2 := nil;
  
  FLayerGrid := TUdLayerGrid.Create(Self);
  FLayerGrid.Parent := pnlClient;
  FLayerGrid.Align := alClient;

  FLayerGrid.OnLayerRename      := OnGridLayerRename;
  FLayerGrid.OnSelectColor      := OnGridSelectColor;
  FLayerGrid.OnSelectLineType   := OnGridSelectLineType;
  FLayerGrid.OnSelectLineWeight := OnGridSelectLineWeight;

  FLineTypesForm := TUdLineTypesForm.Create(nil);
  FLineTypesForm.ManageMode := False;
end;

procedure TUdLayersForm.FormDestroy(Sender: TObject);
begin
  FLayers := nil;
  
  FLayerGrid.Free();
  FLayerGrid := nil;

  FLineTypesForm.Free;
  FLineTypesForm := nil;

  if Assigned(FLayers2) then FLayers2.Free;
  FLayers2 := nil;
end;

procedure TUdLayersForm.FormShow(Sender: TObject);
begin
//
end;


procedure TUdLayersForm.OnGridLayerRename(Sender: TObject; ALayer: TUdLayer; ANewName: string);
begin
  if Assigned(ALayer) and (ALayer.Name <> ANewName) then
  begin
    if FLayers2.IndexOf(ANewName) < 0 then ALayer.Name := ANewName;
  end;
end;

procedure TUdLayersForm.OnGridSelectColor(Sender: TObject; ALayer: TUdLayer);
var
  LForm: TUdColorsForm;
  LValue: Integer;
begin
  LForm := TUdColorsForm.Create(nil);
  try
    if ALayer.Color.ColorType = ctIndexColor then
    begin
      LForm.IsIndexColor := True;
      LForm.ColorValue := ALayer.Color.IndexColor;
    end
    else begin
      LForm.IsIndexColor := False;
      LForm.ColorValue := ALayer.Color.TrueColor;
    end;

    LForm.btnByLayer.Enabled := False;
    LForm.btnByBlock.Enabled := False;

    if LForm.ShowModal() = mrOk then
    begin
      LValue := LForm.ColorValue;
      
      if LForm.IsIndexColor then
      begin
        if LValue in [1..255] then
          ALayer.Color.IndexColor := LValue;
      end
      else begin
        ALayer.Color.TrueColor := LValue;
      end;
    end;
  finally
    LForm.Free;
  end;
end;

procedure TUdLayersForm.OnGridSelectLineType(Sender: TObject; ALayer: TUdLayer);
begin
  if FLineTypesForm.ShowModal() = mrOk then
  begin
    ALayer.LineType.Assign(FLineTypesForm.SelectedItem);
  end;
end;

procedure TUdLayersForm.OnGridSelectLineWeight(Sender: TObject; ALayer: TUdLayer);
var
  LForm: TUdLineWeightsForm;
begin
  LForm := TUdLineWeightsForm.Create(nil);
  try
    LForm.ManageMode := False;
    LForm.CurrentLwt := ALayer.LineWeight;
    if LForm.ShowModal() = mrOk then
    begin
      if LForm.IsAnySelected then
        ALayer.LineWeight := LForm.SelectedLwt;
    end;
  finally
    LForm.Free;
  end;
end;




//---------------------------------------------------------------------------------------------

procedure TUdLayersForm.SetLayers(const Value: TUdLayers);
var
  I: Integer;
begin
  if Assigned(FLayers2) then FLayers2.Free;
  FLayers2 := nil;
  
  FLayers := Value;
  if Assigned(FLayers.Document) then
  begin
    TUdDocument(FLayers.Document).UpdateLayersStatus();
    FLineTypesForm.LineTypes := TUdDocument(FLayers.Document).LineTypes;
  end;

  FLayers2 := TUdLayers.Create();
  FLayers2.Assign(FLayers);

  for I := 0 to FLayers.Count - 1 do
    TFObject(FLayers2.Items[I]).SetID( FLayers.Items[I].ID );

  FLayerGrid.Layers := FLayers2;
  pnlStatus.Caption := ' 当前图层: ' + FLayers2.Active.Name;
end;





procedure TUdLayersForm.btnNewClick(Sender: TObject);
var
  I: Integer;
  LName: string;
  LLayer: TUdLayer;
begin
  I := 1;
  
  LName := '图层' + IntToStr(I);
  while FLayers2.IndexOf(LName) >= 0 do
  begin
    Inc(I);
    LName := '图层' + IntToStr(I);
  end;

  LLayer := TUdLayer.Create();
  LLayer.Name := LName;
  LLayer.Status := STATUS_NEW or STATUS_USELESS;
  FLayers2.Add(LLayer);

  FLayerGrid.Layers := FLayers2;
end;

procedure TUdLayersForm.btnDeleteClick(Sender: TObject);
var
  LLayer: TUdLayer;
begin
  if Assigned(FLayerGrid.SelectedItem) then
  begin
    LLayer := FLayerGrid.SelectedItem;

    if (LLayer.Name = '0') or
       (LLayer.Status and STATUS_CURRENT > 0) or
       (LLayer.Status and STATUS_USELESS <= 0) then
    begin
      MessageBox(Self.Handle, PChar('未删除选择的图层.'+#13#10+#13#10+
                                    '不能删除下列图层:'+#13#10+
                                    '	图层0 和 定义点'+#13#10+
                                    '	当前图层'+#13#10+
                                    '	依赖外部参照的图层'+#13#10+
                                    '	包含对象的图层'), '', MB_ICONWARNING or MB_OK);
      Exit; //==========>>>>>>>
    end;

    if LLayer.Status and STATUS_DELETED > 0 then
      LLayer.Status := LLayer.Status and not STATUS_DELETED
    else
      LLayer.Status := LLayer.Status or STATUS_DELETED;

    FLayerGrid.Invalidate;
  end;
end;

procedure TUdLayersForm.btnCurrentClick(Sender: TObject);
var
  I: Integer;
  LLayer: TUdLayer;
begin
  if Assigned(FLayerGrid.SelectedItem) then
  begin
    LLayer := FLayerGrid.SelectedItem;
    
    if (LLayer.Freeze) or
       (LLayer.Status and STATUS_DELETED > 0) then
    begin
      MessageBox(Self.Handle, PChar('选择的图层不能置为当前.'+#13#10+#13#10+
                                    '不能将下列图层置为当前:'+#13#10+
                                    '	依赖外部参照的图层'+#13#10+
                                    '	已冻结的图层'+#13#10+
                                    '	已删除的图层'), '', MB_ICONWARNING or MB_OK);
      Exit; //==========>>>>>>>
    end;

    for I := 0 to FLayers2.Count - 1 do
    begin
      LLayer := FLayers2.Items[I];
      LLayer.Status := LLayer.Status and not STATUS_CURRENT;
    end;

    LLayer := FLayerGrid.SelectedItem;
    LLayer.Status := LLayer.Status or STATUS_CURRENT;

    FLayerGrid.Invalidate;

    FLayers2.Active := LLayer;
    pnlStatus.Caption := ' 当前图层: ' + FLayers2.Active.Name;
  end;
end;





//---------------------------------------------------------------------------------------------

procedure TUdLayersForm.Apply();

  function _GetLayer(ALayer2: TUdLayer): TUdLayer;
  var
    I: Integer;
  begin
    Result := nil;
    if ALayer2.ID <= 0 then Exit;

    for I := 0 to FLayers.Count - 1 do
    begin
      if FLayers.Items[I].ID = ALayer2.ID then
      begin
        Result := FLayers.Items[I];
        Break;
      end;
    end;
  end;

var
  I: Integer;
  LLayer, LLayer2: TUdLayer;
  LUndoRedo: IUdUndoRedo;
begin
  if Assigned(FLayers) and Assigned(FLayers.Document) and FLayers.IsDocRegister then
    FLayers.Document.GetInterface(IUdUndoRedo, LUndoRedo);

  if Assigned(LUndoRedo) then LUndoRedo.BeginUndo('');
  try
    FLineTypesForm.Apply();
    
    for I := 0 to FLayers2.Count - 1 do
    begin
      LLayer2 := FLayers2.Items[I];
      LLayer  := _GetLayer(LLayer2);

      if Assigned(LLayer) then
      begin
        if LLayer2.Status and STATUS_DELETED > 0 then
        begin
          FLayers.Remove(LLayer);
        end
        else begin
          LLayer.Assign(LLayer2);
          if LLayer2.Status and STATUS_CURRENT > 0 then FLayers.SetActive(LLayer);
        end;
      end
      else begin
        if LLayer2.Status and STATUS_DELETED <= 0 then
        begin
          LLayer := TUdLayer.Create(FLayers.Document, True);
          LLayer.Assign(LLayer2);
          FLayers.Add(LLayer);

          TFObject(LLayer2).SetID( LLayer.ID );
          if LLayer2.Status and STATUS_CURRENT > 0 then FLayers.SetActive(LLayer);
        end;
      end;
    end;
  finally
    if Assigned(LUndoRedo) then LUndoRedo.EndUndo();
  end;

  for I := FLayers2.Count - 1 downto 0 do
  begin
    LLayer2 := FLayers2.Items[I];
    if LLayer2.Status and STATUS_DELETED > 0 then
      FLayers2.RemoveAt(I);
  end;

  FLayerGrid.Layers := FLayers2;
end;

procedure TUdLayersForm.btnOKClick(Sender: TObject);
begin
  Self.Apply();
  Self.ModalResult := mrOk;
end;

procedure TUdLayersForm.btnApplyClick(Sender: TObject);
begin
  Self.Apply();
end;

end.