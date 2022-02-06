{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionPolygon;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdPolyline;

type
  //*** TUdActionPolygon ***//
  TUdActionPolygon = class(TUdDrawAction)
  private
    FP1, FP2: TPoint2D;
    FLine: TUdLine;
    FPolygon: TUdPolyline;

  protected
    function UpdateEntities(): Boolean;

    function SetSideNum(): Boolean;
    function SetCenter(APnt: TPoint2D): Boolean;
    function SetInscribed(AValue: string): Boolean;
    function SetRadius(APnt: TPoint2D): Boolean; overload;
    function SetRadius(AValue: Float): Boolean; overload;

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
  
var
  GPolygonSideNumber: Integer = 4;
  GPolylineWidth: Float = 0.0;
  GPolygonInscribed: string = 'I';



//=========================================================================================
{ TUdActionPolygon }

class function TUdActionPolygon.CommandName: string;
begin
  Result := 'polygon';
end;

constructor TUdActionPolygon.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FPolygon := TUdPolyline.Create(FDocument, False);
  FPolygon.Finished := False;
  FPolygon.Visible := False;
  FPolygon.Closed := True;
  FPolygon.Color.TrueColor := Self.GetDefColor();

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;
  FLine.Color.TrueColor := Self.GetDefColor();

  Self.CanOrtho   := False;
  Self.CanPerpend := False;
  Self.CanSnap    := False;
  Self.CanOSnap   := False;

  Self.Prompt(sSideNumber + ' <' + IntToStr(GPolygonSideNumber) + '>', pkCmd);
end;

destructor TUdActionPolygon.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FPolygon) then FPolygon.Free;
  inherited;
end;


procedure TUdActionPolygon.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FPolygon) and FPolygon.Visible then FPolygon.Draw(ACanvas);
  end;
end;




//----------------------------------------------------------------------

function TUdActionPolygon.SetSideNum(): Boolean;
begin
  Result := True;
  Self.Prompt(sSideNumber + ': ' + IntToStr(GPolygonSideNumber), pkLog);
  Self.Prompt(sPolygonCenter, pkCmd);
  FStep := 1;

  Self.CanSnap    := True;
  Self.CanOSnap   := True;
end;

function TUdActionPolygon.SetCenter(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sPolygonCenter + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sPolygonOption + ' <' + GPolygonInscribed + '>', pkCmd);

  FP1 := APnt;
  FP2 := APnt;

  Self.CanOrtho := True;

  FStep := 2;
  Result := True;

  Self.CanSnap    := False;
  Self.CanOSnap   := False;
end;

function TUdActionPolygon.SetInscribed(AValue: string): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  Self.SetPrevPoint(FP1);

  if Trim(AValue) = '' then AValue := GPolygonInscribed;
  GPolygonInscribed := AValue;

  Self.Prompt(sPolygonOption + ': ' + GPolygonInscribed, pkLog);
  Self.Prompt(sCircleRadius, pkCmd);

  FStep := 3;
  Result := UpdateEntities();

  Self.CanOrtho   := True;
  Self.CanPerpend := True;
  Self.CanSnap    := True;
  Self.CanOSnap   := True;
end;



function TUdActionPolygon.SetRadius(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 3) or IsEqual(APnt, FP1) then Exit;

  FP2 := APnt;
  UpdateEntities();
  FPolygon.Finished := True;
  Self.Submit(FPolygon);

  Self.Prompt(sCircleRadius + ': ' + PointToStr(APnt), pkLog);

  FPolygon := nil;
  Result := Finish();
end;

function TUdActionPolygon.SetRadius(AValue: Float): Boolean;
var
  I, L: Integer;
  R, A, A1, AA: Float;
  LPoints: TPoint2DArray;
begin
  Result := False;
  if FStep <> 3 then Exit;

  LPoints := nil;
  L := GPolygonSideNumber;

  R := Abs(AValue);

  if (L < 3) or (L > 256) or (R <= 0) then
    FPolygon.Free()
  else
  begin
    A := 360.0 / L;
    A1 := 270.0 - A / 2;

    if GPolygonInscribed = 'C' then R := R / UdMath.CosD(A / 2);

    System.SetLength(LPoints, L + 1);
    for I := 0 to L - 1 do
    begin
      AA := A1 + A * I;
      LPoints[I].X := FP1.X + R * UdMath.CosD(AA);
      LPoints[I].Y := FP1.Y + R * UdMath.SinD(AA);
    end;
    LPoints[L] := LPoints[0];

    FPolygon.SetPoints(LPoints);
    FPolygon.Visible := True;

    Self.Submit(FPolygon);
    Self.Prompt(sCircleRadius + ': ' + RealToStr(AValue), pkLog);
  end;

  FPolygon := nil;
  Result := Finish();
end;




//----------------------------------------------------------------------

function TUdActionPolygon.Parse(const AValue: string): Boolean;

  function _SideNumber(const AValue: string): Boolean;
  var
    N: Integer;
  begin
    Result := False;

    if (Trim(AValue) = '') or IsInt(AValue) then
    begin
      Result := True;

      if IsInt(AValue) then
      begin
        N := StrToInt(AValue);
        Result := (N >= 3) and (N <= 256);
        if Result then GPolygonSideNumber := N;
      end;

      if Result then
        SetSideNum()
      else
        Self.Prompt(sPolygonSides, pkLog);
    end
    else
      Self.Prompt(sPolygonSides, pkLog);
  end;


  function _PolygonCenter(const AValue: string): Boolean;
  var
    LPnt: TPoint2D;
    LIsOpp: Boolean;
  begin
    Result := ParseCoord(AValue, LPnt, LIsOpp);
    if Result then
      Result := SetCenter(LPnt)
    else
      Self.Prompt(sInvalidPoint, pkLog);
  end;

  function _InscribedOrCircumscribed(const AValue: string): Boolean;
  var
    V, I: string;
  begin
    V := LowerCase(Trim(AValue));
    Result := V = '';

    if not Result then
    begin
      I := '';
      if Pos(V, 'inscribed') = 1 then
        I := 'I'
      else if Pos(V, 'circumscribed') = 1 then
        I := 'C';
      V := I;
      Result := I <> '';
    end;

    if Result then
      SetInscribed(V)
    else
      Self.Prompt(sRequireKeyword, pkLog);
  end;

  function _CircleRadius(const AValue: string): Boolean;
  var
    LPnt: TPoint2D;
    LIsOpp: Boolean;
  begin
    if ParseCoord(AValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP1.X + LPnt.X;
        LPnt.Y := FP1.Y + LPnt.Y;
      end;
      Result := SetRadius(LPnt);
    end
    else if IsNum(AValue) then
    begin
      Result := SetRadius(StrToFloat(AValue));
    end
    else begin
      Result := False;
      Self.Prompt(sRequireDisOrPoint, pkLog);
    end;
  end;


begin
  Result := True;
  if FStep = 0 then
    Result := _SideNumber(AValue)
  else if FStep = 1 then
    Result := _PolygonCenter(AValue)
  else if FStep = 2 then
    Result := _InscribedOrCircumscribed(AValue)
  else if FStep = 3 then
    Result := _CircleRadius(AValue);
end;



function TUdActionPolygon.UpdateEntities(): Boolean;
var
  I, L: Integer;
  R, A, A1, AA: Float;
  LPoints: TPoint2DArray;
begin
  LPoints := nil;
  L := GPolygonSideNumber;

  Result := False;
  if (FStep <> 3) or (L < 3) or (L > 256) then Exit;

  FLine.StartPoint := FP1;
  FLine.EndPoint := FP2;
  FLine.Visible := True;

  R := UdGeo2D.Distance(FP1, FP2);
  if R <= 0 then Exit;

  A := 360.0 / L;
  A1 := UdGeo2D.GetAngle(FP1, FP2);

  if GPolygonInscribed = 'C' then
  begin
    R := R / UdMath.CosD(A / 2);
    A1 := FixAngle(A1 + A / 2);
  end;

  System.SetLength(LPoints, L + 1);
  for I := 0 to L - 1 do
  begin
    AA := A1 + A * I;
    LPoints[I].X := FP1.X + R * UdMath.CosD(AA);
    LPoints[I].Y := FP1.Y + R * UdMath.SinD(AA);
  end;
  LPoints[L] := LPoints[0];

  FPolygon.SetPoints(LPoints);
  FPolygon.Visible := True;

  Result := True;
end;


procedure TUdActionPolygon.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionPolygon.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                                      ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;
  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetSideNum()
          else if FStep = 1 then
            SetCenter(ACoordPnt)
          else if FStep = 2 then
            SetInscribed('')
          else if FStep = 3 then
            SetRadius(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 3 then
        begin
          FP2 := ACoordPnt;
          UpdateEntities();
        end;
      end;
  end;
end;




end.