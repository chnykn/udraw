object UdPointStyleForm: TUdPointStyleForm
  Left = 531
  Top = 235
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #28857#26679#24335
  ClientHeight = 285
  ClientWidth = 245
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
    245
    285)
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 8
    Top = 8
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox2: TPaintBox
    Tag = 1
    Left = 55
    Top = 8
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox3: TPaintBox
    Tag = 2
    Left = 102
    Top = 8
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox4: TPaintBox
    Tag = 3
    Left = 149
    Top = 8
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox5: TPaintBox
    Tag = 4
    Left = 197
    Top = 8
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox6: TPaintBox
    Tag = 32
    Left = 8
    Top = 44
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox7: TPaintBox
    Tag = 33
    Left = 55
    Top = 44
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox8: TPaintBox
    Tag = 34
    Left = 102
    Top = 44
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox9: TPaintBox
    Tag = 35
    Left = 149
    Top = 44
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox10: TPaintBox
    Tag = 36
    Left = 197
    Top = 44
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox11: TPaintBox
    Tag = 64
    Left = 8
    Top = 80
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox12: TPaintBox
    Tag = 65
    Left = 55
    Top = 80
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox13: TPaintBox
    Tag = 66
    Left = 102
    Top = 80
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox14: TPaintBox
    Tag = 67
    Left = 149
    Top = 80
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox15: TPaintBox
    Tag = 68
    Left = 197
    Top = 80
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox16: TPaintBox
    Tag = 96
    Left = 8
    Top = 116
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox17: TPaintBox
    Tag = 97
    Left = 55
    Top = 116
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox18: TPaintBox
    Tag = 98
    Left = 102
    Top = 116
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox19: TPaintBox
    Tag = 99
    Left = 149
    Top = 116
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object PaintBox20: TPaintBox
    Tag = 100
    Left = 197
    Top = 116
    Width = 40
    Height = 30
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
  end
  object lblPointSize: TLabel
    Left = 8
    Top = 165
    Width = 40
    Height = 13
    Caption = #28857#22823#23567':'
  end
  object edtSize: TEdit
    Left = 64
    Top = 162
    Width = 137
    Height = 21
    TabOrder = 1
    Text = '16.000'
  end
  object rdbWindowsPixels: TRadioButton
    Left = 8
    Top = 195
    Width = 223
    Height = 17
    Caption = #30456#23545#20110#23631#24149#35774#32622#22823#23567
    Checked = True
    TabOrder = 0
    TabStop = True
  end
  object rdbDrawingUnits: TRadioButton
    Left = 8
    Top = 218
    Width = 223
    Height = 17
    Caption = #25353#32477#23545#21333#20301#35774#32622#22823#23567
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 72
    Top = 253
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 157
    Top = 253
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 4
  end
end
