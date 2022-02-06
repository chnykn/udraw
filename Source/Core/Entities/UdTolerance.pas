{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdTolerance;

interface

uses
  Classes, Graphics, Types,
  UdConsts, UdIntfs, UdTypes, UdGTypes,
  UdObject, UdEntity, UdAxes;


type
  TUdTolData = record
    Dia1: Char;
    Value1: string;
    Mat1: Char;

    Dia2: Char;
    Value2: string;
    Mat2: Char;
  end;

  TUdDatumData = record
    Value1: string;
    Mat1: Char;

    Value2: string;
    Mat2: Char;
  end;

  TUdGeoTolData = record
    Sym1, Sym2: Char;
    Tol1, Tol2: TUdTolData;
    Datum1, Datum2, Datum3: TUdDatumData;

    Height: string;
    ProTolZone: Char;

    DatumId: string;
  end;


  //*** TUdTolerance ***//
  TUdTolerance = class(TUdEntity, IUdChildEntities)
  private
    FContents  : string;
    FPosition   : TPoint2D;
    FRotation  : Float;
    FTextHeight: Float;

    FEntityList: TList;

  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    procedure SetContents(const AValue: string);
    procedure SetPosition(const AValue: TPoint2D);

    function GetPositionValue(AIndex: Integer): Float;
    procedure SetPositionValue(AIndex: Integer; const AValue: Float);

    procedure SetRotation(const AValue: Float);
    procedure SetTextHeight(const AValue: Float);


    procedure StatesChanged(AIndex: Integer); override;

    function DoUpdate(AAxes: TUdAxes): Boolean;  override;
    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    function UpdateEntities(AAxes: TUdAxes): Boolean;

    {....}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetGripPoints(): TUdGripPointArray; override;
    function GetOSnapPoints(): TUdOSnapPointArray; override;

    {IUdChildEntities...}
    function GetChildEntities(): TList;


    { operation... }
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;

    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;

    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;
    function Intersect(AOther: TUdEntity): TPoint2DArray; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;

    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property Point      : TPoint2D read FPosition    write SetPosition;
    property EntityList : TList read FEntityList;

  published
    property Contents   : string        read FContents       write SetContents;

    property PositionX   : Float index 0 read GetPositionValue write SetPositionValue;
    property PositionY   : Float index 1 read GetPositionValue write SetPositionValue;

    property Rotation   : Float         read FRotation       write SetRotation;
    property TextHeight : Float         read FTextHeight     write SetTextHeight;
  end;


function StrToGeoTolData(AText: string): TUdGeoTolData;
function GeoTolDataToStr(AData: TUdGeoTolData): string;


implementation

uses
  SysUtils,
  UdLine, UdText,
  UdMath, UdGeo2D, UdUtils, UdStrConverter, UdStreams, UdXml;




//==================================================================================================

procedure InitGeoTolData(var AData: TUdGeoTolData);
begin
  AData.Sym1 := #0;
  AData.Sym2 := #0;

  AData.Tol1.Dia1 := #0;
  AData.Tol1.Dia2 := #0;
  AData.Tol1.Mat1 := #0;
  AData.Tol1.Mat2 := #0;
  AData.Tol1.Value1 := '';
  AData.Tol1.Value2 := '';

  AData.Tol2.Dia1 := #0;
  AData.Tol2.Dia2 := #0;
  AData.Tol2.Mat1 := #0;
  AData.Tol2.Mat2 := #0;
  AData.Tol2.Value1 := '';
  AData.Tol2.Value2 := '';

  AData.Datum1.Mat1 := #0;
  AData.Datum1.Mat2 := #0;
  AData.Datum1.Value1 := '';
  AData.Datum1.Value2 := '';

  AData.Datum2.Mat1 := #0;
  AData.Datum2.Mat2 := #0;
  AData.Datum2.Value1 := '';
  AData.Datum2.Value2 := '';

  AData.Datum3.Mat1 := #0;
  AData.Datum3.Mat2 := #0;
  AData.Datum3.Value1 := '';
  AData.Datum3.Value2 := '';

  AData.Height     := '';
  AData.ProTolZone := #0;
  AData.DatumId    := '';
end;



function IsValieSymChar(AChar: Char): Boolean;
begin
  Result := CharInSet(AnsiChar(AChar), [ 'j', 'r', 'i', 'f', 'b',
                               'a', 'g', 'c', 'e', 'u',
                               'd', 'k', 'h', 't' ]  );

end;

function IsValieMatChar(AChar: Char): Boolean;
begin
  Result := CharInSet(AnsiChar(AChar), [ 'm', 'l', 's']);
end;




function TryStrToSym(AStr: string; ARow: Integer; var AData: TUdGeoTolData): Boolean;
var
  N: Integer;
  LStr: string;
begin
  Result := False;

  LStr := Trim(AStr);

  N := Pos('{', LStr);
  if N > 0 then Delete(LStr, 1, N);

  N := Pos('}', LStr);
  if N > 0 then Delete(LStr, N, System.Length(LStr));


  if LStr = '' then
  begin
    Result := True;
    if ARow = 0 then AData.Sym1 := #0 else AData.Sym2 := #0;
  end
  else begin
    if IsValieSymChar(LStr[1]) then
    begin
      Result := True;
      if ARow = 0 then AData.Sym1 := LStr[1] else AData.Sym2 := LStr[1];
    end;
  end;
end;

function TryStrToTolData(AStr: string; ARow: Integer; var AData: TUdTolData): Boolean;
var
  N, M: Integer;
  LStr, LChar: string;
begin
  LStr := Trim(AStr);
  if LStr = '' then
  begin
    Result := True;
  end
  else begin
    Result := True;
    N := Pos('{', LStr);

    if N = 1 then
    begin
      M := Pos('}', LStr);

      if M - N > 1 then
      begin
        LChar := Copy(LStr, N + 1, 1);
        Result := LChar[1] = 'n';

        if Result then
        begin
          if ARow = 0 then AData.Dia1 := 'n' else AData.Dia2 := 'n';
        end;
      end;

      Delete(LStr, N, M - N + 1);
    end;


    if Result then
    begin
      N := Pos('{', LStr);

      if N > 0 then
      begin
        M := Pos('}', LStr);

        if M - N > 1 then
        begin
          LChar := Copy(LStr, N + 1, 1);
          Result := IsValieMatChar(LChar[1] );

          if Result then
          begin
            if ARow = 0 then AData.Mat1 := LChar[1] else AData.Mat2 := LChar[1];
          end;
        end;

        Delete(LStr, N, M - N + 1);
      end;

      if Result then
      begin
        if ARow = 0 then AData.Value1 := LStr else AData.Value2 := LStr;
      end;
    end;
  end;
end;

function TryStrToDatumData(AStr: string; ARow: Integer; var AData: TUdDatumData): Boolean;
var
  N, M: Integer;
  LStr, LChar: string;
begin
  LStr := Trim(AStr);
  if LStr = '' then
  begin
    Result := True;
  end
  else begin
    Result := True;

    N := Pos('{', LStr);

    if N > 0 then
    begin
      M := Pos('}', LStr);

      if M - N > 1 then
      begin
        LChar := Copy(LStr, N + 1, 1);
        Result := IsValieMatChar(LChar[1] );

        if Result then
        begin
          if ARow = 0 then AData.Mat1 := LChar[1] else AData.Mat2 := LChar[1];
        end;
      end;

      Delete(LStr, N, M - N + 1);
    end;


    if Result then
    begin
      if ARow = 0 then AData.Value1 := LStr else AData.Value2 := LStr;
    end;
  end;
end;


function TryStrToGeoTolData(AStr: string; ARow: Integer; var AData: TUdGeoTolData): Boolean;
var
  I, N, M: Integer;
  LStr, LChar: string;
  LStrs: TStringDynArray;
begin
  Result := False;

  LStr := Trim(AStr);
  if LStr = '' then
  begin
    Result := True;
    Exit; //====>>>>>
  end;

  if ARow < 3 then
  begin
    N := 1;
    while N < System.Length(LStr) do
    begin
      if (LStr[N] = '\') and (LStr[N+1] = 'F') then
      begin
        I := PosStr(';', LStr, N+2, False);
        if I > 0 then
        begin
          Delete(LStr, N, I - N + 1);
        end
        else N := N + 1;
      end
      else N := N + 1;
    end;
  end;

  if ARow in [0, 1] then
  begin
    LStrs := StrSplit(LStr, '%%v');

    Result := (System.Length(LStrs) > 0) and TryStrToSym(LStrs[0], ARow, AData);

    if Result and (System.Length(LStrs) > 1) then
      Result := TryStrToTolData(LStrs[1], ARow, AData.Tol1);

    if Result and (System.Length(LStrs) > 2) then
      Result := TryStrToTolData(LStrs[2], ARow, AData.Tol2);

    if Result and (System.Length(LStrs) > 3) then
      Result := TryStrToDatumData(LStrs[3], ARow, AData.Datum1);

    if Result and (System.Length(LStrs) > 4) then
      Result := TryStrToDatumData(LStrs[4], ARow, AData.Datum2);

    if Result and (System.Length(LStrs) > 5) then
      Result := TryStrToDatumData(LStrs[5], ARow, AData.Datum3);
  end else

  if ARow = 2 then
  begin
    Result := True;

    N := Pos('{', LStr);

    if N > 0 then
    begin
      M := Pos('}', LStr);

      if M - N > 1 then
      begin
        LChar := Copy(LStr, N + 1, 1);
        Result := LChar[1] = 'p';

        AData.ProTolZone := 'p';
      end;

      Delete(LStr, N, M - N + 1);
    end;


    if Result then
      AData.Height := LStr;

  end else

  if ARow = 3 then
  begin
    AData.DatumId := AStr;
    Result := True;
  end;
end;

function StrToGeoTolData(AText: string): TUdGeoTolData;
var
  LStrs: TStrings;
  LOK: Boolean;
  LText: string;
begin
  InitGeoTolData(Result);

  LText := SysUtils.StringReplace(AText, '^J', #13#10, [rfReplaceAll, rfIgnoreCase]);

  LStrs := TStringList.Create;
  try
    LStrs.Text := LText;

    LOK := False;

    if LStrs.Count >= 4 then
    begin
      LOK := TryStrToGeoTolData(LStrs[0], 0, Result) and
             TryStrToGeoTolData(LStrs[1], 1, Result) and
             TryStrToGeoTolData(LStrs[2], 2, Result) and
             TryStrToGeoTolData(LStrs[3], 3, Result);
    end else
    if LStrs.Count >= 3 then
    begin
      LOK := TryStrToGeoTolData(LStrs[0], 0, Result) and
             TryStrToGeoTolData(LStrs[1], 1, Result) and
             TryStrToGeoTolData(LStrs[2], 2, Result);

      if not LOK then
      begin
        InitGeoTolData(Result);
        LOK := TryStrToGeoTolData(LStrs[0], 1, Result) and
               TryStrToGeoTolData(LStrs[1], 2, Result) and
               TryStrToGeoTolData(LStrs[2], 3, Result);
      end;

    end else
    if LStrs.Count >= 2 then
    begin
      LOK := TryStrToGeoTolData(LStrs[0], 0, Result) and
             TryStrToGeoTolData(LStrs[1], 1, Result);

      if not LOK then
      begin
        InitGeoTolData(Result);
        LOK := TryStrToGeoTolData(LStrs[0], 1, Result) and
               TryStrToGeoTolData(LStrs[1], 2, Result);
      end;

      if not LOK then
      begin
        InitGeoTolData(Result);
        LOK := TryStrToGeoTolData(LStrs[0], 2, Result) and
               TryStrToGeoTolData(LStrs[1], 3, Result);
      end;

      if not LOK then
      begin
        InitGeoTolData(Result);
        LOK := TryStrToGeoTolData(LStrs[0], 3, Result) and
               TryStrToGeoTolData(LStrs[1], 4, Result);
      end;
    end  else
    if LStrs.Count >= 1 then
    begin
      LOK := TryStrToGeoTolData(LStrs[0], 0, Result);

      if not LOK then
      begin
        InitGeoTolData(Result);
        LOK := TryStrToGeoTolData(LStrs[0], 1, Result);
      end;

      if not LOK then
      begin
        InitGeoTolData(Result);
        LOK := TryStrToGeoTolData(LStrs[0], 2, Result);
      end;

      if not LOK then
      begin
        InitGeoTolData(Result);
        LOK := TryStrToGeoTolData(LStrs[0], 3, Result);
      end;
    end;

    if not LOK and (LStrs.Count >= 1) then
    begin
      InitGeoTolData(Result);
      Result.DatumId := LStrs[0];
    end;
  finally
    LStrs.Free;
  end;
end;


function IsEmptyTolData(AData: TUdTolData; ARow: Integer): Boolean;
begin
  if ARow = 0 then
  begin
    Result := (AData.Dia1 = #0) and (AData.Value1 = '') and (AData.Mat1 = #0);
  end
  else begin
    Result := (AData.Dia2 = #0) and (AData.Value2 = '') and (AData.Mat2 = #0);
  end;
end;

function IsEmptyDatumData(AData: TUdDatumData; ARow: Integer): Boolean;
begin
  if ARow = 0 then
  begin
    Result := (AData.Value1 = '') and (AData.Mat1 = #0);
  end
  else begin
    Result := (AData.Value2 = '') and (AData.Mat2 = #0);
  end;
end;

function TolSymbolToGdtStr(AChar: Char): string;
begin
  Result := '';
  if AChar <> #0 then
    Result := '{\Fgdt;' + AChar + '}';
end;

function GeoTolDataToStr(AData: TUdGeoTolData): string;
var
  LStr: string;
  LEmpty: Boolean;
begin
  LEmpty := (AData.Sym1 = #0) and
            IsEmptyTolData(AData.Tol1, 0) and IsEmptyTolData(AData.Tol2, 0) and
            IsEmptyDatumData(AData.Datum1, 0) and IsEmptyDatumData(AData.Datum2, 0) and IsEmptyDatumData(AData.Datum3, 0);

  if not LEmpty then
  begin
    Result := TolSymbolToGdtStr(AData.Sym1) + '%%v' +
              TolSymbolToGdtStr(AData.Tol1.Dia1) + AData.Tol1.Value1 + TolSymbolToGdtStr(AData.Tol1.Mat1) + '%%v' +
              TolSymbolToGdtStr(AData.Tol2.Dia1) + AData.Tol2.Value1 + TolSymbolToGdtStr(AData.Tol2.Mat1) + '%%v' +
              AData.Datum1.Value1 + TolSymbolToGdtStr(AData.Datum1.Mat1) + '%%v' +
              AData.Datum2.Value1 + TolSymbolToGdtStr(AData.Datum2.Mat1) + '%%v' +
              AData.Datum3.Value1 + TolSymbolToGdtStr(AData.Datum3.Mat1);
  end;


  //-------------------------------------------

  LEmpty := (AData.Sym2 = #0) and
            IsEmptyTolData(AData.Tol1, 1) and IsEmptyTolData(AData.Tol2, 1) and
            IsEmptyDatumData(AData.Datum1, 1) and IsEmptyDatumData(AData.Datum2, 1) and IsEmptyDatumData(AData.Datum3, 1);

  if LEmpty then
  begin
    Result := Result + '^J';
  end
  else begin
    LStr :=   TolSymbolToGdtStr(AData.Sym2) + '%%v' +
              TolSymbolToGdtStr(AData.Tol1.Dia2) + AData.Tol1.Value2 + TolSymbolToGdtStr(AData.Tol1.Mat2) + '%%v' +
              TolSymbolToGdtStr(AData.Tol2.Dia2) + AData.Tol2.Value2 + TolSymbolToGdtStr(AData.Tol2.Mat2) + '%%v' +
              AData.Datum1.Value2 + TolSymbolToGdtStr(AData.Datum1.Mat2) + '%%v' +
              AData.Datum2.Value2 + TolSymbolToGdtStr(AData.Datum2.Mat2) + '%%v' +
              AData.Datum3.Value2 + TolSymbolToGdtStr(AData.Datum3.Mat2) ;

    if Result <> '' then  Result := Result + '^J';
    Result := Result + LStr;
  end;


  //-------------------------------------------
  LEmpty := (AData.Height = '') and (AData.ProTolZone = #0);

  if LEmpty then
  begin
    Result := Result + '^J';
  end
  else begin
    LStr := AData.Height + TolSymbolToGdtStr(AData.ProTolZone);
    if Result <> '' then  Result := Result + '^J';
    Result := Result + LStr;
  end;


  //-------------------------------------------
  if AData.DatumId <> '' then
  begin
    LStr := AData.DatumId;
    if Result <> '' then  Result := Result + '^J';
    Result := Result + LStr;
  end;

end;


//==================================================================================================
{ TUdTolerance }

constructor TUdTolerance.Create();
begin
  inherited;

  FContents := '';
  FPosition.X := 0.0;
  FPosition.Y := 0.0;
  FRotation := 0.0;
  FTextHeight := 2.5;

  FEntityList := TList.Create;
end;

destructor TUdTolerance.Destroy;
begin
  ClearObjectList(FEntityList);

  FEntityList.Free;
  FEntityList := nil;

  inherited;
end;



function TUdTolerance.GetTypeID: Integer;
begin
  Result := ID_TOLERANCE;
end;


procedure TUdTolerance.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
var
  I: Integer;
begin
  inherited;

  for I := 0 to FEntityList.Count - 1 do
    TUdObject(FEntityList[I]).SetDocument(Self.Document, False);  
end;




//-----------------------------------------------------------------------------------------


procedure TUdTolerance.SetContents(const AValue: string);
begin
  if (FContents <> AValue) and Self.RaiseBeforeModifyObject('Contents') then
  begin
    FContents := AValue;
   	Self.Update();
    Self.RaiseAfterModifyObject('Contents');
  end;
end;

procedure TUdTolerance.SetPosition(const AValue: TPoint2D);
var
  I: Integer;
  LDx, LDy: Float;
begin
  if NotEqual(FPosition, AValue) and Self.RaiseBeforeModifyObject('Position') then
  begin
    LDx := AValue.X - FPosition.X;
    LDy := AValue.Y - FPosition.Y;

    for I := 0 to FEntityList.Count - 1 do
      TUdEntity(FEntityList[I]).Move(LDx, LDy);
    FPosition := AValue;

    FBoundsRect.X1 := FBoundsRect.X1 + LDx;
    FBoundsRect.X2 := FBoundsRect.X2 + LDx;
    FBoundsRect.Y1 := FBoundsRect.Y1 + LDy;
    FBoundsRect.Y2 := FBoundsRect.Y2 + LDy;

//   	Self.Update();
    Self.RaiseAfterModifyObject('Position');
  end;
end;


function TUdTolerance.GetPositionValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FPosition.X;
    1: Result := FPosition.Y;
  end;
end;

procedure TUdTolerance.SetPositionValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FPosition;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  Self.SetPosition(LPnt);
end;



procedure TUdTolerance.SetRotation(const AValue: Float);
begin
  if NotEqual(FRotation, AValue) and Self.RaiseBeforeModifyObject('Rotation') then
  begin
    FRotation := AValue;
   	Self.Update();
    Self.RaiseAfterModifyObject('Rotation');
  end;
end;

procedure TUdTolerance.SetTextHeight(const AValue: Float);
begin
  if NotEqual(FTextHeight, AValue) and Self.RaiseBeforeModifyObject('TextHeight') then
  begin
    FTextHeight := AValue;
   	Self.Update();
    Self.RaiseAfterModifyObject('TextHeight');
  end;
end;



procedure TUdTolerance.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdTolerance) then Exit; //========>>>

  Self.FContents       := TUdTolerance(AValue).FContents;
  Self.FPosition      := TUdTolerance(AValue).FPosition;
  Self.FRotation   := TUdTolerance(AValue).FRotation;
  Self.FTextHeight := TUdTolerance(AValue).FTextHeight;

  Self.Update();
end;


procedure TUdTolerance.StatesChanged(AIndex: Integer);
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


function FCreateLineObj(AOwer: TUdEntity; AP1, AP2: TPoint2D): TUdLine;
begin
  Result := TUdLine.Create(AOwer.Document, False);

  Result.BeginUpdate();
  try
    Result.Owner := AOwer;
    Result.StartPoint := AP1;
    Result.EndPoint := AP2;
  finally
    Result.EndUpdate();
  end;
end;

function FCreateTextObj(AOwer: TUdEntity; AText: string; APos: TPoint2D; ARotation, AHeight: Float; AIsGdt: Boolean): TUdText;
begin
  Result := TUdText.Create(AOwer.Document, False);

  Result.BeginUpdate();
  try  
    Result.Owner := AOwer;
    Result.Alignment := taTopLeft;
    Result.Position := APos;
    Result.Height := AHeight;
    Result.Rotation := ARotation;
    Result.Contents := AText;
    if AIsGdt and Assigned(AOwer.TextStyles) then
      Result.TextStyle := AOwer.TextStyles.Gdt;
  finally
    Result.EndUpdate();
  end;      
end;

function TUdTolerance.UpdateEntities(AAxes: TUdAxes): Boolean;

  function _UpdateTol(ADia: Char; AValue: string; AMat: Char; var APoint: TPoint2D): Boolean;
  var
    LLineObj: TUdLine;
    LTextObj: TUdText;
  begin
    Result := False;

    if (ADia <> #0) or (AValue <> '') or (AMat <> #0) then
      APoint := ShiftPoint(APoint, FRotation, FTextHeight * 0.5);

    if ADia <> #0 then
    begin
      LTextObj := FCreateTextObj(Self, ADia, ShiftPoint(APoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight, True);
      FEntityList.Add(LTextObj);

      Result := True;
      APoint := ShiftPoint(APoint, FRotation, LTextObj.TextWidth);
    end;

    if AValue <> '' then
    begin
      LTextObj := FCreateTextObj(Self, AValue, ShiftPoint(APoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight,  False);
      FEntityList.Add(LTextObj);

      Result := True;
      APoint := ShiftPoint(APoint, FRotation, LTextObj.TextWidth);
    end;

    if AMat <> #0 then
    begin
      LTextObj := FCreateTextObj(Self, AMat, ShiftPoint(APoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight, True);
      FEntityList.Add(LTextObj);

      Result := True;
      APoint := ShiftPoint(APoint, FRotation, LTextObj.TextWidth);
    end;

    if Result then
    begin
      APoint := ShiftPoint(APoint, FRotation, FTextHeight * 0.5);

      LLineObj := FCreateLineObj(Self, APoint, ShiftPoint(APoint, FRotation - 90, FTextHeight * 2));
      FEntityList.Add(LLineObj);
    end;
  end;


  function _UpdateDatum(const AValue: string; AMat: Char; var APoint: TPoint2D): Boolean;
  var
    LLineObj: TUdLine;
    LTextObj: TUdText;
  begin
    Result := False;

    if (AValue <> '') or (AMat <> #0) then
      APoint := ShiftPoint(APoint, FRotation, FTextHeight * 0.5);

    if AValue <> '' then
    begin
      LTextObj := FCreateTextObj(Self, AValue, ShiftPoint(APoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight, False);
      FEntityList.Add(LTextObj);

      Result := True;
      APoint := ShiftPoint(APoint, FRotation, LTextObj.TextWidth);
    end;

    if AMat <> #0 then
    begin
      LTextObj := FCreateTextObj(Self, AMat, ShiftPoint(APoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight, True);
      FEntityList.Add(LTextObj);

      Result := True;
      APoint := ShiftPoint(APoint, FRotation, LTextObj.TextWidth);
    end;

    if Result then
    begin
      APoint := ShiftPoint(APoint, FRotation, FTextHeight * 0.5);

      LLineObj := FCreateLineObj(Self, APoint, ShiftPoint(APoint, FRotation - 90, FTextHeight * 2));
      FEntityList.Add(LLineObj);
    end;
  end;

  function _UpdateHorzLine(N: Integer; var AP1, AP2: TPoint2D; APnt1, APnt2: TPoint2D): Boolean;
  var
    LLineObj: TUdLine;
  begin
    if N > 0 then
    begin
      if Distance(AP1, AP2) > Distance(APnt1, APnt2) then
        LLineObj := FCreateLineObj(Self, AP1, AP2)
      else
        LLineObj := FCreateLineObj(Self, APnt1, APnt2);

      FEntityList.Add(LLineObj);
    end
    else begin
      LLineObj := FCreateLineObj(Self, APnt1, APnt2);
      FEntityList.Add(LLineObj);
    end;

    AP1 := APnt1;
    AP2 := APnt2;

    AP1 := ShiftPoint(AP1, FRotation - 90, FTextHeight * 2);
    AP2 := ShiftPoint(AP2, FRotation - 90, FTextHeight * 2);

    Result := True;
  end;

var
  N: Integer;
  LEmpty: Boolean;
  LData: TUdGeoTolData;
  LPoint: TPoint2D;
  LLineObj: TUdLine;
  LTextObj: TUdText;
  LP1, LP2, LPnt1, LPnt2: TPoint2D;
begin
  Result := False;
  UdUtils.ClearObjectList(FEntityList);

  if SysUtils.Trim(FContents) = '' then Exit;

  LData := StrToGeoTolData(SysUtils.Trim(FContents));

  LEmpty := (LData.Sym1 = #0) and
            IsEmptyTolData(LData.Tol1, 0) and IsEmptyTolData(LData.Tol2, 0) and
            IsEmptyDatumData(LData.Datum1, 0) and IsEmptyDatumData(LData.Datum2, 0) and IsEmptyDatumData(LData.Datum3, 0);

  N := 0;
  LPoint := FPosition;

  if not LEmpty then
  begin
    LP1 := LPoint;

    LLineObj := FCreateLineObj(Self, LPoint, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 2 ));
    FEntityList.Add(LLineObj);

    if LData.Sym1 <> #0 then
    begin
      LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);

      LTextObj := FCreateTextObj(Self, LData.Sym1, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight, True);
      FEntityList.Add(LTextObj);

      LPoint := ShiftPoint(LPoint, FRotation, LTextObj.TextWidth);
      LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);

      LLineObj := FCreateLineObj(Self, LPoint, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 2));
      FEntityList.Add(LLineObj);

//      LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);
    end;

    _UpdateTol(LData.Tol1.Dia1, LData.Tol1.Value1, LData.Tol1.Mat1, LPoint);
    _UpdateTol(LData.Tol2.Dia1, LData.Tol2.Value1, LData.Tol2.Mat1, LPoint);

    _UpdateDatum(LData.Datum1.Value1, LData.Datum1.Mat1, LPoint);
    _UpdateDatum(LData.Datum2.Value1, LData.Datum2.Mat1, LPoint);
    _UpdateDatum(LData.Datum3.Value1, LData.Datum3.Mat1, LPoint);

    LP2 := LPoint;

    _UpdateHorzLine(N,  LP1, LP2,  LP1, LP2);
    Inc(N);
  end;


  //-------------------------------------------

  LEmpty := (LData.Sym2 = #0) and
            IsEmptyTolData(LData.Tol1, 1) and IsEmptyTolData(LData.Tol2, 1) and
            IsEmptyDatumData(LData.Datum1, 1) and IsEmptyDatumData(LData.Datum2, 1) and IsEmptyDatumData(LData.Datum3, 1);

  if not LEmpty then
  begin
    LPoint := ShiftPoint(FPosition, FRotation - 90, FTextHeight * 2 * N);
    LPnt1  := LPoint;

    LLineObj := FCreateLineObj(Self, LPoint, ShiftPoint(LPoint, FRotation - 90, FTextHeight* 2));
    FEntityList.Add(LLineObj);

    if LData.Sym2 <> #0 then
    begin
      LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);

      LTextObj := FCreateTextObj(Self, LData.Sym2, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight, True);
      FEntityList.Add(LTextObj);

      LPoint := ShiftPoint(LPoint, FRotation, LTextObj.TextWidth);
      LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);

      LLineObj := FCreateLineObj(Self, LPoint, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 2));
      FEntityList.Add(LLineObj);

//      LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);
    end;

    _UpdateTol(LData.Tol1.Dia2, LData.Tol1.Value2, LData.Tol1.Mat2, LPoint);
    _UpdateTol(LData.Tol2.Dia2, LData.Tol2.Value2, LData.Tol2.Mat2, LPoint);

    _UpdateDatum(LData.Datum1.Value2, LData.Datum1.Mat2, LPoint);
    _UpdateDatum(LData.Datum2.Value2, LData.Datum2.Mat2, LPoint);
    _UpdateDatum(LData.Datum3.Value2, LData.Datum3.Mat2, LPoint);


    LPnt2  := LPoint;

    _UpdateHorzLine(N,  LP1, LP2,  LPnt1, LPnt2);
    Inc(N);
  end;


  //-------------------------------------------
  LEmpty := (LData.Height = '') and (LData.ProTolZone = #0);

  if not LEmpty then
  begin
    LPoint := ShiftPoint(FPosition, FRotation - 90, FTextHeight * 2 * N);
    LPnt1  := LPoint;

    LLineObj := FCreateLineObj(Self, LPoint, ShiftPoint(LPoint, FRotation - 90, FTextHeight* 2));
    FEntityList.Add(LLineObj);

    LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);

    if LData.Height <> '' then
    begin
      LTextObj := FCreateTextObj(Self, LData.Height, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight,  False);
      FEntityList.Add(LTextObj);

      LPoint := ShiftPoint(LPoint, FRotation, LTextObj.TextWidth);
    end;

    if LData.ProTolZone <> #0 then
    begin
      LTextObj := FCreateTextObj(Self, LData.ProTolZone, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight, True);
      FEntityList.Add(LTextObj);

      LPoint := ShiftPoint(LPoint, FRotation, LTextObj.TextWidth);
    end;

    LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);

    LLineObj := FCreateLineObj(Self, LPoint, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 2));
    FEntityList.Add(LLineObj);

    LPnt2  := LPoint;
    _UpdateHorzLine(N,  LP1, LP2,  LPnt1, LPnt2);
    Inc(N);
  end;


  //-------------------------------------------

  if LData.DatumId <> '' then
  begin
    LPoint := ShiftPoint(FPosition, FRotation - 90, FTextHeight * 2 * N);
    LPnt1  := LPoint;

    LLineObj := FCreateLineObj(Self, LPoint, ShiftPoint(LPoint, FRotation - 90, FTextHeight* 2));
    FEntityList.Add(LLineObj);


    LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);

    LTextObj := FCreateTextObj(Self, LData.DatumId, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 0.5), FRotation, FTextHeight,  False);
    FEntityList.Add(LTextObj);

    LPoint := ShiftPoint(LPoint, FRotation, LTextObj.TextWidth);
    LPoint := ShiftPoint(LPoint, FRotation, FTextHeight * 0.5);

    LLineObj := FCreateLineObj(Self, LPoint, ShiftPoint(LPoint, FRotation - 90, FTextHeight * 2));
    FEntityList.Add(LLineObj);

    LPnt2  := LPoint;
    _UpdateHorzLine(N,  LP1, LP2,  LPnt1, LPnt2);

    Inc(N);
  end;

  if N > 0 then
  begin
    LLineObj := FCreateLineObj(Self, LP1, LP2);
    FEntityList.Add(LLineObj);
  end;

  Result := True;
end;

function TUdTolerance.DoUpdate(AAxes: TUdAxes): Boolean;
var
  I: Integer;
  LBound: TRect2D;
begin
  LBound := FBoundsRect;

  Result := UpdateEntities(AAxes);

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

function TUdTolerance.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
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





//-----------------------------------------------------------------------------------------

function TUdTolerance.GetChildEntities: TList;
begin
  Result := FEntityList;
end;

function TUdTolerance.GetGripPoints(): TUdGripPointArray;
begin
  System.SetLength(Result, 1);
  Result[0] := MakeGripPoint(Self, gmPoint, 0, FPosition, 0);
end;

function TUdTolerance.GetOSnapPoints: TUdOSnapPointArray;
begin
  System.SetLength(Result, 1);
  Result[0] := MakeOSnapPoint(Self, OSNP_END, FPosition, -1);
end;






//-----------------------------------------------------------------------------------------


function TUdTolerance.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;

  if (AGripPnt.Mode = gmPoint) and (AGripPnt.Index = 0) then
     Result := Self.Move(FPosition, AGripPnt.Point);
end;


function TUdTolerance.Pick(APoint: TPoint2D): Boolean;
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

function TUdTolerance.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
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

function TUdTolerance.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPosition := UdGeo2D.Translate(Dx, Dy, FPosition);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdTolerance.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LTheSeg, LMirSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPosition := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FPosition);

  LTheSeg := UdGeo2D.Segment2D(FPosition, ShiftPoint(FPosition, FRotation, 5));
  LMirSeg := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LTheSeg);

  FRotation := GetAngle(LMirSeg.P1, LMirSeg.P2);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdTolerance.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPosition := UdGeo2D.Rotate(ABase, ARota, FPosition);
  FRotation := FixAngle(FRotation + ARota);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdTolerance.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPosition := UdGeo2D.Scale(ABase, AFactor, AFactor, FPosition);
  FTextHeight := FTextHeight *  AFactor;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdTolerance.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;

//  if not AForce then
//  begin
//    if not Self.IsVisible or Self.IsLock() then Exit;
//    if not Assigned(AOther) or not AOther.IsVisible or AOther.IsLock() then Exit;
//  end;
//
//  Result := UdUtils.EntitiesIntersection(Self.GetXData(), AOther);
end;


function TUdTolerance.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  I: Integer;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  System.SetLength(Result, FEntityList.Count);

  for I := 0 to FEntityList.Count - 1 do
    Result[I] := TUdEntity(FEntityList[I]).ScaleEx(ABase, XFactor, YFactor)[0];
end;



//-----------------------------------------------------------------------------------------

procedure TUdTolerance.SaveToStream(AStream: TStream);
begin
  inherited;

  StrToStream(AStream, FContents);
  FloatToStream(AStream, FPosition.X);
  FloatToStream(AStream, FPosition.Y);
  FloatToStream(AStream, FRotation);
  FloatToStream(AStream, FTextHeight);
end;

procedure TUdTolerance.LoadFromStream(AStream: TStream);
begin
  inherited;

  FContents    := StrFromStream(AStream);
  FPosition.X  := FloatFromStream(AStream);
  FPosition.Y  := FloatFromStream(AStream);
  FRotation    := FloatFromStream(AStream);
  FTextHeight  := FloatFromStream(AStream);

  Update();
end;



procedure TUdTolerance.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Contents']  := FContents;

  LXmlNode.Prop['Position']  := Point2DToStr(FPosition);
  LXmlNode.Prop['Rotation']  := FloatToStr(FRotation);
  LXmlNode.Prop['TextHeight']:= FloatToStr(FTextHeight);
end;

procedure TUdTolerance.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FContents   := LXmlNode.Prop['Contents'];
  FPosition   := StrToPoint2D(LXmlNode.Prop['Position']);
  FRotation   := StrToFloatDef(LXmlNode.Prop['Rotation'], 0);
  FTextHeight := StrToFloatDef(LXmlNode.Prop['TextHeight'], 2.5);

  Update();
end;


end.