{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdCanvas;

{$I UdDefs.INC}

interface

uses
  Graphics, Types;

type
  TUdCanvas = class(TCanvas)
  public
    procedure MoveToEx(X, Y: Integer); virtual;
    procedure LineToEx(X, Y: Integer); virtual;
  end;


implementation

{ TUdCanvas }

procedure TUdCanvas.MoveToEx(X, Y: Integer);
begin
  Self.MoveTo(X, Y);
end;

procedure TUdCanvas.LineToEx(X, Y: Integer);
begin
  Self.LineTo(X, Y);
end;





end.