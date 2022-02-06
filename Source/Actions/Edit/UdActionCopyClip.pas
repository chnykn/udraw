{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionCopyClip;

{$I UdDefs.INC}

interface

uses
  UdActionCutClip;

type  
  //*** TUdActionCopyClip ***//
  TUdActionCopyClip = class(TUdActionCutClip)
  protected
    function IsCopyClip(): Boolean; override;
    
  public
    class function CommandName(): string; override;
  end;
  

implementation


//==================================================================================================
{ TUdActionCopyClip }

class function TUdActionCopyClip.CommandName: string;
begin
  Result := 'copyclip';
end;

function TUdActionCopyClip.IsCopyClip: Boolean;
begin
  Result := True;
end;

end.