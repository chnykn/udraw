{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdFigure;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Types,
  UdTypes, UdConsts, UdObject, UdAxes, UdEntity,
  UdColor, UdLineType, UdLineWeight;


type

  TUdAfterDrawEvent  = procedure(Sender: TObject; ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; const ASamplePoints: TPoint2DArray) of object;

  //-----------------------------------------------------------------------------

  TUdFigure = class(TUdEntity)
  protected
    FPenWidth: Single;
    FFixedPenWidth: Boolean;

    FFilled: Boolean;
    FFillStyle: Integer;

    FHasBorder: Boolean;
    FBorderColor: TUdColor;

    FSamplePoints: TPoint2DArray;
    FSampleLtData: PLtData;

    FOnAfterDraw: TUdAfterDrawEvent;

  protected
    function GetPenWidth(): Single;
    procedure SetPenWidth(const AValue: Single);

    function CreateBorderColor(): TUdColor;

    function GetFilled(): Boolean; virtual;
    function GetFillStyle(): Integer;
    function GetHasBorder(): Boolean;
    function GetBorderColor(): TUdColor;

    procedure SetFilled(const AValue: Boolean); virtual;
    procedure SetFillStyle(const AValue: Integer);
    procedure SetHasBorder(const AValue: Boolean);
    procedure SetBorderColor(const AValue: TUdColor);

    procedure OnBorderColorChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
    procedure OnBorderColorChanged(Sender: TObject; APropName: string);

    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;
    
  protected
    function CanFilled(): Boolean; virtual;

    procedure UpdateBoundsRect(AAxes: TUdAxes); virtual;
    procedure UpdateSamplePoints(AAxes: TUdAxes); virtual;


    function FDrawPoints(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; ALineType: TUdLineType;
      const ALineWeight: TUdLineWeight; const ALwFactor: Float; const ASamplePoints: TPoint2DArray; const ASampleLtData: PLtData): Boolean;

    function FDrawPolygon(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; const AFillStyle: Integer;
      const ASamplePoints: TPoint2DArray): Boolean;

    function DoUpdate(AAxes: TUdAxes): Boolean; override;
    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

    procedure SetFixedPenWidth(const Value: Boolean);

  protected
    property Filled     : Boolean   read GetFilled      write SetFilled  ;
    property FillStyle  : Integer   read GetFillStyle   write SetFillStyle;

    property HasBorder  : Boolean   read GetHasBorder   write SetHasBorder;
    property BorderColor: TUdColor  read GetBorderColor write SetBorderColor;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property SamplePoints: TPoint2DArray read FSamplePoints;
    property OnAfterDraw: TUdAfterDrawEvent read FOnAfterDraw write FOnAfterDraw;

  published
    property PenWidth: Single read GetPenWidth write SetPenWidth;
    property FixedPenWidth: Boolean read FFixedPenWidth write SetFixedPenWidth;

  end;



implementation

uses
  {$IFDEF D2010UP} System.UITypes, {$ENDIF} SysUtils, UdLayout,
  UdMath, UdGeo2D, UdStreams, UdXml, UdDrawUtil, UdHatchBitmaps
  {$IFNDEF D2010}, UdCanvas{$ENDIF};




//==================================================================================================
{ TUdFigure }

constructor TUdFigure.Create();
begin
  inherited;

  FPenWidth := 0.0;
  FFixedPenWidth := True;

  FFilled := False;
  FFillStyle := 0;

  FHasBorder := False;
  FBorderColor := nil;

  FSamplePoints := nil;
  FSampleLtData := nil;

  FOnAfterDraw := nil;
end;

destructor TUdFigure.Destroy();
begin
  if Assigned(FBorderColor) then FBorderColor.Free;
  FBorderColor := nil;

  UdLineType.FreeLtData(FSampleLtData);
  FSampleLtData := nil;

  FSamplePoints := nil;

  inherited;
end;

procedure TUdFigure.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;
  if Assigned(FBorderColor) then
    FBorderColor.SetDocument(AValue, False);
end;





//------------------------------------------------------------------------------------------

//function TUdFigure.GetCenter(): PPoint2D;
//begin
//  Result := nil;
//end;


function TUdFigure.GetPenWidth: Single;
begin
  Result := FPenWidth;
end;

procedure TUdFigure.SetPenWidth(const AValue: Single);
begin
  if (FPenWidth <> AValue) and Self.RaiseBeforeModifyObject('PenWidth') then
  begin
    FPenWidth := AValue;
    if Self.FUsePenStyle then Self.Refresh();
    Self.RaiseAfterModifyObject('PenWidth');
  end;
end;


//------------------------------------------------------------------------------------------


function TUdFigure.GetFilled: Boolean;
begin
  Result := FFilled;
end;

procedure TUdFigure.SetFilled(const AValue: Boolean);
begin
  if (FFilled <> AValue) and Self.RaiseBeforeModifyObject('Filled') then
  begin
    FFilled := AValue;
    Self.RaiseAfterModifyObject('Filled');
    Self.Refresh();
  end;
end;


function TUdFigure.GetFillStyle: Integer;
begin
  Result := FFillStyle;
end;

procedure TUdFigure.SetFillStyle(const AValue: Integer);
begin
  if (FFillStyle <> AValue) and Self.RaiseBeforeModifyObject('FillStyle') then
  begin
    FFillStyle := AValue;
    Self.RaiseAfterModifyObject('FillStyle');
    Self.Refresh();
  end;
end;



procedure TUdFigure.SetFixedPenWidth(const Value: Boolean);
begin
  FFixedPenWidth := Value;
  Self.Refresh();
end;



function TUdFigure.GetHasBorder: Boolean;
begin
  Result := FHasBorder;
end;

procedure TUdFigure.SetHasBorder(const AValue: Boolean);
begin
  if (FHasBorder <> AValue) and Self.RaiseBeforeModifyObject('HasBorder') then
  begin
    FHasBorder := AValue;
    Self.RaiseAfterModifyObject('HasBorder');
    Self.Refresh();
  end;
end;



function TUdFigure.CreateBorderColor(): TUdColor;
begin
  Result := TUdColor.Create(Self.Document, False);
  Result.Owner := Self;
  Result.OnChanged := OnBorderColorChanged;
  Result.OnChanging := OnBorderColorChanging;
end;

function TUdFigure.GetBorderColor: TUdColor;
begin
  if not Assigned(FBorderColor) then
    FBorderColor := CreateBorderColor();
  Result := FBorderColor;
end;

procedure TUdFigure.SetBorderColor(const AValue: TUdColor);
begin
  if Self.RaiseBeforeModifyObject('BorderColor'{, Integer(AValue)}) then
  begin
    if Assigned(AValue) then
    begin
      if not Assigned(FBorderColor) then
        FBorderColor := CreateBorderColor();
      FBorderColor.Assign(AValue);
    end
    else begin
      if Assigned(FBorderColor) then FBorderColor.Free;
      FBorderColor := nil;
      Self.Refresh();
    end;
  end;
end;




procedure TUdFigure.OnBorderColorChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
begin
  AAllow := Self.RaiseBeforeModifyObject('BorderColor');
end;

procedure TUdFigure.OnBorderColorChanged(Sender: TObject; APropName: string);
begin
  Self.Refresh();
  Self.RaiseAfterModifyObject('BorderColor');
end;




//------------------------------------------------------------------------------------------

function TUdFigure.CanFilled: Boolean;
begin
  Result := False;
end;

procedure TUdFigure.UpdateBoundsRect(AAxes: TUdAxes);
begin
  //...
end;

procedure TUdFigure.UpdateSamplePoints(AAxes: TUdAxes);
begin
  //...
end;




//------------------------------------------------------------------------------------------


procedure TUdFigure.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdFigure) then Exit;

  FFilled := TUdFigure(AValue).FFilled;
  FFillStyle := TUdFigure(AValue).FFillStyle;;

  FHasBorder := TUdFigure(AValue).FHasBorder;

  if Assigned(TUdFigure(AValue).FBorderColor) then
  begin
    if not Assigned(FBorderColor) then
      FBorderColor := CreateBorderColor();

    FBorderColor.Assign(TUdFigure(AValue).FBorderColor);
  end
  else begin
    if Assigned(FBorderColor) then FBorderColor.Free;
    FBorderColor := nil;
  end;
end;





//------------------------------------------------------------------------------------------


function TUdFigure.FDrawPolygon(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; const AFillStyle: Integer; const ASamplePoints: TPoint2DArray): Boolean;
//var
//  LFgColor, LBkColor: TColor;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>  or not Assigned(AColor)

  if (AFillStyle = 1) {bsClear} then Exit; //=======>>>

  ACanvas.Pen.Mode := pmCopy;
  ACanvas.Pen.Style := psClear;

  ACanvas.Brush.Style := bsClear;

  //(bsSolid, bsClear, bsHorizontal, bsVertical, bsFDiagonal, bsBDiagonal, bsCross, bsDiagCross)

  if Self.Selected then
  begin
//    LFgColor := SELECTED_COLOR;
//    LBkColor := Self.GetLayoutBackColor();
//    ACanvas.Brush.Bitmap := HatchBitmapsRes().GetSelPenBitmap(LBkColor, LFgColor);

    ACanvas.Brush.Color := SELECTED_COLOR;
    ACanvas.Brush.Style := bsSolid;

    UdDrawUtil.DrawPolygon(ACanvas, AAxes, ASamplePoints);
  end
  else begin
    ACanvas.Brush.Color := AColor;
    if (AFillStyle < 8) then
      ACanvas.Brush.Style := TBrushStyle(AFillStyle)
    else
      ACanvas.Brush.Style := bsSolid;

    UdDrawUtil.DrawPolygon(ACanvas, AAxes, ASamplePoints);
  end;
end;

function TUdFigure.FDrawPoints(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; ALineType: TUdLineType;
      const ALineWeight: TUdLineWeight; const ALwFactor: Float; const ASamplePoints: TPoint2DArray; const ASampleLtData: PLtData): Boolean;
var
  LPenWidth: Integer;
  LSelDrawed: Boolean;
  LLayout: TUdLayout;
//  LHorz, LVert: Boolean;
//  LX1, LY1, LX2, LY2: Integer;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>    or not Assigned(AColor)

  if FUsePenStyle and (FPenStyle = psClear) then Exit; //=======>>>

  ACanvas.Pen.Mode := pmCopy;
  ACanvas.Brush.Style := bsClear;

  LPenWidth := 1;
  if NotEqual(FPenWidth, 0.0) and (FPenWidth > 0.0) then
  begin
    if FFixedPenWidth then
      LPenWidth := Trunc(FPenWidth)
    else
      LPenWidth := Trunc( AAxes.XPixelPerValue * FPenWidth)
  end
  else begin
    LLayout := TUdLayout(Self.Layout);
    if Assigned(LLayout) and LLayout.LwtDisp then
      LPenWidth := UdLineWeight.GetLineWeightWidth(ALineWeight, ALwFactor);
  end;

  LSelDrawed := False;

  if (LPenWidth > 1) and (FUsePenStyle) and (FPenStyle <> psSolid) then
  begin
//    if FPenStyle = psUserStyle then
//      ExtCreateUserStylePen(ACanvas.Pen, AColor.TrueColor, ALineType.Value, LPenWidth, True)
//    else
      ExtCreateStylePen(ACanvas.Pen, AColor, bsSolid, FPenStyle, LPenWidth, True)
  end
  else begin
    ACanvas.Pen.Width := LPenWidth;

    if Self.Selected then
      ACanvas.Pen.Color := SELECTED_COLOR
    else
      ACanvas.Pen.Color := AColor;

    if Self.Selected and (LPenWidth <= 1) then
    begin
      ACanvas.Pen.Style := psDot;
      LSelDrawed := True;
    end
    else begin
      if FUsePenStyle then
        ACanvas.Pen.Style := FPenStyle
      else
        ACanvas.Pen.Style := psSolid;
    end;
  end;

  if Assigned(ASampleLtData) then
    UdDrawUtil.DrawLtData(ACanvas, AAxes, ASampleLtData)
  else
    UdDrawUtil.DrawPoints(ACanvas, AAxes, ASamplePoints);

  if Selected and not LSelDrawed then
  begin
    ACanvas.Pen.Mode := pmMaskPenNot;
    ACanvas.Pen.Style := psDot;
    ACanvas.Pen.Width := 1;

    if Assigned(ASampleLtData) then
      UdDrawUtil.DrawLtData(ACanvas, AAxes, ASampleLtData)
    else
      UdDrawUtil.DrawPoints(ACanvas, AAxes, ASamplePoints);

    ACanvas.Pen.Mode := pmCopy;
  end;
end;


function TUdFigure.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
var
  LColor: TColor;
  LDrawPnts: Boolean;
  LLineType: TUdLineType;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>

  LColor := Self.ActualTrueColor(AFlag);
  LLineType := Self.ActualLineType();

  LDrawPnts := False;

  if Self.Finished and Self.CanFilled() and Self.FFilled then
  begin
    FDrawPolygon(ACanvas, AAxes, LColor, FFillStyle, FSamplePoints);

    if FHasBorder then
    begin
      LDrawPnts := True;
      if Assigned(FBorderColor) then LColor := FBorderColor.GetValueEx(AFlag);
    end;
  end
  else
    LDrawPnts := True;


  if LDrawPnts then
  begin
    if Assigned(FSampleLtData) and (LLineType.SegmentLength * Self.ActualLineTypeScale() * AAxes.XPixelPerValue > 2) then
      FDrawPoints(ACanvas, AAxes, LColor, LLineType, Self.ActualLineWeight(), ALwFactor, FSamplePoints, FSampleLtData)
    else
      FDrawPoints(ACanvas, AAxes, LColor, LLineType, Self.ActualLineWeight(), ALwFactor, FSamplePoints, nil);

    if Assigned(FOnAfterDraw) then
      FOnAfterDraw(Self, ACanvas, AAxes, LColor, FSamplePoints);
  end;

  Result := True;
end;


function TUdFigure.DoUpdate(AAxes: TUdAxes): Boolean;
var
  LBound: TRect2D;
  LLineType: TUdLineType;
begin
  Result := False;
  if not Assigned(AAxes) then Exit;

  LBound := FBoundsRect;

  UpdateSamplePoints(AAxes);
  UpdateBoundsRect(AAxes);

  UdLineType.FreeLtData(FSampleLtData);

  if Self.Finished then
  begin
    LLineType := Self.ActualLineType();

    if CanLinetype() then
      FSampleLtData := UdLineType.MakeLtData(FSamplePoints, LLineType.Value, Self.ActualLineTypeScale());
  end;

  LBound := MergeRect(LBound, FBoundsRect);
  Self.Refresh(LBound, AAxes);

  Result := True;
end;




//------------------------------------------------------------------------------------------

procedure TUdFigure.SaveToStream(AStream: TStream);
begin
  inherited;

  SingleToStream(AStream, FPenWidth);
  BoolToStream(AStream, FFixedPenWidth);

  BoolToStream(AStream, FFilled);
  IntToStream(AStream, FFillStyle);

  BoolToStream(AStream, FHasBorder);
  BoolToStream(AStream, Assigned(FBorderColor));
  if Assigned(FBorderColor) then FBorderColor.SaveToStream(AStream);
end;

procedure TUdFigure.LoadFromStream(AStream: TStream);
var
  LBool: Boolean;
begin
  inherited;

  FPenWidth := SingleFromStream(AStream);
  FFixedPenWidth := BoolFromStream(AStream);

  FFilled := BoolFromStream(AStream);
  FFillStyle := IntFromStream(AStream);

  FHasBorder := BoolFromStream(AStream);
  LBool := BoolFromStream(AStream);
  if LBool then
  begin
    if not Assigned(FBorderColor) then
      FBorderColor := CreateBorderColor();
    FBorderColor.LoadFromStream(AStream);
  end
  else begin
    if Assigned(FBorderColor) then FBorderColor.Free;
    FBorderColor := nil;
  end;
end;





procedure TUdFigure.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['PenWidth']  := FloatToStr(FPenWidth);

  LXmlNode.Prop['Filled']    := BoolToStr(FFilled, True);
  LXmlNode.Prop['FillStyle'] := IntToStr(FFillStyle);

  LXmlNode.Prop['HasBorder'] := BoolToStr(FHasBorder, True);
  if Assigned(FBorderColor) then
    FBorderColor.SaveToXml(LXmlNode.Add(), 'BorderColor');
end;


procedure TUdFigure.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FPenWidth  := StrToFloatDef(LXmlNode.Prop['PenWidth'], 0);

  FFilled    := StrToBoolDef(LXmlNode.Prop['Filled'], False);
  FFillStyle := StrToIntDef(LXmlNode.Prop['FillStyle'], 0);

  FHasBorder := StrToBoolDef(LXmlNode.Prop['HasBorder'], False);

  if LXmlNode.Find('BorderColor') >= 0 then
  begin
    if not Assigned(FBorderColor) then
      FBorderColor := CreateBorderColor();
    FBorderColor.LoadFromXml(LXmlNode.FindItem('BorderColor'));
  end
  else begin
    if Assigned(FBorderColor) then FBorderColor.Free;
    FBorderColor := nil;
  end;
end;

end.