Module MainWindow
	EnableExplicit
	; Private variables, structures and constants
	#Window = 0
	#Systray = 0
	
	Global Dim InputArray.i(256)				; Used to discriminate between an actual input and a repeat.
	
	; Private procedures declaration
	Import "User32.lib"
		GetRawInputData(hRawInput, uiCommand, *pData.RAWINPUT, *pcbSize, cbSizeHeader)
		RegisterRawInputDevices(*pRawInputDevices.RAWINPUTDEVICE, *uiNumDevices, cbSize)
	EndImport
	
	Declare Callback(hWnd, Message, WParam, LParam)
	
	
	;{ Public procedures
	Procedure Open()
		
		WindowID = OpenWindow(#Window, 0, 0, 100, 100, "Inputify", #PB_Window_Invisible)
		
		; Set up a hook for keyboard input
		Protected Dim Rid.RAWINPUTDEVICE(0)
		Rid(0)\usUsagePage  = 1
		Rid(0)\usUsage      = 0
		Rid(0)\hwndTarget   = WindowID(#Window)
		Rid(0)\dwFlags   	= #RIDEV_INPUTSINK | #RIDEV_PAGEONLY
		SetWindowCallback(@Callback(), #Window)
		RegisterRawInputDevices (@Rid(), ArraySize(Rid()) + 1, SizeOf(RAWINPUTDEVICE))
		
  		; Get the icon from the executable to avoid stuffing the executable with redondant data. See : https://docs.microsoft.com/en-us/previous-versions/windows/embedded/ms924847(v=msdn.10)
  		Protected nIcons = ExtractIconEx_(ProgramFilename(), -1, #Null, #Null, #Null)
  		Protected Dim phiconSmall(nIcons)
  		ExtractIconEx_(ProgramFilename(), 0, #NUL, phiconSmall(), nIcons) 
  		AddSysTrayIcon(#Systray, WindowID(#Window), phiconSmall(0))
  		
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure Callback(hWnd, Message, WParam, LParam)
		If Message = #WM_INPUT
			Protected pcbSize.l, pRawData.RAWINPUT
			If GetRawInputData(lParam, #RID_INPUT, #Null, @pcbSize, SizeOf(RAWINPUTHEADER)) = 0
				GetRawInputData(lParam, #RID_INPUT, @pRawData, @pcbSize, SizeOf(RAWINPUTHEADER))
				If pRawData\header\dwType = #RIM_TYPEKEYBOARD
					
					If pRawData\keyboard\Flags
						If InputArray(pRawData\keyboard\VKey)
							; An input has been released, start the windows disparition timer
							PopupWindow::Hide(InputArray(pRawData\keyboard\VKey))
							InputArray(pRawData\keyboard\VKey) = #False
						EndIf
					Else
						If Not InputArray(pRawData\keyboard\VKey)
							; This is a new input, create a new window
							InputArray(pRawData\keyboard\VKey) = PopupWindow::Create(pRawData\keyboard\VKey)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure
	;}
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 47
; Folding = -
; EnableXP