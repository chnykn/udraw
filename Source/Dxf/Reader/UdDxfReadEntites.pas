{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfReadEntites;

{$I UdDefs.INC}

//{$DEFINE READ_LAYOUT}
//{$DEFINE SOLID_AS_POLYLINE}


interface

uses
  Classes, UdConsts, UdHashMaps,
  UdDxfTypes, UdDxfReadSection,

  UdTypes, UdGTypes, UdDocument, UdEntities, UdEntity, UdLayer, UdLinetype, UdLineWeight;

type

  TUdDxfReadEntites = class(TUdDxfReadSection)
  private
    FIsBlock: Boolean;
    FVPortCount: Integer;

  protected
    function _SetEntityLayer(AEntity: TUdEntity; AValue: string): Boolean;
    function _SetEntityColor(AEntity: TUdEntity; AValue: string): Boolean;
    function _SetEntityLineType(AEntity: TUdEntity; AValue: string): Boolean;
    function _SetEntityLineWeight(AEntity: TUdEntity; AValue: string): Boolean;

    function InitEntity(AEntity: TUdEntity): Boolean;
    function ReadCommonProp(AEntity: TUdEntity; ARecord: TUdDxfRecord; var ALayoutEntities: TUdEntities): Boolean; overload;
    function ReadCommonProp(AEntity: TUdEntity; ARecords: TUdStrStrHashMap; var ALayoutEntities: TUdEntities): Boolean; overload;


    procedure AddLine(AEntities: TUdEntities);
    procedure AddMLine(AEntities: TUdEntities);
    procedure AddRay(AEntities: TUdEntities);
    procedure AddXLine(AEntities: TUdEntities);
    procedure AddCircle(AEntities: TUdEntities);
    procedure AddArc(AEntities: TUdEntities);
    procedure AddLwPolyline(AEntities: TUdEntities);
    procedure Add2D3DPolyline(AEntities: TUdEntities);
    procedure AddSolid(AEntities: TUdEntities);
    procedure AddEllipse(AEntities: TUdEntities);
    procedure AddSPline(AEntities: TUdEntities);
    procedure AddPoint(AEntities: TUdEntities);

    procedure AddText(AEntities: TUdEntities);
    procedure AddMtext(AEntities: TUdEntities);
    procedure AddAttDef(AEntities: TUdEntities);

    procedure AddDimension(AEntities: TUdEntities);
    procedure AddTolerance(AEntities: TUdEntities);
    procedure AddLeader(AEntities: TUdEntities);
    procedure AddMLeader(AEntities: TUdEntities);

    procedure AddHatch(AEntities: TUdEntities);
    procedure AddInsert(AEntities: TUdEntities);

    procedure AddImage(AEntities: TUdEntities);
    procedure AddRegion(AEntities: TUdEntities);
    procedure AddTrace(AEntities: TUdEntities);
    procedure AddTable(AEntities: TUdEntities);

    procedure AddViewport(AEntities: TUdEntities);

  public
    constructor Create(AOwner: TObject);  override;
    destructor Destroy; override;

    function ReadEntities(AEntities: TUdEntities): Boolean;

    procedure Execute(); override;

  public
    property IsBlock: Boolean read FIsBlock write FIsBlock;

  end;



implementation

uses
  SysUtils, UdDxfReader,
  UdMath, UdGeo2D, UdUtils, UdBSpline2D,
  UdColor, UdTextStyle, UdDimStyle, UdDimProps, UdHatchPattern, UdLayout, UdColls,

  UdPoint, UdLine, UdXLine, UdRay, UdCircle, UdArc, UdEllipse, UdPolyline,
  UdSolid, UdText, UdLeader, UdTolerance, UdHatch, UdInsert, UdBlock,
  UdDimension, UdDimAligned, UdDimRotated, UdDimArclength, UdDimOrdinate,
  UdDimRadial, UdDimRadiallarge, UdDimDiametric, UdDim2LineAngular, UdDim3PointAngular  ;


//=================================================================================================

var
  GEntityMap: TUdStrHashMap;



procedure InitEntityHashMap();
begin
  GEntityMap.Add('LINE'       , TObject(1) );
  GEntityMap.Add('RAY'        , TObject(2) );
  GEntityMap.Add('XLINE'      , TObject(3) );
  GEntityMap.Add('MLINE'      , TObject(4) );
  GEntityMap.Add('CIRCLE'     , TObject(5) );
  GEntityMap.Add('ARC'        , TObject(6) );
  GEntityMap.Add('POLYLINE'   , TObject(7) );
  GEntityMap.Add('LWPOLYLINE' , TObject(8) );
  GEntityMap.Add('ELLIPSE'    , TObject(9) );
  GEntityMap.Add('SPLINE'     , TObject(10) );
  GEntityMap.Add('POINT'      , TObject(11) );

  GEntityMap.Add('DIMENSION'  , TObject(12) );
  GEntityMap.Add('ARC_DIMENSION', TObject(12) );
  GEntityMap.Add('LARGE_RADIAL_DIMENSION', TObject(12) );

  GEntityMap.Add('TOLERANCE'  , TObject(13) );
  GEntityMap.Add('LEADER'     , TObject(14) );
  GEntityMap.Add('MLEADER'    , TObject(15) );

  GEntityMap.Add('TEXT'       , TObject(16) );
  GEntityMap.Add('MTEXT'      , TObject(17) );
  GEntityMap.Add('ATTDEF'     , TObject(18) );
  GEntityMap.Add('ATTRIB'     , TObject(16) );
  GEntityMap.Add('HATCH'      , TObject(19) );

  GEntityMap.Add('INSERT'     , TObject(20) );
  GEntityMap.Add('SOLID'      , TObject(21));
  GEntityMap.Add('TRACE'      , TObject(22) );
  GEntityMap.Add('VIEWPORT'   , TObject(23) );

  GEntityMap.Add('IMAGE'      , TObject(24) );
  GEntityMap.Add('REGION'     , TObject(25) );
  GEntityMap.Add('TABLE'      , TObject(26) );


 {
  GEntityMap.Add('SEQEND'            , TObject(31));
  GEntityMap.Add('SHAPE'             , TObject(32));
  GEntityMap.Add('WIPEOUT'           , TObject(33));
  GEntityMap.Add('ACAD_TABLE'        , TObject(34));
  GEntityMap.Add('3DFACE'            , TObject(35));
  GEntityMap.Add('3DSOLID'           , TObject(36));
  GEntityMap.Add('BODY'              , TObject(37));
  GEntityMap.Add('OLEFRAME'          , TObject(38));
  GEntityMap.Add('OLE2FRAME'         , TObject(39));
  GEntityMap.Add('ACAD_PROXY_ENTITY' , TObject(40));
}

  GEntityMap.Add('ENDBLK'   , TObject(100) );
  GEntityMap.Add('ENDSEC'   , TObject(100) );
  GEntityMap.Add('EOF'      , TObject(100) );
end;





//=================================================================================================
{ TUdDxfReadEntites }



constructor TUdDxfReadEntites.Create(AOwner: TObject);
begin
  inherited;
  FIsBlock := False;
end;

destructor TUdDxfReadEntites.Destroy;
begin

  inherited;
end;






function TUdDxfReadEntites._SetEntityLayer(AEntity: TUdEntity; AValue: string): Boolean;
begin
  Result := False;
  if not Assigned(AEntity) then Exit;

  if AValue = '' then
    AValue := TUdDxfReader(FOwner).Header.ActiveLayer;
    
  if Assigned(Self.Document) then
  begin
    AEntity.Layer := Self.Document.Layers.GetItem(AValue);
    Result := True;
  end;
end;

function TUdDxfReadEntites._SetEntityColor(AEntity: TUdEntity; AValue: string): Boolean;
begin
  Result := False;
  if not Assigned(AEntity) then Exit;

  if AValue = '' then
    AValue := IntToStr(TUdDxfReader(FOwner).Header.ActiveColor);

  SetDxfColor(Self.Document, AEntity.Color, AValue);

//  if (AEntity.Color.ByKind = bkByLayer) and Assigned(AEntity.Layer) then
//    AEntity.Color.Assign(AEntity.Layer.Color);

  Result := True;
end;

function TUdDxfReadEntites._SetEntityLineType(AEntity: TUdEntity; AValue: string): Boolean;
var
  LLntyp: TUdLineType;
begin
  Result := False;
  if not Assigned(AEntity) then Exit;

  if AValue = '' then
    AValue := TUdDxfReader(FOwner).Header.ActiveLineType;

  if Assigned(Self.Document) then
  begin
    LLntyp := Self.Document.LineTypes.GetItem(AValue);
    if not Assigned(LLntyp) then
      LLntyp := Self.Document.LineTypes.GetStdLineType(AValue);

    AEntity.LineType := LLntyp;
    
    Result := True;
  end;
end;

function TUdDxfReadEntites._SetEntityLineWeight(AEntity: TUdEntity; AValue: string): Boolean;
var
  I, N: Integer;
begin
  Result := False;
  
  if AValue = '' then
  begin
    Result := True;
    AEntity.LineWeight := TUdDxfReader(FOwner).Header.ActiveLineWeight;
  end
  else begin
    N := StrToIntDef(AValue, -100);
    for I := Low(ALL_LINE_WEIGHTS) to High(ALL_LINE_WEIGHTS) do
    begin
      if ALL_LINE_WEIGHTS[I] = N then
      begin
        AEntity.LineWeight := N;

        Result := True;
        Break; //=========>>>>>
      end;
    end;
  end;
end;



function TUdDxfReadEntites.InitEntity(AEntity: TUdEntity): Boolean;
begin
  Result := False;
  if not Assigned(AEntity) then Exit;

  AEntity.Layer := TUdDocument(Self.Document).ActiveLayer;
  AEntity.LineTypeScale := 1.0;
  AEntity.LineWeight    := LW_DEFAULT;

  Result := True;
end;

function TUdDxfReadEntites.ReadCommonProp(AEntity: TUdEntity; ARecord: TUdDxfRecord; var ALayoutEntities: TUdEntities): Boolean;
var
  LHandle: string;
begin
  Result := False;
  if not Assigned(AEntity) then Exit; //======>>>>>

  case ARecord.Code of
    5  : begin LHandle := ARecord.Value; Result := True; end;
    8  : Result := _SetEntityLayer(AEntity, ARecord.Value);
    62 : Result := _SetEntityColor(AEntity, ARecord.Value);
    6  : Result := _SetEntityLineType(AEntity, ARecord.Value);
    370: Result := _SetEntityLineWeight(AEntity, ARecord.Value);
    48 : begin AEntity.LineTypeScale := StrToFloatDef(ARecord.Value, 1.0); Result := True; end;
    420: begin AEntity.Color.TrueColor := StrToIntDef(ARecord.Value, 1); Result := True; end;
    330:
      begin
        if not FIsBlock then
          ALayoutEntities := TUdDxfReader(FOwner).GetLayoutEntities(ARecord.Value);

        Result := True;
      end;
  end;

  if LHandle <> '' then ;
end;

function TUdDxfReadEntites.ReadCommonProp(AEntity: TUdEntity; ARecords: TUdStrStrHashMap; var ALayoutEntities: TUdEntities): Boolean;
var
  LValue: string;
  LHandle: string;
begin
  Result := False;
  if not Assigned(AEntity) or not Assigned(ARecords) then Exit; //======>>>>>

  LHandle := ARecords.GetValue('5');

  LValue := ARecords.GetValue('8');
  if LValue = '' then LValue := TUdDxfReader(FOwner).Header.ActiveLayer;
  if LValue <> '' then _SetEntityLayer(AEntity, LValue);

  LValue := ARecords.GetValue('62');
//  if LValue = '' then LValue := TUdDxfReader(FOwner).Header.ActiveColor;
  if LValue <> '' then _SetEntityColor(AEntity, LValue);

  LValue := ARecords.GetValue('6');
  if LValue = '' then LValue := TUdDxfReader(FOwner).Header.ActiveLineType;
  if LValue <> '' then _SetEntityLineType(AEntity, LValue);

  LValue := ARecords.GetValue('370');
//  if LValue = '' then LValue := TUdDxfReader(FOwner).Header.ActiveLineWeight;
  if LValue <> '' then _SetEntityLineWeight(AEntity, LValue);

  LValue := ARecords.GetValue('48');
  if LValue <> '' then AEntity.LineTypeScale := StrToFloatDef(LValue, 1.0);

  LValue := ARecords.GetValue('420');
  if LValue <> '' then AEntity.Color.TrueColor := StrToIntDef(LValue, 0);

  LValue := ARecords.GetValue('330');
  if not FIsBlock and (LValue <> '') then
    ALayoutEntities := TUdDxfReader(FOwner).GetLayoutEntities(LValue);

  if LHandle <> '' then ;

  Result := True;
end;



//---------------------------------------------------------------------------------------------------

procedure TUdDxfReadEntites.AddLine(AEntities: TUdEntities);
var
  X1, Y1: Float;
  X2, Y2: Float;
  LEntity: TUdLine;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdLine.Create(Self.Document, False);
  InitEntity(LEntity);

  LLayoutEntities := nil;

  X1 := 0;  Y1 := 0;
  X2 := 0;  Y2 := 0;
  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        10: X1 := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: Y1 := StrToFloatDef(Self.CurrRecord.Value, 0);

        11: X2 := StrToFloatDef(Self.CurrRecord.Value, 0);
        21: Y2 := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LEntity.BeginUpdate();
  try
    LEntity.StartPoint := Point2D(X1, Y1);
    LEntity.EndPoint   := Point2D(X2, Y2);
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;

procedure TUdDxfReadEntites.AddRay(AEntities: TUdEntities);
var
  X1, Y1: Float;
  X2, Y2: Float;
  LEntity: TUdRay;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdRay.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  X1 := 0;  Y1 := 0;
  X2 := 0;  Y2 := 0;
  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        10: X1 := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: Y1 := StrToFloatDef(Self.CurrRecord.Value, 0);

        11: X2 := StrToFloatDef(Self.CurrRecord.Value, 0);
        21: Y2 := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LEntity.BeginUpdate();
  try
    LEntity.BasePoint   := Point2D(X1, Y1);
    LEntity.SecondPoint := Point2D(X2, Y2);
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;

procedure TUdDxfReadEntites.AddXLine(AEntities: TUdEntities);
var
  X1, Y1: Float;
  X2, Y2: Float;
  LEntity: TUdXLine;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdXLine.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  X1 := 0;  Y1 := 0;
  X2 := 0;  Y2 := 0;
  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        10: X1 := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: Y1 := StrToFloatDef(Self.CurrRecord.Value, 0);

        11: X2 := StrToFloatDef(Self.CurrRecord.Value, 0);
        21: Y2 := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LEntity.BeginUpdate();
  try
    LEntity.BasePoint   := Point2D(X1, Y1);
    LEntity.SecondPoint := Point2D(X2, Y2);
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;

procedure TUdDxfReadEntites.AddMLine(AEntities: TUdEntities);
//var
  //...
//  LLayoutEntities: TUdEntities;
begin
  //...
//  LLayoutEntities := nil;

  repeat
    Self.ReadCurrentRecord();

//    if not ReadCommonProp(LLine, Self.CurrRecord, LLayoutEntities) then
//    begin
//      case Self.CurrRecord.Code of
//        10: X := StrToFloatDef(Self.CurrRecord.Value, 0);
//        20: Y := StrToFloatDef(Self.CurrRecord.Value, 0);
//      end;
//    end;
  until (Self.CurrRecord.Code = 0);

//  if Assigned(LLayoutEntities) then
//    LLayoutEntities.Add(LEntity)
//  else
//    AEntities.Add(LEntity);
end;


procedure TUdDxfReadEntites.AddCircle(AEntities: TUdEntities);
var
  X, Y, R: Float;
  LEntity: TUdCircle;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdCircle.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  X := 0;  Y := 0; R := 0;
  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        10: X := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: Y := StrToFloatDef(Self.CurrRecord.Value, 0);
        40: R := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LEntity.BeginUpdate();
  try
    LEntity.Center := Point2D(X, Y);
    LEntity.Radius := R;
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;

procedure TUdDxfReadEntites.AddArc(AEntities: TUdEntities);
var
  X, Y: Float;
  R, A1, A2: Float;
  LEntity: TUdArc;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdArc.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  X := 0;  Y := 0;
  R := 0; A1 := 0; A2 := 0;
  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        10: X  := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: Y  := StrToFloatDef(Self.CurrRecord.Value, 0);
        40: R  := StrToFloatDef(Self.CurrRecord.Value, 0);
        50: A1 := StrToFloatDef(Self.CurrRecord.Value, 0);
        51: A2 := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LEntity.BeginUpdate();
  try
    LEntity.Center := Point2D(X, Y);
    LEntity.Radius := R;
    LEntity.StartAngle := A1;
    LEntity.EndAngle   := A2;
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;


procedure TUdDxfReadEntites.AddLwPolyline(AEntities: TUdEntities);
var
  I: Integer;
  N, L: Integer;
  LFlag: Integer;
  LFixWid: Float;
  LElevation: Float;
  LThickness: Float;
  LVertexes: TVertexes2D;
  LWidths : TPoint2DArray;
  LEntity: TUdPolyline;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdPolyline.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  N := -1;
  L := -1;
  LFlag := 0;
  LFixWid := -1;
  LElevation := 0;
  LThickness := 0;
  LVertexes := nil;

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        90:
          begin
            L := StrToIntDef(Self.CurrRecord.Value, 0);

            SetLength(LWidths, L);
            SetLength(LVertexes, L);

            for I := 0 to L - 1 do LWidths[I] := Point2D(0, 0);
            for I := 0 to L - 1 do LVertexes[I] := Vertex2D(0, 0, 0);
          end;

        70: LFlag := StrToIntDef(Self.CurrRecord.Value, 0);
        43: LFixWid := StrToFloatDef(Self.CurrRecord.Value, 0);
        38: LElevation := StrToFloatDef(Self.CurrRecord.Value, 0);
        39: LThickness := StrToFloatDef(Self.CurrRecord.Value, 0);

        10:
          begin
            Inc(N);
            if (N >= 0) and (N < L) then LVertexes[N].Point.X := StrToFloatDef(Self.CurrRecord.Value, 0);
          end;
        20: if (N >= 0) and (N < L) then LVertexes[N].Point.Y := StrToFloatDef(Self.CurrRecord.Value, 0);
        42: if (N >= 0) and (N < L) then LVertexes[N].Bulge   := StrToFloatDef(Self.CurrRecord.Value, 0);

        40: if (N >= 0) and (N < L) then LWidths[N].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        41: if (N >= 0) and (N < L) then LWidths[N].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

      end;
    end;
  until (Self.CurrRecord.Code = 0);

  if (N > 0) and (L > 0) then
  begin
    if N + 1 < L then
    begin
      L := N + 1;
      SetLength(LWidths, L);
      SetLength(LVertexes, L);
    end;

    LEntity.BeginUpdate();
    try
      LEntity.Vertexes := LVertexes;
      LEntity.Widths := LWidths;
      if LFixWid >= 0 then LEntity.Width := LFixWid;
      LEntity.Closed := (LFlag = 1) or IsEqual(LVertexes[0].Point, LVertexes[L-1].Point);
    finally
      LEntity.EndUpdate();
    end;

    if Assigned(LLayoutEntities) then
      LLayoutEntities.Add(LEntity)
    else
      AEntities.Add(LEntity);
  end
  else LEntity.Free;

  if LElevation > 0 then ;
  if LThickness > 0 then ;
end;

procedure TUdDxfReadEntites.Add2D3DPolyline(AEntities: TUdEntities);
var
  LFlag: Integer;
  LGrad: Integer;
  LEntity: TUdPolyline;
  LPoint: TPoint2D;
  LPoints: TPoint2DArray;
  LPointList: TPoint2DList;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdPolyline.Create(Self.Document, False);
  InitEntity(LEntity);


  LLayoutEntities := nil;

  LFlag := 0;
  LGrad := 0;
  LPoints := nil;

      
  LPointList := TPoint2DList.Create();
  try
    repeat
      Self.ReadCurrentRecord();

      if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
      begin
        case Self.CurrRecord.Code of
          70: LFlag := StrToIntDef(Self.CurrRecord.Value, 0);
          75: LGrad := StrToIntDef(Self.CurrRecord.Value, 0);
        end;
      end;
    until (Self.CurrRecord.Code = 0);

    while (Self.CurrRecord.Value = 'VERTEX') do
    begin
      repeat
        Self.ReadCurrentRecord();

        case Self.CurrRecord.Code of
          10: begin LPoint.X := StrToFloatDef(Self.CurrRecord.Value, 0);  end;
          20: begin LPoint.Y := StrToFloatDef(Self.CurrRecord.Value, 0); LPointList.Add(LPoint); end;
        end;
      until (Self.CurrRecord.Code = 0);
    end;

    LPoints := LPointList.ToArray();
  finally
    LPointList.Free;
  end;


  LEntity.BeginUpdate();
  try
    LEntity.SetPoints(LPoints);
    LEntity.Closed := ((LFlag and 1) > 0);
    case LGrad of
      5: LEntity.SplineFlag := sfQuadratic; //sfQuadratic,
      6: LEntity.SplineFlag := sfCubic;
    end;
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;




{$IFDEF SOLID_AS_POLYLINE}
procedure TUdDxfReadEntites.AddSolid(AEntities: TUdEntities);
var
//  LThickness: Float;
  LPoints: TPoint2DArray;
  LEntity: TUdPolyline;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdPolyline.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

//  LThickness := 0;
  SetLength(LPoints, 4);

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
//        39: LThickness := StrToFloatDef(Self.CurrRecord.Value, 0);

        10: LPoints[0].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: LPoints[0].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

        11: LPoints[1].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        21: LPoints[1].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

        13: LPoints[2].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        23: LPoints[2].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

        12: LPoints[3].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        22: LPoints[3].Y := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);


  LEntity.BeginUpdate();
  try
    LEntity.SetPoints(LPoints);
    LEntity.Closed := True;
    LEntity.Filled := True;
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;
{$ELSE}

procedure TUdDxfReadEntites.AddSolid(AEntities: TUdEntities);
var
  LPoints: TPoint2DArray;
  LEntity: TUdSolid;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdSolid.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

//  LThickness := 0;
  SetLength(LPoints, 4);

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
//        39: LThickness := StrToFloatDef(Self.CurrRecord.Value, 0);

        10: LPoints[0].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: LPoints[0].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

        11: LPoints[1].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        21: LPoints[1].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

        12: LPoints[2].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        22: LPoints[2].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

        13: LPoints[3].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        23: LPoints[3].Y := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);


  LEntity.BeginUpdate();
  try
    LEntity.P1 := LPoints[0];
    LEntity.P2 := LPoints[1];
    LEntity.P3 := LPoints[2];
    LEntity.P4 := LPoints[3];
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;
{$ENDIF}

procedure TUdDxfReadEntites.AddEllipse(AEntities: TUdEntities);
var
  LCen: TPoint2D;
  LEnd: TPoint2D;
  LFactor: Float;
  LAng1, LAng2: Float;
  LEntity: TUdEllipse;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdEllipse.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  LCen := Point2D(0, 0);
  LEnd := Point2D(0, 0);
  LFactor := 1.0;
  LAng1 := 0; LAng2 := 360;

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        10: LCen.X  := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: LCen.Y  := StrToFloatDef(Self.CurrRecord.Value, 0);
        11: LEnd.X  := StrToFloatDef(Self.CurrRecord.Value, 0);
        21: LEnd.Y  := StrToFloatDef(Self.CurrRecord.Value, 0);
        40: LFactor := StrToFloatDef(Self.CurrRecord.Value, 1);
        41: LAng1   := RadToDeg(StrToFloatDef(Self.CurrRecord.Value, 0));
        42: LAng2   := RadToDeg(StrToFloatDef(Self.CurrRecord.Value, 0));
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LEntity.BeginUpdate();
  try
    LEntity.Center := LCen;
    LEntity.MajorRadius := Sqrt(Sqr(LEnd.X) + Sqr(LEnd.Y));
    LEntity.MinorRadius := LEntity.MajorRadius * LFactor;
    LEntity.Rotation    := FixAngle(ArcTan2D(LEnd.Y, LEnd.X));
    LEntity.StartAngle  := LAng1;
    LEntity.EndAngle    := LAng2;
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;

procedure TUdDxfReadEntites.AddSPline(AEntities: TUdEntities);
var
  L1, L2: Integer;
  LFlag: Integer;
  LThickness: Float;
  LKnots: TFloatArray;
  LWeights: TFloatArray;
  LVertexes: TVertexes2D;
  LVertexes1: TVertexes2D;
  LVertexes2: TVertexes2D;

  LEntity: TUdPolyline;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdPolyline.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  L1 := 0;
  L2 := 0;
  LFlag := 0;
  LThickness := 0;
  LKnots := nil;
  LWeights := nil;
  LVertexes1 := nil;
  LVertexes2 := nil;

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        70: LFlag := StrToIntDef(Self.CurrRecord.Value, 0);

        10:
          begin
            SetLength(LVertexes1, L1 + 1);
            LVertexes1[L1].Point.X := StrToFloatDef(Self.CurrRecord.Value, 0);
            LVertexes1[L1].Bulge := 0;
          end;
        20:
          begin
            if L1 >= 0 then
              LVertexes1[L1].Point.Y := StrToFloatDef(Self.CurrRecord.Value, 0);
            Inc(L1);
          end;

        11:
          begin
            SetLength(LVertexes2, L2 + 1);
            LVertexes2[L2].Point.X := StrToFloatDef(Self.CurrRecord.Value, 0);
            LVertexes2[L2].Bulge := 0;
          end;
        21:
          begin
            if L2 >= 0 then
              LVertexes2[L2].Point.Y := StrToFloatDef(Self.CurrRecord.Value, 0);
            Inc(L2);
          end;

        39: LThickness := StrToFloatDef(Self.CurrRecord.Value, 0);
        40:
          begin
            SetLength(LKnots, Length(LKnots) + 1);
            LKnots[High(LKnots)] := StrToFloatDef(Self.CurrRecord.Value, 0);
          end;
        41:
          begin
            SetLength(LWeights, Length(LWeights) + 1);
            LWeights[High(LWeights)] := StrToFloatDef(Self.CurrRecord.Value, 0);
          end;
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LVertexes := nil;
  if (Length(LVertexes2) > 0) then LVertexes := LVertexes2 else
  if (Length(LVertexes1) > 0) then LVertexes := LVertexes1 else;

  if Length(LVertexes) > 0 then
  begin
    LEntity.BeginUpdate();
    try
      LEntity.Knots := LKnots;
      LEntity.Vertexes := LVertexes;
      LEntity.SplineFlag := sfFitting;
      LEntity.Closed := LFlag = 1;
    finally
      LEntity.EndUpdate();
    end;

    if Assigned(LEntity) then
    begin
      if Assigned(LLayoutEntities) then
        LLayoutEntities.Add(LEntity)
      else
        AEntities.Add(LEntity);
    end;
  end
  else
    LEntity.Free;


  if LThickness > 0 then ;
end;

procedure TUdDxfReadEntites.AddPoint(AEntities: TUdEntities);
var
  X, Y: Float;
  LEntity: TUdPoint;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdPoint.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  X := 0;  Y := 0;
  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        10: X := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: Y := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  if Assigned(LEntity.Layer) and (UpperCase(LEntity.Layer.Name) = 'DEFPOINTS') then
  begin
    LEntity.Free;
    Exit; //=======>>>>>
  end;

  LEntity.BeginUpdate();
  try
    LEntity.Position := Point2D(X, Y);
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;




(*
A{\Ob\fSimSun|b1|i0|c134|p2;\o汉\fSimSun|b0|i1|c134|p2;字\fSimSun|b0|i0|c134|p2;\L测
\fSimSun|b1|i1|c134|p2;\l试}123%%D%%P{\fISOCPEUR|b0|i0|c0|p34;\U+2248\fSimSun|b0|i0|c134|p2;\\\{}
*)

{$WARNINGS OFF}
function FConvertText(const AText: string): string;
var
  I: Integer;
  LText: string;
  LReturn: string;
  N1, N2: Integer;
begin
  LReturn := '';

  I := 1;
  LText := AText + #32;
  while I < Length(LText) do
  begin
    if LText[I] = '\' then
    begin
      if (LText[I+1] in ['P', 'p']) then
      begin
        LReturn := LReturn + #13#10;
        Inc(I, 2);
      end    
      else if (LText[I+1] in ['U', 'u', 'M', 'm']) then   { \U+XXXX  \M+XXXXX}
      begin
        LReturn := LReturn + LText[I];
        Inc(I);
      end
      else if LText[I+1] in ['\', '{', '}'] then   { \\\{ }
      begin
        LReturn := LReturn + LText[I+1];
        Inc(I, 2);
      end
      else begin
        N1 := UdUtils.PosStr(';', LText, I+1, True); { -1 or N}

        if N1 <= 0 then  { \O }
        begin
          Inc(I, 2);
        end
        else begin
          N2 := UdUtils.PosStr('\', LText, I+1, True);
          
          if (N1 < N2) or (N2 <= 0) then
            I := N1 + 1
          else
            Inc(I, 2);
        end;
      end;
    end
    else begin
      if not (LText[I] in ['{', '}']) then
        LReturn := LReturn + LText[I];
      Inc(I);
    end;
  end;

  Result := LReturn;
end;
{$WARNINGS ON}

(*
72 水平文字对正类型（可选，默认值 = 0）

0 = 左对正；
1 = 居中；
2 = 右对正
3 = 对齐（如果垂直对齐 = 0）
4 = 中间（如果垂直对齐 = 0）
5 = 拟合（如果垂直对齐 = 0）

-----------

73  文字垂直对正类型（可选；默认值 = 0）

0 = 基线对正；
1 = 底端对正；
2 = 居中对正；
3 = 顶端对正
*)

(*
function FGetTextAlign(AHorJustify, AVerJustify: Integer): TUdTextAlign;
begin
  Result := taBottomLeft;
  if (AVerJustify = 0) and (AHorJustify > 2) then  //=====>>>>
//  begin
//    case AHorJustify of
//      3: Result := taBottomLeft;
//      4: Result := taBottomCenter;
//      5: Result := taBottomLeft;
//    end;
//    Exit; //=====>>>>
//  end;

  if not (AHorJustify in [0..2]) then AHorJustify := 0;

  AVerJustify := AVerJustify - 1;
  if AVerJustify < 0 then AVerJustify := 0;
  if not (AVerJustify in [0..2]) then AVerJustify := 0;

  case AHorJustify of
    0:
    begin
      case AVerJustify of
        2: Result := taTopLeft;
        1: Result := taMiddleLeft;
        0: Result := taBottomLeft;
      end;
    end;
    1:
    begin
      case AVerJustify of
        2: Result := taTopCenter;
        1: Result := taMiddleCenter;
        0: Result := taBottomCenter;
      end;
    end;
//    2:
//    begin
//      case AVerJustify of
//        2: Result := taTopRight;
//        1: Result := taMiddleRight;
//        0: Result := taBottomRight;
//      end;
//    end;
  end;
end;
*)



procedure TUdDxfReadEntites.AddText(AEntities: TUdEntities);
var
  LFlag: Integer;
  LText: string;
  LStyle: string;
  LHeight: Float;
  LRotation: Float;
  LWidFactor: Float;
  LThickness: Float;
  LHorJustify, LVerJustify: Integer;
  LInsPnt, LAlgnPnt: TPoint2D;
  LLayoutEntities: TUdEntities;
  LEntity: TUdText;
begin
  LEntity := TUdText.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LEntity.KindsFlag := TEXT_KIND_SINGLE_LINE;
    
  LLayoutEntities := nil;

  LText := '';
  LStyle := '';
  LFlag := 0;
  LInsPnt := Point2D(0, 0);
  LAlgnPnt := Point2D(0, 0);
  LHeight := 2.5;
  LRotation  := 0.0;
  LWidFactor := 1.0;
  LThickness := 0.0;
  LHorJustify := 0;
  LVerJustify := 0;
  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        1 : LText       := Self.CurrRecord.Value;
        7 : LStyle      := Self.CurrRecord.Value;
        10: LInsPnt.X   := StrToFloatDef(Self.CurrRecord.Value, 0);
        11: LAlgnPnt.X  := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: LInsPnt.Y   := StrToFloatDef(Self.CurrRecord.Value, 0);
        21: LAlgnPnt.Y  := StrToFloatDef(Self.CurrRecord.Value, 0);
        39: LThickness  := StrToFloatDef(Self.CurrRecord.Value, 0);
        40: LHeight     := StrToFloatDef(Self.CurrRecord.Value, 2.5);
        41: LWidFactor  := StrToFloatDef(Self.CurrRecord.Value, 1.0);
        50: LRotation   := StrToFloatDef(Self.CurrRecord.Value, 0.0);
        71: LFlag       := StrToIntDef(Self.CurrRecord.Value, 0);
        72: LHorJustify := StrToIntDef(Self.CurrRecord.Value, 0);
        73: LVerJustify := StrToIntDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);


  LText := FConvertText(LText);
  if LText <> '' then
  begin
    if LStyle = '' then LStyle := TUdDxfReader(FOwner).Header.ActiveTextStyle;
    
    LEntity.BeginUpdate();
    try
      LEntity.Contents    := LText;
      LEntity.TextStyle   := Self.Document.TextStyles.GetItem(LStyle);
      LEntity.Height      := LHeight;
      LEntity.Position    := LInsPnt;
      LEntity.Rotation    := LRotation;
      LEntity.WidthFactor := LWidFactor;
      LEntity.Alignment   := taBottomLeft; //FGetTextAlign(LHorJustify, LVerJustify);
      LEntity.Backward    := ((LFlag and 2) > 0);
      LEntity.Upsidedown  := ((LFlag and 4) > 0);
    finally
      LEntity.EndUpdate();
    end;

    if Assigned(LLayoutEntities) then
      LLayoutEntities.Add(LEntity)
    else
      AEntities.Add(LEntity);
  end
  else
    LEntity.Free();

  if LThickness > 0 then ;
  if LHorJustify > 0 then ;
  if LVerJustify > 0 then ;
end;

procedure TUdDxfReadEntites.AddMtext(AEntities: TUdEntities);
var
  LText: string;
  LStyle: string;
  LAlignment: Integer;
  LInsPnt: TPoint2D;
  LHeight: Float;
  LBoxWidth: Float;
  LRotation: Float;
  LLineSpaceFactor: Float;
  LFillColor: Integer;
  LUseFillColor: Integer;

  LLayoutEntities: TUdEntities;
  LEntity: TUdText;
begin
  LEntity := TUdText.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LEntity.KindsFlag := TEXT_KIND_MULT_LINE;

  LLayoutEntities := nil;

  LText            := '';
  LStyle           := '';
  LAlignment       := 1;
  LInsPnt          := Point2D(0, 0);
  LHeight          := 2.5;
  LBoxWidth        := 0.0;
  LRotation        := 0.0;
  LLineSpaceFactor := 1.0;
  LFillColor       := CL_WHITE;
  LUseFillColor    := 0;

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        1,3 : LText            := LText + Self.CurrRecord.Value;
        7   : LStyle           := Self.CurrRecord.Value;
        10  : LInsPnt.X        := StrToFloatDef(Self.CurrRecord.Value, 0);
      //11  : LDirect.X        := StrToFloatDef(Self.CurrRecord.Value, 0);
        20  : LInsPnt.Y        := StrToFloatDef(Self.CurrRecord.Value, 0);
      //21  : LDirect.Y        := StrToFloatDef(Self.CurrRecord.Value, 0);
        40  : LHeight          := StrToFloatDef(Self.CurrRecord.Value, 2.5);
        41  : LBoxWidth        := StrToFloatDef(Self.CurrRecord.Value, 0.0);
        44  : LLineSpaceFactor := StrToFloatDef(Self.CurrRecord.Value, 0.0);
        50  : LRotation        := StrToFloatDef(Self.CurrRecord.Value, 0.0);
        71  : LAlignment       := StrToIntDef(Self.CurrRecord.Value, 0);
        63  : LFillColor       := StrToIntDef(Self.CurrRecord.Value, CL_WHITE);
        90  : LUseFillColor    := StrToIntDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LText := FConvertText(LText);
  if LText <> '' then
  begin
    if LStyle = '' then LStyle := TUdDxfReader(FOwner).Header.ActiveTextStyle;
    
    LEntity.BeginUpdate();
    try
      LEntity.Contents        := LText;
      LEntity.TextStyle       := Self.Document.TextStyles.GetItem(LStyle);
      LEntity.Height          := LHeight;
      LEntity.Position        := LInsPnt;
      LEntity.Rotation        := LRotation;
//      LEntity.WidthFactor   := LWidFactor;
      LEntity.LineSpaceFactor := LLineSpaceFactor;

      if LAlignment in [1..9] then
        LEntity.Alignment := TUdTextAlign(LAlignment-1);

      if LUseFillColor = 1 then
        LEntity.FillColor.IndexColor := LFillColor
      else
        LEntity.FillColor.ColorType := ctNone;

      if LBoxWidth > 0 then ;
    finally
      LEntity.EndUpdate();
    end;

    if Assigned(LLayoutEntities) then
      LLayoutEntities.Add(LEntity)
    else
      AEntities.Add(LEntity);
  end
  else
    LEntity.Free();
end;

procedure TUdDxfReadEntites.AddAttDef(AEntities: TUdEntities);
var
  LText   : string;
  LDefStr : string;
  LTagStr : string;
  LHintStr: string;
  LStyle  : string;
  LAlignment: Integer;
  LInsPnt: TPoint2D;
  LHeight: Float;
  LBoxWidth: Float;
  LRotation: Float;
  LWidFactor: Float;
  LLineSpaceFactor: Float;
  LFillColor: Integer;
  LUseFillColor: Integer;

  LLayoutEntities: TUdEntities;
  LEntity: TUdText;
begin
  LEntity := TUdText.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  LDefStr          := '';
  LTagStr          := '';
  LHintStr         := '';
  LStyle           := '';
  LAlignment       := 1;
  LInsPnt          := Point2D(0, 0);
  LHeight          := 2.5;
  LBoxWidth        := 0.0;
  LRotation        := 0.0;
  LWidFactor       := 1.0;
  LLineSpaceFactor := 1.0;
  LFillColor       := CL_WHITE;
  LUseFillColor    := 0;

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        1   : LDefStr          := Self.CurrRecord.Value;
        2   : LTagStr          := Self.CurrRecord.Value;
        3   : LHintStr         := Self.CurrRecord.Value;
        7   : LStyle           := Self.CurrRecord.Value;
        10  : LInsPnt.X        := StrToFloatDef(Self.CurrRecord.Value, 0);
      //11  : LDirect.X        := StrToFloatDef(Self.CurrRecord.Value, 0);
        20  : LInsPnt.Y        := StrToFloatDef(Self.CurrRecord.Value, 0);
      //21  : LDirect.Y        := StrToFloatDef(Self.CurrRecord.Value, 0);
        40  : LHeight          := StrToFloatDef(Self.CurrRecord.Value, 2.5);
        41  : LBoxWidth        := StrToFloatDef(Self.CurrRecord.Value, 0.0);
        44  : LLineSpaceFactor := StrToFloatDef(Self.CurrRecord.Value, 0.0);
        50  : LRotation        := StrToFloatDef(Self.CurrRecord.Value, 0.0);
        71  : LAlignment       := StrToIntDef(Self.CurrRecord.Value, 0);
        63  : LFillColor       := StrToIntDef(Self.CurrRecord.Value, CL_WHITE);
        90  : LUseFillColor    := StrToIntDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LText := FConvertText(LDefStr);
  if LText <> '' then
  begin
    if LStyle = '' then LStyle := TUdDxfReader(FOwner).Header.ActiveTextStyle;
    
    LEntity.BeginUpdate();
    try
      LEntity.Contents        := LText;
      LEntity.TextStyle       := Self.Document.TextStyles.GetItem(LStyle);
      LEntity.Height          := LHeight;
      LEntity.Position        := LInsPnt;
      LEntity.Rotation        := LRotation;
      LEntity.WidthFactor     := LWidFactor;
      LEntity.LineSpaceFactor := LLineSpaceFactor;

      if LAlignment in [1..9] then
        LEntity.Alignment := TUdTextAlign(LAlignment-1);

      if LUseFillColor = 1 then
        LEntity.FillColor.IndexColor := LFillColor
      else
        LEntity.FillColor.ColorType := ctNone;

      if LBoxWidth > 0 then ;
    finally
      LEntity.EndUpdate();
    end;

    if Assigned(LLayoutEntities) then
      LLayoutEntities.Add(LEntity)
    else
      AEntities.Add(LEntity);
  end
  else
    LEntity.Free();

  if LDefStr  = '' then ;
  if LTagStr  = '' then ;
  if LHintStr = '' then ;
end;





procedure TUdDxfReadEntites.AddDimension(AEntities: TUdEntities);

var
  LStyleRecords: TStringList;
  LLayoutEntities: TUdEntities;

  function _ReadCustomDimProp(AEntity: TUdDimension): Boolean;
  var
    N, C: Integer;
    LRec: TUdDxfRecord;
    LCode, LValue: string;
    LDimStyle: TUdDimStyle;
  begin
    Result := False;
    if not Assigned(AEntity) or
       not Assigned(FOwner) or not FOwner.InheritsFrom(TUdDxfReader) then Exit;

    LDimStyle := TUdDimStyle.Create(Self.Document, False);
    try
      LDimStyle.Assign(AEntity.DimStyle);

      N := 0;
      while N < LStyleRecords.Count do
      begin
        LCode := LStyleRecords[N];
        Inc(N);
        if N < LStyleRecords.Count then
        begin
          LValue := LStyleRecords[N];
          if TryStrToInt(LCode, C) then
          begin
            LRec.Code := C;
            LRec.Value := LValue;

            case LRec.Code of
              341: ;
              342: LDimStyle.ArrowsProp.ArrowLeader := TUdDxfReader(FOwner).GetArrowKind(LValue);
              343: LDimStyle.ArrowsProp.ArrowFirst  := TUdDxfReader(FOwner).GetArrowKind(LValue);
              344: LDimStyle.ArrowsProp.ArrowSecond := TUdDxfReader(FOwner).GetArrowKind(LValue);
              else
                TUdDxfReader(FOwner).Tables.SetDimStyleValue(LDimStyle, LRec);
            end;
          end;
        end;
        Inc(N);
      end;

      AEntity.LinesProp.Assign(LDimStyle.LinesProp);
      AEntity.ArrowsProp.Assign(LDimStyle.ArrowsProp);
      AEntity.TextProp.Assign(LDimStyle.TextProp);
      AEntity.UnitsProp.Assign(LDimStyle.UnitsProp);
      AEntity.AltUnitsProp.Assign(LDimStyle.AltUnitsProp);

    finally
      LDimStyle.Free;
    end;

    Result := True;
  end;


  procedure _ReadCommonDimProp(ARecords: TUdStrStrHashMap; AEntity: TUdDimension);
  var
    LStyle: string;
//    LTextColor: string;
    LDimStyle: TUdDimStyle;
    LTextOverride: string;
//    LDimBlockName: string;
  begin
    LStyle := ARecords.GetValue('3');

    if LStyle = '' then LStyle := TUdDxfReader(FOwner).Header.ActiveDimStyle;
    
    LDimStyle := Self.Document.DimStyles.GetItem(LStyle);
    if not Assigned(LDimStyle) then LDimStyle := Self.Document.DimStyles.Standard;

    AEntity.DimStyle := LDimStyle;


//    LDimBlockName := ARecords.GetValue('2');
//    Self.Document.Blocks.Remove(LDimBlockName);


    //--------------------------------
    {
    LTextColor := ARecords.GetValue('1070');
    if LTextColor <> '' then
    begin
      AEntity.TextProp.TextColor.ByKind := bkNone;
      SetDxfColor(AEntity.TextProp.TextColor, LTextColor);
    end;
    }

    //--------------------------------

    LTextOverride := ARecords.GetValue('1');
    if LTextOverride <> '' then
      AEntity.TextOverride := FConvertText(LTextOverride);

    //--------------------------------
    Self.ReadCommonProp(AEntity, ARecords, LLayoutEntities);
    _ReadCustomDimProp(AEntity);
  end;

  function _ReadDimAligned(ARecords: TUdStrStrHashMap; AEntity: TUdDimAligned = nil): TUdEntity;
  var
    LBasePnt: TPoint2D;
    LRotation: Float;
    LTextPoint: TPoint2D;
    LEntity: TUdDimAligned;
  begin
    if Assigned(AEntity) then LEntity := AEntity else
    LEntity := TUdDimAligned.Create(Self.Document, False);
    InitEntity(LEntity);

    LEntity.BeginUpdate();
    try
      _ReadCommonDimProp(ARecords, LEntity);

      LEntity.ExtLine1Point := Point2D(StrToFloatDef(ARecords.GetValue('13'), 0),  StrToFloatDef(ARecords.GetValue('23'), 0));
      LEntity.ExtLine2Point := Point2D(StrToFloatDef(ARecords.GetValue('14'), 0),  StrToFloatDef(ARecords.GetValue('24'), 0));

      if StrToIntDef(ARecords.GetValue('70'), 0) >= 160 then LEntity.TextProp.HorizontalPosition := htpCustom;

      LRotation  := GetAngle(LEntity.ExtLine1Point, LEntity.ExtLine2Point);
      LTextPoint := Point2D(StrToFloatDef(ARecords.GetValue('11'), 0),  StrToFloatDef(ARecords.GetValue('21'), 0));

      if (ARecords.GetValue('10') <> '') and (ARecords.GetValue('20') <> '') then
      begin
        LBasePnt := Point2D(StrToFloatDef(ARecords.GetValue('10'), 0),  StrToFloatDef(ARecords.GetValue('20'), 0));

        if LEntity.InheritsFrom(TUdDimRotated) then
        begin
          if IsEqual(LBasePnt.X, LEntity.ExtLine2Point.X, 0.1) then
            LRotation := 0
          else if IsEqual(LBasePnt.Y, LEntity.ExtLine2Point.Y, 0.1) then
            LRotation := 90;

          TUdDimRotated(LEntity).Rotation := LRotation;
        end;

        LTextPoint := UdGeo2D.ClosestLinePoint(LTextPoint, UdGeo2D.LineK(LBasePnt, LRotation));
      end;

      LEntity.TextPoint := LTextPoint;
    finally
      LEntity.EndUpdate();
    end;

    Result := LEntity;
  end;

  function _ReadDimRotated(ARecords: TUdStrStrHashMap): TUdEntity;
  begin
    Result := _ReadDimAligned(ARecords, TUdDimRotated.Create(Self.Document, False));
  end;

  function _ReadDimArcLength(ARecords: TUdStrStrHashMap): TUdEntity;
  var
    LEntity: TUdDimArclength;
  begin
    LEntity := TUdDimArclength.Create(Self.Document, False);
    InitEntity(LEntity);

    LEntity.BeginUpdate();
    try
      _ReadCommonDimProp(ARecords, LEntity);

      LEntity.CenterPoint   := Point2D(StrToFloatDef(ARecords.GetValue('15'), 0),  StrToFloatDef(ARecords.GetValue('25'), 0));
      LEntity.ExtLine1Point := Point2D(StrToFloatDef(ARecords.GetValue('13'), 0),  StrToFloatDef(ARecords.GetValue('23'), 0));
      LEntity.ExtLine2Point := Point2D(StrToFloatDef(ARecords.GetValue('14'), 0),  StrToFloatDef(ARecords.GetValue('24'), 0));

      if StrToIntDef(ARecords.GetValue('70'), 0) >= 160 then LEntity.TextProp.HorizontalPosition := htpCustom;

      LEntity.ArcPoint      := Point2D(StrToFloatDef(ARecords.GetValue('10'), 0),  StrToFloatDef(ARecords.GetValue('20'), 0));
      LEntity.TextPoint     := Point2D(StrToFloatDef(ARecords.GetValue('11'), 0),  StrToFloatDef(ARecords.GetValue('21'), 0));
    finally
      LEntity.EndUpdate();
    end;

    Result := LEntity;
  end;

  function _ReadDim3PointAngular(ARecords: TUdStrStrHashMap): TUdEntity;
  var
    LEntity: TUdDim3PointAngular;
  begin
    LEntity := TUdDim3PointAngular.Create(Self.Document, False);
    InitEntity(LEntity);

    LEntity.BeginUpdate();
    try
      _ReadCommonDimProp(ARecords, LEntity);

      LEntity.CenterPoint   := Point2D(StrToFloatDef(ARecords.GetValue('15'), 0),  StrToFloatDef(ARecords.GetValue('25'), 0));
      LEntity.ExtLine1Point := Point2D(StrToFloatDef(ARecords.GetValue('13'), 0),  StrToFloatDef(ARecords.GetValue('23'), 0));
      LEntity.ExtLine2Point := Point2D(StrToFloatDef(ARecords.GetValue('14'), 0),  StrToFloatDef(ARecords.GetValue('24'), 0));

      if StrToIntDef(ARecords.GetValue('70'), 0) >= 160 then LEntity.TextProp.HorizontalPosition := htpCustom;

      LEntity.ArcPoint      := Point2D(StrToFloatDef(ARecords.GetValue('10'), 0),  StrToFloatDef(ARecords.GetValue('20'), 0));
      LEntity.TextPoint     := Point2D(StrToFloatDef(ARecords.GetValue('11'), 0),  StrToFloatDef(ARecords.GetValue('21'), 0));
    finally
      LEntity.EndUpdate();
    end;

    Result := LEntity;
  end;

  function _ReadDim2LineAngular(ARecords: TUdStrStrHashMap): TUdEntity;
  var
    LEntity: TUdDim2LineAngular;
  begin
    LEntity := TUdDim2LineAngular.Create(Self.Document, False);
    InitEntity(LEntity);

    LEntity.BeginUpdate();
    try
      _ReadCommonDimProp(ARecords, LEntity);

      LEntity.ExtLine1StartPoint := Point2D(StrToFloatDef(ARecords.GetValue('13'), 0),  StrToFloatDef(ARecords.GetValue('23'), 0));
      LEntity.ExtLine1EndPoint   := Point2D(StrToFloatDef(ARecords.GetValue('14'), 0),  StrToFloatDef(ARecords.GetValue('24'), 0));
      LEntity.ExtLine2StartPoint := Point2D(StrToFloatDef(ARecords.GetValue('10'), 0),  StrToFloatDef(ARecords.GetValue('20'), 0));
      LEntity.ExtLine2EndPoint   := Point2D(StrToFloatDef(ARecords.GetValue('15'), 0),  StrToFloatDef(ARecords.GetValue('25'), 0));

      if StrToIntDef(ARecords.GetValue('70'), 0) >= 160 then LEntity.TextProp.HorizontalPosition := htpCustom;

      LEntity.ArcPoint           := Point2D(StrToFloatDef(ARecords.GetValue('16'), 0),  StrToFloatDef(ARecords.GetValue('26'), 0));
      LEntity.TextPoint          := Point2D(StrToFloatDef(ARecords.GetValue('11'), 0),  StrToFloatDef(ARecords.GetValue('21'), 0));
    finally
      LEntity.EndUpdate();
    end;

    Result := LEntity;
  end;

  function _ReadDimRadial(ARecords: TUdStrStrHashMap): TUdEntity;
  var
    LEntity: TUdDimRadial;
    LTextPnt: TPoint2D;
    LLeaderLen: Float;
  begin
    LEntity := TUdDimRadial.Create(Self.Document, False);
    InitEntity(LEntity);

    LEntity.BeginUpdate();
    try
      _ReadCommonDimProp(ARecords, LEntity);

      LEntity.Center     := Point2D(StrToFloatDef(ARecords.GetValue('10'), 0),  StrToFloatDef(ARecords.GetValue('20'), 0));
      LEntity.ChordPoint := Point2D(StrToFloatDef(ARecords.GetValue('15'), 0),  StrToFloatDef(ARecords.GetValue('25'), 0));

      if StrToIntDef(ARecords.GetValue('70'), 0) >= 160 then LEntity.TextProp.HorizontalPosition := htpCustom;

      LTextPnt := Point2D(StrToFloatDef(ARecords.GetValue('11'), 0),  StrToFloatDef(ARecords.GetValue('21'), 0));
      LLeaderLen := Distance(LTextPnt, LEntity.ChordPoint);
      if UdGeo2D.IsPntInCircle(LTextPnt,
           UdGeo2D.Circle2D(LEntity.Center, UdGeo2D.Distance(LEntity.Center, LEntity.ChordPoint))) then LLeaderLen := -LLeaderLen;

      LEntity.LeaderLen := LLeaderLen;
    finally
      LEntity.EndUpdate();
    end;

    Result := LEntity;
  end;

  function _ReadDimRadialLarge(ARecords: TUdStrStrHashMap): TUdEntity;
  var
    LEntity: TUdDimRadialLarge;
  begin
    LEntity := TUdDimRadialLarge.Create(Self.Document, False);
    InitEntity(LEntity);

    LEntity.BeginUpdate();
    try
      _ReadCommonDimProp(ARecords, LEntity);

      LEntity.Center     := Point2D(StrToFloatDef(ARecords.GetValue('10'), 0),  StrToFloatDef(ARecords.GetValue('20'), 0));
      LEntity.ChordPoint := Point2D(StrToFloatDef(ARecords.GetValue('15'), 0),  StrToFloatDef(ARecords.GetValue('25'), 0));

      LEntity.OverrideCenter:= Point2D(StrToFloatDef(ARecords.GetValue('13'), 0),  StrToFloatDef(ARecords.GetValue('23'), 0));
      LEntity.JogPoint      := Point2D(StrToFloatDef(ARecords.GetValue('14'), 0),  StrToFloatDef(ARecords.GetValue('24'), 0));
    finally
      LEntity.EndUpdate();
    end;

    Result := LEntity;
  end;

  function _ReadDimDiametric(ARecords: TUdStrStrHashMap): TUdEntity;
  var
    LEntity: TUdDimDiametric;
    LP1, LP2: TPoint2D;
    LTextPnt: TPoint2D;
    LLeaderLen: Float;
  begin
    LEntity := TUdDimDiametric.Create(Self.Document, False);
    InitEntity(LEntity);

    LEntity.BeginUpdate();
    try
      _ReadCommonDimProp(ARecords, LEntity);

      LP1 := Point2D(StrToFloatDef(ARecords.GetValue('10'), 0),  StrToFloatDef(ARecords.GetValue('20'), 0));
      LP2 := Point2D(StrToFloatDef(ARecords.GetValue('15'), 0),  StrToFloatDef(ARecords.GetValue('25'), 0));
      LEntity.Center     := MidPoint(LP1, LP2);
      LEntity.ChordPoint := LP2;

      LTextPnt := Point2D(StrToFloatDef(ARecords.GetValue('11'), 0),  StrToFloatDef(ARecords.GetValue('21'), 0));

      LLeaderLen := Distance(LTextPnt, LEntity.ChordPoint);
      if UdGeo2D.IsPntInCircle(LTextPnt,
           UdGeo2D.Circle2D(LEntity.Center, UdGeo2D.Distance(LEntity.Center, LEntity.ChordPoint))) then LLeaderLen := -LLeaderLen;

      LEntity.LeaderLen := LLeaderLen;
    finally
      LEntity.EndUpdate();
    end;

    Result := LEntity;
  end;

  function _ReadDimOrdinate(ARecords: TUdStrStrHashMap): TUdEntity;
  var
    LEntity: TUdDimOrdinate;
  begin
    LEntity := TUdDimOrdinate.Create(Self.Document, False);
    InitEntity(LEntity);

    LEntity.BeginUpdate();
    try
      _ReadCommonDimProp(ARecords, LEntity);

      LEntity.OriginPoint     := Point2D(StrToFloatDef(ARecords.GetValue('10'), 0),  StrToFloatDef(ARecords.GetValue('20'), 0));
      LEntity.DefinitionPoint := Point2D(StrToFloatDef(ARecords.GetValue('13'), 0),  StrToFloatDef(ARecords.GetValue('23'), 0));
      LEntity.LeaderEndPoint  := Point2D(StrToFloatDef(ARecords.GetValue('14'), 0),  StrToFloatDef(ARecords.GetValue('24'), 0));
    finally
      LEntity.EndUpdate();
    end;

    Result := LEntity;
  end;

var
  LSubClass: string;
  LRecords: TUdStrStrHashMap;
  LStyleMode: Boolean;
  LEntity: TUdEntity;
begin
  LLayoutEntities := nil;
  LRecords := TUdStrStrHashMap.Create();
  LStyleRecords := TStringList.Create();
  try
    LStyleMode := False;
    repeat
      Self.ReadCurrentRecord();

      if not LStyleMode then
      begin
        if (Self.CurrRecord.Code = 1000) and (Self.CurrRecord.Value = 'DSTYLE') then
        begin
          Self.ReadCurrentRecord();
          if (Self.CurrRecord.Code = 1002) then
            LStyleMode := True;
        end
        else
          LRecords.Add(IntToStr(Self.CurrRecord.Code), Self.CurrRecord.Value);
      end
      else begin
        if (Self.CurrRecord.Code = 1002) then
          LStyleMode := False;

        if LStyleMode then
        begin
          LStyleRecords.Add(Self.CurrRecord.Value);

          Self.ReadCurrentRecord();
          if (Self.CurrRecord.Code = 1002) then LStyleMode := False;

          if LStyleMode then LStyleRecords.Add(Self.CurrRecord.Value);
        end;
      end;

    until (Self.CurrRecord.Code = 0);

    LEntity := nil;
    LSubClass := UpperCase(LRecords.GetValue('100'));

    if Pos('ALIGNEDDIMENSION'       , LSubClass) > 0 then LEntity := _ReadDimAligned(LRecords)       else
    if Pos('ROTATEDDIMENSION'       , LSubClass) > 0 then LEntity := _ReadDimRotated(LRecords)       else
    if Pos('ARCDIMENSION'           , LSubClass) > 0 then LEntity := _ReadDimArcLength(LRecords)     else
    if Pos('3POINTANGULARDIMENSION' , LSubClass) > 0 then LEntity := _ReadDim3PointAngular(LRecords) else
    if Pos('2LINEANGULARDIMENSION'  , LSubClass) > 0 then LEntity := _ReadDim2LineAngular(LRecords)  else
    if Pos('RADIALDIMENSIONLARGE'   , LSubClass) > 0 then LEntity := _ReadDimRadialLarge(LRecords)   else
    if Pos('RADIALDIMENSION'        , LSubClass) > 0 then LEntity := _ReadDimRadial(LRecords)        else
    if Pos('DIAMETRICDIMENSION'     , LSubClass) > 0 then LEntity := _ReadDimDiametric(LRecords)     else
    if Pos('ORDINATEDIMENSION'      , LSubClass) > 0 then LEntity := _ReadDimOrdinate(LRecords)   ;//else

    if Assigned(LEntity) then
    begin
      if Assigned(LLayoutEntities) then
        LLayoutEntities.Add(LEntity)
      else
        AEntities.Add(LEntity);
    end;
  finally
    LStyleRecords.Free();
    LRecords.Free();
  end;
end;

procedure TUdDxfReadEntites.AddTolerance(AEntities: TUdEntities);
var
  LText: string;
  LStyle: string;
  LStyleObj: TUdTextStyle;
  LInsPnt: TPoint2D;
  LEntity: TUdTolerance;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdTolerance.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  LText   := '';
  LStyle  := '';
  LInsPnt := Point2D(0, 0);

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        1 : LText     := Self.CurrRecord.Value;
        3 : LStyle    := Self.CurrRecord.Value;
        10: LInsPnt.X := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: LInsPnt.Y := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  if LText <> '' then
  begin
    LEntity.BeginUpdate();
    try
      LEntity.Point := LInsPnt;

      if LStyle = '' then LStyle := TUdDxfReader(FOwner).Header.ActiveTextStyle;
      LStyleObj := Self.Document.TextStyles.GetItem(LStyle);

      if not Assigned(LStyleObj) then
        LStyleObj := Self.Document.TextStyles.Standard;

      LEntity.TextHeight := LStyleObj.Height;
      LEntity.Contents := LText;
    finally
      LEntity.EndUpdate();
    end;

    if Assigned(LLayoutEntities) then
      LLayoutEntities.Add(LEntity)
    else
      AEntities.Add(LEntity);
  end
  else
    LEntity.Free;
end;

procedure TUdDxfReadEntites.AddLeader(AEntities: TUdEntities);
var
  L: Integer;
  LStyle: string;
  LStyleObj: TUdDimStyle;
  LPoints: TPoint2DArray;
  LSpline: Boolean;
  LShowArrow: Boolean;

  LEntity: TUdLeader;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdLeader.Create(Self.Document, False);
  InitEntity(LEntity);
  
  LLayoutEntities := nil;

  L := 0;
  LStyle := '';
  LPoints := nil;
  LSpline := False;
  LShowArrow := True;

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        3 : LStyle := Self.CurrRecord.Value;
        10:
        begin
          SetLength(LPoints, L + 1);
          LPoints[L].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        end;
        20:
        begin
          LPoints[L].Y := StrToFloatDef(Self.CurrRecord.Value, 0);
          L := L + 1;
        end;
        71: LShowArrow := StrToBoolDef(Self.CurrRecord.Value, True);
        72: LSpline    := StrToBoolDef(Self.CurrRecord.Value, False);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  if Length(LPoints) > 0 then
  begin
    LEntity.BeginUpdate();
    try
      LEntity.Spline := LSpline;
      LEntity.ShowArrow := LShowArrow;

      if LStyle = '' then
        LStyleObj := Self.Document.DimStyles.Standard
      else
        LStyleObj := Self.Document.DimStyles.GetItem(LStyle);
      if Assigned(LStyleObj) then LEntity.ArrowStyle1 := TUdArrowStyle(LStyleObj.ArrowsProp.ArrowFirst);

      LEntity.Points := LPoints;
    finally
      LEntity.EndUpdate();
    end;

    if Assigned(LLayoutEntities) then
      LLayoutEntities.Add(LEntity)
    else
      AEntities.Add(LEntity);
  end
  else
    LEntity.Free();
end;

procedure TUdDxfReadEntites.AddMLeader(AEntities: TUdEntities);
//var
  //...
//  LLayoutEntities: TUdEntities;
begin
  //...
//  LLayoutEntities := nil;

  repeat
    Self.ReadCurrentRecord();

//    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
//    begin
//      case Self.CurrRecord.Code of
//        10: X1 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        20: Y1 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        11: X2 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        21: Y2 := StrToFloatDef(Self.CurrRecord.Value, 0);
//      end;
//    end;
  until (Self.CurrRecord.Code = 0);

//  if Assigned(LLayoutEntities) then
//    LLayoutEntities.Add(LEntity)
//  else
//    AEntities.Add(LEntity);
end;




procedure TUdDxfReadEntites.AddHatch(AEntities: TUdEntities);

  procedure _AddPattenData(AHatch: TUdHatch; APatternName: string);
  var
    I, J, N: Integer;
    LAngle: Double;
    LCount: Integer;
    LOffPnt: TPoint2D;
    LOriginX, LOriginY: Double;
    LOffsetX, LOffsetY: Double;
    LPatternDashes: TFloatArray;
    LHatchPattern: TUdHatchPattern;
  begin
    LHatchPattern := TUdHatchPattern.Create(Self.Document, False);
    LHatchPattern.Name := APatternName;

    LCount := StrToIntDef(Self.CurrRecord.Value, 0); //78

    for I := 0 to LCount - 1 do
    begin
      Self.ReadCurrentRecord();
      if (Self.CurrRecord.Code <> 53) then Break;
      LAngle := StrToFloatDef(Self.CurrRecord.Value, 0.0);

      Self.ReadCurrentRecord();
      if (Self.CurrRecord.Code <> 43) then Break;
      LOriginX := StrToFloatDef(Self.CurrRecord.Value, 0.0);

      Self.ReadCurrentRecord();
      if (Self.CurrRecord.Code <> 44) then Break;
      LOriginY := StrToFloatDef(Self.CurrRecord.Value, 0.0);

      Self.ReadCurrentRecord();
      if (Self.CurrRecord.Code <> 45) then Break;
      LOffsetX := StrToFloatDef(Self.CurrRecord.Value, 0.0);

      Self.ReadCurrentRecord();
      if (Self.CurrRecord.Code <> 46) then Break;
      LOffsetY := StrToFloatDef(Self.CurrRecord.Value, 0.0);

      Self.ReadCurrentRecord();
      if (Self.CurrRecord.Code <> 79) then Break;
      N := StrToIntDef(Self.CurrRecord.Value, 0);
      
      SetLength(LPatternDashes, N);

      for J := 0 to N - 1 do
      begin
        Self.ReadCurrentRecord(); // 49
        LPatternDashes[J] := StrToFloatDef(Self.CurrRecord.Value, 0.0);
      end;

      if IsEqual(LOriginX, 0) then LOriginX := 0;
      if IsEqual(LOriginY, 0) then LOriginY := 0;
      
      if IsEqual(LOffsetX, 0) then LOffsetX := 0;
      if IsEqual(LOffsetY, 0) then LOffsetY := 0;

      if NotEqual(LAngle, 0.0) then
      begin
        LOffPnt := UdGeo2D.Rotate({Point2D(LOriginX, LOriginY),} -LAngle, Point2D(LOffsetX, LOffsetY));
        LOffsetX := LOffPnt.X;
        LOffsetY := LOffPnt.Y;

        if IsEqual(LOffsetX, 0) then LOffsetX := 0;
        if IsEqual(LOffsetY, 0) then LOffsetY := 0;
      end;
      
      LHatchPattern.PatternLines.Add(LAngle, LOriginX, LOriginY, LOffsetX, LOffsetY, LPatternDashes);
    end;

    AHatch.SetHatchPattern(LHatchPattern)
  end;

  procedure _AddPolyCurves(AEntity: TUdHatch; var AEntitesCount: Integer; var AHatchedHandle: string);
  var
    I, J, K: Integer;
    L, LL, M, N: Integer;
    LCount: Integer;

    LKind, LDegree: Integer;
    LP1, LP2: TPoint2D;
    LR, LA1, LA2: Float;
    LMajorR, LMinorR: Float;
    LArc: TArc2D;
    LEll: TEllipse2D;
    LSpline: TSpline2D;
    LSegment: TSegment2D;
    LVertexes: TVertexes2D;
    LCurves: TCurve2DArray;
    
    //LHatchStyle: Integer;
    LFlag, LHasBulge, LPolylineClosed: Boolean;
  begin
    LR := 0;
    LCurves := nil;

    I := 0;
    LCount := StrToIntDef(Self.CurrRecord.Value, 0);
    
    Self.ReadCurrentRecord();
    while (I < LCount) do
    begin
      if (Self.CurrRecord.Code <> 92) then Exit; //========>>>>>>>
      Inc(I);

      N := StrToIntDef(Self.CurrRecord.Value, 0); //int.Parse(currentRecord.ValueStr, NumberStyles.Any);
      LFlag := (N and 16) = 16;

      if ((N and 2) = 2) then
      begin
        Self.ReadCurrentRecord();
        if (Self.CurrRecord.Code <> 72) then Exit; //========>>>>>>>
        LHasBulge := StrToIntDef(Self.CurrRecord.Value, 0) = 1;

        Self.ReadCurrentRecord();
        if (Self.CurrRecord.Code <> 73) then Exit; //========>>>>>>>
        LPolylineClosed := (StrToIntDef(Self.CurrRecord.Value, 0) = 1);


        Self.ReadCurrentRecord();
        if (Self.CurrRecord.Code <> 93) then Exit; //========>>>>>>>
        M := StrToIntDef(Self.CurrRecord.Value, 0); //int.Parse(Self.CurrRecord.ValueStr, NumberStyles.Any);
        if (M = 0) then M := 1;

        SetLength(LVertexes, M);
        for J := 0 to M - 1 do // (int j = 0; j < M; j++)
        begin
          Self.ReadCurrentRecord();
          LVertexes[J].Point.X := StrToFloatDef(Self.CurrRecord.Value, 0.0); //Self.ReadDouble(Self.CurrRecord.ValueStr, VectorDraw.Serialize.Activator.GetNumberFormat());

          Self.ReadCurrentRecord();
          LVertexes[J].Point.Y := StrToFloatDef(Self.CurrRecord.Value, 0.0); //Self.ReadDouble(Self.CurrRecord.ValueStr, VectorDraw.Serialize.Activator.GetNumberFormat());

          if (LHasBulge) then
          begin
            Self.ReadCurrentRecord();
            LVertexes[J].Bulge := StrToFloatDef(Self.CurrRecord.Value, 0.0); //Self.ReadDouble(Self.CurrRecord.ValueStr, VectorDraw.Serialize.Activator.GetNumberFormat());
          end
          else
            LVertexes[J].Bulge := 0.0;
        end;

        if LPolylineClosed then
        begin
          if NotEqual(LVertexes[0].Point, LVertexes[M-1].Point) then
          begin
            SetLength(LVertexes, M+1);
            LVertexes[M] := Vertex2D(LVertexes[0].Point, 0);
          end;
        end;


        L := Length(LCurves);
        SetLength(LCurves, L + 1);

        LCurves[L].Kind := ckPolyline;
        LCurves[L].Data := New(PVertexes2D);
        SetLength(PVertexes2D(LCurves[L].Data)^, Length(LVertexes));
        for K := 0 to Length(LVertexes) - 1 do PVertexes2D(LCurves[L].Data)^[K] := LVertexes[K];
      end
      else begin
        Self.ReadCurrentRecord();
        if (Self.CurrRecord.Code <> 93) then Exit; //=======>>>>>

        LL := StrToIntDef(Self.CurrRecord.Value, 0);
        for J := 0 to LL - 1 do
        begin
          if (Self.CurrRecord.Code <> 72) then Self.ReadCurrentRecord();
          if (Self.CurrRecord.Code <> 72) then Exit; //=======>>>>>

          LKind := StrToIntDef(Self.CurrRecord.Value, 0); // int.Parse(Self.CurrRecord.ValueStr, NumberStyles.Any);
            
          case (LKind) of
            1:
            begin
              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 10) then Exit; //=========>>>>>
              LSegment.P1.X := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 20) then Exit; //=========>>>>>
              LSegment.P1.Y := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 11) then Exit; //=========>>>>>
              LSegment.P2.X := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 21) then Exit; //=========>>>>>
              LSegment.P2.Y := StrToFloatDef(Self.CurrRecord.Value, 0.0);


              L := Length(LCurves);
              SetLength(LCurves, L + 1);

              LCurves[L].Kind := ckLine;
              LCurves[L].Data := New(PSegment2D);
              PSegment2D(LCurves[L].Data)^ := LSegment;                
            end;

            2:
            begin
              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 10) then Exit; //=========>>>>>
              LArc.Cen.X := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 20) then Exit; //=========>>>>>
              LArc.Cen.Y := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 40) then Exit; //=========>>>>>
              LArc.R := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 50) then Exit; //=========>>>>>
              LArc.Ang1 := FixAngle(StrToFloatDef(Self.CurrRecord.Value, 0.0));

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 51) then Exit; //=========>>>>>
              LArc.Ang2 := FixAngle(StrToFloatDef(Self.CurrRecord.Value, 0.0));

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 73) then Exit; //=========>>>>>

              LArc.IsCW := (StrToIntDef(Self.CurrRecord.Value, 0) = 1);


              L := Length(LCurves);
              SetLength(LCurves, L + 1);

              LCurves[L].Kind := ckArc;
              LCurves[L].Data := New(PArc2D);
              PArc2D(LCurves[L].Data)^ := LArc;
            end;

            3:
            begin
              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 10) then Exit; //=========>>>>>
              LP1.X := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 20) then Exit; //=========>>>>>
              LP1.Y := StrToFloatDef(Self.CurrRecord.Value, 0.0);


              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 11) then Exit; //=========>>>>>
              LP2.x := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 21) then Exit; //=========>>>>>
              LP2.y := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 40) then Exit; //=========>>>>>
              LR := StrToFloatDef(Self.CurrRecord.Value, 1.0);


              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 50) then Exit; //=========>>>>>
              LA1 := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 51) then Exit; //=========>>>>>
              LA2 := StrToFloatDef(Self.CurrRecord.Value, 0.0);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 73) then Exit; //=========>>>>>
              LEll.IsCW := (StrToIntDef(Self.CurrRecord.Value, 0) = 1);

              LMajorR  := Sqrt(Sqr(LP2.X) + Sqr(LP2.Y));
              LMinorR  := LMajorR * LR; if LMinorR > LMajorR then LMinorR := LMajorR;
              LEll     := Ellipse2D(LP1, LMajorR, LMinorR, LA1, LA2, FixAngle(ArcTan2D(LP2.Y, LP2.X)), LEll.IsCW );

              L := Length(LCurves);
              SetLength(LCurves, L + 1);

              LCurves[L].Kind := ckEllipse;
              LCurves[L].Data := New(PEllipse2D);
              PEllipse2D(LCurves[L].Data)^ := LEll;
            end;

            4:
            begin
              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 94) then Exit; //=========>>>>>
              LDegree := StrToIntDef(Self.CurrRecord.Value, 2);

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 73) then Exit; //=========>>>>>
              {N := }StrToIntDef(Self.CurrRecord.Value, 2); //有理?

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 74) then Exit; //=========>>>>>
              {N := }StrToIntDef(Self.CurrRecord.Value, 2); //周期

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 95) then Exit; //=========>>>>>
              M := StrToIntDef(Self.CurrRecord.Value, 0); //节点数

              Self.ReadCurrentRecord();
              if (Self.CurrRecord.Code <> 96) then Exit; //=========>>>>>
              N := StrToIntDef(Self.CurrRecord.Value, 0); //控制点数


              LSpline.Degree := LDegree;
                
              SetLength(LSpline.Knots, M);
              for K := 0 to M - 1 do
              begin
                Self.ReadCurrentRecord(); //40
                LSpline.Knots[K] := StrToFloatDef(Self.CurrRecord.Value, 0);
              end;


              Self.ReadCurrentRecord();

              SetLength(LSpline.CtlPnts, N);

              for K := 0 to N - 1 do
              begin
                if (Self.CurrRecord.Code = 10) then
                  LSpline.CtlPnts[K].X := StrToFloatDef(Self.CurrRecord.Value, 0);

                Self.ReadCurrentRecord();
                if (Self.CurrRecord.Code = 20) then
                  LSpline.CtlPnts[K].Y := StrToFloatDef(Self.CurrRecord.Value, 0);
                    
                Self.ReadCurrentRecord();
                if (Self.CurrRecord.Code = 42) then
                begin
                  LR := StrToFloatDef(Self.CurrRecord.Value, 1);
                  Self.ReadCurrentRecord();
                end;
              end;

              if LR >= 0 then ;  

              L := Length(LCurves);
              SetLength(LCurves, L + 1);

              LCurves[L].Kind := ckSpline;
              LCurves[L].Data := New(PSpline2D);
              PSpline2D(LCurves[L].Data)^ := LSpline;                
            end;
          end;
        end;
      end;


      Self.ReadCurrentRecord();
      if (Self.CurrRecord.Code = 97) then
      begin
        AEntitesCount := StrToIntDef(Self.CurrRecord.Value, 0);

        Self.ReadCurrentRecord();
        while (Self.CurrRecord.Code = 330) do
        begin
          AHatchedHandle := Self.CurrRecord.Value;
          Self.ReadCurrentRecord();
        end;
      end;

      AEntity.AddCurves(LCurves);
      FreeCurveArray(LCurves);

      if LFlag then ;
      (*      
      if (LFlag) then
        LCurves.Operation = ClippingOperation.Difference;
      else begin
        LCurves.Operation = ClippingOperation.Union;
        AEntity.PolyCurves.ChangeOrder(LCurves, True);
      end;
      *)
    end;

    (*
    LHatchStyle := 0;
    
    AEntity.PolyCurves.MakeHatchValid();
    if (Self.CurrRecord.Code = 75) then
      LHatchStyle := StrToIntDef(Self.CurrRecord.Value, 0);

    if (LHatchStyle == 0) then
    begin
      IEnumerator enumerator = AEntity.PolyCurves.GetEnumerator();
      try
        while (enumerator.MoveNext()) do
        begin
          LCurves = (vdCurves)enumerator.Current;
          LCurves.Operation = ClippingOperation.XOr;
        end;
        goto IL_A43;
      finally
        IDisposable disposable := enumerator as IDisposable;
        if (disposable <> null) then disposable.Dispose();
      end;
    end;
    
    if (LHatchStyle == 2) then
    begin
      foreach (TCurves2D LCurves3 in AEntity.PolyCurves)
        LCurves3.Operation = ClippingOperation.Union;
    end;

    IL_A43:
    if (AEntity.HatchProperties <> null && !AEntity.PolyCurves.IsHatchValid())
    {
      AEntity.HatchProperties.HatchMode = vdRender.HatchingMethod.Linear;
    }
    *)
  end;

  
  
var
  LEntity: TUdHatch;
  LLayoutEntities: TUdEntities;

  LIsSolid: Boolean;
  LDoubleFlag: Integer;        // 77  填充图案双标志（仅限图案填充）：0 = 不是双标志；1 = 双标志
  LGradientFlag: Integer;      // 450 表示实体图案填充或渐变色；0 = 实体图案填充  1 = 渐变色
  LPatternName: string;        // 2   填充图案名
  LEntitesCount: Integer;      // 97	源边界对象数
  LHatchedHandle: string;
begin
  LEntity := TUdHatch.Create(Self.Document, False);
  InitEntity(LEntity);

  LLayoutEntities := nil;

  LIsSolid       := True;
  LDoubleFlag    := 0;
  LGradientFlag  := 0;

  LPatternName   := '';
  LEntitesCount  := 0;
  LHatchedHandle := '';


  LEntity.BeginUpdate();
  try
    repeat
      Self.ReadCurrentRecord();

      if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
      begin
        case Self.CurrRecord.Code of
          2   : LPatternName       := Self.CurrRecord.Value;
          41  : LEntity.HatchScale := StrToFloatDef(Self.CurrRecord.Value, 1.0);
          75  : LEntity.Style      := TUdHatchStyle(StrToIntDef(Self.CurrRecord.Value, 0));
          70  : LIsSolid           := StrToBoolDef(Self.CurrRecord.Value, True);
          77  : LDoubleFlag        := StrToIntDef(Self.CurrRecord.Value, 1);
          78  : _AddPattenData(LEntity, LPatternName);
          91  : _AddPolyCurves(LEntity, {var}LEntitesCount, {var}LHatchedHandle);
          52  : LEntity.HatchAngle := StrToFloatDef(Self.CurrRecord.Value, 0.0);
          97  : LEntitesCount := StrToIntDef(Self.CurrRecord.Value, 0);
          450 : LGradientFlag := StrToIntDef(Self.CurrRecord.Value, 0);
        end;
      end;
    until (Self.CurrRecord.Code = 0);

    if LIsSolid then
      LEntity.PatternName := 'SOLID';
//    else
//      LEntity.PatternName := LPatternName;  //_AddPattenData的时候设置过了

    if LDoubleFlag = 1 then ;
    if LGradientFlag = 1 then ;
  finally
    LEntity.EndUpdate();
  end;

 
  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;





{
66            :可变属性跟随标志（可选；默认值 = 0）；如果属性跟随标志的值为 1，则跟随插入的将是一系列属性图元，并以一个 seqend 图元终止
2             :块名
10, 20, 30    :插入点（在 OCS 中）DXF：X Y Z 值；APP：三维点
41, 42, 43    :X,Y,Z 缩放比例（可选；默认值 = 1）
50            :旋转角度（可选；默认值 = 0）
70            :列计数（可选；默认值 = 1）
71            :行计数（可选；默认值 = 1）
44            :列间距（可选；默认值 = 0）
45            :行间距（可选；默认值 = 0）
210, 220, 230 :X,Y,Z拉伸方向（可选；默认值 = 0, 0, 1）
}
procedure TUdDxfReadEntites.AddInsert(AEntities: TUdEntities);
var
  LBlockName: string;
  LScale: TPoint2D;
  LInsPnt: TPoint2D;
  LRotation: Float;

  LBlock: TUdBlock;
  LEntity: TUdInsert;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdInsert.Create(Self.Document, False);
  InitEntity(LEntity);

  LLayoutEntities := nil;

  LBlockName := '';
  LScale     := Point2D(1.0, 1.0);
  LInsPnt    := Point2D(0.0, 0.0);
  LRotation  := 0;

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
        2 : LBlockName := Self.CurrRecord.Value;
        10: LInsPnt.X  := StrToFloatDef(Self.CurrRecord.Value, 0.0);
        20: LInsPnt.Y  := StrToFloatDef(Self.CurrRecord.Value, 0.0);
        41: LScale.X   := StrToFloatDef(Self.CurrRecord.Value, 1.0);
        42: LScale.Y   := StrToFloatDef(Self.CurrRecord.Value, 1.0);
        50: LRotation  := StrToFloatDef(Self.CurrRecord.Value, 0.0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);

  LBlock := Self.Document.Blocks.GetItem(LBlockName);
  if Assigned(LBlock) then
  begin
    LEntity.BeginUpdate();
    try
      LEntity.Position := LInsPnt;
      LEntity.ScaleX   := LScale.X;
      LEntity.ScaleY   := LScale.Y;
      LEntity.Rotation := LRotation;
      LEntity.Block    := LBlock;
    finally
      LEntity.EndUpdate();
    end;

    if Assigned(LLayoutEntities) then
      LLayoutEntities.Add(LEntity)
    else
      AEntities.Add(LEntity);
  end
  else
    LEntity.Free();
end;









procedure TUdDxfReadEntites.AddImage(AEntities: TUdEntities);
//var
  //...
//  LLayoutEntities: TUdEntities;
begin
  //...
//  LLayoutEntities := nil;

  repeat
    Self.ReadCurrentRecord();

//    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
//    begin
//      case Self.CurrRecord.Code of
//        10: X1 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        20: Y1 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        11: X2 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        21: Y2 := StrToFloatDef(Self.CurrRecord.Value, 0);
//      end;
//    end;
  until (Self.CurrRecord.Code = 0);

//  if Assigned(LLayoutEntities) then
//    LLayoutEntities.Add(LEntity)
//  else
//    AEntities.Add(LEntity);
end;


procedure TUdDxfReadEntites.AddRegion(AEntities: TUdEntities);
//var
  //...
//  LLayoutEntities: TUdEntities;
begin
  //...
//  LLayoutEntities := nil;

  repeat
    Self.ReadCurrentRecord();

//    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
//    begin
//      case Self.CurrRecord.Code of
//        10: X1 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        20: Y1 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        11: X2 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        21: Y2 := StrToFloatDef(Self.CurrRecord.Value, 0);
//      end;
//    end;
  until (Self.CurrRecord.Code = 0);

//  if Assigned(LLayoutEntities) then
//    LLayoutEntities.Add(LEntity)
//  else
//    AEntities.Add(LEntity);
end;

procedure TUdDxfReadEntites.AddTrace(AEntities: TUdEntities);
var
  LPoints: TPoint2DArray;
  LEntity: TUdSolid;
  LLayoutEntities: TUdEntities;
begin
  LEntity := TUdSolid.Create(Self.Document, False);
  InitEntity(LEntity);

  LLayoutEntities := nil;

//  LThickness := 0;
  SetLength(LPoints, 4);

  repeat
    Self.ReadCurrentRecord();

    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
    begin
      case Self.CurrRecord.Code of
//        39: LThickness := StrToFloatDef(Self.CurrRecord.Value, 0);

        10: LPoints[0].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        20: LPoints[0].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

        11: LPoints[1].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        21: LPoints[1].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

        12: LPoints[2].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        22: LPoints[2].Y := StrToFloatDef(Self.CurrRecord.Value, 0);

        13: LPoints[3].X := StrToFloatDef(Self.CurrRecord.Value, 0);
        23: LPoints[3].Y := StrToFloatDef(Self.CurrRecord.Value, 0);
      end;
    end;
  until (Self.CurrRecord.Code = 0);


  LEntity.BeginUpdate();
  try
    LEntity.P1 := LPoints[0];
    LEntity.P2 := LPoints[1];
    LEntity.P3 := LPoints[2];
    LEntity.P4 := LPoints[3];
  finally
    LEntity.EndUpdate();
  end;

  if Assigned(LLayoutEntities) then
    LLayoutEntities.Add(LEntity)
  else
    AEntities.Add(LEntity);
end;

procedure TUdDxfReadEntites.AddTable(AEntities: TUdEntities);
//var
  //...
//  LLayoutEntities: TUdEntities;
begin
  //...
//  LLayoutEntities := nil;

  repeat
    Self.ReadCurrentRecord();

//    if not ReadCommonProp(LEntity, Self.CurrRecord, LLayoutEntities) then
//    begin
//      case Self.CurrRecord.Code of
//        10: X1 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        20: Y1 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        11: X2 := StrToFloatDef(Self.CurrRecord.Value, 0);
//        21: Y2 := StrToFloatDef(Self.CurrRecord.Value, 0);
//      end;
//    end;
  until (Self.CurrRecord.Code = 0);

//  if Assigned(LLayoutEntities) then
//    LLayoutEntities.Add(LEntity)
//  else
//    AEntities.Add(LEntity);
end;






procedure TUdDxfReadEntites.AddViewport(AEntities: TUdEntities);
var
  LWidth     : Float;
  LHeight    : Float;
  LCenter    : TPoint2D;
  LHeight2   : Float;
  LCenter2   : TPoint2D;
  LBasePoint : TPoint2D;
  LSnapSpace : TPoint2D;
  LGridSpace : TPoint2D;

  LLayout: TUDLayout;
  LLayoutRec: PUdDxfLayoutRec;
  LBlockHandle: string;    
begin
  LLayout := nil;
  LLayoutRec := nil;

  if (FVPortCount in [0, 1]) then
  begin
    LWidth   := -1;
    LHeight  := -1;
    LHeight2 := -1;
    LCenter  := Point2D(0, 0);
    LCenter2 := Point2D(0, 0);

    LBasePoint  := Point2D(0, 0);
    LSnapSpace  := Point2D(10, 10);
    LGridSpace  := Point2D(10, 10);


    repeat
      Self.ReadCurrentRecord();

      case Self.CurrRecord.Code of
        330 : LBlockHandle := Self.CurrRecord.Value;

        10  : LCenter.X  := StrToFloatDef(Self.CurrRecord.Value, 0);
        20  : LCenter.Y  := StrToFloatDef(Self.CurrRecord.Value, 0);
        40  : LWidth     := StrToFloatDef(Self.CurrRecord.Value, -1);
        41  : LHeight    := StrToFloatDef(Self.CurrRecord.Value, -1);
        12  : LCenter2.X := StrToFloatDef(Self.CurrRecord.Value, 0);
        22  : LCenter2.Y := StrToFloatDef(Self.CurrRecord.Value, 0);
        45  : LHeight2   := StrToFloatDef(Self.CurrRecord.Value, -1);

        13  : LBasePoint.X := StrToFloatDef(Self.CurrRecord.Value, 0);
        23  : LBasePoint.Y := StrToFloatDef(Self.CurrRecord.Value, 0);
        14  : LSnapSpace.X := StrToFloatDef(Self.CurrRecord.Value, 10);
        24  : LSnapSpace.Y := StrToFloatDef(Self.CurrRecord.Value, 10);
        15  : LGridSpace.X := StrToFloatDef(Self.CurrRecord.Value, 10);
        25  : LGridSpace.Y := StrToFloatDef(Self.CurrRecord.Value, 10);
      end;
    until (Self.CurrRecord.Code = 0);

    if FIsBlock then
    begin
      if Assigned(AEntities.Owner) and AEntities.Owner.InheritsFrom(TUdLayout) then
      begin
        LLayout := TUdLayout(AEntities.Owner);
        LLayoutRec := TUdDxfReader(FOwner).GetLayoutRec(LLayout);
      end;
    end
    else begin
      LLayoutRec := TUdDxfReader(FOwner).GetLayoutRec(LBlockHandle);
      LLayout := TUdLayout(LLayoutRec^.Layout);
    end;

    if Assigned(LLayoutRec) and (LBlockHandle = LLayoutRec^.BlockHandle) then
    begin
      if FVPortCount = 0 then
      begin
        LLayoutRec^.PaperWidth  := LWidth;
        LLayoutRec^.PaperHeight := LHeight;
        LLayoutRec^.PaperCenter := LCenter;

        LLayout.Drafting.SnapGrid.Base := LBasePoint;
        LLayout.Drafting.SnapGrid.SnapSpace := LSnapSpace;
        LLayout.Drafting.SnapGrid.GridSpace := LGridSpace;
      end
      else begin
        LLayoutRec^.VPortWidth  := LWidth;
        LLayoutRec^.VPortHeight := LHeight;
        LLayoutRec^.VPortCenter := LCenter;

        LLayoutRec^.VPortLgCenter := LCenter2;
        LLayoutRec^.VPortLgHeight := LHeight2;
      end;
    end;

    Inc(FVPortCount);
  end
  else begin
    repeat
      Self.ReadCurrentRecord();
    until (Self.CurrRecord.Code = 0);
  end;
end;



//-----------------------------------------------------------------------------------------

type
  TFUdEntities = class(TUdEntities);

function TUdDxfReadEntites.ReadEntities(AEntities: TUdEntities): Boolean;
var
  N: Integer;
begin
  Result := False;
  if not Assigned(AEntities) then Exit; //=======>>>>


  TFUdEntities(AEntities).FLoading := True;
  try
    FVPortCount := 0;

    while Self.CurrRecord.Code <> 0 do Self.ReadCurrentRecord();

    while True do
    begin
      N := Integer(GEntityMap.GetValue(Self.CurrRecord.Value));

      if N = 0 then
      begin
        Self.ReadCurrentRecord();
        while Self.CurrRecord.Code <> 0 do Self.ReadCurrentRecord();
      end
      else begin
        case N of
          1  : AddLine(AEntities);
          2  : AddRay(AEntities);
          3  : AddXLine(AEntities);
          4  : AddMLine(AEntities);
          5  : AddCircle(AEntities);
          6  : AddArc(AEntities);
          7  : Add2D3DPolyline(AEntities);
          8  : AddLwPolyline(AEntities);
          9  : AddEllipse(AEntities);
          10 : AddSPline(AEntities);
          11 : AddPoint(AEntities);
          12 : AddDimension(AEntities);
          13 : AddTolerance(AEntities);
          14 : AddLeader(AEntities);
          15 : AddMLeader(AEntities);
          16 : AddText(AEntities);
          17 : AddMtext(AEntities);
          18 : AddAttDef(AEntities);
          19 : AddHatch(AEntities);
          20 : AddInsert(AEntities);
          21 : AddSolid(AEntities);
          22 : AddTrace(AEntities);
          23 : AddViewport(AEntities);

          24 : AddImage(AEntities);
          25 : AddRegion(AEntities);
          26 : AddTable(AEntities);


          100: Break;
        end;
      end;
    end;
  finally
    TFUdEntities(AEntities).FLoading := False;
  end;

  Result := True;
end;

procedure TUdDxfReadEntites.Execute();
begin
  Self.ReadCurrentRecord();
  ReadEntities(Self.Document.ModelSpace.Entities);
end;






//======================================================================================

initialization
  GEntityMap := TUdStrHashMap.Create();
  InitEntityHashMap();

finalization
  GEntityMap.Free;
  GEntityMap := nil;


end.