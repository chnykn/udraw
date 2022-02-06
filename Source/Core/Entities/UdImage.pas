{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdImage;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics,

  UdTypes, UdAxes, UdObject, UdEntity, UdFigure;

type

  //-----------------------------------------------------
  TUdImage = class(TUdEntity)
  private
    FBitmap: TBitmap;
    FPosition: TPoint2D;  // FBitmap's left-bottom point

    FShowBorder: Boolean;
    FBorderColor: TColor;
    FBorderStyle: TPenStyle;

  protected
    function GetTypeID(): Integer; override;

    procedure SetShowBorder(const AValue: Boolean);
    procedure SetBorderColor(const AValue: TColor);
    procedure SetBorderStyle(const AValue: TPenStyle);

    procedure SetPosition(const AValue: TPoint2D);
    procedure DoBitmapLoaded(Sender: TObject);

    function DoUpdate(AAxes: TUdAxes): Boolean; override;
    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Bitmap: TBitmap read FBitmap write FBitmap;
    property Position: TPoint2D read FPosition write SetPosition; //×óÏÂ½Ç

    property ShowBorder: Boolean read FShowBorder write SetShowBorder;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property BorderStyle: TPenStyle read FBorderStyle write SetBorderStyle;
  end;

implementation

uses
  UdConsts, UdMath, UdGeo2D, UdXml, UdStreams, UdStrConverter, UdDrawUtil;

//==================================================================================================
{ TFBitmap }

type
  TFBitmap = class(TBitmap)
  private
    FOnLoaded: TNotifyEvent;
  public
    procedure LoadFromStream(Stream: TStream); override;
  end;

procedure TFBitmap.LoadFromStream(Stream: TStream);
begin
  inherited;
  if Assigned(FOnLoaded) then FOnLoaded(Self);
end;


//==================================================================================================
{ TUdImage }

constructor TUdImage.Create;
begin
  inherited;
  FBitmap := TFBitmap.Create();
  TFBitmap(FBitmap).FOnLoaded := DoBitmapLoaded;

  FShowBorder := True;
  FBorderColor := clNavy;
  FBorderStyle := psDot;
end;

destructor TUdImage.Destroy;
begin
  if Assigned(FBitmap) then FBitmap.Free;
  FBitmap := nil;

  inherited;
end;

function TUdImage.GetTypeID: Integer;
begin
  Result := ID_IMAGE;
end;

procedure TUdImage.DoBitmapLoaded(Sender: TObject);
begin
  Self.Update();
end;



//-----------------------------------------------------------------------------------------

procedure TUdImage.SetShowBorder(const AValue: Boolean);
begin
  if (FShowBorder <> AValue) and Self.RaiseBeforeModifyObject('ShowBorder') then
  begin
    FShowBorder := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ShowBorder');
  end;
end;

procedure TUdImage.SetBorderColor(const AValue: TColor);
begin
  if (FBorderColor <> AValue) and Self.RaiseBeforeModifyObject('BorderColor') then
  begin
    FBorderColor := AValue;
    if FShowBorder then Self.Update();
    Self.RaiseAfterModifyObject('BorderColor');
  end;
end;

procedure TUdImage.SetBorderStyle(const AValue: TPenStyle);
begin
  if (FBorderStyle <> AValue) and Self.RaiseBeforeModifyObject('BorderStyle') then
  begin
    FBorderStyle := AValue;
    if FShowBorder then Self.Update();
    Self.RaiseAfterModifyObject('BorderStyle');
  end;
end;





procedure TUdImage.SetPosition(const AValue: TPoint2D);
begin
  if NotEqual(FPosition, AValue) and Self.RaiseBeforeModifyObject('Position') then
  begin
    FPosition := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Position');
  end;
end;

function TUdImage.DoUpdate(AAxes: TUdAxes): Boolean;
begin
  Result := False;
  if not Assigned(AAxes) then Exit;
  if not Assigned(FBitmap) or (FBitmap.Width <= 0) or (FBitmap.Height <= 0) then Exit;

  FBoundsRect := UdGeo2D.Rect2D(FPosition,
                                Point2D(FPosition.X + FBitmap.Width, FPosition.Y + FBitmap.Height)
                                );

  Self.Refresh(FBoundsRect, AAxes);

  Result := True;
end;


function TUdImage.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal; ALwFactor: Float): Boolean;
var
  LRect: TRect;
  X, Y, W, H: Integer;
begin
  Result := False;
  if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //=======>>>

  LRect.Left   := AAxes.XPixel(FBoundsRect.X1);
  LRect.Bottom := AAxes.YPixel(FBoundsRect.Y1);
  LRect.Right  := AAxes.XPixel(FBoundsRect.X2);
  LRect.Top    := AAxes.YPixel(FBoundsRect.Y2);

  ACanvas.StretchDraw(LRect, FBitmap);

  if FShowBorder then
  begin
    X := (LRect.Left + LRect.Right) div 2;
    Y := (LRect.Top + LRect.Bottom) div 2;
    W := Abs((LRect.Right - LRect.Left) div 2);
    H := Abs((LRect.Bottom - LRect.Top) div 2);

    ACanvas.Brush.Style := bsClear;
    ACanvas.Pen.Color := FBorderColor;
    ACanvas.Pen.Style := FBorderStyle;
    ACanvas.Pen.Width := 0;
    ACanvas.Rectangle(X - W, Y - H, X + W, Y + H);
  end;

  Result := True;
end;






//-----------------------------------------------------------------------------------------

procedure TUdImage.SaveToStream(AStream: TStream);
var
  LHasBmp: Boolean;
  LBmpStream: TMemoryStream;
begin
  inherited;

  FloatToStream(AStream, FPosition.X);
  FloatToStream(AStream, FPosition.Y);

  BoolToStream(AStream, FShowBorder);
  IntToStream(AStream, FBorderColor);
  IntToStream(AStream, Ord(FBorderStyle));

  LHasBmp := Assigned(FBitmap) and (FBitmap.Width > 0) and (FBitmap.Height > 0);
  BoolToStream(AStream, LHasBmp);

  if LHasBmp then
  begin
    LBmpStream := TMemoryStream.Create();
    try
      FBitmap.SaveToStream(LBmpStream);
      StreamToStream(AStream, LBmpStream);
    finally
      LBmpStream.Free;
    end;
  end;
end;

procedure TUdImage.LoadFromStream(AStream: TStream);
var
  LHasBmp: Boolean;
  LBmpStream: TMemoryStream;
begin
  inherited;

  FPosition.X := FloatFromStream(AStream);
  FPosition.Y := FloatFromStream(AStream);

  FShowBorder := BoolFromStream(AStream);
  FBorderColor := IntFromStream(AStream);
  FBorderStyle := TPenStyle(IntFromStream(AStream));


  LHasBmp := BoolFromStream(AStream);

  if LHasBmp then
  begin
    LBmpStream := TMemoryStream.Create();
    try
      StreamFromStream(AStream, LBmpStream);
      FBitmap.LoadFromStream(LBmpStream);
    finally
      LBmpStream.Free;
    end;
  end
  else
  begin
    FBitmap.FreeImage();
  end;

  Self.Update();
end;

procedure TUdImage.SaveToXml(AXmlNode: TObject; ANodeName: string);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Position'] := Point2DToStr(FPosition);

  //TODO: save FBitmap to xml
end;


procedure TUdImage.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;

  LXmlNode := TUdXmlNode(AXmlNode);

  FPosition := StrToPoint2D(LXmlNode.Prop['Position']);

  //TODO: load FBitmap from xml
end;





end.
