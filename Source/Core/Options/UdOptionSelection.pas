{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdOptionSelection;

{$I UdDefs.INC}

interface

uses
  Windows, Classes, Controls, Graphics,
  UdTypes, UdConsts, UdIntfs, UdObject;

type  
  //*** TUdOptionSelection ***//
  TUdOptionSelection = class(TUdObject)
  private
    FUseShiftToAdd         : Boolean;  // Use shift to add selection
    FWindowingHint         : Boolean;
    FPressDragWindow       : Boolean;
    FUnselectBeforeCommond : Boolean;
    FUnselectAfterCommond  : Boolean;
    FOnlyCurrentLayer      : Boolean;
    FClickOnPolygonInner   : Boolean;

  protected
    procedure SetFieldValue(AIndex: Integer; const AValue: Boolean);
    
  public
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); override;
    destructor Destroy; override;

  public
    property UseShiftToAdd         : Boolean index 0 read FUseShiftToAdd         write SetFieldValue;
    property WindowingHint         : Boolean index 1 read FWindowingHint         write SetFieldValue;
    property PressDragWindow       : Boolean index 2 read FPressDragWindow       write SetFieldValue;
    property UnselectBeforeCommond : Boolean index 3 read FUnselectBeforeCommond write SetFieldValue;
    property UnselectAfterCommond  : Boolean index 4 read FUnselectAfterCommond  write SetFieldValue;
    property OnlyCurrentLayer      : Boolean index 5 read FOnlyCurrentLayer      write SetFieldValue;
    property ClickOnPolygonInner   : Boolean index 6 read FClickOnPolygonInner   write SetFieldValue;
  end;


implementation



//==================================================================================================
{ TUdSelectionOption }

constructor TUdOptionSelection.Create(ADocument: TUdObject; AIsDocRegister: Boolean = True);
begin
  inherited;
  
  FUseShiftToAdd         := False;  // Use shift to add selection
  FWindowingHint         := True;
  FPressDragWindow       := False;
  FUnselectBeforeCommond := False;
  FUnselectAfterCommond  := True;
  FOnlyCurrentLayer      := False;
  FClickOnPolygonInner   := True;
end;

destructor TUdOptionSelection.Destroy;
begin

  inherited;
end;


procedure TUdOptionSelection.SetFieldValue(AIndex: Integer; const AValue: Boolean);
begin
  case AIndex of
    0 : FUseShiftToAdd         := AValue;
    1 : FWindowingHint         := AValue;
    2 : FPressDragWindow       := AValue;
    3 : FUnselectBeforeCommond := AValue;
    4 : FUnselectAfterCommond  := AValue;
    5 : FOnlyCurrentLayer      := AValue;
    6 : FClickOnPolygonInner   := AValue;
  end;
end;



end.