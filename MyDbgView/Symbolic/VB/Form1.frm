VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form Form1 
   Caption         =   "符号链接查看器		Visual Basic"
   ClientHeight    =   4200
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7290
   LinkTopic       =   "Form1"
   ScaleHeight     =   4200
   ScaleWidth      =   7290
   StartUpPosition =   2  '屏幕中心
   Begin VB.CommandButton Command2 
      Caption         =   "刷新"
      Height          =   405
      Left            =   4380
      TabIndex        =   3
      Top             =   3660
      Width           =   1245
   End
   Begin VB.CommandButton Command1 
      Cancel          =   -1  'True
      Caption         =   "确定"
      Height          =   405
      Left            =   5790
      TabIndex        =   2
      Top             =   3660
      Width           =   1245
   End
   Begin MSComctlLib.ListView ListView1 
      Height          =   3495
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   7275
      _ExtentX        =   12832
      _ExtentY        =   6165
      View            =   3
      LabelEdit       =   1
      Sorted          =   -1  'True
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   2
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "符号链接"
         Object.Width           =   6271
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "设备名"
         Object.Width           =   6271
      EndProperty
   End
   Begin VB.Label Label1 
      BackStyle       =   0  'Transparent
      Caption         =   "By:Leaf QQ:958570606"
      Height          =   345
      Left            =   360
      TabIndex        =   1
      Top             =   3720
      Width           =   2655
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Declare Function QueryDosDevice Lib "kernel32" Alias "QueryDosDeviceA" (lpDeviceName As Long, lpTargetPath As Long, ByVal ucchMax As Long) As Long
Private Declare Function QueryDosDevice_ Lib "kernel32" Alias "QueryDosDeviceA" (lpDeviceName As String, lpTargetPath As Long, ByVal ucchMax As Long) As Long

Private Sub Command1_Click()
     End
End Sub

Private Sub Command2_Click()
On Error Resume Next
Dim DeviceName(32768) As Byte
Dim TmpStr As String * 32768
Dim TargetPath(260) As Byte
Dim StrArr() As String
Dim i As Long
Dim ListNode As ListItem

ListView1.ListItems.Clear
If (QueryDosDevice(ByVal 0, ByVal VarPtr(DeviceName(0)), 32768) = 0) Then
     Exit Sub
End If
Addr = VarPtr(DeviceName(0))
TmpStr = StrConv(DeviceName, vbUnicode)
StrArr = Split(TmpStr, Chr(0), , vbBinaryCompare)
For i = 0 To UBound(StrArr)
     If (Len(StrArr(i)) <= 0) Then Exit For
     Set ListNode = ListView1.ListItems.Add
     ListNode.Text = StrArr(i)
     QueryDosDevice_ ByVal StrArr(i), ByVal VarPtr(TargetPath(0)), 260
     ListNode.SubItems(1) = StrConv(TargetPath, vbUnicode)
Next
End Sub

Private Sub Form_Load()
     Command2_Click
End Sub
