{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLineWeights;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdConsts, UdIntfs, UdObject, UdLineWeight;


type
  TUdLineWeightEvent = procedure(Sender: TObject; LineWeight: TUdLineWeight) of object;

  //*** TUdLineWeights ***//
  TUdLineWeights = class(TUdObject, IUdActiveSupport)
  private
    FActive : TUdLineWeight;
    FByLayer: TUdLineWeight;
    FByBlock: TUdLineWeight;

    FDefault: TUdLineWeight;
    FAdjustScale: Double;


    FOnSelect: TUdLineWeightEvent;

  protected
    function GetTypeID: Integer; override;

    procedure SetActive_(const AValue: TUdLineWeight);
    procedure SetByLayer(const AValue: TUdLineWeight);
    procedure SetByBlock(const AValue: TUdLineWeight);

    procedure SetDefault(const AValue: TUdLineWeight);
    procedure SetAdjustScale(const AValue: Double);


  public
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); override;
    destructor Destroy; override;

    function SetActive(AValue: TUdLineWeight): Boolean; overload;
    function SetActive(AIndex: Integer): Boolean; overload;
    function GetActiveIndex(): Integer;

    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Active : TUdLineWeight read FActive  write SetActive_;

    property ByLayer: TUdLineWeight read FByLayer write SetByLayer;
    property ByBlock: TUdLineWeight read FByBlock write SetByBlock;

    property Default: TUdLineWeight read FDefault write SetDefault;
    property AdjustScale: Double read FAdjustScale write SetAdjustScale;


    property OnSelect: TUdLineWeightEvent read FOnSelect write FOnSelect;
  end;



implementation

uses
  SysUtils, UdStreams, UdXml;

type
  TFLineWeightStatic = class(TUdLineWeightStatic);


//=================================================================================================
{ TUdLineWeights }

constructor TUdLineWeights.Create(ADocument: TUdObject; AIsDocRegister: Boolean = True);
begin
  inherited;

  FActive := LW_DEFAULT;
  FByLayer := LW_DEFAULT;
  FByBlock := LW_DEFAULT;
    
  FDefault := LW_25;
  TFLineWeightStatic(TUdLineWeightStatic).SetDefault(FDefault);

  FAdjustScale := 1.0;
  TFLineWeightStatic(TUdLineWeightStatic).SetAdjustScale(FAdjustScale);
end;

destructor TUdLineWeights.Destroy;
begin

  inherited;
end;

function TUdLineWeights.GetTypeID: Integer;
begin
  Result := ID_LINEWEIGHTS;
end;




//--------------------------------------------------------------------------------

procedure TUdLineWeights.SetActive_(const AValue: TUdLineWeight);
begin
  Self.SetActive(AValue);
end;

procedure TUdLineWeights.SetByLayer(const AValue: TUdLineWeight);
begin
  FByLayer := AValue;
  TFLineWeightStatic(TUdLineWeightStatic).SetByLayer(AValue);
end;

procedure TUdLineWeights.SetByBlock(const AValue: TUdLineWeight);
begin
  FByBlock := AValue;
  TFLineWeightStatic(TUdLineWeightStatic).SetByBlock(FByBlock);
end;



procedure TUdLineWeights.SetDefault(const AValue: TUdLineWeight);
begin
  if (AValue > 0) and Self.RaiseBeforeModifyObject('Default') then
  begin
    FDefault := AValue;
    TFLineWeightStatic(TUdLineWeightStatic).SetDefault(FDefault);

    Self.RaiseAfterModifyObject('Default');
  end;
end;

procedure TUdLineWeights.SetAdjustScale(const AValue: Double);
begin
  if (AValue > 0) and Self.RaiseBeforeModifyObject('AdjustScale') then
  begin
    FAdjustScale := AValue;
    TFLineWeightStatic(TUdLineWeightStatic).SetAdjustScale(FAdjustScale);

    Self.RaiseAfterModifyObject('AdjustScale');
  end;  
end;




//--------------------------------------------------------------------------------

function TUdLineWeights.SetActive(AValue: TUdLineWeight): Boolean;
begin
  Result := False;
  if (FActive <> AValue) and Self.RaiseBeforeModifyObject('Active') then
  begin
    FActive := AValue;
    if Assigned(FOnSelect) then FOnSelect(Self, FActive);

    Self.RaiseAfterModifyObject('Active');
    Result := True;
  end;
end;


function TUdLineWeights.SetActive(AIndex: Integer): Boolean;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= Length(ALL_LINE_WEIGHTS)) then Exit;

  Self.SetActive(ALL_LINE_WEIGHTS[AIndex]);
end;

function TUdLineWeights.GetActiveIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(ALL_LINE_WEIGHTS) - 1 do
  begin
    if ALL_LINE_WEIGHTS[I] = FActive then
    begin
      Result := I;
      Break;
    end;
  end;
end;



procedure TUdLineWeights.SaveToStream(AStream: TStream);
begin
  inherited;

  IntToStream(AStream, FActive);
  IntToStream(AStream, FDefault);
  FloatToStream(AStream, FAdjustScale);
end;


procedure TUdLineWeights.LoadFromStream(AStream: TStream);
begin
  inherited;
  
  FActive  := TUdLineWeight( IntFromStream(AStream) );
  FDefault := TUdLineWeight( IntFromStream(AStream) );
  FAdjustScale  := FloatFromStream(AStream);

  TFLineWeightStatic(TUdLineWeightStatic).SetDefault(FDefault);
end;





procedure TUdLineWeights.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Active'] := IntToStr(FActive);
  LXmlNode.Prop['Default'] := IntToStr(FDefault);
  LXmlNode.Prop['AdjustScale'] := FloatToStr(FAdjustScale);
end;

procedure TUdLineWeights.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FActive  := StrToIntDef(LXmlNode.Prop['Active'], LW_DEFAULT);
  FDefault := StrToIntDef(LXmlNode.Prop['DefaultWidth'], LW_25);
  FAdjustScale  := StrToFloatDef(LXmlNode.Prop['AdjustScale'], 1.0);

  TFLineWeightStatic(TUdLineWeightStatic).SetDefault(FDefault);  
end;


end.