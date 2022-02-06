{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionCoupleMod;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdPolyline;

type
  //*** TUdActionCoupleMod ***//

  TUdActionCoupleMod = class(TUdModifyAction)
  protected
    FP1, FP2: TPoint2D;

    FLine: TUdLine;
    FRect: TUdPolyline;

    FRectPnts: TPoint2DArray;

    FTaskEntities: TUdEntityArray;
    FSelectedEntities: TUdEntityArray;

    FSetFirstPointPrompt: string;
    FSetSecondPointPrompt: string;

    FPaintBlocking: Boolean;

  protected
    function NeedSketching(): Boolean;

    function ClearTaskEntities(): Boolean;
    function PopulateTaskEntities(): Boolean;

    function SetTaskEntities(): Boolean;
    function UpdateEntities(): Boolean;  virtual;

    function SetFirstPoint(APnt: TPoint2D): Boolean; virtual;
    function SetSecondPoint(APnt: TPoint2D): Boolean; virtual;

    function GetFirstPointPrompt: string; virtual;
    function GetSecondPointPrompt: string; virtual;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function Parse(const AValue: string): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;


  end;

implementation


uses
  SysUtils,
  UdLayout, UdGeo2D, UdUtils, UdAcnConsts;

const
  MAX_DYNC_SEL_COUNT = 512; // -1;


//=========================================================================================
{ TUdActionCoupleMod }

constructor TUdActionCoupleMod.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  LLayout: TUdLayout;
begin
  inherited;

  FSetFirstPointPrompt := GetFirstPointPrompt();//sBasePoint;
  FSetSecondPointPrompt := GetSecondPointPrompt();//sSecondPoint;


  LLayout := TUdLayout(Self.GetLayout());

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FRect := TUdPolyline.Create(FDocument, False);
  FRect.Finished := False;
  FRect.Visible := False;

  FTaskEntities := nil;
  FSelectedEntities := nil;

  if LLayout.SelectedList.Count > 0 then
    SetTaskEntities()
  else
  begin
    Self.Prompt(sSelectObject, pkCmd);
  end;

  FPaintBlocking := False;
end;

destructor TUdActionCoupleMod.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FRect) then FRect.Free();
  ClearTaskEntities();
  inherited;
end;


function TUdActionCoupleMod.GetFirstPointPrompt: string;
begin
  Result := sBasePoint;
end;

function TUdActionCoupleMod.GetSecondPointPrompt: string;
begin
  Result := sSecondPoint;
end;


function TUdActionCoupleMod.ClearTaskEntities(): Boolean;
var
  I: Integer;
begin
  if Assigned(FTaskEntities) then
    for I := System.Length(FTaskEntities) - 1 downto 0 do
      FTaskEntities[I].Free();
  FTaskEntities := nil;
  Result := True;
end;


function TUdActionCoupleMod.NeedSketching(): Boolean;
begin
{$WARNINGS OFF}
  if MAX_DYNC_SEL_COUNT <= 0 then
    Result := False
  else
    Result := (System.Length(FTaskEntities) > MAX_DYNC_SEL_COUNT);
{$WARNINGS ON}
end;

procedure TUdActionCoupleMod.Paint(Sender: TObject; ACanvas: TCanvas);
var
  I: Integer;
  LLayout: TUdLayout;
begin
  inherited;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit;

  if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);

  if not NeedSketching() then
  begin
    if System.Length(FTaskEntities) > 0 then
    begin
      for I := High(FTaskEntities) downto Low(FTaskEntities) do
        if Assigned(FTaskEntities[I]) and FTaskEntities[I].Visible then
          FTaskEntities[I].Draw(ACanvas);
    end;
  end
  else begin
    if Assigned(FRect) and FRect.Visible then FRect.Draw(ACanvas);
  end;
end;



//------------------------------------------------------------

function TUdActionCoupleMod.PopulateTaskEntities(): Boolean;
var
  I: Integer;
  LEntity, NEntity: TUdEntity;
begin
  FSelectedEntities := Self.GetSelectedEntities();
  System.SetLength(FTaskEntities, System.Length(FSelectedEntities));

  for I := 0 to System.Length(FSelectedEntities) - 1 do
  begin
    LEntity := FSelectedEntities[I];

    NEntity := LEntity.Clone();
    NEntity.Finished := False;
    NEntity.Visible := False;

    FTaskEntities[I] := NEntity;
  end;

  Result := System.Length(FSelectedEntities) > 0;
end;

function TUdActionCoupleMod.SetTaskEntities(): Boolean;
var
  LRect: TRect2D;
begin
  Result := False;
  if FStep <> 0 then Exit;

  if not PopulateTaskEntities() then Exit;

  LRect := UdUtils.GetEntitiesBound(FSelectedEntities);
  FRectPnts := UdGeo2D.Polygon2D(LRect);

  Self.CanOSnap := True;
  Self.FStep := 1;

  FSelAction.Visible := False;

  Self.SetCursorStyle(csDraw);
  Self.Prompt(sSelectObject + ':' + IntToStr(System.Length(FSelectedEntities)) + ' found', pkLog);

  if FSetFirstPointPrompt <> '' then
    Self.Prompt(FSetFirstPointPrompt, pkCmd);

  Self.CanPolar := True;

  Result := True;
end;




//----------------------------------------------------------------------------------------

function TUdActionCoupleMod.UpdateEntities: Boolean;
begin
  Result := False;
end;


function TUdActionCoupleMod.SetFirstPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FStep := 2;
  FP1 := APnt;
  FP2 := APnt;

  Self.CanOrtho := True;
  Self.SetPrevPoint(APnt);

  if FSetFirstPointPrompt <> '' then
    Self.Prompt(FSetFirstPointPrompt + ': ' + PointToStr(APnt), pkLog);

  if FSetSecondPointPrompt <> '' then
    Self.Prompt(FSetSecondPointPrompt, pkCmd);

  Result := True;
end;


function TUdActionCoupleMod.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
end;




function TUdActionCoupleMod.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  if Trim(AValue) = '' then
  begin
    if FStep = 0 then
      SetTaskEntities()
    else if (FStep = 1) or (FStep = 2) then
      Self.Prompt(sRequirePoint, pkLog);
  end
  else begin
    if (FStep = 1) or (FStep = 2) then
    begin
      if IsNum(AValue) and (FStep = 2) then
      begin
        LPnt := ShiftPoint(FP1, GetAngle(FP1, FP2), StrToFloat(AValue));
        SetSecondPoint(LPnt);
      end else
      if ParseCoord(AValue, LPnt, LIsOpp) then
      begin
        if FStep = 1 then
          SetFirstPoint(LPnt)
        else if FStep = 2 then
        begin
          if LIsOpp then
          begin
            LPnt.X := FP1.X + LPnt.X;
            LPnt.Y := FP1.Y + LPnt.Y;
          end;
          SetSecondPoint(LPnt);
        end;
      end
      else
      begin
        Self.Prompt(sInvalidPoint, pkLog);
      end;
    end;
  end;
  Result := True;
end;



procedure TUdActionCoupleMod.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionCoupleMod.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 1 then
            SetFirstPoint(ACoordPnt)
          else if FStep = 2 then
            SetSecondPoint(ACoordPnt);
        end
        else if (AButton = mbRight) then
        begin
          if FStep = 0 then
            SetTaskEntities()
          else
            Self.Finish();
        end;
      end;
    mkMouseMove:
      begin
        FP2 := ACoordPnt;
        if FStep = 2 then UpdateEntities();
      end;
  end;
end;






end.