{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimRotated;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdGTypes, UdConsts, UdObject, UdEntity,
  UdDimension, UdDimAligned;


type
  //*** TUdDimRotated ***//
  TUdDimRotated = class(TUdDimAligned)
  protected
    FRotation: Float;

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; override;

    procedure SetRotation(const AValue: Float);

    function GetDimLinePnts(var ADimP1, ADimP2: TPoint2D): Boolean; override;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;
        
  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetRotation(): Float; override;

    {operation...}
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;


    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;


  published
    property Rotation: Float read FRotation write SetRotation;

  end;


implementation


uses
  SysUtils,
  UdMath, UdGeo2D, UdStreams, UdXml;



//=================================================================================================
{ TUdDimRotated }

constructor TUdDimRotated.Create();
begin
  inherited;
  FRotation := 0.0;
end;

destructor TUdDimRotated.Destroy;
begin

  inherited;
end;

function TUdDimRotated.GetTypeID: Integer;
begin
  Result := ID_DIMROTATED;
end;

function TUdDimRotated.GetDimTypeID: Integer;
begin
  Result := 0;
end;


procedure TUdDimRotated.SetRotation(const AValue: Float);
begin
  if NotEqual(FRotation, AValue) and Self.RaiseBeforeModifyObject('Rotation') then
  begin
    FRotation := FixAngle(AValue);
    Self.Update();
    Self.RaiseAfterModifyObject('Rotation');
  end;
end;


procedure TUdDimRotated.CopyFrom(AValue: TUdObject);
begin
  inherited;

  if not AValue.InheritsFrom(TUdDimRotated) then Exit;

  FRotation := TUdDimRotated(AValue).FRotation;
  Self.Update();
end;



//----------------------------------------------------------------------------------------



function TUdDimRotated.GetRotation(): Float;
begin
  Result := FRotation;
end;

function TUdDimRotated.GetDimLinePnts(var ADimP1, ADimP2: TPoint2D): Boolean;
var
  LDimLn: TLineK;
begin
  LDimLn := LineK(FTextPoint, FRotation);

  ADimP1 := UdGeo2D.ClosestLinePoint(FExtLine1Point, LDimLn);
  ADimP2 := UdGeo2D.ClosestLinePoint(FExtLine2Point, LDimLn);

  Result := True;
end;




//----------------------------------------------------------------------------------------

function TUdDimRotated.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  LSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FExtLine1Point := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine1Point);
  FExtLine2Point := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FExtLine2Point);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FTextPoint);

  LSeg := Segment2D(FExtLine1Point, ShiftPoint(FExtLine1Point, FRotation, 5));
  LSeg := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LSeg);

  FRotation := GetAngle(LSeg.P2, LSeg.P1);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdDimRotated.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FExtLine1Point := UdGeo2D.Rotate(ABase, ARota, FExtLine1Point);
  FExtLine2Point := UdGeo2D.Rotate(ABase, ARota, FExtLine2Point);

  if IsValidPoint(FTextPoint) then
    FTextPoint := UdGeo2D.Rotate(ABase, ARota, FTextPoint);

  FRotation := FixAngle(FRotation + ARota);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;




//----------------------------------------------------------------------------------------

procedure TUdDimRotated.SaveToStream(AStream: TStream);
begin
  inherited;

  FloatToStream(AStream, FRotation);
end;

procedure TUdDimRotated.LoadFromStream(AStream: TStream);
begin
  inherited;

  FRotation := FloatFromStream(AStream);

  Self.Update();
end;




procedure TUdDimRotated.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);
  LXmlNode.Prop['Rotation'] := FloatToStr(FRotation);
end;

procedure TUdDimRotated.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode  := TUdXmlNode(AXmlNode);
  FRotation := StrToFloatDef(LXmlNode.Prop['Rotation'], 0.0);

  Self.Update();
end;

end.