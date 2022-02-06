{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionGrip;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls, Types,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject,
  UdEntity, UdAction, UdLine;


const
  MAX_GRIP_COUNT = 16;

    
type
  //*** UdActionGrip ***//
  TUdActionGrip = class(TUdAction)
  private
    FLine: TUdLine;
    FOffsetDis: TPoint2D;

    FGripPoints: TUdGripPointArray;

    FCopyMode: Boolean;
    FGripEntities: TList;
    FTaskEntities: TList;

    FUndoEntityArrays: TUdEntityArrays;

  protected
    procedure ClearGripEntities(AGripEntities: TList; AFreeEntity: Boolean);

    function InitAction(): Boolean;
    function MoveGrips(APnt: TPoint2D; AIsGrip: Boolean = False): Boolean;

    procedure SetGripPoints(const AValue: TUdGripPointArray);
    procedure SetBasePoint(APnt: TPoint2D);

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;

    function CanPopMenu: Boolean; override;

  public
    property GripPoints: TUdGripPointArray read FGripPoints write SetGripPoints;
                           
  end;



implementation

uses
  SysUtils,
  UdLayout, UdAxes, UdFigure,// UdRay, UdXLine,// UdCircle, UdArc, UdDimension,
  UdMath, UdGeo2D, UdUtils, UdDrawUtil, UdAcnConsts;


type
  TFFigure = class(TUdFigure);
  TFLayout = class(TUdLayout);

  TUdGripEntity = class(TObject)
  private
    FEntity: TUdEntity;
    FGripPoints: TUdGripPointArray;

  public
    constructor Create();
    destructor Destroy; override;

    property Entity: TUdEntity read FEntity write FEntity;
    property GripPoints: TUdGripPointArray read FGripPoints write FGripPoints;
  end;  


{ TUdGripEntity }

constructor TUdGripEntity.Create;
begin
  FEntity := nil;
  FGripPoints := nil;
end;

destructor TUdGripEntity.Destroy;
begin
  if Assigned(FEntity) then FEntity.Free;
  FEntity := nil;

  System.SetLength(FGripPoints, 0);

  inherited;
end;


//=========================================================================================
{ TUdActionGrip }

class function TUdActionGrip.CommandName: string;
begin
  Result := '**STRETCH**';
end;

constructor TUdActionGrip.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FCopyMode := False;
  FOffsetDis := Point2D(0, 0);
  FGripPoints := nil;
  FUndoEntityArrays := nil;

  FGripEntities := TList.Create;
  FTaskEntities := TList.Create;

//  Self.CanSnap := True;
  Self.CanOSnap := True;
  Self.CanOrtho := True;
  Self.CanPerpend := True;
  
  Self.SetCursorStyle(csDraw);

  Self.Prompt(sStretchName, pkLog);
  Self.Prompt(sStretchPointOrKeyword, pkCmd);
end;

destructor TUdActionGrip.Destroy;
begin
  if Assigned(FLine) then FLine.Free();

  ClearGripEntities(FGripEntities, False);
  ClearGripEntities(FTaskEntities, True);

  FTaskEntities.Free;
  FTaskEntities := nil;

  FGripEntities.Free;
  FGripEntities := nil;

  inherited;
end;

procedure TUdActionGrip.ClearGripEntities(AGripEntities: TList; AFreeEntity: Boolean);
var
  I: Integer;
begin
  for I := AGripEntities.Count - 1 downto 0 do
  begin
    if not AFreeEntity then TUdGripEntity(AGripEntities[I]).Entity := nil;
    TUdGripEntity(AGripEntities[I]).Free;
  end;

  AGripEntities.Clear;
end;



//--------------------------------------------------------------------------------


function _IndexEntity(AEntity: TUdEntity; AGripEntities: TList): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := AGripEntities.Count - 1 downto 0 do
    if TUdGripEntity(AGripEntities[I]).Entity = AEntity then
    begin
      Result := I;
      Break;
    end;
end;


(*
function GetGripEntityDims(AGripEntity: TUdGripEntity; ADimEntities: TList): Boolean;
var
  I, J: Integer;
  LDim: TUdEntity;
  LCenter: PPoint2D;
  LGripPnts: TUdGripPointArray;
begin
  Result := False;
  if not Assigned(AGripEntity) or not Assigned(ADimEntities) then Exit;

  if not Assigned(AGripEntity.FEntity) or
     not (AGripEntity.FEntity.InheritsFrom(TUdCircle) or AGripEntity.FEntity.InheritsFrom(TUdArc)) then Exit;

  LCenter := TFFigure(AGripEntity.FEntity).GetCenter();
  if not Assigned(LCenter) then Exit;


  for I := 0 to ADimEntities.Count - 1 do
  begin
    LDim := ADimEntities[I];

    if UdGeo2D.IsPntInRect(LCenter^, LDim.BoundsRect) then
    begin
      LGripPnts := LDim.GetGripPoints();

      for J := 0 to System.Length(LGripPnts) - 1 do
      begin
        if LGripPnts[J].Mode = gmCenter then
        begin
          AGripEntity.DimEntities.Add(LDim);
          Break;
        end;
      end;
    end;

  end;
end;
*)
  
function TUdActionGrip.InitAction(): Boolean;
var
  I, J, N: Integer;
  LPoint: TUdGripPoint;
  LSrcEntity, LDstEntity: TUdGripEntity;
begin
  Result := False;
  if System.Length(FGripPoints) <= 0 then Exit;  //=======>>>>

  if FGripEntities.Count <= 0 then
  begin
    for I := 0 to System.Length(FGripPoints) - 1 do
    begin
      LPoint := FGripPoints[I];

      N := _IndexEntity(TUdEntity(LPoint.Entity), FGripEntities);
      if N < 0 then
      begin
        LSrcEntity := TUdGripEntity.Create;
        LSrcEntity.Entity := TUdEntity(LPoint.Entity);
        FGripEntities.Add(LSrcEntity);
      end
      else
        LSrcEntity := TUdGripEntity(FGripEntities[N]);

      System.SetLength(LSrcEntity.FGripPoints, System.Length(LSrcEntity.FGripPoints) + 1);
      LSrcEntity.FGripPoints[High(LSrcEntity.FGripPoints)] := LPoint;
    end;
  end;

  ClearGripEntities(FTaskEntities, False);

  for I := 0 to FGripEntities.Count - 1 do
  begin
    LSrcEntity := TUdGripEntity(FGripEntities[I]);

    LDstEntity := TUdGripEntity.Create;
    
    LDstEntity.Entity := LSrcEntity.Entity.Clone();
    LDstEntity.Entity.Finished := False;
    LDstEntity.Entity.Visible := False;

    System.SetLength(LDstEntity.FGripPoints, System.Length(LSrcEntity.FGripPoints));
    for J := 0 to System.Length(LSrcEntity.FGripPoints) - 1 do
    begin
      LDstEntity.FGripPoints[J] := LSrcEntity.FGripPoints[J];
      LDstEntity.FGripPoints[J].Entity := LDstEntity.Entity;
    end;

    FTaskEntities.Add(LDstEntity);
  end;

  FLine.StartPoint := FGripPoints[0].Point;
  FLine.EndPoint := FGripPoints[0].Point;
  FLine.Visible := True;

  Result := FGripEntities.Count > 0;
end;


function TUdActionGrip.MoveGrips(APnt: TPoint2D; AIsGrip: Boolean = False): Boolean;
var
  I, J: Integer;
  LPnt: TPoint2D;
  LEntityList: TList;
  LGripEntity: TUdGripEntity;
begin
  if AIsGrip then
    LEntityList := FGripEntities
  else
    LEntityList := FTaskEntities;

  for I := 0 to LEntityList.Count - 1 do
    TUdGripEntity(LEntityList[I]).Entity.BeginUpdate();

  try
    if not AIsGrip then
      for I := 0 to LEntityList.Count - 1 do
        TUdGripEntity(LEntityList[I]).Entity.Assign(TUdGripEntity(FGripEntities[I]).Entity);


    LPnt.X := APnt.X + FOffsetDis.X;
    LPnt.Y := APnt.Y + FOffsetDis.Y;

    for I := 0 to LEntityList.Count - 1 do
    begin
      LGripEntity := TUdGripEntity(LEntityList[I]);

      for J := 0 to System.Length(LGripEntity.GripPoints) - 1 do
      begin
        LGripEntity.GripPoints[J].Point := LPnt;
        LGripEntity.Entity.MoveGrip(LGripEntity.GripPoints[J]);
      end;

      LGripEntity.Entity.Visible := True;
    end;

  finally
    for I := 0 to LEntityList.Count - 1 do
    begin
      LGripEntity := TUdGripEntity(LEntityList[I]);
      LGripEntity.Entity.EndUpdate();
    end;
  end;

  Result := True;
end;






//-------------------------------------------------------------------------------




function TUdActionGrip.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  N: Integer;
  LValue: string;
  LLayout: TUdLayout;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));

  if (FStep = 1) then
  begin
    if ParseCoord(LValue, LPnt, LIsOpp) then
      SetBasePoint(LPnt)
    else
      Self.Prompt(sInvalidPoint, pkLog);

    Exit; //=======>>>
  end;

  if ParseCoord(LValue, LPnt, LIsOpp) then
  begin
    if LIsOpp then
    begin
      LPnt.X := FLine.StartPoint.X + LPnt.X;
      LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
    end;
    
    Self.MoveGrips(LPnt, not FCopyMode);
    Self.Finish();

    Exit; //=======>>>
  end
  else if (LValue = 'c') or (LValue = 'copy') then
  begin
    Self.Prompt(sStretchPointOrKeyword + ': ' + LValue, pkLog); 
    
    FCopyMode := not FCopyMode;

    if FCopyMode then
      Self.Prompt(sMuliStretchName, pkLog)
    else
      Self.Prompt(sStretchName, pkLog);

    Self.Prompt(sStretchPointOrKeyword, pkCmd);    
  end
  else if (LValue = 'b') or (LValue = 'base') then
  begin
    FStep := 1;

    Self.Prompt(sStretchPointOrKeyword + ': ' + LValue, pkLog);  
    Self.Prompt(sBasePoint, pkCmd);
    
    Self.Invalidate();
  end
  else if (LValue = 'u') or (LValue = 'undo') then
  begin
    LLayout := TUdLayout(Self.GetLayout());
    if Assigned(LLayout) then
    begin
      N := System.Length(FUndoEntityArrays) - 1;
      if N >= 0 then
      begin
        LLayout.RemoveEntities(FUndoEntityArrays[N]);
        Self.Invalidate();
        
        System.SetLength(FUndoEntityArrays, N);
      end;
    end;
  end
  else if (LValue = 'x') or (LValue = 'exit') then
  begin
    Result := Self.Finish();
  end
  else
    Self.Prompt(sRequireKeyword, pkLog);
end;


procedure TUdActionGrip.Paint(Sender: TObject; ACanvas: TCanvas);

{$IFDEF VER170} //Delphi 2005
  function _DrawGripPoint(ACanvas: TCanvas; AAxes: TUdAxes; AGripPoint: TUdGripPoint; AColor: TColor = clBlue): Boolean;
  var
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

    with AAxes.XAxis do
    begin
      V := (AGripPoint.Point.X - Min) * PixelPerValue;
      LX := Trunc(Pan + V) + AAxes.Margin;
    end;

    with AAxes.YAxis do
    begin
      V := (AGripPoint.Point.Y - Min) * PixelPerValue;
      LY := Trunc(AAxes.Height - Pan - V) - AAxes.Margin;
    end;

    case AGripPoint.Mode of
      gmAngle, gmRadius:
        begin
          LAng := AGripPoint.Angle;
          if AGripPoint.Mode = gmAngle then
          begin
            if AGripPoint.Index = 1 then
              LAng := FixAngle(LAng - 90)
            else
              LAng := FixAngle(LAng + 90);
          end;

          LBase := ShiftPoint(AGripPoint.Point, FixAngle(LAng+180), LR);

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

    Result := True;
  end;
{$ENDIF}
    
var
  I: Integer;
  LLayout: TUdLayout;
begin
  LLayout := TUdLayout(Self.GetLayout());
  
  if Assigned(LLayout) and (System.Length(FGripPoints) > 0) then
  begin
    {$IFDEF VER170} //Delphi 2005
    _DrawGripPoint(ACanvas, LLayout.Axes, FGripPoints[0], clRed);
    {$ELSE}
    UdDrawUtil.DrawGripPoint(ACanvas, LLayout.Axes, FGripPoints[0], clRed);
    {$ENDIF}
  end;

  if FStep = 0 then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);

    for I := 0 to FTaskEntities.Count - 1 do
    begin
      if TUdGripEntity(FTaskEntities[I]).Entity.Visible then
         TUdGripEntity(FTaskEntities[I]).Entity.Draw(ACanvas);
    end;
  end;
end;


procedure TUdActionGrip.SetGripPoints(const AValue: TUdGripPointArray);
begin
  FGripPoints := AValue;
  if not InitAction() then Self.Finish();
end;

procedure TUdActionGrip.SetBasePoint(APnt: TPoint2D);
begin
  if System.Length(FGripPoints) > 0 then
  begin
    FOffsetDis.X := FGripPoints[0].Point.X - APnt.X;
    FOffsetDis.Y := FGripPoints[0].Point.Y - APnt.Y;
  end;

  FStep := 0;

  SetPrevPoint(APnt);

  if FCopyMode then
    Self.Prompt(sMuliStretchName, pkLog)
  else
    Self.Prompt(sStretchName, pkLog);

  Self.Prompt(sStretchPointOrKeyword, pkCmd);  
end;



procedure TUdActionGrip.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  
end;

procedure TUdActionGrip.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  I: Integer;
  LLayout: TUdLayout;
  LEntities: TUdEntityArray;
begin
  inherited;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit;
  
  
  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
          begin
            Self.MoveGrips(ACoordPnt, not FCopyMode);

            if FCopyMode then
            begin
              System.SetLength(LEntities, FTaskEntities.Count);
              for I := 0 to FTaskEntities.Count - 1 do
                LEntities[I] := TUdGripEntity(FTaskEntities[I]).Entity;
              LLayout.AddEntities(LEntities);

              System.SetLength(FUndoEntityArrays, System.Length(FUndoEntityArrays) + 1);
              FUndoEntityArrays[High(FUndoEntityArrays)] :=  LEntities;

              InitAction();
            end
            else
              Self.Finish();
          end
          else if FStep = 1 then
          begin
            Self.SetBasePoint(ACoordPnt);   
          end;
        end
        else if (AButton = mbRight) then
        begin
          if FStep = 0 then
            Self.Finish()
          else if FStep = 1 then
            Self.SetBasePoint(ACoordPnt);
        end;
      end;
    mkMouseMove:
      begin
        if FStep = 0 then
        begin
          MoveGrips(ACoordPnt);
          FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;


function TUdActionGrip.CanPopMenu(): Boolean;
begin
  Result := False;
end;






end.