{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdBaseActions;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Controls, Graphics,
  UdTypes, UdEvents, UdObject, UdEntity, UdAction,
  UdDimStyle, UdTextStyle;

type

  //*** TUdDrawAction ***//
  TUdDrawAction = class(TUdAction)
  protected
    function Submit(AEntity: TUdEntity): Boolean; virtual;
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;
  end;


  //*** TUdModifyAction ***//
  TUdModifyAction = class(TUdAction)
  protected
    FSelAction: TUdAction;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function Reset(): Boolean; override;
    procedure Paint(Sender: TObject; ACanvas: TCanvas); override;

    procedure KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word); override;
    procedure MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState;
                         ACoordPnt: TPoint2D; AScreenPnt: TPoint); override;

    function CanPopMenu: Boolean; override;
  end;



  //*** TUdViewAction ***//
  TUdViewAction = class(TUdAction)
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function CanPopMenu: Boolean; override;
  end;




  //*** TUdDimAction ***//
  TUdDimAction = class(TUdDrawAction)
  protected
    function GetDimStyle(): TUdDimStyle;
    function GetTextStyle(): TUdTextStyle;

  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

    function CanPopMenu: Boolean; override;

  public
    property DimStyle: TUdDimStyle read GetDimStyle;
    property TextStyle: TUdTextStyle read GetTextStyle;

  end;


  //*** TUdInquiryAction ***//
  TUdInquiryAction = class(TUdAction)
  public
    constructor Create(ADocument, ALayout: TUdObject; Args: string = ''); override;
    destructor Destroy(); override;

  end;




implementation

uses
  UdDocument, UdLayout, UdActionSelection;



//==================================================================================================
{ TUdDrawAction }

constructor TUdDrawAction.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  Self.CanSnap    := True;
  Self.CanOSnap   := True;
  Self.CanOrtho   := True;
  Self.CanPerpend := True;

  Self.RemoveAllSelected();
  Self.SetCursorStyle(csDraw);
end;

destructor TUdDrawAction.Destroy;
begin
  Self.RemoveAllSelected();
  inherited;
end;

function TUdDrawAction.Submit(AEntity: TUdEntity): Boolean;
begin
  Result := Self.AddEntity(AEntity);
  if Result then AEntity.Refresh();
end;




//==================================================================================================
{ TUdModifyAction }

constructor TUdModifyAction.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

  Self.CanPolar := False;
  
  FSelAction := TUdActionSelection.Create(FDocument, ALayout);
  Self.SetCursorStyle(csPick);
end;

destructor TUdModifyAction.Destroy;
begin
  Self.RemoveAllSelected();
  if Assigned(FSelAction) then FSelAction.Free;
  inherited;
end;

function TUdModifyAction.Reset: Boolean;
begin
  FSelAction.Reset();
  Result := inherited Reset();
end;

procedure TUdModifyAction.Paint(Sender: TObject; ACanvas: TCanvas);
begin
  inherited;
  if FSelAction.Visible then FSelAction.Paint(Sender, ACanvas);
end;



procedure TUdModifyAction.KeyEvent(Sender: TObject; AKind: TUdKeyKind; AShift: TUdShiftState; AKey: Word);
begin
  inherited;
  if FSelAction.Visible then FSelAction.KeyEvent(Sender, AKind, AShift, AKey);
end;

procedure TUdModifyAction.MouseEvent(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton;
  AShift: TUdShiftState; ACoordPnt: TPoint2D; AScreenPnt: TPoint);
begin
  inherited;

  if FSelAction.Visible then
    FSelAction.MouseEvent(Sender, AKind, AButton, AShift, ACoordPnt, AScreenPnt);
end;


function TUdModifyAction.CanPopMenu(): Boolean;
begin
  Result := False;
end;




//==================================================================================================
{ TUdViewAction }

constructor TUdViewAction.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;
  //... ...
end;

destructor TUdViewAction.Destroy;
begin
  //... ...
  inherited;
end;


function TUdViewAction.CanPopMenu(): Boolean;
begin
  Result := False;
end;



{ TUdDimAction }

constructor TUdDimAction.Create(ADocument, ALayout: TUdObject; Args: string = '');
begin
  inherited;

//  Self.CanSnap    := True;
//  Self.CanOSnap   := True;
//  Self.CanOrtho   := True;
//  Self.CanPerpend := True;

//  Self.SetCursorStyle(csDraw);
end;

destructor TUdDimAction.Destroy;
begin
  //... ...
  inherited;
end;

function TUdDimAction.GetDimstyle: TUdDimStyle;
begin
  Result := nil;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).DimStyles.Active;
end;

function TUdDimAction.GetTextstyle: TUdTextStyle;
begin
  Result := nil;
  if Assigned(FDocument) then
    Result := TUdDocument(FDocument).TextStyles.Active;
end;



function TUdDimAction.CanPopMenu: Boolean;
begin
  Result := False;
end;



{ TUdInquiryAction }

constructor TUdInquiryAction.Create(ADocument, ALayout: TUdObject; Args: string);
begin
  inherited;
  Self.RemoveAllSelected();
end;

destructor TUdInquiryAction.Destroy;
begin

  inherited;
end;




end.