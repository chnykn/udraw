{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionPickWindow;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject,
  UdEntity, UdAction;


type

  //*** TUdActionPickWindow ***//
  TUdActionPickWindow = class(TUdAction)
  private
    FAcnEntity: TUdEntity;
    FP1, FP2: TPoint2D;

    FWindow: TRect2D;
    FOnPickWindow: TUdPickWindowEvent;

  protected
    procedure SetVisible(const AValue: Boolean); override;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = '');  override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint);  override;

  public
    property OnPickWindow: TUdPickWindowEvent read FOnPickWindow write FOnPickWindow;
  end;



implementation

uses
  SysUtils,
  UdLayout, UdRect,
  UdGeo2D, UdMath, UdAcnConsts;



//===========================================================================================================
{ TUdActionPickWindow }


constructor TUdActionPickWindow.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FAcnEntity := TUdRect.Create(FDocument, False);
  FAcnEntity.Finished := False;
  FAcnEntity.Visible := False;
  FAcnEntity.Color.TrueColor := Self.GetDefColor();
  FAcnEntity.UsePenStyle := True;

  FWindow := Rect2D(0, 0, 0, 0);
  Self.SetCursorStyle(csDraw);

  Self.Prompt(sFirstCorner, pkCmd);
end;

destructor TUdActionPickWindow.Destroy;
begin
  if Assigned(FOnPickWindow) then FOnPickWindow(Self, FWindow);
  if Assigned(FAcnEntity) then FAcnEntity.Free();
  inherited;
end;

procedure TUdActionPickWindow.SetVisible(const AValue: Boolean);
begin
  inherited;
  FStep := 0;
  if Assigned(FAcnEntity) then FAcnEntity.Visible := AValue;
end;


//----------------------------------------------------------------------------------------

procedure TUdActionPickWindow.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if Assigned(FAcnEntity) and FAcnEntity.Visible then FAcnEntity.Draw(ACanvas);
end;

procedure TUdActionPickWindow.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

  if AKind = kkPress then
  begin
    if AKey = VK_ESCAPE then
      Self.Finish();
  end;
end;

procedure TUdActionPickWindow.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
    ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
begin
  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=====>>>

  case AKind of
    mkMouseDown:
      begin
        if AButton = mbLeft then
        begin
          if FStep = 0 then
          begin
            FStep := 1;
            FStoreCurStyle := LLayout.XCursorStyle;
            SetCursorStyle(csNone);

            FP1 := ACoordPnt;
            Self.Prompt(sSecondCorner, pkCmd);
          end
          else if FStep = 1 then
          begin
            FAcnEntity.Visible := False;
            Self.SetCursorStyle(FStoreCurStyle);

            FP2 := ACoordPnt;
            FWindow := UdGeo2D.RectHull(FP1, FP2);
            Self.Finish();
          end;
        end
        else if AButton = mbRight then
        begin
          Self.Finish();
        end;

      end;

    mkMouseMove:
      begin
        FP2 := ACoordPnt;
        if (FStep = 1) then
        begin
          FAcnEntity.Visible := True;
          TUdRect(FAcnEntity).SetRect(RectHull(FP1, FP2));
        end;
      end;
  end;
end;







end.