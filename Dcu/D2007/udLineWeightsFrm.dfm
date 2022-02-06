object UdLineWeightsForm: TUdLineWeightsForm
  Left = 407
  Top = 217
  BorderIcons = [biSystemMenu, biHelp]
  Caption = #32447#23485
  ClientHeight = 235
  ClientWidth = 416
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
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 207
    Height = 194
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      207
      194)
    object Label1: TLabel
      Left = 10
      Top = 7
      Width = 28
      Height = 13
      Caption = #32447#23485':'
    end
    object lstLwts: TListBox
      Left = 10
      Top = 28
      Width = 187
      Height = 164
      Style = lbOwnerDrawFixed
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
      OnClick = lstLwtsClick
      OnDblClick = lstLwtsDblClick
      OnDrawItem = cbxDefLwtDrawItem
    end
  end
  object pnlRight: TPanel
    Left = 207
    Top = 0
    Width = 209
    Height = 194
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      209
      194)
    object Label2: TLabel
      Left = 1
      Top = 67
      Width = 24
      Height = 13
      Caption = #40664#35748
    end
    object ckbDisplayLwt: TCheckBox
      Left = 1
      Top = 28
      Width = 156
      Height = 17
      Caption = #26174#31034#32447#23485
      TabOrder = 0
    end
    object GroupBox1: TGroupBox
      Left = 1
      Top = 112
      Width = 201
      Height = 80
      Anchors = [akLeft, akBottom]
      Caption = #35843#25972#26174#31034#27604#20363
      TabOrder = 1
      DesignSize = (
        201
        80)
      object tkbAdjScale: TTrackBar
        Left = 9
        Top = 29
        Width = 182
        Height = 41
        Anchors = [akLeft, akTop, akRight]
        Max = 15
        Min = 5
        Position = 10
        TabOrder = 0
        OnChange = tkbAdjScaleChange
      end
    end
    object cbxDefLwt: TComboBox
      Left = 51
      Top = 64
      Width = 151
      Height = 22
      Style = csOwnerDrawFixed
      TabOrder = 2
      OnChange = cbxDefLwtChange
      OnDrawItem = cbxDefLwtDrawItem
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 194
    Width = 416
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      416
      41)
    object lblCurLwtCaption: TLabel
      Left = 10
      Top = 15
      Width = 52
      Height = 13
      Caption = #24403#21069#32447#23485':'
    end
    object lblCurLwt: TLabel
      Left = 88
      Top = 15
      Width = 44
      Height = 13
      Caption = 'lblCurLwt'
    end
    object btnOK: TButton
      Left = 251
      Top = 12
      Width = 75
      Height = 23
      Anchors = [akRight, akBottom]
      Caption = #30830#23450
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 332
      Top = 12
      Width = 75
      Height = 23
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 1
    end
  end
end
