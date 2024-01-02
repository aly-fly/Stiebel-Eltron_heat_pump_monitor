unit window_energy;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls, heat_pump_comm;

type
  TFormEnergy = class(TForm)
    btnReadEnergyData: TButton;
    GridEnergy: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure btnReadEnergyDataClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    BeforeReading: procedure;
    AfterReading: procedure;
  end;

var
  FormEnergy: TFormEnergy;
  Data : TAHPdata;

implementation

{$R *.dfm}

procedure dummy();
begin
end;

procedure TFormEnergy.btnReadEnergyDataClick(Sender: TObject);
var
  col, row : Integer;
  i : Integer;
  
begin
  BeforeReading();
(*
A	0	'091A'	 EL_AFNAHMELEISTUNG_WW_TAG_WH	976
A	0	'091B'	 EL_AFNAHMELEISTUNG_WW_TAG_KWH	0
A	0	'091C'	 EL_AFNAHMELEISTUNG_WW_SUM_KWH	404
A	0	'091D'	 EL_AFNAHMELEISTUNG_WW_SUM_MWH	1
A	0	'091E'	 EL_AUFNAHMELEISTUNG_HEIZ_TAG_WH	78
A	0	'091F'	 EL_AFNAHMELEISTUNG_HEIZ_TAG_KWH	9
A	0	'0920'	 EL_AUFNAHMELEISTUNG_HEIZ_SUM_KWH	661
A	0	'0921'	 EL_AFNAHMELEISTUNG_HEIZ_SUM_MWH	37
A	0	'0922'	 WAERMEERTRAG_2WE_WW_TAG_WH	807
A	0	'0923'	 WAERMEERTRAG_2WE_WW_TAG_KWH	0
A	0	'0924'	 WAERMEERTRAG_2WE_WW_SUM_KWH	117
A	0	'0925'	 WAERMEERTRAG_2WE_WW_SUM_MWH	0
A	0	'0926'	 WAERMEERTRAG_2WE_HEIZ_TAG_WH	715
A	0	'0927'	 WAERMEERTRAG_2WE_HEIZ_TAG_KWH	0
A	0	'0928'	 WAERMEERTRAG_2WE_HEIZ_SUM_KWH	499
A	0	'0929'	 WAERMEERTRAG_2WE_HEIZ_SUM_MWH	2
A	0	'092A'	 WAERMEERTRAG_WW_TAG_WH	367
A	0	'092B'	 WAERMEERTRAG_WW_TAG_KWH	1
A	0	'092C'	 WAERMEERTRAG_WW_SUM_KWH	829
A	0	'092D'	 WAERMEERTRAG_WW_SUM_MWH	10
A	0	'092E'	 WAERMEERTRAG_HEIZ_TAG_WH	361
A	0	'092F'	 WAERMEERTRAG_HEIZ_TAG_KWH	76
A	0	'0930'	 WAERMEERTRAG_HEIZ_SUM_KWH	757
A	0	'0931'	 WAERMEERTRAG_HEIZ_SUM_MWH	259
*)

  SetLength(Data, 2);
  Data[0].Device := DEV_HEATING;
  Data[0].Circuit := 0;
  Data[0].Scaling := 1/1000;

  Data[1].Device := DEV_HEATING;
  Data[1].Circuit := 0;
  Data[1].Scaling := 1;

  for i := 0 to 11 do
    begin
    col := (i DIV 4) + 1;
    row := (i MOD 4) + 1;
    Data[0].RegAddr := $091A + (i * 2); 
    Data[1].RegAddr := Data[0].RegAddr +1;
    if HPCommRead(Data, 0, False) then
      if HPCommRead(Data, 1, False) then
        GridEnergy.Cells[col, row] := floattostrf(data[0].Value + data[1].Value, fffixed, 5, 3);  
    end;

  AfterReading();    
end;

procedure TFormEnergy.FormCreate(Sender: TObject);
begin
  // functions are not defined yet. Main wrapper may divert those pointers to some actual procedures.
  BeforeReading := dummy;
  AfterReading := dummy;

  GridEnergy.Cells[1, 0] := 'Electric grid';
  GridEnergy.Cells[2, 0] := 'Heater';
  GridEnergy.Cells[3, 0] := 'Produced output';

  GridEnergy.Cells[0, 1] := 'Water daily kWh';
  GridEnergy.Cells[0, 2] := 'Water total MWh';
  
  GridEnergy.Cells[0, 3] := 'Heating daily kWh';
  GridEnergy.Cells[0, 4] := 'Heating total MWh';  
end;

procedure TFormEnergy.FormDestroy(Sender: TObject);
begin
  SetLength(Data, 0);
end;

end.
