{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfWriteClasses;

{$I UdDefs.INC}

interface

uses
  UdDxfTypes, UdDxfWriteSection;

type

  TUdDxfWriteClasses = class(TUdDxfWriteSection)
  public
    procedure Execute(); override;
  end;

implementation

{ TUdDxfWriteClasses }


procedure TUdDxfWriteClasses.Execute();
var
  I: Integer;
begin
{$IFDEF DXF12}
  if (Self.Version = dxf12) then Exit; // Ver12 has no classes
{$ENDIF}

  Self.AddRecord(0, 'SECTION');
  Self.AddRecord(2, 'CLASSES');

  for I := 0 to 5 do
  begin
      AddRecord(0, 'CLASS');
      case I of
          0:
          begin
              AddRecord(1, 'ACDBDICTIONARYWDFLT');
              AddRecord(2, 'AcDbDictionaryWithDefault');
              AddRecord(3, 'ObjectDBX Classes');
              AddRecord(90, '0');
          end;

          1:
          begin
              AddRecord(1, 'IMAGEDEF');
              AddRecord(2, 'AcDbRasterImageDef');
              AddRecord(3, 'ISM');
              AddRecord(90, '0');
          end;

          2:
          begin
              AddRecord(1, 'IMAGE');
              AddRecord(2, 'AcDbRasterImage');
              AddRecord(3, 'ISM');
              AddRecord(90, '127');
          end;

          3:
          begin
              AddRecord(1, 'IMAGEDEF_REACTOR');
              AddRecord(2, 'AcDbRasterImageDefReactor');
              AddRecord(3, 'ObjectDBX Classes');
              AddRecord(90, '1');
          end;

          4:
          begin
              AddRecord(1, 'ACDBPLACEHOLDER');
              AddRecord(2, 'AcDbPlaceHolder');
              AddRecord(3, 'ObjectDBX Classes');
              AddRecord(90, '0');
          end;

          5:
          begin
              AddRecord(1, 'LAYOUT');
              AddRecord(2, 'AcDbLayout');
              AddRecord(3, 'ObjectDBX Classes');
              AddRecord(90, '0');
          end;
      end;

      if (Self.Version = dxf2004) then AddRecord(91, '1');

      AddRecord(280, '0');

      if (I = 2) then AddRecord(281, '1') else AddRecord(281, '0');
  end;

  Self.AddRecord(0, 'ENDSEC');
end;

end.