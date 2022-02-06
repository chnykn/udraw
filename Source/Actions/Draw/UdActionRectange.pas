{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActionRectange;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics, Controls,
  UdTypes, UdGTypes, UdEvents, UdObject, UdEntity, UdAction, UdBaseActions,
  UdLine, UdPolyline;

type
  //*** TUdActionRectange ***//
  TUdActionRectange = class(TUdDrawAction)
  private
    FP1, FP2: TPoint2D;

    FRotating: Boolean;

    FWidth, FHeight: Float;

    FCorner1: TPoint2D;
    FCorner2: TPoint2D;

    FLine: TUdLine;
    FPolyline: TUdPolyline;

  protected
    function UpdatePolyline(): Boolean;
    function ShowFirstPrompt(): Boolean;

    function SetFirstCorner(APnt: TPoint2D): Boolean;     // 0
    function SetOtherCorner(APnt: TPoint2D): Boolean;     // 1

    function SetChamferDis1(AValue: Float): Boolean;      // 2,3
    function SetChamferDis1P1(APnt: TPoint2D): Boolean;   // 2
    function SetChamferDis1P2(APnt: TPoint2D): Boolean;   // 3

    function SetChamferDis2(AValue: Float): Boolean;      // 4,5
    function SetChamferDis2P1(APnt: TPoint2D): Boolean;   // 4
    function SetChamferDis2P2(APnt: TPoint2D): Boolean;   // 5


    function SetFilletRadius(AValue: Float): Boolean;     // 6,7
    function SetFilletRadiusP1(APnt: TPoint2D): Boolean;  // 6
    function SetFilletRadiusP2(APnt: TPoint2D): Boolean;  // 7


    function SetLineWidth(AValue: Float): Boolean;        // 8,9
    function SetLineWidthP1(APnt: TPoint2D): Boolean;     // 8
    function SetLineWidthP2(APnt: TPoint2D): Boolean;     // 9

    function SetRotationAngle(AValue: Float): Boolean; overload;   // 10
    function SetRotationAngle(APnt: TPoint2D): Boolean; overload;    // 10

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
  UdMath, UdGeo2D, UdUtils, UdAcnConsts, UdFillet2D, UdChamfer2D;


type
  TUdRectangleMode = (rmChamfer, rmFillet, rmWidth);
  TUdRectangleModes = set of TUdRectangleMode;

var
  GRectangleModes : TUdRectangleModes = [];
  GChamferDis1    : Float   = 0.0;
  GChamferDis2    : Float   = 0.0;
  GFilletRadius   : Float   = 0.0;
  GLineWidth      : Float   = 0.0;
  GRotationAngle  : Float   = 0.0;


//========================================================================================
{ TUdActionRectange }

class function TUdActionRectange.CommandName: string;
begin
  Result := 'rectange';
end;

constructor TUdActionRectange.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  FWidth := 0;
  FHeight := 0;

  FRotating := False;

  FLine := TUdLine.Create(FDocument, False);
  FLine.Finished := False;
  FLine.Visible := False;

  FPolyline := TUdPolyline.Create(FDocument, False);
  FPolyline.Closed := True;
  FPolyline.Finished := False;
  FPolyline.Visible := False;

  ShowFirstPrompt();
end;

destructor TUdActionRectange.Destroy;
begin
  if Assigned(FLine) then FLine.Free;
  FLine := nil;

  if Assigned(FPolyline) then FPolyline.Free;
  FPolyline := nil;

  inherited;
end;


procedure TUdActionRectange.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if Assigned(FLine) and FLine.Visible then FLine.Draw(ACanvas);
  if Assigned(FPolyline) and FPolyline.Visible then FPolyline.Draw(ACanvas);
end;



//-----------------------------------------------------------------------------------------------

function TUdActionRectange.ShowFirstPrompt(): Boolean;
var
  LStr: string;
begin
  LStr := sCurrRectModes + ': ';

  if (GRectangleModes <> []) or NotEqual(GRotationAngle, 0.0) then
  begin
    if rmChamfer in GRectangleModes then
      LStr := LStr + sChamferName + '=' + RealToStr(GChamferDis1) + ' x ' + RealToStr(GChamferDis2) + '  ';

    if rmFillet in GRectangleModes then
      LStr := LStr + sFilletName + '=' + RealToStr(GFilletRadius) + '  ';

    if rmWidth in GRectangleModes then
      LStr := LStr + sWidthName + '=' + RealToStr(GLineWidth) + '  ';

    if NotEqual(GRotationAngle, 0.0) then
      LStr := LStr + sRotationName + '=' + AngleToStr(GRotationAngle) + '  ';

    Self.Prompt(LStr, pkLog);
  end;

  Result := Self.Prompt(sRectP1OrKeys, pkCmd);
end;


function TUdActionRectange.UpdatePolyline: Boolean;
var
  LAng: Float;
  LLnK: TLineK;
  LP1, LP2, LP3, LP4: TPoint2D;
  LSegarcs, LOutSegarcs: TSegarc2DArray;
begin

  if FRotating then
  begin
    LAng := GetAngle(FP1, FP2);
    LP1 := FP1;
    LP2 := ShiftPoint(LP1, LAng, FWidth);
    LP3 := ShiftPoint(LP2, LAng + 90, FHeight);
    LP4 := ShiftPoint(LP3, LAng + 180, FWidth);
  end
  else begin
    LAng := GRotationAngle;
    LLnK := LineK(FCorner1, LAng);

    LP1 := FCorner1;
    LP2 := ClosestLinePoint(FCorner2, LLnK);
    LP3 := FCorner2;

    FWidth  := Distance(LP1, LP2);
    FHeight := Distance(LP2, LP3);

    if IsEqual(GetAngle(LP1, LP2), LAng, 45) then
      LP4 := ShiftPoint(LP3 , LAng + 180, FWidth)
    else
      LP4 := ShiftPoint(LP3 , LAng, FWidth);
  end;

  System.SetLength(LSegarcs, 4);
  LSegarcs[0] := Segarc2D(LP1, LP2);
  LSegarcs[1] := Segarc2D(LP2, LP3);
  LSegarcs[2] := Segarc2D(LP3, LP4);
  LSegarcs[3] := Segarc2D(LP4, LP1);


  if rmChamfer in GRectangleModes then
  begin
    if UdChamfer2D.Chamfer(GChamferDis1, GChamferDis1, LSegarcs, LOutSegarcs) = CHAMFER_SUCCESS then
      LSegarcs := LOutSegarcs;
  end else
  if rmFillet in GRectangleModes then
  begin
    if UdFillet2D.Fillet(GFilletRadius, LSegarcs, LOutSegarcs) = FILLET_SUCCESS then
      LSegarcs := LOutSegarcs;
  end;

  FPolyline.BeginUpdate();
  try
    FPolyline.Vertexes := Vertexes2D(LSegarcs, False);
    if rmWidth in GRectangleModes then FPolyline.Width := GLineWidth;
  finally
    FPolyline.EndUpdate();
  end;

  Result := True;
end;


function TUdActionRectange.SetFirstCorner(APnt: TPoint2D): Boolean;     // 0
begin
  Result := False;
  if (FStep <> 0) then Exit;

  FCorner1 := APnt;
  FCorner2 := APnt;

  FStep := 1;
  FPolyline.Visible := True;

  Self.Prompt(sRectP2OrKeys, pkCmd);

  Result := True;
end;

function TUdActionRectange.SetOtherCorner(APnt: TPoint2D): Boolean;     // 1
begin
  Result := False;
  if (FStep <> 1) then Exit;

  FCorner2 := APnt;
  UpdatePolyline();

  FPolyline.Finished := True;
  Self.Submit(FPolyline);
  FPolyline := nil;

  Result := Self.Finish();
end;



function TUdActionRectange.SetChamferDis1(AValue: Float): Boolean;      // 2,3
begin
  Result := False;
  if not(FStep in [2, 3]) then Exit;  //2 3

  GRectangleModes := GRectangleModes - [rmFillet];
  GRectangleModes := GRectangleModes + [rmChamfer];

  GChamferDis1 := Abs(AValue);
  GChamferDis2 := Abs(AValue);

  Self.Prompt(sRectChamfer1 + ': ' + RealToStr(GChamferDis1), pkLog);
  Self.Prompt(sRectChamfer2 + ' <' + RealToStr(GChamferDis2) + '>', pkCmd);

  FLine.Visible := False;

  FStep := 4;
  Result := True;
end;

function TUdActionRectange.SetChamferDis1P1(APnt: TPoint2D): Boolean;   // 2
begin
  Result := False;
  if FStep <> 2 then Exit;

  FP1 := APnt;
  FLine.StartPoint := FP1;
  FLine.EndPoint := FP1;

  FLine.Visible := True;
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 3;
  Result := True;
end;

function TUdActionRectange.SetChamferDis1P2(APnt: TPoint2D): Boolean;   // 3
var
  LDis: Double;
begin
  Result := False;
  if FStep <> 3 then Exit;

  FP2 := APnt;

  FLine.Visible := False;
  Self.Prompt(sSecondPoint, pkLog);

  LDis := Distance(FP1, FP2);
  Result := SetChamferDis1(LDis);
end;



function TUdActionRectange.SetChamferDis2(AValue: Float): Boolean;      // 4,5
begin
  Result := False;
  if not(FStep in [4, 5]) then Exit;  // 4 5

  GRectangleModes := GRectangleModes - [rmFillet];


  if (AValue < 0) or IsEqual(AValue, 0.0) then AValue := 0.0;
  GChamferDis2 := Abs(AValue);

  if IsEqual(GChamferDis1, 0.0) and IsEqual(GChamferDis2, 0.0) then
    GRectangleModes := GRectangleModes - [rmChamfer]
  else
    GRectangleModes := GRectangleModes + [rmChamfer];


  Self.Prompt(sRectChamfer2 + ': ' + RealToStr(GChamferDis2), pkLog);
  Self.ShowFirstPrompt();

  FLine.Visible := False;

  FStep := 0;
  Result := True;
end;

function TUdActionRectange.SetChamferDis2P1(APnt: TPoint2D): Boolean;   // 4
begin
  Result := False;
  if FStep <> 4 then Exit;

  FP1 := APnt;
  FLine.StartPoint := FP1;
  FLine.EndPoint := FP1;

  FLine.Visible := True;
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 5;
  Result := True;
end;

function TUdActionRectange.SetChamferDis2P2(APnt: TPoint2D): Boolean;   // 5
var
  LDis: Double;
begin
  Result := False;
  if FStep <> 5 then Exit;

  FP2 := APnt;

  FLine.Visible := False;
  Self.Prompt(sSecondPoint, pkLog);

  LDis := Distance(FP1, FP2);
  Result := SetChamferDis2(LDis);
end;




function TUdActionRectange.SetFilletRadius(AValue: Float): Boolean;     // 6,7
begin
  Result := False;
  if not(FStep in [6, 7]) then Exit;

  GRectangleModes := GRectangleModes - [rmChamfer];

  if (AValue < 0) or IsEqual(AValue, 0.0) then
  begin
    AValue := 0.0;
    GRectangleModes := GRectangleModes - [rmFillet];
  end
  else
    GRectangleModes := GRectangleModes + [rmFillet];

  GFilletRadius := Abs(AValue);

  Self.Prompt(sRectFillet + ': ' + RealToStr(GFilletRadius), pkLog);
  Self.ShowFirstPrompt();

  FLine.Visible := False;

  FStep := 0;
  Result := True;
end;

function TUdActionRectange.SetFilletRadiusP1(APnt: TPoint2D): Boolean;  // 6
begin
  Result := False;
  if FStep <> 6 then Exit;

  FP1 := APnt;
  FLine.StartPoint := FP1;
  FLine.EndPoint := FP1;

  FLine.Visible := True;
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 7;
  Result := True;
end;

function TUdActionRectange.SetFilletRadiusP2(APnt: TPoint2D): Boolean;  // 7
var
  LDis: Double;
begin
  Result := False;
  if FStep <> 7 then Exit;

  FP2 := APnt;

  FLine.Visible := False;
  Self.Prompt(sSecondPoint, pkLog);

  LDis := Distance(FP1, FP2);
  Result := SetFilletRadius(LDis);
end;




function TUdActionRectange.SetLineWidth(AValue: Float): Boolean;        // 8,9
begin
  Result := False;
  if not(FStep in [8, 9]) then Exit;

  if (AValue < 0) or IsEqual(AValue, 0.0) then
  begin
    AValue := 0.0;
    GRectangleModes := GRectangleModes - [rmWidth];
  end
  else
    GRectangleModes := GRectangleModes + [rmWidth];

  GLineWidth := Abs(AValue);

  Self.Prompt(sRectWidth + ': ' + RealToStr(GLineWidth), pkLog);
  Self.ShowFirstPrompt();

  FLine.Visible := False;

  FStep := 0;
  Result := True;
end;

function TUdActionRectange.SetLineWidthP1(APnt: TPoint2D): Boolean;     // 8
begin
  Result := False;
  if FStep <> 8 then Exit;

  FP1 := APnt;
  FLine.StartPoint := FP1;
  FLine.EndPoint := FP1;

  FLine.Visible := True;
  Self.Prompt(sSecondPoint, pkCmd);

  FStep := 9;
  Result := True;
end;

function TUdActionRectange.SetLineWidthP2(APnt: TPoint2D): Boolean;     // 9
var
  LDis: Double;
begin
  Result := False;
  if FStep <> 9 then Exit;

  FP2 := APnt;

  FLine.Visible := False;
  Self.Prompt(sSecondPoint, pkLog);

  LDis := Distance(FP1, FP2);
  Result := SetLineWidth(LDis);
end;




function TUdActionRectange.SetRotationAngle(AValue: Float): Boolean;
begin
  Result := False;
  if (FStep <> 10) then Exit;

  FRotating := False;
  GRotationAngle := FixAngle(AValue);

  Self.Prompt(sRotationAngle + ': ' + AngleToStr(GRotationAngle), pkLog);
  Self.Prompt(sRectP2OrKeys, pkCmd);

  FLine.Visible := False;

  FStep := 1;
  Result := True;
end;

function TUdActionRectange.SetRotationAngle(APnt: TPoint2D): Boolean;
begin
  Result := Self.SetRotationAngle(GetAngle(FCorner1, APnt));
end;




//-----------------------------------------------------------------------------------------------

function TUdActionRectange.Parse(const AValue: string): Boolean;
var
  LPnt: TPoint2D;
  LIsOpp: Boolean;
  LValue: string;
begin
  Result := True;

  LValue := LowerCase(Trim(AValue));

  case FStep of
    0:
    begin
      if (LValue = 'c') or (LValue = 'chamfer') then
      begin
        FStep := 2;
        Self.Prompt(sRectChamfer1 + '<' + RealToStr(GChamferDis1) + '>', pkCmd);
      end else
      if (LValue = 'f') or (LValue = 'fillet') then
      begin
        FStep := 6;
        Self.Prompt(sRectFillet + '<' + RealToStr(GFilletRadius) + '>', pkCmd);
      end else
      if (LValue = 'w') or (LValue = 'width') then
      begin
        FStep := 8;
        Self.Prompt(sRectWidth + '<' + RealToStr(GLineWidth) + '>', pkCmd);
      end else
      if ParseCoord(LValue, LPnt, LIsOpp) then
      begin
        SetFirstCorner(LPnt);
      end;
    end;

    1:
    begin
      if (LValue = 'r') or (LValue = 'rotation') then
      begin
        FStep := 10;
        FRotating := True;
        FP1 := FCorner1;
        FP2 := FCorner1;
        FLine.StartPoint := FP1;
        FLine.EndPoint   := FP2;
        FLine.Visible := True;
        Self.Prompt(sRotationAngle + '<' + AngleToStr(GRotationAngle) + '>', pkCmd);
      end else
//      if (LValue = 'd') or (LValue = 'dimensions') then
//      begin
//        //...
//      end else
      if ParseCoord(LValue, LPnt, LIsOpp) then
      begin
        SetOtherCorner(LPnt);
      end;
    end;

    2,3:
    begin
      if IsNum(LValue) then
      begin
        SetChamferDis1(StrToFloat(LValue)) ;
      end
      else if ParseCoord(LValue, LPnt, LIsOpp) then
      begin
        if FStep = 2 then SetChamferDis1P1(LPnt) else
        begin
          if LIsOpp then
          begin
            LPnt.X := FLine.StartPoint.X + LPnt.X;
            LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
          end;
          SetChamferDis1P2(LPnt)
        end;
      end
      else begin
        Self.Prompt(sInvalidPoint, pkLog);
        Result := False;
      end;
    end;

    4,5:
    begin
      if IsNum(LValue) then
      begin
        SetChamferDis2(StrToFloat(LValue)) ;
      end
      else if ParseCoord(LValue, LPnt, LIsOpp) then
      begin
        if FStep = 4 then SetChamferDis2P1(LPnt) else
        begin
          if LIsOpp then
          begin
            LPnt.X := FLine.StartPoint.X + LPnt.X;
            LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
          end;
          SetChamferDis2P2(LPnt)
        end;
      end
      else begin
        Self.Prompt(sInvalidPoint, pkLog);
        Result := False;
      end;
    end;

    6,7:
    begin
      if IsNum(LValue) then
      begin
        SetFilletRadius(StrToFloat(LValue)) ;
      end
      else if ParseCoord(LValue, LPnt, LIsOpp) then
      begin
        if FStep = 6 then SetFilletRadiusP1(LPnt) else
        begin
          if LIsOpp then
          begin
            LPnt.X := FLine.StartPoint.X + LPnt.X;
            LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
          end;
          SetFilletRadiusP2(LPnt)
        end;
      end
      else begin
        Self.Prompt(sInvalidPoint, pkLog);
        Result := False;
      end;
    end;

    8,9:
    begin
      if IsNum(LValue) then
      begin
        SetLineWidth(StrToFloat(LValue)) ;
      end
      else if ParseCoord(LValue, LPnt, LIsOpp) then
      begin
        if FStep = 8 then SetLineWidthP1(LPnt) else
        begin
          if LIsOpp then
          begin
            LPnt.X := FLine.StartPoint.X + LPnt.X;
            LPnt.Y := FLine.StartPoint.Y + LPnt.Y;
          end;
          SetLineWidthP2(LPnt)
        end;
      end
      else begin
        Self.Prompt(sInvalidPoint, pkLog);
        Result := False;
      end;
    end;

    10:
    begin
      if IsNum(LValue) then
      begin
        SetRotationAngle(StrToFloat(LValue)) ;
      end
      else begin
        Self.Prompt(sRequireValue, pkLog);
        Result := False;
      end;
    end;

  end;

  //...
end;


procedure TUdActionRectange.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  //...
end;

procedure TUdActionRectange.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  case AKind of
    mkMouseDown:
      begin
        if (AButton = mbLeft) then
        begin
          case FStep of
            0: SetFirstCorner(ACoordPnt);
            1: SetOtherCorner(ACoordPnt);
            2: SetChamferDis1P1(ACoordPnt);
            3: SetChamferDis1P2(ACoordPnt);
            4: SetChamferDis2P1(ACoordPnt);
            5: SetChamferDis2P2(ACoordPnt);
            6: SetFilletRadiusP1(ACoordPnt);
            7: SetFilletRadiusP2(ACoordPnt);
            8: SetLineWidthP1(ACoordPnt);
            9: SetLineWidthP2(ACoordPnt);
            10: SetRotationAngle(ACoordPnt);
          end;
        end
        else if (AButton = mbRight) then
        begin
          case FStep of
            0: Self.Finish();
            2,3: SetChamferDis1(GChamferDis1);
            4,5: SetChamferDis2(GChamferDis2);
            6,7: SetFilletRadius(GFilletRadius);
            8,9: SetLineWidth(GLineWidth);
            10,11: Self.Finish();
          end;
        end;
      end;


    mkMouseMove:
      begin
        if (FStep = 1) then
        begin
          FCorner2 := ACoordPnt;
          Self.UpdatePolyline();
        end else
        if (FStep = 10) then
        begin
          FP2 := ACoordPnt;
          FLine.EndPoint := FP2;

          FRotating := True;
          Self.UpdatePolyline();
        end else
        if (FStep in [3,5,7,9,11])  then
        begin
          FP2 := ACoordPnt;
          FLine.EndPoint := FP2;
        end;
      end;
  end;
end;




end.