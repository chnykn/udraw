{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdHatch;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics, Types,
  UdConsts, UdTypes, UdGTypes,
  UdIntfs, UdObject, UdEntity, UdAxes, UdColor, UdLineWeight,
  UdHatchPatterns, UdHatchPattern, UdPatternLines;

type
  TUdHatchStyle = (hsNormal, hsOuter, hsIgnore);
  TUdHatchPatternType = (hptPredefined, hptUserDefined, hptCustomDefined);





  //-----------------------------------------------------
  
  TUdHatch = class(TUdEntity, IUdExplode)
  private
    FStyle      : TUdHatchStyle;
    FPatternType: TUdHatchPatternType;
    FPatternName: string;
    FHatchPattern: TUdHatchPattern;

    FHatchScale: Float;
    FHatchAngle: Float;

    FSegments: TSegment2DArray;
    FEvedLoops: TSegarc2DArrays;

    FLoops: TSegarc2DArrays;
    FPolyCurves: TCurve2DArrays;


    FGripCenter: TPoint2D;
    FCenteGriping: Boolean;

  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function GetIsSolid(): Boolean;

    procedure SetStyle(const AValue: TUdHatchStyle);
    procedure SetPatternType(const AValue: TUdHatchPatternType);
    procedure SetPatternName(const AValue: string);

    procedure SetHatchScale(const AValue: Float);
    procedure SetHatchAngle(const AValue: Float);

    function GetBoundsRect(): TRect2D;

    function FDrawSolid(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; AEvedLoops: TSegarc2DArrays): Boolean;
    function FDrawPattern(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; ASegments: TSegment2DArray; ALwFactor: Double = 1.0): Boolean;

    function DoUpdate(AAxes: TUdAxes): Boolean; override;
    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure SetHatchPattern(AValue: TUdHatchPattern);

    function GetGripPoints(): TUdGripPointArray; override;
    function GetOSnapPoints(): TUdOSnapPointArray; override;

    function AddLoop(ASegarcs: TSegarc2DArray): Boolean;
    function AddCurves(ACurves: TCurve2DArray): Boolean;

    function Evaluate(): Boolean;


    { operation... }
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;

    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;

    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;
    function Intersect(AOther: TUdEntity): TPoint2DArray; override;

    function Explode(): TUdObjectArray;
    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;

    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property IsSolid     : Boolean         read GetIsSolid;
    
    property Loops       : TSegarc2DArrays read FLoops;
    property PolyCurves  : TCurve2DArrays  read FPolyCurves;

    property XData       : TSegment2DArray read FSegments;
    property HatchPattern: TUdHatchPattern read FHatchPattern;

  published
    property Style       : TUdHatchStyle read FStyle write SetStyle;
    property PatternName : string        read FPatternName write SetPatternName;
    property PatternType : TUdHatchPatternType read FPatternType write SetPatternType;

    property HatchScale  : Float read FHatchScale write SetHatchScale;
    property HatchAngle  : Float read FHatchAngle write SetHatchAngle;

  end;



implementation

uses
  SysUtils,
  UdLine, UdMath, UdGeo2D,  UdBSpline2D, UdUtils, UdStrConverter,
  UdArrays, UdStreams, UdXml, UdHatchBitmaps
  {$IFNDEF D2010}, UdCanvas{$ENDIF};



//=================================================================================================
{ TUdHatch }

constructor TUdHatch.Create();
begin
  inherited;

  FStyle := hsNormal;
  FPatternType := hptPredefined;
  FPatternName := '';
  FHatchPattern := nil;

  FHatchScale := 1.0;
  FHatchAngle := 0.0;


  FLoops      := nil;
  FEvedLoops  := nil;
  FSegments   := nil;
  FPolyCurves := nil;


  FGripCenter := Point2D(0, 0);
  FCenteGriping := False;
end;

destructor TUdHatch.Destroy;
var
  I: Integer;
begin
  FLoops := nil;
  FSegments := nil;

  for I := 0 to System.Length(FPolyCurves) - 1 do FreeCurveArray(FPolyCurves[I]);
  FPolyCurves := nil;

  if Assigned(FHatchPattern) then FHatchPattern.Free;
  FHatchPattern := nil;

  inherited;
end;


function TUdHatch.GetTypeID: Integer;
begin
  Result := ID_HATCH;
end;

procedure TUdHatch.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

end;





//-----------------------------------------------------------------------------------------

procedure TUdHatch.CopyFrom(AValue: TUdObject);
var
  I, J: Integer;
  LSegarcs: TSegarc2DArray;
begin
  inherited;
  if not AValue.InheritsFrom(TUdHatch) then Exit; //========>>>

  Self.FStyle       := TUdHatch(AValue).FStyle      ;
  Self.FPatternType := TUdHatch(AValue).FPatternType;
  Self.FPatternName := TUdHatch(AValue).FPatternName;

  Self.FHatchScale  := TUdHatch(AValue).FHatchScale ;
  Self.FHatchAngle  := TUdHatch(AValue).FHatchAngle ;

  System.SetLength(FLoops, System.Length(TUdHatch(AValue).FLoops));
  for I := 0 to System.Length(TUdHatch(AValue).FLoops) - 1 do
  begin
    LSegarcs := TUdHatch(AValue).FLoops[I];

    System.SetLength(FLoops[I], System.Length(LSegarcs));
    for J := 0 to System.Length(LSegarcs) - 1 do FLoops[I][J] := LSegarcs[J];
  end;

  FGripCenter := TUdHatch(AValue).FGripCenter ;

  Self.Update();
end;






procedure TUdHatch.SetStyle(const AValue: TUdHatchStyle);
begin
  if (FStyle <> AValue) and Self.RaiseBeforeModifyObject('Style') then
  begin
    FStyle := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Style');
  end;
end;


procedure TUdHatch.SetPatternType(const AValue: TUdHatchPatternType);
begin
  if (FPatternType <> AValue) and Self.RaiseBeforeModifyObject('PatternType') then
  begin
    FPatternType := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('PatternType');
  end;
end;

procedure TUdHatch.SetPatternName(const AValue: string);
var
  LHatchPattern: TUdHatchPattern;
  LHatchPatterns: TUdHatchPatterns;
begin
  if (FPatternName = AValue) then Exit; //======>>>
  
  LHatchPattern := nil;
  LHatchPatterns := Self.GetHatchPatterns();
  if Assigned(LHatchPatterns) then
    LHatchPattern := LHatchPatterns.GetItem(AValue);

  if Assigned(LHatchPattern) and Self.RaiseBeforeModifyObject('PatternName') then
  begin
    if Assigned(FHatchPattern) then FHatchPattern.Free;
    FHatchPattern := nil;
  
    FHatchPattern := TUdHatchPattern.Create();
    FHatchPattern.Assign(LHatchPattern);
    FHatchPattern.PatternLines.Scale(FHatchScale);

    FPatternName := AValue;

    Self.Update();
    Self.RaiseAfterModifyObject('PatternName');
  end;
end;



procedure TUdHatch.SetHatchPattern(AValue: TUdHatchPattern);
begin
  if Assigned(FHatchPattern) then FHatchPattern.Free;
  FHatchPattern := nil;
  
  FHatchPattern := AValue;
  if Assigned(FHatchPattern) then
  begin
    FPatternName := FHatchPattern.Name;
    FHatchPattern.Owner := Self;
//    FHatchPattern.SetDocument(Self.Document, False);    
  end;
end;




procedure TUdHatch.SetHatchScale(const AValue: Float);
begin
  if NotEqual(AValue, 0.0) and (AValue > 0.0) and
     NotEqual(FHatchScale, AValue) and Self.RaiseBeforeModifyObject('HatchScale') then
  begin
    if Assigned(FHatchPattern) then
      FHatchPattern.PatternLines.Scale(AValue/FHatchScale);

    FHatchScale := AValue;
    Self.Update();
    
    Self.RaiseAfterModifyObject('HatchScale');
  end;
end;

procedure TUdHatch.SetHatchAngle(const AValue: Float);
begin
  if NotEqual(FHatchAngle, AValue) and Self.RaiseBeforeModifyObject('HatchAngle') then
  begin
    FHatchAngle := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('HatchAngle');
  end;
end;




//-----------------------------------------------------------------------------------------

function TUdHatch.DoUpdate(AAxes: TUdAxes): Boolean;
begin
  Result := Self.Evaluate();
end;


function TUdHatch.FDrawSolid(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; AEvedLoops: TSegarc2DArrays): Boolean;

  function _SamplePoints(ASegarcs: TSegarc2DArray): TPoint2DArray;
  var
    N, L: Integer;
    I, J: Integer;
    LSegarc: TSegarc2D;
    LPoints: TPoint2DArray;
  begin
    Result := nil;
    LPoints := nil;

    for I := 0 to System.Length(ASegarcs) - 1 do
    begin
      LSegarc := ASegarcs[I];
      if LSegarc.IsArc then
      begin
        N := SampleSegmentNum(AAxes.XValuePerPixel, LSegarc.Arc.R, FixAngle(LSegarc.Arc.Ang2 - LSegarc.Arc.Ang1));
        LPoints := SamplePoints(LSegarc.Arc, N)
      end
      else
        LPoints := SamplePoints(LSegarc.Seg);

      if (System.Length(Result) > 0) and (System.Length(LPoints) > 0) and IsEqual(Result[High(Result)], LPoints[0]) then
        System.SetLength(Result, System.Length(Result) - 1);

      if System.Length(LPoints) > 0 then
      begin
        L := System.Length(Result);
        System.SetLength(Result, L + System.Length(LPoints));

        for J := 0 to System.Length(LPoints) - 1 do
          Result[L + J] := LPoints[J];
      end;
    end;

  end;

var
  V: Float;
  I, J: Integer;
  M, L: Integer;
  LBkColor: TColor;
  LLoop: TSegarc2DArray;
  LPolygon: TPoint2DArray;
  LPoints: array of TPoint;
  LPolysCount: TIntegerDynArray;
begin
  Result := False;
  if not Assigned(ACanvas) or
     not Assigned(AAxes) then Exit; //=======>>>

  ACanvas.Pen.Style := psClear;

  if Self.Selected then
  begin
    LBkColor := Self.GetLayoutBackColor();
    ACanvas.Brush.Bitmap := HatchBitmapsRes().GetSelPenBitmap(LBkColor, SELECTED_COLOR);
  end
  else begin
    ACanvas.Brush.Color := AColor;
    ACanvas.Brush.Style := bsSolid;
  end;

  M := 0;
  LPoints := nil;
  LPolysCount := nil;

  for I := 0 to System.Length(AEvedLoops) - 1 do
  begin
    LLoop := AEvedLoops[I];
    LPolygon := _SamplePoints(LLoop);

    L := System.Length(LPolygon);
    if L <= 1 then Continue;

    System.SetLength(LPoints, M + L);
    for J := 0 to L - 1 do
    begin
      with AAxes.XAxis do
      begin
        V := (LPolygon[J].X - Min) * PixelPerValue;
        LPoints[M+J].X := Trunc(Pan + V) + AAxes.Margin;
      end;

      with AAxes.YAxis do
      begin
        V := (LPolygon[J].Y - Min) * PixelPerValue;
        LPoints[M+J].Y := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
      end;

//      LPoints[M+J].X := AAxes.XPixel(LPolygon[J].X);
//      LPoints[M+J].Y := AAxes.YPixel(LPolygon[J].Y);
    end;

    System.SetLength(LPolysCount, System.Length(LPolysCount) + 1);
    LPolysCount[High(LPolysCount)] := L;

    M := M + L;
  end;

  if System.Length(LPoints) > 0 then
  begin
    SetPolyFillMode(ACanvas.Handle, ALTERNATE);

    Windows.PolyPolygon(ACanvas.Handle, LPoints[0], LPolysCount[0], System.Length(LPolysCount));
    Result := True;
  end;
end;


function TUdHatch.FDrawPattern(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; ASegments: TSegment2DArray; ALwFactor: Double = 1.0): Boolean;
var
  I: Integer;
  V: Float;
  LColor: TColor;
  LX1, LY1, LX2, LY2: Integer;
  {$IFNDEF D2010}LExFunc: Boolean; {$ENDIF}
begin
  Result := False;
  if not Assigned(ACanvas) or
     not Assigned(AAxes) then Exit; //=======>>>

  {$IFNDEF D2010}LExFunc := ACanvas.InheritsFrom(TUdCanvas); {$ENDIF}
  
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Mode := pmCopy;
  ACanvas.Pen.Width := GetLineWeightWidth(Self.ActualLineWeight(), ALwFactor);

  ACanvas.Brush.Style := bsClear;



  if Self.Selected then
    LColor := SELECTED_COLOR
  else
    LColor := AColor;

  ACanvas.Pen.Color := LColor;

  for I := 0 to System.Length(ASegments) - 1 do
  begin
    //LX1 := AAxes.XPixel(ASegments[I].P1.X);
    //LY1 := AAxes.YPixel(ASegments[I].P1.Y);

    //LX2 := AAxes.XPixel(ASegments[I].P2.X);
    //LY2 := AAxes.YPixel(ASegments[I].P2.Y);


    with AAxes.XAxis do
    begin
      V   := (ASegments[I].P1.X - Min) * PixelPerValue;
      LX1 := Trunc(Pan + V) + AAxes.Margin;
    end;

    with AAxes.YAxis do
    begin
      V   := (ASegments[I].P1.Y - Min) * PixelPerValue;
      LY1 := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
    end;

    with AAxes.XAxis do
    begin
      V   := (ASegments[I].P2.X - Min) * PixelPerValue;
      LX2 := Trunc(Pan + V) + AAxes.Margin;
    end;

    with AAxes.YAxis do
    begin
      V   := (ASegments[I].P2.Y - Min) * PixelPerValue;
      LY2 := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
    end;

    if (LX1 = LX2) and (LY1 = LY2) then
    begin
      ACanvas.Pixels[LX1, LY1] := LColor;
    end
    else begin
    {$IFDEF D2010}
      ACanvas.MoveTo(LX1, LY1);
      ACanvas.LineTo(LX2, LY2);
    {$ELSE}
      if LExFunc then
      begin
        TUdCanvas(ACanvas).MoveToEx(LX1, LY1);
        TUdCanvas(ACanvas).LineToEx(LX2, LY2);
      end
      else begin
        ACanvas.MoveTo(LX1, LY1);
        ACanvas.LineTo(LX2, LY2);
      end;
    {$ENDIF}
    end;
  end;

  Result := True;
end;



function TUdHatch.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>

  if Self.IsSolid then
    Result := FDrawSolid(ACanvas, AAxes, Self.ActualTrueColor(AFlag), FEvedLoops)
  else
    Result := FDrawPattern(ACanvas, AAxes, Self.ActualTrueColor(AFlag), FSegments, ALwFactor);
end;


function TUdHatch.GetGripPoints: TUdGripPointArray;
begin
  System.SetLength(Result, 1);
  if not FCenteGriping then
    FGripCenter :=  Center(FBoundsRect);
  Result[0] := MakeGripPoint(Self, gmCenter, 0, FGripCenter, 0);
end;

function TUdHatch.GetIsSolid: Boolean;
var
  LStr: string;
begin
  LStr := UpperCase(SysUtils.Trim(FPatternName));
  Result := (LStr = '') or (LStr = 'SOLID') or
            not Assigned(FHatchPattern) or (Assigned(FHatchPattern) and FHatchPattern.IsSolid());
end;

function TUdHatch.GetOSnapPoints: TUdOSnapPointArray;
begin
  Result := nil;
end;




//--------------------------------------------------------------------------------------------------

function TUdHatch.AddLoop(ASegarcs: TSegarc2DArray): Boolean;
var
  L: Integer;
  LCurves: TCurve2DArray;
begin
  Result := False;
  if (System.Length(ASegarcs) <= 0) then Exit;
//  if (System.Length(ASegarcs) < 2) then Exit;
//  if (System.Length(ASegarcs) = 2) and not ASegarcs[0].IsArc and not ASegarcs[1].IsArc then Exit;
//  if NotEqual(ASegarcs[0].Seg.P1, ASegarcs[High(ASegarcs)].Seg.P2) then Exit;

  SetLength(LCurves, 1);
  LCurves[0].Kind := ckPolyline;
  LCurves[0].Data := New(PVertexes2D);
  PVertexes2D(LCurves[0].Data)^ := Vertexes2D(ASegarcs);

  L := System.Length(FPolyCurves);
  System.SetLength(FPolyCurves, L+1);

  FPolyCurves[L] := LCurves;
  
  Result := True;
end;


function TUdHatch.AddCurves(ACurves: TCurve2DArray): Boolean;
var
  L: Integer;
begin
  Result := False;
  if (System.Length(ACurves) <= 0) then Exit;

  L := System.Length(FPolyCurves);
  System.SetLength(FPolyCurves, L+1);

  AssignCurveArray(FPolyCurves[L], ACurves);

  Result := True;
end;



function FGetOuterLoops(ALoops: TSegarc2DArrays): TSegarc2DArrays;
var
  I, J, K: Integer;
  LLoops: TSegarc2DArrays;
  ISegarcs: TSegarc2DArray;
  JSegarcs: TSegarc2DArray;
begin
  Result := nil;

  System.SetLength(LLoops, System.Length(ALoops));
  for I := 0 to System.Length(ALoops) - 1 do LLoops[I] := ALoops[I];

  for I := 0 to System.Length(LLoops) - 2 do
  begin
    ISegarcs := LLoops[I];
    if System.Length(ISegarcs) <= 0 then Continue;

    for J := I + 1 to System.Length(LLoops) - 1 do
    begin
      JSegarcs := LLoops[J];
      if System.Length(JSegarcs) <= 0 then Continue;

      if UdGeo2D.InterInclusion(JSegarcs, ISegarcs) = irOvered then
      begin
        for K := 0 to System.Length(LLoops) - 1 do
        begin
          if (K <> J) and (System.Length(LLoops[K]) > 0) and (UdGeo2D.InterInclusion(LLoops[K], JSegarcs) = irOvered) then
            LLoops[K] := nil;
        end;
      end
      else if UdGeo2D.InterInclusion(ISegarcs, JSegarcs) = irOvered then
      begin
        for K := 0 to System.Length(LLoops) - 1 do
        begin
          if (K <> I) and (System.Length(LLoops[K]) > 0) and (UdGeo2D.InterInclusion(LLoops[K], ISegarcs) = irOvered) then
            LLoops[K] := nil;
        end;
      end;
    end;
  end;

  for I := 0 to System.Length(LLoops) - 1 do
  begin
    if System.Length(LLoops[I]) > 0 then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LLoops[I];
    end;
  end;
end;

function FGetIgnoreLoops(ALoops: TSegarc2DArrays): TSegarc2DArrays;
var
  I, J: Integer;
  LLoops: TSegarc2DArrays;
  ISegarcs: TSegarc2DArray;
  JSegarcs: TSegarc2DArray;
begin
  Result := nil;

  System.SetLength(LLoops, System.Length(ALoops));
  for I := 0 to System.Length(ALoops) - 1 do LLoops[I] := ALoops[I];

  for I := 0 to System.Length(LLoops) - 2 do
  begin
    ISegarcs := LLoops[I];
    if System.Length(ISegarcs) <= 0 then Continue;

    for J := I + 1 to System.Length(LLoops) - 1 do
    begin
      JSegarcs := LLoops[J];
      if System.Length(JSegarcs) <= 0 then Continue;

      if UdGeo2D.InterInclusion(JSegarcs, ISegarcs) = irOvered then
      begin
        LLoops[J] := nil;
      end
      else if UdGeo2D.InterInclusion(ISegarcs, JSegarcs) = irOvered then
      begin
        LLoops[I] := nil;
        Break;
      end;
    end;
  end;

  for I := 0 to System.Length(LLoops) - 1 do
  begin
    if System.Length(LLoops[I]) > 0 then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := LLoops[I];
    end;
  end;
end;


function TUdHatch.GetBoundsRect(): TRect2D;
var
  I: Integer;
  LRect: TRect2D;
begin
  Result := Rect2D(0,0,0,0);
  if System.Length(FEvedLoops) > 0 then
  begin
    Result := UdGeo2D.RectHull(FEvedLoops[0]);

    for I := 1 to System.Length(FEvedLoops) - 1 do
    begin
      LRect := UdGeo2D.RectHull(FEvedLoops[I]);

      if Result.X1 > LRect.X1 then Result.X1 := LRect.X1;
      if Result.X2 < LRect.X2 then Result.X2 := LRect.X2;
      if Result.Y1 > LRect.Y1 then Result.Y1 := LRect.Y1;
      if Result.Y2 < LRect.Y2 then Result.Y2 := LRect.Y2;
    end;
  end;
end;

function TUdHatch.Evaluate(): Boolean;

  function _GetSegarcs(ACurve: TCurve2D): TSegarc2DArray;
  var
    LArc: TArc2D;
    LEll: TEllipse2D;
    LSpline: TSpline2D;
    LPnts: TPoint2DArray;
  begin
    Result := nil;

    case ACurve.Kind of
      ckPolyline:
      begin
        Result := UdGeo2D.Segarc2DArray(PVertexes2D(ACurve.Data)^);
      end;

      ckLine:
      begin
        System.SetLength(Result, 1);
        Result[0] := Segarc2D(PSegment2D(ACurve.Data)^);
      end;

      ckArc:
      begin
        LArc := PArc2D(ACurve.Data)^;
        if IsEqual(LArc.Ang1, 0.0) and IsEqual(LArc.Ang2, 360.0) then
        begin
          System.SetLength(Result, 2);
          Result[0] := Segarc2D(Arc2D(LArc.Cen, LArc.R, 0, 180));
          Result[1] := Segarc2D(Arc2D(LArc.Cen, LArc.R, 180, 360));
        end
        else begin
          System.SetLength(Result, 1);
          Result[0] := Segarc2D(LArc);
        end;
      end;

      ckEllipse:
      begin
        LEll := PEllipse2D(ACurve.Data)^;

        Result := UdGeo2D.Segarc2DArray(
          UdGeo2D.SamplePoints(LEll, Round(FixAngle(LEll.Ang2 - LEll.Ang1) / 3) )
          );
      end;

      ckSpline:
      begin
        LSpline := PSpline2D(ACurve.Data)^;
        if LSpline.Degree = 3 then
          LPnts := UdBSpline2D.GetCubicSPlineSamplePoints(LSpline.CtlPnts, Length(LSpline.CtlPnts) * SEGMENTS_PER_SPLINE_CTLPNT, False, LSpline.Knots)
        else
          LPnts := UdBSpline2D.GetQuadraticSPlineSamplePoints(LSpline.CtlPnts, Length(LSpline.CtlPnts) * SEGMENTS_PER_SPLINE_CTLPNT, False, LSpline.Knots);

        Result := Segarc2DArray( LPnts );
      end;
    end;

  end;
  
  procedure _CalcLoops();
  var
    I, J, L: Integer;
    LCurves: TCurve2DArray;
  begin
    L := 0;
    FLoops := nil;

    for I := 0 to Length(FPolyCurves) - 1 do
    begin
      LCurves := FPolyCurves[I];

      for J := 0 to Length(LCurves) - 1 do
      begin
        SetLength(FLoops, L+1);
        FLoops[L] := _GetSegarcs(LCurves[J]);

        Inc(L);
      end;
    end;
  end;

var
  LRect: TRect2D;
  LIsSolid: Boolean;
begin
  Result := False;
  if System.Length(FPolyCurves) <= 0 then Exit;
//  if not Assigned(Self.HatchPatterns) then Exit;

  LIsSolid :=  (UpperCase(FPatternName) = 'SOLID') or
               not Assigned(FHatchPattern) or
               (Assigned(FHatchPattern) and FHatchPattern.IsSolid());

  _CalcLoops();

  case FStyle of
    hsNormal: FEvedLoops := FLoops;
    hsOuter : FEvedLoops := FGetOuterLoops(FLoops);
    hsIgnore: FEvedLoops := FGetIgnoreLoops(FLoops);
  end;

  System.SetLength(FSegments, 0);

  if not LIsSolid and Assigned(FHatchPattern) then
    FSegments := FHatchPattern.PatternLines.CalcHatchSegments(FEvedLoops, FHatchScale, FHatchAngle);


  //------------------------------------
  LRect := FBoundsRect;
  FBoundsRect := GetBoundsRect();

  if IsEqual(FBoundsRect.P1, Point2D(0,0)) and IsEqual(FBoundsRect.P2, Point2D(0,0)) then
    LRect := MergeRect(LRect, FBoundsRect);

  Result := Self.Refresh(LRect);
end;




//-----------------------------------------------------------------------------------------

function TUdHatch.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;

  case AGripPnt.Mode of
    gmCenter:
      begin
        FCenteGriping := True;
        try
          Result := Self.Move(FGripCenter, AGripPnt.Point);
        finally
          FCenteGriping := False;
        end;
      end;
    gmPoint : ;
  end;
end;

function TUdHatch.Pick(APoint: TPoint2D): Boolean;
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

  if Self.IsSolid then
  begin
    for I := 0 to System.Length(FEvedLoops) - 1 do
    begin
      Result := UdGeo2D.IsPntInSegarcs(APoint, FEvedLoops[I]);
      if Result then Break;
    end;
  end
  else begin
    for I := 0 to System.Length(FSegments) - 1 do
    begin
      Result := UdGeo2D.IsPntOnSegment(APoint, FSegments[I], E);
      if Result then Break;
    end;
  end;
end;

function TUdHatch.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.Inclusion(FBoundsRect, ARect) = irOvered;

  if not Result and ACrossingMode then
  begin
    for I := 0 to System.Length(FEvedLoops) - 1 do
    begin
      Result := UdGeo2D.IsIntersect(ARect, FEvedLoops[I]);
      if Result then Break;
    end;
  end;
end;


function TUdHatch.Move(Dx, Dy: Float): Boolean;
var
  I, J: Integer;
  LCurves: TCurve2DArray;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>


  Self.RaiseBeforeModifyObject('');

  for I := 0 to System.Length(FLoops) - 1 do
    FLoops[I] := UdGeo2D.Translate(Dx, Dy, FLoops[I]);

  for I := 0 to System.Length(FPolyCurves) - 1 do
  begin
    LCurves := FPolyCurves[I];
    for J := 0 to System.Length(LCurves) - 1 do
    begin
      case LCurves[J].Kind of
        ckPolyline: PVertexes2D(LCurves[J].Data)^ := UdGeo2D.Translate(Dx, Dy, PVertexes2D(LCurves[J].Data)^);
        ckLine    : PSegment2D(LCurves[J].Data)^  := UdGeo2D.Translate(Dx, Dy, PSegment2D(LCurves[J].Data)^);
        ckArc     : PArc2D(LCurves[J].Data)^      := UdGeo2D.Translate(Dx, Dy, PArc2D(LCurves[J].Data)^);
        ckEllipse : PEllipse2D(LCurves[J].Data)^  := UdGeo2D.Translate(Dx, Dy, PEllipse2D(LCurves[J].Data)^);
        ckSpline  : PSpline2D(LCurves[J].Data)^.CtlPnts  := UdGeo2D.Translate(Dx, Dy, PSpline2D(LCurves[J].Data)^.CtlPnts);
      end;
    end; 
  end;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdHatch.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  I: Integer;
  P1, P2: TPoint2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  P1 := Point2D(0, 0);
  P2 := ShiftPoint(P1, FHatchAngle, 10);

  P1 := UdGeo2D.Mirror(Line2D(APnt1, APnt2), P1);
  P2 := UdGeo2D.Mirror(Line2D(APnt1, APnt2), P2);

  FHatchAngle := GetAngle(P1, P2);

  for I := 0 to System.Length(FLoops) - 1 do
    FLoops[I] := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FLoops[I]);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdHatch.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FHatchAngle := FHatchAngle + ARota;

  for I := 0 to System.Length(FLoops) - 1 do
    FLoops[I] := UdGeo2D.Rotate(ABase, ARota, FLoops[I]);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdHatch.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>


  Self.RaiseBeforeModifyObject('');

  FHatchScale := FHatchScale * AFactor;

  for I := 0 to System.Length(FLoops) - 1 do
    FLoops[I] := UdGeo2D.Scale(ABase, AFactor, FLoops[I]);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdHatch.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;
//  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>
//
//  if not AForce then
//  begin
//    if not Self.IsVisible or Self.IsLock() then Exit;
//    if not AOther.IsVisible or AOther.IsLock() then Exit;
//  end;

//  Result := UdUtils.EntitiesIntersection(Self.GetXData(), AOther);
end;





function TUdHatch.Explode: TUdObjectArray;

  procedure _InitEntity(AEntity: TUdEntity);
  begin
    AEntity.Layer := FLayer;

    AEntity.Color.Assign(FColor);
    AEntity.LineType.Assign(FLineType);
    AEntity.LineWeight := FLineWeight;
  end;

var
  I: Integer;
begin
  System.SetLength(Result, System.Length(FSegments));

  for I := 0 to System.Length(FSegments) - 1 do
  begin
    Result[I] := TUdLine.Create({Self.Document, False});

    TUdEntity(Result[I]).BeginUpdate();
    try
      _InitEntity(TUdEntity(Result[I]));
      TUdLine(Result[I]).XData := FSegments[I];
    finally
      TUdEntity(Result[I]).EndUpdate();
    end;
  end;
end;


function TUdHatch.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;

  procedure _InitEntity(AEntity: TUdEntity);
  begin
    AEntity.Layer := FLayer;

    AEntity.Color.Assign(FColor);
    AEntity.LineType.Assign(FLineType);
    AEntity.LineWeight := FLineWeight;
  end;

var
  I: Integer;
begin
  System.SetLength(Result, System.Length(FSegments));

  for I := 0 to System.Length(FSegments) - 1 do
  begin
    Result[I] := TUdLine.Create({Self.Document, False});

    Result[I].BeginUpdate();
    try
      _InitEntity(Result[I]);
      TUdLine(Result[I]).XData := UdGeo2D.Scale(ABase, XFactor, YFactor, FSegments[I]);
    finally
      Result[I].EndUpdate();
    end;      
  end;
end;




//-----------------------------------------------------------------------------------------

procedure TUdHatch.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  inherited;

  IntToStream(AStream, Ord(FStyle));
  IntToStream(AStream, Ord(FPatternType));
  StrToStream(AStream, FPatternName);

  FloatToStream(AStream, FHatchScale);
  FloatToStream(AStream, FHatchAngle);

  IntToStream(AStream, System.Length(FPolyCurves));
  for I := 0 to System.Length(FPolyCurves) - 1 do
    CurvesToStream(AStream, FPolyCurves[I]);

  IntToStream(AStream, System.Length(FLoops));
  for I := 0 to System.Length(FLoops) - 1 do
    SegarcsToStream(AStream, FLoops[I]);

  IntToStream(AStream, System.Length(FEvedLoops));
  for I := 0 to System.Length(FEvedLoops) - 1 do
    SegarcsToStream(AStream, FEvedLoops[I]);

  SegmentsToStream(AStream, FSegments);
end;

procedure TUdHatch.LoadFromStream(AStream: TStream);
var
  I, L: Integer;
begin
  inherited;

  FStyle       := TUdHatchStyle(IntFromStream(AStream));
  FPatternType := TUdHatchPatternType(IntFromStream(AStream));
  FPatternName := StrFromStream(AStream);

  FHatchScale  := FloatFromStream(AStream);
  FHatchAngle  := FloatFromStream(AStream);

  L := IntFromStream(AStream);
  System.SetLength(FPolyCurves, L);
  for I := 0 to System.Length(FPolyCurves) - 1 do
    FPolyCurves[I] := CurvesFromStream(AStream);

  L := IntFromStream(AStream);
  System.SetLength(FLoops, L);
  for I := 0 to System.Length(FLoops) - 1 do
    FLoops[I] := SegarcsFromStream(AStream);

  L := IntFromStream(AStream);
  System.SetLength(FEvedLoops, L);
  for I := 0 to System.Length(FEvedLoops) - 1 do
    FEvedLoops[I] := SegarcsFromStream(AStream);

  FSegments := SegmentsFromStream(AStream);

  FBoundsRect := GetBoundsRect();
end;




procedure TUdHatch.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I: Integer;
  LXmlNode: TUdXmlNode;
  LObjectNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Style']       := IntToStr(Ord(FStyle));
  LXmlNode.Prop['PatternType'] := IntToStr(Ord(FPatternType));
  LXmlNode.Prop['PatternName'] := FPatternName;

  LXmlNode.Prop['HatchScale']  := FloatToStr(FHatchScale);
  LXmlNode.Prop['HatchAngle']  := FloatToStr(FHatchAngle);


  if Assigned(FHatchPattern) then
  begin
    LObjectNode := LXmlNode.Add();
    FHatchPattern.SaveToXml(LObjectNode, 'HatchPattern');
  end;

  if System.Length(FPolyCurves) > 0 then
  begin
    LObjectNode := LXmlNode.Add();
    LObjectNode.Name := 'PolyCurves';

    LObjectNode.Prop['Count'] := IntToStr(System.Length(FPolyCurves));
    for I := 0 to System.Length(FPolyCurves) - 1 do
    begin
      LObjectNode.Prop['Curves' + IntToStr(I)] := ArrayToStr(FPolyCurves[I]);
    end;
  end;

  if System.Length(FLoops) > 0 then
  begin
    LObjectNode := LXmlNode.Add();
    LObjectNode.Name := 'Loops';

    LObjectNode.Prop['Count'] := IntToStr(System.Length(FLoops));
    for I := 0 to System.Length(FLoops) - 1 do
      LObjectNode.Prop['Loop' + IntToStr(I)] := ArrayToStr(FLoops[I]);
  end;

  if System.Length(FEvedLoops) > 0 then
  begin
    LObjectNode := LXmlNode.Add();
    LObjectNode.Name := 'EvedLoops';

    LObjectNode.Prop['Count'] := IntToStr(System.Length(FEvedLoops));
    for I := 0 to System.Length(FEvedLoops) - 1 do
      LObjectNode.Prop['Loop' + IntToStr(I)] := ArrayToStr(FEvedLoops[I]);
  end;

  if System.Length(FSegments) > 0 then
  begin
    with LXmlNode.Add() do
    begin
      Name := 'Segments';
      Prop['Value'] := ArrayToStr(FSegments);
    end;
  end;
end;

procedure TUdHatch.LoadFromXml(AXmlNode: TObject);
var
  I, L: Integer;
  LXmlNode: TUdXmlNode;
  LObjectNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  FLoops := nil;
  FEvedLoops := nil;
  FSegments := nil;

  LXmlNode := TUdXmlNode(AXmlNode);

  FStyle       := TUdHatchStyle(StrToIntDef(LXmlNode.Prop['Style'], 0));
  FPatternType := TUdHatchPatternType(StrToIntDef(LXmlNode.Prop['PatternType'], 0));
  FPatternName := LXmlNode.Prop['PatternName'];

  FHatchScale  := StrToFloatDef(LXmlNode.Prop['HatchScale'], 0.0);
  FHatchAngle  := StrToFloatDef(LXmlNode.Prop['HatchAngle'], 0.0);

  if Assigned(FHatchPattern) then FHatchPattern.Free;
  FHatchPattern := nil;

  LObjectNode := LXmlNode.FindItem('HatchPattern');
  if Assigned(LObjectNode) then
  begin
    FHatchPattern := TUdHatchPattern.Create();
    FHatchPattern.LoadFromXml(LObjectNode);
  end;


  LObjectNode := LXmlNode.FindItem('PolyCurves');
  if Assigned(LObjectNode) then
  begin
    L := StrToIntDef(LObjectNode.Prop['Count'], 0);
    System.SetLength(FPolyCurves, L);
    for I := 0 to System.Length(FPolyCurves) - 1 do
      StrToArray(LObjectNode.Prop['Curves' + IntToStr(I)], FPolyCurves[I]);
  end;

  LObjectNode := LXmlNode.FindItem('Loops');
  if Assigned(LObjectNode) then
  begin
    L := StrToIntDef(LObjectNode.Prop['Count'], 0);
    System.SetLength(FLoops, L);
    for I := 0 to System.Length(FLoops) - 1 do
      StrToArray(LObjectNode.Prop['Loop' + IntToStr(I)], FLoops[I]);
  end;

  LObjectNode := LXmlNode.FindItem('EvedLoops');
  if Assigned(LObjectNode) then
  begin
    L := StrToIntDef(LObjectNode.Prop['Count'], 0);
    System.SetLength(FEvedLoops, L);
    for I := 0 to System.Length(FEvedLoops) - 1 do
      StrToArray(LObjectNode.Prop['Loop' + IntToStr(I)], FEvedLoops[I]);
  end;

  LObjectNode := LXmlNode.FindItem('Segments');
  if Assigned(LObjectNode) then
    StrToArray(LObjectNode.Prop['Value'], FSegments);

  FBoundsRect := GetBoundsRect();
end;



end.