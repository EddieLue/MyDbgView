#include "StdTemp.h"

KEVENT OEvent;
BOOLEAN bIsInitial,bIsWait;
_DBGINFO DbgInfo;
_SYSDATA SysData;

void EventInitial()
{
	DbgInfo.iCommand=0;
	bIsWait=false;
	KeInitializeEvent(&OEvent,SynchronizationEvent,FALSE);
	bIsInitial=true;
}
NTSTATUS EventWait(_SYSDATA *pDbgInfo)
{
	bIsWait=true;//当调用下面的函数的时候线程会堵塞 当有事件被设置的时候返回
	NTSTATUS RetValue=KeWaitForSingleObject(&OEvent,Executive,UserMode,false,0);
	if(RetValue!=STATUS_SUCCESS)
	{
		bIsWait=false;
	}
	SysData.iCommand=DbgInfo.iCommand;
		switch(DbgInfo.iCommand)
	{
		case COMMAND_NULL:
		{
			//缺省
			break;
		}
		case COMMAND_SET:
		{
			memset(&SysData.cBuffer,0,1024*2);
			SysData.iLength=DbgInfo.strInfo.Length+1;
			SysData.sysTime=DbgInfo.sysTime;
			memmove(&SysData.cBuffer,DbgInfo.strInfo.Buffer,SysData.iLength);
			memset(pDbgInfo->cBuffer,0,1024*2);
			*pDbgInfo=SysData;
			SysData.iLength=0;
			KeResetEvent(&OEvent);//重置事件
			break;
		}
	}
	DbgInfo.iCommand=0;
	return RetValue;
}

void EventSet(_DBGINFO* pDbgInfo)
{
	if(bIsInitial && bIsWait)
	{
		DbgInfo=*pDbgInfo;
		KeSetEvent(&OEvent,NULL,NULL);
	}
}