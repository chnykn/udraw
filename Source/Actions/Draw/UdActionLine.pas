{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionLine;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine;

type
  //*** TUdActionLine ***//
  TUdActionLine = class(TUdDrawAction)
  private
    FLine: TUdLine;
    FCurPnt: TPoint2D;
    FLineList: TList;
    FPrevAng: Float;

  protected
    function GetPrevAngle(): Float; override;
    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetNextPoint(APnt: TPoint2D): Boolean;

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
{ TUdActionLine }

class function TUdActionLine.CommandName: string;
begin
  Result := 'line';
end;

constructor TUdActionLine.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FLineList := TList.Create;
  FPrevAng := -1;

  Self.Prompt(sFirstPoint, pkCmd);
end;

destructor TUdActionLine.Destroy;
begin
  FLineList.Free;
  if Assigned(FLine) then FLine.Free();
  inherited;
end;



//---------------------------------------------------

procedure TUdActionLine.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
end;


function TUdActionLine.GetPrevAngle: Float;
begin
  Result := FPrevAng;
end;



//---------------------------------------------------

function TUdActionLine.SetFirstPoint(APnt: TPoint2D): Boolean;
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
  Self.Prompt(sNextPointUndo, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionLine.SetNextPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FLine.EndPoint := APnt;
  
  if NotEqual(FLine.StartPoint, FLine.EndPoint) then
  begin
    FPrevAng := UdGeo2D.GetAngle(FLine.StartPoint, FLine.EndPoint);
    
    FLine.Finished := True;
    FLineList.Add(FLine);
    Self.Submit(FLine);

    FLine := TUdLine.Create(FDocument, False);
    FLine.Finished := False;

    FLine.StartPoint := APnt;
    FLine.EndPoint := APnt;

    Self.SetPrevPoint(APnt);
    Self.Prompt(sNextPointUndo + ': ' + PointToStr(APnt), pkLog);
    Result := True;


    Self.Invalidate;
  end;
end;



//---------------------------------------------------

function TUdActionLine.Parse(const AValue: string): Boolean;
var
  D: Double;
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
  LLastLine: TUdLine;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));

  if LValue = '' then
  begin
    Self.Finish();
    Exit;
  end;

  if (LValue = 'u') or (LValue = 'undo') then
  begin
    if FLineList.Count > 0 then
    begin
      LLastLine := TUdLine(FLineList[FLineList.Count - 1]);

      FLine.Assign(LLastLine);
      FLine.EndPoint := FCurPnt;

      Self.RemoveEntity(LLastLine);
      FLineList.Delete(FLineList.Count - 1);
    end
    else
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


procedure TUdActionLine.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionLine.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
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