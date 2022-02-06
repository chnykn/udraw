{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfWriteHeader;

{$I UdDefs.INC}

interface

uses
  UdTypes, UdDxfTypes, UdDxfWriteSection;

type

  TUdDxfWriteHeader = class(TUdDxfWriteSection)
  private
    FSeedLinePos: Integer;
  public
    procedure Execute(); override;

    property SeedLinePos: Integer read FSeedLinePos;
  end;

implementation

uses
  SysUtils, StrUtils,
  UdMath, UdUtils, UdLayout, UdDimProps;



//==================================================================================================

procedure TUdDxfWriteHeader.Execute();
var
  LStr: string;
  LRect: TRect2D;
  LFloat: Float;
  LLayout: TUdLayout;
  LHandSeedBlank: string;
begin
  FSeedLinePos := -1;
  
  Self.AddRecord(0, 'SECTION');
  Self.AddRecord(2, 'HEADER');

  AddRecord(9, '$ACADVER');
  case Self.Version of
  {$IFDEF DXF12}
    dxf12  : Self.AddRecord(1, 'AC1009');
  {$ENDIF}
    dxf2000: Self.AddRecord(1, 'AC1015');
    dxf2004: Self.AddRecord(1, 'AC1018');
  end;
  Self.AddRecord(9, '$ACADMAINTVER');
  Self.AddRecord(70, '0');

	Self.AddRecord(9, '$DWGCODEPAGE');
	Self.AddRecord(3, 'ANSI_936');

  {
  for I := 0 to Self.Document.FileProperties.Count - 1 do
  begin
    Self.AddRecord(9, '$CUSTOMPROPERTYTAG');
    Self.AddRecord(1, Self.Document.FileProperties.Names[I]);
    Self.AddRecord(9, '$CUSTOMPROPERTY');
    Self.AddRecord(1, Self.Document.FileProperties.ValueFromIndex[I]);
  end;
  }

  Self.AddRecord(9, '$INSBASE');
  Self.AddRecord(10, 0 {Self.Document.BasePoint.X} );
  Self.AddRecord(20, 0 {Self.Document.BasePoint.Y} );
  Self.AddRecord(30, 0 {Self.Document.BasePoint.Z} );


  LRect := Self.Document.ModelSpace.Entities.BoundsRect;

  Self.AddRecord(9, '$EXTMIN');
  Self.AddRecord(10, LRect.X1);
  Self.AddRecord(20, LRect.Y1);
  Self.AddRecord(30, '0');

  Self.AddRecord(9, '$EXTMAX');
  Self.AddRecord(10, LRect.X2);
  Self.AddRecord(20, LRect.Y2);
  Self.AddRecord(30, 0);


  Self.AddRecord(9, '$LIMMIN');
  Self.AddRecord(10, Self.Document.ModelSpace.Axes.LimRect.X1);
  Self.AddRecord(20, Self.Document.ModelSpace.Axes.LimRect.Y1);

  Self.AddRecord(9, '$LIMMAX');
  Self.AddRecord(10, Self.Document.ModelSpace.Axes.LimRect.X2);
  Self.AddRecord(20, Self.Document.ModelSpace.Axes.LimRect.Y2);

  Self.AddRecord(9, '$ORTHOMODE');
  Self.AddRecord(70, DxfBoolToStr(Self.Document.ModelSpace.OrthoOn) );

  Self.AddRecord(9, '$REGENMODE');
  Self.AddRecord(70, '1');
  Self.AddRecord(9, '$FILLMODE');
  Self.AddRecord(70, '1');

  Self.AddRecord(9, '$QTEXTMODE');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$MIRRTEXT');
  Self.AddRecord(70, '1');
  Self.AddRecord(9, '$LTSCALE');
  Self.AddRecord(40, Self.Document.LineTypes.GlobalScale);

  Self.AddRecord(9, '$ATTMODE');
  Self.AddRecord(70, '1');
  Self.AddRecord(9, '$TEXTSIZE');
  Self.AddRecord(40, 2.5);
  Self.AddRecord(9, '$TRACEWID');
  Self.AddRecord(40, 1.0);

  Self.AddRecord(9, '$TEXTSTYLE');
  Self.AddRecord(7, Self.Document.TextStyles.Active.Name);
  Self.AddRecord(9, '$CLAYER');
  Self.AddRecord(8, Self.Document.Layers.Active.Name);
  Self.AddRecord(9, '$CELTYPE');
  Self.AddRecord(6, Self.Document.LineTypes.Active.Name);
  Self.AddRecord(9, '$CECOLOR');
  Self.AddRecord(62, DxfFixColor(Self.Document.Colors.Active));
  Self.AddRecord(9, '$CELTSCALE');
  Self.AddRecord(40, Self.Document.LineTypes.CurrentScale);
  Self.AddRecord(9, '$DISPSILH');
  Self.AddRecord(70, '0');



  //----------------------------------------------------------------------

  Self.AddRecord(9, '$DIMSCALE');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.OverallScale);
  Self.AddRecord(9, '$DIMASZ');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.ArrowsProp.ArrowSize);
  Self.AddRecord(9, '$DIMEXO');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.LinesProp.ExtOriginOffset);
  Self.AddRecord(9, '$DIMDLI');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.LinesProp.BaselineSpacing);  
  Self.AddRecord(9, '$DIMRND');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.UnitsProp.RoundOff);
  Self.AddRecord(9, '$DIMDLE');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$DIMEXE');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.LinesProp.ExtBeyondDimLines);
  Self.AddRecord(9, '$DIMTP'); //上偏差
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$DIMTM'); //下偏差
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$DIMTXT');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.TextProp.TextHeight);
  Self.AddRecord(9, '$DIMCEN');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.ArrowsProp.MarkSize);
  Self.AddRecord(9, '$DIMTSZ');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$DIMTOL');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMLIM'); //非零时生成的标注界限
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMTIH');
  if Self.Document.ActiveDimStyle.TextProp.InsideAlign then Self.AddRecord(70, '0') else Self.AddRecord(70, '1');
  Self.AddRecord(9, '$DIMTOH');
  if Self.Document.ActiveDimStyle.TextProp.OutsideAlign then Self.AddRecord(70, '0') else Self.AddRecord(70, '1');
  Self.AddRecord(9, '$DIMSE1');
  if Self.Document.ActiveDimStyle.LinesProp.ExtSuppressLine1 then Self.AddRecord(70, '1') else Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMSE2');
  if Self.Document.ActiveDimStyle.LinesProp.ExtSuppressLine2 then Self.AddRecord(70, '1') else Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMTAD');
  Self.AddRecord(70, IntToStr(Ord(Self.Document.ActiveDimStyle.TextProp.VerticalPosition)));

  Self.AddRecord(9, '$DIMZIN');
  with Self.Document.ActiveDimStyle.UnitsProp do
  begin
    if SuppressLeading and SuppressTrailing then LStr := '12' else
    if SuppressTrailing  then LStr := '8' else
    if SuppressLeading   then LStr := '4' else LStr := '0';
  end;
  Self.AddRecord(70, LStr);


  Self.AddRecord(9, '$DIMBLK');
  Self.AddRecord(1, GetDimArrowName(Self.Document.ActiveDimStyle.ArrowsProp.ArrowLeader));

  Self.AddRecord(9, '$DIMASO');
  Self.AddRecord(70, '1');
  Self.AddRecord(9, '$DIMSHO');
  Self.AddRecord(70, '1');

  Self.AddRecord(9, '$DIMPOST');
  LStr := Self.Document.ActiveDimStyle.UnitsProp.Prefix;
  if Self.Document.ActiveDimStyle.UnitsProp.Suffix <> '' then LStr := LStr + '<>' + Self.Document.ActiveDimStyle.UnitsProp.Suffix;
  Self.AddRecord(1, LStr);

  Self.AddRecord(9, '$DIMAPOST');
  LStr := Self.Document.ActiveDimStyle.AltUnitsProp.Prefix;
  if Self.Document.ActiveDimStyle.AltUnitsProp.Suffix <> '' then LStr := LStr + '<>' + Self.Document.ActiveDimStyle.AltUnitsProp.Suffix;
  Self.AddRecord(1, LStr);


  Self.AddRecord(9, '$DIMALT');
  if Self.Document.ActiveDimStyle.DispAltUnits then Self.AddRecord(70, '1') else Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMALTD');
  Self.AddRecord(70, IntToStr(Self.Document.ActiveDimStyle.AltUnitsProp.Precision));
  Self.AddRecord(9, '$DIMALTF');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.AltUnitsProp.MeasurementScale);
  Self.AddRecord(9, '$DIMLFAC');
  Self.AddRecord(40, Self.Document.ActiveDimStyle.UnitsProp.MeasurementScale);

  Self.AddRecord(9, '$DIMTOFL'); //如果文字放在尺寸界线的外侧，非零时则强制在尺寸界线之间画直线
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMTVP');
  Self.AddRecord(40, 0);


  Self.AddRecord(9, '$DIMTIX');
  if Self.Document.ActiveDimStyle.BestFit then Self.AddRecord(70, '0') else Self.AddRecord(70, '1');
  Self.AddRecord(9, '$DIMSOXD');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMSAH');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMBLK1');
  Self.AddRecord(1, GetDimArrowName(Self.Document.ActiveDimStyle.ArrowsProp.ArrowFirst));
  Self.AddRecord(9, '$DIMBLK2');
  Self.AddRecord(1, GetDimArrowName(Self.Document.ActiveDimStyle.ArrowsProp.ArrowSecond));
  Self.AddRecord(9, '$DIMSTYLE');
  Self.AddRecord(2, Self.Document.ActiveDimStyle.Name);
  Self.AddRecord(9, '$DIMCLRD');
  Self.AddRecord(70, DxfFixColor(Self.Document.ActiveDimStyle.LinesProp.Color) );
  Self.AddRecord(9, '$DIMCLRE');
  Self.AddRecord(70, DxfFixColor(Self.Document.ActiveDimStyle.LinesProp.ExtColor) );
  Self.AddRecord(9, '$DIMCLRT');
  Self.AddRecord(70, DxfFixColor(Self.Document.ActiveDimStyle.TextProp.TextColor) );
  Self.AddRecord(9, '$DIMTFAC');
  Self.AddRecord(40, '1.0');
  Self.AddRecord(9, '$DIMGAP');
  LFloat := Self.Document.ActiveDimStyle.TextProp.OffsetFromDimLine;
  if Self.Document.ActiveDimStyle.TextProp.DrawFrame then LFloat := -LFloat;
  Self.AddRecord(40, LFloat);

  Self.AddRecord(9, '$DIMJUST');
  Self.AddRecord(70, IntToStr(Ord(Self.Document.ActiveDimStyle.TextProp.HorizontalPosition) ) );
  Self.AddRecord(9, '$DIMSD1');
  if Self.Document.ActiveDimStyle.LinesProp.SuppressLine1 then Self.AddRecord(70, '1') else Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMSD2');
  if Self.Document.ActiveDimStyle.LinesProp.SuppressLine2 then Self.AddRecord(70, '1') else Self.AddRecord(70, '0');

  Self.AddRecord(9, '$DIMTOLJ');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMTZIN');
  Self.AddRecord(70, '8');
  Self.AddRecord(9, '$DIMALTZ');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMALTTZ');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$DIMUPT');
  Self.AddRecord(70, '0');

  Self.AddRecord(9, '$DIMDEC');
  Self.AddRecord(70, IntToStr(Self.Document.ActiveDimStyle.UnitsProp.Precision));  
  Self.AddRecord(9, '$DIMTDEC');
  Self.AddRecord(70, IntToStr(Self.Document.ActiveDimStyle.UnitsProp.Precision));
  Self.AddRecord(9, '$DIMALTU');
  Self.AddRecord(70, IntToStr(Ord(Self.Document.ActiveDimStyle.AltUnitsProp.UnitFormat) + 1));
  Self.AddRecord(9, '$DIMALTTD');
  Self.AddRecord(70, '3');
    
  Self.AddRecord(9, '$DIMTXSTY');
  Self.AddRecord(7, 'STANDARD');

  Self.AddRecord(9, '$DIMAUNIT');
  Self.AddRecord(70, IntToStr(Ord(Self.Document.ActiveDimStyle.UnitsProp.AngUnitFormat)));
  Self.AddRecord(9, '$DIMADEC');
  Self.AddRecord(70, IntToStr(Self.Document.ActiveDimStyle.UnitsProp.AngPrecision));
  Self.AddRecord(9, '$DIMALTRND'); // 确定换算单位的舍入值
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$DIMAZIN');
  Self.AddRecord(70, '0');

//  Self.AddRecord(9, '$DIMDSEP');
//  Self.AddRecord(70, IntToStr(Ord(Self.Document.ActiveDimStyle.UnitsProp.Decimal)) );

  Self.AddRecord(9, '$DIMATFIT');
  Self.AddRecord(70, '3' );
  Self.AddRecord(9, '$DIMFRAC');
  Self.AddRecord(70, '0' );
//  Self.AddRecord(9, '$DIMLDRBLK');
//  Self.AddRecord(1, '' );

  Self.AddRecord(9, '$DIMLUNIT');
  Self.AddRecord(70, IntToStr(Ord(Self.Document.ActiveDimStyle.UnitsProp.UnitFormat) + 1) );

  Self.AddRecord(9, '$DIMDSEP');
  Self.AddRecord(70, IntToStr(Ord(Self.Document.ActiveDimStyle.UnitsProp.Decimal)) );

  //----------------------------------------------------------------------

  Self.AddRecord(9, '$LUNITS');
  Self.AddRecord(70, IntToStr(Ord(Self.Document.Units.LenUnit) + 1));
  Self.AddRecord(9, '$LUPREC');
  Self.AddRecord(70, IntToStr(Self.Document.Units.LenPrecision));
  Self.AddRecord(9, '$FILLETRAD');
  Self.AddRecord(40, '0.5');
  Self.AddRecord(9, '$AUNITS');
  Self.AddRecord(70, IntToStr(Ord(Self.Document.Units.AngUnit)) );
  Self.AddRecord(9, '$AUPREC');
  Self.AddRecord(70, IntToStr(Self.Document.Units.AngPrecision) );
  Self.AddRecord(9, '$ANGBASE');
  Self.AddRecord(50, Self.Document.Units.AngBase);
  Self.AddRecord(9, '$ANGDIR');
  if Self.Document.Units.AngClockWise then Self.AddRecord(70, '1') else Self.AddRecord(70, '0');
  Self.AddRecord(9, '$MENU');
  Self.AddRecord(1, '');
  Self.AddRecord(9, '$ELEVATION');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$PELEVATION');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$THICKNESS');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$PDMODE');
  Self.AddRecord(70, IntToStr(Self.Document.PointStyle.Mode));
  Self.AddRecord(9, '$PDSIZE');
  Self.AddRecord(40, Self.Document.PointStyle.Size);
  Self.AddRecord(9, '$PLINEWID');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$SPLFRAME');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$SPLINETYPE');
  Self.AddRecord(70, '6');
  Self.AddRecord(9, '$SPLINESEGS');
  Self.AddRecord(70, '8');

  LHandSeedBlank := ' ';//StrUtils.DupeString(#32, 10); //'          ';
  Self.AddRecord(9, '$HANDSEED');
  Self.AddRecord(5, LHandSeedBlank);
  FSeedLinePos := Self.GetLineCount() - 1;//Length(LHandSeedBlank) - 2 {#13#10};

  Self.AddRecord(9, '$SURFTAB1');
  Self.AddRecord(70, '6');
  Self.AddRecord(9, '$SURFTAB2');
  Self.AddRecord(70, '6');
  Self.AddRecord(9, '$SURFTYPE');
  Self.AddRecord(70, '6');
  Self.AddRecord(9, '$SURFU');
  Self.AddRecord(70, '6');
  Self.AddRecord(9, '$SURFV');
  Self.AddRecord(70, '6');
  Self.AddRecord(9, '$UCSBASE');
  Self.AddRecord(2, '');
  Self.AddRecord(9, '$UCSNAME');
  Self.AddRecord(2, '');
  Self.AddRecord(9, '$UCSORG');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$UCSXDIR');
  Self.AddRecord(10, '1.0');
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$UCSYDIR');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, '1.0');
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$UCSORGTOP');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$UCSORGBOTTOM');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$UCSORGLEFT');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$UCSORGRIGHT');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$UCSORGFRONT');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$UCSORGBACK');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$PUCSBASE');
  Self.AddRecord(2, '');
  Self.AddRecord(9, '$PUCSNAME');
  Self.AddRecord(2, '');
  Self.AddRecord(9, '$PUCSXDIR');
  Self.AddRecord(10, '1.0');
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$PUCSYDIR');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, '1.0');
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$PUCSORGTOP');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$PUCSORGBOTTOM');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$PUCSORGLEFT');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$PUCSORGRIGHT');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$PUCSORGFRONT');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$PUCSORGBACK');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$USERI1');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$USERI2');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$USERI3');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$USERI4');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$USERI5');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$USERR1');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$USERR2');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$USERR3');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$USERR4');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$USERR5');
  Self.AddRecord(40, 0);
  Self.AddRecord(9, '$TILEMODE');
  if (Self.Document.ActiveLayout = Self.Document.ModelSpace) then
    Self.AddRecord(70, '1')
  else
    Self.AddRecord(70, '0');

  Self.AddRecord(9, '$PINSBASE');
  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);
  Self.AddRecord(9, '$LWDISPLAY');
  Self.AddRecord(290, '0');
  Self.AddRecord(9, '$INSUNITS');
  Self.AddRecord(70, '0');
  Self.AddRecord(9, '$MEASUREMENT');
  Self.AddRecord(70, '1');

  LLayout := Self.Document.ActiveLayout;
  if (LLayout = Self.Document.ModelSpace) then
  begin
    if Self.Document.Layouts.Count > 1 then
      LLayout := Self.Document.Layouts.Items[1]
    else
      LLayout := nil;
  end;

  if Assigned(LLayout) and Assigned(LLayout.ViewPort) and LLayout.ViewPort.Inited then
  begin
    Self.AddRecord(9, '$PEXTMIN');
    Self.AddRecord(10,LLayout.ViewPort.BoundsRect.X1);
    Self.AddRecord(20,LLayout.ViewPort.BoundsRect.Y1);
    Self.AddRecord(30, 0);
    Self.AddRecord(9, '$PEXTMAX');
    Self.AddRecord(10,LLayout.ViewPort.BoundsRect.X2);
    Self.AddRecord(20,LLayout.ViewPort.BoundsRect.Y2);
    Self.AddRecord(30, 0);

    Self.AddRecord(9, '$PLIMMIN');
    Self.AddRecord(10, LLayout.PaperLimMin.X);
    Self.AddRecord(20, LLayout.PaperLimMin.Y);
    Self.AddRecord(9, '$PLIMMAX');
    Self.AddRecord(10, LLayout.PaperLimMax.X);
    Self.AddRecord(20, LLayout.PaperLimMax.Y);
  end
  else begin
    Self.AddRecord(9, '$PEXTMIN');
    Self.AddRecord(10, 0);
    Self.AddRecord(20, 0);
    Self.AddRecord(30, 0);
    Self.AddRecord(9, '$PEXTMAX');
    Self.AddRecord(10, 0);
    Self.AddRecord(20, 0);
    Self.AddRecord(30, 0);
    
    Self.AddRecord(9, '$PLIMMIN');
    Self.AddRecord(10, 0);
    Self.AddRecord(20, 0);
    Self.AddRecord(9, '$PLIMMAX');
    Self.AddRecord(10, 12);
    Self.AddRecord(20, 9);
  end;

  Self.AddRecord(9, '$VERSIONGUID');
  Self.AddRecord(2, UdUtils.GetGUID(False, False));

  //PSLTSCALE 缩放时使用图纸空间单位, 是指在布局的视口里面是否按照视口打印比例进行缩放。
  //CMLSTYLE  设置绘制多线的样式. 初始值: "standard"
  //CMLJUST   指定多线对正方式：0.上 1.中间 2.下。初始值：0
  //CMLSCALE  初始值：1.0000（英制）或 20.0000（公制）控制多线的全局宽度。
  
  AddRecord(0, 'ENDSEC');
end;

end.