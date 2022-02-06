{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionMatchProp;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction,
  UdActionSelection;

type
  //*** TUdActionMatchProp ***//
  TUdActionMatchProp = class(TUdAction)
  private
    FSrcEntity: TUdEntity;
    FSelAction: TUdActionSelection;

  protected
    function PickSrcEntity(APnt: TPoint2D): Boolean;
    procedure MatchProperties(Sender: TObject; Entities: TUdEntityArray);
    
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    function Parse(const AValue: string): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;
  

implementation

uses
  SysUtils, UdLayout, UdUtils, UdAcnConsts;

  

//================================================================================================
{ TUdActionMatchProp }

class function TUdActionMatchProp.CommandName: string;
begin
  Result := 'matchprop';
end;


constructor TUdActionMatchProp.Create(ADocument, ALayout: TUdObject; Args: string);
var
  LLayout: TUdLayout;
begin
  inherited;

  FSelAction := TUdActionSelection.Create(FDocument, FLayout);
  FSelAction.Visible := False;
  FSelAction.OnSelected := MatchProperties;

  FSrcEntity := nil;

  Self.CanSnap    := False;
  Self.CanOSnap   := False;
  Self.CanOrtho   := False;
  Self.CanPerpend := False;

  LLayout := TUdLayout(Self.GetLayout());

  if Assigned(LLayout) then
  begin
    if LLayout.SelectedList.Count = 1 then
    begin
      FSrcEntity := LLayout.SelectedList[0];
      FStep := 1;

      FSelAction.Visible := True;
      Self.Prompt(sSelectDstObject, pkCmd);
    end
    else
      Self.Prompt(sSelectSrcObject, pkCmd);

    Self.RemoveAllSelected();
    Self.SetCursorStyle(csPick);
  end
  else
    Self.Aborted := True;
end;

destructor TUdActionMatchProp.Destroy;
begin
  if Assigned(FSrcEntity) then FSrcEntity.Selected := False;
  FSrcEntity := nil;
    
  if Assigned(FSelAction) then FSelAction.Free();
  FSelAction := nil;

  inherited;
end;



function TUdActionMatchProp.PickSrcEntity(APnt: TPoint2D): Boolean;
var
  LEntity: TUdEntity;
  LLayout: TUdLayout;
begin
  Result := False;
  if (FStep <> 0) then Exit; //=======>>>>

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=======>>>>


  LEntity := LLayout.PickEntity(APnt);
  if Assigned(LEntity) then
  begin
    FSrcEntity := LEntity;
    FSrcEntity.Selected := True;

    FSelAction.Visible := True;

    Self.SetCursorStyle(csPick);
    Self.Prompt(sSelectDstObject, pkCmd);
        
    FStep := 1;
    Result := True;
  end;
end;


procedure TUdActionMatchProp.MatchProperties(Sender: TObject; Entities: TUdEntityArray);
var
  I: Integer;
begin
  if (FStep <> 1) then Exit; //=======>>>>

  for I := 0 to Length(Entities) - 1 do
  begin
    if Entities[I] = FSrcEntity then Continue;

    Entities[I].Layer         := FSrcEntity.Layer;
    Entities[I].Color         := FSrcEntity.Color;
    Entities[I].LineType      := FSrcEntity.LineType;
    Entities[I].Lineweight    := FSrcEntity.Lineweight;
    Entities[I].LineTypeScale := FSrcEntity.LineTypeScale;
  end;

  Self.Prompt(sSelectDstObject, pkLog);
end;



//--------------------------------------------------------------------------

procedure TUdActionMatchProp.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if FVisible then
  begin
    if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
    if Assigned(FSrcEntity) then FSrcEntity.Draw(ACanvas);
  end;
end;



function TUdActionMatchProp.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := True;
  LValue := LowerCase(Trim(AValue));

  if LValue = '' then
  begin
    Self.Finish();
    Exit; //=====>>>>>
  end;

  if FStep = 0 then
  begin
    if ParseCoord(AValue, LPnt, LIsOpp) then
      Self.PickSrcEntity(LPnt)
    else
      Self.Prompt(sInvalidPoint, pkLog);
  end;
end;


procedure TUdActionMatchProp.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionMatchProp.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;
  
  if FSelAction.Visible then
    FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          case FStep of
            0: Self.PickSrcEntity(ACoordPnt);
            //1: Self.MatchProperties();
          end;
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin

      end;
  end;
end;



end.