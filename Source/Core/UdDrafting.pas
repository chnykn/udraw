{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDrafting;

{$I UdDefs.INC}


interface

uses
  Windows, Classes, Graphics, Types,
  UdConsts, UdTypes, UdGTypes, UdObject, UdEntity;



type
  TUdDrafting = class;

  TUdPrePolarPoint = record
    Point: TPoint2D;
    Angle: Float;
  end;
  PUdPrePolarPoint = ^TUdPrePolarPoint;
  

  //*** TUdSnapGrid ***//
  TUdSnapGrid = class(TUdObject)
  private
    FBase: TPoint2D;
    FCount: TPoint;

    FSnapSpace: TPoint2D;
    FGridSpace: TPoint2D;

    FGridRect: TRect2D;
    FGridPoints: TPoint2DArray;

  protected
    function GetTypeID(): Integer; override;

    procedure SetBase(const AValue: TPoint2D);
    procedure SetCount(const AValue: TPoint);
    procedure SetGridSpace(const AValue: TPoint2D);
    procedure SetSnapSpace(const AValue: TPoint2D);

    function CalcGridPoints: Boolean;
    function Draw(ACanvas: TCanvas): Boolean;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    function CalcPoint(ACurrPnt: PPoint2D): TPoint2D;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Base      : TPoint2D read FBase    write SetBase;
    property Count     : TPoint   read FCount   write SetCount;
    property GridSpace : TPoint2D read FGridSpace write SetGridSpace;
    property SnapSpace : TPoint2D read FSnapSpace write SetSnapSpace;
  end;





  //*** TUdObjectSnap ***//
  TUdObjectSnap = class(TUdObject)
  private
    FColor: TColor;
    FScope: Integer;

    FStoreMode: Cardinal;
    FCurrMode: Cardinal;

    FCurrPoint: TUdOSnapPoint;
    FLastPoint: TUdOSnapPoint;

    FLastTick: DWORD;

    FEndPoint  : Boolean;  //端点
    FMidPoint  : Boolean;  //中点
    FCenter    : Boolean;  //圆心
    FInsertion : Boolean;  //插入点
    FQuadrant  : Boolean;  //象限点
    FNode      : Boolean;  //节点
    FPerpend   : Boolean;  //垂点
    FNearest   : Boolean;  //最近点
    FIntersect : Boolean;  //交点
    FTangent   : Boolean;  //切点


    FCanPerpend: Boolean;
    FPrepPoints: TUdOSnapPointArray;

    FSimpleDraw: Boolean;
    FSimpleSize: Integer;

    FTempEntities: TList;
    //FNearest  : Boolean;

  protected
    function GetTypeID(): Integer; override;

    procedure SetColor(const AValue: TColor);
    procedure SetScope(const AValue: Integer);
    procedure SetOSnap(AIndex: Integer; const AValue: Boolean);

    function SetCurrPoint(ASnapPoint: TUdOSnapPoint): Boolean;

    function Draw(ACanvas: TCanvas): Boolean;

    function FieldToMode(): Cardinal;
    function ModeToField(AMode: Cardinal): Boolean;

    procedure SetCurrMode(const AValue: Cardinal);

    function GetSnapPoint(AEntityList: TList; AEpsilon: Float; APrevPnt, ACurrPnt: PPoint2D; AIsViewPort: Boolean = False): TUdOSnapPoint;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    function CalcPoint(APrevPnt, ACurrPnt: PPoint2D; out AKind: Integer): TPoint2D;

    function AddTempEntity(AEntity: TUdEntity): Boolean;
    function ClearTempEntities(): Boolean;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property EndPoint  : Boolean index OSNP_END read FEndPoint  write SetOSnap; //端点
    property MidPoint  : Boolean index OSNP_MID read FMidPoint  write SetOSnap; //中点
    property Center    : Boolean index OSNP_CEN read FCenter    write SetOSnap; //圆心
    property Insertion : Boolean index OSNP_INS read FInsertion write SetOSnap; //插入点
    property Quadrant  : Boolean index OSNP_QUA read FQuadrant  write SetOSnap; //象限点
    property Node      : Boolean index OSNP_NOD read FNode      write SetOSnap; //节点
    property Perpend   : Boolean index OSNP_PER read FPerpend   write SetOSnap; //垂点
    property Nearest   : Boolean index OSNP_NEA read FNearest   write SetOSnap; //垂点
    property Intersect : Boolean index OSNP_INT read FIntersect write SetOSnap; //交点
    property Tangent   : Boolean index OSNP_TAN read FTangent   write SetOSnap; //切点


    property CurrPoint: TUdOSnapPoint read FCurrPoint;
    property CurrMode: Cardinal read FCurrMode write SetCurrMode;

    property Color: TColor  read FColor write SetColor;
    property Scope: Integer read FScope write SetScope;

    property CanPerpend: Boolean read FCanPerpend write FCanPerpend;

    property SimpleDraw: Boolean read FSimpleDraw write FSimpleDraw;
    property SimpleSize: Integer read FSimpleSize write FSimpleSize;
  end;



  //*** TUdPolarTracking ***//
  TUdPolarTracking = class(TUdObject)
  private
    FIncAngle: Float;

    FTrackLines: TLine2DArray;
    FTrackPoint: TPoint2D;

    FTrackAngle: Float;

  protected
    function FCalcPolarPoint(APolarPnt: TUdPrePolarPoint; ACurrPnt: TPoint2D; AIncAngle,
      ASnapDis: Float; const AViewBound: TPolygon2D; var ARetunPnt: TPoint2D; var AReturnLine: TLine2D): Boolean;
        
    procedure SetTrackLines(ALines: TLine2DArray);
    function Draw(ACanvas: TCanvas): Boolean;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    function CalcPoint(APrevPnt, ACurrPnt: PPoint2D; out AReturn: Boolean): TPoint2D;
        
    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;
    
  published
    property IncAngle: Float read FIncAngle write FIncAngle;
    
  end;





  //*** TUdDrafting ***//
  TUdDrafting = class(TUdObject)
  private
    FSnapGrid: TUdSnapGrid;
    FObjectSnap: TUdObjectSnap;
    FPolarTracking: TUdPolarTracking;

    FPrePolarPointList: TList;

    FSnapOn  : Boolean;
    FGridOn  : Boolean;
    FOrthoOn : Boolean;
    FPolarOn : Boolean;
    FOSnapOn : Boolean;
    FLwtDisp : Boolean;


  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    procedure SetOption(AIndex: Integer; const AValue: Boolean);

    function FieldsToFlag(): Cardinal;
    procedure FlagToFields(const AFlag: Cardinal);

    procedure ClearPrePolarPointList();

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    function Draw(ACanvas: TCanvas; AParam: LongWord = 0): Boolean;

    function Reset(AClearOSnapTempEntities: Boolean = False): Boolean;
    
    function AddOSnapTempEntity(AEntity: TUdEntity): Boolean;
    function ClearOSnapTempEntities(): Boolean;    

    function GetSnapPoint(ACurrPnt: PPoint2D): TPoint2D;
    function GetOSnapPoint(APrevPnt, ACurrPnt: PPoint2D; out AKind: Integer): TPoint2D;
    function GetOrthoPoint(APrevPnt, ACurrPnt: PPoint2D): TPoint2D;
    function GetPolarPoint(APrevPnt, ACurrPnt: PPoint2D; out AReturn: Boolean): TPoint2D;
    
    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property GridOn  : Boolean index 0 read FGridOn  write SetOption;
    property SnapOn  : Boolean index 1 read FSnapOn  write SetOption;
    property OrthoOn : Boolean index 2 read FOrthoOn write SetOption;
    property PolarOn : Boolean index 3 read FPolarOn write SetOption;
    property OSnapOn : Boolean index 4 read FOSnapOn write SetOption;
    property LwtDisp : Boolean index 5 read FLwtDisp write SetOption;

    property SnapGrid: TUdSnapGrid   read FSnapGrid  write FSnapGrid;
    property ObjectSnap: TUdObjectSnap read FObjectSnap write FObjectSnap;
    property PolarTracking: TUdPolarTracking read FPolarTracking write FPolarTracking;

  end;



implementation

uses
  SysUtils,
  UdLayout, UdInsert, UdAxes,
  UdMath, UdGeo2D, UdStreams, UdXml, UdUtils, UdStrConverter, UdDrawUtil, UdBitmap;


type
  TFLayout = class(TUdLayout);
  
const
  VERT_GROSNP_COUNT = 28;
  HORZ_GROSNP_COUNT = 43;

  DEF_OSNAP_SCOPE = 20; //Scope

  OSNAP_TIME_RATE = 90 {ms};
  MAX_OSNAP_COUNT = 16;




//==============================================================================================
{ TUdSnapGrid }

constructor TUdSnapGrid.Create();
begin
  inherited;

  FBase      := Point2D(0, 0);
  FCount.X   := HORZ_GROSNP_COUNT;
  FCount.Y   := VERT_GROSNP_COUNT;
  FSnapSpace := Point2D(10, 10);
  FGridSpace := Point2D(10, 10);
  FGridPoints := nil;
end;

destructor TUdSnapGrid.Destroy;
begin
  FGridPoints := nil;
  inherited;
end;



function TUdSnapGrid.GetTypeID: Integer;
begin
  Result := ID_GRIDSNAP;
end;



procedure TUdSnapGrid.SetBase(const AValue: TPoint2D);
begin
  if NotEqual(AValue, FBase) then
  begin
    FBase := AValue;
    if Assigned(Self.Owner) then CalcGridPoints();
  end;
end;

procedure TUdSnapGrid.SetCount(const AValue: TPoint);
begin
  if (FCount.X <> AValue.X) or (FCount.Y <> AValue.Y)  then
  begin
    FCount := AValue;
    if Assigned(Self.Owner) then CalcGridPoints();
  end;
end;

procedure TUdSnapGrid.SetGridSpace(const AValue: TPoint2D);
begin
  if NotEqual(AValue, FGridSpace) then
  begin
    FGridSpace := AValue;
    if Assigned(Self.Owner) then CalcGridPoints();
  end;
end;

procedure TUdSnapGrid.SetSnapSpace(const AValue: TPoint2D);
begin
  if NotEqual(AValue, FSnapSpace) then
  begin
    FSnapSpace := AValue;
  end;
end;



procedure TUdSnapGrid.CopyFrom(AValue: TUdObject);
begin
  inherited;
  if not AValue.InheritsFrom(TUdSnapGrid) then Exit;

  FBase       := TUdSnapGrid(AValue).FBase      ;
  FCount.X    := TUdSnapGrid(AValue).FCount.X   ;
  FCount.Y    := TUdSnapGrid(AValue).FCount.Y   ;
  FSnapSpace  := TUdSnapGrid(AValue).FSnapSpace ;
  FGridSpace  := TUdSnapGrid(AValue).FGridSpace ;

  Self.CalcGridPoints();
end;




//------------------------------------------------------------------------

function TUdSnapGrid.CalcGridPoints: Boolean;
var
  I, J, N: Integer;
begin
  Result := False;
  if not Assigned(Self.Owner) or not TUdDrafting(Self.Owner).GridOn then Exit;

  System.SetLength(FGridPoints, FCount.X * FCount.Y);

  N := 0;
  for I := 0 to FCount.X - 1 do
  begin
    for J := 1 to FCount.Y do
    begin
      FGridPoints[N].X := FBase.X + FGridSpace.X * I;
      FGridPoints[N].Y := FBase.Y + FGridSpace.Y * J;

      N := N + 1;
    end;
  end;

  FGridRect := UdGeo2D.Rect2D(FBase.X, FBase.Y,
    FBase.X + FCount.X * FGridSpace.X, FBase.Y + FCount.Y * FGridSpace.Y);

  Result := True;
end;



function TUdSnapGrid.Draw(ACanvas: TCanvas): Boolean;
var
  I: Integer;
  X, Y: Integer;
  LColor: TColor;
  LViewRect: TRect2D;
  LLayout: TUdLayout;
begin
  Result := False;
  if not Assigned(Self.Owner) or not TUdDrafting(Self.Owner).GridOn or not Assigned(FGridPoints) then Exit;

  LLayout := nil;
  if Assigned(TUdDrafting(Self.Owner).Owner) then
    LLayout := TUdLayout(TUdDrafting(Self.Owner).Owner);

  if not Assigned(LLayout) then Exit;  //========>>>>>

  LViewRect := LLayout.ViewBound;
  if not UdGeo2D.IsIntersect(FGridRect, LViewRect) then Exit; //========>>>>>

  LColor := clWhite;
  if Assigned(LLayout) then
    LColor := UdDrawUtil.NotColor(LLayout.BackColor);

  for I := High(FGridPoints) downto Low(FGridPoints) do
  begin
    X := LLayout.Axes.XPixel(FGridPoints[I].X);
    Y := LLayout.Axes.YPixel(FGridPoints[I].Y);
    ACanvas.Pixels[X, Y] := LColor;
  end;

  Result := True;
end;




function TUdSnapGrid.CalcPoint(ACurrPnt: PPoint2D): TPoint2D;
begin
  Result.X := Round(ACurrPnt^.X / FSnapSpace.X) * FSnapSpace.X + FBase.X;
  Result.Y := Round(ACurrPnt^.Y / FSnapSpace.Y) * FSnapSpace.Y + FBase.Y;
end;





procedure TUdSnapGrid.SaveToStream(AStream: TStream);
begin
  inherited;

  Point2DToStream(AStream, FBase);
  IntToStream(AStream, FCount.X);
  IntToStream(AStream, FCount.Y);

  Point2DToStream(AStream, FSnapSpace);
  Point2DToStream(AStream, FGridSpace);
end;

procedure TUdSnapGrid.LoadFromStream(AStream: TStream);
begin
  inherited;

  FBase := Point2DFromStream(AStream);
  FCount.X := IntFromStream(AStream);
  FCount.Y := IntFromStream(AStream);

  FSnapSpace := Point2DFromStream(AStream);
  FGridSpace := Point2DFromStream(AStream);

  Self.CalcGridPoints();
end;




procedure TUdSnapGrid.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Base']   := Point2DToStr(FBase);
  LXmlNode.Prop['CountX'] := IntToStr(FCount.X);
  LXmlNode.Prop['CountY'] := IntToStr(FCount.Y);

  LXmlNode.Prop['SnapSpace'] := Point2DToStr(FSnapSpace);
  LXmlNode.Prop['GridSpace'] := Point2DToStr(FGridSpace);
end;

procedure TUdSnapGrid.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FBase      := StrToPoint2D(LXmlNode.Prop['Base']);
  FCount.X   := StrToIntDef(LXmlNode.Prop['CountX'], HORZ_GROSNP_COUNT);
  FCount.Y   := StrToIntDef(LXmlNode.Prop['CountY'], VERT_GROSNP_COUNT);

  FSnapSpace := StrToPoint2D(LXmlNode.Prop['SnapSpace']);
  FGridSpace := StrToPoint2D(LXmlNode.Prop['GridSpace']);

  Self.CalcGridPoints();
end;




//==============================================================================================
{ TUdObjectSnap }

constructor TUdObjectSnap.Create();
begin
  inherited;

  FColor := RGB(255, 197, 127);
  FScope := DEF_OSNAP_SCOPE;

  FCurrMode := 0;
  FStoreMode := 0;

  FLastTick := 0;
  FCurrPoint.Mode := OSNP_NUL;
  FLastPoint.Mode := OSNP_NUL;

  FEndPoint  := True;
  FMidPoint  := True;
  FCenter    := True;
  FQuadrant  := True;
  FIntersect := True;
  FPerpend   := True;

  FNode      := True;
  FTangent   := False;
  FInsertion := False;
  FNearest   := False;

  FCanPerpend := False;
  FTempEntities := TList.Create;
  System.SetLength(FPrepPoints, MAX_OSNAP_COUNT);

  FSimpleDraw := False;
  FSimpleSize := 10;
end;

destructor TUdObjectSnap.Destroy;
begin
  FTempEntities.Free;
  System.SetLength(FPrepPoints, 0);
  inherited;
end;



function TUdObjectSnap.GetTypeID: Integer;
begin
  Result := ID_OBJSNAP;
end;

procedure TUdObjectSnap.SetColor(const AValue: TColor);
begin
  FColor := AValue;
end;


procedure TUdObjectSnap.SetScope(const AValue: Integer);
begin
  if AValue > 5 then FScope := AValue;
end;

procedure TUdObjectSnap.SetOSnap(AIndex: Integer; const AValue: Boolean);
begin
  case AIndex of
    OSNP_END: FEndPoint  := AValue;
    OSNP_MID: FMidPoint  := AValue;
    OSNP_CEN: FCenter    := AValue;
    OSNP_NOD: FNode      := AValue;
    OSNP_QUA: FQuadrant  := AValue;
    OSNP_INT: FIntersect := AValue;
    OSNP_INS: FInsertion := AValue;
    OSNP_PER: FPerpend   := AValue;
    OSNP_TAN: FTangent   := AValue;
    OSNP_NEA : FNearest  := AValue;
  end;
end;


procedure TUdObjectSnap.CopyFrom(AValue: TUdObject);
begin
  inherited;
  if not AValue.InheritsFrom(TUdObjectSnap) then Exit;


  FColor     := TUdObjectSnap(AValue).FColor    ;
  FScope     := TUdObjectSnap(AValue).FScope    ;

  FEndPoint  := TUdObjectSnap(AValue).FEndPoint ;
  FMidPoint  := TUdObjectSnap(AValue).FMidPoint ;
  FCenter    := TUdObjectSnap(AValue).FCenter   ;
  FInsertion := TUdObjectSnap(AValue).FInsertion;
  FQuadrant  := TUdObjectSnap(AValue).FQuadrant ;
  FNode      := TUdObjectSnap(AValue).FNode     ;
  FPerpend   := TUdObjectSnap(AValue).FPerpend  ;
  FNearest   := TUdObjectSnap(AValue).FNearest  ;
  FIntersect := TUdObjectSnap(AValue).FIntersect;
  FTangent   := TUdObjectSnap(AValue).FTangent  ;

  FTempEntities.Clear();
end;


//------------------------------------------------------------------

function TUdObjectSnap.Draw(ACanvas: TCanvas): Boolean;
var
  LPnt: TPoint;
  LLayout: TUdLayout;
begin
  Result := False;

  if FCurrPoint.Mode = OSNP_NUL then Exit;
  if not Assigned(Self.Owner) or not TUdDrafting(Self.Owner).OSnapOn then Exit;


  LLayout := nil;
  if Assigned(TUdDrafting(Self.Owner).Owner) then
    LLayout := TUdLayout(TUdDrafting(Self.Owner).Owner);

  if Assigned(LLayout) then
  begin
    LPnt := LLayout.Axes.PointPixel(FCurrPoint.Point);

    if FSimpleDraw then
    begin
      ACanvas.Pen.Color := FColor;
      ACanvas.Pen.Style := psSolid;
      ACanvas.Pen.Width := 2;
      ACanvas.Pen.Mode  := pmCopy;

      UdDrawUtil.DrawXCross(ACanvas, LPnt.X, LPnt.Y, FSimpleSize);
    end
    else
      UdDrawUtil.DrawOSnap(ACanvas, LPnt.X, LPnt.Y, FCurrPoint.Mode, FColor);

    Result := True;
  end;
end;





//------------------------------------------------------------------

function FGetRect(X, Y, R: Integer): TRect;
begin
  Result.Left   := X - R;
  Result.Right  := X + R;
  Result.Top    := Y - R;
  Result.Bottom := Y + R;
end;

function TUdObjectSnap.SetCurrPoint(ASnapPoint: TUdOSnapPoint): Boolean;

  procedure _AddPrevPloarPoint(const ASnapPoint: TUdOSnapPoint);
  var
    I: Integer;
    LFound: Boolean;
    LPloarPnt: PUdPrePolarPoint;
  begin
    if not TUdDrafting(Self.Owner).FPolarOn then Exit;
    if (ASnapPoint.Mode = OSNP_PER) or
       (ASnapPoint.Mode = OSNP_NEA) or
       (ASnapPoint.Mode = OSNP_TAN) then Exit;

    LFound := False;
    
    for I := 0 to TUdDrafting(Self.Owner).FPrePolarPointList.Count - 1 do
    begin
      LPloarPnt := PUdPrePolarPoint(TUdDrafting(Self.Owner).FPrePolarPointList[I]);
      if IsEqual(LPloarPnt^.Point, ASnapPoint.Point, 1.0E-4) then
      begin
        LFound := True;
        TUdDrafting(Self.Owner).FPrePolarPointList.Delete(I);
        Dispose(LPloarPnt);
        Break;
      end;
    end;

    if not LFound then
    begin
      LPloarPnt := New(PUdPrePolarPoint);
      LPloarPnt^.Point := ASnapPoint.Point;
      LPloarPnt^.Angle := ASnapPoint.Angle;
      TUdDrafting(Self.Owner).FPrePolarPointList.Add(LPloarPnt);
    end;
  end;

var
  LRect: TRect;
  LLayout: TUdLayout;
begin
  Result := False;

  if (FCurrPoint.Mode = ASnapPoint.Mode) and
     IsEqual(FCurrPoint.Point, ASnapPoint.Point) then Exit; //========>>>>

  if not Assigned(Self.Owner) or
     not Assigned(TUdDrafting(Self.Owner).Owner) then Exit;

  LLayout := TUdLayout(TUdDrafting(Self.Owner).Owner);
  if not Assigned(LLayout) then Exit; //========>>>>

  if (FCurrPoint.Mode <> OSNP_NUL) then
  begin
    LRect := FGetRect(LLayout.Axes.XPixel(FCurrPoint.Point.X),
                      LLayout.Axes.YPixel(FCurrPoint.Point.Y),
                      15);
    LLayout.InvalidateRect(LRect, True);
  end;

  FCurrPoint := ASnapPoint;

  if (FCurrPoint.Mode <> OSNP_NUL) then
  begin
    LRect := FGetRect(LLayout.Axes.XPixel(FCurrPoint.Point.X),
                      LLayout.Axes.YPixel(FCurrPoint.Point.Y),
                      15);
    LLayout.InvalidateRect(LRect, True);

    if (FLastPoint.Mode = FCurrPoint.Mode) and IsEqual(FLastPoint.Point, FCurrPoint.Point) then
      if TUdDrafting(Self.Owner).FPolarOn then _AddPrevPloarPoint(FCurrPoint);

    FLastPoint := FCurrPoint;
    TUdDrafting(Self.Owner).FPolarTracking.SetTrackLines(nil);
  end;

  Result := True;
end;


procedure TUdObjectSnap.SetCurrMode(const AValue: Cardinal);
var
  LLayout: TUdLayout;
begin
  if not Assigned(Self.Owner) or
     not Assigned(TUdDrafting(Self.Owner).Owner) then Exit;

  LLayout := TUdLayout(TUdDrafting(Self.Owner).Owner);
  if not Assigned(LLayout) then Exit; //========>>>>

  if AValue > 0 then
  begin
    if not LLayout.IsIdleAction() then
    begin
      FCurrMode := AValue;
      if FStoreMode <= 0 then FStoreMode := FieldToMode();
      Self.ModeToField(FCurrMode);
    end;
  end
  else
  begin
    if FStoreMode > 0 then Self.ModeToField(FStoreMode);
    FStoreMode := 0;
    FCurrMode := 0;
  end;
end;


function TUdObjectSnap.FieldToMode(): Cardinal;
begin
  Result := 0;

  if FEndPoint   then Result := Result or OSNP_END;
  if FMidPoint   then Result := Result or OSNP_MID;
  if FCenter     then Result := Result or OSNP_CEN;
  if FInsertion  then Result := Result or OSNP_INS;
  if FQuadrant   then Result := Result or OSNP_QUA;
  if FNode       then Result := Result or OSNP_NOD;
  if FPerpend    then Result := Result or OSNP_PER;
  if FNearest    then Result := Result or OSNP_NEA;
  if FIntersect  then Result := Result or OSNP_INT;
  if FTangent    then Result := Result or OSNP_TAN;
end;



function TUdObjectSnap.ModeToField(AMode: Cardinal): Boolean;
begin
  Result := True;

  FEndPoint  := (AMode and OSNP_END) > 0;
  FMidPoint  := (AMode and OSNP_MID) > 0;
  FCenter    := (AMode and OSNP_CEN) > 0;
  FInsertion := (AMode and OSNP_INS) > 0;
  FQuadrant  := (AMode and OSNP_QUA) > 0;
  FNode      := (AMode and OSNP_NOD) > 0;
  FPerpend   := (AMode and OSNP_PER) > 0;
  FNearest   := (AMode and OSNP_NEA) > 0;
  FIntersect := (AMode and OSNP_INT) > 0;
  FTangent   := (AMode and OSNP_TAN) > 0;
end;


//------------------------------------------------------------------

function TUdObjectSnap.AddTempEntity(AEntity: TUdEntity): Boolean;
begin
  Result := False;
  if Assigned(AEntity) and (FTempEntities.IndexOf(AEntity) < 0) then
  begin
    FTempEntities.Add(AEntity);
    Result := True;
  end;
end;


function TUdObjectSnap.ClearTempEntities(): Boolean;
begin
  FTempEntities.Clear();
  Result := True;
end;


//------------------------------------------------------------------

function FIsNear(var APnt1, APnt2: TPoint2D; var ADis: Float): Boolean;
begin
  Result := (Abs(APnt1.X - APnt2.X) < ADis) and (Abs(APnt1.Y - APnt2.Y) < ADis);
end;

function TUdObjectSnap.GetSnapPoint(AEntityList: TList; AEpsilon: Float; APrevPnt, ACurrPnt: PPoint2D; AIsViewPort: Boolean = False): TUdOSnapPoint;

var
  LPrepCount: Integer;

  function _AppendSnapPoints(AEntity: TUdEntity; AScope: Float; AFromInsert: Boolean = False): Boolean;
  var
    I: Integer;
    LEntity: TUdEntity;
    LSnapPoint: TUdOSnapPoint;
    LSnapPoints: TUdOSnapPointArray;
  begin
    Result := False;
    if not Assigned(AEntity) or not Assigned(ACurrPnt) then Exit;

    if not AFromInsert and AEntity.InheritsFrom(TUdInsert) and Assigned(TUdInsert(AEntity).Block) then
    begin
      _AppendSnapPoints(AEntity, AScope, True);

      for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      begin
        LEntity := TUdInsert(AEntity).Entities.Items[I];
        if Assigned(LEntity) and IsPntInRect(ACurrPnt^, LEntity.BoundsRect, AScope) then
        begin
          _AppendSnapPoints(LEntity, AScope, True);
          if LPrepCount >= MAX_OSNAP_COUNT then Break;
        end;
      end;
    end
    else begin
      LSnapPoints := AEntity.GetOSnapPoints();

      for I := 0 to System.Length(LSnapPoints) - 1 do
      begin
        LSnapPoint := LSnapPoints[I];

        if (FEndPoint  and (LSnapPoint.Mode  = OSNP_END)) or
           (FMidPoint  and (LSnapPoint.Mode  = OSNP_MID)) or
           (FCenter    and (LSnapPoint.Mode  = OSNP_CEN)) or
           (FNode      and (LSnapPoint.Mode  = OSNP_NOD)) or
           (FQuadrant  and (LSnapPoint.Mode  = OSNP_QUA)) or
           (FIntersect and (LSnapPoint.Mode  = OSNP_INT)) or
           (FInsertion and (LSnapPoint.Mode  = OSNP_INS)) then
        begin
          if FIsNear(LSnapPoint.Point, ACurrPnt^, AScope) then
          begin
            FPrepPoints[LPrepCount] := LSnapPoint;

            LPrepCount := LPrepCount + 1;
            if LPrepCount >= MAX_OSNAP_COUNT then Break;
          end;
        end;
      end; //end for I
    end;

    Result := True;
  end;

  function _AppendPerpendPoints(AEntity: TUdEntity; AScope: Float; AFromInsert: Boolean = False): Boolean;
  var
    I: Integer;
    LEntity: TUdEntity;
    LPoints: TPoint2DArray;
  begin
    Result := False;
    if not Assigned(AEntity) or not Assigned(APrevPnt) then Exit;

    if not AFromInsert and AEntity.InheritsFrom(TUdInsert) and Assigned(TUdInsert(AEntity).Block) then
    begin
      for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      begin
        LEntity := TUdInsert(AEntity).Entities.Items[I];
        if Assigned(LEntity) and IsPntInRect(ACurrPnt^, LEntity.BoundsRect, AScope) then
        begin
          _AppendPerpendPoints(LEntity, AScope, True);
          if LPrepCount >= MAX_OSNAP_COUNT then Break;
        end;
      end;
    end
    else begin
      LPoints := AEntity.Perpend(APrevPnt^);

      for I := 0 to System.Length(LPoints) - 1 do
      begin
        if FIsNear(LPoints[I], ACurrPnt^, AScope) then
        begin
          FPrepPoints[LPrepCount] := MakeOSnapPoint(AEntity, OSNP_PER, LPoints[I], -1);

          LPrepCount := LPrepCount + 1;
          if LPrepCount >= MAX_OSNAP_COUNT then Break;
        end;
      end;
    end;

    Result := True;
  end;

  function _AppendIntersectPoints(AEntity1, AEntity2: TUdEntity; AScope: Float): Boolean;
  var
    I: Integer;
    LPoints: TPoint2DArray;
  begin
    Result := False;
    if not Assigned(AEntity1) or not Assigned(AEntity2) or not Assigned(ACurrPnt) then Exit;

    LPoints := AEntity1.Intersect(AEntity2);

    for I := 0 to System.Length(LPoints) - 1 do
    begin
      if FIsNear(LPoints[I], ACurrPnt^, AScope) then
      begin
        FPrepPoints[LPrepCount] := MakeOSnapPoint(AEntity1, OSNP_INT, LPoints[I], -1);

        LPrepCount := LPrepCount + 1;
        if LPrepCount >= MAX_OSNAP_COUNT then Break;
      end;
    end; {end for I}

    Result := True;
  end;

  function _AppendNearestPoints(AEntity: TUdEntity; AScope: Float; AFromInsert: Boolean = False): Boolean;
  var
    I: Integer;
    LPoint: TPoint2D;
    LEntity: TUdEntity;
  begin
    Result := False;
    if not Assigned(AEntity) or not Assigned(ACurrPnt) then Exit;

    if not AFromInsert and AEntity.InheritsFrom(TUdInsert) and Assigned(TUdInsert(AEntity).Block) then
    begin
      for I := 0 to TUdInsert(AEntity).Entities.Count - 1 do
      begin
        LEntity := TUdInsert(AEntity).Entities.Items[I];
        if Assigned(LEntity) and IsPntInRect(ACurrPnt^, LEntity.BoundsRect, AScope) then
        begin
          _AppendNearestPoints(LEntity, AScope, True);
          if LPrepCount >= MAX_OSNAP_COUNT then Break;
        end;
      end;
    end
    else begin
      if UdUtils.GetEntityClosestPoint(ACurrPnt^, AEntity, LPoint) and FIsNear(LPoint, ACurrPnt^, AScope) then
      begin
        FPrepPoints[LPrepCount] := MakeOSnapPoint(AEntity, OSNP_NEA, LPoint, -1);

        LPrepCount := LPrepCount + 1;
        Result := True;
      end;
    end;
  end;

var
  I, J, L: Integer;
//  LLayout: TUdLayout;
  LDis, LMinDis: Float;
  LEntity, LEntity1: TUdEntity;
  LSnapPoint: TUdOSnapPoint;
begin
  Result := MakeOSnapPoint(nil, OSNP_NUL, Point2D(0, 0), -1);
  if not Assigned(ACurrPnt) {or not Assigned(ALayout)} or not Assigned(AEntityList) then Exit;

  LPrepCount := 0;

  if not AIsViewPort then
    for I := 0 to FTempEntities.Count - 1 do  _AppendSnapPoints(FTempEntities[I], AEpsilon);

  if Assigned(AEntityList) then
    for I := 0 to AEntityList.Count - 1 do
    begin
      LEntity := TUdEntity(AEntityList.Items[I]);
      _AppendSnapPoints(LEntity, AEpsilon);
      if LPrepCount >= MAX_OSNAP_COUNT then Break;
    end;

  if Assigned(APrevPnt) and (LPrepCount < MAX_OSNAP_COUNT) and FCanPerpend and FPerpend then
  begin
    if not AIsViewPort then
      for I := 0 to FTempEntities.Count - 1 do  _AppendPerpendPoints(FTempEntities[I], AEpsilon);

    if Assigned(AEntityList) then
      for I := 0 to AEntityList.Count - 1 do
      begin
        LEntity := TUdEntity(AEntityList.Items[I]);
        _AppendPerpendPoints(LEntity, AEpsilon);
      end; {end for I}
  end;

  if (LPrepCount < MAX_OSNAP_COUNT) and FIntersect then
  begin
    if Assigned(AEntityList) then
    begin
      L := AEntityList.Count;
      for I := 0 to L - 1 do
      begin
        LEntity := TUdEntity(AEntityList.Items[I]);
        if LEntity.InheritsFrom(TUdInsert) and Assigned(TUdInsert(LEntity).Block) then
        begin
          for J := 0 to TUdInsert(LEntity).Entities.Count - 1 do
          begin
            LEntity1 := TUdInsert(LEntity).Entities.Items[J];
            if Assigned(LEntity1) and IsPntInRect(ACurrPnt^, LEntity1.BoundsRect, AEpsilon) then
              AEntityList.Add(LEntity1);
          end;

          AEntityList[I] := nil;
        end;
      end;

      for I := 0 to AEntityList.Count - 2 do
      begin
        LEntity := TUdEntity(AEntityList.Items[I]);

        for J := I + 1 to AEntityList.Count - 1 do
        begin
          LEntity1 := TUdEntity(AEntityList.Items[J]);
          _AppendIntersectPoints(LEntity, LEntity1, AEpsilon);
          if LPrepCount >= MAX_OSNAP_COUNT then Break;
        end; {end for J}
        if LPrepCount >= MAX_OSNAP_COUNT then Break;
      end; {end for I}
    end;
  end;


  if (LPrepCount < MAX_OSNAP_COUNT) and FNearest then
  begin
    if Assigned(AEntityList) then
      for I := 0 to AEntityList.Count - 1 do
      begin
        LEntity := TUdEntity(AEntityList.Items[I]);
        _AppendNearestPoints(LEntity, AEpsilon);
        if LPrepCount >= MAX_OSNAP_COUNT then Break;
      end;
  end;


  if LPrepCount > 0 then
  begin
    LSnapPoint := FPrepPoints[0];
    LMinDis := UdGeo2D.Distance(ACurrPnt^, LSnapPoint.Point);

    for I := 1 to LPrepCount - 1 do
    begin
      LDis := UdGeo2D.Distance(ACurrPnt^, FPrepPoints[I].Point);
      if LDis < LMinDis then
      begin
        LMinDis := LDis;
        LSnapPoint := FPrepPoints[I];
      end;
    end;
  end
  else
    LSnapPoint := MakeOSnapPoint(nil, OSNP_NUL, Point2D(0, 0), -1);

  Result := LSnapPoint;
end;


function TUdObjectSnap.CalcPoint(APrevPnt, ACurrPnt: PPoint2D; out AKind: Integer): TPoint2D;

  function _ToViewPortPoint(ALayout: TUdLayout; ALayoutPnt: TPoint2D): TPoint2D;
  var
    LX, LY: Float;
  begin
    LX := ALayout.Axes.XPixelF(ALayoutPnt.X);
    LY := ALayout.Axes.YPixelF(ALayoutPnt.Y);

    Result.X := ALayout.ViewPort.Axes.XValue(LX);
    Result.Y := ALayout.ViewPort.Axes.YValue(LY);
  end;

  function _ToLayoutPoint(ALayout: TUdLayout; AViewPortPnt: TPoint2D): TPoint2D;
  var
    LX, LY: Float;
  begin
    LX := ALayout.ViewPort.Axes.XPixelF(AViewPortPnt.X);
    LY := ALayout.ViewPort.Axes.YPixelF(AViewPortPnt.Y);

    Result.X := ALayout.Axes.XValue(LX);
    Result.Y := ALayout.Axes.YValue(LY);
  end;

var
  I: Integer;
  LEntity: TUdEntity;
  LEpsilon: Float;
  LLayout: TUdLayout;
  LEntityList: TList;
  LSnapPoint: TUdOSnapPoint;
  LCurrPnt, LPrevPnt : PPoint2D;
begin
  AKind := OSNP_NUL;
  Result := Point2D(0, 0);

  if not Assigned(ACurrPnt) or not Assigned(Self.Owner) then Exit; //==========>>>>>

  LLayout := nil;
  if Assigned(TUdDrafting(Self.Owner).Owner) then
    LLayout := TUdLayout(TUdDrafting(Self.Owner).Owner);
  if not Assigned(LLayout) then Exit; //==========>>>>>

  if (GetTickCount() - FLastTick < OSNAP_TIME_RATE) and (FCurrPoint.Mode <> OSNP_NUL) then
  begin
    AKind := FCurrPoint.Mode;
    Result := FCurrPoint.Point;
    Exit; //==========>>>>>
  end;

  LEpsilon := FScope / LLayout.Axes.XPixelPerValue;

  LEntityList := LLayout.GetPartialEntities(ACurrPnt^, LEpsilon);
  LSnapPoint  := GetSnapPoint(LEntityList, LEpsilon, APrevPnt, ACurrPnt);

  if (LSnapPoint.Mode = OSNP_NUL) and Assigned(LLayout.ViewPort) and
     (not LLayout.ViewPort.Actived) and (LLayout.ViewPort.VisibleList.Count > 0) then
  begin
    LCurrPnt := New(PPoint2D);
    LCurrPnt^ := _ToViewPortPoint(LLayout, ACurrPnt^);

    LPrevPnt := nil;
    if Assigned(APrevPnt) then
    begin
      LPrevPnt := New(PPoint2D);
      LPrevPnt^ := _ToViewPortPoint(LLayout, APrevPnt^);
    end;

    LEpsilon := FScope / LLayout.ViewPort.Axes.XPixelPerValue;

    LEntityList := TList.Create;
    try
      for I := 0 to LLayout.ViewPort.VisibleList.Count - 1 do
      begin
        LEntity := TUdEntity(LLayout.ViewPort.VisibleList[I]);
        if Assigned(LEntity) and UdGeo2D.IsPntInRect(LCurrPnt^, LEntity.BoundsRect, LEpsilon)  then
          LEntityList.Add(LEntity);
      end;
      LSnapPoint := GetSnapPoint(LEntityList, LEpsilon, LPrevPnt, LCurrPnt, True);
      if LSnapPoint.Mode <> OSNP_NUL then
        LSnapPoint.Point := _ToLayoutPoint(LLayout, LSnapPoint.Point);
    finally
      LEntityList.Free;
      Dispose(LCurrPnt);
      if Assigned(LPrevPnt) then Dispose(LPrevPnt);
    end;

  end;

  AKind := LSnapPoint.Mode;
  Result := LSnapPoint.Point;

  FLastTick := GetTickCount();
  Self.SetCurrPoint(LSnapPoint);
end;






procedure TUdObjectSnap.SaveToStream(AStream: TStream);
var
  LMode: Cardinal;
begin
  inherited;
  IntToStream(AStream, FColor);
  if FStoreMode > 0 then LMode := FStoreMode else LMode := FieldToMode();
  CarToStream(AStream, LMode);
end;

procedure TUdObjectSnap.LoadFromStream(AStream: TStream);
var
  LMode: Cardinal;
begin
  inherited;
  FColor := IntFromStream(AStream);
  LMode := CarFromStream(AStream);
  if FStoreMode > 0 then FStoreMode := LMode else ModeToField(LMode);
end;



procedure TUdObjectSnap.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LMode: Cardinal;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Color'] := IntToStr(FColor);

  if FStoreMode > 0 then LMode := FStoreMode else LMode := FieldToMode();
  LXmlNode.Prop['Mode'] := IntToStr(LMode);
end;

procedure TUdObjectSnap.LoadFromXml(AXmlNode: TObject);
var
  LMode: Cardinal;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FColor := StrToIntDef(LXmlNode.Prop['Color'], clYellow);

  LMode  := StrToIntDef(LXmlNode.Prop['Mode'], 0);
  if FStoreMode > 0 then FStoreMode := LMode else ModeToField(LMode);
end;



//==============================================================================================
{ TUdPolarTracking }

constructor TUdPolarTracking.Create();
begin
  inherited;
  FIncAngle := 90;
  FTrackLines := nil;
end;

destructor TUdPolarTracking.Destroy;
begin
  FTrackLines := nil;
  inherited;
end;


procedure TUdPolarTracking.CopyFrom(AValue: TUdObject);
begin
  inherited;
  if not AValue.InheritsFrom(TUdPolarTracking) then Exit;

  FIncAngle := TUdPolarTracking(AValue).FIncAngle;
end;



function TUdPolarTracking.Draw(ACanvas: TCanvas): Boolean;

  function _GetUserDotPen(AColor: TColor): THandle;
  var
    LLogBrush: TLogBrush;
    LStyle: array of integer;
  begin
    SetLength(LStyle, 4);
    LStyle[0] := 0;
    LStyle[1] := 4;
    LStyle[2] := 0;
    LStyle[3] := 4;

    LLogBrush.lbStyle := BS_SOLID;
    LLogBrush.lbColor := AColor;//clWhite;
    LLogBrush.lbHatch := 0;

    Result := ExtCreatePen(PS_GEOMETRIC or PS_USERSTYLE or PS_SOLID or  PS_ENDCAP_SQUARE,//  
      1,
      LLogBrush,
      Length(LStyle),
      LStyle
      );

  end;
  
var
  I: Integer;
  LLayout: TUdLayout;
  LTrackPnt, LPnt: TPoint;
  LPenStyle: TByteDynArray;
  {$IF COMPILERVERSION > 17 }
  LStorePenStyle: TPenStyle;
  {$IFEND}
begin
  Result := False;

  if System.Length(FTrackLines) <= 0 then Exit;
  if not Assigned(Self.Owner) or not TUdDrafting(Self.Owner).FPolarOn then Exit;


  LLayout := nil;
  if Assigned(TUdDrafting(Self.Owner).Owner) then
    LLayout := TUdLayout(TUdDrafting(Self.Owner).Owner);

  if Assigned(LLayout) then
  begin
    LTrackPnt := LLayout.Axes.PointPixel(FTrackPoint);

    if ACanvas.InheritsFrom(TUdCanvas32) then
    begin
      SetLength(LPenStyle, 4);
      LPenStyle[0] := 1;  LPenStyle[1] := 0; LPenStyle[2] := 0; LPenStyle[3] := 0;

      with TUdCanvas32(ACanvas) do
      begin
        Pen.Width := 1;
        Pen.Color := NotColor(LLayout.BackColor);

        {$IF COMPILERVERSION <= 17 }
        UserPenMode := True;
        {$ELSE}
        LStorePenStyle := Pen.Style;
        Pen.Style := psUserStyle;
        {$IFEND}

        UserPenStyle := LPenStyle;
        
        {$IFDEF D2010UP}
        for I := 0 to System.Length(FTrackLines) - 1 do
        begin
          MoveTo(LLayout.Axes.XPixel(FTrackLines[I].P1.X), LLayout.Axes.YPixel(FTrackLines[I].P1.Y));
          LineTo(LLayout.Axes.XPixel(FTrackLines[I].P2.X), LLayout.Axes.YPixel(FTrackLines[I].P2.Y));
        end;
        {$ELSE}
        for I := 0 to System.Length(FTrackLines) - 1 do
        begin
          MoveToEx(LLayout.Axes.XPixel(FTrackLines[I].P1.X), LLayout.Axes.YPixel(FTrackLines[I].P1.Y));
          LineToEx(LLayout.Axes.XPixel(FTrackLines[I].P2.X), LLayout.Axes.YPixel(FTrackLines[I].P2.Y));
        end;
        {$ENDIF}

        {$IF COMPILERVERSION <= 17 }
        UserPenMode := False;
        {$ELSE}
        Pen.Style := LStorePenStyle;
        {$IFEND}            
      end;
      
    end
    else begin
      with ACanvas do
      begin
        Pen.Width := 1;
        Pen.Color := NotColor(LLayout.BackColor);
          
        Pen.Handle := _GetUserDotPen( NotColor(LLayout.BackColor) ); //
        Pen.Mode := pmXor;

        for I := 0 to System.Length(FTrackLines) - 1 do
        begin
          MoveTo(LLayout.Axes.XPixel(FTrackLines[I].P1.X), LLayout.Axes.YPixel(FTrackLines[I].P1.Y));
          LineTo(LLayout.Axes.XPixel(FTrackLines[I].P2.X), LLayout.Axes.YPixel(FTrackLines[I].P2.Y));
        end;
      end;
    end;


    LTrackPnt := LLayout.Axes.PointPixel(FTrackPoint);
    
    with ACanvas do
    begin
      Pen.Width := 1;
      Pen.Color := NotColor(LLayout.BackColor);      
      Pen.Style := psSolid;

      MoveTo(LTrackPnt.X - 3, LTrackPnt.Y - 3);
      LineTo(LTrackPnt.X + 4, LTrackPnt.Y + 4);

      MoveTo(LTrackPnt.X - 3, LTrackPnt.Y + 3);
      LineTo(LTrackPnt.X + 4, LTrackPnt.Y - 4);

      for I := 0 to System.Length(FTrackLines) - 1 do
      begin
        LPnt := LLayout.Axes.PointPixel(FTrackLines[I].P1);
        
        MoveTo(LPnt.X, LPnt.Y - 3);
        LineTo(LPnt.X, LPnt.Y + 4);

        MoveTo(LPnt.X - 3, LPnt.Y);
        LineTo(LPnt.X + 4, LPnt.Y);
      end;           
    end;

    Result := True;
  end;
end;

procedure TUdPolarTracking.SetTrackLines(ALines: TLine2DArray);
var
  I: Integer;
  LRect: TRect;
  LRect2d: TRect2D;
  LLayout: TUdLayout;
begin
  if not Assigned(Self.Owner) or
     not Assigned(TUdDrafting(Self.Owner).Owner) then Exit;

  LLayout := TUdLayout(TUdDrafting(Self.Owner).Owner);
  if not Assigned(LLayout) then Exit; //========>>>>
       
  if System.Length(FTrackLines) > 0 then
  begin
    for I := 0 to Length(FTrackLines) - 1 do
    begin
      LRect2d := Rect2D(FTrackLines[I].P1, FTrackLines[I].P2);
      LRect   := Rect(LLayout.Axes.XPixel(LRect2D.X1), LLayout.Axes.YPixel(LRect2D.Y2),
                      LLayout.Axes.XPixel(LRect2D.X2), LLayout.Axes.YPixel(LRect2D.Y1) );
      InflateRect(LRect, 3, 3);
      LLayout.InvalidateRect(LRect, True);
    end;
  end;

  FTrackLines := ALines;

  if System.Length(FTrackLines) > 0 then
  begin
    for I := 0 to Length(FTrackLines) - 1 do
    begin
      LRect2d := Rect2D(FTrackLines[I].P1, FTrackLines[I].P2);
      LRect   := Rect(LLayout.Axes.XPixel(LRect2D.X1), LLayout.Axes.YPixel(LRect2D.Y2),
                      LLayout.Axes.XPixel(LRect2D.X2), LLayout.Axes.YPixel(LRect2D.Y1) );
      InflateRect(LRect, 3, 3);
      LLayout.InvalidateRect(LRect, True);
    end;
  end;
end;




//----------------------------------------------------------------------------------------------

function _CalcPolarPoint(ABasePnt, ACurrPnt: TPoint2D; ACurrAngle: Float; ASnapDis: Float; const AViewBound: TPolygon2D;
                         var ARetunPnt: TPoint2D; var AReturnLine: TLine2D): Boolean;
var
  LLnK: TLineK;
  LPnt: TPoint2D;
  LPnts: TPoint2DArray;
begin
  Result := False;

  LLnK := LineK(ABasePnt, ACurrAngle);
  LPnt := UdGeo2D.ClosestLinePoint(ACurrPnt, LLnK);

  if IsEqual(UdGeo2D.GetAngle(ABasePnt, LPnt), ACurrAngle, 0.1) and (Distance(LPnt, ACurrPnt) <= ASnapDis) then
  begin
    LPnts := UdGeo2D.Intersection(Ray2D(ABasePnt, ACurrAngle), AViewBound);
    if Length(LPnts) = 1 then
    begin
      ARetunPnt := LPnt;
      AReturnLine := Line2D(ABasePnt, LPnts[0]);
      Result := True;
    end;
  end;
end;

function TUdPolarTracking.FCalcPolarPoint(APolarPnt: TUdPrePolarPoint; ACurrPnt: TPoint2D; AIncAngle, ASnapDis: Float; const AViewBound: TPolygon2D;
                         var ARetunPnt: TPoint2D; var AReturnLine: TLine2D): Boolean;
var
  N: Integer;
  LCurAng: Float;
  LAng1, LAng2: Float;  
begin
  Result := False;


  LCurAng := UdGeo2D.GetAngle(APolarPnt.Point, ACurrPnt);
  if IsEqual(LCurAng, 0.0) then LCurAng := 360.0;

  N := Trunc(LCurAng / AIncAngle);

  LAng1 := AIncAngle * N;
  LAng2 := FixAngle(AIncAngle * (N + 1));

  if FixAngle(LCurAng - LAng1) > FixAngle(LAng2 - LCurAng) then LCurAng := LAng2 else LCurAng := LAng1;
  if IsEqual(LCurAng, 360.0) then LCurAng := 0.0;

  if IsEqual(LCurAng, APolarPnt.Angle) then APolarPnt.Angle := -1;

  
  if (LCurAng >= 0) and NotEqual(LCurAng, FTrackAngle) then
  begin
    Result :=  _CalcPolarPoint(APolarPnt.Point, ACurrPnt, LCurAng, ASnapDis, AViewBound, ARetunPnt, AReturnLine);
    if Result then FTrackAngle := LCurAng;
  end;

  if not Result and (APolarPnt.Angle >= 0) then
  begin
    if NotEqual(APolarPnt.Angle, FTrackAngle) then
    begin
      Result := _CalcPolarPoint(APolarPnt.Point, ACurrPnt, APolarPnt.Angle, ASnapDis, AViewBound, ARetunPnt, AReturnLine);
      if Result then FTrackAngle := LCurAng;
    end;

    if not Result then
    begin
      LCurAng :=  FixAngle(APolarPnt.Angle + 180);
      if NotEqual(LCurAng, FTrackAngle) then
        Result := _CalcPolarPoint(APolarPnt.Point, ACurrPnt, LCurAng, ASnapDis, AViewBound, ARetunPnt, AReturnLine);
      if Result then FTrackAngle := LCurAng;
    end;

    if not Result then
    begin
      LCurAng :=  FixAngle(APolarPnt.Angle + 90);
      if NotEqual(LCurAng, FTrackAngle) then
        Result := _CalcPolarPoint(APolarPnt.Point, ACurrPnt, LCurAng, ASnapDis, AViewBound, ARetunPnt, AReturnLine);
      if Result then FTrackAngle := LCurAng;
    end;
        
    if not Result then
    begin
      LCurAng :=  FixAngle(APolarPnt.Angle - 90);
      if NotEqual(LCurAng, FTrackAngle) then
        Result := _CalcPolarPoint(APolarPnt.Point, ACurrPnt, LCurAng, ASnapDis, AViewBound, ARetunPnt, AReturnLine);
      if Result then FTrackAngle := LCurAng;
    end;
  end;
end;


function TUdPolarTracking.CalcPoint(APrevPnt, ACurrPnt: PPoint2D; out AReturn: Boolean): TPoint2D;
const
  POLAR_SNAP_DIS = 8;
var
  I, L, N: Integer;
  LLayout: TUdLayout;
  LIncAng: Float;
  LSnapDis: Float;
  LInctPnts: TPoint2DArray;
  LViewBound: TPolygon2D;
  LTrackPnt: TPoint2D;
  LTrackLine: TLine2D;
  LTrackLines: TLine2DArray;
  LPolarPnt: TUdPrePolarPoint;
begin
  Result := Point2D(0, 0);
  AReturn := False;
  LTrackLines := nil;
    
  if not Assigned(ACurrPnt) then Exit; //======>>>>>>>

  if not Assigned(Self.Owner) or
     not Assigned(TUdDrafting(Self.Owner).Owner) then Exit;

  LLayout := TUdLayout(TUdDrafting(Self.Owner).Owner);
  if not Assigned(LLayout) then Exit; //========>>>>


  LIncAng := -1;
  L := TUdDrafting(Self.Owner).FPrePolarPointList.Count;
  
  if Assigned(APrevPnt) then
  begin
    LPolarPnt.Point := APrevPnt^;
    LPolarPnt.Angle := TFLayout(LLayout).PrevAngle;
    LIncAng := FIncAngle;
  end
  else begin
    if L > 0 then
    begin
      LIncAng := 90;
      LPolarPnt := PUdPrePolarPoint(TUdDrafting(Self.Owner).FPrePolarPointList[L-1])^;
      L := L - 1;
    end;
  end;

  if LIncAng <= 0 then Exit; //======>>>>
  

  LSnapDis := POLAR_SNAP_DIS * LLayout.Axes.XValuePerPixel;
  LViewBound := Polygon2D(LLayout.ViewBound);


  N := -1;
  FTrackAngle := -1;

  if FCalcPolarPoint(LPolarPnt, ACurrPnt^, LIncAng, LSnapDis, LViewBound, LTrackPnt, LTrackLine) then
  begin
    FTrackPoint := LTrackPnt;

    SetLength(LTrackLines, 1);
    LTrackLines[0] := LTrackLine;
  end
  else begin
    for I := L - 1 downto 0 do
    begin
      LPolarPnt := PUdPrePolarPoint(TUdDrafting(Self.Owner).FPrePolarPointList[I])^;
      if FCalcPolarPoint(LPolarPnt, ACurrPnt^, LIncAng, LSnapDis, LViewBound, LTrackPnt, LTrackLine) then
      begin
        FTrackPoint := LTrackPnt;

        SetLength(LTrackLines, 1);
        LTrackLines[0] := LTrackLine;

        N := I;
        Break;
      end
    end;
  end;

  AReturn := System.Length(LTrackLines) > 0;

  if AReturn then
  begin
    for I := L - 1 downto 0 do
    begin
      if I = N then Continue;
      
      LPolarPnt := PUdPrePolarPoint(TUdDrafting(Self.Owner).FPrePolarPointList[I])^;
      if FCalcPolarPoint(LPolarPnt, FTrackPoint, 90.0, LSnapDis, LViewBound, LTrackPnt, LTrackLine) then
      begin
        LInctPnts := UdGeo2D.Intersection(LTrackLines[0], LTrackLine);
        if Length(LInctPnts) = 1 then FTrackPoint := LInctPnts[0] else FTrackPoint := LTrackPnt;

        SetLength(LTrackLines, 2);
        LTrackLines[1] := LTrackLine;

        Break;
      end
    end;
  end;

  Result := FTrackPoint;
  Self.SetTrackLines(LTrackLines);
end;



procedure TUdPolarTracking.SaveToStream(AStream: TStream);
begin
  inherited;
  FloatToStream(AStream, FIncAngle);
end;

procedure TUdPolarTracking.LoadFromStream(AStream: TStream);
begin
  inherited;
  FIncAngle := FloatFromStream(AStream);
end;

procedure TUdPolarTracking.SaveToXml(AXmlNode: TObject; ANodeName: string);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);
  LXmlNode.Prop['IncAngle'] := FloatToStr(FIncAngle);
end;

procedure TUdPolarTracking.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);
  FIncAngle := StrToFloatDef(LXmlNode.Prop['IncAngle'], 90.0);
end;







//==============================================================================================
{ TUdDrafting }

constructor TUdDrafting.Create();
begin
  inherited;

//  Assert((AOwner <> nil) and AOwner.InheritsFrom(TUdLayout) );

  FSnapOn  := False;
  FGridOn  := False;
  FOrthoOn := False;
  FPolarOn := False;
  FOSnapOn := True;
  FLwtDisp := False;

  FObjectSnap  := TUdObjectSnap.Create();
  FObjectSnap.Owner := Self;

  FSnapGrid := TUdSnapGrid.Create();
  FSnapGrid.Owner := Self;

  FPolarTracking := TUdPolarTracking.Create();
  FPolarTracking.Owner := Self;

  FPrePolarPointList := TList.Create();
end;

destructor TUdDrafting.Destroy;
begin
  FObjectSnap.Free;
  FSnapGrid.Free;
  FPolarTracking.Free;

  ClearPrePolarPointList();
  FPrePolarPointList.Free;
  inherited;
end;


procedure TUdDrafting.ClearPrePolarPointList();
var
  I: Integer;
begin
  for I := FPrePolarPointList.Count - 1 downto 0 do
    Dispose(PUdPrePolarPoint(FPrePolarPointList[I]));
  FPrePolarPointList.Clear();
end;


function TUdDrafting.GetTypeID: Integer;
begin
  Result := ID_DRAFTING;
end;

procedure TUdDrafting.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

  FObjectSnap.SetDocument(Self.Document, Self.IsDocRegister);
  FSnapGrid.SetDocument(Self.Document, Self.IsDocRegister);
  FPolarTracking.SetDocument(Self.Document, Self.IsDocRegister);
end;





procedure TUdDrafting.CopyFrom(AValue: TUdObject);
begin
  inherited;
  if not AValue.InheritsFrom(TUdDrafting) then Exit;

  FSnapOn  := TUdDrafting(AValue).FSnapOn ;
  FGridOn  := TUdDrafting(AValue).FGridOn ;
  FOrthoOn := TUdDrafting(AValue).FOrthoOn;
  FPolarOn := TUdDrafting(AValue).FPolarOn;
  FOSnapOn := TUdDrafting(AValue).FOSnapOn;
  FLwtDisp := TUdDrafting(AValue).FLwtDisp;

  FSnapGrid.Assign(TUdDrafting(AValue).FSnapGrid);
  FObjectSnap.Assign(TUdDrafting(AValue).FObjectSnap);
  FPolarTracking.Assign(TUdDrafting(AValue).FPolarTracking);
end;



procedure TUdDrafting.SetOption(AIndex: Integer; const AValue: Boolean);
var
  LChanged: Boolean;
begin
  LChanged := False;
  case AIndex of
    0: if (FGridOn <> AValue) and Self.RaiseBeforeModifyObject('GridOn') then
      begin
        FGridOn := AValue;
        LChanged := True;
        Self.RaiseAfterModifyObject('GridOn');
      end;
    1: if (FSnapOn <> AValue) and Self.RaiseBeforeModifyObject('SnapOn') then
      begin
        FSnapOn := AValue;
        LChanged := True;
        Self.RaiseAfterModifyObject('SnapOn');
      end;
    2: if (FOrthoOn <> AValue) and Self.RaiseBeforeModifyObject('OrthoOn') then
      begin
        FOrthoOn := AValue;
        LChanged := True;
        Self.RaiseAfterModifyObject('OrthoOn');
      end;
    3: if (FPolarOn <> AValue) and Self.RaiseBeforeModifyObject('PolarOn') then
      begin
        FPolarOn := AValue;
        LChanged := True;
        Self.RaiseAfterModifyObject('PolarOn');
      end;      
    4: if (FOSnapOn <> AValue) and Self.RaiseBeforeModifyObject('OSnapOn') then
      begin
        FOSnapOn := AValue;
        LChanged := True;
        Self.RaiseAfterModifyObject('OSnapOn');
      end;
    5: if (FLwtDisp <> AValue) and Self.RaiseBeforeModifyObject('LwtDisp') then
      begin
        FLwtDisp := AValue;
        LChanged := True;
        Self.RaiseAfterModifyObject('LwtDisp');
      end;
  end;


  if (AIndex = 0) and LChanged and FGridOn then
    FSnapGrid.CalcGridPoints;

  if LChanged then Self.Reset();
end;





function TUdDrafting.GetSnapPoint(ACurrPnt: PPoint2D): TPoint2D;
begin
  Result := UdMath.InvalidPoint();
  if FSnapOn and Assigned(ACurrPnt) then
    Result := FSnapGrid.CalcPoint(ACurrPnt);
end;





function TUdDrafting.GetOSnapPoint(APrevPnt, ACurrPnt: PPoint2D; out AKind: Integer): TPoint2D;
begin
  AKind := OSNP_NUL;
  Result := Point2D(0, 0);

  if Assigned(Self.Owner) and TUdLayout(Self.Owner).Updating then Exit; //======>>>

  if Assigned(ACurrPnt) and (FOSnapOn or (FObjectSnap.FCurrMode > 0)) then
    Result := FObjectSnap.CalcPoint(APrevPnt, ACurrPnt, AKind);
end;

function TUdDrafting.GetOrthoPoint(APrevPnt, ACurrPnt: PPoint2D): TPoint2D;
begin
  if Assigned(APrevPnt) and Assigned(ACurrPnt) then
  begin
    Result := ACurrPnt^;
    if Abs(ACurrPnt^.X - APrevPnt^.X) > Abs(ACurrPnt^.Y - APrevPnt^.Y) then
      Result.Y := APrevPnt^.Y
    else
      Result.X := APrevPnt^.X;
  end
  else
    Result := Point2D(0, 0);
end;

function TUdDrafting.GetPolarPoint(APrevPnt, ACurrPnt: PPoint2D; out AReturn: Boolean): TPoint2D;
begin
  Result := Point2D(0, 0);
  AReturn := False;

  if not Assigned(ACurrPnt) then Exit; //======>>>
  if Assigned(Self.Owner) and TUdLayout(Self.Owner).Updating then Exit; //======>>>

  if (FObjectSnap.FCurrPoint.Mode > 0) or (FObjectSnap.FCurrMode > 0) then Exit;  //======>>>

  if (FPolarOn and not FOrthoOn) then
    Result := FPolarTracking.CalcPoint(APrevPnt, ACurrPnt, AReturn);
end;


function TUdDrafting.Draw(ACanvas: TCanvas; AParam: LongWord = 0): Boolean;
begin
  FSnapGrid.Draw(ACanvas);
  if FOSnapOn or (FObjectSnap.FCurrMode > 0) then FObjectSnap.Draw(ACanvas);
  if FPolarOn then FPolarTracking.Draw(ACanvas);
  
  Result := True;
end;

function TUdDrafting.Reset(AClearOSnapTempEntities: Boolean = False): Boolean;
var
  LSnapPnt: TUdOSnapPoint;
begin
  if AClearOSnapTempEntities then Self.ClearOSnapTempEntities();
  
  LSnapPnt.Mode := OSNP_NUL;
  LSnapPnt.Point := Point2D(0, 0);
  LSnapPnt.Entity := nil;
  FObjectSnap.SetCurrPoint(LSnapPnt);

  Self.ClearPrePolarPointList();
  FPolarTracking.SetTrackLines(nil);
    
  Result := True;
end;

function TUdDrafting.AddOSnapTempEntity(AEntity: TUdEntity): Boolean;
begin
  Result := FObjectSnap.AddTempEntity(AEntity);
end;

function TUdDrafting.ClearOSnapTempEntities(): Boolean;
begin
  Result := FObjectSnap.ClearTempEntities();
end;



function TUdDrafting.FieldsToFlag(): Cardinal;
begin
  Result := 0;
  if FSnapOn  then Result := Result or 1 ;
  if FGridOn  then Result := Result or 2 ;
  if FOrthoOn then Result := Result or 4 ;
  if FPolarOn then Result := Result or 8 ;
  if FOSnapOn then Result := Result or 16 ;
  if FLwtDisp then Result := Result or 32;
end;

procedure TUdDrafting.FlagToFields(const AFlag: Cardinal);
begin
  FSnapOn  := (AFlag and 1 ) > 0;
  FGridOn  := (AFlag and 2 ) > 0;
  FOrthoOn := (AFlag and 4 ) > 0;
  FPolarOn := (AFlag and 8 ) > 0;
  FOSnapOn := (AFlag and 16 ) > 0;
  FLwtDisp := (AFlag and 32) > 0;
end;


procedure TUdDrafting.SaveToStream(AStream: TStream);
var
  LFlag: Cardinal;
begin
  inherited;

  LFlag := Self.FieldsToFlag();

  CarToStream(AStream, LFlag);
  FSnapGrid.SaveToStream(AStream);
  FObjectSnap.SaveToStream(AStream);
  FPolarTracking.SaveToStream(AStream);
end;


procedure TUdDrafting.LoadFromStream(AStream: TStream);
var
  LFlag: Cardinal;
begin
  inherited;

  LFlag := CarFromStream(AStream);
  Self.FlagToFields(LFlag);

  FSnapGrid.LoadFromStream(AStream);
  FObjectSnap.LoadFromStream(AStream);
  FPolarTracking.LoadFromStream(AStream);  
end;




procedure TUdDrafting.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LFlag: Cardinal;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LFlag := Self.FieldsToFlag();
  LXmlNode.Prop['State'] := IntToStr(LFlag);

  FSnapGrid.SaveToXml(LXmlNode.Add());
  FObjectSnap.SaveToXml(LXmlNode.Add());
  FPolarTracking.SaveToXml(LXmlNode.Add());
end;

procedure TUdDrafting.LoadFromXml(AXmlNode: TObject);
var
  LFlag: Cardinal;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LFlag := StrToIntDef(LXmlNode.Prop['State'], 0);
  Self.FlagToFields(LFlag);

  FSnapGrid.LoadFromXml(LXmlNode.FindItem('SnapGrid'));
  FObjectSnap.LoadFromXml(LXmlNode.FindItem('ObjectSnap'));
  FPolarTracking.LoadFromXml(LXmlNode.FindItem('PolarTracking'));
end;





end.