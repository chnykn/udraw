object UdTextParamsForm: TUdTextParamsForm
  Left = 410
  Top = 202
  BorderIcons = [biSystemMenu, biHelp]
  Caption = 'New Text Object'
  ClientHeight = 295
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
  DesignSize = (
    524
    295)
  PixelsPerInch = 96
  TextHeight = 13
  object lblTextContents: TLabel
    Left = 8
    Top = 6
    Width = 52
    Height = 13
    Caption = #25991#26412#20869#23481':'
  end
  object lblHeight: TLabel
    Left = 16
    Top = 116
    Width = 28
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #39640#24230':'
  end
  object lblRotation: TLabel
    Left = 16
    Top = 142
    Width = 52
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #26059#36716#35282#24230':'
  end
  object lblWidthFactor: TLabel
    Left = 16
    Top = 169
    Width = 52
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #23485#39640#27604#20363':'
  end
  object lblAlignment: TLabel
    Left = 16
    Top = 196
    Width = 52
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #23545#40784#26041#24335':'
  end
  object lblTextStyle: TLabel
    Left = 16
    Top = 223
    Width = 48
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #25991#26412#26679#24335
  end
  object btnEditTextStyles: TSpeedButton
    Left = 182
    Top = 220
    Width = 23
    Height = 22
    Anchors = [akLeft, akBottom]
    Caption = '<<'
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    OnClick = btnEditTextStylesClick
  end
  object memText: TMemo
    Left = 8
    Top = 27
    Width = 508
    Height = 73
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object edtHeight: TEdit
    Left = 86
    Top = 113
    Width = 90
    Height = 21
    Anchors = [akLeft, akBottom]
    Color = clBtnFace
    Enabled = False
    TabOrder = 1
    Text = '2.5'
  end
  object edtRotation: TEdit
    Left = 86
    Top = 140
    Width = 90
    Height = 21
    Anchors = [akLeft, akBottom]
    Color = clBtnFace
    Enabled = False
    TabOrder = 2
    Text = '0.0'
  end
  object edtWidthFactor: TEdit
    Left = 86
    Top = 167
    Width = 90
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    Text = '1.0'
  end
  object cbxAlignment: TComboBox
    Left = 86
    Top = 194
    Width = 90
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    DropDownCount = 16
    ItemIndex = 0
    TabOrder = 4
    Text = 'LeftTop '
    Items.Strings = (
      'LeftTop '
      'CenterTop '
      'RightTop'
      'LeftCenter '
      'Center '
      'RightCenter'
      'LeftBottom '
      'CenterBottom '
      'RightBottom')
  end
  object cbxTextStyle: TComboBox
    Left = 86
    Top = 221
    Width = 90
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    DropDownCount = 16
    TabOrder = 5
  end
  object gpbInsPoint: TGroupBox
    Left = 307
    Top = 110
    Width = 208
    Height = 129
    Anchors = [akLeft, akRight, akBottom]
    Caption = #25554#20837#28857
    TabOrder = 6
    DesignSize = (
      208
      129)
    object lblX: TLabel
      Left = 17
      Top = 58
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object lblY: TLabel
      Left = 17
      Top = 86
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object ckxSpcPoint: TCheckBox
      Left = 10
      Top = 27
      Width = 103
      Height = 17
      Caption = #25342#21462#23631#24149#28857
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = ckxSpcPointClick
    end
    object edtX: TEdit
      Left = 42
      Top = 55
      Width = 154
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      TabOrder = 1
      Text = '0.0'
    end
    object edtY: TEdit
      Left = 42
      Top = 82
      Width = 154
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      TabOrder = 2
      Text = '0.0'
    end
  end
  object ckxSpcHeight: TCheckBox
    Left = 182
    Top = 114
    Width = 103
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #25342#21462#23631#24149#28857
    Checked = True
    State = cbChecked
    TabOrder = 7
    OnClick = ckxSpcHeightClick
  end
  object ckxSpcRotation: TCheckBox
    Left = 182
    Top = 142
    Width = 103
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #25342#21462#23631#24149#28857
    Checked = True
    State = cbChecked
    TabOrder = 8
    OnClick = ckxSpcRotationClick
  end
  object ckxUpsidedown: TCheckBox
    Left = 16
    Top = 266
    Width = 84
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #19978#19979#20498#32622
    TabOrder = 9
  end
  object ckxBackward: TCheckBox
    Left = 136
    Top = 266
    Width = 66
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #24038#21491#21453#21521
    TabOrder = 10
  end
  object btnOk: TButton
    Left = 346
    Top = 263
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    Default = True
    TabOrder = 11
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 435
    Top = 263
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 12
  end
end
