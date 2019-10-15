// VC.cpp : Defines the entry point for the application.
//

#define LVM_INSERTCOLUMN 0x1000+27

#include "stdafx.h"
#include "resource.h"

HWND ListView,ButtonWnd[3];

BOOL CALLBACK DialogProc(
						 HWND hwndDlg,  // handle to dialog box
						 UINT uMsg,     // message
						 WPARAM wParam, // first message parameter
						 LPARAM lParam  // second message parameter
						 );

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
	InitCommonControls();
	DialogBox(hInstance,MAKEINTRESOURCE(IDD_DIALOG1),GetDesktopWindow(),DialogProc);
	return 0;
}

int InsertListView(HWND ListViewHwnd,LPSTR lpText)
{
	LVITEM Item;
	Item.iItem=0;
	Item.mask=LVIF_TEXT;
	Item.pszText=lpText;
	Item.iSubItem=0;
	return SendMessage(ListView, LVM_INSERTITEM, 0, (LPARAM)&Item);
}

BOOL CALLBACK DialogProc(
						 HWND hwndDlg,  // handle to dialog box
						 UINT uMsg,     // message
						 WPARAM wParam, // first message parameter
						 LPARAM lParam  // second message parameter
						 )
{
	switch (uMsg)
	{
	case WM_INITDIALOG:
		{
			LVCOLUMN col;
			DWORD OldStyle;

			col.mask=LVCF_TEXT|LVCF_WIDTH;
			col.pszText="符号链接名";col.cx=250;
			col.iSubItem=0;
			ButtonWnd[0]=GetDlgItem(hwndDlg,IDOK);
			ButtonWnd[1]=GetDlgItem(hwndDlg,IDC_REFUSE);
			ButtonWnd[2]=GetDlgItem(hwndDlg,IDC_STATICBY);
			ListView=GetDlgItem(hwndDlg,IDC_LIST1);

			SendMessage(ListView,LVM_INSERTCOLUMN,0,(LPARAM)&col);
			col.pszText="设备名";col.cx=250;
			col.iSubItem=1;
			SendMessage(ListView,LVM_INSERTCOLUMN,1,(LPARAM)&col);
			OldStyle=SendMessage(ListView,LVM_GETEXTENDEDLISTVIEWSTYLE,0,0);
			SendMessage(ListView,LVM_SETEXTENDEDLISTVIEWSTYLE,0,OldStyle|LVS_EX_FULLROWSELECT);
			SendMessage(hwndDlg,WM_COMMAND,IDC_REFUSE,0);
			return TRUE;
		}
	case WM_COMMAND:
		{
			if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL) 
			{
				EndDialog(hwndDlg, LOWORD(wParam));
				return TRUE;
			}
			switch (wParam)
			{
			case IDC_REFUSE:
			{
				SendMessage(ListView, LVM_DELETEALLITEMS, 0, 0);
				char TargetPath[0x8000]={0};
				if(QueryDosDevice(NULL,TargetPath,0x8000)!=0)
				{
				char* tmpch=TargetPath;
				char TargetPath1[MAX_PATH]={0};
				int tmpLen=0;
				LVITEM ItemTxt;
				while (TRUE)
				{
					tmpch=PCHAR(int(tmpch)+tmpLen);
					int i=InsertListView(ListView,tmpch);
					if(QueryDosDevice(tmpch,TargetPath1,0x8000))
					{
						ItemTxt.iItem=0;
						ItemTxt.iSubItem=1;
						ItemTxt.mask=LVIF_TEXT;
						ItemTxt.pszText=PCHAR(TargetPath1);
						ItemTxt.cchTextMax=strlen(TargetPath1);
						SendMessageA(ListView,LVM_SETITEMTEXT,i,(LPARAM)&ItemTxt);
					}
					tmpLen=strlen(tmpch);
					if(tmpLen<=0) break;
					tmpLen+=1;
					}
					SendMessage(ListView,LVM_DELETEITEM,0,0);
				}
			}
			return TRUE;
		}
	}		
	case WM_DESTROY:
		{
			PostQuitMessage(0);
			break;
		} 	
	case WM_SIZE:
		{
			int ListHeight=HIWORD(lParam)-51;
			RECT rt1,rt2;
			int Col1Width;
			MoveWindow(ListView,0,0,LOWORD(lParam),ListHeight,TRUE);
			GetWindowRect(ListView,&rt1);
			GetWindowRect(ButtonWnd[0],&rt2);
			MoveWindow(ButtonWnd[0],rt1.right-rt1.left-85,ListHeight+15,rt2.right-rt2.left,rt2.bottom-rt2.top,TRUE);
			GetWindowRect(ButtonWnd[1],&rt2);
			MoveWindow(ButtonWnd[1],rt1.right-rt1.left-175,ListHeight+15,rt2.right-rt2.left,rt2.bottom-rt2.top,TRUE);
			GetWindowRect(ButtonWnd[2],&rt2);
			MoveWindow(ButtonWnd[2],rt2.left-rt1.left,ListHeight+20,rt2.right-rt2.left,rt2.bottom-rt2.top,TRUE);
			Col1Width=SendMessage(ListView,LVM_GETCOLUMNWIDTH,0,0);
			SendMessage(ListView,LVM_SETCOLUMNWIDTH,1,rt1.right-rt1.left-Col1Width-20);
			break;
		}
	}
	return FALSE;
	
}