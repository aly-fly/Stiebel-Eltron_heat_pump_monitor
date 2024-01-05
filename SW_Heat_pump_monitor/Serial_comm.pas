(******************************************************************************)
(******************************************************************************)
(*                                                                            *)
(*  Procedure za serijsko komunikacijo s podporo iskanja naprav               *)
(*  Avtor: Aljaž Ogrin                                                        *)
(*  Datum: 19. 1. 2015                                                        *)
(*  Revizija: 0                                                               *)
(*                                                                            *)
(******************************************************************************)
(******************************************************************************)


unit Serial_comm;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Dialogs, Registry;

const
  ComReadTimeout = 800; // ms
  STX = #02;
  ETX = #03;
  CR  = #13;
  CRLF = #13#10;

  RegRootKeyHardware = HKEY_LOCAL_MACHINE;
  RegPathHardwareCom : string = 'hardware\devicemap\serialcomm';


type
  TTipUsbNaprave = (FTDI, STM32, Prolific, Nepoznana);

  TSerijskaNaprava = record
    // direktna vrednost iz registra
    Ime : string;
    Vrednost : string;
    // obdelana vrednost iz registra
    TipNaprave : TTipUsbNaprave;
    ComPort : integer;
    // poskus priklopa
    Handle : THandle;
    PortNaVoljo : boolean;
    Baudrate : cardinal;
    StopBits : Byte;
    Parity : byte;
    ID_vprasanje,
    ID_odgovor : ansistring;
    // naprava najdena
    Najdena : boolean;
    Opis : string;
  end;

var
  USBnaprave : array of TSerijskaNaprava;



////////////////////////////////////////////////////////////////////////////////



  procedure IsciCOMporteVregistru;
  function  IsciFTDISNVregistru(SN: String): Integer;

  function ComPortOpen (var Naprava : TSerijskaNaprava) : boolean;
  function ComPortSetBaudRate (var Naprava : TSerijskaNaprava) : boolean;

  procedure ComPortFlush (var Naprava : TSerijskaNaprava);  Overload;
  procedure ComPortFlush (var H : THandle);                 Overload;
  function ComPortWrite (var Naprava : TSerijskaNaprava; s : AnsiString) : boolean;  Overload;
  function ComPortWrite (var H : THandle;                s : AnsiString) : boolean;  Overload;
  function ComPortWaitRead (var Naprava : TSerijskaNaprava; min_dolzina: integer; var prejeto : ansistring) : boolean;  Overload;
  function ComPortWaitRead (var H : THandle;                min_dolzina: integer; var prejeto : ansistring) : boolean;  Overload;

  procedure ComPortClose (var Naprava : TSerijskaNaprava); Overload;
  procedure ComPortClose (var H : THandle);                Overload;

  function ComPortSetRTSsignal (var H : THandle; NewValue : boolean) : boolean; Overload;
  function ComPortSetRTSsignal (var Naprava : TSerijskaNaprava; NewValue : boolean) : boolean; Overload;

////////////////////////////////////////////////////////////////////////////////

implementation

uses  orodja;


procedure IsciCOMporteVregistru();
var
  Reg: TRegistry;
  St: Tstrings;
  S: string;
  i : integer;
  CPN: Integer;
  NovaNaprava : integer;

begin
  SetLength(USBnaprave, 0);
  NovaNaprava := -1;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := RegRootKeyHardware;
    Reg.OpenKeyReadOnly(RegPathHardwareCom);
    St := TStringList.Create;
    try
      Reg.GetValueNames(St);
      for I := 0 to St.Count - 1 do
        begin
//        if (Pos('VCP',St.Strings[I]) > 0) OR  // FTDI
//           (Pos('USBSER',St.Strings[I]) > 0) then  // STM VCP
          begin
          S := Reg.Readstring(St.Strings[I]);
          if Pos('COM',S) = 1 then
            begin
            inc(NovaNaprava);
            SetLength(USBnaprave, NovaNaprava+1);
            USBnaprave[NovaNaprava].Ime := St.Strings[I];
            USBnaprave[NovaNaprava].Vrednost := S;

            CPN := StrToIntDef(Copy(S,4,Length(S)),1);
            USBnaprave[NovaNaprava].ComPort := CPN;

            if (Pos('VCP'   ,St.Strings[I]) > 0) then  USBnaprave[NovaNaprava].TipNaprave := FTDI else
            if (Pos('USBSER',St.Strings[I]) > 0) then  USBnaprave[NovaNaprava].TipNaprave := STM32 else
            if (Pos('Prolific',St.Strings[I]) > 0) then  USBnaprave[NovaNaprava].TipNaprave := Prolific else
            USBnaprave[NovaNaprava].TipNaprave := Nepoznana;
            USBnaprave[NovaNaprava].StopBits := ONESTOPBIT;
            USBnaprave[NovaNaprava].Parity := NOPARITY;
            end;
          end;
        end;
    finally
      St.Free;
    end;
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;


//-------------------------------------------------------------------------------------------------

function IsciFTDISNVregistru(SN:String): Integer;
//HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\FTDIBUS\VID_0403+PID_6001+AH06HJRCA
//HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\FTDIBUS\VID_0403+PID_6001+AH06HJRCA\0000\Device Parameters

var
  Reg: TRegistry;
  S: string;
begin
  Result := 0;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    S := 'SYSTEM\CurrentControlSet\Enum\FTDIBUS\VID_0403+PID_6001+'+UpperCase(SN)+'\0000\Device Parameters';
    if Reg.KeyExists(S) then
    begin
      if Reg.OpenKeyReadOnly(S) then
      begin
        if Reg.ValueExists ('PortName') then
        begin
          S := Reg.ReadString('PortName');
          if Pos('COM',S)=1 then
          begin
            S := Copy(S,4,Length(S));
            Result := StrToIntDef(S,0);
          end;
        end
        else
          Result := 0;
      end;
    end;
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;



//-------------------------------------------------------------------------------------------------

function ComPortOpen (var Naprava : TSerijskaNaprava) : boolean;
var
  comport : string;

begin
  comport := '\\.\COM' + inttostr(Naprava.ComPort);
  Naprava.Handle := INVALID_HANDLE_VALUE;
  Naprava.Handle := CreateFile(PChar(comport),GENERIC_READ+GENERIC_WRITE,0,NIL,OPEN_EXISTING,0,0);
  (*
  if Naprava.Handle <> INVALID_HANDLE_VALUE then
    begin
    wait(50);
    getcommstate(Naprava.Handle, mdcb);
//    er := getlasterror;
    mdcb.BaudRate := Naprava.Baudrate;
    mdcb.ByteSize := 8;
    mdcb.StopBits := OneStopBit;
    mdcb.Parity := Naprava.Parity;
//    setCommState(Naprava.Handle, mdcb);
    if setCommState(Naprava.Handle, mdcb) = False then // error
      Naprava.Handle := INVALID_HANDLE_VALUE;
    wait(50);

//    EscapeCommFunction (Naprava.Handle, CLRRTS);
//    EscapeCommFunction (Naprava.Handle, CLRDTR);
    end; // opened
  *)
  Naprava.PortNaVoljo := Naprava.Handle <> INVALID_HANDLE_VALUE;
  result := Naprava.PortNaVoljo;
end;

//-------------------------------------------------------------------------------------------------

function ComPortSetBaudRate (var Naprava : TSerijskaNaprava) : boolean;
var
  mdcb : TDCB;

begin
  if Naprava.Handle <> INVALID_HANDLE_VALUE then
    begin
    getcommstate(Naprava.Handle, mdcb);
//    er := getlasterror;
    mdcb.BaudRate := Naprava.Baudrate;
    mdcb.ByteSize := 8;
    mdcb.StopBits := Naprava.StopBits;
    mdcb.Parity := Naprava.Parity;
    if setCommState(Naprava.Handle, mdcb) = False then // error
      Naprava.Handle := INVALID_HANDLE_VALUE;
    wait (50);  // sicer ne spozna Keyence 2D kamere
    end;
  Naprava.PortNaVoljo := Naprava.Handle <> INVALID_HANDLE_VALUE;
  result := Naprava.PortNaVoljo;
end;

//-------------------------------------------------------------------------------------------------

procedure ComPortClose (var Naprava : TSerijskaNaprava);
begin
  if Naprava.Handle <> INVALID_HANDLE_VALUE then
    CloseHandle(Naprava.Handle);
  Naprava.Handle := INVALID_HANDLE_VALUE;
end;

procedure ComPortClose (var H : THandle);
begin
  if H <> INVALID_HANDLE_VALUE then
    CloseHandle(H);
  H := INVALID_HANDLE_VALUE;
end;

//-------------------------------------------------------------------------------------------------


procedure ComPortFlush (var Naprava : TSerijskaNaprava);
begin
  if Naprava.Handle <> INVALID_HANDLE_VALUE then
    begin
    PurgeComm (Naprava.Handle, PURGE_RXABORT);   // Terminates all outstanding overlapped read operations and returns immediately, even if the read operations have not been completed.
    PurgeComm (Naprava.Handle, PURGE_RXCLEAR);   // Clears the input buffer
    end;
end;

procedure ComPortFlush (var H : Thandle);
begin
  if H <> INVALID_HANDLE_VALUE then
    begin
    PurgeComm (H, PURGE_RXABORT);   // Terminates all outstanding overlapped read operations and returns immediately, even if the read operations have not been completed.
    PurgeComm (H, PURGE_RXCLEAR);   // Clears the input buffer
    end;
end;

//-------------------------------------------------------------------------------------------------

function ComPortWrite (var H : THandle; s : AnsiString) : boolean;
var
  written: cardinal;

begin
  result := false;
  if H <> INVALID_HANDLE_VALUE then
    begin
    WriteFile(H, PAnsiChar(S)^, Length(S), Written, nil);
    if smallint(written) = length (S)
      then result := True
      else
        begin
        ComPortClose(H);
        ShowMessage('Can''t write to COM port ' + inttostr(H));
        end;
    end;
end;

function ComPortWrite (var Naprava : TSerijskaNaprava; s : AnsiString) : boolean;
var
//  s1 : string;
  Barr : array of Byte;
  len, written: cardinal;

begin
  result := false;
  if Naprava.Handle <> INVALID_HANDLE_VALUE then
    begin
    len := length(s);
    SetLength(Barr, len);
    move(s[1], Barr[0], len);
    WriteFile(Naprava.Handle, Barr[0], len, Written, nil);

//    WriteFile(Naprava.Handle, PAnsiChar(S)^, Length(S), Written, nil);

//    s1 := string(s);
//    WriteFile(Naprava.Handle, PChar(S1)^, Length(S1), Written, nil);

//    WriteFileEx(Naprava.Handle, PAnsiChar(S)^, Length(S), nil, nil);

    if smallint(written) = length (S)
      then result := True
      else
        begin
        ComPortClose(Naprava);
        ShowMessage('Can''t write to COM port ' + inttostr(Naprava.ComPort));
        end;
    SetLength(Barr, 0);
    end;
end;




//-------------------------------------------------------------------------------------------------

function ComPortWaitRead (var H : THandle; min_dolzina: integer; var prejeto : ansistring) : boolean;
var
  available : dword;
  read: cardinal;
  TT : cardinal;
  buf : ansistring;
  er : Cardinal;
  CST : TComStat;

begin
  Result := False;
  prejeto := '';
  if H <> INVALID_HANDLE_VALUE then
    begin
    TT := GetTickCount;
    repeat
      // preberi znake in spravi v buffer
      clearcommerror (H, er, @cst);
      available := cst.cbInQue;
      if available > 0 then
        begin
        SetLength (buf, available); { allocate space }
        ReadFile (H, buf[1], available, read, nil);
        prejeto := prejeto + buf;
        if min_dolzina = 0
          then Result := pos(CR, prejeto) > 0
          else Result := (Length(prejeto) >= min_dolzina);
        end; // available
//      application.ProcessMessages;
    until Result OR (GetTickCount - TT > ComReadTimeout);
    end; // com ok
end;


function ComPortWaitRead (var Naprava : TSerijskaNaprava; min_dolzina: integer; var prejeto : ansistring) : boolean;
begin
  Result := ComPortWaitRead (Naprava.Handle, min_dolzina, prejeto);
end;

//-----------------------------------------------------------------------------------------------------------------------------------------

function ComPortSetRTSsignal (var H : THandle; NewValue : boolean) : boolean;
begin
  result := false;
  if H <> INVALID_HANDLE_VALUE then
    begin
    if NewValue
      then result := EscapeCommFunction (H, SETRTS)
      else result := EscapeCommFunction (H, CLRRTS);
    end;
end;

function ComPortSetRTSsignal (var Naprava : TSerijskaNaprava; NewValue : boolean) : boolean;
begin
  result := ComPortSetRTSsignal(Naprava.Handle, NewValue);
end;

//-----------------------------------------------------------------------------------------------------------------------------------------

initialization
begin
  SetLength(USBnaprave, 0);
end;

finalization
begin
  SetLength(USBnaprave, 0);
end;


//-----------------------------------------------------------------------------------------------------------------------------------------




(*

  PRIMER UPORABE - ISKANJE NAPRAV:


procedure IsciNapraveNaCOMportih;
var
  i : integer;

begin
  IsciCOMporteVregistru();

  for i := 0 to Length(USBNaprave)-1 do
    begin
    if ComPortOpen(USBNaprave[i]) then
      begin

      // RLS naprave z ukazom "v"
      USBNaprave[i].Najdena := False;
      if USBNaprave[i].TipNaprave = STM32 then
        begin
        USBNaprave[i].Baudrate := CBR_115200;  // nima veze
        USBNaprave[i].Parity := NoPARITY;      // nima veze
        USBNaprave[i].ID_vprasanje := 'v';
        if ComPortSetBaudRate (USBNaprave[i]) then
          if ComPortWrite(USBNaprave[i], USBNaprave[i].ID_vprasanje) then
            if ComPortWaitRead (USBNaprave[i], 5, USBNaprave[i].ID_odgovor) then
              begin
              if pos('meritev_IHall', USBNaprave[i].ID_odgovor) > 0 then
                begin
                MerilnikToka := USBNaprave[i].Handle;
                USBNaprave[i].Najdena := True;
                USBNaprave[i].Opis := 'Merilnik toka';
                end;
              if pos('AksIM connection box (00572) v1', USBNaprave[i].ID_odgovor) > 0 then
                begin
                MerilnikToka := USBNaprave[i].Handle;
                USBNaprave[i].Najdena := True;
                USBNaprave[i].Opis := 'Connection box v1';
                end;
              if pos('AksIM connection box (00572) v2', USBNaprave[i].ID_odgovor) > 0 then
                begin
                MerilnikToka := USBNaprave[i].Handle;
                USBNaprave[i].Najdena := True;
                USBNaprave[i].Opis := 'Connection box v2';
                end;
              end;
        end;

      if (not USBNaprave[i].Najdena) AND
         (NapajalnikHP6632B = INVALID_HANDLE_VALUE) AND
         ((USBNaprave[i].TipNaprave = Prolific) OR (USBNaprave[i].TipNaprave = FTDI)) then  // išèemo naprej
        begin
        // HP Agilent 6632B napajalnik - mora biti vedno prvi poiskan, sicer zašteka v napaki
        USBNaprave[i].Baudrate := CBR_9600;
        USBNaprave[i].Parity := NoPARITY;
        USBNaprave[i].ID_vprasanje := '*IDN?'+CRLF;
        USBNaprave[i].ID_odgovor := '';
          if ComPortSetBaudRate (USBNaprave[i]) then
            if ComPortWrite(USBNaprave[i], USBNaprave[i].ID_vprasanje) then
              if ComPortWaitRead (USBNaprave[i], 20, USBNaprave[i].ID_odgovor) then
                begin

                MainForm.Memo1.Lines.Add(USBNaprave[i].ID_odgovor);

                if pos('HEWLETT-PACKARD,6632B', USBNaprave[i].ID_odgovor) > 0 then
                  begin
                  NapajalnikHP6632B := USBNaprave[i].Handle;
                  USBNaprave[i].Najdena := True;
                  USBNaprave[i].Opis := 'Napajalnik HP Agilent 6632B';
                  end;
                end;
        end;  // HP Agilent 6632B napajalnik

      if (not USBNaprave[i].Najdena) AND
         (NapajalnikMatsusada = INVALID_HANDLE_VALUE) AND
         ((USBNaprave[i].TipNaprave = Prolific) OR (USBNaprave[i].TipNaprave = FTDI)) then  // išèemo naprej
        begin
        // Matsusada napajalnik
        USBNaprave[i].Baudrate := CBR_9600;
        USBNaprave[i].Parity := NoPARITY;
        USBNaprave[i].ID_vprasanje := AnsiToUtf8(#0 + 'UNIT?'+ #13);
        USBNaprave[i].ID_odgovor := '';
          if ComPortSetBaudRate (USBNaprave[i]) then
            if ComPortWrite(USBNaprave[i], USBNaprave[i].ID_vprasanje) then
              if ComPortWaitRead (USBNaprave[i], 5, USBNaprave[i].ID_odgovor) then
                begin
                if pos('UNIT=', USBNaprave[i].ID_odgovor) > 0 then
                  begin
                  NapajalnikMatsusada := USBNaprave[i].Handle;
                  USBNaprave[i].Najdena := True;
                  USBNaprave[i].Opis := 'Napajalnik Matsusada';
                  end;
                end;
        end;  // matsusada

      if (not USBNaprave[i].Najdena) AND
         (Kamera2D = INVALID_HANDLE_VALUE) AND
         ((USBNaprave[i].TipNaprave = Prolific) OR (USBNaprave[i].TipNaprave = FTDI)) then  // išèemo naprej
        begin
        // 2D kamera
        USBNaprave[i].Baudrate := CBR_115200;
        USBNaprave[i].Parity := EvenPARITY;
        USBNaprave[i].ID_vprasanje := 'LON' + CR + 'LOFF' + CR;
        USBNaprave[i].ID_odgovor := '';
          if ComPortSetBaudRate (USBNaprave[i]) then
            if ComPortWrite(USBNaprave[i], USBNaprave[i].ID_vprasanje) then
              if ComPortWaitRead (USBNaprave[i], 5, USBNaprave[i].ID_odgovor) then
                begin
                if (pos(STX, USBNaprave[i].ID_odgovor) > 0) AND
                   (pos(ETX, USBNaprave[i].ID_odgovor) > 0) then
                   begin
                   Kamera2D := USBNaprave[i].Handle;
                   USBNaprave[i].Najdena := True;
                   USBNaprave[i].Opis := '2D kamera';
                   end;
                end;
        end;  // matsusada

      end; // port odprt

    if NOT USBNaprave[i].Najdena then ComPortClose (USBNaprave[i]); // niè nismo našli na tem portu - sicer pusti port odprt
    //zapri porte za seboj
    // ComPortCloseN (USBNaprave[i]);
    end;  // sprehod po napravah
end;

*)

end.
