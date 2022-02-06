{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimUpdate;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdDimension, UdActionSelection, UdDimStyle;

type

  //*** TUdActionDimUpdate ***//
  TUdActionDimUpdate = class(TUdDimAction)
  private
//    FDimObjs: TList;
    FSelAction: TUdActionSelection;

  protected
    procedure OnSelActionFilter(Sender: TObject; AEntity: TUdEntity; var Allow: Boolean);
    procedure OnSelActionSelected(Sender: TObject; AEntities: TUdEntityArray);

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    class function UpdateDimObjsStyle(AEntities: TUdEntityArray; ADimStyle: TUdDimStyle): Boolean;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;

  end;



implementation


uses
  SysUtils,
  UdLayout, UdAcnConsts;




//=================================================================================================
{ TUdActionDimUpdate }


class function TUdActionDimUpdate.CommandName: string;
begin
  Result := 'dimaupdate';
end;


class function TUdActionDimUpdate.UpdateDimObjsStyle(AEntities: TUdEntityArray; ADimStyle: TUdDimStyle): Boolean;
var
  I: Integer;
  LDimObj: TUdDimension;
begin
  Result := False;
  if not Assigned(ADimStyle) or (System.Length(AEntities) <= 0) then Exit; //=========>>>>>

  for I := 0 to System.Length(AEntities) - 1 do
  begin
    if not Assigned(AEntities[I]) or
       not AEntities[I].InheritsFrom(TUdDimension) then Continue;
    
    LDimObj := TUdDimension(AEntities[I]);
    LDimObj.UpdateByDimStyle(ADimStyle);
  end;
end;



constructor TUdActionDimUpdate.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FSelAction := TUdActionSelection.Create(FDocument, FLayout);
  FSelAction.OnFilter := OnSelActionFilter;
//  FSelAction.OnSelected := OnSelActionSelected;

//  FDimObjs := TList.Create;

  Self.SetCursorStyle(csPick);
  Self.Prompt(sSelectObject,pkCmd);
end;

destructor TUdActionDimUpdate.Destroy;
begin
  if Assigned(FSelAction) then
  begin
    FSelAction.OnFilter  := nil;
//    FSelAction.OnSelected  := nil;
    FSelAction.Free;
  end;

//  if Assigned(FDimObjs) then
//  begin
//    for I := 0 to FDimObjs.Count - 1 do TUdEntity(FDimObjs[I]).Selected := False;
//    FDimObjs.Free;
//  end;

  inherited;
end;


//---------------------------------------------------

procedure TUdActionDimUpdate.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
//    for I := 0 to FDimObjs.Count - 1 do TUdEntity(FDimObjs[I]).Draw(ACanvas);
    if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
  end;
end;



//---------------------------------------------------

procedure TUdActionDimUpdate.OnSelActionFilter(Sender: TObject; AEntity: TUdEntity; var Allow: Boolean);
begin
  Allow := Assigned(AEntity) and AEntity.InheritsFrom(TUdDimension);
end;

procedure TUdActionDimUpdate.OnSelActionSelected(Sender: TObject; AEntities: TUdEntityArray);
//var
//  I: Integer;
begin
//  for I := 0 to System.Length(AEntities) - 1 do
//    if AEntities[I].InheritsFrom(TUdDimension) and (FSelDimList.IndexOf(AEntities[I]) < 0) then
//    begin
//      AEntities[I].Selected := True;
//      FSelDimList.Add(AEntities[I]);
//    end;
end;


function TUdActionDimUpdate.Parse(const AValue: string): Boolean;
var
  LValue: string;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));
  if LValue = '' then
  begin
    Result := Self.Finish();
  end;

end;


procedure TUdActionDimUpdate.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FSelAction) and FSelAction.Visible then
    FSelAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionDimUpdate.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  I: Integer;
  LList: TList;
  LEntities: TUdEntityArray;
begin
  inherited;

  if (AKind = mkMouseDown) and (AButton = mbRight) then
  begin
    if Assigned(FDocument) then
    begin
      LList := Self.GetSelectedEntityList();
      if Assigned(LList) then
      begin
        System.SetLength(LEntities, LList.Count);
        for I := 0 to LList.Count - 1 do LEntities[I] := LList[I];

        UpdateDimObjsStyle(LEntities, Self.DimStyle);
      end;
    end;

    Self.Finish();
  end
  else begin
    if Assigned(FSelAction) and FSelAction.Visible then
      FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
  end;
end;





end.