{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdCursor;

interface

uses
  Windows, Classes, Graphics, Controls,
  UdTypes, UdConsts;


type

  TUdCursor = class(TPersistent)
  private
    FControl: TWinControl;

    FColor: Integer;
    FStyle: TUdCursorStyle;

    FPickSize: Integer;
    FCrossSize: Integer;

    FLastPos: TPoint;

    FSysCursor: Boolean;

  protected
    procedure SetSysCursor(const AValue: Boolean);
        
    procedure SetColor(const AValue: Integer);
    procedure SetStyle(const AValue: TUdCursorStyle);
    procedure SetCursorSize(AIndex, AValue: Integer);

    {Cursor...}
    function FDrawCursor(ACanvas: TCanvas; APnt: TPoint): Boolean;

  public
    constructor Create(AControl: TWinControl);
    destructor Destroy; override;

    function HideCursor(ACanvas: TCanvas): Boolean;
    function ShowCursor(ACanvas: TCanvas; APnt: TPoint): Boolean;

  published
    property Color: Integer read FColor write SetColor;
    property Style: TUdCursorStyle read FStyle write SetStyle;

    property PickSize : Integer index 0 read FPickSize  write SetCursorSize;
    property CrossSize: Integer index 1 read FCrossSize write SetCursorSize;

    property SysCursor: Boolean read FSysCursor write SetSysCursor;
  end;

implementation


{$R UdCursors.res}

type
  TFCustomControl = class(TCustomControl);


//==============================================================================================
{ TUdCursor }

constructor TUdCursor.Create(AControl: TWinControl);
begin
  FControl := AControl;
  
  FColor := Windows.RGB(255, 255, 255);
  FStyle := csIdle;
  FPickSize  := DEFAULT_PICK_SIZE;
  FCrossSize := DEFAULT_CROSS_SIZE;

  FLastPos.X := -1;
  FLastPos.Y := -1;

  FSysCursor := False;
end;

destructor TUdCursor.Destroy;
begin
  FControl := nil;
  
  inherited;
end;




//------------------------------------------------------------------------------------

procedure TUdCursor.SetSysCursor(const AValue: Boolean);
begin
  FSysCursor := AValue;
  FControl.Cursor := crIdle;
end;




procedure TUdCursor.SetColor(const AValue: Integer);
var
  Sz: Integer;
  LTempRect: TRect;
begin
  if FColor <> AValue then
  begin
    FColor := AValue;

    Sz := FCrossSize + 2;

    LTempRect.Left   := FLastPos.X - Sz;
    LTempRect.Top    := FLastPos.Y - Sz;
    LTempRect.Right  := FLastPos.X + Sz;
    LTempRect.Bottom := FLastPos.Y + Sz;

    if Assigned(FControl) and FControl.HandleAllocated then
      InvalidateRect(FControl.Handle, @LTempRect, True);
  end;
end;

procedure TUdCursor.SetStyle(const AValue: TUdCursorStyle);
var
  Sz: Integer;
  LTempRect: TRect;
begin
  if (FStyle = AValue) then Exit;

  Sz := FCrossSize + 2;

  if AValue in [csNone, csPan, csZoom] then
  begin
    case AValue of
      csNone : FControl.Cursor := crNone;
      csPan  : FControl.Cursor := crPan;
      csZoom : FControl.Cursor := crZoom;
    end;
  end
  else
  begin
    if FSysCursor then
    begin
      if Assigned(FControl) then
      case AValue of
        csIdle: FControl.Cursor := crIdle;
        csDraw: FControl.Cursor := crDraw;
        csPick: FControl.Cursor := crPick;
      end;
    end
    else
    begin
      Sz := FCrossSize;
      FControl.Cursor := crNone;
    end;
  end;

  LTempRect.Left   := FLastPos.X - Sz;
  LTempRect.Top    := FLastPos.Y - Sz;
  LTempRect.Right  := FLastPos.X + Sz;
  LTempRect.Bottom := FLastPos.Y + Sz;

  FStyle := AValue;

  if Assigned(FControl) and FControl.HandleAllocated then
    InvalidateRect(FControl.Handle, @LTempRect, True);
end;

procedure TUdCursor.SetCursorSize(AIndex, AValue: Integer);
var
  LChanged: Boolean;
begin
  LChanged := False;
  case AIndex of
    0: if FPickSize <> AValue then
      begin
        FPickSize := AValue;
        LChanged := True;
      end;
    1: if FCrossSize <> AValue then
      begin
        FCrossSize := AValue;
        LChanged := True;
      end;
  end;
  if LChanged and Assigned(FControl) then FControl.Invalidate;
end;



//------------------------------------------------------------------------------------

function TUdCursor.FDrawCursor(ACanvas: TCanvas; APnt: TPoint): Boolean;

  procedure _DrawCursorCross();
  begin
    ACanvas.MoveTo(APnt.X - FCrossSize, APnt.Y);
    ACanvas.LineTo(APnt.X + FCrossSize, APnt.Y);
    //ACanvas.LineTo(APnt.X + FCrossSize + 1, APnt.Y);

    ACanvas.MoveTo(APnt.X, APnt.Y - CrossSize);
    ACanvas.LineTo(APnt.X, APnt.Y + FCrossSize);
    //ACanvas.LineTo(APnt.X, APnt.Y + FCrossSize + 1);
  end;

  procedure _DrawCursorRect();
  var
    LPnts: array of TPoint;  
  begin
    ACanvas.Brush.Style := bsClear;
    
    System.SetLength(LPnts, 4);
    LPnts[0] := Point(APnt.X - FPickSize, APnt.Y - FPickSize);
    LPnts[1] := Point(APnt.X + FPickSize, APnt.Y - FPickSize);
    LPnts[2] := Point(APnt.X + FPickSize, APnt.Y + FPickSize);
    LPnts[3] := Point(APnt.X - FPickSize, APnt.Y + FPickSize);

    ACanvas.Polygon(LPnts);
  end;



begin
  Result := False;
  if not Assigned(ACanvas) or FSysCursor then Exit;

  case FStyle of
    csIdle:
      begin
        _DrawCursorCross();
        _DrawCursorRect();
      end;
    csDraw: _DrawCursorCross();
    csPick: _DrawCursorRect();
  end;


  Result := True;
end;


function TUdCursor.ShowCursor(ACanvas: TCanvas; APnt: TPoint): Boolean;
//var
//  LRect: TRect;
begin
  Result := False;

  if not Assigned(FControl) or not FControl.HandleAllocated  or FSysCursor then Exit;

  if (FStyle in [csNone, csPan, csZoom]) then
  begin
    FLastPos := APnt;
    Exit;
  end;


  if Assigned(ACanvas) then
  begin
    FControl.Cursor := crNone;

    ACanvas.Pen.Color := FColor;
    ACanvas.Pen.Mode := pmXor;
    ACanvas.Pen.Style := psSolid;
    ACanvas.Pen.Width := 1;

    FDrawCursor(ACanvas, FLastPos);
    FDrawCursor(ACanvas, APnt);
    FLastPos := APnt;

//    LRect.Left   := APnt.X - 2 * FCrossSize;
//    LRect.Right  := APnt.X + 2 * FCrossSize;
//    LRect.Top    := APnt.Y - 2 * FCrossSize;
//    LRect.Bottom := APnt.Y + 2 * FCrossSize;

//    Windows.InvalidateRect(FControl.Handle, @LRect, True);

    ACanvas.Pen.Mode := pmCopy;
  end;

  Result := True;
end;


function TUdCursor.HideCursor(ACanvas: TCanvas): Boolean;
begin
  Result := False;

  if (FStyle in [csNone, csPan, csZoom]) or  FSysCursor or
    not Assigned(FControl) or not FControl.HandleAllocated then Exit;

  if Assigned(ACanvas) then
  begin
    FControl.Cursor := crNone;

    ACanvas.Pen.Color := FColor;
    ACanvas.Pen.Mode := pmXor;
    ACanvas.Pen.Style := psSolid;
    ACanvas.Pen.Width := 1;

    FDrawCursor(ACanvas, FLastPos);
  end;

  Result := True;
end;



end.