{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdAction;

{$I UdDefs.INC}


interface

uses
  Windows, Classes, Graphics,
  UdTypes, UdEvents, UdObject, UdEntity,
  UdDimStyles, UdTextStyles, UdBlocks;



type
  TUdAction = class;
  TUdActionClass = class of TUdAction;


  //-----------------------------------------------------------------------------

  TUdAction = class(TObject)
  protected
    FDocument: TUdObject;
    FLayout: TUdObject;

    FKind: Integer;
    FVisible: Boolean;

    FStep: Integer;
    FStates: LongWord;

    FAborted: Boolean;
    FClearSelectedWhenStop: Boolean;

    FStoreCurStyle: TUdCursorStyle;

  protected
    function GetKind(): Integer; virtual;
    function GetDefColor: TColor;
    function GetPrevAngle(): Float; virtual;
    function GetCurrPoint(): TPoint2D;
    
    function GetLayout(): TUdObject;

    function GetBlocks(): TUdBlocks;
    function GetDimStyles(): TUdDimStyles;
    function GetTextStyles(): TUdTextStyles;

    procedure SetVisible(const AValue: Boolean); virtual;
    procedure SetPrevPoint(const AValue: TPoint2D);

    function GetStates(AIndex: Integer): Boolean;
    procedure SetStates(AIndex: Integer; const AValue: Boolean);

    function Invalidate(): Boolean;
    function InvalidateRect(ARect: TRect2D; AErase: Boolean = False): Boolean;

    function RealToStr(const AValue: Float): string;
    function AngleToStr(const AValue: Float): string;
    function PointToStr(APnt: TPoint2D): string;
    function StrToAngle(const AValue: string): Float;


    //-------------------------------------------------------------

    function AddEntity(AEntity: TUdEntity): Boolean;
    function AddEntities(AEntities: TUdEntityArray): Boolean;

    function RemoveEntity(AEntity: TUdEntity): Boolean;
    function RemoveEntities(AEntities: TUdEntityArray): Boolean;


    function PickEntity(APoint: TPoint2D; AForce: Boolean = False): TUdEntity; overload;
    function PickEntity(ARect: TRect2D; ACrossingMode: Boolean; AForce: Boolean = False): TUdEntityArray; overload;

    function AddSelectedEntity(AEntity: TUdEntity): Boolean;
    function AddSelectedEntities(AEntities: TUdEntityArray): Boolean;

    function RemoveAllSelected(): Boolean;
    function RemoveSelectedEntity(AEntity: TUdEntity): Boolean;
    function RemoveSelectedEntities(AEntities: TUdEntityArray): Boolean;
    function EraseSelectedEntities(): Boolean;

    function GetSelectedEntities(): TUdEntityArray;
    function GetSelectedEntityList(): TList;

    function PixelPerValue(): Extended;
    function ValuePerPixel(): Extended;

    function ExecCommond(const AValue: string): Boolean;

    function BeginUndo(AName: string): Boolean;
    function EndUndo(): Boolean;

    function PerformUndo(): Boolean;
    function PerformRedo(): Boolean;    

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = '');  virtual;
    destructor Destroy(); override;

    class function CommandName(): string; virtual;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); virtual;

    function Reset(): Boolean; virtual;
    function Finish(): Boolean;

    function Parse(const AValue: string): Boolean; virtual;
    function Prompt(const AValue: string; AKind: TUdPromptKind): Boolean;

    procedure DblClick(Sender: TObject; APoint: TPoint); virtual;
    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); virtual;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); virtual;

    function SetCursorStyle(ACurStyle: TUdCursorStyle): Boolean;
    function CanPopMenu(): Boolean; virtual;


  public
    property Kind: Integer read FKind;
    property Document: TUdObject read FDocument;

    property Step: Integer read FStep write FStep;
    property Visible: Boolean read FVisible write SetVisible;

    property Layout: TUdObject read GetLayout;
    property DefColor: TColor read GetDefColor;
    property PrevAngle: Float read GetPrevAngle;
    property CurrPoint: TPoint2D read GetCurrPoint;

    property Blocks: TUdBlocks read GetBlocks;
    property DimStyles: TUdDimStyles read GetDimStyles;
    property TextStyles: TUdTextStyles read GetTextStyles;

    property CanSnap   : Boolean index 0 read GetStates write SetStates;
    property CanOSnap  : Boolean index 1 read GetStates write SetStates;
    property CanOrtho  : Boolean index 2 read GetStates write SetStates;
    property CanPolar  : Boolean index 3 read GetStates write SetStates;
    property CanPerpend: Boolean index 4 read GetStates write SetStates;
    property MustOSnap : Boolean index 5 read GetStates write SetStates;

    property Aborted: Boolean read FAborted write FAborted;
    property ClearSelectedWhenStop: Boolean read FClearSelectedWhenStop write FClearSelectedWhenStop;
  end;



implementation

uses
  SysUtils, UdDocument, UdLayout, UdDrawUtil;

const
  CAN_SNAP  = 1;
  CAN_OSNAP = 2;
  CAN_ORTHO = 4;
  CAN_POLAR = 8;
  CAN_PERP  = 16;
  MUST_OSNAP = 32;

  
  
//==================================================================================================

{ TUdAction }

class function TUdAction.CommandName: string;
begin
  Result := '';
end;

constructor TUdAction.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  FDocument := ADocument;
  FLayout := ALayout;

  FStep := 0;
  FStates := CAN_SNAP or CAN_POLAR;

  FKind := GetKind();
  FVisible := True;

  FAborted := False;
  FClearSelectedWhenStop := True;
  FStoreCurStyle := csIdle;
end;


destructor TUdAction.Destroy();
begin
  //...
  inherited;
end;



function TUdAction.GetKind: Integer;
begin
  Result := 0;
end;

function TUdAction.GetDefColor(): TColor;
var
  LLayout: TUdLayout;
begin
  Result := clWhite;

  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := UdDrawUtil.NotColor(LLayout.BackColor);
end;


function TUdAction.GetPrevAngle(): Float;
begin
  Result := -1;
end;

function TUdAction.GetLayout: TUdObject;
begin
  Result := FLayout;

  if not Assigned(Result) and Assigned(FDocument) then
    Result := TUdDocument(FDocument).ActiveLayout;
end;

function TUdAction.GetCurrPoint(): TPoint2D;
var
  LLayout: TUdLayout;
begin
  Result.X := 0;
  Result.Y := 0;
  
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then Result := LLayout.CurrPoint;
end;




function TUdAction.GetBlocks(): TUdBlocks;
begin
  Result := nil;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).Blocks;
end;

function TUdAction.GetDimstyles: TUdDimStyles;
begin
  Result := nil;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).DimStyles;
end;

function TUdAction.GetTextstyles: TUdTextStyles;
begin
  Result := nil;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).TextStyles;
end;




//function TUdAction.GetCurrPoint: PPoint2D;
//begin
//  Result := nil;
//end;




function TUdAction.SetCursorStyle(ACurStyle: TUdCursorStyle): Boolean;
var
  LLayout: TUdLayout;
begin
  LLayout := TUdLayout(Self.GetLayout());
  Result := Assigned(LLayout);
  if Result then LLayout.XCursorStyle := ACurStyle;
end;



procedure TUdAction.SetVisible(const AValue: Boolean);
var
  LLayout: TUdLayout;
begin
  if FVisible <> AValue then
  begin
    LLayout := TUdLayout(Self.GetLayout());
    if Assigned(LLayout) then
    begin
      if AValue then
        LLayout.XCursorStyle := FStoreCurStyle
      else
        FStoreCurStyle := LLayout.XCursorStyle;
    end;
    FVisible := AValue;
  end;
end;

procedure TUdAction.SetPrevPoint(const AValue: TPoint2D);
var
  LLayout: TUdLayout;
begin
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then LLayout.SetPrevPoint(AValue);
end;



function TUdAction.GetStates(AIndex: Integer): Boolean;
begin
  Result := False;
  case AIndex of
    0: Result := (FStates and CAN_SNAP ) > 0;
    1: Result := (FStates and CAN_OSNAP) > 0;
    2: Result := (FStates and CAN_ORTHO) > 0;
    3: Result := (FStates and CAN_POLAR) > 0;
    4: Result := (FStates and CAN_PERP ) > 0;
    5: Result := (FStates and MUST_OSNAP) > 0;
  end;
end;


procedure TUdAction.SetStates(AIndex: Integer; const AValue: Boolean);
begin
  if Self.GetStates(AIndex) <> AValue then
  begin
    case AIndex of
      0: if AValue then FStates := (FStates or CAN_SNAP )  else FStates := (FStates and not CAN_SNAP );
      1: if AValue then FStates := (FStates or CAN_OSNAP)  else FStates := (FStates and not CAN_OSNAP);
      2: if AValue then FStates := (FStates or CAN_ORTHO)  else FStates := (FStates and not CAN_ORTHO);
      3: if AValue then FStates := (FStates or CAN_POLAR)  else FStates := (FStates and not CAN_POLAR);
      4: if AValue then FStates := (FStates or CAN_PERP )  else FStates := (FStates and not CAN_PERP );
      5: if AValue then FStates := (FStates or MUST_OSNAP) else FStates := (FStates and not MUST_OSNAP );
    end;

    if (AIndex = 3) and Assigned(FDocument) then
    begin
      if Assigned(TUdDocument(FDocument).ActiveLayout) then
      begin
        TUdDocument(FDocument).ActiveLayout.DeletePrevPoint();
        TUdDocument(FDocument).ActiveLayout.Drafting.Reset();
      end;
    end;
  end;
end;



function TUdAction.Reset(): Boolean;
begin
  FStep := 0;
  Result := False;
end;

function TUdAction.Finish: Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  if not FVisible then Exit;

  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.ActionRemoveLast();
end;

function TUdAction.Invalidate(): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  if not FVisible then Exit;

  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.Invalidate();
end;

function TUdAction.InvalidateRect(ARect: TRect2D; AErase: Boolean = False): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  if not FVisible then Exit;

  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.InvalidateRect(ARect, AErase);
end;




function TUdAction.RealToStr(const AValue: Float): string;
begin
  if Assigned(FDocument) then
    Result :=  TUdDocument(FDocument).Units.RealToStr(AValue)
  else
    Result :=  FloatToStrF(AValue, ffFixed, 36, 3);
end;

function TUdAction.AngleToStr(const AValue: Float): string;
begin
  if Assigned(FDocument) then
    Result :=  TUdDocument(FDocument).Units.AngToStr(AValue)
  else
    Result :=  FloatToStrF(AValue, ffFixed, 36, 3);
end;

function TUdAction.PointToStr(APnt: TPoint2D): string;
begin
  if Assigned(FDocument) then
  begin
    with TUdDocument(FDocument).Units do
      Result :=  '(' + RealToStr(APnt.X) + ', ' + RealToStr(APnt.Y) + ')';
  end
  else
    Result :=  '(' + FloatToStrF(APnt.X, ffFixed, 36, 3) + ', ' +
                     FloatToStrF(APnt.Y, ffFixed, 36, 3) + ')';
end;


function TUdAction.StrToAngle(const AValue: string): Float;
var
  LOK: Boolean;
begin
  if Assigned(FDocument) then
    LOK := TUdDocument(FDocument).Units.StrToAng(AValue, Result)
  else
    LOK := TryStrToFloat(AValue, Result);

  if not LOK then Result := -1;
end;





function TUdAction.AddEntity(AEntity: TUdEntity): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.AddEntity(AEntity);
end;

function TUdAction.AddEntities(AEntities: TUdEntityArray): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.AddEntities(AEntities);
end;

function TUdAction.RemoveEntity(AEntity: TUdEntity): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.RemoveEntity(AEntity);
end;

function TUdAction.RemoveEntities(AEntities: TUdEntityArray): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.RemoveEntities(AEntities);
end;




function TUdAction.PickEntity(APoint: TPoint2D; AForce: Boolean = False): TUdEntity;
var
  LLayout: TUdLayout;
begin
  Result := nil;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.PickEntity(APoint, AForce);
end;

function TUdAction.PickEntity(ARect: TRect2D; ACrossingMode: Boolean; AForce: Boolean = False): TUdEntityArray;
var
  LLayout: TUdLayout;
begin
  Result := nil;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.PickEntity(ARect, ACrossingMode, AForce);
end;

function TUdAction.AddSelectedEntity(AEntity: TUdEntity): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.AddSelectedEntity(AEntity{, ARaiseEvent});
end;

function TUdAction.AddSelectedEntities(AEntities: TUdEntityArray): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.AddSelectedEntities(AEntities{, ARaiseEvent});
end;

function TUdAction.RemoveAllSelected(): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.RemoveAllSelected({ARaiseEvent});
end;

function TUdAction.RemoveSelectedEntity(AEntity: TUdEntity): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.RemoveSelectedEntity(AEntity{, ARaiseEvent});
end;

function TUdAction.RemoveSelectedEntities(AEntities: TUdEntityArray): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.RemoveSelectedEntities(AEntities{, ARaiseEvent});
end;

function TUdAction.EraseSelectedEntities(): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.EraseSelectedEntities();
end;

function TUdAction.GetSelectedEntities(): TUdEntityArray;
var
  I: Integer;
  LLayout: TUdLayout;
begin
  Result := nil;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
  begin
    System.SetLength(Result, LLayout.Selection.Count);
    for I := 0 to LLayout.Selection.Count - 1 do
      Result[I] := LLayout.Selection.Items[I];
  end;
end;

function TUdAction.GetSelectedEntityList(): TList;
var
  LLayout: TUdLayout;
begin
  Result := nil;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.Selection.List;
end;


function TUdAction.Parse(const AValue: string): Boolean;
begin
  Result := False;
end;

function TUdAction.Prompt(const AValue: string; AKind: TUdPromptKind): Boolean;
begin
  Result := False;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).Prompt(AValue, AKind);
end;



function TUdAction.PixelPerValue(): Extended;
var
  LLayout: TUdLayout;
begin
  Result := 1.0;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.Axes.XPixelPerValue;
end;

function TUdAction.ValuePerPixel(): Extended;
var
  LLayout: TUdLayout;
begin
  Result := 1.0;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    Result := LLayout.Axes.XValuePerPixel;
end;


function TUdAction.ExecCommond(const AValue: string): Boolean;
begin
  Result := False;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).ExecCommond(AValue);
end;

function TUdAction.BeginUndo(AName: string): Boolean;
begin
  Result := False;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).BeginUndo(AName);
end;

function TUdAction.EndUndo(): Boolean;
begin
  Result := False;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).EndUndo();
end;

function TUdAction.PerformUndo(): Boolean;
begin
  Result := False;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).PerformUndo();
end;

function TUdAction.PerformRedo(): Boolean;
begin
  Result := False;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).PerformRedo();
end;
    


procedure TUdAction.Paint(Sender: TObject; ACanvas: TCanvas);
begin

end;


procedure TUdAction.DblClick(Sender: TObject; APoint: TPoint);
begin

end;

procedure TUdAction.KeyEvent(Sender: TObject; AKind: TUdKeyKind;
  AShift: TUdShiftState; AKey: Word);
begin
 //...
end;

procedure TUdAction.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                               ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin

end;


function TUdAction.CanPopMenu(): Boolean;
begin
  Result := True;
end;


end.