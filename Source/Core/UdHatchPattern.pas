{
  This file is part of the DelphiCAD SDK

  Copyright:
  (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdHatchPattern;

{$I UdDefs.INC}

interface

uses
  Classes, Types,
  UdTypes, UdGTypes, UdObject, UdPatternLines;

type
  TUdHatchPattern = class;

  TUdHatchPatternEvent = procedure(Sender: TObject; HatchPattern: TUdHatchPattern) of object;
  TUdHatchPatternAllowEvent = procedure(Sender: TObject; HatchPattern: TUdHatchPattern; var Allow: Boolean) of object;


  TUdHatchPattern = class(TUdObject)
  private
    FName: string;
    FComment: string;
    FPatternLines: TUdPatternLines;

  protected
    procedure SetName(const AValue: string);
    procedure SetComment(const AValue: string);
    procedure SetPatternLines(const AValue: TUdPatternLines);

  public
    constructor Create(); overload; override;
    constructor Create(AName: string; AComment: string =''); reintroduce; overload;

    destructor Destroy(); override;

    procedure Assign(Source: TPersistent); override;

    function IsSolid(): Boolean;
    function IsEqual(AValue: TUdHatchPattern): Boolean;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;    

    procedure SaveToStrings(AStrings: TStrings);
    procedure LoadFromStrings(AStrings: TStrings; var APos: Integer);

  published
    property Name: string read FName write SetName;
    property Comment: string read FComment write SetComment;
    property PatternLines: TUdPatternLines read FPatternLines write SetPatternLines;

  end;



implementation

uses
  SysUtils, UdPatternLine,
  UdUtils, UdMath, UdStreams, UdXml;



//=================================================================================================



{ TUdHatchPattern }

constructor TUdHatchPattern.Create();
begin
  inherited;

  FName := '';
  FComment := '';
  FPatternLines := TUdPatternLines.Create;
end;


constructor TUdHatchPattern.Create(AName: string; AComment: string ='');
begin
  Self.Create();
  FName := AName;
  FComment := AComment;
end;


destructor TUdHatchPattern.Destroy;
begin
  FPatternLines.Free;
  FPatternLines := nil;

  inherited;
end;



procedure TUdHatchPattern.Assign(Source: TPersistent);
begin
  if Source.InheritsFrom(TUdHatchPattern) then
  begin
    FName         := TUdHatchPattern(Source).FName;
    FComment      := TUdHatchPattern(Source).FComment;
    FPatternLines.Assign(TUdHatchPattern(Source).FPatternLines);
  end
  else inherited;
end;



function TUdHatchPattern.IsSolid: Boolean;
begin
  Result := (UpperCase(FName) = 'SOLID') or
            ((FPatternLines.Count = 1) and (System.Length(FPatternLines.Items[0].Dashes) = 0) and (FPatternLines.Items[0].Offset.Y <= 0.125));
end;

function TUdHatchPattern.IsEqual(AValue: TUdHatchPattern): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not Assigned(AValue) then Exit;

  if (FPatternLines.Count <> AValue.FPatternLines.Count) then Exit;

  for I := 0 to FPatternLines.Count - 1 do
    if not FPatternLines.Items[I].IsEqual(AValue.FPatternLines.Items[I]) then Exit; //=====>>>>

  Result := True;
end;


procedure TUdHatchPattern.SetName(const AValue: string);
begin
  FName := AValue;
end;

procedure TUdHatchPattern.SetComment(const AValue: string);
begin
  FComment := AValue;
end;


procedure TUdHatchPattern.SetPatternLines(const AValue: TUdPatternLines);
begin
  if Assigned(AValue) and (AValue <> FPatternLines) then
    FPatternLines.Assign(AValue);
end;





//----------------------------------------------------------------------------------


function PatternLineToStr(AValue: TUdPatternLine): string;
var
  I: Integer;
  LDashesStr: string;
begin
  LDashesStr := '';
  if not ( (System.Length(AValue.Dashes) = 1) and UdMath.IsEqual(AValue.Dashes[0], 0.0) ) then
  begin
    for I := 0 to System.Length(AValue.Dashes) - 1 do
    begin
      LDashesStr := LDashesStr +FloatToStr(AValue.Dashes[I]);
      if I < System.Length(AValue.Dashes) - 1 then LDashesStr := LDashesStr + ',';
    end;
  end;

  Result :=
    FloatToStr(AValue.Angle) + ',' +
    FloatToStr(AValue.Origin.X) + ',' +
    FloatToStr(AValue.Origin.Y) + ',' +
    FloatToStr(AValue.Offset.X) + ',' +
    FloatToStr(AValue.Offset.Y);

  if LDashesStr <> '' then
    Result := Result + ',' + LDashesStr;
end;

function PatternLineFromStr(AStr: string): TUdPatternLine;
var
  I: Integer;
  LStr: string;
  LStrs: TStringDynArray;
  LDashes: TFloatArray;
begin
  Result := nil;
  LStr := Trim(AStr);

  if (LStr <> '') then
  begin
    if LStr[1] = '*' then Exit; //===========>>>>>

    LStrs := UdUtils.StrSplit(LStr, ',');

    if System.Length(LStrs) >= 5 then
    begin
      if System.Length(LStrs) > 5 then
      begin
        System.SetLength(LDashes, System.Length(LStrs) - 5);
        for I := 0 to System.Length(LDashes) - 1 do LDashes[I] := StrToFloat(LStrs[I+5]);
      end
      else begin
        System.SetLength(LDashes, 1);
        LDashes[0] := 0;
      end;

      Result := TUdPatternLine.Create(
        StrToFloat(LStrs[0]),
        StrToFloat(LStrs[1]),
        StrToFloat(LStrs[2]),
        StrToFloat(LStrs[3]),
        StrToFloat(LStrs[4]),
        LDashes
      );
    end;
  end;
end;






procedure SavePatternLines(AStream: TStream; APatternLines: TUdPatternLines);
var
  I: Integer;
  LPatternLine: TUdPatternLine;
begin
  IntToStream(AStream, APatternLines.Count);

  for I := 0 to APatternLines.Count - 1 do
  begin
    LPatternLine := APatternLines.Items[I];

    FloatToStream(AStream,   LPatternLine.Angle);
    Point2DToStream(AStream, LPatternLine.Origin);
    Point2DToStream(AStream, LPatternLine.Offset);
    FloatsToStream(AStream,  LPatternLine.Dashes);
  end;
end;

procedure TUdHatchPattern.SaveToStream(AStream: TStream);
begin
  inherited;

  StrToStream(AStream, FName);
  StrToStream(AStream, FComment);
  SavePatternLines(AStream, FPatternLines);
end;



procedure LoadPatternLines(AStream: TStream; APatternLines: TUdPatternLines);
var
  I, L: Integer;
  LPatternLine: TUdPatternLine;
  LAngle: Float;
  LOrigin, LOffset: TPoint2D;
  LDashes: TFloatArray;
begin
  APatternLines.Clear();

  L := IntFromStream(AStream);
  for I := 0 to L - 1 do
  begin
    LAngle    :=  FloatFromStream(AStream);
    LOrigin   :=  Point2DFromStream(AStream);
    LOffset   :=  Point2DFromStream(AStream);
    LDashes   :=  FloatsFromStream(AStream);

    LPatternLine := TUdPatternLine.Create(LAngle, LOrigin.X, LOrigin.Y, LOffset.X, LOffset.Y, LDashes);
    APatternLines.Add(LPatternLine);
  end;
end;

procedure TUdHatchPattern.LoadFromStream(AStream: TStream);
begin
  inherited;

  FName := StrFromStream(AStream);
  FComment := StrFromStream(AStream);
  LoadPatternLines(AStream, FPatternLines);
end;




procedure TUdHatchPattern.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  I: Integer;
  LXmlNode: TUdXmlNode;
  LPatternLinesNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);
  LXmlNode.Prop['Name']    := FName;
  LXmlNode.Prop['Comment'] := FComment;

  LPatternLinesNode := LXmlNode.Add();
  LPatternLinesNode.Name := 'PatternLines';
  
  LPatternLinesNode.Prop['Count'] := IntToStr(FPatternLines.Count);
  for I := 0 to FPatternLines.Count - 1 do
    LPatternLinesNode.Prop['PatternLine' + IntToStr(I)] := PatternLineToStr(FPatternLines.Items[I]);
end;


procedure TUdHatchPattern.LoadFromXml(AXmlNode: TObject); 
var
  I, L: Integer;
  LXmlNode: TUdXmlNode;
  LPatternLine: TUdPatternLine;
  LPatternLinesNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FName    := LXmlNode.Prop['Name'];
  FComment := LXmlNode.Prop['Comment'];

  FPatternLines.Clear();
  LPatternLinesNode := LXmlNode.FindItem('PatternLines');
  
  if Assigned(LPatternLinesNode) then
  begin
    L := StrToIntDef(LPatternLinesNode.Prop['Count'], 0);
    for I := 0 to L - 1 do
    begin
      LPatternLine := PatternLineFromStr(LPatternLinesNode.Prop['PatternLine' + IntToStr(I)]);
      if Assigned(LPatternLine) then FPatternLines.Add(LPatternLine);
    end;
  end;
end;





//----------------------------------------------------------------------------------


procedure TUdHatchPattern.SaveToStrings(AStrings: TStrings);
var
  I: Integer;
  LItemStr: string;
  LPatternLine: TUdPatternLine;
begin
  AStrings.Add('*' + FName + ',' + FComment);
  for I := 0 to FPatternLines.Count - 1 do
  begin
    LPatternLine := FPatternLines.Items[I];
    LItemStr := PatternLineToStr(LPatternLine);

    AStrings.Add(LItemStr);
  end;
end;

procedure TUdHatchPattern.LoadFromStrings(AStrings: TStrings; var APos: Integer);
var
  N: Integer;
  LStr: string;
  LStrs: TStringDynArray;
  LPatternLine: TUdPatternLine;
begin
  if (APos < 0) or (APos >= AStrings.Count - 1) then Exit;

  LStr := Trim(AStrings[APos]);
  if (System.Length(LStr) <= 1) or (LStr[1] <> '*') then Exit;

  N := APos;
  Delete(LStr, 1, 1);

  LStrs := UdUtils.StrSplit(LStr, ',');
  FName := UpperCase(LStrs[0]);

  FComment := '';
  if System.Length(LStrs) > 0 then FComment := LStrs[1];

  FPatternLines.Clear;

  Inc(N);
  while (N < AStrings.Count) do
  begin
    LStr := Trim(AStrings[N]);
    LPatternLine := PatternLineFromStr(LStr);

    if Assigned(LPatternLine) then
      FPatternLines.Add(LPatternLine);
      
    Inc(N);
  end;

  APos := N;
end;

end.