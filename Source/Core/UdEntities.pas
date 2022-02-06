{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdEntities;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdConsts, UdTypes, UdIntfs, UdObject,
  UdEntity;

type
  //*** UdEntities ***//
  TUdEntities = class(TUdObject, IUdObjectCollection)
  private
    FList: TList;

    FOnAddEntities: TUdEntitiesEvent;
    FOnRemoveEntities: TUdEntitiesEvent;
    FOnRemovedEntities: TNotifyEvent;

  protected
    FLoading: Boolean;

    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function GetBoundsRect: TRect2D;

    function GetCount: Integer;
    function GetItems(AIndex: Integer): TUdEntity;

    function InternalAdd(AEntity: TUdEntity): Boolean; //; ACheckExists: Boolean = True

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    function Add(AEntity: TUdEntity): Boolean; overload;
    function Add(AEntities: TUdEntityArray): Boolean; overload;

    function Insert(AIndex: Integer; AEntity: TUdEntity): Boolean; overload;

    function Remove(AEntity: TUdEntity): Boolean; overload;
    function Remove(AEntities: TUdEntityArray): Boolean; overload;

    function IndexOf(AEntity: TUdEntity): Integer; overload;

    procedure ChangeOrder(AEntity: TUdEntity; ToBack: Boolean);
    function Swap(AEntity1: TUdEntity; AEntity2: TUdEntity): Boolean;

    procedure Update();

    procedure Clear();


    //IUdObjectCollection ------------------
    function Add(AObj: TUdObject): Boolean; overload;

    function Insert(AIndex: Integer; AObj: TUdObject): Boolean; overload;

    function Remove(AObj: TUdObject): Boolean; overload;
    function RemoveAt(AIndex: Integer): Boolean;

    function IndexOf(AObj: TUdObject): Integer; overload;
    function Contains(AObj: TUdObject): Boolean;

    //----------------------------------------

    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property List: TList read FList;
    property Items[Index: Integer]: TUdEntity read GetItems;

  published
    property Count: Integer read GetCount;
    property BoundsRect: TRect2D read GetBoundsRect;

    property OnAddEntities: TUdEntitiesEvent read FOnAddEntities write FOnAddEntities;
    property OnRemoveEntities: TUdEntitiesEvent read FOnRemoveEntities write FOnRemoveEntities;
    property OnRemovedEntities: TNotifyEvent read FOnRemovedEntities write FOnRemovedEntities;
  end;


implementation

uses
  SysUtils,
  UdDocument, UdLayout, UdMath, UdUtils, UdStreams, UdXml;





//==================================================================================================
{ TUdEntities }

constructor TUdEntities.Create();
begin
  inherited;
  FList := TList.Create;
  FLoading := False;
end;

destructor TUdEntities.Destroy;
begin
  Self.Clear();

  FList.Free;
  FList := nil;

  inherited;
end;


function TUdEntities.GetTypeID: Integer;
begin
  Result := ID_ENTITIES;
end;


procedure TUdEntities.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
var
  I: Integer;
begin
  inherited;

  for I := 0 to FList.Count - 1 do
  begin
    TUdObject(FList[I]).SetDocument(Self.Document, Self.IsDocRegister);
    Self.AddDocObject(TUdObject(FList[I]), False);
  end;
end;




function TUdEntities.GetBoundsRect(): TRect2D;
begin
  Result := GetEntitiesBound(FList, True);
end;




function TUdEntities.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TUdEntities.GetItems(AIndex: Integer): TUdEntity;
begin
  Result := nil;
  if AIndex < 0 then AIndex := AIndex + FList.Count;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  Result := FList[AIndex];
end;





procedure TUdEntities.CopyFrom(AValue: TUdObject);
var
  I: Integer;
  LSrcItem, LDstItem: TUdEntity;
begin
  inherited;

  if not AValue.InheritsFrom(TUdEntities) then Exit;

  if (TUdEntities(AValue).FList.Count > 0) then
  begin
    Self.Clear();

    for I := 0 to TUdEntities(AValue).FList.Count - 1 do
    begin
      LSrcItem := TUdEntity(TUdEntities(AValue).FList[I]);
      if not Assigned(LSrcItem) then Continue;

      LDstItem := TUdEntityClass(LSrcItem.ClassType).Create();
      LDstItem.Assign(LSrcItem);

      LDstItem.Owner := Self;
      LDstItem.SetDocument(Self.Document, Self.IsDocRegister);
      
      FList.Add(LDstItem);
      Self.AddDocObject(LDstItem, False);
    end;
  end;
end;
{
var
  I: Integer;
  LEntity: TUdEntity;
  LEntities: TUdEntities;
begin
  inherited;

  if not AValue.InheritsFrom(TUdEntities) then Exit;

  LEntities := TUdEntities(AValue);

  Self.Clear();
  for I := 0 to LEntities.Count - 1 do
  begin
    LEntity := LEntities.Items[I];

    Self.InternalAdd( LEntity.Clone(Self.Document, Self.IsDocRegister) );
    Self.AddDocObject(AEntity, False);
  end;

end;
}




//---------------------------------------------------------------------

function TUdEntities.InternalAdd(AEntity: TUdEntity): Boolean;
begin
  Result := False;

  if (AEntity = nil) then Exit;
//  if ACheckExists and Self.Find(AEntity) then Exit;

  AEntity.Owner := Self;

  if Self.Document <> nil then
    AEntity.SetDocument(Self.Document, Self.IsDocRegister);

  FList.Add(AEntity);

  Result := True;
end;


function TUdEntities.Add(AEntity: TUdEntity): Boolean;
var
  LEntities: TUdEntityArray;
begin
  Result := False;
  if not InternalAdd(AEntity) then Exit;

  if Self.Document <> nil then
    AEntity.SetDocument(Self.Document, Self.IsDocRegister);

  if not FLoading and Assigned(FOnAddEntities) then
  begin
    System.SetLength(LEntities, 1);
    LEntities[0] := AEntity;
    FOnAddEntities(Self, LEntities);
  end;

  Self.AddDocObject(AEntity);
  Result := True;
end;

function TUdEntities.Add(AEntities: TUdEntityArray): Boolean;
var
  I, L: Integer;
  LEntity: TUdEntity;
  LEntities: TUdEntityArray;
begin
  L := 0;
  System.SetLength(LEntities, System.Length(AEntities));

  for I := 0 to System.Length(AEntities) - 1 do
  begin
    LEntity := AEntities[I];
    if InternalAdd(LEntity) then
    begin
      LEntities[L] := LEntity;
      L := L + 1;
    end;
  end;

  if not FLoading then
  begin
    if System.Length(LEntities) <> L then System.SetLength(LEntities, L);
    if Assigned(FOnAddEntities) then FOnAddEntities(Self, LEntities);
  end;

  for I := 0 to System.Length(LEntities) - 1 do
    Self.AddDocObject(LEntities[I]);

  Result := L > 0;
end;

function TUdEntities.Insert(AIndex: Integer; AEntity: TUdEntity): Boolean;
var
  LEntities: TUdEntityArray;
begin
  Result := False;

  if AIndex < 0 then AIndex := AIndex + FList.Count;
  if AIndex > FList.Count then AIndex := FList.Count;

  if (AIndex < 0) then Exit;  //=======>>>>

  FList.Insert(AIndex, AEntity);

  if not FLoading and Assigned(FOnAddEntities) then
  begin
    System.SetLength(LEntities, 1);
    LEntities[0] := AEntity;
    FOnAddEntities(Self, LEntities);
  end;

  Self.AddDocObject(AEntity);
  Result := True;
end;


function TUdEntities.Remove(AEntity: TUdEntity): Boolean;
var
  N: Integer;
begin
  Result := False;

  N := IndexOf(AEntity);
  if N < 0 then Exit;

  Result := RemoveAt(N);
end;


function TUdEntities.Remove(AEntities: TUdEntityArray): Boolean;
var
  I: Integer;
//  N, L: Integer;
//  LEntity: TUdEntity;
  LEntities: TUdEntityArray;
begin
//  L := 0;
//  System.SetLength(LEntities, System.Length(AEntities));
//
//  for I := 0 to System.Length(AEntities) - 1 do
//  begin
//    LEntity := AEntities[I];
//    if not Assigned(LEntity) then Continue;
//
//    N := FList.IndexOf(LEntity);
//
//    if N >= 0 then
//    begin
//      FList.Delete(N);
//      LEntities[L] := LEntity;
//      L := L + 1;
//    end;
//  end;
//  if System.Length(LEntities) <> L then System.SetLength(LEntities, L);

  LEntities := AEntities;
  if Assigned(FOnRemoveEntities) then FOnRemoveEntities(Self, LEntities);

  for I := 0 to System.Length(LEntities) - 1 do
  begin
    Self.RemoveDocObject(LEntities[I]);
    FList.Remove(LEntities[I]);
  end;

  if Assigned(FOnRemovedEntities) then FOnRemovedEntities(Self);

  Result := System.Length(LEntities) > 0;
end;


function TUdEntities.IndexOf(AEntity: TUdEntity): Integer;
begin
  Result := FList.IndexOf(AEntity);
end;


//---------------------------------------------------------------------

procedure TUdEntities.ChangeOrder(AEntity: TUdEntity; ToBack: Boolean);
var
  N: Integer;
begin
  N := FList.IndexOf(AEntity);
  if N < 0 then Exit;

  if ToBack then
  begin
    if N <> 0 then
    begin
      FList.Delete(N);
      FList.Insert(0, AEntity);
    end;
  end
  else begin
    if N <> FList.Count - 1 then
    begin
      FList.Delete(N);
      FList.Add(AEntity);
    end;
  end;
end;

function TUdEntities.Swap(AEntity1: TUdEntity; AEntity2: TUdEntity): Boolean;
var
  N1, N2: Integer;
begin
  Result := False;

  N1 := FList.IndexOf(AEntity1);
  N2 := FList.IndexOf(AEntity2);
  if (N1 < 0) or (N2 < 0) then Exit;

  FList.Exchange(N1, N2);
  Result := True;
end;



procedure TUdEntities.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    Self.RemoveDocObject(TUdObject(FList[I]), False);
  FList.Clear;

  Self.RaiseChanged();
end;

procedure TUdEntities.Update;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TUdEntity(FList[I]).Update;
end;



//------------------------------------------------------------------------------

function TUdEntities.Add(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdEntity) then
    Result := Self.Add(TUdEntity(AObj));
end;


function TUdEntities.Insert(AIndex: Integer; AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdEntity) then
    Result := Self.Insert(AIndex, TUdEntity(AObj));
end;

function TUdEntities.Remove(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdEntity) then
    Result := Self.Remove(TUdEntity(AObj));
end;

function TUdEntities.RemoveAt(AIndex: Integer): Boolean;
var
  LEntity: TUdEntity;
  LEntities: TUdEntityArray;
begin
  Result := False;

  if AIndex < 0 then AIndex := AIndex + FList.Count;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  LEntity := FList[AIndex];
  if not Assigned(LEntity) then Exit;

  if Assigned(FOnRemoveEntities) then
  begin
    System.SetLength(LEntities, 1);
    LEntities[0] := LEntity;
    FOnRemoveEntities(Self, LEntities);
  end;

  Self.RemoveDocObject(LEntity);
  FList.Delete(AIndex);

  if Assigned(FOnRemovedEntities) then FOnRemovedEntities(Self);

  Result := True;
end;


function TUdEntities.IndexOf(AObj: TUdObject): Integer;
begin
  Result := -1;
  if Assigned(AObj) and AObj.InheritsFrom(TUdEntity) then
    Result := Self.IndexOf(TUdEntity(AObj));
end;

function TUdEntities.Contains(AObj: TUdObject): Boolean;
begin
  Result := Self.IndexOf(AObj) >= 0;
end;




//----------------------------------------------------------------------

procedure TUdEntities.SaveToStream(AStream: TStream);
var
  I, N: Integer;
  LPos, LStep, LCount: Integer;
  LDoProgress: Boolean;
  LEntity: TUdEntity;
begin
  inherited;

  LCount := 0;
  for I := 0 to FList.Count - 1 do
  begin
    LEntity := TUdEntity(FList.Items[I]);
    if Assigned(LEntity) and (LEntity.TypeID <> 0) then Inc(LCount);
  end;

  N := 0;
  LStep := Round(LCount / 100  * 5);
  LDoProgress := Assigned(Document) and Assigned(Owner) and Owner.InheritsFrom(TUdLayout);


  IntToStream(AStream, LCount);
  for I := 0 to FList.Count - 1 do
  begin
    LEntity := TUdEntity(FList.Items[I]);
    if Assigned(LEntity) and (LEntity.TypeID <> 0) then
    begin
      IntToStream(AStream, LEntity.TypeID);
      LEntity.SaveToStream(AStream);

      if LDoProgress and (I >= N) then
      begin
        LPos := Round(I / LCount * 100);
        TUdDocument(Document).DoProgress(LPos, 100);

        N := N + LStep;
      end;
    end;
  end;
end;


type
  TFUdDocument = class(TUdDocument);

procedure TUdEntities.LoadFromStream(AStream: TStream);
var
  I, N: Integer;
  LPos, LStep, LCount: Integer;
  LDoProgress: Boolean;

  LTypeID: Integer;
  LEntity: TUdEntity;
  LEntityClass: TUdEntityClass;
begin
  Self.Clear();

  inherited;

  LCount := IntFromStream(AStream);

  N := 0;
  LStep := Round(LCount / 100  * 5);
  LDoProgress := Assigned(Document) and Assigned(Owner) and Owner.InheritsFrom(TUdLayout);

  for I := 0 to LCount - 1 do
  begin
    LTypeID := IntFromStream(AStream);
    LEntityClass := UdUtils.GetEntityClass(LTypeID);

    if not Assigned(LEntityClass) and Assigned(Self.Document) then
      LEntityClass := TFUdDocument(Self.Document).DoGetEntityClass(Self, LTypeID);

    if Assigned(LEntityClass) then
    begin
      LEntity := LEntityClass.Create(Self.Document, Self.IsDocRegister);
      LEntity.Owner := Self;
      LEntity.LoadFromStream(AStream);

      FList.Add(LEntity);
      Self.AddDocObject(LEntity, False);

      if LDoProgress and (I >= N) then
      begin
        LPos := Round(I / LCount * 100);
        TUdDocument(Document).DoProgress(LPos, 100);

        N := N + LStep;
      end;
    end;
  end;
end;




procedure TUdEntities.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I, N: Integer;
  LPos, LStep, LCount: Integer;
  LDoProgress: Boolean;

  LEntity: TUdEntity;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LCount := FList.Count;

  N := 0;
  LStep := Round(LCount / 100  * 5);
  LDoProgress := Assigned(Document) and Assigned(Owner) and Owner.InheritsFrom(TUdLayout);

  for I := 0 to LCount - 1 do
  begin
    LEntity := TUdEntity(FList.Items[I]);
    if Assigned(LEntity) then
    begin
      LEntity.SaveToXml(LXmlNode.Add());

      if LDoProgress and (I >= N) then
      begin
        LPos := Round(I / LCount * 100);
        TUdDocument(Document).DoProgress(LPos, 100);

        N := N + LStep;
      end;
    end;
  end;
end;

procedure TUdEntities.LoadFromXml(AXmlNode: TObject);
var
  I, N: Integer;
  LPos, LStep, LCount: Integer;
  LDoProgress: Boolean;

  LTypeID: Integer;
  LEntity: TUdEntity;
  LEntityClass: TUdEntityClass;
  LXmlNode, LEntityNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);
  LCount := LXmlNode.Count;

  N := 0;
  LStep := Round(LCount / 100  * 5);
  LDoProgress := Assigned(Document) and Assigned(Owner) and Owner.InheritsFrom(TUdLayout);

  for I := 0 to LCount - 1 do
  begin
    LEntityNode := LXmlNode.Items[I];

    LTypeID := StrToIntDef(LEntityNode.Prop['TypeID'], -1);
    if LTypeID < 0 then Continue;

    LEntityClass := UdUtils.GetEntityClass(LTypeID);

    if Assigned(LEntityClass) then
    begin
      LEntity := LEntityClass.Create();
      LEntity.Owner := Self;
      LEntity.LoadFromXml(LEntityNode);

      FList.Add(LEntity);
      Self.AddDocObject(LEntity, False);

      if LDoProgress and (I >= N) then
      begin
        LPos := Round(I / LCount * 100);
        TUdDocument(Document).DoProgress(LPos, 100);

        N := N + LStep;
      end;
    end;
  end;
end;



end.