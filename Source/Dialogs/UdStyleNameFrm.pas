{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdStyleNameFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TUdStyleNameForm = class(TForm)
    edtStyleName: TEdit;
    lblStyleName: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


function ShowStyleNameDialog(var AValue: string): Boolean;  

implementation

{$R *.dfm}


function ShowStyleNameDialog(var AValue: string): Boolean;
var
  LForm: TUdStyleNameForm;
begin
  Result := False;
  LForm := TUdStyleNameForm.Create(nil);
  try
    LForm.edtStyleName.Text := AValue;
    if LForm.ShowModal() = mrOk then
    begin
      AValue := LForm.edtStyleName.Text;
      Result := True;
    end;
  finally
    LForm.Free;
  end;
end;



end.