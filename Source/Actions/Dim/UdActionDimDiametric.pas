{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDimDiametric;

{$I UdDefs.INC}

interface

uses
  UdObject, UdActionDimRadial;

type
  //*** TUdActionDimDiametric ***//
  TUdActionDimDiametric = class(TUdActionDimRadial)
  protected
    function GetDimObjClass(): TUdDimRadialClass; override;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
  end;  

implementation


uses
  UdDimDiametric;
  

//=========================================================================================
{ TUdActionDimDiametric }

class function TUdActionDimDiametric.CommandName: string;
begin
  Result := 'dimdiameter';
end;

constructor TUdActionDimDiametric.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

end;

destructor TUdActionDimDiametric.Destroy;
begin

  inherited;
end;


function TUdActionDimDiametric.GetDimObjClass(): TUdDimRadialClass;
begin
  Result := TUdDimDiametric;
end;




end.