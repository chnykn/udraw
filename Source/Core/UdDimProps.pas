{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimProps;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdConsts, UdColor, UdLineType, UdLineWeight, UdObject,
  UdUnits;


type

  TUdDimArrowKind = (
    dakClosedFilled, dakClosedBlank, dakClosed, dakDot, dakArchTick,
    dakOblique, dakOpen, dakOrigin, dakOrigin2, dakOpen90, dakOpen30,
    dakDotSmall, dakDotBlank, dakSmall, dakBoxBlank, dakBoxFilled,
    dakDatumBlank, dakDatumFilled, dakIntegral, dakNone
  );

  

  //*** TUdDimProp ***//
  TUdDimProp = class(TUdObject)
  protected
    function GetTypeID: Integer; override;
  public

  end;


  //---------------------------------------------------------------------------------------
  //*** TUdDimLinesProp ***//
  TUdDimLinesProp = class(TUdDimProp)
  private
    FColor           : TUdColor;
    FLineType        : TUdLineType;
    FLineWeight      : TUdLineWeight;
    FExtBeyondTicks  : Float;
    FBaselineSpacing : Float;
    FSuppressLine1   : Boolean;
    FSuppressLine2   : Boolean;

    FExtColor           : TUdColor;
    FExtLineType1       : TUdLineType;
    FExtLineType2       : TUdLineType;
    FExtLineWeight      : TUdLineWeight;
    FExtSuppressLine1   : Boolean;
    FExtSuppressLine2   : Boolean;
    FExtBeyondDimLines  : Float;
    FExtOriginOffset    : Float;

  protected
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;
    
    procedure SetColor(const AValue: TUdColor);
    procedure SetLineType(const AValue: TUdLineType);
    procedure SetLineWeight(const AValue: TUdLineWeight);
    procedure SetExtBeyondTicks(const AValue: Float);
    procedure SetBaselineSpacing(const AValue: Float);
    procedure SetSuppressLine1(const AValue: Boolean);
    procedure SetSuppressLine2(const AValue: Boolean);

    procedure SetExtColor(const AValue: TUdColor);
    procedure SetExtLineType1(const AValue: TUdLineType);
    procedure SetExtLineType2(const AValue: TUdLineType);
    procedure SetExtLineWeight(const AValue: TUdLineWeight);
    procedure SetExtSuppressLine1(const AValue: Boolean);
    procedure SetExtSuppressLine2(const AValue: Boolean);
    procedure SetExtBeyondDimLines(const AValue: Float);
    procedure SetExtOriginOffset(const AValue: Float);

    procedure OnFieldChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
    procedure OnFieldChanged(Sender: TObject; APropName: string);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property Color           : TUdColor       read FColor           write SetColor          ;
    property LineType        : TUdLineType    read FLineType        write SetLineType       ;
    property LineWeight      : TUdLineWeight  read FLineWeight      write SetLineWeight     ;
    property ExtBeyondTicks  : Float          read FExtBeyondTicks  write SetExtBeyondTicks ;
    property BaselineSpacing : Float          read FBaselineSpacing write SetBaselineSpacing;
    property SuppressLine1   : Boolean        read FSuppressLine1   write SetSuppressLine1  ;
    property SuppressLine2   : Boolean        read FSuppressLine2   write SetSuppressLine2  ;

    property ExtColor           : TUdColor      read FExtColor           write SetExtColor          ;
    property ExtLineType1       : TUdLineType   read FExtLineType1       write SetExtLineType1      ;
    property ExtLineType2       : TUdLineType   read FExtLineType2       write SetExtLineType2      ;
    property ExtLineWeight      : TUdLineWeight read FExtLineWeight      write SetExtLineWeight     ;
    property ExtSuppressLine1   : Boolean       read FExtSuppressLine1   write SetExtSuppressLine1  ;
    property ExtSuppressLine2   : Boolean       read FExtSuppressLine2   write SetExtSuppressLine2  ;
    property ExtBeyondDimLines  : Float         read FExtBeyondDimLines  write SetExtBeyondDimLines ;
    property ExtOriginOffset    : Float         read FExtOriginOffset    write SetExtOriginOffset   ;
  end;





//---------------------------------------------------------------------------------------

  TUdDimCenterKind = (ckCenterNone, ckCenterMark, ckCenterLine);
  TUdSymbolPosition = (spSymNone , spSymInFront, spSymAbove);



  //*** TUdDimSymbolArrowsProp ***//
  TUdDimSymbolArrowsProp = class(TUdDimProp)
  private
    FArrowFirst : TUdDimArrowKind;
    FArrowSecond: TUdDimArrowKind;
    FArrowLeader: TUdDimArrowKind;
    FArrowSize  : Float;

    FCenterMark : TUdDimCenterKind;
    FMarkSize   : Float;

    FArcLenSymbolPos: TUdSymbolPosition;

  protected
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    procedure SetArrowFirst(const AValue: TUdDimArrowKind);
    procedure SetArrowSecond(const AValue: TUdDimArrowKind);
    procedure SetArrowLeader(const AValue: TUdDimArrowKind);
    procedure SetArrowSize(const AValue: Float);

    procedure SetCenterMark(const AValue: TUdDimCenterKind);
    procedure SetMarkSize(const AValue: Float);

    procedure SetArcLenSymbolPos(const AValue: TUdSymbolPosition);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property ArrowFirst : TUdDimArrowKind read FArrowFirst  write SetArrowFirst ;
    property ArrowSecond: TUdDimArrowKind read FArrowSecond write SetArrowSecond;
    property ArrowLeader: TUdDimArrowKind read FArrowLeader write SetArrowLeader;
    property ArrowSize  : Float read FArrowSize   write SetArrowSize ;

    property CenterMark : TUdDimCenterKind  read FCenterMark write SetCenterMark;
    property MarkSize   : Float read FMarkSize    write SetMarkSize  ;

    property ArcLenSymbolPos: TUdSymbolPosition read FArcLenSymbolPos write SetArcLenSymbolPos;
  end;




//---------------------------------------------------------------------------------------

  TUdVerticalTextPoint = (
    vtpCentered, // 文字位置在尺寸界线中心
    vtpAbove//,        // 除非尺寸线不是水平的或尺寸界线内的文本被强制设为水平(DIMTIH = 1)，否则将标注文字置于标线上方。尺寸线到最下行文字基线的距离是当前DIMGAP 值
//    vtpOutside,      // 将标注文字置于距定义点最远的基线一端
//    vtpJIS           // 按日本工业标准方式标注文字(JIS)
  );

  TUdHorizontalTextPoint = (
    htpCentered,
    htpFirstExtensionLine,
    htpSecondExtensionLine,
    htpCustom
//    htpOverFirstExtension,
//    htpOverSecondExtension
  );






  //*** TUdDimTextProp ***//
  TUdDimTextProp = class(TUdDimProp)
  private
    FTextStyle  : string;
    FTextColor  : TUdColor;
    FFillColor  : TUdColor;
    FTextHeight : Float;
    FDrawFrame  : Boolean;

    FVerticalPosition : TUdVerticalTextPoint;
    FHorizontalPosition: TUdHorizontalTextPoint;
    FOffsetFromDimLine: Float;

    { TextAlignment:
        Horizontal           :  FInsideAlign := False  FOutsideAlign = False
        Aligned with dim line:  FInsideAlign := True   FOutsideAlign = True
        ISO Standard         :  FInsideAlign := True   FOutsideAlign = False
    }
    FInsideAlign : Boolean;
    FOutsideAlign: Boolean;

  protected
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;
    
    procedure SetTextStyle(const AValue: string);
    procedure SetTextColor(const AValue: TUdColor);
    procedure SetFillColor(const AValue: TUdColor);
    procedure SetTextHeight(const AValue: Float);
    procedure SetDrawFrame(const AValue: Boolean);

    procedure SetInsideAlign(const AValue: Boolean);
    procedure SetOutsideAlign(const AValue: Boolean);
    procedure SetOffsetFromDimLine(const AValue: Float);

    procedure SetHorizontalPosition(const AValue: TUdHorizontalTextPoint);
    procedure SetVerticalPosition(const AValue: TUdVerticalTextPoint);

    procedure OnFieldChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
    procedure OnFieldChanged(Sender: TObject; APropName: string);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property TextStyle  : string   read FTextStyle   write SetTextStyle ;
    property TextColor  : TUdColor read FTextColor   write SetTextColor ;
    property FillColor  : TUdColor read FFillColor   write SetFillColor ;
    property TextHeight : Float    read FTextHeight  write SetTextHeight;
    property DrawFrame  : Boolean  read FDrawFrame   write SetDrawFrame ;

    property VerticalPosition : TUdVerticalTextPoint     read FVerticalPosition   write SetVerticalPosition ;
    property HorizontalPosition: TUdHorizontalTextPoint  read FHorizontalPosition write SetHorizontalPosition ;
    property OffsetFromDimLine: Float read FOffsetFromDimLine  write SetOffsetFromDimLine ;

    property InsideAlign : Boolean read FInsideAlign   write SetInsideAlign ;
    property OutsideAlign: Boolean read FOutsideAlign  write SetOutsideAlign ;
  end;




//---------------------------------------------------------------------------------------

  TUdAltPlacement = (apAfterPrimary, apBelowPrimary);


  //*** TUdDimUnitsProp ***//
  TUdDimUnitsProp = class(TUdDimProp)
  private
    FUnitFormat: TUdLengthUnit;
    FPrecision: Byte;
    FDecimal: Char;
    FRoundOff: Float;

    FPrefix: string;
    FSuffix: string;

    FMeasurementScale: Float;
    FAltPlacement: TUdAltPlacement;

    FSuppressLeading: Boolean;
    FSuppressTrailing: Boolean;


    FAngUnitFormat: TUdAngleUnit;
    FAngPrecision: Byte;

    FAngSuppressLeading: Boolean;
    FAngSuppressTrailing: Boolean;

  protected
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;
    
    procedure SetUnitFormat(const AValue: TUdLengthUnit);
    procedure SetPrecision(const AValue: Byte);
    procedure SetDecimal(const AValue: Char);
    procedure SetRoundOff(const AValue: Float);

    procedure SetPrefix(const AValue: string);
    procedure SetSuffix(const AValue: string);

    procedure SetMeasurementScale(const AValue: Float);
    procedure SetAltPlacement(const AValue: TUdAltPlacement);

    procedure SetSuppressLeading(const AValue: Boolean);
    procedure SetSuppressTrailing(const AValue: Boolean);



    procedure SetAngUnitFormat(const AValue: TUdAngleUnit);
    procedure SetAngPrecision(const AValue: Byte);

    procedure SetAngSuppressLeading(const AValue: Boolean);
    procedure SetAngSuppressTrailing(const AValue: Boolean);

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy; override;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property UnitFormat         : TUdLengthUnit read  FUnitFormat  write SetUnitFormat      ;
    property Precision          : Byte    read FPrecision          write SetPrecision       ;
    property Decimal            : Char    read FDecimal            write SetDecimal         ;
    property RoundOff           : Float   read FRoundOff           write SetRoundOff        ;

    property Prefix             : string  read FPrefix             write SetPrefix          ;
    property Suffix             : string  read FSuffix             write SetSuffix          ;

    property MeasurementScale   : Float   read FMeasurementScale   write SetMeasurementScale;
    
    property AltPlacement       : TUdAltPlacement read FAltPlacement write SetAltPlacement  ;

    property SuppressLeading    : Boolean read FSuppressLeading      write SetSuppressLeading ;
    property SuppressTrailing   : Boolean read FSuppressTrailing     write SetSuppressTrailing;


    property AngUnitFormat: TUdAngleUnit read FAngUnitFormat        write SetAngUnitFormat  ;
    property AngPrecision: Byte          read FAngPrecision         write SetAngPrecision   ;

    property AngSuppressLeading  : Boolean read FAngSuppressLeading write SetAngSuppressLeading ;
    property AngSuppressTrailing : Boolean read FAngSuppressTrailing write SetAngSuppressTrailing;
  end;


  //*** TUdDimAltUnitsProp ***//
  TUdDimAltUnitsProp = class(TUdDimUnitsProp)
  public

  end;




function GetDimArrowName(AValue: TUdDimArrowKind; ADefaultIsNull: Boolean = True): string;
  

implementation

uses
  SysUtils,
  UdStreams, UdXml;



function GetDimArrowName(AValue: TUdDimArrowKind; ADefaultIsNull: Boolean = True): string;
begin
  Result := '';
  if ADefaultIsNull and (AValue = dakClosedFilled) then Exit;

  case Ord(AValue) of
    0  : Result := 'ClosedFilled';
    1  : Result := 'ClosedBlank' ;
    2  : Result := 'Closed'      ;
    3  : Result := 'Dot'         ;
    4  : Result := 'ArchTick'    ;
    5  : Result := 'Oblique'     ;
    6  : Result := 'Open'        ;
    7  : Result := 'Origin'      ;
    8  : Result := 'Origin2'     ;
    9  : Result := 'Open90'      ;
    10 : Result := 'Open30'      ;
    11 : Result := 'DotSmall'    ;
    12 : Result := 'DotBlank'    ;
    13 : Result := 'Small'       ;
    14 : Result := 'BoxBlank'    ;
    15 : Result := 'BoxFilled'   ;
    16 : Result := 'DatumBlank'  ;
    17 : Result := 'DatumFilled' ;
    18 : Result := 'Integral'    ;
    19 : Result := 'None'        ;
  end;
end;



  
{ TUdDimProp }

function TUdDimProp.GetTypeID: Integer;
begin
  Result := ID_DIM_PROP;
end;




//==============================================================================================
{ TUdDimLinesProp }

constructor TUdDimLinesProp.Create();
begin
  inherited;

  FColor := TUdColor.Create();
  FColor.ByKind := bkByBlock;

  FLineType := TUdLineType.Create();
  FLineType.ByKind := bkByBlock;

  FLineWeight        := LW_BYBLOCK;
  FExtBeyondTicks    := 0.0;
  FBaselineSpacing   := 3.75;
  FSuppressLine1     := False;
  FSuppressLine2     := False;


  FExtColor := TUdColor.Create();
  FExtColor.ByKind := bkByBlock;

  FExtLineType1 := TUdLineType.Create();
  FExtLineType1.ByKind := bkByBlock;

  FExtLineType2 := TUdLineType.Create();
  FExtLineType2.ByKind := bkByBlock;  
  
  FExtLineWeight     := LW_BYBLOCK;

  FExtSuppressLine1  := False;
  FExtSuppressLine2  := False;
  FExtBeyondDimLines := 1.25;
  FExtOriginOffset   := 0.625;


  FColor.OnChanged := OnFieldChanged;
  FColor.OnChanging := OnFieldChanging;

  FLineType.OnChanged := OnFieldChanged;
  FLineType.OnChanging := OnFieldChanging;

  FExtColor.OnChanged := OnFieldChanged;
  FExtColor.OnChanging := OnFieldChanging;

  FExtLineType1.OnChanged := OnFieldChanged;
  FExtLineType1.OnChanging := OnFieldChanging;

  FExtLineType2.OnChanged := OnFieldChanged;
  FExtLineType2.OnChanging := OnFieldChanging;
end;

destructor TUdDimLinesProp.Destroy;
begin
  FColor.Free;
  FColor := nil;

  FLineType.Free;
  FLineType := nil;

  FExtColor.Free;
  FExtColor := nil;

  FExtLineType1.Free;
  FExtLineType1 := nil;

  FExtLineType2.Free;
  FExtLineType2 := nil;
    
  inherited;
end;



procedure TUdDimLinesProp.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

  FColor.SetDocument(Self.Document, False);
  FLineType.SetDocument(Self.Document, False);

  FExtColor.SetDocument(Self.Document, False);
  FExtLineType1.SetDocument(Self.Document, False);
  FExtLineType2.SetDocument(Self.Document, False);     
end;


procedure TUdDimLinesProp.OnFieldChanged(Sender: TObject; APropName: string);
begin
  if Sender = FColor       then Self.RaiseAfterModifyObject('Color') else
  if Sender = FLineType    then Self.RaiseAfterModifyObject('LineType')    else
  if Sender = FExtColor    then Self.RaiseAfterModifyObject('ExtColor')    else
  if Sender = FExtLineType1 then Self.RaiseAfterModifyObject('ExtLineType1') else
  if Sender = FExtLineType2 then Self.RaiseAfterModifyObject('ExtLineType2') ;
end;

procedure TUdDimLinesProp.OnFieldChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
begin
  if Sender = FColor       then AAllow := Self.RaiseBeforeModifyObject('Color') else
  if Sender = FLineType    then AAllow := Self.RaiseBeforeModifyObject('LineType')    else
  if Sender = FExtColor    then AAllow := Self.RaiseBeforeModifyObject('ExtColor')    else
  if Sender = FExtLineType1 then AAllow := Self.RaiseBeforeModifyObject('ExtLineType1') else
  if Sender = FExtLineType2 then AAllow := Self.RaiseBeforeModifyObject('ExtLineType2') ;
end;




//----------------------------------------------------------------------------

procedure TUdDimLinesProp.SetColor(const AValue: TUdColor);
begin
  if (FColor <> AValue) and Assigned(AValue) and Self.RaiseBeforeModifyObject('Color'{, Integer(AValue)}) then
  begin
    FColor.Assign(AValue);
    Self.RaiseAfterModifyObject('Color');
  end;
end;

procedure TUdDimLinesProp.SetLineType(const AValue: TUdLineType);
begin
  if (FLineType <> AValue) and Assigned(AValue) and Self.RaiseBeforeModifyObject('LineType'{, Integer(AValue)}) then
  begin
    FLineType.Assign(AValue);
    Self.RaiseAfterModifyObject('LineType');
  end;
end;

procedure TUdDimLinesProp.SetLineWeight(const AValue: TUdLineWeight);
begin
  if (FLineWeight <> AValue) and Self.RaiseBeforeModifyObject('LineWeight') then
  begin
    FLineWeight := AValue;
    Self.RaiseAfterModifyObject('LineWeight');
  end;
end;

procedure TUdDimLinesProp.SetSuppressLine1(const AValue: Boolean);
begin
  if (FSuppressLine1 <> AValue) and Self.RaiseBeforeModifyObject('SuppressLine1') then
  begin
    FSuppressLine1 := AValue;
    Self.RaiseAfterModifyObject('SuppressLine1');
  end;
end;

procedure TUdDimLinesProp.SetSuppressLine2(const AValue: Boolean);
begin
  if (FSuppressLine2 <> AValue) and Self.RaiseBeforeModifyObject('SuppressLine2')  then
  begin
    FSuppressLine2 := AValue;
    Self.RaiseAfterModifyObject('SuppressLine2');
  end;
end;

procedure TUdDimLinesProp.SetExtBeyondTicks(const AValue: Float);
begin
  if (FExtBeyondTicks <> AValue) and (AValue >= 0) and Self.RaiseBeforeModifyObject('ExtBeyondTicks')  then
  begin
    FExtBeyondTicks := AValue;
    Self.RaiseAfterModifyObject('ExtBeyondTicks');
  end;
end;

procedure TUdDimLinesProp.SetBaselineSpacing(const AValue: Float);
begin
  if (FBaselineSpacing <> AValue) and (AValue >= 0) and Self.RaiseBeforeModifyObject('BaselineSpacing') then
  begin
    FBaselineSpacing := AValue;
    Self.RaiseAfterModifyObject('BaselineSpacing');
  end;
end;




//----------------------------------------------------------------------------

procedure TUdDimLinesProp.SetExtColor(const AValue: TUdColor);
begin
  if (FExtColor <> AValue) and Assigned(AValue) and Self.RaiseBeforeModifyObject('ExtColor'{, Integer(AValue)}) then
  begin
    FExtColor.Assign(AValue);
    Self.RaiseAfterModifyObject('ExtColor');
  end;
end;

procedure TUdDimLinesProp.SetExtLineType1(const AValue: TUdLineType);
begin
  if (FExtLineType1 <> AValue) and Assigned(AValue) and Self.RaiseBeforeModifyObject('ExtLineType1'{, Integer(AValue)}) then
  begin
    FExtLineType1.Assign(AValue);
    Self.RaiseAfterModifyObject('ExtLineType1');
  end;
end;

procedure TUdDimLinesProp.SetExtLineType2(const AValue: TUdLineType);
begin
  if (FExtLineType2 <> AValue) and Assigned(AValue) and Self.RaiseBeforeModifyObject('ExtLineType2'{, Integer(AValue)}) then
  begin
    FExtLineType2.Assign(AValue);
    Self.RaiseAfterModifyObject('ExtLineType2');
  end;
end;

procedure TUdDimLinesProp.SetExtLineWeight(const AValue: TUdLineWeight);
begin
  if (FExtLineWeight <> AValue) and Self.RaiseBeforeModifyObject('ExtLineWeight') then
  begin
    FExtLineWeight := AValue;
    Self.RaiseAfterModifyObject('ExtLineWeight');
  end;
end;


procedure TUdDimLinesProp.SetExtBeyondDimLines(const AValue: Float);
begin
  if (FExtBeyondDimLines <> AValue) and (AValue >= 0) and Self.RaiseBeforeModifyObject('ExtBeyondDimLines') then
  begin
    FExtBeyondDimLines := AValue;
    Self.RaiseAfterModifyObject('ExtBeyondDimLines');
  end;
end;

procedure TUdDimLinesProp.SetExtOriginOffset(const AValue: Float);
begin
  if (FExtOriginOffset <> AValue) and (AValue >= 0) and Self.RaiseBeforeModifyObject('ExtOriginOffset') then
  begin
    FExtOriginOffset := AValue;
    Self.RaiseAfterModifyObject('ExtOriginOffset');
  end;
end;

procedure TUdDimLinesProp.SetExtSuppressLine1(const AValue: Boolean);
begin
  if (FExtSuppressLine1 <> AValue) and Self.RaiseBeforeModifyObject('ExtSuppressLine1') then
  begin
    FExtSuppressLine1 := AValue;
    Self.RaiseAfterModifyObject('ExtSuppressLine1');
  end;
end;

procedure TUdDimLinesProp.SetExtSuppressLine2(const AValue: Boolean);
begin
  if (FExtSuppressLine2 <> AValue) and Self.RaiseBeforeModifyObject('ExtSuppressLine2') then
  begin
    FExtSuppressLine2 := AValue;
    Self.RaiseAfterModifyObject('ExtSuppressLine2');
  end;
end;




//--------------------------------------------------------------------------------------------

procedure TUdDimLinesProp.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if AValue.InheritsFrom(TUdDimLinesProp) then
  begin
    FColor.Assign(TUdDimLinesProp(AValue).FColor);
    FLineType.Assign(TUdDimLinesProp(AValue).FLineType);
    FLineWeight        := TUdDimLinesProp(AValue).FLineWeight       ;
    FExtBeyondTicks    := TUdDimLinesProp(AValue).FExtBeyondTicks   ;
    FBaselineSpacing   := TUdDimLinesProp(AValue).FBaselineSpacing  ;
    FSuppressLine1     := TUdDimLinesProp(AValue).FSuppressLine1    ;
    FSuppressLine2     := TUdDimLinesProp(AValue).FSuppressLine2    ;


    FExtColor.Assign(TUdDimLinesProp(AValue).FExtColor);
    FExtLineType1.Assign(TUdDimLinesProp(AValue).FExtLineType1);
    FExtLineType2.Assign(TUdDimLinesProp(AValue).FExtLineType2);
    FExtLineWeight     := TUdDimLinesProp(AValue).FExtLineWeight    ;

    FExtSuppressLine1  := TUdDimLinesProp(AValue).FExtSuppressLine1 ;
    FExtSuppressLine2  := TUdDimLinesProp(AValue).FExtSuppressLine2 ;
    FExtBeyondDimLines := TUdDimLinesProp(AValue).FExtBeyondDimLines;
    FExtOriginOffset   := TUdDimLinesProp(AValue).FExtOriginOffset  ;
  end;
end;


procedure TUdDimLinesProp.SaveToStream(AStream: TStream);
begin
  inherited;

  FColor.SaveToStream(AStream);
  FLineType.SaveToStream(AStream);
  IntToStream(AStream, FLineWeight);
  FloatToStream(AStream, FExtBeyondTicks);
  FloatToStream(AStream, FBaselineSpacing);
  BoolToStream(AStream, FSuppressLine1);
  BoolToStream(AStream, FSuppressLine2);


  FExtColor.SaveToStream(AStream);
  FExtLineType1.SaveToStream(AStream);
  FExtLineType2.SaveToStream(AStream);
  IntToStream(AStream, FExtLineWeight);

  BoolToStream(AStream, FExtSuppressLine1);
  BoolToStream(AStream, FExtSuppressLine2);
  FloatToStream(AStream, FExtBeyondDimLines);
  FloatToStream(AStream, FExtOriginOffset);

end;

procedure TUdDimLinesProp.LoadFromStream(AStream: TStream);
begin
  inherited;

  FColor.LoadFromStream(AStream);
  FLineType.LoadFromStream(AStream);
  FLineWeight        := TUdLineWeight(IntFromStream(AStream));
  FExtBeyondTicks    := FloatFromStream(AStream);
  FBaselineSpacing   := FloatFromStream(AStream);
  FSuppressLine1     := BoolFromStream(AStream);
  FSuppressLine2     := BoolFromStream(AStream);


  FExtColor.LoadFromStream(AStream);
  FExtLineType1.LoadFromStream(AStream);
  FExtLineType2.LoadFromStream(AStream);
  FExtLineWeight     := TUdLineWeight(IntFromStream(AStream));

  FExtSuppressLine1  := BoolFromStream(AStream);
  FExtSuppressLine2  := BoolFromStream(AStream);
  FExtBeyondDimLines := FloatFromStream(AStream);
  FExtOriginOffset   := FloatFromStream(AStream);
end;



procedure TUdDimLinesProp.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FColor.SaveToXml(LXmlNode.Add());
  FLineType.SaveToXml(LXmlNode.Add());

  LXmlNode.Prop['LineWeight']      := IntToStr(FLineWeight);
  LXmlNode.Prop['ExtBeyondTicks']  := FloatToStr(FExtBeyondTicks);
  LXmlNode.Prop['BaselineSpacing'] := FloatToStr(FBaselineSpacing);
  LXmlNode.Prop['SuppressLine1']   := BoolToStr(FSuppressLine1, True);
  LXmlNode.Prop['SuppressLine1']   := BoolToStr(FSuppressLine2, True);

  FExtColor.SaveToXml(LXmlNode.Add(), 'ExtColor');
  FExtLineType1.SaveToXml(LXmlNode.Add(), 'ExtLineType1');
  FExtLineType2.SaveToXml(LXmlNode.Add(), 'ExtLineType2');

  LXmlNode.Prop['ExtLineWeight']   := IntToStr(FExtLineWeight);

  LXmlNode.Prop['ExtSuppressLine1']  := BoolToStr(FExtSuppressLine1, True);
  LXmlNode.Prop['ExtSuppressLine2']  := BoolToStr(FExtSuppressLine2, True);
  LXmlNode.Prop['ExtBeyondDimLines'] := FloatToStr(FExtBeyondDimLines);
  LXmlNode.Prop['ExtOriginOffset']   := FloatToStr(FExtOriginOffset);
end;

procedure TUdDimLinesProp.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FColor.LoadFromXml(LXmlNode.FindItem('Color'));
  FLineType.LoadFromXml(LXmlNode.FindItem('LineType'));

  FLineWeight        := StrToIntDef(LXmlNode.Prop['LineWeight'], LW_BYBLOCK) ;
  FExtBeyondTicks    := StrToFloatDef(LXmlNode.Prop['ExtBeyondTicks'], 1.25) ;
  FBaselineSpacing   := StrToFloatDef(LXmlNode.Prop['BaselineSpacing'], 3.75);
  FSuppressLine1     := StrToBoolDef(LXmlNode.Prop['SuppressLine1'], False)  ;
  FSuppressLine2     := StrToBoolDef(LXmlNode.Prop['SuppressLine2'], False)  ;


  FExtColor.LoadFromXml(LXmlNode.FindItem('ExtColor'));
  FExtLineType1.LoadFromXml(LXmlNode.FindItem('ExtLineType1'));
  FExtLineType2.LoadFromXml(LXmlNode.FindItem('ExtLineType2'));
  
  FExtLineWeight     := StrToIntDef(LXmlNode.Prop['ExtLineWeight'], LW_BYBLOCK) ;

  FExtSuppressLine1  := StrToBoolDef(LXmlNode.Prop['ExtSuppressLine1'], False)  ;
  FExtSuppressLine2  := StrToBoolDef(LXmlNode.Prop['ExtSuppressLine2'], False)  ;
  FExtBeyondDimLines := StrToFloatDef(LXmlNode.Prop['ExtBeyondDimLines'], 1.25) ;
  FExtOriginOffset   := StrToFloatDef(LXmlNode.Prop['ExtBeyondDimLines'], 0.625);
end;





//==============================================================================================
{ TUdDimSymbolArrowsProp }

constructor TUdDimSymbolArrowsProp.Create();
begin
  inherited;

  FArrowFirst      := dakClosedFilled;
  FArrowSecond     := dakClosedFilled;
  FArrowLeader     := dakClosedFilled;
  FArrowSize       := 2.5;

  FCenterMark      := ckCenterMark;
  FMarkSize        := 2.5;

  FArcLenSymbolPos := spSymInFront;
end;

destructor TUdDimSymbolArrowsProp.Destroy;
begin

  inherited;
end;



procedure TUdDimSymbolArrowsProp.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

end;




//--------------------------------------------------------------------------------------

procedure TUdDimSymbolArrowsProp.SetArrowFirst(const AValue: TUdDimArrowKind);
begin
  if (FArrowFirst <> AValue) and Self.RaiseBeforeModifyObject('ArrowFirst') then
  begin
    FArrowFirst := AValue;
    Self.RaiseAfterModifyObject('ArrowFirst');
  end;
end;

procedure TUdDimSymbolArrowsProp.SetArrowSecond(const AValue: TUdDimArrowKind);
begin
  if (FArrowSecond <> AValue) and Self.RaiseBeforeModifyObject('ArrowSecond') then
  begin
    FArrowSecond := AValue;
    Self.RaiseAfterModifyObject('ArrowSecond');
  end;
end;

procedure TUdDimSymbolArrowsProp.SetArrowLeader(const AValue: TUdDimArrowKind);
begin
  if (FArrowLeader <> AValue) and Self.RaiseBeforeModifyObject('ArrowLeader') then
  begin
    FArrowLeader := AValue;
    Self.RaiseAfterModifyObject('ArrowLeader');
  end;
end;

procedure TUdDimSymbolArrowsProp.SetArrowSize(const AValue: Float);
begin
  if (FArrowSize <> AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('ArrowSize') then
  begin
    FArrowSize := AValue;
    Self.RaiseAfterModifyObject('ArrowSize');
  end;
end;



procedure TUdDimSymbolArrowsProp.SetCenterMark(const AValue: TUdDimCenterKind);
begin
  if (FCenterMark <> AValue) and Self.RaiseBeforeModifyObject('CenterMark') then
  begin
    FCenterMark := AValue;
    Self.RaiseAfterModifyObject('CenterMark');
  end;
end;

procedure TUdDimSymbolArrowsProp.SetMarkSize(const AValue: Float);
begin
  if (FMarkSize <> AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('MarkSize') then
  begin
    FMarkSize := AValue;
    Self.RaiseAfterModifyObject('MarkSize');
  end;
end;


procedure TUdDimSymbolArrowsProp.SetArcLenSymbolPos(const AValue: TUdSymbolPosition);
begin
  if (FArcLenSymbolPos <> AValue) and Self.RaiseBeforeModifyObject('ArcLenSymbolPos') then
  begin
    FArcLenSymbolPos := AValue;
    Self.RaiseAfterModifyObject('ArcLenSymbolPos');
  end;
end;




//--------------------------------------------------------------------------------------------


procedure TUdDimSymbolArrowsProp.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if AValue.InheritsFrom(TUdDimSymbolArrowsProp) then
  begin
    FArrowFirst      := TUdDimSymbolArrowsProp(AValue).FArrowFirst     ;
    FArrowSecond     := TUdDimSymbolArrowsProp(AValue).FArrowSecond    ;
    FArrowLeader     := TUdDimSymbolArrowsProp(AValue).FArrowLeader    ;
    FArrowSize       := TUdDimSymbolArrowsProp(AValue).FArrowSize      ;

    FCenterMark      := TUdDimSymbolArrowsProp(AValue).FCenterMark     ;
    FMarkSize        := TUdDimSymbolArrowsProp(AValue).FMarkSize       ;

    FArcLenSymbolPos := TUdDimSymbolArrowsProp(AValue).FArcLenSymbolPos;
  end
end;


procedure TUdDimSymbolArrowsProp.SaveToStream(AStream: TStream);
begin
  inherited;

  ByteToStream(AStream, Ord(FArrowFirst) );
  ByteToStream(AStream, Ord(FArrowSecond) );
  ByteToStream(AStream, Ord(FArrowLeader) );
  FloatToStream(AStream, FArrowSize);

  IntToStream(AStream, Ord(FCenterMark));
  FloatToStream(AStream, FMarkSize);

  IntToStream(AStream, Ord(FArcLenSymbolPos));
end;

procedure TUdDimSymbolArrowsProp.LoadFromStream(AStream: TStream);
begin
  inherited;

  FArrowFirst      :=  TUdDimArrowKind( ByteFromStream(AStream) );
  FArrowSecond     :=  TUdDimArrowKind( ByteFromStream(AStream) );
  FArrowLeader     :=  TUdDimArrowKind( ByteFromStream(AStream) );
  FArrowSize       :=  FloatFromStream(AStream);

  FCenterMark      :=  TUdDimCenterKind(IntFromStream(AStream));
  FMarkSize        :=  FloatFromStream(AStream);

  FArcLenSymbolPos :=  TUdSymbolPosition(IntFromStream(AStream));
end;





procedure TUdDimSymbolArrowsProp.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['ArrowFirst '] := IntToStr(Ord(FArrowFirst));
  LXmlNode.Prop['ArrowSecond'] := IntToStr(Ord(FArrowSecond));
  LXmlNode.Prop['ArrowLeader'] := IntToStr(Ord(FArrowLeader));
  LXmlNode.Prop['ArrowSize']   := FloatToStr(FArrowSize);

  LXmlNode.Prop['CenterMark']  := IntToStr(Ord(FCenterMark));
  LXmlNode.Prop['MarkSize']    := FloatToStr(FMarkSize);

  LXmlNode.Prop['ArcLenSymbolPos']  := IntToStr(Ord(FArcLenSymbolPos));
end;

procedure TUdDimSymbolArrowsProp.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FArrowFirst      :=  TUdDimArrowKind( StrToIntDef(LXmlNode.Prop['ArrowFirst '], 0) );
  FArrowSecond     :=  TUdDimArrowKind( StrToIntDef(LXmlNode.Prop['ArrowSecond'], 0) );
  FArrowLeader     :=  TUdDimArrowKind( StrToIntDef(LXmlNode.Prop['ArrowLeader'], 0) );
  FArrowSize       :=  StrToFloatDef(LXmlNode.Prop['ArrowSize'], 2.5) ;

  FCenterMark      :=  TUdDimCenterKind(StrToIntDef(LXmlNode.Prop['CenterMark'], 0));
  FMarkSize        :=  StrToFloatDef(LXmlNode.Prop['MarkSize'], 2.5) ;

  FArcLenSymbolPos :=  TUdSymbolPosition(StrToIntDef(LXmlNode.Prop['ArcLenSymbolPos'], 0));
end;





//==============================================================================================
{ TUdDimTextProp }

constructor TUdDimTextProp.Create();
begin
  inherited;

  FTextStyle          := '';
  FTextHeight         := 2.5;
  FDrawFrame          := False;

  FVerticalPosition   := vtpAbove;
  FHorizontalPosition := htpCentered;
  FOffsetFromDimLine  := 0.625;

  FInsideAlign        := True;
  FOutsideAlign       := True;


  FFillColor := TUdColor.Create({Self.Document, False});
  FFillColor.Owner := Self;
  FFillColor.ColorType := ctNone;
  FFillColor.OnChanged  := OnFieldChanged;
  FFillColor.OnChanging := OnFieldChanging;  

  FTextColor := TUdColor.Create();
  FFillColor.Owner := Self;
  FTextColor.ByKind := bkByBlock;  
  FTextColor.OnChanged := OnFieldChanged;
  FTextColor.OnChanging := OnFieldChanging;  
end;

destructor TUdDimTextProp.Destroy;
begin
  if Assigned(FTextColor) then FTextColor.Free;
  FTextColor := nil;

  if Assigned(FFillColor) then FFillColor.Free;
  FFillColor := nil;

  inherited;
end;


procedure TUdDimTextProp.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

  if Assigned(FTextColor) then FTextColor.SetDocument(Self.Document, False);
  if Assigned(FFillColor) then FFillColor.SetDocument(Self.Document, False);
end;



procedure TUdDimTextProp.OnFieldChanged(Sender: TObject; APropName: string);
begin
  if Assigned(Sender) then
  begin
    if Sender = FFillColor then Self.RaiseAfterModifyObject('FillColor') else
    if Sender = FTextColor then Self.RaiseAfterModifyObject('TextColor') ;
  end;
end;

procedure TUdDimTextProp.OnFieldChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
begin
  if Assigned(Sender) then
  begin
    if Sender = FFillColor then AAllow := Self.RaiseBeforeModifyObject('FillColor') else
    if Sender = FTextColor then AAllow := Self.RaiseBeforeModifyObject('TextColor') ;
  end;
end;



//-------------------------------------------------------------------------------

procedure TUdDimTextProp.SetTextStyle(const AValue: string);
begin
  if (FTextStyle <> AValue) and Self.RaiseBeforeModifyObject('TextStyle') then
  begin
    FTextStyle := AValue;
    Self.RaiseAfterModifyObject('TextStyle');
  end;
end;

procedure TUdDimTextProp.SetTextColor(const AValue: TUdColor);
begin
  if (FTextColor <> AValue) and Assigned(AValue) and Self.RaiseBeforeModifyObject('TextColor'{, Integer(AValue)}) then
  begin
    FTextColor.Assign(AValue);
    Self.RaiseAfterModifyObject('TextColor');
  end;
end;

procedure TUdDimTextProp.SetFillColor(const AValue: TUdColor);
begin
  if (FFillColor <> AValue) and Self.RaiseBeforeModifyObject('FillColor'{, Integer(AValue)}) then
  begin
    FFillColor.Assign(AValue);
    Self.RaiseAfterModifyObject('FillColor');
  end;
end;

procedure TUdDimTextProp.SetTextHeight(const AValue: Float);
begin
  if (FTextHeight <> AValue) and Self.RaiseBeforeModifyObject('TextHeight') then
  begin
    FTextHeight := AValue;
    Self.RaiseAfterModifyObject('TextHeight');
  end;
end;

procedure TUdDimTextProp.SetDrawFrame(const AValue: Boolean);
begin
  if (FDrawFrame <> AValue) and Self.RaiseBeforeModifyObject('DrawFrame') then
  begin
    FDrawFrame := AValue;
    Self.RaiseAfterModifyObject('DrawFrame');
  end;
end;




procedure TUdDimTextProp.SetHorizontalPosition(const AValue: TUdHorizontalTextPoint);
begin
  if (FHorizontalPosition <> AValue) and Self.RaiseBeforeModifyObject('HorizontalPosition') then
  begin
    FHorizontalPosition := AValue;
    Self.RaiseAfterModifyObject('HorizontalPosition');
  end;
end;


procedure TUdDimTextProp.SetVerticalPosition(const AValue: TUdVerticalTextPoint);
begin
  if (FVerticalPosition <> AValue) and Self.RaiseBeforeModifyObject('VerticalPosition') then
  begin
    FVerticalPosition := AValue;
    Self.RaiseAfterModifyObject('VerticalPosition');
  end;
end;

procedure TUdDimTextProp.SetOffsetFromDimLine(const AValue: Float);
begin
  if (FOffsetFromDimLine <> AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('OffsetFromDimLine') then
  begin
    FOffsetFromDimLine := AValue;
    Self.RaiseAfterModifyObject('OffsetFromDimLine');
  end;
end;




procedure TUdDimTextProp.SetInsideAlign(const AValue: Boolean);
begin
  if (FInsideAlign <> AValue) and Self.RaiseBeforeModifyObject('InsideAlign') then
  begin
    FInsideAlign := AValue;
    Self.RaiseAfterModifyObject('InsideAlign');
  end;
end;

procedure TUdDimTextProp.SetOutsideAlign(const AValue: Boolean);
begin
  if (FOutsideAlign <> AValue) and Self.RaiseBeforeModifyObject('OutsideAlign') then
  begin
    FOutsideAlign := AValue;
    Self.RaiseAfterModifyObject('OutsideAlign');
  end;
end;





//--------------------------------------------------------------------------------------------

procedure TUdDimTextProp.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if AValue.InheritsFrom(TUdDimTextProp) then
  begin
    FTextStyle := TUdDimTextProp(AValue).FTextStyle;
    FTextColor.Assign(TUdDimTextProp(AValue).FTextColor);
    FFillColor.Assign(TUdDimTextProp(AValue).FFillColor);

    FTextHeight         := TUdDimTextProp(AValue).FTextHeight;
    FDrawFrame          := TUdDimTextProp(AValue).FDrawFrame;

    FVerticalPosition   := TUdDimTextProp(AValue).FVerticalPosition  ;
    FHorizontalPosition := TUdDimTextProp(AValue).FHorizontalPosition;
    FOffsetFromDimLine  := TUdDimTextProp(AValue).FOffsetFromDimLine ;

    FInsideAlign        := TUdDimTextProp(AValue).FInsideAlign;
    FOutsideAlign       := TUdDimTextProp(AValue).FOutsideAlign;
  end
end;


procedure TUdDimTextProp.SaveToStream(AStream: TStream);
begin
  inherited;

  StrToStream(AStream, FTextStyle);
  FTextColor.SaveToStream(AStream);

  BoolToStream(AStream, (FFillColor.ColorType <> ctNone));
  if (FFillColor.ColorType <> ctNone) then FFillColor.SaveToStream(AStream);

  FloatToStream(AStream, FTextHeight );
  BoolToStream(AStream, FDrawFrame   );

  IntToStream(AStream, Ord(FVerticalPosition) );
  IntToStream(AStream, Ord(FHorizontalPosition) );
  FloatToStream(AStream, FOffsetFromDimLine );

  BoolToStream(AStream, FInsideAlign );
  BoolToStream(AStream, FOutsideAlign);
end;

procedure TUdDimTextProp.LoadFromStream(AStream: TStream);
begin
  inherited;

  FTextStyle :=  StrFromStream(AStream);
  FTextColor.LoadFromStream(AStream);

  if BoolFromStream(AStream) then FFillColor.LoadFromStream(AStream) else FFillColor.ColorType := ctNone;


  FTextHeight   := FloatFromStream(AStream);
  FDrawFrame    := BoolFromStream(AStream);

  FVerticalPosition    :=  TUdVerticalTextPoint(IntFromStream(AStream));
  FHorizontalPosition  :=  TUdHorizontalTextPoint(IntFromStream(AStream));
  FOffsetFromDimLine   :=  FloatFromStream(AStream);

  FInsideAlign  :=  BoolFromStream(AStream);
  FOutsideAlign :=  BoolFromStream(AStream);
end;





procedure TUdDimTextProp.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['TextStyle']  := FTextStyle;
  FTextColor.SaveToXml(LXmlNode.Add(), 'TextColor');

  if (FFillColor.ColorType <> ctNone) then
    FFillColor.SaveToXml(LXmlNode.Add(), 'FillColor');

  LXmlNode.Prop['TextHeight']        := FloatToStr(FTextHeight);
  LXmlNode.Prop['DrawFrame']         := BoolToStr(FDrawFrame, True);

  LXmlNode.Prop['VerticalPosition']  := FloatToStr(Ord(FVerticalPosition));
  LXmlNode.Prop['HorizontalPosition']:= IntToStr(Ord(FHorizontalPosition));
  LXmlNode.Prop['OffsetFromDimLine'] := FloatToStr(FOffsetFromDimLine);

  LXmlNode.Prop['InsideAlign']       := BoolToStr(FInsideAlign, True);
  LXmlNode.Prop['OutsideAlign']      := BoolToStr(FOutsideAlign, True);
end;

procedure TUdDimTextProp.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);


  FTextStyle := LXmlNode.Prop['TextStyle'];
  FTextColor.LoadFromXml(LXmlNode.FindItem('TextColor'));

  if LXmlNode.FindItem('FillColor') <> nil then
    FFillColor.LoadFromXml(LXmlNode.FindItem('FillColor'))
  else
    FFillColor.ColorType := ctNone;

  FTextHeight          :=  StrToFloatDef(LXmlNode.Prop['TextHeight'], 2.5)  ;
  FDrawFrame           :=  StrToBoolDef(LXmlNode.Prop['DrawFrame'], False)  ;

  FVerticalPosition    :=  TUdVerticalTextPoint(StrToIntDef(LXmlNode.Prop['VerticalPosition'], 1)) ;
  FHorizontalPosition  :=  TUdHorizontalTextPoint(StrToIntDef(LXmlNode.Prop['HorizontalPosition'], 0)) ;
  FOffsetFromDimLine   :=  StrToFloatDef(LXmlNode.Prop['OffsetFromDimLine'], 0.625) ;

  FInsideAlign         :=  StrToBoolDef(LXmlNode.Prop['InsideAlign'], True);
  FOutsideAlign        :=  StrToBoolDef(LXmlNode.Prop['OutsideAlign'], True);
end;





//==============================================================================================
{ TUdDimUnitsProp }

constructor TUdDimUnitsProp.Create();
begin
  inherited;

  FUnitFormat         := luDecimal;
  FPrecision          := 2;
  FDecimal            := ',';
  FRoundOff           := 0;

  FPrefix             := '';
  FSuffix             := '';

  if Self.ClassType = TUdDimAltUnitsProp then
    FMeasurementScale        := 0.03937
  else
    FMeasurementScale        := 1.0;

  FAltPlacement       := apAfterPrimary;

  FSuppressLeading    := False;
  FSuppressTrailing   := True;


  FAngUnitFormat := auDegrees;
  FAngPrecision  := 0;

  FAngSuppressLeading  := False;
  FAngSuppressTrailing := False;
end;

destructor TUdDimUnitsProp.Destroy;
begin

  inherited;
end;




procedure TUdDimUnitsProp.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;

end;

//--------------------------------------------------------------------------------------------


procedure TUdDimUnitsProp.SetUnitFormat(const AValue: TUdLengthUnit);
begin
  if (FUnitFormat <> AValue) and Self.RaiseBeforeModifyObject('UnitFormat') then
  begin
    FUnitFormat := AValue;
    Self.RaiseAfterModifyObject('UnitFormat');
  end;
end;

procedure TUdDimUnitsProp.SetPrecision(const AValue: Byte);
begin
  if (FPrecision <> AValue) and Self.RaiseBeforeModifyObject('Precision') then
  begin
    FPrecision := AValue;
    Self.RaiseAfterModifyObject('Precision');
  end;
end;

procedure TUdDimUnitsProp.SetDecimal(const AValue: Char);
begin
  if (FDecimal <> AValue) and Self.RaiseBeforeModifyObject('Decimal') then
  begin
    FDecimal := AValue;
    Self.RaiseAfterModifyObject('Decimal');
  end;
end;

procedure TUdDimUnitsProp.SetRoundOff(const AValue: Float);
begin
  if (FRoundOff <> AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('RoundOff')  then
  begin
    FRoundOff := AValue;
    Self.RaiseAfterModifyObject('RoundOff');
  end;
end;




procedure TUdDimUnitsProp.SetPrefix(const AValue: string);
begin
  if (FPrefix <> AValue) and Self.RaiseBeforeModifyObject('Prefix')  then
  begin
    FPrefix := AValue;
    Self.RaiseAfterModifyObject('Prefix');
  end;
end;

procedure TUdDimUnitsProp.SetSuffix(const AValue: string);
begin
  if (FSuffix <> AValue) and Self.RaiseBeforeModifyObject('Suffix')  then
  begin
    FSuffix := AValue;
    Self.RaiseAfterModifyObject('Suffix');
  end;
end;



procedure TUdDimUnitsProp.SetMeasurementScale(const AValue: Float);
begin
  if (FMeasurementScale <> AValue) and (AValue > 0) and Self.RaiseBeforeModifyObject('MeasurementScale')  then
  begin
    FMeasurementScale := AValue;
    Self.RaiseAfterModifyObject('MeasurementScale');
  end;
end;

procedure TUdDimUnitsProp.SetAltPlacement(const AValue: TUdAltPlacement);
begin
  if (FAltPlacement <> AValue) and Self.RaiseBeforeModifyObject('AltPlacement')  then
  begin
    FAltPlacement := AValue;
    Self.RaiseAfterModifyObject('AltPlacement');
  end;
end;


procedure TUdDimUnitsProp.SetSuppressLeading(const AValue: Boolean);
begin
  if (FSuppressLeading <> AValue) and Self.RaiseBeforeModifyObject('SuppressLeading')  then
  begin
    FSuppressLeading := AValue;
    Self.RaiseAfterModifyObject('SuppressLeading');
  end;
end;

procedure TUdDimUnitsProp.SetSuppressTrailing(const AValue: Boolean);
begin
  if (FSuppressTrailing <> AValue) and Self.RaiseBeforeModifyObject('SuppressTrailing')  then
  begin
    FSuppressTrailing := AValue;
    Self.RaiseAfterModifyObject('SuppressTrailing');
  end;
end;





procedure TUdDimUnitsProp.SetAngUnitFormat(const AValue: TUdAngleUnit);
begin
  if (FAngUnitFormat <> AValue) and Self.RaiseBeforeModifyObject('AngUnitFormat')  then
  begin
    FAngUnitFormat := AValue;
    Self.RaiseAfterModifyObject('AngUnitFormat');
  end;
end;

procedure TUdDimUnitsProp.SetAngPrecision(const AValue: Byte);
begin
  if (FAngPrecision <> AValue) and Self.RaiseBeforeModifyObject('AngPrecision')  then
  begin
    FAngPrecision := AValue;
    Self.RaiseAfterModifyObject('AngPrecision');
  end;
end;


procedure TUdDimUnitsProp.SetAngSuppressLeading(const AValue: Boolean);
begin
  if (FAngSuppressLeading <> AValue) and Self.RaiseBeforeModifyObject('AngSuppressLeading')  then
  begin
    FAngSuppressLeading := AValue;
    Self.RaiseAfterModifyObject('AngSuppressLeading');
  end;
end;

procedure TUdDimUnitsProp.SetAngSuppressTrailing(const AValue: Boolean);
begin
  if (FAngSuppressTrailing <> AValue) and Self.RaiseBeforeModifyObject('AngSuppressTrailing') then
  begin
    FAngSuppressTrailing := AValue;
    Self.RaiseAfterModifyObject('AngSuppressTrailing');
  end;
end;






//--------------------------------------------------------------------------------------------

procedure TUdDimUnitsProp.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if AValue.InheritsFrom(TUdDimUnitsProp) then
  begin
    FUnitFormat         := TUdDimUnitsProp(AValue).FUnitFormat        ;
    FPrecision          := TUdDimUnitsProp(AValue).FPrecision         ;
    FDecimal            := TUdDimUnitsProp(AValue).FDecimal           ;
    FRoundOff           := TUdDimUnitsProp(AValue).FRoundOff          ;

    FPrefix             := TUdDimUnitsProp(AValue).FPrefix            ;
    FSuffix             := TUdDimUnitsProp(AValue).FSuffix            ;

    MeasurementScale    := TUdDimUnitsProp(AValue).MeasurementScale   ;
    FAltPlacement       := TUdDimUnitsProp(AValue).FAltPlacement      ;

    FSuppressLeading    := TUdDimUnitsProp(AValue).FSuppressLeading   ;
    FSuppressTrailing   := TUdDimUnitsProp(AValue).FSuppressTrailing  ;

    FAngUnitFormat      := TUdDimUnitsProp(AValue).FAngUnitFormat   ;
    FAngPrecision       := TUdDimUnitsProp(AValue).FAngPrecision  ;
        
    FAngSuppressLeading   := TUdDimUnitsProp(AValue).FAngSuppressLeading  ;
    FAngSuppressTrailing := TUdDimUnitsProp(AValue).FAngSuppressTrailing;
  end
end;


procedure TUdDimUnitsProp.SaveToStream(AStream: TStream);
begin
  inherited;

  ByteToStream(AStream, Ord(FUnitFormat) );
  ByteToStream(AStream, FPrecision);
  ByteToStream(AStream, Ord(FDecimal));
  FloatToStream(AStream, FRoundOff );

  StrToStream(AStream, FPrefix);
  StrToStream(AStream, FSuffix);

  FloatToStream(AStream, FMeasurementScale);
  ByteToStream(AStream,  Ord(FAltPlacement) );

  BoolToStream(AStream, FSuppressLeading );
  BoolToStream(AStream, FSuppressTrailing);

  ByteToStream(AStream,  Ord(FAngUnitFormat) );
  ByteToStream(AStream, FAngPrecision);

  BoolToStream(AStream, FAngSuppressLeading );
  BoolToStream(AStream, FAngSuppressTrailing);
end;

procedure TUdDimUnitsProp.LoadFromStream(AStream: TStream);
begin
  inherited;

  FUnitFormat         := TUdLengthUnit(ByteFromStream(AStream));
  FPrecision          := ByteFromStream(AStream);
  FDecimal            := Chr(ByteFromStream(AStream));
  FRoundOff           := FloatFromStream(AStream);

  FPrefix             := StrFromStream(AStream);
  FSuffix             := StrFromStream(AStream);

  FMeasurementScale   := FloatFromStream(AStream);
  FAltPlacement       := TUdAltPlacement(ByteFromStream(AStream));

  FSuppressLeading    := BoolFromStream(AStream);
  FSuppressTrailing   := BoolFromStream(AStream);


  FAngUnitFormat      := TUdAngleUnit(ByteFromStream(AStream));
  FAngPrecision       := ByteFromStream(AStream);

  FAngSuppressLeading  := BoolFromStream(AStream);
  FAngSuppressTrailing := BoolFromStream(AStream);
end;





procedure TUdDimUnitsProp.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['UnitFormat']   := IntToStr(Ord(FUnitFormat));
  LXmlNode.Prop['Precision']    := IntToStr(FPrecision);
  LXmlNode.Prop['Decimal']      := IntToStr(Ord(FDecimal));
  LXmlNode.Prop['RoundOff']     := FloatToStr(FRoundOff);

  LXmlNode.Prop['Prefix']       := FPrefix;
  LXmlNode.Prop['Suffix']       := FSuffix;

  LXmlNode.Prop['MeasurementScale'] := FloatToStr(FMeasurementScale);
  LXmlNode.Prop['AltPlacement']     := IntToStr(Ord(FAltPlacement));

  LXmlNode.Prop['SuppressLeading']  := BoolToStr(FSuppressLeading, True );
  LXmlNode.Prop['SuppressTrailing'] := BoolToStr(FSuppressTrailing, True);

  LXmlNode.Prop['AngUnitFormat']    := IntToStr(Ord(FAngUnitFormat));
  LXmlNode.Prop['AngPrecision']     := IntToStr(FAngPrecision);

  LXmlNode.Prop['AngSuppressLeading']  := BoolToStr(FAngSuppressLeading, True );
  LXmlNode.Prop['AngSuppressTrailing'] := BoolToStr(FAngSuppressTrailing, True);
end;

procedure TUdDimUnitsProp.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FUnitFormat         := TUdLengthUnit(StrToIntDef(LXmlNode.Prop['UnitFormat'], 1));
  FPrecision          := StrToIntDef(LXmlNode.Prop['Precision'], 2);
  FDecimal            := Chr((StrToIntDef(LXmlNode.Prop['Decimal'], Ord(','))));
  FRoundOff           := StrToFloatDef(LXmlNode.Prop['RoundOff'], 0);

  FPrefix             := LXmlNode.Prop['Prefix'] ;
  FSuffix             := LXmlNode.Prop['Suffix'] ;

  FMeasurementScale   := StrToFloatDef(LXmlNode.Prop['MeasurementScale'], 1.0);
  FAltPlacement       := TUdAltPlacement(StrToIntDef(LXmlNode.Prop['AltPlacement'], 0));

  FSuppressLeading    := StrToBoolDef(LXmlNode.Prop['SuppressLeading'], False);
  FSuppressTrailing   := StrToBoolDef(LXmlNode.Prop['SuppressTrailing'], False);


  FAngUnitFormat      := TUdAngleUnit(StrToIntDef(LXmlNode.Prop['AngUnitFormat'], 0));
  FAngPrecision       := StrToIntDef(LXmlNode.Prop['AngPrecision'], 0);

  FAngSuppressLeading  := StrToBoolDef(LXmlNode.Prop['AngSuppressLeading'], False);
  FAngSuppressTrailing := StrToBoolDef(LXmlNode.Prop['AngSuppressTrailing'], False);
end;



end.