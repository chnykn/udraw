{
  This file is part of the DelphiCAD SDK

  Copyright:
   (c) 2014-2015, chnykn@163.com. All rights reserved.
}

unit UdDxfReadBlocks;

{$I UdDefs.INC}

interface

uses
  Classes,
  UdTypes, UdDocument,
  UdDxfTypes, UdDxfReadSection;

type

  TUdDxfReadBlocks = class(TUdDxfReadSection)
  protected
    procedure AddBlock();

  public
    constructor Create(AOwner: TObject);  override;
    destructor Destroy; override;

    procedure Execute(); override;
  end;


implementation

uses
  SysUtils,
  UdDxfReader, UdDxfReadEntites, UdDxfReadTables, UdLayout, UdBlock ;


{ TUdDxfReadBlocks }

constructor TUdDxfReadBlocks.Create(AOwner: TObject);
begin
  inherited;
end;

destructor TUdDxfReadBlocks.Destroy;
begin
  inherited;
end;



procedure TUdDxfReadBlocks.AddBlock();
var
  N, M, LFlag: Integer;
  LOrigin: TPoint2D;
  LHandle, LLayer, LStr: string;
  LBlock: TUdBlock;
  LLayout: TUdLayout;
  LDxfEntites: TUdDxfReadEntites;
  LXrefFile, LBlockName, LUpBlockName, LDescpt: string;
begin
  LFlag := 0;
  LBlockName := '';
  LOrigin.X := 0; LOrigin.Y := 0;

  repeat
    Self.ReadCurrentRecord();

    case Self.CurrRecord.Code of
      330: LHandle   := Self.CurrRecord.Value;
      1  : LXrefFile   := Self.CurrRecord.Value;
      2,3:
        begin
          LBlockName := Trim(Self.CurrRecord.Value);
          LUpBlockName := UpperCase(LBlockName);
          
          if (Pos('MODEL_SPACE', LUpBlockName) > 0) or
             (Pos('PAPER_SPACE', LUpBlockName) > 0) then
          begin
            LBlockName := '';
            while Self.CurrRecord.Code <> 0 do Self.ReadCurrentRecord();

            M := -1;
            
            N := Pos('PAPER_SPACE', LUpBlockName);
            if N > 0 then
            begin
              LStr := Copy(LUpBlockName, N + Length('PAPER_SPACE'), Length(LUpBlockName));
              M := StrToIntDef(LStr, -1);
            end;

            if M >= 0 then
            begin
              LLayout := TUdDxfReader(FOwner).GetLayout(LHandle);
              if Assigned(LLayout) then
              begin
                LDxfEntites := TUdDxfReadEntites.Create(FOwner);
                try
                  LDxfEntites.IsBlock := True;
                  LDxfEntites.ReadEntities(LLayout.Entities);
                finally
                  LDxfEntites.Free;
                end;
              end;
            end;

            Break;
          end; 
        end;
      4  : LDescpt   := Self.CurrRecord.Value;
      8  : LLayer    := Self.CurrRecord.Value;
      10 : LOrigin.X := StrToFloatDef(Self.CurrRecord.Value, 0);
      20 : LOrigin.Y := StrToFloatDef(Self.CurrRecord.Value, 0);
      70 : LFlag     := StrToIntDef(Self.CurrRecord.Value, 0);
    end;
  until (Self.CurrRecord.Code = 0);


  if (LBlockName = '') then Exit; //========>>>>>>

  LUpBlockName := UpperCase(LBlockName);
  if (Pos('*D', LUpBlockName) = 1) then Exit; //========>>>>>>


//  FIDNames.Add(LHandle, LUpBlockName);
  Self.AddBlockName(LHandle, LUpBlockName);


  LBlock := TUdBlock.Create(Self.Document, True);
  LBlock.Name := LBlockName;
  LBlock.Description := LDescpt;
  LBlock.Origin := LOrigin;
  LBlock.XrefFile := LXrefFile;

  if LFlag > 0 then ;

  LDxfEntites := TUdDxfReadEntites.Create(FOwner);
  try
    LDxfEntites.IsBlock := True;
    LDxfEntites.ReadEntities(LBlock.Entities);
  finally
    LDxfEntites.Free;
  end;

  if LBlock.Entities.Count > 0 then
    Self.Document.Blocks.Add(LBlock)
  else
    LBlock.Free;
end;


procedure TUdDxfReadBlocks.Execute();
begin
  repeat
    Self.ReadCurrentRecord();

    if (Self.CurrRecord.Code = 0) and (Self.CurrRecord.Value = 'BLOCK') then
    begin
      Self.AddBlock();
    end;

  until (Self.CurrRecord.Value = 'ENDSEC') or (Self.CurrRecord.Value = 'EOF');

//  Self.SetDimStyleArrow();
end;







end.