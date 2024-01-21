unit window_errors;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, heat_pump_comm, orodja, heat_pump_constants;

type
  TFormErrors = class(TForm)
    btnReadErr: TButton;
    GridErrors: TStringGrid;
    lblCountdown: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnReadErrClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Stop : Boolean;
  public
    BeforeReading: procedure;
    AfterReading: procedure;
    function ReadLastHPErrorTime : u16;
  end;

var
  FormErrors: TFormErrors;

implementation

{$R *.dfm}

procedure dummy();
begin
  // NOP.
end;

function TFormErrors.ReadLastHPErrorTime : u16;
var
  Data : TAHPdata;
  hh, mm : u16;
  
begin
  BeforeReading();
  Result := 0;
  
  SetLength(Data, 1);
  Data[0].Device := DEV_BOILER;
  Data[0].Circuit := 0;
  Data[0].Scaling := 1;
  
  // read newest / latest
  Data[0].RegAddr := $0B00 + ((19-0) * 7) + 0;  // minute
  if HPCommRead(Data, 0, False) then mm := data[0].Data;
  
  Data[0].RegAddr := $0B00 + ((19-0) * 7) + 1;  // hour
  if HPCommRead(Data, 0, False) then hh := data[0].Data;

  Result := ((hh shl 8) OR mm) AND $FFFF;

  // time
  GridErrors.Cells[2, 1] := LeadingZeros(hh, 2) + ':' + LeadingZeros(mm, 2);
  
  SetLength(Data, 0);   
  AfterReading();
end;

procedure TFormErrors.btnReadErrClick(Sender: TObject);
var
  Data : TAHPdata;
  ErrData : array[0..6] of word;
  Num, Field, i : Integer;
  s1, s2 : string;  

begin
  BeforeReading();
  Stop := False;
  Screen.Cursor := crHourGlass;
(*
  { "FEHLERFELD_0"                                     , 0x0b00, 0}, // Min
  { "FEHLERFELD_1"                                     , 0x0b01, 0}, // Std
  { "FEHLERFELD_2"                                     , 0x0b02, 0}, // Tag
  { "FEHLERFELD_3"                                     , 0x0b03, 0}, // Monat
  { "FEHLERFELD_4"                                     , 0x0b04, 0}, // Jahr
  { "FEHLERFELD_5"                                     , 0x0b05, et_dev_nr},
  { "FEHLERFELD_6"                                     , 0x0b06, et_err_nr},
  ....
  { "FEHLERFELD_133"                                   , 0x0b85, 0},
  { "FEHLERFELD_134"                                   , 0x0b86, 0},
  { "FEHLERFELD_135"                                   , 0x0b87, 0},
  { "FEHLERFELD_136"                                   , 0x0b88, 0},
  { "FEHLERFELD_137"                                   , 0x0b89, 0},
  { "FEHLERFELD_138"                                   , 0x0b8a, et_dev_nr},
  { "FEHLERFELD_139"                                   , 0x0b8b, et_err_nr}, 

    03 0 0B85 0032  50
    03 0 0B86 0008  8
    03 0 0B87 0015  21
    03 0 0B88 000C  12
    03 0 0B89 0017  23
    03 0 0B8A 0000  0
    03 0 0B8B 1FBE  8126  
*)


  SetLength(Data, 1);
  Data[0].Device := DEV_BOILER;
  Data[0].Circuit := 0;
  Data[0].Scaling := 1;
  
  for Num := 0 to 19 do
    begin
    // highlight currently read parameter
    GridErrors.Col := 5;
    GridErrors.Row := Num+1;
    
    for Field := 0 to 6 do
      begin
      Data[0].RegAddr := $0B00 + ((19-Num) * 7) + Field;  // read newest first (on top)

      if HPCommRead(Data, 0, False) then
        ErrData[Field] := data[0].Data;

      if Application.Terminated or Stop then
        begin
        Screen.Cursor := crDefault;
        exit; 
        end;
      end;
    // date  
    s1 := IntToStr(ErrData[2]) + '.' + IntToStr(ErrData[3]) + '.' + IntToStr(ErrData[4]+2000);
    GridErrors.Cells[1, Num+1] := s1;
    // time
    s1 := LeadingZeros(ErrData[1], 2) + ':' + LeadingZeros(ErrData[0], 2);
    GridErrors.Cells[2, Num+1] := s1;
(*
    // Device (always 0 --> ignore)
    s1 := IntToHex(ErrData[5], 4);
    GridErrors.Cells[3, Num+1] := s1;
*)  
    // Code
    s1 := IntToHex(ErrData[6], 4);
    GridErrors.Cells[3, Num+1] := s1;
    // Description
    s1 := '';
    for i := 1 to Length(cErrors) do
      begin
      if cErrors[i].number = ErrData[6] then
        begin
        s1 := cErrors[i].display;
        s2 := cErrors[i].descr;
        break;
        end;    
      end;
    
    GridErrors.Cells[4, Num+1] := s1;
    GridErrors.Cells[5, Num+1] := s2;
    end;

//  GridErrors.Col := 0;
//  GridErrors.Row := 0;

  SetLength(Data, 0);   
  AfterReading();
  Screen.Cursor := crDefault;
end;

procedure TFormErrors.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Stop := True;
  AfterReading();    
end;

procedure TFormErrors.FormCreate(Sender: TObject);
var
 i : Integer;
 
begin
  // functions are not defined yet. Main wrapper may divert those pointers to some actual procedures.
  BeforeReading := dummy;
  AfterReading := dummy;

  GridErrors.ColWidths[0] := 25; // number
  GridErrors.ColWidths[4] := 120; // display
  GridErrors.ColWidths[5] := 570; // description

  GridErrors.Cells[0, 0] := '#';
  GridErrors.Cells[1, 0] := 'Date';
  GridErrors.Cells[2, 0] := 'Time';
  GridErrors.Cells[3, 0] := 'Err code';
  GridErrors.Cells[4, 0] := 'Display';
  GridErrors.Cells[5, 0] := 'Error description';

  for i := 1 to 20 do
    GridErrors.Cells[0, i] := IntToStr(i);
end;

end.
