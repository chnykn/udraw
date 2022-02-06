{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdActionHatchFrm;

interface

uses
  Windows, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Buttons,

  UdTypes, UdGTypes, UdObject, UdHatchPattern, UdHatchPatterns;

type
  TUdHatchApply = (haNone, haOk, haCancel, haPickPnts, haSelObjs);


  TUdActionHatchForm = class(TForm)
    gbPatternStyle: TGroupBox;
    cbxPattern: TComboBox;
    Label1: TLabel;
    pnlPreview: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtAngle: TEdit;
    edtScale: TEdit;
    gbBoundaries: TGroupBox;
    gbHatchStyle: TGroupBox;
    btnPickPnts: TSpeedButton;
    Label5: TLabel;
    btnSelObjs: TSpeedButton;
    Label6: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    btnOK: TButton;
    btnCancel: TButton;
    pbPattern: TPaintBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure pbPatternPaint(Sender: TObject);
    procedure cbxPatternChange(Sender: TObject);

    procedure edtAngleChange(Sender: TObject);
    procedure edtScaleChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnPickPntsClick(Sender: TObject);
    procedure btnSelObjsClick(Sender: TObject);

  private
    FDocument: TUdObject;
    FHatchPatterns: TUdHatchPatterns;
    FPatternSegments: TSegment2DArray;
    FApplyResult: TUdHatchApply;

  protected
    function GetHatchScale: Float;
    procedure SetHatchScale(const AValue: Float);

    function GetHatchAngle: Float;
    procedure SetHatchAngle(const AValue: Float);

    function GetHatchStyle: Integer;
    procedure SetHatchStyle(const AValue: Integer);

    function GetPatternName: string;
    procedure SetPatternName(const AValue: string);

    procedure SetDocument(const AValue: TUdObject);

  public
    procedure CalcPreviewSegments();
    
    property HatchStyle  : Integer read GetHatchStyle  write SetHatchStyle;
    property HatchScale  : Float   read GetHatchScale  write SetHatchScale;
    property HatchAngle  : Float   read GetHatchAngle  write SetHatchAngle;
    property PatternName : string  read GetPatternName write SetPatternName;


    property Document: TUdObject read FDocument write SetDocument;
    property ApplyResult: TUdHatchApply read FApplyResult;

  end;



implementation

{$R *.dfm}

uses
  SysUtils, UdDocument, UdGeo2D, UdMath;



{ TUdActionHatchForm }



procedure TUdActionHatchForm.FormCreate(Sender: TObject);
begin
  FDocument := nil;
  FPatternSegments := nil;
  FApplyResult := haNone;
end;

procedure TUdActionHatchForm.FormDestroy(Sender: TObject);
begin
  FDocument := nil;
  FPatternSegments := nil;
end;

procedure TUdActionHatchForm.FormShow(Sender: TObject);
begin
//
end;




//---------------------------------------------------------------------------------------------

function TUdActionHatchForm.GetHatchScale: Float;
begin
  if TryStrToFloat(edtScale.Text, Result) then
  begin
    if IsEqual(Result, 0.0) or (Result <= 0) then Result := 1.0;
  end
  else Result := 1.0;
end;

procedure TUdActionHatchForm.SetHatchScale(const AValue: Float);
begin
  edtScale.OnChange := nil;
  try
    edtScale.Text := FloatToStr(AValue);
  finally
    edtScale.OnChange := edtScaleChange;
  end;
end;



function TUdActionHatchForm.GetHatchAngle: Float;
begin
  if TryStrToFloat(edtAngle.Text, Result) then
    Result := FixAngle(Result)
  else
    Result := 0.0;
end;

procedure TUdActionHatchForm.SetHatchAngle(const AValue: Float);
begin
  edtAngle.OnChange := nil;
  try
    edtAngle.Text := FloatToStr(AValue);
  finally
    edtAngle.OnChange := edtAngleChange;
  end;
end;


function TUdActionHatchForm.GetHatchStyle: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to gbHatchStyle.ControlCount - 1 do
  begin
    if gbHatchStyle.Controls[I].InheritsFrom(TRadioButton) and
       TRadioButton(gbHatchStyle.Controls[I]).Checked then
    begin
      Result := gbHatchStyle.Controls[I].Tag;
      Break;
    end;
  end;
end;

procedure TUdActionHatchForm.SetHatchStyle(const AValue: Integer);
var
  I: Integer;
begin
  for I := 0 to gbHatchStyle.ControlCount - 1 do
  begin
    if gbHatchStyle.Controls[I].InheritsFrom(TRadioButton) and
       (gbHatchStyle.Controls[I].Tag = AValue) then
    begin
       TRadioButton(gbHatchStyle.Controls[I]).Checked := True;
      Break;
    end;
  end;
end;



procedure TUdActionHatchForm.SetPatternName(const AValue: string);
begin
  if Assigned(FHatchPatterns) then
    cbxPattern.ItemIndex := FHatchPatterns.IndexOf(AValue);
end;

function TUdActionHatchForm.GetPatternName: string;
begin
  Result := cbxPattern.Text;
end;



procedure TUdActionHatchForm.CalcPreviewSegments();
var
  N, M: Integer;
  LPnts: TPoint2DArray;
  LSegarcs: TSegarc2DArray;
  LHatchPattern: TUdHatchPattern;
begin
  if cbxPattern.ItemIndex <= 0 then FPatternSegments := nil else
  begin
    LHatchPattern := FHatchPatterns.Items[cbxPattern.ItemIndex];

    System.SetLength(LPnts, 5);
    LPnts[0] := Point2D(0, 0);
    LPnts[1] := Point2D(pnlPreview.Width, 0);
    LPnts[2] := Point2D(pnlPreview.Width, pnlPreview.Height);
    LPnts[3] := Point2D(0, pnlPreview.Height);
    LPnts[4] := Point2D(0, 0);

    LSegarcs := Segarc2DArray(LPnts);
    FPatternSegments := LHatchPattern.PatternLines.CalcHatchSegments(LSegarcs, 1);

    if Pos('ACAD_ISO', LHatchPattern.Name) > 0 then M := 80 else M := 60;

    if (System.Length(FPatternSegments) div LHatchPattern.PatternLines.Count) < 10 then
    begin
      N := 1;
      while (System.Length(FPatternSegments) div LHatchPattern.PatternLines.Count < 10) and (N < 10) do
      begin
        N := N + 1;
        FPatternSegments := LHatchPattern.PatternLines.CalcHatchSegments(LSegarcs, 1 / N);
      end;
    end
    else if (System.Length(FPatternSegments) div LHatchPattern.PatternLines.Count) > M then
    begin
      N := 1;
      while (System.Length(FPatternSegments) div LHatchPattern.PatternLines.Count > M) and (N < 10) do
      begin
        N := N + 1;
        FPatternSegments := LHatchPattern.PatternLines.CalcHatchSegments(LSegarcs, N);
      end;
    end;

  end;
end;


//---------------------------------------------------------------------------------------------


procedure TUdActionHatchForm.pbPatternPaint(Sender: TObject);
var
  I: Integer;
  LCanvas: TCanvas;
  LSegment: TSegment2D;
  LX1, LY1, LX2, LY2: Integer;
begin
  LCanvas := pbPattern.Canvas;

  if System.Length(FPatternSegments) > 0 then
  begin
    LCanvas.Pen.Width := 1;
    LCanvas.Pen.Style := psSolid;
    LCanvas.Pen.Color := clWhite;

    LCanvas.Brush.Style := bsSolid;
    LCanvas.Brush.Color := clWhite;

    LCanvas.FillRect(Rect(0,0, pnlPreview.Width, pnlPreview.Height));


    LCanvas.Pen.Color := clBlack;
    LCanvas.Brush.Style := bsClear;

    for I := 0 to System.Length(FPatternSegments) - 1 do
    begin
      LSegment := FPatternSegments[I];
      LX1 := Trunc(LSegment.P1.X);  LY1 := pnlPreview.Height - Trunc(LSegment.P1.Y);
      LX2 := Trunc(LSegment.P2.X);  LY2 := pnlPreview.Height - Trunc(LSegment.P2.Y);

      if (LX1 = LX2) and (LY1 = LY2) then
      begin
        LCanvas.Pixels[LX1, LY1] := clBlack;
      end
      else begin
        LCanvas.MoveTo(LX1, LY1);
        LCanvas.LineTo(LX2, LY2);
      end;
    end;
  end
  else begin
    LCanvas.Pen.Width := 1;
    LCanvas.Pen.Style := psSolid;
    LCanvas.Pen.Color := clWhite;

    LCanvas.Brush.Style := bsSolid;
    LCanvas.Brush.Color := clWhite;

    LCanvas.FillRect(Rect(0,0, pnlPreview.Width, pnlPreview.Height));

    LCanvas.Brush.Color :=  clBlack;
    LCanvas.FillRect(Rect(2,2, pnlPreview.Width-4, pnlPreview.Height-4));
  end;
end;

procedure TUdActionHatchForm.cbxPatternChange(Sender: TObject);
begin
  CalcPreviewSegments();
  pbPattern.Invalidate;
end;

procedure TUdActionHatchForm.SetDocument(const AValue: TUdObject);
var
  I: Integer;
begin
  FDocument := AValue;
  if Assigned(FDocument) then
  begin
    FHatchPatterns := TUdDocument(FDocument).HatchPatterns;

    cbxPattern.Items.Clear();

    for I := 0 to FHatchPatterns.Count - 1 do
      cbxPattern.Items.Add(FHatchPatterns.Items[I].Name);

    cbxPattern.ItemIndex := 0;
  end;
end;



//---------------------------------------------------------------------------------------------



procedure TUdActionHatchForm.edtAngleChange(Sender: TObject);
begin
//
end;

procedure TUdActionHatchForm.edtScaleChange(Sender: TObject);
begin
//
end;


procedure TUdActionHatchForm.btnOKClick(Sender: TObject);
var
  N: Double;
  LScaleValid: Boolean;
begin
  if not TryStrToFloat(edtAngle.Text, N) then
  begin
    MessageBox(Self.Handle, 'Invalid Angle Input', 'Message', MB_ICONWARNING or MB_OK);
    edtAngle.SetFocus();
    Exit;  //========>>>>
  end;

  LScaleValid := True;

  if TryStrToFloat(edtScale.Text, N) then
  begin
    if IsEqual(N, 0.0) or (N <= 0) then LScaleValid := False;
  end
  else
    LScaleValid := False;

  if not LScaleValid then
  begin
    MessageBox(Self.Handle, 'Invalid Scale Input', 'Message', MB_ICONWARNING or MB_OK);
    edtScale.SetFocus();
    Exit;  //========>>>>
  end;

  FApplyResult := haOK;
  Self.Close();
end;

procedure TUdActionHatchForm.btnPickPntsClick(Sender: TObject);
begin
  FApplyResult := haPickPnts;
  Self.Close();
end;

procedure TUdActionHatchForm.btnSelObjsClick(Sender: TObject);
begin
  FApplyResult := haSelObjs;
  Self.Close();
end;

procedure TUdActionHatchForm.btnCancelClick(Sender: TObject);
begin
  FApplyResult := haCancel;
  Self.Close();
end;





end.