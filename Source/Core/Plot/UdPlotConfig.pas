{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdPlotConfig;

{$I UdDefs.INC}

interface

uses
  Windows, Classes,
  UdTypes, UdGTypes, UdXml;

type
  TUdPlotImageFormat = (pifBmp, pifJpg);

  //*** TUdPlotConfig ***//
  TUdPlotConfig = record
    PrinterName: string;
    PaperSize: Integer;
    Orientation: Integer;
    CopiesNumber: Integer;

    PlotToFile: Boolean;
    FileFormat: TUdPlotImageFormat; // BMP, JPG

    PlotWindow: TRect2D;

    ScaleLineweights: Boolean;
    ForceColorBlock: Boolean;
  end;

  PUdPlotConfig = ^TUdPlotConfig;


  TUdPlotConfigEvent = procedure(Sender: TObject; AConfig: TUdPlotConfig) of object;


procedure InitPlotConfig(var AConfig: TUdPlotConfig);

procedure PlotConfigToStream(AStream: TStream; AValue: TUdPlotConfig);
function PlotConfigFromStream(AStream: TStream): TUdPlotConfig;

procedure PlotConfigToXml(AXmlNode: TUdXmlNode; AValue: TUdPlotConfig);
function PlotConfigFromXml(AXmlNode: TUdXmlNode): TUdPlotConfig;



implementation

uses
  SysUtils, UdStrConverter, UdStreams;



//================================================================================================


procedure InitPlotConfig(var AConfig: TUdPlotConfig);
begin
  AConfig.PrinterName      := '';
  AConfig.PaperSize        := DMPAPER_A4; //'A4';
  AConfig.Orientation      := 1;
  AConfig.CopiesNumber     := 1;

  AConfig.PlotToFile       := False;
  AConfig.FileFormat       := pifBmp;

  AConfig.PlotWindow.X1    := 0;
  AConfig.PlotWindow.Y1    := 0;
  AConfig.PlotWindow.X2    := 0;
  AConfig.PlotWindow.Y2    := 0;

  AConfig.ScaleLineweights := False;
  AConfig.ForceColorBlock  := False;
end;



procedure PlotConfigToStream(AStream: TStream; AValue: TUdPlotConfig);
begin
  StrToStream(AStream  , AValue.PrinterName    );
  IntToStream(AStream  , AValue.PaperSize      );
  IntToStream(AStream  , AValue.Orientation    );
  IntToStream(AStream  , AValue.CopiesNumber   );

  BoolToStream(AStream , AValue.PlotToFile     );
  IntToStream(AStream  , Ord(AValue.FileFormat) );

  FloatToStream(AStream, AValue.PlotWindow.X1  );
  FloatToStream(AStream, AValue.PlotWindow.Y1  );
  FloatToStream(AStream, AValue.PlotWindow.X2  );
  FloatToStream(AStream, AValue.PlotWindow.Y2  );


  BoolToStream(AStream , AValue.ScaleLineweights);
  BoolToStream(AStream , AValue.ForceColorBlock );
end;

function PlotConfigFromStream(AStream: TStream): TUdPlotConfig;
begin
  Result.PrinterName   := StrFromStream(AStream);
  Result.PaperSize     := IntFromStream(AStream);
  Result.Orientation   := IntFromStream(AStream);
  Result.CopiesNumber  := IntFromStream(AStream);

  Result.PlotToFile    := BoolFromStream(AStream);
  Result.FileFormat    := TUdPlotImageFormat( IntFromStream(AStream) );

  Result.PlotWindow.X1 := FloatFromStream(AStream);
  Result.PlotWindow.Y1 := FloatFromStream(AStream);
  Result.PlotWindow.X2 := FloatFromStream(AStream);
  Result.PlotWindow.Y2 := FloatFromStream(AStream);

  Result.ScaleLineweights := BoolFromStream(AStream);
  Result.ForceColorBlock  := BoolFromStream(AStream);
end;





procedure PlotConfigToXml(AXmlNode: TUdXmlNode; AValue: TUdPlotConfig);
begin
  AXmlNode.Name := 'PlotConfig';

  AXmlNode.Prop['PrinterName']   := AValue.PrinterName;
  AXmlNode.Prop['PaperSize']     := IntToStr(AValue.PaperSize);
  AXmlNode.Prop['Orientation']   := IntToStr(AValue.Orientation);
  AXmlNode.Prop['CopiesNumber']  := IntToStr(AValue.CopiesNumber);

  AXmlNode.Prop['PlotToFile']    := BoolToStr(AValue.PlotToFile, True);
  AXmlNode.Prop['FileFormat']    := IntToStr(Ord(AValue.FileFormat));

  AXmlNode.Prop['PlotWindow']    := Point2DToStr(AValue.PlotWindow.P1) + '~' + Point2DToStr(AValue.PlotWindow.P2);

  AXmlNode.Prop['ScaleLineweights'] := BoolToStr(AValue.ScaleLineweights, True);
  AXmlNode.Prop['ForceColorBlock']  := BoolToStr(AValue.ForceColorBlock, True);
end;

function PlotConfigFromXml(AXmlNode: TUdXmlNode): TUdPlotConfig;
var
  N: Integer;
  LStr, LS1, LS2: string;
begin
  Result.PrinterName   := AXmlNode.Prop['PrinterName'];
  Result.PaperSize     := StrToIntDef(AXmlNode.Prop['PaperSize'], DMPAPER_A4);
  Result.Orientation   := StrToIntDef(AXmlNode.Prop['Orientation'], 1);
  Result.CopiesNumber  := StrToIntDef(AXmlNode.Prop['CopiesNumber'], 1);

  Result.PlotToFile    := StrToBoolDef(AXmlNode.Prop['PlotToFile'], False);
  Result.FileFormat    := TUdPlotImageFormat( StrToIntDef(AXmlNode.Prop['FileFormat'], 0) );

  LStr := AXmlNode.Prop['PlotWindow'];

  N := Pos('~', LStr);
  LS1 := Copy(LStr, 1, N-1);
  LS2 := Copy(LStr, N+1, Length(LStr));

  Result.PlotWindow.P1 := StrToPoint2D(LS1);
  Result.PlotWindow.P2 := StrToPoint2D(LS2);

  Result.ScaleLineweights := StrToBoolDef(AXmlNode.Prop['ScaleLineweights'], False);
  Result.ForceColorBlock  := StrToBoolDef(AXmlNode.Prop['ForceColorBlock'] , False);
end;





end.