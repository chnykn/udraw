{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPolyline;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics, Types,
  UdConsts, UdTypes, UdGTypes, UdColor,
  UdIntfs, UdObject, UdEntity, UdFigure, UdAxes;

type

  TUdSplineFlag = (sfStandard, sfCtrlPnts, sfFitting, sfQuadratic, sfCubic);

  //-----------------------------------------------------
  TUdPolyline = class(TUdFigure, IUdExplode)
  private
    FClosed  : Boolean;
    FSplineFlag: TUdSplineFlag;

    FKnots: TFloatArray;
    FVertexes: TVertexes2D;
    FWidths  : TPoint2DArray;

    FSamplePolygons: TPoint2DArrays;

    FVertexIndex: Integer;


  protected
    function GetTypeID(): Integer; override;

    function GetXData: TSegarc2DArray;
    procedure SetXData(const AValue: TSegarc2DArray);

    procedure SetClosed(const AValue: Boolean);
    procedure SetSplineFlag(const AValue: TUdSplineFlag);

    procedure SetKnots(const AValue: TFloatArray);
    procedure SetVertexes(const AValue: TVertexes2D);

    function GetVertex(AIndex: Integer): TVertex2D;
    procedure SetVertex(AIndex: Integer; const AValue: TVertex2D);

    procedure SetWidths(const AValue: TPoint2DArray);


    //-------------------------------------------------

    function GetVertexCount: Integer;

    function GetVertexIndex: Integer;
    procedure SetVertexIndex(const AValue: Integer);

    function GetVertexValue(AIndex: Integer): Float;
    procedure SetVertexValue(AIndex: Integer; const AValue: Float);

    function GetVertexBulge: Float;
    procedure SetVertexBulge(const AValue: Float);

    function GetVertexWidth(AIndex: Integer): Float;
    procedure SetVertexWidth(AIndex: Integer; const AValue: Float);

    function GetWidth(): Float;
    procedure SetWidth(const AValue: Float);

    function GetGloablWidth(): string;
    procedure SetGloablWidth(const AValue: string);


    function GetArea(): Float;
    function GetLength(): Float;


    //-------------------------------------------------

    function CanFilled(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    procedure CheckClosed(Apply: Boolean);

    function FDrawPolyline(ACanvas: TCanvas; AColor: TColor; AAxes: TUdAxes): Boolean;
    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetGripPoints(): TUdGripPointArray; override;
    function GetOSnapPoints(): TUdOSnapPointArray; override;

    function HasWidths(): Boolean;
    function HasBulges(): Boolean;

    function AddVertex(AVex: TVertex2D): Boolean; overload;
    function AddVertex(AVex: TVertex2D; AWid: Single): Boolean; overload;
    function AddVertex(AVex: TVertex2D; AWid1, AWid2: Single): Boolean; overload;

    function SetPoints(APnts: TPoint2DArray): Boolean;


    { operation... }
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;

    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;

    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Offset(ADis: Float; ASidePnt: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;
    function Extend(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): Boolean; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;
    function BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray; override;
    function Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray; override;
    function Explode(): TUdObjectArray;

    function Intersect(AOther: TUdEntity): TPoint2DArray; override;
    function Perpend(APnt: TPoint2D): TPoint2DArray; override;

    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Knots: TFloatArray read FKnots write SetKnots;
    property Vertexes: TVertexes2D  read FVertexes write SetVertexes;
    property Vertex[AIndex: Integer]: TVertex2D  read GetVertex write SetVertex;

    property Widths : TPoint2DArray read FWidths   write SetWidths;
    property Width  : Float        read GetWidth   write SetWidth;

    property XData: TSegarc2DArray    read GetXData  write SetXData;

  published
    property VertexCount : Integer read GetVertexCount;
    property VertexIndex : Integer read GetVertexIndex write SetVertexIndex;
    property VertexX     : Float index 0 read GetVertexValue write SetVertexValue;
    property VertexY     : Float index 1 read GetVertexValue write SetVertexValue;
    property VertexBulge : Float read   GetVertexBulge       write SetVertexBulge;
    property StartWidth  : Float index 0 read GetVertexWidth write SetVertexWidth;
    property EndWidth    : Float index 1 read GetVertexWidth write SetVertexWidth;
    property GloablWidth : string        read GetGloablWidth write SetGloablWidth;

    property Filled;
    property Closed    : Boolean       read FClosed write SetClosed;
    property SplineFlag: TUdSplineFlag read FSplineFlag write SetSplineFlag;

    property Length: Float read GetLength;
    property Area  : Float read GetArea ;
  end;


function VertexesToPoints(AVertexes: TVertexes2D): TPoint2DArray;


implementation


uses
  SysUtils, Variants,
  UdMath, UdGeo2D, UdBSpline2D, UdUtils, UdStrConverter,
  UdColls, UdStreams, UdXml, UdDrawUtil, UdHatchBitmaps,
  UdLine, UdArc, UdEllipse {$IFNDEF D2010}, UdCanvas{$ENDIF};


//==================================================================================================

function VertexesToPoints(AVertexes: TVertexes2D): TPoint2DArray;
var
  I: Integer;
begin
  System.SetLength(Result, System.Length(AVertexes));
  for I := 0 to System.Length(AVertexes) - 1 do Result[I] := AVertexes[I].Point;
end;

function VertexesCopyFromPoints(var AVertexes: TVertexes2D; APnts: TPoint2DArray): Boolean;
var
  I: Integer;
begin
  Result := False;
  if System.Length(AVertexes) <> System.Length(APnts) then Exit;

  for I := 0 to System.Length(AVertexes) - 1 do
    AVertexes[I].Point := APnts[I];

  Result := True;
end;




//==================================================================================================
{ TUdPolyline }

constructor TUdPolyline.Create();
begin
  inherited;

  FClosed := False;
  FSplineFlag := sfStandard;

  FKnots    := nil;
  FVertexes := nil;

  FWidths   := nil;
  FSamplePolygons := nil;

  FVertexIndex := 0;
end;

destructor TUdPolyline.Destroy;
begin
  FKnots    := nil;
  FVertexes := nil;
  FWidths   := nil;
  FSamplePolygons := nil;

  inherited;
end;



function TUdPolyline.GetTypeID: Integer;
begin
  Result := ID_POLYLINE;
end;




//-----------------------------------------------------------------------------------------

procedure TUdPolyline.CopyFrom(AValue: TUdObject);
var
  I: Integer;
begin
  inherited;

  if not AValue.InheritsFrom(TUdPolyline) then Exit; //========>>>

  FClosed     := TUdPolyline(AValue).FClosed;
  FSplineFlag := TUdPolyline(AValue).FSplineFlag;


  System.SetLength(FKnots, System.Length(TUdPolyline(AValue).FKnots));
  for I := 0 to System.Length(TUdPolyline(AValue).FKnots) - 1 do
    FKnots[I] := TUdPolyline(AValue).FKnots[I];

  System.SetLength(FVertexes, System.Length(TUdPolyline(AValue).FVertexes));
  for I := 0 to System.Length(TUdPolyline(AValue).FVertexes) - 1 do
    FVertexes[I] := TUdPolyline(AValue).FVertexes[I];

  System.SetLength(FWidths, System.Length(TUdPolyline(AValue).FWidths));
  for I := 0 to System.Length(TUdPolyline(AValue).FWidths) - 1 do
    FWidths[I] := TUdPolyline(AValue).FWidths[I];

  Self.Update();
end;


procedure TUdPolyline.CheckClosed(Apply: Boolean);
var
  L: Integer;
begin
  L := System.Length(FVertexes);
  if L <= 0 then Exit; //===>>>>

  if Apply then
  begin
    if FClosed then
    begin
      if NotEqual(FVertexes[0].Point, FVertexes[L-1].Point) then
      begin
        System.SetLength(FVertexes, L+1);
        FVertexes[L].Point := FVertexes[0].Point;
        FVertexes[L].Bulge := 0.0;

        System.SetLength(FWidths, L+1);
        FWidths[L].X := 0;
        FWidths[L].Y := 0;

        Self.Update();
      end;
    end
    else begin
      if IsEqual(FVertexes[0].Point, FVertexes[L-1].Point) then
      begin
        System.SetLength(FVertexes, L-1);
        System.SetLength(FWidths, L-1);

        Self.Update();
      end;
    end;
  end
  else begin
    FClosed := False;
    if L > 1 then
      FClosed := IsEqual(FVertexes[0].Point, FVertexes[L-1].Point);
  end;
end;



//-----------------------------------------------------------------------------------------

procedure TUdPolyline.SetClosed(const AValue: Boolean);
begin
  if (FClosed <> AValue) and Self.RaiseBeforeModifyObject('Closed') then
  begin
    FClosed := AValue;
    Self.CheckClosed(True);
    Self.RaiseAfterModifyObject('Closed');
  end;
end;

procedure TUdPolyline.SetSplineFlag(const AValue: TUdSplineFlag);
begin
  if (FSplineFlag <> AValue) and Self.RaiseBeforeModifyObject('SplineFlag') then
  begin
    FSplineFlag := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('SplineFlag');
  end;
end;



function TUdPolyline.GetVertex(AIndex: Integer): TVertex2D;
begin
  Result.Bulge := 0.0;
  Result.Point := Point2D(0, 0);

  if (AIndex < 0) or (AIndex >= System.Length(FVertexes)) then Exit;

  Result := FVertexes[AIndex];
end;


procedure TUdPolyline.SetVertex(AIndex: Integer; const AValue: TVertex2D);
begin
  if (AIndex < 0) or (AIndex >= System.Length(FVertexes)) then Exit;

  if Self.RaiseBeforeModifyObject('SplineFlag'{, Variants.VarArrayOf([AIndex, Integer(@AValue)])}) then
  begin
    FVertexes[AIndex] := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Vertex');
  end;
end;



procedure TUdPolyline.SetKnots(const AValue: TFloatArray);
var
  I: Integer;
begin
  if Self.RaiseBeforeModifyObject('Knots') then
  begin
    System.SetLength(FKnots, System.Length(AValue));
    for I := 0 to System.Length(AValue) - 1 do FKnots[I]:= AValue[I];

    if FSplineFlag in [sfQuadratic, sfCubic] then Self.Update();
    Self.RaiseAfterModifyObject('Knots');
  end;
end;

procedure TUdPolyline.SetVertexes(const AValue: TVertexes2D);
var
  I, L: Integer;
begin
  if Self.RaiseBeforeModifyObject('Vertexes') then
  begin
    System.SetLength(FVertexes, System.Length(AValue));
    for I := 0 to System.Length(AValue) - 1 do FVertexes[I]:= AValue[I];

    if System.Length(FWidths) <> System.Length(FVertexes) then
    begin
      if System.Length(FWidths) > System.Length(FVertexes) then
      begin
        System.SetLength(FWidths, System.Length(FVertexes));
      end
      else begin
        L := System.Length(FWidths);
        System.SetLength(FWidths, System.Length(FVertexes));
        for I := L to System.Length(FVertexes) - 1 do
        begin
          FWidths[I].X := 0;
          FWidths[I].Y := 0;
        end;
      end;
    end;

    CheckClosed(False);

    if (System.Length(FVertexes) <= 0) or (FVertexIndex >= System.Length(FVertexes)) then FVertexIndex := 0;

    Self.Update();
    Self.RaiseAfterModifyObject('Vertexes');
  end;
end;



function TUdPolyline.SetPoints(APnts: TPoint2DArray): Boolean;
var
  I: Integer;
  LVertexes: TVertexes2D;
begin
  System.SetLength(LVertexes, System.Length(APnts));
  for I := 0 to System.Length(APnts) - 1 do
  begin
    LVertexes[I].Point := Point2D(APnts[I].X, APnts[I].Y);
    LVertexes[I].Bulge := 0.0;
  end;

  Self.SetVertexes(LVertexes);
  Result := True;
end;


procedure TUdPolyline.SetWidths(const AValue: TPoint2DArray);
var
  I: Integer;
begin
  if System.Length(AValue) <> System.Length(FVertexes) then Exit;//=====>>>>

  if Self.RaiseBeforeModifyObject('Widths') then
  begin
    System.SetLength(FWidths, System.Length(AValue));
    for I := 0 to System.Length(AValue) - 1 do
    begin
      if (AValue[I].X < 0.0) then FWidths[I].X := 0.0 else FWidths[I].X := AValue[I].X;
      if (AValue[I].Y < 0.0) then FWidths[I].Y := 0.0 else FWidths[I].Y := AValue[I].Y;
    end;

    Self.Update();
    Self.RaiseAfterModifyObject('Widths');
  end;
end;




//-----------------------------------------------------------------------------------------

function TUdPolyline.AddVertex(AVex: TVertex2D): Boolean;
begin
  Result := Self.AddVertex(AVex, 0.0, 0.0);
end;

function TUdPolyline.AddVertex(AVex: TVertex2D; AWid: Single): Boolean;
begin
  Result := Self.AddVertex(AVex, AWid, AWid);
end;

function TUdPolyline.AddVertex(AVex: TVertex2D; AWid1, AWid2: Single): Boolean;
var
  L: Integer;
begin
  Result := False;
  L := System.Length(FVertexes);

  if (L > 0) and
     IsEqual(FVertexes[L-1].Point, AVex.Point) and
     IsEqual(FVertexes[L-1].Bulge, AVex.Bulge) then Exit; //=====>>>>

  if Self.RaiseBeforeModifyObject('AddVertex'{, Variants.VarArrayOf([Integer(@AVex), AWid1, AWid2])}) then
  begin
    System.SetLength(FVertexes, L + 1);
    FVertexes[L] := AVex;

    if (AWid1 < 0) then AWid1 := 0.0;
    if (AWid2 < 0) then AWid2 := 0.0;

    System.SetLength(FWidths, L + 1);
    FWidths[L].X := AWid1;
    FWidths[L].Y := AWid2;

    CheckClosed(False);
    Result := Self.Update();
    Self.RaiseAfterModifyObject('AddVertex');
  end;
end;





function TUdPolyline.GetXData: TSegarc2DArray;
begin
  Result := Segarc2DArray(FVertexes);
end;

procedure TUdPolyline.SetXData(const AValue: TSegarc2DArray);
begin
  SetVertexes(Vertexes2D(AValue));
end;




function TUdPolyline.HasWidths(): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (System.Length(FWidths) >= System.Length(FVertexes)) and (FSplineFlag in [sfStandard, sfCtrlPnts]) then
  begin
    for I := 0 to System.Length(FWidths) - 1 do
    begin
      if (FWidths[I].X > 0.0) or (FWidths[I].Y > 0.0) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

function TUdPolyline.HasBulges: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to System.Length(FVertexes) - 1 do
  begin
    if NotEqual(FVertexes[I].Bulge, 0.0) then
    begin
      Result := True;
      Break;
    end;
  end;
end;


//-----------------------------------------------------------------------------------------



function TUdPolyline.GetVertexCount: Integer;
begin
  Result := System.Length(FVertexes);
end;


function TUdPolyline.GetVertexIndex: Integer;
begin
  Result := FVertexIndex;
end;

procedure TUdPolyline.SetVertexIndex(const AValue: Integer);
begin
  if (AValue >= 0) and ((System.Length(FVertexes) <= 0) or (AValue < System.Length(FVertexes))) then
    FVertexIndex := AValue
  else
    raise Exception.Create('VertexIndex must in [0-' + IntToStr(System.Length(FVertexes)) + ']');
end;



function TUdPolyline.GetVertexValue(AIndex: Integer): Float;
begin
  Result := 0;
  if (System.Length(FVertexes) > 0) and (FVertexIndex >= 0) and (FVertexIndex < System.Length(FVertexes)) then
  begin
    case AIndex of
      0: Result := FVertexes[FVertexIndex].Point.X;
      1: Result := FVertexes[FVertexIndex].Point.Y;
    end;
  end;
end;

procedure TUdPolyline.SetVertexValue(AIndex: Integer; const AValue: Float);
var
  I: Integer;
  LVertexes: TVertexes2D;
begin
  if (System.Length(FVertexes) > 0) and (FVertexIndex >= 0) and (FVertexIndex < System.Length(FVertexes)) then
  begin
    SetLength(LVertexes, System.Length(FVertexes));
    for I := 0 to System.Length(FVertexes) - 1 do LVertexes[I] := FVertexes[I];

    case AIndex of
      0: LVertexes[FVertexIndex].Point.X := AValue;
      1: LVertexes[FVertexIndex].Point.Y := AValue;
    end;

    Self.SetVertexes(LVertexes);
  end;
end;


function TUdPolyline.GetVertexBulge: Float;
begin
  Result := 0;
  if (System.Length(FVertexes) > 0) and (FVertexIndex >= 0) and (FVertexIndex < System.Length(FVertexes)) then
    Result := FVertexes[FVertexIndex].Bulge;
end;

procedure TUdPolyline.SetVertexBulge(const AValue: Float);
var
  I: Integer;
  LVertexes: TVertexes2D;
begin
  if (System.Length(FVertexes) > 0) and (FVertexIndex >= 0) and (FVertexIndex < System.Length(FVertexes)) then
  begin
    SetLength(LVertexes, System.Length(FVertexes));
    for I := 0 to System.Length(FVertexes) - 1 do LVertexes[I] := FVertexes[I];

    LVertexes[FVertexIndex].Bulge := AValue;
    Self.SetVertexes(LVertexes);
  end;
end;



function TUdPolyline.GetVertexWidth(AIndex: Integer): Float;
begin
  Result := 0;
  if (System.Length(FVertexes) > 0) and (FVertexIndex >= 0) and (FVertexIndex < System.Length(FWidths)) then
  begin
    case AIndex of
      0: Result := FWidths[FVertexIndex].X;
      1: Result := FWidths[FVertexIndex].Y;
    end;
  end;
end;

procedure TUdPolyline.SetVertexWidth(AIndex: Integer; const AValue: Float);
var
  I: Integer;
  LWidths: TPoint2DArray;
begin
  if (System.Length(FVertexes) > 0) and (FVertexIndex >= 0) and (FVertexIndex < System.Length(FWidths)) then
  begin
    SetLength(LWidths, System.Length(FWidths));
    for I := 0 to System.Length(FWidths) - 1 do LWidths[I] := FWidths[I];

    case AIndex of
      0: LWidths[FVertexIndex].X := AValue;
      1: LWidths[FVertexIndex].Y := AValue;
    end;

    Self.SetWidths(LWidths);
  end;
end;


function TUdPolyline.GetWidth(): Float;
var
  I, L: Integer;
begin
  Result := -1;
  if (System.Length(FWidths) <= 0) or NotEqual(FWidths[0].X, FWidths[0].Y) then Exit;

  L := System.Length(FWidths);

  Result := FWidths[0].X;
  for I := 1 to L - 2 do
    if NotEqual(FWidths[I].X, Result) or
       NotEqual(FWidths[I].Y, Result) then
    begin
      Result := -1;
      Exit; //====>>>
    end;

  if (Result >= 0) and NotEqual(FWidths[L - 1], Point2D(0, 0)) then
  begin
    if NotEqual(FWidths[L - 1].X, Result) or
       NotEqual(FWidths[L - 1].Y, Result) then
    begin
      Result := -1;
      Exit; //====>>>
    end;
  end;
end;

procedure TUdPolyline.SetWidth(const AValue: Float);
var
  I: Integer;
begin
  if (AValue >= 0) and Self.RaiseBeforeModifyObject('GloablWidth') then
  begin
    for I := 0 to System.Length(FWidths) - 1 do
    begin
      FWidths[I].X := AValue;
      FWidths[I].Y := AValue;
    end;

    Self.Update();
    Self.RaiseAfterModifyObject('GloablWidth');
  end;
end;




function TUdPolyline.GetGloablWidth(): string;
var
  LWidth: Float;
begin
  LWidth := Self.GetWidth;
  if LWidth >= 0 then Result := FloatToStr(LWidth) else Result := '';
end;

procedure TUdPolyline.SetGloablWidth(const AValue: string);
var
  LWidth: Float;
begin
  if (SysUtils.Trim(AValue) = '') then Exit;

  if TryStrToFloat(SysUtils.Trim(AValue), LWidth) and (LWidth > 0) then
    Self.SetWidth(LWidth);
end;




function TUdPolyline.GetArea(): Float;
var
  I: Integer;
  LSegars: TSegarc2DArray;
begin
  Result := 0;

  if FSplineFlag in [sfStandard, sfCtrlPnts] then
  begin
    LSegars := Self.GetXData();
    if FSplineFlag = sfCtrlPnts then
      for I := 0 to System.Length(LSegars) - 1 do LSegars[I].IsArc := False;

    if System.Length(LSegars) > 0 then
    begin
      if not FClosed then
      begin
        SetLength(LSegars, System.Length(LSegars) + 1);
        LSegars[High(LSegars)] := Segarc2D( Segment2D(LSegars[High(LSegars)-1].Seg.P2, LSegars[0].Seg.P1) );
      end;

      Result := UdGeo2D.Area(LSegars);
    end;
  end
  else begin
    Result := UdGeo2D.Area(FSamplePoints);
  end;
end;


function TUdPolyline.GetLength: Float;
var
  I: Integer;
  LSegars: TSegarc2DArray;
begin
  if FSplineFlag in [sfStandard, sfCtrlPnts] then
  begin
    LSegars := Self.GetXData();
    if FSplineFlag = sfCtrlPnts then
      for I := 0 to System.Length(LSegars) - 1 do LSegars[I].IsArc := False;

    Result := UdGeo2D.Perimeter(LSegars);
  end
  else begin
    Result := UdGeo2D.Perimeter(FSamplePoints);
  end;
end;



//-----------------------------------------------------------------------------------------

function TUdPolyline.FDrawPolyline(ACanvas: TCanvas; AColor: TColor; AAxes: TUdAxes): Boolean;
var
  I: Integer;
  LPnts: TPoint2DArray;
  LFgColor, LBkColor: TColor;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>    or not Assigned(AColor)


  ACanvas.Pen.Mode := pmCopy;
  ACanvas.Pen.Width := 1;

  if Self.Selected then
  begin
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Color := SELECTED_COLOR;

    LFgColor := SELECTED_COLOR;
    LBkColor := Self.GetLayoutBackColor();

    ACanvas.Brush.Bitmap := HatchBitmapsRes().GetSelPenBitmap(LBkColor, LFgColor);
  end
  else begin
    ACanvas.Pen.Style := psSolid;
    ACanvas.Pen.Color := AColor;

    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := AColor;
  end;

  for I := 0 to System.Length(FSamplePolygons) - 1 do
  begin
    LPnts := FSamplePolygons[I];
    if System.Length(LPnts) = 2 then
    begin
      ACanvas.MoveTo(AAxes.XPixel(LPnts[0].X), AAxes.YPixel(LPnts[0].Y));
      ACanvas.LineTo(AAxes.XPixel(LPnts[1].X), AAxes.YPixel(LPnts[1].Y));
    end
    else begin
      UdDrawUtil.DrawPolygon(ACanvas, AAxes, LPnts);
    end;
  end;

  Result := True;
end;


function TUdPolyline.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
begin
  if (FSplineFlag in [sfStandard, sfCtrlPnts]) and Self.HasWidths then
  begin
    Result := False;
    if not Assigned(ACanvas) or not Assigned(AAxes)  then Exit; //=======>>>

    Result := FDrawPolyline(ACanvas, Self.ActualTrueColor(AFlag), AAxes);
  end
  else
    Result := inherited DoDraw(ACanvas, AAxes, AFlag);
end;



//-----------------------------------------------------------------------------------------

function TUdPolyline.CanFilled(): Boolean;
begin
  Result := Self.FClosed;
end;


procedure TUdPolyline.UpdateBoundsRect(AAxes: TUdAxes);
var
  I: Integer;
  LRect: TRect2D;
begin
//  LSegarcs := UdGeo2D.Segarc2DArray(FVertexes);
//  FBoundsRect := UdGeo2D.RectHull(LSegarcs);

  if Self.HasWidths() and (FSplineFlag in [sfStandard, sfCtrlPnts]) and (System.Length(FSamplePolygons) > 0) then
  begin
    FBoundsRect := UdGeo2D.RectHull(FSamplePolygons[0]);

    for I := 1 to System.Length(FSamplePolygons) - 1 do
    begin
      LRect := UdGeo2D.RectHull(FSamplePolygons[I]);

      if FBoundsRect.X1 > LRect.X1 then FBoundsRect.X1 := LRect.X1;
      if FBoundsRect.X2 < LRect.X2 then FBoundsRect.X2 := LRect.X2;
      if FBoundsRect.Y1 > LRect.Y1 then FBoundsRect.Y1 := LRect.Y1;
      if FBoundsRect.Y2 < LRect.Y2 then FBoundsRect.Y2 := LRect.Y2;
    end;
  end
  else begin
    FBoundsRect := UdGeo2D.RectHull(FSamplePoints);
  end;
end;


function GetSamplePointsArray(ACtrlPnts: TPoint2DArray; AWidths: TPoint2DArray): TPoint2DArrays; overload;
var
  I: Integer;
  LAng: Float;
  LW1, LW2: Single;
  LP1, LP2: TPoint2D;
begin
  System.SetLength(Result, System.Length(ACtrlPnts) - 1);

  for I := 0 to System.Length(ACtrlPnts) - 2 do
  begin
    LP1 := ACtrlPnts[I];
    LP2 := ACtrlPnts[I+1];

    LW1 := AWidths[I].X; if LW1 < 0.0 then LW1 := 0.0;
    LW2 := AWidths[I].Y; if LW2 < 0.0 then LW2 := 0.0;

    if IsEqual(LW1, 0.0) and IsEqual(LW2, 0.0) then
    begin
      System.SetLength(Result[I], 2);
      Result[I][0] := LP1;
      Result[I][1] := LP2;
    end
    else begin
      LAng := GetAngle(LP1, LP2);

      System.SetLength(Result[I], 5);
      Result[I][0] := ShiftPoint(LP1, LAng + 90, LW1/2);
      Result[I][1] := ShiftPoint(LP2, LAng + 90, LW2/2);
      Result[I][2] := ShiftPoint(LP2, LAng - 90, LW2/2);
      Result[I][3] := ShiftPoint(LP1, LAng - 90, LW1/2);
      Result[I][4] := Result[I][0];
    end;
  end;
end;



function GetSamplePointsArray(AAxes: TUdAxes; ASegarcs: TSegarc2DArray; AWidths: TPoint2DArray): TPoint2DArrays; overload;

  function _SampleArcPoints(Arc: TArc2D; Segments: Integer; Wid1, Wid2: Float): TPoint2DArray;
  var
    I, N: Integer;
    A, D: Float;
    A1, A2: Float;
    DW: Float;
    LPnts1, LPnts2: TPoint2DArray;
  begin
    Result := nil;
    if (Arc.R <= 0.0) or IsEqual(Arc.Ang1, Arc.Ang2) then Exit;

    N  := Segments;
    A1 := FixAngle(Arc.Ang1);
    A2 := FixAngle(Arc.Ang2);

    if N <= 0 then
    begin
      N := Round(FixAngle(A2 - A1) / (DEF_ANG_STEP));
      if N <= 0 then N := 1;
    end;


    DW := Wid2 - Wid1;

    System.SetLength(LPnts1, N + 1);
    System.SetLength(LPnts2, N + 1);

    if Arc.IsCW then
    begin
      LPnts1[0] := GetArcPoint(Arc.Cen, Arc.R - Wid1/2, Arc.Ang2);
      LPnts2[0] := GetArcPoint(Arc.Cen, Arc.R + Wid1/2, Arc.Ang2);

      LPnts1[N] := GetArcPoint(Arc.Cen, Arc.R - Wid2/2, Arc.Ang1);
      LPnts2[N] := GetArcPoint(Arc.Cen, Arc.R + Wid2/2, Arc.Ang1);
    end
    else begin
      LPnts1[0] := GetArcPoint(Arc.Cen, Arc.R - Wid1/2, Arc.Ang1);
      LPnts2[0] := GetArcPoint(Arc.Cen, Arc.R + Wid1/2, Arc.Ang1);

      LPnts1[N] := GetArcPoint(Arc.Cen, Arc.R - Wid2/2, Arc.Ang2);
      LPnts2[N] := GetArcPoint(Arc.Cen, Arc.R + Wid2/2, Arc.Ang2);
    end;

    A := A1;
    D := FixAngle(A2 - A1) / N;
    for I := 1 to N - 1 do
    begin
      A := A + D;
      if Arc.IsCW then
      begin
        LPnts1[N-I] := GetArcPoint(Arc.Cen, Arc.R - Wid2/2 + (I/N)*(DW/2), A);
        LPnts2[N-I] := GetArcPoint(Arc.Cen, Arc.R + Wid2/2 - (I/N)*(DW/2), A);
      end
      else begin
        LPnts1[I]   := GetArcPoint(Arc.Cen, Arc.R - Wid1/2 + (I/N)*(DW/2), A);
        LPnts2[I]   := GetArcPoint(Arc.Cen, Arc.R + Wid1/2 - (I/N)*(DW/2), A);
      end;
    end;

    System.SetLength(Result, 2*(N + 1) + 1);
    for I := 0 to N do Result[I] := LPnts1[I];
    for I := 0 to N do Result[N + 1 + I] := LPnts2[N-I];
    Result[2*(N + 1)] := Result[0];
  end;

var
  I: Integer;
  N: Integer;
  LAng: Float;
  LW1, LW2: Single;
  LSegarc: TSegarc2D;
begin
  System.SetLength(Result, System.Length(ASegarcs));

  for I := 0 to System.Length(ASegarcs) - 1 do
  begin
    LSegarc := ASegarcs[I];

    LW1 := AWidths[I].X; if LW1 < 0.0 then LW1 := 0.0;
    LW2 := AWidths[I].Y; if LW2 < 0.0 then LW2 := 0.0;

    N := 0;
    if LSegarc.IsArc then
      N := SampleSegmentNum(AAxes.XValuePerPixel, LSegarc.Arc.R, FixAngle(LSegarc.Arc.Ang2 - LSegarc.Arc.Ang1));

    if IsEqual(LW1, 0.0) and IsEqual(LW2, 0.0) then
    begin
      if LSegarc.IsArc then
        Result[I] := SamplePoints(LSegarc.Arc, N)
      else
        Result[I] := SamplePoints(LSegarc.Seg);
    end
    else begin
      if LSegarc.IsArc then
      begin
        if IsEqual(LW1, LW2) then
          Result[I] := SamplePoints(LSegarc.Arc, N, LW1)
        else
          Result[I] :=  _SampleArcPoints(LSegarc.Arc, N, LW1, LW2);
      end
      else begin
        LAng := GetAngle(LSegarc.Seg.P1, LSegarc.Seg.P2);

        System.SetLength(Result[I], 5);
        Result[I][0] := ShiftPoint(LSegarc.Seg.P1, LAng + 90, LW1/2);
        Result[I][1] := ShiftPoint(LSegarc.Seg.P2, LAng + 90, LW2/2);
        Result[I][2] := ShiftPoint(LSegarc.Seg.P2, LAng - 90, LW2/2);
        Result[I][3] := ShiftPoint(LSegarc.Seg.P1, LAng - 90, LW1/2);
        Result[I][4] := Result[I][0];
      end;
    end;
  end;
end;

procedure TUdPolyline.UpdateSamplePoints(AAxes: TUdAxes);

  procedure _UpdateStandardSamplePoints(AAxes: TUdAxes);
  var
    I, N: Integer;
    LArc: TArc2D;
    LSegarcs: TSegarc2DArray;
    LSmplPnts, LPnts: TPoint2DArray;
  begin
    LSmplPnts := nil;

    LSegarcs := UdGeo2D.Segarc2DArray(FVertexes);

    if Self.HasWidths() then
    begin
      FSamplePolygons := GetSamplePointsArray(AAxes, LSegarcs, FWidths);
    end
    else begin
      for I := 0 to System.Length(LSegarcs) - 1 do
      begin
        if LSegarcs[I].IsArc then
        begin
          LArc := LSegarcs[I].Arc;

          N := SampleSegmentNum(AAxes.XValuePerPixel, LArc.R, FixAngle(LArc.Ang2 - LArc.Ang1));
          LPnts := UdGeo2D.SamplePoints(LArc, N);
        end
        else
          LPnts := UdGeo2D.SamplePoints(LSegarcs[I].Seg);

        FAddArray(LSmplPnts, LPnts);
      end;

      FSamplePoints := LSmplPnts;
    end;
  end;

  procedure _UpdateCtrlPntsSamplePoints(AAxes: TUdAxes);
  var
    LCtrlPnts: TPoint2DArray;
  begin
    LCtrlPnts := VertexesToPoints(FVertexes);

    if Self.HasWidths() then
    begin
      FSamplePolygons := GetSamplePointsArray(LCtrlPnts, FWidths);
    end
    else begin
      FSamplePoints := LCtrlPnts;
    end;
  end;

  procedure _UpdateBezierSamplePoints(AAxes: TUdAxes; AFlag: TUdSplineFlag);
  var
    LCtrlPnts: TPoint2DArray;
    LSmplPnts: TPoint2DArray;
  begin
    LCtrlPnts := VertexesToPoints(FVertexes);

    case AFlag of
      sfFitting  : LSmplPnts := UdBSpline2D.GetFittingBSplineSamplePoints(LCtrlPnts, System.Length(LCtrlPnts) * SEGMENTS_PER_SPLINE_CTLPNT, FClosed);
      sfQuadratic: LSmplPnts := UdBSpline2D.GetQuadraticSPlineSamplePoints(LCtrlPnts, System.Length(LCtrlPnts) * SEGMENTS_PER_SPLINE_CTLPNT, FClosed, FKnots);
      sfCubic    : LSmplPnts := UdBSpline2D.GetCubicSPlineSamplePoints(LCtrlPnts, System.Length(LCtrlPnts) * SEGMENTS_PER_SPLINE_CTLPNT, FClosed, FKnots);
    end;

    FSamplePoints := LSmplPnts;
  end;


begin
  FSamplePoints := nil;
  FSamplePolygons := nil;
  if HasWidths() then FPenWidth := 0.0;

  case FSplineFlag of
    sfStandard: _UpdateStandardSamplePoints(AAxes);
    sfCtrlPnts: _UpdateCtrlPntsSamplePoints(AAxes);
    sfFitting,
     sfQuadratic,
       sfCubic: _UpdateBezierSamplePoints(AAxes, FSplineFlag);
  end;
end;


function TUdPolyline.GetGripPoints(): TUdGripPointArray;
var
  I, L, N: Integer;
  LSegarcs: TSegarc2DArray;
begin
  Result := nil;

  LSegarcs := UdGeo2D.Segarc2DArray(FVertexes);
  if System.Length(LSegarcs) <= 0 then Exit; //========>>>

  L := 0;
  for I := 0 to System.Length(LSegarcs) - 1 do
    if LSegarcs[I].IsArc then Inc(L);

  System.SetLength(Result, System.Length(FVertexes) + L);

  for I := 0 to System.Length(FVertexes) - 1 do
    Result[I] := MakeGripPoint(Self, gmPoint, I, FVertexes[I].Point, 0.0);

  if L > 0 then
  begin
    N := 0;
    for I := 0 to System.Length(LSegarcs) - 1 do
    begin
      if LSegarcs[I].IsArc then
      begin
        Result[System.Length(FVertexes) + N] := MakeGripPoint(Self, gmCenter, I, MidPoint(LSegarcs[I].Arc), 0.0);
        Inc(N);
      end;
    end;
  end;
end;


function TUdPolyline.GetOSnapPoints: TUdOSnapPointArray;
var
  I, J: Integer;
  L, N: Integer;
  LAng: Float;
  LSegarc: TSegarc2D;
  LSegarcs: TSegarc2DArray;
  LQuaPnts: TPoint2DArray;  
begin
  LSegarcs := UdGeo2D.Segarc2DArray(FVertexes);
  L := System.Length(LSegarcs);

  if L <= 0 then
  begin
    Result := nil;
    Exit;
  end;


  if FClosed then N := L else N := L - 1;

  if FClosed then
    System.SetLength(Result, L*2 + 1 + N)
  else
    System.SetLength(Result, L*2 + 1 + N);

  for I := 0 to L - 1 do
  begin
    LSegarc := LSegarcs[I];

    if LSegarc.IsArc then
    begin
      Result[I * 2]     := MakeOSnapPoint(Self, OSNP_END, ArcEndPnts(LSegarc.Arc)[0], -1);
      Result[I * 2 + 1] := MakeOSnapPoint(Self, OSNP_MID, MidPoint(LSegarc.Arc), -1);
    end
    else begin
      LAng := UdGeo2D.GetAngle(LSegarc.Seg.P1, LSegarc.Seg.P2);
      Result[I * 2]     := MakeOSnapPoint(Self, OSNP_END, LSegarc.Seg.P1, LAng);
      Result[I * 2 + 1] := MakeOSnapPoint(Self, OSNP_MID, MidPoint(LSegarc.Seg), LAng);
    end;
  end;

  if LSegarc.IsArc then
    Result[L*2] := MakeOSnapPoint(Self, OSNP_END, ArcEndPnts(LSegarcs[L-1].Arc)[1], -1)
  else
    Result[L*2] := MakeOSnapPoint(Self, OSNP_END, LSegarcs[L-1].Seg.P2,
                                  UdGeo2D.GetAngle(LSegarcs[L-1].Seg.P1, LSegarcs[L-1].Seg.P2));


  for I := 0 to N - 1 do
  begin
    LSegarc := LSegarcs[I];

    if LSegarc.IsArc then
      Result[L*2 + I + 1] := MakeOSnapPoint(Self, OSNP_INT, ArcEndPnts(LSegarc.Arc)[1], -1)
    else
      Result[L*2 + I + 1] := MakeOSnapPoint(Self, OSNP_INT, LSegarc.Seg.P2,
                                            UdGeo2D.GetAngle(LSegarc.Seg.P1, LSegarc.Seg.P2));
  end;



  for I := 0 to L - 1 do
  begin
    LSegarc := LSegarcs[I];

    if LSegarc.IsArc then
    begin
      LQuaPnts := ArcQuadPnts(LSegarc.Arc);

      if System.Length(LQuaPnts) > 0 then
      begin
        N := System.Length(Result);
        System.SetLength(Result, N + System.Length(LQuaPnts));

        for J := 0 to System.Length(LQuaPnts) - 1 do
          Result[N + J] := MakeOSnapPoint(Self, OSNP_QUA, LQuaPnts[J], -1);
      end;
    end;
  end;

end;






//-----------------------------------------------------------------------------------------

function TUdPolyline.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
var
  I: Integer;
  LVertexes: TVertexes2D;
  LArc: TArc2D;
  LSegarc: TSegarc2D;
  LVex1, LVex2: TVertex2D;
  LP0, LP1, LP2: TPoint2D;
begin
  Result := False;
  if AGripPnt.Mode = gmPoint then
  begin
    if (AGripPnt.Index >= 0) and (AGripPnt.Index < System.Length(FVertexes)) then
    begin
      System.SetLength(LVertexes, System.Length(FVertexes));
      for I := 0 to System.Length(FVertexes) - 1 do  LVertexes[I] := FVertexes[I];

      LVertexes[AGripPnt.Index].Point := AGripPnt.Point;
      Self.SetVertexes(LVertexes);
    end;
    Result := True;
  end
  else if AGripPnt.Mode = gmCenter then
  begin
    if (AGripPnt.Index >= 0) and (AGripPnt.Index < System.Length(FVertexes)) and
       NotEqual(FVertexes[AGripPnt.Index].Bulge, 0.0)  then
    begin
      System.SetLength(LVertexes, System.Length(FVertexes));
      for I := 0 to System.Length(FVertexes) - 1 do  LVertexes[I] := FVertexes[I];

      LVex1 := LVertexes[AGripPnt.Index];
      LVex2 := LVertexes[(AGripPnt.Index + 1) mod System.Length(LVertexes)];

      LSegarc := Segarc2D(LVex1, LVex2);

      LP0 := GetArcPoint(LSegarc.Arc.Cen, LSegarc.Arc.R, LSegarc.Arc.Ang1);
      LP1 := AGripPnt.Point;;
      LP2 := GetArcPoint(LSegarc.Arc.Cen, LSegarc.Arc.R, LSegarc.Arc.Ang2);

      LArc := UdGeo2D.MakeArc(LP0, LP1, LP2);
      LVertexes[AGripPnt.Index].Bulge := UdGeo2D.GetVertexBulge(LVex1.Point, LVex2.Point, LArc);

      Self.SetVertexes(LVertexes);
    end;
    Result := True;
  end;
end;

function TUdPolyline.Pick(APoint: TPoint2D): Boolean;
var
  I: Integer;
  E: Float;
  LAxes: TUdAxes;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;


  if Self.HasWidths() and (FSplineFlag in [sfStandard, sfCtrlPnts]) and (System.Length(FSamplePolygons) > 0) then
  begin
    for I := 0 to System.Length(FSamplePolygons) - 1 do
    begin
      Result := IsPntInPolygon(APoint, FSamplePolygons[I], E);
      if Result then Break;
    end;
  end
  else begin
    Result := UdGeo2D.IsPntOnPolygon(APoint, FSamplePoints, E);
    if not Result and FFilled then
      Result := IsPntInPolygon(APoint, FSamplePoints, _HighiEpsilon);
  end;
end;

function TUdPolyline.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
var
  I: Integer;
  LIc: TInclusion;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LIc := UdGeo2D.Inclusion(FBoundsRect, ARect);
  Result := LIc = irOvered;

  if not Result and ACrossingMode then
  begin
    if Self.HasWidths() and (FSplineFlag in [sfStandard, sfCtrlPnts]) and (System.Length(FSamplePolygons) > 0) then
    begin
      for I := 0 to System.Length(FSamplePolygons) - 1 do
      begin
        Result := IsIntersect(ARect, FSamplePolygons[I]);
        if Result then Break;
      end;
    end
    else begin
      Result := UdGeo2D.IsIntersect(ARect, FSamplePoints);
    end;
  end;
end;



function TUdPolyline.Move(Dx, Dy: Float): Boolean;
var
  LPnts: TPoint2DArray;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LPnts := VertexesToPoints(FVertexes);
  LPnts := UdGeo2D.Translate(Dx, Dy, LPnts);

  VertexesCopyFromPoints(FVertexes, LPnts);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdPolyline.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LSegarcs := Segarc2DArray(FVertexes);
  LSegarcs := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LSegarcs);

  FVertexes := Vertexes2D(LSegarcs);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdPolyline.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
var
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ADis, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LSegarcs := Segarc2DArray(FVertexes);
  LSegarcs := UdGeo2D.OffsetSegarcs(LSegarcs, ADis, ASidePnt);

  FVertexes := Vertexes2D(LSegarcs);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdPolyline.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
var
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LSegarcs := Segarc2DArray(FVertexes);
  LSegarcs := UdGeo2D.Rotate(ABase, ARota, LSegarcs);

  FVertexes := Vertexes2D(LSegarcs);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdPolyline.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
var
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LSegarcs := Segarc2DArray(FVertexes);
  LSegarcs := UdGeo2D.Scale(ABase, AFactor, LSegarcs);

  FVertexes := Vertexes2D(LSegarcs);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdPolyline.Extend(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): Boolean;

  function _SegmentExtend(var ASeg: TSegment2D; AIsP1: Boolean): Boolean;
  var
    I, J: Integer;
    LAng: Float;
    LPnt: TPoint2D;
    LLine: TLine2D;
    LInctPnts: TPoint2DArray;
    LPointList: TPoint2DList;
  begin
    Result := False;
    if AIsP1 then LAng := GetAngle(ASeg.P2, ASeg.P1) else LAng := GetAngle(ASeg.P1, ASeg.P2);

    LLine := Line2D(ASeg.P1, ASeg.P2);
    LPointList := TPoint2DList.Create(MAXBYTE);
    try
      for I := 0 to System.Length(ASelectedEntities) - 1 do
      begin
        if Assigned(ASelectedEntities[I]) then
        begin
          LInctPnts := UdUtils.EntitiesIntersection(LLine, ASelectedEntities[I]);
          for J := 0 to System.Length(LInctPnts) - 1 do LPointList.Add(LInctPnts[J]);
        end;
      end;

      LPnt := MidPoint(ASeg.P1, ASeg.P2);

      for I := LPointList.Count - 1 downto 0 do
      begin
        if NotEqual(UdGeo2D.GetAngle(LPnt, LInctPnts[I]), LAng, 1) or
           UdGeo2D.IsPntOnSegment(LPointList.GetPoint(I), Segment2D(ASeg.P1, ASeg.P2)) then
          LPointList.RemoveAt(I);
      end;

      LInctPnts := LPointList.ToArray();
    finally
      LPointList.Free;
    end;

    if System.Length(LInctPnts) <= 0 then Exit;  //=======>>>>>>

    if AIsP1 then LPnt := ASeg.P1 else LPnt := ASeg.P2;
    LPnt := UdGeo2D.NearestPoint(LInctPnts, LPnt);

    if AIsP1 then ASeg.P1 := LPnt else ASeg.P2 := LPnt;
    Result := True;
  end;


  function _ArcExtend(var AArc: TArc2D; AIsP1: Boolean): Boolean;
  var
    I, J: Integer;
    LAng: Float;
    LCir: TCircle2D;
    LPnt: TPoint2D;
    LInctPnts: TPoint2DArray;
    LPointList: TPoint2DList;
  begin
    Result := False;

    LCir := Circle2D(AArc.Cen, AArc.R);
    LInctPnts := nil;

    LPointList := TPoint2DList.Create(MAXBYTE);
    try
      for I := 0 to System.Length(ASelectedEntities) - 1 do
      begin
        if Assigned(ASelectedEntities[I]) then
        begin
          LInctPnts := UdUtils.EntitiesIntersection(LCir, ASelectedEntities[I]);
          for J := 0 to System.Length(LInctPnts) - 1 do LPointList.Add(LInctPnts[J]);
        end;
      end;

      for I := LPointList.Count - 1 downto 0 do
      begin
        LAng := UdGeo2D.GetAngle(AArc.Cen, LPointList.GetPoint(I));
        if (LAng < 0) or IsInAngles(LAng, AArc.Ang1, AArc.Ang2) then
          LPointList.RemoveAt(I);
      end;

      LInctPnts := LPointList.ToArray();
    finally
      LPointList.Free;
    end;

    if System.Length(LInctPnts) <= 0 then Exit;  //=======>>>>>>


    if AIsP1 then
      LPnt := UdGeo2D.ShiftPoint(AArc.Cen, AArc.Ang1, AArc.R)
    else
      LPnt := UdGeo2D.ShiftPoint(AArc.Cen, AArc.Ang2, AArc.R);

    LPnt := UdGeo2D.NearestPoint(LInctPnts, LPnt);
    LAng := UdGeo2D.GetAngle(AArc.Cen, LPnt);

    if AIsP1 then
    begin
      if UdMath.NotEqual(AArc.Ang2, LAng) then
      begin
        AArc.Ang1 := LAng;
        Result := True;
      end;
    end
    else begin
      if UdMath.NotEqual(AArc.Ang1, LAng) then
      begin
        AArc.Ang2 := LAng;
        Result := True;
      end;
    end;
  end;

var
  I, N: Integer;
  LArc: TArc2D;
  LSeg: TSegment2D;
  LIsP1: Boolean;
  LPnt: TPoint2D;
  LIsArc: Boolean;
  LSegarc: TSegarc2D;
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if Self.Closed or not (FSplineFlag in [sfStandard, sfCtrlPnts]) then Exit;

  LSegarcs := Self.GetXData();
  if System.Length(LSegarcs) <= 0 then Exit;

  if FSplineFlag = sfCtrlPnts then
    for I := 0 to System.Length(LSegarcs) - 1 do LSegarcs[I].IsArc := False;


  N := 0;
  LIsP1 :=  False;

  if System.Length(LSegarcs) = 1 then
  begin
    N := 0;
    LSegarc := LSegarcs[0];
    LIsP1 :=  UdGeo2D.Distance(LSegarc.Seg.P1, APnt) < UdGeo2D.Distance(LSegarc.Seg.P2, APnt);
    Result := True;
  end
  else begin
    LPnt := ClosestSegarcsPoint(APnt, LSegarcs);

    if IsPntOnSegarc(LPnt, LSegarcs[0]) then
    begin
      N := 0;
      LSegarc := LSegarcs[0];
      LIsP1 :=  True;
      Result := True;
    end else
    if IsPntOnSegarc(LPnt, LSegarcs[High(LSegarcs)]) then
    begin
      N := High(LSegarcs);
      LSegarc := LSegarcs[High(LSegarcs)];
      LIsP1 :=  False;
      Result := True;
    end;
  end;

  if not Result then Exit; //======>>>>>


  Self.RaiseBeforeModifyObject('');


  LIsArc := LSegarc.IsArc and (FSplineFlag = sfStandard);
  if LIsP1 then LPnt := LSegarc.Seg.P1 else LPnt := LSegarc.Seg.P2;

  if LIsArc then
  begin
    LArc := LSegarc.Arc;
    if _ArcExtend(LArc, LIsP1) then
    begin
      LSegarcs[N] := Segarc2D(LArc);
      FVertexes := Vertexes2D(LSegarcs);
      Result := Self.Update();
    end;
  end
  else begin
    LSeg := LSegarc.Seg;
    if _SegmentExtend(LSeg, LIsP1) then
    begin
      LSegarcs[N] := Segarc2D(LSeg);
      FVertexes := Vertexes2D(LSegarcs);
      Result := Self.Update();
    end;
  end;

  Self.RaiseAfterModifyObject('');
end;





function TUdPolyline.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  I: Integer;
  LEntity: TUdPolyline;
  LSegarcs: TSegarc2DArray;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LSegarcs := Self.GetXData();

  if IsEqual(XFactor, YFactor) then
  begin
    LEntity := TUdPolyline.Create({Self.Document, False});
    LEntity.BeginUpdate();
    try
      LEntity.Assign(Self);
      LEntity.XData := UdGeo2D.Scale(ABase, XFactor, LSegarcs);
      for I := 0 to System.Length(LEntity.FWidths) - 1 do
      begin
        LEntity.FWidths[I].X := LEntity.FWidths[I].X * XFactor;
        LEntity.FWidths[I].Y := LEntity.FWidths[I].Y * XFactor;
      end;
    finally
      LEntity.EndUpdate();
    end;

    System.SetLength(Result, 1);
    Result[0] := LEntity;
  end
  else begin
    System.SetLength(Result, System.Length(LSegarcs));
    for I := 0 to System.Length(LSegarcs) - 1 do
    begin
      case LSegarcs[I].IsArc of
        True :
          begin
            if IsEqual(XFactor, YFactor) then
            begin
              Result[I] := TUdArc.Create({Self.Document, False});
              Result[I].BeginUpdate();
              try
                Result[I].Assign(Self);
                TUdArc(Result[I]).XData := UdGeo2D.Scale(ABase, XFactor, LSegarcs[I].Arc);
              finally
                Result[I].EndUpdate();
              end;
            end
            else begin
              Result[I] := TUdEllipse.Create({Self.Document, False});
              Result[I].BeginUpdate();
              try
                Result[I].Assign(Self);
                TUdEllipse(Result[I]).XData := UdGeo2D.Scale(ABase, XFactor, YFactor, LSegarcs[I].Arc);
              finally
                Result[I].EndUpdate();
              end;
            end;
          end;
        False:
          begin
            Result[I] := TUdLine.Create({Self.Document, False});
            Result[I].BeginUpdate();
            try
              Result[I].Assign(Self);
              TUdLine(Result[I]).XData := UdGeo2D.Scale(ABase, XFactor, YFactor, LSegarcs[I].Seg);
            finally
              Result[I].EndUpdate();
            end;
          end;
      end;
    end;
  end;
end;

function TUdPolyline.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  I: Integer;
  LPolyline: TUdPolyline;
  LSegarcs: TSegarc2DArray;
  LSegarcsArr: TSegarc2DArrays;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>

  if FSplineFlag in [sfStandard, sfCtrlPnts] then
  begin
    LSegarcs := Self.GetXData();
    if FSplineFlag = sfCtrlPnts then
      for I := 0 to System.Length(LSegarcs) - 1 do LSegarcs[I].IsArc := False;

    LSegarcsArr := UdGeo2D.BreakAt(LSegarcs,  APnt1, APnt2, FClosed);

    System.SetLength(Result, System.Length(LSegarcsArr));
    for I := 0 to System.Length(LSegarcsArr) - 1 do
    begin
      LPolyline := TUdPolyline(Self.Clone());
      LPolyline.Assign(Self);
      LPolyline.FClosed := False;
      LPolyline.SetXData(LSegarcsArr[I]);

      Result[I] := LPolyline;
    end;
  end;
end;

function TUdPolyline.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;

  function _SegarcIntersection(ASegarc: TSegarc2D; AOtherEntities: TUdEntityArray): TPoint2DArray;
  var
    I, J: Integer;
    LInctPnts: TPoint2DArray;
    LInctPntList: TPoint2DList;
  begin
    Result := nil;

    LInctPnts := nil;
    LInctPntList := TPoint2DList.Create(MAXBYTE);
    try
      LInctPntList.Add(ASegarc.Seg.P1);

      for I := 0 to System.Length(AOtherEntities) - 1 do
      begin
        if Assigned(AOtherEntities[I]) and (AOtherEntities[I] <> Self) then
        begin
          LInctPnts := UdUtils.EntitiesIntersection(ASegarc, AOtherEntities[I]);
          for J := 0 to System.Length(LInctPnts) - 1 do LInctPntList.Add(LInctPnts[J]);
        end;
      end;

      LInctPntList.Add(ASegarc.Seg.P2);

      Result := LInctPntList.ToArray();
    finally
      LInctPntList.Free;
    end;
  end;

var
  I, N: Integer;
  LPnt: TPoint2D;
  LP1, LP2: TPoint2D;
  LSegarc: TSegarc2D;
  LSegarcs: TSegarc2DArray;
  LInctPnts: TPoint2DArray;
begin
  Result := nil;
  if not (FSplineFlag in [sfStandard, sfCtrlPnts]) then Exit;

  LSegarcs := Self.GetXData();
  if System.Length(LSegarcs) <= 0 then Exit;

  if FSplineFlag = sfCtrlPnts then
    for I := 0 to System.Length(LSegarcs) - 1 do LSegarcs[I].IsArc := False;

  LPnt := ClosestSegarcsPoint(APnt, LSegarcs, N);

  LSegarc := LSegarcs[N];
  LInctPnts := _SegarcIntersection(LSegarc, ASelectedEntities);

  if System.Length(LInctPnts) <= 0 then Exit; //======>>>>

  if LSegarc.IsArc then
    GetArcTrimBreakPnts(LSegarc.Arc, LPnt, LInctPnts, LP1, LP2)
  else
    GetSegTrimBreakPnts(LSegarc.Seg, LPnt, LInctPnts, LP1, LP2);

  Result := Self.BreakAt(LP1, LP2);
end;

function TUdPolyline.Explode: TUdObjectArray;

  procedure _InitEntity(AEntity: TUdEntity);
  begin
    AEntity.Layer := FLayer;

    AEntity.Color.Assign(FColor);
    AEntity.LineType.Assign(FLineType);
    AEntity.LineWeight := FLineWeight;
  end;

var
  I: Integer;
  LSegarcs: TSegarc2DArray;
begin
  LSegarcs := Self.GetXData();
  System.SetLength(Result, System.Length(LSegarcs));

  for I := 0 to System.Length(LSegarcs) - 1 do
  begin
    if LSegarcs[I].IsArc then
    begin
      Result[I] := TUdArc.Create({Self.Document, False});
      _InitEntity(TUdEntity(Result[I]));
      TUdArc(Result[I]).XData := LSegarcs[I].Arc;
    end
    else begin
      Result[I] := TUdLine.Create({Self.Document, False});
      _InitEntity(TUdEntity(Result[I]));
      TUdLine(Result[I]).XData := LSegarcs[I].Seg;
    end;
  end;
end;



function TUdPolyline.Intersect(AOther: TUdEntity): TPoint2DArray;
var
  LPnts: TPoint2DArray;
  LSegarcs: TSegarc2DArray;
begin
  LPnts := nil;
  Result := nil;

  if not Self.IsVisible or Self.IsLock() then Exit; //======>>>>
  if not Assigned(AOther) or not AOther.IsVisible or AOther.IsLock() then Exit; //======>>>>

  if FSplineFlag = sfStandard then
  begin
    LSegarcs := Segarc2DArray(FVertexes);
    Result := UdUtils.EntitiesIntersection(LSegarcs, AOther);
  end
  else begin
    // sfFitting, sfQuadratic, sfCubic 情况下 使用多边形模拟的
    Result := UdUtils.EntitiesIntersection(FSamplePoints, AOther);
  end;
end;

function TUdPolyline.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  I: Integer;
  LLn: TLine2D;
  LPnt: TPoint2D;
begin
  Result := nil;

  if FSplineFlag = sfStandard then
  begin
    for I := 0 to System.Length(FVertexes) - 2 do
    begin
      if IsEqual(FVertexes[I].Bulge, 0) then
      begin
        LLn := UdGeo2D.Line2D(FVertexes[I].Point, FVertexes[I+1].Point);

        LPnt := UdGeo2D.ClosestLinePoint(APnt, LLn);
        if UdGeo2D.IsPntOnSegment(LPnt, Segment2D(FVertexes[I].Point, FVertexes[I+1].Point)) then
        begin
          System.SetLength(Result, 1);
          Result[0] := LPnt;

          Break;
        end;
      end;
    end;
  end
  else if FSplineFlag = sfCtrlPnts then
  begin
    for I := 0 to System.Length(FVertexes) - 2 do
    begin
      LLn := UdGeo2D.Line2D(FVertexes[I].Point, FVertexes[I+1].Point);

      LPnt := UdGeo2D.ClosestLinePoint(APnt, LLn);
      if UdGeo2D.IsPntOnSegment(LPnt, Segment2D(FVertexes[I].Point, FVertexes[I+1].Point)) then
      begin
        System.SetLength(Result, 1);
        Result[0] := LPnt;

        Break;
      end;
    end;
  end;
end;







//-----------------------------------------------------------------------------------------

procedure TUdPolyline.SaveToStream(AStream: TStream);
begin
  inherited;

  IntToStream(AStream, Ord(FSplineFlag));
  BoolToStream(AStream, FClosed);

  FloatsToStream(AStream, FKnots);
  VertexesToStream(AStream, FVertexes);
  PointsToStream(AStream, FWidths);
end;

procedure TUdPolyline.LoadFromStream(AStream: TStream);
begin
  inherited;

  FSplineFlag := TUdSplineFlag(IntFromStream(AStream));
  FClosed := BoolFromStream(AStream);

  FKnots := FloatsFromStream(AStream);
  FVertexes := VertexesFromStream(AStream);
  FWidths := PointsFromStream(AStream);

  Update();
end;




procedure TUdPolyline.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I, N: Integer;
  LStr: string;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['SplineFlag']   := IntToStr(Ord(FSplineFlag));
  LXmlNode.Prop['Closed']       := BoolToStr(FClosed, True);

  LStr := '';
  if System.Length(FKnots) > 0 then
  begin
    N := System.Length(FKnots) -1;
    for I := 0 to N do
    begin
      LStr := LStr + FloatToStr(FKnots[I]);
      if I <> N then LStr := LStr + ',';
    end;
    LXmlNode.Prop['Knots']  := LStr;
  end;

  LStr := '';
  if System.Length(FVertexes) > 0 then
  begin
    N := System.Length(FVertexes) -1;
    for I := 0 to N do
    begin
      LStr := LStr + Point2DToStr(FVertexes[I].Point) + ',' + FloatToStr(FVertexes[I].Bulge);
      if I <> N then LStr := LStr + ';';
    end;
    LXmlNode.Prop['Vertexes']  := LStr;
  end;

  LStr := '';
  if System.Length(FWidths) > 0 then
  begin
    N := System.Length(FWidths) -1;
    for I := 0 to N do
    begin
      LStr := LStr + Point2DToStr(FWidths[I]);
      if I <> N then LStr := LStr + ';';
    end;
    LXmlNode.Prop['Widths']  := LStr;
  end;
end;

procedure TUdPolyline.LoadFromXml(AXmlNode: TObject);
var
  I, N: Integer;
  LXmlNode: TUdXmlNode;
  LStrs: TStringDynArray;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FSplineFlag := TUdSplineFlag(StrToIntDef(LXmlNode.Prop['SplineFlag'], 0));
  FClosed     := StrToBoolDef(LXmlNode.Prop['Closed'], False);

  LStrs := UdUtils.StrSplit(LXmlNode.Prop['Knots'], ',');
  SetLength(FKnots, System.Length(LStrs));
  for I := 0 to System.Length(LStrs) - 1 do
    FKnots[I] := StrToFloat(LStrs[I]);

  LStrs := UdUtils.StrSplit(LXmlNode.Prop['Vertexes'], ';');
  SetLength(FVertexes, System.Length(LStrs));
  for I := 0 to System.Length(LStrs) - 1 do
  begin
    N := Pos('),', LStrs[I]);
    FVertexes[I].Point := StrToPoint2D(Copy(LStrs[I], 1, N));
    FVertexes[I].Bulge := StrToFloatDef(Copy(LStrs[I], N+2, System.Length(LStrs[I])), 0);
  end;

  LStrs := UdUtils.StrSplit(LXmlNode.Prop['Widths'], ';');
  SetLength(FWidths, System.Length(LStrs));
  for I := 0 to System.Length(LStrs) - 1 do
    FWidths[I] := StrToPoint2D(LStrs[I]);

  Update();
end;



end.