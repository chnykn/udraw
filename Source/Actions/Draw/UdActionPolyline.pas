{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionPolyline;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdArc, UdPolyline;

type
  //*** TUdActionPolyline ***//
  TUdActionPolyline = class(TUdDrawAction)
  private
    FArc: TUdArc;
    FLine: TUdLine;
    FPolyline: TUdPolyline;

    FLastPnt: TPoint2D;
    FCurrPnt: TPoint2D;

    FLastAng: Float;
    FIsArc: Boolean;

    FPrevAng: Float;

  protected
    function GetPrevAngle(): Float; override;
    
    function FAddPoint(APnt: TPoint2D): Boolean; overload;
    function FAddPoint(APnt: TPoint2D; var AIsArc: Boolean; var AArc: TArc2D): Boolean;  overload;

    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetNextPoint(APnt: TPoint2D): Boolean;
    function FinishAction(AClose: Boolean = False): Boolean;

    function CanClosed(): Boolean;

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
  UdLayout, UdMath, UdGeo2D, UdUtils, UdAcnConsts;


{ TUdActionPolyline }

class function TUdActionPolyline.CommandName: string;
begin
  Result := 'pline';
end;

constructor TUdActionPolyline.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FArc := TUdArc.Create(FDocument, False);
  FArc.Finished := False;
  FArc.Visible := False;
  FArc.Color.TrueColor := Self.GetDefColor();

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;
  FLine.Color.TrueColor := Self.GetDefColor();

  FPolyline := TUdPolyline.Create(FDocument, False);
  FPolyline.Closed := False;
  FPolyline.Finished := False;
  FPolyline.Visible := False;
  FPolyline.Color.TrueColor := Self.GetDefColor();

  FCurrPnt := Point2D(0, 0);
  FLastPnt := Point2D(0, 0);
  FLastAng := 0;
  FIsArc := False;

  FPrevAng := -1;

  Self.Prompt(sPolylineStartPnt, pkCmd);
end;

destructor TUdActionPolyline.Destroy;
begin
  if Assigned(FArc) then FArc.Free;
  if Assigned(FLine) then FLine.Free;

  if Assigned(FPolyline) and (System.Length(FPolyline.XData) > 0) then
  begin
    FPolyline.Visible := True;
    FPolyline.Finished := True;

    Self.Submit(FPolyline);
    FPolyline := nil;
  end;

  if Assigned(FPolyline) then FPolyline.Free;

  inherited;
end;




//-----------------------------------------------------------------------

procedure TUdActionPolyline.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

  if FVisible then
  begin
    if Assigned(FArc) and FArc.Visible then FArc.Draw(ACanvas);
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FPolyline) and FPolyline.Visible then FPolyline.Draw(ACanvas);
  end;
end;


function TUdActionPolyline.GetPrevAngle: Float;
begin
  Result := FLastAng;
end;



function TUdActionPolyline.CanClosed: Boolean;
begin
  Result := System.Length(FPolyline.Vertexes) >= 3;
  if not Result then
  begin
    if System.Length(FPolyline.Vertexes) >= 2 then
    begin
      Result := FIsArc or
                NotEqual(FPolyline.Vertexes[0].Bulge, 0.0) or
                NotEqual(FPolyline.Vertexes[1].Bulge, 0.0);
    end;
  end;
end;


function TUdActionPolyline.SetFirstPoint(APnt: TPoint2D): Boolean;
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
  Self.Prompt(sPolylineStartPnt + ': ' + PointToStr(APnt), pkLog);

  if FIsArc then
    Self.Prompt(sPolylineNextPntL, pkCmd)
  else
    Self.Prompt(sPolylineNextPntA, pkCmd);

  FStep := 1;
  Result := True;
end;



function TUdActionPolyline.FAddPoint(APnt: TPoint2D; var AIsArc: Boolean; var AArc: TArc2D): Boolean;
var
  LSegarc: TSegarc2D;
  LSegarcs: TSegarc2DArray;
begin
  Result := False;
  if not Assigned(FPolyline) then Exit;

  if System.Length(FPolyline.Vertexes) > 0 then
    if IsEqual(APnt, FPolyline.Vertexes[High(FPolyline.Vertexes)].Point) then Exit; //======>>>>

  AIsArc := False;

  if FIsArc then
  begin
    AArc := MakeArc(FLastPnt, APnt, FLastAng);
    AIsArc := AArc.R > 0;
  end;

  if AIsArc then
    LSegarc := Segarc2D(AArc)
  else
    LSegarc := Segarc2D(FLastPnt, APnt);

  LSegarcs := FPolyline.XData;
  System.SetLength(LSegarcs, System.Length(LSegarcs) + 1);
  LSegarcs[High(LSegarcs)] := LSegarc;

  FPolyline.XData := LSegarcs;

  Result := True;
end;

function TUdActionPolyline.FAddPoint(APnt: TPoint2D): Boolean;
var
  LArc: TArc2D;
  LIsArc: Boolean;
begin
  Result := Self.FAddPoint(APnt, LIsArc, LArc);
end;

function TUdActionPolyline.SetNextPoint(APnt: TPoint2D): Boolean;
var
  LArc: TArc2D;
  LIsArc: Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  LIsArc := False;
  if not FAddPoint(APnt, LIsArc, LArc) then Exit;

  FPolyline.Visible := True;

  if LIsArc then
  begin
    if LArc.IsCW then FLastAng := FixAngle(LArc.Ang1 - 90) else FLastAng := FixAngle(LArc.Ang2 + 90);
  end
  else
    FLastAng := GetAngle(FLastPnt, APnt);

  FPrevAng := FLastAng;

  FLastPnt := APnt;
  Self.SetPrevPoint(APnt);


  if FIsArc then
    Self.Prompt(sPolylineNextPntL + ': ' + PointToStr(APnt), pkLog)
  else
    Self.Prompt(sPolylineNextPntA + ': ' + PointToStr(APnt), pkLog);

  if Self.CanClosed() then
  begin
    if FIsArc then
      Self.Prompt(sPolylineNextPntL2, pkCmd)
    else
      Self.Prompt(sPolylineNextPntA2, pkCmd);
  end
  else begin
    if FIsArc then
      Self.Prompt(sPolylineNextPntL, pkCmd)
    else
      Self.Prompt(sPolylineNextPntA, pkCmd);
  end;

  Result := True;
  Self.Invalidate;
end;

function TUdActionPolyline.FinishAction(AClose: Boolean = False): Boolean;
var
  L: Integer;
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
    if AClose and Self.CanClosed() then
    begin
      FAddPoint(FPolyline.Vertexes[0].Point);
      FPolyline.Closed := AClose;
    end;

    FPolyline.Visible := True;
    FPolyline.Finished := True;

    Self.Submit(FPolyline);
    FPolyline := nil;
  end;

  Result := Finish();
end;






function TUdActionPolyline.Parse(const AValue: string): Boolean;
var
  D: DOuble;
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
  LSegarc: TSegarc2D;
  LVertexes: TVertexes2D;
  LReNextPrompt: Boolean;
begin
  Result := True;
  LValue := LowerCase(Trim(AValue));

  LReNextPrompt := False;

  if LValue = '' then
  begin
    FinishAction();
  end
  else if ((LValue = 'c') or (LValue = 'close')) and Self.CanClosed() then
  begin
    FinishAction(True);
  end
  else if (LValue = 'a') or (LValue = 'arc') then
  begin
    FIsArc := True;
    Self.Invalidate();
    LReNextPrompt := True;
  end
  else if (LValue = 'l') or (LValue = 'line') then
  begin
    FIsArc := False;
    Self.Invalidate();
    LReNextPrompt := True;
  end
  else if (LValue = 'u') or (LValue = 'undo') then
  begin
    LVertexes := FPolyline.Vertexes;

    if System.Length(LVertexes) > 1 then
    begin
      System.SetLength(LVertexes, System.Length(LVertexes) - 1);

      if System.Length(LVertexes) = 1 then
      begin
        FLastAng := 0;
        FLastPnt := LVertexes[0].Point;
        FIsArc := NotEqual(LVertexes[High(LVertexes)].Bulge, 0.0);
      end
      else begin
        LSegarc := Segarc2D(LVertexes[High(LVertexes)-1], LVertexes[High(LVertexes)]);

        FIsArc := LSegarc.IsArc;
        FLastPnt := LSegarc.Seg.P2;

        if LSegarc.IsArc then
        begin
          if LSegarc.Arc.IsCW then
            FLastAng := FixAngle(LSegarc.Arc.Ang1 - 90)
          else
            FLastAng := FixAngle(LSegarc.Arc.Ang2 + 90);
        end
        else
          FLastAng := GetAngle(LSegarc.Seg.P1, LSegarc.Seg.P2);
      end;

      FPolyline.Vertexes := LVertexes;
      Self.Invalidate();

      LReNextPrompt := True;
    end
    else
      Self.Prompt(sPolylineUndone, pkLog);
  end
  else if (FStep = 1) and (Pos(',', AValue) <= 0) and TryStrToFloat(AValue, D) then
  begin
    LPnt := ShiftPoint(FLastPnt, GetAngle(FLastPnt, FCurrPnt), D);
    SetNextPoint(LPnt);
  end
  else if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetFirstPoint(LPnt)
    else if FStep = 1 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FLastPnt.X + LPnt.X;
        LPnt.Y := FLastPnt.Y + LPnt.Y;
      end;
      SetNextPoint(LPnt);
    end;
  end
  else
  begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;

  if LReNextPrompt then
  begin
    if Self.CanClosed() then
    begin
      if FIsArc then
        Self.Prompt(sPolylineNextPntL2, pkCmd)
      else
        Self.Prompt(sPolylineNextPntA2, pkCmd);
    end
    else begin
      if FIsArc then
        Self.Prompt(sPolylineNextPntL, pkCmd)
      else
        Self.Prompt(sPolylineNextPntA, pkCmd);
    end;
  end;
end;


procedure TUdActionPolyline.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
end;


procedure TUdActionPolyline.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                                       ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LArc: TArc2D;
  LIsArc: Boolean;
begin
  inherited;

//  if (AEvent = ekKeyDown) and (AKey = 192) and (FStep = 0) then
//  begin
//    L := System.Length(FPolyline.XData);
//    if L <= 0 then
//    begin
//      Self.Finish();
//      Exit;
//    end
//    else begin
//      FinishAction(True);
//    end;
//  end;

  case AKind of
    mkMouseDown:
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
      end;
    mkMouseMove:
      begin
        FCurrPnt := ACoordPnt;

        if FStep = 1 then
        begin
          FArc.Visible := False;
          FLine.Visible := False;

          LIsArc := False;

          if FIsArc then
          begin
            LArc := MakeArc(FLastPnt, FCurrPnt, FLastAng);
            LIsArc := LArc.R > 0;
          end;

          if LIsArc then
          begin
            FArc.XData := LArc;
            FArc.Visible := True;
          end
          else begin
            FLine.StartPoint := FLastPnt;
            FLine.EndPoint := ACoordPnt;
            FLine.Visible := True;
          end;
        end;

      end;
  end;
end;




end.