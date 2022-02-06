object UdStyleNameForm: TUdStyleNameForm
  Left = 539
  Top = 261
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #26679#24335#21517#31216
  ClientHeight = 84
  ClientWidth = 295
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    295
    84)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStyleName: TLabel
    Left = 14
    Top = 20
    Width = 52
    Height = 13
    Caption = #26679#24335#21517#31216':'
  end
  object edtStyleName: TEdit
    Left = 78
    Top = 17
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 215
    Top = 15
    Width = 70
    Height = 23
    Anchors = [akTop, akRight]
    Caption = #30830#23450
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 215
    Top = 50
    Width = 70
    Height = 23
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
  end
end
