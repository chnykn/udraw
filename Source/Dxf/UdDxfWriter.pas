{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfWriter;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdDocument, UdHashMaps,
  UdDxfTypes, UdDxfWriteHeader, UdDxfWriteClasses, UdDxfWriteTables,
  UdDxfWriteBlocks, UdDxfWriteEntites, UdDxfWriteObjects;


type
  TUdDxfWriter = class(TObject)
  private
    FVersion : TUdDxfVersion;
    FDocument: TUdDocument;

    FPrecision: Integer;
    FValFormat: string;    

    FTextFile : TStringList;
    FLinePos  : Integer;

  protected

    FPlotHandle: string;
    FGeneralHandle: string;

    FBlockHandles: TUdStrStrHashMap;
    FViewportHandles: TUdStrStrHashMap;    

    FHeader  : TUdDxfWriteHeader;
    FClasses : TUdDxfWriteClasses;
    FTables  : TUdDxfWriteTables;
    FBlocks  : TUdDxfWriteBlocks;
    FEntites : TUdDxfWriteEntites;
    FObjects : TUdDxfWriteObjects;


  protected
    function GetLineCount: Int64;
    procedure SetPrecision(const AValue: Integer);

    procedure AddRecord(ACode: Integer; AValue: string); overload;
    procedure AddRecord(ACode: Integer; AValue: Double); overload;

  public
    constructor Create(ADoc: TUdDocument);
    destructor Destroy; override;

    function Execute(AFileName: string): Boolean;

  public
    property LinePos : Integer read FLinePos;
    property LineCount : Int64 read GetLineCount;
//    property StreamPos: Int64 read GetStreamPos;
    property Document: TUdDocument read FDocument;

    property Header  : TUdDxfWriteHeader  read FHeader ;
    property Classes : TUdDxfWriteClasses read FClasses;
    property Tables  : TUdDxfWriteTables  read FTables ;
    property Blocks  : TUdDxfWriteBlocks  read FBlocks ;
    property Entites : TUdDxfWriteEntites read FEntites;
    property Objects : TUdDxfWriteObjects read FObjects;

    property Version  : TUdDxfVersion read FVersion  write FVersion;
    property Precision: Integer read FPrecision write SetPrecision;
  end;


implementation

uses
  SysUtils, StrUtils;


function TextSeek(var AFile: Text; APosition: Int64): Boolean;
var
  LPos64: Int64Rec absolute APosition;
  LResHi: Cardinal;
begin
  Result := False;
  with TTextRec(AFile) do
  begin
    if (Mode = fmInput) or (mode = fmInOut) then
    begin
      LResHi := LPos64.Hi;
      if (SetFilePointer(Handle, LPos64.Lo, @LResHi, FILE_BEGIN) = LPos64.Lo) and (LResHi = LPos64.Hi) then
      begin
        BufEnd := 0; // flush internal reading buffer
        BufPos := 0;
        Result := True; 
      end;
    end;
  end;
end;


//=================================================================================================
{ TUdDxfWriter }

constructor TUdDxfWriter.Create(ADoc: TUdDocument);
begin
  FDocument := ADoc;
  FVersion  := dxf2000;

  FPrecision := 6;
  FValFormat := '0.0#####';

  FHeader  := TUdDxfWriteHeader.Create(Self);
  FClasses := TUdDxfWriteClasses.Create(Self);
  FTables  := TUdDxfWriteTables.Create(Self);
  FBlocks  := TUdDxfWriteBlocks.Create(Self);
  FEntites := TUdDxfWriteEntites.Create(Self);
  FObjects := TUdDxfWriteObjects.Create(Self);


  FPlotHandle    := '';
  FGeneralHandle := '';

  FBlockHandles    := TUdStrStrHashMap.Create();
  FViewportHandles := TUdStrStrHashMap.Create();

  FTextFile := nil;
  FLinePos := 0;
end;

destructor TUdDxfWriter.Destroy;
begin
  if Assigned(FHeader)  then FHeader.Free;
  if Assigned(FClasses) then FClasses.Free;
  if Assigned(FTables)  then FTables.Free;
  if Assigned(FBlocks)  then FBlocks.Free;
  if Assigned(FEntites) then FEntites.Free;
  if Assigned(FObjects) then FObjects.Free;

  if Assigned(FBlockHandles) then FBlockHandles.Free;
  if Assigned(FViewportHandles) then FViewportHandles.Free;

  if Assigned(FTextFile) then FTextFile.Free;
  FTextFile := nil;

  inherited;
end;


procedure TUdDxfWriter.SetPrecision(const AValue: Integer);
begin
  if AValue > 0 then
  begin
    FPrecision := AValue;
    FValFormat := '0.0';
    if FPrecision > 1 then
      FValFormat := FValFormat + StrUtils.DupeString('#', FPrecision-1);
  end;
end;


function TUdDxfWriter.GetLineCount: Int64;
begin
  Result := -1;
  if Assigned(FTextFile) then Result := FTextFile.Count;
end;




//------------------------------------------------------------------------------------------

procedure TUdDxfWriter.AddRecord(ACode: Integer; AValue: string);
//const
//  LReturn: string = #13+#10;
//var
//  LCode: AnsiString;
//  LValue: AnsiString;
var
  LCode: string;
  LValue: string;
begin
  if not Assigned(FTextFile) then Exit;

//  LCode  := AnsiString('  ' + IntToStr(ACode));
//  LValue := AnsiString(AValue);
//
//  FTextFile.WriteBuffer(LCode[1], System.Length(LCode));
//  FTextFile.WriteBuffer(LReturn[1], 2);
//
//  FTextFile.WriteBuffer(LValue[1], System.Length(LValue));
//  FTextFile.WriteBuffer(LReturn[1], 2);

  LCode  := '  ' + IntToStr(ACode);
  LValue := AValue;

  FTextFile.Add(LCode);
  FTextFile.Add(LValue);

  Inc(FLinePos, 2);
end;

procedure TUdDxfWriter.AddRecord(ACode: Integer; AValue: Double);
//var
//  LCode: AnsiString;
//  LValue: AnsiString;
var
  LCode: string;
  LValue: string;
begin
//  Writeln(FTextFile, '  ' + IntToStr(ACode) {Format('%3d', [ACode])}  );
//  Writeln(FTextFile, FormatFloat(FValFormat, AValue) );

  if not Assigned(FTextFile) then Exit;

//  LCode  := AnsiString('  ' + IntToStr(ACode));
//  LValue := AnsiString( FormatFloat(FValFormat, AValue) );
//
//  FTextFile.WriteBuffer(LCode[1], System.Length(LCode));
//  FTextFile.WriteBuffer(#13#10, 2);
//
//  FTextFile.WriteBuffer(LValue[1], System.Length(LValue));
//  FTextFile.WriteBuffer(#13#10, 2);

  LCode  := '  ' + IntToStr(ACode);
  LValue := FormatFloat(FValFormat, AValue);

  FTextFile.Add(LCode);
  FTextFile.Add(LValue);
    
  Inc(FLinePos, 2);
end;

function TUdDxfWriter.Execute(AFileName: string): Boolean;
var
  LMaxId: String;
begin
  Result := False;
  if not Assigned(FDocument) then Exit;

  Result := True;
  FLinePos := 0;

  FPlotHandle    := '';
  FGeneralHandle := '';

  FBlockHandles.Clear();
  FViewportHandles.Clear();


  //AssignFile(FTextFile, AFileName);
  FTextFile := TStringList.Create();
  try
    try
      FHeader.Execute();
      FClasses.Execute();
      FTables.Execute();
      if Assigned(FDocument) then FDocument.DoProgress(5, 100);

      FBlocks.Execute();
      if Assigned(FDocument) then FDocument.DoProgress(10, 100);

      FEntites.Execute();
      FObjects.Execute();

      AddRecord(0, 'EOF');
    except
      Result := False;
    end;

    if Result then
    begin
      LMaxId := IntToStr(FDocument.GetNextObjectID());
      FTextFile[FHeader.SeedLinePos] := LMaxId;

      FTextFile.SaveToFile(AFileName);
    end;

  finally
    FTextFile.Free;
    FTextFile := nil;
    if Assigned(FDocument) then FDocument.DoProgress(-1, 100);
  end;
end;




end.