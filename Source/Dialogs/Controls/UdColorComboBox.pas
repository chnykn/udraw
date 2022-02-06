{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdColorComboBox;

{$I UdDefs.INC}

interface

uses
  Windows, Messages, Classes, Controls, Graphics, StdCtrls,
  UdConsts, UdColors, UdColor;


type
  TUdSelectingColorEvent = procedure(Sender: TObject; AColor: TUdColor; var AHandled: Boolean) of object;
  TUdGetUsrRGBColorEvent = procedure(Sender: TObject; AColor: TUdColor; var ARRBColor: TColor; var AHandled: Boolean) of object;

  TUdColorComboBox = class(TCustomComboBox)
  private
    FColors: TUdColors;
    FSelectedItem: TUdColor;

    FDoSelect: Boolean;
    FSelectedValid: Boolean;
    
    FOnSelectOther: TNotifyEvent;
    FOnSelectingColor: TUdSelectingColorEvent;
    FOnGetUsrRGBColor: TUdGetUsrRGBColorEvent;


  protected
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure CreateParams(var AParams: TCreateParams); override;

    procedure Select; override;
    procedure CNCommand(var AMessage: TWMCommand); message CN_COMMAND;
    procedure DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState); override;

    procedure PopulateList;

    procedure SetColors(AValue: TUdColors);
    procedure OnColorsChange(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetSelected: TUdColor;
    function SetSelected(AIndex: Integer; AEvent: Boolean = True): Boolean; overload;
    function SetSelected(AValue: TUdColor; AEvent: Boolean = True): Boolean; overload;

    procedure UpdateState;

    function _SetItem(AIndex: Integer): Boolean; overload;
    function _SetItem(AColor: TUdColor): Boolean; overload;

  published
    property Colors: TUdColors read FColors write SetColors;
    property OnSelectOther: TNotifyEvent read FOnSelectOther write FOnSelectOther;
    property OnSelectingColor: TUdSelectingColorEvent read FOnSelectingColor write FOnSelectingColor;
    property OnGetUsrRGBColor: TUdGetUsrRGBColorEvent read FOnGetUsrRGBColor write FOnGetUsrRGBColor;

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



const
  DEFAULT_WIDTH = 150;
  DROP_DOWN_COUNT = 12;


type
  TFriendColor = class(TUdColor);
  TFriendColors = class(TUdColors);




  //=====================================================================================

constructor TUdColorComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.Width := DEFAULT_WIDTH;
  Self.Style := csOwnerDrawFixed;
  Self.DropDownCount := DROP_DOWN_COUNT;
  Self.AutoCloseUp := False;
  
  FColors := nil;
  FSelectedItem := nil;
  FDoSelect := True;
  FSelectedValid := True;
end;

destructor TUdColorComboBox.Destroy;
begin
  FColors := nil;
  FSelectedItem := nil;
  
  inherited;
end;


procedure TUdColorComboBox.CreateWnd;
begin
  inherited CreateWnd;
end;

procedure TUdColorComboBox.Loaded;
begin
  inherited;
end;

procedure TUdColorComboBox.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.WinClassName := 'ColorComboBox';
end;




//----------------------------------------------------------------------

function TUdColorComboBox.GetSelected: TUdColor;
begin
  Result := FSelectedItem;
//  Result := nil;
//  if not Assigned(FColors) then Exit;
//
//  if Self.HandleAllocated() then
//    if ItemIndex >= 0 then Result := FColors.GetItem(ItemIndex);
end;

function TUdColorComboBox.SetSelected(AIndex: Integer; AEvent: Boolean = True): Boolean;
var
  LValue: TUdColor;
begin
  Result := False;
  if AIndex = ItemIndex then Exit;

  if Self.HandleAllocated() then
  begin
    if Assigned(FColors) then
    begin
      LValue := FColors.GetItem(AIndex);

      if Assigned(LValue) then
      begin
        FSelectedItem := LValue;

        FDoSelect := AEvent;
        try
          Self.ItemIndex := AIndex;
          Self.Select();
        finally
          FDoSelect := True;
        end;

        Result := True;
      end;
    end
    else
    begin
      FSelectedItem := nil;
      Self.ItemIndex := -1;
    end;
  end;
end;

function TUdColorComboBox.SetSelected(AValue: TUdColor; AEvent: Boolean = True): Boolean;
var
  N: Integer;
begin
  Result := False;

  if Self.HandleAllocated() then
  begin
    if Assigned(FColors) and Assigned(AValue) then
    begin
      N := FColors.IndexOf(AValue);

      if (N >= 0) and (N <> ItemIndex) then
      begin
        FSelectedItem := AValue;

        FDoSelect := AEvent;
        try
          Self.ItemIndex := N;
          Self.Select();
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

procedure TUdColorComboBox.Select;
var
//  LIndex: Integer;
  LNewItem: TUdColor;
  LHandled: Boolean;
begin
  if not Assigned(FColors) then Exit;

  if Self.ItemIndex = Self.Items.Count - 1 then //if Others color ....
  begin
    if Assigned(FOnSelectOther) then FOnSelectOther(Self);
  end;

  if Self.ItemIndex = Self.Items.Count - 1 then
  begin
    LNewItem := FSelectedItem;
    Self.ItemIndex := FColors.IndexOf(FSelectedItem);
  end
  else
    LNewItem := FColors.GetItem(Self.ItemIndex);
  
  if Assigned(LNewItem) and (FSelectedItem <> LNewItem) then
  begin
    FSelectedItem := LNewItem;
    FSelectedValid := True;

    LHandled := False;
    if Assigned(FOnSelectingColor) then FOnSelectingColor(Self, FSelectedItem, LHandled);

    if not LHandled then FColors.SetActive(ItemIndex);
    
    if FDoSelect then inherited Select();
  end;
end;

procedure TUdColorComboBox.CNCommand(var AMessage: TWMCommand);
begin
  case AMessage.NotifyCode of
    CBN_DBLCLK: DblClick;
    //CBN_EDITCHANGE: Change;
    CBN_DROPDOWN:
      begin
//        PopulateList();
        
        FFocusChanged := False;
        Self.DropDown();
        Self.AdjustDropDown();
        if FFocusChanged then
        begin
          PostMessage(Handle, WM_CANCELMODE, 0, 0);
          if not FIsFocused then PostMessage(Handle, CB_SHOWDROPDOWN, 0, 0);
        end;
      end;
    CBN_SELCHANGE:
      begin
        Self.Text := Items[ItemIndex];
        Self.Click();
        Self.Select();
      end;
    CBN_CLOSEUP: Self.CloseUp();

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


procedure TUdColorComboBox.DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
var
  LRect: TRect;
  LColor: TUdColor;
  LRGBColor: TColor;
  LBackground: TColor;
  LReturn: Boolean;
begin
  with Canvas do
  begin
    FillRect(ARect);
    LBackground := Brush.Color;

    LRect := ARect;
    LRect.Right := LRect.Bottom - LRect.Top + LRect.Left;
    LRect.Left := LRect.Left + 4;
    LRect.Top := LRect.Top + 2;
    LRect.Bottom := LRect.Bottom - 2;
    //    InflateRect(LRect, -2, -2);

    if AIndex < Items.Count - 1 then // not Others...
    begin
      LColor := TUdColor(Items.Objects[AIndex]);
       
      Pen.Color := clBlack;
      Pen.Style := psSolid;

      if (FSelectedItem = LColor) and not FSelectedValid then
      begin
        //....
      end
      else begin
        LReturn := False;
        if Assigned(FOnGetUsrRGBColor) then FOnGetUsrRGBColor(Self, LColor, LRGBColor, LReturn);

        if LReturn then
          Brush.Color := LRGBColor
        else
          Brush.Color := LColor.RGBValue;
              
        Rectangle(LRect);
      end;
    end;

    Brush.Color := LBackground;
    ARect.Left := LRect.Right + 5;

    TextRect(ARect, ARect.Left,
      ARect.Top + (ARect.Bottom - ARect.Top - TextHeight(Items[AIndex])) div 2, Items[AIndex]);
  end;
end;









//------------------------------------------------------------------------------

procedure TUdColorComboBox.PopulateList;
var
  I: Integer;
  LColor: TUdColor;
begin
  if not Assigned(FColors) then
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
      Self.Items.Clear;
      for I := 0 to FColors.Count - 1 do
      begin
        LColor := FColors.Items[I];
        Self.Items.AddObject(LColor.Name, LColor);
      end;
      FSelectedItem := FColors.Active;
      Self.ItemIndex := FColors.IndexOf(FSelectedItem);

      Self.Items.Add(sSelectOtherColor);
    finally
      Self.Items.EndUpdate();
    end;
  end;
end;





procedure TUdColorComboBox.OnColorsChange(Sender: TObject);
begin
  Self.PopulateList();
  Self.Invalidate;
end;

procedure TUdColorComboBox.SetColors(AValue: TUdColors);
begin
//  if (FColors <> AValue) then
  begin
//    if Assigned(AValue) then TFriendColors(AValue).OnChange2 := nil;

    FColors := AValue;
//    if Assigned(FColors) then
//      TFriendColors(FColors).OnChange2 := OnColorsChange;

    PopulateList();
  end;
end;






//--------------------------------------------------------------------

function TUdColorComboBox._SetItem(AIndex: Integer): Boolean;
var
  LValue: TUdColor;
begin
  Result := False;

  if HandleAllocated and Assigned(FColors) then
  begin
    if Assigned(FColors) and (AIndex >= 0) and (AIndex < FColors.Count) then
    begin
      LValue := FColors.GetItem(AIndex);

      FSelectedItem := LValue;
      Self.ItemIndex := AIndex;
    end
    else
    begin
      FSelectedItem := nil;
      Self.ItemIndex := -1;
    end;

    Result := True;
  end;

  if Result then Self.Invalidate;
end;

function TUdColorComboBox._SetItem(AColor: TUdColor): Boolean;
 {
  function _IsEqual(AColor1, AColor2: TUdColor): Boolean;
  begin
    Result := False;

    if (AColor1.ByKind = AColor2.ByKind) and (AColor1.ByKind in [bkByLayer, bkByBlock]) then
    begin
      Result := True;
      Exit;
    end;

    if  (AColor1.ByKind = AColor2.ByKind) and (AColor1.ColorType = AColor2.ColorType) then
    begin
      case AColorType of
        ctTrueColor : Result := AObject.TrueColor  = AValue;
        ctIndexColor: Result := AObject.IndexColor = AValue;
      end;
    end;
  end;
 }
  
var
  I, N: Integer;
begin
  Result := False;

  if HandleAllocated and Assigned(FColors) then
  begin
    N := FColors.IndexOf(AColor);
    if N >= 0 then Result := _SetItem(N);

    if not Result then
    begin
      N := -1;
      
      if Assigned(AColor) then
      begin
        for I := 0 to FColors.Count - 1 do
        begin
          if (AColor.Name = FColors.Items[I].Name) then //_IsEqual(AColor, FColors.Items[I]) then
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




procedure TUdColorComboBox.UpdateState;
begin
  Self.PopulateList;
  Self.Invalidate;
end;

end.