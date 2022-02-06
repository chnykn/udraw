{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdCCP;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdConsts, UdTypes, UdIntfs, UdObject, UdEntity,
  UdLayers, UdDimStyles, UdTextStyles, UdBlocks;

type
  TUdCCP = class(TUdObject) //Cut Copy Paste
  private
    FLayers     : TUdLayers;
    FDimStyles  : TUdDimStyles;
    FTextStyles : TUdTextStyles;
    FBlocks     : TUdBlocks;
    
    FEntityList : TList;

  protected
    function InitData(AIsCut: Boolean): Boolean;
    
    function InitEntity(AEntity: TUdEntity): Boolean;
    function RestEntity(AEntity: TUdEntity): Boolean;

  public
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); override;
    destructor Destroy; override;

    procedure Clear();
    
    function CutClip(): Boolean;
    function CopyClip(): Boolean;

    function PasteClip(): TUdObjectArray;
  end;

  

implementation

uses
  SysUtils, UdUtils,
  UdDocument, UdText, UdDimension, UdInsert,
  UdLayer, UdTextStyle, UdDimStyle, UdBlock;
  


//==============================================================================================
{ TUdCCP }

constructor TUdCCP.Create(ADocument: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

  FLayers     := TUdLayers.Create(ADocument, False);
  FDimStyles  := TUdDimStyles.Create(ADocument, False);
  FTextStyles := TUdTextStyles.Create(ADocument, False);
  FBlocks     := TUdBlocks.Create(ADocument, False);

  FEntityList := TList.Create();
end;

destructor TUdCCP.Destroy;
begin
  Self.Clear();

  if Assigned(FLayers) then FLayers.Free();
  FLayers := nil;

  if Assigned(FDimStyles) then FDimStyles.Free();
  FDimStyles := nil;

  if Assigned(FTextStyles) then FTextStyles.Free();
  FTextStyles := nil;

  if Assigned(FBlocks) then FBlocks.Free();
  FBlocks := nil;
          
  if Assigned(FEntityList) then FEntityList.Free();
  FEntityList := nil;
  
  inherited;
end;




//--------------------------------------------------------------------------------------

procedure TUdCCP.Clear();
begin
  FLayers.Clear(True);    
  FDimStyles.Clear(True);
  FTextStyles.Clear(True);
  FBlocks.Clear();

  UdUtils.ClearObjectList(FEntityList);
end;



function TUdCCP.InitEntity(AEntity: TUdEntity): Boolean;
begin
  Result := False;
  if not Assigned(AEntity) then Exit; //=====>>>>
  
  if Assigned(AEntity.Layer) then
    AEntity.Layer := FLayers.GetItem(AEntity.Layer.Name);

  if AEntity.InheritsFrom(TUdText) and Assigned(TUdText(AEntity).TextStyle) then
    TUdText(AEntity).TextStyle := FTextStyles.GetItem(TUdText(AEntity).TextStyle.Name);

  if AEntity.InheritsFrom(TUdDimension) and Assigned(TUdDimension(AEntity).DimStyle) then
    TUdDimension(AEntity).DimStyle := FDimStyles.GetItem(TUdDimension(AEntity).DimStyle.Name);
    
  if AEntity.InheritsFrom(TUdInsert) and Assigned(TUdInsert(AEntity).Block) then
    TUdInsert(AEntity).Block := FBlocks.GetItem(TUdInsert(AEntity).Block.Name);

  Result := True;
end;

function TUdCCP.RestEntity(AEntity: TUdEntity): Boolean;
var
  N: Integer;
  LDoc: TUdDocument;
  LLayer: TUdLayer;
  LTextStyle: TUdTextStyle;
  LDimStyle: TUdDimStyle;
  LBlock: TUdBlock;
begin
  Result := False;
  if not Assigned(AEntity) then Exit; //=====>>>>

  if (not Assigned(Self.Document)) or
     (not Self.Document.InheritsFrom(TUdDocument)) then Exit; //======>>>>>>

  LDoc := TUdDocument(Self.Document);

  
  if Assigned(AEntity.Layer) then
  begin
    N := LDoc.Layers.IndexOf(AEntity.Layer.Name);

    if N < 0 then
    begin
      LLayer := TUdLayer.Create();
      LLayer.Assign(AEntity.Layer);
      LDoc.Layers.Add(LLayer);

      AEntity.Layer := LLayer;
    end
    else
      AEntity.Layer := LDoc.Layers.Items[N];
  end
  else
    AEntity.Layer := LDoc.ActiveLayer;

    

  if AEntity.InheritsFrom(TUdText) then
  begin
    if Assigned(TUdText(AEntity).TextStyle) then
    begin
      N := LDoc.TextStyles.IndexOf(TUdText(AEntity).TextStyle.Name);

      if N < 0 then
      begin
        LTextStyle := TUdTextStyle.Create();
        LTextStyle.Assign(TUdText(AEntity).TextStyle);
        LDoc.TextStyles.Add(LTextStyle);

        TUdText(AEntity).TextStyle := LTextStyle;
      end
      else
        TUdText(AEntity).TextStyle := LDoc.TextStyles.Items[N];
    end
    else
      TUdText(AEntity).TextStyle := LDoc.ActiveTextStyle;
  end;

  if AEntity.InheritsFrom(TUdDimension) then
  begin
    if Assigned(TUdDimension(AEntity).DimStyle) then
    begin
      N := LDoc.DimStyles.IndexOf(TUdDimension(AEntity).DimStyle.Name);

      if N < 0 then
      begin
        LDimStyle := TUdDimStyle.Create();
        LDimStyle.Assign(TUdDimension(AEntity).DimStyle);
        LDoc.DimStyles.Add(LDimStyle);

        TUdDimension(AEntity).DimStyle := LDimStyle;
      end
      else
        TUdDimension(AEntity).DimStyle := LDoc.DimStyles.Items[N];
    end
    else
      TUdDimension(AEntity).DimStyle := LDoc.ActiveDimStyle;
  end;


  if AEntity.InheritsFrom(TUdInsert) then
  begin
    if Assigned(TUdInsert(AEntity).Block) then
    begin
      N := LDoc.Blocks.IndexOf(TUdInsert(AEntity).Block.Name);

      if N < 0 then
      begin
        LBlock := TUdBlock.Create();
        LBlock.Assign(TUdInsert(AEntity).Block);
        LDoc.Blocks.Add(LBlock);

        TUdInsert(AEntity).Block := LBlock;
      end
      else
        TUdInsert(AEntity).Block := LDoc.Blocks.Items[N];
    end
    //else
    //  TUdInsert(AEntity).Block := LDoc.ActiveBlock;
  end;
    
  Result := True;
end;



function TUdCCP.InitData(AIsCut: Boolean): Boolean;
var
  I: Integer;
  LDoc: TUdDocument;
  LEntities: TUdEntityArray;
  LEntity, LEntity2: TUdEntity;
begin
  Result := False;
  if (not Assigned(Self.Document)) or
     (not Self.Document.InheritsFrom(TUdDocument)) then Exit; //======>>>>>>

  LDoc := TUdDocument(Self.Document);
  if LDoc.ActiveLayout.SelectedList.Count <= 0 then Exit; //======>>>>>>

  Self.Clear();
  
  FLayers.Assign(LDoc.Layers);
  FDimStyles.Assign(LDoc.DimStyles);
  FTextStyles.Assign(LDoc.TextStyles);
  FBlocks.Assign(LDoc.Blocks);

  for I := 0 to LDoc.ActiveLayout.SelectedList.Count - 1 do
  begin
    LEntity := LDoc.ActiveLayout.SelectedList[I];
    
    LEntity2 := LEntity.Clone();
    Self.InitEntity(LEntity2);
    
    FEntityList.Add(LEntity2);
  end;

  if AIsCut then
  begin
    if UdUtils.GetEntitiesArray(LDoc.ActiveLayout.SelectedList, LEntities) then
    begin
      LDoc.ActiveLayout.RemoveAllSelected();
      LDoc.ActiveLayout.Entities.Remove(LEntities);
    end;
  end;

  Result := True;
end;



function TUdCCP.CutClip(): Boolean;
begin
  Result := InitData(True);
end;

function TUdCCP.CopyClip(): Boolean;
begin
  Result := InitData(False);
end;

function TUdCCP.PasteClip(): TUdObjectArray;
var
  I: Integer;
  LEntity, LEntity2: TUdEntity;
begin
  Result := nil;
  if not Assigned(FEntityList) or (FEntityList.Count <= 0) then Exit; //======>>>>>>

  SetLength(Result, FEntityList.Count);
  for I := 0 to FEntityList.Count - 1 do
  begin
    LEntity := FEntityList[I];
    
    LEntity2 := LEntity.Clone();
    Self.RestEntity(LEntity2);
    
    Result[I] := LEntity2;
  end;
end;



end.