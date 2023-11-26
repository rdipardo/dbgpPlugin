object DebugRawForm1: TDebugRawForm1
  Left = 308
  Top = 114
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Raw DBGP'
  ClientHeight = 201
  ClientWidth = 600
  Color = clBtnFace
  DockSite = True
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Consolas'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    307
    201)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 598
    Height = 169
    Anchors = [akLeft, akTop, akRight, akBottom]
    PopupMenu = PopupMenu1
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object Button1: TButton
    Left = 545
    Top = 172
    Width = 51
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Send'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = Button1Click
  end
  object ComboBox1: TComboBox
    Left = 4
    Top = 176
    Width = 535
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
    OnKeyUp = ComboBox1KeyUp
  end
  object PopupMenu1: TPopupMenu
    Left = 40
    Top = 8
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
    object SaveDbgp: TMenuItem
      Caption = 'Save as...'
      OnClick = SaveDBGpClick
    end
  end
  object DlgSaveDbgp: TSaveDialog
    DefaultExt = '.log'
    Filter = 'Raw DBGp|*.log;*.txt;*.xml'
    Options = [ofHideReadOnly, ofOverwritePrompt, ofDontAddToRecent, ofEnableSizing]
    Left = 16
    Top = 114
  end
end
