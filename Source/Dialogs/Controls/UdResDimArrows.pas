{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdResDimArrows;

{$R UdDimArrows.res}

interface

uses
  Windows, Classes, Graphics,
  UdDimProps, UdHashMaps;

type

  TUdResDimArrows = class(TObject)
  private
    FList: TList;
    FHashMap: TUdStrHashMap;

  public
    constructor Create();
    destructor Destroy(); override;

    function GetBitmap(AName: string): TBitmap; overload;
    function GetBitmap(AKind: TUdDimArrowKind): TBitmap; overload;
  end;


implementation

uses
  SysUtils;


{ TUdResDimArrows }

constructor TUdResDimArrows.Create;
begin
  FList := TList.Create();
  FHashMap := TUdStrHashMap.Create();
end;

destructor TUdResDimArrows.Destroy;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do TObject(FList[I]).Free;
  FList.Free();

  FHashMap.Free();

  inherited;
end;


function TUdResDimArrows.GetBitmap(AName: string): TBitmap;
var
  LName: string;
  LBitmap: TBitmap;
begin
  LName := UpperCase(AName);
  LBitmap := TBitmap( FHashMap.GetValue(LName) );

  if not Assigned(LBitmap) then
  begin
    LBitmap             := TBitmap.Create;
    LBitmap.Handle      := LoadBitmap(Hinstance, PChar(LName) );
    LBitmap.Transparent := True;

    FList.Add(LBitmap);
    FHashMap.Add(LName, LBitmap);
  end;

  Result := LBitmap;
end;

function TUdResDimArrows.GetBitmap(AKind: TUdDimArrowKind): TBitmap;
begin
  Result := Self.GetBitmap(UdDimProps.GetDimArrowName(AKind, False));
end;

end.