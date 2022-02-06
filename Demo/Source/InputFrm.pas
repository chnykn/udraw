unit InputFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TInputForm = class(TForm)
    Memo1: TMemo;
    btnOK: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ShowInputForm(AIntStrs: string = ''; ACaption: string = ''): string;

implementation

{$R *.dfm}

function ShowInputForm(AIntStrs: string = ''; ACaption: string = ''): string;
var
  LInputForm: TInputForm;
begin
  Result := '';
  LInputForm := TInputForm.Create(nil);
  try
    if ACaption <> '' then LInputForm.Caption := ACaption;

    LInputForm.Memo1.Lines.Text := AIntStrs;
    if LInputForm.ShowModal() = mrOk then
    begin
      Result := LInputForm.Memo1.Lines.Text;
    end;
  finally
    LInputForm.Free;
  end;
end;

end.
