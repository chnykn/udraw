{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDrawOrder;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction,
  UdActionSelection;

type
  TUdDrawOrderKind = (dokNone, dokAbove, dokUnder, dokFront, dokBack);

  //*** TUdActionDrawOrder ***//
  TUdActionDrawOrder = class(TUdAction)
  private
    FKind: TUdDrawOrderKind;

    FSelEntities: TList;
    FRefEntities: TList;

    FSelAction: TUdActionSelection;

  protected
    function DoStep0(): Boolean;
    function DoStep2(): Boolean;
    function DoStep3(): Boolean;
    
    procedure ApplyAction();

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    function Parse(const AValue: string): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;

    function CanPopMenu: Boolean; override;
  end;



implementation

uses
  SysUtils, UdLayout, UdUtils, UdAcnConsts;
  


  

function GetOrderKind(AValue: string): TUdDrawOrderKind;
var
  LArgs: string;
begin
  Result := dokNone;

  LArgs  := LowerCase(Trim(AValue));

  if (Pos('a', LArgs) = 1) or (Pos('above', LArgs) = 1) then Result := dokAbove else
  if (Pos('u', LArgs) = 1) or (Pos('under', LArgs) = 1) then Result := dokUnder else
  if (Pos('f', LArgs) = 1) or (Pos('front', LArgs) = 1) then Result := dokFront else
  if (Pos('b', LArgs) = 1) or (Pos('back',  LArgs) = 1) then Result := dokBack ;
end;

//function OrderKindToStr(AKind: TUdDrawOrderKind): string;
//begin
//  Result := '';
//  
//  case AKind of
//    dokAbove: Result := 'Above';
//    dokUnder: Result := 'Under';
//    dokFront: Result := 'Front';
//    dokBack : Result := 'Back';
//  end;
//end;




//================================================================================================
{ TUdActionDrawOrder }

class function TUdActionDrawOrder.CommandName: string;
begin
  Result := 'draworder';
end;


constructor TUdActionDrawOrder.Create(ADocument, ALayout: TUdObject; Args: string);
var
  I: Integer;
  LLayout: TUdLayout;
begin
  inherited;

  FSelAction := TUdActionSelection.Create(FDocument, FLayout);
  FSelAction.Visible := False;

  FSelEntities := TList.Create;
  FRefEntities := TList.Create;

  FKind := GetOrderKind(Args);

  Self.CanSnap    := False;
  Self.CanOSnap   := False;
  Self.CanOrtho   := False;
  Self.CanPerpend := False;


  LLayout := TUdLayout(Self.GetLayout());

  if Assigned(LLayout) then
  begin
    if LLayout.SelectedList.Count > 0 then
    begin
      for I := 0 to LLayout.SelectedList.Count - 1 do FSelEntities.Add(LLayout.SelectedList[I]);
      Self.RemoveAllSelected();
      
      if FKind in [dokFront, dokBack] then
      begin
        Self.Step := 1;
        
        Self.ApplyAction();
        Self.Aborted := True;
      end
      else if FKind in [dokAbove, dokUnder] then
      begin
        Self.Step := 3;
        FSelAction.Visible := True;

        Self.Prompt(sSelectRefObjs, pkCmd);
      end
      else begin
        Self.Step := 2;
        Self.Prompt(sEnterObjOrdering, pkCmd);
      end;
    end
    else begin
      FSelAction.Visible := True;
      Self.Prompt(sSelectObject, pkCmd);
    end;

    Self.SetCursorStyle(csPick);
  end
  else Self.Aborted := True;
end;

destructor TUdActionDrawOrder.Destroy;
begin
  if Assigned(FSelEntities) then FSelEntities.Free();
  FSelEntities := nil;

  if Assigned(FRefEntities) then FRefEntities.Free();
  FRefEntities := nil;
    
  if Assigned(FSelAction) then FSelAction.Free();
  FSelAction := nil;

  inherited;
end;



procedure TUdActionDrawOrder.ApplyAction();
var
  I, N: Integer;
  N1, N2: Integer;
  LEntity: TUdEntity;
  LLayout: TUdLayout;
begin
  if (FSelEntities.Count <= 0) then Exit; //=======>>>>

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=======>>>>

  if FKind in [dokFront, dokBack] then
  begin
    for I := 0 to FSelEntities.Count - 1 do
    begin
      LEntity := FSelEntities[I];
      N := LLayout.Entities.List.IndexOf(LEntity);

      if N >= 0 then
      begin
        LLayout.Entities.List.Delete(N);
        
        if FKind = dokFront then
          LLayout.Entities.List.Add(LEntity)
        else
          LLayout.Entities.List.Insert(0, LEntity);
      end;
    end;

    LLayout.UpdateVisibleList();
  end
  else if FKind in [dokAbove, dokUnder] then
  begin
    if (FRefEntities.Count <= 0) then Exit; //=======>>>>
    {
    for I := FRefEntities.Count - 1 downto 0 do
    begin
      LEntity := FRefEntities[I];

      N := FSelEntities.IndexOf(LEntity);
      if N >= 0 then FRefEntities.Delete(I);
    end;

    if (FRefEntities.Count <= 0) then
    begin
      Self.Prompt(sCannotUseSameObj, pkLog);
      Exit; //=======>>>>
    end;
    }

    for I := FSelEntities.Count - 1 downto 0 do
    begin
      LEntity := FSelEntities[I];
      N := LLayout.Entities.List.IndexOf(LEntity);

      if N >= 0 then
        LLayout.Entities.List.Delete(N)
      else
        FSelEntities.Delete(I);
    end;

    N1 := -1;
    N2 := -1;
    for I := 0 to FRefEntities.Count - 1 do
    begin
      LEntity := FRefEntities[I];

      N := LLayout.Entities.List.IndexOf(LEntity);
      if N >= 0 then
      begin
        if (N1 < 0) or (N < N1) then N1 := N;
        if (N2 < 0) or (N > N2) then N2 := N;
      end;
    end;

    if (N1 < 0) or (N2 < 0) then
    begin
      for I := 0 to FSelEntities.Count - 1 do LLayout.Entities.List.Add(FSelEntities[I]);
      Exit; //=======>>>>
    end;


    for I := 0 to FSelEntities.Count - 1 do
    begin
      LEntity := FSelEntities[I];

      if FKind = dokAbove then
        LLayout.Entities.List.Insert(N2+1, LEntity)
      else
        LLayout.Entities.List.Insert(N1, LEntity);
    end;
        
    LLayout.UpdateVisibleList();
  end;
end;




//--------------------------------------------------------------------------

procedure TUdActionDrawOrder.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if FVisible then
  begin
    if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
  end;
end;


function TUdActionDrawOrder.DoStep0(): Boolean;
var
  I: Integer;
  LLayout: TUdLayout;
begin
  Result := False;
  if FStep <> 0 then Exit;  //=======>>>>
  
  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=======>>>>
  
  if LLayout.SelectedList.Count > 0 then
  begin
    for I := 0 to LLayout.SelectedList.Count - 1 do FSelEntities.Add(LLayout.SelectedList[I]);
    Self.RemoveAllSelected();
      
    if FKind in [dokFront, dokBack] then
    begin
      Self.Step := 1;

      Self.ApplyAction();
      Self.Finish();
    end
    else if FKind in [dokAbove, dokUnder] then
    begin
      Self.Step := 3;
      FSelAction.Visible := True;

      Self.Prompt(sSelectRefObjs, pkCmd);
    end
    else begin
      Self.Step := 2;
      Self.Prompt(sEnterObjOrdering, pkCmd);
    end;

    Result := True;
  end
  else begin
    Result := False;
  end;
end;

function TUdActionDrawOrder.DoStep2(): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;  //=======>>>>

  FKind := dokBack;

  Self.Step := 3;
  FSelAction.Visible := True;

  Self.Prompt(sEnterObjOrdering, pkLog);
  Self.Prompt(sSelectRefObjs, pkCmd);

  Result := True;
end;

function TUdActionDrawOrder.DoStep3(): Boolean;
var
  I, N: Integer;
  LEntity: TUdEntity;
  LLayout: TUdLayout;
begin
  Result := False;
  if FStep <> 3 then Exit;  //=======>>>>

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=======>>>>

  if LLayout.SelectedList.Count > 0 then
  begin
    for I := 0 to LLayout.SelectedList.Count - 1 do FRefEntities.Add(LLayout.SelectedList[I]);
    Self.RemoveAllSelected();

    for I := FRefEntities.Count - 1 downto 0 do
    begin
      LEntity := FRefEntities[I];

      N := FSelEntities.IndexOf(LEntity);
      if N >= 0 then FRefEntities.Delete(I);
    end;

    if (FRefEntities.Count > 0) then
    begin
      Self.ApplyAction();
      Self.Finish();

      Result := True;
    end
    else
      Self.Prompt(sCannotUseSameObj, pkLog);
  end
  else
    Self.Prompt(sSelectRefObjs, pkLog);
end;


function TUdActionDrawOrder.Parse(const AValue: string): Boolean;
var
  LValue: string;
begin
  Result := True;
  
  LValue := LowerCase(Trim(AValue));

  if LValue = '' then
  begin
    if FStep = 0 then
    begin
      if not Self.DoStep0() then Self.Finish();
    end
    else if FStep = 2 then
    begin
      Self.DoStep2();
    end
    else if FStep = 3 then
    begin
      Self.DoStep3();
    end;

    Exit; //=====>>>>>
  end;

  if FStep = 2 then
  begin
    FKind := GetOrderKind(LValue);

    if FKind <> dokNone then
    begin
      Self.Step := 3;
      FSelAction.Visible := True;

      Self.Prompt(sEnterObjOrdering + ':' + AValue, pkLog);
      Self.Prompt(sSelectRefObjs, pkCmd);
    end
    else begin
      Self.Prompt(sRequireKeyword, pkLog);
      Result := False;
    end;
  end;
end;


procedure TUdActionDrawOrder.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionDrawOrder.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;
  
  if FSelAction.Visible then
    FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 2 then
          begin
            Self.DoStep2();
          end;
        end

        else if (AButton = mbRight) then
        begin
          if FStep = 0 then
          begin
            if not Self.DoStep0() then Self.Finish();
          end
          else if FStep = 2 then
          begin
            Self.DoStep2();
          end
          else if FStep = 3 then
          begin
            Self.DoStep3();
          end
          else
            Self.Finish();
        end;
      end;
    mkMouseMove:
      begin

      end;
  end;
end;


function TUdActionDrawOrder.CanPopMenu(): Boolean;
begin
  Result := False;
end;



end.