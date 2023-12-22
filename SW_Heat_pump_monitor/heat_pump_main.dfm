object Form1: TForm1
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
      Top = 8
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
    object btnComOpen: TButton
      Left = 8
      Top = 39
      Width = 75
      Height = 25
      Caption = 'Open'
      TabOrder = 2
      OnClick = btnComOpenClick
    end
    object btnComClose: TButton
      Left = 8
      Top = 70
      Width = 75
      Height = 25
      Caption = 'Close'
      Enabled = False
      TabOrder = 3
      OnClick = btnComCloseClick
    end
    object btnReadData: TButton
      Left = 8
      Top = 119
      Width = 75
      Height = 25
      Caption = 'Read data'
      Enabled = False
      TabOrder = 4
      OnClick = btnReadDataClick
    end
    object mm1: TMemo
      Left = 8
      Top = 544
      Width = 377
      Height = 321
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
      Top = 150
      Width = 75
      Height = 17
      Caption = 'Constatntly'
      Enabled = False
      TabOrder = 6
      OnClick = cbReadConstatntlyClick
    end
    object gridData: TStringGrid
      Left = 8
      Top = 238
      Width = 377
      Height = 300
      ColCount = 2
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      OnClick = gridDataClick
      RowHeights = (
        24)
    end
    object cbDebug: TCheckBox
      Left = 8
      Top = 184
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
      Height = 193
      Caption = ' Settings '
      Color = clScrollBar
      ParentBackground = False
      ParentColor = False
      TabOrder = 9
      object Label1: TLabel
        Left = 24
        Top = 46
        Width = 19
        Height = 13
        Caption = 'Day'
      end
      object Label2: TLabel
        Left = 24
        Top = 80
        Width = 25
        Height = 13
        Caption = 'Night'
      end
      object Label3: TLabel
        Left = 64
        Top = 24
        Width = 27
        Height = 13
        Caption = 'Circ 1'
      end
      object Label4: TLabel
        Left = 137
        Top = 24
        Width = 27
        Height = 13
        Caption = 'Circ 2'
      end
      object lblWater: TLabel
        Left = 208
        Top = 24
        Width = 30
        Height = 13
        Caption = 'Water'
      end
      object edC1Day: TEdit
        Left = 64
        Top = 43
        Width = 57
        Height = 21
        TabOrder = 0
      end
      object edC2Day: TEdit
        Left = 137
        Top = 43
        Width = 57
        Height = 21
        TabOrder = 1
      end
      object edC1night: TEdit
        Left = 64
        Top = 77
        Width = 57
        Height = 21
        TabOrder = 2
      end
      object edC2Night: TEdit
        Left = 137
        Top = 77
        Width = 57
        Height = 21
        TabOrder = 3
      end
      object edWaterDay: TEdit
        Left = 208
        Top = 43
        Width = 57
        Height = 21
        TabOrder = 4
      end
      object edWaterNight: TEdit
        Left = 208
        Top = 77
        Width = 57
        Height = 21
        TabOrder = 5
      end
      object ddHPMode: TComboBox
        Left = 64
        Top = 111
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
        Left = 64
        Top = 152
        Width = 75
        Height = 25
        Caption = 'Read'
        Enabled = False
        TabOrder = 7
        OnClick = btnSettingsReadClick
      end
      object btnSettingsWrite: TButton
        Left = 190
        Top = 152
        Width = 75
        Height = 25
        Caption = 'Write'
        Enabled = False
        TabOrder = 8
        OnClick = btnSettingsWriteClick
      end
    end
    object cbDbgAddr: TCheckBox
      Left = 8
      Top = 207
      Width = 80
      Height = 17
      Caption = 'Dbg Address'
      TabOrder = 10
    end
    object btnLoadCharts: TButton
      Left = 312
      Top = 8
      Width = 73
      Height = 25
      Caption = 'Load charts'
      TabOrder = 11
      OnClick = btnLoadChartsClick
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
      LinePen.Width = 2
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
      LinePen.Width = 2
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
    object Series12: TLineSeries
      SeriesColor = clAqua
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
    object LineSeries11: TLineSeries
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
    object Series5: TLineSeries
      SeriesColor = 8388863
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
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
    object Series8: TLineSeries
      SeriesColor = clFuchsia
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
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
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series10: TLineSeries
      SeriesColor = clSilver
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
  object tmr1: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = tmr1Timer
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
