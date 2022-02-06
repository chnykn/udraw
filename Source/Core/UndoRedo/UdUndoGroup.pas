{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdUndoGroup;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdObject, UdUndoItem;

type
  TUdUndoGroup = class(TObject)
  private
    FName: string;
    FOwner: TObject;

    FList: TList;
    FOnGetObjectByID: TUdGetObjectEvent;

  protected
    function GetObjectByID(AID: Integer): TUdObject;
    property _OnGetObjectByID: TUdGetObjectEvent read FOnGetObjectByID write FOnGetObjectByID;

  public
    constructor Create(AOwner: TObject);
    destructor Destroy; override;

    function BeginUndo(AName: string): Boolean;
    function EndUndo(): Boolean;


    procedure DoAddObject(AObj: TUdObject);
    procedure DoRemoveObject(AObj: TUdObject);
    procedure DoBeforeModifyObject(AObj: TUdObject; APropName: string);

    function Perform(AUndo: Boolean): Boolean;

  public
    property Name     : string  read FName     write FName;
    property Owner    : TObject read FOwner    write FOwner;
  end;




implementation

uses
  UdUndoObject, UdUtils;


//===============================================================================================
{ TUdUndoGroup }

constructor TUdUndoGroup.Create(AOwner: TObject);
begin
  FName       := '';
  FOwner      := AOwner;

  FList := TList.Create;
end;

destructor TUdUndoGroup.Destroy;
begin
  UdUtils.ClearObjectList(FList);

  if Assigned(FList) then FList.Free;
  FList := nil;

  FOwner      := nil;

  inherited;
end;


function TUdUndoGroup.GetObjectByID(AID: Integer): TUdObject;
begin
  Result := nil;
  if Assigned(FOnGetObjectByID) then FOnGetObjectByID(Self, AID, Result);
end;



//-----------------------------------------------------------------------

procedure TUdUndoGroup.DoAddObject(AObj: TUdObject);
var
  LItem: TUdUndoObject;
begin
  LItem := TUdUndoObject.Create(Self);
  if LItem.DoAddObject(AObj) then FList.Add(LItem) else LItem.Free;
end;

procedure TUdUndoGroup.DoRemoveObject(AObj: TUdObject);
var
  LItem: TUdUndoObject;
begin
  LItem := TUdUndoObject.Create(Self);
  if LItem.DoRemoveObject(AObj) then FList.Add(LItem) else LItem.Free;
end;

procedure TUdUndoGroup.DoBeforeModifyObject(AObj: TUdObject; APropName: string);
var
  LItem: TUdUndoObject;
begin
  LItem := TUdUndoObject.Create(Self);
  if LItem.DoBeforeModifyObject(AObj, APropName) then FList.Add(LItem) else LItem.Free;
end;




//-----------------------------------------------------------------------

function TUdUndoGroup.BeginUndo(AName: string): Boolean;
begin
  FName  := AName;
  Result := True;
end;


function TUdUndoGroup.EndUndo: Boolean;
begin
  Result := FList.Count > 0;
end;

function TUdUndoGroup.Perform(AUndo: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not Assigned(FList) or (FList.Count <= 0) then Exit;

  if AUndo then
  begin
    for I := FList.Count - 1 downto 0 do
      TUdUndoItem(FList[I]).Perform();
  end
  else begin
    for I := 0 to FList.Count - 1 do
      TUdUndoItem(FList[I]).Perform();
  end;

  Result := True;
end;





end.