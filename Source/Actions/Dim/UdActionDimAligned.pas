{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimAligned;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdDimension, UdDimAligned;

type
  //*** TUdActionDimAligned ***//
  TUdActionDimAligned = class(TUdDimAction)
  private
    FLine: TUdLine;
    FDimObj: TUdDimAligned;

  protected
    function SetExtPoint1(APnt: TPoint2D): Boolean;     // 0
    function SetExtPoint2(APnt: TPoint2D): Boolean;     // 1
    function SetTextPoint(APnt: TPoint2D): Boolean;     // 2
    function SetTextAngle(const AValue: Float): Boolean;      // 3, 4
    function SetTextOverride(const AValue: string): Boolean;  // 6

    function SetAnglePoint1(APnt: TPoint2D): Boolean;   // 3
    function SetAnglePoint2(APnt: TPoint2D): Boolean;   // 4


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
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;


//=========================================================================================
{ TUdActionDimAligned }

class function TUdActionDimAligned.CommandName: string;
begin
  Result := 'dimaligned';
end;

constructor TUdActionDimAligned.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FDimObj := TUdDimAligned.Create(FDocument, False);
  FDimObj.Finished := False;
  FDimObj.Visible := False;

  Self.Prompt(sDimFirstExtOrgn, pkCmd);
end;

destructor TUdActionDimAligned.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FDimObj) then FDimObj.Free();

  inherited;
end;


//---------------------------------------------------

procedure TUdActionDimAligned.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FDimObj) and FDimObj.Visible then FDimObj.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionDimAligned.SetExtPoint1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FDimObj.ExtLine1Point := APnt;


  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sDimFirstExtOrgn + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sDimSecondExtOrgn, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionDimAligned.SetExtPoint2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FLine.EndPoint := APnt;

  if NotEqual(FLine.StartPoint, FLine.EndPoint) then
  begin
    FDimObj.ExtLine2Point := APnt;
    FDimObj.Visible := True;

    FLine.Visible := False;

    Self.Prompt(sDimSecondExtOrgn + ': ' + PointToStr(APnt), pkLog);

    Self.SetPrevPoint(APnt);
    Self.Prompt(sDimLinePntOr, pkLog);
    Self.Prompt(sDimLineKeys2, pkCmd);

    FStep := 2;
    Result := True;
  end;
end;

function TUdActionDimAligned.SetTextPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FDimObj.TextPoint := APnt;
  FDimObj.Finished := True;
  Self.Submit(FDimObj);

  Self.Prompt(sDimLineKeys2, pkLog);
  Self.Prompt(sDimTextIs + #32 + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal), pkLog);

  FDimObj := nil;
  Result := Self.Finish();
end;



function TUdActionDimAligned.SetTextAngle(const AValue: Float): Boolean;
begin
  Result := False;
  if not (FStep in [3, 4]) then Exit;

  FDimObj.TextAngle := AValue;
  Self.Prompt(sDimTextAngle + AngleToStr(AValue), pkLog);

  Self.Prompt(sDimLinePntOr, pkLog);
  Self.Prompt(sDimLineKeys2, pkCmd);

  FStep := 2;
  Result := True;
end;

function TUdActionDimAligned.SetTextOverride(const AValue: string): Boolean;
begin
  Result := False;
  if FStep <> 5 then Exit;

  if AValue = '' then
  begin
    Self.Prompt(sEnterDimText + '<' + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal) + '>', pkLog);
  end
  else begin
    FDimObj.TextOverride := AValue;
    Self.Prompt(sEnterDimText + ' : ' + AValue, pkLog);
  end;


  Self.Prompt(sDimLinePntOr, pkLog);
  Self.Prompt(sDimLineKeys2, pkCmd);

  FStep := 2;
  Result := True;
end;



function TUdActionDimAligned.SetAnglePoint1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 4;
  Result := True;
end;

function TUdActionDimAligned.SetAnglePoint2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 4 then Exit;

  FLine.EndPoint := APnt;
  FLine.Visible := False;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);

  Result := SetTextAngle(GetAngle(FLine.StartPoint, FLine.EndPoint));
end;



//---------------------------------------------------

function TUdActionDimAligned.Parse(const AValue: string): Boolean;
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
    if FStep <= 2 then
    begin
      Self.Finish();
      Exit;
    end else
    if FStep = 3 then
    begin
      FLine.Visible := False;
      Self.Prompt(sDimLinePntOr, pkLog);
      Self.Prompt(sDimLineKeys2, pkCmd);
      FStep := 2;
      Exit;
    end else
    if FStep = 5 then
    begin
      SetTextOverride('');
      Exit;
    end;

    Self.Prompt(sRequirePointOrKeyword, pkLog);
    Exit;
  end;

  if FStep in [0, 1, 3, 4] then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      if FStep = 3 then
      begin
        SetTextAngle(D);
      end else
      if FStep in [1, 4] then
      begin
        LPnt := ShiftPoint(FLine.StartPoint, GetAngle(FLine.StartPoint, FLine.EndPoint), D);
        if FStep = 1 then
          SetExtPoint2(LPnt)
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
      if FStep = 0 then
        SetExtPoint1(LPnt)
      else if FStep = 1 then
      begin
        if LIsOpp then
        begin
          LPnt.X := FLine.StartPoint.X + LPnt.X;
          LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
        end;
        SetExtPoint2(LPnt);
      end else
      if FStep = 3 then
        SetAnglePoint1(LPnt)
      else if FStep = 4 then
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

  if FStep = 2 then
  begin
    if (LValue = 't') or (LValue = 'text') then
    begin
      FStep := 5;
      Self.Prompt(sEnterDimText + '<' + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal) + '>', pkCmd);
    end else

    if (LValue = 'a') or (LValue = 'angle') then
    begin
      FStep := 3;
      Self.Prompt(sDimTextAngle, pkCmd);
    end else

    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FLine.StartPoint.X + LPnt.X;
        LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
      end;
      SetTextPoint(LPnt);
    end

    else begin
      Self.Prompt(sRequirePointOrKeyword, pkLog);
      Result := False;
    end;
  end else
  if FStep = 5 then
  begin
    SetTextOverride(AValue);
  end;
end;


procedure TUdActionDimAligned.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionDimAligned.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetExtPoint1(ACoordPnt)
          else if FStep = 1 then
            SetExtPoint2(ACoordPnt)
          else if FStep = 2 then
            SetTextPoint(ACoordPnt)
          else if FStep = 3 then
            SetAnglePoint1(ACoordPnt)
          else if FStep = 4 then
            SetAnglePoint2(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 2 then
        begin
          FDimObj.TextPoint := ACoordPnt;
        end else
        if FStep in [1, 4] then
        begin
          FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;





end.