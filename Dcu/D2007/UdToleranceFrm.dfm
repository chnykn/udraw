object UdToleranceForm: TUdToleranceForm
  Left = 410
  Top = 269
  BorderIcons = [biSystemMenu, biHelp]
  Caption = #24418#20301#20844#24046
  ClientHeight = 183
  ClientWidth = 598
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
    598
    183)
  PixelsPerInch = 96
  TextHeight = 13
  object lblHeight: TLabel
    Left = 66
    Top = 107
    Width = 36
    Height = 13
    Caption = #39640#24230#65306
  end
  object lblDatumID: TLabel
    Left = 19
    Top = 136
    Width = 72
    Height = 13
    Caption = #22522#20934#26631#35782#31526#65306
  end
  object lblProTolZone: TLabel
    Left = 251
    Top = 107
    Width = 72
    Height = 13
    Caption = #25237#24433#20844#24046#24102#65306
  end
  object gpbSym: TGroupBox
    Left = 7
    Top = 8
    Width = 42
    Height = 81
    Caption = #31526#21495
    TabOrder = 0
    object pnlSym1: TPanel
      Left = 9
      Top = 18
      Width = 22
      Height = 22
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 0
    end
    object pnlSym2: TPanel
      Left = 9
      Top = 50
      Width = 22
      Height = 22
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 1
    end
  end
  object gpbTolerance1: TGroupBox
    Left = 53
    Top = 8
    Width = 149
    Height = 81
    Caption = #20844#24046'1'
    TabOrder = 1
    DesignSize = (
      149
      81)
    object pnlTol11: TPanel
      Left = 9
      Top = 18
      Width = 22
      Height = 22
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 0
    end
    object pnlTol12: TPanel
      Left = 9
      Top = 50
      Width = 22
      Height = 22
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 1
    end
    object edtTol11: TEdit
      Left = 38
      Top = 19
      Width = 73
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
    object edtTol12: TEdit
      Left = 38
      Top = 51
      Width = 73
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
    end
    object pnlMet11: TPanel
      Left = 117
      Top = 18
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 4
    end
    object pnlMet12: TPanel
      Left = 117
      Top = 50
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 5
    end
  end
  object gpbTolerance2: TGroupBox
    Left = 206
    Top = 8
    Width = 149
    Height = 81
    Caption = #20844#24046'2'
    TabOrder = 2
    DesignSize = (
      149
      81)
    object pnlTol21: TPanel
      Left = 9
      Top = 18
      Width = 22
      Height = 22
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 0
    end
    object pnlTol22: TPanel
      Left = 9
      Top = 50
      Width = 22
      Height = 22
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 1
    end
    object edtTol21: TEdit
      Left = 38
      Top = 19
      Width = 73
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
    object edtTol22: TEdit
      Left = 38
      Top = 51
      Width = 73
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
    end
    object pnlMet21: TPanel
      Left = 117
      Top = 18
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 4
    end
    object pnlMet22: TPanel
      Left = 117
      Top = 50
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 5
    end
  end
  object gpbDatum1: TGroupBox
    Left = 358
    Top = 8
    Width = 74
    Height = 81
    Caption = #22522#20934'1'
    TabOrder = 3
    DesignSize = (
      74
      81)
    object edtDat11: TEdit
      Left = 6
      Top = 19
      Width = 33
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object edtDat12: TEdit
      Left = 6
      Top = 51
      Width = 33
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object pnlDat11: TPanel
      Left = 44
      Top = 18
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 2
    end
    object pnlDat12: TPanel
      Left = 44
      Top = 50
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 3
    end
  end
  object gpbDatum2: TGroupBox
    Left = 438
    Top = 8
    Width = 74
    Height = 81
    Caption = #22522#20934'2'
    TabOrder = 4
    DesignSize = (
      74
      81)
    object edtDat21: TEdit
      Left = 6
      Top = 19
      Width = 33
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object edtDat22: TEdit
      Left = 6
      Top = 51
      Width = 33
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object pnlDat21: TPanel
      Left = 44
      Top = 18
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 2
    end
    object pnlDat22: TPanel
      Left = 44
      Top = 50
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 3
    end
  end
  object gpbDatum3: TGroupBox
    Left = 517
    Top = 8
    Width = 74
    Height = 81
    Caption = #22522#20934'3'
    TabOrder = 5
    DesignSize = (
      74
      81)
    object edtDat31: TEdit
      Left = 6
      Top = 19
      Width = 33
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object edtDat32: TEdit
      Left = 6
      Top = 51
      Width = 33
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object pnlDat31: TPanel
      Left = 44
      Top = 18
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 2
    end
    object pnlDat32: TPanel
      Left = 44
      Top = 50
      Width = 22
      Height = 22
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      Color = clBlack
      ParentBackground = False
      TabOrder = 3
    end
  end
  object edtHeight: TEdit
    Left = 111
    Top = 104
    Width = 120
    Height = 21
    TabOrder = 6
  end
  object edtDatID: TEdit
    Left = 111
    Top = 133
    Width = 120
    Height = 21
    TabOrder = 7
  end
  object pnlPTZ: TPanel
    Left = 384
    Top = 103
    Width = 24
    Height = 22
    Anchors = [akTop, akRight]
    BevelOuter = bvNone
    Color = clBlack
    ParentBackground = False
    TabOrder = 8
  end
  object btnOK: TButton
    Left = 412
    Top = 152
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    Default = True
    ModalResult = 1
    TabOrder = 9
  end
  object btnCancel: TButton
    Left = 502
    Top = 152
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 10
  end
end
