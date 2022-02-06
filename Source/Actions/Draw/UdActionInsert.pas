{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionInsert;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction,
  UdLine, UdBlock, UdInsert, UdActionInsertFrm;

type
  //*** TUdActionInsert ***//
  TUdActionInsert = class(TUdAction)
  private
    FInsertForm: TUdActionInsertForm;

    FLine: TUdLine;
    FInsert: TUdInsert;

  protected
    function ShowInsertForm(InCreating: Boolean = False): Boolean;

    function SetInsPoint(APnt: TPoint2D): Boolean;

    function SetScale(APnt: TPoint2D): Boolean; overload;
    function SetScaleX(const AValue: Float): Boolean; overload;
    function SetScaleY(const AValue: Float): Boolean; overload;

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
  SysUtils,
  UdLayout,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;


var
  GScaleX   : Float = 1.0;
  GRoatation: Float = 0;


//=========================================================================================
{ TUdActionInsert }

class function TUdActionInsert.CommandName: string;
begin
  Result := 'insert';
end;

constructor TUdActionInsert.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FInsert := TUdInsert.Create(FDocument, False);
  FInsert.Finished := False;

  FInsertForm := TUdActionInsertForm.Create(nil);
  FInsertForm.Document := FDocument;

  Self.SetCursorStyle(csDraw);
  Self.ShowInsertForm(True);
end;

destructor TUdActionInsert.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FInsert) then FInsert.Free();

  if Assigned(FInsertForm) then FInsertForm.Free();
  FInsertForm := nil;

  inherited;
end;




//------------------------------------------------------------------------------------------

function TUdActionInsert.SetInsPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FInsert.Position := APnt;
  Self.Prompt(sInsBasePoint + ': ' + PointToStr(APnt), pkLog);

  if not FInsertForm.SpecifScaleY and not FInsertForm.SpecifyRoatation then
  begin
    Self.AddEntity(FInsert);

    FInsert := nil;
    Self.Finish();
  end
  else begin
    if not FInsertForm.SpecifScaleY then
    begin
      FLine.StartPoint := FInsert.Position;
      FLine.EndPoint := FInsert.Position;
      FLine.Visible := True;
      SetPrevPoint(FInsert.Position);

      FStep := 3;
      Self.Prompt(sRotationAngle + '<' + AngleToStr(GRoatation) + '>', pkCmd);
    end
    else begin
      FStep := 1;
      Self.Prompt(sScaleXFactor + '<' + FloatToStrF(GScaleX, ffFixed, 36, 3) + '>', pkCmd);
    end;
  end;

  Result := True;
end;




function TUdActionInsert.SetScale(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FInsert.BeginUpdate();
  try
    FInsert.ScaleX := APnt.X - FInsert.Position.X;
    FInsert.ScaleY := APnt.Y - FInsert.Position.Y;
  finally
    FInsert.EndUpdate();
  end;

  GScaleX := FInsert.ScaleX;

  Self.Prompt(sScaleXFactor + ': ' + FloatToStrF(FInsert.ScaleX, ffFixed, 36, 3) +
              sScaleYFactor + ': ' + FloatToStrF(FInsert.ScaleY, ffFixed, 36, 3) , pkLog);

  if not FInsertForm.SpecifyRoatation then
  begin
    Self.AddEntity(FInsert);

    FInsert := nil;
    Self.Finish();
  end
  else begin
    FLine.StartPoint := FInsert.Position;
    FLine.EndPoint := FInsert.Position;
    FLine.Visible := True;
    SetPrevPoint(FInsert.Position);

    FStep := 3;
    Self.Prompt(sRotationAngle + '<' + AngleToStr(GRoatation) + '>', pkCmd);
  end;

  Result := True;
end;

function TUdActionInsert.SetScaleX(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FInsert.ScaleX := AValue;
  Self.Prompt(sScaleXFactor + ': ' + FloatToStrF(AValue, ffFixed, 36, 3), pkLog);

  FStep := 2;
  Self.Prompt(sScaleYFactor + '<' + sUseScaleYFactor + '>', pkCmd);

  Result := True;
end;

function TUdActionInsert.SetScaleY(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FInsert.ScaleY := AValue;
  Self.Prompt(sScaleYFactor + ': ' + FloatToStrF(AValue, ffFixed, 36, 3), pkLog);

  if not FInsertForm.SpecifyRoatation then
  begin
    Self.AddEntity(FInsert);

    FInsert := nil;
    Self.Finish();
  end
  else begin
    FLine.StartPoint := FInsert.Position;
    FLine.EndPoint := FInsert.Position;
    FLine.Visible := True;
    SetPrevPoint(FInsert.Position);

    FStep := 3;
    Self.Prompt(sRotationAngle + '<' + AngleToStr(GRoatation) + '>', pkCmd);
  end;

  Result := True;
end;


function TUdActionInsert.SetRotation(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FLine.EndPoint := APnt;

  if NotEqual(FLine.StartPoint, FLine.EndPoint) then
  begin
    FLine.Visible := False;

    FInsert.Rotation := GetAngle(FLine.StartPoint, FLine.EndPoint);
    GRoatation := FInsert.Rotation;

    Self.Prompt(sRotationAngle + ': ' + AngleToStr(FInsert.Rotation), pkLog);

    Self.AddEntity(FInsert);

    FInsert := nil;
    Self.Finish();

    Result := True;
  end;
end;

function TUdActionInsert.SetRotation(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FLine.Visible := False;

  FInsert.Rotation := FixAngle(AValue);
  GRoatation := FInsert.Rotation;

  Self.Prompt(sRotationAngle + ': ' + AngleToStr(FInsert.Rotation), pkLog);

  Self.AddEntity(FInsert);

  FInsert := nil;
  Self.Finish();

  Result := True;
end;




//------------------------------------------------------------------------------------------

//function TUdActionInsert.ApplyAddInsert(): Boolean;
//begin
//  FInsert.BeginUpdate();
//  try
//    FInsert.Position := FInsPoint;
//    FInsert.ScaleX         := FScale.X;
//    FInsert.ScaleY         := FScale.Y;
//    FInsert.Rotation       := FRotation;
//  finally
//    FInsert.EndUpdate();
//  end;
//
//  Result := Self.AddEntity(FInsert);
//end;


function TUdActionInsert.ShowInsertForm(InCreating: Boolean = False): Boolean;
var
  LBlock: TUdBlock;
begin
  Result := False;

  if not Assigned(Self.Blocks) then
  begin
    if InCreating then Self.Aborted := True else Self.Finish();
    Exit; //=====>>>>
  end;

  if FInsertForm.ShowModal() = mrOK then
  begin
    LBlock := Self.Blocks.GetItem(FInsertForm.BlockName);
    if not Assigned(LBlock) then
    begin
      if InCreating then Self.Aborted := True else Self.Finish();
      Exit; //=====>>>>
    end;

    FInsert.BeginUpdate();
    try
      if FInsertForm.SpecifyInsPoint then
        FInsert.Position := LBlock.Origin
      else
        FInsert.Position := FInsertForm.InsPoint;

      if FInsertForm.SpecifScaleY then
      begin
        FInsert.ScaleX := 1.0;
        FInsert.ScaleY := 1.0;
      end
      else begin
        FInsert.ScaleX := FInsertForm.Scale.X;
        FInsert.ScaleY := FInsertForm.Scale.Y;
      end;

      if FInsertForm.SpecifyRoatation then
        FInsert.Rotation := 0
      else
        FInsert.Rotation := FInsertForm.Roatation;

      FInsert.Block := LBlock;
    finally
      FInsert.EndUpdate();
    end;

    if not FInsertForm.SpecifyInsPoint and
       not FInsertForm.SpecifScaleY and
       not FInsertForm.SpecifyRoatation then
    begin
      Self.AddEntity(FInsert);
      FInsert := nil;

      if InCreating then Self.Aborted := True else Self.Finish();
    end
    else begin
      if FInsertForm.SpecifyInsPoint then
      begin
        FStep := 0;
        Self.Prompt(sInsBasePoint, pkCmd);
      end
      else if FInsertForm.SpecifScaleY then
      begin
        FStep := 1;
        Self.Prompt(sScaleXFactor, pkCmd);  //sScaleYFactor
      end
      else if FInsertForm.SpecifyRoatation then
      begin
        FStep := 3;
        Self.Prompt(sRotationAngle, pkCmd);
      end;
    end;

    Result := True;
  end
  else
    if InCreating then Self.Aborted := True;
end;





//------------------------------------------------------------------------------------------

procedure TUdActionInsert.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FInsert) and FInsert.Visible then FInsert.Draw(ACanvas);
  end;
end;

function TUdActionInsert.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));

  if (LValue = '') and (FStep in [1, 2, 3]) then
  begin
    if FStep = 1 then SetScaleX(GScaleX) else
    if FStep = 2 then SetScaleY(FInsert.ScaleX) else
    if FStep = 3 then SetRotation(GRoatation);

    Exit;
  end;

  if ParseCoord(LValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetInsPoint(LPnt)
    else if FStep = 1 then
    begin
      SetScale(LPnt);
    end
    else if FStep = 3 then
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
    if FStep = 1 then SetScaleX(StrToFloat(LValue)) else
    if FStep = 2 then SetScaleY(StrToFloat(LValue)) else
    if FStep = 3 then SetRotation(StrToFloat(LValue)) else
    Self.Prompt(sInvalidPoint, pkLog);
  end
  else begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


procedure TUdActionInsert.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionInsert.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LAng: Float;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetInsPoint(ACoordPnt)
          else if FStep = 1 then
            SetScale(ACoordPnt)
          else if FStep = 3 then
            SetRotation(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 0 then
        begin
          FInsert.Position := ACoordPnt;
        end
        else if FStep = 1 then
        begin
          FInsert.BeginUpdate();
          try
            FInsert.ScaleX := ACoordPnt.X - FInsert.Position.X;
            FInsert.ScaleY := ACoordPnt.X - FInsert.Position.Y;
          finally
            FInsert.EndUpdate();
          end;
        end
        else if FStep = 3 then
        begin
          FLine.EndPoint := ACoordPnt;
          LAng := GetAngle(FLine.StartPoint, FLine.EndPoint);
          if LAng >= 0 then FInsert.Rotation := LAng;
        end;
      end;
  end;
end;





end.