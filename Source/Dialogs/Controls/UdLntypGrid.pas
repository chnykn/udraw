{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdLntypGrid;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Graphics, Controls, Grids,
  
  UdConsts, UdTypes, UdLineTypes, UdLinetype, UdResStatus;

type

  //----------------------------------------------------------

  TUdLntypTitle = class(TPersistent)
  private
    FStatus      : string;
    FLinetype    : string;
    FAppearance  : string;
    FDescription : string;

  public
    constructor Create();

  published
    property Status      : string read FStatus      write FStatus;
    property Linetype    : string read FLinetype    write FLinetype;
    property Appearance  : string read FAppearance  write FAppearance;
    property Description : string read FDescription write FDescription;
  end;




  //----------------------------------------------------------

  TUdLntypGrid = class(TCustomDrawGrid)
  private
    FResStatus: TUdResStatus;
    
    FTitle: TUdLntypTitle;
    FLineTypes: TUdLineTypes;

    FStatusVisible: Boolean;
    FByItemsVisible: Boolean;

    FOnSelectItem: TNotifyEvent;
    function GetSelectedItem: TUdLineType;

  protected
    procedure SetLineTypes(const AValue: TUdLineTypes);

    procedure SetStatusVisible(const AValue: Boolean);
    procedure SetByItemsVisible(const AValue: Boolean);

    procedure CreateParams(var AParams: TCreateParams); override;
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState); override;

    procedure MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer); override;
    
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Title: TUdLntypTitle read FTitle write FTitle;
    property LineTypes: TUdLineTypes read FLineTypes write SetLineTypes;
    property SelectedItem: TUdLineType read GetSelectedItem;

    property StatusVisible: Boolean read FStatusVisible write SetStatusVisible;
    property ByItemsVisible: Boolean read FByItemsVisible write SetByItemsVisible;

    property OnSelectItem: TNotifyEvent read FOnSelectItem write FOnSelectItem;

    property Align;
    property Anchors;
    property BorderStyle;
    property Color;
    property Constraints;
    property Ctl3D;
    property DefaultColWidth;
    property DefaultRowHeight;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property Font;
    property GridLineWidth;
    property Options;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property Visible;

    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
  UdDrawUtil;

const

  DEFAULT_STATUS       = 'Status';
  DEFAULT_LINETYPE     = 'Linetype';
  DEFAULT_APPEARANCE   = 'Appearance';
  DEFAULT_DESCRIPTION  = 'Description';

{
  DEFAULT_STATUS       = '状态';
  DEFAULT_LINETYPE     = '线型';
  DEFAULT_APPEARANCE   = '外观';
  DEFAULT_DESCRIPTION  = '说明';
}



//=============================================================================================
{ TUdLntypTitle }

constructor TUdLntypTitle.Create;
begin
  FStatus      := DEFAULT_STATUS;
  FLinetype    := DEFAULT_LINETYPE;
  FAppearance  := DEFAULT_APPEARANCE;
  FDescription := DEFAULT_DESCRIPTION;
end;



//=============================================================================================
{ TUdLntypGrid }

constructor TUdLntypGrid.Create(AOwner: TComponent);
begin
  inherited;

  Self.FixedRows := 1;
  Self.FixedCols := 0;

  Self.ColCount := 4;
  Self.RowCount := 3;

  Self.DefaultRowHeight := 18;

  Self.Options := Options - [goVertLine, goRangeSelect]; //, goHorzLine
  Self.Options := Options + [goColSizing, goRowSelect];

  Self.Width  := 550;
  Self.Height := 260;

  Self.ColWidths[0] := 40;
  Self.ColWidths[1] := 110;
  Self.ColWidths[2] := 130;
  Self.ColWidths[3] := 260;

  FLineTypes := nil;

  FByItemsVisible := True;
  FStatusVisible  := True;

  FResStatus := TUdResStatus.Create;
  FTitle     := TUdLntypTitle.Create;
end;

destructor TUdLntypGrid.Destroy;
begin
  FResStatus.Free;
  FTitle.Free;
  inherited;
end;

procedure TUdLntypGrid.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.WinClassName := 'LntypGrid';
end;



function TUdLntypGrid.GetSelectedItem: TUdLineType;
var
  LRect: TGridRect;
  LIndex: Integer;
begin
  Result := nil;
  
  LRect := Self.Selection;
  LIndex := LRect.Top - 1;

  if not FByItemsVisible then LIndex := LIndex + 2;
  if (LIndex >= 0) and (LIndex < FLineTypes.Count) then
    Result := FLineTypes.Items[LIndex];
end;



procedure TUdLntypGrid.SetLineTypes(const AValue: TUdLineTypes);
begin
//  if (FLineTypes <> AValue) then
  begin
    FLineTypes := AValue;
    
    if Assigned(FLineTypes) then
    begin
      if FByItemsVisible then
        Self.RowCount := FLineTypes.Count + 1
      else
        Self.RowCount := FLineTypes.Count + 1 - 2;
    end;
    Self.Invalidate;
  end;
end;


procedure TUdLntypGrid.SetStatusVisible(const AValue: Boolean);
begin
  if (FStatusVisible <> AValue) then
  begin
    FStatusVisible := AValue;
    if FStatusVisible then Self.ColWidths[0] := 40 else Self.ColWidths[0] := 0;
    
    Self.Invalidate;
  end;
end;

procedure TUdLntypGrid.SetByItemsVisible(const AValue: Boolean);
begin
  if (FByItemsVisible <> AValue) then
  begin
    FByItemsVisible := AValue;
    
    if Assigned(FLineTypes) then
    begin
      if FByItemsVisible then
        Self.RowCount := FLineTypes.Count + 1
      else
        Self.RowCount := FLineTypes.Count + 1 - 2;
    end;
    Self.Invalidate;
  end;  
end;




procedure FDrawStatus(ACanvas: TCanvas; ARect: TRect; AUIRes: TUdResStatus; AStatus: Cardinal);
var
//  L: Integer;
  LBmp: TBitmap;
begin
  LBmp := AUIRes.NormalBmp;
  if (AStatus and STATUS_DELETED) > 0 then LBmp := AUIRes.DeletedBmp else
  if (AStatus and STATUS_NEW)     > 0 then LBmp := AUIRes.NewBmp else
  if (AStatus and STATUS_USELESS) > 0 then LBmp := AUIRes.UselessBmp;// else;


//  L := ARect.Left + (ARect.Right - ARect.Left) div 2 - 8;
//  ACanvas.Draw(L, ARect.Top + 2, LBmp);

  ACanvas.Draw(2, ARect.Top + 2, LBmp);

  if (AStatus and STATUS_CURRENT) > 0 then
  begin
    LBmp := AUIRes.CurrentBmp;
    ACanvas.Draw(2 + 15, ARect.Top + 2, LBmp);
  end;
end;

procedure TUdLntypGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  LLinetype: TUdLinetype;
begin
  if Assigned(FLineTypes) then //and (FLineTypes.List.Count = RowCount - 1)
  begin

    if ARow = 0 then
    begin
      case ACol of
        0: Canvas.TextRect(ARect, ARect.Left + 5,  ARect.Top + 2, FTitle.Status);     //Status
        1: Canvas.TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Linetype);
        2: Canvas.TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Appearance);
        3: Canvas.TextRect(ARect, ARect.Left + 10, ARect.Top + 2, FTitle.Description);
      end;
    end
    else
    begin
      if FByItemsVisible then
        LLinetype := FLineTypes.Items[ARow - 1]
      else
        LLinetype := FLineTypes.Items[ARow - 1 + 2];

      if Assigned(LLinetype) then
      begin
        case ACol of
          0: if FStatusVisible then FDrawStatus(Canvas, ARect, FResStatus, LLinetype.Status);
          1: Canvas.TextRect(ARect, ARect.Left + 5, ARect.Top + 2, LLinetype.Name);
          2:
            begin
              InflateRect(ARect, -5, -5);
              DrawLineType(Canvas, ARect, LLinetype.Value);
            end;

          3: Canvas.TextRect(ARect, ARect.Left + 5, ARect.Top + 2, LLinetype.Comment);
        end;   
      end;
    end;

  end;
  
  inherited DrawCell(ACol, ARow, ARect, AState);
end;



procedure TUdLntypGrid.MouseDown(AButton: TMouseButton; AShift: TShiftState; X, Y: Integer);
var
  LCol, LRow, N: Longint;
begin
  inherited;
  if not Assigned(FLineTypes) then Exit;

  Self.MouseToCell(X, Y, LCol, LRow);

  N := LRow - 1;
  if not FByItemsVisible then N := N + 2;
  
  if (N < 0) or (N >= FLineTypes.Count) then Exit;

  if Assigned(FOnSelectItem) then FOnSelectItem(Self);
end;

end.