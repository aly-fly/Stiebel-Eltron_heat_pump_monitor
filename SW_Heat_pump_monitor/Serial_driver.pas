unit Serial_driver;

interface
uses
  Windows, Orodja;

var
  COM_TimeOut_ms : cardinal;
  COM_DEBUG_LOG_ENABLED : Boolean;
  COM_DEBUG_COMMS : string;

// -------------------------------------------------------------------------------------------------------------

  function COM_Read(Ch: THandle; Pricakovanih : cardinal; var SOut: AnsiString) : boolean;

  function COM_Write(var Ch: THandle; podatki: AnsiString) : boolean;

  function COM_Purge(Ch: THandle) : boolean;

  function COM_SendAndWait(Ch: THandle; SIn: AnsiString; N: Cardinal; var SOut: AnsiString): Integer;

// -------------------------------------------------------------------------------------------------------------

implementation

function COM_Read(Ch: THandle; Pricakovanih : cardinal; var SOut: AnsiString) : boolean;
var
  CharsAvailable, CharsToRead, CharsRead: DWord;
  sBuffer: ansistring;
  CST : TComStat;
  T0, Err : cardinal;
  OK : Boolean;

begin
  Result := False;
  if Ch = INVALID_HANDLE_VALUE then exit;

  SOut := '';
  sBuffer := '';
  T0 := GetTickCount;
  repeat
    ClearCommError(Ch,Err,@CST);
    CharsAvailable := CST.cbInQue;
    if CharsAvailable > 0 then
      begin
(*      if Pricakovanih > 0
        then CharsToRead := Pricakovanih - Length(Sout)
        else *) CharsToRead := CharsAvailable;
      SetLength(sBuffer, CharsToRead);
      ReadFile(Ch, sBuffer[1], CharsToRead, CharsRead, nil);
      SetLength(sBuffer,CharsRead);
      SOut := SOut + sBuffer;
      SetLength(sBuffer,0);
      end;
    if Pricakovanih = 0 then
      begin
      Ok := (Pos(#13,SOut) <> 0) or (Length(SOut) > 1);
      end
    else
      OK := Length(SOut) >= Pricakovanih;
  until OK or ((GetTickCount-T0) > COM_TimeOut_ms);

 if COM_DEBUG_LOG_ENABLED then COM_DEBUG_COMMS := COM_DEBUG_COMMS + 'RX:'+SOut + CRLF;

  Result := OK;
end;
//----------------------------------------------------------------------------------------------------------------------

function COM_Write(var Ch: THandle; podatki: AnsiString) : boolean;
var
  Written : Cardinal;

begin
  Result := False;
  if Ch = INVALID_HANDLE_VALUE then exit;

  if not WriteFile(Ch, PAnsiChar(podatki)^, Length(podatki), Written, nil) then
    begin
    Ch := INVALID_HANDLE_VALUE;
    Exit;
    end;

 if COM_DEBUG_LOG_ENABLED then COM_DEBUG_COMMS := COM_DEBUG_COMMS + 'TX:'+podatki + CRLF;
    
  Result := (Written = Length(podatki));
end;

//----------------------------------------------------------------------------------------------------------------------

function COM_Purge(Ch: THandle) : boolean;
begin
  Result := False;
  if Ch = INVALID_HANDLE_VALUE then exit;

            PurgeComm (Ch, PURGE_RXABORT);   // Terminates all outstanding overlapped read operations and returns immediately, even if the read operations have not been completed.
  Result := PurgeComm (Ch, PURGE_RXCLEAR);   // Clears the input buffer
end;

//----------------------------------------------------------------------------------------------------------------------

function COM_SendAndWait(Ch: THandle; SIn: AnsiString; N: Cardinal; var SOut: AnsiString): Integer;
var
  cbCharsAvailable, cbCharsRead: DWord;
  sBuffer: AnsiString;
  Written: Cardinal;
  T: Cardinal;
  Ok: Boolean;
  Error: Cardinal;
  CST: TComStat;

begin
//  wait (100);

  Result := -3;
  if Ch <> INVALID_HANDLE_VALUE then
  begin
    if WriteFile(Ch, PAnsiChar(SIn)^, Length(SIn), Written, nil) then
    begin
      if COM_DEBUG_LOG_ENABLED then COM_DEBUG_COMMS := COM_DEBUG_COMMS + 'TX:'+SIn + CRLF;
      SOut := '';
      sBuffer := '';
      T := GetTickCount;
      repeat
        ClearCommError(Ch,Error,@CST);
        cbCharsAvailable := CST.cbInQue;
        if cbCharsAvailable > 0 then
        begin
          SetLength(sBuffer,cbCharsAvailable);
          ReadFile(Ch, sBuffer[1], cbCharsAvailable, cbCharsRead, nil);
          SetLength(sBuffer,cbCharsRead);
          SOut := SOut + sBuffer;
          SetLength(sBuffer,0);
        end;
        if N = 0 then
        begin
          Ok := (Pos(#13,SOut) <> 0);
        end
        else
          OK := Length(SOut) >= N;
      until OK or ((GetTickCount-T) > COM_TimeOut_ms);
      if Ok then
      begin
        Result := 0;
      end
      else begin
        Result := -1;                 // TimeOut
      end;
      if COM_DEBUG_LOG_ENABLED then COM_DEBUG_COMMS := COM_DEBUG_COMMS + 'RX:'+SOut + CRLF;
    end
    else
      try
        Result := -GetLastError;
      except
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

initialization

  COM_TimeOut_ms := 400; // 0,3 sekunde
  COM_DEBUG_LOG_ENABLED := False;
  COM_DEBUG_COMMS := '';

end.
