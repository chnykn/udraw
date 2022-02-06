{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdActions;

{$I UdDefs.INC}

interface

uses
  Classes, UdHashMaps,
  UdObject, UdAction;

type
  TUdActions = class(TUdObject)
  private
    FAncClassMap: TUdStrHashMap;

  protected
    procedure AddItem(AName: string; AClass: TUdActionClass);

    procedure LoadDimActions();
    procedure LoadModifyActions();
    procedure LoadEntityActions();
    procedure LoadViewActions();
    procedure LoadInquiryActions();
    procedure LoadUtilsAction();
    procedure LoadEditAction();

    function InitDefaultActions(): Boolean;

  public
    constructor Create(ADocument: TUdObject; AIsDocRegister: Boolean = True); override;
    destructor Destroy; override;

    function GetActionClass(AName: string): TUdActionClass;
    function LoadUserActions(AFileName: string): Boolean;

  end;

implementation

uses
  SysUtils,

  UdActionZoom, UdActionPan, UdActionDrawOrder, UdActionMatchProp,

  UdActionErase, UdActionCutClip, UdActionCopyClip, UdActionPasteClip,
  UdActionEditText, UdActionEditHatch,

  UdActionHatch, UdActionSpline,

  UdActionPoint, UdActionLine, UdActionXLine, UdActionRay, UdActionCircle, UdActionArc, UdActionEllipse,
  UdActionRect, UdActionRectange, UdActionPolygon, UdActionPolyline, UdActionClosedPolyline,  UdActionText,
  UdActionDonut,  UdActionBlock, UdActionInsert,

  UdActionArray, UdActionBreak, UdActionChamfer, UdActionExtend, UdActionFillet, UdActionLengthen,
  UdActionMirror, UdActionMove, UdActionCopy, UdActionOffset, UdActionRotate,
  UdActionScale, UdActionStretch, UdActionTrim, UdActionExplode,

  UdActionDimRotated, UdActionDimAligned, UdActionDimArcLength, UdActionDimRadial, UdActionDimDiametric,
  UdActionDimAngular, UdActionDimJogged, UdActionDimOrdinate, UdActionDimCenter, UdActionTolerance,
  UdActionLeader, UdActionDimBaseline, UdActionDimContinue, UdActionDimTextAlign, UdActionDimTextEdit,
  UdActionDimUpdate,

  UdActionDistance, UdActionArea, UdActionList, UdActioLocatePnt

  ;


//==============================================================================================
{ TUdActions }

constructor TUdActions.Create(ADocument: TUdObject; AIsDocRegister: Boolean = True);
begin
  inherited;
  FAncClassMap := TUdStrHashMap.Create();
  InitDefaultActions();
end;

destructor TUdActions.Destroy;
begin
  if Assigned(FAncClassMap) then FAncClassMap.Free;
  FAncClassMap := nil;

  inherited;
end;


procedure TUdActions.AddItem(AName: string; AClass: TUdActionClass);
begin
  if (AName <> '') and (AClass <> nil) then
    FAncClassMap.Add(LowerCase(AName), TObject(AClass));
end;



//--------------------------------------------------------------------------------

procedure TUdActions.LoadEntityActions();
begin
  AddItem('_po',           TUdActionPoint);
  AddItem('_point',        TUdActionPoint);

  AddItem('_l',            TUdActionLine);
  AddItem('_line',         TUdActionLine);

  AddItem('_xl',           TUdActionXLine);
  AddItem('_xline',        TUdActionXLine);

  AddItem('_ray',          TUdActionRay);

  AddItem('_c',            TUdActionCircle);
  AddItem('_circle',       TUdActionCircle);

  AddItem('_a',            TUdActionArc);
  AddItem('_arc',          TUdActionArc);

  AddItem('_ell',          TUdActionEllipse);
  AddItem('_ellipse',      TUdActionEllipse);


  AddItem('_pol',          TUdActionPolygon);
  AddItem('_polygon',      TUdActionPolygon);

  AddItem('_pline',        TUdActionPolygon);
  AddItem('_polyline',     TUdActionPolyline);
  AddItem('_closedpline',  TUdActionClosedPolyline);
  


  AddItem('_text',         TUdActionText);

  AddItem('_do',           TUdActionDonut);
  AddItem('_donut',        TUdActionDonut);

  AddItem('_rect',         TUdActionRect);
  AddItem('_rectange',     TUdActionRectange);

  AddItem('_spline',       TUdActionSpline);
  AddItem('_hatch',        TUdActionHatch);

  AddItem('_b',            TUdActionBlock);
  AddItem('_block',        TUdActionBlock);

  AddItem('_i',            TUdActionInsert);
  AddItem('_insert',       TUdActionInsert);
end;

procedure TUdActions.LoadModifyActions();
begin
  AddItem( '_co',         TUdActionCopy     );
  AddItem( '_copy',       TUdActionCopy     );

  AddItem( '_mi',         TUdActionMirror   );
  AddItem( '_mirror',     TUdActionMirror   );

  AddItem( '_ar',         TUdActionArray    );
  AddItem( '_array',      TUdActionArray    );

  AddItem( '_o',          TUdActionOffset   );
  AddItem( '_offset',     TUdActionOffset   );

  AddItem( '_ro',         TUdActionRotate   );
  AddItem( '_rotate',     TUdActionRotate   );

  AddItem( '_m',          TUdActionMove     );
  AddItem( '_move',       TUdActionMove     );

  AddItem( '_t',          TUdActionTrim     );
  AddItem( '_trim',       TUdActionTrim     );

  AddItem( '_ex',         TUdActionExtend   );
  AddItem( '_extend',     TUdActionExtend   );

  AddItem( '_s',          TUdActionStretch  );
  AddItem( '_stretch',    TUdActionStretch  );

  AddItem( '_len',        TUdActionLengthen );
  AddItem( '_lengthen',   TUdActionLengthen );

  AddItem( '_sc',         TUdActionScale    );
  AddItem( '_scale',      TUdActionScale    );

  AddItem( '_br',         TUdActionBreak    );
  AddItem( '_break',      TUdActionBreak    );
  
  AddItem( '_cha',        TUdActionChamfer  );
  AddItem( '_chamfer',    TUdActionChamfer  );

  AddItem( '_f',          TUdActionFillet   );
  AddItem( '_fillet',     TUdActionFillet   );

  AddItem( '_x',          TUdActionExplode  );
  AddItem( '_explode',    TUdActionExplode  );
end;





procedure TUdActions.LoadViewActions();
begin
  AddItem('_p',      TUdActionPanReal);
  AddItem('_pan',    TUdActionPanReal);
  
  AddItem('_-pan',   TUdActionPan2P);

  AddItem('_z',       TUdActionZoom);
  AddItem('_zoom',    TUdActionZoom);
end;

procedure TUdActions.LoadInquiryActions();
begin
  AddItem('_dist',     TUdActionDistance);
  AddItem('_distance', TUdActionDistance);
  
  AddItem('_area',   TUdActionArea);

  AddItem('_list',   TUdActionList);
  AddItem('_id',     TUdActionLocatePnt);
end;



procedure TUdActions.LoadDimActions();
begin
  AddItem('_dimlinear',    TUdActionDimRotated);
  AddItem('_dimaligned',   TUdActionDimAligned);
  AddItem('_dimarc',       TUdActionDimArcLength);
  AddItem('_dimradius',    TUdActionDimRadial);
  AddItem('_dimdiameter',  TUdActionDimDiametric);
  AddItem('_dimangular',   TUdActionDimAngular);
  AddItem('_dimjogged',    TUdActionDimJogged);
  AddItem('_dimordinate',  TUdActionDimOrdinate);
  AddItem('_dimcenter',    TUdActionDimCenter);
  AddItem('_tolerance',    TUdActionTolerance);
  AddItem('_qleader',      TUdActionLeader);
  AddItem('_dimbaseline',  TUdActionDimBaseline);
  AddItem('_dimcontinue',  TUdActionDimContinue);
  AddItem('_dimalign',     TUdActionDimTextAlign);
  AddItem('_dimedit',      TUdActionDimTextEdit);
  AddItem('_dimupdate',    TUdActionDimUpdate);
end;



procedure TUdActions.LoadUtilsAction();
begin
  AddItem('_draworder', TUdActionDrawOrder);
  AddItem('_matchprop', TUdActionMatchProp);
end;


procedure TUdActions.LoadEditAction();
begin
  AddItem( '_e',          TUdActionErase    );
  AddItem( '_erase',      TUdActionErase    );

  AddItem( '_cutclip',    TUdActionCutClip );
  AddItem( '_copyclip',   TUdActionCopyClip );
  AddItem( '_pasteclip',  TUdActionPasteClip );

  AddItem('_edittext',   TUdActionEditText);
  AddItem('_edithatch',  TUdActionEditHatch);
end;



function TUdActions.InitDefaultActions: Boolean;
begin
  LoadViewActions();
  LoadEntityActions();
  LoadModifyActions();
  LoadDimActions();
  LoadInquiryActions();
  LoadUtilsAction();
  LoadEditAction();
  
  Result := True;
end;



//--------------------------------------------------------------------------------


function TUdActions.GetActionClass(AName: string): TUdActionClass;
var
  LName: string;
  LClass: TObject;
begin
  Result := nil;

  LName := LowerCase(AName);
  LClass := FAncClassMap.GetValue(LName);

  if Assigned(LClass) then
    Result := TUdActionClass(LClass);
end;


function TUdActions.LoadUserActions(AFileName: string): Boolean;
begin
  Result := False;
end;

end.