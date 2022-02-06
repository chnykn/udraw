{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfWriteObjects;

{$I UdDefs.INC}

//{$DEFINE IMAGE_ }
//{$DEFINE GROUP_ }

interface

uses
  UdDocument, UdDxfTypes, UdDxfWriteSection;

type

  TUdDxfWriteObjects = class(TUdDxfWriteSection)
  public
    procedure Execute(); override;

  end;


implementation

uses
  SysUtils,
  UdDxfWriter, UdLayout, UdPrinters, UdPlotConfig;



function GetPrinter(APlotConfig: TUdPlotConfig): TUdCustomPrinter;
var
  N: Integer;
  LPrinter: TUdCustomPrinter;
begin
  N := UdPrinters.GlobalPrinters.IndexOf(APlotConfig.PrinterName);
  LPrinter := UdPrinters.GlobalPrinters.Items[N];
  if not Assigned(LPrinter) then
    LPrinter := UdPrinters.GlobalPrinters.Printer;

  if Assigned(LPrinter) then
  begin
    LPrinter.Init();
    LPrinter.SetViewParams(APlotConfig.PaperSize, 0, 0, TUdPrinterOrientation(APlotConfig.Orientation));
  end;

  Result := LPrinter;
end;


//==================================================================================================
{ TUdDxfWriteObjects }


procedure TUdDxfWriteObjects.Execute;
var
  I, J, N: Integer;
  LLayout: TUdLayout;
  LLayoutValid: Boolean;
  LCount, LNum, LIdx: Integer;
  LHandles: array[0..8] of string;
  LDictHandle, LXRcdHandle, LMLineHandle: string;
  LPrinter: TUdCustomPrinter;
begin
{$IFDEF DXF12}
  if Self.Version = dxf12 then Exit; //=====>>>>>
{$ENDIF}

  AddRecord(0, 'SECTION');
  AddRecord(2, 'OBJECTS');
  AddRecord(0, 'DICTIONARY');

  LDictHandle := Self.NewHandle();

  AddRecord(5, LDictHandle);
  AddRecord(330, '0');
  AddRecord(100, 'AcDbDictionary');
  AddRecord(281, '1');
  AddRecord(3, 'ACAD_GROUP');

  LHandles[0] := Self.NewHandle();
  AddRecord(350, LHandles[0]);

  {$IFDEF IMAGE_}
  if (MainDoc.Images.Count > 0) then
  begin
    AddRecord(3, 'ACAD_IMAGE_DICT');
    LHandles[6] := Self.NewHandle();
    AddRecord(350, LHandles[6]);
  end;
  {$ENDIF}

  AddRecord(3, 'ACAD_LAYOUT');
  LHandles[1] := Self.NewHandle();
  AddRecord(350, LHandles[1]);

  AddRecord(3, 'ACAD_MLINESTYLE');
  LHandles[2] := Self.NewHandle();
  AddRecord(350, LHandles[2]);

  AddRecord(3, 'ACAD_PLOTSETTINGS');
  LHandles[3] := Self.NewHandle();
  AddRecord(350, LHandles[3]);

  //if (Self.Version >= 2000) then
  begin
    AddRecord(3, 'ACAD_PLOTSTYLENAME');
    LHandles[4] := Self.NewHandle();
    AddRecord(350, LHandles[4]);
  end;

  AddRecord(3, 'VECTORDRAW_OBJECTS');
  LHandles[5] := Self.NewHandle();
  AddRecord(350, LHandles[5]);

  AddRecord(3, 'DWGPROPS');
  LHandles[7] := Self.NewHandle();
  AddRecord(350, LHandles[7]);

  {$IFDEF IMAGE_}
  for I := 0 to TUdDxfWriter(FOwner).Entites.ImageDefs.Count - 1 do
  begin
    LImageDef := TUdDxfWriter(FOwner).Entites.ImageDefs[I];

    AddRecord(0, 'IMAGEDEF_REACTOR');
    AddRecord(5, LImageDef.Handle);
    AddRecord(330, LImageDef.ImageHandle);
    AddRecord(100, 'AcDbRasterImageDefReactor');
    AddRecord(90, '2.0');
    AddRecord(330, LImageDef.ImageHandle);
  end;
  {$ENDIF}

  LCount := 5;
  //if (Self.Document.Images.Count > 0) then LCount := 6;

  for I := 0 to LCount do
  begin
    //if ({(Self.Version >= 2000) or} (I <> 4)) then
    begin
      if (I <> 4) then
        Self.AddRecord(0, 'DICTIONARY')
      else
        Self.AddRecord(0, 'ACDBDICTIONARYWDFLT');

      Self.AddRecord(5, LHandles[I]);
      Self.AddRecord(102, '{ACAD_REACTORS');
      Self.AddRecord(330, LDictHandle);
      Self.AddRecord(102, '}');
      Self.AddRecord(330, LDictHandle);
      Self.AddRecord(100, 'AcDbDictionary');
      Self.AddRecord(281, '1');

      case I of
        0:
        begin
          {$IFDEF GROUP_}
          for J := 0 to Self.Document.Groups.Count - 1 do
          begin
              LGroup := Self.Document.Groups.Items[J];
              if Assigned(LGroup)
              begin
                  Self.AddRecord(3, StringToDXF(LGroup.Name));
                  Self.AddRecord(350, IntToHex(LGroup.ID, 0));
              end;
          end;
          {$ENDIF}
        end;

        1:
        begin
          for J := 1 to Self.Document.Layouts.Count - 1 do
          begin
              Self.AddRecord(3, Self.Document.Layouts.Items[J].Name);
              Self.AddRecord(350, IntToHex(Self.Document.Layouts.Items[J].ID, 0));
          end;
          Self.AddRecord(3,  Self.Document.ModelSpace.Name);
          Self.AddRecord(350, IntToHex(Self.Document.ModelSpace.ID, 0));
        end;

        2:
        begin
          Self.AddRecord(3, 'Standard');
          LMLineHandle := Self.NewHandle();
          Self.AddRecord(350, LMLineHandle);
        end;

        3: ;

        4:
        begin
          Self.AddRecord(3, 'Normal');
          Self.AddRecord(350, Self.PlotHandle);
          Self.AddRecord(100, 'AcDbDictionaryWithDefault');
          Self.AddRecord(340, Self.PlotHandle);
        end;

        5:
        begin
          Self.AddRecord(3, 'SERIALNO');
          LXRcdHandle := Self.NewHandle();
          Self.AddRecord(350, LXRcdHandle);
        end;

        6:
        begin
            {$IFDEF IMAGE_}
            for J := 0 to Self.Document.Images.Count - 1 do
            begin
                LImg := Self.Document.Images.Items[J];
                LStr := SysUtils.StringReplace(LImg.Name, '.', '_', [rfReplaceAll]);
                Self.AddRecord(3, LStr);
                Self.AddRecord(350, IntToHex(LImg.ID, 0) );
            end;
            {$ENDIF}
        end;
      end;
    end;
  end;


  {$IFDEF GROUP_}
  for I := 0 to Self.Document.Groups.Count - 1 do
  begin
    LGroup := Self.Document.Groups.Items[I];
    if not Assigned(LGroup) then Continue;

    Self.AddRecord(0, 'GROUP');
    Self.AddRecord(5, IntToHex(LGroup.ID, 0) );
    Self.AddRecord(102, '{ACAD_REACTORS');
    Self.AddRecord(330, LHandles[0]);
    Self.AddRecord(102, '}');
    Self.AddRecord(330, LHandles[0]);
    Self.AddRecord(100, 'AcDbGroup');
    Self.AddRecord(300, StringToDXF(LGroup.Description));
    Self.AddRecord(70, '0');
    if (LGroup.Selectable) then Self.AddRecord(71, '1') else Self.AddRecord(71, '0');

    for J := 0 to LGroup.Count - 1 do
      if LGroup.Items[J].InheritsFrom(TUdEntity)
        Self.AddRecord(340, IntToHex(TUdEntity(LGroup.Items[J]).ID, 0) );
  end;

  for I := 0 to Self.Document.Images.Count - 1 do
  begin
    LImage := Self.Document.Images.Items[I];
    if not Assigned(LImage) then Continue;

    Self.AddRecord(0, 'IMAGEDEF');
    Self.AddRecord(5, IntToHex(LImage.ID, 0) );
    Self.AddRecord(102, '{ACAD_REACTORS');
    Self.AddRecord(330, LHandles[6]);

    for J := 0 to TUdDxfWriter(FOwner).Entites.ImageDefs.Count - 1 do
    begin
      LImageDef := TUdDxfWriter(FOwner).Entites.ImageDefs[J];
      if LImageDef.DefName = LImage.Name then
        Self.AddRecord(330, LImageDef.Handle);
    end;

    Self.AddRecord(102, '}');
    Self.AddRecord(330, LHandles[6]);
    Self.AddRecord(100, 'AcDbRasterImageDef');
    Self.AddRecord(90, '0');
    Self.AddRecord(1, LImage.FileName);
    Self.AddRecord(10, IntToStr(LImage.Width) );
    Self.AddRecord(20, IntToStr(LImage.Height) );

    Self.AddRecord(280, '1');
    Self.AddRecord(281, '0');
  end;
  {$ENDIF}



  LNum := 1;
  LIdx := 0;

  for I := 1 to Self.Document.Layouts.Count - 1 do
  begin
    LLayout := Self.Document.Layouts.Items[I];
    if not Assigned(LLayout) then Continue;

    LLayoutValid := Assigned(LLayout.ViewPort) and (LLayout.ViewPort.Inited);

    LPrinter := nil;
    if LLayoutValid then
      LPrinter := GetPrinter(LLayout.PlotConfig);

    Self.AddRecord(0, 'LAYOUT');
    Self.AddRecord(5, IntToHex(LLayout.ID, 0));

    Self.AddRecord(102, '{ACAD_REACTORS');
    Self.AddRecord(330, LHandles[1]);
    Self.AddRecord(102, '}');
    Self.AddRecord(330, LHandles[1]);
    Self.AddRecord(100, 'AcDbPlotSettings');
    Self.AddRecord(1, '');
    if LLayoutValid then
    begin
      if Assigned(LPrinter) then Self.AddRecord(2, LPrinter.Name) else Self.AddRecord(2, 'none_device');
      N := LPrinter.PaperSizeIndex(LPrinter.PaperSize);
      if (N >= 0) and (N < LPrinter.Papers.Count) then Self.AddRecord(4, LPrinter.Papers[N]) else Self.AddRecord(4, '');
    end
    else begin
      Self.AddRecord(2, ''); //Default Windows System Printer.pc3
      Self.AddRecord(4, '');
    end;

    Self.AddRecord(6, '');

    if Assigned(LPrinter) then
    begin
      Self.AddRecord(40, LPrinter.LeftMargin);
      Self.AddRecord(41, LPrinter.BottomMargin);
      Self.AddRecord(42, LPrinter.RightMargin);
      Self.AddRecord(43, LPrinter.TopMargin);
      if LPrinter.Orientation = poLandscape then  //Self.Document.ModelSpace.PlotConfig.Orientation = 1
      begin
        Self.AddRecord(44, LPrinter.PaperHeight);
        Self.AddRecord(45, LPrinter.PaperWidth);
      end
      else begin
        Self.AddRecord(44, LPrinter.PaperWidth);
        Self.AddRecord(45, LPrinter.PaperHeight);
      end;
    end
    else begin
      Self.AddRecord(40, 0 );
      Self.AddRecord(41, 0 );
      Self.AddRecord(42, 0 );
      Self.AddRecord(43, 0 );
      Self.AddRecord(44, 0 );
      Self.AddRecord(45, 0 );
    end;

		Self.AddRecord(46, '0');
		Self.AddRecord(47, '0');

		Self.AddRecord(48 , LLayout.PlotConfig.PlotWindow.X1);
		Self.AddRecord(49 , LLayout.PlotConfig.PlotWindow.Y1);
		Self.AddRecord(140, LLayout.PlotConfig.PlotWindow.X2);
		Self.AddRecord(141, LLayout.PlotConfig.PlotWindow.Y2);
		Self.AddRecord(142, IntToStr(LLayout.PlotConfig.CopiesNumber) );
		Self.AddRecord(143, '1'); // {LLayout.Printer.PrintScale.Denumerator}

		Self.AddRecord(70, '688');
		Self.AddRecord(72, '1');
		Self.AddRecord(73,  IntToStr(LLayout.PlotConfig.Orientation) {LPrinter.LandScape ? '1' : '0'} );
		Self.AddRecord(74, '5'); // 5 or 4 ?

    Self.AddRecord(75, '16');
    Self.AddRecord(147, '1');

    Self.AddRecord(76, '0');
    Self.AddRecord(76, '2');
    Self.AddRecord(78, '300');

    Self.AddRecord(148, -LLayout.PlotConfig.PlotWindow.X1 );
    Self.AddRecord(149, -LLayout.PlotConfig.PlotWindow.Y1 );

    Self.AddRecord(100 , 'AcDbLayout');
    Self.AddRecord(1, LLayout.Name);

    Self.AddRecord(70, '1');
    Self.AddRecord(71, IntToStr(I));

    if LLayoutValid then
    begin
      Self.AddRecord(10, LLayout.PaperLimMin.X);
      Self.AddRecord(20, LLayout.PaperLimMin.Y);
      Self.AddRecord(11, LLayout.PaperLimMax.X);
      Self.AddRecord(21, LLayout.PaperLimMax.Y);
    end
    else begin
      Self.AddRecord(10, 0);
      Self.AddRecord(20, 0);
      Self.AddRecord(11, 12);
      Self.AddRecord(21, 9);
    end;

    Self.AddRecord(12, 0);
    Self.AddRecord(22, 0);
    Self.AddRecord(32, 0);


    if LLayoutValid then
    begin    
      Self.AddRecord(14, LLayout.ViewPort.BoundsRect.X1);
      Self.AddRecord(24, LLayout.ViewPort.BoundsRect.Y1);
      Self.AddRecord(34, 0);
      Self.AddRecord(15, LLayout.ViewPort.BoundsRect.X2);
      Self.AddRecord(25, LLayout.ViewPort.BoundsRect.Y2);
      Self.AddRecord(35, 0);
    end
    else begin
      Self.AddRecord(14, 0);
      Self.AddRecord(24, 0);
      Self.AddRecord(34, 0);
      Self.AddRecord(15, 0);
      Self.AddRecord(25, 0);
      Self.AddRecord(35, 0);
    end;

    Self.AddRecord(146, 0);
    Self.AddRecord(13,  0);
    Self.AddRecord(23,  0);
    Self.AddRecord(33,  0);
    Self.AddRecord(16,  1);
    Self.AddRecord(26,  0);
    Self.AddRecord(36,  0);
    Self.AddRecord(17,  0);
    Self.AddRecord(27,  1);
    Self.AddRecord(37,  0);
    Self.AddRecord(76, '0');


    if (Self.Document.ActiveLayout = Self.Document.ModelSpace) then
    begin
      if (LNum <> 1) then
      begin
        Self.AddRecord(330, Self.BlockHandles.GetValue('*Paper_Space' + IntToStr(LIdx)) );
        if LLayoutValid then
          Self.AddRecord(331, Self.ViewPortHandles.GetValue('*Paper_Space' + IntToStr(LIdx)) );
        Inc(LIdx);
      end
      else begin
        Self.AddRecord(330, Self.BlockHandles.GetValue('*Paper_Space'));
      end;
    end
    else begin
      if (LLayout.Name <> Self.Document.ActiveLayout.Name) then
      begin
        Self.AddRecord(330, Self.BlockHandles.GetValue('*Paper_Space' + IntToStr(LIdx)) );
        if LLayoutValid then
          Self.AddRecord(331, Self.ViewPortHandles.GetValue('*Paper_Space' + IntToStr(LIdx)) );
        Inc(LIdx);
      end
      else begin
        Self.AddRecord(330, Self.BlockHandles.GetValue('*Paper_Space'));
      end;
    end;

    if LLayoutValid then
    begin
      Self.AddRecord(1001, 'ACAD_PSEXT');
      Self.AddRecord(1000, 'None');
      Self.AddRecord(1000, 'None');
      Self.AddRecord(1000, 'Not applicable');

      Self.AddRecord(1070, '0');
    end;

    Inc(LNum);
  end;



  LPrinter := GetPrinter(Self.Document.ModelSpace.PlotConfig);
  
  Self.AddRecord(0,   'LAYOUT');
  Self.AddRecord(5, IntToHex(Self.Document.ModelSpace.ID, 0));
  Self.AddRecord(102, '{ACAD_REACTORS');
  Self.AddRecord(330, LHandles[1]);
  Self.AddRecord(102, '}');
  Self.AddRecord(330, LHandles[1]);
  Self.AddRecord(100, 'AcDbPlotSettings');
  Self.AddRecord(1,   '');
  if Assigned(LPrinter) then Self.AddRecord(2, LPrinter.Name) else Self.AddRecord(2, 'none_device');
  N := LPrinter.PaperSizeIndex(LPrinter.PaperSize);
  if (N >= 0) and (N < LPrinter.Papers.Count) then Self.AddRecord(4, LPrinter.Papers[N]) else Self.AddRecord(4, '');  

  Self.AddRecord(6,   '');

  if Assigned(LPrinter) then
  begin
    Self.AddRecord(40, LPrinter.LeftMargin);
    Self.AddRecord(41, LPrinter.BottomMargin);
    Self.AddRecord(42, LPrinter.RightMargin);
    Self.AddRecord(43, LPrinter.TopMargin);

    if LPrinter.Orientation = poLandscape then  //Self.Document.ModelSpace.PlotConfig.Orientation = 1
    begin
      Self.AddRecord(44, LPrinter.PaperHeight);
      Self.AddRecord(45, LPrinter.PaperWidth);
    end
    else begin
      Self.AddRecord(44, LPrinter.PaperWidth);
      Self.AddRecord(45, LPrinter.PaperHeight);
    end;
  end
  else begin
    Self.AddRecord(40, 7.5 );
    Self.AddRecord(41, 20.0 );
    Self.AddRecord(42, 7.5 );
    Self.AddRecord(43, 20.0 );
    Self.AddRecord(44, 210.0 );
    Self.AddRecord(45, 297.0 );
  end;
      
  Self.AddRecord(46,  '0'); //????
  Self.AddRecord(47,  '0'); //????
  
  Self.AddRecord(48,  0 );
  Self.AddRecord(49,  0 );
  Self.AddRecord(140, 0 );
  Self.AddRecord(141, 0 );
  Self.AddRecord(142, '1'         );
  Self.AddRecord(143, '8.704084754739808');

  Self.AddRecord(70, '11952');
  Self.AddRecord(72, '1');
  Self.AddRecord(73,  IntToStr(Self.Document.ModelSpace.PlotConfig.Orientation));
  Self.AddRecord(74, '0');
  Self.AddRecord(7,  '');
  Self.AddRecord(75,  '0');
  Self.AddRecord(147, '0.1148885871608098');

  Self.AddRecord(76, '0');
  Self.AddRecord(76, '2');
  Self.AddRecord(78, '300');
    
  Self.AddRecord(148, 0);
  Self.AddRecord(149, 0);
  Self.AddRecord(100, 'AcDbLayout');
  Self.AddRecord(1, Self.Document.ModelSpace.Name);
  Self.AddRecord(70,  '1');
  Self.AddRecord(71,  '0');

  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(11, 12);
  Self.AddRecord(21, 9);

  Self.AddRecord(12, 0);
  Self.AddRecord(22, 0);
  Self.AddRecord(32, 0);

  Self.AddRecord(14, 0);
  Self.AddRecord(24, 0);
  Self.AddRecord(34, 0);
  Self.AddRecord(15, 0);
  Self.AddRecord(25, 0);
  Self.AddRecord(35, 0);

  Self.AddRecord(146, 0);
  Self.AddRecord(13,  0);
  Self.AddRecord(23,  0);
  Self.AddRecord(33,  0);
  Self.AddRecord(16,  1);
  Self.AddRecord(26,  0);
  Self.AddRecord(36,  0);
  Self.AddRecord(17,  0);
  Self.AddRecord(27,  1);
  Self.AddRecord(37,  0);
  Self.AddRecord(76, '0');

  Self.AddRecord(330, Self.BlockHandles.GetValue('*Model_Space') );


  Self.AddRecord(0, 'MLINESTYLE');
  Self.AddRecord(5, LMLineHandle);
  Self.AddRecord(102, '{ACAD_REACTORS');
  Self.AddRecord(330, LHandles[2]);
  Self.AddRecord(102, '}');
  Self.AddRecord(330, LHandles[2]);
  Self.AddRecord(100, 'AcDbMlineStyle');
  Self.AddRecord(2, 'Standard');
  Self.AddRecord(70, '0');
  Self.AddRecord(3, '');
  Self.AddRecord(62, '256');
  Self.AddRecord(51, '90');
  Self.AddRecord(52, '90');
  Self.AddRecord(71, '2');
  Self.AddRecord(49, '0.5');
  Self.AddRecord(62, '256');
  Self.AddRecord(6, 'BYLAYER');
  Self.AddRecord(49, '-0.5');
  Self.AddRecord(62, '256');
  Self.AddRecord(6, 'BYLAYER');

//if (Self.Version >= 2000) then
  begin
    Self.AddRecord(0, 'ACDBPLACEHOLDER');
    Self.AddRecord(5, Self.PlotHandle);
    Self.AddRecord(102, '{ACAD_REACTORS');
    Self.AddRecord(330, LHandles[4]);
    Self.AddRecord(102, '}');
    Self.AddRecord(330, LHandles[4]);
  end;

  Self.AddRecord(0, 'XRECORD');
  Self.AddRecord(5, LXRcdHandle);
  Self.AddRecord(102, '{ACAD_REACTORS');
  Self.AddRecord(330, LHandles[5]);
  Self.AddRecord(102, '}');
  Self.AddRecord(330, LHandles[5]);
  Self.AddRecord(100, 'AcDbXrecord');
  Self.AddRecord(280, '1');
  Self.AddRecord(1000, 'B9997783-9578-4D8D-BD4D-9C83B6EC72D2');
  Self.AddRecord(1070, '5');
  Self.AddRecord(1070, '1');

  Self.AddRecord(0,   'XRECORD');
  Self.AddRecord(5,   LHandles[7]);
  Self.AddRecord(102, '{ACAD_REACTORS');
  Self.AddRecord(330, LDictHandle);
  Self.AddRecord(102, '}');
  Self.AddRecord(330, LDictHandle);
  Self.AddRecord(100, 'AcDbXrecord');
  Self.AddRecord(280, '1');
  Self.AddRecord(1,   'DWGPROPS COOKIE');
  Self.AddRecord(2,   '');
  Self.AddRecord(3,   '');
  Self.AddRecord(4,   '');
  Self.AddRecord(6,   '');
  Self.AddRecord(7,   '');
  Self.AddRecord(8,   '');
  Self.AddRecord(9,   '');
  Self.AddRecord(40,  '0');
  Self.AddRecord(41,  '0');
  Self.AddRecord(42,  '0');
  Self.AddRecord(1,   '');
  Self.AddRecord(90,  '0');


  Self.AddRecord(0, 'ENDSEC');
end;

end.