object AboutForm: TAboutForm
  Left = 479
  Top = 252
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsSingle
  Caption = 'About'
  ClientHeight = 134
  ClientWidth = 247
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 55
    Top = 15
    Width = 113
    Height = 13
    Caption = 'XB CAD version 1.2.0.2'
  end
  object Label2: TLabel
    Left = 23
    Top = 45
    Width = 190
    Height = 13
    Caption = 'Copyright(c) 2014-2015, xinbosoft.com'
  end
  object Label3: TLabel
    Left = 74
    Top = 64
    Width = 93
    Height = 13
    Caption = 'All Rights Reserved'
  end
  object Label4: TLabel
    Left = 27
    Top = 105
    Width = 43
    Height = 13
    Caption = 'Website:'
  end
  object lblURL: TLabel
    Left = 78
    Top = 105
    Width = 128
    Height = 13
    Caption = 'http://www.xinbosoft.com'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    OnClick = lblURLClick
    OnMouseEnter = lblURLMouseEnter
    OnMouseLeave = lblURLMouseLeave
  end
end
