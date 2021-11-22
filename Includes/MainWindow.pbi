Module MainWindow
	EnableExplicit
	; Private variables, structures and constants
	Enumeration ;Menu ID
		#Menu_Enabled
		#Menu_Option
		#Menu_Quit
	EndEnumeration
	
	#Window = 0
 	#EmptyMenu = 0								;a dirty workarround to use BindMenuEvent with FlatMenu
	#Systray = 0
	#WH_KEYBOARD_LL = 13
	
	Global Dim InputArray.i(256)				; Used for key combo.
	Global PopupMenu
	Global Enabled = #True						;
	
	; Private procedures declaration
	Declare HandlerMenuEnabled()
	Declare HandlerMenuOption()
	Declare HandlerMenuQuit()
	Declare HandlerSystray()
	Declare Hook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	
	;{ Public procedures
	Procedure Open()
		WindowID = OpenWindow(#Window, 0, 0, 100, 100, General::#AppName, #PB_Window_Invisible)
		
		; Set up a hook for keyboard input
		SetWindowsHookEx_(#WH_KEYBOARD_LL,@Hook(),GetModuleHandle_(0),0)
		ExamineDesktops()
		
  		; Get the icon from the executable to avoid stuffing the executable with redondant data. See : https://docs.microsoft.com/en-us/previous-versions/windows/embedded/ms924847(v=msdn.10)
  		Protected nIcons = ExtractIconEx_(ProgramFilename(), -1, #Null, #Null, #Null)
  		Protected Dim phiconSmall(nIcons)
  		ExtractIconEx_(ProgramFilename(), 0, #NUL, phiconSmall(), nIcons) 
  		AddSysTrayIcon(#Systray, WindowID(#Window), phiconSmall(0))
  		SysTrayIconToolTip(#Systray, General::#AppName)
  		
  		; Systray popup menu
  		PopupMenu = FlatMenu::Create(#Window, FlatMenu::#DarkTheme)
  		FlatMenu::AddItem(PopupMenu, #Menu_Enabled, -1, "Enable", FlatMenu::#Toggle)
  		FlatMenu::AddItem(PopupMenu, #Menu_Option, -1, "Option")
  		FlatMenu::AddItem(PopupMenu, #Menu_Quit, -1, "Quit")
  		
  		FlatMenu::SetItemState(PopupMenu, #Menu_Enabled, #True)
  		
  		; Set up the popup window origin point to not interfere with the taskbar. See : https://docs.microsoft.com/en-us/windows/win32/api/shellapi/nf-shellapi-shappbarmessage
		;TODO : Implement support of multiple screen
  		Protected pData.APPBARDATA
  		SHAppBarMessage_(#ABM_GETTASKBARPOS, pData)
  		ExamineDesktops()
  		
  		If pData\uEdge = #ABE_BOTTOM
  			PopupWindow::SetPopupOrigin(0, DesktopHeight(0) - (pData\rc\bottom - pData\rc\top))
  		ElseIf pData\uEdge = #ABE_LEFT
  			PopupWindow::SetPopupOrigin(pData\rc\right, DesktopHeight(0))
  		EndIf
  		
  		; Event bindings
  		CreatePopupMenu(#EmptyMenu)
  		BindEvent(#PB_Event_SysTray,@HandlerSystray())
  		BindMenuEvent(#EmptyMenu, #Menu_Enabled, @HandlerMenuEnabled())
  		BindMenuEvent(#EmptyMenu, #Menu_Option, @HandlerMenuOption())
  		BindMenuEvent(#EmptyMenu, #Menu_Quit, @HandlerMenuQuit())
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure HandlerMenuEnabled()
		Debug EventData()
		Enabled = EventData()
	EndProcedure
	
	Procedure HandlerMenuOption()
	EndProcedure
	
	Procedure HandlerMenuQuit() 
		CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm And #PB_Compiler_OS = #PB_OS_Windows
			ImagePlugin::ModuleImagePluginStop()
		CompilerEndIf
		RemoveSysTrayIcon(#Systray)
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
				If Not InputArray(*p\vkCode)
					; This is a new input, create a new window
					InputArray(*p\vkCode) = PopupWindow::Create(*p\vkCode)
				EndIf
			Else
				If Enabled
					If InputArray(*p\vkCode)
						; An input has been released, start the windows disparition timer
						PopupWindow::Hide(InputArray(*p\vkCode))
						InputArray(*p\vkCode) = #False
					EndIf
				EndIf
			EndIf
		EndIf
		ProcedureReturn #False
	EndProcedure
	
	
	;}
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 72
; FirstLine = 36
; Folding = --
; EnableXP