unit NppForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NppPlugin;

type
  TNppForm = class(TForm)
  private
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure RegisterForm();
    procedure UnregisterForm();
    procedure DoClose(var Action: TCloseAction); override;
  public
    { Public declarations }
    Npp: TNppPlugin;
    DefaultCloseAction: TCloseAction;
    constructor Create(NppParent: TNppPlugin); overload;
    constructor Create(AOwner: TNppForm); overload;
    destructor Destroy; override;
//    procedure Show;
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
  inherited Create(Aowner);
  self.RegisterForm();
end;

destructor TNppForm.Destroy;
begin
  if (self.HandleAllocated) then
  begin
    self.UnregisterForm();
  end;
  inherited;
end;

// I'm sure there is a better way arround this, but hack it does the job for now...
// TODO: A kickass solution would be to have a TWinControl that would actually encapuslate the NPP HWND...
procedure TNppForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if (not windows.IsWindow(self.Npp.NppData.NppHandle)) then exit;
  if Parent = nil then
    Params.WndParent := self.Npp.NppData.NppHandle;
end;

//procedure TNppForm.Show;
//begin
//  SendMessage(self.Npp.NppData.NppHandle, WM_DMM_SHOW, 0, LPARAM(self.Handle));
//  inherited;
//end;

procedure TNppForm.RegisterForm();
var
  r: Integer;
begin
  r:=SendMessage(self.Npp.NppData.NppHandle, WM_MODELESSDIALOG, MODELESSDIALOGADD, self.Handle);
{
  if (r = 0) then
  begin
    ShowMessage('Failed reg of form '+form.Name);
    exit;
  end;
}
end;

procedure TNppForm.UnregisterForm();
var
  r: Integer;
begin
  if (not self.HandleAllocated) then exit;
  r:=SendMessage(self.Npp.NppData.NppHandle, WM_MODELESSDIALOG, MODELESSDIALOGREMOVE, self.Handle);
{
  if (r = 0) then
  begin
    ShowMessage('Failed unreg form '+form.Name);
    exit;
  end;
}
end;

procedure TNppForm.DoClose(var Action: TCloseAction);
begin
  if (self.DefaultCloseAction <> caNone) then Action := self.DefaultCloseAction;
  inherited;
end;


end.
