{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionEllipse;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions;

type
  //*** TUdActionEllipse ***//
  TUdActionEllipse = class(TUdDrawAction)
  private
    FAction: TUdAction;

  protected
//    procedure SetCurAction(const AValue: TUdAction);

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
  UdLine, UdEllipse,
  UdMath, UdGeo2D, UdUtils, UdAcnConsts;


var
  GEllipseRadius1: Float = 10;
  GEllipseRadius2: Float = 10;



type
  //*** TUdActionEllipseBase ***//
  TUdActionEllipseBase = class(TUdDrawAction)
  private
    FCenter: TPoint2D;
    FRotation: Float;
    FRadius1, FRadius2: Float;
    FAngle1, FAngle2: Float;

    FLine: TUdLine;
    FEllipse: TUdEllipse;

    FP1, FP2: TPoint2D;
    FAngleAction: Boolean;

//    FOwerAction: TUdAction;
    
  protected
    function SetRadius2(const AValue: Float): Boolean; overload;
    function SetRadius2(APnt: TPoint2D): Boolean; overload;

    function SetAngle1(const AValue: Float): Boolean; overload;
    function SetAngle1(APnt: TPoint2D): Boolean; overload;

    function SetAngle2(const AValue: Float): Boolean; overload;
    function SetAngle2(APnt: TPoint2D): Boolean; overload;

    function UpdateEntities(): Boolean;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;
  end;


  //*** TUdActionEllipseAE ***//
  TUdActionEllipseAE = class(TUdActionEllipseBase) //Axis End
  protected
    function SetAxisEndPoint(APnt: TPoint2D): Boolean;
    function SetOtherEndPoint(const AValue: Float): Boolean; overload;
    function SetOtherEndPoint(APnt: TPoint2D): Boolean; overload;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;

  //*** TUdActionEllipseAngleAE ***//
  TUdActionEllipseAngleAE = class(TUdActionEllipseAE)
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
//    function Parse(const AValue: string): Boolean; override;
  end;



  //*** TUdActionEllipseCen ***//
  TUdActionEllipseCen = class(TUdActionEllipseBase) //Center
  protected
    function SetCenter(APnt: TPoint2D): Boolean;
    function SetRadius1(const AValue: Float): Boolean; overload;
    function SetRadius1(APnt: TPoint2D): Boolean; overload;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    function Parse(const AValue: string): Boolean; override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;
  end;


  //*** TUdActionEllipseAngleCen ***//
  TUdActionEllipseAngleCen = class(TUdActionEllipseCen)
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
  end;

  

//=========================================================================================
{ TUdActionEllipseAE }

constructor TUdActionEllipseBase.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FEllipse := TUdEllipse.Create(FDocument, False);
  FEllipse.Finished := False;
  FEllipse.Visible := False;
  FEllipse.Color.TrueColor := Self.GetDefColor();

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;
  FLine.Color.TrueColor := Self.GetDefColor();

  FAngle1 := 0.0;
  FAngle2 := 360.0;
  FAngleAction := False;

//  FOwerAction := nil;
end;

destructor TUdActionEllipseBase.Destroy;
begin
  if Assigned(FLine) then FLine.Free();
  if Assigned(FEllipse) then FEllipse.Free();

  inherited;
end;



//------------------------------------------------------------

procedure TUdActionEllipseBase.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FLine) then FLine.Draw(ACanvas);
  if Assigned(FEllipse) then FEllipse.Draw(ACanvas);
end;



function TUdActionEllipseBase.UpdateEntities: Boolean;
begin
  Result := False;

  if (FStep >= 1) then
  begin
    FLine.StartPoint := FP1;
    FLine.EndPoint := FP2;
    FLine.Visible := True;
  end
  else
    FLine.Visible := False;

  if (FStep >= 2) then
  begin
    FEllipse.BeginUpdate();
    try
      FEllipse.Center := FCenter;
      FEllipse.Rotation := FRotation;
      FEllipse.MajorRadius := FRadius1;
      FEllipse.MinorRadius := FRadius2;
      FEllipse.StartAngle := FAngle1;
      FEllipse.EndAngle   := FAngle2;
      FEllipse.Visible := True;
    finally
      FEllipse.EndUpdate();
    end;

    Result := (FEllipse.MajorRadius > 0) and (FEllipse.MinorRadius > 0);
  end;
end;



//------------------------------------------------------------

function TUdActionEllipseBase.SetRadius2(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FRadius2 := Abs(AValue);
  Self.Prompt(sEllOtherAxisDisOrRot + ': ' + RealToStr(AValue), pkLog);

  if FAngleAction then
  begin
    FStep := 3;
    Result := UpdateEntities();
  end
  else begin
    if UpdateEntities() then
    begin
      FEllipse.Finished := True;
      Self.Submit(FEllipse);
    end
    else
      FEllipse.Free();

    FEllipse := nil;
    Result := Self.Finish()
  end;
end;

function TUdActionEllipseBase.SetRadius2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 2 then Exit;

  FRadius2 := UdGeo2D.Distance(FCenter, APnt);
  Self.Prompt(sEllOtherAxisDisOrRot + ': ' + PointToStr(APnt), pkLog);

  if FAngleAction then
  begin
    FStep := 3;
    Result := UpdateEntities();

    Self.Prompt(sEllStartAngle, pkCmd);
  end
  else begin
    if UpdateEntities() then
    begin
      FEllipse.Finished := True;
      Self.Submit(FEllipse);
    end
    else
      FEllipse.Free();

    FEllipse := nil;
    Result := Self.Finish()
  end;
end;





function TUdActionEllipseBase.SetAngle1(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FP1 := FCenter;
  FP2 := FCenter;

  FAngle1 := FixAngle(AValue);
  FAngle2 := FAngle1;
  Self.Prompt(sEllStartAngle + ': ' + AngleToStr(AValue), pkLog);

  Self.Prompt(sEllEndAngle, pkCmd);

  FStep := 4;
  Result := UpdateEntities();
end;

function TUdActionEllipseBase.SetAngle1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FP1 := FCenter;
  FP2 := APnt;

  FAngle1 := UdGeo2D.CenAngToEllAng(FRadius1, FRadius2, FixAngle(GetAngle(FCenter, FP2) - FRotation) );
  FAngle2 := FAngle1;
  Self.Prompt(sEllStartAngle + ': ' + PointToStr(APnt), pkLog);
  
  Self.Prompt(sEllEndAngle, pkCmd);

  FStep := 4;
  Result := UpdateEntities();;
end;


function TUdActionEllipseBase.SetAngle2(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 4 then Exit;

  FP1 := FCenter;
  FP2 := FCenter;
    
  FAngle2 := FixAngle(AValue);

  if IsEqual(FAngle1, FAngle2) then
  begin
    FAngle1 := 0.0;
    FAngle2 := 360.0;
  end;

  Self.Prompt(sEllEndAngle + ': ' + AngleToStr(FAngle2), pkLog);

  if UpdateEntities() then
  begin
    FEllipse.Finished := True;
    Self.Submit(FEllipse);
  end
  else
    FEllipse.Free();

  FEllipse := nil;
  Result := Self.Finish()
end;

function TUdActionEllipseBase.SetAngle2(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 4 then Exit;

  FP1 := FCenter;
  FP2 := APnt;

  FAngle2 := UdGeo2D.CenAngToEllAng(FRadius1, FRadius2, FixAngle(GetAngle(FCenter, FP2) - FRotation) );;

  if IsEqual(FAngle1, FAngle2) then
  begin
    FAngle1 := 0.0;
    FAngle2 := 360.0;
  end;

  Self.Prompt(sEllEndAngle + ': ' + PointToStr(APnt), pkLog);

  if UpdateEntities() then
  begin
    FEllipse.Finished := True;
    Self.Submit(FEllipse);
  end
  else
    FEllipse.Free();

  FEllipse := nil;
  Result := Self.Finish();
end;



//=========================================================================================
{ TUdActionEllipseAE }

constructor TUdActionEllipseAE.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.Prompt(sEllAxisEndPointOrKeyword, pkCmd);
end;

function TUdActionEllipseAE.SetAxisEndPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;

  Self.CanOrtho := True;
  Self.SetPrevPoint(APnt);

  Self.Prompt(sEllAxisEndPointOrKeyword + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sEllOtherAxisEndPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionEllipseAE.SetOtherEndPoint(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 1) or IsEqual(APnt, FP1) then Exit;


  FCenter := UdGeo2D.MidPoint(FP1, APnt);
  FRadius1 := UdGeo2D.Distance(FP1, APnt) / 2;

  FP1 := FCenter;
  FRotation := UdGeo2D.GetAngle(FP1, APnt);
  UpdateEntities();

  Self.CanOrtho := False;
  Self.SetPrevPoint(FP1);

  Self.Prompt(sEllOtherAxisEndPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sEllOtherAxisDisOrRot, pkCmd);

  FStep := 2;
  Result := True;
end;

function TUdActionEllipseAE.SetOtherEndPoint(const AValue: Float): Boolean;
begin
  Result := False;
  if (FStep <> 1) or IsEqual(AValue, 0.0) then Exit;

  FRadius1 := AValue / 2;
  FRotation := UdGeo2D.GetAngle(FP1, FP2);
  FCenter := ShiftPoint(FP1, FRotation, FRadius1);


  FP1 := FCenter;
  UpdateEntities();

  Self.CanOrtho := False;
  Self.SetPrevPoint(FP1);

  Self.Prompt(sEllOtherAxisEndPoint + ': ' + RealToStr(AValue), pkLog);
  Self.Prompt(sEllOtherAxisDisOrRot, pkCmd);

  FStep := 2;
  Result := True;
end;



//--------------------------------------------------------------

function TUdActionEllipseAE.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  Result := True;

//  if Trim(AValue) = '' then
//  begin
//    if FStep = 1 then SetRotation(_ErrValue);
//    Exit;
//  end;

  if ParseCoord(AValue, LPnt, LIsOpp) then
  begin
    if FStep = 0 then
      SetAxisEndPoint(LPnt)
    else if FStep = 1 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP1.X + LPnt.X;
        LPnt.Y := FP1.Y + LPnt.Y;
      end;
      SetOtherEndPoint(LPnt);
    end
    else if FStep = 2 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP2.X + LPnt.X;
        LPnt.Y := FP2.Y + LPnt.Y;
      end;
      SetRadius2(LPnt);
    end
    else if FStep = 3 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP2.X + LPnt.X;
        LPnt.Y := FP2.Y + LPnt.Y;
      end;
      SetAngle1(LPnt);
    end
    else if FStep = 4 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP2.X + LPnt.X;
        LPnt.Y := FP2.Y + LPnt.Y;
      end;
      SetAngle2(LPnt);
    end;
  end
  else if UdUtils.IsNum(AValue) then
  begin
    if (FStep = 0)  then
      Self.Prompt(sInvalidPoint, pkLog)
    else if (FStep = 1) then
      SetOtherEndPoint(StrToFloat(AValue))
    else if (FStep = 2) then
      SetRadius2(StrToFloat(AValue))
    else if (FStep = 3) then
      SetAngle1(StrToAngle(AValue))
    else if (FStep = 4) then
      SetAngle2(StrToAngle(AValue));

    Result := True;
  end
  else
  begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


procedure TUdActionEllipseAE.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  //inherited;

end;

procedure TUdActionEllipseAE.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                     ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          if FStep = 0 then
            SetAxisEndPoint(ACoordPnt)
          else if FStep = 1 then
            SetOtherEndPoint(ACoordPnt)
          else if FStep = 2 then
            SetRadius2(ACoordPnt)
          else if FStep = 3 then
            SetAngle1(ACoordPnt)
          else if FStep = 4 then
            SetAngle2(ACoordPnt);
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        FP2 := ACoordPnt;
        if FStep = 2 then
          Self.FRadius2 := UdGeo2D.Distance(FP2, FCenter)
        else if FStep = 4 then
          FAngle2 := UdGeo2D.CenAngToEllAng(FRadius1, FRadius2, FixAngle(GetAngle(FCenter, FP2) - FRotation) );;

        UpdateEntities();
      end;
  end;
end;






//=========================================================================================

{ TUdActionEllipseCen }


constructor TUdActionEllipseCen.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  Self.Prompt(sEllCenterPoint, pkCmd);
end;


function TUdActionEllipseCen.SetCenter(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if FStep <> 0 then Exit;

  FP1 := APnt;
  FCenter := FP1;

  Self.CanOrtho := True;

  Self.SetPrevPoint(APnt);
  Self.Prompt(sEllCenterPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sEllAxisEndPoint, pkCmd);

  FStep := 1;
  Result := True;
end;

function TUdActionEllipseCen.SetRadius1(APnt: TPoint2D): Boolean;
begin
  Result := False;
  if (FStep <> 1) or IsEqual(APnt, FP1) then Exit;

  FRadius1 := UdGeo2D.Distance(FCenter, APnt);
  FRotation := UdGeo2D.GetAngle(FCenter, APnt);
  UpdateEntities();

  Self.CanOrtho := False;
  GEllipseRadius1 := FRadius1;

  Self.Prompt(sEllAxisEndPoint + ': ' + PointToStr(APnt), pkLog);
  Self.Prompt(sEllOtherAxisDisOrRot, pkCmd);

  FStep := 2;
  Result := True;
end;

function TUdActionEllipseCen.SetRadius1(const AValue: Float): Boolean;
begin
  Result := False;
  if FStep <> 1 then Exit;


  if AValue <> _ErrValue then
    FRadius1 := Abs(AValue)
  else
    FRadius1 := GEllipseRadius1;

  FRotation := GetAngle(FCenter, FP2);
  UpdateEntities();

  GEllipseRadius1 := FRadius1;

  Self.Prompt(sEllAxisEndPoint + ': ' + RealToStr(AValue), pkLog);
  Self.Prompt(sEllOtherAxisDisOrRot, pkCmd);

  FStep := 2;
  Result := True;  
end;





//--------------------------------------------------------------

function TUdActionEllipseCen.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
begin
  Result := True;

  if Trim(AValue) = '' then
  begin
    if FStep = 0 then
      SetRadius1(_ErrValue);
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
      SetRadius1(LPnt);
    end
    else if FStep = 2 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP2.X + LPnt.X;
        LPnt.Y := FP2.Y + LPnt.Y;
      end;
      SetRadius2(LPnt);
    end
    else if FStep = 3 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP2.X + LPnt.X;
        LPnt.Y := FP2.Y + LPnt.Y;
      end;
      SetAngle1(LPnt);
    end
    else if FStep = 4 then
    begin
      if LIsOpp then
      begin
        LPnt.X := FP2.X + LPnt.X;
        LPnt.Y := FP2.Y + LPnt.Y;
      end;
      SetAngle2(LPnt);
    end;    
  end
  else if UdUtils.IsNum(AValue) then
  begin
    if (FStep = 0) then
    begin
      Self.Prompt(sInvalidPoint, pkLog);
      Result := False;
    end
    else if FStep = 1 then
      SetRadius1(StrToFloat(AValue))
    else if FStep = 2 then
      SetRadius2(StrToFloat(AValue))
    else if FStep = 3 then
      SetAngle1(StrToFloat(AValue))
    else if FStep = 4 then
      SetAngle2(StrToFloat(AValue))      
  end
  else
  begin
    Self.Prompt(sInvalidPoint, pkLog);
    Result := False;
  end;
end;


procedure TUdActionEllipseCen.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;

end;

procedure TUdActionEllipseCen.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
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
            SetRadius1(ACoordPnt)
          else if FStep = 2 then
            SetRadius2(ACoordPnt)
          else if FStep = 3 then
            SetAngle1(ACoordPnt)
          else if FStep = 4 then
            SetAngle2(ACoordPnt);            
        end
        else if (AButton = mbRight) then
          Self.Finish();
      end;
    mkMouseMove:
      begin
        FP2 := ACoordPnt;
        if FStep = 2 then
          Self.FRadius2 := UdGeo2D.Distance(FP2, FCenter)
        else if FStep = 4 then
          FAngle2 := UdGeo2D.CenAngToEllAng(FRadius1, FRadius2, FixAngle(GetAngle(FCenter, FP2) - FRotation) );;
        UpdateEntities();
      end;
  end;
end;




{ TUdActionEllipseAngleAE }

constructor TUdActionEllipseAngleAE.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FAngleAction := True;
  Self.Prompt(sEllAxisEndPointOrKeyword + ': _a', pkLog);
  Self.Prompt(sEllArcAxisEndPointOrCen, pkCmd);   
end;

//function TUdActionEllipseAngleAE.Parse(const AValue: string): Boolean;
//var
//  LValue: string;
//begin
//  LValue := LowerCase(Trim(AValue));
//
//  if (FStep = 0) and Assigned(FOwerAction) and
//     (TUdActionEllipse(FOwerAction).FAction = Self) and
//     ((LValue = 'c') or (LValue = 'cen') or (LValue = 'center')) then
//  begin
//    TUdActionEllipse(FOwerAction).SetCurAction(TUdActionEllipseAngleCen.Create(FDocument, ''));
//    Result := True;
//  end
//  else
//    Result := inherited Parse(AValue);
//end;



{ TUdActionEllipseAngleCen }

constructor TUdActionEllipseAngleCen.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  FAngleAction := True;
end;





//========================================================================================
{ TUdActionEllipse }

class function TUdActionEllipse.CommandName: string;
begin
  Result := 'ellipse';
end;

constructor TUdActionEllipse.Create(ADocument, ALayout: TUdObject; Args: string = '');
var
  N: Integer;
  LArg: string;
begin
  inherited;

  LArg := LowerCase(Trim(Args));

  N := Pos(' ', LArg);
  if N > 0 then Delete(LArg, N, System.Length(LArg));

  FAction := nil;

  if (LArg = '') or (LArg = 'e') or (LArg = 'ae')  then
    FAction := TUdActionEllipseAE.Create(ADocument, FLayout, '') else
  if (LArg = 'c') or (LArg = 'cen') or (LArg = 'center') then
    FAction := TUdActionEllipseCen.Create(ADocument, FLayout, '') else
  if (LArg = 'a') or (LArg = 'arc')  then
    FAction := TUdActionEllipseAngleAE.Create(ADocument, FLayout, '');

//  if Assigned(FAction) then TUdActionEllipseBase(FAction).FOwerAction := Self;
end;

destructor TUdActionEllipse.Destroy;
begin
  if Assigned(FAction) then FAction.Free;
  inherited;
end;


procedure TUdActionEllipse.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FAction) then FAction.Paint(Sender, ACanvas);
end;

function TUdActionEllipse.Parse(const AValue: string): Boolean;
var
  LValue: string;
begin
  Result := False;
  if not Assigned(FAction) then Exit; //=====>>>>

  if (FAction.Step = 0) then
  begin
    LValue := LowerCase(Trim(AValue));
    
    if FAction.InheritsFrom(TUdActionEllipseAngleAE) then
    begin
      if (LValue = 'c') or (LValue = 'cen') or (LValue = 'center') then
      begin
        if Assigned(FAction) then FAction.Free;
        FAction := TUdActionEllipseAngleCen.Create(FDocument, FLayout, '');
      end
      else
        Self.Prompt(sRequirePointOrKeyword, pkLog);

//      if Assigned(FAction) then TUdActionEllipseBase(FAction).FOwerAction := Self;

      Result := True;
    end
    else if FAction.InheritsFrom(TUdActionEllipseAE) then
    begin
      if (LValue = 'c') or (LValue = 'cen') or (LValue = 'center') then
      begin
        if Assigned(FAction) then FAction.Free;
        FAction := TUdActionEllipseCen.Create(FDocument, FLayout, '');
      end
      else
      if (LValue = 'a') or (LValue = 'arc') then
      begin
        if Assigned(FAction) then FAction.Free;
        FAction := TUdActionEllipseAngleAE.Create(FDocument, FLayout, '');// else
      end
      else
        Self.Prompt(sRequirePointOrKeyword, pkLog);

//      if Assigned(FAction) then TUdActionEllipseBase(FAction).FOwerAction := Self;

      Result := True;
    end
    else
      Result := FAction.Parse(AValue);
  end
  else
    Result := FAction.Parse(AValue);
end;


//procedure TUdActionEllipse.SetCurAction(const AValue: TUdAction);
//begin
//  if Assigned(FAction) then FAction.Free;
//  FAction := AValue;
//end;

procedure TUdActionEllipse.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if Assigned(FAction) then FAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdActionEllipse.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;
  if Assigned(FAction) then FAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
end;




end.