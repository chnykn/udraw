{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfReader;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,

  UdDxfTypes, UdDxfReadHeader, UdDxfReadClasses, UdDxfReadTables,
  UdDxfReadBlocks, UdDxfReadEntites, UdDxfReadObjects,

  UdDocument, UdHashMaps, UdLayout, UdEntities, UdDimProps;


type
  TUdDxfReader = class(TObject)
  protected
    FVersion    : Integer;
    FDocument   : TUdDocument;

    FIsUtf8     : Boolean;
    FRecStep    : Integer;
    FRecCount   : Integer;

    FTextFile   : TextFile;
    FLinePos    : Integer;
    FCurrRecord : TUdDxfRecord;

    FHeader  : TUdDxfReadHeader;
    FClasses : TUdDxfReadClasses;
    FTables  : TUdDxfReadTables;
    FBlocks  : TUdDxfReadBlocks;
    FEntites : TUdDxfReadEntites;
    FObjects : TUdDxfReadObjects;

    FLayoutRecs: TList;
    FBlockNames: TUdStrStrHashMap;

  protected
    function GetVersion: string;

    function ReadRecord(): TUdDxfRecord;
    function FindNextSection(): TUdDxfSectionKind;

    procedure ReadCurrentRecord();
    
    procedure SetDimStyleArrow();

  public
    constructor Create(ADoc: TUdDocument);
    destructor Destroy; override;

    function Execute(AFileName: string): Boolean;

    function GetLayoutRec(ABlockHandle: string): PUdDxfLayoutRec; overload;
    function GetLayoutRec(ALayout: TUdLayout): PUdDxfLayoutRec; overload;
    
    function GetLayout(ABlockHandle: string): TUdLayout;
    function GetLayoutEntities(ABlockHandle: string): TUdEntities;    

    function GetArrowKind(ABlockHandle: string): TUdDimArrowKind;

  public
    property Document   : TUdDocument read FDocument;
    property CurrRecord : TUdDxfRecord read FCurrRecord;

    property Header     : TUdDxfReadHeader  read FHeader ;
    property Classes    : TUdDxfReadClasses read FClasses;
    property Tables     : TUdDxfReadTables  read FTables ;
    property Blocks     : TUdDxfReadBlocks  read FBlocks ;
    property Entites    : TUdDxfReadEntites read FEntites;
    property Objects    : TUdDxfReadObjects read FObjects;

    property LinePos    : Integer read FLinePos;
    property Version    : string  read GetVersion;

    property LayoutRecs : TList read FLayoutRecs;         // [PUdDxfLayoutRec  ....]
    property BlockNames : TUdStrStrHashMap read FBlockNames;// [BlockHandle: BlockName  ....]
  end;


implementation

uses
  SysUtils, UdColor, UdDimStyle, UdUtils;


//=================================================================================================
{ TUdDxfReader }

constructor TUdDxfReader.Create(ADoc: TUdDocument);
begin
  FDocument := ADoc;

  FLinePos := 0;
  FCurrRecord.Code  := 0;
  FCurrRecord.Value := #0;

  FHeader  := TUdDxfReadHeader.Create(Self);
  FClasses := TUdDxfReadClasses.Create(Self);
  FTables  := TUdDxfReadTables.Create(Self);
  FBlocks  := TUdDxfReadBlocks.Create(Self);
  FEntites := TUdDxfReadEntites.Create(Self);
  FObjects := TUdDxfReadObjects.Create(Self);

  FLayoutRecs := TList.Create();
  FBlockNames := TUdStrStrHashMap.Create();
end;

destructor TUdDxfReader.Destroy;
var
  I: Integer;
begin
  for I := FLayoutRecs.Count - 1 downto 0 do Dispose(PUdDxfLayoutRec(FLayoutRecs[I]));
  if Assigned(FLayoutRecs)  then FLayoutRecs.Free;
  
  if Assigned(FBlockNames) then FBlockNames.Free;
  
  if Assigned(FHeader)  then FHeader.Free;
  if Assigned(FClasses) then FClasses.Free;
  if Assigned(FTables)  then FTables.Free;
  if Assigned(FBlocks)  then FBlocks.Free;
  if Assigned(FEntites) then FEntites.Free;
  if Assigned(FObjects) then FObjects.Free;

  inherited;
end;



function TUdDxfReader.GetVersion: string;
begin
  Result := FHeader.DxfVer;
end;



function TUdDxfReader.GetLayoutRec(ALayout: TUdLayout): PUdDxfLayoutRec;
var
  I: Integer;
begin
  Result := nil;
  
  for I := 0 to FLayoutRecs.Count - 1 do
  begin
    if PUdDxfLayoutRec(FLayoutRecs[I])^.Layout = ALayout then
    begin
      Result := PUdDxfLayoutRec(FLayoutRecs[I]);
      Break;
    end;
  end;
end;

function TUdDxfReader.GetLayoutRec(ABlockHandle: string): PUdDxfLayoutRec;
var
  I: Integer;
begin
  Result := nil;
  
  for I := 0 to FLayoutRecs.Count - 1 do
  begin
    if PUdDxfLayoutRec(FLayoutRecs[I])^.BlockHandle = ABlockHandle then
    begin
      Result := PUdDxfLayoutRec(FLayoutRecs[I]);
      Break;
    end;
  end;
end;

function TUdDxfReader.GetLayout(ABlockHandle: string): TUdLayout;
var
  LRec: PUdDxfLayoutRec;
begin
  Result := nil;
  LRec := Self.GetLayoutRec(ABlockHandle);
  if Assigned(LRec) then Result := TUdLayout(LRec.Layout);
end;

function TUdDxfReader.GetLayoutEntities(ABlockHandle: string): TUdEntities;
var
  LLayout: TUdLayout;
begin
  Result := nil;
  LLayout := Self.GetLayout(ABlockHandle);
  if Assigned(LLayout) then Result := LLayout.Entities;
end;





function TUdDxfReader.GetArrowKind(ABlockHandle: string): TUdDimArrowKind;
var
  LInt: Integer;
  LBlkName: string;
begin
  Result := dakClosedFilled;
  
  LBlkName := FBlockNames.GetValue(ABlockHandle);
  if LBlkName = '' then Exit;

  LInt := 0;
  //if LBlkName = '_CLOSEDFILLED' then LInt := 0  else
  if LBlkName = '_CLOSEDBLANK'  then LInt := 1  else
  if LBlkName = '_CLOSED'       then LInt := 2  else
  if LBlkName = '_DOT'          then LInt := 3  else
  if LBlkName = '_ARCHTICK'     then LInt := 4  else
  if LBlkName = '_OBLIQUE'      then LInt := 5  else
  if LBlkName = '_OPEN'         then LInt := 6  else
  if LBlkName = '_ORIGIN'       then LInt := 7  else
  if LBlkName = '_ORIGIN2'      then LInt := 8  else
  if LBlkName = '_OPEN90'       then LInt := 9  else
  if LBlkName = '_OPEN30'       then LInt := 10 else
  if LBlkName = '_DOTSMALL'     then LInt := 11 else
  if LBlkName = '_DotBlank'     then LInt := 12 else
  if LBlkName = '_SMALL'        then LInt := 13 else
  if LBlkName = '_BOXBLANK'     then LInt := 14 else
  if LBlkName = '_BOXFILLED'    then LInt := 15 else
  if LBlkName = '_DATUMBLANK'   then LInt := 16 else
  if LBlkName = '_DATUMFILLED'  then LInt := 17 else
  if LBlkName = '_INTEGRAL'     then LInt := 18 else
  if LBlkName = '_NONE'         then LInt := 19;// else

  Result := TUdDimArrowKind(LInt);
end;                            



procedure TUdDxfReader.SetDimStyleArrow;
var
  I: Integer;
  LRec: TUdDimStyleArrow;
begin
  for I := 0 to Length(FTables.DimStyleArrows) - 1 do
  begin
    LRec := FTables.DimStyleArrows[I];
    if not Assigned(LRec.DimStyle) or not LRec.DimStyle.InheritsFrom(TUdDimStyle) then Continue;

    with TUdDimStyle(LRec.DimStyle).ArrowsProp do
    begin
      ArrowLeader := GetArrowKind(LRec.BlockLeader);
      ArrowFirst  := GetArrowKind(LRec.BlockFirst );
      ArrowSecond := GetArrowKind(LRec.BlockSecond);
    end;
  end;
end;




//------------------------------------------------------------------------------------------


function TUdDxfReader.ReadRecord(): TUdDxfRecord;
var
  LCodeStr: string;
  LCode: Integer;
  LRawStr: {$IF COMPILERVERSION >= 21.0 }RawByteString{$ELSE} UTF8String{$IFEND};
  LValue: string;
begin
  if Eof(FTextFile) then
  begin
    Result.Code := 0;
    Result.Value := 'EOF';
    Exit; //==========>>>>>
  end;

  Readln(FTextFile, LCodeStr);
  LCodeStr := Trim(LCodeStr);
  if not TryStrToInt(LCodeStr, LCode) then LCode := -1;
  Result.Code := LCode;


  Readln(FTextFile, LRawStr);

  if FIsUtf8 then
  begin
  {$IF COMPILERVERSION >= 21.0 } { Delphi 2010 and above }
    LValue := UTF8ToString(LRawStr)
  {$ELSE}
    LValue := Utf8ToAnsi(LRawStr)
  {$IFEND}
  end
  else begin
    LValue := string(LRawStr);
  end;

  Result.Value := LValue;
  Inc(FLinePos, 2);

  if Assigned(FDocument) then
  begin
    if FLinePos >= FRecStep then
    begin
      FDocument.DoProgress(FLinePos, FRecCount);
      FRecStep := FRecStep + FRecCount div 20;
    end;
  end;
end;

function TUdDxfReader.FindNextSection(): TUdDxfSectionKind;
var
  LRecord: TUdDxfRecord;
begin
  while not EOF(FTextFile) do
  begin
    LRecord := Self.ReadRecord();
    if (LRecord.Code = 0)  then
    begin
      if (LRecord.Value = 'SECTION') then
      begin
        LRecord := Self.ReadRecord();
        if LRecord.Value = 'HEADER'   then Result := dsHeader   else
        if LRecord.Value = 'CLASSES'  then Result := dsClasses  else
        if LRecord.Value = 'TABLES'   then Result := dsTables   else
        if LRecord.Value = 'BLOCKS'   then Result := dsBlocks   else
        if LRecord.Value = 'ENTITIES' then Result := dsEntities else
        if LRecord.Value = 'OBJECTS'  then Result := dsObjects  else
        Result := dsUnknown;

        Exit; //=======>>>>
      end
      else if (LRecord.Value = 'EOF') then
      begin
        Result := dsEndOfFile;
        Exit; //=======>>>>
      end;
    end
  end;

  Result := dsEndOfFile;
end;


procedure TUdDxfReader.ReadCurrentRecord();
begin
  FCurrRecord := Self.ReadRecord();
//  if FCurrRecord.Code = 100 then
//    FCurrRecord := Self.ReadRecord();
end;



//------------------------------------------------------------------------------------------

function TUdDxfReader.Execute(AFileName: string): Boolean;
var
  I: Integer;
  LStrs: TStringList;
  LSection: TUdDxfSectionKind;
begin
  Result := False;
  if not Assigned(Self.Document) or not SysUtils.FileExists(AFileName) then Exit;

  FIsUtf8 := UdUtils.IsUTF8File(AFileName);

  AssignFile(FTextFile, AFileName);
  try
    Reset(FTextFile);
  except
    Exit;   // Exit on failure  ==========>>>>>>
  end;

  LStrs := TStringList.Create;
  try
    LStrs.LoadFromFile(AFileName);
    FRecCount := LStrs.Count;
    FRecStep := FRecCount div 20;
  finally
    LStrs.Free;
  end;

  Self.Document.Clear();

  for I := FLayoutRecs.Count - 1 downto 0 do Dispose(PUdDxfLayoutRec(FLayoutRecs[I]));  
  FLayoutRecs.Clear();
  
  FBlockNames.Clear();

  FLinePos := 0;
  try
    LSection := Self.FindNextSection();
    while (LSection <> dsEndOfFile) do
    begin
      case LSection of
        dsHeader    : FHeader.Execute();
        dsClasses   : FClasses.Execute();
        dsTables    : FTables.Execute();
        dsBlocks    : FBlocks.Execute();
        dsEntities  : FEntites.Execute();
        dsObjects   : FObjects.Execute();
        else begin
					Self.ReadCurrentRecord();
					while (FCurrRecord.Value <> 'ENDSEC') do
          begin
            Self.ReadCurrentRecord();
            if (FCurrRecord.Value = 'EOF') then Break;
          end;
        end;
      end;

      LSection := Self.FindNextSection();
    end;
  finally
    CloseFile(FTextFile);
    if Assigned(FDocument) then
      FDocument.DoProgress(-1, FRecCount);
  end;

  Self.SetDimStyleArrow();
  
  Self.Document.DimStyles.SetActive( FHeader.ActiveDimStyle );
  Self.Document.LineTypes.SetActive( FHeader.ActiveLineType );
  Self.Document.TextStyles.SetActive( FHeader.ActiveTextStyle );
  Self.Document.Layers.SetActive( FHeader.ActiveLayer );
  Self.Document.LineWeights.SetActive( FHeader.ActiveLineWeight );

  case FHeader.ActiveColor of
    0  : Self.Document.Colors.SetActive( Self.Document.Colors.ByBlock );
    256: Self.Document.Colors.SetActive( Self.Document.Colors.ByLayer );
    else Self.Document.Colors.SetActive( FHeader.ActiveColor, ctIndexColor );
  end;

  Result := True;
end;








end.