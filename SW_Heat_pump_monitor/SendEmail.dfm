object FormSendEmail: TFormSendEmail
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'FormSendEmail'
  ClientHeight = 221
  ClientWidth = 248
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object IdMessage1: TIdMessage
    AttachmentEncoding = 'UUE'
    BccList = <>
    CCList = <>
    Encoding = meDefault
    FromList = <
      item
      end>
    Recipients = <>
    ReplyTo = <>
    ConvertPreamble = True
    Left = 72
    Top = 120
  end
  object IdSMTP1: TIdSMTP
    OnStatus = IdSMTP1Status
    IOHandler = IdSSLIOHandlerSocketOpenSSL1
    Host = 'smtp.gmail.com'
    Password = '***'
    Port = 587
    SASLMechanisms = <>
    UseTLS = utUseExplicitTLS
    Username = '****'
    Left = 72
    Top = 16
  end
  object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    OnStatus = IdSSLIOHandlerSocketOpenSSL1Status
    Destination = 'smtp.gmail.com:587'
    Host = 'smtp.gmail.com'
    MaxLineAction = maException
    Port = 587
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    OnStatusInfo = IdSSLIOHandlerSocketOpenSSL1StatusInfo
    Left = 72
    Top = 64
  end
end
