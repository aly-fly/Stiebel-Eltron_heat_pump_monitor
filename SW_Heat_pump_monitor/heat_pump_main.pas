unit heat_pump_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, serial_comm, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin, Orodja,
  VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, Vcl.Grids;

const
  FN1 : string = '.\Temperatures_';

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
  
type
  TForm1 = class(TForm)
    chart1: TChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series3: TLineSeries;
    pnl1: TPanel;
    btnComSearch: TButton;
    ddPortList: TComboBox;
    btnComOpen: TButton;
    btnComClose: TButton;
    btnReadData: TButton;
    mm1: TMemo;
    tmr1: TTimer;
    cbReadConstatntly: TCheckBox;
    Chart2: TChart;
    LineSeries1: TLineSeries;
    LineSeries2: TLineSeries;
    LineSeries3: TLineSeries;
    LineSeries4: TLineSeries;
    Chart3: TChart;
    LineSeries9: TLineSeries;
    LineSeries10: TLineSeries;
    LineSeries11: TLineSeries;
    gridData: TStringGrid;
    Series4: TLineSeries;
    Series5: TLineSeries;
    Series6: TLineSeries;
    Series7: TLineSeries;
    Series8: TLineSeries;
    Series9: TLineSeries;
    Series10: TLineSeries;
    cbDebug: TCheckBox;
    grpSettings: TGroupBox;
    edC1Day: TEdit;
    cbDbgAddr: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblWater: TLabel;
    edC2Day: TEdit;
    edC1night: TEdit;
    edC2Night: TEdit;
    edWaterDay: TEdit;
    edWaterNight: TEdit;
    ddHPMode: TComboBox;
    btnSettingsRead: TButton;
    btnSettingsWrite: TButton;
    Series12: TLineSeries;
    btnLoadCharts: TButton;
    tmrScroll: TTimer;
    procedure btnComSearchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnComOpenClick(Sender: TObject);
    procedure btnComCloseClick(Sender: TObject);
    procedure btnReadDataClick(Sender: TObject);
    procedure cbReadConstatntlyClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbDebugClick(Sender: TObject);
    procedure btnSettingsReadClick(Sender: TObject);
    procedure btnSettingsWriteClick(Sender: TObject);
    procedure gridDataClick(Sender: TObject);
    procedure btnLoadChartsClick(Sender: TObject);
    procedure tmrScrollTimer(Sender: TObject);
    procedure ChartZoom(Sender: TObject);
    procedure ChartScroll(Sender: TObject);
    procedure ChartUndoZoom(Sender: TObject);
  private
    Uidx: Integer; // selected usb device index
    HPparamIdx : Integer;
    SenderChart : TObject;
    procedure SaveToFile();
    procedure CompileRequest(var Dataset : TAHPdata; Didx : Integer; Query : u8; WData : u16);
    function  Communicate(var Dataset : TAHPdata; Didx : Integer) : Boolean;
    function  CommRead(var Dataset : TAHPdata; Didx : Integer) : Boolean;
    function  CommWrite(var Dataset : TAHPdata; Didx : Integer) : Boolean;
  public
    { Public declarations }
  end;

const
  DEV_DIRECT  = $00;
  DEV_BOILER  = $03;
  DEV_ATEZ    = $05;
  DEV_CONTROL = $06;
  DEV_ROOM_S  = $08;
  DEV_MANAGER = $09;
  DEV_HEATING = $0A;
  DEV_BUS_CPL = $0B;
  DEV_MIXER   = $0C;
  DEV_OPT_PC  = $0D;
  DEV_FOREIGN = $0E;
  DEV_DCF_CLK = $0F;

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
      
var
  Form1: TForm1;
  HPdata : TAHPdata;
  HPsettings : TAHPdata;

implementation

{$R *.dfm}

procedure TForm1.btnComCloseClick(Sender: TObject);
begin
  cbReadConstatntly.Checked := False;
  ddPortList.Enabled := True;
  btnComOpen.Enabled := True;
  btnComClose.Enabled := False;
  cbReadConstatntly.Enabled := False;
  btnReadData.Enabled := False;
  btnSettingsRead.Enabled := False;
  btnSettingsWrite.Enabled := False;
  ComPortClose(USBnaprave[Uidx]);
end;

procedure TForm1.btnComOpenClick(Sender: TObject);
begin
  Uidx := ddPortList.ItemIndex;
  if not ComPortOpen (USBnaprave[Uidx]) then
    begin
    ShowMessage('Error opening device.');
    Exit;
    end;
  USBnaprave[Uidx].Baudrate := 2400;
  USBnaprave[Uidx].StopBits := TWOSTOPBITS;
  USBnaprave[Uidx].Parity := EVENPARITY; //   NOPARITY ODDPARITY EVENPARITY MARKPARITY SPACEPARITY    

  if not ComPortSetBaudRate (USBnaprave[Uidx]) then
    begin
    ShowMessage('Error configuring device.');
    Exit;
    end;
  ddPortList.Enabled := False;
  btnComOpen.Enabled := False;
  btnComClose.Enabled := True;
  cbReadConstatntly.Enabled := True;
  btnReadData.Enabled := True;
  btnSettingsRead.Enabled := True;
  btnSettingsWrite.Enabled := True;
  mm1.Clear;

  // 0d 00 0d 01 00 0b 00 00 00 00 00 26 	 55 55 55 55 55 55 55 55 55 55 03 52  '0d PC	'0d PC	'01 Read	'000b	'0000	'0000	'0026
  // check connection
  if CommRead(HPsettings, 0) then
    begin
    mm1.Lines.Add('Loopback Check 1 OK.');
    end
  else
    begin
    mm1.Lines.Add('Loopback Check 1 fail!');
    end;
    
  if copy(HPsettings[0].Response, 13, 10) = #$55#$55#$55#$55#$55#$55#$55#$55#$55#$55 then
    begin
    mm1.Lines.Add('Loopback Check 2 OK.');
    end
  else
    begin
    mm1.Lines.Add('Loopback Check 2 fail!');
    end;
end;

procedure TForm1.btnComSearchClick(Sender: TObject);
var
  i : Integer;
begin
  IsciCOMporteVregistru;
  ddPortList.Clear;
  for i := 0 to Length(USBnaprave)-1 do
    begin
    ddPortList.Items.Add(USBnaprave[i].Vrednost + ' (' + USBnaprave[i].Ime + ')');
    end;
  if ddPortList.Items.Count > 0 
    then ddPortList.ItemIndex := ddPortList.Items.Count-1 // last
    else ddPortList.ItemIndex := -1;
    
    
end;

procedure TForm1.btnLoadChartsClick(Sender: TObject);
var
  FN2 : string;
  F: TextFile;
  T : TDateTime;
  Header, Line : string;
  LineNum, param : Integer;
  DateFormat : TFormatSettings;
  SL : TStringList;
  ss : string;
  tt : TDateTime;
  vv : Double;
  
begin
  if cbDebug.Checked then
    mm1.Lines.Add('Loading file...');

  for param := 0 to chart1.SeriesCount-1 do
    chart1.Series[param].Clear; 
  for param := 0 to chart2.SeriesCount-1 do
    chart2.Series[param].Clear; 
  for param := 0 to chart3.SeriesCount-1 do
    chart3.Series[param].Clear; 
    
  T := now();
  DateFormat.DateSeparator := '-';
  DateFormat.TimeSeparator := '-';
  DateFormat.ShortDateFormat := 'YYYYMMDD';
  DateFormat.LongDateFormat  := 'YYYYMMDD';

  FN2 := FN1 + DateTimeToStr(T, DateFormat) + '.csv';
  FN2 := TrimSp(FN2);

  if not FileExists(FN2) then
    begin
    mm1.Lines.Add('File doesn''t exist: ' + FN2);
    Exit;
    end;

  SL := TStringList.Create;
  
  AssignFile(F, FN2);
  Reset(F);
  LineNum := 1;
  Readln(F, Header);
  while not Eof(F) do
    begin
    inc(LineNum);
    Readln(F, Line);
    DivideString(Line, ';', SL);
    if SL.Count-2 <> Length(HPdata) then
      begin
      mm1.Lines.Add('Data size mismatch on line ' + IntToStr(LineNum));
      SL.Destroy;
      CloseFile(F);
      exit;
      end;
    // get date and time
    ss := SL.Strings[0];
    tt := StrToDateTimeDef(ss, 0);
    if tt = 0 then
      begin
      mm1.Lines.Add('Incorrect DateTime on line ' + IntToStr(LineNum) + ': ' + ss);
      SL.Destroy;
      CloseFile(F);
      exit;
      end;

    for param := 0 to SL.Count-3 do
      begin
      ss := SL.Strings[param+1];     
      vv := StrToFloatDef(ss, -10000);
      if vv < -999 then
        begin
        mm1.Lines.Add('Incorrect value on line ' + IntToStr(LineNum) + ': "' + ss + '"');
        SL.Destroy;
        CloseFile(F);
        exit;
        end;
      if HPdata[param].series <> nil then
        HPdata[param].series.AddXY(tt, vv);      
      end;    
    end;
  
  SL.Destroy;
  CloseFile(F);
end;

procedure TForm1.btnReadDataClick(Sender: TObject);
var
  sValue, sDbg : string;
  T, Told : TDateTime;
  
begin
  // highlight currently read parameter
  gridData.Col := 1;
  gridData.Row := HPparamIdx;
  
  if not CommRead(HPdata, HPparamIdx) then exit;
      
  T := now();

  if HPdata[HPparamIdx].Series <> nil then
    HPdata[HPparamIdx].Series.AddXY(T, HPdata[HPparamIdx].Value);
  // delete data older from 24 hrs
  Told := HPdata[HPparamIdx].Series.XValue[0];
  if (HPdata[HPparamIdx].Series.XValues.Count > 50) AND ((T - Told) > 24) then
    begin
    HPdata[HPparamIdx].Series.Delete(0);
    end;
        
  sValue := FloatToStrF(HPdata[HPparamIdx].Value, ffFixed, 5, 1) + HPdata[HPparamIdx].Units;
  gridData.Cells[1,HPparamIdx] := sValue;
  sDbg := HPdata[HPparamIdx].Name + ': ' + sValue; 

  if cbDebug.Checked then
    mm1.Lines.Add(sDbg);  
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if btnComClose.Enabled then btnComCloseClick(nil);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  SetLength(HPdata, 0);
  SetLength(HPsettings, 0);
end;

procedure TForm1.cbDebugClick(Sender: TObject);
begin
  if cbDebug.Checked
  then
    begin
    gridData.Height := 300;
    mm1.Height := 321;
    end
  else
    begin
    gridData.Height := 300+150;
    mm1.Height := 321-150;
    mm1.Clear;
    end;

  mm1.Top := gridData.Top + gridData.Height + 6;   
end;

procedure TForm1.cbReadConstatntlyClick(Sender: TObject);
begin
  tmr1.Enabled := (cbReadConstatntly.Checked AND NOT btnComOpen.Enabled);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  btnComSearchClick(nil);
  cbDebugClick(nil);
end;

procedure TForm1.gridDataClick(Sender: TObject);
begin
  HPparamIdx := gridData.Row;
  if cbDebug.Checked then
    mm1.Lines.Add('Next parameter to read: ' + IntToStr(HPparamIdx) + ' ('+HPdata[HPparamIdx].Name+')');
end;

procedure TForm1.tmr1Timer(Sender: TObject);
begin
  btnReadDataClick(nil);

  if HPparamIdx = Length(HPdata)-1
    then 
      begin
      HPparamIdx := 0;
      SaveToFile();
      //btnSettingsReadClick(nil);
      end
    else inc(HPparamIdx);
end;

procedure TForm1.tmrScrollTimer(Sender: TObject);
begin
  tmrScroll.Enabled := False;
  ChartZoom(SenderChart);
end;

procedure TForm1.SaveToFile();
var
  FN2 : string;
  F: TextFile;
  T : TDateTime;
  Header, Line : string;
  i : Integer;
  DateFormat : TFormatSettings;
  
begin
  if cbDebug.Checked then
    mm1.Lines.Add('Writting file...');
  T := now();

  Line := DateTimeToStr(T) + ';';
  for i := 0 to Length(HPdata)-1 do
    begin
    Line := Line + FloatToStrF(HPdata[i].Value, ffFixed, 5, 2) + ';';
    end;    

  DateFormat.DateSeparator := '-';
  DateFormat.TimeSeparator := '-';
  DateFormat.ShortDateFormat := 'YYYYMMDD';
  DateFormat.LongDateFormat  := 'YYYYMMDD';

  FN2 := FN1 + DateTimeToStr(T, DateFormat) + '.csv';
  FN2 := TrimSp(FN2);
  
  AssignFile(F, FN2);
  if not FileExists(FN2) 
  then
    begin
    Rewrite(F);

    Header := DateTimeToStr(T) + ';';
    for i := 0 to Length(HPdata)-1 do
      begin
      Header := Header + HPdata[i].Name + ';';
      end;    
    Writeln(F, Header);    
    Writeln(F, Line);    
    end
  else
    begin
    Append(F);
    Writeln(F, Line);    
    end; 
  CloseFile(F);
end;


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

procedure TForm1.CompileRequest(var Dataset : TAHPdata; Didx : Integer; Query : u8; WData : u16);
var 
  sChecksum : AnsiString;
  TelegramType : ansichar;
  
begin
  if (Didx < 0) OR (Didx > Length(Dataset)-1) then exit;
  if Query = QRY_READ then WData := $8008;  
  with Dataset[Didx] do
    begin
    TelegramType := #$FA;
    if Device = DEV_OPT_PC then TelegramType := #$0B; // loopback test
    if Device = DEV_OPT_PC then WData := 0; // loopback test

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

function  TForm1.Communicate(var Dataset : TAHPdata; Didx : Integer) : Boolean;
var
  ok : Boolean;
  i : Integer;
  DspStr : string;

begin
  Result := False;
  ComPortFlush(USBnaprave[Uidx]);

  ok := ComPortWrite(USBnaprave[Uidx], Dataset[Didx].Request); 
  if not ok then
    begin
    mm1.Lines.Add('Error sending data.');
    Exit;
    end;
  wait(200);  
  ok := ComPortWaitRead(USBnaprave[Uidx], 2*12, Dataset[Didx].Response);
  if not ok then
    begin
    mm1.Lines.Add('Error reading data.');
    end;
  // even if in error, still display what was received         
  if cbDebug.Checked OR not ok then
    begin
    DspStr  := '';
    for i := 1 to Length(Dataset[Didx].Response) do 
      DspStr := DspStr + IntToHex(byte(Dataset[Didx].Response[i])) + ' ';
    mm1.Lines.Add(DspStr);
    end;
  Result := ok;
end;

procedure TForm1.ChartScroll(Sender: TObject);
begin
  // mm1.Lines.Add('scroll');
  SenderChart := Sender;
  tmrScroll.Enabled := true;
end;

procedure TForm1.ChartUndoZoom(Sender: TObject);
begin
  // mm1.Lines.Add('un zoom');
  chart1.BottomAxis.Automatic := True;
  chart2.BottomAxis.Automatic := True;
  chart3.BottomAxis.Automatic := True;
end;

procedure TForm1.ChartZoom(Sender: TObject);
var
  minn, maxx : Double;
  CH : Tchart;
begin
  // mm1.Lines.Add('zoom');
  if not(Sender is TChart) then exit;
  CH := TChart(Sender);
  if CH.Series[0].Count < 5 then exit; // do not zoom if chart is (almost) empty
  
  chart1.BottomAxis.Automatic := False;
  chart2.BottomAxis.Automatic := False;
  chart3.BottomAxis.Automatic := False;

  minn := CH.BottomAxis.Minimum;
  maxx := CH.BottomAxis.Maximum;
  chart1.BottomAxis.Minimum := minn;
  chart2.BottomAxis.Minimum := minn;
  chart3.BottomAxis.Minimum := minn;
  
  chart1.BottomAxis.Maximum := maxx;
  chart2.BottomAxis.Maximum := maxx;
  chart3.BottomAxis.Maximum := maxx;
end;

function  TForm1.CommRead(var Dataset : TAHPdata; Didx : Integer) : Boolean;
var
  addr : u16;
  data : s16;
  query : u8;
  sResponse,
  sChecksum,
  sMyChecksum : AnsiString;

begin
  Result := False;
  CompileRequest(Dataset, Didx, QRY_READ, 0);   
  if not Communicate(Dataset, Didx)
    then exit;  

  // verify  
  sResponse := copy(Dataset[Didx].Response, 13, 10); // only RX data w/o checksum
  sChecksum := copy(Dataset[Didx].Response, 23, 2);
  CalcChecksum(sResponse, sMyChecksum);
  if sChecksum <> sMyChecksum then
    begin
    mm1.Lines.Add('Checksum mismatch!');
    Exit;
    end;

// 0d 00 03 01 00 fa 00 0c 80 08 01 9f 	 03 00 0d 02 00 fa 00 0c 00 40 01 58 	'0d	'03	'01 read	'00fa	'000c zunanja temp
  
  // decode
  addr := u16((u8(Dataset[Didx].Response[19]) SHL 8) OR u8(Dataset[Didx].Response[20]));
  data := s16((u8(Dataset[Didx].Response[21]) SHL 8) OR u8(Dataset[Didx].Response[22]));
  query := u8(Dataset[Didx].Response[16]);

  if (addr = $5555) AND (data = $5555) AND (query = $55) then
    begin
    if cbDbgAddr.Checked then
      mm1.Lines.Add('Confirmation received.');
    Result := True;
    end
  else
    begin  
    if query <> QRY_RESPONSE then
      begin
      mm1.Lines.Add('Incorrect QRY in the response!');
      Exit;
      end;
      
    if cbDbgAddr.Checked then
      mm1.Lines.Add('++ addr: 0x' + IntToHex(addr) + ', data: ' + IntToStr(data));

    Dataset[Didx].Data := u16(data);
    Dataset[Didx].DataLastRead := u16(data);
    Dataset[Didx].Value := data * Dataset[Didx].Scaling;
    Result := True;
    end;
end;

function  TForm1.CommWrite(var Dataset : TAHPdata; Didx : Integer) : Boolean;
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
   
  CompileRequest(Dataset, Didx, QRY_WRITE, Wdata);
  if not Communicate(Dataset, Didx) then exit;

  // verify response  
  sResponse := copy(Dataset[Didx].Response, 13, 10); // only RX data w/o checksum
  sChecksum := copy(Dataset[Didx].Response, 23, 2); 
  CalcChecksum(sResponse, sMyChecksum);
  if sChecksum <> sMyChecksum then
    begin
    mm1.Lines.Add('Checksum mismatch!');
    Exit;
    end;

  if sResponse <> #$55#$55#$55#$55#$55#$55#$55#$55#$55#$55 then
    begin
    mm1.Lines.Add('Incorrect Write confirmation!');
    Exit;
    end
  else
    mm1.Lines.Add('Write OK.');
    
(*
  TX	RX	source	destination	query	type	register	value	checksum	Column1	source2	destination3	query4	type5	register6	value7	checksum8
  0d 00 06 00 01 fa 00 05 00 96 01 a9 	 55 55 55 55 55 55 55 55 55 55 03 52 	'0d	'06	'00 write	'01fa	'0005 ROOM TARGET TEMP_I	'0096	'01a9		'55	'55	'55	'5555	'5555	'5555	'0352
*)  
  Result := True;
end;

procedure TForm1.btnSettingsReadClick(Sender: TObject);
label error;
begin
  Screen.Cursor := crHourGlass;
  btnReadData.Enabled := False;
  
  // loopback test
  if not CommRead(HPsettings, 0) then goto error;

(*standby 256     0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 01 00 01 20 
  automatic 512   0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 02 00 01 21 
  day 768         0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 03 00 01 22 
  night 1024      0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 04 00 01 23 
  water  1280     0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 05 00 01 24 
  emergency 0     0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 00 00 01 1F  *)
  
  // op mode
  if not CommRead(HPsettings, 1) then goto error;
  case HPsettings[1].Data of
    $0100 : ddHPMode.ItemIndex := 0; // standby
    $0200 : ddHPMode.ItemIndex := 1; // automatic
    $0300 : ddHPMode.ItemIndex := 2; // day
    $0400 : ddHPMode.ItemIndex := 3; // night
    $0500 : ddHPMode.ItemIndex := 4; // water only
    $0000 : ddHPMode.ItemIndex := 5; // emergency
    else
      begin
      ddHPMode.ItemIndex := -1;
      mm1.Lines.Add('Unknown op mode: 0x' + IntToHex(HPsettings[1].Data));
      end;    
  end;
  
  if not CommRead(HPsettings, 2) then goto error;
  edC1Day.Text := FloatToStrF(HPsettings[2].Value, ffFixed, 5, 1);

  if not CommRead(HPsettings, 3) then goto error;
  edC1night.Text := FloatToStrF(HPsettings[3].Value, ffFixed, 5, 1);

  if not CommRead(HPsettings, 4) then goto error;
  edC2Day.Text := FloatToStrF(HPsettings[4].Value, ffFixed, 5, 1);

  if not CommRead(HPsettings, 5) then goto error;
  edC2Night.Text := FloatToStrF(HPsettings[5].Value, ffFixed, 5, 1);

  if not CommRead(HPsettings, 6) then goto error;
  edWaterDay.Text := FloatToStrF(HPsettings[6].Value, ffFixed, 5, 1);

  if not CommRead(HPsettings, 7) then goto error;
  edWaterNight.Text := FloatToStrF(HPsettings[7].Value, ffFixed, 5, 1);
  
error:
  Screen.Cursor := crDefault;
  btnReadData.Enabled := True;
end;

procedure TForm1.btnSettingsWriteClick(Sender: TObject);

    function WriteStr (txt : string; Didx : Integer) : Boolean;
    var
      vv : Double;
    begin  
    Result := True; // false only on comm error
      vv := StrToFloatDef(txt, -100);
      if vv > -100 then
        begin
        HPsettings[Didx].Value := vv;
        Result := CommWrite(HPsettings, Didx);
        end
      else
        begin  
        mm1.Lines.Add('Wrong data: "'+txt+'"');
        end;
    end;
  
begin
  // loopback test
  if not CommRead(HPsettings, 0) then exit;

  // op mode
  case ddHPMode.ItemIndex of
    0: HPsettings[1].Data := $0100; // standby
    1: HPsettings[1].Data := $0200; // automatic
    2: HPsettings[1].Data := $0300; // day
    3: HPsettings[1].Data := $0400; // night
    4: HPsettings[1].Data := $0500; // water only
    5: HPsettings[1].Data := $0000; // emergency
  end;
  
  HPsettings[1].Value := -999999; // use Data variable to write value
  if not CommWrite(HPsettings, 1) then exit;

  if not WriteStr(edC1Day.Text, 2) then exit;
  if not WriteStr(edC1night.Text, 3) then exit;
  if not WriteStr(edC2Day.Text, 4) then exit;
  if not WriteStr(edC2Night.Text, 5) then exit;
  if not WriteStr(edWaterDay.Text, 6) then exit;
  if not WriteStr(edWaterNight.Text, 7) then exit;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i : Integer;
  
begin
  SenderChart := nil;
  SetLength(HPdata, 17);
  i := 0;

// 0d 00 03 01 00 fa 00 0c 80 08 01 9f 	 03 00 0d 02 00 fa 00 0c 00 40 01 58 	'0d	'03	'01 read	'00fa	'000c zunanja temp
  HPdata[i].Name    := 'Outdoor';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$0c#$80#$08#$01#$9f;   
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $000c;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  := Series1;
  inc(i);
  
    // 0d 00 06 01 01 fa 00 11 00 d0 01 f0 	 06 01 0d 02 00 fa 00 11 00 d0 01 f1 	'0d	'06	'01 read	'01fa	'0011 ROOM TEMP	'00d0	'01f0		'06	'0d	'02	'00fa	'0011 ROOM TEMP	'00d0	'01f1	00d0	208	208	20,8
  HPdata[i].Name    := 'Room';
  HPdata[i].Request := #$0d#$00#$06#$01#$01#$fa#$00#$11#$00#$d0#$01#$f0;
  HPdata[i].Device  := DEV_CONTROL;
  HPdata[i].Circuit := CIRC_HC1;
  HPdata[i].RegAddr := $0011;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  Series2;
  inc(i);

  // 0d 00 06 01 01 fa 00 05 00 e6 01 fa 	 06 01 0d 02 00 fa 00 05 00 e6 01 fb 	'0d	'06	'01 read	'01fa	'0005 ROOM TARGET TEMP_I	'00e6	'01fa		'06	'0d	'02	'00fa	'0005 ROOM TARGET TEMP_I	'00e6	'01fb	00e6	230	230	23	
  HPdata[i].Name    := 'Room set Day';
  HPdata[i].Request := #$0d#$00#$06#$01#$01#$fa#$00#$05#$00#$e6#$01#$fa;
  HPdata[i].Device  := DEV_CONTROL;
  HPdata[i].Circuit := CIRC_HC1;
  HPdata[i].RegAddr := $0005;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  Series3;
  inc(i);
  
    // 0d 00 03 01 00 fa 00 0e 01 5b 01 75 	 03 00 0d 02 00 fa 00 0e 01 5a 01 75 	'0d	'03	'01 read	'00fa	'000e STORAGE TEMP	'015b	'0175		'03	'0d	'02	'00fa	'000e STORAGE TEMP	'015a	'0175	015a	346	346	34,6
  HPdata[i].Name    := 'Hot water';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$0e#$01#$5b#$01#$75;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $000e;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  LineSeries9;
  inc(i);
  
    // 0d 00 03 01 00 fa 00 03 80 08 01 96 	 03 00 0d 02 00 fa 00 03 01 54 01 64 	'0d	'03	'01 read	'00fa	'0003 STORAGE SET TEMP	'8008	'0196		'03	'0d	'02	'00fa	'0003 STORAGE SET TEMP	'0154	'0164	0154	340	340	34
  HPdata[i].Name    := 'Hot water set';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$03#$80#$08#$01#$96;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0003;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  LineSeries10;
  inc(i);

    // 0d 00 03 01 00 fa 00 16 80 08 01 a9 	 03 00 0d 02 00 fa 00 16 01 b6 01 d9 	'0d	'03	'01 read	'00fa	'0016 RETURN ACTUAL TEMP	'8008	'01a9		'03	'0d	'02	'00fa	'0016 RETURN ACTUAL TEMP	'01b6	'01d9	01b6	438	438	43,8
  HPdata[i].Name    := 'Heating 1';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$16#$80#$08#$01#$a9;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0016;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  LineSeries1;
  inc(i);
  
  HPdata[i].Name    := 'Heating 1 set';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$01#$d5#$80#$08#$02#$69;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $01d5;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  LineSeries2;
  inc(i);

    // 0d 00 03 01 00 fa 00 0f 80 08 01 a2 	 03 00 0d 02 00 fa 00 0f 01 5d 01 79 	'0d	'03	'01 read	'00fa	'000f FLOW TEMP	'8008	'01a2		'03	'0d	'02	'00fa	'000f FLOW TEMP	'015d	'0179	015d	349	349	34,9
  HPdata[i].Name    := 'Heating 2 (mixer)';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$0f#$80#$08#$01#$a2;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $000f;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  LineSeries3;
  inc(i);
  
    // 0d 00 03 01 00 fa 00 04 01 5e 01 6e 	 03 00 0d 02 00 fa 00 04 01 5e 01 6f 	'0d	'03	'01 read	'00fa	'0004 TARGET FLOW TEMP	'015e	'016e		'03	'0d	'02	'00fa	'0004 TARGET FLOW TEMP	'015e	'016f	015e	350	350	35
  HPdata[i].Name    := 'Heating 2 set';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$04#$01#$5e#$01#$6e;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0004;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  LineSeries4;
  inc(i);
  
    // 0d 00 03 01 00 fa 01 d6 80 08 02 6a 	 03 00 0d 02 00 fa 01 d6 01 bd 02 a1 	'0d	'03	'01 read	'00fa	'01d6 WP PRELIMINARY LIST	'8008	'026a		'03	'0d	'02	'00fa	'01d6 WP PRELIMINARY LIST	'01bd	'02a1	01bd	445	445	44,5
  HPdata[i].Name    := 'Actual flow';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$01#$d6#$80#$08#$02#$6a;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $01d6;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  Series4;
  inc(i);

  HPdata[i].Name    := 'Buffer set';
  HPdata[i].Request := '';
  HPdata[i].Device  := DEV_CONTROL;
  HPdata[i].Circuit := CIRC_HC1;
  HPdata[i].RegAddr := $0004;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  := Series12;
  inc(i);

//======================================================================================================================

  HPdata[i].Name    := '0052 BURNER';
  HPdata[i].Request := #$0d#$00#$0c#$01#$02#$fa#$00#$52#$00#$00#$01#$68;
  HPdata[i].Device  := DEV_MIXER;
  HPdata[i].Circuit := CIRC_HC2;
  HPdata[i].RegAddr := $0052;
  HPdata[i].Scaling := 1/256 * 1.0;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series5;
  inc(i);

  HPdata[i].Name    := 'Pump hot water';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$53#$00#$00#$01#$5e;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0053;
  HPdata[i].Scaling := 1/256 * 1.05;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series6;
  inc(i);

  HPdata[i].Name    := 'Pump heating';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$63#$00#$00#$01#$6e;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0063;
  HPdata[i].Scaling := 1/256 * 1.10;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series7;
  inc(i);

  HPdata[i].Name    := '0064 COLLECTOR_PUMP';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$64#$00#$00#$01#$6f;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0064;
  HPdata[i].Scaling := 1/256 * 1.15;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series8;
  inc(i);

  HPdata[i].Name    := 'fdac PUMP MIXER?';
  HPdata[i].Request := #$0d#$00#$09#$01#$00#$fa#$fd#$ac#$00#$00#$02#$ba;
  HPdata[i].Device  := DEV_MANAGER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $fdac;
  HPdata[i].Scaling := 1/512 * 1.20;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series9;
  inc(i);

  HPdata[i].Name    := 'fdbf RELEASE_2WE';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$fd#$bf#$01#$00#$02#$c8;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $fdbf;
  HPdata[i].Scaling := 1/256 * 1.25;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series10;
  inc(i);


  gridData.RowCount := Length(HPdata);
  gridData.ColWidths[0] := 200;
  gridData.ColWidths[1] := 200;

  for i := 0 to Length(HPdata)-1 do
    begin
    if HPdata[i].Series <> nil then
      HPdata[i].Series.Title := HPdata[i].Name;  
    gridData.Cells[0,i] := HPdata[i].Name;
    end;
  HPparamIdx := 0;  

// ===================================================================================================================  
(*
  src := Copy(S,  1, 2);  
  dst := Copy(S,  5, 2);
  qry := Copy(S,  7, 2);
  cir := Copy(S,  9, 4);
  reg := Copy(S, 13, 4);
  bbb := Copy(S, 17, 4);
  csm := Copy(S, 21, 4);
*)  

  SetLength(HPsettings, 8);
  i := 0;

  // 0d 00 0d 01 00 0b 00 00 00 00 00 26 	 55 55 55 55 55 55 55 55 55 55 03 52  '0d PC	'0d PC	'01 Read	'000b	'0000	'0000	'0026
  //0 : TXD := #$0d#$00#$0d#$01#$00#$0b#$00#$00#$00#$00#$00#$26;

  HPsettings[i].Name    := 'Loopback test';
  HPsettings[i].Request := #$0d#$00#$0d#$01#$00#$0b#$00#$00#$00#$00#$00#$26;   
  HPsettings[i].Device  := DEV_OPT_PC;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := 0;
  HPsettings[i].Scaling := 1;
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);

(* set mode automatic
  0d 00 03 00 00 fa 01 12 02 00 01 1f 	 55 55 55 55 55 55 55 55 55 55 03 52 	'0d	'03	'00 write	'00fa	'0112 PROGRAM SWITCH	'0200	'011f		'55	'55	'55	'5555	'5555	'5555	'0352
   set mode Night - setback
  0d 00 03 00 00 fa 01 12 04 00 01 21 	 55 55 55 55 55 55 55 55 55 55 03 52 	'0d	'03	'00 write	'00fa	'0112 PROGRAM SWITCH	'0400	'0121		'55	'55	'55	'5555	'5555	'5555	'0352
   set mode standby
  0d 00 03 00 00 fa 01 12 01 00 01 1e 	 55 55 55 55 55 55 55 55 55 55 03 52 	'0d	'03	'00 write	'00fa	'0112 PROGRAM SWITCH	'0100	'011e		'55	'55	'55	'5555	'5555	'5555	'0352
*)
  HPsettings[i].Name    := 'Operational Mode';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $0112;
  HPsettings[i].Scaling := 1;
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);

(* set day temp 15 deg  
  TX	RX	source	destination	query	type	register	value	checksum	Column1	source2	destination3	query4	type5	register6	value7	checksum8
  0d 00 06 00 01 fa 00 05 00 96 01 a9 	 55 55 55 55 55 55 55 55 55 55 03 52 	'0d	'06	'00 write	'01fa	'0005 ROOM TARGET TEMP_I	'0096	'01a9		'55	'55	'55	'5555	'5555	'5555	'0352
*)
  HPsettings[i].Name    := 'Heating circ 1 Day';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_CONTROL;
  HPsettings[i].Circuit := CIRC_HC1;
  HPsettings[i].RegAddr := $0005;
  HPsettings[i].Scaling := 0.1;
  HPsettings[i].Units   := ' °C';
  HPsettings[i].Series  := nil;
  inc(i);

(* set night temp 21,5 C
  0d 00 06 00 01 fa 00 08 00 d7 01 ed 	 55 55 55 55 55 55 55 55 55 55 03 52 	'0d	'06	'00 write	'01fa	'0008 ROOM TARGET TEMP_NIGHT	'00d7	'01ed		'55	'55	'55	'5555	'5555	'5555	'0352
*)
  HPsettings[i].Name    := 'Heating circ 1 Night';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_CONTROL;
  HPsettings[i].Circuit := CIRC_HC1;
  HPsettings[i].RegAddr := $0008;
  HPsettings[i].Scaling := 0.1;
  HPsettings[i].Units   := ' °C';
  HPsettings[i].Series  := nil;
  inc(i);

  HPsettings[i].Name    := 'Heating circ 2 Day';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_CONTROL;
  HPsettings[i].Circuit := CIRC_HC2;
  HPsettings[i].RegAddr := $0005;
  HPsettings[i].Scaling := 0.1;
  HPsettings[i].Units   := ' °C';
  HPsettings[i].Series  := nil;
  inc(i);
  
  HPsettings[i].Name    := 'Heating circ 2 Night';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_CONTROL;
  HPsettings[i].Circuit := CIRC_HC2;
  HPsettings[i].RegAddr := $0008;
  HPsettings[i].Scaling := 0.1;
  HPsettings[i].Units   := ' °C';
  HPsettings[i].Series  := nil;
  inc(i);

  HPsettings[i].Name    := 'Hot water set Day';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $0013;
  HPsettings[i].Scaling := 0.1;
  HPsettings[i].Units   := ' °C';
  HPsettings[i].Series  :=  nil;
  inc(i);
  
  HPsettings[i].Name    := 'Hot water set Night';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $0a06;
  HPsettings[i].Scaling := 0.1;
  HPsettings[i].Units   := ' °C';
  HPsettings[i].Series  :=  nil;
  inc(i);
  
end;

end.
