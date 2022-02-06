{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfReadHeader;

{$I UdDefs.INC}

interface

uses
  UdTypes, UdDocument,
  UdDxfTypes, UdDxfReadSection;

type

  TUdDxfReadHeader = class(TUdDxfReadSection)
  private
    FDxfVer           : string;
    FActiveDimStyle   : string;
    FActiveLineType   : string;
    FActiveTextStyle  : string;
    FActiveLayer      : string;
    FActiveColor      : Integer;
    FActiveLineWeight : Integer;
    FSortEntsFlag     : Integer;

  public
    procedure Execute(); override;

  public
    property DxfVer           : string  read  FDxfVer          ;
    property ActiveDimStyle   : string  read  FActiveDimStyle  ;
    property ActiveLineType   : string  read  FActiveLineType  ;
    property ActiveTextStyle  : string  read  FActiveTextStyle ;
    property ActiveLayer      : string  read  FActiveLayer     ;
    property ActiveColor      : Integer read  FActiveColor     ;
    property ActiveLineWeight : Integer read  FActiveLineWeight;

    property SortEntsFlag     : Integer read  FSortEntsFlag    ;
  end;

implementation

uses
  SysUtils,
  UdGeo2D, UdMath, UdUnits, UdDimProps;


(*
40: ---------------------------------------------------------------------------------------------
    $LTSCALE            : 全局线型比例
    $CELTSCALE          : 当前图元线型比例

    $PDSIZE             : 点显示尺寸
    $TEXTSIZE           : 默认文字高度
    $TRACEWID           : 默认宽线宽度
    $CMLSCALE           : 当前多线比例

    $PELEVATION         : 当前图纸空间标高
    $PLINEWID           : 默认的多段线宽度
    $PSVPSCALE          : 查看新视口的比例因子：0= 按图纸空间缩放  >0 = 比例因子（正实数值）

    $CHAMFERA           : 第一个倒角距离
    $CHAMFERB           : 第二个倒角距离
    $CHAMFERC           : 倒角长度
    $CHAMFERD           : 倒角角度
    $FILLETRAD          : 圆角半径



    $DIMALTF            : 换算单位比例因子
    $DIMALTRND          : 确定换算单位的舍入值
    $DIMASZ             : 标注箭头尺寸
    $DIMCEN             : 中心标记/中心线的大小
    $DIMDLE             : 尺寸线超出尺寸界线的距离
    $DIMDLI             : 尺寸线增量
    $DIMEXE             : 尺寸界线延伸
    $DIMEXO             : 尺寸界线偏移
    $DIMFAC             : 用于计算标注分数和公差的文字高度的比例因子。AutoCAD 将 DIMTFAC 与 DIMTXT 相乘，以设置分数或公差的文字高度
    $DIMGAP             : 尺寸线间距
    $DIMLFAC            : 线性测量的比例因子
    $DIMRND             : 标注距离的舍入值
    $DIMSCALE           : 全局标注比例因子
    $DIMTFAC            : 标注公差显示比例因子
    $DIMTM              : 下偏差
    $DIMTP              : 上偏差
    $DIMTSZ             : 标注标记大小： 0 = 无标记
    $DIMTVP             : 文字的垂直位置
    $DIMTXT             : 标注文字高度


    $ELEVATION          : 由 ELEV 命令设置的当前标高
    $THICKNESS          : 由 ELEV 命令设置的当前厚度
    $SHADOWPLANELOCATION: 地面阴影平面的位置。这是 Z 轴坐标。
    $SKETCHINC          : 徒手画记录增量
    $TDCREATE           : 创建图形的本地日期/时间（参见日期/时间变量的特殊处理）
    $TDINDWG            : 此图形的累计编辑时间（参见日期/时间变量的特殊处理）
    $TDUCREATE          : 创建图形的通用日期/时间（参见日期/时间变量的特殊处理）
    $TDUPDATE           : 上次更新图形的本地日期/时间（参见日期/时间变量的特殊处理）
    $TDUSRTIMER         : 用户消耗时间计时器
    $TDUUPDATE          : 上次更新/保存图形的通用日期/时间（参见日期/时间变量的特殊处理）



70:  ---------------------------------------------------------------------------------------------
    $ATTMODE            : 属性的可见性：0 = 无 1 = 普通 2 = 全部


    $ANGDIR             : 0 = 逆时针角度 1 = 顺时针角度
    $AUNITS              角度的单位格式


    $AUPREC             : 角度的单位精度

    $CMLJUST            : 当前多线对正： 0 = 顶端对正；1 = 居中对正；2 = 底端对正
    $DIMADEC            : 角度标注中显示的精度位的位数
    $DIMALT             : 非零时执行的换算单位标注
    $DIMALTD            : 换算单位小数位
    $DIMALTTD           : 换算单位标注的公差值的小数位数
    $DIMALTTZ           : 控制是否对换算公差值做消零处理：
                          0 = 抑制零英尺和精确零英寸  1 = 包含零英尺和精确零英寸  2 = 包含零英尺，抑制零英寸  3 = 包含零英寸，抑制零英尺

    $DIMALTU            : 所有标注样式族成员（角度标注除外）的换算单位的单位格式：
                          1 = 科学；2 = 小数；3 = 工程； 4 = 建筑（堆叠）；5 = 分数（堆叠）；6 = 建筑；7 = 分数

    $DIMALTZ            : 控制是否对换算单位标注值做消零处理：
                          0 = 抑制零英尺和精确零英寸 1 = 包含零英尺和精确零英寸2 = 包含零英尺，抑制零英寸 3 = 包含零英寸，抑制零英尺

    $DIMASO             : 0 = 绘制单个图元 1 = 创建关联标注
    $DIMATFIT           : 在尺寸界线内没有足够的空间放置标注文字和箭头时，控制两者的位置：
                          0 = 将文字和箭头放置在尺寸界线外 1 = 首先移动箭头，然后移动文字 2 = 首先移动文字，然后移动箭头 3 = 移动文字和箭头中较合适的一个
                          如果 DIMTMOVE 设置为 1，AutoCAD 将为被移动的标注文字添加一条引线

    $DIMAUNIT           : 角度标注的角度格式： 0 = 十进制度数；1 = 度/分/秒； 2 = 百分度；3 = 弧度；4 = 勘测单位
    $DIMAZIN            : 控制对角度标注的消零处理：
                          0 = 显示所有前导零和后续零  1 = 消去十进制标注中的前导零  2 = 消去十进制标注中的后续零 3 = 消去前导零和后续零

    $DIMCLRD            : 尺寸线颜色：范围是 0 = 随块；256 = 随层
    $DIMCLRE            : 尺寸界线颜色： 范围是：0 = 随块；256 = 随层
    $DIMCLRT            : 标注文字的颜色： 范围是：0 = 随块；256 = 随层
    $DIMDEC             : 主单位标注的公差值的小数位数
    $DIMDSEP            : 创建单位格式为小数的标注时使用的单字符小数分隔符
    $DIMJUST            : 水平标注文字位置：
                          0 = 在尺寸线上方并在尺寸界线之间居中对正 1 = 在尺寸线上方，靠近第一条尺寸界线 2 = 在尺寸线上方，靠近第二条尺寸界线
                          3 = 在第一条尺寸界线上方并居中对正 4 = 在第二条尺寸界线上方并居中对正

    $DIMLIM             : 非零时生成的标注界限
    $DIMLUNIT           : 为除角度之外的所有标注类型设置单位：1 = 科学；2 = 小数；3 = 工程；4 = 建筑；5 = 分数；6 = Windows 桌面
    $DIMLWD             : 尺寸线线宽：-3 = 标准  -2 = 随层 -1 = 随块  0-211 = 表示百分之几毫米的整数
    $DIMLWE             : 尺寸界线线宽： -3 = 标准 -2 = 随层 -1 = 随块 0-211 = 表示百分之几毫米的整数
    $DIMSAH             : 非零时使用单独的箭头块

    $DIMSD1             : 第一条尺寸界线的抑制情况：0 = 不抑制；1 = 抑制
    $DIMSD2             : 第二条尺寸界线的抑制情况：0 = 不抑制；1 = 抑制
    $DIMSE1             : 非零时抑制第一条尺寸界线
    $DIMSE2             : 非零时抑制第二条尺寸界线
    $DIMSHO             : 0 = 拖动原始图像 1 = 拖动时重新计算标注
    $DIMSOXD            : 非零时抑制位于尺寸界限之外的尺寸线
    $DIMTAD             : 非零时文字在尺寸线上方
    $DIMTDEC            : 显示公差值的小数位数
    $DIMTIH             : 非零时将文字水平放在内侧
    $DIMTIX             : 非零时将文字强制放在尺寸界线的内侧
    $DIMTMOVE           : 标注文字移动规则： 0 = 一起移动尺寸线与标注文字  1 = 移动标注文字时添加引线  2 = 允许自由移动箭头文字而不带引线
    $DIMTOFL            : 如果文字放在尺寸界线的外侧，非零时则强制在尺寸界线之间画直线
    $DIMTOH             : 非零时将文字水平放在外侧
    $DIMTOL             : 非零时生成标注公差
    $DIMTOLJ            : 公差值的垂直对正：
    $DIMTZIN            : 控制是否对公差值做消零处理： 0 = 抑制零英尺和精确零英寸 1 = 包含零英尺和精确零英寸 2 = 包含零英尺，抑制零英寸 3 = 包含零英寸，抑制零英尺
    $DIMUPT             : 用户定位文字的光标功能：0 = 仅控制尺寸线位置 1 = 控制文字位置和尺寸线位置
    $DIMZIN             : 控制是否对主单位值做消零处理： 0 = 抑制零英尺和精确零英寸 1 = 包含零英尺和精确零英寸 2 = 包含零英尺，抑制零英寸 3 = 包含零英寸，抑制零英尺
    $DISPSILH           : 控制“线框”模式下体对象轮廓曲线的显示： 0 = 关；1 = 开
    $FILLMODE           : 非零时启用填充模式
    $INSUNITS           : AutoCAD 设计中心块的默认图形单位：
                          0 = 无单位；1 = 英寸；2 = 英尺；3 = 英里；4 = 毫米；5 = 厘米；6 = 米；7 = 千米；8 = 微英寸；9 = 密耳；10 = 码；11 = 埃；12 = 纳米；
                          13 = 微米；14 = 分米；15 = 十米；16 = 百米；17 = 百万公里；18 = 天文单位；19 = 光年；20 = 秒差距

    $INTERSECTIONCOLOR  : 指定相交多段线的图元颜色：值 1-255 指定一个 AutoCAD 颜色索引 (ACI) 0 = 颜色随块 256 = 颜色随层 257 = 颜色随图元
    $LIMCHECK           : 如果打开了界限检查则为非零值
    $LUNITS             : 坐标和距离的单位格式
    $LUPREC             : 坐标和距离的单位精度
    $MAXACTVP           : 设置要重生成的视口的最大数目
    $MEASUREMENT        : 设置图形单位：0 = 英制；1 = 公制
    $MIRRTEXT           : 非零时镜像文字
    $OBSCOLOR           : 指定遮挡线的颜色。遮挡线是通过更改颜色和线型使其可见的隐藏线，并且仅在使用 HIDE 或 SHADEMODE 命令时才可见。
                          仅当 OBSCUREDLTYPE 的值设置为非 0，打开它时，OBSCUREDCOLOR 设置才可见。0 和 256 = 图元颜色 1-255 = AutoCAD 颜色索引 (ACI)

    $ORTHOMODE          : 非零时启用正交模式
    $PDMODE             : 点显示模式
    $PLIMCHECK          : 非零时图纸空间中的界限检查
    $PLINEGEN           : 控制二维多段线顶点周围的线型图案的生成：0 = 多段线的每段均起始和终止于划 1 = 在多段线顶点周围以连续图案生成线型
    $PROXYGRAPHICS      : 控制代理对象图像的保存
    $PSLTSCALE          : 控制图纸空间线型缩放：0 = 视口缩放控制线型缩放 1 = 没有特殊的线型缩放
    $PUCSORTHOVIEW      : 图纸空间 UCS 的正交视图类型 0 = UCS 不正交；1 = 俯视图；2 = 仰视图；3 = 主视图；4 = 后视图；5 = 左视图；6 = 右视图
    $QTEXTMODE          : 非零时启用“快速文字”模式
    $REGENMODE          : 非零时启用 REGENAUTO 模式
    $SHADEDGE           : 0 = 面着色，边不亮显 1 = 面着色，边以黑色亮显 2 = 面不填充，边显示图元颜色 3 = 面显示图元颜色，边显示黑色
    $SKPOLY             : 0 = 徒手画直线；1 = 徒手画多段线
    $SPLFRAME           : 样条曲线控制多边形显示：1 = 开；0 = 关
    $SPLINESEGS         : 每个样条曲线曲面的直线段数目
    $SPLINETYPE         : PEDIT 样条曲线的样条曲线类型
    $SURFTAB1           : 在第一个方向上的网格平移数目
    $SURFTAB2           : 在第二个方向上的网格平移数目
    $SURFTYPE           :PEDIT 平滑的曲面类型
    $SURFU              : 在 M 方向上的曲面密度（用于 PEDIT 平滑）
    $SURFV              : 在 N 方向上的曲面密度（用于 PEDIT 平滑）
    $TREEDEPTH          : 指定空间索引的最大深度
    $UNITMODE           : 低位集 = 按照输入的格式显示分数、英尺-英寸和勘测角度
    $VISRETAIN          : 0 = 不保留外部参照相关的可见性设置 1 = 保留外部参照相关的可见性设置
    $WORLDVIEW          ; // 1 = 在 DVIEW/VPOINT 期间，将 UCS 设置为 WCS



280:  ---------------------------------------------------------------------------------------------
    $CSHADOW  : 三维对象的阴影模式：0 = 投射和接收阴影 1 = 投射阴影 2 = 接收阴影 3 = 忽略阴影
    $DIMASSOC : 控制标注对象的关联性
                0 = 创建分解标注；标注的元素之间没有关联，并且直线、圆弧、箭头和标注文字作为独立对象进行绘制
                1 = 创建非关联标注对象；标注的元素形成一个对象，并且如果对象上的定义点进行了移动，则更新标注值
                2 = 创建关联标注对象；标注的元素形成一个对象，并且标注的一个或多个定义点与几何图形对象上的关联点相结合

    $ENDCAPS  : 新对象的线宽端面封口设置：0 = 无；1 = 圆形；2 = 角；3 = 方形
    $HALOGAP  : 指定在某一对象被另一对象隐藏处显示的间距；该值被指定为一种单位的百分数，并且不受缩放级别的影响。使用 HIDE 或 SHADEMODE 的 Hidden 选项时，在晕圈行的隐藏点处缩短晕圈行

    $INDEXCTL : 控制是否在图形文件中创建和保存图层索引和空间索引：
                0 = 不创建索引
                1 = 创建图层索引
                2 = 创建空间索引
                3 = 创建图层索引和空间索引



    $JOINSTYLE: 新对象的线宽连接设置：0 = 无；1 = 圆形；2 = 角；3 = 扁平

    $OBSLTYPE : 指定遮挡线的线型。与通常的 AutoCAD 线型不同，遮挡线的线型不受缩放级别的影响。默认值，即 0 值，将关闭遮挡线的显示。对线型值进行如下定义：
                0 = 关
                1 = 实线
                2 =划
                3 = 点
                4 = 短划
                5 = 中划
                6 = 长划
                7 = 双短划
                8 = 双中划
                9 = 双长划
                10 = 中长划
                11 = 稀疏点


    $SORTENTS : 控制对象的排序方式；可从通过“选项”对话框的“用户系统配置”选项卡访问。SORTENTS 使用以下位码：
                0 = 禁用 SORTENTS
                1 = 为对象选择排序
                2 = 为对象捕捉排序
                4 = 为重画排序
                8 = 为 MSLIDE 命令幻灯片创建排序
                16 = 为 REGEN 命令排序
                32 = 为打印排序
                64 = 为 PostScript 输出排序




290:  ---------------------------------------------------------------------------------------------
    $INTERSECTIONDISPLAY : 指定是否显示相交多段线：0 = 不显示相交多段线 1 = 显示相交多段线
    $LWDISPLAY           : 控制“模型”选项卡或“布局”选项卡中线宽的显示：0 = 不显示线宽 1 = 显示线宽
    $PSTYLEMODE          : 指明当前图形处于“颜色相关”模式还是“命名打印样式”模式：0 = 在当前图形中使用命名打印样式表 1 = 在当前图形中使用颜色相关打印样式表
    $XCLIPFRAME          : 控制外部参照剪裁边界的可见性：0 = 剪裁边界不可见 1 = 剪裁边界可见
    $XEDIT               : 控制当前图形被其他图形参照时是否可以在位编辑。0 = 不能使用在位参照编辑 1 = 可以使用在位参照编辑

*)



//==================================================================================================
{ TUdDxfReadHeader }



function _GetCadVer(AValue: string): string;
begin
  Result := 'DXF.CUSTOM';  //Custom
  if AValue = 'AC1024' then Result := 'DXF2010' else
  if AValue = 'AC1021' then Result := 'DXF2007' else
  if AValue = 'AC1018' then Result := 'DXF2004' else
  if AValue = 'AC1015' then Result := 'DXF2000' else
  if AValue = 'AC1014' then Result := 'DXF14'   else
  if AValue = 'AC1012' then Result := 'DXF13'   else
  if AValue = 'AC1009' then Result := 'DXF11'   else
  if AValue = 'AC1006' then Result := 'DXF10';
end;


procedure TUdDxfReadHeader.Execute();
var
  N: Integer;
  LStr: string;
  LRecord: TUdDxfRecord;
  LHandSeed: string;
  LLimMin, LLimMax, LExtMin, LExtMax, LInsBase: TPoint2D;
begin
  FDxfVer := '';
  FActiveDimStyle := '';
  FActiveLineType := '';
  FActiveTextStyle := '';
  FActiveLayer := '';
  FActiveColor := 256;
  FActiveLineWeight := -1;
  FSortEntsFlag := 0;

  LStr := '';
  LHandSeed := '';
  LLimMin.X  := 0; LLimMin.Y  := 0;
  LLimMax.X  := 0; LLimMax.Y  := 0;
  LExtMin.X  := 0; LExtMin.Y  := 0;
  LExtMax.X  := 0; LExtMax.Y  := 0;
  LInsBase.X := 0; LInsBase.Y := 0;

  LRecord := Self.ReadRecord();
  repeat
    case LRecord.Code of
      0:
        begin
          if LRecord.Value = 'ENDSEC' then Break;
        end;

      1:
        begin
          if LStr = '$ACADVER'  then FDxfVer := _GetCadVer(LRecord.Value) else
          if LStr = '$TITLE'    then {Self.Document.FileProperties.AddItem('TITLE=' + LRecord.Value)   } else
          if LStr = '$SUBJECT'  then {Self.Document.FileProperties.AddItem('SUBJECT=' + LRecord.Value) } else
          if LStr = '$AUTHOR'   then {Self.Document.FileProperties.AddItem('AUTHOR=' + LRecord.Value)  } else
          if LStr = '$KEYWORDS' then {Self.Document.FileProperties.AddItem('KEYWORDS=' + LRecord.Value)} else
          if LStr = '$COMMENTS' then {Self.Document.FileProperties.AddItem('COMMENTS=' + LRecord.Value)}  ;
        end;

      2:
        begin
          if LStr = '$DIMSTYLE' then FActiveDimStyle := LRecord.Value;
          {
          $CMLSTYLE       : 当前多线样式名称

          $UCSBASE        : 定义正交 UCS 设置的原点和方向的 UCS 名称
          $UCSNAME        : 当前 UCS 的名称
          $UCSORTHOREF    : 如果模型空间 UCS 为正交（UCSORTHOVIEW 不等于 0），该名称即为与正交 UCS 相关的 UCS 的名称。如果为空，则 UCS 与 WORLD 相关

          $PUCSBASE       : 定义正交 UCS 设置（仅用于图纸空间）的原点和方向的 UCS 名称。
          $PUCSNAME       : 当前图纸空间 UCS 名称
          $PUCSORTHOREF   : 如果图纸空间 UCS 为正交（PUCSORTHOVIEW 不等于 0），该名称即为与正交 UCS 相关的 UCS 的名称。如果为空，则 UCS 与 WORLD 相关

          $FINGERPRINTGUID: 在创建时设置，用于唯一标识特定图形
          $VERSIONGUID    : 唯一标识图形的特定版本。修改图形时更新
          }
        end;

      3:
        begin
          if LStr = '$DWGCODEPAGE' then {... ...} ;
        end;

      5:
        begin
          if LStr = '$HANDSEED' then LHandSeed := LRecord.Value ;
        end;

      6:
        begin
          if LStr = '$CELTYPE' then FActiveLineType := LRecord.Value;
        end;

      7:
        begin
          if LStr = '$TEXTSTYLE' then FActiveTextStyle := LRecord.Value;
        end;

      8:
        begin
          if LStr = '$CLAYER' then FActiveLayer := LRecord.Value;
        end;

      9:
        begin
          LStr := LRecord.Value;
        end;

      10:
        begin
          if LStr =  '$LIMMIN'  then LLimMin.X  := StrToFloatDef(LRecord.Value, 0) else
          if LStr =  '$LIMMAX'  then LLimMax.X  := StrToFloatDef(LRecord.Value, 0) else
          if LStr =  '$EXTMIN'  then LExtMin.X  := StrToFloatDef(LRecord.Value, 0) else
          if LStr =  '$EXTMAX'  then LExtMin.X  := StrToFloatDef(LRecord.Value, 0) else
          if LStr =  '$INSBASE' then LInsBase.X := StrToFloatDef(LRecord.Value, 0) else

          if LStr =  '$PLIMMIN'  then {LPLimMin.X  := StrToFloatDef(LRecord.Value)} else
          if LStr =  '$PLIMMAX'  then {LPLimMax.X  := StrToFloatDef(LRecord.Value)} else
          if LStr =  '$PEXTMIN'  then {LPExtMin.X  := StrToFloatDef(LRecord.Value)} else
          if LStr =  '$PEXTMAX'  then {LPExtMin.X  := StrToFloatDef(LRecord.Value)} ;
        end;

      20:
        begin
          if LStr =  '$LIMMIN'  then LLimMin.Y  := StrToFloatDef(LRecord.Value, 0) else
          if LStr =  '$LIMMAX'  then LLimMax.Y  := StrToFloatDef(LRecord.Value, 0) else
          if LStr =  '$EXTMIN'  then LExtMin.Y  := StrToFloatDef(LRecord.Value, 0) else
          if LStr =  '$EXTMAX'  then LExtMin.Y  := StrToFloatDef(LRecord.Value, 0) else
          if LStr =  '$INSBASE' then LInsBase.Y := StrToFloatDef(LRecord.Value, 0) else

          if LStr =  '$PLIMMIN'  then {LPLimMin.Y  := StrToFloatDef(LRecord.Value)} else
          if LStr =  '$PLIMMAX'  then {LPLimMax.Y  := StrToFloatDef(LRecord.Value)} else
          if LStr =  '$PEXTMIN'  then {LPExtMin.Y  := StrToFloatDef(LRecord.Value)} else
          if LStr =  '$PEXTMAX'  then {LPExtMin.Y  := StrToFloatDef(LRecord.Value)} ;
        end;

      30:
        begin
          //....
        end;

      40:
        begin
          if LStr = '$LTSCALE'    then Self.Document.LineTypes.GlobalScale  := StrToFloatDef(LRecord.Value, 1.0) else
          if LStr = '$CELTSCALE'  then Self.Document.LineTypes.CurrentScale := StrToFloatDef(LRecord.Value, 1.0) else
          if LStr = '$PDSIZE'     then Self.Document.PointStyle.Size := StrToFloatDef(LRecord.Value, -1.0) else
          if LStr = '$TEXTSIZE'   then Self.Document.TextStyles.Active.Height := StrToFloatDef(LRecord.Value, -1.0)  else

          if LStr = '$DIMASZ'     then Self.Document.DimStyles.Active.ArrowsProp.ArrowSize := StrToFloatDef(LRecord.Value, -1.0) else
          if LStr = '$DIMCEN'     then Self.Document.DimStyles.Active.ArrowsProp.MarkSize  := StrToFloatDef(LRecord.Value, -1.0) else
          if LStr = '$DIMDLE'     then Self.Document.DimStyles.Active.LinesProp.ExtBeyondTicks := Round(StrToFloatDef(LRecord.Value, 0.0))  else
          if LStr = '$DIMDLI'     then Self.Document.DimStyles.Active.LinesProp.BaselineSpacing := StrToFloatDef(LRecord.Value, -1.0) else
          if LStr = '$DIMEXE'     then Self.Document.DimStyles.Active.LinesProp.ExtBeyondDimLines := StrToFloatDef(LRecord.Value, -1.0) else // 尺寸界线延伸
          if LStr = '$DIMEXO'     then Self.Document.DimStyles.Active.LinesProp.ExtOriginOffset   := StrToFloatDef(LRecord.Value, -1.0) else // 尺寸界线偏移

          {
          if LStr = '$DIMLFAC'    then  else // 线性测量的比例因子
          if LStr = '$DIMRND'     then  else // 标注距离的舍入值
          if LStr = '$DIMSCALE'   then  else // 全局标注比例因子
          if LStr = '$DIMTFAC'    then  else // 标注公差显示比例因子
          if LStr = '$DIMTM'      then  else // 下偏差
          if LStr = '$DIMTP'      then  else // 上偏差
          if LStr = '$DIMTSZ'     then  else // 标注标记大小： 0 = 无标记
          if LStr = '$DIMTVP'     then  else // 文字的垂直位置
          if LStr = '$DIMTXT'     then  else // 标注文字高度

          if LStr = '$DIMGAP'     then  else // 尺寸线间距
          if LStr = '$DIMALTF'    then  else // 换算单位比例因子
          if LStr = '$DIMALTRND'  then  else // 确定换算单位的舍入值
          if LStr = '$DIMFAC'     then  else // 用于计算标注分数和公差的文字高度的比例因子。AutoCAD 将 DIMTFAC 与 DIMTXT 相乘，以设置分数或公差的文字高度

          if LStr = '$CHAMFERA'   then  else // 第一个倒角距离
          if LStr = '$CHAMFERB'   then  else // 第二个倒角距离
          if LStr = '$CHAMFERC'   then  else // 倒角长度
          if LStr = '$CHAMFERD'   then  else // 倒角角度
          if LStr = '$FILLETRAD'  then  else // 圆角半径

          if LStr = '$CMLSCALE'   then  else // 当前多线比例
          if LStr = '$TRACEWID'   then  else // 默认宽线宽度
          if LStr = '$PLINEWID'   then  else // 默认的多段线宽度
          if LStr = '$PSVPSCALE'  then  else // 查看新视口的比例因子：0= 按图纸空间缩放  >0 = 比例因子（正实数值）

          if LStr = '$PELEVATION' then  else // 当前图纸空间标高
          if LStr = '$ELEVATION'  then  else // 由 ELEV 命令设置的当前标高
          if LStr = '$THICKNESS'  then  else // 由 ELEV 命令设置的当前厚度
          if LStr = '$SKETCHINC'  then  else // 徒手画记录增量
          if LStr = '$TDCREATE'   then  else // 创建图形的本地日期/时间（参见日期/时间变量的特殊处理）
          if LStr = '$TDINDWG'    then  else // 此图形的累计编辑时间（参见日期/时间变量的特殊处理）
          if LStr = '$TDUCREATE'  then  else // 创建图形的通用日期/时间（参见日期/时间变量的特殊处理）
          if LStr = '$TDUPDATE'   then  else // 上次更新图形的本地日期/时间（参见日期/时间变量的特殊处理）
          if LStr = '$TDUSRTIMER' then  else // 用户消耗时间计时器
          if LStr = '$TDUUPDATE'  then  else  // 上次更新/保存图形的通用日期/时间（参见日期/时间变量的特殊处理）
          if LStr = '$SHADOWPLANELOCATION'then  else // 地面阴影平面的位置。这是 Z 轴坐标。
          }
        end;

      50:
        begin
          if LStr = '$ANGBASE' then Self.Document.Units.AngBase := StrToFloatDef(LRecord.Value, 0.0); //0角度方向
        end;

      62:
        begin
          if LStr = '$CECOLOR' then FActiveColor := StrToIntDef(LRecord.Value, 256) else //当前图元颜色号：0 = 随块；256 = 随层
          if LStr = '$INTERFERECOLOR' then ; //表示在执行干涉命令期间创建的“干涉对象”的 ACI 颜色索引。默认值为 1
        end;

      70:
        begin
          if LStr = '$ORTHOMODE'        then Self.Document.ModelSpace.OrthoOn := StrToBoolDef(LRecord.Value, False) else
          if LStr = '$PDMODE'           then Self.Document.PointStyle.Mode := StrToIntDef(LRecord.Value, 0) else


          if LStr = '$ANGDIR'           then Self.Document.Units.AngClockWise := StrToBoolDef(LRecord.Value, False) else

          // 角度的单位格式
          if LStr = '$AUNITS'           then
          begin
            N := StrToIntDef(LRecord.Value, 0);
            if N < 5 then Self.Document.Units.AngUnit := TUdAngleUnit(N);
          end else
          if LStr = '$AUPREC'           then Self.Document.Units.AngPrecision := StrToIntDef(LRecord.Value, 0) else

          // 坐标和距离的单位格式
          if LStr = '$LUNITS'           then
          begin
            N := StrToIntDef(LRecord.Value, 2);  if N = 6 then N := 2;
            N := N - 1;
            if N < 5 then Self.Document.Units.LenUnit := TUdLengthUnit(N);
          end else
          if LStr = '$LUPREC'           then Self.Document.Units.LenPrecision := StrToIntDef(LRecord.Value, 0) else

          // 角度标注的角度格式
          if LStr = '$DIMAUNIT'         then
          begin
            N := StrToIntDef(LRecord.Value, 0);
            if N < 5 then Self.Document.DimStyles.Active.UnitsProp.AngUnitFormat := TUdAngleUnit(N);
          end else
          if LStr = '$DIMAZIN'          then
          begin
            N := StrToIntDef(LRecord.Value, 0);
            Self.Document.DimStyles.Active.UnitsProp.AngSuppressLeading  := (N and 1) > 0;
            Self.Document.DimStyles.Active.UnitsProp.AngSuppressTrailing := (N and 2) > 0;
          end else
          if LStr = '$DIMADEC'          then Self.Document.DimStyles.Active.UnitsProp.AngPrecision := StrToIntDef(LRecord.Value, 0) else // 角度标注中显示的精度位的位数

          // 所有标注样式族成员（角度标注除外）的换算单位的单位格式
          if LStr = '$DIMLUNIT'         then
          begin
            N := StrToIntDef(LRecord.Value, 2);  if N = 6 then N := 2;
            N := N - 1;
            if N < 5 then Self.Document.DimStyles.Active.UnitsProp.UnitFormat := TUdLengthUnit(N);
          end else
          if LStr = '$DIMALTZ'      then
          begin
            N := StrToIntDef(LRecord.Value, 0);
            Self.Document.DimStyles.Active.UnitsProp.SuppressLeading  := (N and 1) > 0;
            Self.Document.DimStyles.Active.UnitsProp.SuppressTrailing := (N and 2) > 0;
          end else
          if LStr = '$DIMDEC'           then Self.Document.DimStyles.Active.UnitsProp.Precision := StrToIntDef(LRecord.Value, 0) else
          if LStr = '$DIMDSEP'          then Self.Document.DimStyles.Active.UnitsProp.Decimal := Chr(StrToIntDef(LRecord.Value, 44)) else

          // 尺寸线
          if LStr = '$DIMCLRD'          then SetDxfColor(Self.Document, Self.Document.DimStyles.Active.LinesProp.Color, LRecord.Value) else
          if LStr = '$DIMCLRE'          then SetDxfColor(Self.Document, Self.Document.DimStyles.Active.LinesProp.ExtColor, LRecord.Value) else
          if LStr = '$DIMSD1'           then  else // 第一条尺寸界线的抑制情况：0 = 不抑制；1 = 抑制
          if LStr = '$DIMSD2'           then  else // 第二条尺寸界线的抑制情况：0 = 不抑制；1 = 抑制
          if LStr = '$DIMSE1'           then  else // 非零时抑制第一条尺寸界线
          if LStr = '$DIMSE2'           then  else // 非零时抑制第二条尺寸界线
          if LStr = '$DIMLWD'           then  else // 尺寸线线宽：-3 = 标准  -2 = 随层 -1 = 随块  0-211 = 表示百分之几毫米的整数
          if LStr = '$DIMLWE'           then  else // 尺寸界线线宽： -3 = 标准 -2 = 随层 -1 = 随块 0-211 = 表示百分之几毫米的整数


          //标注文字
          if LStr = '$DIMCLRT'          then SetDxfColor(Self.Document, Self.Document.DimStyles.Active.TextProp.TextColor, LRecord.Value) else
          if LStr = '$DIMJUST'          then
          begin
            N := StrToIntDef(LRecord.Value, 0); if N > 2 then N := 0;
            Self.Document.DimStyles.Active.TextProp.HorizontalPosition := TUdHorizontalTextPoint(N);
          end else
          if LStr = '$DIMTAD'           then
          begin
            N := StrToIntDef(LRecord.Value, 1);
            if N <> 0 then Self.Document.DimStyles.Active.TextProp.VerticalPosition := vtpAbove else
                           Self.Document.DimStyles.Active.TextProp.VerticalPosition := vtpCentered;
          end else

          if LStr = '$DIMSOXD'          then  else // 非零时抑制位于尺寸界限之外的尺寸线
          if LStr = '$DIMTIH'           then  else // 非零时将文字水平放在内侧
          if LStr = '$DIMTOH'           then  else // 非零时将文字水平放在外侧
          if LStr = '$DIMTIX'           then  ;//  // 非零时将文字强制放在尺寸界线的内侧

          {
          if LStr = '$DIMSHO'           then  else // 0 = 拖动原始图像 1 = 拖动时重新计算标注
          if LStr = '$DIMUPT'           then  else // 用户定位文字的光标功能：0 = 仅控制尺寸线位置 1 = 控制文字位置和尺寸线位置
          if LStr = '$DIMZIN'           then  else // 控制是否对主单位值做消零处理： 0 = 抑制零英尺和精确零英寸 1 = 包含零英尺和精确零英寸 2 = 包含零英尺，抑制零英寸 3 = 包含零英寸，抑制零英尺
          if LStr = '$DISPSILH'         then  else // 控制“线框”模式下体对象轮廓曲线的显示： 0 = 关；1 = 开
          if LStr = '$FILLMODE'         then  else // 非零时启用填充模式

          if LStr = '$DIMLIM'           then  else // 非零时生成的标注界限
          if LStr = '$DIMSAH'           then  else // 非零时使用单独的箭头块

          if LStr = '$DIMTMOVE'         then  else // 标注文字移动规则： 0 = 一起移动尺寸线与标注文字  1 = 移动标注文字时添加引线  2 = 允许自由移动箭头文字而不带引线
          if LStr = '$DIMTOFL'          then  else // 如果文字放在尺寸界线的外侧，非零时则强制在尺寸界线之间画直线

          if LStr = '$DIMALT'           then  else // 非零时执行的换算单位标注
          if LStr = '$DIMALTD'          then  else // 换算单位小数位


          if LStr = '$DIMASO'           then  else // 0 = 绘制单个图元 1 = 创建关联标注
          if LStr = '$DIMATFIT'         then  else // 在尺寸界线内没有足够的空间放置标注文字和箭头时，控制两者的位置：
                              //0 = 将文字和箭头放置在尺寸界线外 1 = 首先移动箭头，然后移动文字 2 = 首先移动文字，然后移动箭头 3 = 移动文字和箭头中较合适的一个
                              //如果 DIMTMOVE 设置为 1，AutoCAD 将为被移动的标注文字添加一条引线


          if LStr = '$DIMALTTD'         then  else // 换算单位标注的公差值的小数位数
          if LStr = '$DIMALTTZ'         then  else // 控制是否对换算公差值做消零处理：
                              //0 = 抑制零英尺和精确零英寸  1 = 包含零英尺和精确零英寸  2 = 包含零英尺，抑制零英寸  3 = 包含零英寸，抑制零英尺
          if LStr = '$DIMTOL'           then  else // 非零时生成标注公差
          if LStr = '$DIMTOLJ'          then  else // 公差值的垂直对正：
          if LStr = '$DIMTZIN'          then  else // 控制是否对公差值做消零处理： 0 = 抑制零英尺和精确零英寸 1 = 包含零英尺和精确零英寸 2 = 包含零英尺，抑制零英寸 3 = 包含零英寸，抑制零英尺


          if LStr = '$ATTMODE'          then  else // 属性的可见性：0 = 无 1 = 普通 2 = 全部
          if LStr = '$CMLJUST'          then  else // 当前多线对正： 0 = 顶端对正；1 = 居中对正；2 = 底端对正

          if LStr = '$INSUNITS'         then  else // AutoCAD 设计中心块的默认图形单位：
                              //0 = 无单位；1 = 英寸；2 = 英尺；3 = 英里；4 = 毫米；5 = 厘米；6 = 米；7 = 千米；8 = 微英寸；9 = 密耳；10 = 码；11 = 埃；12 = 纳米；
                              //13 = 微米；14 = 分米；15 = 十米；16 = 百米；17 = 百万公里；18 = 天文单位；19 = 光年；20 = 秒差距

          if LStr = '$INTERSECTIONCOLOR'then  else // 指定相交多段线的图元颜色：值 1-255 指定一个 AutoCAD 颜色索引 (ACI) 0 = 颜色随块 256 = 颜色随层 257 = 颜色随图元
          if LStr = '$LIMCHECK'         then  else // 如果打开了界限检查则为非零值
          if LStr = '$MAXACTVP'         then  else // 设置要重生成的视口的最大数目
          if LStr = '$MEASUREMENT'      then  else // 设置图形单位：0 = 英制；1 = 公制
          if LStr = '$MIRRTEXT'         then  else // 非零时镜像文字
          if LStr = '$OBSCOLOR'         then  else // 指定遮挡线的颜色。遮挡线是通过更改颜色和线型使其可见的隐藏线，并且仅在使用 HIDE 或 SHADEMODE 命令时才可见。
                              //仅当 OBSCUREDLTYPE 的值设置为非 0，打开它时，OBSCUREDCOLOR 设置才可见。0 和 256 = 图元颜色 1-255 = AutoCAD 颜色索引 (ACI)


          if LStr = '$PLIMCHECK'        then  else // 非零时图纸空间中的界限检查
          if LStr = '$PLINEGEN'         then  else // 控制二维多段线顶点周围的线型图案的生成：0 = 多段线的每段均起始和终止于划 1 = 在多段线顶点周围以连续图案生成线型
          if LStr = '$PROXYGRAPHICS'    then  else // 控制代理对象图像的保存
          if LStr = '$PSLTSCALE'        then  else // 控制图纸空间线型缩放：0 = 视口缩放控制线型缩放 1 = 没有特殊的线型缩放
          if LStr = '$PUCSORTHOVIEW'    then  else // 图纸空间 UCS 的正交视图类型 0 = UCS 不正交；1 = 俯视图；2 = 仰视图；3 = 主视图；4 = 后视图；5 = 左视图；6 = 右视图
          if LStr = '$QTEXTMODE'        then  else // 非零时启用“快速文字”模式
          if LStr = '$REGENMODE'        then  else // 非零时启用 REGENAUTO 模式
          if LStr = '$SHADEDGE'         then  else // 0 = 面着色，边不亮显 1 = 面着色，边以黑色亮显 2 = 面不填充，边显示图元颜色 3 = 面显示图元颜色，边显示黑色
          if LStr = '$SKPOLY'           then  else // 0 = 徒手画直线；1 = 徒手画多段线
          if LStr = '$SPLFRAME'         then  else // 样条曲线控制多边形显示：1 = 开；0 = 关
          if LStr = '$SPLINESEGS'       then  else // 每个样条曲线曲面的直线段数目
          if LStr = '$SPLINETYPE'       then  else // PEDIT 样条曲线的样条曲线类型
          if LStr = '$SURFTAB1'         then  else // 在第一个方向上的网格平移数目
          if LStr = '$SURFTAB2'         then  else // 在第二个方向上的网格平移数目
          if LStr = '$SURFTYPE'         then  else //PEDIT 平滑的曲面类型
          if LStr = '$SURFU'            then  else // 在 M 方向上的曲面密度（用于 PEDIT 平滑）
          if LStr = '$SURFV'            then  else // 在 N 方向上的曲面密度（用于 PEDIT 平滑）
          if LStr = '$TREEDEPTH'        then  else // 指定空间索引的最大深度
          if LStr = '$UNITMODE'         then  else // 低位集 = 按照输入的格式显示分数、英尺-英寸和勘测角度
          if LStr = '$VISRETAIN'        then  else // 0 = 不保留外部参照相关的可见性设置 1 = 保留外部参照相关的可见性设置
          if LStr = '$WORLDVIEW'        then  ; // 1 = 在 DVIEW/VPOINT 期间，将 UCS 设置为 WCS
          }
        end;

      280:
        begin
          if LStr = '$SORTENTS' then FSortEntsFlag := StrToIntDef(LRecord.Value, 0);
          {
          0 = 禁用 SORTENTS
          1 = 为对象选择排序
          2 = 为对象捕捉排序
          4 = 为重画排序
          8 = 为 MSLIDE 命令幻灯片创建排序
          16 = 为 REGEN 命令排序
          32 = 为打印排序
          64 = 为 PostScript 输出排序
          }
        end;

      290:
        begin
          if LStr = '$LWDISPLAY' then Self.Document.ModelSpace.LwtDisp := StrToBoolDef(LRecord.Value, False);
        end;

      370: if LStr = '$CELWEIGHT' then FActiveLineWeight := StrToIntDef(LRecord.Value, -1);
      380: ;// $CEPSNTYPE 新对象的打印样式类型：0 = 随层打印样式 1 = 随块打印样式 2 = 随默认词典打印样式 3 = 随对象 ID/句柄打印样式
      390: ;// $CEPSNID   新对象的打印样式句柄。如果 CEPSNTYPE 为 3，则此值代表该句柄
    end;


    LRecord := Self.ReadRecord();
  until (LRecord.Value = 'ENDSEC') or (LRecord.Value = 'EOF');

  Self.Document.ModelSpace.Axes.LimRect := UdGeo2D.Rect2D(LLimMin, LLimMax);
end;







end.