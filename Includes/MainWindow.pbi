Module MainWindow
	EnableExplicit
	; Private variables, structures and constants
	#Window = 0
	#Systray = 0
	#WH_KEYBOARD_LL = 13
	
	Global Dim InputArray.i(256)				; Used for key combo.
	
	; Private procedures declaration
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
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure Hook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
		If nCode = #HC_ACTION
			
			If wParam = #WM_KEYDOWN
				If Not InputArray(*p\vkCode)
					; This is a new input, create a new window
					InputArray(*p\vkCode) = PopupWindow::Create(*p\vkCode)
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
	;}
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 14
; Folding = -
; EnableXP