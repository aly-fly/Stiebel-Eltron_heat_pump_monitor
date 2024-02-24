unit SendEmail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP, Vcl.StdCtrls, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdMessage, IdSSLOpenSSLHeaders, orodja;

type
  TFormSendEmail = class(TForm)
    IdSMTP1: TIdSMTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    IdMessage1: TIdMessage;
    procedure IdSMTP1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure IdSSLIOHandlerSocketOpenSSL1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure IdSSLIOHandlerSocketOpenSSL1StatusInfo(const AMsg: string);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    PrintDebug: procedure(sss : string);
    PrintError: procedure(sss : string);
    EmailUser,
    EmailPass,
    EmailRcpt : string;
    function SendEmail(Subject, Body : string): Boolean;
  end;

var
  FormSendEmail: TFormSendEmail;

implementation

{$R *.dfm}

procedure PrintDebug_internal(sss : string);
begin
//  ShowMessage(sss);
end;
procedure PrintError_internal(sss : string);
begin
  ShowMessage(sss);
end;

// DLL: libeay32.dll + ssleay32.dll
// https://indy.fulgan.com/SSL/

function TFormSendEmail.SendEmail(Subject, Body : string): Boolean;
// https://www.marcocantu.com/tips/oct06_gmail.html
// +
// https://stackoverflow.com/questions/70867916/problem-sending-an-email-via-gmail-with-indy-smtp-client
// https://stackoverflow.com/questions/7717495/starttls-error-while-sending-email-using-indy-in-delphi-xe/7717862
// uses  IdMessage, IdSMTP, IdSSLOpenSSL, IdGlobal, IdExplicitTLSClientServerBase;

begin
  PrintDebug('Sending email...');
  Result := False;
  if (Length(EmailUser) < 5) OR
     (Length(EmailPass) < 5) OR
     (Length(EmailRcpt) < 5) then
    begin
    PrintError('Email settings are missing!');
    exit;
    end;  
  
  Result := True;
  IdMessage1.Subject := subject;
  IdMessage1.Body.Text := body;

  IdMessage1.From.Address := EmailUser;
  IdMessage1.Recipients.EmailAddresses := EmailRcpt;

  IdSMTP1.Username := EmailUser;
  IdSMTP1.Password := EmailPass;

  try
    IdSMTP1.Connect;
    IdSMTP1.Send(IdMessage1);
  except
    on E : Exception do
      begin
      Result := False;
      PrintError('===== ERROR! =====' + CRLF +
//              'Exception class = '+E.ClassName + CRLF + 
                'Exception message = ' + Trim(E.Message));
      end;
  end;
  IdSMTP1.Disconnect;
  PrintDebug('Done.');
end;


procedure TFormSendEmail.FormCreate(Sender: TObject);
begin
  PrintDebug := PrintDebug_internal;
  PrintError := PrintError_internal;
end;

procedure TFormSendEmail.IdSMTP1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  PrintDebug(AStatusText)
end;

procedure TFormSendEmail.IdSSLIOHandlerSocketOpenSSL1Status(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  PrintDebug(AStatusText)
end;

procedure TFormSendEmail.IdSSLIOHandlerSocketOpenSSL1StatusInfo(const AMsg: string);
begin
  PrintDebug(AMsg)
end;

end.
