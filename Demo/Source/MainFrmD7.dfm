object MainForm: TMainForm
  Left = 123
  Top = 73
  Width = 1122
  Height = 691
  Caption = 'Delphi CAD'
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Splitter1: TSplitter
    Left = 0
    Top = 496
    Width = 1114
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    Color = clSkyBlue
    ParentColor = False
  end
  object TopDock: TTBDock
    Left = 0
    Top = 0
    Width = 1114
    Height = 75
    object MenuToolbar: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'Menu'
      CloseButton = False
      DefaultDock = TopDock
      DockPos = 0
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      FullSize = True
      MenuBar = True
      ParentFont = False
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object mnFile: TTBSubmenuItem
        Caption = #25991#20214'(&F)'
        object mbNew: TTBItem
          Caption = #26032#24314'...'
          ImageIndex = 0
          Images = BitmapsModule.imgsStd
          ShortCut = 16462
          OnClick = acNewExecute
        end
        object mbOpen: TTBItem
          Caption = #25171#24320'...'
          ImageIndex = 1
          Images = BitmapsModule.imgsStd
          ShortCut = 16463
          OnClick = acOpenExecute
        end
        object TBXSeparatorItem1: TTBSeparatorItem
        end
        object mbSave: TTBItem
          Caption = #20445#23384
          ImageIndex = 2
          Images = BitmapsModule.imgsStd
          ShortCut = 16467
          OnClick = acSaveExecute
        end
        object mbSaveAs: TTBItem
          Caption = #21478#23384#20026'(&A)...'
          ImageIndex = 3
          Images = BitmapsModule.imgsStd
          OnClick = acSaveAsExecute
        end
        object TBXSeparatorItem2: TTBSeparatorItem
        end
        object mbPreview: TTBItem
          Caption = #25171#21360#39044#35272
          ImageIndex = 4
          Images = BitmapsModule.imgsStd
          Visible = False
          OnClick = acPreView2Decute
        end
        object mbPrint: TTBItem
          Caption = #25171#21360
          ImageIndex = 5
          Images = BitmapsModule.imgsStd
          OnClick = acPrintExecute
        end
        object TBXSeparatorItem3: TTBSeparatorItem
        end
        object mbHistory: TTBSubmenuItem
          Caption = #21382#21490#25991#20214
        end
        object TBXSeparatorItem40: TTBSeparatorItem
        end
        object mbExit: TTBItem
          Caption = #36864#20986
          Images = BitmapsModule.imgsStd
          OnClick = acExitExecute
        end
      end
      object mnEdit: TTBSubmenuItem
        Caption = #32534#36753'(&E)'
        object mbUndo: TTBItem
          Caption = #25764#38144
          ImageIndex = 9
          Images = BitmapsModule.imgsStd
          ShortCut = 16474
          OnClick = acUndoExecute
        end
        object mbRedo: TTBItem
          Caption = #37325#20570
          ImageIndex = 10
          Images = BitmapsModule.imgsStd
          ShortCut = 16473
          OnClick = acRedoExecute
        end
        object TBXSeparatorItem4: TTBSeparatorItem
        end
        object mbCut: TTBItem
          Caption = #21098#20999
          ImageIndex = 6
          Images = BitmapsModule.imgsStd
          ShortCut = 16472
          OnClick = acCutExecute
        end
        object mbCopyClip: TTBItem
          Caption = #22797#21046
          ImageIndex = 7
          Images = BitmapsModule.imgsStd
          ShortCut = 16451
          OnClick = acCopyExecute
        end
        object mbPaste: TTBItem
          Caption = #31896#36148
          ImageIndex = 8
          Images = BitmapsModule.imgsStd
          ShortCut = 16470
          OnClick = acPasteExecute
        end
        object TBXSeparatorItem11: TTBSeparatorItem
        end
        object mbClear: TTBItem
          Caption = #28165#38500
          Images = BitmapsModule.imgsStd
          OnClick = acClearExecute
        end
        object mbSelectAll: TTBItem
          Caption = #36873#25321#20840#37096
          Images = BitmapsModule.imgsStd
          OnClick = acSelectAllExecute
        end
      end
      object mnView: TTBSubmenuItem
        Caption = #35270#22270'(&V)'
        object mbPan: TTBItem
          Caption = #23454#26102#24179#31227
          ImageIndex = 12
          Images = BitmapsModule.imgsStd
          OnClick = acPanRealExecute
        end
        object mbPan2P: TTBItem
          Caption = #20004#28857#24179#31227
          Images = BitmapsModule.imgsStd
          OnClick = acPan2PExecute
        end
        object TBXSeparatorItem5: TTBSeparatorItem
        end
        object mbZoomReal: TTBItem
          Caption = #23454#26102#32553#25918
          ImageIndex = 13
          Images = BitmapsModule.imgsStd
          OnClick = acZoomRealExecute
        end
        object mbZoomWindow: TTBItem
          Caption = #31383#21475#32553#25918
          ImageIndex = 14
          Images = BitmapsModule.imgsStd
          OnClick = acZoomWinExecute
        end
        object TBXSeparatorItem39: TTBSeparatorItem
        end
        object mbZoomIn: TTBItem
          Caption = #25918#22823
          ImageIndex = 17
          Images = BitmapsModule.imgsStd
          OnClick = acZoomInExecute
        end
        object mbZoomOut: TTBItem
          Caption = #32553#23567
          ImageIndex = 18
          Images = BitmapsModule.imgsStd
          OnClick = acZoomOutExecute
        end
        object mbZoomAll: TTBItem
          Caption = #26174#31034#20840#37096
          ImageIndex = 15
          Images = BitmapsModule.imgsStd
          OnClick = acZoomAllExecute
        end
        object mbZoomExtends: TTBItem
          Caption = #26174#31034#33539#22260
          ImageIndex = 16
          Images = BitmapsModule.imgsStd
          OnClick = acZoomExtendsExecute
        end
        object mbZoomPrev: TTBItem
          Caption = #19978#19968#35270#22270
          ImageIndex = 19
          Images = BitmapsModule.imgsStd
          OnClick = acZoomPrevExecute
        end
        object TBXSeparatorItem62: TTBSeparatorItem
        end
        object mbDispaly: TTBItem
          Caption = 'Dispaly'
          Visible = False
        end
        object mbToolbar: TTBItem
          Caption = 'Toolbar...'
          Visible = False
        end
      end
      object mnFormat: TTBSubmenuItem
        Caption = #26684#24335'(&F)'
        object mbLayer: TTBItem
          Caption = #22270#23618'...'
          ImageIndex = 1
          Images = BitmapsModule.ImgsLayer
          OnClick = acLayerExecute
        end
        object mbColor: TTBItem
          Caption = #39068#33394'...'
          OnClick = acColorExecute
        end
        object mbLinetype: TTBItem
          Caption = #32447#24418'...'
          ImageIndex = 2
          Images = BitmapsModule.ImgsLayer
          OnClick = acLinetypeExecute
        end
        object mbLineWeight: TTBItem
          Caption = #32447#23485'...'
          OnClick = acLineWeightExecute
        end
        object TBXSeparatorItem9: TTBSeparatorItem
        end
        object mbTextStyle: TTBItem
          Caption = #25991#23383#26679#24335'...'
          OnClick = acTextStyleExecute
        end
        object mbDimentionStyle: TTBItem
          Caption = #26631#27880#26679#24335'...'
          ImageIndex = 17
          Images = BitmapsModule.imgsDim
          OnClick = acDimStyleExecute
        end
        object mbPointStyle: TTBItem
          Caption = #28857#26679#24335'...'
          OnClick = acPointStyleExecute
        end
        object TBXSeparatorItem10: TTBSeparatorItem
        end
        object mbUnits: TTBItem
          Caption = #21333#20301'...'
          OnClick = acUnitsClick
        end
      end
      object mnTools: TTBSubmenuItem
        Caption = #24037#20855'(&T)'
        object mbDisOrder: TTBSubmenuItem
          Caption = #26174#31034#39034#24207
          object mbBringFront: TTBItem
            Caption = #21069#32622
            ImageIndex = 0
            Images = BitmapsModule.imgsDisOrder
            OnClick = acBringFrontExecute
          end
          object mbSendBack: TTBItem
            Caption = #21518#32622
            ImageIndex = 1
            Images = BitmapsModule.imgsDisOrder
            OnClick = acSendBackExecute
          end
          object SpTBXSeparatorItem12: TTBSeparatorItem
          end
          object mbBringAbove: TTBItem
            Tag = 1
            Caption = #32622#20110#23545#35937#20043#19978
            ImageIndex = 2
            Images = BitmapsModule.imgsDisOrder
            OnClick = acBringFrontExecute
          end
          object mbSendUnder: TTBItem
            Tag = 1
            Caption = #32622#20110#23545#35937#20043#19979
            ImageIndex = 3
            Images = BitmapsModule.imgsDisOrder
            OnClick = acSendBackExecute
          end
        end
        object mbInquiry: TTBSubmenuItem
          Caption = #26597#35810
          object mbDistance: TTBItem
            Caption = #36317#31163
            ImageIndex = 0
            Images = BitmapsModule.imgsInquiry
            OnClick = acDistanceExecute
          end
          object mbArea: TTBItem
            Caption = #38754#31215
            ImageIndex = 1
            Images = BitmapsModule.imgsInquiry
            OnClick = acAreaExecute
          end
          object TBXSeparatorItem66: TTBSeparatorItem
            Visible = False
          end
          object mbList: TTBItem
            Caption = 'List'
            ImageIndex = 3
            Images = BitmapsModule.imgsInquiry
            Visible = False
            OnClick = acListExecute
          end
          object mbLocatePoint: TTBItem
            Caption = #20301#32622
            ImageIndex = 4
            Images = BitmapsModule.imgsInquiry
            OnClick = acLocatePointExecute
          end
        end
        object mbCalculator: TTBItem
          Caption = #35745#31639#22120'...'
          ImageIndex = 22
          Images = BitmapsModule.imgsStd
          Visible = False
          OnClick = acCalculatorExecute
        end
        object TBXSeparatorItem8: TTBSeparatorItem
        end
        object mbLoadApp: TTBItem
          Caption = 'Load Application'
          Visible = False
          OnClick = acLoadAppExecute
        end
        object mbRunScript: TTBItem
          Caption = 'Run Script'
          Visible = False
          OnClick = acRunScriptExecute
        end
        object TBXSeparatorItem16: TTBSeparatorItem
        end
        object mbSelection: TTBItem
          Caption = 'Selection...'
          Visible = False
          OnClick = acSelectionExecute
        end
        object mbDraftingSettinh: TTBItem
          Caption = #33609#22270#35774#32622'...'
          Images = BitmapsModule.imgsStd
          OnClick = acDraftingSetting
        end
        object mbOptions: TTBItem
          Caption = #36873#39033'...'
          OnClick = acPerferenceExecute
        end
        object TBXSeparatorItem17: TTBSeparatorItem
        end
        object mbSkins: TTBSubmenuItem
          Caption = #30382#32932
        end
      end
      object mnDraw: TTBSubmenuItem
        Caption = #32472#22270'(&D)'
        object mbLine: TTBItem
          Caption = #30452#32447
          ImageIndex = 0
          Images = BitmapsModule.imgsDraw
          OnClick = acLineExecute
        end
        object mbRay: TTBItem
          Caption = #23556#32447
          ImageIndex = 1
          Images = BitmapsModule.imgsDraw
          OnClick = acRayExecute
        end
        object mbXLine: TTBItem
          Caption = #26500#36896#32447
          ImageIndex = 2
          Images = BitmapsModule.imgsDraw
          OnClick = acXLineExecute
        end
        object TBXSeparatorItem18: TTBSeparatorItem
        end
        object mbPolyline: TTBItem
          Caption = #22810#27573#32447
          ImageIndex = 3
          Images = BitmapsModule.imgsDraw
          OnClick = acPolylineExecute
        end
        object mbPolygon: TTBItem
          Caption = #22810#36793#24418
          ImageIndex = 4
          Images = BitmapsModule.imgsDraw
          OnClick = acPolygonExecute
        end
        object mbRectangle: TTBSubmenuItem
          Caption = #30697#24418
          ImageIndex = 5
          Images = BitmapsModule.imgsDraw
          object mbRect2P: TTBItem
            Caption = #20004#28857
            OnClick = acRectExecute
          end
          object mbRect3P: TTBItem
            Caption = #19977#28857
            OnClick = acRect3PExecute
          end
          object mbRectCSA: TTBItem
            Caption = #20013#24515','#22823#23567','#35282#24230
            OnClick = acRectCSAExecute
          end
        end
        object TBXSeparatorItem19: TTBSeparatorItem
        end
        object mbArc: TTBSubmenuItem
          Caption = #22278#24359
          ImageIndex = 6
          Images = BitmapsModule.imgsDraw
          object mbArc3P: TTBItem
            Caption = #19977#28857
            OnClick = acArc3PExecute
          end
          object TBXSeparatorItem20: TTBSeparatorItem
          end
          object mbArcSCE: TTBItem
            Caption = #36215#28857', '#22278#24515', '#31471#28857
            Visible = False
            OnClick = acArcSCEClick
          end
          object mbArcSCA: TTBItem
            Caption = #36215#28857', '#22278#24515', '#35282#24230
            Visible = False
            OnClick = acArcSCAClick
          end
          object mbArcSCL: TTBItem
            Caption = #36215#28857', '#22278#24515', '#38271#24230
            Visible = False
            OnClick = acArcSCLClick
          end
          object TBXSeparatorItem76: TTBSeparatorItem
            Visible = False
          end
          object mbArcSEA: TTBItem
            Caption = #36215#28857',  '#31471#28857', '#35282#24230
            Visible = False
            OnClick = acArcSEAClick
          end
          object mbArcSED: TTBItem
            Caption = #36215#28857',  '#31471#28857',  '#26041#21521
            Visible = False
            OnClick = acArcSEDClick
          end
          object mbArcSER: TTBItem
            Caption = #36215#28857',  '#31471#28857',  '#21322#24452
            Visible = False
            OnClick = acArcSERClick
          end
          object TBXSeparatorItem75: TTBSeparatorItem
            Visible = False
          end
          object mbArcCSE: TTBItem
            Caption = #22278#24515', '#36215#28857', '#31471#28857
            OnClick = acArcCSEClick
          end
          object mbArcCSA: TTBItem
            Caption = #22278#24515', '#36215#28857', '#35282#24230
            OnClick = acArcCSAClick
          end
          object mbArcCSL: TTBItem
            Caption = #22278#24515', '#36215#28857', '#38271#24230
            OnClick = acArcCSLClick
          end
        end
        object mbCircle: TTBSubmenuItem
          Caption = #22278
          ImageIndex = 10
          Images = BitmapsModule.imgsDraw
          object mbCirCR: TTBItem
            Caption = #22278#24515', '#21322#24452
            OnClick = acCircleCRExecute
          end
          object mbCirCD: TTBItem
            Caption = #22278#24515', '#30452#24452
            Visible = False
            OnClick = acCircleCDExecute
          end
          object TBXSeparatorItem21: TTBSeparatorItem
          end
          object mbCir2P: TTBItem
            Caption = #20004#28857
            OnClick = acCircle2PExecute
          end
          object mbCir3P: TTBItem
            Caption = #19977#28857
            OnClick = acCircle3PExecute
          end
          object TBXSeparatorItem22: TTBSeparatorItem
            Visible = False
          end
          object mbCirTTT: TTBItem
            Caption = 'Tan, Tan, Tan'
            Visible = False
            OnClick = acCircleTTTExecute
          end
          object mbCirTTR: TTBItem
            Caption = 'Tan, Tan, Radius'
            Visible = False
            OnClick = acCircleTTRExecute
          end
        end
        object mbDount: TTBItem
          Caption = #22278#29615
          ImageIndex = 20
          Images = BitmapsModule.imgsDraw
          OnClick = acDonutExecute
        end
        object mbSpline: TTBItem
          Caption = #26679#26465#26354#32447
          ImageIndex = 18
          Images = BitmapsModule.imgsDraw
          OnClick = acSplineExecute
        end
        object mbEllipse: TTBSubmenuItem
          Caption = #26925#22278
          ImageIndex = 14
          Images = BitmapsModule.imgsDraw
          object mbEllipseAE: TTBItem
            Caption = #36724', '#31471#28857
            OnClick = acEllipseAEExecute
          end
          object mbEllipseC: TTBItem
            Caption = #20013#24515#28857
            OnClick = acEllipseCExecute
          end
          object SpTBXSeparatorItem7: TTBSeparatorItem
          end
          object mbEllipseArc: TTBItem
            Caption = #26925#22278#24359
          end
        end
        object TBXSeparatorItem24: TTBSeparatorItem
        end
        object TBXSubmenuItem1: TTBSubmenuItem
          Caption = #22359
          ImageIndex = 17
          Images = BitmapsModule.imgsDraw
          object mbInsBlock: TTBItem
            Caption = #25554#20837#22359
            ImageIndex = 16
            Images = BitmapsModule.imgsDraw
            OnClick = acInsBlockExecute
          end
          object mbMakeBlock: TTBItem
            Caption = #21019#24314#22359
            ImageIndex = 17
            Images = BitmapsModule.imgsDraw
            OnClick = acMakeBlockExecute
          end
        end
        object mbPoint: TTBSubmenuItem
          Caption = #28857
          ImageIndex = 21
          Images = BitmapsModule.imgsDraw
          object mbMPoint: TTBItem
            Caption = #21333#28857
            ImageIndex = 21
            Images = BitmapsModule.imgsDraw
            OnClick = acPointExecute
          end
          object TBXSeparatorItem25: TTBSeparatorItem
          end
          object mbDivide: TTBItem
            Caption = #23450#25968#31561#20998
            ImageIndex = 22
            Images = BitmapsModule.imgsDraw
            OnClick = acDivideExecute
          end
          object mbMeasure: TTBItem
            Caption = #23450#36317#31561#20998
            ImageIndex = 23
            Images = BitmapsModule.imgsDraw
          end
        end
        object TBXSeparatorItem26: TTBSeparatorItem
        end
        object mbHatch: TTBItem
          Caption = #22270#26696#22635#20805'...'
          ImageIndex = 26
          Images = BitmapsModule.imgsDraw
          OnClick = acHatchExecute
        end
        object mbRegion: TTBItem
          Caption = 'Region'
          ImageIndex = 27
          Images = BitmapsModule.imgsDraw
          Visible = False
          OnClick = acRegionExecute
        end
        object TBXSeparatorItem27: TTBSeparatorItem
        end
        object mbText: TTBSubmenuItem
          Caption = #25991#23383
          ImageIndex = 24
          Images = BitmapsModule.imgsDraw
          object mbMText: TTBItem
            Caption = #22810#34892#25991#23383
            OnClick = acMTextExecute
          end
          object mbSText: TTBItem
            Caption = #21333#34892#25991#23383
            OnClick = acSTextExecute
          end
        end
      end
      object mnDimention: TTBSubmenuItem
        Caption = #26631#27880'(&D)'
        object mbDimLinear: TTBItem
          Caption = #32447#24615
          ImageIndex = 0
          Images = BitmapsModule.imgsDim
          OnClick = acDimLeaderExecute
        end
        object mbDimAligned: TTBItem
          Caption = #23545#20854
          ImageIndex = 1
          Images = BitmapsModule.imgsDim
          OnClick = acDimAlignedExecute
        end
        object mbDimArcLength: TTBItem
          Caption = #24359#38271
          ImageIndex = 2
          Images = BitmapsModule.imgsDim
          OnClick = acDimArcExecute
        end
        object mbDimOrdinate: TTBItem
          Caption = #22352#26631
          ImageIndex = 3
          Images = BitmapsModule.imgsDim
          OnClick = acDimOrdinateExecute
        end
        object TBXSeparatorItem28: TTBSeparatorItem
        end
        object mbDimRadius: TTBItem
          Caption = #21322#24452
          ImageIndex = 4
          Images = BitmapsModule.imgsDim
          OnClick = acDimRadiusExecute
        end
        object mbDimJogged: TTBItem
          Caption = #25240#24367
          ImageIndex = 5
          Images = BitmapsModule.imgsDim
          OnClick = acDimJoggedExecute
        end
        object mbDimDiameter: TTBItem
          Caption = #30452#24452
          ImageIndex = 6
          Images = BitmapsModule.imgsDim
          OnClick = acDimDiameterExecute
        end
        object mbDimAngular: TTBItem
          Caption = #35282#24230
          ImageIndex = 7
          Images = BitmapsModule.imgsDim
          OnClick = acDimAngularExecute
        end
        object TBXSeparatorItem29: TTBSeparatorItem
        end
        object mbDimBaseline: TTBItem
          Caption = #22522#32447
          ImageIndex = 9
          Images = BitmapsModule.imgsDim
        end
        object mbDimContinue: TTBItem
          Caption = #36830#32493
          ImageIndex = 10
          Images = BitmapsModule.imgsDim
          OnClick = acDimContinueExecute
        end
        object TBXSeparatorItem30: TTBSeparatorItem
        end
        object mbDimLeader: TTBItem
          Caption = #24341#32447
          ImageIndex = 11
          Images = BitmapsModule.imgsDim
          OnClick = acDimLeaderExecute
        end
        object mbDimTolerance: TTBItem
          Caption = #20844#24046'...'
          ImageIndex = 12
          Images = BitmapsModule.imgsDim
          OnClick = acDimToleranceExecute
        end
        object mbDimCenter: TTBItem
          Caption = #22278#24515#26631#35760
          ImageIndex = 13
          Images = BitmapsModule.imgsDim
          OnClick = acDimCenterExecute
        end
        object TBXSeparatorItem31: TTBSeparatorItem
        end
        object mbDimEdit: TTBItem
          Caption = #32534#36753
          ImageIndex = 15
          Images = BitmapsModule.imgsDim
          OnClick = acDimEditClick
        end
        object tbAlignDimText: TTBSubmenuItem
          Caption = #25991#26412#23545#40784
          ImageIndex = 14
          Images = BitmapsModule.imgsDim
          object tbDimTextAlignHome: TTBItem
            Caption = #40664#35748
            OnClick = acDimTextAlignClick
          end
          object tbDimTextAlignAngle: TTBItem
            Tag = 1
            Caption = #35282#24230
            OnClick = acDimTextAlignClick
          end
          object SpTBXSeparatorItem10: TTBSeparatorItem
          end
          object tbDimTextAlignLeft: TTBItem
            Tag = 2
            Caption = #24038
            OnClick = acDimTextAlignClick
          end
          object tbDimTextAlignCenter: TTBItem
            Tag = 3
            Caption = #20013
            OnClick = acDimTextAlignClick
          end
          object tbDimTextAlignRight: TTBItem
            Tag = 4
            Caption = #21491
            OnClick = acDimTextAlignClick
          end
        end
        object TBXSeparatorItem32: TTBSeparatorItem
        end
        object mbDimStyle: TTBItem
          Caption = #26679#24335'...'
          ImageIndex = 17
          Images = BitmapsModule.imgsDim
          OnClick = acDimStyleExecute
        end
        object mbDimOverride: TTBItem
          Caption = #26367#20195
          ImageIndex = 15
          Images = BitmapsModule.imgsDim
          Visible = False
          OnClick = acDimOverrideExecute
        end
        object mbDimUpdate: TTBItem
          Caption = #26356#26032
          ImageIndex = 16
          Images = BitmapsModule.imgsDim
          OnClick = acDimUpdateExecute
        end
      end
      object mnModify: TTBSubmenuItem
        Caption = #20462#25913'(&M)'
        object mbProperties: TTBItem
          Caption = #23545#35937#23646#24615'...'
          ImageIndex = 21
          Images = BitmapsModule.imgsStd
          OnClick = acPropertiesExecute
        end
        object mbMatch: TTBItem
          Caption = #23646#24615#21305#37197
          ImageIndex = 11
          Images = BitmapsModule.imgsStd
          OnClick = acMatchExecute
        end
        object TBXSeparatorItem33: TTBSeparatorItem
        end
        object mbErase: TTBItem
          Caption = #21024#38500
          ImageIndex = 0
          Images = BitmapsModule.imgsModify
          OnClick = acEraseExecute
        end
        object mbCopy: TTBItem
          Caption = #22797#21046
          ImageIndex = 1
          Images = BitmapsModule.imgsModify
          OnClick = acCopyObjExecute
        end
        object mbMirror: TTBItem
          Caption = #38236#20687
          ImageIndex = 2
          Images = BitmapsModule.imgsModify
          OnClick = acMirrorExecute
        end
        object mbOffset: TTBItem
          Caption = #20559#31227
          ImageIndex = 3
          Images = BitmapsModule.imgsModify
          OnClick = acOffsetExecute
        end
        object mbArray: TTBItem
          Caption = #38453#21015
          ImageIndex = 4
          Images = BitmapsModule.imgsModify
          OnClick = acArrayExecute
        end
        object TBXSeparatorItem34: TTBSeparatorItem
        end
        object mbMove: TTBItem
          Caption = #31227#21160
          ImageIndex = 5
          Images = BitmapsModule.imgsModify
          OnClick = acMoveExecute
        end
        object mbRotate: TTBItem
          Caption = #26059#36716
          ImageIndex = 6
          Images = BitmapsModule.imgsModify
          OnClick = acRotateExecute
        end
        object mbScale: TTBItem
          Caption = #32553#25918
          ImageIndex = 7
          Images = BitmapsModule.imgsModify
          OnClick = acScaleExecute
        end
        object mbStretch: TTBItem
          Caption = #25289#20280
          ImageIndex = 8
          Images = BitmapsModule.imgsModify
          OnClick = acStretchExecute
        end
        object mbLengthen: TTBItem
          Caption = #25289#38271
          ImageIndex = 9
          Images = BitmapsModule.imgsModify
          OnClick = acLengthenExecute
        end
        object TBXSeparatorItem35: TTBSeparatorItem
        end
        object mbTrim: TTBItem
          Caption = #20462#21098
          ImageIndex = 10
          Images = BitmapsModule.imgsModify
          OnClick = acTrimExecute
        end
        object mbExtend: TTBItem
          Caption = #24310#20280
          ImageIndex = 11
          Images = BitmapsModule.imgsModify
          OnClick = acExtendExecute
        end
        object mbBreak: TTBItem
          Caption = #25171#26029
          ImageIndex = 12
          Images = BitmapsModule.imgsModify
          OnClick = acBreakExecute
        end
        object mbBreakAtPnt: TTBItem
          Caption = #25171#26029#20110#21333#28857
          ImageIndex = 13
          Images = BitmapsModule.imgsModify
          OnClick = acBreakAtPntExecute
        end
        object mbChamfer: TTBItem
          Caption = #20498#35282
          ImageIndex = 15
          Images = BitmapsModule.imgsModify
          OnClick = acChamferExecute
        end
        object mbFillet: TTBItem
          Caption = #22278#35282
          ImageIndex = 15
          Images = BitmapsModule.imgsModify
          OnClick = acFilletExecute
        end
        object TBXSeparatorItem36: TTBSeparatorItem
        end
        object mbUnion: TTBItem
          Caption = #24182#38598
          ImageIndex = 18
          Images = BitmapsModule.imgsModify
          Visible = False
          OnClick = acUnionExecute
        end
        object mbSubtract: TTBItem
          Caption = #24046#38598
          ImageIndex = 19
          Images = BitmapsModule.imgsModify
          Visible = False
          OnClick = acSubtractExecute
        end
        object mbIntersect: TTBItem
          Caption = #20132#38598
          ImageIndex = 20
          Images = BitmapsModule.imgsModify
          Visible = False
          OnClick = acIntersectExecute
        end
        object TBXSeparatorItem37: TTBSeparatorItem
        end
        object mbEditText: TTBItem
          Caption = #32534#36753#25991#26412
          ImageIndex = 21
          Images = BitmapsModule.imgsModify
          OnClick = acEditTextExecute
        end
        object mbEditHatch: TTBItem
          Caption = #32534#36753#22270#26696#22635#20805
          ImageIndex = 22
          Images = BitmapsModule.imgsModify
          OnClick = acEditHatchExecute
        end
        object mbExplode: TTBItem
          Caption = #28856#24320
          ImageIndex = 17
          Images = BitmapsModule.imgsModify
          OnClick = acExplodeExecute
        end
      end
      object mnWindow: TTBSubmenuItem
        Caption = '&Window'
        Visible = False
        object mbCascade: TTBItem
          Caption = 'Cascade'
        end
        object mbNextWindow: TTBItem
          Caption = 'Next Window'
        end
        object TBXSeparatorItem74: TTBSeparatorItem
        end
      end
      object mnHelp: TTBSubmenuItem
        Caption = #24110#21161'(&H)'
        object mbContents: TTBItem
          Caption = #24110#21161
        end
        object mbAbout: TTBItem
          Caption = #20851#20110
          OnClick = mbAboutClick
        end
      end
      object TBXSubmenuItem2: TTBSubmenuItem
        Caption = '&Test'
        Visible = False
        object btnAddLine: TTBItem
          Caption = 'AddLine'
          OnClick = btnAddLineClick
        end
        object btnAddCircle: TTBItem
          Caption = 'AddCircle'
          OnClick = btnAddCircleClick
        end
        object btnAddArc: TTBItem
          Caption = 'AddArc'
          OnClick = btnAddArcClick
        end
        object btnAddEllipse: TTBItem
          Caption = 'AddEllipse'
          OnClick = btnAddEllipseClick
        end
        object btnAddPoints: TTBItem
          Caption = 'AddPoints'
          OnClick = btnAddPointsClick
        end
        object btnAddSegarc: TTBItem
          Caption = 'AddSegarc'
          OnClick = btnAddSegarcClick
        end
        object btnAddSegarcs: TTBItem
          Caption = 'AddSegarcs'
          OnClick = btnAddSegarcsClick
        end
        object SpTBXSeparatorItem3: TTBSeparatorItem
        end
        object btnArrowBlocks: TTBItem
          Caption = 'ArrowBlocks'
          OnClick = btnArrowBlocksClick
        end
      end
    end
    object StdToolbar: TTBToolbar
      Left = 0
      Top = 23
      Caption = 'Standard'
      DefaultDock = TopDock
      DockableTo = [dpTop, dpBottom]
      DockPos = -6
      DockRow = 1
      Images = BitmapsModule.imgsStd
      TabOrder = 1
      object tbNew: TTBItem
        Caption = 'New...'
        ImageIndex = 0
        ShortCut = 16462
        OnClick = acNewExecute
      end
      object tbOpen: TTBItem
        Caption = 'Open...'
        ImageIndex = 1
        ShortCut = 16463
        OnClick = acOpenExecute
      end
      object tbSave: TTBItem
        Caption = 'Save'
        ImageIndex = 2
        ShortCut = 16467
        OnClick = acSaveExecute
      end
      object SpTBXSeparatorItem6: TTBSeparatorItem
      end
      object tbPrint: TTBItem
        Caption = 'Print'
        ImageIndex = 5
        OnClick = acPrintExecute
      end
      object tbPreview: TTBItem
        Caption = 'Preview'
        ImageIndex = 4
        Visible = False
        OnClick = acPreView2Decute
      end
      object TBXSeparatorItem63: TTBSeparatorItem
      end
      object tbCut: TTBItem
        Caption = 'Cut'
        ImageIndex = 6
        ShortCut = 16472
        OnClick = acCutExecute
      end
      object tbCopy: TTBItem
        Caption = 'Copy'
        ImageIndex = 7
        ShortCut = 16451
        OnClick = acCopyExecute
      end
      object tbPaste: TTBItem
        Caption = 'Paste'
        ImageIndex = 8
        ShortCut = 16470
        OnClick = acPasteExecute
      end
      object TBXSeparatorItem12: TTBSeparatorItem
      end
      object tbMatch: TTBItem
        Caption = 'Match Properties'
        ImageIndex = 11
        OnClick = acMatchExecute
      end
      object tbObjSnap: TTBSubmenuItem
        Caption = 'Object Snap'
        ImageIndex = 20
        Options = [tboDropdownArrow, tboToolbarStyle]
        SubMenuImages = BitmapsModule.imgsSnap
        object tbSnapFrom2: TTBItem
          Caption = 'Snap Form'
          ImageIndex = 1
          OnClick = acSnapFromExecute
        end
        object TBXSeparatorItem72: TTBSeparatorItem
        end
        object tbSnapEndpoint2: TTBItem
          Caption = 'Snap to Endpoint'
          ImageIndex = 2
          OnClick = acSnapEndExecute
        end
        object tbSnapMidpoint2: TTBItem
          Caption = 'Snap to Midpoint'
          ImageIndex = 5
          OnClick = acSnapMidExecute
        end
        object tbSnapIntersection2: TTBItem
          Caption = 'Snap to Intersection'
          ImageIndex = 4
          OnClick = acSnapIntesExecute
        end
        object TBXSeparatorItem68: TTBSeparatorItem
        end
        object tbSnapCenter2: TTBItem
          Caption = 'Snap to Center'
          ImageIndex = 6
          OnClick = acSnapCenterExecute
        end
        object tbSnapQuad2: TTBItem
          Caption = 'Snap to Quadrant'
          ImageIndex = 7
          OnClick = acSnapQuadExecute
        end
        object tbSnapTan2: TTBItem
          Caption = 'Snap to Tangent'
          ImageIndex = 8
          OnClick = acSnapTanExecute
        end
        object TBXSeparatorItem69: TTBSeparatorItem
        end
        object tbSnapPerp2: TTBItem
          Caption = 'Snap to Perpendicular'
          ImageIndex = 9
          OnClick = acSnapPerpExecute
        end
        object tbSnapInsert2: TTBItem
          Caption = 'Snap to Insert'
          ImageIndex = 11
          OnClick = acSnapInsertExecute
        end
        object tbSnapNode2: TTBItem
          Caption = 'Snap to Node'
          ImageIndex = 12
          OnClick = acSnapNodeExecute
        end
        object TBXSeparatorItem71: TTBSeparatorItem
        end
        object tbSnapNearest2: TTBItem
          Caption = 'Snap to Nearest'
          ImageIndex = 13
          Visible = False
          OnClick = acSnapNearestExecute
        end
        object tbSnapNone2: TTBItem
          Caption = 'Snap to None'
          ImageIndex = 15
          OnClick = acSnapNoneExecute
        end
        object tbSnapSetting2: TTBItem
          Caption = 'Snap Setting'
          ImageIndex = 16
          OnClick = acSnapSettingExecute
        end
      end
      object TBXSeparatorItem14: TTBSeparatorItem
      end
      object tbUndo: TTBItem
        Caption = 'Undo'
        Enabled = False
        ImageIndex = 9
        ShortCut = 16474
        OnClick = acUndoExecute
      end
      object tbRedo: TTBItem
        Caption = 'Redo'
        Enabled = False
        ImageIndex = 10
        ShortCut = 16473
        OnClick = acRedoExecute
      end
      object TBXSeparatorItem15: TTBSeparatorItem
      end
      object tbPan: TTBItem
        Caption = 'Pan Realtime'
        ImageIndex = 12
        OnClick = acPanRealExecute
      end
      object tbZoomReal: TTBItem
        Caption = 'Zoom Realtime'
        ImageIndex = 13
        OnClick = acZoomRealExecute
      end
      object tbZoomWin: TTBItem
        Caption = 'Zoom Window'
        ImageIndex = 14
        OnClick = acZoomWinExecute
      end
      object TBXSeparatorItem59: TTBSeparatorItem
      end
      object tbZoomAll: TTBItem
        Caption = 'Zoom All'
        ImageIndex = 15
        OnClick = acZoomAllExecute
      end
      object tbZoomIn: TTBItem
        Caption = 'Zoom In'
        ImageIndex = 17
        OnClick = acZoomInExecute
      end
      object tbZoomOut: TTBItem
        Caption = 'Zoom Out'
        ImageIndex = 18
        OnClick = acZoomOutExecute
      end
      object tbZoomPrev: TTBItem
        Caption = 'Zoom Prevouse'
        ImageIndex = 19
        OnClick = acZoomPrevExecute
      end
      object TBXSeparatorItem23: TTBSeparatorItem
      end
      object tbProperties: TTBItem
        Caption = 'Properties...'
        ImageIndex = 21
        OnClick = acPropertiesExecute
      end
      object tbCalculator: TTBItem
        Caption = 'Calculator'
        ImageIndex = 22
        OnClick = acCalculatorExecute
      end
    end
    object PropToolbar: TTBToolbar
      Left = 0
      Top = 49
      Caption = 'Object Properties'
      DockPos = -6
      DockRow = 2
      Images = BitmapsModule.ImgsLayer
      TabOrder = 2
      object tbSetLayer: TTBItem
        Caption = 'Set Layer'
        ImageIndex = 0
      end
      object tbLayer: TTBItem
        Caption = 'Layers'
        ImageIndex = 1
        OnClick = acLayerExecute
      end
      object SpTBXSeparatorItem5: TTBSeparatorItem
      end
      object tbLinetype: TTBItem
        Caption = '=='
        ImageIndex = 2
        OnClick = acLinetypeExecute
      end
    end
    object InquiryToobar: TTBToolbar
      Left = 523
      Top = 23
      Caption = 'Inquiry'
      DockPos = 523
      DockRow = 1
      Images = BitmapsModule.imgsInquiry
      TabOrder = 3
      object tbDistance: TTBItem
        Caption = 'Distance'
        ImageIndex = 0
        OnClick = acDistanceExecute
      end
      object tbArea: TTBItem
        Caption = 'Area'
        ImageIndex = 1
        OnClick = acAreaExecute
      end
      object TBXSeparatorItem65: TTBSeparatorItem
        Visible = False
      end
      object tbList: TTBItem
        Caption = 'List'
        ImageIndex = 3
        Visible = False
        OnClick = acListExecute
      end
      object tbLocatePoint: TTBItem
        Caption = 'Locate Point'
        ImageIndex = 4
        OnClick = acLocatePointExecute
      end
    end
    object OrderToolbar: TTBToolbar
      Left = 602
      Top = 23
      Caption = 'Order'
      DockPos = 592
      DockRow = 1
      Images = BitmapsModule.imgsDisOrder
      TabOrder = 4
      object tbBringFront: TTBItem
        Caption = 'Bring to Front'
        ImageIndex = 0
        OnClick = acBringFrontExecute
      end
      object tbSendBack: TTBItem
        Caption = 'Send to Back'
        ImageIndex = 1
        OnClick = acSendBackExecute
      end
      object SpTBXSeparatorItem11: TTBSeparatorItem
      end
      object tbBringAbove: TTBItem
        Tag = 1
        Caption = 'Bring Above Objects'
        ImageIndex = 2
        OnClick = acBringFrontExecute
      end
      object tbSendUnder: TTBItem
        Tag = 1
        Caption = 'Send Under Objects'
        ImageIndex = 3
        OnClick = acSendBackExecute
      end
    end
    object TestToolbar: TTBToolbar
      Left = 85
      Top = 49
      Caption = 'Test'
      DockPos = 75
      DockRow = 2
      TabOrder = 5
      object btnLoopSearch: TTBItem
        Caption = 'LoopSearch'
        OnClick = btnLoopSearchClick
      end
    end
  end
  object RightDock: TTBDock
    Left = 1058
    Top = 75
    Width = 54
    Height = 421
    Position = dpRight
    object SnapToolbar: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'Object Snap'
      DefaultDock = RightDock
      DockPos = 0
      Images = BitmapsModule.imgsSnap
      TabOrder = 0
      object tbSnapFrom: TTBItem
        Caption = 'Snap Form'
        ImageIndex = 1
        OnClick = acSnapFromExecute
      end
      object TBXSeparatorItem50: TTBSeparatorItem
      end
      object tbSnapEndpoint: TTBItem
        Caption = 'Snap to Endpoint'
        ImageIndex = 2
        OnClick = acSnapEndExecute
      end
      object tbSnapMidpoint: TTBItem
        Caption = 'Snap to Midpoint'
        ImageIndex = 5
        OnClick = acSnapMidExecute
      end
      object tbSnapIntersection: TTBItem
        Caption = 'Snap to Intersection'
        ImageIndex = 4
        OnClick = acSnapIntesExecute
      end
      object TBXSeparatorItem51: TTBSeparatorItem
      end
      object tbSnapCenter: TTBItem
        Caption = 'Snap to Center'
        ImageIndex = 6
        OnClick = acSnapCenterExecute
      end
      object tbSnapQuad: TTBItem
        Caption = 'Snap to Quadrant'
        ImageIndex = 7
        OnClick = acSnapQuadExecute
      end
      object tbSnapTan: TTBItem
        Caption = 'Snap to Tangent'
        ImageIndex = 8
        OnClick = acSnapTanExecute
      end
      object TBXSeparatorItem52: TTBSeparatorItem
      end
      object tbSnapPerp: TTBItem
        Caption = 'Snap to Perpendicular'
        ImageIndex = 9
        OnClick = acSnapPerpExecute
      end
      object tbSnapInsert: TTBItem
        Caption = 'Snap to Insert'
        ImageIndex = 11
        OnClick = acSnapInsertExecute
      end
      object tbSnapNode: TTBItem
        Caption = 'Snap to Node'
        ImageIndex = 12
        OnClick = acSnapNodeExecute
      end
      object TBXSeparatorItem53: TTBSeparatorItem
      end
      object tbSnapNearest: TTBItem
        Caption = 'Snap to Nearest'
        ImageIndex = 13
        OnClick = acSnapNearestExecute
      end
      object tbSnapNone: TTBItem
        Caption = 'Snap to None'
        ImageIndex = 15
        OnClick = acSnapNoneExecute
      end
      object tbSnapSetting: TTBItem
        Caption = 'Snap Setting'
        ImageIndex = 16
        OnClick = acSnapSettingExecute
      end
    end
    object DimToolbar: TTBToolbar
      Left = 27
      Top = 0
      Caption = 'Dimention'
      DefaultDock = RightDock
      DockPos = 0
      DockRow = 1
      Images = BitmapsModule.imgsDim
      TabOrder = 1
      object tbDimLinear: TTBItem
        Caption = 'Linear'
        ImageIndex = 0
        OnClick = acDimLinearExecute
      end
      object tbDimAligned: TTBItem
        Caption = 'Aligned'
        ImageIndex = 1
        OnClick = acDimAlignedExecute
      end
      object tbDimArcLength: TTBItem
        Caption = 'ArcLength'
        ImageIndex = 2
        OnClick = acDimArcExecute
      end
      object tbDimOrdinate: TTBItem
        Caption = 'Ordinate'
        ImageIndex = 3
        OnClick = acDimOrdinateExecute
      end
      object TBXSeparatorItem54: TTBSeparatorItem
      end
      object tbDimRadius: TTBItem
        Caption = 'Radius'
        ImageIndex = 4
        OnClick = acDimRadiusExecute
      end
      object tbDimJogged: TTBItem
        Caption = 'Jogged'
        ImageIndex = 5
        OnClick = acDimJoggedExecute
      end
      object tbDimDiameter: TTBItem
        Caption = 'Diameter'
        ImageIndex = 6
        OnClick = acDimDiameterExecute
      end
      object tbDimAngular: TTBItem
        Caption = 'Angular'
        ImageIndex = 7
        OnClick = acDimAngularExecute
      end
      object TBXSeparatorItem55: TTBSeparatorItem
      end
      object tbDimBaseline: TTBItem
        Caption = 'Baseline'
        ImageIndex = 9
        OnClick = acDimBaselineExecute
      end
      object tbDimContinue: TTBItem
        Caption = 'Continue'
        ImageIndex = 10
        OnClick = acDimContinueExecute
      end
      object TBXSeparatorItem56: TTBSeparatorItem
      end
      object tbDimLeader: TTBItem
        Caption = 'Leader'
        ImageIndex = 11
        OnClick = acDimLeaderExecute
      end
      object tbDimTolerance: TTBItem
        Caption = 'Tolerance'
        ImageIndex = 12
        OnClick = acDimToleranceExecute
      end
      object tbCenterMark: TTBItem
        Caption = 'Center Mark'
        ImageIndex = 13
        OnClick = acDimCenterExecute
      end
      object TBXSeparatorItem57: TTBSeparatorItem
      end
      object tbDimTextAlign: TTBItem
        Caption = 'Dimention TextAlign'
        ImageIndex = 14
        OnClick = acDimTextAlignClick
      end
      object tbDimTextEdit: TTBItem
        Caption = 'Dimention Text Edit'
        ImageIndex = 15
        OnClick = acDimTextEditClick
      end
      object TBXSeparatorItem58: TTBSeparatorItem
      end
      object tbDimUpdate: TTBItem
        Caption = 'Update'
        ImageIndex = 16
        OnClick = acDimUpdateExecute
      end
      object tbDimStyle: TTBItem
        Caption = 'Dimention Style...'
        ImageIndex = 17
        OnClick = acDimStyleExecute
      end
    end
  end
  object LeftDock: TTBDock
    Left = 214
    Top = 75
    Width = 54
    Height = 421
    Position = dpLeft
    object DrawToolbar: TTBToolbar
      Left = 27
      Top = 0
      Caption = 'Draw'
      DefaultDock = LeftDock
      DockPos = 0
      DockRow = 1
      Images = BitmapsModule.imgsDraw
      TabOrder = 0
      object tbLine: TTBItem
        Caption = 'Line'
        ImageIndex = 0
        OnClick = acLineExecute
      end
      object tbRay: TTBItem
        Caption = 'Ray'
        ImageIndex = 1
        Visible = False
        OnClick = acRayExecute
      end
      object tbXLine: TTBItem
        Caption = 'XLine'
        ImageIndex = 2
        OnClick = acXLineExecute
      end
      object tbPolyline: TTBItem
        Caption = 'Polyline'
        ImageIndex = 3
        OnClick = acPolylineExecute
      end
      object tbPolygon: TTBItem
        Caption = 'Polygon'
        ImageIndex = 4
        OnClick = acPolygonExecute
      end
      object tbRectangle: TTBItem
        Caption = 'Rectangle'
        ImageIndex = 5
        OnClick = acRectExecute
      end
      object TBXSeparatorItem42: TTBSeparatorItem
      end
      object tbArc: TTBItem
        Caption = 'Arc 3 Point'
        ImageIndex = 6
        OnClick = acArc3PExecute
      end
      object tbArcs: TTBSubmenuItem
        Caption = 'Arc'
        ImageIndex = 7
        object tbArcSCE: TTBItem
          Caption = 'Start, Center, End'
          ImageIndex = 7
          Visible = False
          OnClick = acArcSCEClick
        end
        object tbArcSCA: TTBItem
          Caption = 'Start, Center, Angle'
          ImageIndex = 8
          Visible = False
          OnClick = acArcSCAClick
        end
        object tbArcSCL: TTBItem
          Caption = 'Start, Center, Length'
          ImageIndex = 9
          Visible = False
          OnClick = acArcSCLClick
        end
        object SpTBXSeparatorItem8: TTBSeparatorItem
          Visible = False
        end
        object tbArcSEA: TTBItem
          Caption = 'Start,  End,  Angle'
          Visible = False
          OnClick = acArcSEAClick
        end
        object tbArcSED: TTBItem
          Caption = 'Start,  End,  Direction'
          Visible = False
          OnClick = acArcSEDClick
        end
        object tbArcSER: TTBItem
          Caption = 'Start,  End,  Radius'
          Visible = False
          OnClick = acArcSERClick
        end
        object SpTBXSeparatorItem9: TTBSeparatorItem
          Visible = False
        end
        object tbArcCSE: TTBItem
          Caption = 'Center, Start, End'
          ImageIndex = 7
          OnClick = acArcCSEClick
        end
        object tbArcCSA: TTBItem
          Caption = 'Center, Start, Angle'
          ImageIndex = 8
          OnClick = acArcCSAClick
        end
        object tbArcCSL: TTBItem
          Caption = 'Center, Start, Length'
          ImageIndex = 9
          OnClick = acArcCSLClick
        end
      end
      object TBXSeparatorItem78: TTBSeparatorItem
      end
      object tbCircleCR: TTBItem
        Caption = 'Circle Center Radius'
        ImageIndex = 10
        OnClick = acCircleCRExecute
      end
      object tbCircle2P: TTBItem
        Caption = 'Circle 2 Points'
        ImageIndex = 12
        OnClick = acCircle2PExecute
      end
      object tbCircle3P: TTBItem
        Caption = 'Circle 3 Points'
        ImageIndex = 13
        OnClick = acCircle3PExecute
      end
      object TBXSeparatorItem79: TTBSeparatorItem
      end
      object tbEllipse: TTBItem
        Caption = 'Ellipse Axis, End'
        ImageIndex = 14
        OnClick = acEllipseAEExecute
      end
      object tbEllipseArc: TTBItem
        Caption = 'Ellipse Arc'
        ImageIndex = 15
        OnClick = acEllipseArcExecute
      end
      object SpTBXSeparatorItem4: TTBSeparatorItem
      end
      object tbSpline: TTBItem
        Caption = 'Spline'
        ImageIndex = 18
        OnClick = acSplineExecute
      end
      object TBXSeparatorItem43: TTBSeparatorItem
      end
      object tbInsBlock: TTBItem
        Caption = 'Insert Block'
        ImageIndex = 16
        OnClick = acInsBlockExecute
      end
      object tbMakeBlock: TTBItem
        Caption = 'Make Block'
        ImageIndex = 17
        OnClick = acMakeBlockExecute
      end
      object TBXSeparatorItem44: TTBSeparatorItem
      end
      object tbPoint: TTBItem
        Caption = 'Point'
        ImageIndex = 21
        OnClick = acPointExecute
      end
      object TBXSeparatorItem45: TTBSeparatorItem
      end
      object tbHatch: TTBItem
        Caption = 'Hatch...'
        ImageIndex = 26
        OnClick = acHatchExecute
      end
      object tbRegion: TTBItem
        Caption = 'Region'
        ImageIndex = 27
        Visible = False
        OnClick = acRegionExecute
      end
      object TBXSeparatorItem46: TTBSeparatorItem
      end
      object tbText: TTBItem
        Caption = 'Muliiline Text'
        ImageIndex = 24
        OnClick = acMTextExecute
      end
    end
    object ModifyToolbar: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'Modify'
      DefaultDock = LeftDock
      DockPos = -20
      Images = BitmapsModule.imgsModify
      TabOrder = 1
      object tbErase: TTBItem
        Caption = 'Erase'
        ImageIndex = 0
        OnClick = acEraseExecute
      end
      object tbCopyObj: TTBItem
        Caption = 'Copy Object'
        ImageIndex = 1
        OnClick = acCopyObjExecute
      end
      object TBXSeparatorItem41: TTBSeparatorItem
      end
      object tbMirror: TTBItem
        Caption = 'Mirror'
        ImageIndex = 2
        OnClick = acMirrorExecute
      end
      object tbOffset: TTBItem
        Caption = 'Offset'
        ImageIndex = 3
        OnClick = acOffsetExecute
      end
      object tbArray: TTBItem
        Caption = 'Array'
        ImageIndex = 4
        OnClick = acArrayExecute
      end
      object tbMove: TTBItem
        Caption = 'Move'
        ImageIndex = 5
        OnClick = acMoveExecute
      end
      object tbRotate: TTBItem
        Caption = 'Rotate'
        ImageIndex = 6
        OnClick = acRotateExecute
      end
      object tbScale: TTBItem
        Caption = 'Scale'
        ImageIndex = 7
        OnClick = acScaleExecute
      end
      object TBXSeparatorItem47: TTBSeparatorItem
      end
      object tbLengthen: TTBItem
        Caption = 'Lengthen'
        ImageIndex = 9
        Visible = False
        OnClick = acLengthenExecute
      end
      object tbTrim: TTBItem
        Caption = 'Trim'
        ImageIndex = 10
        OnClick = acTrimExecute
      end
      object tbExtend: TTBItem
        Caption = 'Extend'
        ImageIndex = 11
        OnClick = acExtendExecute
      end
      object tbBreak: TTBItem
        Caption = 'Break'
        ImageIndex = 12
        OnClick = acBreakExecute
      end
      object tbBreakAtPnt: TTBItem
        Caption = 'Break At Point'
        ImageIndex = 13
        OnClick = acBreakAtPntExecute
      end
      object tbChamfer: TTBItem
        Caption = 'Chamfer'
        ImageIndex = 16
        OnClick = acChamferExecute
      end
      object tbFillet: TTBItem
        Caption = 'Fillet'
        ImageIndex = 15
        OnClick = acFilletExecute
      end
      object tbExplode: TTBItem
        Caption = 'Explode'
        ImageIndex = 17
        OnClick = acExplodeExecute
      end
      object TBXSeparatorItem48: TTBSeparatorItem
      end
      object tbUnion: TTBItem
        Caption = 'Union'
        ImageIndex = 18
        Visible = False
        OnClick = acUnionExecute
      end
      object tbSubtract: TTBItem
        Caption = 'Subtract'
        ImageIndex = 19
        Visible = False
        OnClick = acSubtractExecute
      end
      object tbIntersect: TTBItem
        Caption = 'Intersect'
        ImageIndex = 20
        Visible = False
        OnClick = acIntersectExecute
      end
      object TBXSeparatorItem49: TTBSeparatorItem
      end
      object tbEditHatch: TTBItem
        Caption = 'Edit Hatch'
        ImageIndex = 22
        OnClick = acEditHatchExecute
      end
      object tbTextEdit: TTBItem
        Caption = 'Edit Text'
        ImageIndex = 21
        OnClick = acEditTextExecute
      end
    end
  end
  object pnlClient: TPanel
    Left = 268
    Top = 75
    Width = 790
    Height = 421
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
  end
  object pnlProperties: TPanel
    Left = 0
    Top = 75
    Width = 214
    Height = 421
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 4
  end
  object pnlRight: TPanel
    Tag = 1
    Left = 1112
    Top = 75
    Width = 2
    Height = 421
    Align = alRight
    TabOrder = 5
  end
  object pnlStatusBar: TPanel
    Left = 0
    Top = 636
    Width = 1114
    Height = 20
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 6
    OnResize = StatusBarResize
    object lblPos: TLabel
      Left = 15
      Top = 4
      Width = 6
      Height = 12
      Caption = '.'
    end
    object btnUseSnap: TSpeedButton
      Tag = 1
      Left = 262
      Top = 0
      Width = 47
      Height = 21
      AllowAllUp = True
      GroupIndex = 1
      Caption = #25429#25417
      Font.Charset = GB2312_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      OnClick = DraftingModeChanged
    end
    object btnUseGrid: TSpeedButton
      Left = 307
      Top = 0
      Width = 47
      Height = 21
      AllowAllUp = True
      GroupIndex = 2
      Caption = #26629#26684
      Font.Charset = GB2312_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      OnClick = DraftingModeChanged
    end
    object btnUseOrtho: TSpeedButton
      Tag = 2
      Left = 352
      Top = 0
      Width = 47
      Height = 21
      AllowAllUp = True
      GroupIndex = 3
      Caption = #27491#20132
      Font.Charset = GB2312_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      OnClick = DraftingModeChanged
    end
    object btnUsePolar: TSpeedButton
      Tag = 3
      Left = 397
      Top = 0
      Width = 47
      Height = 21
      AllowAllUp = True
      GroupIndex = 4
      Caption = #26497#36724
      Font.Charset = GB2312_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      OnClick = DraftingModeChanged
    end
    object btnUseOSnap: TSpeedButton
      Tag = 4
      Left = 442
      Top = 0
      Width = 61
      Height = 21
      AllowAllUp = True
      GroupIndex = 5
      Down = True
      Caption = #23545#35937#25429#25417
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      OnClick = DraftingModeChanged
    end
    object btnUseLWT: TSpeedButton
      Tag = 5
      Left = 501
      Top = 1
      Width = 47
      Height = 21
      AllowAllUp = True
      GroupIndex = 6
      Caption = #32447#23485
      Font.Charset = GB2312_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      OnClick = DraftingModeChanged
    end
    object ProgressBar1: TProgressBar
      Left = 581
      Top = 3
      Width = 473
      Height = 15
      TabOrder = 0
      Visible = False
    end
  end
  object pnlCmdLine: TPanel
    Left = 0
    Top = 500
    Width = 1114
    Height = 136
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 7
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 21
      Height = 136
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 2
        Top = 20
        Width = 12
        Height = 60
        Caption = #21629#13#10#13#10#20196#13#10#13#10#34892
        Font.Charset = GB2312_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'All (*.XCAD; *.XML; *.DXF; *.DWG)|*.XCAD; *.XML; *.DXF; *.DWG|De' +
      'lphiCAD (*.XCAD)|*.XCAD|DelphiCAD XML (*.XML)|*.XML|AutoCAD DXF ' +
      '(*.DXF)|*.DXF|AutoCAD DWG (*.DWG)|*.DWG'
    Left = 314
    Top = 90
  end
  object SaveDialog1: TSaveDialog
    Filter = 
      'DelphiCAD (*.XCAD)|*.XCAD|DelphiCAD XML (*.XML)|*.XML|AutoCAD DX' +
      'F (*.DXF)|*.DXF|AutoCAD DWG (*.DWG)|*.DWG'
    FilterIndex = 0
    Left = 379
    Top = 90
  end
  object ImageList1: TImageList
    Left = 33
    Top = 124
  end
  object PopupMenu: TTBPopupMenu
    OnPopup = PopupMenuPopup
    Options = [tboSameWidth]
    Left = 338
    Top = 149
    object nRepeat: TTBItem
      Tag = 3
      Caption = 'Repeat'
      OnClick = nPopupRepeatClick
    end
    object nUnselectAll: TTBItem
      Tag = 2
      Caption = 'Unselect all'
      OnClick = nPopupUnselectAllClick
    end
    object nExit: TTBItem
      Tag = 4
      Caption = 'Exit'
      OnClick = nPopupExitClick
    end
    object nInputCoordinate: TTBItem
      Tag = -1
      Caption = 'Input Coordinate...'
      OnClick = nPopupInputCoordinateClick
    end
    object nSnapoverrides: TTBSubmenuItem
      Tag = 4
      Caption = 'Snap Overrides'
      LinkSubitems = tbObjSnap
    end
    object N1: TTBSeparatorItem
    end
    object nZoomExtends: TTBItem
      Tag = 1
      Caption = 'Zoom Extends'
      OnClick = acZoomExtendsExecute
    end
    object nZoomWindows: TTBItem
      Tag = 1
      Caption = 'Zoom Windows'
      OnClick = acZoomWinExecute
    end
    object nZoomReal: TTBItem
      Tag = 5
      Caption = 'Zoom Real'
      OnClick = acZoomRealExecute
    end
    object nZoomPan: TTBItem
      Tag = 5
      Caption = 'Pan'
      OnClick = acPanRealExecute
    end
    object N2: TTBSeparatorItem
    end
    object nErase: TTBItem
      Tag = 2
      Caption = 'Erase'
      OnClick = acEraseExecute
    end
    object nMove: TTBItem
      Tag = 2
      Caption = 'Move'
      OnClick = acMoveExecute
    end
    object nCopy: TTBItem
      Tag = 2
      Caption = 'Copy'
      OnClick = acCopyExecute
    end
    object nRotate: TTBItem
      Tag = 2
      Caption = 'Rotate'
      OnClick = acRotateExecute
    end
    object nScale: TTBItem
      Tag = 2
      Caption = 'Scale'
      OnClick = acScaleExecute
    end
    object nMirror: TTBItem
      Tag = 2
      Caption = 'Mirror'
      OnClick = acMirrorExecute
    end
    object nOffset: TTBItem
      Tag = 2
      Caption = 'Offset'
      OnClick = acOffsetExecute
    end
  end
end
