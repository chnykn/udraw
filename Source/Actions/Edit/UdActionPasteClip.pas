{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdActionPasteClip;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdIntfs, UdEvents, UdObject, UdAction,
  UdEntity;

type  
  //*** TUdActionPasteClip ***//
  TUdActionPasteClip = class(TUdAction)
  private
    FP1, FP2: TPoint2D;
    
    FOrgnEntities: TUdEntityArray;
    FTaskEntities: TUdEntityArray;
    
  protected
    function UpdateTaskEntities(): Boolean;
    function Submit(APnt: TPoint2D): Boolean;

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
  SysUtils,
  UdLayout, UdUtils, UdAcnConsts;

  
//==================================================================================================
{ TUdActionPasteClip }

class function TUdActionPasteClip.CommandName: string;
begin
  Result := 'pasteclip';
end;

constructor TUdActionPasteClip.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  I: Integer;
  LBound: TRect2D;
  LEntity: TUdEntity;
  LCCPSupport: IUdCCPSupport;
begin
  inherited;

  Self.CanSnap := True;
  Self.CanOSnap := True;
    
  FOrgnEntities := nil;
  FTaskEntities := nil;

  Self.SetCursorStyle(csDraw);

  if Assigned(FDocument) and FDocument.GetInterface(IUdCCPSupport, LCCPSupport) then
  begin
    FOrgnEntities := TUdEntityArray(LCCPSupport.PasteClip());

    System.SetLength(FTaskEntities, System.Length(FOrgnEntities));
    for I := 0 to System.Length(FOrgnEntities) - 1 do
    begin
      LEntity := FOrgnEntities[I];
      FTaskEntities[I] := LEntity.Clone();
      FTaskEntities[I].Visible := False;
    end;

    
    if Length(FOrgnEntities) > 0 then
    begin
      LBound := UdUtils.GetEntitiesBound(FOrgnEntities);
      FP1.X := LBound.X1;
      FP1.Y := LBound.Y1;

      FP2 := Self.GetCurrPoint();
      Self.UpdateTaskEntities();      
    end
    else
      Self.Aborted := True;
  end
  else Self.Aborted := True;
end;

destructor TUdActionPasteClip.Destroy;
var
  I: Integer;
begin
  for I := System.Length(FOrgnEntities) - 1 downto 0 do
    FOrgnEntities[I].Free();
  FOrgnEntities := nil;

  for I := System.Length(FTaskEntities) - 1 downto 0 do
    FTaskEntities[I].Free();
  FTaskEntities := nil;

  inherited;
end;



procedure TUdActionPasteClip.Paint(Sender: TObject; ACanvas: TCanvas);
var
  I: Integer;
begin
  inherited;

  if System.Length(FTaskEntities) > 0 then
  begin
    for I := High(FTaskEntities) downto Low(FTaskEntities) do
      if Assigned(FTaskEntities[I]) and FTaskEntities[I].Visible then
        FTaskEntities[I].Draw(ACanvas);
  end;
end;





function TUdActionPasteClip.UpdateTaskEntities(): Boolean;
var
  I: Integer;
begin
  Result := False;
  if System.Length(FTaskEntities) <= 0 then Exit;

  for I := System.Length(FTaskEntities) - 1 downto 0 do
  begin
    FTaskEntities[I].BeginUpdate();
    try
      FTaskEntities[I].Assign(FOrgnEntities[I]);
      FTaskEntities[I].Move(FP1, FP2);
      FTaskEntities[I].Visible := True;
    finally
      FTaskEntities[I].EndUpdate();
    end;
  end;

  Result := True;
end;

function TUdActionPasteClip.Submit(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if System.Length(FTaskEntities) <= 0 then Exit;

  FP2 := APnt;
  Self.UpdateTaskEntities(); 

  Self.AddEntities(FTaskEntities);
  FTaskEntities := nil;
  
  Result := True;
end;



procedure TUdActionPasteClip.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionPasteClip.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
begin
  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=====>>>

  case AKind of
    mkMouseDown:
      begin
        if AButton = mbLeft then
        begin
          Self.Submit(ACoordPnt);
          Self.Finish();
        end
        else if AButton = mbRight then
        begin
          Self.Finish();
        end;
      end;

    mkMouseMove:
      begin
        FP2 := ACoordPnt;
        Self.UpdateTaskEntities();
      end;

    mkMouseUp:
      begin

      end;
  end;
end;



end.