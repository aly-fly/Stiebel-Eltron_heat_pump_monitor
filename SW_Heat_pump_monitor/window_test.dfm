object FormTest: TFormTest
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Test'
  ClientHeight = 667
  ClientWidth = 1068
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblRegScanStatus: TLabel
    Left = 463
    Top = 236
    Width = 83
    Height = 13
    Caption = 'lblRegScanStatus'
  end
  object lbl1: TLabel
    Left = 8
    Top = 301
    Width = 19
    Height = 13
    Caption = 'DEV'
  end
  object lbl2: TLabel
    Left = 63
    Top = 301
    Width = 25
    Height = 13
    Caption = 'CIRC'
  end
  object lbl3: TLabel
    Left = 118
    Top = 301
    Width = 20
    Height = 13
    Caption = 'REG'
  end
  object Label1: TLabel
    Left = 173
    Top = 301
    Width = 8
    Height = 13
    Caption = '#'
  end
  object btnScanDevices: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Scan Devices'
    TabOrder = 0
    OnClick = btnScanDevicesClick
  end
  object mm1: TMemo
    Left = 653
    Top = 8
    Width = 410
    Height = 513
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial Narrow'
    Font.Style = []
    Lines.Strings = (
      'mm1')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object cbDebug: TCheckBox
    Left = 112
    Top = 12
    Width = 97
    Height = 17
    Caption = 'Debug'
    TabOrder = 2
    OnClick = cbDebugClick
  end
  object DevGrid: TStringGrid
    Left = 8
    Top = 39
    Width = 449
    Height = 258
    ColCount = 17
    DefaultColWidth = 20
    DefaultRowHeight = 18
    RowCount = 13
    TabOrder = 3
  end
  object rgDevices: TRadioGroup
    Left = 463
    Top = 39
    Width = 185
    Height = 162
    Caption = ' Devices '
    Items.Strings = (
      '00 00 Boiler 0 '
      '02 01 Control 1'
      '02 02 Control 2'
      '04 00 Manager 0'
      '05 00 Heating 0'
      '06 01 Mixer 1 '
      '06 02 Mixer 2 ')
    TabOrder = 4
  end
  object btnScanRegisters: TButton
    Left = 535
    Top = 207
    Width = 113
    Height = 25
    Caption = 'Scan Registers'
    Enabled = False
    TabOrder = 5
    OnClick = btnScanRegistersClick
  end
  object seNumRegisters: TSpinEdit
    Left = 463
    Top = 209
    Width = 66
    Height = 22
    MaxValue = 65535
    MinValue = 1
    TabOrder = 6
    Value = 128
  end
  object pb1: TProgressBar
    Left = 464
    Top = 255
    Width = 184
    Height = 17
    TabOrder = 7
  end
  object btnScanAllDevReg: TButton
    Left = 463
    Top = 278
    Width = 185
    Height = 25
    Caption = 'Read all data'
    Enabled = False
    TabOrder = 8
    OnClick = btnScanAllDevRegClick
  end
  object pb2: TProgressBar
    Left = 463
    Top = 309
    Width = 184
    Height = 17
    TabOrder = 9
  end
  object edCirc: TEdit
    Left = 63
    Top = 320
    Width = 49
    Height = 21
    TabOrder = 10
    Text = '0'
  end
  object edReg: TEdit
    Left = 118
    Top = 320
    Width = 49
    Height = 21
    TabOrder = 11
    Text = '$7f0'
  end
  object btnReadMan: TButton
    Left = 271
    Top = 318
    Width = 58
    Height = 25
    Caption = 'Read'
    TabOrder = 12
    OnClick = btnReadManClick
  end
  object edNumRegs: TEdit
    Left = 173
    Top = 320
    Width = 28
    Height = 21
    TabOrder = 13
    Text = '8'
  end
  object btnStop: TButton
    Left = 588
    Top = 366
    Width = 59
    Height = 25
    Caption = 'Stop'
    TabOrder = 14
    OnClick = btnStopClick
  end
  object cbbDev: TComboBox
    Left = 8
    Top = 320
    Width = 49
    Height = 21
    ItemIndex = 3
    TabOrder = 15
    Text = '$0A'
    Items.Strings = (
      '03'
      '06'
      '09'
      '$0A'
      '$0C')
  end
  object GridTestRead: TStringGrid
    Left = 8
    Top = 349
    Width = 321
    Height = 289
    DefaultColWidth = 60
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing]
    TabOrder = 16
  end
  object btnFill: TButton
    Left = 207
    Top = 318
    Width = 58
    Height = 25
    Caption = 'Fill'
    TabOrder = 17
    OnClick = btnFillClick
  end
end
