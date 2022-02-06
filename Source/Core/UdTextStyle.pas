{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdTextStyle;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics,
  UdConsts, UdTypes, UdIntfs, UdObject, UdShx, UdTTF;

type
  TUdTextStyle = class;

  TUdTextStyleEvent = procedure(Sender: TObject; TextStyle: TUdTextStyle) of object;
  TUdTextStyleAllowEvent = procedure(Sender: TObject; TextStyle: TUdTextStyle; var Allow: Boolean) of object;

  TUdFontKind = (fkShx, fkTTF); 

  //*** TUdTextStyle ***//
  TUdTextStyle = class(TUdObject, IUdObjectItem)
  private
    FName: string;

    FHeight: Float;
    FWidthFactor: Float;

    FBackward: Boolean;
    FUpsidedown: Boolean;

    FShxFont: TUdShx;
    FTTFFont: TUdTTF;

    FFontKind: TUdFontKind;
    
    FStatus: Cardinal;

  protected
    function GetTypeID: Integer; override;

    procedure SetName(const AValue: string);

    procedure SetHeight(const AValue: Float);
    procedure SetWidthFactor(const AValue: Float);

    procedure SetBackward(const AValue: Boolean);
    procedure SetUpsidedown(const AValue: Boolean);

    procedure SetFontKind(const AValue: TUdFontKind);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;
        
  public
    constructor Create(); override;
    destructor Destroy; override;

    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;


    property ShxFont: TUdShx read FShxFont;
    property TTFFont: TUdTTF read FTTFFont;

  published
    property Name       : string      read FName        write SetName       ;

    property Height     : Float       read FHeight      write SetHeight     ;
    property WidthFactor: Float       read FWidthFactor write SetWidthFactor;

    property Backward   : Boolean     read FBackward    write SetBackward   ;
    property Upsidedown : Boolean     read FUpsidedown  write SetUpsidedown ;

    property FontKind   : TUdFontKind read FFontKind    write SetFontKind   ;

    property Status: Cardinal read FStatus write FStatus;
  end;


implementation

uses
  SysUtils,
  UdTextStyles, UdStreams, UdXml;


//=================================================================================================
{ TUdTextStyle }

constructor TUdTextStyle.Create();
begin
  inherited;

  FShxFont := nil;
  FTTFFont := nil;

  FFontKind := fkShx;
  FShxFont := TUdShx.Create;

  FHeight := 2.5;
  FWidthFactor := 1.0;

  FBackward := False;
  FUpsidedown := False;

  FStatus := 0;  
end;

destructor TUdTextStyle.Destroy;
begin
  if Assigned(FTTFFont) then FTTFFont.Free();
  FTTFFont := nil;

  if Assigned(FShxFont) then FShxFont.Free();
  FShxFont := nil;

  inherited;
end;



function TUdTextStyle.GetTypeID: Integer;
begin
  Result := ID_TEXTSTYLE;
end;





//-----------------------------------------------------------------------------------------

procedure TUdTextStyle.SetName(const AValue: string);
begin
  if (FName <> AValue) and Self.RaiseBeforeModifyObject('Name') then
  begin
    FName := AValue;
    Self.RaiseAfterModifyObject('Name');
  end;
end;


procedure TUdTextStyle.SetHeight(const AValue: Float);
begin
  if (FHeight <> AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('Height') then
  begin
    FHeight := AValue;
    Self.RaiseAfterModifyObject('Height');
  end;
end;

procedure TUdTextStyle.SetWidthFactor(const AValue: Float);
begin
  if (FWidthFactor <> AValue) and Self.RaiseBeforeModifyObject('WidthFactor') then
  begin
    FWidthFactor := AValue;
    Self.RaiseAfterModifyObject('WidthFactor');
  end;
end;


procedure TUdTextStyle.SetBackward(const AValue: Boolean);
begin
  if (FBackward <> AValue) and Self.RaiseBeforeModifyObject('Backward') then
  begin
    FBackward := AValue;
    Self.RaiseAfterModifyObject('Backward');
  end;
end;

procedure TUdTextStyle.SetUpsidedown(const AValue: Boolean);
begin
  if (FUpsidedown <> AValue) and Self.RaiseBeforeModifyObject('Upsidedown') then
  begin
    FUpsidedown := AValue;
    Self.RaiseAfterModifyObject('Upsidedown');
  end;
end;

procedure TUdTextStyle.SetFontKind(const AValue: TUdFontKind);
begin
  if (FFontKind <> AValue) and Self.RaiseBeforeModifyObject('FontKind') then
  begin
    if Assigned(FTTFFont) then FTTFFont.Free();
    FTTFFont := nil;

    if Assigned(FShxFont) then FShxFont.Free();
    FShxFont := nil;

    FFontKind := AValue;

    if FFontKind = fkTTF then
      FTTFFont := TUdTTF.Create
    else
      FShxFont := TUdShx.Create;

    Self.RaiseAfterModifyObject('UseTTFFont');
  end;
end;




procedure TUdTextStyle.CopyFrom(AValue: TUdObject);
begin
  inherited;
  if not AValue.InheritsFrom(TUdTextStyle) then Exit; //======>>>

  {
  if Assign(TUdTextStyle(AValue).FShxFont) then
  begin
    if not Assign(FShxFont) then FShxFont := TUdShx.Create;
    FShxFont.ShxFile := TUdTextStyle(AValue).FShxFont.ShxFile;
    FShxFont.BigFile := TUdTextStyle(AValue).FShxFont.BigFile;
  end
  else begin
    if Assign(FShxFont) then FShxFont.Free;
    FShxFont := nil;
  end;
  

  if Assign(TUdTextStyle(AValue).FTTFFont) then
  begin
    if not Assign(FTTFFont) then FTTFFont := TUdTTF.Create;
    FTTFFont.Font      := TUdTextStyle(AValue).FTTFFont.Font;
    FTTFFont.Precision := TUdTextStyle(AValue).FTTFFont.Precision;
  end
  else begin
    if Assign(FTTFFont) then FTTFFont.Free;
    FTTFFont := nil;
  end;
  }

  FName     := TUdTextStyle(AValue).FName;
  Self.SetFontKind( TUdTextStyle(AValue).FFontKind );

  if FFontKind = fkShx then
  begin
    FShxFont.ShxFile := TUdTextStyle(AValue).FShxFont.ShxFile;
    FShxFont.BigFile := TUdTextStyle(AValue).FShxFont.BigFile;
  end
  else begin
    FTTFFont.Font.Name  := TUdTextStyle(AValue).FTTFFont.Font.Name;
    FTTFFont.Font.Style := TUdTextStyle(AValue).FTTFFont.Font.Style;
    //FTTFFont.Precision := TUdTextStyle(AValue).FTTFFont.Precision;
  end;

  FHeight      := TUdTextStyle(AValue).FHeight;
  FWidthFactor := TUdTextStyle(AValue).FWidthFactor;

  FBackward    := TUdTextStyle(AValue).FBackward;
  FUpsidedown  := TUdTextStyle(AValue).FUpsidedown;

  FStatus      := TUdTextStyle(AValue).FStatus;
end;



//-----------------------------------------------------------------------------------------

procedure TUdTextStyle.SaveToStream(AStream: TStream);
var
  LFlag: Cardinal;
begin
  inherited;

  StrToStream(AStream, FName);

  FloatToStream(AStream, FHeight);
  FloatToStream(AStream, FWidthFactor);

  BoolToStream(AStream, FBackward);
  BoolToStream(AStream, FUpsidedown);
  ByteToStream(AStream, Ord(FFontKind));

  if FFontKind = fkTTF then
  begin
    StrToStream(AStream, FTTFFont.Font.Name);

    //  (fsBold, fsItalic, fsUnderline, fsStrikeOut);
    LFlag := 0;
    if fsBold      in FTTFFont.Font.Style then LFlag := LFlag or 1;
    if fsItalic    in FTTFFont.Font.Style then LFlag := LFlag or 2;
    if fsUnderline in FTTFFont.Font.Style then LFlag := LFlag or 4;
    if fsStrikeOut in FTTFFont.Font.Style then LFlag := LFlag or 8;

    CarToStream(AStream, LFlag);
  end
  else begin
    StrToStream(AStream, ExtractFileName(FShxFont.ShxFile));
    StrToStream(AStream, ExtractFileName(FShxFont.BigFile));
  end;
end;

procedure TUdTextStyle.LoadFromStream(AStream: TStream);
var
  LFlag: Cardinal;
  LFontName: string;
  LFontKind: TUdFontKind;
begin
  inherited;

  FName := StrFromStream(AStream);

  FHeight := FloatFromStream(AStream);
  FWidthFactor := FloatFromStream(AStream);

  FBackward := BoolFromStream(AStream);
  FUpsidedown := BoolFromStream(AStream);
  LFontKind   := TUdFontKind(ByteFromStream(AStream));

  Self.SetFontKind(LFontKind);

  if LFontKind = fkTTF then
  begin
    LFontName := StrFromStream(AStream);
    if Assigned(FTTFFont) then FTTFFont.Font.Name := LFontName;

    //  (fsBold, fsItalic, fsUnderline, fsStrikeOut);
    LFlag := CarFromStream(AStream);
    FTTFFont.Font.Style := [];
    if ((LFlag and 1) > 0) then FTTFFont.Font.Style := FTTFFont.Font.Style + [fsBold];
    if ((LFlag and 2) > 0) then FTTFFont.Font.Style := FTTFFont.Font.Style + [fsItalic];
    if ((LFlag and 4) > 0) then FTTFFont.Font.Style := FTTFFont.Font.Style + [fsUnderline];
    if ((LFlag and 8) > 0) then FTTFFont.Font.Style := FTTFFont.Font.Style + [fsStrikeOut];
  end
  else begin
    LFontName := StrFromStream(AStream);
    if Assigned(FShxFont) and Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdTextStyles) then
      FShxFont.ShxFile := TUdTextStyles(Self.Owner).FontsDir + '\' + LFontName;

    LFontName := StrFromStream(AStream);
    if Assigned(FShxFont) and Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdTextStyles) then
      FShxFont.BigFile := TUdTextStyles(Self.Owner).FontsDir + '\' + LFontName;
  end;
end;




procedure TUdTextStyle.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LFlag: Cardinal;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Name'] := FName;

  LXmlNode.Prop['Height']      := FloatToStr(FHeight);
  LXmlNode.Prop['WidthFactor'] := FloatToStr(FWidthFactor);

  LXmlNode.Prop['Backward']    := BoolToStr(FBackward  , True);
  LXmlNode.Prop['Upsidedown']  := BoolToStr(FUpsidedown, True);
  LXmlNode.Prop['FontKind']    := IntToStr(Ord(FFontKind));

  if FFontKind = fkTTF then
  begin
    LXmlNode.Prop['FontName'] := FTTFFont.Font.Name;

    //  (fsBold, fsItalic, fsUnderline, fsStrikeOut);
    LFlag := 0;
    if fsBold      in FTTFFont.Font.Style then LFlag := LFlag or 1;
    if fsItalic    in FTTFFont.Font.Style then LFlag := LFlag or 2;
    if fsUnderline in FTTFFont.Font.Style then LFlag := LFlag or 4;
    if fsStrikeOut in FTTFFont.Font.Style then LFlag := LFlag or 8;

     LXmlNode.Prop['FontStyle'] := IntToStr(LFlag);
  end
  else begin
    LXmlNode.Prop['ShxFile'] := ExtractFileName(FShxFont.ShxFile);
    LXmlNode.Prop['BigFile'] := ExtractFileName(FShxFont.BigFile);
  end;
end;

procedure TUdTextStyle.LoadFromXml(AXmlNode: TObject);
var
  LFlag: Cardinal;
  LXmlNode: TUdXmlNode;
  LFontName: string;
  LFontKind: TUdFontKind;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FName := LXmlNode.Prop['Name'];

  FHeight      := StrToFloatDef(LXmlNode.Prop['Height'], 2.5);
  FWidthFactor := StrToFloatDef(LXmlNode.Prop['WidthFactor'], 1.0);

  FBackward    := StrToBoolDef(LXmlNode.Prop['Backward'], False);
  FUpsidedown  := StrToBoolDef(LXmlNode.Prop['Upsidedown'], False);
  LFontKind    := TUdFontKind(StrToIntDef(LXmlNode.Prop['FontKind'], 0));


  Self.SetFontKind(LFontKind);

  if LFontKind = fkTTF then
  begin
    LFontName := LXmlNode.Prop['FontName'];
    if Assigned(FTTFFont) then
    begin
      FTTFFont.Font.Name := LFontName;
      
      //  (fsBold, fsItalic, fsUnderline, fsStrikeOut);
      FTTFFont.Font.Style := [];

      LFlag := StrToIntDef(LXmlNode.Prop['FontStyle'], 0);
      if ((LFlag and 1) > 0) then FTTFFont.Font.Style := FTTFFont.Font.Style + [fsBold];
      if ((LFlag and 2) > 0) then FTTFFont.Font.Style := FTTFFont.Font.Style + [fsItalic];
      if ((LFlag and 4) > 0) then FTTFFont.Font.Style := FTTFFont.Font.Style + [fsUnderline];
      if ((LFlag and 8) > 0) then FTTFFont.Font.Style := FTTFFont.Font.Style + [fsStrikeOut];
    end;
  end
  else begin
    LFontName := LXmlNode.Prop['ShxFile'];
    if Assigned(FShxFont) and Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdTextStyles) then
      FShxFont.ShxFile := TUdTextStyles(Self.Owner).FontsDir + '\' + LFontName;

    LFontName := LXmlNode.Prop['BigFile'];
    if Assigned(FShxFont) and Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdTextStyles) then
      FShxFont.BigFile := TUdTextStyles(Self.Owner).FontsDir + '\' + LFontName;
  end;
end;

end.