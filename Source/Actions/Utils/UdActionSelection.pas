{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionSelection;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics, Controls,
  UdConsts, UdTypes, UdGTypes, UdIntfs, UdEvents, UdObject,
  UdEntity, UdAction;


type

  //*** TUdActionSelection ***//
  TUdActionSelection = class(TUdAction)
  private
    FCanvas: TCanvas;

    FP1, FP2: TPoint2D;
    FStoreCurStyle: TUdCursorStyle;

    FWindowingHint: Boolean;
    FPressDragWindow: Boolean;
    FCtlKeyForMultSelect: Boolean;

    FOnFilter: TUdEntityAllowEvent;
    FOnSelected: TUdEntitiesEvent;

  protected
    procedure SetVisible(const AValue: Boolean); override;

    function PickPoint(APnt: TPoint2D; ACtlPressed: Boolean): Boolean;
    function PickRect(ARect: TRect2D; ACrossingMode: Boolean; ACtlPressed: Boolean): Boolean;

    procedure SetWindowingHint(const Value: Boolean);
    function DrawWindowingHintRect(AP1, AP2: TPoint2D): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = '');  override;
    destructor Destroy(); override;

    function Reset(): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint);  override;

    function CanPopMenu: Boolean; override;

  public
    property WindowingHint: Boolean read FWindowingHint write SetWindowingHint;
    property PressDragWindow: Boolean read FPressDragWindow write FPressDragWindow;
    property CtlKeyForMultSelect: Boolean read FCtlKeyForMultSelect write FCtlKeyForMultSelect;

    property OnFilter: TUdEntityAllowEvent read FOnFilter write FOnFilter;
    property OnSelected: TUdEntitiesEvent read FOnSelected write FOnSelected;
  end;



implementation

uses
  SysUtils,
  UdLayout, UdRect,
  UdGeo2D, UdMath, UdAcnConsts;



//===========================================================================================================
{ TUdActionSelection }


constructor TUdActionSelection.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  LLayout: TObject;
  LCanvasSup: IUdCanvasSupport;
begin
  inherited;

  FCanvas := nil;

  LLayout := Self.GetLayout();
  if Assigned(LLayout) and Assigned(TUdLayout(LLayout).DrawPanel) then
  begin
    if TUdLayout(LLayout).DrawPanel.GetInterface(IUdCanvasSupport, LCanvasSup) then
      FCanvas := TCanvas(LCanvasSup.GetControlCanvas());
  end;

  FStoreCurStyle := csIdle;

  FWindowingHint := UdConsts.SELECT_WIDOWING;
  FPressDragWindow := False;
  FCtlKeyForMultSelect := True;

  FOnFilter := nil;
  FOnSelected := nil;
end;

destructor TUdActionSelection.Destroy;
begin
  inherited;
end;

procedure TUdActionSelection.SetVisible(const AValue: Boolean);
begin
  inherited;
  FStep := 0;
//  if Assigned(FAcnEntity) then FAcnEntity.Visible := AValue;
end;


procedure TUdActionSelection.SetWindowingHint(const Value: Boolean);
begin
  FWindowingHint := Value;
end;

//----------------------------------------------------------------------------------------

procedure TUdActionSelection.Paint(Sender: TObject; ACanvas: TCanvas);
begin
//  FCanvas := ACanvas;
end;

function TUdActionSelection.PickPoint(APnt: TPoint2D; ACtlPressed: Boolean): Boolean;
var
  LEntity: TUdEntity;
  LLayout: TUdLayout;
  LEntities: TUdEntityArray;
begin
  Result := False;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=====>>>

  LEntity := LLayout.PickEntity(APnt);
  if not Assigned(LEntity) then  Exit; //=====>>>

  if Assigned(FOnFilter) then
  begin
    FOnFilter(Self, LEntity, Result);
    if not Result then  Exit; //=====>>>
  end;

  if Assigned(FOnSelected) then
  begin
    System.SetLength(LEntities, 1);
    LEntities[0] := LEntity;
    FOnSelected(Self, LEntities);
  end
  else begin
    if LLayout.Selection.IndexOf(LEntity) < 0 then
    begin
      if not ACtlPressed and FCtlKeyForMultSelect then
        LLayout.RemoveAllSelected();
      LLayout.AddSelectedEntity(LEntity);
    end;

    Self.Prompt(Format(sSelectObjectsNum, [1, LLayout.Selection.Count]), pkLog);
  end;

  Result := True;
end;

function TUdActionSelection.PickRect(ARect: TRect2D; ACrossingMode: Boolean; ACtlPressed: Boolean): Boolean;
var
  I: Integer;
  LList: TList;
  LAllow: Boolean;
  LLayout: TUdLayout;
  LEntities: TUdEntityArray;
begin
  Result := False;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=====>>>

  LEntities := LLayout.PickEntity(ARect, ACrossingMode);
  if System.Length(LEntities) <= 0 then Exit; //=====>>>

  if Assigned(FOnFilter) then
  begin
    LList := TList.Create;
    try
      for I := 0 to System.Length(LEntities) - 1 do
      begin
        LAllow := False;
        FOnFilter(Self, LEntities[I], LAllow);

        if LAllow then LList.Add(LEntities[I]);
      end;

      System.SetLength(LEntities, LList.Count);
      for I := 0 to LList.Count - 1 do LEntities[I] := LList[I];
    finally
      LList.Free;
    end;
  end;

  if Assigned(FOnSelected) then
  begin
    FOnSelected(Self, LEntities);
  end
  else begin
    if not ACtlPressed and FCtlKeyForMultSelect then
      LLayout.RemoveAllSelected();
    LLayout.AddSelectedEntities(LEntities);
  end;

  Self.Prompt(Format(sSelectObjectsNum, [System.Length(LEntities), LLayout.Selection.Count]), pkLog);

  Result := True;
end;




function TUdActionSelection.Reset: Boolean;
begin
  FStep := 0;
  Self.SetCursorStyle(FStoreCurStyle);

  Result := True;
end;

function TUdActionSelection.DrawWindowingHintRect(AP1, AP2: TPoint2D): Boolean;
var
  LPenStyle: TPenStyle;
  LX1, LY1, LX2, LY2: Integer;
begin
  Result := False;
  if not Assigned(FCanvas) then Exit;

  if AP1.X > AP2.X then LPenStyle := psDot else LPenStyle := psSolid;

  with TUdLayout(Self.Layout) do
  begin
    LX1 := Axes.XPixel(AP1.X);
    LX2 := Axes.XPixel(AP2.X);

    LY1 := Axes.YPixel(AP1.Y);
    LY2 := Axes.YPixel(AP2.Y);
  end;

  if LX1 > LX2 then Swap(LX1, LX2);
  if LY1 > LY2 then Swap(LY1, LY2);

  FCanvas.Pen.Width := 0;
  FCanvas.Pen.Style := LPenStyle;
  FCanvas.Pen.Color := clWhite;
  FCanvas.Pen.Mode  := pmXor;

  FCanvas.PolyLine([Point(LX1, LY1), Point(LX2, LY1),
                    Point(LX2, LY2), Point(LX1, LY2), Point(LX1, LY1)]);

  Result := True;
end;



procedure TUdActionSelection.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
var
  LLayout: TUdLayout;
begin
  //inherited;

  if AKind = kkPress then
  begin
    if AKey = VK_ESCAPE then
    begin
      LLayout := TUdLayout(Self.GetLayout());
      if Assigned(LLayout) then LLayout.RemoveAllSelected();
    end;
  end;
end;

procedure TUdActionSelection.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
    ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LP2: TPoint2D;
  LLayout: TUdLayout;
begin
  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=====>>>

  case AKind of
    mkMouseDown:
      begin
        if AButton = mbLeft then
        begin
          if FWindowingHint then
          begin
            if FStep = 0 then
            begin
              if not Self.PickPoint(ACoordPnt, ssCtrl in AShift) then
              begin
                FStep := 1;
                FStoreCurStyle := LLayout.XCursorStyle;
                SetCursorStyle(csNone);

                FP1 := ACoordPnt;
                FP2 := ACoordPnt;
              end;
            end
            else if FStep = 1 then
            begin
              Self.Reset();

              FP2 := ACoordPnt;
              DrawWindowingHintRect(FP1, FP2);

              Self.PickRect(UdGeo2D.RectHull(FP1, FP2), FP1.X > FP2.X, ssCtrl in AShift);
            end;
          end
          else begin
            Self.PickPoint(ACoordPnt, ssCtrl in AShift);
          end;
        end
        else if AButton = mbRight then
        begin
          if TUdLayout(Self.GetLayout()).ActiveAction = Self then
            Self.Finish();
        end;

      end;

    mkMouseMove:
      begin
        LP2 := FP2;
        FP2 := ACoordPnt;
        if FWindowingHint and (FStep = 1) and Assigned(FCanvas) then
        begin
          DrawWindowingHintRect(FP1, LP2);
          DrawWindowingHintRect(FP1, FP2);
        end;
      end;

    mkMouseUp:
      begin
        if FPressDragWindow and (FStep = 1)  then
        begin
          Self.Reset();

          FP2 := ACoordPnt;
          DrawWindowingHintRect(FP1, FP2);

          Self.PickRect(UdGeo2D.RectHull(FP1, FP2), FP1.X > FP2.X, ssCtrl in AShift);
        end;
      end;
  end;
end;


function TUdActionSelection.CanPopMenu(): Boolean;
begin
  Result := False;
end;





end.