{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdInsert;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics,
  UdConsts, UdTypes, UdGTypes,
  UdIntfs, UdObject, UdEntity, UdAxes, UdBlock, UdEntities;

type

  //-----------------------------------------------------


  TUdInsert = class(TUdEntity, IUdExplode, IUdChildEntities)
  private
    FBlock: TUdBlock;

    FScaleX: Float;
    FScaleY: Float;
    FRotation: Float;
    FPosition: TPoint2D;

    FEntities: TUdEntities;
//    FAttrList: TList;

  protected
    function GetTypeID(): Integer; override;
    procedure AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean); override;

    procedure SetBlock(const AValue: TUdBlock);

    procedure SetScaleX(const AValue: Float);
    procedure SetScaleY(const AValue: Float);

    procedure SetRotation(const AValue: Float);
    procedure SetPosition(const AValue: TPoint2D);

    function GetPositionValue(AIndex: Integer): Float;
    procedure SetPositionValue(AIndex: Integer; const AValue: Float);

    procedure StatesChanged(AIndex: Integer); override;
    procedure CalcEntities();

    function FDoUpdate(AAxes: TUdAxes): Boolean;
    function DoUpdate(AAxes: TUdAxes): Boolean; override;
    function DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean; override;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    function GetGripPoints(): TUdGripPointArray; override;
    function GetOSnapPoints(): TUdOSnapPointArray; override;

    {IUdChildEntities...}
    function GetChildEntities(): TList;

        
    { operation... }
    function MoveGrip(AGripPnt: TUdGripPoint): Boolean; override;

    function Pick(APoint: TPoint2D): Boolean; overload; override;
    function Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean; overload; override;

    function Move(Dx, Dy: Float): Boolean; override;
    function Mirror(APnt1, APnt2: TPoint2D): Boolean; override;
    function Rotate(ABase: TPoint2D; ARota: Float): Boolean; override;
    function Scale(ABase: TPoint2D; AFactor: Float): Boolean; override;

    function Explode(): TUdObjectArray;
    function ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray; override;

    function Intersect(AOther: TUdEntity): TPoint2DArray; override;
    function Perpend(APnt: TPoint2D): TPoint2DArray; override;


    { load&save... }
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

    procedure SaveToXml(AXmlNode: TObject; ANodeName: string = ''); override;
    procedure LoadFromXml(AXmlNode: TObject); override;

    { Attrib ... }
//    procedure ClearAttribs();
//    procedure AddAttrib(AName: string; AValue: string; AOffset: TPoint2D; AAlignment: TUdTextAlign; AHeight: Double; AWidthFactor: Double;
//      ARotaion: Double; ABackwards: Boolean = False; AUpsideDown: Boolean = False);

  public
    property Block   : TUdBlock read FBlock write SetBlock;
    property Entities: TUdEntities read FEntities;

    property Position: TPoint2D read FPosition write SetPosition;

  published
    property PositionX: Float index 0 read GetPositionValue write SetPositionValue;
    property PositionY: Float index 1 read GetPositionValue write SetPositionValue;

    property ScaleX  : Float read FScaleX   write SetScaleX  ;
    property ScaleY  : Float read FScaleY   write SetScaleY  ;
    property Rotation: Float read FRotation write SetRotation;

  end;


implementation

uses
  SysUtils, UdDocument, UdText,
  UdMath, UdGeo2D, UdUtils, UdStrConverter, UdStreams, UdXml;



type
  TUdAttrib = class(TObject)
  protected
    FName: string;
    FValue: string;
    FOffset: TPoint2D;
    FAlignment: TUdTextAlign;

    FHeight: Double;
    FWidthFactor: Double;
    FRotaion: Double;

    FBackwards: Boolean;
    FUpsideDown: Boolean;

  public
    constructor Create(); overload;
    constructor Create(AName, AValue: string; AOffset: TPoint2D; AAlignment: TUdTextAlign; AHeight, AWidthFactor, ARotaion: Double;
                       ABackwards: Boolean = False; AUpsideDown: Boolean = False); overload;
    destructor Destroy; override;

    procedure CopyFrom(ASrcObj: TUdAttrib);

  end;

{ TUdAttrib }

constructor TUdAttrib.Create();
begin
  FName  := '';
  FValue := '';
  FOffset.X := 0;
  FOffset.Y := 0;
  FAlignment := taTopLeft;

  FHeight      := 2.5;
  FWidthFactor := 1.0;
  FRotaion     := 0.0;

  FBackwards  := False;
  FUpsideDown := False;
end;

constructor TUdAttrib.Create(AName, AValue: string; AOffset: TPoint2D; AAlignment: TUdTextAlign; AHeight, AWidthFactor, ARotaion: Double;
                             ABackwards: Boolean = False; AUpsideDown: Boolean = False);
begin
  FName  := AName;
  FValue := AValue;
  FOffset := AOffset;
  FAlignment := AAlignment;

  FHeight      := AHeight;     //2.5;
  FWidthFactor := AWidthFactor;//1.0;
  FRotaion     := ARotaion;    //0.0;

  FBackwards  := ABackwards;
  FUpsideDown := AUpsideDown;
end;

destructor TUdAttrib.Destroy;
begin

  inherited;
end;


procedure TUdAttrib.CopyFrom(ASrcObj: TUdAttrib);
begin
  FName  := ASrcObj.FName;
  FValue := ASrcObj.FValue;

  FOffset      := ASrcObj.FOffset;
  FAlignment   := ASrcObj.FAlignment;

  FHeight      := ASrcObj.FHeight;     //2.5;
  FWidthFactor := ASrcObj.FWidthFactor;//1.0;
  FRotaion     := ASrcObj.FRotaion;    //0.0;

  FBackwards  := ASrcObj.FBackwards;
  FUpsideDown := ASrcObj.FUpsideDown;
end;


function FindAttrObj(AList: TList; AName: string): TUdAttrib;
var
  I: Integer;
  LName: string;
  LAttr: TUdAttrib;
begin
  Result := nil;
  LName := LowerCase(AName);
  for I := 0 to AList.Count - 1 do
  begin
    LAttr := TUdAttrib(AList[I]);
    if LowerCase(LAttr.FName) = LName then
    begin
      Result := LAttr;
      Break;
    end;
  end;
end;



//==================================================================================================
{ TUdInsert }

constructor TUdInsert.Create();
begin
  inherited;

  FBlock := nil;

  FScaleX := 1.0;
  FScaleY := 1.0;
  FRotation := 0.0;
  FPosition := Point2D(0, 0);

  FEntities := TUdEntities.Create();
  FEntities.Owner := Self;

//  FAttrList := TList.Create();
end;

destructor TUdInsert.Destroy;
begin
  FBlock := nil;

  if Assigned(FEntities) then FEntities.Free;
  FEntities := nil;

//  Self.ClearAttribs();

//  if Assigned(FAttrList) then FAttrList.Free;
//  FAttrList := nil;

  inherited;
end;




function TUdInsert.GetTypeID: Integer;
begin
  Result := ID_INSERT;
end;


procedure TUdInsert.AfterSetDocument(const AValue: TUdObject; AIsDocRegister: Boolean);
begin
  inherited;
  FEntities.SetDocument(Self.Document, False);
end;



//-----------------------------------------------------------------------------------------

procedure TUdInsert.SetBlock(const AValue: TUdBlock);
begin
  if (FBlock <> AValue) and Self.RaiseBeforeModifyObject('Block') then
  begin
    FBlock := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Block');
  end;
end;




procedure TUdInsert.SetScaleX(const AValue: Float);
begin
  if NotEqual(FScaleX, AValue) and Self.RaiseBeforeModifyObject('ScaleX') then
  begin
    FScaleX := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ScaleX');
  end;
end;

procedure TUdInsert.SetScaleY(const AValue: Float);
begin
  if NotEqual(FScaleY, AValue) and Self.RaiseBeforeModifyObject('ScaleY') then
  begin
    FScaleY := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('ScaleY');
  end;
end;

procedure TUdInsert.SetRotation(const AValue: Float);
begin
  if NotEqual(FRotation, AValue) and Self.RaiseBeforeModifyObject('Rotation') then
  begin
    FRotation := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Rotation');
  end;
end;

procedure TUdInsert.SetPosition(const AValue: TPoint2D);
//var
//  I: Integer;
begin
  if NotEqual(FPosition, AValue) and Self.RaiseBeforeModifyObject('Position') then
  begin
//    for I := 0 to FEntities.Count - 1 do
//      FEntities.Items[I].Move(FPosition, AValue);
    FPosition := AValue;
    Self.Update();
    Self.RaiseAfterModifyObject('Position');
  end;
end;



function TUdInsert.GetPositionValue(AIndex: Integer): Float;
begin
  Result := 0;
  case AIndex of
    0: Result := FPosition.X;
    1: Result := FPosition.Y;
  end;
end;

procedure TUdInsert.SetPositionValue(AIndex: Integer; const AValue: Float);
var
  LPnt: TPoint2D;
begin
  LPnt := FPosition;
  case AIndex of
    0: LPnt.X := AValue;
    1: LPnt.Y := AValue;
  end;
  if IsEqual(LPnt, FPosition) then Exit;

  case AIndex of
    0: Self.RaiseBeforeModifyObject('PositionX');
    1: Self.RaiseBeforeModifyObject('PositionY');
  end;

  FPosition := LPnt;
  Self.Update();

  case AIndex of
    0: Self.RaiseAfterModifyObject('PositionX');
    1: Self.RaiseAfterModifyObject('PositionY');
  end;
end;


//-----------------------------------------------------------------------------------------



procedure TUdInsert.CopyFrom(AValue: TUdObject);
//var
//  I: Integer;
//  LAttr: TUdAttrib;
begin
  inherited;
  if not AValue.InheritsFrom(TUdInsert) then Exit; //========>>>

  FBlock          := TUdInsert(AValue).FBlock;

  FScaleX         := TUdInsert(AValue).FScaleX;
  FScaleY         := TUdInsert(AValue).FScaleY;
  FRotation       := TUdInsert(AValue).FRotation;
  FPosition := TUdInsert(AValue).FPosition;

  FEntities.Assign(TUdInsert(AValue).FEntities);

//  Self.ClearAttribs();
//  for I := 0 to TUdInsert(AValue).FAttrList.Count - 1 do
//  begin
//    LAttr := TUdAttrib.Create();
//    LAttr.CopyFrom( TUdInsert(AValue).FAttrList[I] );
//    FAttrList.Add(LAttr);
//  end;

  Self.Update();
end;


procedure TUdInsert.StatesChanged(AIndex: Integer);
var
  I: Integer;
  LBool: Boolean;
begin
  inherited;

  case AIndex of
    STATE_INDEX_FINISHED :  Self.Update();
    STATE_INDEX_SELECTED :
      begin
        LBool := (FStates and Byte(fsSelected)) > 0;
        for I := 0 to FEntities.Count - 1 do FEntities.Items[I].Selected := LBool;
      end;
    STATE_INDEX_HIDDEN   :  ;// FStates := (FStates and Byte(fsHidden))   > 0;
    STATE_INDEX_UNDERGRIP:  ;// FStates := (FStates and Byte(fsUnderGrip))> 0;
  end
end;




procedure TUdInsert.CalcEntities();

  procedure _UpdateTextByAttr(AEntity: TUdText; AttrObj: TUdAttrib);
  begin
    AEntity.BeginUpdate();
    try
      AEntity.Position := Point2D(FPosition.X + AttrObj.FOffset.X, FPosition.Y + AttrObj.FOffset.Y);

      AEntity.Height      := AttrObj.FHeight;
      AEntity.WidthFactor := AttrObj.FWidthFactor;
      AEntity.Rotation    := FRotation + AttrObj.FRotaion;
      AEntity.Alignment   := AttrObj.FAlignment;

      AEntity.Backward    := AttrObj.FBackwards;
      AEntity.Upsidedown  := AttrObj.FUpsideDown;

      AEntity.Contents    := AttrObj.FValue;
    finally
      AEntity.EndUpdate();
    end;
  end;

var
  I: Integer;
//  LAttrObj: TUdAttrib;
  LEntities: TUdEntityArray;
begin
  if not Assigned(FBlock) then Exit;

  FEntities.Clear();

  LEntities := FBlock.CreateInsertEntities(FPosition, FScaleX, FScaleY, FRotation);
  for I := 0 to System.Length(LEntities) - 1 do
  begin
    LEntities[I].Owner := Self;
    LEntities[I].SetDocument(Self.Document, False);
    LEntities[I].Selected := Self.Selected;

//    if LEntities[I].InheritsFrom(TUdText) and (TUdText(LEntities[I]).Tag <> '') then
//    begin
//      LAttrObj := FindAttrObj(FAttrList, TUdText(LEntities[I]).Tag);
//
//      if Assigned(LAttrObj) then
//        _UpdateTextByAttr( TUdText(LEntities[I]), LAttrObj );
//    end;

    FEntities.Add(LEntities[I]);
  end;
end;

function TUdInsert.FDoUpdate(AAxes: TUdAxes): Boolean;
var
  LOff: Float;
begin
  Result := False;

  if FEntities.Count > 0 then
  begin
    LOff := AAxes.XValuePerPixel * DEFAULT_PICK_SIZE;
    FBoundsRect := FEntities.BoundsRect; //UdUtils.GetEntitiesBound(FEntities.List);
    FBoundsRect.X1 := FBoundsRect.X1 - LOff;  FBoundsRect.X2 := FBoundsRect.X2 + LOff;
    FBoundsRect.Y1 := FBoundsRect.Y1 - LOff;  FBoundsRect.Y2 := FBoundsRect.Y2 + LOff;

    Result := True;
  end
  else
    FBoundsRect := Rect2D(0, 0, 0, 0);
end;

function TUdInsert.DoUpdate(AAxes: TUdAxes): Boolean;
begin
  Self.CalcEntities();
  Result := FDoUpdate(AAxes);
end;

function TUdInsert.DoDraw(ACanvas: TCanvas; AAxes: TUdAxes; AFlag: Cardinal = 0; ALwFactor: Float = 1.0): Boolean;
var
  I: Integer;
begin
  for I := 0 to FEntities.Count - 1 do
    FEntities.Items[I].Draw(ACanvas, AAxes, AFlag, ALwFactor);

  Result := True;
end;




//-----------------------------------------------------------------------------------------

function TUdInsert.GetChildEntities: TList;
begin
  Result := FEntities.List;
end;

function TUdInsert.GetGripPoints(): TUdGripPointArray;
begin
  System.SetLength(Result, 1);
  Result[0] := MakeGripPoint(Self, gmPoint, 0, FPosition, 0);
end;

function TUdInsert.GetOSnapPoints: TUdOSnapPointArray;
begin
  System.SetLength(Result, 1);
  Result[0] := MakeOSnapPoint(Self, OSNP_INS, FPosition, -1);
end;






//-----------------------------------------------------------------------------------------


function TUdInsert.MoveGrip(AGripPnt: TUdGripPoint): Boolean;
begin
  Result := False;

  if AGripPnt.Mode = gmPoint then
  begin
    if AGripPnt.Index = 0 then
    begin
      Result := Self.Move(FPosition, AGripPnt.Point);
    end;
  end;
end;


function TUdInsert.Pick(APoint: TPoint2D): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  for I := 0 to FEntities.Count - 1 do
  begin
    Result := FEntities.Items[I].Pick(APoint);
    if Result then Break;
  end;
end;

function TUdInsert.Pick(ARect: TRect2D; ACrossingMode: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not UdUtils.CanEntityPick(Self) then Exit; //======>>>>

  for I := 0 to FEntities.Count - 1 do
  begin
    Result := FEntities.Items[I].Pick(ARect, ACrossingMode);
    if Result then Break;
  end;
end;

function TUdInsert.Move(Dx, Dy: Float): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(Dx, 0.0) and UdMath.IsEqual(Dy, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  FPosition := UdGeo2D.Translate(Dx, Dy, FPosition);

  if not Assigned(FBlock) then
    for I := 0 to FEntities.Count - 1 do FEntities.Items[I].Move(Dx, Dy);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;


function TUdInsert.Mirror(APnt1, APnt2: TPoint2D): Boolean;
var
  I: Integer;
  LAng: Float;
  LRotSeg: TSegment2D;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(APnt1, APnt2)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  if not Assigned(FBlock) then
  begin
    for I := 0 to FEntities.Count - 1 do FEntities.Items[I].Mirror(APnt1, APnt2);
  end
  else begin
    LRotSeg := Segment2D(FPosition, ShiftPoint(FPosition, FRotation, 100));
    LRotSeg := UdGeo2D.Mirror(Line2D(APnt1, APnt2), LRotSeg);

    LAng := GetAngle(APnt1, APnt2);

    if ((LAng > 45) and (LAng < 135)) or ((LAng > 225) and (LAng < 315)) then
    begin
      FRotation := GetAngle(LRotSeg.P2, LRotSeg.P1);
      FScaleX := -FScaleX;
    end
    else begin
      FScaleY := -FScaleY;
      FRotation := GetAngle(LRotSeg.P1, LRotSeg.P2);
    end;
  end;

  FPosition := UdGeo2D.Mirror(Line2D(APnt1, APnt2), FPosition);
  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdInsert.Rotate(ABase: TPoint2D; ARota: Float): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(ARota, 0.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  if not Assigned(FBlock) then
    for I := 0 to FEntities.Count - 1 do FEntities.Items[I].Rotate(ABase, ARota);

  FPosition := UdGeo2D.Rotate(ABase, ARota, FPosition);
  FRotation := FixAngle(FRotation + ARota);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;

function TUdInsert.Scale(ABase: TPoint2D; AFactor: Float): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Self.IsLock() or
     (UdMath.IsEqual(AFactor, 0.0) or UdMath.IsEqual(AFactor, 1.0)) then Exit; //======>>>>

  Self.RaiseBeforeModifyObject('');

  if not Assigned(FBlock) then
    for I := 0 to FEntities.Count - 1 do FEntities.Items[I].Scale(ABase, AFactor);

  FScaleX := FScaleX * AFactor;
  FScaleY := FScaleY * AFactor;
  FPosition := UdGeo2D.Scale(ABase, AFactor, AFactor, FPosition);

  Result := Self.Update();

  Self.RaiseAfterModifyObject('');
end;




function TUdInsert.Explode(): TUdObjectArray;
var
  I: Integer;
begin
  Result := nil;
  if FEntities.Count <= 0 then Self.Update();
  if FEntities.Count <= 0 then Exit; //======>>>>

  System.SetLength(Result, FEntities.Count);
  for I := 0 to FEntities.Count - 1 do
    Result[I] := FEntities.Items[I].Clone();
end;

function TUdInsert.ScaleEx(ABase: TPoint2D; XFactor, YFactor: Float): TUdEntityArray;
var
  I, J: Integer;
  LInsert: TUdInsert;
  LEntityArray: TUdEntityArray;
begin
  Result := nil;
  if (UdMath.IsEqual(XFactor, 0.0) or UdMath.IsEqual(YFactor, 0.0)) then Exit; //======>>>>

  LInsert := TUdInsert.Create({Self.Document, False});

  LInsert.BeginUpdate();
  try
    LInsert.Assign(Self);

    if not (UdMath.IsEqual(XFactor, 1.0) and UdMath.IsEqual(YFactor, 1.0)) then
    begin
      LInsert.FScaleX := FScaleX * XFactor;
      LInsert.FScaleY := FScaleY * YFactor;
      LInsert.FPosition := UdGeo2D.Scale(ABase, XFactor, YFactor, FPosition);

      if Assigned(LInsert.FBlock) then
      begin
        //LInsert.CalcEntities(); will be calc in EndUpdate()
      end
      else begin
        LInsert.FEntities.Clear();
        for I := 0 to FEntities.Count - 1 do
        begin
          LEntityArray := FEntities.Items[I].ScaleEx(ABase, XFactor, YFactor);
          for J := 0 to System.Length(LEntityArray) - 1 do LInsert.FEntities.Add(LEntityArray[J]);
        end;
      end;
    end;
  finally
    LInsert.EndUpdate();
  end;

  System.SetLength(Result, 1);
  Result[0] := LInsert;
end;



function TUdInsert.Intersect(AOther: TUdEntity): TPoint2DArray;
var
  I: Integer;
begin
  Result := nil;
  if not Assigned(AOther) or (AOther = Self) then Exit; //====>>>>

  for I := 0 to FEntities.Count - 1 do
    FAddArray(Result, FEntities.Items[I].Intersect(AOther) );
end;

function TUdInsert.Perpend(APnt: TPoint2D): TPoint2DArray;
var
  I: Integer;
begin
  for I := 0 to FEntities.Count - 1 do
    FAddArray(Result, FEntities.Items[I].Perpend(APnt) );
end;





//-----------------------------------------------------------------------------------------

//procedure TUdInsert.AddAttrib(AName, AValue: string; AOffset: TPoint2D; AAlignment: TUdTextAlign; AHeight, AWidthFactor, ARotaion: Double;
//  ABackwards: Boolean = False; AUpsideDown: Boolean = False);
//var
//  LAttr: TUdAttrib;
//begin
//  LAttr := TUdAttrib.Create(AName, AValue, AOffset, AAlignment, AHeight, AWidthFactor, ARotaion, ABackwards, AUpsideDown);
//  FAttrList.Add(LAttr);
//end;


//procedure TUdInsert.ClearAttribs;
//var
//  I: Integer;
//begin
//  for I := FAttrList.Count - 1 downto 0 do
//  begin
//    TObject(FAttrList[I]).Free;
//  end;
//  FAttrList.Clear();
//end;




//-----------------------------------------------------------------------------------------

procedure TUdInsert.SaveToStream(AStream: TStream);
//var
//  I: Integer;
//  LAttr: TUdAttrib;
begin
  inherited;

  if Assigned(FBlock) then StrToStream(AStream, FBlock.Name) else StrToStream(AStream, '');

  FloatToStream(AStream, FScaleX  );
  FloatToStream(AStream, FScaleY  );
  FloatToStream(AStream, FRotation);
  Point2DToStream(AStream, FPosition);

  FEntities.SaveToStream(AStream);

//  IntToStream(AStream, FAttrList.Count);
//  for I := 0 to FAttrList.Count - 1 do
//  begin
//    LAttr := FAttrList[I];
//    StrToStream(AStream, LAttr.FName);
//    StrToStream(AStream, LAttr.FValue);
//    Point2DToStream(AStream, LAttr.FOffset);
//    IntToStream(AStream, Ord(LAttr.FAlignment));
//    FloatToStream(AStream, LAttr.FHeight);
//    FloatToStream(AStream, LAttr.FWidthFactor);
//    FloatToStream(AStream, LAttr.FRotaion);
//    BoolToStream(AStream, LAttr.FBackwards);
//    BoolToStream(AStream, LAttr.FUpsideDown);
//  end;
end;

procedure TUdInsert.LoadFromStream(AStream: TStream);
var
//  I: Integer;
//  LCount: Integer;
//  LAttr: TUdAttrib;
  LBlockName: string;
begin
  inherited;

  LBlockName := StrFromStream(AStream);
  if (LBlockName <> '') and Assigned(Self.Document) then
    FBlock := TUdDocument(Self.Document).Blocks.GetItem(LBlockName);

  FScaleX   := FloatFromStream(AStream);
  FScaleY   := FloatFromStream(AStream);
  FRotation := FloatFromStream(AStream);
  FPosition := Point2DFromStream(AStream);

  FEntities.LoadFromStream(AStream);

//  Self.ClearAttribs();
//  LCount := IntFromStream(AStream);
//  for I := 0 to LCount - 1 do
//  begin
//    LAttr := TUdAttrib.Create();
//
//    LAttr.FName        := StrFromStream(AStream    );
//    LAttr.FValue       := StrFromStream(AStream    );
//    LAttr.FOffset      := Point2DFromStream(AStream);
//    LAttr.FAlignment   := TUdTextAlign( IntFromStream(AStream) );
//    LAttr.FHeight      := FloatFromStream(AStream  );
//    LAttr.FWidthFactor := FloatFromStream(AStream  );
//    LAttr.FRotaion     := FloatFromStream(AStream  );
//    LAttr.FBackwards   := BoolFromStream(AStream   );
//    LAttr.FUpsideDown  := BoolFromStream(AStream   );
//  end;

  Self.FDoUpdate(Self.EnsureAxes(nil));
end;




procedure TUdInsert.SaveToXml(AXmlNode: TObject; ANodeName: string = '');
var
//  I: Integer;
//  LAttr: TUdAttrib;
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  LXmlNode.Prop['ScaleX']   := FloatToStr(FScaleX);
  LXmlNode.Prop['ScaleY']   := FloatToStr(FScaleY);

  LXmlNode.Prop['Rotation'] := FloatToStr(FRotation);
  LXmlNode.Prop['Position'] := Point2DToStr(FPosition);

  FEntities.SaveToXml(LXmlNode.Add());


//  IntToStream(AStream, FAttrList.Count);
//  for I := 0 to FAttrList.Count - 1 do
//  begin
//    LAttr := FAttrList[I];
//    StrToStream(AStream, LAttr.FName);
//    StrToStream(AStream, LAttr.FValue);
//    Point2DToStream(AStream, LAttr.FOffset);
//    FloatToStream(AStream, LAttr.FHeight);
//    FloatToStream(AStream, LAttr.FWidthFactor);
//    FloatToStream(AStream, LAttr.FRotaion);
//    BoolToStream(AStream, LAttr.FBackwards);
//    BoolToStream(AStream, LAttr.FUpsideDown);
//  end;
//
//  LXmlNode.Prop['AttrMap'] := FAttrMap.Text;
end;

procedure TUdInsert.LoadFromXml(AXmlNode: TObject);
var
  LXmlNode: TUdXmlNode;
begin
  inherited;
  if not Assigned(AXmlNode) then Exit; //======>>>>

  LXmlNode := TUdXmlNode(AXmlNode);

  FScaleX    := StrToFloatDef(LXmlNode.Prop['FRotation'], 0.0);
  FScaleY    := StrToFloatDef(LXmlNode.Prop['FRotation'], 0.0);

  FRotation  := StrToFloatDef(LXmlNode.Prop['FRotation'], 0.0);
  FPosition  := StrToPoint2D(LXmlNode.Prop['Position']);

  FEntities.LoadFromXml(LXmlNode.FindItem('Entities'));

//  FAttrMap.Clear();
//  FAttrMap.Text := LXmlNode.Prop['AttrMap'];

  Self.FDoUpdate(Self.EnsureAxes(nil));
end;


end.