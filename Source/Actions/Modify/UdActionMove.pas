{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionMove;

{$I UdDefs.INC}

interface

uses

  UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdActionCopy;


type  
  //*** UdActionMove ***//
  TUdActionMove = class(TUdActionCopy)
  protected
    function SetSecondPoint(APnt: TPoint2D): Boolean; override;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
  end;


implementation

uses
  UdAcnConsts;

  
//==================================================================================================
{ TUdActionMove }

class function TUdActionMove.CommandName: string;
begin
  Result := 'move';
end;

constructor TUdActionMove.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

end;

destructor TUdActionMove.Destroy;
begin

  inherited;
end;



function TUdActionMove.SetSecondPoint(APnt: TPoint2D): Boolean;
var
  I: Integer;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FP2 := APnt;
  for I := 0 to System.Length(FSelectedEntities) - 1 do
    FSelectedEntities[I].Move(FP1, FP2);

  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);

  Result := Self.Finish();
end;

end.