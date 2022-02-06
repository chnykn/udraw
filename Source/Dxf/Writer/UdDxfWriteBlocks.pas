{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfWriteBlocks;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdDocument, UdDxfTypes, UdDxfWriteSection;

type

  TUdDxfWriteBlocks = class(TUdDxfWriteSection)
  protected
    procedure AddBlocks();
  {$IFDEF DXF12}
    procedure AddBlocks12();
  {$ENDIF}
  public
    constructor Create(AOwner: TObject);  override;
    destructor Destroy; override;

    procedure Execute(); override;

  end;


implementation

uses
  SysUtils,
  UdDxfWriter, UdDxfWriteTables, UdDxfWriteEntites, UdLayout,
  UdEntity, UdDimension, UdBlock, UdUtils;


//================================================================================================
{ TUdDxfWriteBlocks }

constructor TUdDxfWriteBlocks.Create(AOwner: TObject);
begin
  inherited;

end;

destructor TUdDxfWriteBlocks.Destroy;
begin
  //...
  inherited;
end;




//-----------------------------------------------------------------------------------------------

procedure TUdDxfWriteBlocks.AddBlocks();
var
  I, J: Integer;
  N, M: Integer;
  LFlag: Boolean;
  LName: string;
  LHandle: string;
  LBlock: TUdBlock;
  LEntity: TUdEntity;
  LLayout: TUdLayout;
  LWriteEntites: TUdDxfWriteEntites;
begin
  Self.AddRecord(0, 'SECTION');
  Self.AddRecord(2, 'BLOCKS');



  Self.AddRecord(0, 'BLOCK');
  Self.AddRecord(5, Self.NewHandle());

  LHandle := Self.BlockHandles.GetValue('*Model_Space');
  Self.AddRecord(330, LHandle);
  Self.AddRecord(100, 'AcDbEntity');

  Self.AddRecord(8, Self.Document.ActiveLayer.Name );
  Self.AddRecord(100, 'AcDbBlockBegin');
  Self.AddRecord(2, '*Model_Space');

  Self.AddRecord(70, '0');
  Self.AddRecord(71, '0');

  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);

  Self.AddRecord(3, '*Model_Space');
  Self.AddRecord(1, '');
  Self.AddRecord(0, 'ENDBLK');

  Self.AddRecord(5, Self.NewHandle());
  Self.AddRecord(330, LHandle);
  Self.AddRecord(100, 'AcDbEntity');
  Self.AddRecord(67, '1');
  Self.AddRecord(8, Self.Document.ActiveLayer.Name );
  Self.AddRecord(100, 'AcDbBlockEnd');



  N := 0;
  M := 0;
  LName := '';
  for I := 1 to Self.Document.Layouts.Count - 1 do
  begin
    LLayout := Self.Document.Layouts.Items[I];
    if not Assigned(LLayout) then Continue;

    LFlag := False;

    if Self.Document.ActiveLayout = Self.Document.ModelSpace then
//    if (LowerCase(Self.Document.ActiveLayout.Name) = 'model') then
    begin
      if (M = 0) then
        LName := '*Paper_Space'
      else begin
        LName := '*Paper_Space' + IntToStr(N);
        LFlag := True;
      end;
    end
    else begin
      if (LLayout.Name = Self.Document.ActiveLayout.Name) then
        LName := '*Paper_Space'
      else begin
        LName := '*Paper_Space' + IntToStr(N);
        LFlag := True;
      end;
    end;

    Inc(M);

    Self.AddRecord(0, 'BLOCK');
    Self.AddRecord(5, Self.NewHandle());

    LHandle := Self.BlockHandles.GetValue(LName);
    Self.AddRecord(330, LHandle);
    Self.AddRecord(100, 'AcDbEntity');
    Self.AddRecord(8, Self.Document.ActiveLayer.Name);
    Self.AddRecord(100, 'AcDbBlockBegin');
    Self.AddRecord(2, LName);
    Self.AddRecord(70, '0');
    Self.AddRecord(71, '0');
    Self.AddRecord(10, 0);
    Self.AddRecord(20, 0);
    Self.AddRecord(30, 0);
    Self.AddRecord(3, LName);
    Self.AddRecord(1, '');


    if LFlag then
    begin
      if Assigned(LLayout.ViewPort) and LLayout.ViewPort.Inited then
      begin
        LWriteEntites := TUdDxfWriteEntites.Create(FOwner);
        try
          LWriteEntites.AddViewport(LLayout, LName, LHandle, False, False);
          if LLayout.ViewPort.Visible then
            LWriteEntites.AddViewport(LLayout, LName, LHandle, False, True);
          
          LWriteEntites.AddEntities(LLayout.Entities, LHandle, True);
        finally
          LWriteEntites.Free();
        end;
      end;

      Inc(N);
    end;


    Self.AddRecord(0, 'ENDBLK');

    Self.AddRecord(5, Self.NewHandle());
    Self.AddRecord(330, LHandle);
    Self.AddRecord(100, 'AcDbEntity');
    Self.AddRecord(67, '1');
    Self.AddRecord(8, Self.Document.ActiveLayer.Name);
    Self.AddRecord(100, 'AcDbBlockEnd');
  end;



  for I := 0 to Self.Document.Blocks.Count - 1 do
  begin
    LBlock := Self.Document.Blocks.Items[I];
    if not Assigned(LBlock) then Continue;

//    LName := UpperCase(LBlock.Name);
//    if (Pos('*X', LName) = 1) then Continue;

    Self.AddRecord(0, 'BLOCK');
    Self.AddRecord(5, Self.NewHandle());

    LHandle := Self.BlockHandles.GetValue(LBlock.Name);
    Self.AddRecord(330, LHandle);
    Self.AddRecord(100, 'AcDbEntity');

    Self.AddRecord(8, '0');

    Self.AddRecord(100, 'AcDbBlockBegin');
    Self.AddRecord(2, LBlock.Name);

    if (LBlock.IsXref) then Self.AddRecord(70, '4') else Self.AddRecord(70, '0');
    if (LBlock.IsXref) and (not LBlock.IsXrefLoaded) then Self.AddRecord(71, '1') else Self.AddRecord(71, '0');

    Self.AddRecord(10, LBlock.Origin.X);
    Self.AddRecord(20, LBlock.Origin.Y);
    Self.AddRecord(30, 0);
    Self.AddRecord(3, LBlock.Name);

    if (LBlock.IsXref) then
      Self.AddRecord(1, LBlock.XrefFile)
    else begin
      Self.AddRecord(1, '');

      LWriteEntites := TUdDxfWriteEntites.Create(FOwner);
      try
        LWriteEntites.AddEntities(LBlock.Entities, LHandle, False);
      finally
        LWriteEntites.Free();
      end;
    end;

    Self.AddRecord(0, 'ENDBLK');

    Self.AddRecord(5, Self.NewHandle() );
    Self.AddRecord(330, LHandle);
    Self.AddRecord(100, 'AcDbEntity');
    Self.AddRecord(8, '0');
    Self.AddRecord(100, 'AcDbBlockEnd');
  end;


  for I := 0 to Self.Document.Layouts.Count - 1 do
  begin
    LLayout := Self.Document.Layouts.Items[I];

    for J := 0 to LLayout.Entities.Count - 1 do
    begin
      LEntity := LLayout.Entities.Items[J];
      if not Assigned(LEntity) or not LEntity.InheritsFrom(TUdDimension) then Continue;

      Self.AddRecord(0, 'BLOCK');
      Self.AddRecord(5, Self.NewHandle());

      LHandle := Self.BlockHandles.GetValue(TUdDimension(LEntity).BlockName);
      Self.AddRecord(330, LHandle);
      Self.AddRecord(100, 'AcDbEntity');

      Self.AddRecord(8, '0');

      Self.AddRecord(100, 'AcDbBlockBegin');
      Self.AddRecord(2, TUdDimension(LEntity).BlockName);

      Self.AddRecord(70, '1');

      Self.AddRecord(10, 0);
      Self.AddRecord(20, 0);
      Self.AddRecord(30, 0);
      Self.AddRecord(3, TUdDimension(LEntity).BlockName);

      LWriteEntites := TUdDxfWriteEntites.Create(FOwner);
      try
        LWriteEntites.AddEntities(TUdDimension(LEntity).EntityList, LHandle, False);
      finally
        LWriteEntites.Free();
      end;

      Self.AddRecord(0, 'ENDBLK');

      Self.AddRecord(5, Self.NewHandle() );
      Self.AddRecord(330, LHandle);
      Self.AddRecord(100, 'AcDbEntity');
      Self.AddRecord(8, '0');
      Self.AddRecord(100, 'AcDbBlockEnd');
    end;
  end;


  Self.AddRecord(0, 'ENDSEC');
end;


{$IFDEF DXF12}
procedure TUdDxfWriteBlocks.AddBlocks12();
var
  I: Integer;
  LBlock: TUdBlock;
  LEntity: TUdEntity;
  LWriteEntites: TUdDxfWriteEntites;
begin
  Self.AddRecord(0, 'SECTION');
  Self.AddRecord(2, 'BLOCKS');

  Self.AddRecord(0, 'BLOCK');
  Self.AddRecord(8, Self.Document.ActiveLayer.Name);
  Self.AddRecord(2, '$Model_Space');
  Self.AddRecord(70, '0');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(3, '$Model_Space');
  Self.AddRecord(1, '');
  Self.AddRecord(0, 'ENDBLK');

  Self.AddRecord(5, Self.NewHandle());
  Self.AddRecord(8, Self.Document.ActiveLayer.Name);


  Self.AddRecord(0, 'BLOCK');
  Self.AddRecord(67, '1');
  Self.AddRecord(8, Self.Document.ActiveLayer.Name);
  Self.AddRecord(2, '$Paper_Space');
  Self.AddRecord(70, '0');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(3, '$Paper_Space');
  Self.AddRecord(1, '');
  Self.AddRecord(0, 'ENDBLK');

  Self.AddRecord(5, Self.NewHandle());
  Self.AddRecord(67, '1');
  Self.AddRecord(8, Self.Document.ActiveLayer.Name);


  for I := 0 to Self.Document.Blocks.Count - 1 do
  begin
    LBlock := Self.Document.Blocks.Items[I];
    if not Assigned(LBlock) then Continue;

    Self.AddRecord(0, 'BLOCK');
    Self.AddRecord(8, '0');
    Self.AddRecord(2, LBlock.Name);

    if (LBlock.IsXref) then Self.AddRecord(70, '4') else Self.AddRecord(70, '0');

    Self.AddRecord(10, LBlock.Origin.X);
    Self.AddRecord(20, LBlock.Origin.Y);
    Self.AddRecord(30, 0);
    Self.AddRecord(3, LBlock.Name);

    if (LBlock.IsXref) then
      Self.AddRecord(1, LBlock.XrefFile)
    else begin
      Self.AddRecord(1, '');

      LWriteEntites := TUdDxfWriteEntites.Create(FOwner);
      try
        LWriteEntites.AddEntities(LBlock.Entities, '', False);
      finally
        LWriteEntites.Free();
      end;
    end;

    Self.AddRecord(0, 'ENDBLK');

    Self.AddRecord(5, Self.NewHandle() );
    Self.AddRecord(8, '0');
  end;




  for I := 0 to Self.Document.ModelSpace.Entities.Count - 1 do
  begin
    LEntity := Self.Document.ModelSpace.Entities.Items[I];
    if not Assigned(LEntity) or not LEntity.InheritsFrom(TUdDimension) then Continue;

    Self.AddRecord(0, 'BLOCK');
    Self.AddRecord(8, '0');
    Self.AddRecord(2, TUdDimension(LEntity).BlockName);

    Self.AddRecord(70, '1');

    Self.AddRecord(10, 0);
    Self.AddRecord(20, 0);
    Self.AddRecord(30, 0);
    Self.AddRecord(3, TUdDimension(LEntity).BlockName);

    LWriteEntites := TUdDxfWriteEntites.Create(FOwner);
    try
      LWriteEntites.AddEntities(TUdDimension(LEntity).EntityList, '', False);
    finally
      LWriteEntites.Free();
    end;

    Self.AddRecord(0, 'ENDBLK');

    Self.AddRecord(5, Self.NewHandle() );
    Self.AddRecord(8, '0');
  end;


  Self.AddRecord(0, 'ENDSEC');
end;
{$ENDIF}


procedure TUdDxfWriteBlocks.Execute();
begin
{$IFDEF DXF12}
  if Self.Version = dxf12 then  Self.AddBlocks12() else
{$ENDIF}
  Self.AddBlocks();
end;

end.