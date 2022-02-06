unit UdActionArrayFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons,

  UdGTypes;

type
  TUdArrayPickKind = (apkNone, apkSelObjs, apkRowOffset, apkColOffset, apkAngle, apkCenter, apkFillAngle);


  TUdActionArrayForm = class(TForm)
    rdRectArray: TRadioButton;
    rdPolarArray: TRadioButton;
    pnlRect: TPanel;
    edtRowNum: TEdit;
    edtColNum: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    edtRowOffset: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    edtColOffset: TEdit;
    Label5: TLabel;
    edtAngle: TEdit;
    Label6: TLabel;
    pnlPolar: TPanel;
    lblCenterPoint: TLabel;
    Label8: TLabel;
    edtCenX: TEdit;
    lblY: TLabel;
    edtCenY: TEdit;
    gpbMethodValues: TGroupBox;
    lblTotalNum: TLabel;
    edtItemsNum: TEdit;
    lblAngleToFill: TLabel;
    edtFillAng: TEdit;
    lblAngleBetween: TLabel;
    edtAngBetween: TEdit;
    lblNote: TLabel;
    ckbRotateItems: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    Panel1: TPanel;
    lblSelectObjects: TLabel;

    btnSelectObjs: TSpeedButton;

    btnRowOffset: TSpeedButton;
    btnColOffset: TSpeedButton;
    btnAngle: TSpeedButton;

    btnCenPnt: TSpeedButton;
    btnFillAng: TSpeedButton;
    Image1: TImage;
    Image2: TImage;



    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rdArrayKindClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnSelectObjsClick(Sender: TObject);
    procedure btnCenPntClick(Sender: TObject);
    procedure btnFillAngClick(Sender: TObject);
    procedure btnRowOffsetClick(Sender: TObject);
    procedure btnColOffsetClick(Sender: TObject);
    procedure btnAngleClick(Sender: TObject);
    procedure edtFillAngChange(Sender: TObject);
    procedure edtItemsNumChange(Sender: TObject);

  private
    FPickKind: TUdArrayPickKind;

  protected
    function CheckInputEdits: Boolean;

    function GetPolarCenter: TPoint2D;
    function GetPolarFillAng: Double;
    function GetPolarNum: Integer;
    function GetPolarRotateItems: Boolean;

    procedure SetPolarCenter(const Value: TPoint2D);
    procedure SetPolarFillAng(const Value: Double);
    procedure SetPolarNum(const Value: Integer);
    procedure SetPolarRotateItems(const Value: Boolean);


    function GetRectAngle: Double;
    function GetRectColDis: Double;
    function GetRectRowDis: Double;
    function GetRectColNum: Integer;
    function GetRectRowNum: Integer;

    procedure SetRectAngle(const Value: Double);
    procedure SetRectColDis(const Value: Double);
    procedure SetRectRowDis(const Value: Double);
    procedure SetRectColNum(const Value: Integer);
    procedure SetRectRowNum(const Value: Integer);

  public
    property RectRowNum: Integer read GetRectRowNum write SetRectRowNum;
    property RectColNum: Integer read GetRectColNum write SetRectColNum;
    property RectRowDis: Double  read GetRectRowDis write SetRectRowDis;
    property RectColDis: Double  read GetRectColDis write SetRectColDis;
    property RectAngle : Double  read GetRectAngle  write SetRectAngle;

    property PolarNum         : Integer  read GetPolarNum         write SetPolarNum;
    property PolarFillAng     : Double   read GetPolarFillAng     write SetPolarFillAng;
    property PolarCenter      : TPoint2D read GetPolarCenter      write SetPolarCenter;
    property PolarRotateItems : Boolean  read GetPolarRotateItems write SetPolarRotateItems;

    property PickKind : TUdArrayPickKind read FPickKind;
  end;

implementation

{$R *.dfm}

uses
  SysUtils;



procedure TUdActionArrayForm.FormCreate(Sender: TObject);
begin
  pnlRect.Visible := True;
  pnlPolar.Visible := False;

  btnRowOffset.Glyph.Assign(btnSelectObjs.Glyph);
  btnColOffset.Glyph.Assign(btnSelectObjs.Glyph);
  btnAngle.Glyph.Assign(btnSelectObjs.Glyph);

  btnCenPnt.Glyph.Assign(btnSelectObjs.Glyph);
  btnFillAng.Glyph.Assign(btnSelectObjs.Glyph);

  Image2.Picture.Assign(Image1.Picture);

  FPickKind := apkNone;
end;

procedure TUdActionArrayForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TUdActionArrayForm.FormShow(Sender: TObject);
begin
  FPickKind := apkNone;
end;



//----------------------------------------------------------------------------------------


function TUdActionArrayForm.GetPolarCenter: TPoint2D;
begin
  if not TryStrToFloat(edtCenX.Text, Result.X) then Result.X := 0;
  if not TryStrToFloat(edtCenY.Text, Result.Y) then Result.Y := 0;
end;

function TUdActionArrayForm.GetPolarFillAng: Double;
begin
  if not TryStrToFloat(edtFillAng.Text, Result) then Result := 0;
end;

function TUdActionArrayForm.GetPolarNum: Integer;
begin
  if not TryStrToInt(edtItemsNum.Text, Result) then Result := 0;
end;

function TUdActionArrayForm.GetPolarRotateItems: Boolean;
begin
  Result := ckbRotateItems.Checked;
end;




procedure TUdActionArrayForm.SetPolarCenter(const Value: TPoint2D);
begin
  edtCenX.Text := FloatToStr(Value.X);
  edtCenY.Text := FloatToStr(Value.X);
end;

procedure TUdActionArrayForm.SetPolarFillAng(const Value: Double);
begin
  edtFillAng.Text := FloatToStr(Value);
end;

procedure TUdActionArrayForm.SetPolarNum(const Value: Integer);
begin
  edtItemsNum.Text := IntToStr(Value);
end;

procedure TUdActionArrayForm.SetPolarRotateItems(const Value: Boolean);
begin
  ckbRotateItems.Checked := Value;
end;






//----------------------------------------------------------------------------------------

function TUdActionArrayForm.GetRectAngle: Double;
begin
  if not TryStrToFloat(edtAngle.Text, Result) then Result := 0;
end;

function TUdActionArrayForm.GetRectColDis: Double;
begin
  if not TryStrToFloat(edtColOffset.Text, Result) then Result := 0;
end;

function TUdActionArrayForm.GetRectRowDis: Double;
begin
  if not TryStrToFloat(edtRowOffset.Text, Result) then Result := 0;
end;

function TUdActionArrayForm.GetRectColNum: Integer;
begin
  if not TryStrToInt(edtColNum.Text, Result) then Result := 0;
end;

function TUdActionArrayForm.GetRectRowNum: Integer;
begin
  if not TryStrToInt(edtRowNum.Text, Result) then Result := 0;
end;



procedure TUdActionArrayForm.SetRectAngle(const Value: Double);
begin
  edtAngle.Text := FloatToStr(Value);
end;

procedure TUdActionArrayForm.SetRectColDis(const Value: Double);
begin
  edtColOffset.Text := FloatToStr(Value);
end;

procedure TUdActionArrayForm.SetRectRowDis(const Value: Double);
begin
  edtRowOffset.Text := FloatToStr(Value);
end;

procedure TUdActionArrayForm.SetRectColNum(const Value: Integer);
begin
  edtColNum.Text := IntToStr(Value);
end;


procedure TUdActionArrayForm.SetRectRowNum(const Value: Integer);
begin
  edtRowNum.Text := IntToStr(Value);
end;



//----------------------------------------------------------------------------------------



procedure TUdActionArrayForm.rdArrayKindClick(Sender: TObject);
begin
  pnlRect.Visible  := TComponent(Sender).Tag = 0;
  pnlPolar.Visible := TComponent(Sender).Tag = 1;
end;


function TUdActionArrayForm.CheckInputEdits(): Boolean;
var
  N: Integer;
  D: Double;
begin
  Result := False;

  if pnlRect.Visible then
  begin
    if not TryStrToInt(edtRowNum.Text, N) then
    begin
      edtRowNum.SetFocus();
      MessageBox(Self.Handle, 'Please enter an integer from 1 to 32767.', PChar(Application.Title), MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    if not TryStrToInt(edtColNum.Text, N) then
    begin
      edtColNum.SetFocus();
      MessageBox(Self.Handle, 'Please enter an integer from 1 to 32767.', PChar(Application.Title), MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    if not TryStrToFloat(edtRowOffset.Text, D) then
    begin
      edtRowOffset.SetFocus();
      MessageBox(Self.Handle, 'Invalid row offset.', PChar(Application.Title), MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    if not TryStrToFloat(edtColOffset.Text, D) then
    begin
      edtColOffset.SetFocus();
      MessageBox(Self.Handle, 'Invalid column offset.', PChar(Application.Title), MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    if not TryStrToFloat(edtAngle.Text, D) then
    begin
      edtAngle.SetFocus();
      MessageBox(Self.Handle, 'Invalid angle of array.', PChar(Application.Title), MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    Result := True;
  end
  else begin
    if not TryStrToFloat(edtCenX.Text, D) then
    begin
      edtCenX.SetFocus();
      MessageBox(Self.Handle, 'Invalid center point.', PChar(Application.Title), MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    if not TryStrToFloat(edtCenY.Text, D) then
    begin
      edtCenY.SetFocus();
      MessageBox(Self.Handle, 'Invalid center point.', PChar(Application.Title), MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    if not TryStrToFloat(edtFillAng.Text, D) then
    begin
      edtFillAng.SetFocus();
      MessageBox(Self.Handle, 'Invalid fill angle.', PChar(Application.Title), MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    if not TryStrToInt(edtItemsNum.Text, N) then
    begin
      edtItemsNum.SetFocus();
      MessageBox(Self.Handle, 'Please enter an integer from 2 to 32767.', PChar(Application.Title), MB_ICONWARNING or MB_OK);
      Exit; //=====>>>>>
    end;

    Result := True;
  end;
end;



procedure TUdActionArrayForm.edtFillAngChange(Sender: TObject);
var
  D: Double;
  N: Integer;
begin
  if TryStrToFloat(edtFillAng.Text, D) and TryStrToInt(edtItemsNum.Text, N) then
    if N > 0 then
      edtAngBetween.Text := FloatToStr(D/N);
end;

procedure TUdActionArrayForm.edtItemsNumChange(Sender: TObject);
var
  D: Double;
  N: Integer;
begin
  if TryStrToFloat(edtFillAng.Text, D) and TryStrToInt(edtItemsNum.Text, N) then
    if N > 0 then
      edtAngBetween.Text := FloatToStr(D/N);
end;


procedure TUdActionArrayForm.btnOKClick(Sender: TObject);
begin
  if CheckInputEdits() then
  begin
    Self.ModalResult := mrOK;
//    Self.Close();
  end;
end;



procedure TUdActionArrayForm.btnSelectObjsClick(Sender: TObject);
begin
  if CheckInputEdits() then
  begin
    FPickKind := apkSelObjs;
    Self.ModalResult := mrYes;
  end;
end;


procedure TUdActionArrayForm.btnCenPntClick(Sender: TObject);
begin
  if CheckInputEdits() then
  begin
    FPickKind := apkCenter;
    Self.ModalResult := mrYes;
  end;
end;


procedure TUdActionArrayForm.btnFillAngClick(Sender: TObject);
begin
  if CheckInputEdits() then
  begin
    FPickKind := apkFillAngle;
    Self.ModalResult := mrYes;
  end;
end;




procedure TUdActionArrayForm.btnRowOffsetClick(Sender: TObject);
begin
  if CheckInputEdits() then
  begin
    FPickKind := apkRowOffset;
    Self.ModalResult := mrYes;
  end;
end;

procedure TUdActionArrayForm.btnColOffsetClick(Sender: TObject);
begin
  if CheckInputEdits() then
  begin
    FPickKind := apkColOffset;
    Self.ModalResult := mrYes;
  end;
end;

procedure TUdActionArrayForm.btnAngleClick(Sender: TObject);
begin
  if CheckInputEdits() then
  begin
    FPickKind := apkAngle;
    Self.ModalResult := mrYes;
  end;
end;



end.