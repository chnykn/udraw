{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdHatchBitmaps;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics,
  UdHashMaps;

type
  TUdHatchBitmaps = class(TObject)
  private
    FList: TList;
    FSelPenBmps: TUdStrHashMap;

  protected

  public
    constructor Create();
    destructor Destroy(); override;

    procedure Clear();
    function GetSelPenBitmap(ABkColor, AFgColor: TColor): TBitmap;
  end;


function HatchBitmapsRes(): TUdHatchBitmaps;


implementation

{$R UdHatchBitmaps.res}

uses
  SysUtils;


var
  GHatchBitmaps: TUdHatchBitmaps;


function HatchBitmapsRes(): TUdHatchBitmaps;
begin
  Result := GHatchBitmaps;
end;



//================================================================================================
{ TUdHatchBitmaps }

constructor TUdHatchBitmaps.Create;
begin
  FList := TList.Create;
  FSelPenBmps := TUdStrHashMap.Create();
end;

destructor TUdHatchBitmaps.Destroy;
begin
  Clear();
  FList.Free;
  FSelPenBmps.Free;
  inherited;
end;


procedure TUdHatchBitmaps.Clear;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do TObject(FList[I]).Free;
  FList.Clear();

  FSelPenBmps.Clear();
end;



function TUdHatchBitmaps.GetSelPenBitmap(ABkColor, AFgColor: TColor): TBitmap;
var
  I, J: Integer;
  LKey: string;
  LBitmap: TBitmap;
  LBmpHandle: HBITMAP;
begin
  LKey := IntToStr(ABkColor) + '|' + IntToStr(AFgColor);

  LBitmap := TBitmap(FSelPenBmps.GetValue(LKey));

  if not Assigned(LBitmap) then
  begin
    LBmpHandle := LoadBitmap(Hinstance, 'SEL_PEN');
    
    if LBmpHandle > 0 then
    begin
      LBitmap := TBitmap.Create;
      LBitmap.Handle := LBmpHandle;
      LBitmap.HandleType := bmDIB;
      LBitmap.PixelFormat := pf24bit;

      for I := 0 to LBitmap.Width - 1 do
      begin
        for J := 0 to LBitmap.Height - 1 do
        begin
          with LBitmap.Canvas do
          begin
            if Pixels[I, J] = clBlack then
              Pixels[I, J] := ABkColor
            else
              Pixels[I, J] := AFgColor;
          end;
        end;
      end;

      FSelPenBmps.Add(LKey, LBitmap);

      FList.Add(LBitmap);
    end;
  end;

  Result := LBitmap;
end;




initialization
  GHatchBitmaps := TUdHatchBitmaps.Create;

finalization
  GHatchBitmaps.Free;



end.