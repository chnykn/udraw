object UdHSLForm: TUdHSLForm
  Left = 570
  Top = 289
  Width = 242
  Height = 234
  Caption = 'UdHSLForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object imgHSL: TImage
    Left = 0
    Top = 0
    Width = 180
    Height = 180
    Cursor = crCross
    OnClick = imgHSLClick
    OnMouseMove = imgHSLMouseMove
  end
  object imgLum: TImage
    Left = 185
    Top = 0
    Width = 13
    Height = 180
    Cursor = crVSplit
  end
  object tcbLum: TTrackBar
    Left = 198
    Top = -7
    Width = 20
    Height = 195
    Ctl3D = False
    Max = 180
    Orientation = trVertical
    ParentCtl3D = False
    TabOrder = 0
    TickStyle = tsNone
  end
end
