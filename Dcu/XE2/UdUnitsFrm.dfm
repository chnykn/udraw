object UdUnitsForm: TUdUnitsForm
  Left = 734
  Top = 229
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #22270#24418#21333#20301
  ClientHeight = 275
  ClientWidth = 371
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
    371
    275)
  PixelsPerInch = 96
  TextHeight = 13
  object gpbLength: TGroupBox
    Left = 8
    Top = 5
    Width = 175
    Height = 151
    Caption = #38271#24230
    TabOrder = 1
    object lblLenUnit: TLabel
      Left = 10
      Top = 22
      Width = 28
      Height = 13
      Caption = #31867#22411':'
    end
    object lblLenPrecision: TLabel
      Left = 10
      Top = 69
      Width = 28
      Height = 13
      Caption = #31934#24230':'
    end
    object cbxLenUnit: TComboBox
      Left = 10
      Top = 41
      Width = 155
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbxLenUnitSelect
      Items.Strings = (
        'Scientific '
        'Decimal '
        'Engineering '
        'Architectural  '
        'Fractional')
    end
    object cbxLenPrecision: TComboBox
      Left = 10
      Top = 88
      Width = 155
      Height = 21
      Style = csDropDownList
      TabOrder = 1
      OnSelect = cbxLenPrecisionSelect
    end
  end
  object gpbAngle: TGroupBox
    Left = 192
    Top = 5
    Width = 175
    Height = 151
    Caption = #35282#24230
    TabOrder = 2
    object lblAngUnit: TLabel
      Left = 10
      Top = 22
      Width = 28
      Height = 13
      Caption = #31867#22411':'
    end
    object lblAngPrecision: TLabel
      Left = 10
      Top = 69
      Width = 28
      Height = 13
      Caption = #31934#24230':'
    end
    object cbxAngPrecision: TComboBox
      Left = 10
      Top = 88
      Width = 155
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbxAngPrecisionSelect
    end
    object cbxAngUnit: TComboBox
      Left = 10
      Top = 41
      Width = 155
      Height = 21
      Style = csDropDownList
      TabOrder = 1
      OnSelect = cbxAngUnitSelect
      Items.Strings = (
        'Degrees'
        'DegMinSec'
        'Grads'
        'Radians')
    end
    object ckbClockwise: TCheckBox
      Left = 10
      Top = 122
      Width = 97
      Height = 17
      Caption = #39034#26102#38024
      TabOrder = 2
      OnClick = ckbClockwiseClick
    end
  end
  object gpbSample: TGroupBox
    Left = 8
    Top = 162
    Width = 359
    Height = 69
    Caption = #36755#20986#26679#20363
    TabOrder = 3
    object lblSampleLen: TLabel
      Left = 13
      Top = 23
      Width = 51
      Height = 13
      Caption = 'SampleLen'
    end
    object lblSampleAng: TLabel
      Left = 13
      Top = 47
      Width = 53
      Height = 13
      Caption = 'SampleAng'
    end
  end
  object btnCancel: TButton
    Left = 282
    Top = 245
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object btnOK: TButton
    Left = 196
    Top = 245
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnDirection: TButton
    Left = 10
    Top = 245
    Width = 90
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = #26041#21521'...'
    TabOrder = 5
    OnClick = btnDirectionClick
  end
end
