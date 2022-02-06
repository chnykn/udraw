                                                                                 {
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDimDiametric;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdConsts, UdObject, UdEntity,
  UdDimension, UdDimRadial;


type
  //*** TUdDimDiametric ***//
  TUdDimDiametric = class(TUdDimRadial)
  protected

  protected
    function GetTypeID(): Integer; override;
    function GetDimTypeID(): Integer; override;

    function IsDiametric(): Boolean; override;

    {...}
    procedure CopyFrom(AValue: TUdObject); override;

  public
    constructor Create(); override;
    destructor Destroy(); override;

    {load&save...}
    procedure SaveToStream(AStream: TStream); override;
    procedure LoadFromStream(AStream: TStream); override;

  public


  end;


implementation


 

//=================================================================================================
{ TUdDimDiametric }

constructor TUdDimDiametric.Create();
begin
  inherited;


end;

destructor TUdDimDiametric.Destroy;
begin
  
  inherited;
end;



function TUdDimDiametric.GetTypeID: Integer;
begin
  Result := ID_DIMDIAMETRIC;
end;

function TUdDimDiametric.GetDimTypeID: Integer;
begin
  Result := 3;
end;



function TUdDimDiametric.IsDiametric: Boolean;
begin
  Result := True;
end;

procedure TUdDimDiametric.CopyFrom(AValue: TUdObject);
begin
  inherited;
  
  if not AValue.InheritsFrom(TUdDimDiametric) then Exit;

//  FFilled := TUdFigure(AValue).FFilled;;
//  FFillStyle := TUdFigure(AValue).FFillStyle;;

end;






//----------------------------------------------------------------------------------------

procedure TUdDimDiametric.SaveToStream(AStream: TStream);
begin
  inherited;

end;

procedure TUdDimDiametric.LoadFromStream(AStream: TStream);
begin
  inherited;

  Self.Update();    
end;





end.
  