{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimOrdinate;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdDimension, UdDimOrdinate;

type
  //*** TUdActionDimOrdinate ***//
  TUdActionDimOrdinate = class(TUdDimAction)
  private
    FDatum: Integer;
    FCurPnt: TPoint2D;

    FLine: TUdLine;
    FDimObj: TUdDimOrdinate;

  protected
    function FSetLeaderEndPoint(APnt: TPoint2D): Boolean;
    
    function SetDefinitionPoint(APnt: TPoint2D): Boolean;  // 0
    function SetLeaderEndPoint(APnt: TPoint2D): Boolean;   // 1

    function SetTextAngle(const AValue: Float): Boolean;        // 2, 3
    function SetTextOverride(const AValue: string): Boolean;    // 4

    function SetAnglePoint1(APnt: TPoint2D): Boolean;     // 2
    function SetAnglePoint2(APnt: TPoint2D): Boolean;     // 3

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
  UdGeo2D, UdUtils, UdAcnConsts;
  

//=========================================================================================
{ TUdActionDimOrdinate }

class function TUdActionDimOrdinate.CommandName: string;
begin
  Result := 'dimordinate';
end;

constructor TUdActionDimOrdinate.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FDimObj := TUdDimOrdinate.Create(FDocument, False);
  FDimObj.Finished := False;
  FDimObj.Visible := False;

  Self.CanPerpend := False;

  FDatum := 0;
  Self.Prompt(sFeaturePoint, pkCmd);
end;

destructor TUdActionDimOrdinate.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FDimObj) then FDimObj.Free();

  inherited;
end;



//---------------------------------------------------

procedure TUdActionDimOrdinate.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FDimObj) and FDimObj.Visible then FDimObj.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionDimOrdinate.SetDefinitionPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FDimObj.DefinitionPoint := APnt;
  FDimObj.Visible := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sLeaderEndPntOrKeys, pkCmd);
  
  FStep := 1;
  Result := True;
end;


function TUdActionDimOrdinate.FSetLeaderEndPoint(APnt: TPoint2D): Boolean;
var
  LDx, LDy: Float;
begin
  FDimObj.BeginUpdate();
  try
    FDimObj.LeaderEndPoint := APnt;
    
    if FDatum = 0 then
    begin
      LDx := Abs(APnt.X - FDimObj.DefinitionPoint.X);
      LDy := Abs(APnt.Y - FDimObj.DefinitionPoint.Y);
      FDimObj.UseXAxis := (LDx < LDy);
    end
    else begin
      FDimObj.UseXAxis := FDatum = 1;
    end;

    FDimObj.Visible := True;
  finally
    FDimObj.EndUpdate();
  end;

  Result := True;
end;

function TUdActionDimOrdinate.SetLeaderEndPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FSetLeaderEndPoint(APnt);
  FDimObj.Finished := True;
  Self.Submit(FDimObj);

  Self.Prompt(sLeaderEndPntOrKeys + ':' + PointToStr(APnt), pkLog);
  Self.Prompt(sDimTextIs + #32 + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal), pkLog);

  FDimObj := nil;
  Result := Finish();
end;


function TUdActionDimOrdinate.SetTextAngle(const AValue: Float): Boolean;
begin
  Result := False;
  if not (FStep in [2, 3]) then Exit;

  FDimObj.TextAngle := AValue;
  Self.Prompt(sDimTextAngle + AngleToStr(AValue), pkLog);

  Self.Prompt(sLeaderEndPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionDimOrdinate.SetTextOverride(const AValue: string): Boolean;
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

  Self.Prompt(sLeaderEndPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;  
end;



function TUdActionDimOrdinate.SetAnglePoint1(APnt: TPoint2D): Boolean;
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

function TUdActionDimOrdinate.SetAnglePoint2(APnt: TPoint2D): Boolean;
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

function TUdActionDimOrdinate.Parse(const AValue: string): Boolean;
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
    if FStep in [0, 1] then
    begin
      Self.Finish();
      Exit;
    end else
    if FStep = 2 then
    begin
      FLine.Visible := False;
      Self.Prompt(sLeaderEndPntOrKeys, pkCmd);

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

  if FStep = 0 then
  begin
    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      SetDefinitionPoint(LPnt)
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end else

  if FStep = 1 then
  begin
    if (LValue = 'x') or (LValue = 'xdatum') then
    begin
      FDatum := 1;
      Self.FSetLeaderEndPoint(FCurPnt);
      Self.Prompt(sLeaderEndPntOrKeys + ':' + AValue, pkCmd);
    end else

    if (LValue = 'y') or (LValue = 'ydatum') then
    begin
      FDatum := 2;
      Self.FSetLeaderEndPoint(FCurPnt);
      Self.Prompt(sLeaderEndPntOrKeys + ':' + AValue, pkCmd);
    end else
          
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
      Self.SetLeaderEndPoint(LPnt);
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


procedure TUdActionDimOrdinate.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionDimOrdinate.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetDefinitionPoint(ACoordPnt)
          else if FStep = 1 then
            SetLeaderEndPoint(ACoordPnt)
          else if FStep = 2 then
            SetAnglePoint1(ACoordPnt)
          else if FStep = 3 then
            SetAnglePoint2(ACoordPnt)
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        FCurPnt := ACoordPnt;
        case FStep of
          1: FSetLeaderEndPoint(ACoordPnt);
          3: FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;





end.