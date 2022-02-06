{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfTypes;

{$I UdDefs.INC}

interface

uses
  UdTypes;

type
  TUdDxfVersion = ({$IFDEF DXF12}dxf12=0,{$ENDIF} dxf2000=1, dxf2004=2);


  TUdDxfRecord = record
    Code: Integer;
    Value: string;
    Kind: Integer;
  end;
  PUdDxfRecord = ^TUdDxfRecord;


  TUdDxfSectionKind = (dsUnknown, dsHeader, dsClasses, dsTables, dsBlocks, dsEntities, dsObjects, dsEndOfFile);


  (*
	TUdDxfBlockKind = (bkBlock, bkLauout);

  TUdDxfBlockRec = record
    Name: string;
    Handle: string;
  end;
  PUdDxfBlockRec = ^TUdDxfBlockRec;

  TUdDxfBlockRecArray = array of TUdDxfBlockRec;
  *)

  TUdDxfLayoutRec = record
    BlockHandle   : string;

    Layout        : TObject;
    Handle        : string;

    PaperWidth    : Float;
    PaperHeight   : Float;
    PaperCenter   : TPoint2D;

    VPortWidth    : Float;
    VPortHeight   : Float;
    VPortCenter   : TPoint2D;

    VPortLgCenter : TPoint2D;
    VPortLgHeight : Float;
  end;
  PUdDxfLayoutRec = ^TUdDxfLayoutRec;



  TUdDxfImageRec = record
    Handle: string;
    ImageHandle: string;

		DefName: string;
		ImageFilename: string;
  end;
  PUdDxfImageRec = ^TUdDxfImageRec;

  TUdDxfImageRecArray = array of TUdDxfImageRec;



procedure InitDxfLayoutRec(var AValue: TUdDxfLayoutRec);

implementation

{ TUdDxfLayout }

procedure InitDxfLayoutRec(var AValue: TUdDxfLayoutRec);
begin
  AValue.BlockHandle := '';
  
  AValue.Layout   := nil;
  AValue.Handle   := '';

  AValue.PaperWidth     := -1;
  AValue.PaperHeight    := -1;
  AValue.PaperCenter.X  := -1;
  AValue.PaperCenter.Y  := -1;

  AValue.VPortWidth     := -1;
  AValue.VPortHeight    := -1;
  AValue.VPortCenter.X  := -1;
  AValue.VPortCenter.Y  := -1;

  AValue.VPortLgCenter.X  := -1;
  AValue.VPortLgCenter.Y  := -1;

  AValue.VPortLgHeight  := -1;
end;

end.