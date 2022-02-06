{$DEFINE UdTypes}

{$DEFINE DoublePrecision}
//{$DEFINE SinglePrecision}
//{$DEFINE ExtendedPrecision}

{$IF COMPILERVERSION > 17 } { Delphi 2005 and above }
  {$DEFINE SUPPORTS_INLINE}
{$IFEND}