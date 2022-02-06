{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionArc;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions;

type

  //*** TUdActionArc ***//
  TUdActionArc = class(TUdDrawAction)
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
  UdLine, UdArc,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;


type

  //*** TUdActionArcBase ***//
  TUdActionArcBase = class(TUdDrawAction)
  private
    FArc: TUdArc;
    FLine: TUdLine;
    FLine2: TUdLine;
  protected

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
  end;

  //*** TUdActionArc3P ***//
  TUdActionArc3P = class(TUdActionArcBase)
  private
    FP1, FP2, FP3: TPoint2D;

  protected
    function UpdateEntities(): Boolean;

    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetSecondPoint(APnt: TPoint2D): Boolean;
    function SetThirdPoint(APnt: TPoint2D): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;

    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionArcCS ***//
  TUdActionArcCS = class(TUdActionArcBase) //Center Start ...
  private
    FCenPnt, FStartPnt, FEndPnt: TPoint2D;

  protected
    function UpdateEntities(): Boolean; virtual;

    function SetCenter(APnt: TPoint2D): Boolean;
    function SetStartPoint(APnt: TPoint2D): Boolean;
    function SetEndPoint(APnt: TPoint2D): Boolean; overload;
    function SetEndPoint(const AValue: Float): Boolean; overload;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;

    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;

  //*** TUdActionArcCSE ***//
  TUdActionArcCSE = class(TUdActionArcCS) //Center Start End
  protected
    function UpdateEntities(): Boolean; override;
  end;

  //*** TUdActionArcCSA ***//
  TUdActionArcCSA = class(TUdActionArcCS) //Center Start Angle
  protected
    function UpdateEntities(): Boolean; override;
  end;

  //*** TUdActionArcCSL ***//
  TUdActionArcCSL = class(TUdActionArcCS) //Center Start Length
  protected
    function UpdateEntities(): Boolean; override;
  end;




  
//=========================================================================================
{ TUdActionArcBase }

constructor TUdActionArcBase.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FArc := TUdArc.Create(FDocument, False);
  FArc.Finished := False;
  FArc.Visible := False;
  FArc.Color.TrueColor := Self.GetDefColor;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;
  FLine.Color.TrueColor := Self.GetDefColor;

  FLine2 := TUdLine.Create(FDocument, False);
  FLine2.Finished := False;
  FLine2.Visible := False;
  FLine2.Color.TrueColor := Self.GetDefColor;
end;

destructor TUdActionArcBase.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FLine2) then FLine2.Free();
  if Assigned(FArc) then FArc.Free();
  inherited;
end;

procedure TUdActionArcBase.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
  if Assigned(FLine2) and FLine2.Visible then FLine2.Draw(ACanvas);
  if Assigned(FArc) and FArc.Visible then FArc.Draw(ACanvas);
end;



//=========================================================================================
{ TUdActionArc3P }

constructor TUdActionArc3P.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.Prompt(sArcStartPointOrKeyword, pkCmd);
end;


//---------------------------------------------------

function TUdActionArc3P.SetFirstPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sArcStartPointOrKeyword + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sArcSecondPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionArc3P.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FP2 := APnt;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sArcSecondPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sArcEndPoint, pkCmd);

  FStep := 2;
  Result := True;
end;

function TUdActionArc3P.SetThirdPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FP3 := APnt;
  if UpdateEntities() then
  begin
    FArc.Finished := True;
    Submit(FArc)
  end
  else
    FArc.Free();

  Self.SetPrevPoint(APnt);
  Self.Prompt(sArcEndPoint + ': ' + PointToStr(APnt), pkLog);

  FArc := nil;
  Result := Finish();
end;



//---------------------------------------------------

function TUdActionArc3P.Parse(const AValue: string): Boolean;
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
        LPnt.X := FP2.X + LPnt.X;
        LPnt.Y := FP2.Y + LPnt.Y;
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


function TUdActionArc3P.UpdateEntities: Boolean;
var
  LArc: TArc2D;
begin
  Result := True;

  if FStep = 1 then
  begin
    FArc.Visible := False;

    FLine.StartPoint := FP1;
    FLine.EndPoint := FP2;
    FLine.Visible := True;
  end
  else if FStep = 2 then
  begin
    FLine2.StartPoint := FP2;
    FLine2.EndPoint := FP3;
    FLine2.Visible := True;

    LArc := UdGeo2D.MakeArc(FP1, FP2, FP3);

    if LArc.R > 0 then
    begin
      FArc.XData := LArc;
      FArc.Visible := True;
    end
    else
      Result := False;
  end;
end;


procedure TUdActionArc3P.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;
end;

procedure TUdActionArc3P.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
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
          UpdateEntities();
        end
        else if FStep = 2 then
        begin
          FP3 := ACoordPnt;
          UpdateEntities();
        end;
      end;
  end;
end;





//=========================================================================================
{ TUdActionArcCS }

constructor TUdActionArcCS.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.Prompt(sCenterPoint, pkCmd);
end;

function TUdActionArcCS.UpdateEntities: Boolean;
begin
  Result := False;
end;



//---------------------------------------------------

function TUdActionArcCS.SetCenter(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FCenPnt := APnt;

  Self.Prompt(sCenterPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sArcStartPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionArcCS.SetStartPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 1) or IsEqual(FCenPnt, APnt) then Exit;

  FStartPnt := APnt;
  FEndPnt := APnt;
  UpdateEntities();

  Self.SetPrevPoint(APnt);
  Self.Prompt(sArcStartPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sArcEndPoint, pkCmd);

  FStep := 2;
  Result := True;
end;

function TUdActionArcCS.SetEndPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 2)  or IsEqual(FStartPnt, APnt) then Exit;

  FEndPnt := APnt;
  if UpdateEntities() then
  begin
    FArc.Finished := True;
    Self.Submit(FArc);
  end
  else
    FArc.Free();

  Self.SetPrevPoint(APnt);
  Self.Prompt(sArcEndPoint + ': ' + PointToStr(FEndPnt), pkLog);

  FArc := nil;
  Result := Self.Finish();
end;

function TUdActionArcCS.SetEndPoint(const AValue: Float): Boolean;
var
  R, L, A: Float;
begin
  Result := False;
  if FStep <> 2 then Exit;

  if Self.InheritsFrom(TUdActionArcCSE) then
  begin
    FArc.Finished := True;
    Self.Submit(FArc);
    Self.Prompt(sArcEndPoint + ': ' + PointToStr(FEndPnt), pkLog);
  end
  else if Self.InheritsFrom(TUdActionArcCSA) then
  begin
    A := UdMath.FixAngle(FArc.StartAngle + AValue);
    if not UdMath.IsEqual(A, FArc.StartAngle) then
    begin
      FArc.Center := FCenPnt;
      FArc.Radius := UdGeo2D.Distance(FCenPnt, FStartPnt);
      FArc.StartAngle := UdGeo2D.GetAngle(FCenPnt, FStartPnt);
      FArc.EndAngle := A;
      FArc.Visible := True;

      FArc.Finished := True;
      Self.Submit(FArc);
      Self.Prompt(sIncludedAngle + ': ' + FloatToStrF(AValue, ffFixed, 36, 2), pkLog);
    end
    else
      FArc.Free();
  end
  else if Self.InheritsFrom(TUdActionArcCSL) then
  begin
    R := UdGeo2D.Distance(FCenPnt, FStartPnt);
    L := UdGeo2D.Distance(FStartPnt, FEndPnt);

    if (L > 0.0) and (L <= 2 * R) then
    begin
      A := UdMath.ArcSinD(L / (2 * R)) * 2;

      FArc.Center := FCenPnt;
      FArc.Radius := R;
      FArc.StartAngle := UdGeo2D.GetAngle(FCenPnt, FStartPnt);
      FArc.EndAngle := FArc.StartAngle + A;

      FArc.Visible := True;

      FArc.Finished := True;
      Self.Submit(FArc);
      Self.Prompt(sChordLengh + ': ' + RealToStr(AValue), pkLog);
    end
    else
      FArc.Free();
  end;

  FArc := nil;
  Result := Finish();
end;




//---------------------------------------------------

function TUdActionArcCS.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  Result := True;

  if Trim(AValue) = '' then Exit;

  if (FStep = 0) or (FStep = 1) then
  begin
    if ParseCoord(AValue, LPnt, LIsOpp) then
    begin
      if FStep = 2 then
        SetCenter(LPnt)
      else if FStep = 1 then
      begin
        if LIsOpp then
        begin
          LPnt.X := FCenPnt.X + LPnt.X;
          LPnt.Y := FCenPnt.Y + LPnt.Y;
        end;
        SetStartPoint(LPnt);
      end
      else
    end
    else
    begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end;
  end
  else if (FStep = 2) then
  begin
    if ParseCoord(AValue, LPnt, LIsOpp) then
    begin
      if LIsOpp then
      begin
        LPnt.X := FStartPnt.X + LPnt.X;
        LPnt.Y := FStartPnt.Y + LPnt.Y;
      end;
      SetEndPoint(LPnt);
    end
    else if IsNum(AValue) then
    begin
      SetEndPoint(StrToFloat(AValue));
    end
    else
      Self.Prompt(sRequireDisOrPoint, pkLog);
  end;
end;


procedure TUdActionArcCS.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;
end;

procedure TUdActionArcCS.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                                    ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      if (AButton = mbLeft) then
      begin
        if FStep = 0 then
          SetCenter(ACoordPnt)
        else if FStep = 1 then
          SetStartPoint(ACoordPnt)
        else if FStep = 2 then
          SetEndPoint(ACoordPnt);
      end
      else if (AButton = mbRight) then
        Self.Finish();
    mkMouseMove:
      begin
        if FStep = 1 then
          FStartPnt := ACoordPnt
        else if FStep = 2 then
          FEndPnt := ACoordPnt;
        UpdateEntities();
      end;
  end;
end;



//=========================================================================================
{ TUdActionArcCSE }

function TUdActionArcCSE.UpdateEntities: Boolean;
var
  LP2: TPoint2D;
begin
  Result := True;

  if FStep = 1 then
  begin
    LP2 := FStartPnt;
  end
  else
    if FStep = 2 then
    begin
      LP2 := FEndPnt;

      FArc.Center := FCenPnt;
      FArc.Radius := UdGeo2D.Distance(FCenPnt, FStartPnt);
      FArc.StartAngle := UdGeo2D.GetAngle(FCenPnt, FStartPnt);
      FArc.EndAngle := UdGeo2D.GetAngle(FCenPnt, FEndPnt);
      if UdMath.IsEqual(FArc.StartAngle, FArc.EndAngle) then Result := False;

      FArc.Visible := True;
    end;

  FLine.StartPoint := FCenPnt;
  FLine.EndPoint := LP2;
  FLine.Visible := True;
end;




//=========================================================================================
{ TUdActionArcCSA }

function TUdActionArcCSA.UpdateEntities: Boolean;
var
  //Agl: Float;
  LP2: TPoint2D;
begin
  Result := True;

  if FStep = 1 then
  begin
    LP2 := FStartPnt;
  end
  else
    if FStep = 2 then
    begin
      LP2 := FEndPnt;

      FArc.Center := FCenPnt;
      FArc.Radius := UdGeo2D.Distance(FCenPnt, FStartPnt);
      FArc.StartAngle := UdGeo2D.GetAngle(FCenPnt, FStartPnt);
      FArc.EndAngle := FArc.StartAngle + UdGeo2D.GetAngle(FCenPnt, FEndPnt);
      if UdMath.IsEqual(FArc.StartAngle, FArc.EndAngle) then Result := False;

      FArc.Visible := True;
    end;

  FLine.StartPoint := FCenPnt;
  FLine.EndPoint := LP2;
  FLine.Visible := True;
end;





//=========================================================================================
{ TUdActionArcCSL }

function TUdActionArcCSL.UpdateEntities: Boolean;
var
  L, R, A: Float;
begin
  Result := True;

  if FStep = 1 then
  begin
    FLine.StartPoint := FCenPnt;
    FLine.EndPoint := FStartPnt;
    FLine.Visible := True;
  end
  else
    if FStep = 2 then
    begin
      FLine.StartPoint := FStartPnt;
      FLine.EndPoint := FEndPnt;
      FLine.Visible := True;

      R := UdGeo2D.Distance(FCenPnt, FStartPnt);
      L := UdGeo2D.Distance(FStartPnt, FEndPnt);

      if (L > 0.0) and (L <= 2 * R) then
      begin
        A := UdMath.ArcSinD(L / (2 * R)) * 2;

        FArc.Center := FCenPnt;
        FArc.Radius := R;
        FArc.StartAngle := UdGeo2D.GetAngle(FCenPnt, FStartPnt);
        FArc.EndAngle := FArc.StartAngle + A;

        FArc.Visible := True;
      end
      else
      begin
        FArc.Visible := False;
        Result := False;
      end;
    end;
end;






//========================================================================================
{ TUdActionArc }

class function TUdActionArc.CommandName: string;
begin
  Result := 'arc';
end;

constructor TUdActionArc.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  N: Integer;
  LArg: string;
begin
  inherited;

  LArg := LowerCase(Trim(Args));
  
  N := Pos(' ', LArg);
  if N > 0 then Delete(LArg, N, System.Length(LArg));

  FAction := nil;

  if (LArg = '') or (LArg = '3p') then
    FAction := TUdActionArc3P.Create(ADocument, FLayout, '') else
  if (LArg = 'cse') or (LArg = 'c') then
    FAction := TUdActionArcCSE.Create(ADocument, FLayout, '') else
  if (LArg = 'csa') or (LArg = 'e')  then
    FAction := TUdActionArcCSA.Create(ADocument, FLayout, '') else
  if (LArg = 'csl') or (LArg = 'l')  then
    FAction := TUdActionArcCSL.Create(ADocument, FLayout, '');// else
end;

destructor TUdActionArc.Destroy;
begin
  if Assigned(FAction) then FAction.Free;
  inherited;
end;


procedure TUdActionArc.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FAction) then FAction.Paint(Sender, ACanvas);
end;

function TUdActionArc.Parse(const AValue: string): Boolean;
var
  LValue: string;
begin
  Result := False;
  if not Assigned(FAction) then Exit; //=====>>>>

  if (FAction.Step = 0) then
  begin
    if FAction.InheritsFrom(TUdActionArc3P) then
    begin
      LValue := LowerCase(Trim(AValue));

      if (LValue = 'cse') or (LValue = 'c') then
      begin
        if Assigned(FAction) then FAction.Free;
        FAction := TUdActionArcCSE.Create(FDocument, FLayout, '');
      end
      else
      if (LValue = 'csa') or (LValue = 'e') then
      begin
        if Assigned(FAction) then FAction.Free;
        FAction := TUdActionArcCSA.Create(FDocument, FLayout, '');// else
      end
      else
      if (LValue = 'csl') or (LValue = 'l') then
      begin
        if Assigned(FAction) then FAction.Free;
        FAction := TUdActionArcCSL.Create(FDocument, FLayout, '');// else
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


procedure TUdActionArc.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FAction) then FAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionArc.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;
  if Assigned(FAction) then FAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
end;




end.