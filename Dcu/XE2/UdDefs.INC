
{
VER130 - Delphi 5
VER140 - Delphi 6
VER150 - Delphi 7
VER160 - Delphi 8
VER170 - Delphi 2005
VER180 - Delphi 2006
VER180 - Delphi 2007
VER185 - Delphi 2007
VER200 - Delphi 2009
VER210 - Delphi 2010
VER220 - Delphi XE
}

//{$DEFINE Async}
{$DEFINE MultiCanvases}

{$IF COMPILERVERSION >= 17 } { Delphi 2005 and above }
  {$DEFINE SUPPORTS_INLINE}
  {$DEFINE SUPPORTS_STATIC}
  {$DEFINE D2005UP}
{$IFEND}

{$IF COMPILERVERSION >= 20.0 } { Delphi 2009 and above }
  {$DEFINE D2009UP}
  {$DEFINE SUPPORT_UNICODE}
{$IFEND}


{$IF COMPILERVERSION >= 21.0 } { Delphi 2010 and above }
  {$DEFINE D2010UP}
  {$DEFINE SUPPORT_UNICODE}
{$IFEND}



//---------------------------------------------------

{$IFDEF D2010UP}
//  {$DEFINE GDIPLUS}
{$ENDIF}


//{$DEFINE DXF12}
//{$DEFINE DEBUG}  //Debug

//{$DEFINE TRIAL}

//{$DEFINE FULLVER}


//----------------------Vers-----------------------------

{$DEFINE UdPen_01}
//{$DEFINE UdPen_02}

{$DEFINE UdBrush_01}
//{$DEFINE UdBrush_02}

{$DEFINE UdFont_01}
//{$DEFINE UdFont_02}



{$DEFINE UdEntity_01}
//{$DEFINE UdEntity_02}
//{$DEFINE UdEntity_03}


{$DEFINE UdDoc_01}
//{$DEFINE UdDoc_02}
//{$DEFINE UdDoc_03}


{$DEFINE UdLayer_01}
//{$DEFINE UdLayer_02}
//{$DEFINE UdLayer_03}

{$DEFINE UdLayers_01}
//{$DEFINE UdLayers_02}
//{$DEFINE UdLayers_03}



{$DEFINE UdColor_01}
//{$DEFINE UdColor_02}
//{$DEFINE UdColor_03}

{$DEFINE UdColors_01}
//{$DEFINE UdColors_02}
//{$DEFINE UdColors_03}



{$DEFINE UdLType_01}
//{$DEFINE UdLType_02}
//{$DEFINE UdLType_03}

{$DEFINE UdLTypes_01}
//{$DEFINE UdLTypes_02}
//{$DEFINE UdLTypes_03}



{$DEFINE UdLwt_01}
//{$DEFINE UdLwt_02}
//{$DEFINE UdLwt_03}

{$DEFINE UdLwts_01}
//{$DEFINE UdLwts_02}
//{$DEFINE UdLwts_03}


{$DEFINE UdTxtStyle_01}
//{$DEFINE UdTxtStyle_02}
//{$DEFINE UdTxtStyle_03}


{$DEFINE UdDimStyle_01}
//{$DEFINE UdDimStyle_02}
//{$DEFINE UdDimStyle_03}


{$DEFINE UdPntStyle_01}
//{$DEFINE UdPntStyle_02}
//{$DEFINE UdPntStyle_03}


{$DEFINE UdPreferences_01}
//{$DEFINE UdPreferences_02}
//{$DEFINE UdPreferences_03}
