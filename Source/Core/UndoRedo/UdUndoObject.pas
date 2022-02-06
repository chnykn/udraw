{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdUndoObject;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, TypInfo,
  UdIntfs, UdObject, UdUndoItem;


type
  TUdUndoKind = (ukNone, ukAdd, ukRemove, ukActive, ukProperty, ukSerialize);

  TUdUndoObject = class(TUdUndoItem)
  protected
    FKind: TUdUndoKind;
    FData: Pointer;

  protected
    procedure SetKind(const AValue: TUdUndoKind);
    procedure DisposeData(AFreeRemoveObj: Boolean);

    function PerformAdd(): Boolean;
    function PerformRemove(): Boolean;
    function PerformProperty(): Boolean;
    function PerformSerialize(): Boolean;
    function PerformActive(): Boolean;

  public
    constructor Create(AOwner: TObject); override;
    destructor Destroy; override;

    function Perform(): Boolean; override;

    function DoAddObject(AObj: TUdObject): Boolean; override;
    function DoRemoveObject(AObj: TUdObject): Boolean; override;
    function DoBeforeModifyObject(AObj: TUdObject; APropName: string): Boolean; override;

  public
    property Kind: TUdUndoKind read FKind;// write SetKind;

  end;


implementation

uses
  SysUtils, Variants,
  UdUndoGroup, UdStreams;




//=================================================================================================

type
  TFUndoGroup = class(TUdUndoGroup);



  TUdAddData = record
    ID: Integer;
  end;
  PUdAddData = ^TUdAddData;

  TUdRemoveData = record
    Obj: TUdObject;
    Index: Integer;
  end;
  PUdRemoveData = ^TUdRemoveData;

  TUdActiveData = record
    ID: Integer;
    Index: Integer;
  end;
  PUdActiveData = ^TUdActiveData;

  TUdPropertyData = record
    ID: Integer;
    Name: string;
    Value: Variant;
  end;
  PUdPropertyData = ^TUdPropertyData;

  TUdSerializeData = record
    ID: Integer;
    Stream: AnsiString;
  end;
  PUdSerializeData = ^TUdSerializeData;




//--------------------------------------------------------------------

function ObjectToStr(AObj: TUdObject): AnsiString;
var
  LStr: AnsiString;
  LStream: TMemoryStream;
begin
  Result := '';
  if not Assigned(AObj) then Exit;
  
  LStream := TMemoryStream.Create;
  try
    AObj.SaveToStream(LStream);

    LStream.Position := 0;
    UdStreams.CompressStream(LStream);

    LStream.Position := 0;
    System.SetLength(LStr, LStream.Size);
    LStream.ReadBuffer(LStr[1], LStream.Size);
  finally
    LStream.Free;
  end;

  Result := LStr;
end;

function ObjectFromStr(AObj: TUdObject; AStr: AnsiString): Boolean;
var
  LStream: TMemoryStream;
begin
  Result := False;
  if not Assigned(AObj) or (Length(AStr) <= 0) then Exit;
  
  LStream := TMemoryStream.Create;
  try
    LStream.WriteBuffer(AStr[1], System.Length(AStr));
    LStream.Position := 0;

    UdStreams.UnCompressStream(LStream);
    LStream.Position := 0;

    AObj.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;

  Result := True;
end;



//=================================================================================================
{ TUdUndoObject }

constructor TUdUndoObject.Create(AOwner: TObject);
begin
  inherited;
  FKind := ukNone;
  FData := nil;
end;

destructor TUdUndoObject.Destroy;
begin
  Self.DisposeData(True);
  FData := nil;

  inherited;
end;

procedure TUdUndoObject.DisposeData(AFreeRemoveObj: Boolean);
begin
  case FKind of
    ukAdd       : begin Dispose(PUdAddData(FData)); end;
    ukRemove    : begin if AFreeRemoveObj then PUdRemoveData(FData)^.Obj.Free; Dispose(PUdRemoveData(FData)); end;
    ukActive    : begin Dispose(PUdActiveData(FData)); end;
    ukProperty  : begin Dispose(PUdPropertyData(FData)); end;
    ukSerialize : begin Dispose(PUdSerializeData(FData)); end;
  end;
  FData := nil;
  FKind := ukNone;
end;


procedure TUdUndoObject.SetKind(const AValue: TUdUndoKind);
begin
  DisposeData(False);

  FKind := AValue;

  case FKind of
    ukAdd       : FData := New(PUdAddData);
    ukRemove    : FData := New(PUdRemoveData);
    ukActive    : FData := New(PUdActiveData);
    ukProperty  : FData := New(PUdPropertyData);
    ukSerialize : FData := New(PUdSerializeData);
  end;
end;



//---------------------------------------------------------------------

function TUdUndoObject.DoAddObject(AObj: TUdObject): Boolean;
begin
  Result := False;
  if not Assigned(AObj) then Exit;

  SetKind(ukAdd);
  PUdAddData(FData)^.ID := AObj.ID;

  Result := True;
end;

function TUdUndoObject.DoRemoveObject(AObj: TUdObject): Boolean;
var
  LObjColl: IUdObjectCollection;
begin
  Result := False;
  if not Assigned(AObj) then Exit;

  SetKind(ukRemove);
  PUdRemoveData(FData)^.Obj := AObj;

  if AObj.Owner.GetInterface(IUdObjectCollection, LObjColl) then
    PUdRemoveData(FData)^.Index := LObjColl.IndexOf(AObj)
  else
    PUdRemoveData(FData)^.Index := -1;

  Result := True;
end;

{$IF COMPILERVERSION <= 15 }

type
  TAccessStyle = (asFieldData, asAccessor, asIndexedAccessor);

function GetAccessToProperty(Instance: TObject; PropInfo: PPropInfo;
  AccessorProc: Longint; out FieldData: Pointer;
  out Accessor: TMethod): TAccessStyle;
begin
  if (AccessorProc and $FF000000) = $FF000000 then
  begin  // field - Getter is the field's offset in the instance data
    FieldData := Pointer(Integer(Instance) + (AccessorProc and $00FFFFFF));
    Result := asFieldData;
  end
  else
  begin
    if (AccessorProc and $FF000000) = $FE000000 then
      // virtual method  - Getter is a signed 2 byte integer VMT offset
      Accessor.Code := Pointer(PInteger(PInteger(Instance)^ + SmallInt(AccessorProc))^)
    else
      // static method - Getter is the actual address
      Accessor.Code := Pointer(AccessorProc);

    Accessor.Data := Instance;
    if PropInfo^.Index = Integer($80000000) then  // no index
      Result := asAccessor
    else
      Result := asIndexedAccessor;
  end;
end;

function GetDynArrayProp(Instance: TObject; PropInfo: PPropInfo): Pointer;
type
  { Need a(ny) dynamic array type to force correct call setup.
    (Address of result passed in EDX) }
  TDynamicArray = array of Byte;
type
  TDynArrayGetProc = function: TDynamicArray of object;
  TDynArrayIndexedGetProc = function (Index: Integer): TDynamicArray of object;
var
  M: TMethod;
begin
  case GetAccessToProperty(Instance, PropInfo, Longint(PropInfo^.GetProc),
    Result, M) of

    asFieldData:
      Result := PPointer(Result)^;

    asAccessor:
      Result := Pointer(TDynArrayGetProc(M)());

    asIndexedAccessor:
      Result := Pointer(TDynArrayIndexedGetProc(M)(PropInfo^.Index));

  end;
end;

function GetPropValueEx(Instance: TObject; PropInfo: PPropInfo;
  PreferStrings: Boolean): Variant;
var
  DynArray: Pointer;
begin
  // assume failure
  Result := Null;

  // return the right type
  case PropInfo^.PropType^^.Kind of
    tkInteger, tkChar, tkWChar, tkClass:
      Result := GetOrdProp(Instance, PropInfo);
    tkEnumeration:
      if PreferStrings then
        Result := GetEnumProp(Instance, PropInfo)
      else if GetTypeData(PropInfo^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
        Result := Boolean(GetOrdProp(Instance, PropInfo))
      else
        Result := GetOrdProp(Instance, PropInfo);
    tkSet:
      if PreferStrings then
        Result := GetSetProp(Instance, PropInfo)
      else
        Result := GetOrdProp(Instance, PropInfo);
    tkFloat:
      Result := GetFloatProp(Instance, PropInfo);
    tkMethod:
      Result := PropInfo^.PropType^.Name;
    tkString, tkLString:
      Result := GetStrProp(Instance, PropInfo);
    tkWString:
      Result := GetWideStrProp(Instance, PropInfo);
    tkVariant:
      Result := GetVariantProp(Instance, PropInfo);
    tkInt64:
      Result := GetInt64Prop(Instance, PropInfo);
    tkDynArray:
      begin
        DynArray := GetDynArrayProp(Instance, PropInfo);
        DynArrayToVariant(Result, DynArray, PropInfo^.PropType^);
      end;
  else
    raise EPropertyConvertError.Create(Format('Invalid property type: %s',[PropInfo.PropType^^.Name]));
  end;
end;




procedure SetDynArrayProp(Instance: TObject; PropInfo: PPropInfo;
  const Value: Pointer);
type
  TDynArraySetProc = procedure (const Value: Pointer) of object;
  TDynArrayIndexedSetProc = procedure (Index: Integer;
                                       const Value: Pointer) of object;
var
  P: Pointer;
  M: TMethod;
begin
  case GetAccessToProperty(Instance, PropInfo, Longint(PropInfo^.SetProc), P, M) of

    asFieldData:
      asm
        MOV    ECX, PropInfo
        MOV    ECX, [ECX].TPropInfo.PropType
        MOV    ECX, [ECX]

        MOV    EAX, [P]
        MOV    EDX, Value
        CALL   System.@DynArrayAsg
      end;

    asAccessor:
      TDynArraySetProc(M)(Value);

    asIndexedAccessor:
      TDynArrayIndexedSetProc(M)(PropInfo^.Index, Value);

  end;
end;

procedure SetPropValueEx(Instance: TObject; PropInfo: PPropInfo;
  const Value: Variant);

  function RangedValue(const AMin, AMax: Int64): Int64;
  begin
    Result := Trunc(Value);
    if (Result < AMin) or (Result > AMax) then
      raise ERangeError.Create('Range check error');
  end;

  function RangedCharValue(const AMin, AMax: Int64): Int64;
  var
    s: string;
    ws: string;
  begin
    case VarType(Value) of
      varString:
        begin
          s := Value;
          if Length(s) = 1 then
            Result := Ord(s[1])
          else
            Result := AMin-1;
       end;

      varOleStr:
        begin
          ws := Value;
          if Length(ws) = 1 then
            Result := Ord(ws[1])
          else
            Result := AMin-1;
        end;
    else
      Result := Trunc(Value);
    end;

    if (Result < AMin) or (Result > AMax) then
      raise ERangeError.Create('Range check error');
  end;

var
  TypeData: PTypeData;
  DynArray: Pointer;
begin
  TypeData := GetTypeData(PropInfo^.PropType^);

  // set the right type
  case PropInfo.PropType^^.Kind of
    tkChar, tkWChar:
      SetOrdProp(Instance, PropInfo, RangedCharValue(TypeData^.MinValue,
        TypeData^.MaxValue));
    tkInteger:
      if TypeData^.MinValue < TypeData^.MaxValue then
        SetOrdProp(Instance, PropInfo, RangedValue(TypeData^.MinValue,
          TypeData^.MaxValue))
      else
        // Unsigned type
        SetOrdProp(Instance, PropInfo,
          RangedValue(LongWord(TypeData^.MinValue),
          LongWord(TypeData^.MaxValue)));
    tkEnumeration:
      if (VarType(Value) = varString) or (VarType(Value) = varOleStr) then
        SetEnumProp(Instance, PropInfo, VarToStr(Value))
      else if VarType(Value) = varBoolean then
        // Need to map variant boolean values -1,0 to 1,0
        SetOrdProp(Instance, PropInfo, Abs(Trunc(Value)))
      else
        SetOrdProp(Instance, PropInfo, RangedValue(TypeData^.MinValue,
          TypeData^.MaxValue));
    tkSet:
      if VarType(Value) = varInteger then
        SetOrdProp(Instance, PropInfo, Value)
      else
        SetSetProp(Instance, PropInfo, VarToStr(Value));
    tkFloat:
      SetFloatProp(Instance, PropInfo, Value);
    tkString, tkLString:
      SetStrProp(Instance, PropInfo, VarToStr(Value));
    tkWString:
      SetWideStrProp(Instance, PropInfo, VarToWideStr(Value));
    tkVariant:
      SetVariantProp(Instance, PropInfo, Value);
    tkInt64:
      SetInt64Prop(Instance, PropInfo, RangedValue(TypeData^.MinInt64Value,
        TypeData^.MaxInt64Value));
    tkDynArray:
      begin
        DynArray := nil; // "nil array"
        DynArrayFromVariant(DynArray, Value, PropInfo^.PropType^);
        SetDynArrayProp(Instance, PropInfo, DynArray);
      end;
  else
    raise EPropertyConvertError.Create(Format('Invalid property type: %s',[PropInfo.PropType^^.Name]));
    //raise EPropertyConvertError.CreateResFmt(@SInvalidPropertyType,
    //  [PropInfo.PropType^^.Name]);
  end;
end;

{$IFEND}

function TUdUndoObject.DoBeforeModifyObject(AObj: TUdObject; APropName: string): Boolean;

  function _DoSerialize(): Boolean;
  begin
    SetKind(ukSerialize);
    PUdSerializeData(FData)^.ID := AObj.ID;
    PUdSerializeData(FData)^.Stream := ObjectToStr(AObj);

    Result := True;
  end;

  function _DoProperty(): Boolean;
  var
    LObjProp: TObject;
    LPropInfo: PPropInfo;
  begin
    Result := False;

    LPropInfo := TypInfo.GetPropInfo(AObj, APropName);
    if not Assigned(LPropInfo) then Exit; //========>>>>

    if LPropInfo.PropType^.Kind in
       [tkUnknown, {tkClass,} tkMethod, tkInterface, tkDynArray{$IFDEF D2010UP}, tkClassRef, tkPointer, tkProcedure{$ENDIF}] then
    begin
      Exit; //========>>>>
    end;

    if (LPropInfo.PropType^.Kind = tkClass) then
    begin
      LObjProp := TypInfo.GetObjectProp(AObj, LPropInfo);
      
      if Assigned(LObjProp) and LObjProp.InheritsFrom(TUdObject) then
      begin
        SetKind(ukProperty);
        PUdPropertyData(FData)^.ID := AObj.ID;
        PUdPropertyData(FData)^.Name := APropName;
        PUdPropertyData(FData)^.Value := ObjectToStr(TUdObject(LObjProp));

        Result := True;
      end;

      Exit; //========>>>>
    end;
    

    SetKind(ukProperty);
    PUdPropertyData(FData)^.ID := AObj.ID;
    PUdPropertyData(FData)^.Name := APropName;

    {$IF COMPILERVERSION <= 15 }
    PUdPropertyData(FData)^.Value := GetPropValueEx(AObj, LPropInfo, True);
    {$ELSE}
    PUdPropertyData(FData)^.Value := TypInfo.GetPropValue(AObj, LPropInfo, True);
    {$IFEND}

    Result := True;
  end;

var
  LActiveSupport: IUdActiveSupport;
begin
  Result := False;
  if not Assigned(AObj) then Exit;

  if AObj.GetInterface(IUdActiveSupport, LActiveSupport) and (UpperCase(APropName) = 'ACTIVE') then
  begin
    SetKind(ukActive);
    PUdActiveData(FData)^.ID := AObj.ID;
    PUdActiveData(FData)^.Index := LActiveSupport.GetActiveIndex();

    Result := True;
  end
  else begin
//    if Assigned(FOwner) and FOwner.InheritsFrom(TUdUndoGroup) then
//      Result := TUdUndoGroup(FOwner).SerializeHash.GetValue(AObj.ID) <> nil;

//    if not Result then
    begin
      if APropName = '' then
      begin
        Result := _DoSerialize();
      end
      else begin
        Result := _DoProperty();
        if not Result then Result := _DoSerialize();
      end;
    end;
  end;
end;






//---------------------------------------------------------------------

function TUdUndoObject.PerformAdd(): Boolean;
var
  LObject: TUdObject;
  LObjColl: IUdObjectCollection;
begin
  Result := False;
  if not Assigned(FOwner) or not FOwner.InheritsFrom(TUdUndoGroup) then Exit;

  LObject := TFUndoGroup(FOwner).GetObjectByID(PUdAddData(FData)^.ID);
  if not Assigned(LObject) then Exit;

  if Assigned(LObject.Owner) and LObject.Owner.GetInterface(IUdObjectCollection, LObjColl) then
  begin
    Self.SetKind(ukRemove);

    PUdRemoveData(FData)^.Obj   := LObject;
    PUdRemoveData(FData)^.Index := LObjColl.IndexOf(LObject);

    LObjColl.Remove(LObject);
    Result := True;
  end
  else
    Self.SetKind(ukNone);
end;

function TUdUndoObject.PerformRemove(): Boolean;
var
  LIndex: Integer;
  LObject: TUdObject;
  LObjColl: IUdObjectCollection;
begin
  Result := False;

  LIndex  := PUdRemoveData(FData)^.Index;
  LObject := PUdRemoveData(FData)^.Obj{ect};

  if //(LIndex >= 0) and
     Assigned(LObject) and Assigned(LObject.Owner) and
     LObject.Owner.GetInterface(IUdObjectCollection, LObjColl) then
  begin
    if LIndex < 0 then LIndex := 0;
    LObjColl.Insert(LIndex, LObject);

    Self.SetKind(ukAdd);
    PUdAddData(FData)^.ID := LObject.ID;

    Result := True;
  end
  else begin
    LObject.Free;
    Self.SetKind(ukNone);
  end;
end;




function TUdUndoObject.PerformActive(): Boolean;
var
  LObject: TUdObject;
  LCurIndex: Integer;
  LActiveSupport: IUdActiveSupport;
begin
  Result := False;
  if not Assigned(FOwner) or not FOwner.InheritsFrom(TUdUndoGroup) then Exit;

  LObject := TFUndoGroup(FOwner).GetObjectByID(PUdActiveData(FData)^.ID);
  if not Assigned(LObject) then Exit;

  if LObject.GetInterface(IUdActiveSupport, LActiveSupport) then
  begin
    LCurIndex := LActiveSupport.GetActiveIndex();
    LActiveSupport.SetActive(PUdActiveData(FData)^.Index);

    PUdActiveData(FData)^.Index := LCurIndex;
    Result := True;
  end
  else
    Self.SetKind(ukNone);
end;

function TUdUndoObject.PerformProperty(): Boolean;
var
  LObject: TUdObject;
  LObjProp: TObject;
  LPropInfo: PPropInfo;
  LPropName: string;
  LPropValue: Variant;
  LCurPropValue: Variant;
  LCurStr, LPrvStr: AnsiString;
begin
  Result := False;
  if not Assigned(FOwner) or not FOwner.InheritsFrom(TUdUndoGroup) then Exit;

  LObject := TFUndoGroup(FOwner).GetObjectByID(PUdPropertyData(FData)^.ID);
  if not Assigned(LObject) then Exit;

  LPropName := PUdPropertyData(FData)^.Name;
  LPropValue := PUdPropertyData(FData)^.Value;

  if (LPropName <> '') {and not VarIsNull(PUdPropertyData(FData)^.Value)} then
  begin
    LPropInfo := TypInfo.GetPropInfo(LObject, LPropName);

    if LPropInfo <> nil then
    begin
      if (LPropInfo.PropType^.Kind = tkClass) then
      begin
        LObjProp := TypInfo.GetObjectProp(LObject, LPropInfo);

        if Assigned(LObjProp) and LObjProp.InheritsFrom(TUdObject) then
        begin
          LCurStr := ObjectToStr( TUdObject(LObjProp) );

          LPrvStr := AnsiString(LPropValue);
          ObjectFromStr(TUdObject(LObjProp), LPrvStr);

          PUdPropertyData(FData)^.Value := LCurStr;
          Result := True;
        end;
      end
      else begin
        {$IF COMPILERVERSION <= 15 }
        LCurPropValue := GetPropValueEx(LObject, LPropInfo, True);
        SetPropValueEx(LObject, LPropInfo, LPropValue);
        {$ELSE}
        LCurPropValue := TypInfo.GetPropValue(LObject, LPropInfo, True);
        TypInfo.SetPropValue(LObject, LPropInfo, LPropValue);
        {$IFEND}

        PUdPropertyData(FData)^.Value := LCurPropValue;

        Result := True;
      end;
    end;
  end;

  if not Result then Self.SetKind(ukNone);
end;

function TUdUndoObject.PerformSerialize(): Boolean;
var
  LObject: TUdObject;
  LCurStr, LPrvStr: AnsiString;
begin
  Result := False;
  if not Assigned(FOwner) or not FOwner.InheritsFrom(TUdUndoGroup) then Exit;

  LObject := TFUndoGroup(FOwner).GetObjectByID(PUdSerializeData(FData)^.ID);
  if not Assigned(LObject) then Exit;

  LPrvStr := PUdSerializeData(FData)^.Stream;
  LCurStr := ObjectToStr( LObject );

  ObjectFromStr(LObject, LPrvStr);

  PUdSerializeData(FData)^.Stream := LCurStr;
  Result := True;
end;






function TUdUndoObject.Perform(): Boolean;
begin
  Result := False;
  if not Assigned(FOwner) then Exit; //=====>>>

  case FKind of
    ukAdd       : Result := PerformAdd();
    ukRemove    : Result := PerformRemove();
    ukActive    : Result := PerformActive();
    ukProperty  : Result := PerformProperty();
    ukSerialize : Result := PerformSerialize();
  end;
end;


end.