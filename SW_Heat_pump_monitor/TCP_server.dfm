object FormTCPserver: TFormTCPserver
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'TCP server'
  ClientHeight = 338
  ClientWidth = 651
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
  object IdTCPServer: TIdTCPServer
    OnStatus = IdTCPServerStatus
    Bindings = <>
    DefaultPort = 0
    MaxConnections = 5
    OnConnect = IdTCPServerConnect
    OnDisconnect = IdTCPServerDisconnect
    OnException = IdTCPServerException
    OnListenException = IdTCPServerListenException
    OnExecute = IdTCPServerExecute
    Left = 160
    Top = 88
  end
end
