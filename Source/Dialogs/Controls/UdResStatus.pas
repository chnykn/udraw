{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdResStatus;

{$R UdStatus.res}

interface

uses
  Windows, Graphics;

type

  TUdResStatus = class(TObject)
  private
    FNormalBmp : TBitmap;
    FNewBmp    : TBitmap;
    FUselessBmp: TBitmap;
    FCurrentBmp: TBitmap;
    FDeletedBmp: TBitmap;

  public
    constructor Create();
    destructor Destroy(); override;

    property NormalBmp : TBitmap read FNormalBmp  write FNormalBmp ;
    property NewBmp    : TBitmap read FNewBmp     write FNewBmp    ;
    property UselessBmp: TBitmap read FUselessBmp write FUselessBmp;
    property CurrentBmp: TBitmap read FCurrentBmp write FCurrentBmp;
    property DeletedBmp: TBitmap read FDeletedBmp write FDeletedBmp;
  end;


implementation


{ TUdResStatus }

constructor TUdResStatus.Create;
begin
  FNormalBmp  := TBitmap.Create;
  FNewBmp     := TBitmap.Create;
  FUselessBmp := TBitmap.Create;
  FCurrentBmp := TBitmap.Create;
  FDeletedBmp := TBitmap.Create;

  FNormalBmp .Handle := LoadBitmap(Hinstance, 'NORMAL');
  FNewBmp.Handle     := LoadBitmap(Hinstance, 'NEW');
  FUselessBmp.Handle := LoadBitmap(Hinstance, 'USELESS');
  FCurrentBmp.Handle := LoadBitmap(Hinstance, 'CURRENT');
  FDeletedBmp.Handle := LoadBitmap(Hinstance, 'DELETED');

  FNormalBmp .Transparent := True;
  FNewBmp.Transparent     := True;
  FUselessBmp.Transparent := True;
  FCurrentBmp.Transparent := True;
  FDeletedBmp.Transparent := True;
end;

destructor TUdResStatus.Destroy;
begin
  FNormalBmp.Free;
  FNewBmp.Free;
  FUselessBmp.Free;
  FCurrentBmp.Free;
  FDeletedBmp.Free;

  inherited;
end;


end.