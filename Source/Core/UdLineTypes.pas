{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLineTypes;

{$I UdDefs.INC}
{$DEFINE ADD_LTS}

interface

uses
  Windows, Classes,
  UdConsts, UdTypes, UdIntfs, UdObject, UdLinetype;


type
  //*** TUdLineTypes ***//
  TUdLineTypes = class(TUdObject, IUdObjectCollection , IUdActiveSupport)
  private
    FList: TList;
    FStdLns: TList;

    FActive: TUdLineType;

    FByLayer: TUdLineType;
    FByBlock: TUdLineType;
    FContinuous: TUdLineType;

    FGlobalScale: Float;
    FCurrentScale: Float;

    FOnAdd: TUdLineTypeEvent;
    FOnSelect: TUdLineTypeEvent;
    FOnRemove: TUdLineTypeAllowEvent;


  protected
    function GetTypeID: Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    function LoadStdLines(): Boolean;
    function GetCount: Integer;

    function GetLineType(AIndex: Integer): TUdLineType;
    procedure SetLineType(AIndex: Integer; const AValue: TUdLineType);

    procedure SetActive_(const AValue: TUdLineType);

    procedure SetGlobalScale(const AValue: Float);
    procedure SetCurrentScale(const AValue: Float);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    procedure Clear(All: Boolean = False);

    function IndexOf(AName: string): Integer; overload;
    function IndexOf(const AValue: TSingleArray): Integer; overload;
    function IndexOf(AObject: TUdLineType): Integer; overload;

    function Add(AName: string): Boolean; overload;
    function Add(AObject: TUdLineType): Boolean; overload;
    function Add(AName, AComment: string; AValue: TSingleArray): Boolean; overload;

    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AName: string): Boolean; overload;
    function Remove(const AValue: TSingleArray): Boolean; overload;
    function Remove(AObject: TUdLineType): Boolean; overload;

    function GetItem(AName: string): TUdLineType; overload;
    function GetItem(AIndex: Integer): TUdLineType; overload;
    function GetItem(const AValue: TSingleArray): TUdLineType; overload;

    function SetActive(AName: string): Boolean; overload;
    function SetActive(AIndex: Integer): Boolean; overload;
    function SetActive(const AValue: TSingleArray): Boolean; overload;
    function SetActive(AObject: TUdLineType): Boolean; overload;

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


    function GetStdLineType(AName: string): TUdLineType;


  public
    property Items[Index: Integer]: TUdLineType read GetLineType write SetLineType;

  published
    property Active: TUdLineType read FActive write SetActive_;

    property ByLayer: TUdLineType read FByLayer;// write FByLayer;
    property ByBlock: TUdLineType read FByBlock;// write FByBlock;
    property Continuous: TUdLineType read FContinuous;// write FContinuous;

    property Count: Integer read GetCount;

    property GlobalScale : Float read FGlobalScale write SetGlobalScale;   //Global scale factor
    property CurrentScale: Float read FCurrentScale write SetCurrentScale; //Current object scale

    property OnAdd: TUdLineTypeEvent read FOnAdd write FOnAdd;
    property OnSelect: TUdLineTypeEvent read FOnSelect write FOnSelect;
    property OnRemove: TUdLineTypeAllowEvent read FOnRemove write FOnRemove;

  end;



function ParseLinFile(ADoc: TUdObject; ALinFile: string; var ALinList: TList): Boolean;

  
implementation

uses
  SysUtils,
  UdDocument, UdMath, UdUtils, UdStreams, UdXml;

const
  STD_LIN_FILE = 'acadiso.lin';



//==================================================================================================

function ParseLinList(ADoc: TUdObject; AStrList: TStringList; var ALinList: TList): Boolean;

  function _LinStrToValue(Value: string): TSingleArray;
  var
    I: Integer;
    S: string;
  begin
    System.SetLength(Result, 0);

    I := Pos(',', Value);
    while I > 0 do
    begin
      S := Trim(Copy(Value, 1, I - 1));
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := StrToFloat(S);

      Delete(Value, 1, I);
      I := Pos(',', Value);
    end;
    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := StrToFloat(Value);
  end;

  function _IsLinStr(Value: string): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to System.Length(Value) - 1 do
    begin
    {$IFDEF D2010UP}
      if not SysUtils.CharInSet(Value[I], ['0'..'9', #0, ' ', '.', ',', '-']) then
    {$ELSE}
      if not (Value[I] in ['0'..'9', #0, ' ', '.', ',', '-']) then
    {$ENDIF}
      begin
        Result := False;
        Break;
      end;
    end;
  end;

var
  I, N: Integer;
  LLnValue: TSingleArray;
  LName, LValue: string;
  LLineType: TUdLineType;
begin
  N := 0;
  while N < AStrList.Count do
  begin
    LName := Trim(AStrList[N]);

    if Pos('*', LName) = 1 then
    begin
      if (N + 1) < AStrList.Count then
      begin
        LValue := Trim(AStrList[N+1]);
        if Pos('A,', LValue) = 1 then
        begin
          Delete(LValue, 1, 2);
          if _IsLinStr(LValue) then
          begin
            LLnValue := _LinStrToValue(LValue);
            if System.Length(LLnValue) > 0 then
            begin
              N := N + 1;

              LLineType := TUdLineType.Create(ADoc);

              I := Pos(',', LName);
              LLineType.Name := Copy(LName, 2, I - 2);

              Delete(LName, 1, I);
              LLineType.Comment := LName;

              LLineType.Value := LLnValue;

              ALinList.Add(LLineType);
            end;
          end;
        end;
      end;
    end;
    N := N + 1;
  end;
  Result := ALinList.Count > 0;
end;

function ParseLinFile(ADoc: TUdObject; ALinFile: string; var ALinList: TList): Boolean;
var
  LStrList: TStringList;
begin
  Result := False;
  if not SysUtils.FileExists(ALinFile) or not Assigned(ALinList) then Exit;

  LStrList := TStringList.Create;
  try
    LStrList.LoadFromFile(ALinFile);
    Result := ParseLinList(ADoc, LStrList, ALinList);
  finally
    LStrList.Free;
  end;
end;



//==================================================================================================
{ TUdLineTypes }

constructor TUdLineTypes.Create();
var
  I: Integer;
  LLineType: TUdLineType;
begin
  inherited;

  FGlobalScale  := 1.0;
  FCurrentScale := 1.0;

  FByLayer := TUdLineType.Create();
  FByLayer.ByKind := bkByLayer;
  FByLayer.Name := sByLayer;
  FByLayer.Owner := Self;

  FByBlock := TUdLineType.Create();
  FByBlock.ByKind := bkByBlock;
  FByBlock.Name := sByBlock;
  FByBlock.Owner := Self;

  FContinuous := TUdLineType.Create();
  FContinuous.Name := sContinuous;
  FContinuous.Owner := Self;

  FActive := FByLayer;


  FList := TList.Create();

  FList.Add(FByLayer);
  FList.Add(FByBlock);
  FList.Add(FContinuous);

  FStdLns := TList.Create();
  LoadStdLines();

{$IFDEF ADD_LTS}
  for I := 0 to Min(FStdLns.Count, 4) - 1 do
  begin
    LLineType := TUdLineType.Create();
    LLineType.Assign(FStdLns[I]);
    LLineType.Owner := Self;
    
    FList.Add(LLineType);
  end;
{$ENDIF}
end;

destructor TUdLineTypes.Destroy;
begin
  Self.Clear(True);

  if Assigned(FList) then FList.Free;
  FList := nil;

  FByLayer := nil;
  FByBlock := nil;
  FContinuous := nil;

  UdUtils.ClearObjectList(FStdLns);
  if Assigned(FStdLns) then FStdLns.Free;
  FStdLns := nil;

  inherited;
end;


function TUdLineTypes.GetTypeID: Integer;
begin
  Result := ID_LINETYPES;
end;

procedure TUdLineTypes.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
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




function TUdLineTypes.GetLineType(AIndex: Integer): TUdLineType;
begin
  Result := Self.GetItem(AIndex);
end;

procedure TUdLineTypes.SetLineType(AIndex: Integer; const AValue: TUdLineType);
var
  LLineType: TUdLineType;
begin
  LLineType := Self.GetItem(AIndex);

  if Assigned(LLineType) and Assigned(AValue) and (LLineType <> AValue) then
  begin
    LLineType.Assign(AValue);

    case AIndex  of
      0: LLineType.ByKind := bkByLayer;
      1: LLineType.ByKind := bkByBlock;
    end;
  end;
end;




function TUdLineTypes.LoadStdLines(): Boolean;
var
  LCurrPath: string;
  LIsoLnFile: string;
  LAppFileName: array[0..255] of Char;
begin
  GetModuleFileName(0, LAppFileName, 255);
  LCurrPath := SysUtils.ExtractFilePath(LAppFileName);

  LIsoLnFile := LCurrPath + STD_LIN_FILE;

  if not SysUtils.FileExists(LIsoLnFile) then
    LIsoLnFile := LCurrPath + 'Data\' + STD_LIN_FILE;

  Result := ParseLinFile(Self.Document, LIsoLnFile, FStdLns);
end;


procedure TUdLineTypes.Clear(All: Boolean = False);
var
  I, N: Integer;
begin
  FActive := nil;

  if All then N := 0 else N := 3;
  for I := FList.Count - 1 downto N do
  begin
    Self.RemoveDocObject(TUdObject(FList[I]), False);
    FList.Delete(I);
  end;

  if All then
  begin
    FByLayer := nil;
    FByBlock := nil;
    FContinuous := nil;
  end
  else
    FActive := FByLayer;

  Self.RaiseChanged();    
end;




//----------------------------------------------------------

procedure TUdLineTypes.CopyFrom(AValue: TUdObject);
var
  I, N: Integer;
  LSrcItem, LDstItem: TUdLineType;
begin
  inherited;

  if not AValue.InheritsFrom(TUdLineTypes) then Exit; //======>>>

  FGlobalScale  := TUdLineTypes(AValue).FGlobalScale ;
  FCurrentScale := TUdLineTypes(AValue).FCurrentScale;

  if (TUdLineTypes(AValue).FList.Count > 0) then
  begin
    Self.Clear(True);

    for I := 0 to TUdLineTypes(AValue).FList.Count - 1 do
    begin
      LSrcItem := TUdLineType(TUdLineTypes(AValue).FList[I]);
      if not Assigned(LSrcItem) then Continue;

      LDstItem := TUdLineType.Create();
      LDstItem.Assign(LSrcItem);
      
      LDstItem.Owner := Self;
      LDstItem.SetDocument(Self.Document, Self.IsDocRegister);
          
      FList.Add(LDstItem);
      Self.AddDocObject(LDstItem, False);
    end;


    if FList.Count > 0 then FByLayer := FList.Items[0];
    if FList.Count > 1 then FByBlock := FList.Items[1];
    if FList.Count > 2 then FContinuous := FList.Items[2];

    N := TUdLineTypes(AValue).IndexOf(TUdLineTypes(AValue).Active);
    if N >= 0 then
      FActive := GetItem(N)
    else
      FActive := FByLayer;
  end;
end;

function TUdLineTypes.GetCount: Integer;
begin
  Result := FList.Count;
end;






//----------------------------------------------------------

function TUdLineTypes.IndexOf(AName: string): Integer;
var
  I: Integer;
  LName: string;
  LLntype: TUdLineType;
begin
  Result := -1;

  LName := LowerCase(Trim(AName));

  for I := FList.Count - 1 downto 0 do
  begin
    LLntype := TUdLineType(FList[I]);

    if LowerCase(Trim(LLntype.Name)) = LName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TUdLineTypes.IndexOf(const AValue: TSingleArray): Integer;
var
  I: Integer;
  LLntype: TUdLineType;
begin
  Result := -1;

  for I := FList.Count - 1 downto 0 do
  begin
    LLntype := TUdLineType(FList[I]);

    if IsEqual(LLntype.Value, AValue) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TUdLineTypes.IndexOf(AObject: TUdLineType): Integer;
begin
  Result := FList.IndexOf(AObject);
end;




//----------------------------------------------------------

function TUdLineTypes.Add(AName: string): Boolean;
var
  I: Integer;
  LName: string;
  LLntype: TUdLineType;
  LLineType: TUdLineType;
begin
  Result := False;
  if not Assigned(FStdLns) or (FStdLns.Count <= 0) or (Self.IndexOf(AName) >= 0) then Exit;

  LName := LowerCase(Trim(AName));

  for I := 0 to FStdLns.Count - 1 do
  begin
    LLntype := TUdLineType(FStdLns.Items[I]);

    if LowerCase(Trim(LLntype.Name)) = LName then
    begin
      LLineType := TUdLineType.Create();
      LLineType.Assign(LLntype);
      LLineType.Owner := Self;
      LLineType.SetDocument(Self.Document, Self.IsDocRegister);
      
      FList.Add(LLineType);
      if Assigned(FOnAdd) then FOnAdd(Self, LLineType);

      Self.AddDocObject(LLineType);
      Result := True;

      Break; //----->>>>
    end;
  end;
end;


function TUdLineTypes.Add(AObject: TUdLineType): Boolean;
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

function TUdLineTypes.Add(AName, AComment: string; AValue: TSingleArray): Boolean;
var
  N: Integer;
  LLineType: TUdLineType;
begin
  Result := False;

  N := IndexOf(AValue);
  if N >= 0 then Exit;

  LLineType := TUdLineType.Create();
  LLineType.Name := AName;
  LLineType.Comment := AComment;
  LLineType.Value := AValue;

  LLineType.Owner := Self;
  LLineType.SetDocument(Self.Document, Self.IsDocRegister);

  FList.Add(LLineType);
  Self.AddDocObject(LLineType);

  if Assigned(FOnAdd) then FOnAdd(Self, LLineType);
  Result := True;
end;




//----------------------------------------------------------

function TUdLineTypes.Remove(AIndex: Integer): Boolean;
var
  LLntype: TUdLineType;
begin
  Result := False;
  if (AIndex < 3) or (AIndex >= FList.Count) then Exit;

  LLntype := TUdLineType(FList.Items[AIndex]);

  if FActive <> LLntype then
  begin
    Result := True;
    if Assigned(FOnRemove) then FOnRemove(Self, LLntype, Result);

    if Result then
    begin
      Self.RemoveDocObject(LLntype);
      FList.Delete(AIndex);
    end;
  end;
end;


function TUdLineTypes.Remove(AName: string): Boolean;
begin
  Result := Remove(IndexOf(AName));
end;

function TUdLineTypes.Remove(const AValue: TSingleArray): Boolean;
begin
  Result := Remove(IndexOf(AValue));
end;

function TUdLineTypes.Remove(AObject: TUdLineType): Boolean;
begin
  Result := Remove(IndexOf(AObject));
end;




//----------------------------------------------------------

function TUdLineTypes.GetItem(AIndex: Integer): TUdLineType;
begin
  Result := nil;

  if (AIndex >= 0) and (AIndex < FList.Count) then
    Result := TUdLineType(FList.Items[AIndex]);
end;

function TUdLineTypes.GetItem(AName: string): TUdLineType;
begin
  Result := GetItem(IndexOf(AName));
end;

function TUdLineTypes.GetItem(const AValue: TSingleArray): TUdLineType;
begin
  Result := GetItem(IndexOf(AValue));
end;



//----------------------------------------------------------

function TUdLineTypes.SetActive(AIndex: Integer): Boolean;
var
  LLntype: TUdLineType;
begin
  Result := False;

  LLntype := GetItem(AIndex);

  if Assigned(LLntype) and (LLntype <> FActive) and Self.RaiseBeforeModifyObject('Active') then
  begin
    FActive := LLntype;

    if Assigned(FOnSelect) then FOnSelect(Self, FActive);

    Self.RaiseAfterModifyObject('Active');
    Result := True;
  end;
end;

function TUdLineTypes.SetActive(AName: string): Boolean;
begin
  Result := SetActive(IndexOf(AName));
end;

function TUdLineTypes.SetActive(const AValue: TSingleArray): Boolean;
begin
  Result := SetActive(IndexOf(AValue));
end;

function TUdLineTypes.SetActive(AObject: TUdLineType): Boolean;
begin
  Result := SetActive(IndexOf(AObject));
end;


procedure TUdLineTypes.SetActive_(const AValue: TUdLineType);
begin
  Self.SetActive(AValue);
end;


function TUdLineTypes.GetActiveIndex(): Integer;
begin
  Result := Self.IndexOf(FActive);
end;




procedure TUdLineTypes.SetCurrentScale(const AValue: Float);
begin
  if NotEqual(FCurrentScale, AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('CurrentScale') then
  begin
    FCurrentScale := AValue;
    Self.RaiseAfterModifyObject('CurrentScale');
  end;
end;

procedure TUdLineTypes.SetGlobalScale(const AValue: Float);
begin
  if NotEqual(FGlobalScale, AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('GlobalScale') then
  begin
    FGlobalScale := AValue;

    if Assigned(Self.Document) then
      TUdDocument(Self.Document).Layouts.UpdateEntities();

    Self.RaiseAfterModifyObject('GlobalScale');
  end;
end;




//----------------------------------------------------------------------

function TUdLineTypes.Add(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLineType) then
    Result := Self.Add(TUdLineType(AObj));
end;

function TUdLineTypes.Insert(AIndex: Integer; AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLineType) and (FList.IndexOf(AObj) < 0) then
  begin
    if AIndex < 0 then AIndex := AIndex + FList.Count;
    if AIndex > FList.Count then AIndex := FList.Count;

    FList.Insert(AIndex, AObj);
    if Assigned(FOnAdd) then FOnAdd(Self, TUdLineType(AObj));

    Self.AddDocObject(AObj);
    Result := True;
  end;
end;


function TUdLineTypes.Remove(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLineType) then
  begin
    Result := Self.Remove(TUdLineType(AObj));
  end;
end;

function TUdLineTypes.RemoveAt(AIndex: Integer): Boolean;
begin
  Result := Self.Remove(AIndex);
end;


function TUdLineTypes.IndexOf(AObj: TUdObject): Integer;
begin
  Result := -1;
  if Assigned(AObj) and AObj.InheritsFrom(TUdLineType) then
    Result := FList.IndexOf(TUdLineType(AObj));
end;

function TUdLineTypes.Contains(AObj: TUdObject): Boolean;
begin
  Result := Self.IndexOf(AObj) >= 0;
end;




//----------------------------------------------------------------------

procedure TUdLineTypes.SaveToStream(AStream: TStream);
var
  I: Integer;
begin
  inherited;

  FloatToStream(AStream, FGlobalScale );
  FloatToStream(AStream, FCurrentScale);

  IntToStream(AStream, FList.Count);

  for I := 0 to FList.Count - 1 do
    TUdLineType(FList[I]).SaveToStream(AStream);

  IntToStream(AStream, IndexOf(FActive));
end;


procedure TUdLineTypes.LoadFromStream(AStream: TStream);
var
  I, LCount: Integer;
  LLineType: TUdLineType;
begin
  Self.Clear(True);

  inherited;

  FGlobalScale  := FloatFromStream(AStream);
  FCurrentScale := FloatFromStream(AStream);

  LCount := IntFromStream(AStream);
  for I := 0 to LCount - 1 do
  begin
    LLineType := TUdLineType.Create(Self.Document, Self.IsDocRegister);
    LLineType.Owner := Self;
    LLineType.LoadFromStream(AStream);

    FList.Add(LLineType);
    Self.AddDocObject(LLineType, False);
  end;

  if FList.Count > 0 then FByLayer    := FList.Items[0];
  if FList.Count > 1 then FByBlock    := FList.Items[1];
  if FList.Count > 2 then FContinuous := FList.Items[2];

  I := IntFromStream(AStream);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FByLayer;

//  Self.RaiseChanged();
end;




procedure TUdLineTypes.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I: Integer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['GlobalScale'] := FloatToStr(FGlobalScale);
  LXmlNode.Prop['CurrentScale'] := FloatToStr(FCurrentScale);

  for I := 0 to FList.Count - 1 do
  begin
    TUdLineType(FList[I]).SaveToXml(LXmlNode.Add());
  end;

  LXmlNode.Prop['ActiveIndex'] := IntToStr(IndexOf(FActive));
end;

procedure TUdLineTypes.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  LLineType: TUdLineType;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  Self.Clear(True);

  LXmlNode := TUdXmlNode(AXmlNode);

  for I := 0 to LXmlNode.Count - 1 do
  begin
    LLineType := TUdLineType.Create(Self.Document, Self.IsDocRegister);
    LLineType.Owner := Self;
    LLineType.LoadFromXml(LXmlNode.Items[I]);

    FList.Add(LLineType);
    Self.AddDocObject(LLineType, False);
  end;

  if FList.Count > 0 then FByLayer    := FList.Items[0];
  if FList.Count > 1 then FByBlock    := FList.Items[1];
  if FList.Count > 2 then FContinuous := FList.Items[2];


  I := StrToIntDef(LXmlNode.Prop['ActiveIndex'], -1);
  if (I >= 0) and (I < FList.Count) then
    FActive := FList.Items[I]
  else
    FActive := FByLayer;
end;



//---------------------------------------------------------------------------

function TUdLineTypes.GetStdLineType(AName: string): TUdLineType;
var
  I: Integer;
  LName: string;
  LLineType: TUdLineType;
begin
  Result := nil;

  LName := UpperCase(AName);
  for I := 0 to FStdLns.Count - 1 do
  begin
    LLineType := TUdLineType(FStdLns.Items[I]);
    if LName = LLineType.Name then
    begin
      Result := LLineType;
      Break;
    end;
  end;
end;





end.