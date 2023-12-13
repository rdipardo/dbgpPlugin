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

unit NppDockingForm;

interface

uses
  Windows, Messages, SysUtils, Classes, NppPlugin, NppForms, Vcl.Forms, Vcl.Controls;

{$I '..\..\Include\Docking.inc'}
{$I '..\..\Include\DockingResource.inc'}

type
  TNppDockingForm = class(TNppForm) {TCustomForm}
  private
    { Private declarations }
    FOnDock: TNotifyEvent;
    FOnFloat: TNotifyEvent;
    procedure RemoveControlParent(control: TControl);
  protected
    { Protected declarations }
    ToolbarData: TToolbarData;
    NppDefaultDockingMask: Cardinal;
    // @todo: change caption and stuff....
    procedure OnWM_NOTIFY(var msg: TWMNotify); message WM_NOTIFY;
    property OnDock: TNotifyEvent read FOnDock write FOnDock;
    property OnFloat: TNotifyEvent read FOnFloat write FOnFloat;
  public
    { Public declarations }
    CmdId, DlgId: Integer;
    constructor Create(NppParent: TNppPlugin; DlgId: Integer); reintroduce;
      overload; virtual;
    constructor Create(AOwner: TNppForm; DlgId: Integer); reintroduce;
      overload; virtual;
    destructor Destroy; override;
    procedure Show;
    procedure Hide;
    /// NOTE.
    /// dock position is saved in config.xml as a GUIConfig element with the
    /// DockingManager attribute; you should delete this between launches when
    /// testing different configurations
    procedure RegisterDockingForm(MaskStyle: Cardinal = DWS_DF_CONT_LEFT);
    procedure UpdateDisplayInfo; overload;
    procedure UpdateDisplayInfo(Info: String); overload;
  published
    { Published declarations }
  end;

implementation

{$R *.dfm}

constructor TNppDockingForm.Create(NppParent: TNppPlugin; DlgId: Integer);
begin
  inherited Create(NppParent);
  self.DlgId := DlgId;
  self.CmdId := self.Npp.CmdIdFromDlgId(DlgId);
  self.RegisterDockingForm(self.NppDefaultDockingMask);
  self.RemoveControlParent(self);
end;

constructor TNppDockingForm.Create(AOwner: TNppForm; DlgId: Integer);
begin
  inherited Create(AOwner);
  self.DlgId := DlgId;
  self.RegisterDockingForm(self.NppDefaultDockingMask);
  self.RemoveControlParent(self);
end;

destructor TNppDockingForm.Destroy;
begin
  with (self.ToolbarData) do
  begin
    if Assigned(Title) then
      Dispose(Title);
    if Assigned(ModuleName) then
      Dispose(ModuleName);
    if Assigned(AdditionalInfo) then
      Dispose(AdditionalInfo);
  end;
  inherited;
end;

procedure TNppDockingForm.OnWM_NOTIFY(var msg: TWMNotify);
begin
  if (self.Npp.NppData.NppHandle <> msg.NMHdr.hwndFrom) then
  begin
    self.RemoveControlParent(self);
    inherited;
    exit;
  end;
  msg.Result := 0;

  if (msg.NMHdr.code = DMN_CLOSE) then
  begin
    self.DoHide;
  end;
  if ((msg.NMHdr.code and $FFFF) = DMN_FLOAT) then
  begin
    // msg.NMHdr.code shr 16 - container
    if Assigned(FOnFloat) then
      FOnFloat(self);
  end;
  if ((msg.NMHdr.code and $FFFF) = DMN_DOCK) then
  begin
    // msg.NMHdr.code shr 16 - container
    if Assigned(FOnDock) then
      FOnDock(self);
  end;
end;

procedure TNppDockingForm.RegisterDockingForm
  (MaskStyle: Cardinal = DWS_DF_CONT_LEFT);
begin
  if (not Assigned(self.Npp)) then
    exit;

  self.HandleNeeded;
  FillChar(self.ToolbarData, sizeof(TToolbarData), 0);

  if (not self.Icon.Empty) then
  begin
    self.ToolbarData.IconTab := self.Icon.Handle;
    self.ToolbarData.Mask := MaskStyle or DWS_ICONTAB;
  end;

  self.ToolbarData.ClientHandle := self.Handle;

  self.ToolbarData.DlgId := self.DlgId;
  self.ToolbarData.Mask := self.ToolbarData.Mask or DWS_ADDINFO or DWS_USEOWNDARKMODE;

  GetMem(self.ToolbarData.Title, MAX_PATH * sizeof(nppPChar));
  GetMem(self.ToolbarData.ModuleName, MAX_PATH * sizeof(nppPChar));
  GetMem(self.ToolbarData.AdditionalInfo, MAX_PATH * sizeof(nppPChar));

  StringToWideChar(self.Caption, self.ToolbarData.Title, MAX_PATH);
  SetLastError(0);
  GetModuleFileNameW(HInstance, self.ToolbarData.ModuleName, MAX_PATH);
  if GetLastError = ERROR_SUCCESS then
  begin
    StrPLCopy(self.ToolbarData.ModuleName,
      ExtractFileName(self.ToolbarData.ModuleName), MAX_PATH);
    StringToWideChar('', self.ToolbarData.AdditionalInfo, 1);
  end;
  SafeSendMessage(self.Npp.NppData.NppHandle, NPPM_DMMREGASDCKDLG, 0, @self.ToolbarData);
  self.Visible := true;
end;

procedure TNppDockingForm.Show;
begin
  if (not Assigned(self.Npp)) then
    exit;

  SafeSendMessage(self.Npp.NppData.NppHandle, NPPM_DMMSHOW, 0,
    LPARAM(self.Handle));
  inherited;
  self.DoShow;
end;

procedure TNppDockingForm.Hide;
begin
  if (not Assigned(self.Npp)) then
    exit;

  SafeSendMessage(self.Npp.NppData.NppHandle, NPPM_DMMHIDE, 0,
    LPARAM(self.Handle));
  self.DoHide;
end;

// This hack prevents the Win Dialog default procedure from an endless loop while
// looking for the previous component, while in a floating state.
// I still don't know why the pointer climbs up to the docking dialog that holds this one
// but this works for now.
// ==========================================================================================
// Changed logic to *set* (not clear) the WS_EX_CONTROLPARENT flag:
// https://github.com/kbilsted/NotepadPlusPlusPluginPack.Net/issues/17#issuecomment-683455467
// - R.D.
// ==========================================================================================
procedure TNppDockingForm.RemoveControlParent(control: TControl);
var
  wincontrol: TWinControl;
  i: Integer;
  r: NativeInt;
begin
  if (control is TWinControl) then
  begin
    wincontrol := control as TWinControl;
    wincontrol.HandleNeeded;
    r := Windows.GetWindowLongPtr(wincontrol.Handle, GWL_EXSTYLE);
    if (r and WS_EX_CONTROLPARENT <> WS_EX_CONTROLPARENT) then
    begin
      Windows.SetWindowLongPtr(wincontrol.Handle, GWL_EXSTYLE,
        r or WS_EX_CONTROLPARENT);
    end;
  end;
  for i := control.ComponentCount - 1 downto 0 do
  begin
    if (control.Components[i] is TControl) then
      self.RemoveControlParent(control.Components[i] as TControl);
  end;
end;

procedure TNppDockingForm.UpdateDisplayInfo;
begin
  self.UpdateDisplayInfo('');
end;

procedure TNppDockingForm.UpdateDisplayInfo(Info: String);
begin
  if (not Assigned(self.Npp)) then
    exit;

  StringToWideChar(Info, self.ToolbarData.AdditionalInfo, MAX_PATH);
  SafeSendMessage(self.Npp.NppData.NppHandle, NPPM_DMMUPDATEDISPINFO, 0,
    LPARAM(self.Handle));
end;

end.
