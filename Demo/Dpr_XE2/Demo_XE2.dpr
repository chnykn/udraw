program Demo_XE2;
           

uses
  FastMM4,
  Forms,
  MainFrm in '..\Source\MainFrm.pas' {MainForm},
  Bitmaps in '..\Source\Bitmaps.pas' {BitmapsModule: TDataModule},
  UdPoint in '..\..\Source\Core\Entities\UdPoint.pas',
  UdCursor in '..\..\Source\Core\UdCursor.pas';

{$R *.res}


begin
  Application.Initialize;
  Application.Title := 'Delphi CAD';

  Application.CreateForm(TBitmapsModule, BitmapsModule);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

end.
