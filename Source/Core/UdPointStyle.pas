{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPointStyle;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdConsts, UdTypes, UdObject;

type

  TUdPointStyle = class(TUdObject)
  private
    FSize: Float;
    FStates: TUdPointStates;
    FDrawingUnits: Boolean;

    FOnChanged: TNotifyEvent;

  protected
    function GetTypeID: Integer; override;

    procedure SetSize(const AValue: Float);
    procedure SetStates(const AValue: TUdPointStates);
    procedure SetDrawingUnits(const AValue: Boolean);

    function GetMode: Integer;
    procedure SetMode(const AValue: Integer);

    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;

  public
    constructor Create(); override;
    destructor Destroy; override;

    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Size: Float read FSize write SetSize;
    property States: TUdPointStates read FStates write SetStates;
    property DrawingUnits: Boolean read FDrawingUnits write SetDrawingUnits;

    property Mode: Integer read GetMode write SetMode;
  end;

implementation

uses
  SysUtils,
  UdStreams, UdXml;

{ TUdPointStyle }

constructor TUdPointStyle.Create();
begin
  inherited;
  FSize := 8.0;
  FStates := [psCross];
  FDrawingUnits := False;
end;

destructor TUdPointStyle.Destroy;
begin

  inherited;
end;



function TUdPointStyle.GetTypeID: Integer;
begin
  Result := ID_POINTSTYLE;
end;

function FGetMode(AStates: TUdPointStates): Integer;
begin
  Result := 1;
  if psPoint  in AStates then Result := 0 else
  if psCross  in AStates then Result := 2 else
  if psXCross in AStates then Result := 3 else
  if psLine   in AStates then Result := 4;

  if psCircle in AStates then Result := Result + 32;
  if psRect   in AStates then Result := Result + 64;
end;




procedure TUdPointStyle.SetSize(const AValue: Float);
begin
  if (FSize <> AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('Size') then
  begin
    FSize := AValue;
    Self.RaiseAfterModifyObject('Size');
    if Assigned(FOnChanged) then FOnChanged(Self);
  end;
end;

procedure TUdPointStyle.SetStates(const AValue: TUdPointStates);
begin
  if (FStates <> AValue) and Self.RaiseBeforeModifyObject('States'{, FGetMode(AValue)}) then
  begin
    FStates := AValue;
    Self.RaiseAfterModifyObject('States');
    if Assigned(FOnChanged) then FOnChanged(Self);
  end;
end;


procedure TUdPointStyle.SetDrawingUnits(const AValue: Boolean);
begin
  if (FDrawingUnits <> AValue) and Self.RaiseBeforeModifyObject('DrawingUnits') then
  begin
    FDrawingUnits := AValue;
    Self.RaiseAfterModifyObject('DrawingUnits');
    if Assigned(FOnChanged) then FOnChanged(Self);
  end;
end;




function TUdPointStyle.GetMode: Integer;
begin
  Result := FGetMode(FStates);
end;


procedure TUdPointStyle.SetMode(const AValue: Integer);
var
  N: Integer;
begin
  N := AValue mod 32;
  case N of
    0: FStates := [psPoint];
    1: FStates := [];
    2: FStates := [psCross];
    3: FStates := [psXCross];
    4: FStates := [psLine];
  end;

  N := AValue div 32;
  if (N and 1) > 0 then Include(FStates, psCircle);
  if (N and 2) > 0 then Include(FStates, psRect);
end;





procedure TUdPointStyle.SaveToStream(AStream: TStream);
var
  I, N: Integer;
begin
  inherited;

  FloatToStream(AStream, FSize);

  N := 0;
  for I := Ord(psPoint) to Ord(psXCross) do
  begin
    if TUdPointState(I) in FStates then
      N := N or (1 shl I);
  end;
  IntToStream(AStream, N);

  BoolToStream(AStream, FDrawingUnits);
end;


procedure TUdPointStyle.LoadFromStream(AStream: TStream);
var
  I, N: Integer;
begin
  inherited;

  FSize := FloatFromStream(AStream);

  FStates := [];

  N := IntFromStream(AStream);
  for I := Ord(psPoint) to Ord(psXCross) do
  begin
    if N and (1 shl I) > 0 then
      FStates := FStates + [TUdPointState(I)];
  end;

  FDrawingUnits := BoolFromStream(AStream);
end;



procedure TUdPointStyle.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I, N: Integer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  N := 0;
  for I := Ord(psPoint) to Ord(psXCross) do
  begin
    if TUdPointState(I) in FStates then
      N := N or (1 shl I);
  end;

  LXmlNode.Prop['Size']    := FloatToStr(FSize);
  LXmlNode.Prop['States']  := IntToStr(N);

  LXmlNode.Prop['DrawingUnits']  := BoolToStr(FDrawingUnits, True);
end;

procedure TUdPointStyle.LoadFromXml(AXmlNode: TObject);
var
  I, N: Integer;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FSize := StrToFloatDef(LXmlNode.Prop['Size'], 16.0);
  FDrawingUnits := StrToBoolDef(LXmlNode.Prop['DrawingUnits'], False);


  FStates := [];

  N := StrToIntDef(LXmlNode.Prop['States'], 0);
  for I := Ord(psPoint) to Ord(psXCross) do
  begin
    if N and (1 shl I) > 0 then
      FStates := FStates + [TUdPointState(I)];
  end;
end;



end.