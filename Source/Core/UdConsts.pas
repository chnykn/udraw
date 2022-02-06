{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdConsts;

{$I UdDefs.INC}

{$DEFINE CN_LANG}



interface



var
  SELECTED_COLOR: Integer  = $FF00FF;
  SELECT_WIDOWING: Boolean = True;

const


{$IFDEF CN_LANG}
  sCmdName       = '命令';
  sUnknownCmd    = '未知命令';
  sCmdCancel     = '*取消*';

  sLayoutMode    = '模型';
  sLayoutName    = '布局';


  sInitColors: array[1..9] of string =
    ('红色', '黄色', '绿色', '青色', '蓝色', '品红', '白色', '灰色', '银色');
  sSelectOtherColor     = '选择颜色...';
  sSelectOtherLineType  = '其他...';

{$ELSE}
  sCmdName       = 'Command';
  sUnknownCmd    = 'Unknown command';
  sCmdCancel     = '*Cancel*';

  sLayoutMode    = 'Model';
  sLayoutName    = 'Layout';

  sInitColors: array[1..9] of string =
    ('Red', 'Yellow', 'Green', 'Cyan', 'Blue', 'Magenta', 'White', 'Gray', 'Silver');
  sSelectOtherColor    = 'Select Color...';
  sSelectOtherLineType = 'Other...';
      
{$ENDIF}

  sByLayer       = 'ByLayer';
  sByBlock       = 'ByBlock';

  sContinuous    = 'Continuous';
  sSolidLine     = 'Solid line';
  

  {Layer/LineType/Color's Status}
  STATUS_CURRENT = 1;
  STATUS_USELESS = 2;
  STATUS_DELETED = 4;
  STATUS_NEW     = 8;
    
    
const
  {Draw Flag}
  PRINT_PAINT   = 1;
  BLACK_PAINT   = 2;


  {Zoom level array}
  ZOOM_100 = 100;
  ZOOM_LEVLE_ARRAY: array[0..17] of Integer = (10, 20, 50, 75, 100, 200, 400, 800, 1600, 3200, 7200, 14400, 30000, 60000, 120000, 240000, 480000, 1000000); //

  ANGLE_GRIP_DIS  = 10;


  LINE_SPACE_FACTOR  = 10/6;
  SEGMENTS_PER_SPLINE_CTLPNT = 4;
  
  
const
  {Cursor size....}
  DEFAULT_PICK_SIZE  = 04;
  DEFAULT_CROSS_SIZE = 28;

  //csrNone    = -100;
  crIdle      = -101;
  crDraw      = -102;
  crPick      = -103;
  crPan       = -104;
  crZoom      = -105;

  
//-----------------------------------------------------------------------------------------------
{OSnap & Grip}


const
{OSnap Mode..}
  OSNP_NUL    = 0;

  OSNP_END     = 1;    //端点
  OSNP_MID     = 2;    //中点
  OSNP_CEN     = 4;    //圆心
  OSNP_INS     = 8;    //插入点
  OSNP_QUA     = 16;   //象限点
  OSNP_NOD     = 32 ;  //节点
  OSNP_PER     = 64 ;  //垂点
  OSNP_NEA     = 128;  //最近点
  OSNP_INT     = 256;  //交点
  OSNP_TAN     = 512;  //切点

  OSNP_ALL     = OSNP_END or OSNP_MID or OSNP_CEN or OSNP_INS or OSNP_QUA or OSNP_PER or OSNP_NEA or
                 OSNP_INT or OSNP_NOD or OSNP_TAN ;


//-----------------------------------------------------------------------------------------------
{ Type ID }

const
  ID_ENTITY         =  0;

  ID_LINE           =  1;
  ID_RAY            =  2;
  ID_XLINE          =  3;
  ID_RECT           =  4;
  ID_CIRCLE         =  5;
  ID_ARC            =  6;
  ID_ELLIPSE        =  7;
  ID_POLYLINE       =  8;
  ID_SPLINE         =  9;
  ID_POINT          =  10;
  ID_POINTS         =  11;

  ID_SOLID          =  12;
  ID_TEXT           =  13;
  ID_MTEXT          =  14;
  ID_IMAGE          =  15;
  ID_LEADER         =  16;
  ID_TOLERANCE      =  17;
  ID_HATCH          =  18;

  ID_DIMENTION      =  20;
  ID_DIMALIGNED     =  21;
  ID_DIMROTATED     =  22;
  ID_DIMARCLENGTH   =  23;
  ID_DIMORDINATE    =  24;
  ID_DIMRADIAL      =  25;
  ID_DIMRADIALLARGE =  26;
  ID_DIMDIAMETRIC   =  27;
  ID_DIMANGULAR     =  28;
  ID_DIM3PANGULAR   =  29;


  ID_INSERT         =  31;

  ID_ENTITIES       =  99;



  //-----------------------------

  ID_COLOR          = 101;
  ID_LINETYPE       = 102;
  ID_LINEWEIGHT     = 103;
  ID_LAYER          = 104;
  ID_DIMSTYLE       = 105;
  ID_TEXTSTYLE      = 106;
  ID_LAYOUT         = 107;
  ID_VIEWPORT       = 108;
  ID_BLOCK          = 109;

  ID_COLORS         = 111;
  ID_LINETYPES      = 112;
  ID_LINEWEIGHTS    = 113;
  ID_LAYERS         = 114;
  ID_DIMSTYLES      = 115;
  ID_TEXTTYLES      = 116;
  ID_LAYOUTS        = 117;
  ID_VIEWPORTS      = 118;
  ID_BLOCKS         = 119;

  ID_POINTSTYLE     = 121;
  ID_UNITS          = 122;
  ID_OPTIONS        = 123;

  ID_AXIS           = 131;
  ID_GRIDSNAP       = 132;
  ID_OBJSNAP        = 133;
  ID_DRAFTING       = 134;   //TUdDrafting
  ID_HATCHPATTERNS  = 135;   //TUdDrafting
  ID_DIM_PROP       = 136;


implementation

end.