object DebugEvalForm1: TDebugEvalForm1
  Left = 339
  Top = 111
  ActiveControl = ComboBox1
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Eval'
  ClientHeight = 71
  ClientWidth = 343
  Color = clBtnFace
  Constraints.MaxHeight = 100
  Constraints.MinHeight = 100
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  DesignSize = (
    343
    71)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 170
    Top = 40
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 258
    Top = 40
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 8
    Width = 323
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object CheckBoxReuseResult: TCheckBox
    Left = 8
    Top = 40
    Width = 129
    Height = 17
    Caption = 'Open in same window'
    TabOrder = 3
  end
end
