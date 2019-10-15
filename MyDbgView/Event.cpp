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
	bIsWait=true;//����������ĺ�����ʱ���̻߳���� �����¼������õ�ʱ�򷵻�
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
			//ȱʡ
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
			KeResetEvent(&OEvent);//�����¼�
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