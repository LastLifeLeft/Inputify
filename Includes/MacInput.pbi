; macOS input, included inside Module MainWindow: event taps stand in for the low level hooks, and the location
; selector catches its click with windows of its own, since a listen only tap cannot swallow it.

;{ Key translation
Procedure InitMacVK()
	Protected Loop

	; Positions of the ANSI layout. Letters, and the punctuation found in VKeyData, come from the typed character
	; instead (see MacKeyToVK) so they follow the user's layout like the Windows virtual key codes do.
	Restore MacVK
	Repeat
		Read.a Loop
		If Loop = 255 : Break : EndIf
		Read.a MacVK(Loop)
	ForEver
EndProcedure

Procedure MacKeyToVK(KeyCode, Event)
	Protected NSEvent, Characters, Text.s, Char

	If KeyCode > 127
		ProcedureReturn 0
	EndIf

	; The keypad keeps its own codes: its digits and signs are drawn the same, but they are other keys.
	If (KeyCode >= 65 And KeyCode <= 92) = #False
		NSEvent = CocoaMessage(0, 0, "NSEvent eventWithCGEvent:", Event)
		If NSEvent
			Characters = CocoaMessage(0, NSEvent, "charactersIgnoringModifiers")	; Shift still applies
			If Characters And CocoaMessage(0, Characters, "length") = 1
				Text = UCase(PeekS(CocoaMessage(0, Characters, "UTF8String"), -1, #PB_UTF8))
				Char = Asc(Text)

				If Char >= 'A' And Char <= 'Z'
					ProcedureReturn Char
				EndIf

				Select Text
					Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" : ProcedureReturn Char
					Case ";", ":" : ProcedureReturn 186
					Case "=", "+" : ProcedureReturn 187
					Case "," : ProcedureReturn 188
					Case "-" : ProcedureReturn 189
					Case "." : ProcedureReturn 190
					Case "/" : ProcedureReturn 191
					Case "`", "~" : ProcedureReturn 192
					Case "[" : ProcedureReturn 219
					Case "\" : ProcedureReturn 220
					Case "]" : ProcedureReturn 221
					Case "'" : ProcedureReturn 222
					Case "§" : ProcedureReturn 223
				EndSelect
			EndIf
		EndIf
	EndIf

	ProcedureReturn MacVK(KeyCode)
EndProcedure
;}

;{ Event taps
Procedure TrackMouseButton(VKey, Down)
	If Down
		If Not InputArray(VKey)
			InputArray(VKey) = PopupWindow::Create(VKey)
		EndIf
	ElseIf InputArray(VKey)
		PopupWindow::Hide(InputArray(VKey))
		InputArray(VKey) = #False
	EndIf
EndProcedure

ProcedureC EventTapCallback(Proxy, Type.l, Event, *UserInfo)
	Protected KeyCode, Flags.q, VKey, Mask
	
	Select Type
		Case #kCGEventTapDisabledByTimeout, #kCGEventTapDisabledByUserInput	; macOS turns a slow tap off: turn it back on
			If KeyTap : CGEventTapEnable(KeyTap, #True) : EndIf
			If MouseTap : CGEventTapEnable(MouseTap, #True) : EndIf
			
		Case #kCGEventKeyDown, #kCGEventKeyUp
			KeyCode = CGEventGetIntegerValueField(Event, #kCGKeyboardEventKeycode)
			VKey = MacKeyToVK(KeyCode, Event)
			If VKey
				ProcessKey(VKey, Bool(Type = #kCGEventKeyDown))
			EndIf
			
		Case #kCGEventFlagsChanged										; Modifiers have no key events, only a new flag set
			KeyCode = CGEventGetIntegerValueField(Event, #kCGKeyboardEventKeycode)
			Flags = CGEventGetFlags(Event)
			
			; Each side has its own device bit, so releasing one Shift while the other is held reads as a release.
			Select KeyCode
				Case 56 : VKey = #VK_SHIFT : Mask = $2
				Case 60 : VKey = #VK_SHIFT : Mask = $4
				Case 59 : VKey = #VK_CONTROL : Mask = $1
				Case 62 : VKey = #VK_CONTROL : Mask = $2000
				Case 58 : VKey = #VK_MENU : Mask = $20
				Case 61 : VKey = #VK_MENU : Mask = $40
				Case 55 : VKey = #VK_LWIN : Mask = $8
				Case 54 : VKey = #VK_LWIN : Mask = $10
				Case 57													; Caps Lock reports each toggle, never a release
					ProcessKey(#VK_CAPITAL, #True)
					ProcessKey(#VK_CAPITAL, #False)
			EndSelect
			
			If VKey
				ProcessKey(VKey, Bool(Flags & Mask))
			EndIf
			
		Case #kCGEventLeftMouseDown, #kCGEventLeftMouseUp
			TrackMouseButton(#VK_LBUTTON, Bool(Type = #kCGEventLeftMouseDown))
			
		Case #kCGEventRightMouseDown, #kCGEventRightMouseUp
			TrackMouseButton(#VK_RBUTTON, Bool(Type = #kCGEventRightMouseDown))
			
		Case #kCGEventOtherMouseDown, #kCGEventOtherMouseUp
			If CGEventGetIntegerValueField(Event, #kCGMouseEventButtonNumber) = 2
				TrackMouseButton(#VK_MBUTTON, Bool(Type = #kCGEventOtherMouseDown))
			EndIf
	EndSelect
	
	ProcedureReturn Event
EndProcedure

Procedure CommonModes()
	; CFRunLoop tells the common modes apart by pointer, so it has to be the framework's own kCFRunLoopCommonModes:
	; an equal string adds the source to a mode of that name, which never runs.
	Protected Symbol.s = "kCFRunLoopCommonModes", *Name = UTF8(Symbol), *Mode.Integer = dlsym(#RTLD_DEFAULT, *Name)
	
	FreeMemory(*Name)
	ProcedureReturn *Mode\i
EndProcedure

Procedure CreateTap(Mask.q, *Source.Integer)
	Protected Tap = CGEventTapCreate(#kCGSessionEventTap, #kCGHeadInsertEventTap, #kCGEventTapOptionListenOnly, Mask, @EventTapCallback(), #Null)
	Protected Mode = CommonModes()

	If Tap
		*Source\i = CFMachPortCreateRunLoopSource(#Null, Tap, 0)
		CFRunLoopAddSource(CFRunLoopGetMain(), *Source\i, Mode)	; Common modes, so keys still show while a menu is tracked
	EndIf

	ProcedureReturn Tap
EndProcedure

Procedure ReleaseTap(Tap, Source)
	Protected Mode = CommonModes()

	CGEventTapEnable(Tap, #False)
	CFRunLoopRemoveSource(CFRunLoopGetMain(), Source, Mode)
	CFMachPortInvalidate(Tap)
	CFRelease(Source)
	CFRelease(Tap)
EndProcedure

Procedure StartKeyboardTap()
	If KeyTap
		ProcedureReturn
	EndIf

	; Keys need Input Monitoring: without it the tap would be created but stay deaf. IOHIDCheckAccess tells an undecided
	; user, who gets macOS's own prompt, from one who refused it, who is offered System Settings instead. A grant only
	; applies to the next launch.
	Select IOHIDCheckAccess(#kIOHIDRequestTypeListenEvent)
		Case #kIOHIDAccessTypeGranted
			KeyTap = CreateTap(#KeyboardMask, @KeySource)
		Case #kIOHIDAccessTypeUnknown
			If Not PermissionAsked
				PermissionAsked = #True
				CGRequestListenEventAccess()
			EndIf
		Default
			If Not PermissionAsked
				PermissionAsked = #True
				If MessageRequester(General::#AppName, Language(#Lng_InputMonitoring), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
					RunProgram("open", "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent", "")
				EndIf
			EndIf
	EndSelect
EndProcedure

Procedure StopKeyboardTap()
	If KeyTap
		ReleaseTap(KeyTap, KeySource)
		KeyTap = 0
		KeySource = 0
	EndIf
EndProcedure

Procedure StartMouseTap()
	If Not MouseTap
		MouseTap = CreateTap(#MouseMask, @MouseSource)
	EndIf
EndProcedure

Procedure StopMouseTap()
	If MouseTap
		ReleaseTap(MouseTap, MouseSource)
		MouseTap = 0
		MouseSource = 0
	EndIf
EndProcedure
;}

;{ Popup location selector
Procedure DrawLocationInformation(X, Y)
	Protected Scale.d = PopupWindow::PixelRatio(), Text.s = "x: " + Str(X) + " y: " + Str(Y)

	If IsImage(LocationImage)
		FreeImage(LocationImage)
	EndIf

	LocationImage = CreateImage(#PB_Any, 101 * Scale, 50 * Scale, 32, #PB_Image_Transparent)
	StartVectorDrawing(ImageVectorOutput(LocationImage))
	ScaleCoordinates(Scale, Scale)

	; The crosshair, its centre left open like the Windows one
	AddPathBox(LocationOffsetX, LocationOffsetY - 12, 1, 10)
	AddPathBox(LocationOffsetX, LocationOffsetY + 3, 1, 10)
	AddPathBox(LocationOffsetX - 12, LocationOffsetY, 10, 1)
	AddPathBox(LocationOffsetX + 3, LocationOffsetY, 10, 1)
	AddPathCircle(LocationOffsetX + 0.5, LocationOffsetY + 0.5, 2.5)
	VectorSourceColor($FFFFFFFF)
	FillPath(#PB_Path_Preserve)
	VectorSourceColor($FF000000)
	StrokePath(1)

	AddPathBox(0, 30, 101, 20)
	VectorSourceColor(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_Trackbar))
	FillPath()
	AddPathBox(1, 31, 99, 18)
	VectorSourceColor(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold))
	FillPath()

	VectorFont(General::OptionFont, 12)
	VectorSourceColor(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_FrontHot))
	MovePathCursor((101 - VectorTextWidth(Text)) * 0.5, 40 - VectorTextHeight(Text) * 0.5)
	DrawVectorText(Text)
	StopVectorDrawing()

	CocoaMessage(0, LocationLayer, "setContents:", ImageID(LocationImage))
EndProcedure

Procedure FollowMouse()
	Protected X = DesktopMouseX(), Y = DesktopMouseY()

	If X <> LocationLastX Or Y <> LocationLastY
		LocationLastX = X
		LocationLastY = Y
		DrawLocationInformation(X, Y)
		ResizeWindow(LocationInformationWindow, X - LocationOffsetX, Y - LocationOffsetY, #PB_Ignore, #PB_Ignore)
	EndIf
EndProcedure

Procedure QuitPopupPlacement()
	RemoveWindowTimer(LocationInformationWindow, #Timer_Location)

	ForEach LocationInformationWindows()
		UnbindGadgetEvent(GetWindowData(LocationInformationWindows()), @Handler_LocationCanvas())
		CloseWindow(LocationInformationWindows())
	Next
	ClearList(LocationInformationWindows())

	HideWindow(LocationInformationWindow, #True)
	CocoaMessage(0, 0, "NSCursor unhide")
EndProcedure

Procedure Handler_Location()
	Protected Loop, DesktopCount, Window, Canvas, Alpha.d = 150 / 255

	If ListSize(LocationInformationWindows())
		ProcedureReturn
	EndIf

	DesktopCount = ExamineDesktops() - 1

	For Loop = 0 To DesktopCount
		Window = OpenWindow(#PB_Any, DesktopX(Loop), DesktopY(Loop), DesktopWidth(Loop), DesktopHeight(Loop), "", #PB_Window_Invisible | #PB_Window_BorderLess)
		AddElement(LocationInformationWindows())
		LocationInformationWindows() = Window

		CocoaMessage(0, WindowID(Window), "setLevel:", 101)
		CocoaMessage(0, WindowID(Window), "setAlphaValue:@", @Alpha)
		CocoaMessage(0, WindowID(Window), "setHasShadow:", #NO)

		Canvas = CanvasGadget(#PB_Any, 0, 0, DesktopWidth(Loop), DesktopHeight(Loop), #PB_Canvas_Keyboard)
		StartDrawing(CanvasOutput(Canvas))
		Box(0, 0, OutputWidth(), OutputHeight(), $141414)
		StopDrawing()
		SetWindowData(Window, Canvas)
		BindGadgetEvent(Canvas, @Handler_LocationCanvas())

		HideWindow(Window, #False)
	Next

	FirstElement(LocationInformationWindows())
	SetActiveWindow(LocationInformationWindows())
	SetActiveGadget(GetWindowData(LocationInformationWindows()))

	LocationLastX = -1
	FollowMouse()
	CocoaMessage(0, WindowID(LocationInformationWindow), "orderFrontRegardless")
	AddWindowTimer(LocationInformationWindow, #Timer_Location, 15)
	CocoaMessage(0, 0, "NSCursor hide")
EndProcedure

Procedure Handler_LocationCanvas()
	Select EventType()
		Case #PB_EventType_LeftButtonDown
			PopupWindow::SetPopupOrigin(DesktopMouseX(), DesktopMouseY())
			QuitPopupPlacement()
		Case #PB_EventType_RightButtonDown
			QuitPopupPlacement()
		Case #PB_EventType_KeyDown
			If GetGadgetAttribute(EventGadget(), #PB_Canvas_Key) = #PB_Shortcut_Escape
				QuitPopupPlacement()
			EndIf
	EndSelect
EndProcedure

Procedure Handler_MacTimer()
	If EventTimer() = #Timer_Location
		FollowMouse()
	EndIf
EndProcedure
;}

DataSection ;{ macOS key code -> Windows VK, for the keys without a meaningful character
	MacVK:
	Data.a 36, #VK_RETURN, 76, #VK_RETURN, 48, #VK_TAB, 49, #VK_SPACE, 51, #VK_BACK, 53, #VK_ESCAPE, 117, #VK_DELETE, 114, #VK_INSERT
	Data.a 123, #VK_LEFT, 124, #VK_RIGHT, 125, #VK_DOWN, 126, #VK_UP, 115, #VK_HOME, 119, #VK_END, 116, #VK_PRIOR, 121, #VK_NEXT
	Data.a 122, #VK_F1, 120, #VK_F1 + 1, 99, #VK_F1 + 2, 118, #VK_F1 + 3, 96, #VK_F1 + 4, 97, #VK_F1 + 5, 98, #VK_F1 + 6, 100, #VK_F1 + 7
	Data.a 101, #VK_F1 + 8, 109, #VK_F1 + 9, 103, #VK_F1 + 10, 111, #VK_F1 + 11, 105, #VK_F1 + 12, 107, #VK_F1 + 13, 113, #VK_F1 + 14
	Data.a 106, #VK_F1 + 15, 64, #VK_F1 + 16, 79, #VK_F1 + 17, 80, #VK_F1 + 18, 90, #VK_F1 + 19
	Data.a 82, #VK_NUMPAD0, 83, #VK_NUMPAD0 + 1, 84, #VK_NUMPAD0 + 2, 85, #VK_NUMPAD0 + 3, 86, #VK_NUMPAD0 + 4, 87, #VK_NUMPAD0 + 5
	Data.a 88, #VK_NUMPAD0 + 6, 89, #VK_NUMPAD0 + 7, 91, #VK_NUMPAD0 + 8, 92, #VK_NUMPAD0 + 9
	Data.a 65, #VK_DECIMAL, 67, #VK_MULTIPLY, 69, #VK_ADD, 75, #VK_DIVIDE, 78, #VK_SUBTRACT, 81, 187
	; The ANSI digit row and punctuation, for layouts where these positions type something VKeyData has no label for
	Data.a 18, '1', 19, '2', 20, '3', 21, '4', 23, '5', 22, '6', 26, '7', 28, '8', 25, '9', 29, '0'
	Data.a 41, 186, 24, 187, 43, 188, 27, 189, 47, 190, 44, 191, 50, 192, 33, 219, 42, 220, 30, 221, 39, 222, 10, 223
	Data.a 255
EndDataSection ;}
