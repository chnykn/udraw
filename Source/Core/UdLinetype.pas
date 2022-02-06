{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLineType;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Types,
  UdConsts, UdTypes, UdIntfs, UdObject;

type
  TUdLineType = class;

  TUdLineTypeEvent = procedure(Sender: TObject; LineType: TUdLineType) of object;
  TUdLineTypeAllowEvent = procedure(Sender: TObject; LineType: TUdLineType; var Allow: Boolean) of object;


  TUdLineTypeArray = array of TUdLineType;


  TUdLineType = class(TUdObject, IUdObjectItem)
  private
    FByKind: TUdByKind;
    FName: string;

    FValue: TSingleArray;
    FComment: string;
    
    FStatus: Cardinal;

  protected
    function GetTypeID: Integer; override;

    procedure SetName(const AValue: string);
    procedure SetByKind(const AValue: TUdByKind);

    procedure SetComment(const AValue: string);
    procedure SetValue(const AValue: TSingleArray);

    function GetValue: TSingleArray;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    function IsEqual(const AValue: TUdLineType): Boolean;
    function SegmentLength(): Float;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Name: string read FName write SetName;
    property ByKind: TUdByKind read FByKind write SetByKind;

    property Value: TSingleArray read GetValue write SetValue;
    property Comment: string read FComment write SetComment;

    property Status: Cardinal read FStatus write FStatus;
  end;





function NewLtData(): PLtData;

function FreeLtData(var ALtData: PLtData): Boolean;
function FreeLtDatas(var ALtDatas: TLtDataArray): Boolean;
function AppendLtData(var ALtData: PLtData; ASeg: PLtSeg): PLtData;

function MakeLtData(P1, P2: TPoint2D; ALineType: TSingleArray; ALtScale: Single = 1.0): PLtData; overload;
function MakeLtData(APoints: TPoint2DArray; ALineType: TSingleArray; ALtScale: Single = 1.0): PLtData; overload;



implementation

uses
  SysUtils,
  UdMath, UdUtils, UdStreams, UdXml;






//=================================================================================================

function NewLtData(): PLtData;
begin
  Result := New(PLtData);
  Result.Next := nil;
  Result.Data := New(PLtSeg);
end;

function FreeLtData(var ALtData: PLtData): Boolean;
var
  LItem1, LItem2: PLtData;
begin
  Result := False;
  if ALtData = nil then Exit;

  LItem1 := ALtData.Next;
  while LItem1 <> nil do
  begin
    LItem2 := LItem1.Next;

    Dispose(LItem1.Data);
    Dispose(LItem1);

    LItem1 := LItem2;
  end;

  Dispose(ALtData.Data);
  Dispose(ALtData);

  ALtData := nil;

  Result := True;
end;

function FreeLtDatas(var ALtDatas: TLtDataArray): Boolean;
var
  I: Integer;
begin
  Result := False;
  if System.Length(ALtDatas) <= 0 then Exit;

  for I := System.Length(ALtDatas) - 1 downto 0 do
    FreeLtData(ALtDatas[I]);
  System.SetLength(ALtDatas, 0);

  Result := True;
end;



function AppendLtData(var ALtData: PLtData; ASeg: PLtSeg): PLtData;
var
  LTemp: PLtData;
begin
  LTemp := New(PLtData);
  LTemp^.Data := ASeg;
  LTemp^.Next := ALtData;
  Result := LTemp;
end;





//--------------------------------------------------------------------------------------


function NewLtSeg(X1, Y1, X2, Y2: Single): PLtSeg;
begin
  Result := New(PLtSeg);
  Result.P1.X := X1;
  Result.P1.Y := Y1;
  Result.P2.X := X2;
  Result.P2.Y := Y2;
end;

function MakeLtData(P1, P2: TPoint2D; ALineType: TSingleArray; ALtScale: Single = 1.0): PLtData;
var
  N, LLen: Integer;
  LTemp: PLtData;
  LX1, LY1, LX2, LY2: Single;
  DX, DY, LSinV, LCosV: Single;
  LPlusDis, LSubDis, LLnDis, LStep: Single;
begin
  Result := nil;

  LLen := System.Length(ALineType);
  if (LLen <= 1) or (IsEqual(P1.X, P2.X) and IsEqual(P1.Y, P2.Y)) then
  begin
    Result := NewLtData();
    Result.Data.P1 := P1;
    Result.Data.P2 := P2;
    Exit;
  end;

  if (ALtScale < 0) or IsEqual(ALtScale, 0, 1E-3) then ALtScale := 1.0;

  //-----------------------------------------------

  DX := P2.X - P1.X;
  DY := P2.Y - P1.Y;
  LLnDis := Sqrt(Sqr(DX) + Sqr(DY));
  if IsEqual(LLnDis, 0.0) then Exit;

  LCosV := DX / LLnDis;
  LSinV := DY / LLnDis;


  N := 1;
  LStep := ALineType[N - 1] * ALtScale;
  LPlusDis := Abs(LStep);

  LSubDis := LLnDis - LPlusDis;
  if LSubDis <= 0 then
  begin
    Result := NewLtData();
    Result.Data.P1 := P1;
    Result.Data.P2 := P2;
    Exit;
  end;



  //-----------------------------------------------
  LTemp := nil;

  LX1 := P1.X;
  LY1 := P1.Y;

  while LSubDis > 0 do
  begin
    LX2 := P1.X + LCosV * LPlusDis;
    LY2 := P1.Y + LSinV * LPlusDis;

    LStep := ALineType[N - 1] * ALtScale;

    if LStep >= 0 then LTemp := AppendLtData(LTemp, NewLtSeg(LX1, LY1, LX2, LY2));

    {
    if AxMath.IsEqual(Step, 0.0) then
      Temp := AppendLtData(Temp, NewLtSeg(_VoidValue, _VoidValue, AX2, AY2))
    else if Step > 0 then
      Temp := AppendLtData(Temp, NewLtSeg(AX1, AY1, AX2, AY2));
    }

    LX1 := LX2;
    LY1 := LY2;

    N := N + 1;
    if N > LLen then N := 1;

    LStep := ALineType[N - 1] * ALtScale;
    LPlusDis := LPlusDis + Abs(LStep);

    LSubDis := LLnDis - LPlusDis;
  end;

  if LStep > 0 then
    LTemp := AppendLtData(LTemp, NewLtSeg(LX1, LY1, P2.X, P2.Y))
  else
    LTemp := AppendLtData(LTemp, NewLtSeg(P2.X, P2.Y, P2.X, P2.Y));

  Result := LTemp;
end;


function MakeLtData(APoints: TPoint2DArray; ALineType: TSingleArray; ALtScale: Single = 1.0): PLtData;

  procedure _MakePathIt(var AReSegs: PLtData; X1, Y1, X2, Y2: Single; var LN: Integer; var LD: Single);
  var
    N, LLen: Integer;
    LX1, LY1, LX2, LY2: Single;
    DX, DY, LSinV, LCosV: Single;
    LPlusDis, LSubDis, LLnDis, LStep: Single;
  begin
    LLen := System.Length(ALineType);
    if (LLen <= 1) or (IsEqual(X1, X2) and IsEqual(Y1, Y2)) then
    begin
      AReSegs := AppendLtData(AReSegs, NewLtSeg(X1, Y1, X2, Y2));
      Exit;
    end;


    //----------------------------------------------

    DX := X2 - X1;
    DY := Y2 - Y1;
    LLnDis := Sqrt(Sqr(DX) + Sqr(DY));
    if IsEqual(LLnDis, 0.0) then Exit;

    LCosV := DX / LLnDis;
    LSinV := DY / LLnDis;


    if (LN > 0) and (LN <= LLen) then
    begin
      N := LN;
      LStep := LD;
    end
    else
    begin
      N := 1;
      LStep := ALineType[N - 1] * ALtScale;
    end;

    LPlusDis := Abs(LStep);

    LSubDis := LLnDis - LPlusDis;
    if LSubDis <= 0 then
    begin
      LN := N;
      LD := Abs(LSubDis);

      if LStep < 0 then
        LD := -LD
      else
        AReSegs := AppendLtData(AReSegs, NewLtSeg(X1, Y1, X2, Y2));
      Exit;
    end;



    //---------------------------------------------

    LX1 := X1;
    LY1 := Y1;

    while LSubDis > 0 do
    begin
      LX2 := X1 + LCosV * LPlusDis;
      LY2 := Y1 + LSinV * LPlusDis;

      if LStep >= 0 then AReSegs := AppendLtData(AReSegs, NewLtSeg(LX1, LY1, LX2, LY2));

      {
      if AxMath.IsEqual(Step, 0.0) then
        ReSegs := AppendLtData(ReSegs, NewLtSeg(_VoidValue, _VoidValue, AX2, AY2))
      else if Step > 0 then
        ReSegs := AppendLtData(ReSegs, NewLtSeg(AX1, AY1, AX2, AY2));
      }

      LX1 := LX2;
      LY1 := LY2;

      N := N + 1;
      if N > LLen then N := 1;

      LStep := ALineType[N - 1] * ALtScale;
      LPlusDis := LPlusDis + Abs(LStep);

      LSubDis := LLnDis - LPlusDis;
    end;

    LN := N;
    LD := Abs(LSubDis);

    if LStep < 0 then
      LD := -LD
    else
      AReSegs := AppendLtData(AReSegs, NewLtSeg(LX1, LY1, X2, Y2));
  end;

var
  I, L, LN: Integer;
  LD: Single;
  LX1, LY1, LX2, LY2: Single;
begin
  LN := -1;
  LD := 0.0;

  Result := nil;

  L := System.Length(APoints);
  if L <= 1 then Exit; //=======>>>

  if L = 2 then
  begin
    Result := MakeLtData(APoints[0], APoints[1], ALineType, ALtScale);
    Exit;  //=======>>>
  end;

  if (ALtScale < 0) or IsEqual(ALtScale, 0, 1E-3) then ALtScale := 1.0;

  LX2 := APoints[0].X;
  LY2 := APoints[0].Y;

  for I := 0 to System.Length(APoints) - 2 do
  begin
    LX1 := APoints[I].X;
    LY1 := APoints[I].Y;
    LX2 := APoints[I + 1].X;
    LY2 := APoints[I + 1].Y;

    _MakePathIt(Result, LX1, LY1, LX2, LY2, LN, LD);
  end;

  if System.Length(APoints) > 2 then
    Result := AppendLtData(Result, NewLtSeg(LX2, LY2, LX2, LY2));
end;




//=================================================================================================
{ TUdLineType }

constructor TUdLineType.Create();
begin
  inherited;

  FByKind := bkNone;

  FName := 'Continuous';
  FComment := '';//'Solid line';

  FStatus := 0;
  System.SetLength(FValue, 0);
end;

destructor TUdLineType.Destroy;
begin
  System.SetLength(FValue, 0);
  inherited;
end;




function TUdLineType.GetTypeID: Integer;
begin
  Result := ID_LINETYPE;
end;


function TUdLineType.GetValue: TSingleArray;
begin
  Result := FValue;
end;


function TUdLineType.SegmentLength: Float;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to System.Length(FValue) - 1 do
    Result := Result + Abs(FValue[I]);
end;



//------------------------------------------------------------------

procedure TUdLineType.SetName(const AValue: string);
begin
  if (FName <> AValue) and Self.RaiseBeforeModifyObject('Name') then
  begin
    FName := AValue;
    Self.RaiseAfterModifyObject('Name');
  end;
end;


procedure TUdLineType.SetByKind(const AValue: TUdByKind);
begin
  if (FByKind <> AValue) and Self.RaiseBeforeModifyObject('ByKind') then
  begin
    FByKind := AValue;
    Self.RaiseAfterModifyObject('ByKind');
  end;
end;

procedure TUdLineType.SetComment(const AValue: string);
begin
  if (FComment <> AValue) and Self.RaiseBeforeModifyObject('Comment') then
  begin
    FComment := AValue;
    Self.RaiseAfterModifyObject('Comment');
  end;
end;


procedure TUdLineType.SetValue(const AValue: TSingleArray);
var
  I: Integer;
begin
  if Self.RaiseBeforeModifyObject('Value') then
  begin
    System.SetLength(FValue, System.Length(AValue));
    for I := 0 to System.Length(AValue) - 1 do FValue[I] := AValue[I];

    Self.RaiseAfterModifyObject('Value');
  end;
end;




//------------------------------------------------------------------

procedure TUdLineType.CopyFrom(AValue: TUdObject);
var
  I: Integer;
begin
  inherited;

  if not AValue.InheritsFrom(TUdLineType) then Exit;

  FName    := TUdLineType(AValue).FName;
  FComment := TUdLineType(AValue).FComment;
  FByKind  := TUdLineType(AValue).FByKind;
  FStatus  := TUdLineType(AValue).FStatus;

  System.SetLength(FValue, System.Length(TUdLineType(AValue).FValue));
  for I := Low(TUdLineType(AValue).FValue) to High(TUdLineType(AValue).FValue) do
    FValue[I] := TUdLineType(AValue).FValue[I];
end;

function TUdLineType.IsEqual(const AValue: TUdLineType): Boolean;
begin
  Result := False;
  if not Assigned(AValue) then Exit;

  Result := (FName = AValue.Name) and
            UdMath.IsEqual(FValue, AValue.Value);
end;




//------------------------------------------------------------------

procedure TUdLineType.SaveToStream(AStream: TStream);
var
  I, L: Integer;
begin
  inherited;

  ByteToStream(AStream, Ord(FByKind));

  StrToStream(AStream, FName);
  StrToStream(AStream, FComment);

  L := System.Length(FValue);
  IntToStream(AStream, L);
  for I := 0 to L - 1 do
    SingleToStream(AStream, FValue[I]);
end;

procedure TUdLineType.LoadFromStream(AStream: TStream);
var
  I, L: Integer;
begin
  inherited;

  FByKind  := TUdByKind(ByteFromStream(AStream));

  FName    := StrFromStream(AStream);
  FComment := StrFromStream(AStream);

  L := IntFromStream(AStream);
  System.SetLength(FValue, L);
  for I := 0 to L - 1 do
    FValue[I] := SingleFromStream(AStream);
end;




procedure TUdLineType.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I, N: Integer;
  LStr: string;
  LXmlNode: TUdXmlNode;
begin
  inherited;

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['ByKind']     := IntToStr(Ord(FByKind));
  LXmlNode.Prop['Name']     := FName;
  LXmlNode.Prop['Comment']  := FComment;

  N := System.Length(FValue) -1;
  for I := 0 to N do
  begin
    LStr := LStr + FloatToStr(FValue[I]);
    if I <> N then LStr := LStr + ',';
  end;

  LXmlNode.Prop['Value']  := LStr;
end;

procedure TUdLineType.LoadFromXml(AXmlNode: TObject);
var
  I: Integer;
  LStrs: TStringDynArray;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FByKind  := TUdByKind(StrToIntDef(LXmlNode.Prop['ByKind'], 0));
  FName    := LXmlNode.Prop['Name'];
  FComment := LXmlNode.Prop['Comment'];

  LStrs := UdUtils.StrSplit(LXmlNode.Prop['Value'], ',');
  SetLength(FValue, System.Length(LStrs));
  for I := 0 to System.Length(LStrs) - 1 do
    FValue[I] := StrToFloat(LStrs[I]);
end;

end.