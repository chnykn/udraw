object UdActionInsertForm: TUdActionInsertForm
  Left = 548
  Top = 289
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #22359#25554#20837
  ClientHeight = 284
  ClientWidth = 492
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
    492
    284)
  PixelsPerInch = 96
  TextHeight = 13
  object lblName: TLabel
    Left = 15
    Top = 24
    Width = 28
    Height = 13
    Caption = #21517#31216':'
  end
  object cbxName: TComboBox
    Left = 64
    Top = 21
    Width = 223
    Height = 21
    Style = csDropDownList
    DropDownCount = 12
    TabOrder = 0
    OnChange = cbxNameChange
  end
  object gpbInsPoint: TGroupBox
    Left = 15
    Top = 88
    Width = 150
    Height = 146
    Caption = #25554#20837#28857
    TabOrder = 1
    DesignSize = (
      150
      146)
    object lblInsX: TLabel
      Left = 15
      Top = 59
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object lblInsY: TLabel
      Left = 15
      Top = 90
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object edtPointX: TEdit
      Left = 35
      Top = 56
      Width = 102
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 0
      Text = '0.00'
    end
    object edtPointY: TEdit
      Left = 35
      Top = 87
      Width = 102
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 1
      Text = '0.00'
    end
    object ckbSpeInsPnt: TCheckBox
      Left = 15
      Top = 25
      Width = 122
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = #22312#23631#24149#19978#25351#23450
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = SpecifyOnSecreenClick
    end
  end
  object grbScale: TGroupBox
    Left = 171
    Top = 88
    Width = 151
    Height = 146
    Caption = #27604#20363
    TabOrder = 2
    DesignSize = (
      151
      146)
    object lblScaleX: TLabel
      Left = 15
      Top = 59
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object lblScaleY: TLabel
      Left = 15
      Top = 90
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object edtScaleX: TEdit
      Left = 35
      Top = 56
      Width = 103
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = '1.00'
      OnChange = edtScaleXChange
    end
    object edtScaleY: TEdit
      Left = 35
      Top = 87
      Width = 103
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 1
      Text = '1.00'
    end
    object ckbSpeScale: TCheckBox
      Tag = 1
      Left = 15
      Top = 25
      Width = 123
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = #22312#23631#24149#19978#25351#23450
      TabOrder = 2
      OnClick = SpecifyOnSecreenClick
    end
    object ckbUniformScale: TCheckBox
      Left = 15
      Top = 117
      Width = 131
      Height = 17
      Caption = #32479#19968#27604#20363
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = ckbUniformScaleClick
    end
  end
  object grbRoatation: TGroupBox
    Left = 327
    Top = 88
    Width = 150
    Height = 146
    Caption = #26059#36716
    TabOrder = 3
    DesignSize = (
      150
      146)
    object lblAngle: TLabel
      Left = 15
      Top = 59
      Width = 28
      Height = 13
      Caption = #35282#24230':'
    end
    object edtAngle: TEdit
      Left = 52
      Top = 56
      Width = 85
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = '0.00'
    end
    object ckbSpeAngle: TCheckBox
      Tag = 2
      Left = 15
      Top = 25
      Width = 122
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = #22312#23631#24149#19978#25351#23450
      TabOrder = 1
      OnClick = SpecifyOnSecreenClick
    end
  end
  object pnlPreview: TPanel
    Left = 369
    Top = 5
    Width = 108
    Height = 69
    Anchors = [akTop, akRight]
    BevelOuter = bvLowered
    Color = clBlack
    ParentBackground = False
    TabOrder = 4
  end
  object btnOK: TButton
    Left = 308
    Top = 251
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    Default = True
    TabOrder = 5
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 397
    Top = 251
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 6
  end
  object ckbExplode: TCheckBox
    Left = 15
    Top = 254
    Width = 86
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #20998#35299
    TabOrder = 7
  end
end
