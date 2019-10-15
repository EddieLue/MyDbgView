unit form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, Menus, ImgList, StdCtrls,SysLoad, ExtCtrls,Ctrl,
  ShellAPI,About,Registry;

type
  Tform_main = class(TForm)
    ListView1: TListView;
    MainMenu1: TMainMenu;
    F1: TMenuItem;
    N1: TMenuItem;
    S1: TMenuItem;
    H1: TMenuItem;
    O1: TMenuItem;
    N2: TMenuItem;
    E1: TMenuItem;
    N3: TMenuItem;
    R1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    F2: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N10: TMenuItem;
    A2: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    ImageList1: TImageList;
    N17: TMenuItem;
    StatusBar1: TStatusBar;
    N18: TMenuItem;
    N19: TMenuItem;
    Win321: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    FindDialog1: TFindDialog;
    Timer1: TTimer;
    N20: TMenuItem;
    N21: TMenuItem;
    ImageList2: TImageList;
    PopupMenu1: TPopupMenu;
    N8: TMenuItem;
    N9: TMenuItem;
    N22: TMenuItem;
    N11: TMenuItem;
    N15: TMenuItem;
    ToolBar1: TToolBar;
    Label1: TLabel;
    ToolButton1: TToolButton;
    ToolButton7: TToolButton;
    ToolButton2: TToolButton;
    ToolButton8: TToolButton;
    Label2: TLabel;
    ToolButton3: TToolButton;
    ToolButton_AutoSava: TToolButton;
    Label4: TLabel;
    ToolButton10_Start: TToolButton;
    Label3: TLabel;
    ToolButton6: TToolButton;
    ToolButton11_AutoScroll: TToolButton;
    ToolButton_Time: TToolButton;
    ToolButton14: TToolButton;
    ToolButton13: TToolButton;
    ToolButton_Top: TToolButton;
    ToolButton4: TToolButton;
    procedure E1Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure O1Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure ToolButton10_StartClick(Sender: TObject);
    procedure ToolButton_TimeClick(Sender: TObject);
    procedure ToolButton_AutoSavaClick(Sender: TObject);
    procedure ToolButton11_AutoScrollClick(Sender: TObject);
    procedure ListView1Insert(Sender: TObject; Item: TListItem);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N20Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure IconMessageFunc(var mMessage:TMessage); message WM_USER+10;
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure A2Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure F2Click(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure R1Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure ToolButton_TopClick(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
  private
    { Private declarations }
    procedure SaveListToFile();
    procedure Load_AddErrorStr(Asterisk:BOOL; error:string);
    function GetMsgTimeFormat(rUser:BOOL;curTime:_TIME_FIELDS):String;
    function FindListText(i:Integer;MatchCase:BOOL):BOOL;
    procedure AddStrToList(ImgIndex:Integer;sTime,sMsg:String);
    procedure CopyText(Str:String);
    function GetChineseTime(var tmpTime:_SYSTEMTIME):String;
  public
    { Public declarations }
  end;

var
  form_main: Tform_main;
  IsEndThread:BOOL;
  OldTime:Int64;
  IconNotify:NOTIFYICONDATAA;
  AutoSavePath:String;
implementation

uses IniFiles;

{$R *.dfm}
function Tform_main.GetChineseTime(var tmpTime:_SYSTEMTIME):String;//将格林威治时间转换到中国时间
begin
  if(tmpTime.wHour>=16) then
  begin
    tmpTime.wHour:=(tmpTime.wHour+8)-24;
  end else begin
    tmpTime.wHour:=tmpTime.wHour+8;
  end;
  Result:=IntToStr(tmpTime.wHour)+':'+IntToStr(tmpTime.wMinute)+':'+IntToStr(tmpTime.wSecond);
  if(N11.Checked)then Result:=Result+':'+IntToStr(tmpTime.wMilliseconds);
end;
procedure Tform_main.CopyText(Str:String);  //复制文本
var
  clipMem:Cardinal;
begin
   //Tlipboard
	OpenClipboard(0);
	EmptyClipboard;
	clipMem:=GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE or GMEM_ZEROINIT,Length(Str)+1);
	CopyMemory(GlobalLock(clipMem),PChar(Str+#0),Length(Str)+1);
	GlobalUnlock(clipMem);
	SetClipboardData(CF_TEXT,clipMem);
	GlobalFree(clipMem);
	CloseClipboard;
end;

function Tform_main.GetMsgTimeFormat(rUser:BOOL;curTime:_TIME_FIELDS):String;  //取格式时间
var
  curUserTime:_SYSTEMTIME;
  curMilliseconds:Int64;
  RetValue:string;
begin
  GetSystemTime(curUserTime);
  if(rUser=False)then
  begin
    curUserTime.wHour:=curTime.Hour;
    curUserTime.wMinute:=curTime.Minute;
    curUserTime.wSecond:=curTime.Second;
    curUserTime.wMilliseconds:=curTime.Milliseconds;
  end;
  RetValue:=GetChineseTime(curUserTime);
  curMilliseconds:=curUserTime.wHour*60*60*1000+curUserTime.wMinute*60*1000
    +curUserTime.wSecond*1000+curUserTime.wMilliseconds;
  case ToolButton_Time.ImageIndex of
    12:begin//时间
          Result:=RetValue;
          Exit;
       end;
    13:begin//秒（小数点）
          if(ListView1.Items.Count=0)then
          begin
            OldTime:=curMilliseconds;
            Result:='0.000';
            Exit;
          end;
          Result:=FloatToStrF((curMilliseconds-OldTime)/1000,ffFixed,10000,3);
       end;
  end;
end;
procedure Tform_main.AddStrToList(ImgIndex:Integer;sTime,sMsg:String);//添加字串到列表
var
  tml:TListItem;
  FileStre:TFileStream;
  tmpBuf:PChar;
  FileSize:Integer;
begin
  tml:=ListView1.Items.Add;
  tml.ImageIndex:=ImgIndex;
  tml.Caption:=IntToStr(tml.Index);
  tml.SubItems.Add(sTime);
  tml.SubItems.Add(sMsg);

  //自动保存：
 if(tml.SubItems.Count<1) then Exit;
  if(ToolButton_AutoSava.ImageIndex=18)then
  begin
   if(FileExists(AutoSavePath)or(StrLen(PChar(AutoSavePath))>0)) then
   begin
      FileStre:=TFileStream.Create(AutoSavePath,fmOpenWrite);
    try
      tmpBuf:=PChar(tml.Caption+' '+tml.SubItems.Strings[0]+' '+tml.SubItems.Strings[1]+#13#10);
      FileStre.Position:=FileStre.Size;
      FileSize:=StrLen(PChar(tmpBuf));
      FileStre.Write(tmpBuf^,FileSize);
    finally
     if(FileStre<>nil) then FileStre.Free;
    end;
   end;
  end;

end;
procedure Tform_main.Load_AddErrorStr(Asterisk:BOOL{是否叹号}; error:string);//添加错误信息
var
  MsgIcon,ImgIndex:Integer;
  NIMATime:_TIME_FIELDS;
begin
  if(N15.Checked) then
  begin
    Exit;
  end;
  if(Asterisk) then
  begin
    MsgIcon:=MB_ICONASTERISK;
    ImgIndex:=1;
  end else begin
    MsgIcon:=MB_ICONWARNING;
    ImgIndex:=0;
  end;
  if(N20.Checked) then
  begin
    Application.MessageBox(PChar(error),'提示',MsgIcon);
    Exit;
  end;
  AddStrToList(ImgIndex,GetMsgTimeFormat(True,NIMATime),'提示:'+error);
end;

procedure Tform_main.E1Click(Sender: TObject);       //结束
begin
  Application.Terminate;
end;

procedure Tform_main.ToolButton1Click(Sender: TObject);//加载服务
var
  error:string;
begin
  if(OpenDialog1.Execute) then
  begin
    SysCtrl.Close;
    if(SysCtrl.Load(OpenDialog1.FileName,PChar(ExtractFileName(OpenDialog1.FileName)),error)=False) then
    begin
      MessageBox(Handle,PChar(error),'提示',MB_ICONWARNING);
    end;
  end;
end;

procedure Tform_main.ToolButton7Click(Sender: TObject);   //开启服务
var
  error:string;
begin
  if(SysCtrl.Start(error)=False) then
  begin
  Load_AddErrorStr(False,error);
  end else
  begin
  Load_AddErrorStr(True,'驱动服务运行成功！');
  end;
end;

procedure Tform_main.ToolButton2Click(Sender: TObject);  //停止服务
var
  error:string;
begin
  if(SysCtrl.Stop(error)=False) then
  begin
  Load_AddErrorStr(False,error);
  end else
  begin
  Load_AddErrorStr(True,'驱动服务停止成功！');
  end;
end;

procedure Tform_main.ToolButton8Click(Sender: TObject);   //卸载服务
var
  error:string;
begin
  if(SysCtrl.Delete(error)=False) then
  begin
  Load_AddErrorStr(False,error);
  end else
  begin
    Load_AddErrorStr(True,'驱动服务删除成功！');
  end;
end;

procedure Tform_main.SaveListToFile();  //将列表中的内容保存到文件
var
  i:Integer;
  tmpStr:TStringList;
begin
  FileClose(FileCreate(SaveDialog1.FileName));//若文件存在 则创建失败
  if(ListView1.Items.Count<=0) then Exit;
  tmpStr:=TStringList.Create;
  try
    for i:=0 to ListView1.Items.Count-1 do
    begin
      tmpStr.Add(ListView1.Items.Item[i].Caption+' '+ListView1.Items.Item[i].SubItems.Strings[0]
      +' '+ListView1.Items.Item[i].SubItems.Strings[1]);
    end;
    tmpStr.SaveToFile(SaveDialog1.FileName);
  finally
    tmpStr.Free;
  end;
end;
procedure Tform_main.ToolButton3Click(Sender: TObject);  //保存
begin
  if(SaveDialog1.Execute) then SaveListToFile;
end;

procedure Tform_main.ToolButton6Click(Sender: TObject);  //清空显示
begin
   ListView1.Clear;
   StatusBar1.Panels.Items[2].Text:='数目:'+IntToStr(ListView1.Items.Count);
end;

procedure Tform_main.O1Click(Sender: TObject);   //菜单 打开驱动
begin
  ToolButton1Click(nil);
end;

procedure Tform_main.N2Click(Sender: TObject);   //菜单 保存信息
begin
  ToolButton3Click(nil);
end;

function WatchThread(tmp:Pointer):Integer;       //【监视线程】
var
  OutBuf:_SYSDATA;
  tempStr:String;
begin
  IsEndThread:=False;
  Result:=1;
  if(DeviceCtrl.ConnectDevice) then
  begin
    while(IsEndThread=False) do
    begin
      if(IsEndThread) then EndThread(1);
      if(DeviceCtrl.ControlDevice(CODE_WAITEVENT,OutBuf))  then
      begin
        if(OutBuf.iCommand=COMMAND_SET) then
        begin
          SetLength(tempStr,OutBuf.iLength);
          MoveMemory(PChar(tempStr),@OutBuf.DbgStr,OutBuf.iLength);
          form_main.AddStrToList(2,form_main.GetMsgTimeFormat(False,OutBuf.sysTime),tempStr);
          ZeroMemory(@OutBuf.DbgStr,1024*2);
          OutBuf.iCommand:=COMMAND_NULL;
          Continue;
        end else begin
           Break;
        end;
      end;
    end;
  end;
  DeviceCtrl.DisConnect;
  EndThread(0);
end;
procedure Tform_main.ToolButton10_StartClick(Sender: TObject);  //启动监视
var
  OutBuf:_SYSDATA;
  hTid:THandle;
begin
  if(DeviceCtrl.ConnectDevice) then
  begin
    case ToolButton10_Start.ImageIndex of
    4:begin     //取消
        if(DeviceCtrl.ControlDevice(CODE_CLEARHOOK,OutBuf)) then
        begin
          IsEndThread:=True;
          ToolButton10_Start.ImageIndex:=3;
          StatusBar1.Panels.Items[1].Text:='未启动监视';
        end;
      end;
    3:begin     //启动
        if(DeviceCtrl.ControlDevice(CODE_STARTHOOK,OutBuf)) then
        begin
          if(OutBuf.iCommand=COMMAND_HOOKSUCCESSFUL)then
          begin
            ToolButton10_Start.ImageIndex:=4;
            StatusBar1.Panels.Items[1].Text:='正在监视';
            BeginThread(nil,0,WatchThread,nil,0,hTid);
          end else begin
            Load_AddErrorStr(False,'内核地址被其他程式HOOK了！');
          end;
        end;
	    end;
    end;
  end;
  N18.Checked:=ToolButton10_Start.ImageIndex=4;;
  DeviceCtrl.DisConnect;
  SysIni.WriteInteger('ToolBar','Start',ToolButton10_Start.ImageIndex);
end;

procedure Tform_main.ToolButton_TimeClick(Sender: TObject);  //时间格式
begin
  case ToolButton_Time.ImageIndex of
    13:begin
        ToolButton_Time.ImageIndex:=12;
      end;
    12:begin
        ToolButton_Time.ImageIndex:=13;
      end;
  end;
  N7.Checked:=ToolButton_Time.ImageIndex=13;
  SysIni.WriteInteger('ToolBar','Time',ToolButton_Time.ImageIndex);
end;

procedure Tform_main.ToolButton_AutoSavaClick(Sender: TObject);   //自动保存
begin
    case ToolButton_AutoSava.ImageIndex of
      18:begin//自动
          ToolButton_AutoSava.ImageIndex:=17;
          AutoSavePath:='';
        end;
      17:begin//非自动
          if(StrLen(PChar(AutoSavePath))<=0) then
          begin
            //路径变量没有字串
            if(SaveDialog1.Execute)then
            begin
              AutoSavePath:=SaveDialog1.FileName;
              if(FileExists(AutoSavePath)=False)then SaveListToFile;
              ToolButton_AutoSava.ImageIndex:=18;
            end;
          end;
        end;
    end;
    N17.Checked:=ToolButton_AutoSava.ImageIndex=18;
end;

procedure Tform_main.ToolButton11_AutoScrollClick(Sender: TObject);   //自动滚动
begin
  case ToolButton11_AutoScroll.ImageIndex of
    2:begin
        ToolButton11_AutoScroll.ImageIndex:=1;
      end;
    1:begin
        ToolButton11_AutoScroll.ImageIndex:=2;
      end;
  end;
  SysIni.WriteInteger('ToolBar','AutoScroll',ToolButton11_AutoScroll.ImageIndex);
end;

procedure Tform_main.ListView1Insert(Sender: TObject; Item: TListItem);   //列表被插入项目
begin
  StatusBar1.Panels.Items[2].Text:='数目:'+IntToStr(ListView1.Items.Count);
  if(ToolButton11_AutoScroll.ImageIndex=2) then
  begin
    SendMessage(ListView1.Handle, $1000+19, Item.Index, MAKELPARAM(1, 0));
  end;
end;

procedure Tform_main.Timer1Timer(Sender: TObject);     //时间 事件
begin
  StatusBar1.Panels.Items[0].Text:=TimeToStr(Time);
end;

procedure Tform_main.FormCreate(Sender: TObject);    //窗口 创建
var
  tmpStr:array[0..MAX_PATH] of Char;
  SysPath:String;
  resl:TResourceStream;
begin   
  Timer1Timer(nil);
  DeviceCtrl.AnjustPrivilegesToDebug;
  GetSystemDirectory(@tmpStr,MAX_PATH);
  DeviceCtrl.Ini_Create(ExtractFilePath(ParamStr(0))+'Config.ini');
  if(DeviceCtrl.ConnectDevice) then  //判断设备是否创建(驱动是否被加载)
  begin
    DeviceCtrl.DisConnect;
    if(SysIni.ReadInteger('ToolBar','Start',3)=4) then ToolButton10_StartClick(NIL);
  end else begin
    SysPath:=tmpStr+'\drivers\HanfDbgV.sys';
    if(FileExists(SysPath)) then
    begin
      MySysCtrl.LoadMySys(Handle,SysPath);
    end else begin
      resl:=TResourceStream.CreateFromID(HInstance,102,'BIN');
      try
        resl.SaveToFile(SysPath);
        if(FileExists(SysPath)) then
        begin
          MySysCtrl.LoadMySys(Handle,SysPath);
        end;
      finally
        if(resl<>nil) then resl.Free;
      end;
    end;
  end;
  ToolButton11_AutoScroll.ImageIndex:=SysIni.ReadInteger('ToolBar','AutoScroll',2);
  ToolButton_Time.ImageIndex:=SysIni.ReadInteger('ToolBar','Time',12);
  if(SysIni.ReadBool('ToolBar','StayOnTop',N10.Checked)) then N10Click(nil);
  if(SysIni.ReadBool('Menu','MsgShowSerMsg',N20.Checked)) then N20Click(nil);

  if(SysIni.ReadBool('Menu','ShowMilliseconds',N11.Checked)) then N11Click(nil);
  if(SysIni.ReadBool('Menu','NoShowSerMsg',N15.Checked)) then N15Click(nil);
end;

procedure Tform_main.N20Click(Sender: TObject);  //菜单 显示消息框
begin
  if(N20.Checked) then
  begin
    N20.Checked:=False;
  end else begin
    N20.Checked:=True;
  end;
  SysIni.WriteBool('Menu','MsgShowSerMsg',N20.Checked);
end;

procedure Tform_main.N10Click(Sender: TObject); //菜单 总在最前
begin
  if(N10.Checked) then
  begin
    SetWindowPos(Handle,HWND(-2),0,0,0,0,SWP_NOMOVE or SWP_NOSIZE);
    N10.Checked:=False;
    ToolButton_Top.ImageIndex:=24;
  end else begin
    SetWindowPos(Handle,HWND(-1),0,0,0,0,SWP_NOMOVE or SWP_NOSIZE);
    N10.Checked:=True;
    ToolButton_Top.ImageIndex:=25;
  end;
  SysIni.WriteBool('ToolBar','StayOnTop',N10.Checked);
end;

procedure Tform_main.IconMessageFunc(var mMessage:TMessage); //托盘图标 消息回调
var
  XY:TPoint;
begin
  if(mMessage.LParam=WM_LBUTTONDBLCLK) then
  begin
    N8Click(nil);
  end else 
  if(mMessage.LParam=WM_RBUTTONDOWN) then
  begin
    GetCursorPos(XY);
    SetForegroundWindow(Handle);
    PopupMenu1.Popup(xy.X,xy.Y);
  end;
  inherited;
end;

procedure Tform_main.N13Click(Sender: TObject);   //菜单 托盘图标
begin
  IconNotify.cbSize:=SizeOf(IconNotify);
  IconNotify.Wnd:=Handle;
  IconNotify.uID:=1;
  IconNotify.uFlags:=NIF_ICON or NIF_MESSAGE or NIF_TIP;
  IconNotify.uCallbackMessage:=WM_USER+10;
  IconNotify.hIcon:=Application.Icon.Handle;
  IconNotify.szTip:='调试打印监视工具';
  if(Shell_NotifyIcon(NIM_ADD,@IconNotify)) then Hide;
end;

procedure Tform_main.N8Click(Sender: TObject);  //图标菜单 显示
begin
  show;
  Shell_NotifyIcon(NIM_DELETE,@IconNotify);
end;

procedure Tform_main.N9Click(Sender: TObject);  //图标菜单 退出
begin
  Application.Terminate;
end;

procedure Tform_main.A2Click(Sender: TObject);  //菜单 关于
var
  formabout:Tform_about;
begin
  formabout:=Tform_about.Create(form_main);
  try
    formabout.ShowModal;
  finally
   if(formabout<>nil) then   formabout.Free;
  end;
end;

procedure Tform_main.N5Click(Sender: TObject);//菜单 删除全部
begin
  ToolButton6Click(nil);
end;

procedure Tform_main.N7Click(Sender: TObject);//菜单 时钟
begin
  ToolButton_TimeClick(nil);
end;

procedure Tform_main.F2Click(Sender: TObject); //菜单 查找
begin
  if(ListView1.Items.Count>0) then  FindDialog1.Execute;
end;

function Tform_main.FindListText(i:Integer;MatchCase:BOOL):BOOL;   //查找列表字串
var
  ItemText,FindText:string;
begin
  result:=False;
  //为了防止列表中的字串被变成小写所以读取到变量
  ItemText:=PChar(ListView1.Items.Item[i].SubItems.Strings[1])^;
  FindText:=PChar(FindDialog1.FindText)^;
  if(MatchCase=False) then //不区分大小写
  begin
     ItemText:=StrLower(PChar(ItemText));
     FindText:=StrLower(PChar(FindText));
  end;
  if(Integer(StrPos(PChar(ItemText),PChar(FindText)))>0) then
  begin
    if(ListView1.SelCount>0) then ListView1.Selected.Selected:=False;
    ListView1.ItemIndex:=i;
    SendMessage(ListView1.Handle, $1000+19,i, MAKELPARAM(1, 0));
    result:=True;
  end;
end;

procedure Tform_main.FindDialog1Find(Sender: TObject); //查找对话框 查找事件
var
  x,i,count:Integer;
  IsMachoCase,IsDown:BOOL;
begin
  count:=ListView1.Items.Count-1;
  IsMachoCase:=(FindDialog1.Options=[frDown,frMatchCase,frFindNext,frHideWholeWord])//向下 区分大小写
    or(FindDialog1.Options=[frMatchCase,frFindNext,frHideWholeWord]); //向上 区分大小写

  IsDown:=(FindDialog1.Options=[frDown,frMatchCase,frFindNext,frHideWholeWord])//向下 区分大小写
    or(FindDialog1.Options=[frDown,frFindNext,frHideWholeWord]);//向下

  if(count<0) then count:=0;
  if(IsDown) then//向下
  begin
    x:=ListView1.ItemIndex+1; if(x<0) then x:=0;
    for i:=x to count do
    begin
      if(FindListText(i,IsMachoCase))then Break;
    end;
  end else begin   //向上
    x:=ListView1.ItemIndex-1; if(x<0) then x:=0;
    for i:=x downto 0 do
    begin
      if(FindListText(i,IsMachoCase))then Break;
    end;
  end;

end;

procedure Tform_main.N17Click(Sender: TObject);//菜单 自动保存
begin
ToolButton_AutoSavaClick(nil);
end;

procedure Tform_main.N3Click(Sender: TObject); //菜单 复制
var
  tml:TListItem;
  tmpBuf:string;
begin
  tml:=ListView1.Selected;
  if(ListView1.SelCount>0) then
  begin
    tmpBuf:=tml.Caption+' '+tml.SubItems.Strings[0]+' '+tml.SubItems.Strings[1];
    CopyText(tmpBuf);
  end;
end;

procedure Tform_main.R1Click(Sender: TObject); //菜单 移除
begin
  if(ListView1.SelCount>0) then ListView1.DeleteSelected;
end;

procedure Tform_main.ToolButton13Click(Sender: TObject); //查找
begin
  F2Click(nil);
end;

procedure Tform_main.N18Click(Sender: TObject); //菜单 监视核心
begin
  ToolButton10_StartClick(nil);
end;

procedure Tform_main.ToolButton_TopClick(Sender: TObject);//总在最前
begin
  N10Click(nil);
end;

procedure Tform_main.N11Click(Sender: TObject); //显示毫秒
begin
  if(N11.Checked) then
  begin
   N11.Checked:=False;
  end else
  begin
   N11.Checked:=True;
  end;
  SysIni.WriteBool('Menu','ShowMilliseconds',N11.Checked);
end;

procedure Tform_main.N15Click(Sender: TObject); //菜单 不显示提示服务信息
begin
  if(N15.Checked) then
  begin
   N15.Checked:=False;
  end else
  begin
   N15.Checked:=True;
  end;
  SysIni.WriteBool('Menu','NoShowSerMsg',N15.Checked);
end;

end.
