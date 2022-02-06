{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionZoom;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls, Types,
  UdTypes, UdGTypes, UdConsts, UdEvents, UdObject,
  UdEntity, UdAction, UdBaseActions;


type
  TUdZoomKind = (zkNone, zkAll, zkCenter, zkExtents, zkPrev, zkScale, zkWindow, zkRealTime, zkObject);

  //*** TUdActionZoom ***//
  TUdActionZoom = class(TUdViewAction)
  private
    FAction: TUdAction;

  protected
    function ParseAction(const AValue: string): Boolean;

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
  UdLayout, UdActionSelection, UdLine, UdRect,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;


type
  //*** TUdActionZoomScale ***//
  TUdActionZoomScale = class(TUdViewAction)
  private
    FLine: TUdLine;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function Parse(const AValue: string): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionZoomCenter ***//
  TUdActionZoomCenter = class(TUdViewAction)
  private

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function Parse(const AValue: string): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionPanReal ***//
  TUdActionZoomWindow = class(TUdViewAction)
  private
    FP1, FP2: TPoint2D;
    FRectEntity: TUdRect;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionZoomReal ***//
  TUdActionZoomReal = class(TUdViewAction)
  private
    FScale: Double;
    FY1, FY2: Integer;
    FOldGridOn: Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function Parse(const AValue: string): Boolean; override;

    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionZoomObject ***//
  TUdActionZoomObject = class(TUdViewAction)
  private
    FSelAction: TUdActionSelection;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;





//--------------------------------------------------------------------------------------------------
{ TUdActionZoomCenter }

constructor TUdActionZoomCenter.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.Prompt(sCenterPoint, pkCmd);
end;

destructor TUdActionZoomCenter.Destroy;
begin

  inherited;
end;

procedure TUdActionZoomCenter.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

end;

function TUdActionZoomCenter.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LLayout: TUdLayout;
begin
  Result := False;

  if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    LLayout := TUdLayout(Self.GetLayout());
    if Assigned(LLayout) then LLayout.ZoomCenter(LPnt);
    Self.Finish();
  end
  else
    Self.Prompt(sInvalidPoint, pkLog);
end;

procedure TUdActionZoomCenter.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        LLayout := TUdLayout(Self.GetLayout());
        if Assigned(LLayout) then LLayout.ZoomCenter(ACoordPnt);
        Self.Finish();
      end;
  end;
end;




//--------------------------------------------------------------------------------------------------
{ TUdActionZoomScale }

constructor TUdActionZoomScale.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  Self.Prompt(sScaleFactor, pkCmd);
end;

destructor TUdActionZoomScale.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  inherited;
end;

procedure TUdActionZoomScale.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
end;

function TUdActionZoomScale.Parse(const AValue: string): Boolean;
var
  N: Integer;
  LValue: string;
  LScale: Float;
  LLayout: TUdLayout;
begin
  Result := False;
  LLayout := TUdLayout(Self.GetLayout());

  if not Assigned(LLayout) then Exit;

  LValue := LowerCase(Trim(AValue));

  N := Pos('xp', LValue);
  if N <= 0 then N := Pos('x', LValue);
  if N > 0 then Delete(LValue, N, System.Length(LValue));

  if IsNum(LValue) then
  begin
    LScale := StrToFloat(LValue);
    if NotEqual(LScale, 0.0) and (LScale > 0) then
    begin
      if N > 0 then LScale := LLayout.Axes.Scale * LScale else LScale := LScale * 100;
      LLayout.ZoomScale(LScale);

      Result := Self.Finish();
    end;
  end;
end;


procedure TUdActionZoomScale.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
          begin
            FLine.StartPoint := ACoordPnt;
            FLine.EndPoint := ACoordPnt;
            FLine.Visible := True;

            FStep := 1;

            Self.Prompt(sFirstPoint + ':' + PointToStr(ACoordPnt), pkLog);
            Self.Prompt(sSecondPoint, pkCmd);
          end
          else if FStep = 1 then
          begin
            FLine.EndPoint := ACoordPnt;

            LLayout := TUdLayout(Self.GetLayout());
            if Assigned(LLayout) then
              LLayout.ZoomScale(Distance(FLine.StartPoint, FLine.EndPoint)*100);

            FLine.Visible := False;

            Self.Prompt(sSecondPoint + ':' + PointToStr(ACoordPnt), pkLog);
            Self.Finish();
          end;
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          FLine.EndPoint := ACoordPnt;
        end;
      end;
  end;
end;




//--------------------------------------------------------------------------------------------------
{ TUdActionZoomWindow }

constructor TUdActionZoomWindow.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FRectEntity := TUdRect.Create(FDocument, False);
  FRectEntity.Finished := False;
  FRectEntity.Visible := False;
  FRectEntity.Color.TrueColor := Self.GetDefColor();
  FRectEntity.UsePenStyle := True;

  Self.SetCursorStyle(csDraw);
  Self.Prompt(sFirstCorner, pkCmd);
end;

destructor TUdActionZoomWindow.Destroy;
begin
  if Assigned(FRectEntity) then FRectEntity.Free();
  inherited;
end;


procedure TUdActionZoomWindow.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FRectEntity) and FRectEntity.Visible then
    FRectEntity.Draw(ACanvas);
end;

procedure TUdActionZoomWindow.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LLayout: TUdLayout;
begin
  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=====>>>

  case AKind of
    mkMouseDown:
      begin
        if AButton = mbLeft then
        begin
          if FStep = 0 then
          begin
            FP1 := ACoordPnt;
            FStep := 1;

            Self.Prompt(sFirstCorner + ': ' + PointToStr(ACoordPnt), pkLog);
            Self.Prompt(sSecondCorner, pkCmd);
          end
          else if FStep = 1 then
          begin
            FRectEntity.Visible := False;

            FP2 := ACoordPnt;
            Self.Prompt(sSecondCorner + ': ' + PointToStr(ACoordPnt), pkLog);

            LLayout.ZoomWindow(RectHull(FP1, FP2), True);

            Self.Finish();
          end;
        end;
      end;

    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          FP2 := ACoordPnt;
          FRectEntity.SetRect(RectHull(FP1, FP2));

          FRectEntity.Visible := True;
        end;
      end;
  end;

end;





//--------------------------------------------------------------------------------------------------
{ TUdActionZoomReal }

constructor TUdActionZoomReal.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.SetCursorStyle(csZoom);
  Self.Prompt(sEscOrEnterToExit, pkLog);
  Self.Prompt('', pkCmd);
end;

destructor TUdActionZoomReal.Destroy;
begin

  inherited;
end;

function TUdActionZoomReal.Parse(const AValue: string): Boolean;
begin
  Result := True;
  if Trim(AValue) = '' then Self.Finish();
end;


procedure TUdActionZoomReal.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LScale: Double;
  LLayout: TUdLayout;
begin
  inherited;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit; //=====>>>

  case AKind of
    mkMouseDown:
      begin
        if AButton = mbLeft then
        begin
          if FStep = 0 then
          begin
            FOldGridOn := LLayout.Drafting.GridOn;

            FStep := 1;
            FY1 := AScreenPnt.Y;
            FY2 := AScreenPnt.Y;
            FScale := LLayout.Axes.Scale;
          end;
        end
        else
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if (FStep = 1) and (ssLeft in AShift) then
        begin
          FY2 := AScreenPnt.Y;

          LLayout.Drafting.GridOn := False;

          LScale := FScale * (1 + ((FY1 - FY2) / LLayout.Axes.YSize) * 2);

          if (LScale <= ZOOM_LEVLE_ARRAY[High(ZOOM_LEVLE_ARRAY)]) and
             (LScale >= ZOOM_LEVLE_ARRAY[Low(ZOOM_LEVLE_ARRAY)]) then
            LLayout.ZoomScale(LScale);
         end;
      end;
    mkMouseUp:
      begin
        if AButton = mbLeft then
        begin
          FStep := 0;
          LLayout.Drafting.GridOn := FOldGridOn;
        end;
      end;
  end;

end;




//--------------------------------------------------------------------------------------------------
{ TUdActionZoomObject }

constructor TUdActionZoomObject.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  LRect: TRect2D;
  LLayout: TUdLayout;
begin
  inherited;

  FSelAction := nil;
  LLayout := TUdLayout(Self.GetLayout());

  if Assigned(LLayout) then
  begin
    if LLayout.SelectedList.Count > 0 then
    begin
      LRect := UdUtils.GetEntitiesBound(LLayout.SelectedList, True);
      LLayout.ZoomWindow(LRect, True);
      LLayout.RemoveAllSelected();

      Self.Finish();
    end
    else begin
      FSelAction := TUdActionSelection.Create(FDocument, ALayout);

      Self.SetCursorStyle(csPick);
      Self.Prompt(sSelectObject, pkLog);
    end;
  end;
end;

destructor TUdActionZoomObject.Destroy;
begin
  if Assigned(FSelAction) then FSelAction.Free;
  FSelAction := nil;

  inherited;
end;

procedure TUdActionZoomObject.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  FSelAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionZoomObject.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FSelAction) and FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
end;

procedure TUdActionZoomObject.MouseEvent(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
var
  LRect: TRect2D;
  LLayout: TUdLayout;
begin
  inherited;

  LLayout := TUdLayout(Self.GetLayout());
  if not Assigned(LLayout) then Exit;

  if (AKind = mkMouseDown) and (AButton = mbRight) then
  begin
    FSelAction.Visible := False;
    LRect := GetEntitiesBound(LLayout.SelectedList, True);

    LLayout.Axes.ZoomWindow(LRect, True);
    LLayout.RemoveAllSelected();

    Self.Finish();
  end
  else begin
    FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
  end;
end;





//==========================================================================================



function GetZoomKind(const AValue: string): TUdZoomKind;
var
  LValue: string;
begin
  Result := zkNone;

  LValue := LowerCase(Trim(AValue));
  if LValue = '' then Exit;

  if (LValue = 'a') or (Pos('all', LValue) > 0)   then Result  := zkAll     else
  if (LValue = 'c') or (Pos('cen', LValue) > 0)   then Result  := zkCenter  else
  if (LValue = 'e') or (Pos('ext', LValue) > 0)   then Result  := zkExtents else
  if (LValue = 'p') or (Pos('prev', LValue) > 0)  then Result  := zkPrev    else
  if (LValue = 's') or (Pos('scale', LValue) > 0) then Result  := zkScale   else
  if (LValue = 'w') or (Pos('win', LValue) > 0)   then Result  := zkWindow  else
  if (LValue = 'r') or (Pos('real', LValue) > 0)  then Result  := zkRealTime  else
  if (LValue = 'o') or (Pos('obj', LValue) > 0)   then Result  := zkObject  ;
end;





{ TUdActionZoom }

class function TUdActionZoom.CommandName: string;
begin
  Result := 'zoom';
end;

constructor TUdActionZoom.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  N: Integer;
  LArg: string;
begin
  inherited;

  LArg := Trim(Args);

  N := Pos(' ', LArg);
  if N > 0 then Delete(LArg, N, System.Length(LArg));

  FAction := nil;

  Self.SetCursorStyle(csDraw);

  if LArg = '' then
  begin
    Self.Prompt(sZoomCmd1, pkLog);
    Self.Prompt(sZoomCmd2, pkCmd);
  end
  else begin
    ParseAction(LArg);
  end;
end;

destructor TUdActionZoom.Destroy;
begin
  if Assigned(FAction) then FAction.Free;
  inherited;
end;


function TUdActionZoom.ParseAction(const AValue: string): Boolean;
var
  N: Integer;
  LScale: Float;
  LStr: string;
  LValue: string;
  LKind: TUdZoomKind;
  LLayout: TUdLayout;
begin
  Result := False;

  LLayout := TUdLayout(GetLayout());
  if not Assigned(LLayout) then
  begin
    FAborted := True;
    Exit; //====>>>>
  end;

  Self.Prompt(sZoomCmd1, pkLog);
  Self.Prompt(sZoomCmd2 + ':' + AValue, pkLog);

  LValue := LowerCase(Trim(AValue));
  LKind := GetZoomKind(LValue);

  if LKind = zkNone then
  begin
    LStr := '';

    N := Pos('xp', LValue);
    if N <= 0 then N := Pos('x', LValue);
    if N > 0 then Delete(LValue, N, System.Length(LValue));

    if IsNum(LValue) then
    begin
      LScale := StrToFloat(LValue);
      if IsEqual(LScale, 0.0) then LStr := 'Value must be positive and nonzero.' else
      if LScale > 0 then
      begin
        if N > 0 then LScale := LLayout.Axes.Scale * LScale else LScale := LScale * 100;
        LLayout.ZoomScale(LScale);

        Self.FAborted := True;
        Result := True;

        Exit; //=========>>>>>
      end;
    end;

    if LStr = '' then LStr := 'Requires a distance, numberX, or option keyword.';

    Self.Prompt(LStr, pkLog);
  end
  else begin
    case LKind of
      zkScale   : FAction := TUdActionZoomScale.Create(FDocument, FLayout, '');
      zkCenter  : FAction := TUdActionZoomCenter.Create(FDocument, FLayout, '');
      zkWindow  : FAction := TUdActionZoomWindow.Create(FDocument, FLayout, '');
      zkRealTime: FAction := TUdActionZoomReal.Create(FDocument, FLayout, '');
      zkObject  : FAction := TUdActionZoomObject.Create(FDocument, FLayout, '');

      zkAll     : begin LLayout.ZoomAll(); Self.FAborted := True; end;
      zkExtents : begin LLayout.ZoomExtends(); Self.FAborted := True; end;
      zkPrev    : begin LLayout.ZoomPrevious(); Self.FAborted := True; end;
    end;
  end;
end;


procedure TUdActionZoom.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FAction) then FAction.Paint(Sender, ACanvas);
end;

function TUdActionZoom.Parse(const AValue: string): Boolean;
begin
  Result := False;

  if FAction = nil then
  begin
    if Trim(AValue) = '' then
    begin
      FAction := TUdActionZoomReal.Create(FDocument, FLayout, '');
    end
    else begin
      Result := ParseAction(AValue);
      if FAborted then Self.Finish();
    end;
  end
  else
    Result := FAction.Parse(AValue);
end;


procedure TUdActionZoom.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FAction) then FAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionZoom.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  if not Assigned(FAction) and (AKind = mkMouseDown) and (AButton = mbLeft) then
    FAction := TUdActionZoomWindow.Create(FDocument, FLayout);

  if Assigned(FAction) then FAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
end;






end.