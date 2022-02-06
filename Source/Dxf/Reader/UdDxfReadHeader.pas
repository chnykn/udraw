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
    $LTSCALE            : ȫ�����ͱ���
    $CELTSCALE          : ��ǰͼԪ���ͱ���

    $PDSIZE             : ����ʾ�ߴ�
    $TEXTSIZE           : Ĭ�����ָ߶�
    $TRACEWID           : Ĭ�Ͽ��߿��
    $CMLSCALE           : ��ǰ���߱���

    $PELEVATION         : ��ǰͼֽ�ռ���
    $PLINEWID           : Ĭ�ϵĶ���߿��
    $PSVPSCALE          : �鿴���ӿڵı������ӣ�0= ��ͼֽ�ռ�����  >0 = �������ӣ���ʵ��ֵ��

    $CHAMFERA           : ��һ�����Ǿ���
    $CHAMFERB           : �ڶ������Ǿ���
    $CHAMFERC           : ���ǳ���
    $CHAMFERD           : ���ǽǶ�
    $FILLETRAD          : Բ�ǰ뾶



    $DIMALTF            : ���㵥λ��������
    $DIMALTRND          : ȷ�����㵥λ������ֵ
    $DIMASZ             : ��ע��ͷ�ߴ�
    $DIMCEN             : ���ı��/�����ߵĴ�С
    $DIMDLE             : �ߴ��߳����ߴ���ߵľ���
    $DIMDLI             : �ߴ�������
    $DIMEXE             : �ߴ��������
    $DIMEXO             : �ߴ����ƫ��
    $DIMFAC             : ���ڼ����ע�����͹�������ָ߶ȵı������ӡ�AutoCAD �� DIMTFAC �� DIMTXT ��ˣ������÷����򹫲�����ָ߶�
    $DIMGAP             : �ߴ��߼��
    $DIMLFAC            : ���Բ����ı�������
    $DIMRND             : ��ע���������ֵ
    $DIMSCALE           : ȫ�ֱ�ע��������
    $DIMTFAC            : ��ע������ʾ��������
    $DIMTM              : ��ƫ��
    $DIMTP              : ��ƫ��
    $DIMTSZ             : ��ע��Ǵ�С�� 0 = �ޱ��
    $DIMTVP             : ���ֵĴ�ֱλ��
    $DIMTXT             : ��ע���ָ߶�


    $ELEVATION          : �� ELEV �������õĵ�ǰ���
    $THICKNESS          : �� ELEV �������õĵ�ǰ���
    $SHADOWPLANELOCATION: ������Ӱƽ���λ�á����� Z �����ꡣ
    $SKETCHINC          : ͽ�ֻ���¼����
    $TDCREATE           : ����ͼ�εı�������/ʱ�䣨�μ�����/ʱ����������⴦��
    $TDINDWG            : ��ͼ�ε��ۼƱ༭ʱ�䣨�μ�����/ʱ����������⴦��
    $TDUCREATE          : ����ͼ�ε�ͨ������/ʱ�䣨�μ�����/ʱ����������⴦��
    $TDUPDATE           : �ϴθ���ͼ�εı�������/ʱ�䣨�μ�����/ʱ����������⴦��
    $TDUSRTIMER         : �û�����ʱ���ʱ��
    $TDUUPDATE          : �ϴθ���/����ͼ�ε�ͨ������/ʱ�䣨�μ�����/ʱ����������⴦��



70:  ---------------------------------------------------------------------------------------------
    $ATTMODE            : ���ԵĿɼ��ԣ�0 = �� 1 = ��ͨ 2 = ȫ��


    $ANGDIR             : 0 = ��ʱ��Ƕ� 1 = ˳ʱ��Ƕ�
    $AUNITS              �Ƕȵĵ�λ��ʽ


    $AUPREC             : �Ƕȵĵ�λ����

    $CMLJUST            : ��ǰ���߶����� 0 = ���˶�����1 = ���ж�����2 = �׶˶���
    $DIMADEC            : �Ƕȱ�ע����ʾ�ľ���λ��λ��
    $DIMALT             : ����ʱִ�еĻ��㵥λ��ע
    $DIMALTD            : ���㵥λС��λ
    $DIMALTTD           : ���㵥λ��ע�Ĺ���ֵ��С��λ��
    $DIMALTTZ           : �����Ƿ�Ի��㹫��ֵ�����㴦��
                          0 = ������Ӣ�ߺ;�ȷ��Ӣ��  1 = ������Ӣ�ߺ;�ȷ��Ӣ��  2 = ������Ӣ�ߣ�������Ӣ��  3 = ������Ӣ�磬������Ӣ��

    $DIMALTU            : ���б�ע��ʽ���Ա���Ƕȱ�ע���⣩�Ļ��㵥λ�ĵ�λ��ʽ��
                          1 = ��ѧ��2 = С����3 = ���̣� 4 = �������ѵ�����5 = �������ѵ�����6 = ������7 = ����

    $DIMALTZ            : �����Ƿ�Ի��㵥λ��עֵ�����㴦��
                          0 = ������Ӣ�ߺ;�ȷ��Ӣ�� 1 = ������Ӣ�ߺ;�ȷ��Ӣ��2 = ������Ӣ�ߣ�������Ӣ�� 3 = ������Ӣ�磬������Ӣ��

    $DIMASO             : 0 = ���Ƶ���ͼԪ 1 = ����������ע
    $DIMATFIT           : �ڳߴ������û���㹻�Ŀռ���ñ�ע���ֺͼ�ͷʱ���������ߵ�λ�ã�
                          0 = �����ֺͼ�ͷ�����ڳߴ������ 1 = �����ƶ���ͷ��Ȼ���ƶ����� 2 = �����ƶ����֣�Ȼ���ƶ���ͷ 3 = �ƶ����ֺͼ�ͷ�нϺ��ʵ�һ��
                          ��� DIMTMOVE ����Ϊ 1��AutoCAD ��Ϊ���ƶ��ı�ע�������һ������

    $DIMAUNIT           : �Ƕȱ�ע�ĽǶȸ�ʽ�� 0 = ʮ���ƶ�����1 = ��/��/�룻 2 = �ٷֶȣ�3 = ���ȣ�4 = ���ⵥλ
    $DIMAZIN            : ���ƶԽǶȱ�ע�����㴦��
                          0 = ��ʾ����ǰ����ͺ�����  1 = ��ȥʮ���Ʊ�ע�е�ǰ����  2 = ��ȥʮ���Ʊ�ע�еĺ����� 3 = ��ȥǰ����ͺ�����

    $DIMCLRD            : �ߴ�����ɫ����Χ�� 0 = ��飻256 = ���
    $DIMCLRE            : �ߴ������ɫ�� ��Χ�ǣ�0 = ��飻256 = ���
    $DIMCLRT            : ��ע���ֵ���ɫ�� ��Χ�ǣ�0 = ��飻256 = ���
    $DIMDEC             : ����λ��ע�Ĺ���ֵ��С��λ��
    $DIMDSEP            : ������λ��ʽΪС���ı�עʱʹ�õĵ��ַ�С���ָ���
    $DIMJUST            : ˮƽ��ע����λ�ã�
                          0 = �ڳߴ����Ϸ����ڳߴ����֮����ж��� 1 = �ڳߴ����Ϸ���������һ���ߴ���� 2 = �ڳߴ����Ϸ��������ڶ����ߴ����
                          3 = �ڵ�һ���ߴ�����Ϸ������ж��� 4 = �ڵڶ����ߴ�����Ϸ������ж���

    $DIMLIM             : ����ʱ���ɵı�ע����
    $DIMLUNIT           : Ϊ���Ƕ�֮������б�ע�������õ�λ��1 = ��ѧ��2 = С����3 = ���̣�4 = ������5 = ������6 = Windows ����
    $DIMLWD             : �ߴ����߿�-3 = ��׼  -2 = ��� -1 = ���  0-211 = ��ʾ�ٷ�֮�����׵�����
    $DIMLWE             : �ߴ�����߿� -3 = ��׼ -2 = ��� -1 = ��� 0-211 = ��ʾ�ٷ�֮�����׵�����
    $DIMSAH             : ����ʱʹ�õ����ļ�ͷ��

    $DIMSD1             : ��һ���ߴ���ߵ����������0 = �����ƣ�1 = ����
    $DIMSD2             : �ڶ����ߴ���ߵ����������0 = �����ƣ�1 = ����
    $DIMSE1             : ����ʱ���Ƶ�һ���ߴ����
    $DIMSE2             : ����ʱ���Ƶڶ����ߴ����
    $DIMSHO             : 0 = �϶�ԭʼͼ�� 1 = �϶�ʱ���¼����ע
    $DIMSOXD            : ����ʱ����λ�ڳߴ����֮��ĳߴ���
    $DIMTAD             : ����ʱ�����ڳߴ����Ϸ�
    $DIMTDEC            : ��ʾ����ֵ��С��λ��
    $DIMTIH             : ����ʱ������ˮƽ�����ڲ�
    $DIMTIX             : ����ʱ������ǿ�Ʒ��ڳߴ���ߵ��ڲ�
    $DIMTMOVE           : ��ע�����ƶ����� 0 = һ���ƶ��ߴ������ע����  1 = �ƶ���ע����ʱ�������  2 = ���������ƶ���ͷ���ֶ���������
    $DIMTOFL            : ������ַ��ڳߴ���ߵ���࣬����ʱ��ǿ���ڳߴ����֮�仭ֱ��
    $DIMTOH             : ����ʱ������ˮƽ�������
    $DIMTOL             : ����ʱ���ɱ�ע����
    $DIMTOLJ            : ����ֵ�Ĵ�ֱ������
    $DIMTZIN            : �����Ƿ�Թ���ֵ�����㴦�� 0 = ������Ӣ�ߺ;�ȷ��Ӣ�� 1 = ������Ӣ�ߺ;�ȷ��Ӣ�� 2 = ������Ӣ�ߣ�������Ӣ�� 3 = ������Ӣ�磬������Ӣ��
    $DIMUPT             : �û���λ���ֵĹ�깦�ܣ�0 = �����Ƴߴ���λ�� 1 = ��������λ�úͳߴ���λ��
    $DIMZIN             : �����Ƿ������λֵ�����㴦�� 0 = ������Ӣ�ߺ;�ȷ��Ӣ�� 1 = ������Ӣ�ߺ;�ȷ��Ӣ�� 2 = ������Ӣ�ߣ�������Ӣ�� 3 = ������Ӣ�磬������Ӣ��
    $DISPSILH           : ���ơ��߿�ģʽ��������������ߵ���ʾ�� 0 = �أ�1 = ��
    $FILLMODE           : ����ʱ�������ģʽ
    $INSUNITS           : AutoCAD ������Ŀ��Ĭ��ͼ�ε�λ��
                          0 = �޵�λ��1 = Ӣ�磻2 = Ӣ�ߣ�3 = Ӣ�4 = ���ף�5 = ���ף�6 = �ף�7 = ǧ�ף�8 = ΢Ӣ�磻9 = �ܶ���10 = �룻11 = ����12 = ���ף�
                          13 = ΢�ף�14 = ���ף�15 = ʮ�ף�16 = ���ף�17 = �����18 = ���ĵ�λ��19 = ���ꣻ20 = ����

    $INTERSECTIONCOLOR  : ָ���ཻ����ߵ�ͼԪ��ɫ��ֵ 1-255 ָ��һ�� AutoCAD ��ɫ���� (ACI) 0 = ��ɫ��� 256 = ��ɫ��� 257 = ��ɫ��ͼԪ
    $LIMCHECK           : ������˽��޼����Ϊ����ֵ
    $LUNITS             : ����;���ĵ�λ��ʽ
    $LUPREC             : ����;���ĵ�λ����
    $MAXACTVP           : ����Ҫ�����ɵ��ӿڵ������Ŀ
    $MEASUREMENT        : ����ͼ�ε�λ��0 = Ӣ�ƣ�1 = ����
    $MIRRTEXT           : ����ʱ��������
    $OBSCOLOR           : ָ���ڵ��ߵ���ɫ���ڵ�����ͨ��������ɫ������ʹ��ɼ��������ߣ����ҽ���ʹ�� HIDE �� SHADEMODE ����ʱ�ſɼ���
                          ���� OBSCUREDLTYPE ��ֵ����Ϊ�� 0������ʱ��OBSCUREDCOLOR ���òſɼ���0 �� 256 = ͼԪ��ɫ 1-255 = AutoCAD ��ɫ���� (ACI)

    $ORTHOMODE          : ����ʱ��������ģʽ
    $PDMODE             : ����ʾģʽ
    $PLIMCHECK          : ����ʱͼֽ�ռ��еĽ��޼��
    $PLINEGEN           : ���ƶ�ά����߶�����Χ������ͼ�������ɣ�0 = ����ߵ�ÿ�ξ���ʼ����ֹ�ڻ� 1 = �ڶ���߶�����Χ������ͼ����������
    $PROXYGRAPHICS      : ���ƴ������ͼ��ı���
    $PSLTSCALE          : ����ͼֽ�ռ��������ţ�0 = �ӿ����ſ����������� 1 = û���������������
    $PUCSORTHOVIEW      : ͼֽ�ռ� UCS ��������ͼ���� 0 = UCS ��������1 = ����ͼ��2 = ����ͼ��3 = ����ͼ��4 = ����ͼ��5 = ����ͼ��6 = ����ͼ
    $QTEXTMODE          : ����ʱ���á��������֡�ģʽ
    $REGENMODE          : ����ʱ���� REGENAUTO ģʽ
    $SHADEDGE           : 0 = ����ɫ���߲����� 1 = ����ɫ�����Ժ�ɫ���� 2 = �治��䣬����ʾͼԪ��ɫ 3 = ����ʾͼԪ��ɫ������ʾ��ɫ
    $SKPOLY             : 0 = ͽ�ֻ�ֱ�ߣ�1 = ͽ�ֻ������
    $SPLFRAME           : �������߿��ƶ������ʾ��1 = ����0 = ��
    $SPLINESEGS         : ÿ���������������ֱ�߶���Ŀ
    $SPLINETYPE         : PEDIT �������ߵ�������������
    $SURFTAB1           : �ڵ�һ�������ϵ�����ƽ����Ŀ
    $SURFTAB2           : �ڵڶ��������ϵ�����ƽ����Ŀ
    $SURFTYPE           :PEDIT ƽ������������
    $SURFU              : �� M �����ϵ������ܶȣ����� PEDIT ƽ����
    $SURFV              : �� N �����ϵ������ܶȣ����� PEDIT ƽ����
    $TREEDEPTH          : ָ���ռ�������������
    $UNITMODE           : ��λ�� = ��������ĸ�ʽ��ʾ������Ӣ��-Ӣ��Ϳ���Ƕ�
    $VISRETAIN          : 0 = �������ⲿ������صĿɼ������� 1 = �����ⲿ������صĿɼ�������
    $WORLDVIEW          ; // 1 = �� DVIEW/VPOINT �ڼ䣬�� UCS ����Ϊ WCS



280:  ---------------------------------------------------------------------------------------------
    $CSHADOW  : ��ά�������Ӱģʽ��0 = Ͷ��ͽ�����Ӱ 1 = Ͷ����Ӱ 2 = ������Ӱ 3 = ������Ӱ
    $DIMASSOC : ���Ʊ�ע����Ĺ�����
                0 = �����ֽ��ע����ע��Ԫ��֮��û�й���������ֱ�ߡ�Բ������ͷ�ͱ�ע������Ϊ����������л���
                1 = �����ǹ�����ע���󣻱�ע��Ԫ���γ�һ�����󣬲�����������ϵĶ����������ƶ�������±�עֵ
                2 = ����������ע���󣻱�ע��Ԫ���γ�һ�����󣬲��ұ�ע��һ������������뼸��ͼ�ζ����ϵĹ���������

    $ENDCAPS  : �¶�����߿���������ã�0 = �ޣ�1 = Բ�Σ�2 = �ǣ�3 = ����
    $HALOGAP  : ָ����ĳһ������һ�������ش���ʾ�ļ�ࣻ��ֵ��ָ��Ϊһ�ֵ�λ�İٷ��������Ҳ������ż����Ӱ�졣ʹ�� HIDE �� SHADEMODE �� Hidden ѡ��ʱ������Ȧ�е����ص㴦������Ȧ��

    $INDEXCTL : �����Ƿ���ͼ���ļ��д����ͱ���ͼ�������Ϳռ�������
                0 = ����������
                1 = ����ͼ������
                2 = �����ռ�����
                3 = ����ͼ�������Ϳռ�����



    $JOINSTYLE: �¶�����߿��������ã�0 = �ޣ�1 = Բ�Σ�2 = �ǣ�3 = ��ƽ

    $OBSLTYPE : ָ���ڵ��ߵ����͡���ͨ���� AutoCAD ���Ͳ�ͬ���ڵ��ߵ����Ͳ������ż����Ӱ�졣Ĭ��ֵ���� 0 ֵ�����ر��ڵ��ߵ���ʾ��������ֵ�������¶��壺
                0 = ��
                1 = ʵ��
                2 =��
                3 = ��
                4 = �̻�
                5 = �л�
                6 = ����
                7 = ˫�̻�
                8 = ˫�л�
                9 = ˫����
                10 = �г���
                11 = ϡ���


    $SORTENTS : ���ƶ��������ʽ���ɴ�ͨ����ѡ��Ի���ġ��û�ϵͳ���á�ѡ����ʡ�SORTENTS ʹ������λ�룺
                0 = ���� SORTENTS
                1 = Ϊ����ѡ������
                2 = Ϊ����׽����
                4 = Ϊ�ػ�����
                8 = Ϊ MSLIDE ����õ�Ƭ��������
                16 = Ϊ REGEN ��������
                32 = Ϊ��ӡ����
                64 = Ϊ PostScript �������




290:  ---------------------------------------------------------------------------------------------
    $INTERSECTIONDISPLAY : ָ���Ƿ���ʾ�ཻ����ߣ�0 = ����ʾ�ཻ����� 1 = ��ʾ�ཻ�����
    $LWDISPLAY           : ���ơ�ģ�͡�ѡ��򡰲��֡�ѡ����߿����ʾ��0 = ����ʾ�߿� 1 = ��ʾ�߿�
    $PSTYLEMODE          : ָ����ǰͼ�δ��ڡ���ɫ��ء�ģʽ���ǡ�������ӡ��ʽ��ģʽ��0 = �ڵ�ǰͼ����ʹ��������ӡ��ʽ�� 1 = �ڵ�ǰͼ����ʹ����ɫ��ش�ӡ��ʽ��
    $XCLIPFRAME          : �����ⲿ���ռ��ñ߽�Ŀɼ��ԣ�0 = ���ñ߽粻�ɼ� 1 = ���ñ߽�ɼ�
    $XEDIT               : ���Ƶ�ǰͼ�α�����ͼ�β���ʱ�Ƿ������λ�༭��0 = ����ʹ����λ���ձ༭ 1 = ����ʹ����λ���ձ༭

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
          $CMLSTYLE       : ��ǰ������ʽ����

          $UCSBASE        : �������� UCS ���õ�ԭ��ͷ���� UCS ����
          $UCSNAME        : ��ǰ UCS ������
          $UCSORTHOREF    : ���ģ�Ϳռ� UCS Ϊ������UCSORTHOVIEW ������ 0���������Ƽ�Ϊ������ UCS ��ص� UCS �����ơ����Ϊ�գ��� UCS �� WORLD ���

          $PUCSBASE       : �������� UCS ���ã�������ͼֽ�ռ䣩��ԭ��ͷ���� UCS ���ơ�
          $PUCSNAME       : ��ǰͼֽ�ռ� UCS ����
          $PUCSORTHOREF   : ���ͼֽ�ռ� UCS Ϊ������PUCSORTHOVIEW ������ 0���������Ƽ�Ϊ������ UCS ��ص� UCS �����ơ����Ϊ�գ��� UCS �� WORLD ���

          $FINGERPRINTGUID: �ڴ���ʱ���ã�����Ψһ��ʶ�ض�ͼ��
          $VERSIONGUID    : Ψһ��ʶͼ�ε��ض��汾���޸�ͼ��ʱ����
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
          if LStr = '$DIMEXE'     then Self.Document.DimStyles.Active.LinesProp.ExtBeyondDimLines := StrToFloatDef(LRecord.Value, -1.0) else // �ߴ��������
          if LStr = '$DIMEXO'     then Self.Document.DimStyles.Active.LinesProp.ExtOriginOffset   := StrToFloatDef(LRecord.Value, -1.0) else // �ߴ����ƫ��

          {
          if LStr = '$DIMLFAC'    then  else // ���Բ����ı�������
          if LStr = '$DIMRND'     then  else // ��ע���������ֵ
          if LStr = '$DIMSCALE'   then  else // ȫ�ֱ�ע��������
          if LStr = '$DIMTFAC'    then  else // ��ע������ʾ��������
          if LStr = '$DIMTM'      then  else // ��ƫ��
          if LStr = '$DIMTP'      then  else // ��ƫ��
          if LStr = '$DIMTSZ'     then  else // ��ע��Ǵ�С�� 0 = �ޱ��
          if LStr = '$DIMTVP'     then  else // ���ֵĴ�ֱλ��
          if LStr = '$DIMTXT'     then  else // ��ע���ָ߶�

          if LStr = '$DIMGAP'     then  else // �ߴ��߼��
          if LStr = '$DIMALTF'    then  else // ���㵥λ��������
          if LStr = '$DIMALTRND'  then  else // ȷ�����㵥λ������ֵ
          if LStr = '$DIMFAC'     then  else // ���ڼ����ע�����͹�������ָ߶ȵı������ӡ�AutoCAD �� DIMTFAC �� DIMTXT ��ˣ������÷����򹫲�����ָ߶�

          if LStr = '$CHAMFERA'   then  else // ��һ�����Ǿ���
          if LStr = '$CHAMFERB'   then  else // �ڶ������Ǿ���
          if LStr = '$CHAMFERC'   then  else // ���ǳ���
          if LStr = '$CHAMFERD'   then  else // ���ǽǶ�
          if LStr = '$FILLETRAD'  then  else // Բ�ǰ뾶

          if LStr = '$CMLSCALE'   then  else // ��ǰ���߱���
          if LStr = '$TRACEWID'   then  else // Ĭ�Ͽ��߿��
          if LStr = '$PLINEWID'   then  else // Ĭ�ϵĶ���߿��
          if LStr = '$PSVPSCALE'  then  else // �鿴���ӿڵı������ӣ�0= ��ͼֽ�ռ�����  >0 = �������ӣ���ʵ��ֵ��

          if LStr = '$PELEVATION' then  else // ��ǰͼֽ�ռ���
          if LStr = '$ELEVATION'  then  else // �� ELEV �������õĵ�ǰ���
          if LStr = '$THICKNESS'  then  else // �� ELEV �������õĵ�ǰ���
          if LStr = '$SKETCHINC'  then  else // ͽ�ֻ���¼����
          if LStr = '$TDCREATE'   then  else // ����ͼ�εı�������/ʱ�䣨�μ�����/ʱ����������⴦��
          if LStr = '$TDINDWG'    then  else // ��ͼ�ε��ۼƱ༭ʱ�䣨�μ�����/ʱ����������⴦��
          if LStr = '$TDUCREATE'  then  else // ����ͼ�ε�ͨ������/ʱ�䣨�μ�����/ʱ����������⴦��
          if LStr = '$TDUPDATE'   then  else // �ϴθ���ͼ�εı�������/ʱ�䣨�μ�����/ʱ����������⴦��
          if LStr = '$TDUSRTIMER' then  else // �û�����ʱ���ʱ��
          if LStr = '$TDUUPDATE'  then  else  // �ϴθ���/����ͼ�ε�ͨ������/ʱ�䣨�μ�����/ʱ����������⴦��
          if LStr = '$SHADOWPLANELOCATION'then  else // ������Ӱƽ���λ�á����� Z �����ꡣ
          }
        end;

      50:
        begin
          if LStr = '$ANGBASE' then Self.Document.Units.AngBase := StrToFloatDef(LRecord.Value, 0.0); //0�Ƕȷ���
        end;

      62:
        begin
          if LStr = '$CECOLOR' then FActiveColor := StrToIntDef(LRecord.Value, 256) else //��ǰͼԪ��ɫ�ţ�0 = ��飻256 = ���
          if LStr = '$INTERFERECOLOR' then ; //��ʾ��ִ�и��������ڼ䴴���ġ�������󡱵� ACI ��ɫ������Ĭ��ֵΪ 1
        end;

      70:
        begin
          if LStr = '$ORTHOMODE'        then Self.Document.ModelSpace.OrthoOn := StrToBoolDef(LRecord.Value, False) else
          if LStr = '$PDMODE'           then Self.Document.PointStyle.Mode := StrToIntDef(LRecord.Value, 0) else


          if LStr = '$ANGDIR'           then Self.Document.Units.AngClockWise := StrToBoolDef(LRecord.Value, False) else

          // �Ƕȵĵ�λ��ʽ
          if LStr = '$AUNITS'           then
          begin
            N := StrToIntDef(LRecord.Value, 0);
            if N < 5 then Self.Document.Units.AngUnit := TUdAngleUnit(N);
          end else
          if LStr = '$AUPREC'           then Self.Document.Units.AngPrecision := StrToIntDef(LRecord.Value, 0) else

          // ����;���ĵ�λ��ʽ
          if LStr = '$LUNITS'           then
          begin
            N := StrToIntDef(LRecord.Value, 2);  if N = 6 then N := 2;
            N := N - 1;
            if N < 5 then Self.Document.Units.LenUnit := TUdLengthUnit(N);
          end else
          if LStr = '$LUPREC'           then Self.Document.Units.LenPrecision := StrToIntDef(LRecord.Value, 0) else

          // �Ƕȱ�ע�ĽǶȸ�ʽ
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
          if LStr = '$DIMADEC'          then Self.Document.DimStyles.Active.UnitsProp.AngPrecision := StrToIntDef(LRecord.Value, 0) else // �Ƕȱ�ע����ʾ�ľ���λ��λ��

          // ���б�ע��ʽ���Ա���Ƕȱ�ע���⣩�Ļ��㵥λ�ĵ�λ��ʽ
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

          // �ߴ���
          if LStr = '$DIMCLRD'          then SetDxfColor(Self.Document, Self.Document.DimStyles.Active.LinesProp.Color, LRecord.Value) else
          if LStr = '$DIMCLRE'          then SetDxfColor(Self.Document, Self.Document.DimStyles.Active.LinesProp.ExtColor, LRecord.Value) else
          if LStr = '$DIMSD1'           then  else // ��һ���ߴ���ߵ����������0 = �����ƣ�1 = ����
          if LStr = '$DIMSD2'           then  else // �ڶ����ߴ���ߵ����������0 = �����ƣ�1 = ����
          if LStr = '$DIMSE1'           then  else // ����ʱ���Ƶ�һ���ߴ����
          if LStr = '$DIMSE2'           then  else // ����ʱ���Ƶڶ����ߴ����
          if LStr = '$DIMLWD'           then  else // �ߴ����߿�-3 = ��׼  -2 = ��� -1 = ���  0-211 = ��ʾ�ٷ�֮�����׵�����
          if LStr = '$DIMLWE'           then  else // �ߴ�����߿� -3 = ��׼ -2 = ��� -1 = ��� 0-211 = ��ʾ�ٷ�֮�����׵�����


          //��ע����
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

          if LStr = '$DIMSOXD'          then  else // ����ʱ����λ�ڳߴ����֮��ĳߴ���
          if LStr = '$DIMTIH'           then  else // ����ʱ������ˮƽ�����ڲ�
          if LStr = '$DIMTOH'           then  else // ����ʱ������ˮƽ�������
          if LStr = '$DIMTIX'           then  ;//  // ����ʱ������ǿ�Ʒ��ڳߴ���ߵ��ڲ�

          {
          if LStr = '$DIMSHO'           then  else // 0 = �϶�ԭʼͼ�� 1 = �϶�ʱ���¼����ע
          if LStr = '$DIMUPT'           then  else // �û���λ���ֵĹ�깦�ܣ�0 = �����Ƴߴ���λ�� 1 = ��������λ�úͳߴ���λ��
          if LStr = '$DIMZIN'           then  else // �����Ƿ������λֵ�����㴦�� 0 = ������Ӣ�ߺ;�ȷ��Ӣ�� 1 = ������Ӣ�ߺ;�ȷ��Ӣ�� 2 = ������Ӣ�ߣ�������Ӣ�� 3 = ������Ӣ�磬������Ӣ��
          if LStr = '$DISPSILH'         then  else // ���ơ��߿�ģʽ��������������ߵ���ʾ�� 0 = �أ�1 = ��
          if LStr = '$FILLMODE'         then  else // ����ʱ�������ģʽ

          if LStr = '$DIMLIM'           then  else // ����ʱ���ɵı�ע����
          if LStr = '$DIMSAH'           then  else // ����ʱʹ�õ����ļ�ͷ��

          if LStr = '$DIMTMOVE'         then  else // ��ע�����ƶ����� 0 = һ���ƶ��ߴ������ע����  1 = �ƶ���ע����ʱ�������  2 = ���������ƶ���ͷ���ֶ���������
          if LStr = '$DIMTOFL'          then  else // ������ַ��ڳߴ���ߵ���࣬����ʱ��ǿ���ڳߴ����֮�仭ֱ��

          if LStr = '$DIMALT'           then  else // ����ʱִ�еĻ��㵥λ��ע
          if LStr = '$DIMALTD'          then  else // ���㵥λС��λ


          if LStr = '$DIMASO'           then  else // 0 = ���Ƶ���ͼԪ 1 = ����������ע
          if LStr = '$DIMATFIT'         then  else // �ڳߴ������û���㹻�Ŀռ���ñ�ע���ֺͼ�ͷʱ���������ߵ�λ�ã�
                              //0 = �����ֺͼ�ͷ�����ڳߴ������ 1 = �����ƶ���ͷ��Ȼ���ƶ����� 2 = �����ƶ����֣�Ȼ���ƶ���ͷ 3 = �ƶ����ֺͼ�ͷ�нϺ��ʵ�һ��
                              //��� DIMTMOVE ����Ϊ 1��AutoCAD ��Ϊ���ƶ��ı�ע�������һ������


          if LStr = '$DIMALTTD'         then  else // ���㵥λ��ע�Ĺ���ֵ��С��λ��
          if LStr = '$DIMALTTZ'         then  else // �����Ƿ�Ի��㹫��ֵ�����㴦��
                              //0 = ������Ӣ�ߺ;�ȷ��Ӣ��  1 = ������Ӣ�ߺ;�ȷ��Ӣ��  2 = ������Ӣ�ߣ�������Ӣ��  3 = ������Ӣ�磬������Ӣ��
          if LStr = '$DIMTOL'           then  else // ����ʱ���ɱ�ע����
          if LStr = '$DIMTOLJ'          then  else // ����ֵ�Ĵ�ֱ������
          if LStr = '$DIMTZIN'          then  else // �����Ƿ�Թ���ֵ�����㴦�� 0 = ������Ӣ�ߺ;�ȷ��Ӣ�� 1 = ������Ӣ�ߺ;�ȷ��Ӣ�� 2 = ������Ӣ�ߣ�������Ӣ�� 3 = ������Ӣ�磬������Ӣ��


          if LStr = '$ATTMODE'          then  else // ���ԵĿɼ��ԣ�0 = �� 1 = ��ͨ 2 = ȫ��
          if LStr = '$CMLJUST'          then  else // ��ǰ���߶����� 0 = ���˶�����1 = ���ж�����2 = �׶˶���

          if LStr = '$INSUNITS'         then  else // AutoCAD ������Ŀ��Ĭ��ͼ�ε�λ��
                              //0 = �޵�λ��1 = Ӣ�磻2 = Ӣ�ߣ�3 = Ӣ�4 = ���ף�5 = ���ף�6 = �ף�7 = ǧ�ף�8 = ΢Ӣ�磻9 = �ܶ���10 = �룻11 = ����12 = ���ף�
                              //13 = ΢�ף�14 = ���ף�15 = ʮ�ף�16 = ���ף�17 = �����18 = ���ĵ�λ��19 = ���ꣻ20 = ����

          if LStr = '$INTERSECTIONCOLOR'then  else // ָ���ཻ����ߵ�ͼԪ��ɫ��ֵ 1-255 ָ��һ�� AutoCAD ��ɫ���� (ACI) 0 = ��ɫ��� 256 = ��ɫ��� 257 = ��ɫ��ͼԪ
          if LStr = '$LIMCHECK'         then  else // ������˽��޼����Ϊ����ֵ
          if LStr = '$MAXACTVP'         then  else // ����Ҫ�����ɵ��ӿڵ������Ŀ
          if LStr = '$MEASUREMENT'      then  else // ����ͼ�ε�λ��0 = Ӣ�ƣ�1 = ����
          if LStr = '$MIRRTEXT'         then  else // ����ʱ��������
          if LStr = '$OBSCOLOR'         then  else // ָ���ڵ��ߵ���ɫ���ڵ�����ͨ��������ɫ������ʹ��ɼ��������ߣ����ҽ���ʹ�� HIDE �� SHADEMODE ����ʱ�ſɼ���
                              //���� OBSCUREDLTYPE ��ֵ����Ϊ�� 0������ʱ��OBSCUREDCOLOR ���òſɼ���0 �� 256 = ͼԪ��ɫ 1-255 = AutoCAD ��ɫ���� (ACI)


          if LStr = '$PLIMCHECK'        then  else // ����ʱͼֽ�ռ��еĽ��޼��
          if LStr = '$PLINEGEN'         then  else // ���ƶ�ά����߶�����Χ������ͼ�������ɣ�0 = ����ߵ�ÿ�ξ���ʼ����ֹ�ڻ� 1 = �ڶ���߶�����Χ������ͼ����������
          if LStr = '$PROXYGRAPHICS'    then  else // ���ƴ������ͼ��ı���
          if LStr = '$PSLTSCALE'        then  else // ����ͼֽ�ռ��������ţ�0 = �ӿ����ſ����������� 1 = û���������������
          if LStr = '$PUCSORTHOVIEW'    then  else // ͼֽ�ռ� UCS ��������ͼ���� 0 = UCS ��������1 = ����ͼ��2 = ����ͼ��3 = ����ͼ��4 = ����ͼ��5 = ����ͼ��6 = ����ͼ
          if LStr = '$QTEXTMODE'        then  else // ����ʱ���á��������֡�ģʽ
          if LStr = '$REGENMODE'        then  else // ����ʱ���� REGENAUTO ģʽ
          if LStr = '$SHADEDGE'         then  else // 0 = ����ɫ���߲����� 1 = ����ɫ�����Ժ�ɫ���� 2 = �治��䣬����ʾͼԪ��ɫ 3 = ����ʾͼԪ��ɫ������ʾ��ɫ
          if LStr = '$SKPOLY'           then  else // 0 = ͽ�ֻ�ֱ�ߣ�1 = ͽ�ֻ������
          if LStr = '$SPLFRAME'         then  else // �������߿��ƶ������ʾ��1 = ����0 = ��
          if LStr = '$SPLINESEGS'       then  else // ÿ���������������ֱ�߶���Ŀ
          if LStr = '$SPLINETYPE'       then  else // PEDIT �������ߵ�������������
          if LStr = '$SURFTAB1'         then  else // �ڵ�һ�������ϵ�����ƽ����Ŀ
          if LStr = '$SURFTAB2'         then  else // �ڵڶ��������ϵ�����ƽ����Ŀ
          if LStr = '$SURFTYPE'         then  else //PEDIT ƽ������������
          if LStr = '$SURFU'            then  else // �� M �����ϵ������ܶȣ����� PEDIT ƽ����
          if LStr = '$SURFV'            then  else // �� N �����ϵ������ܶȣ����� PEDIT ƽ����
          if LStr = '$TREEDEPTH'        then  else // ָ���ռ�������������
          if LStr = '$UNITMODE'         then  else // ��λ�� = ��������ĸ�ʽ��ʾ������Ӣ��-Ӣ��Ϳ���Ƕ�
          if LStr = '$VISRETAIN'        then  else // 0 = �������ⲿ������صĿɼ������� 1 = �����ⲿ������صĿɼ�������
          if LStr = '$WORLDVIEW'        then  ; // 1 = �� DVIEW/VPOINT �ڼ䣬�� UCS ����Ϊ WCS
          }
        end;

      280:
        begin
          if LStr = '$SORTENTS' then FSortEntsFlag := StrToIntDef(LRecord.Value, 0);
          {
          0 = ���� SORTENTS
          1 = Ϊ����ѡ������
          2 = Ϊ����׽����
          4 = Ϊ�ػ�����
          8 = Ϊ MSLIDE ����õ�Ƭ��������
          16 = Ϊ REGEN ��������
          32 = Ϊ��ӡ����
          64 = Ϊ PostScript �������
          }
        end;

      290:
        begin
          if LStr = '$LWDISPLAY' then Self.Document.ModelSpace.LwtDisp := StrToBoolDef(LRecord.Value, False);
        end;

      370: if LStr = '$CELWEIGHT' then FActiveLineWeight := StrToIntDef(LRecord.Value, -1);
      380: ;// $CEPSNTYPE �¶���Ĵ�ӡ��ʽ���ͣ�0 = ����ӡ��ʽ 1 = ����ӡ��ʽ 2 = ��Ĭ�ϴʵ��ӡ��ʽ 3 = ����� ID/�����ӡ��ʽ
      390: ;// $CEPSNID   �¶���Ĵ�ӡ��ʽ�������� CEPSNTYPE Ϊ 3�����ֵ����þ��
    end;


    LRecord := Self.ReadRecord();
  until (LRecord.Value = 'ENDSEC') or (LRecord.Value = 'EOF');

  Self.Document.ModelSpace.Axes.LimRect := UdGeo2D.Rect2D(LLimMin, LLimMax);
end;







end.