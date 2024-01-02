unit heat_pump_comm;

interface

uses
  serial_comm, orodja, VCLTee.Series, System.SysUtils;

type
  THPdata = record
    Name : string;
    Request : AnsiString;
    Response : AnsiString;
    Device : u8;
    Circuit : u8;
    RegAddr : u16;
    Data : u16;
    DataLastRead : u16;
    Scaling : Double;
    Value : Double;
    Units : string;
    Series : TLineSeries;
  end;
  TAHPdata = array of THPdata;

const                // active circuits
  DEV_DIRECT  = $00; // 00 
  DEV_BOILER  = $03; // 00
  DEV_ATEZ    = $05; // --
  DEV_CONTROL = $06; //    01 02
  DEV_ROOM_S  = $08; // --
  DEV_MANAGER = $09; // 00
  DEV_HEATING = $0A; // 00
  DEV_BUS_CPL = $0B; // (all)
  DEV_MIXER   = $0C; //    01 02
  DEV_OPT_PC  = $0D; // (all)
  DEV_FOREIGN = $0E; // --
  DEV_DCF_CLK = $0F; // --

  (*
  serial can
  0x00   0x000 - direkt
  0x03   0x180 - Kessel
  0x05   0x280 - atez
  0x06   0x300, 301 ... - Bedienmodule (bei mir 301, 302 und 303)
  0x08   0x400 - Raumfernfühler
  0x09   0x480 - Manager
  0x0A   0x500 - Heizmodul
  0x0B   0x580 - Buskoppler
  0x0C   0x600, 601 ... -  Mischermodule (bei mir 601, 602, 603)
  0x0D   0x680 - PC (ComfortSoft)
  0x0E   0x700 - Fremdgerät
  0x0F   0x780 - DCF-Modul
*)

  QRY_WRITE    = 0;
  QRY_READ     = 1;
  QRY_RESPONSE = 2;
  QRY_ACK      = 3;
  QRY_WR_ACK   = 4;
  QRY_WR_RSP   = 5;
  QRY_SYS      = 6;
  QRY_SYS_RSP  = 7;
(*
  ('00','Write'),
  ('01','Read'),
  ('02','Response'),
  ('03','ack'),
  ('04','write ack'),
  ('05','write response'),
  ('06','system'),
  ('07','system response')
*)

  CIRC_GEN = 0;
  CIRC_HC1 = 1;
  CIRC_HC2 = 2;    
(*
  ('00fa','General'),
  ('01fa','HC 1'),
  ('02fa','HC 2')
*)

// internal  
procedure HPCompileRequest(var Dataset : TAHPdata; Didx : Integer; Query : u8; WData : u16; Test : Boolean);
function  HPCommunicate(var Dataset : TAHPdata; Didx : Integer) : Boolean;
// external
function  HPCommRead(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
function  HPCommWrite(var Dataset : TAHPdata; Didx : Integer) : Boolean;

var
  Uidx: Integer; // selected usb device index
  PrintDebugMsg : Boolean;
  HPLastMessage : string; // return detailed data to the caller


implementation

procedure CalcChecksum (sData : AnsiString; var sChecksum : AnsiString);
var
  checksum : u32;
  i : Integer;
begin
  checksum := 0;
  for i := 1 to 10 do
    begin
    checksum := checksum + u8(sData[i]);
    end;
  sChecksum := ansichar((checksum SHR 8) AND $FF) + 
               ansichar( checksum        AND $FF);
end;

procedure HPCompileRequest(var Dataset : TAHPdata; Didx : Integer; Query : u8; WData : u16; Test : Boolean);
var 
  sChecksum : AnsiString;
  TelegramType : ansichar;
  
begin
  if (Didx < 0) OR (Didx > Length(Dataset)-1) then exit;
  if Query = QRY_READ then WData := $8008;  
  with Dataset[Didx] do
    begin
    TelegramType := #$FA;
    if Test then TelegramType := #$0B; // loopback test
    if Test then WData := 0; // loopback test

    Request := '';
    // src 00 dst qry circ FA reg(2) data(2) chksm(2)
    // 0d  00 03  01   00  fa 00 0c  80 08    01 9f
    // 03  00 0d  02   00  fa 00 0c  00 40    01 58
    Request := ansichar(DEV_OPT_PC) + 
               #$00 + 
               ansichar(Device) + 
               ansichar(Query) + 
               ansichar(Circuit) +
               ansichar(TelegramType) + 
               ansichar((RegAddr SHR 8) AND $FF) + 
               ansichar( RegAddr        AND $FF) + 
               ansichar((WData SHR 8) AND $FF) + 
               ansichar( WData        AND $FF);

    CalcChecksum(Request, sChecksum); 
    Request := Request + sChecksum;
    end;
end;

function  HPCommunicate(var Dataset : TAHPdata; Didx : Integer) : Boolean;
var
  ok : Boolean;
  i : Integer;
  DspStr : string;
  Retry : Integer;

begin
  Result := False;
  for Retry := 1 to 3 do
    begin
    ComPortFlush(USBnaprave[Uidx]);

    ok := ComPortWrite(USBnaprave[Uidx], Dataset[Didx].Request); 
    if not ok then
      begin
      HPLastMessage := HPLastMessage + 'Error sending data. ';
      Exit;
      end;
    ComPortSetRTSsignal(USBnaprave[Uidx], False); // LED on
    wait(200);  
    ok := ComPortWaitRead(USBnaprave[Uidx], 2*12, Dataset[Didx].Response);
    if not ok then
      begin
      HPLastMessage := HPLastMessage + 'Error reading data. ';
      end;
    // even if in error, still display what was received         
    if PrintDebugMsg OR not ok then
      begin
      DspStr  := '';
      for i := 1 to Length(Dataset[Didx].Response) do 
        DspStr := DspStr + IntToHex(byte(Dataset[Didx].Response[i])) + ' ';
      HPLastMessage := HPLastMessage + DspStr + ' ';
      end;
    if ok then break;
    wait (500); 
    end;
  ComPortSetRTSsignal(USBnaprave[Uidx], True); // LED off
  Result := ok;
end;

function  HPCommRead(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
var
  addr : u16;
  data : s16;
  query : u8;
  sResponse,
  sChecksum,
  sMyChecksum : AnsiString;

begin
  Result := False;
  HPCompileRequest(Dataset, Didx, QRY_READ, 0, Test);   
  if not HPCommunicate(Dataset, Didx)
    then exit;  

  // verify  
  sResponse := copy(Dataset[Didx].Response, 13, 10); // only RX data w/o checksum
  sChecksum := copy(Dataset[Didx].Response, 23, 2);
  CalcChecksum(sResponse, sMyChecksum);
  if sChecksum <> sMyChecksum then
    begin
    HPLastMessage := HPLastMessage + 'Checksum mismatch! ';
    Exit;
    end;

// 0d 00 03 01 00 fa 00 0c 80 08 01 9f 	 03 00 0d 02 00 fa 00 0c 00 40 01 58 	'0d	'03	'01 read	'00fa	'000c zunanja temp
  
  // decode
  addr := u16((u8(Dataset[Didx].Response[19]) SHL 8) OR u8(Dataset[Didx].Response[20]));
  data := s16((u8(Dataset[Didx].Response[21]) SHL 8) OR u8(Dataset[Didx].Response[22]));
  query := u8(Dataset[Didx].Response[16]);

  if (addr = $5555) AND (data = $5555) AND (query = $55) then
    begin
    if PrintDebugMsg then
      HPLastMessage := HPLastMessage + 'Confirmation received. ';
    Result := True;
    end
  else
    begin  
    if query <> QRY_RESPONSE then
      begin
      HPLastMessage := HPLastMessage + 'Incorrect QRY in the response! ';
      Exit;
      end;
      
    if PrintDebugMsg then
      HPLastMessage := HPLastMessage + '++ addr: 0x' + IntToHex(addr) + ', data: ' + IntToStr(data) + ' ';

    Dataset[Didx].Data := u16(data);
    Dataset[Didx].DataLastRead := u16(data);
    Dataset[Didx].Value := data * Dataset[Didx].Scaling;
    Result := True;
    end;
end;

function  HPCommWrite(var Dataset : TAHPdata; Didx : Integer) : Boolean;
var
  Wdata : u16;
  sResponse,
  sChecksum,
  sMyChecksum : AnsiString;
  
begin
  Result := False;
  // select source of the value to write
  if Dataset[Didx].Value < -99999 // invalid
    then Wdata := Dataset[Didx].Data
    else Wdata := u16(s16(Round(Dataset[Didx].Value / Dataset[Didx].Scaling)));

  // do not communicate if data has not changed
  if Wdata = Dataset[Didx].DataLastRead then 
    begin
    Result := True;
    exit;
    end;
   
  HPCompileRequest(Dataset, Didx, QRY_WRITE, Wdata, False);
  if not HPCommunicate(Dataset, Didx) then exit;

  // verify response  
  sResponse := copy(Dataset[Didx].Response, 13, 10); // only RX data w/o checksum
  sChecksum := copy(Dataset[Didx].Response, 23, 2); 
  CalcChecksum(sResponse, sMyChecksum);
  if sChecksum <> sMyChecksum then
    begin
    HPLastMessage := HPLastMessage + 'Checksum mismatch! ';
    Exit;
    end;

  if sResponse <> #$55#$55#$55#$55#$55#$55#$55#$55#$55#$55 then
    begin
    HPLastMessage := HPLastMessage + 'Incorrect Write confirmation! ';
    Exit;
    end
  else
    HPLastMessage := HPLastMessage + 'Write OK. ';
    
(*
  TX	RX	source	destination	query	type	register	value	checksum	Column1	source2	destination3	query4	type5	register6	value7	checksum8
  0d 00 06 00 01 fa 00 05 00 96 01 a9 	 55 55 55 55 55 55 55 55 55 55 03 52 	'0d	'06	'00 write	'01fa	'0005 ROOM TARGET TEMP_I	'0096	'01a9		'55	'55	'55	'5555	'5555	'5555	'0352
*)  
  Result := True;
end;

initialization
begin
  PrintDebugMsg := False;
end;

end.
