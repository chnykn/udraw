object UdBaseAngleForm: TUdBaseAngleForm
  Left = 574
  Top = 226
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #26041#21521
  ClientHeight = 227
  ClientWidth = 230
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
    230
    227)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 66
    Top = 196
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    ModalResult = 1
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 147
    Top = 196
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 1
  end
  object gpbBaseAngle: TGroupBox
    Left = 9
    Top = 8
    Width = 213
    Height = 174
    Caption = #22522#20934#35282#24230
    TabOrder = 2
    object Label1: TLabel
      Left = 109
      Top = 23
      Width = 6
      Height = 13
      Caption = '0'
    end
    object Label2: TLabel
      Left = 109
      Top = 53
      Width = 12
      Height = 13
      Caption = '90'
    end
    object Label3: TLabel
      Left = 109
      Top = 83
      Width = 18
      Height = 13
      Caption = '180'
    end
    object Label4: TLabel
      Left = 109
      Top = 113
      Width = 18
      Height = 13
      Caption = '270'
    end
    object rdbEast: TRadioButton
      Left = 12
      Top = 22
      Width = 82
      Height = 17
      Caption = #19996
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rdbAngleClick
    end
    object rdbNorth: TRadioButton
      Tag = 1
      Left = 12
      Top = 51
      Width = 82
      Height = 17
      Caption = #21271
      TabOrder = 1
      OnClick = rdbAngleClick
    end
    object rdbWest: TRadioButton
      Tag = 2
      Left = 12
      Top = 81
      Width = 82
      Height = 17
      Caption = #35199
      TabOrder = 2
      OnClick = rdbAngleClick
    end
    object rdbSouth: TRadioButton
      Tag = 3
      Left = 12
      Top = 111
      Width = 82
      Height = 17
      Caption = #21335
      TabOrder = 3
      OnClick = rdbAngleClick
    end
    object rdbOther: TRadioButton
      Tag = 4
      Left = 12
      Top = 141
      Width = 82
      Height = 17
      Caption = #20854#20182
      TabOrder = 4
      OnClick = rdbAngleClick
    end
    object edtAngle: TEdit
      Left = 109
      Top = 140
      Width = 90
      Height = 21
      Enabled = False
      TabOrder = 5
      Text = '0'
    end
  end
end
