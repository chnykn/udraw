object UdDimStylesForm: TUdDimStylesForm
  Left = 569
  Top = 169
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #26631#27880#26679#24335
  ClientHeight = 432
  ClientWidth = 559
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    559
    432)
  PixelsPerInch = 96
  TextHeight = 12
  object PageControl1: TPageControl
    Left = 8
    Top = 5
    Width = 545
    Height = 390
    ActivePage = tabList
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = PageControl1Change
    object tabList: TTabSheet
      Caption = #26679#24335#21015#34920
      object lblStyles: TLabel
        Left = 10
        Top = 40
        Width = 24
        Height = 12
        Caption = #26679#24335
      end
      object lblStyleName: TLabel
        Left = 10
        Top = 265
        Width = 48
        Height = 12
        Caption = #32534#36753#21517#31216
      end
      object lblPreview: TLabel
        Left = 188
        Top = 40
        Width = 24
        Height = 12
        Caption = #39044#35272
      end
      object lblCurrentStyle: TLabel
        Left = 10
        Top = 16
        Width = 78
        Height = 12
        Caption = #24403#21069#26631#27880#26679#24335':'
      end
      object lblCurrStyle: TLabel
        Left = 120
        Top = 16
        Width = 6
        Height = 12
      end
      object ltbDimStyles: TListBox
        Left = 10
        Top = 61
        Width = 163
        Height = 190
        ItemHeight = 12
        TabOrder = 0
        OnClick = ltbDimStylesClick
      end
      object edtStyleName: TEdit
        Left = 10
        Top = 284
        Width = 163
        Height = 20
        TabOrder = 1
        OnChange = edtStyleNameChange
      end
      object btnNew: TButton
        Left = 440
        Top = 60
        Width = 80
        Height = 23
        Caption = 'New'
        TabOrder = 2
        OnClick = btnNewClick
      end
      object btnDelete: TButton
        Left = 440
        Top = 99
        Width = 80
        Height = 23
        Caption = 'Delete'
        TabOrder = 3
        OnClick = btnDeleteClick
      end
      object btnSetCurrent: TButton
        Left = 440
        Top = 139
        Width = 80
        Height = 23
        Caption = 'Set Current'
        TabOrder = 4
        OnClick = btnSetCurrentClick
      end
    end
    object tabLines: TTabSheet
      Caption = #30452#32447
      ImageIndex = 1
      object gpbDimLines: TGroupBox
        Left = 5
        Top = 3
        Width = 281
        Height = 204
        Caption = #23610#23544#32447
        TabOrder = 0
        object lblColor: TLabel
          Left = 10
          Top = 25
          Width = 30
          Height = 12
          Caption = #39068#33394':'
        end
        object lblLineType: TLabel
          Left = 10
          Top = 55
          Width = 30
          Height = 12
          Caption = #32447#24418':'
        end
        object lblLineWeight: TLabel
          Left = 10
          Top = 86
          Width = 30
          Height = 12
          Caption = #32447#23485':'
        end
        object lblExtBeyondTicks: TLabel
          Left = 10
          Top = 117
          Width = 54
          Height = 12
          Caption = #36229#20986#26631#35760':'
        end
        object lblBaselineSpacing: TLabel
          Left = 10
          Top = 148
          Width = 54
          Height = 12
          Caption = #22522#32447#38388#36317':'
        end
        object lblSuppressLine: TLabel
          Left = 10
          Top = 179
          Width = 24
          Height = 12
          Caption = #38544#34255
        end
        object edtExtBeyondTicks: TEdit
          Left = 166
          Top = 114
          Width = 75
          Height = 20
          Enabled = False
          TabOrder = 0
          Text = '0'
          OnChange = edtDimStyleLinesPropChange
        end
        object udnExtBeyondTicks: TUpDown
          Left = 241
          Top = 114
          Width = 17
          Height = 20
          Enabled = False
          Max = 32000
          TabOrder = 1
          OnChangingEx = udnDimStyleLinesPropChangingEx
        end
        object ckbSuppressLine1: TCheckBox
          Left = 85
          Top = 178
          Width = 87
          Height = 17
          Caption = #23610#23544#32447'1'
          TabOrder = 2
          OnClick = ckbDimStyleLinesPropSuppressClick
        end
        object ckbSuppressLine2: TCheckBox
          Tag = 1
          Left = 179
          Top = 178
          Width = 94
          Height = 17
          Caption = #23610#23544#32447'2'
          TabOrder = 3
          OnClick = ckbDimStyleLinesPropSuppressClick
        end
        object edtBaselineSpacing: TEdit
          Tag = 1
          Left = 166
          Top = 145
          Width = 75
          Height = 20
          TabOrder = 4
          Text = '0'
          OnChange = edtDimStyleLinesPropChange
        end
        object upnBaselineSpacing: TUpDown
          Tag = 1
          Left = 241
          Top = 145
          Width = 17
          Height = 20
          Max = 32000
          TabOrder = 5
          OnChangingEx = udnDimStyleLinesPropChangingEx
        end
      end
      object gpbExtLines: TGroupBox
        Left = 5
        Top = 213
        Width = 525
        Height = 145
        Caption = #23610#23544#30028#32447
        TabOrder = 1
        object lblExtColor: TLabel
          Left = 10
          Top = 25
          Width = 30
          Height = 12
          Caption = #39068#33394':'
        end
        object lblExtLineType1: TLabel
          Left = 10
          Top = 55
          Width = 84
          Height = 12
          Caption = #23610#23544#30028#32447'1'#32447#24418':'
        end
        object lblExtLineWeight: TLabel
          Left = 10
          Top = 117
          Width = 30
          Height = 12
          Caption = #32447#23485':'
        end
        object lblExtLineType2: TLabel
          Left = 10
          Top = 86
          Width = 84
          Height = 12
          Caption = #23610#23544#30028#32447'2'#32447#24418':'
        end
        object lblExtBeyondDimLines: TLabel
          Left = 287
          Top = 25
          Width = 66
          Height = 12
          Caption = #36229#20986#23610#23544#32447':'
        end
        object lblExtOriginOffset: TLabel
          Left = 287
          Top = 55
          Width = 66
          Height = 12
          Caption = #36215#28857#20559#31227#37327':'
        end
        object lblExtSuppressLine: TLabel
          Left = 287
          Top = 117
          Width = 24
          Height = 12
          Caption = #38544#34255
        end
        object edtExtOriginOffset: TEdit
          Tag = 3
          Left = 426
          Top = 52
          Width = 75
          Height = 20
          TabOrder = 0
          Text = '0'
          OnChange = edtDimStyleLinesPropChange
        end
        object edtExtBeyondDimLines: TEdit
          Tag = 2
          Left = 426
          Top = 24
          Width = 75
          Height = 20
          TabOrder = 1
          Text = '0'
          OnChange = edtDimStyleLinesPropChange
        end
        object udnExtOriginOffset: TUpDown
          Tag = 3
          Left = 501
          Top = 52
          Width = 17
          Height = 20
          TabOrder = 2
          OnChangingEx = udnDimStyleLinesPropChangingEx
        end
        object udnExtBeyondDimLines: TUpDown
          Tag = 2
          Left = 501
          Top = 24
          Width = 17
          Height = 20
          TabOrder = 3
          OnChangingEx = udnDimStyleLinesPropChangingEx
        end
        object ckbExtSuppressLine1: TCheckBox
          Tag = 2
          Left = 348
          Top = 116
          Width = 81
          Height = 17
          Caption = #23610#23544#30028#32447'1'
          TabOrder = 4
          OnClick = ckbDimStyleLinesPropSuppressClick
        end
        object ckbExtSuppressLine2: TCheckBox
          Tag = 3
          Left = 437
          Top = 116
          Width = 82
          Height = 17
          Caption = #23610#23544#30028#32447'2'
          TabOrder = 5
          OnClick = ckbDimStyleLinesPropSuppressClick
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = #31526#21495#21644#31661#22836
      ImageIndex = 2
      object gpbArrowheads: TGroupBox
        Left = 5
        Top = 3
        Width = 275
        Height = 224
        Caption = #31661#22836
        TabOrder = 0
        object lblArrowFirst: TLabel
          Left = 15
          Top = 27
          Width = 66
          Height = 12
          Caption = #31532#19968#20010#31661#22836':'
        end
        object lblArrowSecond: TLabel
          Left = 15
          Top = 77
          Width = 66
          Height = 12
          Caption = #31532#20799#20010#31661#22836':'
        end
        object lblArrowLeader: TLabel
          Left = 15
          Top = 127
          Width = 30
          Height = 12
          Caption = #24341#32447':'
        end
        object lblArrowSize: TLabel
          Left = 15
          Top = 189
          Width = 54
          Height = 12
          Caption = #31661#22836#22823#23567':'
        end
        object cbxArrowFirst: TComboBox
          Left = 15
          Top = 45
          Width = 231
          Height = 21
          Style = csOwnerDrawFixed
          DropDownCount = 12
          ItemHeight = 15
          TabOrder = 0
          OnChange = cbxDimStyleArrowKindChange
          OnDrawItem = cbxDimArrowDrawItem
        end
        object cbxArrowSecond: TComboBox
          Tag = 1
          Left = 15
          Top = 94
          Width = 231
          Height = 21
          Style = csOwnerDrawFixed
          DropDownCount = 12
          ItemHeight = 15
          TabOrder = 1
          OnChange = cbxDimStyleArrowKindChange
          OnDrawItem = cbxDimArrowDrawItem
        end
        object cbxArrowLeader: TComboBox
          Tag = 2
          Left = 15
          Top = 143
          Width = 231
          Height = 21
          Style = csOwnerDrawFixed
          DropDownCount = 12
          ItemHeight = 15
          TabOrder = 2
          OnChange = cbxDimStyleArrowKindChange
          OnDrawItem = cbxDimArrowDrawItem
        end
        object edtArrowSize: TEdit
          Left = 80
          Top = 187
          Width = 80
          Height = 20
          TabOrder = 3
          Text = '0'
          OnChange = edtArrowSizeChange
        end
        object udnArrowSize: TUpDown
          Left = 160
          Top = 186
          Width = 17
          Height = 20
          Max = 32000
          TabOrder = 4
          OnChangingEx = udnArrowSizeChangingEx
        end
      end
      object gpbCenterMarks: TGroupBox
        Left = 5
        Top = 235
        Width = 275
        Height = 119
        Caption = #22278#24515#26631#35760
        TabOrder = 1
        object lblMarkSize: TLabel
          Left = 157
          Top = 40
          Width = 30
          Height = 12
          Caption = #22823#23567':'
        end
        object rdbCenterNone: TRadioButton
          Left = 15
          Top = 28
          Width = 113
          Height = 17
          Caption = #26080
          TabOrder = 0
        end
        object rdbCenterMark: TRadioButton
          Left = 15
          Top = 58
          Width = 113
          Height = 17
          Caption = #26631#35760
          Checked = True
          TabOrder = 1
          TabStop = True
        end
        object rdbCenterLine: TRadioButton
          Left = 15
          Top = 88
          Width = 113
          Height = 17
          Caption = #30452#32447
          TabOrder = 2
        end
        object edtMarkSize: TEdit
          Left = 157
          Top = 59
          Width = 80
          Height = 20
          TabOrder = 3
          Text = '0'
          OnChange = edtMarkSizeChange
        end
        object udnMarkSize: TUpDown
          Left = 237
          Top = 58
          Width = 17
          Height = 20
          Max = 32000
          TabOrder = 4
          OnChangingEx = udnMarkSizeChangingEx
        end
      end
      object gpbArcLengthSymbol: TGroupBox
        Left = 301
        Top = 235
        Width = 229
        Height = 119
        Caption = #24359#32447#38271#24230#31526#21495
        TabOrder = 2
        object rdbSymInFront: TRadioButton
          Tag = 1
          Left = 18
          Top = 26
          Width = 185
          Height = 17
          Caption = #26631#27880#25991#26412#20043#21069
          TabOrder = 0
          OnClick = rdbArcLengthSymbolClick
        end
        object rdbSymAbove: TRadioButton
          Tag = 2
          Left = 18
          Top = 56
          Width = 185
          Height = 17
          Caption = #26631#27880#25991#26412#20043#19978
          TabOrder = 1
          OnClick = rdbArcLengthSymbolClick
        end
        object rdbSymNone: TRadioButton
          Left = 18
          Top = 86
          Width = 180
          Height = 17
          Caption = #19981#26174#31034
          Checked = True
          TabOrder = 2
          TabStop = True
          OnClick = rdbArcLengthSymbolClick
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = #25991#26412
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gpbTextAppearance: TGroupBox
        Left = 5
        Top = 3
        Width = 280
        Height = 197
        Caption = 'Text appearance'
        TabOrder = 0
        object lblTextStyle: TLabel
          Left = 10
          Top = 28
          Width = 54
          Height = 12
          Caption = #25991#23383#26679#24335':'
        end
        object lblTextColor: TLabel
          Left = 10
          Top = 63
          Width = 54
          Height = 12
          Caption = #25991#23383#39068#33394':'
        end
        object lblFillColor: TLabel
          Left = 10
          Top = 98
          Width = 54
          Height = 12
          Caption = #22635#20805#39068#33394':'
        end
        object lblTextHeight: TLabel
          Left = 10
          Top = 133
          Width = 54
          Height = 12
          Caption = #25991#26412#39640#24230':'
        end
        object btnTextStyle: TSpeedButton
          Left = 250
          Top = 24
          Width = 23
          Height = 21
          Caption = '..'
          OnClick = btnTextStyleClick
        end
        object edtTextHeight: TEdit
          Left = 175
          Top = 130
          Width = 75
          Height = 20
          TabOrder = 0
          Text = '0'
          OnChange = edtTextHeightChange
        end
        object udnTextHeight: TUpDown
          Left = 250
          Top = 130
          Width = 17
          Height = 20
          Max = 32000
          TabOrder = 1
          OnChangingEx = udnTextHeightChangingEx
        end
        object ckbDrawFrame: TCheckBox
          Left = 10
          Top = 164
          Width = 186
          Height = 17
          Caption = #32472#21046#25991#23383#36793#26694
          TabOrder = 2
          OnClick = ckbDrawFrameClick
        end
        object cbxTextStyle: TComboBox
          Left = 105
          Top = 25
          Width = 145
          Height = 20
          Style = csDropDownList
          TabOrder = 3
          OnSelect = cbxTextStyleSelect
        end
        object ckbNoneColor: TCheckBox
          Left = 228
          Top = 97
          Width = 45
          Height = 17
          Caption = #31354
          TabOrder = 4
          OnClick = ckbNoneColorClick
        end
      end
      object gpbTextPlacement: TGroupBox
        Left = 5
        Top = 217
        Width = 280
        Height = 134
        Caption = #25991#23383#20301#32622
        TabOrder = 1
        object lblVerticalPosition: TLabel
          Left = 10
          Top = 35
          Width = 30
          Height = 12
          Caption = #22402#30452':'
        end
        object lblHorizontalPosition: TLabel
          Left = 10
          Top = 66
          Width = 36
          Height = 12
          Caption = #27178#21521'l:'
        end
        object lblOffsetFromDimLine: TLabel
          Left = 10
          Top = 98
          Width = 78
          Height = 12
          Caption = #20174#23610#23544#32447#20559#31227':'
        end
        object edtOffsetFromDimLine: TEdit
          Left = 177
          Top = 95
          Width = 71
          Height = 20
          TabOrder = 0
          Text = '0'
          OnChange = edtOffsetFromDimLineChange
        end
        object udnOffsetFromDimLine: TUpDown
          Left = 250
          Top = 95
          Width = 17
          Height = 20
          Max = 32000
          TabOrder = 1
          OnChangingEx = udnOffsetFromDimLineChangingEx
        end
        object cbxVerticalPosition: TComboBox
          Left = 113
          Top = 32
          Width = 154
          Height = 20
          Style = csDropDownList
          TabOrder = 2
          OnSelect = cbxVerticalPositionSelect
          Items.Strings = (
            'Centered'
            'Above')
        end
        object cbxHorizontalPosition: TComboBox
          Left = 113
          Top = 63
          Width = 154
          Height = 20
          Style = csDropDownList
          TabOrder = 3
          OnSelect = cbxHorizontalPositionSelect
          Items.Strings = (
            'Centered'
            'At Ex Line 1'
            'At Ex Line 2'
            'Custom')
        end
      end
      object gpbTextAlignment: TGroupBox
        Left = 310
        Top = 217
        Width = 216
        Height = 134
        Caption = #25991#26412#23545#40784
        TabOrder = 2
        object rdbTextAlignHorizontal: TRadioButton
          Left = 15
          Top = 30
          Width = 185
          Height = 17
          Caption = #27700#24179
          TabOrder = 0
          OnClick = rdbTextAlignmentClick
        end
        object rdbTextAlignWithDimLine: TRadioButton
          Tag = 1
          Left = 15
          Top = 61
          Width = 185
          Height = 17
          Caption = #19982#23610#23544#32447#23545#20854
          Checked = True
          TabOrder = 1
          TabStop = True
          OnClick = rdbTextAlignmentClick
        end
        object rdbTextAlignISOStandard: TRadioButton
          Tag = 2
          Left = 15
          Top = 93
          Width = 180
          Height = 17
          Caption = 'ISO '#26631#20934
          TabOrder = 2
          OnClick = rdbTextAlignmentClick
        end
      end
    end
    object TabSheet5: TTabSheet
      Caption = #35843#25972
      ImageIndex = 4
      object GroupBox8: TGroupBox
        Left = 5
        Top = 3
        Width = 278
        Height = 193
        Caption = #26631#27880#29305#24449#27604#20363
        TabOrder = 0
        object lblOverallScale: TLabel
          Left = 15
          Top = 58
          Width = 72
          Height = 12
          Caption = #20351#29992#20840#23616#27604#20363
        end
        object edtOverallScale: TEdit
          Left = 130
          Top = 55
          Width = 75
          Height = 20
          TabOrder = 0
          Text = '0'
          OnChange = edtOverallScaleChange
        end
        object udnOverallScale: TUpDown
          Left = 205
          Top = 55
          Width = 17
          Height = 20
          Max = 32000
          TabOrder = 1
          OnChangingEx = udnOverallScaleChangingEx
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = #20027#21333#20301
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gpbLinearDimensions: TGroupBox
        Left = 5
        Top = 3
        Width = 280
        Height = 354
        Caption = #32447#24418#26631#27880
        TabOrder = 0
        object lblUnitFormat: TLabel
          Left = 12
          Top = 25
          Width = 54
          Height = 12
          Caption = #21333#20301#26684#24335':'
        end
        object lblPrecision: TLabel
          Left = 12
          Top = 57
          Width = 30
          Height = 12
          Caption = #31934#24230':'
        end
        object lblDecimal: TLabel
          Left = 12
          Top = 89
          Width = 54
          Height = 12
          Caption = #20998#25968#26684#24335':'
        end
        object lblRoundOff: TLabel
          Left = 12
          Top = 121
          Width = 30
          Height = 12
          Caption = #33293#20837':'
        end
        object lblPrefix: TLabel
          Left = 12
          Top = 153
          Width = 30
          Height = 12
          Caption = #21069#32512':'
        end
        object lblSuffix: TLabel
          Left = 12
          Top = 185
          Width = 30
          Height = 12
          Caption = #21518#32512':'
        end
        object lblMeasurementScale: TLabel
          Left = 12
          Top = 217
          Width = 78
          Height = 12
          Caption = #27979#37327#27604#20363#22240#23376':'
        end
        object cbxUnitFormat: TComboBox
          Left = 110
          Top = 22
          Width = 156
          Height = 20
          Style = csDropDownList
          TabOrder = 0
          OnSelect = cbxUnitFormatSelect
          Items.Strings = (
            'Scientific '
            'Decimal '
            'Engineering '
            'Architectural  '
            'Fractional')
        end
        object cbxPrecision: TComboBox
          Left = 110
          Top = 52
          Width = 156
          Height = 20
          Style = csDropDownList
          TabOrder = 1
          OnSelect = cbxPrecisionSelect
        end
        object cbxDecimal: TComboBox
          Left = 110
          Top = 86
          Width = 156
          Height = 20
          Style = csDropDownList
          TabOrder = 2
          OnSelect = cbxDecimalSelect
          Items.Strings = (
            '.'
            ','
            '(space)')
        end
        object edtRoundOff: TEdit
          Left = 175
          Top = 118
          Width = 75
          Height = 20
          TabOrder = 3
          Text = '0'
          OnChange = edtRoundOffChange
        end
        object udnRoundOff: TUpDown
          Left = 250
          Top = 118
          Width = 17
          Height = 20
          TabOrder = 4
          OnChangingEx = udnRoundOffChangingEx
        end
        object edtPrefix: TEdit
          Left = 110
          Top = 150
          Width = 156
          Height = 20
          TabOrder = 5
          OnChange = edtPrefixChange
        end
        object edtSuffix: TEdit
          Left = 110
          Top = 182
          Width = 156
          Height = 20
          TabOrder = 6
          OnChange = edtSuffixChange
        end
        object edtMeasurementScale: TEdit
          Left = 175
          Top = 214
          Width = 75
          Height = 20
          TabOrder = 7
          Text = '0'
          OnChange = edtMeasurementScaleChange
        end
        object udnMeasurementScale: TUpDown
          Left = 250
          Top = 214
          Width = 17
          Height = 20
          TabOrder = 8
          OnChangingEx = udnMeasurementScaleChangingEx
        end
        object gpbZeroSuppression: TGroupBox
          Left = 12
          Top = 276
          Width = 254
          Height = 70
          Caption = #28040#38646
          TabOrder = 9
          object ckbSuppressLeading: TCheckBox
            Left = 17
            Top = 20
            Width = 97
            Height = 17
            Caption = #21069#23548
            TabOrder = 0
            OnClick = ckbSuppressLeadingClick
          end
          object ckbSuppressTrailing: TCheckBox
            Left = 17
            Top = 46
            Width = 97
            Height = 17
            Caption = #21518#32493
            Checked = True
            State = cbChecked
            TabOrder = 1
            OnClick = ckbSuppressTrailingClick
          end
        end
      end
      object gpbAngularDimensions: TGroupBox
        Left = 294
        Top = 199
        Width = 235
        Height = 158
        Caption = #35282#24230#26631#27880
        TabOrder = 1
        object lblAngUnitFormat: TLabel
          Left = 12
          Top = 24
          Width = 54
          Height = 12
          Caption = #21333#20301#26684#24335':'
        end
        object lblAngPrecision: TLabel
          Left = 12
          Top = 53
          Width = 30
          Height = 12
          Caption = #31934#24230':'
        end
        object gpbAngZeroSuppression: TGroupBox
          Left = 12
          Top = 80
          Width = 214
          Height = 70
          Caption = #28040#38646
          TabOrder = 0
          object ckbAngSuppressLeading: TCheckBox
            Left = 17
            Top = 20
            Width = 97
            Height = 17
            Caption = #21069#23548
            TabOrder = 0
            OnClick = ckbAngSuppressLeadingClick
          end
          object ckbAngSuppressTrailing: TCheckBox
            Left = 17
            Top = 46
            Width = 97
            Height = 17
            Caption = #21518#32493
            Checked = True
            State = cbChecked
            TabOrder = 1
            OnClick = ckbAngSuppressTrailingClick
          end
        end
        object cbxAngUnitFormat: TComboBox
          Left = 99
          Top = 21
          Width = 128
          Height = 20
          Style = csDropDownList
          TabOrder = 1
          OnSelect = cbxAngUnitFormatSelect
          Items.Strings = (
            'Degrees'
            'DegMinSec'
            'Grads'
            'Radians')
        end
        object cbxAngPrecision: TComboBox
          Left = 99
          Top = 50
          Width = 128
          Height = 20
          Style = csDropDownList
          TabOrder = 2
          OnSelect = cbxAngPrecisionSelect
        end
      end
    end
    object TabSheet6: TTabSheet
      Caption = #25442#31639#21333#20301
      ImageIndex = 6
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gpbAltLinearDimensions: TGroupBox
        Left = 5
        Top = 31
        Width = 280
        Height = 322
        Caption = #25442#31639#21333#20301
        TabOrder = 0
        object lblAltUnitFormat: TLabel
          Left = 12
          Top = 25
          Width = 54
          Height = 12
          Caption = #21333#20301#26684#24335':'
        end
        object Label6: TLabel
          Left = 12
          Top = 55
          Width = 30
          Height = 12
          Caption = #31934#24230':'
        end
        object lblAltMultiplier: TLabel
          Left = 12
          Top = 86
          Width = 78
          Height = 12
          Caption = #25442#31639#21333#20301#20056#25968':'
        end
        object lblAltRoundDis: TLabel
          Left = 12
          Top = 117
          Width = 54
          Height = 12
          Caption = #33293#20837#31934#24230':'
        end
        object lblAltPrefix: TLabel
          Left = 12
          Top = 148
          Width = 30
          Height = 12
          Caption = #21069#32512':'
        end
        object lblAltSuffix: TLabel
          Left = 12
          Top = 179
          Width = 30
          Height = 12
          Caption = #21518#32512':'
        end
        object cbxAltUnitFormat: TComboBox
          Left = 110
          Top = 22
          Width = 156
          Height = 20
          Style = csDropDownList
          TabOrder = 0
          OnSelect = cbxAltUnitFormatSelect
          Items.Strings = (
            'Scientific '
            'Decimal '
            'Engineering '
            'Architectural  '
            'Fractional')
        end
        object cbxAltPrecision: TComboBox
          Left = 110
          Top = 52
          Width = 156
          Height = 20
          Style = csDropDownList
          TabOrder = 1
          OnSelect = cbxAltPrecisionSelect
        end
        object edtAltRoundDis: TEdit
          Left = 175
          Top = 114
          Width = 75
          Height = 20
          Enabled = False
          TabOrder = 2
          Text = '0'
          OnChange = edtAltRoundDisChange
        end
        object udnAltRoundDis: TUpDown
          Left = 250
          Top = 114
          Width = 17
          Height = 20
          Enabled = False
          TabOrder = 3
          OnChangingEx = udnAltRoundDisChangingEx
        end
        object edtAltPrefix: TEdit
          Left = 110
          Top = 145
          Width = 156
          Height = 20
          TabOrder = 4
          OnChange = edtAltPrefixChange
        end
        object edtAltSuffix: TEdit
          Left = 110
          Top = 176
          Width = 156
          Height = 20
          TabOrder = 5
          OnChange = edtAltSuffixChange
        end
        object gpbAltZeroSuppression: TGroupBox
          Left = 12
          Top = 238
          Width = 254
          Height = 73
          Caption = #28040#38646
          TabOrder = 6
          object ckbAltSuppressLeading: TCheckBox
            Left = 17
            Top = 20
            Width = 97
            Height = 17
            Caption = #21069#23548
            TabOrder = 0
            OnClick = ckbAltSuppressLeadingClick
          end
          object ckbAltSuppressTrailing: TCheckBox
            Left = 17
            Top = 46
            Width = 97
            Height = 17
            Caption = #21518#32493
            Checked = True
            State = cbChecked
            TabOrder = 1
            OnClick = ckbAltSuppressTrailingClick
          end
        end
        object edtAltMultiplier: TEdit
          Left = 175
          Top = 83
          Width = 75
          Height = 20
          TabOrder = 7
          Text = '0'
          OnChange = edtAltMultiplierChange
        end
        object udnedtAltMultiplier: TUpDown
          Left = 250
          Top = 83
          Width = 17
          Height = 20
          TabOrder = 8
          OnChangingEx = udnedtAltMultiplierChangingEx
        end
      end
      object ckbDispAltUnits: TCheckBox
        Left = 6
        Top = 7
        Width = 240
        Height = 17
        Caption = #26174#31034#25442#31639#21333#20301
        TabOrder = 1
        OnClick = ckbDispAltUnitsClick
      end
      object gpbAltPlacement: TGroupBox
        Left = 300
        Top = 217
        Width = 230
        Height = 134
        Caption = #20301#32622
        TabOrder = 2
        object UpDown6: TUpDown
          Left = 252
          Top = 95
          Width = 17
          Height = 20
          Enabled = False
          TabOrder = 0
        end
        object rdbAltAfter: TRadioButton
          Left = 15
          Top = 40
          Width = 177
          Height = 17
          Caption = #20027#20540#21518
          TabOrder = 1
          OnClick = rdbAltPlacementClick
        end
        object rdbAltBelow: TRadioButton
          Tag = 1
          Left = 15
          Top = 75
          Width = 177
          Height = 17
          Caption = #20027#20540#19979
          TabOrder = 2
          OnClick = rdbAltPlacementClick
        end
      end
    end
  end
  object btnOK: TButton
    Left = 368
    Top = 402
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 457
    Top = 402
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
  end
  object pnlPreview: TPanel
    Left = 311
    Top = 32
    Width = 240
    Height = 190
    BevelOuter = bvLowered
    Color = clBlack
    ParentBackground = False
    TabOrder = 3
  end
end
