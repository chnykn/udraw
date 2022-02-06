{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLwtListBox;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Controls, Graphics, StdCtrls,

  UdLineWeight;

type
  TUdLwtListBox = class(TCustomListBox)
  protected
    procedure DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState); override;
    procedure CreateParams(var AParams: TCreateParams); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init(AIncludeByItems: Boolean = True);

  published
    property Style;
    property AutoComplete;
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Columns;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ExtendedSelect;
    property Font;
    property ImeMode;
    property ImeName;
    property IntegralHeight;
    property ItemHeight;
    property Items;
    property MultiSelect;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ScrollWidth;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property TabWidth;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnData;
    property OnDataFind;
    property OnDataObject;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;


implementation

uses
  SysUtils, UdDrawUtil;




//==================================================================================================
{ TUdLwtListBox }

constructor TUdLwtListBox.Create(AOwner: TComponent);
begin
  inherited;
  Self.Style := lbOwnerDrawFixed;
end;

destructor TUdLwtListBox.Destroy;
begin

  inherited;
end;




procedure TUdLwtListBox.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.WinClassName := 'LwtListBox';
end;



procedure TUdLwtListBox.Init(AIncludeByItems: Boolean);
var
  I, N: Integer;
begin
  if AIncludeByItems then N := 0 else N := 2;
  for I := N to Length(ALL_LINE_WEIGHTS) - 1 do 
    Self.Items.Add( IntToStr(ALL_LINE_WEIGHTS[I]) );
end;


procedure TUdLwtListBox.DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
var
  LName: string;
  LValue: Integer;
  LRect: TRect;
  LBackground: TColor;
begin
  if AIndex >= 0 then
  begin
    LValue := StrToInt(Self.Items[AIndex]);
    LName := GetLineWeightName(TUdLineWeight(LValue));

    Self.Canvas.FillRect(ARect);
    LBackground := Self.Canvas.Brush.Color;

    LRect := ARect;
    LRect.Right := LRect.Left + Round((LRect.Right - LRect.Left) - 72);
    InflateRect(LRect, -2, -2);

    DrawLineWeight(Self.Canvas, LRect, UdLineWeight.GetLineWeightWidth(TUdLineWeight(LValue)) );

    Self.Canvas.Brush.Color := LBackground;
    ARect.Left := LRect.Right + 10;

    Self.Canvas.TextRect(ARect, ARect.Left,
      ARect.Top + (ARect.Bottom - ARect.Top - Self.Canvas.TextHeight(LName)) div 2, LName);
  end;
end;

(*
  function _CreatePen(Wd: Integer; Co: TColor; Sl: UINT): HPen;
  var
    LLogBrush: TLogBrush;
  begin
    LLogBrush.lbColor := CO;
    LLogBrush.lbStyle := BS_SOLID;
    LLogBrush.lbHatch := BS_SOLID;
    Result := ExtCreatePen(PS_GEOMETRIC or Sl or PS_ENDCAP_SQUARE or PS_JOIN_BEVEL, Wd, LLogBrush, 0, nil);
  end;

var
  LName: string;
  W, Y: Integer;
  LPenWid: Integer;
  LLwt: TUdLineWeight;
  LRect, LRect1: TRect;
begin
  Canvas.FillRect(ARect);
  if (AIndex >= Count) then Exit;

  LLwt := TUdLineWeight(Items.Objects[AIndex]);

  //--------------- LW
  LRect := ARect;
  LRect.Right := LRect.Left + 80;

  if (LRect.Right > LRect.Left) then
  begin
    LPenWid := UdLineWeight.GetLineWeightWidth(LLwt);

    InflateRect(LRect, -2, -2);

    W := LPenWid div 2;
    Y := (LRect.Top + LRect.Bottom) div 2;

    Canvas.Pen.Handle := _CreatePen(LPenWid, clBlack, PS_SOLID);

    Canvas.MoveTo(LRect.Left + W, Y);
    Canvas.LineTo(LRect.Right - W, Y);
  end;

  //--------------- Text
  LName := Self.Items[AIndex];
  
  LRect1 := ARect;
  LRect1.Left := LRect.Right + 20;
  if LRect1.Left < ARect.Left then LRect1.Left := ARect.Left;
  Canvas.TextRect(LRect1, LRect1.Left, LRect1.Top + (LRect1.Bottom - LRect1.Top - Canvas.TextHeight(LName)) div 2, LName);
end;
*)





end.