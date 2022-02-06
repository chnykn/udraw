{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLwtComboBox;

{$I UdDefs.INC}

interface

uses
  Windows, Messages, Classes, Controls, Graphics, StdCtrls,
  UdLineWeights, UdLineWeight;


type
  TUdSelectingLineWeight = procedure(Sender: TObject; ALineWeight: TUdLineWeight; var AHandled: Boolean) of object;
  
  TUdLwtComboBox = class(TCustomComboBox)
  private
    FLineWeights: TUdLineWeights;
    FSelectedItem: TUdLineWeight;

    FDoSelect: Boolean;
    FOnSelectingLineWeight: TUdSelectingLineWeight;
    
  protected
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure CreateParams(var AParams: TCreateParams); override;

    procedure Select; override;

    procedure WndProc(var Message: TMessage); override;
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;
    procedure DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState); override;

    procedure PopulateList;

    procedure SetLineWeights(AValue: TUdLineWeights);
    procedure OntLineWeightsChange(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetSelected: TUdLineWeight;
    function SetSelected(AIndex: Integer; AEvent: Boolean = True): Boolean; overload;
    function SetSelected(AValue: TUdLineWeight; AEvent: Boolean = True): Boolean; overload;

    procedure UpdateState;

    function _SetItem(AIndex: Integer): Boolean; overload;
    function _SetItem(ALineWeight: TUdLineWeight): Boolean; overload;

  published
    property LineWeights: TUdLineWeights read FLineWeights write SetLineWeights;
    property OnSelectingLineWeight: TUdSelectingLineWeight read FOnSelectingLineWeight write FOnSelectingLineWeight;
    
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
  SysUtils, UdDrawUtil;



const
  DEFAULT_WIDTH = 130;
  DROP_DOWN_COUNT = 32;

//type
//  TFriendLineWeights = class(TUdLineWeights);




//=================================================================================================

constructor TUdLwtComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.Style := csOwnerDrawFixed;
  Self.Width := DEFAULT_WIDTH;
  Self.DropDownCount := DROP_DOWN_COUNT;
  Self.AutoCloseUp := False;

  FLineWeights := nil;
  FSelectedItem := LW_DEFAULT;
  FDoSelect := True;
end;

destructor TUdLwtComboBox.Destroy;
begin
  FLineWeights := nil;
  inherited;
end;


procedure TUdLwtComboBox.CreateWnd;
begin
  inherited CreateWnd;
end;

procedure TUdLwtComboBox.Loaded;
begin
  inherited;
end;

procedure TUdLwtComboBox.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.WinClassName := 'LwtComboBox';
end;




//----------------------------------------------------------------------

function TUdLwtComboBox.GetSelected: TUdLineWeight;
begin
  Result := FSelectedItem;
  
//  Result := LW_DEFAULT;
//  if not Assigned(FLineWeights) then Exit;

//  if Self.HandleAllocated() then
//    if ItemIndex >= 0 then Result := TUdLineWeight(Self.Items.Objects[ItemIndex]);
end;


function TUdLwtComboBox.SetSelected(AIndex: Integer; AEvent: Boolean = True): Boolean;
begin
  Result := False;

  if Self.HandleAllocated() then
  begin
    FDoSelect := AEvent;
    try
      ItemIndex := AIndex;
      Select;
    finally
      FDoSelect := True;
    end;
    Result := True;
  end;
end;

function TUdLwtComboBox.SetSelected(AValue: TUdLineWeight; AEvent: Boolean = True): Boolean;
var
  I, N: Integer;
begin
  Result := False;

  if Self.HandleAllocated() then
  begin
    N := -1;

    for I := 0 to Self.Items.Count - 1 do
    begin
      if TUdLineWeight(Self.Items.Objects[I]) = AValue then
      begin
        N := I;
        Break;
      end;
    end;

    if N >= 0 then
    begin
      FDoSelect := AEvent;
      try
        ItemIndex := N;
        Select;
      finally
        FDoSelect := True;
      end;

      Result := True;
    end;
  end;
end;





//----------------------------------------------------------------------

procedure TUdLwtComboBox.Select;
var
  LNewItem: TUdLineWeight;
  LHandled: Boolean;
begin
  LNewItem := TUdLineWeight(Self.Items.Objects[ItemIndex]);
  
  if FSelectedItem <> LNewItem then
  begin
    FSelectedItem := LNewItem;

    LHandled := False;
    if Assigned(FOnSelectingLineWeight) then FOnSelectingLineWeight(Self, FSelectedItem, LHandled);

    if not LHandled then FLineWeights.SetActive(LNewItem);

    if FDoSelect then inherited Select;
  end;  
end;


procedure TUdLwtComboBox.WndProc(var Message: TMessage);
begin
{
  if not (csDesigning in ComponentState) and (Message.Msg = WM_COMMAND)  then
  begin
//    Dispatch(Message);
    Exit;
  end;
}
//  OutputDebugString(PChar(IntToStr(Message.Msg)));
  
  inherited;
end;

procedure TUdLwtComboBox.CNCommand(var AMessage: TWMCommand);
begin
  case AMessage.NotifyCode of
    CBN_DBLCLK: DblClick;
    //CBN_EDITCHANGE: Change;
    CBN_DROPDOWN:
      begin
//        PopulateList();
        
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
    CBN_CLOSEUP: CloseUp;

    CBN_SETFOCUS:
      begin
        FIsFocused := True;
        FFocusChanged := True;
      end;

    CBN_KILLFOCUS:
      begin
        FIsFocused := False;
        FFocusChanged := True;
        SetSelected(FSelectedItem);
      end;
  end;
end;


procedure TUdLwtComboBox.DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
var
  LRect: TRect;
  LBackground: TColor;
begin
  with Canvas do
  begin
    FillRect(ARect);
    LBackground := Brush.Color;

    LRect := ARect;
    LRect.Right := LRect.Left + Round((LRect.Right - LRect.Left) - 72);
    InflateRect(LRect, -2, -2);

    DrawLineWeight(Canvas, LRect, UdLineWeight.GetLineWeightWidth(TUdLineWeight(Items.Objects[AIndex])) );

    Brush.Color := LBackground;
    ARect.Left := LRect.Right + 10;

    TextRect(ARect, ARect.Left,
      ARect.Top + (ARect.Bottom - ARect.Top - TextHeight(Items[AIndex])) div 2, Items[AIndex]);
  end;
end;









//------------------------------------------------------------------------------


procedure TUdLwtComboBox.PopulateList;
var
  I, N: Integer;
  LLineWeight: TUdLineWeight;
begin
  if not Assigned(FLineWeights) then
  begin
    Self.Items.Clear;
    Exit;
  end;

  
//  if Self.HandleAllocated() then
  begin
    Self.Items.BeginUpdate();
    try
      Self.Items.Clear();
      for I := 0 to Length(ALL_LINE_WEIGHTS) - 1 do
      begin
        LLineWeight := ALL_LINE_WEIGHTS[I];
        Self.Items.AddObject( UdLineWeight.GetLineWeightName(LLineWeight), TObject(LLineWeight) );
      end;

      FSelectedItem := FLineWeights.Active;

      N := -1;
      for I := 0 to Length(ALL_LINE_WEIGHTS) - 1 do
      begin
        if FSelectedItem = ALL_LINE_WEIGHTS[I] then
        begin
          N := I;
          Break;
        end;
      end;
          
      Self.ItemIndex := N;
    finally
      Self.Items.EndUpdate();
    end;
  end;
end;


procedure TUdLwtComboBox.OntLineWeightsChange(Sender: TObject);
begin
  PopulateList;
  Self.Invalidate;
end;

procedure TUdLwtComboBox.SetLineWeights(AValue: TUdLineWeights);
begin
  if (FLineWeights <> AValue) then
  begin
//    if Assigned(AValue) then TFriendLineWeights(AValue).OnChange2 := nil;

    FLineWeights := AValue;
//    if Assigned(FLineWeights) then
//      TFriendLineWeights(FLineWeights).OnChange2 := OntLineWeightsChange;

    PopulateList();
  end;
end;







//--------------------------------------------------------------------

function TUdLwtComboBox._SetItem(AIndex: Integer): Boolean;
var
  LValue: TUdLineWeight;
begin
  Result := False;

  if HandleAllocated and Assigned(FLineWeights) then
  begin
    if Assigned(FLineWeights) and (AIndex >= 0) and (AIndex < Length(ALL_LINE_WEIGHTS)) then
    begin
      LValue := ALL_LINE_WEIGHTS[AIndex];

      FSelectedItem := LValue;
      ItemIndex := AIndex;
    end
    else
    begin
      FSelectedItem := LW_DEFAULT;
      ItemIndex := -1;
    end;

    Result := True;
  end;

  if Result then Self.Invalidate;
end;

function TUdLwtComboBox._SetItem(ALineWeight: TUdLineWeight): Boolean;
var
  I, N: Integer;
begin
  Result := False;

  if HandleAllocated and Assigned(FLineWeights) then
  begin
    N := -1;
    for I := 0 to Length(ALL_LINE_WEIGHTS) - 1 do
    begin
      if ALineWeight = ALL_LINE_WEIGHTS[I] then
      begin
        N := I;
        Break;
      end;
    end;
    Result := _SetItem(N);
  end;
end;


procedure TUdLwtComboBox.UpdateState;
begin
  Self.PopulateList;
  Self.Invalidate;
end;



end.