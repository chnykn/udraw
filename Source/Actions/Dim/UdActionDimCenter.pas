{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimCenter;

{$I UdDefs.INC}

interface

uses
  Classes, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject,
  UdEntity, UdAction, UdBaseActions, UdDimProps;

type
  //*** TUdActionDimCenter ***//
  TUdActionDimCenter = class(TUdDimAction)
  private

  protected
    function SelectArcOrCircle(APnt: TPoint2D): TArc2D;
    function MarkCenter(AArc: TArc2D): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;

    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;  

implementation


uses
  SysUtils,
  UdLine, UdArc, UdCircle, UdPolyline,
  UdGeo2D, UdUtils, UdAcnConsts;
  

//=========================================================================================
{ TUdActionDimCenter }

class function TUdActionDimCenter.CommandName: string;
begin
  Result := 'dimcenter';
end;

constructor TUdActionDimCenter.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  Self.CanSnap    := False;
  Self.CanOSnap   := False;
  Self.CanOrtho   := False;
  Self.CanPerpend := False;


  if Assigned(Self.DimStyle) and (Self.DimStyle.ArrowsProp.CenterMark = ckCenterNone) then
  begin
    Self.Prompt(sInvalidCenterKind, pkLog);
    Self.Aborted := True;
  end
  else begin
    Self.Prompt(sSelectArcOrCir, pkCmd);
    Self.SetCursorStyle(csPick);
  end;
end;

destructor TUdActionDimCenter.Destroy;
begin

  inherited;
end;



//---------------------------------------------------


function TUdActionDimCenter.SelectArcOrCircle(APnt: TPoint2D): TArc2D;
var
  I: Integer;
  E: Float;
  LSelObj: TUdEntity;
  LSegarcs: TSegarc2DArray;
begin
  Result := Arc2D(0, 0, -1, 0, 0);

  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) then
  begin
    Self.Prompt(sSelectArcOrCir, pkLog);
    Exit;
  end;

  if LSelObj.InheritsFrom(TUdArc) then
  begin
    Result := TUdArc(LSelObj).XData;
  end else

  if LSelObj.InheritsFrom(TUdCircle) then
  begin
    Result := Arc2D(TUdCircle(LSelObj).Center, TUdCircle(LSelObj).Radius, 0, 360);
  end else

  if LSelObj.InheritsFrom(TUdPolyline) and (TUdPolyline(LSelObj).SplineFlag = sfStandard) then
  begin
    E := DEFAULT_PICK_SIZE / Self.PixelPerValue();

    LSegarcs := TUdPolyline(LSelObj).XData;

    for I := 0 to System.Length(LSegarcs) - 1 do
    begin
      if LSegarcs[I].IsArc and
         UdGeo2D.IsPntOnArc(APnt, LSegarcs[I].Arc, E) then
      begin
        Result := LSegarcs[I].Arc;
        Break;
      end;
    end;
  end;

end;


function TUdActionDimCenter.MarkCenter(AArc: TArc2D): Boolean;
var
  I: Integer;
  LLineObj: TUdLine;
  LMarkSize: Float;
  LDimCenKind: TUdDimCenterKind;
begin
  Result := False;
  if AArc.R <= 0 then Exit;  //=======>>>>

  if Assigned(Self.DimStyle) then
  begin
    LMarkSize := Self.DimStyle.ArrowsProp.MarkSize;
    LDimCenKind := Self.DimStyle.ArrowsProp.CenterMark
  end
  else begin
    LMarkSize := 2.5;
    LDimCenKind := ckCenterMark;
  end;


  if LDimCenKind = ckCenterNone then Exit;  //=======>>>>


  LLineObj := TUdLine.Create(FDocument, False);
  LLineObj.StartPoint := ShiftPoint(AArc.Cen, 0, LMarkSize);
  LLineObj.EndPoint   := ShiftPoint(AArc.Cen, 180, LMarkSize);
  Self.AddEntity(LLineObj);

  LLineObj := TUdLine.Create(FDocument, False);
  LLineObj.StartPoint := ShiftPoint(AArc.Cen, 90, LMarkSize);
  LLineObj.EndPoint   := ShiftPoint(AArc.Cen, 270, LMarkSize);
  Self.AddEntity(LLineObj);

  if (LDimCenKind = ckCenterLine) and (AArc.R > 2 * LMarkSize) then
  begin
    for I := 0 to 3 do
    begin
      LLineObj := TUdLine.Create(FDocument, False);
      LLineObj.StartPoint := ShiftPoint(AArc.Cen, 90 * I, LMarkSize * 2);
      LLineObj.EndPoint   := ShiftPoint(AArc.Cen, 90 * I, AArc.R + LMarkSize);
      Self.AddEntity(LLineObj);
    end;
  end;
end;


//---------------------------------------------------

function TUdActionDimCenter.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
  LArc: TArc2D;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));
  if LValue = '' then
  begin
    Self.Finish();
    Exit;
  end;

  if ParseCoord(LValue, LPnt, LIsOpp) then
  begin
    LArc := Self.SelectArcOrCircle(LPnt);
    if LArc.R > 0 then
      Self.MarkCenter(LArc)
    else
      Self.Prompt(sNoObjFound, pkLog);
  end
  else
    Self.Prompt(sInvalidSelection, pkLog);
end;


procedure TUdActionDimCenter.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionDimCenter.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LArc: TArc2D;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          LArc := Self.SelectArcOrCircle(ACoordPnt);
          if LArc.R > 0 then
            Self.MarkCenter(LArc);
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