{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfReadObjects;

{$I UdDefs.INC}
//{$DEFINE IMAGE_ }

interface

uses
  Types, UdTypes,
  UdDxfTypes, UdDxfReadSection;

type

  TUdDxfReadObjects = class(TUdDxfReadSection)
  protected
    procedure AddLayout();
    procedure AddImageDef();

  public
    procedure Execute(); override;

  end;


implementation

uses
  SysUtils,
  UdPlotConfig, UdLayout, UdDxfReader, UdHashMaps, UdPrinters, UdMath, UdGeo2D;





//==================================================================================================
{ TUdDxfReadObjects }


procedure TUdDxfReadObjects.AddLayout();


  function _GetPaperSize(APrinterName, APaperName: string): TUdPageSize;
  var
    I, N: Integer;
    LPaperName: string;
    LPrinter: TUdCustomPrinter;
    LDefPaperNames: TStringDynArray;
  begin
    Result := -1;
     
    LPrinter := nil;
    if (APrinterName <> '') and (LowerCase(APrinterName) <> 'none_device') then
    begin
      N := UdPrinters.GlobalPrinters.IndexOf(APrinterName);
      if N >= 0 then LPrinter := UdPrinters.GlobalPrinters.Items[N];
    end;

    if Assigned(LPrinter) then
    begin
      if LPrinter.Papers.IndexOf(APaperName) >= 0 then
        Result := LPrinter.GetPaperSize(APaperName);
    end;

    if Result <= 0 then
    begin
      LPaperName := UpperCase(APaperName);
      LDefPaperNames := UdPrinters.GetDefPaperNames();
      for I := 0 to Length(LDefPaperNames) - 1 do
      begin
        if Pos(UpperCase(LDefPaperNames[I]), LPaperName) > 0 then
        begin
          Result := UdPrinters.GetDefPaperSize(I);
          Break;
        end;
      end;
    end;

    if Result <= 0 then Result := 9; {A4}
  end;

  function _GetVPortLogicBounds(ABounds: TRect2D; ALgHeight: Float; ALgCenter: TPoint2D): TRect2D;
  var
    LLgWidth: Float;
  begin
    LLgWidth := ALgHeight * (ABounds.X2 - ABounds.X1) / (ABounds.Y2 - ABounds.Y1);

    Result.X1 :=  ALgCenter.X - (LLgWidth / 2);
    Result.X2 :=  ALgCenter.X + (LLgWidth / 2);
    Result.Y1 :=  ALgCenter.Y - (ALgHeight / 2);
    Result.Y2 :=  ALgCenter.Y + (ALgHeight / 2);
  end;


var
  LPaperName: string;
  LRecords: TUdStrStrHashMap;
  LLayout: TUdLayout;
  LLogicBound: TRect2D;
  LLayoutRec: PUdDxfLayoutRec;
  LPlotConfig: TUdPlotConfig;
  LPaperLimMin, LPaperLimMax: TPoint2D;
  LVPortExtMin, LVPortExtMax: TPoint2D;
begin
  LRecords := TUdStrStrHashMap.Create();
  try
    repeat
      Self.ReadCurrentRecord();
      if (Self.CurrRecord.Code = 14) then
        if Self.LinePos > 0 then ;
      LRecords.Add(IntToStr(Self.CurrRecord.Code), Self.CurrRecord.Value);
    until (Self.CurrRecord.Code = 0);

    LLayoutRec := TUdDxfReader(FOwner).GetLayoutRec(LRecords.GetValue('330'));
    if Assigned(LLayoutRec) then
    begin
      LLayout := TUdLayout(LLayoutRec^.Layout);
      LPlotConfig := LLayout.PlotConfig;

      LPlotConfig.PrinterName   := LRecords.GetValue('2');
      LPlotConfig.PlotWindow.X1 := StrToFloatDef(LRecords.GetValue('48 '), 0);
      LPlotConfig.PlotWindow.Y1 := StrToFloatDef(LRecords.GetValue('49 '), 0);
      LPlotConfig.PlotWindow.X2 := StrToFloatDef(LRecords.GetValue('140'), 0);
      LPlotConfig.PlotWindow.Y2 := StrToFloatDef(LRecords.GetValue('141'), 0);
      LPlotConfig.Orientation   := StrToIntDef(LRecords.GetValue('73'), 1);

      LPaperName := LRecords.GetValue('4');
      LPlotConfig.PaperSize := _GetPaperSize(LPlotConfig.PrinterName, LPaperName);

      LPaperLimMin.X := StrToFloatDef(LRecords.GetValue('10'), 0);
      LPaperLimMin.Y := StrToFloatDef(LRecords.GetValue('20'), 0);
      LPaperLimMax.X := StrToFloatDef(LRecords.GetValue('11'), 297);
      LPaperLimMax.Y := StrToFloatDef(LRecords.GetValue('21'), 210);

      LVPortExtMin.X := StrToFloatDef(LRecords.GetValue('14'), 30);
      LVPortExtMin.Y := StrToFloatDef(LRecords.GetValue('24'), 30);
      LVPortExtMax.X := StrToFloatDef(LRecords.GetValue('15'), 260);
      LVPortExtMax.Y := StrToFloatDef(LRecords.GetValue('25'), 180);

      if not LLayout.ModelType then
      begin
        if (LVPortExtMax.X >= LVPortExtMin.X) and (LVPortExtMax.Y >= LVPortExtMin.Y) then
        begin
          LLayout.PlotConfig := LPlotConfig;
          LLayout.PaperLimMin := LPaperLimMin;
          LLayout.PaperLimMax := LPaperLimMax;
                
          LLayout.ViewPort.BoundsRect := Rect2D(LVPortExtMin, LVPortExtMax);

          if IsValidRect(LLayout.ViewPort.BoundsRect) then
          begin
            LLogicBound := _GetVPortLogicBounds(LLayout.ViewPort.BoundsRect,
                                               LLayoutRec^.VPortLgHeight, LLayoutRec^.VPortLgCenter);
            LLayout.ViewPort.UpdateAxes(LLogicBound);
            LLayout.ViewPort.UpdateVisibleList();
          end;
        end;
        
//        LLayout.InitViewport();
      end;
    end;
  finally
    LRecords.Free;
  end;
end;

procedure TUdDxfReadObjects.AddImageDef();
var
  LHandle: string;
  LImgPath: string;
begin
  repeat
    Self.ReadCurrentRecord();

    case Self.CurrRecord.Code of
      1: LImgPath := Self.CurrRecord.Value;
      5: LHandle  := Self.CurrRecord.Value;
    end;
  until (Self.CurrRecord.Code = 0);

  if (LHandle <> '') and (LImgPath <> '') then ;
end;




procedure TUdDxfReadObjects.Execute;
begin
  repeat
   
    if Self.CurrRecord.Code = 0 then
    begin
      if (Self.CurrRecord.Value = 'LAYOUT') then
      begin
        Self.AddLayout();
      end
      else if (Self.CurrRecord.Value = 'IMAGEDEF') then
      begin
        Self.AddImageDef();
      end
      else begin
        Self.ReadCurrentRecord();
        while Self.CurrRecord.Code <> 0 do Self.ReadCurrentRecord();
      end;
    end
    else
      Self.ReadCurrentRecord();

  until (Self.CurrRecord.Value = 'ENDSEC') or (Self.CurrRecord.Value = 'EOF');
end;





end.