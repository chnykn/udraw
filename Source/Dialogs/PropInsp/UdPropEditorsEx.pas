{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPropEditorsEx;

interface

uses
  Windows, Classes, Controls, Graphics, Types, TypInfo,
  UdTypes, UdGTypes, UdPropEditors;

type
  TUdDimStylePropEditorEx = class(TUdPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    function AllEqual: Boolean; override;

    procedure GetValues(AValues: TStrings); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;

  TUdTextStylePropEditorEx = class(TUdPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    function AllEqual: Boolean; override;

    procedure GetValues(AValues: TStrings); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;



  TUdColorPropEditorEx = class(TUdPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    function AllEqual: Boolean; override;

    procedure GetValues(AValues: TStrings); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;

    procedure ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); override;
    procedure ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); override;
    procedure ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;
  end;


  TUdLineTypePropEditorEx = class(TUdPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    function AllEqual: Boolean; override;

    procedure GetValues(AValues: TStrings); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;

    procedure ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); override;
    procedure ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); override;
    procedure ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;
  end;


  TUdLineWeightPropEditorEx = class(TUdPropEditor)
  protected
    FValues: TStringList;

  public
    constructor Create(ADesigner: Pointer; APropCount: Integer); override;
    destructor Destroy; override;

    function GetAttrs: TUdPropAttrs; override;
    function AllEqual: Boolean; override;

    procedure GetValues(AValues: TStrings); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;

    procedure ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); override;
    procedure ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); override;
    procedure ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;
  end;


  TUdLayerPropEditorEx = class(TUdPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    function AllEqual: Boolean; override;

    procedure GetValues(AValues: TStrings); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;


  TUdLayoutPropEditorEx = class(TUdPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    function AllEqual: Boolean; override;

    procedure GetValues(AValues: TStrings); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;


implementation

{ TUdLineTypePropEditorEx }

uses
  SysUtils,
  UdDocument, UdObject, UdColor, UdLinetype, UdLineWeight, UdLayer, UdLayout,
  UdDimStyle, UdTextStyle, UdDrawUtil;





//================================================================================================


function TUdDimStylePropEditorEx.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, {praSortList,} praDropDownList];
end;


function TUdDimStylePropEditorEx.AllEqual: Boolean;
var
  I: Integer;
  LName: string;
  LDimStyle: TUdDimStyle;
begin
  Result := True;

  if FPropCount > 0 then
  begin
    LDimStyle := TUdDimStyle(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LDimStyle) then LName := LDimStyle.Name else LName := '';

    for I := 1 to FPropCount - 1 do
    begin
      LDimStyle := TUdDimStyle(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LDimStyle) and (LDimStyle.Name <> LName) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;


procedure TUdDimStylePropEditorEx.GetValues(AValues: TStrings);
var
  I: Integer;
  LDocument: TUdDocument;
begin
  AValues.Clear;

  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);

    for I := 0 to LDocument.DimStyles.Count - 1 do
      AValues.Add(LDocument.DimStyles.Items[I].Name)
  end;
end;

function TUdDimStylePropEditorEx.GetValue: string;
var
  I: Integer;
  LReturn: string;
  LDimStyle: TUdDimStyle;
begin
  Result := '';

  if FPropCount > 0 then
  begin
    LDimStyle := TUdDimStyle(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LDimStyle) then LReturn := LDimStyle.Name else LReturn := '';

    for I := 1 to FPropCount - 1 do
    begin
      LDimStyle := TUdDimStyle(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LDimStyle) and (LDimStyle.Name <> LReturn) then
      begin
        LReturn := '';
        Break;
      end;
    end;

    Result := LReturn;
  end;
end;

procedure TUdDimStylePropEditorEx.SetValue(const Value: string);
var
  I: Integer;
  LDimStyle: TUdDimStyle;
  LDocument: TUdDocument;
begin
  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);
    LDimStyle := LDocument.DimStyles.GetItem(Value);

    for I := 0 to FPropCount - 1 do
      SetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo, LDimStyle);

    Modified();
  end;
end;








//================================================================================================


function TUdTextStylePropEditorEx.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, {praSortList,} praDropDownList];
end;


function TUdTextStylePropEditorEx.AllEqual: Boolean;
var
  I: Integer;
  LName: string;
  LTextStyle: TUdTextStyle;
begin
  Result := True;

  if FPropCount > 0 then
  begin
    LTextStyle := TUdTextStyle(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LTextStyle) then LName := LTextStyle.Name else LName := '';

    for I := 1 to FPropCount - 1 do
    begin
      LTextStyle := TUdTextStyle(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LTextStyle) and (LTextStyle.Name <> LName) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;


procedure TUdTextStylePropEditorEx.GetValues(AValues: TStrings);
var
  I: Integer;
  LDocument: TUdDocument;
begin
  AValues.Clear;

  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);

    for I := 0 to LDocument.TextStyles.Count - 1 do
      AValues.Add(LDocument.TextStyles.Items[I].Name)
  end;
end;

function TUdTextStylePropEditorEx.GetValue: string;
var
  I: Integer;
  LReturn: string;
  LTextStyle: TUdTextStyle;
begin
  Result := '';

  if FPropCount > 0 then
  begin
    LTextStyle := TUdTextStyle(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LTextStyle) then LReturn := LTextStyle.Name else LReturn := '';

    for I := 1 to FPropCount - 1 do
    begin
      LTextStyle := TUdTextStyle(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LTextStyle) and (LTextStyle.Name <> LReturn) then
      begin
        LReturn := '';
        Break;
      end;
    end;

    Result := LReturn;
  end;
end;

procedure TUdTextStylePropEditorEx.SetValue(const Value: string);
var
  I: Integer;
  LTextStyle: TUdTextStyle;
  LDocument: TUdDocument;
begin
  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);
    LTextStyle := LDocument.TextStyles.GetItem(Value);

    for I := 0 to FPropCount - 1 do
      SetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo, LTextStyle);

    Modified();
  end;
end;



//================================================================================================


function TUdColorPropEditorEx.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, {praSortList,} praDropDownList, praOwnerDrawValues];
end;


function TUdColorPropEditorEx.AllEqual: Boolean;
var
  I: Integer;
  LName: string;
  LColor: TUdColor;
begin
  Result := True;

  if FPropCount > 0 then
  begin
    LColor := TUdColor(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LColor) then LName := LColor.Name else LName := '';

    for I := 1 to FPropCount - 1 do
    begin
      LColor := TUdColor(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LColor) and (LColor.Name <> LName) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;


procedure TUdColorPropEditorEx.GetValues(AValues: TStrings);
var
  I: Integer;
  LDocument: TUdDocument;
begin
  AValues.Clear;

  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);

    for I := 0 to LDocument.Colors.Count - 1 do
      AValues.Add(LDocument.Colors.Items[I].Name)
  end;
end;

function TUdColorPropEditorEx.GetValue: string;
var
  I: Integer;
  LReturn: string;
  LColor: TUdColor;
begin
  Result := '';

  if FPropCount > 0 then
  begin
    LColor := TUdColor(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LColor) then LReturn := LColor.Name else LReturn := '';

    for I := 1 to FPropCount - 1 do
    begin
      LColor := TUdColor(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LColor) and (LColor.Name <> LReturn) then
      begin
        LReturn := '';
        Break;
      end;
    end;

    Result := LReturn;
  end;
end;

procedure TUdColorPropEditorEx.SetValue(const Value: string);
var
  I: Integer;
  LColor: TUdColor;
  LDocument: TUdDocument;
begin
  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);
    LColor := LDocument.Colors.GetItem(Value);

    for I := 0 to FPropCount - 1 do
      SetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo, LColor);

    Modified();
  end;
end;


procedure TUdColorPropEditorEx.ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  I: Integer;
  LRight: Integer;
  LOldPenColor: TColor;
  LOldBrushColor: TColor;
  LColor, LColor2: TUdColor;
  LDocument: TUdDocument;
  LDispValue: string;
  LColorValue: TColor;
begin
  LDispValue := AValue;
  LColorValue := clNone;

  if FPropCount > 0 then
  begin
    if UpperCase(AValue) = 'BYLAYER' then
    begin
      LColor := TUdColor(TypInfo.GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));

      if Assigned(LColor) then
      begin
        for I := 1 to FPropCount - 1 do
        begin
          LColor2 := TUdColor(TypInfo.GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
          if not LColor.IsEqual(LColor2) then
          begin
            LColor := nil;
            Break;
          end;
        end;
      end;
      
      if Assigned(LColor) then
        LColorValue := LColor.TrueColor;
    end
    else begin
      LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);

      LColor := LDocument.Colors.GetItem(AValue);
      if Assigned(LColor) then
        LColorValue := LColor.TrueColor;
    end;
  end;


  LRight := (ARect.Bottom - ARect.Top) + ARect.Left;
  
  with ACanvas do
  begin
    if LColorValue <> clNone then
    begin
      LOldPenColor := Pen.Color;
      LOldBrushColor := Brush.Color;

      Pen.Color := Brush.Color;
      Rectangle(ARect.Left, ARect.Top, LRight, ARect.Bottom);

      Brush.Color := LColorValue;
      Pen.Color   := FColorToBorderColor(ColorToRGB(Brush.Color), ASelected);
      Rectangle(ARect.Left + 1, ARect.Top + 1, LRight - 1, ARect.Bottom - 1);

      Pen.Color := LOldPenColor;
      Brush.Color := LOldBrushColor;
    end
    else begin
      Pen.Color := Brush.Color;
      Rectangle(ARect);
    end;

    ACanvas.TextRect(
      Rect(LRight, ARect.Top, ARect.Right, ARect.Bottom),
      LRight + 5,
      ARect.Top + 1,
      LDispValue
      );    
  end;
end;


procedure TUdColorPropEditorEx.ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer);
begin
  AHeight := ACanvas.TextHeight('Ud') + 2;
end;


procedure TUdColorPropEditorEx.ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + ACanvas.TextHeight('Ud');
end;











//================================================================================================


function TUdLineTypePropEditorEx.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, {praSortList,} praDropDownList, praOwnerDrawValues];
end;


function TUdLineTypePropEditorEx.AllEqual: Boolean;
var
  I: Integer;
  LName: string;
  LLineType: TUdLineType;
begin
  Result := True;

  if FPropCount > 0 then
  begin
    LLineType := TUdLineType(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LLineType) then LName := LLineType.Name else LName := '';

    for I := 1 to FPropCount - 1 do
    begin
      LLineType := TUdLineType(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LLineType) and (LLineType.Name <> LName) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;


procedure TUdLineTypePropEditorEx.GetValues(AValues: TStrings);
var
  I: Integer;
  LDocument: TUdDocument;
begin
  AValues.Clear;

  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);

    for I := 0 to LDocument.LineTypes.Count - 1 do
      AValues.Add(LDocument.LineTypes.Items[I].Name)
  end;
end;

function TUdLineTypePropEditorEx.GetValue: string;
var
  I: Integer;
  LReturn: string;
  LLineType: TUdLineType;
begin
  Result := '';

  if FPropCount > 0 then
  begin
    LLineType := TUdLineType(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LLineType) then LReturn := LLineType.Name else LReturn := '';

    for I := 1 to FPropCount - 1 do
    begin
      LLineType := TUdLineType(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LLineType) and (LLineType.Name <> LReturn) then
      begin
        LReturn := '';
        Break;
      end;
    end;

    Result := LReturn;
  end;
end;

procedure TUdLineTypePropEditorEx.SetValue(const Value: string);
var
  I: Integer;
  LLineType: TUdLineType;
  LDocument: TUdDocument;
begin
  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);
    LLineType := LDocument.LineTypes.GetItem(Value);

    for I := 0 to FPropCount - 1 do
      SetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo, LLineType);

    Modified();
  end;
end;


procedure TUdLineTypePropEditorEx.ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
const
  DRAW_LNTYP_WIDTH = 80;
var
  I: Integer;
  LRight: Integer;
  LOldPenColor: TColor;
  LOldBrushColor: TColor;
  LLineType, LLineType2: TUdLineType;
  LDocument: TUdDocument;
begin
  LLineType := nil;

  if FPropCount > 0 then
  begin
    if UpperCase(AValue) = 'BYLAYER' then
    begin
      LLineType := TUdLineType(TypInfo.GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));

      if Assigned(LLineType) then
      begin
        for I := 1 to FPropCount - 1 do
        begin
          LLineType2 := TUdLineType(TypInfo.GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
          if not LLineType.IsEqual(LLineType2) then
          begin
            LLineType := nil;
            Break;
          end;
        end;
      end;
    end
    else begin
      LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);
      LLineType := LDocument.LineTypes.GetItem(AValue);
    end;
  end;


  LRight := DRAW_LNTYP_WIDTH;
  
  if Assigned(LLineType) then
  begin
    LOldPenColor := ACanvas.Pen.Color;
    LOldBrushColor := ACanvas.Brush.Color;

    ACanvas.Pen.Color := ACanvas.Brush.Color;

    ACanvas.Rectangle(ARect.Left, ARect.Top, LRight, ARect.Bottom);
    DrawLinetype(ACanvas, Rect(ARect.Left, ARect.Top, LRight, ARect.Bottom), LLineType.Value);

    ACanvas.Pen.Color := LOldPenColor;
    ACanvas.Brush.Color := LOldBrushColor;
  end
  else begin
    ACanvas.Pen.Color := ACanvas.Brush.Color;
    ACanvas.Rectangle(ARect);
  end;

  ACanvas.TextRect(
    Rect(LRight, ARect.Top, ARect.Right, ARect.Bottom),
    LRight + 5,
    ARect.Top + 1,
    AValue
    );  
end;


procedure TUdLineTypePropEditorEx.ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer);
begin
  AHeight := ACanvas.TextHeight('Ud') + 2;
end;


procedure TUdLineTypePropEditorEx.ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + ACanvas.TextHeight('Ud');
end;









//================================================================================================


constructor TUdLineWeightPropEditorEx.Create(ADesigner: Pointer; APropCount: Integer);
begin
  inherited;
  FValues := TStringList.Create();
end;

destructor TUdLineWeightPropEditorEx.Destroy;
begin
  if Assigned(FValues) then FValues.Free;
  FValues := nil;
  inherited;
end;


function TUdLineWeightPropEditorEx.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, {praSortList,} praDropDownList, praOwnerDrawValues];
end;


function TUdLineWeightPropEditorEx.AllEqual: Boolean;
var
  I: Integer;
  LName: string;
  LLineWeight: TUdLineWeight;
begin
  Result := True;

  if FPropCount > 0 then
  begin
    LLineWeight := TUdLineWeight(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    LName := GetLineWeightName(LLineWeight);

    for I := 1 to FPropCount - 1 do
    begin
      LLineWeight := TUdLineWeight(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if (GetLineWeightName(LLineWeight) <> LName) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;


procedure TUdLineWeightPropEditorEx.GetValues(AValues: TStrings);
var
  I: Integer;
begin
  if FValues.Count <= 0 then
    for I := Low(ALL_LINE_WEIGHTS) to High(ALL_LINE_WEIGHTS) do
      FValues.Add(GetLineWeightName(ALL_LINE_WEIGHTS[I]));

  AValues.Assign(FValues);
end;

function TUdLineWeightPropEditorEx.GetValue: string;
var
  I: Integer;
  LReturn: string;
  LLineWeight: TUdLineWeight;
begin
  Result := '';

  if FPropCount > 0 then
  begin
    LLineWeight := TUdLineWeight(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    LReturn := GetLineWeightName(LLineWeight);

    for I := 1 to FPropCount - 1 do
    begin
      LLineWeight := TUdLineWeight(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if (GetLineWeightName(LLineWeight) <> LReturn) then
      begin
        LReturn := '';
        Break;
      end;
    end;

    Result := LReturn;
  end;
end;

procedure TUdLineWeightPropEditorEx.SetValue(const Value: string);
var
  I: Integer;
  LLineWeight: TUdLineWeight;
begin
  if FPropCount > 0 then
  begin
    LLineWeight := GetLineWeightByName(Value);

    for I := 0 to FPropCount - 1 do
      SetOrdProp(FPropList^[I].Instance, FPropList^[I].PropInfo, LLineWeight);

    Modified();
  end;
end;


procedure TUdLineWeightPropEditorEx.ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
const
  DRAW_LWT_WIDTH = 80;
var
  LRight: Integer;
  LOldPenWidth: Integer;
  LOldPenColor: TColor;
  LOldBrushColor: TColor;
  LLineWeight: TUdLineWeight;
begin
  LLineWeight := GetLineWeightByName(AValue);

  if LLineWeight <> MAXBYTE then
  begin
    LOldPenWidth := ACanvas.Pen.Width;
    LOldPenColor := ACanvas.Pen.Color;
    LOldBrushColor := ACanvas.Brush.Color;

    LRight := DRAW_LWT_WIDTH;
    ACanvas.Pen.Color := ACanvas.Brush.Color;

    ACanvas.Rectangle(ARect.Left, ARect.Top, LRight, ARect.Bottom);
    DrawLineWeight(ACanvas, Rect(ARect.Left, ARect.Top, LRight, ARect.Bottom),
                   UdLineWeight.GetLineWeightWidth(LLineWeight) );

    ACanvas.Pen.Width := LOldPenWidth;
    ACanvas.Pen.Color := LOldPenColor;
    ACanvas.Brush.Color := LOldBrushColor;

    ACanvas.TextRect(
      Rect(LRight, ARect.Top, ARect.Right, ARect.Bottom),
      LRight + 5,
      ARect.Top + 1,
      AValue
      );
  end
  else begin
    ACanvas.Pen.Color := ACanvas.Brush.Color;
    ACanvas.Rectangle(ARect);
  end;
end;


procedure TUdLineWeightPropEditorEx.ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer);
begin
  AHeight := ACanvas.TextHeight('Ud') + 2;
end;


procedure TUdLineWeightPropEditorEx.ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + ACanvas.TextHeight('Ud');
end;







//================================================================================================


function TUdLayerPropEditorEx.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, {praSortList,} praDropDownList];
end;


function TUdLayerPropEditorEx.AllEqual: Boolean;
var
  I: Integer;
  LName: string;
  LLayer: TUdLayer;
begin
  Result := True;

  if FPropCount > 0 then
  begin
    LLayer := TUdLayer(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LLayer) then LName := LLayer.Name else LName := '';

    for I := 1 to FPropCount - 1 do
    begin
      LLayer := TUdLayer(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LLayer) and (LLayer.Name <> LName) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;


procedure TUdLayerPropEditorEx.GetValues(AValues: TStrings);
var
  I: Integer;
  LDocument: TUdDocument;
begin
  AValues.Clear;

  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);

    for I := 0 to LDocument.Layers.Count - 1 do
      AValues.Add(LDocument.Layers.Items[I].Name)
  end;
end;

function TUdLayerPropEditorEx.GetValue: string;
var
  I: Integer;
  LReturn: string;
  LLayer: TUdLayer;
begin
  Result := '';

  if FPropCount > 0 then
  begin
    LLayer := TUdLayer(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LLayer) then LReturn := LLayer.Name else LReturn := '';

    for I := 1 to FPropCount - 1 do
    begin
      LLayer := TUdLayer(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LLayer) and (LLayer.Name <> LReturn) then
      begin
        LReturn := '';
        Break;
      end;
    end;

    Result := LReturn;
  end;
end;

procedure TUdLayerPropEditorEx.SetValue(const Value: string);
var
  I: Integer;
  LLayer: TUdLayer;
  LDocument: TUdDocument;
begin
  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);
    LLayer := LDocument.Layers.GetItem(Value);

    for I := 0 to FPropCount - 1 do
      SetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo, LLayer);

    Modified();
  end;
end;









//================================================================================================


function TUdLayoutPropEditorEx.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, {praSortList,} praDropDownList];
end;


function TUdLayoutPropEditorEx.AllEqual: Boolean;
var
  I: Integer;
  LName: string;
  LLayout: TUdLayout;
begin
  Result := True;

  if FPropCount > 0 then
  begin
    LLayout := TUdLayout(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LLayout) then LName := LLayout.Name else LName := '';

    for I := 1 to FPropCount - 1 do
    begin
      LLayout := TUdLayout(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LLayout) and (LLayout.Name <> LName) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;


procedure TUdLayoutPropEditorEx.GetValues(AValues: TStrings);
var
  I: Integer;
  LDocument: TUdDocument;
begin
  AValues.Clear;

  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);

    for I := 0 to LDocument.Layouts.Count - 1 do
      AValues.Add(LDocument.Layouts.Items[I].Name)
  end;
end;

function TUdLayoutPropEditorEx.GetValue: string;
var
  I: Integer;
  LReturn: string;
  LLayout: TUdLayout;
begin
  Result := '';

  if FPropCount > 0 then
  begin
    LLayout := TUdLayout(GetObjectProp(FPropList^[0].Instance, FPropList^[0].PropInfo));
    if Assigned(LLayout) then LReturn := LLayout.Name else LReturn := '';

    for I := 1 to FPropCount - 1 do
    begin
      LLayout := TUdLayout(GetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo));
      if Assigned(LLayout) and (LLayout.Name <> LReturn) then
      begin
        LReturn := '';
        Break;
      end;
    end;

    Result := LReturn;
  end;
end;

procedure TUdLayoutPropEditorEx.SetValue(const Value: string);
var
  I: Integer;
  LLayout: TUdLayout;
  LDocument: TUdDocument;
begin
  if FPropCount > 0 then
  begin
    LDocument := TUdDocument(TUdObject(FPropList^[0].Instance).Document);
    LLayout := LDocument.Layouts.GetItem(Value);

    for I := 0 to FPropCount - 1 do
      SetObjectProp(FPropList^[I].Instance, FPropList^[I].PropInfo, LLayout);

    Modified();
  end;
end;






end.