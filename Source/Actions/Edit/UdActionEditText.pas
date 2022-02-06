{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionEditText;

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdIntfs, UdEvents, UdObject, UdAction,
  UdEntity, UdText;

type  
  //*** TUdActionEditText ***//
  TUdActionEditText = class(TUdAction)
  private

  protected
    procedure EditText(ATextObj: TUdText);
    function PickTextObj(APnt: TPoint2D): TUdText;
    
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
  UdLayout, UdAcnConsts, UdTextParamsFrm;


//==================================================================================================
{ TUdActionEditText }

class function TUdActionEditText.CommandName: string;
begin
  Result := 'edittext';
end;

constructor TUdActionEditText.Create(ADocument, ALayout: TUdObject; Args: string);
var
  LLayout: TUdLayout;
begin
  inherited;

  Self.SetCursorStyle(csPick);

  LLayout := TUdLayout( Self.GetLayout() );

  if Assigned(LLayout) then
  begin
    if (LLayout.SelectedList.Count = 1) and TObject(LLayout.SelectedList[0]).InheritsFrom(TUdText) then
    begin
      Self.EditText(TUdText(LLayout.SelectedList[0]));
      Self.Aborted := True; 
    end
    else begin
      Self.RemoveAllSelected();
      Self.Prompt(sSelectTextObject, pkCmd);
    end;
  end
  else
    Self.Aborted := True;  
end;

destructor TUdActionEditText.Destroy;
begin

  inherited;
end;





procedure TUdActionEditText.EditText(ATextObj: TUdText);
var
  LForm: TUdTextParamsForm;
begin
  if not Assigned(ATextObj) then Exit;
  
  LForm := TUdTextParamsForm.Create(nil);
  try
    LForm.Document := Self.Document;
    LForm.TextObj := ATextObj;

    LForm.ckxSpcHeight.Checked := False;
    LForm.ckxSpcHeight.Enabled := False;

    LForm.ckxSpcRotation.Checked := False;
    LForm.ckxSpcRotation.Enabled := False;

    LForm.ckxSpcPoint.Checked := False;
    LForm.ckxSpcPoint.Enabled := False;

    LForm.edtX.Enabled := False;
    LForm.edtY.Enabled := False;

    LForm.ShowModal();
  finally
    LForm.Free;
  end;
end;

function TUdActionEditText.PickTextObj(APnt: TPoint2D): TUdText;
var
  LEntity: TUdEntity;
  LLayout: TUdLayout;
begin
  Result := nil;
  LLayout := TUdLayout( Self.GetLayout() );

  if Assigned(LLayout) then
  begin
    LEntity := LLayout.PickEntity(APnt);
    if Assigned(LEntity) and LEntity.InheritsFrom(TUdText) then Result := TUdText(LEntity);
  end;
end;



procedure TUdActionEditText.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

end;


procedure TUdActionEditText.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionEditText.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LTextObj: TUdText;
begin
  inherited;

  if (AKind = mkMouseDown) then
  begin
    case AButton of
      mbLeft :
      begin
        LTextObj := Self.PickTextObj(ACoordPnt);
        if Assigned(LTextObj) then
        begin
          Self.EditText(LTextObj);
          Self.Finish();
        end;
      end;
      
      mbRight: Self.Finish();
    end;

  end;  
end;


end.