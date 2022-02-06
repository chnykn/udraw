{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimAngular;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdDimension;

type

  //*** TUdActionDimAngular ***//
  TUdActionDimAngular = class(TUdDrawAction)
  private
    FSeg1: TSegment2D;
    FSelObj1, FSelObj2: TUdEntity;

    FAction: TUdAction;

  protected
    function SelectObj1(APnt: TPoint2D): Boolean;
    function SelectObj2(APnt: TPoint2D): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;

    function Parse(const AValue: string): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;



implementation


uses
  SysUtils, UdArc, UdCircle, UdPolyline, UdDim2LineAngular, UdDim3PointAngular,
  UdGeo2D, UdUtils, UdAcnConsts;


//=========================================================================================
type


  //*** TUdActionDim3PointAngular ***//
  TUdActionDim3PointAngular = class(TUdDimAction)
  private
    FArc: TArc2D;

    FLine: TUdLine;
    FDimObj: TUdDim3PointAngular;

  protected
    function SetArcPoint(APnt: TPoint2D): Boolean;      // 1

    function SetTextAngle(const AValue: Float): Boolean;      // 2, 3
    function SetTextOverride(const AValue: string): Boolean;  // 4

    function SetAnglePoint1(APnt: TPoint2D): Boolean;   // 2
    function SetAnglePoint2(APnt: TPoint2D): Boolean;   // 3

    function SetCircleAng1Point(APnt: TPoint2D): Boolean; // 5
    function SetCircleAng2Point(APnt: TPoint2D): Boolean; // 6

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function Init(AArc: TArc2D; AIsCircle: Boolean): Boolean;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionDim2LineAngular ***//
  TUdActionDim2LineAngular = class(TUdDimAction)
  private
    FSeg1: TSegment2D;
    FSeg2: TSegment2D;

    FLine: TUdLine;
    FDimObj: TUdDim2LineAngular;

  protected
    function SetArcPoint(APnt: TPoint2D): Boolean;      // 1

    function SetTextAngle(const AValue: Float): Boolean;      // 2, 3
    function SetTextOverride(const AValue: string): Boolean;  // 4

    function SetAnglePoint1(APnt: TPoint2D): Boolean;   // 2
    function SetAnglePoint2(APnt: TPoint2D): Boolean;   // 3


  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function Init(ASeg1, ASeg2: TSegment2D): Boolean;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;






//========================================================================================


constructor TUdActionDim3PointAngular.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FArc := Arc2D(0, 0, 0, 0, 0);

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FDimObj := TUdDim3PointAngular.Create(FDocument, False);
  FDimObj.Finished := False;
  FDimObj.Visible := False;
end;

destructor TUdActionDim3PointAngular.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FDimObj) then FDimObj.Free();

  inherited;
end;


function TUdActionDim3PointAngular.Init(AArc: TArc2D; AIsCircle: Boolean): Boolean;
begin
  FArc := AArc;

  FDimObj.CenterPoint := FArc.Cen;
  if AIsCircle then
  begin
    FLine.StartPoint := FArc.Cen;
    FLine.EndPoint   := FArc.Cen;
    FLine.Visible := True;

    Self.Prompt(sSelectAngle1Pnt, pkCmd);
    FStep := 5;
  end
  else begin
    FDimObj.ExtLine1Point := ShiftPoint(FArc.Cen, FArc.Ang1, FArc.R);
    FDimObj.ExtLine2Point := ShiftPoint(FArc.Cen, FArc.Ang2, FArc.R);
    FDimObj.Visible := True;

    FStep := 1;
    Self.Prompt(sAngularDimPntOrKeys, pkCmd);
  end;

  Result := True;
end;


//---------------------------------------------------

procedure TUdActionDim3PointAngular.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FDimObj) and FDimObj.Visible then FDimObj.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionDim3PointAngular.SetArcPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FDimObj.ArcPoint := APnt;

  FDimObj.Finished := True;
  Self.Submit(FDimObj);

  Self.Prompt(sAngularDimPntOrKeys, pkLog);
  Self.Prompt(sDimTextIs + #32 + FDimObj.GetDimText(FDimObj.Measurement, dtkArcLen), pkLog);

  FDimObj := nil;
  Result := Self.Finish();
end;


function TUdActionDim3PointAngular.SetTextAngle(const AValue: Float): Boolean;
begin
  Result := False;
  if not (FStep in [2, 3]) then Exit;

  FDimObj.TextAngle := AValue;
  Self.Prompt(sDimTextAngle + AngleToStr(AValue), pkLog);

  Self.Prompt(sAngularDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionDim3PointAngular.SetTextOverride(const AValue: string): Boolean;
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

  Self.Prompt(sAngularDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;



function TUdActionDim3PointAngular.SetAnglePoint1(APnt: TPoint2D): Boolean;
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

function TUdActionDim3PointAngular.SetAnglePoint2(APnt: TPoint2D): Boolean;
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



function TUdActionDim3PointAngular.SetCircleAng1Point(APnt: TPoint2D): Boolean;  // 5
var
  LAng: Float;
  LPnt: TPoint2D;
begin
  Result := False;
  if FStep <> 5 then Exit;

  LAng := GetAngle(FArc.Cen, APnt);
  LPnt := ShiftPoint(FArc.Cen, LAng, FArc.R);

  FDimObj.ExtLine1Point := LPnt;

  FLine.StartPoint := FArc.Cen;
  FLine.EndPoint   := LPnt;

  Self.Prompt(sSelectAngle1Pnt + ':' + PointToStr(LPnt), pkLog);
  Self.Prompt(sSelectAngle2Pnt, pkCmd);

  FStep := 6;
  Result := True;
end;

function TUdActionDim3PointAngular.SetCircleAng2Point(APnt: TPoint2D): Boolean;  // 6
var
  LAng: Float;
  LPnt: TPoint2D;
begin
  Result := False;
  if FStep <> 6 then Exit;

  LAng := GetAngle(FArc.Cen, APnt);
  LPnt := ShiftPoint(FArc.Cen, LAng, FArc.R);

  FDimObj.ExtLine2Point := LPnt;
  FDimObj.Visible := True;

  FLine.Visible := False;

  Self.Prompt(sSelectAngle2Pnt + ':' + PointToStr(LPnt), pkLog);
  Self.Prompt(sAngularDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;




//---------------------------------------------------

function TUdActionDim3PointAngular.Parse(const AValue: string): Boolean;
var
  D: Double;
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
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
      Self.Prompt(sAngularDimPntOrKeys, pkCmd);

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

  if FStep in [2, 3, 5, 6] then
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
      end else
      if FStep = 6 then
      begin
        LPnt := ShiftPoint(FLine.StartPoint, GetAngle(FLine.StartPoint, FLine.EndPoint), D);
        SetCircleAng2Point(LPnt);
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
      end else

      if FStep = 5 then
        SetCircleAng1Point(LPnt)
      else if FStep = 6 then
      begin
        if LIsOpp then
        begin
          LPnt.X := FLine.StartPoint.X + LPnt.X;
          LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
        end;
        SetCircleAng2Point(LPnt);
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
      SetArcPoint(LPnt);
    end

    else begin
      Self.Prompt(sRequirePointOrKeyword, pkLog);
      Result := False;
    end;
  end else

  if FStep = 4 then
  begin
    SetTextOverride(AValue);
  end ;
end;


procedure TUdActionDim3PointAngular.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;
end;

procedure TUdActionDim3PointAngular.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LAng: Float;
  LPnt: TPoint2D;
  LGripPnt: TUdGripPoint;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 1 then
            SetArcPoint(ACoordPnt)
          else if FStep = 2 then
            SetAnglePoint1(ACoordPnt)
          else if FStep = 3 then
            SetAnglePoint2(ACoordPnt)
          else if FStep = 5 then
            SetCircleAng1Point(ACoordPnt)
          else if FStep = 6 then
            SetCircleAng2Point(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          FDimObj.BeginUpdate();
          try
            LGripPnt.Mode  := gmPoint;
            LGripPnt.Index := 3;
            LGripPnt.Point := ACoordPnt;
            FDimObj.MoveGrip(LGripPnt);

            FDimObj.Visible := True;
          finally
            FDimObj.EndUpdate();
          end;
        end else
        if FStep in [3, 5, 6] then
        begin
          FLine.EndPoint := ACoordPnt;
        end;

        if FStep = 6 then
        begin
          LAng := GetAngle(FArc.Cen, ACoordPnt);
          LPnt := ShiftPoint(FArc.Cen, LAng, FArc.R);

          FDimObj.BeginUpdate();
          try
            FDimObj.ExtLine2Point := LPnt;
            FDimObj.ArcPoint      := ACoordPnt;
            FDimObj.Visible := True;
          finally
            FDimObj.EndUpdate();
          end;

          FDimObj.Visible := True;
        end;
      end;
  end;
end;






//==================================================================================================
{ TUdActionDim2LineAngular }

constructor TUdActionDim2LineAngular.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FSeg1 := Segment2D(0,0, 0,0);
  FSeg2 := Segment2D(0,0, 0,0);

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FDimObj := TUdDim2LineAngular.Create(FDocument, False);
  FDimObj.Finished := False;
  FDimObj.Visible := False;
end;

destructor TUdActionDim2LineAngular.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FDimObj) then FDimObj.Free();

  inherited;
end;


function TUdActionDim2LineAngular.Init(ASeg1, ASeg2: TSegment2D): Boolean;
begin
  FSeg1 := ASeg1;
  FSeg2 := ASeg2;

  FDimObj.ExtLine1StartPoint := FSeg1.P1;
  FDimObj.ExtLine1EndPoint   := FSeg1.P2;

  FDimObj.ExtLine2StartPoint := FSeg2.P1;
  FDimObj.ExtLine2EndPoint   := FSeg2.P2;

  FDimObj.Visible := True;

  FStep := 1;
  Self.Prompt(sAngularDimPntOrKeys, pkCmd);

  Result := True;
end;



//---------------------------------------------------

procedure TUdActionDim2LineAngular.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FDimObj) and FDimObj.Visible then FDimObj.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionDim2LineAngular.SetArcPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FDimObj.ArcPoint := APnt;

  FDimObj.Finished := True;
  Self.Submit(FDimObj);

  Self.Prompt(sAngularDimPntOrKeys, pkLog);
  Self.Prompt(sDimTextIs + #32 + FDimObj.GetDimText(FDimObj.Measurement, dtkArcLen), pkLog);

  FDimObj := nil;
  Result := Self.Finish();
end;


function TUdActionDim2LineAngular.SetTextAngle(const AValue: Float): Boolean;
begin
  Result := False;
  if not (FStep in [2, 3]) then Exit;

  FDimObj.TextAngle := AValue;
  Self.Prompt(sDimTextAngle + AngleToStr(AValue), pkLog);

  Self.Prompt(sAngularDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionDim2LineAngular.SetTextOverride(const AValue: string): Boolean;
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

  Self.Prompt(sAngularDimPntOrKeys, pkCmd);

  FStep := 1;
  Result := True;
end;



function TUdActionDim2LineAngular.SetAnglePoint1(APnt: TPoint2D): Boolean;
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

function TUdActionDim2LineAngular.SetAnglePoint2(APnt: TPoint2D): Boolean;
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

function TUdActionDim2LineAngular.Parse(const AValue: string): Boolean;
var
  D: Double;
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
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
      Self.Prompt(sAngularDimPntOrKeys, pkCmd);

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
      SetArcPoint(LPnt);
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


procedure TUdActionDim2LineAngular.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;
end;

procedure TUdActionDim2LineAngular.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LGripPnt: TUdGripPoint;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 1 then
            SetArcPoint(ACoordPnt)
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
          LGripPnt.Mode  := gmPoint;
          LGripPnt.Index := 4;
          LGripPnt.Point := ACoordPnt;

          FDimObj.MoveGrip(LGripPnt);
          FDimObj.Visible := True;
        end else
        if FStep = 3 then
        begin
          FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;







//========================================================================================
{ TUdActionDimAngular }

class function TUdActionDimAngular.CommandName: string;
begin
  Result := 'dimangular';
end;

constructor TUdActionDimAngular.Create(ADocument, ALayout: TUdObject; Args: string = '');
//var
//  N: Integer;
//  LArg: string;
begin
  inherited;

//  LArg := LowerCase(Trim(Args));
//
//  N := Pos(' ', LArg);
//  if N > 0 then Delete(LArg, N, System.Length(LArg));


  FSelObj1 := nil;
  FSelObj2 := nil;

  FAction := nil;

  Self.CanSnap    := False;
  Self.CanOSnap   := False;
  Self.CanOrtho   := False;
  Self.CanPerpend := False;

  Self.Prompt(sSelectArcCirLine, pkCmd);
  Self.SetCursorStyle(csPick)
end;

destructor TUdActionDimAngular.Destroy;
begin
  FSelObj1 := nil;
  FSelObj2 := nil;

  if Assigned(FAction) then FAction.Free;
  inherited;
end;




function TUdActionDimAngular.SelectObj1(APnt: TPoint2D): Boolean;
var
  I: Integer;
  E: Float;
  LArc: TArc2D;
  LIsArc: Boolean;
  LIsCir: Boolean;
  LSelObj: TUdEntity;
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if FStep <> 0 then Exit;

  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) then
  begin
    Self.Prompt(sSelectArcCirLine, pkLog);
    Exit; //==========>>>>>
  end;

  LIsArc := False;
  LIsCir := False;

  if LSelObj.InheritsFrom(TUdArc) then
  begin
    FSelObj1 := LSelObj;
    LArc := TUdArc(LSelObj).XData;
    LIsArc := True;
  end else

  if LSelObj.InheritsFrom(TUdCircle) then
  begin
    FSelObj1 := LSelObj;
    LArc := Arc2D(TUdCircle(LSelObj).Center, TUdCircle(LSelObj).Radius, 0, 360);
    LIsArc := True;
    LIsCir := True;
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
        FSelObj1 := LSelObj;
        LArc := LSegarcs[I].Arc;
        LIsArc := True;

        Break;
      end else
      if not LSegarcs[I].IsArc and
         UdGeo2D.IsPntOnSegment(APnt, LSegarcs[I].Seg, E) then
      begin
        FSelObj1 := LSelObj;
        FSeg1 := LSegarcs[I].Seg;
        LIsArc := False;

        Break;
      end else
    end;
  end else

  if LSelObj.InheritsFrom(TUdLine) then
  begin
    FSelObj1 := LSelObj;
    FSeg1 := TUdLine(LSelObj).XData;
    LIsArc := False;
  end;


  if Assigned(FSelObj1) then
  begin
    if LIsArc then
    begin
      FAction := TUdActionDim3PointAngular.Create(FDocument, FLayout);
      TUdActionDim3PointAngular(FAction).Init(LArc, LIsCir);
    end
    else
      Self.Prompt(sSelectSecondLine, pkCmd);

    Self.AddSelectedEntity(FSelObj1);

    FStep := 1;
    Result := True;
  end
  else begin
    Self.Prompt(sSelectArcCirLine, pkLog);
  end;
end;

function TUdActionDimAngular.SelectObj2(APnt: TPoint2D): Boolean;
var
  I: Integer;
  E: Float;
  LSeg: TSegment2D;
  LSelObj: TUdEntity;
  LFound: Boolean;
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if FStep <> 1 then Exit;


  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) then
  begin
    Self.Prompt(sSelectSecondLine, pkLog);
    Exit;    //==========>>>>>
  end;

  LFound := False;

  if LSelObj.InheritsFrom(TUdLine) then
  begin
    LSeg := TUdLine(LSelObj).XData;
    LFound := True;
  end else

  if LSelObj.InheritsFrom(TUdPolyline) and (TUdPolyline(LSelObj).SplineFlag = sfStandard) then
  begin
    E := DEFAULT_PICK_SIZE / Self.PixelPerValue();

    LSegarcs := TUdPolyline(LSelObj).XData;

    for I := 0 to System.Length(LSegarcs) - 1 do
    begin
      if not LSegarcs[I].IsArc and
         UdGeo2D.IsPntOnSegment(APnt, LSegarcs[I].Seg, E) then
      begin
        LSeg := LSegarcs[I].Seg;
        LFound := True;

        Break;
      end else
    end;
  end;

  if LFound then
  begin
    if UdGeo2D.IsParallel(FSeg1, LSeg) then
    begin
      Self.Prompt(sLinesParallel, pkLog);
    end
    else begin
      if LSelObj <> FSelObj1 then
      begin
        FSelObj2 := LSelObj;
        Self.AddSelectedEntity(FSelObj2);
      end;

      FAction := TUdActionDim2LineAngular.Create(FDocument, FLayout);
      TUdActionDim2LineAngular(FAction).Init(FSeg1, LSeg);
    end;
  end
  else begin
    Self.Prompt(sSelectSecondLine, pkLog);
  end;
end;


procedure TUdActionDimAngular.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FAction) then FAction.Paint(Sender, ACanvas);
end;

function TUdActionDimAngular.Parse(const AValue: string): Boolean;
begin
  Result := False;
  if not Assigned(FAction) then Exit; //=====>>>>

  Result := FAction.Parse(AValue);
end;


procedure TUdActionDimAngular.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FAction) then FAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionDimAngular.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  if Assigned(FAction) then
    FAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt)
  else begin
    if AKind = mkMouseDown then
    begin
      if (AButton = mbLeft) then
      begin
        if not Assigned(FSelObj1) then
          Self.SelectObj1(ACoordPnt)
        else
          Self.SelectObj2(ACoordPnt);
      end
      else if (AButton = mbRight) then
        Self.Finish();
    end;
  end;
end;






end.