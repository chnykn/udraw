{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLntypLoaderFrm;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,

  UdLinetype;

type
  TUdLntypLoaderForm = class(TForm)
    edtFile: TEdit;
    btnFile: TButton;
    ltvLinetypes: TListView;
    btnOK: TButton;
    btnCancel: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure ltvLinetypesDblClick(Sender: TObject);
  private
    FLinList: TList;

  protected
    procedure ClearLinList();
    procedure PopulateListView();

    function GetSelectedItems: TUdLineTypeArray;
    
  public
    property SelectedItems: TUdLineTypeArray read GetSelectedItems;
    
  end;


implementation

{$R *.dfm}

uses
  SysUtils, UdLineTypes;

var
  STD_LIN_FILE: string = 'acadiso.lin';



//===============================================================================================

procedure TUdLntypLoaderForm.FormCreate(Sender: TObject);
var
  LCurrPath: string;
  LFileName: string;
begin
  FLinList := TList.Create;

  LCurrPath := SysUtils.ExtractFilePath(Application.ExeName);
  LFileName := LCurrPath + STD_LIN_FILE;

  if not SysUtils.FileExists(LFileName) then
    LFileName := LCurrPath + 'Data\' + STD_LIN_FILE;

  UdLineTypes.ParseLinFile(nil, LFileName, FLinList);
  PopulateListView();

  edtFile.Text := STD_LIN_FILE;
end;

procedure TUdLntypLoaderForm.FormDestroy(Sender: TObject);
begin
  ClearLinList();
  
  FLinList.Free;
  FLinList := nil;
end;

procedure TUdLntypLoaderForm.FormShow(Sender: TObject);
begin
  ltvLinetypes.Columns[0].Width := Self.Width div 4;
  ltvLinetypes.Columns[1].Width := Self.Width - ltvLinetypes.Columns[0].Width - 72;
end;





function TUdLntypLoaderForm.GetSelectedItems: TUdLineTypeArray;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to ltvLinetypes.Items.Count - 1 do
  begin
    if ltvLinetypes.Items[I].Selected and
       Assigned(ltvLinetypes.Items[I].Data) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := ltvLinetypes.Items[I].Data;
    end;
  end;
end;

procedure TUdLntypLoaderForm.ltvLinetypesDblClick(Sender: TObject);
begin
  Self.btnOK.Click();
end;



//-----------------------------------------------------------------------------


procedure TUdLntypLoaderForm.ClearLinList();
var
  I: Integer;
begin
  for I := FLinList.Count - 1 downto 0 do TObject(FLinList[I]).Free;
  FLinList.Clear();
end;


procedure TUdLntypLoaderForm.PopulateListView;
var
  I: Integer;
  LItem: TUdLineType;
begin
  ltvLinetypes.Clear();

  for I := 0 to FLinList.Count - 1 do
  begin
    LItem := FLinList.Items[I];
    with ltvLinetypes.Items.Add() do
    begin
      Caption := LItem.Name;
      SubItems.Add(LItem.Comment);
      Data := LItem;
    end;
  end;
end;




procedure TUdLntypLoaderForm.btnFileClick(Sender: TObject);
begin
  if OpenDialog1.Execute() then
  begin
    Self.ClearLinList();

    UdLineTypes.ParseLinFile(nil, OpenDialog1.FileName, FLinList);
    Self.PopulateListView();

    edtFile.Text := OpenDialog1.FileName;

    STD_LIN_FILE := edtFile.Text;
  end;
end;

procedure TUdLntypLoaderForm.btnOKClick(Sender: TObject);
begin
//
end;


procedure TUdLntypLoaderForm.btnCancelClick(Sender: TObject);
begin
//
end;





end.