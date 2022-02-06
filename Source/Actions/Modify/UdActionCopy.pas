{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionCopy;

{$I UdDefs.INC}

interface

uses

  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdActionCoupleMod;


type  
  //*** UdActionCopy ***//
  TUdActionCopy = class(TUdActionCoupleMod)
  private
    FLastP2: TPoint2D;

  protected
    function UpdateEntities(): Boolean; override;

    function SetSecondPoint(APnt: TPoint2D): Boolean; override;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
  end;


implementation

uses
  
  UdMath, UdGeo2D, UdAcnConsts;

  
//==================================================================================================
{ TUdActionCopy }

class function TUdActionCopy.CommandName: string;
begin
  Result := 'copy';
end;

constructor TUdActionCopy.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FLastP2 := InvalidPoint();
end;

destructor TUdActionCopy.Destroy;
begin
  //....
  inherited;
end;



//------------------------------------------------------------


function TUdActionCopy.UpdateEntities(): Boolean;

  procedure _MoveTaskEntities();
  var
    I: Integer;
  begin
    for I := System.Length(FTaskEntities) - 1 downto 0 do
    begin
      FTaskEntities[I].BeginUpdate();
      try
        FTaskEntities[I].Assign(FSelectedEntities[I]);
        FTaskEntities[I].Move(FP1, FP2);
        FTaskEntities[I].Visible := True;
      finally
        FTaskEntities[I].EndUpdate();
      end;
    end;
  end;

begin
  Result := False;
  if FStep <> 2 then Exit;

  FLine.XData := Segment2D(FP1, FP2);
  FLine.Visible := True;

  if not NeedSketching() then
  begin
    _MoveTaskEntities();
  end
  else begin
    FRect.SetPoints(FRectPnts);
    FRect.Move(FP1, FP2);
    FRect.Visible := True;
  end;

  Result := True;
end;



function TUdActionCopy.SetSecondPoint(APnt: TPoint2D): Boolean;

  function _DoAction(): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if System.Length(FSelectedEntities) <= 0 then Exit;

    for I := 0 to System.Length(FSelectedEntities) - 1 do
    begin
      FTaskEntities[I].BeginUpdate();
      try
        FTaskEntities[I].Assign(FSelectedEntities[I]);
        FTaskEntities[I].Move(FP1, FP2);

        FTaskEntities[I].Finished := True;
        FTaskEntities[I].Visible := True;
      finally
        FTaskEntities[I].EndUpdate();
      end;
    end;

    Self.AddEntities(FTaskEntities);
    FTaskEntities := nil;
    Result := True;
  end;

begin
  Result := False;
  if FStep <> 2 then Exit;

  FP2 := APnt;

  if NotEqual(FLastP2, FP2) then
  begin
    if _DoAction() then PopulateTaskEntities();
    FLastP2 := FP2;
  end;
  
  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);
  Result := True;
end;






end.