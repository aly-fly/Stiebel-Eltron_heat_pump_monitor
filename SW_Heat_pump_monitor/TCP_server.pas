unit TCP_server;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, IdContext, IdStack, IdStackConsts;

const
  RW_TIMEOUT = 10*1000;
  KEEPALIVE_TIMEOUT = 5*60*1000;
  KEEPALIVE_INTERVAL = 60*1000;
             
type
  TServerParameter = record
    Command : AnsiString;
    Value : AnsiString;
    end;
  TServerData = array of TServerParameter;
  
type
  TFormTCPserver = class(TForm)
    IdTCPServer: TIdTCPServer;
    tmrKickAllClients: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure IdTCPServerConnect(AContext: TIdContext);
    procedure IdTCPServerDisconnect(AContext: TIdContext);
    procedure IdTCPServerExecute(AContext: TIdContext);
    procedure IdTCPServerException(AContext: TIdContext; AException: Exception);
    procedure IdTCPServerListenException(AThread: TIdListenerThread; AException: Exception);
    procedure IdTCPServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrKickAllClientsTimer(Sender: TObject);
  private
    procedure Display(p_message : string; Debug : Boolean);
    procedure GetLocalIPAddress(var List: TStringlist);
    procedure ShowNumberOfClients(p_disconnected : Boolean=False);
    procedure BroadcastMessage(p_message : string);
    procedure KickAllClients;
    function ProcessCommandFromClient(sCommand : AnsiString; var sResponse : AnsiString) : Boolean;
  public
    PrintDebug: procedure(sss : string);
    PrintError: procedure(sss : string);
    TCPport : Word;
    // input data to be served - link to the table in the main form
    procedure ServerStart;
    procedure ServerStop;
  end;

var
  FormTCPserver: TFormTCPserver;
  ServerData : TStringGrid;

implementation

{$R *.dfm}

procedure PrintDebug_internal(sss : string);
begin
  ShowMessage(sss);
end;
procedure PrintError_internal(sss : string);
begin
  ShowMessage(sss);
end;

procedure TFormTCPserver.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ServerStop;
  ServerData := nil;
end;

procedure TFormTCPserver.FormCreate(Sender: TObject);
begin
  PrintDebug := PrintDebug_internal;
  PrintError := PrintError_internal;
  TCPport := 0;
end;

procedure TFormTCPserver.ServerStart;
var
  LocalIPs : TStringlist;
  txt : string;
  i : Integer;
  
begin
  if IdTCPServer.Active then Exit;
  if TCPport = 0 then Exit;
    
  // ... START SERVER:

  // ... clear the Bindings property ( ... Socket Handles )
  IdTCPServer.Bindings.Clear;
  // ... Bindings is a property of class: TIdSocketHandles;

  // ... add listening ports:
  // ... add a port for connections from guest clients.
  IdTCPServer.Bindings.DefaultPort := TCPport;
  IdTCPServer.Bindings.Add.Port := TCPport;

  // ... ok, Active the Server!
  IdTCPServer.Active   := True;

  LocalIPs := TStringlist.Create;
  GetLocalIPAddress(LocalIPs);
  
  // ... message log
  txt := 'Server started. Port: ' + IntToStr(TCPport) + '  IP: ';
  for i := 0 to LocalIPs.Count-1 do
    txt := txt + LocalIPs.Strings[i] + '  ';
  Display(txt, false);

  tmrKickAllClients.Interval := 15*60*1000; // check and cleanup every 15 minutes
  tmrKickAllClients.Enabled := True;
end;

procedure TFormTCPserver.ServerStop;
begin
  tmrKickAllClients.Enabled := False;
  if NOT IdTCPServer.Active then Exit;


  // ... before stopping the server ... send 'good bye' to all clients connected
  BroadcastMessage('Goodbye');

  // ... stop server!
  IdTCPServer.Active := False;

  // ... message log
  Display('Server stopped.', true);
end;

procedure TFormTCPserver.Display(p_message : string; Debug : Boolean);
begin
  TThread.Queue(nil, procedure
                     begin
                       if Debug 
                       then PrintDebug(p_message)    // show msg only if program is in Debug mode
                       else PrintError(p_message);   // always show message
                     end
               );

  // ... TThread.Queue() causes the call specified by AMethod to be asynchronously executed using the main thread, thereby avoiding multi-thread conflicts.
end;

procedure TFormTCPserver.GetLocalIPAddress(var List: TStringlist);
begin     
  TIdStack.IncUsage; 
  try 
    List.Assign(TStringlist(GStack.LocalAddresses))
  finally 
    TIdStack.DecUsage; 
  end; 
end;

//           OCCURS ANY TIME A CLIENT IS CONNECTED
procedure TFormTCPserver.IdTCPServerConnect(AContext: TIdContext);
var
  ip          : string;
  port        : Integer;
  peerIP      : string;
  peerPort    : Integer;

  msgToClient : string;

begin
  // ... OnConnect is a TIdServerThreadEvent property that represents the event
  //     handler signalled when a new client connection is connected to the server.

  // ... Use OnConnect to perform actions for the client after it is connected
  //     and prior to execution in the OnExecute event handler.

  // ... see indy doc:
  //     http://www.indyproject.org/sockets/docs/index.en.aspx

  // ... getting IP address and Port of Client that connected
  ip        := AContext.Binding.IP;
  port      := AContext.Binding.Port;
  peerIP    := AContext.Binding.PeerIP;
  peerPort  := AContext.Binding.PeerPort;

  // ... message log
  Display('SERVER: Client Connected: ' + PeerIP + ' : ' + IntToStr(PeerPort), false);

  // ... display the number of clients connected
  ShowNumberOfClients();

  AContext.Binding.SetKeepAliveValues(True, KEEPALIVE_TIMEOUT, KEEPALIVE_INTERVAL);
  AContext.Binding.SetSockOpt(id_SOL_SOCKET, Id_SO_KEEPALIVE, 1);
  AContext.Binding.SetSockOpt(id_SOL_SOCKET, Id_SO_RCVTIMEO, RW_TIMEOUT);
  AContext.Binding.SetSockOpt(id_SOL_SOCKET, Id_SO_SNDTIMEO, RW_TIMEOUT);
  AContext.Connection.IOHandler.ReadTimeout := RW_TIMEOUT;
  
  // ... CLIENT CONNECTED:
  if Port = TCPport then
    begin
    // ... send the Welcome message to Client connected
    msgToClient := 'Welcome';
    AContext.Connection.IOHandler.WriteLn( msgToClient );
    end;
end;

//           OCCURS ANY TIME A CLIENT IS DISCONNECTED
procedure TFormTCPserver.IdTCPServerDisconnect(AContext: TIdContext);
var
//  ip          : string;
//  port        : Integer;
  peerIP      : string;
  peerPort    : Integer;

begin
  // ... getting IP address and Port of Client that connected
//  ip        := AContext.Binding.IP;
//  port      := AContext.Binding.Port;
  peerIP    := AContext.Binding.PeerIP;
  peerPort  := AContext.Binding.PeerPort;

  // ... message log
  Display('SERVER: Client Disconnected: ' + PeerIP + ' : ' + IntToStr(PeerPort), false);

  // ... display the number of clients connected
  ShowNumberOfClients(true);
end;

procedure TFormTCPserver.IdTCPServerException(AContext: TIdContext; AException: Exception);
begin
  Display('SERVER: ' + Trim(AException.Message), false);
end;

//           ON EXECUTE THREAD CLIENT
procedure TFormTCPserver.IdTCPServerExecute(AContext: TIdContext);
var
  PeerPort      : Integer;
  PeerIP        : string;

  msgFromClient : string;
  msgToClient   : AnsiString;
    
begin
  // ... OnExecute is a TIdServerThreadEvents event handler used to execute
  //     the task for a client connection to the server.

  // ... here you can check connection status and buffering before reading
  //     messages from client

  // ... see doc:
  // ... AContext.Connection.IOHandler.InputBufferIsEmpty
  // ... AContext.Connection.IOHandler.CheckForDataOnSource(<milliseconds>);
  //     (milliseconds to wait for the connection to become readable)
  // ... AContext.Connection.IOHandler.CheckForDisconnect;

  // ... received a message from the client

  // ... get message from client
  msgFromClient := AContext.Connection.IOHandler.ReadLn;

  // ... getting IP address, Port and PeerPort from Client that is talking to us
  peerIP    := AContext.Binding.PeerIP;
  peerPort  := AContext.Binding.PeerPort;

  // ... message log
  Display('CLIENT: ' + PeerIP + ':' + IntToStr(PeerPort) + '): ' + msgFromClient, true);

  // process message from Client and send response back if everything is okay
  if ProcessCommandFromClient(ansistring(trim(msgFromClient)), msgToClient) then 
    begin
    Display('SERVER: Command is recognized. Returning data: "'+msgToClient+'".', true);
    AContext.Connection.IOHandler.WriteLn(string(msgToClient));
    end;
end;

procedure TFormTCPserver.IdTCPServerListenException(AThread: TIdListenerThread; AException: Exception);
begin
  Display('SERVER: ' + AException.Message, false);
end;

procedure TFormTCPserver.IdTCPServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  // ... OnStatus is a TIdStatusEvent property that represents the event handler triggered when the current connection state is changed...
  Display('SERVER: ' + AStatusText, false);
end;

//               BROADCAST A MESSAGE TO ALL CLIENTS CONNECTED
procedure TFormTCPserver.broadcastMessage(p_message : string);
var
  tmpList      : TList;
  contexClient : TidContext;
  i            : integer;
  
begin
  // ... get context Locklist
  tmpList  := IdTCPServer.Contexts.LockList;
  try
    i := 0;
    while ( i < tmpList.Count ) do begin
      // ... get context (thread of i-client)
      contexClient := tmpList[i];

      // ... send message to client
      contexClient.Connection.IOHandler.WriteLn(p_message);
      i := i + 1;
    end;

  finally
    // ... unlock list of clients!
    IdTCPServer.Contexts.UnlockList;
  end;
end;

procedure TFormTCPserver.KickAllClients;
var
  tmpList      : TList;
  contexClient : TidContext;
  i            : integer;
  
begin
  // ... get context Locklist
  tmpList  := IdTCPServer.Contexts.LockList;
  try
    i := 0;
    while ( i < tmpList.Count ) do begin
      // ... get context (thread of i-client)
      contexClient := tmpList[i];

      // ... disconnect the client
      contexClient.Connection.IOHandler.CloseGracefully;
      i := i + 1;
    end;

  finally
    // ... unlock list of clients!
    IdTCPServer.Contexts.UnlockList;
  end;
end;

procedure TFormTCPserver.ShowNumberOfClients(p_disconnected : Boolean=False);
var
    nClients : integer;
begin
  try
      // ... get number of clients connected
      nClients := IdTCPServer.Contexts.LockList.Count;
  finally
      IdTCPServer.Contexts.UnlockList;
  end;

  // ... client disconnected?
  if p_disconnected then dec(nClients);

  Display('SERVER: Clients connected = ' + IntToStr(nClients), true);
end;

procedure TFormTCPserver.tmrKickAllClientsTimer(Sender: TObject);
var
    nClients : integer;
begin
  if not IdTCPServer.Active then
    begin
    tmrKickAllClients.Enabled := False;
    exit;
    end;

  // get number of clients connected
  try
    nClients := IdTCPServer.Contexts.LockList.Count;
  finally
    IdTCPServer.Contexts.UnlockList;
  end;

  // cleanup of the old unused connections, probably already disconnected clients
  if nClients > (IdTCPServer.MaxConnections / 2) then KickAllClients();
end;

// Main command processor. Ignores CR / LF and other special chars
function TFormTCPserver.ProcessCommandFromClient(sCommand : AnsiString; var sResponse : AnsiString) : Boolean;
var
  i : Integer;
  
begin
  sCommand := UpperCase(Trim(sCommand));
  Result := False; // failed, do not respond to the client
  if ServerData = nil then exit;

  for i := 0 to ServerData.RowCount-1 do
    begin
    // column 0 is name, column 1 is value
    if sCommand = UpperCase(ServerData.Cells[0,i]) then
      begin
      sResponse := ServerData.Cells[1,i];
      Result := True;
      Break;
      end;
    end;
end;

end.
