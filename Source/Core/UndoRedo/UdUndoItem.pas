{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdUndoItem;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdObject;


type
  TUdUndoItem = class(TObject)
  protected
    FOwner: TObject;

  public
    constructor Create(AOwner: TObject); virtual;
    destructor Destroy; override;

    function Perform(): Boolean; virtual;

    function DoAddObject(AObj: TUdObject): Boolean; virtual;
    function DoRemoveObject(AObj: TUdObject): Boolean; virtual;
    function DoBeforeModifyObject(AObj: TUdObject; APropName: string): Boolean;  virtual;

  public
    property Owner: TObject read FOwner write FOwner;

  end;


implementation


//=================================================================================================

{ TUdUndoItem }

constructor TUdUndoItem.Create(AOwner: TObject);
begin
  FOwner := AOwner;
end;

destructor TUdUndoItem.Destroy;
begin

  inherited;
end;



function TUdUndoItem.DoAddObject(AObj: TUdObject): Boolean;
begin
  Result := False;
end;

function TUdUndoItem.DoRemoveObject(AObj: TUdObject): Boolean;
begin
  Result := False;
end;

function TUdUndoItem.DoBeforeModifyObject(AObj: TUdObject; APropName: string): Boolean;
begin
  Result := False;
end;



function TUdUndoItem.Perform(): Boolean;
begin
  Result := False;
end;

end.