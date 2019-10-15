#include "StdTemp.h"

#pragma code_seg("PAGE")

void UnloadDriver(PDRIVER_OBJECT pDriverObj)
{
	PDEVICE_OBJECT deviceObject = pDriverObj->DeviceObject;
    UNICODE_STRING uniWin32NameString;
    RtlInitUnicodeString( &uniWin32NameString, DOS_DEVICE_NAME );
    IoDeleteSymbolicLink( &uniWin32NameString );

    if ( deviceObject != NULL )
    {
        IoDeleteDevice( deviceObject );
    }
	ClearHook();
}
#pragma code_seg()
#pragma code_seg("INIT")
extern "C" NTSTATUS DriverEntry(PDRIVER_OBJECT pDriverObj,PUNICODE_STRING pRegisterPath )
{
	pDriverObj->DriverUnload=UnloadDriver;
	CreateDevice(pDriverObj);
	
	EventInitial();
	return STATUS_SUCCESS;
}
void CreateDevice(PDRIVER_OBJECT DriverObject)
{
	NTSTATUS        ntStatus;
    UNICODE_STRING  ntUnicodeString;    // NT Device Name
    UNICODE_STRING  ntWin32NameString;    // Win32 Name
    PDEVICE_OBJECT  deviceObject = NULL;    // ptr to device object


    RtlInitUnicodeString( &ntUnicodeString, NT_DEVICE_NAME );

    ntStatus = IoCreateDevice(
        DriverObject,                   // Our Driver Object
        0,                              // We don't use a device extension
        &ntUnicodeString,               // Device name 
        FILE_DEVICE_UNKNOWN,            // Device type
        FILE_DEVICE_SECURE_OPEN,     // Device characteristics
        FALSE,                          // Not an exclusive device
        &deviceObject);                // Returned ptr to Device Object

    if ( !NT_SUCCESS( ntStatus ) )
    {
        KdPrint(("Couldn't create the device object\n"));
        return ;
    }
	
    DriverObject->MajorFunction[IRP_MJ_CREATE] =
	DriverObject->MajorFunction[IRP_MJ_CLOSE] = SioctlCreateClose;
    DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = SioctlDeviceControl;
 
    RtlInitUnicodeString(&ntWin32NameString, DOS_DEVICE_NAME);

	deviceObject->Flags|=DO_BUFFERED_IO;
	
    ntStatus = IoCreateSymbolicLink(&ntWin32NameString,&ntUnicodeString);

    if ( !NT_SUCCESS( ntStatus ) )
    {
        KdPrint(("Couldn't create symbolic link\n"));
        IoDeleteDevice( deviceObject );
    }
    return ;
}
#pragma code_seg()
#pragma code_seg("PAGE")
NTSTATUS SioctlCreateClose(PDEVICE_OBJECT DeviceObject,PIRP Irp)
{
    Irp->IoStatus.Status = STATUS_SUCCESS;
    Irp->IoStatus.Information = 0;

    IoCompleteRequest( Irp, IO_NO_INCREMENT );
    return STATUS_SUCCESS;
}


NTSTATUS SioctlDeviceControl(PDEVICE_OBJECT DeviceObject,PIRP Irp)
{
	_SYSDATA * InOutBuf = (_SYSDATA *)Irp->AssociatedIrp.SystemBuffer;
    PIO_STACK_LOCATION irpSp = IoGetCurrentIrpStackLocation( Irp );
    ULONG inBufLength  = irpSp->Parameters.DeviceIoControl.InputBufferLength;
    ULONG outBufLength = irpSp->Parameters.DeviceIoControl.OutputBufferLength;
	ULONG IoControlCode= irpSp->Parameters.DeviceIoControl.IoControlCode;
	switch(IoControlCode)
	{
	case CODE_WAITEVENT:
		{
			EventWait(InOutBuf);
			break;
		}
	case CODE_STARTHOOK:
		{
			InOutBuf->iCommand=StartHook();
			break;
		}
	case CODE_CLEARHOOK:
		{
			_DBGINFO DbgInfo;
			DbgInfo.iCommand=0;
			EventSet(&DbgInfo);
			ClearHook();
			break;
		}
	case CODE_ISHOOKED:
		{
			InOutBuf->iCommand=COMMAND_NOHOOK;
			if(IsHooked(false))
			{
				InOutBuf->iCommand=COMMAND_NOSELFHOOK;
			}else if(IsHooked(true))
			{
				InOutBuf->iCommand=COMMAND_ISSELFHOOK;
			}
		}
	}
    Irp->IoStatus.Status = STATUS_SUCCESS;
    Irp->IoStatus.Information =outBufLength;
    IoCompleteRequest( Irp, IO_NO_INCREMENT );
    return STATUS_SUCCESS;
}
#pragma code_seg()