object ConfigForm1: TConfigForm1
  Left = 253
  Top = 132
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'DBGp configuration'
  ClientHeight = 409
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 497
    Height = 225
    Caption = 'File Mapping'
    TabOrder = 0
    object Button1: TButton
      Left = 16
      Top = 192
      Width = 75
      Height = 25
      Caption = 'Add'
      TabOrder = 0
      OnClick = Button1Click
    end
    object DeleteButton: TButton
      Left = 104
      Top = 192
      Width = 75
      Height = 25
      Caption = 'Delete'
      TabOrder = 1
      OnClick = DeleteButtonClick
    end
    object StringGrid1: TStringGrid
      Left = 16
      Top = 24
      Width = 465
      Height = 161
      ColCount = 4
      DefaultColWidth = 110
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goAlwaysShowEditor, goThumbTracking]
      TabOrder = 2
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 224
    Width = 497
    Height = 145
    Caption = 'Misc'
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 84
      Width = 134
      Height = 13
      Caption = 'Maximum depth of elements:'
    end
    object Label2: TLabel
      Left = 16
      Top = 108
      Width = 117
      Height = 13
      Caption = 'Maximum child elements:'
    end
    object CheckBox1: TCheckBox
      Left = 16
      Top = 16
      Width = 305
      Height = 17
      Caption = 'Refresh local context on every step'
      TabOrder = 0
    end
    object CheckBox2: TCheckBox
      Left = 16
      Top = 32
      Width = 305
      Height = 17
      Caption = 'Refresh global context on every step'
      TabOrder = 1
    end
    object CheckBox3: TCheckBox
      Left = 16
      Top = 48
      Width = 305
      Height = 17
      Caption = 'Use SOURCE command for all files and bypass maps'
      TabOrder = 2
    end
    object CheckBox4: TCheckBox
      Left = 16
      Top = 64
      Width = 305
      Height = 17
      Caption = 'Start with closed socket (firewall conflicts work arround)'
      TabOrder = 3
    end
    object SpinEdit1: TSpinEdit
      Left = 160
      Top = 80
      Width = 57
      Height = 22
      MaxValue = 1000
      MinValue = 0
      TabOrder = 4
      Value = 0
    end
    object SpinEdit2: TSpinEdit
      Left = 160
      Top = 104
      Width = 57
      Height = 22
      MaxValue = 1000
      MinValue = 0
      TabOrder = 5
      Value = 0
    end
  end
  object Button3: TButton
    Left = 16
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 2
    OnClick = Button3Click
  end
end
