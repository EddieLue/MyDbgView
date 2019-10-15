unit SymbolicViewer;

interface

uses
  Windows,Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ListView1: TListView;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
var
  TmpList:TListItem;
  TmpLength:Integer;
  TmpBuf,AliasedStr:array[0..$8000] of Char;
  OldChar,CurChar:PChar;
begin
  ListView1.Clear;
  TmpLength:=Length(TmpBuf);
  TmpLength:=QueryDosDevice(nil,@TmpBuf,TmpLength);
  OldChar:=@TmpBuf;
  if(TmpLength<>0) then
  begin
    TmpLength:=0;
    while True do
    begin
      CurChar:=PChar(Integer(OldChar)+TmpLength);
      TmpList:=ListView1.Items.Add;
      TmpList.Caption:=CurChar;
      QueryDosDevice(CurChar,@AliasedStr,Length(AliasedStr));
      TmpList.SubItems.Add(PChar(@AliasedStr));
      OldChar:=CurChar;
      TmpLength:=StrLen(OldChar);
      if(TmpLength<=0) then Break;
      TmpLength:=TmpLength+1;
    end;
    if(TmpList<>nil) then TmpList.Delete;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Self.ModalResult:=mrOk;
  Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Button2Click(nil);
end;

end.
