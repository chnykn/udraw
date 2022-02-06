{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionIdle;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Controls, Graphics,
  UdConsts, UdTypes, UdEvents, UdObject, UdEntity, UdAction;

type

  //*** TUdActionIdle ***//
  TUdActionIdle = class(TUdAction)
  private
    FSelAction: TUdAction;

  protected

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    function Reset(): Boolean; override;
    function Parse(const AValue: string): Boolean; override;

    procedure DblClick(Sender: TObject; APoint: TPoint); override;
    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;

  public

  end;

  


implementation

uses
  UdDocument, UdLayout, UdActionSelection, UdActionGrip, UdTolerance, UdToleranceFrm;



{ TUdActionIdle }

constructor TUdActionIdle.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FSelAction := TUdActionSelection.Create(FDocument, FLayout);
  TUdActionSelection(FSelAction).WindowingHint := UdConsts.SELECT_WIDOWING;

  Self.SetCursorStyle(csIdle);
end;

procedure TUdActionIdle.DblClick(Sender: TObject; APoint: TPoint);
var
  LPnt: TPoint2D;
  LLayout: TUdLayout;
  LEntity: TUdEntity;
  LForm: TUdToleranceForm;
begin
  inherited;

  LLayout := TUdLayout(Self.GetLayout());
  
  if Assigned(LLayout) and Assigned(Document) then
  begin
    LPnt := LLayout.Axes.PointValue(APoint);
    LEntity := LLayout.PickEntity(LPnt, False);

    if Assigned(LEntity) and LEntity.InheritsFrom(TUdTolerance) then
    begin
      LForm := TUdToleranceForm.Create(nil);
      try
        if Assigned(Self.TextStyles) then
          LForm.GdtShx := Self.TextStyles.GetItem('__GDT').ShxFont;
        LForm.ToleranceText := TUdTolerance(LEntity).Contents;

        if (LForm.ShowModal() = mrOk) then
          TUdTolerance(LEntity).Contents := LForm.ToleranceText;
      finally
        LForm.Free;
      end;
    end;
  end;
end;

destructor TUdActionIdle.Destroy;
begin
  if Assigned(FSelAction) then FSelAction.Free;
  inherited;
end;



function TUdActionIdle.Reset: Boolean;
begin
  FSelAction.Reset();
  Result := inherited Reset();
end;


procedure TUdActionIdle.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  FSelAction.Paint(Sender, ACanvas);
end;

function TUdActionIdle.Parse(const AValue: string): Boolean;
begin
  Result := FSelAction.Parse(AValue);
end;



procedure TUdActionIdle.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
var
  LOK: Boolean;
begin
  inherited;

  if AKey = VK_ESCAPE then
  begin
    Self.RemoveAllSelected();
  end;


  if Assigned( FDocument ) then
  begin
    if not TUdDocument(FDocument).IdleCanEdit then Exit;
  end;

  LOK := False;

  if AKey = VK_DELETE then
  begin
    Self.BeginUndo('');
    try
      Self.EraseSelectedEntities();
    finally
      Self.EndUndo();
    end;

    LOK := True;
  end;             
  
  if (not LOK) and (AShift = [ssCtrl]) then
  begin
    if AKey in [88, 120,  67, 99,  86, 118] then
    begin
      Self.BeginUndo('');
      try
        if (AKey = 88) or (AKey = 120) {x} then LOK := Self.ExecCommond('_cutclip')   else
        if (AKey = 67) or (AKey = 99)  {c} then LOK := Self.ExecCommond('_copyclip')  else
        if (AKey = 86) or (AKey = 118) {v} then LOK := Self.ExecCommond('_pasteclip')  ;
      finally
        Self.EndUndo();
      end;
    end;

    if AKey in [88, 120,  67, 99,  86, 118] then
    begin
      if (AKey = 90) or (AKey = 122)  {z} then LOK := Self.PerformUndo() else
      if (AKey = 89) or (AKey = 121)  {y} then LOK := Self.PerformRedo() ;
    end;
  end;

  if (not LOK) and FSelAction.Visible then
    FSelAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionIdle.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
  LAction: TUdAction;
  LGripPoints: TUdGripPointArray;
begin
  inherited;

  if (AKind = mkMouseDown) and (AButton = mbLeft) then
  begin
    LLayout := TUdLayout(Self.GetLayout());
    if Assigned(LLayout) and LLayout.EnableGrip then
    begin
      LGripPoints := LLayout.GetGripPoints(ACoordPnt, MAX_GRIP_COUNT);
      if System.Length(LGripPoints) > 0 then
      begin
        LLayout.ActionAdd(TUdActionGrip);

        LAction := LLayout.ActiveAction;
        if Assigned(LAction) and LAction.InheritsFrom(TUdActionGrip) then
        begin
          LLayout.SetPrevPoint(ACoordPnt);
          TUdActionGrip(LAction).GripPoints := LGripPoints;
          Exit; //=======>>>
        end;
      end;
    end;
  end;

  FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
end;





end.