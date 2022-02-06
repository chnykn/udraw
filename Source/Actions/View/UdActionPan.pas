{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionPan;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls, Types,
  UdTypes, UdGTypes, UdEvents, UdObject,
  UdEntity, UdAction, UdBaseActions, UdLine;

type
  //*** TUdActionPanReal ***//
  TUdActionPanReal = class(TUdViewAction)
  private
    FPnt: TPoint;
    FOldUseGrid: Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;

    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionPan2P ***//
  TUdActionPan2P = class(TUdViewAction)
  private
    FPnt: TPoint;
    FLine: TUdLine;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;



implementation

uses

  UdLayout, UdAcnConsts;



//===============================================================================================
{ TUdActionPanReal }

class function TUdActionPanReal.CommandName: string;
begin
  Result := 'pan';
end;

constructor TUdActionPanReal.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.SetCursorStyle(csPan);
end;

destructor TUdActionPanReal.Destroy;
begin

  inherited;
end;

procedure TUdActionPanReal.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
      AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
begin
  inherited;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit;

  case AKind of
    mkMouseDown:
      begin
        if AButton = mbLeft then
        begin
          if FStep = 0 then
          begin
            FOldUseGrid := LLayout.GridOn;

            FStep := 1;
            FPnt := AScreenPnt;
          end;
        end
        else if AButton = mbRight then
          Self.Finish();
      end;

    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          LLayout.Pan(AScreenPnt.X - FPnt.X, AScreenPnt.Y - FPnt.Y);
          FPnt := AScreenPnt;
        end;
      end;

    mkMouseUp:
      begin
        if AButton = mbLeft then
        begin
          FStep := 0;
          LLayout.GridOn := FOldUseGrid;
        end;
      end;
  end;
end;



//=======================================================================================
{ TUdActionPan2P }

class function TUdActionPan2P.CommandName: string;
begin
  Result := '-pan';
end;

constructor TUdActionPan2P.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  Self.SetCursorStyle(csDraw);
  Self.Prompt(sFirstPoint, pkCmd);
end;

destructor TUdActionPan2P.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  inherited;
end;

procedure TUdActionPan2P.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
end;


procedure TUdActionPan2P.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
begin
  inherited;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
          begin
            FLine.StartPoint := ACoordPnt;
            FLine.EndPoint := ACoordPnt;
            FLine.Visible := True;
            Self.FStep := 1;

            FPnt := AScreenPnt;
          end
          else if FStep = 1 then
          begin
            FLine.Visible := False;

            LLayout.Pan(AScreenPnt.X - FPnt.X, AScreenPnt.Y - FPnt.Y);
            Self.Finish();
          end;
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 1 then
          FLine.EndPoint := ACoordPnt;
      end;
  end;
end;

end.