{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimension;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics,
  UdTypes, UdGTypes, UdConsts, UdIntfs, UdObject, UdAxes, UdEntity,
  UdColor, UdLineType, UdDimProps, UdDimStyle, UdText;


const
  DIM_TEXT_SIDE_OFFSET = 2.5;


type
  IUdDimLineSupport = interface
  ['{57762D2C-1958-43F3-BF0C-50B49871C627}']

    function GetDimLine1Point(): TPoint2D;
    function GetDimLine2Point(): TPoint2D;
  end;


  TUdDimTextKind = (dtkNormal, dtkAngle, dtkArcLen, dtkRaidus, dtkDiameter);

  //*** TUdDimension ***//
  TUdDimension = class(TUdEntity, IUdChildEntities)
  protected
    FDimStyle: TUdDimStyle;

    FLinesProp  : TUdDimLinesProp;
    FArrowsProp : TUdDimSymbolArrowsProp;
    FTextProp   : TUdDimTextProp;
    FUnitsProp  : TUdDimUnitsProp;
    FAltUnitsProp: TUdDimAltUnitsProp;

    FExtLineFixed: Boolean;
    FExtLineFixedLen: Float;

    FMeasurement     : Float;
    FTextAngle       : Float;
    FTextOverride    : string;
    FAltUnitsEnabled : Boolean;

    FBlockName: string;
    FEntityList: TList;

    FGripTextPnt: TPoint2D;

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; virtual; abstract;
    function GetDimTextPoint(): TPoint2D;

    procedure OnPropChanged(Sender: TObject; APropName: string);
    procedure OnPropChanging(Sender: TObject; APropName: string; var AAllow: Boolean);

    procedure StatesChanged(AIndex: Integer); override;

    function FSetDimStyle(const AValue: TUdDimStyle): Boolean;
    procedure SetDimStyle(const AValue: TUdDimStyle);

    procedure SetExtLineFixed(const AValue: Boolean);
    procedure SetExtLineFixedLen(const AValue: Float);

    procedure SetTextPoint(const AValue: TPoint2D); virtual;
    procedure SetTextAngle(const AValue: Float); virtual;
    procedure SetTextOverride(const AValue: string); virtual;
    procedure SetAltUnitsEnabled(const AValue: Boolean); virtual;

    function UpdateDim(AAxes: TUdAxes): Boolean; virtual;
    function DoUpdate(AAxes: TUdAxes): Boolean; override;

    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;


    function CreateDimLineWithArrow(AP1, AP2: TPoint2D; AKind1, AKind2: TUdArrowStyle): TUdEntityArray;
    function CreateDimLine(AP1, AP2: TPoint2D; AIsExt: Boolean; AIndex: Integer = 0): TUdEntity;
    function CreateExtLines(AExtP1, AExtP2, ADimP1, ADimP2: TPoint2D): TUdEntityArray;

    function TextAngleValid(AAngle: Float): Boolean;

    function UpdateTextPosition(ATextObj: TUdText; ATextAlign: Boolean; ATextPnt: TPoint2D; ATextAng: Float): Boolean;
    function UpdateInsideTextPosition(ATextEntity: TUdText; ATextPnt: TPoint2D; ATextAngle: Float; AIsArc: Boolean; var ANeedInctBound: Boolean): Boolean;
    function UpdateOutsideTextPosition(ATextEntity: TUdText; ATextPnt: TPoint2D; ATextAngle: Float; APntInCircle: Boolean; var ANeedInctBound: Boolean): Boolean;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetOSnapPoints(): TUdOSnapPointArray; override;

    {IUdChildEntities...}
    function GetChildEntities(): TList;

        
    function GetDimText(const AValue: Float; AKind: TUdDimTextKind): string;
    function UpdateByEntity(AEntity: TUdEntity): Boolean; virtual;
    function UpdateByDimStyle(ADimStyle: TObject): Boolean;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;


    {operation...}
    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;


  public
    property DimTextPoint : TPoint2D read GetDimTextPoint;
    property DimTypeID    : Integer  read GetDimTypeID;
    property EntityList   : TList    read FEntityList;
    property BlockName    : string   read FBlockName write FBlockName;


  published
    property DimStyle     : TUdDimStyle            read FDimStyle     write SetDimStyle;

    property LinesProp    : TUdDimLinesProp        read FLinesProp    write FLinesProp  ;
    property ArrowsProp   : TUdDimSymbolArrowsProp read FArrowsProp   write FArrowsProp ;
    property TextProp     : TUdDimTextProp         read FTextProp     write FTextProp   ;
    property UnitsProp    : TUdDimUnitsProp        read FUnitsProp    write FUnitsProp  ;
    property AltUnitsProp : TUdDimAltUnitsProp     read FAltUnitsProp write FAltUnitsProp;

    property Measurement     : Float   read FMeasurement;
    property TextAngle       : Float   read FTextAngle       write SetTextAngle      ;
    property TextOverride    : string  read FTextOverride    write SetTextOverride   ;
    property AltUnitsEnabled : Boolean read FAltUnitsEnabled write SetAltUnitsEnabled;

    property ExtLineFixed   : Boolean  read FExtLineFixed    write SetExtLineFixed   ;
    property ExtLineFixedLen: Float    read FExtLineFixedLen write SetExtLineFixedLen;
  end;



implementation


uses
  SysUtils,
  UdDocument, UdUnits, UdLine, UdPoint, UdSolid, UdBlock, UdInsert,
  UdMath, UdGeo2D, UdStreams, UdXml, UdUtils, UdStrConverter;


const
  MAX_OSNP_COUNT = 24;



function GetArrowBlockName(AValue: TUdArrowStyle): string;
begin
  Result := '';

  case AValue of
    asClosedBlank      : Result := '_ClosedBlank' ;
    asClosed           : Result := '_Closed'      ;
    asDot              : Result := '_Dot'         ;
    asArchTick         : Result := '_ArchTick'    ;
    asOblique          : Result := '_Oblique'     ;
    asOpen             : Result := '_Open'        ;
    asOriginIndicator  : Result := '_Origin'      ;
    asOriginIndicator2 : Result := '_Origin2'     ;
    asRightAngle       : Result := '_Open90'      ;
    asOpen30           : Result := '_Open30'      ;
    asDotSmall         : Result := '_DotSmall'    ;
    asDotBlank         : Result := '_DotBlank'    ;
    asDotSmallBlank    : Result := '_Small'       ;
    asBox              : Result := '_BoxBlank'    ;
    asBoxFilled        : Result := '_BoxFilled'   ;
    asDutumTriangle    : Result := '_DatumBlank'  ;
    asDutumTriFilled   : Result := '_DatumFilled' ;
    asIntegral         : Result := '_Integral'    ;
  end;
end;




//=================================================================================================
{ TUdDimension }

constructor TUdDimension.Create();
begin
  inherited;

  FDimStyle     := nil;

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

  //if Assigned(ADocument) then Self.FSetDimStyle(TUdDocument(ADocument).DimStyles.Active);

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


  FExtLineFixed := False;
  FExtLineFixedLen := 1.25;

  FMeasurement  := -1.0;
  FTextOverride := '';
  FTextAngle    := -1.0;

  FAltUnitsEnabled := False;

  FEntityList := TList.Create;

  FGripTextPnt := UdMath.InvalidPoint();
end;

destructor TUdDimension.Destroy;
begin
  ClearObjectList(FEntityList);

  FEntityList.Free;
  FEntityList := nil;


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


function TUdDimension.GetTypeID: Integer;
begin
  Result := ID_DIMENTION;
end;


procedure TUdDimension.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
var
  I: Integer;
begin
  inherited;

  if Assigned(AValue) and AValue.InheritsFrom(TUdDocument) then
  begin
    if Assigned(FLinesProp) and Assigned(FArrowsProp) and
       Assigned(FTextProp) and Assigned(FUnitsProp) and Assigned(FAltUnitsProp) then
    begin
      FLinesProp.SetDocument(AValue, False);
      FArrowsProp.SetDocument(AValue, False);
      FTextProp.SetDocument(AValue, False);
      FUnitsProp.SetDocument(AValue, False);
      FAltUnitsProp.SetDocument(AValue, False);
    end;

    if FDimStyle = nil then
      Self.FSetDimStyle(TUdDocument(AValue).DimStyles.Active);
  end;

  for I := 0 to FEntityList.Count - 1 do
    TUdObject(FEntityList[I]).SetDocument(Self.Document, False);    
end;




function TUdDimension.GetDimTextPoint(): TPoint2D;
var
  I: Integer;
begin
  for I := 0 to FEntityList.Count - 1 do
  begin
    if TObject(FEntityList[I]).InheritsFrom(TUdText) then
    begin
      Result := TUdText(FEntityList[I]).Position;
      Exit; //=====>>>>
    end;
  end;

  Result := FGripTextPnt;
end;


function TUdDimension.FSetDimStyle(const AValue: TUdDimStyle): Boolean;
begin
  Result := False;

  FDimStyle := AValue;
  if Assigned(FDimStyle) then
  begin
    FLinesProp.Assign(FDimStyle.LinesProp);
    FArrowsProp.Assign(FDimStyle.ArrowsProp);
    FTextProp.Assign(FDimStyle.TextProp);
    FUnitsProp.Assign(FDimStyle.UnitsProp);
    FAltUnitsProp.Assign(FDimStyle.AltUnitsProp);

    Result := True;
  end;
end;

procedure TUdDimension.SetDimStyle(const AValue: TUdDimStyle);
begin
  if (FDimStyle <> AValue) and Self.RaiseBeforeModifyObject('DimStyle') then
  begin
    Self.BeginUpdate();
    try
      FSetDimStyle(AValue);
    finally
      Self.EndUpdate();
    end;
    Self.RaiseAfterModifyObject('DimStyle');
  end;
end;





//----------------------------------------------------------------------------------------

{
asClosedFilled, #
asClosedBlank,
asClosed,
asDot,
asArchTick,     @
asOblique,      @
asOpen,
asOriginIndicator,
asOriginIndicator2,
asRightAngle,
asOpen30,
asDotSmall,     @
asDotBlank,
asDotSmallBlank,@
asBox,
asBoxFilled,
asDutumTriangle,
asDutumTriFilled,
asIntegral,     @
asNone          #
}

function TUdDimension.CreateDimLineWithArrow(AP1, AP2: TPoint2D; AKind1, AKind2: TUdArrowStyle): TUdEntityArray;

  function _CreateClosedFilledArrow(APnt: TPoint2D; ARotation: Float; AArrowSize: Float): TUdEntity;
  var
    H: Float;
    LSolid: TUdSolid;
  begin
    H := AArrowSize * UdMath.TanD(9);

    LSolid := TUdSolid.Create(Self.Document, False);

    LSolid.BeginUpdate();
    try
      LSolid.Owner := Self;
      LSolid.Color.Assign(FLinesProp.Color);
      LSolid.P1 := ShiftPoint(ShiftPoint(APnt, FixAngle(ARotation+180), AArrowSize), FixAngle(ARotation + 90), H);
      LSolid.P2 := ShiftPoint(ShiftPoint(APnt, FixAngle(ARotation+180), AArrowSize), FixAngle(ARotation - 90), H);
      LSolid.P3 := APnt;
      LSolid.P4 := APnt;
    finally
      LSolid.EndUpdate();
    end;

    Result := LSolid;
  end;

  function _CreateArrowEnt(AKind: TUdArrowStyle; APnt: TPoint2D; ARotation: Float; AArrowSize: Float): TUdEntity;
  var
    LBlock: TUdBlock;
    LInsert: TUdInsert;
    LBlockName: string;
  begin
    Result := nil;
    if AKind = asNone then Exit;

    if AKind = asClosedFilled then Result := _CreateClosedFilledArrow(APnt, ARotation, AArrowSize) else
    if Assigned(Self.Document) then
    begin
      LBlockName := GetArrowBlockName(AKind);
      LBlock := TUdDocument(Self.Document).Blocks.GetItem(LBlockName);
      if Assigned(LBlock) then
      begin
        LInsert := TUdInsert.Create(Self.Document, False);

        LInsert.BeginUpdate();
        try
          LInsert.Owner := Self;
          LInsert.Color.Assign(FLinesProp.Color);
          LInsert.LineType.Assign(FLinesProp.LineType);
          LInsert.LineWeight := FLinesProp.LineWeight;
          LInsert.Block := LBlock;

          LInsert.Position := APnt;
          LInsert.Rotation := ARotation;
          LInsert.ScaleX   := AArrowSize;
          LInsert.ScaleY   := AArrowSize;
        finally
          LInsert.EndUpdate();
        end;

        Result := LInsert;
      end;
    end;
  end;

var
  LAng: Float;
  LSeg: TSegment2D;
  LArrowSize: Float;
  LOverallScale: Float;
  LLineEnt: TUdLine;
  LArrowEnt: TUdEntity;
begin
  SetLength(Result, 1);

  LSeg.P1 := AP1;
  LSeg.P2 := AP2;
  LAng := GetAngle(AP1, AP2);

  LOverallScale := 1.0;
  if Assigned(FDimStyle) then LOverallScale := FDimStyle.OverallScale;

  LArrowSize := FArrowsProp.ArrowSize * LOverallScale;

  if not (AKind1 in [asArchTick, asOblique, asDotSmall, asDotSmallBlank, asIntegral, asNone]) then
    LSeg.P1 := ShiftPoint(AP1, LAng, LArrowSize);

  if not (AKind2 in [asArchTick, asOblique, asDotSmall, asDotSmallBlank, asIntegral, asNone]) then
    LSeg.P2 := ShiftPoint(AP2, LAng+180, LArrowSize);


  LLineEnt := TUdLine.Create(Self.Document, False);
  LLineEnt.BeginUpdate();
  try
    LLineEnt.Owner := Self;
    LLineEnt.Color.Assign(FLinesProp.Color);
    LLineEnt.LineType.Assign(FLinesProp.LineType);
    LLineEnt.LineWeight := FLinesProp.LineWeight;
    LLineEnt.XData := LSeg;
  finally
    LLineEnt.EndUpdate();
  end;
  Result[0] := LLineEnt;

  LArrowEnt := _CreateArrowEnt(AKind2, AP2, LAng, LArrowSize);
  if Assigned(LArrowEnt) then
  begin
    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := LArrowEnt;
  end;

  LArrowEnt := _CreateArrowEnt(AKind1, AP1, FixAngle(LAng+180), LArrowSize );
  if Assigned(LArrowEnt) then
  begin
    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := LArrowEnt;
  end;
end;

function TUdDimension.CreateDimLine(AP1, AP2: TPoint2D; AIsExt: Boolean; AIndex: Integer = 0): TUdEntity;
begin
  Result := TUdLine.Create(Self.Document, False);

  Result.BeginUpdate();
  try
    Result.Owner := Self;

    if AIsExt then
    begin
      TUdLine(Result).Color.Assign(FLinesProp.ExtColor);
      if AIndex = 0 then
        TUdLine(Result).LineType.Assign(FLinesProp.ExtLineType1)
      else
        TUdLine(Result).LineType.Assign(FLinesProp.ExtLineType2);

      TUdLine(Result).LineWeight := FLinesProp.ExtLineWeight;
    end
    else begin
      TUdLine(Result).Color.Assign(FLinesProp.Color);
      TUdLine(Result).LineType.Assign(FLinesProp.LineType);
      TUdLine(Result).LineWeight := FLinesProp.LineWeight;
    end;

    TUdLine(Result).XData := Segment2D(AP1, AP2);
  finally
    Result.EndUpdate();
  end;
end;

function TUdDimension.CreateExtLines(AExtP1, AExtP2, ADimP1, ADimP2: TPoint2D): TUdEntityArray;
var
  LAng: Float;
  LPntEnt: TUdPoint;
  LP1, LP2: TPoint2D;
begin
  System.SetLength(Result, 2);

  LPntEnt := TUdPoint.Create(Self.Document, False);
  LPntEnt.BeginUpdate();
  try
    LPntEnt.Owner := Self;
    LPntEnt.States := [psPoint];
    LPntEnt.Color.Assign(FLinesProp.ExtColor);
    LPntEnt.XData := AExtP1;
  finally
    LPntEnt.EndUpdate();
  end;
  Result[0] := LPntEnt;  

  LPntEnt := TUdPoint.Create(Self.Document, False);
  LPntEnt.BeginUpdate();
  try  
    LPntEnt.Owner := Self;
    LPntEnt.States := [psPoint];
    LPntEnt.Color.Assign(FLinesProp.ExtColor);
    LPntEnt.XData := AExtP2;
  finally
    LPntEnt.EndUpdate();
  end;    
  Result[1] := LPntEnt;

  if not FLinesProp.ExtSuppressLine1 and not IsEqual(AExtP1, ADimP1) then
  begin
    LAng := GetAngle(AExtP1, ADimP1);
    if LAng < 0 then LAng := FixAngle(GetAngle(AExtP1, AExtP2) - 90);

    LP1 := ShiftPoint(AExtP1, LAng, FLinesProp.ExtOriginOffset);

    if FExtLineFixed then
      if Distance(ADimP1, LP1) > FExtLineFixedLen then
        LP1 := ShiftPoint(ADimP1, FixAngle(LAng+180), Abs(FExtLineFixedLen));

    LP2 := ShiftPoint(ADimP1, LAng, FLinesProp.ExtBeyondDimLines);

    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := CreateDimLine(LP1, LP2, True, 0);
  end;

  if not FLinesProp.ExtSuppressLine2 and not IsEqual(AExtP2, ADimP2) then
  begin
    LAng := GetAngle(AExtP2, ADimP2);
    if LAng < 0 then LAng := FixAngle(GetAngle(AExtP1, AExtP2) - 90);

    LP1 := ShiftPoint(AExtP2, LAng, FLinesProp.ExtOriginOffset);

    if FExtLineFixed then
      if Distance(ADimP2, LP1) > FExtLineFixedLen then
        LP1 := ShiftPoint(ADimP2, FixAngle(LAng+180), Abs(FExtLineFixedLen));

    LP2 := ShiftPoint(ADimP2, LAng, FLinesProp.ExtBeyondDimLines);

    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := CreateDimLine(LP1, LP2, True, 1);
  end;
end;



function TUdDimension.TextAngleValid(AAngle: Float): Boolean;
begin
  Result := False;
  if FTextAngle >= 0.0 then
    Result := NotEqual(FixAngle(AAngle), FTextAngle);
end;


function TUdDimension.UpdateTextPosition(ATextObj: TUdText; ATextAlign: Boolean; ATextPnt: TPoint2D; ATextAng: Float): Boolean;
var
  LSgnAng: Float;
  LOffsetFromDimLine: Float;
begin
  Result := False;
  if not Assigned(ATextObj) then Exit;

  LOffsetFromDimLine := FTextProp.OffsetFromDimLine;
  if Assigned(FDimStyle) then LOffsetFromDimLine := LOffsetFromDimLine * FDimStyle.OverallScale;

  LSgnAng := SgnAngle(ATextAng, 0.01);

  if ATextAlign then
  begin
    if (FTextProp.VerticalPosition = vtpAbove) then
    begin
      if LSgnAng <= 90 then
        ATextObj.Position := ShiftPoint(ATextPnt, FixAngle(LSgnAng + 90), (ATextObj.TextHeight/2 + LOffsetFromDimLine) )
      else
        ATextObj.Position := ShiftPoint(ATextPnt, FixAngle(LSgnAng - 90), (ATextObj.TextHeight/2 + LOffsetFromDimLine) );
    end
    else begin
      ATextObj.Position := ATextPnt;
    end;

    if (ATextAng > 90) and (ATextAng <= 270) then ATextAng := ATextAng - 180;
    ATextObj.Rotation := ATextAng;
  end
  else begin
    ATextObj.Position := ATextPnt;
    ATextObj.Rotation := ATextAng;
  end;

  Result := True;
end;



function TUdDimension.UpdateInsideTextPosition(ATextEntity: TUdText; ATextPnt: TPoint2D; ATextAngle: Float;
                                              AIsArc: Boolean; var ANeedInctBound: Boolean): Boolean;
var
  LTextHeight: Float;
  LTextAng, LSgnAng: Float;
  LUserAngled: Boolean;
  LOffsetFromDimLine: Float;
begin
  Result := False;
  ANeedInctBound := False;

  if not Assigned(ATextEntity) then Exit;

  LOffsetFromDimLine := FTextProp.OffsetFromDimLine;
  if Assigned(FDimStyle) then LOffsetFromDimLine := LOffsetFromDimLine * FDimStyle.OverallScale;


  if FTextProp.InsideAlign then
  begin
    LUserAngled := TextAngleValid(ATextAngle);
    if LUserAngled then LTextAng := FTextAngle else LTextAng := ATextAngle;
  end
  else begin
    LUserAngled := TextAngleValid(0.0);
    if LUserAngled then LTextAng := FTextAngle else LTextAng := 0.0;
  end;


  if LUserAngled then
  begin
    ATextEntity.Position := ATextPnt;
    ANeedInctBound := True;
    ATextEntity.Rotation := LTextAng;
  end
  else begin
    FTextAngle := -1;

    LSgnAng := SgnAngle(LTextAng, 0.01);
    LTextHeight := ATextEntity.TextHeight;

    if FTextProp.InsideAlign then
    begin
      if (FTextProp.VerticalPosition = vtpAbove) then
      begin
        if LSgnAng <= 90 then
          ATextEntity.Position := ShiftPoint(ATextPnt, FixAngle(LSgnAng + 90), (LTextHeight/2 + LOffsetFromDimLine) )
        else
          ATextEntity.Position := ShiftPoint(ATextPnt, FixAngle(LSgnAng - 90), (LTextHeight/2 + LOffsetFromDimLine) );
      end
      else begin
        ATextEntity.Position := ATextPnt;
        ANeedInctBound := True;
      end;

      if (LTextAng > 90) and (LTextAng <= 270) then LTextAng := LTextAng - 180;
      ATextEntity.Rotation := LTextAng;
    end
    else begin
      if not AIsArc and (IsEqual(LSgnAng, 0.0) or (FTextProp.VerticalPosition = vtpAbove)) then
      begin
        ATextEntity.Position := ShiftPoint(ATextPnt, FixAngle(LSgnAng + 90), (LTextHeight/2 + LOffsetFromDimLine) );
      end
      else begin
        ATextEntity.Position := ATextPnt;
        ANeedInctBound := True;
      end;

      ATextEntity.Rotation := 0.0;
    end;
  end;

  Result := True;
end;

function TUdDimension.UpdateOutsideTextPosition(ATextEntity: TUdText; ATextPnt: TPoint2D; ATextAngle: Float; APntInCircle: Boolean; var ANeedInctBound: Boolean): Boolean;
var
  LTextHeight: Float;
  LTextAng, LSgnAng: Float;
  LUserAngled: Boolean;
  LOffsetFromDimLine: Float;
begin
  Result := False;
  ANeedInctBound := False;

  if not Assigned(ATextEntity) then Exit;

  LOffsetFromDimLine := FTextProp.OffsetFromDimLine;
  if Assigned(FDimStyle) then LOffsetFromDimLine := LOffsetFromDimLine * FDimStyle.OverallScale;

  if FTextProp.OutsideAlign then
  begin
    LUserAngled := TextAngleValid(ATextAngle);
    if LUserAngled then LTextAng := FTextAngle else LTextAng := ATextAngle;
  end
  else begin
    LUserAngled := TextAngleValid(0.0);
    if LUserAngled then LTextAng := FTextAngle else LTextAng := 0.0;
  end;

  if LUserAngled then
  begin
    ATextEntity.Position := ATextPnt;
    ANeedInctBound := True;
    ATextEntity.Rotation := LTextAng;
  end
  else begin
    FTextAngle := -1;

    LSgnAng := SgnAngle(LTextAng, 0.01);
    LTextHeight := ATextEntity.TextHeight;

    if FTextProp.OutsideAlign then
    begin
      if (FTextProp.VerticalPosition = vtpAbove) then
      begin
        if LSgnAng <= 90 then
          ATextEntity.Position := ShiftPoint(ATextPnt, FixAngle(LSgnAng + 90), (LTextHeight/2 + LOffsetFromDimLine) )
        else
          ATextEntity.Position := ShiftPoint(ATextPnt, FixAngle(LSgnAng - 90), (LTextHeight/2 + LOffsetFromDimLine) );
      end
      else begin
        ATextEntity.Position := ATextPnt;
        ANeedInctBound := True;
      end;

      if (LTextAng > 90) and (LTextAng <= 270) then LTextAng := LTextAng - 180;
      ATextEntity.Rotation := LTextAng;
    end
    else begin
      if not APntInCircle and (FTextProp.VerticalPosition = vtpAbove) then
      begin
        ATextEntity.Position := ShiftPoint(ATextPnt, FixAngle(LSgnAng + 90), (LTextHeight/2 + LOffsetFromDimLine) );
        ANeedInctBound := False;
      end
      else begin
        ATextEntity.Position := ATextPnt;
        ANeedInctBound := True;
      end;

      ATextEntity.Rotation := 0.0;
    end;
  end;

  Result := True;
end;


//----------------------------------------------------------------------------------------


// (dtkNormal, dtkAngle, dtkArcLen, dtkRaidus, dtkDiameter);
function TUdDimension.GetDimText(const AValue: Float; AKind: TUdDimTextKind): string;

  function _GetAngDimText(const AValue: Float; AUnitsProp: TUdDimUnitsProp): string;
  var
    LText: string;
  begin
    LText := UdUnits.AngToS(AValue, AUnitsProp.AngUnitFormat, AUnitsProp.AngPrecision,
                            AUnitsProp.AngSuppressLeading, AUnitsProp.AngSuppressTrailing);

    // 应该表示角度的d 换为标注的表示角度的符号
    case AUnitsProp.AngUnitFormat of
      auDegrees  : LText := LText + '%%D';
      auDegMinSec: LText := StringReplace(LText, 'd', '%%D', [rfReplaceAll]);
    end;

    Result := LText;
  end;

  function _GetLenDimText(const AValue: Float; AUnitsProp: TUdDimUnitsProp): string;
  var
    LInt: Integer;
    LValue: Float;
    LText, LPrefix: string;
  begin
    LValue := AValue * AUnitsProp.MeasurementScale;

    if NotEqual(AUnitsProp.RoundOff, 0.0) and (AUnitsProp.RoundOff > 0) then
    begin
      LInt := Round(LValue / AUnitsProp.RoundOff);
      LValue := LInt * AUnitsProp.RoundOff;
    end;

    LText := UdUnits.RToS(LValue, AUnitsProp.UnitFormat, AUnitsProp.Precision,
                          AUnitsProp.SuppressLeading, AUnitsProp.SuppressTrailing);

    if (AUnitsProp.UnitFormat = luDecimal) and (AUnitsProp.Decimal <> '.') then
      LText := StringReplace(LText, '.', AUnitsProp.Decimal, [rfReplaceAll]);

    LPrefix := AUnitsProp.Prefix;
    if AKind = dtkRaidus   then LPrefix := 'R' else
    if AKind = dtkDiameter then LPrefix := '%%C';
    Result := LPrefix + LText + AUnitsProp.Suffix;
  end;


  function _GetMeasureText(): string;
  begin
    if AKind = dtkAngle then
    begin
      Result := _GetAngDimText(AValue, FUnitsProp);
    end
    else begin
      if FAltUnitsEnabled then
        Result := _GetLenDimText(AValue,  FUnitsProp) + '[' +
                  _GetLenDimText(AValue * FAltUnitsProp.MeasurementScale, FAltUnitsProp) + ']'
      else
        Result := _GetLenDimText(AValue, FUnitsProp);
    end;
  end;

var
  N: Integer;
  LTextMeasure: string;
  LTextOverride: string;
begin
  if FTextOverride <> '' then
  begin
    LTextOverride := FTextOverride;

    N := Pos('<>', LTextOverride);

    if N > 0 then
    begin
      LTextMeasure := _GetMeasureText();
      LTextOverride := StringReplace(LTextOverride, '<>', LTextMeasure, []);
    end;

    Result := LTextOverride;
  end
  else
    Result := _GetMeasureText();
end;

function TUdDimension.UpdateByEntity(AEntity: TUdEntity): Boolean;
begin
  Result := False;
end;

function TUdDimension.UpdateByDimStyle(ADimStyle: TObject): Boolean;
begin
  Result := False;
  if not Assigned(ADimStyle) or not ADimStyle.InheritsFrom(TUdDimStyle) then Exit;

  Self.BeginUpdate();
  try
    FTextAngle := -1;

    FLinesProp.Assign(TUdDimStyle(ADimStyle).LinesProp);
    FArrowsProp.Assign(TUdDimStyle(ADimStyle).ArrowsProp);
    FTextProp.Assign(TUdDimStyle(ADimStyle).TextProp);
    FUnitsProp.Assign(TUdDimStyle(ADimStyle).UnitsProp);
    FAltUnitsProp.Assign(TUdDimStyle(ADimStyle).AltUnitsProp);
  finally
    Self.EndUpdate();
  end;
end;


//----------------------------------------------------------------------------------------


procedure TUdDimension.SetExtLineFixed(const AValue: Boolean);
begin
  if (FExtLineFixed <> AValue) and Self.RaiseBeforeModifyObject('ExtLineFixed') then
  begin
    FExtLineFixed := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLineFixed');
  end;
end;

procedure TUdDimension.SetExtLineFixedLen(const AValue: Float);
begin
  if (FExtLineFixedLen <> AValue) and Self.RaiseBeforeModifyObject('ExtLineFixedLen') then
  begin
    FExtLineFixedLen := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ExtLineFixedLen');
  end;
end;


procedure TUdDimension.SetAltUnitsEnabled(const AValue: Boolean);
begin
  if (FAltUnitsEnabled <> AValue) and Self.RaiseBeforeModifyObject('AltUnitsEnabled') then
  begin
    FAltUnitsEnabled := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('AltUnitsEnabled');
  end;
end;


procedure TUdDimension.SetTextPoint(const AValue: TPoint2D);
begin

end;

procedure TUdDimension.SetTextAngle(const AValue: Float);
begin
  if NotEqual(FTextAngle, AValue) and Self.RaiseBeforeModifyObject('TextAngle') then
  begin
    FTextAngle := FixAngle(AValue);
    Self.Update();
    Self.RaiseAfterModifyObject('TextAngle');
  end;
end;

procedure TUdDimension.SetTextOverride(const AValue: string);
begin
  if (FTextOverride <> AValue) and Self.RaiseBeforeModifyObject('TextOverride') then
  begin
    FTextOverride := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('TextOverride');
  end;
end;



procedure TUdDimension.StatesChanged(AIndex: Integer);
var
  I: Integer;
  LBool: Boolean;
begin
  inherited;

  case AIndex of
    STATE_INDEX_FINISHED :  Self.Update();
    STATE_INDEX_SELECTED :
      begin
        LBool := (FStates and Byte(fsSelected)) > 0;
        for I := 0 to FEntityList.Count - 1 do TUdEntity(FEntityList[I]).Selected := LBool;
      end;
    STATE_INDEX_HIDDEN   :  ;// FStates := (FStates and Byte(fsHidden))   > 0;
    STATE_INDEX_UNDERGRIP:  ;// FStates := (FStates and Byte(fsUnderGrip))> 0;
  end
end;


procedure TUdDimension.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDimension) then Exit;

  Inc(FUpdateCounter);
  try
    FDimStyle := TUdDimension(AValue).FDimStyle;

    FLinesProp.Assign(TUdDimension(AValue).FLinesProp)  ;
    FArrowsProp.Assign(TUdDimension(AValue).FArrowsProp);
    FTextProp.Assign(TUdDimension(AValue).FTextProp)    ;
    FUnitsProp.Assign(TUdDimension(AValue).FUnitsProp)  ;
    FAltUnitsProp.Assign(TUdDimension(AValue).FAltUnitsProp);

    FExtLineFixed    := TUdDimension(AValue).FExtLineFixed   ;
    FExtLineFixedLen := TUdDimension(AValue).FExtLineFixedLen;

    FMeasurement     := TUdDimension(AValue).FMeasurement     ;
    FTextOverride    := TUdDimension(AValue).FTextOverride    ;
    FTextAngle       := TUdDimension(AValue).FTextAngle   ;
    FAltUnitsEnabled := TUdDimension(AValue).FAltUnitsEnabled ;
  finally
    Dec(FUpdateCounter);
  end;
end;


procedure TUdDimension.OnPropChanging(Sender: TObject; APropName: string; var AAllow: Boolean);
begin
  if Sender = FLinesProp    then AAllow := Self.RaiseBeforeModifyObject('LinesProp') else
  if Sender = FArrowsProp   then AAllow := Self.RaiseBeforeModifyObject('ArrowsProp') else
  if Sender = FTextProp     then AAllow := Self.RaiseBeforeModifyObject('TextProp') else
  if Sender = FUnitsProp    then AAllow := Self.RaiseBeforeModifyObject('UnitsProp') else
  if Sender = FAltUnitsProp then AAllow := Self.RaiseBeforeModifyObject('AltUnitsProp');
end;

procedure TUdDimension.OnPropChanged(Sender: TObject; APropName: string);
begin
  if Sender = FLinesProp    then Self.RaiseAfterModifyObject('LinesProp') else
  if Sender = FArrowsProp   then Self.RaiseAfterModifyObject('ArrowsProp') else
  if Sender = FTextProp     then Self.RaiseAfterModifyObject('TextProp') else
  if Sender = FUnitsProp    then Self.RaiseAfterModifyObject('UnitsProp') else
  if Sender = FAltUnitsProp then Self.RaiseAfterModifyObject('AltUnitsProp');

  if FUpdateCounter <= 0 then Self.Update();
end;




//----------------------------------------------------------------------------------------


function TUdDimension.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
var
  I: Integer;
  LEntity: TUdEntity;
begin
  Result := False;

  if not Assigned(ACanvas) or not Assigned(AAxes)  then Exit; //=======>>>
  if not Assigned(FEntityList) or (FEntityList.Count <= 0) then Exit; //=======>>>

  for I := 0 to FEntityList.Count - 1 do
  begin
    LEntity := FEntityList[I];
    LEntity.Draw(ACanvas, AAxes, AFlag, ALwFactor);
  end;

  Result := True;
end;


function TUdDimension.UpdateDim(AAxes: TUdAxes): Boolean;
begin
  Result := False;
end;

function TUdDimension.DoUpdate(AAxes: TUdAxes): Boolean;
var
  I: Integer;
  LBound: TRect2D;
begin
  LBound := FBoundsRect;

  Result := UpdateDim(AAxes);

  if Self.Selected then
    for I := 0 to FEntityList.Count - 1 do
      TUdEntity(FEntityList[I]).Selected := True;

  if not Self.Finished then
  begin
    for I := 0 to FEntityList.Count - 1 do
    begin
      TUdEntity(FEntityList[I]).Finished := False;
      TUdEntity(FEntityList[I]).Color.Assign(Self.Color);
      TUdEntity(FEntityList[I]).LineType.Assign(Self.LineType);
      TUdEntity(FEntityList[I]).LineWeight := Self.LineWeight;
    end;
  end;


  FBoundsRect := UdUtils.GetEntitiesBound(FEntityList);

  LBound := MergeRect(LBound, FBoundsRect);
  Self.Refresh(LBound, AAxes);
end;



function TUdDimension.GetOSnapPoints: TUdOSnapPointArray;
var
  I, J, N: Integer;
  LOPnts: TUdOSnapPointArray;
begin
  System.SetLength(Result, MAX_OSNP_COUNT);

  N := 0;
  for I := 0 to FEntityList.Count - 1 do
  begin
    LOPnts := TUdEntity(FEntityList[I]).GetOSnapPoints();

    for J := 0 to System.Length(LOPnts) - 1 do
    begin
      Result[N] := LOPnts[J];
      N := N + 1;

      if N >= MAX_OSNP_COUNT then Exit; //======>>>
    end;
  end;

  if N < MAX_OSNP_COUNT then
    System.SetLength(Result, N);
end;


function TUdDimension.GetChildEntities: TList;
begin
  Result := FEntityList;
end;



//----------------------------------------------------------------------------------------

function TUdDimension.Pick(APoint: TPoint2D): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  for I := 0 to FEntityList.Count - 1 do
  begin
    if TUdEntity(FEntityList[I]).Pick(APoint) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TUdDimension.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  for I := 0 to FEntityList.Count - 1 do
  begin
    if TUdEntity(FEntityList[I]).Pick(ARect, ACrossingMode) then
    begin
      Result := True;
      Break;
    end;
  end;
end;







//----------------------------------------------------------------------------------------

procedure TUdDimension.SaveToStream(AStream: TStream);
var
  LStyleName: string;
begin
  inherited;

  LStyleName := '';
  if Assigned(FDimStyle) then LStyleName := FDimStyle.Name;
  StrToStream(AStream, LStyleName);

  FLinesProp.SaveToStream(AStream)   ;
  FArrowsProp.SaveToStream(AStream)  ;
  FTextProp.SaveToStream(AStream)    ;
  FUnitsProp.SaveToStream(AStream)   ;
  FAltUnitsProp.SaveToStream(AStream);


  BoolToStream(AStream, FExtLineFixed);
  FloatToStream(AStream, FExtLineFixedLen);

  FloatToStream(AStream, FMeasurement);
  StrToStream(AStream, FTextOverride);
  BoolToStream(AStream, FAltUnitsEnabled);
end;

procedure TUdDimension.LoadFromStream(AStream: TStream);
var
  LStyleName: string;
begin
  inherited;

  FDimStyle := nil;

  LStyleName := StrFromStream(AStream);
  if Assigned(Self.Document) then
    FDimStyle := TUdDocument(Self.Document).DimStyles.GetItem(LStyleName);

  FLinesProp.LoadFromStream(AStream)   ;
  FArrowsProp.LoadFromStream(AStream)  ;
  FTextProp.LoadFromStream(AStream)    ;
  FUnitsProp.LoadFromStream(AStream)   ;
  FAltUnitsProp.LoadFromStream(AStream);

  FExtLineFixed    := BoolFromStream(AStream  );
  FExtLineFixedLen := FloatFromStream(AStream );

  FMeasurement     := FloatFromStream(AStream );
  FTextOverride    := StrFromStream(AStream   );
  FAltUnitsEnabled := BoolFromStream(AStream  );
end;





procedure TUdDimension.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  if Assigned(FDimStyle) then LXmlNode.Prop['StyleName'] := FDimStyle.Name;

  LXmlNode.Prop['ExtLineFixed']    := BoolToStr(FExtLineFixed, True);
  LXmlNode.Prop['ExtLineFixedLen'] := FloatToStr(FExtLineFixedLen);

  LXmlNode.Prop['Measurement']     := FloatToStr(FMeasurement);
  LXmlNode.Prop['TextOverride']    := FTextOverride;
  LXmlNode.Prop['AltUnitsEnabled'] := BoolToStr(FAltUnitsEnabled, True);

  FLinesProp.SaveToXml(LXmlNode.Add())   ;
  FArrowsProp.SaveToXml(LXmlNode.Add())  ;
  FTextProp.SaveToXml(LXmlNode.Add())    ;
  FUnitsProp.SaveToXml(LXmlNode.Add())   ;
  FAltUnitsProp.SaveToXml(LXmlNode.Add());
end;

procedure TUdDimension.LoadFromXml(AXmlNode: TObject);
var
  LStyleName: string;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FDimStyle := nil;
  LStyleName := LXmlNode.Prop['StyleName'];
  if Assigned(Self.Document) then
    FDimStyle := TUdDocument(Self.Document).DimStyles.GetItem(LStyleName);

  FExtLineFixed    := StrToBoolDef(LXmlNode.Prop['ExtLineFixed']  , False);
  FExtLineFixedLen := StrToFloatDef(LXmlNode.Prop['ExtLineFixedLen'], 1.25);

  FMeasurement     := StrToFloatDef(LXmlNode.Prop['ExtLineFixedLen'], 0);
  FTextOverride    := LXmlNode.Prop['TextOverride'];
  FAltUnitsEnabled := StrToBoolDef(LXmlNode.Prop['AltUnitsEnabled'], False);

  FLinesProp.LoadFromXml(LXmlNode.FindItem('DimLinesProp'))   ;
  FArrowsProp.LoadFromXml(LXmlNode.FindItem('DimSymbolArrowsProp'))  ;
  FTextProp.LoadFromXml(LXmlNode.FindItem('DimTextProp'))    ;
  FUnitsProp.LoadFromXml(LXmlNode.FindItem('DimUnitsProp'))   ;
  FAltUnitsProp.LoadFromXml(LXmlNode.FindItem('DimAltUnitsProp'));
end;

end.