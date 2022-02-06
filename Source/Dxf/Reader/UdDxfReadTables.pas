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

      176 : if Assigned(LDimStyle) then SetDxfColor(Self.Document, LDimStyle.LinesProp.Color, ARecord.Value); // DIMCLRD  为尺寸线、箭头和标注引线指定颜色。同时控制由 leader 命令创建的引线颜色
      177 : if Assigned(LDimStyle) then SetDxfColor(Self.Document, LDimStyle.LinesProp.ExtColor, ARecord.Value);                        // DIMCLRE
      371 : if Assigned(LDimStyle) then LDimStyle.LinesProp.LineWeight       := StrToIntDef(ARecord.Value, -3);       // DIMLWD  （线宽枚举值）
      372 : if Assigned(LDimStyle) then LDimStyle.LinesProp.ExtLineWeight    := StrToIntDef(ARecord.Value, -3);       // DIMLWE  （线宽枚举值）
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
      45  : if Assigned(LDimStyle) then LDimStyle.UnitsProp.RoundOff := StrToFloatDef(ARecord.Value, 2.5); // DIMRND   将所有标注距离舍入到指定值
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
      275 : if Assigned(LDimStyle) then // DIMAUNIT  设置角度标注的单位格式：0．十进制度数 1．度/分/秒 2．百分度 3．弧度
            begin
              N := StrToIntDef(ARecord.Value, 0);
              if (N > 3) or (N < 0) then N := 0;
              LDimStyle.UnitsProp.AngUnitFormat := TUdAngleUnit(N);
            end;
      78  : if Assigned(LDimStyle) then // DIMZIN   控制是否对主单位值作消零处理。
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
      79  : if Assigned(LDimStyle) then // DIMAZIN  对角度标注作消零处理
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




      170 : if Assigned(LDimStyle) then LDimStyle.DispAltUnits := StrToBoolDef(ARecord.Value, False); // DIMALT   控制标注中换算单位的显示：关.禁用换算单位 开.启用换算单位
      273 : if Assigned(LDimStyle) then  // DIMALTU  为所有标注样式族（角度标注除外）换算单位设置单位格式。
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
      274 : if Assigned(LDimStyle) then LDimStyle.AltUnitsProp.Precision := Byte(StrToIntDef(ARecord.Value, 3)); // DIMALTTD 设置标注换算单位公差值小数位的位数
      171 : if Assigned(LDimStyle) then ; // DIMALTD  控制换算单位中小数位的位数。



      {
      279 : if Assigned(LDimStyle) then ; // DIMTMOVE  设置标注文字的移动规则。
      284 : if Assigned(LDimStyle) then ; // DIMTZIN  控制是否对公差值作消零处理。
      286 : if Assigned(LDimStyle) then ; // DIMALTTZ 控制是否对公差值作消零处理。

      276 : if Assigned(LDimStyle) then ; // DIMFRAC  在 dimlunit 系统变量设置为：4（建筑）或 5（分数）时设置分数格式，0．水平 1．斜 2．不堆叠
      289 : if Assigned(LDimStyle) then ; // DIMATFIT 当尺寸界线的空间不足以同时放下标注文字和箭头时，本系统变量将确定这两者的排列方式
      288 : if Assigned(LDimStyle) then ; // DIMUPT   控制用户定位文字的选项。0光标仅控制尺寸线的位置 1光标控制文字以及尺寸线的位置
      283 : if Assigned(LDimStyle) then ; // DIMTOLJ   设置公差值相对名词性标注文字的垂直对正方式：0．下 1．中间 2．上
      142 : if Assigned(LDimStyle) then ; // DIMTSZ 指定线性标注、半径标注以及直径标注中替代箭头的小斜线尺寸。
      145 : if Assigned(LDimStyle) then ; // DIMTVP  控制尺寸线上方或下方标注文字的垂直位置。当 dimtad 设置为关时，autocad 将使用 dimtvp 的值。
      146 : if Assigned(LDimStyle) then ; // DIMTFAC 按照 dimtxt 系统变量的设置，相对于标注文字高度给分数值和公差值的文字高度指定比例因子。
      148 : if Assigned(LDimStyle) then ; // DIMALTRND 舍入换算标注单位。
      71  : if Assigned(LDimStyle) then ; // DIMTOL   将公差附在标注文字之后。将 dimtol 设置为“开”，将关闭 dimlim 系统变量。
      72  : if Assigned(LDimStyle) then ; // DIMLIM   将极限尺寸生成为默认文字。
      73  : if Assigned(LDimStyle) then ; // DIMTIH   控制所有标注类型（坐标标注除外）的标注文字在尺寸界线内的位置
      179 : if Assigned(LDimStyle) then ; // DIMADEC  1.使用 dimdec 设置的小数位数绘制角度标注；0-8 使用 dimadec 设置的小数位数绘制角度标注。
      271 : if Assigned(LDimStyle) then ; // DIMDEC   设置标注主单位显示的小数位位数。精度基于选定的单位或角度格式。

      172 : if Assigned(LDimStyle) then ; // DIMTOFL  控制是否将尺寸线绘制在尺寸界线之间（即使文字放置在尺寸界线之外）
      173 : if Assigned(LDimStyle) then ; // DIMSAH   控制尺寸线箭头块的显示。
      174 : if Assigned(LDimStyle) then ; // DIMTIX   在尺寸界线之间绘制文字
      175 : if Assigned(LDimStyle) then ; // DIMSOXD  控制是否允许尺寸线绘制到尺寸界线之外：关．不消除尺寸线 开．消除尺寸线
      46  : if Assigned(LDimStyle) then ; // DIMDLE   当使用小斜线代替箭头进行标注时，设置尺寸线超出尺寸界线的距离。
      47  : if Assigned(LDimStyle) then ; // DIMTP    在dimtol 或 dimlim 系统变量设置为开的情况下，为标注文字设置最大（上）偏差
      48  : if Assigned(LDimStyle) then ; // DIMTM    在dimtol 或 dimlim 系统变量设置为开的情况下，为标注文字设置最小（下）偏差
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