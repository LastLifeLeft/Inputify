Module MainWindow
	EnableExplicit
	; Private variables, structures and constants
	Enumeration ;Menu ID
		#Menu_Enabled
		#Menu_Options
		#Menu_Quit
	EndEnumeration
	
	#Window = 0
	#Systray = 0
	#WH_KEYBOARD_LL = 13
	#WM_INSTANCESTART = 111
	
	Global Dim InputArray.i(256)				; Used for key combo.
	Global PopupMenu
	Global Enabled = #True						;
	
	; Private procedures declaration
	Declare HandlerMenuEnabled()
	Declare HandlerMenuOption()
	Declare HandlerMenuQuit()
	Declare HandlerSystray()
	Declare Hook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare WindowCallback(hWnd, Msg, wParam, lParam)
	
	;{ Public procedures
	Procedure Open()
		
		; Check if another instance is already running signal it
		Protected InstanceWindow = FindWindow_(#Null, General::#AppName + " v" + General:: #Version)
		If InstanceWindow
			SendMessage_(InstanceWindow, #WM_INSTANCESTART, 0, 0)
			HandlerMenuQuit() 
		EndIf
		
		WindowID = OpenWindow(#Window, 0, 0, 100, 100, General::#AppName + " v" + General:: #Version, #PB_Window_Invisible | #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		
		If WindowID
			; Window settings
			StickyWindow(#Window, #True)
			
	  		; Get the icon from the executable to avoid stuffing the executable with redondant data. See : https://docs.microsoft.com/en-us/previous-versions/windows/embedded/ms924847(v=msdn.10)
	  		Protected nIcons = ExtractIconEx_(ProgramFilename(), -1, #Null, #Null, #Null)
	  		Protected Dim phiconSmall(nIcons)
	  		ExtractIconEx_(ProgramFilename(), 0, #NUL, phiconSmall(), nIcons) 
	  		AddSysTrayIcon(#Systray, WindowID, phiconSmall(0))
	  		SysTrayIconToolTip(#Systray, General::#AppName)
	  		
	  		; Systray popup menu
	  		PopupMenu = FlatMenu::Create(#Window, FlatMenu::#DarkTheme)
	  		FlatMenu::AddItem(PopupMenu, #Menu_Enabled, -1, "Enable", FlatMenu::#Toggle)
	  		FlatMenu::AddItem(PopupMenu, #Menu_Options, -1, "Options")
	  		FlatMenu::AddItem(PopupMenu, #Menu_Quit, -1, "Quit")
	  		
	  		FlatMenu::SetItemState(PopupMenu, #Menu_Enabled, #True)
	  		
	  		; Set up the popup window origin point to not interfere with the taskbar. See : https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shappbarmessage
			;TODO : Implement support of multiple screen? I only own one, so I can't do it myself.
	  		Protected pData.APPBARDATA
	  		SHAppBarMessage_(#ABM_GETTASKBARPOS, pData)
	  		ExamineDesktops()
	  		
	  		If pData\uEdge = #ABE_BOTTOM
	  			PopupWindow::SetPopupOrigin(0, DesktopHeight(0) - (pData\rc\bottom - pData\rc\top))
	  		ElseIf pData\uEdge = #ABE_LEFT
	  			PopupWindow::SetPopupOrigin(pData\rc\right, DesktopHeight(0))
	  		EndIf
	  		
	  		; Event bindings
	  		BindEvent(#PB_Event_SysTray,@HandlerSystray())
	  		BindEvent(#PB_Event_Menu, @HandlerMenuEnabled(), #Window, #Menu_Enabled) ; We can't use BindMenuEvent with FlatMenu
	  		BindEvent(#PB_Event_Menu, @HandlerMenuOption(), #Window, #Menu_Options)
	  		BindEvent(#PB_Event_Menu, @HandlerMenuQuit(), #Window, #Menu_Quit)
	  		SetWindowCallback(@WindowCallback(), #Window)
	  		SetWindowsHookEx_(#WH_KEYBOARD_LL,@Hook(),GetModuleHandle_(0),0)
	  	Else
	  		HandlerMenuQuit() 
	  	EndIf
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure HandlerMenuEnabled()
		Enabled = EventData()
	EndProcedure
	
	Procedure HandlerMenuOption()
		HideWindow(#Window, #False)
		SetActiveWindow(#Window)
	EndProcedure
	
	Procedure HandlerMenuQuit() 
		CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm And #PB_Compiler_OS = #PB_OS_Windows
			ImagePlugin::ModuleImagePluginStop()
		CompilerEndIf
		If IsSysTrayIcon(#Systray)
			RemoveSysTrayIcon(#Systray)
		EndIf
		End
	EndProcedure
	
	Procedure HandlerSystray()
		If EventType() = #PB_EventType_RightClick
			FlatMenu::Show(PopupMenu)
		EndIf
	EndProcedure
	
	Procedure Hook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
		If nCode = #HC_ACTION
			
			If wParam = #WM_KEYDOWN
				If Enabled
					If Not InputArray(*p\vkCode)
						; This is a new input, create a new window
						InputArray(*p\vkCode) = PopupWindow::Create(*p\vkCode)
					EndIf
				EndIf
			Else
				If InputArray(*p\vkCode)
					; An input has been released, start the windows disparition timer
					PopupWindow::Hide(InputArray(*p\vkCode))
					InputArray(*p\vkCode) = #False
				EndIf
			EndIf
		EndIf
		ProcedureReturn #False
	EndProcedure
	
	Procedure WindowCallback(hWnd, Msg, wParam, lParam)
		If Msg = #WM_INSTANCESTART
			HandlerMenuOption()
		EndIf
		
		ProcedureReturn #PB_ProcessPureBasicEvents
	EndProcedure
	;}
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 48
; Folding = Lg
; EnableXP