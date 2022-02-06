{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionOffset;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls, Types,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine;


type  
  //*** UdActionOffset ***//
  TUdActionOffset = class(TUdModifyAction)
  private
    FP1, FP2: TPoint2D;
    
    FLine: TUdLine;
    FSelEntity: TUdEntity;

  protected
    function SetOffsetP1(APnt: TPoint2D): Boolean;
    function SetOffsetP2(APnt: TPoint2D): Boolean;

    function SetOffsetDist(const AValue: PDouble): Boolean;
    function SetOffsetSide(APnt: TPoint2D): Boolean;

    function SelectEntity(APnt: TPoint2D): Boolean;    

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    function Parse(const AValue: string): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;  


implementation

uses
  SysUtils,
  UdGeo2D, UdUtils, UdAcnConsts,
  UdPolyline, UdSpline;

var
  GSetOffsetDistance: Float = 5.0;

    
//==================================================================================================
{ TUdActionOffset }

class function TUdActionOffset.CommandName: string;
begin
  Result := 'offset';
end;

constructor TUdActionOffset.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  Self.CanOSnap := True;
  FSelAction.Visible := False;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  Self.RemoveAllSelected();
  Self.CanPolar := True;

  Self.SetCursorStyle(csDraw);
  Self.Prompt(sOffsetDistance + ' <' + RealToStr(GSetOffsetDistance) + '>', pkCmd);
end;

destructor TUdActionOffset.Destroy;
begin
  if Assigned(FLine) then FLine.Free;
  if Assigned(FSelEntity) then FSelEntity.Selected := False;
  inherited;
end;


procedure TUdActionOffset.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
end;




//--------------------------------------------------------------------------------------------



function TUdActionOffset.SetOffsetP1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;
  FLine.StartPoint := FP1;
  FLine.EndPoint   := FP1;

  FLine.Visible := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionOffset.SetOffsetP2(APnt: TPoint2D): Boolean;
var
  LDis: Double;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FP2 := APnt;

  FLine.Visible := False;
  Self.Prompt(sSecondPoint, pkLog);

  LDis := Distance(FP1, FP2);
  Result := SetOffsetDist(@LDis);
end;


function TUdActionOffset.SetOffsetDist(const AValue: PDouble): Boolean;
begin
//  Result := False;
//  if FStep <> 1 then Exit;

  Self.CanOSnap := False;
  Self.CanOrtho := False;
  Self.SetCursorStyle(csPick);

  FStep := 2;
  if AValue <> nil then GSetOffsetDistance := AValue^;

  Self.Prompt(sOffsetDistance + ' <' + RealToStr(GSetOffsetDistance) + '>', pkLog);
  Self.Prompt(sSelectOffObject, pkCmd);

  Self.CanPolar := False;

  Result := True;
end;

function TUdActionOffset.SetOffsetSide(APnt: TPoint2D): Boolean;
var
  LDis: Float;
  LEntity: TUdEntity;
  LPoints: TPoint2DArray;
  LPolyline: TUdPolyline;
begin
  Result := False;

  if (FStep <> 3) then Exit;

  if Assigned(FSelEntity) then
  begin
    if FSelEntity.InheritsFrom(TUdSpline) then
    begin
      LDis := GSetOffsetDistance;
      LPoints := TUdSpline(FSelEntity).SamplePoints;
      LPoints := UdGeo2D.OffsetPoints(LPoints, LDis, APnt);

      if System.Length(LPoints) > 0 then
      begin
        LPolyline := TUdPolyline.Create(FDocument, False);
        LPolyline.Assign(FSelEntity);
        LPolyline.Closed := False;
        LPolyline.SetPoints(LPoints);

        Self.AddEntity(LPolyline);
        LPolyline.Refresh();
      end;
    end
    else begin
      LEntity := FSelEntity.Clone();
      if LEntity.Offset(GSetOffsetDistance, APnt) then
      begin
        Self.AddEntity(LEntity);
        LEntity.Refresh();
      end
      else LEntity.Free;
    end;
    
    FSelEntity.Selected := False;
    Self.RemoveSelectedEntity(FSelEntity);

    Self.SetCursorStyle(csPick);
    Self.Prompt(sOffsetSide + ': ' + PointToStr(APnt), pkLog);
    Self.Prompt(sSelectOffObject, pkCmd);

    FStep := 2;
    Result := True;
  end
  else
    Self.Finish();
end;




function TUdActionOffset.SelectEntity(APnt: TPoint2D): Boolean;
var
  LEntity: TUdEntity;
begin
  Result := False;

  if (FStep <> 2) then Exit;

  LEntity := Self.PickEntity(APnt);
  if (LEntity <> nil) then
  begin
    if (LEntity.TypeID > ID_Entity) and (LEntity.TypeID <= ID_SPLINE) then
    begin
      FSelEntity := LEntity;
      FStep := 3;

      FSelEntity.Selected := True;
      Self.AddSelectedEntity(FSelEntity);

      Self.SetCursorStyle(csDraw);
      Self.Prompt(sSelectOffObject, pkLog);
      Self.Prompt(sOffsetSide, pkCmd);

      Result := True;
    end
    else
      Self.Prompt(sCannotToOffset, pkLog);
  end;
end;


//--------------------------------------------------------------------------------------------

function TUdActionOffset.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LDist: Float;
begin
  if Trim(AValue) = '' then
  begin
    if FStep = 0 then
      SetOffsetDist(nil)
    else
      Self.Finish();
  end
  else begin

    if (FStep = 0) then
    begin
      if TryStrToFloat(AValue, LDist)  then
        SetOffsetDist(@LDist)
      else
        Self.Prompt(sRequireValue, pkLog);
    end
    else if (FStep in [0,1,3]) then
    begin
      if ParseCoord(AValue, LPnt, LIsOpp) then
      begin
        if FStep = 0 then SetOffsetP1(LPnt) else
        if FStep = 1 then SetOffsetP2(LPnt) else
        if FStep = 3 then SetOffsetSide(LPnt);
      end
      else
        Self.Prompt(sInvalidPoint, pkLog);
    end;
    
  end;
  Result := True;
end;



procedure TUdActionOffset.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //....
end;

procedure TUdActionOffset.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetOffsetP1(ACoordPnt)
          else if FStep = 1 then
            SetOffsetP2(ACoordPnt)
          else if FStep = 2 then
            SelectEntity(ACoordPnt)
          else if FStep = 3 then
            SetOffsetSide(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;

    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          FP2 := ACoordPnt;
          FLine.EndPoint := FP2;
        end;
      end;      
  end;
end;

end.