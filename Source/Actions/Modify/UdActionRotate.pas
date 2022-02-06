{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionRotate;

{$I UdDefs.INC}

interface

uses

  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdActionCoupleMod;


type  
  //*** UdActionRotate ***//
  TUdActionRotate = class(TUdActionCoupleMod)
  private
    FCopy: Boolean;

  protected
    function DoRotate(AAng: Float): Boolean;
    
    function UpdateEntities(): Boolean; override;
    function SetSecondPoint(APnt: TPoint2D): Boolean; override;

    function GetSecondPointPrompt: string; override;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    function Parse(const AValue: string): Boolean; override;
  end;  


implementation

uses
  SysUtils,
  UdMath, UdGeo2D, UdAcnConsts;

  
//==================================================================================================
{ TUdActionRotate }

class function TUdActionRotate.CommandName: string;
begin
  Result := 'rotate';
end;

constructor TUdActionRotate.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FCopy := False;
end;

destructor TUdActionRotate.Destroy;
begin
  //....
  inherited;
end;


function TUdActionRotate.GetSecondPointPrompt: string;
begin
  Result := sRotAngleOrCopy;
end;



function TUdActionRotate.DoRotate(AAng: Float): Boolean;
var
  I: Integer;
begin
  Result := False;
  
  if NotEqual(FP1, FP2) then
  begin
    if FCopy then
    begin
      for I := 0 to System.Length(FSelectedEntities) - 1 do
      begin
        FTaskEntities[I].BeginUpdate();
        try
          FTaskEntities[I].Assign(FSelectedEntities[I]);
          FTaskEntities[I].Rotate(FP1, AAng{UdGeo2D.GetAngle(FP1, FP2)});

          FTaskEntities[I].Finished := True;
          FTaskEntities[I].Visible := True;
        finally
          FTaskEntities[I].EndUpdate();
        end;
      end;
      Self.AddEntities(FTaskEntities);
      FTaskEntities := nil;
    end
    else begin
      for I := 0 to System.Length(FSelectedEntities) - 1 do
        FSelectedEntities[I].Rotate(FP1, AAng{UdGeo2D.GetAngle(FP1, FP2)});
      ClearTaskEntities();
    end;

    Result := True;
  end;
end;

function TUdActionRotate.Parse(const AValue: string): Boolean;
var
  LAngle: Float;
  LValue: string;
begin
  Result := False;

  if FStep = 2 then
  begin
    LValue := LowerCase(Trim(AValue));

    if (LValue = 'c') or (LValue = 'copy') then
    begin
      FCopy := True;
      Self.Prompt(sRotCopySelectedObjs, pkLog);
      Self.Prompt(FSetSecondPointPrompt, pkLog);
    end
    else if TryStrToFloat(AValue, LAngle) then
    begin
      if DoRotate(LAngle) then
      begin
        Self.Prompt(FSetSecondPointPrompt + ': ' + AngleToStr(LAngle), pkLog);
        Result := Self.Finish();
      end;
    end
    else
      Self.Prompt(sRequirePointOrKeyword, pkLog);
  end
  else
    Result := inherited Parse(AValue);
end;

function TUdActionRotate.UpdateEntities: Boolean;

  procedure _RotateTaskEntities();
  var
    I: Integer;
  begin
    for I := System.Length(FTaskEntities) - 1 downto 0 do
    begin
      FTaskEntities[I].BeginUpdate();
      try
        FTaskEntities[I].Assign(FSelectedEntities[I]);
        FTaskEntities[I].Rotate(FP1, UdGeo2D.GetAngle(FP1, FP2));
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
    _RotateTaskEntities();
  end
  else begin
    FRect.SetPoints(FRectPnts);
    FRect.Rotate(FP1, UdGeo2D.GetAngle(FP1, FP2));
    FRect.Visible := True;
  end;

  Result := True;
end;

function TUdActionRotate.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FP2 := APnt;

  if NotEqual(FP1, FP2) then
  begin
    if DoRotate(UdGeo2D.GetAngle(FP1, FP2)) then
    begin
      Self.Prompt(FSetSecondPointPrompt + ': ' + PointToStr(APnt), pkLog);
      Result := Self.Finish();
    end;
  end;
end;

end.