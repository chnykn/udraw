{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfReadTables;

{$I UdDefs.INC}

interface

uses
  Classes, Graphics,
  UdConsts, UdTypes, UdDocument, UdLayout, UdEntities,
  UdDxfTypes, UdDxfReadSection, UdDimStyle;

type
  TUdDimStyleArrow = record
    DimStyle: TObject;
    BlockLeader: string;
    BlockFirst : string;
    BlockSecond: string;
  end;
  TUdDimStyleArrowArray = array of TUdDimStyleArrow;


  TUdDxfReadTables = class(TUdDxfReadSection)
  private
    FTextStyles: TStringList;
    FDimStyleArrows: TUdDimStyleArrowArray;
    FPaperSpaceCount: Integer; //PAPER_SPACE

  protected
    procedure AddVPort();
    procedure AddLineType();
    procedure AddLayer();
    procedure AddTextStyle();
    procedure AddDimStyle();
    procedure AddBlockRecord();

  public
    constructor Create(AOwner: TObject);  override;
    destructor Destroy; override;

    procedure Execute(); override;

    function SetDimStyleValue(ADimStyle: TUdDimStyle; ARecord: TUdDxfRecord): Boolean;

  public
    property DimStyleArrows: TUdDimStyleArrowArray read FDimStyleArrows;

  end;

implementation

uses
  SysUtils,
  UdLayer, UdLineType, UdColor, UdTextStyle,
  UdDimProps, UdUnits;





//=================================================================================================
{ TUdDxfReadTables }

constructor TUdDxfReadTables.Create(AOwner: TObject);
begin
  inherited;

  FTextStyles := TStringList.Create();
  FDimStyleArrows := nil;
end;

destructor TUdDxfReadTables.Destroy;
begin
  FTextStyles.Free();
  FDimStyleArrows := nil;

  inherited;
end;






procedure TUdDxfReadTables.AddVPort();
begin
  repeat
    Self.ReadCurrentRecord();
    {
    case FCurrRecord.Code of

    end;
    }
  until (Self.CurrRecord.Code = 0);
end;



procedure TUdDxfReadTables.AddLineType();
var
  I, N: Integer;
  LName: string;               //2
  LFlag: Cardinal;             //70
  LComment: string;            //3
  LLtCount: Integer;           //73
  LLtSegments: TSingleArray;   //49
  LLtSegmentKind: Integer;     //74
  LScale: Double;              //46

  LLineType: TUdLineType;
begin
  N := 0;
  LName          := '';
  LFlag          := 0;
  LComment       := '';
  LLtSegments    := nil;
  LLtSegmentKind := 0;
  LScale         := 1.0;

  repeat
    Self.ReadCurrentRecord();
    case Self.CurrRecord.Code of
      2 : LName       := Self.CurrRecord.Value;
      70: LFlag       := StrToIntDef(Self.CurrRecord.Value, 0);
      3 : LComment    := Self.CurrRecord.Value;
      73:
        begin
          LLtCount := StrToIntDef(Self.CurrRecord.Value, 0);
          SetLength(LLtSegments, LLtCount)
        end;
      49:
        begin
          if N < Length(LLtSegments) then
          begin
            LLtSegments[N] := StrToFloatDef(Self.CurrRecord.Value, 0);
            Inc(N);
          end;
        end;
      74: LLtSegmentKind := StrToIntDef(Self.CurrRecord.Value, 0);
      46: LScale := StrToFloatDef(Self.CurrRecord.Value, 1);
    end;
  until (Self.CurrRecord.Code = 0);

  if LName <> '' then
  begin
    LLineType := Self.Document.LineTypes.GetItem(LName);
    if not Assigned(LLineType) then
    begin
      LLineType := TUdLineType.Create(Self.Document, True);
      Self.Document.LineTypes.Add(LLineType);
    end;

    if Assigned(LLineType) then
    begin
      LLineType.Name := LName;
      LLineType.Comment := LComment;

      if LScale > 0 then
        for I := 0 to Length(LLtSegments) - 1 do LLtSegments[I] := LLtSegments[I] * LScale;

      LLineType.Value := LLtSegments;

      if LFlag > 0 then ;
      if LLtSegmentKind > 0 then ;
    end;
  end;
end;


procedure TUdDxfReadTables.AddLayer();
var
  LName: string;        //2
  LFlag: Cardinal;      //70
  LColor: Integer;      //62
  LLineType: string;    //6
  LPrint: Integer;      //290
  LLineWeight: Integer; //370

  LLayer: TUdLayer;
  LLineTypeObj: TUdLineType;
begin
  LName       := '';
  LFlag       := 0;
  LColor      := 7;
  LLineType   := '';
  LPrint      := 1;
  LLineWeight := -3;

  repeat
    Self.ReadCurrentRecord();
    case Self.CurrRecord.Code of
      2  : LName       := Self.CurrRecord.Value;
      70 : LFlag       := StrToIntDef(Self.CurrRecord.Value, 0);
      62 : LColor      := StrToIntDef(Self.CurrRecord.Value, 0);
      6  : LLineType   := Self.CurrRecord.Value;
      290: LPrint      := StrToIntDef(Self.CurrRecord.Value, 1);
      370: LLineWeight := StrToIntDef(Self.CurrRecord.Value, 0);
    end;
  until (Self.CurrRecord.Code = 0);

  if LName <> '' then
  begin
    LLayer := Self.Document.Layers.GetItem(LName);
    if not Assigned(LLayer) then
    begin
      LLayer := TUdLayer.Create(Self.Document, True);
      Self.Document.Layers.Add(LLayer);
    end;

    if Assigned(LLayer) then
    begin
      LLayer.Name := LName;
      LLayer.Visible := (LColor > 0);
      LLayer.Freeze := ((LFlag and 1) > 0);
      LLayer.Lock := ((LFlag and 4) > 0);
      LLayer.Color.IndexColor := Abs(LColor);

      LLineTypeObj := Self.Document.LineTypes.GetItem(LLineType);
      if not Assigned(LLineTypeObj) then
        LLineTypeObj := Self.Document.LineTypes.GetStdLineType(LLineType);

      if Assigned(LLineTypeObj) then LLayer.LineType := LLineTypeObj;
      
      LLayer.LineWeight := LLineWeight;
      LLayer.Plot := (LPrint = 1);
    end;
  end;
end;

procedure TUdDxfReadTables.AddTextStyle();
var
  N: Integer;
  LName: string;        //2
  LHandle: string;      //5
  LFlag: Cardinal;      //70
  LHeight: Float;       //42
  LWidthFactor: Float;  //41
  LObliqueAng: Float;   //50
  LBackward: Boolean;   //71_2
  LUpsidedown: Boolean; //71_4
  LShxFile: string;     //3
  LBigFile: string;     //4
  LTTFFontName: string; //1000
  LTTFFontFlag: string; //1001
  LTTFFontStyle: Cardinal; //1071

  LTextStyle: TUdTextStyle;
begin
  LName        := '';
  LFlag        := 0;
  LHeight      := 2.5;
  LWidthFactor := 1;
  LObliqueAng  := 0;
  LBackward    := False;
  LUpsidedown  := False;
  LShxFile     := '';
  LBigFile     := '';
  LTTFFontName := '';
  LTTFFontStyle := 0;

  repeat
    Self.ReadCurrentRecord();
    case Self.CurrRecord.Code of
      2  : LName        := Self.CurrRecord.Value;
      5  : LHandle      := Self.CurrRecord.Value;
      70 : LFlag        := StrToIntDef(Self.CurrRecord.Value, 0);
      40 : LHeight      := StrToFloatDef(Self.CurrRecord.Value, 2.5);
      41 : LWidthFactor := StrToFloatDef(Self.CurrRecord.Value, 1);
      50 : LObliqueAng  := StrToFloatDef(Self.CurrRecord.Value, 0);
      71 :
      begin
        N := StrToIntDef(Self.CurrRecord.Value, 0);
        LBackward   := ((N and 2) > 0);
        LUpsidedown := ((N and 4) > 0);
      end;
      3  : LShxFile := Self.CurrRecord.Value;
      4  : LBigFile := Self.CurrRecord.Value;
      1000: LTTFFontName := Self.CurrRecord.Value;
      1001: LTTFFontFlag := Self.CurrRecord.Value;
      1071: LTTFFontStyle := StrToIntDef(Self.CurrRecord.Value, 0);
    end;
  until (Self.CurrRecord.Code = 0);

  if LName <> '' then
  begin
    LTextStyle := Self.Document.TextStyles.GetItem(LName);
    if not Assigned(LTextStyle) then
    begin
      LTextStyle := TUdTextStyle.Create(Self.Document, True);
      Self.Document.TextStyles.Add(LTextStyle);
    end;

    if Assigned(LTextStyle) then
    begin
      LTextStyle.Name := LName;
      LTextStyle.Height := LHeight;
      LTextStyle.WidthFactor := LWidthFactor;
      LTextStyle.Backward := LBackward;
      LTextStyle.Upsidedown := LUpsidedown;

      if (LTTFFontFlag <> '') and (LTTFFontName <> '') then
      begin
        LTextStyle.FontKind := fkTTF;

//        if LTTFFontName = '' then
//        begin
//          LTTFFontName := SysUtils.ExtractFileName(LShxFile);
//          N := Pos('.', LTTFFontName);
//          if N > 0 then Delete(LTTFFontName, N, Length(LTTFFontName));
//        end;

        LTextStyle.TTFFont.Font.Name := LTTFFontName;

        if (LTTFFontStyle and $1000000) > 0 then
          LTextStyle.TTFFont.Font.Style := LTextStyle.TTFFont.Font.Style + [fsItalic];

        if (LTTFFontStyle and $2000000) > 0 then
          LTextStyle.TTFFont.Font.Style := LTextStyle.TTFFont.Font.Style + [fsBold];
      end
      else begin
        LShxFile := Self.Document.TextStyles.GetShxFile(LShxFile);
        if not FileExists(LShxFile) then
          LShxFile := Self.Document.TextStyles.GetShxFile('txt');

        LBigFile := Self.Document.TextStyles.GetShxFile(LBigFile);
        if FileExists(LShxFile) or FileExists(LBigFile) then
        begin
          LTextStyle.FontKind := fkShx;
          LTextStyle.ShxFont.ShxFile := LShxFile;
          LTextStyle.ShxFont.BigFile := LBigFile;
        end
      end;

      if LFlag > 0 then ;
      if LObliqueAng > 0 then ;
      if LHandle <> '' then FTextStyles.AddObject(LHandle, LTextStyle);
    end;
  end;
end;



function  TUdDxfReadTables.SetDimStyleValue(ADimStyle: TUdDimStyle; ARecord: TUdDxfRecord): Boolean;
var
  N: Integer;
  LStr: string;
  LValue: Float;
  LFlag: Integer;
  LDimStyle: TUdDimStyle;
  LTextStyle: TUdTextStyle;
begin
  Result := False;
  if not Assigned(ADimStyle) then Exit;

  LFlag := 0;
  LDimStyle := ADimStyle;


  case ARecord.Code of
      70  : LFlag := StrToIntDef(ARecord.Value, 0);

      40  : if Assigned(LDimStyle) then LDimStyle.OverallScale := StrToFloatDef(ARecord.Value, 1.0);   // DIMSCALE
      174 : if Assigned(LDimStyle) then LDimStyle.BestFit := StrToIntDef(ARecord.Value, 0) <> 1;   // DIMTIX

      176 : if Assigned(LDimStyle) then SetDxfColor(Self.Document, LDimStyle.LinesProp.Color, ARecord.Value); // DIMCLRD  Ϊ�ߴ��ߡ���ͷ�ͱ�ע����ָ����ɫ��ͬʱ������ leader �������������ɫ
      177 : if Assigned(LDimStyle) then SetDxfColor(Self.Document, LDimStyle.LinesProp.ExtColor, ARecord.Value);                        // DIMCLRE
      371 : if Assigned(LDimStyle) then LDimStyle.LinesProp.LineWeight       := StrToIntDef(ARecord.Value, -3);       // DIMLWD  ���߿�ö��ֵ��
      372 : if Assigned(LDimStyle) then LDimStyle.LinesProp.ExtLineWeight    := StrToIntDef(ARecord.Value, -3);       // DIMLWE  ���߿�ö��ֵ��
      281 : if Assigned(LDimStyle) then LDimStyle.LinesProp.SuppressLine1    := StrToBoolDef(ARecord.Value, False) ;  // DIMSD1
      282 : if Assigned(LDimStyle) then LDimStyle.LinesProp.SuppressLine2    := StrToBoolDef(ARecord.Value, False) ;  // DIMSD2
      75  : if Assigned(LDimStyle) then LDimStyle.LinesProp.ExtSuppressLine1 := StrToBoolDef(ARecord.Value, False);   // DIMSE1
      76  : if Assigned(LDimStyle) then LDimStyle.LinesProp.ExtSuppressLine2 := StrToBoolDef(ARecord.Value, False);   // DIMSE2
      43  : if Assigned(LDimStyle) then LDimStyle.LinesProp.BaselineSpacing  := StrToFloatDef(ARecord.Value, 3.75);   // DIMDLI
//      44  : if Assigned(LDimStyle) then LDimStyle.LinesProp.ExtBeyondTicks   := StrToFloatDef(ARecord.Value, 1.25);
      44  : if Assigned(LDimStyle) then LDimStyle.LinesProp.ExtBeyondDimLines := StrToFloatDef(ARecord.Value, 1.25);
      42  : if Assigned(LDimStyle) then LDimStyle.LinesProp.ExtOriginOffset   := StrToFloatDef(ARecord.Value, 0.625);  // DIMEXO



      {
      1001
      ACAD_DSTYLE_DIMEXT_LENGTH
      1070
         378
      1040
      1.25

      1001
      ACAD_DSTYLE_DIMEXT_ENABLED
      1070
         383
      1070
           0

      1001
      ACAD_DSTYLE_DIMARC_LENGTH_SYMBOL
      1070
         379
      1070
           0

      1001
      ACAD_DSTYLE_DIMJOGGED_JOGANGLE_SYMBOL
      1070
         384
      1040
      1.570796326794896
        0
      }
      41  : if Assigned(LDimStyle) then LDimStyle.ArrowsProp.ArrowSize := StrToFloatDef(ARecord.Value, 2.5);  // DIMASZ
      141 : if Assigned(LDimStyle) then LDimStyle.ArrowsProp.MarkSize  := StrToFloatDef(ARecord.Value, 2.5);  // DIMCEN
      341 : if Assigned(LDimStyle) then
            begin
              with FDimStyleArrows[High(FDimStyleArrows)] do
              begin
                BlockLeader := ARecord.Value;
              end;
            end;
      342 : if Assigned(LDimStyle) then   // DIMBLK
            begin
              with FDimStyleArrows[High(FDimStyleArrows)] do
              begin
                BlockFirst  := ARecord.Value;
                BlockSecond := ARecord.Value;
              end;
            end;
      343 : if Assigned(LDimStyle) then  // DIMBLK1
            begin
              with FDimStyleArrows[High(FDimStyleArrows)] do
              begin
                BlockFirst  := ARecord.Value;
              end;
            end;

      344 : if Assigned(LDimStyle) then // DIMBLK2
            begin
              with FDimStyleArrows[High(FDimStyleArrows)] do
              begin
                BlockSecond  := ARecord.Value;
              end;
            end;



      // LDimStyle.TextProp.FillColor  //Yellow
      {
      1001
      ACAD_DSTYLE_DIMTEXT_FILL
      1070
         376
      1070
         2
      }
      340 : if Assigned(LDimStyle) then {TextStyle's Handle}  // Get TextStyle by TextStyle's Handle
            begin
              N := FTextStyles.IndexOf(ARecord.Value);
              if N >= 0 then
              begin
                LTextStyle := TUdTextStyle(FTextStyles.Objects[N]);
                LDimStyle.TextProp.TextStyle := LTextStyle.Name;
              end;
            end;
      178 : if Assigned(LDimStyle) then SetDxfColor(Self.Document, LDimStyle.TextProp.TextColor, ARecord.Value);                // DIMCLRT
      140 : if Assigned(LDimStyle) then LDimStyle.TextProp.TextHeight := StrToFloatDef(ARecord.Value, 2.5);      // DIMTXT
      147 : if Assigned(LDimStyle) then  // DIMGAP
            begin
              LValue := StrToFloatDef(ARecord.Value, 0.625);
              LDimStyle.TextProp.OffsetFromDimLine := Abs(LValue);
              LDimStyle.TextProp.DrawFrame := LValue < 0;
            end;
      73  : if Assigned(LDimStyle) then
            begin
              N := StrToIntDef(ARecord.Value, 1);
              LDimStyle.TextProp.InsideAlign := N = 0;
            end;
      74  : if Assigned(LDimStyle) then
            begin
              N := StrToIntDef(ARecord.Value, 1);
              LDimStyle.TextProp.OutsideAlign := N = 0;
            end;
      77  : if Assigned(LDimStyle) then LDimStyle.TextProp.VerticalPosition := TUdVerticalTextPoint(Integer(StrToBoolDef(ARecord.Value, False))); // DIMTAD
      280 : if Assigned(LDimStyle) then   // DIMJUST
            begin
              N := StrToIntDef(ARecord.Value, 0);
              if N < 3 then LDimStyle.TextProp.HorizontalPosition := TUdHorizontalTextPoint(N);
            end;


      277 : if Assigned(LDimStyle) then // DIMLUNIT
            begin
              N := StrToIntDef(ARecord.Value, 2);  if N = 6 then N := 2;
              N := N - 1;
              if N < 5 then LDimStyle.UnitsProp.UnitFormat := TUdLengthUnit(N);
            end;
      271 : if Assigned(LDimStyle) then LDimStyle.UnitsProp.Precision := Byte(StrToIntDef(ARecord.Value, 3)); // DIMDEC
//      272 : if Assigned(LDimStyle) then LDimStyle.UnitsProp.Precision := Byte(StrToIntDef(ARecord.Value, 3)); // DIMTDEC
      278 : if Assigned(LDimStyle) then LDimStyle.UnitsProp.Decimal := Chr(StrToIntDef(ARecord.Value, 44));
      45  : if Assigned(LDimStyle) then LDimStyle.UnitsProp.RoundOff := StrToFloatDef(ARecord.Value, 2.5); // DIMRND   �����б�ע�������뵽ָ��ֵ
      3   : if Assigned(LDimStyle) then  // DIMPOST
            begin
              LStr := ARecord.Value;
              N := Pos('\X', LStr);
              if N > 0 then
              begin
                Delete(LStr, N, 2);
                LDimStyle.AltUnitsProp.AltPlacement := apBelowPrimary;
              end
              else
                LDimStyle.AltUnitsProp.AltPlacement := apAfterPrimary;

              N := Pos('<>', LStr);
              if N > 0 then
              begin
                LDimStyle.UnitsProp.Prefix := Copy(LStr, 1, N-1);
                LDimStyle.UnitsProp.Suffix := Copy(LStr, N+2, MAXINT);
              end
              else
                LDimStyle.UnitsProp.Suffix := ARecord.Value;
            end;
      144 : if Assigned(LDimStyle) then LDimStyle.UnitsProp.MeasurementScale := StrToFloatDef(ARecord.Value, 1.0);               // DIMLFAC
      275 : if Assigned(LDimStyle) then // DIMAUNIT  ���ýǶȱ�ע�ĵ�λ��ʽ��0��ʮ���ƶ��� 1����/��/�� 2���ٷֶ� 3������
            begin
              N := StrToIntDef(ARecord.Value, 0);
              if (N > 3) or (N < 0) then N := 0;
              LDimStyle.UnitsProp.AngUnitFormat := TUdAngleUnit(N);
            end;
      78  : if Assigned(LDimStyle) then // DIMZIN   �����Ƿ������λֵ�����㴦��
            begin
              LDimStyle.UnitsProp.SuppressLeading := False;
              LDimStyle.UnitsProp.SuppressTrailing := False;
              N := StrToIntDef(ARecord.Value, 0);
              case N of
                4 : begin LDimStyle.UnitsProp.SuppressLeading := True;  end;
                8 : begin LDimStyle.UnitsProp.SuppressTrailing := True; end;
                12: begin LDimStyle.UnitsProp.SuppressLeading := True; LDimStyle.UnitsProp.SuppressTrailing := True; end;
              end;
            end;
      79  : if Assigned(LDimStyle) then // DIMAZIN  �ԽǶȱ�ע�����㴦��
            begin
              LDimStyle.UnitsProp.AngSuppressLeading := False;
              LDimStyle.UnitsProp.AngSuppressTrailing := False;
              N := StrToIntDef(ARecord.Value, 0);
              case N of
                4 : begin LDimStyle.UnitsProp.AngSuppressLeading := True;  end;
                8 : begin LDimStyle.UnitsProp.AngSuppressTrailing := True; end;
                12: begin LDimStyle.UnitsProp.AngSuppressLeading := True; LDimStyle.UnitsProp.AngSuppressTrailing := True; end;
              end;
            end;




      170 : if Assigned(LDimStyle) then LDimStyle.DispAltUnits := StrToBoolDef(ARecord.Value, False); // DIMALT   ���Ʊ�ע�л��㵥λ����ʾ����.���û��㵥λ ��.���û��㵥λ
      273 : if Assigned(LDimStyle) then  // DIMALTU  Ϊ���б�ע��ʽ�壨�Ƕȱ�ע���⣩���㵥λ���õ�λ��ʽ��
            begin
              N := StrToIntDef(ARecord.Value, 2);  if N = 6 then N := 2;
              N := N - 1;
              if N < 5 then LDimStyle.UnitsProp.UnitFormat := TUdLengthUnit(N);
            end;
      4   : if Assigned(LDimStyle) then // DIMAPOST
            begin
              N := Pos('[]', ARecord.Value);
              if N > 0 then
              begin
                LDimStyle.AltUnitsProp.Prefix := Copy(ARecord.Value, 1, N-1);
                LDimStyle.AltUnitsProp.Suffix := Copy(ARecord.Value, N+2, MAXINT);
              end
              else
                LDimStyle.AltUnitsProp.Suffix := ARecord.Value;
            end;
      143 : if Assigned(LDimStyle) then LDimStyle.AltUnitsProp.MeasurementScale := StrToFloatDef(ARecord.Value, 0.03937);    // DIMALTF
      285 : if Assigned(LDimStyle) then  // DIMALTZ
            begin
              LDimStyle.AltUnitsProp.SuppressLeading := False;
              LDimStyle.AltUnitsProp.SuppressTrailing := False;
              N := StrToIntDef(ARecord.Value, 0);
              case N of
                4 : begin LDimStyle.AltUnitsProp.SuppressLeading := True;  end;
                8 : begin LDimStyle.AltUnitsProp.SuppressTrailing := True; end;
                12: begin LDimStyle.AltUnitsProp.SuppressLeading := True; LDimStyle.AltUnitsProp.SuppressTrailing := True; end;
              end;
            end;
      274 : if Assigned(LDimStyle) then LDimStyle.AltUnitsProp.Precision := Byte(StrToIntDef(ARecord.Value, 3)); // DIMALTTD ���ñ�ע���㵥λ����ֵС��λ��λ��
      171 : if Assigned(LDimStyle) then ; // DIMALTD  ���ƻ��㵥λ��С��λ��λ����



      {
      279 : if Assigned(LDimStyle) then ; // DIMTMOVE  ���ñ�ע���ֵ��ƶ�����
      284 : if Assigned(LDimStyle) then ; // DIMTZIN  �����Ƿ�Թ���ֵ�����㴦��
      286 : if Assigned(LDimStyle) then ; // DIMALTTZ �����Ƿ�Թ���ֵ�����㴦��

      276 : if Assigned(LDimStyle) then ; // DIMFRAC  �� dimlunit ϵͳ��������Ϊ��4���������� 5��������ʱ���÷�����ʽ��0��ˮƽ 1��б 2�����ѵ�
      289 : if Assigned(LDimStyle) then ; // DIMATFIT ���ߴ���ߵĿռ䲻����ͬʱ���±�ע���ֺͼ�ͷʱ����ϵͳ������ȷ�������ߵ����з�ʽ
      288 : if Assigned(LDimStyle) then ; // DIMUPT   �����û���λ���ֵ�ѡ�0�������Ƴߴ��ߵ�λ�� 1�����������Լ��ߴ��ߵ�λ��
      283 : if Assigned(LDimStyle) then ; // DIMTOLJ   ���ù���ֵ��������Ա�ע���ֵĴ�ֱ������ʽ��0���� 1���м� 2����
      142 : if Assigned(LDimStyle) then ; // DIMTSZ ָ�����Ա�ע���뾶��ע�Լ�ֱ����ע�������ͷ��Сб�߳ߴ硣
      145 : if Assigned(LDimStyle) then ; // DIMTVP  ���Ƴߴ����Ϸ����·���ע���ֵĴ�ֱλ�á��� dimtad ����Ϊ��ʱ��autocad ��ʹ�� dimtvp ��ֵ��
      146 : if Assigned(LDimStyle) then ; // DIMTFAC ���� dimtxt ϵͳ���������ã�����ڱ�ע���ָ߶ȸ�����ֵ�͹���ֵ�����ָ߶�ָ���������ӡ�
      148 : if Assigned(LDimStyle) then ; // DIMALTRND ���뻻���ע��λ��
      71  : if Assigned(LDimStyle) then ; // DIMTOL   ������ڱ�ע����֮�󡣽� dimtol ����Ϊ�����������ر� dimlim ϵͳ������
      72  : if Assigned(LDimStyle) then ; // DIMLIM   �����޳ߴ�����ΪĬ�����֡�
      73  : if Assigned(LDimStyle) then ; // DIMTIH   �������б�ע���ͣ������ע���⣩�ı�ע�����ڳߴ�����ڵ�λ��
      179 : if Assigned(LDimStyle) then ; // DIMADEC  1.ʹ�� dimdec ���õ�С��λ�����ƽǶȱ�ע��0-8 ʹ�� dimadec ���õ�С��λ�����ƽǶȱ�ע��
      271 : if Assigned(LDimStyle) then ; // DIMDEC   ���ñ�ע����λ��ʾ��С��λλ�������Ȼ���ѡ���ĵ�λ��Ƕȸ�ʽ��

      172 : if Assigned(LDimStyle) then ; // DIMTOFL  �����Ƿ񽫳ߴ��߻����ڳߴ����֮�䣨��ʹ���ַ����ڳߴ����֮�⣩
      173 : if Assigned(LDimStyle) then ; // DIMSAH   ���Ƴߴ��߼�ͷ�����ʾ��
      174 : if Assigned(LDimStyle) then ; // DIMTIX   �ڳߴ����֮���������
      175 : if Assigned(LDimStyle) then ; // DIMSOXD  �����Ƿ�����ߴ��߻��Ƶ��ߴ����֮�⣺�أ��������ߴ��� ���������ߴ���
      46  : if Assigned(LDimStyle) then ; // DIMDLE   ��ʹ��Сб�ߴ����ͷ���б�עʱ�����óߴ��߳����ߴ���ߵľ��롣
      47  : if Assigned(LDimStyle) then ; // DIMTP    ��dimtol �� dimlim ϵͳ��������Ϊ��������£�Ϊ��ע������������ϣ�ƫ��
      48  : if Assigned(LDimStyle) then ; // DIMTM    ��dimtol �� dimlim ϵͳ��������Ϊ��������£�Ϊ��ע����������С���£�ƫ��
      }
  end;


  if Assigned(LDimStyle) then
    if LFlag > 0 then ;

  Result := True;
end;

procedure TUdDxfReadTables.AddDimStyle();
var
  LDimStyle: TUdDimStyle;
begin
  LDimStyle := nil;

  repeat
    Self.ReadCurrentRecord();
    case Self.CurrRecord.Code of
      2:
      begin
        LDimStyle := Self.Document.DimStyles.GetItem(Self.CurrRecord.Value);
        if not Assigned(LDimStyle) then
        begin
          LDimStyle := TUdDimStyle.Create(Self.Document, True);
          LDimStyle.Name := Self.CurrRecord.Value;
          Self.Document.DimStyles.Add(LDimStyle);
        end;

        SetLength(FDimStyleArrows, Length(FDimStyleArrows) + 1);
        with FDimStyleArrows[High(FDimStyleArrows)] do
        begin
          DimStyle := LDimStyle;
          BlockLeader := '';
          BlockFirst  := '';
          BlockSecond := '';
        end;
      end;

      else SetDimStyleValue(LDimStyle, Self.CurrRecord);
    end;
  until (Self.CurrRecord.Code = 0);

end;

procedure TUdDxfReadTables.AddBlockRecord();
{
  function _GetPaperSpaceIndex(AValue: string): Integer;
  var
    N: Integer;
    LStr: string;
  begin
    Result := -1;

    LStr := AValue;
    Delete(LStr, 1, Length('*PAPER_SPACE'));

    if LStr = '' then Result := 0 else
    begin
      if TryStrToInt(LStr, N) then
        Result := N + 1;
    end;
  end;
}
var
  LStr: string;
  LBlockName: string;
  LBlockHandle: string;
  LLayoutHandle: string;
begin
  repeat
    Self.ReadCurrentRecord();

    case Self.CurrRecord.Code of
      2  : LBlockName := Self.CurrRecord.Value;
      5  : LBlockHandle := Self.CurrRecord.Value;
      340: LLayoutHandle := Self.CurrRecord.Value;
    end;
  until (Self.CurrRecord.Code = 0);


  LStr := UpperCase(LBlockName);
  if LStr = '*MODEL_SPACE' then
  begin
    Self.AddDxfLayout(LBlockHandle, LLayoutHandle, Self.Document.ModelSpace);
  end else
  if Pos('*PAPER_SPACE', LStr) > 0 then
  begin
    if FPaperSpaceCount >= Self.Document.Layouts.Count then
      Self.Document.Layouts.Add(sLayoutName + IntToStr(FPaperSpaceCount), False);

    Self.AddDxfLayout(LBlockHandle, LLayoutHandle, Self.Document.Layouts.Items[FPaperSpaceCount]);
    Inc(FPaperSpaceCount);
  end;
end;






procedure TUdDxfReadTables.Execute();
begin
  FTextStyles.Clear();
  FDimStyleArrows := nil;
  FPaperSpaceCount := 1;

  while True do
  begin
    Self.ReadCurrentRecord();

    if Self.CurrRecord.Code = 0 then
    begin
      if Self.CurrRecord.Value = 'TABLE' then
      begin
        Self.ReadCurrentRecord();

        if Self.CurrRecord.Value = 'VPORT' then
        begin
          repeat
            Self.AddVPort();
          until (Self.CurrRecord.Value <> 'VPORT');
        end else
        if Self.CurrRecord.Value = 'LTYPE' then
        begin
          repeat
            Self.AddLineType();
          until (Self.CurrRecord.Value <> 'LTYPE');
        end else
        if Self.CurrRecord.Value = 'LAYER' then
        begin
          repeat
            Self.AddLayer();
          until (Self.CurrRecord.Value <> 'LAYER');
        end else
        if Self.CurrRecord.Value = 'STYLE' then
        begin
          repeat
            Self.AddTextStyle();
          until (Self.CurrRecord.Value <> 'STYLE');
        end else
        if Self.CurrRecord.Value = 'DIMSTYLE' then
        begin
          repeat
            Self.AddDimStyle();
          until (Self.CurrRecord.Value <> 'DIMSTYLE');
        end else
        if Self.CurrRecord.Value = 'BLOCK_RECORD' then
        begin
          repeat
            Self.AddBlockRecord();
          until (Self.CurrRecord.Value <> 'BLOCK_RECORD');
        end;

        while Self.CurrRecord.Value <> 'ENDTAB' do
          Self.ReadCurrentRecord();
      end
      else begin
        if (Self.CurrRecord.Value = 'ENDSEC') or (Self.CurrRecord.Value = 'EOF') then Break;
      end;
    end;
  end;
end;





end.