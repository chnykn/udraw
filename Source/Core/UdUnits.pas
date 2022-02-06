{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdUnits;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdConsts, UdTypes, UdObject;

type

  {长度单位          科学             小数        工程       建筑               分数      }
  TUdLengthUnit = (luScientific, luDecimal, luEngineering, luArchitectural,  luFractional );

  {角度单位       十进制度数    度/分/秒    梯度(百分度)    弧度      勘测单位   }
  TUdAngleUnit  = (auDegrees, auDegMinSec, auGrads,        auRadians, auSurveyor);

  //*** TUdUnits ***//
  TUdUnits = class(TUdObject)
  private
    FLenUnit: TUdLengthUnit;
    FLenPrecision: Byte;

    FAngUnit: TUdAngleUnit;
    FAngPrecision: Byte;

    FAngBase: Float;
    FAngClockWise: Boolean;

  protected
    function GetTypeID: Integer; override;

    procedure SetLenUnit(const AValue: TUdLengthUnit);
    procedure SetLenPrecision(const AValue: Byte);

    procedure SetAngPrecision(const AValue: Byte);
    procedure SetAngUnit(const AValue: TUdAngleUnit);

    procedure SetAngBase(const AValue: Float);
    procedure SetAngClockWise(const AValue: Boolean);

    procedure CopyFrom(AValue: TUdObject); override;
    
  public
    constructor Create(); override;
    destructor Destroy(); override;

    function RealToStr(const AValue: Float): string;
    function AngToStr(const AValue: Float): string;

    function StrToReal(const AValue: string; var AReturn: Float): Boolean;
    function StrToAng(const AValue: string; var AReturn: Float): Boolean;

    
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  published
    property LenUnit     : TUdLengthUnit read FLenUnit      write SetLenUnit     ;
    property LenPrecision: Byte          read FLenPrecision write SetLenPrecision;

    property AngUnit     : TUdAngleUnit  read FAngUnit      write SetAngUnit     ;
    property AngPrecision: Byte          read FAngPrecision write SetAngPrecision;
    property AngBase     : Float         read FAngBase      write SetAngBase;
    property AngClockWise: Boolean       read FAngClockWise write SetAngClockWise;
  end;


function RToS(const AValue: Float; AMode: TUdLengthUnit; APrecision: Byte;
              ASuppressLeading: Boolean = False; ASuppressTrailing: Boolean = False): string;
function AngToS(const AValue: Float; AMode: TUdAngleUnit; APrecision: Byte;
              ASuppressLeading: Boolean = False; ASuppressTrailing: Boolean = False): string;

function SToR(const AValue: string; AMode: TUdLengthUnit; var AReturn: Float): Boolean;
function SToAng(const AValue: string; AMode: TUdAngleUnit; var AReturn: Float): Boolean;


implementation

uses
  SysUtils, StrUtils,
  UdMath, UdStreams, UdXml;


//=================================================================================================

function GetFormatStr(APrecision: Byte; ASuppressLeading, ASuppressTrailing: Boolean; AScientific: Boolean = False): string;
var
  LStr: string;
begin
  if ASuppressLeading then Result := '#' else Result := '0';

  if APrecision > 0 then
  begin
    if ASuppressTrailing then LStr := '#' else LStr := '0';
    Result := Result + '.' + StrUtils.DupeString(LStr, APrecision);
  end;

  if AScientific then Result := Result + 'E+00';
end;

function RToS(const AValue: Float; AMode: TUdLengthUnit; APrecision: Byte;
  ASuppressLeading: Boolean = False; ASuppressTrailing: Boolean = False): string;

  function _GetFraction(ADigit: Float; APrecision: Byte): string;
  var
    N, D: Integer;
  begin
    Result := '';
    if (APrecision = 0) then Exit;

    D := 1 shl APrecision;
    N := Round(ADigit * D);

    if N = 0 then Exit;

    while not Odd(N) do
    begin
      D := D div 2;
      N := N div 2;
    end;

    Result := ' ' + IntToStr(N) + '/' + IntToStr(D);
  end;

var
  LVal, LVal1: Integer;
  LValue, LDigit: Float;
begin
  case AMode of
    luScientific: Result := FormatFloat(GetFormatStr(APrecision, ASuppressLeading, ASuppressTrailing, True), AValue);

    luDecimal:
      begin
        Result := FormatFloat(GetFormatStr(APrecision, ASuppressLeading, ASuppressTrailing, False), AValue);
        if Result = '' then Result := '0';
      end;

    luEngineering:
      begin
        LValue := AValue / 12;
        
        LVal := Trunc(LValue);
        LDigit := Abs(AValue - LVal * 12);

        Result := IntToStr(LVal) + '''-' +
                  FormatFloat(GetFormatStr(APrecision, ASuppressLeading, ASuppressTrailing, False), LDigit) + '"';
      end;

    luArchitectural:
      begin
        LValue := AValue / 12;
        
        LVal := Trunc(LValue);
        LDigit := Abs(AValue - LVal * 12);

        LVal1 := Trunc(LDigit);
        LDigit := Abs(LDigit - LVal1);

        Result := IntToStr(LVal) + '''-' + IntToStr(LVal1) + _GetFraction(LDigit, APrecision) + '"';
      end;

    luFractional   :
      begin
        if APrecision = 0 then Result := IntToStr(Round(AValue)) else
        begin
          LVal := Trunc(AValue);
          LDigit := Abs(AValue - LVal);
          Result := IntToStr(LVal) + _GetFraction(LDigit, APrecision);
        end;
      end;
  end;
end;


function AngToS(const AValue: Float; AMode: TUdAngleUnit; APrecision: Byte;
  ASuppressLeading: Boolean = False; ASuppressTrailing: Boolean = False): string;
var
  N: Integer;
  LStr: Char;
  LFormatStr: string;
  LDeg, LMin: Integer;
  LValue, LDigit: Float;
begin
  case AMode of
    auDegrees,
      auSurveyor:
      begin
        Result := FormatFloat(GetFormatStr(APrecision, ASuppressLeading, ASuppressTrailing, False), AValue);
        if Result = '' then Result := '0';
      end;

    auDegMinSec:
      begin
        LDeg := Trunc(AValue);
        if APrecision = 0 then
        begin
          Result := IntToStr(LDeg) + 'd';
        end
        else begin
          LDigit := Abs(AValue - LDeg);
          LValue := LDigit * 60;
          LMin := Trunc(LValue);
          LDigit := Abs(LValue - LMin);
          LValue := LDigit * 60;

          Result := IntToStr(LDeg) + 'd' + IntToStr(LMin) + '''';

          if APrecision > 2 then
          begin
            LFormatStr := '00';
            N := APrecision - 4;

            if N > 0 then
            begin
              if ASuppressTrailing then LStr := '#' else LStr := '0';
              LFormatStr := LFormatStr + '.' + StrUtils.DupeString(LStr, N);
            end;

            Result := Result + FormatFloat(LFormatStr, LValue) + '"';
          end;
        end;
      end;

    auGrads:
      begin
        Result := FormatFloat(GetFormatStr(APrecision, ASuppressLeading, ASuppressTrailing, False), AValue * (10/9));
        if Result = '' then Result := '0';

        Result := Result + 'g';
      end;

    auRadians:
      begin
        Result := FormatFloat(GetFormatStr(APrecision, ASuppressLeading, ASuppressTrailing, False), DegToRad(AValue));
        if Result = '' then Result := '0';

        Result := Result + 'r';
      end;

//    auSurveyor:
//      begin
//        Result := FloatToStrF(AValue, ffNumber, MAXWORD, APrecision);
//      end;
  end;
end;





//----------------------------------------------------------------------------------


function _FractToFloat(const AValue: string; var AReturn: Float): Boolean;
var
  N: Integer;
  LS1, LS2: string;
  LV1, LV2: Float;
begin
  Result := False;
  if AValue = '' then Exit;

  N := Pos('/', AValue);
  LS1 := Copy(AValue, 1, N - 1);
  LS2 := Copy(AValue, N + 1, System.Length(AValue));

  if TryStrToFloat(LS1, LV1) and TryStrToFloat(LS2, LV2) then
  begin
    AReturn := LV1 / LV2;
    Result := True;
  end;
end;

function _FractionalSToR(const AValue: string; var AReturn: Float): Boolean;
var
  N: Integer;
  LSign: Integer;
  LValue: string;
  LMain, LFrac: Float;
  LMainS, LFracS: string;
begin
  Result := TryStrToFloat(AValue, AReturn);
  if Result then Exit; //=====>>>

  LValue := Trim(AValue);
  if LValue = '' then  Exit; //=====>>>

  LSign := 1;
  if LValue[1] = '-' then
  begin
    LSign := -1;
    Delete(LValue, 1, 1);
  end;
  

  N := Pos(' ', LValue);
  if N > 0 then
  begin
    LMainS := Copy(LValue, 1, N - 1);

    Delete(LValue, 1, N);
    LFracS := LValue;

    if TryStrToFloat(LMainS, LMain) then
    begin
      AReturn := LMain;
      if _FractToFloat(LFracS, LFrac) then AReturn := AReturn + LFrac;
      Result := True;
    end;
  end
  else begin
    Result := _FractToFloat(LValue, AReturn);
  end;

  if Result then AReturn := AReturn * LSign;
end;


function _ArchitecturalSToR(const AValue: string; var AReturn: Float): Boolean;
var
  N: Integer;
  LSign: Integer;
  LFeet, LInch: Float;
  LFeetS, LInchS: string;
begin
  Result := False;
  if TryStrToFloat(AValue, LFeet) then
  begin
    AReturn := LFeet * 12;
    Result := True;
  end
  else begin
    N := Pos('''', AValue);
    if N > 0 then
    begin
      LFeetS := Copy(AValue, 1, N - 1);

      LInchS := Copy(AValue, N + 1, System.Length(AValue));
      N := Pos('-', LInchS);
      if N > 0 then Delete(LInchS, 1, N);
      N := Pos('"', LInchS);
      if N > 0 then Delete(LInchS, N, System.Length(LInchS));

      if TryStrToFloat(LFeetS, LFeet) then
      begin
        LSign := 1;
        if IsEqual(LFeet, 0.0) then
        begin
          if (System.Length(LFeetS) > 0) and (LFeetS[1] = '-') then LSign := -1;
        end
        else begin
          if (LFeet < 0) then LSign := -1;
        end;

        if not _FractionalSToR(LInchS, LInch) then LInch := 0.0;

        AReturn := LFeet * 12;
        if NotEqual(LInch, 0.0, 1.0E-12) then
          AReturn := AReturn + LInch * LSign;

        Result := True;
      end;
    end;
  end;

end;

function _EngineeringSToR(const AValue: string; var AReturn: Float): Boolean;
var
  N: Integer;
  LSign: Integer;
  LFeet, LInch: Float;
  LFeetS, LInchS: string;
begin
  Result := False;
  if TryStrToFloat(AValue, LFeet) then
  begin
    AReturn := LFeet * 12;
    Result := True;
  end
  else begin
    N := Pos('''', AValue);
    if N > 0 then
    begin
      LFeetS := Copy(AValue, 1, N - 1);

      LInchS := Copy(AValue, N + 1, System.Length(AValue));
      N := Pos('-', LInchS);
      if N > 0 then Delete(LInchS, 1, N);
      N := Pos('"', LInchS);
      if N > 0 then Delete(LInchS, N, System.Length(LInchS));

      if TryStrToFloat(LFeetS, LFeet) then
      begin
        LSign := 1;
        if IsEqual(LFeet, 0.0) then
        begin
          if (System.Length(LFeetS) > 0) and (LFeetS[1] = '-') then LSign := -1;
        end
        else begin
          if (LFeet < 0) then LSign := -1;
        end;

        if not TryStrToFloat(LInchS, LInch) then LInch := 0.0;

        AReturn := LFeet * 12;
        if NotEqual(LInch, 0.0, 1.0E-12) then
          AReturn := AReturn + LInch * LSign;

        Result := True;
      end;
    end;
  end;
end;



function SToR(const AValue: string; AMode: TUdLengthUnit; var AReturn: Float): Boolean;
var
  LValue: string;
begin
  Result := False;
  LValue := Trim(AValue);

  case AMode of
    luScientific,
      luDecimal   : Result := TryStrToFloat(LValue, AReturn);
    luEngineering : Result := _EngineeringSToR(LValue, AReturn);
    luArchitectural:Result := _ArchitecturalSToR(LValue, AReturn);
    luFractional   :Result := _FractionalSToR(LValue, AReturn);
  end;
end;




function _MinSecSToAng(const AValue: string; var AReturn: Float): Boolean;
var
  N: Integer;
  LMin, LSec: Float;
  LMinS, LSecS: string;
begin
  Result := False;
  if TryStrToFloat(AValue, LMin) then
  begin
    AReturn := LMin * 60;
    Result := True;
  end
  else begin
    N := Pos('''', AValue);
    if N > 0 then
    begin
      LMinS := Copy(AValue, 1, N - 1);

      LSecS := Copy(AValue, N + 1, System.Length(AValue));
      N := Pos('"', LSecS);
      if N > 0 then Delete(LSecS, N, System.Length(LSecS));

      if TryStrToFloat(LMinS, LMin) then
      begin
        if not TryStrToFloat(LSecS, LSec) then LSec := 0.0;

        AReturn := LMin / 60;
        if NotEqual(LSec, 0.0, 1.0E-12) then
          AReturn := AReturn + LSec / (60 * 60);

        Result := True;
      end;
    end;
  end;
end;


function SToAng(const AValue: string; AMode: TUdAngleUnit; var AReturn: Float): Boolean;
var
  N: Integer;
  LSign: Integer;
  LDeg, LMinSec: Float;
  LDegS, LMinSecS: string;
  LValue: string;
begin
  Result := False;
  LValue := Trim(AValue);

  case AMode of
    auDegrees: Result := TryStrToFloat(LValue, AReturn);
    auDegMinSec:
      begin
        N := Pos('d', LValue);
        LDegS := Copy(LValue, 1, N - 1);
        if TryStrToFloat(LDegS, LDeg) then
        begin
          LSign := 1;
          if IsEqual(LDeg, 0.0) then
          begin
            if (System.Length(LDegS) > 0) and (LDegS[1] = '-') then LSign := -1;
          end
          else begin
            if (LDeg < 0) then LSign := -1;
          end;

          Delete(LValue, 1, N);
          LMinSecS := Trim(LValue);
          if not _MinSecSToAng(LMinSecS, LMinSec) then  LMinSec := 0.0;

          AReturn := LDeg + LMinSec * LSign;
          Result := True;
        end;
      end;
    auGrads:
      begin
        Result := TryStrToFloat(LValue, AReturn);
        if Result then AReturn := AReturn * (9/10);
      end;
    auRadians:
      begin
        Result := TryStrToFloat(LValue, AReturn);
        if Result then AReturn := RadToDeg(AReturn);
      end;
    auSurveyor: Result := TryStrToFloat(LValue, AReturn);
  end;
end;



//=================================================================================================

{ TUdUnits }

constructor TUdUnits.Create();
begin
  inherited;

  FLenUnit := luDecimal; //luFractional; //luArchitectural; //luEngineering;//luScientific; //luDecimal;
  FLenPrecision := 4;

  FAngUnit := auDegrees;
  FAngPrecision := 0;

  FAngBase := 0;
  FAngClockWise := False;
end;

destructor TUdUnits.Destroy;
begin

  inherited;
end;




function TUdUnits.GetTypeID: Integer;
begin
  Result := ID_UNITS;
end;


procedure TUdUnits.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdUnits) then Exit;

  FLenUnit      := TUdUnits(AValue).FLenUnit     ;
  FLenPrecision := TUdUnits(AValue).FLenPrecision;

  FAngUnit      := TUdUnits(AValue).FAngUnit     ;
  FAngPrecision := TUdUnits(AValue).FAngPrecision;

  FAngBase      := TUdUnits(AValue).FAngBase     ;
  FAngClockWise := TUdUnits(AValue).FAngClockWise;
end;



//--------------------------------------------------------------------------

function TUdUnits.RealToStr(const AValue: Float): string;
begin
  Result := RToS(AValue, FLenUnit, FLenPrecision);
end;

function TUdUnits.AngToStr(const AValue: Float): string;
var
  LValue: Float;
begin
  LValue := AValue;
  
  if FAngClockWise then
  begin
    if NotEqual(FAngBase, 0.0) then
      LValue := FixAngle(360 - LValue)
    else
      LValue := FixAngle(360 - LValue + FAngBase);
  end
  else begin
    if NotEqual(FAngBase, 0.0) then
      LValue := FixAngle(LValue - FAngBase);
  end;

  Result := AngToS(LValue, FAngUnit, FAngPrecision);
end;


function TUdUnits.StrToReal(const AValue: string; var AReturn: Float): Boolean;
begin
  Result := SToR(AValue, FLenUnit, AReturn);
end;


function TUdUnits.StrToAng(const AValue: string; var AReturn: Float): Boolean;
begin
  Result := SToAng(AValue, FAngUnit, AReturn);

  if FAngClockWise then
  begin
    if NotEqual(FAngBase, 0.0) then
      AReturn := FixAngle(360 - AReturn)
    else
      AReturn := FixAngle(360 - AReturn + FAngBase);
  end
  else begin
    if NotEqual(FAngBase, 0.0) then
      AReturn := FixAngle(AReturn - FAngBase);
  end;
end;




//---------------------------------------------------------------------------------------------

procedure TUdUnits.SetLenUnit(const AValue: TUdLengthUnit);
begin
  if (FLenUnit <> AValue) and Self.RaiseBeforeModifyObject('LenUnit') then
  begin
    FLenUnit := AValue;
    Self.RaiseAfterModifyObject('LenUnit');
  end;
end;

procedure TUdUnits.SetLenPrecision(const AValue: Byte);
begin
  if (FLenPrecision <> AValue) and Self.RaiseBeforeModifyObject('LenPrecision') then
  begin
    FLenPrecision := AValue;
    Self.RaiseAfterModifyObject('LenPrecision');
  end;
end;


procedure TUdUnits.SetAngUnit(const AValue: TUdAngleUnit);
begin
  if (FAngUnit <> AValue) and Self.RaiseBeforeModifyObject('AngUnit') then
  begin
    FAngUnit := AValue;
    Self.RaiseAfterModifyObject('AngUnit');
  end;
end;

procedure TUdUnits.SetAngPrecision(const AValue: Byte);
begin
  if (FAngPrecision <> AValue) and Self.RaiseBeforeModifyObject('AngPrecision') then
  begin
    FAngPrecision := AValue;
    Self.RaiseAfterModifyObject('AngPrecision');
  end;
end;


procedure TUdUnits.SetAngBase(const AValue: Float);
var
  LVal: Float;
begin
  LVal := FixAngle(AValue);
  
  if (FAngBase <> LVal) and Self.RaiseBeforeModifyObject('AngBase') then
  begin
    FAngBase := LVal;
    Self.RaiseAfterModifyObject('AngBase');
  end;
end;

procedure TUdUnits.SetAngClockWise(const AValue: Boolean);
begin
  if (FAngClockWise <> AValue) and Self.RaiseBeforeModifyObject('AngClockWise') then
  begin
    FAngClockWise := AValue;
    Self.RaiseAfterModifyObject('AngClockWise');
  end;
end;



//---------------------------------------------------------------------------------------------

procedure TUdUnits.SaveToStream(AStream: TStream);
begin
  inherited;

  ByteToStream(AStream, Ord(FLenUnit));
  ByteToStream(AStream, FLenPrecision);

  ByteToStream(AStream, Ord(FAngUnit));
  ByteToStream(AStream, FAngPrecision);

  FloatToStream(AStream, FAngBase);
  BoolToStream(AStream, FAngClockWise);
end;





procedure TUdUnits.LoadFromStream(AStream: TStream);
begin
  inherited;

  FLenUnit := TUdLengthUnit(ByteFromStream(AStream));
  FLenPrecision := ByteFromStream(AStream);

  FAngUnit := TUdAngleUnit(ByteFromStream(AStream));
  FAngPrecision := ByteFromStream(AStream);

  FAngBase := FloatFromStream(AStream);
  FAngClockWise := BoolFromStream(AStream);
end;




procedure TUdUnits.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['LenUnit']      := IntToStr(Ord(FLenUnit));
  LXmlNode.Prop['LenPrecision'] := IntToStr(FLenPrecision);

  LXmlNode.Prop['AngUnit']      := IntToStr(Ord(FAngUnit));
  LXmlNode.Prop['AngPrecision'] := IntToStr(FAngPrecision);

  LXmlNode.Prop['AngBase']      := FloatToStr(FAngBase);
  LXmlNode.Prop['AngClockWise'] := BoolToStr(FAngClockWise, True);
end;

procedure TUdUnits.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FLenUnit      := TUdLengthUnit(StrToIntDef(LXmlNode.Prop['LenUnit'],  1)) ;
  FLenPrecision := StrToIntDef(LXmlNode.Prop['LenPrecision'], 4)  ;

  FAngUnit      := TUdAngleUnit(StrToIntDef(LXmlNode.Prop['AngUnit'], 0))   ;
  FAngPrecision := StrToIntDef(LXmlNode.Prop['AngPrecision'], 0) ;

  FAngBase      := StrToFloatDef(LXmlNode.Prop['AngBase'], 0)    ;
  FAngClockWise := StrToBoolDef(LXmlNode.Prop['AngClockWise'], False)  ;
end;


end.