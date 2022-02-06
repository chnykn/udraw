{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdHSLFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls;

type
  TUdMovingColor = procedure(Sender: TObject; AColor: TColor) of object;
  
  TUdHSLForm = class(TForm)
    imgHSL: TImage;
    imgLum: TImage;
    tcbLum: TTrackBar;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    
    procedure imgHSLMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure imgHSLClick(Sender: TObject);
    procedure imgHSLMouseLeave(Sender: TObject);

  private
    FHSLBitmap: TBitmap;
    
    FHue, FSat, FLum: Integer;
    FVHue, FVSat, FVLum: Integer;

    FManulLum: Boolean;
    
    FSelectColor: TColor;
    FMovingColor: TColor;

    FOnMovingColor: TUdMovingColor;
    FOnSelectColor: TNotifyEvent;
    FOnLeavedColor: TNotifyEvent;

  protected
    function GetHue: Integer;
    procedure SetHue(const Value: Integer);

    function GetSat: Integer;
    procedure SetSat(const Value: Integer);

    function GetLum: Integer;
    procedure SetLum(const Value: Integer);

    procedure DrawHSCoord();
    procedure UpdateSelectColor();

    procedure InitHSLImage();
    procedure InitLumImage();

    function GetSelectColor: TColor;
    procedure SetSelectColor(const Value: TColor);

    procedure OnLumTrackBarChange(Sender: TObject);
        
  public
    property SelectColor: TColor read GetSelectColor write SetSelectColor;

    property Hue: Integer read GetHue write SetHue; //色调[0~360]
    property Sat: Integer read GetSat write SetSat; //饱和度[0~100]
    property Lum: Integer read GetLum write SetLum; //色调[0~100]

    property OnSelectColor: TNotifyEvent   read FOnSelectColor write FOnSelectColor;
    property OnMovingColor: TUdMovingColor read FOnMovingColor write FOnMovingColor;
    property OnLeavedColor: TNotifyEvent   read FOnLeavedColor write FOnLeavedColor;
  end;


implementation

{$R *.dfm}

uses
  UdDrawUtil;


type
  TRGBQuadArray = array [0..65535] of TRGBQuad;
  PRGBQuadArray = ^TRGBQuadArray;
   


function RGBtoRGBQuad(R, G, B: byte): TRGBQuad; overload;
begin
  with Result do
  begin
    rgbRed      := R;
    rgbGreen    := G;
    rgbBlue     := B;
    rgbReserved := 0;
  end
end;

function RGBToRGBQuad(C: TColor): TRGBQuad; overload;
begin
  with Result do
  begin
    rgbRed      := GetRValue(C);
    rgbGreen    := GetGValue(C);
    rgbBlue     := GetBValue(C);
    rgbReserved := 0;
  end;
end;



//==================================================================================================

procedure TUdHSLForm.FormCreate(Sender: TObject);
begin
  FHue := 0;
  FSat := 0;
  FLum := MAX_HUE;

  FVHue := 0;
  FVSat := 0;
  FVLum := 100;

  FManulLum := False;
  FSelectColor := clWhite;
  FMovingColor := clWhite;

  tcbLum.Min := 0;
  tcbLum.Max := MAX_LUM;
  tcbLum.Position := 0;
  tcbLum.OnChange := OnLumTrackBarChange;

  FHSLBitmap := nil;
  
  UpdateSelectColor();
  InitHSLImage();
  InitLumImage();
end;

procedure TUdHSLForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FHSLBitmap) then FHSLBitmap.Free;
  FHSLBitmap := nil;
  
  tcbLum.OnChange := nil;
end;

procedure TUdHSLForm.FormShow(Sender: TObject);
begin
//
end;





//------------------------------------------------------------------------

function TUdHSLForm.GetHue: Integer;
begin
  Result := FVHue;
end;

procedure TUdHSLForm.SetHue(const Value: Integer);
begin
  if (Value >= 0) and (Value <= 360) and (FVHue <> Value) then
  begin
    FVHue := Value;
    FHue := Trunc((FVHue / 360) * MAX_HUE);

    UpdateSelectColor();
  end;
end;


function TUdHSLForm.GetSat: Integer;
begin
  Result := FVSat;
end;

procedure TUdHSLForm.SetSat(const Value: Integer);
begin
  if (Value in [0..100]) and (FVSat <> Value) then
  begin
    FVSat := Value;
    FSat := Trunc((FVSat / 100) * MAX_SAT);

    UpdateSelectColor();
  end;
end;



function TUdHSLForm.GetLum: Integer;
begin
  Result := FVLum;
end;

procedure TUdHSLForm.SetLum(const Value: Integer);
begin
  if (Value in [0..100]) and (FVLum <> Value) then
  begin
    FVLum := Value;
    FLum := Trunc((FVLum / 100) * MAX_LUM);

    tcbLum.OnChange := nil;
    try
      tcbLum.Position := MAX_LUM - FLum;
    finally
      tcbLum.OnChange := OnLumTrackBarChange;
    end;

    FManulLum := True;

    UpdateSelectColor();
  end;
end;






function TUdHSLForm.GetSelectColor: TColor;
begin
  Result := FSelectColor;
end;

procedure TUdHSLForm.SetSelectColor(const Value: TColor);
begin
  if FSelectColor <> Value then
  begin
    FSelectColor := ColorToRGB(Value);
    RGBtoHSL(FSelectColor, FHue, FSat, FLum);

    FVHue := Trunc((FHue / 180) * 360);
    FVSat := Trunc((FSat / 180) * 100);
    FVLum := Trunc((FLum / 180) * 100);

    tcbLum.OnChange := nil;
    try
      tcbLum.Position := MAX_LUM - FLum;
    finally
      tcbLum.OnChange := OnLumTrackBarChange;
    end;

//    FManulLum := True;
    Self.DrawHSCoord();
    Self.InitLumImage();

    if Assigned(FOnSelectColor) then FOnSelectColor(Self);  
  end;
end;


procedure TUdHSLForm.DrawHSCoord();
var
  X, Y: Integer;
begin
  X := FHue;
  Y := MAX_SAT - FSat;
  if (X >= 0) and (X <= MAX_HUE) and (Y >= 0) and (Y <= MAX_SAT) then
  begin
    imgHSL.Picture.Bitmap.Assign(FHSLBitmap);

    imgHSL.Canvas.Pen.Width := 3;
    imgHSL.Canvas.Pen.Style := psSolid;

    imgHSL.Canvas.MoveTo(X-4, Y);  imgHSL.Canvas.LineTo(X-8, Y);
    imgHSL.Canvas.MoveTo(X+4, Y);  imgHSL.Canvas.LineTo(X+8, Y);

    imgHSL.Canvas.MoveTo(X, Y-4);  imgHSL.Canvas.LineTo(X, Y-8);
    imgHSL.Canvas.MoveTo(X, Y+4);  imgHSL.Canvas.LineTo(X, Y+8);
  end;
end;

procedure TUdHSLForm.UpdateSelectColor;
begin
  DrawHSCoord();
  FSelectColor := HSLToRGB(FHue, FSat, FLum);
  if Assigned(FOnSelectColor) then FOnSelectColor(Self);
end;

procedure TUdHSLForm.OnLumTrackBarChange(Sender: TObject);
begin
  FLum := MAX_LUM - tcbLum.Position;
  FVLum := Trunc((FLum / 180) * 100);
  FManulLum := True;
  UpdateSelectColor();
end;



procedure TUdHSLForm.imgHSLMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if (X >= 0) and (X <= FHSLBitmap.Width) and
     (Y >= 0) and (Y <= FHSLBitmap.Height) then
  begin
    FMovingColor := FHSLBitmap.Canvas.Pixels[X, Y];
    if Assigned(FOnMovingColor) then FOnMovingColor(Self, FMovingColor);
  end;
end;

procedure TUdHSLForm.imgHSLClick(Sender: TObject);
var
  LLum: Integer;
begin
  FMovingColor := ColorToRGB(FMovingColor);
  RGBtoHSL(FMovingColor, FHue, FSat, LLum);

  FVHue := Trunc((FHue / 180) * 360);
  FVSat := Trunc((FSat / 180) * 100);

  if not FManulLum then
  begin
    FLum := LLum;
    FVLum := Trunc((FLum / 180) * 100);

    tcbLum.OnChange := nil;
    try
      tcbLum.Position := MAX_LUM - FLum;
    finally
      tcbLum.OnChange := OnLumTrackBarChange;
    end;
  end;

  UpdateSelectColor();
  Self.InitLumImage();
end;

procedure TUdHSLForm.imgHSLMouseLeave(Sender: TObject);
begin
  if Assigned(FOnLeavedColor) then FOnLeavedColor(Self);
end;





//------------------------------------------------------------------------

procedure TUdHSLForm.InitHSLImage();
var
  Row: PRGBQuadArray;
  Hue, Sat, Lum: Integer;
begin
  Lum := MAX_LUM div 2;

  if not Assigned(FHSLBitmap) then
  begin
    FHSLBitmap := TBitmap.Create;

    FHSLBitmap.PixelFormat := pf32bit;
    FHSLBitmap.Width  := MAX_HUE + 1; //240;
    FHSLBitmap.Height := MAX_SAT + 1; //241;

    for Hue := 0 to MAX_HUE do  //239
    begin
      for Sat := 0 to MAX_SAT do  //240
      begin
        Row := FHSLBitmap.ScanLine[MAX_SAT - Sat];
        Row[Hue] := RGBToRGBQuad(HSLToRGB(Hue, Sat, Lum));
      end;
    end;    
  end;

  imgHSL.Picture.Bitmap.Assign(FHSLBitmap);
end;

procedure TUdHSLForm.InitLumImage;
var
  I, J: integer;
  Row: PRGBQuadArray;
  LumBmp: TBitmap;
begin
  LumBmp := TBitmap.Create;
  try
    LumBmp.PixelFormat := pf32bit;
    LumBmp.Width := 16;
    LumBmp.Height := MAX_LUM;

    for I := 0 to MAX_LUM - 1 do
    begin
      Row := LumBmp.Scanline[I];
      for J := 0 to 16 do
        Row[J] := RGBToRGBQuad(HSLToRGB(FHue, FSat, MAX_LUM - I));
    end;

    imgLum.Picture.Bitmap.Assign(LumBmp);
  finally
    LumBmp.Free;
  end;
end;



end.