{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdViewPort;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics,
  UdConsts, UdTypes, UdGTypes, UdObject,
  UdAxes, UdAction, UdEntity, UdRect, UdEntities;

type

  //*** TUdViewPort ***//
  TUdViewPort = class(TUdObject)
  private
    FAxes: TUdAxes;

    FCenter: TPoint2D;
    FWidth, FHeight: Float;
    FBoundsShape: TUdRect;

    FActived: Boolean;
    FVisible: Boolean;
    FUpdating: Boolean;
    FVisibleList: TList;

    FViewBound: TRect2D;

    FOnAxesChanged: TNotifyEvent;
    FOnAxesChanging: TNotifyEvent;
    FOnBoundsChanged: TNotifyEvent;

  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function GetEntities: TUdEntities;
    function GetVisibleList: TList;

    function GetInited(): Boolean;
    function GetOwnerAxes(): TUdAxes;

    procedure FSetBoundsRect(const AValue: TRect2D);

    function GetBoundsRect(): TRect2D;
    procedure SetBoundsRect(const AValue: TRect2D);

    function GetBounds: string;
    procedure SetBounds(const AValue: string);


    function GetCenter_(AIndex: Integer): Float;
    procedure SetCenter_(AIndex: Integer; const AValue: Float);

    procedure SetCenter(const AValue: TPoint2D);
    procedure SetHeight(const AValue: Float);
    procedure SetWidth(const AValue: Float);

    procedure SetActived(const AValue: Boolean);
    procedure SetVisible(const AValue: Boolean);

    procedure OnAxesChanged_(Sender: TObject);
    procedure OnAxesChanging_(Sender: TObject);
    procedure OnBoundsShapeChanged(Sender: TObject; APropName: string);


    function UpdateViewBound(): Boolean;
    function UpdateBoundsShape(): Boolean;
    function UpdateAxes(ALogicBounds: PRect2D = nil): Boolean; overload;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure InitSize(ACenter: TPoint2D; AWidth, AHeight: Float);

    function UpdateAxes(): Boolean; overload;
    function UpdateAxes(ALogicBounds: TRect2D): Boolean; overload;

    function UpdateVisibleList(): Boolean;

    function Paint(ACanvas: TCanvas; AFlag: Cardinal; ALwFactor: Float; ACliped: Boolean): Boolean;
    function Invalidate(): Boolean;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Axes: TUdAxes read FAxes;
    property BoundsShape: TUdRect read FBoundsShape;
    property Entities: TUdEntities read GetEntities;// write FEntities;

    property Inited: Boolean read GetInited;
    property Updating: Boolean read FUpdating;

    property VisibleList: TList read GetVisibleList;

    property Center  : TPoint2D read FCenter     write SetCenter;
    property BoundsRect: TRect2D  read GetBoundsRect write SetBoundsRect;
    
    property ViewBound: TRect2D read FViewBound;

    property Actived: Boolean read FActived write SetActived;
    property Visible: Boolean read FVisible write SetVisible;

  published
    property CenterX: Float index 0 read GetCenter_  write SetCenter_;
    property CenterY: Float index 1 read GetCenter_  write SetCenter_;

    property Width : Float    read FWidth    write SetWidth;
    property Height: Float    read FHeight   write SetHeight;

    property Bounds: string  read GetBounds write SetBounds;

    property OnAxesChanged: TNotifyEvent read FOnAxesChanged write FOnAxesChanged;
    property OnAxesChanging: TNotifyEvent read FOnAxesChanging write FOnAxesChanging;
    property OnBoundsChanged: TNotifyEvent read FOnBoundsChanged write FOnBoundsChanged;
  end;


implementation

uses
  SysUtils,
  UdDocument, UdLayout, UdMath, UdGeo2D, UdStreams, UdStrConverter, UdXml;

type
  TFUdAxes = class(TUdAxes);
  TFUdLayout = class(TUdLayout);



//==================================================================================================
{ TUdViewPort }

constructor TUdViewPort.Create();
begin
  inherited;

  FBoundsShape := TUdRect.Create(); // Self.Document, False
  FBoundsShape.Owner := Self;
  FBoundsShape.Color.TrueColor := clBlack;
  FBoundsShape.UsePenStyle := True;
  FBoundsShape.PenStyle := psSolid;
  FBoundsShape.PenWidth := 1;
  FBoundsShape.SimpleGrip := True;
  FBoundsShape.OnChanged := OnBoundsShapeChanged;

  FCenter := Point2D(0.0, 0.0);
  FWidth  := 0.0;
  FHeight := 0.0;


  FAxes := TUdAxes.Create();   // Self.Document, False
  FAxes.Owner := Self;
  TFUdAxes(FAxes)._OnAxesChanging := OnAxesChanging_;
  TFUdAxes(FAxes)._OnAxesChanged  := OnAxesChanged_;

  FActived := False;
  FVisible := True;

  FUpdating := False;

  FViewBound := Rect2D(0,0, 0,0);
  FVisibleList := TList.Create();
end;

destructor TUdViewPort.Destroy;
begin
  if Assigned(FAxes) then FAxes.Free;
  FAxes := nil;

  if Assigned(FVisibleList) then FVisibleList.Free;
  FVisibleList := nil;

  if Assigned(FBoundsShape) then FBoundsShape.Free;
  FBoundsShape := nil;

  inherited;
end;



function TUdViewPort.GetEntities: TUdEntities;
begin
  Result := nil;
//  if Assigned(Self.Owner) and Assigned(Self.Owner.Document) then
  if Assigned(Self.Document) and Assigned(TUdDocument(Self.Document).ModelSpace) then
    Result := TUdDocument(Self.Document).ModelSpace.Entities;
end;


//-------------------------------------------------------------------------------------

function TUdViewPort.GetTypeID: Integer;
begin
  Result := UdConsts.ID_VIEWPORT;
end;


procedure TUdViewPort.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;
  FBoundsShape.SetDocument(Self.Document, False);
  FAxes.SetDocument(Self.Document, False);
end;




function TUdViewPort.GetInited(): Boolean;
begin
  Result := //Assigned(FEntities) and
            (NotEqual(FWidth, 0.0) or NotEqual(FHeight, 0.0)) ;
end;

function TUdViewPort.GetOwnerAxes(): TUdAxes;
begin
  Result := nil;
  if Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdLayout) then
    Result := TFUdLayout(Self.Owner)._Axes;
end;



function TUdViewPort.GetVisibleList: TList;
begin
  Result := FVisibleList;
end;



function TUdViewPort.UpdateBoundsShape(): Boolean;
begin
  FBoundsShape.BeginUpdate();
  try
    FBoundsShape.Center := FCenter;
    FBoundsShape.Width  := FWidth;
    FBoundsShape.Height := FHeight;
  finally
    Result := FBoundsShape.EndUpdate() <= 0;
  end;
end;



procedure TUdViewPort.InitSize(ACenter: TPoint2D; AWidth, AHeight: Float);
begin
  FCenter := ACenter;
  FWidth  := AWidth;
  FHeight := AHeight;
  Self.UpdateBoundsShape();
end;

procedure TUdViewPort.CopyFrom(AValue: TUdObject);
begin
  inherited;
  if not AValue.InheritsFrom(TUdViewPort) then Exit;

  FAxes.Assign(TUdViewPort(AValue).FAxes);

  FCenter := TUdViewPort(AValue).FCenter;
  FWidth  := TUdViewPort(AValue).FWidth;
  FHeight := TUdViewPort(AValue).FHeight;

  FVisible   := TUdViewPort(AValue).FVisible;
  FViewBound := TUdViewPort(AValue).FViewBound;
  FBoundsShape.Assign( TUdViewPort(AValue).FBoundsShape );

  Self.UpdateVisibleList();
end;


//-------------------------------------------------------------------------------------

procedure TUdViewPort.SetCenter(const AValue: TPoint2D);
begin
  if NotEqual(FCenter, AValue) and Self.RaiseBeforeModifyObject('Center') then
  begin
    FCenter := AValue;
    Self.UpdateBoundsShape();

    Self.RaiseAfterModifyObject('Center');
  end;
end;



function TUdViewPort.GetCenter_(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FCenter.X;
    1: Result := FCenter.Y;
  end;
end;

procedure TUdViewPort.SetCenter_(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FCenter;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  Self.SetCenter(LPnt);
end;

procedure TUdViewPort.SetHeight(const AValue: Float);
begin
  if NotEqual(FHeight, AValue) and Self.RaiseBeforeModifyObject('Height') then
  begin
    FHeight := AValue;
    Self.UpdateBoundsShape();

    Self.RaiseAfterModifyObject('Height');
  end;
end;

procedure TUdViewPort.SetWidth(const AValue: Float);
begin
  if NotEqual(FWidth, AValue) and Self.RaiseBeforeModifyObject('Width') then
  begin
    FWidth := AValue;
    Self.UpdateBoundsShape();

    Self.RaiseAfterModifyObject('Width');
  end;
end;




procedure TUdViewPort.FSetBoundsRect(const AValue: TRect2D);
begin
  FCenter := Centroid(AValue);
  FWidth  := Abs(AValue.X2 - AValue.X1);
  FHeight := Abs(AValue.Y2 - AValue.Y1);
  Self.UpdateBoundsShape();
end;

function TUdViewPort.GetBoundsRect: TRect2D;
begin
  Result := Rect2D(FCenter.X - FWidth/2, FCenter.Y - FHeight/2, FCenter.X + FWidth/2, FCenter.Y + FHeight/2);
end;

procedure TUdViewPort.SetBoundsRect(const AValue: TRect2D);
begin
  if Self.RaiseBeforeModifyObject('Bounds') then
  begin
    FSetBoundsRect(AValue);
    Self.RaiseAfterModifyObject('Bounds');
  end;
end;


function TUdViewPort.GetBounds: string;
var
  LRect: TRect2D;
begin
  LRect := GetBoundsRect();
  Result := Point2DToStr(LRect.P1) + ';' + Point2DToStr(LRect.P2);
end;

procedure TUdViewPort.SetBounds(const AValue: string);
var
  N: Integer;
  LRect: TRect2D;
begin
  N := Pos(';', AValue);
  if N > 0 then
  begin
    LRect.P1 := StrToPoint2D(Copy(AValue, 1, N - 1));
    LRect.P2 := StrToPoint2D(Copy(AValue, N + 1, Length(AValue)));
    Self.FSetBoundsRect(LRect);
  end;
end;



procedure TUdViewPort.SetActived(const AValue: Boolean);
begin
  if FActived <> AValue then
  begin
    FActived := AValue;
    if FActived then FBoundsShape.PenWidth := 3 else FBoundsShape.PenWidth := 1;
  end;
end;

procedure TUdViewPort.SetVisible(const AValue: Boolean);
begin
  if FVisible <> AValue then
  begin
    FVisible := AValue;
    FBoundsShape.Visible := FVisible;

    if FVisible then UpdateVisibleList() else FVisibleList.Clear();
    Self.Invalidate();
  end;
end;




//-------------------------------------------------------------------------------------

procedure TUdViewPort.OnAxesChanging_(Sender: TObject);
begin
  if Assigned(FOnAxesChanging) then FOnAxesChanging(Sender);
end;

procedure TUdViewPort.OnAxesChanged_(Sender: TObject);
begin
  if Assigned(FOnAxesChanged) then FOnAxesChanged(Sender);
end;


procedure TUdViewPort.OnBoundsShapeChanged(Sender: TObject; APropName: string);
begin
  if APropName = '' then
  begin
    if Self.RaiseBeforeModifyObject('Bounds') then
    begin
      FCenter := FBoundsShape.Center;
      FWidth  := FBoundsShape.Width;
      FHeight := FBoundsShape.Height;
      if Assigned(FOnBoundsChanged) then FOnBoundsChanged(Self);

      Self.RaiseAfterModifyObject('Bounds');
    end;
  end;
end;



//-------------------------------------------------------------------------------------


function TUdViewPort.UpdateViewBound(): Boolean;
var
  LOwnerAxes: TUdAxes;
  LX1, LX2, LY1, LY2: Float;
begin
  Result := False;

  LOwnerAxes := Self.GetOwnerAxes();
  if not Assigned(LOwnerAxes) then Exit; //=======>>>>>>>

  LX1 := LOwnerAxes.XPixelF(FCenter.X - FWidth/2 );
  LX2 := LOwnerAxes.XPixelF(FCenter.X + FWidth/2 );
  LY1 := LOwnerAxes.YPixelF(FCenter.Y - FHeight/2);
  LY2 := LOwnerAxes.YPixelF(FCenter.Y + FHeight/2);

  FViewBound.X1 := FAxes.XValue(LX1);
  FViewBound.X2 := FAxes.XValue(LX2);
  FViewBound.Y1 := FAxes.YValue(LY1);
  FViewBound.Y2 := FAxes.YValue(LY2);

  Result := True;
end;
  
function TUdViewPort.UpdateAxes(ALogicBounds: PRect2D = nil): Boolean;
var
  LPan: TPoint2D;
  LPnt: TPoint2D;
  LSize: TPoint2D;
  LAxesScale: PFloat;
  LOwnerAxes: TUdAxes;
begin
  Result := False;

  LOwnerAxes := Self.GetOwnerAxes();
  if not Assigned(LOwnerAxes) then Exit;

  LPnt := Point2D(FCenter.X - FWidth / 2, FCenter.Y + FHeight / 2);
  LPan := Point2D(LOwnerAxes.XPixelF(LPnt.X), -LOwnerAxes.YPixelF(LPnt.Y));

  LSize.X := LOwnerAxes.XPixelPerValue * FWidth;
  LSize.Y := LOwnerAxes.YPixelPerValue * FHeight;

  if (LSize.X <= 0) or (LSize.Y <= 0) then Exit; //=======>>>>>>

  {
  if IsEqual(LPan.X, FAxes.XPan) and IsEqual(LPan.Y, FAxes.YPan) and
     IsEqual(LSize.X, FAxes.XSize) and IsEqual(LSize.Y, FAxes.YSize) then Exit; //======>>>>>>
  }

  if Assigned(ALogicBounds) then
  begin
  //FAxes.ZoomScale(100);
    LAxesScale  := @(FAxes.Scale);
    LAxesScale^ := 100;
    Result := FAxes.CalcAxis(LSize.X, LSize.Y, ALogicBounds^, @(LPan.X), @(LPan.Y));
  end
  else
    Result := FAxes.CalcAxis(LSize.X, LSize.Y, @(LPan.X), @(LPan.Y));

  if Result then Self.UpdateViewBound();
end;

function TUdViewPort.UpdateAxes(): Boolean;
begin
  Result := Self.UpdateAxes(nil);
end;

function TUdViewPort.UpdateAxes(ALogicBounds: TRect2D): Boolean;
begin
  Result := Self.UpdateAxes(@ALogicBounds);
end;


function TUdViewPort.UpdateVisibleList(): Boolean;
var
  I: Integer;
  LEntity: TUdEntity;
  LEntities: TUdEntities;
begin
  Result := False;
  if not FVisible then Exit;

  LEntities := Self.GetEntities();
  if not Assigned(LEntities) then Exit;

  FUpdating := True;
  try
    FVisibleList.Clear();

    for I := 0 to LEntities.Count - 1 do
    begin
      LEntity := LEntities.Items[I];
      if not Assigned(LEntity) or not LEntity.IsVisible() then Continue;

      if UdGeo2D.IsIntersect(LEntity.BoundsRect, FViewBound) then
        FVisibleList.Add(LEntity)
    end;

  finally
    FUpdating := False;
  end;

  Result := True;
end;



//-------------------------------------------------------------------------------------

function TUdViewPort.Paint(ACanvas: TCanvas; AFlag: Cardinal; ALwFactor: Float; ACliped: Boolean): Boolean;
var
  I: Integer;
  LRgn: HRGN;
  LEntity: TUdEntity;
  LSelectedList: TList;
  LOwnerAxes: TUdAxes;
  LX1, LY1, LX2, LY2: Integer;
begin
  Result := False;
  if not FVisible or not Assigned(ACanvas) then Exit; //========>>>>>>>

  LOwnerAxes := Self.GetOwnerAxes();
  if not Assigned(LOwnerAxes) then Exit; //========>>>>>>>
    
  LRgn := 0;

  if not ACliped then
  begin
    LRgn := CreateRectRgn(0, 0, 10000, 10000);
    GetClipRgn(ACanvas.Handle, LRgn);
  end;

  try
    if not ACliped and Assigned(LOwnerAxes) then
    begin
      LX1 := LOwnerAxes.XPixel(FCenter.X - FWidth/2);
      LX2 := LOwnerAxes.XPixel(FCenter.X + FWidth/2);
      LY1 := LOwnerAxes.YPixel(FCenter.Y + FHeight/2);
      LY2 := LOwnerAxes.YPixel(FCenter.Y - FHeight/2);

      IntersectClipRect(ACanvas.Handle, LX1, LY1, LX2, LY2);
    end;

    for I := 0 to FVisibleList.Count - 1 do
    begin
      LEntity := FVisibleList[I];
      if Assigned(LEntity) and not LEntity.Selected then
        LEntity.Draw(ACanvas, FAxes, AFlag, ALwFactor);
    end;

    if FActived and Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdLayout) then
    begin
      LSelectedList := TUdLayout(Self.Owner).SelectedList;

      for I := 0 to LSelectedList.Count - 1 do
      begin
        LEntity := TUdEntity(LSelectedList[I]);
        if Assigned(LEntity) then LEntity.Draw(ACanvas, FAxes, AFlag, ALwFactor);
      end;

      //TUdLayout(Self.Owner).Selection.DrawGrips(ACanvas);
    end;

  finally
    if not ACliped then
    begin
      SelectClipRgn(ACanvas.Handle, LRgn);
      DeleteObject(LRgn);
    end;
  end;

  Result := True;
end;


function TUdViewPort.Invalidate(): Boolean;
begin
  Result := False;
  if Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdLayout) then
    Result := TUdLayout(Self.Owner).Invalidate();
end;



//-------------------------------------------------------------------------------------

procedure TUdViewPort.SaveToStream(AStream: TStream);
begin
  inherited;

  FAxes.SaveToStream(AStream);

  Point2DToStream(AStream, FCenter);
  FloatToStream(AStream, FWidth );
  FloatToStream(AStream, FHeight);

  BoolToStream(AStream, FVisible);
end;

procedure TUdViewPort.LoadFromStream(AStream: TStream);
begin
  inherited;

  FAxes.LoadFromStream(AStream);

  FCenter := Point2DFromStream(AStream);
  FWidth  := FloatFromStream(AStream);
  FHeight := FloatFromStream(AStream);

  FVisible := BoolFromStream(AStream);

  Self.UpdateBoundsShape();
  Self.UpdateViewBound();
end;




procedure TUdViewPort.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FAxes.SaveToXml(LXmlNode.Add());

  LXmlNode.Prop['Center']  := Point2DToStr(FCenter);
  LXmlNode.Prop['Width']   := FloatToStr(FWidth);
  LXmlNode.Prop['Height']  := FloatToStr(FHeight);

  LXmlNode.Prop['Visible'] := BoolToStr(FVisible, True);
end;

procedure TUdViewPort.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FAxes.LoadFromXml(LXmlNode.FindItem('Axes'));

  FCenter := StrToPoint2D(LXmlNode.Prop['Center']);
  FWidth  := StrToFloatDef(LXmlNode.Prop['Width'], 0);
  FHeight := StrToFloatDef(LXmlNode.Prop['Height'], 0);

  FVisible := StrToBoolDef(LXmlNode.Prop['Visible'], True);

  Self.UpdateBoundsShape();
  Self.UpdateViewBound();
end;



end.