{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionExtend;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions;


type  
  //*** UdActionExtend ***//
  TUdActionExtend = class(TUdModifyAction)
  private
    FSelectedEntities: TUdEntityArray;

  protected
    function SetSelectedEntities(): Boolean;
    function ExtendEntity(APnt: TPoint2D): Boolean;

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
  SysUtils,
  UdUtils, UdAcnConsts;

  
//==================================================================================================
{ TUdActionExtend }

class function TUdActionExtend.CommandName: string;
begin
  Result := 'extend';
end;

constructor TUdActionExtend.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FSelectedEntities := nil;
  
  if SetSelectedEntities() then
  begin
    FStep := 1;
    Self.Prompt(sSelectToExtend, pkCmd);
  end
  else begin
    Self.Prompt(sSelectObject, pkCmd);
  end;
end;

destructor TUdActionExtend.Destroy;
begin
//....
  inherited;
end;



procedure TUdActionExtend.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

end;



function TUdActionExtend.SetSelectedEntities: Boolean;
var
  I: Integer;
  LList: TList;
  LEntity: TUdEntity;
begin
  Result := False;

  LList := Self.GetSelectedEntityList();
  if not Assigned(LList) then Exit;
  

  FSelectedEntities := nil;
  for I := 0 to LList.Count - 1 do
  begin
    LEntity := TUdEntity(LList[I]);

    if Assigned(LEntity) and (LEntity.TypeID > ID_Entity) and (LEntity.TypeID <= ID_SPLINE) then
    begin
      System.SetLength(FSelectedEntities, System.Length(FSelectedEntities) + 1);
      FSelectedEntities[High(FSelectedEntities)] := TUdEntity(LList[I]);
    end;
  end;

  Result := System.Length(FSelectedEntities) > 0;
end;


function TUdActionExtend.ExtendEntity(APnt: TPoint2D): Boolean;
var
  LEntity: TUdEntity;
begin
  Result := False;

  LEntity := Self.PickEntity(APnt);
  if not Assigned(LEntity) then Exit;

  Result := LEntity.Extend(FSelectedEntities, APnt);
  
  if not Result then
    Self.Prompt(sCannotToExtend, pkLog);
end;




//---------------------------------------------------------------------------------------------

function TUdActionExtend.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  if Trim(AValue) = '' then
  begin
    if (FStep = 0) then
    begin
      if SetSelectedEntities() then
      begin
        FStep := 1;
        Self.Prompt(sSelectToExtend, pkCmd);
      end
      else
        Self.Finish();
    end
    else if (FStep = 1) then
      Self.Prompt(sRequirePoint, pkLog);
  end
  else begin

    if ParseCoord(AValue, LPnt, LIsOpp) then
    begin
      if FStep = 1 then ExtendEntity(LPnt);
    end
    else begin
      if FStep = 0 then
        {...}
      else
        Self.Prompt(sSelectToExtend, pkCmd);
    end;

  end;
  Result := True;
end;



procedure TUdActionExtend.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionExtend.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 1 then ExtendEntity(ACoordPnt);
        end
        else if (AButton = mbRight) then
        begin
          if FStep = 0 then
          begin
            FSelAction.Visible := False;
            
            if SetSelectedEntities() then
            begin
              FStep := 1;
              Self.Prompt(sSelectToExtend, pkCmd);
            end
            else
              Self.Finish();
          end
          else
            Self.Finish();
        end;
      end;
  end;
end;




end.