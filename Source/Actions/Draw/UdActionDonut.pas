{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionDonut;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdPolyline;

type
  //*** TUdActionDonut ***//
  TUdActionDonut = class(TUdDrawAction)
  private
    FLine: TUdLine;
    FDonut: TUdPolyline;
    FCurPnt: TPoint2D;

    FDia1, FDia2: Float;
    
  protected
    function SetInsideDiaPoint1(APnt: TPoint2D): Boolean;    // 0
    function SetInsideDiaPoint2(APnt: TPoint2D): Boolean;    // 1

    function SetOutsideDiaPoint1(APnt: TPoint2D): Boolean;   // 2
    function SetOutsideDiaPoint2(APnt: TPoint2D): Boolean;   // 3

    function FSetCenterPoint(APnt: TPoint2D): Boolean;       // 4
    function SetCenterPoint(APnt: TPoint2D): Boolean;        // 4

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    class function CommandName(): string; override;
    
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;  

implementation


uses
  SysUtils,
  UdGeo2D, UdUtils, UdAcnConsts;

var
  GInsideDia: Float = 0.5;
  GOutsideDia: Float = 1.0;
  

//=========================================================================================
{ TUdActionDonut }

class function TUdActionDonut.CommandName: string;
begin
  Result := 'donut';
end;

constructor TUdActionDonut.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FDonut := TUdPolyline.Create(FDocument, False);
  FDonut.Finished := False;
  FDonut.Visible := False;

  Self.Prompt(sDonutInsideDia + '<' + RealToStr(GInsideDia) + '>', pkCmd);
end;

destructor TUdActionDonut.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FDonut) then FDonut.Free();
  inherited;
end;


//---------------------------------------------------

procedure TUdActionDonut.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FDonut) and FDonut.Visible then FDonut.Draw(ACanvas);
  end;
end;



//---------------------------------------------------

function TUdActionDonut.SetInsideDiaPoint1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionDonut.SetInsideDiaPoint2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FLine.EndPoint := APnt;
  FLine.Visible := False;

  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);

  FDia1 := Distance(FLine.StartPoint, FLine.EndPoint);
  GInsideDia := FDia1;

  FStep := 2;
  Self.Prompt(sDonutInsideDia + '<' + RealToStr(FDia1) + '>', pkLog);
  Self.Prompt(sDonutOutsideDia + '<' + RealToStr(GOutsideDia) + '>', pkCmd);

  Result := True;  
end;

function TUdActionDonut.SetOutsideDiaPoint1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FLine.StartPoint := APnt;
  FLine.EndPoint := APnt;
  FLine.Visible := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstPoint + ': ' + PointToStr(APnt), pkLog);

  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 3;
  Result := True;
end;

function TUdActionDonut.SetOutsideDiaPoint2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FLine.EndPoint := APnt;
  FLine.Visible := False;

  Self.Prompt(sSecondPoint + ': ' + PointToStr(APnt), pkLog);

  FDia2 := Distance(FLine.StartPoint, FLine.EndPoint);
  GOutsideDia := FDia2;

  FSetCenterPoint(APnt);

  FStep := 4;
  Self.Prompt(sDonutOutsideDia + '<' + RealToStr(FDia2) + '>', pkLog);
  Self.Prompt(sDonutCenterPnt, pkCmd);

  Result := True;  
end;



function TUdActionDonut.FSetCenterPoint(APnt: TPoint2D): Boolean;
var
  LRad, LWid: Float;
  LP1, LP2: TPoint2D;
begin
  Result := False;
  if not Assigned(FDonut) then Exit;

  LRad := (FDia1 + FDia2) / 4;
  LWid := Abs(FDia2 - FDia1) /2;

  LP1 := ShiftPoint(APnt, 180.0, LRad);
  LP2 := ShiftPoint(APnt, 0.0, LRad);

  FDonut.BeginUpdate();
  try
    FDonut.Vertexes := nil;
    FDonut.AddVertex(Vertex2D(LP1, 1),  LWid);
    FDonut.AddVertex(Vertex2D(LP2, 1),  LWid);
    FDonut.Closed := True;
    FDonut.Visible := True;
  finally
    FDonut.EndUpdate();
  end;

  Result := True;
end;

function TUdActionDonut.SetCenterPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 4 then Exit;

  FSetCenterPoint(APnt);

  FDonut.Finished := True;
  Self.Submit(FDonut);

  FDonut := TUdPolyline.Create(FDocument, False);
  FDonut.Finished := False;
  FDonut.Visible := False;

  Result := True;
end;



//---------------------------------------------------

function TUdActionDonut.Parse(const AValue: string): Boolean;
var
  D: Double;
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));

  if LValue = '' then
  begin
    if FStep in [0, 1] then
    begin
      FDia1 := GInsideDia;
      FLine.Visible := False;
      FStep := 2;

      Self.Prompt(sDonutInsideDia + '<' + RealToStr(FDia1) + '>', pkLog);
      Self.Prompt(sDonutOutsideDia + '<' + RealToStr(GOutsideDia) + '>', pkCmd);
    end else
    if FStep in [2, 3] then
    begin
      FDia2 := GOutsideDia;
      FLine.Visible := False;
      FStep := 4;

      Self.Prompt(sDonutOutsideDia + '<' + RealToStr(FDia2) + '>', pkLog);
      Self.Prompt(sDonutCenterPnt, pkCmd);
    end
    else begin
      Self.Finish();
    end;

    Exit; //=========>>>>>>
  end;

  if FStep in [0, 2] then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      if FStep = 0 then
      begin
        FDia1 := Abs(D);
        GInsideDia := FDia1;
        FStep := 2;

        Self.Prompt(sDonutInsideDia + '<' + RealToStr(FDia1) + '>', pkLog);
        Self.Prompt(sDonutOutsideDia + '<' + RealToStr(GOutsideDia) + '>', pkCmd);
      end
      else begin
        FDia2 := Abs(D);
        GOutsideDia := FDia2;
        FStep := 4;
        FSetCenterPoint(FCurPnt);

        Self.Prompt(sDonutOutsideDia + '<' + RealToStr(FDia2) + '>', pkLog);
        Self.Prompt(sDonutCenterPnt, pkCmd);
      end;
    end
    else if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if FStep = 0 then
        SetInsideDiaPoint1(LPnt)
      else
        SetOutsideDiaPoint1(LPnt);
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end else
  if FStep in [1, 3] then
  begin
    if TryStrToFloat(LValue, D) then
    begin
      LPnt := ShiftPoint(FLine.StartPoint, GetAngle(FLine.StartPoint, FCurPnt), D);
      if FStep = 1 then
        SetInsideDiaPoint2(LPnt)
      else
        SetOutsideDiaPoint2(LPnt);
    end
    else if ParseCoord(LValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FLine.StartPoint.X + LPnt.X;
        LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
      end;
      if FStep = 1 then
        SetInsideDiaPoint2(LPnt)
      else
        SetOutsideDiaPoint2(LPnt);
    end
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end
  else if FStep = 4 then
  begin
    if ParseCoord(LValue, LPnt, LIsOpp) then
      SetCenterPoint(LPnt)
    else begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end;

end;





procedure TUdActionDonut.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;

procedure TUdActionDonut.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetInsideDiaPoint1(ACoordPnt)
          else if FStep = 1 then
            SetInsideDiaPoint2(ACoordPnt)
          else if FStep = 2 then
            SetOutsideDiaPoint1(ACoordPnt)
          else if FStep = 3 then
            SetOutsideDiaPoint2(ACoordPnt)
          else if FStep = 4 then
            SetCenterPoint(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        FCurPnt := ACoordPnt;
        if FStep in [1, 3] then
        begin
          FLine.EndPoint := ACoordPnt;
        end
        else if FStep = 4 then
        begin
          FSetCenterPoint(ACoordPnt);
        end;
      end;
  end;
end;





end.