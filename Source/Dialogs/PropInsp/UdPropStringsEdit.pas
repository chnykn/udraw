unit UdPropStringsEdit;

interface

uses
  Windows, SysUtils , Variants , Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, ExtCtrls;

var
  SELStringsEditorDlgCaption            : string  = '文本列表编辑器';
  SELStringsEditorDlgOkBtnCaption       : string  = '确认(&O)';
  SELStringsEditorDlgCancelBtnCaption   : string  = '取消';
  SELStringsEditorDlgLinesCountTemplate : string  = '行数: %d';

type
  TUdStringsEditorDlg = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    lbLineCount: TLabel;
    bvlMain: TBevel;
    memMain: TRichEdit;
    procedure memMainChange(Sender: TObject);
  private
    function GetLines: TStrings;
    procedure SetLines(const Value: TStrings);
  public
    function Execute: Boolean;
    property Lines: TStrings read GetLines write SetLines;
  end;

implementation

{$R *.dfm}

{ TUdStringsEditorDlg }

function TUdStringsEditorDlg.Execute: Boolean;
begin
  Caption := SELStringsEditorDlgCaption;
  btnOk.Caption := SELStringsEditorDlgOkBtnCaption;
  btnCancel.Caption := SELStringsEditorDlgCancelBtnCaption;
  lbLineCount.Caption := Format(SELStringsEditorDlgLinesCountTemplate,
    [memMain.Lines.Count]);

  Result := (ShowModal = mrOk);
end;

function TUdStringsEditorDlg.GetLines: TStrings;
begin
  Result := memMain.Lines;
end;

procedure TUdStringsEditorDlg.SetLines(const Value: TStrings);
begin
  memMain.Lines := Value;
end;

procedure TUdStringsEditorDlg.memMainChange(Sender: TObject);
begin
  lbLineCount.Caption := Format(SELStringsEditorDlgLinesCountTemplate,
    [memMain.Lines.Count]);
end;

end.