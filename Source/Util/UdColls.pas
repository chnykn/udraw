
unit UdColls;

interface

uses
  Windows, Classes, UdTypes, UdObject;

type
  TPoint2DList = class(TObject)
  private
    FList: TList;

  public
    constructor Create(ACapacity: Integer=MAXBYTE);
    destructor Destroy; override;

    function Add(AItem: TPoint2D): Boolean; overload;
    function Add(AItem: PPoint2D): Boolean; overload;

    function IndexOf(AItem: TPoint2D; Epsilon: Extended = 1E-8): Integer; overload;
    function IndexOf(AItem: PPoint2D): Integer; overload;

    function Contains(AItem: TPoint2D; Epsilon: Extended = 1E-8): Boolean; overload;
    function Contains(AItem: PPoint2D): Boolean; overload;

    function Insert(AIndex: Integer; AItem: TPoint2D): Integer; overload;
    function Insert(AIndex: Integer; AItem: PPoint2D): Integer; overload;

    function Remove(AItem: TPoint2D; Epsilon: Extended = 1E-8): Boolean; overload;
    function Remove(AItem: PPoint2D): Boolean; overload;

    function RemoveAt(AIndex: Integer): Boolean;

    function Clear(): Boolean;

    function Count(): Integer;
    function ToArray(): TPoint2DArray;

    function GetPoint(AIndex: Integer): TPoint2D;
    function GetPPoint(AIndex: Integer): PPoint2D;
  end;


  TPoint2DStack = class(TObject)
  private
    FList: TList;

  public
    constructor Create(ACapacity: Integer);
    destructor Destroy; override;

    function Push(AItem: TPoint2D): Boolean; overload;
    function Push(AItem: PPoint2D): Boolean; overload;

    function Pop(): PPoint2D;
    function Peek(): PPoint2D;

    function Clear(): Boolean;

    function Count(): Integer;
    function ToArray(): TPoint2DArray;
  end;




  //--------------------------------------------------------------
(*
  TUdObjectFunc = function(AObj: TUdObject): Boolean;
  TUdObjectMethod = function(AObj: TUdObject): Boolean of object;


  TUdObjectList = class(TObject)
  private
    FList: TList;

  protected
    function GetCount: Integer;
    function GetItems(AIndex: Integer): Pointer;
    procedure SetItems(AIndex: Integer; const AValue: Pointer);

  public
    constructor Create();
    destructor Destroy; override;

    function Add(AItem: TUdObject): Boolean;
    function Insert(AIndex: Integer; AItem: TUdObject): Integer;

    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AItem: TUdObject): Boolean; overload;

//    function Find(AFunc: TUdObjectFunc): TUdObject; overload;
//    function Find(AMethod: TUdObjectMethod): TUdObject; overload;
//
//    function Find(AFunc: TUdObjectFunc; out AIndex: Integer): TUdObject; overload;
//    function Find(AMethod: TUdObjectMethod; out AIndex: Integer): TUdObject; overload;


    function Contains(AItem: TUdObject): Boolean;

    function IndexOf(AItem: TUdObject): Integer;
    function Exchange(Index1, Index2: Integer): Boolean;


    function Clear(): Boolean; overload;
    function Clear(AReservedCount: Integer): Boolean; overload;

    function ToArray(): TUdObjectArray;

    procedure Sort(Compare: TListSortCompare);
//    procedure SortList(const Compare: TListSortCompareFunc);

  public
    property Count: Integer read GetCount;
    property Items[Index: Integer]: Pointer read GetItems write SetItems;


  end;
*)

implementation

uses
  Math;



//==================================================================================================
{ TPoint2DList }

constructor TPoint2DList.Create(ACapacity: Integer=MAXBYTE);
begin
  FList := TList.Create;
  FList.Capacity := ACapacity;
end;

destructor TPoint2DList.Destroy;
begin
  Self.Clear();
  if Assigned(FList) then FList.Free;
  FList := nil;
  inherited;
end;




function TPoint2DList.Add(AItem: TPoint2D): Boolean;
var
  LPnt: PPoint2D;
begin
  LPnt := New(PPoint2D);
  LPnt^.X := AItem.X;
  LPnt^.Y := AItem.Y;
  Result := Self.Add(LPnt);
end;

function TPoint2DList.Add(AItem: PPoint2D): Boolean;
begin
  Result := FList.Add(AItem) > 0;
end;



function TPoint2DList.IndexOf(AItem: PPoint2D): Integer;
begin
  Result := FList.IndexOf(AItem);
end;

function TPoint2DList.IndexOf(AItem: TPoint2D; Epsilon: Extended = 1E-8): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := FList.Count - 1 downto 0 do
  begin
    if Math.SameValue(PPoint2D(FList[I])^.X, AItem.X) and
       Math.SameValue(PPoint2D(FList[I])^.Y, AItem.Y) then
    begin
      Result := I;
      Break;
    end;
  end;
end;



function TPoint2DList.Contains(AItem: PPoint2D): Boolean;
begin
  Result := Self.IndexOf(AItem) >= 0;
end;

function TPoint2DList.Contains(AItem: TPoint2D; Epsilon: Extended = 1E-8): Boolean;
begin
  Result := Self.IndexOf(AItem, Epsilon) >= 0;
end;





function TPoint2DList.Insert(AIndex: Integer; AItem: TPoint2D): Integer;
var
  LPnt: PPoint2D;
begin
  Result := -1;     
  if (AIndex >= 0) and (AIndex <= FList.Count) then
  begin
    LPnt := New(PPoint2D);
    LPnt^.X := AItem.X;
    LPnt^.Y := AItem.Y;
    Result := Self.Insert(AIndex, LPnt);
  end;
end;

function TPoint2DList.Insert(AIndex: Integer; AItem: PPoint2D): Integer;
begin
  Result := AIndex;
  try
    FList.Insert(AIndex, AItem);
  except
    Result := -1;
  end;
end;


function TPoint2DList.Remove(AItem: PPoint2D): Boolean;
begin
  Result := FList.Remove(AItem) >= 0;
end;

function TPoint2DList.Remove(AItem: TPoint2D; Epsilon: Extended = 1E-8): Boolean;
var
  N: Integer;
begin
  Result := False;

  N := Self.IndexOf(AItem, Epsilon);
  if N >= 0 then
  begin
    Dispose(PPoint2D(FList[N]));
    FLIst.Delete(N);

    Result := True;
  end;
end;


function TPoint2DList.RemoveAt(AIndex: Integer): Boolean;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  Dispose(PPoint2D(FList[AIndex]));
  FLIst.Delete(AIndex);

  Result := True;
end;





function TPoint2DList.Clear(): Boolean;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do Dispose(PPoint2D(FList[I]));
  FList.Clear();
  Result := True;
end;


function TPoint2DList.Count(): Integer;
begin
  Result := FList.Count;
end;

function TPoint2DList.ToArray(): TPoint2DArray;
var
  I: Integer;
begin
  System.SetLength(Result, FList.Count);
  for I := 0 to FList.Count - 1 do Result[I] := PPoint2D(FList[I])^;
end;




function TPoint2DList.GetPoint(AIndex: Integer): TPoint2D;
begin
  if (AIndex >= 0) and (AIndex < FList.Count) then
    Result :=  PPoint2D(FList[AIndex])^;
end;

function TPoint2DList.GetPPoint(AIndex: Integer): PPoint2D;
begin
  Result := nil;
  if (AIndex >= 0) and (AIndex < FList.Count) then
    Result :=  PPoint2D(FList[AIndex]);
end;



//==================================================================================================
{TPoint2DStack}

constructor TPoint2DStack.Create(ACapacity: Integer);
begin
  FList := TList.Create;
  FList.Capacity := ACapacity;
end;

destructor TPoint2DStack.Destroy;
begin
  Self.Clear();
  if Assigned(FList) then FList.Free;
  FList := nil;
  inherited;
end;



function TPoint2DStack.Push(AItem: TPoint2D): Boolean;
var
  LPnt: PPoint2D;
begin
  LPnt := New(PPoint2D);
  LPnt^.X := AItem.X;
  LPnt^.Y := AItem.Y;
  Result := Self.Push(LPnt);
end;

function TPoint2DStack.Push(AItem: PPoint2D): Boolean;
begin
  Result := FList.Add(AItem) > 0;
end;

function TPoint2DStack.Pop(): PPoint2D;
begin
  Result := nil;
  if FList.Count > 0 then
  begin
    Result := PPoint2D(FList[FList.Count - 1]);
    FList.Delete(FList.Count - 1);
  end;
end;

function TPoint2DStack.Peek(): PPoint2D;
begin
  Result := nil;
  if FList.Count > 0 then
    Result := PPoint2D(FList[FList.Count - 1]);
end;



function TPoint2DStack.Clear(): Boolean;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do Dispose(PPoint2D(FList[I]));
  FList.Clear();
  Result := True;
end;


function TPoint2DStack.Count(): Integer;
begin
  Result := FList.Count;
end;

function TPoint2DStack.ToArray(): TPoint2DArray;
var
  I: Integer;
begin
  System.SetLength(Result, FList.Count);
  for I := 0 to FList.Count - 1 do Result[I] := PPoint2D(FList[I])^;
end;




//==================================================================================================
{ TUdObjectList }
(*
constructor TUdObjectList.Create;
begin
  FList := TList.Create;
end;

destructor TUdObjectList.Destroy;
begin
  Self.Clear();

  FList.Free;
  FList := nil;

  inherited;
end;



//-------------------------------------------------------------------------

function TUdObjectList.GetCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FList.Count - 1 do
    if not TUdObject(FList[I]).Deleted then Inc(Result);
end;

function TUdObjectList.GetItems(AIndex: Integer): Pointer;
var
  I, N: Integer;
begin
  Result := nil;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  N := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if not TUdObject(FList[I]).Deleted then
    begin
      Inc(N);
      if N = AIndex then
      begin
        Result := FList[I];
        Break;
      end;
    end;
  end;
end;

procedure TUdObjectList.SetItems(AIndex: Integer; const AValue: Pointer);
var
  I, N: Integer;
begin
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  N := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if not TUdObject(FList[I]).Deleted then
    begin
      Inc(N);
      if N = AIndex then
      begin
        FList[I] := AValue;
        Break;
      end;
    end;
  end;
end;



//-------------------------------------------------------------------------

function TUdObjectList.Add(AItem: TUdObject): Boolean;
begin
  Result := False;
  if not Assigned(AItem) or (FList.IndexOf(AItem) >= 0) then Exit;

  FList.Add(AItem);
  Result := True;
end;

function TUdObjectList.Insert(AIndex: Integer; AItem: TUdObject): Integer;
var
  I, N, M: Integer;
begin
  N := -1;
  M := -1;
  if AIndex < 0 then M := 0 else
  if AIndex > FList.Count - 1 then M := FList.Count - 1 else
  begin
    for I := 0 to FList.Count - 1 do
    begin
      if not TUdObject(FList[I]).Deleted then
      begin
        Inc(N);
        if N = AIndex then
        begin
          M := I;
          Break;
        end;
      end;
    end;

    if M < 0 then
    begin
      if N < AIndex then M := FList.Count - 1 else M := 0;
    end;
  end;

  FList.Insert(M, AItem);
  Result := M;
end;



function TUdObjectList.Remove(AIndex: Integer): Boolean;
var
  I, N: Integer;
begin
  Result := False;

  N := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if not TUdObject(FList[I]).Deleted then
    begin
      Inc(N);
      if N = AIndex then
      begin
        TUdObject(FList[I]).Deleted := True;

        Result := True;
        Break;
      end;
    end;
  end;
end;

function TUdObjectList.Remove(AItem: TUdObject): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FList.Count - 1 do
  begin
    if (FList[I] = AItem)  then
    begin
      if TUdObject(FList[I]).Deleted then
      begin
        AItem.Free;
        FList.Delete(I);
      end
      else
        AItem.Deleted := True;

      Break;
      Result := True;
    end;
  end;
end;






//-------------------------------------------------------------------------

function TUdObjectList.Find(AFunc: TUdObjectFunc; out AIndex: Integer): TUdObject;
var
  I, N: Integer;
begin
  Result := nil;
  AIndex := -1;
  if not Assigned(AFunc) then Exit;

  N := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if not TUdObject(FList[I]).Deleted then
    begin
      Inc(N);

      if AFunc(FList[I]) then
      begin
        AIndex := N;
        Result := FList[I];
        Break;
      end;
    end;
  end;
end;

function TUdObjectList.Find(AMethod: TUdObjectMethod; out AIndex: Integer): TUdObject;
var
  I, N: Integer;
begin
  Result := nil;
  AIndex := -1;
  if not Assigned(AMethod) then Exit;

  N := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if not TUdObject(FList[I]).Deleted then
    begin
      Inc(N);

      if AMethod(FList[I]) then
      begin
        AIndex := N;
        Result := FList[I];
        Break;
      end;
    end;
  end;
end;


function TUdObjectList.Find(AFunc: TUdObjectFunc): TUdObject;
var
  N: Integer;
begin
  Result := Self.Find(AFunc, N);
end;

function TUdObjectList.Find(AMethod: TUdObjectMethod): TUdObject;
var
  N: Integer;
begin
  Result := Self.Find(AMethod, N);
end;






function TUdObjectList.Contains(AItem: TUdObject): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 0 to FList.Count - 1 do
  begin
    if not TUdObject(FList[I]).Deleted and (FList[I] = AItem) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TUdObjectList.IndexOf(AItem: TUdObject): Integer;
var
  I, N: Integer;
begin
  Result := -1;

  N := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if not TUdObject(FList[I]).Deleted then
    begin
      Inc(N);

      if (FList[I] = AItem) then
      begin
        Result := N;
        Break;
      end;
    end;
  end;
end;

function TUdObjectList.Exchange(Index1, Index2: Integer): Boolean;
var
  I, N, M1, M2: Integer;
begin
  Result := False;

  N := -1;
  M1 := -1; M2 := -1;
  for I := 0 to FList.Count - 1 do
  begin
    if not TUdObject(FList[I]).Deleted then
    begin
      Inc(N);

      if (N = Index1) then M1 := I;
      if (N = Index2) then M2 := I;

      if (M1 >= 0) and (M2 >= 0) then Break;
    end;
  end;

  if (M1 >= 0) and (M2 >= 0) then
  begin
    FList.Exchange(M1, M2);
    Result := True;
  end;
end;



//-------------------------------------------------------------------------

function TUdObjectList.Clear(): Boolean;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do TUdObject(FList[I]).Free;
  FList.Clear;

  Result := True;
end;

function TUdObjectList.Clear(AReservedCount: Integer): Boolean;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto AReservedCount do
  begin
    TUdObject(FList[I]).Free;
    FList.Delete(I);
  end;

  Result := True;
end;


function TUdObjectList.ToArray(): TUdObjectArray;
var
  I, L: Integer;
begin
  System.SetLength(Result, FList.Count);

  L := 0;
  for I := 0 to FList.Count - 1 do
  begin
    if not TUdObject(FList[I]).Deleted then
    begin
      Result[L] := FList[I];
      Inc(L);
    end;
  end;

  if System.Length(Result) <> L then System.SetLength(Result, L);
end;




procedure TUdObjectList.Sort(Compare: TListSortCompare);
begin
  FList.Sort(Compare);
end;

//procedure TUdObjectList.SortList(const Compare: TListSortCompareFunc);
//begin
//  FList.SortList(Compare);
//end;
*)



end.