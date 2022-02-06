{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimRadial;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdDimension, UdDimRadial;

type
  TUdDimRadialClass = class of TUdDimRadial;

  //*** TUdActionDimRadial ***//
  TUdActionDimRadial = class(TUdDimAction)
  private
    FArc: TArc2D;
    FSelObj: TUdEntity;

    FLine: TUdLine;
    FDimObj: TUdDimRadial;

  protected
    function GetDimObjClass(): TUdDimRadialClass; virtual;
    function FSetChordPoint(APnt: TPoint2D): Boolean;

    function SelectObj(APnt: TPoint2D): Boolean;        // 0
    function SetChordPoint(APnt: TPoint2D): Boolean;    // 1

    function SetTextAngle(const AValue: Float): Boolean;      // 2, 3
    function SetTextOverride(const AValue: string): Boolean;  // 4

    function SetAnglePoint1(APnt: TPoint2D): Boolean;   // 2
    function SetAnglePoint2(APnt: TPoint2D): Boolean;   // 3

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
  SysUtils, UdArc, UdCircle, UdPolyline,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;


//=========================================================================================
{ TUdActionDimRadial }

class function TUdActionDimRadial.CommandName: string;
begin
  Result := 'dimradius';
end;

constructor TUdActionDimRadial.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FArc    := Arc2D(0, 0, -1, 0, 0);
  FSelObj := nil;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FDimObj := GetDimObjClass().Create(FDocument, False);
  FDimObj.Finished := False;
  FDimObj.Visible := False;


  Self.CanSnap    := False;
  Self.CanOSnap   := False;
  Self.CanOrtho   := False;
  Self.CanPerpend := False;


  Self.Prompt(sSelectArcOrCir, pkCmd);
  Self.SetCursorStyle(csPick)
end;

destructor TUdActionDimRadial.Destroy;
begin
  FSelObj := nil;

  if Assigned(FLine) then FLine.Free();
  if Assigned(FDimObj) then FDimObj.Free();

  inherited;
end;


function TUdActionDimRadial.GetDimObjClass(): TUdDimRadialClass;
begin
  Result := TUdDimRadial;
end;


//---------------------------------------------------

procedure TUdActionDimRadial.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FDimObj) and FDimObj.Visible then FDimObj.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionDimRadial.SelectObj(APnt: TPoint2D): Boolean;
var
  I: Integer;
  E: Float;
  LLeaderLen: Float;
  LSelObj: TUdEntity;
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if FStep <> 0 then Exit;

  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) then
  begin
    Self.Prompt(sSelArcOrPolyArc, pkLog);
    Exit;
  end;

  if LSelObj.InheritsFrom(TUdArc) then
  begin
    FSelObj := LSelObj;
    FArc := TUdArc(FSelObj).XData;
  end else

  if LSelObj.InheritsFrom(TUdCircle) then
  begin
    FSelObj := LSelObj;
    FArc := Arc2D(TUdCircle(FSelObj).Center, TUdCircle(FSelObj).Radius, 0, 360);
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
        FArc := LSegarcs[I].Arc;
      end;
    end;
  end;

  if Assigned(FSelObj) then
  begin
    Self.AddSelectedEntity(FSelObj);

    FDimObj.Center := FArc.Cen;
    FDimObj.ChordPoint := ShiftPoint(FArc.Cen, GetAngle(FArc.Cen, APnt), FArc.R);

    LLeaderLen := Distance(FDimObj.ChordPoint, APnt);
    if UdGeo2D.IsPntInCircle(APnt, Circle2D(FArc.Cen, FArc.R)) then LLeaderLen := -LLeaderLen;

    FDimObj.LeaderLen := LLeaderLen;
    FDimObj.Visible := True;


    Self.CanSnap    := True;
    Self.CanOSnap   := True;
    Self.CanOrtho   := True;
    Self.CanPerpend := True;

    Self.SetCursorStyle(csDraw);
    Self.Prompt(sRadialDimPntOrKeys, pkCmd);

    FStep := 1;
    Result := True;
  end
  else begin
    Self.Prompt(sSelArcOrPolyArc, pkLog);
  end;
end;


function TUdActionDimRadial.FSetChordPoint(APnt: TPoint2D): Boolean;
var
  LAng: Float;
  LLeaderLen: Float;
begin
  Result := False;

  LAng := GetAngle(FArc.Cen, APnt);
  if not UdMath.IsInAngles(LAng, FArc.Ang1, FArc.Ang2) then Exit;


  FDimObj.BeginUpdate();
  try
    FDimObj.Center := FArc.Cen;
    FDimObj.ChordPoint := ShiftPoint(FArc.Cen, LAng, FArc.R);

    LLeaderLen := Distance(FDimObj.ChordPoint, APnt);
    if UdGeo2D.IsPntInCircle(APnt, Circle2D(FArc.Cen, FArc.R)) then LLeaderLen := -LLeaderLen;

    FDimObj.LeaderLen := LLeaderLen;
  finally
    FDimObj.EndUpdate();
  end;

  Result := True;
end;

function TUdActionDimRadial.SetChordPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FSetChordPoint(APnt);

  FDimObj.Finished := True;
  Self.Submit(FDimObj);

  Self.Prompt(sRadialDimPntOrKeys, pkLog);
  Self.Prompt(sDimTextIs + #32 + FDimObj.GetDimText(FDimObj.Measurement, dtkArcLen), pkLog);

  FDimObj := nil;
  Result := Self.Finish();
end;


function TUdActionDimRadial.SetTextAngle(const AValue: Float): Boolean;
begin
  Result := False;
  if not (FStep in [2, 3]) then Exit;

  FDimObj.TextAngle := AValue;
  Self.Prompt(sDimTextAngle + AngleToStr(AValue), pkLog);

  Self.Prompt(sRadialDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionDimRadial.SetTextOverride(const AValue: string): Boolean;
begin
  Result := False;
  if FStep <> 4 then Exit;

  if AValue = '' then
  begin
    Self.Prompt(sEnterDimText + '<' + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal) + '>', pkLog);
  end
  else begin
    FDimObj.TextOverride := AValue;
    Self.Prompt(sEnterDimText + ' : ' + AValue, pkLog);
  end;

  Self.Prompt(sRadialDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;



function TUdActionDimRadial.SetAnglePoint1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 3;
  Result := True;
end;

function TUdActionDimRadial.SetAnglePoint2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FLine.EndPoint := APnt;
  FLine.Visible := False;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);

  Result := SetTextAngle(GetAngle(FLine.StartPoint, FLine.EndPoint));
end;



//---------------------------------------------------

function TUdActionDimRadial.Parse(const AValue: string): Boolean;
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
    if FStep = 2 then
    begin
      FLine.Visible := False;
      Self.Prompt(sRadialDimPntOrKeys, pkCmd);

      FStep := 1;
      Exit;
    end else
    if FStep = 4 then
    begin
      SetTextOverride('');
      Exit;
    end;

    Self.Prompt(sRequirePointOrKeyword, pkLog);
    Exit;
  end;

  if FStep in [2, 3] then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      if FStep = 2 then
      begin
        SetTextAngle(D);
      end else
      if FStep = 3 then
      begin
        LPnt := ShiftPoint(FLine.StartPoint, GetAngle(FLine.StartPoint, FLine.EndPoint), D);
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
        SetAnglePoint1(LPnt)
      else if FStep = 3 then
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
      FStep := 4;
      Self.Prompt(sEnterDimText + '<' + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal) + '>', pkCmd);
    end else

    if (LValue = 'a') or (LValue = 'angle') then
    begin
      FStep := 2;
      Self.Prompt(sDimTextAngle, pkCmd);
    end else

    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FLine.StartPoint.X + LPnt.X;
        LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
      end;
      SetChordPoint(LPnt);
    end

    else begin
      Self.Prompt(sRequirePointOrKeyword, pkLog);
      Result := False;
    end;
  end else
  if FStep = 4 then
  begin
    SetTextOverride(AValue);
  end;
end;


procedure TUdActionDimRadial.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionDimRadial.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
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
            SetChordPoint(ACoordPnt)
          else if FStep = 2 then
            SetAnglePoint1(ACoordPnt)
          else if FStep = 3 then
            SetAnglePoint2(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 1 then
        begin
           FSetChordPoint(ACoordPnt);
        end else
        if FStep = 3 then
        begin
          FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;




end.