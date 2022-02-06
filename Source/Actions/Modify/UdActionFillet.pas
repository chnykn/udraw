{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionFillet;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine;


type
  //*** UdActionFillet ***//
  TUdActionFillet = class(TUdModifyAction)
  private
    FLine: TUdLine;

    FP1, FP2: TPoint2D;
    FEntity1, FEntity2: TUdEntity;

  protected
    function Fillet(): Boolean;

    function SelectFirstEntity(APnt: TPoint2D): Boolean;
    function SelectSecondEntity(APnt: TPoint2D): Boolean;
    function SelectPolylineEntity(APnt: TPoint2D): Boolean;

    function SetFilletRadius(const AValue: Float): Boolean;
    function SetFilletRadiusP1(APnt: TPoint2D): Boolean;
    function SetFilletRadiusP2(APnt: TPoint2D): Boolean;

    function GetFilletStatus: string;

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
  UdFillet2D, UdArc, UdPolyline;

var
  GFilletRadius: Float = 10.0;
  GFilletTrim: Boolean = True;



//==================================================================================================
{ TUdActionFillet }

class function TUdActionFillet.CommandName: string;
begin
  Result := 'fillet';
end;

constructor TUdActionFillet.Create(ADocument, ALayout: TUdObject; Args: string = '');
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
  Self.Prompt(GetFilletStatus(), pkLog);
  Self.Prompt(sFilletObj1OrKeyword, pkCmd);
end;

destructor TUdActionFillet.Destroy;
begin
  if Assigned(FLine) then FLine.Free;
  if Assigned(FEntity1) then FEntity1.Selected := False;
  if Assigned(FEntity2) then FEntity2.Selected := False;
  inherited;
end;


function TUdActionFillet.GetFilletStatus: string;
begin
  if GFilletTrim then Result := '(TRIM mode)' else Result := '(NOTRIM mode)';
  Result := Result + ' ' + Format(sFilletStatus, [GFilletRadius]);
end;

procedure TUdActionFillet.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FEntity1) then FEntity1.Draw(ACanvas);
  if Assigned(FEntity2) then FEntity2.Draw(ACanvas);
  if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
end;



//---------------------------------------------------------------------------------------

function TUdActionFillet.Fillet(): Boolean;

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

   procedure _Fillet11(ASeg1, ASeg2: TSegment2D);
   var
     LFtArc: TArc2D;
     LSeg1, LSeg2: TSegment2D;
     LEntity: TUdEntity;
   begin
     if UdFillet2D.Fillet(GFilletRadius, FP1, FP2, ASeg1, ASeg2, LSeg1, LSeg2, LFtArc) = FILLET_SUCCESS then
     begin
       if GFilletTrim then
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

       if not IsEqual(LFtArc.R, 0.0) and (LFtArc.R > 0) then
       begin
         LEntity := TUdArc.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdArc(LEntity).XData := LFtArc;
         Self.AddEntity(LEntity);
       end;

       if GFilletTrim then
         _RemoveSelectedEntity();
     end;
   end;

   procedure _Fillet22(AArc1, AArc2: TArc2D);
   var
     LFtArc: TArc2D;
     LArc1, LArc2: TArc2D;
     LEntity: TUdEntity;
   begin
     if UdFillet2D.Fillet(GFilletRadius, FP1, FP2, AArc1, AArc2, LArc1, LArc2, LFtArc) = FILLET_SUCCESS then
     begin
       if GFilletTrim then
       begin
         LEntity := TUdArc.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdArc(LEntity).XData := LArc1;
         Self.AddEntity(LEntity);

         LEntity := TUdArc.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdArc(LEntity).XData := LArc2;
         Self.AddEntity(LEntity);
       end;

       if not IsEqual(LFtArc.R, 0.0) and (LFtArc.R > 0) then
       begin
         LEntity := TUdArc.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdArc(LEntity).XData := LFtArc;
         Self.AddEntity(LEntity);
       end;

       if GFilletTrim then
         _RemoveSelectedEntity();
     end;
   end;

   procedure _Fillet33(ASegarcs1, ASegarcs2: TSegarc2DArray);
   var
     LFtArc: TArc2D;
     LSegarcs: TSegarc2DArray;
     LEntity: TUdEntity;
   begin
     if UdFillet2D.Fillet(GFilletRadius, FP1, FP2, ASegarcs1, ASegarcs2, LSegarcs, LFtArc) = FILLET_SUCCESS then
     begin
       if GFilletTrim then
       begin
         LEntity := TUdPolyline.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdPolyline(LEntity).XData := LSegarcs;
         Self.AddEntity(LEntity);

         _RemoveSelectedEntity();
       end
       else begin
         if not IsEqual(LFtArc.R, 0.0) and (LFtArc.R > 0) then
         begin
           LEntity := TUdArc.Create(FDocument, False);
           LEntity.Assign(FEntity1);
           TUdArc(LEntity).XData := LFtArc;
           Self.AddEntity(LEntity);
         end;
       end;
     end;
   end;

   procedure _Fillet3(ASegarcs: TSegarc2DArray);
   var
     LFtArc: TArc2D;
     LSegarcs: TSegarc2DArray;
     LEntity: TUdEntity;
   begin
     if UdFillet2D.Fillet(GFilletRadius, FP1, FP2, ASegarcs, LSegarcs, LFtArc) = FILLET_SUCCESS then
     begin
       if GFilletTrim then
       begin
         LEntity := TUdPolyline.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdPolyline(LEntity).XData := LSegarcs;
         Self.AddEntity(LEntity);

         _RemoveSelectedEntity();
       end
       else begin
         if not IsEqual(LFtArc.R, 0.0) and (LFtArc.R > 0) then
         begin
           LEntity := TUdArc.Create(FDocument, False);
           LEntity.Assign(FEntity1);
           TUdArc(LEntity).XData := LFtArc;
           Self.AddEntity(LEntity);
         end;
       end;
     end;
   end;

   procedure _Fillet12(ASeg: TSegment2D; AArc: TArc2D);
   var
     LSeg: TSegment2D;
     LArc, LFtArc: TArc2D;
     LEntity: TUdEntity;
   begin
     if UdFillet2D.Fillet(GFilletRadius, FP1, FP2, ASeg, AArc, LSeg, LArc, LFtArc) = FILLET_SUCCESS then
     begin
       if GFilletTrim then
       begin
         LEntity := TUdLine.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdLine(LEntity).XData := LSeg;
         Self.AddEntity(LEntity);

         LEntity := TUdArc.Create(FDocument, False);
         LEntity.Assign(FEntity2);
         TUdArc(LEntity).XData := LArc;
         Self.AddEntity(LEntity);
       end;

       if not IsEqual(LFtArc.R, 0.0) and (LFtArc.R > 0) then
       begin
         LEntity := TUdArc.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdArc(LEntity).XData := LFtArc;
         Self.AddEntity(LEntity);
       end;

       if GFilletTrim then
         _RemoveSelectedEntity();       
     end;
   end;

   procedure _Fillet13(ASeg: TSegment2D; ASegarcs: TSegarc2DArray);
   var
     LFtArc: TArc2D;
     LSegarcs: TSegarc2DArray;
     LEntity: TUdEntity;
   begin
     if UdFillet2D.Fillet(GFilletRadius, FP1, FP2, ASeg, ASegarcs, LSegarcs, LFtArc) = FILLET_SUCCESS then
     begin
       if GFilletTrim then
       begin
         LEntity := TUdPolyline.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdPolyline(LEntity).XData := LSegarcs;
         Self.AddEntity(LEntity);

         _RemoveSelectedEntity();
       end
       else begin
         if not IsEqual(LFtArc.R, 0.0) and (LFtArc.R > 0) then
         begin
           LEntity := TUdArc.Create(FDocument, False);
           LEntity.Assign(FEntity1);
           TUdArc(LEntity).XData := LFtArc;
           Self.AddEntity(LEntity);
         end;
       end;
     end;
   end;

   procedure _Fillet23(AArc: TArc2D; ASegarcs: TSegarc2DArray);
   var
     LFtArc: TArc2D;
     LSegarcs: TSegarc2DArray;
     LEntity: TUdEntity;
   begin
     if UdFillet2D.Fillet(GFilletRadius, FP1, FP2, AArc, ASegarcs, LSegarcs, LFtArc) = FILLET_SUCCESS then
     begin
       if GFilletTrim then
       begin
         LEntity := TUdPolyline.Create(FDocument, False);
         LEntity.Assign(FEntity1);
         TUdPolyline(LEntity).XData := LSegarcs;
         Self.AddEntity(LEntity);

         _RemoveSelectedEntity();
       end
       else begin
         if not IsEqual(LFtArc.R, 0.0) and (LFtArc.R > 0) then
         begin
           LEntity := TUdArc.Create(FDocument, False);
           LEntity.Assign(FEntity1);
           TUdArc(LEntity).XData := LFtArc;
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
      _Fillet3(TUdPolyline(FEntity1).XData);
    end;
  end
  else begin
    if FEntity1.InheritsFrom(TUdLine) then
    begin
      if FEntity2.InheritsFrom(TUdLine) then _Fillet11(TUdLine(FEntity1).XData, TUdLine(FEntity2).XData) else
      if FEntity2.InheritsFrom(TUdArc)  then _Fillet12(TUdLine(FEntity1).XData, TUdArc(FEntity2).XData) else
      if FEntity2.InheritsFrom(TUdPolyline) then _Fillet13(TUdLine(FEntity1).XData, TUdPolyline(FEntity2).XData);
    end
    else if FEntity1.InheritsFrom(TUdArc) then
    begin
      if FEntity2.InheritsFrom(TUdLine) then begin Swap(FP1, FP2); _Fillet12(TUdLine(FEntity2).XData, TUdArc(FEntity1).XData); end else
      if FEntity2.InheritsFrom(TUdArc)  then _Fillet22(TUdArc(FEntity1).XData, TUdArc(FEntity2).XData) else
      if FEntity2.InheritsFrom(TUdPolyline) then _Fillet23(TUdArc(FEntity1).XData, TUdPolyline(FEntity2).XData);
    end
    else if FEntity1.InheritsFrom(TUdPolyline) then
    begin
      if FEntity2.InheritsFrom(TUdLine) then begin Swap(FP1, FP2); _Fillet13(TUdLine(FEntity2).XData, TUdPolyline(FEntity1).XData); end else
      if FEntity2.InheritsFrom(TUdArc)  then begin Swap(FP1, FP2); _Fillet23(TUdArc(FEntity2).XData, TUdPolyline(FEntity1).XData); end else
      if FEntity2.InheritsFrom(TUdPolyline) then _Fillet33(TUdPolyline(FEntity1).XData, TUdPolyline(FEntity2).XData);
    end;
  end;
end;

function TUdActionFillet.SelectFirstEntity(APnt: TPoint2D): Boolean;
var
  LEntity: TUdEntity;
begin
  Result := False;

  if (FStep <> 0) then Exit;

  LEntity := Self.PickEntity(APnt);
  if not Assigned(LEntity) then Exit;

  if not LEntity.InheritsFrom(TUdLine) and
     not LEntity.InheritsFrom(TUdArc) and
     not (LEntity.InheritsFrom(TUdPolyline) and (TUdPolyline(LEntity).SplineFlag in [sfStandard, sfCtrlPnts])) then
  begin
    Self.Prompt(sFilletError, pkLog);
    Exit;
  end;

  FP1 := APnt;
  FEntity1 := LEntity;
  FEntity1.Selected := True;

  Self.Prompt(sFilletObj1OrKeyword, pkLog);
  Self.Prompt(sFilletObj2, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionFillet.SelectSecondEntity(APnt: TPoint2D): Boolean;
var
  LEntity: TUdEntity;
begin
  Result := False;

  if (FStep <> 1) then Exit;

  LEntity := Self.PickEntity(APnt);
  if not Assigned(LEntity) then Exit;

  if not LEntity.InheritsFrom(TUdLine) and
     not LEntity.InheritsFrom(TUdArc) and
     not (LEntity.InheritsFrom(TUdPolyline) and (TUdPolyline(LEntity).SplineFlag in [sfStandard, sfCtrlPnts])) then
  begin
    Self.Prompt(sFilletError, pkLog);
    Exit;
  end;

  if not LEntity.InheritsFrom(TUdPolyline) and (LEntity = FEntity1) then Exit; //======>>>>


  FP2 := APnt;
  FEntity2 := LEntity;
  FEntity2.Selected := True;

  Self.Prompt(sFilletObj2, pkLog);

  Result := Fillet();

  if Result then
  begin
    FEntity1 := nil;
    FEntity2 := nil;
  end;

  Self.Finish();
end;

function TUdActionFillet.SelectPolylineEntity(APnt: TPoint2D): Boolean;
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
    if NotEqual(GFilletRadius, 0.0) then
    begin
      LSegarcs := TUdPolyline(LSelObj).XData;
      if TUdPolyline(LSelObj).SplineFlag = sfCtrlPnts then
        for I := 0 to System.Length(LSegarcs) - 1 do LSegarcs[I].IsArc := False;

      if UdFillet2D.Fillet(GFilletRadius, LSegarcs, LOutSegarcs) = FILLET_SUCCESS then
        TUdPolyline(LSelObj).XData := LOutSegarcs;
    end;

    Result := Finish();
  end;
end;


function TUdActionFillet.SetFilletRadius(const AValue: Float): Boolean;
begin
  Result := False;
  if not(FStep in [2, 3]) then Exit;  //2 3

  GFilletRadius := Abs(AValue);

  Self.Prompt(sFilletRadius + ': ' + RealToStr(GFilletRadius), pkLog);
  Self.Prompt(sFilletObj1OrKeyword, pkCmd);

  if Assigned(FEntity1) then FEntity1.Selected := False;
  if Assigned(FEntity2) then FEntity2.Selected := False;

  FEntity1 := nil;
  FEntity2 := nil;
  FLine.Visible := False;

  Self.CanOSnap := False;
  Self.SetCursorStyle(csPick);

  FStep := 0;
  Result := True;
end;

function TUdActionFillet.SetFilletRadiusP1(APnt: TPoint2D): Boolean;
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

function TUdActionFillet.SetFilletRadiusP2(APnt: TPoint2D): Boolean;
var
  LDis: Double;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FP2 := APnt;

  FLine.Visible := False;
  Self.Prompt(sSecondPoint, pkLog);

  LDis := Distance(FP1, FP2);
  Result := SetFilletRadius(LDis);
end;



//---------------------------------------------------------------------------------------

function TUdActionFillet.Parse(const AValue: string): Boolean;
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
      2,3: SetFilletRadius(GFilletRadius);
    end;
  end
  else if (LValue = 'r') or (LValue = 'radius') then
  begin
    if FStep = 0 then
    begin
      FStep := 2;
      Self.Prompt(sFilletObj1OrKeyword, pkLog);
      Self.Prompt(sFilletRadius + ' <' + RealToStr(GFilletRadius) + '>', pkCmd);

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
      Self.Prompt(sFilletObj1OrKeyword, pkLog);

      if GFilletTrim then LTrimStr := ': <T>' else LTrimStr := ': <N>';
      Self.Prompt(sTrimMode + LTrimStr, pkCmd);
      FStep := 6;
    end else
    if FStep = 6 then
    begin
      GFilletTrim := True;
      Self.Prompt(AValue, pkLog);

      FStep := 0;
      Self.Prompt(sFilletObj1OrKeyword, pkCmd);
    end
    else
      Self.Prompt(sRequirePointOrKeyword, pkLog);
  end
  else if (FStep = 6) and ((LValue = 'n') or (LValue = 'no')or (LValue = 'notrim')) then
  begin
    GFilletTrim := False;
    Self.Prompt(AValue, pkLog);

    FStep := 0;
    Self.Prompt(sFilletObj1OrKeyword, pkCmd);
  end

  else if IsNum(AValue) then
  begin
    if (FStep = 2) or (FStep = 3) then
      SetFilletRadius(StrToFloat(AValue))
    else
      Self.Prompt(sRequirePointOrKeyword, pkLog);
  end

  else if ParseCoord(AValue, LPnt, LIsOpp) then
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
      2: SetFilletRadiusP1(LPnt);
      3: SetFilletRadiusP1(LOppPnt);
      7: SelectPolylineEntity(LPnt);
    end;
  end
  else
    Self.Prompt(sRequirePointOrKeyword, pkLog);

  Result := True;
end;



procedure TUdActionFillet.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionFillet.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
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
            2: SetFilletRadiusP1(ACoordPnt);
            3: SetFilletRadiusP2(ACoordPnt);
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
              2,3: SetFilletRadius(GFilletRadius);
              6: begin
                   if GFilletTrim then LTrimStr := '<T>' else LTrimStr := '<N>';
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
        if (FStep = 3) then
        begin
          FP2 := ACoordPnt;
          FLine.EndPoint := FP2;
        end;
      end;
  end;
end;






end.