object FormErrors: TFormErrors
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Errors'
  ClientHeight = 434
  ClientWidth = 993
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblCountdown: TLabel
    Left = 920
    Top = 13
    Width = 65
    Height = 13
    Alignment = taRightJustify
    Caption = 'lblCountdown'
  end
  object btnReadErr: TButton
    Left = 8
    Top = 8
    Width = 105
    Height = 25
    Caption = 'Read past errors'
    TabOrder = 0
    OnClick = btnReadErrClick
  end
  object GridErrors: TStringGrid
    Left = 8
    Top = 39
    Width = 977
    Height = 386
    ColCount = 6
    DefaultColWidth = 80
    DefaultRowHeight = 17
    RowCount = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
end
