object form_about: Tform_about
  Left = 192
  Top = 138
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #20851#20110
  ClientHeight = 94
  ClientWidth = 301
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object Image1: TImage
    Left = 10
    Top = 14
    Width = 47
    Height = 41
    Center = True
  end
  object Label1: TLabel
    Left = 63
    Top = 9
    Width = 226
    Height = 72
    AutoSize = False
    Caption = #26539#21494#35843#35797#20449#24687#30417#35270#24037#20855' V1.0'#13#10#24320#21457#24179#21488':XPsp3 Delphi7 Vs2005+WDK'#13#10#13#10#20316#32773':Leaf'#13#10
    Transparent = True
  end
  object Label2: TLabel
    Left = 64
    Top = 62
    Width = 81
    Height = 12
    Cursor = crHandPoint
    AutoSize = False
    Caption = 'QQ:958570606'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    OnClick = Label2Click
    OnMouseEnter = Label2MouseEnter
    OnMouseLeave = Label2MouseLeave
  end
  object Button1: TButton
    Left = 212
    Top = 53
    Width = 67
    Height = 22
    Caption = #30830#23450
    ModalResult = 3
    TabOrder = 0
  end
end
