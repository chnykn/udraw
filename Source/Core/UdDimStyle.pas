{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimStyle;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdConsts, UdIntfs, UdObject, UdDimProps;

type
  TUdDimStyle = class;

  TUdDimStyleEvent = procedure(Sender: TObject; DimStyle: TUdDimStyle) of object;
  TUdDimStyleAllowEvent = procedure(Sender: TObject; DimStyle: TUdDimStyle; var Allow: Boolean) of object;



  //*** TUdDimStyle ***//
  TUdDimStyle = class(TUdObject, IUdObjectItem)
  private
    FName: string;
    FDescription: string;

    FBestFit: Boolean;
    FOverallScale: Float;


    FLinesProp  : TUdDimLinesProp;
    FArrowsProp : TUdDimSymbolArrowsProp;
    FTextProp   : TUdDimTextProp;
    FUnitsProp  : TUdDimUnitsProp;
    FAltUnitsProp: TUdDimAltUnitsProp;

    FDispAltUnits: Boolean;

    FStatus: Cardinal;

  protected
    function GetTypeID: Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    procedure SetBestFit(const AValue: Boolean);
    procedure SetOverallScale(const AValue: Float);
    procedure SetDispAltUnits(const AValue: Boolean);

    procedure OnPropChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
    procedure OnPropChanged(Sender: TObject; APropName: string);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Name        : string  read FName         write FName       ;
    property Description : string  read FDescription  write FDescription;

    property BestFit     : Boolean read FBestFit      write SetBestFit;
    property OverallScale: Float   read FOverallScale write SetOverallScale;

    property LinesProp    : TUdDimLinesProp        read FLinesProp   write FLinesProp ;
    property ArrowsProp   : TUdDimSymbolArrowsProp read FArrowsProp  write FArrowsProp;
    property TextProp     : TUdDimTextProp         read FTextProp    write FTextProp  ;
    property UnitsProp    : TUdDimUnitsProp        read FUnitsProp   write FUnitsProp  ;
    property AltUnitsProp : TUdDimAltUnitsProp     read FAltUnitsProp  write FAltUnitsProp;

    property DispAltUnits : Boolean read FDispAltUnits write SetDispAltUnits;

    property Status: Cardinal read FStatus write FStatus;
  end;


implementation

uses
  SysUtils,
  UdStreams, UdXml;

{ TUdDimStyle }

constructor TUdDimStyle.Create();
begin
  inherited;

  FName := '';
  FDescription := '';

  FBestFit := True;
  FOverallScale := 1.0;

  FDispAltUnits := False;

  FLinesProp    := TUdDimLinesProp.Create();
  FArrowsProp   := TUdDimSymbolArrowsProp.Create();
  FTextProp     := TUdDimTextProp.Create();
  FUnitsProp    := TUdDimUnitsProp.Create();
  FAltUnitsProp := TUdDimAltUnitsProp.Create();

  FLinesProp.Owner := Self;
  FArrowsProp.Owner := Self;
  FTextProp.Owner := Self;
  FUnitsProp.Owner := Self;
  FAltUnitsProp.Owner := Self;

  FLinesProp.OnChanging    := OnPropChanging;
  FArrowsProp.OnChanging   := OnPropChanging;
  FTextProp.OnChanging     := OnPropChanging;
  FUnitsProp.OnChanging    := OnPropChanging;
  FAltUnitsProp.OnChanging := OnPropChanging;

  FLinesProp.OnChanged    := OnPropChanged;
  FArrowsProp.OnChanged   := OnPropChanged;
  FTextProp.OnChanged     := OnPropChanged;
  FUnitsProp.OnChanged    := OnPropChanged;
  FAltUnitsProp.OnChanged := OnPropChanged;

  FStatus := 0;  
end;

destructor TUdDimStyle.Destroy;
begin
  FLinesProp.OnChanged    := nil;
  FArrowsProp.OnChanged   := nil;
  FTextProp.OnChanged     := nil;
  FUnitsProp.OnChanged    := nil;
  FAltUnitsProp.OnChanged := nil;

  FLinesProp.Free;
  FArrowsProp.Free;
  FTextProp.Free;
  FUnitsProp.Free;
  FAltUnitsProp.Free;

  inherited;
end;



function TUdDimStyle.GetTypeID: Integer;
begin
  Result := ID_DIMSTYLE;
end;

procedure TUdDimStyle.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

  FLinesProp.SetDocument(Self.Document, False);   
  FArrowsProp.SetDocument(Self.Document, False);
  FTextProp.SetDocument(Self.Document, False);
  FUnitsProp.SetDocument(Self.Document, False);
  FAltUnitsProp.SetDocument(Self.Document, False);
end;



procedure TUdDimStyle.SetBestFit(const AValue: Boolean);
begin
  if (FBestFit <> AValue) and Self.RaiseBeforeModifyObject('BestFit') then
  begin
    FBestFit := AValue;
    Self.RaiseAfterModifyObject('BestFit');
  end;
end;

procedure TUdDimStyle.SetOverallScale(const AValue: Float);
begin
  if (AValue > 0) and (FOverallScale <> AValue) and Self.RaiseBeforeModifyObject('OverallScale') then
  begin
    FOverallScale := AValue;
    Self.RaiseAfterModifyObject('OverallScale');
  end;
end;


procedure TUdDimStyle.SetDispAltUnits(const AValue: Boolean);
begin
  if (FDispAltUnits <> AValue) and Self.RaiseBeforeModifyObject('DispAltUnits') then
  begin
    FDispAltUnits := AValue;
    Self.RaiseAfterModifyObject('DispAltUnits');
  end;
end;



procedure TUdDimStyle.OnPropChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
begin
  if Sender = FLinesProp    then AAllow := Self.RaiseBeforeModifyObject('LinesProp') else
  if Sender = FArrowsProp   then AAllow := Self.RaiseBeforeModifyObject('ArrowsProp') else
  if Sender = FTextProp     then AAllow := Self.RaiseBeforeModifyObject('TextProp') else
  if Sender = FUnitsProp    then AAllow := Self.RaiseBeforeModifyObject('UnitsProp') else
  if Sender = FAltUnitsProp then AAllow := Self.RaiseBeforeModifyObject('AltUnitsProp');
end;

procedure TUdDimStyle.OnPropChanged(Sender: TObject; APropName: string);
begin
  if Sender = FLinesProp    then Self.RaiseAfterModifyObject('LinesProp') else
  if Sender = FArrowsProp   then Self.RaiseAfterModifyObject('ArrowsProp') else
  if Sender = FTextProp     then Self.RaiseAfterModifyObject('TextProp') else
  if Sender = FUnitsProp    then Self.RaiseAfterModifyObject('UnitsProp') else
  if Sender = FAltUnitsProp then Self.RaiseAfterModifyObject('AltUnitsProp');
end;





procedure TUdDimStyle.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDimStyle) then Exit;

  FName         := TUdDimStyle(AValue).FName;
  FDescription  := TUdDimStyle(AValue).FDescription;

  FBestFit      := TUdDimStyle(AValue).FBestFit;
  FOverallScale := TUdDimStyle(AValue).FOverallScale;

  FLinesProp.Assign(TUdDimStyle(AValue).FLinesProp)  ;
  FArrowsProp.Assign(TUdDimStyle(AValue).FArrowsProp);
  FTextProp.Assign(TUdDimStyle(AValue).FTextProp)    ;
  FUnitsProp.Assign(TUdDimStyle(AValue).FUnitsProp)  ;
  FAltUnitsProp.Assign(TUdDimStyle(AValue).FAltUnitsProp);

  FStatus := TUdDimStyle(AValue).FStatus;
end;




procedure TUdDimStyle.SaveToStream(AStream: TStream);
begin
  inherited;

  StrToStream(AStream, FName);
  StrToStream(AStream, FDescription);

  BoolToStream(AStream, FBestFit);
  FloatToStream(AStream, FOverallScale);
  BoolToStream(AStream, FDispAltUnits);

  FLinesProp.SaveToStream(AStream)   ;
  FArrowsProp.SaveToStream(AStream)  ;
  FTextProp.SaveToStream(AStream)    ;
  FUnitsProp.SaveToStream(AStream)   ;
  FAltUnitsProp.SaveToStream(AStream);
end;

procedure TUdDimStyle.LoadFromStream(AStream: TStream);
begin
  inherited;

  FName := StrFromStream(AStream);
  FDescription := StrFromStream(AStream);

  FBestFit      := BoolFromStream(AStream);
  FOverallScale := FloatFromStream(AStream);
  FDispAltUnits := BoolFromStream(AStream);

  FLinesProp.LoadFromStream(AStream)   ;
  FArrowsProp.LoadFromStream(AStream)  ;
  FTextProp.LoadFromStream(AStream)    ;
  FUnitsProp.LoadFromStream(AStream)   ;
  FAltUnitsProp.LoadFromStream(AStream);

end;





procedure TUdDimStyle.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Name'] := FName;
  LXmlNode.Prop['Description'] := FDescription;

  LXmlNode.Prop['BestFit']      := BoolToStr(FBestFit, True);
  LXmlNode.Prop['OverallScale'] := FloatToStr(FOverallScale);
  LXmlNode.Prop['DispAltUnits'] := BoolToStr(FDispAltUnits, True);

  FLinesProp.SaveToXml(LXmlNode.Add())   ;
  FArrowsProp.SaveToXml(LXmlNode.Add())  ;
  FTextProp.SaveToXml(LXmlNode.Add())    ;
  FUnitsProp.SaveToXml(LXmlNode.Add())   ;
  FAltUnitsProp.SaveToXml(LXmlNode.Add());
end;

procedure TUdDimStyle.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FName        := LXmlNode.Prop['Name'];
  FDescription := LXmlNode.Prop['Description'];

  FBestFit      := StrToBoolDef(LXmlNode.Prop['BestFit'], True);
  FOverallScale := StrToFloatDef(LXmlNode.Prop['OverallScale'], 1.0);
  FDispAltUnits := StrToBoolDef(LXmlNode.Prop['DispAltUnits'], False);

  FLinesProp.LoadFromXml(LXmlNode.FindItem('DimLinesProp'))   ;
  FArrowsProp.LoadFromXml(LXmlNode.FindItem('DimSymbolArrowsProp'))  ;
  FTextProp.LoadFromXml(LXmlNode.FindItem('DimTextProp'))    ;
  FUnitsProp.LoadFromXml(LXmlNode.FindItem('DimUnitsProp'))   ;
  FAltUnitsProp.LoadFromXml(LXmlNode.FindItem('DimAltUnitsProp'));
end;

end.