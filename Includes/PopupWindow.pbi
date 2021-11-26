Module PopupWindow
	EnableExplicit
	; Private variables, structures and constants
	Enumeration ;Timer
		#Timer_Apparition
		#Timer_Duration
		#Timer_FadeOutAnimation
		#Timer_FadeInAnimation
		#Timer_Movement
	EndEnumeration
	
	Enumeration ;Window status
		#Born
		#Hold
		#Alive
		#Dying
	EndEnumeration
	
	#Window_Width = 320
	#Window_Height = 80
	
	#ApparitionDelay = 100 ; Delay until the window start appearing
	
	;{ Vkey
	Structure VKeyData
		Text.s
		Width.i
		Offset.i
	EndStructure
	
	Global Dim VKeyData.VKeyData(255)
	
	;{ Numbers ( 48 to 57)
	VKeyData(48)\Text = "0"
	VKeyData(48)\Width = 60
	VKeyData(48)\Offset = 32
	VKeyData(49)\Text = "1"
	VKeyData(49)\Width = 60
	VKeyData(49)\Offset = 32
	VKeyData(50)\Text = "2"
	VKeyData(50)\Width = 60
	VKeyData(50)\Offset = 32
	VKeyData(51)\Text = "3"
	VKeyData(51)\Width = 60
	VKeyData(51)\Offset = 32
	VKeyData(52)\Text = "4"
	VKeyData(52)\Width = 60
	VKeyData(52)\Offset = 32
	VKeyData(53)\Text = "5"
	VKeyData(53)\Width = 60
	VKeyData(53)\Offset = 32
	VKeyData(54)\Text = "6"
	VKeyData(54)\Width = 60
	VKeyData(54)\Offset = 32
	VKeyData(55)\Text = "7"
	VKeyData(55)\Width = 60
	VKeyData(55)\Offset = 32
	VKeyData(56)\Text = "8"
	VKeyData(56)\Width = 60
	VKeyData(56)\Offset = 32
	VKeyData(57)\Text = "9"
	VKeyData(57)\Width = 60
	VKeyData(57)\Offset = 32
	;}
	
	;{ Alphabet ( 65 to 90 )
	VKeyData(65)\Text = "A"
	VKeyData(65)\Width = 60
	VKeyData(65)\Offset = 30
	VKeyData(66)\Text = "B"
	VKeyData(66)\Width = 60
	VKeyData(66)\Offset = 30
	VKeyData(67)\Text = "C"
	VKeyData(67)\Width = 60
	VKeyData(67)\Offset = 30
	VKeyData(68)\Text = "D"
	VKeyData(68)\Width = 60
	VKeyData(68)\Offset = 30
	VKeyData(69)\Text = "E"
	VKeyData(69)\Width = 60
	VKeyData(69)\Offset = 30
	VKeyData(70)\Text = "F"
	VKeyData(70)\Width = 60
	VKeyData(70)\Offset = 31
	VKeyData(71)\Text = "G"
	VKeyData(71)\Width = 60
	VKeyData(71)\Offset = 29
	VKeyData(72)\Text = "H"
	VKeyData(72)\Width = 60
	VKeyData(72)\Offset = 30
	VKeyData(73)\Text = "I"
	VKeyData(73)\Width = 60
	VKeyData(73)\Offset = 36
	VKeyData(74)\Text = "J"
	VKeyData(74)\Width = 60
	VKeyData(74)\Offset = 32
	VKeyData(75)\Text = "K"
	VKeyData(75)\Width = 60
	VKeyData(75)\Offset = 30
	VKeyData(76)\Text = "L"
	VKeyData(76)\Width = 60
	VKeyData(76)\Offset = 31
	VKeyData(77)\Text = "M"
	VKeyData(77)\Width = 60
	VKeyData(77)\Offset = 28
	VKeyData(78)\Text = "N"
	VKeyData(78)\Width = 60
	VKeyData(78)\Offset = 30
	VKeyData(79)\Text = "O"
	VKeyData(79)\Width = 60
	VKeyData(79)\Offset = 29
	VKeyData(80)\Text = "P"
	VKeyData(80)\Width = 60
	VKeyData(80)\Offset = 30
	VKeyData(81)\Text = "Q"
	VKeyData(81)\Width = 60
	VKeyData(81)\Offset = 29
	VKeyData(82)\Text = "R"
	VKeyData(82)\Width = 60
	VKeyData(82)\Offset = 30
	VKeyData(83)\Text = "S"
	VKeyData(83)\Width = 60
	VKeyData(83)\Offset = 30
	VKeyData(84)\Text = "T"
	VKeyData(84)\Width = 60
	VKeyData(84)\Offset = 31
	VKeyData(85)\Text = "U"
	VKeyData(85)\Width = 60
	VKeyData(85)\Offset = 30
	VKeyData(86)\Text = "V"
	VKeyData(86)\Width = 60
	VKeyData(86)\Offset = 30
	VKeyData(87)\Text = "W"
	VKeyData(87)\Width = 60
	VKeyData(87)\Offset = 26
	VKeyData(88)\Text = "X"
	VKeyData(88)\Width = 60
	VKeyData(88)\Offset = 30
	VKeyData(89)\Text = "Y"
	VKeyData(89)\Width = 60
	VKeyData(89)\Offset = 30
	VKeyData(90)\Text = "Z"
	VKeyData(90)\Width = 60
	VKeyData(90)\Offset = 31
	;}
	
	;{ Function keys (112 to 135)
	VKeyData(112)\Text = "F1"
	VKeyData(112)\Width = 78
	VKeyData(112)\Offset = 32
	VKeyData(113)\Text = "F2"
	VKeyData(113)\Width = 78
	VKeyData(113)\Offset = 32
	VKeyData(114)\Text = "F3"
	VKeyData(114)\Width = 78
	VKeyData(114)\Offset = 32
	VKeyData(115)\Text = "F4"
	VKeyData(115)\Width = 78
	VKeyData(115)\Offset = 32
	VKeyData(116)\Text = "F5"
	VKeyData(116)\Width = 78
	VKeyData(116)\Offset = 32
	VKeyData(117)\Text = "F6"
	VKeyData(117)\Width = 78
	VKeyData(117)\Offset = 32
	VKeyData(118)\Text = "F7"
	VKeyData(118)\Width = 78
	VKeyData(118)\Offset = 32
	VKeyData(119)\Text = "F8"
	VKeyData(119)\Width = 78
	VKeyData(119)\Offset = 32
	VKeyData(120)\Text = "F9"
	VKeyData(120)\Width = 78
	VKeyData(120)\Offset = 32
	VKeyData(121)\Text = "F10"
	VKeyData(121)\Width = 78
	VKeyData(121)\Offset = 24
	VKeyData(122)\Text = "F11"
	VKeyData(122)\Width = 78
	VKeyData(122)\Offset = 24
	VKeyData(123)\Text = "F12"
	VKeyData(123)\Width = 78
	VKeyData(123)\Offset = 24
	VKeyData(124)\Text = "F13"
	VKeyData(124)\Width = 78
	VKeyData(124)\Offset = 24
	VKeyData(125)\Text = "F14"
	VKeyData(125)\Width = 78
	VKeyData(125)\Offset = 24
	VKeyData(126)\Text = "F15"
	VKeyData(126)\Width = 78
	VKeyData(126)\Offset = 24
	VKeyData(127)\Text = "F16"
	VKeyData(127)\Width = 78
	VKeyData(127)\Offset = 24
	VKeyData(128)\Text = "F17"
	VKeyData(128)\Width = 78
	VKeyData(128)\Offset = 24
	VKeyData(129)\Text = "F18"
	VKeyData(129)\Width = 78
	VKeyData(129)\Offset = 24
	VKeyData(130)\Text = "F19"
	VKeyData(130)\Width = 78
	VKeyData(130)\Offset = 24
	VKeyData(131)\Text = "F20"
	VKeyData(131)\Width = 78
	VKeyData(131)\Offset = 24
	VKeyData(132)\Text = "F21"
	VKeyData(132)\Width = 78
	VKeyData(132)\Offset = 24
	VKeyData(133)\Text = "F22"
	VKeyData(133)\Width = 78
	VKeyData(133)\Offset = 24
	VKeyData(134)\Text = "F23"
	VKeyData(134)\Width = 78
	VKeyData(134)\Offset = 24
	VKeyData(135)\Text = "F24"
	VKeyData(135)\Width = 78
	VKeyData(135)\Offset = 24
	;}
	
	;{ Modifiers
	VKeyData(16)\Text = "Shift"
	VKeyData(16)\Width = 94
	VKeyData(16)\Offset = 24
	
	VKeyData(17)\Text = "Ctrl"
	VKeyData(17)\Width = 77
	VKeyData(17)\Offset = 24
	
	VKeyData(18)\Text = "Alt"
	VKeyData(18)\Width = 69
	VKeyData(18)\Offset = 24
	;}
	
	;{ Arrow
	VKeyData(37)\Text = "◄"
	VKeyData(37)\Width = 60
	VKeyData(37)\Offset = 27
	
	VKeyData(39)\Text = "►"
	VKeyData(39)\Width = 60
	VKeyData(39)\Offset = 27
	
	VKeyData(38)\Text = "▲"
	VKeyData(38)\Width = 60
	VKeyData(38)\Offset = 27
	
	VKeyData(40)\Text = "▼"
	VKeyData(40)\Width = 60
	VKeyData(40)\Offset = 27
	;}
	
	;{ Misc
	VKeyData(13)\Text = "Return"
	VKeyData(13)\Width = 121
	VKeyData(13)\Offset = 24
	
	VKeyData(46)\Text = "Del"
	VKeyData(46)\Width = 71
	VKeyData(46)\Offset = 24
	
	VKeyData(8)\Text = "Backspace"
	VKeyData(8)\Width = 182
	VKeyData(8)\Offset = 24
	
	VKeyData(32)\Text = "Space"
	VKeyData(32)\Width = 121
	VKeyData(32)\Offset = 26
	
	VKeyData(186)\Text = ":"
	VKeyData(186)\Width = 60
	VKeyData(186)\Offset = 37
	
	VKeyData(187)\Text = "+"
	VKeyData(187)\Width = 60
	VKeyData(187)\Offset = 32
	
	VKeyData(188)\Text = ","
	VKeyData(188)\Width = 60
	VKeyData(188)\Offset = 37
	
	VKeyData(189)\Text = "-"
	VKeyData(189)\Width = 60
	VKeyData(189)\Offset = 35
	
	VKeyData(190)\Text = "."
	VKeyData(190)\Width = 60
	VKeyData(190)\Offset = 37
	
	VKeyData(191)\Text = "/"
	VKeyData(191)\Width = 60
	VKeyData(191)\Offset = 32
	
	VKeyData(192)\Text = "~"
	VKeyData(192)\Width = 60
	VKeyData(192)\Offset = 32
	
	VKeyData(219)\Text = "["
	VKeyData(219)\Width = 60
	VKeyData(219)\Offset = 36
	
	VKeyData(220)\Text = "\"
	VKeyData(220)\Width = 60
	VKeyData(220)\Offset = 35
	
	VKeyData(221)\Text = "]"
	VKeyData(221)\Width = 60
	VKeyData(221)\Offset = 36
	
	VKeyData(222)\Text = ~"\""
	VKeyData(222)\Width = 60
	VKeyData(222)\Offset = 34
	
	VKeyData(223)\Text = "§"
	VKeyData(223)\Width = 60
	VKeyData(223)\Offset = 36
	;}
	
	;{ Mouse
	VKeyData(#VK_LBUTTON)\Text = ""
	VKeyData(#VK_LBUTTON)\Width = 60
	VKeyData(#VK_LBUTTON)\Offset = 27
	
	VKeyData(#VK_RBUTTON)\Text = ""
	VKeyData(#VK_RBUTTON)\Width = 60
	VKeyData(#VK_RBUTTON)\Offset = 27
	
	VKeyData(#VK_MBUTTON)\Text = ""
	VKeyData(#VK_MBUTTON)\Width = 60
	VKeyData(#VK_MBUTTON)\Offset = 27
	;}
	
	;}
	
	Structure WindowData
		Window.i
		WindowID.i
		MovementTarget.l
		OriginalPosition.l
		CurrentPosition.l
		MovementStep.a
		FadeStep.a
		X.l
		Status.b
		Height.l
		Width.l
		Vkey.l
		Offset.i
		
		Image.i
		ImageID.i
		Alpha.a
		Combo.a
	EndStructure
	
	Global FrameDuration = 33										; The duration of a movement frame. 33ms =~ two frames on a 60fps screen
	Global FrameCount = 9											; The number of step in a movement animation.
	Global OriginX, OriginY											; The apparition coordinates of a new window
	Global WindowWidth = #Window_Width
	Global WindowHeight = #Window_Height
	Global Window_MovementTarget = WindowHeight + 10
	Global Scale.d = 1
	Global *LatestWindow.WindowData = 0
	Global NewList WindowList.WindowData()
	
	Global Dim Preprocess.f($FF), Blend.BLENDFUNCTION, Image_BitmapInfo.BITMAPINFO, ContextOffset.POINT
	
	; Private procedures declaration
	Declare HandlerTimer()
	Declare.d Ease_CubicOut(Time.d, Original.d, Target.d, Duration.d)
	Declare.d Ease_CubicIn(Time.d, Original.d, Target.d, Duration.d)
	Declare Init()
	Declare InitAlphaBlening(*WindowData.WindowData)
	Declare SetAlpha(*WindowData.WindowData)
	Declare DrawKey(VKey, *WindowData.WindowData)
	
	Init()
	
	Procedure max(a, b)
		If a > b
			ProcedureReturn a
		Else
			ProcedureReturn b
		EndIf
	EndProcedure
	
	;{ Public procedures
	Procedure AddKey(Window, VKey)
		If VKeyData(VKey)\Width 
			Protected *WindowData.WindowData = GetWindowData(Window)
			
			DrawKey(VKey, *WindowData)
			
			*LatestWindow\Vkey + VKey
			*LatestWindow\Offset + VKeyData(VKey)\Width + 5
			InitAlphaBlening(*LatestWindow)
		EndIf
	EndProcedure
	
	Procedure Create(VKey)
		Protected Window, Count
		
		If General::Preferences(General::#Pref_Combo) And *LatestWindow And *LatestWindow\Vkey = VKey And *LatestWindow\Status < #Dying
			Window = *LatestWindow\Window
			
			If *LatestWindow\Status = #Alive
				*LatestWindow\Status = #Hold
				RemoveWindowTimer(Window, #Timer_Duration)
			EndIf
			
			*LatestWindow\Combo + 1
			
			StartVectorDrawing(ImageVectorOutput(*LatestWindow\Image))
			VectorFont(General::TitleFont, 20 * Scale)
			
			General::AddPathRoundedBox((*LatestWindow\Offset + 10) * Scale, 22 * Scale, 30 * Scale + VectorTextWidth("x"+*LatestWindow\Combo), 36 * Scale, 4 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold)))
			FillPath()
			
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_4)))
			MovePathCursor((*LatestWindow\Offset + 25) * Scale, 30 * Scale)
			DrawVectorText("x"+*LatestWindow\Combo)
			FillPath()
			
			StopVectorDrawing()
			InitAlphaBlening(*LatestWindow)
			
		ElseIf VKeyData(VKey)\Width 
			; Move the other windows up.
			ForEach WindowList()
				WindowList()\OriginalPosition = WindowList()\CurrentPosition
				WindowList()\MovementTarget - Window_MovementTarget
				WindowList()\MovementStep = 0
				AddWindowTimer(WindowList()\Window, #Timer_Movement, FrameDuration)
			Next
			
			Window = OpenWindow(#PB_Any, OriginX, OriginY - Count * Window_MovementTarget, WindowWidth, WindowHeight, General::#AppName, #PB_Window_Invisible | #PB_Window_BorderLess, MainWindow::WindowID)
			
			If Window
				; Set up the window data
				*LatestWindow = AddElement(WindowList())
				*LatestWindow\Window = Window
				*LatestWindow\WindowID = WindowID(Window)
				*LatestWindow\CurrentPosition = OriginY - Count * Window_MovementTarget
				*LatestWindow\MovementTarget = *LatestWindow\CurrentPosition
				*LatestWindow\X = OriginX
				*LatestWindow\Status = #Hold
				*LatestWindow\Width = WindowWidth
				*LatestWindow\Height = WindowHeight
				*LatestWindow\Alpha = 0
				*LatestWindow\Image = CreateImage(#PB_Any, WindowWidth, WindowHeight, 32, #PB_Image_Transparent)
				*LatestWindow\Vkey = VKey
				*LatestWindow\Combo = 1
				*LatestWindow\Offset + 5
				
				SetWindowData(Window, *LatestWindow)
				
				DrawKey(VKey, *LatestWindow)
				
				*LatestWindow\ImageID = ImageID(*LatestWindow\Image)
				*LatestWindow\Offset + VKeyData(VKey)\Width + 5
				
				StickyWindow(Window, #True)
				BindEvent(#PB_Event_Timer, @HandlerTimer(), Window)
				
				; Set up the alpha blending
				SetWindowLongPtr_(*LatestWindow\WindowID,#GWL_EXSTYLE,#WS_EX_LAYERED)
				InitAlphaBlening(*LatestWindow)
				HideWindow(Window, #False, #PB_Window_NoActivate)
				
				; Delay the apparition (helps for Hold)
				AddWindowTimer(Window, #Timer_Apparition, #ApparitionDelay)
			EndIf
		EndIf
		ProcedureReturn Window
	EndProcedure
	
	Procedure CreateMouse(VKey)
		
	EndProcedure
	
	Procedure Hide(Window)
		Protected *WindowData.WindowData = GetWindowData(Window)
		
 		AddWindowTimer(Window, #Timer_Duration, General::Preferences(General::#Pref_Duration) + (FrameCount - *WindowData\MovementStep) * FrameDuration)
		*WindowData\Status = #Alive
	EndProcedure
	
	Procedure SetPopupOrigin(X, Y)
		OriginX = X
		OriginY = Y - WindowHeight
	EndProcedure
	
	Procedure ShortCut(Control, Shift, Alt,Vkey)
		;TODO: Clean this mess up!
		If Vkey = #VK_SHIFT
			If *LatestWindow And *LatestWindow\Status < #Dying 
				If *LatestWindow\Vkey = #VK_CONTROL And *LatestWindow\Combo = 1
					MainWindow::InputArray(#VK_SHIFT) = MainWindow::InputArray(#VK_CONTROL)
					MainWindow::InputArray(#VK_CONTROL) = #False
					AddKey(*LatestWindow\Window, Vkey)
				ElseIf *LatestWindow\Vkey = #VK_CONTROL + Vkey
					Create(*LatestWindow\Vkey)
					MainWindow::InputArray(#VK_SHIFT) = *LatestWindow\Window
				Else
					AddWindowTimer(*LatestWindow\Window, #Timer_Duration, General::Preferences(General::#Pref_Duration))
					MainWindow::InputArray(#VK_CONTROL) = #False
					*LatestWindow = 0
					MainWindow::InputArray(#VK_SHIFT) = Create(#VK_CONTROL)
					AddKey(*LatestWindow\Window, #VK_SHIFT)
				EndIf
			Else
				MainWindow::InputArray(#VK_CONTROL) = #False
				*LatestWindow = 0
				MainWindow::InputArray(#VK_SHIFT) = Create(#VK_CONTROL)
				AddKey(*LatestWindow\Window, #VK_SHIFT)
			EndIf
		ElseIf Vkey = #VK_MENU
			If *LatestWindow And *LatestWindow\Status < #Dying 
				If *LatestWindow\Vkey = #VK_CONTROL And *LatestWindow\Combo = 1
					MainWindow::InputArray(#VK_MENU) = MainWindow::InputArray(#VK_CONTROL)
					MainWindow::InputArray(#VK_CONTROL) = #False
					AddKey(*LatestWindow\Window, Vkey)
				ElseIf *LatestWindow\Vkey = #VK_CONTROL + Vkey
					Create(*LatestWindow\Vkey)
					MainWindow::InputArray(#VK_MENU) = *LatestWindow\Window
				Else
					AddWindowTimer(*LatestWindow\Window, #Timer_Duration, General::Preferences(General::#Pref_Duration))
					MainWindow::InputArray(#VK_CONTROL) = #False
					*LatestWindow = 0
					MainWindow::InputArray(#VK_MENU) = Create(#VK_CONTROL)
					AddKey(*LatestWindow\Window, #VK_MENU)
				EndIf
			Else
				MainWindow::InputArray(#VK_CONTROL) = #False
				*LatestWindow = 0
				MainWindow::InputArray(#VK_MENU) = Create(#VK_CONTROL)
				AddKey(*LatestWindow\Window, #VK_MENU)
			EndIf
		Else
			If *LatestWindow And *LatestWindow\Status < #Dying 
				If *LatestWindow\Vkey = Control * #VK_CONTROL + Shift * #VK_SHIFT + Alt * #VK_MENU And *LatestWindow\Combo = 1
					MainWindow::InputArray(Vkey) = *LatestWindow\Window
					MainWindow::InputArray(#VK_CONTROL) = #False
					MainWindow::InputArray(#VK_SHIFT) = #False
					MainWindow::InputArray(#VK_MENU) = #False
					
					AddKey(*LatestWindow\Window, Vkey)
					
				ElseIf *LatestWindow\Vkey = Control * #VK_CONTROL + Shift * #VK_SHIFT + Alt * #VK_MENU + Vkey
					Create(*LatestWindow\Vkey)
					MainWindow::InputArray(Vkey) = *LatestWindow\Window
				Else
					AddWindowTimer(*LatestWindow\Window, #Timer_Duration, General::Preferences(General::#Pref_Duration))
					*LatestWindow = 0
					MainWindow::InputArray(#VK_CONTROL) = #False
					MainWindow::InputArray(#VK_SHIFT) = #False
					MainWindow::InputArray(#VK_MENU) = #False
					
					If Control
						MainWindow::InputArray(Vkey) = Create(#VK_CONTROL)
					EndIf
					
					If Shift
						If MainWindow::InputArray(Vkey)
							AddKey(MainWindow::InputArray(Vkey), #VK_SHIFT)
						Else
							MainWindow::InputArray(Vkey) = Create(#VK_SHIFT)
						EndIf
					EndIf
					
					If Alt
						If MainWindow::InputArray(Vkey)
							AddKey(MainWindow::InputArray(Vkey), #VK_MENU)
						Else
							MainWindow::InputArray(Vkey) = Create(#VK_MENU)
						EndIf
					EndIf
					
					AddKey(MainWindow::InputArray(Vkey), Vkey)
					
				EndIf
			Else
				AddWindowTimer(*LatestWindow\Window, #Timer_Duration, General::Preferences(General::#Pref_Duration))
				*LatestWindow = 0
				MainWindow::InputArray(#VK_CONTROL) = #False
				MainWindow::InputArray(#VK_SHIFT) = #False
				MainWindow::InputArray(#VK_MENU) = #False
				
				If Control
					MainWindow::InputArray(Vkey) = Create(#VK_CONTROL)
				EndIf
				
				If Shift
					If MainWindow::InputArray(Vkey)
						AddKey(MainWindow::InputArray(Vkey), #VK_SHIFT)
					Else
						MainWindow::InputArray(Vkey) = Create(#VK_SHIFT)
					EndIf
				EndIf
				
				If Alt
					If MainWindow::InputArray(Vkey)
						AddKey(MainWindow::InputArray(Vkey), #VK_MENU)
					Else
						MainWindow::InputArray(Vkey) = Create(#VK_MENU)
					EndIf
				EndIf
				
				AddKey(MainWindow::InputArray(Vkey), Vkey)
			EndIf
		EndIf
	EndProcedure
	
	Procedure SetScale(NewScale)
		Scale = NewScale / 100
		OriginY + WindowHeight
		WindowWidth = #Window_Width * Scale
		WindowHeight = #Window_Height * Scale
		Window_MovementTarget = WindowHeight + 10 * Scale
		OriginY - WindowHeight
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure Init()
		Protected Loop, Image
		
		For Loop = 0 To $FF
			Preprocess(Loop) = Loop / $FF
		Next
		
		Blend\AlphaFormat = 1
		Blend\BlendOp = 0
		Blend\BlendFlags = 0
		
		Image_BitmapInfo\bmiHeader\biSize = SizeOf(BITMAPINFOHEADER)
		Image_BitmapInfo\bmiHeader\biPlanes = 1
		Image_BitmapInfo\bmiHeader\biBitCount = 32
	EndProcedure
	
	Procedure InitAlphaBlening(*WindowData.WindowData)
		Protected Width, Height, x, y, Red, Green, Blue, AlphaChannel, Color, ImageDC, OldDC
		
		ImageDC = CreateCompatibleDC_(#Null)
		OldDC = SelectObject_(ImageDC, *WindowData\ImageID)
		
		Width = *WindowData\Width - 1
		Height = *WindowData\Height - 1
		Protected Dim Image.l(Width, Height)
		Image_BitmapInfo\bmiHeader\biWidth = *WindowData\Width
		Image_BitmapInfo\bmiHeader\biHeight = *WindowData\Height
		
		GetDIBits_(ImageDC, *WindowData\ImageID, 0, *WindowData\Height, @Image(), @Image_BitmapInfo, #DIB_RGB_COLORS)
		
		For x = 0 To Width
			For y = 0 To Height
				Color = Image(x, y)
				AlphaChannel = Color >> 24 & $FF
				If AlphaChannel < $FF
					If AlphaChannel = 0
						Image(x, y) = 0
					Else
						Red = (Color & $FF) * Preprocess(AlphaChannel)
						Green = (Color >> 8 & $FF) * Preprocess(AlphaChannel)
						Blue = (Color >> 16 & $FF) * Preprocess(AlphaChannel)
						Image(x, y) = Red | Green << 8 | Blue << 16 | AlphaChannel << 24
					EndIf
				EndIf
			Next
		Next
		
		SetDIBits_(ImageDC, *WindowData\ImageID, 0, *WindowData\Height, @Image(), @Image_BitmapInfo, #DIB_RGB_COLORS)
		
		Blend\SourceConstantAlpha = *WindowData\Alpha
		
		UpdateLayeredWindow_(*WindowData\WindowID, 0, 0, @Image_BitmapInfo + 4, ImageDC, @ContextOffset, 0, @Blend, 2)
		
		SelectObject_(ImageDC, OldDC)
		
		DeleteDC_(OldDC)
 		DeleteDC_(ImageDC)
	EndProcedure
	
	Procedure SetAlpha(*WindowData.WindowData)
		Protected ImageDC, OldDC
		
		ImageDC = CreateCompatibleDC_(#Null)
		OldDC = SelectObject_(ImageDC, *WindowData\ImageID)
		
		Blend\SourceConstantAlpha = *WindowData\Alpha
		Image_BitmapInfo\bmiHeader\biWidth = *WindowData\Width
		Image_BitmapInfo\bmiHeader\biHeight = *WindowData\Height
		
		UpdateLayeredWindow_(*WindowData\WindowID, 0, 0, @Image_BitmapInfo + 4, ImageDC, #NUL, 0, @Blend, 2)
		
		SelectObject_(ImageDC, OldDC)
		DeleteDC_(OldDC)
		DeleteDC_(ImageDC)
	EndProcedure
	
	Procedure HandlerTimer()
		Protected Window = EventWindow()
		Protected *WindowData.WindowData = GetWindowData(Window)
		
		Select EventTimer()
			Case #Timer_Duration
				*WindowData\Status = #Dying
				AddWindowTimer(Window, #Timer_FadeOutAnimation, FrameDuration)
				
			Case #Timer_FadeInAnimation
				*WindowData\FadeStep + 1
				
				If *WindowData\FadeStep = 7
					SetAlpha(*WindowData)
					RemoveWindowTimer(Window, #Timer_FadeInAnimation)
				Else
					*WindowData\Alpha = Ease_CubicOut(*WindowData\FadeStep, 0, 255, 7)
					SetAlpha(*WindowData)
				EndIf
				
			Case #Timer_FadeOutAnimation
				*WindowData\FadeStep - 1
				
				If *WindowData\FadeStep = 0
					Protected Y = *WindowData\CurrentPosition
					UnbindEvent(#PB_Event_Timer, @HandlerTimer(), Window)
					FreeImage(*WindowData\Image)
					
					ChangeCurrentElement(WindowList(), *WindowData)
					If DeleteElement(WindowList(), #True)
						Repeat  ; Check if later objects should be moved back down.
							If WindowList()\CurrentPosition < Y
								WindowList()\OriginalPosition = WindowList()\CurrentPosition
								WindowList()\MovementTarget + Window_MovementTarget
								WindowList()\MovementStep = 0
								AddWindowTimer(WindowList()\Window, #Timer_Movement, FrameDuration)
							EndIf
						Until Not PreviousElement(WindowList())
					Else
						*LatestWindow = 0
					EndIf
					
					CloseWindow(Window)
				Else
					
					*WindowData\Alpha = Ease_CubicIn(*WindowData\FadeStep, 0, 255, 7)
					SetAlpha(*WindowData)
				EndIf
				
			Case #Timer_Movement
				*WindowData\MovementStep + 1
				
				If *WindowData\MovementStep = FrameCount
					*WindowData\OriginalPosition = *WindowData\MovementTarget
					*WindowData\CurrentPosition = *WindowData\MovementTarget
					RemoveWindowTimer(Window, #Timer_Movement)
				Else
					*WindowData\CurrentPosition = Ease_CubicOut(*WindowData\MovementStep, *WindowData\OriginalPosition, *WindowData\MovementTarget, FrameCount)
				EndIf
				
				SetWindowPos_(*WindowData\WindowID, 0, *WindowData\X, *WindowData\CurrentPosition, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER|#SWP_NOREDRAW)
				
			Case #Timer_Apparition
				AddWindowTimer(Window, #Timer_FadeInAnimation, FrameDuration)
				RemoveWindowTimer(Window, #Timer_Apparition)
		EndSelect
	EndProcedure
	
	Procedure.d Ease_CubicOut(Time.d, Original.d, Target.d, Duration.d)
		Target - Original
		Time / Duration
		Time - 1
		ProcedureReturn ((Target * ((Time * Time * Time) + 1)) + Original)
	EndProcedure
	
	Procedure.d Ease_CubicIn(Time.d, Original.d, Target.d, Duration.d)
		ProcedureReturn Original + Target - Ease_CubicOut(Duration - Time, Original, Target, Duration);
	EndProcedure
	
	Procedure DrawKey(VKey, *WindowData.WindowData)
		StartVectorDrawing(ImageVectorOutput(*WindowData\Image))
		VectorFont(General::TitleFont, 30 * Scale)
		
		If VKey < 5
			SaveVectorState()
			
			AddPathBox(10,8, 27, 61)
			ClipPath()
			
			MovePathCursor((*LatestWindow\Offset + 32) * Scale, 35 * Scale)
			AddPathLine(-23, 0, #PB_Path_Relative)
			AddPathArc(-3, 28, 22, 30, 10, #PB_Path_Relative)
			AddPathCurve(0, 0, 15, 5, 30, 0,  #PB_Path_Relative)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2)))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			StrokePath(4)
			
			MovePathCursor((*LatestWindow\Offset + 32) * Scale, 35 * Scale)
			AddPathLine(-23, 0, #PB_Path_Relative)
			AddPathArc(3, -22, 15, -25, 10, #PB_Path_Relative)
			AddPathLine(13, 0, #PB_Path_Relative)
			ClosePath()
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2 + 3 * Bool(VKey = #VK_LBUTTON))))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			StrokePath(4)
			
			RestoreVectorState()
			SaveVectorState()
			
			FlipCoordinatesX(37)

			AddPathBox(10,8, 27, 61)
			ClipPath()
			
			MovePathCursor((*LatestWindow\Offset + 32) * Scale, 35 * Scale)
			AddPathLine(-23, 0, #PB_Path_Relative)
			AddPathArc(-3, 28, 22, 30, 10, #PB_Path_Relative)
			AddPathCurve(0, 0, 15, 5, 30, 0,  #PB_Path_Relative)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2)))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			StrokePath(4)
			
			MovePathCursor((*LatestWindow\Offset + 32) * Scale, 35 * Scale)
			AddPathLine(-23, 0, #PB_Path_Relative)
			AddPathArc(3, -22, 15, -25, 10, #PB_Path_Relative)
			AddPathLine(13, 0, #PB_Path_Relative)
			ClosePath()
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2 + 3 * Bool(VKey = #VK_RBUTTON))))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			StrokePath(4)
			
			RestoreVectorState()
			SaveVectorState()
			
			AddPathCircle(37, 20, 6)
			AddPathCircle(37, 27, 6)
			AddPathBox(31, 20, 12, 7)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			FillPath(#PB_Path_Winding)
			
			
			AddPathCircle(37, 20, 4)
			AddPathCircle(37, 25, 4)
			AddPathBox(33, 20, 8, 5)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2 + 3 * Bool(VKey = #VK_MBUTTON))))
			FillPath(#PB_Path_Winding)
			
		Else
			
			General::AddPathRoundedBox((*LatestWindow\Offset + 5) * Scale, 10 * Scale, VKeyData(VKey)\Width * Scale, 60 * Scale, 7 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			FillPath()
			
			General::AddPathRoundedBox((*LatestWindow\Offset + 9) * Scale, 14 * Scale, (VKeyData(VKey)\Width - 8) * Scale, 52 * Scale, 4 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_1)))
			FillPath()
			
			General::AddPathRoundedBox((*LatestWindow\Offset + 12) * Scale, 17 * Scale, (VKeyData(VKey)\Width - 14) * Scale, 46 * Scale, 2 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2)))
			FillPath()
			
			General::AddPathRoundedBox((*LatestWindow\Offset + 15) * Scale, 20 * Scale, (VKeyData(VKey)\Width - 20) * Scale, 40 * Scale, 2 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_3)))
			FillPath()
			
			MovePathCursor((*LatestWindow\Offset + VKeyData(VKey)\Offset - 5)  * Scale, 25  * Scale)
			
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_4)))
			DrawVectorText(VKeyData(VKey)\Text)
			
			FillPath()
		EndIf
		StopVectorDrawing()
	EndProcedure
	;}
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 822
; FirstLine = 221
; Folding = DVDB+
; EnableXP