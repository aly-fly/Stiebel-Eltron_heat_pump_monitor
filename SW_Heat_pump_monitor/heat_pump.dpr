program heat_pump;

uses
  Vcl.Forms,
  heat_pump_main in 'heat_pump_main.pas' {FormHPmonitor},
  Serial_comm in 'Serial_comm.pas',
  Orodja in 'Orodja.pas',
  window_test in 'window_test.pas' {FormTest},
  heat_pump_comm in 'heat_pump_comm.pas',
  heat_pump_constants in 'heat_pump_constants.pas',
  window_energy in 'window_energy.pas' {FormEnergy},
  window_errors in 'window_errors.pas' {FormErrors};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormHPmonitor, FormHPmonitor);
  Application.CreateForm(TFormTest, FormTest);
  Application.CreateForm(TFormEnergy, FormEnergy);
  Application.CreateForm(TFormErrors, FormErrors);
  Application.Run;
end.
