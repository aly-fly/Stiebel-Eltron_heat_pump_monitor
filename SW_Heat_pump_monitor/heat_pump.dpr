program heat_pump;

uses
  Vcl.Forms,
  heat_pump_main in 'heat_pump_main.pas' {Form1},
  Serial_comm in 'Serial_comm.pas',
  Orodja in 'Orodja.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
