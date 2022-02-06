{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdRect;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdConsts, UdTypes, UdGTypes,
  UdIntfs, UdObject, UdEntity, UdFigure, UdAxes;

type

  //-----------------------------------------------------
  TUdRect = class(TUdFigure, IUdExplode)
  private
    FCenter: TPoint2D;

    FWidth: Float;
    FHeight: Float;
    FRotation: Float;

    FCornerR: Float;  //Corner Radius
    FChamfer: Boolean;

    FSimpleGrip: Boolean;

  protected
    function GetTypeID(): Integer; override;

    procedure CheckCornerR();

    procedure SetCenter(const AValue: TPoint2D);
    procedure SetWidth(const AValue: Float);
    procedure SetHeight(const AValue: Float);
    procedure SetRotation(const AValue: Float);
    procedure SetCornerR(const AValue: Float);
    procedure SetChamfer(const AValue: Boolean);

    function GetCenterValue(AIndex: Integer): Float;
    procedure SetCenterValue(AIndex: Integer; const AValue: Float);

    function GetXData: TSegarc2DArray;

    function CanFilled(): Boolean; override;

    procedure UpdateBoundsRect(AAxes: TUdAxes); override;
    procedure UpdateSamplePoints(AAxes: TUdAxes); override;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetGripPoints(): TUdGripPointArray; override;
    function GetOSnapPoints(): TUdOSnapPointArray; override;

    procedure SetRect(ARect: TRect2D);

    { operation... }
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;

    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;

    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Offset(ADis: Float; ASidePnt: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;
    function BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray; override;
    function Intersect(AOther: TUdEntity): TPoint2DArray; override;
    function Perpend(APnt: TPoint2D): TPoint2DArray; override;

    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;
    function Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray; override;
    function Explode(): TUdObjectArray;

    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

  public
    property XData : TSegarc2DArray read GetXData;
    property Center: TPoint2D read FCenter write SetCenter;
    property SimpleGrip: Boolean read FSimpleGrip write FSimpleGrip;

  published
    property CenterX : Float index 0 read GetCenterValue write SetCenterValue;
    property CenterY : Float index 1 read GetCenterValue write SetCenterValue;

    property Width   : Float   read FWidth    write SetWidth   ;
    property Height  : Float   read FHeight   write SetHeight  ;
    property Rotation: Float   read FRotation write SetRotation;

    property CornerRadius: Float read FCornerR  write SetCornerR ;
    property Chamfer     : Boolean read FChamfer  write SetChamfer ;

    property Filled;
    property FillStyle;

    property HasBorder;
    property BorderColor;
  end;

implementation

uses
  SysUtils,
  UdMath, UdGeo2D, UdUtils, UdStrConverter,
  UdStreams, UdXml, UdColls, UdLine, UdArc, UdPolyline;




//==================================================================================================
{ TUdRect }

constructor TUdRect.Create();
begin
  inherited;

  FCenter := Point2D(0, 0);

  FWidth   := 20.0;
  FHeight  := 15.0;
  FRotation:= 0.0;

  FCornerR := 0.0;  //Corner Radius
  FChamfer := False;

  FSimpleGrip := False;
end;

destructor TUdRect.Destroy;
begin
  inherited;
end;



function TUdRect.GetTypeID: Integer;
begin
  Result := ID_RECT;
end;

//function TUdRect.GetCenter(): PPoint2D;
//begin
//  Result := @FCenter;
//end;


//-----------------------------------------------------------------------------------------

procedure TUdRect.CheckCornerR();
var
  LMaxR: Float;
begin
  LMaxR := Min(FWidth, FHeight) / 2;
  if FCornerR > LMaxR then FCornerR := LMaxR;
end;

procedure TUdRect.SetCenter(const AValue: TPoint2D);
begin
  if NotEqual(FCenter, AValue) and Self.RaiseBeforeModifyObject('Center') then
  begin
    FCenter := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Center');
  end;
end;


procedure TUdRect.SetWidth(const AValue: Float);
begin
  if (AValue > 0.0) and NotEqual(FWidth, AValue) and Self.RaiseBeforeModifyObject('Width') then
  begin
    FWidth := AValue;
    CheckCornerR();
    Self.Update();
    Self.RaiseAfterModifyObject('Width');
  end;
end;

procedure TUdRect.SetHeight(const AValue: Float);
begin
  if (AValue > 0.0) and NotEqual(FHeight, AValue) and Self.RaiseBeforeModifyObject('Height') then
  begin
    FHeight := AValue;
    CheckCornerR();
    Self.Update();
    Self.RaiseAfterModifyObject('Height');
  end;
end;

procedure TUdRect.SetRotation(const AValue: Float);
begin
  if NotEqual(FRotation, AValue) and Self.RaiseBeforeModifyObject('Rotation') then
  begin
    FRotation := AValue;
    CheckCornerR();
    Self.Update();
    Self.RaiseAfterModifyObject('Rotation');
  end;
end;



procedure TUdRect.SetCornerR(const AValue: Float);
begin
  if (AValue > 0) and (FCornerR <> AValue) and Self.RaiseBeforeModifyObject('CornerR') then
  begin
    FCornerR := AValue;
    CheckCornerR();
    Self.Update();
    Self.RaiseAfterModifyObject('CornerR');
  end;
end;

procedure TUdRect.SetChamfer(const AValue: Boolean);
begin
  if (FChamfer <> AValue) and Self.RaiseBeforeModifyObject('Chamfer') then
  begin
    FChamfer := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Chamfer');
  end;
end;



function TUdRect.GetCenterValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FCenter.X;
    1: Result := FCenter.Y;
  end;
end;

procedure TUdRect.SetCenterValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FCenter;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FCenter) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('CenterX');
    1: Self.RaiseBeforeModifyObject('CenterY');
  end;

  FCenter := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('CenterX');
    1: Self.RaiseAfterModifyObject('CenterY');
  end;
end;



function TUdRect.GetXData: TSegarc2DArray;

  procedure _GetSegarcs(var ASegarcs: TSegarc2DArray);
  var
    LEqWid, LEqHgt: Boolean;
  begin
    ASegarcs := nil;

    if IsEqual(FCornerR, 0.0) or (FCornerR < 0.0) then
    begin
      System.SetLength(ASegarcs, 4);
      ASegarcs[0] := Segarc2D(Point2D(-FWidth/2,  FHeight/2), Point2D(FWidth/2,  FHeight/2));
      ASegarcs[1] := Segarc2D(Point2D( FWidth/2,  FHeight/2), Point2D(FWidth/2, -FHeight/2));
      ASegarcs[2] := Segarc2D(Point2D( FWidth/2, -FHeight/2), Point2D(-FWidth/2,-FHeight/2));
      ASegarcs[3] := Segarc2D(Point2D(-FWidth/2, -FHeight/2), Point2D(-FWidth/2, FHeight/2));
    end
    else begin
      LEqWid := IsEqual(FWidth/2, FCornerR);
      LEqHgt := IsEqual(FHeight/2, FCornerR);

      if LEqHgt and LEqWid then
      begin
        if FChamfer then
        begin
          System.SetLength(ASegarcs, 4);
          ASegarcs[0] := Segarc2D(Point2D(-FWidth/2,  0),  Point2D(0, FHeight/2));
          ASegarcs[1] := Segarc2D(Point2D( FHeight/2,  0), Point2D(FWidth/2,  0));
          ASegarcs[2] := Segarc2D(Point2D(FWidth/2,  0),   Point2D(0, -FHeight/2));
          ASegarcs[3] := Segarc2D(Point2D(0, -FHeight/2),  Point2D(-FWidth/2,  0));
        end
        else begin
          System.SetLength(ASegarcs, 1);
          ASegarcs[0] := Segarc2D(Arc2D(0, 0, FCornerR, 0, 360, False));
        end;
      end
      else
      if LEqHgt then
      begin
        if FChamfer then
        begin
          System.SetLength(ASegarcs, 6);
          ASegarcs[0] := Segarc2D(Point2D(-FWidth/2,  0),  Point2D(-FWidth/2 + FCornerR,  FHeight/2));
          ASegarcs[1] := Segarc2D(Point2D(-FWidth/2 + FCornerR,  FHeight/2 ),  Point2D( FWidth/2 - FCornerR,  FHeight/2));
          ASegarcs[2] := Segarc2D(Point2D( FWidth/2 - FCornerR,  FHeight/2),   Point2D(FWidth/2,  0));
          ASegarcs[3] := Segarc2D(Point2D(FWidth/2,  0), Point2D( FWidth/2 - FCornerR,  -FHeight/2));
          ASegarcs[4] := Segarc2D(Point2D( FWidth/2 - FCornerR, -FHeight/2), Point2D( -FWidth/2 + FCornerR, -FHeight/2));
          ASegarcs[5] := Segarc2D(Point2D(-FWidth/2 + FCornerR, -FHeight/2), Point2D(-FWidth/2,  0));
        end
        else begin
          System.SetLength(ASegarcs, 4);
          ASegarcs[0] := Segarc2D(Arc2D(-FWidth/2 + FCornerR, 0, FCornerR, 90, 270, True));
          ASegarcs[1] := Segarc2D(Point2D(-FWidth/2 + FCornerR,  FHeight/2 ),  Point2D( FWidth/2 - FCornerR,  FHeight/2));
          ASegarcs[2] := Segarc2D(Arc2D( FWidth/2 - FCornerR, 0, FCornerR, 270, 90, True));
          ASegarcs[3] := Segarc2D(Point2D( FWidth/2 - FCornerR, -FHeight/2), Point2D( -FWidth/2 + FCornerR, -FHeight/2));
        end;
      end
      else
      if LEqWid then
      begin
        if FChamfer then
        begin
          System.SetLength(ASegarcs, 6);
          ASegarcs[0] := Segarc2D(Point2D(-FWidth/2,  FHeight/2 - FCornerR),  Point2D(0, FHeight/2));
          ASegarcs[1] := Segarc2D(Point2D(0, FHeight/2),  Point2D( FWidth/2,  FHeight/2- FCornerR));
          ASegarcs[2] := Segarc2D(Point2D( FWidth/2,  FHeight/2- FCornerR),   Point2D( FWidth/2,  -FHeight/2 + FCornerR));
          ASegarcs[3] := Segarc2D(Point2D( FWidth/2,  -FHeight/2 + FCornerR), Point2D(0,  -FHeight/2));
          ASegarcs[4] := Segarc2D(Point2D(0,  -FHeight/2), Point2D( -FWidth/2, -FHeight/2 + FCornerR));
          ASegarcs[5] := Segarc2D(Point2D( -FWidth/2, -FHeight/2 + FCornerR), Point2D(-FWidth/2,  FHeight/2 - FCornerR));
        end
        else begin
          System.SetLength(ASegarcs, 4);
          ASegarcs[0] := Segarc2D(Arc2D(0, FHeight/2 - FCornerR,  FCornerR, 0, 180, True));
          ASegarcs[1] := Segarc2D(Point2D(FWidth/2,  FHeight/2 - FCornerR ),  Point2D(FWidth/2,  -FHeight/2 + FCornerR ));
          ASegarcs[2] := Segarc2D(Arc2D(0, -FHeight/2 + FCornerR, FCornerR, 180, 360, True));
          ASegarcs[3] := Segarc2D( Point2D(-FWidth/2,  -FHeight/2 + FCornerR ), Point2D(-FWidth/2,  FHeight/2 - FCornerR ));
        end;
      end
      else begin
        System.SetLength(ASegarcs, 8);
        if FChamfer then
        begin
          ASegarcs[0] := Segarc2D(Point2D(-FWidth/2,  FHeight/2 - FCornerR), Point2D(-FWidth/2 + FCornerR,  FHeight/2));
          ASegarcs[1] := Segarc2D(Point2D(-FWidth/2 + FCornerR,  FHeight/2), Point2D( FWidth/2 - FCornerR,  FHeight/2));
          ASegarcs[2] := Segarc2D(Point2D( FWidth/2 - FCornerR,  FHeight/2), Point2D( FWidth/2,  FHeight/2 - FCornerR));
          ASegarcs[3] := Segarc2D(Point2D( FWidth/2,  FHeight/2 - FCornerR), Point2D( FWidth/2, -FHeight/2 + FCornerR));
          ASegarcs[4] := Segarc2D(Point2D( FWidth/2, -FHeight/2 + FCornerR), Point2D( FWidth/2 - FCornerR, -FHeight/2));
          ASegarcs[5] := Segarc2D(Point2D( FWidth/2 - FCornerR, -FHeight/2), Point2D( -FWidth/2 + FCornerR, -FHeight/2));
          ASegarcs[6] := Segarc2D(Point2D(-FWidth/2 + FCornerR, -FHeight/2), Point2D( -FWidth/2 , -FHeight/2 + FCornerR));
          ASegarcs[7] := Segarc2D(Point2D(-FWidth/2, -FHeight/2 + FCornerR), Point2D( -FWidth/2 , FHeight/2 - FCornerR));
        end
        else begin
          ASegarcs[0] := Segarc2D(Arc2D(-FWidth/2+FCornerR, FHeight/2-FCornerR, FCornerR, 90, 180, True));
          ASegarcs[1] := Segarc2D(Point2D(-FWidth/2 + FCornerR,  FHeight/2), Point2D( FWidth/2 - FCornerR,  FHeight/2));
          ASegarcs[2] := Segarc2D(Arc2D(FWidth/2-FCornerR,  FHeight/2-FCornerR, FCornerR, 0, 90, True));
          ASegarcs[3] := Segarc2D(Point2D( FWidth/2,  FHeight/2 - FCornerR), Point2D( FWidth/2, -FHeight/2 + FCornerR));
          ASegarcs[4] := Segarc2D(Arc2D(FWidth/2-FCornerR, -FHeight/2+FCornerR, FCornerR, 270, 360, True));
          ASegarcs[5] := Segarc2D(Point2D( FWidth/2 - FCornerR, -FHeight/2), Point2D( -FWidth/2 + FCornerR, -FHeight/2));
          ASegarcs[6] := Segarc2D(Arc2D(-FWidth/2+FCornerR,-FHeight/2+FCornerR, FCornerR, 180, 270, True));
          ASegarcs[7] := Segarc2D(Point2D(-FWidth/2, -FHeight/2 + FCornerR), Point2D( -FWidth/2 , FHeight/2 - FCornerR));
        end;
      end;
    end;
  end;

var
  LSegarcs: TSegarc2DArray;
begin
  Result := nil;

  _GetSegarcs(LSegarcs);

  if System.Length(LSegarcs) > 0 then
  begin
    if NotEqual(FRotation, 0.0) then
      LSegarcs := UdGeo2D.Rotate(FRotation, LSegarcs);
    Result := UdGeo2D.Translate(FCenter.X, FCenter.Y, LSegarcs);
  end;
end;


procedure TUdRect.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdRect) then Exit; //========>>>

  Self.FCenter := TUdRect(AValue).FCenter;

  Self.FWidth   := TUdRect(AValue).FWidth   ;
  Self.FHeight  := TUdRect(AValue).FHeight  ;
  Self.FRotation:= TUdRect(AValue).FRotation;

  Self.FCornerR := TUdRect(AValue).FCornerR ;  //Corner Radius
  Self.FChamfer := TUdRect(AValue).FChamfer ;

  Self.Update();
end;


procedure TUdRect.SetRect(ARect: TRect2D);
begin
  Self.FCenter := MidPoint(ARect.P1, ARect.P2);

  Self.FWidth   := Abs(ARect.P2.X - ARect.P1.X);
  Self.FHeight  := Abs(ARect.P2.Y - ARect.P1.Y);
  Self.FRotation:= 0;
  Self.FCornerR := 0 ;
  Self.FChamfer := False;

  Self.Update();
end;


//-----------------------------------------------------------------------------------------

function TUdRect.CanFilled(): Boolean;
begin
  Result := True;
end;

procedure TUdRect.UpdateBoundsRect(AAxes: TUdAxes);
begin
  FBoundsRect := UdGeo2D.RectHull(Self.GetXData());
end;

procedure TUdRect.UpdateSamplePoints(AAxes: TUdAxes);
begin
  FSamplePoints := UdGeo2D.SamplePoints(Self.GetXData(), False);
end;



function TUdRect.GetGripPoints(): TUdGripPointArray;
var
  I: Integer;
  LAng: Float;
  LPnt: TPoint2D;
begin
  if FSimpleGrip then
  begin
    System.SetLength(Result, 4);

//    Result[0] := MakeGripPoint(Self, gmCenter, 0, FCenter, 0.0);

    LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation, FWidth/2), FixAngle(FRotation + 90), FHeight/2);
    Result[0] := MakeGripPoint(Self, gmPoint, 1, LPnt, 0.0);

    LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation+180, FWidth/2), FixAngle(FRotation + 90), FHeight/2);
    Result[1] := MakeGripPoint(Self, gmPoint, 2, LPnt, 0.0);

    LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation+180, FWidth/2), FixAngle(FRotation - 90), FHeight/2);
    Result[2] := MakeGripPoint(Self, gmPoint, 3, LPnt, 0.0);

    LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation, FWidth/2), FixAngle(FRotation - 90), FHeight/2);
    Result[3] := MakeGripPoint(Self, gmPoint, 4, LPnt, 0.0);
  end
  else begin
    System.SetLength(Result, 9);

    Result[0] := MakeGripPoint(Self, gmCenter, 0, FCenter, 0.0);

    for I := 1 to 4 do
    begin
      LAng := FRotation + (I - 1) * 90;
      if Odd(I) then
      begin
        LPnt := ShiftPoint(FCenter, LAng, FWidth/2);
        Result[I] := MakeGripPoint(Self, gmSize, 1, LPnt, (I - 1) * 90);
      end
      else begin
        LPnt := ShiftPoint(FCenter, LAng, FHeight/2);
        Result[I] := MakeGripPoint(Self, gmSize, 2, LPnt, (I - 1) * 90);
      end;
    end;

    LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation, FWidth/2), FixAngle(FRotation + 90), FHeight/2);
    Result[5] := MakeGripPoint(Self, gmSize, 3, LPnt, 0.0);

    LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation+180, FWidth/2), FixAngle(FRotation + 90), FHeight/2);
    Result[6] := MakeGripPoint(Self, gmSize, 3, LPnt, 0.0);

    LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation+180, FWidth/2), FixAngle(FRotation - 90), FHeight/2);
    Result[7] := MakeGripPoint(Self, gmSize, 3, LPnt, 0.0);

    LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation, FWidth/2), FixAngle(FRotation - 90), FHeight/2);
    Result[8] := MakeGripPoint(Self, gmSize, 3, LPnt, 0.0);
  end;

//  Result[9] := MakeGripPoint(gmRotation, 0, FCenter, FRotation);
end;

function TUdRect.GetOSnapPoints: TUdOSnapPointArray;
var
  I, L: Integer;
  LAng: Float;
  LSegarcs: TSegarc2DArray;
begin
  LSegarcs := Self.GetXData();
  L := System.Length(LSegarcs);

  System.SetLength(Result, L*2);
  for I := 0 to L - 1 do
  begin
    LAng := UdGeo2D.GetAngle(LSegarcs[I].Seg.P1, LSegarcs[I].Seg.P2);
    Result[2*I]     := MakeOSnapPoint(Self, OSNP_END, LSegarcs[I].Seg.P1, LAng);
    Result[2*I + 1] := MakeOSnapPoint(Self, OSNP_MID, UdGeo2D.MidPoint(LSegarcs[I]), LAng);
  end;
end;






//-----------------------------------------------------------------------------------------

function TUdRect.MoveGrip(AGripPnt: TUdGripPoint): Boolean;

  procedure _MovePointSize(AGripPnt: TUdGripPoint);
  var
    LPnt: TPoint2D;
  begin
    LPnt := Point2D(0, 0);
    if not (AGripPnt.Index in [1..4]) then Exit;

    case AGripPnt.Index of
      1: LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation+180, FWidth/2), FixAngle(FRotation - 90), FHeight/2);
      2: LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation, FWidth/2), FixAngle(FRotation - 90), FHeight/2);
      3: LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation, FWidth/2), FixAngle(FRotation + 90), FHeight/2);
      4: LPnt := ShiftPoint(ShiftPoint(FCenter, FRotation+180, FWidth/2), FixAngle(FRotation + 90), FHeight/2);
    end;

    Self.RaiseBeforeModifyObject('');

    FCenter := UdGeo2D.MidPoint(LPnt, AGripPnt.Point);
    FWidth  := UdGeo2D.Distance(LPnt, UdGeo2D.ClosestLinePoint(AGripPnt.Point, LineK(LPnt, FRotation)));
    FHeight := UdGeo2D.Distance(LPnt, UdGeo2D.ClosestLinePoint(AGripPnt.Point, LineK(LPnt, FRotation + 90)));

    Self.Update();

    Self.RaiseAfterModifyObject('');
  end;

var
  LDis, LDis1: Float;
  LnK: TLineK;
begin
  Result := False;

  case AGripPnt.Mode of
    gmCenter: Result := Self.Move(FCenter, AGripPnt.Point);

    gmSize:
      begin
        LDis := Distance(AGripPnt.Point, FCenter);

        if AGripPnt.Index = 1 then Self.Width  := LDis * 2 else
        if AGripPnt.Index = 2 then Self.Height := LDis * 2 else
        if AGripPnt.Index = 3 then
        begin
          LnK := LineK(FCenter, FRotation + 90);
          LDis := DistanceToLine(AGripPnt.Point, LnK);

          LnK := LineK(FCenter, FRotation);
          LDis1 := DistanceToLine(AGripPnt.Point, LnK);

          if NotEqual(LDis, 0.0) and NotEqual(LDis1, 0.0) then
          begin
            Self.SetWidth( LDis * 2 );
            Self.SetHeight( LDis1 * 2 );
          end;
        end;

        Result := True;
      end;

    gmPoint:
      begin
        _MovePointSize(AGripPnt);
      end;
  end;
end;



function TUdRect.Pick(APoint: TPoint2D): Boolean;
var
  E: Float;
  LAxes: TUdAxes;
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  LAxes := Self.EnsureAxes(nil);

  E := DEFAULT_PICK_SIZE;
  if Assigned(LAxes) then E := E / LAxes.XPixelPerValue;

  LSegarcs := Self.GetXData();

//  if FPenWidth > 0.0 then
//  begin
//    D := DistanceToSegarcs(APoint, LSegarcs);
//    Result := (D < FPenWidth/2) or IsEqual(D, FPenWidth/2, E);
//  end
//  else
  Result := UdGeo2D.IsPntOnSegarcs(APoint, LSegarcs, E);
end;

function TUdRect.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  Result := UdGeo2D.Inclusion(FBoundsRect, ARect) = irOvered;

  if not Result and ACrossingMode then
    Result := UdGeo2D.IsIntersect(ARect, Self.GetXData());
end;

function TUdRect.Move(Dx, Dy: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter := UdGeo2D.Translate(Dx, Dy, FCenter);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdRect.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LnK: TLineK;
  MrLn: TLine2D;
  LPnts: TPoint2DArray;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  LnK := LineK(FCenter, FRotation);

  MrLn := Line2D(APnt1, APnt2);
  FCenter := UdGeo2D.Mirror(MrLn, FCenter);

  LPnts := Intersection(LnK, MrLn);
  if System.Length(LPnts) > 0 then
    FRotation := GetAngle(FCenter, LPnts[0]);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdRect.Offset(ADis: Float; ASidePnt: TPoint2D): Boolean;
var
  LWidth, LHeight: Float;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ADis, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  if IsPntInSegarcs(ASidePnt, GetXData()) then ADis := -ADis;

  LWidth := FWidth + 2*ADis;
  LHeight := FHeight + 2*ADis;
  if (LWidth <= 0) or IsEqual(LWidth, 0.0) or
     (LHeight <= 0) or IsEqual(LHeight, 0.0)  then Exit;

  FWidth := LWidth;
  FHeight := LHeight;
  CheckCornerR();

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdRect.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter := UdGeo2D.Rotate(ABase, ARota, FCenter );
  FRotation := FRotation + ARota;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdRect.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FCenter := UdGeo2D.Scale(ABase, AFactor, AFactor, FCenter);
  FWidth  := FWidth * AFactor;
  FHeight := FHeight * AFactor;
  FCornerR := FCornerR * AFactor;

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdRect.BreakAt(APnt1, APnt2: TPoint2D): TUdEntityArray;
var
  I: Integer;
  LPolyline: TUdPolyline;
  LSegarcs: TSegarc2DArray;
  LSegarcsArr: TSegarc2DArrays;
begin
  Result := nil;
  if Self.IsLock() then  Exit; //======>>>>

  LSegarcs := Self.GetXData();
  LSegarcsArr := UdGeo2D.BreakAt(LSegarcs,  APnt1, APnt2, True);

  System.SetLength(Result, System.Length(LSegarcsArr));
  for I := 0 to System.Length(LSegarcsArr) - 1 do
  begin
    LPolyline := TUdPolyline.Create({Self.Document, False});
    LPolyline.Assign(Self);
    LPolyline.Closed := False;
    LPolyline.XData := LSegarcsArr[I];

    Result[I] := LPolyline;
  end;
end;

function TUdRect.Intersect(AOther: TUdEntity): TPoint2DArray;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  if not Self.IsVisible or Self.IsLock() then Exit;
  if not AOther.IsVisible or AOther.IsLock() then Exit;

  Result := UdUtils.EntitiesIntersection(Self.GetXData(), AOther);
end;

function TUdRect.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  I: Integer;
  LLn: TLine2D;
  LPnt: TPoint2D;
  LArc: TArc2D;
  LSeg: TSegment2D;
  LSegarcs: TSegarc2DArray;
begin
  Result := nil;

  LSegarcs := Self.GetXData();
  for I := 0 to System.Length(LSegarcs) - 1 do
  begin
    if LSegarcs[I].IsArc then
    begin
      LArc := LSegarcs[I].Arc;
      LLn := UdGeo2D.Line2D(APnt, LArc.Cen);
      Result := UdGeo2D.Intersection(LLn, LArc);

      if System.Length(Result) > 0 then Break;
    end
    else begin
      LSeg := LSegarcs[I].Seg;

      LLn := UdGeo2D.Line2D(LSeg.P1, LSeg.P2);

      LPnt := UdGeo2D.ClosestLinePoint(APnt, LLn);
      if UdGeo2D.IsPntOnSegment(LPnt, LSeg) then
      begin
        System.SetLength(Result, 1);
        Result[0] := LPnt;
        Break;
      end;
    end;
  end;
end;


function TUdRect.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  I: Integer;
  LSegarcs: TSegarc2DArray;
begin
  LSegarcs := Self.GetXData();

  System.SetLength(Result, System.Length(LSegarcs));
  for I := 0 to System.Length(LSegarcs) - 1 do
  begin
    case LSegarcs[I].IsArc of
      True :
        begin
          Result[I] := TUdArc.Create({Self.Document, False});

          Result[I].BeginUpdate();
          try
            Result[I].Assign(Self);
            TUdArc(Result[I]).XData := LSegarcs[I].Arc;
          finally
            Result[I].EndUpdate();
          end;
        end;
      False:
        begin
          Result[I] := TUdLine.Create({Self.Document, False});

          Result[I].BeginUpdate();
          try
            Result[I].Assign(Self);
            TUdLine(Result[I]).XData := LSegarcs[I].Seg;
          finally
            Result[I].EndUpdate();
          end;
        end;
    end;
  end;
end;

function TUdRect.Trim(ASelectedEntities: TUdEntityArray; APnt: TPoint2D): TUdEntityArray;

  function _SegarcIntersection(ASegarc: TSegarc2D; AOtherEntities: TUdEntityArray): TPoint2DArray;
  var
    I, J: Integer;
    LInctPnts: TPoint2DArray;
    LInctPntList: TPoint2DList;
  begin
    Result := nil;

    LInctPnts := nil;
    LInctPntList := TPoint2DList.Create(MAXBYTE);
    try
      LInctPntList.Add(ASegarc.Seg.P1);

      for I := 0 to System.Length(AOtherEntities) - 1 do
      begin
        if Assigned(AOtherEntities[I]) and (AOtherEntities[I] <> Self) then
        begin
          LInctPnts := UdUtils.EntitiesIntersection(ASegarc, AOtherEntities[I]);
          for J := 0 to System.Length(LInctPnts) - 1 do LInctPntList.Add(LInctPnts[J]);
        end;
      end;

      LInctPntList.Add(ASegarc.Seg.P2);

      Result := LInctPntList.ToArray();
    finally
      LInctPntList.Free;
    end;
  end;

var
  N: Integer;
  LPnt: TPoint2D;
  LP1, LP2: TPoint2D;
  LSegarc: TSegarc2D;
  LSegarcs: TSegarc2DArray;
  LInctPnts: TPoint2DArray;
begin
  Result := nil;

  LSegarcs := Self.GetXData();
  LPnt := ClosestSegarcsPoint(APnt, LSegarcs, N);

  LSegarc := LSegarcs[N];
  LInctPnts := _SegarcIntersection(LSegarc, ASelectedEntities);

  if System.Length(LInctPnts) <= 0 then Exit; //======>>>>

  if LSegarc.IsArc then
    GetArcTrimBreakPnts(LSegarc.Arc, LPnt, LInctPnts, LP1, LP2)
  else
    GetSegTrimBreakPnts(LSegarc.Seg, LPnt, LInctPnts, LP1, LP2);

  Result := Self.BreakAt(LP1, LP2);
end;


function TUdRect.Explode(): TUdObjectArray;

  procedure _InitEntity(AEntity: TUdEntity);
  begin
    AEntity.Layer := FLayer;

    AEntity.Color.Assign(FColor);
    AEntity.LineType.Assign(FLineType);
    AEntity.LineWeight := FLineWeight;
  end;

var
  I: Integer;
  LSegarcs: TSegarc2DArray;
begin
  LSegarcs := Self.GetXData();
  System.SetLength(Result, System.Length(LSegarcs));

  for I := 0 to System.Length(LSegarcs) - 1 do
  begin
    if LSegarcs[I].IsArc then
    begin
      Result[I] := TUdArc.Create({Self.Document, False});
      _InitEntity(TUdEntity(Result[I]));
      TUdArc(Result[I]).XData := LSegarcs[I].Arc;
    end
    else begin
      Result[I] := TUdLine.Create({Self.Document, False});
      _InitEntity(TUdEntity(Result[I]));
      TUdLine(Result[I]).XData := LSegarcs[I].Seg;
    end;
  end;
end;



//-----------------------------------------------------------------------------------------

procedure TUdRect.SaveToStream(AStream: TStream);
begin
  inherited;

  FloatToStream(AStream, FCenter.X);
  FloatToStream(AStream, FCenter.Y);
  FloatToStream(AStream, FWidth   );
  FloatToStream(AStream, FHeight  );
  FloatToStream(AStream, FRotation);
  FloatToStream(AStream, FCornerR );
  BoolToStream( AStream, FChamfer );
  BoolToStream( AStream, FSimpleGrip );
end;

procedure TUdRect.LoadFromStream(AStream: TStream);
begin
  inherited;

  FCenter.X  := FloatFromStream(AStream);
  FCenter.Y  := FloatFromStream(AStream);
  FWidth     := FloatFromStream(AStream);
  FHeight    := FloatFromStream(AStream);
  FRotation  := FloatFromStream(AStream);
  FCornerR   := FloatFromStream(AStream);
  FChamfer   := BoolFromStream( AStream);
  FSimpleGrip:= BoolFromStream( AStream);

  Update();
end;



procedure TUdRect.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['Center']   := Point2DToStr(FCenter);
  LXmlNode.Prop['Width']    := FloatToStr(FWidth);
  LXmlNode.Prop['Height']   := FloatToStr(FHeight);
  LXmlNode.Prop['Rotation'] := FloatToStr(FRotation);
  LXmlNode.Prop['CornerR']  := FloatToStr(FCornerR);

  LXmlNode.Prop['Chamfer']    := BoolToStr(FChamfer, True);
  LXmlNode.Prop['SimpleGrip'] := BoolToStr(FSimpleGrip, True);
end;

procedure TUdRect.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FCenter   := StrToPoint2D(LXmlNode.Prop['Center']);
  FWidth    := StrToFloatDef(LXmlNode.Prop['Width'], 0);
  FHeight   := StrToFloatDef(LXmlNode.Prop['FHeight'], 0);
  FRotation := StrToFloatDef(LXmlNode.Prop['Rotation'], 0);
  FCornerR  := StrToFloatDef(LXmlNode.Prop['CornerR'], 0);

  FChamfer    := StrToBoolDef(LXmlNode.Prop['Chamfer']   , False);
  FSimpleGrip := StrToBoolDef(LXmlNode.Prop['SimpleGrip'], False);
end;

end.