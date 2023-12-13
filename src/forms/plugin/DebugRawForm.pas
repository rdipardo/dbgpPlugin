{
    This file is part of DBGP Plugin for Notepad++
    Copyright (C) 2007  Damjan Zobo Cvetko

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

unit DebugRawForm;

interface

uses
  Windows, Messages, Classes, Controls, Dialogs, StdCtrls, Menus, Clipbrd, NppDockingForm;

type
  TDebugRawForm1 = class(TNppDockingForm)
    Memo1: TMemo;
    Button1: TButton;
    PopupMenu1: TPopupMenu;
    Clear1: TMenuItem;
    Copy1: TMenuItem;
    SaveDbgp: TMenuItem;
    ComboBox1: TComboBox;
    DlgSaveDbgp: TSaveDialog;
    procedure DoShow; override;
    procedure Button1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure SaveDBGpClick(Sender: TObject);
    procedure ComboBox1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DebugRawForm1: TDebugRawForm1;

implementation

uses
  MainForm;
{$R *.dfm}

procedure TDebugRawForm1.Button1Click(Sender: TObject);
var
  mf: TNppDockingForm1;
begin
  // send raw
  mf := self.Owner as TNppDockingForm1;
  if Assigned(mf.sock) then
  begin
    mf.sock.SendText(UTF8Encode(self.ComboBox1.Text)+#0);
    mf.sock.debugdata.Add('User: '+self.ComboBox1.Text);
  end;
  self.ComboBox1.Items.Add(self.ComboBox1.Text);
end;

procedure TDebugRawForm1.Clear1Click(Sender: TObject);
begin
  self.Memo1.Clear;
end;

procedure TDebugRawForm1.Copy1Click(Sender: TObject);
begin
  if (self.Memo1.SelText = '') then exit;
  Clipboard.SetTextBuf(PChar(self.Memo1.SelText));
end;

procedure TDebugRawForm1.ComboBox1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) then self.Button1Click(Sender);
end;

procedure TDebugRawForm1.SaveDBGpClick(Sender: TObject);
begin
  if DlgSaveDbgp.Execute(self.Npp.NppData.NppHandle) then
    Memo1.Lines.SaveToFile(DlgSaveDbgp.FileName);
end;

procedure TDebugRawForm1.DoShow;
begin
  inherited;
  SafeSendMessage(Memo1.Handle, EM_LINESCROLL, 0, Memo1.Lines.Count);
  ComboBox1.SetFocus;
end;

end.
