{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdTimer;


interface

uses
  Windows, Classes;

type
  TUdTimer = class(TObject)
  protected
    FId: UINT;
    FTag: Integer;
    FEnabled: Boolean;
    FInterval: Cardinal;
    FAutoDisable: Boolean;
    FOnTimer: TNotifyEvent;

  protected
    procedure Initialize(AInterval: Cardinal; AOnTimer: TNotifyEvent);
    
    procedure SetEnabled(AValue: Boolean);
    procedure SetInterval(AValue: Cardinal);
    procedure SetOnTimer(AValue: TNotifyEvent);

    function Start: Boolean;
    function Stop(Disable: Boolean): Boolean;

  public
    constructor Create();
    constructor CreateEx(AInterval: Cardinal; AOnTimer: TNotifyEvent);

    destructor Destroy; override;

  public
//    property ID: UINT read FId;
    property Tag: Integer read FTag write FTag;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Interval: Cardinal read FInterval write SetInterval default 1000;
    property AutoDisable: Boolean read FAutoDisable write FAutoDisable;

    property OnTimer: TNotifyEvent read FOnTimer write SetOnTimer;
  end;


function GetTimerCount: Cardinal;
function GetTimerActiveCount: Cardinal;


implementation                       

uses
  Messages;




//=================================================================================================


type
  TUdTimerHandler = class(TObject)
  private
    FRefCount: Cardinal;
    FActiveCount: Cardinal;
    FWindowHandle: HWND;
    procedure WndProc(var Msg: TMessage);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddTimer();
    procedure RemoveTimer();
  end;


constructor TUdTimerHandler.Create;
begin
  inherited Create;
  FWindowHandle := AllocateHWnd(WndProc);
end;


destructor TUdTimerHandler.Destroy();
begin
  DeallocateHWnd(FWindowHandle);
  inherited Destroy;
end;


procedure TUdTimerHandler.AddTimer();
begin
  Inc(FRefCount);
end;


procedure TUdTimerHandler.RemoveTimer();
begin
  if FRefCount > 0 then
    Dec(FRefCount);
end;


procedure TUdTimerHandler.WndProc(var Msg: TMessage);
var
  LTimer: TUdTimer;
begin
  if Msg.Msg = WM_TIMER then
  begin
{$WARNINGS OFF}
    LTimer := TUdTimer(Msg.wParam);
{$WARNINGS ON}
    if LTimer.FAutoDisable then
      LTimer.Stop(True);
    // Call OnTimer event method if assigned
    if Assigned(LTimer.FOnTimer) then
      LTimer.FOnTimer(LTimer);
  end
  else
    Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
end;





//=================================================================================================


var
  GTimerHandler: TUdTimerHandler = nil;


function GetTimerCount: Cardinal;
begin
  if Assigned(GTimerHandler) then
    Result := GTimerHandler.FRefCount
  else
    Result := 0;
end;


function GetTimerActiveCount: Cardinal;
begin
  if Assigned(GTimerHandler) then
    Result := GTimerHandler.FActiveCount
  else
    Result := 0;
end;



//----------------------------------------------------------

procedure AddTimer();
begin
  if not Assigned(GTimerHandler) then
    GTimerHandler := TUdTimerHandler.Create;
  GTimerHandler.AddTimer();
end;


procedure RemoveTimer();
begin
  if Assigned(GTimerHandler) then
  begin
    GTimerHandler.RemoveTimer;
    if GTimerHandler.FRefCount = 0 then
    begin
      GTimerHandler.Free;
      GTimerHandler := nil;
    end;
  end;
end;







//=================================================================================================

constructor TUdTimer.Create;
begin
  inherited Create;
  FTag := 0;
  Initialize(1000, nil);
end;


constructor TUdTimer.CreateEx(AInterval: Cardinal; AOnTimer: TNotifyEvent);
begin
  inherited Create;
  Initialize(AInterval, AOnTimer);
end;


destructor TUdTimer.Destroy;
begin
  if FEnabled then
    Stop(True);
  RemoveTimer(); // Container management
  inherited Destroy;
end;



procedure TUdTimer.Initialize(AInterval: Cardinal; AOnTimer: TNotifyEvent);
begin
{$WARNINGS OFF}
  FId := UINT(Self);         // Use Self as id in call to SetTimer and callback method
{$WARNINGS ON}
  FAutoDisable := False;
  FEnabled := False;
  FInterval := AInterval;
  Self.SetOnTimer(AOnTimer);
  AddTimer;                  // Container management
end;


procedure TUdTimer.SetEnabled(AValue: Boolean);
begin
  if AValue then
    Self.Start()
  else
    Self.Stop(True);
end;

procedure TUdTimer.SetInterval(AValue: Cardinal);
begin
  if AValue <> FInterval then
  begin
    FInterval := AValue;
    if FEnabled then
    begin
      if FInterval <> 0 then
        Self.Start()
      else
        Self.Stop(False);
    end;
  end;
end;


procedure TUdTimer.SetOnTimer(AValue: TNotifyEvent);
begin
  FOnTimer := AValue;
  if (not Assigned(AValue)) and (FEnabled) then
    Self.Stop(False);
end;


function TUdTimer.Start: Boolean;
begin
  if FInterval = 0 then
  begin
    Result := False;
    Exit;
  end;

  if FEnabled then
    Stop(True);

  Result := (SetTimer(GTimerHandler.FWindowHandle, FId, FInterval, nil) <> 0);
  if Result then
  begin
    FEnabled := True;
    Inc(GTimerHandler.FActiveCount);
  end
end;


function TUdTimer.Stop(Disable: Boolean): Boolean;
begin
  if Disable then
    FEnabled := False;
  Result := KillTimer(GTimerHandler.FWindowHandle, FId);
  if Result and (GTimerHandler.FActiveCount > 0) then
    Dec(GTimerHandler.FActiveCount);
end;



//---------------------------------------------------------------------------------------------------

initialization

finalization
  if Assigned(GTimerHandler) then
  begin
    GTimerHandler.Free;
    GTimerHandler := nil;
  end;

end.