{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionEditHatch;

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdIntfs, UdEvents, UdObject, UdAction,
  UdEntity, UdHatch;

type  
  //*** TUdActionEditHatch ***//
  TUdActionEditHatch = class(TUdAction)
  private

  protected
    procedure EditHatch(AHatchObj: TUdHatch);
    function PickHatchObj(APnt: TPoint2D): TUdHatch;
    
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;  

implementation

uses
  UdLayout, UdAcnConsts, UdActionHatchFrm;


//==================================================================================================
{ TUdActionEditHatch }

class function TUdActionEditHatch.CommandName: string;
begin
  Result := 'edithatch';
end;

constructor TUdActionEditHatch.Create(ADocument, ALayout: TUdObject; Args: string);
var
  LLayout: TUdLayout;
begin
  inherited;

  Self.SetCursorStyle(csPick);

  LLayout := TUdLayout( Self.GetLayout() );

  if Assigned(LLayout) then
  begin
    if (LLayout.SelectedList.Count = 1) and TObject(LLayout.SelectedList[0]).InheritsFrom(TUdHatch) then
    begin
      Self.EditHatch(TUdHatch(LLayout.SelectedList[0]));
      Self.Aborted := True; 
    end
    else begin
      Self.RemoveAllSelected();
      Self.Prompt(sSelectHatchObject, pkCmd);
    end;
  end
  else
    Self.Aborted := True;  
end;

destructor TUdActionEditHatch.Destroy;
begin

  inherited;
end;





procedure TUdActionEditHatch.EditHatch(AHatchObj: TUdHatch);
var
  LForm: TUdActionHatchForm;
begin
  if not Assigned(AHatchObj) then Exit;
  
  LForm := TUdActionHatchForm.Create(nil);
  try
    LForm.Document := Self.Document;

    LForm.HatchStyle  := Ord(AHatchObj.Style);
    LForm.HatchScale  := AHatchObj.HatchScale ;
    LForm.HatchAngle  := AHatchObj.HatchAngle ;
    LForm.PatternName := AHatchObj.PatternName;
    LForm.CalcPreviewSegments();

    LForm.gbBoundaries.Enabled := False;
    LForm.btnPickPnts.Enabled := False;
    LForm.btnSelObjs.Enabled := False;
    LForm.Label5.Enabled := False;
    LForm.Label6.Enabled := False;

    LForm.ShowModal();
    
    if LForm.ApplyResult = haOk then
    begin
      AHatchObj.BeginUpdate();
      try
        AHatchObj.Style := TUdHatchStyle(LForm.HatchStyle);
        AHatchObj.HatchScale  := LForm.HatchScale ;
        AHatchObj.HatchAngle  := LForm.HatchAngle ;
        AHatchObj.PatternName := LForm.PatternName;
      finally
        AHatchObj.EndUpdate();
      end;
    end;
    
//    LForm.ckxSpcHeight.Checked := False;
//    LForm.ckxSpcHeight.Enabled := False;
//
//    LForm.ckxSpcRotation.Checked := False;
//    LForm.ckxSpcRotation.Enabled := False;
//
//    LForm.ckxSpcPoint.Checked := False;
//    LForm.ckxSpcPoint.Enabled := False;
//
//    LForm.edtX.Enabled := False;
//    LForm.edtY.Enabled := False;
  finally
    LForm.Free;
  end;
end;

function TUdActionEditHatch.PickHatchObj(APnt: TPoint2D): TUdHatch;
var
  LEntity: TUdEntity;
  LLayout: TUdLayout;
begin
  Result := nil;
  LLayout := TUdLayout( Self.GetLayout() );

  if Assigned(LLayout) then
  begin
    LEntity := LLayout.PickEntity(APnt);
    if Assigned(LEntity) and LEntity.InheritsFrom(TUdHatch) then Result := TUdHatch(LEntity);
  end;
end;



procedure TUdActionEditHatch.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

end;


procedure TUdActionEditHatch.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionEditHatch.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LHatchObj: TUdHatch;
begin
  inherited;

  if (AKind = mkMouseDown) then
  begin
    case AButton of
      mbLeft :
      begin
        LHatchObj := Self.PickHatchObj(ACoordPnt);
        if Assigned(LHatchObj) then
        begin
          Self.EditHatch(LHatchObj);
          Self.Finish();
        end;
      end;
      
      mbRight: Self.Finish();
    end;

  end;  
end;



end.