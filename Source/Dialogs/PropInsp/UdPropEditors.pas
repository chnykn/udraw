{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPropEditors;

interface

uses
  Windows, Classes, Controls, Graphics, Forms, Types, TypInfo,
  UdPropConsts;

type
  TUdPropEditor = class;
  TUdPropEditorClass = class of TUdPropEditor;

  TUdPropAttr = (praValueList, praSubProperties, praDialog, praMultiSelect,
    praSortList, praReadOnly, praVolatileSubProperties, praNotNestable, praAutoUpdate,
    praOwnerDrawValues, praComponentRef, praDropDownList);
  TUdPropAttrs = set of TUdPropAttr;

  TUdPropGetEditorClassProc = function(AInstance: TPersistent; APropInfo: PPropInfo): TUdPropEditorClass of object;

  TUdPropGetComponentEvent = procedure(Sender: TObject; const AComponentName: string; var AComponent: TComponent) of object;
  TUdPropGetComponentNamesEvent = procedure(Sender: TObject; AClass: TComponentClass; AResult: TStrings) of object;
  TUdPropGetComponentNameEvent = procedure(Sender: TObject; AComponent: TComponent; var AName: string) of object;

  TUdPropEditorPropListItem = packed record
    Instance: TPersistent;
    PropInfo: PPropInfo;
  end;

  PUdPropEditorPropList = ^TUdPropEditorPropList;
  TUdPropEditorPropList = array[0..1023 { Range not used }] of TUdPropEditorPropListItem;

  TUdPropEditor = class(TObject)
  protected
    FPropList: PUdPropEditorPropList;
    FPropCount: Integer;
    FOnModified: TNotifyEvent;
    FOnGetComponent: TUdPropGetComponentEvent;
    FOnGetComponentNames: TUdPropGetComponentNamesEvent;
    FOnGetComponentName: TUdPropGetComponentNameEvent;
    FDesigner: Pointer;

  protected
    function DoGetValue: string;

    function GetPropTypeInfo: PTypeInfo; virtual;
    function GetIsAnyReadonly(): Boolean;
    procedure SetPropEntry(AIndex: Integer; AInstance: TPersistent; APropInfo: PPropInfo);

  public
    constructor Create(ADesigner: Pointer; APropCount: Integer); virtual;
    destructor Destroy; override;
    procedure Modified;

    procedure ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); virtual;
    procedure ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); virtual;
    procedure ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); virtual;


    function GetComponent(const AComponentName: string): TComponent;
    procedure GetComponentNames(AClass: TComponentClass; AResult: TStrings);
    function GetComponentName(AComponent: TComponent): string;
    function GetValue: string; virtual;
    procedure SetValue(const Value: string); virtual;
    function GetAttrs: TUdPropAttrs; virtual;
    procedure GetValues(AValues: TStrings); virtual;
    procedure GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean); virtual; // Returns a list of TUdPropEditor
    function GetPropName: string; virtual;
    function AllEqual: Boolean; virtual;
    procedure Edit; virtual;

    function GetPropInfo(AIndex: Integer): PPropInfo;
    function GetInstance(AIndex: Integer): TPersistent;
    function GetFloatValue(AIndex: Integer): Extended;
    function GetInt64Value(AIndex: Integer): Int64;
    function GetOrdValue(AIndex: Integer): Longint;
    function GetStrValue(AIndex: Integer): string;
    function GetVarValue(AIndex: Integer): Variant;
    procedure SetFloatValue(Value: Extended);
    procedure SetInt64Value(Value: Int64);
    procedure SetOrdValue(Value: Longint);
    procedure SetStrValue(const Value: string);
    procedure SetVarValue(const Value: Variant);

  public
    property PropName: string read GetPropName;
    property PropTypeInfo: PTypeInfo read GetPropTypeInfo;
    property PropCount: Integer read FPropCount;
    property IsAnyReadonly: Boolean read GetIsAnyReadonly;
    property Value: string read DoGetValue write SetValue;
    property Designer: Pointer read FDesigner;
    property OnModified: TNotifyEvent read FOnModified write FOnModified;
    property OnGetComponent: TUdPropGetComponentEvent read FOnGetComponent write FOnGetComponent;
    property OnGetComponentNames: TUdPropGetComponentNamesEvent read FOnGetComponentNames write FOnGetComponentNames;
    property OnGetComponentName: TUdPropGetComponentNameEvent read FOnGetComponentName write FOnGetComponentName;

  end;

  TUdNestedPropEditor = class(TUdPropEditor)
  protected
    FParent: TUdPropEditor;
  public
    constructor Create(AParent: TUdPropEditor); reintroduce;
    destructor Destroy; override;
    function GetPropName: string; override;

    property Parent: TUdPropEditor read FParent;
  end;


//---------------------------------------------------------------------------
{ Standart property editors }

  TUdOrdinalPropEditor = class(TUdPropEditor)
  public
    function AllEqual: Boolean; override;
  end;

  TUdIntegerPropEditor = class(TUdOrdinalPropEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;

  TUdCharPropEditor = class(TUdOrdinalPropEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;

  TUdEnumPropEditor = class(TUdOrdinalPropEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    function GetAttrs: TUdPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TUdFloatPropEditor = class(TUdPropEditor)
  public
    function AllEqual: Boolean; override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;

  TUdStringPropEditor = class(TUdPropEditor)
  public
    function AllEqual: Boolean; override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;

  TUdSetElemPropEditor = class(TUdNestedPropEditor)
  private
    FElement: Integer;
  public
    constructor Create(AParent: TUdPropEditor; AElement: Integer); reintroduce;
    function GetPropTypeInfo: PTypeInfo; override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    function GetAttrs: TUdPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
    function GetPropName: string; override;
    function AllEqual: Boolean; override;

    property Element: Integer read FElement;
  end;

  TUdSetPropEditor = class(TUdOrdinalPropEditor)
  public
    function GetValue: string; override;
    function GetAttrs: TUdPropAttrs; override;
    procedure GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean); override;
  end;

  TUdClassPropEditor = class(TUdPropEditor)
  public
    function GetValue: string; override;
    function GetAttrs: TUdPropAttrs; override;
    procedure GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean); override;
  end;

  TUdComponentPropEditor = class(TUdPropEditor)
  public
    function AllEqual: Boolean; override;
    function GetAttrs: TUdPropAttrs; override;
    procedure GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean); override;
    function GetValue: string; override;
    procedure GetValues(AValues: TStrings); override;
    procedure SetValue(const Value: string); override;
  end;

  TUdVariantTypePropEditor = class(TUdNestedPropEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    procedure GetValues(AValues: TStrings); override;
    function GetPropName: string; override;
    function GetAttrs: TUdPropAttrs; override;
    function AllEqual: Boolean; override;
  end;

  TUdVariantPropEditor = class(TUdPropEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    function GetAttrs: TUdPropAttrs; override;
    procedure GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean); override;
  end;

  TUdInt64PropEditor = class(TUdPropEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    function AllEqual: Boolean; override;
  end;

  TUdComponentNamePropEditor = class(TUdStringPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
  end;

  TUdDatePropEditor = class(TUdPropEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    function GetAttrs: TUdPropAttrs; override;
  end;

  TUdTimePropEditor = class(TUdPropEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    function GetAttrs: TUdPropAttrs; override;
  end;

  TUdDateTimePropEditor = class(TUdPropEditor)
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    function GetAttrs: TUdPropAttrs; override;
  end;


//---------------------------------------------------------------------------
{ VCL property editors }

  TUdCaptionPropEditor = class(TUdStringPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
  end;

  TUdColorPropEditor = class(TUdIntegerPropEditor)
  private
    FValues: TStrings;
    procedure AddValue(const LS: string);
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    procedure GetValues(AValues: TStrings); override;
    function GetAttrs: TUdPropAttrs; override;
    procedure Edit; override;
    procedure ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); override;
    procedure ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); override;
    procedure ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;
  end;

  TUdCursorPropEditor = class(TUdIntegerPropEditor)
  protected
    FValues: TStrings;
    procedure AddValue(const LS: string);
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    procedure GetValues(AValues: TStrings); override;
    function GetAttrs: TUdPropAttrs; override;
    procedure ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); override;
    procedure ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); override;
    procedure ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;
  end;

  TUdFontCharsetPropEditor = class(TUdIntegerPropEditor)
  protected
    FValues: TStrings;
    procedure AddValue(const LS: string);
  public
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
    procedure GetValues(AValues: TStrings); override;
    function GetAttrs: TUdPropAttrs; override;
  end;

  TUdFontNamePropEditor = class(TUdStringPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TUdImeNamePropEditor = class(TUdStringPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    procedure GetValues(AValues: TStrings); override;
  end;

  TUdFontPropEditor = class(TUdClassPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    procedure Edit; override;
  end;

  TUdModalResultPropEditor = class(TUdIntegerPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    function GetValue: string; override;
    procedure GetValues(AValues: TStrings); override;
    procedure SetValue(const Value: string); override;
  end;

  TUdPenStylePropEditor = class(TUdEnumPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    procedure ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); override;
    procedure ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); override;
    procedure ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;
  end;

  TUdBrushStylePropEditor = class(TUdEnumPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    procedure ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer); override;
    procedure ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer); override;
    procedure ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;
  end;

  TUdTabOrderPropEditor = class(TUdIntegerPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
  end;

  TUdShortCutPropEditor = class(TUdOrdinalPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    function GetValue: string; override;
    procedure GetValues(AValues: TStrings); override;
    procedure SetValue(const Value: string); override;
  end;

  TUdStringsPropEditor = class(TUdClassPropEditor)
  public
    function GetAttrs: TUdPropAttrs; override;
    procedure Edit; override;
  end;



function FColorToBorderColor(AColor: TColor; ASelected: Boolean): TColor;

procedure UdGetObjectsProps(ADesigner: Pointer; AObjList: TList; AKinds: TTypeKinds; AOnlyNestable: Boolean;
  AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean);



implementation

uses
  SysUtils, Variants, Menus, Dialogs,
  UdPropStringsEdit;




//================================================================================================

type
  TColorQuad = record
    Red, Green, Blue,Alpha: Byte;
  end;

function FColorToBorderColor(AColor: TColor; ASelected: Boolean): TColor;
begin
  if (TColorQuad(AColor).Red > 192) or (TColorQuad(AColor).Green > 192) or (TColorQuad(AColor).Blue > 192) then
    Result := clBlack
  else if ASelected then
    Result := clWhite
  else
    Result := AColor;
end;


//==================================================================================================

procedure UdGetObjectsProps(ADesigner: Pointer; AObjList: TList; AKinds: TTypeKinds;
  AOnlyNestable: Boolean; AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean);

type
  TObjProps = record
    Props: PPropList;
    Count: Integer;
  end;

var
  I, J, K: Integer;
  LIndex, LObjCount: Integer;
  LObj: TPersistent;
  LAttrs: TUdPropAttrs;
  LEditor: TUdPropEditor;
  LEditorClass: TUdPropEditorClass;
  LPropLists: array of TObjProps;
  LIntersection: array of array of PPropInfo;
begin
  LObjCount := AObjList.Count;
  { Create prop lists }
  System.SetLength(LPropLists, LObjCount);
  for I := 0 to LObjCount - 1 do
  begin
    LObj := AObjList[I];
    LPropLists[I].Count := GetPropList(LObj.ClassInfo, AKinds, nil, False);
    GetMem(LPropLists[I].Props, LPropLists[I].Count * SizeOf(Pointer));
    try
      GetPropList(LObj.ClassInfo, AKinds, LPropLists[I].Props, SortList);
    except
      FreeMem(LPropLists[I].Props);
      raise;
    end;
  end;
  try
    { Initialize intersection }
    System.SetLength(LIntersection, LPropLists[0].Count);
    for I := 0 to LPropLists[0].Count - 1 do
    begin
      System.SetLength(LIntersection[I], LObjCount);
      LIntersection[I][0] := LPropLists[0].Props[I];
    end;
    { Intersect }
    for I := 1 to LObjCount - 1 do
      for J := High(LIntersection) downto Low(LIntersection) do
      begin
        LIndex := -1;
        for K := 0 to LPropLists[I].Count - 1 do
          if (LPropLists[I].Props[K].PropType^ = LIntersection[J][0].PropType^) and
            SameText(string(LPropLists[I].Props[K].Name), string(LIntersection[J][0].Name)) then
          begin
            LIndex := K;
            Break;
          end;
        if LIndex <> -1 then
          LIntersection[J][I] := LPropLists[I].Props[K]
        else
        begin
          for K := J + 1 to High(LIntersection) do
            LIntersection[K - 1] := LIntersection[K];
          System.SetLength(LIntersection, System.Length(LIntersection) - 1);
        end;
      end;
    { Create property editors }
    for I := Low(LIntersection) to High(LIntersection) do
    begin
      { Determine editor class }
      LEditorClass := AGetEditorClassProc(TPersistent(AObjList[0]), LIntersection[I][0]);
      for J := 0 to LObjCount - 1 do
        if AGetEditorClassProc(TPersistent(AObjList[J]), LIntersection[I][J]) <> LEditorClass then
        begin
          LEditorClass := nil;
          Break;
        end;
      { Create editor }
      if LEditorClass <> nil then
      begin
        LEditor := LEditorClass.Create(ADesigner, AObjList.Count);
        try
          for J := 0 to AObjList.Count - 1 do
            LEditor.SetPropEntry(J, TPersistent(AObjList[J]), LIntersection[I][J]);
          LAttrs := LEditor.GetAttrs;
          if ((LObjCount = 1) or (praMultiSelect in LAttrs)) and
            (not AOnlyNestable or not (praNotNestable in LAttrs)) then
            AResult.Add(LEditor)
          else
          begin
            LEditor.Free;
            LEditor := nil;
          end;
        except
          LEditor.Free;
          raise;
        end;
      end;
    end;
  finally
    { Free prop lists }
    for I := 0 to LObjCount - 1 do
      FreeMem(LPropLists[I].Props);
  end;
end;



//==================================================================================================
{ TUdPropEditor }

function TUdPropEditor.AllEqual: Boolean;
begin
  Result := FPropCount = 1;
end;


constructor TUdPropEditor.Create(ADesigner: Pointer; APropCount: Integer);
begin
  GetMem(FPropList, APropCount * SizeOf(TUdPropEditorPropListItem));
  FDesigner := ADesigner;
  FPropCount := APropCount;
end;


destructor TUdPropEditor.Destroy;
begin
  if FPropList <> nil then
    FreeMem(FPropList, FPropCount * SizeOf(TUdPropEditorPropListItem));
end;


function TUdPropEditor.DoGetValue: string;
begin
  if AllEqual then
    Result := GetValue
  else
    Result := '';
end;


procedure TUdPropEditor.Edit;
begin
  // ... ...
end;


function TUdPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect];
end;


function TUdPropEditor.GetComponent(const AComponentName: string): TComponent;
begin
  Result := nil;
  if Assigned(OnGetComponent) then OnGetComponent(Self, AComponentName, Result);
end;


function TUdPropEditor.GetComponentName(AComponent: TComponent): string;
begin
  Result := AComponent.Name;
  if Assigned(OnGetComponentName) then OnGetComponentName(Self, AComponent, Result);
end;


procedure TUdPropEditor.GetComponentNames(AClass: TComponentClass; AResult: TStrings);
begin
  if Assigned(OnGetComponentNames) then OnGetComponentNames(Self, AClass, AResult);
end;


function TUdPropEditor.GetFloatValue(AIndex: Integer): Extended;
begin
  with FPropList^[AIndex] do
    Result := GetFloatProp(Instance, PropInfo);
end;


function TUdPropEditor.GetInstance(AIndex: Integer): TPersistent;
begin
  Result := FPropList[AIndex].Instance;
end;


function TUdPropEditor.GetInt64Value(AIndex: Integer): Int64;
begin
  with FPropList^[AIndex] do
    Result := GetInt64Prop(Instance, PropInfo);
end;


function TUdPropEditor.GetOrdValue(AIndex: Integer): Longint;
begin
  with FPropList^[AIndex] do
    Result := GetOrdProp(Instance, PropInfo);
end;


function TUdPropEditor.GetPropInfo(AIndex: Integer): PPropInfo;
begin
  Result := FPropList[AIndex].PropInfo;
end;


function TUdPropEditor.GetPropName: string;
begin
  Result := string(FPropList[0].PropInfo^.Name);
end;


function TUdPropEditor.GetPropTypeInfo: PTypeInfo;
begin
  Result := FPropList[0].PropInfo^.PropType^;
end;

function TUdPropEditor.GetIsAnyReadonly(): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FPropCount - 1 do
  begin
    if not Assigned(FPropList[I].PropInfo^.SetProc) then
    begin
      Result := True;
      Break;
    end;
  end;
end;


function TUdPropEditor.GetStrValue(AIndex: Integer): string;
begin
  with FPropList^[AIndex] do
    Result := GetStrProp(Instance, PropInfo);
end;


procedure TUdPropEditor.GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean);
begin
  // ... ...
end;


function TUdPropEditor.GetValue: string;
begin
  Result := '(Unknown)';
end;


procedure TUdPropEditor.GetValues(AValues: TStrings);
begin
  // ... ...
end;


function TUdPropEditor.GetVarValue(AIndex: Integer): Variant;
begin
  with FPropList^[AIndex] do
    Result := GetVariantProp(Instance, PropInfo);
end;


procedure TUdPropEditor.Modified;
begin
  if Assigned(FOnModified) then FOnModified(Self);
end;


procedure TUdPropEditor.SetFloatValue(Value: Extended);
var
  I: Integer;
begin
  for I := 0 to FPropCount - 1 do
    with FPropList^[I] do
      SetFloatProp(Instance, PropInfo, Value);
  Modified;
end;


procedure TUdPropEditor.SetInt64Value(Value: Int64);
var
  I: Integer;
begin
  for I := 0 to FPropCount - 1 do
    with FPropList^[I] do
      SetInt64Prop(Instance, PropInfo, Value);
  Modified;
end;


procedure TUdPropEditor.SetOrdValue(Value: Integer);
var
  I: Integer;
begin
  for I := 0 to FPropCount - 1 do
  begin
    with FPropList^[I] do
      SetOrdProp(Instance, PropInfo, Value);
  end;
  Modified;
end;


procedure TUdPropEditor.SetPropEntry(AIndex: Integer; AInstance: TPersistent;
  APropInfo: PPropInfo);
begin
  with FPropList[AIndex] do
  begin
    Instance := AInstance;
    PropInfo := APropInfo;
  end;
end;


procedure TUdPropEditor.SetStrValue(const Value: string);
var
  I: Integer;
begin
  for I := 0 to FPropCount - 1 do
    with FPropList^[I] do
      SetStrProp(Instance, PropInfo, Value);
  Modified;
end;


procedure TUdPropEditor.SetValue(const Value: string);
begin
  // ... ...
end;


procedure TUdPropEditor.SetVarValue(const Value: Variant);
var
  I: Integer;
begin
  for I := 0 to FPropCount - 1 do
    with FPropList^[I] do
      SetVariantProp(Instance, PropInfo, Value);
  Modified;
end;


procedure TUdPropEditor.ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
begin
  ACanvas.TextRect(ARect, 1 + ARect.Left, 1 + ARect.Top, AValue);
end;


procedure TUdPropEditor.ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer);
begin
  // ... ...
end;


procedure TUdPropEditor.ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer);
begin
  // ... ...
end;



{ TUdNestedPropEditor }

constructor TUdNestedPropEditor.Create(AParent: TUdPropEditor);
begin
  FParent := AParent;
  FPropList := AParent.FPropList;
  FPropCount := AParent.FPropCount;
end;


destructor TUdNestedPropEditor.Destroy;
begin
  // Do not execute inherited
end;

function TUdNestedPropEditor.GetPropName: string;
begin
  Result := 'SubProp';
end;



{ TUdOrdinalPropEditor }

function TUdOrdinalPropEditor.AllEqual: Boolean;
var
  I: Integer;
  LV: Longint;
begin
  Result := True;
  if PropCount > 1 then
  begin
    LV := GetOrdValue(0);
    for I := 1 to PropCount - 1 do
      if GetOrdValue(I) <> LV then
      begin
        Result := False;
        Break;
      end;
  end;
end;



{ TUdIntegerPropEditor }

function TUdIntegerPropEditor.GetValue: string;
begin
  with GetTypeData(PropTypeInfo)^ do
    if OrdType = otULong then // Unsigned
      Result := IntToStr(Cardinal(GetOrdValue(0)))
    else
      Result := IntToStr(GetOrdValue(0));
end;


procedure TUdIntegerPropEditor.SetValue(const Value: string);
var
  I: Int64;
begin
  I := StrToInt64(Value);
  with GetTypeData(PropTypeInfo)^ do
  begin
    if OrdType = otULong then
    begin
      // bump up to Int64 to get past the %d in the format string
      if (I < Cardinal(MinValue)) or (I > Cardinal(MaxValue)) then
        raise Exception.CreateFmt('Value must be between %d and %d', [Int64(Cardinal(MinValue)), Int64(Cardinal(MaxValue))]);
    end
    else if (I < MinValue) or (I > MaxValue) then
      raise Exception.CreateFmt('Value must be between %d and %d', [MinValue, MaxValue]);
  end;
  SetOrdValue(I);
end;



{ TUdCharPropEditor }

function TUdCharPropEditor.GetValue: string;
var
  LCh: Char;
begin
  LCh := Chr(GetOrdValue(0));
{$IF COMPILERVERSION >= 21.0 }
  if CharInSet(LCh, [#33..#127]) then
{$ELSE}
  if LCh in [#33..#127] then
{$IFEND}
    Result := LCh
  else
    FmtStr(Result, '#%d', [Ord(LCh)]);
end;


procedure TUdCharPropEditor.SetValue(const Value: string);
var
  N: Longint;
begin
  if System.Length(Value) = 0 then N := 0
  else if System.Length(Value) = 1 then N := Ord(Value[1])
  else if Value[1] = '#' then N := StrToInt(Copy(Value, 2, Maxint))
  else raise Exception.Create('Invalid property value');

  with GetTypeData(PropTypeInfo)^ do
    if (N < MinValue) or (N > MaxValue) then
      raise Exception.CreateFmt('Value must be between %d and %d', [MinValue, MaxValue]);

  SetOrdValue(N);
end;



{ TUdEnumPropEditor }

function TUdEnumPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, {praSortList,} praDropDownList];
end;

function TUdEnumPropEditor.GetValue: string;
var
  I: Longint;
begin
  I := GetOrdValue(0);
  with GetTypeData(PropTypeInfo)^ do
    if (I < MinValue) or (I > MaxValue) then I := MaxValue;
  Result := GetEnumName(PropTypeInfo, I);
end;

procedure TUdEnumPropEditor.GetValues(AValues: TStrings);
var
  I: Integer;
  LEnumType: PTypeInfo;
begin
  LEnumType := PropTypeInfo;
  with GetTypeData(LEnumType)^ do
  begin
    if MinValue < 0 then // Longbool/Wordbool/Bytebool
    begin
      AValues.Add(GetEnumName(LEnumType, 0));
      AValues.Add(GetEnumName(LEnumType, 1));
    end
    else
      for I := MinValue to MaxValue do
        AValues.Add(GetEnumName(LEnumType, I));
  end;
end;

procedure TUdEnumPropEditor.SetValue(const Value: string);
var
  I: Integer;
begin
  I := GetEnumValue(PropTypeInfo, Value);
  with GetTypeData(PropTypeInfo)^ do
    if (I < MinValue) or (I > MaxValue) then
      raise Exception.Create('Invalid property value');
  SetOrdValue(I);
end;




{ TUdFloatPropEditor }

function TUdFloatPropEditor.AllEqual: Boolean;
var
  I: Integer;
  LV: Extended;
begin
  Result := True;
  if PropCount > 1 then
  begin
    LV := GetFloatValue(0);
    for I := 1 to PropCount - 1 do
      if GetFloatValue(I) <> LV then
      begin
        Result := False;
        Break;
      end;
  end;
end;

function TUdFloatPropEditor.GetValue: string;
const
  LPrecisions: array[TFloatType] of Integer = (7, 15, 18, 18, 18);
begin
  Result := FloatToStrF(GetFloatValue(0), ffGeneral,
    LPrecisions[GetTypeData(PropTypeInfo)^.FloatType], 0);
end;

procedure TUdFloatPropEditor.SetValue(const Value: string);
begin
  SetFloatValue(StrToFloat(Value));
end;



{ TUdStringPropEditor }

function TUdStringPropEditor.AllEqual: Boolean;
var
  I: Integer;
  LV: string;
begin
  Result := True;
  if PropCount > 1 then
  begin
    LV := GetStrValue(0);
    for I := 1 to PropCount - 1 do
      if GetStrValue(I) <> LV then
      begin
        Result := False;
        Break;
      end;
  end;
end;

function TUdStringPropEditor.GetValue: string;
begin
  Result := GetStrValue(0);
end;

procedure TUdStringPropEditor.SetValue(const Value: string);
begin
  SetStrValue(Value);
end;




{ TUdSetPropEditor }

function TUdSetPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praSubProperties, praReadOnly];
end;

procedure TUdSetPropEditor.GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean);
var
  I: Integer;
begin
  with GetTypeData(GetTypeData(PropTypeInfo)^.CompType^)^ do
    for I := MinValue to MaxValue do
      AResult.Add(TUdSetElemPropEditor.Create(Self, I));
end;

function TUdSetPropEditor.GetValue: string;
var
  I: Integer;
  LS: TIntegerSet;
  LTypeInfo: PTypeInfo;
begin
  Integer(LS) := GetOrdValue(0);
  LTypeInfo := GetTypeData(PropTypeInfo)^.CompType^;
  Result := '[';
  for I := 0 to SizeOf(Integer) * 8 - 1 do
    if I in LS then
    begin
      if System.Length(Result) <> 1 then Result := Result + ',';
      Result := Result + GetEnumName(LTypeInfo, I);
    end;
  Result := Result + ']';
end;




{ TUdSetElemPropEditor }

function TUdSetElemPropEditor.AllEqual: Boolean;
var
  I: Integer;
  LV: Boolean;
  LS: TIntegerSet;
begin
  Result := True;
  if PropCount > 1 then
  begin
    Integer(LS) := GetOrdValue(0);
    LV := FElement in LS;
    for I := 1 to PropCount - 1 do
    begin
      Integer(LS) := GetOrdValue(I);
      if (FElement in LS) <> LV then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;

constructor TUdSetElemPropEditor.Create(AParent: TUdPropEditor; AElement: Integer);
begin
  inherited Create(AParent);
  FElement := AElement;
end;

function TUdSetElemPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

function TUdSetElemPropEditor.GetPropName: string;
begin
  Result := GetEnumName(GetTypeData(Parent.PropTypeInfo)^.CompType^, FElement);
end;

function TUdSetElemPropEditor.GetPropTypeInfo: PTypeInfo;
begin
  Result := TypeInfo(Boolean);
end;

function TUdSetElemPropEditor.GetValue: string;
var
  LS: TIntegerSet;
begin
  Integer(LS) := GetOrdValue(0);
  Result := BooleanIdents[FElement in LS];
end;

procedure TUdSetElemPropEditor.GetValues(AValues: TStrings);
begin
  AValues.Add(BooleanIdents[False]);
  AValues.Add(BooleanIdents[True]);
end;

procedure TUdSetElemPropEditor.SetValue(const Value: string);
var
  LS: TIntegerSet;
begin
  Integer(LS) := GetOrdValue(0);
  if CompareText(Value, BooleanIdents[True]) = 0 then
    Include(LS, FElement)
  else
    Exclude(LS, FElement);
  SetOrdValue(Integer(LS));
end;




{ TUdClassPropEditor }

function TUdClassPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praSubProperties, praReadOnly];
end;

procedure TUdClassPropEditor.GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean);
var
  I, J: Integer;
  LObjects: TList;
begin
  LObjects := TList.Create;
  try
    for I := 0 to PropCount - 1 do
    begin
      J := GetOrdValue(I);
      if J <> 0 then
        LObjects.Add(TObject(J));
    end;
    if LObjects.Count > 0 then
      UdGetObjectsProps(Designer, LObjects, tkAny, False, AGetEditorClassProc, AResult, SortList);
  finally
    LObjects.Free;
  end;
end;

function TUdClassPropEditor.GetValue: string;
begin
  FmtStr(Result, '(%s)', [PropTypeInfo^.Name]);

//  Result := string(PropTypeInfo^.Name);
//  if Pos('TUd', Result) = 1 then Delete(Result, 1, 3) else
//  if Pos('T', Result)   = 1 then Delete(Result, 1, 1) ;
//
//  FmtStr(Result, '(%s)', [Result]);
end;




{ TUdInt64PropEditor }

function TUdInt64PropEditor.AllEqual: Boolean;
var
  I: Integer;
  LV: Int64;
begin
  Result := True;
  if PropCount > 1 then
  begin
    LV := GetInt64Value(0);
    for I := 1 to PropCount - 1 do
      if GetInt64Value(I) <> LV then
      begin
        Result := False;
        Break;
      end;
  end;
end;

function TUdInt64PropEditor.GetValue: string;
begin
  Result := IntToStr(GetInt64Value(0));
end;

procedure TUdInt64PropEditor.SetValue(const Value: string);
begin
  SetInt64Value(StrToInt64(Value));
end;



{ TUdVariantPropEditor }

function TUdVariantPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praSubProperties];
end;

procedure TUdVariantPropEditor.GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean);
begin
  AResult.Add(TUdVariantTypePropEditor.Create(Self));
end;

function TUdVariantPropEditor.GetValue: string;

  function _GetVariantStr(const AValue: Variant): string;
  begin
    case VarType(AValue) of
      varBoolean : Result := BooleanIdents[AValue = True];
      varCurrency: Result := CurrToStr(AValue);
    else
      if TVarData(AValue).VType <> varNull then
        Result := AValue
      else
        Result := SNull;
    end;
  end;

var
  LValue: Variant;
begin
  LValue := GetVarValue(0);
  if VarType(LValue) <> varDispatch then
    Result := _GetVariantStr(LValue)
  else
    Result := '(ERROR)';
end;


procedure TUdVariantPropEditor.SetValue(const Value: string);

  function _Cast(var AValue: Variant; ANewType: Integer): Boolean;
  var
    LV2: Variant;
  begin
    Result := True;
    if ANewType = varCurrency then
    begin
    {$IF COMPILERVERSION >= 22.0 }
      Result := AnsiPos(FormatSettings.CurrencyString, AValue) > 0;
    {$ELSE}
      Result := AnsiPos(CurrencyString, AValue) > 0;
    {$IFEND}
    end;

    if Result then
    try
      VarCast(LV2, AValue, ANewType);
      Result := (ANewType = varDate) or (VarToStr(LV2) = VarToStr(AValue));
      if Result then AValue := LV2;
    except
      Result := False;
    end;
  end;

var
  LV: Variant;
  LOldType: Integer;
begin
  LOldType := VarType(GetVarValue(0));
  LV := Value;
  if Value = '' then VarClear(LV)
  else if (CompareText(Value, SNull) = 0) then LV := NULL
  else if not _Cast(LV, LOldType) then LV := Value;

  SetVarValue(LV);
end;



{ TUdVariantTypePropEditor }

function TUdVariantTypePropEditor.AllEqual: Boolean;
var
  I: Integer;
  LV1, LV2: Variant;
begin
  Result := True;
  if PropCount > 1 then
  begin
    LV1 := GetVarValue(0);
    for I := 1 to PropCount - 1 do
    begin
      LV2 := GetVarValue(I);
      if VarType(LV1) <> VarType(LV2) then
      begin
        Result := False;
        Break;
      end;
    end;
  end;
end;


function TUdVariantTypePropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

function TUdVariantTypePropEditor.GetPropName: string;
begin
  Result := 'Type';
end;

function TUdVariantTypePropEditor.GetValue: string;
begin
  case VarType(GetVarValue(0)) and varTypeMask of
    Low(VarTypeNames)..High(VarTypeNames):  Result := VarTypeNames[VarType(GetVarValue(0))];
    varString:  Result := SString;
  else
    Result := SUnknown;
  end;
end;

procedure TUdVariantTypePropEditor.GetValues(AValues: TStrings);
var
  I: Integer;
begin
  for I := 0 to High(VarTypeNames) do
    if VarTypeNames[I] <> '' then
      AValues.Add(VarTypeNames[I]);
  AValues.Add(SString);
end;

procedure TUdVariantTypePropEditor.SetValue(const Value: string);

  function _GetSelectedType: Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to High(VarTypeNames) do
      if VarTypeNames[I] = Value then
      begin
        Result := I;
        Break;
      end;
    if (Result = -1) and (Value = SString) then
      Result := varString;
  end;

var
  LV: Variant;
  LNewType: Integer;
begin
  LV := GetVarValue(0);
  LNewType := _GetSelectedType;
  case LNewType of
    varEmpty: VarClear(LV);
    varNull : LV := NULL;
    -1: raise Exception.Create(SUnknownType);
  else
    try
      VarCast(LV, LV, LNewType);
    except
      { If it cannot cast, clear it and then cast again. }
      VarClear(LV);
      VarCast(LV, LV, LNewType);
    end;
  end;
  SetVarValue(LV);
end;



{ TUdComponentNamePropEditor }

function TUdComponentNamePropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praNotNestable];
end;



{ TUdDateTimePropEditor }

function TUdDateTimePropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect];
end;

function TUdDateTimePropEditor.GetValue: string;
var
  LDt: TDateTime;
begin
  LDt := GetFloatValue(0);
  if LDt = 0.0 then
    Result := ''
  else
    Result := DateTimeToStr(LDt);
end;

procedure TUdDateTimePropEditor.SetValue(const Value: string);
var
  LDt: TDateTime;
begin
  if Value = '' then
    LDt := 0.0
  else
    LDt := StrToDateTime(Value);
  SetFloatValue(LDt);
end;



{ TUdDatePropEditor }

function TUdDatePropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect];
end;

function TUdDatePropEditor.GetValue: string;
var
  LDt: TDateTime;
begin
  LDt := GetFloatValue(0);
  if LDt = 0.0 then
    Result := ''
  else
    Result := DateToStr(LDt);
end;

procedure TUdDatePropEditor.SetValue(const Value: string);
var
  LDt: TDateTime;
begin
  if Value = '' then
    LDt := 0.0
  else
    LDt := StrToDate(Value);
  SetFloatValue(LDt);
end;



{ TUdTimePropEditor }

function TUdTimePropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect];
end;

function TUdTimePropEditor.GetValue: string;
var
  LDt: TDateTime;
begin
  LDt := GetFloatValue(0);
  if LDt = 0.0 then
    Result := ''
  else
    Result := TimeToStr(LDt);
end;

procedure TUdTimePropEditor.SetValue(const Value: string);
var
  LDt: TDateTime;
begin
  if Value = '' then
    LDt := 0.0
  else
    LDt := StrToTime(Value);
  SetFloatValue(LDt);
end;



{ TUdCaptionPropEditor }

function TUdCaptionPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praAutoUpdate];
end;



{ TUdColorPropEditor }

procedure TUdColorPropEditor.AddValue(const LS: string);
begin
  FValues.Add(LS);
end;

procedure TUdColorPropEditor.Edit;
var
  LColorDialog: TColorDialog;
begin
  LColorDialog := TColorDialog.Create(Application);
  try
    LColorDialog.Color := GetOrdValue(0);
    LColorDialog.Options := [];
    if LColorDialog.Execute then SetOrdValue(LColorDialog.Color);
  finally
    LColorDialog.Free;
  end;
end;

function TUdColorPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praDialog, praValueList, praOwnerDrawValues];
end;

function TUdColorPropEditor.GetValue: string;
begin
  Result := ColorToString(TColor(GetOrdValue(0)));
end;

procedure TUdColorPropEditor.GetValues(AValues: TStrings);
begin
  FValues := AValues;
  GetColorValues(AddValue);
end;

procedure TUdColorPropEditor.SetValue(const Value: string);
var
  N: Integer;
  LNewValue: Longint;
  ColorValue: string;
begin
  N := AnsiPos('=', Value);
  if N <> 0 then //AValue 格式为 DispName=ColorName
    ColorValue := Copy(Value, N + 1, MaxInt)
  else
    ColorValue := Value;

  if IdentToColor(ColorValue, LNewValue) then
    SetOrdValue(LNewValue)
  else
    inherited SetValue(ColorValue);
end;

procedure TUdColorPropEditor.ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  N: Integer;
  LRight: Integer;
  LOldPenColor, LOldBrushColor: TColor;
  LColorValue, LDispValue: string;
begin
  LRight := (ARect.Bottom - ARect.Top) + ARect.Left;
  with ACanvas do
  begin
    LOldPenColor := Pen.Color;
    LOldBrushColor := Brush.Color;

    Pen.Color := Brush.Color;
    Rectangle(ARect.Left, ARect.Top, LRight, ARect.Bottom);

    N := AnsiPos('=', AValue);
    if N <> 0 then //AValue 格式为 DispName=ColorName
    begin
      LDispValue := Copy(AValue, 1, N - 1);
      LColorValue := Copy(AValue, N + 1, MaxInt);
    end
    else
    begin //AValue 格式为 ColorName
      LDispValue := AValue;
      LColorValue := AValue;
    end;

    Brush.Color := StringToColor(LColorValue);
    Pen.Color   := FColorToBorderColor(ColorToRGB(Brush.Color), ASelected);
    Rectangle(ARect.Left + 1, ARect.Top + 1, LRight - 1, ARect.Bottom - 1);

    Brush.Color := LOldBrushColor;
    Pen.Color := LOldPenColor;
    ACanvas.TextRect(
      Rect(LRight, ARect.Top, ARect.Right, ARect.Bottom),
      LRight + 1,
      ARect.Top + 1,
      LDispValue
      );
  end;
end;


procedure TUdColorPropEditor.ValuesMeasureHeight(const AValue: string;ACanvas: TCanvas; var AHeight: Integer);
begin
  AHeight := ACanvas.TextHeight('Ud') + 2;
end;

procedure TUdColorPropEditor.ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + ACanvas.TextHeight('Ud');
end;



{ TUdCursorPropEditor }

procedure TUdCursorPropEditor.AddValue(const LS: string);
begin
  FValues.Add(LS);
end;

function TUdCursorPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList, praOwnerDrawValues];
end;

function TUdCursorPropEditor.GetValue: string;
begin
  Result := CursorToString(TCursor(GetOrdValue(0)));
end;

procedure TUdCursorPropEditor.GetValues(AValues: TStrings);
begin
  FValues := AValues;
  GetCursorValues(AddValue);
end;

procedure TUdCursorPropEditor.SetValue(const Value: string);
var
  LNewValue: Longint;
begin
  if IdentToCursor(Value, LNewValue) then
    SetOrdValue(LNewValue)
  else
    inherited SetValue(Value);
end;

procedure TUdCursorPropEditor.ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  LRight: Integer;
  LCursorIndex: Integer;
  LCursorHandle: THandle;
begin
  LRight := ARect.Left + GetSystemMetrics(SM_CXCURSOR) + 4;
  with ACanvas do
  begin
    if not IdentToCursor(AValue, LCursorIndex) then
      LCursorIndex := StrToInt(AValue);
    ACanvas.FillRect(ARect);
    LCursorHandle := Screen.Cursors[LCursorIndex];
    if LCursorHandle <> 0 then
      DrawIconEx(ACanvas.Handle, ARect.Left + 2, ARect.Top + 2, LCursorHandle,
        0, 0, 0, 0, DI_NORMAL or DI_DEFAULTSIZE);
    ACanvas.TextRect(
      Rect(LRight, ARect.Top, ARect.Right, ARect.Bottom),
      LRight + 1,
      ARect.Top + 1,
      AValue
      );
  end;
end;


procedure TUdCursorPropEditor.ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer);
var
  LTextHeight, LCursorHeight: Integer;
begin
  LTextHeight := ACanvas.TextHeight('Ud');
  LCursorHeight := GetSystemMetrics(SM_CYCURSOR) + 4;
  if LTextHeight >= LCursorHeight then
    AHeight := LTextHeight
  else
    AHeight := LCursorHeight;
end;

procedure TUdCursorPropEditor.ValuesMeasureWidth(const AValue: string;
  ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + GetSystemMetrics(SM_CXCURSOR) + 4;
end;



{ TUdFontCharsetPropEditor }

procedure TUdFontCharsetPropEditor.AddValue(const LS: string);
begin
  FValues.Add(LS);
end;

function TUdFontCharsetPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praSortList, praValueList];
end;

function TUdFontCharsetPropEditor.GetValue: string;
begin
  if not CharsetToIdent(TFontCharset(GetOrdValue(0)), Result) then
    FmtStr(Result, '%d', [GetOrdValue(0)]);
end;

procedure TUdFontCharsetPropEditor.GetValues(AValues: TStrings);
begin
  FValues := AValues;
  GetCharsetValues(AddValue);
end;

procedure TUdFontCharsetPropEditor.SetValue(const Value: string);
var
  LNewValue: Longint;
begin
  if IdentToCharset(Value, LNewValue) then
    SetOrdValue(LNewValue)
  else
    inherited SetValue(Value);
end;



{ TUdFontNamePropEditor }

function TUdFontNamePropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList, praSortList];
end;

procedure TUdFontNamePropEditor.GetValues(AValues: TStrings);
var
  I: Integer;
begin
  for I := 0 to Screen.Fonts.Count - 1 do
    AValues.Add(Screen.Fonts[I]);
end;


{ TUdImeNamePropEditor }

function TUdImeNamePropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praValueList, praSortList, praMultiSelect];
end;

procedure TUdImeNamePropEditor.GetValues(AValues: TStrings);
var
  I: Integer;
begin
  for I := 0 to Screen.Imes.Count - 1 do
    AValues.Add(Screen.Imes[I]);
end;


{ TUdFontPropEditor }

procedure TUdFontPropEditor.Edit;
var
  LFontDialog: TFontDialog;
begin
  LFontDialog := TFontDialog.Create(Application);
  try
    LFontDialog.Font := TFont(GetOrdValue(0));
    LFontDialog.Options := LFontDialog.Options + [fdForceFontExist];
    if LFontDialog.Execute then
      SetOrdValue(Longint(LFontDialog.Font));
  finally
    LFontDialog.Free;
  end;
end;

function TUdFontPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praSubProperties, praDialog, praReadOnly];
end;


{ TUdModalResultPropEditor }

function TUdModalResultPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList];
end;

function TUdModalResultPropEditor.GetValue: string;
var
  LCurValue: Longint;
begin
  LCurValue := GetOrdValue(0);
  case LCurValue of
    Low(ModalResults)..High(ModalResults):
      Result := ModalResults[LCurValue];
  else
    Result := IntToStr(LCurValue);
  end;
end;

procedure TUdModalResultPropEditor.GetValues(AValues: TStrings);
var
  I: Integer;
begin
  for I := Low(ModalResults) to High(ModalResults) do
    AValues.Add(ModalResults[I]);
end;

procedure TUdModalResultPropEditor.SetValue(const Value: string);
var
  I: Integer;
begin
  if Value = '' then
  begin
    SetOrdValue(0);
    Exit;
  end;
  for I := Low(ModalResults) to High(ModalResults) do
    if CompareText(ModalResults[I], Value) = 0 then
    begin
      SetOrdValue(I);
      Exit;
    end;
  inherited SetValue(Value);
end;


{ TUdPenStylePropEditor }

function TUdPenStylePropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := inherited GetAttrs + [praOwnerDrawValues];
end;

procedure TUdPenStylePropEditor.ValuesDrawValue(const AValue: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  LRight, LTop: Integer;
  LOldPenColor, LOldBrushColor: TColor;
  LOldPenStyle: TPenStyle;
begin
  LRight := (ARect.Bottom - ARect.Top) * 3 + ARect.Left;
  LTop  := (ARect.Bottom - ARect.Top) div 2 + ARect.Top;

  with ACanvas do
  begin
    LOldPenColor := Pen.Color;
    LOldBrushColor := Brush.Color;
    LOldPenStyle := Pen.Style;

    Pen.Color := Brush.Color;
    Rectangle(ARect.Left, ARect.Top, LRight, ARect.Bottom);

    Pen.Color := clGrayText;
    Brush.Color := clWindow;
    Rectangle(ARect.Left + 1, ARect.Top + 1, LRight - 1, ARect.Bottom - 1);

    Pen.Color := clWindowText;
    Pen.Style := TPenStyle(GetEnumValue(PropTypeInfo, AValue));
    MoveTo(ARect.Left + 1, LTop);
    LineTo(LRight - 1, LTop);
    MoveTo(ARect.Left + 1, LTop + 1);
    LineTo(LRight - 1, LTop + 1);

    Brush.Color := LOldBrushColor;
    Pen.Style := LOldPenStyle;
    Pen.Color := LOldPenColor;
    ACanvas.TextRect(
      Rect(LRight, ARect.Top, ARect.Right, ARect.Bottom),
      LRight + 5,
      ARect.Top + 1,
      AValue
      );
  end;
end;

procedure TUdPenStylePropEditor.ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer);
begin
  AHeight := ACanvas.TextHeight('Ud') + 2;
end;

procedure TUdPenStylePropEditor.ValuesMeasureWidth(const AValue: string;
  ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + ACanvas.TextHeight('Ud') * 2;
end;


{ TUdBrushStylePropEditor }

function TUdBrushStylePropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := inherited GetAttrs + [praOwnerDrawValues];
end;

procedure TUdBrushStylePropEditor.ValuesDrawValue(const AValue: string;
  ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  LRight: Integer;
  LOldPenColor, LOldBrushColor: TColor;
  LOldBrushStyle: TBrushStyle;
begin
//  LRight := (ARect.Bottom - ARect.Top) + ARect.Left;
  LRight := (ARect.Bottom - ARect.Top) * 3 + ARect.Left;
  with ACanvas do
  begin
    LOldPenColor := Pen.Color;
    LOldBrushColor := Brush.Color;
    LOldBrushStyle := Brush.Style;

    Pen.Color := Brush.Color;
    Brush.Color := clWindow;
    Rectangle(ARect.Left, ARect.Top, LRight, ARect.Bottom);

    Pen.Color := clWindowText;
    Brush.Style := TBrushStyle(GetEnumValue(PropTypeInfo, AValue));
    if Brush.Style = bsClear then
    begin
      Brush.Color := clWindow;
      Brush.Style := bsSolid;
    end
    else
      Brush.Color := clWindowText;
    Rectangle(ARect.Left + 1, ARect.Top + 1, LRight - 1, ARect.Bottom - 1);

    Brush.Color := LOldBrushColor;
    Brush.Style := LOldBrushStyle;
    Pen.Color := LOldPenColor;
    ACanvas.TextRect(
      Rect(LRight, ARect.Top, ARect.Right, ARect.Bottom),
      LRight + 5,
      ARect.Top + 1,
      AValue
      );
  end;
end;

procedure TUdBrushStylePropEditor.ValuesMeasureHeight(const AValue: string; ACanvas: TCanvas; var AHeight: Integer);
begin
  AHeight := ACanvas.TextHeight('Ud') + 2;
end;

procedure TUdBrushStylePropEditor.ValuesMeasureWidth(const AValue: string; ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + ACanvas.TextHeight('Ud') * 2;
end;



{ TUdTabOrderPropEditor }

function TUdTabOrderPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [];
end;



{ TUdShortCutPropEditor }

function TUdShortCutPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praValueList];
end;

function TUdShortCutPropEditor.GetValue: string;
var
  LCurValue: TShortCut;
begin
  LCurValue := GetOrdValue(0);
  if LCurValue = scNone then
    Result := srNone
  else
    Result := ShortCutToText(LCurValue);
end;

procedure TUdShortCutPropEditor.GetValues(AValues: TStrings);
var
  I: Integer;
begin
  AValues.Add(srNone);
  for I := 1 to High(ShortCuts) do
    AValues.Add(ShortCutToText(ShortCuts[I]));
end;

procedure TUdShortCutPropEditor.SetValue(const Value: string);
var
  LNewValue: TShortCut;
begin
  LNewValue := 0;
  if (Value <> '') and (AnsiCompareText(Value, srNone) <> 0) then
  begin
    LNewValue := TextToShortCut(Value);
    if LNewValue = 0 then
      raise Exception.Create('Invalid property value');
  end;
  SetOrdValue(LNewValue);
end;



{ TUdComponentPropEditor }

function TUdComponentPropEditor.AllEqual: Boolean;
var
  I: Integer;
  LInstance: TComponent;
begin
  Result := True;
  LInstance := TComponent(GetOrdValue(0));
  if PropCount > 1 then
    for I := 1 to PropCount - 1 do
      if TComponent(GetOrdValue(I)) <> LInstance then
      begin
        Result := False;
        Break;
      end;
end;

function TUdComponentPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praComponentRef];
  if Assigned(GetPropInfo(0).SetProc) then
    Result := Result + [praValueList, praSortList]
  else
    Result := Result + [praReadOnly];
  if (TComponent(GetOrdValue(0)) <> nil) and AllEqual then
    Result := Result + [praSubProperties, praVolatileSubProperties];
end;

procedure TUdComponentPropEditor.GetSubProps(AGetEditorClassProc: TUdPropGetEditorClassProc; AResult: TList; SortList: Boolean);
var
  I: Integer;
  J: Integer;
  LObjects: TList;
begin
  LObjects := TList.Create;
  try
    for I := 0 to PropCount - 1 do
    begin
      J := GetOrdValue(I);
      if J <> 0 then
        LObjects.Add(TObject(J));
    end;
    if LObjects.Count > 0 then
      UdGetObjectsProps(Designer, LObjects, tkAny, True, AGetEditorClassProc, AResult, SortList);
  finally
    LObjects.Free;
  end;
end;

function TUdComponentPropEditor.GetValue: string;
var
  LComponent: TComponent;
begin
  LComponent := TComponent(GetOrdValue(0));
  if LComponent <> nil then
    Result := GetComponentName(LComponent)
  else
    Result := '';
end;

procedure TUdComponentPropEditor.GetValues(AValues: TStrings);
begin
  GetComponentNames(TComponentClass(GetTypeData(PropTypeInfo)^.ClassType), AValues);
end;

procedure TUdComponentPropEditor.SetValue(const Value: string);
var
  LComponent: TComponent;
begin
  LComponent := nil;
  if Value <> '' then
  begin
    LComponent := GetComponent(Value);
    if not (LComponent is GetTypeData(PropTypeInfo)^.ClassType) then
      raise EPropertyError.Create('Invalid property value');
  end;
  SetOrdValue(LongInt(LComponent));
end;



{ TUdStringsPropEditor }

procedure TUdStringsPropEditor.Edit;
var
  LStringsEditorDlg: TUdStringsEditorDlg;
begin
  LStringsEditorDlg := TUdStringsEditorDlg.Create(Application);
  try
    LStringsEditorDlg.Lines := TStrings(GetOrdValue(0));
    if LStringsEditorDlg.Execute then SetOrdValue(Longint(LStringsEditorDlg.Lines));
  finally
    LStringsEditorDlg.Free;
  end;
end;

function TUdStringsPropEditor.GetAttrs: TUdPropAttrs;
begin
  Result := [praMultiSelect, praDialog, praReadOnly];
end;




end.