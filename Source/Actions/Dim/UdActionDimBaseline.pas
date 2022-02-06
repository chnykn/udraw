{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimBaseline;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdAction, UdBaseActions,
  UdEntity, UdDimension;

type
  //*** TUdActionDimBaseline ***//
  TUdActionDimBaseline = class(TUdDimAction)
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
    function SelectBaseDim(APnt: TPoint2D): Boolean;
    function CreateNewDimObj():TUdDimension;

    function GetBaselineSpacing(): Float;
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
  UdLayout, UdGeo2D, UdMath, UdUtils, UdAcnConsts,
  UdDimAligned, UdDimRotated, UdDim2LineAngular, UdDim3PointAngular;



//=========================================================================================
{ TUdActionDimBaseline }

class function TUdActionDimBaseline.CommandName: string;
begin
  Result := 'dimbaseline';
end;

constructor TUdActionDimBaseline.Create(ADocument, ALayout: TUdObject; Args: string = '');
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

destructor TUdActionDimBaseline.Destroy;
begin
  FDimObjList.Free;

  FSelDimObj := nil;
  if Assigned(FNewDimObj) then FNewDimObj.Free;

  inherited;
end;


//---------------------------------------------------

procedure TUdActionDimBaseline.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FNewDimObj) and FNewDimObj.Visible then FNewDimObj.Draw(ACanvas);
  end;
end;



function TUdActionDimBaseline.SelectBaseDim(APnt: TPoint2D): Boolean;
var
  LAng: Float;
  LSelObj: TUdEntity;
  LLayout: TUdLayout;
  LP1, LP2: TPoint2D;
  LExtPnt, LDimPnt: TPoint2D;
begin
  Result := False;
  if FStep <> 0 then Exit;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //========>>>>>

  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) or
     not (LSelObj.InheritsFrom(TUdDimAligned) or {LSelObj.InheritsFrom(TUdDimRotated) or}
          LSelObj.InheritsFrom(TUdDim2LineAngular) or LSelObj.InheritsFrom(TUdDim3PointAngular)) then
  begin
    Self.Prompt(sNeedLnOrAngDim, pkLog);
    Exit;  //========>>>>>
  end;


  FIsArc := False;
  FDimArc := Arc2D(0, 0, -1, 0, 0);
  FDimLine := Line2D(0,0, 0,0);
  
  if LSelObj.InheritsFrom(TUdDimAligned) then
  begin
    if Distance(APnt, TUdDimAligned(LSelObj).DimLine1Point) <
       Distance(APnt, TUdDimAligned(LSelObj).DimLine2Point) then
    begin
      FSide := 1;
      LExtPnt := TUdDimAligned(LSelObj).ExtLine1Point;
    end
    else begin
      FSide := 2;
      LExtPnt := TUdDimAligned(LSelObj).ExtLine2Point;
    end;

    FDimLine := Line2D(TUdDimAligned(LSelObj).DimLine1Point, TUdDimAligned(LSelObj).DimLine2Point);
  end
  else begin
    FIsArc := True;
    
    if LSelObj.InheritsFrom(TUdDim2LineAngular) then
      FDimArc := TUdDim2LineAngular(LSelObj).GetDimArc()
    else
      FDimArc := TUdDim3PointAngular(LSelObj).GetDimArc();

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


    if LSelObj.InheritsFrom(TUdDim2LineAngular) then
    begin
      if FSide = 1 then
        LDimPnt := ShiftPoint(FDimArc.Cen, FDimArc.Ang1, FDimArc.R)
      else
        LDimPnt := ShiftPoint(FDimArc.Cen, FDimArc.Ang2, FDimArc.R);

      with TUdDim2LineAngular(LSelObj) do
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
        if Distance(LExtPnt, LP1) < Distance(LExtPnt, LP2) then
          LExtPnt := LP1
        else
          LExtPnt := LP2;
      end
      else begin
        if IsEqual(GetAngle(FDimArc.Cen, LDimPnt), GetAngle(LDimPnt, LP1), 1) then
          LExtPnt := LP1
        else
          LExtPnt := LP2;
      end;
    end
    else begin
      FDimArc := TUdDim3PointAngular(LSelObj).GetDimArc();

      if FSide = 1 then
        LExtPnt := TUdDim3PointAngular(LSelObj).ExtLine1Point
      else
        LExtPnt := TUdDim3PointAngular(LSelObj).ExtLine2Point;
    end;
  end;

  FExtPnt := LExtPnt;

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

function TUdActionDimBaseline.CreateNewDimObj():TUdDimension;
begin
  if FIsArc then
  begin
    Result := TUdDim3PointAngular.Create(FDocument, False);
    TUdDim3PointAngular(Result).CenterPoint := FDimArc.Cen;

    Result.Finished := False;
  end
  else begin
    Result := TUdDimRotated.Create(FDocument, False);
    TUdDimRotated(Result).Rotation := TUdDimAligned(FSelDimObj).GetRotation();

    TUdDimRotated(Result).ExtLine1Point := FExtPnt;
  end;

  Result.Finished := False;
  Result.Visible := True;
end;


function TUdActionDimBaseline.FSetExtLine2Point(APnt: TPoint2D): Boolean;
var
  LSpacing: Float;
  LAng, LArcAng: Float;
  LArcPnt: TPoint2D;
  LTextPnt: TPoint2D;
begin
  LSpacing := Self.GetBaselineSpacing();
  
  if FIsArc then
  begin
    LAng := GetAngle(FDimArc.Cen, APnt);
    LArcPnt := ShiftPoint(FDimArc.Cen, LAng, FDimArc.R + LSpacing);

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

    if NotEqual(LTextPnt, APnt) then
      LTextPnt := ShiftPoint(LTextPnt, GetAngle(APnt, LTextPnt), LSpacing)
    else
      LTextPnt := ShiftPoint(LTextPnt, GetAngle(FDimLine.P1, FDimLine.P2) + 90, LSpacing);

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


function TUdActionDimBaseline.GetBaselineSpacing(): Float;
begin
  Result := 3.75;
  if Assigned(Self.DimStyle) then
    Result := Self.DimStyle.LinesProp.BaselineSpacing
end;

function TUdActionDimBaseline.SetExtLine2Point(APnt: TPoint2D): Boolean;
var
  LSpacing: Float;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FSetExtLine2Point(APnt);
  FNewDimObj.Finished := True;
  Self.Submit(FNewDimObj);

  LSpacing := Self.GetBaselineSpacing();

  if FIsArc then
    FDimArc.R := FDimArc.R + LSpacing
  else
    FDimLine := Line2D(TUdDimAligned(FNewDimObj).DimLine1Point, TUdDimAligned(FNewDimObj).DimLine2Point);

  FNewDimObj := CreateNewDimObj();
  FSetExtLine2Point(APnt);

  Result := True;
end;




//---------------------------------------------------


function TUdActionDimBaseline.Parse(const AValue: string): Boolean;
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



procedure TUdActionDimBaseline.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionDimBaseline.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
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