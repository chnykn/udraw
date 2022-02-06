{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionList;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions;

type

  //*** TUdActionList ***//
  TUdActionList = class(TUdInquiryAction)
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    function Parse(const AValue: string): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;

implementation



//================================================================================================
{ TUdActionList }


class function TUdActionList.CommandName: string;
begin
  Result := 'list';
end;



constructor TUdActionList.Create(ADocument, ALayout: TUdObject; Args: string);
begin
  inherited;

end;

destructor TUdActionList.Destroy;
begin

  inherited;
end;




//--------------------------------------------------------------------------

procedure TUdActionList.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

end;


function TUdActionList.Parse(const AValue: string): Boolean;
begin
  Result := False;
end;


procedure TUdActionList.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionList.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

end;

end.