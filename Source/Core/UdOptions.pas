{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdOptions;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdConsts, UdObject,
  UdOptionDisplay, UdOptionSelection, UdOptionGrips, UdOptionOSnap;

type
  //*** TUdOptions ***//
  TUdOptions = class(TUdObject)
  private
    FDisplay   : TUdOptionDisplay;
    FSelection : TUdOptionSelection;
    FGrips     : TUdOptionGrips;
    FOSnap     : TUdOptionOSnap;

  protected
    function GetTypeID(): Integer; override;

  public  
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); override;
    destructor Destroy; override;

    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;
        
  published
    property Display   : TUdOptionDisplay    read FDisplay    write FDisplay  ;
    property Selection : TUdOptionSelection  read FSelection  write FSelection;
    property Grips     : TUdOptionGrips      read FGrips      write FGrips    ;
    property OSnap     : TUdOptionOSnap      read FOSnap      write FOSnap    ;
  end;



implementation







//==================================================================================================
{ TUdOptions }

constructor TUdOptions.Create(ADocument: TUdObject; AIsDocRegister: Boolean = True);
begin
  inherited;

  FDisplay   := TUdOptionDisplay.Create(ADocument);
  FSelection := TUdOptionSelection.Create(ADocument);
  FGrips     := TUdOptionGrips.Create(ADocument);
  FOSnap     := TUdOptionOSnap.Create(ADocument);
end;

destructor TUdOptions.Destroy;
begin
  if Assigned(FDisplay) then FDisplay.Free;
  FDisplay := nil;

  if Assigned(FSelection) then FSelection.Free;
  FSelection := nil;

  if Assigned(FGrips) then FGrips.Free;
  FGrips := nil;

  if Assigned(FOSnap) then FOSnap.Free;
  FOSnap := nil;

  inherited;
end;


function TUdOptions.GetTypeID: Integer;
begin
  Result := ID_OPTIONS;
end;

procedure TUdOptions.LoadFromStream(AStream: TStream);
begin
  inherited;
//  {$MESSAGE 'ToDo: TUdOptions.LoadFromStream'}
end;

procedure TUdOptions.SaveToStream(AStream: TStream);
begin
  inherited;
//  {$MESSAGE 'ToDo: TUdOptions.SaveToStream'}
end;

end.