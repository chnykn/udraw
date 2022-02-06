{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdToleranceSymbolFrm;

interface

uses
   Classes, Controls, Forms,
  UdShx, UdGdtSymbolPanel, ExtCtrls;

type
  TUdTolSymbolKind = (tskSymbol, tskMeterial);
  
  TUdToleranceSymbolForm = class(TForm)
    pnlClient: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    
  private
    FGdtShx: TUdShx;

  protected
    function GetSymbol: Char;
    procedure SetSymbol(const Value: Char);
    function CreateSymbolPanel: TUdGdtSymbolPanel;

    procedure OnSymbolPanelClick(Sender: TObject);
    procedure OnSymbolPanelDblClick(Sender: TObject);
    
  public
    function Init(AGdtShx: TUdShx; AKind: TUdTolSymbolKind): Boolean;
    
  public
    property Symbol: Char read GetSymbol write SetSymbol;

  end;



implementation

{$R *.dfm}



const
  SYMBOL_WIDTH  = 32;
  SYMBOL_HEIGHT = 28;

  SYMBOL_PADDING  = 5;
  
procedure TUdToleranceSymbolForm.FormCreate(Sender: TObject);
begin
//
end;

procedure TUdToleranceSymbolForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TUdToleranceSymbolForm.FormShow(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to pnlClient.ControlCount - 1 do
    pnlClient.Controls[I].Invalidate;
end;


procedure TUdToleranceSymbolForm.OnSymbolPanelClick(Sender: TObject);
begin
  if Assigned(Sender) and Sender.InheritsFrom(TUdGdtSymbolPanel) then
  begin
    Self.SetSymbol(TUdGdtSymbolPanel(Sender).Symbol);
    Self.ModalResult := mrOk;
  end;
end;

procedure TUdToleranceSymbolForm.OnSymbolPanelDblClick(Sender: TObject);
begin
//  if Assigned(Sender) and Sender.InheritsFrom(TUdGdtSymbolPanel) then
//  begin
//    Self.SetSymbol(TUdGdtSymbolPanel(Sender).Symbol);
//    Self.ModalResult := mrOk;
//  end;
end;


function TUdToleranceSymbolForm.CreateSymbolPanel(): TUdGdtSymbolPanel;
begin
  Result := TUdGdtSymbolPanel.Create(Self);
  Result.Parent := pnlClient;
  Result.GdtShx := FGdtShx;

  Result.OnClick := OnSymbolPanelClick;
  Result.OnDblClick := OnSymbolPanelDblClick;
end;

function TUdToleranceSymbolForm.Init(AGdtShx: TUdShx; AKind: TUdTolSymbolKind): Boolean;
var
  I: Integer;
  LSymbolPanel: TUdGdtSymbolPanel;
begin
  FGdtShx := AGdtShx;
  
  if AKind = tskSymbol then
  begin
    pnlClient.Width := SYMBOL_WIDTH * 5 + SYMBOL_PADDING * 6;
    pnlClient.Height := SYMBOL_HEIGHT * 3 + SYMBOL_PADDING * 4;

    Self.Caption := '·ûºÅ';
  end
  else begin
    pnlClient.Width := SYMBOL_WIDTH * 4 + SYMBOL_PADDING * 5;
    pnlClient.Height := SYMBOL_HEIGHT * 1 + SYMBOL_PADDING * 2;

    Self.Caption := '°üÈÝÌõ¼þ';
  end;

  if AKind = tskSymbol then
  begin
    for I := 0 to 4 do
    begin
      LSymbolPanel := CreateSymbolPanel();
      LSymbolPanel.SetBounds(SYMBOL_PADDING * (I + 1) + SYMBOL_WIDTH * I,
                             SYMBOL_PADDING, SYMBOL_WIDTH, SYMBOL_HEIGHT);
      case I of 
        0: LSymbolPanel.Symbol := 'j';
        1: LSymbolPanel.Symbol := 'r';
        2: LSymbolPanel.Symbol := 'i';
        3: LSymbolPanel.Symbol := 'f';
        4: LSymbolPanel.Symbol := 'b';
      end;
    end;

    for I := 0 to 4 do
    begin
      LSymbolPanel := CreateSymbolPanel();
      LSymbolPanel.SetBounds(SYMBOL_PADDING * (I + 1) + SYMBOL_WIDTH * I,
                             SYMBOL_PADDING * 2 + SYMBOL_HEIGHT ,
                             SYMBOL_WIDTH, SYMBOL_HEIGHT);
      case I of 
        0: LSymbolPanel.Symbol := 'a';
        1: LSymbolPanel.Symbol := 'g';
        2: LSymbolPanel.Symbol := 'c';
        3: LSymbolPanel.Symbol := 'e';
        4: LSymbolPanel.Symbol := 'u';
      end;
    end;

    for I := 0 to 4 do
    begin
      LSymbolPanel := CreateSymbolPanel();
      LSymbolPanel.SetBounds(SYMBOL_PADDING * (I + 1) + SYMBOL_WIDTH * I,
                             SYMBOL_PADDING * 3 + SYMBOL_HEIGHT * 2 ,
                             SYMBOL_WIDTH, SYMBOL_HEIGHT);
      case I of
        0: LSymbolPanel.Symbol := 'd';
        1: LSymbolPanel.Symbol := 'k';
        2: LSymbolPanel.Symbol := 'h';
        3: LSymbolPanel.Symbol := 't';
        4: LSymbolPanel.Selected := True;
      end;
    end;
      
  end
  else begin
    Self.Width := SYMBOL_WIDTH * 4 + SYMBOL_PADDING * 5;
    Self.Height := SYMBOL_HEIGHT * 1 + SYMBOL_PADDING * 2; 

    for I := 0 to 3 do
    begin
      LSymbolPanel := CreateSymbolPanel();
      LSymbolPanel.SetBounds(SYMBOL_PADDING * (I + 1) + SYMBOL_WIDTH * I,
                             SYMBOL_PADDING, SYMBOL_WIDTH, SYMBOL_HEIGHT);
      case I of 
        0: LSymbolPanel.Symbol := 'm';
        1: LSymbolPanel.Symbol := 'l';
        2: LSymbolPanel.Symbol := 's';
        3: LSymbolPanel.Selected := True;
      end;
    end;
     
  end;

  Result := True;
end;




function TUdToleranceSymbolForm.GetSymbol: Char;
var
  I: Integer;
  LSymbolPanel: TUdGdtSymbolPanel;
begin
  Result := #0;
  
  for I := 0 to pnlClient.ControlCount - 1 do
  begin
    if pnlClient.Controls[I].InheritsFrom(TUdGdtSymbolPanel) then
    begin
      LSymbolPanel := TUdGdtSymbolPanel(pnlClient.Controls[I]);
      if LSymbolPanel.Selected then
      begin
        Result := LSymbolPanel.Symbol;
        Break;
      end;
    end;
  end;
end;

procedure TUdToleranceSymbolForm.SetSymbol(const Value: Char);
var
  I: Integer;
  LSymbolPanel: TUdGdtSymbolPanel;
begin
  for I := 0 to pnlClient.ControlCount - 1 do
  begin
    if pnlClient.Controls[I].InheritsFrom(TUdGdtSymbolPanel) then
    begin
      LSymbolPanel := TUdGdtSymbolPanel(pnlClient.Controls[I]);
      LSymbolPanel.Selected := (LSymbolPanel.Symbol = Value);
    end;
  end;
end;



end.