{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionStretch;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdAction, UdBaseActions;


type  
  //*** UdActionStretch ***//
  TUdActionStretch = class(TUdModifyAction)
  private
    

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;  


implementation



  
//==================================================================================================
{ TUdActionStretch }

constructor TUdActionStretch.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

end;

destructor TUdActionStretch.Destroy;
begin
//....
  inherited;
end;



procedure TUdActionStretch.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

end;



procedure TUdActionStretch.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionStretch.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  if (AKind = mkMouseDown) and (AButton = mbRight) then
  begin
    FSelAction.Visible := False;
    //......

    Self.Finish();
  end;
end;

end.