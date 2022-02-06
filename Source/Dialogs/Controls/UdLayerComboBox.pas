{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLayerComboBox;

{$I UdDefs.INC}

interface

uses
  Windows, Messages, Classes, Controls, Graphics, StdCtrls,
  UdIntfs, UdLayers, UdLayer, UdResLayers;


type
  TUdSelectingLayer = procedure(Sender: TObject; ALayer: TUdLayer; var AHandled: Boolean) of object;
  
  //*** TUdLayerComboBox ***//
  TUdLayerComboBox = class(TCustomComboBox)
  private
    FResLayers: TUdResLayers;
    FLayers: TUdLayers;
    FSelectedItem: TUdLayer;
    FFocusedIndex: Integer;

    FDoSelect: Boolean;
    FOnSelectingLayer: TUdSelectingLayer;
    
  protected
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure CreateParams(var AParams: TCreateParams); override;

    procedure Select; override;
    procedure DropDown; override;
    procedure CloseUp; override;
        
    procedure WndProc(var Message: TMessage); override;
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;
    procedure DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState); override;

    procedure PopulateList;

    procedure SetLayers(AValue: TUdLayers);
    procedure OnLayersChange(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetSelected: TUdLayer;
    function SetSelected(AIndex: Integer; AEvent: Boolean = True): Boolean; overload;
    function SetSelected(AValue: TUdLayer; AEvent: Boolean = True): Boolean; overload;

    procedure UpdateState;

    function _SetItem(AIndex: Integer; AEvent: Boolean = True): Boolean; overload;
    function _SetItem(ALayer: TUdLayer; AEvent: Boolean = True): Boolean; overload;

  published
    property Layers: TUdLayers read FLayers write SetLayers;
    property OnSelectingLayer: TUdSelectingLayer read FOnSelectingLayer write FOnSelectingLayer;
      
    property AutoComplete;
    property AutoDropDown;

    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BiDiMode;
    property Color;
    property Constraints;
    property Ctl3D;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;

    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDock;
    property OnStartDrag;

    property OnCloseUp;
    property OnClick;
    property OnSelect;

  end;

implementation


uses
  Themes;

const
  DEFAULT_WIDTH = 210;
  DROP_DOWN_COUNT = 12;


type
  TFriendLayers = class(TUdLayers);




function DrawLayer(ACanvas: TCanvas; ARect: TRect; ALayer: TUdLayer; AUIRes: TUdResLayers): Boolean;
var
  LBackground: TColor;
begin
  Result := False;
  if not Assigned(ACanvas) then Exit;

  with ACanvas do
  begin
    FillRect(ARect);
    LBackground := Brush.Color;

    if Assigned(ALayer) and Assigned(AUIRes) then
    begin
      if ALayer.Visible then
        Draw(02, ARect.Top + 1, AUIRes.VisileBmp)
      else
        Draw(02, ARect.Top + 1, AUIRes.InvisileBmp);

      if ALayer.Freeze then
        Draw(20, ARect.Top + 1, AUIRes.FreezeBmp)
      else
        Draw(20, ARect.Top + 1, AUIRes.UnFreezeBmp);
        
      if ALayer.Lock then
        Draw(40, ARect.Top + 1, AUIRes.LockBmp)
      else
        Draw(40, ARect.Top + 1, AUIRes.UnLockBmp);

      Pen.Color := clBlack;
      Brush.Color := ALayer.Color.RGBValue;
      Rectangle(60, ARect.Top + 4, 70, ARect.Top + 14);

      //if ALayer.Freeze then
      //  Font.Color := clGrayText;

      Brush.Color := LBackground;
      TextOut(80, ARect.Top + (ARect.Bottom - ARect.Top - TextHeight(ALayer.Name)) div 2, ALayer.Name);
    end;
  end;

  Result := True;
end;

  

//=================================================================================================
{ TUdLayerComboBox }

constructor TUdLayerComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.Style := csOwnerDrawFixed;
  Self.Width := DEFAULT_WIDTH;
  Self.DropDownCount := DROP_DOWN_COUNT;

  FResLayers := TUdResLayers.Create;
    
  FLayers := nil;
  FSelectedItem := nil;
  FFocusedIndex := -1;
  FDoSelect := True;
end;

destructor TUdLayerComboBox.Destroy;
begin
  FResLayers.Free;
  FResLayers := nil;
  FLayers := nil;
  FSelectedItem := nil;
  inherited Destroy;
end;


procedure TUdLayerComboBox.CreateWnd;
begin
  inherited CreateWnd;
  //if FNeedPopulate then PopulateList;
end;

procedure TUdLayerComboBox.Loaded;
begin
  inherited;
  //  Selected := FDefaultColor;
end;

procedure TUdLayerComboBox.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.WinClassName := 'LayerComboBox';
end;





//-------------------------------------------------------------------------

function TUdLayerComboBox.GetSelected: TUdLayer;
begin
  Result := FSelectedItem;
  
//  Result := nil;
//  if not Assigned(FLayers) then Exit;
//
//  if Self.HandleAllocated() then
//    if ItemIndex >= 0 then Result := FLayers.GetItem(ItemIndex);
end;

function TUdLayerComboBox.SetSelected(AIndex: Integer; AEvent: Boolean = True): Boolean;
var
  LValue: TUdLayer;
begin
  Result := False;

  if Self.HandleAllocated() then
  begin
    if Assigned(FLayers) then
    begin
      LValue := FLayers.GetItem(AIndex);

      if Assigned(LValue) then
      begin
        FSelectedItem := LValue;

        FDoSelect := AEvent;
        try
          ItemIndex := AIndex;
          Select;
        finally
          FDoSelect := True;
        end;

        Result := True;
      end;
    end
    else
    begin
      FSelectedItem := nil;
      ItemIndex := -1;
    end;
  end;
end;

function TUdLayerComboBox.SetSelected(AValue: TUdLayer; AEvent: Boolean = True): Boolean;
var
  N: Integer;
begin
  Result := False;

  if Self.HandleAllocated() then
  begin
    if Assigned(FLayers) and Assigned(AValue) then
    begin
      N := FLayers.IndexOf(AValue);
      if (N >= 0) and (N <> ItemIndex) then
      begin
        FSelectedItem := AValue;

        FDoSelect := AEvent;
        try
          ItemIndex := N;
          Select;
        finally
          FDoSelect := True;
        end;

        Result := True;
      end;
    end
    else
    begin
      FSelectedItem := nil;
      ItemIndex := -1;
    end;
  end;
end;




//-------------------------------------------------------------------------

procedure TUdLayerComboBox.Select;
var
  LNewItem: TUdLayer;
  LHandled: Boolean;
begin
  LNewItem := FLayers.GetItem(ItemIndex);
  
  if FSelectedItem <> LNewItem then
  begin
    FSelectedItem := LNewItem;

    LHandled := False;
    if Assigned(FOnSelectingLayer) then FOnSelectingLayer(Self, FSelectedItem, LHandled);

    if not LHandled then FLayers.SetActive(ItemIndex);

    if FDoSelect then inherited Select;
  end;
end;

procedure TUdLayerComboBox.CloseUp;
var
  LUndoRedo: IUdUndoRedo;
begin
  inherited;
  if Assigned(FLayers) and Assigned(FLayers.Document) and FLayers.IsDocRegister then
  begin
    if FLayers.Document.GetInterface(IUdUndoRedo, LUndoRedo) then
      LUndoRedo.EndUndo();
  end;
end;

procedure TUdLayerComboBox.DropDown;
var
  LUndoRedo: IUdUndoRedo;
begin
  inherited;
  if Assigned(FLayers) and Assigned(FLayers.Document) and FLayers.IsDocRegister then
  begin
    if FLayers.Document.GetInterface(IUdUndoRedo, LUndoRedo) then
      LUndoRedo.BeginUndo('');
  end;
end;


procedure TUdLayerComboBox.WndProc(var Message: TMessage);
var
  N: Integer;
  LPnt: TPoint;
  LLayer: TUdLayer;
begin
  if not (csDesigning in ComponentState) and (Message.Msg = WM_COMMAND) and
    (FFocusedIndex >= 0) and Assigned(FLayers) then
  begin
    LLayer := FLayers.Items[FFocusedIndex];

    if Assigned(LLayer) then
    begin
      Windows.GetCursorPos(LPnt);
      LPnt := Self.ScreenToClient(LPnt);

      N := LPnt.X div 20;

      if N in [0..2] then
      begin
        case N of
          0: LLayer.Visible := not LLayer.Visible;
          1: LLayer.Freeze  := not LLayer.Freeze;
          2: LLayer.Lock    := not LLayer.Lock;
        end;

//        if FDropHandle > 0 then
//        begin
//          LRect := Rect(0, FFocusedIndex * Self.ItemHeight, Self.Width, (FFocusedIndex + 1) * Self.ItemHeight);
//          Windows.InvalidateRect(Windows.GetFocus(), @LRect, True);
//        end;

//        SendMessage(Handle, CB_SETCURSEL, Self.ItemIndex, 0);

        SendMessage(Handle, CB_SETCURSEL, -1, 0);

        Message.Result := 0;
        Exit; //======>>>>>
      end;
    end;
  end;

  inherited;
end;

procedure TUdLayerComboBox.CNCommand(var AMessage: TWMCommand);
begin
  case AMessage.NotifyCode of
    CBN_DBLCLK: DblClick;
    //CBN_EDITCHANGE: Change;
    CBN_DROPDOWN:
      begin
        //PopulateList();
        
        FFocusChanged := False;
        DropDown;
        AdjustDropDown;
        if FFocusChanged then
        begin
          PostMessage(Handle, WM_CANCELMODE, 0, 0);
          if not FIsFocused then PostMessage(Handle, CB_SHOWDROPDOWN, 0, 0);
        end;
      end;
    CBN_SELCHANGE:
      begin
        Text := Items[ItemIndex];
        Click;
        Select;
      end;
    CBN_CLOSEUP:
      begin
        FFocusedIndex := -1;
        CloseUp;
      end;

    CBN_SETFOCUS:
      begin
        FIsFocused := True;
        FFocusChanged := True;
      end;

    CBN_KILLFOCUS:
      begin
        FFocusedIndex := -1;
        FIsFocused := False;
        FFocusChanged := True;
        SetSelected(FSelectedItem);
      end;
  end;
end;

procedure TUdLayerComboBox.DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
begin
  if (odComboBoxEdit in AState) and (AIndex < 0) then
    DrawLayer(Canvas, ARect, FSelectedItem, FResLayers) //TUdLayer(Items.Objects[AIndex])
  else
    DrawLayer(Canvas, ARect, TUdLayer(Items.Objects[AIndex]), FResLayers);    //TUdLayer(Items.Objects[AIndex])

  if odFocused in AState then
    FFocusedIndex := AIndex;


end;







//------------------------------------------------------------------------------

procedure TUdLayerComboBox.PopulateList;
var
  I: Integer;
  LLayer: TUdLayer;
begin
  if not Assigned(FLayers) then
  begin
    Self.Items.Clear;
    FSelectedItem := nil;    
    Exit;
  end;

  if Self.HandleAllocated() then
  begin
    Self.Items.BeginUpdate();
    try
      Items.Clear;
      for I := 0 to FLayers.Count - 1 do
      begin
        LLayer := FLayers.Items[I];
        Self.Items.AddObject(LLayer.Name, LLayer);
      end;
      FSelectedItem := FLayers.Active;
      Self.ItemIndex := FLayers.IndexOf(FSelectedItem);
    finally
      Self.Items.EndUpdate();
    end;
  end;
end;


procedure TUdLayerComboBox.OnLayersChange(Sender: TObject);
begin
  //Update();
end;


procedure TUdLayerComboBox.SetLayers(AValue: TUdLayers);
begin
  if (FLayers <> AValue) then
  begin
//    if Assigned(AValue) then TFriendLayers(AValue).OnChange2 := nil;

    FLayers := AValue;
//    if Assigned(FLayers) then
//      TFriendLayers(FLayers).OnChange2 := OntLayersChange;

    PopulateList();
  end;
end;







//--------------------------------------------------------------------

function TUdLayerComboBox._SetItem(AIndex: Integer; AEvent: Boolean = True): Boolean;
var
  LValue: TUdLayer;
begin
  Result := False;

  if HandleAllocated and Assigned(FLayers) then
  begin
    if Assigned(FLayers) and (AIndex >= 0) and (AIndex < FLayers.Count) then
    begin
      LValue := FLayers.GetItem(AIndex);

      FSelectedItem := LValue;
      ItemIndex := AIndex;
    end
    else
    begin
      FSelectedItem := nil;
      ItemIndex := -1;
    end;

    Result := True;
  end;

  if Result then Self.Invalidate;
end;

function TUdLayerComboBox._SetItem(ALayer: TUdLayer; AEvent: Boolean = True): Boolean;
begin
  Result := False;

  if HandleAllocated and Assigned(FLayers) then
    Result := _SetItem(FLayers.IndexOf(ALayer));
end;





procedure TUdLayerComboBox.UpdateState;
begin
  Self.PopulateList();
  Self.Invalidate;
end;





end.