unit Ctrl;

interface

uses
  Windows,WinSvc,IniFiles;
{$A1}
type
  _TIME_FIELDS=record
    Year:Word;        // range [1601...]//年
    Month:Word;       // range [1..12]//月
    Day:Word;         // range [1..31]//天
    Hour:Word;        // range [0..23]//小时
    Minute:Word;      // range [0..59]//分钟
    Second:Word;      // range [0..59]//秒
    Milliseconds:Word;// range [0..999]//毫秒
    Weekday:Word;     // range [0..6] == [Sunday..Saturday]//星期天到星期六
  end;
type
  _SYSDATA=record
    iCommand:Integer;
    sysTime:_TIME_FIELDS;
    iLength:Integer;
    DbgStr:array[0..1024*2] of Char;
  end;

{$A4}
type
  TSysCtrl=class(TObject)
  procedure AnjustPrivilegesToDebug();
  function ConnectDevice():BOOL;
  function DisConnect():BOOL;
  function CTL_CODE(DeviceType,FuncCode, Method, Access:Integer):Integer;
  function ControlDevice(IoCtrlCode:Integer;VAR OutBuffer:_SYSDATA):BOOL;

  procedure Ini_Create(const sFileName:String);
  private

  public

  end;
const
  CODE_ISHOOKED=$805;
  CODE_CLEARHOOK=$804;
  CODE_STARTHOOK=$803;
  CODE_WAITEVENT=$802;
  COMMAND_NULL=0;
  COMMAND_SET=1;
  COMMAND_HOOKSUCCESSFUL=2;
  COMMAND_NOSELFHOOK=3;
  COMMAND_ISSELFHOOK=4;
  COMMAND_NOHOOK=5;
var
  DeviceCtrl:TSysCtrl;
  SysIni:TIniFile;
  hDevice:THandle;
implementation

procedure TSysCtrl.Ini_Create(const sFileName:String);
begin                   
  SysIni:=TIniFile.Create(sFileName);
end;

procedure TSysCtrl.AnjustPrivilegesToDebug();
var
  hToken:THandle;
  tkp:_TOKEN_PRIVILEGES;
  iRet:DWORD;
  tkps:TTokenPrivileges;
begin
	OpenProcessToken(Cardinal(-1),TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,hToken);
	LookupPrivilegeValue(nil,'SeDebugPrivilege',tkp.Privileges[0].Luid);
	tkp.PrivilegeCount:=1;
	tkp.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED ;
	AdjustTokenPrivileges(hToken,False,tkp,sizeof(_TOKEN_PRIVILEGES),tkps,iRet);
	CloseHandle(hToken);
end;

function TSysCtrl.ConnectDevice():BOOL;
begin
  hDevice:=0;
  hDevice:=CreateFile('\\.\hanfDbgView001',GENERIC_READ or GENERIC_WRITE,0,nil
						,OPEN_EXISTING,0,0);
Result:=(hDevice<>INVALID_HANDLE_VALUE)and(hDevice>0);
end;
function TSysCtrl.DisConnect():BOOL;
begin
  Result:=CloseHandle(hDevice);
  hDevice:=0;
end;

function TSysCtrl.CTL_CODE(DeviceType,FuncCode, Method, Access:Integer):Integer;
begin
  Result:=(DeviceType shl 16) or (Access shl 14) or (FuncCode shl 2) or (Method);
end;

function TSysCtrl.ControlDevice(IoCtrlCode:Integer;VAR OutBuffer:_SYSDATA):BOOL;
var
  Bytes:DWORD;
  InBufd:_SYSDATA;
begin
  ZeroMemory(@outbuffer,SizeOf(outbuffer));
  Result:=DeviceIoControl(hDevice,CTL_CODE($22,IoCtrlCode,0,0),@InBufd,4,@outbuffer,SizeOf(OutBuffer),Bytes,nil);
end;
end.