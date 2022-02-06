{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLineWeight;

{$I UdDefs.INC}

interface




type
  TUdLineWeight = -3..255;


const
  LW_BYLAYER {:TUdLineWeight}  = -1;
  LW_BYBLOCK {:TUdLineWeight}  = -2;
  LW_DEFAULT {:TUdLineWeight}  = -3;

  LW_0       {:TUdLineWeight}  = 0;
  LW_5       {:TUdLineWeight}  = 5;
  LW_9       {:TUdLineWeight}  = 9;
  LW_13      {:TUdLineWeight}  = 13;
  LW_15      {:TUdLineWeight}  = 15;
  LW_18      {:TUdLineWeight}  = 18;
  LW_20      {:TUdLineWeight}  = 20;
  LW_25      {:TUdLineWeight}  = 25;
  LW_30      {:TUdLineWeight}  = 30;
  LW_35      {:TUdLineWeight}  = 35;
  LW_40      {:TUdLineWeight}  = 40;
  LW_50      {:TUdLineWeight}  = 50;
  LW_53      {:TUdLineWeight}  = 53;
  LW_60      {:TUdLineWeight}  = 60;
  LW_70      {:TUdLineWeight}  = 70;
  LW_80      {:TUdLineWeight}  = 80;
  LW_90      {:TUdLineWeight}  = 90;
  LW_100     {:TUdLineWeight}  = 100;
  LW_106     {:TUdLineWeight}  = 106;
  LW_120     {:TUdLineWeight}  = 120;
  LW_140     {:TUdLineWeight}  = 140;
  LW_158     {:TUdLineWeight}  = 158;
  LW_200     {:TUdLineWeight}  = 200;
  LW_211     {:TUdLineWeight}  = 211;


  ALL_LINE_WEIGHTS: array[0..26] of TUdLineWeight = (LW_BYLAYER, LW_BYBLOCK, LW_DEFAULT,
   LW_0, LW_5, LW_9, LW_13, LW_15, LW_18, LW_20, LW_25, LW_30, LW_35, LW_40, LW_50, LW_53,
   LW_60, LW_70, LW_80, LW_90, LW_100, LW_106, LW_120, LW_140, LW_158, LW_200, LW_211);


//  TUdLineWeight = ( LW_BYLAYER=-1, LW_BYBLOCK=-2, LW_DEFAULT=-3,
//    LW_0=0, LW_5=5, LW_9=9, LW_13=13,LW_15=15, LW_18=18, LW_20=20,
//    LW_25=25, LW_30=30, LW_35=35, LW_40=40, LW_50=50, LW_53=53, LW_60=60, LW_70=70, LW_80=80, LW_90=90,
//    LW_100=100, LW_106=106, LW_120=120,  LW_140=140, LW_158=158, LW_200=200, LW_211=211);



type
  TUdLineWeightStatic = class(TObject)
  protected  // this "projected" because only for TUdLineWeights
    class procedure SetByLayer(AValue: TUdLineWeight); {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class procedure SetByBlock(AValue: TUdLineWeight); {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class procedure SetDefault(AValue: TUdLineWeight); {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
    class procedure SetAdjustScale(AValue: Double);    {$IFDEF SUPPORTS_STATIC} static; {$ENDIF}
  end;


function GetLineWeightName(const AValue: TUdLineWeight): string;
function GetLineWeightByName(AStr: string): TUdLineWeight;


function GetLineWeightWidth(const AValue: TUdLineWeight; ALwFactor: Double = 1.0): Integer;



implementation


const
  PIXELS_PER_MM: Double = 96 / 25.4;



//=================================================================================================


var
  GByLayerLineWeight: TUdLineWeight = LW_DEFAULT;
  GByBlockLineWeight: TUdLineWeight = LW_DEFAULT;
  GDefaultLineWeight: TUdLineWeight = LW_25;
  GAdjustScale      : Double        = 1.0; {mm}


{ TUdLineWeightStatic }


class procedure TUdLineWeightStatic.SetByLayer(AValue: TUdLineWeight);
begin
  GByLayerLineWeight := AValue;
end;

class procedure TUdLineWeightStatic.SetByBlock(AValue: TUdLineWeight);
begin
  GByBlockLineWeight := AValue;
end;

class procedure TUdLineWeightStatic.SetDefault(AValue: TUdLineWeight);
begin
  GDefaultLineWeight := AValue;
end;

class procedure TUdLineWeightStatic.SetAdjustScale(AValue: Double);
begin
  GAdjustScale := AValue;
end;







//---------------------------------------------------------------------------------------


function GetLineWeightName(const AValue: TUdLineWeight): string;
begin
  Result := '';
  case AValue of
    LW_BYLAYER : Result := 'ByLayer';
    LW_BYBLOCK : Result := 'ByBlock';
    LW_DEFAULT : Result := 'Default';
    LW_0       : Result := '0.00 mm';
    LW_5       : Result := '0.05 mm';
    LW_9       : Result := '0.09 mm';
    LW_13      : Result := '0.13 mm';
    LW_15      : Result := '0.15 mm';
    LW_18      : Result := '0.18 mm';
    LW_20      : Result := '0.20 mm';
    LW_25      : Result := '0.25 mm';
    LW_30      : Result := '0.30 mm';
    LW_35      : Result := '0.35 mm';
    LW_40      : Result := '0.40 mm';
    LW_50      : Result := '0.50 mm';
    LW_53      : Result := '0.53 mm';
    LW_60      : Result := '0.60 mm';
    LW_70      : Result := '0.70 mm';
    LW_80      : Result := '0.80 mm';
    LW_90      : Result := '0.90 mm';
    LW_100     : Result := '1.00 mm';
    LW_106     : Result := '1.06 mm';
    LW_120     : Result := '1.20 mm';
    LW_140     : Result := '1.40 mm';
    LW_158     : Result := '1.58 mm';
    LW_200     : Result := '2.00 mm';
    LW_211     : Result := '2.11 mm';
  end;
end;

function GetLineWeightByName(AStr: string): TUdLineWeight;
begin
  Result := 255;

  if AStr = 'ByLayer' then Result := LW_BYLAYER  else
  if AStr = 'ByBlock' then Result := LW_BYBLOCK  else
  if AStr = 'Default' then Result := LW_DEFAULT  else
  if AStr = '0.00 mm' then Result := LW_0        else
  if AStr = '0.05 mm' then Result := LW_5        else
  if AStr = '0.09 mm' then Result := LW_9        else
  if AStr = '0.13 mm' then Result := LW_13       else
  if AStr = '0.15 mm' then Result := LW_15       else
  if AStr = '0.18 mm' then Result := LW_18       else
  if AStr = '0.20 mm' then Result := LW_20       else
  if AStr = '0.25 mm' then Result := LW_25       else
  if AStr = '0.30 mm' then Result := LW_30       else
  if AStr = '0.35 mm' then Result := LW_35       else
  if AStr = '0.40 mm' then Result := LW_40       else
  if AStr = '0.50 mm' then Result := LW_50       else
  if AStr = '0.53 mm' then Result := LW_53       else
  if AStr = '0.60 mm' then Result := LW_60       else
  if AStr = '0.70 mm' then Result := LW_70       else
  if AStr = '0.80 mm' then Result := LW_80       else
  if AStr = '0.90 mm' then Result := LW_90       else
  if AStr = '1.00 mm' then Result := LW_100      else
  if AStr = '1.06 mm' then Result := LW_106      else
  if AStr = '1.20 mm' then Result := LW_120      else
  if AStr = '1.40 mm' then Result := LW_140      else
  if AStr = '1.58 mm' then Result := LW_158      else
  if AStr = '2.00 mm' then Result := LW_200      else
  if AStr = '2.11 mm' then Result := LW_211      ;
end;



type
  TFLineWeightStatic = class(TUdLineWeightStatic);

function GetLineWeightWidth(const AValue: TUdLineWeight; ALwFactor: Double = 1.0): Integer;
var
  LWidth: Integer;
  LValue: TUdLineWeight;
begin
  LValue := AValue;
  case AValue of
    LW_BYLAYER: LValue := GByLayerLineWeight;
    LW_BYBLOCK: LValue := GByBlockLineWeight;
    LW_DEFAULT: LValue := GDefaultLineWeight;
  end;

  LWidth := Integer(LValue);

  if LWidth < 0 then Result := 1 else
    Result := Round(PIXELS_PER_MM * GAdjustScale * ALwFactor * LWidth / 100);

  if Result <= 0 then Result := 1;
end;







end.