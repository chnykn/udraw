object UdColorsForm: TUdColorsForm
  Left = 406
  Top = 177
  Anchors = [akLeft, akBottom]
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #36873#25321#39068#33394
  ClientHeight = 346
  ClientWidth = 402
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
    402
    346)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 388
    Height = 304
    ActivePage = TabSheet1
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = ' '#32034#24341#39068#33394' '
      DesignSize = (
        380
        276)
      object lblIndexColor: TLabel
        Left = 6
        Top = 172
        Width = 3
        Height = 13
      end
      object Label4: TLabel
        Left = 6
        Top = 251
        Width = 28
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = #39068#33394':'
      end
      object lblIndexColor2: TLabel
        Left = 146
        Top = 172
        Width = 3
        Height = 13
      end
      object pnlIndexColor: TPanel
        Left = 5
        Top = 5
        Width = 370
        Height = 161
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
      end
      object pnlIndexPreview: TPanel
        Left = 323
        Top = 234
        Width = 47
        Height = 40
        Anchors = [akRight, akBottom]
        BevelInner = bvLowered
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
      end
      object btnByLayer: TButton
        Left = 213
        Top = 189
        Width = 75
        Height = 22
        Anchors = [akTop, akRight]
        Caption = 'ByLayer'
        TabOrder = 2
        OnClick = btnByLayerClick
      end
      object btnByBlock: TButton
        Left = 295
        Top = 189
        Width = 75
        Height = 22
        Anchors = [akTop, akRight]
        Caption = 'ByBlock'
        TabOrder = 3
        OnClick = btnByBlockClick
      end
      object edtIndexColor: TEdit
        Left = 47
        Top = 248
        Width = 213
        Height = 21
        Anchors = [akLeft, akBottom]
        TabOrder = 4
        Text = 'ByLayer'
        OnChange = edtIndexColorChange
      end
    end
    object TabSheet2: TTabSheet
      Caption = '  '#30495#24425#33394'  '
      ImageIndex = 1
      DesignSize = (
        380
        276)
      object Label1: TLabel
        Left = 12
        Top = 252
        Width = 16
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akBottom]
        Caption = #32418':'
      end
      object Label2: TLabel
        Left = 120
        Top = 252
        Width = 16
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akBottom]
        Caption = #32511':'
      end
      object Label3: TLabel
        Left = 223
        Top = 252
        Width = 16
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akBottom]
        Caption = #34013':'
      end
      object lblTrueColor: TLabel
        Left = 6
        Top = 223
        Width = 3
        Height = 13
      end
      object lblSat: TLabel
        Left = 126
        Top = 7
        Width = 40
        Height = 13
        Alignment = taRightJustify
        Caption = #39281#21644#24230':'
      end
      object lblHue: TLabel
        Left = 12
        Top = 7
        Width = 28
        Height = 13
        Alignment = taRightJustify
        Caption = #33394#35843':'
      end
      object lblLum: TLabel
        Left = 263
        Top = 7
        Width = 28
        Height = 13
        Alignment = taRightJustify
        Caption = #20142#24230':'
      end
      object pnlTruePreview: TPanel
        Left = 323
        Top = 234
        Width = 47
        Height = 40
        Anchors = [akRight, akBottom]
        BevelInner = bvLowered
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
      end
      object pnlTrueColor: TPanel
        Left = 2
        Top = 31
        Width = 148
        Height = 186
        BevelOuter = bvNone
        TabOrder = 1
      end
      object edtRed: TEdit
        Left = 34
        Top = 249
        Width = 51
        Height = 21
        Anchors = [akLeft, akBottom]
        TabOrder = 2
        Text = '255'
        OnChange = edtRGBChange
        OnExit = edtRGBExit
      end
      object edtGreen: TEdit
        Tag = 1
        Left = 142
        Top = 249
        Width = 51
        Height = 21
        Anchors = [akLeft, akBottom]
        TabOrder = 3
        Text = '255'
        OnChange = edtRGBChange
        OnExit = edtRGBExit
      end
      object edtBlue: TEdit
        Tag = 2
        Left = 245
        Top = 249
        Width = 51
        Height = 21
        Anchors = [akLeft, akBottom]
        TabOrder = 4
        Text = '255'
        OnChange = edtRGBChange
        OnExit = edtRGBExit
      end
      object pnlHSL: TPanel
        Left = 155
        Top = 31
        Width = 220
        Height = 189
        BevelOuter = bvNone
        TabOrder = 5
      end
      object edtSat: TEdit
        Tag = 1
        Left = 167
        Top = 4
        Width = 42
        Height = 21
        TabOrder = 6
        Text = '0'
        OnChange = edtHSLChange
        OnExit = edtHSLExit
      end
      object edtHue: TEdit
        Left = 42
        Top = 4
        Width = 42
        Height = 21
        TabOrder = 7
        Text = '0'
        OnChange = edtHSLChange
        OnExit = edtHSLExit
      end
      object edtLum: TEdit
        Tag = 2
        Left = 292
        Top = 4
        Width = 42
        Height = 21
        TabOrder = 8
        Text = '100'
        OnChange = edtHSLChange
        OnExit = edtHSLExit
      end
      object udnHue: TUpDown
        Left = 84
        Top = 4
        Width = 16
        Height = 21
        Associate = edtHue
        Max = 360
        Increment = 4
        TabOrder = 9
        OnChangingEx = udnHSLChangingEx
      end
      object udnSat: TUpDown
        Tag = 1
        Left = 209
        Top = 4
        Width = 16
        Height = 21
        Associate = edtSat
        TabOrder = 10
        OnChangingEx = udnHSLChangingEx
      end
      object udnLum: TUpDown
        Tag = 2
        Left = 334
        Top = 4
        Width = 16
        Height = 21
        Associate = edtLum
        Position = 100
        TabOrder = 11
        OnChangingEx = udnHSLChangingEx
      end
    end
  end
  object btnOK: TButton
    Left = 220
    Top = 318
    Width = 80
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 310
    Top = 318
    Width = 80
    Height = 22
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
  end
end
