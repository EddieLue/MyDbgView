#include "StdTemp.h"

PCHAR GetHookAddress();

_VDBGPRINTCALL *DbgPrintCall;
CHAR cOldCode[5];

NTSTATUS __stdcall DbgPrintHookFunc(PANSI_STRING Prarm1,int prarm2,int prarm3)
{
	//__asm int 3
	LARGE_INTEGER CurTime;
	TIME_FIELDS tmpTime;
	KeQuerySystemTime(&CurTime);
	RtlTimeToTimeFields(&CurTime,&tmpTime);
	ClearHook();
	_DBGINFO DbgInfo;
	DbgInfo.iCommand=COMMAND_SET;
	DbgInfo.strInfo=*Prarm1;
	DbgInfo.sysTime=tmpTime;
	EventSet(&DbgInfo); //没有初始化事件 会蓝屏
	NTSTATUS RetValue=DbgPrintCall(Prarm1,prarm2,prarm3);
	StartHook();
	return RetValue;
}

int StartHook()
{
	if(IsHooked(true))//是否被自己HOOK
	{
		return COMMAND_HOOKSUCCESSFUL;	
	}
	if(IsHooked(false))	//是否被其他程序HOOK
	{
		return COMMAND_NOSELFHOOK;
	}

	PCHAR hookAddr=GetHookAddress();
	if(hookAddr==PCHAR(-1)) return COMMAND_NULL; 
	memmove(&cOldCode,hookAddr,5);
 	*hookAddr=(CHAR)0xE9;
 	*(PLONG)((LONG)hookAddr+1)=LONG(&DbgPrintHookFunc)-(LONG)hookAddr-5;
	DbgPrintCall=(_VDBGPRINTCALL *)hookAddr;
	return COMMAND_HOOKSUCCESSFUL;
}
void ClearHook()
{

	PCHAR hookAddr=GetHookAddress();
	if(hookAddr==PCHAR(-1)) return; 
	//判断是否已被自己HOOK
	if(IsHooked(true))
	{
		memmove(hookAddr,&cOldCode,5);//还原头五字节
	}
}

PCHAR GetHookAddress()//获取指向要HOOK的地址
{
	LONG CallAddr=LONG(&vDbgPrintExWithPrefix)+0xfc;
 	LONG hookOffset=*(LONG *)(CallAddr+0x1);
 	PCHAR hookAddr=(PCHAR)CallAddr+hookOffset+5;
	if(!MmIsAddressValid((PVOID)hookAddr))
	{
		hookAddr=PCHAR(-1);
	}
	return hookAddr;
}

BOOLEAN IsHooked(BOOLEAN CompareSelf)
{
	PCHAR hookAddr=GetHookAddress();
	char tmpvar;
	if(hookAddr==PCHAR(-1)){return true; }
	if(!CompareSelf)
	{
		tmpvar=*hookAddr;
	
		if(*hookAddr!=(CHAR)0x8b) 
		{
			return true;//被其它程序HOOK了
		}else
		{
			return false;
		}
	}

	if(*hookAddr==(CHAR)0xe9)
	{
		if(*(PLONG)((LONG)hookAddr+1)==LONG(&DbgPrintHookFunc)-(LONG)hookAddr-5) 
		{
			if(DbgPrintCall!=NULL)
			{
				return true;//被自己HOOK了
			}
		}
	}
	return false;
}