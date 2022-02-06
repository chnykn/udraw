{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionBlock;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction,
  UdActionSelection, UdActionBlockFrm;

type
  //*** TUdActionBlock ***//
  TUdActionBlock = class(TUdAction)
  private
    FBlockForm: TUdActionBlockForm;
    FSelAction: TUdActionSelection;

    FBlockApply: TUdBlockApply;

  protected
    function ApplyAddBlock(): Boolean;
    function ShowBlockForm(InCreating: Boolean = False): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;

    function CanPopMenu: Boolean; override;
  end;  

implementation


uses
  SysUtils,
  UdLayout, UdBlock, UdInsert,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;



//=========================================================================================
{ TUdActionBlock }

class function TUdActionBlock.CommandName: string;
begin
  Result := 'block';
end;

constructor TUdActionBlock.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FSelAction := TUdActionSelection.Create(FDocument, FLayout);
  FSelAction.Visible := False;

  FBlockForm := TUdActionBlockForm.Create(nil);
  FBlockForm.Document := FDocument;

  Self.ShowBlockForm(True);
end;

destructor TUdActionBlock.Destroy;
begin
  if Assigned(FSelAction) then FSelAction.Free();
  FSelAction := nil;

  if Assigned(FBlockForm) then FBlockForm.Free();
  FBlockForm := nil;

  inherited;
end;


//---------------------------------------------------

procedure TUdActionBlock.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
  end;
end;



function TUdActionBlock.ApplyAddBlock(): Boolean;

  function _ConvertToBlock(ABlock: TUdBlock): Boolean;
  var
    LInsert: TUdInsert;
  begin
    LInsert := TUdInsert.Create(FDocument, False);
    LInsert.Position := ABlock.Origin;
    LInsert.Block := ABlock;

    Result := Self.AddEntity(LInsert);
  end;

var
  I: Integer;
  LList: TList;
  LBlock: TUdBlock;
  LIsExists: Boolean;
begin
  Result := False;
  if not Assigned(Self.Blocks) then Exit;

  LBlock := Self.Blocks.GetItem(FBlockForm.BlockName);
  LIsExists := Assigned(LBlock);

  if LIsExists then
  begin
    LList := Self.GetSelectedEntityList();
    if Assigned(LList) then
    begin
      for I := 0 to LList.Count - 1 do
      begin
        if TObject(LList[I]).InheritsFrom(TUdInsert) and (TUdInsert(LList[I]).Block = LBlock) then
        begin
          Self.Prompt('Block "' + FBlockForm.BlockName +'" references itself.', pkLog);
          Exit; //======>>>>>
        end;
      end;
    end;
  end;

  Result := True;

  if LIsExists then
  begin
    Result := LBlock.RaiseBeforeModifyObject('Entities');
  end
  else begin
    LBlock := TUdBlock.Create(FDocument, False);
    LBlock.Name := FBlockForm.BlockName;
  end;

  if Result then
  begin
    LBlock.Entities.Clear();
    LBlock.Origin := FBlockForm.BlockOrigin;
    LBlock.Description := FBlockForm.BlockDescription;

    LList := Self.GetSelectedEntityList();
    if Assigned(LList) then
    begin
      for I := 0 to LList.Count - 1 do
        LBlock.Entities.Add( TUdEntity(LList[I]).Clone() );
    end;

    case FBlockForm.SelObjsAcn of
      1: begin TUdLayout(Self.Layout).EraseSelectedEntities(); _ConvertToBlock(LBlock); end;
      2: TUdLayout(Self.Layout).EraseSelectedEntities();
    end;

    if LIsExists then
    begin
      LBlock.RaiseAfterModifyObject('Entities');
    end
    else begin
      Self.Blocks.Add(LBlock);
    end;
  end
  else begin
//    Self.Prompt('', pmLog);
  end;
end;

function TUdActionBlock.ShowBlockForm(InCreating: Boolean = False): Boolean;
begin
  Result := True;
  FBlockForm.ShowModal();

  if FBlockForm.ApplyResult in [baNone, baCancel] then
  begin
    if InCreating then Self.Aborted := True else Self.Finish();
  end
  else if FBlockForm.ApplyResult = baOk then
  begin
    Self.ApplyAddBlock();
    if InCreating then Self.Aborted := True else Self.Finish();
  end
  else begin
    FBlockApply := FBlockForm.ApplyResult;
    FSelAction.Visible := FBlockApply = baSelObjs;
    if FBlockApply = baSelObjs then Self.RemoveAllSelected();

    case FBlockApply of
      baPickPnts: Self.Prompt(sInsBasePoint, pkCmd);
      baSelObjs : Self.Prompt(sSelectObject, pkCmd);
    end;

    Self.CanSnap  := FBlockApply = baPickPnts;
    Self.CanOSnap := FBlockApply = baPickPnts;
    Self.CanOrtho := False;

    case FBlockApply of
      baPickPnts: Self.SetCursorStyle(csDraw);
      baSelObjs : Self.SetCursorStyle(csPick);
    end;
  end;
end;




//---------------------------------------------------

function TUdActionBlock.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := True;
  if Assigned(FSelAction) and FSelAction.Visible then
  begin
    FSelAction.Parse(AValue);
    Exit; //======>>>>
  end;

  LValue := LowerCase(Trim(AValue));

  if LValue = '' then
  begin
    //.....
    Exit;
  end;

  if FBlockApply = baPickPnts then
  begin
    if ParseCoord(AValue, LPnt, LIsOpp) then
    begin
      FBlockForm.edtX.Text := FloatToStr(LPnt.X);
      FBlockForm.edtY.Text := FloatToStr(LPnt.Y);
      Self.ShowBlockForm();
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end;
end;


procedure TUdActionBlock.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FSelAction) and FSelAction.Visible then
    FSelAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionBlock.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  if FSelAction.Visible then
    FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if (FBlockApply = baPickPnts) then
          begin
            FBlockForm.BlockOrigin := ACoordPnt;
            Self.ShowBlockForm();
          end;
        end
        else if (AButton = mbRight) then
        begin
          if (FBlockApply = baPickPnts) then
          begin
            Self.ShowBlockForm();
          end else
          if (FBlockApply = baSelObjs) then
          begin
            FSelAction.Visible := False;
            Self.ShowBlockForm();
          end;
        end;
      end;
    mkMouseMove:
      begin
        //...
      end;
  end;
end;



function TUdActionBlock.CanPopMenu: Boolean;
begin
  Result := False;
end;



end.