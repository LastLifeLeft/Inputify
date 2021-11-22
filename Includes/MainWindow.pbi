Module MainWindow
	EnableExplicit
	; Private variables
	#Window = 0
	#SystrayIcon = 0
	
	; Private procedures declaration
	Import "User32.lib"
		GetRawInputData(hRawInput, uiCommand, *pData.RAWINPUT, *pcbSize, cbSizeHeader)
		RegisterRawInputDevices(*pRawInputDevices.RAWINPUTDEVICE, *uiNumDevices, cbSize)
	EndImport
	
	Declare Callback(hWnd, Message, WParam, LParam)
	
	
	;{ Public procedures
	Procedure Open()
		
		OpenWindow(#Window, 0, 0, 100, 100, "Inputify", #PB_Window_Invisible)
		
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
  		AddSysTrayIcon(#SystrayIcon, WindowID(#Window), phiconSmall(0))
  		
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
						Debug "VKey " + pRawData\keyboard\VKey + " released"
					Else
						Debug "VKey " + pRawData\keyboard\VKey + " pressed"
					EndIf
				EndIf
			EndIf
		EndIf
	ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure
	;}
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 48
; Folding = -
; EnableXP