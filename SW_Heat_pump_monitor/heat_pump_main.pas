unit heat_pump_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin, Orodja, serial_comm,
  VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, Vcl.Grids, inifiles,
  window_test, window_energy, window_errors, window_settings, heat_pump_comm,
  SendEmail;

const
  FN1 : string = '.\Temperatures_';
  
type
  TFormHPmonitor = class(TForm)
    chart1: TChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series3: TLineSeries;
    pnlComm: TPanel;
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
    Series6: TLineSeries;
    Series7: TLineSeries;
    Series9: TLineSeries;
    cbDebug: TCheckBox;
    tmrScrollZoomCharts: TTimer;
    btnTest: TButton;
    btnEnergy: TButton;
    Series11: TLineSeries;
    Series13: TLineSeries;
    Series14: TLineSeries;
    Series15: TLineSeries;
    Series16: TLineSeries;
    Series10: TLineSeries;
    Series12: TLineSeries;
    Series5: TLineSeries;
    tmrStartup: TTimer;
    btnLoadCharts: TButton;
    OpenDialogTxt: TOpenDialog;
    cbLogCommErrors: TCheckBox;
    btnErrors: TButton;
    btnSettings: TButton;
    procedure btnComSearchClick(Sender: TObject);
    procedure btnComOpenClick(Sender: TObject);
    procedure btnComCloseClick(Sender: TObject);
    procedure btnReadDataClick(Sender: TObject);
    procedure cbReadConstatntlyClick(Sender: TObject);
    procedure timerAutoReadTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbDebugClick(Sender: TObject);
    procedure gridDataClick(Sender: TObject);
    procedure btnLoadChartsClick(Sender: TObject);
    procedure tmrScrollZoomChartsTimer(Sender: TObject);
    procedure ChartZoom(Sender: TObject);
    procedure ChartScroll(Sender: TObject);
    procedure ChartUndoZoom(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnEnergyClick(Sender: TObject);
    procedure tmrStartupTimer(Sender: TObject);
    procedure btnErrorsClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
  private
    HPparamIdx : Integer;
    SenderChart : TObject;
    InitOK : Integer;
    ViewOnlyMode : Boolean;
    LastHPErrorTime : u16;
    ErrorReadCountdown : Integer;
    procedure SaveToFile();
    procedure CheckHPErrorsSendEmail();
    function  HPCommReadLog(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
    function  HPCommWriteLog(var Dataset : TAHPdata; Didx : Integer) : Boolean;    
  public
    //...
  end;

      
var
  FormHPmonitor: TFormHPmonitor;
  HPdata : TAHPdata;
  HPcheck : TAHPdata;

procedure StartAutoRead();
procedure StopAutoRead();
procedure DisplayDebug (sss : string);
procedure DisplayError (sss : string);

implementation

{$R *.dfm}

procedure DisplayDebug (sss : string);
begin
  if FormHPmonitor.cbDebug.Checked then FormHPmonitor.mm1.Lines.Add(sss);
end;
procedure DisplayError (sss : string);
begin
  FormHPmonitor.mm1.Lines.Add(sss);
end;

function  TFormHPmonitor.HPCommReadLog(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
begin
  HPLastMessage := '';
  Result := HPCommRead(Dataset, Didx, Test);
  if HPLastMessage <> '' then
    begin
    // ignore the Reading error if not requested by the user/checkbox
    if (Pos('Error reading data.', HPLastMessage) <> 1) OR cbLogCommErrors.Checked then
      mm1.Lines.Add(HPLastMessage);  
    end;
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
  btnSettings.Enabled := False;
  btnErrors.Enabled := False;
  btnEnergy.Enabled := False;
  btnTest.Enabled := False;

  FormSettings.btnSettingsRead.Enabled := False;
  FormSettings.btnSettingsWrite.Enabled := False;
  FormEnergy.btnReadEnergyData.Enabled := False;
  FormErrors.btnReadErr.Enabled := False;
  FormTest.btnScanDevices.Enabled := False;
  FormTest.btnScanRegisters.Enabled := False;
  FormTest.btnScanAllDevReg.Enabled := False;
  FormTest.btnReadMan.Enabled := False;
  
  ComPortClose(USBnaprave[Uidx]);
end;

procedure TFormHPmonitor.btnComOpenClick(Sender: TObject);
begin
  InitOK := 0;
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
  btnSettings.Enabled := True;
  btnErrors.Enabled := True;
  btnEnergy.Enabled := True;
  btnTest.Enabled := True;

  FormSettings.btnSettingsRead.Enabled := True;
  FormSettings.btnSettingsWrite.Enabled := True;
  FormEnergy.btnReadEnergyData.Enabled := True;
  FormErrors.btnReadErr.Enabled := True;
  FormTest.btnScanDevices.Enabled := True;
  FormTest.btnScanRegisters.Enabled := True;
  FormTest.btnScanAllDevReg.Enabled := True;
  FormTest.btnReadMan.Enabled := True;

  mm1.Clear;

  // 0d 00 0d 01 00 0b 00 00 00 00 00 26 	 55 55 55 55 55 55 55 55 55 55 03 52  '0d PC	'0d PC	'01 Read	'000b	'0000	'0000	'0026
  // check connection
  if HPCommReadLog(HPcheck, 0, True) 
    then 
      begin
      mm1.Lines.Add('Loopback Check 1 (TX/RX function) OK.');
      inc(InitOK);
      end
    else mm1.Lines.Add('Loopback Check 1 (TX/RX function) fail!');
    
  if copy(HPcheck[0].Response, 1, 12) = HPcheck[0].Request 
    then 
      begin
      mm1.Lines.Add('Loopback Check 2 (IR echo) OK.');
      inc(InitOK);
      end
    else mm1.Lines.Add('Loopback Check 2 (IR echo) fail!');

  if copy(HPcheck[0].Response, 13, 10) = #$55#$55#$55#$55#$55#$55#$55#$55#$55#$55 
    then 
      begin
      mm1.Lines.Add('Loopback Check 3 (response 0x55) OK.');
      inc(InitOK);
      end
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

procedure TFormHPmonitor.btnErrorsClick(Sender: TObject);
begin
  FormErrors.Show;
end;

procedure TFormHPmonitor.btnLoadChartsClick(Sender: TObject);
var
  FN2 : string;
  F: TextFile;
  FileNum : Integer;
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
  OpenDialogTxt.Files.Clear;
  OpenDialogTxt.Files.Add(FN2); // in COMM mode, load the most recent file with today's date.

  if ViewOnlyMode then
    begin
    OpenDialogTxt.Filter := 'Saved heat pump data (*.csv)|*.csv';
    OpenDialogTxt.Title := 'Load heat pump recordings';
    OpenDialogTxt.Files.Clear;
    if NOT OpenDialogTxt.Execute then exit;
    if OpenDialogTxt.Files.Count = 0 then exit;
    end;
  
  SL := TStringList.Create;
  for FileNum := 0 to OpenDialogTxt.Files.Count-1 do
    begin
    FN2 := OpenDialogTxt.Files.Strings[FileNum];
  
    if not FileExists(FN2) then
      begin
      mm1.Lines.Add('File doesn''t exist: ' + FN2);
      Exit;
      end;
  
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
        if ViewOnlyMode then ShowMessage('Data size mismatch on line ' + IntToStr(LineNum));       
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
        if ViewOnlyMode then ShowMessage('Incorrect DateTime on line ' + IntToStr(LineNum) + ': ' + ss);
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
          if ViewOnlyMode then ShowMessage('Incorrect value on line ' + IntToStr(LineNum) + ': "' + ss + '"');
          SL.Destroy;
          CloseFile(F);
          exit;
          end;
        if HPdata[param].series <> nil then
          HPdata[param].series.AddXY(tt, vv);      
        end;    
      end;
  
    CloseFile(F);
    end;
  SL.Destroy;
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
  SetLength(HPcheck, 0);
end;

procedure TFormHPmonitor.cbDebugClick(Sender: TObject);
begin
  PrintDebugMsg := cbDebug.Checked;
  if cbDebug.Checked
  then
    begin
    gridData.Height := (gridData.DefaultRowHeight+1) * gridData.RowCount + 3 -200;
    mm1.Height := 740 - gridData.Height;
    end
  else
    begin
    gridData.Height := (gridData.DefaultRowHeight+1) * gridData.RowCount + 3;
    mm1.Height := 740 - gridData.Height;
    mm1.Clear;
    end;

  mm1.Top := gridData.Top + gridData.Height + 6;   
end;

procedure TFormHPmonitor.cbReadConstatntlyClick(Sender: TObject);
begin
  StartAutoRead();
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

      FormErrors.lblCountdown.Caption := IntToStr(ErrorReadCountdown) + ' ['+IntToHex(LastHPErrorTime)+']';
      if ErrorReadCountdown = 0 then
        begin
        ErrorReadCountdown := 50; // every 50 cycles check error status and send email if changed
        CheckHPErrorsSendEmail();
        end
      else dec(ErrorReadCountdown); 
      end
    else inc(HPparamIdx);
end;

procedure TFormHPmonitor.tmrScrollZoomChartsTimer(Sender: TObject);
begin
  tmrScrollZoomCharts.Enabled := False;
  ChartZoom(SenderChart);
end;

procedure TFormHPmonitor.tmrStartupTimer(Sender: TObject);
var
  IniFile: TMemIniFile;
  iniFileName : string;
  
begin
  tmrStartup.Enabled := False;
  // assign real functions
  FormSettings.BeforeReading := StopAutoRead;
  FormSettings.AfterReading := StartAutoRead;    
  FormSettings.PrintDebug := DisplayDebug;
  FormSettings.PrintError := DisplayError;

  FormTest.BeforeReading := StopAutoRead;
  FormTest.AfterReading := StartAutoRead;    

  FormEnergy.BeforeReading := StopAutoRead;
  FormEnergy.AfterReading := StartAutoRead;    

  FormErrors.BeforeReading := StopAutoRead;
  FormErrors.AfterReading := StartAutoRead;    

  FormSendEmail.PrintDebug := DisplayDebug;
  FormSendEmail.PrintError := DisplayError;

  iniFileName := ChangeFileExt(ParamStr(0), '.ini');
  IniFile := TMemIniFile.Create(iniFileName);
  FormSettings.edMailLoginUser.Text := TrimEmail(      IniFile.ReadString('EMAIL', 'LoginUser', ''));
  FormSettings.edMailLoginPass.Text := Trim2    (      IniFile.ReadString('EMAIL', 'LoginPass', ''));
  FormSettings.edMailAddressReceiver.Text := TrimEmail(IniFile.ReadString('EMAIL', 'ReceiverAddress', ''));
  IniFile.Free;
  FormSettings.UpdateEmailData(nil);
  
  
  cbDebug.Checked := PrintDebugMsg;
  cbDebugClick(nil);  
  btnComSearchClick(nil);
  if ddPortList.Items.Count > 0 then
    begin
    btnComOpenClick(nil);
    if InitOK = 3 then 
      begin
      //btnSettingsReadClick(nil);
      cbReadConstatntly.Checked := True;
      btnLoadChartsClick(nil);
      end;
    end;
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

procedure TFormHPmonitor.CheckHPErrorsSendEmail();
var
  NewHPErrorTime : u16;
  EmailBody : string;
  row, col : Integer;
  
begin
  if cbDebug.Checked then mm1.Lines.Add('Checking for any new errors on HP...');
  NewHPErrorTime := FormErrors.ReadLastHPErrorTime();
  if LastHPErrorTime <> NewHPErrorTime then
    begin
    mm1.Lines.Add('Reading all error history...');
    FormErrors.btnReadErrClick(nil);
    EmailBody := 'Current time: ' + DateTimeToStr(now()) + CRLF;
    for row := 0 to FormErrors.GridErrors.RowCount-1 do
      begin
      for col := 0 to FormErrors.GridErrors.ColCount-1 do
        begin
        EmailBody := EmailBody + FormErrors.GridErrors.Cells[col, row] + '  ' + TAB;
        end;
      EmailBody := EmailBody + CRLF;
      end;
    mm1.Lines.Add('Sending email...');
    FormSendEmail.SendEmail('HP porocilo o napakah', EmailBody);    
    mm1.Lines.Add('Complete.');
    end;  
  LastHPErrorTime := NewHPErrorTime;
end;


procedure TFormHPmonitor.ChartScroll(Sender: TObject);
begin
  // mm1.Lines.Add('scroll');
  SenderChart := Sender;
  tmrScrollZoomCharts.Enabled := true;
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


procedure TFormHPmonitor.btnTestClick(Sender: TObject);
begin
  FormTest.Show;
end;

procedure TFormHPmonitor.btnSettingsClick(Sender: TObject);
begin
  FormSettings.Show;
end;

procedure TFormHPmonitor.btnEnergyClick(Sender: TObject);
begin
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
  ViewOnlyMode := False;
  for i := 1 to ParamCount do
    begin
    if Pos('/VIEW',UpperCase(ParamStr(i))) > 0 then
      begin
      ViewOnlyMode := True;
      pnlComm.Width := 0;
      btnLoadCharts.Left := 5;
      chart1.Left := 0;
      chart2.Left := 0;
      chart3.Left := 0;
      chart1.Width := Width;
      chart2.Width := Width;
      chart3.Width := Width;
      end;
    end;

  // -------------------
  LastHPErrorTime := 0;
  ErrorReadCountdown := 3;


  SetLength(HPcheck, 1);
  // 0d 00 0d 01 00 0b 00 00 00 00 00 26 	 55 55 55 55 55 55 55 55 55 55 03 52  '0d PC	'0d PC	'01 Read	'000b	'0000	'0000	'0026
  //0 : TXD := #$0d#$00#$0d#$01#$00#$0b#$00#$00#$00#$00#$00#$26;
  HPcheck[0].Name    := 'Loopback test';
  HPcheck[0].Request := #$0d#$00#$0d#$01#$00#$0b#$00#$00#$00#$00#$00#$26;   
  HPcheck[0].Device  := DEV_OPT_PC;
  HPcheck[0].Circuit := CIRC_GEN;
  HPcheck[0].RegAddr := 0;
  HPcheck[0].Scaling := 1;
  HPcheck[0].Units   := '';
  HPcheck[0].Series  := nil;

  
  SenderChart := nil;
  SetLength(HPdata, 15+7+4);
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
  
  HPdata[i].Name    := 'Outdoor HP';
  HPdata[i].Request := '';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $000c;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  := Series12;
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

  HPdata[i].Name    := 'Room set';  // ADJUSTED ROOM SET TEMP
  HPdata[i].Request := '';
  HPdata[i].Device  := DEV_MIXER;
  HPdata[i].Circuit := CIRC_HC1;
  HPdata[i].RegAddr := $0012;
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
  HPdata[i].Name    := 'Heating 2';
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
  
  HPdata[i].Name    := 'Buffer set';
  HPdata[i].Request := '';
  HPdata[i].Device  := DEV_CONTROL;
  HPdata[i].Circuit := CIRC_HC1;
  HPdata[i].RegAddr := $0004;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  := nil;
  inc(i);

    // 0d 00 03 01 00 fa 01 d6 80 08 02 6a 	 03 00 0d 02 00 fa 01 d6 01 bd 02 a1 	'0d	'03	'01 read	'00fa	'01d6 WP PRELIMINARY LIST	'8008	'026a		'03	'0d	'02	'00fa	'01d6 WP PRELIMINARY LIST	'01bd	'02a1	01bd	445	445	44,5
  HPdata[i].Name    := 'Charge flow';
  HPdata[i].Request := '';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0822;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  :=  Series4;
  inc(i);

  HPdata[i].Name    := 'Charge return';
  HPdata[i].Request := '';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0823;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  := Series10;
  inc(i);

  HPdata[i].Name    := 'Chg flow rate';
  HPdata[i].Request := '';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0a3f;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := '';
  HPdata[i].Series  := nil;
  inc(i);

//======================================================================================================================

  HPdata[i].Name    := 'Chg Pump hot water';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$53#$00#$00#$01#$5e;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0053;
  HPdata[i].Scaling := 1/256 * 1.05;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series6;
  inc(i);

  HPdata[i].Name    := 'Chg Pump heating';
  HPdata[i].Request := #$0d#$00#$03#$01#$00#$fa#$00#$63#$00#$00#$01#$6e;
  HPdata[i].Device  := DEV_BOILER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0063;
  HPdata[i].Scaling := 1/256 * 1.10;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series7;
  inc(i);

  HPdata[i].Name    := 'Pump Circuit 1';
  HPdata[i].Request := #$0d#$00#$09#$01#$00#$fa#$fd#$ac#$00#$00#$02#$ba;
  HPdata[i].Device  := DEV_MANAGER;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $fdac;
  HPdata[i].Scaling := 1/512 * 1.20;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series9;
  inc(i);
(*
  HPdata[i].Name    := '0052 BURNER ?';
  HPdata[i].Request := #$0d#$00#$0c#$01#$02#$fa#$00#$52#$00#$00#$01#$68;
  HPdata[i].Device  := DEV_MIXER;
  HPdata[i].Circuit := CIRC_HC2;
  HPdata[i].RegAddr := $0052;
  HPdata[i].Scaling := 1/256 * 1.0;
  HPdata[i].Units   := '';
  HPdata[i].Series  :=  Series5;
  inc(i);
*)
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

  HPdata[i].Name    := 'Evaporator temperature';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0821;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  := nil;
  inc(i);
 
  HPdata[i].Name    := 'Expelled air';
  HPdata[i].Device  := DEV_HEATING;
  HPdata[i].Circuit := CIRC_GEN;
  HPdata[i].RegAddr := $0a38;
  HPdata[i].Scaling := 0.1;
  HPdata[i].Units   := ' °C';
  HPdata[i].Series  := Series5;
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
  HPdata[i].Units   := ' min';
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
  
  InitOK := 0;
  tmrStartup.Enabled := True;  
end;

end.
