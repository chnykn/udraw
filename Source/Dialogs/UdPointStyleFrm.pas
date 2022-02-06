{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPointStyleFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TUdPointStyleForm = class(TForm)

    PaintBox1: TPaintBox;
    PaintBox2: TPaintBox;
    PaintBox3: TPaintBox;
    PaintBox4: TPaintBox;
    PaintBox5: TPaintBox;
    PaintBox6: TPaintBox;
    PaintBox7: TPaintBox;
    PaintBox8: TPaintBox;
    PaintBox9: TPaintBox;
    PaintBox10: TPaintBox;
    PaintBox11: TPaintBox;
    PaintBox12: TPaintBox;
    PaintBox13: TPaintBox;
    PaintBox14: TPaintBox;
    PaintBox15: TPaintBox;
    PaintBox16: TPaintBox;
    PaintBox17: TPaintBox;
    PaintBox18: TPaintBox;
    PaintBox19: TPaintBox;
    PaintBox20: TPaintBox;
    
    lblPointSize: TLabel;
    edtSize: TEdit;
    rdbWindowsPixels: TRadioButton;
    rdbDrawingUnits: TRadioButton;
    
    btnOK: TButton;
    btnCancel: TButton;
    
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PaintBoxClick(Sender: TObject);

  private
    FMode: Integer;
    FSize: Double;

  protected
    procedure SetMode(const Value: Integer);

    procedure SetSize(const Value: Double);
    procedure SetDrawingUnits(const Value: Boolean);

    function GetSize: Double;
    function GetDrawingUnits: Boolean;
        
  public
    property Mode: Integer read FMode write SetMode;
    property Size: Double  read GetSize write SetSize;
    property DrawingUnits: Boolean read GetDrawingUnits write SetDrawingUnits;

  end;

function ShowPointStyleDialog(var AMode: Integer; var ASize: Double; var ADrawingUnits: Boolean): Boolean;


implementation

{$R *.dfm}

uses
  SysUtils, UdDrawUtil;



function ShowPointStyleDialog(var AMode: Integer; var ASize: Double; var ADrawingUnits: Boolean): Boolean;
var
  LForm: TUdPointStyleForm;
begin
  Result := False;
  
  LForm := TUdPointStyleForm.Create(nil);
  try
    LForm.Mode         := AMode;
    LForm.Size         := ASize;
    LForm.DrawingUnits := ADrawingUnits;
    
    if LForm.ShowModal() = mrOk then
    begin
      AMode          := LForm.Mode        ;
      ASize          := LForm.Size        ;
      ADrawingUnits  := LForm.DrawingUnits;

      Result := True;
    end;
  finally
    LForm.Free();
  end;
end;




//===============================================================================================
{ TUdPointStyleForm }

procedure TUdPointStyleForm.FormCreate(Sender: TObject);
begin
  FMode := 0;
  FSize := 16.0;
end;

procedure TUdPointStyleForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TUdPointStyleForm.FormShow(Sender: TObject);
begin
//
end;






//--------------------------------------------------------------------

procedure TUdPointStyleForm.SetMode(const Value: Integer);
begin
  FMode := Value;
  if Self.HandleAllocated then Self.Invalidate();
end;

procedure TUdPointStyleForm.SetSize(const Value: Double);
begin
  edtSize.Text := FormatFloat('0.0000', Value);
  FSize := Value;
end;

procedure TUdPointStyleForm.SetDrawingUnits(const Value: Boolean);
begin
  case Value of
    True : rdbDrawingUnits.Checked  := True;
    False: rdbWindowsPixels.Checked := True;
  end;
end;



function TUdPointStyleForm.GetSize: Double;
begin
  Result := StrToFloatDef(edtSize.Text, FSize);
  if Result <= 0 then Result := FSize;
end;

function TUdPointStyleForm.GetDrawingUnits: Boolean;
begin
  Result :=  rdbDrawingUnits.Checked;
end;




//--------------------------------------------------------------------

procedure TUdPointStyleForm.PaintBoxPaint(Sender: TObject);
var
  N: Integer;
  LPaintBox: TPaintBox;
begin
  LPaintBox := TPaintBox(Sender);

  LPaintBox.Canvas.Pen.Style := psSolid;
  LPaintBox.Canvas.Brush.Style := bsSolid;

  if FMode = LPaintBox.Tag then
  begin
    LPaintBox.Canvas.Pen.Color := clWhite;
    LPaintBox.Canvas.Brush.Color := clBlack;
  end
  else begin
    LPaintBox.Canvas.Pen.Color := clBlack;
    LPaintBox.Canvas.Brush.Color := clWhite;
  end;

  LPaintBox.Canvas.FillRect(LPaintBox.ClientRect);
  if FMode <> LPaintBox.Tag then
    LPaintBox.Canvas.Rectangle(LPaintBox.ClientRect);


  N := LPaintBox.Tag mod 32;
  case N of
    0: LPaintBox.Canvas.Pixels[20, 15] := LPaintBox.Canvas.Pen.Color;
    1: ;
    2: UdDrawUtil.DrawCross(LPaintBox.Canvas, 20, 15, 12);
    3: UdDrawUtil.DrawXCross(LPaintBox.Canvas, 20, 15, 12);
    4: begin LPaintBox.Canvas.MoveTo(20, 15); LPaintBox.Canvas.LineTo(20, 5); end;
  end;

  N := LPaintBox.Tag div 32;
  if (N and 1) > 0 then UdDrawUtil.DrawCircle(LPaintBox.Canvas, 20, 15, 10);
  if (N and 2) > 0 then UdDrawUtil.DrawRect(LPaintBox.Canvas, 20, 15, 10);
end;


procedure TUdPointStyleForm.PaintBoxClick(Sender: TObject);
begin
  FMode := TComponent(Sender).Tag;
  Self.Invalidate();
end;


end.