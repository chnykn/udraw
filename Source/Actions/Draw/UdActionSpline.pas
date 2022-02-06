
{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionSpline;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdSpline;

type
  //*** TUdActionSpline ***//
  TUdActionSpline = class(TUdDrawAction)
  private
    FLine: TUdLine;
    FSpline: TUdSpline;
    FPoints: TPoint2DArray;

  protected
//    function GetCurrPoint: PPoint2D; override;

    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetNextPoint(APnt: TPoint2D): Boolean;
    function FinishAction(AClosed: Boolean = False): Boolean;

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
  UdMath, UdUtils, UdAcnConsts;



//=========================================================================================
{ TUdActionSpline }

class function TUdActionSpline.CommandName: string;
begin
  Result := 'spline';
end;

constructor TUdActionSpline.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FSpline := TUdSpline.Create(FDocument, False);
  FSpline.Finished := False;
  FSpline.Visible := False;

  FPoints := nil;
  Self.Prompt(sFirstPoint, pkCmd);
end;

destructor TUdActionSpline.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FSpline) then FSpline.Free();
  inherited;
end;



//---------------------------------------------------

procedure TUdActionSpline.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FSpline) and FLine.Visible then FSpline.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionSpline.SetFirstPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sNextPoint, pkCmd);

  System.SetLength(FPoints, 1);
  FPoints[0] := APnt;

  FStep := 1;
  Result := True;
end;

function TUdActionSpline.SetNextPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FLine.EndPoint := APnt;
  
  if NotEqual(FLine.StartPoint, FLine.EndPoint) then
  begin
    System.SetLength(FPoints, System.Length(FPoints) + 1);
    FPoints[High(FPoints)] := APnt;

    FLine.StartPoint := APnt;
    FLine.EndPoint := APnt;

    Self.SetPrevPoint(APnt);
    Self.Prompt(sNextPoint + ': ' + PointToStr(APnt), pkLog);
    Result := True;

    Self.Invalidate;
  end;
end;

function TUdActionSpline.FinishAction(AClosed: Boolean = False): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  if System.Length(FPoints) > 1 then
  begin
    FSpline.FittingPoints := FPoints;
    FSpline.Closed := AClosed;
    
    FSpline.Visible := True;
    FSpline.Finished := True;

    Self.Submit(FSpline);
  end
  else
    FSpline.Free;
  
  FSpline := nil;
  Result := Self.Finish();
end;



//---------------------------------------------------

function TUdActionSpline.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));

  if LValue= '' then
  begin
    FinishAction();
  end
  else if (LValue = 'c') or (LValue = 'close') then
  begin
    FinishAction(True);
  end else

  if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetFirstPoint(LPnt)
    else if FStep = 1 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FLine.StartPoint.X + LPnt.X;
        LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
      end;
      SetNextPoint(LPnt);
    end;
  end
  else
  begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


procedure TUdActionSpline.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  
end;

procedure TUdActionSpline.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  I: Integer;
  LPoints: TPoint2DArray;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetFirstPoint(ACoordPnt)
          else if FStep = 1 then
            SetNextPoint(ACoordPnt);
        end
        else if (AButton = mbRight) then
          FinishAction();
      end;
    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          FLine.EndPoint := ACoordPnt;

          System.SetLength(LPoints, System.Length(FPoints) + 1);
          for I := 0 to System.Length(FPoints) - 1 do LPoints[I] := FPoints[I];
          LPoints[High(LPoints)] := ACoordPnt;

          FSpline.FittingPoints := LPoints;
          FSpline.Visible := True;

        end;
      end;
  end;
end;


end.