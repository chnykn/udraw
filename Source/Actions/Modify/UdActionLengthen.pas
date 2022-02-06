{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionLengthen;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdAction, UdBaseActions;


type  
  //*** UdActionLengthen ***//
  TUdActionLengthen = class(TUdModifyAction)
  private
    

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;  


implementation



  
//==================================================================================================
{ TUdActionLengthen }

class function TUdActionLengthen.CommandName: string;
begin
  Result := 'lengthen';
end;

constructor TUdActionLengthen.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

end;

destructor TUdActionLengthen.Destroy;
begin
//....
  inherited;
end;



procedure TUdActionLengthen.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

end;



procedure TUdActionLengthen.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionLengthen.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
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