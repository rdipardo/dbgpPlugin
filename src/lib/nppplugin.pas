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

unit nppplugin;

interface

uses
  Classes, SysUtils, Windows, Messages, Vcl.Dialogs, Vcl.Forms;

{$I '..\Include\Scintilla.inc'}
{$I '..\Include\Npp.inc'}

  TNppPlugin = class(TObject)
  protected
    PluginName: WideString; // unicode
    FuncArray: array of _TFuncItem;
    function GetPluginsConfigDir: WideString;
    function SupportsDarkMode: Boolean; // needs N++ 8.0 or later
    function SupportsBigFiles: Boolean; // needs N++ 8.3 or later
    function AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD): Integer; overload;
    function AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD;
      ShortcutKey: PShortcutKey): Integer; overload;
    function MakeShortcutKey(const Ctrl, Alt, Shift: Boolean; const AKey: AnsiChar)
      : PShortcutKey;
  public
    NppData: TNppData;
    constructor Create;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    function CmdIdFromDlgId(DlgId: Integer): Integer;

    // needed for DLL export.. wrappers are in the main dll file.
    procedure SetInfo(NppData: TNppData);
    function GetName: PWChar;
    function GetFuncsArray(var FuncsCount: Integer): Pointer;
    procedure BeNotified(sn: PSciNotification); virtual;
    procedure MessageProc(var Msg: TMessage); virtual;

    // hooks
    procedure DoNppnToolbarModification; virtual;
    procedure DoNppnShutdown; virtual;

    // df
    function DoOpen(filename: WideString): boolean; overload;
    function DoOpen(filename: WideString; Line: Integer): boolean; overload;
    procedure GetFileLine(var filename: String; var Line: Integer);
    procedure GetOpenFiles(files: TStrings);
    function GetWord: string;
  end;

  function WideStrLen(const Str: PWideChar): Cardinal;

implementation

{ TNppPlugin }

{ This is hacking for trouble...
  We need to unset the Application handler so that the forms
  don't get berserk and start throwing OS error 1004.
  This happens because the main NPP HWND is already lost when the
  DLL_PROCESS_DETACH gets called, and the form tries to allocate a new
  handler for sending the "close" windows message...
}
procedure TNppPlugin.BeforeDestruction;
begin
  Application.Handle := 0;
  Application.Terminate;
  inherited;
end;

constructor TNppPlugin.Create;
begin
  inherited;
end;

destructor TNppPlugin.Destroy;
var i: Integer;
begin
  for i:=0 to Length(self.FuncArray)-1 do
  begin
    if (self.FuncArray[i].ShortcutKey <> nil) then
    begin
      Dispose(self.FuncArray[i].ShortcutKey);
    end;
  end;

  inherited;
end;

function TNppPlugin.AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD): Integer;
var
  i: Integer;
begin
  i := Length(self.FuncArray);
  SetLength(self.FuncArray, i + 1);
  StringToWideChar(Name, self.FuncArray[i].ItemName, 1000);
  self.FuncArray[i].Func := Func;
  self.FuncArray[i].ShortcutKey := nil;
  Result := i;
end;

function TNppPlugin.AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD;
  ShortcutKey: PShortcutKey): Integer;
var
  i: Integer;
begin
  i := self.AddFuncItem(Name, Func);
  New(self.FuncArray[i].ShortcutKey);
  self.FuncArray[i].ShortcutKey := ShortcutKey;
  Result := i;
end;

function TNppPlugin.MakeShortcutKey(const Ctrl, Alt, Shift: Boolean;
  const AKey: AnsiChar): PShortcutKey;
begin
  Result := New(PShortcutKey);
  with Result^ do
  begin
    IsCtrl := Ctrl;
    IsAlt := Alt;
    IsShift := Shift;
    Key := AKey;
  end;
end;

procedure TNppPlugin.GetFileLine(var filename: String; var Line: Integer);
var
  s: String;
  r: Integer;
begin
  s := '';
  SetLength(s, 300);
  SendMessage(self.NppData.NppHandle, NPPM_GETFULLCURRENTPATH, 0,
    LPARAM(PChar(s)));
  SetLength(s, StrLen(PChar(s)));
  filename := s;

  r := SendMessage(self.NppData.ScintillaMainHandle, SCI_GETCURRENTPOS, 0, 0);
  Line := SendMessage(self.NppData.ScintillaMainHandle,
    SCI_LINEFROMPOSITION, r, 0);
end;

function TNppPlugin.GetFuncsArray(var FuncsCount: Integer): Pointer;
begin
  FuncsCount := Length(self.FuncArray);
  Result := self.FuncArray;
end;

function TNppPlugin.GetName: nppPChar;
begin
  Result := nppPChar(self.PluginName);
end;

function TNppPlugin.GetPluginsConfigDir: WideString;
var
  s: string;
begin
  SetLength(s, 1001);
  SendMessage(self.NppData.NppHandle, NPPM_GETPLUGINSCONFIGDIR, 1000,
    LPARAM(PChar(s)));
  SetString(s, PChar(s), StrLen(PChar(s)));
  Result := s;
end;

procedure TNppPlugin.GetOpenFiles(files: TStrings);
var
  i,nf: integer;
  tmpfiles: array of WideString;
begin
// TODO unicode
  nf := SendMessageW(self.NppData.NppHandle, NPPM_GETNBOPENFILES, 0, PRIMARY_VIEW);
  SetLength(tmpfiles, nf);
  for i:=0 to nf-1 do
  begin
    SetLength(tmpfiles[i],500);
  end;
  nf := SendMessageW(self.NppData.NppHandle, NPPM_GETOPENFILENAMESPRIMARY, WPARAM(tmpfiles), nf);
  files.Clear;
  for i:=0 to nf-1 do
  begin
    SetLength(tmpfiles[i], WideStrLen(PWideChar(tmpfiles[i])));
    files.Add(tmpfiles[i]);
  end;
end;

procedure TNppPlugin.BeNotified(sn: PSciNotification);
begin
  if (HWND(sn^.nmhdr.hwndFrom) = self.NppData.NppHandle) and
    (sn^.nmhdr.code = NPPN_TBMODIFICATION) then
  begin
    self.DoNppnToolbarModification;
  end
  else if (HWND(sn^.nmhdr.hwndFrom) = self.NppData.NppHandle) and
    (sn^.nmhdr.code = NPPN_SHUTDOWN) then
  begin
    self.DoNppnShutdown;
  end;
  // @todo
end;

{$REGION 'Virtual procedures'}

procedure TNppPlugin.MessageProc(var Msg: TMessage);
var
  hm: HMENU;
  i: Integer;
begin
  if (Msg.Msg = WM_CREATE) then
  begin
    // Change - to separator items
    hm := GetMenu(self.NppData.NppHandle);
    for i := 0 to Length(self.FuncArray) - 1 do
      if (self.FuncArray[i].ItemName[0] = '-') then
        ModifyMenu(hm, self.FuncArray[i].CmdID, MF_BYCOMMAND or
          MF_SEPARATOR, 0, nil);
  end;
  Dispatch(Msg);
end;

procedure TNppPlugin.SetInfo(NppData: TNppData);
begin
  self.NppData := NppData;
  Application.Handle := NppData.NppHandle;
end;

function WideStrLen(const Str: PWideChar): Cardinal;
var
  i: Cardinal;
begin
  i := 0;
  while (Str[i] <> #0) do inc(i);
  Result := i;
end;

procedure TNppPlugin.DoNppnShutdown;
begin
  // override
end;

procedure TNppPlugin.DoNppnToolbarModification;
begin
  // override
end;
{$ENDREGION}

// utils
function TNppPlugin.GetWord: string;
var
  s: string;
begin
  SetLength(s, 800);
  SendMessage(self.NppData.NppHandle, NPPM_GETCURRENTWORD, 0, LPARAM(PChar(s)));
  Result := s;
end;

function TNppPlugin.DoOpen(filename: WideString): Boolean;
var
  r: Integer;
  s: string;
begin
  // ask if we are not already opened
  SetLength(s, 500);
  r := SendMessage(self.NppData.NppHandle, NPPM_GETFULLCURRENTPATH, 0,
    LPARAM(PChar(s)));
  SetString(s, PChar(s), StrLen(PChar(s)));
  Result := true;
  if (s = filename) then
    exit;
  r := SendMessage(self.NppData.NppHandle, WM_DOOPEN, 0,
    LPARAM(PChar(filename)));
  Result := (r = 0);
end;

function TNppPlugin.DoOpen(filename: WideString; Line: Integer): Boolean;
var
  r: Boolean;
begin
  r := self.DoOpen(filename);
  if (r) then
    SendMessage(self.NppData.ScintillaMainHandle, SCI_GOTOLINE, Line, 0);
  Result := r;
end;

function TNppPlugin.CmdIdFromDlgId(DlgId: Integer): Integer;
begin
  Result := self.FuncArray[DlgId].CmdID;
end;

/// since 8.0
/// A return value of `true` means the NPPM_ADDTOOLBARICON_FORDARKMODE message is defined
/// https://community.notepad-plus-plus.org/topic/21652/add-new-api-nppm_addtoolbaricon_fordarkmode-for-dark-mode
function TNppPlugin.SupportsDarkMode: Boolean;
var
  NppVersion: Cardinal;
begin
  NppVersion := SendMessage(self.NppData.NppHandle, NPPM_GETNPPVERSION, 0, 0);
  Result := HIWORD(NppVersion) >= 8;
end;

/// since 8.3
/// *** MAJOR BREAKING CHANGE ***
/// A return value of `true` means that x64 editors return 64-bit character and line positions,
/// i.e., sizeof(Sci_Position) == sizeof(NativeInt), and sizeof(Sci_PositionU) == sizeof(SIZE_T)
/// https://community.notepad-plus-plus.org/topic/22471/recompile-your-x64-plugins-with-new-header
{$HINTS off}
function TNppPlugin.SupportsBigFiles: Boolean;
const
  // Also check for N++ versions 8.1.9.1, 8.1.9.2 and 8.1.9.3
  PatchReleases: Array[0..2] of Word = ( 191, 192, 193 );
var
  NppVersion: Cardinal;
  IsPatchRelease: Boolean;
  i: Byte;
begin
  NppVersion := SendMessage(self.NppData.NppHandle, NPPM_GETNPPVERSION, 0, 0);
  IsPatchRelease := False;

  for i := 0 to Length(PatchReleases) - 1 do
  begin
    IsPatchRelease := (LOWORD(NppVersion) = PatchReleases[i]);
    if IsPatchRelease then Break;
end;

  Result :=
    (HIWORD(NppVersion) > 8) or
    ((HIWORD(NppVersion) = 8) and
      // 8.3 => 8,3 *not* 8,30
      (((LOWORD(NppVersion) >= 3) and (LOWORD(NppVersion) <= 9)) or
       ((LOWORD(NppVersion) > 21) and not IsPatchRelease)));
end;
{$HINTS on}

end.
