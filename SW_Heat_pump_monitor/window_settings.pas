unit window_settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, inifiles, heat_pump_comm, orodja, heat_pump_constants, SendEmail;

type
  TFormSettings = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblWater: TLabel;
    Label5: TLabel;
    lblCurrTime: TLabel;
    edC1Day: TEdit;
    edC2Day: TEdit;
    edC1night: TEdit;
    edC2Night: TEdit;
    edWaterDay: TEdit;
    edWaterNight: TEdit;
    ddHPMode: TComboBox;
    btnSettingsRead: TButton;
    btnSettingsWrite: TButton;
    edPartyHrs: TEdit;
    Label6: TLabel;
    grpEmail: TGroupBox;
    edMailLoginUser: TEdit;
    edMailAddressReceiver: TEdit;
    edMailLoginPass: TEdit;
    btnSave: TButton;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    btnMailTest: TButton;
    Label10: TLabel;
    edHtgCurve1: TEdit;
    edHtgCurve2: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btnSettingsReadClick(Sender: TObject);
    procedure btnSettingsWriteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnMailTestClick(Sender: TObject);
    procedure UpdateEmailData(Sender: TObject);
  private
    Stop : Boolean;
    function  HPCommReadLog(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
    function  HPCommWriteLog(var Dataset : TAHPdata; Didx : Integer) : Boolean;    
  public
    BeforeReading: procedure;
    AfterReading: procedure;
    PrintDebug: procedure(sss : string);
    PrintError: procedure(sss : string);
  end;

var
  FormSettings: TFormSettings;
  HPsettings : TAHPdata;

implementation

{$R *.dfm}

procedure dummy();
begin
  // NOP.
end;

procedure PrintDebug_internal(sss : string);
begin
//  ShowMessage(sss);
end;
procedure PrintError_internal(sss : string);
begin
  ShowMessage(sss);
end;

function  TFormSettings.HPCommReadLog(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
begin
  HPLastMessage := '';
  Result := HPCommRead(Dataset, Didx, Test);
  if HPLastMessage <> '' then PrintError(HPLastMessage);
end;

function  TFormSettings.HPCommWriteLog(var Dataset : TAHPdata; Didx : Integer) : Boolean;
begin
  HPLastMessage := '';
  Result := HPCommWrite(Dataset, Didx);
  if HPLastMessage <> '' then PrintError(HPLastMessage);
end;


procedure TFormSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Stop := True;
  AfterReading();    
end;

procedure TFormSettings.btnMailTestClick(Sender: TObject);
begin
  PrintError('Sending email...');
  PrintError('  Result = ' + BoolToStr(
    FormSendEmail.SendEmail('Heat pump test email', 'Stiebel Eltron heat pump WPM manager over optical interface.'+CRLF+'Author: Aljaz Ogrin.'+CRLF+'GitHub repository: "aly-fly"'),
    True));
  PrintError('Done.');
end;

procedure TFormSettings.btnSaveClick(Sender: TObject);
var
  IniFile: TMemIniFile;
  iniFileName : string;
begin
  iniFileName := ChangeFileExt(ParamStr(0), '.ini');

  IniFile := TMemIniFile.Create(iniFileName);

  IniFile.WriteString('EMAIL', 'LoginUser', TrimEmail(edMailLoginUser.Text));
  IniFile.WriteString('EMAIL', 'LoginPass', Trim2(edMailLoginPass.Text));
  IniFile.WriteString('EMAIL', 'ReceiverAddress', TrimEmail(edMailAddressReceiver.Text));

  IniFile.UpdateFile; // save from memory stream to file
  IniFile.Free;
end;

procedure TFormSettings.btnSettingsReadClick(Sender: TObject);
label error;
var                            //   1    2    3   4   5  
  DtTm : array [1..5] of word; //  day, mth, yr, hr, min    // day of the week is automatically recalculated by the unit at every minute change
  i : Integer;
  
begin
  BeforeReading();
  Stop := False;
  Screen.Cursor := crHourGlass;
  
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
      PrintError('Unknown op mode: 0x' + IntToHex(HPsettings[1].Data));
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

  if not HPCommReadLog(HPsettings, 15, False) then goto error;
  edHtgCurve1.Text := FloatToStrF(HPsettings[15].Value, ffFixed, 5, 2);

  if not HPCommReadLog(HPsettings, 16, False) then goto error;
  edHtgCurve2.Text := FloatToStrF(HPsettings[16].Value, ffFixed, 5, 2);

  
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
     
error:
  AfterReading();
  Screen.Cursor := crDefault;
end;

procedure TFormSettings.btnSettingsWriteClick(Sender: TObject);

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
        PrintError('Wrong data: "'+txt+'"');
        end;
    end;
  
label error; // skip to the end and clean up what needs to be finalized
var
  Time : TDateTime;
  hh, mm, ss, ms,
  yr, mth, day : word;
  
begin
  BeforeReading();
  Stop := False;
  Screen.Cursor := crHourGlass;

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
  if not WriteStr(edHtgCurve1.Text, 15) then goto error;
  if not WriteStr(edHtgCurve2.Text, 16) then goto error; 
  if not WriteStr(edPartyHrs.Text, 8) then goto error;

  // current time
  Time := GetTime();
  DecodeTime(Time, hh, mm, ss, ms);
  // MSB = minutes, LSB = hours: 060B = "11:06"
  HPsettings[9].Data := ((mm SHL 8) AND $FF00) OR (hh AND $00FF); 
  HPsettings[9].Value := -999999; // use Data variable to write value
  PrintDebug('Writing current time: 0x' + IntToHex(HPsettings[9].Data, 4));
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
  AfterReading();
  Screen.Cursor := crDefault;
end;


procedure TFormSettings.FormDestroy(Sender: TObject);
begin
  SetLength(HPsettings, 0);
end;

procedure TFormSettings.UpdateEmailData(Sender: TObject);
begin
  FormSendEmail.EmailUser := edMailLoginUser.Text;
  FormSendEmail.EmailPass := edMailLoginPass.Text;
  FormSendEmail.EmailRcpt := edMailAddressReceiver.Text;
end;

procedure TFormSettings.FormCreate(Sender: TObject);
var
  i : Integer;
  
begin
  // functions are not defined yet. Main wrapper may divert those pointers to some actual procedures.
  BeforeReading := dummy;
  AfterReading := dummy;
  PrintDebug := PrintDebug_internal;
  PrintError := PrintError_internal;

(*
  src := Copy(S,  1, 2);  
  dst := Copy(S,  5, 2);
  qry := Copy(S,  7, 2);
  cir := Copy(S,  9, 4);
  reg := Copy(S, 13, 4);
  bbb := Copy(S, 17, 4);
  csm := Copy(S, 21, 4);
*)  

  SetLength(HPsettings, 18);
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

  // 15
  HPsettings[i].Name    := 'Heating Curve Circ 1';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_CONTROL;
  HPsettings[i].Circuit := CIRC_HC1;
  HPsettings[i].RegAddr := $010E;
  HPsettings[i].Scaling := 0.01;
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);

  // 16
  HPsettings[i].Name    := 'Heating Curve Circ 2';
  HPsettings[i].Request := '';
  HPsettings[i].Device  := DEV_CONTROL;
  HPsettings[i].Circuit := CIRC_HC2;
  HPsettings[i].RegAddr := $010E;
  HPsettings[i].Scaling := 0.01;
  HPsettings[i].Units   := '';
  HPsettings[i].Series  := nil;
  inc(i);

  // currently not used
  // 17
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
