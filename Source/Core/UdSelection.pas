{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdSelection;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Types,
  UdTypes, UdConsts, UdObject, UdAxes, UdEntity;

type
  //*** TUdSelection ***//
  TUdSelection = class(TObject)
  private
    FLayout: TUdObject;
    FList: TList;

    FMulitSelect: Boolean;

    FOnAddEntities: TUdEntitiesEvent;
    FOnRemoveEntities: TUdEntitiesEvent;
    FOnRemoveAll: TNotifyEvent;

  protected
    function GetCount: Integer;
    function GetItems(AIndex: Integer): TUdEntity;

    function GetShowGrips: Boolean;

  public
    constructor Create(ALayout: TUdObject);
    destructor Destroy; override;

    function PickEntity(APoint: TPoint2D; AForce: Boolean = False): TUdEntity; overload;
    function PickEntity(ARect: TRect2D; ACrossingMode: Boolean; AForce: Boolean = False): TUdEntityArray; overload;

    function AddEntity(AEntity: TUdEntity; ARaiseEvent: Boolean = True): Boolean;
    function AddEntities(AEntities: TUdEntityArray; ARaiseEvent: Boolean = True): Boolean;

    function SelectEntity(APoint: TPoint2D; ARaiseEvent: Boolean = False): Boolean;
    function SelectEntities(ARect: TRect2D; ACrossingMode: Boolean; ARaiseEvent: Boolean = False): Boolean;

    function RemoveAll(ARaiseEvent: Boolean = True): Boolean;
    function RemoveEntity(AEntity: TUdEntity; ARaiseEvent: Boolean = True): Boolean;
    function RemoveEntities(AEntities: TUdEntityArray; ARaiseEvent: Boolean = True): Boolean;

    function IndexOf(AEntity: TUdEntity): Integer;

    function DrawGrips(ACanvas: TCanvas): Boolean;

  public
    property List: TList read FList;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TUdEntity read GetItems;

    property ShowGrips: Boolean read GetShowGrips;
    property MulitSelect: Boolean read FMulitSelect write FMulitSelect;

    property OnAddEntities: TUdEntitiesEvent read FOnAddEntities write FOnAddEntities;
    property OnRemoveEntities: TUdEntitiesEvent read FOnRemoveEntities write FOnRemoveEntities;
    property OnRemoveAll: TNotifyEvent read FOnRemoveAll write FOnRemoveAll;

  end;


implementation

uses
  {$IFDEF D2010UP} System.UITypes, {$ENDIF} UdLayout, UdGeo2D, UdMath, UdDrawUtil;

const
  MAX_GRIPS_COUNT = 100;


//==================================================================================================
{ TUdSelection }


constructor TUdSelection.Create(ALayout: TUdObject);
begin
  FLayout := nil;
  if ALayout.InheritsFrom(TUdLayout) then FLayout := ALayout;

  FList := TList.Create;
  FMulitSelect := True;
end;

destructor TUdSelection.Destroy;
begin
  if Assigned(FList) then FList.Free;
  FList := nil;

  inherited;
end;



function TUdSelection.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TUdSelection.GetItems(AIndex: Integer): TUdEntity;
begin
  Result := nil;

  if AIndex < 0 then AIndex := AIndex + FList.Count;
  if (AIndex < 0) or (AIndex >= FList.Count) then Exit;

  Result := FList[AIndex];
end;

function TUdSelection.GetShowGrips: Boolean;
begin
  Result := (FList.Count <= MAX_GRIPS_COUNT);

  if Result and Assigned(FLayout) then
  begin
    Result := TUdLayout(FLayout).EnableGrip and (TUdLayout(FLayout).IsIdleAction or TUdLayout(FLayout).IsGripAction);
  end;
end;



function TUdSelection.DrawGrips(ACanvas: TCanvas): Boolean;

  {$IFDEF VER170} // Delphi 2005
  function _DrawGripPoints(ACanvas: TCanvas; AAxes: TUdAxes; AGripPoints: TUdGripPointArray; AColor: TColor = clBlue): Boolean;
  var
    I: Integer;
    V: Float;
    R: Integer;
    LX, LY: Integer;
    LR, LAng: Float;
    LBase, LPnt: TPoint2D;
    LPnts: array of TPoint;
  begin
    Result := False;
    if not Assigned(ACanvas) or not Assigned(AAxes) then Exit; //======>>>>

    ACanvas.Pen.Width := 1;
    ACanvas.Pen.Color := clGray;
    ACanvas.Pen.Style := psSolid;

    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := AColor;

    R := DEFAULT_PICK_SIZE;
    LR := AAxes.XValuePerPixel * R;

    System.SetLength(LPnts, 4);

    for I := 0 to System.Length(AGripPoints) - 1 do
    begin
      with AAxes.XAxis do
      begin
        V := (AGripPoints[I].Point.X - Min) * PixelPerValue;
        LX := Trunc(Pan + V) + AAxes.Margin;
      end;

      with AAxes.YAxis do
      begin
        V := (AGripPoints[I].Point.Y - Min) * PixelPerValue;
        LY := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
      end;

      case AGripPoints[I].Mode of
        gmAngle, gmRadius:
          begin
            LAng := AGripPoints[I].Angle;
            if AGripPoints[I].Mode = gmAngle then
            begin
              if AGripPoints[I].Index = 1 then
                LAng := FixAngle(LAng - 90)
              else
                LAng := FixAngle(LAng + 90);
            end;

            LBase := ShiftPoint(AGripPoints[I].Point, FixAngle(LAng+180), LR);

            LPnt := ShiftPoint(LBase, FixAngle(LAng+90), LR);
            LPnts[0] := AAxes.PointPixel(LPnt);

            LPnt := ShiftPoint(LBase, FixAngle(LAng-90), LR);
            LPnts[1] := AAxes.PointPixel(LPnt);

            LPnt := ShiftPoint(LBase, LAng, LR*3);
            LPnts[2] := AAxes.PointPixel(LPnt);

            LPnts[3] := LPnts[0];
          end
        else begin
          LPnts[0] := Point(LX - R, LY - R);
          LPnts[1] := Point(LX + R, LY - R);
          LPnts[2] := Point(LX + R, LY + R);
          LPnts[3] := Point(LX - R, LY + R);
        end;
      end;

      ACanvas.Polygon(LPnts);
    end;

    Result := True;
  end;
  {$ENDIF}

var
  I: Integer;
  LEntity: TUdEntity;
  LGripPnts: TUdGripPointArray;
begin
  Result := False;
  if not Assigned(FLayout) or not Self.GetShowGrips() then Exit;

  for I := 0 to FList.Count - 1 do
  begin
    LEntity := TUdEntity(FList.Items[I]);
    LGripPnts := LEntity.GetGripPoints();
    {$IFDEF VER170} // Delphi 2005
    _DrawGripPoints(ACanvas, TUdLayout(FLayout).Axes, LGripPnts);
    {$ELSE}
    UdDrawUtil.DrawGripPoints(ACanvas, TUdLayout(FLayout).Axes, LGripPnts);
    {$ENDIF}
  end;

  Result := True;
end;


function TUdSelection.IndexOf(AEntity: TUdEntity): Integer;
begin
  Result := FList.IndexOf(AEntity);
end;

{$DEFINE UPDATE_SEL_ENTITY}

function TUdSelection.PickEntity(APoint: TPoint2D; AForce: Boolean = False): TUdEntity;
const
  MAX_PERP_COUNT = 10;
var
  I: Integer;
  LEntity: TUdEntity;
  LArea, LArea1: Float;
  LLayout: TUdLayout;
  LTempList, LEntityList: TList;
begin
  Result := nil;

  LLayout := TUdLayout(FLayout);
  if not Assigned(LLayout) or LLayout.Updating then Exit;

  LEntityList := LLayout.GetPartialEntities(APoint, DEFAULT_PICK_SIZE * LLayout.Axes.XValuePerPixel);

  LTempList := TList.Create;
  try
    for I := 0 to LEntityList.Count - 1 do
    begin
      LEntity := TUdEntity(LEntityList.Items[I]);
      if not Assigned(LEntity) then Continue;

      if LEntity.Pick(APoint) then
      begin
        LTempList.Add(LEntity);
        if LTempList.Count > MAX_PERP_COUNT then Break;
      end;
    end;

    if LTempList.Count > 0 then
    begin
      LEntity := TUdEntity(LTempList[0]);
      LArea1 := UdGeo2D.Area(LEntity.BoundsRect);

      for I := 1 to LTempList.Count - 1 do
      begin
        LArea := UdGeo2D.Area(TUdEntity(LTempList[I]).BoundsRect);
        if LArea < LArea1 then LEntity := TUdEntity(LTempList[I]);
      end;

    {$IFDEF UPDATE_SEL_ENTITY}
      if LEntity.Selected and (LEntity.TypeID in [ID_CIRCLE, ID_ARC, ID_ELLIPSE]) then
        LEntity.Update();
    {$ENDIF}

      Result := LEntity;
    end;
  finally
    LTempList.Free;
  end;
end;


function TUdSelection.PickEntity(ARect: TRect2D; ACrossingMode: Boolean; AForce: Boolean = False): TUdEntityArray;
var
  I: Integer;
  LEntity: TUdEntity;
  LLayout: TUdLayout;
  LTempList: TList;
begin
  Result := nil;

  LLayout := TUdLayout(FLayout);
  if not Assigned(LLayout) or LLayout.Updating then Exit;

  LTempList := TList.Create;
  try
    LTempList.Capacity := 512;
    for I := 0 to LLayout.VisibleList.Count - 1 do
    begin
      LEntity := TUdEntity(LLayout.VisibleList.Items[I]);
      if not Assigned(LEntity) then Continue;

      if LEntity.Pick(ARect, ACrossingMode) then LTempList.Add(LEntity);
    end;

    System.SetLength(Result, LTempList.Count);
    for I := 0 to LTempList.Count - 1 do Result[I] := TUdEntity(LTempList.Items[I]);
  finally
    LTempList.Free;
  end;
end;






function TUdSelection.AddEntity(AEntity: TUdEntity; ARaiseEvent: Boolean = True): Boolean;
var
  LEntities: TUdEntityArray;
begin
  Result := False;
  if FList.IndexOf(AEntity) >= 0 then Exit;

  if Assigned(FLayout) and Assigned(TUdLayout(FLayout).DrawPanel) then
    if TUdLayout(FLayout).DrawPanel.DblClicking then Exit;  //=======>>>>>

  if not FMulitSelect then
    Self.RemoveAll(ARaiseEvent);

  AEntity.Selected := True;
  FList.Add(AEntity);

  if Assigned(FOnAddEntities) then
  begin
    System.SetLength(LEntities, 1);
    LEntities[0] := AEntity;

    FOnAddEntities(Self, LEntities);
  end;

  Result := False;
end;

function TUdSelection.AddEntities(AEntities: TUdEntityArray; ARaiseEvent: Boolean = True): Boolean;
var
  I: Integer;
  LEntity: TUdEntity;
  LTempList: TList;
  LEntities: TUdEntityArray;
begin
  Result := False;
  if Assigned(FLayout) and Assigned(TUdLayout(FLayout).DrawPanel) then
    if TUdLayout(FLayout).DrawPanel.DblClicking then Exit;  //=======>>>>>

  if not FMulitSelect then
  begin
    Self.AddEntity(AEntities[0], ARaiseEvent);
    Exit; //====>>>>
  end;

  LTempList := TList.Create;
  try
    LTempList.Capacity := 512;
    for I := 0 to System.Length(AEntities) - 1 do
    begin
      LEntity := AEntities[I];
      if FList.IndexOf(LEntity) < 0 then LTempList.Add(LEntity);
    end;

    System.SetLength(LEntities, LTempList.Count);
    for I := 0 to LTempList.Count - 1 do
    begin
      LEntity := TUdEntity(LTempList[I]);
      LEntity.Selected := True;

      FList.Add(LEntity);
      LEntities[I] := LEntity;
    end;

    Result := System.Length(LEntities) > 0;
    if Result and Assigned(FOnAddEntities) then FOnAddEntities(Self, LEntities);
  finally
    LTempList.Free;
  end;
end;





function TUdSelection.SelectEntity(APoint: TPoint2D; ARaiseEvent: Boolean = False): Boolean;
begin
  Result := Self.AddEntity(Self.PickEntity(APoint), ARaiseEvent);
end;

function TUdSelection.SelectEntities(ARect: TRect2D; ACrossingMode: Boolean; ARaiseEvent: Boolean = False): Boolean;
begin
  Result := Self.AddEntities(Self.PickEntity(ARect, ACrossingMode), ARaiseEvent);
end;




function TUdSelection.RemoveAll(ARaiseEvent: Boolean = True): Boolean;
var
  I: Integer;
  LEntities: TUdEntityArray;
begin
  Result := False;
  if FList.Count <= 0 then Exit;

  System.SetLength(LEntities, FList.Count);
  for I := 0 to FList.Count - 1 do
  begin
    LEntities[I] := TUdEntity(FList[I]);
    TUdEntity(FList[I]).Selected := False;
  end;

  FList.Clear;

  if ARaiseEvent and Assigned(FOnRemoveAll) then FOnRemoveAll(Self);
  if ARaiseEvent and Assigned(FOnRemoveEntities) then FOnRemoveEntities(Self, LEntities);

  Result := True;
end;

function TUdSelection.RemoveEntity(AEntity: TUdEntity; ARaiseEvent: Boolean = True): Boolean;
var
  LEntities: TUdEntityArray;
begin
  Result := False;
  if not Assigned(AEntity) or (FList.IndexOf(AEntity) < 0) then Exit;

  FList.Remove(AEntity);
  AEntity.Selected := False;

  if ARaiseEvent and Assigned(FOnRemoveEntities) then
  begin
    System.SetLength(LEntities, 1);
    LEntities[0] := AEntity;

    FOnRemoveEntities(Self, LEntities);
  end;

  Result := True;
end;

function TUdSelection.RemoveEntities(AEntities: TUdEntityArray; ARaiseEvent: Boolean = True): Boolean;
var
  I: Integer;
  LEntity: TUdEntity;
begin
  Result := False;
  if not Assigned(AEntities) or (System.Length(AEntities) <= 0) then Exit;

  for I := 0 to System.Length(AEntities) - 1 do
  begin
    LEntity := TUdEntity(AEntities[I]);
    LEntity.Selected := False;

    FList.Remove(LEntity);
  end;

  if ARaiseEvent and Assigned(FOnRemoveEntities) then
    FOnRemoveEntities(Self, AEntities);

  Result := True;
end;



end.