{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdOptionOSnap;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Controls, Graphics,
  UdTypes, UdConsts, UdIntfs, UdObject;

type  
  //*** TUdOptionOSnap ***//
  TUdOptionOSnap = class(TUdObject)
  private

  protected

  public
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); override;
    destructor Destroy; override;

  public

  end;

implementation

{ TUdOptionOSnap }

constructor TUdOptionOSnap.Create(ADocument: TUdObject; AIsDocRegister: Boolean = True);
begin
  inherited;

end;

destructor TUdOptionOSnap.Destroy;
begin

  inherited;
end;


end.