unit SysLoad;

interface

uses
  Windows,WinSvc,SysUtils,Registry;

type
  TSysLoad=class(TObject)
  function Load(strFileName:String;strServerName:PChar;var strError:String):BOOL;
  function Start(var strError:String):BOOL;
  function Stop(var strError:String):BOOL;
  function Delete(var strError:String):BOOL;
  procedure Close;
  procedure LoadMySys(mHwnd:HWND;const sSysPath:string);
  private
  function GetErrorStr():string;

  public


  end;
  
var
  SysCtrl:TSysLoad;
  MySysCtrl:TSysLoad;
  hSCM,hService:THandle;
const
  ERROR_NOOPENSERVICE='没有打开驱动。';
  
implementation

procedure TSysLoad.LoadMySys(mHwnd:HWND;const sSysPath:string);
var
  tmpError:String;
  tmpReg:TRegistry;
begin
  if(MySysCtrl.Load(sSysPath,'Hanf_DbgV',tmpError))then//如果服务已经存在则打开服务
  begin
    MySysCtrl.Start(tmpError); //如果已经运行就不管它
    DeleteFile(sSysPath);
    MySysCtrl.Close;
    tmpReg:=TRegistry.Create;
    try
      tmpReg.RootKey:=HKEY_LOCAL_MACHINE;
      tmpReg.DeleteKey('\SYSTEM\ControlSet001\Services\Hanf_DbgV');
    finally
     if(tmpReg<>nil) then tmpReg.Free;
    end;
  end else begin MessageBox(mHwnd,PChar(tmpError),'提示',MB_ICONWARNING); end;
end;

function TSysLoad.GetErrorStr():string;
begin
  Result:='错误代码:0x'+IntToHex(GetLastError,8)+'。';
  case (GetLastError) of
    $430:Result:='服务之前已经被删除了。';
    $426:Result:='服务还没启动。';
    $420:Result:='服务正在运行中。';
    $6  :Result:=ERROR_NOOPENSERVICE;//'没有打开驱动。'
    $2  :Result:='没有这个文件，或文件被其他程序独占。';
    $7d1:Result:='无效的驱动文件。';
    $425:Result:='服务无法在此时接受控制信息。'
  end;

end;
procedure TSysLoad.Close;
begin
  CloseServiceHandle(hService);
  CloseServiceHandle(hSCM);
end;

function TSysLoad.Load(strFileName:String;strServerName:PChar;var strError:String):BOOL;
begin
  strError:='';
  Result:=True;
  hSCM:=0; hService:=0;
  hSCM:=OpenSCManager(nil,nil,WinSvc.SC_MANAGER_ALL_ACCESS);
  if(INVALID_HANDLE_VALUE=hSCM)or(0=hSCM) then
  begin
    strError:='打开服务控制管理器失败！错误代码:0x'+IntToHex(GetLastError,8);
    Result:=False;
    strError:=GetErrorStr;
    Exit;
  end;
  hService:=CreateService(hSCM,strServerName,strServerName,
  SERVICE_ALL_ACCESS,SERVICE_KERNEL_DRIVER,SERVICE_DEMAND_START,SERVICE_ERROR_IGNORE,pchar(StrFileName)
  ,nil,nil,nil,nil,nil);

  if(GetLastError=ERROR_SERVICE_EXISTS)or(hService=0)or(INVALID_HANDLE_VALUE=hService) then
  begin
    hService:=OpenService(hSCM,strServerName,SERVICE_ALL_ACCESS);
  end;
  if(hService=0)or(INVALID_HANDLE_VALUE=hService) then
  begin
    strError:=GetErrorStr;
    Result:=False;
  end;
end;

function TSysLoad.Start(var strError:String):BOOL;
var
  tmpStr:PChar;
begin
  strError:='';
  if (hService=0)or(hService=INVALID_HANDLE_VALUE) then
  begin strError:=ERROR_NOOPENSERVICE; Result:=False; Exit; end;
  if(StartService(hService,0,tmpStr)=False) then
  begin
    Result:=False;
    strError:=GetErrorStr;
  end
  else begin
    Result:=True;
  end;
end;

function TSysLoad.Stop(var strError:String):BOOL;
var
  lSerSta:SERVICE_STATUS;
begin
  strError:='';
  Result:=True;
  if (hService=0)or(hService=INVALID_HANDLE_VALUE) then
  begin strError:=ERROR_NOOPENSERVICE; Result:=False; Exit; end;
  if(ControlService(hService,SERVICE_CONTROL_STOP,lSerSta)=False) then
  begin
    Result:=False;
    strError:=GetErrorStr;
  end;
end;

function TSysLoad.Delete(var strError:String):BOOL;
var
  tmpSta:SERVICE_STATUS;
begin
  strError:='';
  if (hService=0)or(hService=INVALID_HANDLE_VALUE) then
  begin strError:=ERROR_NOOPENSERVICE; Result:=False; Exit; end;
  if(QueryServiceStatus(hService,tmpSta)) then
  begin
    if(tmpSta.dwCurrentState=SERVICE_STOPPED) then
    begin
      if(DeleteService(hService)=False) then
      begin
        Result:=False;
        strError:=GetErrorStr;
      end else begin
        Result:=True;
        Close;
      end;
    end else
    begin
      Result:=False;
      strError:='请先停止驱动服务！';
    end;
  end else
  begin
    Result:=False;strError:=GetErrorStr;
  end;
end;
end.

