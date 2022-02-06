unit PropsFrm;

interface

uses
  Windows, Messages, Classes, Controls, Graphics, Forms, Types, TypInfo,
  StdCtrls, ExtCtrls, Buttons,

  UdTypes, UdObject, UdPropInsp, UdPropEditors;

type
  TPropsForm = class(TForm)
    Image2: TImage;
    Image1: TImage;

    pnlPropInsp: TPanel;
    cbxSelection: TComboBox;
    btnPickMode: TSpeedButton;
    btnSelectObjs: TSpeedButton;
    btnQuickSelect: TSpeedButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPickModeClick(Sender: TObject);
    procedure btnSelectObjsClick(Sender: TObject);
    procedure btnQuickSelectClick(Sender: TObject);
    procedure cbxSelectionChange(Sender: TObject);

  private
    FDocument: TUdObject;
    FPropInsp: TUdPropertyInspector;

    FGroupObjsList: TStringList;

  protected
    function GetNoSelection(): Boolean;
    function GetInspObjectCount: Integer;

    procedure OnPropInspBeforeSetValue(Sender: TObject; APropName: string; APropTypeInfo: PTypeInfo; var AValue: string; var AHandled: Boolean);
    procedure OnPropInspAfterSetValue(Sender: TObject; APropName: string; APropTypeInfo: PTypeInfo; var AValue: string);
    procedure OnPropInspGetEditorClass(Sender: TObject; AInstance: TPersistent; APropInfo: PPropInfo; var AEditorClass: TUdPropEditorClass);

    procedure AddAllInspObjects();
    procedure UpdateSelectionCombox();

  public
    procedure AddInspObject(AObject: TPersistent);
    procedure AddInspObjects(AObjects: TList);

    procedure RemoveInspObject(AObject: TPersistent);
    procedure RemoveInspObjects(AObjects: TList);

    procedure ClearInspObjects();

    procedure ObjectModified(AObject: TPersistent);

  public
    property NoSelection: Boolean read GetNoSelection;
    property InspObjectCount: Integer read GetInspObjectCount;

    property Document: TUdObject read FDocument write FDocument;

  end;


implementation

uses
  SysUtils, UdDocument, UdPropEditorsEx, UdActionSelection;

{$R *.dfm}



//================================================================================================

procedure TPropsForm.FormCreate(Sender: TObject);
begin
  FPropInsp := TUdPropertyInspector.Create(nil);
  FPropInsp.Parent := pnlPropInsp;
  FPropInsp.Align := alClient;

  FPropInsp.OnBeforeSetValue := OnPropInspBeforeSetValue;
  FPropInsp.OnAfterSetValue  := OnPropInspAfterSetValue;
  FPropInsp.OnGetEditorClass := OnPropInspGetEditorClass;

  FGroupObjsList := TStringList.Create();

  btnPickMode.Glyph.Assign(Image1.Picture.Bitmap);
end;

procedure TPropsForm.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(FGroupObjsList) then
  begin
    for I := FGroupObjsList.Count - 1 downto 0 do TObject(FGroupObjsList.Objects[I]).Free;
    FGroupObjsList.Free;
  end;
  FGroupObjsList := nil;

  if Assigned(FPropInsp) then FPropInsp.Free;
  FPropInsp := nil;
end;

procedure TPropsForm.FormShow(Sender: TObject);
begin
//...
end;





//---------------------------------------------------------------------------------

function TPropsForm.GetNoSelection(): Boolean;
begin
  Result := (FPropInsp.ObjectCount = 1) and (FPropInsp.Objects[0] = FDocument);
end;

function TPropsForm.GetInspObjectCount: Integer;
begin
  Result := FPropInsp.ObjectCount;
end;

procedure TPropsForm.AddInspObject(AObject: TPersistent);
var
  N: Integer;
  LList: TList;
begin
  if not Assigned(AObject) then Exit;

  if not AObject.InheritsFrom(TUdDocument) then
  begin
    N := FGroupObjsList.IndexOf(AObject.ClassName);
    if N >= 0 then LList := TList(FGroupObjsList.Objects[N]) else LList := nil;

    if not Assigned(LList) then
    begin
      LList := TList.Create;
      FGroupObjsList.AddObject(AObject.ClassName, LList);
    end;

    LList.Add(AObject);
  end;

  Self.UpdateSelectionCombox();
  Self.AddAllInspObjects();
end;

procedure TPropsForm.AddInspObjects(AObjects: TList);
var
  I: Integer;
  N: Integer;
  LList: TList;
  LObject: TPersistent;
begin
  if not Assigned(AObjects) then Exit;

  for I := 0 to AObjects.Count - 1 do
  begin
    LObject := AObjects[I];
    if not Assigned(LObject) or LObject.InheritsFrom(TUdDocument) then Continue;

    N := FGroupObjsList.IndexOf(LObject.ClassName);
    if N >= 0 then LList := TList(FGroupObjsList.Objects[N]) else LList := nil;
    
    if not Assigned(LList) then
    begin
      LList := TList.Create;
      FGroupObjsList.AddObject(LObject.ClassName, LList);
    end;

    LList.Add(LObject);
  end;

  Self.UpdateSelectionCombox();
  Self.AddAllInspObjects();
end;

procedure TPropsForm.RemoveInspObject(AObject: TPersistent);
var
  N: Integer;
  LList: TList;
begin
  if not Assigned(AObject) then Exit;

  N := FGroupObjsList.IndexOf(AObject.ClassName);
  if N >= 0 then LList := TList(FGroupObjsList.Objects[N]) else LList := nil;
  
  if Assigned(LList) then
  begin
    LList.Remove(AObject);
    if LList.Count <= 0 then
    begin
      LList.Free;
      FGroupObjsList.Delete(N);
    end;
  end;

  if FPropInsp.Remove(AObject) then Self.UpdateSelectionCombox();
end;

procedure TPropsForm.RemoveInspObjects(AObjects: TList);
var
  I: Integer;
  N: Integer;
  LList: TList;
  LObject: TPersistent;
begin
  if not Assigned(AObjects) then Exit;

  for I := 0 to AObjects.Count - 1 do
  begin
    LObject := AObjects[I];
    if not Assigned(LObject) or LObject.InheritsFrom(TUdDocument) then Continue;

    N := FGroupObjsList.IndexOf(LObject.ClassName);
    if N >= 0 then LList := TList(FGroupObjsList.Objects[N]) else LList := nil;
      
    if Assigned(LList) then
    begin
      LList.Remove(LObject);
      if LList.Count <= 0 then
      begin
        LList.Free;
        FGroupObjsList.Delete(N);
      end;
    end;

    FPropInsp.Remove(LObject)
  end;

  Self.UpdateSelectionCombox();
end;


procedure TPropsForm.ClearInspObjects;
var
  I: Integer;
begin
  FPropInsp.Clear();

  for I := FGroupObjsList.Count - 1 downto 0 do TObject(FGroupObjsList.Objects[I]).Free;
  FGroupObjsList.Clear();

  cbxSelection.Clear();

  Self.UpdateSelectionCombox();
end;


procedure TPropsForm.ObjectModified(AObject: TPersistent);
begin
  if not FPropInsp.ObjectsLocked and (FPropInsp.IndexOf(AObject) >= 0) then
    FPropInsp.Modified();
end;



procedure TPropsForm.AddAllInspObjects();
var
  I, J: Integer;
  LList: TList;
  LAllList: TList;
begin
  FPropInsp.Clear();

  LAllList := TList.Create;
  try
    for I := 0 to FGroupObjsList.Count - 1 do
    begin
      LList := TList(FGroupObjsList.Objects[I]);
      for J := 0 to LList.Count - 1 do LAllList.Add(LList[J]);

      FPropInsp.AddObjects(LAllList);
    end;
  finally
    LAllList.Free;
  end;
end;

procedure TPropsForm.UpdateSelectionCombox();
var
  I, M: Integer;
  LStr: string;
  LList: TList;
begin
  cbxSelection.OnChange := nil;
  try
    if FGroupObjsList.Count <= 0 then
    begin
      cbxSelection.Items.Clear();
      cbxSelection.Items.Add('No Selection');
      cbxSelection.ItemIndex := 0;

      if Assigned(FDocument) then FPropInsp.Add(FDocument);
    end
    else begin
      cbxSelection.Items.Clear();

      M := 0;
      for I := 0 to FGroupObjsList.Count - 1 do
      begin
        LList := TList(FGroupObjsList.Objects[I]);
        M := M + LList.Count;

        LStr := FGroupObjsList[I];
        if Pos('TUd', LStr) = 1 then Delete(LStr, 1, 3);

        cbxSelection.Items.Add(LStr  + '  (' + IntToStr(LList.Count) + ')' );
      end;
      cbxSelection.Items.Insert(0, 'All' + '  (' + IntToStr(M) + ')');

      if FGroupObjsList.Count = 1 then
        cbxSelection.ItemIndex := 1
      else
        cbxSelection.ItemIndex := 0;
    end;
  finally
    cbxSelection.OnChange := cbxSelectionChange;
  end;
end;

procedure TPropsForm.cbxSelectionChange(Sender: TObject);
var
  N: Integer;
  LStr: string;
  LList: TList;
begin
  LStr := cbxSelection.Text;
  N := Pos(' ', LStr);
  if N > 0 then Delete(LStr, N, Length(LStr));

  if LStr = 'All' then
  begin
    AddAllInspObjects();
  end
  else begin
    LStr := 'TUd' + LStr;

    N := FGroupObjsList.IndexOf(LStr);
    if N >= 0 then LList := TList(FGroupObjsList.Objects[N]) else LList := nil;

    if Assigned(LList) then
    begin
      FPropInsp.Clear();
      FPropInsp.AddObjects(LList);
    end;
  end;
end;


//---------------------------------------------------------------------------------

procedure TPropsForm.OnPropInspBeforeSetValue(Sender: TObject; APropName: string; APropTypeInfo: PTypeInfo; var AValue: string; var AHandled: Boolean);
begin
  TUdDocument(FDocument).BeginUndo(string(APropTypeInfo^.Name));
end;

procedure TPropsForm.OnPropInspAfterSetValue(Sender: TObject; APropName: string; APropTypeInfo: PTypeInfo; var AValue: string);
begin
  TUdDocument(FDocument).EndUndo();
end;


procedure TPropsForm.OnPropInspGetEditorClass(Sender: TObject; AInstance: TPersistent;
  APropInfo: PPropInfo; var AEditorClass: TUdPropEditorClass);
var
  LTypeInfo: PTypeInfo;
begin
  if AInstance.InheritsFrom(TUdObject) then
  begin
    LTypeInfo := APropInfo.PropType^;

    if (LTypeInfo^.Kind = tkClass) then
    begin
      if (LTypeInfo^.Name = 'TUdDimStyle') and (APropInfo^.Name = 'ActiveDimStyle')  then AEditorClass := TUdDimStylePropEditorEx  else
      if (LTypeInfo^.Name = 'TUdTextStyle') and (APropInfo^.Name = 'ActiveTextStyle') then AEditorClass := TUdTextStylePropEditorEx else
      if (LTypeInfo^.Name = 'TUdColor') and (APropInfo^.Name = 'ActiveColor')     then AEditorClass := TUdColorPropEditorEx     else
      if (LTypeInfo^.Name = 'TUdLineType') and (APropInfo^.Name = 'ActiveLineType')  then AEditorClass := TUdLineTypePropEditorEx  else
      if (LTypeInfo^.Name = 'TUdLayer')  and (APropInfo^.Name = 'ActiveLayer')    then AEditorClass := TUdLayerPropEditorEx     else
      if (LTypeInfo^.Name = 'TUdLayout') and (APropInfo^.Name = 'ActiveLayout')    then AEditorClass := TUdLayoutPropEditorEx   ;// else
    end
    else if (LTypeInfo^.Kind = tkInteger) then
    begin
      if (LTypeInfo^.Name = 'TUdLineWeight') then AEditorClass := TUdLineWeightPropEditorEx ;
    end;
  end;
end;




//---------------------------------------------------------------------------------

procedure TPropsForm.btnPickModeClick(Sender: TObject);
begin
  if btnPickMode.Tag = 0 then
  begin
    btnPickMode.Tag := 1;
    btnPickMode.Glyph.Assign(Image2.Picture.Bitmap);
    //....
  end
  else begin
    btnPickMode.Tag := 0;
    btnPickMode.Glyph.Assign(Image1.Picture.Bitmap);
    //....
  end;
end;

procedure TPropsForm.btnSelectObjsClick(Sender: TObject);
begin
  if Assigned(FDocument) then
  begin
    TUdDocument(FDocument).ActiveLayout.RemoveAllSelected();
    TUdDocument(FDocument).ActiveLayout.ActionAdd(TUdActionSelection);
    TUdDocument(FDocument).ActiveLayout.XCursorStyle := csPick;
  end;
end;

procedure TPropsForm.btnQuickSelectClick(Sender: TObject);
begin
//
end;

end.
