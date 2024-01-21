object FormSettings: TFormSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Heat pump settings'
  ClientHeight = 403
  ClientWidth = 445
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 55
    Top = 94
    Width = 19
    Height = 13
    Caption = 'Day'
  end
  object Label2: TLabel
    Left = 55
    Top = 121
    Width = 25
    Height = 13
    Caption = 'Night'
  end
  object Label3: TLabel
    Left = 95
    Top = 72
    Width = 27
    Height = 13
    Caption = 'Circ 1'
  end
  object Label4: TLabel
    Left = 168
    Top = 72
    Width = 27
    Height = 13
    Caption = 'Circ 2'
  end
  object lblWater: TLabel
    Left = 239
    Top = 72
    Width = 30
    Height = 13
    Caption = 'Water'
  end
  object Label5: TLabel
    Left = 32
    Top = 193
    Width = 60
    Height = 13
    AutoSize = False
    Caption = 'Party hours'
  end
  object lblCurrTime: TLabel
    Left = 224
    Top = 193
    Width = 92
    Height = 40
    Hint = 'Current time at time of reading settings'
    Alignment = taCenter
    AutoSize = False
    Caption = 'Time'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
  end
  object Label6: TLabel
    Left = 55
    Top = 37
    Width = 30
    Height = 13
    Caption = 'Mode:'
  end
  object Label10: TLabel
    Left = 22
    Top = 156
    Width = 67
    Height = 13
    Caption = 'Heating curve'
  end
  object edC1Day: TEdit
    Left = 95
    Top = 91
    Width = 57
    Height = 21
    TabOrder = 0
  end
  object edC2Day: TEdit
    Left = 168
    Top = 91
    Width = 57
    Height = 21
    TabOrder = 1
  end
  object edC1night: TEdit
    Left = 95
    Top = 118
    Width = 57
    Height = 21
    TabOrder = 2
  end
  object edC2Night: TEdit
    Left = 168
    Top = 118
    Width = 57
    Height = 21
    TabOrder = 3
  end
  object edWaterDay: TEdit
    Left = 239
    Top = 91
    Width = 57
    Height = 21
    TabOrder = 4
  end
  object edWaterNight: TEdit
    Left = 239
    Top = 118
    Width = 57
    Height = 21
    TabOrder = 5
  end
  object ddHPMode: TComboBox
    Left = 95
    Top = 34
    Width = 201
    Height = 21
    Style = csDropDownList
    TabOrder = 6
    Items.Strings = (
      'Standby / off'
      'Automatic'
      'Day'
      'Night'
      'Water only'
      'Emergency (electric only)')
  end
  object btnSettingsRead: TButton
    Left = 348
    Top = 34
    Width = 67
    Height = 41
    Caption = 'Read'
    Enabled = False
    TabOrder = 7
    OnClick = btnSettingsReadClick
  end
  object btnSettingsWrite: TButton
    Left = 348
    Top = 153
    Width = 67
    Height = 41
    Caption = 'Write'
    Enabled = False
    TabOrder = 8
    OnClick = btnSettingsWriteClick
  end
  object edPartyHrs: TEdit
    Left = 95
    Top = 190
    Width = 38
    Height = 21
    Hint = 'Number of hours tos stay in Day mode (schedule override)'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
  end
  object grpEmail: TGroupBox
    Left = 8
    Top = 275
    Width = 425
    Height = 121
    Caption = '  Email  (Gmail only)  '
    TabOrder = 10
    object Label7: TLabel
      Left = 14
      Top = 27
      Width = 48
      Height = 13
      Caption = 'Username'
    end
    object Label8: TLabel
      Left = 14
      Top = 54
      Width = 46
      Height = 13
      Caption = 'Password'
    end
    object Label9: TLabel
      Left = 14
      Top = 81
      Width = 44
      Height = 13
      Caption = 'Recipient'
    end
    object edMailLoginUser: TEdit
      Left = 71
      Top = 24
      Width = 237
      Height = 21
      TabOrder = 0
      OnChange = UpdateEmailData
    end
    object edMailAddressReceiver: TEdit
      Left = 71
      Top = 78
      Width = 237
      Height = 21
      TabOrder = 1
      OnChange = UpdateEmailData
    end
    object edMailLoginPass: TEdit
      Left = 71
      Top = 51
      Width = 237
      Height = 21
      TabOrder = 2
      OnChange = UpdateEmailData
    end
    object btnSave: TButton
      Left = 332
      Top = 24
      Width = 75
      Height = 41
      Caption = 'Save'
      TabOrder = 3
      OnClick = btnSaveClick
    end
    object btnMailTest: TButton
      Left = 332
      Top = 78
      Width = 75
      Height = 21
      Caption = 'Test mail'
      TabOrder = 4
      OnClick = btnMailTestClick
    end
  end
  object edHtgCurve1: TEdit
    Left = 95
    Top = 153
    Width = 57
    Height = 21
    TabOrder = 11
  end
  object edHtgCurve2: TEdit
    Left = 168
    Top = 153
    Width = 57
    Height = 21
    TabOrder = 12
  end
end
