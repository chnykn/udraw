{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdAcnConsts;

{$I UdDefs.INC}

{$DEFINE CN_LANG}

interface

uses
  Windows;

const

{$IFDEF CN_LANG}
   {$INCLUDE UdAncCost.Cn.inc}
{$ELSE}
   {$INCLUDE UdAncCost.En.inc}
{$ENDIF}




implementation

end.