{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionHatch;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls, Forms,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdActionSelection, UdActionHatchFrm;

type


  //*** TUdActionHatch ***//
  TUdActionHatch = class(TUdAction)
  private
    FHatchForm: TUdActionHatchForm;
    FSelAction: TUdActionSelection;

    FHatchApply: TUdHatchApply;
    FPickedLoops: TSegarc2DArrays;
    FPickedEntities: TList;

  protected
    function IsAnyLoopValid(): Boolean;
    function AddPickLoops(APnt: TPoint2D): Boolean;

    function ApplyPickedPntsHatch(): Boolean;
    function ApplySelectedObjsHatch(): Boolean;

    procedure IsValidHatchEntity(Sender: TObject; Entity: TUdEntity; var Allow: Boolean);

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
  UdLayout, UdMath, UdGeo2D, UdAcnConsts, UdHatch,
  UdLine, UdArc, UdCircle, UdRect, UdEllipse, UdPolyline, UdSpline;



//=========================================================================================
{ TUdActionHatch }


class function TUdActionHatch.CommandName: string;
begin
  Result := 'hatch';
end;

constructor TUdActionHatch.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  I: Integer;
  LEntity: TUdEntity;
  LList: TList;
begin
  inherited;

  LList := Self.GetSelectedEntityList();
  if Assigned(LList) then
  begin
    for I := LList.Count - 1 downto 0 do
    begin
      LEntity := LList[I];
      if not (LEntity.InheritsFrom(TUdLine) or LEntity.InheritsFrom(TUdArc) or LEntity.InheritsFrom(TUdCircle) or
              LEntity.InheritsFrom(TUdRect) or LEntity.InheritsFrom(TUdEllipse) or LEntity.InheritsFrom(TUdPolyline) ) then
      begin
        Self.RemoveSelectedEntity(LEntity);
      end;
    end;
  end;

  FPickedLoops := nil;
  FPickedEntities := TList.Create;

  FSelAction := TUdActionSelection.Create(FDocument, FLayout);
  FSelAction.OnFilter := IsValidHatchEntity;
  FSelAction.Visible := False;

  FHatchForm := TUdActionHatchForm.Create(nil);
  FHatchForm.Document := FDocument;
  FHatchForm.btnOK.Enabled := IsAnyLoopValid();

  FHatchForm.ShowModal();

  if FHatchForm.ApplyResult in [haNone, haCancel] then
  begin
    Self.Aborted := True;
  end
  else if FHatchForm.ApplyResult = haOk then
  begin
    ApplySelectedObjsHatch();
    Self.Aborted := True;
  end
  else begin
    FHatchApply := FHatchForm.ApplyResult;
    FSelAction.Visible := FHatchApply = haSelObjs;
    if FHatchApply = haPickPnts then Self.RemoveAllSelected();

    case FHatchApply of
      haPickPnts: Self.Prompt(sPickInterPnt, pkCmd);
      haSelObjs : Self.Prompt(sSelectObject, pkCmd);
    end;

    Self.CanSnap := False;
    Self.CanOSnap := False;
    Self.CanOrtho := False;

    case FHatchApply of
      haPickPnts: Self.SetCursorStyle(csDraw);
      haSelObjs : Self.SetCursorStyle(csPick);
    end;

  end;
end;

destructor TUdActionHatch.Destroy;
begin
  FPickedLoops := nil;

  UdUtils.ClearObjectList(FPickedEntities);
  FPickedEntities.Free;
  FPickedEntities := nil;


  if Assigned(FSelAction) then FSelAction.Free();
  FSelAction := nil;

  if Assigned(FHatchForm) then FHatchForm.Free();
  FHatchForm := nil;

  inherited;
end;




//------------------------------------------------------------------------------------

function TUdActionHatch.IsAnyLoopValid: Boolean;
begin
  Result := True;

  case FHatchApply of
    haSelObjs : Result := TUdLayout(Layout).SelectedList.Count > 0;
    haPickPnts: Result := System.Length(FPickedLoops) > 0;
  end;
end;







type
  TUdDisEntity = record
    Dis: Float;
    Entity: TUdEntity;
  end;
  PUdDisEntity = ^TUdDisEntity;


function FSortDisEntity(Item1, Item2: Pointer): Integer;
begin
  Result := Trunc((PUdDisEntity(Item1)^.Dis - PUdDisEntity(Item2)^.Dis) * 100);
end;

function TUdActionHatch.AddPickLoops(APnt: TPoint2D): Boolean;

  function _AddLoop(ASegarcs: TSegarc2DArray): Boolean;
  var
    I: Integer;
    LEntity: TUdPolyline;
  begin
    Result := True;

    for I := 0 to System.Length(FPickedLoops) - 1 do
    begin
      if IsEqual(FPickedLoops[I], ASegarcs) then
      begin
        Result := False;
        Break;
      end;
    end;

    if Result then
    begin
      System.SetLength(FPickedLoops, System.Length(FPickedLoops) + 1);
      FPickedLoops[High(FPickedLoops)] := ASegarcs;

      LEntity := TUdPolyline.Create(FDocument, False);
      LEntity.Finished := False;

      LEntity.PenStyle := psDot;
      LEntity.UsePenStyle := True;

      LEntity.XData := ASegarcs;
      LEntity.Selected := True;

      FPickedEntities.Add(LEntity);
    end;
  end;

  function _GetDistance(APnt: TPoint2D; AEntity: TUdEntity): Float;
  begin
    Result := -1;

    if AEntity.InheritsFrom(TUdLine) then
      Result := UdGeo2D.DistanceToSegment(APnt, TUdLine(AEntity).XData)  else
    if AEntity.InheritsFrom(TUdArc) then
      Result := UdGeo2D.DistanceToArc(APnt, TUdArc(AEntity).XData)  else
    if AEntity.InheritsFrom(TUdCircle) then
      Result := UdGeo2D.DistanceToCircle(APnt, TUdCircle(AEntity).XData)  else
    if AEntity.InheritsFrom(TUdRect) then
      Result := UdGeo2D.DistanceToSegarcs(APnt, TUdRect(AEntity).XData)  else
    if AEntity.InheritsFrom(TUdEllipse) then
      Result := UdGeo2D.DistanceToEllipse(APnt, TUdEllipse(AEntity).XData)  else
    if AEntity.InheritsFrom(TUdPolyline) then
      Result := UdGeo2D.DistanceToSegarcs(APnt, TUdPolyline(AEntity).XData) else
    if AEntity.InheritsFrom(TUdSpline)  then
      Result := UdGeo2D.DistanceToPolygon(APnt, TUdSpline(AEntity).SamplePoints);
  end;


const
  MAX_SEARCH_COUNT = 200;
var
  I: Integer;
  LDis: Float;
  LAllow: Boolean;
  LEntity: TUdEntity;
  LLayout: TUdLayout;
  LEntityList: TList;
  LDisEntity: PUdDisEntity;
  LLoopSearch: TUdLoopSearch;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit;

  LEntityList := TList.Create;
  LLoopSearch := TUdLoopSearch.Create();
  try
    LEntityList.Capacity := LLayout.Entities.Count;

    for I := 0 to LLayout.Entities.Count - 1 do
    begin
      LEntity := LLayout.Entities.Items[I];
      Self.IsValidHatchEntity(nil, LEntity, LAllow);
      if not LAllow then Continue;

      LDis := _GetDistance(APnt, LEntity);
      if LDis < 0 then Continue;

      LDisEntity := New(PUdDisEntity);
      LDisEntity^.Dis := LDis;
      LDisEntity^.Entity := LEntity;

      LEntityList.Add(LDisEntity);
    end;

    LEntityList.Sort(FSortDisEntity);

    for I := 0 to Min(LEntityList.Count, MAX_SEARCH_COUNT) - 1 do
    begin
      LEntity := PUdDisEntity(LEntityList[I])^.Entity;

      if LEntity.InheritsFrom(TUdLine) then
        LLoopSearch.Add(TUdLine(LEntity).XData) else
      if LEntity.InheritsFrom(TUdArc) then
        LLoopSearch.Add(TUdArc(LEntity).XData) else
      if LEntity.InheritsFrom(TUdCircle) then
        LLoopSearch.Add(TUdCircle(LEntity).XData)  else
      if LEntity.InheritsFrom(TUdRect) then
        LLoopSearch.Add(TUdRect(LEntity).XData)  else
      if LEntity.InheritsFrom(TUdEllipse) then
        LLoopSearch.Add( UdGeo2D.SamplePoints(TUdEllipse(LEntity).XData, Round(FixAngle(TUdEllipse(LEntity).EndAngle - TUdEllipse(LEntity).StartAngle) / 3 ) ) )  else
      if LEntity.InheritsFrom(TUdPolyline) then
        LLoopSearch.Add(TUdPolyline(LEntity).XData) else
       if LEntity.InheritsFrom(TUdSpline) then
        LLoopSearch.Add(TUdSpline(LEntity).SamplePoints);
    end;

    LLoopSearch.Search();

    for I := 0 to System.Length(LLoopSearch.MinLoops) - 1 do
      if UdGeo2D.IsPntInSegarcs(APnt, LLoopSearch.MinLoops[I]) then
        _AddLoop(LLoopSearch.MinLoops[I]);

  finally
    for I := LEntityList.Count - 1 downto 0 do Dispose(PUdDisEntity(LEntityList[I]));
    LEntityList.Free;

    LLoopSearch.Free;
  end;

end;



function TUdActionHatch.ApplyPickedPntsHatch: Boolean;
var
  I: Integer;
  LHatch: TUdHatch;
begin
  if System.Length(FPickedLoops) > 0 then
  begin
    for I := 0 to System.Length(FPickedLoops) - 1 do
    begin
      LHatch := TUdHatch.Create(FDocument, False);
      LHatch.HatchScale := FHatchForm.HatchScale;
      LHatch.HatchAngle := FHatchForm.HatchAngle;
      LHatch.Style := TUdHatchStyle(FHatchForm.HatchStyle);
      LHatch.PatternName := FHatchForm.PatternName;

      LHatch.AddLoop(FPickedLoops[I]);
      LHatch.Evaluate();

      Self.AddEntity(LHatch);
    end;
  end;

  Result := Self.Finish();
end;

function TUdActionHatch.ApplySelectedObjsHatch: Boolean;

  function _GetSegarcs(AEntity: TUdEntity): TSegarc2DArray;
  begin
    Result := nil;
    if not Assigned(AEntity) then Exit;

    if AEntity.InheritsFrom(TUdLine) then
    begin
      System.SetLength(Result, 1);
      Result[0] := Segarc2D(TUdLine(AEntity).XData);
    end else

    if AEntity.InheritsFrom(TUdArc) then
    begin
      System.SetLength(Result, 1);
      Result[0] := Segarc2D(TUdArc(AEntity).XData);

      case  TUdArc(AEntity).ArcKind of
        akSector: ;
        akChord : ;
      end;

    end else

    if AEntity.InheritsFrom(TUdCircle) then
    begin
      System.SetLength(Result, 2);
      Result[0] := Segarc2D(Arc2D(TUdCircle(AEntity).Center, TUdCircle(AEntity).Radius, 0, 180));
      Result[1] := Segarc2D(Arc2D(TUdCircle(AEntity).Center, TUdCircle(AEntity).Radius, 180, 360));
    end else

    if AEntity.InheritsFrom(TUdRect) then
    begin
      Result := TUdRect(AEntity).XData;
    end else

    if AEntity.InheritsFrom(TUdEllipse) then
    begin
      Result := Segarc2DArray(UdGeo2D.SamplePoints(TUdEllipse(AEntity).XData, Round(FixAngle(TUdEllipse(AEntity).EndAngle - TUdEllipse(AEntity).StartAngle) / 3 ) ))
    end  else

    if AEntity.InheritsFrom(TUdPolyline) then
    begin
      Result := TUdPolyline(AEntity).XData;
    end else

    if AEntity.InheritsFrom(TUdSpline)  then
    begin
      Result := Segarc2DArray( TUdSpline(AEntity).SamplePoints );
    end;
  end;

var
  I: Integer;
  LEntity: TUdEntity;
  LHatch: TUdHatch;
begin
  LHatch := TUdHatch.Create(FDocument, False);
  LHatch.HatchScale := FHatchForm.HatchScale;
  LHatch.HatchAngle := FHatchForm.HatchAngle;
  LHatch.Style := TUdHatchStyle(FHatchForm.HatchStyle);
  LHatch.PatternName := FHatchForm.PatternName;

  for I := 0 to TUdLayout(Layout).SelectedList.Count - 1 do
  begin
    LEntity := TUdLayout(Layout).SelectedList[I];
    LHatch.AddLoop(_GetSegarcs(LEntity));
  end;

  LHatch.Evaluate();
  Self.AddEntity(LHatch);

  Result := Self.Finish();
end;



procedure TUdActionHatch.IsValidHatchEntity(Sender: TObject; Entity: TUdEntity; var Allow: Boolean);
begin
  Allow := Assigned(Entity) and
           (Entity.InheritsFrom(TUdLine) or Entity.InheritsFrom(TUdArc) or Entity.InheritsFrom(TUdCircle) or
            Entity.InheritsFrom(TUdRect) or Entity.InheritsFrom(TUdEllipse) or Entity.InheritsFrom(TUdPolyline) or
            Entity.InheritsFrom(TUdSpline) );
end;


//------------------------------------------------------------------------------------


procedure TUdActionHatch.Paint(Sender: TObject; ACanvas: TCanvas);
var
  I: Integer;
begin
  if FVisible then
  begin
    if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
    for I := 0 to FPickedEntities.Count - 1 do TUdEntity(FPickedEntities[I]).Draw(ACanvas);
  end;
end;


function TUdActionHatch.Parse(const AValue: string): Boolean;
begin
  Result := True;
  if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Parse(AValue);
end;




//------------------------------------------------------------------------------------


procedure TUdActionHatch.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FSelAction) and FSelAction.Visible then
    FSelAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionHatch.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  if FSelAction.Visible then
    FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if (FHatchApply = haPickPnts) then
          begin
            Self.AddPickLoops(ACoordPnt);
          end;
        end
        else if (AButton = mbRight) then
        begin

          case FHatchApply of
            haSelObjs:
              begin
                FHatchForm.btnOK.Enabled := Self.IsAnyLoopValid();
                FHatchForm.ShowModal();

                if FHatchForm.ApplyResult = haOk then Self.ApplySelectedObjsHatch()  else
                if FHatchForm.ApplyResult = haPickPnts then
                begin
                  FHatchApply := haPickPnts;
                  Self.RemoveAllSelected();
                  FSelAction.Visible := False;

                  Self.SetCursorStyle(csDraw);
                  Self.Prompt(sPickInterPnt, pkCmd);
                end else
                if FHatchForm.ApplyResult = haSelObjs then
                begin

                end
                else
                  Self.Finish();
              end;

            haPickPnts:
              begin
                FHatchForm.btnOK.Enabled := Self.IsAnyLoopValid();
                FHatchForm.ShowModal();

                if FHatchForm.ApplyResult = haOk then Self.ApplyPickedPntsHatch()  else
                if FHatchForm.ApplyResult = haPickPnts then
                begin

                end  else
                if FHatchForm.ApplyResult = haSelObjs then
                begin
                  Self.RemoveAllSelected();

                  FHatchApply := haSelObjs;
                  FPickedLoops := nil;
                  UdUtils.ClearObjectList(FPickedEntities);
                  Self.RemoveAllSelected();

                  Self.SetCursorStyle(csPick);
                  Self.Prompt(sSelectObject, pkCmd);
                  Self.Invalidate();
                end
                else
                  Self.Finish();
              end;
          end;

        end;
      end;
    mkMouseMove:
      begin
        //...
      end;
  end;
end;



function TUdActionHatch.CanPopMenu: Boolean;
begin
  Result := False;
            //((FHatchApply = haSelObjs) and (FHatchForm.ApplyResult <> haSelObjs)) or
            //((FHatchApply = haPickPnts) and (FHatchForm.ApplyResult <> haSelObjs))     ;
end;


end.