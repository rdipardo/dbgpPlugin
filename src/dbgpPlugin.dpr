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

library dbgpPlugin;
{$R 'dbgpPluginRes.res'}

{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$ENDIF}

{$WARN SYMBOL_PLATFORM OFF} 

uses
  Windows,
  Messages,
  nppplugin in 'lib\nppplugin.pas',
  Base64 in 'lib\Base64.pas',
  dbgpnppplugin in 'lib\dbgpnppplugin.pas',
  DbgpWinSocket in 'lib\DbgpWinSocket.pas',
  MainForm in 'forms\npp\MainForm.pas' {NppDockingForm1},
  NppForms in 'forms\npp\NppForms.pas' {NppForm},
  NppDockingForm in 'forms\npp\NppDockingForm.pas',
  ConfigForm in 'forms\npp\ConfigForm.pas' {ConfigForm1},
  AboutForm in 'forms\npp\AboutForm.pas' {AboutForm1},
  DebugStackForm in 'forms\plugin\DebugStackForm.pas' {DebugStackForm1},
  DebugEvalForm in 'forms\plugin\DebugEvalForm.pas' {DebugEvalForm1},
  DebugInspectorForm in 'forms\plugin\DebugInspectorForm.pas' {DebugInspectorForm1},
  DebugRawForm in 'forms\plugin\DebugRawForm.pas' {DebugRawForm1},
  DebugBreakpointsForm in 'forms\plugin\DebugBreakpointsForm.pas' {DebugBreakpointsForm1},
  DebugBreakpointEditForm in 'forms\plugin\DebugBreakpointEditForm.pas' {DebugBreakpointEditForm1},
  DebugVarForms in 'forms\plugin\DebugVarForms.pas' {DebugVarForm},
  DebugContextForms in 'forms\plugin\DebugContextForms.pas' {DebugContextForm},
  DebugWatchForms in 'forms\plugin\DebugWatchForms.pas' {DebugWatchFrom},
  DebugEditWatchForms in 'forms\plugin\DebugEditWatchForms.pas' {DebugEditWatchForm};

procedure DLLEntryPoint(dwReason: DWord);
begin
  case dwReason of
  DLL_PROCESS_ATTACH:
  begin
    // create the main object
    Npp := TDbgpNppPlugin.Create;
  end;
  DLL_PROCESS_DETACH:
  begin
    Npp.Destroy;
  end;
  //DLL_THREAD_ATTACH: MessageBeep(0);
  //DLL_THREAD_DETACH: MessageBeep(0);
  end;
end;

procedure setInfo(NppData: TNppData); cdecl; export;
begin
  Npp.SetInfo(NppData);
end;

function getName(): PWchar; cdecl; export;
begin
  Result := Npp.GetName;
end;

function getFuncsArray(var nFuncs:integer):Pointer;cdecl; export;
begin
  Result := Npp.GetFuncsArray(nFuncs);
end;

procedure beNotified(sn: PSciNotification); cdecl; export;
begin
  Npp.BeNotified(sn);
end;

function messageProc(msg: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; cdecl; export;
var xmsg:TMessage;
begin
  xmsg.Msg := msg;
  xmsg.WParam := wParam;
  xmsg.LParam := lParam;
  xmsg.Result := 0;
  Npp.MessageProc(xmsg);
  Result := xmsg.Result;
end;

function isUnicode():boolean; cdecl; export;
begin
  Result := true;
end;


exports
  setInfo, getName, getFuncsArray, beNotified, messageProc, isUnicode;

begin
{$IFNDEF RELEASE}
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
{$ENDIF}
  { First, assign the procedure to the DLLProc variable }
  DllProc := @DLLEntryPoint;
  { Now invoke the procedure to reflect that the DLL is attaching to the process }
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.
