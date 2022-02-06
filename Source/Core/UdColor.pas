{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdColor;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics,
  UdConsts, UdTypes, UdIntfs, UdObject;


const
  CL_RED     = 1; //red
  CL_YELLOW  = 2; //yellow
  CL_GREEN   = 3; //green
  CL_CYAN    = 4; //cyan
  CL_BLUE    = 5; //blue
  CL_MAGENTA = 6; //magenta
  CL_WHITE   = 7; //white
  CL_GRAY    = 8; //gray
  CL_SILVER  = 9; //silver

  CL_BY_LAYER = -1;
  CL_BY_BLOCK = -2;


const

  COLOR_PALETTE: array[1..255] of Integer =   //color palette
    (
    255, 65535, 65280, 16776960, 16711680, 16711935, 16777215, 8355711, 12566463, 255,
    8355839, 192, 6316224, 144, 4212880, 127, 4145023, 64, 2105408, 16383, 8364031, 12495,
    6324175, 10143, 5201808, 8063, 4149119, 4175, 2109263, 30975, 8372223, 24768, 6330304,
    18576, 4222864, 14448, 4153215, 8256, 2111296, 49151, 8380415, 39119, 6336719, 28816,
    5210256, 24447, 4157311, 14415, 2113615, 65535, 8388607, 51392, 6342848, 38800, 4233104,
    30847, 4161407, 18496, 2115648, 65471, 8388575, 51344, 6342831, 39024, 5216128, 32607,
    4161391, 18495, 2115647, 65407, 8388543, 51295, 6342800, 38720, 4233071, 30768, 4161375,
    18463, 2115632, 65343, 8388511, 51248, 6342783, 38944, 5216095, 32543, 4161359, 18448,
    2115631, 65280, 8388479, 51200, 6342752, 38656, 4233024, 30720, 4161343, 18432, 2115616,
    4194048, 10485631, 3196928, 8374368, 2136064, 6264655, 2064128, 5209919, 1067008, 3098656,
    8388352, 12582783, 6277120, 9488480, 4232960, 7313216, 3176448, 6258495, 2050048, 3164192,
    12582656, 14679935, 10471424, 11520096, 7378944, 8427343, 6258432, 7307071, 3164160,
    4147232, 16776960, 16777087, 12634112, 12634208, 9475840, 9475904, 8353792, 8355647,
    4212736, 4212768, 16760576, 16768895, 13604864, 13611104, 10448896, 9470031, 8347392,
    8351551, 5191680, 5193760, 16742400, 16760703, 12607488, 12621664, 9455616, 9465664,
    7354368, 8347455, 4202496, 4208416, 16727808, 16752511, 13578240, 13598560, 9447168,
    9461583, 8331008, 8343359, 5181440, 5189408, 16711680, 16744319, 12582912, 12607584,
    9437184, 9455680, 8323072, 8339263, 4194304, 4202528, 16711743, 16744351, 13566000,
    13592447, 10420256, 9455711, 8323103, 8339279, 5177360, 5187375, 16711807, 16744383,
    12583007, 12607632, 9437248, 9455727, 7340080, 8339295, 4194335, 4202544, 16711871,
    16744415, 13566111, 13592495, 9437296, 9455744, 8323167, 8339311, 5177392, 5187391,
    16711935, 16744447, 12583104, 12607680, 9437328, 9455760, 8323199, 8339327, 4194368,
    4202560, 12517631, 14647295, 9437391, 11495375, 7340191, 8407184, 6226047, 7290751, 4128847,
    4138831, 8323327, 12550143, 6226112, 9461952, 4194448, 7293072, 3145840, 6242175, 2031680,
    3153984, 4129023, 10452991, 3145935, 8349647, 2097296, 6244496, 2031743, 5193599, 1048655,
    3090255, 3092527, 6248543, 8421504, 10528928, 13619407, 16777215
    );




type
  TUdIndexColor = Byte;
  TUdColorType = (ctNone, ctIndexColor, ctTrueColor);

  TUdColor = class;
  TUdColorEvent = procedure(Sender: TObject; Color: TUdColor) of object;
  TUdColorAllowEvent = procedure(Sender: TObject; Color: TUdColor; var Allow: Boolean) of object;

  //*** TUdColor ***//
  TUdColor = class(TUdObject, IUdObjectItem)
  private
    FByKind: TUdByKind;
    FColorType: TUdColorType;

    FTrueColor: TColor;
    FIndexColor: Byte;
    
    FStatus: Cardinal;

  protected
    function GetTypeID: Integer; override;
    function GetName: string;
    function GetName_: string;

    function GetLayout(): TUdObject;
    function GetRGBValue(): TColor;

    procedure SetByKind(const AValue: TUdByKind);
    procedure SetTrueColor(const AValue: TColor);
    procedure SetIndexColor(const AValue: TUdIndexColor);
    procedure SetColorType(const AValue: TUdColorType);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    function IsEqual(const AValue: TUdColor): Boolean;
    function GetValueEx(APaintFlag: Cardinal): TColor;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Name      : string read GetName;
    property Name_     : string read GetName_;
    property ByKind    : TUdByKind read FByKind write SetByKind;

    property RGBValue  : TColor       read GetRGBValue;
    property ColorType : TUdColorType read FColorType  write SetColorType;

    property TrueColor : TColor        read FTrueColor  write SetTrueColor;
    property IndexColor: TUdIndexColor read FIndexColor write SetIndexColor;

    property Status: Cardinal read FStatus write FStatus;
  end;


//function TrueColorToIndexColor(AColor: TColor; ADefault: TUdIndexColor = CL_RED): TUdIndexColor;


implementation

uses
  SysUtils,
  UdDocument, UdLayout, UdEntity, UdStreams, UdXml, UdDrawUtil;


//=================================================================================================

function TrueColorToIndexColor(AColor: TColor; ADefault: TUdIndexColor = CL_RED): TUdIndexColor;
var
  I: Integer;
  N: Integer;
  M, D: Integer;
  LColor: TColor;
  LR, LG, LB: Byte;
  LR1, LG1, LB1: Byte;
begin
  LColor := ColorToRGB(AColor);

  LR1 := GetRValue(LColor);
  LG1 := GetGValue(LColor);
  LB1 := GetBValue(LColor);

  N := -1;
  M := MAXLONG;

  for I := Low(COLOR_PALETTE) to High(COLOR_PALETTE) do
  begin
    LR := GetRValue(COLOR_PALETTE[I]);
    LG := GetGValue(COLOR_PALETTE[I]);
    LB := GetBValue(COLOR_PALETTE[I]);

    D := Abs(LR- LR1) + Abs(LG- LG1) + Abs(LB- LB1);
    if D < M then
    begin
      M := D;
      N := I;
    end;
  end;

  if N > 0 then Result := N else Result := ADefault;
end;




//=================================================================================================
{ TUdColor }

constructor TUdColor.Create();
begin
  inherited;

  FByKind := bkNone;;

  FIndexColor := CL_WHITE;
  FTrueColor  := RGB(255, 255, 255);

  FColorType := ctIndexColor;
  FStatus    := 0;
end;

destructor TUdColor.Destroy;
begin

  inherited;
end;



function TUdColor.GetTypeID: Integer;
begin
  Result := ID_COLOR;
end;


//------------------------------------------------------------------------------------------

function TUdColor.GetLayout(): TUdObject;
//var
//  LOwner: TUdObject;
begin
  Result := nil;

//  LOwner := Self.Owner;
//  while Assigned(LOwner) do
//  begin
//    if LOwner.InheritsFrom(TUdLayout) then
//    begin
//      Result := LOwner;
//      Break;
//    end;
//
//    LOwner := LOwner.Owner;
//  end;

  if Assigned(Self.Document) then
  begin
//    if Assigned(Result) and (Result = TUdDocument(Self.Document).ModelSpace) and
//      (TUdDocument(Self.Document).ActiveLayout <> Result) or (TUdDocument(Self.Document).ActiveLayout.ViewPortActived) then
//      Result := TUdDocument(Self.Document).ActiveLayout;

    if not Assigned(Result) then
      Result := TUdDocument(Self.Document).ActiveLayout;
  end;
end;


function TUdColor.GetName: string;
begin
  if FByKind <> bkNone then
  begin
    case FByKind of
      bkByLayer: Result := sByLayer;
      bkByBlock: Result := sByBlock;
    end;
  end
  else begin
    case FColorType of
      ctNone: Result := 'None';
      ctIndexColor:
        begin
          if (FIndexColor > 0) and (FIndexColor <= Length(sInitColors)) then
            Result := sInitColors[FIndexColor]
          else
            Result := 'Color ' + IntToStr(FIndexColor);
        end;
      ctTrueColor:  Result := IntToStr(GetRValue(FTrueColor)) + ', ' +
                              IntToStr(GetGValue(FTrueColor)) + ', ' +
                              IntToStr(GetBValue(FTrueColor));
    end;
  end;
end;


function TUdColor.GetName_: string;
begin
  case FColorType of
    ctIndexColor:
      begin
        if (FIndexColor > 0) and (FIndexColor <= Length(sInitColors)) then
          Result := sInitColors[FIndexColor]
        else
          Result := 'Color ' + IntToStr(FIndexColor);
      end;
    ctTrueColor:  Result := IntToStr(GetRValue(FTrueColor)) + ', ' +
                            IntToStr(GetGValue(FTrueColor)) + ', ' +
                            IntToStr(GetBValue(FTrueColor));
  end;
end;

function TUdColor.GetRGBValue(): TColor;
var
  LLayout: TUdLayout;
begin
  Result := clNone;
  case FColorType of
    ctNone:
      begin
        //Result := clWhite;
        
        LLayout := nil;
        if Assigned(Self.Document) then LLayout := TUdDocument(Self.Document).ActiveLayout;

        if Assigned(LLayout) then
          Result := UdDrawUtil.NotColor(LLayout.BackColor)
        else
          Result := clWhite;
      end;
      
    ctIndexColor:
      begin
        if FIndexColor = CL_WHITE then
        begin
          LLayout := nil; //TUdLayout(Self.GetLayout());
          if Assigned(Self.Document) then LLayout := TUdDocument(Self.Document).ActiveLayout;

          if Assigned(LLayout) then
          begin
            if (LLayout.BackColor = clAppWorkSpace) or (LLayout.BackColor = clNone) then
              Result := clBlack
            else
              Result := UdDrawUtil.NotColor(LLayout.BackColor);
          end
          else
            Result := COLOR_PALETTE[FIndexColor];
        end
        else begin
          if FIndexColor > 0 then Result := COLOR_PALETTE[FIndexColor];
        end;
      end;
        
    ctTrueColor :
      begin
        Result := FTrueColor;
      end;
  end;
end;

function TUdColor.GetValueEx(APaintFlag: Cardinal): TColor;
begin
  if (APaintFlag and BLACK_PAINT) > 0 then
  begin
    Result := clBlack;
    Exit; //=====>>>>
  end;

  if ((APaintFlag and PRINT_PAINT) > 0) and
     (FColorType = ctIndexColor) and (FIndexColor = CL_WHITE) then
    Result := clBlack
  else
    Result := Self.RGBValue;
end;


procedure TUdColor.SetTrueColor(const AValue: TColor);
begin
  if AValue = clNone then
  begin
    Self.SetColorType(ctNone);
    Exit;
  end;

  if Self.RaiseBeforeModifyObject('TrueColor') then
  begin
    FTrueColor := ColorToRGB(AValue);
    FIndexColor := TrueColorToIndexColor(AValue);

    FColorType := ctTrueColor;
    if Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdEntity) then FByKind := bkNone;

    Self.RaiseAfterModifyObject('TrueColor');
  end;
end;

procedure TUdColor.SetIndexColor(const AValue: TUdIndexColor);
begin
  if Self.RaiseBeforeModifyObject('IndexColor') then
  begin
    FIndexColor := AValue;
    if FIndexColor > 0 then FTrueColor := COLOR_PALETTE[FIndexColor] else FTrueColor := clNone;

    FColorType := ctIndexColor;
    if Assigned(Self.Owner) and Self.Owner.InheritsFrom(TUdEntity) then FByKind := bkNone;

    Self.RaiseAfterModifyObject('IndexColor');
  end;
end;


procedure TUdColor.SetByKind(const AValue: TUdByKind);
begin
  if (FByKind <> AValue) and Self.RaiseBeforeModifyObject('ByKind') then
  begin
    FByKind := AValue;
    Self.RaiseAfterModifyObject('ByKind');
  end
end;

procedure TUdColor.SetColorType(const AValue: TUdColorType);
begin
  if (FColorType <> AValue) and Self.RaiseBeforeModifyObject('ColorType') then
  begin
    FColorType := AValue;
    if FColorType = ctNone then
    begin
      FTrueColor := RGB(255,255,255);
      FIndexColor := TrueColorToIndexColor(FTrueColor);
    end;

    Self.RaiseAfterModifyObject('ColorType');
  end;
end;





//------------------------------------------------------------------------------------------

procedure TUdColor.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdColor) then Exit;

  FTrueColor  := TUdColor(AValue).FTrueColor;
  FIndexColor := TUdColor(AValue).FIndexColor;

  FByKind     := TUdColor(AValue).FByKind;
  FColorType  := TUdColor(AValue).ColorType;

  FStatus     := TUdColor(AValue).FStatus;
end;

function TUdColor.IsEqual(const AValue: TUdColor): Boolean;
begin
  Result := False;
  if not Assigned(AValue) then Exit;

  Result :=  //(FByKind = AValue.FByKind) and
             (FColorType  = AValue.ColorType) and
             (FTrueColor  = AValue.FTrueColor) and
             (FIndexColor = AValue.FIndexColor);
end;






//-----------------------------------------------------------------------

procedure TUdColor.SaveToStream(AStream: TStream);
begin
  inherited;

  ByteToStream(AStream, Ord(FByKind));
  ByteToStream(AStream, Ord(FColorType));

  IntToStream(AStream, FTrueColor);
  ByteToStream(AStream, FIndexColor);
end;

procedure TUdColor.LoadFromStream(AStream: TStream);
begin
  inherited;

  FByKind    := TUdByKind(ByteFromStream(AStream));
  FColorType := TUdColorType(ByteFromStream(AStream));

  FTrueColor  := IntFromStream(AStream);
  FIndexColor := ByteFromStream(AStream);
end;



procedure TUdColor.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['ByKind']     := IntToStr(Ord(FByKind));
  LXmlNode.Prop['ColorType']  := IntToStr(Ord(FColorType));

  LXmlNode.Prop['TrueColor']  := IntToStr(FTrueColor);
  LXmlNode.Prop['IndexColor'] := IntToStr(FIndexColor);
end;

procedure TUdColor.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FByKind     := TUdByKind(StrToIntDef(LXmlNode.Prop['ByKind'], 0));
  FColorType  := TUdColorType(StrToIntDef(LXmlNode.Prop['ColorType'], 0));

  FTrueColor  := StrToIntDef(LXmlNode.Prop['TrueColor'], clWhite);
  FIndexColor := StrToIntDef(LXmlNode.Prop['IndexColor'], CL_WHITE);
end;

end.