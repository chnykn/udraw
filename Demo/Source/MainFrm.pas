
(**************************************************************

  Demo of DelphiCAD


                                                --YangKing
***************************************************************)


unit MainFrm;


interface

uses
  Windows, Classes, Controls, Graphics, Forms,
  StdCtrls, ExtCtrls, Menus, Dialogs, ImgList,


  TB2Item, TB2Dock, TB2Toolbar,
  SpTBXSkins, SpTBXItem, SpTBXDkPanels, SpTBXEditors, SpTBXControls, SpTBXExtEditors,

  UdTypes, UdGTypes, UdConsts, UdEvents, UdEntity,
  UdColor, UdLinetype, UdLineWeight, UdLayer, UdLayout, UdDocument,
  UdCmdLine, UdDrawPanel, PropsFrm,

  UdLayerComboBox, UdColorComboBox, UdLntypComboBox, UdLwtComboBox;
  

type
  TMainForm = class(TForm)

    TopDock: TSpTBXDock;
    RightDock: TSpTBXDock;
    LeftDock: TSpTBXDock;

    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StatusBar: TSpTBXStatusBar;
    pnlClient: TPanel;

    //=============================================================
    {Menu....}//
    MenuToolbar: TSpTBXToolbar;

    {File..}
    mnFile: TSpTBXSubmenuItem;
    mbNew: TSpTBXItem;
    mbOpen: TSpTBXItem;
    mbSave: TSpTBXItem;
    mbPreview: TSpTBXItem;
    mbPrint: TSpTBXItem;
    mbHistory: TSpTBXSubmenuItem;
    mbExit: TSpTBXItem;
    TBXSeparatorItem2: TSpTBXSeparatorItem;
    TBXSeparatorItem1: TSpTBXSeparatorItem;
    TBXSeparatorItem3: TSpTBXSeparatorItem;
    TBXSeparatorItem40: TSpTBXSeparatorItem;


    {Edit..}
    mnEdit: TSpTBXSubmenuItem;
    mbRedo: TSpTBXItem;
    mbUndo: TSpTBXItem;
    mbCut: TSpTBXItem;
    mbCopyClip: TSpTBXItem;
    mbClear: TSpTBXItem;
    mbSelectAll: TSpTBXItem;
    TBXSeparatorItem4: TSpTBXSeparatorItem;
    TBXSeparatorItem11: TSpTBXSeparatorItem;


    {Format..}
    mnFormat: TSpTBXSubmenuItem;
    mbLayer: TSpTBXItem;
    mbColor: TSpTBXItem;
    mbLinetype: TSpTBXItem;
    mbLineWeight: TSpTBXItem;
    mbTextStyle: TSpTBXItem;
    mbDimentionStyle: TSpTBXItem;
    mbPointStyle: TSpTBXItem;
    mbUnits: TSpTBXItem;
    TBXSeparatorItem9: TSpTBXSeparatorItem;
    TBXSeparatorItem10: TSpTBXSeparatorItem;


    {View..}
    mnView: TSpTBXSubmenuItem;
    mbPan: TSpTBXItem;
    mbPan2P: TSpTBXItem;
    mbZoomAll: TSpTBXItem;
    mbZoomOut: TSpTBXItem;
    mbZoomIn: TSpTBXItem;
    mbZoomWindow: TSpTBXItem;
    mbZoomReal: TSpTBXItem;
    mbZoomPrev: TSpTBXItem;
    mbToolbar: TSpTBXItem;
    mbDispaly: TSpTBXItem;
    TBXSeparatorItem5: TSpTBXSeparatorItem;


    {Tools..}
    mnTools: TSpTBXSubmenuItem;
    mbDisOrder: TSpTBXSubmenuItem;
    mbSendBack: TSpTBXItem;
    mbBringFront: TSpTBXItem;
    mbInquiry: TSpTBXSubmenuItem;
    mbArea: TSpTBXItem;
    mbDistance: TSpTBXItem;
    mbLocatePoint: TSpTBXItem;
    mbList: TSpTBXItem;
    mbLoadApp: TSpTBXItem;
    mbRunScript: TSpTBXItem;
    mbSelection: TSpTBXItem;
    mbDraftingSettinh: TSpTBXItem;
    mbOptions: TSpTBXItem;
    mbCalculator: TSpTBXItem;
    mbSkins: TSpTBXSubmenuItem;
    SpTBXSkinGroupItem1: TSpTBXSkinGroupItem;
    TBXSeparatorItem66: TSpTBXSeparatorItem;
    TBXSeparatorItem8: TSpTBXSeparatorItem;
    TBXSeparatorItem16: TSpTBXSeparatorItem;
    TBXSeparatorItem17: TSpTBXSeparatorItem;


    {Draw..}
    mnDraw: TSpTBXSubmenuItem;
    mbLine: TSpTBXItem;
    mbRay: TSpTBXItem;
    mbXLine: TSpTBXItem;
    mbPolyline: TSpTBXItem;
    mbPolygon: TSpTBXItem;
    mbSpline: TSpTBXItem;
    mbDount: TSpTBXItem;
    mbArc: TSpTBXSubmenuItem;
    mbArcSCE: TSpTBXItem;
    mbArc3P: TSpTBXItem;
    mbArcSCA: TSpTBXItem;
    mbArcSCL: TSpTBXItem;
    mbArcCSL: TSpTBXItem;
    mbArcCSA: TSpTBXItem;
    mbArcCSE: TSpTBXItem;
    mbArcSER: TSpTBXItem;
    mbArcSED: TSpTBXItem;
    mbArcSEA: TSpTBXItem;
    mbCircle: TSpTBXSubmenuItem;
    mbCirTTR: TSpTBXItem;
    mbCirTTT: TSpTBXItem;
    mbCir3P: TSpTBXItem;
    mbCir2P: TSpTBXItem;
    mbCirCR: TSpTBXItem;
    mbCirCD: TSpTBXItem;
    mbEllipse: TSpTBXSubmenuItem;
    mbEllipseC: TSpTBXItem;
    mbEllipseAE: TSpTBXItem;
    mbMakeBlock: TSpTBXItem;
    mbInsBlock: TSpTBXItem;
    TBXSubmenuItem1: TSpTBXSubmenuItem;
    mbPoint: TSpTBXSubmenuItem;
    mbDivide: TSpTBXItem;
    mbMPoint: TSpTBXItem;
    mbRegion: TSpTBXItem;
    mbHatch: TSpTBXItem;
    mbText: TSpTBXSubmenuItem;
    mbSText: TSpTBXItem;
    mbMText: TSpTBXItem;
    mbEllipseArc: TSpTBXItem;
    mbRectangle: TSpTBXSubmenuItem;
    mbRect2P: TSpTBXItem;
    mbRect3P: TSpTBXItem;
    mbRectCSA: TSpTBXItem;
    mbZoomExtends: TSpTBXItem;
    TBXSeparatorItem18: TSpTBXSeparatorItem;
    TBXSeparatorItem19: TSpTBXSeparatorItem;
    TBXSeparatorItem20: TSpTBXSeparatorItem;
    TBXSeparatorItem21: TSpTBXSeparatorItem;
    TBXSeparatorItem22: TSpTBXSeparatorItem;
    TBXSeparatorItem24: TSpTBXSeparatorItem;
    TBXSeparatorItem25: TSpTBXSeparatorItem;
    TBXSeparatorItem26: TSpTBXSeparatorItem;
    TBXSeparatorItem27: TSpTBXSeparatorItem;
    TBXSeparatorItem75: TSpTBXSeparatorItem;
    TBXSeparatorItem76: TSpTBXSeparatorItem;


    {Dimention..}
    mnDimention: TSpTBXSubmenuItem;
    mbDimTolerance: TSpTBXItem;
    mbDimLeader: TSpTBXItem;
    mbDimArcLength: TSpTBXItem;
    mbDimContinue: TSpTBXItem;
    mbDimAngular: TSpTBXItem;
    mbDimDiameter: TSpTBXItem;
    mbDimRadius: TSpTBXItem;
    mbDimOrdinate: TSpTBXItem;
    mbDimAligned: TSpTBXItem;
    mbDimLinear: TSpTBXItem;
    mbDimUpdate: TSpTBXItem;
    mbDimStyle: TSpTBXItem;
    mbDimCenter: TSpTBXItem;
    mbDimOverride: TSpTBXItem;
    mbDimJogged: TSpTBXItem;
    TBXSeparatorItem28: TSpTBXSeparatorItem;
    TBXSeparatorItem29: TSpTBXSeparatorItem;
    TBXSeparatorItem30: TSpTBXSeparatorItem;
    TBXSeparatorItem31: TSpTBXSeparatorItem;
    TBXSeparatorItem32: TSpTBXSeparatorItem;


    {Modify..}
    mnModify: TSpTBXSubmenuItem;
    mbScale: TSpTBXItem;
    mbRotate: TSpTBXItem;
    mbMove: TSpTBXItem;
    mbArray: TSpTBXItem;
    mbOffset: TSpTBXItem;
    mbMirror: TSpTBXItem;
    mbCopy: TSpTBXItem;
    mbMatch: TSpTBXItem;
    mbProperties: TSpTBXItem;
    mbExplode: TSpTBXItem;
    mbFillet: TSpTBXItem;
    mbChamfer: TSpTBXItem;
    mbLengthen: TSpTBXItem;
    mbStretch: TSpTBXItem;
    mbBreak: TSpTBXItem;
    mbBreakAtPnt: TSpTBXItem;
    mbExtend: TSpTBXItem;
    mbTrim: TSpTBXItem;
    mbIntersect: TSpTBXItem;
    mbUnion: TSpTBXItem;
    mbSubtract: TSpTBXItem;
    TBXSeparatorItem33: TSpTBXSeparatorItem;
    TBXSeparatorItem34: TSpTBXSeparatorItem;
    TBXSeparatorItem35: TSpTBXSeparatorItem;
    TBXSeparatorItem36: TSpTBXSeparatorItem;
    TBXSeparatorItem37: TSpTBXSeparatorItem;
    TBXSeparatorItem39: TSpTBXSeparatorItem;



    //=============================================================
    {Toolbar......}

      {Standard...}
    StdToolbar: TSpTBXToolbar;
    tbNew: TSpTBXItem;
    tbOpen: TSpTBXItem;
    tbSave: TSpTBXItem;
    tbPreview: TSpTBXItem;
    tbPrint: TSpTBXItem;
    tbCut: TSpTBXItem;
    tbCopy: TSpTBXItem;
    tbMatch: TSpTBXItem;
    tbZoomAll: TSpTBXItem;
    tbZoomWin: TSpTBXItem;
    tbZoomReal: TSpTBXItem;
    tbPan: TSpTBXItem;
    tbZoomIn: TSpTBXItem;
    tbZoomOut: TSpTBXItem;
    tbZoomPrev: TSpTBXItem;
    tbRedo: TSpTBXItem;
    tbUndo: TSpTBXItem;
    tbProperties: TSpTBXItem;

    tbObjSnap: TSpTBXSubmenuItem;
    tbSnapNode2: TSpTBXItem;
    tbSnapInsert2: TSpTBXItem;
    tbSnapPerp2: TSpTBXItem;
    tbSnapTan2: TSpTBXItem;
    tbSnapQuad2: TSpTBXItem;
    tbSnapCenter2: TSpTBXItem;
    tbSnapIntersection2: TSpTBXItem;
    tbSnapMidpoint2: TSpTBXItem;
    tbSnapEndpoint2: TSpTBXItem;
    tbSnapFrom2: TSpTBXItem;
    tbSnapSetting2: TSpTBXItem;
    tbSnapNone2: TSpTBXItem;
    tbSnapNearest2: TSpTBXItem;
    TBXSeparatorItem68: TSpTBXSeparatorItem;
    TBXSeparatorItem69: TSpTBXSeparatorItem;
    TBXSeparatorItem71: TSpTBXSeparatorItem;
    TBXSeparatorItem62: TSpTBXSeparatorItem;
    TBXSeparatorItem12: TSpTBXSeparatorItem;
    TBXSeparatorItem59: TSpTBXSeparatorItem;
    TBXSeparatorItem14: TSpTBXSeparatorItem;
    TBXSeparatorItem15: TSpTBXSeparatorItem;
    TBXSeparatorItem23: TSpTBXSeparatorItem;


    {Draw...}
    DrawToolbar: TSpTBXToolbar;
    tbLine: TSpTBXItem;
    tbRay: TSpTBXItem;
    tbXLine: TSpTBXItem;
    tbPolyline: TSpTBXItem;
    tbPolygon: TSpTBXItem;
    tbRectangle: TSpTBXItem;
    tbArc: TSpTBXItem;
    tbCircle2P: TSpTBXItem;
    tbCircleCR: TSpTBXItem;
    tbCircle3P: TSpTBXItem;
    tbEllipse: TSpTBXItem;
    tbSpline: TSpTBXItem;
    tbInsBlock: TSpTBXItem;
    tbMakeBlock: TSpTBXItem;
    tbPoint: TSpTBXItem;
    tbHatch: TSpTBXItem;
    tbRegion: TSpTBXItem;
    tbText: TSpTBXItem;

    tbEllipseArc: TSpTBXItem;
    SpTBXSeparatorItem4: TSpTBXSeparatorItem;
    tbArcs: TSpTBXSubmenuItem;
    tbArcSCE: TSpTBXItem;
    tbArcSCA: TSpTBXItem;
    tbArcSCL: TSpTBXItem;
    SpTBXSeparatorItem8: TSpTBXSeparatorItem;
    tbArcSEA: TSpTBXItem;
    tbArcSED: TSpTBXItem;
    tbArcSER: TSpTBXItem;
    SpTBXSeparatorItem9: TSpTBXSeparatorItem;
    tbArcCSE: TSpTBXItem;
    tbArcCSA: TSpTBXItem;
    tbArcCSL: TSpTBXItem;

    TBXSeparatorItem42: TSpTBXSeparatorItem;
    TBXSeparatorItem43: TSpTBXSeparatorItem;
    TBXSeparatorItem44: TSpTBXSeparatorItem;
    TBXSeparatorItem45: TSpTBXSeparatorItem;
    TBXSeparatorItem46: TSpTBXSeparatorItem;
    TBXSeparatorItem78: TSpTBXSeparatorItem;
    TBXSeparatorItem79: TSpTBXSeparatorItem;



    {Modify...}
    ModifyToolbar: TSpTBXToolbar;
    tbCopyObj: TSpTBXItem;
    tbMirror: TSpTBXItem;
    tbOffset: TSpTBXItem;
    tbArray: TSpTBXItem;
    tbMove: TSpTBXItem;
    tbRotate: TSpTBXItem;
    tbScale: TSpTBXItem;
    tbLengthen: TSpTBXItem;
    tbTrim: TSpTBXItem;
    tbExtend: TSpTBXItem;
    tbBreak: TSpTBXItem;
    tbBreakAtPnt: TSpTBXItem;
    tbChamfer: TSpTBXItem;
    tbFillet: TSpTBXItem;
    tbExplode: TSpTBXItem;
    tbUnion: TSpTBXItem;
    tbSubtract: TSpTBXItem;
    tbIntersect: TSpTBXItem;
    tbEditHatch: TSpTBXItem;
    tbTextEdit: TSpTBXItem;
    TBXSeparatorItem47: TSpTBXSeparatorItem;
    TBXSeparatorItem48: TSpTBXSeparatorItem;
    TBXSeparatorItem49: TSpTBXSeparatorItem;
    SnapToolbar: TSpTBXToolbar;
    tbSnapFrom: TSpTBXItem;
    tbSnapEndpoint: TSpTBXItem;
    tbSnapMidpoint: TSpTBXItem;
    tbSnapIntersection: TSpTBXItem;
    tbSnapCenter: TSpTBXItem;
    tbSnapQuad: TSpTBXItem;
    tbSnapTan: TSpTBXItem;
    tbSnapPerp: TSpTBXItem;
    tbSnapInsert: TSpTBXItem;
    tbSnapNode: TSpTBXItem;
    tbSnapNearest: TSpTBXItem;
    tbSnapNone: TSpTBXItem;
    tbSnapSetting: TSpTBXItem;
    TBXSeparatorItem50: TSpTBXSeparatorItem;
    TBXSeparatorItem51: TSpTBXSeparatorItem;
    TBXSeparatorItem52: TSpTBXSeparatorItem;
    TBXSeparatorItem53: TSpTBXSeparatorItem;


    {Dimention...}
    DimToolbar: TSpTBXToolbar;
    tbDimLinear: TSpTBXItem;
    tbDimAligned: TSpTBXItem;
    tbDimOrdinate: TSpTBXItem;
    tbDimRadius: TSpTBXItem;
    tbDimDiameter: TSpTBXItem;
    tbDimAngular: TSpTBXItem;
    tbDimContinue: TSpTBXItem;
    tbDimLeader: TSpTBXItem;
    tbDimTolerance: TSpTBXItem;
    tbCenterMark: TSpTBXItem;
    tbDimTextAlign: TSpTBXItem;
    tbDimTextEdit: TSpTBXItem;
    tbDimStyle: TSpTBXItem;
    tbDimUpdate: TSpTBXItem;
    tbAlignDimText: TSpTBXSubmenuItem;
    tbDimTextAlignAngle: TSpTBXItem;
    tbDimTextAlignHome: TSpTBXItem;
    tbDimTextAlignRight: TSpTBXItem;
    tbDimTextAlignCenter: TSpTBXItem;
    tbDimTextAlignLeft: TSpTBXItem;
    tbDimJogged: TSpTBXItem;
    tbDimArcLength: TSpTBXItem;

    TBXSeparatorItem54: TSpTBXSeparatorItem;
    TBXSeparatorItem55: TSpTBXSeparatorItem;
    TBXSeparatorItem56: TSpTBXSeparatorItem;
    TBXSeparatorItem57: TSpTBXSeparatorItem;
    TBXSeparatorItem58: TSpTBXSeparatorItem;
    SpTBXSeparatorItem10: TSpTBXSeparatorItem;


    {Inquiry...}
    InquiryToobar: TSpTBXToolbar;
    tbLocatePoint: TSpTBXItem;
    tbList: TSpTBXItem;
    tbArea: TSpTBXItem;
    tbDistance: TSpTBXItem;
    TBXSeparatorItem65: TSpTBXSeparatorItem;

    
    {Order...}
    OrderToolbar: TSpTBXToolbar;
    tbSendBack: TSpTBXItem;
    tbBringFront: TSpTBXItem;
    SpTBXSeparatorItem11: TSpTBXSeparatorItem;
    tbSendUnder: TSpTBXItem;
    tbBringAbove: TSpTBXItem;
    SpTBXSeparatorItem12: TSpTBXSeparatorItem;
    mbBringAbove: TSpTBXItem;
    mbSendUnder: TSpTBXItem;

        

    {Properties...}
    PropToolbar: TSpTBXToolbar;
    tbLayer: TSpTBXItem;
    tbLinetype: TSpTBXItem;
    tbSetLayer: TSpTBXItem;
    TBXSeparatorItem63: TSpTBXSeparatorItem;
    TBXSeparatorItem72: TSpTBXSeparatorItem;
    SpTBXSeparatorItem5: TSpTBXSeparatorItem;
    
    
    {Windows}
    mnWindow: TSpTBXSubmenuItem;
    mbNextWindow: TSpTBXItem;
    TBXSeparatorItem74: TSpTBXSeparatorItem;
    TBXSeparatorItem41: TSpTBXSeparatorItem;
    TBXSubmenuItem2: TSpTBXSubmenuItem;
    SpTBXLabelItem1: TSpTBXLabelItem;

    {Drafing}
    lblPos      : TSpTBXLabelItem;
    btnUseSnap  : TSpTBXItem;
    btnUseGrid  : TSpTBXItem;
    btnUseOrtho : TSpTBXItem;
    btnUseOSnap : TSpTBXItem;
    btnUseLWT   : TSpTBXItem;
    btnUsePolar: TSpTBXItem;

    {Test..}
    TestToolbar: TSpTBXToolbar;
    SpTBXSeparatorItem7: TSpTBXSeparatorItem;
    SpTBXSeparatorItem1: TSpTBXSeparatorItem;
    SpTBXSeparatorItem2: TSpTBXSeparatorItem;
    ProgressBar1: TSpTBXProgressBar;
    TBControlItem8: TTBControlItem;
    lblStatus: TSpTBXLabelItem;
    btnAddLine: TSpTBXItem;
    btnAddPoints: TSpTBXItem;
    btnAddSegarcs: TSpTBXItem;
    btnAddArc: TSpTBXItem;
    btnAddSegarc: TSpTBXItem;
    btnAddCircle: TSpTBXItem;
    btnAddEllipse: TSpTBXItem;
    SpTBXSeparatorItem6: TSpTBXSeparatorItem;
    SpTBXSeparatorItem3: TSpTBXSeparatorItem;
    btnArrowBlocks: TSpTBXItem;
    


    {PopupMenu..}
    PopupMenu: TSpTBXPopupMenu;
    nRepeat: TSpTBXItem;
    nUnselectAll: TSpTBXItem;
    nExit: TSpTBXItem;
    nInputCoordinate: TSpTBXItem;
    nSnapoverrides: TSpTBXSubmenuItem;
    N1: TSpTBXSeparatorItem;
    nZoomExtends: TSpTBXItem;
    nZoomWindows: TSpTBXItem;
    nZoomReal: TSpTBXItem;
    nZoomPan: TSpTBXItem;
    N2: TSpTBXSeparatorItem;
    nErase: TSpTBXItem;
    nMove: TSpTBXItem;
    nCopy: TSpTBXItem;
    nRotate: TSpTBXItem;
    nScale: TSpTBXItem;
    nMirror: TSpTBXItem;
    nOffset: TSpTBXItem;


    
    //---------------------------------------------

    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlCmdLine: TSpTBXDockablePanel;
    pnlProperties: TSpTBXDockablePanel;
    sptBottom: TSpTBXSplitter;
    sptProperties: TSpTBXSplitter;
    LeftMultiDock: TSpTBXMultiDock;
    RightMultiDock: TSpTBXMultiDock;



    btnLoopSearch: TSpTBXItem;
    ImageList1: TImageList;
    tbCalculator: TSpTBXItem;
    mnHelp: TSpTBXSubmenuItem;
    mbAbout: TSpTBXItem;
    mbContents: TSpTBXItem;
    mbEditHatch: TSpTBXItem;
    mbEditText: TSpTBXItem;
    mbDimEdit: TSpTBXItem;
    btnAddImage: TSpTBXItem;
    btnAddFog: TSpTBXItem;
    FogTimer: TTimer;






    {File...}
    procedure acNewExecute(Sender: TObject);
    procedure acOpenExecute(Sender: TObject);
    procedure acSaveExecute(Sender: TObject);
    procedure acSaveAsExecute(Sender: TObject);
    procedure acPreView2Decute(Sender: TObject);
    procedure acPrintExecute(Sender: TObject);
    procedure acPrintSetupExecute(Sender: TObject);
    procedure acExitExecute(Sender: TObject);

    {Edit...}
    procedure acUndoExecute(Sender: TObject);
    procedure acRedoExecute(Sender: TObject);
    procedure acCutExecute(Sender: TObject);
    procedure acCopyExecute(Sender: TObject);
    procedure acPasteExecute(Sender: TObject);
    procedure acSelectAllExecute(Sender: TObject);
    procedure acClearExecute(Sender: TObject);

    {View...}
    procedure acPanRealExecute(Sender: TObject);
    procedure acPan2PExecute(Sender: TObject);
    procedure acZoomRealExecute(Sender: TObject);
    procedure acZoomWinExecute(Sender: TObject);
    procedure acZoomInExecute(Sender: TObject);
    procedure acZoomOutExecute(Sender: TObject);
    procedure acZoomAllExecute(Sender: TObject);
    procedure acZoomExtendsExecute(Sender: TObject);
    procedure acZoomPrevExecute(Sender: TObject);


    {Format...}
    procedure acLayerExecute(Sender: TObject);
    procedure acColorExecute(Sender: TObject);
    procedure acLinetypeExecute(Sender: TObject);
    procedure acLineWeightExecute(Sender: TObject);
    procedure acTextStyleExecute(Sender: TObject);
    procedure acDimStyleExecute(Sender: TObject);
    procedure acPointStyleExecute(Sender: TObject);
    procedure acUnitsClick(Sender: TObject);
    

    {Tools...}
    procedure acBringFrontExecute(Sender: TObject);
    procedure acSendBackExecute(Sender: TObject);
    procedure acDistanceExecute(Sender: TObject);
    procedure acAreaExecute(Sender: TObject);
    procedure acListExecute(Sender: TObject);
    procedure acLocatePointExecute(Sender: TObject);
    procedure acCalculatorExecute(Sender: TObject);
    procedure acLoadAppExecute(Sender: TObject);
    procedure acRunScriptExecute(Sender: TObject);
    procedure acDraftingSetting(Sender: TObject);
    procedure acSelectionExecute(Sender: TObject);
    procedure acPerferenceExecute(Sender: TObject);

    {Draw...}
    procedure acLineExecute(Sender: TObject);
    procedure acRayExecute(Sender: TObject);
    procedure acXLineExecute(Sender: TObject);
    procedure acPolylineExecute(Sender: TObject);
    procedure acPolygonExecute(Sender: TObject);
    procedure acRectExecute(Sender: TObject);
    procedure acRect3PExecute(Sender: TObject);
    procedure acRectCSAExecute(Sender: TObject);
    procedure acCircleCRExecute(Sender: TObject);
    procedure acCircleCDExecute(Sender: TObject);
    procedure acCircle2PExecute(Sender: TObject);
    procedure acCircle3PExecute(Sender: TObject);
    procedure acCircleTTRExecute(Sender: TObject);
    procedure acCircleTTTExecute(Sender: TObject);
    procedure acEllipseCExecute(Sender: TObject);
    procedure acEllipseAEExecute(Sender: TObject);
    procedure acEllipseArcExecute(Sender: TObject);
    procedure acDonutExecute(Sender: TObject);
    procedure acSplineExecute(Sender: TObject);
    procedure acArc3PExecute(Sender: TObject);
    procedure acArcSCEClick(Sender: TObject);
    procedure acArcSCAClick(Sender: TObject);
    procedure acArcSCLClick(Sender: TObject);
    procedure acArcSEAClick(Sender: TObject);
    procedure acArcSEDClick(Sender: TObject);
    procedure acArcSERClick(Sender: TObject);
    procedure acArcCSEClick(Sender: TObject);
    procedure acArcCSAClick(Sender: TObject);
    procedure acArcCSLClick(Sender: TObject);
    procedure acPointExecute(Sender: TObject);
    procedure acDivideExecute(Sender: TObject);
    procedure acMeasureExecute(Sender: TObject);
    procedure acMakeBlockExecute(Sender: TObject);
    procedure acInsBlockExecute(Sender: TObject);
    procedure acHatchExecute(Sender: TObject);
    procedure acRegionExecute(Sender: TObject);
    procedure acSTextExecute(Sender: TObject);
    procedure acMTextExecute(Sender: TObject);

    {Dimention...}
    procedure acDimLinearExecute(Sender: TObject);
    procedure acDimAlignedExecute(Sender: TObject);
    procedure acDimArcExecute(Sender: TObject);
    procedure acDimRadiusExecute(Sender: TObject);
    procedure acDimJoggedExecute(Sender: TObject);
    procedure acDimOrdinateExecute(Sender: TObject);
    procedure acDimDiameterExecute(Sender: TObject);
    procedure acDimAngularExecute(Sender: TObject);
    procedure acDimBaselineExecute(Sender: TObject);
    procedure acDimContinueExecute(Sender: TObject);
    procedure acDimLeaderExecute(Sender: TObject);
    procedure acDimToleranceExecute(Sender: TObject);
    procedure acDimCenterExecute(Sender: TObject);
    procedure acDimEditClick(Sender: TObject);
    procedure acDimTextEditClick(Sender: TObject);
    procedure acDimTextAlignClick(Sender: TObject);
    procedure acDimOverrideExecute(Sender: TObject);
    procedure acDimUpdateExecute(Sender: TObject);

    {Modify...}
    procedure acPropertiesExecute(Sender: TObject);
    procedure acMatchExecute(Sender: TObject);
    procedure acEraseExecute(Sender: TObject);
    procedure acCopyObjExecute(Sender: TObject);
    procedure acMirrorExecute(Sender: TObject);
    procedure acOffsetExecute(Sender: TObject);
    procedure acArrayExecute(Sender: TObject);
    procedure acMoveExecute(Sender: TObject);
    procedure acRotateExecute(Sender: TObject);
    procedure acScaleExecute(Sender: TObject);
    procedure acStretchExecute(Sender: TObject);
    procedure acLengthenExecute(Sender: TObject);
    procedure acTrimExecute(Sender: TObject);
    procedure acExtendExecute(Sender: TObject);
    procedure acBreakExecute(Sender: TObject);
    procedure acBreakAtPntExecute(Sender: TObject);
    procedure acChamferExecute(Sender: TObject);
    procedure acFilletExecute(Sender: TObject);
    procedure acUnionExecute(Sender: TObject);
    procedure acSubtractExecute(Sender: TObject);
    procedure acIntersectExecute(Sender: TObject);
    procedure acExplodeExecute(Sender: TObject);
    procedure acEditTextExecute(Sender: TObject);
    procedure acEditHatchExecute(Sender: TObject);

    {Snap...}
    procedure acSnapFromExecute(Sender: TObject);
    procedure acSnapEndExecute(Sender: TObject);
    procedure acSnapMidExecute(Sender: TObject);
    procedure acSnapIntesExecute(Sender: TObject);
    procedure acSnapCenterExecute(Sender: TObject);
    procedure acSnapQuadExecute(Sender: TObject);
    procedure acSnapTanExecute(Sender: TObject);
    procedure acSnapPerpExecute(Sender: TObject);
    procedure acSnapInsertExecute(Sender: TObject);
    procedure acSnapNodeExecute(Sender: TObject);
    procedure acSnapNearestExecute(Sender: TObject);
    procedure acSnapQuickExecute(Sender: TObject);
    procedure acSnapNoneExecute(Sender: TObject);
    procedure acSnapSettingExecute(Sender: TObject);


    {PopupMenu...}
    procedure PopupMenuPopup(Sender: TObject);
    procedure nPopupRepeatClick(Sender: TObject);
    procedure nPopupUnselectAllClick(Sender: TObject);
    procedure nPopupExitClick(Sender: TObject);
    procedure nPopupInputCoordinateClick(Sender: TObject);

        

    //================================================================================

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure pnlPropertiesDockChanging(Sender: TObject; Floating: Boolean; DockingTo: TTBDock);

    procedure DraftingModeChanged(Sender: TObject);
    procedure pnlLeftResize(Sender: TObject);
    procedure pnlPropertiesClose(Sender: TObject);


    procedure btnAddLineClick(Sender: TObject);
    procedure btnAddArcClick(Sender: TObject);
    procedure btnAddPointsClick(Sender: TObject);
    procedure btnAddSegarcsClick(Sender: TObject);
    procedure btnAddSegarcClick(Sender: TObject);
    procedure btnAddPolylineClick(Sender: TObject);
    procedure btnAddCircleClick(Sender: TObject);
    procedure btnAddEllipseClick(Sender: TObject);

    procedure TopDockCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    procedure mbAboutClick(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);

    //------------------------------------------------------------

    procedure btnLoopSearchClick(Sender: TObject);
    procedure btnArrowBlocksClick(Sender: TObject);
    procedure btnAddImageClick(Sender: TObject);
    procedure btnAddFogClick(Sender: TObject);
    procedure FogTimerTimer(Sender: TObject);

  private
    FDocFile: string;

    FDocument: TUdDocument;
    FCmdLine : TUdCmdLine;
    FDrawPanel: TUdDrawPanel;

    FPropsForm: TPropsForm;

    FLayerComboBox: TUdLayerComboBox;
    FColorComboBox: TUdColorComboBox;
    FLntypComboBox: TUdLntypComboBox;
    FLwtComboBox  : TUdLwtComboBox;

    FPropPanelWidth: Integer;
    FFogPntsList: TList;

  protected
    procedure SetDocFile(Value: string);

    procedure OnDrawPanelKeyPress(Sender: TObject; var Key: Char);
    procedure OnDrawPanelKeyDown(Sender: TObject;var Key: Word; Shift: TShiftState);
    
    procedure UpdateStatusBar;
    procedure UpdatePropComboBox();

    {Colors's Event...}
    procedure OnDocumentColorAdd(Sender: TObject; AColor: TUdColor);
    procedure OnDocumentColorSelect(Sender: TObject; AColor: TUdColor);
    procedure OnDocumentColorRemove(Sender: TObject; AColor: TUdColor; var AAllow: Boolean);

    {LineTypes's Event...}
    procedure OnDocumentLineTypeAdd(Sender: TObject; ALineType: TUdLineType);
    procedure OnDocumentLineTypeSelect(Sender: TObject; ALineType: TUdLineType);
    procedure OnDocumentLineTypeRemove(Sender: TObject; ALineType: TUdLineType; var AAllow: Boolean);

    {LineWeights's Event...}
    procedure OnDocumentLineWeightsSelect(Sender: TObject; ALineWeight: TUdLineWeight);

    {Layers's Event...}
    procedure OnDocumentLayerAdd(Sender: TObject; ALayer: TUdLayer);
    procedure OnDocumentLayerSelect(Sender: TObject; ALayer: TUdLayer);
    procedure OnDocumentLayerRemove(Sender: TObject; ALayer: TUdLayer; var AAllow: Boolean);

    {Layouts's Event...}
    procedure OnDocumentLayoutAdd(Sender: TObject; ALayout: TUdLayout);
    procedure OnDocumentLayoutSelect(Sender: TObject; ALayout: TUdLayout);
    procedure OnDocumentLayoutRemove(Sender: TObject; ALayout: TUdLayout; var AAllow: Boolean);

    {Document's Event...}
    procedure OnDocumentPaint(Sender: TObject; ACanvas: TCanvas);
    procedure OnDocumentMousePoint(Sender: TObject; AKind: TUdMouseKind; AButton: TUdMouseButton; AShift: TUdShiftState; APoint: TPoint; APoint2D: TPoint2D);
    procedure OnDocumentUndoRedoChanged(Sender: TObject);

    procedure OnDocumentAddSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnDocumentRemoveSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
    procedure OnDocumentRemoveAllSelectedEntities(Sender: TObject);
    procedure OnDocumentAfterObjectModify(Sender: TObject; AObj: TObject; APropName: string);

    procedure OnDocumentAxesChanging(Sender: TObject);
    procedure OnDocumentAxesChanged(Sender: TObject);

    {....}
    procedure OnLayerComboBoxSelect(Sender: TObject);
    procedure OnColorComboBoxSelectOther(Sender: TObject);
    procedure OnLineTypeComboBoxSelectOther(Sender: TObject);

    procedure OnLayerComboBoxSelecting(Sender: TObject; ALayer: TUdLayer; var AHandled: Boolean);
    procedure OnColorComboBoxSelecting(Sender: TObject; AColor: TUdColor; var AHandled: Boolean);
    procedure OnLineTypeComboBoxSelecting(Sender: TObject; ALineType: TUdLineType; var AHandled: Boolean);
    procedure OnLineWeightComboBoxSelecting(Sender: TObject; ALineWeight: TUdLineWeight; var AHandled: Boolean);

    procedure OnColorComboBoxGetUsrRGBColor(Sender: TObject; AColor: TUdColor; var ARRBColor: TColor; var AHandled: Boolean);    
    procedure OnLineTypeComboBoxGetUsrLineTypeValue(Sender: TObject; ALineType: TUdLineType; var AValue: TSingleArray; var AHandled: Boolean);

    procedure OnDocumentProgress(Sender: TObject; AProgress: Integer; const AProgressMax: Integer; AMsg: string);

  public
    property DocFile: string read FDocFile write SetDocFile;

  end;


var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  SysUtils, ShellAPI, Variants, InputFrm,

  UdMath, UdGeo2D, UdArrays, UdUtils, UdStrConverter,
  UdFigure, UdLine, UdRect, UdArc, UdCircle, UdEllipse, UdPolyline, UdPoint, UdImage,

  UdLoopSearch, UdXml, UdDxfConvert, UdColorsFrm, UdLineTypesFrm, UdUnitsFrm, AboutFrm;


type
  TFDrawPanel = class(TUdDrawPanel);



//==============================================================================================

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SkinManager.SetSkin('Office 2003');

  FDocument := TUdDocument.Create();

  FDrawPanel := TUdDrawPanel.Create(nil);
  FDrawPanel.Parent := pnlClient;
  FDrawPanel.Align := alClient;
  FDrawPanel.OnKeyPress := OnDrawPanelKeyPress;
  FDrawPanel.OnKeyDown := OnDrawPanelKeyDown;
  FDrawPanel.PopupMenu := PopupMenu;
  //FDrawPanel.XCursor.SysCursor := true;

  FCmdLine := TUdCmdLine.Create(nil);
  FCmdLine.Parent := pnlCmdLine;
  FCmdLine.Align := alClient;


  FDocument.OnColorAdd        := OnDocumentColorAdd   ;
  FDocument.OnColorSelect     := OnDocumentColorSelect;
  FDocument.OnColorRemove     := OnDocumentColorRemove;

  FDocument.OnLineTypeAdd     := OnDocumentLineTypeAdd   ;
  FDocument.OnLineTypeSelect  := OnDocumentLineTypeSelect;
  FDocument.OnLineTypeRemove  := OnDocumentLineTypeRemove;

  FDocument.OnLayerAdd        := OnDocumentLayerAdd    ;
  FDocument.OnLayerSelect     := OnDocumentLayerSelect ;
  FDocument.OnLayerRemove     := OnDocumentLayerRemove ;

  FDocument.OnLayoutAdd       := OnDocumentLayoutAdd   ;
  FDocument.OnLayoutSelect    := OnDocumentLayoutSelect;
  FDocument.OnLayoutRemove    := OnDocumentLayoutRemove;

  FDocument.OnUserPaint                := OnDocumentPaint;
  FDocument.OnMousePoint               := OnDocumentMousePoint;
  FDocument.OnAddSelectedEntities      := OnDocumentAddSelectedEntities;
  FDocument.OnRemoveSelectedEntities   := OnDocumentRemoveSelectedEntities;
  FDocument.OnRemoveAllSelecteEntities := OnDocumentRemoveAllSelectedEntities;
  FDocument.OnAfterObjectModify        := OnDocumentAfterObjectModify;

  FDocument.OnAxesChanged   := OnDocumentAxesChanged;
  FDocument.OnAxesChanging  := OnDocumentAxesChanging;

  FDocument.OnProgress := OnDocumentProgress;

  FDocument.UndoRedo.OnChanged := OnDocumentUndoRedoChanged;
  FDocument.ModelSpace.BackColor := RGB(2, 16, 25);


  FPropsForm := TPropsForm.Create(nil);
  FPropsForm.ManualDock(pnlProperties);
  FPropsForm.Parent := pnlProperties;
  FPropsForm.Align := alClient;

  pnlProperties.Width := pnlLeft.Width;
  FPropPanelWidth := pnlProperties.Width;

  FLayerComboBox := TUdLayerComboBox.Create(Self);
  FColorComboBox := TUdColorComboBox.Create(Self);
  FLntypComboBox := TUdLntypComboBox.Create(Self);
  FLwtComboBox   := TUdLwtComboBox.Create(Self);

  pnlPropertiesClose(pnlProperties);
  FFogPntsList := TList.Create();
end;

procedure TMainForm.FormShow(Sender: TObject);

  function _NewSeparatorItem():  TSpTBXSeparatorItem;
  begin
    Result := TSpTBXSeparatorItem.Create(PropToolbar);
  end;

begin
  FDocument.CmdLine := FCmdLine;
  FDocument.DrawPanel := FDrawPanel;

//  PenStyleBox.ItemIndex := 0;
//  PenWidthBox.ItemIndex := 0;
//  BrushStyleBox.ItemIndex := 0;
//  BrushStyleBox.BrushColor := BrushColorBox.Selected;

  FLayerComboBox.Parent := PropToolbar;
  PropToolbar.Items.Add(_NewSeparatorItem()); //TSpTBXSeparatorItem

  FColorComboBox.Parent := PropToolbar;
  PropToolbar.Items.Add(_NewSeparatorItem()); //TSpTBXSeparatorItem

  FLntypComboBox.Parent := PropToolbar;
  PropToolbar.Items.Add(_NewSeparatorItem()); //TSpTBXSeparatorItem
  
  FLwtComboBox.Parent   := PropToolbar;

  PropToolbar.Items.Move(3, 7);
  
  FLayerComboBox.Layers := FDocument.Layers;
  FColorComboBox.Colors := FDocument.Colors;
  FLntypComboBox.LineTypes := FDocument.LineTypes;
  FLwtComboBox.LineWeights := FDocument.LineWeights;

  FLayerComboBox.OnSelect := OnLayerComboBoxSelect;
  FColorComboBox.OnSelectOther := OnColorComboBoxSelectOther;
  FLntypComboBox.OnSelectOther := OnLineTypeComboBoxSelectOther;

  FLayerComboBox.OnSelectingLayer := OnLayerComboBoxSelecting;
  FColorComboBox.OnSelectingColor := OnColorComboBoxSelecting;
  FLntypComboBox.OnSelectingLineType := OnLineTypeComboBoxSelecting;
  FLwtComboBox.OnSelectingLineWeight := OnLineWeightComboBoxSelecting;

  FColorComboBox.OnGetUsrRGBColor := OnColorComboBoxGetUsrRGBColor;
  FLntypComboBox.OnGetUsrLineTypeValue := OnLineTypeComboBoxGetUsrLineTypeValue;

  FPropsForm.Document := FDocument;
  FPropsForm.ClearInspObjects();
  FPropsForm.Show();
end;




procedure TMainForm.FormActivate(Sender: TObject);
begin
  if Self.CanFocus then Self.SetFocus;
  //if LayerBox.HandleAllocated then LayerBox.CloseDown;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FDocument ) then FDocument.Free();
  if Assigned(FDrawPanel) then FDrawPanel.Free();
  if Assigned(FCmdLine  ) then FCmdLine.Free();
  if Assigned(FPropsForm) then FPropsForm.Free();

  if Assigned(FLayerComboBox) then FLayerComboBox.Free();
  if Assigned(FColorComboBox) then FColorComboBox.Free();
  if Assigned(FLntypComboBox) then FLntypComboBox.Free();
  if Assigned(FLwtComboBox  ) then FLwtComboBox.Free();

  if Assigned(FFogPntsList) then FFogPntsList.Free;
  FFogPntsList := nil;
  //ShellAPI.ShellExecute(0, 'open', 'http://www.xinbosoft.com', '', '', SW_SHOWNORMAL);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // 
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if FPropsForm.NoSelection then FPropsForm.ObjectModified(FDocument);
end;


procedure TMainForm.SetDocFile(Value: string);
begin
  FDocFile := Value;
  Self.Caption := 'Delphi CAD' + ' - ' + FDocFile;
end;



procedure TMainForm.StatusBarResize(Sender: TObject);
begin
  ProgressBar1.Width := StatusBar.Width - 560;
end;

procedure TMainForm.TopDockCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
  //
end;

//------------------------------------------------------------------------------------------------

procedure TMainForm.pnlLeftResize(Sender: TObject);
begin
  if TComponent(Sender).Tag = 0 then
  begin
    if pnlProperties.CurrentDock = LeftMultiDock then
      pnlProperties.Width := pnlLeft.Width;
  end
  else begin
    if pnlProperties.CurrentDock = RightMultiDock then
      pnlProperties.Width := pnlRight.Width;
  end;
end;

procedure TMainForm.pnlPropertiesClose(Sender: TObject);
begin
  if Assigned(pnlProperties.CurrentDock) then
  begin
    FPropPanelWidth := pnlProperties.Width;
    
    if pnlProperties.CurrentDock = LeftMultiDock  then
      pnlLeft.Width := 2
    else if pnlProperties.CurrentDock = RightMultiDock then
      pnlRight.Width := 2;

    sptProperties.Visible := False;
  end;

  pnlProperties.Visible := False;
end;

procedure TMainForm.pnlPropertiesDockChanging(Sender: TObject; Floating: Boolean; DockingTo: TTBDock);
begin
  if Assigned(DockingTo) then
  begin
    if DockingTo = LeftMultiDock  then
    begin
      pnlLeft.Width := pnlProperties.Width;

      sptProperties.Align := alLeft;
      sptProperties.Left := pnlLeft.Width;
    end
    else if DockingTo = RightMultiDock then
    begin
      pnlRight.Width := pnlProperties.Width;

      sptProperties.Align := alRight;
      sptProperties.Left := pnlRight.Left;
    end;

    sptProperties.Visible := True;
  end
  else begin
    if pnlProperties.LastDock = LeftMultiDock then
      pnlProperties.FloatingClientWidth := pnlLeft.Width
    else
      pnlProperties.FloatingClientWidth := pnlRight.Width;

    pnlLeft.Width := 2;
    pnlRight.Width := 2;
    sptProperties.Visible := False;
  end;
end;




procedure TMainForm.PopupMenuPopup(Sender: TObject);
var
  I: Integer;
  LFlag: UINT;
begin
  LFlag := 1;

  if FDocument.ActiveLayout.IsIdleAction then
  begin
    if FDocument.ActiveLayout.Selection.Count > 0 then LFlag := 2;
  end
  else
    LFlag := 4;

  for I := 0 to PopupMenu.Items.Count - 1 do
  begin
    if PopupMenu.Items[I].Tag > 0 then
      PopupMenu.Items[I].Visible := ((PopupMenu.Items[I].Tag and LFlag) > 0)
    else if PopupMenu.Items[I].Tag < 0 then
      PopupMenu.Items[I].Visible := False;
  end;

  if nRepeat.Visible then
  begin
    nRepeat.Visible := (FDocument.LastCmd <> '');
    nRepeat.Caption := '重复 ' + FDocument.LastCmd;
    nRepeat.Hint := FDocument.LastCmd;
  end;
end;


procedure TMainForm.nPopupExitClick(Sender: TObject);
begin
  FDocument.ActiveLayout.ActionRemoveLast();
end;

procedure TMainForm.nPopupInputCoordinateClick(Sender: TObject);
begin
//
end;

procedure TMainForm.nPopupRepeatClick(Sender: TObject);
begin
  FDocument.ExecCommond(nRepeat.Hint);
end;

procedure TMainForm.nPopupUnselectAllClick(Sender: TObject);
begin
  FDocument.ActiveLayout.Selection.RemoveAll();
end;






//-----------------------------------------------------------------------------------------

procedure TMainForm.DraftingModeChanged(Sender: TObject);
var
  LBtn: TSpTBXItem;
begin
  if not Sender.InheritsFrom(TSpTBXItem) then Exit;

  LBtn := TSpTBXItem(Sender);
  if LBtn.Checked then
    LBtn.FontSettings.Color := clBlack
  else
    LBtn.FontSettings.Color := clGray;

  case LBtn.Tag of
    0: FDocument.ActiveLayout.GridOn  := LBtn.Checked;
    1: FDocument.ActiveLayout.SnapOn  := LBtn.Checked;
    2: FDocument.ActiveLayout.OrthoOn := LBtn.Checked;
    3: FDocument.ActiveLayout.PolarOn := LBtn.Checked;
    4: FDocument.ActiveLayout.OSnapOn := LBtn.Checked;
    5: FDocument.ActiveLayout.LwtDisp := LBtn.Checked;
  end;
end;



procedure TMainForm.OnDrawPanelKeyPress(Sender: TObject; var Key: Char);
begin
  FCmdLine.ExecKeyPress(Key);
end;

procedure TMainForm.OnDrawPanelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LLayout: TUdLayout;
begin
  LLayout := FDocument.ActiveLayout;
  
  //           OSnapOn  GridOn  OrthoOn SnapOn, PolarOn
  //if (Key in [VK_F3,   VK_F7,  VK_F8,  VK_F9,  VK_F10]) then
  //begin
    case Key of
      VK_F3 : LLayout.OSnapOn := not LLayout.OSnapOn;
      VK_F7 : LLayout.GridOn  := not LLayout.GridOn;
      VK_F8 : LLayout.OrthoOn := not LLayout.OrthoOn;
      VK_F9 : LLayout.SnapOn  := not LLayout.SnapOn;
      VK_F10: LLayout.PolarOn := not LLayout.PolarOn;
    end;
  //end;
end;


//--------------------------------------------------------------------------
{Colors's Event...}

procedure TMainForm.OnDocumentColorAdd(Sender: TObject; AColor: TUdColor);
begin

end;

procedure TMainForm.OnDocumentColorSelect(Sender: TObject; AColor: TUdColor);
begin
  if FPropsForm.NoSelection then FPropsForm.ObjectModified(FDocument);
end;

procedure TMainForm.OnDocumentColorRemove(Sender: TObject; AColor: TUdColor; var AAllow: Boolean);
begin

end;



//--------------------------------------------------------------------------
{LineTypes's Event...}

procedure TMainForm.OnDocumentLineTypeAdd(Sender: TObject; ALineType: TUdLineType);
begin

end;

procedure TMainForm.OnDocumentLineTypeSelect(Sender: TObject; ALineType: TUdLineType);
begin
  if FPropsForm.NoSelection then FPropsForm.ObjectModified(FDocument);
end;

procedure TMainForm.OnDocumentLineTypeRemove(Sender: TObject; ALineType: TUdLineType; var AAllow: Boolean);
begin

end;



//--------------------------------------------------------------------------
{LineWeights's Event...}

procedure TMainForm.OnDocumentLineWeightsSelect(Sender: TObject; ALineWeight: TUdLineWeight);
begin

end;




//--------------------------------------------------------------------------
{Layers's Event...}

procedure TMainForm.OnDocumentLayerAdd(Sender: TObject; ALayer: TUdLayer);
begin

end;

procedure TMainForm.OnDocumentLayerSelect(Sender: TObject; ALayer: TUdLayer);
begin
  if FPropsForm.NoSelection then FPropsForm.ObjectModified(FDocument);
end;

procedure TMainForm.OnDocumentLayerRemove(Sender: TObject; ALayer: TUdLayer; var AAllow: Boolean);
begin

end;




//--------------------------------------------------------------------------
{Layouts's Event...}

procedure TMainForm.UpdateStatusBar();
var
  I: Integer;
  LLayout: TUdLayout;
begin
  if not Assigned(FDocument) or
     not Assigned(FDocument.Layouts) then Exit;
     
  LLayout := FDocument.Layouts.Active;
  if not Assigned(LLayout) then Exit;

  btnUseSnap.Checked  := LLayout.SnapOn;
  btnUseGrid.Checked  := LLayout.GridOn;
  btnUseOrtho.Checked := LLayout.OrthoOn;
  btnUsePolar.Checked := LLayout.PolarOn;
  btnUseOSnap.Checked := LLayout.OSnapOn;
  btnUseLWT.Checked   := LLayout.LwtDisp;

  for I := 0 to StatusBar.Items.Count - 1 do
  begin
    if StatusBar.Items[I].InheritsFrom(TSpTBXItem) then //and (StatusBar.Items[I].HelpContext = -1)
    begin
      if StatusBar.Items[I].Checked then
        TSpTBXItem(StatusBar.Items[I]).FontSettings.Color := clBlack
      else
        TSpTBXItem(StatusBar.Items[I]).FontSettings.Color := clGray;
    end;
  end;
end;

procedure TMainForm.OnDocumentLayoutAdd(Sender: TObject; ALayout: TUdLayout);
begin
//..
end;

procedure TMainForm.OnDocumentLayoutSelect(Sender: TObject; ALayout: TUdLayout);
begin
  Self.UpdateStatusBar();
  if FPropsForm.NoSelection then FPropsForm.ObjectModified(FDocument);
end;

procedure TMainForm.OnDocumentLayoutRemove(Sender: TObject; ALayout: TUdLayout; var AAllow: Boolean);
begin
//...
end;




//--------------------------------------------------------------------------
{Document's Event...}

procedure TMainForm.OnDocumentPaint(Sender: TObject; ACanvas: TCanvas);
begin

end;

procedure TMainForm.OnDocumentMousePoint(Sender: TObject; AKind: TUdMouseKind;
  AButton: TUdMouseButton; AShift: TUdShiftState; APoint: TPoint; APoint2D: TPoint2D);
var
  LPos: string;
begin
  LPos := FDocument.Units.RealToStr(APoint2D.X) +  ', ' +
          FDocument.Units.RealToStr(APoint2D.Y) +  ', ' +
          FDocument.Units.RealToStr(0.0);

  lblPos.Caption := LPos;
end;


procedure TMainForm.OnDocumentUndoRedoChanged(Sender: TObject);
begin
  Self.tbUndo.Enabled := FDocument.UndoRedo.UndoCount > 0;
  Self.tbRedo.Enabled := FDocument.UndoRedo.RedoCount > 0;

  Self.mbUndo.Enabled := FDocument.UndoRedo.UndoCount > 0;
  Self.mbRedo.Enabled := FDocument.UndoRedo.RedoCount > 0;

  Self.UpdateStatusBar();
end;




procedure TMainForm.UpdatePropComboBox();

  procedure _UpdateLayerComboBox(AEntityList: TList);
  var
    I: Integer;
    LLayer: TUdLayer;
  begin
    LLayer := TUdEntity(AEntityList[0]).Layer;
    for I := 1 to AEntityList.Count - 1 do
    begin
      if (TUdEntity(AEntityList[I]).Layer <> LLayer) then
      begin
        LLayer := nil;
        Break;
      end;
    end;
    FLayerComboBox._SetItem(LLayer, False);
  end;

  procedure _UpdateColorComboBox(AEntityList: TList);
  var
    I: Integer;
    LTrueColor: TColor;
    LColor, LColor2: TUdColor;
  begin
    LColor := TUdEntity(AEntityList[0]).Color;
    LTrueColor := LColor.RGBValue;
    
    for I := 1 to AEntityList.Count - 1 do
    begin
      LColor2 := TUdEntity(AEntityList[I]).Color;

      if (LColor2.Name <> LColor.Name) then
      begin
        LColor := nil;
        Break;
      end
      else begin
        if LTrueColor <> clNone then
        begin
          if LTrueColor <> LColor2.RGBValue then
            LTrueColor := clNone;
        end;
      end;
    end;

    if Assigned(LColor) and (LTrueColor <> LColor.RGBValue) then LTrueColor := clNone;

    FColorComboBox._SetItem(LColor);
    if Assigned(LColor) and (LTrueColor = clNone) then
      FColorComboBox.SelectedValid := False;
  end;
  
  procedure _UpdateLineTypeComboBox(AEntityList: TList);
  var
    I: Integer;
    LValid: Boolean;
    LLineType, LLineType2: TUdLineType;
  begin
    LValid := True;
    LLineType := TUdEntity(AEntityList[0]).LineType;

    for I := 1 to AEntityList.Count - 1 do
    begin
      LLineType2 := TUdEntity(AEntityList[I]).LineType;

      if (LLineType2.Name <> LLineType.Name) then
      begin
        LLineType := nil;
        Break;
      end
      else begin
        if LValid and not IsEqual(LLineType2.SegmentLength, LLineType.SegmentLength) then
        begin
          LValid := False;
        end;
      end;
    end;
    FLntypComboBox._SetItem(LLineType);
    FLntypComboBox.SelectedValid := LValid;
  end;

  procedure _UpdateLineWeightComboBox(AEntityList: TList);
  var
    I: Integer;
    LLineWeight: TUdLineWeight;
  begin
    LLineWeight := TUdEntity(AEntityList[0]).LineWeight;
    for I := 1 to AEntityList.Count - 1 do
    begin
      if (TUdEntity(AEntityList[I]).LineWeight <> LLineWeight) then
      begin
        LLineWeight := 255;
        Break;
      end;
    end;
    FLwtComboBox._SetItem(LLineWeight);
  end;

var
  LEntityList: TList;
begin
  if not Self.FDocument.ActiveLayout.IsIdleAction then Exit; //======>>>

  LEntityList := FDocument.ActiveLayout.SelectedList;
  
  if LEntityList.Count <= 0 then
  begin
    FLayerComboBox.UpdateState();
    FColorComboBox.UpdateState();
    FLntypComboBox.UpdateState();
    FLwtComboBox.UpdateState();
  end
  else begin
    _UpdateLayerComboBox(LEntityList);
    _UpdateColorComboBox(LEntityList);
    _UpdateLineTypeComboBox(LEntityList);
    _UpdateLineWeightComboBox(LEntityList);
  end;
end;


procedure TMainForm.OnDocumentAddSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
var
  LList: TList;
begin
  if Self.FDocument.ActiveLayout.IsIdleAction then
  begin
    if pnlProperties.Visible then
    begin
      LList := TList.Create;
      try
        FPropsForm.RemoveInspObject(FDocument);

        UdUtils.GetEntitiesList(Entities, LList);
        FPropsForm.AddInspObjects(LList);
      finally
        LList.Free;
      end;
    end;

    Self.UpdatePropComboBox();
  end;
end;

procedure TMainForm.OnDocumentRemoveSelectedEntities(Sender: TObject; Entities: TUdEntityArray);
var
  LList: TList;
begin
  if Self.FDocument.ActiveLayout.IsIdleAction then
  begin
    if pnlProperties.Visible then
    begin
      if FPropsForm.InspObjectCount > 0 then
      begin
        LList := TList.Create;
        try
          UdUtils.GetEntitiesList(Entities, LList);
          FPropsForm.RemoveInspObjects(LList);

          if FPropsForm.InspObjectCount <= 0 then
            FPropsForm.AddInspObject(FDocument);
        finally
          LList.Free;
        end;
      end;
    end;

    Self.UpdatePropComboBox();
  end;
end;

procedure TMainForm.OnDocumentRemoveAllSelectedEntities(Sender: TObject);
begin
  if Self.FDocument.ActiveLayout.IsIdleAction  then
  begin
    if pnlProperties.Visible then
      FPropsForm.ClearInspObjects();

    Self.UpdatePropComboBox();
  end;
end;

procedure TMainForm.OnDocumentAfterObjectModify(Sender: TObject; AObj: TObject; APropName: string);
begin
  if pnlProperties.Visible then
  begin
    if Assigned(AObj) and AObj.InheritsFrom(TPersistent) then
      FPropsForm.ObjectModified(TPersistent(AObj));
  end;

  Self.UpdateStatusBar();
end;



procedure TMainForm.OnDocumentAxesChanging(Sender: TObject);
begin

end;

procedure TMainForm.OnDocumentAxesChanged(Sender: TObject);
begin
  if FPropsForm.NoSelection then FPropsForm.ObjectModified(FDocument);
end;






procedure TMainForm.OnLayerComboBoxSelect(Sender: TObject);
begin
  FColorComboBox.Invalidate();
  FLntypComboBox.Invalidate;
  FLwtComboBox.Invalidate();
end;

procedure TMainForm.OnColorComboBoxSelectOther(Sender: TObject);
begin
  if UdColorsFrm.ShowColorsDialog(FDocument.Colors) then
    FColorComboBox.Colors := FDocument.Colors;
end;

procedure TMainForm.OnLineTypeComboBoxSelectOther(Sender: TObject);
begin
  if UdLineTypesFrm.ShowLineTypesDialog(FDocument.LineTypes) then
    FLntypComboBox.LineTypes := FDocument.LineTypes;
end;


procedure TMainForm.OnLayerComboBoxSelecting(Sender: TObject; ALayer: TUdLayer; var AHandled: Boolean);
var
  I: Integer;
  LLayout: TUdLayout;
begin
  LLayout := FDocument.ActiveLayout;
  if Assigned(LLayout) and LLayout.IsIdleAction and (LLayout.SelectedList.Count > 0) then
  begin
    for I := 0 to LLayout.SelectedList.Count - 1 do
      TUdEntity(LLayout.SelectedList[I]).Layer := ALayer;
    AHandled := True;
  end;
end;

procedure TMainForm.OnColorComboBoxSelecting(Sender: TObject; AColor: TUdColor; var AHandled: Boolean);
var
  I: Integer;
  LLayout: TUdLayout;
begin
  LLayout := FDocument.ActiveLayout;
  if Assigned(LLayout) and LLayout.IsIdleAction and (LLayout.SelectedList.Count > 0) then
  begin
    for I := 0 to LLayout.SelectedList.Count - 1 do
      TUdEntity(LLayout.SelectedList[I]).Color := AColor;
    AHandled := True;
  end;
end;

procedure TMainForm.OnLineTypeComboBoxSelecting(Sender: TObject; ALineType: TUdLineType; var AHandled: Boolean);
var
  I: Integer;
  LLayout: TUdLayout;
begin
  LLayout := FDocument.ActiveLayout;
  if Assigned(LLayout) and LLayout.IsIdleAction and (LLayout.SelectedList.Count > 0) then
  begin
    for I := 0 to LLayout.SelectedList.Count - 1 do
      TUdEntity(LLayout.SelectedList[I]).LineType := ALineType;
    AHandled := True;
  end;
end;

procedure TMainForm.OnLineWeightComboBoxSelecting(Sender: TObject; ALineWeight: TUdLineWeight; var AHandled: Boolean);
var
  I: Integer;
  LLayout: TUdLayout;
begin
  LLayout := FDocument.ActiveLayout;
  if Assigned(LLayout) and LLayout.IsIdleAction and (LLayout.SelectedList.Count > 0) then
  begin
    for I := 0 to LLayout.SelectedList.Count - 1 do
      TUdEntity(LLayout.SelectedList[I]).LineWeight := ALineWeight;
    AHandled := True;
  end;
end;




procedure TMainForm.OnColorComboBoxGetUsrRGBColor(Sender: TObject; AColor: TUdColor; var ARRBColor: TColor; var AHandled: Boolean);
var
  LLayer: TUdLayer;
  LLayout: TUdLayout;
begin
  if AColor.Name = sByLayer then
  begin
    LLayout := FDocument.ActiveLayout;
    if Assigned(LLayout) and LLayout.IsIdleAction and (LLayout.SelectedList.Count > 0) then
    begin
      LLayer := FLayerComboBox.GetSelected();
      if Assigned(LLayer) then
      begin
        ARRBColor := LLayer.Color.RGBValue;
        AHandled := True;
      end;
    end;
  end;
end;
    

procedure TMainForm.OnLineTypeComboBoxGetUsrLineTypeValue(Sender: TObject; ALineType: TUdLineType; var AValue: TSingleArray; var AHandled: Boolean);
var
  LLayer: TUdLayer;
  LLayout: TUdLayout;
begin
  if ALineType.Name = sByLayer then
  begin
    LLayout := FDocument.ActiveLayout;
    if Assigned(LLayout) and LLayout.IsIdleAction and (LLayout.SelectedList.Count > 0) then
    begin
      LLayer := FLayerComboBox.GetSelected();
      if Assigned(LLayer) then
      begin
        AValue := LLayer.LineType.Value;
        AHandled := True;
      end;
    end;
  end;
end;


procedure TMainForm.OnDocumentProgress(Sender: TObject; AProgress: Integer; const AProgressMax: Integer; AMsg: string);
begin
  ProgressBar1.Visible := AProgress > 0;
//  ProgressBar1.Min := 0;
  ProgressBar1.Max := AProgressMax;
  ProgressBar1.Position := AProgress;
  ProgressBar1.Update();
end;


//==============================================================================================
{File...}

procedure TMainForm.acNewExecute(Sender: TObject);
begin
  FLayerComboBox.Layers := nil;
  FColorComboBox.Colors := nil;
  FLntypComboBox.LineTypes := nil;
  FLwtComboBox.LineWeights := nil;

  try
    Self.FDocument.Clear();
    FDrawPanel.Invalidate;
  finally
    FLayerComboBox.Layers    := FDocument.Layers     ;
    FColorComboBox.Colors    := FDocument.Colors     ;
    FLntypComboBox.LineTypes := FDocument.LineTypes  ;
    FLwtComboBox.LineWeights := FDocument.LineWeights;
  end;
end;

procedure TMainForm.acOpenExecute(Sender: TObject);
const
  kInvalidSymbol: string = 'Invalid Symbol Table name';
  kFixOptHint: string = '当前要打开的文件Symbol表有错误，请尝试以下操作：' + #13#10 +
                        '  1.把当前DWG文件使用AutoCAD打开;' + #13#10 +
                        '  2.选中全部图形后,进行"复制";' + #13#10 +
                        '  3.在AutoCAD中新建的文件，并进行"粘贴"' + #13#10 +
                        '  4.把该文件保存之后，再尝试重新打开！';

var
  LReturn: Boolean;
  LFileExt: string;
  LFileName: string;
  LTempDir, LDxfFile, LErrMsg: string;
begin
  LReturn := False;
//  SaveDialog1.InitialDir := SysUtils.ExtractFilePath(Application.ExeName);

  LTempDir := SysUtils.ExtractFilePath(Application.ExeName) + 'Temp';
  if not DirectoryExists(LTempDir) then ForceDirectories(LTempDir);

  if not OpenDialog1.Execute then Exit;

  Screen.Cursor := crHourGlass;
  try
    FLayerComboBox.Layers := nil;
    FColorComboBox.Colors := nil;
    FLntypComboBox.LineTypes := nil;
    FLwtComboBox.LineWeights := nil;

    FPropsForm.ClearInspObjects();

    LFileName := OpenDialog1.FileName;
    LFileExt  := ExtractFileExt(LFileName);

    if (UpperCase(LFileExt) = '.DWG') then
    begin
      LDxfFile := LTempDir + '\' + UdUtils.GetGUID(True) + '.DXF';
      if UdDxfConvert.DwgToDxf(LFileName, LDxfFile, LErrMsg) then
        LReturn := FDocument.LoadFromDxfFile(LDxfFile)
      else
      begin
        MessageBox(Self.Handle, PChar('打开文件出错：' + #13#10 + LErrMsg), '错误', MB_ICONWARNING or MB_OK);
        if LErrMsg = kInvalidSymbol then
          MessageBox(Self.Handle, PChar(kFixOptHint), '提示', MB_ICONINFORMATION or MB_OK);
      end;

      DeleteFile(LDxfFile);
    end
    else if (UpperCase(LFileExt) = '.DXF') then
      LReturn := FDocument.LoadFromDxfFile(LFileName)
    else if (UpperCase(LFileExt) = '.XML') then
      LReturn := FDocument.LoadFromXmlFile(LFileName)
    else
      LReturn := FDocument.LoadFromFile(LFileName);

    if LReturn then SetDocFile(LFileName);

    FLayerComboBox.Layers    := FDocument.Layers     ;
    FColorComboBox.Colors    := FDocument.Colors     ;
    FLntypComboBox.LineTypes := FDocument.LineTypes  ;
    FLwtComboBox.LineWeights := FDocument.LineWeights;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.acSaveExecute(Sender: TObject);
var
  LFileExt: string;
  LTempDir, LDxfFile, LErrMsg: string;
begin
  if (FDocFile = '') then
  begin
    acSaveAsExecute(Sender);
    Exit; //======>>>>
  end;

  LTempDir := SysUtils.ExtractFilePath(Application.ExeName) + 'Temp';
  if not DirectoryExists(LTempDir) then ForceDirectories(LTempDir);

  LFileExt := UpperCase(SysUtils.ExtractFileExt(FDocFile));


  Screen.Cursor := crHourGlass;
  try
    if LFileExt = '.DWG' then
    begin
      LDxfFile := LTempDir + '\' + UdUtils.GetGUID(True) + '.DXF';
      Self.FDocument.SaveToDxfFile(LDxfFile);

      if not UdDxfConvert.DxfToDwg(LDxfFile, FDocFile, LErrMsg) then
        MessageBox(Self.Handle, PChar('保存文件出错：' + #13#10 + LErrMsg), '错误', MB_ICONWARNING or MB_OK);

      DeleteFile(LDxfFile);
    end
    else
    if LFileExt = '.DXF' then
      Self.FDocument.SaveToDxfFile(FDocFile)
    else
    if LFileExt = '.XML' then
      Self.FDocument.SaveToXmlFile(FDocFile)
    else
      Self.FDocument.SaveToFile(FDocFile);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.acSaveAsExecute(Sender: TObject);
var
  LReturn: Boolean;
  LFileName: string;
  LFileExt, LFileExt2: string;
  LTempDir, LDxfFile, LErrMsg: string;
begin
  LTempDir := SysUtils.ExtractFilePath(Application.ExeName) + 'Temp';
  if not DirectoryExists(LTempDir) then ForceDirectories(LTempDir);

  if SaveDialog1.Execute then
  begin
    LFileName := SaveDialog1.FileName;
    LFileExt := UpperCase(SysUtils.ExtractFileExt(LFileName));

    LFileExt2 := '';
    case SaveDialog1.FilterIndex of
      1: LFileExt2 := '.XCAD';
      2: LFileExt2 := '.XML';
      3: LFileExt2 := '.DXF';
      4: LFileExt2 := '.DWG';
    end;

    if LFileExt <> LFileExt2 then
      LFileName := LFileName + LFileExt2;

//    if (LFileExt = '.DWG') or (LFileExt = '.DXF') then
//    begin
//      MessageBox(Self.Handle, '未授权用户，不能存为AutoCAD的文件格式！', '提示', MB_ICONWARNING or MB_OK);
//      Exit;
//    end;

    if LFileExt2 = '.DWG' then
    begin
      LDxfFile := LTempDir + '\' + UdUtils.GetGUID(True) + '.DXF';
      Self.FDocument.SaveToDxfFile(LDxfFile);

      LReturn := UdDxfConvert.DxfToDwg(LDxfFile, LFileName, LErrMsg);

      if not LReturn then
        MessageBox(Self.Handle, PChar('保存文件出错：' + #13#10 + LErrMsg), '错误', MB_ICONWARNING or MB_OK);

      DeleteFile(LDxfFile);
    end
    else
    if LFileExt2 = '.DXF' then
      LReturn := Self.FDocument.SaveToDxfFile(LFileName)
    else
    if LFileExt2 = '.XML' then
      LReturn := Self.FDocument.SaveToXmlFile(LFileName)
    else
      LReturn := Self.FDocument.SaveToFile(LFileName);

    if LReturn then Self.SetDocFile(LFileName);
  end;
end;

procedure TMainForm.acPreView2Decute(Sender: TObject);
begin
  //
end;

procedure TMainForm.acPrintExecute(Sender: TObject);
begin
  FDocument.ActiveLayout.ShowPlotForm();
end;

procedure TMainForm.acPrintSetupExecute(Sender: TObject);
begin
  //
end;

procedure TMainForm.acExitExecute(Sender: TObject);
begin
  Self.Close();
end;





//-----------------------------------------------------------------------------------------
{Edit...}

procedure TMainForm.acUndoExecute(Sender: TObject);
begin
  Self.FDocument.ExecCommond('undo');
end;

procedure TMainForm.acRedoExecute(Sender: TObject);
begin
  Self.FDocument.ExecCommond('redo');
end;

procedure TMainForm.acCutExecute(Sender: TObject);
begin
  Self.FDocument.ExecCommond('cutclip');
end;

procedure TMainForm.acCopyExecute(Sender: TObject);
begin
  Self.FDocument.ExecCommond('copyclip');
end;

procedure TMainForm.acPasteExecute(Sender: TObject);
begin
  Self.FDocument.ExecCommond('pasteclip');
end;

procedure TMainForm.acSelectAllExecute(Sender: TObject);
begin
  Self.FDocument.ExecCommond('selectall');
end;

procedure TMainForm.acClearExecute(Sender: TObject);
begin
  Self.FDocument.ExecCommond('clear');
end;






//-----------------------------------------------------------------------------------------
{View...}

procedure TMainForm.acPanRealExecute(Sender: TObject);
begin
  FDocument.ExecCommond('pan');
end;

procedure TMainForm.acPan2PExecute(Sender: TObject);
begin
  FDocument.ExecCommond('-pan');
end;


procedure TMainForm.acZoomRealExecute(Sender: TObject);
begin
  FDocument.ExecCommond('zoom real');
end;

procedure TMainForm.acZoomWinExecute(Sender: TObject);
begin
  FDocument.ExecCommond('zoom win');
end;

procedure TMainForm.acZoomInExecute(Sender: TObject);
begin
  FDocument.ExecCommond('zoom 2x');
end;

procedure TMainForm.acZoomOutExecute(Sender: TObject);
begin
  FDocument.ExecCommond('zoom 0.5x');
end;

procedure TMainForm.acZoomAllExecute(Sender: TObject);
begin
  FDocument.ExecCommond('zoom all');
end;

procedure TMainForm.acZoomExtendsExecute(Sender: TObject);
begin
  FDocument.ExecCommond('zoom ext');
end;


procedure TMainForm.acZoomPrevExecute(Sender: TObject);
begin
  FDocument.ExecCommond('zoom prev');
end;






//-----------------------------------------------------------------------------------------
{Format...}

procedure TMainForm.acLayerExecute(Sender: TObject);
begin
  FDocument.ExecCommond('layer');
end;

procedure TMainForm.acColorExecute(Sender: TObject);
begin
  FDocument.ExecCommond('color');
end;

procedure TMainForm.acLinetypeExecute(Sender: TObject);
begin
  FDocument.ExecCommond('linetype');
end;

procedure TMainForm.acLineWeightExecute(Sender: TObject);
begin
  FDocument.ExecCommond('lweight');
end;

procedure TMainForm.acTextStyleExecute(Sender: TObject);
begin
  FDocument.ExecCommond('textstyle');
end;

procedure TMainForm.acDimStyleExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimstyle');
  FColorComboBox.UpdateState();
  FLntypComboBox.UpdateState();
end;

procedure TMainForm.acPointStyleExecute(Sender: TObject);
begin
  FDocument.ExecCommond('ddptype');
end;


procedure TMainForm.acUnitsClick(Sender: TObject);
var
  LForm: TUdUnitsForm;
begin
  LForm := TUdUnitsForm.Create(nil);
  try
    LForm.Units := FDocument.Units;
    LForm.ShowModal();
  finally
    LForm.Free;
  end;
  
  FDocument.ExecCommond('units');
end;




//-----------------------------------------------------------------------------------------
{Tools...}

procedure TMainForm.acBringFrontExecute(Sender: TObject);
begin
  if TComponent(Sender).Tag = 1 then
    FDocument.ExecCommond('draworder a')
  else
    FDocument.ExecCommond('draworder f');
end;

procedure TMainForm.acSendBackExecute(Sender: TObject);
begin
  if TComponent(Sender).Tag = 1 then
    FDocument.ExecCommond('draworder u')
  else
    FDocument.ExecCommond('draworder b');
end;

procedure TMainForm.acDistanceExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dist');
end;

procedure TMainForm.acAreaExecute(Sender: TObject);
begin
  FDocument.ExecCommond('area');
end;

procedure TMainForm.acListExecute(Sender: TObject);
begin
  FDocument.ExecCommond('list');
end;

procedure TMainForm.acLocatePointExecute(Sender: TObject);
begin
  FDocument.ExecCommond('id');
end;

procedure TMainForm.acCalculatorExecute(Sender: TObject);
begin
  FDocument.ExecCommond('calc');
end;

procedure TMainForm.acLoadAppExecute(Sender: TObject);
begin
  //
end;

procedure TMainForm.acRunScriptExecute(Sender: TObject);
begin
  //
end;

procedure TMainForm.acDraftingSetting(Sender: TObject);
begin
  FDocument.ExecCommond('dsettings');
end;

procedure TMainForm.acSelectionExecute(Sender: TObject);
begin
  //
end;

procedure TMainForm.acPerferenceExecute(Sender: TObject);
begin
  //
end;





//-----------------------------------------------------------------------------------------
{Draw...}

procedure TMainForm.acLineExecute(Sender: TObject);
begin
  FDocument.ExecCommond('line');
end;

procedure TMainForm.acRayExecute(Sender: TObject);
begin
  FDocument.ExecCommond('ray');
end;

procedure TMainForm.acXLineExecute(Sender: TObject);
begin
  FDocument.ExecCommond('xline');
end;

procedure TMainForm.acPolylineExecute(Sender: TObject);
begin
  FDocument.ExecCommond('polyline');
end;


procedure TMainForm.acPolygonExecute(Sender: TObject);
begin
  FDocument.ExecCommond('polygon');
end;


procedure TMainForm.acRectExecute(Sender: TObject);
begin
//  FDocument.ExecCommond('rect');
  FDocument.ExecCommond('rectange');
end;

procedure TMainForm.acRect3PExecute(Sender: TObject);
begin
  FDocument.ExecCommond('rect 3p'); //
end;

procedure TMainForm.acRectCSAExecute(Sender: TObject);
begin
  FDocument.ExecCommond('rect c'); //
end;

procedure TMainForm.acCircleCRExecute(Sender: TObject);
begin
  FDocument.ExecCommond('circle');
end;

procedure TMainForm.acCircleCDExecute(Sender: TObject);
begin
  FDocument.ExecCommond('circle d');
end;

procedure TMainForm.acCircle2PExecute(Sender: TObject);
begin
  FDocument.ExecCommond('circle 2p');
end;

procedure TMainForm.acCircle3PExecute(Sender: TObject);
begin
  FDocument.ExecCommond('circle 3p');
end;

procedure TMainForm.acCircleTTRExecute(Sender: TObject);
begin
  FDocument.ExecCommond('circle ttr');
end;

procedure TMainForm.acCircleTTTExecute(Sender: TObject);
begin
  FDocument.ExecCommond('circle ttt');
end;

procedure TMainForm.acDonutExecute(Sender: TObject);
begin
  FDocument.ExecCommond('donut');
end;

procedure TMainForm.acSplineExecute(Sender: TObject);
begin
  FDocument.ExecCommond('spline');
end;

procedure TMainForm.acEllipseCExecute(Sender: TObject);
begin
  FDocument.ExecCommond('ellipse cen');
end;

procedure TMainForm.acEllipseAEExecute(Sender: TObject);
begin
  FDocument.ExecCommond('ellipse');
end;

procedure TMainForm.acEllipseArcExecute(Sender: TObject);
begin
  FDocument.ExecCommond('ellipse arc');
end;

procedure TMainForm.acMakeBlockExecute(Sender: TObject);
begin
  FDocument.ExecCommond('block');
end;

procedure TMainForm.acInsBlockExecute(Sender: TObject);
begin
  FDocument.ExecCommond('insert');
end;

procedure TMainForm.acPointExecute(Sender: TObject);
begin
  FDocument.ExecCommond('point');
end;

procedure TMainForm.acDivideExecute(Sender: TObject);
begin
  FDocument.ExecCommond('divide');
end;

procedure TMainForm.acMeasureExecute(Sender: TObject);
begin
  FDocument.ExecCommond('measure');
end;

procedure TMainForm.acHatchExecute(Sender: TObject);
begin
  FDocument.ExecCommond('hatch');
end;

procedure TMainForm.acRegionExecute(Sender: TObject);
begin
  FDocument.ExecCommond('region');
end;

procedure TMainForm.acSTextExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dtext');
end;

procedure TMainForm.acMTextExecute(Sender: TObject);
begin
  FDocument.ExecCommond('text');
end;

procedure TMainForm.acArc3PExecute(Sender: TObject);
begin
  FDocument.ExecCommond('arc');
end;


procedure TMainForm.acArcSCEClick(Sender: TObject);
begin
  FDocument.ExecCommond('arc sce');
end;

procedure TMainForm.acArcSCAClick(Sender: TObject);
begin
  FDocument.ExecCommond('arc sca');
end;

procedure TMainForm.acArcSCLClick(Sender: TObject);
begin
  FDocument.ExecCommond('arc scl');
end;

procedure TMainForm.acArcSEAClick(Sender: TObject);
begin
  FDocument.ExecCommond('arc sea');
end;

procedure TMainForm.acArcSEDClick(Sender: TObject);
begin
  FDocument.ExecCommond('arc sed');
end;

procedure TMainForm.acArcSERClick(Sender: TObject);
begin
  FDocument.ExecCommond('arc ser');
end;

procedure TMainForm.acArcCSEClick(Sender: TObject);
begin
  FDocument.ExecCommond('arc cse');
end;

procedure TMainForm.acArcCSAClick(Sender: TObject);
begin
  FDocument.ExecCommond('arc csa');
end;

procedure TMainForm.acArcCSLClick(Sender: TObject);
begin
  FDocument.ExecCommond('arc csl');
end;



//-----------------------------------------------------------------------------------------
{Dimention...}

procedure TMainForm.acDimLinearExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimlinear');
end;

procedure TMainForm.acDimAlignedExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimaligned');
end;

procedure TMainForm.acDimArcExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimarc');
end;

procedure TMainForm.acDimOrdinateExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimordinate');
end;

procedure TMainForm.acDimRadiusExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimradius');
end;

procedure TMainForm.acDimJoggedExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimjogged');
end;

procedure TMainForm.acDimDiameterExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimdiameter');
end;

procedure TMainForm.acDimAngularExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimangular');
end;



procedure TMainForm.acDimBaselineExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimbaseline');
end;

procedure TMainForm.acDimContinueExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimcontinue');
end;

procedure TMainForm.acDimLeaderExecute(Sender: TObject);
begin
  FDocument.ExecCommond('qleader');
end;

procedure TMainForm.acDimToleranceExecute(Sender: TObject);
begin
  FDocument.ExecCommond('tolerance');
end;

procedure TMainForm.acDimCenterExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimcenter');
end;


procedure TMainForm.acDimEditClick(Sender: TObject);
begin
//  FDocument.ExecCommond('dimedit');
end;

procedure TMainForm.acDimTextEditClick(Sender: TObject);
begin
  FDocument.ExecCommond('dimedit');
end;


procedure TMainForm.acDimTextAlignClick(Sender: TObject);
var
  LArg: string;
begin
  case TComponent(Sender).Tag of
    0: LArg := '';
    1: LArg := 'a';
    2: LArg := 'l';
    3: LArg := 'c';
    4: LArg := 'r';
  end;
  FDocument.ExecCommond('dimalign '+ LArg);
end;



procedure TMainForm.acDimUpdateExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimupdate');
end;

procedure TMainForm.acDimOverrideExecute(Sender: TObject);
begin
  FDocument.ExecCommond('dimoverride');
end;



//-----------------------------------------------------------------------------------------
{Modify...}

procedure TMainForm.acPropertiesExecute(Sender: TObject);
begin
//  FDocument.ExecCommond('properties');

  if pnlProperties.Visible then
  begin
    pnlPropertiesClose(pnlProperties);
  end
  else begin
    if Assigned(pnlProperties.CurrentDock) then
    begin
      if pnlProperties.CurrentDock = LeftMultiDock  then
        pnlLeft.Width := FPropPanelWidth  //pnlProperties.Width
      else if pnlProperties.CurrentDock = RightMultiDock then
        pnlRight.Width := FPropPanelWidth ;//pnlProperties.Width;

      sptProperties.Visible := True;
    end;

    pnlProperties.Visible := True;

    if pnlProperties.CurrentDock = LeftMultiDock then
    begin
      pnlLeft.Width := pnlLeft.Width + 1;
      pnlLeft.Width := pnlLeft.Width - 1;
    end
    else if pnlProperties.CurrentDock = RightMultiDock then
    begin
      pnlRight.Width := pnlRight.Width + 1;
      pnlRight.Width := pnlRight.Width - 1;
    end;

    FPropsForm.ClearInspObjects();
    
    if FDocument.ActiveLayout.SelectedList.Count > 0 then
    begin
      FPropsForm.RemoveInspObject(FDocument);
      FPropsForm.AddInspObjects(FDocument.ActiveLayout.SelectedList);
    end;
  end;
end;

procedure TMainForm.acMatchExecute(Sender: TObject);
begin
  FDocument.ExecCommond('matchprop');
end;

procedure TMainForm.acEraseExecute(Sender: TObject);
begin
  FDocument.ExecCommond('erase');
end;

procedure TMainForm.acCopyObjExecute(Sender: TObject);
begin
  FDocument.ExecCommond('copy');
end;

procedure TMainForm.acMirrorExecute(Sender: TObject);
begin
  FDocument.ExecCommond('mirror');
end;

procedure TMainForm.acOffsetExecute(Sender: TObject);
begin
  FDocument.ExecCommond('offset');
end;

procedure TMainForm.acArrayExecute(Sender: TObject);
begin
  FDocument.ExecCommond('array');
end;

procedure TMainForm.acMoveExecute(Sender: TObject);
begin
  FDocument.ExecCommond('move');
end;

procedure TMainForm.acRotateExecute(Sender: TObject);
begin
  FDocument.ExecCommond('rotate');
end;

procedure TMainForm.acScaleExecute(Sender: TObject);
begin
  FDocument.ExecCommond('scale');
end;

procedure TMainForm.acStretchExecute(Sender: TObject);
begin
  FDocument.ExecCommond('stretch');
end;

procedure TMainForm.acLengthenExecute(Sender: TObject);
begin
  FDocument.ExecCommond('lengthen');
end;

procedure TMainForm.acTrimExecute(Sender: TObject);
begin
  FDocument.ExecCommond('trim');
end;

procedure TMainForm.acExtendExecute(Sender: TObject);
begin
  FDocument.ExecCommond('extend');
end;

procedure TMainForm.acBreakExecute(Sender: TObject);
begin
  FDocument.ExecCommond('break');
end;

procedure TMainForm.acBreakAtPntExecute(Sender: TObject);
begin
  FDocument.ExecCommond('break 1pnt');
end;

procedure TMainForm.acChamferExecute(Sender: TObject);
begin
  FDocument.ExecCommond('chamfer');
end;

procedure TMainForm.acFilletExecute(Sender: TObject);
begin
  FDocument.ExecCommond('fillet');
end;

procedure TMainForm.acUnionExecute(Sender: TObject);
begin
  FDocument.ExecCommond('union');
end;

procedure TMainForm.acSubtractExecute(Sender: TObject);
begin
  FDocument.ExecCommond('subtract');
end;

procedure TMainForm.acIntersectExecute(Sender: TObject);
begin
  FDocument.ExecCommond('intersect');
end;

procedure TMainForm.acExplodeExecute(Sender: TObject);
begin
  FDocument.ExecCommond('explode');
end;

procedure TMainForm.acEditTextExecute(Sender: TObject);
begin
  FDocument.ExecCommond('edittext');
end;

procedure TMainForm.acEditHatchExecute(Sender: TObject);
begin
  FDocument.ExecCommond('edithatch');
end;





//-----------------------------------------------------------------------------------------
{Snap...}

procedure TMainForm.acSnapFromExecute(Sender: TObject);
begin
  //
end;

procedure TMainForm.acSnapEndExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_END;
end;

procedure TMainForm.acSnapMidExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_MID;
end;

procedure TMainForm.acSnapIntesExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_INT;
end;

procedure TMainForm.acSnapCenterExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_CEN;
end;

procedure TMainForm.acSnapQuadExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_QUA;
end;

procedure TMainForm.acSnapTanExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_TAN;
end;

procedure TMainForm.acSnapPerpExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_PER;
end;

procedure TMainForm.acSnapInsertExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_INS;
end;

procedure TMainForm.acSnapNodeExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_NOD;
end;

procedure TMainForm.acSnapNearestExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_NEA;
end;

procedure TMainForm.acSnapQuickExecute(Sender: TObject);
begin
  //
end;

procedure TMainForm.acSnapNoneExecute(Sender: TObject);
begin
  Self.FDocument.ActiveLayout.OSnapMode := OSNP_NUL;
end;

procedure TMainForm.acSnapSettingExecute(Sender: TObject);
begin
  //
end;








//==================================================================================================


procedure TMainForm.btnAddLineClick(Sender: TObject);
var
  LData: TSegment2D;
  LShape: TUdLine;
begin
  LData := StrToSegment2D(ShowInputForm('', 'Input TSegment2D'));

  if NotEqual(LData.P1, LData.P2) then
  begin
    LShape := TUdLine.Create();
    LShape.XData := LData;

    FDocument.ActiveLayout.Entities.Add(LShape);
  end;

  FDocument.ActiveLayout.Invalidate;
end;

procedure TMainForm.btnAddCircleClick(Sender: TObject);
var
  LData: TCircle2D;
  LShape: TUdCircle;
begin
  LData := StrToCircle2D(ShowInputForm('', 'Input TArc2D'));
  if LData.R > 0 then
  begin
    LShape := TUdCircle.Create();
    LShape.XData := LData;

    FDocument.ActiveLayout.Entities.Add(LShape);
  end;

  FDocument.ActiveLayout.Invalidate;
end;

procedure TMainForm.btnAddEllipseClick(Sender: TObject);
var
  LData: TEllipse2D;
  LShape: TUdEllipse;
begin
  LData := StrToEllipse2D(ShowInputForm('', 'Input TEllipse2D'));
  if NotEqual(LData.Rx, 0) and NotEqual(LData.Ry, 0.0) then
  begin
    LShape := TUdEllipse.Create();
    LShape.XData := LData;

    FDocument.ActiveLayout.Entities.Add(LShape);
  end;

  FDocument.ActiveLayout.Invalidate;
end;



procedure TMainForm.btnAddArcClick(Sender: TObject);
var
  LData: TArc2D;
  LShape: TUdArc;
begin
  LData := StrToArc2D(ShowInputForm('', 'Input TArc2D'));
  if LData.R > 0 then
  begin
    LShape := TUdArc.Create();
    LShape.XData := LData;

    FDocument.ActiveLayout.Entities.Add(LShape);
  end;

  FDocument.ActiveLayout.Invalidate;
end;




procedure TMainForm.btnAddPointsClick(Sender: TObject);
var
  LData: TPoint2DArray;
  LShape: TUdPolyline;
begin
  StrToArray(ShowInputForm('', 'Input TPoint2DArray'), LData);

  if Length(LData) > 0 then
  begin
    LShape := TUdPolyline.Create();
    LShape.SetPoints(LData);

    FDocument.ActiveLayout.Entities.Add(LShape);
  end;

  FDocument.ActiveLayout.Invalidate;
end;

procedure TMainForm.btnAddPolylineClick(Sender: TObject);
begin
  //
end;

procedure TMainForm.btnAddSegarcClick(Sender: TObject);
var
  LData: TSegarc2D;
  LShape: TUdEntity;
begin
  LData := StrToSegarc2D(ShowInputForm('', 'Input TSegarc2D'));
  if LData.IsArc then
  begin
    LShape := TUdArc.Create();
    TUdArc(LShape).XData := LData.Arc;
  end
  else
  begin
    LShape := TUdLine.Create();
    TUdLine(LShape).XData := LData.Seg;
  end;

  FDocument.ActiveLayout.Entities.Add(LShape);
  FDocument.ActiveLayout.Invalidate;
end;

procedure TMainForm.btnAddSegarcsClick(Sender: TObject);
var
  LData: TSegarc2DArray;
  LShape: TUdPolyline;
begin
  StrToArray(ShowInputForm('', 'Input TSegarc2DArray'), LData);
  if Length(LData) > 0 then
  begin
    LShape := TUdPolyline.Create();
    LShape.XData := LData;

    FDocument.ActiveLayout.Entities.Add(LShape);
  end;

  FDocument.ActiveLayout.Invalidate;
end;





//-------------------------------------------------------------------------------------------------

procedure TMainForm.btnArrowBlocksClick(Sender: TObject);
var
  LXmlDocument: TUdXMLDocument;
begin
  LXmlDocument := TUdXMLDocument.Create;
  try
    LXmlDocument.AutoIndent := True;
    Self.FDocument.Blocks.SaveToXml(LXmlDocument.Root);

    LXmlDocument.SaveToFile('E:\ArrowBlocks.xml');
  finally
    LXmlDocument.Free;
  end;
end;

procedure TMainForm.btnLoopSearchClick(Sender: TObject);
var
  I: Integer;
  LRect, LRct: TRect2D;
  LList: TList;
  LEntity: TUdEntity;
  LSegarcs: TSegarc2DArray;
  LLoopSearch: TUdLoopSearch;
  LPolylineObj: TUdPolyline;
begin
  LList := TList.Create;
  LLoopSearch := TUdLoopSearch.Create();
  try
    for I := 0 to FDocument.ActiveLayout.Selection.Count - 1 do
    begin
      LEntity := FDocument.ActiveLayout.Selection.Items[I];

      if LEntity.TypeID in [ID_LINE, ID_RECT, ID_CIRCLE, ID_ARC, ID_POLYLINE, ID_ELLIPSE, ID_SPLINE] then
      begin
        case LEntity.TypeID of
          ID_LINE     : LLoopSearch.Add(TUdLine(LEntity).XData);
          ID_RECT     : LLoopSearch.Add(TUdRect(LEntity).XData);
          ID_CIRCLE   : LLoopSearch.Add(Arc2D(TUdCircle(LEntity).XData.Cen, TUdCircle(LEntity).XData.R, 0, 360));
          ID_ARC      : LLoopSearch.Add(TUdArc(LEntity).XData);
          ID_POLYLINE : LLoopSearch.Add(TUdPolyline(LEntity).XData);

          ID_ELLIPSE,
           ID_SPLINE : LLoopSearch.Add(TUdFigure(LEntity).SamplePoints);
        end;

        LList.Add(LEntity);
      end;
    end;

    LLoopSearch.Search();

    if Length(LLoopSearch.MaxLoops) > 0 then
    begin
      LRect := UdGeo2D.RectHull(LLoopSearch.MaxLoops[0]);
      for I := 1 to Length(LLoopSearch.MaxLoops) - 1 do
      begin
        LRct := UdGeo2D.RectHull(LLoopSearch.MaxLoops[I]);
        if LRect.X1 > LRct.X1 then LRect.X1 := LRct.X1;
        if LRect.X2 < LRct.X2 then LRect.X2 := LRct.X2;
        if LRect.Y1 > LRct.Y1 then LRect.Y1 := LRct.Y1;
        if LRect.Y2 < LRct.Y2 then LRect.Y2 := LRct.Y2;
      end;
    end;

    for I := 0 to Length(LLoopSearch.MinLoops) - 1 do
    begin
      LSegarcs := LLoopSearch.MinLoops[I];
      LSegarcs := UdGeo2D.Translate(Abs(LRect.X2 - LRect.X1) * 1.1, 0, LSegarcs);

      LPolylineObj := TUdPolyline.Create();
      LPolylineObj.Color.TrueColor := clBlue;
      LPolylineObj.Vertexes := Vertexes2D(LSegarcs);
      FDocument.ActiveLayout.AddEntity(LPolylineObj);
    end;

    for I := 0 to Length(LLoopSearch.MaxLoops) - 1 do
    begin
      LSegarcs := LLoopSearch.MaxLoops[I];
      LSegarcs := UdGeo2D.Translate(0, -Abs(LRect.Y2 - LRect.Y1) * 1.1, LSegarcs);

      LPolylineObj := TUdPolyline.Create();
      LPolylineObj.Color.TrueColor := clRed;
      LPolylineObj.Vertexes := Vertexes2D(LSegarcs);
      FDocument.ActiveLayout.AddEntity(LPolylineObj);
    end;
  finally
    LList.Free;
    LLoopSearch.Free;
  end;
end;

procedure TMainForm.btnAddImageClick(Sender: TObject);
var
  LImage: TUdImage;
begin
  LImage := TUdImage.Create();
  LImage.Position := Point2D(0, 0);
  LImage.Bitmap.LoadFromFile('E:\Documents\map01.bmp');
  FDocument.ActiveLayout.AddEntity(LImage);
  FDocument.ActiveLayout.ZoomAll();
end;

procedure TMainForm.btnAddFogClick(Sender: TObject);
var
  I: Integer;
  LPntObj: TUdPoint;
begin
  Randomize();
  for I := 0 to 300 do
  begin
    LPntObj := TUdPoint.Create();
    LPntObj.Position := Point2D(Random(600), Random(500));
    FDocument.ActiveLayout.AddEntity(LPntObj);
    FFogPntsList.Add(LPntObj);
  end;
  FogTimer.Enabled := True;
end;

procedure TMainForm.FogTimerTimer(Sender: TObject);
var
  I: Integer;
  LPntObj: TUdPoint;
begin
  FogTimer.Enabled := False;

  Randomize();
  for I := 0 to FFogPntsList.Count - 1 do
  begin
    LPntObj := FFogPntsList[I];
    LPntObj.Position := Point2D(LPntObj.Position.X + Random(5), LPntObj.Position.Y + Random(4));
  end;

  FogTimer.Enabled := True;
end;


//--------------------------------------------------------------------------------------------------

procedure TMainForm.mbAboutClick(Sender: TObject);
var
  LAboutForm: TAboutForm;
begin
  LAboutForm := TAboutForm.Create(nil);
  try
    LAboutForm.ShowModal();
  finally
    LAboutForm.Free;
  end;
end;




end.

