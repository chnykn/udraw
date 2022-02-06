{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionPoint;

{$I UdDefs.INC}

interface

uses
  Classes, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdAction, UdBaseActions,
  UdPoint;


type

  //*** TAxPointAction ***//
  TUdActionPoint = class(TUdDrawAction)
  private
    FP1: TPoint2D;

  protected

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;

  

implementation

uses
  SysUtils,
  UdGeo2D, UdUtils, UdAcnConsts;


//=========================================================================================
{ TUdActionPoint }

class function TUdActionPoint.CommandName: string;
begin
  Result := 'point';
end;

constructor TUdActionPoint.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FP1 := Point2D(0, 0);
  Self.CanOrtho := False;
  Self.CanPerpend := False;
  Self.Prompt(sAPoint, pkCmd);
end;

destructor TUdActionPoint.Destroy;
begin

  inherited;
end;


//function TUdActionPoint.GetID: Integer;
//begin
//  Result := ID_POINT;
//end;


function TUdActionPoint.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LPntObj: TUdPoint;
begin
  Result := True;

  if Trim(AValue) = '' then
  begin
    Self.Finish();
    Exit;
  end;

  if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if LIsOpp then
    begin
      LPnt.X := FP1.X + LPnt.X;
      LPnt.Y := FP1.Y + LPnt.Y;
    end;

    LPntObj := TUdPoint.Create(FDocument, False);
    LPntObj.Position := LPnt;

    Self.Submit(LPntObj);
    Self.Prompt(sAPoint + ': ' + PointToStr(LPnt), pkLog);
  end
  else
  begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


procedure TUdActionPoint.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionPoint.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                                    ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LPntObj: TUdPoint;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          FP1 := ACoordPnt;

          LPntObj := TUdPoint.Create(FDocument, False);
          LPntObj.Position := FP1;

          Self.Submit(LPntObj);
          Self.Prompt(sAPoint + ': ' + PointToStr(FP1), pkLog);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
  end;
end;


end.