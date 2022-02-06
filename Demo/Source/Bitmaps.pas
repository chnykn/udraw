

unit Bitmaps;

interface

uses
  Classes, Controls, ImgList;

type
  TBitmapsModule = class(TDataModule)
    imgsStd: TImageList;
    ImgsLayer: TImageList;
    imgsDraw: TImageList;
    imgsModify: TImageList;
    imgsDim: TImageList;
    imgsSnap: TImageList;
    imgsInquiry: TImageList;
    imgsDisOrder: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BitmapsModule: TBitmapsModule;

implementation

{$R *.dfm}


end.
