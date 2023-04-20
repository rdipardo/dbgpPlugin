object DebugStackForm1: TDebugStackForm1
  Left = 776
  Top = 112
  BorderStyle = bsSizeToolWin
  Caption = 'Stack'
  ClientHeight = 172
  ClientWidth = 256
  Color = clBtnFace
  DockSite = True
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    256
    172)
  PixelsPerInch = 96
  TextHeight = 13
  object VirtualStringTree1: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 256
    Height = 172
    Anchors = [akLeft, akTop, akRight, akBottom]
    Header.AutoSizeIndex = 0
    Header.Options = [hoColumnResize, hoDrag, hoVisible]
    HintMode = hmTooltip
    ParentShowHint = False
    PopupMenu = PopupMenu1
    ShowHint = False
    TabOrder = 0
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowRoot, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    TreeOptions.StringOptions = [toSaveCaptions]
    OnDblClick = VirtualStringTree1DblClick
    OnGetText = VirtualStringTree1GetText
    Columns = <
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Text = 'Level'
        Width = 40
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Text = 'File'
        Width = 250
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 2
        Text = 'Line'
        Width = 40
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 3
        Text = 'Where'
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 4
        Text = 'Type'
      end>
  end
  object JvDockClient1: TJvDockClient
    DirectDrag = False
    ShowHint = False
    EnableCloseButton = False
    LeftDock = False
    TopDock = False
    RightDock = False
    DockStyle = NppDockingForm1.JvDockVSNetStyle1
    CustomDock = False
    Left = 8
    Top = 24
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 40
    Top = 24
    object GetContext1: TMenuItem
      Caption = 'GetContext'
      OnClick = GetContext1Click
    end
  end
end
