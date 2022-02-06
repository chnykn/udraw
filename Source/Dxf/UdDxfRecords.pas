{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfRecords;

{$I UdDefs.INC}

interface

uses
  Windows, Classes;

type
  TUdDxfRecordBin = record
    Code: Integer;
    Value: string;
  end;
  TUdDxfRecordBinArray = array of TUdDxfRecordBin;


  //*** UdDxfRecords ***//
  TUdDxfRecords = class(TObject)
  private
    FItems: TUdDxfRecordBinArray;


  protected
    class function CheckCode12(ACode: Byte): Integer; {$IFDEF D2010UP} static; {$ENDIF}
    class function CheckCode2000(ACode: Integer): Integer; {$IFDEF D2010UP} static; {$ENDIF}
    class function ReadString(AStream: TStream): AnsiString; {$IFDEF D2010UP} static; {$ENDIF}

  public
    constructor Create(); overload;
    constructor Create(ACapacity: Integer); overload;


  end;


implementation

uses
  SysUtils, UdStreams;


//==================================================================================================
{ TUdDxfRecords }

constructor TUdDxfRecords.Create;
begin
  SetLength(FItems, 0);
end;

constructor TUdDxfRecords.Create(ACapacity: Integer);
begin
  SetLength(FItems, ACapacity);
end;


class function TUdDxfRecords.CheckCode12(ACode: Byte): Integer;
var
  N: Integer;
begin
  N := Trunc(ACode / 10);

  if (N in [0, 10, 100]) then
    Result := 2
  else if ((N >= 1) and (N < 6)) or ((N >= 11) and (N < 15)) or ((N >= 21) and (N < 24)) then
    Result := 3
  else if (N in [6, 7, 17]) then
    Result := 4
  else if (N = 9) then
    Result := 5
  else if (ACode = 255) then
    Result := 6
  else if (ACode = 100) then
    Result := 1
  else
    Result :=  0;
end;

class function TUdDxfRecords.CheckCode2000(ACode: Integer): Integer;
var
  N: Integer;
begin
  N := Trunc(ACode / 10);

  if (N = 0) or (N = 10) or ((N >= 30) and (N < 37)) or (N = 39) or (N = 41) or (N = 43) or (N = 100) then
  begin
    if (ACode = 1004) then
      Result := 7
    else
      Result := 2;
  end
  else begin
    if ((N >= 1) and (N < 6)) or ((N >= 11) and (N < 15)) or ((N >= 21) and (N < 24)) or (N = 46) or (N = 47) or ((N >= 101) and (N < 106)) then
      Result := 3
    else if (N in [6, 7, 17, 27, 28, 37, 38, 40, 45, 106]) or (N = 1070) then
      Result := 4
    else if (N in [9, 42, 44])  or (N = 1071)then
      Result := 5
    else if (N = 29) then
      Result := 8
    else if (ACode = 100) then
      Result := 1
    else
      Result := 0;
  end;
end;


class function TUdDxfRecords.ReadString(AStream: TStream): AnsiString;
var
  B: Byte;
  N: Integer;
  LPos: Integer;
  LStr: AnsiString;
begin

  LPos := AStream.Position;

  N := 1;
  B := ByteFromStream(AStream);

  while (B <> 0) do
  begin
    Inc(N);
    B := ByteFromStream(AStream);
  end;

  AStream.Seek(LPos, soFromBeginning);

  System.SetLength(LStr, N-1);
  AStream.ReadBuffer(LStr[1], N-1);

  ByteFromStream(AStream);

  Result := LStr;
end;




end.