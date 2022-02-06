{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLoopSearch;

{$I UdGeoDefs.INC}

interface

//{$DEFINE DEBUG}
//{$DEFINE WRITE_LOG}

uses
  Windows, Classes, Types,
  UdTypes, UdGTypes;


type
  TIntegersDynArray = array of TIntegerDynArray;

  //*** TUdLoopSearch ***//
  TUdLoopSearch = class(TObject)
  private
    FSourceList: TList;

    FSegarcList: TList;
    FPointList : TList;

    FMinPolygons: TPolygon2DArray;
    FMaxPolygons: TPolygon2DArray;

    FMinLoops: TSegarcs2DArray;
    FMaxLoops: TSegarcs2DArray;

    FMinLoopDatas: TIntegersDynArray;
    FMaxLoopDatas: TIntegersDynArray;

  protected
    procedure ClearSources();
    procedure ClearLoops();
    procedure ClearAll();

    procedure RaiseProgress(Pos: Integer; Msg: string = '');
    procedure AddSource(var ASegarc: TSegarc2D; AData: Pointer);

    function CalcSegarcs(): Boolean;

    function CalcPoints(): Boolean;
    function CheckPoints(): Boolean;

    function SortPointList(var AList: TList): Boolean;
    function SortSegemtsPoint(): Boolean;

    function CalcPointsVector(): Boolean;

    function PartPointList(var ALists: TList): Boolean;
    function CalcAllLoops(): Boolean;

  public
    constructor Create(AContinuous: Boolean = False; AIntactData: Boolean = False);
    destructor Destroy(); override;

    procedure Add(ASegment: TSegment2D; AData: Pointer = nil); overload;
    procedure Add(AArc: TArc2D; AData: Pointer = nil); overload;
    procedure Add(ACir: TCircle2D; AData: Pointer = nil); overload;
    procedure Add(APoints: TPoint2DArray; AData: Pointer = nil); overload;
    procedure Add(ASegarc: TSegarc2D; AData: Pointer = nil); overload;
    procedure Add(ASegarcs: TSegarc2DArray; AData: Pointer = nil); overload;

    procedure Clear();
    function Search(): Boolean;

  public
    property MinPolygons: TPolygon2DArray read FMinPolygons;
    property MaxPolygons: TPolygon2DArray read FMaxPolygons;

    property MinLoops: TSegarcs2DArray read FMinLoops;
    property MaxLoops: TSegarcs2DArray read FMaxLoops;

    property MinLoopDatas: TIntegersDynArray read FMinLoopDatas;
    property MaxLoopDatas: TIntegersDynArray read FMaxLoopDatas;
  end;



implementation

uses
  SysUtils,
  UdMath, UdGeo2D;


const
  INCT_EPSION   = UdGTypes._Epsilon;
  ANGLE_EPSION  = UdGTypes._Epsilon;

type
  PScSegarc2D = ^TScSegarc2D;
  TScSegarc2D = record
    Segarc: TSegarc2D;
    Data: Pointer;
  end;




//==================================================================================================

type
  TPointerArray = array of Pointer;
  TListSortProc = procedure (ASortList: {$IF COMPILERVERSION >= 23 }TPointerList{$ELSE}PPointerList{$IFEND}; AListCount: Integer; AArgs: TPointerArray = nil);
  TListCompFunc = function(Item1, Item2: Pointer; AArgs: TPointerArray = nil): Double;

procedure FQuickSort(ASortList: {$IF COMPILERVERSION >= 23 }TPointerList{$ELSE}PPointerList{$IFEND}; L, R: Integer; ACompare: TListCompFunc; AArgs: TPointerArray = nil);
var
  I, J: Integer;
  P, T: Pointer;
begin
  repeat
    I := L;
    J := R;
    P := ASortList[(L + R) shr 1];
    repeat
      while ACompare(ASortList[I], P, AArgs) < 0 do
        Inc(I);
      while ACompare(ASortList[J], P, AArgs) > 0 do
        Dec(J);
      if I <= J then
      begin
        T := ASortList[I];
        ASortList[I] := ASortList[J];
        ASortList[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then FQuickSort(ASortList, L, J, ACompare, AArgs);
    L := I;
  until I >= R;
end;

procedure SortList(AList: TList; ACompareFunc: TListCompFunc; AArgs: TPointerArray = nil); overload;
begin
  if Assigned(AList) and Assigned(AList.List) and (AList.Count > 0) and Assigned(ACompareFunc) then
    FQuickSort(AList.List, 0, AList.Count - 1, ACompareFunc, AArgs);
end;

procedure SortList(AList: TList; ASortProc: TListSortProc; AArgs: TPointerArray = nil);  overload;
begin
  if Assigned(AList) and Assigned(AList.List) and (AList.Count > 0) and Assigned(ASortProc) then
    ASortProc(AList.List, AList.Count, AArgs);
end;




function ClearObjectList(AList: TList): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not Assigned(AList) then Exit;

  for I := AList.Count - 1 downto 0 do
    TObject(AList.Items[I]).Free;
  AList.Clear();

  Result := True;
end;



//==================================================================================================
type

  TScPoint = class(TObject)
  private
    FPoint: TPoint2D;
    FRaded: Boolean;
    FSegarcList: TList;
    FVectorList: TList;

  public
    constructor Create();
    destructor Destroy(); override;

  public
    property Point: TPoint2D read FPoint write FPoint;
    property Raded: Boolean  read FRaded write FRaded;

    property SegarcList: TList read FSegarcList write FSegarcList;
    property VectorList: TList read FVectorList write FVectorList;
  end;


  TScSegarc = class(TObject)
  private
    FData: Pointer;
    FSegarc: TSegarc2D;
    FPointList: TList;

  protected
    function GetIsArc: Boolean;

    function GetSeg: TSegment2D;
    procedure SetSeg(const Value: TSegment2D);

    function GetArc: TArc2D;
    procedure SetArc(const Value: TArc2D);

  public
    constructor Create(ASegarc: TSegarc2D; AData: Pointer = nil);
    destructor Destroy(); override;

  public
    property IsArc: Boolean  read GetIsArc;
    property Arc: TArc2D read GetArc write SetArc;
    property Seg: TSegment2D read GetSeg write SetSeg;

    property Data: Pointer read FData write FData;
    property PointList: TList read FPointList write FPointList;
  end;


  TScVector = class(TObject)
  private
    FThis : TScPoint;
    FNext : TScPoint;
    FAngle: Float;
    FSegment: TScSegarc;

    FFlag: Boolean;
  public
    constructor Create();
    destructor Destroy(); override;

    property This : TScPoint read FThis  write FThis;
    property Next : TScPoint read FNext  write FNext;
    property Angle: Float    read FAngle write FAngle;
    property Segment: TScSegarc read FSegment write FSegment;

    //property Flag : Boolean read FFlag  write FFlag;
  end;




//--------------------------------------------------------------------------------------------
{TScPoint's implementation}

constructor TScPoint.Create();
begin
  FPoint.X := 0;
  FPoint.Y := 0;
  FRaded := False;
  FSegarcList := TList.Create();
  FVectorList := TList.Create();
end;

destructor TScPoint.Destroy();
var
  I: Integer;
begin
  FSegarcList.Free;
  FSegarcList := nil;

  for I := FVectorList.Count - 1 downto 0 do
    TScVector(FVectorList.Items[I]).Free;

  FVectorList.Free;
  FVectorList := nil;

  inherited;
end;



//--------------------------------------------------------------------------------------------
{TScSegarc's implementation}

constructor TScSegarc.Create(ASegarc: TSegarc2D; AData: Pointer = nil);
begin
  FData := AData;
  FSegarc := ASegarc;
  FPointList := TList.Create();
end;

destructor TScSegarc.Destroy();
begin
  if Assigned(FPointList) then
  begin
    FPointList.Free;
    FPointList :=nil;
  end;
  inherited;
end;


function TScSegarc.GetIsArc: Boolean;
begin
  Result := FSegarc.IsArc;
end;


function TScSegarc.GetSeg: TSegment2D;
begin
  Result := FSegarc.Seg;
end;

procedure TScSegarc.SetSeg(const Value: TSegment2D);
begin
  FSegarc.Seg := Value;
end;


function TScSegarc.GetArc: TArc2D;
begin
  Result := FSegarc.Arc;
end;

procedure TScSegarc.SetArc(const Value: TArc2D);
begin
  FSegarc.Arc := Value;
end;






//--------------------------------------------------------------------------------------------
{TScVector's implementation}

constructor TScVector.Create();
begin
  FThis := nil;
  FNext := nil;
  FSegment := nil;

  FAngle := -1.0;
  FFlag := False;
end;

destructor TScVector.Destroy;
begin

  inherited;
end;





//=================================================================================================

function FComparePointsVector(Item1, Item2: Pointer; AArgs: TPointerArray = nil): Double;
var
  LPnt: TPoint2D;
  LIsLeft1, LIsLeft2: Boolean;
  LVector1, LVector2: TScVector;
begin
  Result := 0.0;
  if Item1 = Item2 then Exit; //======>>>>


  LVector1 := TScVector(Item1);
  LVector2 := TScVector(Item2);

  if IsEqual(LVector1.Angle, LVector2.Angle) then
  begin
    if LVector1.Segment.IsArc and LVector2.Segment.IsArc then
    begin
      LPnt := ShiftPoint(LVector1.This.Point, LVector1.Angle, 10);

      LIsLeft1 := IsPntOnLeftSide(LVector1.Segment.Arc.Cen, LVector1.This.Point, LPnt);
      LIsLeft2 := IsPntOnLeftSide(LVector2.Segment.Arc.Cen, LVector1.This.Point, LPnt);

      if LIsLeft1 = LIsLeft2 then
      begin
        if LVector1.Segment.Arc.R > LVector2.Segment.Arc.R then
        begin
          if LIsLeft1 then
            Result := -_Epsilon
          else
            Result := +_Epsilon;
        end
        else begin
          if LIsLeft1 then
            Result := +_Epsilon
          else
            Result := -_Epsilon;
        end;
      end
      else begin
        if LIsLeft1 then Result := +_Epsilon else Result := -_Epsilon;
      end;
    end else

    if LVector1.Segment.IsArc or LVector2.Segment.IsArc then
    begin
      if LVector1.Segment.IsArc then
      begin
        if IsPntOnLeftSide(LVector1.Segment.Arc.Cen, LVector2.This.Point, LVector2.Next.Point) then
          Result := +_Epsilon
        else
          Result := -_Epsilon;
      end
      else begin
        if IsPntOnLeftSide(LVector2.Segment.Arc.Cen, LVector1.This.Point, LVector1.Next.Point) then
          Result := -_Epsilon
        else
          Result := +_Epsilon;
      end;
    end

    else begin
      if Distance(LVector1.Segment.Seg) > Distance(LVector2.Segment.Seg) then
        Result := +_Epsilon
      else
        Result := -_Epsilon;
    end;
  end
  else
    Result := (LVector1.Angle - LVector2.Angle);
end;




//=================================================================================================
{ TUdLoopSearch }


constructor TUdLoopSearch.Create(AContinuous: Boolean = False; AIntactData: Boolean = False);
begin
  FSourceList := TList.Create();
  FPointList := TList.Create();
  FSegarcList := TList.Create();

  FMaxLoops := nil;
  FMinLoops := nil;

  FMinLoopDatas := nil;
  FMaxLoopDatas := nil;

  FMinPolygons := nil;
  FMaxPolygons := nil;
end;

destructor TUdLoopSearch.Destroy;
begin
  ClearAll();

  if Assigned(FSourceList) then FSourceList.Free;
  if Assigned(FPointList)  then FPointList.Free;
  if Assigned(FSegarcList) then FSegarcList.Free;

  inherited;
end;


procedure TUdLoopSearch.RaiseProgress(Pos: Integer; Msg: string = '');
begin
//  if Assigned(FOnProgress) then FOnProgress(Self, Pos, 100, Msg);
end;




//----------------------------------------------------------------------

procedure TUdLoopSearch.ClearSources();
var
  I: Integer;
begin
  for I := FSourceList.Count - 1 downto 0 do Dispose(PScSegarc2D(FSourceList[I]));
  FSourceList.Clear();
end;

procedure TUdLoopSearch.ClearLoops();
begin
  FMaxLoops := nil;
  FMinLoops := nil;
  FMinPolygons := nil;
  FMaxPolygons := nil;
  FMinLoopDatas := nil;
  FMaxLoopDatas := nil;
end;

procedure TUdLoopSearch.ClearAll();
begin
  ClearObjectList(FSegarcList);
  ClearObjectList(FPointList);

  ClearSources();
  ClearLoops();
end;





//----------------------------------------------------------------------

procedure TUdLoopSearch.AddSource(var ASegarc: TSegarc2D; AData: Pointer);
var
  LArc: TArc2D;
  LArcKind: TArcKind;
  LSegarc: PScSegarc2D;
begin
  LSegarc := New(PScSegarc2D);
  LSegarc^.Data := AData;
  LSegarc^.Segarc := ASegarc;

  LArcKind := LSegarc^.Segarc.Arc.Kind;
  LSegarc^.Segarc.Arc.Kind := akCurve;

  FSourceList.Add(LSegarc);

  if LSegarc^.Segarc.IsArc and (LArcKind <> akCurve) then
  begin
    LArc := LSegarc^.Segarc.Arc;

    if LArcKind = akChord then
    begin
      LSegarc := New(PScSegarc2D);
      LSegarc^.Data := AData;
      LSegarc^.Segarc := Segarc2D(ShiftPoint(LArc.Cen, LArc.Ang1, LArc.R), ShiftPoint(LArc.Cen, LArc.Ang2, LArc.R));
      FSourceList.Add(LSegarc);
    end
    else begin
      LSegarc := New(PScSegarc2D);
      LSegarc^.Data := AData;
      LSegarc^.Segarc := Segarc2D(LArc.Cen, ShiftPoint(LArc.Cen, LArc.Ang1, LArc.R));
      FSourceList.Add(LSegarc);

      LSegarc := New(PScSegarc2D);
      LSegarc^.Data := AData;
      LSegarc^.Segarc := Segarc2D(LArc.Cen, ShiftPoint(LArc.Cen, LArc.Ang2, LArc.R));
      FSourceList.Add(LSegarc);
    end;
  end;
end;

procedure TUdLoopSearch.Add(ASegment: TSegment2D; AData: Pointer = nil);
var
  LSegarc: TSegarc2D;
//  LSeg1, LSeg2: TSegment2D;
//  LSegarc1, LSegarc2: TSegarc2D;
begin
//  if Width > 0 then
//  begin
//    UdGeo2D.OffsetSegment(ASegment, Width, LSeg1, LSeg2);
//
//    LSegarc1 := UdGeo2D.Segarc2D(LSeg1);
//    AddSource(LSegarc1, AData);
//
//    LSegarc2 := UdGeo2D.Segarc2D(LSeg2);
//    AddSource(LSegarc2, AData);
//
//    LSegarc := UdGeo2D.Segarc2D(Segment2D(LSegarc1.Seg.P1, LSegarc2.Seg.P1));
//    AddSource(LSegarc, AData);
//
//    LSegarc := UdGeo2D.Segarc2D(Segment2D(LSegarc1.Seg.P2, LSegarc2.Seg.P2));
//    AddSource(LSegarc, AData);
//  end
//  else begin
    LSegarc := UdGeo2D.Segarc2D(ASegment);
    AddSource(LSegarc, AData);
//  end;
end;


procedure TUdLoopSearch.Add(AArc: TArc2D; AData: Pointer = nil);
var
  LSegarc: TSegarc2D;
//  LArc1, LArc2: TArc2D;
//  LSegarc1, LSegarc2: TSegarc2D;
begin
//  if Width > 0 then
//  begin
//    UdGeo2D.OffsetArc(AArc, Width, LArc1, LArc2);
//
//    LSegarc1 := UdGeo2D.Segarc2D(LArc1);
//    AddSource(LSegarc1, AData);
//
//    LSegarc2 := UdGeo2D.Segarc2D(LArc2);
//    AddSource(LSegarc2, AData);
//
//    LSegarc := UdGeo2D.Segarc2D(Segment2D(LSegarc1.Seg.P1, LSegarc2.Seg.P1));
//    AddSource(LSegarc, AData);
//
//    LSegarc := UdGeo2D.Segarc2D(Segment2D(LSegarc1.Seg.P2, LSegarc2.Seg.P2));
//    AddSource(LSegarc, AData);
//  end
//  else begin
  if IsEqual(AArc.Ang1, 0.0) and IsEqual(AArc.Ang2, 360.0) then
  begin
    LSegarc := UdGeo2D.Segarc2D(Arc2D(AArc.Cen, AArc.R, 0.0, 180.0, AArc.IsCW, akCurve));
    AddSource(LSegarc, AData);

    LSegarc := UdGeo2D.Segarc2D(Arc2D(AArc.Cen, AArc.R, 180.0, 360.0, AArc.IsCW, akCurve));
    AddSource(LSegarc, AData);
  end
  else begin
    LSegarc := UdGeo2D.Segarc2D(AArc);
    AddSource(LSegarc, AData);
  end;
end;

procedure TUdLoopSearch.Add(ACir: TCircle2D; AData: Pointer = nil);
begin
  Self.Add(Arc2D(ACir.Cen, ACir.R, 0.0, 360.0), AData);
end;

procedure TUdLoopSearch.Add(APoints: TPoint2DArray; AData: Pointer = nil);
var
  I: Integer;
  LSegarc: TSegarc2D;
  LP1, LP2: TPoint2D;
begin
  for I := 0 to System.Length(APoints) - 2 do
  begin
    LP1 := APoints[I];
    LP2 := APoints[I + 1];
    if NotEqual(LP1, LP2) then
    begin
      LSegarc := UdGeo2D.Segarc2D(Segment2D(LP1, LP2));
      AddSource(LSegarc, AData);
    end;
  end;
end;

procedure TUdLoopSearch.Add(ASegarc: TSegarc2D; AData: Pointer = nil);
begin
  if ASegarc.IsArc then
    Self.Add(ASegarc.Arc, AData)
  else
    Self.Add(ASegarc.Seg, AData);
end;

procedure TUdLoopSearch.Add(ASegarcs: TSegarc2DArray; AData: Pointer = nil);
var
  I: Integer;
begin
  for I := 0 to System.Length(ASegarcs) - 1 do
    Self.Add(ASegarcs[I], AData);
end;




//----------------------------------------------------------------------

function TUdLoopSearch.CalcSegarcs(): Boolean;
var
  I: Integer;
  LAng: Float;
  LData: Pointer;
  LSegarc: TSegarc2D;
  LScSegarc: TScSegarc;
begin
  Result := False;
  if not Assigned(FSourceList) or (FSourceList.Count <= 0) then Exit;


  for I := 0 to FSourceList.Count - 1 do
  begin
    LData   := PScSegarc2D(FSourceList[I])^.Data;
    LSegarc := PScSegarc2D(FSourceList[I])^.Segarc;

    if not LSegarc.IsArc then
    begin
      LAng := UdGeo2D.GetAngle(LSegarc.Seg.P1, LSegarc.Seg.P2, ANGLE_EPSION);
      if IsEqual(LAng, 180.0) or (LAng > 180.0) then
        Swap(LSegarc.Seg.P1, LSegarc.Seg.P2);
    end;

    if not IsDegenerate(LSegarc) then
    begin
      LScSegarc := TScSegarc.Create(LSegarc, LData);
      FSegarcList.Add(LScSegarc);
    end;

    Self.RaiseProgress(Round(((I + 1) / FSourceList.Count) * 100));
  end;

  Result := True;
end;


//----------------------------------------------------------------------

function TUdLoopSearch.CalcPoints(): Boolean;

  function _AddPoint(APoint: TScPoint): Boolean;
  var
    I: Integer;
    J, K: Integer;
    LList: TList;
    LPoint: TScPoint;
  begin
    Result := False;
    if not Assigned(APoint) then Exit;

    for I := 0 to FPointList.Count - 1 do
    begin
      LPoint := TScPoint(FPointList.Items[I]);

      //注意: 当判断相交的点 是否是相同的点的时候 控制精度应该比计算相交的时候低一个级别
      if (Abs(LPoint.FPoint.X - APoint.FPoint.X) < INCT_EPSION * 10) and
         (Abs(LPoint.FPoint.Y - APoint.FPoint.Y) < INCT_EPSION * 10) then
      begin
        LList := TList.Create;

        try
          for J := APoint.FSegarcList.Count - 1 downto 0 do LList.Add(APoint.FSegarcList.Items[J]);
          for J := LPoint.FSegarcList.Count - 1 downto 0 do LList.Add(LPoint.FSegarcList.Items[J]);

          for J := 0 to LList.Count - 2 do
            for K := J + 1 to LList.Count - 1 do
              if LList[J] = LList[K] then LList[K] := nil;
          LList.Pack;

          for J := 0 to LList.Count - 1 do TScSegarc(LList[J]).FPointList.Remove(APoint);
          for J := 0 to LList.Count - 1 do
            if TScSegarc(LList[J]).FPointList.IndexOf(LPoint) < 0 then
            begin
              TScSegarc(LList[J]).FPointList.Add(LPoint);
//              if LPoint.FSegarcList.IndexOf(LList[J]) < 0 then
                LPoint.FSegarcList.Add(LList[J]);
            end;
        finally
          LList.Free;
        end;

        APoint.Free;
        Result := True;
        Break;
      end;
    end;

    if not Result then FPointList.Add(APoint);

    Result := True;
  end;

  function _CreatePoint(ASegmet1, ASegmet2: TScSegarc): Boolean;
  var
    I: Integer;
    LPoint: TScPoint;
    LInctPnts: TPoint2DArray;
  begin
    Result := False;

    if ASegmet1.FSegarc.IsArc and ASegmet2.FSegarc.IsArc then
      if Result then ;

    LInctPnts := Intersection(ASegmet1.FSegarc, ASegmet2.FSegarc, INCT_EPSION);

    if System.Length(LInctPnts) <= 0 then Exit;

    for I := 0 to System.Length(LInctPnts) - 1 do
    begin
      LPoint := TScPoint.Create;

      with LPoint do
      begin
        FPoint := LInctPnts[I];
        FSegarcList.Add(ASegmet1);
        FSegarcList.Add(ASegmet2);
      end;

      ASegmet1.FPointList.Add(LPoint);
      ASegmet2.FPointList.Add(LPoint);

      _AddPoint(LPoint);
    end;

    Result := True;
  end;



var
  I, J: Integer;
  ISegment, JSegment: TScSegarc;
begin
  Result := False;
  if not Assigned(FSegarcList) or (FSegarcList.Count = 0) then Exit;

  for I := 0 to FSegarcList.Count - 2 do
  begin
    ISegment := TScSegarc(FSegarcList.Items[I]);
    for J := I + 1 to FSegarcList.Count - 1 do
    begin
      JSegment := TScSegarc(FSegarcList.Items[J]);
      _CreatePoint(ISegment, JSegment);
    end;
    Self.RaiseProgress(Round(((I + 1) / FSegarcList.Count) * 100));
  end;
  Result := True;
end;

function TUdLoopSearch.CheckPoints(): Boolean;
var
  I: Integer;
  M, N: Integer;
  LPoint: TScPoint;
  LSegarc: TScSegarc;
  LPntCount, LSegCount: Integer;
begin
  Result := False;
  if not Assigned(FSegarcList) or (FSegarcList.Count = 0)  or
     not Assigned(FPointList) {or (FPointList.Count = 0)}  then Exit;

  M := 0;
  for I := FSegarcList.Count - 1 downto 0 do
  begin
    LSegarc := TScSegarc(FSegarcList.Items[I]);
    if LSegarc = nil then Continue;

    LPntCount := LSegarc.FPointList.Count;
    N := I;

    while LPntCount <= 1 do
    begin
      FSegarcList.Items[N] := nil;

      if LPntCount = 1 then
      begin
        LPoint := TScPoint(LSegarc.FPointList.Items[0]);
        LPoint.FSegarcList.Remove(LSegarc);
        LSegarc.Free;

        LSegCount := LPoint.FSegarcList.Count;
        if LSegCount <= 1 then
        begin
          if LSegCount = 1 then
          begin
            LSegarc := TScSegarc(LPoint.FSegarcList.Items[0]);
            LSegarc.FPointList.Remove(LPoint);

            N := FSegarcList.IndexOf(LSegarc);
            LPntCount := LSegarc.FPointList.Count;
          end
          else LPntCount := MAXLONG;

          FPointList.Remove(LPoint);
          FreeAndNil(LPoint);
        end
        else LPntCount := MAXLONG;
      end
      else begin
        LSegarc.Free;
        LPntCount := MAXLONG;
      end;
    end;

    M := M + 1;
    RaiseProgress(Round((M / FSegarcList.Count) * 100));
  end;

  FPointList.Pack;
  FSegarcList.Pack;

  Result := True;
end;





//----------------------------------------------------------------------

type
  _TCompPointFunc = function(Item1, Item2: TScPoint): Double;

function FPointsCompareY(AItem1, AItem2: TScPoint): Double;
begin
  if IsEqual(AItem2.FPoint.Y, AItem1.FPoint.Y) then
    Result := 0
  else
    Result := AItem2.FPoint.Y - AItem1.FPoint.Y;
end;

function FPointsCompareX(AItem1, AItem2: TScPoint): Double;
begin
  if IsEqual(AItem2.FPoint.X, AItem1.FPoint.X) then
    Result := 0
  else
    Result := AItem2.FPoint.X - AItem1.FPoint.X;
end;


procedure FSortPoints(ASortList: {$IF COMPILERVERSION >= 23 }TPointerList{$ELSE}PPointerList{$IFEND}; AListCount: Integer; AArgs: TPointerArray = nil);

  procedure _QuickSortPoints(A: {$IF COMPILERVERSION >= 23 }TPointerList{$ELSE}PPointerList{$IFEND}; L, R: Integer; ACompareFunc: _TCompPointFunc);
  var
    I, J: Integer;
    P, T: Pointer;
  begin
    repeat
      I := L;
      J := R;
      P := A[(L + R) shr 1];
      repeat
        while ACompareFunc(A[I], P) < 0 do Inc(I);
        while ACompareFunc(A[J], P) > 0 do Dec(J);

        if I <= J then
        begin
          T := A[I];
          A[I] := A[J];
          A[J] := T;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then _QuickSortPoints(ASortList, L, J, ACompareFunc);
      L := I;
    until I >= R;
  end;

var
  I: Integer;
  N, M: Integer;
  L, R: Integer;
begin
  L := 0;
  R := AListCount - 1;

  //先按Y坐标从大到小排序
  _QuickSortPoints(ASortList, L, R, FPointsCompareY);

  //Y相同的部分 再按按X坐标从大到小排序
  N := 0;
  M := 0;
  for I := 1 to AListCount - 1 do
  begin
    if IsEqual(TScPoint(ASortList[I]).FPoint.Y, TScPoint(ASortList[N]).FPoint.Y) then
    begin
      M := I;
    end
    else begin
      if I - N > 1 then
        _QuickSortPoints(ASortList, N, I - 1, FPointsCompareX);
      N := I;
    end;
  end;
  if M > N then
    _QuickSortPoints(ASortList, N, M, FPointsCompareX);
end;

function TUdLoopSearch.SortPointList(var AList: TList): Boolean;
begin
  Result := False;
  if not Assigned(AList) or (AList.Count = 0)  then Exit;

  SortList(AList, FSortPoints);
  Result := True;
end;






function FPointsCompareAngle(AItem1, AItem2: Pointer; AArgs: TPointerArray = nil): Double;
var
  LSegarc: TScSegarc;
  LDA1, LDA2: Float;
  LAng1, LAng2: Float;
begin
  LSegarc := TScSegarc(AArgs[0]);

  LAng1 := UdGeo2D.GetAngle(LSegarc.Arc.Cen, TScPoint(AItem1).FPoint, ANGLE_EPSION);
  LAng2 := UdGeo2D.GetAngle(LSegarc.Arc.Cen, TScPoint(AItem2).FPoint, ANGLE_EPSION);

  LDA1 := UdMath.FixAngle(LAng1 - LSegarc.Arc.Ang1 );
  LDA2 := UdMath.FixAngle(LAng2 - LSegarc.Arc.Ang1 );

  Result := LDA1 - LDA2;
end;

function TUdLoopSearch.SortSegemtsPoint(): Boolean;
var
  I: Integer;
  LSegarc: TScSegarc;
  LArgs: TPointerArray;
begin
  Result := False;
  if not Assigned(FSegarcList) or (FSegarcList.Count = 0) then Exit;

  System.SetLength(LArgs, 1);
  for I := 0 to FSegarcList.Count - 1 do
  begin
    LSegarc := TScSegarc(FSegarcList.Items[I]);
    LArgs[0] := LSegarc;

    if LSegarc.IsArc then
      SortList(LSegarc.FPointList, FPointsCompareAngle, LArgs)
    else
      SortList(LSegarc.FPointList, FSortPoints, LArgs);
  end;

  Result := True;
end;



//----------------------------------------------------------------------

  function FIsVectorExist(var ThisPoint, NextPoint: TScPoint; Angle: Float): Boolean;
  var
    I: Integer;
    AVector: TScVector;
  begin
    Result := False;
    for I := 0 to ThisPoint.VectorList.Count - 1 do
    begin
      AVector := TScVector(ThisPoint.VectorList.Items[I]);
      if not Assigned(AVector) then Continue;

      if (AVector.Next = NextPoint) and IsEqual(AVector.Angle, Angle, ANGLE_EPSION) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;


  function FCreateVector(Pnt1, Pnt2: TScPoint; Agl: Float; Seg: TScSegarc): TScVector;
  begin
    Result := TScVector.Create;
    with Result do
    begin
      This  := Pnt1;
      Next  := Pnt2;
      Angle := Agl;
      Segment := Seg;
    end;
  end;

  function FGetArcGetAngle(AArc: TArc2D; APnt1, APnt2: TPoint2D): Float;
  var
    LAng1, LAng2: Float;
  begin
    LAng1 := UdGeo2D.GetAngle(AArc.Cen, APnt1, ANGLE_EPSION);
    LAng2 := UdGeo2D.GetAngle(AArc.Cen, APnt2, ANGLE_EPSION);

    if FixAngle(LAng1 - AArc.Ang1) < FixAngle(LAng2 - AArc.Ang1) then
      Result := UdMath.FixAngle(LAng1 + 90)
    else
      Result := UdMath.FixAngle(LAng1 - 90);

    if IsEqual(Result, 360.0) then Result := 0;
  end;

function TUdLoopSearch.CalcPointsVector(): Boolean;

  function _GetGetAngle(ASegment: TScSegarc; APoint1, APoint2: TScPoint): Float;
  begin
    if ASegment.IsArc then
      Result := FGetArcGetAngle(ASegment.Arc, APoint1.FPoint, APoint2.FPoint)
    else
      Result := UdGeo2D.GetAngle(APoint1.FPoint, APoint2.FPoint, ANGLE_EPSION);
    if IsEqual(Result, 360.0) then Result := 0;
  end;

var
  I, J: Integer;
  N, M: Integer;
  NAngle: Float;
  NPoint: TScPoint;
  LPoint: TScPoint;
  LSegarc: TScSegarc;
  LVector: TScVector;
begin
  Result := False;
  if not Assigned(FPointList) or (FPointList.Count = 0)  then Exit;

  M := 0;

  for I := FPointList.Count - 1 downto 0 do
  begin
    LPoint := TScPoint(FPointList.Items[I]);

    for J := 0 to LPoint.FSegarcList.Count - 1 do
    begin
      LSegarc := TScSegarc(LPoint.FSegarcList.Items[J]);

      N := LSegarc.FPointList.IndexOf(LPoint);
      if N < 0 then Continue; //理论上说 N绝对没有小于0的可能

      //注意 此时的LSegarc当中的FPointList已经排序过了
      if N > 0 then  {这里就是>0 不是>=0}
      begin
        NPoint := TScPoint(LSegarc.FPointList.Items[N - 1]);
        NAngle := _GetGetAngle(LSegarc, LPoint, NPoint);

        if not FIsVectorExist(LPoint, NPoint, NAngle) and (NAngle >= 0) then
        begin
          LVector := FCreateVector(LPoint, NPoint, NAngle, LSegarc);
          LPoint.FVectorList.Add(LVector);
        end;

      end;

      if N < LSegarc.FPointList.Count - 1 then
      begin
        NPoint := TScPoint(LSegarc.FPointList.Items[N + 1]);
        NAngle := _GetGetAngle(LSegarc, LPoint, NPoint);

        if not FIsVectorExist(LPoint, NPoint, NAngle) and (NAngle >= 0) then
        begin
          LVector := FCreateVector(LPoint, NPoint, NAngle, LSegarc);
          LPoint.FVectorList.Add(LVector);
        end;

      end;

    end; {end for J}

    M := M + 1;
    RaiseProgress(Round((M / FPointList.Count) * 100));

    SortList(LPoint.FVectorList, FComparePointsVector);  //根据向量的角度 从小到大排序
  end;

  Result := True;
end;





//----------------------------------------------------------------------

function TUdLoopSearch.PartPointList(var ALists: TList): Boolean;
type
  TScPointerArray = array of Pointer;

  function _GetRadPoints(var ASeedArray: TScPointerArray): Integer;
  var
    I, J: Integer;
    LVector: TScVector;
    LRadArray: TScPointerArray;
    LThisPoint, LNextPoint: TScPoint;
  begin
    LRadArray := nil;

    for I := Low(ASeedArray) to High(ASeedArray) do
    begin
      LThisPoint := TScPoint(ASeedArray[I]);

      for J := 0 to LThisPoint.FVectorList.Count - 1 do
      begin
        LVector := TScVector(LThisPoint.FVectorList.Items[J]);
        if not Assigned(LVector) then Continue;

        LNextPoint := LVector.Next;
        if not LNextPoint.FRaded then
        begin
          LNextPoint.FRaded := True;

          System.SetLength(LRadArray, System.Length(LRadArray) + 1);
          LRadArray[High(LRadArray)] := LNextPoint;
        end;
      end; {end for J}
    end; {end for I}

    ASeedArray := LRadArray; //这次辐射的对象 作为下次辐射的种子
    Result := System.Length(LRadArray);
  end;

  //得到一个辐射种子
  function _GetRadSeed(out ASeed: TScPoint): Boolean;
  var
    I: Integer;
    LPoint: TScPoint;
  begin
    Result := False;
    if not Assigned(FPointList) then Exit;

    ASeed := nil;
    for I := 0 to FPointList.Count - 1 do
    begin
      LPoint := TScPoint(FPointList.Items[I]);

      if not LPoint.FRaded then
      begin
        ASeed := LPoint;
        Result := True;
        Break;
      end;
    end;
  end;

var
  I, N: Integer;
  LCount: Integer;
  LPoint: TScPoint;
  LList: TList;
  LSeedArray: TScPointerArray;
begin
  Result := False;
  if not Assigned(ALists) then Exit;

  LSeedArray := nil;

  if not _GetRadSeed(LPoint) then Exit;
  LPoint.FRaded := True;

  Result := True;

  N := 1;
  LCount := FPointList.Count;

  System.SetLength(LSeedArray, 1);
  LSeedArray[0] := LPoint;

  LList := TList.Create();
  LList.Add(LPoint);

  ALists.Add(LList);

  while N < LCount do
  begin
    N := N + _GetRadPoints(LSeedArray);
    for I := 0 to System.Length(LSeedArray) - 1 do LList.Add(LSeedArray[I]);

    if (System.Length(LSeedArray) = 0) and (N < LCount) then
    begin
      if _GetRadSeed(LPoint) then
      begin
        N := N + 1;

        LPoint.FRaded := True;
        System.SetLength(LSeedArray, 1);
        LSeedArray[0] := LPoint;

        LList := TList.Create();
        LList.Add(LPoint);

        ALists.Add(LList);
      end
      else begin
        Break;
        Result := False;
      end;
    end;

    Self.RaiseProgress(Round((N / LCount) * 100));
  end;
end;



function FCalcLoop(AStartVector: TScVector; var AReSegarcs: TSegarc2DArray; var AReDatas: TIntegerDynArray; Continuous: Boolean = False): Boolean;

  function _GetSegarc(var AVector: TScVector; var AReSegarc: TSegarc2D; var AReData: Integer): Boolean;
  var
    LArc: TArc2D;
  begin
    Result := False;
    if not Assigned(AVector) then Exit;

    if AVector.Segment.IsArc then
    begin
      LArc := UdGeo2D.ClipArc(AVector.Segment.Arc, AVector.FThis.FPoint, AVector.FNext.FPoint);

      //
      if (LArc.R > 0) and NotEqual(LArc.Ang1, LArc.Ang2) and
         not (IsEqual(LArc.Ang1, 0.0) and IsEqual(LArc.Ang2, 360.0)) then
      begin
        LArc.IsCW := UdGeo2D.IsClockWise(LArc, AVector.FThis.FPoint, AVector.FNext.FPoint);

        AReData := Integer(AVector.FSegment.Data);
        AReSegarc := UdGeo2D.Segarc2D(LArc);

        Result := True;
      end;
    end
    else begin
      AReData := Integer(AVector.FSegment.Data);
      AReSegarc := UdGeo2D.Segarc2D(Segment2D(AVector.FThis.FPoint, AVector.FNext.FPoint));

      Result := True;
    end;
  end;


  function _CalcNextPoint(var AVector: TScVector): TScPoint;
  var
    I, N, M: Integer;
    LCount: Integer;
    LVecAngle: Float;
    LThisPoint, LPrevPoint, LNextPoint: TScPoint;
    LPrevVector, LNextVector, LTempVector: TScVector;
  begin
    Result := nil;
    LPrevVector := nil;
    if not Assigned(AVector) or (AVector.FFlag) then Exit;

    AVector.FFlag := True;

    LPrevPoint := AVector.This;
    LThisPoint := AVector.Next;

    LVecAngle := -1.0;
    if AVector.Segment.IsArc then
      LVecAngle := FGetArcGetAngle(AVector.Segment.Arc, LThisPoint.FPoint, LPrevPoint.FPoint);


    LCount := LThisPoint.FVectorList.Count;

    N := -1;
    for I := 0 to LCount - 1 do
    begin
      LTempVector := TScVector(LThisPoint.FVectorList.Items[I]);
      if not Assigned(LTempVector) then Continue;

      if (LTempVector.Next = LPrevPoint) then
      begin
        if AVector.Segment.IsArc then
        begin
          if (LTempVector.Segment.IsArc) and IsEqual(LTempVector.Angle, LVecAngle, 0.1) then
            N := I;
        end
        else begin
          N := I;
        end;
      end;

      if N >= 0 then
      begin
        LPrevVector := LTempVector; //PrevVector是与AVector方向相反的Vector
        Break;
      end;
    end;

    if (LPrevVector <> nil) and (N >= 0) then
    begin
      if N = 0 then N := LCount - 1 else N := N - 1;   //逆时针查找
      LNextVector := TScVector(LThisPoint.FVectorList.Items[N]);

      M := 0;
      while ((LNextVector = nil) or (LNextVector.FFlag)) and (M < LCount) do
      begin
        if N = 0 then N := LCount - 1 else N := N - 1;  //逆时针查找
        LNextVector := TScVector(LThisPoint.FVectorList.Items[N]);

        M := M + 1;
      end;

      if M >= LCount then
      begin
        Result := nil;
        AVector := nil;
      end
      else begin
        LNextPoint := LNextVector.Next;
        AVector := LNextVector;

        Result := LNextPoint;
      end;
    end; {end if (LPrevVector <> nil) }
  end;


var
  L: Integer;
  LVector: TScVector;
  LStartPoint, LThisPoint: TScPoint;
begin
  Result := False;

  AReDatas := nil;
  AReSegarcs := nil;

  if not Assigned(AStartVector) then Exit;

  L := 0;
  LVector := AStartVector;

  System.SetLength(AReDatas, L + 1);
  System.SetLength(AReSegarcs, L + 1);

  if _GetSegarc(LVector, AReSegarcs[0], AReDatas[0]) then
    L := L + 1
  else begin
    System.SetLength(AReDatas, L);
    System.SetLength(AReSegarcs, L);
  end;

  LStartPoint := AStartVector.This;
  LThisPoint  := AStartVector.Next;

  while LThisPoint <> LStartPoint do
  begin
    LThisPoint := _CalcNextPoint(LVector);  //AVector递归

    if Assigned(LThisPoint) and Assigned(LVector) then
    begin
      System.SetLength(AReDatas, L + 1);
      System.SetLength(AReSegarcs, L + 1);

      if _GetSegarc(LVector, AReSegarcs[L], AReDatas[L]) then
        L := L + 1
      else begin
        System.SetLength(AReDatas, L);
        System.SetLength(AReSegarcs, L);
      end;

      if LThisPoint = LStartPoint then
      begin
        LVector.FFlag := True;
        Break;
      end;
    end
    else begin
      System.SetLength(AReDatas, 0);
      System.SetLength(AReSegarcs, 0);

      Break;
    end;
  end;

  Result := (LThisPoint = LStartPoint) and (System.Length(AReSegarcs) > 1) ;
end;


function TUdLoopSearch.CalcAllLoops: Boolean;

  procedure _AddToMinLoops(var ASegarcs: TSegarc2DArray; var ADatas: TIntegerDynArray);
  begin
    System.SetLength(FMinLoops, System.Length(FMinLoops) + 1);
    FMinLoops[High(FMinLoops)] := ASegarcs;

    System.SetLength(FMinLoopDatas, System.Length(FMinLoopDatas) + 1);
    FMinLoopDatas[High(FMinLoopDatas)] := ADatas;

    System.SetLength(FMinPolygons, System.Length(FMinPolygons) + 1);
    FMinPolygons[High(FMinPolygons)] := SamplePoints(ASegarcs, False);
  end;

  procedure _AddToMaxLoops(var ASegarcs: TSegarc2DArray; var ADatas: TIntegerDynArray);
  begin
    System.SetLength(FMaxLoops, System.Length(FMaxLoops) + 1);
    FMaxLoops[High(FMaxLoops)] := ASegarcs;

    System.SetLength(FMaxLoopDatas, System.Length(FMaxLoopDatas) + 1);
    FMaxLoopDatas[High(FMaxLoopDatas)] := ADatas;

    System.SetLength(FMaxPolygons, System.Length(FMaxPolygons) + 1);
    FMaxPolygons[High(FMaxPolygons)] := SamplePoints(ASegarcs, False);
  end;

var
  I: Integer;
  J, K: Integer;
  LPoint: TScPoint;
  LVector: TScVector;
  LPoints: TPoint2DArray;
  LDatas: TIntegerDynArray;
  LSegarcs: TSegarc2DArray;
  LPntList: TList;
  LPntLists: TList;
  LArea: Float;
  LMaxArea: Float;
  LMaxSegarcs: TSegarc2DArray;
  LMaxDatas: TIntegerDynArray;
begin
  LPntLists := TList.Create;
  try
    Self.PartPointList(LPntLists);
    for I := 0 to LPntLists.Count - 1 do
    begin
      LPntList := TList(LPntLists[I]);
      Self.SortPointList(LPntList);

      LMaxArea := 0.0;
      LMaxDatas := nil;
      LMaxSegarcs := nil;


      for J := 0 to LPntList.Count - 1 do
      begin
        LPoint := TScPoint(LPntList.Items[J]);

        for K := 0 to LPoint.FVectorList.Count - 1 do
        begin
          LVector := TScVector(LPoint.FVectorList.Items[K]);
          if not Assigned(LVector) then Continue;

          if not LVector.FFlag then
          begin
            if not FCalcLoop(LVector, LSegarcs, LDatas) then Continue;

            LPoints := SamplePoints(LSegarcs, True);

            //顺时针的为外围 最大的Loop
            if UdGeo2D.IsClockWise(LPoints) then
            begin
              LArea := UdGeo2D.Area(LPoints);
              if (System.Length(LMaxSegarcs) <= 0) or (LArea > LMaxArea) then
              begin
                if System.Length(LMaxSegarcs) > 0 then _AddToMinLoops(LMaxSegarcs, LDatas);

                LMaxArea := LArea;
                LMaxDatas := LDatas;
                LMaxSegarcs := LSegarcs;
              end
              else
                _AddToMinLoops(LSegarcs, LDatas);
            end
            else
              _AddToMinLoops(LSegarcs, LDatas);
          end; {end if not LVector.FFlag}
        end; {end for K}

        RaiseProgress(Round(100 * J / LPntList.Count));
      end; {end for J}


      if System.Length(LMaxSegarcs) > 0 then
        _AddToMaxLoops(LMaxSegarcs, LMaxDatas);

    end; {end for I}
  finally
    ClearObjectList(LPntLists);
    LPntLists.Free;
  end;

  Result := (System.Length(FMinLoops) > 0);
end;



//----------------------------------------------------------------------


procedure TUdLoopSearch.Clear();
begin
  Self.ClearAll();
end;

function TUdLoopSearch.Search(): Boolean; //Param: LongWord = SC_ALL
begin
  ClearObjectList(FSegarcList);
  ClearObjectList(FPointList);
  ClearLoops();

  RaiseProgress(0);
  try
    Result := CalcSegarcs()        and
              CalcPoints()         and   //求所有小线段之间的交点
              CheckPoints()        and   //去掉只产生一个交点的线段和交点，及其连锁反应
              SortSegemtsPoint()   and   //对小线段链表的每个小线段包含的交点进行排序
              CalcPointsVector()   and   //计算交点之间的关系
              CalcAllLoops()    ;//and   //计算封闭Loops
  finally
    RaiseProgress(-1);
  end;
end;






end.