{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdEntity;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics,
  UdTypes, UdConsts, UdIntfs, UdEvents, UdObject, UdAxes,
  UdColor, UdLineType, UdLineWeight, UdLayer,
  UdDimStyles, UdTextStyles, UdHatchPatterns, UdPointStyle;


const
  STATE_INDEX_FINISHED  = 0;
  STATE_INDEX_SELECTED  = 1;
  STATE_INDEX_HIDDEN    = 2;
  STATE_INDEX_UNDERGRIP = 3;
  STATE_INDEX_CANSEL    = 4;

type
  TUdEntity = class;
  TUdEntityClass  = class of TUdEntity;
  TUdEntityArray  = array of TUdEntity;
  TUdEntityArrays = array of TUdEntityArray;

  TUdEntityEvent  = procedure(Sender: TObject; Entity: TUdEntity) of object;
  TUdEntitiesEvent = procedure(Sender: TObject; Entities: TUdEntityArray) of object;

  TUdEntityAllowEvent  = procedure(Sender: TObject; Entity: TUdEntity; var Allow: Boolean) of object;
  TUdEntitiesAllowEvent = procedure(Sender: TObject; Entities: TUdEntityArray; var Allow: Boolean) of object;

  TUdGetEntityClassEvent  = procedure(Sender: TObject; EntityId: Integer; var EntityClass: TUdEntityClass) of object;


  //-----------------------------------------------------------------------------

  TUdEntity = class(TUdObject, IUdObjectItem)
  protected
    FVer: Integer;
    FKey: string;

    FLayer: TUdLayer;
    FColor: TUdColor;
    FLineType: TUdLineType;
    FLineTypeScale: Float;
    FLineWeight: TUdLineWeight;

    FPenStyle: TPenStyle;
    FUsePenStyle: Boolean;

    FStates: LongWord;
    FVisible: Boolean;

    FBoundsRect: TRect2D;
    FUpdateCounter: Integer;

    FOnRefresh: TUdRefreshEvent;

  protected
    function GetTypeID(): Integer; override;
    procedure SetOwner(const AValue: TUdObject); override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    procedure SetLayer(const AValue: TUdLayer); virtual;
    procedure SetColor(const AValue: TUdColor); virtual;
    procedure SetLineType(const AValue: TUdLineType); virtual;
    procedure SetLineTypeScale(const AValue: Float); virtual;
    procedure SetLineWeight(const AValue: TUdLineWeight); virtual;

    procedure SetPenStyle(const AValue: TPenStyle); virtual;
    procedure SetUsePenStyle(const AValue: Boolean); virtual;

    function GetVisible(): Boolean; virtual;
    procedure SetVisible(const AValue: Boolean); virtual;

    function GetStates(AIndex: Integer): Boolean;
    procedure SetStates(AIndex: Integer; const AValue: Boolean);

    procedure StatesChanged(AIndex: Integer); virtual;
    function GetUpdating(): Boolean;



    //----------------------------------------------

    function ActualColor(): TUdColor;
    function ActualTrueColor(APaintFlag: Cardinal): TColor;

    function ActualLineType(): TUdLineType;
    function ActualLineTypeScale(): Float;

    function ActualLineWeight(): TUdLineWeight;


    //----------------------------------------------

    procedure OnColorChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
    procedure OnColorChanged(Sender: TObject; APropName: string);

    procedure OnLineTypeChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
    procedure OnLineTypeChanged(Sender: TObject; APropName: string);

  protected
    function GetLayout(): TUdObject;
    function GetLayoutBackColor(): TColor;
    function GetLayoutViewBound(): TRect2D;

    function GetPointStyle(): TUdPointStyle;
    function GetDimStyles(): TUdDimStyles;
    function GetTextStyles(): TUdTextStyles;
    function GetHatchPatterns(): TUdHatchPatterns;

    function EnsureAxes(AAxes: TUdAxes): TUdAxes;

    function CanLinetype(): Boolean; virtual;

    function DoUpdate(AAxes: TUdAxes): Boolean; virtual;
    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; virtual;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); overload; override;
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); overload; override;
    
    destructor Destroy(); override;

    function Clone(): TUdEntity; overload;
    function Clone(ADocument: TUdObject; AIsDocRegister: Boolean): TUdEntity; overload;

    function Draw(ACanvas: TCanvas; AAxes: TUdAxes = nil; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
    function Update(AAxes: TUdAxes = nil): Boolean;

    function BeginUpdate(): Integer;
    function EndUpdate(AAxes: TUdAxes = nil): Integer;

    function Refresh(const ARect: TRect): Boolean; overload;
    function Refresh(const ARect: TRect2D; AAxes: TUdAxes = nil): Boolean; overload;
    function Refresh(AAxes: TUdAxes = nil): Boolean; overload;

    function IsLock(): Boolean;
    function IsVisible(): Boolean; virtual;

    function GetGripPoints(): TUdGripPointArray; virtual;
    function GetOSnapPoints(): TUdOSnapPointArray; virtual;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    {operation...}
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; virtual;

    function Pick(APoint: TPoint2D): Boolean; overload; virtual;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; virtual;

    function Move(Dx, Dy: Float): Boolean; overload; dynamic;
    function Move(APnt1, APnt2: TPoint2D): Boolean; overload;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; dynamic;
    function Offset(ADis: Float; ASidePnt: TPoint2D): Boolean; dynamic;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; dynamic;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; dynamic;
    function Extend(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): Boolean; dynamic;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; dynamic;
    function BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray; dynamic;
    function Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray; dynamic;

    function ArrayRect(ARowNum, AColNum: Integer; ARowDis, AColDis: Float; AAngle: Float = 0.0): TUdEntityArray;
    function ArrayPolar(ANum: Integer; AFillAng: Float; ACenter: TPoint2D; ARotateItems: Boolean = True): TUdEntityArray;

    function Intersect(AOther: TUdEntity): TPoint2DArray; virtual;
    function Perpend(APnt: TPoint2D): TPoint2DArray; virtual;


  public
    property Ver       : Integer read FVer;
    property Updating  : Boolean read GetUpdating;
    property BoundsRect: TRect2D read FBoundsRect;
    property Visible   : Boolean read GetVisible   write SetVisible;


    property Finished   : Boolean index STATE_INDEX_FINISHED  read GetStates write SetStates;
    property Selected   : Boolean index STATE_INDEX_SELECTED  read GetStates write SetStates;
    property Hidden     : Boolean index STATE_INDEX_HIDDEN    read GetStates write SetStates;
    property UnderGrip  : Boolean index STATE_INDEX_UNDERGRIP read GetStates write SetStates;
    property CanSelected: Boolean index STATE_INDEX_CANSEL    read GetStates write SetStates;

    property Layout        : TUdObject        read GetLayout;
    property PointStyle    : TUdPointStyle    read GetPointStyle;
    property DimStyles     : TUdDimStyles     read GetDimStyles;
    property TextStyles    : TUdTextStyles    read GetTextStyles;
    property HatchPatterns : TUdHatchPatterns read GetHatchPatterns;

  published
    property Key: string read FKey write FKey;

    property Layer         : TUdLayer       read FLayer           write SetLayer;
    property Color         : TUdColor       read FColor           write SetColor;
    property LineType      : TUdLineType    read FLineType        write SetLineType;
    property LineTypeScale : Float          read FLineTypeScale   write SetLineTypeScale;
    property LineWeight    : TUdLineWeight  read FLineWeight      write SetLineWeight;

    property PenStyle      : TPenStyle read FPenStyle    write SetPenStyle;
    property UsePenStyle   : Boolean   read FUsePenStyle write SetUsePenStyle;

    property OnRefresh     : TUdRefreshEvent read FOnRefresh      write FOnRefresh;

  end;


  function AddEntityArray(var Dest: TUdEntityArray; const Source: TUdEntityArray): Boolean;


implementation


uses
  SysUtils,
  UdDocument, UdLayout, UdEntities, UdMath, UdGeo2D, UdStreams, UdDrawUtil, UdXml;



type
  TFObject = class(TUdObject);
    

function AddEntityArray(var Dest: TUdEntityArray; const Source: TUdEntityArray): Boolean;
var
  I: Integer;
  L1, L2: Integer;
begin
  Result := False;
  if System.Length(Source) = 0 then Exit;

  L1 := System.Length(Dest);
  L2 := System.Length(Source);

  System.SetLength(Dest, L1 + L2);
  for I := L1 to L1 + L2 - 1 do Dest[I] := Source[I - L1];

  Result := True;
end;


//==================================================================================================
{ TUdEntity }

constructor TUdEntity.Create();
begin
  inherited;

{$IFDEF UdEntity_01}FVer := 1;{$ENDIF}
{$IFDEF UdEntity_02}FVer := 2;{$ENDIF}
{$IFDEF UdEntity_03}FVer := 3;{$ENDIF}

  FLayer := nil;

  FColor := TUdColor.Create(); // ADocument, False
  FColor.Owner := Self;

  FLineType := TUdLineType.Create(); //ADocument, False
  FLineType.Owner := Self;

  FLineTypeScale := 1.0;
  FLineWeight := LW_DEFAULT;


  FColor.OnChanged := OnColorChanged;
  FColor.OnChanging := OnColorChanging;

  FLineType.OnChanged := OnLineTypeChanged;
  FLineType.OnChanging := OnLineTypeChanging;

  FPenStyle := psSolid;
  FUsePenStyle := False;


  FStates := Byte(fsFinished) or Byte(fsCanSelected);
  FVisible := True;

  FBoundsRect.X1 := 1.0;
  FBoundsRect.Y1 := 1.0;
  FBoundsRect.X2 := -1.0;
  FBoundsRect.Y2 := -1.0;

  FUpdateCounter := 0;
end;

constructor TUdEntity.Create(ADocument: TUdObject; AIsDocRegister: Boolean = True);
begin
  inherited;

  if Assigned(Self.Document) then
  begin
    FLayer := TUdDocument(Self.Document).ActiveLayer;
    FColor.Assign(TUdDocument(Self.Document).ActiveColor);
    FLineType.Assign(TUdDocument(Self.Document).ActiveLineType);
    FLineTypeScale := TUdDocument(Self.Document).LineTypes.CurrentScale;
    FLineWeight := TUdDocument(Self.Document).ActiveLineWeight;
  end;
end;


destructor TUdEntity.Destroy();
begin
  FLayer := nil;

  if Assigned(FColor) then FColor.Free;
  FColor := nil;

  if Assigned(FLineType) then FLineType.Free;
  FLineType := nil;

  inherited;
end;



//--------------------------------------------------------------

function TUdEntity.GetTypeID: Integer;
begin
  Result := 0;
end;

procedure TUdEntity.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

  FColor.SetDocument(AValue, AIsDocRegister);
  FLineType.SetDocument(AValue, AIsDocRegister);

  Self.Update();
end;



procedure TUdEntity.SetOwner(const AValue: TUdObject);
begin
  inherited;

  if Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdEntity) then
  begin
//    FColor.ByKind    := bkByBlock;
//    FLineType.ByKind := bkByBlock;
//    FLineWeight      := LW_BYBLOCK;

    Self.Update();
  end;
end;



procedure TUdEntity.SetLayer(const AValue: TUdLayer);
begin
  if (FLayer <> AValue) and Self.RaiseBeforeModifyObject('Layer'{, Integer(AValue)}) then
  begin
    FLayer := AValue;

    if Assigned(FLayer) then
    begin
      if FColor.ByKind = bkByLayer then FColor.Assign(FLayer.Color);
      if FLineType.ByKind = bkByLayer then FLineType.Assign(FLayer.LineType);
      FLineWeight := FLayer.LineWeight;
    end;
    
    Self.RaiseAfterModifyObject('Layer');
    Self.Refresh();
  end;
end;

procedure TUdEntity.SetColor(const AValue: TUdColor);
begin
  if Assigned(AValue) and (FColor <> AValue) and Self.RaiseBeforeModifyObject('Color'{, Integer(AValue)}) then
  begin
    FColor.Assign(AValue);
    if (FColor.ByKind = bkByLayer) and Assigned(FLayer) then
      TFObject(FColor).CopyFrom(FLayer.Color);

    Self.RaiseAfterModifyObject('Color');
    Self.Refresh();
  end;
end;

procedure TUdEntity.SetLineType(const AValue: TUdLineType);
begin
  if Assigned(AValue) and (FLineType <> AValue) and Self.RaiseBeforeModifyObject('LineType'{, Integer(AValue)}) then
  begin
    FLineType.Assign(AValue);
    if (FLineType.ByKind = bkByLayer) and Assigned(FLayer) then
      TFObject(FLineType).CopyFrom(FLayer.LineType);    

    Self.Update();
    Self.RaiseAfterModifyObject('LineType');
  end;
end;

procedure TUdEntity.SetLineTypeScale(const AValue: Float);
begin
  if NotEqual(FLineWeight, AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('LineTypeScale') then
  begin
    FLineTypeScale := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('LineTypeScale');
  end;
end;



procedure TUdEntity.SetLineWeight(const AValue: TUdLineWeight);
begin
  if (FLineWeight <> AValue) and Self.RaiseBeforeModifyObject('LineWeight') then
  begin
    FLineWeight := AValue;
    Self.Refresh();
    Self.RaiseAfterModifyObject('LineWeight');
  end;
end;

procedure TUdEntity.SetPenStyle(const AValue: TPenStyle);
begin
  if (FPenStyle <> AValue) and Self.RaiseBeforeModifyObject('PenStyle') then
  begin
    FPenStyle := AValue;
    Self.Refresh();
    Self.RaiseAfterModifyObject('PenStyle');
  end;
end;

procedure TUdEntity.SetUsePenStyle(const AValue: Boolean);
begin
  if (FUsePenStyle <> AValue) and Self.RaiseBeforeModifyObject('UsePenStyle') then
  begin
    FUsePenStyle := AValue;
    Self.Refresh();
    Self.RaiseAfterModifyObject('UsePenStyle');
  end;
end;





//--------------------------------------------------------------------------------------

function _GetOwnerEntity(AEntity: TUdEntity): TUdEntity;
begin
  Result := nil;
  if Assigned(AEntity.Owner) then
  begin
    if AEntity.Owner.InheritsFrom(TUdEntity) then
      Result := TUdEntity(AEntity.Owner)
    else
    if AEntity.Owner.InheritsFrom(TUdEntities) and Assigned(TUdEntities(AEntity.Owner).Owner) and TUdEntities(AEntity.Owner).Owner.InheritsFrom(TUdEntity) then
      Result := TUdEntity( TUdEntities(AEntity.Owner).Owner )
  end;
end;

function TUdEntity.ActualColor(): TUdColor;
var
  LLayer: TUdLayer;
  LOwnerEnt: TUdEntity;
begin
  Result := nil;
  if not Self.Finished then Exit; //====>>>>

  Result := FColor;

  LOwnerEnt := _GetOwnerEntity(Self);

  if FColor.ByKind = bkByLayer then
  begin
    LLayer := FLayer;

    if Assigned(LOwnerEnt) then
      LLayer := LOwnerEnt.Layer;

    if Assigned(LLayer) then
      Result := LLayer.Color;
  end else

  if FColor.ByKind = bkByBlock then
  begin
    if Assigned(LOwnerEnt) then
      Result := LOwnerEnt.ActualColor()
  end;
end;

function TUdEntity.ActualTrueColor(APaintFlag: Cardinal): TColor;
var
  LColor: TUdColor;
  LLayout: TUdObject;
begin
  LColor := Self.ActualColor();

  if Assigned(LColor) then
  begin
    if LColor.ByKind = bkByBlock then
    begin
      LLayout := Self.GetLayout();

      if Assigned(LLayout) then
      begin
        Result := UdDrawUtil.NotColor(TUdLayout(LLayout).BackColor);
        Exit; //======>>>>
      end;
    end;

    Result := LColor.GetValueEx(APaintFlag);
  end
  else begin
    LLayout := Self.GetLayout();

    if Assigned(LLayout) then
      Result := UdDrawUtil.NotColor(TUdLayout(LLayout).BackColor)
    else
      Result := clNone;
  end;
end;


function TUdEntity.ActualLineType(): TUdLineType;
var
  LLayer: TUdLayer;
  LOwnerEnt: TUdEntity;
begin
  Result := FLineType;

  LOwnerEnt := _GetOwnerEntity(Self);

  if FLineType.ByKind = bkByLayer then
  begin
    LLayer := FLayer;

    if Assigned(LOwnerEnt) then
      LLayer := LOwnerEnt.Layer;

    if Assigned(LLayer) then
      Result := LLayer.LineType;
  end else

  if FLineType.ByKind = bkByBlock then
  begin
    if Assigned(LOwnerEnt) then
      Result := LOwnerEnt.ActualLineType();
  end;
end;

function TUdEntity.ActualLineTypeScale(): Float;
begin
  Result := FLineTypeScale;

  if Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdEntity) then
    Result := TUdEntity(Self.Owner).FLineTypeScale;

  if Assigned(Self.Document) then
    Result := Result * TUdDocument(Self.Document).LineTypes.GlobalScale;
end;


function TUdEntity.ActualLineWeight(): TUdLineWeight;
var
  LLayer: TUdLayer;
  LOwnerEnt: TUdEntity;
begin
  Result := FLineWeight;

  LOwnerEnt := _GetOwnerEntity(Self);

  if FLineWeight = LW_BYLAYER then
  begin
    LLayer := FLayer;

    if Assigned(LOwnerEnt) then
      LLayer := LOwnerEnt.Layer;

    if Assigned(LLayer) then
      Result := LLayer.LineWeight;
  end else

  if FLineWeight = LW_BYBLOCK then
  begin
    if Assigned(LOwnerEnt) then
      Result := LOwnerEnt.ActualLineWeight();
  end;
end;




//------------------------------------------------------------------------------------------

procedure TUdEntity.OnColorChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
begin
  AAllow := Self.RaiseBeforeModifyObject('Color');
end;

procedure TUdEntity.OnColorChanged(Sender: TObject; APropName: string);
begin
  Self.Refresh();
  Self.RaiseAfterModifyObject('Color');
end;


procedure TUdEntity.OnLineTypeChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
begin
  AAllow := Self.RaiseBeforeModifyObject('LineType');
end;

procedure TUdEntity.OnLineTypeChanged(Sender: TObject; APropName: string);
begin
  if (Self.ActualLineType() = Sender) and (APropName <> 'Name') and (APropName <> 'Comment') then Self.Update();
  Self.RaiseAfterModifyObject('LineType');
end;





//------------------------------------------------------------------------------------------

procedure TUdEntity.StatesChanged(AIndex: Integer);
begin

end;

function TUdEntity.GetStates(AIndex: Integer): Boolean;
begin
  Result := False;
  case AIndex of
    STATE_INDEX_FINISHED : Result := (FStates and Byte(fsFinished) ) > 0;
    STATE_INDEX_SELECTED : Result := (FStates and Byte(fsSelected) ) > 0;
    STATE_INDEX_HIDDEN   : Result := (FStates and Byte(fsHidden)   ) > 0;
    STATE_INDEX_UNDERGRIP: Result := (FStates and Byte(fsUnderGrip)) > 0;
    STATE_INDEX_CANSEL   : Result := (FStates and Byte(fsCanSelected)) > 0;
  end;
end;

procedure TUdEntity.SetStates(AIndex: Integer; const AValue: Boolean);
begin
  if Self.GetStates(AIndex) <> AValue then
  begin
    case AIndex of
      STATE_INDEX_FINISHED : if AValue then FStates := FStates or Byte(fsFinished)  else  FStates := FStates and not Byte(fsFinished);
      STATE_INDEX_SELECTED : if AValue then FStates := FStates or Byte(fsSelected)  else  FStates := FStates and not Byte(fsSelected);
      STATE_INDEX_HIDDEN   : if AValue then FStates := FStates or Byte(fsHidden)    else  FStates := FStates and not Byte(fsHidden);
      STATE_INDEX_UNDERGRIP: if AValue then FStates := FStates or Byte(fsUnderGrip) else  FStates := FStates and not Byte(fsUnderGrip);
      STATE_INDEX_CANSEL   : if AValue then FStates := FStates or Byte(fsCanSelected) else  FStates := FStates and not Byte(fsCanSelected);
    end;

    Self.StatesChanged(AIndex);

    if AIndex in [0] then Self.Update() else
    if AIndex in [1, 2, 3] then Self.Refresh();
  end;
end;




function TUdEntity.GetVisible(): Boolean;
begin
  Result := FVisible;
end;

procedure TUdEntity.SetVisible(const AValue: Boolean);
begin
  if (FVisible <> AValue) and Self.RaiseBeforeModifyObject('Visible') then
  begin
    FVisible := AValue;
    Self.RaiseAfterModifyObject('Visible');

    Self.Refresh();
  end;
end;


function TUdEntity.GetUpdating(): Boolean;
begin
  Result := FUpdateCounter > 0;
end;



function TUdEntity.BeginUpdate(): Integer;
begin
  Inc(FUpdateCounter);
  Result := FUpdateCounter;
end;

function TUdEntity.EndUpdate(AAxes: TUdAxes = nil): Integer;
begin
  Dec(FUpdateCounter);
  if FUpdateCounter < 0 then FUpdateCounter := 0;
  if FUpdateCounter = 0 then Self.Update(AAxes);
  Result := FUpdateCounter;
end;


//function TUdEntity.BeginUndo(AName: string): Boolean;
//begin
//  Result := False;
//  if Assigned(Self.Document) and Self.FIsDocRegister then
//    Result := TUdDocument(Self.Document).BeginUndo(AName);
//end;
//
//function TUdEntity.EndUndo(): Boolean;
//begin
//  Result := False;
//  if Assigned(Self.Document) and Self.FIsDocRegister then
//    Result := TUdDocument(Self.Document).EndUndo();
//end;


//------------------------------------------------------------------------------------------

function TUdEntity.GetLayout(): TUdObject;
var
  LOwner: TUdObject;
begin
  Result := nil;

  if Assigned(Self.Document) then
    Result := TUdDocument(Self.Document).ActiveLayout;

  if not Assigned(Result) then
  begin
    LOwner := Self.Owner;
    while Assigned(LOwner) do
    begin
      if LOwner.InheritsFrom(TUdLayout) then
      begin
        Result := LOwner;
        Break;
      end;

      LOwner := LOwner.Owner;
    end;
  end;
end;

function TUdEntity.GetLayoutBackColor(): TColor;
var
  LLayout: TUdLayout;
begin
  Result := clBlack;
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then Result := LLayout.BackColor;
end;

function TUdEntity.GetLayoutViewBound(): TRect2D;
var
  LLayout: TUdLayout;
begin
  Result := Rect2D(0, 0, 0, 0);
  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then Result := LLayout.ViewBound;
end;




function TUdEntity.GetPointStyle(): TUdPointStyle;
begin
  Result := nil;
  if Assigned(Self.Document) then
    Result := TUdDocument(Self.Document).PointStyle;
end;

function TUdEntity.GetDimstyles: TUdDimStyles;
begin
  Result := nil;
  if Assigned(Self.Document) then
    Result := TUdDocument(Self.Document).DimStyles;
end;

function TUdEntity.GetTextstyles: TUdTextStyles;
begin
  Result := nil;
  if Assigned(Self.Document) then
    Result := TUdDocument(Self.Document).TextStyles;
end;

function TUdEntity.GetHatchPatterns(): TUdHatchPatterns;
begin
  Result := nil;
  if Assigned(Self.Document) then
    Result := TUdDocument(Self.Document).HatchPatterns;
end;



function TUdEntity.EnsureAxes(AAxes: TUdAxes): TUdAxes;
var
  LOwner: TUdObject;
  LAxesSupport: IUdAxesSupport;
begin
  Result := AAxes;

  if not Assigned(Result) then
  begin
    if Assigned(Self.Document) and Assigned(TUdDocument(Self.Document).ActiveLayout) then
      Result := TUdDocument(Self.Document).ActiveLayout.Axes;
  end;

  if not Assigned(Result) then
  begin
    LOwner := Self.Owner;
    while Assigned(LOwner) do
    begin
      if LOwner.GetInterface(IUdAxesSupport, LAxesSupport) then
      begin
        Result := TUdAxes(LAxesSupport.GetAxes());
        Break;
      end;

      LOwner := LOwner.Owner;
    end;
  end;
end;


function TUdEntity.CanLinetype(): Boolean;
var
  LLineType: TUdLineType;
begin
  Result := False;
  LLineType := Self.ActualLineType();
  if Assigned(LLineType) and Self.Finished and not FUsePenStyle then
    Result := (System.Length(LLineType.Value) > 0);
end;



//------------------------------------------------------------------------------------------

function TUdEntity.Clone(): TUdEntity;
begin
  Result := TUdEntityClass(Self.ClassType).Create(Self.Document, False);
  Result.Assign(Self);
end;

function TUdEntity.Clone(ADocument: TUdObject; AIsDocRegister: Boolean): TUdEntity;
begin
  Result := TUdEntityClass(Self.ClassType).Create(ADocument, AIsDocRegister);
  Result.Assign(Self);
end;


procedure TUdEntity.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdEntity) then Exit;

  if Assigned(Self.Document) and (TUdEntity(AValue).Document = Self.Document) then
    FLayer := TUdEntity(AValue).FLayer;

  FColor.Assign(TUdEntity(AValue).FColor);
  FLineType.Assign(TUdEntity(AValue).FLineType);
  FLineWeight := TUdEntity(AValue).FLineWeight;

  FVisible := TUdEntity(AValue).FVisible;
//  FStates := AValue.FStates;
end;









//------------------------------------------------------------------------------------------


function TUdEntity.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
begin
  Result := False;
end;

function TUdEntity.Draw(ACanvas: TCanvas; AAxes: TUdAxes = nil; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
var
  LAxes: TUdAxes;
begin
  Result := False;

  if not Assigned(ACanvas) then Exit; //=======>>>

  LAxes := Self.EnsureAxes(AAxes);
  if not Assigned(LAxes) then Exit; //=======>>>

  if Self.Hidden and not Self.Selected then Exit; //=====>>>>>  Hide的图形 只有在选中的时候 才完整显示
  if Self.Updating or not IsVisible() then Exit; //=====>>>>>

  if (PRINT_PAINT and AFlag) > 0 then
    if Assigned(FLayer) and not FLayer.Plot then Exit; //=======>>>

  Result := DoDraw(ACanvas, LAxes, AFlag, ALwFactor);
end;



function TUdEntity.DoUpdate(AAxes: TUdAxes): Boolean;
begin
  Result := False;
end;

function TUdEntity.Update(AAxes: TUdAxes = nil): Boolean;
var
  LAxes: TUdAxes;
begin
  Result := False;
  if Self.Updating then Exit; //=====>>>>>

  FBoundsRect := UdGeo2D.Rect2D(0, 0, 0, 0);

  LAxes := Self.EnsureAxes(AAxes);
  if not Assigned(LAxes) then Exit; //=======>>>

  Result := DoUpdate(LAxes);
end;



function TUdEntity.Refresh(const ARect: TRect): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  if (ARect.Left > ARect.Right) or (ARect.Top > ARect.Bottom) then Exit;

  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
  begin
    if not LLayout.Updating then
      LLayout.InvalidateRect(ARect, False);
  end
  else
    if Assigned(FOnRefresh) then FOnRefresh(Self, ARect);

  Result := True;
end;

function TUdEntity.Refresh(const ARect: TRect2D; AAxes: TUdAxes = nil): Boolean;
var
  LRect: TRect;
  LAxes: TUdAxes;
begin
  Result := False;
  LAxes := Self.EnsureAxes(AAxes);

  if Assigned(LAxes) then
  begin
    with LAxes do
    begin
      LRect.Left   := XPixel(ARect.X1);
      LRect.Right  := XPixel(ARect.X2);
      LRect.Top    := YPixel(ARect.Y2);
      LRect.Bottom := YPixel(ARect.Y1);
    end;

    InflateRect(LRect, ANGLE_GRIP_DIS+8, ANGLE_GRIP_DIS+8);
    Result := Self.Refresh(LRect);
  end;
end;

function TUdEntity.Refresh(AAxes: TUdAxes = nil): Boolean;
begin
  Result := Self.Refresh(FBoundsRect, AAxes);
end;




//------------------------------------------------------------------------------------------

function TUdEntity.IsLock(): Boolean;
begin
  Result := False;
  if Assigned(FLayer) then Result := TUdLayer(FLayer).Lock;
end;

function TUdEntity.IsVisible(): Boolean;
begin
  Result := FVisible;
  if Assigned(FLayer) then Result := Result and TUdLayer(FLayer).Visible and not TUdLayer(FLayer).Freeze;
end;



function TUdEntity.GetGripPoints(): TUdGripPointArray;
begin
  Result := nil;
end;


function TUdEntity.GetOSnapPoints(): TUdOSnapPointArray;
begin
  Result := nil;
end;





procedure TUdEntity.SaveToStream(AStream: TStream);
begin
  inherited;

  IntToStream(AStream, FVer);
  StrToStream(AStream, FKey);

  if Assigned(FLayer) then
    StrToStream(AStream, FLayer.Name)
  else
    StrToStream(AStream, '');

  FColor.SaveToStream(AStream);
  FLineType.SaveToStream(AStream);
  FloatToStream(AStream, FLineTypeScale);
  IntToStream(AStream, FLineWeight);

  IntToStream(AStream, Ord(FPenStyle));
  BoolToStream(AStream, FUsePenStyle);

//  DWordToStream(AStream, FStates);
//  BoolToStream(AStream, FVisible);
end;

procedure TUdEntity.LoadFromStream(AStream: TStream);
var
  LVer: Integer;
  LLayerName: string;
begin
  inherited;

  LVer := IntFromStream(AStream);
  if LVer > 0 then ;

  FKey := StrFromStream(AStream);

  LLayerName := StrFromStream(AStream);

  FLayer := nil;
  if (LLayerName <> '') and Assigned(Self.Document) then
    FLayer := TUdDocument(Self.Document).Layers.GetItem(LLayerName);

  FColor.LoadFromStream(AStream);
  FLineType.LoadFromStream(AStream);
  FLineTypeScale := FloatFromStream(AStream);
  FLineWeight := TUdLineWeight(IntFromStream(AStream));

  FPenStyle := TPenStyle(IntFromStream(AStream));
  FUsePenStyle := BoolFromStream(AStream);

//  FStates := DWordFromStream(AStream);
//  FVisible := BoolFromStream(AStream);
end;




procedure TUdEntity.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Ver'] := IntToStr(FVer);
  LXmlNode.Prop['Key'] := FKey;

  if Assigned(FLayer) then
    LXmlNode.Prop['Layer'] := FLayer.Name;


  FColor.SaveToXml(LXmlNode.Add());
  FLineType.SaveToXml(LXmlNode.Add());

  LXmlNode.Prop['LineTypeScale'] := FloatToStr(FLineTypeScale);
  LXmlNode.Prop['LineWeight']    := IntToStr(FLineWeight);

  LXmlNode.Prop['PenStyle']      := IntToStr(Ord(FPenStyle));
  LXmlNode.Prop['UsePenStyle']   := BoolToStr(FUsePenStyle, True);
end;

procedure TUdEntity.LoadFromXml(AXmlNode: TObject);
var
  LVer: Integer;
  LLayerName: string;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);


  LVer := StrToIntDef(LXmlNode.Prop['Ver'], 0);
  if LVer > 0 then ;

  FKey := LXmlNode.Prop['Key'];

  LLayerName := LXmlNode.Prop['Layer'];
  
  FLayer := nil;
  if (LLayerName <> '') and Assigned(Self.Document) then
    FLayer := TUdDocument(Self.Document).Layers.GetItem(LLayerName);

  FColor.LoadFromXml(LXmlNode.FindItem('Color'));
  FLineType.LoadFromXml(LXmlNode.FindItem('LineType'));

  FLineTypeScale := StrToFloatDef(LXmlNode.Prop['LineTypeScale'], 1.0);
  FLineWeight    := StrToIntDef(LXmlNode.Prop['LineWeight'], LW_DEFAULT);

  FPenStyle    := TPenStyle(StrToIntDef(LXmlNode.Prop['PenStyle'], 0));
  FUsePenStyle := StrToBoolDef(LXmlNode.Prop['UsePenStyle'], False);
end;





//------------------------------------------------------------------------------------------

function TUdEntity.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;
end;

function TUdEntity.Pick(APoint: TPoint2D): Boolean;
begin
  Result := False;
end;

function TUdEntity.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := False;
end;

function TUdEntity.Intersect(AOther: TUdEntity): TPoint2DArray; //; Option: TUdExtOption
begin
  Result := nil;
end;

function TUdEntity.Perpend(APnt: TPoint2D): TPoint2DArray;
begin
  Result := nil;
end;

function TUdEntity.Mirror(APnt1, APnt2: TPoint2D): Boolean;
begin
  Result := False;
end;

function TUdEntity.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
end;

function TUdEntity.Move(APnt1, APnt2: TPoint2D): Boolean;
begin
  Self.RaiseBeforeModifyObject('');
  Result := Move((APnt2.X - APnt1.X), (APnt2.Y - APnt1.Y));
  Self.RaiseAfterModifyObject('');
end;

function TUdEntity.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
begin
  Result := False;
end;

function TUdEntity.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
end;

function TUdEntity.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
end;

function TUdEntity.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
begin
  Result := nil;
end;

function TUdEntity.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
begin
  Result := nil;
end;





function TUdEntity.Extend(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): Boolean;
begin
  Result := False;
end;

function TUdEntity.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;
begin
  Result := nil;
end;



function TUdEntity.ArrayRect(ARowNum, AColNum: Integer; ARowDis, AColDis: Float; AAngle: Float = 0.0): TUdEntityArray;
var
  N: Integer;
  I, J: Integer;
  LAngle: Float;
  LOffPnt: TPoint2D;
  LEntity: TUdEntity;
begin
  Result := nil;
  if (ARowNum <= 1) or (AColNum <= 1) then Exit;

  LAngle := FixAngle(AAngle);

  N := 0;
  System.SetLength(Result, ARowNum * AColNum - 1);

  for I := 0 to AColNum - 1 do
  begin
    for J := 0 to ARowNum - 1 do
    begin
      if (I = 0) and (J = 0) then Continue;

      if IsEqual(LAngle, 0.0) or IsEqual(LAngle, 360) then
      begin
        LOffPnt := Point2D(ARowDis * I, AColDis * J);
      end
      else begin
        LOffPnt := UdGeo2D.ShiftPoint(Point2D(0, 0), LAngle, ARowDis * I);
        LOffPnt := UdGeo2D.ShiftPoint(LOffPnt, LAngle + 90, AColDis * J);
      end;

      LEntity := TUdEntityClass(Self.ClassType).Create({Self.Document, False});
      LEntity.Assign(Self);
      LEntity.Move(LOffPnt.X, LOffPnt.Y);

      Result[N] := LEntity;
      Inc(N);
    end;
  end;
end;

function TUdEntity.ArrayPolar(ANum: Integer; AFillAng: Float; ACenter: TPoint2D; ARotateItems: Boolean = True): TUdEntityArray;
var
  I: Integer;
  LPnt, LStPnt: TPoint2D;
  LAng{, LStAng}: Float;
  LFillAng, LDisAng: Float;
  LEntity: TUdEntity;
begin
  Result := nil;
  if (ANum <= 1) then Exit;

  System.SetLength(Result, ANum - 1);

  LFillAng := FixAngle(AFillAng);
  LDisAng  := LFillAng / ANum;

  LStPnt := Center(FBoundsRect);
//  LStAng := UdGeo2D.GetAngle(ACenter, LStPnt);

  for I := 1 to ANum - 1 do
  begin
    LAng := LDisAng * I; //LStAng +

    LEntity := TUdEntityClass(Self.ClassType).Create({Self.Document, False});
    LEntity.Assign(Self);

    if ARotateItems then
      LEntity.Rotate(ACenter, LAng)
    else begin
      LPnt := UdGeo2D.Rotate(ACenter, LAng, LStPnt);
      LEntity.Move(LStPnt, LPnt);
    end;

    Result[I-1] := LEntity;
  end;
end;












end.