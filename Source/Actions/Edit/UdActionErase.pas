{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionErase;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdAction, UdBaseActions;


type  
  //*** UdActionErase ***//
  TUdActionErase = class(TUdModifyAction)
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

uses
  UdLayout;

  
//==================================================================================================
{ TUdActionErase }

class function TUdActionErase.CommandName: string;
begin
  Result := 'erase';
end;

constructor TUdActionErase.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  LLayout: TUdLayout;
begin
  inherited;

  LLayout := TUdLayout(Self.GetLayout());

  if Assigned(LLayout) then
  begin
    if LLayout.SelectedList.Count > 0 then
    begin
      LLayout.EraseSelectedEntities();
      Self.Aborted := True;
    end;
  end
  else Self.Aborted := True;
end;

destructor TUdActionErase.Destroy;
begin
  inherited;
end;



procedure TUdActionErase.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  //....
end;



procedure TUdActionErase.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionErase.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
begin
  inherited;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit;

  if (AKind = mkMouseDown) and (AButton = mbRight) then
  begin
    FSelAction.Visible := False;
    LLayout.EraseSelectedEntities();

    Self.Finish();
  end;
end;





end.