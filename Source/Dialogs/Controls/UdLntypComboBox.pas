{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLntypComboBox;

{$I UdDefs.INC}

interface

uses
  Windows, Messages, Classes, Controls, Graphics, StdCtrls,
  UdTypes, UdConsts, UdLineTypes, UdLinetype;


type
  TUdSelectingLineTypeEvent = procedure(Sender: TObject; ALineType: TUdLineType; var AHandled: Boolean) of object;
  TUdGetUsrLineTypeValueEvent = procedure(Sender: TObject; ALineType: TUdLineType; var AValue: TSingleArray; var AHandled: Boolean) of object;
  
  TUdLntypComboBox = class(TCustomComboBox)
  private
    FLineTypes: TUdLineTypes;
    FSelectedItem: TUdLineType;

    FDoSelect: Boolean;
    FSelectedValid: Boolean;
    
    FOnSelectOther: TNotifyEvent;
    FOnSelectingLineType: TUdSelectingLineTypeEvent;
    FOnGetUsrLineTypeValue: TUdGetUsrLineTypeValueEvent;
    
  protected
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure CreateParams(var AParams: TCreateParams); override;

    procedure Select; override;
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;
    procedure DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState); override;

    procedure PopulateList;

    procedure SetLineTypes(AValue: TUdLineTypes);
    procedure OntLineTypesChange(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetSelected: TUdLineType;
    function SetSelected(AIndex: Integer; AEvent: Boolean = True): Boolean; overload;
    function SetSelected(AValue: TUdLineType; AEvent: Boolean = True): Boolean; overload;

    procedure UpdateState;

    function _SetItem(AIndex: Integer): Boolean; overload;
    function _SetItem(ALineType: TUdLineType): Boolean; overload;

  published
    property LineTypes: TUdLineTypes read FLineTypes write SetLineTypes;
    property OnSelectOther: TNotifyEvent read FOnSelectOther write FOnSelectOther;
    property OnSelectingLineType: TUdSelectingLineTypeEvent read FOnSelectingLineType write FOnSelectingLineType;
    property OnGetUsrLineTypeValue: TUdGetUsrLineTypeValueEvent read FOnGetUsrLineTypeValue write FOnGetUsrLineTypeValue;
    
    property SelectedValid: Boolean read FSelectedValid write FSelectedValid;
    
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
  UdDrawUtil;



const
  DEFAULT_WIDTH = 190;
  DROP_DOWN_COUNT = 12;


type
  TFriendLineType = class(TUdLineType);
  TFriendLineTypes = class(TUdLineTypes);



//=================================================================================================

constructor TUdLntypComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.Style := csOwnerDrawFixed;
  Self.Width := DEFAULT_WIDTH;
  Self.DropDownCount := DROP_DOWN_COUNT;

  FLineTypes := nil;
  FSelectedItem := nil;
  FDoSelect := True;
  FSelectedValid := True;
end;

destructor TUdLntypComboBox.Destroy;
begin
  FLineTypes := nil;
  FSelectedItem := nil;
  
  inherited;
end;


procedure TUdLntypComboBox.CreateWnd;
begin
  inherited CreateWnd;
end;

procedure TUdLntypComboBox.Loaded;
begin
  inherited;
end;

procedure TUdLntypComboBox.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.WinClassName := 'LntypComboBox';
end;




//----------------------------------------------------------------------

function TUdLntypComboBox.GetSelected: TUdLineType;
begin
  Result := FSelectedItem;
  
//  Result := nil;
//  if not Assigned(FLineTypes) then Exit;
//
//  if Self.HandleAllocated() then
//    if ItemIndex >= 0 then Result := FLineTypes.GetItem(ItemIndex);
end;


function TUdLntypComboBox.SetSelected(AIndex: Integer; AEvent: Boolean = True): Boolean;
var
  LValue: TUdLineType;
begin
  Result := False;

  if Self.HandleAllocated() then
  begin
    if Assigned(FLineTypes) then
    begin
      LValue := FLineTypes.GetItem(AIndex);

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

function TUdLntypComboBox.SetSelected(AValue: TUdLineType; AEvent: Boolean = True): Boolean;
var
  N: Integer;
begin
  Result := False;

  if Self.HandleAllocated() then
  begin
    if Assigned(FLineTypes) and Assigned(AValue) then
    begin
      N := FLineTypes.IndexOf(AValue);

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





//----------------------------------------------------------------------

procedure TUdLntypComboBox.Select;
var
  LNewItem: TUdLineType;
  LHandled: Boolean;
begin
  if not Assigned(FLineTypes) then Exit;

  if Self.ItemIndex = Self.Items.Count - 1 then //if Other ....
  begin
    if Assigned(FOnSelectOther) then FOnSelectOther(Self);
  end;

  if Self.ItemIndex = Self.Items.Count - 1 then
  begin
    LNewItem := FSelectedItem;
    Self.ItemIndex := FLineTypes.IndexOf(FSelectedItem);
  end
  else
    LNewItem := FLineTypes.GetItem(Self.ItemIndex);

  if FSelectedItem <> LNewItem then
  begin
    FSelectedItem := LNewItem;
    FSelectedValid := True;
    
    LHandled := False;
    if Assigned(FOnSelectingLineType) then FOnSelectingLineType(Self, FSelectedItem, LHandled);

    if not LHandled then FLineTypes.SetActive(ItemIndex);
    
    if FDoSelect then inherited Select();
  end;
end;


procedure TUdLntypComboBox.CNCommand(var AMessage: TWMCommand);
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


procedure TUdLntypComboBox.DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
var
  LRect: TRect;
  LLineType: TUdLineType;
  LBackground: TColor;
  LValue: TSingleArray;
  LReturn: Boolean;
begin
  with Canvas do
  begin
    FillRect(ARect);
    LBackground := Brush.Color;

    LRect := ARect;
    LRect.Right := LRect.Left + Round((LRect.Right - LRect.Left) * 0.45);
    InflateRect(LRect, -2, -2);

    if AIndex < Items.Count - 1 then // not Others...
    begin
      LLineType := TUdLinetype(Items.Objects[AIndex]);

      if (FSelectedItem = LLineType) and not FSelectedValid then
      begin
        //...
      end
      else begin
        LReturn := False;
        if Assigned(FOnGetUsrLineTypeValue) then FOnGetUsrLineTypeValue(Self, LLineType, LValue, LReturn);

        if LReturn then
          DrawLineType(Canvas, LRect, LValue)
        else
          DrawLineType(Canvas, LRect, LLineType.Value);
      end;
    end;

    Brush.Color := LBackground;
    ARect.Left := LRect.Right + 5;

    TextRect(ARect, ARect.Left,
      ARect.Top + (ARect.Bottom - ARect.Top - TextHeight(Items[AIndex])) div 2, Items[AIndex]);
  end;
end;









//------------------------------------------------------------------------------


procedure TUdLntypComboBox.PopulateList;
var
  I: Integer;
  LLinetype: TUdLinetype;
begin
  if not Assigned(FLineTypes) then
  begin
    Self.Items.Clear;
    FSelectedItem := nil;    
    Exit;
  end;

  FSelectedValid := True;
  
//  if Self.HandleAllocated() then
  begin
    Self.Items.BeginUpdate();
    try
      Items.Clear;
      for I := 0 to FLineTypes.Count - 1 do
      begin
        LLinetype := FLineTypes.Items[I];
        Self.Items.AddObject(LLinetype.Name, LLinetype);
      end;
      FSelectedItem := FLineTypes.Active;
      Self.ItemIndex := FLineTypes.IndexOf(FSelectedItem);

      Self.Items.Add(sSelectOtherLineType);
    finally
      Self.Items.EndUpdate();
    end;
  end;
end;


procedure TUdLntypComboBox.OntLineTypesChange(Sender: TObject);
begin
  PopulateList;
  Self.Invalidate;
end;

procedure TUdLntypComboBox.SetLineTypes(AValue: TUdLineTypes);
begin
//  if (FLineTypes <> AValue) then
  begin
//    if Assigned(AValue) then TFriendLineTypes(AValue).OnChange2 := nil;

    FLineTypes := AValue;
//    if Assigned(FLineTypes) then
//      TFriendLineTypes(FLineTypes).OnChange2 := OntLineTypesChange;

    PopulateList();
  end;
end;







//--------------------------------------------------------------------

function TUdLntypComboBox._SetItem(AIndex: Integer): Boolean;
var
  LValue: TUdLineType;
begin
  Result := False;

  if HandleAllocated and Assigned(FLineTypes) then
  begin
    if Assigned(FLineTypes) and (AIndex >= 0) and (AIndex < FLineTypes.Count) then
    begin
      LValue := FLineTypes.GetItem(AIndex);

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

function TUdLntypComboBox._SetItem(ALineType: TUdLineType): Boolean;
var
  I, N: Integer;
begin
  Result := False;

  if HandleAllocated and Assigned(FLineTypes) then
  begin
    N := FLineTypes.IndexOf(ALineType);
    if N >= 0 then Result := _SetItem(N);

    if not Result then
    begin
      N := -1;

      if Assigned(ALineType) then
      begin
        for I := 0 to FLineTypes.Count - 1 do
        begin
          if (ALineType.Name = FLineTypes.Items[I].Name) then
          begin
            N := I;
            Break;
          end;
        end;
      end;
      
      Result := _SetItem(N);
    end;    
  end;
end;





procedure TUdLntypComboBox.UpdateState;
begin
  Self.PopulateList;
  Self.Invalidate;
end;

end.