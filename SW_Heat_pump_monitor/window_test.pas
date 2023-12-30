unit window_test;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, heat_pump_comm, heat_pump_constants, orodja, Vcl.Grids, Vcl.ExtCtrls, Vcl.Samples.Spin,
  Vcl.ComCtrls;

type
  TFormTest = class(TForm)
    btnScanDevices: TButton;
    mm1: TMemo;
    cbDebug: TCheckBox;
    DevGrid: TStringGrid;
    rgDevices: TRadioGroup;
    btnScanRegisters: TButton;
    seNumRegisters: TSpinEdit;
    pb1: TProgressBar;
    btnScanAllDevReg: TButton;
    pb2: TProgressBar;
    lblRegScanStatus: TLabel;
    edDev: TEdit;
    edCirc: TEdit;
    edReg: TEdit;
    btnReadMan: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    edVal: TEdit;
    edNumRegs: TEdit;
    Label1: TLabel;
    procedure btnScanDevicesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbDebugClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnScanRegistersClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnScanAllDevRegClick(Sender: TObject);
    procedure btnReadManClick(Sender: TObject);
  private
    function  HPCommReadLog(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
    procedure SaveToFile(Name : string);
  public
    Stop : boolean;
  end;

var
  FormTest: TFormTest;
  DatasetTest : TAHPdata;

implementation

{$R *.dfm}

function  TFormTest.HPCommReadLog(var Dataset : TAHPdata; Didx : Integer; Test : Boolean) : Boolean;
begin
  HPLastMessage := '';
  Result := HPCommRead(Dataset, Didx, Test);
  if HPLastMessage <> '' then mm1.Lines.Add(HPLastMessage);
end;

procedure TFormTest.btnReadManClick(Sender: TObject);
var
  Data : TAHPdata;
  i, n : Integer;
begin
  SetLength(Data, 1);
  Data[0].Device  := StrToInt(edDev.Text);
  Data[0].Circuit := StrToInt(edCirc.Text);
  Data[0].RegAddr := StrToInt(edReg.Text);
  n := StrToInt(edNumRegs.Text);
  for i := 0 to n-1 do 
    begin
    Data[0].RegAddr := StrToInt(edReg.Text) + i;
    if HPCommReadLog (Data, 0, False) 
      then edVal.Text := IntToHex(Data[0].Data, 4) + '  ' + IntToStr(s16(Data[0].Data))
      else edVal.Text := '';
    mm1.Lines.Add(edDev.Text + ' ' + edCirc.Text + ' ' + IntToHex(Data[0].RegAddr, 4) + ' ' + edVal.Text);  
    if Application.Terminated or Stop then exit; 
    wait (200);
    end;
  
  mm1.Lines.Add('-----');  
  SetLength(Data, 0);
end;

procedure TFormTest.btnScanAllDevRegClick(Sender: TObject);
var
  dev, num : Integer;
begin
  btnScanAllDevReg.Enabled := False;
  num := rgDevices.Items.Count;
  pb2.Max := num;
  for dev := 0 to num-1 do
    begin
    rgDevices.ItemIndex := dev;
    btnScanRegistersClick(nil);
    pb2.Position := dev + 1;
    if Application.Terminated or Stop then exit; 
    end;
  btnScanAllDevReg.Enabled := True;
end;

procedure TFormTest.btnScanDevicesClick(Sender: TObject);
var
 dd, cc : Integer;
 sR, L : string;
begin
  mm1.Clear;
  rgDevices.Items.Clear;

  for dd := 0 to Length(DatasetTest)-1 do
    begin
    mm1.Lines.Add('-----');
    for cc := 0 to $F do
      begin
      DatasetTest[dd].Circuit := cc;
      if HPCommReadLog (DatasetTest, dd, True) then sR := 'X' else sR := '.';
      L := DatasetTest[dd].Name + ' ' + IntToHex(cc, 1) + ' ' + sR;
      mm1.Lines.Add(L);
      DevGrid.Cells[cc+1, dd+1] := sR;
      // add to list
      if (sR = 'X') and (DatasetTest[dd].Device <> DEV_BUS_CPL) and (DatasetTest[dd].Device <> DEV_OPT_PC) then
        rgDevices.Items.Add(IntToHex(dd, 2) + ' ' + IntToHex(cc, 2) + ' ' + L);
      // skip end of line if device does not exist
      if (cc > 0) and (sR = '.') then break;
      wait(150);
      if Application.Terminated or Stop then exit; 
      end;
    end;
  btnScanRegisters.Enabled := True;
  btnScanAllDevReg.Enabled := True;  
end;

procedure TFormTest.btnScanRegistersClick(Sender: TObject);
var
  i, rr, Didx, circ, num : Integer;
  txt, t1, t2, srch, cmpr, name : string;
  
begin
  if rgDevices.ItemIndex < 0 then exit;
  btnScanRegisters.Enabled := False;
  mm1.Clear;
  txt := rgDevices.Items[rgDevices.ItemIndex];
  t1 := '$' + Copy(txt, 1, 2);
  t2 := '$' + Copy(txt, 4, 2);

  Didx := StrToIntDef(t1, 0);
  circ := StrToIntDef(t2, 0);  
  
  mm1.Lines.Add(DatasetTest[Didx].Name);
  mm1.Lines.Add('Device;Circuit;Register;Value');
  DatasetTest[Didx].Circuit := circ;
  DatasetTest[Didx].Scaling := 1;
  num := seNumRegisters.Value;
  pb1.Max := num;
  for rr := 0 to num do
    begin
    DatasetTest[Didx].RegAddr := rr;

    // register name
    srch := LowerCase(TrimAlfaNum(IntToHex(rr, 4)));
    name := '';
    for i := 1 to Length(cRegisters)-1 do
      begin
      cmpr := LowerCase(cRegisters[i][1]);
      if cmpr = srch then
        begin
        name := ' ' + cRegisters[i][2];
        break;
        end;    
      end;
    
    lblRegScanStatus.Caption := 
                    IntToHex(DatasetTest[Didx].Device, 1) + '  ' +
                    IntToHex(DatasetTest[Didx].Circuit, 1) + '  ' +
                    IntToHex(DatasetTest[Didx].RegAddr, 4) + '  ';
    
    if HPCommReadLog (DatasetTest, Didx, False) then 
      begin
      lblRegScanStatus.Caption := lblRegScanStatus.Caption + IntToStr(s16(DatasetTest[Didx].Data)) + HPLastMessage;
      
      if DatasetTest[Didx].Data <> $8000 then
        mm1.Lines.Add(IntToHex(DatasetTest[Didx].Device, 1) + ';' +
                      IntToHex(DatasetTest[Didx].Circuit, 1) + ';' +
                '"' + IntToHex(DatasetTest[Didx].RegAddr, 4) + '";' +
                      IntToStr(s16(DatasetTest[Didx].Data)) + ';' +
                      name + ';'
                      );
      end;
    pb1.Position := rr+1;  
    wait (150);
    if Application.Terminated or Stop then exit; 
    end;
  SaveToFile(DatasetTest[Didx].Name);    
  btnScanRegisters.Enabled := True;
end;

procedure TFormTest.cbDebugClick(Sender: TObject);
begin
  PrintDebugMsg := cbDebug.Checked;
end;

procedure TFormTest.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Stop := True;
end;

procedure TFormTest.FormCreate(Sender: TObject);
var
  i, r, c : Integer;
begin
  Stop := False;
  SetLength(DatasetTest, 9);
  for i := 0 to Length(DatasetTest)-1 do
    begin
    DatasetTest[i].Circuit := 0;
    DatasetTest[i].RegAddr := 0;
    end;

  DatasetTest[0].Name := 'Boiler';
  DatasetTest[0].Device := DEV_BOILER;
  
  DatasetTest[1].Name := 'Atez';
  DatasetTest[1].Device := DEV_ATEZ;

  DatasetTest[2].Name := 'Control';
  DatasetTest[2].Device := DEV_CONTROL;

  DatasetTest[3].Name := 'Room sensor';
  DatasetTest[3].Device := DEV_ROOM_S;

  DatasetTest[4].Name := 'Manager';
  DatasetTest[4].Device := DEV_MANAGER;

  DatasetTest[5].Name := 'Heating';
  DatasetTest[5].Device := DEV_HEATING;

  DatasetTest[6].Name := 'Mixer';
  DatasetTest[6].Device := DEV_MIXER;

  DatasetTest[7].Name := 'Foreign';
  DatasetTest[7].Device := DEV_FOREIGN;

  DatasetTest[8].Name := 'DCF';
  DatasetTest[8].Device := DEV_DCF_CLK;
(*
  DatasetTest[0].Name := 'Direct';
  DatasetTest[0].Device := DEV_DIRECT;
  
  DatasetTest[7].Name := 'Bus coupler';
  DatasetTest[7].Device := DEV_BUS_CPL;

  DatasetTest[9].Name := 'Optical/PC';
  DatasetTest[9].Device := DEV_OPT_PC;
*)

  DevGrid.RowCount := Length(DatasetTest)+1;
  
  for r := 0 to DevGrid.RowCount-1 do
    DevGrid.RowHeights[r] := 20;
  for c := 0 to DevGrid.ColCount-1 do
    DevGrid.ColWidths[c] := 20;


  DevGrid.ColWidths[0] := 100;
  DevGrid.RowHeights[0] := 20;

  for c := 1 to DevGrid.ColCount-1 do
    DevGrid.Cells[c, 0] := IntToHex(c-1, 1);
  for r := 1 to DevGrid.RowCount-1 do
    DevGrid.Cells[0, r] := DatasetTest[r-1].Name;
  
end;

procedure TFormTest.FormDestroy(Sender: TObject);
begin
  SetLength(DatasetTest, 0);
end;

procedure TFormTest.FormShow(Sender: TObject);
begin
  cbDebug.Checked := PrintDebugMsg;
end;

procedure TFormTest.SaveToFile(Name : string);
var
  FN2 : string;
  F: TextFile;
  T : TDateTime;
  DateFormat : TFormatSettings;
  
begin
  mm1.Lines.Add('Writting file...');
  T := now();
  DateFormat.DateSeparator := '-';
  DateFormat.TimeSeparator := '-';
  DateFormat.ShortDateFormat := 'YYYYMMDDHHMM';
  DateFormat.LongDateFormat  := 'YYYYMMDDHHMM';

  FN2 := Name + '_' + DateTimeToStr(T, DateFormat) + '.csv';
  FN2 := TrimSp(FN2);
  mm1.Lines.Add(FN2);
  
  AssignFile(F, FN2);
  if not FileExists(FN2) 
  then
    begin
    Rewrite(F);
    end
  else
    begin
    Append(F);
    end; 

  Writeln(F, mm1.text);    
  CloseFile(F);
  mm1.Lines.Add('Finished.');
end;



end.
