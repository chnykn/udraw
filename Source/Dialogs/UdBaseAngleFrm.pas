{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdBaseAngleFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TUdBaseAngleForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    gpbBaseAngle: TGroupBox;
    rdbEast: TRadioButton;
    rdbNorth: TRadioButton;
    rdbWest: TRadioButton;
    rdbSouth: TRadioButton;
    rdbOther: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtAngle: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rdbAngleClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    
  private
    FAngle: Double;
  protected
    procedure SetAngle(const Value: Double);
  public
    property Angle: Double read FAngle write SetAngle;
  end;



implementation

{$R *.dfm}

uses
  SysUtils, Math;


//=================================================================================================
{ TUdBaseAngleForm }


procedure TUdBaseAngleForm.FormCreate(Sender: TObject);
begin
  FAngle := 0.0;
end;

procedure TUdBaseAngleForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TUdBaseAngleForm.FormShow(Sender: TObject);
begin
//
end;


procedure TUdBaseAngleForm.SetAngle(const Value: Double);
begin
  FAngle := Value;

  if SameValue(FAngle, 0.0, 1E-5) then
  begin
    FAngle := 0.0;
    rdbEast.Checked := True;
  end else
  if SameValue(FAngle, 90.0, 1E-5) then
  begin
    FAngle := 90.0;
    rdbNorth.Checked := True;
  end else
  if SameValue(FAngle, 180.0, 1E-5) then
  begin
    FAngle := 180.0;
    rdbWest.Checked := True;
  end else
  if SameValue(FAngle, 270.0, 1E-5) then
  begin
    FAngle := 270.0;
    rdbSouth.Checked := True;
  end
  else begin
    rdbOther.Checked := True;
    edtAngle.Text := FloatToStr(FAngle);
  end;
end;


procedure TUdBaseAngleForm.rdbAngleClick(Sender: TObject);
begin
  if TComponent(Sender).Tag < 4 then
  begin
    edtAngle.Text := FloatToStr(TComponent(Sender).Tag * 90);
    edtAngle.Enabled := False;
  end
  else begin
    edtAngle.Enabled := True;
  end;
end;


procedure TUdBaseAngleForm.btnOKClick(Sender: TObject);
begin
  FAngle := StrToFloatDef(edtAngle.Text, FAngle);
end;





end.