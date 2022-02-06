{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}


unit UdEvents;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics, Controls, StdCtrls,
  UdTypes;


type
  TUdPromptKind = (pkCmd, pkLog, pkHint);

  TUdKeyKind = (kkKeyDown, kkKeyUp, kkPress);
  TUdMouseKind = (mkMouseDown, mkMouseMove, mkMouseUp);

  TUdMouseButton = Controls.TMouseButton; //(mbNull, mbLeft, mbRight, mbMiddle);
  TUdShiftState  = Classes.TShiftState;    //set of (ssShift, ssAlt, ssCtrl, ssLeft, ssRight, ssMiddle, ssDouble {$IFDEF D2010UP}, ssTouch, ssPen{$ENDIF});


type
  TUdPaintEvent      = procedure(Sender: TObject; ACanvas: TCanvas) of object;
  TUdRefreshEvent    = procedure(Sender: TObject; ARect: TRect) of object;

  TUdPromptEvent     = procedure(Sender: TObject; AValue: string; AKind: TUdPromptKind) of object;
  TUdScrollEvent     = procedure(Sender: TObject; AKind: Integer; AScrollCode: TScrollCode; AScrollPos: Integer) of object;


  TUdClickEvent      = procedure(Sender: TObject; APoint: TPoint) of object;

  TUdKeyEvent        = procedure(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; var AKey: Word) of object;
  TUdMouseEvent      = procedure(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState; var APoint: TPoint) of object;
  TUdMouseWheelEvent = procedure(Sender: TObject; AKeys: SmallInt; AWheelDelta: SmallInt; XPos, YPos: Smallint) of object;

  TUdMousePointEvent = procedure(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                                 APoint: TPoint; APoint2D: TPoint2D) of object;

  TUdAllowEvent      = procedure(Sender: TObject; var AAllow: Boolean) of object;
  TUdProgressEvent   = procedure(Sender: TObject; AProgress: Integer; const AProgressMax: Integer; AMsg: string) of object;


  TUdChangedEvent    = procedure(Sender: TObject; APropName: string) of object;
  TUdChangingEvent   = procedure(Sender: TObject; APropName: string; var AAllow: Boolean) of object;

  TUdAfterModifyEvent   = procedure(Sender: TObject; AObj: TObject; APropName: string) of object;
  TUdBeforeModifyEvent  = procedure(Sender: TObject; AObj: TObject; APropName: string; {ANewValue: Variant;} var AAllow: Boolean) of object;


  TUdPickWindowEvent = procedure(Sender: TObject; ARect: TRect2D) of object;

implementation

end.