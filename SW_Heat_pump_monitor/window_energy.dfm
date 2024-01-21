object FormEnergy: TFormEnergy
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Energy'
  ClientHeight = 187
  ClientWidth = 589
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnReadEnergyData: TButton
    Left = 8
    Top = 8
    Width = 105
    Height = 25
    Caption = 'ReadEnergyData'
    TabOrder = 0
    OnClick = btnReadEnergyDataClick
  end
  object GridEnergy: TStringGrid
    Left = 8
    Top = 39
    Width = 573
    Height = 138
    ColCount = 4
    DefaultColWidth = 140
    DefaultRowHeight = 25
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
end
