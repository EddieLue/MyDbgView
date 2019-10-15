#ifndef _STDTEMP
#define _STDTEMP
extern "C"
{
	#include <ntddk.h>
};

void CreateDevice(PDRIVER_OBJECT DriverObject);
NTSTATUS SioctlCreateClose(PDEVICE_OBJECT DeviceObject,PIRP Irp);
NTSTATUS SioctlDeviceControl(PDEVICE_OBJECT DeviceObject,PIRP Irp);

#define NT_DEVICE_NAME      L"\\Device\\HanfDbgViewNT"
#define DOS_DEVICE_NAME     L"\\DosDevices\\hanfDbgView001"

#define GET_CTL_CODE(Code)  (CTL_CODE(FILE_DEVICE_UNKNOWN,Code,METHOD_BUFFERED,FILE_ANY_ACCESS))

#define CODE_WAITEVENT GET_CTL_CODE(0x802)
#define CODE_STARTHOOK GET_CTL_CODE(0x803)
#define CODE_CLEARHOOK GET_CTL_CODE(0x804)
#define CODE_ISHOOKED  GET_CTL_CODE(0x805)

#define COMMAND_NULL 0
#define COMMAND_SET 1
#define COMMAND_HOOKSUCCESSFUL 2
#define COMMAND_NOSELFHOOK 3
#define COMMAND_ISSELFHOOK 4
#define COMMAND_NOHOOK 5

#pragma pack(push)
#pragma pack(1)
struct _DBGINFO
{
	int iCommand;
	TIME_FIELDS sysTime;
	ANSI_STRING strInfo;
};
struct _SYSDATA
{
	int iCommand;
	TIME_FIELDS sysTime;
	int iLength;
	CHAR cBuffer[1024*2];
};
#pragma pack(pop)

extern void EventInitial();
extern NTSTATUS EventWait(_SYSDATA *pDbgInfo);
extern void EventSet(_DBGINFO* pDbgInfo);

extern int StartHook();
extern void ClearHook();
extern BOOLEAN IsHooked(BOOLEAN CompareSelf);

typedef NTSTATUS __stdcall _VDBGPRINTCALL(PANSI_STRING Prarm1,int prarm2,int prarm3);

#endif