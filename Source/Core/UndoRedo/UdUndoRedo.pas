{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdUndoRedo;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Types,
  UdHashMaps, UdObject, UdUndoGroup;

type
  TUdUndoRedo = class(TUdObject)
  private
    FCounter: Integer;
    FPerforming: Boolean;
    FCurGroup: TUdUndoGroup;

    FUndoList: TList;
    FRedoList: TList;

    FModifyHash: TUdStrHashMap;

    FOnChanged: TNotifyEvent;
    FOnGetObjectByID: TUdGetObjectEvent;

  protected
    function GetUndoCount: Integer;
    function GetRedoCount: Integer;

    function GetUndoNames: TStringDynArray;
    function GetRedoNames: TStringDynArray;

    procedure OnUndoGroupGetObjectByID(Sender: TObject; const AID: Integer; var AObject: TUdObject);
    property _OnGetObjectByID: TUdGetObjectEvent read FOnGetObjectByID write FOnGetObjectByID;

  public
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); override;
    destructor Destroy; override;

    procedure Clear();

    function BeginUndo(AName: string): Boolean;
    function EndUndo(): Boolean;

    function PerformUndo(): Boolean;
    function PerformRedo(): Boolean;

    procedure DoAddObject(AObj: TUdObject);
    procedure DoRemoveObject(AObj: TUdObject);
    procedure DoBeforeModifyObject(AObj: TUdObject; APropName: string);

  public
    property UndoCount: Integer read GetUndoCount;
    property RedoCount: Integer read GetRedoCount;

    property UndoNames: TStringDynArray read GetUndoNames;
    property RedoNames: TStringDynArray read GetRedoNames;

    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;


implementation

uses
  SysUtils,
  UdLayout, UdMath, UdUtils;


type
  TFUndoGroup = class(TUdUndoGroup);



//=================================================================================================
{ TUdUndoRedo }

constructor TUdUndoRedo.Create(ADocument: TUdObject; AIsDocRegister: Boolean = True);
begin
  inherited;

  FCounter := 0;
  FPerforming := False;

  FCurGroup := nil;

  FUndoList := TList.Create;
  FRedoList := TList.Create;

  FModifyHash := TUdStrHashMap.Create();
end;

destructor TUdUndoRedo.Destroy;
begin
  Clear();

  if Assigned(FCurGroup) then FCurGroup.Free;
  FCurGroup := nil;

  if Assigned(FUndoList) then FUndoList.Free;
  FUndoList := nil;

  if Assigned(FRedoList) then FRedoList.Free;
  FRedoList := nil;

  if Assigned(FModifyHash) then FModifyHash.Free;
  FModifyHash := nil;

  inherited;
end;


procedure TUdUndoRedo.OnUndoGroupGetObjectByID(Sender: TObject; const AID: Integer; var AObject: TUdObject);
begin
  AObject := nil;
  if Assigned(FOnGetObjectByID) then FOnGetObjectByID(Sender, AID, AObject);
end;


//-------------------------------------------------------------------------------

procedure TUdUndoRedo.Clear;
begin
  FModifyHash.Clear();
  
  if Assigned(FCurGroup) then FCurGroup.Free;
  FCurGroup := nil;

  UdUtils.ClearObjectList(FUndoList);
  UdUtils.ClearObjectList(FRedoList);

  if Assigned(FOnChanged) then FOnChanged(Self);
end;


function TUdUndoRedo.GetUndoCount: Integer;
begin
  Result := FUndoList.Count;
end;


function TUdUndoRedo.GetRedoCount: Integer;
begin
  Result := FRedoList.Count;
end;


function TUdUndoRedo.GetUndoNames: TStringDynArray;
var
  I: Integer;
begin
  System.SetLength(Result, FUndoList.Count);
  for I := 0 to FUndoList.Count - 1 do
    Result[I] := TUdUndoGroup(FUndoList[I]).Name;
end;

function TUdUndoRedo.GetRedoNames: TStringDynArray;
var
  I: Integer;
begin
  System.SetLength(Result, FRedoList.Count);
  for I := 0 to FRedoList.Count - 1 do
    Result[I] := TUdUndoGroup(FRedoList[I]).Name;
end;



//-------------------------------------------------------------------------------

function TUdUndoRedo.BeginUndo(AName: string): Boolean;
begin
  Result := False;
  if FPerforming then Exit;

  Inc(FCounter);

  if FCounter = 1 then
  begin
    FModifyHash.Clear();
    if Assigned(FCurGroup) then FCurGroup.Free;
    FCurGroup := nil;

    FCurGroup := TUdUndoGroup.Create(Self);
    TFUndoGroup(FCurGroup)._OnGetObjectByID := OnUndoGroupGetObjectByID;
    FCurGroup.BeginUndo(AName);

    Result := True;
  end;
end;

function TUdUndoRedo.EndUndo: Boolean;
begin
  Result := False;
  if FCounter > 0 then Dec(FCounter);

  if (FCounter = 0) and Assigned(FCurGroup) then
  begin
    if FCurGroup.EndUndo() then
    begin
      FUndoList.Add(FCurGroup);

      UdUtils.ClearObjectList(FRedoList);
      FModifyHash.Clear();

      if Assigned(FOnChanged) then FOnChanged(Self);
      Result := True;
    end
    else
      FCurGroup.Free;

    FCurGroup := nil;
  end;
end;




function TUdUndoRedo.PerformUndo: Boolean;
var
  N: Integer;
  LUndoGroup: TUdUndoGroup;
begin
  Result := False;

  if FPerforming or (FCounter <> 0) then Exit;
  if not Assigned(FUndoList) or (FUndoList.Count <= 0) then Exit;

  if Assigned(FCurGroup) then FCurGroup.Free;
  FCurGroup := nil;

  FPerforming := True;
  try
    N := FUndoList.Count - 1;
    LUndoGroup := TUdUndoGroup(FUndoList[N]);

    TFUndoGroup(LUndoGroup)._OnGetObjectByID := OnUndoGroupGetObjectByID;
    LUndoGroup.Perform(True);

    if Assigned(FRedoList) then FRedoList.Add(LUndoGroup);
    FUndoList.Delete(N);

    if Assigned(FOnChanged) then FOnChanged(Self);
  finally
    FPerforming := False;
  end;

  Result := True;
end;


function TUdUndoRedo.PerformRedo: Boolean;
var
  N: Integer;
  LUndoGroup: TUdUndoGroup;
begin
  Result := False;

  if FPerforming or (FCounter <> 0) then Exit;
  if not Assigned(FRedoList) or (FRedoList.Count <= 0) then Exit;

  if Assigned(FCurGroup) then FCurGroup.Free;
  FCurGroup := nil;

  FPerforming := True;
  try
    N := FRedoList.Count - 1;
    LUndoGroup := TUdUndoGroup(FRedoList[N]);

    TFUndoGroup(LUndoGroup)._OnGetObjectByID := OnUndoGroupGetObjectByID;
    LUndoGroup.Perform(False);

    if Assigned(FUndoList) then FUndoList.Add(LUndoGroup);
    FRedoList.Delete(N);

    if Assigned(FOnChanged) then FOnChanged(Self);
  finally
    FPerforming := False;
  end;

  Result := True;
end;






//-------------------------------------------------------------------------------

procedure TUdUndoRedo.DoAddObject(AObj: TUdObject);
begin
  if FPerforming or not Assigned(AObj) then Exit;
  if not Assigned(AObj.Owner) or not Assigned(FCurGroup) then Exit;

  FCurGroup.DoAddObject(AObj);
end;

procedure TUdUndoRedo.DoRemoveObject(AObj: TUdObject);
begin
  if FPerforming or not Assigned(AObj) then Exit;

  if not Assigned(AObj.Owner) or not Assigned(FCurGroup) then
  begin
    AObj.Free;
    Exit; //==========>>>
  end;

  FCurGroup.DoRemoveObject(AObj);
end;

procedure TUdUndoRedo.DoBeforeModifyObject(AObj: TUdObject; APropName: string);
var
  LKey: string;
  LObj: TObject;
begin
  if not Assigned(AObj) or not Assigned(FCurGroup) then Exit;

  LKey := IntToStr(AObj.ID) + '|' + APropName;
  LObj := FModifyHash.GetValue(LKey);
  if LObj = AObj then Exit; //=====>>>

  FCurGroup.DoBeforeModifyObject(AObj, APropName);
  FModifyHash.Add(LKey, AObj);
end;





end.