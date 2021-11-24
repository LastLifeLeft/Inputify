﻿Module MainWindow
	EnableExplicit
	; Private variables, structures and constants
	;{ Language
	Enumeration 
		#Lng_DarkMode
		#Lng_Scale
		#Lng_Mouse
		#Lng_Duration
		#Lng_Combo
		#Lng_CheckUpdate
		#Lng_About
		
		#ToolTip_DarkMode
		#ToolTip_Scale
		#ToolTip_Mouse
		#ToolTip_Duration
		#ToolTip_Combo
		#ToolTip_CheckUpdate
		#ToolTip_About
		
		#Lng_UserInterface
		#Lng_Behavior
		#Lng_Misc               
		
		#_Lng_Count
	EndEnumeration
	
	Global Dim Language.s(#_Lng_Count)
	Language(#Lng_DarkMode)			= "Dark mode:"
	Language(#Lng_Scale)			= "Scale:"
	Language(#Lng_Mouse)			= "Track Mouse:"
	Language(#Lng_Duration)			= "Block duration:"
	Language(#Lng_Combo)			= "Combo regroupment:"
	Language(#Lng_CheckUpdate)		= "Auto-update"
	Language(#Lng_About)			= "Visit ❤x1's website"
	
	Language(#ToolTip_DarkMode)			= "Switch between the dark and ligh theme."
	Language(#ToolTip_Scale)			= "Changes the size of the input popup"
	Language(#ToolTip_Mouse)			= "Include mouse click in the tracked inputs"
	Language(#ToolTip_Duration)			= "Change the time an input popup stay on screen"
	Language(#ToolTip_Combo)			= "Regroup identical input as a group"
	Language(#ToolTip_CheckUpdate)		= "Check update at startup."
	Language(#ToolTip_About)			= ""
	
	Language(#Lng_UserInterface)	= "APPEARANCE"
	Language(#Lng_Behavior)			= "BEHAVIOR"
	Language(#Lng_Misc)				= "MISC"
	;}
	
	;{ Windows and gadgets
	#Window = 0
	
	Enumeration ;Gadget
		#Canvas_DarkMode
		#Canvas_Scale
		#Canvas_Mouse
		#Canvas_Duration
		#Canvas_Combo
		#Canvas_CheckUpdate
		#Canvas_About
		
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
	#Appearance_Window_Width = 340
	#Appearance_Window_Height = 510
	#Appearance_Window_Margin = 50
	;}
	
	#WH_KEYBOARD_LL = 13
	#WM_INSTANCESTART = 111
	
	Global Dim InputArray.i(255)
	Global PopupMenu
	Global Enabled = #True
	Global MouseOffset = -1000
	
	; Private procedures declaration
	Declare CreateToggleButton(x, y, ID)
	Declare CreateTracbar(x, y, ID)
	Declare HandlerCloseWindow()
	Declare HandlerMenuEnabled()
	Declare HandlerMenuOptions()
	Declare HandlerMenuQuit()
	Declare HandlerSystray()
	Declare HandlerToggle()
	Declare HandlerTrackbar()
	Declare Hook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
	Declare RedrawToggle(ID)
	Declare RedrawTrackbar(ID)
	Declare SetColor()
	Declare WindowCallback(hWnd, Msg, wParam, lParam)
	Declare VectorCheck(x.d, y.d, Size.d)
	Declare VectorPlus(x.d, y.d, Size.d)
	
	;{ Public procedures
	Procedure Open()
		; Check if another instance is already running signal it
		Protected InstanceWindow = FindWindow_(#Null, General::#AppName + " v" + General:: #Version)
		If InstanceWindow
			SendMessage_(InstanceWindow, #WM_INSTANCESTART, 0, 0)
			HandlerMenuQuit() 
		EndIf
		
		WindowID = OpenWindow(#Window, 0, 0, #Appearance_Window_Width, #Appearance_Window_Height, General::#AppName + " v" + General:: #Version, #PB_Window_Invisible | #PB_Window_ScreenCentered | #PB_Window_SystemMenu)
		
		If WindowID
			; Window
			StickyWindow(#Window, #True)
			SetGadgetFont(#PB_Default, General::TitleFont)
			
			TextGadget(#Text_UserInterface, #Appearance_Window_Margin, 50, 200, 20, Language(#Lng_UserInterface))
			TextGadget(#Text_Behavior, #Appearance_Window_Margin, 190, 200, 20, Language(#Lng_Behavior))
			TextGadget(#Text_Misc, #Appearance_Window_Margin, 370, 200, 20, Language(#Lng_Misc))
			
			SetGadgetFont(#PB_Default, General::OptionFont)
			
			CreateToggleButton(#Appearance_Window_Margin, 81, #Canvas_DarkMode)
			CreateTracbar(#Appearance_Window_Margin, 121, #Canvas_Scale)
			CreateToggleButton(#Appearance_Window_Margin, 221, #Canvas_Mouse)
			CreateTracbar(#Appearance_Window_Margin, 261, #Canvas_Duration)
			CreateToggleButton(#Appearance_Window_Margin, 301, #Canvas_Combo)
			CreateToggleButton(#Appearance_Window_Margin, 401, #Canvas_CheckUpdate)
			
			SetColor()
			
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
			;TODO : Implement support of multiple screen? I only own one, so I can't do it by myself.
	  		Protected pData.APPBARDATA
	  		SHAppBarMessage_(#ABM_GETTASKBARPOS, pData)
	  		ExamineDesktops()
	  		
	  		If pData\uEdge = #ABE_BOTTOM
	  			PopupWindow::SetPopupOrigin(0, DesktopHeight(0) - (pData\rc\bottom - pData\rc\top))
	  		ElseIf pData\uEdge = #ABE_LEFT
	  			PopupWindow::SetPopupOrigin(pData\rc\right, DesktopHeight(0))
	  		EndIf
	  		
	  		; Event bindings
	  		BindEvent(#PB_Event_CloseWindow, @HandlerCloseWindow(), #Window)
	  		BindEvent(#PB_Event_SysTray,@HandlerSystray())
	  		BindEvent(#PB_Event_Menu, @HandlerMenuEnabled(), #Window, #Menu_Enabled) ; We can't use BindMenuEvent with FlatMenu
	  		BindEvent(#PB_Event_Menu, @HandlerMenuOptions(), #Window, #Menu_Options)
	  		BindEvent(#PB_Event_Menu, @HandlerMenuQuit(), #Window, #Menu_Quit)
	  		SetWindowCallback(@WindowCallback(), #Window)
	  		SetWindowsHookEx_(#WH_KEYBOARD_LL,@Hook(),GetModuleHandle_(0),0)
	  	Else
	  		HandlerMenuQuit() 
	  	EndIf
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure AddPathRoundedBox(x.d, y.d, Width, Height, Radius, Flag = #PB_Path_Default)
		MovePathCursor(x, y + Radius, Flag)
		
		AddPathArc(0, Height - radius, Width, Height - radius, Radius, #PB_Path_Relative)
		AddPathArc(Width - Radius, 0, Width - Radius, - Height, Radius, #PB_Path_Relative)
		AddPathArc(0, Radius - Height, -Width, Radius - Height, Radius, #PB_Path_Relative)
		AddPathArc(Radius - Width, 0, Radius - Width, Height, Radius, #PB_Path_Relative)
		ClosePath()
	EndProcedure
	
	Procedure CreateToggleButton(x, y, ID)
		CanvasGadget(ID, x, y, #Appearance_Window_Width - 2 * #Appearance_Window_Margin, 24, #PB_Canvas_Container)
		GadgetToolTip(ID, Language(ID + #ToolTip_DarkMode))
		SetGadgetData(ID, TextGadget(#PB_Any, 5, 4, 150, 16, Language(ID)))
		CloseGadgetList()
		SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_Hand)
		
		RedrawToggle(ID)
		
		BindEvent(#PB_Event_Gadget, @HandlerToggle(), #Window, ID)
	EndProcedure
	
	Procedure CreateTracbar(x, y, ID)
		CanvasGadget(ID, x, y, #Appearance_Window_Width - 2 * #Appearance_Window_Margin, 24, #PB_Canvas_Container)
		GadgetToolTip(ID, Language(ID + #ToolTip_DarkMode))
		SetGadgetData(ID, TextGadget(#PB_Any, 5, 4, 110, 16, Language(ID)))
		CloseGadgetList()
		
		RedrawTrackbar(ID)
		BindEvent(#PB_Event_Gadget, @HandlerTrackbar(), #Window, ID)
	EndProcedure
	
	Procedure HandlerCloseWindow()
		HideWindow(#Window, #True)
	EndProcedure
	
	Procedure HandlerMenuEnabled()
		Enabled = EventData()
	EndProcedure
	
	Procedure HandlerMenuOptions()
		HideWindow(#Window, #False, #PB_Window_ScreenCentered)
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
		ElseIf EventType() = #PB_EventType_LeftDoubleClick
			HandlerMenuOptions()
		EndIf
	EndProcedure
	
	Procedure HandlerToggle()
		Protected ID = EventGadget()
		
		If EventType() = #PB_EventType_LeftClick
			
			General::Preferences(ID) = Bool(Not General::Preferences(ID))
			
			If ID = #Canvas_DarkMode
				SetColor()
			Else
				RedrawToggle(ID)
			EndIf
			
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
					If MouseX >= 131 + Position - 5 And MouseX <= 131 + Position + 4
						SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
					Else
						SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_Default)
					EndIf
				Else
					Position = MouseX - 131 - MouseOffset
					If Position > 100
						Position = 100
					ElseIf Position < 0
						Position = 0
					EndIf
					
					General::Preferences(ID) = Minimum + (Position * Maximum) / 100
					RedrawTrackbar(ID)
				EndIf
			Case #PB_EventType_LeftButtonDown
				If MouseX >= 131 + Position - 5 And MouseX <= 131 + Position + 4
					MouseOffset = (MouseX - 131) - Position
					SetGadgetAttribute(ID, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
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
	
	Procedure Hook(nCode, wParam, *p.KBDLLHOOKSTRUCT)
		If nCode = #HC_ACTION
			
			If wParam = #WM_KEYDOWN
				If Enabled
					If Not InputArray(*p\vkCode)
						; This is a new input, create a new window
						InputArray(*p\vkCode) = PopupWindow::Create(*p\vkCode)
					Else
						; Hold!
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
		
	Procedure RedrawToggle(ID)
		StartVectorDrawing(CanvasVectorOutput(ID))
		AddPathBox(0, 0, VectorOutputWidth(), VectorOutputHeight())
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold)))
		FillPath()
		
		; Back
		AddPathCircle(195 + 12, 12, 12)
		AddPathCircle(195 + 40 - 12, 12, 12)
		AddPathBox(195 + 12, 0, 16, 24)
		
		VectorSourceColor(General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_ToggleOff + General::Preferences(ID)))
		FillPath(#PB_Path_Winding)
		
		; Front
		AddPathCircle(195 + 12  + General::Preferences(ID) * 15, 12, 9)
		If General::Preferences(ID)
			VectorCheck(195 + 6  + General::Preferences(ID) * 15, 13, 11)
		Else
			VectorPlus(195 + 12  + General::Preferences(ID) * 15, 2, 13)
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
		
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontDisabled)))
		
		MovePathCursor(131, 5)
		AddPathLine(0, 18, #PB_Path_Relative)
		
		MovePathCursor(231, 5)
		AddPathLine(0, 18, #PB_Path_Relative)
		StrokePath(2)
		
		AddPathBox(131 + Position, 10, 100 - Position, 8)
		AddPathCircle(231, 14, 4)
		FillPath(#PB_Path_Winding)
		
		AddPathCircle(131, 14, 4)
		AddPathBox(131, 10, Position, 8)
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_Trackbar)))
		FillPath(#PB_Path_Winding)
		
		AddPathRoundedBox(131 + Position - 5, 3, 9, 20, 3)
		VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontDisabled)))
		StrokePath(2, #PB_Path_Preserve)
		VectorSourceColor($FFFFFFFF)
		FillPath()
		
		
		
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
		SetGadgetColor(GetGadgetData(#Canvas_Combo), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(GetGadgetData(#Canvas_Combo), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		RedrawToggle(#Canvas_Combo)
		SetGadgetColor(GetGadgetData(#Canvas_CheckUpdate), #PB_Gadget_BackColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold))
		SetGadgetColor(GetGadgetData(#Canvas_CheckUpdate), #PB_Gadget_FrontColor, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_FrontCold))
		RedrawToggle(#Canvas_CheckUpdate)
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
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 224
; FirstLine = 105
; Folding = XBgE+
; EnableXP