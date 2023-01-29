;
; EditorFactory.pbi
; Pure Basic include file for object management in a canvas gadget.
; Copyright (C) 2021, Dieppedalle David (alias Shadow)
;                     Martin Guttmann (alias STARGÅTE)
; 
; This source code is distributed under  Creative Commons Attribution-NonCom-
; mercial 4.0  International Public License  (CC BY-NC 4.0)  and is therefore
; per definition not "open source". You must give appropriate credit, provide
; a link to the license,  and indicate if changes were made.  You may not use 
; the material for commercial purposes.
; 
; This source code is provided "as is", without warranty of any kind, express
; or implied, including but not limited to the warranties of merchantability,
; fitness for a particular purpose and noninfringement. In no event shall the
; authors  or copyright  holders be liable  for any claim,  damages or  other
; liability,  whether in an action  of contract,  tort or otherwise,  arising
; from, out of, or in connection  with the code or the use  or other dealings
; in the source code.
; 
; License: https://creativecommons.org/licenses/by-nc/4.0/
;
; Additional credits:
;  - Shardik, for his code using custom cursors
;    https://www.purebasic.fr/english/viewtopic.php?p=558545
; 
; Current version of the Module: 1.17.01, on 2021-08-07.
;
; Change Log (1.15):
;  - Added: SetObjectFrameClipping(), SetObjectFrameOffset()
;  - Added: #Object_All, #Object_Default, #Object_Selected as possible constants for various functions.
;  - Added: #EventType_Created, #EventType_Freed
;  - Changed: CanvasObjectsEvent() do not need a specific gadget
;
; Change Log (1.16):
;  - Added: IsObjectFrame(), AddObjectFrame(), RemoveObjectFrame(), MoveObjectFrame()
;  - Added: ReleaseCanvasObjects()
;  - Added: #EventType_LeftMouseButtonHold, #EventType_RightMouseButtonHold, #EventType_MiddleMouseButtonHold
;  - Changed: CreateObject() - handling of the frame index!
;  - Changed: AddObjectFrame() - frame properties
;  - Changed: SetObjectFrameClipping() --> SetObjectFrameViewBox() - changed behavior
;  - Changed: SetObjectFrameOffset()   --> SetObjectFrameInnerOffset() - changed behavior
;
; Change Log (1.17):
;  - Added: Example #6: Example06_Gadgets.pb
;  - Changed: More states returned by ObjectState() to create custom gadget easily, see example #6



DeclareModule EditorFactory
	
	Enumeration -2 Step -1
		#Object_All
		#Object_Default
		#Object_Selected
	EndEnumeration
	
	EnumerationBinary Handle 1
		#Handle_Position      ; 1
		#Handle_BottomLeft
		#Handle_Bottom
		#Handle_BottomRight
		#Handle_Left
		#Handle_Rotation
		#Handle_Right
		#Handle_TopLeft
		#Handle_Top
		#Handle_TopRight
		#Handle_Custom1    ; 1024
		#Handle_Custom2
		#Handle_Custom3
		#Handle_Custom4
		#Handle_Custom5
		#Handle_Custom6
		#Handle_Custom7
		#Handle_Custom8
	EndEnumeration
	#Handle_None    = 0
	#Handle_Width   = #Handle_Left | #Handle_Right
	#Handle_Height  = #Handle_Top | #Handle_Bottom
	#Handle_Edge    = #Handle_Width | #Handle_Height
	#Handle_Corner  = #Handle_BottomLeft | #Handle_BottomRight | #Handle_TopLeft | #Handle_TopRight
	#Handle_Size    = #Handle_Edge | #Handle_Corner
	#Handle_Customs = #Handle_Custom1 | #Handle_Custom2 | #Handle_Custom3 | #Handle_Custom4 | #Handle_Custom5 | #Handle_Custom7 | #Handle_Custom8
	#Handle_All     = #Handle_Position | #Handle_Rotation | #Handle_Size | #Handle_Customs
	
	Enumeration
		#Handle_ShowIfHovered   = %001
		#Handle_ShowIfSelected  = %010
		#Handle_ShowAlways      = %111
	EndEnumeration
	
	EnumerationBinary 1
		#Alignment_Left
		#Alignment_Right
		#Alignment_Top
		#Alignment_Bottom
	EndEnumeration
	#Alignment_Center  = 0
	#Alignment_Middle  = 0
	#Alignment_Default = 0
	
	EnumerationBinary 1
		#Attachment_X
		#Attachment_Y
		#Attachment_Width
		#Attachment_Height
		#Attachment_PreserveGlobalPosition
	EndEnumeration
	
	#Attachment_Position = #Attachment_X | #Attachment_Y
	#Attachment_Size     = #Attachment_Width | #Attachment_Height
	
	
	EnumerationBinary
		#Frame_ChildDrawingCompletely
		#Frame_ChildDrawingClipped
	EndEnumeration
	
	Enumeration
		#Frame_NoFrame     = -3
		#Frame_ViewedFrame = -2
		#Frame_LastFrame   = -1
	EndEnumeration
	
	Enumeration -1
		#SelectionStyle_Default
		#SelectionStyle_None
		#SelectionStyle_Solid
		#SelectionStyle_Dotted
		#SelectionStyle_Dashed
	EndEnumeration
	#SelectionStyle_Mode       = $100
	#SelectionStyle_Completely = 0
	#SelectionStyle_Partially  = $100
	#SelectionStyle_Ignore = #PB_Ignore
	Enumeration -1
		#BoundaryStyle_Default
		#BoundaryStyle_None
		#BoundaryStyle_Solid
		#BoundaryStyle_Dotted
		#BoundaryStyle_Dashed
	EndEnumeration
	#BoundaryStyle_Ignore = #PB_Ignore
	
	#Boundary_Ignore          = -$80000000    ; 0b10000000...
	#Boundary_Default         = -$7FFFFFFF    ; 0b01111111...
	#Boundary_None            =  $3FFFFFFF    ; 0b00111111...
	#Boundary_ParentSize      =  $60000000    ; 0b01100000...
	#Boundary_ParentSizeMask  =  $C0000000    ; 0b11000000...
	
	Enumeration 1
		#Boundary_MinX
		#Boundary_MinY
		#Boundary_MaxX
		#Boundary_MaxY
		#Boundary_MinWidth
		#Boundary_MinHeight
		#Boundary_MaxWidth
		#Boundary_MaxHeight
	EndEnumeration
	
	;#Failed = -$80000000
	#PB_Cursor_Custom = -1
	
	Enumeration 0
		#Event_None
		#Event_Object
		#Event_Handle
	EndEnumeration
	
	Enumeration 0
		#EventType_None
		#EventType_MouseEnter
		#EventType_MouseLeave
		#EventType_LeftMouseBottonDown
		#EventType_LeftMouseBottonUp
		#EventType_LeftMouseClick
		#EventType_LeftMouseDoubleClick
		#EventType_LeftMouseButtonHold
		#EventType_RightMouseBottonDown
		#EventType_RightMouseBottonUp
		#EventType_RightMouseClick
		#EventType_RightMouseDoubleClick
		#EventType_RightMouseButtonHold
		#EventType_MiddleMouseBottonDown
		#EventType_MiddleMouseBottonUp
		#EventType_MiddleMouseClick
		#EventType_MiddleMouseDoubleClick
		#EventType_MiddleMouseButtonHold
		#EventType_Moved
		#EventType_Resized
		#EventType_Selected
		#EventType_Unselected
		#EventType_MouseWheel
		#EventType_KeyDown
		#EventType_KeyUp
		#EventType_Selection
		#EventType_Created
		#EventType_Freed
	EndEnumeration
	
	Enumeration 0
		#EventTypeData_Default
		#EventTypeData_MinX
		#EventTypeData_MinY
		#EventTypeData_MaxX
		#EventTypeData_MaxY
	EndEnumeration
	
	EnumerationBinary
		#State_Hidden
		#State_Disabled
		#State_Hovered
		#State_Selected
		#State_LeftMousePushed
		#State_RightMousePushed
		#State_MiddleMousePushed
	EndEnumeration
	#State_Normal = 0
	
	EnumerationBinary 0
		#Object_GlobalPosition
		#Object_LocalPosition
		#Object_DetachChildObjects
		#Object_FreeChildObjects
	EndEnumeration
	
	Prototype.i ObjectDrawingCallback(iObject.i, iWidth.i, iHeight.i, iData.i)
	Prototype.i DrawingCallback(iCanvasGadget.i, iData.i)
	
	Declare.i ReleaseCanvasObjects(iCanvasGadget.i)
	Declare.i InitializeCanvasObjects(iCanvasGadget.i, iWindow.i)
	Declare.i IsCanvasObjects(iCanvasGadget.i)
	Declare.i IsObject(iObject.i)
	Declare.i FreeObject(iObject.i, eFlags.i=#Object_FreeChildObjects)
	Declare.i CreateObject(iCanvasGadget.i, iObject.i, iX.i, iY.i, iWidth.i, iHeight.i, iParentObject.i=#PB_Default, iFrameIndex.i=#Frame_NoFrame)
	Declare.i DuplicateObject(iObject.i, iNewObject.i, iNewCanvasGadget.i=#PB_Ignore, bDuplicateChilds.i=#True)
	Declare.i AddObjectFrame(iObject.i, iFrameIndex.i, iViewBoxX.i=0, iViewBoxY.i=0, iViewBoxWidth.i=#Boundary_ParentSize, iViewBoxHeight.i=#Boundary_ParentSize, iInnerWidth.i=#Boundary_None, iInnerHeight.i=#Boundary_None, iInnerOffsetX.i=0, iInnerOffsetY.i=0)
	Declare.i RemoveObjectFrame(iObject.i, iFrameIndex.i)
	Declare.i MoveObjectFrame(iObject.i, iFrameIndex.i, iNewFrameIndex.i, iNewObject.i=#PB_Ignore)
	Declare.i AddObjectHandle(iObject.i, eType.i, iImage.i=#PB_Default, eAlignment.i=#Alignment_Default, iX.i=0, iY.i=0)
	Declare.i RemoveObjectHandle(iObject.i, eType.i)
	Declare.i ObjectHandleDisplayMode(iObject.i, eMode.i, iCanvasGadget.i=#PB_Ignore)
	Declare.i CreateCustomCursor(iImage.i, iHotSpotX.i=0, iHotSpotY.i=0)
	Declare   FreeCustomCursor(hCursorHandle.i)
	Declare.i ParentObject(iObject.i)
	Declare.i VisibleObjectFrame(iObject.i)
	Declare   AttachObject(iObject.i, iParentObject.i, eMode.i=#Attachment_Position|#Attachment_PreserveGlobalPosition, iFrameIndex.i=#Frame_NoFrame)
	Declare   DetachObject(iObject.i, eMode.i=#Attachment_PreserveGlobalPosition)
	Declare   ShowObjectFrame(iObject.i, iFrameIndex.i)
	Declare.i CountObjectFrames(iObject.i)
	Declare   SelectObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
	Declare   UnselectObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
	Declare   HideObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
	Declare   ShowObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
	Declare   EnableObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
	Declare   DisableObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
	Declare   AlignObjectPosition(iObject.i, iCanvasGadget.i=#PB_Ignore)
	Declare   AlignObjectSize(iObject.i, iCanvasGadget.i=#PB_Ignore)
	Declare.i ObjectState(iObject.i)
	Declare.i ExamineObjects(iCanvasGadget.i, bSelected.i=#False)
	Declare.i NextObject(iCanvasGadget.i)
	Declare.i CanvasObjectsEvent(iCanvasGadget.i=#PB_All)
	Declare.i CanvasObjectsEventGadget()
	Declare.i CanvasObjectsEventType(iCanvasGadget.i)
	Declare.i CanvasObjectsEventData(iCanvasGadget.i, eDataType.i=#EventTypeData_Default)
	Declare.i EventObject(iCanvasGadget.i)
	Declare.i EventHandle(iCanvasGadget.i)
	Declare.i SetCanvasDrawingCallback(iCanvasGadget.i, pPreCallback.ObjectDrawingCallback, pPostCallback.ObjectDrawingCallback, iData.i=0)
	Declare.i SetCanvasCursor(iCanvasGadget.i, eCursor.i, hCursorHandle.i=#Null)
	Declare.i SetObjectBoundaries(iObject.i, iMinX.i=#Boundary_Ignore, iMinY.i=#Boundary_Ignore, iMaxX.i=#Boundary_Ignore, iMaxY.i=#Boundary_Ignore, iMinWidth.i=#Boundary_Ignore, iMinHeight.i=#Boundary_Ignore, iMaxWidth.i=#Boundary_Ignore, iMaxHeight.i=#Boundary_Ignore)
	Declare.i SetObjectCursor(iObject.i, eCursor.i, hCursorHandle.i=#Null)
	Declare.i SetObjectHandleCursor(iObject.i, eType.i, eCursor.i, hCursorHandle.i=#Null)
	Declare.i SetObjectDrawingCallback(iObject.i, pCallback.ObjectDrawingCallback, iData.i=0)
	Declare.i SetObjectData(iObject.i, iData.i)
	Declare.i SetObjectDictionary(iObject.i, sName.s, sValue.s)
	Declare.i SetObjectLayer(iObject.i, iLayer.i, iMode.i=#PB_Absolute)
	Declare.i SetObjectHeight(iObject.i, iHeight.i)
	Declare.i SetObjectWidth(iObject.i, iWidth.i)
	Declare.i SetObjectX(iObject.i, iX.i, eFlag.i=#Object_GlobalPosition)
	Declare.i SetObjectY(iObject.i, iY.i, eFlag.i=#Object_GlobalPosition)
	Declare.i SetObjectMovementStep(iObject.i, iX.i, iY.i)
	Declare.i SetObjectResizeStep(iObject.i, iX.i, iY.i)
	Declare.i SetObjectBoundaryStyle(iObject.i, eType.i, iColor.i=$FF000000, dThickness.d=1.0)
	Declare.i SetObjectSelectionStyle(iObject.i, eType.i=#SelectionStyle_Ignore, iColor.i=#SelectionStyle_Ignore, dThickness.d=#SelectionStyle_Ignore, dDistance.d=#SelectionStyle_Ignore)
	Declare.i SetObjectFrameViewBox(iObject.i, iFrameIndex.i, iX.i=0, iY.i=0, iWidth.i=#Boundary_ParentSize, iHeight.i=#Boundary_ParentSize, bEnabledClipping.i=#True)
	Declare.i SetObjectFrameInnerOffset(iObject.i, iFrameIndex.i, iX.i=0, iY.i=0, iMode.i=#PB_Absolute)
	Declare   SetCursorSelectionStyle(iCanvasGadget.i, eType.i=#SelectionStyle_Ignore, iColor.i=#SelectionStyle_Ignore, dThickness.d=#SelectionStyle_Ignore, iBackgroundColor.i=#SelectionStyle_Ignore)
	Declare.i GetObjectBoundary(iObject.i, eBoundary.i)
	Declare.i GetObjectHandles(iObject.i)
	Declare.i GetCanvasCursor(iCanvasGadget.i)
	Declare.i GetObjectCursor(iObject.i)
	Declare.i GetObjectHandleCursor(iObject.i, eType.i)
	Declare.i GetObjectData(iObject.i)
	Declare.s GetObjectDictionary(iObject.i, sName.s)
	Declare.i GetObjectLayer(iObject.i)
	Declare.i GetObjectHeight(iObject.i)
	Declare.i GetObjectWidth(iObject.i)
	Declare.i GetObjectX(iObject.i, eFlag.i=#Object_GlobalPosition)
	Declare.i GetObjectY(iObject.i, eFlag.i=#Object_GlobalPosition)
	Declare.i GetObjectMovementStepX(iObject.i)
	Declare.i GetObjectMovementStepY(iObject.i)
	Declare.i GetObjectResizeStepX(iObject.i)
	Declare.i GetObjectResizeStepY(iObject.i)
	Declare.i GetObjectSelectionStyle(iObject.i)
	Declare.i GetObjectSelectionStyleColor(iObject.i)
	Declare.d GetObjectSelectionStyleThickness(iObject.i)
	Declare.i GetCursorSelectionStyle(iCanvasGadget.i)
	Declare.i GetCursorSelectionStyleColor(iCanvasGadget.i)
	Declare.i GetCursorSelectionStyleBackgroundColor(iCanvasGadget.i)
	Declare.d GetCursorSelectionStyleThickness(iCanvasGadget.i)
	Declare.d GetCursorSelectionStyleDistance(iCanvasGadget.i)
	Declare.i GetMouseHoveredObject()
	
EndDeclareModule

Module EditorFactory
	
	EnableExplicit
	
	EnumerationBinary Handle
		#Handle_SelectionFrame
	EndEnumeration
	
	#Handles = 18
	#LastHandle = 17
	
	Structure EventDataArray
		i.i[5]
	EndStructure
	
	Structure ObjectStyle
		eType.i
		iColor.i
		dThickness.d
		dDistance.d
		iBackgroundColor.i
	EndStructure
	
	Structure ObjectBoundaries
		iMinX.i
		iMaxX.i
		iMinY.i
		iMaxY.i
		iMinWidth.i
		iMaxWidth.i
		iMinHeight.i
		iMaxHeight.i
	EndStructure
	
	Structure ObjectHandle
		iImage.i
		iImageID.i
		iWidth.i
		iHeight.i
		eAlignment.i
		iX.i
		iY.i
		eCursor.i
		hCursorHandle.i
	EndStructure
	
	Structure ObjectGrid
		iMoveX.i
		iMoveY.i
		iSizeX.i
		iSizeY.i
	EndStructure
	
	Structure FrameBox
		bEnabled.i
		iX.i
		iY.i
		iWidth.i
		iHeight.i
	EndStructure
	
	Structure FrameFake
		*pObjectManager.ObjectManager
		*pParentObject.Object
		ViewBox.FrameBox
		InnerArea.FrameBox
		List		*lpChildObject()
	EndStructure
	
	;- Object structure
	Structure Object
		*pParentFrame.Frame
		iObject.i
		iX.i
		iY.i
		iWidth.i
		iHeight.i
		fPivotX.f
		fPivotY.f
		fRotation.f
		Boundaries.ObjectBoundaries
		Grid.ObjectGrid
		*pSelectionStyle.ObjectStyle
		*pBoundaryStyle.ObjectStyle
		eHandle.i
		Array		aHandle.ObjectHandle(#LastHandle)
		eCursor.i
		hCursorHandle.i
		bSelected.i
		bDisabled.i
		bHidden.i
		bDisjunct.i
		pDrawingCallback.ObjectDrawingCallback
		iCallbackData.i
		iData.i
		eHandleDisplayMode.i
		Map			msAttribute.s()
		List		lFrame.FrameFake()
		*pVisibleFrame.Frame
		*pNoFrame.Frame
		eAttachmentMode.i
		bFreed.i
		List		*lpConnectedObject.Object()
	EndStructure
	
	Structure Frame
		*pObjectManager.ObjectManager
		*pParentObject.Object
		ViewBox.FrameBox
		InnerArea.FrameBox
		List		*lpChildObject.Object()
	EndStructure
	
	Structure ObjectManagerEvent
		iEvent.i
		iEventType.i
		iEventData.i
		iEventDataArray.i[5]
		*pObject.Object
		eHandle.i
	EndStructure
	
	Structure ObjectManager
		iCanvasGadget.i
		iCanvasWidth.i
		iCanvasHeight.i
		iWindow.i
		bRedrawPosted.i
		iMouseX.i
		iMouseY.i
		iAnchorMouseX.i
		iAnchorMouseY.i
		*pHoveredObject.Object
		*pCurrentFrame.Frame
		*pEnteredFrame.Frame
		*pMouseDownObject.Object[4]
		*pMouseClickObject.Object[4]
		iMouseDoubleClickTime.i[4]
		iHoveredHandle.i
		iMouseDownHandle.i[4]
		iMouseClickHandle.i[4]
		iMouseHoldTime.i[4]
		eCurrentCursor.i
		hCurrentCursorHandle.i
		bMovement.i
		iTransformationMode.i
		*pEventObject.Object
		iEventHandle.i
		*pCurrentExaminedElement
		bCurrentExaminedSelected.i
		MainFrame.Frame
		List		lEvent.ObjectManagerEvent()
		List		*lpObject.Object()                ; All object links
		CurrentExaminedEvent.ObjectManagerEvent
		CursorSelectionStyle.ObjectStyle
		pPreDrawingCallback.DrawingCallback
		pPostDrawingCallback.DrawingCallback
		iCallbackData.i
		eCursor.i
		hCursorHandle.i
		iMouseButtonHoldThread.i
		iEventMutex.i
		bQuitThread.i
	EndStructure
	
	Structure EditorFactory
		bInitialized.i
		List		lObject.Object()                ; All objects
		Array		*apObject.Object(0)             ; All objects linked by Index
		List		lObjectManager.ObjectManager()  ; All canvas gadgets
		List		lObjectStyle.ObjectStyle()
		*pCurrentObjectManager.ObjectManager
		iDefaultHandleImage.i
		iDefaultRotationHandleImage.i
		DefaultObject.Object
		bQueryObjects.i
		*pQueryObjectManager.ObjectManager
	EndStructure
	
	
	
	Enumeration #PB_EventType_FirstCustomValue
		#Redraw
	EndEnumeration
	
	
	
	Global EditorFactory.EditorFactory
	
	
	;- Private
	
	Macro _DQ_
		"
	EndMacro
	
	Macro _ObjectManagerID_(pObjectManager, iCanvasGadget, ReturnValue = #False)
		
		If IsGadget(iCanvasGadget) And GetGadgetData(iCanvasGadget)
			pObjectManager = GetGadgetData(iCanvasGadget)
		Else
			Debug "EditorFactory.Error: Invalid or not initialized canvas gadget for "+#PB_Compiler_Procedure+" (" +  _DQ_#iCanvasGadget#_DQ_ + " = "+Str(iCanvasGadget)+")"
			ProcedureReturn ReturnValue
		EndIf
		
	EndMacro	
	
	Macro _ObjectID_(pObject, iNumber, ReturnValue = #False)
		
		PushListPosition(EditorFactory\lObject())
		Repeat
			ForEach EditorFactory\lObject()
				If (EditorFactory\lObject()\iObject = iNumber And EditorFactory\lObject()\bFreed = #False) Or @EditorFactory\lObject() = iNumber
					pObject = @EditorFactory\lObject()
					PopListPosition(EditorFactory\lObject())
					Break 2
				EndIf
			Next
			Debug "EditorFactory.Error: Invalid object number for "+#PB_Compiler_Procedure+" (" +  _DQ_#iNumber#_DQ_ + " = "+Str(iNumber)+")"
			PopListPosition(EditorFactory\lObject())
			ProcedureReturn ReturnValue
		Until #True
		
	EndMacro
	
	Macro _ObjectFrameID_(pFrame, pObject, iFrameIndex, ReturnValue = #False)
		
		PushListPosition(pObject\lFrame())
		If iFrameIndex = #Frame_NoFrame And pObject\pNoFrame
			pFrame = pObject\pNoFrame
		ElseIf iFrameIndex = #Frame_ViewedFrame And pObject\pVisibleFrame
			pFrame = pObject\pVisibleFrame
		ElseIf iFrameIndex >= 0 And iFrameIndex < ListSize(pObject\lFrame()) - 1
			pFrame = SelectElement(pObject\lFrame(), iFrameIndex+1) ; +1, because index 0 is the attachment frame
		Else
			Debug "EditorFactory.Error: Invalid object frame index number for "+#PB_Compiler_Procedure+" (" +  _DQ_#iFrameIndex#_DQ_ + " = "+Str(iFrameIndex)+")"
			PopListPosition(pObject\lFrame())
			ProcedureReturn ReturnValue
		EndIf
		PopListPosition(pObject\lFrame())
		
	EndMacro
	
	Macro _SetObjectBoundaries_SetMacro_( _Field_ )
		
		If _Field_ = #Boundary_Default
			*Object\Boundaries\_Field_ = EditorFactory\DefaultObject\Boundaries\_Field_
		ElseIf _Field_ <> #Boundary_Ignore
			*Object\Boundaries\_Field_ = _Field_
		EndIf
		
	EndMacro
	
	Procedure.i ExObjectID(*ppObject.Integer, iNumber, iCanvasGadget.i=#PB_Ignore, sErrorText.s="")
		
		If iNumber = #Object_Default
			
			If EditorFactory\bQueryObjects
				EditorFactory\bQueryObjects = #False
				*ppObject\i = #Null
				ProcedureReturn #False
			Else
				EditorFactory\bQueryObjects = #True
				*ppObject\i = EditorFactory\DefaultObject
				ProcedureReturn #True
			EndIf
			
		ElseIf iNumber = #Object_All
			
			If iCanvasGadget = #PB_Ignore
				If EditorFactory\bQueryObjects = #False
					ResetList(EditorFactory\lObject())
					EditorFactory\bQueryObjects = #True
				EndIf
				If EditorFactory\bQueryObjects
					Repeat
						If NextElement(EditorFactory\lObject())
							If EditorFactory\lObject()\bFreed = #True
								Continue
							Else
								*ppObject\i = EditorFactory\lObject()
								ProcedureReturn #True
							EndIf
						Else
							EditorFactory\bQueryObjects = #False
							*ppObject\i = #Null
							ProcedureReturn #False
						EndIf
					ForEver
				EndIf
			Else
				If EditorFactory\bQueryObjects = #False
					Repeat
						ForEach EditorFactory\lObjectManager()
							If EditorFactory\lObjectManager()\iCanvasGadget = iCanvasGadget
								EditorFactory\pQueryObjectManager = EditorFactory\lObjectManager()
								ResetList(EditorFactory\pQueryObjectManager\lpObject())
								EditorFactory\bQueryObjects = #True
								Break 2
							EndIf
						Next
						Debug "EditorFactory.Error: Invalid or not initialized canvas gadget for "+StringField(sErrorText, 1, #TAB$)+" ("+StringField(sErrorText, 3, #TAB$)+" = "+Str(iCanvasGadget)+")"
						ProcedureReturn #False
					Until #True
				EndIf
				If EditorFactory\bQueryObjects And EditorFactory\pQueryObjectManager
					Repeat
						If NextElement(EditorFactory\pQueryObjectManager\lpObject())
							If EditorFactory\pQueryObjectManager\lpObject()\bFreed = #True
								Continue
							Else
								*ppObject\i = EditorFactory\pQueryObjectManager\lpObject()
								ProcedureReturn #True
							EndIf
						Else
							EditorFactory\bQueryObjects = #False
							*ppObject\i = #Null
							ProcedureReturn #False
						EndIf
					ForEver
				EndIf
			EndIf
			
		ElseIf iNumber = #Object_Selected
			
			If iCanvasGadget = #PB_Ignore
				If EditorFactory\bQueryObjects = #False
					ResetList(EditorFactory\lObject())
					EditorFactory\bQueryObjects = #True
				EndIf
				If EditorFactory\bQueryObjects
					Repeat
						If NextElement(EditorFactory\lObject())
							If EditorFactory\lObject()\bFreed = #True Or EditorFactory\lObject()\bSelected = #False
								Continue
							Else
								*ppObject\i = EditorFactory\lObject()
								ProcedureReturn #True
							EndIf
						Else
							EditorFactory\bQueryObjects = #False
							*ppObject\i = #Null
							ProcedureReturn #False
						EndIf
					ForEver
				EndIf
			Else
				If EditorFactory\bQueryObjects = #False
					Repeat
						ForEach EditorFactory\lObjectManager()
							If EditorFactory\lObjectManager()\iCanvasGadget = iCanvasGadget
								EditorFactory\pQueryObjectManager = EditorFactory\lObjectManager()
								ResetList(EditorFactory\pQueryObjectManager\lpObject())
								EditorFactory\bQueryObjects = #True
								Break
							EndIf
						Next
						Debug "EditorFactory.Error: Invalid or not initialized canvas gadget for "+StringField(sErrorText, 1, #TAB$)+" ("+StringField(sErrorText, 3, #TAB$)+" = "+Str(iCanvasGadget)+")"
						ProcedureReturn #False
					Until #True
				EndIf
				If EditorFactory\bQueryObjects And EditorFactory\pQueryObjectManager
					Repeat
						If NextElement(EditorFactory\pQueryObjectManager\lpObject())
							If EditorFactory\pQueryObjectManager\lpObject()\bFreed = #True Or EditorFactory\pQueryObjectManager\lpObject()\bSelected = #False
								Continue
							Else
								*ppObject\i = EditorFactory\pQueryObjectManager\lpObject()
								ProcedureReturn #True
							EndIf
						Else
							EditorFactory\bQueryObjects = #False
							*ppObject\i = #Null
							ProcedureReturn #False
						EndIf
					ForEver
				EndIf
			EndIf
			
		Else
			
			If EditorFactory\bQueryObjects
				EditorFactory\bQueryObjects = #False
				*ppObject\i = #Null
				ProcedureReturn #False
			Else
				Repeat
					PushListPosition(EditorFactory\lObject())
					ForEach EditorFactory\lObject()
						If (EditorFactory\lObject()\iObject = iNumber And EditorFactory\lObject()\bFreed = #False) Or @EditorFactory\lObject() = iNumber
							*ppObject\i = @EditorFactory\lObject()
							PopListPosition(EditorFactory\lObject())
							EditorFactory\bQueryObjects = #True
							ProcedureReturn #True
						EndIf
					Next
					Debug "EditorFactory.Error: Invalid object number for "+StringField(sErrorText, 1, #TAB$)+" ("+StringField(sErrorText, 2, #TAB$)+" = "+Str(iNumber)+")"
					PopListPosition(EditorFactory\lObject())
					*ppObject\i = #Null
					ProcedureReturn #False
				Until #True
			EndIf
			
		EndIf
		
	EndProcedure
	
	Macro _ExObjectID_(ppObject, iNumber, iCanvasGadget=#PB_Ignore)
		ExObjectID(ppObject, iNumber, iCanvasGadget, #PB_Compiler_Procedure + #TAB$ + _DQ_#iNumber#_DQ_ + #TAB$ + _DQ_#iCanvasGadget#_DQ_ )
	EndMacro
	
	Procedure.i IntFloor(iValue.i, iSteps.i)
		
		Protected iModulo = iValue % iSteps
		
		If (iSteps > 0 And iModulo < 0) Or (iSteps < 0 And iModulo > 0)
			ProcedureReturn iValue - iModulo - iSteps
		Else
			ProcedureReturn iValue - iModulo
		EndIf
		
	EndProcedure
	
	Procedure.i IntCeil(iValue.i, iSteps.i)
		
		Protected iModulo = iValue % (-iSteps)
		
		If (iSteps < 0 And iModulo < 0) Or (iSteps > 0 And iModulo > 0)
			ProcedureReturn iValue - iModulo + iSteps
		Else
			ProcedureReturn iValue - iModulo
		EndIf
		
	EndProcedure
	
	Procedure.i IntRound(iValue.i, iSteps.i)
		
		Protected iModulo = iValue % iSteps
		
		If (iModulo > 0 And iModulo >= iSteps>>1)
			ProcedureReturn iValue - iModulo + iSteps
		ElseIf (iModulo < 0 And -iModulo > iSteps>>1)
			ProcedureReturn iValue - iModulo - iSteps
		Else
			ProcedureReturn iValue - iModulo
		EndIf
		
	EndProcedure
	
	Procedure.i GlobalX(*Object.Object, iX.i)
		
		While *Object\pParentFrame\pParentObject
			If *Object\eAttachmentMode & #Attachment_X
				iX + *Object\pParentFrame\pParentObject\iX + *Object\pParentFrame\ViewBox\iX - *Object\pParentFrame\InnerArea\iX
				*Object = *Object\pParentFrame\pParentObject
			Else
				Break
			EndIf
		Wend
		
		ProcedureReturn iX
		
	EndProcedure
	
	Procedure.i GlobalY(*Object.Object, iY.i)
		
		While *Object\pParentFrame\pParentObject
			If *Object\eAttachmentMode & #Attachment_Y
				iY + *Object\pParentFrame\pParentObject\iY + *Object\pParentFrame\ViewBox\iY - *Object\pParentFrame\InnerArea\iY
				*Object = *Object\pParentFrame\pParentObject
			Else
				Break
			EndIf
		Wend
		
		ProcedureReturn iY
		
	EndProcedure
	
	Procedure.i DecodeParentSize(iEncodedValue.i, iParentValue.i)
		
		If iEncodedValue & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
			ProcedureReturn iParentValue + (iEncodedValue - #Boundary_ParentSize)
		Else
			ProcedureReturn iEncodedValue
		EndIf
		
	EndProcedure
	
	Procedure.i AdjustX(*Object.Object, iX.i, iWidth.i=0)
		
		Protected iMinX.i, iMaxX.i
		
		With *Object\Boundaries
			
			If \iMinX & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask And *Object\pParentFrame
				If *Object\pParentFrame\pParentObject And *Object\eAttachmentMode & #Attachment_X
					iMinX = *Object\pParentFrame\pParentObject\iWidth + (\iMinX - #Boundary_ParentSize)
				Else
					iMinX = *Object\pParentFrame\pObjectManager\iCanvasWidth + (\iMinX - #Boundary_ParentSize)
				EndIf
			ElseIf \iMinX <> #Boundary_None
				iMinX = \iMinX
			EndIf
			If *Object\Grid\iMoveX > 0
				iMinX = IntCeil(iMinX, *Object\Grid\iMoveX)
			EndIf
			If \iMinX <> #Boundary_None And iX < iMinX
				iX = iMinX
			EndIf
			If *Object\pParentFrame And *Object\pParentFrame\InnerArea\iWidth <> #Boundary_None And iX < 0
				iX = 0
			EndIf
			
			If \iMaxX & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask And *Object\pParentFrame
				If *Object\pParentFrame\pParentObject And *Object\eAttachmentMode & #Attachment_X
					iMaxX = *Object\pParentFrame\pParentObject\iWidth + (\iMaxX - #Boundary_ParentSize) - iWidth
				Else
					iMaxX = *Object\pParentFrame\pObjectManager\iCanvasWidth + (\iMaxX - #Boundary_ParentSize) - iWidth
				EndIf
			ElseIf \iMaxX <> #Boundary_None
				iMaxX = \iMaxX - iWidth
			EndIf
			If *Object\Grid\iMoveX > 0
				iMaxX = IntFloor(iMaxX, *Object\Grid\iMoveX)
			EndIf
			If \iMaxX <> #Boundary_None And iX > iMaxX
				iX = iMaxX
			EndIf
			If *Object\pParentFrame And *Object\pParentFrame\InnerArea\iWidth <> #Boundary_None And
			   *Object\pParentFrame\pParentObject And iX > DecodeParentSize(*Object\pParentFrame\InnerArea\iWidth, *Object\pParentFrame\pParentObject\iWidth) - iWidth
				iX = DecodeParentSize(*Object\pParentFrame\InnerArea\iWidth, *Object\pParentFrame\pParentObject\iWidth) - iWidth
			EndIf
			
			If *Object\Grid\iMoveX > 0
				iX = IntRound(iX, *Object\Grid\iMoveX)
			EndIf
			
		EndWith
		
		ProcedureReturn iX
		
	EndProcedure
	
	Procedure.i AdjustY(*Object.Object, iY.i, iHeight.i=0)
		
		Protected iMinY.i, iMaxY.i
		
		With *Object\Boundaries
			
			If \iMinY & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask And *Object\pParentFrame
				If *Object\pParentFrame\pParentObject And *Object\eAttachmentMode & #Attachment_Y
					iMinY = *Object\pParentFrame\pParentObject\iHeight + (\iMinY - #Boundary_ParentSize)
				Else
					iMinY = *Object\pParentFrame\pObjectManager\iCanvasHeight + (\iMinY - #Boundary_ParentSize)
				EndIf
			ElseIf \iMinY <> #Boundary_None
				iMinY = \iMinY
			EndIf
			If *Object\Grid\iMoveY > 0
				iMinY = IntCeil(iMinY, *Object\Grid\iMoveY)
			EndIf
			If \iMinY <> #Boundary_None And iY < iMinY
				iY = iMinY
			EndIf
			If *Object\pParentFrame And *Object\pParentFrame\InnerArea\iHeight <> #Boundary_None And iY < 0
				iY = 0
			EndIf
			
			If \iMaxY & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask And *Object\pParentFrame
				If *Object\pParentFrame\pParentObject And *Object\eAttachmentMode & #Attachment_Y
					iMaxY = *Object\pParentFrame\pParentObject\iHeight + (\iMaxY - #Boundary_ParentSize) - iHeight
				Else
					iMaxY = *Object\pParentFrame\pObjectManager\iCanvasHeight + (\iMaxY - #Boundary_ParentSize) - iHeight
				EndIf
			ElseIf \iMaxY <> #Boundary_None
				iMaxY = \iMaxY - iHeight
			EndIf
			If *Object\Grid\iMoveY > 0
				iMaxY = IntFloor(iMaxY, *Object\Grid\iMoveY)
			EndIf
			If \iMaxY <> #Boundary_None And iY > iMaxY
				iY = iMaxY
			EndIf
			If *Object\pParentFrame And *Object\pParentFrame\InnerArea\iHeight <> #Boundary_None And
			   *Object\pParentFrame\pParentObject And iY > DecodeParentSize(*Object\pParentFrame\InnerArea\iHeight, *Object\pParentFrame\pParentObject\iHeight) - iHeight
				iY = DecodeParentSize(*Object\pParentFrame\InnerArea\iHeight, *Object\pParentFrame\pParentObject\iHeight) - iHeight
			EndIf
			
			If *Object\Grid\iMoveY > 0
				iY = IntRound(iY, *Object\Grid\iMoveY)
			EndIf
			
		EndWith
		
		ProcedureReturn iY
		
	EndProcedure
	
	Procedure.i AdjustWidth(*Object.Object, iWidth.i)
		
		Protected iMinWidth.i = 0, iMaxWidth.i = #Boundary_None, iMinX.i, iMaxX.i
		Protected *ChildObject.Object
		
		With *Object\Boundaries
			
			If \iMinWidth & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask And *Object\pParentFrame
				If *Object\pParentFrame\pParentObject And *Object\eAttachmentMode & #Attachment_X
					iMinWidth = *Object\pParentFrame\pParentObject\iWidth + (\iMinWidth - #Boundary_ParentSize)
				Else
					iMinWidth = *Object\pParentFrame\pObjectManager\iCanvasWidth + (\iMinWidth - #Boundary_ParentSize)
				EndIf
			ElseIf \iMinWidth <> #Boundary_None
				iMinWidth = \iMinWidth
			EndIf
			If \iMaxWidth & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask And *Object\pParentFrame
				If *Object\pParentFrame\pParentObject And *Object\eAttachmentMode & #Attachment_X
					iMaxWidth = *Object\pParentFrame\pParentObject\iWidth + (\iMaxWidth - #Boundary_ParentSize)
				Else
					iMaxWidth = *Object\pParentFrame\pObjectManager\iCanvasWidth + (\iMaxWidth - #Boundary_ParentSize)
				EndIf
			ElseIf \iMaxWidth <> #Boundary_None
				iMaxWidth = \iMaxWidth
			EndIf
			If \iMinX <> #Boundary_None And \iMaxX <> #Boundary_None
				iMinX = AdjustX(*Object, -#Boundary_None)
				iMaxX = AdjustX(*Object, #Boundary_None)
				If iMaxX-iMinX < iMaxWidth
					iMaxWidth = iMaxX-iMinX
				EndIf
			EndIf
			If *Object\pParentFrame And *Object\pParentFrame\InnerArea\iWidth <> #Boundary_None And
			   *Object\pParentFrame\pParentObject And iMaxWidth > DecodeParentSize(*Object\pParentFrame\InnerArea\iWidth, *Object\pParentFrame\pParentObject\iWidth)
				iMaxWidth = DecodeParentSize(*Object\pParentFrame\InnerArea\iWidth, *Object\pParentFrame\pParentObject\iWidth)
			EndIf
			
			ForEach *Object\lFrame()
				ForEach *Object\lFrame()\lpChildObject()
					*ChildObject = *Object\lFrame()\lpChildObject()
					If *ChildObject\eAttachmentMode & #Attachment_X And *ChildObject\iX + *ChildObject\iWidth > iMinWidth And *ChildObject\Boundaries\iMaxX & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						iMinWidth = *ChildObject\iX + *ChildObject\iWidth
					EndIf
				Next
			Next
			
			If *Object\Grid\iSizeX > 1
				iMinWidth = IntCeil(iMinWidth, *Object\Grid\iSizeX)
				iMaxWidth = IntFloor(iMaxWidth, *Object\Grid\iSizeX)
			EndIf
			
			If iWidth > iMaxWidth
				iWidth = iMaxWidth
			ElseIf iWidth < iMinWidth
				iWidth = iMinWidth
			EndIf
			
			If *Object\Grid\iSizeX > 1
				iWidth = IntRound(iWidth, *Object\Grid\iSizeX)
			EndIf
			
		EndWith
		
		ProcedureReturn iWidth
		
	EndProcedure
	
	Procedure.i AdjustHeight(*Object.Object, iHeight.i)
		
		Protected iMinHeight.i = 0, iMaxHeight.i = #Boundary_None, iMinY.i, iMaxY.i
		Protected *ChildObject.Object
		
		With *Object\Boundaries
			
			If \iMinHeight & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask And *Object\pParentFrame
				If *Object\pParentFrame\pParentObject And *Object\eAttachmentMode & #Attachment_Y
					iMinHeight = *Object\pParentFrame\pParentObject\iHeight + (\iMinHeight - #Boundary_ParentSize)
				Else
					iMinHeight = *Object\pParentFrame\pObjectManager\iCanvasHeight + (\iMinHeight - #Boundary_ParentSize)
				EndIf
			ElseIf \iMinHeight <> #Boundary_None
				iMinHeight = \iMinHeight
			EndIf
			If \iMaxHeight & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask And *Object\pParentFrame
				If *Object\pParentFrame\pParentObject And *Object\eAttachmentMode & #Attachment_Y
					iMaxHeight = *Object\pParentFrame\pParentObject\iHeight + (\iMaxHeight - #Boundary_ParentSize)
				Else
					iMaxHeight = *Object\pParentFrame\pObjectManager\iCanvasHeight + (\iMaxHeight - #Boundary_ParentSize)
				EndIf
			ElseIf \iMaxHeight <> #Boundary_None
				iMaxHeight = \iMaxHeight
			EndIf
			If \iMinY <> #Boundary_None And \iMaxY <> #Boundary_None
				iMinY = AdjustY(*Object, -#Boundary_None)
				iMaxY = AdjustY(*Object, #Boundary_None)
				If iMaxY-iMinY < iMaxHeight
					iMaxHeight = iMaxY-iMinY
				EndIf
			EndIf
			If *Object\pParentFrame And *Object\pParentFrame\InnerArea\iHeight <> #Boundary_None And
			   *Object\pParentFrame\pParentObject And iMaxHeight > DecodeParentSize(*Object\pParentFrame\InnerArea\iHeight, *Object\pParentFrame\pParentObject\iHeight)
				iMaxHeight = DecodeParentSize(*Object\pParentFrame\InnerArea\iHeight, *Object\pParentFrame\pParentObject\iHeight)
			EndIf
			
			ForEach *Object\lFrame()
				ForEach *Object\lFrame()\lpChildObject()
					*ChildObject = *Object\lFrame()\lpChildObject()
					If *ChildObject\eAttachmentMode & #Attachment_Y And *ChildObject\iY + *ChildObject\iHeight > iMinHeight And *ChildObject\Boundaries\iMaxY & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						iMinHeight = *ChildObject\iY + *ChildObject\iHeight
					EndIf
				Next
			Next
			
			If *Object\Grid\iSizeY > 1
				iMinHeight = IntCeil(iMinHeight, *Object\Grid\iSizeY)
				iMaxHeight = IntFloor(iMaxHeight, *Object\Grid\iSizeY)
			EndIf
			
			If iHeight > iMaxHeight
				iHeight = iMaxHeight
			ElseIf iHeight < iMinHeight
				iHeight = iMinHeight
			EndIf
			
			If *Object\Grid\iSizeY > 1
				iHeight = IntRound(iHeight, *Object\Grid\iSizeY)
			EndIf
			
		EndWith
		
		ProcedureReturn iHeight
		
	EndProcedure
	
	Procedure   PostRedrawEvent(*ObjectManager.ObjectManager)
		
		If *ObjectManager\bRedrawPosted = #False
			*ObjectManager\bRedrawPosted = #True
			PostEvent(#PB_Event_Gadget, *ObjectManager\iWindow, *ObjectManager\iCanvasGadget, #PB_EventType_FirstCustomValue)
		EndIf
		
	EndProcedure
	
	Procedure   HandleGlobalPosition(*Object.Object, *Handle.ObjectHandle, *X.Integer, *Y.Integer)
		
		If *Handle\eAlignment & #Alignment_Left
			*X\i = GlobalX(*Object, *Object\iX) + *Handle\iX
		ElseIf *Handle\eAlignment & #Alignment_Right
			*X\i = GlobalX(*Object, *Object\iX) + *Object\iWidth + *Handle\iX
		Else
			*X\i = GlobalX(*Object, *Object\iX) + *Object\iWidth/2 + *Handle\iX
		EndIf
		
		If *Handle\eAlignment & #Alignment_Top
			*Y\i = GlobalY(*Object, *Object\iY) + *Handle\iY
		ElseIf *Handle\eAlignment & #Alignment_Bottom
			*Y\i = GlobalY(*Object, *Object\iY) + *Object\iHeight + *Handle\iY
		Else
			*Y\i = GlobalY(*Object, *Object\iY) + *Object\iHeight/2 + *Handle\iY
		EndIf
		
	EndProcedure
	
	Procedure   HandlePosition(*Object.Object, *Handle.ObjectHandle, *X.Integer, *Y.Integer)
		
		If *Handle\eAlignment & #Alignment_Left
			*X\i = *Object\iX + *Handle\iX
		ElseIf *Handle\eAlignment & #Alignment_Right
			*X\i = *Object\iX + *Object\iWidth + *Handle\iX
		Else
			*X\i = *Object\iX + 0.5 * *Object\iWidth + *Handle\iX
		EndIf
		
		If *Handle\eAlignment & #Alignment_Top
			*Y\i = *Object\iY + *Handle\iY
		ElseIf *Handle\eAlignment & #Alignment_Bottom
			*Y\i = *Object\iY + *Object\iHeight + *Handle\iY
		Else
			*Y\i = *Object\iY + 0.5 * *Object\iHeight + *Handle\iY
		EndIf
		
	EndProcedure
	
	Procedure   PostObjectEvent(*ObjectManager.ObjectManager, iEventType.i, *Object.Object, *Data.EventDataArray=#Null)
		
		Protected iFrameIndex.i
		
		If iEventType = #EventType_Resized
			For iFrameIndex = CountObjectFrames(*Object)-1 To 0 Step -1
				SetObjectFrameInnerOffset(*Object, iFrameIndex, 0, 0, #PB_Relative)
			Next
		EndIf
		LockMutex(*ObjectManager\iEventMutex)
		LastElement(*ObjectManager\lEvent())
		AddElement(*ObjectManager\lEvent())
		*ObjectManager\lEvent()\iEvent     = #Event_Object
		*ObjectManager\lEvent()\iEventType = iEventType
		If iEventType = #EventType_Selection
			CopyMemory(*Data, @*ObjectManager\lEvent()\iEventDataArray[0], SizeOf(EventDataArray))
		Else
			*ObjectManager\lEvent()\iEventData = *Data
		EndIf
		*ObjectManager\lEvent()\pObject    = *Object
		UnlockMutex(*ObjectManager\iEventMutex)
		
	EndProcedure
	
	Procedure   PostHandleEvent(*ObjectManager.ObjectManager, iEventType.i, *Object.Object, eHandle.i, *Data.EventDataArray=#Null)
		
		LockMutex(*ObjectManager\iEventMutex)
		LastElement(*ObjectManager\lEvent())
		AddElement(*ObjectManager\lEvent())
		*ObjectManager\lEvent()\iEvent     = #Event_Handle
		*ObjectManager\lEvent()\iEventType = iEventType
		*ObjectManager\lEvent()\iEventData = *Data
		*ObjectManager\lEvent()\pObject    = *Object
		*ObjectManager\lEvent()\eHandle    = eHandle
		UnlockMutex(*ObjectManager\iEventMutex)
		
	EndProcedure
	
	Procedure.i ObjectEvents_Frame(*Frame.Frame, iParentX.i=0, iParentY.i=0)
		
		Protected iX.i, iY.i, iHandleX.i, iHandleY.i, iIndex.i
		Protected *Object.Object, Hovered.i,  BorderSize.i = 8
		
		With *Frame\pObjectManager
			If LastElement(*Frame\lpChildObject())
				Repeat
					*Object = *Frame\lpChildObject()
					
					If *Object\bDisabled Or *Object\bHidden
						Continue
					EndIf
					
					iX = *Object\iX + Bool(*Object\eAttachmentMode & #Attachment_X) * iParentX
					iY = *Object\iY + Bool(*Object\eAttachmentMode & #Attachment_Y) * iParentY
					
					If *Object\pNoFrame
						If ObjectEvents_Frame(*Object\pNoFrame, iX, iY)
							ProcedureReturn #True
						EndIf
					EndIf
					If *Object\pVisibleFrame
						If *Object\pVisibleFrame\ViewBox\bEnabled 
							If \iMouseX >= iX+*Object\pVisibleFrame\ViewBox\iX And \iMouseX < iX+*Object\pVisibleFrame\ViewBox\iX+DecodeParentSize(*Object\pVisibleFrame\ViewBox\iWidth, *Object\iWidth) And
							   \iMouseY >= iY+*Object\pVisibleFrame\ViewBox\iY And \iMouseY < iY+*Object\pVisibleFrame\ViewBox\iY+DecodeParentSize(*Object\pVisibleFrame\ViewBox\iHeight, *Object\iHeight)
								If ObjectEvents_Frame(*Object\pVisibleFrame, iX+*Object\pVisibleFrame\ViewBox\iX-*Object\pVisibleFrame\InnerArea\iX, iY+*Object\pVisibleFrame\ViewBox\iY-*Object\pVisibleFrame\InnerArea\iY)
									ProcedureReturn #True
								EndIf
							EndIf
						Else
							If ObjectEvents_Frame(*Object\pVisibleFrame, iX+*Object\pVisibleFrame\ViewBox\iX-*Object\pVisibleFrame\InnerArea\iX, iY+*Object\pVisibleFrame\ViewBox\iY-*Object\pVisibleFrame\InnerArea\iY)
								ProcedureReturn #True
							EndIf
						EndIf
					EndIf
					
					; Handles
					For iIndex = 0 To #LastHandle
						If iIndex = 0 And *Object\aHandle(iIndex)\iImage = EditorFactory\iDefaultHandleImage
							Continue
						EndIf
						If (*Object\eHandleDisplayMode = #Handle_ShowAlways Or *Object\eHandleDisplayMode & #Handle_ShowIfHovered Or
						    (*Object\eHandleDisplayMode & #Handle_ShowIfSelected And *Object\bSelected) )
							If *Object\eHandle & (1<<iIndex)
								HandleGlobalPosition(*Object, *Object\aHandle(iIndex), @iHandleX, @iHandleY)
								If \iMouseX >= iHandleX-*Object\aHandle(iIndex)\iWidth/2 And \iMouseX < iHandleX+*Object\aHandle(iIndex)\iWidth/2 And 
									 \iMouseY >= iHandleY-*Object\aHandle(iIndex)\iHeight/2 And \iMouseY < iHandleY+*Object\aHandle(iIndex)\iHeight/2
									If \pHoveredObject And \pHoveredObject <> *Object
										PostObjectEvent(*Frame\pObjectManager, #EventType_MouseLeave, \pHoveredObject)
									EndIf
									If \pHoveredObject <> *Object
										\pHoveredObject = *Object
										PostObjectEvent(*Frame\pObjectManager, #EventType_MouseEnter, \pHoveredObject)
									EndIf
									If \iHoveredHandle And \iHoveredHandle <> (1<<iIndex)
										PostHandleEvent(*Frame\pObjectManager, #EventType_MouseLeave, \pHoveredObject, \iHoveredHandle)
									EndIf
									If \iHoveredHandle <> (1<<iIndex)
										\iHoveredHandle = (1<<iIndex)
										PostHandleEvent(*Frame\pObjectManager, #EventType_MouseEnter, \pHoveredObject, (1<<iIndex))
									EndIf
									If *Object\aHandle(iIndex)\eCursor = #PB_Cursor_Custom And (\eCurrentCursor <> *Object\aHandle(iIndex)\eCursor Or \hCurrentCursorHandle <> *Object\aHandle(iIndex)\hCursorHandle)
										SetGadgetAttribute(\iCanvasGadget, #PB_Canvas_CustomCursor, *Object\aHandle(iIndex)\hCursorHandle)
										\eCurrentCursor = *Object\aHandle(iIndex)\eCursor
										\hCurrentCursorHandle = *Object\aHandle(iIndex)\hCursorHandle
									ElseIf \eCurrentCursor <> *Object\aHandle(iIndex)\eCursor
										SetGadgetAttribute(\iCanvasGadget, #PB_Canvas_Cursor, *Object\aHandle(iIndex)\eCursor)
										\eCurrentCursor = *Object\aHandle(iIndex)\eCursor
										\hCurrentCursorHandle = #Null
									EndIf
									ProcedureReturn #True
								EndIf
							EndIf
						EndIf
					Next
					
					; Object
					If \iMouseX >= iX And \iMouseX < iX+*Object\iWidth And \iMouseY >= iY And \iMouseY < iY+*Object\iHeight
						If \pEnteredFrame = \MainFrame And *Object\pVisibleFrame
							\pEnteredFrame = *Object\pVisibleFrame
						EndIf
						If *Object\pVisibleFrame And \CursorSelectionStyle\eType <> #SelectionStyle_None
							If Not (\iMouseX >= iX + BorderSize And \iMouseX < iX+*Object\iWidth - BorderSize And \iMouseY >= iY + BorderSize And \iMouseY < iY+*Object\iHeight - BorderSize)
								Hovered = #True
							Else
								Hovered = #False
							EndIf
						Else
							Hovered = #True
						EndIf
					Else
						Hovered = #False
					EndIf
					If Hovered
						If \pHoveredObject And \pHoveredObject <> *Object
							PostObjectEvent(*Frame\pObjectManager, #EventType_MouseLeave, \pHoveredObject)
						EndIf
						If \pHoveredObject <> *Object
							\pHoveredObject = *Object
							PostObjectEvent(*Frame\pObjectManager, #EventType_MouseEnter, \pHoveredObject)
						EndIf
						If *Object\eHandle & #Handle_Position And *Object\aHandle(0)\iImage = EditorFactory\iDefaultHandleImage
							If \iHoveredHandle And \iHoveredHandle <> #Handle_Position
								PostHandleEvent(*Frame\pObjectManager, #EventType_MouseLeave, \pHoveredObject, \iHoveredHandle)
							EndIf
							If \iHoveredHandle <> #Handle_Position
								\iHoveredHandle = #Handle_Position
								PostHandleEvent(*Frame\pObjectManager, #EventType_MouseEnter, \pHoveredObject, #Handle_Position)
							EndIf
						Else
							If \iHoveredHandle And \pHoveredObject = *Object
								PostHandleEvent(*Frame\pObjectManager, #EventType_MouseLeave, \pHoveredObject, \iHoveredHandle)
								\iHoveredHandle = #Handle_None
							EndIf
						EndIf
						If *Object\eCursor = #PB_Cursor_Custom And (\eCurrentCursor <> *Object\eCursor Or \hCurrentCursorHandle <> *Object\hCursorHandle)
							SetGadgetAttribute(\iCanvasGadget, #PB_Canvas_CustomCursor, *Object\hCursorHandle)
							\eCurrentCursor = *Object\eCursor
							\hCurrentCursorHandle = *Object\hCursorHandle
						ElseIf \eCurrentCursor <> *Object\eCursor
							SetGadgetAttribute(\iCanvasGadget, #PB_Canvas_Cursor, *Object\eCursor)
							\eCurrentCursor = *Object\eCursor
							\hCurrentCursorHandle = #Null
						EndIf
						ProcedureReturn #True
					EndIf
					If \iHoveredHandle And \pHoveredObject = *Object
						PostHandleEvent(*Frame\pObjectManager, #EventType_MouseLeave, \pHoveredObject, \iHoveredHandle)
						\iHoveredHandle = #Handle_None
					EndIf
					
				Until PreviousElement(*Frame\lpChildObject()) = #False
			EndIf
		EndWith
		
		ProcedureReturn #False
		
	EndProcedure
	
	Procedure.i ObjectEvents(*ObjectManager.ObjectManager)
		
		Protected iResult.i = #False
		Protected *CurrentHoveredObject.Object
		Protected iX.i, iY.i, iIndex.i
		
		With *ObjectManager
			*CurrentHoveredObject = \pHoveredObject
			Repeat
				If \iTransformationMode
					Break
				EndIf
				\pEnteredFrame = \MainFrame
				If ObjectEvents_Frame(\MainFrame)
					Break
				EndIf
				If \pHoveredObject
					PostObjectEvent(*ObjectManager, #EventType_MouseLeave, \pHoveredObject)
					\pHoveredObject = #Null
				EndIf
				If \eCursor = #PB_Cursor_Custom And (\eCurrentCursor <> \eCursor Or \hCurrentCursorHandle <> \hCursorHandle)
					SetGadgetAttribute(\iCanvasGadget, #PB_Canvas_CustomCursor, \hCursorHandle)
					\eCurrentCursor = \eCursor
					\hCurrentCursorHandle = \hCursorHandle
				ElseIf \eCurrentCursor <> \eCursor
					SetGadgetAttribute(\iCanvasGadget, #PB_Canvas_Cursor, \eCursor)
					\eCurrentCursor = \eCursor
					\hCurrentCursorHandle = #Null
				EndIf
			Until #True
		EndWith
		
		If *ObjectManager\pHoveredObject <> *CurrentHoveredObject
			ProcedureReturn #True
		Else
			ProcedureReturn #False
		EndIf
		
	EndProcedure
	
	Procedure   ObjectDrawing_Frame(*Frame.Frame, iParentX.i=0, iParentY.i=0)
		
		Protected iX.i, iY.i, iWidth.i, iHeight.i
		Protected iIndex.i, *Object.Object, *ObjectManager.ObjectManager
		Protected iHandleX.i, iHandleY.i
		
		*ObjectManager = *Frame\pObjectManager
		ForEach *Frame\lpChildObject()
			*Object = *Frame\lpChildObject()
			With *Object
				If \bHidden
					Continue
				EndIf
				iX      = \iX
				iY      = \iY
				iWidth  = \iWidth
				iHeight = \iHeight
				;RotateCoordinates(iX, iY, Degree(\fRotation))
				If \bSelected And *ObjectManager\iTransformationMode & \eHandle
					Select *ObjectManager\iTransformationMode
						Case #Handle_Position
							If *ObjectManager\bMovement
								iX = AdjustX(*Object, \iX+*ObjectManager\iMouseX-*ObjectManager\iAnchorMouseX, \iWidth)
								iY = AdjustY(*Object, \iY+*ObjectManager\iMouseY-*ObjectManager\iAnchorMouseY, \iHeight)
							EndIf
						Case #Handle_BottomLeft
							iWidth  = AdjustWidth(*Object, \iWidth-*ObjectManager\iMouseX+*ObjectManager\iAnchorMouseX)
							iX      = AdjustX(*Object, \iX-iWidth+\iWidth, iWidth)
							iHeight = AdjustHeight(*Object, \iHeight+*ObjectManager\iMouseY-*ObjectManager\iAnchorMouseY)
							iY      = AdjustY(*Object, \iY, iHeight)
						Case #Handle_Bottom
							iHeight = AdjustHeight(*Object, \iHeight+*ObjectManager\iMouseY-*ObjectManager\iAnchorMouseY)
							iY      = AdjustY(*Object, \iY, iHeight)
						Case #Handle_BottomRight
							iWidth  = AdjustWidth(*Object, \iWidth+*ObjectManager\iMouseX-*ObjectManager\iAnchorMouseX)
							iX      = AdjustX(*Object, \iX, iWidth)
							iHeight = AdjustHeight(*Object, \iHeight+*ObjectManager\iMouseY-*ObjectManager\iAnchorMouseY)
							iY      = AdjustY(*Object, \iY, iHeight)
						Case #Handle_Left
							iWidth  = AdjustWidth(*Object, \iWidth-*ObjectManager\iMouseX+*ObjectManager\iAnchorMouseX)
							iX      = AdjustX(*Object, \iX-iWidth+\iWidth, iWidth)
						Case #Handle_Right
							iWidth  = AdjustWidth(*Object, \iWidth+*ObjectManager\iMouseX-*ObjectManager\iAnchorMouseX)
							iX      = AdjustX(*Object, \iX, iWidth)
						Case #Handle_TopLeft
							iWidth  = AdjustWidth(*Object, \iWidth-*ObjectManager\iMouseX+*ObjectManager\iAnchorMouseX)
							iX      = AdjustX(*Object, \iX-iWidth+\iWidth, iWidth)
							iHeight = AdjustHeight(*Object, \iHeight-*ObjectManager\iMouseY+*ObjectManager\iAnchorMouseY)
							iY      = AdjustY(*Object, \iY-iHeight+\iHeight, iHeight)
						Case #Handle_Top
							iHeight = AdjustHeight(*Object, \iHeight-*ObjectManager\iMouseY+*ObjectManager\iAnchorMouseY)
							iY      = AdjustY(*Object, \iY-iHeight+\iHeight, iHeight)
						Case #Handle_TopRight
							iWidth  = AdjustWidth(*Object, \iWidth+*ObjectManager\iMouseX-*ObjectManager\iAnchorMouseX)
							iX      = AdjustX(*Object, \iX, iWidth)
							iHeight = AdjustHeight(*Object, \iHeight-*ObjectManager\iMouseY+*ObjectManager\iAnchorMouseY)
							iY      = AdjustY(*Object, \iY-iHeight+\iHeight, iHeight)
					EndSelect
				EndIf
				iX + Bool(\eAttachmentMode & #Attachment_X) * iParentX
				iY + Bool(\eAttachmentMode & #Attachment_Y) * iParentY
				; Object and Frame
				If \pDrawingCallback
					SaveVectorState()
					TranslateCoordinates(iX, iY)
					\pDrawingCallback(\iObject, iWidth, iHeight, \iCallbackData)
					RestoreVectorState()
				Else
					AddPathBox(iX, iY, iWidth, iHeight)
					VectorSourceColor($FFC0C0C0)
					FillPath()
				EndIf
				If \bSelected
					If \pSelectionStyle\eType <> #SelectionStyle_None
						AddPathBox(iX-\pSelectionStyle\dDistance, iY-\pSelectionStyle\dDistance, iWidth+\pSelectionStyle\dDistance*2, iHeight+\pSelectionStyle\dDistance*2)
						VectorSourceColor(\pSelectionStyle\iColor)
						Select \pSelectionStyle\eType
							Case #SelectionStyle_Solid  : StrokePath(\pSelectionStyle\dThickness)
							Case #SelectionStyle_Dashed : DashPath(\pSelectionStyle\dThickness, \pSelectionStyle\dThickness*3)
							Case #SelectionStyle_Dotted : DotPath(\pSelectionStyle\dThickness, \pSelectionStyle\dThickness*2)
						EndSelect
					EndIf
				EndIf
				; Handles
				If (\eHandleDisplayMode = #Handle_ShowAlways Or 
				    (\eHandleDisplayMode & #Handle_ShowIfHovered And *Object = *ObjectManager\pHoveredObject) Or
				    (\eHandleDisplayMode & #Handle_ShowIfSelected And \bSelected) ) And *ObjectManager\bMovement = #False
					For iIndex = 0 To #LastHandle
						If iIndex = 0 And \aHandle(0)\iImage = EditorFactory\iDefaultHandleImage : Continue : EndIf
						If \eHandle & (1<<iIndex)
							Swap \iX, iX
							Swap \iY, iY
							Swap \iWidth, iWidth
							Swap \iHeight, iHeight
							HandlePosition(*Object, \aHandle(iIndex), @iHandleX, @iHandleY)
							MovePathCursor(iHandleX-Int(\aHandle(iIndex)\iWidth/2), iHandleY-Int(\aHandle(iIndex)\iHeight/2))
							DrawVectorImage(\aHandle(iIndex)\iImageID)
							Swap \iX, iX
							Swap \iY, iY
							Swap \iWidth, iWidth
							Swap \iHeight, iHeight
						EndIf
					Next
				EndIf
				If \pNoFrame
					ObjectDrawing_Frame(\pNoFrame, iX, iY)
				EndIf
				If \pVisibleFrame
					If \pVisibleFrame\ViewBox\bEnabled
						SaveVectorState()
						AddPathBox(iX+\pVisibleFrame\ViewBox\iX, iY+\pVisibleFrame\ViewBox\iY, DecodeParentSize(\pVisibleFrame\ViewBox\iWidth, iWidth), DecodeParentSize(\pVisibleFrame\ViewBox\iHeight, iHeight))
						ClipPath()
						ObjectDrawing_Frame(\pVisibleFrame, iX+\pVisibleFrame\ViewBox\iX-\pVisibleFrame\InnerArea\iX, iY+\pVisibleFrame\ViewBox\iY-\pVisibleFrame\InnerArea\iY)
						RestoreVectorState()
					Else
						ObjectDrawing_Frame(\pVisibleFrame, iX+\pVisibleFrame\ViewBox\iX-\pVisibleFrame\InnerArea\iX, iY+\pVisibleFrame\ViewBox\iY-\pVisibleFrame\InnerArea\iY)
					EndIf
				EndIf
			EndWith
		Next
		
	EndProcedure
	
	Procedure   ObjectDrawing(*ObjectManager.ObjectManager)
		
		Protected iX.i, iY.i, iWidth.i, iHeight.i
		Protected iIndex.i
		Protected iMinX.i, iMinY.i, iMaxX.i, iMaxY.i
		Protected iHandleX.i, iHandleY.i
		Protected iTime = ElapsedMilliseconds()
		
		If StartVectorDrawing(CanvasVectorOutput(*ObjectManager\iCanvasGadget))
			*ObjectManager\iCanvasWidth = VectorOutputWidth()
			*ObjectManager\iCanvasHeight = VectorOutputHeight()
			If *ObjectManager\pPreDrawingCallback
				*ObjectManager\pPreDrawingCallback(*ObjectManager\iCanvasGadget, *ObjectManager\iCallbackData)
			Else
				VectorSourceColor($FFFFFFFF)
				FillVectorOutput()
			EndIf
			; Boundaries
; 			If #False; *ObjectManager\bMovement
; 				ForEach *ObjectManager\lpObject()
; 					With *ObjectManager\lpObject()
; 						If \bSelected
; 							Select *ObjectManager\iTransformationMode
; 								Case #Handle_Position
; 									If *ObjectManager\lpObject()\pBoundaryStyle\eType <> #BoundaryStyle_None
; 										iX = AdjustX(*ObjectManager\lpObject(), -1)
; 										iY = AdjustY(*ObjectManager\lpObject(), -1)
; 										iWidth = AdjustX(*ObjectManager\lpObject(), VectorOutputWidth()+1, *ObjectManager\lpObject()\iWidth) + *ObjectManager\lpObject()\iWidth - iX
; 										iHeight = AdjustY(*ObjectManager\lpObject(), VectorOutputHeight()+1, *ObjectManager\lpObject()\iHeight) + *ObjectManager\lpObject()\iHeight - iY
; 										AddPathBox(iX+0.5, iY+0.5, iWidth-1, iHeight-1)
; 										VectorSourceColor(*ObjectManager\lpObject()\pBoundaryStyle\iColor)
; 										Select *ObjectManager\lpObject()\pBoundaryStyle\eType
; 											Case #BoundaryStyle_Solid  : StrokePath(*ObjectManager\lpObject()\pBoundaryStyle\dThickness)
; 											Case #BoundaryStyle_Dashed : DashPath(*ObjectManager\lpObject()\pBoundaryStyle\dThickness, 3)
; 											Case #BoundaryStyle_Dotted : DotPath(*ObjectManager\lpObject()\pBoundaryStyle\dThickness, *ObjectManager\lpObject()\pBoundaryStyle\dThickness*2)
; 										EndSelect
; 									EndIf
; 									; 							Case #Handle_Right
; 									; 								iX      = *ObjectManager\lpObject()\iX + AdjustWidth(*ObjectManager\lpObject(), 0)
; 									; 								iY      = *ObjectManager\lpObject()\iY - 10
; 									; 								iWidth  = *ObjectManager\lpObject()\iX + AdjustWidth(*ObjectManager\lpObject(), VectorOutputWidth()) - iX
; 									; 								iHeight = *ObjectManager\lpObject()\iHeight + 20
; 									; 								MovePathCursor(iX-0.5, iY-0.5)
; 									; 								AddPathLine(0, iHeight, #PB_Path_Relative)
; 									; 								MovePathCursor(iX+iWidth-0.5, iY+0.5)
; 									; 								AddPathLine(0, iHeight, #PB_Path_Relative)
; 									; 								VectorSourceColor($FF808080)
; 									; 								DotPath(1, 3)
; 									; 							Case #Handle_BottomRight
; 									; 								iMinX = *ObjectManager\lpObject()\iX + AdjustWidth(*ObjectManager\lpObject(), 0)
; 									; 								iMaxX = *ObjectManager\lpObject()\iX + AdjustWidth(*ObjectManager\lpObject(), VectorOutputWidth()-*ObjectManager\lpObject()\iX)
; 									; 								iMinY = *ObjectManager\lpObject()\iY + AdjustHeight(*ObjectManager\lpObject(), 0)
; 									; 								iMaxY = *ObjectManager\lpObject()\iY + AdjustHeight(*ObjectManager\lpObject(), VectorOutputHeight()-*ObjectManager\lpObject()\iX)
; 									; 								MovePathCursor(iMinX-0.5, *ObjectManager\lpObject()\iY-10-0.5)
; 									; 								AddPathLine(iMinX-0.5, iMinY-0.5)
; 									; 								AddPathLine(*ObjectManager\lpObject()\iX-10-0.5, iMinY-0.5)
; 									; 								MovePathCursor(iMaxX+0.5, *ObjectManager\lpObject()\iY-10-0.5)
; 									; 								AddPathLine(iMaxX+0.5, iMaxY+0.5)
; 									; 								AddPathLine(*ObjectManager\lpObject()\iX-10-0.5, iMaxY+0.5)
; 									; 								VectorSourceColor($FF808080)
; 									; 								DotPath(1, 3)
; 							EndSelect
; 						EndIf
; 					EndWith
; 				Next
; 			EndIf
			; Objects
			ObjectDrawing_Frame(*ObjectManager\MainFrame)
			; Selection Frame
			With *ObjectManager\CursorSelectionStyle
				If \eType <> #SelectionStyle_None And *ObjectManager\iTransformationMode = #Handle_SelectionFrame And (*ObjectManager\iMouseX-*ObjectManager\iAnchorMouseX Or *ObjectManager\iMouseY-*ObjectManager\iAnchorMouseY)
					AddPathBox(*ObjectManager\iAnchorMouseX-\dThickness*0.5, *ObjectManager\iAnchorMouseY-\dThickness*0.5, *ObjectManager\iMouseX-*ObjectManager\iAnchorMouseX+\dThickness, *ObjectManager\iMouseY-*ObjectManager\iAnchorMouseY+\dThickness)
					If \iBackgroundColor>>24 <> $00
						VectorSourceColor(\iBackgroundColor)
						FillPath(#PB_Path_Preserve)
					EndIf
					VectorSourceColor(\iColor)
					If \dThickness > 0.0
						Select \eType & ~#SelectionStyle_Mode
							Case #SelectionStyle_Solid  : StrokePath(\dThickness)
							Case #SelectionStyle_Dashed : DashPath(\dThickness, \dThickness*3)
							Case #SelectionStyle_Dotted : DotPath(\dThickness, \dThickness*2)
						EndSelect
					Else
						ResetPath()
					EndIf
				EndIf
			EndWith
			If *ObjectManager\pPostDrawingCallback
				*ObjectManager\pPostDrawingCallback(*ObjectManager\iCanvasGadget, *ObjectManager\iCallbackData)
			EndIf
			StopVectorDrawing()
		EndIf
		
		;Debug ElapsedMilliseconds()-iTime
		
	EndProcedure
	
	Procedure   ChangeObjectSelection(*Object.Object)
		
		If *Object\bSelected
			*Object\bSelected = #False
			PostObjectEvent(*Object\pParentFrame\pObjectManager, #EventType_Unselected, *Object)
		Else
			*Object\bSelected = #True
			PostObjectEvent(*Object\pParentFrame\pObjectManager, #EventType_Selected, *Object)
		EndIf
		
	EndProcedure
	
	Procedure   SelectExclusiveObject(*Object.Object)
		
		Protected *ObjectManager.ObjectManager = *Object\pParentFrame\pObjectManager
		
		ForEach *ObjectManager\lpObject()
			If *ObjectManager\lpObject() = *Object
				If *ObjectManager\lpObject()\bSelected = #False
					*ObjectManager\lpObject()\bSelected = #True
					PostObjectEvent(*ObjectManager, #EventType_Selected, *ObjectManager\lpObject())
				EndIf
			Else
				If *ObjectManager\lpObject()\bSelected = #True
					*ObjectManager\lpObject()\bSelected = #False
					PostObjectEvent(*ObjectManager, #EventType_Unselected, *ObjectManager\lpObject())
				EndIf
			EndIf
		Next
		
	EndProcedure
	
	Procedure   UnselectObjects(*ObjectManager.ObjectManager)
		
		ForEach *ObjectManager\lpObject()
			If *ObjectManager\lpObject()\bSelected
				*ObjectManager\lpObject()\bSelected = #False
				PostObjectEvent(*ObjectManager, #EventType_Unselected, *ObjectManager\lpObject())
			EndIf
		Next
		
	EndProcedure
	
	Procedure   EventCallback_UpdateCanvasGadget()
		
		Protected *ObjectManager.ObjectManager = GetGadgetData(EventGadget())
		Protected iX.i, iY.i, iWidth.i, iHeight.i, iShiftX.i, iShiftY.i
		Protected iEvent.i, EventDataArray.EventDataArray, *Object.Object
		
		With *ObjectManager
			If \pHoveredObject
				\pEventObject = \pHoveredObject
			Else
				\pEventObject = #Null
			EndIf
			If \iHoveredHandle 
				\iEventHandle = \iHoveredHandle
			Else
				\iEventHandle = #Handle_None
			EndIf
			Select EventType()
				Case #PB_EventType_Resize
					ObjectDrawing(*ObjectManager)
				Case #PB_EventType_KeyDown ;- KeyDown
					If \pHoveredObject
						PostObjectEvent(*ObjectManager, #EventType_KeyDown, \pHoveredObject, GetGadgetAttribute(EventGadget(), #PB_Canvas_Key))
						If \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_KeyDown, \pHoveredObject, \iHoveredHandle, GetGadgetAttribute(EventGadget(), #PB_Canvas_Key))
						EndIf	
					EndIf
					iShiftX = 0
					iShiftY = 0
					Select GetGadgetAttribute(\iCanvasGadget, #PB_Canvas_Key)
						Case #PB_Shortcut_Down
							iShiftY = 1
						Case #PB_Shortcut_Up
							iShiftY = -1
						Case #PB_Shortcut_Left
							iShiftX = -1
						Case #PB_Shortcut_Right
							iShiftX = 1
					EndSelect
					If iShiftX Or iShiftY
						ForEach \lpObject()
							If \lpObject()\bSelected 
								If GetGadgetAttribute(\iCanvasGadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
									If #Handle_Width & \lpObject()\eHandle
										iWidth  = AdjustWidth(\lpObject(), \lpObject()\iWidth+iShiftX*\lpObject()\Grid\iSizeY)
										If iWidth <> \lpObject()\iWidth
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
										\lpObject()\iWidth  = iWidth
										\lpObject()\iX      = AdjustX(\lpObject(), \lpObject()\iX, \lpObject()\iWidth)
									EndIf
									If #Handle_Height & \lpObject()\eHandle
										iHeight = AdjustHeight(\lpObject(), \lpObject()\iHeight+iShiftY*\lpObject()\Grid\iSizeY)
										If iHeight <> \lpObject()\iHeight
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
										\lpObject()\iHeight = iHeight
										\lpObject()\iY      = AdjustY(\lpObject(), \lpObject()\iY, \lpObject()\iHeight)
									EndIf
								ElseIf GetGadgetAttribute(\iCanvasGadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control = 0 And #Handle_Position & \lpObject()\eHandle
									iX = AdjustX(\lpObject(), \lpObject()\iX + iShiftX*\lpObject()\Grid\iMoveX, \lpObject()\iWidth)
									iY = AdjustY(\lpObject(), \lpObject()\iY + iShiftY*\lpObject()\Grid\iMoveY, \lpObject()\iHeight)
									If iX <> \lpObject()\iX Or iY <> \lpObject()\iY
										PostObjectEvent(*ObjectManager, #EventType_Moved, \lpObject())
									EndIf
									\lpObject()\iX = iX
									\lpObject()\iY = iY
								EndIf
							EndIf
						Next
						ObjectDrawing(*ObjectManager)
					EndIf
				Case #PB_EventType_KeyUp ;- KeyUp
					If \pHoveredObject
						PostObjectEvent(*ObjectManager, #EventType_KeyUp, \pHoveredObject, GetGadgetAttribute(EventGadget(), #PB_Canvas_Key))
						If \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_KeyUp, \pHoveredObject, \iHoveredHandle, GetGadgetAttribute(EventGadget(), #PB_Canvas_Key))
						EndIf
					EndIf
				Case #PB_EventType_MouseWheel ;- MouseWheel
					If \pHoveredObject
						PostObjectEvent(*ObjectManager, #EventType_MouseWheel, \pHoveredObject, GetGadgetAttribute(EventGadget(), #PB_Canvas_WheelDelta))
						If \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_MouseWheel, \pHoveredObject, \iHoveredHandle, GetGadgetAttribute(EventGadget(), #PB_Canvas_WheelDelta))
						EndIf	
					EndIf
				Case #PB_EventType_MouseMove ;- MouseMove
					\iMouseX = GetGadgetAttribute(\iCanvasGadget, #PB_Canvas_MouseX)
					\iMouseY = GetGadgetAttribute(\iCanvasGadget, #PB_Canvas_MouseY)
					iEvent = ObjectEvents(*ObjectManager)
					If GetGadgetAttribute(\iCanvasGadget, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton And \iTransformationMode
						If Abs(\iMouseX-\iAnchorMouseX) >= 5 Or Abs(\iMouseY-\iAnchorMouseY) >= 5
							\bMovement = #True
							If \pHoveredObject And \iTransformationMode = #Handle_Position
								If \pHoveredObject\aHandle(0)\eCursor = #PB_Cursor_Custom And (\eCurrentCursor <> \pHoveredObject\aHandle(0)\eCursor Or \hCurrentCursorHandle <> \pHoveredObject\aHandle(0)\hCursorHandle)
									SetGadgetAttribute(\iCanvasGadget, #PB_Canvas_CustomCursor, \pHoveredObject\aHandle(0)\hCursorHandle)
									\eCurrentCursor = \pHoveredObject\aHandle(0)\eCursor
									\hCurrentCursorHandle = \pHoveredObject\aHandle(0)\hCursorHandle
								ElseIf \eCurrentCursor <> \pHoveredObject\aHandle(0)\eCursor
									SetGadgetAttribute(\iCanvasGadget, #PB_Canvas_Cursor, \pHoveredObject\aHandle(0)\eCursor)
									\eCurrentCursor = \pHoveredObject\aHandle(0)\eCursor
									\hCurrentCursorHandle = #Null
								EndIf
							EndIf
						EndIf
					EndIf
					If \bMovement Or iEvent
						ObjectDrawing(*ObjectManager)
					EndIf
				Case #PB_EventType_MouseLeave ;- MouseLeave
					If \pHoveredObject
						PostObjectEvent(*ObjectManager, #EventType_MouseLeave, \pHoveredObject)
						\pHoveredObject = #Null
						If \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_MouseLeave, \pHoveredObject, \iHoveredHandle)
							\iHoveredHandle = #Handle_None
						EndIf
					EndIf
				Case #PB_EventType_LeftButtonDown ;- LeftButtonDown
					\iAnchorMouseX = \iMouseX
					\iAnchorMouseY = \iMouseY
					If \pHoveredObject
						\pMouseDownObject[1] = \pHoveredObject
						If \iHoveredHandle < #Handle_Custom1
							\iTransformationMode = \iHoveredHandle
						EndIf
						If \pCurrentFrame <> \pHoveredObject\pParentFrame
							UnselectObjects(*ObjectManager)
							\pCurrentFrame = \pHoveredObject\pParentFrame
						EndIf
						If GetGadgetAttribute(\iCanvasGadget, #PB_Canvas_Modifiers) & #PB_Canvas_Control
							ChangeObjectSelection(\pHoveredObject)
						ElseIf \pHoveredObject\bSelected = #False
							SelectExclusiveObject(\pHoveredObject)
						EndIf
						PostObjectEvent(*ObjectManager, #EventType_LeftMouseBottonDown, \pHoveredObject)
						If \pMouseClickObject[1] = \pHoveredObject And ElapsedMilliseconds() - \iMouseDoubleClickTime[1] < DoubleClickTime()
							PostObjectEvent(*ObjectManager, #EventType_LeftMouseDoubleClick, \pHoveredObject)
						EndIf
						If \iHoveredHandle
							\iMouseDownHandle[1] = \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_LeftMouseBottonDown, \pHoveredObject, \iHoveredHandle)
							If \iMouseClickHandle[1] = \iHoveredHandle And \pMouseClickObject[1] = \pHoveredObject And ElapsedMilliseconds() - \iMouseDoubleClickTime[1] < DoubleClickTime()
								PostHandleEvent(*ObjectManager, #EventType_LeftMouseDoubleClick, \pHoveredObject, \iHoveredHandle)
							EndIf
							CompilerIf #PB_Compiler_Thread
								PostHandleEvent(*ObjectManager, #EventType_LeftMouseButtonHold, \pHoveredObject, \iHoveredHandle)
								\iMouseHoldTime[1] = ElapsedMilliseconds()
							CompilerEndIf
						Else
							\iMouseDownHandle[1] = #Handle_None
						EndIf
					Else
						\pMouseDownObject[1] = #Null
						If \CursorSelectionStyle\eType <> #SelectionStyle_None
							\iTransformationMode = #Handle_SelectionFrame
							\pCurrentFrame = \pEnteredFrame
						EndIf
						UnselectObjects(*ObjectManager)
					EndIf
					ObjectDrawing(*ObjectManager)
				Case #PB_EventType_LeftButtonUp ;- LeftButtonUp
					\iMouseHoldTime[1] = 0
					\pMouseClickObject[1] = #Null
					If \pHoveredObject
						PostObjectEvent(*ObjectManager, #EventType_LeftMouseBottonUp, \pHoveredObject)
						If \pMouseDownObject[1] = \pHoveredObject And \bMovement = #False
							\pMouseClickObject[1] = \pHoveredObject
							\iMouseDoubleClickTime[1] = ElapsedMilliseconds()
							PostObjectEvent(*ObjectManager, #EventType_LeftMouseClick, \pHoveredObject)
						EndIf
						If \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_LeftMouseBottonUp, \pHoveredObject, \iHoveredHandle)
							If \iMouseDownHandle[1] = \iHoveredHandle And \pMouseDownObject[1] = \pHoveredObject And \bMovement = #False
								\iMouseClickHandle[1] = \iHoveredHandle
								\iMouseDoubleClickTime[1] = ElapsedMilliseconds()
								PostHandleEvent(*ObjectManager, #EventType_LeftMouseClick, \pHoveredObject, \iHoveredHandle)
							EndIf
						EndIf
					EndIf
					\pMouseDownObject[1] = #Null
					If  \iTransformationMode = #Handle_SelectionFrame
						iX = \iAnchorMouseX
						iY = \iAnchorMouseY
						iWidth = \iMouseX - \iAnchorMouseX
						iHeight = \iMouseY - \iAnchorMouseY
						If iWidth < 0 : iX + iWidth : iWidth = -iWidth : EndIf
						If iHeight < 0 : iY + iHeight : iHeight = -iHeight : EndIf
						ForEach \pCurrentFrame\lpChildObject()
							*Object = \pCurrentFrame\lpChildObject()
							If *Object\bDisabled Or *Object\bHidden
								Continue
							EndIf
							If GlobalX(*Object, *Object\iX) >= iX And GlobalX(*Object, *Object\iX)+*Object\iWidth <= iX+iWidth And
							   GlobalY(*Object, *Object\iY) >= iY And GlobalY(*Object, *Object\iY)+*Object\iHeight <= iY+iHeight
								*Object\bSelected = #True
								PostObjectEvent(*ObjectManager, #EventType_Selected, *Object)
							ElseIf \CursorSelectionStyle\eType & #SelectionStyle_Partially And 
							       GlobalX(*Object, *Object\iX)+*Object\iWidth >= iX And GlobalX(*Object, *Object\iX) <= iX+iWidth And
							       GlobalY(*Object, *Object\iY)+*Object\iHeight >= iY And GlobalY(*Object, *Object\iY) <= iY+iHeight
								*Object\bSelected = #True
								PostObjectEvent(*ObjectManager, #EventType_Selected, *Object)
							EndIf
						Next
						EventDataArray\i[#EventTypeData_MinX] = iX
						EventDataArray\i[#EventTypeData_MinY] = iY
						EventDataArray\i[#EventTypeData_MaxX] = iX+iWidth
						EventDataArray\i[#EventTypeData_MaxY] = iY+iHeight
						If iWidth > 0 Or iHeight > 0
							PostObjectEvent(*ObjectManager, #EventType_Selection, #Null, @EventDataArray)
						EndIf
					ElseIf \bMovement
						ForEach \lpObject()
							If \lpObject()\bSelected And \iTransformationMode & \lpObject()\eHandle
								Select \iTransformationMode
									Case #Handle_Position
										iX = AdjustX(\lpObject(), \lpObject()\iX + \iMouseX - \iAnchorMouseX, \lpObject()\iWidth)
										iY = AdjustY(\lpObject(), \lpObject()\iY + \iMouseY - \iAnchorMouseY, \lpObject()\iHeight)
										If iX <> \lpObject()\iX Or iY <> \lpObject()\iY
											\lpObject()\iX = iX
											\lpObject()\iY = iY
											PostObjectEvent(*ObjectManager, #EventType_Moved, \lpObject())
										EndIf
									Case #Handle_BottomLeft
										iWidth              = AdjustWidth(\lpObject(), \lpObject()\iWidth-\iMouseX+\iAnchorMouseX)
										iHeight             = AdjustHeight(\lpObject(), \lpObject()\iHeight+\iMouseY-\iAnchorMouseY)
										If iWidth <> \lpObject()\iWidth Or iHeight <> \lpObject()\iHeight
											\lpObject()\iX      = AdjustX(\lpObject(), \lpObject()\iX-iWidth+\lpObject()\iWidth, iWidth)
											\lpObject()\iWidth  = iWidth
											\lpObject()\iHeight = iHeight
											\lpObject()\iY      = AdjustY(\lpObject(), \lpObject()\iY, \lpObject()\iHeight)
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
									Case #Handle_Bottom
										iHeight             = AdjustHeight(\lpObject(), \lpObject()\iHeight+\iMouseY-\iAnchorMouseY)
										If iHeight <> \lpObject()\iHeight
											\lpObject()\iHeight = iHeight
											\lpObject()\iY      = AdjustY(\lpObject(), \lpObject()\iY, \lpObject()\iHeight)
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
									Case #Handle_BottomRight
										iWidth  = AdjustWidth(\lpObject(), \lpObject()\iWidth+\iMouseX-\iAnchorMouseX)
										iHeight = AdjustHeight(\lpObject(), \lpObject()\iHeight+\iMouseY-\iAnchorMouseY)
										If iWidth <> \lpObject()\iWidth Or iHeight <> \lpObject()\iHeight
											\lpObject()\iWidth  = iWidth
											\lpObject()\iX      = AdjustX(\lpObject(), \lpObject()\iX, \lpObject()\iWidth)
											\lpObject()\iHeight = iHeight
											\lpObject()\iY      = AdjustY(\lpObject(), \lpObject()\iY, \lpObject()\iHeight)
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
									Case #Handle_Left
										iWidth              = AdjustWidth(\lpObject(), \lpObject()\iWidth-\iMouseX+\iAnchorMouseX)
										If iWidth <> \lpObject()\iWidth
											\lpObject()\iX      = AdjustX(\lpObject(), \lpObject()\iX-iWidth+\lpObject()\iWidth, iWidth)
											\lpObject()\iWidth  = iWidth
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
									Case #Handle_Right
										iWidth  = AdjustWidth(\lpObject(), \lpObject()\iWidth+\iMouseX-\iAnchorMouseX)
										If iWidth <> \lpObject()\iWidth
											\lpObject()\iWidth  = iWidth
											\lpObject()\iX      = AdjustX(\lpObject(), \lpObject()\iX, \lpObject()\iWidth)
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
									Case #Handle_TopLeft
										iWidth              = AdjustWidth(\lpObject(), \lpObject()\iWidth-\iMouseX+\iAnchorMouseX)
										iHeight             = AdjustHeight(\lpObject(), \lpObject()\iHeight-\iMouseY+\iAnchorMouseY)
										If iWidth <> \lpObject()\iWidth Or iHeight <> \lpObject()\iHeight
											\lpObject()\iX      = AdjustX(\lpObject(), \lpObject()\iX-iWidth+\lpObject()\iWidth, iWidth)
											\lpObject()\iWidth  = iWidth
											\lpObject()\iY      = AdjustY(\lpObject(), \lpObject()\iY-iHeight+\lpObject()\iHeight, iHeight)
											\lpObject()\iHeight = iHeight
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
									Case #Handle_Top
										iHeight = AdjustHeight(\lpObject(), \lpObject()\iHeight-\iMouseY+\iAnchorMouseY)
										If iHeight <> \lpObject()\iHeight
											\lpObject()\iY      = AdjustY(\lpObject(), \lpObject()\iY-iHeight+\lpObject()\iHeight, iHeight)
											\lpObject()\iHeight = iHeight
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
									Case #Handle_TopRight
										iWidth  = AdjustWidth(\lpObject(), \lpObject()\iWidth+\iMouseX-\iAnchorMouseX)
										iHeight = AdjustHeight(\lpObject(), \lpObject()\iHeight-\iMouseY+\iAnchorMouseY)
										If iWidth <> \lpObject()\iWidth Or iHeight <> \lpObject()\iHeight
											\lpObject()\iWidth  = iWidth
											\lpObject()\iX      = AdjustX(\lpObject(), \lpObject()\iX, \lpObject()\iWidth)
											\lpObject()\iY      = AdjustY(\lpObject(), \lpObject()\iY-iHeight+\lpObject()\iHeight, iHeight)
											\lpObject()\iHeight = iHeight
											PostObjectEvent(*ObjectManager, #EventType_Resized, \lpObject())
										EndIf
								EndSelect
							EndIf
						Next
					EndIf
					\iTransformationMode = #Null
					\bMovement = #False
					ObjectDrawing(*ObjectManager)
				Case #PB_EventType_MiddleButtonDown ;- MiddleButtonDown
					If \pHoveredObject
						\pMouseDownObject[3] = \pHoveredObject
						PostObjectEvent(*ObjectManager, #EventType_MiddleMouseBottonDown, \pHoveredObject)
						If \pMouseClickObject[3] = \pHoveredObject And ElapsedMilliseconds() - \iMouseDoubleClickTime[3] < DoubleClickTime()
							PostObjectEvent(*ObjectManager, #EventType_MiddleMouseDoubleClick, \pHoveredObject)
						EndIf
						If \iHoveredHandle
							\iMouseDownHandle[3] = \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_MiddleMouseBottonDown, \pHoveredObject, \iHoveredHandle)
							If \iMouseClickHandle[3] = \iHoveredHandle And \pMouseClickObject[3] = \pHoveredObject And ElapsedMilliseconds() - \iMouseDoubleClickTime[3] < DoubleClickTime()
								PostHandleEvent(*ObjectManager, #EventType_MiddleMouseDoubleClick, \pHoveredObject, \iHoveredHandle)
							EndIf
							CompilerIf #PB_Compiler_Thread
								PostHandleEvent(*ObjectManager, #EventType_LeftMouseButtonHold, \pHoveredObject, \iHoveredHandle)
								\iMouseHoldTime[3] = ElapsedMilliseconds()
							CompilerEndIf
						Else
							\iMouseDownHandle[3] = #Handle_None
						EndIf
					Else
						\pMouseDownObject[3] = #Null
					EndIf
				Case #PB_EventType_MiddleButtonUp ;- MiddleButtonUp
					\iMouseHoldTime[3] = 0
					\pMouseClickObject[3] = #Null
					If \pHoveredObject
						PostObjectEvent(*ObjectManager, #EventType_MiddleMouseBottonUp, \pHoveredObject)
						If \pMouseDownObject[3] = \pHoveredObject
							\pMouseClickObject[3] = \pHoveredObject
							\iMouseDoubleClickTime[3] = ElapsedMilliseconds()
							PostObjectEvent(*ObjectManager, #EventType_MiddleMouseClick, \pHoveredObject)
						EndIf
						If \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_MiddleMouseBottonUp, \pHoveredObject, \iHoveredHandle)
							If \iMouseDownHandle[3] = \iHoveredHandle And \pMouseDownObject[3] = \pHoveredObject
								\iMouseClickHandle[3] = \iHoveredHandle
								\iMouseDoubleClickTime[3] = ElapsedMilliseconds()
								PostHandleEvent(*ObjectManager, #EventType_MiddleMouseClick, \pHoveredObject, \iHoveredHandle)
							EndIf
						EndIf
					EndIf
					\pMouseDownObject[3] = #Null
				Case #PB_EventType_RightButtonDown ;- RightButtonDown
					If \pHoveredObject
						\pMouseDownObject[2] = \pHoveredObject
						PostObjectEvent(*ObjectManager, #EventType_RightMouseBottonDown, \pHoveredObject)
						If \pMouseClickObject[2] = \pHoveredObject And ElapsedMilliseconds() - \iMouseDoubleClickTime[2] < DoubleClickTime()
							PostObjectEvent(*ObjectManager, #EventType_RightMouseDoubleClick, \pHoveredObject)
						EndIf
						If \iHoveredHandle
							\iMouseDownHandle[2] = \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_LeftMouseBottonDown, \pHoveredObject, \iHoveredHandle)
							If \iMouseClickHandle[2] = \iHoveredHandle And \pMouseClickObject[2] = \pHoveredObject And ElapsedMilliseconds() - \iMouseDoubleClickTime[2] < DoubleClickTime()
								PostHandleEvent(*ObjectManager, #EventType_LeftMouseDoubleClick, \pHoveredObject, \iHoveredHandle)
							EndIf
							CompilerIf #PB_Compiler_Thread
								PostHandleEvent(*ObjectManager, #EventType_LeftMouseButtonHold, \pHoveredObject, \iHoveredHandle)
								\iMouseHoldTime[2] = ElapsedMilliseconds()
							CompilerEndIf
						Else
							\iMouseDownHandle[2] = #Handle_None
						EndIf
					Else
						\pMouseDownObject[2] = #Null
					EndIf
				Case #PB_EventType_RightButtonUp ;- RightButtonUp
					\iMouseHoldTime[2] = 0
					\pMouseClickObject[2] = #Null
					If \pHoveredObject
						PostObjectEvent(*ObjectManager, #EventType_RightMouseBottonUp, \pHoveredObject)
						If \pMouseDownObject[2] = \pHoveredObject
							\pMouseClickObject[2] = \pHoveredObject
							\iMouseDoubleClickTime[2] = ElapsedMilliseconds()
							PostObjectEvent(*ObjectManager, #EventType_RightMouseClick, \pHoveredObject)
						EndIf
						If \iHoveredHandle
							PostHandleEvent(*ObjectManager, #EventType_RightMouseBottonUp, \pHoveredObject, \iHoveredHandle)
							If \iMouseDownHandle[2] = \iHoveredHandle And \pMouseDownObject[2] = \pHoveredObject
								\iMouseClickHandle[2] = \iHoveredHandle
								\iMouseDoubleClickTime[2] = ElapsedMilliseconds()
								PostHandleEvent(*ObjectManager, #EventType_RightMouseClick, \pHoveredObject, \iHoveredHandle)
							EndIf
						EndIf
					EndIf
					\pMouseDownObject[2] = #Null
				Case #Redraw
					ObjectDrawing(*ObjectManager)
					*ObjectManager\bRedrawPosted = #False
			EndSelect
		EndWith
		
	EndProcedure
	
	Procedure   MouseButtonHold_Thread(*ObjectManager.ObjectManager)
		
		Protected *HoveredObject, HoveredHandle.i, *Event.ObjectManagerEvent
		
		With *ObjectManager
			Repeat
				Delay(50)
				LockMutex(*ObjectManager\iEventMutex)
				*Event = LastElement(*ObjectManager\lEvent())
				*HoveredObject = \pHoveredObject
				HoveredHandle  = \iHoveredHandle
				If \iMouseHoldTime[1] <> 0 And ElapsedMilliseconds() > \iMouseHoldTime[1] + DoubleClickTime()/2 And *ObjectManager\bRedrawPosted = #False
					PostHandleEvent(*ObjectManager, #EventType_LeftMouseButtonHold, *HoveredObject, HoveredHandle)
					PostRedrawEvent(*ObjectManager)
				EndIf
				If \iMouseHoldTime[2] <> 0 And ElapsedMilliseconds() > \iMouseHoldTime[2] + DoubleClickTime()/2 And *ObjectManager\bRedrawPosted = #False
					PostHandleEvent(*ObjectManager, #EventType_RightMouseButtonHold, *HoveredObject, HoveredHandle)
					PostRedrawEvent(*ObjectManager)
				EndIf
				If \iMouseHoldTime[3] <> 0 And ElapsedMilliseconds() > \iMouseHoldTime[3] + DoubleClickTime()/2 And *ObjectManager\bRedrawPosted = #False
					PostHandleEvent(*ObjectManager, #EventType_MiddleMouseButtonHold, *HoveredObject, HoveredHandle)
					PostRedrawEvent(*ObjectManager)
				EndIf
				UnlockMutex(*ObjectManager\iEventMutex)
			Until *ObjectManager\bQuitThread
		EndWith
		
	EndProcedure
	
	
	;---------------------------------
	;- Public
	;---------------------------------
	
	
	;- General
	
	
	
	;{ Deinitializes the whole object manager for the specified canvas gadget and frees all resources.
	;  iCanvasGadget:         PB Gadget number.
  ;  Result:                #True, if deinitialization succeeded, otherwise #False.
	;
	;  Désinitialise l'ensemble du gestionnaire d'objets pour le canevas gadget spécifié et libère toutes les ressources qui y sont associés.
	;  iCanvasGadget:         PB Numéro de gadget.
	;  Résultat:              #True, si la désinitialisation (libération) a réussi, sinon #False.
	;}
	Procedure.i ReleaseCanvasObjects(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0)
		
		With *ObjectManager
			UnbindGadgetEvent(iCanvasGadget, @EventCallback_UpdateCanvasGadget())
			\bQuitThread = #True
			If \iMouseButtonHoldThread
				WaitThread(\iMouseButtonHoldThread)
			EndIf
			FreeMutex(\iEventMutex)
			ClearList(\lEvent())
			ForEach \MainFrame\lpChildObject()
				FreeObject(\MainFrame\lpChildObject(), #Object_FreeChildObjects)
			Next
			SetGadgetData(iCanvasGadget, #Null)
			ChangeCurrentElement(EditorFactory\lObjectManager(), *ObjectManager)
			DeleteElement(EditorFactory\lObjectManager())
		EndWith
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Initializes the object manager for the specified canvas gadget in the specified window.
	;  iCanvasGadget:         PB Gadget number.
	;  iWindow:               PB Window number.
	;  Result:                #True, if initialization succeeded, otherwise #False.
	;
	;  Initialise le gestionnaire d'Objets pour le Canevas gadget spécifié dans la fenêtre spécifiée, doit être fait pour chaque Canevas gadget.
	;  iCanvasGadget:         PB Numéro du Canevas gadget.
	;  iWindow:               PB Numéro de fenêtre.
	;  Resulta:               Renvoie #True, si l'initialisation a réussi, sinon, #False.
	;}
	Procedure.i InitializeCanvasObjects(iCanvasGadget.i, iWindow.i)
		
		If IsWindow(iWindow) = #False
			Debug "EditorFactory.Error: Invalid window number for "+#PB_Compiler_Procedure+" (" +  _DQ_#iWindow#_DQ_ + " = "+Str(iWindow)+")"
			ProcedureReturn #False
		EndIf
		
		If IsGadget(iCanvasGadget) = #False Or GadgetType(iCanvasGadget) <> #PB_GadgetType_Canvas
			Debug "EditorFactory.Error: Invalid canvas gadget number for "+#PB_Compiler_Procedure+" (" +  _DQ_#iCanvasGadget#_DQ_ + " = "+Str(iCanvasGadget)+")"
			ProcedureReturn #False
		EndIf
		
		AddElement(EditorFactory\lObjectManager())
		With EditorFactory\lObjectManager()
			\iCanvasGadget = iCanvasGadget
			\iWindow       = iWindow
			If StartDrawing(CanvasOutput(iCanvasGadget))
				\iCanvasWidth  = OutputWidth()
				\iCanvasHeight = OutputHeight()
				StopDrawing()
			EndIf
			\CursorSelectionStyle\eType            = #SelectionStyle_None
			\CursorSelectionStyle\iColor           = $FF000000
			\CursorSelectionStyle\dThickness       = 1.0
			\CursorSelectionStyle\iBackgroundColor = $00000000
			SetGadgetData(iCanvasGadget, EditorFactory\lObjectManager())
			BindGadgetEvent(iCanvasGadget, @EventCallback_UpdateCanvasGadget())
			\eCursor                               = #PB_Cursor_Default
			\MainFrame\pObjectManager              = EditorFactory\lObjectManager()
			\MainFrame\InnerArea\iWidth            = #Boundary_None
			\MainFrame\InnerArea\iHeight           = #Boundary_None
			CompilerIf #PB_Compiler_Thread
				ElapsedMilliseconds()
				\iMouseButtonHoldThread                = CreateThread(@MouseButtonHold_Thread(), @EditorFactory\lObjectManager())
			CompilerEndIf
			\iEventMutex = CreateMutex()
		EndWith
		
		If Not EditorFactory\bInitialized
			
			EditorFactory\iDefaultHandleImage = CreateImage(#PB_Any, 8, 8, 32, #PB_Image_Transparent)
			If StartDrawing(ImageOutput(EditorFactory\iDefaultHandleImage))
				DrawingMode(#PB_2DDrawing_AllChannels)
				Box(0, 0, 8, 8, $C0FFFFFF)
				DrawingMode(#PB_2DDrawing_AllChannels|#PB_2DDrawing_Outlined)
				Box(0, 0, 8, 8, $FF000000)
				StopDrawing()
			EndIf
			
			;- Default settings
			EditorFactory\DefaultObject\pSelectionStyle = AddElement(EditorFactory\lObjectStyle())
			With EditorFactory\DefaultObject\pSelectionStyle
				\eType            = #SelectionStyle_None
				\iColor           = $FF000000
				\dThickness       = 1.0
				\dDistance        = 0.5
				\iBackgroundColor = $00000000
			EndWith
			EditorFactory\DefaultObject\pBoundaryStyle = AddElement(EditorFactory\lObjectStyle())
			With EditorFactory\DefaultObject\pBoundaryStyle
				\eType            = #SelectionStyle_Dashed
				\iColor           = $40000000
				\dThickness       = 1.0
				\iBackgroundColor = $00000000
			EndWith
			With EditorFactory\DefaultObject\Boundaries
				\iMinX       = #Boundary_None
				\iMinY       = #Boundary_None
				\iMaxX       = #Boundary_None
				\iMaxY       = #Boundary_None
				\iMinWidth   = 0
				\iMinHeight  = 0
				\iMaxWidth   = #Boundary_None
				\iMaxHeight  = #Boundary_None
			EndWith
			With EditorFactory\DefaultObject\Grid
				\iMoveX = 1
				\iMoveY = 1
				\iSizeX = 1
				\iSizeY = 1
			EndWith
			With EditorFactory\DefaultObject
				\eCursor            = #PB_Cursor_Default
				\eHandleDisplayMode = #Handle_ShowIfHovered|#Handle_ShowIfSelected
			EndWith
			
			EditorFactory\bInitialized = #True
			
		EndIf
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Verifies that the gadget is initialized for objects.
	;  iCanvasGadget:         PB Gadget number.
	;  Result:                #True if the gadget was initialized, otherwise #False.
	;
	;  Vérifie que le Canevas gadget est initialisé pour les Objets.
	;  iCanvasGadget:         Numéro du Canevas gadget.
  ;  Résultat:              #True si le Canevas gadget est initialisé, Sinon #False.
	;} 
	Procedure.i IsCanvasObjects(iCanvasGadget.i)
		
		ForEach EditorFactory\lObjectManager()
			If EditorFactory\lObjectManager()\iCanvasGadget = iCanvasGadget
				ProcedureReturn #True
			EndIf
		Next
		
		ProcedureReturn #False
		
	EndProcedure
	
	
	;{ Verifies that an object exists.
	;  iObject:               Object number.
	;  Result:                The adress to the object if the object exists, otherwise #Null.
	;
	;  Vérifie l'existence d'un Objet.
	;  iObject:               Le numéro de L'Objet.
	;  Résultat :             L'adresse de l'objet si l'objet existe, sinon #Null.
	;} 
	Procedure.i IsObject(iObject.i)
		
		ForEach EditorFactory\lObject()
			If EditorFactory\lObject()\iObject = iObject Or @EditorFactory\lObject() = iObject
				ProcedureReturn @EditorFactory\lObject()
			EndIf
		Next
		
	EndProcedure
	
	
	;{ Verifies whether an object frame exists.
	;  iObject:               Object number.
	;  iFrameIndex:           An index of a frame (starting with 0).
  ;  Result:                #True, if the frame exists, otherwise #False.
	;
	;  Vérifie si un cadre d'objet existe.
	;  iObject:               Numéro de l'objet.
	;  iFrameIndex:           Un index d'une trame (commençant par 0).
	;  Résultat:              #True, si le cadre existe, sinon #False.
	;} 
	Procedure.i IsObjectFrame(iObject.i, iFrameIndex.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		
		If iFrameIndex >= 0 And iFrameIndex < ListSize(*Object\lFrame())-1
			ProcedureReturn #True
		Else
			ProcedureReturn #False
		EndIf
		
	EndProcedure
	
	
	;{ Frees and removes the object from its parent canvas gadget.
	;  iObject:               Object number.
	;  eFlags:                #Object_FreeChildObjects or #Object_DetachChildObjects, to free or detach all child objects.
	;  Result:                #True, if freeing succeeded, otherwise #False.
	;
	;  Libère et supprime l'Objet de son Canevas gadget parent.
	;  iObject:               Numéro de l'Objet.
  ;  eFlags :               #Object_FreeChildObjects ou #Object_DetachChildObjects, pour libérer ou détacher tous les enfants-objets.
	;  Result:                #True, si la libération a réussi, Sinon, #False.
	;}
	Procedure.i FreeObject(iObject.i, eFlags.i=#Object_FreeChildObjects)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		Protected *ObjectManager.ObjectManager = *Object\pParentFrame\pObjectManager
		
		; Entfernung aller Frames und deren Kinder
		ForEach *Object\lFrame()
			ForEach *Object\lFrame()\lpChildObject()
				If eFlags = #Object_DetachChildObjects
					DetachObject(*Object\lFrame()\lpChildObject())
				Else
					FreeObject(*Object\lFrame()\lpChildObject())
				EndIf
			Next
		Next
		
		; Entfernung aus der globalen Liste
		ForEach *ObjectManager\lpObject()
			If *ObjectManager\lpObject() = *Object
				If *ObjectManager\pCurrentExaminedElement = *ObjectManager\lpObject()
					DeleteElement(*ObjectManager\lpObject())
					If ListIndex(*ObjectManager\lpObject()) = -1
						*ObjectManager\pCurrentExaminedElement = #Null
					Else
						*ObjectManager\pCurrentExaminedElement = *ObjectManager\lpObject()
					EndIf
				Else
					DeleteElement(*ObjectManager\lpObject())
				EndIf
			EndIf
		Next
		; Entfernung aus der lokalen Liste
		ForEach *Object\pParentFrame\lpChildObject()
			If *Object\pParentFrame\lpChildObject() = *Object
				DeleteElement(*Object\pParentFrame\lpChildObject())
			EndIf
		Next
		
		If *Object\iObject | $FFFF = $FFFF And ArraySize(EditorFactory\apObject()) >= *Object\iObject 
			EditorFactory\apObject(*Object\iObject) = #Null
		EndIf
		*Object\bFreed = #True
		PostObjectEvent(*ObjectManager, #EventType_Freed, *Object)
		PostRedrawEvent(*ObjectManager)
		;ChangeCurrentElement(EditorFactory\lObject(), *Object) ; Wait for events!
		;DeleteElement(EditorFactory\lObject())
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Creates and adds an object to the specified canvas object. ATTENTION: InitializeCanvasObjects() have to call before adding objects.
	;  iCanvasGadget:         PB Gadget number.
	;  iObject:               A self defined object number or #PB_Any to generate a unique number. The self defined number must be between 1 and 65535.
	;  iX, iY:                The position of the object.
	;  iWidth, iHeight:       The size of the object.
	;  iParentObject:         A valid object number to which the object should attached (optional). By default the object will be placed on the canvas frame.
	;  iFrameIndex:           An index of the frame (starting with 0) or one of the following constants, in which the object should attached (optional).
	;                          - #Frame_NoFrame:     The object will be attached to the non-indexed standard frame (frame for attachments).
	;                          - #Frame_ViewedFrame: The object will be attached to the currently shown indexed frame.
	;  Result:                The object number of the created object or 0 if creation failed. 
	;
	;  Crée et ajoute un Objet au Canevas spécifié. ATTENTION: InitializeCanvasObjects() doit être appelé avant d'ajouter des Objets à ce Canevas.
	;  iCanvasGadget:         PB Numéro du gadget Canevas.
	;  iObject:               Un Numéro de l'Objet auto-défini ou #PB_Any pour générer un numéro unique. Le nombre auto-défini doit être compris entre 1 et 65535.
	;  iX, iY:                La position de l'Objet sur le Canevas.
  ;  iWidth, iHeight:       La taille de l'Objet sur le Canevas.
	;	 iParentObject:         Un numéro d'objet valide auquel l'objet doit être rattaché (facultatif). Par défaut, l'objet sera placé sur le cadre de la toile.
	;  iFrameIndex:           Un index du cadre (commençant par 0) ou l'une des constantes suivantes, dans lequel l'objet doit être attaché (facultatif).
	;                          - #Frame_NoFrame:     L'objet sera attaché au cadre standard non indexé (cadre pour les pièces jointes).
  ;                          - #Frame_ViewedFrame: L'objet sera attaché au cadre indexé actuellement affiché.
	;  Résultat:              Le numéro d'objet de l'objet créé ou 0 si la création a échoué. 
	;}
	Procedure.i CreateObject(iCanvasGadget.i, iObject.i, iX.i, iY.i, iWidth.i, iHeight.i, iParentObject.i=#PB_Default, iFrameIndex.i=#Frame_NoFrame)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0)
		Protected *Object.Object, *Frame.Frame, *ParentObject.Object
		
		If iParentObject = #PB_Default
			*Frame = *ObjectManager\MainFrame
		Else
			_ObjectID_(*ParentObject, iParentObject, #False)
			_ObjectFrameID_(*Frame, *ParentObject, iFrameIndex, #False)
		EndIf
		
		If iObject= #PB_Any
			; Globale Liste
			LastElement(EditorFactory\lObject())
			*Object = AddElement(EditorFactory\lObject())
			; Canvas Liste
			LastElement(*ObjectManager\lpObject())
			AddElement(*ObjectManager\lpObject())
			*ObjectManager\lpObject() = *Object
			; Lokale Liste
			LastElement(*Frame\lpChildObject())
			AddElement(*Frame\lpChildObject())
			*Frame\lpChildObject() = *Object
			*Object\iObject = @EditorFactory\lObject()
		ElseIf iObject > 0 And iObject <= $FFFF
			; Globale Liste
			LastElement(EditorFactory\lObject())
			*Object = AddElement(EditorFactory\lObject())
			; Canvas Liste
			LastElement(*ObjectManager\lpObject())
			AddElement(*ObjectManager\lpObject())
			*ObjectManager\lpObject() = *Object
			; Lokale Liste
			LastElement(*Frame\lpChildObject())
			AddElement(*Frame\lpChildObject())
			*Frame\lpChildObject() = *Object
			*Object\iObject = iObject
			If ArraySize(EditorFactory\apObject()) < iObject 
				ReDim EditorFactory\apObject(iObject)
			ElseIf EditorFactory\apObject(iObject)
				FreeObject(iObject)
			EndIf
			EditorFactory\apObject(iObject) = *Object
		Else
			ProcedureReturn 0
		EndIf
		
		*Object\pParentFrame                   = *Frame
		If *Frame <> *ObjectManager\MainFrame 
			*Object\eAttachmentMode              = #Attachment_Position
		EndIf
		*Object\Boundaries                     = EditorFactory\DefaultObject\Boundaries
		*Object\iWidth                         = AdjustWidth(*Object, iWidth)
		*Object\iHeight                        = AdjustHeight(*Object, iHeight)
		*Object\iX                             = AdjustX(*Object, iX, *Object\iWidth)
		*Object\iY                             = AdjustY(*Object, iY, *Object\iHeight)
		*Object\eCursor                        = EditorFactory\DefaultObject\eCursor
		*Object\hCursorHandle                  = EditorFactory\DefaultObject\hCursorHandle
		*Object\eHandleDisplayMode             = EditorFactory\DefaultObject\eHandleDisplayMode
		*Object\pSelectionStyle                = EditorFactory\DefaultObject\pSelectionStyle
		*Object\pBoundaryStyle                 = EditorFactory\DefaultObject\pBoundaryStyle
		*Object\Grid                           = EditorFactory\DefaultObject\Grid
		*Object\eHandle                        = EditorFactory\DefaultObject\eHandle
		CopyArray(EditorFactory\DefaultObject\aHandle(), *Object\aHandle())
		*Object\pDrawingCallback               = EditorFactory\DefaultObject\pDrawingCallback
		*Object\iCallbackData                  = EditorFactory\DefaultObject\iCallbackData
		*Object\bDisjunct                      = #False
		*Object\pNoFrame                       = AddObjectFrame(*Object, #Frame_NoFrame)
		PostObjectEvent(*ObjectManager, #EventType_Created, *Object)
		PostRedrawEvent(*ObjectManager)
		
		ProcedureReturn *Object\iObject
		
	EndProcedure
	
	
	;{ Creates a duplicate of the specified object. The duplicate is located in the same parent frame/canvas gadget except a new canvas gadget is specified.
	;  iObject:               Object number of the object which should be duplicated.
	;  iNewObject:            A self defined object number or #PB_Any to generate a unique number. The self defined number must be between 1 and 65535.
	;  iNewCanvasGadget:      Canvas gadget number or #PB_Ignore if the new object is located in the same canvas gadget.
	;  bDuplicateChilds:      #True to duplicate also all child (attached) objects, otherwise #False. Duplicated childs will get automatically unique object numbers. 
	;  Result:                The object number of the new object or 0 if duplication failed. 
	;
	;  Crée un double de l'objet spécifié. Le double est situé dans le même cadre du canevas parent, sauf si un nouveau canevas est spécifié.
  ;  iObject:                Numéro de l'objet qui doit être dupliqué.
  ;  iNewObject:             Un numéro d'objet autodéfini ou #PB_Any pour générer un numéro unique. Le numéro autodéfini doit être compris entre 1 et 65535.
  ;  iNewCanvasGadget:       Numéro du canevas ou #PB_Ignore si le nouvel objet est situé dans le même canevas.
  ;  bDuplicateChilds:       #True pour dupliquer également tous les objets enfants (attachés), sinon #False. Les enfants dupliqués obtiendront automatiquement des numéros d'objet uniques.
  ;  Résultat:               Le numéro d'objet du nouvel objet ou 0 si la duplication a échoué.
	;}
	Procedure.i DuplicateObject(iObject.i, iNewObject.i, iNewCanvasGadget.i=#PB_Ignore, bDuplicateChilds.i=#True)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		Protected *NewObjectManager.ObjectManager
		Protected *NewFrame.Frame
		Protected *NewObject.Object, iChildObject.i
		
		If iNewCanvasGadget = #PB_Ignore
			*NewFrame = *Object\pParentFrame
			*NewObjectManager = *Object\pParentFrame\pObjectManager
		Else
			_ObjectManagerID_(*NewObjectManager, iNewCanvasGadget, 0)
			*NewFrame = *NewObjectManager\MainFrame
		EndIf
		
		If iNewObject = iObject
			Debug "EditorFactory.DuplicateObject: Duplicated object number ("+iNewObject+") cann't be the number of the object to duplicate ("+iObject+")."
			ProcedureReturn 0
		EndIf
		
		If iNewObject= #PB_Any
			; Globale Liste
			LastElement(EditorFactory\lObject())
			*NewObject = AddElement(EditorFactory\lObject())
			CopyStructure(*Object, *NewObject, Object)
			; Canvas Liste
			LastElement(*NewObjectManager\lpObject())
			AddElement(*NewObjectManager\lpObject())
			*NewObjectManager\lpObject() = *NewObject
			; Lokale Liste
			LastElement(*NewFrame\lpChildObject())
			AddElement(*NewFrame\lpChildObject())
			*NewFrame\lpChildObject() = *NewObject
			*NewObject\iObject = @EditorFactory\lObject()
		ElseIf iNewObject > 0 And iNewObject <= $FFFF
			; Globale Liste
			LastElement(EditorFactory\lObject())
			*NewObject = AddElement(EditorFactory\lObject())
			CopyStructure(*Object, *NewObject, Object)
			; Canvas Liste
			LastElement(*NewObjectManager\lpObject())
			AddElement(*NewObjectManager\lpObject())
			*NewObjectManager\lpObject() = *NewObject
			; Lokale Liste
			LastElement(*NewFrame\lpChildObject())
			AddElement(*NewFrame\lpChildObject())
			*NewFrame\lpChildObject() = *NewObject
			*NewObject\iObject = iNewObject
			If ArraySize(EditorFactory\apObject()) < iNewObject 
				ReDim EditorFactory\apObject(iNewObject)
			ElseIf EditorFactory\apObject(iNewObject)
				FreeObject(iNewObject)
			EndIf
			EditorFactory\apObject(iNewObject) = *NewObject
		Else
			ProcedureReturn 0
		EndIf
		
		ForEach *NewObject\lFrame()
			*NewObject\lFrame()\pObjectManager = *NewObjectManager
			*NewObject\lFrame()\pParentObject  = *NewObject
			ClearList(*NewObject\lFrame()\lpChildObject())
		Next
		
		If *Object\pBoundaryStyle <> @EditorFactory\DefaultObject\pBoundaryStyle
			*NewObject\pBoundaryStyle = AddElement(EditorFactory\lObjectStyle())
			CopyStructure(*Object\pBoundaryStyle, *NewObject\pBoundaryStyle, ObjectStyle)
		EndIf
		If *Object\pSelectionStyle <> @EditorFactory\DefaultObject\pSelectionStyle
			*NewObject\pSelectionStyle = AddElement(EditorFactory\lObjectStyle())
			CopyStructure(*Object\pSelectionStyle, *NewObject\pSelectionStyle, ObjectStyle)
		EndIf
		*NewObject\pParentFrame = *NewFrame
		*NewObject\pNoFrame     = FirstElement(*NewObject\lFrame())
		If *Object\pVisibleFrame
			ChangeCurrentElement(*Object\lFrame(), *Object\pVisibleFrame)
			*NewObject\pVisibleFrame = SelectElement(*NewObject\lFrame(), ListIndex(*Object\lFrame()))
		EndIf
		
		If bDuplicateChilds
			ForEach *Object\lFrame()
				ForEach *Object\lFrame()\lpChildObject()
					iChildObject = DuplicateObject(*Object\lFrame()\lpChildObject(), #PB_Any, iNewCanvasGadget, #True)
					AttachObject(iChildObject, *NewObject, #Attachment_Position, ListIndex(*Object\lFrame()))
				Next
			Next
		EndIf
		
		PostObjectEvent(*NewObjectManager, #EventType_Created, *NewObject)
		PostRedrawEvent(*NewObjectManager)
		
		ProcedureReturn *NewObject\iObject
		
	EndProcedure
	
	
	;{ Adds a new object frame the the object.
	;  iObject:               Object number.
	;  iFrameIndex:           Index (starting with 0), at which the frame should be insert. #Frame_LastFrame can be used to add the frame to the end of all frames.
	;                         This new frame will be automatically set as the current visible frame.
	;  iViewBoxX:             Local X-position of the clipping for inner child objects. 0 means that the clipping is exactly at the edge of the object.
	;  iViewBoxY:             Local Y-position of the clipping for inner child objects. 0 means that the clipping is exactly at the edge of the object.
	;  iViewBoxWidth:         Width of the clipping area for inner child objects. Add #Boundary_ParentSize to a value (#Boundary_ParentSize ± value) to make the width relative to the object size.
	;  iViewBoxHeight:        Height of the clipping area for inner child objects. Add #Boundary_ParentSize to a value (#Boundary_ParentSize ± value) to make the height relative to the object size.
	;  Result:                The index of the new added frame, or -1 in case of a failure.
	;
	;  Ajoute un nouveau cadre à l'objet.
	;  iObject:               Numéro de l'objet.
	;  iFrameIndex:           Index (commençant par 0), auquel la trame doit être insérée. #Frame_LastFrame peut être utilisé pour ajouter le cadre à la fin de tous les cadres.
  ;                         Ce nouveau cadre sera automatiquement défini comme le cadre visible actuel.
	;  iViewBoxX:             Position X locale de l'écrêtage pour les objets enfants internes. 0 signifie que l'écrêtage se trouve exactement au bord de l'objet.
	;  iViewBoxY:             Position Y locale de l'écrêtage pour les objets enfants internes. 0 signifie que l'écrêtage se trouve exactement au bord de l'objet.
	;  iViewBoxWidth:         Largeur de la zone d'écrêtage pour les objets enfants internes. Ajoutez #Boundary_ParentSize à une valeur (#Boundary_ParentSize ± valeur) pour que la largeur soit relative à la taille de l'objet.
	;  iViewBoxHeight:        Hauteur de la zone d'écrêtage pour les objets enfants internes. Ajoutez #Boundary_ParentSize à une valeur (#Boundary_ParentSize ± valeur) pour que la hauteur soit relative à la taille de l'objet.
	;  Résultat:              L'index de la nouvelle trame ajoutée, ou -1 en cas d'échec.
	;}
	Procedure.i AddObjectFrame(iObject.i, iFrameIndex.i, iViewBoxX.i=0, iViewBoxY.i=0, iViewBoxWidth.i=#Boundary_ParentSize, iViewBoxHeight.i=#Boundary_ParentSize, iInnerWidth.i=#Boundary_None, iInnerHeight.i=#Boundary_None, iInnerOffsetX.i=0, iInnerOffsetY.i=0)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, -1)
		Protected *Frame.Frame, iResult.i
		
		If iFrameIndex = #Frame_NoFrame And ListSize(*Object\lFrame()) = 0
			*Frame = AddElement(*Object\lFrame())
			*Object\pNoFrame = *Frame
			iResult = *Frame
		ElseIf iFrameIndex >= 0 And iFrameIndex < ListSize(*Object\lFrame())-1
			SelectElement(*Object\lFrame(), iFrameIndex+1)
			*Frame = AddElement(*Object\lFrame())
			*Object\pVisibleFrame = *Frame
			iResult = iFrameIndex
		Else
			LastElement(*Object\lFrame())
			*Frame = AddElement(*Object\lFrame())
			*Object\pVisibleFrame = *Frame
			iResult = ListIndex(*Object\lFrame()) - 1
		EndIf
		
		With *Frame
			\pParentObject     = *Object
			\pObjectManager    = *Object\pParentFrame\pObjectManager
			\ViewBox\bEnabled  = #True
			\ViewBox\iX        = iViewBoxX
			\ViewBox\iY        = iViewBoxY
			\ViewBox\iWidth    = iViewBoxWidth
			\ViewBox\iHeight   = iViewBoxHeight
			\InnerArea\iWidth  = iInnerWidth
			\InnerArea\iHeight = iInnerHeight
			\InnerArea\iX      = iInnerOffsetX
			\InnerArea\iY      = iInnerOffsetY
		EndWith
		
		ProcedureReturn iResult
		
	EndProcedure
	
	
	;{ Removes an object frame togerther with all their child objects.
	;  iObject:               Object number.
	;  iFrameIndex:           An index of the frame (starting with 0) which should be removed.
  ;  Result:                #True, if freeing succeeded, otherwise #False.
	;
	;  Supprime un cadre d'objet avec tous les objets enfants qui y sont.
	;  iObject:               Numéro de l'objet.
	;  iFrameIndex:           Un index de la trame (commençant par 0) qui doit être supprimé.
	;  Résultat:              #True, si la libération a réussi, sinon #False.
	;}
	Procedure.i RemoveObjectFrame(iObject.i, iFrameIndex.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		
		If iFrameIndex >= 0 And iFrameIndex < ListSize(*Object\lFrame()) - 1
			SelectElement(*Object\lFrame(), iFrameIndex+1)
			ForEach *Object\lFrame()\lpChildObject()
				FreeObject(*Object\lFrame()\lpChildObject(), #Object_FreeChildObjects)
			Next
			*Object\pVisibleFrame = DeleteElement(*Object\lFrame())
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
		
	EndProcedure
	
	
	;{ Moves an object frame to another index and optionally also to another object.
	;  iObject:               Object number.
	;  iFrameIndex:           An index of the frame (starting with 0) or #Frame_ViewedFrame which should be moved.
	;  iNewFrameIndex:        The index (starting with 0), at which the frame should be insert. #Frame_LastFrame can be used to add the frame to the end of all frames.
	;  iNewObject:            The new object number. In case of #PB_Ignore, the frame keeps it parent object.
  ;  Result:                The index of the new added frame, or -1 in case of a failure.
	;
	;  Déplace une trame d'objet vers un autre index et éventuellement aussi vers un autre objet.
	;  iObject:               Numéro de l'objet.
	;  iFrameIndex:           Un index de la trame (commençant par 0) ou utilisez #Frame_ViewedFrame pour déplacée la trame visible actuellement.
	;  iNewFrameIndex:        L'index (commençant par 0), auquel la trame doit être insérée. #Frame_LastFrame peut être utilisé pour ajouter le cadre à la fin de tous les cadres.
	;  iNewObject:            Le numéro du nouvel objet. Dans le cas de #PB_Ignore, la trame conserve son objet parent.
	;  Résultat :             L'index de la nouvelle trame ajoutée, ou -1 en cas d'échec.
	;}
	Procedure.i MoveObjectFrame(iObject.i, iFrameIndex.i, iNewFrameIndex.i, iNewObject.i=#PB_Ignore)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, -1)
		Protected *Frame.Frame   : _ObjectFrameID_(*Frame, *Object, iFrameIndex, -1)
		Protected *NewObject.Object = *Object
		Protected *Position, *TempObject.Object
		
		If iNewObject = #PB_Ignore
			
			If iNewFrameIndex >= 0 And iNewFrameIndex < ListSize(*NewObject\lFrame())-1
				*Position = SelectElement(*Object\lFrame(), iNewFrameIndex + 1)
				ChangeCurrentElement(*Object\lFrame(), *Frame)
				MoveElement(*Object\lFrame(), #PB_List_Before, *Position)
			Else
				ChangeCurrentElement(*Object\lFrame(), *Frame)
				MoveElement(*Object\lFrame(), #PB_List_Last)
			EndIf
			ProcedureReturn ListIndex(*Object\lFrame()) - 1
			
		Else
			
			_ObjectID_(*NewObject, iNewObject, -1)
			If AddObjectFrame(iNewObject, iNewFrameIndex) <> -1
				*NewObject\lFrame()\pObjectManager = *Frame\pObjectManager
				*NewObject\lFrame()\pParentObject  = *Frame\pParentObject
				CopyList(*Frame\lpChildObject(), *NewObject\lFrame()\lpChildObject())
				ForEach *NewObject\lFrame()\lpChildObject()
					*TempObject = *NewObject\lFrame()\lpChildObject()
					*TempObject\pParentFrame = *NewObject\lFrame()
				Next
				*Object\pVisibleFrame = DeleteElement(*Object\lFrame())
				ProcedureReturn ListIndex(*NewObject\lFrame()) - 1
			EndIf
			
		EndIf
		
	EndProcedure
	
	
	;{ Adds a standard or custom handle to the specified object. Custom handles can have an alignment and a position offset.
	;  iObject:          Object number or one of the following constants:
	;                     - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                     - #Object_All      : Iterates through all objects in sequence.
	;                     - #Object_Selected : Iterates through all selected objects in sequence.
	;  eType:            A combination of all handle type which have to added. *
	;  iImage:           An image number for the handle. By default (#PB_Default) the default handle image is used.
	;  eAlignment:       The alignment of the custom handle. By default this is #Alignment_Default = #Alignment_Center **
	;  iX, iY:           The offset position of the handle with respect to the alignment and the object.
	;  Result:           #True, if adding succeeded, otherwise #False.
	;
	;                  * The following handle types can used and combined:
	;                    #Handle_Position:  A handle over the whole object to move them.
	;                    #Handle_Rotation:  A handle to rotate the object. (NOT IN USE).
	;                    #Handle_BottomLeft, _Bottom, _BottomRight, _Left, _Right, _TopLeft, _Top, _TopRight:  A handle To size the object in this direction.
	;                    #Handle_Custom1 ... #Handle_Custom8:  A custom handle.
	;
	;                    Furthermore, the following constants are predefined combinations:
	;                    #Handle_Width  = #Handle_Left | #Handle_Right.
	;                    #Handle_Height = #Handle_Top | #Handle_Bottom.
	;                    #Handle_Edge   = #Handle_Width | #Handle_Height.
	;                    #Handle_Corner = #Handle_BottomLeft | #Handle_BottomRight | #Handle_TopLeft | #Handle_TopRight.
	;                    #Handle_Size   = #Handle_Edge | #Handle_Corner.
	;
	;                 ** The following alignment types can used and combined:
	;                    #Alignment_Top:     Aligns the handle center to the top border of the object.
	;                    #Alignment_Bottom:  Aligns the handle center to the bottom border of the object.
	;                    #Alignment_Left:    Aligns the handle center to the left border of the object.
	;                    #Alignment_Right:   Aligns the handle center to the right border of the object.
	;                    #Alignment_Center:  Aligns the handle center to the center (x and/or y) of the object.
	;
	;  Ajoute une ou plusieurs poignée standard ou personnalisée à l'Objet spécifié. Les poignées personnalisées peuvent avoir un alignement et un décalage de position.
  ;  iObject:          Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                     - #Object_Default: Définie les poignées par defaut de tous les nouveaux objets créé.
	;                     - #Object_All: Définie les poignées de tous les objets.
	;                     - #Object_Selected: Définie les poignées de tous les objets sélectionnés.
	;  eType:            Une combinaison de tous les types de poignées qu'il faut ajouter. *
	;  iImage:           Un numéro d'image pour la poignée. Par défaut (#PB_Default) l'image par défaut de la poignée est utilisée.
	;  eAlignment:       L'alignement de la poignée personnalisée. Par défaut c'est #Alignment_Default = #Alignment_Center **
	;  iX, iY:           Position décalée de la poignée par rapport à l'alignement et à l'Objet.
	;  Resulta:          Renvoie #True, si l'ajout de la poignée a réussi, sinon #False.
	;                  
	;                  * Les types de poignées suivantes peuvent être utilisés et combinés:
	;                    #Handle_Position:  Une poignée pour déplacer l'Objet.
	;                    #Handle_Rotation:  Une poignée pour faire tourner l'Objet. (NON UTILISÉ).
	;                    #Handle_BottomLeft, #Handle_Bottom, #Handle_BottomRight, #Handle_Left, #Handle_Right, #Handle_TopLeft, #Handle_Top, #Handle_TopRight:  Une poignée Pour redimensionner l'Objet dans cette direction.
	;                    #Handle_Custom1 ... #Handle_Custom8: Une poignée personnalisée:
	;                    
	;                    En outre, les constantes suivantes sont des combinaisons prédéfinies:
	;                    #Handle_Width  = #Handle_Left | #Handle_Right.
	;                    #Handle_Height = #Handle_Top | #Handle_Bottom.
	;                    #Handle_Edge   = #Handle_Width | #Handle_Height.
	;                    #Handle_Corner = #Handle_BottomLeft | #Handle_BottomRight | #Handle_TopLeft | #Handle_TopRight.
	;                    #Handle_Size   = #Handle_Edge | #Handle_Corner.
	;                 
	;                 ** Les types d'alignement suivants peuvent être utilisés et combinés:
	;                    #Alignment_Top:     Aligne le centre de la poignée sur le bord supérieur de l'Objet.
	;                    #Alignment_Bottom:  Aligne le centre de la poignée sur le bord inférieur de l'Objet.
	;                    #Alignment_Left:    Aligne le centre de la poignée sur le bord gauche de l'Objet.
	;                    #Alignment_Right:   Aligne le centre de la poignée sur le bord droit de l'Objet.
	;                    #Alignment_Center:  Aligne le centre de la poignée sur le centre (x et/ou y) de l'Objet.
	;}
	Procedure.i AddObjectHandle(iObject.i, eType.i, iImage.i=#PB_Default, eAlignment.i=#Alignment_Default, iX.i=0, iY.i=0)
		
		Protected *Object.Object
		Protected iIndex.i, bResult.i = #False
		
		If iImage = #PB_Default Or IsImage(iImage) = #False
			iImage = EditorFactory\iDefaultHandleImage
		EndIf
		
		While _ExObjectID_(@*Object, iObject)
			
			*Object\eHandle | eType
			For iIndex = 0 To #LastHandle
				If eType & (1<<iIndex)
					*Object\aHandle(iIndex)\iImage     = iImage
					*Object\aHandle(iIndex)\iImageID   = ImageID(iImage)
					*Object\aHandle(iIndex)\iWidth     = ImageWidth(iImage)
					*Object\aHandle(iIndex)\iHeight    = ImageHeight(iImage)
					If eAlignment = #Alignment_Default
						*Object\aHandle(iIndex)\eAlignment = PeekI(?DefaultAlignment+iIndex*SizeOf(Integer))
					Else
						*Object\aHandle(iIndex)\eAlignment = eAlignment
					EndIf
					*Object\aHandle(iIndex)\iX         = iX
					*Object\aHandle(iIndex)\iY         = iY
					*Object\aHandle(iIndex)\eCursor    = PeekI(?DefaultCursor+iIndex*SizeOf(Integer))
				EndIf
			Next
			
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
			bResult = #True
			
		Wend
		
		ProcedureReturn bResult
		
		DataSection
			DefaultAlignment:
			Data.i #Alignment_Center|#Alignment_Middle
			Data.i #Alignment_Left|#Alignment_Bottom, #Alignment_Center|#Alignment_Bottom, #Alignment_Right|#Alignment_Bottom
			Data.i #Alignment_Left|#Alignment_Middle, #Alignment_Center|#Alignment_Middle, #Alignment_Right|#Alignment_Middle
			Data.i #Alignment_Left|#Alignment_Top,    #Alignment_Center|#Alignment_Top,    #Alignment_Right|#Alignment_Top
			Data.i #Alignment_Center|#Alignment_Middle, #Alignment_Center|#Alignment_Middle, #Alignment_Center|#Alignment_Middle, #Alignment_Center|#Alignment_Middle
			Data.i #Alignment_Center|#Alignment_Middle, #Alignment_Center|#Alignment_Middle, #Alignment_Center|#Alignment_Middle, #Alignment_Center|#Alignment_Middle
			DefaultCursor:
			Data.i #PB_Cursor_Arrows
			Data.i #PB_Cursor_LeftDownRightUp, #PB_Cursor_UpDown, #PB_Cursor_LeftUpRightDown
			Data.i #PB_Cursor_LeftRight, #PB_Cursor_Hand, #PB_Cursor_LeftRight
			Data.i #PB_Cursor_LeftUpRightDown, #PB_Cursor_UpDown, #PB_Cursor_LeftDownRightUp
			Data.i #PB_Cursor_Hand, #PB_Cursor_Hand, #PB_Cursor_Hand, #PB_Cursor_Hand
			Data.i #PB_Cursor_Hand, #PB_Cursor_Hand, #PB_Cursor_Hand, #PB_Cursor_Hand
		EndDataSection
		
	EndProcedure
	
	
	;{ Removes handles from the specified object.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. (Is needed, if you want to remove a handle from the default layout)
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  eType:                 A combination of all handle type or which have to removed or use #Handle_All to remove all.*
	;  Result:                #True, if removing succeeded, otherwise #False.
	;                         * See AddObjectHandle().
	;
	;  Enlève la poignée de l'Objet spécifié.
  ;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                         - #Object_Default:  Supprime les poignées par defaut de tous les nouveaux objets créé. (Nécessaire, si vous voulez supprimer un objet de la mise en page par défaut)
	;                         - #Object_All: Supprime les poignées de tous les objets.
	;                         - #Object_Selected: Supprime les poignées de tous les objets sélectionnés.
	;  eType:                 Une combinaison de tous les types de poignées qui doivent être retirées ou utilisez #Handle_All pour toutes les enlever *.
	;  Result:                #True, si le retrait a réussi, Sinon #False.
	;                         * Voir AddObjectHandle().
	;}
	Procedure.i RemoveObjectHandle(iObject.i, eType.i)
		
		Protected *Object.Object, bResult.i = #False
		
		While _ExObjectID_(@*Object, iObject)
			
			*Object\eHandle & ~eType
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			bResult = #True
			
		Wend
		
		ProcedureReturn bResult
		
	EndProcedure
	
	
	;{ Change the mode of showing the handles of the object or all objects in the specified canvas.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  eMode:                 A combination of the following constants:
	;                          - #Handle_ShowIfHovered:     Show the handles if the mouse is over the object.
	;                          - #Handle_ShowIfSelected:    Show the handles if the object is selected.
	;                          - #Handle_ShowAlways:        Show the handles always.
	;  iCanvasGadget:         Canvas gadget number to restrict #Object_All or #Object_Selected to the specified gadget or #PB_Ignore to allow all gadgets.
	;  Result:                #True, if succeeded, otherwise #False.
	;
	;  Change le mode d'affichage des poignées de l'Objets du Canevas specifié ou tous les Objets dans le Canevas spésifié.
	;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Change l'affichage des poignées de tous les nouveaux objets créé.
	;                          - #Object_All: Change l'affichage des poignées de tous les objets.
	;                          - #Object_Selected: Change l'affichage des poignées de tous les objets sélectionnés.
	;  eMode:                 Une des constantes suivantes:
	;                          - #Handle_ShowIfHovered:     Afficher les poignées si la souris est sur l'Objet.
	;                          - #Handle_ShowIfSelected:    Afficher les poignées si l'Objet est sélectionné.
	;                          - #Handle_ShowAlways:        Toujours afficher les poignées.
	;  iCanvasGadget:         Numéro du Canevas gadget, nécessaire uniquement si iObject est défini sur #PB_All.
	;  Résultat:              #True, si réussi, Sinon #False.
	;}
	Procedure.i ObjectHandleDisplayMode(iObject.i, eMode.i, iCanvasGadget.i=#PB_Ignore)
		
		Protected *Object.Object, bResult.i = #False
		
		While _ExObjectID_(@*Object, iObject, iCanvasGadget)
			
			*Object\eHandleDisplayMode = eMode
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			bResult = #True
			
		Wend
		
		ProcedureReturn bResult
		
	EndProcedure
	
	
	;{ Creates a custom cursor from an image. This function is to be used for customizing the mouse cursor image for the objects, the object handles and for the canvas.
	;  iImage:                A valid image number.
	;  iHotSpotX:             Adjustment X-position of the image in relation to the mouse cursor.
	;  iHotSpotY:             Adjustment Y-position of the image in relation to the mouse cursor.
	;  Result:                An operation system specific handle to the cursor.
	;
	;  Crée un curseur personnalisé à partir d'une image. Cette fonction doit être utilisée pour personnaliser l'image du curseur de la souris pour les objets, les poignées d'objets et pour la toile.
	;  iImage:                Un numéro d'image valide.
	;  iHotSpotX:             Ajustement de la position X de l'image par rapport au curseur de la souris.
	;  iHotSpotY:             Ajustement de la position Y de l'image par rapport au curseur de la souris.
	;  Résultat:              Un Handle spécifique au système d'exploitation pour le curseur.
	;}
	Procedure.i CreateCustomCursor(iImage.i, iHotSpotX.i=0, iHotSpotY.i=0)
		
		; https://www.purebasic.fr/english/viewtopic.php?p=558816#p558816
		
		Protected hCursor.i
		
		CompilerSelect #PB_Compiler_OS
			CompilerCase #PB_OS_Linux
				hCursor = gdk_cursor_new_from_pixbuf_(gdk_display_get_default_(), ImageID(iImage), iHotSpotX, iHotSpotY)
			CompilerCase #PB_OS_MacOS
				Protected Hotspot.NSPoint
				Hotspot\x = iHotSpotX
				Hotspot\y = iHotSpotY
				hCursor = CocoaMessage(0, 0, "NSCursor alloc")
				CocoaMessage(0, hCursor, "initWithImage:", ImageID(iImage), "hotSpot:@", @Hotspot)
			CompilerCase #PB_OS_Windows
				Protected Icon.ICONINFO
				Icon\fIcon    = #False
				Icon\xHotspot = iHotSpotX
				Icon\yHotspot = iHotSpotY
				Icon\hbmColor = ImageID(iImage)
				Icon\hbmMask  = ImageID(iImage)
				hCursor = CreateIconIndirect_(Icon)
		CompilerEndSelect
		
		ProcedureReturn hCursor
		
	EndProcedure
	
	
	;{ Frees a custom cursor.
  ;  hCursorHandle:         A valid operation system specific cursor handle.
	;
	;  Libère un curseur personnalisé.
	;  hCursorHandle:         Un Handle de curseur spécifique à un système d'exploitation valide.
	;}
	Procedure   FreeCustomCursor(hCursorHandle.i)
		
		; https://www.purebasic.fr/english/viewtopic.php?p=558816#p558816
		
		CompilerSelect #PB_Compiler_OS
			CompilerCase #PB_OS_Linux
				g_object_unref_(hCursorHandle)
			CompilerCase #PB_OS_MacOS
				CocoaMessage(0, hCursorHandle, "release")
			CompilerCase #PB_OS_Windows
				DestroyCursor_(hCursorHandle)
		CompilerEndSelect
			
	EndProcedure
	
	
	;{ Gives the number of the parent object, if the object is attached.
	;  iObject:               Object number.
	;  Result:                The number of the parent object, or #Null, if the object is not attached.
	;
	;  Donne le numéro de l'objet parent, si l'objet est attaché.
	;  iObject :               Numéro de l'objet.
	;  Résultat :              Le numéro de l'objet parent, ou #Null, si l'objet n'est pas attaché.
	;}
	Procedure.i ParentObject(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #Null)
		
		If *Object\pParentFrame\pParentObject
			ProcedureReturn *Object\pParentFrame\pParentObject\iObject
		EndIf
		
	EndProcedure
	
	
	;{ Gives the number of currently visible frame of the object.
	;  iObject:               Object number.
	;  Result:                The inedx of the frame starting with 0, or -1 if not frame exists.
	;
	;  Donne le nombre de frame actuellement visibles de l'obje conteneur.
	;  iObjet :               Numéro de l'objet.
	;  Résultat :             L'inedx de la trame commençant par 0, ou -1 si aucune trame n'existe.
	;}
	Procedure.i VisibleObjectFrame(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #Null)
		Protected iIndex.i = -1
		
		PushListPosition(*Object\lFrame())
		If *Object\pVisibleFrame
			ChangeCurrentElement(*Object\lFrame(), *Object\pVisibleFrame)
			iIndex = ListIndex(*Object\lFrame()) - 1
		EndIf
		PopListPosition(*Object\lFrame())
		
		ProcedureReturn iIndex
		
	EndProcedure
	
	
	;- Actions
	
	
	;{ Attaches the specified object to another object as child.
	;  iObject:               Object number.
	;  iParentObject:         Object number to the parent object, to which the object become a child.
	;  eMode:                 A combination of the following constants:
	;                          - #Attachment_X:                      The X position is attached to the parent object
	;                          - #Attachment_Y:                      The Y position is attached to the parent object
	;                          - #Attachment_Position:               Both, X and Y position, is attached to the parent object
	;                          - #Attachment_PreserveGlobalPosition: The global position of the object will be maintained, otherwise the local position is adopted.
	;  iFrameIndex:           An index of the frame (starting with 0) or one of the following constants, in which the object should attached (optional).
	;                          - #Frame_NoFrame:     The object will be attached to the non-indexed standard frame (frame for attachments).
	;                          - #Frame_ViewedFrame: The object will be attached to the currently shown indexed frame.
	;  Result:                #True if the attachment succeeded, otherwise #False.
	;
	;  Attache l'objet spécifié à un autre objet en tant qu'enfant.
	;  iObject:               Numéro de l'objet.
	;  iParentObject:         Numéro d'objet de l'objet parent, auquel l'objet devient un enfant.
	;	 eMode:                 Une combinaison des constantes suivantes:
	;                          - #Attachment_X: La position X est attachée à l'objet parent.
	;                          - #Attachment_Y: la position Y est attachée à l'objet parent.
	;                          - #Attachment_Position: Les deux positions, X et Y, sont attachées à l'objet parent.
	;                          - #Attachment_PreserveGlobalPosition: La position globale de l'objet sera maintenue, sinon la position locale est adoptée.
	;  iFrameIndex:           Un index du cadre (commençant par 1) ou l'une des constantes suivantes, dans lequel l'objet doit être attaché (facultatif).
	;                          - #Frame_NoFrame:     L'objet sera attaché au cadre standard non indexé (cadre pour les pièces jointes).
  ;                          - #Frame_ViewedFrame: L'objet sera attaché au cadre indexé actuellement affiché.
	;  Result:                #True si l'attachement a réussi, sinon #False.
	;}
	Procedure.i AttachObject(iObject.i, iParentObject.i, eMode.i=#Attachment_Position|#Attachment_PreserveGlobalPosition, iFrameIndex.i=#Frame_NoFrame)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		Protected *ParentObject.Object : _ObjectID_(*ParentObject, iParentObject, #False)
		Protected *Frame.Frame : _ObjectFrameID_(*Frame, *ParentObject, iFrameIndex)
		Protected *TempObject.Object
		
		; Zirkulare Hirachie?
		*TempObject = *ParentObject
		While *TempObject
			If *TempObject = *Object
				Debug "EditorFactory.AttachObject: Circular hierarchy reference detected. Attaching Object "+iObject+" to "+iParentObject+" not possible."
				ProcedureReturn #False
			EndIf
			*TempObject = *TempObject\pParentFrame\pParentObject
		Wend
		
		ForEach *Object\pParentFrame\lpChildObject()
			If *Object\pParentFrame\lpChildObject() = *Object
				DeleteElement(*Object\pParentFrame\lpChildObject())
			EndIf
		Next
		
		*Object\pParentFrame    = *Frame
		*Object\eAttachmentMode = eMode & (#Attachment_Position|#Attachment_Size)
		LastElement(*Object\pParentFrame\lpChildObject())
		AddElement(*Object\pParentFrame\lpChildObject())
		*Object\pParentFrame\lpChildObject() = *Object
		
		If eMode & #Attachment_PreserveGlobalPosition
			*Object\iX - GlobalX(*Object, 0)
			*Object\iY - GlobalY(*Object, 0)
		EndIf
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Detachs the specified object from its parent object.
	;  iObject:               Object number.
	;  eMode:                 A combination of the following constants:
	;                         - #Attachment_PreserveGlobalPosition: The global position of the object will be maintained, otherwise the local position is used.
	;  Result:                #True if the detachment succeeded, otherwise #False.
	;
	;  Détache l'objet spécifié de son objet parent.
	;  iObject:               Numéro de l'objet.
	;  eMode:                 Une combinaison des constantes suivantes:
	;                         - #Attachment_PreserveGlobalPosition: La position globale de l'objet sera conservée, sinon la position locale est utilisée.
	;  Résultat:              #Vrai si le détachement a réussi, Sinon #Faux.
	;}
	Procedure.i DetachObject(iObject.i, eMode.i=#Attachment_PreserveGlobalPosition)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		
		If eMode & #Attachment_PreserveGlobalPosition
			*Object\iX + GlobalX(*Object, 0)
			*Object\iY + GlobalY(*Object, 0)
		EndIf
		
		ForEach *Object\pParentFrame\lpChildObject()
			If *Object\pParentFrame\lpChildObject() = *Object
				DeleteElement(*Object\pParentFrame\lpChildObject())
			EndIf
		Next
		*Object\pParentFrame    = *Object\pParentFrame\pObjectManager\MainFrame
		*Object\eAttachmentMode = #Null
		LastElement(*Object\pParentFrame\lpChildObject())
		AddElement(*Object\pParentFrame\lpChildObject())
		*Object\pParentFrame\lpChildObject() = *Object
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	; NOT IN USE !
	Procedure.i ConnectObjects(iObject1.i, iObject2.i)
		
		Protected *Object1.Object : _ObjectID_(*Object1, iObject1, #False)
		Protected *Object2.Object : _ObjectID_(*Object2, iObject2, #False)
		
		Repeat
			ForEach *Object1\lpConnectedObject()
				If *Object1\lpConnectedObject() = *Object2
					Break 2
				EndIf
			Next
			AddElement(*Object1\lpConnectedObject())
			*Object1\lpConnectedObject() = *Object2
		Until #True
		Repeat
			ForEach *Object2\lpConnectedObject()
				If *Object2\lpConnectedObject() = *Object1
					Break 2
				EndIf
			Next
			AddElement(*Object2\lpConnectedObject())
			*Object2\lpConnectedObject() = *Object1
		Until #True
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Changes the viewed frame of an object.
	;  iObject:               Object number.
	;  iFrameIndex:           Index of the frame, started with 0.
	;
	;  Modifie la frame affiché d'un objet.
	;  iObjet :               Numéro de l'objet.
	;  iFrameIndex :          Index de la frame, commençant par 0.
	;}
	Procedure   ShowObjectFrame(iObject.i, iFrameIndex.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject)
		
		If iFrameIndex >= 0 And iFrameIndex < ListSize(*Object\lFrame()) - 1
			*Object\pVisibleFrame = SelectElement(*Object\lFrame(), iFrameIndex+1)
			PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		EndIf
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Give the number of frame in the object.
	;  iObject:               Object number.
	;  Result:                The number of frames, or 0 if no frame is present or the object number is invalid.
	;
	;  Renvoie le nombre de framess que contient l'objet.
	;  iObjet :               Numéro de l'objet.
	;  Résultat :             Le nombre de frame, ou 0 si aucune framle n'est présente ou si le numéro de l'objet n'est pas valide.
	;}
	Procedure.i CountObjectFrames(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject)
		
		ProcedureReturn ListSize(*Object\lFrame()) - 1
		
	EndProcedure
	
	
	;{ Selects the specified object or all objects in the specified canvas.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_All: Iterates through all objects in sequence.
	;  iCanvasGadget:         Canvas gadget number to restrict #Object_All to the specified gadget, or #PB_Ignore to allow all gadgets.
	;
	;  Sélectionne l'Objet spécifié ou tous les Objets du Canevas spécifié.
	;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_All: Selectionne tous les objets.
  ;  iCanvasGadget:         Numéro du canevas pour restraindre la selection des Objets seulement à ce canevas, ou #PB_Ignore pour autoriser la selection de n'importe quel objets peut importe ou il ce trouve.
	;}
	Procedure   SelectObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
		
		Protected *Object.Object
		
		While _ExObjectID_(@*Object, iObject, iCanvasGadget)
		
			*Object\bSelected = #True
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
		Wend
		
	EndProcedure
	
	
	;{ Unselects the specified object or all objects in the specified canvas.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  iCanvasGadget:         Canvas gadget number to restrict #Object_All or #Object_Selected to the specified gadget, or #PB_Ignore to allow all gadgets.
	;
	;  Désélectionne l'Objet spécifié ou tous les Objets du Canevas spécifié.
  ;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_All: Deselectionne tous les objets.
	;                          - #Object_Selected: Deselectionne tous les objets sélectionnés.
  ;  iCanvasGadget:         Numéro du canevas pour restraindre la Deselection seulement à ce canevas, ou #PB_Ignore pour autoriser la Deselection de tous les objets peut importe ou il ce trouve.
	;}
	Procedure   UnselectObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
		
		Protected *Object.Object
		
		While _ExObjectID_(@*Object, iObject, iCanvasGadget)
		
			*Object\bSelected = #False
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
		Wend
		
	EndProcedure
	
	
	;{ Hide the specified object or all objects in the specified canvas.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects.
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  iCanvasGadget:         Canvas gadget number to restrict #Object_All or #Object_Selected to the specified gadget, or #PB_Ignore to allow all gadgets.
	;
	;  Cache l'Objet spécifié ou tous les Objets dans le Canevas spécifiée.
	;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Cache par defaut les nouveaux objets créé.
	;                          - #Object_All: Cache tous les objets.
	;                          - #Object_Selected: Cache tous les objets sélectionnés.
	;  iCanvasGadget:         Numéro du canevas pour Cacher seulement les Objets de ce canevas, ou #PB_Ignore pour Cacher n'importe quel objets peut importe ou il ce trouve.
	;}
	Procedure   HideObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
		
		Protected *Object.Object
		
		While _ExObjectID_(@*Object, iObject, iCanvasGadget)
		
			*Object\bHidden = #True
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
		Wend
		
	EndProcedure
	
	
	;{ Shot the specified object or all objects in the specified canvas.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects.
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  iCanvasGadget:         Canvas gadget number to restrict #Object_All or #Object_Selected to the specified gadget, or #PB_Ignore to allow all gadgets.
	;
	;  Affiche l'Objet spécifié ou tous les Objets dans le Canevas spécifiée.
	;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Affiche par defaut les nouveaux objets créé.
	;                          - #Object_All: Affiche tous les objets.
	;                          - #Object_Selected: Affiche tous les objets sélectionnés.
	;  iCanvasGadget:         Numéro du canevas pour Afficher seulement les Objets de ce canevas, ou #PB_Ignore pour Afficher n'importe quel objets peut importe ou il ce trouve.
	;}
	Procedure   ShowObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
		
		Protected *Object.Object
		
		While _ExObjectID_(@*Object, iObject, iCanvasGadget)
		
			*Object\bHidden = #False
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
		Wend
		
	EndProcedure
	
	
	;{ Enables the specified object or all objects in the specified canvas.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  iCanvasGadget:         Canvas gadget number to restrict #Object_All or #Object_Selected to the specified gadget, or #PB_Ignore to allow all gadgets.
	;
	;  Active l'Objet spécifié ou tous les Objets dans le Canevas spécifié.
	;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Active les nouveaux objets créé.
	;                          - #Object_All: Active tous les objets.
	;                          - #Object_Selected: Active tous les objets sélectionnés.
	;  iCanvasGadget:         Numéro du canevas pour Activer seulement les Objets de ce canevas, ou #PB_Ignore pour Activer n'importe quel objets peut importe ou il ce trouve.
	;}
	Procedure   EnableObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
		
		Protected *Object.Object
		
		While _ExObjectID_(@*Object, iObject, iCanvasGadget)
		
			*Object\bDisabled = #False
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
		Wend
		
	EndProcedure
	
	
	;{ Disables the specified object or all objects in the specified canvas.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  iCanvasGadget:         Canvas gadget number to restrict #Object_All or #Object_Selected to the specified gadget, or #PB_Ignore to allow all gadgets.
	;
	;  Désactive l'Objet spécifié ou tous les Objets dans le Canevas spécifié.
	;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Désactive les nouveaux objets créé.
	;                          - #Object_All: Désactive tous les objets.
	;                          - #Object_Selected: Désactive tous les objets sélectionnés.
	;  iCanvasGadget:         Numéro du canevas pour Desactiver seulement les Objets de ce canevas, ou #PB_Ignore pour Desactiver n'importe quel objets peut importe ou il ce trouve.
	;}
	Procedure   DisableObject(iObject.i, iCanvasGadget.i=#PB_Ignore)
		
		Protected *Object.Object
		
		While _ExObjectID_(@*Object, iObject, iCanvasGadget)
		
			*Object\bDisabled = #True
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
		Wend
		
	EndProcedure
	
	
	;{ Align the specified object position or all object positions in the specified canvas to their grid.
	;  iObject:               Object number or #PB_All to align all objects.
	;  iCanvasGadget:         Canvas gadget number, only needed if iObject is set to #PB_All.
	;
	;  Aligner la position du ou des Objets spécifié dans le canavas spécifiée sur leur grille (Colle le ou les Objets sur leur grille).
	;  iObject:               Numéro de l'Objet ou #PB_All pour aligner tous les Objets.
	;  iCanvasGadget:         Numéro du Canevas gadget, nécessaire uniquement si iObject est défini sur #PB_All.
	;}
	Procedure   AlignObjectPosition(iObject.i, iCanvasGadget.i=#PB_Ignore)
		
		Protected *ObjectManager.ObjectManager
		Protected *Object.Object
		
		If iObject = #PB_All
			_ObjectManagerID_(*ObjectManager, iCanvasGadget)
			ForEach *ObjectManager\lpObject()
				*ObjectManager\lpObject()\iX = AdjustX(*ObjectManager\lpObject(), *ObjectManager\lpObject()\iX, *ObjectManager\lpObject()\iWidth)
				*ObjectManager\lpObject()\iY = AdjustY(*ObjectManager\lpObject(), *ObjectManager\lpObject()\iY, *ObjectManager\lpObject()\iHeight)
			Next
			PostRedrawEvent(*ObjectManager)
		Else
			_ObjectID_(*Object, iObject)
			*Object\iX = AdjustX(*Object, *Object\iX)
			*Object\iY = AdjustY(*Object, *Object\iY)
			PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		EndIf
		
	EndProcedure
	
	
	;{ Align the specified object size or all object sizes in the specified canvas to their grid.
	;  iObject:               Object number or #PB_All to align all objects.
  ;  iCanvasGadget:         Canvas gadget number, only needed if iObject is set to #PB_All.
	;
	;  Aligne la taille du ou des Objets spécifié en fonction de leur grille dans le canavas spécifiée (Redimentionne le ou les Objets en fonction de leur grille).
	;  iObject:               Numéro de l'Objet ou #PB_All pour aligner tous les Objets.
	;  iCanvasGadget:         Numéro du Canevas gadget, nécessaire uniquement si iObject est défini sur #PB_All.
	;}
	Procedure   AlignObjectSize(iObject.i, iCanvasGadget.i=#PB_Ignore)
		
		Protected *ObjectManager.ObjectManager
		Protected *Object.Object
		
		If iObject = #PB_All
			_ObjectManagerID_(*ObjectManager, iCanvasGadget)
			ForEach *ObjectManager\lpObject()
				*ObjectManager\lpObject()\iWidth  = AdjustWidth(*ObjectManager\lpObject(), *ObjectManager\lpObject()\iWidth)
				*ObjectManager\lpObject()\iHeight = AdjustHeight(*ObjectManager\lpObject(), *ObjectManager\lpObject()\iHeight)
			Next
			PostRedrawEvent(*ObjectManager)
		Else
			_ObjectID_(*Object, iObject)
			*Object\iWidth  = AdjustWidth(*Object, *Object\iWidth)
			*Object\iHeight = AdjustHeight(*Object, *Object\iHeight)
			PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		EndIf
		
	EndProcedure
	
	
	;- Examinations
	
	
	;{ Give the current state of the specified object. !! UPDATE !!
	;  iObject:         Object number.
	;  Result:          A combination of the following constants:
	;                    - #State_Disabled:          The object is disabled.
	;                    - #State_Selected:          The object is selected.
	;                    - #State_Hidden:            The object is hidden.
	;                    - #State_Hovered:           The object is hovered by the cursor.
	;                    - #State_LeftMousePushed:   The object is pushed by the left mouse button.
	;                    - #State_RightMousePushed:  The object is pushed by the right mouse button.
	;                    - #State_MiddleMousePushed: The object is pushed by the middle mouse button.
	;                   Or 0 if the object doesn't exist.
	;
	; Indiquez l'état actuel de l'Objet spécifié.
	; iObject :         Numéro de l'Objet.
	; Résultat :        Une combinaison des constantes suivantes:
	;                   - #State_Disabled:   L'Objet est désactivé.
	; 	                - #State_Selected:   L'Objet est sélectionné.
	; 	                - #State_Hidden:     L'Objet est caché.
	;                   Ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i ObjectState(iObject.i)
			
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		Protected eState.i
		
		If *Object\bDisabled : eState | #State_Disabled : EndIf
		If *Object\bSelected : eState | #State_Selected : EndIf
		If *Object\bHidden   : eState | #State_Hidden   : EndIf
		
		If *Object = *Object\pParentFrame\pObjectManager\pHoveredObject
			eState | #State_Hovered
		EndIf
		If *Object = *Object\pParentFrame\pObjectManager\pMouseDownObject[1]
			eState | #State_LeftMousePushed
		EndIf
		If *Object = *Object\pParentFrame\pObjectManager\pMouseDownObject[2]
			eState | #State_RightMousePushed
		EndIf
		If *Object = *Object\pParentFrame\pObjectManager\pMouseDownObject[3]
			eState | #State_MiddleMousePushed
		EndIf
		
		ProcedureReturn eState
		
	EndProcedure
	
	
	;{ Examines all (selected) objects in the specified canvas gadget.
	;  iCanvasGadget:         Canvas gadget number.
	;  bSelected:             #True, if only selected objects should exermine, or #False for all objects.
	;  Result:                The count of (selected) objects or 0 if the canvas gadget was invalid.
	;
	;  Examine tous les Objets sélectionnés ou non dans le canvas
	;  iCanvasGadget :        Numéro du Canevas gadget.
	;  bSelected :            #True, si seuls les Objets sélectionnés doivent être retourné, ou #False pour renvoyé tous les Objets.
	;  Résultat :             Renvoie le nombre d'Objets sélectionnés ou tous les Objets du Canevas ou 0 si le Canevas n'était pas valide.
	;}
	Procedure.i ExamineObjects(iCanvasGadget.i, bSelected.i=#False)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0)
		Protected iCount.i
		
		*ObjectManager\pCurrentExaminedElement  = #Null
		*ObjectManager\bCurrentExaminedSelected = bSelected
		ForEach *ObjectManager\lpObject()
			If bSelected = #False Or *ObjectManager\lpObject()\bSelected
				iCount + 1
			EndIf
		Next
		
		ProcedureReturn iCount
		
	EndProcedure
	
	
	;{ Gives the next (selected) object in the specified canvas gadget. ExamineObjects() have to call at the first time!
	;  iCanvasGadget:         Canvas gadget number.
	;  Result:                The object number of the next (selected) object or 0 if no more object was found.
	;
	;  Renvoie l'Objet sélectionné ou non, suivant dans le canvas spécifié. ATTENTION: ExamineObjects() doit être appelé la première fois, ceci sert à passer en revue (Et à renvoyer leur numero) tous les Objets.
	;  iCanvasGadget:         Numéro du Canevas gadget.
	;  Resulta:               Le Numéro de l'Objet correspond à un Objet sélectionné ou non, ou 0 si aucun autre Objet n'a été trouvé.
	;}
	Procedure.i NextObject(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0)
		
		If *ObjectManager\pCurrentExaminedElement
			ChangeCurrentElement(*ObjectManager\lpObject(), *ObjectManager\pCurrentExaminedElement)
		Else
			ResetList(*ObjectManager\lpObject())
		EndIf
		
		While NextElement(*ObjectManager\lpObject())
			If *ObjectManager\bCurrentExaminedSelected = #False Or *ObjectManager\lpObject()\bSelected
				*ObjectManager\pCurrentExaminedElement = @*ObjectManager\lpObject()
				ProcedureReturn *ObjectManager\lpObject()\iObject
			EndIf
		Wend
		
		ProcedureReturn 0
		
	EndProcedure
	
	
	;{ Gives the event happened in the specified canvas gadget.
	;  iCanvasGadget:         Canvas gadget number or #PB_All to receive events from all gadgets (which is the case by default).
	;  Result:                One of the following events:
	;                          - #Event_None:            No event.
	;                          - #Event_Object:          An event on an object.
	;                          - #Event_Handle:          An event on an handle.
	;                         As long as an event happens, this function should be call again to dequeue all events.
	;
	;  Renvoie l'événement qui s'est produit dans le canvas spécifié.
	;  iCanvasGadget:         Numéro du Canevas gadget concerné ou #PB_All pour renvoyer les événements de tous les canevas (Ce qui est le cas par défaut).
	;  Result:                Un des événements suivants:
	;                          - #Event_None:            Aucun événement ne s'est passé.
	;                          - #Event_Object:          Un événement s'est passé sur un Objet.
	;                          - #Event_Handle:          Un événement s'est passé sur une poignée.
	;                         Tant qu'un événement se produit, cette fonction doit être rappelée pour mettre en file d'attente tous les événements.
	;}
	Procedure.i CanvasObjectsEvent(iCanvasGadget.i=#PB_All)
		
		Protected *ObjectManager.ObjectManager
		
		If iCanvasGadget = #PB_All
			ForEach EditorFactory\lObjectManager()
				*ObjectManager = EditorFactory\lObjectManager()
				If *ObjectManager\CurrentExaminedEvent\pObject And *ObjectManager\CurrentExaminedEvent\iEvent = #EventType_Freed And *ObjectManager\CurrentExaminedEvent\pObject\bFreed
					ChangeCurrentElement(EditorFactory\lObject(), *ObjectManager\CurrentExaminedEvent\pObject) ; Now realy freed
					DeleteElement(EditorFactory\lObject())
				EndIf
				LockMutex(*ObjectManager\iEventMutex)
				If FirstElement(*ObjectManager\lEvent())
					EditorFactory\pCurrentObjectManager = *ObjectManager
					*ObjectManager\CurrentExaminedEvent = *ObjectManager\lEvent()
					DeleteElement(*ObjectManager\lEvent())
					UnlockMutex(*ObjectManager\iEventMutex)
					ProcedureReturn *ObjectManager\CurrentExaminedEvent\iEvent
				Else
					UnlockMutex(*ObjectManager\iEventMutex)
					ClearStructure(*ObjectManager\CurrentExaminedEvent, ObjectManagerEvent)
				EndIf
			Next
			ProcedureReturn #Event_None
		Else
			_ObjectManagerID_(*ObjectManager, iCanvasGadget, #Event_None)
			If *ObjectManager\CurrentExaminedEvent\pObject And *ObjectManager\CurrentExaminedEvent\iEvent = #EventType_Freed And *ObjectManager\CurrentExaminedEvent\pObject\bFreed
				ChangeCurrentElement(EditorFactory\lObject(), *ObjectManager\CurrentExaminedEvent\pObject) ; Now realy freed
				DeleteElement(EditorFactory\lObject())
			EndIf
			LockMutex(*ObjectManager\iEventMutex)
			If FirstElement(*ObjectManager\lEvent())
				EditorFactory\pCurrentObjectManager = *ObjectManager
				*ObjectManager\CurrentExaminedEvent = *ObjectManager\lEvent()
				DeleteElement(*ObjectManager\lEvent())
				UnlockMutex(*ObjectManager\iEventMutex)
				ProcedureReturn *ObjectManager\CurrentExaminedEvent\iEvent
			Else
				UnlockMutex(*ObjectManager\iEventMutex)
				ClearStructure(*ObjectManager\CurrentExaminedEvent, ObjectManagerEvent)
				ProcedureReturn #Event_None
			EndIf
		EndIf
		
	EndProcedure
	
	
	;{ Gives the gadget on which the event happened. CanvasObjectsEvent() have to call before.
	;  Result:                A canvas gadget number.
	;
	;  Renvoie le numéro du canevas sur lequel un événement s'est produit. Attention, CanvasObjectsEvent() doivent être appelés avant.
	;  Résultat :             Le numéro du canevas ou s'est passé un événement.
	;}
	Procedure.i CanvasObjectsEventGadget()
		
		If EditorFactory\pCurrentObjectManager
			ProcedureReturn EditorFactory\pCurrentObjectManager\iCanvasGadget
		EndIf
		
	EndProcedure
	
	
	;{ Gives the event type happened on an object or handle in the specified canvas gadget. CanvasObjectsEvent() have to call before.
	;  iCanvasGadget:         Canvas gadget number.
	;  Result:                One of the following event types:
	;                          - #EventType_MouseEnter:              The mouse cursor enters an object/handle.
	;                          - #EventType_MouseLeave:              The mouse cursor leaves an object/handle.
	;                          - #EventType_Selected:                An object was selected.
	;                          - #EventType_Unselected:              An object was unselected.
	;                          - #EventType_Moved:                   An object was moved.
	;                          - #EventType_Resized:                 An object was resized.
	;                          - #EventType_LeftMouseBottonDown:     Left mouse button was pressed on an object/handle.
	;                          - #EventType_LeftMouseBottonUp:       Left mouse button was released from an object/handle.
	;                          - #EventType_LeftMouseClick:          Left mouse button was clicked on an object/handle.
	;                          - #EventType_LeftMouseDoubleClick:    Left mouse button was double clicked on an object/handle.
	;                          - #EventType_LeftMouseButtonHold:     Left mouse button is held on an handle. (Only possible in thread safe mode)
	;                          - #EventType_MiddleMouseBottonDown:   Middle mouse button was pressed on an object/handle.
	;                          - #EventType_MiddleMouseBottonUp:     Middle mouse button was released from an object/handle.
	;                          - #EventType_MiddleMouseClick:        Middle mouse button was clicked on an object/handle.
	;                          - #EventType_MiddleMouseDoubleClick:  Middle mouse button was double clicked on an object/handle.
	;                          - #EventType_MiddleMouseButtonHold:   Middle mouse button is held on an handle. (Only possible in thread safe mode)
	;                          - #EventType_RightMouseBottonDown:    Right mouse button was pressed on an object/handle.
	;                          - #EventType_RightMouseBottonUp:      Right mouse button was released from an object/handle.
	;                          - #EventType_RightMouseClick:         Right mouse button was clicked on an object/handle.
	;                          - #EventType_RightMouseDoubleClick:   Right mouse button was double clicked on an object/handle.
	;                          - #EventType_RightMouseButtonHold:    Right mouse button is held on an handle. (Only possible in thread safe mode)
	;                          - #EventType_MouseWheel:              The mouse wheel was rotated on an object/handle.
	;                          - #EventType_KeyDown:                 A key was pressed on an object/handle. Use CanvasObjectsEventData() to get the key.
	;                          - #EventType_KeyUp:                   A key was released on an object/handle. Use CanvasObjectsEventData() to get the key.
	;                          - #EventType_Selection:               A selection frame was drawn. Use CanvasObjectsEventData() to get the coordinates.
	;                          - #EventType_Created:                 An object was created.
	;                          - #EventType_Freed:                   An object was freed. In this case EventObject() gives still a valid object number until the next call of CanvasObjectsEvent()
	;
	;  Renvoie le type d'événement qui s'est produit sur un objet ou une poignée dans le canvas spécifié. ATTENTION, CanvasObjectsEvent() doit être appelés auparavant.
	;  iCanvasGadget:         Numéro du gadget de toile.
	;  Resulta:               Un des types d'événements suivants:
	;                          - #EventType_MouseEnter:              Le curseur de la souris entre dans sur un objet/une poignée.
	;                          - #EventType_MouseLeave:              Le curseur de la souris est partie d'un objet/une poignée.
	;                          - #EventType_Selected:                Un objet a été sélectionné.
	;                          - #EventType_Unselected:              Un objet a été désélectionné.
	;                          - #EventType_Moved:                   Un objet a été déplacé.
	;                          - #EventType_Resized:                 Un objet à été redimentionné.
	;                          - #EventType_LeftMouseBottonDown:     le bouton gauche de la souris a été enfoncé sur un objet/une poignée.
  ;                          - #EventType_LeftMouseBottonUp:       Le bouton gauche de la souris a été relâché sur un objet/poignée.
  ;                          - #EventType_LeftMouseClick:          Le bouton gauche de la souris a été cliqué sur un objet/poignée.
  ;                          - #EventType_LeftMouseDoubleClick:    Le bouton gauche de la souris a été double-cliqué sur un objet/une poignée.
	;                          - #EventType_LeftMouseButtonHold:     Le bouton gauche de la souris est maintenu sur une poignée. (Uniquement possible en mode thread safe)
	;                          - #EventType_MiddleMouseBottonDown:   le bouton du milieu de la souris a été enfoncé sur un objet/une poignée.
  ;                          - #EventType_MiddleMouseBottonUp:     Le bouton du milieu de la souris a été relâché sur un objet/poignée.
  ;                          - #EventType_MiddleMouseClick:        Le bouton du milieu de la souris a été cliqué sur un objet/poignée.
  ;                          - #EventType_MiddleMouseDoubleClick:  Le bouton du milieu de la souris a été double-cliqué sur un objet/une poignée.
	;                          - #EventType_MiddleMouseButtonHold:   Le bouton du milieu de la souris est maintenu sur une poignée. (Possible uniquement en mode thread safe)
	;                          - #EventType_RightMouseBottonDown:    Le bouton droit de la souris a été enfoncé sur un objet/une poignée.
  ;                          - #EventType_RightMouseBottonUp:      Le bouton droit de la souris a été relâché sur un objet/poignée.
  ;                          - #EventType_RightMouseClick:         Le bouton droit de la souris a été cliqué sur un objet/une poignée.
  ;                          - #EventType_RightMouseDoubleClick:   Le bouton droit de la souris a été double-cliqué sur un objet/une poignée.
	;                          - #EventType_RightMouseButtonHold:    Le bouton droit de la souris est maintenu sur une poignée. (Uniquement possible en mode thread safe)
	;                          - #EventType_MouseWheel:              La molette de la souris a été tournée sur un objet/une poignée.
	;                          - #EventType_KeyDown:                 Une touche a été enfoncée sur un objet/une poignée.
	;                          - #EventType_KeyUp :                  Une touche a été relâchée sur un objet/une poignée.
	;                          - #EventType_Selection:               L'utilisateur a déssiné une selection avec la souris, Utilisez CanvasObjectsEventData() pour avoir les coordonnées.
	;                          - #EventType_Created :                Un objet a été créé.
	;                          - #EventType_Freed:                   Un objet a été libéré. Dans ce cas, EventObject() donne toujours un numéro d'objet valide jusqu'au prochain appel de CanvasObjectsEvent()
	;}
	Procedure.i CanvasObjectsEventType(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, #EventType_None)
		
		ProcedureReturn *ObjectManager\CurrentExaminedEvent\iEventType
		
	EndProcedure
	
	
	;{ Gives the event data from an event on an object or handle in the specified canvas gadget. CanvasObjectsEvent() have to call before.
	;  iCanvasGadget:         Canvas gadget number.
  ;  eDataType:             If the event type was #EventType_Selection you can use one of the following constants to get the frame coordinates:
	;                          - #EventTypeData_MinX
	;                          - #EventTypeData_MinY
	;                          - #EventTypeData_MaxX
	;                          - #EventTypeData_MaxY
  ;  Result:                The data value of the event type or the value of the specified position.
	;
	;  Renvoie les données d'un événement d'un objet ou une poignée dans le canevas spécifié. ATTENTION: CanvasObjectsEvent() doit être appelés auparavant.
	;  iCanvasGadget :        Numéro du gadget de canevas
  ;  eDataType :            Si le type d'événement était #EventType_Selection, vous pouvez utiliser l'une des constantes suivantes pour obtenir les coordonnées du cadre:
	;                          - #EventTypeData_MinX
	;                          - #EventTypeData_MinY
	;                          - #EventTypeData_MaxX
  ;                          - #EventTypeData_MaxY
	; Résultat:               La valeur de la donnée du type d'événement ou la valeur de la position spécifiée.
 	;}
	Procedure.i CanvasObjectsEventData(iCanvasGadget.i, eDataType.i=#EventTypeData_Default)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0)
		
		If eDataType > 0 And eDataType < 5
			ProcedureReturn *ObjectManager\CurrentExaminedEvent\iEventDataArray[eDataType]
		Else
			ProcedureReturn *ObjectManager\CurrentExaminedEvent\iEventData
		EndIf
		
	EndProcedure
	
	
	;{ Gives the object on which an event happened in the specified canvas gadget.
	;  iCanvasGadget:         Canvas gadget number.
	;  Resulta:               The object number or 0 if no event happends.
	;
	;  Renvoie le numéro de l'Objet sur lequel un événement s'est produit dans le canvas spécifié.
	;  iCanvasGadget:         Numéro du Canevas gadget.
	;  Resulta:               Le numéro de l'Objet ou 0 si aucun événement ne se produit.
	;}
	Procedure.i EventObject(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0)
		
		If *ObjectManager\CurrentExaminedEvent\pObject
			If *ObjectManager\CurrentExaminedEvent\pObject\bFreed
				ProcedureReturn *ObjectManager\CurrentExaminedEvent\pObject
			Else
				ProcedureReturn *ObjectManager\CurrentExaminedEvent\pObject\iObject
			EndIf
		Else
			ProcedureReturn 0
		EndIf
		
	EndProcedure
	
	
	;{ Gives the handle on which an event happened in the specified canvas gadget.
	;  iCanvasGadget:         Canvas gadget number.
	;  Result:                The handle number or #Handle_None if no event happends on a handle.
	;
	;  Donne la poignée sur lequel un événement s'est produit dans le Canevas gadget spécifié.
	;  iCanvasGadget:         Numéro du gadget de toile.
	;  Resulta:               Le numéro de l'identifiant ou #Handle_None si aucun événement ne s'est produit sur un identifiant.
	;}
	Procedure.i EventHandle(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, #Handle_None)
		
		If *ObjectManager\CurrentExaminedEvent\pObject
			ProcedureReturn *ObjectManager\CurrentExaminedEvent\eHandle
		Else
			ProcedureReturn #Handle_None
		EndIf
		
	EndProcedure
	
	
	;- Set & Get
	
	
	;{ Sets a custom drawing Procedure to the specified canvas gadget.
	;  iCanvasGadget:         Canvas gadget number.
	;  pPreCallback:          #Null, or a valid address to a procedure which will called BEFORE object drawing with the following arguments: Callback(iGadget.i, iData.i)
	;                          - iGadget contains the canvas gadget number.
	;                          - iData contains a custom user aata.
	;  pPostCallback:         #Null, or a valid address to a procedure which will called AFTER object drawing with the following arguments: Callback(iGadget.i, iData.i)
	;                          - iGadget contains the canvas gadget number.
	;                          - iData contains a custom user aata.
	;  iData:                 An individual custom user data which will send also to the callback (Optional).
	;  Result:                #True or #False if the canvas gadget was invalid.
	;
	;  Définit une procédure de dessin personnalisée pour le Canevas.
	;  iCanvasGadget:         Numéro du Canevas gadget.
	;  pPreCallback:          #Null, ou une adresse valide vers une procédure qui serra appeler avant de déssiner les graphiques sur les Objets, avec les arguments suivants: NomCallback(iGadget.i, iData.i)
  ;                          - iGadget contient le numéro de gadget du Canevas.
  ;                          - iData contient une donnée utilisateur personnalisée.
	;  pPostCallback:         #Null, ou une adresse valide vers une procédure qui sera appelée APRÈS le dessin de l'Objet avec les arguments suivants: Callback(iGadget.i, iData.i)
  ;                          - iGadget contient le numéro de gadget du Canevas.
	;                          - iData contient une donnée utilisateur personnalisée.
	;  iData:                 Une donnée utilisateur personnalisée individuelle qui sera également envoyée au callback (Optionnel).
	;  Résultat:              #True ou #False si le Canevas gadget n'était pas valide.
	;}
	Procedure.i SetCanvasDrawingCallback(iCanvasGadget.i, pPreCallback.ObjectDrawingCallback, pPostCallback.ObjectDrawingCallback, iData.i=0)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, #False)
		
		*ObjectManager\pPreDrawingCallback  = pPreCallback
		*ObjectManager\pPostDrawingCallback = pPostCallback
		*ObjectManager\iCallbackData        = iData
		PostRedrawEvent(*ObjectManager)
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Sets the shown cursor of the specified canvas gadget. (Sets the cursor which is shown, when you are over the gadget)
	;  iCanvasGadget:         Canvas gadget number.
	;  eCursor:               A valid #PB_Cursor_* constant or #PB_Cursor_Custom.
	;  hCursorHandle:         A valid cursor handle or icon image id. Only needed if eCursor is set to #PB_Cursor_Custom.
	;  Result:                #True if the cursor was set or #False if the canvas doesn't exist.
	;
	;  Définit le curseur de la souris affiché quand la souris passe sur le canevas spécifié.
	;  iObject:               Numéro de l'objet.
	;  eCursor:               Une constante #PB_Cursor_* valide.
	;  hCursorHandle:         Une image personnalisé pour le curseur, a condition que eCursor soit #PB_Cursor_Custom.
	;  Résultat:              Renvoie #True si le curseur a été placé ou #False si le Canevas n'existe pas.
	;}
	Procedure.i SetCanvasCursor(iCanvasGadget.i, eCursor.i, hCursorHandle.i=#Null)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, #False)
		
		*ObjectManager\eCursor       = eCursor
		*ObjectManager\hCursorHandle = hCursorHandle
		PostRedrawEvent(*ObjectManager)
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Sets the size and position boundaries of the specified object.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  iMinX, iMinY:          Minimum values for the (top left) object position.*
	;  iMaxX, iMaxY:          Maximum values for the (bottom right corner) object position.*
	;  iMinWidth, iMinHeight: Minimum values for the object size.*
	;  iMaxWidth, iMaxHeight: Maximum values for the object size.*
	;  Result:                #True if the boundaries were set or #False if the object doesn't exist.
	;                         * For the size and position values also following constants can be used:
	;                           #Boundary_Ignore:      Ignore this parameter and left the boundary value unchanged.
	;                           #Boundary_None:        Removes the boundary value for this parameter.
	;                           #Boundary_Default:     Set the boundary value to the default value.
	;                           #Boundary_ParentSize:  Add this constant to a boundary value (#Boundary_ParentSize ± value) to make the boundary relative to the parent frame (or the canvas gadget) size.
	;
	;  Définit la taille et la position limite de l'Objet spécifié.
	;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Définie les limites pour tous les nouveaux objets créé.
	;                          - #Object_All: Définie les limites de tous les objets éxistant.
	;                          - #Object_Selected: Définie les limites de tous les objets sélectionnés.
	;  iMinX, iMinY:          Valeurs minimales pour la position de l'objet (en haut à gauche). *
	;  iMaxX, iMaxY:          Valeurs maximales pour la position de l'objet (coin inférieur droit). *
	;  iMinWidth, iMinHeight: Valeurs minimales pour la taille de l'objet. *
  ;  iMaxWidth, iMaxHeight: Valeurs maximales pour la taille de l'objet. *
	;  Résultat:              #True si les limites ont été fixées ou #False si l'objet n'existe pas.
	;                         * Pour les valeurs de taille et de position, les constantes suivantes peuvent également être utilisées:
	;                           #Boundary_Ignore:      Ignorer ce paramètre et laisser la valeur limite inchangée.
	;                           #Boundary_None:        Supprime la valeur limite de ce paramètre.
	;                           #Boundary_ParentSize:  Ajoutez cette constante à une valeur de limite (#Boundary_ParentSize ± Valeur) pour rendre la limite relative à la taille du cadre parent (ou du canevas gadget).
	;                           #Boundary_Default:     Régler la valeur limite à la valeur par défaut.
	;}
	Procedure.i SetObjectBoundaries(iObject.i, iMinX.i=#Boundary_Ignore, iMinY.i=#Boundary_Ignore, iMaxX.i=#Boundary_Ignore, iMaxY.i=#Boundary_Ignore, iMinWidth.i=#Boundary_Ignore, iMinHeight.i=#Boundary_Ignore, iMaxWidth.i=#Boundary_Ignore, iMaxHeight.i=#Boundary_Ignore)
		
		Protected *Object.Object, bResult.i = #False
		
		While _ExObjectID_(@*Object, iObject)
			
			_SetObjectBoundaries_SetMacro_(iMinX)
			_SetObjectBoundaries_SetMacro_(iMinY)
			_SetObjectBoundaries_SetMacro_(iMaxX)
			_SetObjectBoundaries_SetMacro_(iMaxY)
			_SetObjectBoundaries_SetMacro_(iMinWidth)
			_SetObjectBoundaries_SetMacro_(iMinHeight)
			_SetObjectBoundaries_SetMacro_(iMaxWidth)
			_SetObjectBoundaries_SetMacro_(iMaxHeight)
			
			With *Object
				\iWidth  = AdjustWidth(*Object, \iWidth)
				\iHeight = AdjustHeight(*Object, \iHeight)
				\iX      = AdjustX(*Object, \iX, \iWidth)
				\iY      = AdjustY(*Object, \iY, \iHeight)
			EndWith
			
			bResult = #True
			
		Wend
		
		ProcedureReturn bResult
		
	EndProcedure
	
	
	;{ Sets the shown cursor of the specified object. (Sets the cursor which is shown, when you are over the object)
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  eCursor:               A valid #PB_Cursor_* constant or #PB_Cursor_Custom.
	;  hCursorHandle:         A valid cursor handle or icon image id. Only needed if eCursor is set to #PB_Cursor_Custom.
	;  Result:                #True if the cursor was set or #False if the object doesn't exist.
	;
	;  Définit le curseur de la souris affiché quand la souris passe sur l'objet spécifié.
	;  Cette fonction est à utiliser pour les fonctions suivante: SetObjectHandleCursor() et SetCanvasCursor(), pour le paramètre hCursorHandle.
  ;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Définie le curseur de la souris par defaut de tous les nouveaux objets créé.
	;                          - #Object_All: Définie le curseur de la souris de tous les objets.
	;                          - #Object_Selected: Définie le curseur de la souris de tous les objets sélectionnés.
  ;  eCursor:               Une constante #PB_Cursor_* valide.
	;  hCursorHandle:         Une image personnalisé pour le curseur, a condition que eCursor soit #PB_Cursor_Custom.
	;  Résultat:              Renvoie #True si le curseur a été placé ou #False si l'objet n'existe pas.
	;}
	Procedure.i SetObjectCursor(iObject.i, eCursor.i, hCursorHandle.i=#Null)
		
		Protected *Object.Object, bResult.i = #False
		
		While _ExObjectID_(@*Object, iObject)
			
			*Object\eCursor       = eCursor
			*Object\hCursorHandle = hCursorHandle
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
			bResult = #True
			
		Wend
		
		ProcedureReturn bResult
		
	EndProcedure
	
	
	;{ Sets the shown cursor of the specified handle of the specified object. (Sets the cursor which is shown, when you are over the handle)
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  eType:                  A valid combination of handle constants (see AddObjectHandle()).
	;  eCursor:                A valid #PB_Cursor_* constant or #PB_Cursor_Custom.
	;  hCursorHandle:          A valid cursor handle or icon image id. Only needed if eCursor is set to #PB_Cursor_Custom.
  ;  Result:                 #True if the cursor was set or #False if the object doesn't exist.
	;
	;  Définit le curseur de la souris affiché quand la souris passe sur la poignée spécifié de l'objet.
  ;  iObject:                Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                           - #Object_Default: Définie le curseur de la poignées de l'objet par defaut pour tous les nouveaux objets créé.
	;                           - #Object_All: Définie le curseur de la poignées de l'objet de tous les objets.
	;                           - #Object_Selected: Définie le curseur de la poignées de l'objet des objets sélectionnés.
	;  eType:                  Une conbinaisont de constante de poignée (Voir AddObjectHandle())
  ;  eCursor:                Une constante #PB_Cursor_* valide
	;  hCursorHandle:          Une image personnalisé pour le curseur, a condition que eCursor soit #PB_Cursor_Custom.
	;  Résultat:               Renvoie #True si le curseur a été changé ou #False si l'objet n'existe pas.
	;}
	Procedure.i SetObjectHandleCursor(iObject.i, eType.i, eCursor.i, hCursorHandle.i=#Null)
		
		Protected iIndex.i
		Protected *Object.Object, bResult.i = #False
		
		While _ExObjectID_(@*Object, iObject)
			
			For iIndex = 0 To #LastHandle
				If eType & (1<<iIndex)
					*Object\aHandle(iIndex)\eCursor       = eCursor
					*Object\aHandle(iIndex)\hCursorHandle = hCursorHandle
				EndIf
			Next
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
			bResult = #True
		Wend
		
		ProcedureReturn bResult
		
	EndProcedure
	
	
	;{ Sets the custom data value of the specified object.
	;  iObject:               Object number.
	;  iData:                 Integer value.
	;  Result:                #True or #False if the object doesn't exist.
	;
	;  Définit une valeur personnalisées de l'Objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  iData:                 Valeur entière.
	;  Résultat:              #True ou #False si l'Objet n'existe pas.
	;}
	Procedure.i SetObjectData(iObject.i, iData.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		
		*Object\iData = iData
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Sets a custom value at the specified object (Map).
	;  iObject:               Object number.
	;  sName:                 Name of the custom value.
	;  sValue:                Value of the custom value.
	;  Result:                #True or #False if the object doesn't exist.
	;
	;  Définit une valeur personnalisée de l'Objet spécifié depuis une clef (Map).
	;  iObject :              Numéro de l'Objet.
	;  sNom :                 Nom (Clef) de la valeur.
	;  sValeur :              Valeur de la clef.
	;  Résultat :             #True ou #False si l'Objet n'existe pas.
	;}
	Procedure.i SetObjectDictionary(iObject.i, sName.s, sValue.s)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		
		*Object\msAttribute(sName) = sValue
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Sets a custom drawing procedure to the specified object.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  pCallback:             #Null,  or a valid address to a procedure with the following arguments: Callback(iObject.i, iWidth.i, iHeight.i, iData.i)
  ;                          - iObject contains the object number.
	;                          - iWidth contains the current width.
	;                          - iHeight contains the current height, iData contains a custom user data.
	;                          - iData contains an individual custom user data which will send also to the callback.
	;  Result:                #True if the callback was set or #False if the object doesn't exist.
	;
	;  Définit une procédure de dessin personnalisée pour l'Objet spécifié.
  ;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Définie l'image par defaut de tous les nouveaux objets créé.
	;                          - #Object_All: Définie l'image de tous les objets.
	;                          - #Object_Selected: Définie l'image de tous les objets sélectionnés.
	;  pCallback:             #Null, ou one adresse valide pour une procédure avec les arguments suivants obligatoire: NomCallback(iObject.i, iWidth.i, iHeight.i, iData.i)
	;                          - iObject contient le numéro de l'Objet.
	;                          - iWidth contient la largeur actuelle.
	;                          - iHeight contient la hauteur actuelle.
	;                          - iData contient une donnée utilisateur personnalisée (Nombre) individuelle qui sera également envoyée à la fonction.
	;  Résultat:              Renvoie #True si le callback a été défini avec succet à l'Objet ou #False si l'Objet n'existe pas.
	;}
	Procedure.i SetObjectDrawingCallback(iObject.i, pCallback.ObjectDrawingCallback, iData.i=0)
		
		Protected *Object.Object, bResult.i = #False
		
		While _ExObjectID_(@*Object, iObject)
			
			*Object\pDrawingCallback = pCallback
			*Object\iCallbackData    = iData
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
			bResult = #True
		Wend
		
		ProcedureReturn bResult
		
	EndProcedure
	
	
	;{ Set the drawing layer position of the specified object.
	;  iObject:               Object number.
	;  iLayer:                The layer position. The lowest layer position is 1. Negative position values count from the top most layer.
	;  iMode:                 #PB_Relative to change the layer relative to its current position (e.g. -1 (one layer down), +3 (three layer up) or
	;                         #PB_Absolute to change the absolute position of the layer (e.g. 4 (4th layer from the bottom), -1 (1st layer from the top)).
	;  Result:                The new layer position of the object or 0 if the object doesn't exist.
	;
	;  Définie la position de l'Objets sur la couche de dessin (Layer) de l'objet spécifié, par exemple pour mettre un Objets au dessus d'un autre ou vice et versa.
	;  iObject :              Numéro de l'objet.
	;  iLayer :               La position de l'Objets sur la couche (Layer). La position de la couche la plus basse est 1. Les valeurs de position négatives comptent à partir de la couche la plus haute, par exemple si il y à 5 couche et que vous mettez -1 alors se serra égale à 5, -2 = 4, etc.
	;  iMode :                #PB_Relative pour modifier le calque par rapport à sa position actuelle (par exemple, -1 (un calque en bas), +3 (trois calques en haut) ou
	;                         #PB_Absolute pour changer la position absolue de la couche (par exemple 4 (4ème couche à partir du bas), -1 (1ère couche à partir du haut)).
	;  Résultat :             La nouvelle position de la couche de l'objet ou 0 si l'objet n'existe pas.
	;}
	Procedure.i SetObjectLayer(iObject.i, iLayer.i, iMode.i=#PB_Absolute)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		Protected *Element, *Frame.Frame
		
		*Frame = *Object\pParentFrame
		
		If iMode = #PB_Absolute Or iMode = #PB_Relative
			If iMode = #PB_Relative
				ForEach *Frame\lpChildObject()
					If *Frame\lpChildObject() = *Object
						iLayer + ListIndex(*Frame\lpChildObject())
						If iLayer < 0 : iLayer = 0 : EndIf
						If iLayer > ListSize(*Frame\lpChildObject())-1 : iLayer = ListSize(*Frame\lpChildObject())-1 : EndIf
						Break
					EndIf
				Next
			Else
				If iLayer > ListSize(*Frame\lpChildObject())
					iLayer = ListSize(*Frame\lpChildObject())-1
				ElseIf iLayer < -ListSize(*Frame\lpChildObject()) Or iLayer = 0
					iLayer = 0
				ElseIf iLayer < 0
					iLayer = ListSize(*Frame\lpChildObject()) + iLayer
				Else
					iLayer - 1
				EndIf
			EndIf
			*Element = SelectElement(*Frame\lpChildObject(), iLayer)
			ForEach *Frame\lpChildObject()
				If *Frame\lpChildObject() = *Object
					If iLayer < ListIndex(*Frame\lpChildObject())
						MoveElement(*Frame\lpChildObject(), #PB_List_Before, *Element)
					Else
						MoveElement(*Frame\lpChildObject(), #PB_List_After, *Element)
					EndIf
					Break
				EndIf
			Next
			PostRedrawEvent(*Frame\pObjectManager)
			ProcedureReturn ListIndex(*Frame\lpChildObject())
		EndIf
		
	EndProcedure
	
	
	;{ Sets the height of the specified object. If the height is outside the spezified boundary condition, the value will be adjusted automaticaly.
	;  iObject:               Object number.
	;  iWidth:                Height value.
	;  Result:                The height of the object or 0 if the object doesn't exist.
	;
	;  Définit la hauteur de l'Objet spécifié. Si la hauteur est en dehors de la condition limite spécifiée, la valeur sera automatiquement ajustée.
	;  iObject:               Numéro de l'Objet.
	;  iWidth:                Valeur de la hauteur.
	;  Résultat:              La hauteur de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i SetObjectHeight(iObject.i, iHeight.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		*Object\iHeight = AdjustHeight(*Object, iHeight)
		*Object\iY     = AdjustX(*Object, *Object\iY, *Object\iHeight)
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn *Object\iHeight
		
	EndProcedure
	
	
	;{ Sets the width of the specified object. If the width is outside the spezified boundary condition, the value will be adjusted automaticaly.
	;  iObject:               Object number.
	;  iWidth:                Width value.
	;  Result:                The width of the object or 0 if the object doesn't exist.
	;
	;  Définit la largeur de l'Objet spécifié. Si la largeur est en dehors de la condition limite spécifiée, la valeur sera automatiquement ajustée.
	;  iObject:               Numéro de l'Objet.
	;  iWidth:                Valeur de la largeur.
	;  Résultat:              La largeur de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i SetObjectWidth(iObject.i, iWidth.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		*Object\iWidth = AdjustWidth(*Object, iWidth)
		*Object\iX     = AdjustX(*Object, *Object\iX, *Object\iWidth)
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn *Object\iWidth
		
	EndProcedure
	
	
	;{ Sets the X position of the specified object. If the X position is outside the spezified boundary condition, the value will be adjusted automaticaly.
	;  iObject:               Object number.
	;  iX:                    Position value.
	;  eFlag:                 #Object_GlobalPosition or #Object_LocalPosition, to use iX as a global canvas position or a local position inside the parent object.
	;  Result:                The X position of the object or 0 if the object doesn't exist.
	;
	;  Définit la position X de l'Objet spécifié. Si la position X est en dehors de la condition limite spécifiée, la valeur sera ajustée automatiquement.
	;  iObject:               Numéro de l'Objet.
  ;  iX:                    Valeur de position X.
	;  eFlag :                #Object_GlobalPosition ou #Object_LocalPosition, pour utiliser X comme position globale dans le canevas ou comme position locale dans l'objet parent.
	;  Result:                La position X de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i SetObjectX(iObject.i, iX.i, eFlag.i=#Object_GlobalPosition)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		Select eFlag
			Case #Object_GlobalPosition
				*Object\iX = AdjustX(*Object, iX - GlobalX(*Object, 0), *Object\iWidth)
			Case #Object_LocalPosition
				*Object\iX = AdjustX(*Object, iX, *Object\iWidth)
		EndSelect
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn *Object\iX
		
	EndProcedure
	
	
	;{ Sets the Y position of the specified object. If the Y position is outside the spezified boundary condition, the value will be adjusted automaticaly.
	;  iObject:               Object number.
	;  iX:                    Position value.
	;  eFlag:                 #Object_GlobalPosition or #Object_LocalPosition, to use iY as a global canvas position or a local position inside the parent object.
	;  Result:                The Y position of the object or 0 if the object doesn't exist.
	;
	;  Définit la position Y de l'Objet spécifié. Si la position Y est en dehors de la condition limite spécifiée, la valeur sera ajustée automatiquement.
	;  iObject:               Numéro de l'Objet.
  ;  iX:                    Valeur de position Y.
	;  eFlag :                #Object_GlobalPosition ou #Object_LocalPosition, pour utiliser Y comme position globale dans le canevas ou comme position locale dans l'objet parent.
	;  Result:                La position Y de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i SetObjectY(iObject.i, iY.i, eFlag.i=#Object_GlobalPosition)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		Select eFlag
			Case #Object_GlobalPosition
				*Object\iY = AdjustY(*Object, iY - GlobalY(*Object, 0), *Object\iHeight)
			Case #Object_LocalPosition
				*Object\iY = AdjustY(*Object, iY, *Object\iHeight)
		EndSelect
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn *Object\iY
		
	EndProcedure
	
	;{ !! NOT IN USE !!
	
	;{ Sets the pivot position of the specified object. This value is relative to the object position and size.
	;  iObject:               Object number.
	;  fX:                    Pivot position value. The left side is 0.0, the right side is 1.0
	;  fY:                    Pivot position value. The left side is 0.0, the right side is 1.0
	;  Result:                #True if the pivot was set or #False if the object doesn't exist.
	;}
	Procedure.i SetObjectPivot(iObject.i, fX.f, fY.f)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		
		*Object\fPivotX = fX
		*Object\fPivotY = fY
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Sets the pivot X position of the specified object. This value is relative to the object position and width.
	;  iObject:               Object number.
	;  fX:                    Pivot position value. The left side is 0.0, the right side is 1.0
	;  Result:                The set pivot position of the object or 0.0 if the object doesn't exist.
	;}
	Procedure.f SetObjectPivotX(iObject.i, fX.f)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0.0)
		
		*Object\fPivotX = fX
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn *Object\fPivotX
		
	EndProcedure
	
	
	;{ Sets the pivot Y position of the specified object. This value is relative to the object position and height.
	;  iObject:               Object number.
	;  fY:                    Pivot position value. The top side is 0.0, the bottom side is 1.0
	;  Result:                The set pivot position of the object or 0.0 if the object doesn't exist.
	;}
	Procedure.f SetObjectPivotY(iObject.i, fY.f)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0.0)
		
		*Object\fPivotY = fY
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn *Object\fPivotY
		
	EndProcedure
	
	
	;{ Sets the rotation of the specified object.
	;  iObject:               Object number.
	;  fAngle:                The angle in degree. 0 is directed to the right side and 90 is directed to the bottom.
	;  Result:                The rotation angle of the object or 0 if the object doesn't exist.
	;}
	Procedure   SetObjectRotation(iObject.i, fAngle.f)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		*Object\fRotation = Radian(Mod(fAngle, 360))
		If *Object\fRotation < 0
			*Object\fRotation = 2*#PI + *Object\fRotation
		EndIf
		
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
	EndProcedure
	
	;}
	
	;{ Sets the movement step size of the specified object.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  iX:                    X step size or #PB_Ignore to ignore this parameter.
	;  iY:                    Y step size or #PB_Ignore to ignore this parameter.
	;  Result:                #True or #False if the object doesn't exist.
	;
	;  Définit la taille du pas de déplacement de l'objet spécifié en X et Y.
  ;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Définie le pas de mouvement par defaut de tous les nouveaux objets créé.
	;                          - #Object_All: Définie le pas de mouvement de tous les objets.
	;                          - #Object_Selected: Définie le pas de mouvement de tous les objets sélectionnés.
	;  iX:                    Pas X ou #PB_Ignore pour ignorer ce paramètre.
	;  iY:                    Pas Y ou #PB_Ignore pour ignorer ce paramètre.
	;  Résultat:              #True ou #False si l'objet n'existe pas.
	;}
	Procedure.i SetObjectMovementStep(iObject.i, iX.i, iY.i)
		
		Protected *Object.Object, bResult.i = #False
		
		While _ExObjectID_(@*Object, iObject)
			
			If iX <> #PB_Ignore
				*Object\Grid\iMoveX = iX
			EndIf
			If iY <> #PB_Ignore
				*Object\Grid\iMoveY = iY
			EndIf
			
			bResult = #True
		Wend
		
		ProcedureReturn bResult
		
	EndProcedure
	
	
	;{ Sets the resize step size of the specified object.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  iX:                    X step size or #PB_Ignore to ignore this parameter.
	;  iY:                    Y step size or #PB_Ignore to ignore this parameter.
	;  Result:                #True or #False if the object doesn't exist.
	;
	;  Définit le pas de redimensionnement de l'objet spécifié en X et Y.
  ;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Définie le pas de redimentionnement par defaut de tous les nouveaux objets créé.
	;                          - #Object_All: Définie le pas de redimentionnement de tous les objets.
	;                          - #Object_Selected: Définie le pas de redimentionnement de tous les objets sélectionnés.
	;  iX:                    Pas X ou #PB_Ignore pour ignorer ce paramètre.
	;  iY:                    Pas Y ou #PB_Ignore pour ignorer ce paramètre.
	;  Résultat:              #True ou #False si l'objet n'existe pas.
	;}
	Procedure.i SetObjectResizeStep(iObject.i, iX.i, iY.i)
		
		Protected *Object.Object, bResult.i = #False
		
		While _ExObjectID_(@*Object, iObject)
			
			If iX <> #PB_Ignore
				*Object\Grid\iSizeX = iX
			EndIf
			If iY <> #PB_Ignore
				*Object\Grid\iSizeY = iY
			EndIf
			
			bResult = #True
		Wend
		
		ProcedureReturn bResult
		
	EndProcedure
	
	
	;{ Sets the boundary frame style of the specified object. !! NOT IN USE !!
	;  iObject:               Object number or #PB_Default to set a default style for all objects.
	;  eType:                 One of the following style types:
	;                          - #BoundaryStyle_Default: Uses the default style.
	;                          - #BoundaryStyle_None:    Hide the boundary frame.
	;                          - #BoundaryStyle_Solid:   Solid frame line.
	;                          - #BoundaryStyle_Dotted:  Dotted frame line.
	;                          - #BoundaryStyle_Dashed:  Dahsed frame line.
	;  iColor:                RGBA-Color of the frame. Not used if eType is #BoundaryStyle_Default or #BoundaryStyle_None.
	;  dThickness:            Thickness of the frame line. Not used if eType is #BoundaryStyle_Default or #BoundaryStyle_None.
	;  Result:                #True if the selected frame state was set or #False if the object doesn't exist.
	;
	;  Définit le style du cadre de délimitation de l'Objet spécifié.
	;  iObject:               Numéro de l'Objet ou #PB_Default pour définir un style par défaut pour tous les Objets.
	;  eType:                 Un des types de style suivants:
	;                          - #BoundaryStyle_Default: Utilise le style par défaut.
	;                          - #BoundaryStyle_None: Masque le cadre.
	;                          - #BoundaryStyle_Solid: ligne solide.
	;                          - #BoundaryStyle_Dotted: Ligne en pointillés.
	;                          - #BoundaryStyle_Dashed: ligne tiret.
	;  iColor:                Couleur RGBA de l'image. Non utilisé si eType est #BoundaryStyle_Default ou #BoundaryStyle_None.
	;  dÉpaisseur:            Épaisseur de la ligne du cadre. Non utilisé si eType est #BoundaryStyle_Default ou #BoundaryStyle_None.
	;  Résultat:              Renvoie #True le style a été défini ou #False si l'Objet n'existe pas.
	;}
	Procedure.i SetObjectBoundaryStyle(iObject.i, eType.i, iColor.i=$FF000000, dThickness.d=1.0)
		
		Protected *Object.Object
		
		If iObject = #PB_Default
			EditorFactory\DefaultObject\pBoundaryStyle\eType      = eType
			EditorFactory\DefaultObject\pBoundaryStyle\iColor     = iColor
			EditorFactory\DefaultObject\pBoundaryStyle\dThickness = dThickness
		Else
			_ObjectID_(*Object, iObject, #False)
			If eType = #BoundaryStyle_Default
				If *Object\pBoundaryStyle <> @EditorFactory\DefaultObject\pBoundaryStyle
					ChangeCurrentElement(EditorFactory\lObjectStyle(), *Object\pBoundaryStyle)
					DeleteElement(EditorFactory\lObjectStyle())
				EndIf
				*Object\pBoundaryStyle = @EditorFactory\DefaultObject\pBoundaryStyle
			Else
				If *Object\pBoundaryStyle = @EditorFactory\DefaultObject\pBoundaryStyle
					*Object\pBoundaryStyle = AddElement(EditorFactory\lObjectStyle())
				EndIf
				*Object\pBoundaryStyle\eType      = eType
				*Object\pBoundaryStyle\iColor     = iColor
				*Object\pBoundaryStyle\dThickness = dThickness
			EndIf
			PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		EndIf
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Sets the selection frame style of the specified object.
	;  iObject:               Object number or one of the following constants:
	;                          - #Object_Default  : Specifies the "default" object, which properties are used for all new objects. 
	;                          - #Object_All      : Iterates through all objects in sequence.
	;                          - #Object_Selected : Iterates through all selected objects in sequence.
	;  eType:                 One of the following style types:
	;                          - #SelectionStyle_Default: Uses the default style.
	;                          - #SelectionStyle_None:    Hide the selection frame.
	;                          - #SelectionStyle_Solid:   Solid frame line.
	;                          - #SelectionStyle_Dotted:  Dotted frame line.
	;                          - #SelectionStyle_Dashed:  Dahsed frame line.
	;                          - #SelectionStyle_Ignore:  Ignore this parameter.
	;  iColor:                RGBA-Color of the frame or #SelectionStyle_Ignore to ignore this parameter. Not used if eType is #SelectionStyle_Default or #SelectionStyle_None.
	;  dThickness:            Thickness of the frame line or #SelectionStyle_Ignore to ignore this parameter. Not used if eType is #SelectionStyle_Default or #SelectionStyle_None.
	;  dDistance:             Distance of the frame line to the object border or #SelectionStyle_Ignore to ignore this parameter.
	;  Result:                #True if the selected frame state was set or #False if the object doesn't exist.
	;
	;  Définit le style du cadre de sélection de l'Objet spécifié.
  ;  iObject:               Le numéro de l'Objet, les constantes suivantes peuvent être utilisées à la place du numéro de l'objet.
	;                          - #Object_Default: Définie le style de selection par defaut de tous les nouveaux objets créé.
	;                          - #Object_All: Définie le style de selection de tous les objets.
	;                          - #Object_Selected: Définie le style de selection de tous les objets sélectionnés.
	;  eType:                 Un des types de style suivants:
	;                          - #SelectionStyle_Default: Utilise le style par défaut.
	;                          - #SelectionStyle_None: Masque le cadre de sélection.
	;                          - #SelectionStyle_Solid: ligne en continue.
	;                          - #SelectionStyle_Dotted: ligne en Pointillés.
	;                          - #SelectionStyle_Dashed: ligne tiret.
	;  iColor:                Couleur RGBA du cadre ou #SelectionStyle_Ignore pour ignorer ce paramètre. Non utilisé si eType est #SelectionStyle_Default ou #SelectionStyle_None.
	;  dÉpaisseur:            Epaisseur de la ligne de cadre ou #SelectionStyle_Ignore pour ignorer ce paramètre. Non utilisé si eType est #SelectionStyle_Default ou #SelectionStyle_None.
	;  dDistance:             Distance de la ligne du cadre à la bordure de l'objet ou #SelectionStyle_Ignore pour ignorer ce paramètre.
	;  Résultat:              #True si l'état du cadre sélectionné a été défini ou #False si l'objet n'existe pas.
	;}
	Procedure.i SetObjectSelectionStyle(iObject.i, eType.i=#SelectionStyle_Ignore, iColor.i=#SelectionStyle_Ignore, dThickness.d=#SelectionStyle_Ignore, dDistance.d=#SelectionStyle_Ignore)
		
		Protected *Object.Object, bResult.i = #False
		
		While _ExObjectID_(@*Object, iObject)
			
			If eType = #SelectionStyle_Default And iObject <> #Object_Default
				If *Object\pSelectionStyle <> @EditorFactory\DefaultObject\pSelectionStyle
					ChangeCurrentElement(EditorFactory\lObjectStyle(), *Object\pSelectionStyle)
					DeleteElement(EditorFactory\lObjectStyle())
				EndIf
				*Object\pSelectionStyle = @EditorFactory\DefaultObject\pSelectionStyle
			Else
				If *Object\pSelectionStyle = @EditorFactory\DefaultObject\pSelectionStyle And iObject <> #Object_Default
					*Object\pSelectionStyle = AddElement(EditorFactory\lObjectStyle())
					CopyStructure(EditorFactory\DefaultObject\pSelectionStyle, *Object\pSelectionStyle, ObjectStyle)
				EndIf
				If eType <> #SelectionStyle_Ignore      : *Object\pSelectionStyle\eType      = eType      : EndIf
				If iColor <> #SelectionStyle_Ignore     : *Object\pSelectionStyle\iColor     = iColor     : EndIf
				If dThickness <> #SelectionStyle_Ignore : *Object\pSelectionStyle\dThickness = dThickness : EndIf
				If dDistance <> #SelectionStyle_Ignore  : *Object\pSelectionStyle\dDistance  = dDistance  : EndIf
			EndIf
			If *Object\pParentFrame
				PostRedrawEvent(*Object\pParentFrame\pObjectManager)
			EndIf
			
			bResult = #True
		Wend
		
		ProcedureReturn bResult
		
	EndProcedure
	
	
	;{ Defines the view box for the drawing of child objects, which means child objects will shifted and will be not displayed outside the view box. It can be used for example to design a PanelGadget or ScrollAreaGadget.
	;  iObject:               Number of the object.
	;  iFrameIndex:           An index of the frame (starting with 0) or #Frame_ViewedFrame to use the currently shown frame.
	;  iViewBoxX:             Local X-position of the clipping for inner child objects. 0 means that the clipping is exactly at the edge of the object.
	;  iViewBoxY:             Local Y-position of the clipping for inner child objects. 0 means that the clipping is exactly at the edge of the object.
	;  iViewBoxWidth:         Width of the clipping area for inner child objects. Add #Boundary_ParentSize to a value (#Boundary_ParentSize ± value) to make the width relative to the object size.
	;  iViewBoxHeight:        Height of the clipping area for inner child objects. Add #Boundary_ParentSize to a value (#Boundary_ParentSize ± value) to make the height relative to the object size.
	;  bEnabledClipping:      #True, to enable the clipping, or #False, to disable the clipping (child objects will be drawn over their parent's border).
  ;  Result:                #True if the view box is set or #False if the object or frame does not exist.
	;
	;  Définit la boîte de vue pour le dessin des objets enfants, ce qui signifie que les objets enfants seront décalés et ne seront pas affichés en dehors de la boîte de vue. Il peut être utilisé par exemple pour concevoir un PanelGadget ou un ScrollAreaGadget.
	;  iObject:               Numéro de l'objet.
	;  iFrameIndex:           Un index du cadre (commençant par 0) ou #Frame_ViewedFrame pour utiliser le cadre actuellement affiché.
	;  iViewBoxX:             Position locale en X du découpage pour les objets enfants internes. 0 signifie que le découpage est exactement au bord de l'objet.
	;  iViewBoxY:             Position locale en Y de l'écrêtage pour les objets enfants internes. 0 signifie que l'écrêtage se trouve exactement au bord de l'objet.
	;  iViewBoxWidth:         Largeur de la zone d'écrêtage pour les objets enfants internes. Ajoutez #Boundary_ParentSize à une valeur (#Boundary_ParentSize ± valeur) pour que la largeur soit relative à la taille de l'objet.
	;  iViewBoxHeight:        hauteur de la zone d'écrêtage pour les objets enfants internes. Ajoutez #Boundary_ParentSize à une valeur (#Boundary_ParentSize ± valeur) pour que la hauteur soit relative à la taille de l'objet.
	;  bEnabledClipping:      #True, pour activer l'écrêtage, ou #False, pour désactiver l'écrêtage (les objets enfants seront dessinés par-dessus la bordure de leur parent).
	;  Resultat:              #True si la boîte de vue est définie ou #False si l'objet ou le cadre n'existe pas.
	;}
	Procedure.i SetObjectFrameViewBox(iObject.i, iFrameIndex.i, iX.i=0, iY.i=0, iWidth.i=#Boundary_ParentSize, iHeight.i=#Boundary_ParentSize, bEnabledClipping.i=#True)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		Protected *Frame.Frame : _ObjectFrameID_(*Frame, *Object, iFrameIndex, #False)
		
		*Frame\ViewBox\bEnabled = bEnabledClipping
		*Frame\ViewBox\iX       = iX
		*Frame\ViewBox\iY       = iY
		*Frame\ViewBox\iWidth   = iWidth
		*Frame\ViewBox\iHeight  = iHeight
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Defines the offset of the drawing of the object's frame content, It is useful to make a ScrollAreaGadget.
	;  For example, by clicking on a button of a scroll bar to shift the image of the object relative to the parent's frame.
	;  The set value is automatically adjusted between 0 and InnerWidth-ParentWidth or 0 and InnerHeight-ParentHeight.
	;  iObject:               Number of the object.
	;  iFrameIndex:           An index of the frame (starting with 0) or #Frame_ViewedFrame to use the currently shown frame.
	;  iX:                    The X-offset of the drawed frame content. In other words, how the drawing of child objects will shifted.
	;  iY:                    The Y-offset of the drawed frame content. In other words, how the drawing of child objects will shifted.
	;  iMode:                 #PB_Absolute To change the absolute offset Or #PB_Relative To change the offset relative To the old value.
	;  Result:                #True If the offset has been changed Or #False If the object does Not exist.
	;
	;  Définit le décalage du dessin du contenu du cadre de l'objet, Utile pour faire des ScrollAreaGadget, l'objet devras être un conteneur.
  ;  Par exemple, C'est utile pour réaliser un ScrollAreaGadget, en cliquant sur un bouton d'une barre de défilement pour décaler l'image de l'objet par rapport au cadre du parent.
	;  La valeur définie est automatiquement ajustée entre 0 et InnerWidth-ParentWidth ou 0 et InnerHeight-ParentHeight.
  ;  iObject:               Numéro de l'objet.
	;  iFrameIndex:            Un index du cadre (commençant par 0) ou #Frame_ViewedFrame pour utiliser le cadre actuellement affiché.
	;  iX:                    Le décalage X du contenu du cadre dessiné. En d'autres termes, comment le dessin des objets enfants sera décalé.
	;  iY:                    Le décalage Y du contenu du cadre dessiné. En d'autres termes, comment le dessin des objets enfants sera décalé.
	;  iMode:                 #PB_Absolute pour modifier le décalage absolu ou #PB_Relative pour modifier le décalage par rapport à l'ancienne valeur.
	;  Résultat:              #True si le décalage a été modifié ou #False si l'objet n'existe pas.
	;}
	Procedure.i SetObjectFrameInnerOffset(iObject.i, iFrameIndex.i, iX.i=0, iY.i=0, iMode.i=#PB_Absolute)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #False)
		Protected *Frame.Frame : _ObjectFrameID_(*Frame, *Object, iFrameIndex, #False)
		
		Select iMode
			Case #PB_Absolute
				*Frame\InnerArea\iX    = iX
				*Frame\InnerArea\iY    = iY
			Case #PB_Relative
				*Frame\InnerArea\iX    + iX
				*Frame\InnerArea\iY    + iY
		EndSelect
		If *Frame\InnerArea\iX < 0
			*Frame\InnerArea\iX = 0
		ElseIf *Frame\InnerArea\iX > *Frame\InnerArea\iWidth - DecodeParentSize(*Frame\ViewBox\iWidth, *Frame\pParentObject\iWidth)
			If *Frame\InnerArea\iWidth - DecodeParentSize(*Frame\ViewBox\iWidth, *Frame\pParentObject\iWidth) > 0
				*Frame\InnerArea\iX = *Frame\InnerArea\iWidth - DecodeParentSize(*Frame\ViewBox\iWidth, *Frame\pParentObject\iWidth)
			Else
				*Frame\InnerArea\iX = 0
			EndIf
		EndIf
		If *Frame\InnerArea\iY < 0
			*Frame\InnerArea\iY = 0
		ElseIf *Frame\InnerArea\iY > *Frame\InnerArea\iHeight - DecodeParentSize(*Frame\ViewBox\iHeight, *Frame\pParentObject\iHeight)
			If *Frame\InnerArea\iHeight - DecodeParentSize(*Frame\ViewBox\iHeight, *Frame\pParentObject\iHeight) > 0
				*Frame\InnerArea\iY = *Frame\InnerArea\iHeight - DecodeParentSize(*Frame\ViewBox\iHeight, *Frame\pParentObject\iHeight)
			Else
				*Frame\InnerArea\iY = 0
			EndIf
		EndIf
		
		PostRedrawEvent(*Object\pParentFrame\pObjectManager)
		
		ProcedureReturn #True
		
	EndProcedure
	
	
	;{ Sets the cursor selection frame style.
	;  iCanvasGadget:         Canvas gadget number.
	;  eType:                 One of the following style types:
	;                          - #SelectionStyle_None:    Hide the selection frame.
	;                          - #SelectionStyle_Solid:   Solid frame line.
	;                          - #SelectionStyle_Dotted:  Dotted frame line.
	;                          - #SelectionStyle_Dashed:  Dahsed frame line.
	;                          - #SelectionStyle_Ignore:  Ignore this parameter.
	;                         You can combine (|) the style type with #SelectionStyle_Partially to allow selection by partially overlap.
	;  iColor:                RGBA-Color of the frame or #SelectionStyle_Ignore to ignore this parameter.
  ;  dThickness:            Thickness of the frame line or #SelectionStyle_Ignore to ignore this parameter.
	;  iBackgroundColor.i     The color within the selection or #SelectionStyle_Ignore to ignore this parameter.
	;
  ;  Définit le style du cadre de sélection du curseur de la souris.
	;  iCanvasGadget.i        Le numéro du Canevas gadget.
	;  eType :                Un des types de style suivants:
	;                          - #SelectionStyle_None: Masque le cadre de sélection.
	;                          - #SelectionStyle_Solid: ligne de cadre solide.
	;                          - #SelectionStyle_Dotted: Ligne de cadre en pointillés.
	;                          - #SelectionStyle_Dashed:  Dahsed frame line.
  ;                          - #SelectionStyle_Ignore:  Ignorer ce paramètre.
	;                          - #SelectionStyle_Partially: Vous pouvez combiner cette constante (|) avec le type de style pour permettre la sélection par partiel.
 	;  iColor:                Couleur RGBA du cadre ou #SelectionStyle_Ignore pour ignorer ce paramètre.
  ;  dThickness :           Epaisseur de la ligne du cadre ou #SelectionStyle_Ignore pour ignorer ce paramètre.
	;  iBackgroundColor.i     La couleur à l’intérieur de la sélection ou #SelectionStyle_Ignore pour ignorer ce paramètre.
	;}
	Procedure   SetCursorSelectionStyle(iCanvasGadget.i, eType.i=#SelectionStyle_Ignore, iColor.i=#SelectionStyle_Ignore, dThickness.d=#SelectionStyle_Ignore, iBackgroundColor.i=#SelectionStyle_Ignore)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget)
		
		If eType <> #SelectionStyle_Ignore
			*ObjectManager\CursorSelectionStyle\eType            = eType
		EndIf
		If iColor <> #SelectionStyle_Ignore
			*ObjectManager\CursorSelectionStyle\iColor           = iColor
		EndIf
		If dThickness <> #SelectionStyle_Ignore
			*ObjectManager\CursorSelectionStyle\dThickness       = dThickness
		EndIf
		If iBackgroundColor <> #SelectionStyle_Ignore
			*ObjectManager\CursorSelectionStyle\iBackgroundColor = iBackgroundColor
		EndIf
		PostRedrawEvent(*ObjectManager)
		
	EndProcedure
	
	
	;{ Gets the shown cursor of the specified canvas gadget.
	;  iCanvasGadget:         Canvas gadget number.
	;  Result:                A #PB_Cursor_* constant, #PB_Cursor_Custom or 0 if the canvas gadget doesn't exist.
	;
	;  Renvoie le curseur affiché du Ca,=nevas gadget spécifié.
	;  iCanvasGadget :        Numéro du gadget de toile.
	;  Résultat :             Une constante #PB_Cursor_*, #PB_Cursor_Custom ou 0 si le Canevas gadget n'existe pas.
	;}
	Procedure.i GetCanvasCursor(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0)
		
		ProcedureReturn *ObjectManager\eCursor
		
	EndProcedure
	
	
	;{ Gets the specified boundary value of the specified object
	;  iObject:               Object number.
	;  eBoundary:             One of the following constants:
	;                          - #Boundary_MinX:       Minimal X-position.
	;                          - #Boundary_MinY:       Minimal Y-position.
	;                          - #Boundary_MaxX:       Maximal X-position.
	;                          - #Boundary_MaxY:       Maximal Y-position.
	;                          - #Boundary_MinWidth:   Minimal width.
	;                          - #Boundary_MinHeight:  Minimal height.
	;                          - #Boundary_MaxWidth:   Maximal width.
	;                          - #Boundary_MaxHeight:  Maximal height.
	;  Result:                The boundary value, #Boundary_None if the specified boundary is not set or 0 if the object doesn't exist.
	;
	;  Obtient la valeur limite spécifiée de l'Objet spécifié
	;  iObject:               Numéro de l'Objet.
	;  eBoundary:             Une des constantes suivantes:
	;                          - #Boundary_MinX: Position X minimale.
	;                          - #Boundary_MinY: Position Y minimale.
	;                          - #Boundary_MaxX: Maximal X-position.
	;                          - #Boundary_MaxY: Maximal Y-position.
	;                          - #Boundary_MinWidth: Largeur minimale.
	;                          - #Boundary_MinHeight: Hauteur minimale.
	;                          - #Boundary_MaxWidth: Largeur maximale.
	;                          - #Boundary_MaxHeight: Hauteur maximale.
	;  Résultat:              La valeur de la limite, #Boundary_None si la limite spécifiée n'est pas définie ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectBoundary(iObject.i, eBoundary.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		With *Object\Boundaries
			Select eBoundary
				Case #Boundary_MinX
					If \iMinX & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						ProcedureReturn \iMinX - #Boundary_ParentSize
					Else
						ProcedureReturn \iMinX
					EndIf
				Case #Boundary_MinY
					If \iMinY & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						ProcedureReturn \iMinY - #Boundary_ParentSize
					Else
						ProcedureReturn \iMinY
					EndIf
				Case #Boundary_MaxX
					If \iMaxX & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						ProcedureReturn \iMaxX - #Boundary_ParentSize
					Else
						ProcedureReturn \iMaxX
					EndIf
				Case #Boundary_MaxY
					If \iMaxY & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						ProcedureReturn \iMaxY - #Boundary_ParentSize
					Else
						ProcedureReturn \iMaxY
					EndIf
				Case #Boundary_MinWidth
					If \iMinWidth & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						ProcedureReturn \iMinWidth - #Boundary_ParentSize
					Else
						ProcedureReturn \iMinWidth
					EndIf
				Case #Boundary_MinHeight
					If \iMinHeight & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						ProcedureReturn \iMinHeight - #Boundary_ParentSize
					Else
						ProcedureReturn \iMinHeight
					EndIf
				Case #Boundary_MaxWidth
					If \iMaxWidth & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						ProcedureReturn \iMaxWidth - #Boundary_ParentSize
					Else
						ProcedureReturn \iMaxWidth
					EndIf
				Case #Boundary_MaxHeight
					If \iMaxHeight & #Boundary_ParentSizeMask = #Boundary_ParentSize & #Boundary_ParentSizeMask
						ProcedureReturn \iMaxHeight - #Boundary_ParentSize
					Else
						ProcedureReturn \iMaxHeight
					EndIf
				Default
					ProcedureReturn 0
			EndSelect
		EndWith
		
	EndProcedure
	
	
	;{ Gets the shown cursor of the specified object.
	;  iObject:               Object number.
	;  Result:                A #PB_Cursor_* constant, #PB_Cursor_Custom or 0 if the object doesn't exist.
	;
	;  Obtient le curseur affiché quand la souris passe sur l'objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  Résultat:              Une constante #PB_Cursor_*, #PB_Cursor_Custom ou 0 si l'objet n'existe pas.
	;}
	Procedure.i GetObjectCursor(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ProcedureReturn *Object\eCursor
		
	EndProcedure
	
	
	;{ Gets the custom data value of the specified object.
	;  iObject:               Object number.
	;  Result:                The data value or 0 if the object doesn't exist.
	;
	;  Renvoie la valeur personnalisées de l'objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  Résultat:              La valeur de la donnée ou 0 si l'objet n'existe pas.
	;}
	Procedure.i GetObjectData(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ProcedureReturn *Object\iData
		
	EndProcedure
	
	
	;{ Gives a custom value from the specified object.
	;  iObject:               Object number.
	;  sName:                 Name of the custom value.
	;  Result:                The value or an empty string if the object doesn't exist.
	;
	;  Renvoie la valeur personnalisée de l'Objet spécifié en fonction de ça clef.
	;  iObject:               Numéro de l'Objet.
	;  sNom:                  Nom de la clef.
  ;  Résultat:              La valeur de la clef de l'Objet ou une chaîne vide si l'Objet n'existe pas.
	;}
	Procedure.s GetObjectDictionary(iObject.i, sName.s)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, "")
		
		If FindMapElement(*Object\msAttribute(), sName)
			ProcedureReturn *Object\msAttribute()
		Else
			ProcedureReturn ""
		EndIf
		
	EndProcedure
	
	
	;{ Gives a combination of all added handles at the specified object.
	;  iObject:               Object number.
	;  Result:                A combination of all handle types* added at the object.
  ;                         * See AddObjectHandle().
	
	;  Donne une combinaison de toutes les poignées ajoutées à l'Objet spécifié.
  ;  iObject:               Numéro de l'Objet.
  ;  Résultat:              Une combinaison de tous les types de Poignées* ajoutés à l'Objet.
  ;                         * Voir AddObjectHandle()
	;}
	Procedure.i GetObjectHandles(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #Handle_None)
		
		ProcedureReturn *Object\eHandle
		
	EndProcedure
	
	
	;{ Gets the shown cursor of the specified handle of the specified object.
	;  iObject:               Object number.
	;  eType:                 A valid handle constant (see AddObjectHandle()).
	;  Result:                A #PB_Cursor_* constant, #PB_Cursor_Custom or 0 if the handle or object doesn't exist.
	;
	; Renvoie le curseur affiché de la souris quand celle-ci passe sur la poignée spécifiée de l'objet spécifié.
	; iObject :               Numéro de l'objet.
	; eType :                 Une constante de poignée valide (voir AddObjectHandle()).
	; Result :                Une constante #PB_Cursor_*, #PB_Cursor_Custom ou 0 si le handle ou l'objet n'existe pas.
	;}
	Procedure.i GetObjectHandleCursor(iObject.i, eType.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		Protected iIndex.i
		
		For iIndex = 0 To #LastHandle
			If eType & (1<<iIndex)
				ProcedureReturn *Object\aHandle(iIndex)\eCursor
			EndIf
		Next
		
		ProcedureReturn 0
		
	EndProcedure
	
	
	;{ Get the drawing layer position of the specified object.
	;  iObject:               Object number.
	;  Result:                The layer position of the object or 0 if the object doesn't exist. The lowest layer position is 1. 
	;
	;  Renvoie la profondeur (Couche) de l'Objet spécifié.
	;  iObject :              Numéro de l'Objet.
	;  Résultat :             La position de la couche de l'Objet ou 0 si l'Objet n'existe pas, La position de la couche la plus basse est 1.
	;}
	Procedure.i GetObjectLayer(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ForEach *Object\pParentFrame\lpChildObject()
			If *Object\pParentFrame\lpChildObject() = *Object
				ProcedureReturn ListIndex(*Object\pParentFrame\lpChildObject()) + 1
			EndIf
		Next
		
	EndProcedure
	
	
	;{ Gets the height of the specified object.
	;  iObject:               Object number.
	;  Result:                The height of the object or 0 if the object doesn't exist.
	;
	;  Permet d'obtenir la hauteur de l'Objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  Résultat:              La hauteur de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectHeight(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ProcedureReturn *Object\iHeight
		
	EndProcedure
	
	
	;{ Gets the width of the specified object.
	;  iObject:               Object number.
	;  Result:                The width of the object or 0 if the object doesn't exist.
	;
	;  Obtient la largeur de l'Objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  Résultat:              La largeur de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectWidth(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ProcedureReturn *Object\iWidth
		
	EndProcedure
	
	
	;{ Gets the X position of the specified object.
	;  iObject:               Object number.
	;  eFlag:                 #Object_GlobalPosition or #Object_LocalPosition, to return the global canvas position or the local position in the parent object.
	;  Result:                The X position of the object or 0 if the object doesn't exist.
	;
	;  Retourne la position X de l'Objet spécifié.
  ;  iObject:               Numéro de l'Objet.
	;  eFlag :                #Object_GlobalPosition ou #Object_LocalPosition, pour retourner la position globale du canevas ou la position locale dans l'objet parent.
	;  Result:                La position X de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectX(iObject.i, eFlag.i=#Object_GlobalPosition)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		Select eFlag
			Case #Object_GlobalPosition
				ProcedureReturn GlobalX(*Object, *Object\iX)
			Case #Object_LocalPosition
				ProcedureReturn *Object\iX
		EndSelect
		
	EndProcedure
	
	
	;{ Gets the Y position of the specified object.
	;  iObject:               Object number.
	;  eFlag:                 #Object_GlobalPosition or #Object_LocalPosition, to return the global canvas position or the local position in the parent object.
	;  Result:                The Y position of the object or 0 if the object doesn't exist.
	;
	;  Retourne la position Y de l'Objet spécifié.
  ;  iObject:               Numéro de l'Objet.
	;  eFlag :                #Object_GlobalPosition ou #Object_LocalPosition, pour retourner la position globale du canevas ou la position locale dans l'objet parent.
	;  Result:                La position Y de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectY(iObject.i, eFlag.i=#Object_GlobalPosition)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		Select eFlag
			Case #Object_GlobalPosition
				ProcedureReturn GlobalX(*Object, *Object\iY)
			Case #Object_LocalPosition
				ProcedureReturn *Object\iY
		EndSelect
		
	EndProcedure
	
	
	;{ Gets the X movement step size of the specified object.
	;  iObject:               Object number.
	;  Result:                The X movement step size of the object or 0 if the object doesn't exist.
	;
	;  Renvoie la valeur du pas de déplacement X de l'Objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  Résultat:              La valeur du pas de déplacement X de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectMovementStepX(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ProcedureReturn *Object\Grid\iMoveX
		
	EndProcedure
	
	
	;{ Gets the Y movement step size of the specified object.
	;  iObject:               Object number.
	;  Result:                The Y movement step size of the object or 0 if the object doesn't exist.
	;
	;  Renvoie la valeur du pas de déplacement Y de l'Objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  Résultat:              La valeur du pas de déplacement Y de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectMovementStepY(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ProcedureReturn *Object\Grid\iMoveY
		
	EndProcedure
	
	
	;{ Gets the X resize step size of the specified object.
	;  iObject:               Object number.
	;  Result:                The X resize step size of the object or 0 if the object doesn't exist.
	;
	;  Renvoie la valeur du pas de redimensionnement X de l'Objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  Résultat:              La valeur du pas de redimensionnement X de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectResizeStepX(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ProcedureReturn *Object\Grid\iSizeX
		
	EndProcedure
	
	
	;{ Gets the Y resize step size of the specified object.
	;  iObject:               Object number.
	;  Result:                The Y resize step size of the object or 0 if the object doesn't exist.
	;
	;  Renvoie la valeur du pas de redimensionnement Y de l'Objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  Résultat:              La valeur du pas de redimensionnement Y de l'Objet ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectResizeStepY(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ProcedureReturn *Object\Grid\iSizeY
		
	EndProcedure
	
	
	;{ Gives the selection frame style type of the specified object.
	;  iObject:               Object number.
	;  Result:                One of the following style types:
	;                          - #SelectionStyle_None:    Hidden selection frame
	;                          - #SelectionStyle_Solid:   Solid frame line
	;                          - #SelectionStyle_Dotted:  Dotted frame line
  ;                          - #SelectionStyle_Dashed:  Dahsed frame line
	;                         If the object doesn't exist #SelectionStyle_None is returned.
	;
	;  Renvoie le type du style du cadre de sélection de l'Objet spécifié.
	;  iObject:               Numéro de l'Objet.
	;  Résultat:              Un des types de style suivants:
	;                          - #SelectionStyle_Solid:   Ligne Continue.
	;                          - #SelectionStyle_Dotted:  Ligne en pointillés.
	;                          - #SelectionStyle_Dashed:  Ligne tiret.
	;                          - #SelectionStyle_None:    Caché.
	;                         Si l'objet n'existe pas, #SelectionStyle_None est renvoyé.
	;}
	Procedure.i GetObjectSelectionStyle(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, #SelectionStyle_None)
		
		ProcedureReturn *Object\pSelectionStyle\eType
		
	EndProcedure
	
	
	;{ Gives the selection frame style color of the specified object.
	;  iObject:               Object number.
  ;  Result:                RGBA-Color of the frame or 0 if the canvas object doesn't exist.
	;
	;  Renvoie la couleur du style du cadre de sélection de l'Objet spécifié.
	;  iObjet:                Numéro de l'Objet.
	;  Résultat:              Couleur RGBA du cadre ou 0 si l'Objet n'existe pas.
	;}
	Procedure.i GetObjectSelectionStyleColor(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0)
		
		ProcedureReturn *Object\pSelectionStyle\iColor
		
	EndProcedure
	
	
	;{ Gives the selection frame style thickness of the specified object.
	;  iObject:               Object number.
	;  Result:                Thickness of the frame line or 0.0 if the object doesn't exist.
	;
	;  Renvoie l'épaisseur du style du cadre de sélection de l'Objet spécifié.
	;  iObjet:                Numéro de l'Objet.
	;  Résultat:              Épaisseur de la ligne du cadre ou 0.0 si l'Objet n'existe pas.
	;}
	Procedure.d GetObjectSelectionStyleThickness(iObject.i)
		
		Protected *Object.Object : _ObjectID_(*Object, iObject, 0.0)
		
		ProcedureReturn *Object\pSelectionStyle\dThickness
		
	EndProcedure
	
	
	;{ Gives the cursor selection frame style type.
	;  iCanvasGadget:         Canvas gadget number.
	;  Result:                One of the following style types:
	;                          - #SelectionStyle_None:    Hidden selection frame.
	;                          - #SelectionStyle_Solid:   Solid frame line.
	;                          - #SelectionStyle_Dotted:  Dotted frame line.
	;                          - #SelectionStyle_Dashed:  Dahsed frame line.
	;                         If the canvas gadget doesn't exist #SelectionStyle_None is returned.
	;
  ;  Renvoie le type du cadre de sélection du curseur.
	;  iCanvasGadget:         Numéro du Canevas gadget.
	;  Résultat :             Un des types de style suivants:
	;                          - #SelectionStyle_Solid:   Ligne continue.
	;                          - #SelectionStyle_Dotted:  Ligne en pointillés.
	;                          - #SelectionStyle_Dashed:  Ligne tiret.
	;                          - #SelectionStyle_None:    Le cadre de la sélection est caché
	;                         Si le Canevas gadget n'existe pas, #SelectionStyle_None est renvoyé.
	;}
	Procedure.i GetCursorSelectionStyle(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, #SelectionStyle_None)
		
		ProcedureReturn *ObjectManager\CursorSelectionStyle\eType & ~#SelectionStyle_Mode
		
	EndProcedure
	
	
	;{ Gives the cursor selection frame color.
	;  iCanvasGadget:         Canvas gadget number.
	;  Result:                RGBA-Color of the frame or 0 if the canvas gadget doesn't exist.
	;
	;  Renvoie la couleur du cadre de sélection du curseur de la souris sur le canvas spésifié.
	;  Résultat:              Couleur RGBA du cadre de la selection de la souris ou 0 si le Canevas gadget n'existe pas.
	;}
	Procedure.i GetCursorSelectionStyleColor(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0)
		
		ProcedureReturn *ObjectManager\CursorSelectionStyle\iColor
		
	EndProcedure
	
	
	;{ Gives the cursor selection frame background color.
	;  iCanvasGadget:         Canvas gadget number.
	;  Result:                RGBA-Color of the background or 0 if the canvas gadget doesn't exist.
	;
	;  Renvoie la couleur de fond du cadre de sélection du curseur de la souris sur le canvas spésifié.
	;  Résultat:              Couleur RGBA à l'interieur du cadre de la selection de la souris ou 0 si le Canevas gadget n'existe pas.
	;}
	Procedure.i GetCursorSelectionStyleBackgroundColor(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0)
		
		ProcedureReturn *ObjectManager\CursorSelectionStyle\iBackgroundColor
		
	EndProcedure
	
	
	;{ Gives the cursor selection frame style thickness.
	;  iCanvasGadget:         Canvas gadget number.
	;  Result:                Thickness of the frame line or 0.0 if the canvas gadget doesn't exist.
	;
	;  Renvoie l'épaisseur du style du cadre de sélection du curseur de la souris sur le canvas spésifié.
	;  Résultat:              Épaisseur de la ligne du cadre de la selection de la souris ou 0.0 si l'objet n'existe pas.
	;}
	Procedure.d GetCursorSelectionStyleThickness(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0.0)
		
		ProcedureReturn *ObjectManager\CursorSelectionStyle\dThickness
		
	EndProcedure
	
	
	;{ Gives the cursor selection frame style distance.
	;  iCanvasGadget:         Canvas gadget number.
	;  Result:                Distance of the frame line to the object border or 0.0 if the canvas gadget doesn't exist.
	;
	;  Renvoie la distance de style du cadre de sélection du curseur.
	;  iCanvasGadget:         Numéro du Canevas gadget.
	;  Résultat:              Distance de la ligne du cadre de selection de l'Objet par apport à l'Objet ou 0.0 si l'objet n'existe pas.
	;}
	Procedure.d GetCursorSelectionStyleDistance(iCanvasGadget.i)
		
		Protected *ObjectManager.ObjectManager : _ObjectManagerID_(*ObjectManager, iCanvasGadget, 0.0)
		
		ProcedureReturn *ObjectManager\CursorSelectionStyle\dDistance
		
	EndProcedure
	
	
	;{ Gives the object which is hovered by the mouse cursor.
	;  Result:                The object number or 0 if no object is hovered by the mouse cursor.
	;
	;  Donne l'objet qui est survolé par le curseur de la souris.
	;  Résultat:              Le numéro de l'objet ou 0 si aucun objet n'est survolé par le curseur de la souris.
	;}
	Procedure.i GetMouseHoveredObject()
		
		ForEach EditorFactory\lObjectManager()
			If EditorFactory\lObjectManager()\pHoveredObject
				ProcedureReturn EditorFactory\lObjectManager()\pHoveredObject\iObject
			EndIf
		Next
		
		ProcedureReturn 0
		
	EndProcedure
	
	
EndModule



; IDE Options = PureBasic 6.01 LTS beta 1 (Windows - x64)
; CursorPosition = 153
; Folding = DIE9-gCbIrR0LJJ9whkBAADPQSAAAABAAkBy
; EnableXP
; EnableCompileCount = 212
; EnableBuildCount = 0
; EnableExeConstant