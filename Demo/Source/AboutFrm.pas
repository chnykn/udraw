unit AboutFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TAboutForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblURL: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
        
    procedure lblURLMouseEnter(Sender: TObject);
    procedure lblURLMouseLeave(Sender: TObject);
    procedure lblURLClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;



implementation

{$R *.dfm}


uses
  ShellAPI;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
//
end;


procedure TAboutForm.FormDestroy(Sender: TObject);
begin
//
end;

procedure TAboutForm.FormDblClick(Sender: TObject);
begin
  Self.Close();
end;





procedure TAboutForm.lblURLMouseEnter(Sender: TObject);
begin
  //lblURL.Font.Color := clBlue;
  lblURL.Font.Style := lblURL.Font.Style + [fsUnderline];
  lblURL.Cursor := crHandPoint;
end;

procedure TAboutForm.lblURLMouseLeave(Sender: TObject);
begin
  //lblURL.Font.Color := clWindowText;
  lblURL.Font.Style := lblURL.Font.Style - [fsUnderline];
end;

procedure TAboutForm.lblURLClick(Sender: TObject);
begin
  ShellAPI.ShellExecute(0, 'open', PChar(lblURL.Caption), '', '', SW_SHOWNORMAL);
end;


end.
