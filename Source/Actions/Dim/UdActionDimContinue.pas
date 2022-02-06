{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimContinue;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdAction, UdBaseActions,
  UdEntity, UdDimension;

type
  //*** TUdActionDimContinue ***//
  TUdActionDimContinue = class(TUdDimAction)
  private
    FSide: Integer;
    FExtPnt: TPoint2D;
    FIsArc: Boolean;
    FDimArc: TArc2D;
    FDimLine: TLine2D;

    FSelDimObj: TUdDimension;
    FNewDimObj: TUdDimension;

    FDimObjList: TList;

  protected
    function CalcAngular(ADimObj: TUdEntity; APnt: TPoint2D): Boolean;

    function SelectBaseDim(APnt: TPoint2D): Boolean;
    function CreateNewDimObj():TUdDimension;

    function FSetExtLine2Point(APnt: TPoint2D): Boolean;
    function SetExtLine2Point(APnt: TPoint2D): Boolean;

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
  UdGeo2D, UdMath, UdUtils, UdAcnConsts,
  UdDimAligned, UdDimRotated, UdDim2LineAngular, UdDim3PointAngular;



//=========================================================================================
{ TUdActionDimContinue }

class function TUdActionDimContinue.CommandName: string;
begin
  Result := 'dimcontinue';
end;

constructor TUdActionDimContinue.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FSelDimObj := nil;
  FNewDimObj := nil;

  FDimObjList := TList.Create;
  Self.Prompt(sSelBaseDim, pkCmd);

  FSide := -1;
  FDimLine := Line2D(0,0, 0,0);

  FIsArc := False;
  FDimArc := Arc2D(0, 0, -1, 0, 0);
  FExtPnt := Point2D(0, 0);

  Self.CanSnap := False;
  Self.CanOSnap := False;
  Self.CanOrtho := false;
  Self.SetCursorStyle(csPick);
end;

destructor TUdActionDimContinue.Destroy;
begin
  FDimObjList.Free;

  FSelDimObj := nil;
  if Assigned(FNewDimObj) then FNewDimObj.Free;

  inherited;
end;


//---------------------------------------------------

procedure TUdActionDimContinue.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FNewDimObj) and FNewDimObj.Visible then FNewDimObj.Draw(ACanvas);
  end;
end;


function TUdActionDimContinue.CalcAngular(ADimObj: TUdEntity; APnt: TPoint2D): Boolean;
var
  LAng: Float;
  LDimPnt: TPoint2D;
  LP1, LP2: TPoint2D;
begin
  Result := True;
  if not Assigned(ADimObj) or
     not (ADimObj.InheritsFrom(TUdDim2LineAngular) or ADimObj.InheritsFrom(TUdDim3PointAngular)) then Exit;


  if ADimObj.InheritsFrom(TUdDim2LineAngular) then
    FDimArc := TUdDim2LineAngular(ADimObj).GetDimArc()
  else
    FDimArc := TUdDim3PointAngular(ADimObj).GetDimArc();

  LAng := GetAngle(FDimArc.Cen, APnt);
  if UdMath.IsInAngles(LAng, FDimArc.Ang1, FDimArc.Ang2) then
  begin
    if FixAngle(LAng - FDimArc.Ang1) < FixAngle(FDimArc.Ang2 - LAng) then
      FSide := 1 else FSide := 2;
  end
  else begin
    if FixAngle(FDimArc.Ang1 - LAng) < FixAngle(LAng - FDimArc.Ang2) then
      FSide := 1 else FSide := 2;
  end;


  if ADimObj.InheritsFrom(TUdDim2LineAngular) then
  begin
    if FSide = 1 then
      LDimPnt := ShiftPoint(FDimArc.Cen, FDimArc.Ang1, FDimArc.R)
    else
      LDimPnt := ShiftPoint(FDimArc.Cen, FDimArc.Ang2, FDimArc.R);

    with TUdDim2LineAngular(ADimObj) do
    begin
      if DistanceToLine(LDimPnt, Line2D(ExtLine1StartPoint, ExtLine1EndPoint)) <
         DistanceToLine(LDimPnt, Line2D(ExtLine2StartPoint, ExtLine2EndPoint)) then
      begin
        LP1 := ExtLine1EndPoint;
        LP2 := ExtLine1EndPoint;
      end
      else begin
        LP1 := ExtLine2EndPoint;
        LP2 := ExtLine2EndPoint;
      end;
    end;

    if IsEqual(GetAngle(LDimPnt, LP1),  GetAngle(LDimPnt, LP2), 1) then
    begin
      if Distance(LDimPnt, LP1) < Distance(LDimPnt, LP2) then
        FExtPnt := LP1
      else
        FExtPnt := LP2;
    end
    else begin
      if IsEqual(GetAngle(FDimArc.Cen, LDimPnt), GetAngle(LDimPnt, LP1), 1) then
        FExtPnt := LP1
      else
        FExtPnt := LP2;
    end;
  end
  else begin
    FDimArc := TUdDim3PointAngular(ADimObj).GetDimArc();

    if FSide = 1 then
      FExtPnt := TUdDim3PointAngular(ADimObj).ExtLine1Point
    else
      FExtPnt := TUdDim3PointAngular(ADimObj).ExtLine2Point;
  end;

  Result := True;
end;


function TUdActionDimContinue.SelectBaseDim(APnt: TPoint2D): Boolean;
var
  LSelObj: TUdEntity;
begin
  Result := False;
  if FStep <> 0 then Exit;


  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) or
     not (LSelObj.InheritsFrom(TUdDimAligned) or {LSelObj.InheritsFrom(TUdDimRotated) or}
          LSelObj.InheritsFrom(TUdDim2LineAngular) or LSelObj.InheritsFrom(TUdDim3PointAngular)) then
  begin
    Self.Prompt(sNeedLnOrAngDim, pkLog);
    Exit;  //========>>>>>
  end;


  FIsArc := False;

  if LSelObj.InheritsFrom(TUdDimAligned) then
  begin
    if Distance(APnt, TUdDimAligned(LSelObj).DimLine1Point) <
       Distance(APnt, TUdDimAligned(LSelObj).DimLine2Point) then
    begin
      FSide := 1;
      FExtPnt := TUdDimAligned(LSelObj).ExtLine1Point;
    end
    else begin
      FSide := 2;
      FExtPnt := TUdDimAligned(LSelObj).ExtLine2Point;
    end;

    FDimLine := Line2D(TUdDimAligned(LSelObj).DimLine1Point, TUdDimAligned(LSelObj).DimLine2Point);
  end
  else begin
    FIsArc := True;
    Self.CalcAngular(LSelObj, APnt);
  end;

  FSelDimObj := TUdDimension(LSelObj);
  Self.AddSelectedEntity(FSelDimObj);

  FNewDimObj := CreateNewDimObj();
  FSetExtLine2Point(APnt);

  Self.SetCursorStyle(csDraw);
  Self.CanSnap := True;
  Self.CanOSnap := True;

  FStep := 1;
  Result := True;
end;

function TUdActionDimContinue.CreateNewDimObj():TUdDimension;
begin
  if FIsArc then
  begin
    Result := TUdDim3PointAngular.Create(FDocument, False);
    TUdDim3PointAngular(Result).CenterPoint := FDimArc.Cen;
  end
  else begin
    Result := TUdDimRotated.Create(FDocument, False);
    TUdDimRotated(Result).Rotation := TUdDimAligned(FSelDimObj).GetRotation();
    TUdDimRotated(Result).ExtLine1Point := FExtPnt;
  end;

  Result.Finished := False;
  Result.Visible := True;
end;


function TUdActionDimContinue.FSetExtLine2Point(APnt: TPoint2D): Boolean;
var
  LAng, LArcAng: Float;
  LArcPnt: TPoint2D;
  LTextPnt: TPoint2D;
begin
  if FIsArc then
  begin
    LAng := GetAngle(FDimArc.Cen, APnt);
    LArcPnt := ShiftPoint(FDimArc.Cen, LAng, FDimArc.R);

    FNewDimObj.BeginUpdate();
    try
      if UdMath.IsInAngles(LAng, FDimArc.Ang1, FDimArc.Ang2) then
      begin
        if FSide = 1 then
        begin
          TUdDim3PointAngular(FNewDimObj).ExtLine1Point := FExtPnt;
          TUdDim3PointAngular(FNewDimObj).ExtLine2Point := APnt;
        end
        else begin
          TUdDim3PointAngular(FNewDimObj).ExtLine1Point := APnt;
          TUdDim3PointAngular(FNewDimObj).ExtLine2Point := FExtPnt;
        end;
      end
      else begin
        if FSide = 1 then LArcAng := FDimArc.Ang1 else LArcAng := FDimArc.Ang2;

        if FixAngle(LAng - LArcAng) <= 180 then
        begin
          TUdDim3PointAngular(FNewDimObj).ExtLine1Point := FExtPnt;
          TUdDim3PointAngular(FNewDimObj).ExtLine2Point := APnt;
        end
        else begin
          TUdDim3PointAngular(FNewDimObj).ExtLine1Point := APnt;
          TUdDim3PointAngular(FNewDimObj).ExtLine2Point := FExtPnt;
        end;
      end;

      TUdDim3PointAngular(FNewDimObj).ArcPoint := LArcPnt;
    finally
      FNewDimObj.EndUpdate();
    end;

  end
  else begin
    LTextPnt := ClosestLinePoint(APnt, FDimLine);

    FNewDimObj.BeginUpdate();
    try
      TUdDimAligned(FNewDimObj).ExtLine2Point := APnt;
      TUdDimAligned(FNewDimObj).TextPoint := LTextPnt;
    finally
      FNewDimObj.EndUpdate();
    end;
  end;

  Result := True;
end;


function TUdActionDimContinue.SetExtLine2Point(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FSetExtLine2Point(APnt);
  FNewDimObj.Finished := True;
  Self.Submit(FNewDimObj);


  if FIsArc then
  begin
    CalcAngular(FNewDimObj, APnt);
  end
  else begin
    FSide := 2;
    FExtPnt := TUdDimAligned(FNewDimObj).ExtLine2Point;
    FDimLine := Line2D(TUdDimAligned(FNewDimObj).DimLine1Point, TUdDimAligned(FNewDimObj).DimLine2Point);
  end;

  FNewDimObj := CreateNewDimObj();
  FSetExtLine2Point(APnt);

  Result := True;
end;




//---------------------------------------------------


function TUdActionDimContinue.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));
  if LValue = '' then
  begin
    Self.Finish();
    Exit;
  end;

  if FStep = 0 then
  begin
    if ParseCoord(LValue, LPnt, LIsOpp) then
      Result := Self.SelectBaseDim(LPnt)
    else
      Self.Prompt(sInvalidSelection, pkLog);
  end

  else if FStep = 1 then
  begin
    if ParseCoord(LValue, LPnt, LIsOpp) then
      Result := Self.SetExtLine2Point(LPnt);
  end;
end;



procedure TUdActionDimContinue.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionDimContinue.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SelectBaseDim(ACoordPnt)
          else if FStep = 1 then
            SetExtLine2Point(ACoordPnt);
        end
        else if (AButton = mbRight) then
        begin
          Self.Finish();
        end;
      end;
    mkMouseMove:
      begin
        if (FStep = 1) then
        begin
          FSetExtLine2Point(ACoordPnt);
        end;
      end;
  end;
end;





end.