{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionChamfer;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine;


type
  //*** UdActionChamfer ***//
  TUdActionChamfer = class(TUdModifyAction)
  private
    FLine: TUdLine;

    FP1, FP2: TPoint2D;
    FEntity1, FEntity2: TUdEntity;

  protected
    function Chamfer(): Boolean;
    function GetChamferStatus(): string;

    function SelectFirstEntity(APnt: TPoint2D): Boolean;
    function SelectSecondEntity(APnt: TPoint2D): Boolean;
    function SelectPolylineEntity(APnt: TPoint2D): Boolean;

    function SetChamferDis1(const AValue: Float): Boolean;
    function SetChamferDis2(const AValue: Float): Boolean;


    function SetChamferDis1P1(APnt: TPoint2D): Boolean;
    function SetChamferDis1P2(APnt: TPoint2D): Boolean;

    function SetChamferDis2P1(APnt: TPoint2D): Boolean;
    function SetChamferDis2P2(APnt: TPoint2D): Boolean;

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
  UdMath, UdGeo2D, UdUtils, UdAcnConsts,
  UdChamfer2D, UdPolyline;

var
  GChamferDis1: Float = 10.0;
  GChamferDis2: Float = 10.0;
  GChamferTrim: Boolean = True;

//==================================================================================================
{ TUdActionChamfer }

class function TUdActionChamfer.CommandName: string;
begin
  Result := 'chamfer';
end;

constructor TUdActionChamfer.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  Self.CanOSnap := False;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  Self.RemoveAllSelected();

  FSelAction.Visible := False;

  FEntity1 := nil;
  FEntity2 := nil;

  Self.SetCursorStyle(csPick);
  Self.Prompt(GetChamferStatus(), pkLog);
  Self.Prompt(sChamferLine1OrKeyword, pkCmd);
end;

destructor TUdActionChamfer.Destroy;
begin
  if Assigned(FLine) then FLine.Free;
  if Assigned(FEntity1) then FEntity1.Selected := False;
  if Assigned(FEntity2) then FEntity2.Selected := False;
  inherited;
end;

function TUdActionChamfer.GetChamferStatus: string;
begin
  if GChamferTrim then Result := '(TRIM mode)' else Result := '(NOTRIM mode)';
  Result := Result + ' ' + Format(sChamferStatus, [GChamferDis1, GChamferDis2]);
end;

procedure TUdActionChamfer.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FEntity1) then FEntity1.Draw(ACanvas);
  if Assigned(FEntity2) then FEntity2.Draw(ACanvas);
  if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
end;



//---------------------------------------------------------------------------------------


function TUdActionChamfer.Chamfer: Boolean;

   procedure _RemoveSelectedEntity();
   begin
     if FEntity1 = FEntity2 then
       Self.RemoveEntity(FEntity1)
     else begin
       Self.RemoveEntity(FEntity1);
       Self.RemoveEntity(FEntity2);
     end;
     FEntity1 := nil;
     FEntity2 := nil;
   end;

   procedure _Chamfer11(ASeg1, ASeg2: TSegment2D);
   var
     LEntity: TUdEntity;
     LSeg1, LSeg2, LChSeg: TSegment2D;
   begin
     if UdChamfer2D.Chamfer(GChamferDis1, GChamferDis2, FP1, FP2, ASeg1, ASeg2, LSeg1, LSeg2, LChSeg) = CHAMFER_SUCCESS then
     begin
       if GChamferTrim then
       begin
         LEntity := TUdLine.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdLine(LEntity).XData := LSeg1;
         Self.AddEntity(LEntity);

         LEntity := TUdLine.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdLine(LEntity).XData := LSeg2;
         Self.AddEntity(LEntity);
       end;

       if NotEqual(LChSeg.P1, LChSeg.P2) then
       begin
         LEntity := TUdLine.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdLine(LEntity).XData := LChSeg;
         Self.AddEntity(LEntity);
       end;

       if GChamferTrim then
         _RemoveSelectedEntity();
     end;
   end;

   procedure _Chamfer33(ASegarcs1, ASegarcs2: TSegarc2DArray);
   var
     LChSeg: TSegment2D;
     LEntity: TUdEntity;
     LSegarcs: TSegarc2DArray;
   begin
     if UdChamfer2D.Chamfer(GChamferDis1, GChamferDis2, FP1, FP2, ASegarcs1, ASegarcs2, LSegarcs, LChSeg) = CHAMFER_SUCCESS then
     begin
       if GChamferTrim then
       begin
         LEntity := TUdPolyline.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdPolyline(LEntity).XData := LSegarcs;
         Self.AddEntity(LEntity);

        _RemoveSelectedEntity();
       end
       else begin
         if NotEqual(LChSeg.P1, LChSeg.P2) then
         begin
           LEntity := TUdLine.Create(FDocument, False);
           LEntity.Assign(FEntity1);
           TUdLine(LEntity).XData := LChSeg;
           Self.AddEntity(LEntity);
         end;
       end;
     end;
   end;

   procedure _Chamfer3(ASegarcs: TSegarc2DArray);
   var
     LChSeg: TSegment2D;
     LEntity: TUdEntity;
     LSegarcs: TSegarc2DArray;
   begin
     if UdChamfer2D.Chamfer(GChamferDis1, GChamferDis2, FP1, FP2, ASegarcs, LSegarcs, LChSeg) = CHAMFER_SUCCESS then
     begin
       if GChamferTrim then
       begin
         LEntity := TUdPolyline.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdPolyline(LEntity).XData := LSegarcs;
         Self.AddEntity(LEntity);

        _RemoveSelectedEntity();
       end
       else begin
         if NotEqual(LChSeg.P1, LChSeg.P2) then
         begin
           LEntity := TUdLine.Create(FDocument, False);
           LEntity.Assign(FEntity1);
           TUdLine(LEntity).XData := LChSeg;
           Self.AddEntity(LEntity);
         end;
       end;
     end;
   end;

   procedure _Chamfer13(ASeg: TSegment2D; ASegarcs: TSegarc2DArray);
   var
     LChSeg: TSegment2D;
     LEntity: TUdEntity;
     LSegarcs: TSegarc2DArray;
   begin
     if UdChamfer2D.Chamfer(GChamferDis1, GChamferDis2, FP1, FP2, ASeg, ASegarcs, LSegarcs, LChSeg) = CHAMFER_SUCCESS then
     begin
       if GChamferTrim then
       begin
         LEntity := TUdPolyline.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdPolyline(LEntity).XData := LSegarcs;
         Self.AddEntity(LEntity);

        _RemoveSelectedEntity();
       end
       else begin
         if NotEqual(LChSeg.P1, LChSeg.P2) then
         begin
           LEntity := TUdLine.Create(FDocument, False);
           LEntity.Assign(FEntity1);
           TUdLine(LEntity).XData := LChSeg;
           Self.AddEntity(LEntity);
         end;
       end;
     end;
   end;



begin
  Result := False;
  if not Assigned(FEntity1) or not Assigned(FEntity2) then Exit;

  if FEntity1 = FEntity2 then
  begin
    if FEntity1.InheritsFrom(TUdPolyline) then
    begin
      _Chamfer3(TUdPolyline(FEntity1).XData);
    end;
  end
  else begin
    if FEntity1.InheritsFrom(TUdLine) then
    begin
      if FEntity2.InheritsFrom(TUdLine) then _Chamfer11(TUdLine(FEntity1).XData, TUdLine(FEntity2).XData) else
      if FEntity2.InheritsFrom(TUdPolyline) then _Chamfer13(TUdLine(FEntity1).XData, TUdPolyline(FEntity2).XData);
    end
    else if FEntity1.InheritsFrom(TUdPolyline) then
    begin
      if FEntity2.InheritsFrom(TUdLine) then begin Swap(FP1, FP2); _Chamfer13(TUdLine(FEntity2).XData, TUdPolyline(FEntity1).XData); end else
      if FEntity2.InheritsFrom(TUdPolyline) then _Chamfer33(TUdPolyline(FEntity1).XData, TUdPolyline(FEntity2).XData);
    end;
  end;
end;


function TUdActionChamfer.SelectFirstEntity(APnt: TPoint2D): Boolean;
var
  LEntity: TUdEntity;
begin
  Result := False;

  if (FStep <> 0) then Exit;

  LEntity := Self.PickEntity(APnt);
  if not Assigned(LEntity) then Exit;

  if not LEntity.InheritsFrom(TUdLine) and
     not (LEntity.InheritsFrom(TUdPolyline) and (TUdPolyline(LEntity).SplineFlag in [sfStandard, sfCtrlPnts])) then
  begin
    Self.Prompt(sChamferError, pkLog);
    Exit;
  end;

  FP1 := APnt;
  FEntity1 := LEntity;
  FEntity1.Selected := True;

  Self.Prompt(sChamferLine1OrKeyword, pkLog);
  Self.Prompt(sChamferLine2, pkCmd);

  FStep := 1;
  Result := True;
end;




function TUdActionChamfer.SelectSecondEntity(APnt: TPoint2D): Boolean;
var
  LEntity: TUdEntity;
begin
  Result := False;

  if (FStep <> 1) then Exit;

  LEntity := Self.PickEntity(APnt);
  if not Assigned(LEntity) then Exit;

  if not LEntity.InheritsFrom(TUdLine) and
     not (LEntity.InheritsFrom(TUdPolyline) and (TUdPolyline(LEntity).SplineFlag in [sfStandard, sfCtrlPnts])) then
  begin
    Self.Prompt(sChamferError, pkLog);
    Exit;
  end;

  if not LEntity.InheritsFrom(TUdPolyline) and (LEntity = FEntity1) then Exit; //======>>>>


  FP2 := APnt;
  FEntity2 := LEntity;
  FEntity2.Selected := True;

  Self.Prompt(sChamferLine2, pkLog);

  Result := Chamfer();

  if Result then
  begin
    FEntity1 := nil;
    FEntity2 := nil;
  end;

  Self.Finish();
end;


function TUdActionChamfer.SelectPolylineEntity(APnt: TPoint2D): Boolean;
var
  I: Integer;
  LSelObj: TUdEntity;
  LSegarcs: TSegarc2DArray;
  LOutSegarcs: TSegarc2DArray;
begin
  Result := False;
  if FStep <> 7 then Exit;

  LSelObj := Self.PickEntity(APnt, False);
  if not Assigned(LSelObj) or not LSelObj.InheritsFrom(TUdPolyline) then
  begin
    Self.Prompt(sSelectPolyline, pkLog);
    Exit;  //========>>>>>
  end;

  if TUdPolyline(LSelObj).SplineFlag in [sfStandard, sfCtrlPnts] then
  begin
    if NotEqual(GChamferDis1, 0.0) or NotEqual(GChamferDis2, 0.0) then
    begin
      LSegarcs := TUdPolyline(LSelObj).XData;
      if TUdPolyline(LSelObj).SplineFlag = sfCtrlPnts then
        for I := 0 to System.Length(LSegarcs) - 1 do LSegarcs[I].IsArc := False;

      if UdChamfer2D.Chamfer(GChamferDis1, GChamferDis2, LSegarcs, LOutSegarcs) = CHAMFER_SUCCESS then
        TUdPolyline(LSelObj).XData := LOutSegarcs;
    end;

    Result := Finish();
  end;
end;

function TUdActionChamfer.SetChamferDis1(const AValue: Float): Boolean;
begin
  Result := False;
  if not(FStep in [2, 3]) then Exit;  //2 3

  GChamferDis1 := Abs(AValue);
  GChamferDis2 := Abs(AValue);

  Self.Prompt(sChamferDis1 + ': ' + RealToStr(GChamferDis1), pkLog);
  Self.Prompt(sChamferDis2 + ' <' + RealToStr(GChamferDis2) + '>', pkCmd);

  FLine.Visible := False;

  if Assigned(FEntity1) then FEntity1.Selected := False;
  if Assigned(FEntity2) then FEntity2.Selected := False;

  FEntity1 := nil;
  FEntity2 := nil;

  FStep := 4;
  Result := True;
end;

function TUdActionChamfer.SetChamferDis2(const AValue: Float): Boolean;
begin
  Result := False;
  if not(FStep in [4, 5]) then Exit;  // 4 5

  GChamferDis2 := Abs(AValue);

  Self.Prompt(sChamferDis2 + ': ' + RealToStr(GChamferDis2), pkLog);
  Self.Prompt(sChamferLine1OrKeyword, pkCmd);

  FLine.Visible := False;

  if Assigned(FEntity1) then FEntity1.Selected := False;
  if Assigned(FEntity2) then FEntity2.Selected := False;

  FEntity1 := nil;
  FEntity2 := nil;


  Self.CanOSnap := False;
  Self.SetCursorStyle(csPick);

  FStep := 0;
  Result := True;
end;




function TUdActionChamfer.SetChamferDis1P1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FP1 := APnt;
  FLine.StartPoint := FP1;
  FLine.EndPoint := FP1;

  FLine.Visible := True;
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 3;
  Result := True;
end;

function TUdActionChamfer.SetChamferDis1P2(APnt: TPoint2D): Boolean;
var
  LDis: Double;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FP2 := APnt;

  FLine.Visible := False;
  Self.Prompt(sSecondPoint, pkLog);

  LDis := Distance(FP1, FP2);
  Result := SetChamferDis1(LDis);
end;


function TUdActionChamfer.SetChamferDis2P1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 4 then Exit;

  FP1 := APnt;
  FLine.StartPoint := FP1;
  FLine.EndPoint := FP1;

  FLine.Visible := True;
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 5;
  Result := True;
end;

function TUdActionChamfer.SetChamferDis2P2(APnt: TPoint2D): Boolean;
var
  LDis: Double;
begin
  Result := False;
  if FStep <> 5 then Exit;

  FP2 := APnt;

  FLine.Visible := False;
  Self.Prompt(sSecondPoint, pkLog);

  LDis := Distance(FP1, FP2);
  Result := SetChamferDis2(LDis);
end;


//---------------------------------------------------------------------------------------

function TUdActionChamfer.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LOppPnt: TPoint2D;
  LValue, LTrimStr: string;
begin
  LValue := LowerCase(Trim(AValue));

  if LValue = '' then
  begin
    case FStep of
      0: Self.Finish();
      1: ;
      2,3: SetChamferDis1(GChamferDis1);
      4,5: SetChamferDis2(GChamferDis2);
    end;
  end
  else if (LValue = 'd') or (Pos('dis', LValue) > 0) then
  begin
    if FStep = 0 then
    begin
      FStep := 2;
      Self.Prompt(sChamferLine1OrKeyword, pkLog);
      Self.Prompt(sChamferDis1 + ' <' + RealToStr(GChamferDis1) + '>', pkCmd);

      Self.CanOSnap := True;
      Self.SetCursorStyle(csDraw);
    end
    else
      Self.Prompt(sRequirePointOrKeyword, pkLog);
  end
  else if (LValue = 'p') or  (LValue = 'polyline') then
  begin
    if FStep = 0 then
    begin
      FLine.Visible := False;
      FStep := 7;
      Self.Prompt(sSelectPolyline, pkCmd);
    end
    else
      Self.Prompt(sRequirePointOrKeyword, pkLog);
  end
  else if (LValue = 't') or (Pos('trim', LValue) > 0) then
  begin
    if FStep = 0 then
    begin
      Self.Prompt(sChamferLine1OrKeyword, pkLog);

      if GChamferTrim then LTrimStr := ': <T>' else LTrimStr := ': <N>';
      Self.Prompt(sTrimMode + LTrimStr, pkCmd);
      FStep := 6;
    end else
    if FStep = 6 then
    begin
      GChamferTrim := True;
      Self.Prompt(AValue, pkLog);

      FStep := 0;
      Self.Prompt(sChamferLine1OrKeyword, pkCmd);
    end
    else
      Self.Prompt(sRequirePointOrKeyword, pkLog);
  end
  else if (FStep = 6) and ((LValue = 'n') or (LValue = 'no')or (LValue = 'notrim')) then
  begin
    GChamferTrim := False;
    Self.Prompt(AValue, pkLog);

    FStep := 0;
    Self.Prompt(sChamferLine1OrKeyword, pkCmd);
  end
  else if IsNum(LValue) then
  begin
    case FStep of
      2,3: SetChamferDis1(StrToFloat(LValue));
      4,5: SetChamferDis2(StrToFloat(LValue));
    else
      Self.Prompt(sRequirePointOrKeyword, pkLog);
    end
  end
  else if ParseCoord(LValue, LPnt, LIsOpp) then
  begin
    LOppPnt := LPnt;
    if LIsOpp then
    begin
      LOppPnt.X := FP1.X + LPnt.X;
      LOppPnt.Y := FP1.Y + LPnt.Y;
    end;

    case FStep of
      0: SelectFirstEntity(LPnt);
      1: SelectSecondEntity(LOppPnt);
      2: SetChamferDis1P1(LPnt);
      3: SetChamferDis1P2(LOppPnt);
      4: SetChamferDis1P1(LPnt);
      5: SetChamferDis1P2(LOppPnt);
      7: SelectPolylineEntity(LPnt);
    end;
  end
  else
    Self.Prompt(sRequirePointOrKeyword, pkLog);

  Result := True;
end;



procedure TUdActionChamfer.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionChamfer.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LTrimStr: string;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          case FStep of
            0: SelectFirstEntity(ACoordPnt);
            1: SelectSecondEntity(ACoordPnt);
            2: SetChamferDis1P1(ACoordPnt);
            3: SetChamferDis1P2(ACoordPnt);
            4: SetChamferDis2P1(ACoordPnt);
            5: SetChamferDis2P2(ACoordPnt);
            6: begin

               end;
            7: SelectPolylineEntity(ACoordPnt);
          end;
        end
        else
          if (AButton = mbRight) then
          begin
            case FStep of
              0: Self.Finish();
              1: Self.Prompt(sChamferLine2, pkLog);
              2,3: SetChamferDis1(GChamferDis1);
              4,5: SetChamferDis2(GChamferDis2);
              6: begin
                   if GChamferTrim then LTrimStr := '<T>' else LTrimStr := '<N>';
                   Self.Prompt(LTrimStr, pkLog);
                   FStep := 0;
                   Self.Prompt(sChamferLine1OrKeyword, pkCmd);
                 end;
              7: Self.Finish();
            end;
          end;
      end;


    mkMouseMove:
      begin
        if (FStep = 3) or (FStep = 5) then
        begin
          FP2 := ACoordPnt;
          FLine.EndPoint := FP2;
        end;
      end;
  end;
end;






end.