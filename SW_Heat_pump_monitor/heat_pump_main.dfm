object FormHPmonitor: TFormHPmonitor
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 
    'Stiebel Eltron heat pump WPM manager over optical interface [by ' +
    'Aljaz Ogrin]'
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
  PixelsPerInch = 96
  TextHeight = 13
  object pnlComm: TPanel
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
      Enabled = False
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
    object mmLog: TMemo
      Left = 8
      Top = 768
      Width = 377
      Height = 97
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial Narrow'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 5
    end
    object cbReadConstatntly: TCheckBox
      Left = 101
      Top = 93
      Width = 75
      Height = 17
      Caption = 'Constatntly'
      Enabled = False
      TabOrder = 6
      OnClick = cbReadConstatntlyClick
    end
    object gridData: TStringGrid
      Left = 8
      Top = 120
      Width = 377
      Height = 642
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
      Left = 316
      Top = 66
      Width = 63
      Height = 17
      Caption = 'Debug'
      TabOrder = 8
      OnClick = cbDebugClick
    end
    object btnTest: TButton
      Left = 310
      Top = 35
      Width = 75
      Height = 25
      Caption = 'Test'
      TabOrder = 9
      OnClick = btnTestClick
    end
    object btnEnergy: TButton
      Left = 214
      Top = 89
      Width = 75
      Height = 25
      Caption = 'Energy'
      TabOrder = 10
      OnClick = btnEnergyClick
    end
    object cbLogCommErrors: TCheckBox
      Left = 101
      Top = 39
      Width = 97
      Height = 17
      Caption = 'Log comm errors'
      TabOrder = 11
    end
    object btnErrors: TButton
      Left = 214
      Top = 62
      Width = 75
      Height = 25
      Caption = 'Errors'
      TabOrder = 12
      OnClick = btnErrorsClick
    end
    object btnSettings: TButton
      Left = 214
      Top = 35
      Width = 75
      Height = 25
      Caption = 'Settings'
      TabOrder = 13
      OnClick = btnSettingsClick
    end
  end
  object chart1: TChart
    Left = 391
    Top = 0
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
    object Series5: TLineSeries
      SeriesColor = clSilver
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
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
    object Series9: TLineSeries
      SeriesColor = clAqua
      VertAxis = aRightAxis
      Brush.BackColor = clDefault
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object btnLoadCharts: TButton
    Left = 310
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Load charts'
    TabOrder = 4
    OnClick = btnLoadChartsClick
  end
  object timerAutoRead: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = timerAutoReadTimer
    Left = 64
    Top = 304
  end
  object tmrScrollZoomCharts: TTimer
    Enabled = False
    Interval = 200
    OnTimer = tmrScrollZoomChartsTimer
    Left = 176
    Top = 312
  end
  object tmrStartup: TTimer
    Interval = 3000
    OnTimer = tmrStartupTimer
    Left = 64
    Top = 248
  end
  object OpenDialogTxt: TOpenDialog
    Filter = 'Text (*.csv)|*.csv'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 328
    Top = 216
  end
end
