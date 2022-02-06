{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdThreadObject;

interface

uses
  Windows, Classes;


type
  TUdThreadObject = class(TPersistent)
  protected
    FLock: TRTLCriticalSection;
    FLockCount: Integer;
    FUpdateCount: Integer;
    FOnChange: TNotifyEvent;

  protected
    property LockCount: Integer read FLockCount;
    property UpdateCount: Integer read FUpdateCount;

  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Changed; virtual;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Lock;
    procedure Unlock;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;



implementation


var
  GCounterLock: TRTLCriticalSection;



//==================================================================================================
{ TUdThreadObject }

constructor TUdThreadObject.Create;
begin
  InitializeCriticalSection(FLock);
end;

destructor TUdThreadObject.Destroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TUdThreadObject.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TUdThreadObject.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then FOnChange(Self);
end;

procedure TUdThreadObject.EndUpdate;
begin
  Assert(FUpdateCount > 0, 'Unpaired TUdThreadObject.EndUpdate');
  Dec(FUpdateCount);
end;

procedure TUdThreadObject.Lock;
begin
  EnterCriticalSection(GCounterLock);
  Inc(FLockCount);
  LeaveCriticalSection(GCounterLock);
  EnterCriticalSection(FLock);
end;

procedure TUdThreadObject.Unlock;
begin
  LeaveCriticalSection(FLock);
  EnterCriticalSection(GCounterLock);
  Dec(FLockCount);
  LeaveCriticalSection(GCounterLock);
end;






initialization
  InitializeCriticalSection(GCounterLock);

finalization
  DeleteCriticalSection(GCounterLock);


end.