{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLayerGrid;

{$I UdDefs.INC}

interface

uses
  Windows, Messages, Forms, Classes, Graphics, Controls, StdCtrls, Grids,

  UdConsts, UdLayers, UdLayer, UdResLayers, UdResStatus;

type

  TUdLayerRenameEvent = procedure(Sender: TObject; Layer: TUdLayer; NewName: string) of object;


  //----------------------------------------------------------

  TUdLayerTitle = class(TPersistent)
  private
    FStatus     : string;
    FName       : string;
    FVisible    : string;
    FFreeze     : string;
    FLock       : string;
    FColor      : string;
    FLinetype   : string;
    FLineweight : string;
    FPlot       : string;

  public
    constructor Create();

  published
    property Status     : string read FStatus     write FStatus;
    property Name       : string read FName       write FName;
    property Visible    : string read FVisible    write FVisible;
    property Freeze     : string read FFreeze     write FFreeze;
    property Lock       : string read FLock       write FLock;
    property Color      : string read FColor      write FColor;
    property Linetype   : string read FLinetype   write FLinetype;
    property Lineweight : string read FLineweight write FLineweight;
    property Plot       : string read FPlot       write FPlot;
  end;




  //----------------------------------------------------------

  TUdLayerGrid = class(TCustomDrawGrid)
  private
    FResLayers: TUdResLayers;
    FResStatus: TUdResStatus;

    FTitle: TUdLayerTitle;
    FLayers: TUdLayers;

    FLastTick: Cardinal;
    FLastCol, FLastRow: Integer;
    
    FEdit: TEdit;

    FOnLayerRename: TUdLayerRenameEvent;
    FOnSelectColor: TUdLayerEvent;
    FOnSelectLineType: TUdLayerEvent;
    FOnSelectLineWeight: TUdLayerEvent;

  protected
    procedure SetLayers(AValue: TUdLayers);
    function GetSelectedItem: TUdLayer;

    procedure CreateParams(var AParams: TCreateParams); override;
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState); override;

    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer); override;

    procedure OnEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnEditLostFocus(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Title: TUdLayerTitle read FTitle write FTitle;
    property Layers: TUdLayers read FLayers write SetLayers;

    property SelectedItem: TUdLayer read GetSelectedItem;

    property OnLayerRename      : TUdLayerRenameEvent read FOnLayerRename      write FOnLayerRename;
    property OnSelectColor      : TUdLayerEvent       read FOnSelectColor      write FOnSelectColor;
    property OnSelectLineType   : TUdLayerEvent       read FOnSelectLineType   write FOnSelectLineType;
    property OnSelectLineWeight : TUdLayerEvent       read FOnSelectLineWeight write FOnSelectLineWeight;

    property Align;
    property Anchors;
    property BorderStyle;
    property Color;
    property Constraints;
    property Ctl3D;
    property DefaultColWidth;
    property DefaultRowHeight;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property Font;
    property GridLineWidth;
    property Options;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property Visible;

    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
  SysUtils, Dialogs,
  UdColor, UdLineWeight;


type
  TUdLayerNameEdit = class(TEdit)
  private
    FOnLostFocus: TNotifyEvent;
  protected
    procedure WMKillFocus(var Message: TMessage); message WM_KillFocus;
  public
    property OnLostFocus: TNotifyEvent read FOnLostFocus write FOnLostFocus;
  end;

{ TUdLayerNameEdit }

procedure TUdLayerNameEdit.WMKillFocus(var Message: TMessage);
begin
  inherited;
  if Assigned(FOnLostFocus) then FOnLostFocus(Self);
end;



//=============================================================================================
{ TUdLayerTitle }

constructor TUdLayerTitle.Create;
begin
  FStatus     := '状态';

//  FName       := 'Name';
//  FVisible    := 'On';
//  FFreeze     := 'Freeze';
//  FLock       := 'Lock';
//  FColor      := 'Color';
//  FLinetype   := 'Linetype';
//  FLineweight := 'Lineweight';
//  FPlot       := 'Plot';

  FName       := '名称';
  FVisible    := '可见';
  FFreeze     := '冻结';
  FLock       := '锁定';
  FColor      := '颜色';
  FLinetype   := '线形';
  FLineweight := '线宽';
  FPlot       := '打印';

end;



//=============================================================================================
{ TUdLayerGrid }

constructor TUdLayerGrid.Create(AOwner: TComponent);
begin
  inherited;

  Self.FixedRows := 1;
  Self.FixedCols := 0;

  Self.ColCount := 9;
  Self.RowCount := 3;

  Self.DefaultRowHeight := 18;

  Self.Options := Options - [goVertLine, goRangeSelect]; //, goHorzLine
  Self.Options := Options + [goColSizing, goRowSelect];

  Self.Width  := 560;
  Self.Height := 260;

  Self.ColWidths[0] := 40;  //Status
  Self.ColWidths[1] := 100; //Name
  Self.ColWidths[2] := 40;  //On
  Self.ColWidths[3] := 50;  //Freeze
  Self.ColWidths[4] := 50;  //Lock
  Self.ColWidths[5] := 90;  //Color
  Self.ColWidths[6] := 100; //Linetype
  Self.ColWidths[7] := 110; //Lineeweight
  Self.ColWidths[8] := 40;  //plot

  FLayers := nil;

  FResLayers := TUdResLayers.Create;
  FResStatus := TUdResStatus.Create;

  FTitle := TUdLayerTitle.Create;

  FLastTick := 0;
  FLastCol  := 0;
  FLastRow  := 0;

  FEdit := TUdLayerNameEdit.Create(Self);
  FEdit.Visible := False;
  FEdit.Parent := Self;
  FEdit.Ctl3D := False;
  FEdit.OnKeyUp :=  OnEditKeyUp;//procedure(Sender: TObject; var Key: Char);
  TUdLayerNameEdit(FEdit).OnLostFocus := OnEditLostFocus;
end;

destructor TUdLayerGrid.Destroy;
begin
  FResLayers.Free;
  FResStatus.Free;
  FTitle.Free;

  FEdit.Free;


  inherited;
end;

procedure TUdLayerGrid.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.WinClassName := 'LayerGrid';
end;




procedure TUdLayerGrid.SetLayers(AValue: TUdLayers);
begin
//  if (FLayers <> AValue) then
  begin
    FLayers := AValue;
    if Assigned(FLayers) then
      Self.RowCount := FLayers.Count + 1;
    Self.Invalidate;
  end;
end;



procedure TUdLayerGrid.OnEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    FEdit.Visible := False;
    if Assigned(FOnLayerRename) then
    begin
      FOnLayerRename(Self, TUdLayer(FEdit.Tag), FEdit.Text);
      Self.Invalidate;
    end;
  end;
end;

procedure TUdLayerGrid.OnEditLostFocus(Sender: TObject);
begin
  if Trim(FEdit.Text) = '' then
  begin
    MessageBox(Application.Handle,
               PChar('图层名称无效.'+#13#10+#13#10+'图层名称必须至少包含一个字符.'), '',
               MB_ICONWARNING or MB_OK);
    FEdit.Text := TUdLayer(FEdit.Tag).Name;
  end;

  FEdit.Visible := False;
  if Assigned(FOnLayerRename) then
  begin
    FOnLayerRename(Self, TUdLayer(FEdit.Tag), FEdit.Text);
    Self.Invalidate;
  end;
end;


function TUdLayerGrid.GetSelectedItem: TUdLayer;
var
  LRect: TGridRect;
  LIndex: Integer;
begin
  Result := nil;

  LRect := Self.Selection;
  LIndex := LRect.Top - 1;

//  if not FByItemsVisible then LIndex := LIndex + 2;
  if (LIndex >= 0) and (LIndex < FLayers.Count) then
    Result := FLayers.Items[LIndex];
end;





//-------------------------------------------------------------------------------------------------

procedure FDrawColor(ACanvas: TCanvas; ARect: TRect; AColor: TUdColor);
var
  LName: string;
  LRect, LRect1: TRect;
begin
  LRect.Left   := ARect.Left + 2;
  LRect.Top    := ARect.Top + 3;
  LRect.Bottom := ARect.Bottom - 2;
  LRect.Right  := ARect.Left + 2 + LRect.Bottom - LRect.Top;

  with ACanvas do
  begin
    Pen.Color := clBlack;
    Pen.Style := psSolid;
    Brush.Style := bsSolid;
    Brush.Color := AColor.RGBValue;
    Rectangle(LRect);
  end;

  //--------------- Text
  LName := AColor.Name_;
  
  LRect1 := ARect;
  LRect1.Left := LRect.Right + 5;
  if LRect1.Left < ARect.Left then LRect1.Left := ARect.Left;

  ACanvas.Brush.Style := bsClear;
  ACanvas.TextRect(LRect1, LRect1.Left, LRect1.Top + (LRect1.Bottom - LRect1.Top - ACanvas.TextHeight(LName)) div 2, LName);
end;

procedure FDrawLineWeight(ACanvas: TCanvas; ARect: TRect; ALineWeight: TUdLineWeight);

  function _CreatePen(Wd: Integer; Co: TColor): HPen;
  var
    LLogBrush: TLogBrush;
  begin
    LLogBrush.lbColor := CO;
    LLogBrush.lbStyle := BS_SOLID;
    LLogBrush.lbHatch := BS_SOLID;
    Result := ExtCreatePen(PS_GEOMETRIC or PS_SOLID or PS_ENDCAP_SQUARE, Wd, LLogBrush, 0, nil);
  end;

var
  Y, W: Integer;
  LName: string;
  LPenWidth: Integer;
  LRect, LRect1: TRect;
begin
  LRect := ARect;

  //--------------- LW
  LRect.Right := LRect.Left + Round((LRect.Right - LRect.Left) - 50);
  if LRect.Right > LRect.Left then
  begin
    LPenWidth := GetLineWeightWidth(ALineWeight);
    
    InflateRect(LRect, -2, -2);

    W := LPenWidth div 2;
    Y := (ARect.Top + ARect.Bottom) div 2;

    ACanvas.Pen.Handle := _CreatePen(LPenWidth, clBlack);

    ACanvas.MoveTo(LRect.Left + W, Y);
    ACanvas.LineTo(LRect.Right - W, Y);
  end;

  //--------------- Text
  LName := UdLineWeight.GetLineWeightName(ALineWeight);

  LRect1 := ARect;
  LRect1.Left := LRect.Right + 5;
  if LRect1.Left < ARect.Left then LRect1.Left := ARect.Left;

  ACanvas.TextRect(LRect1, LRect1.Left, LRect1.Top + (LRect1.Bottom - LRect1.Top - ACanvas.TextHeight(LName)) div 2, LName);
end;

{
STATUS_CURRENT
STATUS_DELETED
STATUS_USELESS
}
procedure FDrawStatus(ACanvas: TCanvas; ARect: TRect; AUIRes: TUdResStatus; AStatus: Cardinal);
var
//  L: Integer;
  LBmp: TBitmap;
begin
  LBmp := AUIRes.NormalBmp;
  if (AStatus and STATUS_DELETED) > 0 then LBmp := AUIRes.DeletedBmp else
  if (AStatus and STATUS_NEW)     > 0 then LBmp := AUIRes.NewBmp else
  if (AStatus and STATUS_USELESS) > 0 then LBmp := AUIRes.UselessBmp;// else;


//  L := ARect.Left + (ARect.Right - ARect.Left) div 2 - 8;
//  ACanvas.Draw(L, ARect.Top + 2, LBmp);

  ACanvas.Draw(2, ARect.Top + 2, LBmp);

  if (AStatus and STATUS_CURRENT) > 0 then
  begin
    LBmp := AUIRes.CurrentBmp;
    ACanvas.Draw(2 + 15, ARect.Top + 2, LBmp);
  end;
end;


procedure TUdLayerGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  L: Integer;
  LLayer: TUdLayer;
begin
  if Assigned(FLayers) then //and (FLayers.List.Count = RowCount - 1)
  begin
//    Self.RowCount := FLayers.Count + 1

    if ARow = 0 then
    begin
      with Canvas do
        case ACol of
          0: TextRect(ARect, ARect.Left + 5,  ARect.Top + 2, FTitle.Status);     //Status
          1: TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Name);       //Name
          2: TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Visible);    //On
          3: TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Freeze);     //Freeze
          4: TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Lock);       //Lock
          5: TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Color);      //Color
          6: TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Linetype);   //Linetype
          7: TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Lineweight); //Lineeweight
          8: TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Plot);       //plot
        end;
    end
    else begin
      LLayer := FLayers.Items[ARow - 1];

      if Assigned(LLayer) then
      begin
        L := ARect.Left + (ARect.Right - ARect.Left) div 2 - 6;

        case ACol of
          0: FDrawStatus(Canvas, ARect, FResStatus, LLayer.Status);
          1: Canvas.TextRect(ARect, ARect.Left + 5, ARect.Top + 2, LLayer.Name);
          2: if LLayer.Visible then Canvas.Draw(L, ARect.Top + 2, FResLayers.VisileBmp) else Canvas.Draw(L, ARect.Top + 2, FResLayers.InvisileBmp);
          3: if LLayer.Freeze then Canvas.Draw(L, ARect.Top + 2, FResLayers.FreezeBmp) else Canvas.Draw(L, ARect.Top + 2, FResLayers.UnfreezeBmp);
          4: if LLayer.Lock then Canvas.Draw(L, ARect.Top + 2, FResLayers.LockBmp) else Canvas.Draw(L, ARect.Top + 2, FResLayers.UnLockBmp);
          5: FDrawColor(Canvas, ARect, LLayer.Color);
          6: Canvas.TextRect(ARect, ARect.Left + 5, ARect.Top + 2, LLayer.LineType.Name);
          7: FDrawLineWeight(Canvas, ARect, LLayer.LineWeight);
          8: if LLayer.Plot then Canvas.Draw(L, ARect.Top + 2, FResLayers.PlotBmp) else Canvas.Draw(L, ARect.Top + 2, FResLayers.UnPlotBmp);
        end;
      end;
    end;

  end;

  inherited DrawCell(ACol, ARow, ARect, AState);
end;





procedure TUdLayerGrid.MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  LLayer: TUdLayer;
  LCol, LRow, N: Longint;
begin
  inherited;
  if not Assigned(FLayers) then Exit;

  Self.MouseToCell(X, Y, LCol, LRow);

  LRow := LRow - 1;
  if (LRow < 0) or (LRow >= FLayers.Count) then Exit;

  LLayer := FLayers.Items[LRow];

  if AButton = mbLeft then
  begin
    case LCol of
      1:
      begin
        if (FLastCol = LCol) and (FLastRow = LRow) and (LRow > 0) then
        begin
            N := GetTickCount() - FLastTick;
            if (N < 5000) and (N > 500) then
            begin
              FEdit.Height := Self.DefaultRowHeight;
              FEdit.Width  := Self.ColWidths[1];
              FEdit.Left   := Self.ColWidths[0];
              FEdit.Top    := Self.DefaultRowHeight * (LRow + 1) + LRow + 1;
              FEdit.Text := LLayer.Name;
              FEdit.Visible := True;
              FEdit.Tag := Integer(LLayer);
              FEdit.SetFocus();
            end;
        end;

        FLastTick := GetTickCount();
      end;
      
      2: LLayer.Visible := not LLayer.Visible;
      3: LLayer.Freeze := not LLayer.Freeze;
      4: LLayer.Lock := not LLayer.Lock;
      5: if Assigned(FOnSelectColor) then FOnSelectColor(Self, LLayer);
      6: if Assigned(FOnSelectLineType) then FOnSelectLineType(Self, LLayer);
      7: if Assigned(FOnSelectLineWeight) then FOnSelectLineWeight(Self, LLayer);
      8: LLayer.Plot := not LLayer.Plot;
    end;

    FLastCol := LCol;
    FLastRow := LRow;
  end;

  Self.Invalidate;
end;



end.