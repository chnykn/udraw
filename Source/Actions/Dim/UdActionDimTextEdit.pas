{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimTextEdit;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdDimension, UdActionDimTextAlign;

type
  //*** TUdActionDimTextEdit ***//
  TUdActionDimTextEdit = class(TUdDimAction)
  private
    FDimObj: TUdEntity;
    FOgnObj: TUdEntity;

    FKind: TUdDimTextAlignKind;
    FAlignAction: TUdActionDimTextAlign;

  protected
    function SelectDimObj(APnt: TPoint2D): Boolean;
    function SetTextPoint(APnt: TPoint2D): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;

  end;  

implementation


uses
  SysUtils,

  UdUtils, UdAcnConsts;
  
type
  TFDimension = class(TUdDimension);
  


//=================================================================================================
{ TUdActionDimTextEdit }

class function TUdActionDimTextEdit.CommandName: string;
begin
  Result := 'dimedit';
end;

constructor TUdActionDimTextEdit.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  N: Integer;
  LArg: string;
begin
  inherited;

  LArg := Trim(Args);

  N := Pos(' ', LArg);
  if N > 0 then Delete(LArg, N, System.Length(LArg));

  LArg := Trim(LArg);
  FKind := GetDimTextAlignKind(LArg);

  FOgnObj := nil;
  FDimObj := nil;
  FAlignAction := nil;

  Self.CanSnap := False;
  Self.CanOSnap := False;
  Self.CanOrtho := False;
  Self.CanPerpend := False;

  Self.Prompt(sSelectDimObject, pkCmd);
  Self.SetCursorStyle(csPick);
end;

destructor TUdActionDimTextEdit.Destroy;
begin
  if Assigned(FOgnObj) then FOgnObj.Free;
  if Assigned(FDimObj) then FDimObj.Selected := False;;

  if Assigned(FAlignAction) then FAlignAction.Free;

  inherited;
end;


//---------------------------------------------------

procedure TUdActionDimTextEdit.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FAlignAction) and FAlignAction.Visible then FAlignAction.Paint(Sender, ACanvas);
  end;
end;


function TUdActionDimTextEdit.SelectDimObj(APnt: TPoint2D): Boolean;
var
  LStr: string;
  LSelObj: TUdEntity;
  LEntities: TUdEntityArray;
begin
  Result := False;
  if FStep <> 0 then Exit;

  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) or not LSelObj.InheritsFrom(TUdDimension) then Exit; //========>>>>>
  
  FDimObj := LSelObj;
  FOgnObj := FDimObj.Clone();

  if FKind = takNone then
  begin
    Self.Prompt(sEditDimTextEdit, pkCmd);
    
//    Self.CanSnap := True;
//    Self.CanOSnap := True;
    Self.SetCursorStyle(csDraw);
    FStep := 1;
  end
  else begin

    case FKind of
      takHome  : LStr := '_h';
      takAngle : LStr := '_a';
      takLeft  : LStr := '_l';
      takCenter: LStr := '_c';
      takRight : LStr := '_r';
    end;

    Self.Prompt(sEditDimTextEdit + ':' + LStr, pkLog);
    
    System.SetLength(LEntities, 1);
    LEntities[0] := FDimObj;

    if FKind = takAngle then
      FAlignAction := TUdActionDimTextAlign.CreateByEntities(FDocument, LEntities, FKind)
    else begin
      TUdActionDimTextAlign.SetEntitesTextAlign(Self.DimStyle, LEntities, FKind);
      Self.Finish();
    end;
  end;

  Result := True;
end;

function TUdActionDimTextEdit.SetTextPoint(APnt: TPoint2D): Boolean;
begin
  if Assigned(FDimObj) then
    TFDimension(FDimObj).SetTextPoint(APnt);
  Result := Self.Finish();
end;



//---------------------------------------------------


function TUdActionDimTextEdit.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
  LKind: TUdDimTextAlignKind;
  LEntities: TUdEntityArray;
begin
  if Assigned(FAlignAction) then
  begin
    Result := FAlignAction.Parse(AValue);
    Exit; //========>>>>>
  end;

  LValue := LowerCase(Trim(AValue));
  if LValue = '' then
  begin
    if Assigned(FDimObj) and Assigned(FOgnObj) then
      FDimObj.Assign(FOgnObj);
    Result := Self.Finish();
    Exit; //========>>>>>
  end;

  Result := False;
  
  if FStep = 0 then
  begin
    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      Result := SelectDimObj(LPnt);
      if not Result then
        Self.Prompt(sNoDimObjectSelected, pkLog);
    end
    else
      Self.Prompt(sInvalidPoint, pkLog);
  end
  else begin
    LKind := GetDimTextAlignKind(LValue);

    if LKind = takNone then
    begin
      if ParseCoord(LValue, LPnt, LIsOpp) then
        Result := SetTextPoint(LPnt)
      else
        Self.Prompt(sRequirePointOrKeyword, pkLog);
    end
    else begin
      if Assigned(FDimObj) then
      begin
        FKind := LKind;
        if Assigned(FOgnObj) then FDimObj.Assign(FOgnObj);
        
        System.SetLength(LEntities, 1);
        LEntities[0] := FDimObj;

        Self.Prompt(sEditDimTextEdit + ':' + AValue, pkLog);

        if FKind = takAngle then
          FAlignAction := TUdActionDimTextAlign.CreateByEntities(FDocument, LEntities, FKind)
        else begin
          TUdActionDimTextAlign.SetEntitesTextAlign(Self.DimStyle, LEntities, FKind);
          Result := Self.Finish();
        end;
      end
      else
        Result := Self.Finish();
    end;
  end;
end;


procedure TUdActionDimTextEdit.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FAlignAction) and FAlignAction.Visible then FAlignAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionDimTextEdit.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  if Assigned(FAlignAction) and FAlignAction.Visible then
  begin
    FAlignAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
  end
  else begin
    case AKind of
      mkMouseDown:
        begin
          if (AButton = mbLeft) then
          begin
            if FStep = 0 then
              Self.SelectDimObj(ACoordPnt)
            else
              Self.SetTextPoint(ACoordPnt);
          end
          else if (AButton = mbRight) then
          begin
            Self.Finish();
          end;
        end;
      mkMouseMove:
        begin
          if Assigned(FDimObj) and (FStep = 1) then
            TFDimension(FDimObj).SetTextPoint(ACoordPnt);
        end;
    end;
  end;
end;





end.