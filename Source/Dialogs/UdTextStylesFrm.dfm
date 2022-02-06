object UdTextStylesForm: TUdTextStylesForm
  Left = 404
  Top = 184
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #25991#23383#26679#24335
  ClientHeight = 298
  ClientWidth = 524
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
    524
    298)
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 441
    Top = 165
    Width = 14
    Height = 15
    Picture.Data = {
      07544269746D61709E020000424D9E0200000000000036000000280000000E00
      00000E0000000100180000000000680200000000000000000000000000000000
      0000FFFFFFC0DCC0808080FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF808080C0DCC0
      FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFF000000
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFF
      FFFFFFFF0000000000C0DCC0000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00C0DCC0FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
      00FFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFF808080808080FFFFFF80808080
      8080FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFF
      FFFF000000FFFFFF000000FFFFFF000000FFFFFFFFFFFFFFFFFF000000FFFFFF
      0000FFFFFFFFFFFFFFFFFFFFFFFF000000000000000000FFFFFF000000FFFFFF
      FFFFFFFFFFFF000000FFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFF
      000000FFFFFFFFFFFF000000000000000000FFFFFFFFFFFF0000FFFFFFFFFFFF
      FFFFFF808080000000000000000000808080FFFFFF000000FFFFFF000000FFFF
      FFFFFFFF0000FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF000000FFFF
      FFFFFFFF000000FFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFF0000
      00000000000000FFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFF0000FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF0000}
    Transparent = True
    Visible = False
  end
  object Image2: TImage
    Left = 461
    Top = 165
    Width = 14
    Height = 15
    Picture.Data = {
      07544269746D61709E020000424D9E0200000000000036000000280000000E00
      00000E0000000100180000000000680200000000000000000000000000000000
      0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      000000000000000000000000000000000000FFFFFFFFFFFF0000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFF
      FFFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00000000FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF8080808080808080
      80808080808080808080000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000FFFF
      FFFFFFFFFFFFFFFFFFFF808080808080FFFFFFFFFFFF000000000000FFFFFFFF
      FFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFF808080808080FFFFFFFF
      FFFF000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFF
      FFFF808080000000FFFFFFFFFFFF000000000000FFFFFFFFFFFF000000FFFFFF
      0000FFFFFFFFFFFFFFFFFFFFFFFF808080000000000000FFFFFF000000000000
      FFFFFF000000000000FFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFF808080000000
      000000000000000000000000000000000000000000FFFFFF0000FFFFFF808080
      FFFFFFFFFFFF808080808080FFFFFFFFFFFF808080FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFF0000FFFFFF808080808080FFFFFF808080808080FFFFFF8080808080
      80FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFF8080800000008080808080
      80000000808080808080808080FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF0000}
    Transparent = True
    Visible = False
  end
  object gpbStyleName: TGroupBox
    Left = 8
    Top = 8
    Width = 423
    Height = 58
    Caption = #26679#24335#21517#31216
    TabOrder = 0
    object cbxStyleName: TComboBox
      Left = 11
      Top = 25
      Width = 150
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbxStyleNameChange
    end
    object btnNew: TButton
      Left = 177
      Top = 23
      Width = 75
      Height = 23
      Caption = #26032#24314'..'
      TabOrder = 1
      OnClick = btnNewClick
    end
    object btnRename: TButton
      Left = 255
      Top = 23
      Width = 75
      Height = 23
      Caption = #37325#21629#21517'..'
      TabOrder = 2
      OnClick = btnRenameClick
    end
    object btnDelete: TButton
      Left = 333
      Top = 23
      Width = 75
      Height = 23
      Caption = #21024#38500
      TabOrder = 3
      OnClick = btnDeleteClick
    end
  end
  object gpbFont: TGroupBox
    Left = 8
    Top = 74
    Width = 423
    Height = 106
    Caption = #23383#20307
    TabOrder = 1
    object lblFontName: TLabel
      Left = 11
      Top = 22
      Width = 40
      Height = 13
      Caption = #23383#20307#21517':'
    end
    object lblFontStyle: TLabel
      Left = 177
      Top = 22
      Width = 52
      Height = 13
      Caption = #23383#20307#26679#24335':'
    end
    object lblHeight: TLabel
      Left = 341
      Top = 22
      Width = 28
      Height = 13
      Caption = #39640#24230':'
    end
    object cbxFontName: TComboBox
      Left = 11
      Top = 43
      Width = 150
      Height = 22
      Style = csOwnerDrawFixed
      TabOrder = 0
      OnChange = cbxFontNameChange
      OnDrawItem = cbxFontNameDrawItem
    end
    object cbxFontStyle: TComboBox
      Left = 177
      Top = 43
      Width = 150
      Height = 21
      Style = csDropDownList
      ItemIndex = 3
      TabOrder = 1
      Text = 'Regular'
      OnChange = cbxFontStyleChange
      Items.Strings = (
        'Bold'
        'Bold Italic'
        'Italic'
        'Regular')
    end
    object edtHeight: TEdit
      Left = 341
      Top = 43
      Width = 70
      Height = 21
      TabOrder = 2
      Text = '2.5000'
      OnKeyUp = edtHeightKeyUp
    end
    object ckbUseBigfont: TCheckBox
      Left = 11
      Top = 78
      Width = 97
      Height = 17
      Caption = #20351#29992#22823#23383#20307
      TabOrder = 3
      OnClick = ckbUseBigfontClick
    end
  end
  object gpbEffects: TGroupBox
    Left = 8
    Top = 187
    Width = 213
    Height = 99
    Anchors = [akLeft, akBottom]
    Caption = #25928#26524
    TabOrder = 2
    object lblWidthFactor: TLabel
      Left = 11
      Top = 70
      Width = 52
      Height = 13
      Caption = #23485#39640#27604#20363':'
    end
    object ckbUpsideDown: TCheckBox
      Left = 11
      Top = 28
      Width = 92
      Height = 17
      Caption = #19978#19979#39072#20498
      TabOrder = 0
      OnClick = ckbUpsideDownClick
    end
    object ckbBackwards: TCheckBox
      Left = 114
      Top = 28
      Width = 94
      Height = 17
      Caption = #24038#21491#21453#21521
      TabOrder = 1
      OnClick = ckbBackwardsClick
    end
    object edtWidthFactor: TEdit
      Left = 94
      Top = 68
      Width = 87
      Height = 21
      TabOrder = 2
      OnKeyUp = edtWidthFactorKeyUp
    end
  end
  object gpbPreview: TGroupBox
    Left = 234
    Top = 187
    Width = 275
    Height = 99
    Anchors = [akLeft, akRight, akBottom]
    Caption = #39044#35272
    TabOrder = 3
    DesignSize = (
      275
      99)
    object pnlPreview: TPanel
      Left = 9
      Top = 18
      Width = 256
      Height = 45
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object ptbPreview: TPaintBox
        Left = 0
        Top = 0
        Width = 256
        Height = 45
        Align = alClient
        OnPaint = ptbPreviewPaint
      end
    end
    object edtPreview: TEdit
      Left = 9
      Top = 70
      Width = 167
      Height = 21
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 1
      Text = 'AaBbCcDd'
    end
    object btnPreview: TButton
      Left = 181
      Top = 70
      Width = 84
      Height = 22
      Anchors = [akRight, akBottom]
      Caption = #39044#35272
      TabOrder = 2
      OnClick = btnPreviewClick
    end
  end
  object btnApply: TButton
    Left = 439
    Top = 30
    Width = 75
    Height = 23
    Anchors = [akTop, akRight]
    Caption = #24212#29992
    TabOrder = 4
    OnClick = btnApplyClick
  end
  object btnCancel: TButton
    Left = 439
    Top = 62
    Width = 75
    Height = 23
    Anchors = [akTop, akRight]
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 5
  end
end
