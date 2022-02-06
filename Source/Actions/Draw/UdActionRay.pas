{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionRay;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdRay;

type
  //*** TUdActionRay ***//
  TUdActionRay = class(TUdDrawAction)
  private
    FRay: TUdRay;
    FBasePnt: TPoint2D;
    FCurPnt: TPoint2D;
    
  protected
    function SetBasePoint(APnt: TPoint2D): Boolean;
    function SetSecondPoint(APnt: TPoint2D): Boolean;

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
{ TUdActionRay }

class function TUdActionRay.CommandName: string;
begin
  Result := 'xline';
end;

constructor TUdActionRay.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FRay := TUdRay.Create(FDocument, False);
  FRay.Finished := False;
  FRay.Visible := False;

  Self.Prompt(sBasePoint, pkCmd);
end;

destructor TUdActionRay.Destroy;
begin
  if Assigned(FRay) then FRay.Free();
  inherited;
end;


//---------------------------------------------------

procedure TUdActionRay.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
    if Assigned(FRay) and FRay.Visible then FRay.Draw(ACanvas);
end;



//---------------------------------------------------

function TUdActionRay.SetBasePoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FBasePnt := APnt;

  FRay.BasePoint := APnt;
  FRay.SecondPoint := APnt;
  FRay.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sBasePoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sThroughPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionRay.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FRay.SecondPoint := APnt;
  
  if NotEqual(FBasePnt, APnt) then
  begin
    FRay.Finished := True;
    Self.Submit(FRay);

    FRay := TUdRay.Create(FDocument, False);
    FRay.BeginUpdate();
    try
      FRay.BasePoint := FBasePnt;
      FRay.SecondPoint := FBasePnt;
      FRay.Finished := False;
    finally
      FRay.EndUpdate();
    end;

    Self.SetPrevPoint(FRay.BasePoint);
    Self.Prompt(sThroughPoint + ': ' + PointToStr(APnt), pkLog);
    Result := True;

    Self.Invalidate;
  end;
end;



//---------------------------------------------------

function TUdActionRay.Parse(const AValue: string): Boolean;
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
    Self.Finish();
    Exit;
  end;

  if (FStep = 1) and TryStrToFloat(AValue, D) then
  begin
    LPnt := ShiftPoint(FBasePnt, GetAngle(FBasePnt, FCurPnt), D);
    SetSecondPoint(LPnt);
  end
  else if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetBasePoint(LPnt)
    else if FStep = 1 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FRay.BasePoint.X + LPnt.X;
        LPnt.Y := FRay.BasePoint.Y + LPnt.Y;
      end;
      SetSecondPoint(LPnt);
    end;
  end
  else begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


procedure TUdActionRay.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionRay.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetBasePoint(ACoordPnt)
          else if FStep = 1 then
            SetSecondPoint(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        FCurPnt := ACoordPnt;
        if FStep = 1 then
        begin
          FRay.SecondPoint := ACoordPnt;
        end;
      end;
  end;
end;





end.