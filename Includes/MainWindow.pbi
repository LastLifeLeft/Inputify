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
	#Appearance_Window_Height = 555
	#Appearance_Window_Margin = 50
	#Appearance_Window_OptionSpacing = 40
	
	#Appearance_Option_Width = #Appearance_Window_Width - 2 *#Appearance_Window_Margin
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
	Declare CreateToggleButton(x, y, ID)
	Declare CreateTracbar(x, y, ID)
	Declare CreateButton(x, y, ID)
	Declare HandlerCloseWindow()
	Declare HandlerMenuEnabled()
	Declare HandlerMenuOptions()
	Declare HandlerMenuQuit()
	Declare HandlerSystray()
	Declare HandlerToggle()
	Declare HandlerTrackbar()
	Declare HandlerUpdate()
	Declare HandlerHyperLink()
	Declare HandlerButton()
	Declare KeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare MouseHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare LocationMouseHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare LocationKeyboardHook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare RedrawToggle(ID)
	Declare RedrawTrackbar(ID)
	Declare RedrawButton(ID)
	Declare SetColor()
	Declare WindowCallback(hWnd, Msg, wParam, lParam)
	Declare VectorCheck(x.d, y.d, Size.d)
	Declare VectorPlus(x.d, y.d, Size.d)
	
	;{ Public procedures
	Procedure Open()
		; Check if another instance is already running signal it
		Protected InstanceWindow = FindWindow_(#Null, "60e272b1-eb20-4caa-9354-2142e2be78a0")
		If InstanceWindow
			SendMessage_(InstanceWindow, #WM_INSTANCESTART, 0, 0)
			HandlerMenuQuit() 
		EndIf
		
		WindowID = OpenWindow(#Window, 0, 0, #Appearance_Window_Width, #Appearance_Window_Height, General::#AppName, #PB_Window_Invisible | #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		
		If WindowID
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
			
			; Window
			StickyWindow(#Window, #True)
			SetGadgetFont(#PB_Default, General::TitleFont)
			
			TextGadget(#Text_UserInterface, #Appearance_Window_Margin, 50, 200, 20, Language(#Lng_UserInterface))
			TextGadget(#Text_Behavior, #Appearance_Window_Margin, 190, 200, 20, Language(#Lng_Behavior))
			TextGadget(#Text_Misc, #Appearance_Window_Margin, 410, 200, 20, Language(#Lng_Misc))
			
			SetGadgetFont(#PB_Default, General::OptionFont)
			
			Y = CreateToggleButton(#Appearance_Window_Margin, Y, #Canvas_DarkMode)
			Y = CreateTracbar(#Appearance_Window_Margin, Y, #Canvas_Scale)
			Y + 60
			Y = CreateToggleButton(#Appearance_Window_Margin, Y, #Canvas_Mouse)
			Y = CreateTracbar(#Appearance_Window_Margin, Y, #Canvas_Duration)
			Y = CreateToggleButton(#Appearance_Window_Margin, Y, #Canvas_Combo)
			Y = CreateButton(#Appearance_Window_Margin, Y + 5, #Canvas_Location)
			Y + 60
			Y = CreateToggleButton(#Appearance_Window_Margin, Y, #Canvas_CheckUpdate)
			Y = HyperLinkGadget(#HyperLink_About, #Appearance_Window_Margin + 5, Y, #Appearance_Window_Width - 2 * #Appearance_Window_Margin, 15, Language(#Lng_About), General::FixColor($FF5E91), #PB_HyperLink_Underline)
			
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
	  	Else
	  		HandlerMenuQuit() 
	  	EndIf
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
	
	Procedure CreateToggleButton(x, y, ID)
		Protected TextID
		CanvasGadget(ID, x, y, #Appearance_Option_Width, 24, #PB_Canvas_Container)
		GadgetToolTip(ID, Language(ID + #ToolTip_DarkMode))
		TextID = TextGadget(#PB_Any, 5, 4, 150, 16, Language(ID))
		SetGadgetData(ID, TextID)
		ResizeGadget(TextID, #PB_Ignore, #PB_Ignore, GadgetWidth(TextID, #PB_Gadget_RequiredSize), #PB_Ignore)
		CloseGadgetList()
		SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		
		BindEvent(#PB_Event_Gadget, @HandlerToggle(), #Window, ID)
		ProcedureReturn y + #Appearance_Window_OptionSpacing
	EndProcedure
	
	Procedure CreateTracbar(x, y, ID)
		Protected TextID
		CanvasGadget(ID, x, y, #Appearance_Option_Width, 24, #PB_Canvas_Container)
		GadgetToolTip(ID, Language(ID + #ToolTip_DarkMode))
		TextID = TextGadget(#PB_Any, 5, 4, 110, 16, Language(ID))
		SetGadgetData(ID, TextID)
		ResizeGadget(TextID, #PB_Ignore, #PB_Ignore, GadgetWidth(TextID, #PB_Gadget_RequiredSize), #PB_Ignore)
		CloseGadgetList()
		
		BindEvent(#PB_Event_Gadget, @HandlerTrackbar(), #Window, ID)
		ProcedureReturn y + #Appearance_Window_OptionSpacing
	EndProcedure
	
	Procedure CreateButton(x, y, ID)
		CanvasGadget(ID, x + 10, y, #Appearance_Option_Width - 2, 24, #PB_Canvas_Container)
		GadgetToolTip(ID, Language(ID + #ToolTip_DarkMode))
		SetGadgetData(ID, TextGadget(#PB_Any, 1, 4, #Appearance_Option_Width - 22, 16, Language(ID), #PB_Text_Center))
		CloseGadgetList()
		SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		
		BindEvent(#PB_Event_Gadget, @HandlerButton(), #Window, ID)
		ProcedureReturn y + #Appearance_Window_OptionSpacing
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
	
	Procedure HandlerToggle()
		Protected ID = EventGadget()
		
		If EventType() = #PB_EventType_LeftClick
			
			General::Preferences(ID) = Bool(Not General::Preferences(ID))
			
			Select ID
				Case #Canvas_DarkMode
					SetColor()
				Case #Canvas_Mouse
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
					RedrawToggle(ID)
				Default
					RedrawToggle(ID)
			EndSelect
			
		EndIf
	EndProcedure
	
	Procedure HandlerTrackbar()
		Protected ID = EventGadget(), Maximum, Minimum, Position, MouseX = GetGadgetAttribute(ID, #PB_Canvas_MouseX), MouseY = GetGadgetAttribute(ID, #PB_Canvas_MouseY)
		
		If ID = #Canvas_Duration
			Maximum = 4500 
			Minimum = 500
		Else
			Maximum = 350
			Minimum = 50
		EndIf
		
		Position = (General::Preferences(ID) - Minimum) * 100 / Maximum
		
		Select EventType()
			Case #PB_EventType_MouseMove
				If MouseOffset = - 1000
					If MouseX >= (#Appearance_Option_Width - 109) + Position - 5 And MouseX <= (#Appearance_Option_Width - 109) + Position + 4
						SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
					ElseIf MouseX >= (#Appearance_Option_Width - 109) And MouseY >= 10 And MouseY <= 18
						SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_Hand)
					Else
						SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_Default)
					EndIf
				Else
					Position = MouseX - (#Appearance_Option_Width - 109) - MouseOffset
					If Position > 100
						Position = 100
					ElseIf Position < 0
						Position = 0
					EndIf
					
					General::Preferences(ID) = Minimum + (Position * Maximum) / 100
					
					If ID = #Canvas_Scale
						PopupWindow::SetScale(General::Preferences(ID))
					EndIf
					
					RedrawTrackbar(ID)
				EndIf
			Case #PB_EventType_LeftButtonDown
				If MouseX >= (#Appearance_Option_Width - 109) + Position - 5 And MouseX <= (#Appearance_Option_Width - 109) + Position + 4
					MouseOffset = (MouseX - (#Appearance_Option_Width - 109)) - Position
					SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
				ElseIf MouseX >= (#Appearance_Option_Width - 109) And MouseY >= 10 And MouseY <= 18
					Position = MouseX - (#Appearance_Option_Width - 109)
					MouseOffset = 0
					General::Preferences(ID) = Minimum + (Position * Maximum) / 100
					RedrawTrackbar(ID)
					SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
					
					If ID = #Canvas_Scale
						PopupWindow::SetScale(General::Preferences(ID))
					EndIf
				EndIf
			Case #PB_EventType_LeftButtonUp
				MouseOffset = - 1000
				SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_Default)
			Default
				If MouseOffset = - 1000
					SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_Default)
				EndIf
		EndSelect
	EndProcedure
	
	Procedure HandlerButton()
		Protected Loop, DesktopCount
		If EventType() = #PB_EventType_LeftClick
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
	
	Procedure RedrawToggle(ID)
		StartVectorDrawing(CanvasVectorOutput(ID))
		AddPathBox(0, 0, VectorOutputWidth(), VectorOutputHeight())
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold)))
		FillPath()
		
		; Back
		AddPathCircle(#Appearance_Option_Width - 45 + 12, 12, 12)
		AddPathCircle(#Appearance_Option_Width - 45 + 40 - 12, 12, 12)
		AddPathBox(#Appearance_Option_Width - 45 + 12, 0, 16, 24)
		
		VectorSourceColor(General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_ToggleOff + General::Preferences(ID)))
		FillPath(#PB_Path_Winding)
		
		; Front
		AddPathCircle(#Appearance_Option_Width - 45 + 12  + General::Preferences(ID) * 15, 12, 9)
		If General::Preferences(ID)
			VectorCheck(#Appearance_Option_Width - 45 + 6  + General::Preferences(ID) * 15, 13, 11)
		Else
			VectorPlus(#Appearance_Option_Width - 45 + 12 + General::Preferences(ID) * 15, 2, 14)
		EndIf
		VectorSourceColor(General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_ToggleFront))
		FillPath()
		
		StopVectorDrawing()
	EndProcedure
	
	Procedure RedrawTrackbar(ID)
		Protected Maximum, Minimum, Position
		
		If ID = #Canvas_Duration
			Maximum = 4500 
			Minimum = 500
		Else
			Maximum = 350
			Minimum = 50
		EndIf
		
		Position = (General::Preferences(ID) - Minimum) * 100 / Maximum
		
		StartVectorDrawing(CanvasVectorOutput(ID))
		AddPathBox(0, 0, VectorOutputWidth(), VectorOutputHeight())
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold)))
		FillPath()
		
		; Attempt at displaying an help icon
; 		VectorFont(General::OptionFont, 12)
; 		AddPathCircle(GadgetWidth(GetGadgetData(id), #PB_Gadget_RequiredSize) + 17, 11, 7)
; 		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold)))
; 		FillPath()
; 		MovePathCursor(GadgetWidth(GetGadgetData(id), #PB_Gadget_RequiredSize) + 14, 5)
; 		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold)))
; 		DrawVectorText("?")
		
		MovePathCursor(#Appearance_Option_Width - 109, 5)
		AddPathLine(0, 18, #PB_Path_Relative)
		
		MovePathCursor(#Appearance_Option_Width - 9, 5)
		AddPathLine(0, 18, #PB_Path_Relative)
		
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontDisabled)))
		StrokePath(2)
		
		AddPathBox(#Appearance_Option_Width - 109 + Position, 10, 100 - Position, 8)
		AddPathCircle(#Appearance_Option_Width - 9, 14, 4)
		FillPath(#PB_Path_Winding)
		
		AddPathCircle(#Appearance_Option_Width - 109, 14, 4)
		AddPathBox(#Appearance_Option_Width - 109, 10, Position, 8)
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_Trackbar)))
		FillPath(#PB_Path_Winding)
		
		AddPathRoundedBox(#Appearance_Option_Width - 109 + Position - 5, 3, 9, 20, 3)
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontDisabled)))
		StrokePath(2, #PB_Path_Preserve)
		VectorSourceColor($FFFFFFFF)
		FillPath()
		
		StopVectorDrawing()
	EndProcedure
	
	Procedure RedrawButton(ID)
		StartVectorDrawing(CanvasVectorOutput(ID))
		AddPathBox(0, 0, VectorOutputWidth(), VectorOutputHeight())
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold)))
		FillPath(#PB_Path_Preserve)
		
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontDisabled)))
		StrokePath(2)
		
		StopVectorDrawing()
	EndProcedure
	
	Procedure SetColor()
		SetWindowColor(#Window, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		
		SetGadgetColor(#Text_UserInterface, #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(#Text_UserInterface, #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
		SetGadgetColor(#Text_Behavior, #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(#Text_Behavior, #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
		SetGadgetColor(#Text_Misc, #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(#Text_Misc, #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontHot))
		
		SetGadgetColor(GetGadgetData(#Canvas_DarkMode), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(GetGadgetData(#Canvas_DarkMode), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		RedrawToggle(#Canvas_DarkMode)
		SetGadgetColor(GetGadgetData(#Canvas_Scale), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(GetGadgetData(#Canvas_Scale), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		RedrawTrackbar(#Canvas_Scale)
		SetGadgetColor(GetGadgetData(#Canvas_Mouse), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(GetGadgetData(#Canvas_Mouse), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		RedrawToggle(#Canvas_Mouse)
		SetGadgetColor(GetGadgetData(#Canvas_Duration), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(GetGadgetData(#Canvas_Duration), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		RedrawTrackbar(#Canvas_Duration)
		SetGadgetColor(GetGadgetData(#Canvas_Location), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(GetGadgetData(#Canvas_Location), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		RedrawButton(#Canvas_Location)
		SetGadgetColor(GetGadgetData(#Canvas_Combo), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(GetGadgetData(#Canvas_Combo), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		RedrawToggle(#Canvas_Combo)
		SetGadgetColor(GetGadgetData(#Canvas_CheckUpdate), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(GetGadgetData(#Canvas_CheckUpdate), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		RedrawToggle(#Canvas_CheckUpdate)
		
		SetGadgetColor(#HyperLink_About, #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(#HyperLink_About, #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
	EndProcedure
	
	Procedure VectorCheck(x.d, y.d, Size.d)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Up),  Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		RotateCoordinates(0, 0, - 45)
		
		AddPathLine(0, Half, #PB_Path_Relative)
		AddPathLine(Size, 0, #PB_Path_Relative)
		AddPathLine(0, - PathWidth, #PB_Path_Relative)
		AddPathLine(-Size + PathWidth, 0, #PB_Path_Relative)
		AddPathLine(0, - Half + PathWidth, #PB_Path_Relative)
		ClosePath()
		
	EndProcedure
	
	Procedure VectorPlus(x.d, y.d, Size.d)
		Protected PathWidth.i = Round(Size * 0.1, #PB_Round_Nearest),  Half.i = Size * 0.5
		
		MovePathCursor(x, y)
		RotateCoordinates(0, 0, 45)
		
		MovePathCursor(Half - PathWidth, PathWidth, #PB_Path_Relative)
		AddPathLine(0, Half - PathWidth * 2, #PB_Path_Relative)
		AddPathLine(PathWidth * 2 - Half, 0, #PB_Path_Relative)
		AddPathLine(0, PathWidth * 2, #PB_Path_Relative)
		AddPathLine(Half - PathWidth * 2, 0, #PB_Path_Relative)
		AddPathLine(0, Half - PathWidth * 2, #PB_Path_Relative)
		AddPathLine(PathWidth * 2,0, #PB_Path_Relative)
		AddPathLine(0, PathWidth * 2 - Half , #PB_Path_Relative)
		AddPathLine(Half - PathWidth * 2, 0, #PB_Path_Relative)
		AddPathLine(0, - PathWidth * 2, #PB_Path_Relative)
		AddPathLine(PathWidth * 2 - Half, 0, #PB_Path_Relative)
		AddPathLine(0, PathWidth * 2 - Half, #PB_Path_Relative)
		ClosePath()
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
	EndDataSection ;}
	
EndModule
; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 547
; FirstLine = 68
; Folding = xDAAAA-
; EnableXP