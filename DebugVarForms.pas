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

unit DebugVarForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvDockTree, JvDockControlForm, JvDockVIDStyle, JvDockVSNetStyle,
  JvComponentBase, VirtualTrees, DbgpWinSocket, DebugInspectorForm, nppplugin,
  Menus, StrUtils, NppDockingForm;

type
  TNodeCompareData = record
    FullName: string;
    states: TVirtualNodeStates;
    data: string;
  end;
  PNodeCompareData = ^TNodeCompareData;
  TDebugVarForm = class(TNppDockingForm)
    VirtualStringTree1: TVirtualStringTree;
    JvDockClient1: TJvDockClient;
    procedure FormCreate(Sender: TObject);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure VirtualStringTree1DblClick(Sender: TObject);
    procedure VirtualStringTree1PaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
  private
    { Private declarations }
    procedure SubSetVars(ParentNode: PVirtualNode; list:TPropertyItems; CompareList: TList);
    procedure GenerateCompareData(var list: TList; node: PVirtualNode);
    function GetCompareData(FullName: string; list: TList): PNodeCompareData;
  public
    { Public declarations }
    Npp: TNppPlugin;
    procedure SetVars(list: TPropertyItems);
    procedure ClearVars;
  end;
  TPropertyItemEx = record
    p: TPropertyItem;
    changed: boolean;
  end;
  PPropertyItemEx = ^TPropertyItemEx;
var
  DebugVarForm: TDebugVarForm;

implementation

uses
  MainForm;
{$R *.dfm}

procedure TDebugVarForm.FormCreate(Sender: TObject);
begin
  self.VirtualStringTree1.NodeDataSize := SizeOf(TPropertyItemEx);
end;

// insane

function TDebugVarForm.GetCompareData(FullName: string; list: TList): PNodeCompareData;
var
  i: integer;
begin
  for i:=0 to list.Count-1 do
  begin
    Result := list[i];
    if (Result^.FullName = FullName) then exit;
  end;
  Result := nil;
end;

procedure TDebugVarForm.GenerateCompareData(var list: TList; node: PVirtualNode);
var
  node1: PVirtualNode;
  data: PNodeCompareData;
  Item: PPropertyItem;
begin
  if (node = nil) then exit;
  node1 := node.FirstChild;
  while (node1 <> nil) do
  begin
    New(data);
    Item := self.VirtualStringTree1.GetNodeData(node1);
    data^.FullName := Item^.fullname;
    data^.states := [];
    if (vsExpanded in node1.States) then Include(data^.states, vsExpanded);
    data^.data := Item^.data;
    list.Add(data);
    self.GenerateCompareData(list, node1);
    node1 := node1.NextSibling;
  end;
end;

procedure TDebugVarForm.SetVars(list: TPropertyItems);
var
  cmplist: TList;
  i: integer;
  oldxy: TPoint;

begin
  // save state (expanded)
  // save data for compare
  cmplist := TList.Create;
  self.GenerateCompareData(cmplist, self.VirtualStringTree1.RootNode);

  oldxy := self.VirtualStringTree1.OffsetXY;

  self.VirtualStringTree1.Clear;
  self.VirtualStringTree1.BeginUpdate;

  self.SubSetVars(nil, list, cmplist);

  self.VirtualStringTree1.EndUpdate;
  for i:=0 to cmplist.Count-1 do
  begin
    Dispose(cmplist[i]);
  end;
  self.VirtualStringTree1.OffsetXY := oldxy;
end;

procedure TDebugVarForm.SubSetVars(ParentNode: PVirtualNode;
  list: TPropertyItems; CompareList: TList);
var
  i: Integer;
  Node: PVirtualNode;
  Item: PPropertyItem;
  ItemEx: PPropertyItemEx;
  CompareData: PNodeCompareData;
begin

  for i:=0 to Length(list)-1 do
  begin
    Node := self.VirtualStringTree1.AddChild(ParentNode);
    Item := self.VirtualStringTree1.GetNodeData(Node);
    ItemEx := self.VirtualStringTree1.GetNodeData(Node);

    Item^.name := list[i].name;
    Item^.fullname := list[i].fullname;
    Item^.datatype := list[i].datatype;
    Item^.classname := list[i].classname;
    Item^.constant := list[i].constant;
    Item^.haschildren := list[i].haschildren;
    Item^.size := list[i].size;
    Item^.page := list[i].page;
    Item^.pagesize := list[i].pagesize;
    Item^.address := list[i].address;
    Item^.key := list[i].key;
    Item^.numchildren := list[i].numchildren;
    Item^.data := list[i].data;
    Item^.children := nil;

    ItemEx^.changed := false;
    // get compare data
    CompareData := self.GetCompareData(Item^.fullname, CompareList);
    if (CompareData <> nil) then
    begin
      if (Item^.data <> CompareData^.data) then
      begin
        ItemEx^.changed := true;
        // hilight
      end;
      if (vsExpanded in CompareData^.states) then Include(Node.States, vsExpanded);
    end
    else
    begin
      ItemEx^.changed := true; // ?
    end;

    if ((list[i].numchildren <> '0') and (list[i].children <> nil)) then
    begin
      self.SubSetVars(Node, list[i].children^, CompareList);
    end;
  end;

end;

procedure TDebugVarForm.VirtualStringTree1GetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
var
  Item: PPropertyItem;
begin
  Item := PPropertyItem(Sender.GetNodeData(Node));

  case Column of
  0: if (Node.Parent <> Sender.RootNode) then CellText := Item^.name else CellText := Item^.fullname;
  //1: CellText := Item^.data;
  1:
  begin
    if (Item^.datatype = 'object') then
      CellText := Item^.classname
    else
    CellText := AnsiReplaceStr(Item^.data, #10, #13+#10);
  end;
  2: CellText := Item^.datatype;
  end;
end;

procedure TDebugVarForm.VirtualStringTree1PaintText(
  Sender: TBaseVirtualTree; const TargetCanvas: TCanvas;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
var
  ItemEx: PPropertyItemEx;
begin
  ItemEx := Sender.GetNodeData(Node);
  if (ItemEx^.changed) then TargetCanvas.Font.Color := clRed;
end;

// show data
procedure TDebugVarForm.VirtualStringTree1DblClick(Sender: TObject);
var
  Item: PPropertyItem;
  i: TDebugInspectorForm1;
begin
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  Item := PPropertyItem(self.VirtualStringTree1.GetNodeData(self.VirtualStringTree1.FocusedNode));
  if (Item^.datatype = 'array') or (Item^.datatype = 'object') then
  begin
    TNppDockingForm1(self.Owner).DoEval(Item^.fullname);
  end;
  if (Item^.datatype <> 'string') then exit;
  i := TDebugInspectorForm1.Create(self);
  i.Show;
  i.SetData(Item.data);
  //i.AutoSize := true;
  //i.AutoSize := false; // wtf
  // register witn npp?
end;

procedure TDebugVarForm.ClearVars;
begin
  self.VirtualStringTree1.Clear;
end;

end.