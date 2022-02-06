{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionTrim;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions;


type  
  //*** UdActionTrim ***//
  TUdActionTrim = class(TUdModifyAction)
  private
    FSelectedEntities: TUdEntityArray;

  protected
    function SetSelectedEntities(): Boolean;
    function TrimEntity(APnt: TPoint2D): Boolean;
    
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
{ TUdActionTrim }

class function TUdActionTrim.CommandName: string;
begin
  Result := 'trim';
end;

constructor TUdActionTrim.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FSelectedEntities := nil;

  if SetSelectedEntities() then
  begin
    FSelAction.Visible := False;

    FStep := 1;
    Self.Prompt(sSelectToTrim, pkCmd);
  end
  else begin
    Self.Prompt(sSelectObject, pkCmd);
  end;
end;

destructor TUdActionTrim.Destroy;
var
  I: Integer;
begin
  for I := System.Length(FSelectedEntities) - 1 downto 0 do TUdEntity(FSelectedEntities[I]).Free;
  FSelectedEntities := nil;
    
  inherited;
end;



procedure TUdActionTrim.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

end;



//------------------------------------------------------------------------

function TUdActionTrim.SetSelectedEntities: Boolean;
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
      FSelectedEntities[High(FSelectedEntities)] := TUdEntity(LList[I]).Clone;
    end;
  end;

  Result := System.Length(FSelectedEntities) > 0;
end;

function TUdActionTrim.TrimEntity(APnt: TPoint2D): Boolean;
var
  LEntity: TUdEntity;
  LEntities: TUdEntityArray;
begin
  Result := False;


  LEntity := Self.PickEntity(APnt);
  if not Assigned(LEntity) then Exit;

  LEntities := LEntity.Trim(FSelectedEntities, APnt);
  if System.Length(LEntities) > 0 then
  begin
    Self.AddEntities(LEntities);
    Self.RemoveEntity(LEntity);

    Self.Invalidate();
    Result := True;
  end;
  
  if not Result then
    Self.Prompt(sCannotToTrim, pkLog);
end;




//------------------------------------------------------------------------

function TUdActionTrim.Parse(const AValue: string): Boolean;
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
        FSelAction.Visible := False;

        FStep := 1;
        Self.Prompt(sSelectToTrim, pkCmd);
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
      if FStep = 1 then TrimEntity(LPnt);
    end
    else begin
      if FStep = 0 then
        {...}
      else
        Self.Prompt(sSelectToTrim, pkCmd);
    end;

  end;
  Result := True;
end;



procedure TUdActionTrim.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionTrim.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 1 then TrimEntity(ACoordPnt);
        end
        else if (AButton = mbRight) then
        begin
          if FStep = 0 then
          begin
            FSelAction.Visible := False;
            
            if SetSelectedEntities() then
            begin
              FStep := 1;
              Self.Prompt(sSelectToTrim, pkCmd);
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