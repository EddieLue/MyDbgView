object Form1: TForm1
  Left = 206
  Top = 181
  AutoScroll = False
  Caption = 'Symbolic Link Viewer'
  ClientHeight = 318
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    480
    318)
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 8
    Top = 296
    Width = 185
    Height = 12
    Anchors = [akLeft, akBottom]
    AutoSize = False
    Caption = 'By:Leaf QQ:958570606'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 480
    Height = 270
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object ListView1: TListView
      Left = 0
      Top = 0
      Width = 480
      Height = 270
      Align = alClient
      Columns = <
        item
          AutoSize = True
          Caption = #31526#21495#38142#25509#21517
        end
        item
          AutoSize = True
          Caption = #35774#22791#21517
        end>
      GridLines = True
      ReadOnly = True
      RowSelect = True
      SortType = stText
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object Button1: TButton
    Left = 369
    Top = 283
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 281
    Top = 283
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #21047#26032
    TabOrder = 2
    OnClick = Button2Click
  end
end
