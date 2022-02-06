{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimRotated;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdDimension, UdDimRotated;

type
  //*** TUdActionDimRotated ***//
  TUdActionDimRotated = class(TUdDimAction)
  private
    FLine: TUdLine;
    FDimObj: TUdDimRotated;

    FRotationBound: TPoint2DArray;

  protected
    function SetExtPoint1(APnt: TPoint2D): Boolean; // 0
    function SetExtPoint2(APnt: TPoint2D): Boolean; // 1
    function SetTextPoint(APnt: TPoint2D): Boolean; // 2
    function SetTextAngle(const AValue: Float): Boolean;  // 3, 4
    function SetRotation(const AValue: Float): Boolean;   // 5, 6
    function SetTextOverride(const AValue: string): Boolean; // 7

    function SetAnglePoint1(APnt: TPoint2D): Boolean;  // 3
    function SetAnglePoint2(APnt: TPoint2D): Boolean;  // 4

    function SetRotationPoint1(APnt: TPoint2D): Boolean; // 5
    function SetRotationPoint2(APnt: TPoint2D): Boolean; // 6

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


function FBoundHull(APnt1, APnt2: TPoint2D; Ang: Float): TPoint2DArray;
var
  LAng: Float;
  LLn11, LLn12: TLineK;
  LLn21, LLn22: TLineK;
begin
  LAng := UdMath.SgnAngle(GetAngle(APnt1, APnt2));
  if IsEqual(LAng, 0.0) or IsEqual(LAng, 90.0) then
  begin
    Result := nil;
    Exit; //=============>>>>>>>
  end;

  LLn11 := LineK(APnt1, Ang);
  LLn12 := LineK(APnt1, Ang+90);

  LLn21 := LineK(APnt2, Ang);
  LLn22 := LineK(APnt2, Ang+90);

  System.SetLength(Result, 5);
  Result[0] := APnt1;
  Result[1] := UdGeo2D.Intersection(LLn11, LLn22)[0];
  Result[2] := APnt2;
  Result[3] := UdGeo2D.Intersection(LLn21, LLn12)[0];

//  if IsEqual(Result[0], Result[1]) then
//  begin
//    Result[0] := ShiftPoint(Result[0], FixAngle(Ang), 1.0E-3);
//    Result[1] := ShiftPoint(Result[0], FixAngle(Ang+180), 1.0E-3);
//  end;
//
//  if IsEqual(Result[2], Result[3]) then
//  begin
//    Result[2] := ShiftPoint(Result[2], FixAngle(Ang), 1.0E-3);
//    Result[3] := ShiftPoint(Result[3], FixAngle(Ang+180), 1.0E-3);
//  end;

  Result[4] := APnt1;
end;


//=========================================================================================
{ TUdActionDimRotated }

class function TUdActionDimRotated.CommandName: string;
begin
  Result := 'dimlinear';
end;

constructor TUdActionDimRotated.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FDimObj := TUdDimRotated.Create(FDocument, False);
  FDimObj.Finished := False;
  FDimObj.Visible := False;

  FRotationBound := nil;
  Self.Prompt(sDimFirstExtOrgn, pkCmd);
end;

destructor TUdActionDimRotated.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FDimObj) then FDimObj.Free();

  inherited;
end;


//---------------------------------------------------

procedure TUdActionDimRotated.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FDimObj) and FDimObj.Visible then FDimObj.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionDimRotated.SetExtPoint1(APnt: TPoint2D): Boolean;
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

function TUdActionDimRotated.SetExtPoint2(APnt: TPoint2D): Boolean;
var
  LAng: Float;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FLine.EndPoint := APnt;

  if NotEqual(FLine.StartPoint, FLine.EndPoint) then
  begin
    FDimObj.ExtLine2Point := APnt;
    FDimObj.Visible := True;

    LAng := UdMath.SgnAngle(GetAngle(FDimObj.ExtLine1Point, FDimObj.ExtLine2Point));
    if IsEqual(LAng, 0.0) or IsEqual(LAng, 90.0) then
    begin
      FRotationBound := nil;
      if IsEqual(LAng, 0.0) then
        FDimObj.Rotation := 0
      else
        FDimObj.Rotation := 90;
    end
    else begin
      FRotationBound := FBoundHull(FDimObj.ExtLine1Point, FDimObj.ExtLine2Point, FDimObj.Rotation);
    end;

    FLine.Visible := False;

    Self.Prompt(sDimSecondExtOrgn + ': ' + PointToStr(APnt), pkLog);

    Self.SetPrevPoint(APnt);
    Self.Prompt(sDimLinePntOr, pkLog);
    Self.Prompt(sDimLineKeys1, pkCmd);

    FStep := 2;
    Result := True;
  end;
end;

function TUdActionDimRotated.SetTextPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FDimObj.TextPoint := APnt;
  FDimObj.Finished := True;
  Self.Submit(FDimObj);

  Self.Prompt(sDimLineKeys1, pkLog);
  Self.Prompt(sDimTextIs + #32 + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal), pkLog);

  FDimObj := nil;
  Result := Self.Finish();
end;



function TUdActionDimRotated.SetTextAngle(const AValue: Float): Boolean;
begin
  Result := False;
  if not (FStep in [3, 4]) then Exit;

  FDimObj.TextAngle := AValue;
  Self.Prompt(sDimTextAngle + AngleToStr(AValue), pkLog);

  Self.Prompt(sDimLinePntOr, pkLog);
  Self.Prompt(sDimLineKeys1, pkCmd);

  FStep := 2;
  Result := True;
end;

function TUdActionDimRotated.SetRotation(const AValue: Float): Boolean;
begin
  Result := False;
  if not (FStep in [5, 6]) then Exit;


  FDimObj.Rotation := AValue;
  FRotationBound := FBoundHull(FDimObj.ExtLine1Point, FDimObj.ExtLine2Point, FDimObj.Rotation);

  Self.Prompt(sEnterDimAngle + AngleToStr(AValue), pkLog);

  Self.Prompt(sDimLinePntOr, pkLog);
  Self.Prompt(sDimLineKeys1, pkCmd);

  FStep := 2;
  Result := True;
end;

function TUdActionDimRotated.SetTextOverride(const AValue: string): Boolean;
begin
  Result := False;
  if FStep <> 7 then Exit;

  if AValue = '' then
  begin
    Self.Prompt(sEnterDimText + '<' + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal) + '>', pkLog);
  end
  else begin
    FDimObj.TextOverride := AValue;
    Self.Prompt(sEnterDimText + ' : ' + AValue, pkLog);
  end;


  Self.Prompt(sDimLinePntOr, pkLog);
  Self.Prompt(sDimLineKeys1, pkCmd);

  FStep := 2;
  Result := True;
end;



function TUdActionDimRotated.SetAnglePoint1(APnt: TPoint2D): Boolean;
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

function TUdActionDimRotated.SetAnglePoint2(APnt: TPoint2D): Boolean;
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


function TUdActionDimRotated.SetRotationPoint1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 5 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 6;
  Result := True;
end;

function TUdActionDimRotated.SetRotationPoint2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 6 then Exit;

  FLine.EndPoint := APnt;
  FLine.Visible := False;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);

  Result := SetRotation(GetAngle(FLine.StartPoint, FLine.EndPoint));
end;



//---------------------------------------------------

function TUdActionDimRotated.Parse(const AValue: string): Boolean;
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
    if FStep in [3, 4, 5, 6] then
    begin
      FLine.Visible := False;
      Self.Prompt(sDimLinePntOr, pkLog);
      Self.Prompt(sDimLineKeys1, pkCmd);
      FStep := 2;
      Exit;
    end else
    if FStep = 7 then
    begin
      SetTextOverride('');
      Exit;
    end;

    Self.Prompt(sRequirePointOrKeyword, pkLog);
    Exit;
  end;

  if FStep in [0, 1, 3, 4, 5, 6] then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      if FStep in [3, 5] then
      begin
        if FStep = 3 then SetTextAngle(D) else SetRotation(D);
      end else
      if FStep in [1, 4, 6] then
      begin
        LPnt := ShiftPoint(FLine.StartPoint, GetAngle(FLine.StartPoint, FLine.EndPoint), D);
        if FStep = 1 then
          SetExtPoint2(LPnt)
        else if FStep = 4 then
          SetAnglePoint2(LPnt)
        else
          SetRotationPoint2(LPnt);
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
      end else
      if FStep = 5 then
        SetRotationPoint1(LPnt)
      else if FStep = 6 then
      begin
        if LIsOpp then
        begin
          LPnt.X := FLine.StartPoint.X + LPnt.X;
          LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
        end;
        SetRotationPoint2(LPnt);
      end;
    end

    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end else

  if FStep = 2 then
  begin
    if (LValue = 'h') or (LValue = 'horizontal') then
    begin
      FDimObj.Rotation := 0;
      FRotationBound := FBoundHull(FDimObj.ExtLine1Point, FDimObj.ExtLine2Point, FDimObj.Rotation);

      Self.Prompt(sDimLineKeys1 + ':' + AValue, pkLog);
    end else
    if (LValue = 'v') or (LValue = 'vertical') then
    begin
      FDimObj.Rotation := 90;
      FRotationBound := FBoundHull(FDimObj.ExtLine1Point, FDimObj.ExtLine2Point, FDimObj.Rotation);

      Self.Prompt(sDimLineKeys1 + ':' + AValue, pkLog);
    end else

    if (LValue = 'a') or (LValue = 'angle') then
    begin
      FStep := 3;
      Self.Prompt(sDimTextAngle, pkCmd);
    end else
    if (LValue = 'r') or (LValue = 'rotated') then
    begin
      FStep := 5;
      Self.Prompt(sEnterDimAngle, pkCmd);
    end else
    if (LValue = 't') or (LValue = 'text') then
    begin
      FStep := 7;
      Self.Prompt(sEnterDimText + '<' + FDimObj.GetDimText(FDimObj.Measurement, dtkNormal) + '>', pkCmd);
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
  if FStep = 7 then
  begin
    SetTextOverride(AValue);
  end;
end;


procedure TUdActionDimRotated.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionDimRotated.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  N: Integer;
  LAng: Float;
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
            SetAnglePoint2(ACoordPnt)
          else if FStep = 5 then
            SetRotationPoint1(ACoordPnt)
          else if FStep = 6 then
            SetRotationPoint2(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 2 then
        begin
          if (Length(FRotationBound) > 0) and not UdGeo2D.IsPntInPolygon(ACoordPnt, FRotationBound) then
          begin
            LAng := SgnAngle( GetAngle(FRotationBound[0], FRotationBound[1]) );

            if IsEqual(FDimObj.Rotation, LAng, 1) then
            begin
              UdGeo2D.ClosestSegmentPoint(ACoordPnt, Segment2D(FRotationBound[1], FRotationBound[2]), N);
              if N = 0 then FDimObj.Rotation := SgnAngle(FDimObj.Rotation + 90);

              if N <> 0 then
              begin
                UdGeo2D.ClosestSegmentPoint(ACoordPnt, Segment2D(FRotationBound[0], FRotationBound[3]), N);
                if N = 0 then FDimObj.Rotation := SgnAngle(FDimObj.Rotation + 90);
              end;

              if N = 0 then
                FRotationBound := FBoundHull(FDimObj.ExtLine1Point, FDimObj.ExtLine2Point, FDimObj.Rotation);
            end
            else begin
              UdGeo2D.ClosestSegmentPoint(ACoordPnt, Segment2D(FRotationBound[0], FRotationBound[1]), N);
              if N = 0 then FDimObj.Rotation := SgnAngle(FDimObj.Rotation - 90);

              if N <> 0 then
              begin
                UdGeo2D.ClosestSegmentPoint(ACoordPnt, Segment2D(FRotationBound[2], FRotationBound[3]), N);
                if N = 0 then FDimObj.Rotation := SgnAngle(FDimObj.Rotation - 90);
              end;

              if N = 0 then
                FRotationBound := FBoundHull(FDimObj.ExtLine1Point, FDimObj.ExtLine2Point, FDimObj.Rotation);
            end;
          end;

          FDimObj.TextPoint := ACoordPnt;
        end else
        if FStep in [1, 4, 6] then
        begin
          FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;




end.