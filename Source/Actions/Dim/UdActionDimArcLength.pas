{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimArcLength;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdDimension, UdDimArcLength;

type
  //*** TUdActionDimArcLength ***//
  TUdActionDimArcLength = class(TUdDimAction)
  private
    FArc: TArc2D;
    FSelArc: TArc2D;
    FSelObj: TUdEntity;

    FLine: TUdLine;
    FDimObj: TUdDimArcLength;

    FPartPnt1, FPartPnt2: TPoint2D;

  protected
    function SelectObj(APnt: TPoint2D): Boolean;        // 0
    function SetArcPoint(APnt: TPoint2D): Boolean;      // 1

    function SetArcPartPoint1(APnt: TPoint2D): Boolean; // 2
    function SetArcPartPoint2(APnt: TPoint2D): Boolean; // 3

    function SetTextAngle(const AValue: Float): Boolean;      // 4, 5
    function SetTextOverride(const AValue: string): Boolean;  // 6

    function SetAnglePoint1(APnt: TPoint2D): Boolean;   // 4
    function SetAnglePoint2(APnt: TPoint2D): Boolean;   // 5


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
  SysUtils, UdArc, UdPolyline,
  UdGeo2D, UdUtils, UdAcnConsts;


//=========================================================================================
{ TUdActionDimArcLength }

class function TUdActionDimArcLength.CommandName: string;
begin
  Result := 'dimarc';
end;

constructor TUdActionDimArcLength.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FArc    := Arc2D(0, 0, -1, 0, 0);
  FSelArc := Arc2D(0, 0, -1, 0, 0);
  FSelObj := nil;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FDimObj := TUdDimArcLength.Create(FDocument, False);
  FDimObj.Finished := False;
  FDimObj.Visible := False;


  Self.CanSnap    := False;
  Self.CanOSnap   := False;
  Self.CanOrtho   := False;
  Self.CanPerpend := False;


  Self.Prompt(sSelArcOrPolyArc, pkCmd);
  Self.SetCursorStyle(csPick)
end;

destructor TUdActionDimArcLength.Destroy;
begin
  FSelObj := nil;

  if Assigned(FLine) then FLine.Free();
  if Assigned(FDimObj) then FDimObj.Free();

  inherited;
end;


//---------------------------------------------------

procedure TUdActionDimArcLength.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FDimObj) and FDimObj.Visible then FDimObj.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionDimArcLength.SelectObj(APnt: TPoint2D): Boolean;
var
  I: Integer;
  E: Float;
  LSelObj: TUdEntity;
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if FStep <> 0 then Exit;

  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) then
  begin
    Self.Prompt(sSelArcOrPolyArc, pkLog);
    Exit;  //========>>>>>
  end;

  if LSelObj.InheritsFrom(TUdArc) then
  begin
    FSelObj := LSelObj;
    FSelArc := TUdArc(FSelObj).XData;
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
        FSelObj := LSelObj;
        FSelArc := LSegarcs[I].Arc;
      end;
    end;
  end;

  if Assigned(FSelObj) then
  begin
    FArc := FSelArc;
    Self.AddSelectedEntity(FSelObj);

    FDimObj.CenterPoint := FArc.Cen;
    FDimObj.ExtLine1Point := ShiftPoint(FArc.Cen, FArc.Ang1, FArc.R);
    FDimObj.ExtLine2Point := ShiftPoint(FArc.Cen, FArc.Ang2, FArc.R);
    FDimObj.ArcPoint := APnt;
    FDimObj.Visible := True;


    Self.CanSnap    := True;
    Self.CanOSnap   := True;
    Self.CanOrtho   := True;
    Self.CanPerpend := True;

    Self.SetCursorStyle(csDraw);

    if FDimObj.ShowLeader then
      Self.Prompt(sArcLenDimPntOrKeys2, pkCmd)
    else
      Self.Prompt(sArcLenDimPntOrKeys, pkCmd);

    FStep := 1;
    Result := True;
  end
  else begin
    Self.Prompt(sSelArcOrPolyArc, pkLog);
  end;
end;

function TUdActionDimArcLength.SetArcPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FDimObj.ArcPoint := APnt;
  FDimObj.Finished := True;
  Self.Submit(FDimObj);

  if FDimObj.ShowLeader then
    Self.Prompt(sArcLenDimPntOrKeys2, pkLog)
  else
    Self.Prompt(sArcLenDimPntOrKeys, pkLog);

  Self.Prompt(sDimTextIs + #32 + FDimObj.GetDimText(FDimObj.Measurement, dtkArcLen), pkLog);

  FDimObj := nil;
  Result := Self.Finish();
end;


function TUdActionDimArcLength.SetArcPartPoint1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FDimObj.Visible := False;

  FPartPnt1 := UdGeo2D.ClosestArcPoint(APnt, FSelArc);

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sArcLenDimArcPnt1 + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sArcLenDimArcPnt2, pkCmd);

  FStep := 3;
  Result := True;
end;

function TUdActionDimArcLength.SetArcPartPoint2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FPartPnt2 := UdGeo2D.ClosestArcPoint(APnt, FSelArc);
  FArc := UdGeo2D.ClipArc(FSelArc, FPartPnt1, FPartPnt2);

  FDimObj.CenterPoint := FArc.Cen;
  FDimObj.ExtLine1Point := ShiftPoint(FArc.Cen, FArc.Ang1, FArc.R);
  FDimObj.ExtLine2Point := ShiftPoint(FArc.Cen, FArc.Ang2, FArc.R);

  FDimObj.Visible := True;


  Self.Prompt(sArcLenDimArcPnt2 + ': ' + PointToStr(APnt), pkLog);

  Self.SetPrevPoint(APnt);

  if FDimObj.ShowLeader then
    Self.Prompt(sArcLenDimPntOrKeys2, pkCmd)
  else
    Self.Prompt(sArcLenDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;


function TUdActionDimArcLength.SetTextAngle(const AValue: Float): Boolean;
begin
  Result := False;
  if not (FStep in [4, 5]) then Exit;

  FDimObj.TextAngle := AValue;
  Self.Prompt(sDimTextAngle + AngleToStr(AValue), pkLog);

  if FDimObj.ShowLeader then
    Self.Prompt(sArcLenDimPntOrKeys2, pkCmd)
  else
    Self.Prompt(sArcLenDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionDimArcLength.SetTextOverride(const AValue: string): Boolean;
begin
  Result := False;
  if FStep <> 6 then Exit;

  if AValue = '' then
  begin
    Self.Prompt(sEnterDimText + '<' + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal) + '>', pkLog);
  end
  else begin
    FDimObj.TextOverride := AValue;
    Self.Prompt(sEnterDimText + ' : ' + AValue, pkLog);
  end;


  if FDimObj.ShowLeader then
    Self.Prompt(sArcLenDimPntOrKeys2, pkCmd)
  else
    Self.Prompt(sArcLenDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;



function TUdActionDimArcLength.SetAnglePoint1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 4 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 5;
  Result := True;
end;

function TUdActionDimArcLength.SetAnglePoint2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 5 then Exit;

  FLine.EndPoint := APnt;
  FLine.Visible := False;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);

  Result := SetTextAngle(GetAngle(FLine.StartPoint, FLine.EndPoint));
end;



//---------------------------------------------------

function TUdActionDimArcLength.Parse(const AValue: string): Boolean;
var
  D: Double;
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
//  LLayout: TUdLayout;
//  LLastLine: TUdLine;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));
  if LValue = '' then
  begin
    if FStep <= 1 then
    begin
      Self.Finish();
      Exit;
    end else
    if FStep = 4 then
    begin
      FLine.Visible := False;

      if FDimObj.ShowLeader then
        Self.Prompt(sArcLenDimPntOrKeys2, pkCmd)
      else
        Self.Prompt(sArcLenDimPntOrKeys, pkCmd);

      FStep := 1;
      Exit;
    end else
    if FStep = 6 then
    begin
      SetTextOverride('');
      Exit;
    end;

    Self.Prompt(sRequirePointOrKeyword, pkLog);
    Exit;
  end;

  if FStep in [2, 3, 4, 5] then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      if FStep = 4 then
      begin
        SetTextAngle(D);
      end else
      if FStep in [3, 5] then
      begin
        LPnt := ShiftPoint(FLine.StartPoint, GetAngle(FLine.StartPoint, FLine.EndPoint), D);
        if FStep = 3 then
          SetArcPartPoint2(LPnt)
        else
          SetAnglePoint2(LPnt);
      end
      else begin
        Self.Prompt(sInvalidPoint, pkLog);
        Result := False;
      end;
    end else

    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if FStep = 2 then
        SetArcPartPoint1(LPnt)
      else if FStep = 3 then
      begin
        if LIsOpp then
        begin
          LPnt.X := FLine.StartPoint.X + LPnt.X;
          LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
        end;
        SetArcPartPoint2(LPnt);
      end else
      if FStep = 4 then
        SetAnglePoint1(LPnt)
      else if FStep = 5 then
      begin
        if LIsOpp then
        begin
          LPnt.X := FLine.StartPoint.X + LPnt.X;
          LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
        end;
        SetAnglePoint2(LPnt);
      end;
    end

    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end else

  if FStep = 1 then
  begin
    if (LValue = 't') or (LValue = 'text') then
    begin
      FStep := 6;
      Self.Prompt(sEnterDimText + '<' + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal) + '>', pkCmd);
    end else

    if (LValue = 'a') or (LValue = 'angle') then
    begin
      FStep := 4;
      Self.Prompt(sDimTextAngle, pkCmd);
    end else

    if (LValue = 'p') or (LValue = 'partial') then
    begin
      FStep := 2;
      FDimObj.Visible := False;
      Self.Prompt(sArcLenDimArcPnt1, pkCmd);
    end else

    if (LValue = 'l') or (LValue = 'leader') then
    begin
      FDimObj.ShowLeader := True;
      Self.Prompt(sArcLenDimPntOrKeys2, pkCmd)
    end else

    if (LValue = 'n') or (LValue = 'no leader') then
    begin
      FDimObj.ShowLeader := False;
      Self.Prompt(sArcLenDimPntOrKeys, pkCmd);
    end else

    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FLine.StartPoint.X + LPnt.X;
        LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
      end;
      SetArcPoint(LPnt);
    end

    else begin
      Self.Prompt(sRequirePointOrKeyword, pkLog);
      Result := False;
    end;
  end else
  if FStep = 6 then
  begin
    SetTextOverride(AValue);
  end;
end;


procedure TUdActionDimArcLength.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionDimArcLength.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SelectObj(ACoordPnt)
          else if FStep = 1 then
            SetArcPoint(ACoordPnt)
          else if FStep = 2 then
            SetArcPartPoint1(ACoordPnt)
          else if FStep = 3 then
            SetArcPartPoint2(ACoordPnt)
          else if FStep = 4 then
            SetAnglePoint1(ACoordPnt)
          else if FStep = 5 then
            SetAnglePoint2(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          FDimObj.ArcPoint := ACoordPnt;
        end else
        if FStep in [3, 5] then
        begin
          FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;





end.