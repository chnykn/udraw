{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionText;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdText;

type

  //*** TUdActionText ***//
  TUdActionText = class(TUdDrawAction)
  private
    FLine: TUdLine;
    FText: TUdText;

    FP1, FP2: TPoint2D;
    FHeighted, FRotated, FPositioned: Boolean;

    FTextHeight: Float;

  protected
    function SetPosition(APnt: TPoint2D): Boolean;

    function SetHeight(APnt: TPoint2D): Boolean; overload;
    function SetHeight(const AValue: Float): Boolean; overload;

    function SetRotation(APnt: TPoint2D): Boolean; overload;
    function SetRotation(const AValue: Float): Boolean; overload;

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
  SysUtils, UdTextParamsFrm,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;


//=========================================================================================
{ TUdActionText }

class function TUdActionText.CommandName: string;
begin
  Result := 'text';
end;

constructor TUdActionText.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FText := TUdText.Create(FDocument, False);
  FText.Finished := False;
  FText.Visible := False;

  if UdTextParamsFrm.ShowTextParamsForm(FDocument, FText, FHeighted, FRotated, FPositioned) then
  begin
    FTextHeight := FText.Height;
    
    if FHeighted and FRotated and FPositioned then
    begin
      FText.Finished := True;
      Self.Submit(FText);
      FText := nil;
      Self.Aborted := True;
    end
    else begin
      if not FPositioned then
        Self.Prompt(sTextInsertPoint, pkCmd)
      else if not FHeighted then
      begin
        FP1 := FText.Position;
        FP2 := FText.Position;
        FStep := 1;
        Self.Prompt(sTextHeight, pkCmd);
      end
      else if not FRotated then
      begin
        FP1 := FText.Position;
        FP2 := FText.Position;
        FStep := 2;      
        Self.Prompt(sTextRotation, pkCmd);
      end;
    end;
  end
  else Self.Aborted := True;
end;

destructor TUdActionText.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FText) then FText.Free();
  inherited;
end;



//---------------------------------------------------

procedure TUdActionText.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FText) and FText.Visible then FText.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionText.SetPosition(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;
  FP2 := APnt;

  FLine.StartPoint := FP1;
  FLine.EndPoint := FP2;
  FLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  FText.Position := APnt;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sTextInsertPoint + ': ' + PointToStr(APnt), pkLog);

  if FHeighted and FRotated then
  begin
    FText.Finished := False;
    Self.Submit(FText);

    FText := nil;
    Self.Finish();
  end
  else begin
    if FHeighted then
    begin
      FStep := 2;
      Self.Prompt(sTextRotation, pkCmd);
    end
    else begin
      FStep := 1;
      Self.Prompt(sTextHeight, pkCmd);
    end;
  end;

  Result := True;
end;

function TUdActionText.SetHeight(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FP2 := APnt;
  FLine.EndPoint := FP2;

  if NotEqual(FLine.StartPoint, FLine.EndPoint) then
  begin
    FTextHeight := Distance(FP1, FP2);
    FText.Height := FTextHeight;
    Self.Prompt(sTextHeight + ': ' + RealToStr(FText.Height), pkLog);

    if FRotated then
    begin
      FText.Finished := False;
      Self.Submit(FText);

      FText := nil;
      Self.Finish();
    end
    else begin
      Self.Prompt(sTextRotation, pkCmd);

      FStep := 2;
      Result := True;
    end;
  end;
end;

function TUdActionText.SetHeight(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  if FHeighted then
  begin
    FStep := 2;
    Exit;  //=====>>>>
  end;
    
  if NotEqual(AValue, 0.0) and (AValue > 0) then
  begin
    FTextHeight := AValue;
    FText.Height := AValue;
    Self.Prompt(sTextHeight + ': ' + RealToStr(AValue), pkLog);

    if FRotated then
    begin
      FText.Finished := False;
      Self.Submit(FText);

      FText := nil;
      Self.Finish();
    end
    else begin
      Self.Prompt(sTextRotation, pkCmd);
      
      FStep := 2;
      Result := True;
    end;
  end;
end;



function TUdActionText.SetRotation(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FP2 := APnt;
  FLine.EndPoint := FP2;

  if NotEqual(FLine.StartPoint, FLine.EndPoint) then
  begin
    FText.Rotation := GetAngle(FP1, FP2);
    Self.Prompt(sTextRotation + ': ' + AngleToStr(FText.Rotation), pkLog);

    FText.Finished := False;
    Self.Submit(FText);

    FText := nil;
    Result := Self.Finish();
  end;
end;

function TUdActionText.SetRotation(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FText.Rotation := FixAngle(AValue);
  Self.Prompt(sTextRotation + ': ' + AngleToStr(AValue), pkLog);

  FText.Finished := False;
  Self.Submit(FText);

  FText := nil;
  Result := Self.Finish();
end;


//---------------------------------------------------

function TUdActionText.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));

  if LValue = '' then
  begin
    if FStep = 0 then
    begin
      Self.Finish;
      Exit; //=======>>>>
    end
    else if FStep = 1 then
    begin
      SetHeight(FText.Height);
      Exit;  //=====>>>>
    end
    else if FStep = 2 then
    begin
      SetRotation(0);
      Exit;  //=====>>>>
    end;
  end;
  

  if ParseCoord(LValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetPosition(LPnt)
    else if FStep = 1 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FLine.StartPoint.X + LPnt.X;
        LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
      end;
      SetHeight(LPnt);
    end
    else if FStep = 2 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FLine.StartPoint.X + LPnt.X;
        LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
      end;
      SetRotation(LPnt);
    end;
  end
  else if IsNum(LValue) then
  begin
    if FStep = 1 then SetHeight(StrToFloat(LValue)) else
    if FStep = 2 then SetRotation(StrToFloat(LValue)) else
    Self.Prompt(sInvalidPoint, pkLog);
  end
  else begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


procedure TUdActionText.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  
end;

procedure TUdActionText.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetPosition(ACoordPnt)
          else if FStep = 1 then
            SetHeight(ACoordPnt)
          else if FStep = 2 then
            SetRotation(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin

        if FStep = 0 then
        begin
          FText.Position := ACoordPnt;
          FText.Visible := True;
        end
        else if (FStep = 1) or (FStep = 2) then
        begin
          FP2 := ACoordPnt;

          FLine.StartPoint := FP1;
          FLine.EndPoint := FP2;
          FLine.Visible := True;

          if FStep = 1 then
            FText.Height := Distance(FP1, FP2)
          else
            FText.Rotation := GetAngle(FP1, FP2);
          FText.Visible := True;  
        end;
      end;
  end;
end;



end.