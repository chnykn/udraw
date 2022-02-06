{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfWriteTables;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, UdTypes,
  UdDocument, UdDxfTypes, UdDxfWriteSection;

type
  TUdDimStyleArrow = record
    DimStyle: TObject;
    BlockLeader: string;
    BlockFirst : string;
    BlockSecond: string;
  end;
  TUdDimStyleArrowArray = array of TUdDimStyleArrow;


  TUdDxfWriteTables = class(TUdDxfWriteSection)
  protected
  {$IFDEF DXF12}
    procedure AddVPort12();
    procedure AddLineTypes12();
    procedure AddLayers12();
    procedure AddTextStyles12();
    procedure AddViewUCS12();
    procedure AddAPPID12();
    procedure AddDimStyles12();
  {$ENDIF}

    procedure AddVPort();
    procedure AddLineTypes();
    procedure AddLayers();
    procedure AddTextStyles();
    procedure AddViewUCS();
    procedure AddAPPID();
    procedure AddBlockRecords();
    procedure AddDimStyles();

  public
    constructor Create(AOwner: TObject);  override;
    destructor Destroy; override;

    procedure Execute(); override;

  end;

implementation

uses
  SysUtils,
  UdLayout, UdLayer, UdLineType, UdColor, UdDimStyle, UdDimProps, UdTextStyle,
  UdEntity, UdDimension, UdBlock, UdUtils;





//=================================================================================================
{ TUdDxfWriteTables }

constructor TUdDxfWriteTables.Create(AOwner: TObject);
begin
  inherited;
end;

destructor TUdDxfWriteTables.Destroy;
begin
  inherited;
end;



//-----------------------------------------------------------------------------------------------
{$IFDEF DXF12}

procedure TUdDxfWriteTables.AddVPort12();
var
  LModel: TUdLayout;
  LBound: TRect2D;
  LCenter: TPoint2D;
begin
  LModel := Self.Document.ModelSpace;
  LBound := LModel.ViewBound;
  LCenter.X := (LBound.X1 + LBound.X2) / 2;
  LCenter.Y := (LBound.Y1 + LBound.Y2) / 2;

  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'VPORT');
  Self.AddRecord(70, '2');
  Self.AddRecord(0, 'VPORT');
  Self.AddRecord(2, '*Active');
  Self.AddRecord(70, '0');
  Self.AddRecord(10, '0');
  Self.AddRecord(20, '0');
  Self.AddRecord(11, '1');
  Self.AddRecord(21, '1');
  Self.AddRecord(12, LCenter.X);
  Self.AddRecord(22, LCenter.Y);
  Self.AddRecord(13, '0');
  Self.AddRecord(23, '0');
  Self.AddRecord(14, '1');
  Self.AddRecord(24, '1');
  Self.AddRecord(15, '1');
  Self.AddRecord(25, '1');
  Self.AddRecord(16, '0');
  Self.AddRecord(26, '0');
  Self.AddRecord(36, '1');
  Self.AddRecord(17, '0');
  Self.AddRecord(27, '0');
  Self.AddRecord(37, '0');
  Self.AddRecord(40, Abs(LBound.Y2 - LBound.Y1));
  Self.AddRecord(41, '1');
  Self.AddRecord(42, '0.05'{LModel.FocalLength});
  Self.AddRecord(43, '0');
  Self.AddRecord(44, '0');
  Self.AddRecord(50, '0');
  Self.AddRecord(51, '0');
  Self.AddRecord(71, '0');
  Self.AddRecord(72, '100');
  Self.AddRecord(73, '1');
  Self.AddRecord(74, '3');
  Self.AddRecord(75, '0');
  Self.AddRecord(76, '0');
  Self.AddRecord(77, '0');
  Self.AddRecord(78, '0');

  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddLineTypes12();
var
  I, J: Integer;
  LLnType: TUdLineType;
begin
  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'LTYPE');
  Self.AddRecord(70, IntToStr(Self.Document.LineTypes.Count));

  for I := 0 to Self.Document.LineTypes.Count - 1 do
  begin
    LLnType := Self.Document.LineTypes.Items[I];
    if not Assigned(LLnType) then Continue;  //or (Length(LLnType.Value) <= 0)

    Self.AddRecord(0, 'LTYPE');
    Self.AddRecord(5, IntToHex(LLnType.ID, 0));

    Self.AddRecord(2, LLnType.Name);
    Self.AddRecord(3, LLnType.Comment);

    //if Pos('|', LLnType.Name) > 0 then Self.AddRecord(70, '16') else Self.AddRecord(70, '0');
    Self.AddRecord(70, '0');

    Self.AddRecord(72, '65');
    Self.AddRecord(73, IntToStr(Length(LLnType.Value)) );
    Self.AddRecord(40, LLnType.SegmentLength() );

    for J := 0 to Length(LLnType.Value) - 1 do
      Self.AddRecord(49, LLnType.Value[J]);
  end;
  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddLayers12();
var
  I: Integer;
  LFlag: Cardinal;
  LLayer: TUdLayer;
begin
  Self.PlotHandle := NewHandle();

  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'LAYER');
  Self.AddRecord(70, IntToStr(Self.Document.Layers.Count));

  for I := 0 to Self.Document.Layers.Count - 1 do
  begin
    LLayer := Self.Document.Layers.Items[I];
    if not Assigned(LLayer) then Continue;

    Self.AddRecord(0, 'LAYER');
    Self.AddRecord(2, LLayer.Name); //Self.StringToDXF(LLayer.Name)

    LFlag := 0;
    if (not LLayer.Visible and (LLayer <> Self.Document.ActiveLayer)) then LFlag := 1;
    if (LLayer.Lock) then LFlag := LFlag + 4;

    if Pos('|', LLayer.Name) > 0 then
      Self.AddRecord(70, IntToStr(LFlag + 16))
    else
      Self.AddRecord(70, IntToStr(LFlag));

    Self.AddRecord(6, LLayer.LineType.Name);
    Self.AddRecord(62, IntToStr(LLayer.Color.IndexColor));
  end;

  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddTextStyles12();
var
  I: Integer;
  LFlag: Cardinal;
  LTextStyle: TUdTextStyle;
begin
  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'STYLE');
  Self.AddRecord(70, IntToStr(Self.Document.TextStyles.Count));

  for I := 0 to Self.Document.TextStyles.Count - 1 do
  begin
    LTextStyle := Self.Document.TextStyles.Items[I];
    if not Assigned(LTextStyle) then Continue;

    Self.AddRecord(0, 'STYLE');

  //Self.AddRecord(2, Self.StringToDXF(LTextStyle.Name));
    Self.AddRecord(2, LTextStyle.Name);

    if Pos('|', LTextStyle.Name) = 1 then Self.AddRecord(70, '16') else Self.AddRecord(70, '0');

    Self.AddRecord(40, LTextStyle.Height);
    Self.AddRecord(41, LTextStyle.WidthFactor);
  //Self.AddRecord(50, LTextStyle.Extra.ObliquingAngle);
    Self.AddRecord(50, '0');

    LFlag := 0;
    if LTextStyle.Backward then LFlag := LFlag or 2;
    if LTextStyle.Upsidedown then LFlag := LFlag or 4;

    Self.AddRecord(71, IntToStr(LFlag));
    Self.AddRecord(42, 0.25);

    Self.AddRecord(3, LTextStyle.ShxFont.ShxFile);
    Self.AddRecord(4, LTextStyle.ShxFont.BigFile);
  end;
  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddViewUCS12();
begin
  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'VIEW');
  Self.AddRecord(70, '0');
  Self.AddRecord(0, 'ENDTAB');
  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'UCS');
  Self.AddRecord(70, '0');
  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddAPPID12();
begin
  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'APPID');

  Self.AddRecord(70, '2');

  Self.AddRecord(0, 'APPID');
  Self.AddRecord(2, 'ACAD');
  Self.AddRecord(70, '0');

  Self.AddRecord(0, 'APPID');
  Self.AddRecord(2, 'ACAD_PSEXT');
  Self.AddRecord(70, '0');

  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddDimStyles12();
var
  I: Integer; //, N
  LStr: string;
  LFloat: Double;
  LDimStyle: TUdDimStyle;
begin
  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'DIMSTYLE');
  Self.AddRecord(70, IntToStr(Self.Document.DimStyles.Count));

  for I := 0 to Self.Document.DimStyles.Count - 1 do
  begin
    LDimStyle := Self.Document.DimStyles.Items[I];
    if not Assigned(LDimStyle) then Continue;

    Self.AddRecord(0, 'DIMSTYLE');
    Self.AddRecord(2, LDimStyle.Name );
    if Pos('|', LDimStyle.Name) > 0 then Self.AddRecord(70, '16') else Self.AddRecord(70, '0');


    LStr := '';
    if LDimStyle.AltUnitsProp.AltPlacement = apBelowPrimary then LStr := '\X';

    LStr := LStr + LDimStyle.UnitsProp.Prefix;
    if LDimStyle.UnitsProp.Suffix <> '' then LStr := LStr + '<>' + LDimStyle.UnitsProp.Suffix;

    Self.AddRecord(3, LStr); // DIMPOST


    LStr := LStr + LDimStyle.AltUnitsProp.Prefix;
    if LDimStyle.AltUnitsProp.Suffix <> '' then LStr := LStr + '<>' + LDimStyle.AltUnitsProp.Suffix;

    Self.AddRecord(4, LStr); // DIMAPOST

    //R12 --->>>
    Self.AddRecord(5, '');  //DIMBLK （已废弃，现在为对象 ID）
    Self.AddRecord(6, '');  //DIMBLK1（已废弃，现在为对象 ID）
    Self.AddRecord(7, '');  //DIMBLK2（已废弃，现在为对象 ID）
    //----<<<

    Self.AddRecord(40, LDimStyle.OverallScale);                //DIMSCALE
    Self.AddRecord(41, LDimStyle.ArrowsProp.ArrowSize);        // DIMASZ
    Self.AddRecord(42, LDimStyle.LinesProp.ExtOriginOffset);   // DIMEXO
    Self.AddRecord(43, LDimStyle.LinesProp.BaselineSpacing);   // DIMDLI
    Self.AddRecord(44, LDimStyle.LinesProp.ExtBeyondDimLines); // DIMEXE
    Self.AddRecord(45, LDimStyle.UnitsProp.RoundOff);          // DIMRND
    Self.AddRecord(46, 0);                                 // DIMDLE  尺寸线超出尺寸界线的距离
    Self.AddRecord(47, 0);                                 // DIMTP   上偏差
    Self.AddRecord(48, 0);                                 // DIMTM   下偏差

    Self.AddRecord(140, LDimStyle.TextProp.TextHeight);        // DIMTXT
    Self.AddRecord(141, LDimStyle.ArrowsProp.MarkSize);        // DIMCEN
    Self.AddRecord(142, 0);                                // DIMTSZ  替代箭头的小斜线尺寸
    Self.AddRecord(143, LDimStyle.AltUnitsProp.AltMult);       // DIMALTF
    Self.AddRecord(144, LDimStyle.UnitsProp.Scale);            // DIMLFAC
    Self.AddRecord(145, 0);                                // DIMTVP  标注文字的垂直位置
    Self.AddRecord(146, '1.0');                                // DIMTFAC 公差对象的文字高度

    LFloat := LDimStyle.TextProp.OffsetFromDimLine;
    if LDimStyle.TextProp.DrawFrame then LFloat := -LFloat;
    Self.AddRecord(147, LFloat);                               // DIMGAP


    Self.AddRecord(71, '0');  // DIMTOL  公差的标注方式 OFF
    Self.AddRecord(72, '0');  // DIMLIM  生成极限尺寸  OFF
    if LDimStyle.TextProp.InsideAlign  then Self.AddRecord(73, '0') else Self.AddRecord(73, '1'); //DIMTIH
    if LDimStyle.TextProp.OutsideAlign then Self.AddRecord(74, '0') else Self.AddRecord(74, '1'); //DIMTOH

    if LDimStyle.LinesProp.ExtSuppressLine1 then Self.AddRecord(75, '1') else Self.AddRecord(75, '0'); //DIMSE1
    if LDimStyle.LinesProp.ExtSuppressLine2 then Self.AddRecord(76, '1') else Self.AddRecord(76, '0'); //DIMSE2

    Self.AddRecord(77, IntToStr(Ord(LDimStyle.TextProp.VerticalPosition)) );   //DIMTAD

    if LDimStyle.UnitsProp.SuppressLeading and LDimStyle.UnitsProp.SuppressTrailing then LStr := '12' else
    if LDimStyle.UnitsProp.SuppressTrailing  then LStr := '8' else
    if LDimStyle.UnitsProp.SuppressLeading   then LStr := '4' else LStr := '0';

    Self.AddRecord(78, LStr);   //DIMZIN   控制消零处理


    if LDimStyle.DispAltUnits then Self.AddRecord(170, '1') else Self.AddRecord(170, '0');  //DIMALT
    Self.AddRecord(171, IntToStr(LDimStyle.AltUnitsProp.Precision));  // DIMALTD 换算单位小数位
    Self.AddRecord(172, '0');  // DIMTOFL 强制尺寸线置于尺寸界线之间 OFF
    Self.AddRecord(173, '0');  // DIMSAH  分离箭头块 OFF
    if LDimStyle.BestFit then Self.AddRecord(174, '1') else Self.AddRecord(174, '0');  // DIMTIX
    Self.AddRecord(175, '0');  // DIMSOXD  隐藏尺寸界线之外的尺寸线 OFF

    Self.AddRecord(176, DxfFixColor(LDimStyle.LinesProp.Color));     // DIMCLRD
    Self.AddRecord(177, DxfFixColor(LDimStyle.LinesProp.ExtColor));  // DIMCLRE
    Self.AddRecord(178, DxfFixColor(LDimStyle.TextProp.TextColor));  // DIMCLRT
  end;


  Self.AddRecord(0, 'ENDTAB');
end;

{$ENDIF}


//--------------------------------------------------------------------------------------------------


procedure TUdDxfWriteTables.AddVPort();
var
  LHandle: string;
  LModel: TUdLayout;
  LBound: TRect2D;
  LCenter: TPoint2D;
begin
  LModel := Self.Document.ModelSpace;
  LBound := LModel.ViewBound;
  LCenter.X := (LBound.X1 + LBound.X2) / 2;
  LCenter.Y := (LBound.Y1 + LBound.Y2) / 2;


  LHandle := Self.NewHandle();

  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'VPORT');
  Self.AddRecord(5, LHandle);
  Self.AddRecord(330, '0');
  Self.AddRecord(100, 'AcDbSymbolTable');
  Self.AddRecord(70, '2');
  Self.AddRecord(0, 'VPORT');
  Self.AddRecord(5, Self.NewHandle());
  Self.AddRecord(330, LHandle);
  Self.AddRecord(100, 'AcDbSymbolTableRecord');
  Self.AddRecord(100, 'AcDbViewportTableRecord');
  Self.AddRecord(2, '*Active');
  Self.AddRecord(70, '0');
  Self.AddRecord(10, '0');
  Self.AddRecord(20, '0');
  Self.AddRecord(11, '1');
  Self.AddRecord(21, '1');
  Self.AddRecord(12, LCenter.X);
  Self.AddRecord(22, LCenter.Y);
  Self.AddRecord(13, Self.Document.ActiveLayout.Drafting.SnapGrid.Base.X);
  Self.AddRecord(23, Self.Document.ActiveLayout.Drafting.SnapGrid.Base.Y);
  Self.AddRecord(14, Self.Document.ActiveLayout.Drafting.SnapGrid.SnapSpace.X);
  Self.AddRecord(24, Self.Document.ActiveLayout.Drafting.SnapGrid.SnapSpace.Y);
  Self.AddRecord(15, Self.Document.ActiveLayout.Drafting.SnapGrid.GridSpace.X);
  Self.AddRecord(25, Self.Document.ActiveLayout.Drafting.SnapGrid.GridSpace.Y);
  Self.AddRecord(16, '0');
  Self.AddRecord(26, '0');
  Self.AddRecord(36, '1');
  Self.AddRecord(17, '0');
  Self.AddRecord(27, '0');
  Self.AddRecord(37, '0');
  Self.AddRecord(40, Abs(LBound.Y2 - LBound.Y1));
  if Abs(LBound.Y2 - LBound.Y1) > 0 then
    Self.AddRecord(41, Abs(LBound.X2 - LBound.X1)/Abs(LBound.Y2 - LBound.Y1) )
  else
    Self.AddRecord(41, '1.0');
  Self.AddRecord(42, '50');
  Self.AddRecord(43, '0');
  Self.AddRecord(44, '0');
  Self.AddRecord(50, '0');
  Self.AddRecord(51, '0');
  Self.AddRecord(71, '0');
  Self.AddRecord(72, '1000');
  Self.AddRecord(73, '1');
  Self.AddRecord(74, '3');
  Self.AddRecord(75, '0');
  Self.AddRecord(76, '0');
  Self.AddRecord(77, '0');
  Self.AddRecord(78, '0');
  Self.AddRecord(281, '0');
  Self.AddRecord(65,  '1');
  Self.AddRecord(110, '0');
  Self.AddRecord(120, '0');
  Self.AddRecord(130, '0');
  Self.AddRecord(111, '1');
  Self.AddRecord(121, '0');
  Self.AddRecord(131, '0');
  Self.AddRecord(112, '0');
  Self.AddRecord(122, '1');
  Self.AddRecord(132, '0');
  Self.AddRecord(79,  '0');
  Self.AddRecord(146, '0');

  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddLineTypes();
var
  I, J: Integer;
  LHandle: string;
  LLnType: TUdLineType;
begin
  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'LTYPE');

  LHandle := Self.NewHandle();
  Self.AddRecord(5, LHandle);

  Self.AddRecord(330, '0');
  Self.AddRecord(100, 'AcDbSymbolTable');
  Self.AddRecord(70, IntToStr(Self.Document.LineTypes.Count) );

  for I := 0 to Self.Document.LineTypes.Count - 1 do
  begin
    LLnType := Self.Document.LineTypes.Items[I];
    if not Assigned(LLnType) then Continue;  //or (Length(LLnType.Value) <= 0)


    Self.AddRecord(0, 'LTYPE');
    Self.AddRecord(5, IntToHex(LLnType.ID, 0));
    Self.AddRecord(330, LHandle);
    Self.AddRecord(100, 'AcDbSymbolTableRecord');
    Self.AddRecord(100, 'AcDbLinetypeTableRecord');
    Self.AddRecord(2, LLnType.Name);
    Self.AddRecord(3, LLnType.Comment);

//    if Pos('|', LLnType.Name) > 0 then Self.AddRecord(70, '16') else Self.AddRecord(70, '0');
    Self.AddRecord(70, '0');

    Self.AddRecord(72, '65');
    Self.AddRecord(73, IntToStr(Length(LLnType.Value)) );
    Self.AddRecord(40, LLnType.SegmentLength() );

    for J := 0 to Length(LLnType.Value) - 1 do
    begin
      Self.AddRecord(49, LLnType.Value[J]);
      Self.AddRecord(74, '0');
    end;
  end;

  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddLayers();
var
  I: Integer;
  LFlag: Cardinal;
  LLayer: TUdLayer;
  LHandle: string;
begin
  Self.PlotHandle := Self.NewHandle();

  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'LAYER');

  LHandle := Self.NewHandle();
  Self.AddRecord(5, LHandle);

  Self.AddRecord(330, '0');
  Self.AddRecord(100, 'AcDbSymbolTable');
  Self.AddRecord(70, IntToStr(Self.Document.Layers.Count));

  for I := 0 to Self.Document.Layers.Count - 1 do
  begin
    LLayer := Self.Document.Layers.Items[I];
    if not Assigned(LLayer) then Continue;

    Self.AddRecord(0, 'LAYER');
    Self.AddRecord(5, IntToHex(LLayer.ID, 0));
    Self.AddRecord(330, LHandle);
    Self.AddRecord(100, 'AcDbSymbolTableRecord');
    Self.AddRecord(100, 'AcDbLayerTableRecord');


//  Self.AddRecord(2, StringToDXF(LLayer.Name));
    Self.AddRecord(2, LLayer.Name);

    LFlag := 0;
    if (LLayer.Freeze and (LLayer <> Self.Document.ActiveLayer)) then LFlag := 1;
    if (LLayer.Lock) then LFlag := LFlag or 4;

    if Pos('|', LLayer.Name) > 0 then
      Self.AddRecord(70, IntToStr(LFlag + 16))
    else
      Self.AddRecord(70, IntToStr(LFlag));

    if Assigned(LLayer.LineType) and (LLayer.LineType.Name <> '') then
      Self.AddRecord(6, LLayer.LineType.Name)
    else
      Self.AddRecord(6, 'Continuous');

    if LLayer.Visible then
      Self.AddRecord(62, IntToStr(LLayer.Color.IndexColor))
    else
      Self.AddRecord(62, IntToStr(-LLayer.Color.IndexColor));

    if (LLayer.Color.ColorType = ctTrueColor) and (Self.Version = dxf2004) then
      Self.AddRecord(420, IntToStr(LLayer.Color.TrueColor));

    Self.AddRecord(370, IntToStr(LLayer.LineWeight));

    if (UpperCase(LLayer.Name) = 'DEFPOINTS') then
      Self.AddRecord(290, '0');
//    else
//      Self.AddRecord(290, IntToStr(Integer(LLayer.Plot)) );


//    if (Self.Version = dxf2004) then
      Self.AddRecord(390, Self.PlotHandle);
  end;

  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddTextStyles();

  function _ExtractFileName(const AFileName: string): string;
  var
    N: Integer;
    LFileExt: string;
    LFileName: string;
  begin
    LFileName := SysUtils.ExtractFileName(AFileName);
    LFileExt  := SysUtils.ExtractFileExt(LFileName);
    N := Pos(LFileExt, LFileName);
    if N > 0 then Delete(LFileName, N, Length(LFileExt));

    Result := LFileName;
  end;

var
  I: Integer;
  LName: string;
  LFlag: Cardinal;
  LHandle: string;
  LTextStyle: TUdTextStyle;
begin
  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'STYLE');

  LHandle := Self.NewHandle();
  Self.AddRecord(5, LHandle);

  Self.AddRecord(330, '0');
  Self.AddRecord(100, 'AcDbSymbolTable');
  Self.AddRecord(70, IntToStr(Self.Document.TextStyles.Count));

  for I := 0 to Self.Document.TextStyles.Count - 1 do
  begin
    LTextStyle := Self.Document.TextStyles.Items[I];
    if not Assigned(LTextStyle) then Continue;

    Self.AddRecord(0, 'STYLE');
    Self.AddRecord(5, IntToHex(LTextStyle.ID, 0));
    Self.AddRecord(330, LHandle);
    Self.AddRecord(100, 'AcDbSymbolTableRecord');
    Self.AddRecord(100, 'AcDbTextStyleTableRecord');


    LName := LTextStyle.Name;

    if Pos('RECOVER', LTextStyle.Name) = 1 then
    begin
      Self.AddRecord(2, '');
      LName := '';
    end
    else begin
    //Self.AddRecord(2, Self.StringToDXF(LName));
      Self.AddRecord(2, LName);
    end;

    if Pos('|', LTextStyle.Name) = 1 then
    begin
      Self.AddRecord(70, '16');
    end
    else begin
      if (LName = '') then Self.AddRecord(70, '1') else Self.AddRecord(70, '0');
    end;

    Self.AddRecord(40, LTextStyle.Height);
    Self.AddRecord(41, LTextStyle.WidthFactor);
  //Self.AddRecord(50, LTextStyle.Extra.ObliquingAngle);
    Self.AddRecord(50, '0');

    LFlag := 0;
    if LTextStyle.Backward then LFlag := LFlag or 2;
    if LTextStyle.Upsidedown then LFlag := LFlag or 4;

    Self.AddRecord(71, IntToStr(LFlag));
//    Self.AddRecord(42, 2.5);


    if LTextStyle.FontKind = fkTTF then
    begin
      Self.AddRecord(3, LTextStyle.TTFFont.Font.Name);
      if (LName <> '') then
      begin
        Self.AddRecord(1001, 'ACAD');
        Self.AddRecord(1000, LTextStyle.TTFFont.Font.Name);
        LFlag := 0;
        if fsItalic in LTextStyle.TTFFont.Font.Style then LFlag := LFlag + $1000000;
        if fsBold   in LTextStyle.TTFFont.Font.Style then LFlag := LFlag + $2000000;
        Self.AddRecord(1071, IntToStr(LFlag));
      end;
    end
    else begin
      Self.AddRecord(3, _ExtractFileName(LTextStyle.ShxFont.ShxFile));
      Self.AddRecord(4, _ExtractFileName(LTextStyle.ShxFont.BigFile));
    end;

  end;
  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddViewUCS();
begin
  Self.AddRecord(0, 'TABLE');

  Self.AddRecord(2, 'VIEW');
  Self.AddRecord(5, Self.NewHandle());
  Self.AddRecord(330, '0');
  Self.AddRecord(100, 'AcDbSymbolTable');
  if Self.Document.ActiveLayout = Self.Document.ModelSpace then
    Self.AddRecord(70, '0')
  else
    Self.AddRecord(70, '1');
  Self.AddRecord(0, 'ENDTAB');

  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'UCS');
  Self.AddRecord(5, Self.NewHandle());
  Self.AddRecord(330, '0');
  Self.AddRecord(100, 'AcDbSymbolTable');
  Self.AddRecord(70, '0');

  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddAPPID();
var
  LHandle: string;
begin
  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'APPID');

  LHandle := Self.NewHandle();
  Self.AddRecord(5, LHandle);
  Self.AddRecord(330, '0');
  Self.AddRecord(100, 'AcDbSymbolTable');

  Self.AddRecord(70, '2');

  Self.AddRecord(0, 'APPID');
  Self.AddRecord(5, Self.NewHandle());
  Self.AddRecord(330, LHandle);
  Self.AddRecord(100, 'AcDbSymbolTableRecord');
  Self.AddRecord(100, 'AcDbRegAppTableRecord');
  Self.AddRecord(2, 'ACAD');
  Self.AddRecord(70, '0');

  Self.AddRecord(0, 'APPID');
  Self.AddRecord(5, Self.NewHandle());
  Self.AddRecord(330, LHandle);
  Self.AddRecord(100, 'AcDbSymbolTableRecord');
  Self.AddRecord(100, 'AcDbRegAppTableRecord');
  Self.AddRecord(2, 'ACAD_PSEXT');
  Self.AddRecord(70, '0');

  Self.AddRecord(0, 'ENDTAB');
end;


procedure TUdDxfWriteTables.AddDimStyles();
var
  I, N: Integer;
  LStr: string;
  LFloat: Double;
  LHandle: string;
  LDimStyle: TUdDimStyle;
begin
  LHandle := Self.NewHandle();

  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'DIMSTYLE');
  Self.AddRecord(5, LHandle);
  Self.AddRecord(330, '0');

  Self.AddRecord(100, 'AcDbSymbolTable');
  Self.AddRecord(70, IntToStr(Self.Document.DimStyles.Count));

  Self.AddRecord(100, 'AcDbDimStyleTable');
  Self.AddRecord(71, IntToStr(Self.Document.DimStyles.Count));


  for I := 0 to Self.Document.DimStyles.Count - 1 do
  begin
    LDimStyle := Self.Document.DimStyles.Items[I];
    if Assigned(LDimStyle) then
      Self.AddRecord(340, IntToHex(LDimStyle.ID, 0));
  end;

  for I := 0 to Self.Document.DimStyles.Count - 1 do
  begin
    LDimStyle := Self.Document.DimStyles.Items[I];
    if not Assigned(LDimStyle) then Continue;

    Self.AddRecord(0, 'DIMSTYLE');
    Self.AddRecord(105, IntToHex(LDimStyle.ID, 0));
    Self.AddRecord(330, LHandle);

    Self.AddRecord(100, 'AcDbSymbolTableRecord');
    Self.AddRecord(100, 'AcDbDimStyleTableRecord');

    Self.AddRecord(2, LDimStyle.Name );
    if Pos('|', LDimStyle.Name) > 0 then Self.AddRecord(70, '16') else Self.AddRecord(70, '0');


    LStr := '';
    if LDimStyle.AltUnitsProp.AltPlacement = apBelowPrimary then LStr := '\X';

    LStr := LStr + LDimStyle.UnitsProp.Prefix;
    if LDimStyle.UnitsProp.Suffix <> '' then LStr := LStr + '<>' + LDimStyle.UnitsProp.Suffix;

    Self.AddRecord(3, LStr); // DIMPOST


    LStr := LDimStyle.AltUnitsProp.Prefix;
    if LDimStyle.AltUnitsProp.Suffix <> '' then LStr := LStr + '<>' + LDimStyle.AltUnitsProp.Suffix;

    Self.AddRecord(4, LStr); // DIMAPOST

    //R12 --->>>
    Self.AddRecord(5, '');  //DIMBLK （已废弃，现在为对象 ID）
    Self.AddRecord(6, '');  //DIMBLK1（已废弃，现在为对象 ID）
    Self.AddRecord(7, '');  //DIMBLK2（已废弃，现在为对象 ID）
    //----<<<

    Self.AddRecord(40, LDimStyle.OverallScale);                //DIMSCALE
    Self.AddRecord(41, LDimStyle.ArrowsProp.ArrowSize);        // DIMASZ
    Self.AddRecord(42, LDimStyle.LinesProp.ExtOriginOffset);   // DIMEXO
    Self.AddRecord(43, LDimStyle.LinesProp.BaselineSpacing);   // DIMDLI
    Self.AddRecord(44, LDimStyle.LinesProp.ExtBeyondDimLines); // DIMEXE
    Self.AddRecord(45, LDimStyle.UnitsProp.RoundOff);          // DIMRND
    Self.AddRecord(46, 0);                                 // DIMDLE  尺寸线超出尺寸界线的距离
    Self.AddRecord(47, 0);                                 // DIMTP   上偏差
    Self.AddRecord(48, 0);                                 // DIMTM   下偏差

    Self.AddRecord(140, LDimStyle.TextProp.TextHeight);        // DIMTXT
    Self.AddRecord(141, LDimStyle.ArrowsProp.MarkSize);        // DIMCEN
    Self.AddRecord(142, 0);                                // DIMTSZ  替代箭头的小斜线尺寸
    Self.AddRecord(143, LDimStyle.AltUnitsProp.MeasurementScale);     // DIMALTF
    Self.AddRecord(144, LDimStyle.UnitsProp.MeasurementScale);        // DIMLFAC
    Self.AddRecord(145, 0);                                // DIMTVP  标注文字的垂直位置
    Self.AddRecord(146, '1.0');                                // DIMTFAC 公差对象的文字高度

    LFloat := LDimStyle.TextProp.OffsetFromDimLine;
    if LDimStyle.TextProp.DrawFrame then LFloat := -LFloat;
    Self.AddRecord(147, LFloat);                               // DIMGAP


    Self.AddRecord(71, '0');  // DIMTOL  公差的标注方式 OFF
    Self.AddRecord(72, '0');  // DIMLIM  生成极限尺寸  OFF
    if LDimStyle.TextProp.InsideAlign  then Self.AddRecord(73, '0') else Self.AddRecord(73, '1'); //DIMTIH
    if LDimStyle.TextProp.OutsideAlign then Self.AddRecord(74, '0') else Self.AddRecord(74, '1'); //DIMTOH

    if LDimStyle.LinesProp.ExtSuppressLine1 then Self.AddRecord(75, '1') else Self.AddRecord(75, '0'); //DIMSE1
    if LDimStyle.LinesProp.ExtSuppressLine2 then Self.AddRecord(76, '1') else Self.AddRecord(76, '0'); //DIMSE2

    Self.AddRecord(77, IntToStr(Ord(LDimStyle.TextProp.VerticalPosition)) );   //DIMTAD

    if LDimStyle.UnitsProp.SuppressLeading and LDimStyle.UnitsProp.SuppressTrailing then LStr := '12' else
    if LDimStyle.UnitsProp.SuppressTrailing  then LStr := '8' else
    if LDimStyle.UnitsProp.SuppressLeading   then LStr := '4' else LStr := '0';

    Self.AddRecord(78, LStr);   //DIMZIN   控制消零处理


    if LDimStyle.DispAltUnits then Self.AddRecord(170, '1') else Self.AddRecord(170, '0');  //DIMALT
    Self.AddRecord(171, IntToStr(LDimStyle.AltUnitsProp.Precision));  // DIMALTD 换算单位小数位
    Self.AddRecord(172, '0');  // DIMTOFL 强制尺寸线置于尺寸界线之间 OFF
    Self.AddRecord(173, '0');  // DIMSAH  分离箭头块 OFF
    if LDimStyle.BestFit then Self.AddRecord(174, '0') else Self.AddRecord(174, '1');  // DIMTIX
    Self.AddRecord(175, '0');  // DIMSOXD  隐藏尺寸界线之外的尺寸线 OFF

    Self.AddRecord(176, DxfFixColor(LDimStyle.LinesProp.Color));     // DIMCLRD
    Self.AddRecord(177, DxfFixColor(LDimStyle.LinesProp.ExtColor));  // DIMCLRE
    Self.AddRecord(178, DxfFixColor(LDimStyle.TextProp.TextColor));  // DIMCLRT


    //----------------------
    Self.AddRecord(79, '0');                  // DIMAZIN  控制角度标注的消零处理
    Self.AddRecord(148, 0);               // DIMALTRND 舍入换算标注单位

    Self.AddRecord(179, IntToStr(LDimStyle.UnitsProp.AngPrecision));  // DIMADEC
    Self.AddRecord(271, IntToStr(LDimStyle.UnitsProp.Precision));     // DIMDEC
    Self.AddRecord(272, IntToStr(2));                                 // DIMTDEC Total Precision

    Self.AddRecord(273, IntToStr(Ord(LDimStyle.AltUnitsProp.UnitFormat) + 1)); // DIMALTU
    Self.AddRecord(274, '3');                                                  // DIMALTTD   设置标注换算单位公差值小数位的位数
    Self.AddRecord(275, IntToStr(Ord(LDimStyle.UnitsProp.AngUnitFormat)));     // DIMAUNIT
    Self.AddRecord(276, '0');                                                  // DIMFRAC  分数格式

    Self.AddRecord(277, IntToStr(Ord(LDimStyle.UnitsProp.UnitFormat) + 1));   // DIMLUNIT  线性单位的格式
    Self.AddRecord(278, Ord(LDimStyle.UnitsProp.Decimal));                    // DIMDSEP  小数分隔符
    Self.AddRecord(279, '0');                                                 // DIMTMOVE 标注文字的移动规则

    N := Ord(LDimStyle.TextProp.HorizontalPosition);
    if N >= 3 then N := 0;
    Self.AddRecord(280, IntToStr(N));                                         // DIMJUST 控制尺寸线上标注文字的水平对齐

    if LDimStyle.LinesProp.SuppressLine1 then Self.AddRecord(281, '1') else Self.AddRecord(281, '0'); //DIMSD1
    if LDimStyle.LinesProp.SuppressLine2 then Self.AddRecord(282, '1') else Self.AddRecord(282, '0'); //DIMSD2

    Self.AddRecord(283, '0');      // DIMTOLJ  公差的垂直对正方式
    Self.AddRecord(284, '8');      // DIMTZIN  控制公差的消零处理
    Self.AddRecord(285, '0');      // DIMALTZ  控制换算单位的消零处理
    Self.AddRecord(286, '0');      // DIMALTTZ 控制换算公差的消零处理

    Self.AddRecord(288, '0');      // DIMUPT   控制用户定位文字  OFF
    Self.AddRecord(289, '3');      // DIMATFIT 箭头及文字自适应调整


    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    {
    Self.AddRecord(340, '');      // DIMTXSTY 文字样式 (STYLE的句柄)
    Self.AddRecord(341, '');      // DIMLDRBLK 引线箭头块名称 (BLOCK的句柄)
    }
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    LStr := GetDimArrowName(LDimStyle.ArrowsProp.ArrowLeader);
    if LStr <> '' then
    begin
      LStr := '_' + LStr;
      LStr := Self.BlockHandles.GetValue(LStr);
      if LStr <> '' then Self.AddRecord(342, '');      // DIMBLK  箭头块名称       (BLOCK的句柄)
    end;

    LStr := GetDimArrowName(LDimStyle.ArrowsProp.ArrowFirst);
    if LStr <> '' then
    begin
      LStr := '_' + LStr;
      LStr := Self.BlockHandles.GetValue(LStr);
      if LStr <> '' then Self.AddRecord(343, '');     //  DIMBLK1 第一箭头块名称   (BLOCK的句柄)
    end;

    LStr := GetDimArrowName(LDimStyle.ArrowsProp.ArrowSecond);
    if LStr <> '' then
    begin
      LStr := '_' + LStr;
      LStr := Self.BlockHandles.GetValue(LStr);
      if LStr <> '' then Self.AddRecord(344, '');     // DIMBLK2 第二箭头块名称   (BLOCK的句柄)
    end;

    Self.AddRecord(371, IntToStr(LDimStyle.LinesProp.LineWeight));      //DIMLWD  尺寸线和引线线宽
    Self.AddRecord(372, IntToStr(LDimStyle.LinesProp.ExtLineWeight));   //DIMLWE  尺寸界线线宽
  end;


  Self.AddRecord(0, 'ENDTAB');
end;

procedure TUdDxfWriteTables.AddBlockRecords();
var
  I, J, N: Integer;
  LCount: Integer;
  LBlock: TUdBlock;
  LEntity: TUdEntity;
  LLayout: TUdLayout;
  LOwnHandle, LName, LHandle: string;
begin
{$IFDEF DXF12}
  if Self.Version = dxf12 then Exit;
{$ENDIF}

  Self.AddRecord(0, 'TABLE');
  Self.AddRecord(2, 'BLOCK_RECORD');

  LOwnHandle := Self.NewHandle();
  Self.AddRecord(5, LOwnHandle);

  Self.AddRecord(330, '0');
  Self.AddRecord(100, 'AcDbSymbolTable');

  LCount := Self.Document.Blocks.Count + Self.Document.Layouts.Count;
  Self.AddRecord(70, IntToStr(LCount));



  Self.GeneralHandle := Self.NewHandle();

  Self.AddRecord(0, 'BLOCK_RECORD');
  Self.AddRecord(5, Self.GeneralHandle);
  Self.AddRecord(330, LOwnHandle);
  Self.AddRecord(100, 'AcDbSymbolTableRecord');
  Self.AddRecord(100, 'AcDbBlockTableRecord');
  Self.AddRecord(2, '*Model_Space');
  Self.AddRecord(340, IntToHex(Self.Document.ModelSpace.ID, 0) );

  Self.BlockHandles.Add('*Model_Space', Self.GeneralHandle);


  N := -1;
  for I := 1 to Self.Document.Layouts.Count - 1 do
  begin
    LLayout := Self.Document.Layouts.Items[I];
    if not Assigned(LLayout) then Continue;

    Self.AddRecord(0, 'BLOCK_RECORD');

    LHandle := Self.NewHandle();
    Self.AddRecord(5, LHandle);
    Self.AddRecord(330, LOwnHandle);

    Self.AddRecord(100, 'AcDbSymbolTableRecord');
    Self.AddRecord(100, 'AcDbBlockTableRecord');

    if (N >= 0) then
      LName := '*Paper_Space' + IntToStr(N)
    else
      LName := '*Paper_Space';

    Self.AddRecord(2, LName);
    Self.AddRecord(340, IntToHex(LLayout.ID, 2) );

    Self.BlockHandles.Add(LName, LHandle);

    Inc(N);
  end;


  for I := 0 to Self.Document.Blocks.Count - 1 do
  begin
    LBlock := Self.Document.Blocks.Items[I];
    if not Assigned(LBlock) then Continue;
    
    LName := UpperCase(LBlock.Name);
    if (Pos('*D', LName) = 1) then Continue;  //or (Pos('*X', LName) = 1) 

    Self.AddRecord(0, 'BLOCK_RECORD');
    LHandle := Self.NewHandle();

    Self.AddRecord(5, LHandle);
    Self.AddRecord(330, LOwnHandle);
    Self.AddRecord(100, 'AcDbSymbolTableRecord');
    Self.AddRecord(100, 'AcDbBlockTableRecord');
    Self.AddRecord(2, LBlock.Name);
    Self.AddRecord(340, '0');

    Self.BlockHandles.Add(LBlock.Name, LHandle);
  end;

  N := 0;
  for I := 0 to Self.Document.Layouts.Count - 1 do
  begin
    LLayout := Self.Document.Layouts.Items[I];
    for J := 0 to LLayout.Entities.Count - 1 do
    begin
      LEntity := LLayout.Entities.Items[J];
      if not Assigned(LEntity) or not LEntity.InheritsFrom(TUdDimension) then Continue;

      Inc(N);
      TUdDimension(LEntity).BlockName := '*D' + IntToStr(N);

      //------------------------
      Self.AddRecord(0, 'BLOCK_RECORD');
      LHandle := Self.NewHandle();

      Self.AddRecord(5, LHandle);
      Self.AddRecord(330, LOwnHandle);
      Self.AddRecord(100, 'AcDbSymbolTableRecord');
      Self.AddRecord(100, 'AcDbBlockTableRecord');
      Self.AddRecord(2, TUdDimension(LEntity).BlockName);
      Self.AddRecord(340, '0');

      Self.BlockHandles.Add(TUdDimension(LEntity).BlockName, LHandle);
    end;
  end;


  Self.AddRecord(0, 'ENDTAB');
end;



procedure TUdDxfWriteTables.Execute();
begin
  Self.PlotHandle := '';
  Self.BlockHandles.Clear();

  Self.AddRecord(0, 'SECTION');
  Self.AddRecord(2, 'TABLES');

{$IFDEF DXF12}
  if (Self.Version = dxf12) then
  begin
    Self.AddVPort12();
    Self.AddLinetypes12();
    Self.AddLayers12();
    Self.AddTextStyles12();
    Self.AddViewUCS12();
    Self.AddAPPID12();
    Self.AddDimStyles12();
  end
  else
{$ENDIF}
  begin
    Self.AddVPort();
    Self.AddLineTypes();
    Self.AddLayers();
    Self.AddTextStyles();
    Self.AddViewUCS();
    Self.AddAPPID();
    Self.AddBlockRecords();
    Self.AddDimStyles();
  end;

  Self.AddRecord(0, 'ENDSEC');
end;

end.