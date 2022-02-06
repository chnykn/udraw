{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdColorsFrm;

{$DEFINE FULL_MODE}

interface

uses
  Windows, Messages,  Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls

  {$IFDEF FULL_MODE} ,UdConsts, UdColors, UdColor {$ENDIF}

  , UdHSLFrm;

type
  TUdColorsForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    pnlIndexColor: TPanel;
    pnlIndexPreview: TPanel;
    lblIndexColor: TLabel;
    btnByLayer: TButton;
    btnByBlock: TButton;
    Label4: TLabel;
    edtIndexColor: TEdit;
    pnlTruePreview: TPanel;
    pnlTrueColor: TPanel;
    lblTrueColor: TLabel;
    edtRed: TEdit;
    edtGreen: TEdit;
    edtBlue: TEdit;
    lblIndexColor2: TLabel;
    pnlHSL: TPanel;
    lblSat: TLabel;
    lblHue: TLabel;
    lblLum: TLabel;
    edtHue: TEdit;
    edtSat: TEdit;
    edtLum: TEdit;
    udnHue: TUpDown;
    udnSat: TUpDown;
    udnLum: TUpDown;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);


    procedure edtRGBChange(Sender: TObject);
    procedure edtRGBExit(Sender: TObject);

    procedure udnHSLChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure edtHSLChange(Sender: TObject);
    procedure edtHSLExit(Sender: TObject);


    procedure btnByLayerClick(Sender: TObject);
    procedure btnByBlockClick(Sender: TObject);

    procedure btnOKClick(Sender: TObject);
    procedure edtIndexColorChange(Sender: TObject);

  private
    FHSLForm: TUdHSLForm;

  protected
    procedure InitTrueColors();
    procedure InitIndexColors();

    procedure OnTrueColorCtrlMouseEnter(Sender: TObject);
    procedure OnTrueColorCtrlMouseLeave(Sender: TObject);
    procedure OnTrueColorCtrlClick(Sender: TObject);

    procedure OnHSLFormSelectColor(Sender: TObject);
    procedure OnHSLFormMovingColor(Sender: TObject; AColor: TColor);
    procedure OnHSLFormLeavedColor(Sender: TObject);


    procedure OnIndexColorCtrlMouseEnter(Sender: TObject);
    procedure OnIndexColorCtrlMouseLeave(Sender: TObject);
    procedure OnIndexColorCtrlClick(Sender: TObject);


    function GetColorValue: Integer;
    function GetIsIndexColor: Boolean;

    procedure SetColorValue(const AValue: Integer);
    procedure SetIsIndexColor(const AValue: Boolean);

    function CheckColorValue(): Boolean;

  public
    property ColorValue: Integer read GetColorValue write SetColorValue;
    property IsIndexColor: Boolean read GetIsIndexColor write SetIsIndexColor;

  end;

{$IFDEF FULL_MODE}
function ShowColorsDialog(AColors: TUdColors): Boolean;
{$ENDIF}



implementation

{$R *.dfm}


uses
  SysUtils{$IFDEF FULL_MODE}, UdStreams, UdUtils{$ENDIF};



//=================================================================================================

{$IFDEF FULL_MODE}
function ShowColorsDialog(AColors: TUdColors): Boolean;
var
  N: Integer;
  LAdded: Boolean;
  LValue: Integer;
  LForm: TUdColorsForm;
begin
  Result := False;
  if not Assigned(AColors) then Exit; //=======>>>>>
  
  LForm := TUdColorsForm.Create(nil);
  try
    if LForm.ShowModal() = mrOk then
    begin
      N := -1;
      LAdded := False;
      LValue := LForm.ColorValue;

      if LForm.IsIndexColor then
      begin
        if (LValue > 0) and (LValue <= 255) then // -1: Error  0: ByBlock  256: ByLayer
        begin
          N := AColors.IndexOf(LValue, ctIndexColor);
          if N < 2 then
          begin
            AColors.Add(Byte(LValue));
            LAdded := True;
          end;
        end
        else begin
          case LValue of
            0  : N := 1;  //ByBlock
            256: N := 0;  //ByLayer
          end;
        end;
      end
      else begin
        N := AColors.IndexOf(LValue, ctTrueColor);
        if N < 2 then
        begin
          AColors.Add(TColor(LValue));
          LAdded := True;
        end;
      end;

      if LAdded then N := AColors.Count - 1;
      if N >= 0 then
      begin
        AColors.SetActive(N);
        Result := True;
      end;
    end;
  finally
    LForm.Free;
  end;
end;
{$ENDIF}






//=================================================================================================


type

  TUdColorPanel = class(TGraphicControl)
  private
    FShowBorder: Boolean;
    FMouseEntered: Boolean;

    {$IF COMPILERVERSION <= 17 }
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    {$IFEND}
    
  protected
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure Paint; override;
    
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Color;
    property ShowBorder: Boolean read FShowBorder write FShowBorder;

    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;

    {$IF COMPILERVERSION <= 17 }
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    {$ELSE}
    property OnMouseEnter;
    property OnMouseLeave;
    {$IFEND}      
  end;


{ TUdColorPanel }

constructor TUdColorPanel.Create(AOwner: TComponent);
begin
  inherited;
  FShowBorder := True; 
  FMouseEntered := False;
end;

destructor TUdColorPanel.Destroy;
begin

  inherited;
end;


procedure TUdColorPanel.Paint;
var
  LRect: TRect;
begin
  inherited;

  Self.Canvas.Brush.Style := bsSolid;
  Self.Canvas.Brush.Color := Self.Color;

  if FMouseEntered then
  begin
    Self.Canvas.Pen.Style := psSolid;
    Self.Canvas.Pen.Width := 2;

    if Self.Color = clWhite then
      Self.Canvas.Pen.Color := clGray
    else
      Self.Canvas.Pen.Color := clWhite;
  end
  else begin
    if FShowBorder then
    begin
      Self.Canvas.Pen.Style := psSolid;
      Self.Canvas.Pen.Width := 1;
      Self.Canvas.Pen.Color := clBtnShadow;
    end
    else
      Self.Canvas.Pen.Style := psClear;
  end;

  LRect := Self.ClientRect;

  Self.Canvas.Rectangle(LRect);
  
  if FMouseEntered then
    Self.Canvas.DrawFocusRect(LRect);
end;

procedure TUdColorPanel.CMMouseEnter(var Message: TMessage);
begin
  inherited;

  {$IF COMPILERVERSION <= 15 }
  if Parent <> nil then
    Parent.Perform(CM_MOUSEENTER, 0, Longint(Self));
  if (Message.LParam = 0) and Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
  {$IFEND}

  FMouseEntered := True;
  Self.Invalidate();
end;

procedure TUdColorPanel.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  {$IF COMPILERVERSION <= 15 }
  if Parent <> nil then
    Parent.Perform(CM_MOUSELEAVE, 0, Longint(Self));
  if (Message.LParam = 0) and Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
  {$IFEND}
      
  FMouseEntered := False;
  Self.Invalidate();  
end;





//=================================================================================================


const
  TRUE_COLORS: array[0..47] of string =
  ('255,128,128', '255,255,128', '128,255,128', '0,255,128',   '128,255,255', '0,128,255',   '255,128,192', '255,128,255',
   '255,0,0',     '255,255,0',   '128,255,0',   '0,255,64',    '0,255,255',   '0,128,192',   '128,128,192',  '255,0,255',
   '128,64,64',   '255,128,64',  '0,255,0',     '0,128,128',   '0,64,128',    '128,128,255', '128,0,64',     '255,0,128',
   '128,0,0',     '255,128,0',   '0,128,0',     '0,128,64',    '0,0,255',     '0,0,160',     '128,0,128',    '128,0,255',
   '64,0,0',      '128,64,0',    '0,64,0',      '0,64,64',     '0,0,128',     '0,0,64',      '64,0,64',      '64,0,128',
   '0,0,0',       '128,128,0',   '128,128,64',  '128,128,128', '64,128,128',  '192,192,192', '64,0,64',      '255,255,255');


  
function _RGBStrToColor(AValue: string): TColor;
var
  LStr: string;
  N, R, G, B: Integer;
begin
  LStr := AValue;

  N := Pos(',',  LStr);
  R := StrToIntDef(Copy(LStr, 1, N-1), 0);
  Delete(LStr, 1, N);

  N := Pos(',',  LStr);
  G := StrToIntDef(Copy(LStr, 1, N-1), 0);
  Delete(LStr, 1, N);

  B := StrToIntDef(LStr, 0);

  Result := RGB(R,G,B);
end;





//=================================================================================================

procedure TUdColorsForm.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  InitTrueColors();
  InitIndexColors();

  FHSLForm := TUdHSLForm.Create(nil);
  FHSLForm.ManualDock(pnlHSL);
  FHSLForm.Align := alClient;

  FHSLForm.OnSelectColor := OnHSLFormSelectColor;
  FHSLForm.OnMovingColor := OnHSLFormMovingColor;
  FHSLForm.OnLeavedColor := OnHSLFormLeavedColor;

  FHSLForm.Show();
end;



procedure TUdColorsForm.FormDestroy(Sender: TObject);
begin
  FHSLForm.Free;
end;

procedure TUdColorsForm.FormShow(Sender: TObject);
begin
//
end;



//-------------------------------------------------------------------------------------

procedure TUdColorsForm.InitTrueColors;
var
  I, J: Integer;
  X, Y, N, D: Integer;
  LXSize, LYSize: Integer;
  LColorCtl: TUdColorPanel;
begin
  LXSize := pnlTrueColor.Width div 6;
  LYSize := pnlTrueColor.Height div 8;

  D := 0;
  N := 0;
  
  for I := 0 to 7 do
  begin
    for J := 0 to 5 do
    begin
      if I = 4 then D:= 2;

      X := J * LXSize;
      Y := I * LYSize + D;

      LColorCtl := TUdColorPanel.Create(pnlTrueColor);
      LColorCtl.Left := X;
      LColorCtl.Top  := Y;
      LColorCtl.Width  := LXSize - 2;
      LColorCtl.Height := LYSize - 2;
      LColorCtl.Parent := pnlTrueColor;
      LColorCtl.Color := _RGBStrToColor(TRUE_COLORS[N]);

      LColorCtl.OnMouseEnter := OnTrueColorCtrlMouseEnter;
      LColorCtl.OnMouseLeave := OnTrueColorCtrlMouseLeave;
      LColorCtl.OnClick      := OnTrueColorCtrlClick;

      Inc(N);
    end;
  end;
end;



procedure TUdColorsForm.OnTrueColorCtrlMouseEnter(Sender: TObject);
var
  LColor: TColor;
begin
  LColor := TUdColorPanel(Sender).Color;
  lblTrueColor.Caption := '红, 绿, 蓝:  ' +
                          IntToStr(GetRValue(LColor)) + ', ' +
                          IntToStr(GetGValue(LColor)) + ', ' +
                          IntToStr(GetBValue(LColor)) ;
end;

procedure TUdColorsForm.OnTrueColorCtrlMouseLeave(Sender: TObject);
begin
  lblTrueColor.Caption := '';
end;


procedure TUdColorsForm.OnTrueColorCtrlClick(Sender: TObject);
var
  LColor: TColor;
begin
  LColor := TUdColorPanel(Sender).Color;
//  pnlTruePreview.Color := LColor;
//
//  edtRed.OnChange   := nil;
//  edtGreen.OnChange := nil;
//  edtBlue.OnChange  := nil;
//  try
//    edtRed.Text   := IntToStr(GetRValue(LColor));
//    edtGreen.Text := IntToStr(GetGValue(LColor));
//    edtBlue.Text  := IntToStr(GetBValue(LColor));

    FHSLForm.SelectColor := LColor; // This will tiger FHSLForm's OnSelectColor -> OnHSLFormSelectColor
//  finally
//    edtRed.OnChange   := edtRGBChange;
//    edtGreen.OnChange := edtRGBChange;
//    edtBlue.OnChange  := edtRGBChange;
//  end;
end;




procedure TUdColorsForm.OnHSLFormSelectColor(Sender: TObject);
var
  LColor: TColor;
begin
  LColor := FHSLForm.SelectColor;
  pnlTruePreview.Color := LColor;

  edtRed.OnChange   := nil;
  edtGreen.OnChange := nil;
  edtBlue.OnChange  := nil;

  edtHue.OnChange  := nil;
  edtSat.OnChange  := nil;
  edtLum.OnChange  := nil;

  try
    edtRed.Text   := IntToStr(GetRValue(LColor));
    edtGreen.Text := IntToStr(GetGValue(LColor));
    edtBlue.Text  := IntToStr(GetBValue(LColor));

    edtHue.Text   := IntToStr(FHSLForm.Hue);
    edtSat.Text   := IntToStr(FHSLForm.Sat);
    edtLum.Text   := IntToStr(FHSLForm.Lum);
  finally
    edtRed.OnChange   := edtRGBChange;
    edtGreen.OnChange := edtRGBChange;
    edtBlue.OnChange  := edtRGBChange;

    edtHue.OnChange := edtHSLChange;
    edtSat.OnChange := edtHSLChange;
    edtLum.OnChange := edtHSLChange;
  end;
end;

procedure TUdColorsForm.OnHSLFormMovingColor(Sender: TObject; AColor: TColor);
begin
  lblTrueColor.Caption := '红, 绿, 蓝:  ' +
                          IntToStr(GetRValue(AColor)) + ', ' +
                          IntToStr(GetGValue(AColor)) + ', ' +
                          IntToStr(GetBValue(AColor)) ;
end;

procedure TUdColorsForm.OnHSLFormLeavedColor(Sender: TObject);
begin
  lblTrueColor.Caption := '';
end;



procedure TUdColorsForm.edtRGBChange(Sender: TObject);
var
  N: Integer;
  R, G, B: Integer;
begin
  R := GetRValue(pnlTruePreview.Color);
  G := GetGValue(pnlTruePreview.Color);
  B := GetBValue(pnlTruePreview.Color);

  edtRed.OnChange   := nil;
  edtGreen.OnChange := nil;
  edtBlue.OnChange  := nil;

  edtHue.OnChange  := nil;
  edtSat.OnChange  := nil;
  edtLum.OnChange  := nil;
  try
    if Trim(edtRed.Text) = '' then R := 0
    else begin
      if TryStrToInt(edtRed.Text, N) then
      begin
        if N < 0 then R := 0 else if N > 255 then R := 255 else R := N;
      end;
    end;

    if Trim(edtGreen.Text) = '' then G := 0
    else begin
      if TryStrToInt(edtGreen.Text, N) then
      begin
        if N < 0 then G := 0 else if N > 255 then G := 255 else G := N;
      end;
    end;

    if Trim(edtBlue.Text) = '' then B := 0
    else begin
      if TryStrToInt(edtBlue.Text, N) then
      begin
        if N < 0 then B := 0 else if N > 255 then B := 255 else B := N;
      end;
    end;
    
    pnlTruePreview.Color := RGB(R, G, B);
    FHSLForm.SelectColor := RGB(R, G, B);

    edtHue.Text  := IntToStr( FHSLForm.Hue );
    edtSat.Text  := IntToStr( FHSLForm.Sat );
    edtLum.Text  := IntToStr( FHSLForm.Lum );

  finally
    edtRed.OnChange   := edtRGBChange;
    edtGreen.OnChange := edtRGBChange;
    edtBlue.OnChange  := edtRGBChange;

    edtHue.OnChange := edtHSLChange;
    edtSat.OnChange := edtHSLChange;
    edtLum.OnChange := edtHSLChange;
  end;
end;

procedure TUdColorsForm.edtRGBExit(Sender: TObject);
begin
  TEdit(Sender).OnChange := nil;
  try
    case TEdit(Sender).Tag of
      0: TEdit(Sender).Text := IntToStr( GetRValue(pnlTruePreview.Color) );
      1: TEdit(Sender).Text := IntToStr( GetGValue(pnlTruePreview.Color) );
      2: TEdit(Sender).Text := IntToStr( GetBValue(pnlTruePreview.Color) );
    end;
  finally
    TEdit(Sender).OnChange := edtRGBChange;
  end;
end;



procedure TUdColorsForm.udnHSLChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
begin
  case TComponent(Sender).Tag of
    0: AllowChange := (NewValue >= 0) and (NewValue <= 360);
    1: AllowChange := (NewValue >= 0) and (NewValue <= 100);
    2: AllowChange := (NewValue >= 0) and (NewValue <= 100);
  end;
end;

procedure TUdColorsForm.edtHSLChange(Sender: TObject);
var
  N: Integer;
  H, S, L: Integer;
begin
  H := FHSLForm.Hue;
  S := FHSLForm.Sat;
  L := FHSLForm.Lum;

  edtHue.OnChange  := nil;
  edtSat.OnChange  := nil;
  edtLum.OnChange  := nil;
  try
    if Trim(edtHue.Text) = '' then H := 0
    else begin
      if TryStrToInt(edtHue.Text, N) then
      begin
        if N < 0 then H := 0 else if N > 360 then H := 360 else H := N;
      end;
    end;

    if Trim(edtSat.Text) = '' then S := 0
    else begin
      if TryStrToInt(edtSat.Text, N) then
      begin
        if N < 0 then S := 0 else if N > 100 then S := 100 else S := N;
      end;
    end;

    if Trim(edtLum.Text) = '' then L := 0
    else begin
      if TryStrToInt(edtLum.Text, N) then
      begin
        if N < 0 then L := 0 else if N > 100 then L := 100 else L := N;
      end;
    end;

    FHSLForm.Hue := H;
    FHSLForm.Sat := S;
    FHSLForm.Lum := L;
  finally
    edtHue.OnChange := edtHSLChange;
    edtSat.OnChange := edtHSLChange;
    edtLum.OnChange := edtHSLChange;
  end;
end;

procedure TUdColorsForm.edtHSLExit(Sender: TObject);
begin
  TEdit(Sender).OnChange := nil;
  try
    case TEdit(Sender).Tag of
      0: TEdit(Sender).Text := IntToStr( FHSLForm.Hue );
      1: TEdit(Sender).Text := IntToStr( FHSLForm.Sat );
      2: TEdit(Sender).Text := IntToStr( FHSLForm.Lum );
    end;
  finally
    TEdit(Sender).OnChange := edtHSLChange;
  end;
end;







//--------------------------------------------------------------------------------------------


procedure TUdColorsForm.InitIndexColors;
const
  COLOR_SEEDS: array[0..9] of Integer = (8,6,4,2,0, 1,3,5,7,9);
var
  I, J: Integer;
  X, Y, N, D: Integer;
  LSize: Integer;
  LColorCtl: TUdColorPanel;
begin
  LSize := Trunc(pnlIndexColor.Width / 24);

  D := 0;
  pnlIndexColor.Height := LSize * 10 + 8;
  lblIndexColor.Top := pnlIndexColor.Top + pnlIndexColor.Height + 2;
  lblIndexColor2.Top := pnlIndexColor.Top + pnlIndexColor.Height + 2;
  
  for I := Low(COLOR_SEEDS) to High(COLOR_SEEDS) do
  begin
    for J := 1 to 24 do
    begin
      if COLOR_SEEDS[I] = 1 then D := 5;
      
      X := (J - 1) * LSize;
      Y := I * LSize + D;

      N := COLOR_SEEDS[I] + J * 10;

      LColorCtl := TUdColorPanel.Create(pnlIndexColor);
      LColorCtl.Left    := X;
      LColorCtl.Top     := Y;
      LColorCtl.Width   := LSize - 1;
      LColorCtl.Height  := LSize - 1;
      LColorCtl.Parent  := pnlIndexColor;
      LColorCtl.Tag     := N;
      LColorCtl.Color   := {$IFDEF FULL_MODE} UdColor.COLOR_PALETTE[N] {$ELSE} clMoneyGreen {$ENDIF};
      LColorCtl.OnClick := OnIndexColorCtrlClick;
      LColorCtl.OnMouseEnter := OnIndexColorCtrlMouseEnter;
      LColorCtl.OnMouseLeave := OnIndexColorCtrlMouseLeave;
    end;
  end;

  Y := btnByLayer.Top + 1;
  X := pnlIndexColor.Left;
  LSize := 20;
  
  for I := 1 to 9 do
  begin
    LColorCtl := TUdColorPanel.Create(TabSheet1);
    LColorCtl.Left    := X + LSize * (I-1);
    LColorCtl.Top     := Y;
    LColorCtl.Width   := LSize - 1;
    LColorCtl.Height  := LSize - 1;
    LColorCtl.Parent  := TabSheet1;
    LColorCtl.Tag     := I;
    LColorCtl.Color   := {$IFDEF FULL_MODE} UdColor.COLOR_PALETTE[I] {$ELSE} clSkyBlue {$ENDIF};;
    LColorCtl.OnClick := OnIndexColorCtrlClick;
    LColorCtl.OnMouseEnter := OnIndexColorCtrlMouseEnter;
    LColorCtl.OnMouseLeave := OnIndexColorCtrlMouseLeave;
  end;

  Y := btnByLayer.Top + 25;

  for I := 250 to 255 do
  begin
    LColorCtl := TUdColorPanel.Create(TabSheet1);
    LColorCtl.Left    := X + LSize * (I-250);
    LColorCtl.Top     := Y;
    LColorCtl.Width   := LSize - 1;
    LColorCtl.Height  := LSize - 1;
    LColorCtl.Parent  := TabSheet1;
    LColorCtl.Tag     := I;
    LColorCtl.Color   := {$IFDEF FULL_MODE} UdColor.COLOR_PALETTE[I] {$ELSE} clMedGray {$ENDIF};
    LColorCtl.OnClick := OnIndexColorCtrlClick;
    LColorCtl.OnMouseEnter := OnIndexColorCtrlMouseEnter;
    LColorCtl.OnMouseLeave := OnIndexColorCtrlMouseLeave;    
  end;
  
end;



procedure TUdColorsForm.OnIndexColorCtrlMouseEnter(Sender: TObject);
var
  LColor: TColor;
begin
  LColor := TUdColorPanel(Sender).Color;
  lblIndexColor.Caption  := '颜色索引:  ' + IntToStr(TUdColorPanel(Sender).Tag);
  lblIndexColor2.Caption :=  '红, 绿, 蓝:  ' +
                             IntToStr(GetRValue(LColor)) + ', ' +
                             IntToStr(GetGValue(LColor)) + ', ' +
                             IntToStr(GetBValue(LColor)) ;
end;

procedure TUdColorsForm.OnIndexColorCtrlMouseLeave(Sender: TObject);
begin
  lblIndexColor.Caption := '';
  lblIndexColor2.Caption := '';
end;

procedure TUdColorsForm.OnIndexColorCtrlClick(Sender: TObject);
begin
  edtIndexColor.OnChange := nil;
  try
   {$IFDEF FULL_MODE}
    if TUdColorPanel(Sender).Tag in [1..9] then
      edtIndexColor.Text := sInitColors[TUdColorPanel(Sender).Tag]
    else
   {$ENDIF}
      edtIndexColor.Text := IntToStr(TUdColorPanel(Sender).Tag);
  finally
    edtIndexColor.OnChange := edtIndexColorChange;
  end;
  pnlIndexPreview.Color := TUdColorPanel(Sender).Color;  
end;



procedure TUdColorsForm.btnByLayerClick(Sender: TObject);
begin
  edtIndexColor.OnChange := nil;
  try
    edtIndexColor.Text := 'ByLayer';
  finally
    edtIndexColor.OnChange := edtIndexColorChange;
  end;
  pnlIndexPreview.Color := clWhite;
end;

procedure TUdColorsForm.btnByBlockClick(Sender: TObject);
begin
  edtIndexColor.OnChange := nil;
  try
    edtIndexColor.Text := 'ByBlock';
  finally
    edtIndexColor.OnChange := edtIndexColorChange;
  end;    
  pnlIndexPreview.Color := clWhite;  
end;


procedure TUdColorsForm.edtIndexColorChange(Sender: TObject);
begin
//
end;





//=====================================================================================

function TUdColorsForm.GetColorValue: Integer;
begin
  Result := -1;
  if Self.CheckColorValue() then
  begin
    if PageControl1.ActivePageIndex = 0 then
      Result := edtIndexColor.Tag
    else
      Result := pnlTruePreview.Color;
  end;
end;

function TUdColorsForm.GetIsIndexColor: Boolean;
begin
  Result := PageControl1.ActivePageIndex = 0;
end;


procedure TUdColorsForm.SetColorValue(const AValue: Integer);
begin
  if PageControl1.ActivePageIndex = 0 then
  begin
    if (AValue = 0) or (AValue = 256) then
    begin
      pnlIndexPreview.Color := clWhite;
      if (AValue = 0) then edtIndexColor.Text := 'ByBlock' else edtIndexColor.Text := 'ByLayer';
    end else
    if (AValue > 0) and (AValue < 255) then
    begin
     {$IFDEF FULL_MODE}
      pnlIndexPreview.Color := UdColor.COLOR_PALETTE[AValue];
      if AValue in [1..9] then
        edtIndexColor.Text := UdConsts.sInitColors[AValue]
      else
     {$ENDIF};
        edtIndexColor.Text := IntToStr(AValue);
    end;
  end
  else begin
    pnlTruePreview.Color := AValue;

    edtRed.OnChange   := nil;
    edtGreen.OnChange := nil;
    edtBlue.OnChange  := nil;

    edtHue.OnChange  := nil;
    edtSat.OnChange  := nil;
    edtLum.OnChange  := nil;
    try
      edtRed.Text   := IntToStr(GetRValue(AValue));
      edtGreen.Text := IntToStr(GetGValue(AValue));
      edtBlue.Text  := IntToStr(GetBValue(AValue));

      FHSLForm.SelectColor := AValue;

      edtHue.Text  := IntToStr( FHSLForm.Hue );
      edtSat.Text  := IntToStr( FHSLForm.Sat );
      edtLum.Text  := IntToStr( FHSLForm.Lum );      
    finally
      edtRed.OnChange   := edtRGBChange;
      edtGreen.OnChange := edtRGBChange;
      edtBlue.OnChange  := edtRGBChange;

      edtHue.OnChange := edtHSLChange;
      edtSat.OnChange := edtHSLChange;
      edtLum.OnChange := edtHSLChange;      
    end;
  end;
end;

procedure TUdColorsForm.SetIsIndexColor(const AValue: Boolean);
begin
  if AValue then PageControl1.ActivePageIndex := 0 else PageControl1.ActivePageIndex := 1;
end;




function TUdColorsForm.CheckColorValue(): Boolean;
var
  {$IFDEF FULL_MODE}I,{$ENDIF} N: Integer;
  LStr: string;
begin
  if PageControl1.ActivePageIndex = 0 then
  begin
    edtIndexColor.Tag := -1;

    LStr := UpperCase(Trim(edtIndexColor.Text));
    if TryStrToInt(LStr, N) and (N in [1..255]) then
    begin
      edtIndexColor.Tag := N;
    end
    else begin
     {$IFDEF FULL_MODE}
      for I := Low(sInitColors) to High(sInitColors) - 1 do
      begin
        if LStr = UpperCase(sInitColors[I]) then
        begin
          edtIndexColor.Tag := I;
          Break;
        end;
      end;
     {$ENDIF};

      if edtIndexColor.Tag <= 0 then
      begin
        if LStr = 'BYLAYER' then edtIndexColor.Tag := 256  else
        if LStr = 'BYBLOCK' then edtIndexColor.Tag := 0 ;
      end;
    end;

    Result := edtIndexColor.Tag >= 0;
  end
  else begin
    edtRGBChange(edtRed);
    Result := True;
  end;
end;


procedure TUdColorsForm.btnOKClick(Sender: TObject);
begin
  if Self.CheckColorValue() then
    Self.ModalResult := mrOk
  else
    MessageBox(Self.Handle, '无效的颜色名称或数值.', '', MB_ICONWARNING or MB_OK);
end;




//=================================================================================================


end.