{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdResLayers;

{$R UdLayers.res}

interface

uses
  Windows, Graphics;

type

  TUdResLayers = class(TObject)
  private
    FVisileBmp: TBitmap;
    FInvisileBmp: TBitmap;

    FLockBmp: TBitmap;
    FUnLockBmp: TBitmap;

    FFreezeBmp: TBitmap;
    FUnFreezeBmp: TBitmap;

    FPlotBmp: TBitmap;
    FUnPlotBmp: TBitmap;

  public
    constructor Create();
    destructor Destroy(); override;


    property VisileBmp: TBitmap read FVisileBmp write FVisileBmp;
    property InvisileBmp: TBitmap read FInvisileBmp write FInvisileBmp;

    property LockBmp: TBitmap read FLockBmp write FLockBmp;
    property UnLockBmp: TBitmap read FUnLockBmp write FUnLockBmp;

    property FreezeBmp: TBitmap read FFreezeBmp write FFreezeBmp;
    property UnFreezeBmp: TBitmap read FUnFreezeBmp write FUnFreezeBmp;

    property PlotBmp: TBitmap read FPlotBmp write FPlotBmp;
    property UnPlotBmp: TBitmap read FUnPlotBmp write FUnPlotBmp;

  end;


implementation


{ TUdResLayers }

constructor TUdResLayers.Create;
begin
  FVisileBmp   := TBitmap.Create;
  FInvisileBmp := TBitmap.Create;
  FLockBmp     := TBitmap.Create;
  FUnLockBmp   := TBitmap.Create;
  FFreezeBmp   := TBitmap.Create;
  FUnFreezeBmp := TBitmap.Create;
  FPlotBmp     := TBitmap.Create;
  FUnPlotBmp   := TBitmap.Create;

  FVisileBmp.Handle   := LoadBitmap(Hinstance, 'VISIBLE');
  FInvisileBmp.Handle := LoadBitmap(Hinstance, 'INVISIBLE');
  FLockBmp.Handle     := LoadBitmap(Hinstance, 'LOCK');
  FUnLockBmp.Handle   := LoadBitmap(Hinstance, 'UNLOCK');
  FFreezeBmp.Handle   := LoadBitmap(Hinstance, 'FREEZE');
  FUnFreezeBmp.Handle := LoadBitmap(Hinstance, 'UNFREEZE');
  FPlotBmp.Handle     := LoadBitmap(Hinstance, 'PLOT');
  FUnPlotBmp.Handle   := LoadBitmap(Hinstance, 'UNPLOT');

  FVisileBmp.Transparent   := True;
  FInvisileBmp.Transparent := True;
  FLockBmp.Transparent     := True;
  FUnLockBmp.Transparent   := True;
  FFreezeBmp.Transparent   := True;
  FUnFreezeBmp.Transparent := True;
  FPlotBmp.Transparent     := True;
  FUnPlotBmp.Transparent   := True;
end;

destructor TUdResLayers.Destroy;
begin
  FVisileBmp.Free;
  FInvisileBmp.Free;

  FLockBmp.Free;
  FUnLockBmp.Free;

  FFreezeBmp.Free;
  FUnFreezeBmp.Free;

  FPlotBmp.Free;
  FUnPlotBmp.Free;

  inherited;
end;


end.