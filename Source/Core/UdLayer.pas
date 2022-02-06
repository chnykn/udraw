{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLayer;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdConsts, UdTypes, UdIntfs, UdObject,
  UdColor, UdLineType, UdLineWeight;


type
  TUdLayer = class;

  TUdLayerEvent = procedure(Sender: TObject; Layer: TUdLayer) of object;
  TUdLayerAllowEvent = procedure(Sender: TObject; Layer: TUdLayer; var Allow: Boolean) of object;


  TUdLayer = class(TUdObject, IUdObjectItem)
  private
    FName: string;

    FVisible: Boolean;
    FFreeze: Boolean;
    FLock: Boolean;

    FColor: TUdColor;
    FLineType: TUdLineType;
    FLineWeight: TUdLineWeight;

    FPlot: Boolean;
    FStatus: Cardinal;

  protected
    function GetTypeID: Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    procedure SetName(const AValue: string);

    procedure SetVisible(const AValue: Boolean);
    procedure SetFreeze(const AValue: Boolean);
    procedure SetLock(const AValue: Boolean);

    procedure SetColor(const AValue: TUdColor);
    procedure SetLineType(const AValue: TUdLineType);
    procedure SetLineWeight(const AValue: TUdLineWeight);

    procedure SetPlot(const AValue: Boolean);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;


    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Name: string read FName write SetName;

    property Visible: Boolean read FVisible write SetVisible;
    property Freeze: Boolean read FFreeze write SetFreeze;
    property Lock: Boolean read FLock write SetLock;

    property Color: TUdColor read FColor write SetColor;
    property LineType: TUdLineType read FLineType write SetLineType;
    property LineWeight: TUdLineWeight read FLineWeight write SetLineWeight;

    property Plot: Boolean read FPlot write SetPlot;
    property Status: Cardinal read FStatus write FStatus;
  end;


implementation

uses
  SysUtils,
  UdStreams, UdXml, UdDocument;


//==================================================================================================
{ TUdLayer }


constructor TUdLayer.Create();
begin
  inherited;

  FName := '';

  FVisible := True;
  FFreeze := False;
  FLock := False;

  FColor := TUdColor.Create();
  FColor.ByKind := bkByLayer;
  FColor.Owner := Self;

  FLineType := TUdLineType.Create();
  FLineType.ByKind := bkByLayer;
  FLineType.Owner := Self;
  
  FLineWeight := LW_DEFAULT;
  FPlot := True;

  FStatus := 0;
end;

destructor TUdLayer.Destroy;
begin
  FColor.Free();
  FLineType.Free();

  inherited;
end;




function TUdLayer.GetTypeID: Integer;
begin
  Result := ID_LAYER;
end;

procedure TUdLayer.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

  FColor.SetDocument(Self.Document, Self.IsDocRegister);
  Self.AddDocObject(FColor, False);

  FLineType.SetDocument(Self.Document, Self.IsDocRegister);
  Self.AddDocObject(FLineType, False);
end;



//-------------------------------------------------------

procedure TUdLayer.SetName(const AValue: string);
begin
  if (FName <> AValue) and Self.RaiseBeforeModifyObject('Name') then
  begin
    FName := AValue;
    Self.RaiseAfterModifyObject('Name');
  end;
end;


procedure TUdLayer.SetVisible(const AValue: Boolean);
begin
  if (FVisible <> AValue) and Self.RaiseBeforeModifyObject('Visible') then
  begin
    FVisible := AValue;
    if Assigned(Document) then
      TUdDocument(Document).ModelSpace.Invalidate;

    Self.RaiseAfterModifyObject('Visible');
  end;
end;

procedure TUdLayer.SetFreeze(const AValue: Boolean);
begin
  if (FFreeze <> AValue) and Self.RaiseBeforeModifyObject('Freeze') then
  begin
    FFreeze := AValue;
    Self.RaiseAfterModifyObject('Freeze');
  end;
end;

procedure TUdLayer.SetLock(const AValue: Boolean);
begin
  if (FLock <> AValue) and Self.RaiseBeforeModifyObject('Lock') then
  begin
    FLock := AValue;
//    if Assigned(Document) then
//      TUdDocument(Document).ModelSpace.Invalidate;

    Self.RaiseAfterModifyObject('Lock');
  end;
end;

procedure TUdLayer.SetColor(const AValue: TUdColor);
begin
  if Assigned(AValue) and (FColor <> AValue) and Self.RaiseBeforeModifyObject('Color'{, Integer(AValue)}) then
  begin
    FColor.Assign(AValue);
    FColor.ByKind := bkByLayer;
    Self.RaiseAfterModifyObject('Color');
  end;
end;

procedure TUdLayer.SetLineType(const AValue: TUdLineType);
begin
  if Assigned(AValue) and (FLineType <> AValue) and Self.RaiseBeforeModifyObject('LineType'{, Integer(AValue)}) then
  begin
    FLineType.Assign(AValue);
    FLineType.ByKind := bkByLayer;
    Self.RaiseAfterModifyObject('LineType');
  end;
end;

procedure TUdLayer.SetLineWeight(const AValue: TUdLineWeight);
begin
  if (FLineWeight <> AValue) and Self.RaiseBeforeModifyObject('LineWeight') then
  begin
    FLineWeight := AValue;
    Self.RaiseAfterModifyObject('LineWeight');
  end;
end;


procedure TUdLayer.SetPlot(const AValue: Boolean);
begin
  if (FPlot <> AValue) and Self.RaiseBeforeModifyObject('Plot') then
  begin
    FPlot := AValue;
    Self.RaiseAfterModifyObject('Plot');
  end;
end;




procedure TUdLayer.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdLayer) then Exit; //===>>>

  FName       := TUdLayer(AValue).FName;

  FVisible    := TUdLayer(AValue).FVisible;
  FFreeze     := TUdLayer(AValue).FFreeze;
  FLock       := TUdLayer(AValue).FLock;

  FColor.Assign(TUdLayer(AValue).FColor);
  FLineType.Assign(TUdLayer(AValue).FLineType);
  FLineWeight := TUdLayer(AValue).FLineWeight;

  FPlot       := TUdLayer(AValue).FPlot;
  FStatus     := TUdLayer(AValue).FStatus;
end;



//-------------------------------------------------------

procedure TUdLayer.SaveToStream(AStream: TStream);
begin
  inherited;

  StrToStream(AStream, FName);

  BoolToStream(AStream, FVisible);
  BoolToStream(AStream, FFreeze);
  BoolToStream(AStream, FLock);

  FColor.SaveToStream(AStream);
  FLineType.SaveToStream(AStream);
  IntToStream(AStream, FLineWeight);

  BoolToStream(AStream, FPlot);
end;

procedure TUdLayer.LoadFromStream(AStream: TStream);
begin
  inherited;

  FName := StrFromStream(AStream);

  FVisible := BoolFromStream(AStream);
  FFreeze := BoolFromStream(AStream);
  FLock := BoolFromStream(AStream);

  FColor.LoadFromStream(AStream);
  FLineType.LoadFromStream(AStream);
  FLineWeight := TUdLineWeight(IntFromStream(AStream));

  FPlot := BoolFromStream(AStream);
end;



procedure TUdLayer.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Name'] := FName;

  LXmlNode.Prop['Visible'] := BoolToStr(FVisible, True);
  LXmlNode.Prop['Freeze'] := BoolToStr(FFreeze, True);
  LXmlNode.Prop['Lock'] := BoolToStr(FLock, True);

  FColor.SaveToXml(LXmlNode.Add());
  FLineType.SaveToXml(LXmlNode.Add());

  LXmlNode.Prop['LineWeight'] := IntToStr(FLineWeight);
  LXmlNode.Prop['Plot'] := BoolToStr(FPlot, True);
end;


procedure TUdLayer.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FName := LXmlNode.Prop['Name'];

  FVisible := StrToBoolDef(LXmlNode.Prop['Visible'], True);
  FFreeze  := StrToBoolDef(LXmlNode.Prop['Freeze'], False);
  FLock    := StrToBoolDef(LXmlNode.Prop['Lock'], False);

  FColor.LoadFromXml(LXmlNode.FindItem('Color'));
  FLineType.LoadFromXml(LXmlNode.FindItem('LineType'));

  FLineWeight := StrToIntDef(LXmlNode.Prop['LineWeight'], LW_DEFAULT);
  FPlot := StrToBoolDef(LXmlNode.Prop['Plot'], True);
end;



end.