{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimTextAlign;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdDimStyle, UdLine, UdDimension, UdActionSelection, UdDimProps;

type
  TUdDimTextAlignKind = (takNone, takHome, takAngle, takLeft, takCenter, takRight);

  //*** TUdActionDimTextAlign ***//
  TUdActionDimTextAlign = class(TUdDimAction)
  private
    FLine: TUdLine;
    FKind: TUdDimTextAlignKind;

    FSelAction: TUdActionSelection;

  protected
    function SetSelDimsAlign(): Boolean;
    procedure OnSelActionFilter(Sender: TObject; AEntity: TUdEntity; var Allow: Boolean);
//    procedure OnSelActionOnSelected(Sender: TObject; AEntities: TUdEntityArray);

    function SetAnglePoint1(APnt: TPoint2D): Boolean;   // 1
    function SetAnglePoint2(APnt: TPoint2D): Boolean;   // 2
    function SetTextAngle(const AValue: Float): Boolean;      //
        
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    constructor CreateByEntities(ADocument: TUdObject; AEntities: TUdEntityArray; AKind: TUdDimTextAlignKind);

    destructor Destroy(); override;

    class function CommandName(): string; override;
    class function SetEntitesTextAlign(ADimStyle: TUdDimStyle; AEntities: TUdEntityArray; AKind: TUdDimTextAlignKind): Boolean;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;

  end;


function GetDimTextAlignKind(const AValue: string): TUdDimTextAlignKind;


implementation


uses
  SysUtils,
  UdLayout, UdMath, UdGeo2D, UdUtils, UdAcnConsts;



//=================================================================================================

function GetDimTextAlignKind(const AValue: string): TUdDimTextAlignKind;
var
  LValue: string;
begin
  Result := takNone;

  LValue := LowerCase(Trim(AValue));
  if LValue = '' then Exit;

  //takHome, takAngle, takLeft, takCenter, takRight
  if (LValue = 'h') or (Pos('home', LValue) > 0)    then Result  := takHome  else
  if (LValue = 'a') or (Pos('angle', LValue) > 0)   then Result  := takAngle else
  if (LValue = 'l') or (Pos('left', LValue) > 0)    then Result  := takLeft  else
  if (LValue = 'c') or (Pos('center', LValue) > 0)  then Result  := takCenter else
  if (LValue = 'r') or (Pos('right', LValue) > 0)   then Result  := takRight ;
end;




//=================================================================================================
{ TUdActionDimTextAlign }


class function TUdActionDimTextAlign.CommandName: string;
begin
  Result := 'dimalign';
end;


class function TUdActionDimTextAlign.SetEntitesTextAlign(ADimStyle: TUdDimStyle;
  AEntities: TUdEntityArray; AKind: TUdDimTextAlignKind): Boolean;

   procedure _AlignHome(ADimObj: TUdDimension);
   begin
     ADimObj.BeginUpdate();
     try
       ADimObj.TextAngle := -1;

       if Assigned(ADimStyle) then
       begin
         ADimObj.TextProp.HorizontalPosition := ADimStyle.TextProp.HorizontalPosition;
         ADimObj.TextProp.VerticalPosition   := ADimStyle.TextProp.VerticalPosition;
       end
       else begin
         ADimObj.TextProp.HorizontalPosition := htpCentered;
         ADimObj.TextProp.VerticalPosition   := vtpAbove;
       end;
     finally
       ADimObj.EndUpdate();
     end;
   end;

   procedure _AlignCenter(ADimObj: TUdDimension);
   begin
     ADimObj.TextProp.HorizontalPosition := htpCentered;
   end;


   procedure _AlignLeft(ADimObj: TUdDimension);
   var
     LP1, LP2: TPoint2D;
     LDimLineSup: IUdDimLineSupport;
   begin
     if ADimObj.GetInterface(IUdDimLineSupport, LDimLineSup) then
     begin
       LP1 := LDimLineSup.GetDimLine1Point();
       LP2 := LDimLineSup.GetDimLine2Point();
       if (LP1.X < LP2.X) then
         ADimObj.TextProp.HorizontalPosition := htpFirstExtensionLine
       else
         ADimObj.TextProp.HorizontalPosition := htpSecondExtensionLine;
     end;
   end;

   procedure _AlignRight(ADimObj: TUdDimension);
   var
     LP1, LP2: TPoint2D;
     LDimLineSup: IUdDimLineSupport;
   begin
     if ADimObj.GetInterface(IUdDimLineSupport, LDimLineSup) then
     begin
       LP1 := LDimLineSup.GetDimLine1Point();
       LP2 := LDimLineSup.GetDimLine2Point();
       if (LP1.X > LP2.X) then
         ADimObj.TextProp.HorizontalPosition := htpFirstExtensionLine
       else
         ADimObj.TextProp.HorizontalPosition := htpSecondExtensionLine;
     end;
   end;
   


var
  I: Integer;
  LDimObj: TUdDimension;
begin
  Result := False;
  if  (System.Length(AEntities) <= 0) then Exit; //=========>>>>>

  for I := 0 to System.Length(AEntities) - 1 do
  begin
    if not Assigned(AEntities[I]) or
       not AEntities[I].InheritsFrom(TUdDimension) then Continue;
    
    LDimObj := TUdDimension(AEntities[I]);

    case AKind of
      takHome  : _AlignHome(LDimObj);
      takLeft  : _AlignLeft(LDimObj);
      takCenter: _AlignCenter(LDimObj);
      takRight : _AlignRight(LDimObj);
    end;
  end;
end;



constructor TUdActionDimTextAlign.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  I, N: Integer;
  LArg: string;
  LLayout: TUdLayout;
begin
  inherited;

  LArg := Trim(Args);
  
  N := Pos(' ', LArg);
  if N > 0 then Delete(LArg, N, System.Length(LArg));

  FKind := GetDimTextAlignKind(LArg);
  if FKind = takNone then FKind := takHome;


  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;


  //------------------------------------------------------

  LLayout := TUdLayout(Self.GetLayout());

  for I := LLayout.Selection.Count - 1 downto 0 do
    if not LLayout.Selection.Items[I].InheritsFrom(TUdDimension) then
      LLayout.RemoveSelectedEntity(LLayout.Selection.Items[I]);


  //------------------------------------------------------


  FSelAction := TUdActionSelection.Create(FDocument, FLayout);
  FSelAction.OnFilter := OnSelActionFilter;
//  FSelAction.OnSelected := OnSelActionOnSelected;


  Self.CanSnap := False;
  Self.CanOSnap := False;
  Self.CanOrtho := False;
  Self.CanPerpend := False;

  Self.Prompt(sEditDimTextAlign + ':' + LArg, pkLog);

  if LLayout.Selection.Count > 0 then
  begin
    FSelAction.Visible := False;
    SetSelDimsAlign();

    if FKind <> takAngle then Self.Aborted := True;
  end
  else begin
    Self.Prompt(sSelectDimObject, pkCmd);
    
    FSelAction.Visible := True;
//    FSelAction.WindowingHint := FKind <> takAngle;
    
    Self.SetCursorStyle(csPick);
  end;
end;

constructor TUdActionDimTextAlign.CreateByEntities(ADocument: TUdObject; AEntities: TUdEntityArray;
  AKind: TUdDimTextAlignKind);
begin
  inherited Create(ADocument, FLayout);
  
  Self.CanSnap := False;
  Self.CanOSnap := False;
  Self.CanOrtho := False;
  Self.CanPerpend := False;



  FSelAction := nil;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;


 //------------------------------------------------------

  FKind := AKind;

  Self.RemoveAllSelected();
  Self.AddSelectedEntities(AEntities);

  SetSelDimsAlign();
  if FKind <> takAngle then Self.Aborted := True;
end;

destructor TUdActionDimTextAlign.Destroy;
begin
  if Assigned(FLine) then FLine.Free();

  if Assigned(FSelAction) then
  begin
    FSelAction.OnSelected  := nil;
    FSelAction.Free;
  end;

  inherited;
end;


//---------------------------------------------------

procedure TUdActionDimTextAlign.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
  end;
end;



//---------------------------------------------------


procedure TUdActionDimTextAlign.OnSelActionFilter(Sender: TObject; AEntity: TUdEntity; var Allow: Boolean);
begin
  Allow := Assigned(AEntity) and AEntity.InheritsFrom(TUdDimension);
end;

//procedure TUdActionDimTextAlign.OnSelActionOnSelected(Sender: TObject; AEntities: TUdEntityArray);
//var
//  I: Integer;
//begin
//  for I := 0 to System.Length(AEntities) - 1 do
//    if AEntities[I].InheritsFrom(TUdDimension) and (FSelDimList.IndexOf(AEntities[I]) < 0) then
//    begin
//      AEntities[I].Selected := True;
//      FSelDimList.Add(AEntities[I]);
//    end;
//
////  if (FKind = takAngle) and (FSelDimList.Count > 0) then  SetSelDimsAlign();
//end;

function TUdActionDimTextAlign.SetSelDimsAlign(): Boolean;
var
  LLayout: TUdLayout;
begin
  LLayout := TUdLayout(Self.GetLayout());
  
  if (LLayout.Selection.Count <= 0) then
  begin
    Result := Self.Finish();
  end
  else begin
    if Assigned(FSelAction) then FSelAction.Visible := False;

    if FKind = takAngle then
    begin
      Self.CanSnap := True;
      Self.CanOSnap := True;
      Self.CanOrtho := True;
      Self.CanPerpend := True;

      FStep := 1;
      Self.SetCursorStyle(csDraw);
      Self.Prompt(sDimTextAngle, pkCmd);
      
      Result := True;
    end
    else begin
      SetEntitesTextAlign(Self.DimStyle, Self.GetSelectedEntities(), FKind);
      Result := Self.Finish();
    end;
  end;
end;


function TUdActionDimTextAlign.SetAnglePoint1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 2;
  Result := True;
end;

function TUdActionDimTextAlign.SetAnglePoint2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FLine.EndPoint := APnt;
  FLine.Visible := False;

  Self.CanOrtho := True;
  Self.CanPerpend := True;

  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);

  Result := SetTextAngle(GetAngle(FLine.StartPoint, FLine.EndPoint));
end;


function TUdActionDimTextAlign.SetTextAngle(const AValue: Float): Boolean;
var
  I: Integer;
  LAng: Float;
  LList: TList;
begin
  Result := False;
  if not (FStep in [1, 2]) then Exit;

  LAng := FixAngle(AValue);

  LList := Self.GetSelectedEntityList();

  if Assigned(LList) then
    for I := 0 to LList.Count - 1 do
      if TObject(LList[I]).InheritsFrom(TUdDimension) then
         TUdDimension(LList[I]).TextAngle := LAng;

  Self.Prompt(sDimTextAngle + AngleToStr(AValue), pkLog);

  Result := Self.Finish();
end;



function TUdActionDimTextAlign.Parse(const AValue: string): Boolean;
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
    Result := Self.Finish();
    Exit;
  end;

  if FStep in [1, 2] then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      if FStep = 1 then
      begin
        SetTextAngle(D);
        FLine.Visible := False;
      end  else
      if FStep = 2 then
      begin
        LPnt := ShiftPoint(FLine.StartPoint, GetAngle(FLine.StartPoint, FLine.EndPoint), D);
        SetAnglePoint2(LPnt);
      end
      else begin
        Self.Prompt(sInvalidPoint, pkLog);
        Result := False;
      end;
    end else

    if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if FStep = 1 then
        SetAnglePoint1(LPnt)
      else if FStep = 2 then
      begin
        if LIsOpp then
        begin
          LPnt.X := FLine.StartPoint.X + LPnt.X;
          LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
        end;
        SetAnglePoint2(LPnt);
      end;
    end
    
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end;

end;


procedure TUdActionDimTextAlign.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FSelAction) and FSelAction.Visible then
    FSelAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionDimTextAlign.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
begin
  inherited;

  if Assigned(FSelAction) and FSelAction.Visible then
    FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);  

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 1 then
            SetAnglePoint1(ACoordPnt)
          else if FStep = 2 then
            SetAnglePoint2(ACoordPnt);
        end
        else if (AButton = mbRight) then
        begin
          if FStep = 0 then
            SetSelDimsAlign()
          else
            Self.Finish();
        end;
      end;
    mkMouseMove:
      begin
        if FStep = 2 then FLine.EndPoint := ACoordPnt;
      end;
  end;
end;




end.