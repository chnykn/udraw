{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimStylesFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Buttons,

  UdTypes, UdConsts, UdObject, UdAxes, UdDocument, UdDrawPanel, UdEntities,
  UdColors, UdColor, UdLineTypes, UdLinetype, UdLineWeights, UdDimStyles, UdDimStyle,
  UdUnits, UdResDimArrows, UdColorComboBox, UdLntypComboBox, UdLwtComboBox;

type
  TUdDimStylesForm = class(TForm)
    PageControl1: TPageControl;
    tabList: TTabSheet;
    tabLines: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet1: TTabSheet;
    TabSheet6: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    ltbDimStyles: TListBox;
    lblStyles: TLabel;
    edtStyleName: TEdit;
    lblStyleName: TLabel;
    lblPreview: TLabel;
    btnNew: TButton;
    btnDelete: TButton;
    btnSetCurrent: TButton;
    gpbDimLines: TGroupBox;
    lblColor: TLabel;
    lblLineType: TLabel;
    lblLineWeight: TLabel;
    lblExtBeyondTicks: TLabel;
    lblBaselineSpacing: TLabel;
    lblSuppressLine: TLabel;
    edtExtBeyondTicks: TEdit;
    udnExtBeyondTicks: TUpDown;
    ckbSuppressLine1: TCheckBox;
    ckbSuppressLine2: TCheckBox;
    edtBaselineSpacing: TEdit;
    upnBaselineSpacing: TUpDown;
    gpbExtLines: TGroupBox;
    lblExtColor: TLabel;
    lblExtLineType1: TLabel;
    lblExtLineWeight: TLabel;
    lblExtLineType2: TLabel;
    lblExtBeyondDimLines: TLabel;
    lblExtOriginOffset: TLabel;
    lblExtSuppressLine: TLabel;
    edtExtOriginOffset: TEdit;
    edtExtBeyondDimLines: TEdit;
    udnExtOriginOffset: TUpDown;
    udnExtBeyondDimLines: TUpDown;
    ckbExtSuppressLine1: TCheckBox;
    ckbExtSuppressLine2: TCheckBox;
    gpbArrowheads: TGroupBox;
    lblArrowFirst: TLabel;
    cbxArrowFirst: TComboBox;
    lblArrowSecond: TLabel;
    cbxArrowSecond: TComboBox;
    lblArrowLeader: TLabel;
    cbxArrowLeader: TComboBox;
    lblArrowSize: TLabel;
    edtArrowSize: TEdit;
    gpbCenterMarks: TGroupBox;
    rdbCenterNone: TRadioButton;
    rdbCenterMark: TRadioButton;
    rdbCenterLine: TRadioButton;
    lblMarkSize: TLabel;
    edtMarkSize: TEdit;
    udnMarkSize: TUpDown;
    gpbArcLengthSymbol: TGroupBox;
    rdbSymInFront: TRadioButton;
    rdbSymAbove: TRadioButton;
    rdbSymNone: TRadioButton;
    gpbTextAppearance: TGroupBox;
    lblTextStyle: TLabel;
    lblTextColor: TLabel;
    lblFillColor: TLabel;
    lblTextHeight: TLabel;
    edtTextHeight: TEdit;
    udnTextHeight: TUpDown;
    ckbDrawFrame: TCheckBox;
    cbxTextStyle: TComboBox;
    btnTextStyle: TSpeedButton;
    gpbTextPlacement: TGroupBox;
    lblVerticalPosition: TLabel;
    lblHorizontalPosition: TLabel;
    lblOffsetFromDimLine: TLabel;
    edtOffsetFromDimLine: TEdit;
    udnOffsetFromDimLine: TUpDown;
    cbxVerticalPosition: TComboBox;
    cbxHorizontalPosition: TComboBox;
    gpbTextAlignment: TGroupBox;
    rdbTextAlignHorizontal: TRadioButton;
    rdbTextAlignWithDimLine: TRadioButton;
    rdbTextAlignISOStandard: TRadioButton;
    gpbLinearDimensions: TGroupBox;
    lblUnitFormat: TLabel;
    lblPrecision: TLabel;
    lblDecimal: TLabel;
    lblRoundOff: TLabel;
    lblPrefix: TLabel;
    lblSuffix: TLabel;
    cbxUnitFormat: TComboBox;
    cbxPrecision: TComboBox;
    cbxDecimal: TComboBox;
    edtRoundOff: TEdit;
    udnRoundOff: TUpDown;
    edtPrefix: TEdit;
    edtSuffix: TEdit;
    lblMeasurementScale: TLabel;
    edtMeasurementScale: TEdit;
    udnMeasurementScale: TUpDown;
    gpbAngularDimensions: TGroupBox;
    gpbAngZeroSuppression: TGroupBox;
    ckbAngSuppressLeading: TCheckBox;
    ckbAngSuppressTrailing: TCheckBox;
    lblAngUnitFormat: TLabel;
    cbxAngUnitFormat: TComboBox;
    lblAngPrecision: TLabel;
    cbxAngPrecision: TComboBox;
    gpbZeroSuppression: TGroupBox;
    ckbSuppressLeading: TCheckBox;
    ckbSuppressTrailing: TCheckBox;
    gpbAltLinearDimensions: TGroupBox;
    lblAltUnitFormat: TLabel;
    Label6: TLabel;
    lblAltMultiplier: TLabel;
    lblAltRoundDis: TLabel;
    lblAltPrefix: TLabel;
    lblAltSuffix: TLabel;
    cbxAltUnitFormat: TComboBox;
    cbxAltPrecision: TComboBox;
    edtAltRoundDis: TEdit;
    udnAltRoundDis: TUpDown;
    edtAltPrefix: TEdit;
    edtAltSuffix: TEdit;
    gpbAltZeroSuppression: TGroupBox;
    ckbAltSuppressLeading: TCheckBox;
    ckbAltSuppressTrailing: TCheckBox;
    ckbDispAltUnits: TCheckBox;
    edtAltMultiplier: TEdit;
    udnedtAltMultiplier: TUpDown;
    gpbAltPlacement: TGroupBox;
    UpDown6: TUpDown;
    rdbAltAfter: TRadioButton;
    rdbAltBelow: TRadioButton;
    GroupBox8: TGroupBox;
    lblOverallScale: TLabel;
    edtOverallScale: TEdit;
    udnOverallScale: TUpDown;
    pnlPreview: TPanel;
    udnArrowSize: TUpDown;
    ckbNoneColor: TCheckBox;
    lblCurrentStyle: TLabel;
    lblCurrStyle: TLabel;
    
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    
    procedure PageControl1Change(Sender: TObject);
    procedure cbxDimArrowDrawItem(AControl: TWinControl; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);

    procedure edtDimStyleLinesPropChange(Sender: TObject);
    procedure udnDimStyleLinesPropChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure ckbDimStyleLinesPropSuppressClick(Sender: TObject);

    procedure cbxDimStyleArrowKindChange(Sender: TObject);
    procedure edtArrowSizeChange(Sender: TObject);
    procedure edtMarkSizeChange(Sender: TObject);
    procedure udnArrowSizeChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure udnMarkSizeChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure rdbArcLengthSymbolClick(Sender: TObject);

    procedure cbxTextStyleSelect(Sender: TObject);
    procedure btnTextStyleClick(Sender: TObject);
    procedure ckbNoneColorClick(Sender: TObject);
    procedure edtTextHeightChange(Sender: TObject);
    procedure udnTextHeightChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure ckbDrawFrameClick(Sender: TObject);
    procedure cbxVerticalPositionSelect(Sender: TObject);
    procedure cbxHorizontalPositionSelect(Sender: TObject);
    procedure edtOffsetFromDimLineChange(Sender: TObject);
    procedure udnOffsetFromDimLineChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure rdbTextAlignmentClick(Sender: TObject);

    procedure udnOverallScaleChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure edtOverallScaleChange(Sender: TObject);
    procedure cbxUnitFormatSelect(Sender: TObject);
    procedure cbxPrecisionSelect(Sender: TObject);
    procedure cbxDecimalSelect(Sender: TObject);
    procedure edtRoundOffChange(Sender: TObject);
    procedure udnRoundOffChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure edtPrefixChange(Sender: TObject);
    procedure edtSuffixChange(Sender: TObject);
    procedure edtMeasurementScaleChange(Sender: TObject);
    procedure udnMeasurementScaleChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure ckbSuppressLeadingClick(Sender: TObject);
    procedure ckbSuppressTrailingClick(Sender: TObject);
    procedure cbxAngUnitFormatSelect(Sender: TObject);
    procedure cbxAngPrecisionSelect(Sender: TObject);
    procedure ckbAngSuppressLeadingClick(Sender: TObject);
    procedure ckbAngSuppressTrailingClick(Sender: TObject);
    
    procedure ckbDispAltUnitsClick(Sender: TObject);
    procedure cbxAltUnitFormatSelect(Sender: TObject);
    procedure cbxAltPrecisionSelect(Sender: TObject);
    procedure edtAltMultiplierChange(Sender: TObject);
    procedure udnedtAltMultiplierChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure edtAltRoundDisChange(Sender: TObject);
    procedure udnAltRoundDisChangingEx(Sender: TObject; var AllowChange: Boolean; NewValue: Smallint; Direction: TUpDownDirection);
    procedure edtAltPrefixChange(Sender: TObject);
    procedure edtAltSuffixChange(Sender: TObject);
    procedure ckbAltSuppressLeadingClick(Sender: TObject);
    procedure ckbAltSuppressTrailingClick(Sender: TObject);
    procedure rdbAltPlacementClick(Sender: TObject);

    procedure ltbDimStylesClick(Sender: TObject);
    procedure edtStyleNameChange(Sender: TObject);
        
    procedure btnNewClick(Sender: TObject);
    procedure btnSetCurrentClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);


    
  private
    FDocument: TUdDocument;
    FDimStyles: TUdDimStyles;

    FAxes: TUdAxes;
    FEntities: TUdEntities;
    FEntities2: TUdEntities;
    
    FDrawPanel: TUdDrawPanel;
    FResDimArrows: TUdResDimArrows;
    
    FColors2: TUdColors;
    FLineTypes2:  TUdLineTypes;
    FLineWeights2: TUdLineWeights;
    FDimStyles2: TUdDimStyles;


    FCurrDimStyle: TUdDimStyle;


    FDimColorCombox      : TUdColorComboBox;
    FDimLineTypeCombox   : TUdLntypComboBox;
    FDimLineWeightCombox : TUdLwtComboBox;

    FExtColorCombox      : TUdColorComboBox;
    FExtLineType1Combox  : TUdLntypComboBox;
    FExtLineType2Combox  : TUdLntypComboBox;
    FExtLineWeightCombox : TUdLwtComboBox;


    FTextColorCombox: TUdColorComboBox;
    FFillColorCombox: TUdColorComboBox;

    FChanging: Boolean;

  protected
    procedure UpdatePrivewDim();

    procedure OnColorSelect(Sender: TObject);
    procedure OnLineTypeSelect(Sender: TObject);
    procedure OnLineWeightSelect(Sender: TObject);
    
    procedure OnColorsAddOther(Sender: TObject);
    procedure OnLineTypesAddOther(Sender: TObject);
    procedure OnDrawPanelPaint(Sender: TObject; ACanvas: TCanvas);
      
    procedure InitPrecisionCombox(AComboBox: TComboBox; AUnit: TUdLengthUnit; APrecision: Byte); overload;
    procedure InitPrecisionCombox(AComboBox: TComboBox; AUnit: TUdAngleUnit; APrecision: Byte); overload;

    procedure SetDimStyles(const AValue: TUdDimStyles);
    procedure SetCurrDimStyle(const AValue: TUdDimStyle);

  public
    property DimStyles: TUdDimStyles read FDimStyles write SetDimStyles;
    
  end;



function ShowDimStylesDialog(ADimStyles: TUdDimStyles): Boolean;  

implementation

{$R *.dfm}

uses
  SysUtils, UdEntity, UdDimension, UdTextStyle, UdText, UdDimProps, UdXml, UdUtils,
  UdColorsFrm, UdLineTypesFrm, UdTextStylesFrm;
  
const
  DIM_SAMPLE_FILE = 'DimSample.xml';

type
  TFObject = class(TUdObject);
  TFEntity = class(TUdEntity);
  TFDrawPanel = class(TUdDrawPanel);





function ShowDimStylesDialog(ADimStyles: TUdDimStyles): Boolean;
var
  LForm: TUdDimStylesForm;
begin
  Result := False;
  if not Assigned(ADimStyles) then Exit; //===>>>>

  LForm := TUdDimStylesForm.Create(nil);
  try
    LForm.DimStyles := ADimStyles;
    LForm.ShowModal();
  finally
    LForm.Free;
  end;

  Result := True;
end;




//==================================================================================================
{ TUdDimStylesForm }



procedure TUdDimStylesForm.FormCreate(Sender: TObject);
var
  I: Integer;
  LStr: string;
begin
  FColors2      :=  TUdColors.Create();
  FLineTypes2   :=  TUdLineTypes.Create();
  FLineWeights2 :=  TUdLineWeights.Create();
  FDimStyles2   :=  TUdDimStyles.Create();

  FAxes := TUdAxes.Create;
  FEntities  := TUdEntities.Create;
  FEntities2 := TUdEntities.Create;

  
  FDrawPanel := TUdDrawPanel.Create(nil);
  FDrawPanel.Parent        := pnlPreview;
  FDrawPanel.Align         := alClient;
  FDrawPanel.ScrollBars    := ssNone;
  FDrawPanel.ReadOnly      := True;
  FDrawPanel.XCursor.Style := csDraw;
  TFDrawPanel(FDrawPanel)._OnPaint := OnDrawPanelPaint;
  

  
  PageControl1.ActivePageIndex := 0;
  pnlPreview.Left := 200;
  pnlPreview.Top  := PageControl1.Top + 85;

  FResDimArrows := TUdResDimArrows.Create;


  FDimColorCombox             := TUdColorComboBox.Create(Self);
  FDimColorCombox.Parent      := gpbDimLines;
  FDimColorCombox.Left        := 105;
  FDimColorCombox.Top         := 22;
  FDimColorCombox.Width       := 150;
  FDimColorCombox.OnSelect    := OnColorSelect;
  FDimColorCombox.OnSelectOther := OnColorsAddOther;

  FDimLineTypeCombox          := TUdLntypComboBox.Create(Self);
  FDimLineTypeCombox.Parent   := gpbDimLines;
  FDimLineTypeCombox.Left     := 105;
  FDimLineTypeCombox.Top      := 52;
  FDimLineTypeCombox.Width    := 150;
  FDimLineTypeCombox.OnSelect := OnLineTypeSelect;
  FDimLineTypeCombox.OnSelectOther := OnLineTypesAddOther;
  
  FDimLineWeightCombox        := TUdLwtComboBox.Create(Self);
  FDimLineWeightCombox.Parent := gpbDimLines;
  FDimLineWeightCombox.Left   := 105;
  FDimLineWeightCombox.Top    := 83;
  FDimLineWeightCombox.Width  := 150;
  FDimLineWeightCombox.OnSelect := OnLineWeightSelect;


  FExtColorCombox             := TUdColorComboBox.Create(Self);
  FExtColorCombox.Parent      := gpbExtLines;
  FExtColorCombox.Left        := 105;
  FExtColorCombox.Top         := 22;
  FExtColorCombox.Width       := 150;
  FExtColorCombox.OnSelect    := OnColorSelect;
  FExtColorCombox.OnSelectOther := OnColorsAddOther;
  
  FExtLineType1Combox         := TUdLntypComboBox.Create(Self);
  FExtLineType1Combox.Parent  := gpbExtLines;
  FExtLineType1Combox.Left    := 105;
  FExtLineType1Combox.Top     := 52;
  FExtLineType1Combox.Width   := 150;
  FExtLineType1Combox.OnSelect      := OnLineTypeSelect;
  FExtLineType1Combox.OnSelectOther := OnLineTypesAddOther;
  
  FExtLineType2Combox         := TUdLntypComboBox.Create(Self);
  FExtLineType2Combox.Parent  := gpbExtLines;
  FExtLineType2Combox.Left    := 105;
  FExtLineType2Combox.Top     := 83;
  FExtLineType2Combox.Width   := 150;
  FExtLineType2Combox.OnSelect      := OnLineTypeSelect;
  FExtLineType2Combox.OnSelectOther := OnLineTypesAddOther;
  
  FExtLineWeightCombox        := TUdLwtComboBox.Create(Self);
  FExtLineWeightCombox.Parent := gpbExtLines;
  FExtLineWeightCombox.Left   := 105;
  FExtLineWeightCombox.Top    := 114;
  FExtLineWeightCombox.Width  := 150;
  FExtLineWeightCombox.OnSelect := OnLineWeightSelect;


  FTextColorCombox  := TUdColorComboBox.Create(nil);
  FTextColorCombox.Parent      := gpbTextAppearance;
  FTextColorCombox.Left        := 105;
  FTextColorCombox.Top         := 60;
  FTextColorCombox.Width       := 165;
  FTextColorCombox.OnSelect    := OnColorSelect;
  FTextColorCombox.OnSelectOther := OnColorsAddOther;

  FFillColorCombox  := TUdColorComboBox.Create(nil);
  FFillColorCombox.Parent      := gpbTextAppearance;
  FFillColorCombox.Left        := 105;
  FFillColorCombox.Top         := 95;
  FFillColorCombox.Width       := 120;
  FFillColorCombox.OnSelect    := OnColorSelect;
  FFillColorCombox.OnSelectOther := OnColorsAddOther;
  
  for I := Ord(dakClosedFilled) to Ord(dakNone) do
  begin
    LStr := UdDimProps.GetDimArrowName(TUdDimArrowKind(I), False);
    cbxArrowFirst.Items.Add(LStr);
    cbxArrowSecond.Items.Add(LStr);
    cbxArrowLeader.Items.Add(LStr);
  end;

  FCurrDimStyle := nil;
  FDimStyles := nil;
  FDocument := nil;
  FChanging := False;
end;

procedure TUdDimStylesForm.FormDestroy(Sender: TObject);
begin
  FDimColorCombox.Free;
  FDimLineTypeCombox.Free;
  FDimLineWeightCombox.Free;

  FExtColorCombox.Free;
  FExtLineType1Combox.Free;
  FExtLineType2Combox.Free;
  FExtLineWeightCombox.Free;

  FTextColorCombox.Free;
  FFillColorCombox.Free;

  FResDimArrows.Free;
  FResDimArrows := nil;

  if Assigned(FColors2) then FColors2.Free;
  FColors2 := nil;

  if Assigned(FLineTypes2) then FLineTypes2.Free;
  FLineTypes2 := nil;

  if Assigned(FLineWeights2) then FLineWeights2.Free;
  FLineWeights2 := nil;

  if Assigned(FDimStyles2) then FDimStyles2.Free;
  FDimStyles2 := nil;

  if Assigned(FEntities) then FEntities.Free;
  FEntities := nil;

  if Assigned(FEntities2) then FEntities2.Free;
  FEntities2 := nil;

  if Assigned(FAxes) then FAxes.Free;
  FAxes := nil;

  if Assigned(FDrawPanel) then FDrawPanel.Free;
  FDrawPanel := nil;

  FDimStyles := nil;
  FDocument := nil;  
end;

procedure TUdDimStylesForm.FormShow(Sender: TObject);
var
  LFileName: string;
  LCurrPath: string;
  LXmlDoc: TUdXMLDocument;
begin
  pnlPreview.BringToFront();

  LCurrPath := SysUtils.ExtractFilePath(Application.ExeName);
  LFileName := LCurrPath + DIM_SAMPLE_FILE;
  
  if not SysUtils.FileExists(LFileName) then
    LFileName := LCurrPath + 'Data\' + DIM_SAMPLE_FILE;

  if FileExists(LFileName) then
  begin
    LXmlDoc := TUdXMLDocument.Create();
    try
      LXmlDoc.LoadFromFile(LFileName);
      FEntities.LoadFromXml(LXmlDoc.Root);
    finally
      LXmlDoc.Free;
    end;
  end;

  FDrawPanel.Cursor := 0;
  Self.UpdatePrivewDim();
end;



//---------------------------------------------------------------------------------------------


procedure TUdDimStylesForm.UpdatePrivewDim();
var
  I, J: Integer;
  LBase: TPoint2D;
  LBound: TRect2D;
  LFactor: Double;
  LEntity, LEntity2: TUdEntity;
begin
  if not Assigned(FCurrDimStyle) then Exit;

  FEntities2.Clear();

  for I := 0 to FEntities.Count - 1 do
  begin
    LEntity := FEntities.Items[I];
    LEntity2 := LEntity.Clone();
    FEntities2.Add(LEntity2);
  end;

  LFactor := FCurrDimStyle.OverallScale;

  if (LFactor < 2) then
    if (FCurrDimStyle.TextProp.TextHeight > 5) then
      LFactor := FCurrDimStyle.TextProp.TextHeight / 2.5;

  if LFactor >= 2 then
  begin
    LBase.X := 0;
    LBase.Y := 0;
    
    for I := 0 to FEntities2.Count - 1 do
    begin
      LEntity := FEntities2.Items[I];
      LEntity.Scale(LBase, LFactor);
    end;
  end;
  
  for I := 0 to FEntities2.Count - 1 do
  begin
    LEntity := FEntities2.Items[I];
    LEntity.SetDocument(FDocument, False);
    
    if LEntity.InheritsFrom(TUdDimension) then
    begin
      TUdDimension(LEntity).DimStyle := nil;
      TUdDimension(LEntity).DimStyle := FCurrDimStyle;
      
      LEntity.Update(FAxes);
      for J := 0 to TUdDimension(LEntity).EntityList.Count - 1 do
      begin
        LEntity2 := TUdEntity(TUdDimension(LEntity).EntityList[J]);
        LEntity2.Update(FAxes);
      end;
        
      TFEntity(LEntity).FBoundsRect := UdUtils.GetEntitiesBound(TUdDimension(LEntity).EntityList);
    end
    else
      LEntity.Update(FAxes);
  end;
  LBound := UdUtils.GetEntitiesBound(FEntities2.List);

  LBound.X1 := LBound.X1 + 3;  LBound.X2 := LBound.X2 - 6;
  LBound.Y1 := LBound.Y1 + 8;  LBound.Y2 := LBound.Y2 - 6;

  FAxes.CalcAxis(pnlPreview.Width, pnlPreview.Height, LBound);
  FDrawPanel.Invalidate();
end;





procedure TUdDimStylesForm.OnColorsAddOther(Sender: TObject);
var
  N: Integer;
  LColor: TUdColor;
  LAdded: Boolean;
  LValue: Integer;
  LForm: TUdColorsForm;
begin
  LForm := TUdColorsForm.Create(nil);
  try
    if LForm.ShowModal() = mrOk then
    begin
      N := -1;
      LAdded := False;
      LValue := LForm.ColorValue;

      if LForm.IsIndexColor then
      begin
        if (LValue > 0) and (LValue <= 255) then // -1: Error  0: ByBlock  256: ByLayer
        begin
          N := FColors2.IndexOf(LValue, ctIndexColor);
          if N < 2 then
          begin
            FColors2.Add(Byte(LValue));
            LAdded := True;
          end;
        end
        else begin
          case LValue of
            0  : N := 1;  //ByBlock
            256: N := 0;  //ByLayer
          end;
        end;
      end
      else begin
        N := FColors2.IndexOf(LValue, ctTrueColor);
        if N < 2 then
        begin
          FColors2.Add(TColor(LValue));
          LAdded := True;
        end;
      end;


      LColor := FColors2.Items[FColors2.Count - 1];
      LColor.Status := STATUS_NEW;

      if N > 0 then ;

      if LAdded then
      begin
        if Sender = FDimColorCombox  then FCurrDimStyle.LinesProp.Color.Assign(LColor) else
        if Sender = FExtColorCombox  then FCurrDimStyle.LinesProp.ExtColor.Assign(LColor) else
        if Sender = FTextColorCombox then FCurrDimStyle.TextProp.TextColor.Assign(LColor) else
        if Sender = FFillColorCombox then FCurrDimStyle.TextProp.FillColor.Assign(LColor);

        FDimColorCombox.Colors := FColors2;
        FExtColorCombox.Colors := FColors2;
        FTextColorCombox.Colors := FColors2;
        FFillColorCombox.Colors := FColors2;

        FDimColorCombox._SetItem(FCurrDimStyle.LinesProp.Color);
        FExtColorCombox._SetItem(FCurrDimStyle.LinesProp.ExtColor);
        FTextColorCombox._SetItem(FCurrDimStyle.TextProp.TextColor);
        if FCurrDimStyle.TextProp.FillColor.ColorType <> ctNone then
          FFillColorCombox._SetItem(FCurrDimStyle.TextProp.FillColor);

        Self.UpdatePrivewDim();
      end;
    end;
  finally
    LForm.Free;
  end;
end;

procedure TUdDimStylesForm.OnLineTypesAddOther(Sender: TObject);
var
  LForm: TUdLineTypesForm;
begin
  LForm := TUdLineTypesForm.Create(nil);
  try
    LForm.ManageMode := False;
    LForm.LineTypes := FLineTypes2;
    if LForm.ShowModal() = mrOk then
    begin
      if FLineTypes2.IndexOf(LForm.SelectedItem.Name) <= 0 then
      begin
        FLineTypes2.Add(LForm.SelectedItem.Name);
        FLineTypes2.Items[FLineTypes2.Count - 1].Status := STATUS_NEW;
        
        if Sender = FDimLineTypeCombox  then FCurrDimStyle.LinesProp.LineType.Assign(LForm.SelectedItem) else
        if Sender = FExtLineType1Combox then FCurrDimStyle.LinesProp.ExtLineType1.Assign(LForm.SelectedItem) else
        if Sender = FExtLineType2Combox then FCurrDimStyle.LinesProp.ExtLineType1.Assign(LForm.SelectedItem);

        FDimLineTypeCombox.LineTypes := FLineTypes2;
        FExtLineType1Combox.LineTypes := FLineTypes2;
        FExtLineType1Combox.LineTypes := FLineTypes2;

        FDimLineTypeCombox._SetItem(FCurrDimStyle.LinesProp.LineType);
        FExtLineType1Combox._SetItem(FCurrDimStyle.LinesProp.ExtLineType1);
        FExtLineType2Combox._SetItem(FCurrDimStyle.LinesProp.ExtLineType2);

        Self.UpdatePrivewDim();
      end;
    end;
  finally
    LForm.Free;
  end;
end;

procedure TUdDimStylesForm.OnDrawPanelPaint(Sender: TObject; ACanvas: TCanvas);
var
  I: Integer;
  LEntity: TUdEntity;
begin
  for I := 0 to FEntities2.Count - 1 do
  begin
    LEntity := FEntities2.Items[I];
    LEntity.Draw(ACanvas, FAxes);
  end;
end;


procedure TUdDimStylesForm.OnColorSelect(Sender: TObject);
var
  LColor: TUdColor;
begin
  if FChanging then Exit; //=====>>>>>
  
  LColor := nil;
  if Assigned(Sender) and Sender.InheritsFrom(TUdColorComboBox) then
    LColor := FColors2.Items[ TUdColorComboBox(Sender).ItemIndex ];

  if Assigned(LColor) then
  begin
    if Sender = FDimColorCombox  then FCurrDimStyle.LinesProp.Color.Assign(LColor) else
    if Sender = FExtColorCombox  then FCurrDimStyle.LinesProp.ExtColor.Assign(LColor) else
    if Sender = FTextColorCombox then FCurrDimStyle.TextProp.TextColor.Assign(LColor) else
    if Sender = FFillColorCombox then FCurrDimStyle.TextProp.FillColor.Assign(LColor);

    Self.UpdatePrivewDim();
  end;
end;

procedure TUdDimStylesForm.OnLineTypeSelect(Sender: TObject);
var
  LLineType: TUdLineType;
begin
  if FChanging then Exit; //=====>>>>>
  
  LLineType := nil;
  if Assigned(Sender) and Sender.InheritsFrom(TUdLntypComboBox) then
    LLineType := FLineTypes2.Items[ TUdLntypComboBox(Sender).ItemIndex ];

  if Assigned(LLineType) then
  begin
    if Sender = FDimLineTypeCombox  then FCurrDimStyle.LinesProp.LineType.Assign(LLineType) else
    if Sender = FExtLineType1Combox then FCurrDimStyle.LinesProp.ExtLineType1.Assign(LLineType) else
    if Sender = FExtLineType2Combox then FCurrDimStyle.LinesProp.ExtLineType1.Assign(LLineType);

    Self.UpdatePrivewDim();
  end;
end;

procedure TUdDimStylesForm.OnLineWeightSelect(Sender: TObject);
var
  LLineType: TUdLineType;
begin
  if FChanging then Exit; //=====>>>>>
  
  LLineType := nil;
  if Assigned(Sender) and Sender.InheritsFrom(TUdLntypComboBox) then
    LLineType := FLineTypes2.Items[ TUdLntypComboBox(Sender).ItemIndex ];

  if Assigned(LLineType) then
  begin
    if Sender = FDimLineTypeCombox  then FCurrDimStyle.LinesProp.LineType.Assign(LLineType) else
    if Sender = FExtLineType1Combox then FCurrDimStyle.LinesProp.ExtLineType1.Assign(LLineType) else
    if Sender = FExtLineType2Combox then FCurrDimStyle.LinesProp.ExtLineType1.Assign(LLineType);

    Self.UpdatePrivewDim();
  end;
end;



procedure TUdDimStylesForm.InitPrecisionCombox(AComboBox: TComboBox; AUnit: TUdLengthUnit; APrecision: Byte);
var
  I: Integer;
begin
  AComboBox.Items.Clear();
  for I := 0 to 8 do
    AComboBox.Items.Add(RToS(0, AUnit, I));
  AComboBox.ItemIndex := APrecision;
end;

procedure TUdDimStylesForm.InitPrecisionCombox(AComboBox: TComboBox; AUnit: TUdAngleUnit; APrecision: Byte);
var
  I: Integer;
begin
  AComboBox.Items.Clear();
  for I := 0 to 8 do
    AComboBox.Items.Add(AngToS(0, AUnit, I));
  AComboBox.ItemIndex := APrecision;
end;




//---------------------------------------------------------------------------------------------

procedure TUdDimStylesForm.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePageIndex = 0 then
  begin
    pnlPreview.Left := 200;
    pnlPreview.Top  := PageControl1.Top + 85;
  end
  else begin
    pnlPreview.Left := 305;
    pnlPreview.Top  := PageControl1.Top + 32;
  end;

  //Alternate Units
  if PageControl1.ActivePageIndex = 6 then
  begin

  end;
end;







procedure TUdDimStylesForm.cbxDimArrowDrawItem(AControl: TWinControl; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
var
  LItem: string;
  LBitmap: TBitmap;
  LRect: TRect;
  LBackground: TColor;
  LCanvas: TCanvas;
begin
  LCanvas := nil;
  if AControl.InheritsFrom(TComboBox) then
  begin
    LCanvas := TComboBox(AControl).Canvas;
    if AIndex >= 0 then LItem := TComboBox(AControl).Items[AIndex];
  end;

  if not Assigned(LCanvas) then Exit; //======>>>>

  if AIndex >= 0 then
  begin
    LCanvas.FillRect(ARect);
    LBackground := LCanvas.Brush.Color;

    LBitmap := FResDimArrows.GetBitmap(LItem);
    if Assigned(LBitmap) then LCanvas.Draw(ARect.Left + 2, ARect.Top + 1, LBitmap);
    
    LCanvas.Brush.Color := LBackground;

    LRect := ARect;
    LRect.Left := LRect.Left + 20;

    LCanvas.TextRect(LRect, LRect.Left,
      LRect.Top + (LRect.Bottom - LRect.Top - LCanvas.TextHeight(LItem)) div 2, LItem);
  end;
end;


//--------------------------------------------------------------------------------------------

procedure TUdDimStylesForm.SetCurrDimStyle(const AValue: TUdDimStyle);
var
  I, N: Integer;
begin
  if FCurrDimStyle = AValue then Exit;

  FCurrDimStyle := AValue;

  FChanging := True;
  try
    FDimColorCombox._SetItem(FCurrDimStyle.LinesProp.Color);
    FDimLineTypeCombox._SetItem(FCurrDimStyle.LinesProp.LineType);
    FDimLineWeightCombox._SetItem(FCurrDimStyle.LinesProp.LineWeight);
    edtExtBeyondTicks.Text := FloatToStr(FCurrDimStyle.LinesProp.ExtBeyondTicks);
    edtBaselineSpacing.Text := FloatToStr(FCurrDimStyle.LinesProp.BaselineSpacing);
    ckbSuppressLine1.Checked := FCurrDimStyle.LinesProp.SuppressLine1;
    ckbSuppressLine2.Checked := FCurrDimStyle.LinesProp.SuppressLine2;
    FExtColorCombox._SetItem(FCurrDimStyle.LinesProp.ExtColor);
    FExtLineType1Combox._SetItem(FCurrDimStyle.LinesProp.ExtLineType1);
    FExtLineType2Combox._SetItem(FCurrDimStyle.LinesProp.ExtLineType2);
    FExtLineWeightCombox._SetItem(FCurrDimStyle.LinesProp.ExtLineWeight);
    edtExtBeyondDimLines.Text := FloatToStr(FCurrDimStyle.LinesProp.ExtBeyondDimLines);
    edtOffsetFromDimLine.Text := FloatToStr(FCurrDimStyle.LinesProp.ExtOriginOffset);
    ckbExtSuppressLine1.Checked := FCurrDimStyle.LinesProp.ExtSuppressLine1;
    ckbExtSuppressLine2.Checked := FCurrDimStyle.LinesProp.ExtSuppressLine2;

    cbxArrowFirst.ItemIndex := Ord(FCurrDimStyle.ArrowsProp.ArrowFirst);
    cbxArrowSecond.ItemIndex := Ord(FCurrDimStyle.ArrowsProp.ArrowSecond);
    cbxArrowLeader.ItemIndex := Ord(FCurrDimStyle.ArrowsProp.ArrowLeader);
    edtArrowSize.Text := FloatToStr(FCurrDimStyle.ArrowsProp.ArrowSize);
    edtMarkSize.Text := FloatToStr(FCurrDimStyle.ArrowsProp.MarkSize);
    case FCurrDimStyle.ArrowsProp.CenterMark of
      ckCenterNone: rdbCenterNone.Checked := True;
      ckCenterMark: rdbCenterMark.Checked := True;
      ckCenterLine: rdbCenterLine.Checked := True;
    end;
    case FCurrDimStyle.ArrowsProp.ArcLenSymbolPos of  //spSymNone , spSymInFront, spSymAbove
      spSymNone   : rdbSymInFront.Checked := True;
      spSymInFront: rdbSymAbove.Checked := True;
      spSymAbove  : rdbSymNone.Checked := True;
    end;



    N := -1;
    for I := 0 to cbxTextStyle.Items.Count - 1 do
    begin
      if UpperCase(cbxTextStyle.Items[I]) = UpperCase(FCurrDimStyle.TextProp.TextStyle) then
      begin
        N := I;
        Break;
      end;
    end;
    if N < 0 then N := 0;
    cbxTextStyle.ItemIndex := N;

    FTextColorCombox._SetItem(FCurrDimStyle.TextProp.TextColor);
    if FFillColorCombox._SetItem(FCurrDimStyle.TextProp.FillColor) then
    begin
      ckbNoneColor.Checked := False;
    end
    else begin
      FFillColorCombox.ItemIndex := -1;
      FFillColorCombox.Enabled := False;
      ckbNoneColor.Checked := True;
    end;

    edtTextHeight.Text := FloatToStr(FCurrDimStyle.TextProp.TextHeight);
    ckbDrawFrame.Checked := FCurrDimStyle.TextProp.DrawFrame;
    cbxVerticalPosition.ItemIndex := Ord(FCurrDimStyle.TextProp.VerticalPosition);
    cbxHorizontalPosition.ItemIndex := Ord(FCurrDimStyle.TextProp.HorizontalPosition);
    edtOffsetFromDimLine.Text := FloatToStr(FCurrDimStyle.TextProp.OffsetFromDimLine);
    { TextAlignment:
        Horizontal           :  FInsideAlign := False  FOutsideAlign = False
        Aligned with dim line:  FInsideAlign := True   FOutsideAlign = True
        ISO Standard         :  FInsideAlign := True   FOutsideAlign = False
    }
    if FCurrDimStyle.TextProp.InsideAlign and not FCurrDimStyle.TextProp.OutsideAlign then
      rdbTextAlignISOStandard.Checked := True
    else if not FCurrDimStyle.TextProp.InsideAlign and not FCurrDimStyle.TextProp.OutsideAlign then
      rdbTextAlignHorizontal.Checked := True
    else
      rdbTextAlignWithDimLine.Checked := True;


    edtOverallScale.Text := FloatToStr(FCurrDimStyle.OverallScale);


    cbxUnitFormat.ItemIndex := Ord(FCurrDimStyle.UnitsProp.UnitFormat);
    InitPrecisionCombox(cbxPrecision, FCurrDimStyle.UnitsProp.UnitFormat, FCurrDimStyle.UnitsProp.Precision);
    cbxDecimal.ItemIndex := cbxDecimal.Items.IndexOf(FCurrDimStyle.UnitsProp.Decimal);
    edtRoundOff.Text := FloatToStr(FCurrDimStyle.UnitsProp.RoundOff);
    edtPrefix.Text := FCurrDimStyle.UnitsProp.Prefix;
    edtSuffix.Text := FCurrDimStyle.UnitsProp.Suffix;
    edtMeasurementScale.Text := FloatToStr(FCurrDimStyle.UnitsProp.MeasurementScale);
    ckbSuppressLeading.Checked := FCurrDimStyle.UnitsProp.SuppressLeading;
    ckbSuppressTrailing.Checked := FCurrDimStyle.UnitsProp.SuppressTrailing;

    cbxAngUnitFormat.ItemIndex := Ord(FCurrDimStyle.UnitsProp.AngUnitFormat);
    InitPrecisionCombox(cbxAngPrecision, FCurrDimStyle.UnitsProp.AngUnitFormat, FCurrDimStyle.UnitsProp.AngPrecision);
    ckbAngSuppressLeading.Checked := FCurrDimStyle.UnitsProp.AngSuppressLeading;
    ckbAngSuppressTrailing.Checked := FCurrDimStyle.UnitsProp.AngSuppressTrailing;



    ckbDispAltUnits.Checked := FCurrDimStyle.DispAltUnits;

    cbxAltUnitFormat.ItemIndex := Ord(FCurrDimStyle.AltUnitsProp.UnitFormat);
    InitPrecisionCombox(cbxAltPrecision, FCurrDimStyle.AltUnitsProp.UnitFormat, FCurrDimStyle.AltUnitsProp.Precision);
    edtAltMultiplier.Text := FloatToStr(FCurrDimStyle.AltUnitsProp.MeasurementScale);
    edtAltRoundDis.Text := FloatToStr(FCurrDimStyle.AltUnitsProp.RoundOff);
    edtAltPrefix.Text := FCurrDimStyle.AltUnitsProp.Prefix;
    edtAltSuffix.Text := FCurrDimStyle.AltUnitsProp.Suffix;
    ckbAltSuppressLeading.Checked := FCurrDimStyle.AltUnitsProp.SuppressLeading;
    ckbAltSuppressTrailing.Checked := FCurrDimStyle.AltUnitsProp.SuppressTrailing;
    case FCurrDimStyle.AltUnitsProp.AltPlacement of
      apAfterPrimary: rdbAltAfter.Checked := True;
      apBelowPrimary: rdbAltBelow.Checked := True;
    end;

    edtStyleName.Text := FCurrDimStyle.Name;
    edtStyleName.Enabled := FDimStyles2.IndexOf(FCurrDimStyle) > 0;
  finally
    FChanging := False;
  end;

  Self.UpdatePrivewDim();
end;

procedure TUdDimStylesForm.SetDimStyles(const AValue: TUdDimStyles);
var
  I: Integer;
  LDimStyle: TUdDimStyle;
begin
  FDocument := nil;
  FDimStyles := AValue;

  if Assigned(FDimStyles) and Assigned(FDimStyles.Document) then
  begin
    FDocument := TUdDocument(FDimStyles.Document);
    FDocument.UpdateDimTypesStatus();

    FColors2.Assign(FDocument.Colors);
    for I := 0 to FDocument.Colors.Count - 1 do TFObject(FColors2.Items[I]).SetID(FDocument.Colors.Items[I].ID);

    FLineTypes2.Assign(FDocument.LineTypes);
    for I := 0 to FDocument.LineTypes.Count - 1 do TFObject(FLineTypes2.Items[I]).SetID(FDocument.LineTypes.Items[I].ID);
    
    FDimStyles2.Assign(FDimStyles);
    for I := 0 to FDocument.DimStyles.Count - 1 do TFObject(FDimStyles2.Items[I]).SetID(FDocument.DimStyles.Items[I].ID);

    FDimColorCombox.Colors           := FColors2;
    FDimLineTypeCombox.LineTypes     := FLineTypes2;
    FDimLineWeightCombox.LineWeights := FLineWeights2;

    FExtColorCombox.Colors           := FColors2;
    FExtLineType1Combox.LineTypes    := FLineTypes2;
    FExtLineType2Combox.LineTypes    := FLineTypes2;
    FExtLineWeightCombox.LineWeights := FLineWeights2;


    FTextColorCombox.Colors := FColors2;
    FFillColorCombox.Colors := FColors2;

    for I := 0 to FDocument.TextStyles.Count - 1 do
      cbxTextStyle.Items.AddObject(FDocument.TextStyles.Items[I].Name, FDocument.TextStyles.Items[I]);
      
  end;

  ltbDimStyles.Clear();
  for I := 0 to FDimStyles2.Count - 1 do
  begin
    LDimStyle := FDimStyles2.Items[I];
    ltbDimStyles.AddItem(LDimStyle.Name, LDimStyle);
  end;

  I := FDimStyles.GetActiveIndex();
  if I >= 0 then
  begin
    ltbDimStyles.Selected[I] := True;
    Self.SetCurrDimStyle(FDimStyles2.Items[I]);

    lblCurrStyle.Caption := FDimStyles2.Items[I].Name;
  end;
end;







//===========================================================================================

procedure TUdDimStylesForm.edtDimStyleLinesPropChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  if TryStrToFloat(TEdit(Sender).Text, LVal) and (LVal >= 0) then
  begin
    case TComponent(Sender).Tag of
      0: FCurrDimStyle.LinesProp.ExtBeyondTicks    := LVal;
      1: FCurrDimStyle.LinesProp.BaselineSpacing   := LVal;
      2: FCurrDimStyle.LinesProp.ExtBeyondDimLines := LVal;
      3: FCurrDimStyle.LinesProp.ExtOriginOffset   := LVal;
    end;

    Self.UpdatePrivewDim();
  end;
end;



procedure TUdDimStylesForm.udnDimStyleLinesPropChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  LVal := 0;
  AllowChange := False;
  
  case TComponent(Sender).Tag of
    0: LVal := FCurrDimStyle.LinesProp.ExtBeyondTicks   ;
    1: LVal := FCurrDimStyle.LinesProp.BaselineSpacing  ;
    2: LVal := FCurrDimStyle.LinesProp.ExtBeyondDimLines;
    3: LVal := FCurrDimStyle.LinesProp.ExtOriginOffset  ;
  end;

  if Direction = updUp then
    LVal := LVal + 0.005
  else
    LVal := LVal - 0.005;

  if LVal < 0 then LVal := 0;

  case TComponent(Sender).Tag of
    0: begin FCurrDimStyle.LinesProp.ExtBeyondTicks    := LVal; edtExtBeyondTicks.Text    := FloatToStr(LVal); end;
    1: begin FCurrDimStyle.LinesProp.BaselineSpacing   := LVal; edtBaselineSpacing.Text   := FloatToStr(LVal); end;
    2: begin FCurrDimStyle.LinesProp.ExtBeyondDimLines := LVal; edtExtBeyondDimLines.Text := FloatToStr(LVal); end;
    3: begin FCurrDimStyle.LinesProp.ExtOriginOffset   := LVal; edtExtOriginOffset.Text   := FloatToStr(LVal); end;
  end;

  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.ckbDimStyleLinesPropSuppressClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>
  
  case TComponent(Sender).Tag of
    0: FCurrDimStyle.LinesProp.SuppressLine1    := TCheckBox(Sender).Checked;
    1: FCurrDimStyle.LinesProp.SuppressLine2    := TCheckBox(Sender).Checked;
    2: FCurrDimStyle.LinesProp.ExtSuppressLine1 := TCheckBox(Sender).Checked;
    3: FCurrDimStyle.LinesProp.ExtSuppressLine2 := TCheckBox(Sender).Checked;
  end;

  Self.UpdatePrivewDim();
end;






//-----------------------------------------------------------------------------------------

procedure TUdDimStylesForm.cbxDimStyleArrowKindChange(Sender: TObject);
var
  LKind: TUdDimArrowKind;
begin
  if FChanging then Exit; //=====>>>>>

  LKind := TUdDimArrowKind(TComboBox(Sender).ItemIndex);
  
  case TComponent(Sender).Tag of
    0: FCurrDimStyle.ArrowsProp.ArrowFirst  := LKind;
    1: FCurrDimStyle.ArrowsProp.ArrowSecond := LKind;
    2: FCurrDimStyle.ArrowsProp.ArrowLeader := LKind;
  end;

  Self.UpdatePrivewDim();
end;




procedure TUdDimStylesForm.edtArrowSizeChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  if TryStrToFloat(edtArrowSize.Text, LVal) and (LVal >= 0) then
  begin
    FCurrDimStyle.ArrowsProp.ArrowSize := LVal;
    Self.UpdatePrivewDim();
  end;
end;

procedure TUdDimStylesForm.udnArrowSizeChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  AllowChange := False;
  
  LVal := FCurrDimStyle.ArrowsProp.ArrowSize;

  if Direction = updUp then
    LVal := LVal + 0.005
  else
    LVal := LVal - 0.005;

  if LVal < 0 then LVal := 0;

  FCurrDimStyle.ArrowsProp.ArrowSize := LVal;
  edtArrowSize.Text := FloatToStr(LVal);

  Self.UpdatePrivewDim();
end;



procedure TUdDimStylesForm.edtMarkSizeChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  if TryStrToFloat(edtMarkSize.Text, LVal) and (LVal >= 0) then
    FCurrDimStyle.ArrowsProp.MarkSize := LVal;
end;


procedure TUdDimStylesForm.udnMarkSizeChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  AllowChange := False;
  
  LVal := FCurrDimStyle.ArrowsProp.MarkSize;

  if Direction = updUp then
    LVal := LVal + 0.005
  else
    LVal := LVal - 0.005;

  if LVal < 0 then LVal := 0;

  FCurrDimStyle.ArrowsProp.MarkSize := LVal;
  edtMarkSize.Text := FloatToStr(LVal);
end;




procedure TUdDimStylesForm.rdbArcLengthSymbolClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>
  
  //spSymNone , spSymInFront, spSymAbove
  FCurrDimStyle.ArrowsProp.ArcLenSymbolPos := TUdSymbolPosition(TComponent(Sender).Tag);
end;





//-----------------------------------------------------------------------------------------


procedure TUdDimStylesForm.cbxTextStyleSelect(Sender: TObject);
var
  LTextStyle: string;
begin
  if FChanging then Exit; //=====>>>>>

  if cbxTextStyle.ItemIndex >= 0 then
  begin
    LTextStyle := cbxTextStyle.Text;
    FCurrDimStyle.TextProp.TextStyle := LTextStyle;

    Self.UpdatePrivewDim();
  end;
end;



procedure TUdDimStylesForm.btnTextStyleClick(Sender: TObject);
var
  I, N: Integer;
begin
  if UdTextStylesFrm.ShowTextStylesDialog(FDocument.TextStyles) then
  begin
    cbxTextStyle.Clear();

    N := -1;
    for I := 0 to FDocument.TextStyles.Count - 1 do
    begin
      cbxTextStyle.Items.AddObject(FDocument.TextStyles.Items[I].Name, FDocument.TextStyles.Items[I]);
      if (N < 0) and
         (UpperCase(FDocument.TextStyles.Items[I].Name) = UpperCase(FCurrDimStyle.TextProp.TextStyle)) then
        N := I;
    end;

    if N < 0 then
    begin
      N := 0;
      FCurrDimStyle.TextProp.TextStyle := FDocument.TextStyles.Standard.Name;
    end;

    cbxTextStyle.ItemIndex := N;
  end;
end;



procedure TUdDimStylesForm.ckbNoneColorClick(Sender: TObject);
var
  LColor: TUdColor;
begin
  if FChanging then Exit; //=====>>>>>
  
  if ckbNoneColor.Checked then
  begin
    FFillColorCombox.ItemIndex := -1;
    FFillColorCombox.Enabled := False;
    
    FCurrDimStyle.TextProp.FillColor.ColorType := ctNone;
  end
  else begin
    FFillColorCombox.Enabled := True;
    FFillColorCombox.ItemIndex := 2;

    LColor := FColors2.Items[ FFillColorCombox.ItemIndex ];
    FCurrDimStyle.TextProp.FillColor.Assign(LColor);
  end;

  Self.UpdatePrivewDim();
end;



procedure TUdDimStylesForm.edtTextHeightChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  if TryStrToFloat(edtTextHeight.Text, LVal) and (LVal >= 0) then
  begin
    FCurrDimStyle.TextProp.TextHeight := LVal;
    Self.UpdatePrivewDim();
  end;
end;

procedure TUdDimStylesForm.udnTextHeightChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  AllowChange := False;

  LVal := FCurrDimStyle.TextProp.TextHeight;

  if Direction = updUp then
    LVal := LVal + 0.05
  else
    LVal := LVal - 0.05;

  if LVal < 0 then LVal := 0;

  FCurrDimStyle.TextProp.TextHeight := LVal;
  edtTextHeight.Text := FloatToStr(LVal);
  
  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.ckbDrawFrameClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>
  
  FCurrDimStyle.TextProp.DrawFrame := ckbDrawFrame.Checked;
  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.cbxVerticalPositionSelect(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>
  
  FCurrDimStyle.TextProp.VerticalPosition := TUdVerticalTextPoint(cbxVerticalPosition.ItemIndex);
  Self.UpdatePrivewDim();
end;

procedure TUdDimStylesForm.cbxHorizontalPositionSelect(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>
  
  FCurrDimStyle.TextProp.HorizontalPosition := TUdHorizontalTextPoint(cbxHorizontalPosition.ItemIndex);
  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.edtOffsetFromDimLineChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>

  if TryStrToFloat(edtOffsetFromDimLine.Text, LVal) and (LVal >= 0) then
  begin
    FCurrDimStyle.TextProp.OffsetFromDimLine := LVal;
    Self.UpdatePrivewDim();
  end;
end;


procedure TUdDimStylesForm.udnOffsetFromDimLineChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  AllowChange := False;

  LVal := FCurrDimStyle.TextProp.OffsetFromDimLine;

  if Direction = updUp then
    LVal := LVal + 0.005
  else
    LVal := LVal - 0.005;

  if LVal < 0 then LVal := 0;

  FCurrDimStyle.TextProp.OffsetFromDimLine := LVal;
  edtOffsetFromDimLine.Text := FloatToStr(LVal);
  
  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.rdbTextAlignmentClick(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    0: begin FCurrDimStyle.TextProp.InsideAlign := False; FCurrDimStyle.TextProp.OutsideAlign := False; end;
    1: begin FCurrDimStyle.TextProp.InsideAlign := True;  FCurrDimStyle.TextProp.OutsideAlign := True;  end;
    2: begin FCurrDimStyle.TextProp.InsideAlign := True;  FCurrDimStyle.TextProp.OutsideAlign := False; end;
  end;
end;




//-----------------------------------------------------------------------------------------


procedure TUdDimStylesForm.edtOverallScaleChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>

  if TryStrToFloat(edtOverallScale.Text, LVal) and (LVal >= 0) then
  begin
    FCurrDimStyle.OverallScale := LVal;
    Self.UpdatePrivewDim();
  end;
end;


procedure TUdDimStylesForm.udnOverallScaleChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  AllowChange := False;

  LVal := FCurrDimStyle.OverallScale;

  if Direction = updUp then
    LVal := LVal + 0.005
  else
    LVal := LVal - 0.005;

  if LVal < 0 then LVal := 0;

  FCurrDimStyle.OverallScale := LVal;
  edtOverallScale.Text := FloatToStr(LVal);
  
  Self.UpdatePrivewDim();
end;




//-----------------------------------------------------------------------------------------

procedure TUdDimStylesForm.cbxUnitFormatSelect(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.UnitFormat := TUdLengthUnit(cbxUnitFormat.ItemIndex);
  Self.UpdatePrivewDim();

  InitPrecisionCombox(cbxPrecision, FCurrDimStyle.UnitsProp.UnitFormat, FCurrDimStyle.UnitsProp.Precision);
end;

procedure TUdDimStylesForm.cbxPrecisionSelect(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.Precision := cbxPrecision.ItemIndex;
  Self.UpdatePrivewDim();  
end;


procedure TUdDimStylesForm.cbxDecimalSelect(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  case cbxDecimal.ItemIndex of
    0: FCurrDimStyle.UnitsProp.Decimal := '.';
    1: FCurrDimStyle.UnitsProp.Decimal := ',';
    2: FCurrDimStyle.UnitsProp.Decimal := ' ';
  end;
  
  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.edtRoundOffChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>

  if TryStrToFloat(edtRoundOff.Text, LVal) and (LVal >= 0) then
  begin
    FCurrDimStyle.UnitsProp.RoundOff := LVal;
    Self.UpdatePrivewDim();
  end;
end;


procedure TUdDimStylesForm.udnRoundOffChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  AllowChange := False;

  LVal := FCurrDimStyle.UnitsProp.RoundOff;

  if Direction = updUp then
    LVal := LVal + 0.005
  else
    LVal := LVal - 0.005;

  if LVal < 0 then LVal := 0;

  FCurrDimStyle.UnitsProp.RoundOff := LVal;
  edtRoundOff.Text := FloatToStr(LVal);
  
  Self.UpdatePrivewDim();
end;



procedure TUdDimStylesForm.edtPrefixChange(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.Prefix := edtPrefix.Text;
  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.edtSuffixChange(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.Suffix := edtSuffix.Text;
  Self.UpdatePrivewDim();
end;




procedure TUdDimStylesForm.edtMeasurementScaleChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>

  if TryStrToFloat(edtMeasurementScale.Text, LVal) and (LVal >= 0) then
  begin
    FCurrDimStyle.UnitsProp.MeasurementScale := LVal;
    Self.UpdatePrivewDim();
  end;
end;


procedure TUdDimStylesForm.udnMeasurementScaleChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>

  AllowChange := False;

  LVal := FCurrDimStyle.UnitsProp.MeasurementScale;

  if Direction = updUp then
    LVal := LVal + 0.005
  else
    LVal := LVal - 0.005;

  if LVal < 0 then LVal := 0;

  FCurrDimStyle.UnitsProp.MeasurementScale := LVal;
  edtMeasurementScale.Text := FloatToStr(LVal);
  
  Self.UpdatePrivewDim();
end;

procedure TUdDimStylesForm.ckbSuppressLeadingClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.SuppressLeading := ckbSuppressLeading.Checked;
  Self.UpdatePrivewDim();
end;

procedure TUdDimStylesForm.ckbSuppressTrailingClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.SuppressTrailing := ckbSuppressTrailing.Checked;
  Self.UpdatePrivewDim();
end;




procedure TUdDimStylesForm.cbxAngUnitFormatSelect(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.AngUnitFormat := TUdAngleUnit(cbxAngUnitFormat.ItemIndex);
  Self.UpdatePrivewDim();

  InitPrecisionCombox(cbxAngPrecision, FCurrDimStyle.UnitsProp.AngUnitFormat, FCurrDimStyle.UnitsProp.AngPrecision);
end;



procedure TUdDimStylesForm.cbxAngPrecisionSelect(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.AngPrecision := cbxAngPrecision.ItemIndex;
  Self.UpdatePrivewDim();  
end;




procedure TUdDimStylesForm.ckbAngSuppressLeadingClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.AngSuppressLeading := ckbAngSuppressLeading.Checked;
  Self.UpdatePrivewDim();
end;

procedure TUdDimStylesForm.ckbAngSuppressTrailingClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.UnitsProp.AngSuppressTrailing := ckbAngSuppressTrailing.Checked;
  Self.UpdatePrivewDim();
end;





//-----------------------------------------------------------------------------------------------

procedure TUdDimStylesForm.ckbDispAltUnitsClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.DispAltUnits := ckbDispAltUnits.Checked;
  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.cbxAltUnitFormatSelect(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.AltUnitsProp.UnitFormat := TUdLengthUnit(cbxAltUnitFormat.ItemIndex);
  Self.UpdatePrivewDim();

  InitPrecisionCombox(cbxAltPrecision, FCurrDimStyle.AltUnitsProp.UnitFormat, FCurrDimStyle.AltUnitsProp.Precision);
end;


procedure TUdDimStylesForm.cbxAltPrecisionSelect(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.AltUnitsProp.Precision := cbxAltPrecision.ItemIndex;
  Self.UpdatePrivewDim();
end;



procedure TUdDimStylesForm.edtAltMultiplierChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>

  if TryStrToFloat(edtAltMultiplier.Text, LVal) and (LVal >= 0) then
  begin
    FCurrDimStyle.AltUnitsProp.MeasurementScale := LVal;
    Self.UpdatePrivewDim();
  end;
end;

procedure TUdDimStylesForm.udnedtAltMultiplierChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>
  
  AllowChange := False;

  LVal := FCurrDimStyle.AltUnitsProp.MeasurementScale;

  if Direction = updUp then
    LVal := LVal + 0.005
  else
    LVal := LVal - 0.005;

  if LVal < 0 then LVal := 0;

  FCurrDimStyle.AltUnitsProp.MeasurementScale := LVal;
  edtAltMultiplier.Text := FloatToStr(LVal);
  
  Self.UpdatePrivewDim();
end;



procedure TUdDimStylesForm.edtAltRoundDisChange(Sender: TObject);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>

  if TryStrToFloat(edtAltRoundDis.Text, LVal) and (LVal >= 0) then
  begin
    FCurrDimStyle.AltUnitsProp.RoundOff := LVal;
    Self.UpdatePrivewDim();
  end;
end;


procedure TUdDimStylesForm.udnAltRoundDisChangingEx(Sender: TObject; var AllowChange: Boolean;
  NewValue: Smallint; Direction: TUpDownDirection);
var
  LVal: Double;
begin
  if FChanging then Exit; //=====>>>>>

  AllowChange := False;

  LVal := FCurrDimStyle.AltUnitsProp.RoundOff;

  if Direction = updUp then
    LVal := LVal + 0.005
  else
    LVal := LVal - 0.005;

  if LVal < 0 then LVal := 0;

  FCurrDimStyle.AltUnitsProp.RoundOff := LVal;
  edtAltRoundDis.Text := FloatToStr(LVal);
  
  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.edtAltPrefixChange(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.AltUnitsProp.Prefix := edtAltPrefix.Text;
  Self.UpdatePrivewDim();
end;

procedure TUdDimStylesForm.edtAltSuffixChange(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.AltUnitsProp.Suffix := edtAltSuffix.Text;
  Self.UpdatePrivewDim();
end;




procedure TUdDimStylesForm.ckbAltSuppressLeadingClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.AltUnitsProp.SuppressLeading := ckbAltSuppressLeading.Checked;
  Self.UpdatePrivewDim();
end;

procedure TUdDimStylesForm.ckbAltSuppressTrailingClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  FCurrDimStyle.AltUnitsProp.SuppressTrailing := ckbAltSuppressTrailing.Checked;
  Self.UpdatePrivewDim();
end;


procedure TUdDimStylesForm.rdbAltPlacementClick(Sender: TObject);
begin
  if FChanging then Exit; //=====>>>>>

  case TComponent(Sender).Tag of
    0: FCurrDimStyle.AltUnitsProp.AltPlacement := apAfterPrimary;
    1: FCurrDimStyle.AltUnitsProp.AltPlacement := apBelowPrimary;
  end;
end;



//================================================================================================


procedure TUdDimStylesForm.edtStyleNameChange(Sender: TObject);
var
  I, N, M: Integer;
  LName: string;
  LDimStyle: TUdDimStyle;
begin
  if FChanging then Exit; //=====>>>>>

  LName := LowerCase(Trim(edtStyleName.Text));
  if LName = '' then
  begin
    edtStyleName.OnChange := nil;
    try
      edtStyleName.Text := FCurrDimStyle.Name;
    finally
      edtStyleName.OnChange := edtStyleNameChange;
    end;
    
    Exit; //=====>>>>
  end;


  N := -1;
  M := -1;
  for I := 0 to FDimStyles2.Count - 1 do
  begin
    LDimStyle := FDimStyles2.Items[I];
    if LDimStyle = FCurrDimStyle then
    begin
      M := I;
      Continue;
    end;

    if LowerCase(LDimStyle.Name) = LName then
    begin
      N := I;
      Break;
    end;
  end;

  if N < 0 then
  begin
    FCurrDimStyle.Name := edtStyleName.Text;
    ltbDimStyles.Items[M] := edtStyleName.Text;
    if FCurrDimStyle = FDimStyles2.Active then lblCurrStyle.Caption := FCurrDimStyle.Name;
  end
  else begin
    edtStyleName.OnChange := nil;
    try
      edtStyleName.Text := FCurrDimStyle.Name;
    finally
      edtStyleName.OnChange := edtStyleNameChange;
    end;
  end;
end;


procedure TUdDimStylesForm.btnNewClick(Sender: TObject);
var
  I: Integer;
  N, M: Integer;
  LName: string;
  LDimStyle: TUdDimStyle;
begin
  N := -1;
  for I := 0 to ltbDimStyles.Count - 1 do
  begin
    if ltbDimStyles.Selected[I] then
    begin
      N := I;
      Break;
    end;
  end;


  M := 1;
  LName := 'DimStyle' + IntToStr(M);
  while FDimStyles2.IndexOf(LName) >= 0 do
  begin
    Inc(M);
    LName := 'DimStyle' + IntToStr(M);
  end;

  LDimStyle := TUdDimStyle.Create();
  if N >= 0 then
    LDimStyle.Assign(FDimStyles2.Items[N]);
  LDimStyle.Name := LName;

  FDimStyles2.Add(LDimStyle);
  ltbDimStyles.AddItem(LDimStyle.Name, LDimStyle);

  ltbDimStyles.Selected[FDimStyles2.Count - 1] := True;
  Self.SetCurrDimStyle(LDimStyle);

  LDimStyle.Status := STATUS_NEW;
end;

procedure TUdDimStylesForm.btnSetCurrentClick(Sender: TObject);
var
  I: Integer;
  N: Integer;
begin
  N := -1;
  for I := 0 to ltbDimStyles.Count - 1 do
  begin
    if ltbDimStyles.Selected[I] then
    begin
      N := I;
      Break;
    end;
  end;

  if N >= 0 then
  begin
    FDimStyles2.SetActive(N);
    lblCurrStyle.Caption := FDimStyles2.Items[N].Name;
  end;
end;

procedure TUdDimStylesForm.btnDeleteClick(Sender: TObject);
var
  I: Integer;
  N: Integer;
begin
  N := -1;
  for I := 0 to ltbDimStyles.Count - 1 do
  begin
    if ltbDimStyles.Selected[I] then
    begin
      N := I;
      Break;
    end;
  end;

  if N > 0 then
  begin
    if ((FDimStyles2.Items[N] <> FDimStyles2.Active) and (FDimStyles2.Items[N] = FDimStyles2.Standard)) and
       ((FDimStyles2.Items[N].Status and STATUS_USELESS) > 0) then
    begin
      FDimStyles2.Remove(N);
      ltbDimStyles.Items.Delete(N);

      ltbDimStyles.Selected[0] := True;
      Self.SetCurrDimStyle(FDimStyles2.Items[0]);
    end;
  end;
end;




procedure TUdDimStylesForm.ltbDimStylesClick(Sender: TObject);
var
  I: Integer;
  N: Integer;
  LDimStyle: TUdDimStyle;
begin
  N := -1;
  for I := 0 to ltbDimStyles.Count - 1 do
  begin
    if ltbDimStyles.Selected[I] then
    begin
      N := I;
      Break;
    end;
  end;

  if N >= 0 then
  begin
    LDimStyle := FDimStyles2.Items[N];
    if LDimStyle <> FCurrDimStyle then Self.SetCurrDimStyle(LDimStyle);
  end;
end;




procedure TUdDimStylesForm.btnOKClick(Sender: TObject);

  function _GetDimStyle(ADimStyles: TUdDimStyles; AID: Integer): TUdDimStyle;
  var
    I: Integer;
  begin
    Result := nil;
    if AID <= 0 then Exit;

    for I := 0 to ADimStyles.Count - 1 do
    begin
      if ADimStyles.Items[I].ID = AID then
      begin
        Result := ADimStyles.Items[I];
        Break;
      end;
    end;
  end;
  
var
  I: Integer;
  LColor: TUdColor;
  LLineType: TUdLineType;
  LDimStyle, LDimStyle2: TUdDimStyle;
begin
  if Assigned(FDocument) then FDocument.BeginUndo('');
  try
    if Assigned(FDocument) then
    begin
      for I := 0 to FColors2.Count - 1 do
      begin
        if (FColors2.Items[I].Status and STATUS_NEW) > 0 then
        begin
          LColor := TUdColor.Create();
          LColor.Assign(FColors2.Items[I]);
          FDocument.Colors.Add(LColor);
        end;
      end;

      for I := 0 to FLineTypes2.Count - 1 do
      begin
        if (FLineTypes2.Items[I].Status and STATUS_NEW) > 0 then
        begin
          LLineType := TUdLineType.Create();
          LLineType.Assign(FLineTypes2.Items[I]);
          FDocument.LineTypes.Add(LLineType);
        end;
      end;      
    end;

    for I := FDimStyles.Count - 1 downto 0 do
    begin
      LDimStyle  := FDimStyles.Items[I];
      LDimStyle2 := _GetDimStyle(FDimStyles2, LDimStyle.ID);
      if not Assigned(LDimStyle2) then FDimStyles.RemoveAt(I);
    end;

    for I := 0 to FDimStyles2.Count - 1 do
    begin
      LDimStyle2 := FDimStyles2.Items[I];
      LDimStyle  := _GetDimStyle(FDimStyles, LDimStyle2.ID);

      if Assigned(LDimStyle) then
      begin
        LDimStyle.Assign(LDimStyle2);
        if (LDimStyle2 = FDimStyles2.Active) then FDimStyles.SetActive(LDimStyle.Name);
      end
      else begin
        LDimStyle := TUdDimStyle.Create();
        LDimStyle.Assign(LDimStyle2);
        FDimStyles.Add(LDimStyle);

        if (LDimStyle2 = FDimStyles2.Active) then FDimStyles.SetActive(LDimStyle.Name);
      end;
    end;       
  finally
    if Assigned(FDocument) then FDocument.EndUndo();
  end;

  Self.ModalResult := mrOk;
end;





end.