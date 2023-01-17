Module MainWindow
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
		
		#Lng_Markdown
		
		#_Lng_Count
	EndEnumeration
	
	Global Dim Language.s(#_Lng_Count)
	;}
	
	;{ Windows and gadgets
	#Window = 0
	#Window_SingleInstance = 1
	#Window_ColorChoice = 2
	
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
		#Radio_Custom
		#CustomColor0
		#CustomColor1
		#CustomColor2
		#CustomColor3
		#CustomColor4
		#CustomColor5
		#SubContainer_Appearance
		#Scrollbar_Appearance
		#Scrollarea_Appearance
		
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
		
		#Container_ColorChoice
		#ColorPicker_ColorChoice
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
	#Appearance_Window_Height = 570
	#Appearance_Window_Margin = 135
	#Appearance_Window_TitleMargin = #Appearance_Window_Margin - 20
	#Appearance_Window_OptionSpacing = 45
	#Appearance_Window_TitleSpacing = #Appearance_Window_OptionSpacing + 15
	#Appearance_TrackBar_Lenght = 220
	#Appearance_LeftPanel_Width = 285
	#Appearance_LeftPanel_ItemHeight = 50
	#Appearance_MarkDown_Margin = 90
	#Appearance_Window_ItemWidth = #Appearance_Window_Width - #Appearance_LeftPanel_Width - 2 * #Appearance_Window_Margin
	#Appearance_Corner_Size = 5
	#Appearance_Scrollbar_Size = 7
	
	#Appearance_ColorChoice_Width = 200
	#Appearance_ColorChoice_Height = 245
	
	#Appearance_Option_Width = #Appearance_Window_Width - 2 *#Appearance_Window_TitleMargin
	;}
	
	#WH_KEYBOARD_LL = 13
	#WM_INSTANCESTART = 111
	
	Global MouseHook, MouseHook_Button, KeyboardHook
	Global LocationMouseHook, LocationKeyboardHook, LocationInformationWindow, LocationInformationText
	Global KeepColorChoice = -1
	Global Dim CornerImage(1)
	Global NewList LocationInformationWindows()
	Global *ScrollBar_Event_Manager, *Radio_Event_Manager
	
	;{ Private procedures declaration
	Declare SystrayBalloon(Title.s,Message.s,Flags)
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
	Declare Handler_Timer()
	Declare Handler_Location()
	Declare Handler_Wheel_Appearance()
	Declare Handler_LeftPanel()
	Declare Handler_Radio()
	Declare Handler_ScrollArea_Appearance()
	Declare Handler_ScrollBar_Appearance()
	Declare Handler_CustomColor()
	Declare Handler_CustomColorWindow_Timer()
	Declare Handler_CustomColorWindow()
	Declare KeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare MouseHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare LocationMouseHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare LocationKeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare SetColor()
	Declare WindowCallback(hWnd, Msg, wParam, lParam)
	Declare VListItemRedraw(*Item.UITK::VerticalListItem, X, Y, Width, Height, State)
	Macro CustomColor(Gadget)
		CanvasGadget(Gadget, 158 + (Gadget - #CustomColor0) * 48, 8, 39, 22)
		SetGadgetAttribute(Gadget, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		StartDrawing(CanvasOutput(Gadget))
		Box(1,1, 37, 20, General::KeyScheme(General::#Scheme_Custom, Gadget - #CustomColor0))
		StopDrawing()
		BindGadgetEvent(Gadget, @Handler_CustomColor())
	EndMacro
	
	;}
	
	;Public procedures
	Procedure Open()
		; Check if another instance is already running signal it
		Protected InstanceWindow = FindWindow_(#Null, "60e272b1-eb20-4caa-9354-2142e2be78a0")
		Protected cchData, lpLCData.s, Loop, Y, Icon = ImageID(CatchImage(#PB_Any, ?Icon18))
		
		If InstanceWindow
			CompilerIf #PB_Compiler_Debugger
				MessageRequester("Inputify", "Another instance is already running")
			CompilerEndIf
			SendMessage_(InstanceWindow, #WM_INSTANCESTART, 0, 0)
			Handler_MenuQuit() 
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
		WindowID = UITK::Window(#Window, 0, 0, #Appearance_Window_Width, #Appearance_Window_Height, General::#AppName, UITK::#Window_Invisible | UITK::#Window_ScreenCentered | UITK::#HAlignLeft | UITK::#Window_CloseButton | UITK::#DarkMode)
		UITK::WindowSetColor(#Window, UITK::#Color_Parent, UITK::WindowGetColor(#Window, UITK::#Color_WindowBorder))
		StickyWindow(#Window, #True)
		DisableWindow(#Window, #True)
		UITK::SetWindowIcon(#Window, Icon)
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
 		AddGadgetItem(#VList_Menu, -1, Language(#Lng_About))
 		SetGadgetState(#VList_Menu, 0)
 		ResizeGadget(#VList_Menu, #PB_Ignore, (WindowHeight(#Window) - 30 - (#Appearance_LeftPanel_ItemHeight * CountGadgetItems(#VList_Menu))) * 0.5, #PB_Ignore, #PB_Ignore)
 		BindGadgetEvent(#VList_Menu, @Handler_LeftPanel(), #PB_EventType_Change)
 		;}
 		
 		;{ Appearance 
		ContainerGadget(#Container_Appearance, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - 30, #PB_Container_BorderLess)
		ImageGadget(#ContainerCorner_Appearance, 0, 0, #Appearance_Corner_Size, #Appearance_Corner_Size, 0)
		
		ContainerGadget(#SubContainer_Appearance, #Appearance_Corner_Size, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width - #Appearance_Corner_Size - #Appearance_Scrollbar_Size - 4, WindowHeight(#Window) - 30)
		ScrollAreaGadget(#Scrollarea_Appearance, 0, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width + 40, WindowHeight(#Window) + 10, #Appearance_Window_Width - #Appearance_LeftPanel_Width - 40, 780, 50, #PB_ScrollArea_BorderLess)
		BindGadgetEvent(#Scrollarea_Appearance, @Handler_ScrollArea_Appearance())
		
		Y = 60
		
		UITK::Label(#Title_Input, #Appearance_Window_TitleMargin, Y, 200, 20, "Behavior")
; 		BindGadgetEvent(#Title_Input, @Handler_Wheel_Appearance(), #PB_EventType_MouseWheel)
		BindEvent(#PB_Event_Gadget, @Handler_Wheel_Appearance(), #Window, #PB_All, #PB_All)
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
		
		UITK::TrackBar(#Trackbar_Duration, GadgetWidth(#Container_Appearance) - #Appearance_Window_Margin - #Appearance_TrackBar_Lenght, Y - 9, #Appearance_TrackBar_Lenght, 42, 5, 45, UITK::#Trackbar_ShowState)
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
		
		Y + #Appearance_Window_TitleSpacing
		
		
		UITK::Label(#Title_UserInterface, #Appearance_Window_TitleMargin, Y, 200, 20, Language(#Lng_UserInterface))
		SetGadgetFont(#Title_UserInterface, General::TitleFont)
		
		Y + 31
		
; 		UITK::Toggle(#Toggle_DarkMode, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_DarkMode))
; 		SetGadgetFont(#Toggle_DarkMode, General::OptionFont)
; 		GadgetToolTip(#Toggle_DarkMode, Language(#ToolTip_DarkMode))
; 		BindGadgetEvent(#Toggle_DarkMode, @Handler_DarkMode(), #PB_EventType_Change)
; 		SetGadgetState(#Toggle_DarkMode, General::Preferences(General::#Pref_DarkMode))
; 		
; 		Y + #Appearance_Window_OptionSpacing
		
		UITK::TrackBar(#Trackbar_Scale, GadgetWidth(#Container_Appearance) - #Appearance_Window_Margin - #Appearance_TrackBar_Lenght, Y - 9, #Appearance_TrackBar_Lenght, 42, 25, 150, UITK::#Trackbar_ShowState)
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
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Button(#Button_Location, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24, Language(#Lng_Location), UITK::#Border)
		BindGadgetEvent(#Button_Location, @Handler_Location(), #PB_EventType_Change)
		
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
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Radio(#Radio_Custom, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 38, "Custom theme", "Color Theme", UITK::#HAlignCenter | UITK::#Container)
		SetGadgetFont(#Radio_Custom, General::OptionFont)
		BindGadgetEvent(#Radio_Custom, @Handler_Radio(), #PB_EventType_Change)
		
		SetGadgetState(#Radio_Dark + General::Preferences(General::#Pref_InputColor), #True)
		
		CustomColor(#CustomColor0)
		CustomColor(#CustomColor1)
		CustomColor(#CustomColor2)
		CustomColor(#CustomColor3)
		CustomColor(#CustomColor4)
		CustomColor(#CustomColor5)
		
		CloseGadgetList()
 		CloseGadgetList()
 		CloseGadgetList()
		UITK::ScrollBar(#Scrollbar_Appearance, #Appearance_Window_Width - #Appearance_LeftPanel_Width - 4 - #Appearance_Scrollbar_Size, 4, #Appearance_Scrollbar_Size, WindowHeight(#Window) - 30 - 2 * 4, 0, 780, WindowHeight(#Window) + 10, UITK::#Gadget_Vertical | UITK::#DarkMode)
		BindGadgetEvent(#Scrollbar_Appearance, @Handler_ScrollBar_Appearance(), #PB_EventType_Change)
		SetGadgetAttribute(#Scrollbar_Appearance, UITK::#ScrollBar_ScrollStep, 50)
		
		CloseGadgetList() ;}
		
		;{ Behavior
		ContainerGadget(#Container_Behavior, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - 30, #PB_Container_BorderLess)
		HideGadget(#Container_Behavior, #True)
		ImageGadget(#ContainerCorner_Behavior, 0, 0, 5, 5, 0)
; 		
; 		Y = 120
; 		
; 	
; 		
; 		UITK::Label(#Title_Misc, #Appearance_Window_TitleMargin, Y, 200, 20, Language(#Lng_Misc))
; 		SetGadgetFont(#Title_Misc, General::TitleFont)
; 		
; 		Y + 31
; 		
; 		UITK::Toggle(#Toggle_CheckUpdate, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Lng_CheckUpdate))
; 		SetGadgetFont(#Toggle_CheckUpdate, General::OptionFont)
; 		GadgetToolTip(#Toggle_CheckUpdate, Language(#ToolTip_CheckUpdate))
; 		BindGadgetEvent(#Toggle_CheckUpdate, @Handler_CheckUpdate(), #PB_EventType_Change)
; 		SetGadgetState(#Toggle_CheckUpdate, General::Preferences(General::#Pref_CheckUpdate))
; 		
		CloseGadgetList() ;}
		
		;{ Controller
		ContainerGadget(#Container_Controller, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - 30, #PB_Container_BorderLess)
		HideGadget(#Container_Controller, #True)
		ImageGadget(#ContainerCorner_Controller, 0, 0, #Appearance_Corner_Size, #Appearance_Corner_Size, 0)
		
		CloseGadgetList()
		;}
		
		;{ About
		ContainerGadget(#Container_About, #Appearance_LeftPanel_Width, 0, #Appearance_Window_Width - #Appearance_LeftPanel_Width, WindowHeight(#Window) - 30, #PB_Container_BorderLess)
		HideGadget(#Container_About, #True)
		ImageGadget(#ContainerCorner_About, 0, 0, 5, 5, 0)
		
		MarkDown::Gadget(#MarkDown, #Appearance_MarkDown_Margin, 10, #Appearance_Window_Width - #Appearance_LeftPanel_Width - #Appearance_MarkDown_Margin * 2, GadgetHeight(#Container_About) - 20, MarkDown::#Borderless)
		MarkDown::SetText(#MarkDown, Language(#Lng_Markdown))
		MarkDown::SetFont(#MarkDown, "Segoe UI", 10)
		CloseGadgetList()
		;}
		
		;{ Systray
		AddSysTrayIcon(#Systray, WindowID, Icon)
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
		BindEvent(#PB_Event_CloseWindow, @Handler_CloseWindow(), #Window)
		BindEvent(#PB_Event_SysTray, @Handler_Systray())
		BindEvent(General::#Event_Update, @Handler_Update())
		
		BindMenuEvent(0, #Menu_KeyboardTracking, @Handler_TrackKeyboard())
		BindMenuEvent(0, #Menu_MouseTracking, @Handler_TrackMouse())
		BindMenuEvent(0, #Menu_Options, @Handler_MenuOptions())
		BindMenuEvent(0, #Menu_Quit, @Handler_MenuQuit())
		
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
		;}
		
		;{ Create the location selector window (it works but it's very hacky, there has to be a proper solution): 
		LocationInformationWindow = OpenWindow(#PB_Any, 0, 0, 101, 50, "", #PB_Window_Invisible | #PB_Window_BorderLess, WindowID)
		SetWindowLong_(WindowID(LocationInformationWindow), #GWL_EXSTYLE, GetWindowLong_(WindowID(LocationInformationWindow), #GWL_EXSTYLE) | #WS_EX_LAYERED)
		SetLayeredWindowAttributes_(WindowID(LocationInformationWindow), $FF00FF, 255, #LWA_COLORKEY)
		
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
		
		; Get the scrollbar event manager adress :
		*ScrollBar_Event_Manager = UITK::SubClassFunction(#Scrollbar_Appearance, UITK::#SubClass_EventHandler, #Null)
		*Radio_Event_Manager = UITK::SubClassFunction(#Radio_Custom, UITK::#SubClass_EventHandler, #Null)
		
		;{ Custom color selection window
		UITK::Window(#Window_ColorChoice, 0, 0, #Appearance_ColorChoice_Width, #Appearance_ColorChoice_Height, "Color picker", UITK::#Window_Invisible | UITK::#Window_ScreenCentered | UITK::#DarkMode, WindowID)
		OpenWindow(#Window_ColorChoice, 0, 0, #Appearance_ColorChoice_Width, #Appearance_ColorChoice_Height, "", #PB_Window_BorderLess | #PB_Window_Invisible, WindowID)
		ContainerGadget(#Container_ColorChoice, 1, 1, #Appearance_ColorChoice_Width - 2, #Appearance_ColorChoice_Height - 2, #PB_Container_BorderLess)
		UITK::ColorPicker(#ColorPicker_ColorChoice, 5, 5, #Appearance_ColorChoice_Width - 9, #Appearance_ColorChoice_Height - 10)
		BindEvent(#PB_Event_DeactivateWindow, @Handler_CustomColorWindow(), #Window_ColorChoice)
		BindEvent(#PB_Event_Timer, @Handler_CustomColorWindow_Timer(), #Window_ColorChoice)
		;}
		
		
		SetColor()
	EndProcedure
	
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
			KeyboardHook = SetWindowsHookEx_(#WH_KEYBOARD_LL, @KeyboardHook(), GetModuleHandle_(0), 0)
			
		Else
			UnhookWindowsHookEx_(KeyboardHook)
			KeyboardHook = 0
			
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
			RunProgram("https://github.com/LastLifeLeft/Inputify/releases/latest")
		EndIf
	EndProcedure
	
	Procedure Handler_HyperLink()
		RunProgram("http://lastlife.net/")
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
	EndProcedure
	
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
			
			PreferenceGroup("About")
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
			MouseHook = SetWindowsHookEx_(#WH_MOUSE_LL, @MouseHook(), GetModuleHandle_(0), 0)
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
			LocationInformationWindows() = OpenWindow(#PB_Any, DesktopX(Loop), DesktopY(Loop), DesktopWidth(Loop), DesktopHeight(Loop), "", #PB_Window_Invisible | #PB_Window_BorderLess, WindowID)
			SetWindowColor(LocationInformationWindows(), $141414)
			StickyWindow(LocationInformationWindows(), #True)
			SetWindowLongPtr_(WindowID(LocationInformationWindows()), #GWL_EXSTYLE, #WS_EX_LAYERED)
			SetLayeredWindowAttributes_(WindowID(LocationInformationWindows()), 0, 150, #LWA_ALPHA)
			HideWindow(LocationInformationWindows(), #False)
		Next
		
		SetGadgetText(LocationInformationText, "x: " + Str(DesktopMouseX() - 50) + " y: " +Str(DesktopMouseY() - 12))
		SetWindowPos_(WindowID(LocationInformationWindow), 0, DesktopMouseX() - 50, DesktopMouseY() - 12, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER|#SWP_NOREDRAW)
		HideWindow(LocationInformationWindow, #False)
		SetActiveWindow(LocationInformationWindow)
		ShowCursor_(#False)
		
		DisableWindow(LocationInformationWindow, #False)
	EndProcedure
	
	Procedure Handler_Wheel_Appearance()
		Protected Event.UITK::Event, Gadget
		If EventType() = #PB_EventType_MouseWheel
			Select GetGadgetState(#VList_Menu)
				Case 0 ; Popup
					Gadget = EventGadget()
					If Gadget <> #Scrollbar_Appearance
						Event\EventType	= UITK::#MouseWheel
						Event\Param = GetGadgetAttribute(Gadget, #PB_Canvas_WheelDelta)
						
						CallFunctionFast(*ScrollBar_Event_Manager, PeekI(IsGadget(#Scrollbar_Appearance) + 8), Event) ; PeekI(IsGadget(#Scrollbar_Appearance) + 8) is a dirty hack to get the UITK gadget adress. This should be changed once the UITK API is finalized
					EndIf
				Case 1 ; Overlay
					
			EndSelect
		EndIf
	EndProcedure
	
	Procedure Handler_LeftPanel()
		Select GetGadgetState(#VList_Menu)
			Case 0 ; Popup
				HideGadget(#Container_Appearance, #False)
				HideGadget(#Container_Behavior, #True)
				HideGadget(#Container_About, #True)
				HideGadget(#Container_Controller, #True)
				
			Case 1 ; Overlay
				HideGadget(#Container_Behavior, #False)
				HideGadget(#Container_Appearance, #True)
				HideGadget(#Container_About, #True)
				HideGadget(#Container_Controller, #True)
				
; 			Case 2; Controller
; 				HideGadget(#Container_Behavior, #True)
; 				HideGadget(#Container_Appearance, #True)
; 				HideGadget(#Container_About, #True)
; 				HideGadget(#Container_Controller, #False)
				
			Case 2 ; About
				HideGadget(#Container_Behavior, #True)
				HideGadget(#Container_Appearance, #True)
				HideGadget(#Container_About, #False)
				HideGadget(#Container_Controller, #True)
				
		EndSelect
	EndProcedure
	
	Procedure Handler_Radio()
		General::Preferences(General::#Pref_InputColor) = EventGadget() - #Radio_Dark
	EndProcedure
	
	Procedure Handler_ScrollArea_Appearance()
		If EventType() = 0
			SetGadgetState(#Scrollbar_Appearance, GetGadgetAttribute(#Scrollarea_Appearance, #PB_ScrollArea_Y))
		EndIf
	EndProcedure
	
	Procedure Handler_ScrollBar_Appearance()
		SetGadgetAttribute(#Scrollarea_Appearance, #PB_ScrollArea_Y, GetGadgetState(#Scrollbar_Appearance))
	EndProcedure
	
	Procedure Handler_CustomColor()
		Protected Event.UITK::Event, Gadget
		
		Select EventType()
			Case #PB_EventType_LeftButtonDown
				If Not GetGadgetState(#Radio_Custom)
					Event\EventType = UITK::#LeftClick
					CallFunctionFast(*Radio_Event_Manager, PeekI(IsGadget(#Radio_Custom) + 8), Event)
				EndIf
				
				Gadget = EventGadget()
				
				SetGadgetState(#ColorPicker_ColorChoice, General::KeyScheme(General::#Scheme_Custom, Gadget - #CustomColor0))
				ResizeWindow(#Window_ColorChoice, GadgetX(Gadget, #PB_Gadget_ScreenCoordinate) - 81, GadgetY(Gadget, #PB_Gadget_ScreenCoordinate) - WindowHeight(#Window_ColorChoice) - 15, #PB_Ignore, #PB_Ignore)
				KeepColorChoice + 1
				HideWindow(#Window_ColorChoice, #False)
				
			Case #PB_EventType_MouseEnter, #PB_EventType_MouseMove
				Event\EventType = UITK::#MouseEnter
				CallFunctionFast(*Radio_Event_Manager, PeekI(IsGadget(#Radio_Custom) + 8), Event)
		EndSelect
	EndProcedure
	
	Procedure Handler_CustomColorWindow_Timer()
		RemoveWindowTimer(#Window_ColorChoice, 1)
		If KeepColorChoice
			SetActiveWindow(#Window_ColorChoice)
		Else
			HideWindow(#Window_ColorChoice, #True)
		EndIf
		KeepColorChoice - 1
	EndProcedure
	
	Procedure Handler_CustomColorWindow()
		AddWindowTimer(#Window_ColorChoice, 1, 50)
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
					SetGadgetText(LocationInformationText, "x: " + Str(*p\pt\x - 50) + " y: " +Str(*p\pt\y - 12))
					SetWindowPos_(WindowID(LocationInformationWindow), 0, *p\pt\x - 50, *p\pt\y - 12, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER|#SWP_NOREDRAW)
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
		SendMessage_(GadgetID(#Container_Appearance), #WM_SETREDRAW, #False, 0)
		
		SetContainerColor(#Container_Appearance)
		SetContainerColor(#SubContainer_Appearance)
		SetContainerColor(#Scrollarea_Appearance)
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
; 		SetTitleAppearance(#Title_Misc)
		
		SetTextAppearance(#Text_Scale)
		SetTextAppearance(#Text_Duration)
		
; 		SetToggleAppearance(#Toggle_DarkMode)
; 		SetToggleAppearance(#Toggle_CheckUpdate)
		SetToggleAppearance(#Toggle_Combo)
		SetToggleAppearance(#Toggle_TrackKeyboard)
		SetToggleAppearance(#Toggle_TrackMouse)
		
		SetRadioAppearance(#Radio_Dark)
		SetRadioAppearance(#Radio_Light)
		SetRadioAppearance(#Radio_Pink)
		SetRadioAppearance(#Radio_Blue)
		SetRadioAppearance(#Radio_Custom)
		
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
		
		SendMessage_(GadgetID(#Container_Appearance), #WM_SETREDRAW, #True, 0)
		RedrawWindow_(GadgetID(#Container_Appearance), 0, 0, #RDW_ERASE | #RDW_INVALIDATE)
		
		SetGadgetColor(#Container_ColorChoice, #PB_Gadget_BackColor, UITK::WindowGetColor(#Window, UITK::#Color_WindowBorder))
		SetGadgetColor(#ColorPicker_ColorChoice, UITK::#Color_Parent, General::SetAlpha(255, UITK::WindowGetColor(#Window, UITK::#Color_WindowBorder)))
		SetWindowColor(#Window_ColorChoice, GetGadgetColor(#Radio_Blue, UITK::#Color_Text_Cold))
	EndProcedure
	
	Procedure WindowCallback(hWnd, Msg, wParam, lParam)
		If Msg = #WM_INSTANCESTART
			Handler_MenuOptions()
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
	
	DataSection
		
		English:
		IncludeFile "../Language/English.pbi"
		
		French:
		IncludeFile "../Language/Français.pbi"
		
		Icon18:
		IncludeBinary "../Media/Icon/18.png"
		
	EndDataSection
	
EndModule
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 838
; FirstLine = 234
; Folding = 6SAYAAAMAA-
; EnableXP