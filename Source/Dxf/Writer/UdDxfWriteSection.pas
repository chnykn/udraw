{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfWriteSection;

{$I UdDefs.INC}

interface

uses
  UdHashMaps, UdDxfTypes, UdDocument, UdColor, UdDimProps;

type
  TUdDxfWriteSection = class(TObject)
  protected
    FOwner: TObject;

  protected
    function GetLinePos: Integer;
    function GetLineCount: Int64;
    
    function GetVersion(): TUdDxfVersion;
    function GetDocument(): TUdDocument;

    function GetPlotHandle: string;
    function GetGeneralHandle: string;

    function GetBlockHandles: TUdStrStrHashMap;
    function GetViewportHandles: TUdStrStrHashMap;

    procedure SetPlotHandle(const AValue: string);
    procedure SetGeneralHandle(const AValue: string);

  protected
    procedure AddRecord(ACode: Integer; AValue: string); overload;
    procedure AddRecord(ACode: Integer; AValue: Double); overload;

    function NewHandle(): string;

  protected
    property PlotHandle: string read GetPlotHandle write SetPlotHandle;
    property GeneralHandle: string  read GetGeneralHandle write SetGeneralHandle;

    property BlockHandles: TUdStrStrHashMap read GetBlockHandles;
    property ViewportHandles: TUdStrStrHashMap read GetViewportHandles;

  public
    constructor Create(AOwner: TObject);  virtual;
    destructor Destroy; override;

    procedure Execute(); virtual;

  public
    property LinePos: Integer read GetLinePos;
    property LineCount: Int64 read GetLineCount;
    property Version: TUdDxfVersion read GetVersion;
    property Document: TUdDocument  read GetDocument;

  end;



function DxfBoolToStr(AValue: Boolean): string;
function DxfFixColor(AColor: TUdColor): string;


implementation

uses
  SysUtils, UdTypes, UdDxfWriter;

type
  TFDxfWriter = class(TUdDxfWriter);



function DxfBoolToStr(AValue: Boolean): string;
begin
  if AValue then Result := '1' else Result := '0';
end;

function DxfFixColor(AColor: TUdColor): string;
begin
  if AColor.ByKind = bkByBlock then Result := '0' else
  if AColor.ByKind = bkByLayer then Result := '256' else
  Result := IntToStr(AColor.IndexColor);
end;





//============================================================================================
{ TUdDxfWriteSection }

constructor TUdDxfWriteSection.Create(AOwner: TObject);
begin
  Assert(AOwner is TUdDxfWriter);
  FOwner := AOwner;
end;

destructor TUdDxfWriteSection.Destroy;
begin

  inherited;
end;




//-----------------------------------------------------------------------------------


function TUdDxfWriteSection.GetLinePos: Integer;
begin
  Result := TFDxfWriter(FOwner).LinePos;
end;

function TUdDxfWriteSection.GetLineCount: Int64;
begin
  Result := TFDxfWriter(FOwner).LineCount;
end;


function TUdDxfWriteSection.GetVersion(): TUdDxfVersion;
begin
  Result := TFDxfWriter(FOwner).Version;
end;

function TUdDxfWriteSection.GetDocument(): TUdDocument;
begin
  Result := TFDxfWriter(FOwner).Document;
end;



function TUdDxfWriteSection.GetPlotHandle: string;
begin
  Result := TFDxfWriter(FOwner).FPlotHandle;
end;

function TUdDxfWriteSection.GetGeneralHandle: string;
begin
  Result := TFDxfWriter(FOwner).FGeneralHandle;
end;


function TUdDxfWriteSection.GetBlockHandles: TUdStrStrHashMap;
begin
  Result := TFDxfWriter(FOwner).FBlockHandles;
end;


function TUdDxfWriteSection.GetViewportHandles: TUdStrStrHashMap;
begin
  Result := TFDxfWriter(FOwner).FViewportHandles;
end;



procedure TUdDxfWriteSection.SetPlotHandle(const AValue: string);
begin
  TFDxfWriter(FOwner).FPlotHandle := AValue;
end;

procedure TUdDxfWriteSection.SetGeneralHandle(const AValue: string);
begin
  TFDxfWriter(FOwner).FGeneralHandle := AValue;
end;







//-----------------------------------------------------------------------------------

function TUdDxfWriteSection.NewHandle(): string;
begin
  Result := IntToHex(Self.Document.GetNextObjectID(), 0);
end;


procedure TUdDxfWriteSection.AddRecord(ACode: Integer; AValue: string);
begin
  TFDxfWriter(FOwner).AddRecord(ACode, AValue);
end;

procedure TUdDxfWriteSection.AddRecord(ACode: Integer; AValue: Double);
begin
  TFDxfWriter(FOwner).AddRecord(ACode, AValue);
end;



procedure TUdDxfWriteSection.Execute();
begin
  //... ...
end;


end.