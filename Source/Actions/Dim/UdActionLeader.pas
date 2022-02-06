{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionLeader;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdAction, UdBaseActions,
  UdLeader, UdText;

type
  //*** TUdActionLeader ***//
  TUdActionLeader = class(TUdDimAction)
  private
    FLeaderObj: TUdLeader;
    FTextObj: TUdText;

    FPoints: TPoint2DArray;
    FCurPnt: TPoint2D;

  protected
    function CalcTextParams(): Boolean;

    function AddPoint(APnt: TPoint2D): Boolean;
    function AddTextStr(AStr: string): Boolean;

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
  UdGeo2D, UdMath, UdUtils, UdAcnConsts;

const
  LEADER_PNTS_COUNT = 3;



//=========================================================================================
{ TUdActionLeader }

class function TUdActionLeader.CommandName: string;
begin
  Result := 'qleader';
end;

constructor TUdActionLeader.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FPoints := nil;

  FLeaderObj := TUdLeader.Create(FDocument, False);
  FLeaderObj.Finished := False;
  FLeaderObj.Visible := False;

  FTextObj := TUdText.Create(FDocument, False);
  FTextObj.Finished := False;
  FTextObj.Visible := False;

  if Assigned(Self.DimStyle) then
    FTextObj.Height := Self.DimStyle.TextProp.TextHeight
  else
    FTextObj.Height := 2.5;


  Self.Prompt(sFirstLeaderPnt, pkCmd);
end;

destructor TUdActionLeader.Destroy;
begin
  FPoints := nil;
  if Assigned(FLeaderObj) then FLeaderObj.Free();
  if Assigned(FTextObj) then FTextObj.Free();

  inherited;
end;


//---------------------------------------------------

procedure TUdActionLeader.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLeaderObj) and FLeaderObj.Visible then FLeaderObj.Draw(ACanvas);
    if Assigned(FTextObj) and FTextObj.Visible then FTextObj.Draw(ACanvas);
  end;
end;



//---------------------------------------------------


function TUdActionLeader.CalcTextParams: Boolean;
var
  LAng: Float;
  LPoint: TPoint2D;
begin
  Result := False;
  if not Assigned(FTextObj) or (System.Length(FPoints) <= 0) then Exit;

  LPoint := FPoints[High(FPoints)];

  LAng := 0;
  if System.Length(FPoints) > 1 then
    LAng := GetAngle(FPoints[High(FPoints)-1], FPoints[High(FPoints)]);

  LPoint := ShiftPoint(LPoint, 90, FTextObj.Height / 2);

  if (LAng > 180.0) and (LAng <= 270.0) then
  begin
    FTextObj.Position := ShiftPoint(LPoint, 180, 0.5);
    FTextObj.Alignment := taTopRight;
  end
  else begin
    FTextObj.Position := ShiftPoint(LPoint, 0, 0.5);
    FTextObj.Alignment := taTopLeft;
  end;


  Result := True;
end;

function TUdActionLeader.AddPoint(APnt: TPoint2D): Boolean;
var
  L: Integer;
begin
  Result := False;
  if not Assigned(FLeaderObj) or (FStep <> 0) then Exit;

  L := System.Length(FPoints);
  if (L > 0) and IsEqual(FPoints[L-1], APnt) then Exit;

  SetPrevPoint(APnt);

  System.SetLength(FPoints, L + 1);
  FPoints[L] := APnt;

  FLeaderObj.Points := FPoints;
  FLeaderObj.Visible := True;

  if System.Length(FPoints) >= LEADER_PNTS_COUNT  then
  begin
    FLeaderObj.Finished := True;
    Self.Submit(FLeaderObj);
    FLeaderObj := nil;

    CalcTextParams();

    Self.CanSnap := False;
    Self.CanOSnap := False;
    Self.CanOrtho := False;

    Self.Prompt(sFirstLineOfText, pkCmd);
    FStep := 1;
  end
  else begin
    if L = 0 then
      Self.Prompt(sFirstLeaderPnt + ':' + PointToStr(APnt), pkLog)
    else
      Self.Prompt(sNextPoint + ':' + PointToStr(APnt), pkLog);

    Self.Prompt(sNextPoint, pkCmd);
  end;
end;

function TUdActionLeader.AddTextStr(AStr: string): Boolean;
begin
  Result := False;
  if not Assigned(FTextObj) or (FStep <> 1) then Exit;

  if AStr = ''  then
  begin
    if FTextObj.Contents = '' then
    begin
      //....
    end
    else begin
      FTextObj.Finished := True;
      FTextObj.Visible := True;

      Self.Submit(FTextObj);
      FTextObj := nil;
    end;

    Result := Self.Finish();
  end
  else begin
    if FTextObj.Contents = '' then
    begin
      FTextObj.Contents := AStr;
      Self.Prompt(sFirstLineOfText + ':' + AStr, pkLog);
    end
    else begin
      FTextObj.Contents := FTextObj.Contents + #13#10 + AStr;
      FTextObj.Refresh();

      Self.Prompt(sNextLineOfText + ':' + AStr, pkLog);
    end;

//    CalcTextParams();
    FTextObj.Visible := True;

    Self.Prompt(sNextLineOfText, pkCmd);
    Result := True;
  end;
end;


//---------------------------------------------------

function TUdActionLeader.Parse(const AValue: string): Boolean;
var
  D: Float;
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  LValue := LowerCase(Trim(AValue));

  if FStep = 0 then
  begin
    if (System.Length(FPoints) > 0) and TryStrToFloat(LValue, D) then
    begin
      LPnt := ShiftPoint(FPoints[High(FPoints)], GetAngle(FPoints[High(FPoints)], FCurPnt), D);
      AddPoint(LPnt);
    end
    else if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp and (System.Length(FPoints) > 0) then
      begin
        LPnt.X := FPoints[High(FPoints)].X + LPnt.X;
        LPnt.Y := FPoints[High(FPoints)].Y + LPnt.Y;
      end;
      AddPoint(LPnt);
    end
    else
      Self.Prompt(sInvalidPoint, pkLog);
  end

  else begin
    AddTextStr(AValue);
  end;

  Result := True;
end;


procedure TUdActionLeader.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionLeader.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  I, L: Integer;
  LPnts: TPoint2DArray;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            AddPoint(ACoordPnt);
        end
        else if (AButton = mbRight) then
        begin
          if FStep = 1 then
            AddTextStr('')
          else
            Self.Finish();
        end;
      end;
    mkMouseMove:
      begin
        FCurPnt := ACoordPnt;

        L := System.Length(FPoints);
        if (FStep = 0) and (L > 0) and (L < LEADER_PNTS_COUNT) then
        begin
          System.SetLength(LPnts, L + 1);
          for I := 0 to L - 1 do LPnts[I] := FPoints[I];
          LPnts[L] := ACoordPnt;

          FLeaderObj.Points := LPnts;
        end;
      end;
  end;
end;






end.