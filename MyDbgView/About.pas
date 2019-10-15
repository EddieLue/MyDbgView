unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  Tform_about = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Image1: TImage;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Label2MouseLeave(Sender: TObject);
    procedure Label2MouseEnter(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure Tform_about.FormCreate(Sender: TObject);
begin
  Image1.Picture.Graphic:=Application.Icon;
end;

procedure Tform_about.Label2MouseLeave(Sender: TObject);
begin
  Label2.Font.Style:=[];
end;

procedure Tform_about.Label2MouseEnter(Sender: TObject);
begin
  Label2.Font.Style:=[fsUnderline,fsItalic];
end;

procedure Tform_about.Label2Click(Sender: TObject);
begin
  WinExec('explorer.exe http://958570606.qzone.qq.com/',SW_SHOW);
end;

procedure Tform_about.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if(Key=VK_RETURN)then ModalResult:=mrCancel;
end;

end.
