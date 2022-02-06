{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdOptionDisplay;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Controls, Graphics,
  UdTypes, UdConsts, UdIntfs, UdObject;

type  
  //*** TUdOptionDisplay ***//
  TUdOptionDisplay = class(TUdObject)
  private

  protected

  public
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); override;
    destructor Destroy; override;

  end;
  

implementation

{ TUdOptionDisplay }

constructor TUdOptionDisplay.Create(ADocument: TUdObject; AIsDocRegister: Boolean = True);
begin
  inherited;

end;

destructor TUdOptionDisplay.Destroy;
begin

  inherited;
end;


end.