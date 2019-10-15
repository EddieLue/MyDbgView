program DbgView;

{$R 'SysDdata.res' 'SysDdata.rc'}

uses
  Forms,Windows,
  form in 'form.pas';
{$R *.res}
var
  hMutex:THandle;
begin
  hMutex:=CreateMutex(nil,False,'HanfDbgView_Mutex');
  if(GetLastError<>ERROR_ALREADY_EXISTS) then
  begin
    Application.Initialize;
    Application.Title := 'DbgView';
    Application.CreateForm(Tform_main, form_main);
    Application.Run;
    ReleaseMutex(hMutex);
    CloseHandle(hMutex);
    Exit;
  end;
  Application.MessageBox('另一个 DbgView 实例已经在运行了！','提示',MB_ICONASTERISK);
end.
