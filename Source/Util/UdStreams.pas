unit UdStreams;

{$I UdDefs.Inc}

interface

uses
  Windows, Classes, Types, UdGTypes;

function BoolFromStream(AStream: TStream): Boolean;
function ByteFromStream(AStream: TStream): Byte;
function SmallIntFromStream(AStream: TStream): SmallInt;
function IntFromStream(AStream: TStream): Integer;
function CarFromStream(AStream: TStream): LongWord;
function StrFromStream(AStream: TStream): string;
function WordFromStream(AStream: TStream): Word;
function FloatFromStream(AStream: TStream): Float;
function SingleFromStream(AStream: TStream): Single;
function SizeFromStream(AStream: TStream): TSize;
function RectFromStream(AStream: TStream): TRect;
function DWordFromStream(AStream: TStream): DWord;
function PointFromStream(AStream: TStream): TPoint;
procedure StreamFromStream(ASource, ASubStream: TStream);


procedure BoolToStream(AStream: TStream; AValue: Boolean);
procedure ByteToStream(AStream: TStream; AValue: Byte);
procedure SmallIntToStream(AStream: TStream; AValue: SmallInt);
procedure IntToStream(AStream: TStream; AValue: Integer);
procedure CarToStream(AStream: TStream; AValue: LongWord);
procedure StrToStream(AStream: TStream; AValue: string);
procedure WordToStream(AStream: TStream; AValue: Word);
procedure FloatToStream(AStream: TStream; AValue: Float);
procedure SingleToStream(AStream: TStream; AValue: Single);
procedure SizeToStream(AStream: TStream; AValue: TSize);
procedure RectToStream(AStream: TStream; AValue: TRect);
procedure DWordToStream(AStream: TStream; AValue: DWord);
procedure PointToStream(AStream: TStream; AValue: TPoint);
procedure StreamToStream(AStream, ASubStream: TStream);




//----------------------------------------------------------------------------

procedure Point2DToStream(AStream: TStream; AValue: TPoint2D);
procedure Line2DToStream(AStream: TStream; AValue: TLine2D);
procedure Segment2DToStream(AStream: TStream; AValue: TSegment2D);
procedure Rect2DToStream(AStream: TStream; AValue: TRect2D);
procedure Circle2DToStream(AStream: TStream; AValue: TCircle2D);
procedure Arc2DToStream(AStream: TStream; AValue: TArc2D);
procedure Ellipse2DToStream(AStream: TStream; AValue: TEllipse2D);
procedure Segarc2DToStream(AStream: TStream; AValue: TSegarc2D);
procedure Spline2DToStream(AStream: TStream; AValue: TSpline2D);

function Point2DFromStream(AStream: TStream): TPoint2D;
function Line2DFromStream(AStream: TStream): TLine2D;
function Segment2DFromStream(AStream: TStream): TSegment2D;
function Rect2DFromStream(AStream: TStream): TRect2D;
function Circle2DFromStream(AStream: TStream): TCircle2D;
function Arc2DFromStream(AStream: TStream): TArc2D;
function Ellipse2DFromStream(AStream: TStream): TEllipse2D;
function Segarc2DFromStream(AStream: TStream): TSegarc2D;
function Spline2DFromStream(AStream: TStream): TSpline2D;


//-------------------------------------------------------------------------------------------
//procedure IntsToStream(Stream: TStream; var AInts: TIntArray);
//function IntsFromStream(Stream: TStream): TIntArray;


function BytesFromStream(AStream: TMemoryStream; ACount: Integer): TByteDynArray;  overload;

procedure BytesToStream(AStream: TMemoryStream; ABytes: TByteDynArray);
function BytesFromStream(AStream: TMemoryStream): TByteDynArray; overload;

procedure FloatsToStream(Stream: TStream; AFloats: TFloatArray);
function FloatsFromStream(Stream: TStream): TFloatArray;


procedure PointsToStream(AStream: TStream; APoints: TPoint2DArray);
function PointsFromStream(AStream: TStream): TPoint2DArray;

procedure LinesToStream(AStream: TStream; ALines: TLine2DArray);
function LinesFromStream(AStream: TStream): TLine2DArray;

procedure SegmentsToStream(AStream: TStream; ASegments: TSegment2DArray);
function SegmentsFromStream(AStream: TStream): TSegment2DArray;

procedure ArcsToStream(AStream: TStream; AArcs: TArc2DArray);
function ArcsFromStream(AStream: TStream): TArc2DArray;

procedure EllipsesToStream(AStream: TStream; AEllipses: TEllipse2DArray);
function EllipsesFromStream(AStream: TStream): TEllipse2DArray;


procedure VertexesToStream(AStream: TStream; AVertexes: TVertexes2D);
function VertexesFromStream(AStream: TStream): TVertexes2D;

procedure SegarcsToStream(AStream: TStream; ASegarcs: TSegarc2DArray);
function SegarcsFromStream(AStream: TStream): TSegarc2DArray;

procedure PointsArrayToStream(AStream: TStream; APointsArray: TPoint2DArrays);
function PointsArrayFromStream(AStream: TStream): TPoint2DArrays;



procedure CurveToStream(AStream: TStream; ACurve: TCurve2D);
function CurveFromStream(AStream: TStream): TCurve2D;

procedure CurvesToStream(AStream: TStream; ACurves: TCurve2DArray);
function CurvesFromStream(AStream: TStream): TCurve2DArray;




const
  INC_MEM_DELTA = $100000; { Must be a power of 2 } //1M

type
  TMemoryStreamEx = class(TMemoryStream)
  private
    FIncMemDelta: Integer;
  protected
    function Realloc(var ANewCapacity: Longint): Pointer; override;
  public
    constructor Create(AIncMemoryDelta: Integer = INC_MEM_DELTA);
  end;

//----------------------------------------------------------------------------------

function StreamToHexStr(AStream: TStream): AnsiString;
function HexStrToStream(AHexStr: AnsiString; AStream: TMemoryStream): Boolean;



//----------------------------------------------------------------------------------

procedure CompressStream(AStream: TMemoryStream);
procedure UnCompressStream(AStream: TMemoryStream);

implementation

uses
  ZLib;


const
  FM_CREATE = $FFFF;




//==============================================================================================
{ TMemoryStreamEx }

constructor TMemoryStreamEx.Create(AIncMemoryDelta: Integer = INC_MEM_DELTA);
begin
  FIncMemDelta := AIncMemoryDelta;
end;

function TMemoryStreamEx.Realloc(var ANewCapacity: Integer): Pointer;
begin
  if (ANewCapacity > 0) and (ANewCapacity <> Self.Size) then
    ANewCapacity := (ANewCapacity + (FIncMemDelta - 1)) and not (FIncMemDelta - 1);
  Result := Memory;
  if ANewCapacity <> Self.Capacity then
  begin
    if ANewCapacity = 0 then
    begin
{$IFDEF MSWINDOWS}
      GlobalFreePtr(Memory);
{$ELSE}
      FreeMem(Memory);
{$ENDIF}
      Result := nil;
    end
    else
    begin
{$IFDEF MSWINDOWS}
{$WARNINGS OFF}
      if Capacity = 0 then
        Result := GlobalAllocPtr(HeapAllocFlags, ANewCapacity)
      else
        Result := GlobalReallocPtr(Memory, ANewCapacity, HeapAllocFlags);
{$WARNINGS ON}
{$ELSE}
      if Capacity = 0 then
        GetMem(Result, ANewCapacity)
      else
        ReallocMem(Result, ANewCapacity);
{$ENDIF}
      Assert(Result <> nil);
    end;
  end;
end;



procedure CompressStream(AStream: TMemoryStream);
var
  LSourceStream: TCompressionStream;
  LDestStream: TMemoryStream;
  LCount: Integer;
begin
  LCount := AStream.Size;
  LDestStream := TMemoryStream.Create;
  LSourceStream := TCompressionStream.Create(clDefault, LDestStream);
  try
    AStream.SaveToStream(LSourceStream);
    LSourceStream.Free;
    AStream.Clear;
    AStream.WriteBuffer(LCount, SizeOf(LCount));

    AStream.CopyFrom(LDestStream, 0);
    AStream.Seek(0, soFromBeginning);
  finally
    LDestStream.Free;
  end;
end;


procedure UnCompressStream(AStream: TMemoryStream);
var
  LBuffer: PChar;
  LCount: Integer;
  LSourceStream: TDecompressionStream;
begin
  AStream.ReadBuffer(LCount, SizeOf(LCount));
  GetMem(LBuffer, LCount);
  LSourceStream := TDecompressionStream.Create(AStream);
  try
    LSourceStream.ReadBuffer(LBuffer^, LCount);
    AStream.Clear;
    AStream.WriteBuffer(LBuffer^, LCount);
    AStream.Seek(0, soFromBeginning);
  finally
    FreeMem(LBuffer);
    LSourceStream.Free;
  end;
end;


function StreamToHexStr(AStream: TStream): AnsiString;
begin
  Result := '';
  if not Assigned(AStream) or (AStream.Size <= 0) then Exit;

  System.SetLength(Result, AStream.Size);

  AStream.Position := 0;
  AStream.ReadBuffer(Result[1], AStream.Size);
end;


function HexStrToStream(AHexStr: AnsiString; AStream: TMemoryStream): Boolean;
var
  L: Integer;
begin
  Result := False;
  if System.Length(AHexStr) <= 0 then Exit;

  L := System.Length(AHexStr);
  AStream.SetSize(AStream.Size + L);
  AStream.Write(AHexStr[1], L);

  Result := True;
end;



//==============================================================================================

function BoolFromStream(AStream: TStream): Boolean;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function ByteFromStream(AStream: TStream): Byte;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function SmallIntFromStream(AStream: TStream): SmallInt;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function DWordFromStream(AStream: TStream): DWord;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function FloatFromStream(AStream: TStream): Float;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function SingleFromStream(AStream: TStream): Single;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function IntFromStream(AStream: TStream): Integer;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function CarFromStream(AStream: TStream): LongWord;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function WordFromStream(AStream: TStream): Word;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function PointFromStream(AStream: TStream): TPoint;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function RectFromStream(AStream: TStream): TRect;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

function SizeFromStream(AStream: TStream): TSize;
begin
  AStream.ReadBuffer(Result, SizeOf(Result));
end;

procedure StreamFromStream(ASource, ASubStream: TStream);
var
  LStreamSize: Integer;
begin
  LStreamSize := IntFromStream(ASource);
  if LStreamSize > 0 then
  begin
    ASubStream.CopyFrom(ASource, LStreamSize);
    ASubStream.Seek(0, soFromBeginning);
  end;
end;

function StrFromStream(AStream: TStream): string;
var
  LStr: AnsiString;
  L: Integer;
begin
  Result := '';
  L := IntFromStream(AStream);
  if L > 0 then
  begin
    System.SetLength(LStr, L);
    AStream.ReadBuffer(LStr[1], L);

    Result := string(LStr);
  end;
end;








//----------------------------------------------------------------------------------------------

procedure BoolToStream(AStream: TStream; AValue: Boolean);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure ByteToStream(AStream: TStream; AValue: Byte);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure SmallIntToStream(AStream: TStream; AValue: SmallInt);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure IntToStream(AStream: TStream; AValue: Integer);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure DWordToStream(AStream: TStream; AValue: DWord);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure FloatToStream(AStream: TStream; AValue: Float);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure SingleToStream(AStream: TStream; AValue: Single);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure CarToStream(AStream: TStream; AValue: LongWord);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure WordToStream(AStream: TStream; AValue: Word);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure PointToStream(AStream: TStream; AValue: TPoint);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure RectToStream(AStream: TStream; AValue: TRect);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure SizeToStream(AStream: TStream; AValue: TSize);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

procedure StreamToStream(AStream, ASubStream: TStream);
var
  LStreamSize: Integer;
begin
  LStreamSize := ASubStream.Size;
  IntToStream(AStream, LStreamSize);
  if LStreamSize > 0 then
  begin
    ASubStream.Seek(0, soFromBeginning);
    AStream.CopyFrom(ASubStream, LStreamSize);
  end;
end;

procedure StrToStream(AStream: TStream; AValue: string);
var
  L: Integer;
  LStr: AnsiString;
begin
  LStr := AnsiString(AValue);
  L := System.Length(LStr);
  IntToStream(AStream, L);
  if L > 0 then
    AStream.WriteBuffer(LStr[1], L);
end;















//==============================================================================================

procedure Point2DToStream(AStream: TStream; AValue: TPoint2D);
begin
  FloatToStream(AStream, AValue.X);
  FloatToStream(AStream, AValue.Y);
end;

procedure Line2DToStream(AStream: TStream; AValue: TLine2D);
begin
  Point2DToStream(AStream, AValue.P1);
  Point2DToStream(AStream, AValue.P2);
end;

procedure Segment2DToStream(AStream: TStream; AValue: TSegment2D);
begin
  Point2DToStream(AStream, AValue.P1);
  Point2DToStream(AStream, AValue.P2);
end;

procedure Rect2DToStream(AStream: TStream; AValue: TRect2D);
begin
  FloatToStream(AStream, AValue.X1);
  FloatToStream(AStream, AValue.Y1);
  FloatToStream(AStream, AValue.X2);
  FloatToStream(AStream, AValue.Y2);
end;

procedure Circle2DToStream(AStream: TStream; AValue: TCircle2D);
begin
  FloatToStream(AStream, AValue.R);
  Point2DToStream(AStream, AValue.Cen);
end;

procedure Arc2DToStream(AStream: TStream; AValue: TArc2D);
begin
  FloatToStream(AStream, AValue.R);
  Point2DToStream(AStream, AValue.Cen);
  FloatToStream(AStream, AValue.Ang1);
  FloatToStream(AStream, AValue.Ang2);
  BoolToStream(AStream, AValue.IsCW);
  IntToStream(AStream, Ord(AValue.Kind));
end;

procedure Ellipse2DToStream(AStream: TStream; AValue: TEllipse2D);
begin
  Point2DToStream(AStream, AValue.Cen);
  FloatToStream(AStream, AValue.Rx);
  FloatToStream(AStream, AValue.Ry);
  FloatToStream(AStream, AValue.Ang1);
  FloatToStream(AStream, AValue.Ang2);
  FloatToStream(AStream, AValue.Rot);
  BoolToStream(AStream, AValue.IsCW);
  IntToStream(AStream, Ord(AValue.Kind));
end;

procedure Segarc2DToStream(AStream: TStream; AValue: TSegarc2D);
begin
  BoolToStream(AStream, AValue.IsArc);
  Segment2DToStream(AStream, AValue.Seg);
  if AValue.IsArc then
    Arc2DToStream(AStream, AValue.Arc);
end;

procedure Spline2DToStream(AStream: TStream; AValue: TSpline2D);
begin
  PointsToStream(AStream, AValue.CtlPnts);
  FloatsToStream(AStream, AValue.Knots);
  IntToStream(AStream, AValue.Degree);
end;




function Point2DFromStream(AStream: TStream): TPoint2D;
begin
  Result.X := FloatFromStream(AStream);
  Result.Y := FloatFromStream(AStream);
end;

function Line2DFromStream(AStream: TStream): TLine2D;
begin
  Result.P1 := Point2DFromStream(AStream);
  Result.P2 := Point2DFromStream(AStream);
end;

function Segment2DFromStream(AStream: TStream): TSegment2D;
begin
  Result.P1 := Point2DFromStream(AStream);
  Result.P2 := Point2DFromStream(AStream);
end;

function Rect2DFromStream(AStream: TStream): TRect2D;
begin
  Result.X1 := FloatFromStream(AStream);
  Result.Y1 := FloatFromStream(AStream);
  Result.X2 := FloatFromStream(AStream);
  Result.Y2 := FloatFromStream(AStream);
end;

function Circle2DFromStream(AStream: TStream): TCircle2D;
begin
  Result.R := FloatFromStream(AStream);
  Result.Cen := Point2DFromStream(AStream);
end;

function Arc2DFromStream(AStream: TStream): TArc2D;
begin
  Result.R := FloatFromStream(AStream);
  Result.Cen := Point2DFromStream(AStream);
  Result.Ang1 := FloatFromStream(AStream);
  Result.Ang2 := FloatFromStream(AStream);
  Result.IsCW := BoolFromStream(AStream);
  Result.Kind := TArcKind(IntFromStream(AStream));
end;

function Ellipse2DFromStream(AStream: TStream): TEllipse2D;
begin
  Result.Cen  := Point2DFromStream(AStream);
  Result.Rx   := FloatFromStream(AStream);
  Result.Ry   := FloatFromStream(AStream);
  Result.Ang1 := FloatFromStream(AStream);
  Result.Ang2 := FloatFromStream(AStream);
  Result.Rot  := FloatFromStream(AStream);
  Result.IsCW := BoolFromStream(AStream);
  Result.Kind := TArcKind(IntFromStream(AStream));
end;

function Segarc2DFromStream(AStream: TStream): TSegarc2D;
begin
  Result.IsArc := BoolFromStream(AStream);
  Result.Seg := Segment2DFromStream(AStream);
  if Result.IsArc then
    Result.Arc := Arc2DFromStream(AStream);
end;

function Spline2DFromStream(AStream: TStream): TSpline2D;
begin
  Result.CtlPnts := PointsFromStream(AStream);
  Result.Knots   := FloatsFromStream(AStream);
  Result.Degree  := IntFromStream(AStream);
end;




//----------------------------------------------------------------------------------------------

function BytesFromStream(AStream: TMemoryStream; ACount: Integer): TByteDynArray;
var
  LBuffer: TByteDynArray;
begin
  Result := nil;
  if (ACount <= 0) then Exit;

  System.SetLength(LBuffer, ACount);
  AStream.Read(LBuffer[0], ACount);

  Result := LBuffer;
end;

procedure BytesToStream(AStream: TMemoryStream; ABytes: TByteDynArray);
var
  I, L: Integer;
begin
  L := System.Length(ABytes);
  IntToStream(AStream, L);
  for I := Low(ABytes) to High(ABytes) do ByteToStream(AStream, ABytes[I]);
end;

function BytesFromStream(AStream: TMemoryStream): TByteDynArray;
var
  I, L: Integer;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);
  for I := 0 to L - 1 do Result[I] := ByteFromStream(AStream);
end;


{
procedure IntsToStream(Stream: TStream; AInts: TIntArray);
var
  I, L: Integer;
begin
  L := System.Length(AInts);
  IntToStream(Stream, L);
  for I := Low(AInts) to High(AInts) do IntToStream(Stream, AInts[I]);
end;

function IntsFromStream(Stream: TStream): TIntArray;
var
  I, L: Integer;
begin
  L := IntFromStream(Stream);
  System.SetLength(Result, L);
  for I := 0 to L - 1 do Result[I] := IntFromStream(Stream);
end;
}


procedure FloatsToStream(Stream: TStream; AFloats: TFloatArray);
var
  I, L: Integer;
begin
  L := System.Length(AFloats);
  IntToStream(Stream, L);
  for I := Low(AFloats) to High(AFloats) do FloatToStream(Stream, AFloats[I]);
end;

function FloatsFromStream(Stream: TStream): TFloatArray;
var
  I, L: Integer;
begin
  L := IntFromStream(Stream);
  System.SetLength(Result, L);
  for I := 0 to L - 1 do Result[I] := FloatFromStream(Stream);
end;





procedure PointsToStream(AStream: TStream; APoints: TPoint2DArray);
var
  I, L: Integer;
begin
  L := System.Length(APoints);
  IntToStream(AStream, L);
  for I := Low(APoints) to High(APoints) do
  begin
    FloatToStream(AStream, APoints[I].X);
    FloatToStream(AStream, APoints[I].Y);
  end;
end;

function PointsFromStream(AStream: TStream): TPoint2DArray;
var
  I, L: Integer;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
  begin
    Result[I].X := FloatFromStream(AStream);
    Result[I].Y := FloatFromStream(AStream);
  end;
end;




procedure LinesToStream(AStream: TStream; ALines: TLine2DArray);
var
  I, L: Integer;
  LLine: TLine2D;
begin
  L := System.Length(ALines);
  IntToStream(AStream, L);

  for I := Low(ALines) to High(ALines) do
  begin
    LLine := ALines[I];

    FloatToStream(AStream, LLine.P1.X);
    FloatToStream(AStream, LLine.P1.Y);
    FloatToStream(AStream, LLine.P2.X);
    FloatToStream(AStream, LLine.P2.Y);
  end;
end;

function LinesFromStream(AStream: TStream): TLine2DArray;
var
  I, L: Integer;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
  begin
    Result[I].P1.X := FloatFromStream(AStream);
    Result[I].P1.Y := FloatFromStream(AStream);
    Result[I].P2.X := FloatFromStream(AStream);
    Result[I].P2.Y := FloatFromStream(AStream);
  end;
end;




procedure SegmentsToStream(AStream: TStream; ASegments: TSegment2DArray);
var
  I, L: Integer;
  LSeg: TSegment2D;
begin
  L := System.Length(ASegments);
  IntToStream(AStream, L);

  for I := Low(ASegments) to High(ASegments) do
  begin
    LSeg := ASegments[I];

    FloatToStream(AStream, LSeg.P1.X);
    FloatToStream(AStream, LSeg.P1.Y);
    FloatToStream(AStream, LSeg.P2.X);
    FloatToStream(AStream, LSeg.P2.Y);
  end;
end;

function SegmentsFromStream(AStream: TStream): TSegment2DArray;
var
  I, L: Integer;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
  begin
    Result[I].P1.X := FloatFromStream(AStream);
    Result[I].P1.Y := FloatFromStream(AStream);
    Result[I].P2.X := FloatFromStream(AStream);
    Result[I].P2.Y := FloatFromStream(AStream);
  end;
end;


procedure ArcsToStream(AStream: TStream; AArcs: TArc2DArray);
var
  I, L: Integer;
  LArc: TArc2D;
begin
  L := System.Length(AArcs);
  IntToStream(AStream, L);

  for I := Low(AArcs) to High(AArcs) do
  begin
    LArc := AArcs[I];
    Arc2DToStream(AStream, LArc);
  end;
end;

function ArcsFromStream(AStream: TStream): TArc2DArray;
var
  I, L: Integer;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
    Result[I]:= Arc2DFromStream(AStream);
end;


procedure EllipsesToStream(AStream: TStream; AEllipses: TEllipse2DArray);
var
  I, L: Integer;
  LEll: TEllipse2D;
begin
  L := System.Length(AEllipses);
  IntToStream(AStream, L);

  for I := Low(AEllipses) to High(AEllipses) do
  begin
    LEll := AEllipses[I];
    Ellipse2DToStream(AStream, LEll);
  end;
end;

function EllipsesFromStream(AStream: TStream): TEllipse2DArray;
var
  I, L: Integer;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
    Result[I]:= Ellipse2DFromStream(AStream);
end;



procedure VertexesToStream(AStream: TStream; AVertexes: TVertexes2D);
var
  I, L: Integer;
begin
  L := System.Length(AVertexes);
  IntToStream(AStream, L);

  for I := 0 to L - 1 do
  begin
    Point2DToStream(AStream, AVertexes[I].Point);
    FloatToStream(AStream, AVertexes[I].Bulge);
  end;
end;

function VertexesFromStream(AStream: TStream): TVertexes2D;
var
  I, L: Integer;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
  begin
    Result[I].Point := Point2DFromStream(AStream);
    Result[I].Bulge := FloatFromStream(AStream);
  end;
end;


procedure SegarcsToStream(AStream: TStream; ASegarcs: TSegarc2DArray);
var
  I, L: Integer;
begin
  L := System.Length(ASegarcs);
  IntToStream(AStream, L);

  for I := Low(ASegarcs) to High(ASegarcs) do
    Segarc2DToStream(AStream, ASegarcs[I]);
end;

function SegarcsFromStream(AStream: TStream): TSegarc2DArray;
var
  I, L: Integer;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
    Result[I] := Segarc2DFromStream(AStream);
end;




//----------------------------------------------------------------------------


procedure PointsArrayToStream(AStream: TStream; APointsArray: TPoint2DArrays);
var
  I, J, L, N: Integer;
  LArray: TPoint2DArray;
begin
  L := System.Length(APointsArray);
  IntToStream(AStream, L);

  LArray := nil;
  for I := Low(APointsArray) to High(APointsArray) do
  begin
    LArray := APointsArray[I];

    N := System.Length(LArray);
    IntToStream(AStream, N);

    for J := Low(LArray) to High(LArray) do
    begin
      FloatToStream(AStream, LArray[J].X);
      FloatToStream(AStream, LArray[J].Y);
    end;
  end;
end;

function PointsArrayFromStream(AStream: TStream): TPoint2DArrays;
var
  I, J, L, N: Integer;
  LArray: TPoint2DArray;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
  begin
    N := IntFromStream(AStream);
    System.SetLength(LArray, N);

    for J := 0 to N - 1 do
    begin
      LArray[J].X := FloatFromStream(AStream);
      LArray[J].Y := FloatFromStream(AStream);
    end;

    Result[I] := LArray;
  end;
end;






procedure CurveToStream(AStream: TStream; ACurve: TCurve2D);
begin
  IntToStream(AStream, Ord(ACurve.Kind));
  case ACurve.Kind of
    ckPolyline: VertexesToStream( AStream, PVertexes2D(ACurve.Data)^);
    ckLine    : Segment2DToStream(AStream, PSegment2D(ACurve.Data)^);
    ckArc     : Arc2DToStream(    AStream, PArc2D(ACurve.Data)^);
    ckEllipse : Ellipse2DToStream(AStream, PEllipse2D(ACurve.Data)^);
    ckSpline  : Spline2DToStream( AStream, PSpline2D(ACurve.Data)^);
  end;
end;

function CurveFromStream(AStream: TStream): TCurve2D;
var
//  J: Integer;
  
  LVertexes  : TVertexes2D;
  LSegment   : TSegment2D;
  LArc       : TArc2D;
  LEll       : TEllipse2D;
  LSpline    : TSpline2D;

  LPVertexes : PVertexes2D;
  LPSegment  : PSegment2D;
  LPArc      : PArc2D;
  LPEll      : PEllipse2D;
  LPSpline   : PSpline2D;
begin
  Result.Kind := TCurveKind(IntFromStream(AStream));

  case Result.Kind of
    ckPolyline:
    begin
      LVertexes   := VertexesFromStream(AStream);
      LPVertexes  := New(PVertexes2D);

      LPVertexes^ := LVertexes;
//      SetLength(LPVertexes^, Length(LVertexes));
//      for J := 0 to Length(LVertexes) - 1 do LPVertexes^[J] := LVertexes[J];

      Result.Data := LPVertexes;
    end;

    ckLine:
    begin
      LSegment    := Segment2DFromStream(AStream);
      LPSegment   := New(PSegment2D);
      LPSegment^  := LSegment;
      Result.Data := LPSegment;
    end;

    ckArc:
    begin
      LArc        := Arc2DFromStream(AStream);
      LPArc       := New(PArc2D);
      LPArc^      := LArc;
      Result.Data := LPArc;
    end;

    ckEllipse :
    begin
      LEll        := Ellipse2DFromStream(AStream);
      LPEll       := New(PEllipse2D);
      LPEll^      := LEll;
      Result.Data := LPEll;
    end;

    ckSpline  :
    begin
      LSpline     := Spline2DFromStream(AStream);
      LPSpline    := New(PSpline2D);

      LPSpline^   := LSpline;
//      SetLength(LPSpline^.Knots, Length(LSpline.Knots));
//      for J := 0 to Length(LSpline.Knots) - 1 do LPSpline^.Knots[J] := LSpline.Knots[J];
        
//      SetLength(LPSpline^.CtlPnts, Length(LSpline.CtlPnts));
//      for J := 0 to Length(LSpline.CtlPnts) - 1 do LPSpline^.CtlPnts[J] := LSpline.CtlPnts[J];

      Result.Data := LPSpline;
    end;
  end;

  {
  case Result.Kind of
    ckPolyline: begin Result.Data := New(PVertexes2D);  PVertexes2D(Result.Data)^ := VertexesFromStream(AStream);  end;
    ckLine    : begin Result.Data := New(PSegment2D);   PSegment2D(Result.Data)^  := Segment2DFromStream(AStream); end;
    ckArc     : begin Result.Data := New(PArc2D);       PArc2D(Result.Data)^      := Arc2DFromStream(AStream);     end;
    ckEllipse : begin Result.Data := New(PEllipse2D);   PEllipse2D(Result.Data)^  := Ellipse2DFromStream(AStream); end;
    ckSpline  : begin Result.Data := New(PSpline2D);    PSpline2D(Result.Data)^   := Spline2DFromStream(AStream);  end;
  end;
  }
end;


procedure CurvesToStream(AStream: TStream; ACurves: TCurve2DArray);
var
  I, L: Integer;
begin
  L := System.Length(ACurves);
  IntToStream(AStream, L);

  for I := Low(ACurves) to High(ACurves) do
    CurveToStream(AStream, ACurves[I]);
end;

function CurvesFromStream(AStream: TStream): TCurve2DArray;
var
  I, L: Integer;
begin
  L := IntFromStream(AStream);
  System.SetLength(Result, L);

  for I := 0 to L - 1 do
    Result[I] := CurveFromStream(AStream);
end;




end.
