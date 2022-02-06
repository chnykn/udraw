{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionCircle;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions;

type

  //*** TUdActionCircle ***//
  TUdActionCircle = class(TUdDrawAction)
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
  UdLine, UdCircle ,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;

var
  GStoreCircleRadius: Float = 10;



type

  //*** TUdActionCircleBase ***//
  TUdActionCircleBase = class(TUdDrawAction)
  private
    FLine: TUdLine;
    FCircle: TUdCircle;

  protected
//    function UpdateEntities(): Boolean; virtual;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
  end;


  //*** TUdActionCircleCR ***//
  TUdActionCircleCR = class(TUdActionCircleBase) //Center Radius
  private
    FP1, FP2: TPoint2D;

  protected
    function UpdateEntities(): Boolean;

    function SetCenter(APnt: TPoint2D): Boolean;
    function SetRadius(const AValue: Float): Boolean; overload;
    function SetRadius(APnt: TPoint2D): Boolean; overload;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionCircle2P ***//
  TUdActionCircle2P = class(TUdActionCircleBase)
  private
    FP1, FP2: TPoint2D;

  protected
    function UpdateEntities(): Boolean;

    function SetFirstPoint(APnt: TPoint2D): Boolean;
    function SetSecondPoint(APnt: TPoint2D): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionCircle3P ***//
  TUdActionCircle3P = class(TUdActionCircleBase)
  private
    FP1, FP2, FP3: TPoint2D;
    FLine2: TUdLine;
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



  

//=========================================================================================
{ TUdActionCircleBase }

constructor TUdActionCircleBase.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FCircle := TUdCircle.Create(FDocument, False);
  FCircle.Finished := False;
  FCircle.Visible := False;
end;

destructor TUdActionCircleBase.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FCircle) then FCircle.Free();
  inherited;
end;


procedure TUdActionCircleBase.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
  if Assigned(FCircle) and FCircle.Visible then FCircle.Draw(ACanvas);
end;




//=========================================================================================
{ TUdActionCircleCR }

constructor TUdActionCircleCR.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.Prompt(sCircleCenterPoint, pkCmd);
end;

destructor TUdActionCircleCR.Destroy;
begin

  inherited;
end;



//---------------------------------------------------

function TUdActionCircleCR.SetCenter(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;
  Self.CanOrtho := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sCircleCenterPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sCircleRadius + ' <' + RealToStr(GStoreCircleRadius) + '>', pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionCircleCR.SetRadius(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;

  FP2.X := FP1.X;
  FP2.Y := FP1.Y + AValue;

  UpdateEntities();
  FCircle.Finished := True;
  Self.Submit(FCircle);

  GStoreCircleRadius := AValue;
  Self.Prompt(sCircleRadius + ': ' + RealToStr(AValue), pkLog);

  FCircle := nil;
  Result := Finish();
end;

function TUdActionCircleCR.SetRadius(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 1) or IsEqual(FP1, APnt) then Exit;

  FP2 := APnt;
  UpdateEntities();
  FCircle.Finished := True;
  Self.Submit(FCircle);

  GStoreCircleRadius := UdGeo2D.Distance(FP1, FP2);
  Self.Prompt(sCircleRadius + ': ' + PointToStr(APnt), pkLog);

  FCircle := nil;
  Result := Finish();
end;




//---------------------------------------------------

function TUdActionCircleCR.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  Result := True;
  if Trim(AValue) = '' then
  begin
    if FStep = 1 then SetRadius(GStoreCircleRadius);
    Exit;
  end;

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
      SetRadius(LPnt);
    end;
  end
  else
  begin
    if (FStep = 1) and IsNum(AValue) then
    begin
      SetRadius(StrToFloat(AValue));
    end
    else
    begin
      Self.Prompt(sInvalidCircleRadius, pkLog);
      Result := False;
    end;
  end;
end;

function TUdActionCircleCR.UpdateEntities(): Boolean;
begin
  Result := False;
  if (FStep <> 1) then Exit;

  FLine.StartPoint := FP1;
  FLine.EndPoint := FP2;

  FLine.Visible := True;

  FCircle.Center := FP1;
  FCircle.Radius := UdGeo2D.Distance(FP1, FP2);

  FCircle.Visible := True;
  FCircle.Refresh();
  Result := True;
end;


procedure TUdActionCircleCR.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;

end;

procedure TUdActionCircleCR.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
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
            SetRadius(ACoordPnt);
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
        end;
      end;
  end;
end;






//=========================================================================================
{ TUdActionCircle2P }

constructor TUdActionCircle2P.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.Prompt(sCircleFirstPoint, pkCmd);
end;

destructor TUdActionCircle2P.Destroy;
begin
  inherited;
end;



//---------------------------------------------------

function TUdActionCircle2P.SetFirstPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;
  Self.CanOrtho := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sCircleFirstPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sCircleSecondPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionCircle2P.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 1) or IsEqual(APnt, FP1) then Exit;

  FP2 := APnt;
  UpdateEntities();
  FCircle.Finished := True;
  Self.Submit(FCircle);

  Self.SetPrevPoint(APnt);
  Self.Prompt(sCircleSecondPoint + ': ' + PointToStr(APnt), pkLog);

  FCircle := nil;
  Result := Finish();
end;



//---------------------------------------------------

function TUdActionCircle2P.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  Result := True;

//  if Trim(AValue) = '' then Exit;

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
    end;
  end
  else
  begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


function TUdActionCircle2P.UpdateEntities: Boolean;
begin
  Result := False;
  if (FStep <> 1) then Exit;

  FLine.StartPoint := FP1;
  FLine.EndPoint := FP2;
  FLine.Visible := True;

  FCircle.Center := UdGeo2D.MidPoint(FP1, FP2);
  FCircle.Radius := UdGeo2D.Distance(FP1, FP2) / 2;
  FCircle.Visible := True;

  Result := True;
end;


procedure TUdActionCircle2P.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;
  
end;

procedure TUdActionCircle2P.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
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
            SetSecondPoint(ACoordPnt);
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
        end;
      end;
  end;
end;




//=========================================================================================
{ TUdActionCircle3P }

constructor TUdActionCircle3P.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FLine2 := TUdLine.Create(FDocument, False);
  FLine2.Finished := False;
  FLine2.Visible := False;


  Self.Prompt(sCirclePoint1, pkCmd);
end;

destructor TUdActionCircle3P.Destroy;
begin
  FLine2.Free;
  FLine2 := nil;
  inherited;
end;


procedure TUdActionCircle3P.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FLine2) and FLine2.Visible then FLine2.Draw(ACanvas);
end;


//---------------------------------------------------

function TUdActionCircle3P.SetFirstPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sCirclePoint1 + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sCirclePoint2, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionCircle3P.SetSecondPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 1) or IsEqual(FP1, APnt) then Exit;

  FP2 := APnt;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sCirclePoint2 + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sCirclePoint3, pkCmd);

  FStep := 2;
  Result := True;
end;

function TUdActionCircle3P.SetThirdPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 2) or IsEqual(FP2, APnt) then Exit;

  FP3 := APnt;
  UpdateEntities();
  FCircle.Finished := True;
  Self.Submit(FCircle);

  Self.SetPrevPoint(APnt);
  Self.Prompt(sCirclePoint3 + ': ' + PointToStr(APnt), pkLog);

  FCircle := nil;
  Result := Finish();
end;



//---------------------------------------------------


function TUdActionCircle3P.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  Result := True;

//  if Trim(AValue) = '' then Exit;

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

function TUdActionCircle3P.UpdateEntities: Boolean;
var
  LCir: TCircle2D;
begin
  LCir := UdGeo2D.CircumCircle(FP1, FP2, FP3);

  FCircle.Center := LCir.Cen;
  FCircle.Radius := LCir.R;
  FCircle.Visible := True;

  Result := True;
end;


procedure TUdActionCircle3P.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;
  
end;

procedure TUdActionCircle3P.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
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
          FLine.StartPoint := FP1;
          FLine.EndPoint := ACoordPnt;
          FLine.Visible := True;
        end;
        if FStep = 2 then
        begin
          FLine2.StartPoint := FP2;
          FLine2.EndPoint := ACoordPnt;
          FLine2.Visible := True;

          FP3 := ACoordPnt;
          UpdateEntities();
        end;
      end;
  end;
end;






//========================================================================================
{ TUdActionCircle }

class function TUdActionCircle.CommandName: string;
begin
  Result := 'circle';
end;

constructor TUdActionCircle.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  N: Integer;
  LArg: string;
begin
  inherited;

  LArg := LowerCase(Trim(Args));
  
  N := Pos(' ', LArg);
  if N > 0 then Delete(LArg, N, System.Length(LArg));

  FAction := nil;

  if (LArg = '') or (LArg = 'c') or (LArg = 'cen') then
    FAction := TUdActionCircleCR.Create(ADocument, FLayout, '') else
  if LArg = '2p' then
    FAction := TUdActionCircle2P.Create(ADocument, FLayout, '') else
  if LArg = '3p' then
    FAction := TUdActionCircle3P.Create(ADocument, FLayout, '');// else
end;

destructor TUdActionCircle.Destroy;
begin
  if Assigned(FAction) then FAction.Free;
  inherited;
end;


procedure TUdActionCircle.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FAction) then FAction.Paint(Sender, ACanvas);
end;

function TUdActionCircle.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := False;
  if not Assigned(FAction) then Exit; //=====>>>>

  if (FAction.Step = 0) then
  begin
    if FAction.InheritsFrom(TUdActionCircleCR) then
    begin
      LValue := LowerCase(Trim(AValue));

      if ParseCoord(LValue, LPnt, LIsOpp) then
      begin
        TUdActionCircleCR(FAction).SetCenter(LPnt);
      end else

      if LValue = '2p' then
      begin
        if Assigned(FAction) then FAction.Free;
        FAction := TUdActionCircle2P.Create(FDocument, FLayout, '');
      end
      else
      if LValue = '3p' then
      begin
        if Assigned(FAction) then FAction.Free;
        FAction := TUdActionCircle3P.Create(FDocument, FLayout, '');// else
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


procedure TUdActionCircle.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FAction) then FAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionCircle.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;
  if Assigned(FAction) then FAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
end;


end.