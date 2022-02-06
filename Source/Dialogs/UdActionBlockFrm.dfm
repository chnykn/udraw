object UdActionBlockForm: TUdActionBlockForm
  Left = 529
  Top = 152
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = #22359#23450#20041
  ClientHeight = 334
  ClientWidth = 412
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
    412
    334)
  PixelsPerInch = 96
  TextHeight = 13
  object lblName: TLabel
    Left = 15
    Top = 20
    Width = 28
    Height = 13
    Caption = #21517#31216':'
  end
  object lblDescription: TLabel
    Left = 15
    Top = 205
    Width = 28
    Height = 13
    Caption = #25551#36848':'
  end
  object lblSelObjs: TLabel
    Left = 51
    Top = 300
    Width = 46
    Height = 13
    Caption = 'lblSelObjs'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clTeal
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label7: TLabel
    Left = 17
    Top = 300
    Width = 12
    Height = 13
    Caption = #9734
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object cbxName: TComboBox
    Left = 70
    Top = 17
    Width = 280
    Height = 21
    TabOrder = 0
  end
  object gpbBasePoint: TGroupBox
    Left = 15
    Top = 55
    Width = 185
    Height = 130
    Caption = #22522#28857
    TabOrder = 1
    DesignSize = (
      185
      130)
    object btnPickPoint: TSpeedButton
      Left = 15
      Top = 20
      Width = 26
      Height = 24
      Anchors = [akTop, akRight]
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        0800000000000001000000000000000000000001000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A6000020400000206000002080000020A0000020C0000020E000004000000040
        20000040400000406000004080000040A0000040C0000040E000006000000060
        20000060400000606000006080000060A0000060C0000060E000008000000080
        20000080400000806000008080000080A0000080C0000080E00000A0000000A0
        200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
        200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
        200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
        20004000400040006000400080004000A0004000C0004000E000402000004020
        20004020400040206000402080004020A0004020C0004020E000404000004040
        20004040400040406000404080004040A0004040C0004040E000406000004060
        20004060400040606000406080004060A0004060C0004060E000408000004080
        20004080400040806000408080004080A0004080C0004080E00040A0000040A0
        200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
        200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
        200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
        20008000400080006000800080008000A0008000C0008000E000802000008020
        20008020400080206000802080008020A0008020C0008020E000804000008040
        20008040400080406000804080008040A0008040C0008040E000806000008060
        20008060400080606000806080008060A0008060C0008060E000808000008080
        20008080400080806000808080008080A0008080C0008080E00080A0000080A0
        200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
        200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
        200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
        2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
        2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
        2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
        2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
        2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
        2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
        2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
        FFFFFFFFFFFFF791F7FFFFFFFFFFFFFFFFFFFFFFFFFF91B691FFFFFFFFFFFFFF
        FFFFFF8BFFF7B6BF9BFFFFFFFFFFFFFFFFFFFF91A391BFACEDFFFFFFFFFFFFFF
        FFFFFF91BFA4BF91FFFFFF919191919191919191BFBFB6A39A91FFEDF6F6F6F6
        F609089108BFBFBF91FFFFEDF6F6F6F6F6F60991F6F6BF91FFFFFFEDFFF6F6F6
        F6F6F691F6F691A3FFFFFFEDFFFFF6F6F90DF691FF91F691FFFFFFEDFFFFF6F6
        F6F90D9191090891FFFFFFEDFFFFFFF6F6F6F991F6090991FFFFFFEDFFFFFFFF
        F60DF9F90DF60991FFFFFFEDFFFFFFFF0DF9F6F6F90DF691FFFFFFEDFFFFFFFF
        FFF6F6F6F6F6F691FFFFFFEDEDEDEDEDEDEDEDEDEDEDED91FFFF}
      OnClick = btnPickPointClick
    end
    object lblPick: TLabel
      Left = 50
      Top = 25
      Width = 36
      Height = 13
      Caption = #25342#21462#28857
    end
    object lblX: TLabel
      Left = 15
      Top = 64
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object lblY: TLabel
      Left = 15
      Top = 95
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object edtX: TEdit
      Left = 35
      Top = 61
      Width = 135
      Height = 21
      TabOrder = 0
      Text = '0.00'
    end
    object edtY: TEdit
      Left = 35
      Top = 92
      Width = 135
      Height = 21
      TabOrder = 1
      Text = '0.00'
    end
  end
  object gpbObjects: TGroupBox
    Left = 212
    Top = 55
    Width = 185
    Height = 130
    Caption = #23545#35937
    TabOrder = 2
    DesignSize = (
      185
      130)
    object btnSelectObjs: TSpeedButton
      Left = 15
      Top = 20
      Width = 26
      Height = 24
      Anchors = [akTop, akRight]
      OnClick = btnSelectObjsClick
    end
    object lblSelect: TLabel
      Left = 50
      Top = 25
      Width = 48
      Height = 13
      Caption = #36873#25321#23545#35937
    end
    object rdbRetain: TRadioButton
      Left = 15
      Top = 53
      Width = 113
      Height = 17
      Caption = #20445#30041
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rdbConvert: TRadioButton
      Left = 15
      Top = 77
      Width = 113
      Height = 17
      Caption = #36716#25442#20026#22359
      TabOrder = 1
    end
    object rdbDelete: TRadioButton
      Left = 15
      Top = 102
      Width = 113
      Height = 17
      Caption = #21024#38500
      TabOrder = 2
    end
  end
  object memDescription: TMemo
    Left = 15
    Top = 224
    Width = 382
    Height = 59
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object btnOK: TButton
    Left = 227
    Top = 299
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&'#30830#23450
    Default = True
    TabOrder = 4
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 318
    Top = 299
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #21462#28040
    TabOrder = 5
    OnClick = btnCancelClick
  end
end
