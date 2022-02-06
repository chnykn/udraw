{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDistance;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine;

type

  //*** TUdActionDistance ***//
  TUdActionDistance = class(TUdInquiryAction)
  private
    FLine: TUdLine;
    FCurPnt: TPoint2D;
    FPrevAng: Float;

  protected
    function GetPrevAngle(): Float; override;
    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetNextPoint(APnt: TPoint2D): Boolean;

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
  SysUtils,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;



//================================================================================================
{ TUdActionDistance }


class function TUdActionDistance.CommandName: string;
begin
  Result := 'dist';
end;



constructor TUdActionDistance.Create(ADocument, ALayout: TUdObject; Args: string);
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FPrevAng := -1;
  
  Self.CanSnap    := True;
  Self.CanOSnap   := True;
  Self.CanPerpend := True;
    
  Self.SetCursorStyle(csDraw);
  Self.Prompt(sFirstPoint, pkCmd);  
end;

destructor TUdActionDistance.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  FLine := nil;
  
  inherited;
end;



function TUdActionDistance.GetPrevAngle: Float;
begin
  Result := FPrevAng;
end;

procedure TUdActionDistance.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if FVisible then
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
end;




//---------------------------------------------------

function TUdActionDistance.SetFirstPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sNextPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionDistance.SetNextPoint(APnt: TPoint2D): Boolean;
var
  LStr: string;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FLine.EndPoint := APnt;
  
  if NotEqual(FLine.StartPoint, FLine.EndPoint) then
  begin
    FPrevAng := UdGeo2D.GetAngle(FLine.StartPoint, FLine.EndPoint);
    FLine.Finished := True;

    Self.Prompt(sNextPoint + ': ' + PointToStr(APnt), pkLog);

    LStr := 'Distance = ' + Self.RealToStr(FLine.Length) + ',   ' +
            'Angle = '    + Self.AngleToStr(FLine.Angle) + #13#10 +
            'Delta X = '  + Self.RealToStr(FLine.DeltaX) + ',   ' +
            'Delta Y = '  + Self.RealToStr(FLine.DeltaY);
    Self.Prompt(LStr, pkLog);


    Result := Self.Finish();
  end;
end;



//--------------------------------------------------------------------------

function TUdActionDistance.Parse(const AValue: string): Boolean;
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
    LPnt := ShiftPoint(FLine.StartPoint, GetAngle(FLine.StartPoint, FCurPnt), D);
    SetNextPoint(LPnt);
  end
  else if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetFirstPoint(LPnt)
    else if FStep = 1 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FLine.StartPoint.X + LPnt.X;
        LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
      end;
      SetNextPoint(LPnt);
    end;
  end
  else begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


procedure TUdActionDistance.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionDistance.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;
  
  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetFirstPoint(ACoordPnt)
          else if FStep = 1 then
            SetNextPoint(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        FCurPnt := ACoordPnt;
        if FStep = 1 then
        begin
          FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;


end.