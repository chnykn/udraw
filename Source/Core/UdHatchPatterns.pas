{
  This file is part of the DelphiCAD SDK

  Copyright:
  (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdHatchPatterns;

{$I UdDefs.INC}

interface

uses
  Classes, Types,
  UdConsts, UdIntfs, UdObject, UdHatchPattern;

type
  TUdHatchPatterns = class(TUdObject, IUdObjectCollection )
  private
    FStrList: TStringList;

    FOnAdd: TUdHatchPatternEvent;
    FOnRemove: TUdHatchPatternAllowEvent;

  protected
    function GetTypeID: Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;
    
    function AddItem(AObject: TUdHatchPattern; ACheckExits: Boolean = True): Boolean;

    function GetCount: Integer;

    {$IFNDEF D2005UP}
    function GetItem_(AIndex: Integer): TUdHatchPattern;
    {$ENDIF}

  public
    constructor Create(); override;
    destructor Destroy(); override;

//    function Add(AName: string): TUdHatchPattern; overload;
    function Add(AObject: TUdHatchPattern): Boolean; overload;

    function Remove(AName: string): Boolean; overload;
    function Remove(AIndex: Integer): Boolean; overload;
    function Remove(AObject: TUdHatchPattern): Boolean; overload;

    function GetItem(AName: string): TUdHatchPattern; overload;
    function GetItem(AIndex: Integer): TUdHatchPattern; overload;

    function IndexOf(AName: string): Integer; overload;

    procedure Clear();
    procedure AddDefaults();

    procedure SaveToPatFile(AFileName: string);
    procedure LoadFromPatFile(AFileName: string; AReDefineIfExist: Boolean);


    //IUdObjectCollection ------------------
    function Add(AObj: TUdObject): Boolean; overload;
    function Insert(AIndex: Integer; AObj: TUdObject): Boolean; overload;

    function Remove(AObj: TUdObject): Boolean; overload;
    function RemoveAt(AIndex: Integer): Boolean;

    function IndexOf(AObj: TUdObject): Integer; overload;
    function Contains(AObj: TUdObject): Boolean;


  public
    property Items[AIndex: Integer]: TUdHatchPattern read {$IFDEF D2005UP} GetItem {$ELSE} GetItem_ {$ENDIF};

  published
    property Count: Integer read GetCount;

    property OnAdd: TUdHatchPatternEvent read FOnAdd write FOnAdd;
    property OnRemove: TUdHatchPatternAllowEvent read FOnRemove write FOnRemove;

  end;

implementation

uses
  SysUtils, UdUtils;



// =================================================================================================
{ TUdHatchPatterns }

constructor TUdHatchPatterns.Create();
begin
  inherited;

  FStrList := TStringList.Create;
  Self.AddDefaults();
end;

destructor TUdHatchPatterns.Destroy;
begin
  Self.Clear();
  FStrList.Free;
  FStrList := nil;

  inherited;
end;






function TUdHatchPatterns.GetTypeID: Integer;
begin
  Result := ID_HATCHPATTERNS;
end;

procedure TUdHatchPatterns.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
//var
//  I: Integer;
begin
  inherited;

//  for I := 0 to FStrList.Count - 1 do
//  begin
//    TUdObject(FStrList.Objects[I]).SetDocument(Self.Document, False);
//    //Self.AddDocObject(TUdObject(FList[I]), False);
//  end;
end;


procedure TUdHatchPatterns.Clear;
var
  I: Integer;
begin
  for I:= FStrList.Count - 1 downto 0 do
  begin
//    Self.RemoveDocObject(TUdObject(FStrList.Objects[I]), False);
    TObject(FStrList.Objects[I]).Free;
  end;
  FStrList.Clear();

  Self.RaiseChanged();
end;



//----------------------------------------------------------------------------------------


function TUdHatchPatterns.GetCount: Integer;
begin
  Result := FStrList.Count;
end;

{$IFNDEF D2005UP}
function TUdHatchPatterns.GetItem_(AIndex: Integer): TUdHatchPattern;
begin
  Result := Self.GetItem(AIndex);
end;
{$ENDIF}




function TUdHatchPatterns.AddItem(AObject: TUdHatchPattern; ACheckExits: Boolean = True): Boolean;
begin
  Result := False;
  if ACheckExits and (Self.IndexOf(AObject.Name) >= 0) then Exit;

  AObject.Owner := Self;
  AObject.SetDocument(Self.Document, Self.IsDocRegister);

  FStrList.AddObject(UpperCase(AObject.Name), AObject);
//  Self.AddDocObject(AObject, False);
  
  if Assigned(FOnAdd) then FOnAdd(Self, AObject);
  Result := True;
end;



function TUdHatchPatterns.Add(AObject: TUdHatchPattern): Boolean;
begin
  Result := False;
  if not Assigned(AObject) and (FStrList.IndexOfObject(AObject) < 0) then Exit; //======>>>

  AObject.SetDocument(Self.Document, Self.IsDocRegister);
  AObject.Owner := Self;

  FStrList.AddObject(UpperCase(AObject.Name), AObject);
//  Self.AddDocObject(AObject, False);
  
  if Assigned(FOnAdd) then FOnAdd(Self, AObject);
  Result := True;
end;





function TUdHatchPatterns.Remove(AIndex: Integer): Boolean;
var
  LPattern: TUdHatchPattern;
begin
  Result := False;
  if (AIndex < 0) or (AIndex >= FStrList.Count) then Exit;

  Result := True;

  LPattern := TUdHatchPattern(FStrList.Objects[AIndex]);
  if Assigned(FOnRemove) then FOnRemove(Self, LPattern, Result);

  if Result then
  begin
    FStrList.Delete(AIndex);
    LPattern.Free;
//    Self.RemoveDocObject(LPattern, False);
  end;

  Result := True;
end;

function TUdHatchPatterns.Remove(AName: string): Boolean;
begin
  Result := Self.Remove(Self.IndexOf(UpperCase(AName)));
end;

function TUdHatchPatterns.Remove(AObject: TUdHatchPattern): Boolean;
begin
  Result := Self.Remove(FStrList.IndexOfObject(AObject));
end;



function TUdHatchPatterns.GetItem(AName: string): TUdHatchPattern;
var
  N: Integer;
  LName: string;
begin
  Result := nil;

  LName := UpperCase(AName);
  N := FStrList.IndexOf(LName);
  if N >= 0 then
    Result := TUdHatchPattern(FStrList.Objects[N]);
end;

function TUdHatchPatterns.GetItem(AIndex: Integer): TUdHatchPattern;
begin
  Result := nil;
  if (AIndex < 0) or (AIndex >= FStrList.Count) then Exit;

  Result := TUdHatchPattern(FStrList.Objects[AIndex]);
end;



function TUdHatchPatterns.IndexOf(AName: string): Integer;
begin
  Result := FStrList.IndexOf(UpperCase(AName));
end;




//--------------------------------------------------------------------------------------

function TUdHatchPatterns.Add(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdHatchPattern) and (FStrList.IndexOfObject(AObj) < 0) then
    Result := Self.Add(TUdHatchPattern(AObj));
end;

function TUdHatchPatterns.Insert(AIndex: Integer; AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdHatchPattern) and (FStrList.IndexOfObject(AObj) < 0) then
  begin
    if AIndex < 0 then AIndex := AIndex + FStrList.Count;
    if AIndex > FStrList.Count - 1 then AIndex := FStrList.Count - 1;

    FStrList.InsertObject(AIndex, UpperCase(TUdHatchPattern(AObj).Name), AObj);
    if Assigned(FOnAdd) then FOnAdd(Self, TUdHatchPattern(AObj));

//    Self.AddDocObject(AObj, False);
    Result := True;
  end;
end;


function TUdHatchPatterns.Remove(AObj: TUdObject): Boolean;
begin
  Result := False;
  if Assigned(AObj) and AObj.InheritsFrom(TUdHatchPattern) then
  begin
    Result := Self.Remove(TUdHatchPattern(AObj));
  end;
end;

function TUdHatchPatterns.RemoveAt(AIndex: Integer): Boolean;
begin
  Result := Self.Remove(AIndex);
end;


function TUdHatchPatterns.IndexOf(AObj: TUdObject): Integer;
begin
  Result := FStrList.IndexOfObject(AObj);
end;

function TUdHatchPatterns.Contains(AObj: TUdObject): Boolean;
begin
  Result := Self.IndexOf(AObj) >= 0;
end;





//--------------------------------------------------------------------------------------

procedure TUdHatchPatterns.AddDefaults();
var
  LPattern: TUdHatchPattern;
begin
  if (Self.IndexOf('SOLID') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'SOLID');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 0.0, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ANGLE') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ANGLE');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 6.985, [5.08, -1.905]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 0.0, 6.985, [5.08, -1.905]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ANSI31') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ANSI31');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 3.175, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ANSI32') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ANSI32');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 9.525, [0]);
    LPattern.PatternLines.Add(45.0, 4.49013, 0.0, 0.0, 9.525, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ANSI33') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ANSI33');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(45.0, 4.49013, 0.0, 0.0, 6.35, [3.175, -1.5875]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ANSI34') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ANSI34');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 19.05, [0]);
    LPattern.PatternLines.Add(45.0, 4.49013, 0.0, 0.0, 19.05, [0]);
    LPattern.PatternLines.Add(45.0, 8.98026, 0.0, 0.0, 19.05, [0]);
    LPattern.PatternLines.Add(45.0, 13.4704, 0.0, 0.0, 19.05, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ANSI35') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ANSI35');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(45.0, 4.49013, 0.0, 0.0, 6.35, [7.9375, -1.5875, 0.0, -1.5875]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ANSI36') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ANSI36');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 5.55625, 3.175, [7.9375, -1.5875, 0.0, -1.5875]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ANSI37') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ANSI37');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 3.175, [0]);
    LPattern.PatternLines.Add(135.0, 0.0, 0.0, 0.0, 3.175, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ANSI38') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ANSI38');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 3.175, [0]);
    LPattern.PatternLines.Add(135.0, 0.0, 0.0, 6.35, 3.175, [7.9375, -4.7625]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-B816') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-B816');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 203.2, [0]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 203.2, 203.2, [203.2, -203.2]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-B816C') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-B816C');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 203.2, 203.2, [396.875, -9.525]);
    LPattern.PatternLines.Add(0.0, -203.2, 9.525, 203.2, 203.2, [396.875, -9.525]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 203.2, 203.2, [-212.725, 193.675]);
    LPattern.PatternLines.Add(90.0, -9.525, 0.0, 203.2, 203.2, [-212.725, 193.675]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-B88') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-B88');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 203.2, [0]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 203.2, 101.6, [203.2, -203.2]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-BRELM') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-BRELM');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 135.484, [193.675, -9.525]);
    LPattern.PatternLines.Add(0.0, 0.0, 57.15, 0.0, 135.484, [193.675, -9.525]);
    LPattern.PatternLines.Add(0.0, 50.8, 67.7418, 0.0, 135.484, [92.075, -9.525]);
    LPattern.PatternLines.Add(0.0, 50.8, 124.892, 0.0, 135.484, [92.075, -9.525]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 0.0, 203.2, [57.15, -78.3336]);
    LPattern.PatternLines.Add(90.0, -9.525, 0.0, 0.0, 203.2, [57.15, -78.3336]);
    LPattern.PatternLines.Add(90.0, 50.8, 67.7418, 0.0, 101.6, [57.15, -78.3336]);
    LPattern.PatternLines.Add(90.0, 41.275, 67.7418, 0.0, 101.6, [57.15, -78.3336]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-BRSTD') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-BRSTD');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 67.7418, [0]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 67.7418, 101.6, [67.7418, -67.7418]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-CONC') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-CONC');
    LPattern.PatternLines.Add(50.0, 0.0, 0.0, 104.896, -149.807, [19.05, -209.55]);
    LPattern.PatternLines.Add(355.0, 0.0, 0.0, -51.7604, 187.258, [15.24, -167.64]);
    LPattern.PatternLines.Add(100.451, 15.182, -1.32825, 145.557, -176.27, [16.19, -178.09]);
    LPattern.PatternLines.Add(46.1842, 0.0, 50.8, 157.343, -224.71, [28.575, -314.325]);
    LPattern.PatternLines.Add(96.6356, 22.5899, 47.2965, 218.335, -264.405, [24.285, -267.135]);
    LPattern.PatternLines.Add(351.184, 0.0, 50.8, 196.679, 280.887, [22.86, -251.46]);
    LPattern.PatternLines.Add(21.0, 25.4, 38.1, 104.896, -149.807, [19.05, -209.55]);
    LPattern.PatternLines.Add(326.0, 25.4, 38.1, -51.7604, 187.258, [15.24, -167.64]);
    LPattern.PatternLines.Add(71.4514, 38.0345, 29.5779, 145.557, -176.27, [16.19, -178.09]);
    LPattern.PatternLines.Add(37.5, 0.0, 0.0, 53.9242, 65.2018, [0.0, -165.608, 0.0, -170.18, 0.0, -168.275]);
    LPattern.PatternLines.Add(7.5, 0.0, 0.0, 79.3242, 90.6018, [0.0, -97.028, 0.0, -161.798, 0.0, -64.135]);
    LPattern.PatternLines.Add(-32.5, -56.642, 0.0, 117.434, 68.0212, [0.0, -63.5, 0.0, -198.12, 0.0, -262.89]);
    LPattern.PatternLines.Add(-42.5, -82.042, 0.0, 92.0344, 118.821, [0.0, -82.55, 0.0, -131.572, 0.0, -186.69]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-HBONE') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-HBONE');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 101.6, 101.6, [304.8, -101.6]);
    LPattern.PatternLines.Add(135.0, 71.842, 71.842, 101.6, -101.6, [304.8, -101.6]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-PARQ1') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-PARQ1');
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 304.8, 304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(90.0, 50.8, 0.0, 304.8, 304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(90.0, 101.6, 0.0, 304.8, 304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(90.0, 152.4, 0.0, 304.8, 304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(90.0, 203.2, 0.0, 304.8, 304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(90.0, 254.0, 0.0, 304.8, 304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(90.0, 304.8, 0.0, 304.8, 304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(0.0, 0.0, 304.8, 304.8, -304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(0.0, 0.0, 355.6, 304.8, -304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(0.0, 0.0, 406.4, 304.8, -304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(0.0, 0.0, 457.2, 304.8, -304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(0.0, 0.0, 508.0, 304.8, -304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(0.0, 0.0, 558.8, 304.8, -304.8, [304.8, -304.8]);
    LPattern.PatternLines.Add(0.0, 0.0, 609.6, 304.8, -304.8, [304.8, -304.8]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-RROOF') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-RROOF');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 55.88, 25.4, [381.0, -50.8, 127.0, -25.4]);
    LPattern.PatternLines.Add(0.0, 33.782, 12.7, -25.4, 33.782, [76.2, -8.382, 152.4, -19.05]);
    LPattern.PatternLines.Add(0.0, 12.7, 21.59, 132.08, 17.018, [203.2, -35.56, 101.6, -25.4]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-RSHKE') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-RSHKE');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 647.7, 304.8, [152.4, -127.0, 177.8, -76.2, 228.6, -101.6]);
    LPattern.PatternLines.Add(0.0, 152.4, 12.7, 647.7, 304.8, [127.0, -482.6, 101.6, -152.4]);
    LPattern.PatternLines.Add(0.0, 457.2, -19.05, 647.7, 304.8, [76.2, -787.4]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 304.8, 215.9, [292.1, -927.1]);
    LPattern.PatternLines.Add(90.0, 152.4, 0.0, 304.8, 215.9, [285.75, -933.45]);
    LPattern.PatternLines.Add(90.0, 279.4, 0.0, 304.8, 215.9, [266.7, -952.5]);
    LPattern.PatternLines.Add(90.0, 457.2, -19.05, 304.8, 215.9, [292.1, -927.1]);
    LPattern.PatternLines.Add(90.0, 533.4, -19.05, 304.8, 215.9, [292.1, -927.1]);
    LPattern.PatternLines.Add(90.0, 762.0, 0.0, 304.8, 215.9, [279.4, -939.8]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('AR-SAND') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'AR-SAND');
    LPattern.PatternLines.Add(37.5, 0.0, 0.0, 28.5242, 39.8018, [0.0, -38.608, 0.0, -43.18, 0.0, -41.275]);
    LPattern.PatternLines.Add(7.5, 0.0, 0.0, 53.9242, 65.2018, [0.0, -20.828, 0.0, -34.798, 0.0, -13.335]);
    LPattern.PatternLines.Add(-32.5, -31.242, 0.0, 66.6344, 42.6212, [0.0, -12.7, 0.0, -45.72, 0.0, -59.69]);
    LPattern.PatternLines.Add(-42.5, -31.242, 0.0, 41.2344, 68.0212, [0.0, -6.35, 0.0, -29.972, 0.0, -34.29]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('BOX') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'BOX');
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 0.0, 25.4, [0]);
    LPattern.PatternLines.Add(90.0, 6.35, 0.0, 0.0, 25.4, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 25.4, [-6.35, 6.35]);
    LPattern.PatternLines.Add(0.0, 0.0, 6.35, 0.0, 25.4, [-6.35, 6.35]);
    LPattern.PatternLines.Add(0.0, 0.0, 12.7, 0.0, 25.4, [6.35, -6.35]);
    LPattern.PatternLines.Add(0.0, 0.0, 19.05, 0.0, 25.4, [6.35, -6.35]);
    LPattern.PatternLines.Add(90.0, 12.7, 0.0, 0.0, 25.4, [6.35, -6.35]);
    LPattern.PatternLines.Add(90.0, 19.05, 0.0, 0.0, 25.4, [6.35, -6.35]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('BRASS') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'BRASS');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 3.175, 0.0, 6.35, [3.175, -1.5875]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('BRICK') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'BRICK');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 0.0, 12.7, [6.35, -6.35]);
    LPattern.PatternLines.Add(90.0, 6.35, 0.0, 0.0, 12.7, [-6.35, 6.35]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('BRSTONE') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'BRSTONE');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 8.382, [0]);
    LPattern.PatternLines.Add(90.0, 22.86, 0.0, 8.382, 12.7, [8.382, -8.382]);
    LPattern.PatternLines.Add(90.0, 20.32, 0.0, 8.382, 12.7, [8.382, -8.382]);
    LPattern.PatternLines.Add(0.0, 22.86, 1.397, 12.7, 8.382, [-22.86, 2.54]);
    LPattern.PatternLines.Add(0.0, 22.86, 2.794, 12.7, 8.382, [-22.86, 2.54]);
    LPattern.PatternLines.Add(0.0, 22.86, 4.191, 12.7, 8.382, [-22.86, 2.54]);
    LPattern.PatternLines.Add(0.0, 22.86, 5.588, 12.7, 8.382, [-22.86, 2.54]);
    LPattern.PatternLines.Add(0.0, 22.86, 6.985, 12.7, 8.382, [-22.86, 2.54]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('CLAY') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'CLAY');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 4.7625, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 0.79375, 0.0, 4.7625, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 1.5875, 0.0, 4.7625, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 3.175, 0.0, 4.7625, [4.7625, -3.175]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('CORK') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'CORK');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 3.175, [0]);
    LPattern.PatternLines.Add(135.0, 1.5875, -1.5875, 0.0, 8.98026, [4.49013, -4.49013]);
    LPattern.PatternLines.Add(135.0, 2.38125, -1.5875, 0.0, 8.98026, [4.49013, -4.49013]);
    LPattern.PatternLines.Add(135.0, 3.175, -1.5875, 0.0, 8.98026, [4.49013, -4.49013]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('CROSS') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'CROSS');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 6.35, 6.35, [3.175, -9.525]);
    LPattern.PatternLines.Add(90.0, 1.5875, -1.5875, 6.35, 6.35, [3.175, -9.525]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('DASH') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'DASH');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 3.175, 3.175, [3.175, -3.175]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('DOLMIT') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'DOLMIT');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 17.9605, [8.98026, -17.9605]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('DOTS') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'DOTS');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.79375, 1.5875, [0, -1.5875]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('EARTH') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'EARTH');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 6.35, 6.35, [6.35, -6.35]);
    LPattern.PatternLines.Add(0.0, 0.0, 2.38125, 6.35, 6.35, [6.35, -6.35]);
    LPattern.PatternLines.Add(0.0, 0.0, 4.7625, 6.35, 6.35, [6.35, -6.35]);
    LPattern.PatternLines.Add(90.0, 0.79375, 5.55625, 6.35, 6.35, [6.35, -6.35]);
    LPattern.PatternLines.Add(90.0, 3.175, 5.55625, 6.35, 6.35, [6.35, -6.35]);
    LPattern.PatternLines.Add(90.0, 5.55625, 5.55625, 6.35, 6.35, [6.35, -6.35]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ESCHER') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ESCHER');
    LPattern.PatternLines.Add(60.0, 0.0, 0.0, -15.24, 26.3965, [27.94, -2.54]);
    LPattern.PatternLines.Add(180.0, 0.0, 0.0, -15.24, 26.3965, [27.94, -2.54]);
    LPattern.PatternLines.Add(300.0, 0.0, 0.0, 15.24, 26.3965, [27.94, -2.54]);
    LPattern.PatternLines.Add(60.0, 2.54, 0.0, -15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(300.0, 2.54, 0.0, 15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(60.0, -1.27, 2.1997, -15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(180.0, -1.27, 2.1997, -15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(300.0, -1.27, -2.1997, 15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(180.0, -1.27, -2.1997, -15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(60.0, -10.16, 0.0, -15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(300.0, -10.16, 0.0, 15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(60.0, 5.08, -8.79882, -15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(180.0, 5.08, -8.79882, -15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(300.0, 5.08, 8.79882, 15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(180.0, 5.08, 8.79882, -15.24, 26.3965, [5.08, -25.4]);
    LPattern.PatternLines.Add(0.0, 5.08, 4.39941, -15.24, 26.3965, [17.78, -12.7]);
    LPattern.PatternLines.Add(0.0, 5.08, -4.39941, -15.24, 26.3965, [17.78, -12.7]);
    LPattern.PatternLines.Add(120.0, 1.27, 6.59911, 15.24, 26.3965, [17.78, -12.7]);
    LPattern.PatternLines.Add(120.0, -6.35, 2.1997, 15.24, 26.3965, [17.78, -12.7]);
    LPattern.PatternLines.Add(240.0, -6.35, -2.1997, 15.24, 26.3965, [17.78, -12.7]);
    LPattern.PatternLines.Add(240.0, 1.27, -6.59911, 15.24, 26.3965, [17.78, -12.7]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('FLEX') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'FLEX');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 6.35, [6.35, -6.35]);
    LPattern.PatternLines.Add(45.0, 6.35, 0.0, 4.49013, 4.49013, [1.5875, -5.80526, 1.5875, -8.98026]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('GRASS') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'GRASS');
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 17.9605, 17.9605, [4.7625, -31.1585]);
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 25.4, [4.7625, -20.6375]);
    LPattern.PatternLines.Add(135.0, 0.0, 0.0, 0.0, 25.4, [4.7625, -20.6375]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('GRATE') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'GRATE');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 0.79375, [0]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 0.0, 3.175, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('HEX') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'HEX');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 5.49926, [3.175, -6.35]);
    LPattern.PatternLines.Add(120.0, 0.0, 0.0, 0.0, 5.49926, [3.175, -6.35]);
    LPattern.PatternLines.Add(60.0, 3.175, 0.0, 0.0, 5.49926, [3.175, -6.35]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('HONEY') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'HONEY');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 4.7625, 2.74963, [3.175, -6.35]);
    LPattern.PatternLines.Add(120.0, 0.0, 0.0, 4.7625, 2.74963, [3.175, -6.35]);
    LPattern.PatternLines.Add(60.0, 0.0, 0.0, 4.7625, 2.74963, [-6.35, 3.175]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('HOUND') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'HOUND');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 6.35, 1.5875, [25.4, -12.7]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, -6.35, 1.5875, [25.4, -12.7]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('INSUL') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'INSUL');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 9.525, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 3.175, 0.0, 9.525, [3.175, -3.175]);
    LPattern.PatternLines.Add(0.0, 0.0, 6.35, 0.0, 9.525, [3.175, -3.175]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('LINE') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'LINE');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 3.175, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('MUDST') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'MUDST');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 12.7, 6.35, [6.35, -6.35, 0.0, -6.35, 0.0, -6.35]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('NET') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'NET');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 3.175, [0]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 0.0, 3.175, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('NET3') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'NET3');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 3.175, [0]);
    LPattern.PatternLines.Add(60.0, 0.0, 0.0, 0.0, 3.175, [0]);
    LPattern.PatternLines.Add(120.0, 0.0, 0.0, 0.0, 3.175, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('PLAST') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'PLAST');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 0.79375, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 1.5875, 0.0, 6.35, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('PLASTI') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'PLASTI');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 0.79375, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 1.5875, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 3.96875, 0.0, 6.35, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('SACNCR') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'SACNCR');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 2.38125, [0]);
    LPattern.PatternLines.Add(45.0, 1.6838, 0.0, 0.0, 2.38125, [0, -2.38125]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('SQUARE') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'SQUARE');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 3.175, [3.175, -3.175]);
    LPattern.PatternLines.Add(90.0, 0.0, 0.0, 0.0, 3.175, [3.175, -3.175]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('STARS') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'STARS');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 5.49926, [3.175, -3.175]);
    LPattern.PatternLines.Add(60.0, 0.0, 0.0, 0.0, 5.49926, [3.175, -3.175]);
    LPattern.PatternLines.Add(120.0, 1.5875, 2.74963, 0.0, 5.49926, [3.175, -3.175]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('STEEL') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'STEEL');
    LPattern.PatternLines.Add(45.0, 0.0, 0.0, 0.0, 3.175, [0]);
    LPattern.PatternLines.Add(45.0, 0.0, 1.5875, 0.0, 3.175, [0]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('SWAMP') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'SWAMP');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 12.7, 21.997, [3.175, -22.225]);
    LPattern.PatternLines.Add(90.0, 1.5875, 0.0, 21.997, 12.7, [1.5875, -42.4066]);
    LPattern.PatternLines.Add(90.0, 1.98438, 0.0, 21.997, 12.7, [1.27, -42.7241]);
    LPattern.PatternLines.Add(90.0, 1.19062, 0.0, 21.997, 12.7, [1.27, -42.7241]);
    LPattern.PatternLines.Add(60.0, 2.38125, 0.0, 12.7, 21.997, [1.016, -24.384]);
    LPattern.PatternLines.Add(120.0, 0.79375, 0.0, 12.7, 21.997, [1.016, -24.384]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('TRANS') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'TRANS');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 0.0, 6.35, [0]);
    LPattern.PatternLines.Add(0.0, 0.0, 3.175, 0.0, 6.35, [3.175, -3.175]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('TRIANG') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'TRIANG');
    LPattern.PatternLines.Add(60.0, 0.0, 0.0, 4.7625, 8.24889, [4.7625, -4.7625]);
    LPattern.PatternLines.Add(120.0, 0.0, 0.0, 4.7625, 8.24889, [4.7625, -4.7625]);
    LPattern.PatternLines.Add(0.0, -2.38125, 4.12445, 4.7625, 8.24889, [4.7625, -4.7625]);
    Self.AddItem(LPattern, False);
  end;
  if (Self.IndexOf('ZIGZAG') < 0) then
  begin
    LPattern := TUdHatchPattern.Create( 'ZIGZAG');
    LPattern.PatternLines.Add(0.0, 0.0, 0.0, 3.175, 3.175, [3.175, -3.175]);
    LPattern.PatternLines.Add(90.0, 3.175, 0.0, 3.175, 3.175, [3.175, -3.175]);
    Self.AddItem(LPattern, False);
  end;
end;



procedure TUdHatchPatterns.SaveToPatFile(AFileName: string);
var
  I: Integer;
  LPattern: TUdHatchPattern;
  LStrings: TStringList;
begin
  LStrings := TStringList.Create;
  try
    for I := 0 to FStrList.Count - 1 do
    begin
      LPattern := TUdHatchPattern(FStrList.Objects[I]);
      LPattern.SaveToStrings(LStrings);
    end;

    LStrings.SaveToFile(AFileName);
  finally
    LStrings.Free;
  end;
end;


procedure TUdHatchPatterns.LoadFromPatFile(AFileName: string; AReDefineIfExist: Boolean);

  function _FindPatternHeaderLine(AStrings: TStringList; AStart: Integer; var APatternName: string): Integer;
  var
    I: Integer;
    LStr: string;
    LStrs: TStringDynArray;
  begin
    Result := -1;
    APatternName := '';
    for I := AStart to AStrings.Count - 1 do
    begin
      LStr := Trim(AStrings[I]);
      if (System.Length(LStr) > 1) and (LStr[1] = '*') and (I < (AStrings.Count - 1)) then
      begin
        Result := I;

        Delete(LStr, 1, 1);
        LStrs := UdUtils.StrSplit(LStr, ',');
        APatternName := UpperCase(LStrs[0]);

        Break;
      end;
    end;
  end;

var
  N: Integer;
  LPatternName: string;
  LStrings: TStringList;
  LPattern, LTmpPattern: TUdHatchPattern;
begin
  if not FileExists(AFileName) then Exit;

  LStrings := TStringList.Create;
  LTmpPattern := TUdHatchPattern.Create('');
  try
    LStrings.LoadFromFile(AFileName);
    N := _FindPatternHeaderLine(LStrings, 0, LPatternName);

    while N >= 0 do
    begin
      LPattern := Self.GetItem(LPatternName);
      if Assigned(LPattern) then
      begin
        if not AReDefineIfExist then LPattern := LTmpPattern;
      end
      else begin
        LPattern := TUdHatchPattern.Create(LPatternName);
        LPattern.Owner := Self;

        FStrList.AddObject(UpperCase(LPattern.Name), LPattern);
//        Self.AddDocObject(LPattern, False);
      end;

      LPattern.LoadFromStrings(LStrings, N);
      N := _FindPatternHeaderLine(LStrings, N, LPatternName);
    end;
  finally
    LTmpPattern.Free;
    LStrings.Free;
  end;

//  Self.RaiseChanged();
end;



end.