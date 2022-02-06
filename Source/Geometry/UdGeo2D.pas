{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdGeo2D;

{$I UdGeoDefs.INC}

interface

uses
  {$IFDEF UdTypes} UdTypes, {$ENDIF} UdGTypes;



//------------------------------------------------------------------------------------------------

function Point2D(X, Y: Float): TPoint2D;                                                                          {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Line2D(X1, Y1, X2, Y2: Float): TLine2D;                                                                  {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Line2D(Pnt1, Pnt2: TPoint2D): TLine2D;                                                                   {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Segment2D(X1, Y1, X2, Y2: Float): TSegment2D;                                                            {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Segment2D(Pnt1, Pnt2: TPoint2D): TSegment2D;                                                             {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Rect2D(X1, Y1, X2, Y2: Float): TRect2D;                                                                  {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Rect2D(Pnt1, Pnt2: TPoint2D): TRect2D;                                                                   {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;

function Circle2D(X, Y: Float; R: Float): TCircle2D;                                                              {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Circle2D(Cen: TPoint2D; R: Float): TCircle2D;                                                            {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Arc2D(Cen: TPoint2D; R: Float; Ang1, Ang2: Float; IsCW: Boolean = False; Kind: TArcKind = akCurve): TArc2D; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Arc2D(X, Y: Float; R: Float; Ang1, Ang2: Float; IsCW: Boolean = False; Kind: TArcKind = akCurve): TArc2D;   {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;

function LineK(K, B: Float; HasK: Boolean): TLineK;                                                               {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function LineK(X, Y, Ang: Float): TLineK;                                                                         {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function LineK(Pnt: TPoint2D; Ang: Float): TLineK;                                                                {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function LineK(X1, Y1, X2, Y2: Float): TLineK;                                                                    {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function LineK(Pnt1, Pnt2: TPoint2D): TLineK;                                                                     {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function LineK(B, Ang: Float): TLineK;                                                                            {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Ray2D(Pnt1, Pnt2: TPoint2D): TRay2D;                                                                     {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Ray2D(Pnt: TPoint2D; Ang: Float): TRay2D;                                                                {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Polygon2D(Rect: TRect2D): TPoint2DArray;
function Ellipse2D(Cen: TPoint2D; Rx, Ry: Float; Rot: Float = 0): TEllipse2D;                                     {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Ellipse2D(Cen: TPoint2D; Rx, Ry: Float; Ang1, Ang2: Float;
                   Rot: Float = 0; IsCW: Boolean = False; Kind: TArcKind = akCurve): TEllipse2D; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;

function Vertex2D(X, Y, Bulge: Float): TVertex2D;                                                                 {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;
function Vertex2D(Pnt: TPoint2D; Bulge: Float): TVertex2D;                                                        {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF} overload;

function Segarc2D(P1, P2: TPoint2D): TSegarc2D;                                                                   overload; // {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function Segarc2D(Seg: TSegment2D): TSegarc2D;                                                                    overload; // {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function Segarc2D(Arc: TArc2D): TSegarc2D;                                                                        overload; // {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function Segarc2D(P1, P2: TPoint2D; Bulge: Float): TSegarc2D;                                                     overload; // {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function Segarc2D(V1, V2: TVertex2D): TSegarc2D;                                                                  overload; // {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}

function Segarc2DArray(Vexs: TVertexes2D): TSegarc2DArray; overload;
function Segarc2DArray(Pnts: TPoint2DArray): TSegarc2DArray; overload;

function GetVertexBulge(P1, P2: TPoint2D; Arc: TArc2D): Float;                                                       // {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
function Vertexes2D(Segarcs: TSegarc2DArray; CheckPnts: Boolean = True): TVertexes2D;



//---------------------------------------------------------------------

function Quadrant(Angle: Float): Integer; overload;
function Quadrant(X, Y: Float): Integer; overload;
function Quadrant(Pnt: TPoint2D): Integer; overload;

function ShiftPoint(Px,Py, Dx,Dy, Dis: Float): TPoint2D; overload;
function ShiftPoint(SP, DP: TPoint2D; Dis: Float): TPoint2D; overload;
function ShiftPoint(Px,Py, Angle, Dis: Float): TPoint2D; overload;
function ShiftPoint(SP: TPoint2D; Angle, Dis: Float): TPoint2D; overload;

function ShiftArcPoint(Arc: TArc2D; Ang1Side: Boolean; Dis: Float): TPoint2D; overload;
function ShiftArcPoint(Cen: TPoint2D; R, Ang1, Ang2: Float; Ang1Side: Boolean; Dis: Float):TPoint2D; overload;


function GetAngle(Cx, Cy, Px, Py: Float; const Epsilon: Float = _Epsilon): Float; overload;
function GetAngle(Cen, Pnt: TPoint2D; const Epsilon: Float = _Epsilon): Float; overload;

function VertexAngle(X1, Y1, X2, Y2, X3, Y3: Float; const Epsilon: Float = _Epsilon): Float; overload;
function VertexAngle(Pnt1, Pnt2, Pnt3: TPoint2D; const Epsilon: Float = _Epsilon): Float; overload;

function IncludedAngle(P1: TPoint2D; P2: TPoint2D; P3: TPoint2D): Float;

function CartesianAngle(X, Y: Float; const Epsilon: Float = _Epsilon): Float;  overload;
function CartesianAngle(Point: TPoint2D; const Epsilon: Float = _Epsilon): Float;  overload;



function Signed(Px, Py: Float; X1, Y1, X2, Y2: Float): Float; overload;
function Signed(PntP, Pnt1, Pnt2: TPoint2D): Float; overload;
function Signed(Pnt: TPoint2D; Ln: TLine2D): Float; overload;
function Signed(Pnt: TPoint2D; Seg: TSegment2D): Float; overload;

function Orientation(Px, Py: Float; X1, Y1, X2, Y2: Float; Epsilon: Float = _HighiEpsilon): Longint; overload;
function Orientation(PntP, Pnt1, Pnt2: TPoint2D; Epsilon: Float = _HighiEpsilon): Longint; overload;
function Orientation(Pnt: TPoint2D; Ln: TLine2D; Epsilon: Float = _HighiEpsilon): Longint; overload;
function Orientation(Pnt: TPoint2D; Seg: TSegment2D; Epsilon: Float = _HighiEpsilon): Longint; overload;

function IsClockWise(Pnts: TPoint2DArray): Boolean; overload; // Is ClockWise ?
function IsClockWise(Arc: TArc2D; P1, P2: TPoint2D): Boolean; overload; // Is ClockWise ?


//---------------------------------------------------------------------

function IsCoincident(Pnt1, Pnt2: TPoint2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsCoincident(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsCoincident(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsCoincident(Rect1,Rect2: TRect2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsCoincident(Cir1, Cir2: TCircle2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsCoincident(Arc1, Arc2: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsCoincident(Ell1, Ell2: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsDegenerate(X1,Y1, X2,Y2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsDegenerate(Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsDegenerate(Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsDegenerate(Rect: TRect2D; const Epsilon: Float = _Epsilon):Boolean; overload;
function IsDegenerate(Cir: TCircle2D; const Epsilon: Float = _Epsilon):Boolean; overload;
function IsDegenerate(Arc: TArc2D; const Epsilon: Float = _Epsilon):Boolean; overload;
function IsDegenerate(Ell: TEllipse2D; const Epsilon: Float = _Epsilon):Boolean; overload;
function IsDegenerate(Segarc: TSegarc2D; const Epsilon: Float = _Epsilon):Boolean; overload;

function IsCollinear(X1, Y1, X2, Y2, X3, Y3: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsCollinear(Pnt1, Pnt2, Pnt3: TPoint2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsRobustCollinear(X1, Y1, X2, Y2, X3, Y3: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsRobustCollinear(Pnt1, Pnt2, Pnt3: TPoint2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntCollinear(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon; Robust: Boolean = False): Boolean; overload;
function IsPntCollinear(PntP, Pnt1, Pnt2: TPoint2D; const Epsilon: Float = _Epsilon; Robust: Boolean = False): Boolean; overload;
function IsPntCollinear(Pnt: TPoint2D; Ln: TLine2D; const Epsilon: Float = _Epsilon; Robust: Boolean = False): Boolean; overload;
function IsPntCollinear(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon; Robust: Boolean = False): Boolean; overload;


function IsPntOnLeftSide(Px,Py, x1,y1, x2,y2:Float):Boolean; overload;
function IsPntOnLeftSide(Pnt: TPoint2D; P1, P2: TPoint2D):Boolean; overload;
function IsPntOnLeftSide(X, Y: Float; Ln: TLine2D): Boolean; overload;
function IsPntOnLeftSide(Pnt: TPoint2D; Ln: TLine2D): Boolean; overload;
function IsPntOnLeftSide(Pnt: TPoint2D; Seg: TSegment2D): Boolean; overload;
function IsPntOnLeftSide(Pnt: TPoint2D; Arc: TArc2D): Boolean; overload;
function IsPntOnLeftSide(Pnt: TPoint2D; Ell: TEllipse2D): Boolean; overload;
function IsPntOnLeftSide(Pnt: TPoint2D; Segarc: TSegarc2D): Boolean; overload;

function IsPntOnRightSide(Px,Py, x1,y1, x2,y2:Float): Boolean; overload;
function IsPntOnRightSide(Pnt: TPoint2D; P1, P2: TPoint2D):Boolean; overload;
function IsPntOnRightSide(X, Y: Float; Ln: TLine2D): Boolean; overload;
function IsPntOnRightSide(Pnt: TPoint2D; Ln: TLine2D): Boolean; overload;
function IsPntOnRightSide(Pnt: TPoint2D; Seg: TSegment2D): Boolean; overload;
function IsPntOnRightSide(Pnt: TPoint2D; Arc: TArc2D): Boolean; overload;
function IsPntOnRightSide(Pnt: TPoint2D; Ell: TEllipse2D): Boolean; overload;
function IsPntOnRightSide(Pnt: TPoint2D; Segarc: TSegarc2D): Boolean; overload;

function IsConvexPolygon(Poly: TPoint2DArray): Boolean; overload;
function IsConvexPolygon(Poly: array of TPoint2D): Boolean; overload;



//---------------------------------------------------------------------

function IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float): Boolean; overload;
function IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D): Boolean; overload;
function IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out iX, iY: Float): Boolean; overload;
function IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D; out iX, iY: Float): Boolean; overload;

function IsIntersect(Ln1, Ln2: TLine2D): Boolean; overload;
function IsIntersect(Seg1, Seg2: TSegment2D): Boolean; overload;
function IsIntersect(Ln: TLine2D; Seg: TSegment2D): Boolean; overload;

function IsIntersect(Ln: TLine2D; Rect: TRect2D): Boolean; overload;
function IsIntersect(Seg: TSegment2D; Rect: TRect2D): Boolean; overload;

function IsIntersect(Ln: TLine2D; Cir: TCircle2D): Boolean; overload;
function IsIntersect(Seg: TSegment2D; Cir: TCircle2D): Boolean; overload;

function IsIntersect(Ln: TLine2D; Arc: TArc2D): Boolean; overload;
function IsIntersect(Seg: TSegment2D; Arc: TArc2D): Boolean; overload;


function IsIntersect(Ln: TLine2D; Poly: TPoint2DArray): Boolean; overload;
function IsIntersect(Seg: TSegment2D; Poly: TPoint2DArray): Boolean; overload;

function IsIntersect(Rect1, Rect2: TRect2D): Boolean; overload;
function IsIntersect(Rect: TRect2D; Cir: TCircle2D): Boolean; overload;
function IsIntersect(Rect: TRect2D; Arc: TArc2D): Boolean; overload;
function IsIntersect(Rect: TRect2D; Ell: TEllipse2D): Boolean; overload;
function IsIntersect(Rect: TRect2D; Poly: TPoint2DArray): Boolean; overload;

function IsIntersect(Cir1, Cir2: TCircle2D): Boolean; overload;
function IsIntersect(Cir: TCircle2D; Arc: TArc2D): Boolean; overload;
function IsIntersect(Cir: TCircle2D; Poly: TPoint2DArray): Boolean; overload;

function IsIntersect(Arc1, Arc2: TArc2D): Boolean; overload;
function IsIntersect(Arc: TArc2D; Poly: TPoint2DArray): Boolean; overload;

function IsIntersect(Poly1, Poly2: TPoint2DArray): Boolean; overload;


function IsIntersect(Ln: TLine2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Seg: TSegment2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Cir: TCircle2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Arc: TArc2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Rect: TRect2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Segarc1, Segarc2: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsIntersect(Ln: TLine2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Seg: TSegment2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Cir: TCircle2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Arc: TArc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Rect: TRect2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Poly: TPolygon2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsIntersect(Segarcs1, Segarcs2: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;



function IsSelfIntersect(Poly: TPolygon2D): Boolean; overload;
function IsSelfIntersect(Segarcs: TSegarc2DArray): Boolean; overload;



//function IsIntersect(Ray: TRay2D; Ln: TLine2D): Boolean; overload;
//function IsIntersect(Ray: TRay2D; Seg: TSegment2D): Boolean; overload;
//function IsIntersect(Ray: TRay2D; Arc: TArc2D): Boolean; overload;
//function IsIntersect(Ray: TRay2D; Cir: TCircle2D): Boolean; overload;
//function IsIntersect(Ray: TRay2D; Rect: TRect2D): Boolean; overload;
//function IsIntersect(Ray: TRay2D; Ell: TEllipse2D): Boolean; overload;
//function IsIntersect(Ray: TRay2D; Rect: TRect2D): Boolean; overload;
//function IsIntersect(Ray: TRay2D; Poly: TPoint2DArray): Boolean; overload;
//function IsIntersect(Ray: TRay2D; Segarc: TSegarc2D): Boolean; overload;
//function IsIntersect(Ray: TRay2D; Segarcs: TSegarc2DArray): Boolean; overload;


//---------------------------------------------------------------------

function IsParallel(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out E: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsParallel(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D; out E: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsParallel(Ln1, Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsParallel(Seg1, Seg2: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsParallel(Ln: TLine2D; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsParallel(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsParallel(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsParallel(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsParallel(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsParallel(Ln: TLine2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;


function IsPerpendicular(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPerpendicular(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPerpendicular(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPerpendicular(Ln: TLine2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;


function IsTangent(Seg: TSegment2D; Cir: TCircle2D): Boolean;




//---------------------------------------------------------------------

function IsPntInSegment(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInSegment(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntInRect(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInRect(Pnt: TPoint2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): Boolean; overload;


function IsPntInCircle(Px,Py, Cx,Cy, Radius: Float; const Epsilon: Float = _Epsilon): Boolean;  overload;
function IsPntInCircle(Px, Py: Float; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInCircle(Pnt: TPoint2D; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean; overload;


function FastIsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function FastIsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

//function IsPntInPolygon(Pnt: TPoint2D; Poly: TPointsF; const Epsilon: Float = _Epsilon): Boolean; overload;

function AbsIsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function AbsIsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

function FastIsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function FastIsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function FastIsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function FastIsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntInEllipse(Px, Py: Float; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInEllipse(Pnt: TPoint2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean; overload;


function IsCircleInCircle(Cir1, Cir2: TCircle2D): Boolean;

function IsPntInArc(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInArc(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;


function IsPntInSegarcs(Px, Py: Float; Segarcs: TSegarc2DArray; OnIsValid: Boolean = True; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntInSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray; OnIsValid: Boolean = True; const Epsilon: Float = _Epsilon): Boolean; overload;


function IsPntOnRay(Pnt: TPoint2D; Ray: TRay2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnRay(Px, Py: Float; Ray: TRay2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntOnLine(Pnt: TPoint2D; Ln: TLineK; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnLine(Pnt: TPoint2D; Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnLine(Px, Py: Float; Ln: TLineK; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnLine(Px, Py: Float; Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntOnSegment(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnSegment(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntOnRect(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnRect(Pnt: TPoint2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntOnCircle(Px, Py: Float; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnCircle(Px, Py: Float; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnCircle(Pnt: TPoint2D; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntOnArc(Px, Py: Float; Cx, Cy, Radius, Ang1, Ang2: Float; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnArc(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnArc(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntOnPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntOnPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntOnSegarc(Pnt: TPoint2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnSegarcs(Px, Py: Float; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean; overload;

function IsPntOnEllipse(Px, Py: Float; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean; overload;
function IsPntOnEllipse(Pnt: TPoint2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean; overload;





//---------------------------------------------------------------------

function Distance(X1, Y1, X2, Y2: Float): Float; overload;
function Distance(Pnt1, Pnt2: TPoint2D): Float; overload;
function Distance(Seg: TSegment2D): Float; overload;
function Distance(Arc: TArc2D): Float; overload;
function Distance(R, Ang1, Ang2: Float): Float; overload;
function Distance(Seg: TSegarc2D): Float; overload;

function LayDistance(X1, Y1, X2, Y2: Float): Float; overload;
function LayDistance(Pnt1, Pnt2: TPoint2D): Float; overload;
function ManDistance(X1, Y1, X2, Y2: Float): Float; overload;
function ManDistance(Pnt1, Pnt2: TPoint2D): Float; overload;

function LayDistanceSegments(x1,y1, x2,y2, x3,y3, x4,y4: Float): Float; overload;
function LayDistanceSegments(Seg1, Seg2: TSegment2D): Float; overload;
function DistanceSegments(Seg1, Seg2: TSegment2D): Float;

function LayDistanceLines(x1,y1, x2,y2, x3,y3, x4,y4: Float): Float; overload;
function LayDistanceLines(Line1, Line2: TLine2D): Float; overload;
function DistanceLines(Line1, Line2: TLine2D): Float;


function DistanceToRay(Px,Py: Float; Ray: TRay2D): Float; overload;
function DistanceToRay(Pnt: TPoint2D; Ray: TRay2D): Float; overload;

function DistanceToLine(Px,Py: Float; Ln: TLineK): Float; overload;
function DistanceToLine(Pnt: TPoint2D; Ln: TLineK): Float; overload;

function DistanceToLine(Px,Py, X1,Y1, X2,Y2: Float): Float; overload;
function DistanceToLine(Pnt: TPoint2D; Ln: TLine2D): Float; overload;

function DistanceToSegment(Px,Py, X1,Y1, X2,Y2:Float; out Idx: Integer): Float; overload;
function DistanceToSegment(Pnt: TPoint2D; Seg: TSegment2D; out Idx: Integer): Float; overload;

function DistanceToSegment(Px,Py, X1,Y1, X2,Y2:Float): Float; overload;
function DistanceToSegment(Pnt: TPoint2D; Seg: TSegment2D): Float; overload;

function DistanceToRect(Px,Py, X1,Y1, X2,Y2:Float): Float; overload;
function DistanceToRect(Pnt: TPoint2D; Rect: TRect2D): Float; overload;

function DistanceToPolygon(Pnt:TPoint2D; Poly: TPoint2DArray): Float;

function DistanceToArc(Pnt: TPoint2D; Arc: TArc2D): Float;
function DistanceToCircle(Pnt: TPoint2D; Cir: TCircle2D): Float;
function DistanceToEllipse(Pnt: TPoint2D; Ell: TEllipse2D): Float;
function DistanceToSegarc(Pnt: TPoint2D; Segarc: TSegarc2D): Float;
function DistanceToSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray): Float;




//---------------------------------------------------------------------

function Area(Rect: TRect2D): Float; overload;
function Area(Cir: TCircle2D): Float; overload;
function Area(Poly: TPoint2DArray): Float; overload;
function Area(Arc: TArc2D; Kind: TArcKind = akSector): Float; overload;
function Area(Segarcs: TSegarc2DArray): Float; overload;

function Perimeter(Rect: TRect2D): Float; overload;
function Perimeter(Cir: TCircle2D): Float; overload;
function Perimeter(Poly: TPoint2DArray; Closed: Boolean = False): Float; overload;
function Perimeter(Segarcs: TSegarc2DArray): Float; overload;

function Centroid(X1,Y1, X2,Y2, X3,Y3: Float): TPoint2D; overload;
function Centroid(Pnt1, Pnt2, Pnt3: TPoint2D): TPoint2D; overload;
function Centroid(Rect: TRect2D): TPoint2D; overload;
function Centroid(Poly: TPoint2DArray): TPoint2D; overload;

function Center(Rect: TRect2D): TPoint2D; overload;
function Center(Poly: TPoint2DArray): TPoint2D; overload;
function Center(Segarcs: TSegarc2DArray): TPoint2D; overload;


function MidPoint(X1,Y1, X2,Y2: Float): TPoint2D; overload;
function MidPoint(Pnt1, Pnt2: TPoint2D): TPoint2D; overload;
function MidPoint(Seg: TSegment2D): TPoint2D; overload;
function MidPoint(Arc: TArc2D): TPoint2D; overload;
function MidPoint(Segarc: TSegarc2D): TPoint2D; overload;

function Incenter(X1, Y1, X2, Y2, X3, Y3: Float): TPoint2D; overload;
function Incenter(Pnt1, Pnt2, Pnt3: TPoint2D): TPoint2D; overload;

function Circumcenter(X1, Y1, X2, Y2, X3, Y3: Float): TPoint2D; overload;
function Circumcenter(Pnt1, Pnt2, Pnt3: TPoint2D): TPoint2D; overload;




function Rotate(RotAng: Float; X, Y: Float): TPoint2D; overload;
function Rotate(RotAng: Float; Pnt: TPoint2D): TPoint2D; overload;
function Rotate(RotAng: Float; Ln: TLine2D): TLine2D; overload;
function Rotate(RotAng: Float; Seg: TSegment2D): TSegment2D; overload;
function Rotate(RotAng: Float; Poly: TPoint2DArray): TPoint2DArray; overload;
function Rotate(RotAng: Float; Cir: TCircle2D): TCircle2D; overload;
function Rotate(RotAng: Float; Arc: TArc2D): TArc2D; overload;
function Rotate(RotAng: Float; Ell: TEllipse2D): TEllipse2D; overload;
function Rotate(RotAng: Float; Segarc: TSegarc2D): TSegarc2D; overload;
function Rotate(RotAng: Float; Segarcs: TSegarc2DArray): TSegarc2DArray; overload;

function Rotate(Base: TPoint2D; RotAng: Float; X, Y: Float): TPoint2D; overload;
function Rotate(Base: TPoint2D; RotAng: Float; Pnt: TPoint2D): TPoint2D; overload;
function Rotate(Base: TPoint2D; RotAng: Float; Ln: TLine2D): TLine2D; overload;
function Rotate(Base: TPoint2D; RotAng: Float; Seg: TSegment2D): TSegment2D; overload;
function Rotate(Base: TPoint2D; RotAng: Float; Poly: TPoint2DArray): TPoint2DArray; overload;
function Rotate(Base: TPoint2D; RotAng: Float; Cir: TCircle2D): TCircle2D; overload;
function Rotate(Base: TPoint2D; RotAng: Float; Arc: TArc2D): TArc2D; overload;
function Rotate(Base: TPoint2D; RotAng: Float; Ell: TEllipse2D): TEllipse2D; overload;
function Rotate(Base: TPoint2D; RotAng: Float; Segarc: TSegarc2D): TSegarc2D; overload;
function Rotate(Base: TPoint2D; RotAng: Float; Segarcs: TSegarc2DArray): TSegarc2DArray; overload;


function Translate(Dx, Dy: Float; Pnt: TPoint2D): TPoint2D; overload;
function Translate(Dx, Dy: Float; Ln: TLine2D): TLine2D; overload;
function Translate(Dx, Dy: Float; Seg: TSegment2D): TSegment2D; overload;
function Translate(Dx, Dy: Float; Rect: TRect2D): TRect2D; overload;
function Translate(Dx, Dy: Float; Cir: TCircle2D): TCircle2D; overload;
function Translate(Dx, Dy: Float; Arc: TArc2D): TArc2D; overload;
function Translate(Dx, Dy: Float; Ell: TEllipse2D): TEllipse2D; overload;
function Translate(Dx, Dy: Float; Poly: TPoint2DArray): TPoint2DArray; overload;
function Translate(Dx, Dy: Float; Segarc: TSegarc2D): TSegarc2D; overload;
function Translate(Dx, Dy: Float; Segarcs: TSegarc2DArray): TSegarc2DArray; overload;
function Translate(Dx, Dy: Float; Vertexes: TVertexes2D): TVertexes2D; overload;

function Scale(Sx, Sy: Float; Pnt: TPoint2D): TPoint2D; overload;
function Scale(Sx, Sy: Float; Ln: TLine2D): TLine2D; overload;
function Scale(Sx, Sy: Float; Seg: TSegment2D): TSegment2D; overload;
function Scale(Sx, Sy: Float; Rect: TRect2D): TRect2D; overload;
function Scale(Sr: Float; Cir: TCircle2D): TCircle2D; overload;
function Scale(Sr: Float; Arc: TArc2D): TArc2D; overload;
function Scale(Sx, Sy: Float; Cir: TCircle2D): TEllipse2D; overload;
function Scale(Sx, Sy: Float; Arc: TArc2D): TEllipse2D; overload;
function Scale(Sx, Sy: Float; Ell: TEllipse2D): TEllipse2D; overload;
function Scale(Sx, Sy: Float; Poly: TPoint2DArray): TPoint2DArray; overload;

function Scale(Base: TPoint2D; Sx, Sy: Float; Pnt: TPoint2D): TPoint2D; overload;
function Scale(Base: TPoint2D; Sx, Sy: Float; Ln: TLine2D): TLine2D; overload;
function Scale(Base: TPoint2D; Sx, Sy: Float; Seg: TSegment2D): TSegment2D; overload;
function Scale(Base: TPoint2D; Sx, Sy: Float; Rect: TRect2D): TRect2D; overload;
function Scale(Base: TPoint2D; Sr: Float; Cir: TCircle2D): TCircle2D; overload;
function Scale(Base: TPoint2D; Sr: Float; Arc: TArc2D): TArc2D; overload;
function Scale(Base: TPoint2D; Sx, Sy: Float; Cir: TCircle2D): TEllipse2D; overload;
function Scale(Base: TPoint2D; Sx, Sy: Float; Arc: TArc2D): TEllipse2D; overload;
function Scale(Base: TPoint2D; Sx, Sy: Float; Ell: TEllipse2D): TEllipse2D; overload;
function Scale(Base: TPoint2D; Sx, Sy: Float; Poly: TPoint2DArray): TPoint2DArray; overload;

function Scale(S: Float; Segarc: TSegarc2D): TSegarc2D; overload;
function Scale(S: Float; Segarc: TSegarc2D; Base: TPoint2D): TSegarc2D; overload;
function Scale(S: Float; Segarcs: TSegarc2DArray): TSegarc2DArray; overload;
function Scale(Base: TPoint2D; S: Float; Segarcs: TSegarc2DArray): TSegarc2DArray; overload;


function Mirror(MrLn: TLineK; X, Y: Float): TPoint2D; overload;
function Mirror(MrLn: TLineK; Pnt: TPoint2D): TPoint2D; overload;

function Mirror(MrLn: TLine2D; X, Y: Float): TPoint2D; overload;
function Mirror(MrLn: TLine2D; Pnt: TPoint2D): TPoint2D; overload;
function Mirror(MrLn: TLine2D; Seg: TSegment2D): TSegment2D; overload;
function Mirror(MrLn: TLine2D; Rect: TRect2D): TRect2D; overload;
function Mirror(MrLn: TLine2D; Cir: TCircle2D): TCircle2D; overload;
function Mirror(MrLn: TLine2D; Arc: TArc2D): TArc2D; overload;
function Mirror(MrLn: TLine2D; Ell: TEllipse2D): TEllipse2D;  overload;
function Mirror(MrLn: TLine2D; Poly: TPoint2DArray): TPoint2DArray; overload;
function Mirror(MrLn: TLine2D; Segarc: TSegarc2D): TSegarc2D; overload;
function Mirror(MrLn: TLine2D; Segarcs: TSegarc2DArray): TSegarc2DArray; overload;



function ClosestLinePoint(Px, Py: Float; Ln: TLineK): TPoint2D; overload;
function ClosestLinePoint(Pnt: TPoint2D; Ln: TLineK): TPoint2D; overload;

function ClosestLinePoint(Px, Py: Float; X1, Y1, X2, Y2: Float): TPoint2D; overload;
function ClosestLinePoint(Pnt: TPoint2D; Ln: TLine2D): TPoint2D; overload;

function ClosestSegmentPoint(Px,Py, X1,Y1, X2,Y2:Float; out Idx: Integer): TPoint2D; overload;
function ClosestSegmentPoint(Pnt: TPoint2D; Seg: TSegment2D; out Idx: Integer): TPoint2D; overload;

function ClosestSegmentPoint(Px, Py: Float; X1, Y1, X2, Y2: Float): TPoint2D; overload;
function ClosestSegmentPoint(Pnt: TPoint2D; Seg: TSegment2D): TPoint2D; overload;

function ClosestRectPoint(Px,Py, X1,Y1, X2,Y2: Float): TPoint2D; overload;
function ClosestRectPoint(Pnt:TPoint2D; Rect: TRect2D): TPoint2D; overload;

function ClosestCirclePoint(Pnt:TPoint2D; Cir: TCircle2D):TPoint2D;
function ClosestArcPoint(Pnt:TPoint2D; Arc: TArc2D): TPoint2D;
function ClosestEllipsePoint(Pnt:TPoint2D; Ell: TEllipse2D): TPoint2D;
function ClosestPointsPoint(Pnt:TPoint2D; Poly: TPoint2DArray; out Idx: Integer): TPoint2D; overload;
function ClosestPointsPoint(Pnt:TPoint2D; Poly: TPoint2DArray): TPoint2D; overload;

function ClosestSegarcPoint(Pnt: TPoint2D; Segarc: TSegarc2D): TPoint2D;
function ClosestSegarcsPoint(Pnt: TPoint2D; Segarcs: TSegarc2DArray; out Idx: Integer): TPoint2D; overload;
function ClosestSegarcsPoint(Pnt: TPoint2D; Segarcs: TSegarc2DArray): TPoint2D; overload;

function PerpendBisector(X1, Y1, X2, Y2: Float): TLineK; overload;
function PerpendBisector(P1, P2: TPoint2D): TLineK; overload;




//---------------------------------------------------------------------

function Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(P1, P2, P3, P4: TPoint2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln1, Ln2: TLineK; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln1: TLineK; Ln2: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln: TLineK; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln: TLine2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(P1, P2, P3, P4: TPoint2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln1, Ln2: TLineK; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln1, Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln1: TLineK; Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln: TLineK; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln: TLine2D; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg1, Seg2: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;


function Intersection(Ln: TLineK; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln: TLine2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg: TSegment2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function Intersection(Ln: TLineK; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln: TLineK; Cir: TCircle2D; const Epsilon: Float = _Epsilon) : TPoint2DArray; overload;
function Intersection(Ln: TLine2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg: TSegment2D; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg: TSegment2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function Intersection(Ln: TLineK; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln: TLine2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg: TSegment2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function Intersection(Ln: TLineK; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln: TLine2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg: TSegment2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function Intersection(Ray1, Ray2: TRay2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ray: TRay2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ray: TRay2D; Ln: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ray: TRay2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ray: TRay2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ray: TRay2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ray: TRay2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ray: TRay2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ray: TRay2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ray: TRay2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;


function Intersection(Rect1, Rect2: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Rect: TRect2D; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Rect: TRect2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Rect: TRect2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Rect: TRect2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function Intersection(Cir1, Cir2: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Cir: TCircle2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Cir: TCircle2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function Intersection(Arc1, Arc2: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Arc: TArc2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function Intersection(Poly1, Poly2: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;


function Intersection(Ln: TLineK; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ln: TLine2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg: TSegment2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Cir: TCircle2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Arc: TArc2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Rect: TRect2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ell1, Ell2: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ell: TEllipse2D; Poly: TPoint2DArray;  const Epsilon: Float = _Epsilon): TPoint2DArray; overload;


function Intersection(Ln: TLine2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg: TSegment2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Cir: TCircle2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Arc: TArc2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Rect: TRect2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ell: TEllipse2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Poly: TPoint2DArray; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Segarc1, Segarc2: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Segarc: TSegarc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;

function Intersection(Ln: TLine2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Seg: TSegment2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Cir: TCircle2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Arc: TArc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Rect: TRect2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Ell: TEllipse2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Poly: TPoint2DArray; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
function Intersection(Segarcs1, Segarcs2: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;



//---------------------------------------------------------------------

function LowerPoint(P1, P2: TPoint2D): TPoint2D; overload;
function LowerPoint(Poly: TPoint2DArray): TPoint2D; overload;
function HigherPoint(P1, P2: TPoint2D): TPoint2D; overload;
function HigherPoint(Poly: TPoint2DArray): TPoint2D; overload;
function LefterPoint(P1, P2: TPoint2D): TPoint2D; overload;
function LefterPoint(Poly: TPoint2DArray): TPoint2D; overload;
function RighterPoint(P1, P2: TPoint2D): TPoint2D; overload;
function RighterPoint(Poly: TPoint2DArray): TPoint2D; overload;
function NearestPoint(Poly: TPoint2DArray; Pnt: TPoint2D): TPoint2D; overload;
function NearestPoint(Poly: TPoint2DArray; Pnt: TPoint2D; out Index: Integer): TPoint2D; overload;


function RectHull(X1, Y1, X2, Y2: Float): TRect2D; overload;
function RectHull(P1, P2: TPoint2D): TRect2D; overload;
function RectHull(X1, Y1, X2, Y2, X3, Y3: Float): TRect2D; overload;
function RectHull(P1, P2, P3: TPoint2D): TRect2D; overload;

function RectHull(Seg: TSegment2D): TRect2D; overload;
function RectHull(Rect: TRect2D): TRect2D;  overload;
function RectHull(Cir : TCircle2D): TRect2D; overload;
function RectHull(Arc : TArc2D): TRect2D; overload;
function RectHull(Ell : TEllipse2D): TRect2D; overload;

function RectHull(Poly: TPoint2DArray): TRect2D; overload;
function RectHull(Segarcs: TSegarc2DArray): TRect2D; overload;

function CircleHull(Poly: TPoint2DArray): TCircle2D;
function WidthHull(Poly: TPoint2DArray): TPoint2D;
function HeightHull(Poly: TPoint2DArray): TPoint2D;


function CircumCircle(Pnt1, Pnt2, Pnt3: TPoint2D): TCircle2D;
function InscribedCircle(Pnt1, Pnt2, Pnt3: TPoint2D): TCircle2D;



//---------------------------------------------------------------------

function ArcEndPnts(Arc: TArc2D): TPoint2DArray;
function ArcQuadPnts(Arc: TArc2D): TPoint2DArray;
function ArcHullPnts(Arc: TArc2D): TPoint2DArray;

function EllipseQuadPnts(Ell: TEllipse2D): TPoint2DArray;
function SegarcEndPnts(Segarc: TSegarc2D): TPoint2DArray;

function EllAngToCenAng(Rx, Ry: Float; Ang: Float): Float;
function CenAngToEllAng(Rx, Ry: Float; Ang: Float): Float;

function GetArcPoint(Cen: TPoint2D; R: Float; Ang: Float): TPoint2D;
function GetEllPoint(Cen: TPoint2D; Rx, Ry: Float; Rot: Float; Ang: Float; EAng: Boolean): TPoint2D;
function GetEllipsePoint(Cen: TPoint2D; Rx, Ry: Float; Rot: Float; Ang: Float; EAng: Boolean = True): TPoint2D; overload;
function GetEllipsePoint(Ell: TEllipse2D; Ang: Float; EAng: Boolean = True): TPoint2D; overload;

function SamplePoints(Seg: TSegment2D; Wid: Float = 0.0): TPoint2DArray; overload;
function SamplePoints(Arc: TArc2D; Segments: Integer; Wid: Float = 0.0): TPoint2DArray; overload;
function SamplePoints(Cir: TCircle2D; Segments: Integer; Wid: Float = 0.0): TPoint2DArray; overload;
function SamplePoints(Ell: TEllipse2D; Segments: Integer; Wid: Float = 0.0): TPoint2DArray; overload;
function SamplePoints(Segarc: TSegarc2D; Wid: Float = 0.0): TPoint2DArray; overload;
function SamplePoints(Segarcs: TSegarc2DArray; IsSimple: Boolean = False): TPoint2DArray; overload;

function SampleSegmentNum(PixelSize: Float; Radius, IncdeAng: Float; Resolution: Integer = 800): Integer; //PixelSize = Value/Pixel
function PointsToSegments(Pnts: TPoint2DArray): TSegment2DArray;



//---------------------------------------------------------------------

function BreakAt(ASeg: TSegment2D; APnt1, APnt2: TPoint2D; var AFlag: Cardinal): TSegment2DArray;  overload;
function BreakAt(ASeg: TSegment2D; APnt1, APnt2: TPoint2D): TSegment2DArray; overload;
function BreakAt(AArc: TArc2D; APnt1, APnt2: TPoint2D): TArc2DArray; overload;
function BreakAt(AArc: TArc2D; APnt1, APnt2: TPoint2D; var AFlag: Cardinal): TArc2DArray; overload;
function BreakAt(ACir: TCircle2D; APnt1, APnt2: TPoint2D): TArc2D; overload;
function BreakAt(AEll: TEllipse2D; APnt1, APnt2: TPoint2D; var AFlag: Cardinal): TEllipse2DArray; overload;
function BreakAt(AEll: TEllipse2D; APnt1, APnt2: TPoint2D): TEllipse2DArray; overload;
function BreakAt(APoints: TPoint2DArray; APnt1, APnt2: TPoint2D; AClosed: Boolean = False): TPoint2DArrays; overload;
function BreakAt(ASegarcs: TSegarc2DArray; APnt1, APnt2: TPoint2D; AClosed: Boolean = False): TSegarc2DArrays; overload;

function Stretch(ASeg: TSegment2D; AValue: Float): TSegment2D; overload;
function Stretch(ASeg: TSegment2D; AValue1, AValue2: Float): TSegment2D;  overload;

function Stretch(AArc: TArc2D; AValue: Float; AByAng: Boolean = True): TArc2D; overload;
function Stretch(AArc: TArc2D; AValue1, AValue2: Float; AByAng: Boolean = True): TArc2D; overload;

function DivisionPnt(Pnt1, Pnt2: TPoint2D; Num: Integer): TPoint2DArray; overload;
function DivisionPnt(Arc: TArc2D; Num: Integer): TPoint2DArray; overload;

function InterInclusion(FromPoly, ToPoly: TPoint2DArray; const Epsilon: Float = _Epsilon): TInclusion; overload;
function InterInclusion(FromSegarcs, ToSegarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TInclusion; overload;

function Inclusion(FromRect, ToRect: TRect2D): TInclusion;  overload;
function Inclusion(FromPoly, ToPoly: TPoint2DArray; const Robust: Boolean = True; const Epsilon: Float = _Epsilon): TInclusion; overload;
function Inclusion(FromSegarcs, ToSegarcs: TSegarc2DArray; const Robust: Boolean = True; const Epsilon: Float = _Epsilon): TInclusion; overload;

//---------------------------------------------------------------------

function OffsetSegment(Seg: TSegment2D; Dis: Float; ALeftSide: Boolean): TSegment2D; overload;
function OffsetSegment(Seg: TSegment2D; Wid: Float; out Seg1, Seg2: TSegment2D): Boolean; overload;

function OffsetArc(Arc: TArc2D; Dis: Float; ALeftSide: Boolean): TArc2D; overload;
function OffsetArc(Arc: TArc2D; Wid: Float; out Arc1, Arc2: TArc2D): Boolean; overload;

function OffsetEllipse(Ell: TEllipse2D; Dis: Float; ALeftSide: Boolean): TEllipse2D; overload;
function OffsetEllipse(Ell: TEllipse2D; Wid: Float; out Ell1, Ell2: TEllipse2D): Boolean; overload;

function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float; ALeftSide: Boolean): TSegarc2DArray;  overload;
function OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray; ALeftSide: Boolean): TSegarc2DArray; overload;

function OffsetPoints(Poly: TPoint2DArray; Dis: Float; ALeftSide: Boolean): TPoint2DArray;  overload;
function OffsetPoints(Poly: TPoint2DArray; Dises: TFloatArray; ALeftSide: Boolean): TPoint2DArray;  overload;

function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float): TSegarc2DArray;  overload;
function OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray): TSegarc2DArray; overload;

function OffsetPolygon(Poly: TPoint2DArray; Dis: Float): TPoint2DArray;  overload;
function OffsetPolygon(Poly: TPoint2DArray; Dises: TFloatArray): TPoint2DArray;  overload;


function OffsetSegment(Seg: TSegment2D; Dis: Float; ASidePnt: TPoint2D): TSegment2D; overload;
function OffsetArc(Arc: TArc2D; Dis: Float; ASidePnt: TPoint2D): TArc2D; overload;
function OffsetEllipse(Ell: TEllipse2D; Dis: Float; ASidePnt: TPoint2D): TEllipse2D; overload;
function OffsetPoints(Poly: TPoint2DArray; Dis: Float; ASidePnt: TPoint2D): TPoint2DArray;  overload;
function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float; ASidePnt: TPoint2D): TSegarc2DArray;  overload;




function ClosePolygon(var APolygon: TPoint2DArray): Boolean;
function ConvexPolygon(Poly: TPoint2DArray; CW: Boolean = False): TPoint2DArray;
function NormalizePolygon(Poly: TPoint2DArray; TrimPnts: Boolean = False): TPoint2DArray;



//---------------------------------------------------------------------

function MakeArc(P1, P2, P3: TPoint2D): TArc2D; overload;
function MakeArc(P1, P2: TPoint2D; R: Float; Clock, Big: Boolean): TArc2D; overload;
function MakeArc(P1, P2: TPoint2D; TanAng: Float): TArc2D; overload;
function MakeArc(P1, P2, P3: TPoint2D; BowHeight: Double): TArc2D; overload;
function MakeArc(P1, P2: TPoint2D; IsLeft: Boolean; BowHeight: Double): TArc2D; overload;

function ClipArc(Arc: TArc2D; A1, A2: Float): TArc2D; overload;    //ClipArc
function ClipArc(Arc: TArc2D; P1, P2: TPoint2D): TArc2D; overload; //ClipArc
function MergeArc(Arc1, Arc2: TArc2D; const Epsilon: Float = _Epsilon): TArc2D;
function ModifyArc(Arc: TArc2D; A1, A2: Float): TArc2D; overload;
function ModifyArc(Arc: TArc2D; P1, P2: TPoint2D): TArc2D; overload;


function ClipSegment(Seg: TSegment2D; P1, P2: TPoint2D): TSegment2D;
function MergeSegment(Seg1, Seg2: TSegment2D; const AngEpsilon: Float = 0.1; const DEpsilon: Float = 0.1): TSegment2D;
function ModifySegment(Seg: TSegment2D; P1, P2: TPoint2D): TSegment2D;

function MergeRect(Rect1, Rect2: TRect2D): TRect2D;

procedure GetSegmentBD(Seg: TSegment2D; out B, D: Float; const AEpsion: Float = 0.01);
function GetSegmentD(Seg: TSegment2D; const AEpsion: Float = 0.01): Float;



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//function BoundHull(Seg: TSegment2D; Ang: Float): TBound2D; overload;
//function BoundHull(Cir : TCircle2D; Ang: Float): TBound2D; overload;
//function BoundHull(Arc : TArc2D; Ang: Float): TBound2D; overload;
//function BoundHull(Poly: TPoint2DArray; Ang: Float): TBound2D; overload;
//function BoundHull(Segarcs: TSegarc2DArray; Ang: Float): TBound2D; overload;


function SortPoints(var A: TPoint2DArray; B: TPoint2D): Boolean; overload;
function SortPoints(var A: TPoint2DArray; B: TPoint2D; Ang: Float): Boolean; overload;
function SortPoints(var A: TPoint2DArray; Arc: TArc2D): Boolean; overload;
function SortPoints(var A: TPoint2DArray; Ell: TEllipse2D): Boolean; overload;

//------------------------------------------------------------------------------------------


implementation

uses
  UdMath, UdInct2D, UdRela2D, UdDist2D, UdOffset2D;



//=================================================================================================

//procedure Swap(var X, Y: Float); overload;
//var
//  F: Float;
//begin
//  F := X;
//  X := Y;
//  Y := F;
//end;
//


//-----------------------------------------------------------------------------------------

function Point2D(X, Y: Float): TPoint2D;
begin
  Result.X := X;
  Result.Y := Y;
end;

function Line2D(X1, Y1, X2, Y2: Float): TLine2D;
begin
  Result.P1.X := X1;
  Result.P2.X := X2;
  Result.P1.Y := Y1;
  Result.P2.Y := Y2;
end;

function Line2D(Pnt1, Pnt2: TPoint2D): TLine2D;
begin
  Result.P1 := Pnt1;
  Result.P2 := Pnt2;
end;

function Segment2D(X1, Y1, X2, Y2: Float): TSegment2D;
begin
  Result.P1.X := X1;
  Result.P2.X := X2;
  Result.P1.Y := Y1;
  Result.P2.Y := Y2;
end;

function Segment2D(Pnt1, Pnt2: TPoint2D): TSegment2D;
begin
  Result.P1 := Pnt1;
  Result.P2 := Pnt2;
end;

function Rect2D(X1, Y1, X2, Y2: Float): TRect2D;
begin
  Result.P1.X := Min(X1, X2);
  Result.P2.X := Max(X1, X2);
  Result.P1.Y := Min(Y1, Y2);
  Result.P2.Y := Max(Y1, Y2);
end;

function Rect2D(Pnt1, Pnt2: TPoint2D): TRect2D;
begin
  Result := Rect2D(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y);
end;

function Circle2D(X, Y: Float; R: Float): TCircle2D;
begin
  Result.Cen.X := X;
  Result.Cen.Y := Y;
  Result.R := R;
end;

function Circle2D(Cen: TPoint2D; R: Float): TCircle2D;
begin
  Result.Cen := Cen;
  Result.R := R;
end;


function Arc2D(Cen: TPoint2D; R: Float; Ang1, Ang2: Float; IsCW: Boolean = False; Kind: TArcKind = akCurve): TArc2D;
begin
  Result.R := R;
  Result.Cen := Cen;
  Result.Ang1 := Ang1;
  Result.Ang2 := Ang2;
  Result.IsCW := IsCW;
  Result.Kind := Kind;
end;

function Arc2D(X, Y: Float; R: Float; Ang1, Ang2: Float; IsCW: Boolean = False; Kind: TArcKind = akCurve): TArc2D;
begin
  Result.R := R;
  Result.Cen.X := X;
  Result.Cen.Y := Y;
  Result.Ang1 := Ang1;
  Result.Ang2 := Ang2;
  Result.IsCW := IsCW;
  Result.Kind := Kind;
end;





function LineK(K, B: Float; HasK: Boolean): TLineK;
begin
  Result.K := K;
  Result.B := B;
  Result.HasK := HasK;
end;


function LineK(X, Y, Ang: Float): TLineK;
begin
  Ang := UdMath.FixAngle(Ang);

  with Result do
  begin
    if IsEqual(Ang, 90.0) or IsEqual(Ang, 270.0) then
    begin
      K := _ErrValue;
      B := X;
      HasK := False;
    end
    else begin
      K := UdMath.TanD(Ang);
      B := Y - K * X;
      HasK := True;
    end;
  end; {end with}
end;

function LineK(B, Ang: Float): TLineK;
begin
  Ang := UdMath.FixAngle(Ang);

  Result.B := B;

  with Result do
  begin
    if IsEqual(Ang, 90.0) or IsEqual(Ang, 270.0) then
    begin
      K := _ErrValue;
      HasK := False;
    end
    else begin
      K := UdMath.TanD(Ang);
      HasK := True;
    end;
  end; {end with}
end;

function LineK(Pnt: TPoint2D; Ang: Float): TLineK;
begin
  Result := LineK(Pnt.X, Pnt.Y, Ang);
end;

function LineK(X1, Y1, X2, Y2: Float): TLineK;
begin
  with Result do
  begin
    if not IsEqual(X1, X2) then
    begin
      K := (Y2 - Y1) / (X2 - X1);
      B := Y2 - K * X2;
      HasK := True;
    end
    else
    begin
      B := (X1 + X2) / 2;
      K := _ErrValue;
      HasK := False;
    end;
  end; {end with}
end;

function LineK(Pnt1, Pnt2: TPoint2D): TLineK;
begin
  Result := LineK(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y);
end;

function Ray2D(Pnt1, Pnt2: TPoint2D): TRay2D;
begin
  Result.Base := Pnt1;
  Result.Ang  := GetAngle(Pnt1, Pnt2);
end;

function Ray2D(Pnt: TPoint2D; Ang: Float): TRay2D;
begin
  Result.Base := Pnt;
  Result.Ang  := Ang;
end;


function Polygon2D(Rect: TRect2D): TPoint2DArray;
var
  Rct: TRect2D;
begin
  Rct := Rect2D(Rect.P1, Rect.P2);

  System.SetLength(Result, 5);
  Result[0].X := Rct.P1.X;
  Result[0].Y := Rct.P1.Y;
  Result[1].X := Rct.P2.X;
  Result[1].Y := Rct.P1.Y;
  Result[2].X := Rct.P2.X;
  Result[2].Y := Rct.P2.Y;
  Result[3].X := Rct.P1.X;
  Result[3].Y := Rct.P2.Y;
  Result[4].X := Rct.P1.X;
  Result[4].Y := Rct.P1.Y;
end;



function Vertex2D(X, Y, Bulge: Float): TVertex2D;
begin
  Result.Point := Point2D(X, Y);
  Result.Bulge := Bulge;
end;

function Vertex2D(Pnt: TPoint2D; Bulge: Float): TVertex2D; overload;
begin
  Result.Point := Pnt;
  Result.Bulge := Bulge;
end;



function Ellipse2D(Cen: TPoint2D; Rx, Ry: Float; Rot: Float = 0): TEllipse2D;
begin
  Result.Rx := Rx;
  Result.Ry := Ry;
  Result.Cen := Cen;
  Result.Rot := Rot;
  Result.Ang1 := 0.0;
  Result.Ang2 := 360.0;
  Result.IsCW := False;
  Result.Kind := akCurve;
end;

function Ellipse2D(Cen: TPoint2D; Rx, Ry: Float; Ang1, Ang2: Float; Rot: Float = 0; IsCW: Boolean = False; Kind: TArcKind = akCurve): TEllipse2D;
begin
  Result.Rx := Rx;
  Result.Ry := Ry;
  Result.Cen := Cen;
  Result.Rot := Rot;
  Result.Ang1 := Ang1;
  Result.Ang2 := Ang2;
  Result.IsCW := IsCW;
  Result.Kind := Kind;
end;



function Segarc2D(P1, P2: TPoint2D): TSegarc2D;
begin
  Result.Arc := Arc2D(0,0, -1, 0,0);
  Result.Seg := Segment2D(P1, P2);
  Result.IsArc := False;
end;

function Segarc2D(Seg: TSegment2D): TSegarc2D;
begin
  Result.Arc := Arc2D(0,0, -1, 0,0);
  Result.Seg := Seg;
  Result.IsArc := False;
end;

function Segarc2D(Arc: TArc2D): TSegarc2D;
begin
  Result.Arc := Arc;
  Result.Seg := Segment2D(
    ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R),
    ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R)
  );
  if Result.Arc.IsCW then
    Swap(Result.Seg.P1, Result.Seg.P2);

  Result.IsArc := True;
end;

function Segarc2D(P1, P2: TPoint2D; Bulge: Float): TSegarc2D;
var
  A1, A2: Float;
  LCen: TPoint2D;
  B, D, R: Float;
begin
  Result.Arc := Arc2D( 0,0,-1, 0,0);
  Result.Seg := Segment2D(P1, P2);
  Result.IsArc := False;

  if IsEqual(Bulge, 0.0) then Exit; //=====>>>

  D := Distance(P1, P2);
  if IsEqual(D, 0.0) then Exit; //=====>>>


  B := (Bulge * D) / 2.0;
  R := (((D / 2.0) * (D / 2.0)) + (B * B) ) / (B * 2.0);

  LCen := MidPoint(P1, P2);
  LCen := ShiftPoint(LCen, GetAngle(P1, P2) + 90, R - B);

  A1 := GetAngle(LCen, P1);
  A2 := GetAngle(LCen, P2);
  if (Bulge < 0.0) then UdMath.Swap(A1, A2);

  Result.IsArc    := True;

  Result.Arc.R    := Abs(R);
  Result.Arc.Cen  := LCen;
  Result.Arc.Ang1 := A1;
  Result.Arc.Ang2 := A2;
  Result.Arc.IsCW := IsClockWise(Result.Arc, P1, P2);
  Result.Arc.Kind := akCurve;
end;

function Segarc2D(V1, V2: TVertex2D): TSegarc2D;
begin
  Result := Segarc2D(V1.Point, V2.Point, V1.Bulge);
end;



function Segarc2DArray(Vexs: TVertexes2D): TSegarc2DArray;
var
  I: Integer;
begin
  Result := nil;
  if System.Length(Vexs) < 2 then Exit;

  System.SetLength(Result, System.Length(Vexs) - 1);

  for I := 0 to System.Length(Vexs) - 2 do
    Result[I] := Segarc2D(Vexs[I], Vexs[I+1]);
end;

function Segarc2DArray(Pnts: TPoint2DArray): TSegarc2DArray;
var
  I: Integer;
begin
  Result := nil;
  if System.Length(Pnts) < 2 then Exit;

  System.SetLength(Result, System.Length(Pnts) - 1);

  for I := 0 to System.Length(Pnts) - 2 do
    Result[I] := Segarc2D(Pnts[I], Pnts[I+1]);
end;


function GetVertexBulge(P1, P2: TPoint2D; Arc: TArc2D): Float;
var
  A, D: Float;
  Pc: TPoint2D;
begin
  Result := 0.0;
  if IsEqual(Arc.R, 0.0) or (Arc.R < 0) then Exit;

  D := Distance(P1, P2);
  if IsEqual(D, 0.0) then Exit;

  Pc := ShiftPoint(Arc.Cen,  MidAngle(Arc.Ang1, Arc.Ang2), Arc.R);
  A := Distance(Pc, MidPoint(P1, P2));
  Result := A / D * 2;
  if IsPntOnLeftSide(Pc, P1, P2) then Result := -Result;
end;


function Vertexes2D(Segarcs: TSegarc2DArray; CheckPnts: Boolean = True): TVertexes2D;
var
  I: Integer;
  L, N: Integer;
  LSegarc: TSegarc2D;
  LSegarcs: TSegarc2DArray;
begin
  Result := nil;
  L := System.Length(Segarcs);
  if L <= 0 then Exit; //=======>>>>>

  N := 0;

  if CheckPnts then
  begin
    SetLength(LSegarcs, L);
    for I := 0 to L - 1 do
    begin
      if IsEqual(Segarcs[I].Seg.P1, Segarcs[I].Seg.P2) then
      begin
        if (I < (L-1)) and NotEqual(Segarcs[I].Seg.P2, Segarcs[I+1].Seg.P1) then
        begin
          LSegarcs[I] := Segarc2D(Segarcs[I].Seg.P2, Segarcs[I+1].Seg.P1)
        end
        else begin
          LSegarcs[I].Arc := Arc2D(0, 0, -1, 0, 0);
          LSegarcs[I].Seg := Segment2D(0, 0, 0, 0);
          LSegarcs[I].IsArc := True;

          Inc(N);
        end;
      end
      else
        LSegarcs[I] := Segarcs[I]
    end;
  end
  else
    LSegarcs := Segarcs;

  if N >= L  then Exit;  //=======>>>>>


  System.SetLength(Result, L + 1);

  N := 0;
  for I := 0 to L - 1 do
  begin
    LSegarc := LSegarcs[I];
    if LSegarc.IsArc and (LSegarc.Arc.R < 0) then Continue;

    Result[N].Point := LSegarc.Seg.P1;
    Result[N].Bulge := 0.0;

    Result[N+1].Point := LSegarc.Seg.P2;
    Result[N+1].Bulge := 0.0;

    if LSegarc.IsArc then
      Result[N].Bulge := GetVertexBulge(Result[N].Point, Result[N+1].Point, LSegarc.Arc);    

    Inc(N);
  end;

  if Length(Result) > (N+1) then
    System.SetLength(Result, (N+1));
end;




//==================================================================================================

function Quadrant(Angle: Float): Integer;
var
  A: Float;
begin
  Result := 0;
  A := FixAngle(Angle);

       if (A >=   0) and (A <  90) then Result := 1
  else if (A >=  90) and (A < 180) then Result := 2
  else if (A >= 180) and (A < 270) then Result := 3
  else if (A >= 270) and (A < 360) then Result := 4
  else if A = 360                  then Result := 1;
end;

function Quadrant(X, Y: Float):Integer;
begin
  if      (x >  0.0) and (y >= 0.0) then Result := 1
  else if (x <= 0.0) and (y >  0.0) then Result := 2
  else if (x <  0.0) and (y <= 0.0) then Result := 3
  else if (x >= 0.0) and (y <  0.0) then Result := 4
  else Result := 0;
end;

function Quadrant(Pnt: TPoint2D): Integer;
begin
  Result := Quadrant(Pnt.X, Pnt.Y);
end;



function ShiftPoint(Px,Py, Dx,Dy, Dis: Float): TPoint2D;
var
  Ratio: Float;
begin
  if IsEqual(Dis, 0.0) then
  begin
    Result.X := Px;
    Result.Y := Py;
  end
  else begin
    Ratio := Dis / Distance(Px,Py, Dx,Dy);
    Result.X := Px + Ratio * (Dx - Px);
    Result.Y := Py + Ratio * (Dy - Py);
  end;
end;

function ShiftPoint(SP, DP: TPoint2D; Dis: Float): TPoint2D;
begin
  Result := ShiftPoint(SP.X, SP.Y, DP.X, DP.Y, Dis);
end;


function ShiftPoint(Px,Py, Angle, Dis: Float): TPoint2D;
var
  Dx: Float;
  Dy: Float;
begin
  if IsEqual(Dis, 0.0) then
  begin
    Result.X := Px;
    Result.Y := Py;
    Exit; //=======>>>>>
  end;

  Dx := 0.0;
  Dy := 0.0;
  case Quadrant(Angle) of
    1 : begin
          Dx := CosD(Angle) * Dis;
          Dy := SinD(Angle) * Dis;
        end;
    2 : begin
          Dx := SinD((Angle - 90.0)) * Dis * -1.0;
          Dy := CosD((Angle - 90.0)) * Dis;
        end;
    3 : begin
          Dx := CosD((Angle - 180.0)) * Dis * -1.0;
          Dy := SinD((Angle - 180.0)) * Dis * -1.0;
        end;
    4 : begin
          Dx := SinD((Angle - 270.0)) * Dis;
          Dy := CosD((Angle - 270.0)) * Dis * -1.0;
        end;
   end;
   Result.X := Px + Dx;
   Result.Y := Py + Dy;
end;

function ShiftPoint(SP: TPoint2D; Angle, Dis: Float):TPoint2D;
begin
  Result := ShiftPoint(SP.X, SP.Y, Angle, Dis);
end;


function ShiftArcPoint(Arc: TArc2D; Ang1Side: Boolean; Dis: Float): TPoint2D;
begin
  Result := ShiftArcPoint(Arc.Cen, Arc.R, Arc.Ang1, Arc.Ang2, Ang1Side, Dis);
end;

function ShiftArcPoint(Cen: TPoint2D; R, Ang1, Ang2: Float; Ang1Side: Boolean; Dis: Float): TPoint2D;
var
  LAng, LAngDelta: Float;
begin
  LAngDelta := LenToAng(Abs(Dis), R); // (Abs(Dis) / (2 * Pi * R)) * 360.0;

  if Ang1Side then
  begin
    if Dis > 0 then
      LAng := Ang1 - LAngDelta
    else
      LAng := Ang1 + LAngDelta;
  end
  else begin
    if Dis > 0 then
      LAng := Ang2 + LAngDelta
    else
      LAng := Ang2 - LAngDelta;
  end;

  LAng := FixAngle(LAng);
  Result := ShiftPoint(Cen, LAng, R);
end;


//-------------------------------------------------------------------------------------------------

function GetAngle(Cx, Cy, Px, Py: Float; const Epsilon: Float = _Epsilon): Float;
begin
 Result := -1;
 if not IsEqual(Distance(Cx, Cy, Px, Py), 0.0, Epsilon) then
   Result := FixAngle(ArcTan2D(Py - Cy, Px - Cx));
end;

function GetAngle(Cen, Pnt: TPoint2D; const Epsilon: Float = _Epsilon): Float;
begin
  Result := GetAngle(Cen.X, Cen.Y, Pnt.X, Pnt.Y, Epsilon);
end;


function VertexAngle(X1, Y1, X2, Y2, X3, Y3: Float; const Epsilon: Float = _Epsilon): Float;
var
  Dis: Float;
  Term : Float;
  Dx1, Dx2, Dy1, Dy2: Float;
begin
  // Quantify coordinates
  Dx1 := X1 - X2;
  Dx2 := X3 - X2;
  Dy1 := Y1 - Y2;
  Dy2 := Y3 - Y2;

  // Calculate Lay Distance
  Dis := (Dx1 * Dx1 + Dy1 * Dy1) * (Dx2 * Dx2 + Dy2 * Dy2);

  if IsEqual(Dis, 0.0, Epsilon) then
    Result := 0.0
  else begin
    Term := (Dx1 * Dx2 + Dy1 * Dy2) / Sqrt(Dis);
    if IsEqual(Term, 1.0, Epsilon) then
      Result := 0.0
    else if IsEqual(Term, -1.0, Epsilon) then
      Result := 180.0
    else
      Result := ArcCos(Term) * _180DivPI;
  end;
end;

function VertexAngle(Pnt1, Pnt2, Pnt3: TPoint2D; const Epsilon: Float = _Epsilon): Float;
begin
  Result := VertexAngle(Pnt1.X, Pnt1.Y,  Pnt2.X, Pnt2.Y,  Pnt3.X, Pnt3.Y, Epsilon);
end;

function IncludedAngle(P1: TPoint2D; P2: TPoint2D; P3: TPoint2D): Float;
var
  LAng: Double;
begin
  LAng := GetAngle(P2, P3) - GetAngle(P2, P1);
  if ((LAng > 0) and not IsEqual(LAng, 0, 1E-06)) then
    Result := LAng
  else
    Result := (LAng + 360.0);
end;




function CartesianAngle(X, Y: Float; const Epsilon: Float = _Epsilon): Float;
begin
  Result := -1;
  if IsEqual(X, 0.0, Epsilon) and IsEqual(Y, 0.0, Epsilon) then Exit;

  if      IsEqual(Y, 0.0, Epsilon) and (X >  0.0) then Result :=  0.0
  else if IsEqual(X, 0.0, Epsilon) and (Y >  0.0) then Result :=  90.0
  else if IsEqual(Y, 0.0, Epsilon) and (X <  0.0) then Result := 180.0
  else if IsEqual(X, 0.0, Epsilon) and (Y <  0.0) then Result := 270.0

  else if (X >  0.0) and (Y >  0.0) then Result := (ArcTan( Y / X) * _180DivPI)
  else if (X <  0.0) and (Y >  0.0) then Result := (ArcTan(-X / Y) * _180DivPI) +  90.0
  else if (X <  0.0) and (Y <  0.0) then Result := (ArcTan( Y / X) * _180DivPI) + 180.0
  else if (X >  0.0) and (Y <  0.0) then Result := (ArcTan(-X / Y) * _180DivPI) + 270.0;
end;

function CartesianAngle(Point: TPoint2D; const Epsilon: Float = _Epsilon): Float;
begin
  Result := CartesianAngle(Point.X, Point.Y, Epsilon);
end;


//-------------------------------------------------------------------------------------------------

function Signed(Px, Py: Float; X1, Y1, X2, Y2: Float): Float;
begin
  Result := (X2 - X1) * (Py - Y1) - (Px - X1) * (Y2 - Y1);
end;

function Signed(PntP, Pnt1, Pnt2: TPoint2D): Float;
begin
  Result := Signed(PntP.X, PntP.Y, Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y);
end;

function Signed(Pnt: TPoint2D; Ln: TLine2D): Float;
begin
  Result := Signed(Pnt.X, Pnt.Y, Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y);
end;

function Signed(Pnt: TPoint2D; Seg: TSegment2D): Float;
begin
  Result := Signed(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y)
end;



function Orientation(Px, Py: Float; X1, Y1, X2, Y2: Float; Epsilon: Float = _HighiEpsilon): Longint;
var
  Orin: Float;
begin
  Orin := Signed(Px, Py, X1, Y1, X2, Y2);

  if IsEqual(Orin, 0.0, Epsilon) then
    Result := _NeutralOfSide
  else if Orin > 0.0 then
    Result := _LeftHandSide   // left-hand side
  else //if Orin < 0.0 then
    Result := _RightHandSide  // right-hand side
end;


function Orientation(PntP, Pnt1, Pnt2: TPoint2D; Epsilon: Float = _HighiEpsilon): Longint;
begin
  Result := Orientation(PntP.X, PntP.Y, Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Epsilon);
end;

function Orientation(Pnt: TPoint2D; Ln: TLine2D; Epsilon: Float = _HighiEpsilon): Longint;
begin
  Result := Orientation(Pnt.X, Pnt.Y, Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y, Epsilon);
end;


function Orientation(Pnt: TPoint2D; Seg: TSegment2D; Epsilon: Float = _HighiEpsilon): Longint;
begin
  Result := Orientation(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Epsilon);
end;





function IsClockWise(Pnts: TPoint2DArray): Boolean;
var
  I, L: Integer;
  LArea: Float;
  LPnts: TPoint2DArray;
begin
  Result := False;

  L := System.Length(Pnts);
  if L < 3 then Exit;

  LPnts := Pnts;
  if not IsEqual(LPnts[0], LPnts[L - 1]) then
  begin
    System.SetLength(LPnts, L + 1);
    LPnts[L] := LPnts[0];
  end;

  LArea := 0.0;
  for I := 0 to System.Length(LPnts) - 2 do
    LArea := LArea + (LPnts[I + 1].X - LPnts[I].X ) * (LPnts[I + 1].Y + LPnts[I].Y);// * 0.5;

  Result := LArea > 0.0;
end;

function IsClockWise(Arc: TArc2D; P1, P2: TPoint2D): Boolean;
var
  LAng1: Float;
  LAng2: Float;
begin
  LAng1 := UdGeo2D.GetAngle(Arc.Cen, P1);
  LAng2 := UdGeo2D.GetAngle(Arc.Cen, P2);

  Result := FixAngle(LAng1 - Arc.Ang1) > FixAngle(LAng2 - Arc.Ang1);

//  LAng := FixAngle(Arc.Ang1) + FixAngle(Arc.Ang2 - Arc.Ang1) / 2;
//  LPnt := ShiftPoint(Arc.Cen, LAng, Arc.R);
//  Result := IsPntOnLeftSide(LPnt, P1, P2);
end;






//=================================================================================================

function IsCoincident(Pnt1, Pnt2: TPoint2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsEqual(Pnt1, Pnt2, Epsilon);
end;


function IsCoincident(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := (IsCoincident(Ln1.P1, Ln2.P1, Epsilon) and IsCoincident(Ln1.P2, Ln2.P2, Epsilon)) or
            (IsCoincident(Ln1.P1, Ln2.P2, Epsilon) and IsCoincident(Ln1.P2, Ln2.P1, Epsilon));
end;

function IsCoincident(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := (IsCoincident(Seg1.P1, Seg2.P1, Epsilon) and IsCoincident(Seg1.P2, Seg2.P2, Epsilon)) or
            (IsCoincident(Seg1.P1, Seg2.P2, Epsilon) and IsCoincident(Seg1.P2, Seg2.P1, Epsilon));
end;

function IsCoincident(Rect1, Rect2: TRect2D; const Epsilon: Float = _Epsilon):Boolean;
begin
  Result := (IsCoincident(Rect1.P1, Rect2.P1, Epsilon) and IsCoincident(Rect1.P2, Rect2.P2, Epsilon)) or
            (IsCoincident(Rect1.P1, Rect2.P2, Epsilon) and IsCoincident(Rect1.P2, Rect2.P1, Epsilon));
end;

function IsCoincident(Cir1, Cir2: TCircle2D; const Epsilon: Float = _Epsilon):Boolean;
begin
  Result := IsCoincident(Cir1.Cen, Cir2.Cen, Epsilon) and IsEqual(Cir1.R, Cir2.R, Epsilon);
end;

function IsCoincident(Arc1, Arc2: TArc2D; const Epsilon: Float = _Epsilon):Boolean;
begin
  Result := IsCoincident(Arc1.Cen, Arc2.Cen, Epsilon) and IsEqual(Arc1.R, Arc2.R, Epsilon) and
            IsEqual(Arc1.Ang1, Arc2.Ang1, Epsilon) and IsEqual(Arc1.Ang2, Arc2.Ang2, Epsilon);
end;

function IsCoincident(Ell1, Ell2: TEllipse2D; const Epsilon: Float = _Epsilon):Boolean;
begin
  Result := IsCoincident(Ell1.Cen, Ell2.Cen, Epsilon) and
            IsEqual(Ell1.Rx, Ell2.Rx, Epsilon) and IsEqual(Ell1.Ry, Ell2.Ry, Epsilon) and
            IsEqual(Ell1.Ang1, Ell2.Ang1, Epsilon) and IsEqual(Ell1.Ang2, Ell2.Ang2, Epsilon);
end;




//-------------------------------------------------------------------------------------------------

function IsDegenerate(X1,Y1, X2,Y2:Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsEqual(X1, X2, Epsilon) and IsEqual(Y1, Y2, Epsilon);
end;

function IsDegenerate(Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsDegenerate(Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Epsilon);
end;

function IsDegenerate(Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsDegenerate(Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y, Epsilon);
end;

function IsDegenerate(Rect: TRect2D; const Epsilon: Float = _Epsilon):Boolean;
begin
  Result := IsDegenerate(Rect.P1.X, Rect.P1.Y, Rect.P2.X, Rect.P2.Y, Epsilon);
end;

function IsDegenerate(Cir: TCircle2D; const Epsilon: Float = _Epsilon):Boolean;
begin
  Result := {(Cir.R < 0.0) or} IsEqual(Cir.R, 0.0, Epsilon);
end;

function IsDegenerate(Arc: TArc2D; const Epsilon: Float = _Epsilon):Boolean;
begin
  Result := {(Arc.R < 0.0) or} IsEqual(Arc.R, 0.0, Epsilon) or IsEqual(Arc.Ang1, Arc.Ang2, Epsilon);
end;

function IsDegenerate(Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := (IsEqual(Ell.Rx, 0.0, Epsilon) and IsEqual(Ell.Ry, 0.0, Epsilon)) or IsEqual(Ell.Ang1, Ell.Ang2, Epsilon);
end;

function IsDegenerate(Segarc: TSegarc2D; const Epsilon: Float = _Epsilon):Boolean;
begin
  if Segarc.IsArc then
    Result := IsDegenerate(Segarc.Arc, Epsilon)
  else
    Result := IsDegenerate(Segarc.Seg, Epsilon);
end;







//-------------------------------------------------------------------------------------------------

function IsCollinear(X1, Y1, X2, Y2, X3, Y3: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsEqual((X2 - X1) * (Y3 - Y1), (X3 - X1) * (Y2 - Y1), Epsilon);
end;

function IsCollinear(Pnt1, Pnt2, Pnt3: TPoint2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsCollinear(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y, Epsilon);
end;

function IsRobustCollinear(X1, Y1, X2, Y2, X3, Y3: Float; const Epsilon: Float = _Epsilon): Boolean;
var
  LayDist1: Float;
  LayDist2: Float;
  LayDist3: Float;
begin
  LayDist1 := LayDistance(X1, Y1, X2, Y2);
  LayDist2 := LayDistance(X2, Y2, X3, Y3);
  LayDist3 := LayDistance(X3, Y3, X1, Y1);

  if LayDist1 >= LayDist2 then
  begin
    if LayDist1 >= LayDist3 then
      Result := IsEqual(DistanceToLine(X3, Y3, X1, Y1, X2, Y2), 0.0, Epsilon)
    else
      Result := IsEqual(DistanceToLine(X2, Y2, X3, Y3, X1, Y1), 0.0, Epsilon)
  end
  else if LayDist2 >= LayDist3 then
    Result := IsEqual(DistanceToLine(X1, Y1, X2, Y2, X3, Y3), 0.0, Epsilon)
  else
    Result := IsEqual(DistanceToLine(X2, Y2, X3, Y3, X1, Y1), 0.0, Epsilon);
end;

function IsRobustCollinear(Pnt1, Pnt2, Pnt3: TPoint2D; const Epsilon: Float = _Epsilon): Boolean;
begin
 Result := IsRobustCollinear(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y, Epsilon);
end;




function IsPntCollinear(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon; Robust: Boolean = False): Boolean;
var
  OK: Boolean;
  LowEpsilon: Float;
begin
  Result := False;

  LowEpsilon := Epsilon * 10;

  if IsEqual(X1, X2, LowEpsilon) then
    OK := IsEqual(X1, Px, LowEpsilon)
  else
    OK := ((X1 <= Px + LowEpsilon) and (Px - LowEpsilon <= X2)) or
          ((X2 <= Px + LowEpsilon) and (Px - LowEpsilon <= X1));

  if not OK then Exit;  //=====>>>>>

  if IsEqual(Y1, Y2, LowEpsilon) then
    OK := IsEqual(Y1, Py, LowEpsilon)
  else
    OK := ((Y1 <= Py + LowEpsilon) and (Py - LowEpsilon <= Y2)) or
          ((Y2 <= Py + LowEpsilon) and (Py - LowEpsilon <= Y1));

  if not OK then Exit; //=====>>>>>

  if Robust then
    Result := IsRobustCollinear(Px,Py, X1,Y1, X2,Y2, Epsilon)
  else
    Result := IsCollinear(Px,Py, X1,Y1, X2,Y2, Epsilon);
end;

function IsPntCollinear(PntP, Pnt1, Pnt2: TPoint2D; const Epsilon: Float = _Epsilon; Robust: Boolean = False): Boolean;
begin
  Result := IsPntCollinear(PntP.X, PntP.Y, Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Epsilon, Robust);
end;

function IsPntCollinear(Pnt: TPoint2D; Ln: TLine2D; const Epsilon: Float = _Epsilon; Robust: Boolean = False): Boolean;
begin
  Result := IsPntCollinear(Pnt.X, Pnt.Y, Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y, Epsilon, Robust);
end;

function IsPntCollinear(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon; Robust: Boolean = False): Boolean;
begin
  Result := IsPntCollinear(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Epsilon, Robust);
end;



//-------------------------------------------------------------------------------------------------

function IsPntOnLeftSide(Px,Py, x1,y1, x2,y2:Float): Boolean;
begin
  Result := (Orientation(Px,Py, x1,y1, x2,y2) > 0.0);
end;

function IsPntOnLeftSide(Pnt: TPoint2D; P1, P2: TPoint2D):Boolean;
begin
  Result := (Orientation(Pnt.X,Pnt.Y, P1.X,P1.Y, P2.X,P2.Y) > 0.0);
end;

function IsPntOnLeftSide(X, Y: Float; Ln: TLine2D): Boolean;
begin
  Result := (Orientation(X, Y, Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y) > 0.0);
end;

function IsPntOnLeftSide(Pnt: TPoint2D; Ln: TLine2D): Boolean;
begin
  Result := (Orientation(Pnt.X, Pnt.Y, Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y) > 0.0);
end;

function IsPntOnLeftSide(Pnt: TPoint2D; Seg: TSegment2D): Boolean;
begin
  Result := (Orientation(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y) > 0.0);
end;

function IsPntOnLeftSide(Pnt: TPoint2D; Arc: TArc2D): Boolean;
var
  P1, P2: TPoint2D;
begin
  Result := False;
  if Arc.R <= 0 then Exit;

  P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
  P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
  if Arc.IsCW then Swap(P1, P2);

  if Arc.IsCW then
  begin
    Result := IsPntOnLeftSide(Pnt, P1, P2) and
              not IsPntInCircle(Pnt, Circle2D(Arc.Cen, Arc.R));
  end
  else begin
    Result := IsPntOnLeftSide(Pnt, P1, P2) or
              IsPntInCircle(Pnt, Circle2D(Arc.Cen, Arc.R));
  end;
end;

function IsPntOnLeftSide(Pnt: TPoint2D; Ell: TEllipse2D): Boolean;
var
  P1, P2: TPoint2D;
begin
  Result := False;
  if IsEqual(Ell.Rx, 0.0) and IsEqual(Ell.Ry, 0.0) then Exit;

  if IsEqual(Ell.Ang1, Ell.Ang2) or
    (IsEqual(Ell.Ang1, 0.0) and IsEqual(Ell.Ang2, 360.0)) then
  begin
    Result := IsPntInEllipse(Pnt, Ell);
    Exit; //=====>>>
  end;

  P1 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang1);
  P2 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang2);
  if Ell.IsCW then Swap(P1, P2);

  if Ell.IsCW then
  begin
    Result := IsPntOnLeftSide(Pnt, P1, P2) and
              not IsPntInEllipse(Pnt, Ellipse2D(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot));
  end
  else begin
    Result := IsPntOnLeftSide(Pnt, P1, P2) or
              IsPntInEllipse(Pnt, Ellipse2D(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot));
  end;
end;

function IsPntOnLeftSide(Pnt: TPoint2D; Segarc: TSegarc2D): Boolean;
begin
  if Segarc.IsArc then
    Result := IsPntOnLeftSide(Pnt, Segarc.Arc)
  else
    Result := IsPntOnLeftSide(Pnt, Segarc.Seg);
end;



function IsPntOnRightSide(Px,Py, x1,y1,x2,y2:Float):Boolean;
begin
  Result := (Orientation(Px,Py, x1,y1, x2,y2) < 0.0);
end;

function IsPntOnRightSide(Pnt: TPoint2D; P1, P2: TPoint2D):Boolean;
begin
  Result := (Orientation(Pnt.X,Pnt.Y, P1.X,P1.Y, P2.X,P2.Y) < 0.0);
end;

function IsPntOnRightSide(X, Y: Float; Ln: TLine2D): Boolean;
begin
  Result := (Orientation(X, Y, Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y) < 0.0);
end;

function IsPntOnRightSide(Pnt: TPoint2D; Ln: TLine2D): Boolean;
begin
  Result := (Orientation(Pnt.X, Pnt.Y, Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y) < 0.0);
end;

function IsPntOnRightSide(Pnt: TPoint2D; Seg: TSegment2D): Boolean;
begin
  Result := (Orientation(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y) < 0.0);
end;

function IsPntOnRightSide(Pnt: TPoint2D; Arc: TArc2D): Boolean;
var
  P1, P2: TPoint2D;
begin
  Result := False;
  if Arc.R <= 0 then Exit;

  P1 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
  P2 := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
  if Arc.IsCW then Swap(P1, P2);

  if Arc.IsCW then
  begin
    Result := IsPntOnRightSide(Pnt, P1, P2) or
              IsPntInCircle(Pnt, Circle2D(Arc.Cen, Arc.R));
  end
  else begin
    Result := IsPntOnRightSide(Pnt, P1, P2) and
              not IsPntInCircle(Pnt, Circle2D(Arc.Cen, Arc.R));
  end;
end;

function IsPntOnRightSide(Pnt: TPoint2D; Ell: TEllipse2D): Boolean;
var
  P1, P2: TPoint2D;
begin
  Result := False;
  if IsEqual(Ell.Rx, 0.0) and IsEqual(Ell.Ry, 0.0) then Exit;

  if IsEqual(Ell.Ang1, Ell.Ang2) or
    (IsEqual(Ell.Ang1, 0.0) and IsEqual(Ell.Ang2, 360.0)) then
  begin
    Result := not IsPntInEllipse(Pnt, Ell);
    Exit; //=====>>>
  end;

  P1 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang1);
  P2 := GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang2);
  if Ell.IsCW then Swap(P1, P2);

  if Ell.IsCW then
  begin
    Result := IsPntOnRightSide(Pnt, P1, P2) or
              IsPntInEllipse(Pnt, Ellipse2D(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot));
  end
  else begin
    Result := IsPntOnRightSide(Pnt, P1, P2) and
              not IsPntInEllipse(Pnt, Ellipse2D(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot));
  end;
end;

function IsPntOnRightSide(Pnt: TPoint2D; Segarc: TSegarc2D): Boolean;
begin
  if Segarc.IsArc then
    Result := IsPntOnRightSide(Pnt, Segarc.Arc)
  else
    Result := IsPntOnRightSide(Pnt, Segarc.Seg);
end;





//-------------------------------------------------------------------------------------------------

function IsConvexPolygon(Poly: TPoint2DArray): Boolean;
var
  I, J, K: Longint;
  InitOrin: Longint;
  CurnOrin: Longint;
  FirstTime: Boolean;
begin
  Result := False;
  if System.Length(Poly) < 3 then Exit; //---->>>>

  FirstTime := True;
  InitOrin := Orientation(Poly[0], Poly[System.Length(Poly) - 2], Poly[High(Poly)]);
  J := 0;
  K := High(Poly);
  for I := 1 to High(Poly) do
  begin
    CurnOrin := Orientation(Poly[I], Poly[K], Poly[J]);
    if (InitOrin = 0) and (InitOrin <> CurnOrin) and FirstTime then
    begin
      InitOrin := CurnOrin;
      FirstTime := False;
    end
    else if (InitOrin <> CurnOrin) and (CurnOrin <> 0.0) then
      Exit; //---->>>>

    K := J;
    J := I;
  end;
  Result := True;
end;


function IsConvexPolygon(Poly: array of TPoint2D): Boolean;
var
  I, J, K: Longint;
  InitOrin: Longint;
  CurnOrin: Longint;
begin
  Result := False;
  if System.Length(Poly) < 3 then Exit; //---->>>>

  InitOrin := Orientation(Poly[0], Poly[System.Length(Poly) - 2], Poly[High(Poly)]);
  J := 0;
  K := High(Poly);
  for I := 1 to High(Poly) do
  begin
    CurnOrin := Orientation(Poly[I], Poly[K], Poly[J]);
    if (InitOrin = 0) and (InitOrin <> CurnOrin) then
      InitOrin := CurnOrin
    else if (InitOrin <> CurnOrin) and (CurnOrin <> 0.0) then
      Exit; //---->>>>

    K := J;
    J := I;
  end;
  Result := True;
end;








//-------------------------------------------------------------------------------------------------

function IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float): Boolean;
begin
  Result := TUdInct2D.IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;


function IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out iX, iY: Float): Boolean;
begin
  Result := TUdInct2D.IsIntersect(X1, Y1, X2, Y2, X3, Y3, X4, Y4, iX, iY);
end;

function IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4);
end;

function IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D; out iX, iY: Float): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Pnt1, Pnt2, Pnt3, Pnt4, iX, iY);
end;



function IsIntersect(Ln1, Ln2: TLine2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Ln1, Ln2);
end;

function IsIntersect(Seg1, Seg2: TSegment2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Seg1, Seg2);
end;

function IsIntersect(Ln: TLine2D; Seg: TSegment2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Ln, Seg);
end;



function IsIntersect(Ln: TLine2D; Rect: TRect2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Ln, Rect);
end;

function IsIntersect(Seg: TSegment2D; Rect: TRect2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Seg, Rect);
end;



function IsIntersect(Ln: TLine2D; Cir: TCircle2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Ln, Cir);
end;

function IsIntersect(Seg: TSegment2D; Cir: TCircle2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Seg, Cir);
end;


function IsIntersect(Ln: TLine2D; Arc: TArc2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Ln, Arc);
end;

function IsIntersect(Seg: TSegment2D; Arc: TArc2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Seg, Arc);
end;



function IsIntersect(Ln: TLine2D; Poly: TPoint2DArray): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Ln, Poly);
end;

function IsIntersect(Seg: TSegment2D; Poly: TPoint2DArray): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Seg, Poly);
end;




//------------------------------------------------------

function IsIntersect(Rect1, Rect2: TRect2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Rect1, Rect2);
end;

function IsIntersect(Rect: TRect2D; Cir: TCircle2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Rect, Cir);
end;

//secure, fast, but not exact
function IsIntersect(Rect: TRect2D; Arc: TArc2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Rect, Arc);
end;

function IsIntersect(Rect: TRect2D; Ell: TEllipse2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Rect, Ell);
end;

function IsIntersect(Rect: TRect2D; Poly: TPoint2DArray): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Rect, Poly);
end;



//------------------------------------------------------

function IsIntersect(Cir1, Cir2: TCircle2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Cir1, Cir2);
end;

//secure, fast, but not exact
function IsIntersect(Cir: TCircle2D; Arc: TArc2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Cir, Arc);
end;

function IsIntersect(Cir: TCircle2D; Poly: TPoint2DArray): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Cir, Poly);
end;



//------------------------------------------------------

function IsIntersect(Arc1, Arc2: TArc2D): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Arc1, Arc2);
end;

//secure, fast, but not exact
function IsIntersect(Arc: TArc2D; Poly: TPoint2DArray): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Arc, Poly);
end;




//------------------------------------------------------

function IsIntersect(Poly1, Poly2: TPoint2DArray): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Poly1, Poly2);
end;



function IsIntersect(Ln: TLine2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Ln, Segarc, Epsilon);
end;

function IsIntersect(Seg: TSegment2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Seg, Segarc, Epsilon);
end;

function IsIntersect(Cir: TCircle2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Cir, Segarc, Epsilon);
end;

function IsIntersect(Arc: TArc2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Arc, Segarc, Epsilon);
end;

function IsIntersect(Rect: TRect2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Rect, Segarc, Epsilon);
end;

function IsIntersect(Segarc1, Segarc2: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Segarc1, Segarc2, Epsilon);
end;



function IsIntersect(Ln: TLine2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Ln, Segarcs, Epsilon);
end;

function IsIntersect(Seg: TSegment2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Seg, Segarcs, Epsilon);
end;

function IsIntersect(Cir: TCircle2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Cir, Segarcs, Epsilon);
end;

function IsIntersect(Arc: TArc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Arc, Segarcs, Epsilon);
end;

function IsIntersect(Rect: TRect2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Rect, Segarcs, Epsilon);
end;

function IsIntersect(Poly: TPolygon2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Poly, Segarcs, Epsilon);
end;

function IsIntersect(Segarcs1, Segarcs2: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdInct2D.IsIntersect(Segarcs1, Segarcs2, Epsilon);
end;



//function IsIntersect(Ray: TRay2D; Ln: TLine2D): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Ln)) > 0;
//end;
//
//function IsIntersect(Ray: TRay2D; Seg: TSegment2D): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Seg)) > 0;
//end;
//
//function IsIntersect(Ray: TRay2D; Arc: TArc2D): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Arc)) > 0;
//end;
//
//function IsIntersect(Ray: TRay2D; Cir: TCircle2D): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Cir)) > 0;
//end;
//
//function IsIntersect(Ray: TRay2D; Rect: TRect2D): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Rect)) > 0;
//end;
//
//function IsIntersect(Ray: TRay2D; Ell: TEllipse2D): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Ell)) > 0;
//end;
//
//function IsIntersect(Ray: TRay2D; Poly: TPoint2DArray): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Poly)) > 0;
//end;
//
//function IsIntersect(Ray: TRay2D; Rect: TRect2D): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Rect)) > 0;
//end;
//
//function IsIntersect(Ray: TRay2D; Segarc: TSegarc2D): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Segarc)) > 0;
//end;
//
//function IsIntersect(Ray: TRay2D; Segarcs: TSegarc2DArray): Boolean;
//begin
//  Result := System.Length(TUdInct2D.Intersection(Ray, Segarcs)) > 0;
//end;


function IsSelfIntersect(Poly: TPolygon2D):Boolean;
begin
  Result := TUdInct2D.IsSelfIntersect(Poly);
end;

function IsSelfIntersect(Segarcs: TSegarc2DArray): Boolean;
begin
  Result := TUdInct2D.IsSelfIntersect(Segarcs);
end;




//-------------------------------------------------------------------------------------------------


function IsParallel(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out E: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  E := 0;
  Result := UdMath.IsEqual(((Y1 - Y2) * (X3 - X4)), ((Y3 - Y4) * (X1 - X2)), Epsilon);

  if Result then
  begin
    E := _PARALLEL;
    if IsCollinear(X1, Y1, X2, Y2, X3, Y3, Epsilon) or
       IsCollinear(X1, Y1, X2, Y2, X4, Y4, Epsilon) then E := _OVERLAP;
  end;
end;

function IsParallel(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D; out E: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsParallel(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y, Pnt4.X, Pnt4.Y, E, Epsilon);
end;

function IsParallel(Ln1, Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsParallel(Ln1.P1.X, Ln1.P1.Y, Ln1.P2.X, Ln1.P2.Y, Ln2.P1.X, Ln2.P1.Y, Ln2.P2.X, Ln2.P2.Y, E, Epsilon);
end;

function IsParallel(Seg1, Seg2: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsParallel(Seg1.P1.X, Seg1.P1.Y, Seg1.P2.X, Seg1.P2.Y, Seg2.P1.X, Seg2.P1.Y, Seg2.P2.X, Seg2.P2.Y, E, Epsilon);
end;

function IsParallel(Ln: TLine2D; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsParallel(Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, E, Epsilon);
end;



function IsParallel(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; const Epsilon: Float = _Epsilon): Boolean;
var
  E: Integer;
begin
  Result := IsParallel(X1, Y1, X2, Y2, X3, Y3, X4, Y4, E, Epsilon);
end;

function IsParallel(Pnt1, Pnt2, Pnt3, Pnt4: TPoint2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsParallel(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y, Pnt4.X, Pnt4.Y, Epsilon);
end;

function IsParallel(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsParallel(Ln1.P1.X, Ln1.P1.Y, Ln1.P2.X, Ln1.P2.Y, Ln2.P1.X, Ln2.P1.Y, Ln2.P2.X, Ln2.P2.Y, Epsilon);
end;

function IsParallel(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsParallel(Seg1.P1.X, Seg1.P1.Y, Seg1.P2.X, Seg1.P2.Y, Seg2.P1.X, Seg2.P1.Y, Seg2.P2.X, Seg2.P2.Y, Epsilon);
end;

function IsParallel(Ln: TLine2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsParallel(Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Epsilon);
end;





//-------------------------------------------------------------------------------------------------

function IsPerpendicular(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  //Result := IsEqual((Y2 - Y1) * (X3 - X4), (Y4 - Y3) * (X2 - X1) * -1);
  Result := IsEqual(-1.0 * (Y2 - Y1) * (Y4 - Y3), (X4 - X3) * (X2 - X1), Epsilon);
end;

function IsPerpendicular(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPerpendicular(Ln1.P1.X, Ln1.P1.Y, Ln1.P2.X, Ln1.P2.Y, Ln2.P1.X, Ln2.P1.Y, Ln2.P2.X, Ln2.P2.Y, Epsilon);
end;

function IsPerpendicular(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPerpendicular(Seg1.P1.X, Seg1.P1.Y, Seg1.P2.X, Seg1.P2.Y, Seg2.P1.X, Seg2.P1.Y, Seg2.P2.X, Seg2.P2.Y, Epsilon);
end;

function IsPerpendicular(Ln: TLine2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := IsPerpendicular(Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Epsilon);
end;




function IsTangent(Seg: TSegment2D; Cir: TCircle2D):Boolean;
var
  rSqr: Float;
  dSqr: Float;
  drSqr: Float;
  TmpSeg: TSegment2D;
begin
  TmpSeg := Translate(-Cir.Cen.X, -Cir.Cen.Y, Seg);
  rSqr   := Cir.R * Cir.R;
  drSqr  := LayDistance(TmpSeg.P1, TmpSeg.P2);
  dSqr   := Sqr(TmpSeg.P1.x * TmpSeg.P2.y - TmpSeg.P2.x * TmpSeg.P1.y);
  Result := (IsEqual((rSqr * drSqr - dSqr), 0.0));
end;




//-------------------------------------------------------------------------------------------------

function IsPntInSegment(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInSegment(Px, Py, X1, Y1, X2, Y2, Epsilon);
end;

function IsPntInSegment(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInSegment(Pnt, Seg, Epsilon);
end;



function IsPntInRect(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInRect(Px, Py, X1, Y1, X2, Y2, Epsilon);
end;

function IsPntInRect(Pnt: TPoint2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInRect(Pnt, Rect, Epsilon);
end;



function IsPntInCircle(Px,Py, Cx,Cy, Radius: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInCircle(Px, Py, Cx,Cy, Radius, Epsilon);
end;

function IsPntInCircle(Px, Py: Float; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInCircle(Px, Py, Circle, Epsilon);
end;

function IsPntInCircle(Pnt: TPoint2D; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInCircle(Pnt, Circle, Epsilon);
end;


function FastIsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.FastIsPntInPolygon(Px, Py, Poly, Epsilon);
end;


function FastIsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.FastIsPntInPolygon(Pnt, Poly, Epsilon);
end;



function IsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInPolygon(Px, Py, Poly, Epsilon);
end;

function IsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInPolygon(Pnt, Poly, Epsilon);
end;


function AbsIsPntInPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.AbsIsPntInPolygon(Px, Py, Poly, Epsilon);
end;

function AbsIsPntInPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.AbsIsPntInPolygon(Pnt, Poly, Epsilon);
end;



function IsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInPolygons(X, Y, Polygons, Index, Epsilon);
end;

function IsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInPolygons(Pnt, Polygons, Index, Epsilon);
end;


function IsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInPolygons(X, Y, Polygons, Epsilon);
end;

function IsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInPolygons(Pnt, Polygons, Epsilon);
end;




function FastIsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.FastIsPntInPolygons(X, Y, Polygons, Index, Epsilon);
end;

function FastIsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.FastIsPntInPolygons(Pnt, Polygons, Index, Epsilon);
end;


function FastIsPntInPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.FastIsPntInPolygons(X, Y,  Polygons, Epsilon);
end;

function FastIsPntInPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.FastIsPntInPolygons(Pnt, Polygons, Epsilon);
end;







function IsCircleInCircle(Cir1, Cir2: TCircle2D):Boolean;
begin
  Result := TUdRela2D.IsCircleInCircle(Cir1, Cir2);
end;


function IsPntInArc(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInArc(Px, Py, Arc, Epsilon);
end;

function IsPntInArc(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInArc(Pnt, Arc, Epsilon);
end;



function IsPntInSegarcs(Px, Py: Float; Segarcs: TSegarc2DArray; OnIsValid: Boolean = True; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInSegarcs(Px, Py, Segarcs, OnIsValid, Epsilon);
end;

function IsPntInSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray; OnIsValid: Boolean = True; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInSegarcs(Pnt, Segarcs, OnIsValid, Epsilon);
end;


function IsPntInEllipse(Px, Py: Float; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInEllipse(Px, Py, Ell, Epsilon);
end;

function IsPntInEllipse(Pnt: TPoint2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntInEllipse(Pnt, Ell, Epsilon);
end;



//-------------------------------------------------------------------------------------------------

function IsPntOnRay(Pnt: TPoint2D; Ray: TRay2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnRay(Pnt, Ray, Epsilon);
end;

function IsPntOnRay(Px, Py: Float; Ray: TRay2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnRay(Px, Py, Ray, Epsilon);
end;

function IsPntOnLine(Px, Py: Float; Ln: TLineK; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnLine(Px, Py, Ln, Epsilon);
end;

function IsPntOnLine(Px, Py: Float; Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnLine(Px, Py, Ln, Epsilon);
end;

function IsPntOnLine(Pnt: TPoint2D; Ln: TLineK; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnLine(Pnt, Ln, Epsilon);
end;

function IsPntOnLine(Pnt: TPoint2D; Ln: TLine2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnLine(Pnt, Ln, Epsilon);
end;



function IsPntOnSegment(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnSegment(Px, Py, X1, Y1, X2, Y2, Epsilon);
end;

function IsPntOnSegment(Pnt: TPoint2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnSegment(Pnt, Seg, Epsilon);
end;



function IsPntOnRect(Px, Py: Float; X1, Y1, X2, Y2: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnRect(Px, Py, X1, Y1, X2, Y2, Epsilon);
end;

function IsPntOnRect(Pnt: TPoint2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnRect(Pnt, Rect, Epsilon);
end;



function IsPntOnCircle(Px, Py: Float; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnCircle(Px, Py, Cx, Cy, Radius, Epsilon);
end;

function IsPntOnCircle(Px, Py: Float; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnCircle(Px, Py, Circle, Epsilon);
end;

function IsPntOnCircle(Pnt: TPoint2D; Circle: TCircle2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnCircle(Pnt, Circle, Epsilon);
end;



function IsPntOnArc(Px, Py: Float; Cx, Cy, Radius, Ang1, Ang2: Float; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnArc(Px, Py,  Cx, Cy, Radius, Ang1, Ang2, Epsilon);
end;

function IsPntOnArc(Px, Py: Float; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnArc(Px, Py,  Arc, Epsilon);
end;

function IsPntOnArc(Pnt: TPoint2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnArc(Pnt, Arc, Epsilon);
end;



function IsPntOnPolygon(Px, Py: Float; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnPolygon(Px, Py,  Poly, Epsilon);
end;

function IsPntOnPolygon(Pnt: TPoint2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnPolygon(Pnt,  Poly, Epsilon);
end;



function IsPntOnPolygons(X, Y: Float; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnPolygons(X, Y,  Polygons, Index, Epsilon);
end;

function IsPntOnPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; out Index: Integer; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnPolygons(Pnt, Polygons, Index, Epsilon);
end;


function IsPntOnPolygons(X, Y: Float; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnPolygons(X, Y,  Polygons, Epsilon);
end;

function IsPntOnPolygons(Pnt: TPoint2D; Polygons: TPolygon2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnPolygons(Pnt,  Polygons, Epsilon);
end;



function IsPntOnSegarc(Pnt: TPoint2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnSegarc(Pnt, Segarc, Epsilon);
end;

function IsPntOnSegarcs(Px, Py: Float; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnSegarcs(Px, Py,  Segarcs, Epsilon);
end;

function IsPntOnSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnSegarcs(Pnt,  Segarcs, Epsilon);
end;

function IsPntOnEllipse(Px, Py: Float; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnEllipse(Px, Py,  Ell, Epsilon);
end;

function IsPntOnEllipse(Pnt: TPoint2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): Boolean;
begin
  Result := TUdRela2D.IsPntOnEllipse(Pnt,  Ell, Epsilon);
end;






//-------------------------------------------------------------------------------------------------

function Distance(X1, Y1, X2, Y2: Float): Float;
begin
  Result := TUdDist2D.Distance(X1, Y1, X2, Y2);
end;

function Distance(Pnt1, Pnt2: TPoint2D): Float;
begin
  Result := TUdDist2D.Distance(Pnt1, Pnt2);
end;

function Distance(Seg: TSegment2D): Float;
begin
  Result := TUdDist2D.Distance(Seg);
end;

function Distance(R, Ang1, Ang2: Float): Float;
begin
  Result := TUdDist2D.Distance(R, Ang1, Ang2);
end;

function Distance(Arc: TArc2D): Float;
begin
  Result := TUdDist2D.Distance(Arc);
end;

function Distance(Seg: TSegarc2D): Float;
begin
  Result := TUdDist2D.Distance(Seg);
end;


function LayDistance(X1, Y1, X2, Y2: Float): Float;
begin
  Result := TUdDist2D.LayDistance(X1, Y1, X2, Y2);
end;

function LayDistance(Pnt1, Pnt2: TPoint2D): Float;
begin
  Result := TUdDist2D.LayDistance(Pnt1, Pnt2);
end;



function ManDistance(X1, Y1, X2, Y2: Float): Float;
begin
  Result := TUdDist2D.ManDistance(X1, Y1, X2, Y2);
end;

function ManDistance(Pnt1, Pnt2: TPoint2D): Float;
begin
  Result := TUdDist2D.ManDistance(Pnt1, Pnt2);
end;




function LayDistanceSegments(X1,Y1, X2,Y2, X3,Y3, X4,Y4: Float): Float;
begin
  Result := TUdDist2D.LayDistanceSegments(X1,Y1, X2,Y2, X3,Y3, X4,Y4);
end;

function LayDistanceSegments(Seg1, Seg2: TSegment2D): Float;
begin
  Result := TUdDist2D.LayDistanceSegments(Seg1, Seg2);
end;

function DistanceSegments(Seg1, Seg2: TSegment2D): Float;
begin
  Result := TUdDist2D.DistanceSegments(Seg1, Seg2);
end;

function LayDistanceLines(X1,Y1, X2,Y2, X3,Y3, X4,Y4: Float): Float;
begin
  Result := TUdDist2D.LayDistanceLines(X1,Y1, X2,Y2, X3,Y3, X4,Y4);
end;

function LayDistanceLines(Line1, Line2: TLine2D): Float;
begin
  Result := TUdDist2D.LayDistanceLines(Line1, Line2);
end;

function DistanceLines(Line1, Line2: TLine2D): Float;
begin
  Result := TUdDist2D.DistanceLines(Line1, Line2);
end;




//-------------------------------------------------------------------------------------------------

function DistanceToRay(Px,Py: Float; Ray: TRay2D): Float;
begin
  Result := TUdDist2D.DistanceToRay(Px,Py, Ray);
end;

function DistanceToRay(Pnt: TPoint2D; Ray: TRay2D): Float;
begin
  Result := TUdDist2D.DistanceToRay(Pnt, Ray);
end;

function DistanceToLine(Px,Py: Float; Ln: TLineK): Float;
begin
  Result := TUdDist2D.DistanceToLine(Px,Py, Ln);
end;

function DistanceToLine(Pnt: TPoint2D; Ln: TLineK): Float;
begin
  Result := TUdDist2D.DistanceToLine(Pnt, Ln);
end;


function DistanceToLine(Px,Py, X1,Y1, X2,Y2: Float): Float;
begin
  Result := TUdDist2D.DistanceToLine(Px,Py, X1,Y1, X2,Y2);
end;

function DistanceToLine(Pnt: TPoint2D; Ln: TLine2D): Float;
begin
  Result := TUdDist2D.DistanceToLine(Pnt, Ln);
end;



function DistanceToSegment(Px,Py, X1,Y1, X2,Y2: Float; out Idx: Integer): Float;
begin
  Result := TUdDist2D.DistanceToSegment(Px,Py, X1,Y1, X2,Y2, Idx);
end;

function DistanceToSegment(Pnt: TPoint2D; Seg: TSegment2D; out Idx: Integer): Float;
begin
  Result := TUdDist2D.DistanceToSegment(Pnt, Seg, Idx);
end;


function DistanceToSegment(Px,Py, X1,Y1, X2,Y2: Float): Float;
begin
  Result := TUdDist2D.DistanceToSegment(Px,Py, X1,Y1, X2,Y2);
end;

function DistanceToSegment(Pnt: TPoint2D; Seg: TSegment2D): Float;
begin
  Result := TUdDist2D.DistanceToSegment(Pnt, Seg);
end;


function DistanceToRect(Px,Py, X1,Y1, X2,Y2:Float): Float;
begin
  Result := TUdDist2D.DistanceToRect(Px,Py, X1,Y1, X2,Y2);
end;

function DistanceToRect(Pnt: TPoint2D; Rect: TRect2D): Float;
begin
  Result := TUdDist2D.DistanceToRect(Pnt, Rect);
end;


function DistanceToPolygon(Pnt: TPoint2D; Poly: TPoint2DArray): Float;
begin
  Result := TUdDist2D.DistanceToPolygon(Pnt, Poly);
end;

function DistanceToArc(Pnt: TPoint2D; Arc: TArc2D): Float;
begin
  Result := TUdDist2D.DistanceToArc(Pnt, Arc);
end;

function DistanceToCircle(Pnt: TPoint2D; Cir: TCircle2D): Float;
begin
  Result := TUdDist2D.DistanceToCircle(Pnt, Cir);
end;

function DistanceToEllipse(Pnt: TPoint2D; Ell: TEllipse2D): Float;
begin
  Result := TUdDist2D.DistanceToEllipse(Pnt, Ell);
end;

function DistanceToSegarc(Pnt: TPoint2D; Segarc: TSegarc2D): Float;
begin
  Result := TUdDist2D.DistanceToSegarc(Pnt, Segarc);
end;

function DistanceToSegarcs(Pnt: TPoint2D; Segarcs: TSegarc2DArray): Float;
begin
  Result := TUdDist2D.DistanceToSegarcs(Pnt, Segarcs);
end;






//-------------------------------------------------------------------------------------------------

function Area(Rect: TRect2D): Float;
begin
  Result := (Rect.P2.X - Rect.P1.X) * (Rect.P2.Y - Rect.P1.Y);
end;

function Area(Cir: TCircle2D): Float;
begin
  Result := PI * Cir.R * Cir.R;
end;


function Area(Poly: TPoint2DArray): Float;
var
  I, N: Longint;
begin
  Result := 0.0;

  if System.Length(Poly) < 3 then Exit;   //---->>>>

  N := High(Poly);
  for I := Low(Poly) to High(Poly) do
  begin
    Result := Result + ((Poly[N].X * Poly[I].Y) - (Poly[N].Y * Poly[I].X));
    N := I;
  end;
  Result := Abs(Result * 0.5);
end;

function Area(Arc: TArc2D; Kind: TArcKind = akSector): Float;
var
  DeltaA: Float;
  LPoly: TPoint2DArray;
begin
  Result := 0.0;
  if Kind = akCurve then Exit; //=======>>>>

  LPoly := nil;

  DeltaA := FixAngle(Arc.Ang2 - Arc.Ang1);
  Result := (PI * Arc.R * Arc.R) * (DeltaA / 360.0);

  if NotEqual(DeltaA, 180.0) and (Kind = akChord) then
  begin
    System.SetLength(LPoly, 4);
    LPoly[0] := Arc.Cen;
    LPoly[1] := ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R);
    LPoly[2] := ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R);
    LPoly[3] := Arc.Cen;

    if DeltaA < 180.0 then
      Result := Result - Area(LPoly)
    else
      Result := Result + Area(LPoly);
  end;
end;

function Area(Segarcs: TSegarc2DArray): Float;
var
  I: Integer;
  LPolygon: TPolygon2D;
begin
  LPolygon := SamplePoints(Segarcs, True);
  Result := Area(LPolygon);

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    if not Segarcs[I].IsArc then Continue;

    if FastIsPntInPolygon(MidPoint(Segarcs[I].Arc), LPolygon) then
      Result := Result - Area(Segarcs[I].Arc, akChord)
    else
      Result := Result + Area(Segarcs[I].Arc, akChord);
  end;
end;


//-------------------------------------------------------------------------------------------------

function Perimeter(Rect: TRect2D): Float;
begin
  Result := 2 * ((Rect.P2.X - Rect.P1.X) + (Rect.P2.Y - Rect.P1.Y));
end;

function Perimeter(Cir: TCircle2D): Float;
begin
  Result := 2 * PI * Cir.R;
end;

function Perimeter(Poly: TPoint2DArray; Closed: Boolean = False): Float;
var
  I, Len: Longint;
begin
  Result := 0;
  Len := System.Length(Poly);
  if Closed then
  begin
    for I := 0 to Len - 1 do
      Result := Result + Distance(Poly[I], Poly[(I + 1) mod Len]);
  end
  else begin
    for I := 0 to Len - 2 do
      Result := Result + Distance(Poly[I], Poly[(I + 1)]);
  end;
end;

function Perimeter(Segarcs: TSegarc2DArray): Float;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    if Segarcs[I].IsArc then
      Result := Result + Distance(Segarcs[I].Arc)
    else
      Result := Result + Distance(Segarcs[I].Seg);
  end;
end;




//-------------------------------------------------------------------------------------------------

function Centroid(X1,Y1, X2,Y2, X3,Y3: Float): TPoint2D;
begin
  Result := Intersection(
                            Point2D(X1, Y1),
                            MidPoint(X2,Y2, X3,Y3),
                            Point2D(X2, Y2),
                            MidPoint(X1,Y1, X3,Y3)
                           )[0];
end;

function Centroid(Pnt1, Pnt2, Pnt3: TPoint2D): TPoint2D;
begin
  Result := Centroid(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y,  Pnt3.X, Pnt3.Y);
end;


function Centroid(Rect: TRect2D): TPoint2D;
begin
  Result.X := (Rect.X1 + Rect.X2) * 0.5;
  Result.Y := (Rect.Y1 + Rect.Y2) * 0.5;
end;

function Centroid(Poly: TPoint2DArray): TPoint2D;
var
  L: Longint;
  I, J: Longint;
  Sum, Term: Float;
begin
  Result.X := 0.0;
  Result.Y := 0.0;

  L := System.Length(Poly);
  if L <= 0 then Exit;   //---->>>>

  if L = 1 then Result := Poly[0] else
  if L = 2 then Result := MidPoint(Poly[0], Poly[1])
  else begin
    Sum := 0.0;
    J := High(Poly);

    for I := Low(Poly) to High(Poly) do
    begin
      Term := ((Poly[J].X * Poly[I].Y) - (Poly[J].Y * Poly[I].X));
      Sum := Sum + Term;
      Result.X := Result.X + (Poly[J].X + Poly[I].X) * Term;
      Result.Y := Result.Y + (Poly[J].Y + Poly[I].Y) * Term;
      J := I;
    end;

    if NotEqual(Sum, 0.0) then
    begin
      Result.X := Result.X / (3.0 * Sum);
      Result.Y := Result.Y / (3.0 * Sum);
    end;
  end;
end;


function Center(Rect: TRect2D): TPoint2D;
begin
  Result := Centroid(Rect);
end;

function Center(Poly: TPoint2DArray): TPoint2D;
var
  I: Integer;
  L: Integer;
begin
  Result := Point2D(0, 0);

  L := System.Length(Poly);
  if L <= 1 then Exit;

  if IsEqual(Poly[L - 1], Poly[0]) then L := L - 1;
  if L <= 1 then Exit;

  for I := 0 to L - 1 do
  begin
    Result.X := Result.X + Poly[I].X;
    Result.Y := Result.Y + Poly[I].Y;
  end;

  Result.X := Result.X / L;
  Result.Y := Result.Y / L;
end;

function Center(Segarcs: TSegarc2DArray): TPoint2D;
begin
  Result := Center(SamplePoints(Segarcs));
end;




//-------------------------------------------------------------------------------------------------

function MidPoint(X1, Y1, X2, Y2: Float): TPoint2D;
begin
  Result.X := (X1 + X2) * 0.5;
  Result.Y := (Y1 + Y2) * 0.5;
end;

function MidPoint(Pnt1, Pnt2: TPoint2D): TPoint2D;
begin
  Result := MidPoint(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y);
end;

function MidPoint(Seg: TSegment2D): TPoint2D;
begin
  Result := MidPoint(Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y);
end;

function MidPoint(Arc: TArc2D): TPoint2D;
var
  A: Float;
begin
  A := FixAngle(Arc.Ang2 - Arc.Ang1);
  A := Arc.Ang1 + A / 2;
  Result := ShiftPoint(Arc.Cen, A, Arc.R);
end;

function MidPoint(Segarc: TSegarc2D): TPoint2D;
begin
  if Segarc.IsArc then
    Result := MidPoint(Segarc.Arc)
  else
    Result := MidPoint(Segarc.Seg);
end;




//-------------------------------------------------------------------------------------------------

function Incenter(X1, Y1, X2, Y2, X3, Y3: Float): TPoint2D;
var
  Perim:  Float;
  Side12: Float;
  Side23: Float;
  Side31: Float;
begin
  Side12 := Distance(X1, Y1, X2, Y2);
  Side23 := Distance(X2, Y2, X3, Y3);
  Side31 := Distance(X3, Y3, X1, Y1);

  Perim := 1 / (Side12 + Side23 + Side31);
  Result.X := (Side23 * X1 + Side31 * X2 + Side12 * X3) * Perim;
  Result.Y := (Side23 * Y1 + Side31 * Y2 + Side12 * Y3) * Perim;
end;

function Incenter(Pnt1, Pnt2, Pnt3: TPoint2D): TPoint2D;
begin
  Result := Incenter(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y);
end;



function Circumcenter(X1, Y1, X2, Y2, X3, Y3: Float): TPoint2D;
var
  A, C, B, D, E, F, G: Float;
begin
  Result.X := _ErrValue;
  Result.Y := _ErrValue;

  A := X2 - X1;
  B := Y2 - Y1;
  C := X3 - X1;
  D := Y3 - Y1;
  E := A * (X1 + X2) + B * (Y1 + Y2);
  F := C * (X1 + X3) + D * (Y1 + Y3);
  G := 2.0 * (A * (Y3 - Y2) - B * (X3 - X2));

  if IsEqual(G, 0.0) then Exit;   //---->>>>

  Result.X := (D * E - B * F) / G;
  Result.Y := (A * F - C * E) / G;
end;

function Circumcenter(Pnt1, Pnt2, Pnt3: TPoint2D): TPoint2D;
begin
  Result := Circumcenter(Pnt1.X, Pnt1.Y, Pnt2.X, Pnt2.Y, Pnt3.X, Pnt3.Y);
end;







//-------------------------------------------------------------------------------------------------

function Rotate(RotAng: Float; X, Y: Float): TPoint2D;
var
  SinVal: Float;
  CosVal: Float;
begin
  SinVal := SinD(RotAng);
  CosVal := CosD(RotAng);
  Result.X := X * CosVal - Y * SinVal;
  Result.Y := X * SinVal + Y * CosVal;
end;

function Rotate(RotAng: Float; Pnt: TPoint2D): TPoint2D;
begin
  if IsEqual(RotAng, 0.0) then
  begin
    Result := Pnt;
    Exit; //======>>>>>
  end;

  Result := Rotate(RotAng, Pnt.X, Pnt.Y);
end;

function Rotate(RotAng: Float; Ln: TLine2D): TLine2D;
begin
  if IsEqual(RotAng, 0.0) then
  begin
    Result := Ln;
    Exit; //======>>>>>
  end;

  Result.P1 := Rotate(RotAng, Ln.P1);
  Result.P2 := Rotate(RotAng, Ln.P2);
end;

function Rotate(RotAng: Float; Seg: TSegment2D): TSegment2D;
begin
  if IsEqual(RotAng, 0.0) then
  begin
    Result := Seg;
    Exit; //======>>>>>
  end;

  Result.P1 := Rotate(RotAng, Seg.P1);
  Result.P2 := Rotate(RotAng, Seg.P2);
end;

function Rotate(RotAng: Float; Poly: TPoint2DArray): TPoint2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Poly));
  for I := Low(Poly) to High(Poly) do Result[I] := Rotate(RotAng, Poly[I]);
end;

function Rotate(RotAng: Float; Cir: TCircle2D): TCircle2D;
begin
  if IsEqual(RotAng, 0.0) then
  begin
    Result := Cir;
    Exit; //======>>>>>
  end;

  Result.R := Cir.R;
  Result.Cen := Rotate(RotAng, Cir.Cen);
end;

function Rotate(RotAng: Float; Arc: TArc2D): TArc2D;
var
  P1, P2: TPoint2D;
begin
  if Arc.R <= 0.0 then
  begin
    Result := Arc;
    Exit; //====>>>>
  end;

  if IsEqual(RotAng, 0.0) then
  begin
    Result := Arc;
    Exit; //======>>>>>
  end;

  Result.R := Arc.R;
  Result.Cen := Rotate(RotAng, Arc.Cen);

  if NotEqual(Arc.Ang1, 0.0) or NotEqual(Arc.Ang2, 360.0) then
  begin
    P1 := Rotate(Arc.Cen, RotAng, GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1));
    P2 := Rotate(Arc.Cen, RotAng, GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2));
    Result.Ang1 := GetAngle(Arc.Cen, P1);
    Result.Ang2 := GetAngle(Arc.Cen, P2);
  end
  else begin
    Result.Ang1 := Arc.Ang1;
    Result.Ang2 := Arc.Ang2;
  end;

  Result.IsCW := Arc.IsCW;
  Result.Kind := Arc.Kind;
end;

function Rotate(RotAng: Float; Ell: TEllipse2D): TEllipse2D;
var
  P1, P2: TPoint2D;
begin
  if IsEqual(RotAng, 0.0) then
  begin
    Result := Ell;
    Exit; //======>>>>>
  end;

  Result.Rx := Ell.Rx;
  Result.Ry := Ell.Ry;
  Result.Rot := FixAngle(Ell.Rot + RotAng);
  Result.Cen := Rotate(RotAng, Ell.Cen);
  Result.Kind := Ell.Kind;
  Result.IsCW := Ell.IsCW;

  if NotEqual(Ell.Ang1, 0.0) or NotEqual(Ell.Ang2, 360.0) then
  begin
    P1 := Rotate(Ell.Cen, RotAng, GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang1));
    P2 := Rotate(Ell.Cen, RotAng, GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang2));

    Result.Ang1 := UdGeo2D.CenAngToEllAng(Ell.Rx, Ell.Ry, FixAngle(GetAngle(Ell.Cen, P1) - Result.Rot) );
    Result.Ang2 := UdGeo2D.CenAngToEllAng(Ell.Rx, Ell.Ry, FixAngle(GetAngle(Ell.Cen, P2) - Result.Rot) );
  end
  else begin
    Result.Ang1 := Ell.Ang1;
    Result.Ang2 := Ell.Ang2;
  end;
end;

function Rotate(RotAng: Float; Segarc: TSegarc2D): TSegarc2D;
begin
  if IsEqual(RotAng, 0.0) then
  begin
    Result := Segarc;
    Exit; //======>>>>>
  end;

  Result.Seg := Rotate(RotAng, Segarc.Seg);
  Result.Arc := Rotate(RotAng, Segarc.Arc);
  Result.IsArc := Segarc.IsArc;
end;

function Rotate(RotAng: Float; Segarcs: TSegarc2DArray): TSegarc2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Segarcs));
  for I := Low(Segarcs) to High(Segarcs) do Result[I] := Rotate(RotAng, Segarcs[I]);
end;




function Rotate(Base: TPoint2D; RotAng: Float; X, Y: Float): TPoint2D;
begin
  Result := Rotate(RotAng, X - Base.X, Y - Base.Y);
  Result.X := Result.X + Base.X;
  Result.Y := Result.Y + Base.Y;
end;

function Rotate(Base: TPoint2D; RotAng: Float; Pnt: TPoint2D): TPoint2D;
begin
  if IsEqual(RotAng, 0.0) and IsEqual(Base.X, 0.0) and IsEqual(Base.Y, 0.0) then
  begin
    Result := Pnt;
    Exit; //======>>>>>
  end;

  Result := Rotate(Base, RotAng, Pnt.X, Pnt.Y);
end;

function Rotate(Base: TPoint2D; RotAng: Float; Ln: TLine2D): TLine2D;
begin
  if IsEqual(RotAng, 0.0) and IsEqual(Base.X, 0.0) and IsEqual(Base.Y, 0.0) then
  begin
    Result := Ln;
    Exit; //======>>>>>
  end;

  Result.P1 := Rotate(Base, RotAng, Ln.P1);
  Result.P2 := Rotate(Base, RotAng, Ln.P2);
end;

function Rotate(Base: TPoint2D; RotAng: Float; Seg: TSegment2D): TSegment2D;
begin
  if IsEqual(RotAng, 0.0) and IsEqual(Base.X, 0.0) and IsEqual(Base.Y, 0.0) then
  begin
    Result := Seg;
    Exit; //======>>>>>
  end;

  Result.P1 := Rotate(Base, RotAng, Seg.P1);
  Result.P2 := Rotate(Base, RotAng, Seg.P2);
end;

function Rotate(Base: TPoint2D; RotAng: Float; Poly: TPoint2DArray): TPoint2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Poly));
  for I := Low(Poly) to High(Poly) do Result[I] := Rotate(Base, RotAng, Poly[I]);
end;

function Rotate(Base: TPoint2D; RotAng: Float; Cir: TCircle2D): TCircle2D;
begin
  if IsEqual(RotAng, 0.0) and IsEqual(Base.X, 0.0) and IsEqual(Base.Y, 0.0) then
  begin
    Result := Cir;
    Exit; //======>>>>>
  end;

  Result.R := Cir.R;
  Result.Cen := Rotate(Base, RotAng, Cir.Cen);
end;

function Rotate(Base: TPoint2D; RotAng: Float; Arc: TArc2D): TArc2D;
var
  P1, P2: TPoint2D;
begin
  if Arc.R <= 0.0 then
  begin
    Result := Arc;
    Exit; //====>>>>
  end;

  if IsEqual(RotAng, 0.0) and IsEqual(Base.X, 0.0) and IsEqual(Base.Y, 0.0) then
  begin
    Result := Arc;
    Exit; //======>>>>>
  end;

  Result.R := Arc.R;
  Result.Cen := Rotate(Base, RotAng, Arc.Cen);

  if NotEqual(Arc.Ang1, 0.0) or NotEqual(Arc.Ang2, 360.0) then
  begin
    P1 := Rotate(Arc.Cen, RotAng, GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1));
    P2 := Rotate(Arc.Cen, RotAng, GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2));
    Result.Ang1 := GetAngle(Arc.Cen, P1);
    Result.Ang2 := GetAngle(Arc.Cen, P2);
  end
  else begin
    Result.Ang1 := Arc.Ang1;
    Result.Ang2 := Arc.Ang2;
  end;

  Result.IsCW := Arc.IsCW;
  Result.Kind := Arc.Kind;
end;

function Rotate(Base: TPoint2D; RotAng: Float; Ell: TEllipse2D): TEllipse2D;
var
  P1, P2: TPoint2D;
begin
  if IsEqual(RotAng, 0.0) and IsEqual(Base.X, 0.0) and IsEqual(Base.Y, 0.0) then
  begin
    Result := Ell;
    Exit; //======>>>>>
  end;

  Result.Rx := Ell.Rx;
  Result.Ry := Ell.Ry;
  Result.Rot := FixAngle(Ell.Rot + RotAng);
  Result.Cen := Rotate(Base, RotAng, Ell.Cen);
  Result.IsCW := Ell.IsCW;
  Result.Kind := Ell.Kind;

  if NotEqual(Ell.Ang1, 0.0) or NotEqual(Ell.Ang2, 360.0) then
  begin
    P1 := Rotate(Ell.Cen, RotAng, GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang1));
    P2 := Rotate(Ell.Cen, RotAng, GetEllipsePoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ell.Ang2));

    Result.Ang1 := UdGeo2D.CenAngToEllAng(Ell.Rx, Ell.Ry, FixAngle(GetAngle(Ell.Cen, P1) - Result.Rot) );
    Result.Ang2 := UdGeo2D.CenAngToEllAng(Ell.Rx, Ell.Ry, FixAngle(GetAngle(Ell.Cen, P2) - Result.Rot) );
  end
  else begin
    Result.Ang1 := Ell.Ang1;
    Result.Ang2 := Ell.Ang2;
  end;
end;

function Rotate(Base: TPoint2D; RotAng: Float; Segarc: TSegarc2D): TSegarc2D;
begin
  if IsEqual(RotAng, 0.0) and IsEqual(Base.X, 0.0) and IsEqual(Base.Y, 0.0) then
  begin
    Result := Segarc;
    Exit; //======>>>>>
  end;

  Result.Arc := Rotate(Base, RotAng, Segarc.Arc);
  Result.Seg := Rotate(Base, RotAng, Segarc.Seg);
  Result.IsArc := Segarc.IsArc;
end;

function Rotate(Base: TPoint2D; RotAng: Float; Segarcs: TSegarc2DArray): TSegarc2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Segarcs));
  for I := Low(Segarcs) to High(Segarcs) do Result[I] := Rotate(Base, RotAng, Segarcs[I]);
end;





//-------------------------------------------------------------------------------------------------

function Translate(Dx, Dy: Float; Pnt: TPoint2D): TPoint2D;
begin
  Result.X := Pnt.X + Dx;
  Result.Y := Pnt.Y + Dy;
end;

function Translate(Dx, Dy: Float; Ln: TLine2D): TLine2D;
begin
  Result.P1.X := Ln.P1.X + Dx;
  Result.P1.Y := Ln.P1.Y + Dy;
  Result.P2.X := Ln.P2.X + Dx;
  Result.P2.Y := Ln.P2.Y + Dy;
end;

function Translate(Dx, Dy: Float; Seg: TSegment2D): TSegment2D;
begin
  Result.P1.X := Seg.P1.X + Dx;
  Result.P1.Y := Seg.P1.Y + Dy;
  Result.P2.X := Seg.P2.X + Dx;
  Result.P2.Y := Seg.P2.Y + Dy;
end;

function Translate(Dx, Dy: Float; Rect: TRect2D): TRect2D;
begin
  Result.X1 := Rect.X1 + Dx;
  Result.Y1 := Rect.Y1 + Dy;
  Result.X2 := Rect.X2 + Dx;
  Result.Y2 := Rect.Y2 + Dy;
end;

function Translate(Dx, Dy: Float; Cir: TCircle2D): TCircle2D;
begin
  Result := Cir;
  Result.Cen.X := Cir.Cen.X + Dx;
  Result.Cen.Y := Cir.Cen.Y + Dy;
end;

function Translate(Dx, Dy: Float; Arc: TArc2D): TArc2D;
begin
  Result := Arc;
  if Arc.R <= 0.0 then Exit; //====>>>>

  Result.Cen.X := Arc.Cen.X + Dx;
  Result.Cen.Y := Arc.Cen.Y + Dy;
end;

function Translate(Dx, Dy: Float; Ell: TEllipse2D): TEllipse2D;
begin
  Result := Ell;
  Result.Cen.X := Ell.Cen.X + Dx;
  Result.Cen.Y := Ell.Cen.Y + Dy;
end;

function Translate(Dx, Dy: Float; Poly: TPoint2DArray): TPoint2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Poly));
  for I := Low(Poly) to High(Poly) do
  begin
    Result[I].X := Poly[I].X + Dx;
    Result[I].Y := Poly[I].Y + Dy;
  end;
end;

function Translate(Dx, Dy: Float; Segarc: TSegarc2D): TSegarc2D;
begin
  Result.Arc := Translate(Dx, Dy, Segarc.Arc);
  Result.Seg := Translate(Dx, Dy, Segarc.Seg);
  Result.IsArc := Segarc.IsArc;
end;

function Translate(Dx, Dy: Float; Segarcs: TSegarc2DArray): TSegarc2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Segarcs));
  for I := Low(Segarcs) to High(Segarcs) do
    Result[I] := Translate(Dx, Dy, Segarcs[I]);
end;

function Translate(Dx, Dy: Float; Vertexes: TVertexes2D): TVertexes2D;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Vertexes));
  for I := Low(Vertexes) to High(Vertexes) do
    Result[I].Point := Translate(Dx, Dy, Vertexes[I].Point);
end;  


//-------------------------------------------------------------------------------------------------

function Scale(Sx, Sy: Float; Pnt: TPoint2D): TPoint2D;
begin
  Result.X := Pnt.X * Sx;
  Result.Y := Pnt.Y * Sy;
end;

function Scale(Sx, Sy: Float; Ln: TLine2D): TLine2D;
begin
  Result.P1.X := Ln.P1.X * Sx;
  Result.P1.Y := Ln.P1.Y * Sy;
  Result.P2.X := Ln.P2.X * Sx;
  Result.P2.Y := Ln.P2.Y * Sy;
end;

function Scale(Sx, Sy: Float; Seg: TSegment2D): TSegment2D;
begin
  Result.P1.X := Seg.P1.X * Sx;
  Result.P1.Y := Seg.P1.Y * Sy;
  Result.P2.X := Seg.P2.X * Sx;
  Result.P2.Y := Seg.P2.Y * Sy;
end;

function Scale(Sx, Sy: Float; Rect: TRect2D): TRect2D;
begin
  Result.X1 := Rect.X1 * Sx;
  Result.Y1 := Rect.Y1 * Sy;
  Result.X2 := Rect.X2 * Sx;
  Result.Y2 := Rect.Y2 * Sy;
end;

function Scale(Sr: Float; Cir: TCircle2D): TCircle2D;
begin
  Result := Cir;
  Result.R := Cir.R * Sr;
end;

function Scale(Sr: Float; Arc: TArc2D): TArc2D;
begin
  Result := Arc;
  if Arc.R <= 0.0 then Exit; //====>>>>

  Result.R := Arc.R * Sr;
end;

function Scale(Sx, Sy: Float; Cir: TCircle2D): TEllipse2D;
begin
  Result.Cen  := Cir.Cen;
  Result.Rx   := Cir.R * Sx;
  Result.Ry   := Cir.R * Sy;
  Result.Ang1 := 0.0;
  Result.Ang2 := 360.0;
  Result.Rot  := 0.0;
  Result.IsCW := False;
  Result.Kind := akCurve;
end;

function Scale(Sx, Sy: Float; Arc: TArc2D): TEllipse2D;
begin
//  Result := Arc;
//  if Arc.R <= 0.0 then Exit; //====>>>>

  Result.Cen  := Arc.Cen;
  Result.Rx   := Arc.R * Sx;
  Result.Ry   := Arc.R * Sy;
  Result.Ang1 := Arc.Ang1;
  Result.Ang2 := Arc.Ang2;
  Result.Rot  := 0.0;
  Result.IsCW := Arc.IsCW;
  Result.Kind := Arc.Kind;
end;

function Scale(Sx, Sy: Float; Ell: TEllipse2D): TEllipse2D;
begin
  Result.Cen  := Ell.Cen;
  Result.Rx   := Ell.Rx * Sx;
  Result.Ry   := Ell.Ry * Sy;
  Result.Ang1 := Ell.Ang1;
  Result.Ang2 := Ell.Ang2;
  Result.Rot  := Ell.Rot;
  Result.IsCW := Ell.IsCW;
  Result.Kind := Ell.Kind;
end;

function Scale(Sx, Sy: Float; Poly: TPoint2DArray): TPoint2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Poly));
  for I := Low(Poly) to High(Poly) do
  begin
    Result[I].X := Poly[I].X * Sx;
    Result[I].Y := Poly[I].Y * Sy;
  end;
end;






function Scale(Base: TPoint2D; Sx, Sy: Float; Pnt: TPoint2D): TPoint2D;
begin
  Result.X := Base.X + (Pnt.X - Base.X) * Sx;
  Result.Y := Base.Y + (Pnt.Y - Base.Y) * Sy;
end;

function Scale(Base: TPoint2D; Sx, Sy: Float; Ln: TLine2D): TLine2D;
begin
  Result.P1.X := Base.X + (Ln.P1.X - Base.X) * Sx;
  Result.P1.Y := Base.Y + (Ln.P1.Y - Base.Y) * Sy;
  Result.P2.X := Base.X + (Ln.P2.X - Base.X) * Sx;
  Result.P2.Y := Base.Y + (Ln.P2.Y - Base.Y) * Sy;
end;

function Scale(Base: TPoint2D; Sx, Sy: Float; Seg: TSegment2D): TSegment2D;
begin
  Result.P1.X := Base.X + (Seg.P1.X - Base.X) * Sx;
  Result.P1.Y := Base.Y + (Seg.P1.Y - Base.Y) * Sy;
  Result.P2.X := Base.X + (Seg.P2.X - Base.X) * Sx;
  Result.P2.Y := Base.Y + (Seg.P2.Y - Base.Y) * Sy;
end;

function Scale(Base: TPoint2D; Sx, Sy: Float; Rect: TRect2D): TRect2D;
begin
  Result.X1 := Base.X + (Rect.X1 - Base.X) * Sx;
  Result.Y1 := Base.Y + (Rect.Y1 - Base.Y) * Sy;
  Result.X2 := Base.X + (Rect.X2 - Base.X) * Sx;
  Result.Y2 := Base.Y + (Rect.Y2 - Base.Y) * Sy;
end;

function Scale(Base: TPoint2D; Sr: Float; Cir: TCircle2D): TCircle2D;
begin
  Result := Cir;
  Result.R := Cir.R * Sr;
  Result.Cen := Scale(Base, Sr, Sr, Cir.Cen);
end;

function Scale(Base: TPoint2D; Sr: Float; Arc: TArc2D): TArc2D;
begin
  Result := Arc;
  if Arc.R <= 0.0 then Exit; //====>>>>

  Result.R := Arc.R * Sr;
  Result.Cen := Scale(Base, Sr, Sr, Arc.Cen);
end;

function Scale(Base: TPoint2D; Sx, Sy: Float; Cir: TCircle2D): TEllipse2D;
begin
  Result.Cen := Scale(Base, Sx, Sy, Cir.Cen);
  Result.Rx   := Cir.R * Sx;
  Result.Ry   := Cir.R * Sy;
  Result.Ang1 := 0.0;
  Result.Ang2 := 360.0;
  Result.Rot  := 0.0;
  Result.IsCW := False;
  Result.Kind := akCurve;
end;

function Scale(Base: TPoint2D; Sx, Sy: Float; Arc: TArc2D): TEllipse2D;
begin
  Result.Cen  := Scale(Base, Sx, Sy, Arc.Cen);
  Result.Rx   := Arc.R * Sx;
  Result.Ry   := Arc.R * Sy;
  Result.Ang1 := Arc.Ang1;
  Result.Ang2 := Arc.Ang2;
  Result.Rot  := 0.0;
  Result.IsCW := Arc.IsCW;
  Result.Kind := Arc.Kind;

//  if Sx < 0 then Result := Mirror(Line2D(Result.Cen, ShiftPoint(Result.Cen, Result.Rot + 90, 100)), Result);
//  if Sy < 0 then Result := Mirror(Line2D(Result.Cen, ShiftPoint(Result.Cen, Result.Rot, 100)), Result);
end;

function Scale(Base: TPoint2D; Sx, Sy: Float; Ell: TEllipse2D): TEllipse2D;
begin
  Result.Cen  := Scale(Base, Sx, Sy, Ell.Cen);
  Result.Rx   := Ell.Rx * Sx;
  Result.Ry   := Ell.Ry * Sy;
  Result.Ang1 := Ell.Ang1;
  Result.Ang2 := Ell.Ang2;
  Result.Rot  := Ell.Rot;
  Result.IsCW := Ell.IsCW;
  Result.Kind := Ell.Kind;

//  if Sx < 0 then Result := Mirror(Line2D(Base, ShiftPoint(Base, 90, 100)), Result);
//  if Sy < 0 then Result := Mirror(Line2D(Base, ShiftPoint(Base, 0,  100)), Result);
end;

function Scale(Base: TPoint2D; Sx, Sy: Float; Poly: TPoint2DArray): TPoint2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Poly));
  for I := Low(Poly) to High(Poly) do
  begin
    Result[I].X := Base.X + (Poly[I].X - Base.X) * Sx;
    Result[I].Y := Base.Y + (Poly[I].Y - Base.Y) * Sy;
  end;
end;




function Scale(S: Float; Segarc: TSegarc2D): TSegarc2D;
begin
  Result.Arc := Scale(S, Segarc.Arc);
  Result.Seg := Scale(S, S, Segarc.Seg);
  Result.IsArc := Segarc.IsArc;
end;

function Scale(S: Float; Segarc: TSegarc2D; Base: TPoint2D): TSegarc2D;
begin
  Result.Arc := Scale(Base, S, Segarc.Arc);
  Result.Seg := Scale(Base, S, S, Segarc.Seg);
  Result.IsArc := Segarc.IsArc;
end;

function Scale(S: Float; Segarcs: TSegarc2DArray): TSegarc2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Segarcs));
  for I := Low(Segarcs) to High(Segarcs) do
    Result[I] := Scale(S, Segarcs[I]);
end;

function Scale(Base: TPoint2D; S: Float; Segarcs: TSegarc2DArray): TSegarc2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Segarcs));
  for I := Low(Segarcs) to High(Segarcs) do
    Result[I] := Scale(S, Segarcs[I], Base);
end;



//-------------------------------------------------------------------------------------------------

function Mirror(MrLn: TLineK; X, Y: Float): TPoint2D;
var
  Dis: Float;
  Eq: TEqResult;
  LopLn: TLineK;
  InctPnts: TPoint2DArray;
begin
  InctPnts := nil;

  if not MrLn.HasK then
  begin
    Result.X := 2 * MrLn.B - X;
    Result.Y := Y;
  end
  else if IsEqual(MrLn.K, 0) then
  begin
    Result.X := X;
    Result.Y := 2 * MrLn.B - Y;
  end
  else begin
    Dis := DistanceToLine(X, Y, MrLn);
    if IsEqual(Dis, 0.0) then
    begin
      Result.X := X;
      Result.Y := Y;
      Exit;   //---->>>>
    end;

    LopLn := LineK(-(1/MrLn.K), Y + (1/MrLn.K)*X , True);

    InctPnts := Intersection(MrLn, LopLn);
    if System.Length(InctPnts) <> 1 then Exit;   //---->>>>


    Eq := Equation(
                   (1 + Sqr(LopLn.K)),
                   (2 * LopLn.B * LopLn.K - 2 * X - 2 * LopLn.K * Y),
                   (Sqr(X) + Sqr(Y) + Sqr(LopLn.B) - 2 * LopLn.B * Y - 4 * Sqr(Dis))
                  );


    if Eq.L = 2 then
    begin
      if X < InctPnts[0].X then
        Result.X := Max(Eq.X[0], Eq.X[1])
      else
        Result.X := Min(Eq.X[0], Eq.X[1]);

      Result.Y := LopLn.K * Result.X + LopLn.B;
    end
    else if Eq.L = 1 then
    begin
      Result.X := X;
      Result.Y := Y;
    end;
  end;
end;

function Mirror(MrLn: TLineK; Pnt: TPoint2D): TPoint2D;
begin
  Result := Mirror(MrLn, Pnt.X, Pnt.Y);
end;



//---------------------------------------------------------------------

function Mirror(MrLn: TLine2D; X, Y: Float): TPoint2D;
begin
  Result := ClosestLinePoint(Point2D(X, Y), MrLn);
  Result.X := X + 2 * (Result.X - X);
  Result.Y := Y + 2 * (Result.Y - Y);
end;

function Mirror(MrLn: TLine2D; Pnt: TPoint2D): TPoint2D;
begin
  Result := Mirror(MrLn, Pnt.X, Pnt.Y);
end;

function Mirror(MrLn: TLine2D; Seg: TSegment2D): TSegment2D;
begin
  Result.P1 := Mirror(MrLn, Seg.P1);
  Result.P2 := Mirror(MrLn, Seg.P2);
end;

function Mirror(MrLn: TLine2D; Rect: TRect2D): TRect2D;
begin
  Result.P1 := Mirror(MrLn, Rect.P1);
  Result.P2 := Mirror(MrLn, Rect.P2);
end;

function Mirror(MrLn: TLine2D; Cir: TCircle2D): TCircle2D;
begin
  Result.R := Cir.R;
  Result.Cen := Mirror(MrLn, Cir.Cen);
end;

function Mirror(MrLn: TLine2D; Arc: TArc2D): TArc2D;
var
  P1, P2: TPoint2D;
begin
  Result.R := Arc.R;
  Result.Cen := Mirror(MrLn, Arc.Cen);

  if NotEqual(Arc.Ang1, 0.0) or NotEqual(Arc.Ang2, 360.0) then
  begin
    P1 := Mirror(MrLn, GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1) );
    P2 := Mirror(MrLn, GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2) );

    Result.Ang1 := GetAngle(Result.Cen, P2);
    Result.Ang2 := GetAngle(Result.Cen, P1);
  end
  else begin
    Result.Ang1 := Arc.Ang1;
    Result.Ang2 := Arc.Ang2;
  end;
  Result.Kind := Arc.Kind;
end;

function Mirror(MrLn: TLine2D; Ell: TEllipse2D): TEllipse2D;
var
  LAng: Float;
  LRotSeg: TSegment2D;
begin
  Result.Rx := Ell.Rx;
  Result.Ry := Ell.Ry;
  Result.Ang1 := Ell.Ang1;
  Result.Ang2 := Ell.Ang2;
  Result.Rot := Ell.Rot;
  Result.Cen := Mirror(MrLn, Ell.Cen);
  Result.Kind := Ell.Kind;

  LRotSeg := Segment2D(Ell.Cen, ShiftPoint(Ell.Cen, Ell.Rot, 100));
  LRotSeg := UdGeo2D.Mirror(MrLn, LRotSeg);

  if NotEqual(Ell.Ang1, 0.0) or NotEqual(Ell.Ang2, 360.0) then
  begin
    LAng := GetAngle(MrLn.P1, MrLn.P2);

    if ((LAng > 45) and (LAng < 135)) or ((LAng > 225) and (LAng < 315)) then
    begin
      Result.Rx := -Result.Rx;
      Result.Rot := GetAngle(LRotSeg.P2, LRotSeg.P1);
    end
    else begin
      Result.Ry := -Result.Ry;
      Result.Rot := GetAngle(LRotSeg.P1, LRotSeg.P2);
    end;
  end
  else begin
    Result.Ang1 := Ell.Ang1;
    Result.Ang2 := Ell.Ang2;
  end;
end;

function Mirror(MrLn: TLine2D; Poly: TPoint2DArray): TPoint2DArray;
var
  I: Integer;
begin
  System.SetLength(Result, System.Length(Poly));
  for I := Low(Poly) to High(Poly) do Result[I] := Mirror(MrLn, Poly[I]);
end;

function Mirror(MrLn: TLine2D; Segarc: TSegarc2D): TSegarc2D;
begin
  Result.Arc := Mirror(MrLn, Segarc.Arc );
  Result.Seg := Mirror(MrLn, Segarc.Seg );
  Result.IsArc := Segarc.IsArc;
end;

function Mirror(MrLn: TLine2D; Segarcs: TSegarc2DArray): TSegarc2DArray;
var
  I: Longint;
begin
  System.SetLength(Result, System.Length(Segarcs));
  for I := Low(Segarcs) to High(Segarcs) do
  begin
    Result[I] := Mirror(MrLn, Segarcs[I]);
  end;
end;







//-------------------------------------------------------------------------------------------------

function ClosestLinePoint(Px, Py: Float; Ln: TLineK): TPoint2D;
var
  K2, B2: Double;
begin
  if not Ln.HasK then
  begin
    Result.X := Ln.B;
    Result.Y := Py;
  end
  else if IsEqual(Ln.K, 0.0) then
  begin
    Result.X := Px;
    Result.Y := Ln.B;
  end
  else begin
    {
    LopLn := LineK(-(1/Ln.K), Py + (1/Ln.K)*Px , True);

    Result.X := (Ln.B - LopLn.B) / (LopLn.K - Ln.K);
    Result.Y := Ln.K * Result.X + Ln.B;
    }
    K2 := -1 / Ln.K;
    B2 := Py - K2 * Px;

    Result.X := (Ln.B - B2) / (K2 - Ln.K);
    Result.Y := Ln.K * Result.X + Ln.B;
  end;
end;

function ClosestLinePoint(Pnt: TPoint2D; Ln: TLineK): TPoint2D;
begin
  Result := ClosestLinePoint(Pnt.X, Pnt.Y, Ln);
end;



function ClosestLinePoint(Px, Py: Float; X1, Y1, X2, Y2: Float): TPoint2D;
var
  Ratio: Float;
  K1, K2, B1, B2: Float;
begin
  if IsEqual(Y1, Y2) then
  begin
    Result.X := Px;
    Result.Y := Y1;
  end
  else if IsEqual(X1, X2) then
  begin
    Result.X := X1;
    Result.Y := Py;
  end
  else begin
    K1 := (Y2 - Y1) / (X2 - X1);
    B1 := Y1 - K1 * X1;

    K2 := -1 / K1;
    B2 := Py - (K2 * Px);

    Ratio := (B2 - B1) / (K1 - K2);
    Result.X  := Ratio;
    Result.Y  := (K2 * Ratio) + B2;
  end;
end;

function ClosestSegmentPoint(Px, Py: Float; X1, Y1, X2, Y2: Float; out Idx: Integer): TPoint2D;
var
  Ratio: Float;
  Dx, Dy: Float;
begin
  Idx := 0;

  if IsEqual(X1, X2) and IsEqual(Y1, Y2) then
  begin
    Result := Point2D(X1, Y1);
    Exit;
  end;

  Dx := X2 - X1;
  Dy := Y2 - Y1;

  Ratio := ((Px - X1) * Dx + (Py - Y1) * Dy) / (Dx * Dx + Dy * Dy);

  if Ratio < 0.0 then
  begin
    Idx := 1;
    Result.X := X1;
    Result.Y := Y1;
  end
  else if Ratio > 1.0 then
  begin
    Idx := 2;
    Result.X := X2;
    Result.Y := Y2;
  end
  else
  begin
    Result.X := X1 + (Ratio * Dx);
    Result.Y := Y1 + (Ratio * Dy);
  end;
end;

function ClosestLinePoint(Pnt: TPoint2D; Ln: TLine2D): TPoint2D;
begin
  Result := ClosestLinePoint(Pnt.X, Pnt.Y, Ln.P1.X, Ln.P1.Y, Ln.P2.X, Ln.P2.Y);
end;

function ClosestSegmentPoint(Pnt: TPoint2D; Seg: TSegment2D; out Idx: Integer): TPoint2D;
begin
  Result := ClosestSegmentPoint(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Idx);
end;


function ClosestSegmentPoint(Px, Py: Float; X1, Y1, X2, Y2: Float): TPoint2D;
var
  Idx: Integer;
begin
  Result := ClosestSegmentPoint(Px, Py, X1, Y1, X2, Y2, Idx);
end;

function ClosestSegmentPoint(Pnt: TPoint2D; Seg: TSegment2D): TPoint2D;
var
  Idx: Integer;
begin
  Result := ClosestSegmentPoint(Pnt.X, Pnt.Y, Seg.P1.X, Seg.P1.Y, Seg.P2.X, Seg.P2.Y, Idx);
end;


function ClosestRectPoint(Px,Py, X1,Y1, X2,Y2: Float): TPoint2D;
begin
  if (Px < Min(X1, X2)) then
    Result.X := Min(X1, X2)
  else if (Px > Max(X1, X2)) then
    Result.X := Max(X1, X2)
  else
    Result.X := Px;

  if (Py < Min(Y1, Y2)) then
    Result.Y := Min(Y1, Y2)
  else if (Py > Max(Y1, Y2)) then
    Result.Y := Max(Y1, Y2)
  else
    Result.Y := Py;
end;

function ClosestRectPoint(Pnt:TPoint2D; Rect: TRect2D):TPoint2D;
begin
  Result := Pnt;

  if Pnt.X <= Rect.X1 then Result.X := Rect.X1
  else if Pnt.X >= Rect.X2 then Result.X := Rect.X2;

  if Pnt.Y <= Rect.Y1 then Result.Y := Rect.Y1
  else if Pnt.Y >= Rect.Y2 then Result.Y := Rect.Y2;
end;

function ClosestCirclePoint(Pnt:TPoint2D; Cir: TCircle2D): TPoint2D;
var
  Ratio: Float;
  Dx, Dy: Float;
begin
  Dx := Pnt.X - Cir.Cen.X;
  Dy := Pnt.Y - Cir.Cen.Y;
  Ratio := Cir.R / Sqrt(Dx * Dx + Dy * Dy);
  Result.X := Cir.Cen.X + Ratio * Dx;
  Result.Y := Cir.Cen.Y + Ratio * Dy;
end;

function ClosestArcPoint(Pnt:TPoint2D; Arc: TArc2D): TPoint2D;
var
  P1, P2: TPoint2D;
begin
  Result := ClosestCirclePoint(Pnt, Circle2D(Arc.Cen, Arc.R));
  if not IsInAngles(GetAngle(Arc.Cen, Result), Arc.Ang1, Arc.Ang2) then
  begin
    P1 := ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R);
    P2 := ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R);
    if LayDistance(P1, Pnt) < LayDistance(P2, Pnt) then Result := P1 else Result := P2;
  end;
end;

function ClosestEllipsePoint(Pnt:TPoint2D; Ell: TEllipse2D): TPoint2D;
var
  Ln: TLine2D;
  LPnts: TPoint2DArray;
begin
  Result := InvalidPoint();

  Ln := Line2D(Pnt, Ell.Cen);
  LPnts := TUdInct2D.Intersection(Ln, Ell);
  if System.Length(LPnts) >= 1 then
  begin
    Result := LPnts[0];

    if System.Length(LPnts) = 2 then
      if LayDistance(LPnts[0], Pnt) > LayDistance(LPnts[1], Pnt) then Result := LPnts[1];
  end;
end;


function ClosestPointsPoint(Pnt:TPoint2D; Poly: TPoint2DArray; out Idx: Integer): TPoint2D;
var
  I: Integer;
  AP, MP: TPoint2D;
  AD, MD: Float;
  ASeg: TSegment2D;
begin
  MD := _ErrValue;
  MP := InvalidPoint();

  for I := Low(Poly) to High(Poly) - 1 do
  begin
    ASeg := Segment2D(Poly[I], Poly[I + 1]);
    AP := ClosestSegmentPoint(Pnt, ASeg);
    AD := LayDistance(AP, Pnt);

    if (I = 0) or (AD <= MD) then
    begin
      MP := AP;
      MD := AD;
      Idx := I;
    end;
  end;

  Result := MP;
end;

function ClosestPointsPoint(Pnt:TPoint2D; Poly: TPoint2DArray): TPoint2D;
var
  N: Integer;
begin
  Result := ClosestPointsPoint(Pnt, Poly, N);
end;


function ClosestSegarcPoint(Pnt: TPoint2D; Segarc: TSegarc2D): TPoint2D;
begin
  if Segarc.IsArc then
    Result := ClosestArcPoint(Pnt, Segarc.Arc)
  else
    Result := ClosestSegmentPoint(Pnt, Segarc.Seg);
end;

function ClosestSegarcsPoint(Pnt: TPoint2D; Segarcs: TSegarc2DArray; out Idx: Integer): TPoint2D;
var
  I: Integer;
  AP, MP: TPoint2D;
  AD, MD: Float;
begin
  MD := _ErrValue;
  MP := InvalidPoint();

  for I := Low(Segarcs) to High(Segarcs) do
  begin
    AP := ClosestSegarcPoint(Pnt, Segarcs[I]);
    AD := LayDistance(AP, Pnt);

    if (I = 0) or (AD <= MD) then
    begin
      MP := AP;
      MD := AD;
      Idx := I;
    end;
  end;

  Result := MP;
end;

function ClosestSegarcsPoint(Pnt: TPoint2D; Segarcs: TSegarc2DArray): TPoint2D;
var
  LIndex: Integer;
begin
  Result := ClosestSegarcsPoint(Pnt, Segarcs, LIndex);
end;



//------------------------------------------------------------------------------------------

function PerpendBisector(X1, Y1, X2, Y2: Float): TLineK;
var
  Ln: TLineK;
  //Pnt: TPoint2D;
begin
  with Ln do
  begin
    if IsEqual(Y2, Y1) then
    begin
      HasK := False;
      B := (X1 + X2) / 2;
    end
    else if IsEqual(X2, X1) then
    begin
      HasK := True;
      B := (Y1 + Y2) / 2;
      K := 0;
    end
    else begin
      HasK := True;
      K := -(X2 - X1) / (Y2 - Y1);
      B := ((Y1 + Y2) / 2) - K * ((X1 + X2)/ 2);
    end;
  end;

//  Pnt := Point2D((X1 + X2) / 2, (Y1 + Y2) / 2);
//  Ln := LineK(X1, Y1, X2, Y2);
//
//  with Ln do
//    if HasK then
//      if IsEqual(K, 0) then
//      begin
//        B := Pnt.X;
//        HasK := False;
//      end
//      else
//      begin
//        K := 1 / K;
//        B := Pnt.Y - K * Pnt.X;
//      end
//    else
//    begin
//      K := 0;
//      B := Pnt.Y;
//      HasK := True;
//    end;

  Result := Ln;
end;

function PerpendBisector(P1, P2: TPoint2D): TLineK;
begin
  Result := PerpendBisector(P1.X, P1.Y, P2.X, P2.Y);
end;







//-------------------------------------------------------------------------------------------------

function Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4, E, Epsilon);
end;

function Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Float; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(X1, Y1, X2, Y2, X3, Y3, X4, Y4, Epsilon);
end;


function Intersection(Ln1, Ln2: TLineK; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln1, Ln2, E, Epsilon);
end;

function Intersection(Ln1, Ln2: TLineK; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln1, Ln2, Epsilon);
end;


function Intersection(P1, P2, P3, P4: TPoint2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(P1, P2, P3, P4, E, Epsilon);
end;

function Intersection(P1, P2, P3, P4: TPoint2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(P1, P2, P3, P4, Epsilon);
end;


function Intersection(Ln1, Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln1, Ln2, E, Epsilon);
end;

function Intersection(Ln1, Ln2: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln1, Ln2, Epsilon);
end;


function Intersection(Ln1: TLineK; Ln2: TLine2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln1, Ln2, E, Epsilon);
end;

function Intersection(Ln1: TLineK; Ln2: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln1, Ln2, Epsilon);
end;


function Intersection(Ln: TLineK; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Seg, E, Epsilon);
end;

function Intersection(Ln: TLineK; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Seg, Epsilon);
end;


function Intersection(Ln: TLine2D; Seg: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Seg, E, Epsilon);
end;

function Intersection(Ln: TLine2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Seg, Epsilon);
end;


function Intersection(Seg1, Seg2: TSegment2D; out E: Integer; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg1, Seg2, E, Epsilon);
end;

function Intersection(Seg1, Seg2: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg1, Seg2, Epsilon);
end;





//-------------------------------------------------------------

function Intersection(Ln: TLineK; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Rect, Epsilon);
end;

function Intersection(Ln: TLine2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Rect, Epsilon);
end;

function Intersection(Seg: TSegment2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg, Rect, Epsilon);
end;




//-------------------------------------------------------------

function Intersection(Ln: TLineK; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Cx, Cy, Radius, Epsilon);
end;

function Intersection(Ln: TLineK; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Cir, Epsilon);
end;

function Intersection(Ln: TLine2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Cir, Epsilon);
end;


function Intersection(Seg: TSegment2D; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg, Cx, Cy, Radius, Epsilon);
end;

function Intersection(Seg: TSegment2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg, Cir, Epsilon);
end;




//-------------------------------------------------------------

function Intersection(Ln: TLineK; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Arc, Epsilon);
end;

function Intersection(Ln: TLine2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Arc, Epsilon);
end;

function Intersection(Seg: TSegment2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg, Arc, Epsilon);
end;



//-------------------------------------------------------------

function Intersection(Ln: TLineK; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Poly, Epsilon);
end;

function Intersection(Ln: TLine2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Poly, Epsilon);
end;

function Intersection(Seg: TSegment2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg, Poly, Epsilon);
end;



//-------------------------------------------------------------

function Intersection(Ray1, Ray2: TRay2D; const Epsilon: Float = _Epsilon): TPoint2DArray; overload;
begin
  Result := TUdInct2D.Intersection(Ray1, Ray2, Epsilon);
end;

function Intersection(Ray: TRay2D; Seg: TSegment2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ray, Seg, Epsilon);
end;


function Intersection(Ray: TRay2D; Ln: TLine2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ray, Ln, Epsilon);
end;

function Intersection(Ray: TRay2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ray, Cir, Epsilon);
end;

function Intersection(Ray: TRay2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ray, Arc, Epsilon);
end;

function Intersection(Ray: TRay2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ray, Ell, Epsilon);
end;

function Intersection(Ray: TRay2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ray, Poly, Epsilon);
end;

function Intersection(Ray: TRay2D; Rect: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ray, Rect, Epsilon);
end;

function Intersection(Ray: TRay2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ray, Segarc, Epsilon);
end;

function Intersection(Ray: TRay2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ray, Segarcs, Epsilon);
end;




//-------------------------------------------------------------

function Intersection(Rect1, Rect2: TRect2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Rect1, Rect2, Epsilon);
end;

function Intersection(Rect: TRect2D; Cx, Cy, Radius: Float; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Rect, Cx, Cy, Radius, Epsilon);
end;

function Intersection(Rect: TRect2D; Cir: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Rect, Cir, Epsilon);
end;

function Intersection(Rect: TRect2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Rect, Arc, Epsilon);
end;

function Intersection(Rect: TRect2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Rect, Poly, Epsilon);
end;




//-------------------------------------------------------------

function Intersection(Cir1, Cir2: TCircle2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Cir1, Cir2, Epsilon);
end;

function Intersection(Cir: TCircle2D; Arc: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Cir, Arc, Epsilon);
end;

function Intersection(Cir: TCircle2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Cir, Poly, Epsilon);
end;




function Intersection(Arc1, Arc2: TArc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
 Result := TUdInct2D.Intersection(Arc1, Arc2, Epsilon);
end;

function Intersection(Arc: TArc2D; Poly: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Arc, Poly, Epsilon);
end;




function Intersection(Poly1, Poly2: TPoint2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Poly1, Poly2, Epsilon);
end;





function Intersection(Ln: TLineK; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Ell, Epsilon);
end;

function Intersection(Ln: TLine2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Ell, Epsilon);
end;

function Intersection(Seg: TSegment2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg, Ell, Epsilon);
end;

function Intersection(Cir: TCircle2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Cir, Ell, Epsilon);
end;

function Intersection(Arc: TArc2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Arc, Ell, Epsilon);
end;

function Intersection(Rect: TRect2D; Ell: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Rect, Ell, Epsilon);
end;

function Intersection(Ell1, Ell2: TEllipse2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ell1, Ell2, Epsilon);
end;

function Intersection(Ell: TEllipse2D; Poly: TPoint2DArray;  const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ell, Poly, Epsilon);
end;




function Intersection(Ln: TLine2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Segarc, Epsilon);
end;

function Intersection(Seg: TSegment2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg, Segarc, Epsilon);
end;

function Intersection(Cir: TCircle2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Cir, Segarc, Epsilon);
end;

function Intersection(Arc: TArc2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Arc, Segarc, Epsilon);
end;

function Intersection(Rect: TRect2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Rect, Segarc, Epsilon);
end;

function Intersection(Ell: TEllipse2D; Segarc: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ell, Segarc, Epsilon);
end;

function Intersection(Poly: TPoint2DArray; Segarc: TSegarc2D;const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Poly, Segarc, Epsilon);
end;

function Intersection(Segarc1, Segarc2: TSegarc2D; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Segarc1, Segarc2, Epsilon);
end;

function Intersection(Segarc: TSegarc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Segarc, Segarcs, Epsilon);
end;



function Intersection(Ln: TLine2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ln, Segarcs, Epsilon);
end;

function Intersection(Seg: TSegment2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Seg, Segarcs, Epsilon);
end;

function Intersection(Cir: TCircle2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Cir, Segarcs, Epsilon);
end;

function Intersection(Arc: TArc2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Arc, Segarcs, Epsilon);
end;

function Intersection(Rect: TRect2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Rect, Segarcs, Epsilon);
end;

function Intersection(Ell: TEllipse2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Ell, Segarcs, Epsilon);
end;

function Intersection(Poly: TPolygon2D; Segarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Poly, Segarcs, Epsilon);
end;

function Intersection(Segarcs1, Segarcs2: TSegarc2DArray; const Epsilon: Float = _Epsilon): TPoint2DArray;
begin
  Result := TUdInct2D.Intersection(Segarcs1, Segarcs2, Epsilon);
end;




//-------------------------------------------------------------------------------------------------

function RighterPoint(P1, P2: TPoint2D): TPoint2D;
begin
  if P1.X > P2.X then Result := P1 else Result := P2;
end;

function RighterPoint(Poly: TPoint2DArray): TPoint2D;
var
  I: Longint;
begin
  Result := Point2D(0, 0);

  for I := Low(Poly) to High(Poly) do
    if I = Low(Poly) then Result := Poly[I] else if Poly[I].X > Result.X then Result := Poly[I];
end;


function LefterPoint(P1, P2: TPoint2D): TPoint2D;
begin
  if P1.X < P2.X then Result := P1 else Result := P2;
end;

function LefterPoint(Poly: TPoint2DArray): TPoint2D;
var
  I: Longint;
begin
  Result := Point2D(0, 0);

  for I := Low(Poly) to High(Poly) do
    if I = Low(Poly) then Result := Poly[I] else if Poly[I].X < Result.X then Result := Poly[I];
end;


function HigherPoint(P1, P2: TPoint2D): TPoint2D;
begin
  if P1.Y > P2.Y then Result := P1 else Result := P2;
end;

function HigherPoint(Poly: TPoint2DArray): TPoint2D;
var
  I: Longint;
begin
  Result := Point2D(0, 0);

  for I := Low(Poly) to High(Poly) do
    if I = Low(Poly) then Result := Poly[I] else if Poly[I].Y > Result.Y then Result := Poly[I];
end;


function LowerPoint(P1, P2: TPoint2D): TPoint2D;
begin
  if P1.Y < P2.Y then Result := P1 else Result := P2;
end;

function LowerPoint(Poly: TPoint2DArray): TPoint2D;
var
  I: Longint;
begin
  Result := Point2D(0, 0);

  for I := Low(Poly) to High(Poly) do
    if I = Low(Poly) then Result := Poly[I] else if Poly[I].Y < Result.Y then Result := Poly[I];
end;


function NearestPoint(Poly: TPoint2DArray; Pnt: TPoint2D; out Index: Integer): TPoint2D;
var
  I, N: Integer;
  AD, MD: Float;
  RePnt: TPoint2D;
begin
  N := -1;
  MD := 0.0;
  for I := 0 to System.Length(Poly) - 1 do
  begin
    AD := LayDistance(Poly[I], Pnt);

    if I = 0 then
    begin
      N := I;
      MD := AD;
      RePnt := Poly[0];
    end
    else begin
      if AD < MD then
      begin
        N := I;
        MD := AD;
        RePnt := Poly[I];
      end;
    end;
  end;
  Index := N;
  Result := RePnt;
end;

function NearestPoint(Poly: TPoint2DArray; Pnt: TPoint2D): TPoint2D;
var
  N: Integer;
begin
  Result := NearestPoint(Poly, Pnt, N);
end;








function RectHull(X1, Y1, X2, Y2: Float): TRect2D;
begin
  Result.X1 := Min(X1, X2);
  Result.Y1 := Min(Y1, Y2);
  Result.X2 := Max(X1, X2);
  Result.Y2 := Max(Y1, Y2);
end;

function RectHull(P1, P2: TPoint2D): TRect2D;
begin
  Result := RectHull(P1.X, P1.Y, P2.X, p2.Y);
end;

function RectHull(X1, Y1, X2, Y2, X3, Y3: Float): TRect2D;
begin
  Result.X1 := Min(Min(X1, X2), X3);
  Result.Y1 := Min(Min(Y1, Y2), Y3);
  Result.X2 := Max(Max(X1, X2), X3);
  Result.Y2 := Max(Max(Y1, Y2), Y3)
end;

function RectHull(P1, P2, P3: TPoint2D): TRect2D;
begin
  Result := RectHull(P1.X, P1.Y, P2.X, p2.Y, P3.X, p3.Y);
end;



function RectHull(Seg: TSegment2D): TRect2D;
begin
  Result := RectHull(Seg.P1, Seg.P2);
end;

function RectHull(Rect: TRect2D): TRect2D;
begin
  Result.X1 := Min(Rect.X1, Rect.X2);
  Result.Y1 := Min(Rect.Y1, Rect.Y2);
  Result.X2 := Max(Rect.X1, Rect.X2);
  Result.Y2 := Max(Rect.Y1, Rect.Y2);
end;

function RectHull(Cir: TCircle2D): TRect2D;
begin
  Result.X1 := Cir.Cen.X - Cir.R;
  Result.Y1 := Cir.Cen.Y - Cir.R;
  Result.X2 := Cir.Cen.X + Cir.R;
  Result.Y2 := Cir.Cen.Y + Cir.R;
end;

function RectHull(Arc: TArc2D): TRect2D;
begin
  Result := RectHull(ArcHullPnts(Arc));
end;

function RectHull(Ell : TEllipse2D): TRect2D;
var
  R: Float;
begin
  R := Max(Abs(Ell.Ry), Abs(Ell.Rx));
  Result.X1 := Ell.Cen.X - R;
  Result.Y1 := Ell.Cen.Y - R;
  Result.X2 := Ell.Cen.X + R;
  Result.Y2 := Ell.Cen.Y + R;
end;


function RectHull(Poly: TPoint2DArray): TRect2D;
var
  I: Longint;
  X, Y: Float;
begin
  Result.X1 := 0.0;  Result.Y1 := 0.0;
  Result.X2 := 0.0;  Result.Y2 := 0.0;

  for I := Low(Poly) to High(Poly) do
  begin
    X := Poly[I].X;
    Y := Poly[I].Y;

    if I = Low(Poly) then
    begin
      Result.X1 := X; Result.Y1 := Y;
      Result.X2 := X; Result.Y2 := Y;
    end
    else begin
      if X < Result.X1 then Result.X1 := X else if X > Result.X2 then Result.X2 := X;
      if Y < Result.Y1 then Result.Y1 := Y else if Y > Result.Y2 then Result.Y2 := Y;
    end;
  end;
end;

function RectHull(Segarcs: TSegarc2DArray): TRect2D;
var
  I: Integer;
  LPolygon: TPolygon2D;
begin
  LPolygon := nil;
  for I := 0 to System.Length(Segarcs) - 1 do
    if Segarcs[I].IsArc then
      FAddArray(LPolygon, ArcHullPnts(Segarcs[I].Arc))
    else
      FAddArray(LPolygon, SamplePoints(Segarcs[I].Seg));

  Result := RectHull(LPolygon);
end;


function CircleHull(Poly: TPoint2DArray): TCircle2D;
var
  I: Integer;
  Cen: TPoint2D;
  LayLen: Float;
  LayDist: Float;
begin
  if System.Length(Poly) < 3 then Exit;   //---->>>>

  LayLen := -1;
  Cen := Centroid(Poly);

  for I := Low(Poly) to High(Poly) do
  begin
    LayDist := LayDistance(Cen, Poly[I]);
    if LayDist > LayLen then LayLen := LayDist;
  end;

  Result.Cen := Cen;
  Result.R := Sqrt(LayLen);
end;



function WidthHull(Poly: TPoint2DArray): TPoint2D;
var
  ARct: TRect2D;
begin
  ARct := RectHull(Poly);
  Result.X := ARct.X1;
  Result.Y := ARct.X2;
end;

function HeightHull(Poly: TPoint2DArray): TPoint2D;
var
  ARct: TRect2D;
begin
  ARct := RectHull(Poly);
  Result.X := ARct.Y1;
  Result.Y := ARct.Y2;
end;










//-------------------------------------------------------------------------------------------------

function CircumCircle(Pnt1, Pnt2, Pnt3: TPoint2D): TCircle2D;
begin
  Result.Cen := Circumcenter(Pnt1, Pnt2, Pnt3);
  Result.R := Distance(Pnt1, Result.Cen);
end;


function InscribedCircle(Pnt1, Pnt2, Pnt3: TPoint2D): TCircle2D;
var
  Perim:  Float;
  Side12: Float;
  Side23: Float;
  Side31: Float;
begin
  Side12 := Distance(Pnt1, Pnt2);
  Side23 := Distance(Pnt2, Pnt3);
  Side31 := Distance(Pnt3, Pnt1);

  Perim  := 1 / (Side12 + Side23 + Side31);

  Result.Cen.X := (Side23 * Pnt1.X + Side31 * Pnt2.X + Side12 * Pnt3.X) * Perim;
  Result.Cen.Y := (Side23 * Pnt1.Y + Side31 * Pnt2.Y + Side12 * Pnt3.Y) * Perim;
  Result.R := Sqrt(
                    (-Side12 + Side23 + Side31) *
                    (Side12 - Side23 + Side31)  *
                    (Side12 + Side23 - Side31)  *
                     Perim
                  ) * 0.5;
end;





function ArcEndPnts(Arc: TArc2D): TPoint2DArray;
begin
  Result := nil;
  if Arc.R <= 0 then Exit;

  System.SetLength(Result, 2);
  if Arc.IsCW then
  begin
    Result[0] := ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R);
    Result[1] := ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R);
  end
  else begin
    Result[0] := ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R);
    Result[1] := ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R);
  end;
end;

function ArcQuadPnts(Arc: TArc2D): TPoint2DArray;
var
  I, L: Integer;
  Q, A: Integer;
  A1, A2: Float;
begin
  Result := nil;

  A1 := Arc.Ang1;
  A2 := Arc.Ang2;

  if A2 < A1 then A2 := A2 + 360;

  Q := Quadrant(A1);
  A := Q * 90;

  L := 0;
  while A < A2 do
  begin
    L := L + 1;
    A := A + 90;
  end;

  if L <= 0 then Exit;  //======>>>>

  System.SetLength(Result, L);
  if Arc.IsCW then
  begin
    for I := L - 1 downto 0 do
      Result[L-1 - I] := GetArcPoint(Arc.Cen, Arc.R, (Q + I) * 90);
  end
  else begin
    for I := 0 to L - 1 do
      Result[I] := GetArcPoint(Arc.Cen, Arc.R, (Q + I) * 90);
  end;
end;

function ArcHullPnts(Arc: TArc2D): TPoint2DArray;
var
  I: Integer;
  LEndPnts: TPoint2DArray;
  LQuadPnts: TPoint2DArray;
begin
  Result := nil;
  if IsEqual(Arc.R, 0) or (Arc.R < 0) then Exit;

  LEndPnts := ArcEndPnts(Arc);
  LQuadPnts := ArcQuadPnts(Arc);

  System.SetLength(Result, System.Length(LQuadPnts) + 2);

  Result[0] := LEndPnts[0];
  for I := 0 to System.Length(LQuadPnts) - 1 do Result[I + 1] := LQuadPnts[I];
  Result[High(Result)] := LEndPnts[1];
end;

function SegarcEndPnts(Segarc: TSegarc2D): TPoint2DArray;
begin
  if Segarc.IsArc then
  begin
    Result := ArcEndPnts(Segarc.Arc);
  end
  else begin
    Result := SamplePoints(Segarc.Seg);
  end;
end;



function EllipseQuadPnts(Ell: TEllipse2D): TPoint2DArray;
var
  I, L: Integer;
  Q, A: Integer;
  A1, A2: Float;
begin
  Result := nil;

  A1 := Ell.Ang1;
  A2 := Ell.Ang2;

  if A2 < A1 then A2 := A2 + 360;

  Q := Quadrant(A1);
  A := Q * 90;

  L := 0;
  while A < A2 do
  begin
    L := L + 1;
    A := A + 90;
  end;

  if L <= 0 then Exit;  //======>>>>

  System.SetLength(Result, L);
  if Ell.IsCW then
  begin
    for I := L - 1 downto 0 do
      Result[L-1 - I] := GetEllipsePoint(Ell, (Q + I) * 90);
  end
  else begin
    for I := 0 to L - 1 do
      Result[I] := GetEllipsePoint(Ell, (Q + I) * 90);
  end;
end;



//-------------------------------------------------------------------------------------------------

function CenAngToEllAng(Rx, Ry: Float; Ang: Float): Float;
var
  LnX: TLine2D;
  LnK: TLineK;
  LAng: Float;
  LRx, LRy: Float;
  LPe, LPnt: TPoint2D;
  LInctPnts: TPoint2DArray;
begin
  Result := -1;

  LAng := FixAngle(Ang);
  if IsEqual(LAng, 0.0) or IsEqual(LAng, 90.0) or
     IsEqual(LAng, 180.0) or IsEqual(LAng, 270.0) or IsEqual(LAng, 360.0) then
  begin
    Result := Ang;

    if (Rx < 0) and (Ry < 0) then
      Result := FixAngle(Result + 180.0)
    else if (Rx < 0) then
      Result := FixAngle(180.0 - Result)
    else if (Ry < 0) then
      Result := FixAngle(-Result);

    Exit; //=====>>>
  end;

  LRx := Rx;
  LRy := Ry;
  if IsEqual(LRx, LRy) then
  begin
    Result := Ang;
    Exit; //=====>>>
  end;

  LnK := LineK(0, 0, LAng);
  LInctPnts := Intersection(LnK, Ellipse2D(Point2D(0,0), Rx, Ry, 0, 360, 0));

  LPe := LInctPnts[0];
  if (System.Length(LInctPnts) > 1) and
     NotEqual(GetAngle(Point2D(0,0), LInctPnts[0]), LAng, 45) then LPe := LInctPnts[1];


  LnX := Line2D(0, LPe.Y, LPe.X, LPe.Y);

  LInctPnts := Intersection(LnX, Circle2D(Point2D(0,0), Ry));
  if System.Length(LInctPnts) < 1 then Exit; //=====>>>

  LPnt := LInctPnts[0];
  if (System.Length(LInctPnts) > 1) and
     (LayDistance(LInctPnts[0], LPe) > LayDistance(LInctPnts[1], LPe)) then LPnt := LInctPnts[1];

  Result := GetAngle(Point2D(0, 0), LPnt);

  if (Rx < 0) and (Ry < 0) then
    Result := FixAngle(Result + 180.0)
  else if (Rx < 0) then
    Result := FixAngle(180.0 - Result)
  else if (Ry < 0) then
    Result := FixAngle(-Result);
end;

function EllAngToCenAng(Rx, Ry: Float; Ang: Float): Float;
var
  LAng: Float;
  LRx, LRy: Float;
  LPx, LPy: TPoint2D;
  LnX, LnY: TLine2D;
  LInctPnts: TPoint2DArray;
begin
  Result := -1;

  LAng := FixAngle(Ang);
  if IsEqual(LAng, 0.0) or IsEqual(LAng, 90.0) or
     IsEqual(LAng, 180.0) or IsEqual(LAng, 270.0) or IsEqual(LAng, 360.0) then
  begin
    Result := Ang;
    Exit; //=====>>>
  end;

  LRx := Rx;
  LRy := Ry;
  if IsEqual(LRx, LRy) then
  begin
    Result := Ang;
    Exit; //=====>>>
  end;

  LPx := GetArcPoint(Point2D(0, 0), Rx, LAng);
  LPy := GetArcPoint(Point2D(0, 0), Ry, LAng);

  LnX := Line2D(LPx.X, 0, LPx.X, LPx.Y);
  LnY := Line2D(0, LPy.Y, LPy.X, LPy.Y);

  LInctPnts := Intersection(LnX, LnY);
  if System.Length(LInctPnts) > 0  then
    Result := GetAngle(Point2D(0, 0), LInctPnts[0]);
end;


function GetArcPoint(Cen: TPoint2D; R: Float; Ang: Float): TPoint2D;
begin
  Result.X := Cen.X + R * CosD(Ang);
  Result.Y := Cen.Y + R * SinD(Ang);
end;

function GetEllPoint(Cen: TPoint2D; Rx, Ry: Float; Rot: Float; Ang: Float; EAng: Boolean): TPoint2D;
var
  LAng, LRotSin, LRotCos: Extended;
begin
  SinCosD(Rot, LRotSin, LRotCos);

  LAng := Ang;
  if not EAng then
    LAng := CenAngToEllAng(Rx, Ry, Ang);

  Result.X := Cen.X + Rx * LRotCos * CosD(LAng) - Ry * LRotSin * SinD(LAng);
  Result.Y := Cen.Y + Rx * LRotSin * CosD(LAng) + Ry * LRotCos * SinD(LAng);
end;

function GetEllipsePoint(Cen: TPoint2D; Rx, Ry: Float; Rot: Float; Ang: Float; EAng: Boolean = True): TPoint2D;
begin
  Result := GetEllPoint(Cen, Rx, Ry, Rot, Ang, EAng);
end;

function GetEllipsePoint(Ell: TEllipse2D; Ang: Float; EAng: Boolean = True): TPoint2D;
begin
  Result := GetEllPoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Rot, Ang, EAng);
end;


function SamplePoints(Seg: TSegment2D; Wid: Float = 0.0): TPoint2DArray;
var
  LAng: Float;
begin
  if (Wid < 0.0) or IsEqual(Wid, 0.0) then
  begin
    System.SetLength(Result, 2);
    Result[0] := Seg.P1;
    Result[1] := Seg.P2;
  end
  else begin
    LAng := GetAngle(Seg.P1, Seg.P2);

    System.SetLength(Result, 5);

    Result[0] := ShiftPoint(Seg.P1, LAng + 90, (Wid / 2));
    Result[1] := ShiftPoint(Seg.P1, LAng - 90, (Wid / 2));
    Result[2] := ShiftPoint(Seg.P2, LAng - 90, (Wid / 2));
    Result[3] := ShiftPoint(Seg.P2, LAng + 90, (Wid / 2));
    Result[4] := Result[0];
  end;
end;

function SamplePoints(Arc: TArc2D; Segments: Integer; Wid: Float = 0.0): TPoint2DArray;
var
  I, N: Integer;
  A, D, A1, A2: Float;
  LArc: TArc2D;
begin
  if (Wid < 0.0) or IsEqual(Wid, 0.0) then
  begin
    Result := nil;
    if (Arc.R <= 0.0) or IsEqual(Arc.Ang1, Arc.Ang2) then Exit;

    N  := Segments;
    A1 := FixAngle(Arc.Ang1);
    A2 := FixAngle(Arc.Ang2);

    if N <= 0 then
    begin
      N := Round(FixAngle(A2 - A1) / (DEF_ANG_STEP));
      if N <= 0 then N := 1;
    end;


    System.SetLength(Result, N + 1);

    if Arc.IsCW then
    begin
      Result[N] := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
      Result[0] := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
    end
    else begin
      Result[0] := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang1);
      Result[N] := GetArcPoint(Arc.Cen, Arc.R, Arc.Ang2);
    end;

    A := A1;
    D := FixAngle(A2 - A1) / N;
    for I := 1 to N - 1 do
    begin
      A := A + D;
      if Arc.IsCW then
        Result[N-I] := GetArcPoint(Arc.Cen, Arc.R, A)
      else
        Result[I]   := GetArcPoint(Arc.Cen, Arc.R, A);
    end;
  end
  else begin
    LArc := Arc;
    LArc.R := LArc.R + Wid / 2;
    Result := SamplePoints(LArc, Segments, 0.0);

    LArc := Arc;
    LArc.R := LArc.R - Wid / 2;
    LArc.IsCW := not LArc.IsCW;

    FAddArray(Result, SamplePoints(LArc, Segments, 0.0) );

    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := Result[0] ;
  end;
end;

function SamplePoints(Cir: TCircle2D; Segments: Integer; Wid: Float = 0.0): TPoint2DArray;
var
  I, N: Integer;
  A, D: Float;
  LArc: TArc2D;
begin
  if (Wid < 0.0) or IsEqual(Wid, 0.0) then
  begin
    Result := nil;
    if (Cir.R <= 0.0) then Exit;

    N := Segments;

    if N <= 0 then
      N := Round(360.0 / DEF_ANG_STEP);

    System.SetLength(Result, N + 1);
    Result[0] := GetArcPoint(Cir.Cen, Cir.R, 0.0 );
    Result[N] := GetArcPoint(Cir.Cen, Cir.R, 360.0);

    A := 0.0;
    D := 360.0 / N;
    for I := 1 to N - 1 do
    begin
      A := A + D;
      Result[I] := GetArcPoint(Cir.Cen, Cir.R, A);
    end;
  end
  else begin
    LArc := Arc2D(Cir.Cen, Cir.R, 0, 360);
    Result := SamplePoints(LArc, Segments, Wid);
  end;
end;

function SamplePoints(Ell: TEllipse2D; Segments: Integer; Wid: Float = 0.0): TPoint2DArray;
var
  LRotSin, LRotCos: Extended;

  function _GetEllPoint(Cen: TPoint2D; Rx, Ry: Float; Ang: Float): TPoint2D;
  begin
    Result.X := Cen.X + Rx * LRotCos * CosD(Ang) - Ry * LRotSin * SinD(Ang);
    Result.Y := Cen.Y + Rx * LRotSin * CosD(Ang) + Ry * LRotCos * SinD(Ang);
  end;

var
  I, N: Integer;
  A, D, A1, A2: Float;
  LEll: TEllipse2D;
begin
  if (Wid < 0.0) or IsEqual(Wid, 0.0) then
  begin
    Result := nil;
    if IsEqual(Ell.Rx , 0.0) and IsEqual(Ell.Ry, 0.0) then Exit; // or IsEqual(Ell.Ang1, Ell.Ang2)


    N  := Segments;
    A1 := FixAngle(Ell.Ang1);
    A2 := FixAngle(Ell.Ang2);

    if N <= 0 then
    begin
      N := Round(FixAngle(A2 - A1) / (DEF_ANG_STEP));
      if N <= 0 then N := 1;
    end;


    SinCosD(Ell.Rot, LRotSin, LRotCos);

    System.SetLength(Result, N + 1);

    if Ell.IsCW then
    begin
      Result[N] := _GetEllPoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Ang1);
      Result[0] := _GetEllPoint(Ell.Cen, Ell.Rx, Ell.Ry, Ell.Ang2);
    end
    else begin
      Result[0] := _GetEllPoint(Ell.Cen, Ell.Rx, Ell.Ry,  Ell.Ang1);
      Result[N] := _GetEllPoint(Ell.Cen, Ell.Rx, Ell.Ry,  Ell.Ang2);
    end;

    A := A1;
    D := FixAngle(A2 - A1) / N;
    for I := 1 to N - 1 do
    begin
      A := A + D;
      if Ell.IsCW then
        Result[N-I] := _GetEllPoint(Ell.Cen, Ell.Rx, Ell.Ry, A)
      else
        Result[I]   := _GetEllPoint(Ell.Cen, Ell.Rx, Ell.Ry, A);
    end;
  end
  else begin
    LEll := Ell;
    LEll.Rx := LEll.Rx + Wid / 2;
    LEll.Ry := LEll.Ry + Wid / 2;
    Result := SamplePoints(LEll, Segments, 0.0);

    LEll := Ell;
    LEll.Rx := LEll.Rx - Wid / 2;
    LEll.Ry := LEll.Ry - Wid / 2;
    LEll.IsCW := not LEll.IsCW;

    FAddArray(Result, SamplePoints(LEll, Segments, 0.0) );

    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := Result[0] ;
  end;
end;

function SamplePoints(Segarc: TSegarc2D; Wid: Float = 0.0): TPoint2DArray;
begin
  if Segarc.IsArc then
    Result := SamplePoints(Segarc.Arc, -1)
  else
    Result := SamplePoints(Segarc.Seg);
end;

function SamplePoints(Segarcs: TSegarc2DArray; IsSimple: Boolean = False): TPoint2DArray;
var
  L: Integer;
  I, J: Integer;
  LSegarc: TSegarc2D;
  LPnts: TPoint2DArray;
  LPoints: TPoint2DArray;
begin
  Result := nil;
  LPoints := nil;


  for I := 0 to System.Length(Segarcs) - 1 do
  begin
    LSegarc := Segarcs[I];
    if LSegarc.IsArc then
    begin
      if IsSimple then
      begin
        LPnts := ArcEndPnts(LSegarc.Arc);
        System.SetLength(LPoints, 3);
        LPoints[0] := LPnts[0];
        LPoints[1] := MidPoint(LSegarc.Arc);
        LPoints[2] := LPnts[1];
      end
      else
        LPoints := SamplePoints(LSegarc.Arc, -1)
    end
    else
      LPoints := SamplePoints(LSegarc.Seg);

    if (System.Length(Result) > 0) and (System.Length(LPoints) > 0) and IsEqual(Result[High(Result)], LPoints[0]) then
      System.SetLength(Result, System.Length(Result) - 1);

    if System.Length(LPoints) > 0 then
    begin
      L := System.Length(Result);
      System.SetLength(Result, L + System.Length(LPoints));

      for J := 0 to System.Length(LPoints) - 1 do
        Result[L + J] := LPoints[J];
    end;
  end;

end;


function SampleSegmentNum(PixelSize: Float; Radius, IncdeAng: Float; Resolution: Integer = 800): Integer;
var
  LAngPerctN: SmallInt;
  LReso, LReturn, LModVal: Integer;
  LAngPerct, LFactor, LIncdeAng, LPixelSize: Float;
begin
  LIncdeAng := FixAngle(IncdeAng);

  LPixelSize := Abs(PixelSize);
  if LPixelSize <= 0 then LPixelSize := 1.0;


  if IsEqual(LIncdeAng, 0.0, 1E-06) then
    LIncdeAng := 360.0;

  LReso := 400;
  if (Resolution > 1000) then
    LReso := Round(LReso * (Resolution / 1000));

  LAngPerct := LIncdeAng / 360.0;
  LAngPerctN := SmallInt(Trunc(8.99 * LAngPerct));

  if (LAngPerctN < 1) then
    LAngPerctN := 1;

  LFactor := 0.3222 * Sqrt((Resolution * Abs(Radius)) / LPixelSize);

  LFactor := LFactor * LAngPerct;
  if (LFactor < LAngPerctN) then
    LFactor := LAngPerctN
  else if (LFactor > LReso) then
    LFactor := LReso;

  LReturn := Trunc(LFactor);
  LModVal := LReturn mod 4;

  if (Abs((LAngPerct - 1.0)) < 1E-08) and (LModVal <> 0) then
    LReturn := LReturn + 4 - LModVal;

  Result := LReturn;
end;

function PointsToSegments(Pnts: TPoint2DArray): TSegment2DArray;
var
  I, L: Integer;
begin
  Result := nil;

  L := System.Length(Pnts);
  if L <= 1 then Exit;

  System.SetLength(Result, L - 1);
  for I := 0 to L - 2 do
    Result[I] := Segment2D(Pnts[I], Pnts[I + 1]);
end;



//--------------------------------------------------------------------------------------------------

function BreakAt(ASeg: TSegment2D; APnt1, APnt2: TPoint2D; var AFlag: Cardinal): TSegment2DArray;
var
  LP1, LP2: TPoint2D;
begin
  Result := nil;
  if IsEqual(ASeg.P1, ASeg.P2) then  Exit; //======>>>>

  AFlag := 0;

  LP1 := ClosestSegmentPoint(APnt1, ASeg);
  LP2 := ClosestSegmentPoint(APnt2, ASeg);

  if not IsEqual(GetAngle(ASeg.P1, ASeg.P2), GetAngle(LP1, LP2), _Epsilon * 100) then
    Swap(LP1, LP2);

  if UdMath.NotEqual(ASeg.P1, LP1) then
  begin
    System.SetLength(Result, System.Length(Result) + 1);
    Result[ High(Result)] := Segment2D(ASeg.P1, LP1);
    AFlag := AFlag or 1;
  end;

  if UdMath.NotEqual(ASeg.P2, LP2) then
  begin
    System.SetLength(Result, System.Length(Result) + 1);
    Result[ High(Result)] := Segment2D(LP2, ASeg.P2);
    AFlag := AFlag or 2;
  end;
end;

function BreakAt(ASeg: TSegment2D; APnt1, APnt2: TPoint2D): TSegment2DArray;
var
  LFlag: Cardinal;
begin
  Result := BreakAt(ASeg, APnt1, APnt2, LFlag);
end;


function BreakAt(AArc: TArc2D; APnt1, APnt2: TPoint2D; var AFlag: Cardinal): TArc2DArray;
var
  A1, A2: Float;
  LArc: TArc2D;
begin
  Result := nil;
  if (AArc.R <= 0.0) then  Exit; //======>>>>

  AFlag := 0;

  A1 := GetAngle(AArc.Cen, ClosestArcPoint(APnt1, AArc));
  A2 := GetAngle(AArc.Cen, ClosestArcPoint(APnt2, AArc));

  if FixAngle(A1 - AArc.Ang1) > FixAngle(A2 - AArc.Ang1) then UdMath.Swap(A1, A2);

  if not IsEqual(A1, AArc.Ang1) then
  begin
    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := Arc2D(AArc.Cen, AArc.R, AArc.Ang1, A1, AArc.IsCW);

    if AArc.IsCW then AFlag := AFlag or 2 else AFlag := AFlag or 1;
  end;

  if not IsEqual(A2, AArc.Ang2) then
  begin
    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := Arc2D(AArc.Cen, AArc.R, A2, AArc.Ang2, AArc.IsCW);

    if AArc.IsCW then AFlag := AFlag or 1 else AFlag := AFlag or 2;
  end;

  if AArc.IsCW and (System.Length(Result) = 2) then
  begin
    LArc := Result[0];
    Result[0] := Result[1];
    Result[1] := LArc;
  end;
end;

function BreakAt(AArc: TArc2D; APnt1, APnt2: TPoint2D): TArc2DArray;
var
  LFlag: Cardinal;
begin
  Result := BreakAt(AArc, APnt1, APnt2, LFlag);
end;

function BreakAt(ACir: TCircle2D; APnt1, APnt2: TPoint2D): TArc2D;
var
  A1, A2: Float;
begin
  Result := Arc2D(0,0, -1, 0,0);
  if (ACir.R <= 0.0) then  Exit; //======>>>>

  A1 := GetAngle(ACir.Cen, ClosestCirclePoint(APnt1, ACir));
  A2 := GetAngle(ACir.Cen, ClosestCirclePoint(APnt2, ACir));

  if IsEqual(A1, A2) then Exit; ////======>>>> Arc cannot be full 360 degrees

  Result.Cen := ACir.Cen;
  Result.R := ACir.R;
  Result.Ang1 := A2;
  Result.Ang2 := A1;
end;

function BreakAt(AEll: TEllipse2D; APnt1, APnt2: TPoint2D; var AFlag: Cardinal): TEllipse2DArray;
var
  LFull: Boolean;
  A1, A2: Float;
  LEll: TEllipse2D;
begin
  Result := nil;
  if IsEqual(AEll.Rx, 0.0) or IsEqual(AEll.Ry, 0.0) then Exit;

  AFlag := 0;

  A1 := GetAngle(AEll.Cen, ClosestEllipsePoint(APnt1, AEll));
  A2 := GetAngle(AEll.Cen, ClosestEllipsePoint(APnt2, AEll));

  LFull := IsEqual(AEll.Ang1, 0.0) and IsEqual(AEll.Ang2, 360.0);
  if LFull and IsEqual(A1, A2) then Exit; ////======>>>> cannot be full 360 degrees

  A1 := CenAngToEllAng(AEll.Rx, AEll.Ry, A1 - AEll.Rot);
  A2 := CenAngToEllAng(AEll.Rx, AEll.Ry, A2 - AEll.Rot);

  if LFull then
  begin
    System.SetLength(Result, System.Length(Result) + 1);
    Result[High(Result)] := Ellipse2D(AEll.Cen, AEll.Rx, AEll.Ry, A2, A1, AEll.Rot, AEll.IsCW);
    AFlag := 1;
  end
  else begin
    if FixAngle(A1 - AEll.Ang1) > FixAngle(A2 - AEll.Ang1) then Swap(A1, A2);

    if not IsEqual(A1, AEll.Ang1) then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := Ellipse2D(AEll.Cen, AEll.Rx, AEll.Ry, AEll.Ang1, A1, AEll.Rot, AEll.IsCW);

      if AEll.IsCW then AFlag := AFlag or 2 else AFlag := AFlag or 1;
    end;

    if not IsEqual(A2, AEll.Ang2) then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[High(Result)] := Ellipse2D(AEll.Cen, AEll.Rx, AEll.Ry, A2, AEll.Ang2, AEll.Rot, AEll.IsCW);

      if AEll.IsCW then AFlag := AFlag or 1 else AFlag := AFlag or 2;
    end;
  end;

  if AEll.IsCW and (System.Length(Result) = 2) then
  begin
    LEll := Result[0];
    Result[0] := Result[1];
    Result[1] := LEll;
  end;
end;

function BreakAt(AEll: TEllipse2D; APnt1, APnt2: TPoint2D): TEllipse2DArray;
var
  LFlag: Cardinal;
begin
  Result := BreakAt(AEll, APnt1, APnt2, LFlag);
end;

function BreakAt(APoints: TPoint2DArray; APnt1, APnt2: TPoint2D; AClosed: Boolean = False): TPoint2DArrays;
var
  I, L: Integer;
  N, N1, N2: Integer;
  LP1, LP2: TPoint2D;
  LClosed: Boolean;
  LPnts, LPnts1, LPnts2: TPoint2DArray;
begin
  Result := nil;
  if System.Length(APoints) < 1 then  Exit; //======>>>>

  LClosed := AClosed and IsEqual(APoints[0], APoints[High(APoints)]);

  LP1 := ClosestPointsPoint(APnt1, APoints, N1);
  LP2 := ClosestPointsPoint(APnt2, APoints, N2);

  if N1 > N2 then
  begin
    Swap(N1, N2);
    Swap(LP1, LP2);
  end else
  if N1 = N2 then
  begin
    if not IsEqual(GetAngle(APoints[N1], APoints[N1+1]), GetAngle(LP1, LP2), _Epsilon * 100) then
      Swap(LP1, LP2);
  end;


  LPnts1 := nil;
  if not( (N1 = 0) and UdMath.IsEqual(APoints[0], LP1) ) then
  begin
    System.SetLength(LPnts1, N1 + 2);
    for I := 0 to N1 do LPnts1[I] := APoints[I];
    LPnts1[N1+1] := LP1;
  end;

  LPnts2 := nil;
  if not ( (N2 = High(APoints)-1) and UdMath.IsEqual(APoints[High(APoints)], LP2) ) then
  begin
    System.SetLength(LPnts2, System.Length(APoints) - N2);

    LPnts2[0] := LP2;
    for I := N2 + 1 to System.Length(APoints) - 1 do
     LPnts2[I-N2] := APoints[I];
  end;

  if LClosed and (System.Length(LPnts1) > 0) and (System.Length(LPnts2) > 0) then
  begin
    System.SetLength(LPnts, System.Length(LPnts1) + System.Length(LPnts2));

    L := System.Length(LPnts2);
    for I := 0 to L - 1 do LPnts[I] := LPnts2[I];

    N := 0;
    for I := 0 to System.Length(LPnts1) - 1 do
    begin
      LPnts[L+N] := LPnts1[I];
      N := N + 1;
    end;

    System.SetLength(Result, 1);
    Result[0] := LPnts;
  end
  else begin
    if (System.Length(LPnts1) > 0)  then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[ High(Result)] := LPnts1;
    end;

    if (System.Length(LPnts2) > 0)  then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[ High(Result)] := LPnts2;
    end;
  end;
end;


procedure _BreakSegarc(ASegarc: TSegarc2D; APnt1, APnt2: TPoint2D; var AOutSegarc1, AOutSegarc2: TSegarc2D);
var
  LFlag: Cardinal;
  LArcs: TArc2DArray;
  LSegs: TSegment2DArray;
begin
  AOutSegarc1 := Segarc2D(Point2D(0,0), Point2D(0,0));
  AOutSegarc2 := Segarc2D(Point2D(0,0), Point2D(0,0));

  if ASegarc.IsArc then
  begin
    LArcs := BreakAt(ASegarc.Arc, APnt1, APnt2, LFlag);

    if System.Length(LArcs) = 2 then
    begin
      AOutSegarc1 := Segarc2D(LArcs[0]);
      AOutSegarc2 := Segarc2D(LArcs[1]);
    end else
    if System.Length(LArcs) = 1 then
    begin
      if LFlag = 1 then
        AOutSegarc1 := Segarc2D(LArcs[0])
      else if LFlag = 2 then
        AOutSegarc2 := Segarc2D(LArcs[0])
    end;
  end
  else begin
    LSegs := BreakAt(ASegarc.Seg, APnt1, APnt2, LFlag);

    if System.Length(LSegs) = 2 then
    begin
      AOutSegarc1 := Segarc2D(LSegs[0]);
      AOutSegarc2 := Segarc2D(LSegs[1]);
    end else
    if System.Length(LSegs) = 1 then
    begin
      if LFlag = 1 then
        AOutSegarc1 := Segarc2D(LSegs[0])
      else if LFlag = 2 then
        AOutSegarc2 := Segarc2D(LSegs[0])
    end;
  end;
end;

function BreakAt(ASegarcs: TSegarc2DArray; APnt1, APnt2: TPoint2D; AClosed: Boolean = False): TSegarc2DArrays;
var
  I, L: Integer;
  N, N1, N2: Integer;
  LP1, LP2: TPoint2D;
  LClosed: Boolean;
  LSegarc10, LSegarc20: TSegarc2D;
  LSegarc, LSegarc1, LSegarc2: TSegarc2D;
  LSegarcs, LSegarcs1, LSegarcs2: TSegarc2DArray;
begin
  Result := nil;
  if System.Length(ASegarcs) < 1 then  Exit; //======>>>>

  LClosed := AClosed and IsEqual(ASegarcs[0].Seg.P1, ASegarcs[High(ASegarcs)].Seg.P2);

  LP1 := ClosestSegarcsPoint(APnt1, ASegarcs, N1);
  LP2 := ClosestSegarcsPoint(APnt2, ASegarcs, N2);

  for I := 0 to System.Length(ASegarcs) - 1 do
  begin
    if (IsEqual(ASegarcs[I].Seg.P1, LP1) and IsEqual(ASegarcs[I].Seg.P2, LP2)) or
       (IsEqual(ASegarcs[I].Seg.P2, LP1) and IsEqual(ASegarcs[I].Seg.P1, LP2)) then
    begin
      N1 := I;
      N2 := I;
      Break;
    end;
  end;



  if N1 = N2 then
  begin
    LSegarc := ASegarcs[N1];
    _BreakSegarc(LSegarc, LP1, LP2, LSegarc1, LSegarc2);
  end
  else begin
    if N1 > N2 then
    begin
      Swap(N1, N2);
      Swap(LP1, LP2);
    end;

    LSegarc := ASegarcs[N1];
    _BreakSegarc(LSegarc, LP1, LSegarc.Seg.P2, LSegarc10, LSegarc20);
    LSegarc1 := LSegarc10;

    LSegarc := ASegarcs[N2];
    _BreakSegarc(LSegarc, LSegarc.Seg.P1, LP2, LSegarc10, LSegarc20);
    LSegarc2 := LSegarc20;
  end;

  LSegarcs1 := nil;
  if N1 > 0 then
  begin
    System.SetLength(LSegarcs1, N1);
    for I := 0 to N1 - 1 do LSegarcs1[I] := ASegarcs[I];
  end;
  if not IsDegenerate(LSegarc1) then
  begin
    System.SetLength(LSegarcs1, System.Length(LSegarcs1) + 1);
    LSegarcs1[ High(LSegarcs1)] := LSegarc1;
  end;

  N := 0;
  LSegarcs2 := nil;
  if not IsDegenerate(LSegarc2) then
  begin
    N := 1;
    System.SetLength(LSegarcs2, 1);
    LSegarcs2[0] := LSegarc2;
  end;
  if N2 < System.Length(ASegarcs) - 1 then
  begin
    L := System.Length(ASegarcs) - N2 - 1;
    System.SetLength(LSegarcs2, N + L);
    for I := 0 to L - 1 do LSegarcs2[N + I] := ASegarcs[N2 + 1 + I];
  end;


  if LClosed and (System.Length(LSegarcs1) > 0) and (System.Length(LSegarcs2) > 0) then
  begin
    System.SetLength(LSegarcs, System.Length(LSegarcs1) + System.Length(LSegarcs2));

    L := System.Length(LSegarcs2);
    for I := 0 to L - 1 do LSegarcs[I] := LSegarcs2[I];

    N := 0;
    for I := 0 to System.Length(LSegarcs1) - 1 do
    begin
      LSegarcs[L+N] := LSegarcs1[I];
      N := N + 1;
    end;

    System.SetLength(Result, 1);
    Result[0] := LSegarcs;
  end
  else begin
    if System.Length(LSegarcs1) > 0 then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[ High(Result)] := LSegarcs1;
    end;

    if System.Length(LSegarcs2) > 0 then
    begin
      System.SetLength(Result, System.Length(Result) + 1);
      Result[ High(Result)] := LSegarcs2;
    end;
  end;
end;




function Stretch(ASeg: TSegment2D; AValue: Float): TSegment2D;
begin
  Result := Stretch(ASeg, AValue, AValue);;
end;

function Stretch(ASeg: TSegment2D; AValue1, AValue2: Float): TSegment2D;
var
  LAng: Float;
begin
  Result := ASeg;

  LAng := GetAngle(ASeg.P1, ASeg.P2);

  if NotEqual(AValue1, 0.0) then
    Result.P1 := ShiftPoint(Result.P1, LAng + 180, AValue1);

  if NotEqual(AValue2, 0.0) then
    Result.P2 := ShiftPoint(Result.P2, LAng, AValue2);
end;

function Stretch(AArc: TArc2D; AValue: Float; AByAng: Boolean = True): TArc2D;
begin
  Result := Stretch(AArc, AValue, AValue, AByAng);
end;

function Stretch(AArc: TArc2D; AValue1, AValue2: Float; AByAng: Boolean = True): TArc2D;
var
  LDelta: Float;
begin
  Result := AArc;

  if not AByAng then
  begin
    AValue1 := LenToAng(AValue1, AArc.R);
    AValue2 := LenToAng(AValue2, AArc.R);
  end;

  with Result do
  begin
    LDelta := Abs(Ang2 - Ang1) / 4;
    if AValue1 > LDelta then AValue1 := LDelta;
    if AValue2 > LDelta then AValue2 := LDelta;

    Ang1 := FixAngle(Ang1 - AValue1);
    Ang2 := FixAngle(Ang2 + AValue2);
  end;
end;






//-------------------------------------------------------------------------------------------------

function DivisionPnt(Pnt1, Pnt2: TPoint2D; Num: Integer): TPoint2DArray;
var
  I: Integer;
  Interval: Float;
begin
  Result := nil;
  if Num <= 0 then Exit; //====>>>>>

  Interval := Distance(Pnt1, Pnt2) / Num;

  System.SetLength(Result, Num + 1);
  Result[0] := Pnt1;

  for I := 1 to Num - 1 do
    Result[I] := ShiftPoint(Pnt1, Pnt2, Interval * I);

  Result[Num] := Pnt2;
end;

function DivisionPnt(Arc: TArc2D; Num: Integer): TPoint2DArray;
var
  I: Integer;
  Interval: Float;
begin
  Result := nil;
  if Num <= 0 then Exit; //====>>>>>

  Interval := FixAngle(Arc.Ang2 - Arc.Ang1) / Num;

  System.SetLength(Result, Num + 1);

  if Arc.IsCW then
  begin
    Result[0] := ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R);
    for I := 1 to Num - 1 do
      Result[I] := ShiftPoint(Arc.Cen, (Arc.Ang2 - Interval * I), Arc.R);
    Result[Num] := ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R);
  end
  else begin
    Result[0] := ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R);
    for I := 1 to Num - 1 do
      Result[I] := ShiftPoint(Arc.Cen, (Arc.Ang1 + Interval * I), Arc.R);
    Result[Num] := ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R);
  end;
end;



function Inclusion(FromRect, ToRect: TRect2D): TInclusion;
var
  H, V: TInclusion;
begin
  Result := irOutside;

  if IsIntersect(FromRect, ToRect) then
  begin
    V := irIntsct;
    if (FromRect.Y1 >= ToRect.Y1) and (FromRect.Y2 <= ToRect.Y2) then V := irOvered
    else if (FromRect.Y1 < ToRect.Y1) and (FromRect.Y2 > ToRect.Y2) then V := irCovered;

    H := irIntsct;
    if (FromRect.X1 >= ToRect.X1) and (FromRect.X2 <= ToRect.X2) then H := irOvered
    else if (FromRect.X1 < ToRect.X1) and (FromRect.X2 > ToRect.X2) then H := irCovered;

    if (V = irCovered) and (H = irCovered) then Result := irCovered
    else if (V = irOvered) and (H = irOvered) then Result := irOvered
    else Result := irIntsct;
  end;
end;


function InterInclusion(FromPoly, ToPoly: TPoint2DArray; const Epsilon: Float = _Epsilon): TInclusion;
var
  I, N, L: Longint;
  Pnt1, Pnt2: TPoint2D;
  KeyPnts, Pnts: TPoint2DArray;
begin
  L := System.Length(FromPoly);

  KeyPnts := nil;

  for I := 0 to L - 1 do
  begin
    Pnt1 := FromPoly[I];
    Pnt2 := FromPoly[(I + 1) mod L];

    if IsEqual(Pnt1, Pnt2) then Continue;

    Pnts := DivisionPnt(Pnt1, Pnt2, 4);

    N := System.Length(KeyPnts);
    System.SetLength(KeyPnts, N + 4);

    KeyPnts[N + 0] := Pnts[0];
    KeyPnts[N + 1] := Pnts[1];
    KeyPnts[N + 2] := Pnts[2];
    KeyPnts[N + 3] := Pnts[3];
  end;

  N := 0;
  for I := Low(KeyPnts) to High(KeyPnts) do
    if IsPntInPolygon(KeyPnts[I].X, KeyPnts[I].Y, ToPoly, Epsilon) then N := N + 1;

  if N > 0 then
  begin
    if N = System.Length(KeyPnts) then Result := irOvered else Result := irIntsct;
  end
  else Result := irOutside;
end;

function Inclusion(FromPoly, ToPoly: TPoint2DArray; const Robust: Boolean = True; const Epsilon: Float = _Epsilon): TInclusion;
var
  FResult, TResult: TInclusion;
begin
  if Robust then
  begin
    FResult := InterInclusion(FromPoly, ToPoly, Epsilon);
    TResult := InterInclusion(ToPoly, FromPoly, Epsilon);

    if (FResult = irOutside) and (TResult = irOutside) then Result := irOutside
    else if (FResult = irOvered) and (TResult = irOvered) then Result := irEqual
    else if (FResult = irOvered) then Result := irOvered
    else if (TResult = irOvered) then Result := irCovered
    else Result := irIntsct;
  end
  else begin
    Result := InterInclusion(FromPoly, ToPoly, Epsilon);
  end;
end;



function InterInclusion(FromSegarcs, ToSegarcs: TSegarc2DArray; const Epsilon: Float = _Epsilon): TInclusion;
var
  I, N, L: Longint;
  KeyPnts, Pnts: TPoint2DArray;
begin
  L := System.Length(FromSegarcs);

  KeyPnts := nil;

  for I := 0 to L - 1 do
  begin
    if IsDegenerate(FromSegarcs[I]) then Continue;

    if FromSegarcs[I].IsArc then
      Pnts := DivisionPnt(FromSegarcs[I].Arc, 4)
    else
      Pnts := DivisionPnt(FromSegarcs[I].Seg.P1, FromSegarcs[I].Seg.P2, 4);

    N := System.Length(KeyPnts);
    System.SetLength(KeyPnts, N + 4);

    KeyPnts[N + 0] := Pnts[0];
    KeyPnts[N + 1] := Pnts[1];
    KeyPnts[N + 2] := Pnts[2];
    KeyPnts[N + 3] := Pnts[3];
  end;

  N := 0;
  for I := Low(KeyPnts) to High(KeyPnts) do
    if IsPntInSegarcs(KeyPnts[I].X, KeyPnts[I].Y, ToSegarcs, True, Epsilon) then N := N + 1;

  if N > 0 then
  begin
    if N = System.Length(KeyPnts) then Result := irOvered else Result := irIntsct;
  end
  else Result := irOutside;
end;

function Inclusion(FromSegarcs, ToSegarcs: TSegarc2DArray; const Robust: Boolean = True; const Epsilon: Float = _Epsilon): TInclusion;
var
  FResult, TResult: TInclusion;
begin
  if Robust then
  begin
    FResult := InterInclusion(FromSegarcs, ToSegarcs, Epsilon);
    TResult := InterInclusion(ToSegarcs, FromSegarcs, Epsilon);

    if (FResult = irOutside) and (TResult = irOutside) then Result := irOutside
    else if (FResult = irOvered) and (TResult = irOvered) then Result := irEqual
    else if (FResult = irOvered) then Result := irOvered
    else if (TResult = irOvered) then Result := irCovered
    else Result := irIntsct;
  end
  else begin
    Result := InterInclusion(FromSegarcs, ToSegarcs, Epsilon);
  end;
end;





//------------------------------------------------------------------------------------------------

function OffsetSegment(Seg: TSegment2D; Dis: Float; ALeftSide: Boolean): TSegment2D;
begin
  Result := TUdOffset2D.OffsetSegment(Seg, Dis, ALeftSide);
end;

function OffsetSegment(Seg: TSegment2D; Wid: Float; out Seg1, Seg2: TSegment2D): Boolean;
begin
  Result := TUdOffset2D.OffsetSegment(Seg, Wid, Seg1, Seg2);
end;


function OffsetArc(Arc: TArc2D; Dis: Float; ALeftSide: Boolean): TArc2D;
begin
  Result := TUdOffset2D.OffsetArc(Arc, Dis, ALeftSide);
end;

function OffsetArc(Arc: TArc2D; Wid: Float; out Arc1, Arc2: TArc2D): Boolean;
begin
  Result := TUdOffset2D.OffsetArc(Arc, Wid, Arc1, Arc2);
end;


function OffsetEllipse(Ell: TEllipse2D; Dis: Float; ALeftSide: Boolean): TEllipse2D;
begin
  Result := TUdOffset2D.OffsetEllipse(Ell, Dis, ALeftSide);
end;

function OffsetEllipse(Ell: TEllipse2D; Wid: Float; out Ell1, Ell2: TEllipse2D): Boolean;
begin
  Result := TUdOffset2D.OffsetEllipse(Ell, Wid, Ell1, Ell2);
end;


function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float; ALeftSide: Boolean): TSegarc2DArray;
begin
  Result := TUdOffset2D.OffsetSegarcs(Segarcs, Dis, ALeftSide);
end;

function OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray; ALeftSide: Boolean): TSegarc2DArray;
begin
  Result := TUdOffset2D.OffsetSegarcs(Segarcs, Dises, ALeftSide);
end;


function OffsetPoints(Poly: TPoint2DArray; Dis: Float; ALeftSide: Boolean): TPoint2DArray;
begin
  Result := TUdOffset2D.OffsetPoints(Poly, Dis, ALeftSide);
end;

function OffsetPoints(Poly: TPoint2DArray; Dises: TFloatArray; ALeftSide: Boolean): TPoint2DArray;
begin
  Result := TUdOffset2D.OffsetPoints(Poly, Dises, ALeftSide);
end;


function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float): TSegarc2DArray;
begin
  Result := TUdOffset2D.OffsetSegarcs(Segarcs, Dis);
end;

function OffsetSegarcs(Segarcs: TSegarc2DArray; Dises: TFloatArray): TSegarc2DArray;
begin
  Result := TUdOffset2D.OffsetSegarcs(Segarcs, Dises);
end;


function OffsetPolygon(Poly: TPoint2DArray; Dis: Float): TPoint2DArray;
begin
  Result := TUdOffset2D.OffsetPolygon(Poly, Dis);
end;

function OffsetPolygon(Poly: TPoint2DArray; Dises: TFloatArray): TPoint2DArray;
begin
  Result := TUdOffset2D.OffsetPolygon(Poly, Dises);
end;



function OffsetSegment(Seg: TSegment2D; Dis: Float; ASidePnt: TPoint2D): TSegment2D;
begin
  Result := TUdOffset2D.OffsetSegment(Seg, Dis, ASidePnt);
end;

function OffsetArc(Arc: TArc2D; Dis: Float; ASidePnt: TPoint2D): TArc2D;
begin
  Result := TUdOffset2D.OffsetArc(Arc, Dis, ASidePnt);
end;

function OffsetEllipse(Ell: TEllipse2D; Dis: Float; ASidePnt: TPoint2D): TEllipse2D;
begin
  Result := TUdOffset2D.OffsetEllipse(Ell, Dis, ASidePnt);
end;

function OffsetPoints(Poly: TPoint2DArray; Dis: Float; ASidePnt: TPoint2D): TPoint2DArray;
begin
  Result := TUdOffset2D.OffsetPoints(Poly, Dis, ASidePnt);
end;

function OffsetSegarcs(Segarcs: TSegarc2DArray; Dis: Float; ASidePnt: TPoint2D): TSegarc2DArray;
begin
  Result := TUdOffset2D.OffsetSegarcs(Segarcs, Dis, ASidePnt);
end;




//------------------------------------------------------------------------------------------------

function ClosePolygon(var APolygon: TPoint2DArray): Boolean;
begin
  Result := False;
  if System.Length(APolygon) <= 0 then Exit;

  if not IsEqual(APolygon[Low(APolygon)], APolygon[High(APolygon)]) then
  begin
    System.SetLength(APolygon, System.Length(APolygon) + 1);
    APolygon[High(APolygon)] := APolygon[Low(APolygon)];

    Result := True;
  end;
end;

function ConvexPolygon(Poly: TPoint2DArray; CW: Boolean = False): TPoint2DArray;
var
  I, L: Integer;
  I1, I2: Integer;
  Flags: array of Boolean;
  P0, P1, P2: TPoint2D;
begin
  L := System.Length(Poly);

  System.SetLength(Flags, L);
  //for I := 0 to L - 1 do Flags[I] := True;

  for I := 0 to L - 1 do
  begin
    I1 := (I + 1) mod L;
    I2 := (I + 2) mod L;

    P0 := Poly[I];
    P1 := Poly[I1];
    P2 := Poly[I2];

    if CW then
      Flags[I1] := (Orientation(P1, P0, P2) >= 0.0)
    else
      Flags[I1] := (Orientation(P1, P0, P2) <= 0.0);
  end;

  I1 := 0;
  for I := 0 to L - 1 do
  begin
    if Flags[I] then
    begin
      System.SetLength(Result, I1 + 1);
      Result[I1] := Poly[I];

      I1 := I1 + 1;
    end;
  end;
end;

function NormalizePolygon(Poly: TPoint2DArray; TrimPnts: Boolean = False): TPoint2DArray;
var
  I, L, N: Integer;
  A1, A2: Float;
  P1, P2, P3: TPoint2D;
  Pnts: TPoint2DArray;
begin
  if TrimPnts then
    Pnts := TrimPoints(Poly)
  else
    Pnts := Poly;

  L := System.Length(Pnts);
  if L < 3 then
  begin
    Result := Pnts;
    Exit; //======>>>>
  end;

  System.SetLength(Result, L);
  Result[0] := Pnts[0];
  Result[1] := Pnts[1];

  P1 := Pnts[0];
  P2 := Pnts[1];
  A1 := GetAngle(P1, P2);

  N := 0;
  for I := 2 to L - 1 do
  begin
    P3 := Pnts[I];
    A2 := GetAngle(P2, P3);

    if IsEqual(A1, A2) then
    begin
      Result[I - 1] := P3;
      N := N + 1;
    end
    else begin
      Result[I] := P3;
    end;

    P1 := P2;
    P2 := P3;
    A1 := A2;
  end;

  if N > 0 then
    System.SetLength(Result, L - N);
end;








//-------------------------------------------------------------------------------------------

function MakeArc(P1, P2, P3: TPoint2D): TArc2D;
var
  ArcData: TArc2D;
  A, B, E: Float;
begin
  with ArcData do
  begin
    if (IsEqual(P1.X, P2.X) and IsEqual(P1.Y, P2.Y)) or
       (IsEqual(P1.X, P3.X) and IsEqual(P1.Y, P3.Y)) or
       (IsEqual(P2.X, P3.X) and IsEqual(P2.Y, P3.Y)) or
       IsCollinear(P1.X, P1.Y, P2.X, P2.Y, P3.X, P3.Y) then
    begin
      R := -1;
    end
    else begin
      A := (P1.X + P2.X) * (P1.X - P2.X) + (P1.Y + P2.Y) * (P1.Y - P2.Y);
      B := (P3.X + P2.X) * (P3.X - P2.X) + (P3.Y + P2.Y) * (P3.Y - P2.Y);
      E := (P1.X - P2.X) * (P3.Y - P2.Y) - (P2.X - P3.X) * (P2.Y - P1.Y);

      if NotEqual(E, 0.0) then
      begin
        Cen.X := (A * (P3.Y - P2.Y) + B * (P2.Y - P1.Y)) / (2 * E);
        Cen.Y := (A * (P2.X - P3.X) + B * (P1.X - P2.X)) / (2 * E);
        R := Distance(P1.X, P1.Y, Cen.X, Cen.Y);
      end
      else R := -2;
    end;

    IsCW := False;
    Kind := akCurve;
  end;

  if ArcData.R > 0 then
  begin
    with ArcData do
    begin
      Ang1 := GetAngle(Cen.X, Cen.Y, P1.X, P1.Y);
      Ang2 := GetAngle(Cen.X, Cen.Y, P3.X, P3.Y);

      if IsPntOnRightSide(P3.X, P3.Y, Line2D(P1.X, P1.Y, P2.X, P2.Y)) then UdMath.Swap(Ang1, Ang2);
      if Ang2 <= Ang1 then Ang2 := FixAngle(Ang2 + 360.0);
    end;
  end;

  Result := ArcData;
end;


function MakeArc(P1, P2: TPoint2D; R: Float; Clock, Big: Boolean): TArc2D;

  function FGetCen(InctPnts: TPoint2DArray): TPoint2D;
  begin
    if IsEqual(P1.X, P2.X) then
    begin
      if P2.Y > P1.Y then
      begin
        if (Clock and Big) or ((not Clock) and (not Big)) then
          Result := LefterPoint(InctPnts[0], InctPnts[1])
        else
          Result := RighterPoint(InctPnts[0], InctPnts[1]);
      end
      else if P2.Y < P1.Y then
      begin
        if (Clock and Big) or ((not Clock) and (not Big)) then
          Result := RighterPoint(InctPnts[0], InctPnts[1])
        else
          Result := LefterPoint(InctPnts[0], InctPnts[1]);
      end;
    end
    else if P2.X > P1.X then
    begin
      if (Clock and Big) or ((not Clock) and (not Big)) then
        Result := HigherPoint(InctPnts[0], InctPnts[1])
      else
        Result := LowerPoint(InctPnts[0], InctPnts[1]);
    end
    else if P2.X < P1.X then
    begin
      if (Clock and Big) or ((not Clock) and (not Big)) then
        Result := LowerPoint(InctPnts[0], InctPnts[1])
      else
        Result := HigherPoint(InctPnts[0], InctPnts[1]);
    end;
  end;

var
  Ln: TLineK;
  Cr: TCircle2D;
  Cen: TPoint2D;
  InctPnts: TPoint2DArray;
begin
  InctPnts := nil;

  if IsEqual(R, 0.0) then
  begin
    Result := Arc2D(P1, 0.0, 0, 0);
    Exit;   //---->>>>
  end;

  if (IsEqual(P1.X, P2.X) and IsEqual(P1.Y, P2.Y)) then
  begin
    Result := Arc2D(P1, -1.0, 0, 0);
    Exit;   //---->>>>
  end;

  if Abs(2 * R) < Distance(P1.X, P1.Y, P2.X, P2.Y) then
  begin
    Result := Arc2D(P1, -2.0, 0, 0);
    Exit;   //---->>>>
  end;


  Cr := Circle2D(P1.X, P1.Y, R);
  Ln := PerpendBisector(P1.X, P1.Y, P2.X, P2.Y);

  InctPnts := Intersection(Ln, Cr);
  if System.Length(InctPnts) <= 0 then Exit;

  if System.Length(InctPnts) = 1 then Cen := InctPnts[0] else Cen := FGetCen(InctPnts);

  Result.R := R;
  Result.Cen := Cen;

  Result.Ang1 := GetAngle(Cen.X, Cen.Y, P1.X, P1.Y);
  Result.Ang2 := GetAngle(Cen.X, Cen.Y, P2.X, P2.Y);

  Result.IsCW := False;
  Result.Kind := akCurve;

  if Clock then UdMath.Swap(Result.Ang1, Result.Ang2);
end;

function MakeArc(P1, P2: TPoint2D; TanAng: Float): TArc2D;
var
  LAng: Float;
  LLn1, LLn2: TLineK;
  LCen: TPoint2D;
  LInctPnts: TPoint2DArray;
begin
  Result := Arc2D(P1, -1.0, 0, 0);
  if IsEqual(P1, P2) then Exit;

  LAng := GetAngle(P1, P2);
  if IsEqual(LAng, TanAng) then Exit;

  LLn1 := LineK(P1, FixAngle(TanAng + 90));
  LLn2 := LineK(MidPoint(P1, P2), FixAngle(LAng + 90));

  LInctPnts := Intersection(LLn1, LLn2); //center
  if System.Length(LInctPnts) <> 1 then Exit;

  LCen := LInctPnts[0];

  Result.R := Distance(P1, LCen);
  Result.Cen := LCen;
  Result.Ang1 := GetAngle(LCen, P1);
  Result.Ang2 := GetAngle(LCen, P2);
  Result.IsCW := IsPntOnLeftSide(ShiftPoint(P1, TanAng, Distance(P1, P2)/2), P1, P2);
  Result.Kind := akCurve;

  if Result.IsCW then
    UdMath.Swap(Result.Ang1, Result.Ang2);
end;


function MakeArc(P1, P2, P3: TPoint2D; BowHeight: Double): TArc2D;
var
  Orn: Integer;
  P12, Cen: TPoint2D;
  PA, PB: TPoint2D;
  DisA, DisB: Double;
  Dis12, Ang12: Double;
begin
  Result := Arc2D(P1, -1.0, 0, 0);
  if IsEqual(BowHeight, 0.0) then Exit;

  Dis12 := Distance(P1, P2);
  if IsEqual(Dis12, 0.0) then Exit;

  Orn := Orientation(P3, P1, P2);
  if Orn = 0.0 then Exit;

  Ang12 := GetAngle(P2, P1);

  P12 := MidPoint(P1, P2);

  PA := ShiftPoint(P12, Ang12 - 90, BowHeight);
  PB := ShiftPoint(P12, Ang12 + 90, BowHeight);

  if UdMath.IsClockWise(P1, P2, P3) = UdMath.IsClockWise(P1, P2, PA) then
  begin
    DisB :=  (Dis12 / 2) * (Dis12 / 2) / BowHeight;
    PB := ShiftPoint(P12, Ang12 + 90, DisB);
    if Orientation(P1, PA, PB) < 0.0 then Swap(P1, P2);
  end
  else begin
    DisA :=  (Dis12 / 2) * (Dis12 / 2) / BowHeight;
    PA := ShiftPoint(P12, Ang12 - 90, DisA);
    if Orientation(P2, PA, PB) < 0.0 then Swap(P1, P2);
  end;

  Cen := MidPoint(PA, PB);

  Result.R := Distance(PA, PB) / 2;
  Result.Cen := Cen;
  Result.Ang1 := GetAngle(Cen, P1);
  Result.Ang2 := GetAngle(Cen, P2);
  Result.IsCW := False;
  Result.Kind := akCurve;
end;

function MakeArc(P1, P2: TPoint2D; IsLeft: Boolean; BowHeight: Double): TArc2D;
var
  A12: Double;
  P12: TPoint2D;
  P3: TPoint2D;
begin
  P12 := MidPoint(P1, P2);
  A12 := GetAngle(P1, P2);

  if IsLeft then
    P3 := ShiftPoint(P12, A12 + 90, 10)
  else
    P3 := ShiftPoint(P12, A12 - 90, 10);

  Result := MakeArc(P1, P2, P3, BowHeight);
end;




function ClipArc(Arc: TArc2D; A1, A2: Float): TArc2D;
var
  In1, In2: Boolean;
  Pnt1, Pnt2, Pnt: TPoint2D;
begin
  Result := Arc2D(Arc.Cen, -1, 0, 0);
  if IsEqual(A1, A2) then Exit; //=======>>>>

  if (IsEqual(A1, Arc.Ang1) and IsEqual(A2, Arc.Ang2)) or
     (IsEqual(A2, Arc.Ang1) and IsEqual(A1, Arc.Ang2)) then
  begin
    Result := Arc;
    Exit; //=======>>>>
  end;

  In1 := UdMath.IsInAngles(A1, Arc.Ang1, Arc.Ang2);
  In2 := UdMath.IsInAngles(A2, Arc.Ang1, Arc.Ang2);

  if not In1 and not In2 then Exit;

  if not In1 or not In2 then
  begin
    Pnt1 := ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R);
    Pnt2 := ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R);

    if not In1 then
    begin
      Pnt := ShiftPoint(Arc.Cen, A1, Arc.R);
      if Distance(Pnt, Pnt1) < Distance(Pnt, Pnt2) then A1 := Arc.Ang1 else A1 := Arc.Ang2;
    end;
    if not In2 then
    begin
      Pnt := ShiftPoint(Arc.Cen, A2, Arc.R);
      if Distance(Pnt, Pnt1) < Distance(Pnt, Pnt2) then A2 := Arc.Ang1 else A2 := Arc.Ang2;
    end;
  end;

  Result.R := Arc.R;
  Result.Cen := Arc.Cen;
  Result.IsCW := Arc.IsCW;
  Result.Kind := Arc.Kind;
  if FixAngle(A1 - Arc.Ang1) < FixAngle(A2 - Arc.Ang1) then
  begin
    Result.Ang1 := A1;
    Result.Ang2 := A2;
  end
  else begin
    Result.Ang1 := A2;
    Result.Ang2 := A1;
  end;
end;

function ClipArc(Arc: TArc2D; P1, P2: TPoint2D): TArc2D;
var
  A1, A2: Float;
begin
  if UdMath.IsValidPoint(P1) then
    A1 := GetAngle(Arc.Cen, P1)
  else
    A1 := Arc.Ang1;

  if UdMath.IsValidPoint(P2) then
    A2 := GetAngle(Arc.Cen, P2)
  else
    A2 := Arc.Ang2;

  Result := ClipArc(Arc, A1, A2);
end;


function MergeArc(Arc1, Arc2: TArc2D; const Epsilon: Float = _Epsilon): TArc2D;
var
  In1, In2: Boolean;
begin
  Result := Arc1;
  if IsEqual(Arc1.R, Arc2.R, Epsilon) and
     IsEqual(Arc1.Cen, Arc2.Cen, Epsilon) then
  begin
    In1 := UdMath.IsInAngles(Arc1.Ang1, Arc2.Ang1, Arc2.Ang2);
    In2 := UdMath.IsInAngles(Arc1.Ang2, Arc2.Ang1, Arc2.Ang2);

    if In1 and In2 then
    begin
      Result := Arc2;
    end
    else if In1 then
    begin
      Result.Ang1 := Arc2.Ang1
    end
    else if In2 then
    begin
      Result.Ang2 := Arc2.Ang2;
    end
    else begin
//      if UdMath.IsInAngles(Arc2.Ang1, Arc1.Ang1, Arc1.Ang2) and
//         UdMath.IsInAngles(Arc2.Ang2, Arc1.Ang1, Arc1.Ang2) then
//        Result := Arc1;
    end;
  end;
end;

function ModifyArc(Arc: TArc2D; A1, A2: Float): TArc2D;
var
  In1, In2: Boolean;
  Pnt1, Pnt2, Pnt: TPoint2D;
begin
  Result := Arc;

  if IsEqual(A1, A2) or
     (IsEqual(A1, Arc.Ang1) and IsEqual(A2, Arc.Ang2)) then
  begin
    Exit;
  end;

  In1 := UdMath.IsInAngles(A1, Arc.Ang1, Arc.Ang2);
  In2 := UdMath.IsInAngles(A2, Arc.Ang1, Arc.Ang2);

  if In1 and In2 then
  begin
    if FixAngle(A1 - Arc.Ang1) < FixAngle(A2 - Arc.Ang1) then
    begin
      Result.Ang1 := A1;
      Result.Ang2 := A2;
    end
    else begin
      Result.Ang1 := A2;
      Result.Ang2 := A1;
    end;
  end
  else begin
    Pnt1 := ShiftPoint(Arc.Cen, Arc.Ang1, Arc.R);
    Pnt2 := ShiftPoint(Arc.Cen, Arc.Ang2, Arc.R);

    if not In1 then
    begin
      Pnt := ShiftPoint(Arc.Cen, A1, Arc.R);
      if Distance(Pnt, Pnt1) < Distance(Pnt, Pnt2) then
        Result.Ang1 := A1 else Result.Ang2 := A1;
    end;

    if not In2 then
    begin
      Pnt := ShiftPoint(Arc.Cen, A2, Arc.R);
      if Distance(Pnt, Pnt1) < Distance(Pnt, Pnt2) then
        Result.Ang1 := A2 else Result.Ang2 := A2;
    end;
  end;
end;

function ModifyArc(Arc: TArc2D; P1, P2: TPoint2D): TArc2D;
var
  A1, A2: Float;
begin
  if UdMath.IsValidPoint(P1) then
    A1 := GetAngle(Arc.Cen, P1)
  else
    A1 := Arc.Ang1;

  if UdMath.IsValidPoint(P2) then
    A2 := GetAngle(Arc.Cen, P2)
  else
    A2 := Arc.Ang2;

  Result := ModifyArc(Arc, A1, A2);
end;




//----------------------------------------------------------------------------

function ClipSegment(Seg: TSegment2D; P1, P2: TPoint2D): TSegment2D;
var
  Ln: TLine2D;
  In1, In2: Boolean;
  Pnt1, Pnt2: TPoint2D;
begin
  if UdMath.IsEqual(P1, P2) then
  begin
    Result := Seg;
    Exit;
  end;

  Ln := Line2D(Seg.P1, Seg.P2);

  if UdMath.IsValidPoint(P1) then
  begin
    Pnt1 := ClosestLinePoint(P1, Ln);
    In1 := IsPntInSegment(Pnt1, Seg);
  end
  else begin
    In1 := True;
    Pnt1 := Seg.P1;
  end;

  if UdMath.IsValidPoint(P2) then
  begin
    Pnt2 := ClosestLinePoint(P2, Ln);
    In2 := IsPntInSegment(Pnt2, Seg);
  end
  else begin
    In2 := True;
    Pnt2 := Seg.P2;
  end;

  if In1 and In2 then
  begin
    Result := Segment2D(Pnt1, Pnt2);
  end
  else begin
    if In1 then
    begin
      if Distance(Pnt2, Seg.P1) < Distance(Pnt2, Seg.P2) then
        Result := Segment2D(Pnt1, Seg.P1)
      else
        Result := Segment2D(Pnt1, Seg.P2);
    end else
    if In2 then
    begin
      if Distance(Pnt1, Seg.P1) < Distance(Pnt1, Seg.P2) then
        Result := Segment2D(Pnt2, Seg.P1)
      else
        Result := Segment2D(Pnt2, Seg.P2);
    end
    else begin
      Result := Seg;
    end;
  end;
end;

function MergeSegment(Seg1, Seg2: TSegment2D; const AngEpsilon: Float = 0.1; const DEpsilon: Float = 0.1): TSegment2D;

  function FCheckSeg(var ASeg: TSegment2D; var Ang: Float): Boolean;
  begin
    Result := False;
    Ang := GetAngle(ASeg.P1, ASeg.P2);

    if Ang > 180 then
    begin
      Ang := Ang - 180;
      Swap(ASeg.P1, ASeg.P2);

      Result := not Result;
    end;

    if IsEqual(Ang, 180.0, AngEpsilon) then
    begin
      Ang := 0;
      Swap(ASeg.P1, ASeg.P2);

      Result := not Result;
    end;
  end;

  function FGetSegD(var ASeg: TSegment2D): Float;
  var
    A: Float;
    B: Float;
    IsH, IsV: Boolean;
  begin
    A := GetAngle(ASeg.P1, ASeg.P2);
    A := UdMath.SgnAngle(A, AngEpsilon);

    B := LineK(ASeg.P1, ASeg.P2).B;

    IsH := UdMath.IsEqual(A, 0.0, AngEpsilon);
    IsV := UdMath.IsEqual(A, 90.0, AngEpsilon);

    if IsH or IsV then
    begin
      if IsH then
        B := (ASeg.P1.Y + ASeg.P2.Y) / 2
      else
        B := (ASeg.P1.X + ASeg.P2.X) / 2;
      Result := B
    end
    else begin
      Result := B * Abs(SinD(A - 90));
    end;
  end;

var
  OK: Boolean;
  D1, D2: Float;
  A1, A2: Float;
  In1, In2: Boolean;
  LSeg1, LSeg2: TSegment2D;
  Swaped1, Swaped2: Boolean;
begin
  Result := Seg1;

  LSeg1 := Seg1;
  LSeg2 := Seg2;

  Swaped1 := FCheckSeg(LSeg1, A1);
  Swaped2 := FCheckSeg(LSeg2, A2);

  if NotEqual(A1, A2, AngEpsilon) then Exit;

  D1 := FGetSegD(LSeg1);
  D2 := FGetSegD(LSeg2);

  if NotEqual(D1, D2, DEpsilon) then Exit;


  In1 := IsPntInSegment(LSeg2.P1, LSeg1);
  In2 := IsPntInSegment(LSeg2.P2, LSeg1);

  OK := False;

  if In1 and not In2 then
  begin
    LSeg1.P2 := LSeg2.P2;
    OK := True;
  end else
  if not In1 and In2 then
  begin
    LSeg1.P1 := LSeg2.P1;
    OK := True;
  end else
  if not In1 and not In2 then
  begin
    if IsEqual(GetAngle(LSeg2.P1, LSeg1.P1),  GetAngle(LSeg1.P2, LSeg2.P2), 5) then
    begin
      LSeg1 := Seg2;
      Swaped1 := Swaped2;
      OK := True;
    end;
  end;

  if OK then
  begin
    if Swaped1 then Swap(LSeg1.P1, LSeg1.P2);
    Result := LSeg1;
  end;
end;


function ModifySegment(Seg: TSegment2D; P1, P2: TPoint2D): TSegment2D;
var
  Ln: TLine2D;
  Pnt1, Pnt2: TPoint2D;
begin
  if UdMath.IsEqual(P1, P2) then
  begin
    Result := Seg;
    Exit;
  end;

  Ln := Line2D(Seg.P1, Seg.P2);

  if UdMath.IsValidPoint(P1) then
    Pnt1 := ClosestLinePoint(P1, Ln)
  else
    Pnt1 := Seg.P1;

  if UdMath.IsValidPoint(P2) then
    Pnt2 := ClosestLinePoint(P2, Ln)
  else
    Pnt2 := Seg.P2;

  if IsEqual(UdMath.SgnAngle(GetAngle(Seg.P1, Seg.P2), 1), UdMath.SgnAngle(GetAngle(Pnt1, Pnt2), 1), 1) then
  begin
    Result := Segment2D(Pnt1, Pnt2);
  end
  else begin
    Result := Segment2D(Pnt2, Pnt1);
  end;
end;



function MergeRect(Rect1, Rect2: TRect2D): TRect2D;
begin
  Result := Rect2;

  if Result.X1 > Rect1.X1  then Result.X1 := Rect1.X1;
  if Result.X2 < Rect1.X2  then Result.X2 := Rect1.X2;
  if Result.Y1 > Rect1.Y1  then Result.Y1 := Rect1.Y1;
  if Result.Y2 < Rect1.Y2  then Result.Y2 := Rect1.Y2;
end;


procedure GetSegmentBD(Seg: TSegment2D; out B, D: Float; const AEpsion: Float = 0.01);
var
  A: Float;
  LIsH, LIsV: Boolean;
begin
  A := GetAngle(Seg.P1, Seg.P2);
  A := UdMath.SgnAngle(A, AEpsion);

  B := LineK(Seg.P1, Seg.P2).B;

  LIsH := UdMath.IsEqual(A, 0.0, AEpsion);
  LIsV := UdMath.IsEqual(A, 90.0, AEpsion);

  if LIsH or LIsV then
  begin
    if LIsH then
      B := (Seg.P1.Y + Seg.P2.Y) / 2
    else
      B := (Seg.P1.X + Seg.P2.X) / 2;
    D := B
  end
  else
  begin
    D := B * Abs(SinD(A - 90));
  end;
end;

function GetSegmentD(Seg: TSegment2D; const AEpsion: Float = 0.01): Float;
var
  B: Float;
begin
  GetSegmentBD(Seg, B, Result, AEpsion);
end;





//------------------------------------------------------------------------------------------------
(*
function BoundHull(Seg: TSegment2D; Ang: Float): TBound2D;
var
  Ln1, Ln2: TLineK;
  PX1, PX2, PY1, PY2: TPoint2D;
  InctPnts1, InctPnts2, InctPnts3, InctPnts4: TPoint2DArray;
begin
  InitBound(Result);
  Ang := FixAngle(Ang);

  Ln1 := LineK(Seg.P1, Ang);
  Ln2 := LineK(Seg.P1, Ang + 90);

  PX1 := ClosestLinePoint(Seg.P1, Ln1);
  PX2 := ClosestLinePoint(Seg.P2, Ln1);

  PY1 := ClosestLinePoint(Seg.P1, Ln2);
  PY2 := ClosestLinePoint(Seg.P2, Ln2);

  InctPnts1 := Intersection(LineK(PX1, Ang + 90), LineK(PY1, Ang));
  InctPnts2 := Intersection(LineK(PX2, Ang + 90), LineK(PY1, Ang));
  InctPnts3 := Intersection(LineK(PX2, Ang + 90), LineK(PY2, Ang));
  InctPnts4 := Intersection(LineK(PX1, Ang + 90), LineK(PY2, Ang));

  if (System.Length(InctPnts1) = 1) and (System.Length(InctPnts2) = 1) and
     (System.Length(InctPnts3) = 1) and (System.Length(InctPnts4) = 1) then
  begin
    Result[0] := InctPnts1[0];
    Result[1] := InctPnts2[0];
    Result[2] := InctPnts3[0];
    Result[3] := InctPnts4[0];
  end;
end;

function BoundHull(Cir : TCircle2D; Ang: Float): TBound2D;
begin

end;

function BoundHull(Arc : TArc2D; Ang: Float): TBound2D;
begin

end;

function BoundHull(Poly: TPoint2DArray; Ang: Float): TBound2D;
begin

end;

function BoundHull(Segarcs: TSegarc2DArray; Ang: Float): TBound2D;
begin

end;
*)

//------------------------------------------------------------------------------------------------

function SortPoints(var A: TPoint2DArray; B: TPoint2D): Boolean;
var
  I: Integer;
  J: Integer;
  T: TPoint2D;
begin
  Result := False;
  if System.Length(A) <= 0 then Exit;

  for I := Low(A) to High(A) - 1 do
  begin
    for J := High(A) downto I + 1 do
    begin
      if Distance(A[I], B) > Distance(A[J], B) then
      begin
        T := A[I];
        A[I] := A[J];
        A[J] := T;
      end;
    end;
  end;

  Result := True;
end;

function SortPoints(var A: TPoint2DArray; B: TPoint2D; Ang: Float): Boolean;
var
  I: Integer;
  J: Integer;
  T: TPoint2D;
  D1, D2: Float;
begin
  Result := False;
  if System.Length(A) <= 0 then Exit;

  for I := Low(A) to High(A) - 1 do
  begin
    for J := High(A) downto I + 1 do
    begin
      D1 := Distance(A[I], B);
      D2 := Distance(A[J], B);

      if NotEqual(GetAngle(B, A[I]), Ang, 1) then D1 := -D1;
      if NotEqual(GetAngle(B, A[J]), Ang, 1) then D2 := -D2;

      if D1 > D2 then
      begin
        T := A[I];
        A[I] := A[J];
        A[J] := T;
      end;
    end;
  end;

  Result := True;
end;

function SortPoints(var A: TPoint2DArray; Arc: TArc2D): Boolean;
var
  I: Integer;
  J: Integer;
  T: TPoint2D;
begin
  Result := False;
  if System.Length(A) <= 0 then Exit;

  if Arc.IsCW then
  begin
    for I := Low(A) to High(A) - 1 do
    begin
      for J := High(A) downto I + 1 do
      begin
        if FixAngle( Arc.Ang2 - GetAngle(Arc.Cen, A[I]) ) >
           FixAngle( Arc.Ang2 - GetAngle(Arc.Cen, A[J]) ) then
        begin
          T := A[I];
          A[I] := A[J];
          A[J] := T;
        end;
      end;
    end;
  end
  else begin
    for I := Low(A) to High(A) - 1 do
    begin
      for J := High(A) downto I + 1 do
      begin
        if FixAngle( GetAngle(Arc.Cen, A[I]) - Arc.Ang1 ) >
           FixAngle( GetAngle(Arc.Cen, A[J]) - Arc.Ang1 ) then
        begin
          T := A[I];
          A[I] := A[J];
          A[J] := T;
        end;
      end;
    end;
  end;

  Result := True;
end;

function SortPoints(var A: TPoint2DArray; Ell: TEllipse2D): Boolean;
var
  I: Integer;
  J: Integer;
  T: TPoint2D;
begin
  Result := False;
  if System.Length(A) <= 0 then Exit;

  if Ell.IsCW then
  begin
    for I := Low(A) to High(A) - 1 do
    begin
      for J := High(A) downto I + 1 do
      begin
        if FixAngle( Ell.Ang2 - CenAngToEllAng(Ell.Rx, Ell.Ry, GetAngle(Ell.Cen, A[I]) - Ell.Rot) ) >
           FixAngle( Ell.Ang2 - CenAngToEllAng(Ell.Rx, Ell.Ry, GetAngle(Ell.Cen, A[J]) - Ell.Rot) ) then
        begin
          T := A[I];
          A[I] := A[J];
          A[J] := T;
        end;
      end;
    end;
  end
  else begin
    for I := Low(A) to High(A) - 1 do
    begin
      for J := High(A) downto I + 1 do
      begin
        if FixAngle( CenAngToEllAng(Ell.Rx, Ell.Ry, GetAngle(Ell.Cen, A[I]) - Ell.Rot) - Ell.Ang1 ) >
           FixAngle( CenAngToEllAng(Ell.Rx, Ell.Ry, GetAngle(Ell.Cen, A[J]) - Ell.Rot) - Ell.Ang1 ) then
        begin
          T := A[I];
          A[I] := A[J];
          A[J] := T;
        end;
      end;
    end;
  end;

  Result := True;
end;

end.