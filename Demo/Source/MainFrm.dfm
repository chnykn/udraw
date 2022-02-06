object MainForm: TMainForm
  Left = 387
  Top = 108
  Caption = 'Delphi CAD'
  ClientHeight = 656
  ClientWidth = 1097
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
  object TopDock: TSpTBXDock
    Left = 0
    Top = 0
    Width = 1097
    Height = 81
    OnCanResize = TopDockCanResize
    object MenuToolbar: TSpTBXToolbar
      Left = 0
      Top = 0
      CloseButton = False
      DefaultDock = TopDock
      DockPos = 0
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      FullSize = True
      ParentFont = False
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      Caption = 'Menu'
      Customizable = False
      MenuBar = True
      object mnFile: TSpTBXSubmenuItem
        Caption = #25991#20214'(&F)'
        object mbNew: TSpTBXItem
          Caption = #26032#24314'...'
          ImageIndex = 0
          Images = BitmapsModule.imgsStd
          ShortCut = 16462
          OnClick = acNewExecute
        end
        object mbOpen: TSpTBXItem
          Caption = #25171#24320'...'
          ImageIndex = 1
          Images = BitmapsModule.imgsStd
          ShortCut = 16463
          OnClick = acOpenExecute
        end
        object TBXSeparatorItem1: TSpTBXSeparatorItem
        end
        object mbSave: TSpTBXItem
          Caption = #20445#23384
          ImageIndex = 2
          Images = BitmapsModule.imgsStd
          ShortCut = 16467
          OnClick = acSaveExecute
        end
        object mbSaveAs: TSpTBXItem
          Caption = #21478#23384#20026'(&A)...'
          ImageIndex = 3
          Images = BitmapsModule.imgsStd
          OnClick = acSaveAsExecute
        end
        object TBXSeparatorItem2: TSpTBXSeparatorItem
        end
        object mbPreview: TSpTBXItem
          Caption = #25171#21360#39044#35272
          ImageIndex = 4
          Images = BitmapsModule.imgsStd
          Visible = False
          OnClick = acPreView2Decute
        end
        object mbPrint: TSpTBXItem
          Caption = #25171#21360
          ImageIndex = 5
          Images = BitmapsModule.imgsStd
          OnClick = acPrintExecute
        end
        object TBXSeparatorItem3: TSpTBXSeparatorItem
        end
        object mbHistory: TSpTBXSubmenuItem
          Caption = #21382#21490#25991#20214
        end
        object TBXSeparatorItem40: TSpTBXSeparatorItem
        end
        object mbExit: TSpTBXItem
          Caption = #36864#20986
          Images = BitmapsModule.imgsStd
          OnClick = acExitExecute
        end
      end
      object mnEdit: TSpTBXSubmenuItem
        Caption = #32534#36753'(&E)'
        object mbUndo: TSpTBXItem
          Caption = #25764#38144
          ImageIndex = 9
          Images = BitmapsModule.imgsStd
          ShortCut = 16474
          OnClick = acUndoExecute
        end
        object mbRedo: TSpTBXItem
          Caption = #37325#20570
          ImageIndex = 10
          Images = BitmapsModule.imgsStd
          ShortCut = 16473
          OnClick = acRedoExecute
        end
        object TBXSeparatorItem4: TSpTBXSeparatorItem
        end
        object mbCut: TSpTBXItem
          Caption = #21098#20999
          ImageIndex = 6
          Images = BitmapsModule.imgsStd
          ShortCut = 16472
          OnClick = acCutExecute
        end
        object mbCopyClip: TSpTBXItem
          Caption = #22797#21046
          ImageIndex = 7
          Images = BitmapsModule.imgsStd
          ShortCut = 16451
          OnClick = acCopyExecute
        end
        object mbPaste: TSpTBXItem
          Caption = #31896#36148
          ImageIndex = 8
          Images = BitmapsModule.imgsStd
          ShortCut = 16470
          OnClick = acPasteExecute
        end
        object TBXSeparatorItem11: TSpTBXSeparatorItem
        end
        object mbClear: TSpTBXItem
          Caption = #28165#38500
          Images = BitmapsModule.imgsStd
          OnClick = acClearExecute
        end
        object mbSelectAll: TSpTBXItem
          Caption = #36873#25321#20840#37096
          Images = BitmapsModule.imgsStd
          OnClick = acSelectAllExecute
        end
      end
      object mnView: TSpTBXSubmenuItem
        Caption = #35270#22270'(&V)'
        object mbPan: TSpTBXItem
          Caption = #23454#26102#24179#31227
          ImageIndex = 12
          Images = BitmapsModule.imgsStd
          OnClick = acPanRealExecute
        end
        object mbPan2P: TSpTBXItem
          Caption = #20004#28857#24179#31227
          Images = BitmapsModule.imgsStd
          OnClick = acPan2PExecute
        end
        object TBXSeparatorItem5: TSpTBXSeparatorItem
        end
        object mbZoomReal: TSpTBXItem
          Caption = #23454#26102#32553#25918
          ImageIndex = 13
          Images = BitmapsModule.imgsStd
          OnClick = acZoomRealExecute
        end
        object mbZoomWindow: TSpTBXItem
          Caption = #31383#21475#32553#25918
          ImageIndex = 14
          Images = BitmapsModule.imgsStd
          OnClick = acZoomWinExecute
        end
        object TBXSeparatorItem39: TSpTBXSeparatorItem
        end
        object mbZoomIn: TSpTBXItem
          Caption = #25918#22823
          ImageIndex = 17
          Images = BitmapsModule.imgsStd
          OnClick = acZoomInExecute
        end
        object mbZoomOut: TSpTBXItem
          Caption = #32553#23567
          ImageIndex = 18
          Images = BitmapsModule.imgsStd
          OnClick = acZoomOutExecute
        end
        object mbZoomAll: TSpTBXItem
          Caption = #26174#31034#20840#37096
          ImageIndex = 15
          Images = BitmapsModule.imgsStd
          OnClick = acZoomAllExecute
        end
        object mbZoomExtends: TSpTBXItem
          Caption = #26174#31034#33539#22260
          ImageIndex = 16
          Images = BitmapsModule.imgsStd
          OnClick = acZoomExtendsExecute
        end
        object mbZoomPrev: TSpTBXItem
          Caption = #19978#19968#35270#22270
          ImageIndex = 19
          Images = BitmapsModule.imgsStd
          OnClick = acZoomPrevExecute
        end
        object TBXSeparatorItem62: TSpTBXSeparatorItem
        end
        object mbDispaly: TSpTBXItem
          Caption = 'Dispaly'
          Visible = False
        end
        object mbToolbar: TSpTBXItem
          Caption = 'Toolbar...'
          Visible = False
        end
      end
      object mnFormat: TSpTBXSubmenuItem
        Caption = #26684#24335'(&F)'
        object mbLayer: TSpTBXItem
          Caption = #22270#23618'...'
          ImageIndex = 1
          Images = BitmapsModule.ImgsLayer
          OnClick = acLayerExecute
        end
        object mbColor: TSpTBXItem
          Caption = #39068#33394'...'
          OnClick = acColorExecute
        end
        object mbLinetype: TSpTBXItem
          Caption = #32447#24418'...'
          ImageIndex = 2
          Images = BitmapsModule.ImgsLayer
          OnClick = acLinetypeExecute
        end
        object mbLineWeight: TSpTBXItem
          Caption = #32447#23485'...'
          OnClick = acLineWeightExecute
        end
        object TBXSeparatorItem9: TSpTBXSeparatorItem
        end
        object mbTextStyle: TSpTBXItem
          Caption = #25991#23383#26679#24335'...'
          OnClick = acTextStyleExecute
        end
        object mbDimentionStyle: TSpTBXItem
          Caption = #26631#27880#26679#24335'...'
          ImageIndex = 17
          Images = BitmapsModule.imgsDim
          OnClick = acDimStyleExecute
        end
        object mbPointStyle: TSpTBXItem
          Caption = #28857#26679#24335'...'
          OnClick = acPointStyleExecute
        end
        object TBXSeparatorItem10: TSpTBXSeparatorItem
        end
        object mbUnits: TSpTBXItem
          Caption = #21333#20301'...'
          OnClick = acUnitsClick
        end
      end
      object mnTools: TSpTBXSubmenuItem
        Caption = #24037#20855'(&T)'
        object mbDisOrder: TSpTBXSubmenuItem
          Caption = #26174#31034#39034#24207
          object mbBringFront: TSpTBXItem
            Caption = #21069#32622
            ImageIndex = 0
            Images = BitmapsModule.imgsDisOrder
            OnClick = acBringFrontExecute
          end
          object mbSendBack: TSpTBXItem
            Caption = #21518#32622
            ImageIndex = 1
            Images = BitmapsModule.imgsDisOrder
            OnClick = acSendBackExecute
          end
          object SpTBXSeparatorItem12: TSpTBXSeparatorItem
          end
          object mbBringAbove: TSpTBXItem
            Tag = 1
            Caption = #32622#20110#23545#35937#20043#19978
            ImageIndex = 2
            Images = BitmapsModule.imgsDisOrder
            OnClick = acBringFrontExecute
          end
          object mbSendUnder: TSpTBXItem
            Tag = 1
            Caption = #32622#20110#23545#35937#20043#19979
            ImageIndex = 3
            Images = BitmapsModule.imgsDisOrder
            OnClick = acSendBackExecute
          end
        end
        object mbInquiry: TSpTBXSubmenuItem
          Caption = #26597#35810
          object mbDistance: TSpTBXItem
            Caption = #36317#31163
            ImageIndex = 0
            Images = BitmapsModule.imgsInquiry
            OnClick = acDistanceExecute
          end
          object mbArea: TSpTBXItem
            Caption = #38754#31215
            ImageIndex = 1
            Images = BitmapsModule.imgsInquiry
            OnClick = acAreaExecute
          end
          object TBXSeparatorItem66: TSpTBXSeparatorItem
            Visible = False
          end
          object mbList: TSpTBXItem
            Caption = 'List'
            ImageIndex = 3
            Images = BitmapsModule.imgsInquiry
            Visible = False
            OnClick = acListExecute
          end
          object mbLocatePoint: TSpTBXItem
            Caption = #20301#32622
            ImageIndex = 4
            Images = BitmapsModule.imgsInquiry
            OnClick = acLocatePointExecute
          end
        end
        object mbCalculator: TSpTBXItem
          Caption = #35745#31639#22120'...'
          ImageIndex = 22
          Images = BitmapsModule.imgsStd
          Visible = False
          OnClick = acCalculatorExecute
        end
        object TBXSeparatorItem8: TSpTBXSeparatorItem
        end
        object mbLoadApp: TSpTBXItem
          Caption = 'Load Application'
          Visible = False
          OnClick = acLoadAppExecute
        end
        object mbRunScript: TSpTBXItem
          Caption = 'Run Script'
          Visible = False
          OnClick = acRunScriptExecute
        end
        object TBXSeparatorItem16: TSpTBXSeparatorItem
        end
        object mbSelection: TSpTBXItem
          Caption = 'Selection...'
          Visible = False
          OnClick = acSelectionExecute
        end
        object mbDraftingSettinh: TSpTBXItem
          Caption = #33609#22270#35774#32622'...'
          Images = BitmapsModule.imgsStd
          OnClick = acDraftingSetting
        end
        object mbOptions: TSpTBXItem
          Caption = #36873#39033'...'
          OnClick = acPerferenceExecute
        end
        object TBXSeparatorItem17: TSpTBXSeparatorItem
        end
        object mbSkins: TSpTBXSubmenuItem
          Caption = #30382#32932
          object SpTBXSkinGroupItem1: TSpTBXSkinGroupItem
          end
        end
      end
      object mnDraw: TSpTBXSubmenuItem
        Caption = #32472#22270'(&D)'
        object mbLine: TSpTBXItem
          Caption = #30452#32447
          ImageIndex = 0
          Images = BitmapsModule.imgsDraw
          OnClick = acLineExecute
        end
        object mbRay: TSpTBXItem
          Caption = #23556#32447
          ImageIndex = 1
          Images = BitmapsModule.imgsDraw
          OnClick = acRayExecute
        end
        object mbXLine: TSpTBXItem
          Caption = #26500#36896#32447
          ImageIndex = 2
          Images = BitmapsModule.imgsDraw
          OnClick = acXLineExecute
        end
        object TBXSeparatorItem18: TSpTBXSeparatorItem
        end
        object mbPolyline: TSpTBXItem
          Caption = #22810#27573#32447
          ImageIndex = 3
          Images = BitmapsModule.imgsDraw
          OnClick = acPolylineExecute
        end
        object mbPolygon: TSpTBXItem
          Caption = #22810#36793#24418
          ImageIndex = 4
          Images = BitmapsModule.imgsDraw
          OnClick = acPolygonExecute
        end
        object mbRectangle: TSpTBXSubmenuItem
          Caption = #30697#24418
          ImageIndex = 5
          Images = BitmapsModule.imgsDraw
          object mbRect2P: TSpTBXItem
            Caption = #20004#28857
            OnClick = acRectExecute
          end
          object mbRect3P: TSpTBXItem
            Caption = #19977#28857
            OnClick = acRect3PExecute
          end
          object mbRectCSA: TSpTBXItem
            Caption = #20013#24515','#22823#23567','#35282#24230
            OnClick = acRectCSAExecute
          end
        end
        object TBXSeparatorItem19: TSpTBXSeparatorItem
        end
        object mbArc: TSpTBXSubmenuItem
          Caption = #22278#24359
          ImageIndex = 6
          Images = BitmapsModule.imgsDraw
          object mbArc3P: TSpTBXItem
            Caption = #19977#28857
            OnClick = acArc3PExecute
          end
          object TBXSeparatorItem20: TSpTBXSeparatorItem
          end
          object mbArcSCE: TSpTBXItem
            Caption = #36215#28857', '#22278#24515', '#31471#28857
            Visible = False
            OnClick = acArcSCEClick
          end
          object mbArcSCA: TSpTBXItem
            Caption = #36215#28857', '#22278#24515', '#35282#24230
            Visible = False
            OnClick = acArcSCAClick
          end
          object mbArcSCL: TSpTBXItem
            Caption = #36215#28857', '#22278#24515', '#38271#24230
            Visible = False
            OnClick = acArcSCLClick
          end
          object TBXSeparatorItem76: TSpTBXSeparatorItem
            Visible = False
          end
          object mbArcSEA: TSpTBXItem
            Caption = #36215#28857',  '#31471#28857', '#35282#24230
            Visible = False
            OnClick = acArcSEAClick
          end
          object mbArcSED: TSpTBXItem
            Caption = #36215#28857',  '#31471#28857',  '#26041#21521
            Visible = False
            OnClick = acArcSEDClick
          end
          object mbArcSER: TSpTBXItem
            Caption = #36215#28857',  '#31471#28857',  '#21322#24452
            Visible = False
            OnClick = acArcSERClick
          end
          object TBXSeparatorItem75: TSpTBXSeparatorItem
            Visible = False
          end
          object mbArcCSE: TSpTBXItem
            Caption = #22278#24515', '#36215#28857', '#31471#28857
            OnClick = acArcCSEClick
          end
          object mbArcCSA: TSpTBXItem
            Caption = #22278#24515', '#36215#28857', '#35282#24230
            OnClick = acArcCSAClick
          end
          object mbArcCSL: TSpTBXItem
            Caption = #22278#24515', '#36215#28857', '#38271#24230
            OnClick = acArcCSLClick
          end
        end
        object mbCircle: TSpTBXSubmenuItem
          Caption = #22278
          ImageIndex = 10
          Images = BitmapsModule.imgsDraw
          object mbCirCR: TSpTBXItem
            Caption = #22278#24515', '#21322#24452
            OnClick = acCircleCRExecute
          end
          object mbCirCD: TSpTBXItem
            Caption = #22278#24515', '#30452#24452
            Visible = False
            OnClick = acCircleCDExecute
          end
          object TBXSeparatorItem21: TSpTBXSeparatorItem
          end
          object mbCir2P: TSpTBXItem
            Caption = #20004#28857
            OnClick = acCircle2PExecute
          end
          object mbCir3P: TSpTBXItem
            Caption = #19977#28857
            OnClick = acCircle3PExecute
          end
          object TBXSeparatorItem22: TSpTBXSeparatorItem
            Visible = False
          end
          object mbCirTTT: TSpTBXItem
            Caption = 'Tan, Tan, Tan'
            Visible = False
            OnClick = acCircleTTTExecute
          end
          object mbCirTTR: TSpTBXItem
            Caption = 'Tan, Tan, Radius'
            Visible = False
            OnClick = acCircleTTRExecute
          end
        end
        object mbDount: TSpTBXItem
          Caption = #22278#29615
          ImageIndex = 20
          Images = BitmapsModule.imgsDraw
          OnClick = acDonutExecute
        end
        object mbSpline: TSpTBXItem
          Caption = #26679#26465#26354#32447
          ImageIndex = 18
          Images = BitmapsModule.imgsDraw
          OnClick = acSplineExecute
        end
        object mbEllipse: TSpTBXSubmenuItem
          Caption = #26925#22278
          ImageIndex = 14
          Images = BitmapsModule.imgsDraw
          object mbEllipseAE: TSpTBXItem
            Caption = #36724', '#31471#28857
            OnClick = acEllipseAEExecute
          end
          object mbEllipseC: TSpTBXItem
            Caption = #20013#24515#28857
            OnClick = acEllipseCExecute
          end
          object SpTBXSeparatorItem7: TSpTBXSeparatorItem
          end
          object mbEllipseArc: TSpTBXItem
            Caption = #26925#22278#24359
          end
        end
        object TBXSeparatorItem24: TSpTBXSeparatorItem
        end
        object TBXSubmenuItem1: TSpTBXSubmenuItem
          Caption = #22359
          ImageIndex = 17
          Images = BitmapsModule.imgsDraw
          object mbInsBlock: TSpTBXItem
            Caption = #25554#20837#22359
            ImageIndex = 16
            Images = BitmapsModule.imgsDraw
            OnClick = acInsBlockExecute
          end
          object mbMakeBlock: TSpTBXItem
            Caption = #21019#24314#22359
            ImageIndex = 17
            Images = BitmapsModule.imgsDraw
            OnClick = acMakeBlockExecute
          end
        end
        object mbPoint: TSpTBXSubmenuItem
          Caption = #28857
          ImageIndex = 21
          Images = BitmapsModule.imgsDraw
          object mbMPoint: TSpTBXItem
            Caption = #21333#28857
            ImageIndex = 21
            Images = BitmapsModule.imgsDraw
            OnClick = acPointExecute
          end
          object TBXSeparatorItem25: TSpTBXSeparatorItem
          end
          object mbDivide: TSpTBXItem
            Caption = #23450#25968#31561#20998
            ImageIndex = 22
            Images = BitmapsModule.imgsDraw
            OnClick = acDivideExecute
          end
          object mbMeasure: TSpTBXItem
            Caption = #23450#36317#31561#20998
            ImageIndex = 23
            Images = BitmapsModule.imgsDraw
          end
        end
        object TBXSeparatorItem26: TSpTBXSeparatorItem
        end
        object mbHatch: TSpTBXItem
          Caption = #22270#26696#22635#20805'...'
          ImageIndex = 26
          Images = BitmapsModule.imgsDraw
          OnClick = acHatchExecute
        end
        object mbRegion: TSpTBXItem
          Caption = 'Region'
          ImageIndex = 27
          Images = BitmapsModule.imgsDraw
          Visible = False
          OnClick = acRegionExecute
        end
        object TBXSeparatorItem27: TSpTBXSeparatorItem
        end
        object mbText: TSpTBXSubmenuItem
          Caption = #25991#23383
          ImageIndex = 24
          Images = BitmapsModule.imgsDraw
          object mbMText: TSpTBXItem
            Caption = #22810#34892#25991#23383
            OnClick = acMTextExecute
          end
          object mbSText: TSpTBXItem
            Caption = #21333#34892#25991#23383
            OnClick = acSTextExecute
          end
        end
      end
      object mnDimention: TSpTBXSubmenuItem
        Caption = #26631#27880'(&D)'
        object mbDimLinear: TSpTBXItem
          Caption = #32447#24615
          ImageIndex = 0
          Images = BitmapsModule.imgsDim
          OnClick = acDimLeaderExecute
        end
        object mbDimAligned: TSpTBXItem
          Caption = #23545#20854
          ImageIndex = 1
          Images = BitmapsModule.imgsDim
          OnClick = acDimAlignedExecute
        end
        object mbDimArcLength: TSpTBXItem
          Caption = #24359#38271
          ImageIndex = 2
          Images = BitmapsModule.imgsDim
          OnClick = acDimArcExecute
        end
        object mbDimOrdinate: TSpTBXItem
          Caption = #22352#26631
          ImageIndex = 3
          Images = BitmapsModule.imgsDim
          OnClick = acDimOrdinateExecute
        end
        object TBXSeparatorItem28: TSpTBXSeparatorItem
        end
        object mbDimRadius: TSpTBXItem
          Caption = #21322#24452
          ImageIndex = 4
          Images = BitmapsModule.imgsDim
          OnClick = acDimRadiusExecute
        end
        object mbDimJogged: TSpTBXItem
          Caption = #25240#24367
          ImageIndex = 5
          Images = BitmapsModule.imgsDim
          OnClick = acDimJoggedExecute
        end
        object mbDimDiameter: TSpTBXItem
          Caption = #30452#24452
          ImageIndex = 6
          Images = BitmapsModule.imgsDim
          OnClick = acDimDiameterExecute
        end
        object mbDimAngular: TSpTBXItem
          Caption = #35282#24230
          ImageIndex = 7
          Images = BitmapsModule.imgsDim
          OnClick = acDimAngularExecute
        end
        object TBXSeparatorItem29: TSpTBXSeparatorItem
        end
        object mbDimBaseline: TSpTBXItem
          Caption = #22522#32447
          ImageIndex = 9
          Images = BitmapsModule.imgsDim
        end
        object mbDimContinue: TSpTBXItem
          Caption = #36830#32493
          ImageIndex = 10
          Images = BitmapsModule.imgsDim
          OnClick = acDimContinueExecute
        end
        object TBXSeparatorItem30: TSpTBXSeparatorItem
        end
        object mbDimLeader: TSpTBXItem
          Caption = #24341#32447
          ImageIndex = 11
          Images = BitmapsModule.imgsDim
          OnClick = acDimLeaderExecute
        end
        object mbDimTolerance: TSpTBXItem
          Caption = #20844#24046'...'
          ImageIndex = 12
          Images = BitmapsModule.imgsDim
          OnClick = acDimToleranceExecute
        end
        object mbDimCenter: TSpTBXItem
          Caption = #22278#24515#26631#35760
          ImageIndex = 13
          Images = BitmapsModule.imgsDim
          OnClick = acDimCenterExecute
        end
        object TBXSeparatorItem31: TSpTBXSeparatorItem
        end
        object mbDimEdit: TSpTBXItem
          Caption = #32534#36753
          ImageIndex = 15
          Images = BitmapsModule.imgsDim
          OnClick = acDimEditClick
        end
        object tbAlignDimText: TSpTBXSubmenuItem
          Caption = #25991#26412#23545#40784
          ImageIndex = 14
          Images = BitmapsModule.imgsDim
          object tbDimTextAlignHome: TSpTBXItem
            Caption = #40664#35748
            OnClick = acDimTextAlignClick
          end
          object tbDimTextAlignAngle: TSpTBXItem
            Tag = 1
            Caption = #35282#24230
            OnClick = acDimTextAlignClick
          end
          object SpTBXSeparatorItem10: TSpTBXSeparatorItem
          end
          object tbDimTextAlignLeft: TSpTBXItem
            Tag = 2
            Caption = #24038
            OnClick = acDimTextAlignClick
          end
          object tbDimTextAlignCenter: TSpTBXItem
            Tag = 3
            Caption = #20013
            OnClick = acDimTextAlignClick
          end
          object tbDimTextAlignRight: TSpTBXItem
            Tag = 4
            Caption = #21491
            OnClick = acDimTextAlignClick
          end
        end
        object TBXSeparatorItem32: TSpTBXSeparatorItem
        end
        object mbDimStyle: TSpTBXItem
          Caption = #26679#24335'...'
          ImageIndex = 17
          Images = BitmapsModule.imgsDim
          OnClick = acDimStyleExecute
        end
        object mbDimOverride: TSpTBXItem
          Caption = #26367#20195
          ImageIndex = 15
          Images = BitmapsModule.imgsDim
          Visible = False
          OnClick = acDimOverrideExecute
        end
        object mbDimUpdate: TSpTBXItem
          Caption = #26356#26032
          ImageIndex = 16
          Images = BitmapsModule.imgsDim
          OnClick = acDimUpdateExecute
        end
      end
      object mnModify: TSpTBXSubmenuItem
        Caption = #20462#25913'(&M)'
        object mbProperties: TSpTBXItem
          Caption = #23545#35937#23646#24615'...'
          ImageIndex = 21
          Images = BitmapsModule.imgsStd
          OnClick = acPropertiesExecute
        end
        object mbMatch: TSpTBXItem
          Caption = #23646#24615#21305#37197
          ImageIndex = 11
          Images = BitmapsModule.imgsStd
          OnClick = acMatchExecute
        end
        object TBXSeparatorItem33: TSpTBXSeparatorItem
        end
        object mbErase: TSpTBXItem
          Caption = #21024#38500
          ImageIndex = 0
          Images = BitmapsModule.imgsModify
          OnClick = acEraseExecute
        end
        object mbCopy: TSpTBXItem
          Caption = #22797#21046
          ImageIndex = 1
          Images = BitmapsModule.imgsModify
          OnClick = acCopyObjExecute
        end
        object mbMirror: TSpTBXItem
          Caption = #38236#20687
          ImageIndex = 2
          Images = BitmapsModule.imgsModify
          OnClick = acMirrorExecute
        end
        object mbOffset: TSpTBXItem
          Caption = #20559#31227
          ImageIndex = 3
          Images = BitmapsModule.imgsModify
          OnClick = acOffsetExecute
        end
        object mbArray: TSpTBXItem
          Caption = #38453#21015
          ImageIndex = 4
          Images = BitmapsModule.imgsModify
          OnClick = acArrayExecute
        end
        object TBXSeparatorItem34: TSpTBXSeparatorItem
        end
        object mbMove: TSpTBXItem
          Caption = #31227#21160
          ImageIndex = 5
          Images = BitmapsModule.imgsModify
          OnClick = acMoveExecute
        end
        object mbRotate: TSpTBXItem
          Caption = #26059#36716
          ImageIndex = 6
          Images = BitmapsModule.imgsModify
          OnClick = acRotateExecute
        end
        object mbScale: TSpTBXItem
          Caption = #32553#25918
          ImageIndex = 7
          Images = BitmapsModule.imgsModify
          OnClick = acScaleExecute
        end
        object mbStretch: TSpTBXItem
          Caption = #25289#20280
          ImageIndex = 8
          Images = BitmapsModule.imgsModify
          OnClick = acStretchExecute
        end
        object mbLengthen: TSpTBXItem
          Caption = #25289#38271
          ImageIndex = 9
          Images = BitmapsModule.imgsModify
          OnClick = acLengthenExecute
        end
        object TBXSeparatorItem35: TSpTBXSeparatorItem
        end
        object mbTrim: TSpTBXItem
          Caption = #20462#21098
          ImageIndex = 10
          Images = BitmapsModule.imgsModify
          OnClick = acTrimExecute
        end
        object mbExtend: TSpTBXItem
          Caption = #24310#20280
          ImageIndex = 11
          Images = BitmapsModule.imgsModify
          OnClick = acExtendExecute
        end
        object mbBreak: TSpTBXItem
          Caption = #25171#26029
          ImageIndex = 12
          Images = BitmapsModule.imgsModify
          OnClick = acBreakExecute
        end
        object mbBreakAtPnt: TSpTBXItem
          Caption = #25171#26029#20110#21333#28857
          ImageIndex = 13
          Images = BitmapsModule.imgsModify
          OnClick = acBreakAtPntExecute
        end
        object mbChamfer: TSpTBXItem
          Caption = #20498#35282
          ImageIndex = 15
          Images = BitmapsModule.imgsModify
          OnClick = acChamferExecute
        end
        object mbFillet: TSpTBXItem
          Caption = #22278#35282
          ImageIndex = 15
          Images = BitmapsModule.imgsModify
          OnClick = acFilletExecute
        end
        object TBXSeparatorItem36: TSpTBXSeparatorItem
        end
        object mbUnion: TSpTBXItem
          Caption = #24182#38598
          ImageIndex = 18
          Images = BitmapsModule.imgsModify
          Visible = False
          OnClick = acUnionExecute
        end
        object mbSubtract: TSpTBXItem
          Caption = #24046#38598
          ImageIndex = 19
          Images = BitmapsModule.imgsModify
          Visible = False
          OnClick = acSubtractExecute
        end
        object mbIntersect: TSpTBXItem
          Caption = #20132#38598
          ImageIndex = 20
          Images = BitmapsModule.imgsModify
          Visible = False
          OnClick = acIntersectExecute
        end
        object TBXSeparatorItem37: TSpTBXSeparatorItem
        end
        object mbEditText: TSpTBXItem
          Caption = #32534#36753#25991#26412
          ImageIndex = 21
          Images = BitmapsModule.imgsModify
          OnClick = acEditTextExecute
        end
        object mbEditHatch: TSpTBXItem
          Caption = #32534#36753#22270#26696#22635#20805
          ImageIndex = 22
          Images = BitmapsModule.imgsModify
          OnClick = acEditHatchExecute
        end
        object mbExplode: TSpTBXItem
          Caption = #28856#24320
          ImageIndex = 17
          Images = BitmapsModule.imgsModify
          OnClick = acExplodeExecute
        end
      end
      object mnWindow: TSpTBXSubmenuItem
        Caption = '&Window'
        Visible = False
        object mbCascade: TSpTBXItem
          Caption = 'Cascade'
        end
        object mbNextWindow: TSpTBXItem
          Caption = 'Next Window'
        end
        object TBXSeparatorItem74: TSpTBXSeparatorItem
        end
      end
      object mnHelp: TSpTBXSubmenuItem
        Caption = #24110#21161'(&H)'
        object mbContents: TSpTBXItem
          Caption = #24110#21161
        end
        object mbAbout: TSpTBXItem
          Caption = #20851#20110
          OnClick = mbAboutClick
        end
      end
      object TBXSubmenuItem2: TSpTBXSubmenuItem
        Caption = '&Test'
        Visible = False
        object btnAddLine: TSpTBXItem
          Caption = 'AddLine'
          OnClick = btnAddLineClick
        end
        object btnAddCircle: TSpTBXItem
          Caption = 'AddCircle'
          OnClick = btnAddCircleClick
        end
        object btnAddArc: TSpTBXItem
          Caption = 'AddArc'
          OnClick = btnAddArcClick
        end
        object btnAddEllipse: TSpTBXItem
          Caption = 'AddEllipse'
          OnClick = btnAddEllipseClick
        end
        object btnAddPoints: TSpTBXItem
          Caption = 'AddPoints'
          OnClick = btnAddPointsClick
        end
        object btnAddSegarc: TSpTBXItem
          Caption = 'AddSegarc'
          OnClick = btnAddSegarcClick
        end
        object btnAddSegarcs: TSpTBXItem
          Caption = 'AddSegarcs'
          OnClick = btnAddSegarcsClick
        end
        object SpTBXSeparatorItem3: TSpTBXSeparatorItem
        end
        object btnArrowBlocks: TSpTBXItem
          Caption = 'ArrowBlocks'
          OnClick = btnArrowBlocksClick
        end
      end
    end
    object StdToolbar: TSpTBXToolbar
      Left = 0
      Top = 27
      DefaultDock = TopDock
      DockableTo = [dpTop, dpBottom]
      DockPos = -6
      DockRow = 1
      Images = BitmapsModule.imgsStd
      TabOrder = 1
      Caption = 'Standard'
      object tbNew: TSpTBXItem
        Caption = 'New...'
        ImageIndex = 0
        ShortCut = 16462
        OnClick = acNewExecute
      end
      object tbOpen: TSpTBXItem
        Caption = 'Open...'
        ImageIndex = 1
        ShortCut = 16463
        OnClick = acOpenExecute
      end
      object tbSave: TSpTBXItem
        Caption = 'Save'
        ImageIndex = 2
        ShortCut = 16467
        OnClick = acSaveExecute
      end
      object SpTBXSeparatorItem6: TSpTBXSeparatorItem
      end
      object tbPrint: TSpTBXItem
        Caption = 'Print'
        ImageIndex = 5
        OnClick = acPrintExecute
      end
      object tbPreview: TSpTBXItem
        Caption = 'Preview'
        ImageIndex = 4
        Visible = False
        OnClick = acPreView2Decute
      end
      object TBXSeparatorItem63: TSpTBXSeparatorItem
      end
      object tbCut: TSpTBXItem
        Caption = 'Cut'
        ImageIndex = 6
        ShortCut = 16472
        OnClick = acCutExecute
      end
      object tbCopy: TSpTBXItem
        Caption = 'Copy'
        ImageIndex = 7
        ShortCut = 16451
        OnClick = acCopyExecute
      end
      object tbPaste: TSpTBXItem
        Caption = 'Paste'
        ImageIndex = 8
        ShortCut = 16470
        OnClick = acPasteExecute
      end
      object TBXSeparatorItem12: TSpTBXSeparatorItem
      end
      object tbMatch: TSpTBXItem
        Caption = 'Match Properties'
        ImageIndex = 11
        OnClick = acMatchExecute
      end
      object tbObjSnap: TSpTBXSubmenuItem
        Caption = 'Object Snap'
        ImageIndex = 20
        Options = [tboDropdownArrow, tboToolbarStyle]
        SubMenuImages = BitmapsModule.imgsSnap
        ToolBoxPopup = True
        object tbSnapFrom2: TSpTBXItem
          Caption = 'Snap Form'
          ImageIndex = 1
          OnClick = acSnapFromExecute
          Alignment = taLeftJustify
        end
        object TBXSeparatorItem72: TSpTBXSeparatorItem
        end
        object tbSnapEndpoint2: TSpTBXItem
          Caption = 'Snap to Endpoint'
          ImageIndex = 2
          OnClick = acSnapEndExecute
          Alignment = taLeftJustify
        end
        object tbSnapMidpoint2: TSpTBXItem
          Caption = 'Snap to Midpoint'
          ImageIndex = 5
          OnClick = acSnapMidExecute
          Alignment = taLeftJustify
        end
        object tbSnapIntersection2: TSpTBXItem
          Caption = 'Snap to Intersection'
          ImageIndex = 4
          OnClick = acSnapIntesExecute
          Alignment = taLeftJustify
        end
        object TBXSeparatorItem68: TSpTBXSeparatorItem
        end
        object tbSnapCenter2: TSpTBXItem
          Caption = 'Snap to Center'
          ImageIndex = 6
          OnClick = acSnapCenterExecute
          Alignment = taLeftJustify
        end
        object tbSnapQuad2: TSpTBXItem
          Caption = 'Snap to Quadrant'
          ImageIndex = 7
          OnClick = acSnapQuadExecute
          Alignment = taLeftJustify
        end
        object tbSnapTan2: TSpTBXItem
          Caption = 'Snap to Tangent'
          ImageIndex = 8
          OnClick = acSnapTanExecute
          Alignment = taLeftJustify
        end
        object TBXSeparatorItem69: TSpTBXSeparatorItem
        end
        object tbSnapPerp2: TSpTBXItem
          Caption = 'Snap to Perpendicular'
          ImageIndex = 9
          OnClick = acSnapPerpExecute
          Alignment = taLeftJustify
        end
        object tbSnapInsert2: TSpTBXItem
          Caption = 'Snap to Insert'
          ImageIndex = 11
          OnClick = acSnapInsertExecute
          Alignment = taLeftJustify
        end
        object tbSnapNode2: TSpTBXItem
          Caption = 'Snap to Node'
          ImageIndex = 12
          OnClick = acSnapNodeExecute
          Alignment = taLeftJustify
        end
        object TBXSeparatorItem71: TSpTBXSeparatorItem
        end
        object tbSnapNearest2: TSpTBXItem
          Caption = 'Snap to Nearest'
          ImageIndex = 13
          Visible = False
          OnClick = acSnapNearestExecute
          Alignment = taLeftJustify
        end
        object tbSnapNone2: TSpTBXItem
          Caption = 'Snap to None'
          ImageIndex = 15
          OnClick = acSnapNoneExecute
          Alignment = taLeftJustify
        end
        object tbSnapSetting2: TSpTBXItem
          Caption = 'Snap Setting'
          ImageIndex = 16
          OnClick = acSnapSettingExecute
          Alignment = taLeftJustify
        end
      end
      object TBXSeparatorItem14: TSpTBXSeparatorItem
      end
      object tbUndo: TSpTBXItem
        Caption = 'Undo'
        Enabled = False
        ImageIndex = 9
        ShortCut = 16474
        OnClick = acUndoExecute
      end
      object tbRedo: TSpTBXItem
        Caption = 'Redo'
        Enabled = False
        ImageIndex = 10
        ShortCut = 16473
        OnClick = acRedoExecute
      end
      object TBXSeparatorItem15: TSpTBXSeparatorItem
      end
      object tbPan: TSpTBXItem
        Caption = 'Pan Realtime'
        ImageIndex = 12
        OnClick = acPanRealExecute
      end
      object tbZoomReal: TSpTBXItem
        Caption = 'Zoom Realtime'
        ImageIndex = 13
        OnClick = acZoomRealExecute
      end
      object tbZoomWin: TSpTBXItem
        Caption = 'Zoom Window'
        ImageIndex = 14
        OnClick = acZoomWinExecute
      end
      object TBXSeparatorItem59: TSpTBXSeparatorItem
      end
      object tbZoomAll: TSpTBXItem
        Caption = 'Zoom All'
        ImageIndex = 15
        OnClick = acZoomAllExecute
      end
      object tbZoomIn: TSpTBXItem
        Caption = 'Zoom In'
        ImageIndex = 17
        OnClick = acZoomInExecute
      end
      object tbZoomOut: TSpTBXItem
        Caption = 'Zoom Out'
        ImageIndex = 18
        OnClick = acZoomOutExecute
      end
      object tbZoomPrev: TSpTBXItem
        Caption = 'Zoom Prevouse'
        ImageIndex = 19
        OnClick = acZoomPrevExecute
      end
      object TBXSeparatorItem23: TSpTBXSeparatorItem
      end
      object tbProperties: TSpTBXItem
        Caption = 'Properties...'
        ImageIndex = 21
        OnClick = acPropertiesExecute
      end
      object tbCalculator: TSpTBXItem
        Caption = 'Calculator'
        ImageIndex = 22
        OnClick = acCalculatorExecute
      end
    end
    object PropToolbar: TSpTBXToolbar
      Left = 0
      Top = 54
      DockPos = 0
      DockRow = 2
      Images = BitmapsModule.ImgsLayer
      TabOrder = 2
      Caption = 'Object Properties'
      object tbSetLayer: TSpTBXItem
        Caption = 'Set Layer'
        ImageIndex = 0
      end
      object tbLayer: TSpTBXItem
        Caption = 'Layers'
        ImageIndex = 1
        OnClick = acLayerExecute
      end
      object SpTBXSeparatorItem5: TSpTBXSeparatorItem
      end
      object tbLinetype: TSpTBXItem
        Caption = '=='
        ImageIndex = 2
        OnClick = acLinetypeExecute
      end
    end
    object InquiryToobar: TSpTBXToolbar
      Left = 523
      Top = 27
      DockPos = 523
      DockRow = 1
      Images = BitmapsModule.imgsInquiry
      TabOrder = 3
      Caption = 'Inquiry'
      object tbDistance: TSpTBXItem
        Caption = 'Distance'
        ImageIndex = 0
        OnClick = acDistanceExecute
      end
      object tbArea: TSpTBXItem
        Caption = 'Area'
        ImageIndex = 1
        OnClick = acAreaExecute
      end
      object TBXSeparatorItem65: TSpTBXSeparatorItem
        Visible = False
      end
      object tbList: TSpTBXItem
        Caption = 'List'
        ImageIndex = 3
        Visible = False
        OnClick = acListExecute
      end
      object tbLocatePoint: TSpTBXItem
        Caption = 'Locate Point'
        ImageIndex = 4
        OnClick = acLocatePointExecute
      end
    end
    object OrderToolbar: TSpTBXToolbar
      Left = 602
      Top = 27
      DockPos = 592
      DockRow = 1
      Images = BitmapsModule.imgsDisOrder
      TabOrder = 4
      Caption = 'Order'
      object tbBringFront: TSpTBXItem
        Caption = 'Bring to Front'
        ImageIndex = 0
        OnClick = acBringFrontExecute
      end
      object tbSendBack: TSpTBXItem
        Caption = 'Send to Back'
        ImageIndex = 1
        OnClick = acSendBackExecute
      end
      object SpTBXSeparatorItem11: TSpTBXSeparatorItem
      end
      object tbBringAbove: TSpTBXItem
        Tag = 1
        Caption = 'Bring Above Objects'
        ImageIndex = 2
        OnClick = acBringFrontExecute
      end
      object tbSendUnder: TSpTBXItem
        Tag = 1
        Caption = 'Send Under Objects'
        ImageIndex = 3
        OnClick = acSendBackExecute
      end
    end
    object TestToolbar: TSpTBXToolbar
      Left = 415
      Top = 54
      DockPos = 415
      DockRow = 2
      TabOrder = 5
      Caption = 'Test'
      object btnLoopSearch: TSpTBXItem
        Caption = 'LoopSearch'
        OnClick = btnLoopSearchClick
      end
      object btnAddImage: TSpTBXItem
        Caption = 'AddImage'
        OnClick = btnAddImageClick
      end
      object btnAddFog: TSpTBXItem
        Caption = 'AddFog'
        OnClick = btnAddFogClick
      end
    end
  end
  object RightDock: TSpTBXDock
    Left = 1041
    Top = 81
    Width = 54
    Height = 474
    Position = dpRight
    object SnapToolbar: TSpTBXToolbar
      Left = 0
      Top = 0
      DefaultDock = RightDock
      DockPos = 0
      Images = BitmapsModule.imgsSnap
      TabOrder = 0
      Caption = 'Object Snap'
      object tbSnapFrom: TSpTBXItem
        Caption = 'Snap Form'
        ImageIndex = 1
        OnClick = acSnapFromExecute
      end
      object TBXSeparatorItem50: TSpTBXSeparatorItem
      end
      object tbSnapEndpoint: TSpTBXItem
        Caption = 'Snap to Endpoint'
        ImageIndex = 2
        OnClick = acSnapEndExecute
      end
      object tbSnapMidpoint: TSpTBXItem
        Caption = 'Snap to Midpoint'
        ImageIndex = 5
        OnClick = acSnapMidExecute
      end
      object tbSnapIntersection: TSpTBXItem
        Caption = 'Snap to Intersection'
        ImageIndex = 4
        OnClick = acSnapIntesExecute
      end
      object TBXSeparatorItem51: TSpTBXSeparatorItem
      end
      object tbSnapCenter: TSpTBXItem
        Caption = 'Snap to Center'
        ImageIndex = 6
        OnClick = acSnapCenterExecute
      end
      object tbSnapQuad: TSpTBXItem
        Caption = 'Snap to Quadrant'
        ImageIndex = 7
        OnClick = acSnapQuadExecute
      end
      object tbSnapTan: TSpTBXItem
        Caption = 'Snap to Tangent'
        ImageIndex = 8
        OnClick = acSnapTanExecute
      end
      object TBXSeparatorItem52: TSpTBXSeparatorItem
      end
      object tbSnapPerp: TSpTBXItem
        Caption = 'Snap to Perpendicular'
        ImageIndex = 9
        OnClick = acSnapPerpExecute
      end
      object tbSnapInsert: TSpTBXItem
        Caption = 'Snap to Insert'
        ImageIndex = 11
        OnClick = acSnapInsertExecute
      end
      object tbSnapNode: TSpTBXItem
        Caption = 'Snap to Node'
        ImageIndex = 12
        OnClick = acSnapNodeExecute
      end
      object TBXSeparatorItem53: TSpTBXSeparatorItem
      end
      object tbSnapNearest: TSpTBXItem
        Caption = 'Snap to Nearest'
        ImageIndex = 13
        OnClick = acSnapNearestExecute
      end
      object tbSnapNone: TSpTBXItem
        Caption = 'Snap to None'
        ImageIndex = 15
        OnClick = acSnapNoneExecute
      end
      object tbSnapSetting: TSpTBXItem
        Caption = 'Snap Setting'
        ImageIndex = 16
        OnClick = acSnapSettingExecute
      end
    end
    object DimToolbar: TSpTBXToolbar
      Left = 27
      Top = 0
      DefaultDock = RightDock
      DockPos = 0
      DockRow = 1
      Images = BitmapsModule.imgsDim
      TabOrder = 1
      Caption = 'Dimention'
      object tbDimLinear: TSpTBXItem
        Caption = 'Linear'
        ImageIndex = 0
        OnClick = acDimLinearExecute
      end
      object tbDimAligned: TSpTBXItem
        Caption = 'Aligned'
        ImageIndex = 1
        OnClick = acDimAlignedExecute
      end
      object tbDimArcLength: TSpTBXItem
        Caption = 'ArcLength'
        ImageIndex = 2
        OnClick = acDimArcExecute
      end
      object tbDimOrdinate: TSpTBXItem
        Caption = 'Ordinate'
        ImageIndex = 3
        OnClick = acDimOrdinateExecute
      end
      object TBXSeparatorItem54: TSpTBXSeparatorItem
      end
      object tbDimRadius: TSpTBXItem
        Caption = 'Radius'
        ImageIndex = 4
        OnClick = acDimRadiusExecute
      end
      object tbDimJogged: TSpTBXItem
        Caption = 'Jogged'
        ImageIndex = 5
        OnClick = acDimJoggedExecute
      end
      object tbDimDiameter: TSpTBXItem
        Caption = 'Diameter'
        ImageIndex = 6
        OnClick = acDimDiameterExecute
      end
      object tbDimAngular: TSpTBXItem
        Caption = 'Angular'
        ImageIndex = 7
        OnClick = acDimAngularExecute
      end
      object TBXSeparatorItem55: TSpTBXSeparatorItem
      end
      object tbDimBaseline: TSpTBXItem
        Caption = 'Baseline'
        ImageIndex = 9
        OnClick = acDimBaselineExecute
      end
      object tbDimContinue: TSpTBXItem
        Caption = 'Continue'
        ImageIndex = 10
        OnClick = acDimContinueExecute
      end
      object TBXSeparatorItem56: TSpTBXSeparatorItem
      end
      object tbDimLeader: TSpTBXItem
        Caption = 'Leader'
        ImageIndex = 11
        OnClick = acDimLeaderExecute
      end
      object tbDimTolerance: TSpTBXItem
        Caption = 'Tolerance'
        ImageIndex = 12
        OnClick = acDimToleranceExecute
      end
      object tbCenterMark: TSpTBXItem
        Caption = 'Center Mark'
        ImageIndex = 13
        OnClick = acDimCenterExecute
      end
      object TBXSeparatorItem57: TSpTBXSeparatorItem
      end
      object tbDimTextAlign: TSpTBXItem
        Caption = 'Dimention TextAlign'
        ImageIndex = 14
        OnClick = acDimTextAlignClick
      end
      object tbDimTextEdit: TSpTBXItem
        Caption = 'Dimention Text Edit'
        ImageIndex = 15
        OnClick = acDimTextEditClick
      end
      object TBXSeparatorItem58: TSpTBXSeparatorItem
      end
      object tbDimUpdate: TSpTBXItem
        Caption = 'Update'
        ImageIndex = 16
        OnClick = acDimUpdateExecute
      end
      object tbDimStyle: TSpTBXItem
        Caption = 'Dimention Style...'
        ImageIndex = 17
        OnClick = acDimStyleExecute
      end
    end
  end
  object LeftDock: TSpTBXDock
    Left = 219
    Top = 81
    Width = 54
    Height = 474
    Position = dpLeft
    object DrawToolbar: TSpTBXToolbar
      Left = 27
      Top = 0
      DefaultDock = LeftDock
      DockPos = 0
      DockRow = 1
      Images = BitmapsModule.imgsDraw
      TabOrder = 0
      Caption = 'Draw'
      object tbLine: TSpTBXItem
        Caption = 'Line'
        ImageIndex = 0
        OnClick = acLineExecute
      end
      object tbRay: TSpTBXItem
        Caption = 'Ray'
        ImageIndex = 1
        Visible = False
        OnClick = acRayExecute
      end
      object tbXLine: TSpTBXItem
        Caption = 'XLine'
        ImageIndex = 2
        OnClick = acXLineExecute
      end
      object tbPolyline: TSpTBXItem
        Caption = 'Polyline'
        ImageIndex = 3
        OnClick = acPolylineExecute
      end
      object tbPolygon: TSpTBXItem
        Caption = 'Polygon'
        ImageIndex = 4
        OnClick = acPolygonExecute
      end
      object tbRectangle: TSpTBXItem
        Caption = 'Rectangle'
        ImageIndex = 5
        OnClick = acRectExecute
      end
      object TBXSeparatorItem42: TSpTBXSeparatorItem
      end
      object tbArc: TSpTBXItem
        Caption = 'Arc 3 Point'
        ImageIndex = 6
        OnClick = acArc3PExecute
      end
      object tbArcs: TSpTBXSubmenuItem
        Caption = 'Arc'
        ImageIndex = 7
        object tbArcSCE: TSpTBXItem
          Caption = 'Start, Center, End'
          ImageIndex = 7
          Visible = False
          OnClick = acArcSCEClick
        end
        object tbArcSCA: TSpTBXItem
          Caption = 'Start, Center, Angle'
          ImageIndex = 8
          Visible = False
          OnClick = acArcSCAClick
        end
        object tbArcSCL: TSpTBXItem
          Caption = 'Start, Center, Length'
          ImageIndex = 9
          Visible = False
          OnClick = acArcSCLClick
        end
        object SpTBXSeparatorItem8: TSpTBXSeparatorItem
          Visible = False
        end
        object tbArcSEA: TSpTBXItem
          Caption = 'Start,  End,  Angle'
          Visible = False
          OnClick = acArcSEAClick
        end
        object tbArcSED: TSpTBXItem
          Caption = 'Start,  End,  Direction'
          Visible = False
          OnClick = acArcSEDClick
        end
        object tbArcSER: TSpTBXItem
          Caption = 'Start,  End,  Radius'
          Visible = False
          OnClick = acArcSERClick
        end
        object SpTBXSeparatorItem9: TSpTBXSeparatorItem
          Visible = False
        end
        object tbArcCSE: TSpTBXItem
          Caption = 'Center, Start, End'
          ImageIndex = 7
          OnClick = acArcCSEClick
        end
        object tbArcCSA: TSpTBXItem
          Caption = 'Center, Start, Angle'
          ImageIndex = 8
          OnClick = acArcCSAClick
        end
        object tbArcCSL: TSpTBXItem
          Caption = 'Center, Start, Length'
          ImageIndex = 9
          OnClick = acArcCSLClick
        end
      end
      object TBXSeparatorItem78: TSpTBXSeparatorItem
      end
      object tbCircleCR: TSpTBXItem
        Caption = 'Circle Center Radius'
        ImageIndex = 10
        OnClick = acCircleCRExecute
      end
      object tbCircle2P: TSpTBXItem
        Caption = 'Circle 2 Points'
        ImageIndex = 12
        OnClick = acCircle2PExecute
      end
      object tbCircle3P: TSpTBXItem
        Caption = 'Circle 3 Points'
        ImageIndex = 13
        OnClick = acCircle3PExecute
      end
      object TBXSeparatorItem79: TSpTBXSeparatorItem
      end
      object tbEllipse: TSpTBXItem
        Caption = 'Ellipse Axis, End'
        ImageIndex = 14
        OnClick = acEllipseAEExecute
      end
      object tbEllipseArc: TSpTBXItem
        Caption = 'Ellipse Arc'
        ImageIndex = 15
        OnClick = acEllipseArcExecute
      end
      object SpTBXSeparatorItem4: TSpTBXSeparatorItem
      end
      object tbSpline: TSpTBXItem
        Caption = 'Spline'
        ImageIndex = 18
        OnClick = acSplineExecute
      end
      object TBXSeparatorItem43: TSpTBXSeparatorItem
      end
      object tbInsBlock: TSpTBXItem
        Caption = 'Insert Block'
        ImageIndex = 16
        OnClick = acInsBlockExecute
      end
      object tbMakeBlock: TSpTBXItem
        Caption = 'Make Block'
        ImageIndex = 17
        OnClick = acMakeBlockExecute
      end
      object TBXSeparatorItem44: TSpTBXSeparatorItem
      end
      object tbPoint: TSpTBXItem
        Caption = 'Point'
        ImageIndex = 21
        OnClick = acPointExecute
      end
      object TBXSeparatorItem45: TSpTBXSeparatorItem
      end
      object tbHatch: TSpTBXItem
        Caption = 'Hatch...'
        ImageIndex = 26
        OnClick = acHatchExecute
      end
      object tbRegion: TSpTBXItem
        Caption = 'Region'
        ImageIndex = 27
        Visible = False
        OnClick = acRegionExecute
      end
      object TBXSeparatorItem46: TSpTBXSeparatorItem
      end
      object tbText: TSpTBXItem
        Caption = 'Muliiline Text'
        ImageIndex = 24
        OnClick = acMTextExecute
      end
    end
    object ModifyToolbar: TSpTBXToolbar
      Left = 0
      Top = 0
      DefaultDock = LeftDock
      DockPos = -20
      Images = BitmapsModule.imgsModify
      TabOrder = 1
      Caption = 'Modify'
      object tbErase: TSpTBXItem
        Caption = 'Erase'
        ImageIndex = 0
        OnClick = acEraseExecute
      end
      object tbCopyObj: TSpTBXItem
        Caption = 'Copy Object'
        ImageIndex = 1
        OnClick = acCopyObjExecute
      end
      object TBXSeparatorItem41: TSpTBXSeparatorItem
      end
      object tbMirror: TSpTBXItem
        Caption = 'Mirror'
        ImageIndex = 2
        OnClick = acMirrorExecute
      end
      object tbOffset: TSpTBXItem
        Caption = 'Offset'
        ImageIndex = 3
        OnClick = acOffsetExecute
      end
      object tbArray: TSpTBXItem
        Caption = 'Array'
        ImageIndex = 4
        OnClick = acArrayExecute
      end
      object tbMove: TSpTBXItem
        Caption = 'Move'
        ImageIndex = 5
        OnClick = acMoveExecute
      end
      object tbRotate: TSpTBXItem
        Caption = 'Rotate'
        ImageIndex = 6
        OnClick = acRotateExecute
      end
      object tbScale: TSpTBXItem
        Caption = 'Scale'
        ImageIndex = 7
        OnClick = acScaleExecute
      end
      object TBXSeparatorItem47: TSpTBXSeparatorItem
      end
      object tbLengthen: TSpTBXItem
        Caption = 'Lengthen'
        ImageIndex = 9
        Visible = False
        OnClick = acLengthenExecute
      end
      object tbTrim: TSpTBXItem
        Caption = 'Trim'
        ImageIndex = 10
        OnClick = acTrimExecute
      end
      object tbExtend: TSpTBXItem
        Caption = 'Extend'
        ImageIndex = 11
        OnClick = acExtendExecute
      end
      object tbBreak: TSpTBXItem
        Caption = 'Break'
        ImageIndex = 12
        OnClick = acBreakExecute
      end
      object tbBreakAtPnt: TSpTBXItem
        Caption = 'Break At Point'
        ImageIndex = 13
        OnClick = acBreakAtPntExecute
      end
      object tbChamfer: TSpTBXItem
        Caption = 'Chamfer'
        ImageIndex = 16
        OnClick = acChamferExecute
      end
      object tbFillet: TSpTBXItem
        Caption = 'Fillet'
        ImageIndex = 15
        OnClick = acFilletExecute
      end
      object tbExplode: TSpTBXItem
        Caption = 'Explode'
        ImageIndex = 17
        OnClick = acExplodeExecute
      end
      object TBXSeparatorItem48: TSpTBXSeparatorItem
      end
      object tbUnion: TSpTBXItem
        Caption = 'Union'
        ImageIndex = 18
        Visible = False
        OnClick = acUnionExecute
      end
      object tbSubtract: TSpTBXItem
        Caption = 'Subtract'
        ImageIndex = 19
        Visible = False
        OnClick = acSubtractExecute
      end
      object tbIntersect: TSpTBXItem
        Caption = 'Intersect'
        ImageIndex = 20
        Visible = False
        OnClick = acIntersectExecute
      end
      object TBXSeparatorItem49: TSpTBXSeparatorItem
      end
      object tbEditHatch: TSpTBXItem
        Caption = 'Edit Hatch'
        ImageIndex = 22
        OnClick = acEditHatchExecute
      end
      object tbTextEdit: TSpTBXItem
        Caption = 'Edit Text'
        ImageIndex = 21
        OnClick = acEditTextExecute
      end
    end
  end
  object StatusBar: TSpTBXStatusBar
    Left = 0
    Top = 629
    Width = 1097
    Height = 27
    OnResize = StatusBarResize
    object SpTBXLabelItem1: TSpTBXLabelItem
    end
    object lblPos: TSpTBXLabelItem
      CustomWidth = 280
    end
    object SpTBXSeparatorItem2: TSpTBXSeparatorItem
    end
    object btnUseSnap: TSpTBXItem
      Tag = 1
      Caption = #25429#25417
      AutoCheck = True
      OnClick = DraftingModeChanged
      FontSettings.Color = clGray
    end
    object btnUseGrid: TSpTBXItem
      Caption = #26629#26684
      AutoCheck = True
      OnClick = DraftingModeChanged
      FontSettings.Color = clGray
    end
    object btnUseOrtho: TSpTBXItem
      Tag = 2
      Caption = #27491#20132
      AutoCheck = True
      OnClick = DraftingModeChanged
      FontSettings.Color = clGray
    end
    object btnUsePolar: TSpTBXItem
      Tag = 3
      Caption = #26497#36724
      AutoCheck = True
      OnClick = DraftingModeChanged
      FontSettings.Color = clGray
    end
    object btnUseOSnap: TSpTBXItem
      Tag = 4
      Caption = #23545#35937#25429#25417
      AutoCheck = True
      Checked = True
      OnClick = DraftingModeChanged
    end
    object btnUseLWT: TSpTBXItem
      Tag = 5
      Caption = #32447#23485
      AutoCheck = True
      OnClick = DraftingModeChanged
      FontSettings.Color = clGray
    end
    object SpTBXSeparatorItem1: TSpTBXSeparatorItem
    end
    object lblStatus: TSpTBXLabelItem
      Caption = ' '
    end
    object TBControlItem8: TTBControlItem
      Control = ProgressBar1
    end
    object ProgressBar1: TSpTBXProgressBar
      Left = 540
      Top = 3
      Width = 210
      Height = 17
      Caption = '0%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
  end
  object pnlClient: TPanel
    Left = 273
    Top = 81
    Width = 768
    Height = 474
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 4
  end
  object pnlCmdLine: TSpTBXDockablePanel
    Left = 0
    Top = 561
    Width = 1097
    Height = 68
    Caption = #21629#20196#34892
    Align = alBottom
    DockableTo = [dpBottom]
    DockPos = 0
    TabOrder = 5
    FixedDockedSize = True
    Options.Close = False
    ShowVerticalCaption = True
  end
  object sptBottom: TSpTBXSplitter
    Left = 0
    Top = 555
    Width = 1097
    Height = 6
    Cursor = crSizeNS
    Align = alBottom
    Color = clBtnFace
    ParentColor = False
    GripSize = 80
  end
  object sptProperties: TSpTBXSplitter
    Left = 214
    Top = 81
    Height = 474
    Cursor = crSizeWE
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 81
    Width = 214
    Height = 474
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 8
    OnResize = pnlLeftResize
    object LeftMultiDock: TSpTBXMultiDock
      Left = 0
      Top = 0
      Width = 214
      Height = 474
      object pnlProperties: TSpTBXDockablePanel
        Left = 0
        Top = 0
        Width = 214
        Height = 474
        Caption = #23545#35937#23646#24615
        DockableTo = [dpLeft, dpRight]
        DockPos = 0
        TabOrder = 0
        OnClose = pnlPropertiesClose
        OnDockChanging = pnlPropertiesDockChanging
      end
    end
  end
  object pnlRight: TPanel
    Tag = 1
    Left = 1095
    Top = 81
    Width = 2
    Height = 474
    Align = alRight
    TabOrder = 9
    OnResize = pnlLeftResize
    object RightMultiDock: TSpTBXMultiDock
      Left = -8
      Top = 1
      Width = 9
      Height = 472
      Position = dpxRight
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
  object PopupMenu: TSpTBXPopupMenu
    OnPopup = PopupMenuPopup
    Options = [tboSameWidth]
    Left = 338
    Top = 149
    object nRepeat: TSpTBXItem
      Tag = 3
      Caption = 'Repeat'
      OnClick = nPopupRepeatClick
    end
    object nUnselectAll: TSpTBXItem
      Tag = 2
      Caption = 'Unselect all'
      OnClick = nPopupUnselectAllClick
    end
    object nExit: TSpTBXItem
      Tag = 4
      Caption = 'Exit'
      OnClick = nPopupExitClick
    end
    object nInputCoordinate: TSpTBXItem
      Tag = -1
      Caption = 'Input Coordinate...'
      OnClick = nPopupInputCoordinateClick
    end
    object nSnapoverrides: TSpTBXSubmenuItem
      Tag = 4
      Caption = 'Snap Overrides'
      LinkSubitems = tbObjSnap
    end
    object N1: TSpTBXSeparatorItem
    end
    object nZoomExtends: TSpTBXItem
      Tag = 1
      Caption = 'Zoom Extends'
      OnClick = acZoomExtendsExecute
    end
    object nZoomWindows: TSpTBXItem
      Tag = 1
      Caption = 'Zoom Windows'
      OnClick = acZoomWinExecute
    end
    object nZoomReal: TSpTBXItem
      Tag = 5
      Caption = 'Zoom Real'
      OnClick = acZoomRealExecute
    end
    object nZoomPan: TSpTBXItem
      Tag = 5
      Caption = 'Pan'
      OnClick = acPanRealExecute
    end
    object N2: TSpTBXSeparatorItem
    end
    object nErase: TSpTBXItem
      Tag = 2
      Caption = 'Erase'
      OnClick = acEraseExecute
    end
    object nMove: TSpTBXItem
      Tag = 2
      Caption = 'Move'
      OnClick = acMoveExecute
    end
    object nCopy: TSpTBXItem
      Tag = 2
      Caption = 'Copy'
      OnClick = acCopyExecute
    end
    object nRotate: TSpTBXItem
      Tag = 2
      Caption = 'Rotate'
      OnClick = acRotateExecute
    end
    object nScale: TSpTBXItem
      Tag = 2
      Caption = 'Scale'
      OnClick = acScaleExecute
    end
    object nMirror: TSpTBXItem
      Tag = 2
      Caption = 'Mirror'
      OnClick = acMirrorExecute
    end
    object nOffset: TSpTBXItem
      Tag = 2
      Caption = 'Offset'
      OnClick = acOffsetExecute
    end
  end
  object FogTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = FogTimerTimer
    Left = 563
    Top = 196
  end
end
