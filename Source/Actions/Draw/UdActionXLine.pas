{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionXLine;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdXLine, UdLine;

type
  //*** TUdActionXLine ***//
  TUdActionXLine = class(TUdDrawAction)
  private
    FLine: TUdLine;
    FXLine: TUdXLine;

    FBasePnt: TPoint2D;
    FCurPnt: TPoint2D;

    FAngle: Float;
    FOffDis: Float;
    FThroughed: Boolean;

    FOffP1, FOffP2: TPoint2D;

  protected
    function SetBasePoint(APnt: TPoint2D): Boolean;     // 0
    function SetSecondPoint(APnt: TPoint2D): Boolean;   // 1

    function FSetAngBasePoint(APnt: TPoint2D): Boolean;
    function SetAngBasePoint(APnt: TPoint2D): Boolean;  // 2
    function SetAnglePoint1(APnt: TPoint2D): Boolean;   // 3
    function SetAnglePoint2(APnt: TPoint2D): Boolean;   // 4

    function SetOffsetP1(APnt: TPoint2D): Boolean; // 5
    function SetOffsetP2(APnt: TPoint2D): Boolean; // 6
    function SelLineObject(APnt: TPoint2D): Boolean; // 7
    function OffsideXLine(APnt: TPoint2D): Boolean; // 8

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
  UdPolyline, UdRay,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;

var
  GXLineAngle: Float = 0.0;
  GXLineOffDis: Float = 10.0;
  
  

//=========================================================================================
{ TUdActionXLine }

class function TUdActionXLine.CommandName: string;
begin
  Result := 'xline';
end;

constructor TUdActionXLine.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FAngle := GXLineAngle;
  FOffDis := GXLineOffDis;
  FThroughed := False;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FXLine := TUdXLine.Create(FDocument, False);
  FXLine.Finished := False;
  FXLine.Visible := False;

  Self.Prompt(sXLinePntOrKeys, pkCmd);
end;

destructor TUdActionXLine.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FXLine) then FXLine.Free();
  inherited;
end;


//---------------------------------------------------

procedure TUdActionXLine.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FXLine) and FXLine.Visible then FXLine.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionXLine.SetBasePoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FBasePnt := APnt;

  FXLine.BasePoint := APnt;
  FXLine.SecondPoint := APnt;
  FXLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sBasePoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sThroughPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionXLine.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FXLine.SecondPoint := APnt;
  
  if NotEqual(FBasePnt, APnt) then
  begin
    FXLine.Finished := True;
    Self.Submit(FXLine);

    FXLine := TUdXLine.Create(FDocument, False);
    FXLine.BeginUpdate();
    try
      FXLine.BasePoint := FBasePnt;
      FXLine.SecondPoint := FBasePnt;
      FXLine.Finished := False;
    finally
      FXLine.EndUpdate();
    end;

    Self.SetPrevPoint(FXLine.BasePoint);
    Self.Prompt(sThroughPoint + ': ' + PointToStr(APnt), pkLog);
    Result := True;

    Self.Invalidate;
  end;
end;


function TUdActionXLine.FSetAngBasePoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if not Assigned(FXLine) then Exit;
  
  FXLine.BeginUpdate();
  try
    FXLine.BasePoint := APnt;
    FXLine.SecondPoint := ShiftPoint(APnt, FAngle, 100);
    FXLine.Visible := True;
  finally
    FXLine.EndUpdate();
  end;

  Result := True;
end;

function TUdActionXLine.SetAngBasePoint(APnt: TPoint2D): Boolean;  // 2
begin
  Result := False;
  if FStep <> 2 then Exit;

  FSetAngBasePoint(APnt);
  FXLine.Finished := True;
  Self.Submit(FXLine);

  FXLine := TUdXLine.Create(FDocument, False);
  FSetAngBasePoint(APnt);

  Self.Prompt(sThroughPoint + ': ' + PointToStr(APnt), pkLog);
  Result := True;

  Self.Invalidate;   
end;

function TUdActionXLine.SetAnglePoint1(APnt: TPoint2D): Boolean;   // 3
begin
  Result := False;
  if FStep <> 3 then Exit;

  FXLine.Visible := False;

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

function TUdActionXLine.SetAnglePoint2(APnt: TPoint2D): Boolean;   // 4
begin
  Result := False;
  if FStep <> 4 then Exit;

  FLine.EndPoint := APnt;
  FLine.Visible := False;

  Self.CanOrtho := False;
  Self.CanPerpend := True;

  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);

  FAngle := GetAngle(FLine.StartPoint, FLine.EndPoint);
  GXLineAngle := FAngle;

  FStep := 2;
  FXLine.Visible := True;

  Self.Prompt(sThroughPoint + ': ' + PointToStr(APnt), pkCmd);
  Result := True;  
end;



function TUdActionXLine.SetOffsetP1(APnt: TPoint2D): Boolean; // 5
begin
  Result := False;
  if FStep <> 5 then Exit;

  FXLine.Visible := False;

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

function TUdActionXLine.SetOffsetP2(APnt: TPoint2D): Boolean; // 6
begin
  Result := False;
  if FStep <> 6 then Exit;

  FLine.EndPoint := APnt;
  FLine.Visible := False;

  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);


  FOffDis := Distance(FLine.StartPoint, FLine.EndPoint);
  GXLineOffDis := FOffDis;

  FStep := 7;
  FThroughed := False;

  Self.CanSnap := False;
  Self.CanOSnap := False;
  Self.CanOrtho := False;
  Self.CanPerpend := False;
    
  Self.SetCursorStyle(csPick);
  
  Self.SetPrevPoint(APnt);
  Self.Prompt(sSelLineObj, pkCmd);
  Result := True;  
end;

function TUdActionXLine.SelLineObject(APnt: TPoint2D): Boolean; // 7
var
  I: Integer;
  E: Float;
  LP1, LP2: TPoint2D;
  LSelObj: TUdEntity;
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if FStep <> 7 then Exit;

  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) then
  begin
    Self.Prompt(sNoUsableObjSel, pkLog);
    Exit;  //========>>>>>
  end;  

  if LSelObj.InheritsFrom(TUdPolyline) and (TUdPolyline(LSelObj).SplineFlag = sfStandard) then
  begin
    E := DEFAULT_PICK_SIZE / Self.PixelPerValue();

    LSegarcs := TUdPolyline(LSelObj).XData;

    for I := 0 to System.Length(LSegarcs) - 1 do
    begin
      if not LSegarcs[I].IsArc and
         UdGeo2D.IsPntOnSegment(APnt, LSegarcs[I].Seg, E) then
      begin
        LP1 := LSegarcs[I].Seg.P1;
        LP2 := LSegarcs[I].Seg.P2;

        Result := True;
        Break;
      end;
    end;
  end
  else if LSelObj.InheritsFrom(TUdLine) then
  begin
    LP1 := TUdLine(LSelObj).StartPoint;
    LP2 := TUdLine(LSelObj).EndPoint;
    Result := True;
  end
  else if LSelObj.InheritsFrom(TUdXLine) then
  begin
    LP1 := TUdXLine(LSelObj).BasePoint;
    LP2 := TUdXLine(LSelObj).SecondPoint;
    Result := True;
  end
  else if LSelObj.InheritsFrom(TUdRay) then
  begin
    LP1 := TUdRay(LSelObj).BasePoint;
    LP2 := TUdRay(LSelObj).SecondPoint;
    Result := True;
  end;

  if Result then
  begin
    if FThroughed then
    begin
      FAngle := GetAngle(LP1, LP2);
      GXLineAngle := FAngle;

      FSetAngBasePoint(APnt);

      FStep := 2;
      FXLine.Visible := True;

      Self.Prompt(sThroughPoint, pkCmd);
    end
    else begin
      FOffP1 := LP1;
      FOffP2 := LP2;

      FStep := 8;
            
      Self.Prompt(sOffsetSide, pkCmd);
    end;

    Self.SetCursorStyle(csDraw);
  end
  else
    Self.Prompt(sNoUsableObjSel, pkLog);
end;

function TUdActionXLine.OffsideXLine(APnt: TPoint2D): Boolean;
var
  LSeg: TSegment2D;
begin
  Result := False;
  if FStep <> 8 then Exit;

  LSeg := UdGeo2D.OffsetSegment(Segment2D(FOffP1, FOffP2), FOffDis, APnt);

  FXLine.BeginUpdate();
  try
    FXLine.BasePoint := LSeg.P1;
    FXLine.SecondPoint := LSeg.P2;
    FXLine.Visible := True;
  finally
    FXLine.EndUpdate();
  end;

  FXLine.Finished := True;
  Self.Submit(FXLine);

  FXLine := TUdXLine.Create(FDocument, False);
  FStep := 7;

  Self.SetCursorStyle(csPick);
  Self.Prompt(sSelLineObj, pkCmd);

  Result := True;  
end;


//---------------------------------------------------

function TUdActionXLine.Parse(const AValue: string): Boolean;
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
    if FStep in [0, 1, 2, 7, 8] then
    begin
      Self.Finish();
      Exit;
    end
    else if FStep = 3 then
    begin
      FAngle := GXLineAngle;

      FLine.Visible := False;
      FXLine.Visible := True;

      FStep := 2;
      Self.Prompt(sThroughPoint, pkCmd);
      Exit;
    end
    else if FStep = 5 then
    begin
      FOffDis := GXLineOffDis;

      FLine.Visible := False;
      FXLine.Visible := True;

      FStep := 7;

      Self.CanSnap := False;
      Self.CanOSnap := False;
      Self.CanOrtho := False;
      Self.CanPerpend := False;

      Self.SetCursorStyle(csPick);
      Self.Prompt(sSelLineObj, pkCmd);
      Exit;
    end;
  end;

  if FStep = 0 then
  begin
    if (LValue = 'h') or (LValue = 'hor') then
    begin
      FAngle := 0.0;
      FStep := 2;
      Self.CanOrtho := False;
      Self.FSetAngBasePoint(FCurPnt);
      Self.Prompt(sThroughPoint, pkCmd);
    end
    else if (LValue = 'v') or (LValue = 'Ver') then
    begin
      FAngle := 90.0;
      FStep := 2;
      Self.CanOrtho := False;
      Self.FSetAngBasePoint(FCurPnt);
      Self.Prompt(sThroughPoint, pkCmd);
    end
    else if (LValue = 'a') or (LValue = 'ang') then
    begin
      FStep := 3;
      Self.Prompt(sEnterXLineAng + '<' + AngleToStr(GXLineAngle) + '>', pkCmd);
    end
    else if (LValue = 'o') or (LValue = 'Offset') then
    begin
      FStep := 5;
      FXLine.Visible := False;
      Self.Prompt(sXLineOffDisOrKeys + '<' + RealToStr(GXLineOffDis) + '>', pkCmd);
    end
    else if ParseCoord(AValue, LPnt, LIsOpp) then
    begin
      SetBasePoint(LPnt);
    end
    else begin
      Self.Prompt(sRequirePointOrKeyword, pkLog);
      Result := False;
    end;
  end
  else if FStep = 1 then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      LPnt := ShiftPoint(FBasePnt, GetAngle(FBasePnt, FCurPnt), D);
      SetSecondPoint(LPnt);
    end
    else if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FBasePnt.X + LPnt.X;
        LPnt.Y := FBasePnt.Y + LPnt.Y;
      end;
      SetSecondPoint(LPnt);
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end
  else if FStep = 2 then
  begin
    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      SetAngBasePoint(LPnt);
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end
  else if FStep = 3 then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      FAngle := D;
      GXLineAngle := D;

      FLine.Visible := False;
      FXLine.Visible := True;

      FStep := 2;
      Self.Prompt(sThroughPoint, pkCmd);
    end
    else if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      SetAnglePoint1(LPnt);
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end
  else if FStep = 4 then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      LPnt := ShiftPoint(FBasePnt, GetAngle(FBasePnt, FCurPnt), D);
      SetAnglePoint2(LPnt);
    end
    else if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FBasePnt.X + LPnt.X;
        LPnt.Y := FBasePnt.Y + LPnt.Y;
      end;
      SetAnglePoint2(LPnt);
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end
  else if FStep = 5 then
  begin
    if (LValue = 't') or (LValue = 'Through') then
    begin
      FLine.Visible := False;
      FXLine.Visible := True;
          
      FThroughed := True;
      FStep := 7;

      Self.CanSnap := False;
      Self.CanOSnap := False;
      Self.CanOrtho := False;
      Self.CanPerpend := False;

      Self.SetCursorStyle(csPick);
      Self.Prompt(sSelLineObj, pkCmd);
    end
    else if TryStrToFloat(LValue, D) then
    begin
      FOffDis := D;
      GXLineOffDis := D;

      FLine.Visible := False;
      FXLine.Visible := True;

      FStep := 7;
      Self.Prompt(sSelLineObj, pkCmd);
    end
    else if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      Self.SetOffsetP1(LPnt);
    end
    else begin
      Self.Prompt(sRequirePointOrKeyword, pkLog);
      Result := False;
    end;
  end
  else if FStep = 6 then
  begin
    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FBasePnt.X + LPnt.X;
        LPnt.Y := FBasePnt.Y + LPnt.Y;
      end;    
      SetOffsetP2(LPnt);
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end
  else if FStep = 7 then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      LPnt := ShiftPoint(FBasePnt, GetAngle(FBasePnt, FCurPnt), D);
      SetOffsetP2(LPnt);
    end
    else if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FBasePnt.X + LPnt.X;
        LPnt.Y := FBasePnt.Y + LPnt.Y;
      end;
      SetOffsetP2(LPnt);
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end
  else if FStep = 8 then
  begin
    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FBasePnt.X + LPnt.X;
        LPnt.Y := FBasePnt.Y + LPnt.Y;
      end;    
      OffsideXLine(LPnt);
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end       
end;


procedure TUdActionXLine.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  
end;

procedure TUdActionXLine.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          case FStep of
            0: SetBasePoint(ACoordPnt);
            1: SetSecondPoint(ACoordPnt);
            2: SetAngBasePoint(ACoordPnt);
            3: SetAnglePoint1(ACoordPnt);
            4: SetAnglePoint2(ACoordPnt);
            5: SetOffsetP1(ACoordPnt);
            6: SetOffsetP2(ACoordPnt);
            7: SelLineObject(ACoordPnt);
            8: OffsideXLine(ACoordPnt);
          end;
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        FCurPnt := ACoordPnt;
        case FStep of
          1: FXLine.SecondPoint := ACoordPnt;
          2: FSetAngBasePoint(ACoordPnt);
          4, 6: FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;





end.
