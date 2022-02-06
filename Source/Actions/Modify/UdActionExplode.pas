{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionExplode;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls, Forms,
  UdTypes, UdGTypes, UdEvents, UdObject, UdIntfs, UdEntity, UdAction, UdBaseActions,
  UdActionSelection;

type


  //*** TUdActionExplode ***//
  TUdActionExplode = class(TUdAction)
  private
    FSelAction: TUdActionSelection;

  protected
    function GetExplodeAbleEntities(): TUdEntityArray;
    function ApplyExplode(AEntities: TUdEntityArray): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;


    function CanPopMenu: Boolean; override;

  end;


implementation


uses
  SysUtils, UdLoopSearch,  UdUtils,
  UdLayout, UdMath, UdGeo2D, UdAcnConsts;



//=========================================================================================
{ TUdActionExplode }

class function TUdActionExplode.CommandName: string;
begin
  Result := 'explode';
end;

constructor TUdActionExplode.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  LEntities: TUdEntityArray;
begin
  inherited;

  LEntities := GetExplodeAbleEntities();

  if System.Length(LEntities) > 0 then
  begin
    Self.Prompt('', pkCmd);
    ApplyExplode(LEntities);
    Self.Aborted := True;
  end
  else begin
    FSelAction := TUdActionSelection.Create(FDocument, FLayout);
    Self.SetCursorStyle(csPick);
    Self.Prompt(sSelectObject, pkCmd);

    Self.CanSnap := False;
    Self.CanOSnap := False;
    Self.CanOrtho := False;
    Self.SetCursorStyle(csPick);
  end;
end;

destructor TUdActionExplode.Destroy;
begin
  if Assigned(FSelAction) then FSelAction.Free();
  FSelAction := nil;

  inherited;
end;




//------------------------------------------------------------------------------------

function TUdActionExplode.GetExplodeAbleEntities(): TUdEntityArray;
var
  I: Integer;
  LList: TList;
  LEntity: TUdEntity;
  LExplode: IUdExplode;
begin
  Result := nil;

  LList := Self.GetSelectedEntityList();
  if Assigned(LList) then
  begin
    for I := LList.Count - 1 downto 0 do
    begin
      LEntity := LList[I];
      if LEntity.GetInterface(IUdExplode, LExplode) then
      begin
        System.SetLength(Result, System.Length(Result) + 1);
        Result[High(Result)] := LEntity;
      end;
    end;
  end;
end;


function TUdActionExplode.ApplyExplode(AEntities: TUdEntityArray): Boolean;
var
  I, N: Integer;
  LEntity: TUdEntity;
  LExplode: IUdExplode;
  LExpEntities: TUdEntityArray;
begin
  N := 0;
  for I := 0 to System.Length(AEntities) - 1 do
  begin
    LEntity := AEntities[I];
    if Assigned(LEntity) and LEntity.GetInterface(IUdExplode, LExplode) then
    begin
      LExpEntities := TUdEntityArray(LExplode.Explode());
      if System.Length(LExpEntities) > 0 then
      begin
        Self.AddEntities(LExpEntities);
        Self.RemoveEntity(LEntity);
      end;

      Inc(N);
    end;
  end;

  Self.Prompt(IntToStr(N) + ' objects exploded', pkLog);

  Result := N > 0;
end;


procedure TUdActionExplode.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
  end;
end;


function TUdActionExplode.Parse(const AValue: string): Boolean;
begin
  Result := True;
  if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Parse(AValue);
end;




//------------------------------------------------------------------------------------


procedure TUdActionExplode.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FSelAction) and FSelAction.Visible then
    FSelAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionExplode.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LEntities: TUdEntityArray;
begin
  inherited;

  if FSelAction.Visible then
    FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin

        end
        else if (AButton = mbRight) then
        begin
          LEntities := GetExplodeAbleEntities();
          Self.ApplyExplode(LEntities);

          Self.Finish();
        end;
      end;
    mkMouseMove:
      begin
        //...
      end;
  end;
end;

function TUdActionExplode.CanPopMenu(): Boolean;
begin
  Result := False;
end;



end.