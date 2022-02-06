{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionRect;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions;

type
  //*** TUdActionRect ***//
  TUdActionRect = class(TUdDrawAction)
  private
    FAction: TUdAction;

  protected
    
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
  UdLine, UdRect,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;




type
  //*** TUdActionRectBase ***//
  TUdActionRectBase = class(TUdDrawAction)
  private
    FRect: TUdRect;
    FOwnerAction: TUdAction;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

  end;


  //*** TUdActionRect2P ***//
  TUdActionRect2P = class(TUdActionRectBase)
  private
    FP1, FP2: TPoint2D;

  protected
    function UpdateEntities(): Boolean;

    function SetFirstCorner(APnt: TPoint2D): Boolean;
    function SetSecondCorner(APnt: TPoint2D): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;



  //*** TUdActionRect3P ***//
  TUdActionRect3P = class(TUdActionRectBase)
  private
    FP1, FP2, FP3: TPoint2D;
    FLine: TUdLine;

  protected
    function UpdateEntities(): Boolean;

    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetSecondPoint(APnt: TPoint2D): Boolean;
    function SetThirdPoint(APnt: TPoint2D): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionRectCenter ***//
  TUdActionRectCenter = class(TUdActionRectBase) //Center Size Angle
  private
    FP1, FP2, FP3: TPoint2D;
    FLine: TUdLine;

    FAngle: Float;

  protected
    function UpdateEntities(): Boolean;

    function SetCenter(APnt: TPoint2D): Boolean;
    function SetSize(APnt: TPoint2D): Boolean;
    function SetAngle(APnt: TPoint2D): Boolean; overload;
    function SetAngle(const AValue: Float): Boolean; overload;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;




  
//=========================================================================================
{ TUdActionRectBase }

constructor TUdActionRectBase.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FRect := TUdRect.Create(FDocument, False);
  FRect.Finished := False;
  FRect.Visible := False;
  FRect.Color.TrueColor := Self.GetDefColor();
end;

destructor TUdActionRectBase.Destroy;
begin
  if Assigned(FRect) then FRect.Free;
  inherited;
end;





//=========================================================================================
{ TUdActionRect2P }

constructor TUdActionRect2P.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.Prompt(sFirstCornerOrKeyword, pkCmd);
  Self.CanOrtho := False;
end;

destructor TUdActionRect2P.Destroy;
begin
  inherited;
end;



//---------------------------------------------------

procedure TUdActionRect2P.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if FVisible then
    if Assigned(FRect) and FRect.Visible then FRect.Draw(ACanvas);
end;




//---------------------------------------------------

function TUdActionRect2P.SetFirstCorner(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FStep := 1;
  FP1 := APnt;
  FP2 := APnt;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstCornerOrKeyword + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sSecondCorner, pkCmd);

  Result := True;
end;

function TUdActionRect2P.SetSecondCorner(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  if NotEqual(FP1, APnt) then
  begin
    FP2 := APnt;
    UpdateEntities();
    FRect.Finished := True;
    Self.Submit(FRect);

    Self.SetPrevPoint(APnt);
    Self.Prompt(sSecondCorner + ': ' + PointToStr(APnt), pkLog);

    FRect := nil;
    Result := Finish();
  end;
end;



//---------------------------------------------------

function TUdActionRect2P.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  Result := True;
  if Trim(AValue) = '' then Exit;

  if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetFirstCorner(LPnt)
    else if FStep = 1 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP1.X + LPnt.X;
        LPnt.Y := FP1.Y + LPnt.Y;
      end;
      SetSecondCorner(LPnt);
    end;
  end
  else
  begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


function TUdActionRect2P.UpdateEntities(): Boolean;
var
  LRect: TRect2D;
begin
  Result := False;
  if IsEqual(FP1, FP2) then Exit;
  
  LRect := UdGeo2D.Rect2D(FP1, FP2);

  FRect.Center := MidPoint(FP1, FP2);
  FRect.Width  := Abs(FP2.X - FP1.X);
  FRect.Height := Abs(FP2.Y - FP1.Y);
  FRect.Visible := True;

  Result := True;
end;


procedure TUdActionRect2P.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;
  
end;

procedure TUdActionRect2P.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                                   ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetFirstCorner(ACoordPnt)
          else if FStep = 1 then
            SetSecondCorner(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          FP2 := ACoordPnt;
          UpdateEntities();
        end;
      end;
  end;

end;




//=========================================================================================
{ TUdActionRect3P }

constructor TUdActionRect3P.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;
  FLine.Color.TrueColor := Self.GetDefColor();

  Self.Prompt(sFirstCorner, pkCmd);
end;

destructor TUdActionRect3P.Destroy;
begin
  if Assigned(FLine) then FLine.Free;
  inherited;
end;



//---------------------------------------------------

procedure TUdActionRect3P.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FRect) and FRect.Visible then FRect.Draw(ACanvas);
  end;
end;




//---------------------------------------------------

function TUdActionRect3P.SetFirstPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sFirstCorner + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionRect3P.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  if NotEqual(FP1, APnt) then
  begin
    FP2 := APnt;

    Self.SetPrevPoint(APnt);
    Self.Prompt(sThirdPoint + ': ' + PointToStr(APnt), pkLog);
    Self.Prompt(sThirdPoint, pkCmd);

    FStep := 2;
    Result := True;
  end;
end;


function TUdActionRect3P.SetThirdPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  if DistanceToLine(APnt, Line2D(FP1, FP2)) > 0 then
  begin
    FP3 := APnt;

    Self.SetPrevPoint(APnt);
    Self.Prompt(sThirdPoint + ': ' + PointToStr(APnt), pkLog);


    if UpdateEntities() then
    begin
      FRect.Finished := True;
      Self.Submit(FRect);
    end
    else
      FRect.Free;

    FRect := nil;
    Result := Finish();
  end;
end;


//---------------------------------------------------

function TUdActionRect3P.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  Result := True;
  if Trim(AValue) = '' then Exit;

  if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetFirstPoint(LPnt)
    else if FStep = 1 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP1.X + LPnt.X;
        LPnt.Y := FP1.Y + LPnt.Y;
      end;
      SetSecondPoint(LPnt);
    end
    else if FStep = 2 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP1.X + LPnt.X;
        LPnt.Y := FP1.Y + LPnt.Y;
      end;
      SetThirdPoint(LPnt);
    end;
  end
  else
  begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


function TUdActionRect3P.UpdateEntities(): Boolean;
var
  LCen: TPoint2D;
  LAng, LWidth, LHeight: Float;
begin
  LAng := GetAngle(FP1, FP2);
  LCen := MidPoint(FP1, FP2);

  LWidth := Distance(FP1, FP2);
  LHeight := DistanceToLine(FP3, Line2D(FP1, FP2));
  
  if UdGeo2D.IsPntOnLeftSide(FP3, FP1, FP2) then
    LCen := ShiftPoint(LCen, LAng+90, LHeight/2)
  else
    LCen := ShiftPoint(LCen, LAng-90, LHeight/2);

  FRect.Center := LCen;
  FRect.Rotation := LAng;
  FRect.Width  := LWidth;
  FRect.Height := LHeight;
  FRect.Visible := True;

  Result := True;
end;


procedure TUdActionRect3P.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;
  
end;

procedure TUdActionRect3P.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                                   ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetFirstPoint(ACoordPnt)
          else if FStep = 1 then
            SetSecondPoint(ACoordPnt)
          else if FStep = 2 then
            SetThirdPoint(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          FP2 := ACoordPnt;
          FLine.StartPoint := FP1;
          FLine.EndPoint := FP2;
          FLine.Visible := True;
        end
        else if FStep = 2 then
        begin
          FP3 := ACoordPnt;
          FLine.Visible := False;
          UpdateEntities();
        end;
      end;
  end;

end;








//=========================================================================================
{ TUdActionRectCenter }

constructor TUdActionRectCenter.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;
  FLine.Color.TrueColor := Self.GetDefColor();

  FAngle := 0;
  Self.Prompt(sCenterPoint, pkCmd);
end;

destructor TUdActionRectCenter.Destroy;
begin
  if Assigned(FLine) then FLine.Free;
  inherited;
end;



//---------------------------------------------------

procedure TUdActionRectCenter.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;

  if FVisible then
  begin
    if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
    if Assigned(FRect) and FRect.Visible then FRect.Draw(ACanvas);
  end;
end;




//---------------------------------------------------

function TUdActionRectCenter.SetCenter(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;

  Self.CanOrtho := False;
  
  Self.SetPrevPoint(APnt);
  Self.Prompt(sCenterPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sSpecifySize, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionRectCenter.SetSize(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  if NotEqual(FP1, APnt) then
  begin
    FP2 := APnt;

    Self.SetPrevPoint(APnt);
    Self.Prompt(sSpecifySize + ': ' + PointToStr(APnt), pkLog);
    Self.Prompt(sRotationAngle, pkCmd);

    FStep := 2;

    Self.SetPrevPoint(FP1);
    if Assigned(FOwnerAction) then FOwnerAction.CanOrtho := True;
    Result := True;
  end;
end;


function TUdActionRectCenter.SetAngle(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  if NotEqual(FP1, APnt) then
  begin
    FP3 := APnt;
    FAngle := GetAngle(FP1, FP3);

    Self.SetPrevPoint(APnt);
    Self.Prompt(sRotationAngle + ': ' + PointToStr(APnt), pkLog);

    if UpdateEntities() then
    begin
      FRect.Finished := True;
      Self.Submit(FRect);
    end
    else
      FRect.Free;

    FRect := nil;
    Result := Finish();
  end;
end;

function TUdActionRectCenter.SetAngle(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FAngle := AValue;
  Self.Prompt(sRotationAngle + ': ' + AngleToStr(AValue), pkLog);


  if UpdateEntities() then
  begin
    FRect.Finished := True;
    Self.Submit(FRect);
  end
  else
    FRect.Free;

  FRect := nil;
  Result := Finish();
end;




//---------------------------------------------------

function TUdActionRectCenter.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  Result := True;
  if Trim(AValue) = '' then Exit;

  if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetCenter(LPnt)
    else if FStep = 1 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP1.X + LPnt.X;
        LPnt.Y := FP1.Y + LPnt.Y;
      end;
      SetSize(LPnt);
    end
    else if FStep = 2 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP1.X + LPnt.X;
        LPnt.Y := FP1.Y + LPnt.Y;
      end;
      SetAngle(LPnt);
    end;
  end
  else if IsNum(AValue) then
  begin
    if FStep = 2 then
      SetAngle(StrToAngle(AValue));
  end
  else begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


function TUdActionRectCenter.UpdateEntities(): Boolean;
var
  LCen: TPoint2D;
  LWidth, LHeight: Float;
begin
  LCen := FP1;

  LWidth := Abs(FP2.X - FP1.X) * 2;
  LHeight := Abs(FP2.Y - FP1.Y) * 2;

  FRect.Center := LCen;
  FRect.Rotation := FAngle;
  FRect.Width  := LWidth;
  FRect.Height := LHeight;
  FRect.Visible := True;
  FRect.Refresh();

  Result := True;
end;


procedure TUdActionRectCenter.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;
  
end;

procedure TUdActionRectCenter.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                                   ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetCenter(ACoordPnt)
          else if FStep = 1 then
            SetSize(ACoordPnt)
          else if FStep = 2 then
            SetAngle(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        if FStep = 1 then
        begin
          FP2 := ACoordPnt;
          FLine.StartPoint := FP1;
          FLine.EndPoint := FP2;
          FLine.Visible := True;
          FLine.Refresh();
          UpdateEntities();
        end
        else if FStep = 2 then
        begin
          FP3 := ACoordPnt;
          FAngle := GetAngle(FP1, FP3);
          
          FLine.StartPoint := FP1;
          FLine.EndPoint := FP3;
          FLine.Visible := True;
          FLine.Refresh();
          UpdateEntities();
        end;
      end;
  end;

end;







//========================================================================================
{ TUdActionRect }

class function TUdActionRect.CommandName: string;
begin
  Result := 'rect';
end;

constructor TUdActionRect.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  N: Integer;
  LArg: string;
begin
  inherited;

  LArg := LowerCase(Trim(Args));
  
  N := Pos(' ', LArg);
  if N > 0 then Delete(LArg, N, System.Length(LArg));

  FAction := nil;
  Self.CanOrtho := False;

  if LArg = '' then
  begin
    FAction := TUdActionRect2P.Create(ADocument, FLayout, '');
    TUdActionRectBase(FAction).FOwnerAction := Self;
  end
  else if LArg = '3p' then
  begin
    Self.CanOrtho := True;
    FAction := TUdActionRect3P.Create(ADocument, FLayout, '');
    TUdActionRectBase(FAction).FOwnerAction := Self;
  end
  else if (LArg = 'c') or (LArg = 'cen') or (LArg = 'center') then
  begin
    FAction := TUdActionRectCenter.Create(ADocument, FLayout, '');// else
    TUdActionRectBase(FAction).FOwnerAction := Self;
  end;
end;

destructor TUdActionRect.Destroy;
begin
  if Assigned(FAction) then FAction.Free;
  inherited;
end;


procedure TUdActionRect.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FAction) then FAction.Paint(Sender, ACanvas);
end;

function TUdActionRect.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := False;
  if not Assigned(FAction) then Exit; //=====>>>>

  if (FAction.Step = 0) then
  begin
    if FAction.InheritsFrom(TUdActionRect2P) then
    begin
      LValue := LowerCase(Trim(AValue));

      if LValue = '3p' then
      begin
        if Assigned(FAction) then FAction.Free;
        Self.CanOrtho := True;
        FAction := TUdActionRect3P.Create(FDocument, FLayout, '');
        TUdActionRectBase(FAction).FOwnerAction := Self;
      end
      else
      if (LValue = 'c') or (LValue = 'cen') or (LValue = 'center') then
      begin
        if Assigned(FAction) then FAction.Free;
        FAction := TUdActionRectCenter.Create(FDocument, FLayout, '');// else
        TUdActionRectBase(FAction).FOwnerAction := Self;
      end
      else
      if ParseCoord(LValue, LPnt, LIsOpp) then
      begin
        TUdActionRect2P(FAction).SetFirstCorner(LPnt);
      end
      else
        Self.Prompt(sRequirePointOrKeyword, pkLog);
        
      Result := True;
    end
    else
      Result := FAction.Parse(AValue);
  end
  else
    Result := FAction.Parse(AValue);
end;


procedure TUdActionRect.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FAction) then FAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionRect.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;
  if Assigned(FAction) then FAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
end;




end.