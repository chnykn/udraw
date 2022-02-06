{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActioLocatePnt;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions;

type

  //*** TUdActionLocatePnt ***//
  TUdActionLocatePnt = class(TUdInquiryAction)
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

uses
  SysUtils, UdAcnConsts;



//================================================================================================
{ TUdActionLocatePnt }


class function TUdActionLocatePnt.CommandName: string;
begin
  Result := 'id';
end;



constructor TUdActionLocatePnt.Create(ADocument, ALayout: TUdObject; Args: string);
begin
  inherited;

  Self.CanSnap    := True;
  Self.CanOSnap   := True;
  Self.CanPerpend := True;
    
  Self.SetCursorStyle(csDraw);
  Self.Prompt(sAPoint, pkCmd);
end;

destructor TUdActionLocatePnt.Destroy;
begin

  inherited;
end;




//--------------------------------------------------------------------------

procedure TUdActionLocatePnt.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

end;


function TUdActionLocatePnt.Parse(const AValue: string): Boolean;
var
  LValue: string;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));
  if LValue = '' then Self.Finish();
end;


procedure TUdActionLocatePnt.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionLocatePnt.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LStr: string;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          LStr := sAPoint + ':  ' +
                  'X = ' + Self.RealToStr(ACoordPnt.X) + '    ' +
                  'Y = ' + Self.RealToStr(ACoordPnt.Y);
          Self.Prompt(LStr, pkLog);
          Self.Finish();
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin

      end;
  end;  
end;


end.