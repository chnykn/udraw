{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionMirror;

{$I UdDefs.INC}

interface

uses

  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdActionCoupleMod;


type  
  //*** UdActionMirror ***//
  TUdActionMirror = class(TUdActionCoupleMod)
  protected
    function UpdateEntities(): Boolean; override;

    function SetSecondPoint(APnt: TPoint2D): Boolean; override;

    function GetFirstPointPrompt: string; override;
    function GetSecondPointPrompt: string; override;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
  end;


implementation

uses
  UdMath, UdGeo2D, UdAcnConsts;

  
//==================================================================================================
{ TUdActionMirror }

class function TUdActionMirror.CommandName: string;
begin
  Result := 'mirror';
end;

constructor TUdActionMirror.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
end;

destructor TUdActionMirror.Destroy;
begin
  //....
  inherited;
end;




function TUdActionMirror.GetFirstPointPrompt: string;
begin
  Result := sMirrorFirstPnt;
end;

function TUdActionMirror.GetSecondPointPrompt: string;
begin
  Result := sMirrorSecondPnt;
end;



//------------------------------------------------------------


function TUdActionMirror.UpdateEntities(): Boolean;

  procedure _MirrorTaskEntities();
  var
    I: Integer;
  begin
    for I := System.Length(FTaskEntities) - 1 downto 0 do
    begin
      FTaskEntities[I].BeginUpdate();
      try
        FTaskEntities[I].Assign(FSelectedEntities[I]);
        FTaskEntities[I].Mirror(FP1, FP2);
        FTaskEntities[I].Visible := True;
      finally
        FTaskEntities[I].EndUpdate();
      end;
    end;
  end;

var
  LPnts: TPoint2DArray;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FLine.XData := Segment2D(FP1, FP2);
  FLine.Visible := True;

  if not NeedSketching() then
  begin
    _MirrorTaskEntities();
  end
  else begin
    LPnts := UdGeo2D.Mirror(Line2D(FP1, FP2), FRectPnts);
    FRect.SetPoints(LPnts);
    FRect.Visible := True;
  end;

  Result := True;
end;




function TUdActionMirror.SetSecondPoint(APnt: TPoint2D): Boolean;

  function _DoAction(): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if System.Length(FSelectedEntities) <= 0 then Exit;
    
    for I := 0 to System.Length(FSelectedEntities) - 1 do
    begin
      FTaskEntities[I].Assign(FSelectedEntities[I]);
      FTaskEntities[I].Mirror(FP1, FP2);

      FTaskEntities[I].Finished := True;
      FTaskEntities[I].Visible := True;
    end;

    Self.AddEntities(FTaskEntities);
    FTaskEntities := nil;
    
    Result := True;
  end;

begin
  Result := False;
  if FStep <> 2 then Exit;

  FP2 := APnt;

  if NotEqual(FP1, FP2) then
  begin
    _DoAction();

    Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);
    Result := Self.Finish();
  end;
end;



end.