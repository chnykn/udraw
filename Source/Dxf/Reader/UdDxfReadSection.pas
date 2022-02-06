{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfReadSection;

{$I UdDefs.INC}

interface

uses
  UdTypes, UdDocument, UdColor, UdDxfTypes;

type
  TUdDxfReadSection = class(TObject)
  protected
    FOwner: TObject;

  protected
    function GetLinePos: Integer;

    function GetDocument: TUdDocument;
    function GetCurrRecord: TUdDxfRecord;

    function ReadRecord(): TUdDxfRecord;
    procedure ReadCurrentRecord();

    procedure AddDxfLayout(ABlockHandle, ALayoutHandle: string; ALayout: TObject);
    procedure AddBlockName(ABlockHandle, ABlockName: string);

  public
    constructor Create(AOwner: TObject);  virtual;
    destructor Destroy; override;

    procedure Execute(); virtual;

  public
    property LinePos: Integer read GetLinePos;
    property Document: TUdDocument read GetDocument;
    property CurrRecord: TUdDxfRecord read GetCurrRecord;

  end;



procedure SetDxfColor(ADoc: TObject; AColor: TUdColor; AValue: string); //  0 = Ëæ¿é£»256 = Ëæ²ã

implementation

uses
  SysUtils, UdDxfReader;


type
  TFDxfReader = class(TUdDxfReader);




//============================================================================================

procedure SetDxfColor(ADoc: TObject; AColor: TUdColor; AValue: string); //  0 = Ëæ¿é£»256 = Ëæ²ã
var
  N: Integer;
begin
  N := StrToIntDef(AValue, 256);
  if (N < 0) or (N > 256) then Exit;

  if N = 0   then AColor.ByKind := bkByBlock else
  if N = 256 then AColor.ByKind := bkByLayer else
  begin
    AColor.ByKind := bkNone;
    AColor.ColorType := ctIndexColor;
    AColor.IndexColor := N;

    if Assigned(ADoc) then
      TUdDocument(ADoc).Colors.Add(TUdIndexColor(N));
  end;
end;







//============================================================================================
{ TUdDxfReadSection }


constructor TUdDxfReadSection.Create(AOwner: TObject);
begin
  Assert(AOwner is TUdDxfReader);
  FOwner := AOwner;
end;

destructor TUdDxfReadSection.Destroy;
begin

  inherited;
end;




procedure TUdDxfReadSection.AddDxfLayout(ABlockHandle, ALayoutHandle: string; ALayout: TObject);
var
  LRec: PUdDxfLayoutRec;
begin
  LRec := New(PUdDxfLayoutRec);
  InitDxfLayoutRec(LRec^);

  LRec^.BlockHandle := ABlockHandle;
  LRec^.Handle := ALayoutHandle;
  LRec^.Layout := ALayout;
  TUdDxfReader(FOwner).LayoutRecs.Add(LRec);
end;

procedure TUdDxfReadSection.AddBlockName(ABlockHandle, ABlockName: string);
begin
  TUdDxfReader(FOwner).BlockNames.Add(ABlockHandle, ABlockName);
end;



//-----------------------------------------------------------------------------------

function TUdDxfReadSection.GetLinePos: Integer;
begin
  Result := TFDxfReader(FOwner).LinePos;
end;

function TUdDxfReadSection.GetDocument: TUdDocument;
begin
  Result := TFDxfReader(FOwner).Document;
end;

function TUdDxfReadSection.GetCurrRecord: TUdDxfRecord;
begin
  Result := TFDxfReader(FOwner).CurrRecord;
end;



function TUdDxfReadSection.ReadRecord: TUdDxfRecord;
begin
  Result := TFDxfReader(FOwner).ReadRecord();
end;

procedure TUdDxfReadSection.ReadCurrentRecord();
begin
  TFDxfReader(FOwner).ReadCurrentRecord();
end;




//-----------------------------------------------------------------------------------

procedure TUdDxfReadSection.Execute();
var
  LRecord: TUdDxfRecord;
begin
  LRecord := Self.ReadRecord();
  repeat
    //... ...
    LRecord := Self.ReadRecord();
  until (LRecord.Value = 'ENDSEC') or (LRecord.Value = 'EOF');
end;







end.