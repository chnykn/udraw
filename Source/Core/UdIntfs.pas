{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdIntfs;

{$I UdDefs.INC}

interface

uses
   Classes, UdTypes, UdObject;

type
  IUdAxes = interface
    ['{639B49B8-FD79-4F28-BBF6-3E752413A645}']

    function XPixel(const X: Float): Integer;
    function YPixel(const Y: Float): Integer;
    function XValue(const X: Float): Float;
    function YValue(const Y: Float): Float;

    function XPixelF(const X: Float): Float;
    function YPixelF(const Y: Float): Float;

    function PointPixel(const AValuePnt: TPoint2D): TPoint;
    function PointValue(const APixelPnt: TPoint): TPoint2D; overload;

    function PointsPixel(const AValuePnts: TPoint2DArray): TPointArray;
    function PointsValue(const APixelPnts: TPointArray): TPoint2DArray; overload;

    function GetPixelPerValue(AIndex: Integer): Float;
    function GetValuePerPixel(AIndex: Integer): Float;
  end;

  IUdCanvasSupport = interface
    ['{92D00B2F-1C34-4B88-951C-8E93586A8BB4}']

    function GetBitmapCanvas(): TObject;
    function GetControlCanvas(): TObject;
  end;


  IUdExplode = interface
    ['{1CED8240-5A1B-4F52-84C5-E51EDD48F58C}']

    function Explode(): TUdObjectArray;
  end;


  IUdActiveSupport = interface
    ['{4B70F070-70B3-45F5-B968-56F669F839CE}']

    function SetActive(AIndex: Integer): Boolean;
    function GetActiveIndex(): Integer;
  end;


  IUdAxesSupport = interface
    ['{0B7C6EC5-1412-4D98-ACFF-B8B803485633}']

    function GetAxes(): TObject;
  end;




  //------------------------------------------------------------------

  IUdObjectCollection  = interface
    ['{AD2B8AD9-2646-4D9D-8845-B2A97AFE3D8D}']

    function Add(AObj: TUdObject): Boolean;
    function Insert(AIndex: Integer; AObj: TUdObject): Boolean;
    function Remove(AObj: TUdObject): Boolean;
    function RemoveAt(AIndex: Integer): Boolean;
    function IndexOf(AObj: TUdObject): Integer;
    function Contains(AObj: TUdObject): Boolean;
  end;

  IUdObjectItem  = interface
    ['{85824792-19ED-4CF9-A958-1AB5F8168344}']

    //... ...
  end;


  IUdChildEntities  = interface
    ['{72AA6505-EA5E-4B2F-B005-BFEECC7CA889}']

    function GetChildEntities(): TList;
  end;  



  IUdUndoRedo = interface
    ['{0026E9EF-8AC2-4299-B341-89DC3A5B5395}']
    function BeginUndo(AName: string): Boolean;
    function EndUndo(): Boolean;

    function PerformUndo(): Boolean;
    function PerformRedo(): Boolean;
  end;


  IUdCCPSupport = interface  //Cut Copy Paste
   ['{E126B44D-2743-466F-82A3-D6311452C974}']

    function CutClip(): Boolean;
    function CopyClip(): Boolean;
    function PasteClip(): TUdObjectArray;
  end;

implementation

end.