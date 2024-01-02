unit heat_pump_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin, Orodja, serial_comm,
  VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, Vcl.Grids, window_test, window_energy, heat_pump_comm;

const
  FN1 : string = '.\Temperatures_';
  
type
  TFormHPmonitor = class(TForm)
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
    timerAutoRead: TTimer;
    cbReadConstatntly: TCheckBox;
    Chart2: TChart;
    LineSeries1: TLineSeries;
    LineSeries2: TLineSeries;
    LineSeries3: TLineSeries;
    LineSeries4: TLineSeries;
    Chart3: TChart;
    LineSeries9: TLineSeries;
    LineSeries10: TLineSeries;
    gridData: TStringGrid;
    Series4: TLineSeries;
    Series5: TLineSeries;
    Series6: TLineSeries;
    Series7: TLineSeries;
    Series8: TLineSeries;
    Series9: TLineSeries;
    cbDebug: TCheckBox;
    grpSettings: TGroupBox;
    edC1Day: TEdit;
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
    btnLoadCharts: TButton;
    tmrScroll: TTimer;
    btnTest: TButton;
    btnShowEnergy: TButton;
    Series11: TLineSeries;
    Series13: TLineSeries;
    Series14: TLineSeries;
    Series15: TLineSeries;
    Series16: TLineSeries;
    edPartyHrs: TEdit;
    Label5: TLabel;
    lblCurrTime: TLabel;
    procedure btnComSearchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnComOpenClick(Sender: TObject);
    procedure btnComCloseClick(Sender: TObject);
    procedure btnReadDataClick(Sender: TObject);
    procedure cbReadConstatntlyClick(Sender: TObject);
    procedure timerAutoReadTimer(Sender: TObject);
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
    procedure btnTestClick(Sender: TObject);
    procedure btnShowEnergyClick(Sender: TObject);
  private
    HPparamIdx : Integer;
    SenderChart : TObject;
    procedure SaveToFile();
    function  HPCommReadLog(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
    function  HPCommWriteLog(var Dataset : TAHPdata; Didx : Integer) : Boolean;    
  public
    // ...
  end;

      
var
  FormHPmonitor: TFormHPmonitor;
  HPdata : TAHPdata;
  HPsettings : TAHPdata;

procedure StartAutoRead();
procedure StopAutoRead();

implementation

{$R *.dfm}

function  TFormHPmonitor.HPCommReadLog(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
begin
  HPLastMessage := '';
  Result := HPCommRead(Dataset, Didx, Test);
  if HPLastMessage <> '' then mm1.Lines.Add(HPLastMessage);  
end;

function  TFormHPmonitor.HPCommWriteLog(var Dataset : TAHPdata; Didx : Integer) : Boolean;
begin
  HPLastMessage := '';
  Result := HPCommWrite(Dataset, Didx);
  if HPLastMessage <> '' then mm1.Lines.Add(HPLastMessage);  
end;

procedure TFormHPmonitor.btnComCloseClick(Sender: TObject);
begin
  cbReadConstatntly.Checked := False;
  ddPortList.Enabled := True;
  btnComOpen.Enabled := True;
  btnComClose.Enabled := False;
  cbReadConstatntly.Enabled := False;
  btnReadData.Enabled := False;
  btnSettingsRead.Enabled := False;
  btnSettingsWrite.Enabled := False;
  btnTest.Enabled := False;
  ComPortClose(USBnaprave[Uidx]);
end;

procedure TFormHPmonitor.btnComOpenClick(Sender: TObject);
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
  btnTest.Enabled := True;
  mm1.Clear;

  // 0d 00 0d 01 00 0b 00 00 00 00 00 26 	 55 55 55 55 55 55 55 55 55 55 03 52  '0d PC	'0d PC	'01 Read	'000b	'0000	'0000	'0026
  // check connection
  if HPCommReadLog(HPsettings, 0, True) 
    then mm1.Lines.Add('Loopback Check 1 (TX/RX function) OK.')
    else mm1.Lines.Add('Loopback Check 1 (TX/RX function) fail!');
    
  if copy(HPsettings[0].Response, 1, 12) = HPsettings[0].Request 
    then mm1.Lines.Add('Loopback Check 2 (IR echo) OK.')
    else mm1.Lines.Add('Loopback Check 2 (IR echo) fail!');

  if copy(HPsettings[0].Response, 13, 10) = #$55#$55#$55#$55#$55#$55#$55#$55#$55#$55 
    then mm1.Lines.Add('Loopback Check 3 (response 0x55) OK.')
    else mm1.Lines.Add('Loopback Check 3 (response 0x55) fail!');
end;

procedure TFormHPmonitor.btnComSearchClick(Sender: TObject);
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

procedure TFormHPmonitor.btnLoadChartsClick(Sender: TObject);
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

procedure TFormHPmonitor.btnReadDataClick(Sender: TObject);
var
  sValue, sDbg : string;
  T, Told : TDateTime;
  
begin
  // highlight currently read parameter
  gridData.Col := 1;
  gridData.Row := HPparamIdx;
  
  if not HPCommReadLog(HPdata, HPparamIdx, False) then exit;
      
  T := now();

  if HPdata[HPparamIdx].Series <> nil then
    begin
    HPdata[HPparamIdx].Series.AddXY(T, HPdata[HPparamIdx].Value);
    // delete data older from 23 hrs (The fractional part of a TDateTime value is the time of day.)
    Told := HPdata[HPparamIdx].Series.XValue[0];
    if (HPdata[HPparamIdx].Series.XValues.Count > 50) AND ((T - Told) > 0.96) then
      begin
      HPdata[HPparamIdx].Series.Delete(0);
      end;
    end;
        
  sValue := FloatToStrF(HPdata[HPparamIdx].Value, ffFixed, 5, 2) + HPdata[HPparamIdx].Units;
  gridData.Cells[1,HPparamIdx] := sValue;
  sDbg := HPdata[HPparamIdx].Name + ': ' + sValue; 

  if cbDebug.Checked then
    mm1.Lines.Add(sDbg);  
end;

procedure TFormHPmonitor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if btnComClose.Enabled then btnComCloseClick(nil);
end;


procedure TFormHPmonitor.FormDestroy(Sender: TObject);
begin
  SetLength(HPdata, 0);
  SetLength(HPsettings, 0);
end;

procedure TFormHPmonitor.cbDebugClick(Sender: TObject);
begin
  PrintDebugMsg := cbDebug.Checked;
  if cbDebug.Checked
  then
    begin
    gridData.Height := 557-200;
    mm1.Height := 100+200;
    end
  else
    begin
    gridData.Height := 557;
    mm1.Height := 100;
    mm1.Clear;
    end;

  mm1.Top := gridData.Top + gridData.Height + 6;   
end;

procedure TFormHPmonitor.cbReadConstatntlyClick(Sender: TObject);
begin
  StartAutoRead();
end;

procedure TFormHPmonitor.FormShow(Sender: TObject);
begin
  btnComSearchClick(nil);
  cbDebug.Checked := PrintDebugMsg;
  cbDebugClick(nil);
end;

procedure TFormHPmonitor.gridDataClick(Sender: TObject);
begin
  HPparamIdx := gridData.Row;
  if cbDebug.Checked then
    mm1.Lines.Add('Next parameter to read: ' + IntToStr(HPparamIdx) + ' ('+HPdata[HPparamIdx].Name+')');
end;

procedure TFormHPmonitor.timerAutoReadTimer(Sender: TObject);
begin
  btnReadDataClick(nil);

  // go to next parameter
  if HPparamIdx = Length(HPdata)-1
    then 
      begin
      HPparamIdx := 0;
      SaveToFile();
      //btnSettingsReadClick(nil);
      end
    else inc(HPparamIdx);
end;

procedure TFormHPmonitor.tmrScrollTimer(Sender: TObject);
begin
  tmrScroll.Enabled := False;
  ChartZoom(SenderChart);
end;

procedure TFormHPmonitor.SaveToFile();
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


procedure TFormHPmonitor.ChartScroll(Sender: TObject);
begin
  // mm1.Lines.Add('scroll');
  SenderChart := Sender;
  tmrScroll.Enabled := true;
end;

procedure TFormHPmonitor.ChartUndoZoom(Sender: TObject);
begin
  // mm1.Lines.Add('un zoom');
  chart1.BottomAxis.Automatic := True;
  chart2.BottomAxis.Automatic := True;
  chart3.BottomAxis.Automatic := True;
end;

procedure TFormHPmonitor.ChartZoom(Sender: TObject);
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


procedure TFormHPmonitor.btnSettingsReadClick(Sender: TObject);
label error;
var                            //   1    2    3   4   5  
  DtTm : array [1..5] of word; //  day, mth, yr, hr, min    // day of the week is automatically recalculated by the unit at every minute change
  i : Integer;
  
begin
  Screen.Cursor := crHourGlass;
  btnReadData.Enabled := False;
  StopAutoRead();
  
  // loopback test
  if not HPCommReadLog(HPsettings, 0, True) then goto error;

(*standby 256     0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 01 00 01 20 
  automatic 512   0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 02 00 01 21 
  day 768         0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 03 00 01 22 
  night 1024      0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 04 00 01 23 
  water  1280     0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 05 00 01 24 
  emergency 0     0D 00 03 01 00 FA 01 12 80 08 01 A6 03 00 0D 02 00 FA 01 12 00 00 01 1F  *)
  
  // op mode
  if not HPCommReadLog(HPsettings, 1, False) then goto error;
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
  
  if not HPCommReadLog(HPsettings, 2, False) then goto error;
  edC1Day.Text := FloatToStrF(HPsettings[2].Value, ffFixed, 5, 1);

  if not HPCommReadLog(HPsettings, 3, False) then goto error;
  edC1night.Text := FloatToStrF(HPsettings[3].Value, ffFixed, 5, 1);

  if not HPCommReadLog(HPsettings, 4, False) then goto error;
  edC2Day.Text := FloatToStrF(HPsettings[4].Value, ffFixed, 5, 1);

  if not HPCommReadLog(HPsettings, 5, False) then goto error;
  edC2Night.Text := FloatToStrF(HPsettings[5].Value, ffFixed, 5, 1);

  if not HPCommReadLog(HPsettings, 6, False) then goto error;
  edWaterDay.Text := FloatToStrF(HPsettings[6].Value, ffFixed, 5, 1);

  if not HPCommReadLog(HPsettings, 7, False) then goto error;
  edWaterNight.Text := FloatToStrF(HPsettings[7].Value, ffFixed, 5, 1);

  if not HPCommReadLog(HPsettings, 8, False) then goto error;
  edPartyHrs.Text := FloatToStrF(HPsettings[8].Value, ffFixed, 5, 0);

  if not HPCommReadLog(HPsettings, 9, False) then goto error; // current time
  lblCurrTime.Caption := LeadingZeros(((HPsettings[9].Data      ) AND $FF), 2) + ':' +  // HH
                         LeadingZeros(((HPsettings[9].Data SHR 8) AND $FF), 2);         // MM 

  // read date and time
  for i := 1 to 5 do
    begin
    if not HPCommReadLog(HPsettings, 9 + i, False) then goto error;
    DtTm[i] := round(HPsettings[9+i].Value);
    end;
  lblCurrTime.Caption := lblCurrTime.Caption + CRLF +  
    LeadingZeros(DtTm[4], 2) + ':' +  // HH
    LeadingZeros(DtTm[5], 2) + CRLF + // MM
      IntToStr(DtTm[3]+2000) + '-' + // YYYY
    LeadingZeros(DtTm[2], 2) + '-' + // MM
    LeadingZeros(DtTm[1], 2);        // DD
  if cbDebug.Checked then mm1.Lines.Add(lblCurrTime.Caption);
   
  StartAutoRead(); // re-enable timer if required
  
error:
  Screen.Cursor := crDefault;
  btnReadData.Enabled := True;
end;

procedure TFormHPmonitor.btnSettingsWriteClick(Sender: TObject);

    function WriteStr (txt : string; Didx : Integer) : Boolean;
    var
      vv : Double;
    begin  
    Result := True; // false only on comm error
      vv := StrToFloatDef(txt, -100);
      if vv > -100 then
        begin
        HPsettings[Didx].Value := vv;
        Result := HPCommWriteLog(HPsettings, Didx);
        end
      else
        begin  
        mm1.Lines.Add('Wrong data: "'+txt+'"');
        end;
    end;
  
label error; // skip to the end and clean up what needs to be finalized
var
  Time : TDateTime;
  hh, mm, ss, ms,
  yr, mth, day : word;
  
begin
  Screen.Cursor := crHourGlass;
  StopAutoRead();
  // loopback test
  if not HPCommReadLog(HPsettings, 0, True) then goto error;

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
  if not HPCommWriteLog(HPsettings, 1) then goto error;

  if not WriteStr(edC1Day.Text, 2) then goto error;
  if not WriteStr(edC1night.Text, 3) then goto error;
  if not WriteStr(edC2Day.Text, 4) then goto error;
  if not WriteStr(edC2Night.Text, 5) then goto error;
  if not WriteStr(edWaterDay.Text, 6) then goto error;
  if not WriteStr(edWaterNight.Text, 7) then goto error;
  if not WriteStr(edPartyHrs.Text, 8) then goto error;

  // current time
  Time := GetTime();
  DecodeTime(Time, hh, mm, ss, ms);
  // MSB = minutes, LSB = hours: 060B = "11:06"
  HPsettings[9].Data := ((mm SHL 8) AND $FF00) OR (hh AND $00FF); 
  HPsettings[9].Value := -999999; // use Data variable to write value
  mm1.Lines.Add('Writing current time: 0x' + IntToHex(HPsettings[9].Data, 4));
  if not HPCommWriteLog(HPsettings, 9) then goto error;
  // current date and time in different registers
  Time := now();
  DecodeDate(Time, yr, mth, day);

  HPsettings[10].Value := day;
  if not HPCommWriteLog(HPsettings, 11) then goto error;
  HPsettings[11].Value := mth;
  if not HPCommWriteLog(HPsettings, 12) then goto error;
  HPsettings[12].Value := yr-2000;
  if not HPCommWriteLog(HPsettings, 13) then goto error;
  HPsettings[13].Value := hh;
  if not HPCommWriteLog(HPsettings, 14) then goto error;
  HPsettings[14].Value := mm;
  if not HPCommWriteLog(HPsettings, 15) then goto error;
  // day of the week (register $0121) is automatically recalculated by the unit itself at every minute change

error:
  Screen.Cursor := crDefault;
  btnReadData.Enabled := True;
  StartAutoRead(); // re-enable timer if required  
end;

procedure TFormHPmonitor.btnTestClick(Sender: TObject);
begin
  // assign real functions
  FormTest.BeforeReading := StopAutoRead;
  FormTest.AfterReading := StartAutoRead;    

  FormTest.Show;
end;

procedure TFormHPmonitor.btnShowEnergyClick(Sender: TObject);
begin
  // assign real functions
  FormEnergy.BeforeReading := StopAutoRead;
  FormEnergy.AfterReading := StartAutoRead;    

  FormEnergy.Show;
end;

procedure StartAutoRead();
begin
  FormHPmonitor.timerAutoRead.Enabled := (FormHPmonitor.cbReadConstatntly.Checked AND NOT FormHPmonitor.btnComOpen.Enabled);
end;

procedure StopAutoRead();
begin
  FormHPmonitor.timerAutoRead.Enabled := False;
end;


procedure TFormHPmonitor.FormCreate(Sender: TObject);
var
  i : Integer;
  
begin
  SenderChart := nil;
  SetLength(HPdata, 16+7);
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
  HPdata[i].Series  := nil;
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

  HPdata[i].Name    := '0064 COLLECTOR';
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

//--------------------------------------------------------------------------------------------------------------------

  HPdata[i].Name    := 'Fan speed';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0833;
  HPdata[i].Scaling := 0.01;
  HPdata[i].Units   := '';
  HPdata[i].Series  := series13;
  inc(i);

  HPdata[i].Name    := 'Compressor speed';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $063D;
  HPdata[i].Scaling := 0.01;
  HPdata[i].Units   := '';
  HPdata[i].Series  := series14;
  inc(i);
(* 
  HPdata[i].Name    := 'Compressor target';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $063B;
  HPdata[i].Scaling := 0.01;
  HPdata[i].Units   := '';
  HPdata[i].Series  := nil;
  inc(i);
*) 
  HPdata[i].Name    := 'High pressure';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $07A6;
  HPdata[i].Scaling := 0.01;
  HPdata[i].Units   := ' bar';
  HPdata[i].Series  := series15;
  inc(i);
 
  HPdata[i].Name    := 'Low pressure';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $07A7;
  HPdata[i].Scaling := 0.01;
  HPdata[i].Units   := ' bar';
  HPdata[i].Series  := series16;
  inc(i);

  HPdata[i].Name    := 'Hot gas temperature';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0265;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  := nil;
  inc(i);

  HPdata[i].Name    := 'Defrost active';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0060;
  HPdata[i].Scaling := 1/256*1.3;
  HPdata[i].Units   := '';
  HPdata[i].Series  := Series11;
  inc(i);
 
  HPdata[i].Name    := 'Last defrost duration';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0807;
  HPdata[i].Scaling := 1;
  HPdata[i].Units   := '';
  HPdata[i].Series  := nil;
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

  SetLength(HPsettings, 16);
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

  HPsettings[i].Name    := 'Party hours';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $fdbf;
  HPsettings[i].Scaling := 1/256;  // 3328 = 13 hours
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);
  // 9
  HPsettings[i].Name    := 'Current time';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $0009;
  HPsettings[i].Scaling := 1; // MSB = minutes, LSB = hours: 060B = "11:06"
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);
(*
  { "WOCHENTAG"                                        , 0x0121, et_little_endian},
  { "TAG"                                              , 0x0122, et_little_endian},
  { "MONAT"                                            , 0x0123, et_little_endian},
  { "JAHR"                                             , 0x0124, et_little_endian}, // +2000
  { "STUNDE"                                           , 0x0125, et_little_endian},
  { "MINUTE"                                           , 0x0126, et_little_endian},
  { "SEKUNDE"                                          , 0x0127, et_little_endian},
*)  
  // 10
  HPsettings[i].Name    := 'DAY';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $0122;
  HPsettings[i].Scaling := 1/256; // MSB = real value
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);

  HPsettings[i].Name    := 'MONTH';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $0123;
  HPsettings[i].Scaling := 1/256; // MSB = real value
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);

  HPsettings[i].Name    := 'YEAR';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $0124;
  HPsettings[i].Scaling := 1/256; // MSB = real value
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);

  HPsettings[i].Name    := 'HOUR';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $0125;
  HPsettings[i].Scaling := 1/256; // MSB = real value
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);
  // 14
  HPsettings[i].Name    := 'MINUTES';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $0126;
  HPsettings[i].Scaling := 1/256; // MSB = real value
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);

  // currently not used
  // 15
  HPsettings[i].Name    := 'Manual defrost';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_BOILER;
  HPsettings[i].Circuit := CIRC_GEN;
  HPsettings[i].RegAddr := $fdc0;
  HPsettings[i].Scaling := 1/256;
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);
  
end;

end.
