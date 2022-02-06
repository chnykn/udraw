{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdGdtSymbolPanel;

interface

uses
   Classes, Graphics, Controls,
  UdTypes;

type
  TUdGdtSymbolPanel = class(TCustomControl)
  private
    FGdtShx: TObject;
    FSymbol: Char;
    FSelected: Boolean;
    FFontPolys: TPoint2DArrays;

  protected
    procedure SetSymbol(const AValue: Char);
    procedure SetSelected(const AValue: Boolean);

    procedure CalcFontPolys();
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure RefreshSymbol();

    property GdtShx: TObject read FGdtShx write FGdtShx;
    property Symbol: Char read FSymbol write SetSymbol;
    property Selected: Boolean read FSelected write SetSelected;

  public
    property OnClick;
    property OnDblClick;
    
  end;


implementation

uses
  UdGeo2D, UdShx;

//=================================================================================================
{ TUdGdtSymbolPanel }

constructor TUdGdtSymbolPanel.Create(AOwner: TComponent);
begin
  inherited;
  FGdtShx := nil;
  FSymbol := #0;
  FSelected := False;
  FFontPolys := nil;

  Self.Width := 33;
  Self.Height := 33;
  Self.ParentColor := False;

  Self.Color := clBlack;
  Self.Font.Size := 12;
end;

destructor TUdGdtSymbolPanel.Destroy;
begin
  FGdtShx := nil;
  FFontPolys := nil;
  inherited;
end;

procedure TUdGdtSymbolPanel.Paint;
var
  I, J, L: Integer;
  LPnts: TPoint2DArray;
  LPoints: array of TPoint;
begin
  inherited;

  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  Canvas.Brush.Style := bsSolid;

  if FSelected then
  begin
    Self.Color := clWhite;
    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := clWhite;

    Canvas.Font.Color := clBlack;
  end
  else begin
    Self.Color := clBlack;
    Canvas.Pen.Color := clWhite;
    Canvas.Brush.Color := clBlack;

    Canvas.Font.Color := clWhite;
  end;


  if System.Length(FFontPolys) > 0 then
  begin
    for I := 0 to System.Length(FFontPolys) - 1 do
    begin
      LPnts := FFontPolys[I];

      L := System.Length(LPnts);
      if L <= 1 then Continue;

      System.SetLength(LPoints, L);
      for J := 0 to L - 1 do
      begin
        LPoints[J].X := Trunc(LPnts[J].X) ;
        LPoints[J].Y := Self.Height - Trunc(LPnts[J].Y);
      end;

      Canvas.Polyline(LPoints)
    end;
  end
  else begin
    Canvas.TextOut(5, 5, FSymbol);
  end;
end;



procedure TUdGdtSymbolPanel.RefreshSymbol;
begin
  Self.CalcFontPolys;
  Self.Invalidate;
end;

procedure TUdGdtSymbolPanel.CalcFontPolys;
var
  LStyle: TUdTextStyleRec;
begin
  FFontPolys := nil;
  if not Assigned(FGdtShx) then Exit;

  LStyle.WidthFactor := 1.0;
  LStyle.Rotation    := 0.0;
  LStyle.Align       := taMiddleCenter;
  LStyle.Backward    := False;
  LStyle.Upsidedown  := False;

  FFontPolys := TUdShx(FGdtShx).GetTextPolys(FSymbol, Point2D(Self.Width /2, Self.Height/2), Self.Height * 0.4, LStyle);
end;


procedure TUdGdtSymbolPanel.SetSymbol(const AValue: Char);
begin
  if FSymbol <> AValue then
  begin
    FSymbol := AValue;
    CalcFontPolys();
    Self.Invalidate();
  end;
end;

procedure TUdGdtSymbolPanel.SetSelected(const AValue: Boolean);
begin
  if FSelected <> AValue then
  begin
    FSelected := AValue;
    Self.Invalidate();
  end;
end;



end.