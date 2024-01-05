object FormHPmonitor: TFormHPmonitor
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Stiebel Eltron heat pump WPM manager over optical interface'
  ClientHeight = 871
  ClientWidth = 1194
  Color = clBtnFace
  Constraints.MinHeight = 600
  Constraints.MinWidth = 883
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 391
    Height = 873
    BevelOuter = bvNone
    TabOrder = 1
    object btnComSearch: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Search'
      TabOrder = 0
      OnClick = btnComSearchClick
    end
    object ddPortList: TComboBox
      Left = 89
      Top = 10
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
    object btnComOpen: TButton
      Left = 8
      Top = 35
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 2
      OnClick = btnComOpenClick
    end
    object btnComClose: TButton
      Left = 8
      Top = 62
      Width = 75
      Height = 25
      Caption = 'Close'
      Enabled = False
      TabOrder = 3
      OnClick = btnComCloseClick
    end
    object btnReadData: TButton
      Left = 8
      Top = 89
      Width = 75
      Height = 25
      Caption = 'Read data'
      Enabled = False
      TabOrder = 4
      OnClick = btnReadDataClick
    end
    object mm1: TMemo
      Left = 8
      Top = 762
      Width = 377
      Height = 100
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial Narrow'
      Font.Style = []
      Lines.Strings = (
        'mm1')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 5
    end
    object cbReadConstatntly: TCheckBox
      Left = 8
      Top = 122
      Width = 75
      Height = 17
      Caption = 'Constatntly'
      Enabled = False
      TabOrder = 6
      OnClick = cbReadConstatntlyClick
    end
    object gridData: TStringGrid
      Left = 8
      Top = 199
      Width = 377
      Height = 557
      ColCount = 2
      DefaultRowHeight = 19
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      OnClick = gridDataClick
    end
    object cbDebug: TCheckBox
      Left = 8
      Top = 145
      Width = 75
      Height = 17
      Caption = 'Debug'
      TabOrder = 8
      OnClick = cbDebugClick
    end
    object grpSettings: TGroupBox
      Left = 89
      Top = 39
      Width = 296
      Height = 154
      Caption = ' Settings '
      Color = clScrollBar
      ParentBackground = False
      ParentColor = False
      TabOrder = 9
      object Label1: TLabel
        Left = 30
        Top = 36
        Width = 19
        Height = 13
        Caption = 'Day'
      end
      object Label2: TLabel
        Left = 30
        Top = 63
        Width = 25
        Height = 13
        Caption = 'Night'
      end
      object Label3: TLabel
        Left = 70
        Top = 14
        Width = 27
        Height = 13
        Caption = 'Circ 1'
      end
      object Label4: TLabel
        Left = 143
        Top = 14
        Width = 27
        Height = 13
        Caption = 'Circ 2'
      end
      object lblWater: TLabel
        Left = 214
        Top = 14
        Width = 30
        Height = 13
        Caption = 'Water'
      end
      object Label5: TLabel
        Left = 11
        Top = 101
        Width = 38
        Height = 13
        Alignment = taCenter
        AutoSize = False
        Caption = 'Party'
      end
      object lblCurrTime: TLabel
        Left = 136
        Top = 110
        Width = 69
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
      object edC1Day: TEdit
        Left = 70
        Top = 33
        Width = 57
        Height = 21
        TabOrder = 0
      end
      object edC2Day: TEdit
        Left = 143
        Top = 33
        Width = 57
        Height = 21
        TabOrder = 1
      end
      object edC1night: TEdit
        Left = 70
        Top = 60
        Width = 57
        Height = 21
        TabOrder = 2
      end
      object edC2Night: TEdit
        Left = 143
        Top = 60
        Width = 57
        Height = 21
        TabOrder = 3
      end
      object edWaterDay: TEdit
        Left = 214
        Top = 33
        Width = 57
        Height = 21
        TabOrder = 4
      end
      object edWaterNight: TEdit
        Left = 214
        Top = 60
        Width = 57
        Height = 21
        TabOrder = 5
      end
      object ddHPMode: TComboBox
        Left = 70
        Top = 87
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
        Left = 70
        Top = 114
        Width = 67
        Height = 25
        Caption = 'Read'
        Enabled = False
        TabOrder = 7
        OnClick = btnSettingsReadClick
      end
      object btnSettingsWrite: TButton
        Left = 204
        Top = 114
        Width = 67
        Height = 25
        Caption = 'Write'
        Enabled = False
        TabOrder = 8
        OnClick = btnSettingsWriteClick
      end
      object edPartyHrs: TEdit
        Left = 11
        Top = 116
        Width = 38
        Height = 21
        Hint = 'Number of hours tos stay in Day mode (schedule override)'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 9
      end
    end
    object btnLoadCharts: TButton
      Left = 312
      Top = 8
      Width = 73
      Height = 25
      Caption = 'Load charts'
      TabOrder = 10
      OnClick = btnLoadChartsClick
    end
    object btnTest: TButton
      Left = 8
      Top = 168
      Width = 31
      Height = 25
      Caption = 'Test'
      TabOrder = 11
      OnClick = btnTestClick
    end
    object btnShowEnergy: TButton
      Left = 41
      Top = 168
      Width = 42
      Height = 25
      Caption = 'Energy'
      TabOrder = 12
      OnClick = btnShowEnergyClick
    end
  end
  object chart1: TChart
    Left = 391
    Top = 0
    Width = 802
    Height = 293
    Legend.Alignment = laTop
    Legend.Frame.Color = clSilver
    Legend.TopPos = 0
    Legend.VertMargin = 1
    MarginTop = 0
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    OnScroll = ChartScroll
    OnUndoZoom = ChartUndoZoom
    OnZoom = ChartZoom
    BottomAxis.Grid.Color = 14540253
    LeftAxis.Grid.Color = 14540253
    RightAxis.Grid.Visible = False
    View3D = False
    Zoom.Pen.Color = 8388863
    Color = clWhite
    TabOrder = 0
    DefaultCanvas = 'TGDIPlusCanvas'
    PrintMargins = (
      15
      23
      15
      23)
    ColorPaletteIndex = 9
    object Series1: TLineSeries
      Brush.BackColor = clDefault
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series12: TLineSeries
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series2: TLineSeries
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series3: TLineSeries
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object Chart2: TChart
    Left = 391
    Top = 290
    Width = 802
    Height = 293
    Legend.Alignment = laTop
    Legend.CheckBoxes = True
    Legend.Frame.Color = clSilver
    Legend.TopPos = 0
    Legend.VertMargin = 1
    MarginTop = 0
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    OnScroll = ChartScroll
    OnUndoZoom = ChartUndoZoom
    OnZoom = ChartZoom
    BottomAxis.Grid.Color = 14540253
    LeftAxis.Grid.Color = 14540253
    RightAxis.Grid.Visible = False
    View3D = False
    Zoom.Pen.Color = 8388863
    Color = clWhite
    TabOrder = 2
    DefaultCanvas = 'TGDIPlusCanvas'
    PrintMargins = (
      15
      23
      15
      23)
    ColorPaletteIndex = 9
    object LineSeries1: TLineSeries
      Brush.BackColor = clDefault
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object LineSeries2: TLineSeries
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object LineSeries3: TLineSeries
      Brush.BackColor = clDefault
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object LineSeries4: TLineSeries
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series4: TLineSeries
      SeriesColor = clFuchsia
      Brush.BackColor = clDefault
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series10: TLineSeries
      SeriesColor = clFuchsia
      Brush.BackColor = clDefault
      LinePen.Style = psDash
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series15: TLineSeries
      SeriesColor = clAqua
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series16: TLineSeries
      SeriesColor = 16744448
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object Chart3: TChart
    Left = 391
    Top = 581
    Width = 802
    Height = 293
    Legend.Alignment = laTop
    Legend.CheckBoxes = True
    Legend.Frame.Color = clSilver
    Legend.TopPos = 0
    Legend.VertMargin = 1
    MarginTop = 0
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    OnScroll = ChartScroll
    OnUndoZoom = ChartUndoZoom
    OnZoom = ChartZoom
    BottomAxis.Grid.Color = 14540253
    LeftAxis.Grid.Color = 14540253
    RightAxis.Grid.Visible = False
    View3D = False
    Zoom.Pen.Color = 8388863
    Color = clWhite
    TabOrder = 3
    DefaultCanvas = 'TGDIPlusCanvas'
    PrintMargins = (
      15
      23
      15
      23)
    ColorPaletteIndex = 9
    object LineSeries9: TLineSeries
      Brush.BackColor = clDefault
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object LineSeries10: TLineSeries
      SeriesColor = 16685954
      Brush.BackColor = clDefault
      LinePen.Style = psDash
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.DateTime = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series6: TLineSeries
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series7: TLineSeries
      SeriesColor = 5592405
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series11: TLineSeries
      SeriesColor = clRed
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series13: TLineSeries
      SeriesColor = 33023
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series14: TLineSeries
      SeriesColor = 8454016
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series8: TLineSeries
      SeriesColor = clFuchsia
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      LinePen.Style = psDot
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series9: TLineSeries
      SeriesColor = clAqua
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      LinePen.Style = psDot
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series5: TLineSeries
      SeriesColor = 8388863
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      LinePen.Style = psDot
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object timerAutoRead: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = timerAutoReadTimer
    Left = 64
    Top = 304
  end
  object tmrScroll: TTimer
    Enabled = False
    Interval = 200
    OnTimer = tmrScrollTimer
    Left = 144
    Top = 312
  end
end
