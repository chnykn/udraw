{
  This file is part of the DelphiCAD SDK

  Copyright:
  (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPatternLines;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdGTypes, UdPatternLine;

type
  TUdPatternLines = class(TPersistent)
  private
    FList: TList;

  protected
    function GetCount: Integer;

  public
    constructor Create();
    destructor Destroy(); override;


    procedure Clear();
    procedure Assign(Source: TPersistent); override;

    procedure Scale(AScale: Float);

    function IndexOf(AObject: TUdPatternLine): Integer;

    function Add(AObject: TUdPatternLine): Boolean;  overload;
    function Add(AAngle: Float; AOriginX, AOriginY: Float; AOffsetX, AOffsetY: Float; ADashes: array of Float): Boolean;  overload;

    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AObject: TUdPatternLine): Boolean; overload;

    function GetItem(AIndex: Integer): TUdPatternLine;


    function CalcHatchSegments(ASegarcs: TSegarc2DArray; var ASegmentList: TList; AScale: Float = 1.0; ARotation: Float = 0.0): Boolean; overload;
    function CalcHatchSegments(ASegarcs: TSegarc2DArray; AScale: Float = 1.0; ARotation: Float = 0.0): TSegment2DArray; overload;

    function CalcHatchSegments(ASegarcsArray: TSegarc2DArrays; var ASegmentList: TList; AScale: Float = 1.0; ARotation: Float = 0.0): Boolean; overload;
    function CalcHatchSegments(ASegarcsArray: TSegarc2DArrays; AScale: Float = 1.0; ARotation: Float = 0.0): TSegment2DArray; overload;

  public
    property Items[Index: Integer]: TUdPatternLine read GetItem;

  published
    property Count: Integer read GetCount;

  end;

implementation

uses
  UdUtils;



// =================================================================================================
{ TUdPatternLines }

constructor TUdPatternLines.Create;
begin
  FList := TList.Create();
end;

destructor TUdPatternLines.Destroy;
begin
  UdUtils.ClearObjectList(FList);
  FList.Free;

  inherited;
end;




procedure TUdPatternLines.Clear;
begin
  UdUtils.ClearObjectList(FList);
end;



procedure TUdPatternLines.Assign(Source: TPersistent);
var
  I: Integer;
  LSrcItem, LDstItem: TUdPatternLine;
begin
  if Source.InheritsFrom(TUdPatternLines) then
  begin
    Self.Clear();

    for I := 0 to TUdPatternLines(Source).FList.Count - 1 do
    begin
      LSrcItem := TUdPatternLine(TUdPatternLines(Source).FList.Items[I]);

      LDstItem := TUdPatternLine.Create();
      LDstItem.Assign(LSrcItem);
      Self.Add(LDstItem);
    end;
  end
  else inherited;
end;


procedure TUdPatternLines.Scale(AScale: Float);
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TUdPatternLine(FList.Items[I]).Scale(AScale);
end;


function TUdPatternLines.IndexOf(AObject: TUdPatternLine): Integer;
begin
  Result := FList.IndexOf(AObject);
end;


function TUdPatternLines.Add(AObject: TUdPatternLine): Boolean;
begin
  Result := False;
  if not Assigned(AObject) or (FList.IndexOf(AObject) >= 0)  then Exit;

  FList.Add(AObject);

  Result := True;
end;


function TUdPatternLines.Add(AAngle: Float; AOriginX, AOriginY: Float; AOffsetX, AOffsetY: Float;
  ADashes: array of Float): Boolean;
begin
  Result := Self.Add(TUdPatternLine.Create(AAngle, AOriginX, AOriginY, AOffsetX, AOffsetY, ADashes));
end;


function TUdPatternLines.Remove(AIndex: Integer): Boolean;
var
  LPatternLine: TUdPatternLine;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  LPatternLine := TUdPatternLine(FList.Items[AIndex]);

  LPatternLine.Free;
  FList.Delete(AIndex);

  Result := True;
end;

function TUdPatternLines.Remove(AObject: TUdPatternLine): Boolean;
begin
  Result := Remove(IndexOf(AObject));
end;


function TUdPatternLines.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TUdPatternLines.GetItem(AIndex: Integer): TUdPatternLine;
begin
  Result := nil;
  if (AIndex >= 0) and (AIndex < FList.Count) then
    Result := TUdPatternLine(FList.Items[AIndex]);
end;




function TUdPatternLines.CalcHatchSegments(ASegarcs: TSegarc2DArray; var ASegmentList: TList; AScale: Float = 1.0; ARotation: Float = 0.0): Boolean;
var
  I: Integer;
  LPatternLine: TUdPatternLine;
begin
  Result := False;
  if (System.Length(ASegarcs) <= 0) or not Assigned(ASegmentList) then Exit;

  for I := 0 to FList.Count - 1 do
  begin
    LPatternLine := TUdPatternLine(FList[I]);
    LPatternLine.CalcHatchSegments(ASegarcs, ASegmentList, AScale, ARotation);
  end;

  Result := ASegmentList.Count > 0;
end;

function TUdPatternLines.CalcHatchSegments(ASegarcs: TSegarc2DArray; AScale: Float = 1.0; ARotation: Float = 0.0): TSegment2DArray;
var
  I: Integer;
  LSegmentList: TList;
begin
  Result := nil;
  if System.Length(ASegarcs) <= 0 then Exit;

  LSegmentList := TList.Create;
  try
    if Self.CalcHatchSegments(ASegarcs, LSegmentList, AScale, ARotation) then
    begin
      System.SetLength(Result, LSegmentList.Count);
      for I := 0 to LSegmentList.Count - 1 do Result[I] := PSegment2D(LSegmentList[I])^;
    end;
  finally
    for I := LSegmentList.Count - 1 downto 0 do Dispose(PSegment2D(LSegmentList[I]));
    LSegmentList.Free;
  end;
end;




function TUdPatternLines.CalcHatchSegments(ASegarcsArray: TSegarc2DArrays; var ASegmentList: TList; AScale: Float = 1.0; ARotation: Float = 0.0): Boolean;
var
  I: Integer;
  LPatternLine: TUdPatternLine;
begin
  Result := False;
  if (System.Length(ASegarcsArray) <= 0) or not Assigned(ASegmentList) then Exit;

  for I := 0 to FList.Count - 1 do
  begin
    LPatternLine := TUdPatternLine(FList[I]);
    LPatternLine.CalcHatchSegments(ASegarcsArray, ASegmentList, AScale, ARotation);
  end;

  Result := ASegmentList.Count > 0;
end;

function TUdPatternLines.CalcHatchSegments(ASegarcsArray: TSegarc2DArrays; AScale: Float = 1.0; ARotation: Float = 0.0): TSegment2DArray;
var
  I: Integer;
  LSegmentList: TList;
begin
  Result := nil;
  if System.Length(ASegarcsArray) <= 0 then Exit;

  LSegmentList := TList.Create;
  try
    if Self.CalcHatchSegments(ASegarcsArray, LSegmentList, AScale, ARotation) then
    begin
      System.SetLength(Result, LSegmentList.Count);
      for I := 0 to LSegmentList.Count - 1 do Result[I] := PSegment2D(LSegmentList[I])^;
    end;
  finally
    for I := LSegmentList.Count - 1 downto 0 do Dispose(PSegment2D(LSegmentList[I]));
    LSegmentList.Free;
  end;
end;




end.