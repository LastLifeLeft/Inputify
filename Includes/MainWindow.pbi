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
		#Lng_Mouse
		#Lng_Duration
		#Lng_Combo
		#Lng_Location
		#Lng_CheckUpdate
		#Lng_About
		
		#ToolTip_DarkMode
		#ToolTip_Scale
		#ToolTip_Mouse
		#ToolTip_Duration
		#ToolTip_Combo
		#ToolTip_Location
		#ToolTip_CheckUpdate
		
		#Lng_UserInterface
		#Lng_Behavior
		#Lng_Misc               
		
		#Lng_Menu_Enable
		#Lng_Menu_Options
		#Lng_Menu_Quit
		
		#Lng_FirstStart
		
		#_Lng_Count
	EndEnumeration
	
	Global Dim Language.s(#_Lng_Count)
	;}
	
	;{ Windows and gadgets
	#Window = 0
	#Window_SingleInstance = 1
	
	Enumeration ;Gadget
		#Canvas_DarkMode
		#Canvas_Scale
		#Canvas_Mouse
		#Canvas_Duration
		#Canvas_Combo
		#Canvas_Location
		#Canvas_CheckUpdate
		#HyperLink_About
		
		#Text_UserInterface
		#Text_Behavior
		#Text_Misc
		#Text_Scale
		#Text_Duration
		                         
		#Canvas
	EndEnumeration
	
	#Systray = 0
	
	Enumeration ;Menu ID
		#Menu_Enabled
		#Menu_Options
		#Menu_Quit
	EndEnumeration		
	;}
	
	;{ Appearance
	#Appearance_Window_Width = 400
	#Appearance_Window_Height = 580
	#Appearance_Window_TitleMargin = 50
	#Appearance_Window_Margin = 56
	#Appearance_Window_ItemWidth = 288
	#Appearance_Window_OptionSpacing = 45
	
	#Appearance_Option_Width = #Appearance_Window_Width - 2 *#Appearance_Window_TitleMargin
	;}
	
	#WH_KEYBOARD_LL = 13
	#WM_INSTANCESTART = 111
	
	Global PopupMenu
	Global Enabled = #True
	Global MouseOffset = -1000
	Global MouseHook, KeyboardHook
	Global LocationMouseHook, LocationKeyboardHook, LocationWindow, LocationText
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
	Declare KeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare MouseHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare LocationMouseHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare LocationKeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare SetColor()
	Declare WindowCallback(hWnd, Msg, wParam, lParam)
	
	;{ Public procedures
	Procedure Open()
		; Check if another instance is already running signal it
		Protected InstanceWindow = FindWindow_(#Null, "60e272b1-eb20-4caa-9354-2142e2be78a0")
		If InstanceWindow
			SendMessage_(InstanceWindow, #WM_INSTANCESTART, 0, 0)
			HandlerMenuQuit() 
		EndIf
		
		WindowID = UITK::Window(#Window, 0, 0, #Appearance_Window_Width, #Appearance_Window_Height, General::#AppName, #PB_Window_Invisible | #PB_Window_ScreenCentered | UITK::#Window_CloseButton | UITK::#DarkMode)
		
		; Languageè
		Protected cchData, lpLCData.s, Loop, Y = 81
		cchData = GetLocaleInfo_(#LOCALE_USER_DEFAULT, #LOCALE_SNATIVELANGNAME, @lpLCData, 0)
		lpLCData = Space(cchData)
		GetLocaleInfo_(#LOCALE_USER_DEFAULT, #LOCALE_SNATIVELANGNAME, @lpLCData, cchData)
		
		Select lpLCData
			Case "français"
				Restore French:
			Default
				Restore English:
		EndSelect
		
		For Loop = #Lng_DarkMode To #Lng_FirstStart
			Read.s Language(Loop)
		Next
		
		UITK::SetWindowIcon(#Window, ImageID(CatchImage(#PB_Any, ?Icon)))

		StickyWindow(#Window, #True)
		
		UITK::Label(#Text_UserInterface, #Appearance_Window_TitleMargin, 50, 200, 20, Language(#Lng_UserInterface))
		SetGadgetFont(#Text_UserInterface, General::TitleFont)
		UITK::Label(#Text_Behavior, #Appearance_Window_TitleMargin, 200, 200, 20, Language(#Lng_Behavior))
		SetGadgetFont(#Text_Behavior, General::TitleFont)
		UITK::Label(#Text_Misc, #Appearance_Window_TitleMargin, 440, 200, 20, Language(#Lng_Misc))
		SetGadgetFont(#Text_Misc, General::TitleFont)
		
		UITK::Toggle(#Canvas_DarkMode, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Canvas_DarkMode))
		SetGadgetFont(#Canvas_DarkMode, General::OptionFont)
		SetGadgetColor(#Canvas_DarkMode, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(#Canvas_DarkMode, UITK::#Color_Text_Warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		GadgetToolTip(#Canvas_DarkMode, Language(#ToolTip_DarkMode))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Label(#Text_Scale, #Appearance_Window_Margin, Y + 5, 100, 20, Language(#Lng_Scale))
		SetGadgetFont(#Text_Scale, General::OptionFont)
		SetGadgetColor(#Text_Scale, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		UITK::TrackBar(#Canvas_Scale, WindowWidth(#Window) - #Appearance_Window_Margin - 150, Y - 4, 150, 40, 25, 175, UITK::#Trackbar_ShowState)
		SetGadgetState(#Canvas_Scale, General::Preferences(General::#Pref_Scale) * 0.5)
		SetGadgetAttribute(#Canvas_Scale, UITK::#Trackbar_Scale, 50)
		SetGadgetText(#Canvas_Scale, "x")
		AddGadgetItem(#Canvas_Scale, 25, "")
		AddGadgetItem(#Canvas_Scale, 50, "")
		AddGadgetItem(#Canvas_Scale, 175, "")
		
		Y + #Appearance_Window_OptionSpacing + 60
		
		UITK::Toggle(#Canvas_Mouse, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Canvas_Mouse))
		SetGadgetFont(#Canvas_Mouse, General::OptionFont)
		SetGadgetColor(#Canvas_Mouse, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(#Canvas_Mouse, UITK::#Color_Text_warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		GadgetToolTip(#Canvas_Mouse, Language(#ToolTip_Mouse))
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Label(#Text_Duration, #Appearance_Window_Margin, Y + 5, 100, 20, Language(#Lng_Duration))
		SetGadgetFont(#Text_Duration, General::OptionFont)
		SetGadgetColor(#Text_Duration, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		UITK::TrackBar(#Canvas_Duration, WindowWidth(#Window) - #Appearance_Window_Margin - 150, Y - 4, 150, 40, 5, 45, UITK::#Trackbar_ShowState)
		SetGadgetState(#Canvas_Duration, General::Preferences(General::#Pref_Duration) * 0.01)
		SetGadgetAttribute(#Canvas_Duration, UITK::#Trackbar_Scale, 10)
		SetGadgetText(#Canvas_Duration, "s")
		AddGadgetItem(#Canvas_Duration, 5, "")
		AddGadgetItem(#Canvas_Duration, 20, "")
		AddGadgetItem(#Canvas_Duration, 45, "")
		
		Y + #Appearance_Window_OptionSpacing
		
		UITK::Toggle(#Canvas_Combo, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Canvas_Combo))
		SetGadgetFont(#Canvas_Combo, General::OptionFont)
		SetGadgetColor(#Canvas_Combo, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(#Canvas_Combo, UITK::#Color_Text_warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		GadgetToolTip(#Canvas_Combo, Language(#ToolTip_Combo))
		
		
		Y + #Appearance_Window_OptionSpacing + 5
		
		
		UITK::Button(#Canvas_Location, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24, Language(#Lng_Location), UITK::#Border)
		
		Y + #Appearance_Window_OptionSpacing + 56
		
		UITK::Toggle(#Canvas_CheckUpdate, #Appearance_Window_Margin, Y, #Appearance_Window_ItemWidth, 24,  Language(#Canvas_CheckUpdate))
		SetGadgetFont(#Canvas_CheckUpdate, General::OptionFont)
		SetGadgetColor(#Canvas_CheckUpdate, UITK::#Color_Text_Cold, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		SetGadgetColor(#Canvas_CheckUpdate, UITK::#Color_Text_warm, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		GadgetToolTip(#Canvas_CheckUpdate, Language(#ToolTip_CheckUpdate))
		
		Y + #Appearance_Window_OptionSpacing

		
		HyperLinkGadget(#HyperLink_About, #Appearance_Window_TitleMargin + 5, Y, #Appearance_Window_Width - 2 * #Appearance_Window_TitleMargin, 15, Language(#Lng_About), General::FixColor($FF5E91), #PB_HyperLink_Underline)
		SetGadgetColor(#HyperLink_About, #PB_Gadget_BackColor, GetGadgetColor(#Canvas_Location, UITK::#Color_Back_Cold))
		
		SetGadgetColor(#HyperLink_About, #PB_Gadget_FrontColor, RGB(Red(General::ColorScheme(General::Preferences(General::#Pref_DarkMode),General::#Color_Type_FrontCold)),
		                                                            Green(General::ColorScheme(General::Preferences(General::#Pref_DarkMode),General::#Color_Type_FrontCold)),
		                                                            Blue(General::ColorScheme(General::Preferences(General::#Pref_DarkMode),General::#Color_Type_FrontCold))))
		BindGadgetEvent(#HyperLink_About, @HandlerHyperLink())
		
		
		SetColor()
		
		; Get the icon from the executable to avoid stuffing the executable with redondant data. See : https://docs.microsoft.com/en-us/previous-versions/windows/embedded/ms924847(v=msdn.10)
		Protected nIcons = ExtractIconEx_(ProgramFilename(), -1, #Null, #Null, #Null)
		Protected Dim phiconSmall(nIcons)
		ExtractIconEx_(ProgramFilename(), 0, #NUL, phiconSmall(), nIcons) 
		AddSysTrayIcon(#Systray, WindowID, phiconSmall(0))
		SysTrayIconToolTip(#Systray, General::#AppName)
		
		; Systray popup menu
		CreatePopupMenu(0)
		MenuItem(#Menu_Enabled, Language(#Lng_Menu_Enable))
		MenuItem(#Menu_Options, Language(#Lng_Menu_Options))
		MenuItem(#Menu_Quit, Language(#Lng_Menu_Quit))
		
		SetMenuItemState(0, #Menu_Enabled, #True)
		
		; Set up the popup window origin point to not interfere with the taskbar. See : https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shappbarmessage
		Protected pData.APPBARDATA
		SHAppBarMessage_(#ABM_GETTASKBARPOS, pData)
		ExamineDesktops()
		
		If pData\uEdge = #ABE_BOTTOM
			PopupWindow::SetPopupOrigin(10, DesktopHeight(0) - (pData\rc\bottom - pData\rc\top) - 10)
		ElseIf pData\uEdge = #ABE_LEFT
			PopupWindow::SetPopupOrigin(pData\rc\right + 10, DesktopHeight(0) - 10)
		EndIf
		
		; Event bindings
		BindEvent(#PB_Event_CloseWindow, @HandlerCloseWindow(), #Window)
		BindEvent(#PB_Event_SysTray,@HandlerSystray())
		BindEvent(#PB_Event_Menu, @HandlerMenuEnabled(), #Window, #Menu_Enabled) ; We can't use BindMenuEvent with FlatMenu
		BindEvent(#PB_Event_Menu, @HandlerMenuOptions(), #Window, #Menu_Options)
		BindEvent(#PB_Event_Menu, @HandlerMenuQuit(), #Window, #Menu_Quit)
		BindEvent(General::#Event_Update, @HandlerUpdate())
		
		OpenWindow(#Window_SingleInstance, 0, 0, 10, 0, "60e272b1-eb20-4caa-9354-2142e2be78a0", #PB_Window_Invisible)
		SetWindowCallback(@WindowCallback(), #Window_SingleInstance)
		
		KeyboardHook = SetWindowsHookEx_(#WH_KEYBOARD_LL, @KeyboardHook(), GetModuleHandle_(0), 0)
		If General::Preferences(General::#Pref_Mouse)
			MouseHook = SetWindowsHookEx_(#WH_MOUSE_LL, @MouseHook(), GetModuleHandle_(0), 0)
		EndIf
		
		If General::FirstStart
			SystrayBalloon(General::#AppName, Language(#Lng_FirstStart), #NIIF_USER|#NIIF_INFO )
		EndIf
		
		; Create the location selector window (it works but it's very hacky, there has to be a proper solution): 
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
		Box(0, 30, 101, 20, General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_FrontDisabled))
		Box(1, 31, 99, 18, General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold))
		StopDrawing()
		
		LocationText = TextGadget(#PB_Any, 1, 31, 99, 18, "x: y:", #PB_Text_Center)
		SetGadgetColor(LocationText, #PB_Gadget_BackColor, General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_BackCold))
		SetGadgetColor(LocationText, #PB_Gadget_FrontColor, General::ColorScheme(General::#Color_Mode_Dark, General::#Color_Type_FrontHot))
		
		CloseGadgetList()
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
				MouseHook = 0
				UnhookWindowsHookEx_(MouseHook)
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
			
			PreferenceGroup("Misc")
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
			DisplayPopupMenu(0, WindowID(#Window))
		ElseIf EventType() = #PB_EventType_LeftDoubleClick
			HandlerMenuOptions()
		EndIf
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
					InputArray(#VK_LBUTTON) = PopupWindow::Create(#VK_LBUTTON)
				Case #WM_RBUTTONDOWN
					InputArray(#VK_RBUTTON) = PopupWindow::Create(#VK_RBUTTON)
				Case #WM_MBUTTONDOWN
					InputArray(#VK_MBUTTON) = PopupWindow::Create(#VK_MBUTTON)
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
	
	Procedure SetColor()
; 		SetWindowColor(#Window, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		
; 		SetGadgetColor(#Text_UserInterface, #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(#Text_UserInterface, #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
; 		SetGadgetColor(#Text_Behavior, #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(#Text_Behavior, #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
; 		SetGadgetColor(#Text_Misc, #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(#Text_Misc, #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
; 		
; 		SetGadgetColor(GetGadgetData(#Canvas_DarkMode), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(GetGadgetData(#Canvas_DarkMode), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
; 		RedrawToggle(#Canvas_DarkMode)
; 		SetGadgetColor(GetGadgetData(#Canvas_Scale), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(GetGadgetData(#Canvas_Scale), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
; 		RedrawTrackbar(#Canvas_Scale)
; 		SetGadgetColor(GetGadgetData(#Canvas_Mouse), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(GetGadgetData(#Canvas_Mouse), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
; 		RedrawToggle(#Canvas_Mouse)
; 		SetGadgetColor(GetGadgetData(#Canvas_Duration), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(GetGadgetData(#Canvas_Duration), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
; 		RedrawTrackbar(#Canvas_Duration)
; 		SetGadgetColor(GetGadgetData(#Canvas_Location), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(GetGadgetData(#Canvas_Location), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
; 		RedrawButton(#Canvas_Location)
; 		SetGadgetColor(GetGadgetData(#Canvas_Combo), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(GetGadgetData(#Canvas_Combo), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
; 		RedrawToggle(#Canvas_Combo)
; 		SetGadgetColor(GetGadgetData(#Canvas_CheckUpdate), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(GetGadgetData(#Canvas_CheckUpdate), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
; 		RedrawToggle(#Canvas_CheckUpdate)
; 		
; 		SetGadgetColor(#HyperLink_About, #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
; 		SetGadgetColor(#HyperLink_About, #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
	EndProcedure
	
	Procedure WindowCallback(hWnd, Msg, wParam, lParam)
		If Msg = #WM_INSTANCESTART
			HandlerMenuOptions()
		EndIf
		
		ProcedureReturn #PB_ProcessPureBasicEvents
	EndProcedure
	;}
	
	DataSection ;{ Languages
		English:
		Data.s "Dark mode"
		Data.s "Scale"
		Data.s "Track Mouse"
		Data.s "Window duration"
		Data.s "Combo regroupment"
		Data.s "Move popup origin"
		Data.s "Auto-update"
		Data.s "Visit ❤x1's website"
		
		Data.s "Switch between the dark and light theme"
		Data.s "Changes the size of the input popup"
		Data.s "Include mouse click in the tracked inputs"
		Data.s "Change the time spent on screen"
		Data.s "Regroup identical inputs as a group"
		Data.s ""
		Data.s "Check update at startup"
		
		Data.s "APPEARANCE"
		Data.s "BEHAVIOR"
		Data.s "MISC"
		
		Data.s "Track inputs"
		Data.s "Preferences"
		Data.s "Quit"
		
		Data.s "Inputify has started, you can find it in your system tray icons!"
		
		French:
		Data.s "Mode sombre"
		Data.s "Taille"
		Data.s "Souris"
		Data.s "Durée d'affichage"
		Data.s "Regrouper les séries"
		Data.s "Déplacer le point d'apparition"
		Data.s "Surveiller les MàJ"
		Data.s "Aller sur le site de ❤x1"
		
		Data.s "Alterne entre les modes sombre et clair"
		Data.s "Modifie la taille des inputs à l'écran"
		Data.s "Ajoute la souris aux inputs"
		Data.s "Change la durée d'affichage d'un input"
		Data.s "Regroupe les séries d'inputs"
		Data.s ""
		Data.s "Au démarrage, vérifie si une nouvelle version est disponible"
		
		Data.s "APPARENCE"
		Data.s "COMPORTEMENT"
		Data.s "DIVERS"
		
		Data.s "Afficher les inputs"
		Data.s "Préférences"
		Data.s "Quitter"
		
		Data.s "Inputify a correctement démarré, vous pouvez le retrouver dans les icônes de la barre d'état !"
		
		Icon:
		IncludeBinary "../Media/Icon/18.png"
	EndDataSection ;}
	
EndModule
; IDE Options = PureBasic 6.00 Beta 9 (Windows - x64)
; CursorPosition = 128
; FirstLine = 15
; Folding = 6DAQ-
; EnableXP