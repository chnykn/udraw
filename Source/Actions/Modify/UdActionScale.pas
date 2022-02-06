{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionScale;

{$I UdDefs.INC}

interface

uses

  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdActionCoupleMod;


type  
  //*** UdActionScale ***//
  TUdActionScale = class(TUdActionCoupleMod)
  private
    FCopy: Boolean;
      
  protected
    function DoScale(AFactor: Float): Boolean;
    
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
{ TUdActionScale }

class function TUdActionScale.CommandName: string;
begin
  Result := 'scale';
end;

constructor TUdActionScale.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FCopy := False;
end;

destructor TUdActionScale.Destroy;
begin
  //....
  inherited;
end;


function TUdActionScale.GetSecondPointPrompt: string;
begin
  Result := sScaleFactorOrCopy;
end;


function TUdActionScale.DoScale(AFactor: Float): Boolean;
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
          FTaskEntities[I].Scale(FP1, AFactor);

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
        FSelectedEntities[I].Scale(FP1, AFactor);
      ClearTaskEntities();
    end;

    Result := True;
  end;
end;


function TUdActionScale.Parse(const AValue: string): Boolean;
var
  LScale: Float;
  LValue: string;  
begin
  Result := False;

  if FStep = 2 then
  begin
    if (LValue = 'c') or (LValue = 'copy') then
    begin
      FCopy := True;
      Self.Prompt(sScaleCopySelectedObjs, pkLog);
      Self.Prompt(FSetSecondPointPrompt, pkLog);
    end
    else if TryStrToFloat(AValue, LScale) and NotEqual(LScale, 0.0) then
    begin
      LScale := Abs(LScale);

      if DoScale(LScale) then
      begin
        Self.Prompt(FSetSecondPointPrompt + ': ' + RealToStr(LScale), pkLog);
        Result := Self.Finish();
      end;  
    end
    else
      Self.Prompt(sRequirePointOrKeyword, pkLog);    
  end
  else
    Result := inherited Parse(AValue);
end;

function TUdActionScale.UpdateEntities: Boolean;

  procedure _ScaleTaskEntities();
  var
    I: Integer;
  begin
    for I := System.Length(FTaskEntities) - 1 downto 0 do
    begin
      FTaskEntities[I].BeginUpdate();
      try
        FTaskEntities[I].Assign(FSelectedEntities[I]);
        FTaskEntities[I].Scale(FP1, UdGeo2D.Distance(FP2, FP1));
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
    _ScaleTaskEntities();
  end
  else begin
    FRect.SetPoints(FRectPnts);
    FRect.Scale(FP1, UdGeo2D.Distance(FP2, FP1));
    FRect.Visible := True;
  end;

  Result := True;
end;

function TUdActionScale.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FP2 := APnt;

  if NotEqual(FP1, FP2) then
  begin
    if DoScale(UdGeo2D.Distance(FP2, FP1)) then
    begin
      Self.Prompt(FSetSecondPointPrompt + ': ' + PointToStr(APnt), pkLog);
      Result := Self.Finish();
    end;
  end;
end;



end.