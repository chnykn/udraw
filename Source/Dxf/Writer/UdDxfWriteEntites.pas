{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfWriteEntites;

{$I UdDefs.INC}
//{$DEFINE READ_LAYOUT}

interface

uses
  Classes,
  UdDxfTypes, UdDxfWriteSection,

  UdGTypes, UdTypes, UdDocument, UdEntities, UdEntity, UdLayer, UdLinetype,  UdLineWeight,

  UdPoint, UdLine, UdXLine, UdRay, UdCircle, UdArc, UdEllipse, UdPolyline, UdSpline,
  UdText, UdSolid, UdLeader, UdTolerance, UdHatch, UdInsert,
  UdDimension, UdDimAligned, UdDimRotated, UdDimArclength, UdDimOrdinate,
  UdDimRadial, UdDimRadiallarge, UdDimDiametric, UdDim2LineAngular, UdDim3PointAngular;

type

  TUdDxfWriteEntites = class(TUdDxfWriteSection)
  private
    FEntityIndex: Integer;
    FEntityCount: Integer;
    FProgrssStep: Integer;
    FLastProgrss: Integer;

  protected
    procedure AddCommonProp(AEntity: TUdEntity; ADbClassName: string; AOwnerHandle: string; AInLayout: Boolean);

    procedure AddLine(AEntity: TUdLine; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddRay(AEntity: TUdRay; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddXLine(AEntity: TUdXLine; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddCircle(AEntity: TUdCircle; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddArc(AEntity: TUdArc; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddEllipse(AEntity: TUdEllipse; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddSPline_(AEntity: TUdEntity; AFitPnts: TPoint2DArray; AClosed: Boolean; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddPolyline(AEntity: TUdPolyline; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddSPline(AEntity: TUdSpline; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddPoint(AEntity: TUdPoint; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddText(AEntity: TUdText; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddSolid(AEntity: TUdSolid; AOwnerHandle: string; AInLayout: Boolean);

    procedure AddHatch(AEntity: TUdHatch; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddInsert(AEntity: TUdInsert; AOwnerHandle: string; AInLayout: Boolean);

    procedure AddLeader(AEntity: TUdLeader; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddTolerance(AEntity: TUdTolerance; AOwnerHandle: string; AInLayout: Boolean);


    procedure AddDimCustomProp(AEntity: TUdDimension);
    procedure AddDimension(AEntity: TUdDimAligned; AOwnerHandle: string; AInLayout: Boolean); overload;
    procedure AddDimension(AEntity: TUdDimRotated; AOwnerHandle: string; AInLayout: Boolean); overload;
    procedure AddDimension(AEntity: TUdDimArcLength; AOwnerHandle: string; AInLayout: Boolean); overload;
    procedure AddDimension(AEntity: TUdDim3PointAngular; AOwnerHandle: string; AInLayout: Boolean); overload;
    procedure AddDimension(AEntity: TUdDim2LineAngular; AOwnerHandle: string; AInLayout: Boolean); overload;
    procedure AddDimension(AEntity: TUdDimRadialLarge; AOwnerHandle: string; AInLayout: Boolean); overload;
    procedure AddDimension(AEntity: TUdDimRadial; AOwnerHandle: string; AInLayout: Boolean); overload;
    procedure AddDimension(AEntity: TUdDimDiametric; AOwnerHandle: string; AInLayout: Boolean); overload;
    procedure AddDimension(AEntity: TUdDimOrdinate; AOwnerHandle: string; AInLayout: Boolean); overload;


    {
    procedure AddImage(AEntity: TUdImage; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddRegion(AEntity: TUdRegion; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddTrace(AEntity: TUdTrace; AOwnerHandle: string; AInLayout: Boolean);
    procedure AddTable(AEntity: TUdTable; AOwnerHandle: string; AInLayout: Boolean);
    }

  public
    constructor Create(AOwner: TObject);  override;
    destructor Destroy; override;

    procedure AddViewport(ALayout: TObject; ABlockName, AOwnerHandle: string; AEntitiesSection, AVPortMode: Boolean);

    function AddEntities(AEntities: TList; AOwnerHandle: string; AInLayout: Boolean): Boolean; overload;
    function AddEntities(AEntities: TUdEntities; AOwnerHandle: string; AInLayout: Boolean): Boolean; overload;

    procedure Execute(); override;

  end;



implementation

uses
  SysUtils,
  UdDxfWriter, UdColor, UdLayout, UdDimStyle, UdDimProps, UdHatchPattern,
  UdMath, UdGeo2D, UdBSpline2D;



//=================================================================================================
{ TUdDxfWriteEntites }


constructor TUdDxfWriteEntites.Create(AOwner: TObject);
begin
  inherited;

  FEntityIndex := 0;
  FEntityCount := 0;
  FProgrssStep := 0;
end;

destructor TUdDxfWriteEntites.Destroy;
begin
  //...
  inherited;
end;




//-----------------------------------------------------------------------------------------------

procedure TUdDxfWriteEntites.AddCommonProp(AEntity: TUdEntity; ADbClassName: string; AOwnerHandle: string; AInLayout: Boolean);
begin
  if (AEntity.ID < 0) then  // not AInLayout or  or AEntity.InheritsFrom(TUdText)
    Self.AddRecord(5, NewHandle())
  else
    Self.AddRecord(5, IntToHex(AEntity.ID, 0));

  (*
  if Self.Version <> dxf12 then
  begin
    if (ALeaderHandle <> '') then
    begin
      Self.AddRecord(102, '{ACAD_REACTORS');
      Self.AddRecord(330, ALeaderHandle);
      Self.AddRecord(102, '}');
    end;
  end;
  *)

{$IFDEF DXF12}
  if Self.Version <> dxf12 then
  begin
{$ENDIF}
    Self.AddRecord(330, AOwnerHandle);
    Self.AddRecord(100, 'AcDbEntity');
{$IFDEF DXF12}
  end;
{$ENDIF}

  if ((Self.GeneralHandle <> AOwnerHandle) and AInLayout) then
    Self.AddRecord(67, '1');

  if Assigned(AEntity.Layer) then
    Self.AddRecord(8, AEntity.Layer.Name);

  if AInLayout and Assigned(AEntity.LineType) and (AEntity.LineType.ByKind <> bkByLayer) then
    Self.AddRecord(6, AEntity.LineType.Name);

  if Assigned(AEntity.Color) and (AEntity.Color.ByKind <> bkByLayer) then
  begin
    Self.AddRecord(62, DxfFixColor(AEntity.Color));
    if (Self.Version = dxf2004) and (AEntity.Color.ColorType = ctTrueColor) then
      Self.AddRecord(420, IntToStr(AEntity.Color.TrueColor));
  end;

{$IFDEF DXF12}
  if Self.Version <> dxf12 then
  begin
{$ENDIF}
    if AEntity.LineWeight <> LW_BYLAYER then
      Self.AddRecord(370, IntToStr(AEntity.LineWeight));
{$IFDEF DXF12}
  end;
{$ENDIF}

  if NotEqual(AEntity.LineTypeScale, 1.0) then
    Self.AddRecord(48, AEntity.LineTypeScale);

//  if not AEntity.Visible then Self.AddRecord(60, '1');

{$IFDEF DXF12}
  if Self.Version <> dxf12 then
{$ENDIF}
  Self.AddRecord(100,  ADbClassName);
end;


procedure TUdDxfWriteEntites.AddLine(AEntity: TUdLine; AOwnerHandle: string; AInLayout: Boolean);
begin
  Self.AddRecord(0, 'LINE');
  Self.AddCommonProp(AEntity, 'AcDbLine', AOwnerHandle, AInLayout);

//  if NotEqual(AEntity.Thickness, 0.0) then
//    Self.AddRecord(39, AEntity.Thickness);

  Self.AddRecord(10, AEntity.StartX);
  Self.AddRecord(20, AEntity.StartY);
  Self.AddRecord(30, '0');

  Self.AddRecord(11, AEntity.EndX);
  Self.AddRecord(21, AEntity.EndY);
  Self.AddRecord(31, '0');
end;

procedure TUdDxfWriteEntites.AddRay(AEntity: TUdRay; AOwnerHandle: string; AInLayout: Boolean);
var
  LAng: Float;
begin
  Self.AddRecord(0, 'RAY');
  Self.AddCommonProp(AEntity, 'AcDbRay', AOwnerHandle, AInLayout);

  Self.AddRecord(10, AEntity.BasePoint.X);
  Self.AddRecord(20, AEntity.BasePoint.Y);
  Self.AddRecord(30, '0');

  LAng := AEntity.Angle;

  Self.AddRecord(11, UdMath.CosD(LAng));
  Self.AddRecord(21, UdMath.SinD(LAng));
  Self.AddRecord(31, '0');
end;

procedure TUdDxfWriteEntites.AddXLine(AEntity: TUdXLine; AOwnerHandle: string; AInLayout: Boolean);
var
  LAng: Float;
begin
  Self.AddRecord(0, 'XLINE');
  Self.AddCommonProp(AEntity, 'AcDbXline', AOwnerHandle, AInLayout);

  Self.AddRecord(10, AEntity.BasePoint.X);
  Self.AddRecord(20, AEntity.BasePoint.Y);
  Self.AddRecord(30, '0');

  LAng := AEntity.Angle;

  Self.AddRecord(11, UdMath.CosD(LAng));
  Self.AddRecord(21, UdMath.SinD(LAng));
  Self.AddRecord(31, '0');
end;

procedure TUdDxfWriteEntites.AddCircle(AEntity: TUdCircle; AOwnerHandle: string; AInLayout: Boolean);
begin
  Self.AddRecord(0, 'CIRCLE');
  Self.AddCommonProp(AEntity, 'AcDbCircle', AOwnerHandle, AInLayout);

//  if NotEqual(AEntity.Thickness, 0.0) then
//    Self.AddRecord(39, AEntity.Thickness);

  Self.AddRecord(10, AEntity.Center.X);
  Self.AddRecord(20, AEntity.Center.Y);
  Self.AddRecord(30, '0');
  Self.AddRecord(40, AEntity.Radius);
end;

procedure TUdDxfWriteEntites.AddArc(AEntity: TUdArc; AOwnerHandle: string; AInLayout: Boolean);
begin
  Self.AddRecord(0, 'ARC');
  Self.AddCommonProp(AEntity, 'AcDbCircle', AOwnerHandle, AInLayout);

//  if NotEqual(AEntity.Thickness, 0.0) then
//    Self.AddRecord(39, AEntity.Thickness);

  Self.AddRecord(10, AEntity.Center.X);
  Self.AddRecord(20, AEntity.Center.Y);
  Self.AddRecord(30, '0');
  Self.AddRecord(40, AEntity.Radius);

  Self.AddRecord(100, 'AcDbArc');
  Self.AddRecord(50, AEntity.StartAngle);
  Self.AddRecord(51, AEntity.EndAngle);
end;

procedure TUdDxfWriteEntites.AddEllipse(AEntity: TUdEllipse; AOwnerHandle: string; AInLayout: Boolean);
var
  LEndPnt: TPoint2D;
begin
  Self.AddRecord(0, 'ELLIPSE');
  Self.AddCommonProp(AEntity, 'AcDbEllipse', AOwnerHandle, AInLayout);

//  if NotEqual(AEntity.Thickness, 0.0) then
//    Self.AddRecord(39, AEntity.Thickness);

  Self.AddRecord(10, AEntity.Center.X);
  Self.AddRecord(20, AEntity.Center.Y);
  Self.AddRecord(30, '0');

  LEndPnt := UdGeo2D.GetEllipsePoint(AEntity.XData, 0, True);
  LEndPnt.X := LEndPnt.X - AEntity.Center.X;
  LEndPnt.Y := LEndPnt.Y - AEntity.Center.Y;

  Self.AddRecord(11, LEndPnt.X);
  Self.AddRecord(21, LEndPnt.Y);
  Self.AddRecord(31, '0');

  Self.AddRecord(40, AEntity.MinorRadius / AEntity.MajorRadius);
  Self.AddRecord(41, UdMath.DegToRad(AEntity.StartAngle) );
  Self.AddRecord(42, UdMath.DegToRad(AEntity.EndAngle) );
end;


procedure TUdDxfWriteEntites.AddSPline_(AEntity: TUdEntity; AFitPnts: TPoint2DArray; AClosed: Boolean; AOwnerHandle: string; AInLayout: Boolean);
var
  I: Integer;
  LKnots: TFloatArray;
  LCtrlPoints: TPoint2DArray;
  LSamplePnts: TPoint2DArray;
begin
  LSamplePnts := UdBSpline2D.GetFittingBSplineSamplePoints(AFitPnts, Length(AFitPnts) * 2, AClosed, LKnots, LCtrlPoints);
  if Length(LSamplePnts) <= 0 then Exit; //====>>>>>

  Self.AddRecord(0, 'SPLINE');
  Self.AddCommonProp(AEntity, 'AcDbSpline', AOwnerHandle, AInLayout);

  //if NotEqual(AEntity.Thickness, 0.0) then
  //  Self.AddRecord(39, AEntity.Thickness);

  if AClosed then Self.AddRecord(70, '11') else Self.AddRecord(70, '10');
  Self.AddRecord(71, '3');  // Degree 3

  Self.AddRecord(72, Length(LKnots));
  Self.AddRecord(73, Length(LCtrlPoints));
  Self.AddRecord(74, Length(AFitPnts));

  Self.AddRecord(42, '0.0000001');
  Self.AddRecord(43, '0.0000001');
  Self.AddRecord(44, '0.0000001');

  for I := 0 to Length(LKnots) - 1 do
    Self.AddRecord(40, LKnots[I] );

  for I := 0 to Length(LCtrlPoints) - 1 do
  begin
    Self.AddRecord(10, LCtrlPoints[I].X );
    Self.AddRecord(20, LCtrlPoints[I].Y );
    Self.AddRecord(30, 0 );
  end;

  for I := 0 to Length(AFitPnts) - 1 do
  begin
    Self.AddRecord(11, AFitPnts[I].X );
    Self.AddRecord(21, AFitPnts[I].Y );
    Self.AddRecord(31, 0 );
  end;
end;

//(sfStandard, sfCtrlPnts, sfFitting, sfQuadratic, sfCubic);
procedure TUdDxfWriteEntites.AddPolyline(AEntity: TUdPolyline; AOwnerHandle: string; AInLayout: Boolean);

  procedure _Add2DPolyline();
  var
    I: Integer;
    LHandle: string;
    LLayerName: string;
    LFixWidth: Float;
  begin
    Self.AddRecord(0, 'POLYLINE');
    Self.AddCommonProp(AEntity, 'AcDb2dPolyline'{'AcDb3dPolyline'}, AOwnerHandle, AInLayout);

    Self.AddRecord(66, '1');
    Self.AddRecord(10, 0);
    Self.AddRecord(20, 0);
    Self.AddRecord(30, 0);

  //if NotEqual(AEntity.Thickness, 0.0) then
  //  Self.AddRecord(39, AEntity.Thickness);

    Self.AddRecord(70, '4');
    if (AEntity.SplineFlag = sfCubic) then Self.AddRecord(75, '6') else Self.AddRecord(75, '5');


    LFixWidth := AEntity.Width;

    LHandle := IntToHex(AEntity.ID, 0);
    LLayerName := '';
    if Assigned(AEntity.Layer) then LLayerName := AEntity.Layer.Name;

    for I := 0 to Length(AEntity.Vertexes) - 1 do
    begin
      Self.AddRecord(0, 'VERTEX');
      Self.AddRecord(5, Self.NewHandle());
      Self.AddRecord(330, LHandle);
      Self.AddRecord(100, 'AcDbEntity');
      Self.AddRecord(8, LLayerName);

      if (AEntity.Color.ByKind <> bkByLayer) then
        Self.AddRecord(62, DxfFixColor(AEntity.Color))
      else
        Self.AddRecord(62, '0');

      Self.AddRecord(100, 'AcDbVertex');
      Self.AddRecord(100, 'AcDb2dVertex'{'AcDb3dPolylineVertex'});

      Self.AddRecord(10, AEntity.Vertexes[I].Point.X);
      Self.AddRecord(20, AEntity.Vertexes[I].Point.Y);
      Self.AddRecord(30, 0);

      if LFixWidth > 0 then
      begin
        Self.AddRecord(40, LFixWidth);
        Self.AddRecord(41, LFixWidth);
      end;

      Self.AddRecord(70, '16');
    end;

    for I := 0 to Length(AEntity.SamplePoints) - 1 do
    begin
      Self.AddRecord(0, 'VERTEX');

      Self.AddRecord(5, Self.NewHandle());
      Self.AddRecord(330, LHandle);
      Self.AddRecord(100, 'AcDbEntity');

      Self.AddRecord(8, LLayerName);
      Self.AddRecord(100, 'AcDbVertex');
      Self.AddRecord(100, 'AcDb2dVertex');

      Self.AddRecord(10, AEntity.SamplePoints[I].X);
      Self.AddRecord(20, AEntity.SamplePoints[I].Y);
      Self.AddRecord(30, 0);

      if LFixWidth > 0 then
      begin
        Self.AddRecord(40, LFixWidth);
        Self.AddRecord(41, LFixWidth);
      end;

      Self.AddRecord(70, '8');
    end;

    Self.AddRecord(0, 'SEQEND');
    Self.AddRecord(5, Self.NewHandle());
    Self.AddRecord(330, LHandle);
    Self.AddRecord(100, 'AcDbEntity');
    Self.AddRecord(8, LLayerName);
  end;

  procedure _AddLwPolyline();
  var
    I: Integer;
    LFixWidth: Float;
  begin
    Self.AddRecord(0, 'LWPOLYLINE');
    Self.AddCommonProp(AEntity, 'AcDbPolyline', AOwnerHandle, AInLayout);

  //if NotEqual(AEntity.Thickness, 0.0) then
  //  Self.AddRecord(39, AEntity.Thickness);

    Self.AddRecord(90, IntToStr(Length(AEntity.Vertexes)));
    if AEntity.Closed then Self.AddRecord(70, '1');

    LFixWidth := AEntity.Width;
    if LFixWidth > 0 then
      Self.AddRecord(43, LFixWidth);

    Self.AddRecord(38, 0{AEntity.Elevation} );
    for I := 0 to Length(AEntity.Vertexes) - 1 do
    begin
      Self.AddRecord(10, AEntity.Vertexes[I].Point.X);
      Self.AddRecord(20, AEntity.Vertexes[I].Point.Y);

      Self.AddRecord(40, AEntity.Widths[I].X);
      Self.AddRecord(41, AEntity.Widths[I].Y);

      if NotEqual(AEntity.Vertexes[I].Bulge, 0.0) and (AEntity.SplineFlag <> sfCtrlPnts) then
        Self.AddRecord(42, AEntity.Vertexes[I].Bulge);
    end;
  end;

begin
  if AEntity.SplineFlag = sfFitting then
    Self.AddSPline_(AEntity,  VertexesToPoints(AEntity.Vertexes), AEntity.Closed, AOwnerHandle, AInLayout)
  else if AEntity.SplineFlag in [sfQuadratic, sfCubic] then
    _Add2DPolyline()
  else
    _AddLwPolyline()
end;

procedure TUdDxfWriteEntites.AddSPline(AEntity: TUdSpline; AOwnerHandle: string; AInLayout: Boolean);
begin
  AddSPline_(AEntity, AEntity.FittingPoints, AEntity.Closed, AOwnerHandle, AInLayout);
end;

procedure TUdDxfWriteEntites.AddPoint(AEntity: TUdPoint; AOwnerHandle: string; AInLayout: Boolean);
begin
  Self.AddRecord(0, 'POINT');
  Self.AddCommonProp(AEntity, 'AcDbPoint', AOwnerHandle, AInLayout);

  //if NotEqual(AEntity.Thickness, 0.0) then
  //  Self.AddRecord(39, AEntity.Thickness);

  Self.AddRecord(10, AEntity.Position.X);
  Self.AddRecord(20, AEntity.Position.Y);
  Self.AddRecord(30, '0');
end;

procedure TUdDxfWriteEntites.AddText(AEntity: TUdText; AOwnerHandle: string; AInLayout: Boolean);

  procedure _AddMultLineText();//(AEntity: TUdText; AOwnerHandle: string; AInLayout: Boolean);
  var
    S: string;
    LStr: string;
    LFlag: Cardinal;
  begin
    Self.AddRecord(0, 'MTEXT');
    Self.AddCommonProp(AEntity, 'AcDbMText', AOwnerHandle, AInLayout);

    //if NotEqual(AEntity.Thickness, 0.0) then
    //  Self.AddRecord(39, AEntity.Thickness);

    Self.AddRecord(10, AEntity.Position.X);
    Self.AddRecord(20, AEntity.Position.Y);
    Self.AddRecord(30, 0);
    Self.AddRecord(40, AEntity.Height);
    Self.AddRecord(41, AEntity.TextWidth + Round(AEntity.Height * 2) );

    {
    LFlag := 1;
    case AEntity.Alignment of
      taTopLeft      : LFlag := 1;
      taMiddleLeft   : LFlag := 4;
      taBottomLeft   : LFlag := 7;

      taTopCenter    : LFlag := 2;
      taMiddleCenter : LFlag := 5;
      taBottomCenter : LFlag := 8;

      taTopRight     : LFlag := 3;
      taMiddleRight  : LFlag := 6;
      taBottomRight  : LFlag := 9;
    end;
    }
    LFlag := Ord(AEntity.Alignment) + 1;

    Self.AddRecord(71, IntToStr(LFlag));
    Self.AddRecord(72, '5');

    LStr := AEntity.Contents;
    LStr := SysUtils.StringReplace(LStr, #13#10, '\P', [rfReplaceAll]);

    if Length(LStr) < 256 then
    begin
      Self.AddRecord(1, LStr);
    end
    else begin
      S := Copy(LStr, 1, 256);
      Self.AddRecord(1, S);

      Delete(LStr, 1, 256);
      while LStr <> '' do
      begin
        S := Copy(LStr, 1, 256);
        Self.AddRecord(3, S);

        Delete(LStr, 1, 256);
      end;
    end;

    if Assigned(AEntity.TextStyle) then
      Self.AddRecord(7, AEntity.TextStyle.Name);

    if NotEqual(AEntity.Rotation, 0.0) then
      Self.AddRecord(50, AEntity.Rotation );
      
//    Self.AddRecord(42, AEntity.TextWidth + 20);
    Self.AddRecord(44, AEntity.LineSpaceFactor);
  end;


  {
  procedure _GetTextAlign(ATextAlign: TUdTextAlign; var AHorJustify, AVerJustify: Integer);
  begin
    case ATextAlign of
      taTopLeft   : begin AHorJustify := 0; AVerJustify := 3; end;
      taTopCenter : begin AHorJustify := 1; AVerJustify := 3; end;
      taTopRight  : begin AHorJustify := 2; AVerJustify := 3; end;
      
      taMiddleLeft  : begin AHorJustify := 0; AVerJustify := 2; end;
      taMiddleCenter: begin AHorJustify := 1; AVerJustify := 2; end;
      taMiddleRight : begin AHorJustify := 2; AVerJustify := 2; end;

      taBottomLeft  : begin AHorJustify := 0; AVerJustify := 1; end;
      taBottomCenter: begin AHorJustify := 1; AVerJustify := 1; end;
      taBottomRight : begin AHorJustify := 2; AVerJustify := 1; end;
    end;
  end;
  }


  
  procedure _AddSingleLineText();//(AEntity: TUdText; AOwnerHandle: string; AInLayout: Boolean);
  var
    LFlag: Cardinal;
    //LHorJustify, LVerJustify: Integer;
    LInsPnt: TPoint2D;
  begin
    Self.AddRecord(0, 'TEXT');
    Self.AddCommonProp(AEntity, 'AcDbText', AOwnerHandle, AInLayout);

    if Length(AEntity.TextBound) > 0 then
      LInsPnt := AEntity.TextBound[0]
    else
      LInsPnt := AEntity.Position;
      
    Self.AddRecord(10, LInsPnt.X);
    Self.AddRecord(20, LInsPnt.Y);
    Self.AddRecord(30, 0);
    
    Self.AddRecord(40, AEntity.Height);
    Self.AddRecord(1, AEntity.Contents);

    if NotEqual(AEntity.Rotation, 0.0) then
      Self.AddRecord(50, AEntity.Rotation );

    if NotEqual(AEntity.WidthFactor, 1.0) then
      Self.AddRecord(41, AEntity.WidthFactor);

    if Assigned(AEntity.TextStyle) then
      Self.AddRecord(7, AEntity.TextStyle.Name);

    LFlag := 0;
    if AEntity.Backward then LFlag := LFlag or 2;
    if AEntity.Upsidedown then LFlag := LFlag or 4;
    if LFlag > 0 then
      Self.AddRecord(71, IntToStr(LFlag));
      

    {
    _GetTextAlign(AEntity.Alignment, LHorJustify, LVerJustify);
    Self.AddRecord(72, IntToStr(LHorJustify));
        
    Self.AddRecord(11, AEntity.Position.X);
    Self.AddRecord(21, AEntity.Position.Y);
    Self.AddRecord(31, 0);
    }
    
    Self.AddRecord(100, 'AcDbText');
    {
    Self.AddRecord(73, IntToStr(LVerJustify));
    }
  end;

var
  LText: string;
  LSingleLine: Boolean;
begin
  LSingleLine := False;

  
  if ((AEntity.KindsFlag and TEXT_KIND_SINGLE_LINE) > 0) then
  begin
    LText := Trim(AEntity.Contents);
    LSingleLine := Pos(#13, LText) <= 0;
  end;

  if LSingleLine then
    _AddSingleLineText() //(AEntity, AOwnerHandle, AInLayout)
  else
    _AddMultLineText();  //(AEntity, AOwnerHandle, AInLayout);
end;

procedure TUdDxfWriteEntites.AddSolid(AEntity: TUdSolid; AOwnerHandle: string; AInLayout: Boolean);
begin
  Self.AddRecord(0, 'SOLID');
  Self.AddCommonProp(AEntity, 'AcDbTrace', AOwnerHandle, AInLayout);

  Self.AddRecord(10, AEntity.P1.X);
  Self.AddRecord(20, AEntity.P1.Y);
  Self.AddRecord(30, 0);

  Self.AddRecord(11, AEntity.P2.X);
  Self.AddRecord(21, AEntity.P2.Y);
  Self.AddRecord(31, 0);

  Self.AddRecord(12, AEntity.P3.X);
  Self.AddRecord(22, AEntity.P3.Y);
  Self.AddRecord(32, 0);

  Self.AddRecord(13, AEntity.P4.X);
  Self.AddRecord(23, AEntity.P4.Y);
  Self.AddRecord(33, 0);
end;




procedure TUdDxfWriteEntites.AddHatch(AEntity: TUdHatch; AOwnerHandle: string; AInLayout: Boolean);
var
  I, J, K, L: Integer;
  LCurve: TCurve2D;
  LCurves: TCurve2DArray;
  LIsPolyline: Boolean;
  LEll: TEllipse2D;
  LSpline: TSpline2D;
  LVertexes: TVertexes2D;
  LHasBulge, LClosed: Boolean;
  LP1, LP2, LPnt: TPoint2D;
  LMajorR, LMinorR, LFactor, LA1, LA2: Float;
  LHatchPattern: TUdHatchPattern;
begin
  if System.Length(AEntity.PolyCurves) <= 0 then Exit;

  Self.AddRecord(0, 'HATCH');
  Self.AddCommonProp(AEntity, 'AcDbHatch', AOwnerHandle, AInLayout);

  Self.AddRecord(10, 0);
  Self.AddRecord(20, 0);
  Self.AddRecord(30, 0);

  Self.AddRecord(210, 0);
  Self.AddRecord(220, 0);
  Self.AddRecord(230, '1.0');

  Self.AddRecord(2, AEntity.PatternName);
  if AEntity.IsSolid then Self.AddRecord(70, '1') else Self.AddRecord(70, '0');
  Self.AddRecord(71, '0');
  Self.AddRecord(91, IntToStr(System.Length(AEntity.PolyCurves)));

  for I := 0 to System.Length(AEntity.PolyCurves) - 1 do
  begin
    LCurves := AEntity.PolyCurves[I];

    LIsPolyline := (Length(LCurves) = 1) and (LCurves[0].Kind = ckPolyline);

    if LIsPolyline then
    begin
      Self.AddRecord(92, '6');   // '2'
    end
    else begin
      Self.AddRecord(92, '4');
      Self.AddRecord(93, IntToStr(Length(LCurves)));
    end;

    for J := 0 to Length(LCurves) - 1 do
    begin
      LCurve := LCurves[J];

      case LCurve.Kind of
        ckLine:
        begin
          Self.AddRecord(72, '1');
          Self.AddRecord(10, FloatToStr(PSegment2D(LCurve.Data)^.P1.X) );
          Self.AddRecord(20, FloatToStr(PSegment2D(LCurve.Data)^.P1.Y) );
          Self.AddRecord(11, FloatToStr(PSegment2D(LCurve.Data)^.P2.X) );
          Self.AddRecord(21, FloatToStr(PSegment2D(LCurve.Data)^.P2.Y) );
        end;

        ckArc:
        begin
          Self.AddRecord(72, '2');
          Self.AddRecord(10, FloatToStr(PArc2D(LCurve.Data)^.Cen.X) );
          Self.AddRecord(20, FloatToStr(PArc2D(LCurve.Data)^.Cen.Y) );
          Self.AddRecord(40, FloatToStr(PArc2D(LCurve.Data)^.R) );
          Self.AddRecord(50, FloatToStr(PArc2D(LCurve.Data)^.Ang1) );
          Self.AddRecord(51, FloatToStr(PArc2D(LCurve.Data)^.Ang2) );
          Self.AddRecord(73, DxfBoolToStr(PArc2D(LCurve.Data)^.IsCW) );
        end;

        ckEllipse:
        begin
          LEll := PEllipse2D(LCurve.Data)^;
          
          LP1 := LEll.Cen;
          if LEll.Rx >= LEll.Ry then
          begin
            LA1 := LEll.Ang1;
            LA2 := LEll.Ang2;
            LMajorR := LEll.Rx;
            LMinorR := LEll.Ry;
            LP2 := UdGeo2D.GetEllipsePoint(LEll, 0);
          end
          else begin
            if IsEqual(LEll.Ang1, 0.0) and IsEqual(LEll.Ang1, 360.0) then
            begin
              LA1 := LEll.Ang1;
              LA2 := LEll.Ang2;
            end
            else begin
              LA1 := FixAngle(LEll.Ang1 - 90);
              LA2 := FixAngle(LEll.Ang2 - 90);
            end;
            LMajorR := LEll.Ry;
            LMinorR := LEll.Rx;
            LP2 := UdGeo2D.GetEllipsePoint(LEll, 90);
          end;
          LP2.X := LP2.X - LP1.X;
          LP2.Y := LP2.Y - LP1.Y;
          LFactor := LMinorR / LMajorR;

          Self.AddRecord(72, '3');
          Self.AddRecord(10, FloatToStr(LP1.X) );
          Self.AddRecord(20, FloatToStr(LP1.Y) );
          Self.AddRecord(11, FloatToStr(LP2.X) );
          Self.AddRecord(21, FloatToStr(LP2.Y) );
          Self.AddRecord(40, FloatToStr(LFactor) );
          Self.AddRecord(50, FloatToStr(LA1) );
          Self.AddRecord(51, FloatToStr(LA2) );

          Self.AddRecord(73, DxfBoolToStr(LEll.IsCW) );
        end;

        ckSpline:
        begin
          LSpline := PSpline2D(LCurve.Data)^;

          Self.AddRecord(72, '4');
          Self.AddRecord(94, IntToStr(LSpline.Degree) );
          Self.AddRecord(73, '0' );
          Self.AddRecord(77, '0' );
          Self.AddRecord(95, IntToStr(Length(LSpline.Knots)) );
          Self.AddRecord(96, IntToStr(Length(LSpline.CtlPnts)) );

          for K := 0 to Length(LSpline.Knots) - 1 do
            Self.AddRecord(40, FloatToStr(LSpline.Knots[K]) );

          for K := 0 to Length(LSpline.CtlPnts) - 1 do
          begin
            Self.AddRecord(10, FloatToStr(LSpline.CtlPnts[K].X) );
            Self.AddRecord(20, FloatToStr(LSpline.CtlPnts[K].Y) );
          end;
        end;


        ckPolyline:
        begin
          LVertexes := PVertexes2D(LCurve.Data)^;
          LHasBulge := False;
          
          for K := 0 to Length(LVertexes) - 1 do
          begin
            if NotEqual(LVertexes[I].Bulge, 0.0) then
            begin
              LHasBulge := True;
              Break;
            end;
          end;

          LClosed := (Length(LVertexes) > 1) and IsEqual(LVertexes[0].Point, LVertexes[High(LVertexes)].Point);
          L := Length(LVertexes);
          if LClosed then L := L - 1;

          Self.AddRecord(72, DxfBoolToStr(LHasBulge) );
          Self.AddRecord(73, DxfBoolToStr(LClosed));
          Self.AddRecord(93, IntToStr(L));

          for K := 0 to L - 1 do
          begin
            Self.AddRecord(10, FloatToStr(LVertexes[K].Point.X) );
            Self.AddRecord(20, FloatToStr(LVertexes[K].Point.Y) );

            if LHasBulge then
              Self.AddRecord(42, FloatToStr(LVertexes[K].Bulge) );
          end;
        end;
      end;

    end; {end for J}

    Self.AddRecord(97, '0');
  end; {end for I}

  Self.AddRecord(75, IntToStr(Ord(AEntity.Style)));
  Self.AddRecord(76, '1'); // 填充图案类型：0 = 用户定义；1 = 预定义；2 = 自定义

  LHatchPattern := AEntity.HatchPattern;
  
  if Assigned(LHatchPattern) and not AEntity.IsSolid then
  begin
    Self.AddRecord(52, AEntity.HatchAngle);
    Self.AddRecord(41, AEntity.HatchScale);
    Self.AddRecord(77, '0'); //填充图案双标志（仅限图案填充）：0 = 不是双标志；1 = 双标志

    if Assigned(LHatchPattern) then
    begin
      Self.AddRecord(78, IntToStr(LHatchPattern.PatternLines.Count));

      for I := 0 to LHatchPattern.PatternLines.Count - 1 do
      begin
        Self.AddRecord(53, FloatToStr(LHatchPattern.PatternLines.Items[I].Angle) );

        Self.AddRecord(43, FloatToStr(LHatchPattern.PatternLines.Items[I].Origin.X) );
        Self.AddRecord(44, FloatToStr(LHatchPattern.PatternLines.Items[I].Origin.Y) );

        if NotEqual(LHatchPattern.PatternLines.Items[I].Angle, 0.0) then
        begin
          LPnt := UdGeo2D.Rotate({LHatchPattern.PatternLines.Items[I].Origin,}
                                 LHatchPattern.PatternLines.Items[I].Angle,
                                 LHatchPattern.PatternLines.Items[I].Offset);

          Self.AddRecord(45, FloatToStr(LPnt.X) );
          Self.AddRecord(46, FloatToStr(LPnt.Y) );
        end
        else begin
          Self.AddRecord(45, FloatToStr(LHatchPattern.PatternLines.Items[I].Offset.X) );
          Self.AddRecord(46, FloatToStr(LHatchPattern.PatternLines.Items[I].Offset.Y) );
        end;

        Self.AddRecord(79, IntToStr( System.Length(LHatchPattern.PatternLines.Items[I].Dashes) ));

        for J := 0 to System.Length(LHatchPattern.PatternLines.Items[I].Dashes) - 1 do
          Self.AddRecord(49,  FloatToStr(LHatchPattern.PatternLines.Items[I].Dashes[J]) );
      end;
    end;
  end;

  // 在相关图案填充和使用图案填充的“填充”方法创建的图案填充的填充图案计算中，
  // 用于确定执行各种相交和射线法操作的密度的像素大小。
  Self.AddRecord(47, '1');

  Self.AddRecord(98, '0');  //种子点数   (貌似这个可以设置为0 下面的两个10和20都可以不要了)
//  Self.AddRecord(10, 0);
//  Self.AddRecord(20, 0);

  Self.AddRecord(1001, 'ACAD');
  Self.AddRecord(1010, 0);
  Self.AddRecord(1020, 0);
  Self.AddRecord(1030, 0);
end;












































procedure TUdDxfWriteEntites.AddInsert(AEntity: TUdInsert; AOwnerHandle: string; AInLayout: Boolean);
begin
  if not Assigned(AEntity.Block) then Exit; //===>>>

  Self.AddRecord(0, 'INSERT');
  Self.AddCommonProp(AEntity, 'AcDbBlockReference', AOwnerHandle, AInLayout);

  Self.AddRecord(2, AEntity.Block.Name);

  Self.AddRecord(10, AEntity.Position.X);
  Self.AddRecord(20, AEntity.Position.Y);
  Self.AddRecord(30, 0);

  Self.AddRecord(41, AEntity.ScaleX);
  Self.AddRecord(42, AEntity.ScaleY);
  Self.AddRecord(43, '1.0');

  Self.AddRecord(50, AEntity.Rotation);
end;



procedure TUdDxfWriteEntites.AddLeader(AEntity: TUdLeader; AOwnerHandle: string; AInLayout: Boolean);
var
  I: Integer;
begin
  Self.AddRecord(0, 'LEADER');
  Self.AddCommonProp(AEntity, 'AcDbLeader', AOwnerHandle, AInLayout);

  if Assigned(AEntity.DimStyle) then Self.AddRecord(3, AEntity.DimStyle.Name);

  if AEntity.ShowArrow then Self.AddRecord(71, '1') else Self.AddRecord(71, '0');
  if AEntity.Spline    then Self.AddRecord(72, '1') else Self.AddRecord(72, '0');

  Self.AddRecord(76, IntToStr(Length(AEntity.Points)) );
  for I := 0 to Length(AEntity.Points) - 1 do
  begin
    Self.AddRecord(10, AEntity.Points[I].X );
    Self.AddRecord(20, AEntity.Points[I].Y );
    Self.AddRecord(30, 0 );
  end;
end;

procedure TUdDxfWriteEntites.AddTolerance(AEntity: TUdTolerance; AOwnerHandle: string; AInLayout: Boolean);
begin
  Self.AddRecord(0, 'TOLERANCE');
  Self.AddCommonProp(AEntity, 'AcDbFcf', AOwnerHandle, AInLayout);
  self.AddRecord(3, Self.Document.DimStyles.Standard.Name);

  Self.AddRecord(10, AEntity.PositionX);
  Self.AddRecord(20, AEntity.PositionY);
  Self.AddRecord(30, 0);
  Self.AddRecord(1, AEntity.Contents);

  if NotEqual(AEntity.Rotation, 0) then
  begin
    Self.AddRecord(11, UdMath.CosD(AEntity.Rotation));
    Self.AddRecord(21, UdMath.SinD(AEntity.Rotation));
    Self.AddRecord(31, 0);
  end;
end;


procedure TUdDxfWriteEntites.AddDimCustomProp(AEntity: TUdDimension);
var
  _RecordList: TList;

  procedure _AddRecord(ACode: Integer; AValue: string; AKind: Integer); overload;
  var
    LRec: PUdDxfRecord;
  begin
    LRec := New(PUdDxfRecord);
    LRec^.Code := ACode;
    LRec^.Value := AValue;
    LRec^.Kind  := AKind;
    _RecordList.Add(LRec);
  end;

  procedure _AddRecord(ACode: Integer; AValue: Double; AKind: Integer); overload;
  var
    LRec: PUdDxfRecord;
  begin
    LRec := New(PUdDxfRecord);
    LRec^.Code := ACode;
    LRec^.Value := FloatToStr(AValue);
    LRec^.Kind  := AKind;
    _RecordList.Add(LRec);
  end;

  procedure _AddRecordsToFile();
  var
    I: Integer;
  begin
    if _RecordList.Count <= 0 then Exit;

    Self.AddRecord(1001, 'ACAD');
    Self.AddRecord(1000, 'DSTYLE');
    Self.AddRecord(1002, '{');

    for I := 0 to _RecordList.Count - 1 do
    begin
      Self.AddRecord(1070, IntToStr(PUdDxfRecord(_RecordList[I])^.Code));

      Self.AddRecord(
        PUdDxfRecord(_RecordList[I])^.Kind,
        PUdDxfRecord(_RecordList[I])^.Value
      );
    end;
    Self.AddRecord(1002, '}');
  end;



var
  I: Integer;
  N: Integer;
  LStr: string;
  LFloat: Float;
  LDimStyle: TUdDimStyle;
  LSperateArrow: Boolean;
begin
//  Exit; //===>>>
  if not Assigned(AEntity) or not Assigned(AEntity.DimStyle) then Exit;

  LDimStyle := AEntity.DimStyle;

  _RecordList := TList.Create();
  try

    if (LDimStyle.AltUnitsProp.Suffix <> AEntity.AltUnitsProp.Suffix) or
       (LDimStyle.AltUnitsProp.AltPlacement <> AEntity.AltUnitsProp.AltPlacement) then
    begin
      LStr := '';
      if AEntity.AltUnitsProp.AltPlacement = apBelowPrimary then LStr := '\X';

      LStr := LStr + AEntity.UnitsProp.Prefix;
      if AEntity.UnitsProp.Suffix <> '' then LStr := LStr + '<>' + AEntity.UnitsProp.Suffix;

      _AddRecord(3, LStr, 1000); // DIMPOST
    end;
    

    if (LDimStyle.AltUnitsProp.Prefix <> AEntity.AltUnitsProp.Prefix) then
    begin    
      LStr := AEntity.AltUnitsProp.Prefix;
      if AEntity.AltUnitsProp.Suffix <> '' then LStr := LStr + '<>' + AEntity.AltUnitsProp.Suffix;

      _AddRecord(4, LStr, 1000); // DIMAPOST
    end;

    if (LDimStyle.ArrowsProp.ArrowSize <> AEntity.ArrowsProp.ArrowSize) then
      _AddRecord(41, AEntity.ArrowsProp.ArrowSize, 1040);        // DIMASZ

    if (LDimStyle.LinesProp.ExtOriginOffset <> AEntity.LinesProp.ExtOriginOffset) then
      _AddRecord(42, AEntity.LinesProp.ExtOriginOffset, 1040);   // DIMEXO
      
    if (LDimStyle.LinesProp.BaselineSpacing <> AEntity.LinesProp.BaselineSpacing) then
      _AddRecord(43, AEntity.LinesProp.BaselineSpacing, 1040);   // DIMDLI

    if (LDimStyle.LinesProp.ExtBeyondDimLines <> AEntity.LinesProp.ExtBeyondDimLines) then
      _AddRecord(44, AEntity.LinesProp.ExtBeyondDimLines, 1040); // DIMEXE

    if (LDimStyle.UnitsProp.RoundOff <> AEntity.UnitsProp.RoundOff) then
      _AddRecord(45, AEntity.UnitsProp.RoundOff, 1040);          // DIMRND

    {
    _AddRecord(46, 0);                                 // DIMDLE  尺寸线超出尺寸界线的距离
    _AddRecord(47, 0);                                 // DIMTP   上偏差
    _AddRecord(48, 0);                                 // DIMTM   下偏差
    }

    if (LDimStyle.TextProp.TextHeight <> AEntity.TextProp.TextHeight) then
      _AddRecord(140, AEntity.TextProp.TextHeight, 1040);        // DIMTXT

    if (LDimStyle.ArrowsProp.MarkSize <> AEntity.ArrowsProp.MarkSize) then
      _AddRecord(141, AEntity.ArrowsProp.MarkSize, 1040);        // DIMCEN


    {
    _AddRecord(142, 0);                                // DIMTSZ  替代箭头的小斜线尺寸
    }

    if (LDimStyle.AltUnitsProp.MeasurementScale <> AEntity.AltUnitsProp.MeasurementScale) then
      _AddRecord(143, AEntity.AltUnitsProp.MeasurementScale, 1040);       // DIMALTF

    if (LDimStyle.UnitsProp.MeasurementScale <> AEntity.UnitsProp.MeasurementScale) then
      _AddRecord(144, AEntity.UnitsProp.MeasurementScale, 1040);            // DIMLFAC

    {
    _AddRecord(145, 0);                                // DIMTVP  标注文字的垂直位置
    _AddRecord(146, '1.0');                                // DIMTFAC 公差对象的文字高度
    }

    if (LDimStyle.TextProp.DrawFrame <> AEntity.TextProp.DrawFrame) or
       (LDimStyle.TextProp.OffsetFromDimLine <> AEntity.TextProp.OffsetFromDimLine) then
    begin
      LFloat := AEntity.TextProp.OffsetFromDimLine;
      if AEntity.TextProp.DrawFrame then LFloat := -LFloat;
      _AddRecord(147, LFloat, 1040);                               // DIMGAP
    end;

    {
    _AddRecord(71, '0');  // DIMTOL  公差的标注方式 OFF
    _AddRecord(72, '0');  // DIMLIM  生成极限尺寸  OFF
    }

    if (LDimStyle.TextProp.InsideAlign <> AEntity.TextProp.InsideAlign) then
    begin
      if AEntity.TextProp.InsideAlign  then _AddRecord(73, '0', 1070) else _AddRecord(73, '1', 1070); //DIMTIH
    end;

    if (LDimStyle.TextProp.OutsideAlign <> AEntity.TextProp.OutsideAlign) then
    begin
      if AEntity.TextProp.OutsideAlign then _AddRecord(74, '0', 1070) else _AddRecord(74, '1', 1070); //DIMTOH
    end;

    if (LDimStyle.LinesProp.ExtSuppressLine1 <> AEntity.LinesProp.ExtSuppressLine1) then
    begin
      if AEntity.LinesProp.ExtSuppressLine1 then _AddRecord(75, '1', 1070) else _AddRecord(75, '0', 1070); //DIMSE1  \
    end;

    if (LDimStyle.LinesProp.ExtSuppressLine2 <> AEntity.LinesProp.ExtSuppressLine2) then
    begin
      if AEntity.LinesProp.ExtSuppressLine2 then _AddRecord(76, '1', 1070) else _AddRecord(76, '0', 1070); //DIMSE2
    end;

    if (LDimStyle.TextProp.VerticalPosition <> AEntity.TextProp.VerticalPosition) then
      _AddRecord(77, IntToStr(Ord(AEntity.TextProp.VerticalPosition)) , 1070);   //DIMTAD

    if (LDimStyle.UnitsProp.SuppressLeading <> AEntity.UnitsProp.SuppressLeading) or
       (LDimStyle.UnitsProp.SuppressTrailing <> AEntity.UnitsProp.SuppressTrailing) then
    begin
      if AEntity.UnitsProp.SuppressLeading and AEntity.UnitsProp.SuppressTrailing then LStr := '12' else
      if AEntity.UnitsProp.SuppressTrailing  then LStr := '8' else
      if AEntity.UnitsProp.SuppressLeading   then LStr := '4' else LStr := '0';

      _AddRecord(78, LStr, 1070);   //DIMZIN   控制消零处理
    end;

    if (LDimStyle.AltUnitsProp.Precision <> AEntity.AltUnitsProp.Precision) then  // DIMALTD 换算单位小数位
      _AddRecord(171, IntToStr(AEntity.AltUnitsProp.Precision), 1070);
    {
    _AddRecord(172, '0');  // DIMTOFL 强制尺寸线置于尺寸界线之间 OFF
    _AddRecord(175, '0');  // DIMSOXD  隐藏尺寸界线之外的尺寸线 OFF
    }

    if (DxfFixColor(LDimStyle.LinesProp.Color) <> DxfFixColor(AEntity.LinesProp.Color)) then
      _AddRecord(176, DxfFixColor(AEntity.LinesProp.Color), 1070);     // DIMCLRD

    if (DxfFixColor(LDimStyle.LinesProp.ExtColor) <> DxfFixColor(AEntity.LinesProp.ExtColor)) then
      _AddRecord(177, DxfFixColor(AEntity.LinesProp.ExtColor), 1070);  // DIMCLRE

    if (DxfFixColor(LDimStyle.TextProp.TextColor) <> DxfFixColor(AEntity.TextProp.TextColor)) then
      _AddRecord(178, DxfFixColor(AEntity.TextProp.TextColor), 1070);  // DIMCLRT


    {
    _AddRecord(79, '0');                  // DIMAZIN  控制角度标注的消零处理
    _AddRecord(148, 0);               // DIMALTRND 舍入换算标注单位
    }

    if (LDimStyle.UnitsProp.AngPrecision <> AEntity.UnitsProp.AngPrecision) then
      _AddRecord(179, IntToStr(AEntity.UnitsProp.AngPrecision), 1070);  // DIMADEC

    if (LDimStyle.UnitsProp.Precision <> AEntity.UnitsProp.Precision) then
      _AddRecord(271, IntToStr(AEntity.UnitsProp.Precision), 1070);     // DIMDEC

    {
    _AddRecord(272, IntToStr(2));                                 // DIMTDEC Total Precision
    }

    if (LDimStyle.AltUnitsProp.UnitFormat <> AEntity.AltUnitsProp.UnitFormat) then
      _AddRecord(273, IntToStr(Ord(AEntity.AltUnitsProp.UnitFormat) + 1), 1070); // DIMALTU

    if (LDimStyle.UnitsProp.AngUnitFormat <> AEntity.UnitsProp.AngUnitFormat) then
      _AddRecord(275, IntToStr(Ord(AEntity.UnitsProp.AngUnitFormat)), 1070);     // DIMAUNIT

    {
    _AddRecord(274, '3');                                                  // DIMALTTD   设置标注换算单位公差值小数位的位数
    _AddRecord(276, '0');                                                  // DIMFRAC  分数格式
    }

    if (LDimStyle.UnitsProp.UnitFormat <> AEntity.UnitsProp.UnitFormat) then
      _AddRecord(277, IntToStr(Ord(AEntity.UnitsProp.UnitFormat) + 1), 1070);   // DIMLUNIT  线性单位的格式

    if (LDimStyle.UnitsProp.Decimal <> AEntity.UnitsProp.Decimal) then
      _AddRecord(278, Ord(AEntity.UnitsProp.Decimal), 1070);                    // DIMDSEP  小数分隔符

    {
    _AddRecord(279, '0');                                                 // DIMTMOVE 标注文字的移动规则
    }


    if (LDimStyle.TextProp.HorizontalPosition <> AEntity.TextProp.HorizontalPosition) then
    begin
      N := Ord(AEntity.TextProp.HorizontalPosition);
      if N >= 3 then N := 0;
      _AddRecord(280, IntToStr(N), 1070);                                         // DIMJUST 控制尺寸线上标注文字的水平对齐
    end;

    if (LDimStyle.LinesProp.SuppressLine1 <> AEntity.LinesProp.SuppressLine1) then
    begin
      if AEntity.LinesProp.SuppressLine1 then _AddRecord(281, '1', 1070) else _AddRecord(281, '0', 1070); //DIMSD1
    end;

    if (LDimStyle.LinesProp.SuppressLine2 <> AEntity.LinesProp.SuppressLine2) then
    begin
      if AEntity.LinesProp.SuppressLine2 then _AddRecord(282, '1', 1070) else _AddRecord(282, '0', 1070); //DIMSD2
    end;

    {
    _AddRecord(283, '0');      // DIMTOLJ  公差的垂直对正方式
    _AddRecord(284, '8');      // DIMTZIN  控制公差的消零处理
    _AddRecord(285, '0');      // DIMALTZ  控制换算单位的消零处理
    _AddRecord(286, '0');      // DIMALTTZ 控制换算公差的消零处理

    _AddRecord(288, '0');      // DIMUPT   控制用户定位文字  OFF
    _AddRecord(289, '3');      // DIMATFIT 箭头及文字自适应调整
    }


    {
    _AddRecord(340, '');      // DIMTXSTY 文字样式 (STYLE的句柄)
    _AddRecord(341, '');      // DIMLDRBLK 引线箭头块名称 (BLOCK的句柄)
    }

    LSperateArrow := False;
    
    if (LDimStyle.ArrowsProp.ArrowLeader <> AEntity.ArrowsProp.ArrowLeader) then
    begin
      LStr := GetDimArrowName(AEntity.ArrowsProp.ArrowLeader);  // DIMBLK  箭头块名称       (BLOCK的句柄)
      if LStr <> '' then
      begin
        LStr := '_' + LStr;
        LStr := Self.BlockHandles.GetValue(LStr);
        if LStr <> '' then _AddRecord(342, LStr, 1005);

        LSperateArrow := True;
      end;
    end;

    if (LDimStyle.ArrowsProp.ArrowFirst <> AEntity.ArrowsProp.ArrowFirst) then
    begin
      LStr := GetDimArrowName(AEntity.ArrowsProp.ArrowFirst);  // DIMBLK1 第一箭头块名称   (BLOCK的句柄)
      if LStr <> '' then
      begin
        LStr := '_' + LStr;
        LStr := Self.BlockHandles.GetValue(LStr);
        if LStr <> '' then _AddRecord(343, LStr, 1005);

        LSperateArrow := True;
      end;
    end;    

    if (LDimStyle.ArrowsProp.ArrowSecond <> AEntity.ArrowsProp.ArrowSecond) then
    begin
      LStr := GetDimArrowName(AEntity.ArrowsProp.ArrowSecond);  // DIMBLK2 第二箭头块名称   (BLOCK的句柄)
      if LStr <> '' then
      begin
        LStr := '_' + LStr;
        LStr := Self.BlockHandles.GetValue(LStr);
        if LStr <> '' then _AddRecord(344, LStr, 1005);

        LSperateArrow := True;
      end;
    end;

    if LSperateArrow then
      _AddRecord(173, '1', 1070);  // DIMSAH  分离箭头块 OFF
        

    if (LDimStyle.LinesProp.LineWeight <> AEntity.LinesProp.LineWeight) then
      _AddRecord(371, IntToStr(AEntity.LinesProp.LineWeight), 1070);      //DIMLWD  尺寸线和引线线宽

    if (LDimStyle.LinesProp.ExtLineWeight <> AEntity.LinesProp.ExtLineWeight) then
      _AddRecord(372, IntToStr(AEntity.LinesProp.ExtLineWeight), 1070);   //DIMLWE  尺寸界线线宽

    if _RecordList.Count > 0 then
      _AddRecordsToFile();
  finally
    for I := _RecordList.Count - 1 downto 0 do Dispose(PUdDxfRecord(_RecordList[I]));
    _RecordList.Free;
  end;
end;


procedure TUdDxfWriteEntites.AddDimension(AEntity: TUdDimAligned; AOwnerHandle: string; AInLayout: Boolean);
var
  LPnt: TPoint2D;
begin
  if AEntity.BlockName = '' then
  begin
    if Assigned(AEntity) then
    Exit;
  end;
  
  Self.AddRecord(0, 'DIMENSION');
  Self.AddCommonProp(AEntity, 'AcDbDimension', AOwnerHandle, AInLayout);

  Self.AddRecord(2, AEntity.BlockName);

  Self.AddRecord(10, AEntity.DimLine2Point.X);
  Self.AddRecord(20, AEntity.DimLine2Point.Y);
  Self.AddRecord(30, 0);

  LPnt := AEntity.DimTextPoint;

  if IsValidPoint(LPnt) then
  begin
    Self.AddRecord(11, LPnt.X);
    Self.AddRecord(21, LPnt.Y);
  end
  else begin
    Self.AddRecord(11, AEntity.TextPoint.X);
    Self.AddRecord(21, AEntity.TextPoint.Y);
  end;
  Self.AddRecord(31, 0);


  if AEntity.TextProp.HorizontalPosition = htpCustom then
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 160))
  else
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 32));


  if AEntity.TextOverride <> '' then
    Self.AddRecord(1, AEntity.TextOverride);
        
  Self.AddRecord(71, '5');

  if Assigned(AEntity.DimStyle) then
    Self.AddRecord(3, AEntity.DimStyle.Name);

  Self.AddRecord(100, 'AcDbAlignedDimension');

  Self.AddRecord(13, AEntity.ExtLine1Point.X);
  Self.AddRecord(23, AEntity.ExtLine1Point.Y);
  Self.AddRecord(33, 0);

  Self.AddRecord(14, AEntity.ExtLine2Point.X);
  Self.AddRecord(24, AEntity.ExtLine2Point.Y);
  Self.AddRecord(34, 0);

  if AEntity.InheritsFrom(TUdDimRotated) then
  begin
    Self.AddRecord(50, TUdDimRotated(AEntity).Rotation );
    Self.AddRecord(100, 'AcDbRotatedDimension');
  end;

  AddDimCustomProp(AEntity);
end;

procedure TUdDxfWriteEntites.AddDimension(AEntity: TUdDimRotated; AOwnerHandle: string; AInLayout: Boolean);
begin
  Self.AddDimension(TUdDimAligned(AEntity), AOwnerHandle, AInLayout);
end;

procedure TUdDxfWriteEntites.AddDimension(AEntity: TUdDimArcLength; AOwnerHandle: string; AInLayout: Boolean);
var
  LRad: Float;
  LPnt: TPoint2D;
  LAng1, LAng2: Float;
  LPnt1, LPnt2: TPoint2D;
begin
  if AEntity.BlockName = '' then
  begin
    if Assigned(AEntity) then
    Exit;
  end;
  
  Self.AddRecord(0, 'ARC_DIMENSION');
  Self.AddCommonProp(AEntity, 'AcDbDimension', AOwnerHandle, AInLayout);

  Self.AddRecord(2, AEntity.BlockName);

  Self.AddRecord(10, AEntity.ArcPoint.X);
  Self.AddRecord(20, AEntity.ArcPoint.Y);
  Self.AddRecord(30, 0);

  LPnt := AEntity.DimTextPoint;

  if IsValidPoint(LPnt) then
  begin
    Self.AddRecord(11, LPnt.X);
    Self.AddRecord(21, LPnt.Y);
  end
  else begin
    Self.AddRecord(11, AEntity.TextPoint.X);
    Self.AddRecord(21, AEntity.TextPoint.Y);
  end;
  Self.AddRecord(31, 0);


  if AEntity.TextProp.HorizontalPosition = htpCustom then
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 160))
  else
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 32));


  if AEntity.TextOverride <> '' then
    Self.AddRecord(1, AEntity.TextOverride);
        
  Self.AddRecord(71, '5');

  if Assigned(AEntity.DimStyle) then
    Self.AddRecord(3, AEntity.DimStyle.Name);

  Self.AddRecord(100, 'AcDbArcDimension');

  Self.AddRecord(13, AEntity.ExtLine1Point.X);
  Self.AddRecord(23, AEntity.ExtLine1Point.Y);
  Self.AddRecord(33, 0);

  Self.AddRecord(14, AEntity.ExtLine2Point.X);
  Self.AddRecord(24, AEntity.ExtLine2Point.Y);
  Self.AddRecord(34, 0);

  Self.AddRecord(15, AEntity.CenterPoint.X);
  Self.AddRecord(25, AEntity.CenterPoint.Y);
  Self.AddRecord(35, 0);


  //-----------------------------------------

  LRad := Distance(AEntity.CenterPoint, AEntity.ArcPoint);
  LAng1 := GetAngle(AEntity.CenterPoint, AEntity.ExtLine1Point);
  LAng2 := GetAngle(AEntity.CenterPoint, AEntity.ExtLine2Point);
  LPnt1 := ShiftPoint(AEntity.CenterPoint, LAng1, LRad);
  LPnt2 := ShiftPoint(AEntity.CenterPoint, LAng1, LRad);

//  Self.AddRecord(70, '0');
  Self.AddRecord(40, DegToRad(LAng1));
  Self.AddRecord(41, DegToRad(LAng2));
  Self.AddRecord(71, '0');

  Self.AddRecord(16, LPnt1.X);
  Self.AddRecord(26, LPnt1.Y);
  Self.AddRecord(36, 0);

  Self.AddRecord(17, LPnt2.X);
  Self.AddRecord(27, LPnt2.Y);
  Self.AddRecord(37, 0);

  AddDimCustomProp(AEntity);
end;

procedure TUdDxfWriteEntites.AddDimension(AEntity: TUdDim3PointAngular; AOwnerHandle: string; AInLayout: Boolean);
var
  LPnt: TPoint2D;
begin
  if AEntity.BlockName = '' then
  begin
    if Assigned(AEntity) then
    Exit;
  end;

  Self.AddRecord(0, 'DIMENSION');
  Self.AddCommonProp(AEntity, 'AcDbDimension', AOwnerHandle, AInLayout);

  Self.AddRecord(2, AEntity.BlockName);

  Self.AddRecord(10, AEntity.ArcPoint.X);
  Self.AddRecord(20, AEntity.ArcPoint.Y);
  Self.AddRecord(30, 0);

  LPnt := AEntity.DimTextPoint;

  if IsValidPoint(LPnt) then
  begin
    Self.AddRecord(11, LPnt.X);
    Self.AddRecord(21, LPnt.Y);
  end
  else begin
    Self.AddRecord(11, AEntity.TextPoint.X);
    Self.AddRecord(21, AEntity.TextPoint.Y);
  end;
  Self.AddRecord(31, 0);


  if AEntity.TextProp.HorizontalPosition = htpCustom then
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 160))
  else
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 32));

  if AEntity.TextOverride <> '' then
    Self.AddRecord(1, AEntity.TextOverride);
        
  Self.AddRecord(71, '5');

  if Assigned(AEntity.DimStyle) then
    Self.AddRecord(3, AEntity.DimStyle.Name);

  Self.AddRecord(100, 'AcDb3PointAngularDimension');

  Self.AddRecord(13, AEntity.ExtLine1Point.X);
  Self.AddRecord(23, AEntity.ExtLine1Point.Y);
  Self.AddRecord(33, 0);

  Self.AddRecord(14, AEntity.ExtLine2Point.X);
  Self.AddRecord(24, AEntity.ExtLine2Point.Y);
  Self.AddRecord(34, 0);

  Self.AddRecord(15, AEntity.CenterPoint.X);
  Self.AddRecord(25, AEntity.CenterPoint.Y);
  Self.AddRecord(35, 0);


  AddDimCustomProp(AEntity);
end;

procedure TUdDxfWriteEntites.AddDimension(AEntity: TUdDim2LineAngular; AOwnerHandle: string; AInLayout: Boolean);
var
  LPnt: TPoint2D;
begin
  if AEntity.BlockName = '' then
  begin
    if Assigned(AEntity) then
    Exit;
  end;

  Self.AddRecord(0, 'DIMENSION');
  Self.AddCommonProp(AEntity, 'AcDbDimension', AOwnerHandle, AInLayout);

  Self.AddRecord(2, AEntity.BlockName);

  Self.AddRecord(10, AEntity.ExtLine2StartPoint.X);
  Self.AddRecord(20, AEntity.ExtLine2StartPoint.Y);
  Self.AddRecord(30, 0);

  LPnt := AEntity.DimTextPoint;

  if IsValidPoint(LPnt) then
  begin
    Self.AddRecord(11, LPnt.X);
    Self.AddRecord(21, LPnt.Y);
  end
  else begin
    Self.AddRecord(11, AEntity.TextPoint.X);
    Self.AddRecord(21, AEntity.TextPoint.Y);
  end;
  Self.AddRecord(31, 0);


  if AEntity.TextProp.HorizontalPosition = htpCustom then
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 160))
  else
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 32));

  if AEntity.TextOverride <> '' then
    Self.AddRecord(1, AEntity.TextOverride);
        
  Self.AddRecord(71, '5');

  if Assigned(AEntity.DimStyle) then
    Self.AddRecord(3, AEntity.DimStyle.Name);

  Self.AddRecord(100, 'AcDb2LineAngularDimension');

  Self.AddRecord(13, AEntity.ExtLine1StartPoint.X);
  Self.AddRecord(23, AEntity.ExtLine1StartPoint.Y);
  Self.AddRecord(33, 0);

  Self.AddRecord(14, AEntity.ExtLine1EndPoint.X);
  Self.AddRecord(24, AEntity.ExtLine1EndPoint.Y);
  Self.AddRecord(34, 0);

  Self.AddRecord(15, AEntity.ExtLine2EndPoint.X);
  Self.AddRecord(25, AEntity.ExtLine2EndPoint.Y);
  Self.AddRecord(35, 0);

  Self.AddRecord(16, AEntity.ArcPoint.X);
  Self.AddRecord(26, AEntity.ArcPoint.Y);
  Self.AddRecord(36, 0);

  AddDimCustomProp(AEntity);
end;

procedure TUdDxfWriteEntites.AddDimension(AEntity: TUdDimRadialLarge; AOwnerHandle: string; AInLayout: Boolean);
var
  LPnt: TPoint2D;
begin
  if AEntity.BlockName = '' then
  begin
    if Assigned(AEntity) then
    Exit;
  end;

  Self.AddRecord(0, 'LARGE_RADIAL_DIMENSION');
  Self.AddCommonProp(AEntity, 'AcDbDimension', AOwnerHandle, AInLayout);

  Self.AddRecord(2, AEntity.BlockName);

  Self.AddRecord(10, AEntity.Center.X);
  Self.AddRecord(20, AEntity.Center.Y);
  Self.AddRecord(30, 0);

  LPnt := AEntity.TextPoint;

  if IsValidPoint(LPnt) then
  begin
    Self.AddRecord(11, LPnt.X);
    Self.AddRecord(21, LPnt.Y);
    Self.AddRecord(31, 0);
  end;


//  Self.AddRecord(70, '169');
  if AEntity.TextProp.HorizontalPosition = htpCustom then
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 160))
  else
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 32));

  if AEntity.TextOverride <> '' then
    Self.AddRecord(1, AEntity.TextOverride);
        
  Self.AddRecord(71, '5');
  Self.AddRecord(42, AEntity.Measurement);

  if Assigned(AEntity.DimStyle) then
    Self.AddRecord(3, AEntity.DimStyle.Name);

  Self.AddRecord(100, 'AcDbRadialDimensionLarge');

  Self.AddRecord(13, AEntity.OverrideCenter.X);
  Self.AddRecord(23, AEntity.OverrideCenter.Y);
  Self.AddRecord(33, 0);

  LPnt := AEntity.GripJogPoint;
  if not IsValidPoint(LPnt) then LPnt := AEntity.JogPoint;

  Self.AddRecord(14, LPnt.X);
  Self.AddRecord(24, LPnt.Y);
  Self.AddRecord(34, 0);

  Self.AddRecord(15, AEntity.ChordPoint.X);
  Self.AddRecord(25, AEntity.ChordPoint.Y);
  Self.AddRecord(35, 0);

  Self.AddRecord(40, 0);

  AddDimCustomProp(AEntity);
end;

procedure TUdDxfWriteEntites.AddDimension(AEntity: TUdDimRadial; AOwnerHandle: string; AInLayout: Boolean);
var
  LAng: Float;
  LPnt: TPoint2D;
begin
  if AEntity.BlockName = '' then
  begin
    if Assigned(AEntity) then
    Exit;
  end;

  Self.AddRecord(0, 'DIMENSION');
  Self.AddCommonProp(AEntity, 'AcDbDimension', AOwnerHandle, AInLayout);

  Self.AddRecord(2, AEntity.BlockName);

  LAng := GetAngle(AEntity.Center, AEntity.ChordPoint);
  
  if AEntity.InheritsFrom(TUdDimDiametric) then
  begin
    LPnt := ShiftPoint(AEntity.Center, FixAngle(LAng+180), Distance(AEntity.Center, AEntity.ChordPoint));
    
    Self.AddRecord(10, LPnt.X);
    Self.AddRecord(20, LPnt.Y);
    Self.AddRecord(30, 0);
  end
  else begin
    Self.AddRecord(10, AEntity.Center.X);
    Self.AddRecord(20, AEntity.Center.Y);
    Self.AddRecord(30, 0);
  end;

  LPnt := ShiftPoint(AEntity.ChordPoint, LAng, AEntity.LeaderLen);

  Self.AddRecord(11, LPnt.X);
  Self.AddRecord(21, LPnt.Y);
  Self.AddRecord(31, 0);

  if AEntity.TextProp.HorizontalPosition = htpCustom then
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 160))
  else
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 32));

  if AEntity.TextOverride <> '' then
    Self.AddRecord(1, AEntity.TextOverride);
        
  Self.AddRecord(71, '5');
//  Self.AddRecord(42, FloatToStr(AEntity.Measurement));

  if Assigned(AEntity.DimStyle) then
    Self.AddRecord(3, AEntity.DimStyle.Name);

  if AEntity.InheritsFrom(TUdDimDiametric) then
    Self.AddRecord(100, 'AcDbDiametricDimension')
  else
    Self.AddRecord(100, 'AcDbRadialDimension');

  Self.AddRecord(15, AEntity.ChordPoint.X);
  Self.AddRecord(25, AEntity.ChordPoint.Y);
  Self.AddRecord(35, 0);

  Self.AddRecord(40, 0);

  AddDimCustomProp(AEntity);
end;

procedure TUdDxfWriteEntites.AddDimension(AEntity: TUdDimDiametric; AOwnerHandle: string; AInLayout: Boolean);
begin
  Self.AddDimension(TUdDimRadial(AEntity), AOwnerHandle, AInLayout);
end;

procedure TUdDxfWriteEntites.AddDimension(AEntity: TUdDimOrdinate; AOwnerHandle: string; AInLayout: Boolean);
var
  LPnt: TPoint2D;
begin
  if AEntity.BlockName = '' then
  begin
    if Assigned(AEntity) then
    Exit;
  end;

  Self.AddRecord(0, 'DIMENSION');
  Self.AddCommonProp(AEntity, 'AcDbDimension', AOwnerHandle, AInLayout);

  Self.AddRecord(2, AEntity.BlockName);

  Self.AddRecord(10, AEntity.OriginPoint.X);
  Self.AddRecord(20, AEntity.OriginPoint.Y);
  Self.AddRecord(30, 0);


  LPnt := AEntity.DimTextPoint;

  if IsValidPoint(LPnt) then
  begin
    Self.AddRecord(11, LPnt.X);
    Self.AddRecord(21, LPnt.Y);
    Self.AddRecord(31, 0);
  end;

  if AEntity.UseXAxis then
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 32 + 64))
  else
    Self.AddRecord(70, IntToStr(AEntity.DimTypeID + 32));

  if AEntity.TextOverride <> '' then
    Self.AddRecord(1, AEntity.TextOverride);
        
  Self.AddRecord(71, '5');


  if Assigned(AEntity.DimStyle) then
    Self.AddRecord(3, AEntity.DimStyle.Name);

  Self.AddRecord(100, 'AcDbOrdinateDimension');

  Self.AddRecord(13, AEntity.DefinitionPoint.X);
  Self.AddRecord(23, AEntity.DefinitionPoint.Y);
  Self.AddRecord(33, 0);

  Self.AddRecord(14, AEntity.LeaderEndPoint.X);
  Self.AddRecord(24, AEntity.LeaderEndPoint.Y);
  Self.AddRecord(34, 0);

  AddDimCustomProp(AEntity);
end;



procedure TUdDxfWriteEntites.AddViewport(ALayout: TObject; ABlockName, AOwnerHandle: string; AEntitiesSection, AVPortMode: Boolean);
var
  LHandle: string;
  LLayout: TUdLayout;
  LBound: TRect2D;
  LCenter: TPoint2D;
begin
  if not Assigned(ALayout) or not ALayout.InheritsFrom(TUdLayout) then Exit;

  LLayout := TUdLayout(ALayout);


  if AVPortMode then
    LBound := LLayout.ViewPort.BoundsRect //Rect2D(LLayout.PaperLimMin, LLayout.PaperLimMax)
  else
    LBound := LLayout.ViewBound;

  LCenter.X := (LBound.X1 + LBound.X2) / 2;
  LCenter.Y := (LBound.Y1 + LBound.Y2) / 2;


  LHandle := Self.NewHandle();

  Self.AddRecord(0, 'VIEWPORT');
  Self.AddRecord(5, LHandle);
  Self.ViewportHandles.Add(ABlockName, LHandle);

  Self.AddRecord(330, AOwnerHandle);
  Self.AddRecord(100, 'AcDbEntity');
  Self.AddRecord(67, '1');
  Self.AddRecord(8, '0');
  Self.AddRecord(100, 'AcDbViewport');

  Self.AddRecord(10, LCenter.X);
  Self.AddRecord(20, LCenter.Y);
  Self.AddRecord(30, 0);

  Self.AddRecord(40, Abs(LBound.X2 - LBound.X1) );
  Self.AddRecord(41, Abs(LBound.Y2 - LBound.Y1) );  {'LLayout.ViewSize}


  if AVPortMode then
  begin
    Self.AddRecord(68, '2');
    Self.AddRecord(69, '2');
  end
  else begin
    Self.AddRecord(68, '1');
    Self.AddRecord(69, '1');
  end;


  if AVPortMode then
  begin
    LBound := LLayout.ViewPort.ViewBound;
    LCenter.X := (LBound.X1 + LBound.X2) / 2;
    LCenter.Y := (LBound.Y1 + LBound.Y2) / 2;
  end;
  
  Self.AddRecord(12, LCenter.X);
  Self.AddRecord(22, LCenter.Y);

  Self.AddRecord(13, LLayout.Drafting.SnapGrid.Base.X);
  Self.AddRecord(23, LLayout.Drafting.SnapGrid.Base.Y);
  Self.AddRecord(14, LLayout.Drafting.SnapGrid.SnapSpace.X);
  Self.AddRecord(24, LLayout.Drafting.SnapGrid.SnapSpace.Y);
  Self.AddRecord(15, LLayout.Drafting.SnapGrid.GridSpace.X);
  Self.AddRecord(25, LLayout.Drafting.SnapGrid.GridSpace.Y);
  Self.AddRecord(16, 0);
  Self.AddRecord(26, 0);
  Self.AddRecord(36, 1);
  Self.AddRecord(17, 0);
  Self.AddRecord(27, 0);
  Self.AddRecord(37, 0);
  Self.AddRecord(42, 50);
  Self.AddRecord(43, 0);
  Self.AddRecord(44, 0);
  Self.AddRecord(45, Abs(LBound.Y2 - LBound.Y1) ); {LLayout.ViewSize}
  Self.AddRecord(50, 0); //捕捉角度
  Self.AddRecord(51, 0);
  Self.AddRecord(72, '1000');
  if AVPortMode then Self.AddRecord(90, '32864') else Self.AddRecord(90, '32800');
  Self.AddRecord(1, '');
  Self.AddRecord(281, '0');
  Self.AddRecord(71, '1');
  Self.AddRecord(74, '0');
  Self.AddRecord(110, 0);
  Self.AddRecord(120, 0);
  Self.AddRecord(130, 0);
  Self.AddRecord(111, 1);
  Self.AddRecord(121, 0);
  Self.AddRecord(131, 0);
  Self.AddRecord(112, 0);
  Self.AddRecord(122, 1);
  Self.AddRecord(132, 0);
  Self.AddRecord(79, '0');
  Self.AddRecord(146, 0);
  Self.AddRecord(170, '0');
end;



function TUdDxfWriteEntites.AddEntities(AEntities: TList; AOwnerHandle: string; AInLayout: Boolean): Boolean;
var
  I, LPos: Integer;
  LEntity: TUdEntity;
  LDoc: TUdDocument;
begin
  Result := False;
  if not Assigned(AEntities) then Exit;

  LDoc := Self.GetDocument();

  for I := 0 to AEntities.Count - 1 do
  begin
    LEntity := AEntities[I];
    if not Assigned(LEntity) then Continue;

    if LEntity.InheritsFrom(TUdLine)      then Self.AddLine(TUdLine(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdRay)       then Self.AddRay(TUdRay(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdXLine)     then Self.AddXLine(TUdXLine(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdCircle)    then Self.AddCircle(TUdCircle(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdArc)       then Self.AddArc(TUdArc(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdPolyline)  then Self.AddPolyline(TUdPolyline(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdEllipse)   then Self.AddEllipse(TUdEllipse(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdSpline)    then Self.AddSPline(TUdSpline(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdPoint)     then Self.AddPoint(TUdPoint(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdText)      then Self.AddText(TUdText(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdSolid)     then Self.AddSolid(TUdSolid(LEntity), AOwnerHandle, AInLayout) else

    if LEntity.InheritsFrom(TUdLeader)    then Self.AddLeader(TUdLeader(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdTolerance) then Self.AddTolerance(TUdTolerance(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdHatch)     then Self.AddHatch(TUdHatch(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdInsert)    then Self.AddInsert(TUdInsert(LEntity), AOwnerHandle, AInLayout) else

    if LEntity.InheritsFrom(TUdDimAligned)       then Self.AddDimension(TUdDimAligned(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdDimRotated)       then Self.AddDimension(TUdDimRotated(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdDimArcLength)     then Self.AddDimension(TUdDimArcLength(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdDim3PointAngular) then Self.AddDimension(TUdDim3PointAngular(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdDim2LineAngular)  then Self.AddDimension(TUdDim2LineAngular(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdDimRadialLarge)   then Self.AddDimension(TUdDimRadialLarge(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdDimRadial)        then Self.AddDimension(TUdDimRadial(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdDimDiametric)     then Self.AddDimension(TUdDimDiametric(LEntity), AOwnerHandle, AInLayout) else
    if LEntity.InheritsFrom(TUdDimOrdinate)      then Self.AddDimension(TUdDimOrdinate(LEntity), AOwnerHandle, AInLayout) ;//else

//  if LEntity.InheritsFrom(TUdMLine)     then Self.AddMLine(TUdMLine(LEntity), AOwnerHandle, AInLayout) else
//  if LEntity.InheritsFrom(TUdMLeader)   then Self.AddMLeader(TUdMLeader(LEntity), AOwnerHandle, AInLayout) else
//  if LEntity.InheritsFrom(TUdImage)     then Self.AddImage(TUdImage(LEntity), AOwnerHandle, AInLayout) else
//  if LEntity.InheritsFrom(TUdRegion)    then Self.AddRegion(TUdRegion(LEntity), AOwnerHandle, AInLayout) else
//  if LEntity.InheritsFrom(TUdTable)     then Self.AddTable(TUdTable(LEntity), AOwnerHandle, AInLayout);

    if Assigned(LDoc) and (FEntityCount > 0) then
    begin
      Inc(FEntityIndex);

      if FEntityIndex >= FLastProgrss then
      begin
        LPos := Round(FEntityIndex / FEntityCount * 90);
        LDoc.DoProgress(LPos+10, 100);

        FLastProgrss := FLastProgrss + FProgrssStep;
      end;
    end;
  end;
end;

function TUdDxfWriteEntites.AddEntities(AEntities: TUdEntities; AOwnerHandle: string; AInLayout: Boolean): Boolean;
begin
  Result := Self.AddEntities(AEntities.List, AOwnerHandle, AInLayout);
end;

procedure TUdDxfWriteEntites.Execute;
var
  LLayout: TUdLayout;
  LName, LHandle: string;  
begin
  LLayout := Self.Document.ActiveLayout;
  if (LLayout = Self.Document.ModelSpace) then
  begin
    if Self.Document.Layouts.Count > 1 then
      LLayout := Self.Document.Layouts.Items[1]
    else
      LLayout := nil;
  end;


  FEntityCount := Self.Document.ModelSpace.Entities.Count;
  if Assigned(LLayout) then
    FEntityCount := FEntityCount + LLayout.Entities.Count;

  FProgrssStep := Round(FEntityCount / 90  * 5);
  FLastProgrss := FProgrssStep;
  FEntityIndex := 0;


  //----------------------------------------------------------

  Self.AddRecord(0, 'SECTION');
  Self.AddRecord(2, 'ENTITIES');

  Self.AddEntities(Self.Document.ModelSpace.Entities, Self.GeneralHandle, True);


  if Assigned(LLayout) and Assigned(LLayout.ViewPort) and LLayout.ViewPort.Inited then
  begin
    {$IFDEF DXF12}
    if Self.Version = dxf12 then LName := '$Paper_Space' else
    {$ENDIF}
    LName := '*Paper_Space';

    LHandle := Self.BlockHandles.GetValue(LName);
    if LHandle <> '' then
    begin
      Self.AddViewport(LLayout, LName, LHandle, True, False);
      if LLayout.ViewPort.Visible then
        Self.AddViewport(LLayout, LName, LHandle, True, True);
      Self.AddEntities(LLayout.Entities, LHandle, True);
    end;
  end;


  AddRecord(0, 'ENDSEC');
end;





end.