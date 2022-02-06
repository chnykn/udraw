{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdBlock;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes, UdConsts, UdIntfs, UdObject, UdEntity, UdEntities;

type
  TUdBlock = class;

  TUdBlockEvent = procedure(Sender: TObject; Block: TUdBlock) of object;
  TUdBlockAllowEvent = procedure(Sender: TObject; Block: TUdBlock; var Allow: Boolean) of object;


  //*** TUdBlock ***//
  TUdBlock = class(TUdObject, IUdObjectItem)
  private
    FIsSys: Boolean;

    FName: string;
    FDescription: string;

    FOrigin: TPoint2D;

    FXrefFile: string;
    FIsXrefLoaded: Boolean;

    FEntities: TUdEntities;

  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    procedure SetName(const AValue: string);
    procedure SetDescription(const AValue: string);

    procedure SetIsSys(const AValue: Boolean);
    procedure SetOrigin(const AValue: TPoint2D);

    function GetIsXref: Boolean;
    procedure SetXrefFile(const AValue: string);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    function GetEntities(): TUdEntityArray;
    function CreateInsertEntities(AInsPnt: TPoint2D; ScaleX, ScaleY: Float; ARotation: Float): TUdEntityArray;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Entities: TUdEntities read FEntities;

    property IsSys: Boolean  read FIsSys write SetIsSys;

    property Name: string read FName write SetName;
    property Description: string read FDescription write SetDescription;

    property Origin: TPoint2D read FOrigin write SetOrigin;

    property IsXref: Boolean read GetIsXref;

    property IsXrefLoaded: Boolean read FIsXrefLoaded;
    property XrefFile: string read FXrefFile write SetXrefFile;

  end;


implementation

uses
  SysUtils,
  UdDocument, UdMath, UdGeo2D, UdStreams, UdStrConverter, UdText,
  UdXml, UdInsert, UdTolerance;



//==================================================================================================
{ TUdBlock }

constructor TUdBlock.Create();
begin
  inherited;

  FName := '';

  FOrigin := Point2D(0, 0);
  FIsSys := False;

  FXrefFile := '';
  FIsXrefLoaded := False;

  FEntities := TUdEntities.Create();
  FEntities.Owner := Self;
end;

destructor TUdBlock.Destroy;
begin
  if Assigned(FEntities) then FEntities.Free;
  FEntities := nil;

  inherited;
end;


function TUdBlock.GetTypeID: Integer;
begin
  Result := ID_BLOCK;
end;

procedure TUdBlock.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;
  FEntities.SetDocument(Self.Document, False);
end;





//------------------------------------------------------------------------


procedure TUdBlock.SetName(const AValue: string);
begin
  if (FName <> Trim(AValue)) and Self.RaiseBeforeModifyObject('Name') then
  begin
    FName := Trim(AValue);
    Self.RaiseAfterModifyObject('Name');
  end;
end;

procedure TUdBlock.SetDescription(const AValue: string);
begin
  if (FDescription <> AValue) and Self.RaiseBeforeModifyObject('Description') then
  begin
    FDescription := AValue;
    Self.RaiseAfterModifyObject('Description');
  end;
end;




procedure TUdBlock.SetIsSys(const AValue: Boolean);
begin
  if (FIsSys <> AValue) and Self.RaiseBeforeModifyObject('IsSys') then
  begin
    FIsSys := AValue;
    Self.RaiseAfterModifyObject('IsSys');
  end;
end;

procedure TUdBlock.SetOrigin(const AValue: TPoint2D);
begin
  if NotEqual(FOrigin, AValue) and Self.RaiseBeforeModifyObject('Origin') then
  begin
    FOrigin := AValue;
    Self.RaiseAfterModifyObject('Origin');
  end;
end;

procedure TUdBlock.SetXrefFile(const AValue: string);
begin
  if (FXrefFile <> AValue) and Self.RaiseBeforeModifyObject('XrefFile') then
  begin
    FXrefFile := AValue;
    FIsXrefLoaded := False;
    Self.RaiseAfterModifyObject('XrefFile');
  end;
end;




procedure TUdBlock.CopyFrom(AValue: TUdObject);
begin
  inherited;
  if not AValue.InheritsFrom(TUdBlock) then Exit; //========>>>

  FName         := TUdBlock(AValue).FName        ;
  FDescription  := TUdBlock(AValue).FDescription ;

  FOrigin       := TUdBlock(AValue).FOrigin      ;
  FIsSys       := TUdBlock(AValue).FIsSys      ;

  FXrefFile     := TUdBlock(AValue).FXrefFile    ;
  FIsXrefLoaded := TUdBlock(AValue).FIsXrefLoaded;

  FEntities.Assign(TUdBlock(AValue).FEntities);
end;




//-----------------------------------------------------------------------


function TUdBlock.GetIsXref: Boolean;
begin
  Result := (FXrefFile <> '') and SysUtils.FileExists(FXrefFile);
end;

function TUdBlock.GetEntities(): TUdEntityArray;
var
  I: Integer;
  LDoc: TUdDocument;
  LFileValid: Boolean;
begin
  Result := nil;

  if Self.GetIsXref() and not FIsXrefLoaded then
  begin
    LDoc := TUdDocument.Create();
    try
      try
        LFileValid := LDoc.LoadFromFile(FXrefFile);
      except
        LFileValid := False;
      end;
    finally
      LDoc.Free;
    end;

    if LFileValid then
    begin
      FEntities.Assign(LDoc.ModelSpace.Entities);
      FIsXrefLoaded := True;
    end
    else
      FEntities.Clear();
  end;

  System.SetLength(Result, FEntities.Count);
  for I := 0 to FEntities.Count - 1 do Result[I] := FEntities.Items[I];
end;



function TUdBlock.CreateInsertEntities(AInsPnt: TPoint2D; ScaleX, ScaleY: Float; ARotation: Float): TUdEntityArray;

  function _GetInsEntities(AEntity: TUdEntity): TUdObjectArray;
  var
    I: Integer;
  begin
    Result := TUdObjectArray(AEntity.ScaleEx(AInsPnt, Abs(ScaleX), Abs(ScaleY)));

    if ScaleX < 0 then
      for I := 0 to System.Length(Result) - 1 do
        TUdEntity(Result[I]).Mirror(AInsPnt, Point2D(AInsPnt.X, AInsPnt.Y + 5));

    if ScaleY < 0 then
      for I := 0 to System.Length(Result) - 1 do
        TUdEntity(Result[I]).Mirror(AInsPnt, Point2D(AInsPnt.X+5, AInsPnt.Y));

    if NotEqual(ARotation, 0.0) then
      for I := 0 to System.Length(Result) - 1 do
        TUdEntity(Result[I]).Rotate(AInsPnt, ARotation);
  end;

  function _CreateInsertEntities(ASrcEntity: TUdEntity; var AReturn: TUdEntityArray): Boolean;
  var
    I, L: Integer;
    LEntity: TUdEntity;
    LEntities: TUdObjectArray;
    LInsert: TUdInsert;
  begin
    Result := False;
    if not Assigned(ASrcEntity) then Exit;

    if ASrcEntity.InheritsFrom(TUdInsert) and Assigned(TUdInsert(ASrcEntity).Block) then
    begin
      LEntities := TUdInsert(ASrcEntity).Explode();

      for I := 0 to System.Length(LEntities) - 1 do
      begin
        _CreateInsertEntities(TUdEntity(LEntities[I]), AReturn);
        LEntities[I].Free;
      end;
    end
    else begin
      LEntity := TUdEntityClass(ASrcEntity.ClassType).Create({Self.Document, False});
      LEntity.BeginUpdate();
      try
        LEntity.Assign(ASrcEntity);
        LEntity.Move(FOrigin, AInsPnt);

        LEntities := _GetInsEntities(LEntity);
        
        if LEntity.InheritsFrom(TUdTolerance) or  LEntity.InheritsFrom(TUdInsert) then
        begin
          LInsert := TUdInsert.Create({Self.Document, False});
          LInsert.Position := AInsPnt;
          for I := 0 to System.Length(LEntities) - 1 do LInsert.Entities.Add(LEntities[I]);
          LInsert.Update();

          System.SetLength(AReturn, System.Length(AReturn) + 1);
          AReturn[High(AReturn)] := LInsert;
        end
        else begin
          L := System.Length(AReturn);
          System.SetLength(AReturn, L + System.Length(LEntities));
          for I := 0 to System.Length(LEntities) - 1 do AReturn[L + I] := TUdEntity(LEntities[I]);
        end;

      finally
//        LEntity.EndUpdate();
        LEntity.Free;
      end;
    end;

  end;


var
  I, J: Integer;
  LEntity: TUdEntity;
  LEntities: TUdEntityArray;
  LTempList: TList;
  LEntityArray: TUdEntityArray;
begin
  Result := nil;
  if IsEqual(ScaleX, 0.0) or IsEqual(ScaleY, 0.0) then Exit;

  LEntities := Self.GetEntities();
  System.SetLength(Result, System.Length(LEntities));

  LTempList := TList.Create;
  try
    for I := 0 to System.Length(LEntities) - 1 do
    begin
      LEntity := LEntities[I];

      LEntityArray := nil;
      _CreateInsertEntities(LEntity, LEntityArray);

      for J := 0 to System.Length(LEntityArray) - 1 do
        LTempList.Add(LEntityArray[J]);
    end;

    System.SetLength(Result, LTempList.Count);
    for I := 0 to LTempList.Count - 1 do Result[I] := LTempList[I];
  finally
    LTempList.Free;
  end;
end;



//-----------------------------------------------------------------------

procedure TUdBlock.SaveToStream(AStream: TStream);
var
  LIsXref: Boolean;
begin
  inherited;

  BoolToStream(AStream, FIsSys);

  StrToStream(AStream, FName);
  StrToStream(AStream, FDescription);

  Point2DToStream(AStream, FOrigin);

  LIsXref := Self.GetIsXref();
  BoolToStream(AStream, LIsXref);

  if LIsXref then
    StrToStream(AStream, FXrefFile)
  else
    FEntities.SaveToStream(AStream);
end;

procedure TUdBlock.LoadFromStream(AStream: TStream);
var
  LIsXref: Boolean;
begin
  inherited;

  FIsSys        := BoolFromStream(AStream);

  FName         := StrFromStream(AStream);
  FDescription  := StrFromStream(AStream);

  FOrigin       := Point2DFromStream(AStream);

  FIsXrefLoaded := False;
  LIsXref       := BoolFromStream(AStream);

  FEntities.Clear();

  if LIsXref then
    FXrefFile := StrFromStream(AStream)
  else
    FEntities.LoadFromStream(AStream);
end;



procedure TUdBlock.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LIsXref: Boolean;
  LXmlNode: TUdXmlNode;
begin
  inherited;

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['IsSys']       := BoolToStr(FIsSys, True);

  LXmlNode.Prop['Name']        := FName;
  LXmlNode.Prop['Description'] := FDescription;

  LXmlNode.Prop['Origin']      := Point2DToStr(FOrigin);

  LIsXref                      := Self.GetIsXref();
  LXmlNode.Prop['IsXref']      := BoolToStr(LIsXref, True);

  if LIsXref then
    LXmlNode.Prop['XrefFile'] := FXrefFile
  else
    FEntities.SaveToXml(LXmlNode.Add(), 'Entities');
end;

procedure TUdBlock.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FIsSys       :=  StrToBoolDef(LXmlNode.Prop['IsSys'], False);

  FName        :=  LXmlNode.Prop['Name'];
  FDescription :=  LXmlNode.Prop['Description'];

  FOrigin      :=  StrToPoint2D(LXmlNode.Prop['Origin']);

  FXrefFile    :=  LXmlNode.Prop['XrefFile'];
  FEntities.LoadFromXml(LXmlNode.FindItem('Entities'));
end;

end.