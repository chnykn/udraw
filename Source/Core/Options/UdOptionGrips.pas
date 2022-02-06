{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdOptionGrips;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Controls, Graphics,
  UdTypes, UdConsts, UdIntfs, UdObject;

type  
  //*** TUdOptionGrips ***//
  TUdOptionGrips = class(TUdObject)
  private

  protected

  public
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); override;
    destructor Destroy; override;

  public

  end;

implementation

{ TUdOptionGrips }

constructor TUdOptionGrips.Create(ADocument: TUdObject; AIsDocRegister: Boolean = True);
begin
  inherited;

end;

destructor TUdOptionGrips.Destroy;
begin

  inherited;
end;


end.