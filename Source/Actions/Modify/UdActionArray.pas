{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionArray;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls, Forms,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdActionSelection, UdActionArrayFrm;

type


  //*** TUdActionArray ***//
  TUdActionArray = class(TUdAction)
  private
    FLine: TUdLine;

    FArrayForm: TUdActionArrayForm;
    FSelAction: TUdActionSelection;

  protected
    function ApplyArray(): Boolean;
    function ApplyPickKind(): Boolean;
    procedure ShowArrayForm();

    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetNextPoint(APnt: TPoint2D): Boolean;

    function SetCenterPoint(APnt: TPoint2D): Boolean;
    function SetFillAngPoint(APnt: TPoint2D): Boolean;

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
{ TUdActionArray }


class function TUdActionArray.CommandName: string;
begin
  Result := 'array';
end;

constructor TUdActionArray.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FSelAction := TUdActionSelection.Create(FDocument, FLayout);
  FSelAction.Visible := False;

  FArrayForm := TUdActionArrayForm.Create(nil);
  FArrayForm.btnOK.Enabled := TUdLayout(Self.Layout).SelectedList.Count > 0;

  Self.CanSnap := False;
  Self.CanOSnap := False;
  Self.CanOrtho := False;

  case FArrayForm.ShowModal() of
    mrOK:
      begin
        Self.ApplyArray();
        Self.Aborted := True;
      end;

    mrYes:
      begin
        Self.ApplyPickKind();
      end;

    else
      Self.Aborted := True;
  end;
end;

destructor TUdActionArray.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  FLine := nil;

  if Assigned(FSelAction) then FSelAction.Free();
  FSelAction := nil;

  if Assigned(FArrayForm) then FArrayForm.Free();
  FArrayForm := nil;

  inherited;
end;




//------------------------------------------------------------------------------------


function TUdActionArray.ApplyArray(): Boolean;

  procedure _RectArray(ALayout: TUdLayout; ARowNum, AColNum: Integer; ARowDis, AColDis: Float; AAngle: Float);
  var
    I: Integer;
    LEntity: TUdEntity;
    LEntities: TUdEntityArray;
  begin
    for I := 0 to ALayout.SelectedList.Count -  1 do
    begin
      LEntity := TUdEntity(ALayout.SelectedList[I]);
      LEntities := LEntity.ArrayRect(ARowNum, AColNum, ARowDis, AColDis, AAngle);

      ALayout.AddEntities(LEntities);
    end;
  end;

  procedure _PolarArray(ALayout: TUdLayout; ANum: Integer; AFillAng: Float; ACenter: TPoint2D; ARotateItems: Boolean);
  var
    I: Integer;
    LEntity: TUdEntity;
    LEntities: TUdEntityArray;
  begin
    for I := 0 to ALayout.SelectedList.Count -  1 do
    begin
      LEntity := TUdEntity(ALayout.SelectedList[I]);
      LEntities := LEntity.ArrayPolar(ANum, AFillAng, ACenter, ARotateItems);

      ALayout.AddEntities(LEntities);
    end;
  end;

var
  LLayout: TUdLayout;
begin
  Result := False;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) or (LLayout.SelectedList.Count <= 0) then Exit;

  if FArrayForm.rdRectArray.Checked then
  begin
    _RectArray(LLayout, FArrayForm.RectRowNum, FArrayForm.RectColNum,
      FArrayForm.RectRowDis, FArrayForm.RectColDis, FArrayForm.RectAngle);
  end
  else begin
    _PolarArray(LLayout, FArrayForm.PolarNum, FArrayForm.PolarFillAng,
      FArrayForm.PolarCenter, FArrayForm.PolarRotateItems);
  end;

  Result := True;
end;


function TUdActionArray.ApplyPickKind: Boolean;
begin
  FStep := 0;
  FLine.Visible := False;

  FSelAction.Visible := False;

  case FArrayForm.PickKind of
    apkSelObjs   :
    begin
      FSelAction.Visible := True;
      Self.SetCursorStyle(csPick);
      Self.Prompt(sSelectObject, pkCmd);
    end;


    apkRowOffset :
    begin
      Self.SetCursorStyle(csDraw);
      Self.Prompt(sDisBetweenColumns, pkCmd);
    end;

    apkColOffset :
    begin
      Self.SetCursorStyle(csDraw);
      Self.Prompt(sDisBetweenRows, pkCmd);
    end;

    apkAngle     :
    begin
      Self.SetCursorStyle(csDraw);
      Self.Prompt(sAngleOfArray, pkCmd);
    end;


    apkCenter    :
    begin
      Self.SetCursorStyle(csDraw);
      Self.Prompt(sCenterOfArray, pkCmd);
    end;

    apkFillAngle :
    begin
      FLine.StartPoint := FArrayForm.PolarCenter;
      FLine.Visible := True;

      Self.SetCursorStyle(csDraw);
      Self.Prompt(sAngleOfFill, pkCmd);
    end;
  end;

  Result := True;
end;


procedure TUdActionArray.ShowArrayForm();
begin
  FArrayForm.btnOK.Enabled := TUdLayout(Self.Layout).SelectedList.Count > 0;
  case FArrayForm.ShowModal() of
    mrOK:
      begin
        Self.ApplyArray();
        Self.Finish;
      end;
    mrYes: ApplyPickKind();
    else
      Self.Finish();
  end;
end;

//------------------------------------------------------------------------------------

function TUdActionArray.SetFirstPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.CanSnap := True;
  Self.CanOSnap := True;
  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);

  case FArrayForm.PickKind of
    apkRowOffset: Self.Prompt(sDisBetweenRows   , pkLog);
    apkColOffset: Self.Prompt(sDisBetweenColumns, pkLog);
    apkAngle    : Self.Prompt(sAngleOfArray     , pkLog);
  end;


  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sNextPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionArray.SetNextPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FLine.EndPoint := APnt;

  if NotEqual(FLine.StartPoint, FLine.EndPoint) then
  begin
    FStep := 0;
    FLine.Visible := False;

    case FArrayForm.PickKind of
      apkRowOffset: FArrayForm.RectRowDis := Distance(FLine.XData);
      apkColOffset: FArrayForm.RectColDis := Distance(FLine.XData);
      apkAngle    : FArrayForm.RectAngle  := GetAngle(FLine.StartPoint, FLine.EndPoint);
    end;

    ShowArrayForm();
  end;
end;


function TUdActionArray.SetCenterPoint(APnt: TPoint2D): Boolean;
begin
  Result := True;
  FArrayForm.PolarCenter := APnt;
  ShowArrayForm();
end;


function TUdActionArray.SetFillAngPoint(APnt: TPoint2D): Boolean;
begin
  Result := True;
  FArrayForm.PolarFillAng := GetAngle(FArrayForm.PolarCenter, APnt);
  ShowArrayForm();
end;




//------------------------------------------------------------------------------------


procedure TUdActionArray.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
  end;
end;


function TUdActionArray.Parse(const AValue: string): Boolean;
begin
  Result := True;
  if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Parse(AValue);
end;




//------------------------------------------------------------------------------------


procedure TUdActionArray.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FSelAction) and FSelAction.Visible then
    FSelAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionArray.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
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
          case FArrayForm.PickKind of
            apkRowOffset, apkColOffset, apkAngle :
              if FStep = 0 then SetFirstPoint(ACoordPnt) else if FStep = 1 then SetNextPoint(ACoordPnt);

            apkCenter    : SetCenterPoint(ACoordPnt);
            apkFillAngle : SetFillAngPoint(ACoordPnt);
          end;
        end


        else if (AButton = mbRight) then
        begin
          if FArrayForm.PickKind = apkSelObjs then
          begin
            if TUdLayout(Self.Layout).SelectedList.Count <= 0 then
              Self.Finish()
            else
              Self.ShowArrayForm();
          end
          else begin
            //.......
          end;
        end;
      end;
    mkMouseMove:
      begin
        case FArrayForm.PickKind of
          apkRowOffset, apkColOffset, apkAngle :
            if FStep = 1 then FLine.EndPoint := ACoordPnt;

          apkFillAngle :
            if FStep = 0 then FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;


function TUdActionArray.CanPopMenu(): Boolean;
begin
  Result := False;
end;



end.