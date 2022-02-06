{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdText;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics, Types,
  UdConsts, UdTypes, UdGTypes, UdLineWeight,
  UdObject, UdEntity, UdAxes, UdColor, UdTextStyle;

const
  TEXT_BOUND_OFFSET_FACTOR = 0.2;

  TEXT_KIND_SINGLE_LINE = 1;
  TEXT_KIND_MULT_LINE   = 2;


type

  //-----------------------------------------------------
  TUdText = class(TUdEntity)
  private
    FContents: string;
    FPosition: TPoint2D;

    FHeight: Float;
    FWidthFactor: Float;
    FLineSpaceFactor: Float;
    FRotation: Float;

    FAlignment: TUdTextAlign;
    FBackward: Boolean;
    FUpsidedown: Boolean;

    FTextStyle: TUdTextStyle;
    FIsShxFont: Boolean;

    FFontPolys: TPoint2DArrays;
    FPolysCounts: array of TIntegerDynArray;

    FTextBound: TPoint2DArray;
    FTextBoundEx: TPoint2DArray;
    FTextWidth, FTextHeight: Float;

    FDrawFrame: Boolean;
    FFillColor: TUdColor;

    FKindsFlag: Cardinal;

    //for Attdef Attrib
    FTag: string;
//    FIsAttr: Boolean;
//    FValue: string;

  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    procedure SetContents(const AValue: string);
    procedure SetPosition(const AValue: TPoint2D);

    function GetPositionValue(AIndex: Integer): Float;
    procedure SetPositionValue(AIndex: Integer; const AValue: Float);


    procedure SetHeight(const AValue: Float);
    procedure SetWidthFactor(const AValue: Float);
    procedure SetLineSpaceFactor(const AValue: Float);
    procedure SetRotation(const AValue: Float);

    procedure SetAlignment(const AValue: TUdTextAlign);
    procedure SetBackward(const AValue: Boolean);
    procedure SetUpsidedown(const AValue: Boolean);

    procedure SetDrawFrame(const AValue: Boolean);
    procedure SetFillColor(const AValue: TUdColor);

    procedure SetTag(const AValue: string);


    procedure SetTextStyle(const AValue: TUdTextStyle);
    function GetTextStyleRec: TUdTextStyleRec;
//    procedure SetTextStyleRec(const AValue: TUdTextStyleRec);


    function FDrawText(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; ALwFactor: Float = 1.0): Boolean;

    function DoUpdate(AAxes: TUdAxes): Boolean; override;
    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    procedure OnFillColorChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
    procedure OnFillColorChanged(Sender: TObject; APropName: string);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetGripPoints(): TUdGripPointArray; override;
    function GetOSnapPoints(): TUdOSnapPointArray; override;

    {operation...}
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;

    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;

    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;

    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property TextWidth: Float read FTextWidth;
    property TextHeight: Float read FTextHeight;

    {
     1       2
     *-------*
     |       |
     *-------*
     0       3
    }    
    property TextBound: TPoint2DArray{[0..3]} read FTextBound;


    property Position: TPoint2D read FPosition write SetPosition;
    property KindsFlag: Cardinal read FKindsFlag write FKindsFlag;

  published
    property Contents: string read FContents write SetContents;
    property TextStyle: TUdTextStyle read FTextStyle  write SetTextStyle;

    property PositionX: Float index 0 read GetPositionValue write SetPositionValue;
    property PositionY: Float index 1 read GetPositionValue write SetPositionValue;

    property Height: Float read FHeight write SetHeight;
    property WidthFactor: Float read FWidthFactor write SetWidthFactor;
    property LineSpaceFactor: Float read FLineSpaceFactor write SetLineSpaceFactor;
    property Rotation: Float read FRotation write SetRotation;

    property Alignment: TUdTextAlign read FAlignment write SetAlignment;
    property Backward: Boolean read FBackward write SetBackward;
    property Upsidedown: Boolean read FUpsidedown write SetUpsidedown;

    property DrawFrame: Boolean read FDrawFrame write SetDrawFrame;
    property FillColor: TUdColor read FFillColor write SetFillColor;

    property Tag: string read FTag write SetTag;
  end;

implementation

uses
  SysUtils,
  UdLayout, UdMath, UdGeo2D, UdDrawUtil, UdUtils, UdStrConverter,
  UdHatchBitmaps, UdTTF, UdShx, UdStreams, UdXml {$IFNDEF D2010}, UdCanvas{$ENDIF};


var
  GDefTTFFont: TUdTTF;



//==================================================================================================
{ TUdText }

constructor TUdText.Create();
begin
  inherited;

  FContents := '';
  FTextStyle := nil;

  FHeight := 5;
  FWidthFactor := 1.0;
  FLineSpaceFactor := 1.0;
  FRotation := 0.0;
  FPosition := Point2D(0, 0);

  FAlignment := taBottomLeft;
  FBackward := False;
  FUpsidedown := False;

  FIsShxFont := True;

  FFontPolys := nil;
  FPolysCounts := nil;

  FDrawFrame := False;

  FFillColor := TUdColor.Create({Self.Document, False});
  FFillColor.Owner := Self;
  FFillColor.ColorType := ctNone;
  FFillColor.OnChanged  := OnFillColorChanged;
  FFillColor.OnChanging := OnFillColorChanging;

  FKindsFlag := 0;

  FTextBound   := nil;
  FTextBoundEx := nil;

  FTag := '';
end;

destructor TUdText.Destroy;
begin
  if Assigned(FFillColor) then FFillColor.Free;
  FFillColor := nil;
  
  FFontPolys := nil;
  FPolysCounts := nil;
  inherited;
end;

function TUdText.GetTypeID: Integer;
begin
  Result := ID_TEXT;
end;


procedure TUdText.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;
  
  if Assigned(FFillColor) then
    FFillColor.SetDocument(Self.Document, False);
end;


//-----------------------------------------------------------------------------------------

procedure TUdText.SetContents(const AValue: string);
begin
  if (FContents <> AValue) and Self.RaiseBeforeModifyObject('Contents') then
  begin
    FContents := AValue;
   	Self.Update();
    Self.RaiseAfterModifyObject('Contents');
  end;
end;



procedure TUdText.SetPosition(const AValue: TPoint2D);
begin
  if NotEqual(FPosition, AValue) and Self.RaiseBeforeModifyObject('Position') then
  begin
    FPosition := AValue;
   	Self.Update();
    Self.RaiseAfterModifyObject('Position');
  end;
end;




function TUdText.GetPositionValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FPosition.X;
    1: Result := FPosition.Y;
  end;
end;

procedure TUdText.SetPositionValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FPosition;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FPosition) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('PositionX');
    1: Self.RaiseBeforeModifyObject('PositionY');
  end;

  FPosition := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('PositionX');
    1: Self.RaiseAfterModifyObject('PositionY');
  end;
end;



procedure TUdText.SetHeight(const AValue: Float);
begin
  if (AValue > 0.0) and NotEqual(FHeight, AValue) and Self.RaiseBeforeModifyObject('Height') then
  begin
    FHeight := AValue;
	  Self.Update();
    Self.RaiseAfterModifyObject('Height');
  end;
end;

procedure TUdText.SetWidthFactor(const AValue: Float);
begin
  if (AValue > 0.0) and NotEqual(FWidthFactor, AValue) and Self.RaiseBeforeModifyObject('WidthFactor') then
  begin
    FWidthFactor := AValue;
	  Self.Update();
    Self.RaiseAfterModifyObject('WidthFactor');
  end;
end;

procedure TUdText.SetLineSpaceFactor(const AValue: Float);
begin
  if (AValue >= 0.25) and NotEqual(FLineSpaceFactor, AValue) and Self.RaiseBeforeModifyObject('LineSpaceFactor') then
  begin
    FLineSpaceFactor := AValue;
	  Self.Update();
    Self.RaiseAfterModifyObject('LineSpaceFactor');
  end;
end;

procedure TUdText.SetRotation(const AValue: Float);
begin
  if NotEqual(FRotation, AValue) and Self.RaiseBeforeModifyObject('Rotation') then
  begin
    FRotation := AValue;
 	  Self.Update();
    Self.RaiseAfterModifyObject('Rotation');
  end;
end;



procedure TUdText.SetAlignment(const AValue: TUdTextAlign);
begin
  if (FAlignment <> AValue) and Self.RaiseBeforeModifyObject('Alignment') then
  begin
    FAlignment := AValue;
	  Self.Update();
    Self.RaiseAfterModifyObject('Alignment');
  end;
end;

procedure TUdText.SetBackward(const AValue: Boolean);
begin
  if (FBackward <> AValue) and Self.RaiseBeforeModifyObject('Backward') then
  begin
    FBackward := AValue;
	  Self.Update();
    Self.RaiseAfterModifyObject('Backward');
  end;
end;


procedure TUdText.SetUpsidedown(const AValue: Boolean);
begin
  if (FUpsidedown <> AValue) and Self.RaiseBeforeModifyObject('Upsidedown') then
  begin
    FUpsidedown := AValue;
	  Self.Update();
    Self.RaiseAfterModifyObject('Upsidedown');
  end;
end;



procedure TUdText.SetDrawFrame(const AValue: Boolean);
begin
  if (FDrawFrame <> AValue) and Self.RaiseBeforeModifyObject('DrawFrame') then
  begin
    FDrawFrame := AValue;
    Self.Refresh();
    Self.RaiseAfterModifyObject('DrawFrame');
  end;
end;

procedure TUdText.SetFillColor(const AValue: TUdColor);
begin
  if (FFillColor <> AValue) and Self.RaiseBeforeModifyObject('FillColor') then
  begin
    FFillColor.Assign(AValue);

    Self.Refresh();
    Self.RaiseAfterModifyObject('FillColor');
  end;
end;



procedure TUdText.SetTag(const AValue: string);
begin
  if (FTag <> AValue) and Self.RaiseBeforeModifyObject('Tag') then
  begin
    FTag := AValue;
    Self.RaiseAfterModifyObject('Tag');
  end;
end;


//procedure TUdText.SetIsShxFont(const AValue: Boolean);
//begin
//  if FIsShxFont <> AValue then
//  begin
//    FIsShxFont := AValue;
//	  Self.Update();
//  end;
//end;



procedure TUdText.SetTextStyle(const AValue: TUdTextStyle);
begin
  if (FTextStyle <> AValue) and Self.RaiseBeforeModifyObject('TextStyle') then
  begin
    if Assigned(AValue) then
    begin
      if FTextStyle = nil then
      begin
        FHeight := AValue.Height;
        FWidthFactor := AValue.WidthFactor;
      end;
      
      FBackward := AValue.Backward;
      FUpsidedown := AValue.Upsidedown;
    end;

    FTextStyle := AValue;

    Self.Update();
    Self.RaiseAfterModifyObject('TextStyle');
  end;
end;


function TUdText.GetTextStyleRec: TUdTextStyleRec;
begin
  Result.WidthFactor     := FWidthFactor;
  Result.LineSpaceFactor := FLineSpaceFactor * UdConsts.LINE_SPACE_FACTOR;
  Result.Rotation        := FRotation   ;
  Result.Align           := FAlignment  ;
  Result.Backward        := FBackward   ;
  Result.Upsidedown      := FUpsidedown ;
end;



//procedure TUdText.SetTextStyleRec(const AValue: TUdTextStyleRec);
//begin
//  FWidthFactor := AValue.WidthFactor;
//  FRotation    := AValue.Rotation   ;
//  FAlignment       := AValue.Align      ;
//  FBackward    := AValue.Backward   ;
//  FUpsidedown  := AValue.Upsidedown ;
//
//  Self.Update();
//end;






procedure TUdText.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdText) then Exit;  //========>>>

  Self.FContents := TUdText(AValue).FContents;
  Self.FPosition := TUdText(AValue).FPosition;
  Self.FTextStyle    := TUdText(AValue).FTextStyle;

  Self.FHeight       := TUdText(AValue).FHeight;
  Self.FWidthFactor  := TUdText(AValue).FWidthFactor;
  Self.FLineSpaceFactor := TUdText(AValue).FLineSpaceFactor;
  Self.FRotation     := TUdText(AValue).FRotation;

  Self.FAlignment  := TUdText(AValue).FAlignment;
  Self.FBackward   := TUdText(AValue).FBackward;
  Self.FUpsidedown := TUdText(AValue).FUpsidedown;


  Self.FDrawFrame  := TUdText(AValue).FDrawFrame;
  Self.FFillColor.Assign(TUdText(AValue).FFillColor);

  Self.FKindsFlag := TUdText(AValue).FKindsFlag;
//  Self.FIsShxFont := TUdText(AValue).FIsShxFont;

  FTag := TUdText(AValue).FTag;

  Self.Update();
end;


procedure TUdText.OnFillColorChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
begin
  AAllow := Self.RaiseBeforeModifyObject('FillColor');
end;

procedure TUdText.OnFillColorChanged(Sender: TObject; APropName: string);
begin
  Self.Refresh();
  Self.RaiseAfterModifyObject('FillColor');
end;


//-----------------------------------------------------------------------------------------

function TUdText.FDrawText(ACanvas: TCanvas; AAxes: TUdAxes; AColor: TColor; ALwFactor: Float = 1.0): Boolean;
var
  V: Float;
  LX, LY: Integer;
  I, J, L: Integer;
  LPnts: TPoint2DArray;
  LBkColor: TColor;
  LLayout: TUdLayout;  
  LPolysCount: TIntegerDynArray;
  LPoints: array of TPoint;
  {$IFNDEF D2010}LExFunc: Boolean; {$ENDIF}  
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>   or not Assigned(AColor)

  {$IFNDEF D2010}LExFunc := ACanvas.InheritsFrom(TUdCanvas); {$ENDIF}
    
  ACanvas.Pen.Mode := pmCopy;
  ACanvas.Pen.Width := 1;

  if FIsShxFont then
  begin
    ACanvas.Brush.Style := bsClear;

    if Self.Selected then
    begin
      ACanvas.Pen.Style := psDot;
      ACanvas.Pen.Color := SELECTED_COLOR;
    end
    else begin
      ACanvas.Pen.Style := psSolid;
      ACanvas.Pen.Color := AColor;

      LLayout := TUdLayout(Self.Layout);
      if Assigned(LLayout) and LLayout.LwtDisp then      
        ACanvas.Pen.Width := GetLineWeightWidth(Self.ActualLineWeight(), ALwFactor);
    end;
  end
  else begin
    ACanvas.Pen.Style := psSolid;

    if Self.Selected then
    begin
      ACanvas.Pen.Color := SELECTED_COLOR;
      LBkColor := Self.GetLayoutBackColor();
      ACanvas.Brush.Bitmap := HatchBitmapsRes().GetSelPenBitmap(LBkColor, SELECTED_COLOR);
    end
    else begin
      ACanvas.Pen.Color := AColor;
      ACanvas.Brush.Color := AColor;
      ACanvas.Brush.Style := bsSolid;
    end;

    SetPolyFillMode(ACanvas.Handle, WINDING);
  end;



  for I := 0 to System.Length(FFontPolys) - 1 do
  begin
    LPnts := FFontPolys[I];

    L := System.Length(LPnts);
    if L <= 1 then Continue;

    if FIsShxFont then
    begin
    {$IFDEF D2010}
      ACanvas.MoveTo(AAxes.XPixel(LPnts[0].X), AAxes.YPixel(LPnts[0].Y));
    {$ELSE}
      if LExFunc then
        TUdCanvas(ACanvas).MoveToEx(AAxes.XPixel(LPnts[0].X), AAxes.YPixel(LPnts[0].Y))
      else
        ACanvas.MoveTo(AAxes.XPixel(LPnts[0].X), AAxes.YPixel(LPnts[0].Y));
    {$ENDIF}
      
      for J := 1 to L - 1 do
      begin
      {$IFDEF D2010}
        ACanvas.LineTo(AAxes.XPixel(LPnts[J].X), AAxes.YPixel(LPnts[J].Y));
      {$ELSE}
        if LExFunc then
          TUdCanvas(ACanvas).LineToEx(AAxes.XPixel(LPnts[J].X), AAxes.YPixel(LPnts[J].Y))
        else
          ACanvas.LineTo(AAxes.XPixel(LPnts[J].X), AAxes.YPixel(LPnts[J].Y));
      {$ENDIF}
      end;
    end
    else begin
      System.SetLength(LPoints, L);
      for J := 0 to L - 1 do
      begin
      //LPoints[J].X := AAxes.XPixel(LPnts[J].X);
      //LPoints[J].Y := AAxes.YPixel(LPnts[J].Y);

        with AAxes.XAxis do
        begin
          V := (LPnts[J].X - Min) * PixelPerValue;
          LX := Trunc(Pan + V) + AAxes.Margin;
        end;

        with AAxes.YAxis do
        begin
          V := (LPnts[J].Y - Min) * PixelPerValue;
          LY := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
        end;

        LPoints[J].X := LX;
        LPoints[J].Y := LY;
      end;

      LPolysCount := FPolysCounts[I];
      if (Length(LPolysCount) > 0) then
      begin
        Windows.PolyPolygon(ACanvas.Handle, LPoints[0], LPolysCount[0], System.Length(LPolysCount));
      end
      else begin
        ACanvas.Pen.Width := 2;

        {$IFDEF D2010}
          ACanvas.MoveTo(LPoints[0].X, LPoints[0].Y);
        {$ELSE}
          if LExFunc then
            TUdCanvas(ACanvas).MoveToEx(LPoints[0].X, LPoints[0].Y)
          else
            ACanvas.MoveTo(LPoints[0].X, LPoints[0].Y);
        {$ENDIF}

        for J := 1 to L - 1 do
        begin
        {$IFDEF D2010}
          ACanvas.LineTo(LPoints[J].X, LPoints[J].Y);
        {$ELSE}
          if LExFunc then
            TUdCanvas(ACanvas).LineToEx(LPoints[J].X, LPoints[J].Y)
          else
            ACanvas.LineTo(LPoints[J].X, LPoints[J].Y);
        {$ENDIF}
        end;
      end;
    end;
  end;

  Result := True;
end;

function TUdText.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>

  if (FFillColor.ColorType <> ctNone) or FDrawFrame then
  begin
    ACanvas.Pen.Width := 1;

    if FDrawFrame then
    begin
      ACanvas.Pen.Style := psSolid;
      ACanvas.Pen.Color := Self.ActualTrueColor(AFlag);
    end
    else begin
      ACanvas.Pen.Style := psClear;
    end;

    if (FFillColor.ColorType <> ctNone) then
    begin
      ACanvas.Brush.Style := bsSolid;
      ACanvas.Brush.Color := FFillColor.GetValueEx(AFlag);
    end
    else begin
      ACanvas.Brush.Style := bsClear;
    end;

    UdDrawUtil.DrawPolygon(ACanvas, AAxes, FTextBoundEx);
  end;

  FDrawText(ACanvas, AAxes, Self.ActualTrueColor(AFlag), ALwFactor);

  Result := True;
end;




//-----------------------------------------------------------------------------------------

function TUdText.DoUpdate(AAxes: TUdAxes): Boolean;
var
  I, L: Integer;
  LShx: TUdShx;
  LTTF: TUdTTF;
  LBound: TRect2D;
  LStyleObj: TUdTextStyle;
  LStyleRec: TUdTextStyleRec;
  LTtfPolys: TUdTTFPolygonArray;
begin
  Result := False;

  FFontPolys := nil;
  FPolysCounts := nil;

  FTextBound := nil;
  FTextBoundEx := nil;

  FTextWidth := 0;
  FTextHeight := 0;

  if FContents = '' then Exit;

  LBound := FBoundsRect;

  LStyleObj := FTextStyle;
  if not Assigned(LStyleObj) and Assigned(Self.TextStyles) then
    LStyleObj := Self.TextStyles.Standard;

  LShx := nil;
  LTTF := nil;
  if Assigned(LStyleObj) then
  begin
    if LStyleObj.FontKind = fkTTF then
    begin
      LTTF := LStyleObj.TTFFont;
      if not Assigned(LTTF) then LTTF := GDefTTFFont;
    end
    else begin
      LShx := LStyleObj.ShxFont;
      if not Assigned(LShx) then LTTF := GDefTTFFont;
    end;
  end
  else begin
    LTTF := GDefTTFFont;
  end;

  FIsShxFont := Assigned(LShx);

  LStyleRec := Self.GetTextStyleRec();

  if FIsShxFont then
  begin
    FFontPolys := LShx.GetTextPolys(FContents, FPosition, FHeight, LStyleRec, FTextWidth, FTextHeight, FTextBound);
  end
  else begin
    LTtfPolys := LTTF.GetTextPolys(FContents, FPosition, FHeight, LStyleRec, FTextWidth, FTextHeight, FTextBound);

    L := System.Length(LTtfPolys);
    System.SetLength(FFontPolys, L);
    System.SetLength(FPolysCounts, L);

    for I := 0 to L - 1 do
    begin
      FFontPolys[I] := LTtfPolys[I].Polys;
      FPolysCounts[I] := LTtfPolys[I].Counts;
    end;
  end;

  UdGeo2D.ClosePolygon(FTextBound);
  FTextBoundEx := UdGeo2D.OffsetPolygon(FTextBound, FTextHeight * TEXT_BOUND_OFFSET_FACTOR);

  FBoundsRect := RectHull(FTextBoundEx);

  LBound := MergeRect(LBound, FBoundsRect);
  Self.Refresh(LBound, AAxes);

  Result := True;
end;


function TUdText.GetGripPoints: TUdGripPointArray;
//var
//  LPnt: TPoint2D;
begin
  System.SetLength(Result, 1);
  Result[0] := MakeGripPoint(Self, gmPoint, 0, FPosition, 0.0);

//  System.SetLength(Result, 4);
//  Result[0] := MakeGripPoint(Self, gmPoint, 0,  FTextBound[0], 0.0);
//  Result[1] := MakeGripPoint(Self, gmPoint, 1,  FTextBound[1], 0.0);
//  Result[2] := MakeGripPoint(Self, gmPoint, 2,  FTextBound[2], 0.0);
//  Result[3] := MakeGripPoint(Self, gmPoint, 3,  FTextBound[3], 0.0);
end;

function TUdText.GetOSnapPoints: TUdOSnapPointArray;
begin
  System.SetLength(Result, 1);
  Result[0] := MakeOSnapPoint(Self, OSNP_END, FPosition, -1);

//  System.SetLength(Result, 4);
//  Result[0] := MakeOSnapPoint(Self, OSNP_END, FTextBound[0]);
//  Result[1] := MakeOSnapPoint(Self, OSNP_END, FTextBound[1]);
//  Result[2] := MakeOSnapPoint(Self, OSNP_END, FTextBound[2]);
//  Result[3] := MakeOSnapPoint(Self, OSNP_END, FTextBound[3]);
end;





//-----------------------------------------------------------------------------------------

function TUdText.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
//var
//  LDx, LDy: Float;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
//    LDx := 0;
//    LDy := 0;
//
//    case AGripPnt.Index of
//      0: begin LDx := AGripPnt.Point.X - FTextBound[0].X;  LDy := AGripPnt.Point.Y - FTextBound[0].Y; end;
//      1: begin LDx := AGripPnt.Point.X - FTextBound[1].X;  LDy := AGripPnt.Point.Y - FTextBound[1].Y; end;
//      2: begin LDx := AGripPnt.Point.X - FTextBound[2].X;  LDy := AGripPnt.Point.Y - FTextBound[2].Y; end;
//      3: begin LDx := AGripPnt.Point.X - FTextBound[3].X;  LDy := AGripPnt.Point.Y - FTextBound[3].Y; end;
//    end;
//
//    SetPosition( UdGeo2D.Translate(LDx, LDy, FPosition) );

    SetPosition( AGripPnt.Point );
    Result := True;
  end;
end;


function TUdText.Pick(APoint: TPoint2D): Boolean;
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

  if Assigned(FFillColor) and (FFillColor.ColorType <> ctNone) then
  begin
    Result := UdGeo2D.IsPntInPolygon(APoint, FTextBoundEx, E);
  end
  else begin
    if FDrawFrame then
      Result := UdGeo2D.IsPntOnPolygon(APoint, FTextBoundEx, E);
    if not Result then
    begin
      for I := 0 to System.Length(FFontPolys) - 1 do
      begin
        Result := UdGeo2D.IsPntOnPolygon(APoint, FFontPolys[I], E);
        if Result then Break;
      end;
    end;
  end;
end;

function TUdText.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.Inclusion(FBoundsRect, ARect) = irOvered;

  if not Result and ACrossingMode then
    Result := UdGeo2D.IsIntersect(ARect, FTextBoundEx);
end;


function TUdText.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPosition := UdGeo2D.Translate(Dx, Dy, FPosition);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdText.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  I: Integer;
  LAng: Float;
  LAxes: TUdAxes;
  LAlign: TUdTextAlign;
  LCenter: TPoint2D;
  LFound: Boolean;
  LRotSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>


  Self.RaiseBeforeModifyObject('');

  LAng := GetAngle(APnt1, APnt2);

  if FAlignment <> taMiddleCenter then
  begin
    LAxes := Self.EnsureAxes(nil);
    LAlign := FAlignment;

    DoUpdate(LAxes);
    LCenter := Centroid(FTextBound);
    LCenter := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LCenter);

    LRotSeg := Segment2D(FPosition, ShiftPoint(FPosition, FRotation, FHeight));
    LRotSeg := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LRotSeg);

    if ((LAng > 45) and (LAng < 135)) or ((LAng > 225) and (LAng < 315)) then
      FRotation := GetAngle(LRotSeg.P2, LRotSeg.P1)
    else
      FRotation := GetAngle(LRotSeg.P1, LRotSeg.P2);

    FPosition  := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FPosition);

    LFound := False;
    for I := Ord(taTopLeft) to Ord(taBottomRight) do
    begin
      if (TUdTextAlign(I) <> taMiddleCenter) and (TUdTextAlign(I) <> LAlign) then
      begin
        FAlignment := TUdTextAlign(I);
        DoUpdate(LAxes);

        if Distance(Centroid(FTextBound), LCenter) < (FHeight/4) then
        begin
          LFound := True;
          Break;
        end;
      end;
    end;

    if not LFound then FAlignment := LAlign;
  end
  else
  begin
    LRotSeg := Segment2D(FPosition, ShiftPoint(FPosition, FRotation, FHeight));
    LRotSeg := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LRotSeg);

    if ((LAng > 45) and (LAng < 135)) or ((LAng > 225) and (LAng < 315)) then
      FRotation := GetAngle(LRotSeg.P2, LRotSeg.P1)
    else
      FRotation := GetAngle(LRotSeg.P1, LRotSeg.P2);

    FPosition  := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FPosition);
  end;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdText.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPosition := UdGeo2D.Rotate(ABase, ARota, FPosition);
  FRotation := FixAngle(FRotation + ARota);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdText.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPosition := UdGeo2D.Scale(ABase, AFactor, AFactor, FPosition);
  FHeight := FHeight * AFactor;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdText.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  LEntity: TUdText;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LEntity := TUdText.Create({Self.Document, False});

  LEntity.BeginUpdate();  
  try
    LEntity.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      LEntity.FPosition    := UdGeo2D.Scale(ABase, XFactor, YFactor, FPosition);
      LEntity.FHeight      := Abs(FHeight * YFactor);
      LEntity.FWidthFactor := Abs(XFactor / YFactor);
    end;
  finally
    LEntity.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LEntity;
end;



//-----------------------------------------------------------------------------------------

procedure TUdText.SaveToStream(AStream: TStream);
var
  LStyleName: string;
begin
  inherited;

  StrToStream(AStream, FContents);

  LStyleName := '';
  if Assigned(FTextStyle) then LStyleName := FTextStyle.Name;
  StrToStream(AStream, LStyleName);

  FloatToStream(AStream, FPosition.X);
  FloatToStream(AStream, FPosition.Y);

  FloatToStream(AStream, FHeight);
  FloatToStream(AStream, FWidthFactor);
  FloatToStream(AStream, FLineSpaceFactor);
  FloatToStream(AStream, FRotation);

  IntToStream(AStream, Ord(FAlignment));
  BoolToStream(AStream, FBackward);
  BoolToStream(AStream, FUpsidedown);

  BoolToStream(AStream, FDrawFrame);
  BoolToStream(AStream, (FFillColor.ColorType <> ctNone));
  if (FFillColor.ColorType <> ctNone) then FFillColor.SaveToStream(AStream);

  CarToStream(AStream, FKindsFlag);

  StrToStream(AStream, FTag);
end;

procedure TUdText.LoadFromStream(AStream: TStream);
var
  LBool: Boolean;
  LStyleName: string;
begin
  inherited;

  FContents := StrFromStream(AStream);

  FTextStyle := nil;
  LStyleName := StrFromStream(AStream);
  if Assigned(Self.TextStyles) then
    FTextStyle := Self.TextStyles.GetItem(LStyleName);

  FPosition.X := FloatFromStream(AStream);
  FPosition.Y := FloatFromStream(AStream);

  FHeight := FloatFromStream(AStream);
  FWidthFactor := FloatFromStream(AStream);
  FLineSpaceFactor := FloatFromStream(AStream);
  FRotation  := FloatFromStream(AStream);

  FAlignment := TUdTextAlign(IntFromStream(AStream));
  FBackward  := BoolFromStream(AStream);
  FUpsidedown := BoolFromStream(AStream);

  FDrawFrame := BoolFromStream(AStream);
  LBool := BoolFromStream(AStream);
  if LBool then FFillColor.LoadFromStream(AStream) else FFillColor.ColorType := ctNone;

  FKindsFlag := CarFromStream(AStream);

  FTag  := StrFromStream(AStream);
  
  Self.Update();
end;





procedure TUdText.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Contents']  := FContents;

  if Assigned(FTextStyle) then LXmlNode.Prop['StyleName'] := FTextStyle.Name;

  LXmlNode.Prop['Position']        := Point2DToStr(FPosition);
  LXmlNode.Prop['Height']          := FloatToStr(FHeight);
  LXmlNode.Prop['WidthFactor']     := FloatToStr(FWidthFactor);
  LXmlNode.Prop['LineSpaceFactor'] := FloatToStr(FLineSpaceFactor);
  LXmlNode.Prop['Rotation']        := FloatToStr(FRotation);

  LXmlNode.Prop['Alignment']       := IntToStr(Ord(FAlignment));
  LXmlNode.Prop['Backward']        := BoolToStr(FBackward, True);
  LXmlNode.Prop['Upsidedown']      := BoolToStr(FUpsidedown, True);


  LXmlNode.Prop['Upsidedown']      := BoolToStr(FDrawFrame, True);
  if (FFillColor.ColorType <> ctNone) then FFillColor.SaveToXml(LXmlNode.Add(), 'FillColor');

  LXmlNode.Prop['KindsFlag']      := IntToStr(FKindsFlag);

  LXmlNode.Prop['Tag']  := FTag;
end;

procedure TUdText.LoadFromXml(AXmlNode: TObject);
var
  LStyleName: string;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FContents := LXmlNode.Prop['Contents'];

  FTextStyle := nil;
  LStyleName := LXmlNode.Prop['StyleName'];
  if Assigned(Self.TextStyles) then
    FTextStyle := Self.TextStyles.GetItem(LStyleName);

  FPosition        := StrToPoint2D(LXmlNode.Prop['Position']);
  FHeight          := StrToFloatDef(LXmlNode.Prop['Height'], 5);
  FWidthFactor     := StrToFloatDef(LXmlNode.Prop['WidthFactor'], 1.0);
  FLineSpaceFactor := StrToFloatDef(LXmlNode.Prop['LineSpaceFactor'], 1.0);
  FRotation        := StrToFloatDef(LXmlNode.Prop['Rotation'], 0.0);

  FAlignment  := TUdTextAlign(StrToIntDef(LXmlNode.Prop['Alignment'], 0));
  FBackward   := StrToBoolDef(LXmlNode.Prop['Backward']  , False);
  FUpsidedown := StrToBoolDef(LXmlNode.Prop['Upsidedown'], False);

  FDrawFrame := StrToBoolDef(LXmlNode.Prop['DrawFrame'], False);

  if LXmlNode.FindItem('FillColor') <> nil then
    FFillColor.LoadFromXml(LXmlNode.FindItem('FillColor'))
  else
    FFillColor.ColorType := ctNone;

  FKindsFlag := StrToIntDef(LXmlNode.Prop['KindsFlag'], 0);

  FTag := LXmlNode.Prop['Tag'];

  Self.Update();
end;








//==================================================================================================

function GetSysDefFontName(): string;
var
  LMetrics: TNonClientMetrics;
begin
  LMetrics.cbSize := SizeOf(TNonClientMetrics);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, SizeOf(TNonClientMetrics), @LMetrics, 0);
  Result := LMetrics.lfSmCaptionFont.lfFaceName;
end;

initialization
  GDefTTFFont := TUdTTF.Create;
  GDefTTFFont.Font.Name := GetSysDefFontName(); //'ËÎÌו';


finalization
  GDefTTFFont.Free;
  GDefTTFFont := nil;


end.