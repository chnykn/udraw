{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLayers;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics,
  UdConsts, UdTypes, UdIntfs, UdObject,
  UdLayer, UdColor, UdLineType, UdLineWeight;

type
  //*** TUdLayers ***//
  TUdLayers = class(TUdObject, IUdObjectCollection , IUdActiveSupport)
  private
    FList: TList;
    FActive: TUdLayer;
    FStandard: TUdLayer;

    FOnAdd: TUdLayerEvent;
    FOnSelect: TUdLayerEvent;
    FOnRemove: TUdLayerAllowEvent;

  protected
    function GetTypeID: Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function GetCount: Integer;
    procedure SetItem(AIndex: Integer; const AValue: TUdLayer);
    procedure SetActive_(const AValue: TUdLayer);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

    {$IFNDEF D2005UP}
    function GetItem_(AIndex: Integer): TUdLayer;
    {$ENDIF}
        
  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure Clear(All: Boolean = False);

    function IndexOf(AName: string): Integer; overload;
    function IndexOf(AObject: TUdLayer): Integer; overload;


    function Add(AObject: TUdLayer): Boolean; overload;
    function Add(AName: string; AVisible, ALock: Boolean; AColor: TColor;
                 ALnty: TSingleArray; ALwt: TUdLineWeight): TUdLayer; overload;

    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AName: string): Boolean; overload;
    function Remove(AObject: TUdLayer): Boolean; overload;

    function GetItem(AIndex: Integer): TUdLayer; overload;
    function GetItem(AName: string): TUdLayer; overload;

    function SetActive(AIndex: Integer): Boolean; overload;
    function SetActive(AName: string): Boolean; overload;
    function SetActive(AObject: TUdLayer): Boolean; overload;

    function GetActiveIndex(): Integer;

    //IUdObjectCollection ------------------
    function Add(AObj: TUdObject): Boolean; overload;

    function Insert(AIndex: Integer; AObj: TUdObject): Boolean; overload;

    function Remove(AObj: TUdObject): Boolean; overload;
    function RemoveAt(AIndex: Integer): Boolean;

    function IndexOf(AObj: TUdObject): Integer; overload;
    function Contains(AObj: TUdObject): Boolean;


    //-----------------------------------

    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;


  public
    property Items[Index: Integer]: TUdLayer read {$IFDEF D2005UP} GetItem {$ELSE} GetItem_ {$ENDIF} write SetItem;

  published
    property Active: TUdLayer read FActive write SetActive_;
    property Standard: TUdLayer read FStandard;// write FStandard;

    property Count: Integer read GetCount;

    property OnAdd: TUdLayerEvent read FOnAdd write FOnAdd;
    property OnSelect: TUdLayerEvent read FOnSelect write FOnSelect;
    property OnRemove: TUdLayerAllowEvent read FOnRemove write FOnRemove;

  end;


implementation

uses
  SysUtils,
  UdStreams, UdXml;


const
  SLAYER = 'Layer';


//==================================================================================================
{ TUdLayers }

constructor TUdLayers.Create();
var
  LLayer: TUdLayer;
begin
  inherited;

  FStandard := TUdLayer.Create();
  FStandard.Name := '0';
  FStandard.Owner := Self;

  FActive := FStandard;

  FList := TList.Create();
  FList.Add(FStandard);


  //-----------------------------------------------
  
  LLayer := TUdLayer.Create();
  LLayer.Name := 'Layer1';
  LLayer.Owner := Self;

  FList.Add(LLayer);
end;

destructor TUdLayers.Destroy;
begin
  Self.Clear(True);

  if Assigned(FList) then FList.Free;
  FList := nil;

  FStandard := nil;

  inherited;
end;


function TUdLayers.GetTypeID: Integer;
begin
  Result := ID_LAYERS;
end;


procedure TUdLayers.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
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



procedure TUdLayers.Clear(All: Boolean = False);
var
  I, N: Integer;
begin
  FActive := nil;

  if All then N := 0 else N := 1;
  for I := FList.Count - 1 downto N do
  begin
    Self.RemoveDocObject(TUdObject(FList[I]), False);
    FList.Delete(I);
  end;

  if All then
    FStandard := nil
  else
    FActive := FStandard;

  Self.RaiseChanged();
end;



//--------------------------------------------------------

procedure TUdLayers.CopyFrom(AValue: TUdObject);
var
  I, N: Integer;
  LSrcItem, LDstItem: TUdLayer;
begin
  inherited;

  if not AValue.InheritsFrom(TUdLayers) then Exit;

  if (TUdLayers(AValue).FList.Count > 0) then
  begin
    Self.Clear(True);

    for I := 0 to TUdLayers(AValue).FList.Count - 1 do
    begin
      LSrcItem := TUdLayer(TUdLayers(AValue).FList[I]);
      if not Assigned(LSrcItem) then Continue;

      LDstItem := TUdLayer.Create();
      LDstItem.Assign(LSrcItem);

      LDstItem.Owner := Self;
      LDstItem.SetDocument(Self.Document, Self.IsDocRegister);
      
      FList.Add(LDstItem);
      Self.AddDocObject(LDstItem, False);
    end;

    if FList.Count > 0 then FStandard := FList.Items[0];

    N := TUdLayers(AValue).IndexOf(TUdLayers(AValue).Active);
    if N >= 0 then
      FActive := GetItem(N)
    else
      FActive := FStandard;
  end;
end;


function TUdLayers.GetCount: Integer;
begin
  Result := FList.Count;
end;


procedure TUdLayers.SetItem(AIndex: Integer; const AValue: TUdLayer);
var
  LLayer: TUdLayer;
begin
//  if AIndex < 1 then Exit; // 0 is FStandard

  LLayer := TUdLayer(FList.Items[AIndex]);

  if Assigned(LLayer) and Assigned(AValue) and (LLayer <> AValue) then
    LLayer.Assign(AValue);
end;


{$IFNDEF D2005UP}
function TUdLayers.GetItem_(AIndex: Integer): TUdLayer;
begin
  Result := Self.GetItem(AIndex);
end;
{$ENDIF}




//-------------------------------------------------------

function TUdLayers.IndexOf(AName: string): Integer;
var
  I: Integer;
  LName: string;
  LLayer: TUdLayer;
begin
  Result := -1;

  LName := LowerCase(Trim(AName));

  for I := FList.Count - 1 downto 0 do
  begin
    LLayer := TUdLayer(FList[I]);

    if LowerCase(Trim(LLayer.Name)) = LName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TUdLayers.IndexOf(AObject: TUdLayer): Integer;
begin
  Result := FList.IndexOf(AObject);
end;





//-------------------------------------------------------

function TUdLayers.Add(AObject: TUdLayer): Boolean;
begin
  Result := False;
  if not Assigned(AObject) and (FList.IndexOf(AObject) < 0) then Exit; //======>>>

  AObject.Owner := Self;
  AObject.SetDocument(Self.Document, Self.IsDocRegister);

  FList.Add(AObject);
  Self.AddDocObject(AObject);
  
  if Assigned(FOnAdd) then FOnAdd(Self, AObject);
  Result := True;
end;


function TUdLayers.Add(AName: string; AVisible, ALock: Boolean; AColor: TColor;
                       ALnty: TSingleArray; ALwt: TUdLineWeight): TUdLayer;
var
  LLayer: TUdLayer;
begin
  LLayer := TUdLayer.Create();

  LLayer.Name := AName;
  LLayer.Visible := AVisible;
  LLayer.Lock := ALock;
  LLayer.Freeze := False;
  LLayer.Color.TrueColor := AColor;
  LLayer.LineType.Value := ALnty;
  LLayer.LineWeight := ALwt;

  LLayer.Owner := Self;
  LLayer.SetDocument(Self.Document, Self.IsDocRegister);
    
  FList.Add(LLayer);
  Self.AddDocObject(LLayer);
  
  if Assigned(FOnAdd) then FOnAdd(Self, LLayer);
  Result := LLayer;
end;






//-------------------------------------------------------

function TUdLayers.Remove(AIndex: Integer): Boolean;
var
  LLayer: TUdLayer;
begin
  Result := False;
  if (AIndex < 1) or (AIndex >= FList.Count) then Exit;

  LLayer := TUdLayer(FList.Items[AIndex]);

  if FActive <> LLayer then
  begin
    Result := True;
    if Assigned(FOnRemove) then FOnRemove(Self, LLayer, Result);

    if Result then
    begin
      Self.RemoveDocObject(LLayer);
      FList.Delete(AIndex);
    end;
  end;
end;

function TUdLayers.Remove(AName: string): Boolean;
begin
  Result := Remove(IndexOf(AName));
end;

function TUdLayers.Remove(AObject: TUdLayer): Boolean;
begin
  Result := Remove(IndexOf(AObject));
end;





//-------------------------------------------------------

function TUdLayers.GetItem(AIndex: Integer): TUdLayer;
begin
  Result := nil;

  if (AIndex >= 0) and (AIndex < FList.Count) then
    Result := TUdLayer(FList.Items[AIndex]);
end;

function TUdLayers.GetItem(AName: string): TUdLayer;
begin
  Result := GetItem(IndexOf(AName));
end;






//-------------------------------------------------------

function TUdLayers.SetActive(AIndex: Integer): Boolean;
var
  LLayer: TUdLayer;
begin
  Result := False;

  LLayer := GetItem(AIndex);

  if Assigned(LLayer) and (LLayer <> FActive) and not LLayer.Lock and Self.RaiseBeforeModifyObject('Active') then
  begin
    FActive := LLayer;

    if Assigned(FOnSelect) then FOnSelect(Self, FActive);

    Self.RaiseAfterModifyObject('Active');
    Result := True;
  end;
end;

function TUdLayers.SetActive(AName: string): Boolean;
begin
  Result := SetActive(IndexOf(AName));
end;

function TUdLayers.SetActive(AObject: TUdLayer): Boolean;
begin
  Result := SetActive(IndexOf(AObject));
end;

procedure TUdLayers.SetActive_(const AValue: TUdLayer);
begin
  Self.SetActive(AValue);
end;

function TUdLayers.GetActiveIndex(): Integer;
begin
  Result := Self.IndexOf(FActive);
end;



//------------------------------------------------------------------------------

function TUdLayers.Add(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLayer) then
    Result := Self.Add(TUdLayer(AObj));
end;


function TUdLayers.Insert(AIndex: Integer; AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLayer) and (FList.IndexOf(AObj) < 0) then
  begin
    if AIndex < 0 then AIndex := AIndex + FList.Count;
    if AIndex > FList.Count then AIndex := FList.Count;

    FList.Insert(AIndex, AObj);
    if Assigned(FOnAdd) then FOnAdd(Self, TUdLayer(AObj));

    Self.AddDocObject(AObj);
    Result := True;
  end;
end;

function TUdLayers.Remove(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLayer) then
    Result := Self.Remove(TUdLayer(AObj));
end;

function TUdLayers.RemoveAt(AIndex: Integer): Boolean;
begin
  Result := Self.Remove(AIndex);
end;

function TUdLayers.IndexOf(AObj: TUdObject): Integer;
begin
  Result := -1;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLayer) then
    Result := FList.IndexOf(TUdLayer(AObj));
end;

function TUdLayers.Contains(AObj: TUdObject): Boolean;
begin
  Result := Self.IndexOf(AObj) >= 0;
end;






//------------------------------------------------------------------------------

procedure TUdLayers.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  inherited;

  IntToStream(AStream, FList.Count);

  for I := 0 to FList.Count - 1 do
    TUdLayer(FList[I]).SaveToStream(AStream);

  IntToStream(AStream, IndexOf(FActive));
end;


procedure TUdLayers.LoadFromStream(AStream: TStream);
var
  I, LCount: Integer;
  LLayer: TUdLayer;
begin
  Self.Clear(True);

  inherited;

  LCount := IntFromStream(AStream);
  for I := 0 to LCount - 1 do
  begin
    LLayer := TUdLayer.Create(Self.Document, Self.IsDocRegister);
    LLayer.Owner := Self;
    LLayer.LoadFromStream(AStream);

    FList.Add(LLayer);
    Self.AddDocObject(LLayer, False);
  end;

  if FList.Count > 0 then FStandard := FList.Items[0];

  I := IntFromStream(AStream);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FStandard;
end;



//------------------------------------------------------------------------------


procedure TUdLayers.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I: Integer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to FList.Count - 1 do
  begin
    TUdLayer(FList[I]).SaveToXml(LXmlNode.Add());
  end;

  LXmlNode.Prop['ActiveIndex'] := IntToStr(IndexOf(FActive));
end;


procedure TUdLayers.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  LLayer: TUdLayer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  Self.Clear(True);

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to LXmlNode.Count - 1 do
  begin
    LLayer := TUdLayer.Create(Self.Document, Self.IsDocRegister);
    LLayer.Owner := Self;
    LLayer.LoadFromXml(LXmlNode.Items[I]);

    FList.Add(LLayer);
    Self.AddDocObject(LLayer, False);
  end;

  if FList.Count > 0 then FStandard := FList.Items[0];

  I := StrToIntDef(LXmlNode.Prop['ActiveIndex'], -1);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FStandard;
end;





end.