{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionBreak;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdPoint;


type
  //*** UdActionBreak ***//
  TUdActionBreak = class(TUdModifyAction)
  private
    FP1, FP2: TPoint2D;
    FSelEntity: TUdEntity;

    FIs1Pnt: Boolean;
    FPntObj1, FPntObj2: TUdPoint;

  protected
    function SelectEntity(APnt: TPoint2D): Boolean;
    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetSecondPoint(APnt: TPoint2D): Boolean;

    function BreakEntity(): Boolean;

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
{ TUdActionBreak }

class function TUdActionBreak.CommandName: string;
begin
  Result := 'break';
end;

constructor TUdActionBreak.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  N: Integer;
  LArg: string;
begin
  inherited;

  LArg := LowerCase(Trim(Args));

  N := Pos(' ', LArg);
  if N > 0 then Delete(LArg, N, System.Length(LArg));

  FIs1Pnt := (LArg = '1p') or (LArg = '1pt') or (LArg = '1pnt')or (LArg = '1point');

  Self.CanSnap := False;
  Self.CanOSnap := False;
  Self.CanOrtho := False;
  Self.CanPerpend := False;

  Self.RemoveAllSelected();


  FPntObj1 := TUdPoint.Create(FDocument, False);
  FPntObj1.States := [psXCross];
  FPntObj1.Finished := False;
  FPntObj1.Visible := False;
  FPntObj1.States := [psXCross];
  FPntObj1.DrawingUnits := False;

  FPntObj2 := TUdPoint.Create(FDocument, False);
  FPntObj2.States := [psXCross];
  FPntObj2.Finished := False;
  FPntObj2.Visible := False;
  FPntObj2.States := [psXCross];
  FPntObj2.DrawingUnits := False;

  FSelAction.Visible := False;

  Self.SetCursorStyle(csPick);
  Self.Prompt(sSelectObject, pkCmd);
end;

destructor TUdActionBreak.Destroy;
begin
  if Assigned(FSelEntity) then FSelEntity.Selected := False;
  if Assigned(FPntObj1) then FPntObj1.Free();
  if Assigned(FPntObj2) then FPntObj2.Free();

  inherited;
end;






//-----------------------------------------------------------------------------------

function TUdActionBreak.SelectEntity(APnt: TPoint2D): Boolean;
var
  LEntity: TUdEntity;
begin
  Result := False;
  if (FStep <> 0) then Exit;

  LEntity := Self.PickEntity(APnt);
  if (LEntity <> nil) then
  begin
    if (LEntity.TypeID > ID_Entity) and (LEntity.TypeID <= ID_SPLINE) then
    begin
      FSelEntity := LEntity;
      FStep := 1;

      FSelEntity.Selected := True;
      Self.AddSelectedEntity(FSelEntity);

      Self.SetCursorStyle(csDraw);
      Self.Prompt(sSelectObject, pkLog);

      if FIs1Pnt then
        Self.Prompt(sSpecifyBreakPoint2, pkCmd)
      else
        Self.Prompt(sSpecifyBreakPoint1, pkCmd);

      Self.CanSnap := True;
      Self.CanOSnap := True;

      Result := True;
    end
    else
      Self.Prompt(sCannotToBreak, pkLog);
  end;
end;

function TUdActionBreak.SetFirstPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 1) or not Assigned(FSelEntity) then Exit;

  FP1 := APnt;
  FPntObj1.XData := FP1;
  FPntObj1.Visible := True;

  Self.Prompt(sSpecifyBreakPoint1 + ': ' + PointToStr(APnt), pkLog);

  if FIs1Pnt then
  begin
    FP2 := APnt;
    BreakEntity();

    Self.Prompt(sSpecifyBreakPoint2 + ': @', pkLog);
    Result := Self.Finish();
  end
  else begin
    FStep := 2;

    Self.CanPolar := True;
    Self.Prompt(sSpecifyBreakPoint2, pkCmd);
    Result := True;
  end;
end;


function TUdActionBreak.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FP2 := APnt;
  FPntObj2.XData := FP2;
  FPntObj2.Visible := True;

  BreakEntity();

  Self.Prompt(sSpecifyBreakPoint2 + ': ' + PointToStr(APnt), pkLog);
  Result := Self.Finish();
end;


function TUdActionBreak.BreakEntity: Boolean;
var
  LEntities: TUdEntityArray;
begin
  Result := False;
  LEntities := nil;

  LEntities := FSelEntity.BreakAt(FP1, FP2);
  if System.Length(LEntities) > 0 then
  begin
    Self.AddEntities(LEntities);

    FSelEntity.Selected := False;
    Self.RemoveEntity(FSelEntity);

    FSelEntity := nil;

    Result := True;
  end;
end;



//-----------------------------------------------------------------------------------

procedure TUdActionBreak.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FPntObj1) and FPntObj1.Visible then FPntObj1.Draw(ACanvas);
  if Assigned(FPntObj2) and FPntObj2.Visible then FPntObj2.Draw(ACanvas);
end;


function TUdActionBreak.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  LValue := LowerCase(Trim(AValue));

//  if FIs1Pnt and (FStep = 1) and ((LValue = 'f') or (LValue = 'first')) then
//  begin
//    FIs1Pnt := False;
//  end
//  else
  if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      Self.SelectEntity(LPnt)
    else if FStep = 1 then
      Self.SetFirstPoint(LPnt)
    else if FStep = 2 then
     Self.SetSecondPoint(LPnt)
  end
  else
    Self.Prompt(sInvalidPoint, pkLog);

  Result := True;
end;

procedure TUdActionBreak.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionBreak.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SelectEntity(ACoordPnt)
          else if FStep = 1 then
            SetFirstPoint(ACoordPnt)
          else if FStep = 2 then
            SetSecondPoint(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
  end;
end;






end.