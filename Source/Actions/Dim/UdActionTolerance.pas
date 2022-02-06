{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionTolerance;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdAction, UdBaseActions,
  UdTolerance;

type
  //*** TUdActionDimRotated ***//
  TUdActionTolerance = class(TUdDimAction)
  private
    FDimObj: TUdTolerance;

  protected
    function SetPoint(APnt: TPoint2D): Boolean;  // 1

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
  UdUtils, UdAcnConsts, UdToleranceFrm;



//=========================================================================================
{ TUdActionTolerance }

class function TUdActionTolerance.CommandName: string;
begin
  Result := 'tolerance';
end;

constructor TUdActionTolerance.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  LStr: string;
  LForm: TUdToleranceForm;
begin
  inherited;

  FDimObj := nil;

  if Assigned(FDocument) then
  begin
    LForm := TUdToleranceForm.Create(nil);
    try
      if Assigned(Self.TextStyles) then
        LForm.GdtShx := Self.TextStyles.GetItem('__GDT').ShxFont;

      if (LForm.ShowModal() = mrOk) then
      begin
        LStr := Trim(LForm.ToleranceText);

        if Trim(LStr) <> '' then
        begin
          FDimObj := TUdTolerance.Create(FDocument, False);

          if Assigned(Self.DimStyle) then
            FDimObj.TextHeight := Self.DimStyle.TextProp.TextHeight
          else
            FDimObj.TextHeight := 2.5;

          FDimObj.Contents   := LStr;
        end;
      end;
    finally
      LForm.Free;
    end;
  end;

  if Assigned(FDimObj) then
    Self.Prompt(sEnterTolPoint, pkCmd)
  else
    Self.Aborted := True;
end;

destructor TUdActionTolerance.Destroy;
begin
  if Assigned(FDimObj) then FDimObj.Free();

  inherited;
end;


//---------------------------------------------------

procedure TUdActionTolerance.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FDimObj) and FDimObj.Visible then FDimObj.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionTolerance.SetPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if not Assigned(FDimObj) then Exit;

  FDimObj.BeginUpdate();
  try
    FDimObj.Point := APnt;
    FDimObj.Finished := True;
  finally
    FDimObj.EndUpdate();
  end;

  Self.Submit(FDimObj);
  FDimObj := nil;

  Self.Prompt(sEnterTolPoint + ':' + PointToStr(APnt), pkLog);
  Result := Self.Finish;
end;


//---------------------------------------------------

function TUdActionTolerance.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := False;

  LValue := LowerCase(Trim(AValue));
  if LValue = '' then
  begin
    Self.Finish();
    Exit;
  end;

  if ParseCoord(LValue, LPnt, LIsOpp) then
    SetPoint(LPnt)
  else
    Self.Prompt(sInvalidPoint, pkLog);

  Result := True;
end;


procedure TUdActionTolerance.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionTolerance.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
          SetPoint(ACoordPnt)
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        FDimObj.Point := ACoordPnt;
      end;
  end;
end;





end.