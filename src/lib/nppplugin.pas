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
  Classes, SysUtils, Windows, Messages, Vcl.Forms;

{$I '..\Include\Scintilla.inc'}
{$I '..\Include\Npp.inc'}

  TNppPlugin = class(TObject)
  protected
    PluginName: WideString; // unicode
    FuncArray: array of _TFuncItem;
    function GetPluginsConfigDir: WideString;
    function GetCurrentScintilla: HWND;
    function SupportsDarkMode: Boolean; // needs N++ 8.0 or later
    function SupportsBigFiles: Boolean; // needs N++ 8.3 or later
    function HasFullRangeApis: Boolean; // needs N++ 8.4.3 or later
    function GetNppVersion: Cardinal;
    function AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD): Integer; overload;
    function AddFuncItem(Name: nppString; Func: PFUNCPLUGINCMD;
      ShortcutKey: PShortcutKey): Integer; overload;
    function MakeShortcutKey(const Ctrl, Alt, Shift: Boolean; const AKey: AnsiChar)
      : PShortcutKey;
    function SendNppMessage(Msg: Cardinal; _WParam: NativeUInt = 0; _LParam: NativeInt = 0): LRESULT; overload;
    function SendNppMessage(Msg: Cardinal; _WParam: NativeUInt; APParam: Pointer = nil): LRESULT; overload;
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
    function DoOpen(filename: WideString; Line: Sci_Position): boolean; overload;
    procedure GetFileLine(var filename: String; var Line: Sci_Position);
    procedure GetOpenFiles(files: TStrings);
    function GetWord: string;
    property CurrentScintilla: HWND read GetCurrentScintilla;
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
  StrPLCopy(self.FuncArray[i].ItemName, Name, 1000);
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

procedure TNppPlugin.GetFileLine(var filename: String; var Line: Sci_Position);
var
  s: array [0..1024] of char;
  r: Sci_Position;
  editor: HWND;
begin
  editor := CurrentScintilla;
  SendNppMessage(NPPM_GETFULLCURRENTPATH, 0, @s[0]);
  filename := string(s);

  r := SendMessageW(editor, SCI_GETCURRENTPOS, 0, 0);
  Line := SendMessageW(editor, SCI_LINEFROMPOSITION, r, 0);
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
  s: array [0..1024] of char;
begin
  SendNppMessage(NPPM_GETPLUGINSCONFIGDIR, Length(s)-1, @s[0]);
  Result := string(s);
end;

procedure TNppPlugin.GetOpenFiles(files: TStrings);
var
  i,nf: integer;
  tmpfiles: array of WideString;
begin
// TODO unicode
  nf := SendNppMessage(NPPM_GETNBOPENFILES, 0, PRIMARY_VIEW);
  SetLength(tmpfiles, nf);
  for i:=0 to nf-1 do
  begin
    SetLength(tmpfiles[i], 1024);
  end;
  nf := SendNppMessage(NPPM_GETOPENFILENAMESPRIMARY, WPARAM(tmpfiles), nf);
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
  s := '';
  SetLength(s, 800);
  SendNppMessage(NPPM_GETCURRENTWORD, 0, PChar(s));
  Result := s;
end;

function TNppPlugin.DoOpen(filename: WideString): Boolean;
var
  r: Integer;
  s: array [0..1024] of char;
begin
  // ask if we are not already opened
  SendNppMessage(NPPM_GETFULLCURRENTPATH, 0, @s[0]);
  Result := true;
  if (s = filename) then
    exit;
  r := SendNppMessage(WM_DOOPEN, 0, PChar(filename));
  Result := (r = 0);
end;

function TNppPlugin.DoOpen(filename: WideString; Line: Sci_Position): Boolean;
var
  r: Boolean;
begin
  r := self.DoOpen(filename);
  if (r) then
    SendMessageW(CurrentScintilla, SCI_GOTOLINE, Line, 0);
  Result := r;
end;

function TNppPlugin.CmdIdFromDlgId(DlgId: Integer): Integer;
begin
  Result := self.FuncArray[DlgId].CmdID;
end;

function TNppPlugin.GetNppVersion: Cardinal;
var
  NppVersion: Cardinal;
begin
  NppVersion := SendNppMessage(NPPM_GETNPPVERSION);
  // retrieve the zero-padded version, if available
  // https://github.com/notepad-plus-plus/notepad-plus-plus/commit/ef609c896f209ecffd8130c3e3327ca8a8157e72
  if ((HIWORD(NppVersion) > 8) or
      ((HIWORD(NppVersion) = 8) and
        (((LOWORD(NppVersion) >= 41) and (not (LOWORD(NppVersion) in [191, 192, 193]))) or
          (LOWORD(NppVersion) in [5, 6, 7, 8, 9])))) then
    NppVersion := SendNppMessage(NPPM_GETNPPVERSION, 1, 0);

  Result := NppVersion;
end;

function TNppPlugin.SendNppMessage(Msg: Cardinal; _WParam: NativeUInt; _LParam: NativeInt): LRESULT;
begin
  Result := SendMessageW(self.NppData.NppHandle, Msg, WPARAM(_WParam), LPARAM(_LParam));
end;

function TNppPlugin.SendNppMessage(Msg: Cardinal; _WParam: NativeUInt; APParam: Pointer): LRESULT;
begin
  Result := SendNppMessage(Msg, _WParam, NativeInt(APParam));
end;

function TNppPlugin.GetCurrentScintilla: HWND;
var
  Idx: Integer;
begin
  Result := Self.NppData.ScintillaMainHandle;
  SendNppMessage(NPPM_GETCURRENTSCINTILLA, 0, @Idx);
  if Idx <> 0 then
    Result := Self.NppData.ScintillaSecondHandle;
end;

/// since 8.0
/// A return value of `true` means the NPPM_ADDTOOLBARICON_FORDARKMODE message is defined
/// https://community.notepad-plus-plus.org/topic/21652/add-new-api-nppm_addtoolbaricon_fordarkmode-for-dark-mode
function TNppPlugin.SupportsDarkMode: Boolean;
begin
  Result := HIWORD(GetNppVersion) >= 8;
end;

/// since 8.3
/// *** MAJOR BREAKING CHANGE ***
/// A return value of `true` means that x64 editors return 64-bit character and line positions,
/// i.e., sizeof(Sci_Position) == sizeof(NativeInt), and sizeof(Sci_PositionU) == sizeof(SIZE_T)
/// https://community.notepad-plus-plus.org/topic/22471/recompile-your-x64-plugins-with-new-header
function TNppPlugin.SupportsBigFiles: Boolean;
var
  NppVersion: Cardinal;
begin
  NppVersion := GetNppVersion;
  Result :=
    (HIWORD(NppVersion) > 8) or
    ((HIWORD(NppVersion) = 8) and
      // 8.3 => 8,3 *not* 8,30
      ((LOWORD(NppVersion) in [3, 4]) or
       // Also check for N++ versions 8.1.9.1, 8.1.9.2 and 8.1.9.3
       ((LOWORD(NppVersion) > 21) and (not (LOWORD(NppVersion) in [191, 192, 193])))));
end;

/// since 8.4.3
/// A return value of `true` means the 64-bit APIs added in Scintilla 5.2.3 are available
/// https://groups.google.com/g/scintilla-interest/c/mPLwYdC0-FE
/// https://github.com/notepad-plus-plus/notepad-plus-plus/commit/ed4bb1a93e763001aac842698fcde0856ba8b0bc
function TNppPlugin.HasFullRangeApis: Boolean;
var
  NppVersion: Cardinal;
begin
  NppVersion := GetNppVersion;
  Result :=
    (HIWORD(NppVersion) > 8) or
    ((HIWORD(NppVersion) = 8) and
       ((LOWORD(NppVersion) >= 43) and (not (LOWORD(NppVersion) in [191, 192, 193]))));
end;

end.
