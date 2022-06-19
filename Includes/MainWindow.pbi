﻿Module MainWindow
	EnableExplicit
	; Private variables, structures and constants
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
	
	;{ Language
	Enumeration 
		#Lng_DarkMode
		#Lng_Scale
		#Lng_Mouse
		#Lng_Duration
		#Lng_Combo
		#Lng_Location
		#Lng_CheckUpdate
		#Lng_Website
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
		
		#Lng_Menu_Enable
		#Lng_Menu_Options
		#Lng_Menu_Quit
		
		#Lng_FirstStart
		
		#Lng_LightTheme
		#Lng_DarkTheme
		#Lng_BlueTheme
		#Lng_PinkTheme
		
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
		#Toggle_TrackInput
		#Toggle_Mouse
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
		
		#Container_Controller
		#ContainerCorner_Controller
	EndEnumeration
	
	#Systray = 0
	
	Enumeration ;Menu ID
		#Menu_Enabled
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
	#Appearance_Window_ItemWidth = #Appearance_Window_Width - #Appearance_LeftPanel_Width - 2 * #Appearance_Window_Margin
	
	#Appearance_Option_Width = #Appearance_Window_Width - 2 *#Appearance_Window_TitleMargin
	;}
	
	#WH_KEYBOARD_LL = 13
	#WM_INSTANCESTART = 111
	
	Global Enabled = #True
	Global MouseOffset = -1000
	Global MouseHook, KeyboardHook
	Global LocationMouseHook, LocationKeyboardHook, LocationWindow, LocationText
	Global HookButton, Dim CornerImage(1)
	Global NewList DesktopWindow()
	
	; Private procedures declaration
	Declare SystrayBalloon(Title.s,Message.s,Flags)
	Declare HandlerCloseWindow()
	Declare HandlerMenuEnabled()
	Declare HandlerMenuOptions()
	Declare HandlerMenuQuit()
	Declare HandlerSystray()
	Declare HandlerUpdate()
	Declare HandlerHyperLink()
	Declare Handler_Scale()
	Declare Handler_Duration()
	Declare Handler_DarkMode()
	Declare Handler_Mouse()
	Declare Handler_Combo()
	Declare Handler_CheckUpdate()
	Declare Handler_Timer()
	Declare Handler_Location()
	Declare Handler_LeftPanel()
	Declare KeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare MouseHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare LocationMouseHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare LocationKeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare SetColor()
	Declare WindowCallback(hWnd, Msg, wParam, lParam)
	Declare VListItemRedraw(*Item.UITK::VerticalListItem, X, Y, Width, Height, State)
	
	;{ Public procedures
	Procedure Open()
		; Check if another instance is already running signal it
		Protected InstanceWindow = FindWindow_(#Null, "60e272b1-eb20-4caa-9354-2142e2be78a0")
		Protected cchData, lpLCData.s, Loop, Y, Icon = ImageID(CatchImage(#PB_Any, ?Icon18))
		
		If InstanceWindow
			SendMessage_(InstanceWindow, #WM_INSTANCESTART, 0, 0)
			HandlerMenuQuit() 
		EndIf
		
		;{ Language
		cchData = GetLocaleInfo_(#LOCALE_USER_DEFAULT, #LOCALE_SNATIVELANGNAME, @lpLCData, 0)
		lpLCData = Space(cchData)
		GetLocaleInfo_(#LOCALE_USER_DEFAULT, #LOCALE_SNATIVELANGNAME, @lpLCData, cchData)
		
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
		WindowID = UITK::Window(#Window, 0, 0, #Appearance_Window_Width, #Appearance_Window_Height, General::#AppName, #PB_Window_Invisible | #PB_Window_ScreenCentered | UITK::#Window_CloseButton | UITK::#DarkMode)
		UITK::WindowSetColor(#Window, UITK::#Color_Parent, UITK::WindowGetColor(#Window, UITK::#Color_WindowBorder))
		StickyWindow(#Window, #True)
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
 		ResizeGadget(#VList_Menu, #PB_Ignore, (WindowHeight(#Window) - 30 - (#Appearance_LeftPanel_ItemHeight * CountGadgetItems(#VList_Menu))) * 0.5, #PB_Ignore, #PB_Ignore)
 		BindGadgetEvent(#VList_Menu, @Handler_LeftPanel(), #PB_EventType_Change)
 		;}
 		
 		;{ Appearance 
		ContainerGadget(#Container_Appearance, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - 30, #PB_Container_BorderLess)
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
		
		UITK::Label(#Text_Scale, #Appearance_Window_Margin, Y, 200, 20, Language(#Lng_Scale))
		SetGadgetFont(#Text_Scale, General::OptionFont)
		UITK::TrackBar(#Trackbar_Scale, GadgetWidth(#Container_Appearance) - #Appearance_Window_Margin - #Appearance_TrackBar_Lenght, Y - 9, #Appearance_TrackBar_Lenght, 40, 25, 150, UITK::#Trackbar_ShowState)
		SetGadgetState(#Trackbar_Scale, General::Preferences(General::#Pref_Scale) * 0.5)
		SetGadgetAttribute(#Trackbar_Scale, UITK::#Trackbar_Scale, 50)
		SetGadgetText(#Trackbar_Scale, "x")
		AddGadgetItem(#Trackbar_Scale, 25, "")
		AddGadgetItem(#Trackbar_Scale, 50, "")
		AddGadgetItem(#Trackbar_Scale, 150, "")
		BindGadgetEvent(#Trackbar_Scale, @Handler_Scale(), #PB_EventType_LeftButtonUp)
		
		Y + #Appearance_Window_TitleSpacing
		
		UITK::Label(#Title_InputColor, #Appearance_Window_TitleMargin, Y, 200, 20, Language(#Lng_InputColor))
		SetGadgetFont(#Title_InputColor, General::TitleFont)
		
		Y + #Appearance_Window_OptionSpacing - 8
		
		UITK::Radio(#Radio_Dark, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 38, Language(#Lng_DarkTheme), "Color Theme", UITK::#HAlignCenter)
		SetGadgetFont(#Radio_Dark, General::OptionFont)
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Radio(#Radio_Light, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 38, Language(#Lng_LightTheme), "Color Theme", UITK::#HAlignCenter)
		SetGadgetFont(#Radio_Light, General::OptionFont)
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Radio(#Radio_Pink, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 38, Language(#Lng_PinkTheme), "Color Theme", UITK::#HAlignCenter)
		SetGadgetFont(#Radio_Pink, General::OptionFont)
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Radio(#Radio_Blue, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 38, Language(#Lng_BlueTheme), "Color Theme", UITK::#HAlignCenter)
		SetGadgetFont(#Radio_Blue, General::OptionFont)
		
		SetGadgetState(#Radio_Dark, #True)
		
		CloseGadgetList() ;}
		
		;{ Behavior
		ContainerGadget(#Container_Behavior, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - 30, #PB_Container_BorderLess)
		HideGadget(#Container_Behavior, #True)
		ImageGadget(#ContainerCorner_Behavior, 0, 0, 5, 5, 0)
		
		Y = 125
		
		UITK::Label(#Title_Input, #Appearance_Window_TitleMargin, Y, 200, 20, Language(#Lng_Input))
		SetGadgetFont(#Title_Input, General::TitleFont)
		
		Y + 31
		
		UITK::Toggle(#Toggle_TrackInput, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_Menu_Enable))
		SetGadgetFont(#Toggle_TrackInput, General::OptionFont)
		GadgetToolTip(#Toggle_TrackInput, Language(#ToolTip_TrackInput))
		BindGadgetEvent(#Toggle_TrackInput, @HandlerMenuEnabled(), #PB_EventType_Change)
		SetGadgetState(#Toggle_TrackInput, General::Preferences(Enabled))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Toggle(#Toggle_Mouse, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_Mouse))
		SetGadgetFont(#Toggle_Mouse, General::OptionFont)
		GadgetToolTip(#Toggle_Mouse, Language(#ToolTip_Mouse))
		BindGadgetEvent(#Toggle_Mouse, @Handler_Mouse(), #PB_EventType_Change)
		SetGadgetState(#Toggle_Mouse, General::Preferences(General::#Pref_Mouse))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Toggle(#Toggle_Combo, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_Combo))
		SetGadgetFont(#Toggle_Combo, General::OptionFont)
		GadgetToolTip(#Toggle_Combo, Language(#ToolTip_Combo))
		BindGadgetEvent(#Toggle_Combo, @Handler_Combo(), #PB_EventType_Change)
		SetGadgetState(#Toggle_Combo, General::Preferences(General::#Pref_Combo))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Label(#Text_Duration, #Appearance_Window_Margin, Y, 200, 20, Language(#Lng_Duration))
		SetGadgetFont(#Text_Duration, General::OptionFont)
		UITK::TrackBar(#Trackbar_Duration, GadgetWidth(#Container_Appearance) - #Appearance_Window_Margin - #Appearance_TrackBar_Lenght, Y - 9, #Appearance_TrackBar_Lenght, 40, 5, 45, UITK::#Trackbar_ShowState)
		SetGadgetState(#Trackbar_Duration, General::Preferences(General::#Pref_Duration) * 0.01)
		SetGadgetAttribute(#Trackbar_Duration, UITK::#Trackbar_Scale, 10)
		SetGadgetText(#Trackbar_Duration, "s")
		AddGadgetItem(#Trackbar_Duration, 5, "")
		AddGadgetItem(#Trackbar_Duration, 20, "")
		AddGadgetItem(#Trackbar_Duration, 45, "")
		BindGadgetEvent(#Trackbar_Duration, @Handler_Duration(), #PB_EventType_Change)
		
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
		ContainerGadget(#Container_Controller, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - 30, #PB_Container_BorderLess)
		HideGadget(#Container_Controller, #True)
		ImageGadget(#ContainerCorner_Controller, 0, 0, 5, 5, 0)
		
		
		
		CloseGadgetList()
		;}
		
		;{ About
		ContainerGadget(#Container_About, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - 30, #PB_Container_BorderLess)
		HideGadget(#Container_About, #True)
		ImageGadget(#ContainerCorner_About, 0, 0, 5, 5, 0)
		
		
		
		CloseGadgetList()
		
; 		HyperLinkGadget(#HyperLink_Website, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 15, Language(#Lng_Website), General::FixColor($FF5E91), #PB_HyperLink_Underline)
; 		BindGadgetEvent(#HyperLink_Website, @HandlerHyperLink())
; 		HideGadget(#Container_Behavior, #True)
		;}
		
		;{ Systray
		AddSysTrayIcon(#Systray, WindowID, Icon)
		SysTrayIconToolTip(#Systray, General::#AppName)
		
		CreatePopupMenu(0)
		MenuItem(#Menu_Enabled, Language(#Lng_Menu_Enable))
		MenuItem(#Menu_Options, Language(#Lng_Menu_Options))
		MenuItem(#Menu_Quit, Language(#Lng_Menu_Quit))
		
		SetMenuItemState(0, #Menu_Enabled, #True)
		;}
		
		;{ Set up the popup window origin point to not interfere with the taskbar. See : https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shappbarmessage
		Protected pData.APPBARDATA
		SHAppBarMessage_(#ABM_GETTASKBARPOS, pData)
		ExamineDesktops()
		
		If pData\uEdge = #ABE_BOTTOM
			PopupWindow::SetPopupOrigin(10, DesktopHeight(0) - (pData\rc\bottom - pData\rc\top) - 10)
		ElseIf pData\uEdge = #ABE_LEFT
			PopupWindow::SetPopupOrigin(pData\rc\right + 10, DesktopHeight(0) - 10)
		EndIf
		;}
		
		;{ Event bindings
		BindEvent(#PB_Event_CloseWindow, @HandlerCloseWindow(), #Window)
		BindEvent(#PB_Event_SysTray, @HandlerSystray())
		BindEvent(General::#Event_Update, @HandlerUpdate())
		BindEvent(#PB_Event_Timer, @Handler_Timer(), #Window)
		
		BindMenuEvent(0, #Menu_Enabled, @HandlerMenuEnabled())
		BindMenuEvent(0, #Menu_Options, @HandlerMenuOptions())
		BindMenuEvent(0, #Menu_Quit, @HandlerMenuQuit())
		
		OpenWindow(#Window_SingleInstance, 0, 0, 10, 0, "60e272b1-eb20-4caa-9354-2142e2be78a0", #PB_Window_Invisible)
		SetWindowCallback(@WindowCallback(), #Window_SingleInstance)
		
		KeyboardHook = SetWindowsHookEx_(#WH_KEYBOARD_LL, @KeyboardHook(), GetModuleHandle_(0), 0)
		If General::Preferences(General::#Pref_Mouse)
			MouseHook = SetWindowsHookEx_(#WH_MOUSE_LL, @MouseHook(), GetModuleHandle_(0), 0)
		EndIf
		
		If General::FirstStart
			SystrayBalloon(General::#AppName, Language(#Lng_FirstStart), #NIIF_USER|#NIIF_INFO )
		EndIf
		;}
		
		;{ Create the location selector window (it works but it's very hacky, there has to be a proper solution): 
		LocationWindow = OpenWindow(#PB_Any, 0, 0, 101, 50, "", #PB_Window_Invisible | #PB_Window_BorderLess, WindowID)
		SetWindowLong_(WindowID(LocationWindow), #GWL_EXSTYLE, GetWindowLong_(WindowID(LocationWindow), #GWL_EXSTYLE) | #WS_EX_LAYERED)
		SetLayeredWindowAttributes_(WindowID(LocationWindow), $FF00FF, 255, #LWA_COLORKEY)
		
		StartDrawing(CanvasOutput(CanvasGadget(#PB_Any, 0, 0, 101, 50, #PB_Canvas_Container)))
		Box(0, 0, 101, 30, $FF00FF)
		FrontColor($FFFFFF)
		Line(50, 0, 1, 10)
		Line(50, 15, 1, 10)
		Line(38, 12, 10, 1)
		Line(53, 12, 10, 1)
		Plot(49, 10)
		Plot(51, 10)
		Plot(48, 11)
		Plot(52, 11)
		Plot(48, 13)
		Plot(52, 13)
		Plot(49, 14)
		Plot(51, 14)
		Box(0, 30, 101, 20, General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_Trackbar))
		Box(1, 31, 99, 18, General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold))
		StopDrawing()
		
		LocationText = TextGadget(#PB_Any, 1, 31, 99, 18, "x: y:", #PB_Text_Center)
		SetGadgetColor(LocationText, #PB_Gadget_BackColor, RGB(Red(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold)),
		                                                       Green(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold)),
		                                                       Blue(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold))))
		SetGadgetColor(LocationText, #PB_Gadget_FrontColor, RGB(Red(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_FrontHot)),
		                                                       Green(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_FrontHot)),
		                                                       Blue(General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_FrontHot))))
		;}
		
		SetColor()
		StickyWindow(LocationWindow, #True)
	EndProcedure
	;}
	
	;{ Private procedures
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
	
	Procedure AddPathRoundedBox(x.d, y.d, Width, Height, Radius, Flag = #PB_Path_Default)
		MovePathCursor(x, y + Radius, Flag)
		
		AddPathArc(0, Height - radius, Width, Height - radius, Radius, #PB_Path_Relative)
		AddPathArc(Width - Radius, 0, Width - Radius, - Height, Radius, #PB_Path_Relative)
		AddPathArc(0, Radius - Height, -Width, Radius - Height, Radius, #PB_Path_Relative)
		AddPathArc(Radius - Width, 0, Radius - Width, Height, Radius, #PB_Path_Relative)
		ClosePath()
	EndProcedure
	
	Procedure HandlerCloseWindow()
		HideWindow(#Window, #True)
	EndProcedure
	
	Procedure HandlerMenuEnabled()
		Protected Loop
		
		Enabled = Bool( Not GetMenuItemState(0, #Menu_Enabled))
		SetGadgetState(#Toggle_TrackInput, Enabled)
		SetMenuItemState(0, #Menu_Enabled, Enabled)
		
		If Enabled 
			KeyboardHook = SetWindowsHookEx_(#WH_KEYBOARD_LL, @KeyboardHook(), GetModuleHandle_(0), 0)
			
			If General::Preferences(General::#Pref_Mouse)
				MouseHook = SetWindowsHookEx_(#WH_MOUSE_LL, @MouseHook(), GetModuleHandle_(0), 0)
			EndIf
			
		Else
			UnhookWindowsHookEx_(KeyboardHook)
			KeyboardHook = 0
			
			If MouseHook
				UnhookWindowsHookEx_(MouseHook)
				MouseHook = 0
				
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
			
			For Loop = 0 To 255
				If InputArray(Loop)
					PopupWindow::Hide(InputArray(Loop))
					InputArray(Loop) = #False
				EndIf
			Next
			
		EndIf
	EndProcedure
	
	Procedure HandlerUpdate()
		If MessageRequester(General::#AppName, ~"A new version is available!\nDo you want to download it?",#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
			RunProgram("https://github.com/LastLifeLeft/Inputify/releases/latest")
		EndIf
	EndProcedure
	
	Procedure HandlerHyperLink()
		RunProgram("http://lastlife.net/")
	EndProcedure
	
	Procedure Handler_Scale()
		General::Preferences(General::#Pref_Scale) = GetGadgetState(EventGadget()) * 2
		PopupWindow::SetScale(General::Preferences(General::#Pref_Scale))
	EndProcedure
	
	Procedure Handler_Duration()
		General::Preferences(General::#Pref_Duration) = GetGadgetState(EventGadget()) * 100
	EndProcedure
	
	Procedure HandlerMenuOptions()
		HideWindow(#Window, #False, #PB_Window_ScreenCentered)
	EndProcedure
	
	Procedure HandlerMenuQuit()
		If CreatePreferences(General::PreferenceFile)
			PreferenceGroup("Appearance")
			WritePreferenceLong("DarkMode", General::Preferences(General::#Pref_DarkMode))
			WritePreferenceLong("Scale", General::Preferences(General::#Pref_Scale))
			
			PreferenceGroup("Behavior")
			WritePreferenceLong("Mouse", General::Preferences(General::#Pref_Mouse))
			WritePreferenceLong("Duration", General::Preferences(General::#Pref_Duration))				
			WritePreferenceLong("Combo", General::Preferences(General::#Pref_Combo))
			
			PreferenceGroup("About")
			WritePreferenceLong("Update", General::Preferences(General::#Pref_CheckUpdate))
			
			ClosePreferences()
		EndIf
		
		If IsSysTrayIcon(#Systray)
			RemoveSysTrayIcon(#Systray)
		EndIf
		
		End
	EndProcedure
	
	Procedure HandlerSystray()
		If EventType() = #PB_EventType_RightClick
			HookButton = #False
			DisplayPopupMenu(0, WindowID(#Window))
			
		ElseIf EventType() = #PB_EventType_LeftDoubleClick
			HandlerMenuOptions()
		EndIf
	EndProcedure
	
	Procedure Handler_DarkMode()
		General::Preferences(General::#Pref_DarkMode) = GetGadgetState(#Toggle_DarkMode)
		SetColor()
	EndProcedure
	
	Procedure Handler_Mouse()
		General::Preferences(General::#Pref_Mouse) = GetGadgetState(#Toggle_Mouse)
		
		If General::Preferences(General::#Pref_Mouse)
			If Enabled
				MouseHook = SetWindowsHookEx_(#WH_MOUSE_LL, @MouseHook(), GetModuleHandle_(0), 0)
			EndIf
		Else
			UnhookWindowsHookEx_(MouseHook)
			MouseHook = 0
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
	
	Procedure Handler_Timer()
		RemoveWindowTimer(#Window, 0)
		If HookButton
			InputArray(HookButton) = PopupWindow::Create(HookButton)
		EndIf
	EndProcedure
	
	Procedure Handler_Location()
		Protected Loop, DesktopCount
		LocationMouseHook = SetWindowsHookEx_(#WH_MOUSE_LL, @LocationMouseHook(), GetModuleHandle_(0), 0)
		LocationKeyboardHook = SetWindowsHookEx_(#WH_KEYBOARD_LL, @LocationKeyboardHook(), GetModuleHandle_(0), 0)
		
		DesktopCount = ExamineDesktops() - 1
		
		For Loop = 0 To DesktopCount
			AddElement(DesktopWindow())
			DesktopWindow() = OpenWindow(#PB_Any, DesktopX(Loop), DesktopY(Loop), DesktopWidth(Loop), DesktopHeight(Loop), "", #PB_Window_Invisible | #PB_Window_BorderLess, WindowID)
			SetWindowColor(DesktopWindow(), $141414)
			StickyWindow(DesktopWindow(), #True)
			SetWindowLongPtr_(WindowID(DesktopWindow()), #GWL_EXSTYLE, #WS_EX_LAYERED)
			SetLayeredWindowAttributes_(WindowID(DesktopWindow()), 0, 150, #LWA_ALPHA)
			HideWindow(DesktopWindow(), #False)
		Next
		
		SetGadgetText(LocationText, "x: " + Str(DesktopMouseX() - 50) + " y: " +Str(DesktopMouseY() - 12))
		SetWindowPos_(WindowID(LocationWindow), 0, DesktopMouseX() - 50, DesktopMouseY() - 12, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER|#SWP_NOREDRAW)
		HideWindow(LocationWindow, #False)
		SetActiveWindow(LocationWindow)
		ShowCursor_(#False)
	EndProcedure
	
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
	
	Procedure KeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
		If nCode = #HC_ACTION
			If (*p\vkCode = #VK_LCONTROL Or *p\vkCode = #VK_RCONTROL)
				*p\vkCode = #VK_CONTROL
			ElseIf (*p\vkCode = #VK_LSHIFT Or *p\vkCode = #VK_RSHIFT)
				*p\vkCode = #VK_SHIFT
			ElseIf (*p\vkCode = #VK_LMENU Or *p\vkCode = #VK_RMENU)
				*p\vkCode = #VK_MENU
			EndIf
			
			If wParam = #WM_KEYDOWN
				If Not InputArray(*p\vkCode)
					If (*p\vkCode = #VK_CONTROL)
						InputArray(*p\vkCode) = PopupWindow::Create(*p\vkCode)
						Ctrl = #True
					ElseIf (*p\vkCode = #VK_SHIFT)
						If Ctrl
							PopupWindow::ShortCut(Ctrl, Shift, Alt, *p\vkCode)
						Else
							InputArray(*p\vkCode) = PopupWindow::Create(*p\vkCode)
						EndIf
						Shift = #True
					ElseIf (*p\vkCode = #VK_MENU)
						If Ctrl
							PopupWindow::ShortCut(Ctrl, Shift, Alt, *p\vkCode)
						Else 
							InputArray(*p\vkCode) = PopupWindow::Create(*p\vkCode)
						EndIf
						Alt = #True
					ElseIf Ctrl Or Shift Or Alt
						PopupWindow::ShortCut(Ctrl, Shift, Alt, *p\vkCode)
					Else
						InputArray(*p\vkCode) = PopupWindow::Create(*p\vkCode)
					EndIf
				Else
					; Hold!
				EndIf
			Else
				If (*p\vkCode = #VK_CONTROL)
					Ctrl = #False
				ElseIf (*p\vkCode = #VK_SHIFT)
					Shift = #False
				ElseIf (*p\vkCode = #VK_MENU)
					Alt = #False
				EndIf
				
				If InputArray(*p\vkCode)
					; An input has been released, start the windows disparition timer
					PopupWindow::Hide(InputArray(*p\vkCode))
					InputArray(*p\vkCode) = #False
				EndIf
			EndIf
		EndIf
		
		ProcedureReturn CallNextHookEx_(#NUL, nCode, wParam, *p)
	EndProcedure
	
	Procedure MouseHook(nCode, wParam, *p.MOUSEHOOKSTRUCT)
		If nCode = #HC_ACTION
			Select wParam 
				Case #WM_LBUTTONDOWN
					AddWindowTimer(#Window, 0, 1)
					HookButton = #VK_LBUTTON
				Case #WM_RBUTTONDOWN
					AddWindowTimer(#Window, 0, 1)
					HookButton = #VK_RBUTTON
				Case #WM_MBUTTONDOWN
					AddWindowTimer(#Window, 0, 1)
					HookButton = #VK_MBUTTON
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
		
		ForEach DesktopWindow()
			CloseWindow(DesktopWindow())
		Next
		ClearList(DesktopWindow())
		
		HideWindow(LocationWindow, #True)
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
					SetGadgetText(LocationText, "x: " + Str(*p\pt\x - 50) + " y: " +Str(*p\pt\y - 12))
					SetWindowPos_(WindowID(LocationWindow), 0, *p\pt\x - 50, *p\pt\y - 12, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER|#SWP_NOREDRAW)
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
		SetToggleAppearance(#Toggle_TrackInput)
		SetToggleAppearance(#Toggle_Mouse)
		
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
; 		
; 		SetGadgetColor(#HyperLink_Website, #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(#HyperLink_Website, #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
; 		
; 		SetGadgetColor(#HyperLink_Website, #PB_Gadget_BackColor, GetGadgetColor(#Button_Location, UITK::#Color_Parent))
; 		SetGadgetColor(#HyperLink_Website, #PB_Gadget_FrontColor, RGB(Red(General::ColorScheme(General::Preferences(General::#Pref_DarkMode),General::#Color_Type_FrontCold)),
; 		                                                            Green(General::ColorScheme(General::Preferences(General::#Pref_DarkMode),General::#Color_Type_FrontCold)),
; 		                                                            Blue(General::ColorScheme(General::Preferences(General::#Pref_DarkMode),General::#Color_Type_FrontCold))))
	EndProcedure
	
	Procedure WindowCallback(hWnd, Msg, wParam, lParam)
		If Msg = #WM_INSTANCESTART
			HandlerMenuOptions()
		EndIf
		
		ProcedureReturn #PB_ProcessPureBasicEvents
	EndProcedure
	
	Procedure VListItemRedraw(*Item.UITK::VerticalListItem, X, Y, Width, Height, State)
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
		
		UITK::DrawVectorTextBlock(@*Item\Text, X + 25, Y - 2)
		
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
		;MainWindow settings
		Data.s "Dark mode", "Input scale", "Track Mouse", "Window duration", "Combo regroupment", "Move popup origin", "Auto-update", "Visit ❤x1's website", "Input color"
		
		;MainWindow tooltips
		Data.s "Switch between the dark and light theme", "Changes the size of the input popup", "Include mouse click in the tracked inputs", "Change the time spent on screen", "Regroup identical inputs as a group", "Enable the tracking altogether.", "Check update at startup"
		
		;Titles
		Data.s "Appearance", "Behavior", "About", "Controller", "General", "Input", "Misc"
		
		;Menu
		Data.s "Track inputs", "Preferences", "Quit"
		
		Data.s "Inputify has started, you can find it in your system tray icons!"
		
		;Themes
		Data.s "Light theme", "Dark theme", "Blue theme", "Pink theme"
		
		French:
		;MainWindow settings
		Data.s "Mode sombre", "Taille", "Souris", "Durée d'affichage", "Regrouper les séries", "Déplacer le point d'apparition", "Surveiller les MàJ", "Aller sur le site de ❤x1", "Input color"
		
		;MainWindow tooltips
		Data.s "Alterne entre les modes sombre et clair", "Modifie la taille des inputs à l'écran", "Ajoute la souris aux inputs", "Change la durée d'affichage d'un input", "Regroupe les séries d'inputs", "", "Au démarrage, vérifie si une nouvelle version est disponible"
		
		;Titles
		Data.s "Apparence", "Comportement", "Divers", "Manette", "Général", "Input", "Misc"
		
		;Menu
		Data.s "Afficher les inputs", "Préférences", "Quitter"
		
		Data.s "Inputify a correctement démarré, vous pouvez le retrouver dans les icônes de la barre d'état !"
		
		;Themes
		Data.s "Clair", "Sombre", "Bleu", "Rose"
		
		Icon18:
		IncludeBinary "../Media/Icon/18.png"
		
	EndDataSection ;}
	
EndModule
; IDE Options = PureBasic 6.00 Beta 9 (Windows - x64)
; CursorPosition = 898
; FirstLine = 264
; Folding = 0BGCAACA6
; EnableXP