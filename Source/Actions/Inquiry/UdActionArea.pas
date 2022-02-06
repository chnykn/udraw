{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionArea;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdPolyline;

type

  //*** TUdActionArea ***//
  TUdActionArea = class(TUdInquiryAction)
  private
    FLastAng: Float;
    FPrevAng: Float;

    FLine: TUdLine;
    FPolyline: TUdPolyline;

    FLastPnt: TPoint2D;
    FCurrPnt: TPoint2D;

    FPointMode: Boolean;

  protected
    function GetPrevAngle: Float; override;

    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetNextPoint(APnt: TPoint2D): Boolean;
    function FinishAction(AClose: Boolean = False): Boolean;

    function PickAreaObject(APnt: TPoint2D): Boolean;
        
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
  UdLayout, UdMath, UdGeo2D, UdUtils, UdAcnConsts,
  UdRect, UdCircle, UdEllipse , UdSpline;
  

//================================================================================================
{ TUdActionArea }


class function TUdActionArea.CommandName: string;
begin
  Result := 'area';
end;



constructor TUdActionArea.Create(ADocument, ALayout: TUdObject; Args: string);
begin
  inherited;

  FPointMode := True;
  
  FLastAng := -1;
  FPrevAng := -1;
  
  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;
  FLine.Color.TrueColor := Self.GetDefColor();
    
  FPolyline := TUdPolyline.Create(FDocument, False);
  FPolyline.Closed := False;
  FPolyline.Finished := False;
  FPolyline.Visible := False;
  FPolyline.Color.TrueColor := Self.GetDefColor();
  
  Self.CanSnap    := True;
  Self.CanOSnap   := True;
  Self.CanPerpend := True;
    
  Self.SetCursorStyle(csDraw);
  Self.Prompt(sFirstCornerOrObj, pkCmd);
end;

destructor TUdActionArea.Destroy;
begin
  if Assigned(FLine) then FLine.Free;
  FLine := nil;
  
  if Assigned(FPolyline) then FPolyline.Free;
  FPolyline := nil;
  
  inherited;
end;

function TUdActionArea.GetPrevAngle: Float;
begin
  Result := FLastAng;
end;


procedure TUdActionArea.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Self.Visible then
  begin
    if FLine.Visible then FLine.Draw(ACanvas);
    if FPolyline.Visible then FPolyline.Draw(ACanvas);
  end;
end;



//--------------------------------------------------------------------------

function TUdActionArea.SetFirstPoint(APnt: TPoint2D): Boolean;
var
  LLayout: TUdLayout;
begin
  Result := False;
  if FStep <> 0 then Exit;

  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
    LLayout.Drafting.ObjectSnap.AddTempEntity(FPolyline);


  FLastPnt := APnt;
  FCurrPnt := APnt;

  Self.CanOrtho := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstCornerOrObj + ': ' + PointToStr(APnt), pkLog);

  Self.Prompt(sNextPointOrEnter, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionArea.SetNextPoint(APnt: TPoint2D): Boolean;

  function _AddPoint(APnt: TPoint2D): Boolean;
  var
    LSegarc: TSegarc2D;
    LSegarcs: TSegarc2DArray;
  begin
    Result := False;
    if not Assigned(FPolyline) then Exit;

    if System.Length(FPolyline.Vertexes) > 0 then
      if IsEqual(APnt, FPolyline.Vertexes[High(FPolyline.Vertexes)].Point) then Exit; //======>>>>

    LSegarc := Segarc2D(FLastPnt, APnt);

    LSegarcs := FPolyline.XData;
    System.SetLength(LSegarcs, System.Length(LSegarcs) + 1);
    LSegarcs[High(LSegarcs)] := LSegarc;

    FPolyline.XData := LSegarcs;

    Result := True;
  end;

begin
  Result := False;
  if FStep <> 1 then Exit;

  if not _AddPoint(APnt) then Exit;

  FPolyline.Visible := True;
  FLastAng := GetAngle(FLastPnt, APnt);

  FPrevAng := FLastAng;

  FLastPnt := APnt;
  Self.SetPrevPoint(APnt);

  Self.Prompt(sNextPointOrEnter + ': ' + PointToStr(APnt), pkLog);


  Result := True;
  Self.Invalidate;
end;



function TUdActionArea.FinishAction(AClose: Boolean): Boolean;
var
  L: Integer;
  LStr: string;
begin
  Result := False;

  if FStep = 0 then
  begin
    Result := Finish();
    Exit; //=======>>>>
  end;

  if FStep <> 1 then Exit;

  L := System.Length(FPolyline.XData);

  if L > 0 then
  begin
    FPolyline.Closed := True;

    LStr := 'Area = ' + Self.RealToStr(FPolyline.Area)  + ' , ' +
            'Perimeter = ' + Self.RealToStr(FPolyline.Length);
    Self.Prompt(LStr, pkLog);
  end;

  Result := Finish();
end;

function TUdActionArea.PickAreaObject(APnt: TPoint2D): Boolean;
var
  LStr: string;
  LPoints: TPoint2DArray;
  LEntity: TUdEntity;
  LLayout: TUdLayout;
begin
  Result := False;
  if FStep <> 0 then Exit;

  LLayout := TUdLayout(Self.GetLayout());
  if Assigned(LLayout) then
  begin
    LEntity := LLayout.PickEntity(APnt);

    if Assigned(LEntity) then
    begin
      LStr := '';
      
      if LEntity.InheritsFrom(TUdPolyline) then
      begin
        LStr := 'Area = ' + Self.RealToStr(TUdPolyline(LEntity).Area)  + ' , ' +
                'Perimeter = ' + Self.RealToStr(TUdPolyline(LEntity).Length);
      end
      else if LEntity.InheritsFrom(TUdRect) then
      begin
        LStr := 'Area = ' + Self.RealToStr(Area(TUdRect(LEntity).XData))  + ' , ' +
                'Perimeter = ' + Self.RealToStr(Perimeter(TUdRect(LEntity).XData));
      end
      else if LEntity.InheritsFrom(TUdCircle) then
      begin
        LStr := 'Area = ' + Self.RealToStr(TUdCircle(LEntity).Area)  + ' , ' +
                'Circumference = ' + Self.RealToStr(TUdCircle(LEntity).Circumference);
      end
      else if LEntity.InheritsFrom(TUdEllipse) then
      begin
        LStr := 'Area = ' + Self.RealToStr(TUdEllipse(LEntity).Area)  + ' , ' +
                'Length = ' + Self.RealToStr(TUdEllipse(LEntity).ArcLength);
      end

      else if LEntity.InheritsFrom(TUdSpline) then
      begin
        LPoints := TUdSpline(LEntity).SamplePoints;
        LStr := 'Area = ' + Self.RealToStr(Area(LPoints))  + ' , ' +
                'Perimeter = ' + Self.RealToStr(Perimeter(LPoints));        
      end
      ;

      if (LStr = '') then
      begin
        Self.Prompt(sObjectHasNoArea, pkLog);
      end
      else begin
        Self.Prompt(LStr, pkLog);
        Self.Finish();
      end;
    end
    else
      Self.Prompt(sSelectObject, pkLog);
  end;
end;





//--------------------------------------------------------------------------

function TUdActionArea.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := False;

  LValue := LowerCase(Trim(AValue));

  if LValue = '' then
  begin
    if FPointMode then
      FinishAction()
    else
      Self.Finish();

    Exit; //=====>>>>>
  end;

  Result := True;
    
  if Step = 0 then
  begin
    if (LValue = 'o') or (LValue = 'obj') or (LValue = 'object') then
    begin
      Self.CanSnap    := False;
      Self.CanOSnap   := False;
      Self.CanPerpend := False;

      Self.SetCursorStyle(csPick);
      
      FPointMode := False;
      Self.Prompt(sSelectObject, pkCmd);
    end
    else begin
      FPointMode := True;

      if ParseCoord(AValue, LPnt, LIsOpp) then
        Self.SetFirstPoint(LPnt)
      else begin
        Self.Prompt(sInvalidPoint, pkLog);
        Result := False;
      end;
    end;
  end
  else begin
    if ParseCoord(AValue, LPnt, LIsOpp) then
    begin
      if FPointMode then
      begin
        if LIsOpp then
        begin
          LPnt.X := FLastPnt.X + LPnt.X;
          LPnt.Y := FLastPnt.Y + LPnt.Y;
        end;
        Self.SetNextPoint(LPnt);
      end
      else begin
        Self.PickAreaObject(LPnt);
      end;
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end;
end;




procedure TUdActionArea.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionArea.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if FPointMode then
        begin
          if (AButton = mbLeft) then
          begin
            if FStep = 0 then
            begin
              SetFirstPoint(ACoordPnt);
              Self.Invalidate;
            end
            else if FStep = 1 then
            begin
              SetNextPoint(ACoordPnt);
              Self.Invalidate;
            end;
          end
          else if (AButton = mbRight) then
            FinishAction();
        end
        else begin
          if (AButton = mbLeft) then
            Self.PickAreaObject(ACoordPnt)
          else if (AButton = mbRight) then
            Self.Finish();
        end;
      end;
    mkMouseMove:
      begin
        if FPointMode then
        begin
          FCurrPnt := ACoordPnt;

          if FStep = 1 then
          begin
            FLine.Visible := False;

            FLine.StartPoint := FLastPnt;
            FLine.EndPoint := ACoordPnt;
            FLine.Visible := True;
          end;
        end;
      end;
  end;

end;


end.