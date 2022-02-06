
unit UdCmdLine;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls,
  UdConsts;

const
  CMD_OPP: Char  = '@';   //opposite
  CMD_SEP: Char  = ',';   //separator
  CMD_POL: Char  = '<';   //polar coord

  CMD_LBR: Char  = '[';   //left bracket
  CMD_RBR: Char  = ']';   //right bracket
  CMD_TIP: Char  = ':';   //tip colon

  CMD_LDE: Char  = '<';   //left
  CMD_RDE: Char  = '>';   //right


  CMD_EDIT_HEIGHT  = 21;
  CMD_LOGS_HEIGHT  = 40;


type

  TUdUserTextEvent = procedure(Sender: TObject; AText: string) of object;

  //*** TUdCmdLine ***//
  TUdCmdLine = class(TCustomControl)
  private
    FIsLoaded: Boolean;
    FSpaceEnter: Boolean;

    FCommandName: string;
    FCommandValue: string;

    FHistoryMemo : TMemo;
    FUserTextEdit: TEdit;
    FCommandNameLabel: TLabel;
    FCommandPanel: TCustomControl;
    FCommandBevel: TBevel;

    FHistoryCapacity: Integer;

    FOnUserText: TUdUserTextEvent;
    F_OnUserText: TUdUserTextEvent;

  protected
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure Notification(Component: TComponent; Operation: TOperation); override;
    procedure CreateParams(var Params: TCreateParams); override;

    function LayoutCtrls(): Boolean;
    function UpdateCmdCtrls(): Boolean;

    function GetCommandName: string;
    function GetCommandValue: string;

    procedure SetCommandName(Value: string);
    procedure SetCommandValue(Value: string);


    procedure OnUserTextButtonClick(Sender: TObject);
    procedure OnUserTextLogKeyPress(Sender: TObject; var Key: Char);
    procedure OnUserTextEditKeyPress(Sender: TObject; var Key: Char);

    property _OnUserText: TUdUserTextEvent read F_OnUserText write F_OnUserText;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    function AddLog(AText: string): Boolean;
    function ClearLogs(): Boolean;

    function Reset(): Boolean;
    function SetCommand(AName, AText: string): Boolean;

    procedure ExecKeyPress(AKey: Char);


  published
    property CommandName: string read GetCommandName write SetCommandName;
    property CommandValue: string read GetCommandValue write SetCommandValue;

    property SpaceEnter: Boolean read FSpaceEnter write FSpaceEnter;
    property LogCapacity: Integer read FHistoryCapacity write FHistoryCapacity;
                                  
    property OnUserText: TUdUserTextEvent read FOnUserText write FOnUserText;

    property Align;
    property Anchors;
    property AutoSize;
    property Color;
    property Constraints;
    property Ctl3D;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;





implementation

uses
  SysUtils, UdUtils;

const
  DEFAULT_WIDTH    = 300;
  DEFAULT_HEIGHT   = CMD_EDIT_HEIGHT + CMD_LOGS_HEIGHT;




//==================================================================================================
{ TUdCmdLine }

constructor TUdCmdLine.Create(AOwner: TComponent);
begin
  inherited;

  FIsLoaded := False;
  FSpaceEnter := True;

  FCommandName := sCmdName;
  FHistoryCapacity := 1024;

  FCommandPanel := TCustomControl.Create(Self);
  with FCommandPanel do
  begin
    Parent := Self;
    ParentColor := False;
    Color := clWindow;
    ParentFont := True;
    Caption := '';
    BevelOuter := bvNone;
  end;

  FUserTextEdit := TEdit.Create(Self);
  with FUserTextEdit do
  begin
    Parent := FCommandPanel;
    ParentFont := True;
    ParentColor := True;
    BorderStyle := bsNone;
    OnKeyPress := OnUserTextEditKeyPress;
  end;

  FCommandNameLabel := TLabel.Create(Self);
  with FCommandNameLabel do
  begin
    Parent := FCommandPanel;
    ParentFont := True;
    ParentColor := True;
    AutoSize := True;
    Layout := tlCenter;
  end;

  FHistoryMemo := TMemo.Create(Self);
  with FHistoryMemo do
  begin
    Parent := Self;
    ParentFont := True;
    ParentColor := False;
    Color := clWindow;
    ReadOnly := True;
    ScrollBars := ssVertical;
    BorderStyle := bsNone;
    OnKeyPress := OnUserTextLogKeyPress;
  end;

  FCommandBevel := TBevel.Create(Self);
  with FCommandBevel do
  begin
    Parent := FCommandPanel;
    Shape := bsBottomLine;
    Align := alTop;
    Height := 2;
  end;

  Self.ParentColor := False;
  Self.Color := clWindow; //clNavy; //clRed; //clHotLight;
  Self.Caption := '';
  Self.Width := DEFAULT_WIDTH;
  Self.Height := DEFAULT_HEIGHT;

  Self.BevelOuter := bvNone;

  LayoutCtrls();
end;

destructor TUdCmdLine.Destroy;
begin
  FUserTextEdit.Free;
  FCommandNameLabel.Free;
  FCommandBevel.Free;
  FCommandPanel.Free;
  FHistoryMemo.Free;

  inherited;
end;

procedure TUdCmdLine.CreateWnd;
begin
  inherited;
  if Handle <> INVALID_HANDLE_VALUE then SetClassLong(Handle, GCL_HCURSOR, 0);
end;

procedure TUdCmdLine.Loaded;
begin
  inherited;
  FIsLoaded := True;
end;

procedure TUdCmdLine.WMSize(var Message: TWMSize);
begin
  LayoutCtrls();  //if FIsLoaded then
end;

procedure TUdCmdLine.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  if FIsLoaded then LayoutCtrls();
end;

procedure TUdCmdLine.Notification(Component: TComponent; Operation: TOperation);
begin
  inherited Notification(Component, Operation);

  if Operation = opRemove then
  begin
    //if Component = FParserObject then FParserObject := nil;
  end;
end;

procedure TUdCmdLine.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WinClassName := 'Afx:40000:29:7:2:65732';
end;




//--------------------------------------------------------------------

function TUdCmdLine.UpdateCmdCtrls(): Boolean;
var
  AWid: Integer;
begin
  if FCommandName <> '' then
    FCommandNameLabel.Caption := FCommandName + CMD_TIP
  else
    FCommandNameLabel.Caption := '';
    
  AWid := FCommandNameLabel.Width;

  with FUserTextEdit do
  begin
    Left  := 3 + AWid + 2;
    Width := Parent.Width - Left - 2;
  end;

  Result := True;
end;

function TUdCmdLine.LayoutCtrls(): Boolean;
begin
  with FHistoryMemo do
  begin
    Left := 0;
    Top := 0;
    Height := Self.Height - CMD_EDIT_HEIGHT - BorderWidth - 1;
    Width := Self.Width;
    Anchors := [akLeft,akTop,akRight,akBottom];
  end;

  with FCommandPanel do
  begin
    Top := Self.Height - CMD_EDIT_HEIGHT;
    Height := CMD_EDIT_HEIGHT;
    Align := alBottom;
  end;


  with FUserTextEdit do
  begin
    BorderStyle := bsNone;
    Top := 3;
  end;

  with FCommandNameLabel do
  begin
    Left := 3;
    Top :=  3;
  end;

  UpdateCmdCtrls();

  Result := True;
end;




//--------------------------------------------------------------------

procedure TUdCmdLine.OnUserTextButtonClick(Sender: TObject);
begin
  SendMessage(FUserTextEdit.Handle, WM_CHAR, VK_RETURN, 0);
end;

procedure TUdCmdLine.OnUserTextLogKeyPress(Sender: TObject; var Key: Char);
begin
  Self.FUserTextEdit.SetFocus;
  KeyPress(Key);
  Key := #0;
end;

procedure TUdCmdLine.OnUserTextEditKeyPress(Sender: TObject; var Key: Char);
begin                                     {空格}
  if (Key = #13) or (FSpaceEnter and (Key = #32)) then
  begin
    Key := #0;

    FCommandValue := Trim(FUserTextEdit.Text);
    FUserTextEdit.Clear;

    //Self.AddLog(FCommandName + ':' + FCommandValue);
    if Assigned(FOnUserText) then FOnUserText(Self, FCommandValue);
    if Assigned(F_OnUserText) then F_OnUserText(Self, FCommandValue);
  end
  else if (Key = #27)  then
  begin
    Key := #0;
    
    FCommandValue := '';
    FCommandName := sCmdName;

    AddLog(sCmdCancel);
    FUserTextEdit.Clear;

    if Assigned(FOnUserText) then FOnUserText(Self, '*');
    if Assigned(F_OnUserText) then F_OnUserText(Self, '*');

    UpdateCmdCtrls();
  end;
end;




//--------------------------------------------------------------------

procedure TUdCmdLine.SetCommandName(Value: string);
begin
//  if Trim(Value) <> '' then
//  begin
    FCommandName := Value;
    FCommandValue := '';

    FUserTextEdit.Text := FCommandValue;
    FCommandNameLabel.Caption := FCommandName;

    UpdateCmdCtrls();
//  end;
end;

procedure TUdCmdLine.SetCommandValue(Value: string);
begin
  FCommandValue := Trim(Value);
  FUserTextEdit.Text := FCommandValue;
  if FUserTextEdit.CanFocus then
  begin
    FUserTextEdit.SetFocus;
    SendMessage(FUserTextEdit.Handle, WM_KEYDOWN, VK_END, 0);
  end;  
end;

function TUdCmdLine.GetCommandName: string;
begin
  Result := FCommandName;
end;

function TUdCmdLine.GetCommandValue: string;
begin
  Result := FCommandValue;
end;



//--------------------------------------------------------------------

function TUdCmdLine.AddLog(AText: string): Boolean;
begin
  Result := False;
  if Assigned(FHistoryMemo) and (Trim(AText) <> '') then
  begin
    if (FHistoryCapacity > 0) and (FHistoryMemo.Lines.Count > FHistoryCapacity) then FHistoryMemo.Clear;
    FHistoryMemo.Lines.Add(AText);
  end;
end;

function TUdCmdLine.ClearLogs: Boolean;
begin
  Result := False;
  if Assigned(FHistoryMemo) then FHistoryMemo.Clear;
end;



function TUdCmdLine.Reset(): Boolean;
begin
  FCommandName := sCmdName;
  FCommandValue := '';
  FUserTextEdit.Clear();

  UpdateCmdCtrls();
  Result := True;  
end;

function TUdCmdLine.SetCommand(AName, AText: string): Boolean;
begin
  if Trim(Name) <> '' then FCommandName := AName;
  FCommandValue := Trim(AText);

  FUserTextEdit.Text := FCommandValue;
  FCommandNameLabel.Caption := FCommandName;
  if FUserTextEdit.CanFocus then FUserTextEdit.SetFocus;

  UpdateCmdCtrls();
  Result := True;
end;

procedure TUdCmdLine.ExecKeyPress(AKey: Char);
begin
  if (AKey = #8)  then
    SendMessage(FUserTextEdit.Handle, WM_CHAR, VK_BACK, 0) else
  if (AKey = #27)  then
    SendMessage(FUserTextEdit.Handle, WM_CHAR, VK_ESCAPE, 0)
  else if (AKey = #13) or (FSpaceEnter and (AKey = #32)) then
    SendMessage(FUserTextEdit.Handle, WM_CHAR, VK_RETURN, 0)
  else if not CharInSet(AnsiChar(AKey), [#0..#31]) then //不是控制符
  begin
    FUserTextEdit.Text := FUserTextEdit.Text + AKey;
    SendMessage(FUserTextEdit.Handle, WM_KEYDOWN, VK_END, 0);
  end;
end;




end.