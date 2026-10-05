Module MainWindow
	EnableExplicit
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
		UseModule VK
	CompilerEndIf
	; Private variables, structures and constants
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	;{ Notification
	Structure NOTIFYICONDATA_ Align #PB_Structure_AlignC
		cbSize.l
		hwnd.i
		uId.l
		uFlags.l
		uCallbackMessage.l
		hIcon.i
		StructureUnion
			szTip.s{64}
			szTipEx.s{128}
		EndStructureUnion
		dwState.l
		dwStateMask.l
		szInfo.s{256}
		StructureUnion
			uTimeout.l
			uVersion.l
		EndStructureUnion
		szInfoTitle.s{64}
		dwInfoFlags.l
		guidItem.GUID
		hBalloonIcon.i
	EndStructure
	
	Global SysTrayInfo.NOTIFYICONDATA_
		
	#NIIF_INFO  = $1
		
	;}
	CompilerEndIf
	
	;{ Language
	Enumeration 
		#Lng_DarkMode
		#Lng_Scale
		#Lng_TrackMouse
		#Lng_Duration
		#Lng_Combo
		#Lng_Location
		#Lng_CheckUpdate
		#Lng_InputColor
		
		#ToolTip_DarkMode
		#ToolTip_Scale
		#ToolTip_Mouse
		#ToolTip_Duration
		#ToolTip_Combo
		#ToolTip_TrackInput
		#ToolTip_CheckUpdate
		
		#Lng_General
		#Lng_Behavior
		#Lng_About               
		#Lng_Controller
		#Lng_UserInterface
		#Lng_Input
		#Lng_Misc
		
		#Lng_TrackKeyboard
		#Lng_Menu_Options
		#Lng_Menu_Quit
		
		#Lng_FirstStart
		
		#Lng_LightTheme
		#Lng_DarkTheme
		#Lng_BlueTheme
		#Lng_PinkTheme
		#Lng_InputMonitoring
		
		#Lng_Markdown
		
		#_Lng_Count
	EndEnumeration
	
	Global Dim Language.s(#_Lng_Count)
	;}
	
	;{ Windows and gadgets
	#Window = 0
	#Window_SingleInstance = 1
	
	Enumeration ;Gadget
		#Toggle_DarkMode
		#Trackbar_Scale
		#Toggle_TrackKeyboard
		#Toggle_TrackMouse
		#Trackbar_Duration
		#Toggle_Combo
		#Button_Location
		#Toggle_CheckUpdate
		#HyperLink_Website
		#Radio_Dark
		#Radio_Light
		#Radio_Pink
		#Radio_Blue
		
		#Title_UserInterface
		#Title_InputColor
		#Title_Input
		#Title_Misc
		
		#Text_Scale
		#Text_Duration
		
		#VList_Menu
		
		#Container_Appearance
		#ContainerCorner_Appearance
		
		#Container_Behavior
		#ContainerCorner_Behavior
		
		#Container_About
		#ContainerCorner_About
		#MarkDown
		
		#Container_Controller
		#ContainerCorner_Controller
	EndEnumeration
	
	#Systray = 0
	
	Enumeration ;Menu ID
		#Menu_KeyboardTracking
		#Menu_MouseTracking
		#Menu_Options
		#Menu_Quit
	EndEnumeration		
	;}
	
	;{ Appearance
	#Appearance_Window_Width = 1000
	#Appearance_Window_Height = 580
	#Appearance_Window_Margin = 140
	#Appearance_Window_TitleMargin = #Appearance_Window_Margin - 20
	#Appearance_Window_OptionSpacing = 45
	#Appearance_Window_TitleSpacing = #Appearance_Window_OptionSpacing + 15
	#Appearance_TrackBar_Lenght = 220
	#Appearance_LeftPanel_Width = 285
	#Appearance_LeftPanel_ItemHeight = 50
	#Appearance_MarkDown_Margin = 90
	#Appearance_Window_ItemWidth = #Appearance_Window_Width - #Appearance_LeftPanel_Width - 2 * #Appearance_Window_Margin
	
	#Appearance_Option_Width = #Appearance_Window_Width - 2 *#Appearance_Window_TitleMargin
	
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS						; The title bar UITK draws inside the window on Windows is Cocoa's own, outside it
		#Appearance_TitleBar_Height = 0
	CompilerElse
		#Appearance_TitleBar_Height = 30
	CompilerEndIf
	;}
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		#WH_KEYBOARD_LL = 13
		#WM_INSTANCESTART = #WM_USER + 111								; Must sit above #WM_USER: 0 to $3FF is reserved for the system, so a bare 111 could be
																		; delivered by Windows and pop the options window open on its own.
	CompilerElse
		;{ Event taps: the macOS counterpart of the low level hooks
		ImportC "-framework ApplicationServices"
			CGEventTapCreate(Tap.l, Place.l, Options.l, Mask.q, *Callback, *UserInfo)
			CGEventTapEnable(Tap, Enable.l)
			CGEventGetIntegerValueField.q(Event, Field.l)
			CGEventGetFlags.q(Event)
			CGRequestListenEventAccess()
			CFMachPortCreateRunLoopSource(Allocator, Port, Order.i)
			CFMachPortInvalidate(Port)
			CFRunLoopGetMain()
			CFRunLoopAddSource(RunLoop, Source, Mode)
			CFRunLoopRemoveSource(RunLoop, Source, Mode)
			CFRelease(Object)
			dlsym(Handle, *Symbol)
		EndImport
		
		ImportC "-framework IOKit"
			IOHIDCheckAccess.l(RequestType.l)
		EndImport
		
		#kIOHIDRequestTypeListenEvent = 1
		Enumeration ; IOHIDAccessType
			#kIOHIDAccessTypeGranted
			#kIOHIDAccessTypeDenied
			#kIOHIDAccessTypeUnknown
		EndEnumeration
		
		#RTLD_DEFAULT = -2
		
		#kCGSessionEventTap = 1
		#kCGHeadInsertEventTap = 0
		#kCGEventTapOptionListenOnly = 1
		#kCGKeyboardEventKeycode = 9
		#kCGMouseEventButtonNumber = 3
		
		Enumeration ; CGEventType
			#kCGEventLeftMouseDown = 1
			#kCGEventLeftMouseUp
			#kCGEventRightMouseDown
			#kCGEventRightMouseUp
			#kCGEventKeyDown = 10
			#kCGEventKeyUp
			#kCGEventFlagsChanged
			#kCGEventOtherMouseDown = 25
			#kCGEventOtherMouseUp
			#kCGEventTapDisabledByTimeout = -2						; $FFFFFFFE, read through a signed .l
			#kCGEventTapDisabledByUserInput = -1
		EndEnumeration
		
		#KeyboardMask = 1 << #kCGEventKeyDown | 1 << #kCGEventKeyUp | 1 << #kCGEventFlagsChanged
		#MouseMask = 1 << #kCGEventLeftMouseDown | 1 << #kCGEventLeftMouseUp | 1 << #kCGEventRightMouseDown | 1 << #kCGEventRightMouseUp | 1 << #kCGEventOtherMouseDown | 1 << #kCGEventOtherMouseUp
		
		#Timer_Location = 0											; On LocationInformationWindow
		
		Global KeyTap, KeySource, LocationLayer, MouseTap, MouseSource, PermissionAsked, LocationImage, LocationLastX = -1, LocationLastY = -1
		Global Dim MacVK.a(127)										; macOS virtual key code -> Windows VK, for keys whose character says nothing
		;}
	CompilerEndIf
	
	Global MouseHook, MouseHook_Button, KeyboardHook
	Global LocationMouseHook, LocationKeyboardHook, LocationInformationWindow, LocationInformationText, LocationOffsetX, LocationOffsetY
	Global Dim CornerImage(1)
	Global NewList LocationInformationWindows()
	
	;{ Private procedures declaration
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		Declare SystrayBalloon(Title.s,Message.s,Flags)
		Declare Handler_Timer()
	CompilerEndIf
	Declare Handler_CloseWindow()
	Declare Handler_TrackKeyboard()
	Declare Handler_MenuOptions()
	Declare Handler_MenuQuit()
	Declare Handler_Systray()
	Declare Handler_Update()
	Declare Handler_HyperLink()
	Declare Handler_Scale()
	Declare Handler_Duration()
	Declare Handler_DarkMode()
	Declare Handler_TrackMouse()
	Declare Handler_Combo()
	Declare Handler_CheckUpdate()
	Declare Handler_Location()
	Declare Handler_LeftPanel()
	Declare Handler_Radio()
	Declare ProcessKey(VKey, Down)
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		Declare KeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
		Declare MouseHook(nCode, wParam, *p.MOUSEHOOKSTRUCT)
		Declare LocationMouseHook(nCode, wParam, *p.MOUSEHOOKSTRUCT)
		Declare LocationKeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
		Declare WindowCallback(hWnd, Msg, wParam, lParam)
	CompilerElse
		Declare StartKeyboardTap()
		Declare StopKeyboardTap()
		Declare StartMouseTap()
		Declare StopMouseTap()
		Declare InitMacVK()
		Declare DrawLocationInformation(X, Y)
		Declare Handler_MacTimer()
		Declare Handler_LocationCanvas()
		Declare Handler_AppQuit()
	CompilerEndIf
	Declare SetColor()
	Declare VListItemRedraw(*Item.UITK::VerticalListItem, X, Y, Width, Height, State, *Theme.UITK::Theme)
	;}
	
	
	;Public procedures
	Procedure Open()
		Protected cchData, lpLCData.s, Loop, Y, Icon = ImageID(CatchImage(#PB_Any, ?Icon18))
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			; Check if another instance is already running signal it
			Protected InstanceWindow = FindWindow_(#Null, "60e272b1-eb20-4caa-9354-2142e2be78a0")
			
			If InstanceWindow
				SendMessage_(InstanceWindow, #WM_INSTANCESTART, 0, 0)
				Handler_MenuQuit() 
			EndIf
		CompilerElse
			; Launch Services already keeps a bundle to one instance. An accessory app has no Dock icon and no menu bar:
			; Inputify lives in its status item, and showing a popup never activates it.
			CocoaMessage(0, CocoaMessage(0, 0, "NSApplication sharedApplication"), "setActivationPolicy:", 1)
			InitMacVK()
		CompilerEndIf
		
		;{ Language
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			cchData = GetLocaleInfo_(#LOCALE_USER_DEFAULT, #LOCALE_SNATIVELANGNAME, @lpLCData, 0)
			lpLCData = Space(cchData)
			GetLocaleInfo_(#LOCALE_USER_DEFAULT, #LOCALE_SNATIVELANGNAME, @lpLCData, cchData)
		CompilerElse
			Protected Languages = CocoaMessage(0, 0, "NSLocale preferredLanguages")
			If Languages And CocoaMessage(0, Languages, "count")
				If LCase(Left(PeekS(CocoaMessage(0, CocoaMessage(0, Languages, "objectAtIndex:", 0), "UTF8String"), -1, #PB_UTF8), 2)) = "fr"
					lpLCData = "français"
				EndIf
			EndIf
		CompilerEndIf
		
		Select lpLCData
			Case "français"
				Restore French:
			Default
				Restore English:
		EndSelect
		
		For Loop = #Lng_DarkMode To #_Lng_Count - 1
			Read.s Language(Loop)
		Next
		;}
		
		;{ Window
		WindowID = UITK::Window(#Window, 0, 0, #Appearance_Window_Width, #Appearance_Window_Height, General::#AppName, UITK::#Window_Invisible | UITK::#Window_ScreenCentered | UITK::#Window_CloseButton | UITK::#DarkMode)
		UITK::WindowSetColor(#Window, UITK::#Color_Parent, UITK::WindowGetColor(#Window, UITK::#Color_WindowBorder))
		StickyWindow(#Window, #True)
		DisableWindow(#Window, #True)
		;}
		
		;{ Corner images
		CornerImage(0) = CreateImage(#PB_Any, 5, 5, 24, UITK::WindowGetColor(#Window, UITK::#Color_WindowBorder))
		CornerImage(1) = CreateImage(#PB_Any, 5, 5, 24, UITK::WindowGetColor(#Window, UITK::#Color_WindowBorder))
		
		StartVectorDrawing(ImageVectorOutput(CornerImage(0)))
		UITK::AddPathRoundedBox(0, 0, 40, 40, 5)
		VectorSourceColor(General::ColorScheme(0,General::#Color_Type_BackCold))
		FillPath()
		StopVectorDrawing()
		
		StartVectorDrawing(ImageVectorOutput(CornerImage(1)))
		UITK::AddPathRoundedBox(0, 0, 40, 40, 5)
		VectorSourceColor(General::ColorScheme(1,General::#Color_Type_BackCold))
		FillPath()
		StopVectorDrawing()
		
		CornerImage(1) = ImageID(CornerImage(1))
		CornerImage(0) = ImageID(CornerImage(0))
		;}
		
		;{ Left Panel
		UITK::VerticalList(#VList_Menu, 0, 0, #Appearance_LeftPanel_Width, 300, UITK::#Default, @VListItemRedraw())
		SetGadgetFont(#VList_Menu, General::TitleFont)
		SetGadgetAttribute(#VList_Menu, UITK::#Attribute_TextScale, 18)
		SetGadgetAttribute(#VList_Menu, UITK::#Attribute_CornerRadius, 0)
		SetGadgetAttribute(#VList_Menu, UITK::#Attribute_ItemHeight, #Appearance_LeftPanel_ItemHeight)
 		SetGadgetColor(#VList_Menu, UITK::#Color_Shade_Cold, General::SetAlpha(255, UITK::WindowGetColor(#Window, UITK::#Color_WindowBorder)))
 		AddGadgetItem(#VList_Menu, -1, Language(#Lng_General))
 		AddGadgetItem(#VList_Menu, -1, Language(#Lng_Behavior))
;  		AddGadgetItem(#VList_Menu, -1, Language(#Lng_Controller))
 		AddGadgetItem(#VList_Menu, -1, Language(#Lng_About))
 		SetGadgetState(#VList_Menu, 0)
 		ResizeGadget(#VList_Menu, #PB_Ignore, (WindowHeight(#Window) - #Appearance_TitleBar_Height - (#Appearance_LeftPanel_ItemHeight * CountGadgetItems(#VList_Menu))) * 0.5, #PB_Ignore, #PB_Ignore)
 		BindGadgetEvent(#VList_Menu, @Handler_LeftPanel(), #PB_EventType_Change)
 		;}
 		
 		;{ Appearance 
		ContainerGadget(#Container_Appearance, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - #Appearance_TitleBar_Height, #PB_Container_BorderLess)
		ImageGadget(#ContainerCorner_Appearance, 0, 0, 5, 5, 0)
		UITK::SetWindowIcon(#Window, Icon)
		
		Y = 117
		
		UITK::Label(#Title_UserInterface, #Appearance_Window_TitleMargin, Y, 200, 20, Language(#Lng_UserInterface))
		SetGadgetFont(#Title_UserInterface, General::TitleFont)
		
		Y + 31
		
		UITK::Toggle(#Toggle_DarkMode, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_DarkMode))
		SetGadgetFont(#Toggle_DarkMode, General::OptionFont)
		GadgetToolTip(#Toggle_DarkMode, Language(#ToolTip_DarkMode))
		BindGadgetEvent(#Toggle_DarkMode, @Handler_DarkMode(), #PB_EventType_Change)
		SetGadgetState(#Toggle_DarkMode, General::Preferences(General::#Pref_DarkMode))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::TrackBar(#Trackbar_Scale, GadgetWidth(#Container_Appearance) - #Appearance_Window_Margin - #Appearance_TrackBar_Lenght, Y - 9, #Appearance_TrackBar_Lenght, 40, 25, 150, UITK::#Trackbar_ShowState)
		SetGadgetFont(#Trackbar_Scale, General::OptionFont)
		SetGadgetState(#Trackbar_Scale, General::Preferences(General::#Pref_Scale) * 0.5)
		GadgetToolTip(#Trackbar_Scale, Language(#ToolTip_Scale))
		SetGadgetAttribute(#Trackbar_Scale, UITK::#Trackbar_Scale, 50)
		SetGadgetText(#Trackbar_Scale, "x")
		AddGadgetItem(#Trackbar_Scale, 25, "")
		AddGadgetItem(#Trackbar_Scale, 50, "")
		AddGadgetItem(#Trackbar_Scale, 150, "")
		BindGadgetEvent(#Trackbar_Scale, @Handler_Scale(), #PB_EventType_LeftButtonUp)
		UITK::Label(#Text_Scale, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth - GadgetWidth(#Trackbar_Scale), 20, Language(#Lng_Scale))
		SetGadgetFont(#Text_Scale, General::OptionFont)
		GadgetToolTip(#Text_Scale, Language(#ToolTip_Scale))
		
		Y + #Appearance_Window_TitleSpacing
		
		UITK::Label(#Title_InputColor, #Appearance_Window_TitleMargin, Y, 200, 20, Language(#Lng_InputColor))
		SetGadgetFont(#Title_InputColor, General::TitleFont)
		
		Y + #Appearance_Window_OptionSpacing - 8
		
		UITK::Radio(#Radio_Dark, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 38, Language(#Lng_DarkTheme), "Color Theme", UITK::#HAlignCenter)
		SetGadgetFont(#Radio_Dark, General::OptionFont)
		BindGadgetEvent(#Radio_Dark, @Handler_Radio(), #PB_EventType_Change)
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Radio(#Radio_Light, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 38, Language(#Lng_LightTheme), "Color Theme", UITK::#HAlignCenter)
		SetGadgetFont(#Radio_Light, General::OptionFont)
		BindGadgetEvent(#Radio_Light, @Handler_Radio(), #PB_EventType_Change)
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Radio(#Radio_Pink, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 38, Language(#Lng_PinkTheme), "Color Theme", UITK::#HAlignCenter)
		SetGadgetFont(#Radio_Pink, General::OptionFont)
		BindGadgetEvent(#Radio_Pink, @Handler_Radio(), #PB_EventType_Change)
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Radio(#Radio_Blue, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 38, Language(#Lng_BlueTheme), "Color Theme", UITK::#HAlignCenter)
		SetGadgetFont(#Radio_Blue, General::OptionFont)
		BindGadgetEvent(#Radio_Blue, @Handler_Radio(), #PB_EventType_Change)
		
		SetGadgetState(#Radio_Dark + General::Preferences(General::#Pref_InputColor), #True)
		
		CloseGadgetList() ;}
		
		;{ Behavior
		ContainerGadget(#Container_Behavior, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - #Appearance_TitleBar_Height, #PB_Container_BorderLess)
		HideGadget(#Container_Behavior, #True)
		ImageGadget(#ContainerCorner_Behavior, 0, 0, 5, 5, 0)
		
		Y = 125
		
		UITK::Label(#Title_Input, #Appearance_Window_TitleMargin, Y, 200, 20, Language(#Lng_Input))
		SetGadgetFont(#Title_Input, General::TitleFont)
		
		Y + 31
		
		UITK::Toggle(#Toggle_TrackKeyboard, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_TrackKeyboard))
		SetGadgetFont(#Toggle_TrackKeyboard, General::OptionFont)
		GadgetToolTip(#Toggle_TrackKeyboard, Language(#ToolTip_TrackInput))
		BindGadgetEvent(#Toggle_TrackKeyboard, @Handler_TrackKeyboard(), #PB_EventType_Change)
		SetGadgetState(#Toggle_TrackKeyboard, General::Preferences(General::#Pref_Keyboard))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Toggle(#Toggle_TrackMouse, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_TrackMouse))
		SetGadgetFont(#Toggle_TrackMouse, General::OptionFont)
		GadgetToolTip(#Toggle_TrackMouse, Language(#ToolTip_Mouse))
		BindGadgetEvent(#Toggle_TrackMouse, @Handler_TrackMouse(), #PB_EventType_Change)
		SetGadgetState(#Toggle_TrackMouse, General::Preferences(General::#Pref_TrackMouse))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Toggle(#Toggle_Combo, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_Combo))
		SetGadgetFont(#Toggle_Combo, General::OptionFont)
		GadgetToolTip(#Toggle_Combo, Language(#ToolTip_Combo))
		BindGadgetEvent(#Toggle_Combo, @Handler_Combo(), #PB_EventType_Change)
		SetGadgetState(#Toggle_Combo, General::Preferences(General::#Pref_Combo))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::TrackBar(#Trackbar_Duration, GadgetWidth(#Container_Appearance) - #Appearance_Window_Margin - #Appearance_TrackBar_Lenght, Y - 9, #Appearance_TrackBar_Lenght, 40, 5, 45, UITK::#Trackbar_ShowState)
		SetGadgetFont(#Trackbar_Duration, General::OptionFont)
		GadgetToolTip(#Trackbar_Duration, Language(#ToolTip_Duration))
		SetGadgetState(#Trackbar_Duration, General::Preferences(General::#Pref_Duration) * 0.01)
		SetGadgetAttribute(#Trackbar_Duration, UITK::#Trackbar_Scale, 10)
		SetGadgetText(#Trackbar_Duration, "s")
		AddGadgetItem(#Trackbar_Duration, 5, "")
		AddGadgetItem(#Trackbar_Duration, 20, "")
		AddGadgetItem(#Trackbar_Duration, 45, "")
		BindGadgetEvent(#Trackbar_Duration, @Handler_Duration(), #PB_EventType_Change)
		UITK::Label(#Text_Duration, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth - GadgetWidth(#Trackbar_Duration), 20, Language(#Lng_Duration))
		SetGadgetFont(#Text_Duration, General::OptionFont)
		GadgetToolTip(#Text_Duration, Language(#ToolTip_Duration))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Button(#Button_Location, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24, Language(#Lng_Location), UITK::#Border)
		BindGadgetEvent(#Button_Location, @Handler_Location(), #PB_EventType_Change)
		
		Y + #Appearance_Window_TitleSpacing
		
		UITK::Label(#Title_Misc, #Appearance_Window_TitleMargin, Y, 200, 20, Language(#Lng_Misc))
		SetGadgetFont(#Title_Misc, General::TitleFont)
		
		Y + 31
		
		UITK::Toggle(#Toggle_CheckUpdate, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_CheckUpdate))
		SetGadgetFont(#Toggle_CheckUpdate, General::OptionFont)
		GadgetToolTip(#Toggle_CheckUpdate, Language(#ToolTip_CheckUpdate))
		BindGadgetEvent(#Toggle_CheckUpdate, @Handler_CheckUpdate(), #PB_EventType_Change)
		SetGadgetState(#Toggle_CheckUpdate, General::Preferences(General::#Pref_CheckUpdate))
		
		CloseGadgetList() ;}
		
		;{ Controller
		ContainerGadget(#Container_Controller, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - #Appearance_TitleBar_Height, #PB_Container_BorderLess)
		HideGadget(#Container_Controller, #True)
		ImageGadget(#ContainerCorner_Controller, 0, 0, 5, 5, 0)
		
		CloseGadgetList()
		;}
		
		;{ About
		ContainerGadget(#Container_About, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - #Appearance_TitleBar_Height, #PB_Container_BorderLess)
		HideGadget(#Container_About, #True)
		ImageGadget(#ContainerCorner_About, 0, 0, 5, 5, 0)
		
		MarkDown::Gadget(#MarkDown, #Appearance_MarkDown_Margin, 10, #Appearance_Window_Width - #Appearance_LeftPanel_Width - #Appearance_MarkDown_Margin * 2, GadgetHeight(#Container_About) - 20, MarkDown::#Borderless)
		MarkDown::SetText(#MarkDown, Language(#Lng_Markdown))
		MarkDown::SetFont(#MarkDown, General::#MarkDownFont, General::#MarkDownFontSize)
		CloseGadgetList()
		;}
		
		;{ Systray
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			AddSysTrayIcon(#Systray, WindowID, Icon)
		CompilerElse
			; The status item and its menu get a plain window of their own: macOS drops the menu events of a disabled
			; window, and the UITK options window is disabled whenever it is hidden.
			AddSysTrayIcon(#Systray, WindowID(OpenWindow(#PB_Any, 0, 0, 1, 1, "", #PB_Window_Invisible | #PB_Window_NoGadgets)), Icon)
		CompilerEndIf
		SysTrayIconToolTip(#Systray, General::#AppName)
		
		CreatePopupMenu(0)
		MenuItem(#Menu_KeyboardTracking, Language(#Lng_TrackKeyboard))
		MenuItem(#Menu_MouseTracking, Language(#Lng_TrackMouse))
		MenuBar()
		MenuItem(#Menu_Options, Language(#Lng_Menu_Options))
		MenuBar()
		MenuItem(#Menu_Quit, Language(#Lng_Menu_Quit))
		
		SetMenuItemState(0, #Menu_KeyboardTracking, General::Preferences(General::#Pref_Keyboard))
		SetMenuItemState(0, #Menu_MouseTracking, General::Preferences(General::#Pref_TrackMouse))
		
		CompilerIf #PB_Compiler_OS = #PB_OS_MacOS					; A status item shows its menu itself, on a left click as Mac users expect
			SysTrayIconMenu(#Systray, MenuID(0))
		CompilerEndIf
		;}
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		;{ Set up the popup window origin point to not interfere with the taskbar. See : https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shappbarmessage
		Protected pData.APPBARDATA
		SHAppBarMessage_(#ABM_GETTASKBARPOS, pData)
		
		; The taskbar rect and GetSystemMetrics_ answer in this process's own units, like SetWindowPos_ which moves the
		; popups. PB's DesktopHeight does not: it is the physical mode even in a DPI unaware build.
		If pData\uEdge = #ABE_BOTTOM
			PopupWindow::SetPopupOrigin(10, GetSystemMetrics_(#SM_CYSCREEN) - (pData\rc\bottom - pData\rc\top) - 10)
		ElseIf pData\uEdge = #ABE_LEFT
			PopupWindow::SetPopupOrigin(pData\rc\right + 10, GetSystemMetrics_(#SM_CYSCREEN) - 10)
		EndIf
		;}
		CompilerElse
		;{ Set up the popup window origin point above the Dock: the visible frame leaves out the Dock and the menu bar
		Protected Screen = CocoaMessage(0, CocoaMessage(0, 0, "NSScreen screens"), "objectAtIndex:", 0), Frame.NSRect, Visible.NSRect
		CocoaMessage(@Frame, Screen, "frame")
		CocoaMessage(@Visible, Screen, "visibleFrame")
		PopupWindow::SetPopupOrigin(Visible\origin\x + 10, Frame\size\height - Visible\origin\y - 10)	; Cocoa's y grows upward
		;}
		CompilerEndIf
		
		;{ Event bindings
		BindEvent(#PB_Event_CloseWindow, @Handler_CloseWindow(), #Window)
		BindEvent(#PB_Event_SysTray, @Handler_Systray())
		BindEvent(General::#Event_Update, @Handler_Update())
		
		BindMenuEvent(0, #Menu_KeyboardTracking, @Handler_TrackKeyboard())
		BindMenuEvent(0, #Menu_MouseTracking, @Handler_TrackMouse())
		BindMenuEvent(0, #Menu_Options, @Handler_MenuOptions())
		BindMenuEvent(0, #Menu_Quit, @Handler_MenuQuit())
		CompilerIf #PB_Compiler_OS = #PB_OS_MacOS					; PB turns a quit request (Cmd+Q, logout, System Settings' "Quit & Reopen") into
			BindEvent(#PB_Event_Menu, @Handler_AppQuit())			; #PB_Menu_Quit and cancels it: unhandled, Inputify would refuse to quit
		CompilerEndIf
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		OpenWindow(#Window_SingleInstance, 0, 0, 10, 0, "60e272b1-eb20-4caa-9354-2142e2be78a0", #PB_Window_Invisible)
		SetWindowCallback(@WindowCallback(), #Window_SingleInstance)
		
		If General::Preferences(General::#Pref_Keyboard)
			KeyboardHook = SetWindowsHookEx_(#WH_KEYBOARD_LL, @KeyboardHook(), GetModuleHandle_(0), 0)
		EndIf
		
		If General::Preferences(General::#Pref_TrackMouse)
			MouseHook = SetWindowsHookEx_(#WH_MOUSE_LL, @MouseHook(), GetModuleHandle_(0), 0)
		EndIf
		
		If General::FirstStart
			SystrayBalloon(General::#AppName, Language(#Lng_FirstStart), #NIIF_USER|#NIIF_INFO )
		EndIf
		CompilerEndIf
		;}
		
		CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
		;{ The location selector: a click-through crosshair over one dimmed, click catching window per screen
		LocationInformationWindow = OpenWindow(#PB_Any, 0, 0, 101, 50, "", #PB_Window_Invisible | #PB_Window_BorderLess | #PB_Window_NoGadgets)
		LocationLayer = PopupWindow::ImageLayer(WindowID(LocationInformationWindow))
		CocoaMessage(0, WindowID(LocationInformationWindow), "setLevel:", 102)
		LocationOffsetX = 50
		LocationOffsetY = 12
		BindEvent(#PB_Event_Timer, @Handler_MacTimer(), LocationInformationWindow)
		;}
		
		If General::Preferences(General::#Pref_Keyboard)
			StartKeyboardTap()
		EndIf
		
		If General::Preferences(General::#Pref_TrackMouse)
			StartMouseTap()
		EndIf
		
		SetColor()
		
		If General::FirstStart										; No balloon on macOS: show where the settings are instead
			Handler_MenuOptions()
		EndIf
		CompilerElse
		
		;{ Create the location selector window (it works but it's very hacky, there has to be a proper solution): 
		LocationInformationWindow = OpenWindow(#PB_Any, 0, 0, 101, 50, "", #PB_Window_Invisible | #PB_Window_BorderLess, WindowID)
		SetWindowLong_(WindowID(LocationInformationWindow), #GWL_EXSTYLE, GetWindowLong_(WindowID(LocationInformationWindow), #GWL_EXSTYLE) | #WS_EX_LAYERED)
		SetLayeredWindowAttributes_(WindowID(LocationInformationWindow), $FF00FF, 255, #LWA_COLORKEY)
		
		; The window and its gadgets are laid out in points, but the canvas is drawn in pixels: the crosshair is
		; drawn around its scaled centre, and the hooks place the window by that same pixel offset.
		LocationOffsetX = DesktopScaledX(50)
		LocationOffsetY = DesktopScaledY(12)
		
		StartDrawing(CanvasOutput(CanvasGadget(#PB_Any, 0, 0, 101, 50, #PB_Canvas_Container)))
		Box(0, 0, OutputWidth(), OutputHeight(), $FF00FF)
		FrontColor($FFFFFF)
		Line(LocationOffsetX, LocationOffsetY - 12, 1, 10)
		Line(LocationOffsetX, LocationOffsetY + 3, 1, 10)
		Line(LocationOffsetX - 12, LocationOffsetY, 10, 1)
		Line(LocationOffsetX + 3, LocationOffsetY, 10, 1)
		Plot(LocationOffsetX - 1, LocationOffsetY - 2)
		Plot(LocationOffsetX + 1, LocationOffsetY - 2)
		Plot(LocationOffsetX - 2, LocationOffsetY - 1)
		Plot(LocationOffsetX + 2, LocationOffsetY - 1)
		Plot(LocationOffsetX - 2, LocationOffsetY + 1)
		Plot(LocationOffsetX + 2, LocationOffsetY + 1)
		Plot(LocationOffsetX - 1, LocationOffsetY + 2)
		Plot(LocationOffsetX + 1, LocationOffsetY + 2)
		Box(0, DesktopScaledY(30), OutputWidth(), OutputHeight() - DesktopScaledY(30), General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_Trackbar))
		Box(1, DesktopScaledY(30) + 1, OutputWidth() - 2, OutputHeight() - DesktopScaledY(30) - 2, General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold))
		StopDrawing()
		
		LocationInformationText = TextGadget(#PB_Any, 1, 31, 99, 18, "x: y:", #PB_Text_Center)
		SetGadgetColor(LocationInformationText, #PB_Gadget_BackColor, RGB(Red(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold)),
		                                                       Green(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold)),
		                                                       Blue(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold))))
		SetGadgetColor(LocationInformationText, #PB_Gadget_FrontColor, RGB(Red(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_FrontHot)),
		                                                       Green(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_FrontHot)),
		                                                       Blue(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_FrontHot))))
		StickyWindow(LocationInformationWindow, #True)
		BindEvent(#PB_Event_Timer, @Handler_Timer(), LocationInformationWindow)
		DisableWindow(LocationInformationWindow, #True)
		;}
		
		SetColor()
		CompilerEndIf
	EndProcedure
	
	;{ Private procedures
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	Procedure SystrayBalloon(Title.s,Message.s,Flags)
		If OSVersion() >= #PB_OS_Windows_Vista
			SysTrayInfo\cbSize = SizeOf(NOTIFYICONDATA_)
		ElseIf OSVersion() >= #PB_OS_Windows_XP
			SysTrayInfo\cbSize=OffsetOf(NOTIFYICONDATA_\hBalloonIcon)
		ElseIf OSVersion() >= #PB_OS_Windows_2000
			SysTrayInfo\cbSize = OffsetOf(NOTIFYICONDATA_\guidItem)
		Else
			SysTrayInfo\cbSize = OffsetOf(NOTIFYICONDATA_\szTip) + SizeOf(NOTIFYICONDATA_\szTip)
		EndIf
		
		If SysTrayInfo\cbSize
			SysTrayInfo\uVersion = #NOTIFYICON_VERSION
			SysTrayInfo\uCallbackMessage = #WM_NOTIFYICON
			SysTrayInfo\uId = #Null
			SysTrayInfo\uFlags = #NIF_INFO|#NIF_TIP
			SysTrayInfo\uTimeout = 10000
			SysTrayInfo\hwnd = WindowID(#Window)
			SysTrayInfo\dwInfoFlags = Flags
			SysTrayInfo\dwState = #NIS_SHAREDICON
			SysTrayInfo\szInfoTitle = Title
			SysTrayInfo\szInfo = Message
			SysTrayInfo\hBalloonIcon = #Null
			SysTrayInfo\szTip = General::#AppName
			ProcedureReturn Shell_NotifyIcon_(#NIM_MODIFY, @SysTrayInfo)
		EndIf
		
		ProcedureReturn #False
	EndProcedure
	CompilerEndIf
	
	Procedure Handler_CloseWindow()
		DisableWindow(#Window, #True)
		HideWindow(#Window, #True)
	EndProcedure
	
	Procedure Handler_TrackKeyboard()
		Protected Loop
		
		General::Preferences(General::#Pref_Keyboard) = Bool(Not General::Preferences(General::#Pref_Keyboard))
		SetGadgetState(#Toggle_TrackKeyboard, General::Preferences(General::#Pref_Keyboard))
		SetMenuItemState(0, #Menu_KeyboardTracking, General::Preferences(General::#Pref_Keyboard))
		
		If General::Preferences(General::#Pref_Keyboard) 
			CompilerIf #PB_Compiler_OS = #PB_OS_Windows
				KeyboardHook = SetWindowsHookEx_(#WH_KEYBOARD_LL, @KeyboardHook(), GetModuleHandle_(0), 0)
			CompilerElse
				StartKeyboardTap()
			CompilerEndIf
			
		Else
			CompilerIf #PB_Compiler_OS = #PB_OS_Windows
				UnhookWindowsHookEx_(KeyboardHook)
				KeyboardHook = 0
			CompilerElse
				StopKeyboardTap()
				Ctrl = #False : Shift = #False : Alt = #False : Cmd = #False	; A release that comes while the tap is off is never seen
			CompilerEndIf
			
			For Loop = 0 To 255
				If InputArray(Loop)
					PopupWindow::Hide(InputArray(Loop))
					InputArray(Loop) = #False
				EndIf
			Next
			
		EndIf
	EndProcedure
	
	Procedure Handler_Update()
		If MessageRequester(General::#AppName, ~"A new version is available!\nDo you want to download it?",#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
			CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
				RunProgram("open", "https://github.com/LastLifeLeft/Inputify/releases/latest", "")
			CompilerElse
				RunProgram("https://github.com/LastLifeLeft/Inputify/releases/latest")
			CompilerEndIf
		EndIf
	EndProcedure
	
	Procedure Handler_HyperLink()
		CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
			RunProgram("open", "http://lastlife.net/", "")
		CompilerElse
			RunProgram("http://lastlife.net/")
		CompilerEndIf
	EndProcedure
	
	Procedure Handler_Scale()
		General::Preferences(General::#Pref_Scale) = GetGadgetState(EventGadget()) * 2
		PopupWindow::SetScale(General::Preferences(General::#Pref_Scale))
	EndProcedure
	
	Procedure Handler_Duration()
		General::Preferences(General::#Pref_Duration) = GetGadgetState(EventGadget()) * 100
	EndProcedure
	
	Procedure Handler_MenuOptions()
		DisableWindow(#Window, #False)
		HideWindow(#Window, #False, #PB_Window_ScreenCentered)
		CompilerIf #PB_Compiler_OS = #PB_OS_MacOS					; An accessory app is not brought forward by showing a window
			CocoaMessage(0, CocoaMessage(0, 0, "NSApplication sharedApplication"), "activateIgnoringOtherApps:", #YES)
		CompilerEndIf
	EndProcedure
	
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
	Procedure Handler_AppQuit()
		If EventMenu() = #PB_Menu_Quit
			Handler_MenuQuit()
		EndIf
	EndProcedure
	CompilerEndIf
	
	Procedure Handler_MenuQuit()
		If CreatePreferences(General::PreferenceFile)
			PreferenceGroup("Appearance")
			WritePreferenceLong("DarkMode", General::Preferences(General::#Pref_DarkMode))
			WritePreferenceLong("Scale", General::Preferences(General::#Pref_Scale))
			WritePreferenceLong("InputColor", General::Preferences(General::#Pref_InputColor))
			
			PreferenceGroup("Behavior")
			WritePreferenceLong("Keyboard", General::Preferences(General::#Pref_Keyboard))
			WritePreferenceLong("Mouse", General::Preferences(General::#Pref_TrackMouse))
			WritePreferenceLong("Duration", General::Preferences(General::#Pref_Duration))				
			WritePreferenceLong("Combo", General::Preferences(General::#Pref_Combo))
			
			PreferenceGroup("Misc")
			WritePreferenceLong("Update", General::Preferences(General::#Pref_CheckUpdate))
			
			ClosePreferences()
		EndIf
		
		If IsSysTrayIcon(#Systray)
			RemoveSysTrayIcon(#Systray)
		EndIf
		
		End
	EndProcedure
	
	Procedure Handler_Systray()
		If EventType() = #PB_EventType_RightClick
			MouseHook_Button = #False
			DisplayPopupMenu(0, WindowID(#Window))
			
		ElseIf EventType() = #PB_EventType_LeftDoubleClick
			Handler_MenuOptions()
		EndIf
	EndProcedure
	
	Procedure Handler_DarkMode()
		General::Preferences(General::#Pref_DarkMode) = GetGadgetState(#Toggle_DarkMode)
		SetColor()
	EndProcedure
	
	Procedure Handler_TrackMouse()
		General::Preferences(General::#Pref_TrackMouse) = Bool(Not General::Preferences(General::#Pref_TrackMouse))
		SetGadgetState(#Toggle_TrackMouse, General::Preferences(General::#Pref_TrackMouse))
		SetMenuItemState(0, #Menu_MouseTracking, General::Preferences(General::#Pref_TrackMouse))
		
		If General::Preferences(General::#Pref_TrackMouse)
			CompilerIf #PB_Compiler_OS = #PB_OS_Windows
				MouseHook = SetWindowsHookEx_(#WH_MOUSE_LL, @MouseHook(), GetModuleHandle_(0), 0)
			CompilerElse
				StartMouseTap()
			CompilerEndIf
		Else
			CompilerIf #PB_Compiler_OS = #PB_OS_Windows
				UnhookWindowsHookEx_(MouseHook)
				MouseHook = 0
			CompilerElse
				StopMouseTap()
			CompilerEndIf
			If InputArray(#VK_LBUTTON)
				PopupWindow::Hide(InputArray(#VK_LBUTTON))
				InputArray(#VK_LBUTTON) = #False
			EndIf
			
			If InputArray(#VK_RBUTTON)
				PopupWindow::Hide(InputArray(#VK_RBUTTON))
				InputArray(#VK_RBUTTON) = #False
			EndIf
			
			If InputArray(#VK_MBUTTON)
				PopupWindow::Hide(InputArray(#VK_MBUTTON))
				InputArray(#VK_MBUTTON) = #False
			EndIf
		EndIf
	EndProcedure
	
	Procedure Handler_Combo()
		General::Preferences(General::#Pref_Combo) = GetGadgetState(#Toggle_Combo)
	EndProcedure
	
	Procedure Handler_CheckUpdate()
		General::Preferences(General::#Pref_CheckUpdate) = GetGadgetState(#Toggle_CheckUpdate)
	EndProcedure
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	Procedure Handler_Timer()
		RemoveWindowTimer(LocationInformationWindow, 0)
		If MouseHook_Button
			InputArray(MouseHook_Button) = PopupWindow::Create(MouseHook_Button)
		EndIf
	EndProcedure
	
	Procedure Handler_Location()
		Protected Loop, DesktopCount
		LocationMouseHook = SetWindowsHookEx_(#WH_MOUSE_LL, @LocationMouseHook(), GetModuleHandle_(0), 0)
		LocationKeyboardHook = SetWindowsHookEx_(#WH_KEYBOARD_LL, @LocationKeyboardHook(), GetModuleHandle_(0), 0)
		
		DesktopCount = ExamineDesktops() - 1
		
		For Loop = 0 To DesktopCount
			AddElement(LocationInformationWindows())
			LocationInformationWindows() = OpenWindow(#PB_Any, 0, 0, 10, 10, "", #PB_Window_Invisible | #PB_Window_BorderLess, WindowID)
			SetWindowPos_(WindowID(LocationInformationWindows()), 0, DesktopX(Loop), DesktopY(Loop), DesktopWidth(Loop), DesktopHeight(Loop), #SWP_NOZORDER | #SWP_NOACTIVATE)	; Desktop* are pixels, OpenWindow takes points
			SetWindowColor(LocationInformationWindows(), $141414)
			StickyWindow(LocationInformationWindows(), #True)
			SetWindowLongPtr_(WindowID(LocationInformationWindows()), #GWL_EXSTYLE, GetWindowLongPtr_(WindowID(LocationInformationWindows()), #GWL_EXSTYLE) | #WS_EX_LAYERED)
			SetLayeredWindowAttributes_(WindowID(LocationInformationWindows()), 0, 150, #LWA_ALPHA)
			HideWindow(LocationInformationWindows(), #False)
		Next
		
		SetGadgetText(LocationInformationText, "x: " + Str(DesktopMouseX() - LocationOffsetX) + " y: " +Str(DesktopMouseY() - LocationOffsetY))
		SetWindowPos_(WindowID(LocationInformationWindow), 0, DesktopMouseX() - LocationOffsetX, DesktopMouseY() - LocationOffsetY, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER|#SWP_NOREDRAW|#SWP_NOACTIVATE)
		HideWindow(LocationInformationWindow, #False)
		SetActiveWindow(LocationInformationWindow)
		ShowCursor_(#False)
		
		DisableWindow(LocationInformationWindow, #False)
	EndProcedure
	CompilerEndIf
	
	Procedure Handler_LeftPanel()
		Select GetGadgetState(#VList_Menu)
			Case 0 ; Appearance
				HideGadget(#Container_Appearance, #False)
				HideGadget(#Container_Behavior, #True)
				HideGadget(#Container_About, #True)
				HideGadget(#Container_Controller, #True)
				
			Case 1 ; Behavior
				HideGadget(#Container_Behavior, #False)
				HideGadget(#Container_Appearance, #True)
				HideGadget(#Container_About, #True)
				HideGadget(#Container_Controller, #True)
				
			Case 2 ; About
				HideGadget(#Container_Behavior, #True)
				HideGadget(#Container_Appearance, #True)
				HideGadget(#Container_About, #False)
				HideGadget(#Container_Controller, #True)
				
			Case 3; Controller
				HideGadget(#Container_Behavior, #True)
				HideGadget(#Container_Appearance, #True)
				HideGadget(#Container_About, #True)
				HideGadget(#Container_Controller, #False)
		EndSelect
	EndProcedure
	
	Procedure Handler_Radio()
		General::Preferences(General::#Pref_InputColor) = EventGadget() - #Radio_Dark
	EndProcedure
	
	; Shared by the Windows hook and the macOS event tap. Ctrl and Command both start a shortcut: Command is the
	; Mac's shortcut key, and Cmd is never set on Windows.
	Procedure ProcessKey(VKey, Down)
		If Down
			If Not InputArray(VKey)
				If (VKey = #VK_CONTROL)
					CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
						If Cmd
							PopupWindow::ShortCut(Ctrl, Shift, Alt, Cmd, VKey)
						Else
							InputArray(VKey) = PopupWindow::Create(VKey)
						EndIf
					CompilerElse
						InputArray(VKey) = PopupWindow::Create(VKey)
					CompilerEndIf
					Ctrl = #True
				ElseIf (VKey = #VK_SHIFT)
					If Ctrl Or Cmd
						PopupWindow::ShortCut(Ctrl, Shift, Alt, Cmd, VKey)
					Else
						InputArray(VKey) = PopupWindow::Create(VKey)
					EndIf
					Shift = #True
				ElseIf (VKey = #VK_MENU)
					If Ctrl Or Cmd
						PopupWindow::ShortCut(Ctrl, Shift, Alt, Cmd, VKey)
					Else 
						InputArray(VKey) = PopupWindow::Create(VKey)
					EndIf
					Alt = #True
				CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
				ElseIf (VKey = #VK_LWIN)
					If Ctrl
						PopupWindow::ShortCut(Ctrl, Shift, Alt, Cmd, VKey)
					Else
						InputArray(VKey) = PopupWindow::Create(VKey)
					EndIf
					Cmd = #True
				CompilerEndIf
				ElseIf Ctrl Or Shift Or Alt Or Cmd
					PopupWindow::ShortCut(Ctrl, Shift, Alt, Cmd, VKey)
				Else
					InputArray(VKey) = PopupWindow::Create(VKey)
				EndIf
			Else
				; Hold!
			EndIf
		Else
			If (VKey = #VK_CONTROL)
				Ctrl = #False
			ElseIf (VKey = #VK_SHIFT)
				Shift = #False
			ElseIf (VKey = #VK_MENU)
				Alt = #False
			ElseIf (VKey = #VK_LWIN)
				Cmd = #False
			EndIf
			
			If InputArray(VKey)
				; An input has been released, start the windows disparition timer
				PopupWindow::Hide(InputArray(VKey))
				InputArray(VKey) = #False
			EndIf
		EndIf
	EndProcedure
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	Procedure KeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
		If nCode = #HC_ACTION
			If (*p\vkCode = #VK_LCONTROL Or *p\vkCode = #VK_RCONTROL)
				*p\vkCode = #VK_CONTROL
			ElseIf (*p\vkCode = #VK_LSHIFT Or *p\vkCode = #VK_RSHIFT)
				*p\vkCode = #VK_SHIFT
			ElseIf (*p\vkCode = #VK_LMENU Or *p\vkCode = #VK_RMENU)
				*p\vkCode = #VK_MENU
			EndIf
			
			ProcessKey(*p\vkCode, Bool(wParam = #WM_KEYDOWN))
		EndIf
		
		ProcedureReturn CallNextHookEx_(#NUL, nCode, wParam, *p)
	EndProcedure
	
	Procedure MouseHook(nCode, wParam, *p.MOUSEHOOKSTRUCT)
		If nCode = #HC_ACTION
			Select wParam 
				Case #WM_LBUTTONDOWN
					AddWindowTimer(LocationInformationWindow, 0, 1)
					MouseHook_Button = #VK_LBUTTON
				Case #WM_RBUTTONDOWN
					AddWindowTimer(LocationInformationWindow, 0, 1)
					MouseHook_Button = #VK_RBUTTON
				Case #WM_MBUTTONDOWN
					AddWindowTimer(LocationInformationWindow, 0, 1)
					MouseHook_Button = #VK_MBUTTON
				Case #WM_LBUTTONUP
					If InputArray(#VK_LBUTTON)
						PopupWindow::Hide(InputArray(#VK_LBUTTON))
						InputArray(#VK_LBUTTON) = #False
					EndIf
				Case #WM_RBUTTONUP
					If InputArray(#VK_RBUTTON)
						PopupWindow::Hide(InputArray(#VK_RBUTTON))
						InputArray(#VK_RBUTTON) = #False
					EndIf
				Case #WM_MBUTTONUP
					If InputArray(#VK_MBUTTON)
						PopupWindow::Hide(InputArray(#VK_MBUTTON))
						InputArray(#VK_MBUTTON) = #False
					EndIf
			EndSelect
		EndIf
		
		ProcedureReturn CallNextHookEx_(#NUL, nCode, wParam, *p)
	EndProcedure
	
	Macro QuitPopupPlacement
		UnhookWindowsHookEx_(LocationMouseHook)
		UnhookWindowsHookEx_(LocationKeyboardHook)
		
		ForEach LocationInformationWindows()
			CloseWindow(LocationInformationWindows())
		Next
		ClearList(LocationInformationWindows())
		
		HideWindow(LocationInformationWindow, #True)
		DisableWindow(LocationInformationWindow, #True)
 		ShowCursor_(#True)
	EndMacro
	
	Procedure LocationMouseHook(nCode, wParam, *p.MOUSEHOOKSTRUCT)
		If nCode = #HC_ACTION
			Select wParam 
				Case #WM_LBUTTONDOWN
					PopupWindow::SetPopupOrigin(*p\pt\x, *p\pt\y)
					QuitPopupPlacement
				Case #WM_RBUTTONDOWN
					QuitPopupPlacement
				Case #WM_MOUSEMOVE
					SetGadgetText(LocationInformationText, "x: " + Str(*p\pt\x - LocationOffsetX) + " y: " +Str(*p\pt\y - LocationOffsetY))
					SetWindowPos_(WindowID(LocationInformationWindow), 0, *p\pt\x - LocationOffsetX, *p\pt\y - LocationOffsetY, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER|#SWP_NOREDRAW|#SWP_NOACTIVATE)
					ProcedureReturn #False
			EndSelect
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	
	Procedure LocationKeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
		If nCode = #HC_ACTION
			If wParam = #WM_KEYDOWN And *p\vkCode = #VK_ESCAPE
				QuitPopupPlacement
			EndIf
		EndIf
		ProcedureReturn #True
	EndProcedure
	CompilerEndIf
	
	Macro SetRadioAppearance(Button)
		SetGadgetColor(Button, UITK::#Color_Parent, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(Button, UITK::#Color_Back_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(Button, UITK::#Color_Back_Warm,  General::SetAlpha(80, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_Trackbar)))
		SetGadgetColor(Button, UITK::#Color_Back_Hot,  General::SetAlpha(130, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_Trackbar)))
		SetGadgetColor(Button, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(Button, UITK::#Color_Text_Warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
		SetGadgetColor(Button, UITK::#Color_Text_Hot, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
	EndMacro
	
	Macro SetToggleAppearance(Toggle)
		SetGadgetColor(Toggle, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(Toggle, UITK::#Color_Text_Warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(Toggle, UITK::#Color_Parent, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
	EndMacro
	
	Macro SetTextAppearance(Text)
		SetGadgetColor(Text, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(Text, UITK::#Color_Parent, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
	EndMacro
	
	Macro SetTitleAppearance(Text)
		SetGadgetColor(Text, UITK::#Color_Parent, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(Text, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
	EndMacro
	
	Macro SetContainerColor(Container)
		SetGadgetColor(Container, #PB_Gadget_BackColor, RGB(Red(General::ColorScheme(General::Preferences(General::#Pref_DarkMode),General::#Color_Type_BackCold)),
		                                                                Green(General::ColorScheme(General::Preferences(General::#Pref_DarkMode),General::#Color_Type_BackCold)),
		                                                                Blue(General::ColorScheme(General::Preferences(General::#Pref_DarkMode),General::#Color_Type_BackCold))))
	EndMacro
	
	Procedure SetColor()
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			SendMessage_(GadgetID(#Container_Appearance), #WM_SETREDRAW, #False, 0)
		CompilerEndIf
		
		SetContainerColor(#Container_Appearance)
		SetContainerColor(#Container_Behavior)
		SetContainerColor(#Container_Controller)
		SetContainerColor(#Container_About)
		
		SetGadgetState(#ContainerCorner_Appearance, CornerImage(General::Preferences(General::#Pref_DarkMode)))
		SetGadgetState(#ContainerCorner_Behavior, CornerImage(General::Preferences(General::#Pref_DarkMode)))
		SetGadgetState(#ContainerCorner_About, CornerImage(General::Preferences(General::#Pref_DarkMode)))
		SetGadgetState(#ContainerCorner_Controller, CornerImage(General::Preferences(General::#Pref_DarkMode)))
		
		SetTitleAppearance(#Title_InputColor)
		SetTitleAppearance(#Title_UserInterface)
		SetTitleAppearance(#Title_Input)
		SetTitleAppearance(#Title_Misc)
		
		SetTextAppearance(#Text_Scale)
		SetTextAppearance(#Text_Duration)
		
		SetToggleAppearance(#Toggle_DarkMode)
		SetToggleAppearance(#Toggle_CheckUpdate)
		SetToggleAppearance(#Toggle_Combo)
		SetToggleAppearance(#Toggle_TrackKeyboard)
		SetToggleAppearance(#Toggle_TrackMouse)
		
		SetRadioAppearance(#Radio_Dark)
		SetRadioAppearance(#Radio_Light)
		SetRadioAppearance(#Radio_Pink)
		SetRadioAppearance(#Radio_Blue)
		
		SetGadgetColor(#Trackbar_Duration, UITK::#Color_Parent, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(#Trackbar_Duration, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(#Trackbar_Duration, UITK::#Color_Shade_Warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_Trackbar))
		
		SetGadgetColor(#Trackbar_Scale, UITK::#Color_Parent, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(#Trackbar_Scale, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(#Trackbar_Scale, UITK::#Color_Shade_Warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_Trackbar))
		
		SetGadgetColor(#Button_Location, UITK::#Color_Back_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(#Button_Location, UITK::#Color_Back_Warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackHot))
		SetGadgetColor(#Button_Location, UITK::#Color_Back_Hot, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackHot))
		SetGadgetColor(#Button_Location, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(#Button_Location, UITK::#Color_Text_Warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
		SetGadgetColor(#Button_Location, UITK::#Color_Text_Hot, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
		SetGadgetColor(#Button_Location, UITK::#Color_Parent, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		
		MarkDown::SetColor(#MarkDown, MarkDown::#Color_Back, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		MarkDown::SetColor(#MarkDown, MarkDown::#Color_Front, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
		MarkDown::SetColor(#MarkDown, MarkDown::#Color_Link, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		MarkDown::SetColor(#MarkDown, MarkDown::#Color_HighlightLink, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			SendMessage_(GadgetID(#Container_Appearance), #WM_SETREDRAW, #True, 0)
			RedrawWindow_(GadgetID(#Container_Appearance), 0, 0, #RDW_ERASE | #RDW_INVALIDATE) 
		CompilerEndIf
	EndProcedure
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
	Procedure WindowCallback(hWnd, Msg, wParam, lParam)
		If Msg = #WM_INSTANCESTART
			Handler_MenuOptions()
		EndIf
		
		ProcedureReturn #PB_ProcessPureBasicEvents
	EndProcedure
	CompilerElse
	XIncludeFile "MacInput.pbi"
	CompilerEndIf
	
	Procedure VListItemRedraw(*Item.UITK::VerticalListItem, X, Y, Width, Height, State, *Theme.UITK::Theme)
		If State = UITK::#Cold
			VectorSourceColor(General::ColorScheme(1, General::#Color_Type_FrontCold))
		Else
			
			UITK::AddPathRoundedBox(15, Y + 2, #Appearance_LeftPanel_Width - 30, Height - 2, 5)
			
			If State = UITK::#Hot
				VectorSourceColor(General::SetAlpha(50, $FFFFFF))
				FillPath()
				VectorSourceColor(General::ColorScheme(1, General::#Color_Type_FrontHot))
			Else
				VectorSourceColor(General::SetAlpha(30, $FFFFFF))
				FillPath()
				VectorSourceColor(General::ColorScheme(1, General::#Color_Type_FrontCold))
			EndIf
		EndIf
		
		UITK::DrawVectorTextBlock(@*Item\Text, X + 25, Y + 1)
		
; 		If State = #Hot
; 			MovePathCursor(X + *Item\Text\Width - #VerticalList_IconWidth, Y + (*Item\Text\Height - 14) * 0.5)
; 			VectorFont(IconFont, 16)
; 			DrawVectorText("")
; 			
; 			If *Item\Text\FontScale
; 				VectorFont(*Item\Text\FontID, *Item\Text\FontScale)
; 			Else
; 				VectorFont(*Item\Text\FontID)
; 			EndIf
; 		EndIf
		
	EndProcedure
	;}
	
	DataSection ;{ Languages
		
		English:
		IncludeFile "../Language/English.pbi"
		
		French:
		IncludeFile "../Language/Français.pbi"
		
		Icon18:
		IncludeBinary "../Media/Icon/18.png"
		
	EndDataSection ;}
	
EndModule
; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 583
; FirstLine = 21
; Folding = hAACAAAAw
; EnableXP