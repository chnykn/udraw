{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfConvert;

{$I UdDefs.INC}

interface

uses
  Windows, Classes;

type
  TCADVersion = (ACAD9, ACAD10, ACAD12, ACAD13, ACAD14, ACAD2000, ACAD2004, ACAD2007, ACAD2010);

function DirDxfToDwg(const AInputDir, AOutputDir: string; AOutVersion: TCADVersion = ACAD2000; ARecurseInputDir: Boolean = False): Boolean; overload;
function DirDwgToDxf(const AInputDir, AOutputDir: string; AOutVersion: TCADVersion = ACAD2000; ARecurseInputDir: Boolean = False): Boolean; overload;

function DxfToDwg(const AInputFile, AOutputFile: string; var AErrorMsg: string; AOutVersion: TCADVersion = ACAD2004): Boolean; overload;
function DwgToDxf(const AInputFile, AOutputFile: string; var AErrorMsg: string; AOutVersion: TCADVersion = ACAD2000): Boolean; overload;


implementation

uses
  SysUtils, Forms, UdUtils;


function CADVerToStr(AValue: TCADVersion): string;
begin
  case AValue of
    ACAD9    : Result := 'ACAD9';
    ACAD10   : Result := 'ACAD10';
    ACAD12   : Result := 'ACAD12';
    ACAD13   : Result := 'ACAD13';
    ACAD14   : Result := 'ACAD14';
    ACAD2000 : Result := 'ACAD2000';
    ACAD2004 : Result := 'ACAD2004';
    ACAD2007 : Result := 'ACAD2007';
    ACAD2010 : Result := 'ACAD2010';
  end;
end;


(*
Teigha File Converter
---------------------------
Command Line Format is:
  Quoted Input Folder
  Quoted Output Folder
  Output_version
    {"ACAD9","ACAD10","ACAD12",
     "ACAD13","ACAD14",
     "ACAD2000","ACAD2004",
     "ACAD2007","ACAD2010"}
  Output File type
    {"DWG","DXF","DXB"}
  Recurse Input Folder
    {"0","1"}
  Audit each file
    {"0","1"}
  [optional] Input files filter
    (default: "*.DWG;*.DXF")
*)

//AInputDir must be different than AOutputDir
function TeighaConvert(const AInputDir, AOutputDir: string; AOutVersion, AOutFileType: string;
                      ARecurseInputDir: Boolean = False; AInputFilesFilter: string = '*.DWG;*.DXF'): Boolean;

  function _BoolToStr(AValue: Boolean): string;
  begin
    if AValue then Result := '1' else Result := '0';
  end;

const
  EXE_DIR = 'ODA\';
  EXE_NAME = 'TeighaFileConverter.exe';
var
  LExcd: DWORD;
  LTimeOut: Cardinal;
  LCreationFlags: Cardinal;
  LStInfo: STARTUPINFO;
  LProcInfo: PROCESS_INFORMATION;
  LExeName, LExePath, LCommand: string;
begin
  LExePath := ExtractFilePath(Application.ExeName) + EXE_DIR;
  LExeName := LExePath + EXE_NAME;
  LCommand := QuotedStr(LExeName) + #32 + QuotedStr(AInputDir) + #32 + QuotedStr(AOutputDir) + #32 +
                               QuotedStr(AOutVersion) + #32 + QuotedStr(AOutFileType) + #32 +
                               QuotedStr(_BoolToStr(ARecurseInputDir)) + #32 + QuotedStr('0'){Audit each file: True};// + #32 +
                               //AInputFilesFilter;

  ZeroMemory(@LProcInfo, Sizeof(LProcInfo));
  ZeroMemory(@LStInfo, Sizeof(LStInfo));
  LStInfo.cb := Sizeof(LStInfo);
  LStInfo.wShowWindow := SW_HIDE;
  LStInfo.dwFlags := STARTF_USESHOWWINDOW;

{
function CreateProcess(lpApplicationName: PWideChar; lpCommandLine: PWideChar;
  lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
  bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
  lpCurrentDirectory: PWideChar; const lpStartupInfo: TStartupInfo;
  var lpProcessInformation: TProcessInformation): BOOL; stdcall;
}
  LCreationFlags := NORMAL_PRIORITY_CLASS or CREATE_DEFAULT_ERROR_MODE;
  Result := CreateProcess(PChar(LExeName), PChar(LCommand), nil, nil, False,
                          LCreationFlags, nil, PChar(LExePath), LStInfo, LProcInfo);


  if Result then
  begin
    if LProcInfo.hThread <> 0 then CloseHandle(LProcInfo.hThread);

    LExcd := STILL_ACTIVE;
    LTimeOut := INFINITE;

    if Windows.WaitForSingleObject(LProcInfo.hProcess, LTimeOut) = WAIT_TIMEOUT then
    begin
      TerminateProcess(LProcInfo.hProcess, 1);
      CloseHandle(LProcInfo.hProcess);
      raise EOSError.Create('Process timed out')
    end
    else begin
      GetExitCodeProcess(LProcInfo.hProcess, LExcd);
      CloseHandle(LProcInfo.hProcess);
    end;

    {
    LExcd := STILL_ACTIVE;
    while LExcd = STILL_ACTIVE do
    begin
      Sleep(200);
      GetExitCodeProcess(LProcInfo.hProcess, LExcd);
    end;
    }

    Result := LExcd = 0;
  end;
end;


function DirDxfToDwg(const AInputDir, AOutputDir: string; AOutVersion:TCADVersion = ACAD2000; ARecurseInputDir: Boolean = False): Boolean;
begin
  Result := TeighaConvert(AInputDir, AOutputDir, CADVerToStr(AOutVersion), 'DWG', ARecurseInputDir, '*.DXF');
end;

function DirDwgToDxf(const AInputDir, AOutputDir: string; AOutVersion: TCADVersion = ACAD2000; ARecurseInputDir: Boolean = False): Boolean;
begin
  Result := TeighaConvert(AInputDir, AOutputDir, CADVerToStr(AOutVersion), 'DXF', ARecurseInputDir, '*.DWG');
end;




type
  TUdConvFileKind = (cfkDxf2Dwg, cfkDwg2Dxf);

function FileConvert(const AInputFile, AOutputFile: string; AConvKind: TUdConvFileKind; var AErrorMsg: string; AOutVersion: TCADVersion = ACAD2000): Boolean;

  function _GetErrorMsgFromFile(AErrFile: string): string;
  var
    I, N: Integer;
    LStr: string;
    LStrs: TStringList;
  begin
    Result := '';
    if not FileExists(AErrFile) then Exit;

    LStrs := TStringList.Create;
    try
      LStrs.LoadFromFile(AErrFile);
      if LStrs.Count > 1 then N := 1 else N := 0;

      for I := N to LStrs.Count - 1 do
      begin
        LStr := Trim(LStrs[I]);
        if LStr <> '' then
        begin
          if Result <> '' then Result := Result + #13#10;
          Result := Result + LStr;
        end;
      end;
    finally
      LStrs.Free;
    end;
  end;

var
  LOk: Boolean;
  LAppPath: string;
  LTempPath: string;
  LInputDir, LOutputDir: string;
  LInputFile, LOutputFile: string;
begin
  Result := False;
  if not FileExists(AInputFile) then
  begin
    AErrorMsg := QuotedStr(AInputFile) + '不存在';
    Exit;
  end;

  LOk := True;
  case AConvKind of
    cfkDxf2Dwg: if UpperCase(SysUtils.ExtractFileExt(AInputFile)) <> '.DXF' then LOk := False; //====>>>>>>
    cfkDwg2Dxf: if UpperCase(SysUtils.ExtractFileExt(AInputFile)) <> '.DWG' then LOk := False; //====>>>>>>
  end;

  if not LOk then
  begin
    AErrorMsg := QuotedStr(AInputFile) + '文件格式不正确';
    Exit;
  end;


  LAppPath := SysUtils.ExtractFilePath(Application.ExeName);
  LTempPath := LAppPath + 'Temp\';
  if not DirectoryExists(LTempPath) then
  begin
    if not ForceDirectories(LTempPath) then LTempPath := UdUtils.GetTempPath();
  end;

  LInputDir  := LTempPath + UdUtils.GetGUID(True);
  LOutputDir := LTempPath + UdUtils.GetGUID(True);

  if not SysUtils.ForceDirectories(LInputDir) or
     not SysUtils.ForceDirectories(LOutputDir) then
  begin
    AErrorMsg := '不能创建临时目录:' + QuotedStr(LInputDir);
    Exit;
  end;


  LInputFile  := LInputDir  + '\' + SysUtils.ExtractFileName(AInputFile);
  LOutputFile := LOutputDir + '\' + SysUtils.ExtractFileName(AInputFile);

  case AConvKind of
    cfkDxf2Dwg: LOutputFile := SysUtils.ChangeFileExt(LOutputFile, '.DWG');
    cfkDwg2Dxf: LOutputFile := SysUtils.ChangeFileExt(LOutputFile, '.DXF');
  end;

  if not CopyFile(PChar(AInputFile), PChar(LInputFile), False) then
  begin
    AErrorMsg := '不能复制文件:' + QuotedStr(AInputFile);
    Exit;
  end;

  case AConvKind of
    cfkDxf2Dwg: Result := DirDxfToDwg(LInputDir, LOutputDir, AOutVersion, False);
    cfkDwg2Dxf: Result := DirDwgToDxf(LInputDir, LOutputDir, AOutVersion, False);
  end;

  if Result then
  begin
    if FileExists(LOutputFile + '.err') then
    begin
      Result := False;
      AErrorMsg := _GetErrorMsgFromFile(LOutputFile + '.err');
    end
    else
    begin
      Result := MoveFile(PChar(LOutputFile), PChar(AOutputFile));
      if not Result then
        AErrorMsg := '移动文件失败:' + QuotedStr(LOutputFile);
    end;
  end
  else
    AErrorMsg := '创建进程失败';

  ForceDeleteDirectory(LInputDir);
  ForceDeleteDirectory(LOutputDir);
end;


function DxfToDwg(const AInputFile, AOutputFile: string; var AErrorMsg: string; AOutVersion: TCADVersion = ACAD2004): Boolean;
begin
  Result := FileConvert(AInputFile, AOutputFile, cfkDxf2Dwg, AErrorMsg, AOutVersion);
end;

function DwgToDxf(const AInputFile, AOutputFile: string; var AErrorMsg: string; AOutVersion: TCADVersion = ACAD2000): Boolean;
begin
  Result := FileConvert(AInputFile, AOutputFile, cfkDwg2Dxf, AErrorMsg, AOutVersion);
end;



end.