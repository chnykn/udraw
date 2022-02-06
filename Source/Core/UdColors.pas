{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdColors;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics,
  UdConsts, UdTypes, UdIntfs, UdObject, UdColor;

type
  TUdColors = class(TUdObject, IUdObjectCollection , IUdActiveSupport)
  private
    FList: TList;

    FActive: TUdColor;
    FByLayer: TUdColor;
    FByBlock: TUdColor;

    FOnAdd: TUdColorEvent;
    FOnSelect: TUdColorEvent;
    FOnRemove: TUdColorAllowEvent;

  protected
    function GetTypeID: Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function Init(): Boolean;
    function GetCount: Integer;

    function GetColor(AIndex: Integer): TUdColor;
    procedure SetColor(AIndex: Integer; const AValue: TUdColor);

    procedure SetActive_(const AValue: TUdColor);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure Clear(All: Boolean = False);

    function IndexOf(AName: string): Integer; overload;
    function IndexOf(AColor: Integer; AColorType: TUdColorType): Integer; overload;
    function IndexOf(AObject: TUdColor): Integer; overload;

    function Add(AColor: TColor): Boolean; overload;
    function Add(AColor: TUdIndexColor): Boolean; overload;
    function Add(AObject: TUdColor): Boolean; overload;

    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AName: string): Boolean; overload;
    function Remove(AColor: Integer; AColorType: TUdColorType): Boolean; overload;
    function Remove(AObject: TUdColor): Boolean; overload;

    function GetItem(AIndex: Integer): TUdColor; overload;
    function GetItem(AName: string): TUdColor; overload;
    function GetItem(AColor: Integer; AColorType: TUdColorType): TUdColor; overload;

    function SetActive(AIndex: Integer): Boolean; overload;
    function SetActive(AName: string): Boolean; overload;
    function SetActive(AObject: TUdColor): Boolean; overload;
    function SetActive(AColor: Integer; AColorType: TUdColorType): Boolean; overload;

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
    property Items[Index: Integer]: TUdColor read GetColor write SetColor;

  published
    property Active: TUdColor read FActive write SetActive_;

    property ByLayer: TUdColor read FByLayer;// write FByLayer;
    property ByBlock: TUdColor read FByBlock;// write FByLayer;

    property Count: Integer read GetCount;

    property OnAdd: TUdColorEvent read FOnAdd write FOnAdd;
    property OnSelect: TUdColorEvent read FOnSelect write FOnSelect;
    property OnRemove: TUdColorAllowEvent read FOnRemove write FOnRemove;

  end;


implementation

uses
  SysUtils,
  UdStreams, UdXml;


//==============================================================================================
{ TUdColors }

constructor TUdColors.Create();
begin
  inherited;

  FByLayer := TUdColor.Create();
  FByLayer.IndexColor := CL_WHITE;
  FByLayer.ByKind := bkByLayer;
  FByLayer.Owner := Self;

  FByBlock := TUdColor.Create();
  FByBlock.IndexColor := CL_WHITE;
  FByBlock.ByKind := bkByBlock;
  FByBlock.Owner := Self;

  FActive := FByLayer;

  FList := TList.Create();

  FList.Add(FByLayer);
  FList.Add(FByBlock);

  Init();
end;

destructor TUdColors.Destroy;
begin
  Self.Clear(True);

  if Assigned(FList) then FList.Free;
  FList := nil;

  FByLayer := nil;
  FByBlock := nil;

  inherited;
end;



function TUdColors.GetTypeID: Integer;
begin
  Result := ID_COLORS;
end;

procedure TUdColors.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
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



function TUdColors.GetColor(AIndex: Integer): TUdColor;
begin
  Result := Self.GetItem(AIndex);
end;

procedure TUdColors.SetColor(AIndex: Integer; const AValue: TUdColor);
var
  LColor: TUdColor;
begin
//  if AIndex < 2 then Exit; // 0:FByLayer  1:FByBlock

  LColor := Self.GetItem(AIndex);

  if Assigned(LColor) and Assigned(AValue) and (LColor <> AValue) then
  begin
    LColor.Assign(AValue);

    case AIndex  of
      0: LColor.ByKind := bkByLayer;
      1: LColor.ByKind := bkByBlock;
    end;
  end;
end;




function TUdColors.Init: Boolean;
var
  I: Integer;
  LColor: TUdColor;
begin
  for I := Low(sInitColors) to High(sInitColors) do
  begin
    LColor := TUdColor.Create();
    LColor.IndexColor := I;
    LColor.Owner := Self;
    LColor.SetDocument(Self.Document, Self.IsDocRegister);

    FList.Add(LColor);
    Self.AddDocObject(LColor, False);
  end;

  Result := True;
end;

procedure TUdColors.Clear(All: Boolean = False);
var
  I, N: Integer;
begin
  FActive := nil;

  if All then N := 0 else N := 2 + High(sInitColors);

  for I := FList.Count - 1 downto N do
  begin
    Self.RemoveDocObject(TUdObject(FList[I]), False);
    FList.Delete(I);
  end;

  if All then
  begin
    FByLayer := nil;
    FByBlock := nil;
  end
  else
    FActive := FByLayer;

  Self.RaiseChanged();
end;

//procedure TUdColors.RaiseChange;
//begin
//  if Assigned(FOnChange) then FOnChange(Self);
//  if Assigned(_FOnChange) then _FOnChange(Self);
//end;



//-----------------------------------------------------------------------------

procedure TUdColors.CopyFrom(AValue: TUdObject);
var
  I, N: Integer;
  LSrcItem, LDstItem: TUdColor;
begin
  inherited;

  if not AValue.InheritsFrom(TUdColors) then Exit;

  if (TUdColors(AValue).FList.Count > 0) then
  begin
    Self.Clear(True);

    for I := 0 to TUdColors(AValue).FList.Count - 1 do
    begin
      LSrcItem := TUdColor(TUdColors(AValue).FList[I]);
      if not Assigned(LSrcItem) then Continue;

      LDstItem := TUdColor.Create();
      LDstItem.Assign(LSrcItem);
      
      LDstItem.Owner := Self;
      LDstItem.SetDocument(Self.Document, Self.IsDocRegister);
          
      FList.Add(LDstItem);
      Self.AddDocObject(LDstItem, False);
    end;

    FActive := FByLayer;

    if FList.Count > 0 then FByLayer := FList.Items[0];
    if FList.Count > 1 then FByBlock := FList.Items[1];

    N := TUdColors(AValue).IndexOf(TUdColors(AValue).Active);
    if N >= 0 then
      FActive := GetItem(N)
    else
      FActive := FByLayer;
  end;
end;

function TUdColors.GetCount: Integer;
begin
  Result := FList.Count;
end;




//-----------------------------------------------------------------------------

function TUdColors.IndexOf(AName: string): Integer;
var
  I: Integer;
  LName: string;
  LColor: TUdColor;
begin
  Result := -1;

  LName := LowerCase(Trim(AName));

  for I := 0 to FList.Count - 1 do
  begin
    LColor := TUdColor(FList[I]);

    if LowerCase(Trim(LColor.Name)) = LName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TUdColors.IndexOf(AColor: Integer; AColorType: TUdColorType): Integer;

  function _IsEqualColor(AObject: TUdColor; AColorType: TUdColorType; AValue: Integer): Boolean;
  begin
    Result := False;
    if AObject.ColorType = AColorType then
    begin
      case AColorType of
        ctTrueColor : Result := AObject.TrueColor  = AValue;
        ctIndexColor: Result := AObject.IndexColor = AValue;
      end;
    end;
  end;

var
  I: Integer;
  LColor: TUdColor;
  LValue: Integer;
begin
  Result := -1;

  LValue := AColor;
  if AColorType = ctTrueColor then LValue := ColorToRGB(AColor);

  for I := FList.Count - 1 downto 0 do
  begin
    LColor := TUdColor(FList[I]);

    if _IsEqualColor(LColor, AColorType, LValue) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TUdColors.IndexOf(AObject: TUdColor): Integer;
begin
  Result := FList.IndexOf(AObject);
end;






//-----------------------------------------------------------------------------

function TUdColors.Add(AObject: TUdColor): Boolean;
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

function TUdColors.Add(AColor: TColor): Boolean;
var
  N: Integer;
  LColor: TUdColor;
begin
  Result := False;

  N := IndexOf(AColor, ctTrueColor);
  if (N >= 2) then Exit; //======>>>

  LColor := TUdColor.Create();
  LColor.TrueColor := ColorToRGB(AColor);

  LColor.Owner := Self;
  LColor.SetDocument(Self.Document, Self.IsDocRegister);

  FList.Add(LColor);
  Self.AddDocObject(LColor);

  if Assigned(FOnAdd) then FOnAdd(Self, LColor);
  Result := True;
end;

function TUdColors.Add(AColor: TUdIndexColor): Boolean;
var
  N: Integer;
  LColor: TUdColor;
begin
  Result := False;

  N := IndexOf(AColor, ctIndexColor);
  if (N >= 2) then Exit; //======>>>

  LColor := TUdColor.Create();
  LColor.IndexColor := AColor;
  
  LColor.Owner := Self;
  LColor.SetDocument(Self.Document, Self.IsDocRegister);

  FList.Add(LColor);
  Self.AddDocObject(LColor);

  if Assigned(FOnAdd) then FOnAdd(Self, LColor);
  Result := True;
end;





//-----------------------------------------------------------------------------

function TUdColors.Remove(AIndex: Integer): Boolean;
var
  LColor: TUdColor;
begin
  Result := False;
  if (AIndex < 2) or (AIndex >= FList.Count) then Exit;

  LColor := TUdColor(FList.Items[AIndex]);

  if FActive <> LColor then
  begin
    Result := True;
    if Assigned(FOnRemove) then FOnRemove(Self, LColor, Result);

    if Result then
    begin
      Self.RemoveDocObject(LColor);
      FList.Delete(AIndex);
    end;
  end;
end;

function TUdColors.Remove(AName: string): Boolean;
begin
  Result := Remove(IndexOf(AName));
end;

function TUdColors.Remove(AColor: Integer; AColorType: TUdColorType): Boolean;
begin
  Result := Remove(IndexOf(AColor, AColorType));
end;

function TUdColors.Remove(AObject: TUdColor): Boolean;
begin
  Result := Remove(IndexOf(AObject));
end;



//-----------------------------------------------------------------------------

function TUdColors.GetItem(AIndex: Integer): TUdColor;
begin
  Result := nil;
  if (AIndex >= 0) and (AIndex < FList.Count) then
    Result := TUdColor(FList.Items[AIndex]);
end;

function TUdColors.GetItem(AName: string): TUdColor;
begin
  Result := GetItem(IndexOf(AName));
end;

function TUdColors.GetItem(AColor: Integer; AColorType: TUdColorType): TUdColor;
begin
  Result := GetItem(IndexOf(AColor, AColorType));
end;




//-----------------------------------------------------------------------------

function TUdColors.SetActive(AIndex: Integer): Boolean;
var
  LColor: TUdColor;
begin
  Result := False;

  LColor := GetItem(AIndex);

  if Assigned(LColor) and (LColor <> FActive) and Self.RaiseBeforeModifyObject('Active') then
  begin
    FActive := LColor;

    if Assigned(FOnSelect) then FOnSelect(Self, FActive);

    Self.RaiseAfterModifyObject('Active');
    Result := True;
  end;
end;


function TUdColors.SetActive(AName: string): Boolean;
begin
  Result := SetActive(IndexOf(AName));
end;

function TUdColors.SetActive(AObject: TUdColor): Boolean;
begin
  Result := SetActive(IndexOf(AObject));
end;

function TUdColors.SetActive(AColor: Integer; AColorType: TUdColorType): Boolean;
begin
  Result := SetActive(IndexOf(AColor, AColorType));
end;

procedure TUdColors.SetActive_(const AValue: TUdColor);
begin
  Self.SetActive(AValue);
end;

function TUdColors.GetActiveIndex(): Integer;
begin
  Result := Self.IndexOf(FActive);
end;



//-----------------------------------------------------------------------------

function TUdColors.Add(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdColor) then
    Result := Self.Add(TUdColor(AObj));
end;

function TUdColors.Insert(AIndex: Integer; AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdColor) and (FList.IndexOf(AObj) < 0) then
  begin
    if AIndex < 0 then AIndex := AIndex + FList.Count;
    if AIndex > FList.Count then AIndex := FList.Count;

    FList.Insert(AIndex, AObj);
    if Assigned(FOnAdd) then FOnAdd(Self, TUdColor(AObj));

    Self.AddDocObject(AObj);
    Result := True;
  end;
end;


function TUdColors.Remove(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdColor) then
    Result := Self.Remove(TUdColor(AObj));
end;

function TUdColors.RemoveAt(AIndex: Integer): Boolean;
begin
  Result := Self.Remove(AIndex);
end;


function TUdColors.IndexOf(AObj: TUdObject): Integer;
begin
  Result := -1;
  if Assigned(AObj) and AObj.InheritsFrom(TUdColor) then
    Result := FList.IndexOf(TUdColor(AObj));
end;

function TUdColors.Contains(AObj: TUdObject): Boolean;
begin
  Result := Self.IndexOf(AObj) >= 0;
end;




//-----------------------------------------------------------------------------

procedure TUdColors.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  inherited;

  IntToStream(AStream, FList.Count);

  for I := 0 to FList.Count - 1 do
    TUdColor(FList[I]).SaveToStream(AStream);

  IntToStream(AStream, IndexOf(FActive));
end;

procedure TUdColors.LoadFromStream(AStream: TStream);
var
  I, LCount: Integer;
  LColor: TUdColor;
begin
  Self.Clear(True);

  inherited;

  LCount := IntFromStream(AStream);
  for I := 0 to LCount - 1 do
  begin
    LColor := TUdColor.Create(Self.Document, True);
    LColor.Owner := Self;
    LColor.LoadFromStream(AStream);

    FList.Add(LColor);
    Self.AddDocObject(LColor, False);
  end;

  if FList.Count > 0 then FByLayer := FList.Items[0];
  if FList.Count > 1 then FByBlock := FList.Items[1];

  I := IntFromStream(AStream);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FByLayer;
end;




//------------------------------------------------------------------------------


procedure TUdColors.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I: Integer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to FList.Count - 1 do
  begin
    TUdColor(FList[I]).SaveToXml(LXmlNode.Add());
  end;

  LXmlNode.Prop['ActiveIndex'] := IntToStr(IndexOf(FActive));
end;


procedure TUdColors.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  LColor: TUdColor;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  Self.Clear(True);

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to LXmlNode.Count - 1 do
  begin
    LColor := TUdColor.Create(Self.Document, True);
    LColor.Owner := Self;
    LColor.LoadFromXml(LXmlNode.Items[I]);

    FList.Add(LColor);
    Self.AddDocObject(LColor, False);
  end;

  if FList.Count > 0 then FByLayer := FList.Items[0];
  if FList.Count > 1 then FByBlock := FList.Items[1];

  I := StrToIntDef(LXmlNode.Prop['ActiveIndex'], -1);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FByLayer;
end;




end.