object DebugStackForm1: TDebugStackForm1
  Left = 776
  Top = 112
  Width = 264
  Height = 206
  BorderStyle = bsSizeToolWin
  Caption = 'Stack'
  Color = clBtnFace
  DockSite = True
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
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
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoVisible]
    HintMode = hmTooltip
    ParentShowHint = False
    ShowHint = True
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
        Width = 40
        WideText = 'Level'
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Width = 150
        WideText = 'File'
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 2
        Width = 40
        WideText = 'Line'
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 3
        WideText = 'Where'
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 4
        WideText = 'Type'
      end>
  end
  object JvDockClient1: TJvDockClient
    DirectDrag = False
    EnableCloseButton = False
    LeftDock = False
    TopDock = False
    RightDock = False
    DockStyle = NppDockingForm1.JvDockVSNetStyle1
    CustomDock = False
    Left = 8
    Top = 24
  end
end
