{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionCutClip;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdIntfs, UdEvents, UdObject, UdAction,
  UdEntity, UdActionSelection;

type  
  //*** TUdActionCutClip ***//
  TUdActionCutClip = class(TUdAction)
  private
    FSelAction: TUdAction;

  protected
    function IsCopyClip(): Boolean; virtual;
    
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;

    function CanPopMenu: Boolean; override;
  end;  
  

implementation

uses
  SysUtils,
  UdLayout, UdLayer, UdUtils, UdAcnConsts;

  
//==================================================================================================
{ TUdActionCutClip }


class function TUdActionCutClip.CommandName: string;
begin
  Result := 'cutclip';
end;

constructor TUdActionCutClip.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  LOK: Boolean;
  LCCPSupport: IUdCCPSupport;
begin
  inherited;


  FSelAction := TUdActionSelection.Create(FDocument, ALayout);
  Self.SetCursorStyle(csPick);

  if Assigned(FDocument) and FDocument.GetInterface(IUdCCPSupport, LCCPSupport) then
  begin
    if IsCopyClip() then LOK := LCCPSupport.CopyClip() else LOK := LCCPSupport.CutClip();
    if LOK then
      Self.Aborted := True
    else
      Self.Prompt(sSelectObject, pkCmd);
  end
  else Self.Aborted := True;
end;

destructor TUdActionCutClip.Destroy;
begin
  if Assigned(FSelAction) then FSelAction.Free;
  FSelAction := nil;
  
  inherited;
end;



function TUdActionCutClip.IsCopyClip: Boolean;
begin
  Result := False;
end;






procedure TUdActionCutClip.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
end;



procedure TUdActionCutClip.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionCutClip.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LCCPSupport: IUdCCPSupport;
begin
  inherited;

  if FSelAction.Visible then
    FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);

  if (AKind = mkMouseDown) and (AButton = mbRight) then
  begin
    if Assigned(FDocument) and FDocument.GetInterface(IUdCCPSupport, LCCPSupport) then
    begin
      if IsCopyClip() then LCCPSupport.CopyClip() else LCCPSupport.CutClip();
    end;
    
    Self.Finish()
  end;
end;


function TUdActionCutClip.CanPopMenu: Boolean;
begin
  Result := False;
end;


end.