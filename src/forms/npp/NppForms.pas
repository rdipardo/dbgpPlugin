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

unit NppForms;

interface

uses
  Windows, Messages, Classes, NppPlugin, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs;

type
  TWinApiMsgProc = function(Hndl: HWND; Msg: Cardinal; _WParam: WPARAM;
    _LParam: LPARAM): LRESULT; stdcall;

  TNppForm = class(TForm)
  private
    { Private declarations }
  protected
    function SafeSendMessage(Hndl: HWND; Msg: Cardinal; _WParam: WPARAM;
      _LParam: LPARAM): LRESULT;
    procedure RegisterForm();
    procedure UnregisterForm();
    procedure DoClose(var Action: TCloseAction); override;
  public
    { Public declarations }
    Npp: TNppPlugin;
    DefaultCloseAction: TCloseAction;
    constructor Create(NppParent: TNppPlugin); reintroduce; overload;
    constructor Create(AOwner: TNppForm); reintroduce; overload;
    destructor Destroy; override;
    function WantChildKey(Child: TControl; var Message: TMessage): Boolean; override;
  end;

var
  NppForm: TNppForm;

implementation

{$R *.dfm}

{ TNppForm }

constructor TNppForm.Create(NppParent: TNppPlugin);
begin
  self.Npp := NppParent;
  self.DefaultCloseAction := caNone;
  inherited Create(nil);
  self.RegisterForm();
end;

constructor TNppForm.Create(AOwner: TNppForm);
begin
  self.Npp := AOwner.Npp;
  self.DefaultCloseAction := caNone;
  inherited Create(AOwner);
end;

destructor TNppForm.Destroy;
begin
  if (self.HandleAllocated) then
  begin
    self.UnregisterForm();
  end;
  inherited;
end;

function TNppForm.SafeSendMessage(Hndl: HWND; Msg: Cardinal; _WParam: WPARAM;
  _LParam: LPARAM): LRESULT;
var
  _MsgProc: TWinApiMsgProc;
begin
{$IFDEF CPUx64}
  _MsgProc := SendMessageW;
{$ELSE}
  _MsgProc := SendMessage;
{$ENDIF}
  Result := _MsgProc(Hndl, Msg, _WParam, _LParam);
end;

procedure TNppForm.RegisterForm();
begin
  if (not Assigned(self.Npp)) then
    exit;
  // "For each created dialog in your plugin, you should register it (and
  // unregister while destroy it) to Notepad++ by using this message. If
  // this message is ignored, then your dialog won't react with the key
  // stroke messages such as TAB key. For the good functioning of your
  // plugin dialog, you're recommended to not ignore this message"
  // https://github.com/notepad-plus-plus/npp-usermanual/blob/master/content/docs/plugin-communication.md#nppm_modelessdialogage
  SafeSendMessage(self.Npp.NppData.NppHandle, NPPM_MODELESSDIALOG,
    MODELESSDIALOGADD, LPARAM(self.Handle));
end;

procedure TNppForm.UnregisterForm();
begin
  if (not self.HandleAllocated) then
    exit;
  SafeSendMessage(self.Npp.NppData.NppHandle, NPPM_MODELESSDIALOG,
    MODELESSDIALOGREMOVE, LPARAM(self.Handle));
end;

procedure TNppForm.DoClose(var Action: TCloseAction);
begin
  if (self.DefaultCloseAction <> caNone) then Action := self.DefaultCloseAction;
  inherited;
end;

// This is going to help us solve the problems we are having because of N++ handling our messages
function TNppForm.WantChildKey(Child: TControl; var Message: TMessage): Boolean;
begin
  Result := Child.Perform(CN_BASE + Message.Msg, Message.WParam,
    Message.LParam) <> 0;
end;

end.
