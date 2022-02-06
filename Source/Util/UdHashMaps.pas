{
  This file is part of the DelphiCAD SDK

  Copyright:
  (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdHashMaps;

//{$I UdDefs.INC}

interface

uses
  Classes;

type
  TUdHashMapItem = record
    Key: Variant;
    Value: Variant;
    HashCode: Integer; 
  end;
  TUdHashMapItemArray = array of TUdHashMapItem;


  //*** TUdHashMap ***//
  TUdHashMap = class(TPersistent)
  private
    FItems: TUdHashMapItemArray;
    FCount: Integer; 

  protected
    procedure SetCapacity(ACapacity: Integer);
    procedure GrowCapacity(ACapacity: Integer);

    function Hash(AKey: Variant): Integer; virtual;
    function HashCode(AKey: Variant): Integer;

    function RemoveValue(AValue: Variant): Boolean; virtual;
    function IndexOfKey(AKey: Variant): Integer;

    function _Add(AKey, AValue: Variant; AbortIfKeyExist: Boolean = False): Boolean;
    function _Remove(AKey: Variant): Boolean;
    function _GetValue(AKey: Variant; var AKeyExist: Boolean): Variant;

  public
    constructor Create(ACapacity: Integer = 8);
    destructor Destroy; override;

    procedure Clear();
    procedure Refresh();

    function Add(AKey, AValue: Variant; AbortIfKeyExist: Boolean = False): Boolean; overload; virtual;
    function Remove(AKey: Variant): Boolean; overload; virtual;

    function GetValue(AKey: Variant; var AKeyExist: Boolean): Variant; overload; virtual;
    function GetValue(AKey: Variant): Variant; overload; virtual;

  public
    property Count: Integer read FCount;
    property Items: TUdHashMapItemArray read FItems;

  end;


  TUdIntHashMap = class(TUdHashMap)
  public
    function Add(AKey: Integer; AValue: TObject; AbortIfKeyExist: Boolean = False): Boolean; reintroduce; overload;
    function Remove(AKey: Integer): Boolean; reintroduce; overload;
    function GetValue(AKey: Integer; var AKeyExist: Boolean): TObject; reintroduce; overload;
    function GetValue(AKey: Integer): TObject; reintroduce; overload;
  end;


  TUdStrHashMap = class(TUdHashMap)
  protected
    function Hash(AKey: Variant): Integer; override;
  public
    function Add(AKey: string; AValue: TObject; AbortIfKeyExist: Boolean = False): Boolean; reintroduce; overload;
    function Remove(AKey: string): Boolean; reintroduce; overload;
    function GetValue(AKey: string; var AKeyExist: Boolean): TObject; reintroduce; overload;
    function GetValue(AKey: string): TObject; reintroduce; overload;
  end;


  TUdStrStrHashMap = class(TUdHashMap)
  protected
    function Hash(AKey: Variant): Integer; override;
  public
    function Add(AKey, AValue: string; AbortIfKeyExist: Boolean = False): Boolean; reintroduce; overload;
    function Remove(AKey: string): Boolean; reintroduce; overload;
    function GetValue(AKey: string; var AKeyExist: Boolean): string; reintroduce; overload;
    function GetValue(AKey: string): string; reintroduce; overload;
  end;




implementation

uses
  SysUtils, Variants;
  

//=================================================================================================
{ TUdHashMap }

constructor TUdHashMap.Create(ACapacity: Integer = 8);
begin
  inherited Create;

  FCount := 0;
  SetCapacity(ACapacity);
end;

destructor TUdHashMap.Destroy;
begin
  Clear();
  inherited;
end;




//----------------------------------------------------------------------------------------

procedure TUdHashMap.Clear();
var
  I: Integer;
begin
  for I := Low(FItems) to High(FItems) do
    if FItems[I].HashCode >= 0 then
      RemoveValue(FItems[I].Value);

  SetLength(FItems, 0);
end;


procedure TUdHashMap.SetCapacity(ACapacity: Integer);
var
  I: Integer;
//  N: Integer;
begin
  FCount := 0;
  SetLength(FItems, ACapacity);

  for I := Low(FItems) to High(FItems) do
    FItems[I].HashCode := -2;  //-2: nothing   -1: deleted

//  FLengthBit := 1;
//  N := 2;

//  while N < ACapacity do
//  begin
//    N := N * 2;
//
//    Inc(FLengthBit);
//  end;
end;

procedure TUdHashMap.GrowCapacity(ACapacity: Integer);
var
  I: Integer;
  LItems: TUdHashMapItemArray;
begin
  if (ACapacity <= FCount) then
  begin
    ACapacity := FCount * 2;
//    raise Exception.Create('New capacity is invalid');
  end;

  SetLength(LItems, Length(FItems));
  try
    for I := Low(LItems) to High(LItems) do
      LItems[I] := FItems[I];

    Self.SetCapacity(ACapacity);

    for I := Low(LItems) to High(LItems) do
      if LItems[I].HashCode >= 0 then
        Self.Add(LItems[I].Key, LItems[I].Value);

  finally
    SetLength(LItems, 0);
  end;
end;




//----------------------------------------------------------------------------------------



function TUdHashMap.Hash(AKey: Variant): Integer;
begin
  Result := Integer(AKey);
end;

function TUdHashMap.HashCode(AKey: Variant): Integer;
var
  LKey: Integer;
  LReturn: Integer;
begin
  LKey := Self.Hash(AKey);

  {
  case (HashCodeMethod) of
    UdHashMove:
      begin
        nTemp := Abs(LKey);
        nTemp2 := 0;
        nTemp3 := 1 shl FLengthBit;

        while (nTemp > 0) do
        begin
          Inc(nTemp2, nTemp mod nTemp3);

          nTemp := nTemp shr FLengthBit;
        end;

        Result := nTemp2;
      end;


    UdHashMod:
      Result := LKey mod Length(FItems);
  end;
  }

  LReturn := LKey mod System.Length(FItems);
  Result := Abs(LReturn);
end;





//----------------------------------------------------------------------------------------

function TUdHashMap.RemoveValue(AValue: Variant): Boolean;
begin
  Result := False;
end;


function TUdHashMap.IndexOfKey(AKey: Variant): Integer;
var
  I, N: Integer;
  LPos: Integer;
begin
  Result := -1;
  if Length(FItems) <= 0 then Exit; 

  N := Self.HashCode(AKey);

  for I := Low(FItems) to High(FItems) do
  begin
    LPos := (N + I) mod Length(FItems);

    if FItems[LPos].HashCode = -2 then  //-2: nothing   -1: deleted
      Break
    else if (FItems[LPos].HashCode = N) and (FItems[LPos].Key = AKey) then
    begin
      Result := LPos;
      Break;
    end;
  end;
end;


function TUdHashMap._Add(AKey, AValue: Variant; AbortIfKeyExist: Boolean = False): Boolean;
var
  I, N, L: Integer;
  LKeyExist: Boolean;
  LPos, LDelPos: Integer;
begin
  Result := False;
  
  if FCount >= Length(FItems) then
  begin
    L := FCount * 2;
    if L <= 0 then L := 4;
    Self.GrowCapacity(L);
  end;

  N := Self.HashCode(AKey);

  LPos := N;
  LDelPos := -1;
  LKeyExist := False;

  for I := Low(FItems) to High(FItems) do
  begin
    LPos := (N + I) mod Length(FItems);

    if (FItems[LPos].HashCode = -2) then Break;  //-2: nothing   -1: deleted

    if ((FItems[LPos].HashCode = N) and (FItems[LPos].Key = AKey)) then
    begin
      LKeyExist := True;
      Break;
    end;

    if (LDelPos < 0) and (FItems[LPos].HashCode = -1) then
      LDelPos := LPos;
  end;

  if LKeyExist and AbortIfKeyExist then Exit; //========>>>>>
  

  if (FItems[LPos].HashCode = -2) or
    ((FItems[LPos].HashCode = N) and (FItems[LPos].Key = AKey)) then //new record
  begin
    if LKeyExist then
      RemoveValue(FItems[LPos].Value)
    else
      Inc(FCount);

    FItems[LPos].Key := AKey;
    FItems[LPos].HashCode := N;

    FItems[LPos].Value := AValue;
  end
  else if LDelPos >= 0 then
  begin
    LPos := LDelPos;

    FItems[LPos].Key := AKey;
    FItems[LPos].HashCode := N;
    FItems[LPos].Value := AValue;

    Inc(FCount);
  end;

  Result := True;
end;


function TUdHashMap.Add(AKey, AValue: Variant; AbortIfKeyExist: Boolean = False): Boolean;
begin
  Result := Self._Add(AKey, AValue, AbortIfKeyExist);
end;



function TUdHashMap._Remove(AKey: Variant): Boolean;
var
  N: Integer;
begin
  N := Self.IndexOfKey(AKey);

  if N = -1 then
    Result := False
  else begin
    FItems[N].HashCode := -1; //deleted
    Self.RemoveValue(FItems[N].Value);

    Dec(FCount);
    Result := true;
  end;
end;

function TUdHashMap.Remove(AKey: Variant): Boolean;
begin
  Result := Self._Remove(AKey);
end;


function TUdHashMap._GetValue(AKey: Variant; var AKeyExist: Boolean): Variant;
var
  LPos: Integer;
begin
  LPos := IndexOfKey(AKey);

  if LPos < 0 then
  begin
    AKeyExist := False;
    Result := Variants.Null;
  end
  else begin
    AKeyExist := True;
    Result := FItems[LPos].Value;
  end;
end;
    
function TUdHashMap.GetValue(AKey: Variant; var AKeyExist: Boolean): Variant;
begin
  Result := _GetValue(AKey, AKeyExist);
end;

function TUdHashMap.GetValue(AKey: Variant): Variant;
var
  LKeyExist: Boolean;
begin
  Result := GetValue(AKey, LKeyExist);
end;



procedure TUdHashMap.Refresh;
var
  L: Integer;
begin
  L := Length(FItems);
  while L > FCount do L := L div 2;

  if L <= 0 then L := 4;
  while L <= FCount do L := L * 2;

  Self.GrowCapacity(L);
end;







//================================================================================================
{ TUdIntHashMap }

function TUdIntHashMap.Add(AKey: Integer; AValue: TObject; AbortIfKeyExist: Boolean = False): Boolean;
begin
  Result := Self._Add(AKey, Integer(AValue), AbortIfKeyExist);
end;

function TUdIntHashMap.Remove(AKey: Integer): Boolean;
begin
  Result := Self._Remove(AKey);
end;


function TUdIntHashMap.GetValue(AKey: Integer; var AKeyExist: Boolean): TObject;
var
  LVal: Variant;
begin
  Result := nil;
  LVal := Self._GetValue(Variant(AKey), AKeyExist);

  if AKeyExist then
    Result := TObject(Integer(LVal));
end;

function TUdIntHashMap.GetValue(AKey: Integer): TObject;
var
  LVal: Variant;
  LKeyExist: Boolean;
begin
  Result := nil;
  LVal := Self._GetValue(Variant(AKey), LKeyExist);

  if LKeyExist then
    Result := TObject(Integer(LVal));
end;




//================================================================================================
{ TUdStrHashMap }

function HashStr(AStr: string): Integer;
var
  I: Integer;
  LStr: AnsiString;
  LHash: Integer;  
begin
  LStr  := AnsiString(AStr);
  LHash := 0;

  for I := 1 to Length(LStr) do
    LHash := LHash shl 5 + Ord(LStr[I]) + LHash;

  Result := Abs(LHash);
end;

function TUdStrHashMap.Hash(AKey: Variant): Integer;
begin
  Result := HashStr(AKey);
end;

function TUdStrHashMap.Add(AKey: string; AValue: TObject; AbortIfKeyExist: Boolean = False): Boolean;
begin
  Result := Self._Add(AKey, Integer(AValue), AbortIfKeyExist);
end;

function TUdStrHashMap.Remove(AKey: string): Boolean;
begin
  Result := Self._Remove(AKey);
end;

function TUdStrHashMap.GetValue(AKey: string; var AKeyExist: Boolean): TObject;
var
  LVal: Variant;
begin
  Result := nil;
  LVal := Self._GetValue(Variant(AKey), AKeyExist);

  if AKeyExist then
    Result := TObject(Integer(LVal));
end;

function TUdStrHashMap.GetValue(AKey: string): TObject;
var
  LVal: Variant;
  LKeyExist: Boolean;
begin
  Result := nil;
  LVal := Self._GetValue(Variant(AKey), LKeyExist);

  if LKeyExist then
    Result := TObject(Integer(LVal));
end;



{ TUdStrStrHashMap }


function TUdStrStrHashMap.Hash(AKey: Variant): Integer;
begin
  Result := HashStr(AKey);
end;

function TUdStrStrHashMap.Add(AKey, AValue: string; AbortIfKeyExist: Boolean = False): Boolean;
begin
  Result := Self._Add(AKey, AValue, AbortIfKeyExist);
end;

function TUdStrStrHashMap.Remove(AKey: string): Boolean;
begin
  Result := Self._Remove(AKey);
end;

function TUdStrStrHashMap.GetValue(AKey: string; var AKeyExist: Boolean): string;
var
  LVal: Variant;
begin
  Result := '';
  LVal := Self._GetValue(Variant(AKey), AKeyExist);

  if AKeyExist then
    Result := string(LVal);
end;

function TUdStrStrHashMap.GetValue(AKey: string): string;
var
  LVal: Variant;
  LKeyExist: Boolean;
begin
  Result := '';
  LVal := Self._GetValue(Variant(AKey), LKeyExist);

  if LKeyExist then
    Result := string(LVal);
end;


   
end.