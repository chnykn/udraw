object UdLntypLoaderForm: TUdLntypLoaderForm
  Left = 394
  Top = 202
  BorderIcons = [biSystemMenu, biHelp]
  Caption = #21152#36733#25110#37325#36733#32447#24418
  ClientHeight = 322
  ClientWidth = 434
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    434
    322)
  PixelsPerInch = 96
  TextHeight = 13
  object edtFile: TEdit
    Left = 80
    Top = 10
    Width = 346
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ReadOnly = True
    TabOrder = 1
  end
  object btnFile: TButton
    Left = 8
    Top = 9
    Width = 65
    Height = 23
    Caption = #25991#20214'...'
    TabOrder = 2
    OnClick = btnFileClick
  end
  object ltvLinetypes: TListView
    Left = 8
    Top = 42
    Width = 418
    Height = 236
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #32447#24418
      end
      item
        Caption = #35828#26126
      end>
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = ltvLinetypesDblClick
  end
  object btnOK: TButton
    Left = 248
    Top = 289
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 335
    Top = 289
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Linetype(*.lin)|*.lin'
    Left = 195
    Top = 140
  end
end
