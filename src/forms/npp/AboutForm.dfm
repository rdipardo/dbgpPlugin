object AboutForm1: TAboutForm1
  Left = 391
  Top = 326
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 1
  Caption = 'About'
  ClientHeight = 346
  ClientWidth = 273
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 13
  object Label7: TLabel
    Left = 0
    Top = 0
    Width = 273
    Height = 13
    Align = alTop
    Alignment = taCenter
    Caption = 'DBGP Plugin v%d.%d.%d %s for Notepad++ v%s'
    ExplicitWidth = 247
  end
  object Label22: TLabel
    Left = 25
    Top = 279
    Width = 232
    Height = 13
    Caption = 'See the README file for more information...'
  end
  object Button1: TButton
    Left = 100
    Top = 313
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 112
    Width = 257
    Height = 161
    Caption = 'Menu entries'
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 52
      Height = 13
      Caption = 'Debugger'
    end
    object Label2: TLabel
      Left = 8
      Top = 40
      Width = 47
      Height = 13
      Caption = 'Step Into'
    end
    object Label3: TLabel
      Left = 8
      Top = 56
      Width = 50
      Height = 13
      Caption = 'Step Over'
    end
    object Label4: TLabel
      Left = 8
      Top = 72
      Width = 46
      Height = 13
      Caption = 'Step Out'
    end
    object Label5: TLabel
      Left = 8
      Top = 88
      Width = 21
      Height = 13
      Caption = 'Run'
    end
    object Label6: TLabel
      Left = 8
      Top = 120
      Width = 44
      Height = 13
      Caption = 'Config...'
    end
    object Label10: TLabel
      Left = 80
      Top = 24
      Width = 103
      Height = 13
      Caption = 'Starts the debugger'
    end
    object Label11: TLabel
      Left = 80
      Top = 40
      Width = 131
      Height = 13
      Caption = 'Steps into next statement'
    end
    object Label12: TLabel
      Left = 80
      Top = 56
      Width = 132
      Height = 13
      Caption = 'Steps over next statement'
    end
    object Label13: TLabel
      Left = 80
      Top = 72
      Width = 136
      Height = 13
      Caption = 'Steps out of current scope'
    end
    object Label14: TLabel
      Left = 80
      Top = 88
      Width = 160
      Height = 13
      Caption = 'Continue until next breakpoint'
    end
    object Label15: TLabel
      Left = 80
      Top = 120
      Width = 139
      Height = 13
      Caption = 'Open configuration dialog'
    end
    object Label16: TLabel
      Left = 8
      Top = 136
      Width = 41
      Height = 13
      Caption = 'About...'
    end
    object Label17: TLabel
      Left = 80
      Top = 136
      Width = 87
      Height = 13
      Caption = 'Show this dialog'
    end
    object Label23: TLabel
      Left = 8
      Top = 104
      Width = 56
      Height = 13
      Caption = 'Breakpoint'
    end
    object Label24: TLabel
      Left = 80
      Top = 104
      Width = 95
      Height = 13
      Caption = 'Toggle breakpoint'
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 19
    Width = 257
    Height = 87
    TabOrder = 2
    object Label18: TLabel
      Left = 38
      Top = 8
      Width = 175
      Height = 13
      Alignment = taCenter
      Caption = #169' 2007-2012 Damjan Zobo Cvetko'
    end
    object Label8: TLabel
      Left = 63
      Top = 27
      Width = 122
      Height = 13
      Alignment = taCenter
      Caption = #169' 2023 Robert Di Pardo'
    end
    object Label9: TLabel
      Left = 31
      Top = 46
      Width = 190
      Height = 13
      Alignment = taCenter
      Caption = 'Licensed under the GPLv3 and LGPLv3'
    end
    object lblRepoURL: TLabel
      Left = 32
      Top = 65
      Width = 194
      Height = 15
      Hint = 'View source code'
      Alignment = taCenter
      Caption = 'https://bitbucket.org/rdipardo/dbgp'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHotLight
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsUnderline]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = lblRepoURLClick
      OnMouseEnter = lblRepoURLMouseEnter
      OnMouseLeave = lblRepoURLMouseLeave
    end
  end
end
