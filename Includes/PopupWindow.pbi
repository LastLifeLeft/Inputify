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
	
	;{ Alphabet
	VKeyData('A')\Offset = 30
	VKeyData('B')\Offset = 30
	VKeyData('C')\Offset = 30
	VKeyData('D')\Offset = 30
	VKeyData('E')\Offset = 30
	VKeyData('F')\Offset = 31
	VKeyData('G')\Offset = 29
	VKeyData('H')\Offset = 30
	VKeyData('I')\Offset = 36
	VKeyData('J')\Offset = 32
	VKeyData('K')\Offset = 30
	VKeyData('L')\Offset = 31
	VKeyData('M')\Offset = 28
	VKeyData('N')\Offset = 30
	VKeyData('O')\Offset = 29
	VKeyData('P')\Offset = 30
	VKeyData('Q')\Offset = 29
	VKeyData('R')\Offset = 30
	VKeyData('S')\Offset = 30
	VKeyData('T')\Offset = 31
	VKeyData('U')\Offset = 30
	VKeyData('V')\Offset = 30
	VKeyData('W')\Offset = 26
	VKeyData('X')\Offset = 30
	VKeyData('Y')\Offset = 30
	VKeyData('Z')\Offset = 31
	
	;}
	
	;{ Special
	VKeyData(#VK_SHIFT)\Text = "Shift"
	VKeyData(#VK_SHIFT)\Width = 94
	VKeyData(#VK_SHIFT)\Offset = 24
	
	VKeyData(#VK_CONTROL)\Text = "Ctrl"
	VKeyData(#VK_CONTROL)\Width = 77
	VKeyData(#VK_CONTROL)\Offset = 24
	
	VKeyData(#VK_MENU)\Text = "Alt"
	VKeyData(#VK_MENU)\Width = 69
	VKeyData(#VK_MENU)\Offset = 24
	
	VKeyData(#VK_ESCAPE)\Text = "Esc"
	VKeyData(#VK_ESCAPE)\Width = 82
	VKeyData(#VK_ESCAPE)\Offset = 24
	
	VKeyData(#VK_TAB)\Text = "Tab"
	VKeyData(#VK_TAB)\Width = 80
	VKeyData(#VK_TAB)\Offset = 24
	
	VKeyData(#VK_CAPITAL)\Text = "CAPS"
	VKeyData(#VK_CAPITAL)\Width = 110
	VKeyData(#VK_CAPITAL)\Offset = 24
	
	VKeyData(#VK_RETURN)\Text = "Return"
	VKeyData(#VK_RETURN)\Width = 121
	VKeyData(#VK_RETURN)\Offset = 24
	
	VKeyData(#VK_DELETE)\Text = "Del"
	VKeyData(#VK_DELETE)\Width = 71
	VKeyData(#VK_DELETE)\Offset = 24
	
	VKeyData(#VK_BACK)\Text = "Backspace"
	VKeyData(#VK_BACK)\Width = 182
	VKeyData(#VK_BACK)\Offset = 24
	
	VKeyData(#VK_SPACE)\Text = "Space"
	VKeyData(#VK_SPACE)\Width = 121
	VKeyData(#VK_SPACE)\Offset = 26
	;}
	
	;{ Arrow
	VKeyData(#VK_LEFT)\Text = "◄"
	VKeyData(#VK_LEFT)\Width = 60
	VKeyData(#VK_LEFT)\Offset = 27
	
	VKeyData(#VK_RIGHT)\Text = "►"
	VKeyData(#VK_RIGHT)\Width = 60
	VKeyData(#VK_RIGHT)\Offset = 27
	
	VKeyData(#VK_UP)\Text = "▲"
	VKeyData(#VK_UP)\Width = 60
	VKeyData(#VK_UP)\Offset = 27
	
	VKeyData(#VK_DOWN)\Text = "▼"
	VKeyData(#VK_DOWN)\Width = 60
	VKeyData(#VK_DOWN)\Offset = 27
	;}
	
	;{ Misc
	VKeyData(186)\Text = ":"
	VKeyData(186)\Width = 60
	VKeyData(186)\Offset = 35
	
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
	VKeyData(191)\Offset = 37
	
	VKeyData(192)\Text = "~"
	VKeyData(192)\Width = 60
	VKeyData(192)\Offset = 32
	
	VKeyData(219)\Text = "["
	VKeyData(219)\Width = 60
	VKeyData(219)\Offset = 36
	
	VKeyData(220)\Text = "\"
	VKeyData(220)\Width = 60
	VKeyData(220)\Offset = 37
	
	VKeyData(221)\Text = "]"
	VKeyData(221)\Width = 60
	VKeyData(221)\Offset = 36
	
	VKeyData(222)\Text = ~"'"
	VKeyData(222)\Width = 60
	VKeyData(222)\Offset = 37
	
	VKeyData(223)\Text = "§"
	VKeyData(223)\Width = 60
	VKeyData(223)\Offset = 32
	;}
	
	;{ Mouse
	VKeyData(#VK_LBUTTON)\Width = 60
	VKeyData(#VK_RBUTTON)\Width = 60
	VKeyData(#VK_MBUTTON)\Width = 60
	;}
	
	;{ Numpad
	VKeyData(#VK_DIVIDE)\Text = "/"
	VKeyData(#VK_DIVIDE)\Width = 60
	VKeyData(#VK_DIVIDE)\Offset = 37
	
	VKeyData(#VK_MULTIPLY)\Text = "*"
	VKeyData(#VK_MULTIPLY)\Width = 60
	VKeyData(#VK_MULTIPLY)\Offset = 35
	
	VKeyData(#VK_ADD)\Text = "+"
	VKeyData(#VK_ADD)\Width = 60
	VKeyData(#VK_ADD)\Offset = 32
	
	VKeyData(#VK_SUBTRACT)\Text = "-"
	VKeyData(#VK_SUBTRACT)\Width = 60
	VKeyData(#VK_SUBTRACT)\Offset = 35
	
	VKeyData(#VK_DECIMAL)\Text = "."
	VKeyData(#VK_DECIMAL)\Width = 60
	VKeyData(#VK_DECIMAL)\Offset = 37
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
		OriginalImage.i												; We must keep a copy of the original image for proper alphablending calculation down the line.
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
	
	;{ Public procedures
	Procedure AddKey(Window, VKey)
		If VKeyData(VKey)\Width 
			Protected *WindowData.WindowData = GetWindowData(Window)
			
			DrawKey(VKey, *WindowData)
		EndIf
	EndProcedure
	
	Procedure Create(VKey)
		Protected Window
		
		If General::Preferences(General::#Pref_Combo) And *LatestWindow And *LatestWindow\Vkey = VKey And *LatestWindow\Status < #Dying
			Window = *LatestWindow\Window
			
			If *LatestWindow\Status = #Alive
				*LatestWindow\Status = #Hold
				RemoveWindowTimer(Window, #Timer_Duration)
			EndIf
			
			*LatestWindow\Combo + 1
			
			StartVectorDrawing(ImageVectorOutput(*LatestWindow\OriginalImage))
			VectorFont(General::TitleFont, 20 * Scale)
			
			General::AddPathRoundedBox((*LatestWindow\Offset) * Scale, 12 * Scale, 30 * Scale + VectorTextWidth("x"+*LatestWindow\Combo), 36 * Scale, 4 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Type_BackCold)))
			FillPath()
			
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_4)))
			MovePathCursor((*LatestWindow\Offset + 15) * Scale, 20 * Scale)
			DrawVectorText("x"+*LatestWindow\Combo)
			FillPath()
			
			StopVectorDrawing()
			
			FreeImage(*LatestWindow\Image)
			*LatestWindow\Image = CopyImage(*LatestWindow\OriginalImage, #PB_Any)
			*LatestWindow\ImageID = ImageID(*LatestWindow\Image)
			InitAlphaBlening(*LatestWindow)
			
		ElseIf VKeyData(VKey)\Width 
			; Move the other windows up.
			ForEach WindowList()
				WindowList()\OriginalPosition = WindowList()\CurrentPosition
				WindowList()\MovementTarget - Window_MovementTarget
				WindowList()\MovementStep = 0
				AddWindowTimer(WindowList()\Window, #Timer_Movement, FrameDuration)
			Next
			
			Window = OpenWindow(#PB_Any, OriginX, OriginY, WindowWidth, WindowHeight, General::#AppName, #PB_Window_Invisible | #PB_Window_BorderLess | #PB_Window_NoActivate | #PB_Window_NoGadgets, MainWindow::WindowID)
			
			If Window
				; Set up the window data
				*LatestWindow = AddElement(WindowList())
				*LatestWindow\Window = Window
				*LatestWindow\WindowID = WindowID(Window)
				*LatestWindow\CurrentPosition = OriginY
				*LatestWindow\MovementTarget = *LatestWindow\CurrentPosition
				*LatestWindow\X = OriginX
				*LatestWindow\Status = #Hold
				*LatestWindow\Width = WindowWidth
				*LatestWindow\Height = WindowHeight
				*LatestWindow\Alpha = 0
				*LatestWindow\OriginalImage = CreateImage(#PB_Any, WindowWidth, WindowHeight, 32, #PB_Image_Transparent)
				*LatestWindow\Combo = 1
				
				SetWindowLongPtr_(*LatestWindow\WindowID, #GWL_EXSTYLE, #WS_EX_LAYERED)
				
				SetWindowData(Window, *LatestWindow)
				
				DrawKey(VKey, *LatestWindow)
				
				StickyWindow(Window, #True)
				BindEvent(#PB_Event_Timer, @HandlerTimer(), Window)
				
				; Set up the alpha blending
				HideWindow(Window, #False, #PB_Window_NoActivate)
				
				; Delay the apparition to limit overlap.
				AddWindowTimer(Window, #Timer_Apparition, #ApparitionDelay)
			EndIf
		EndIf
		ProcedureReturn Window
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
		If *LatestWindow And *LatestWindow\Status < #Dying 
			If *LatestWindow\Vkey = Control * #VK_CONTROL + (Shift * Bool(Not Vkey = #VK_SHIFT)) * #VK_SHIFT + (Alt * Bool(Not Vkey = #VK_MENU)) * #VK_MENU And *LatestWindow\Combo = 1
				MainWindow::InputArray(#VK_CONTROL) = #False
				MainWindow::InputArray(#VK_SHIFT) = #False
				MainWindow::InputArray(#VK_MENU) = #False
				MainWindow::InputArray(Vkey) = *LatestWindow\Window
				
				AddKey(*LatestWindow\Window, Vkey)
				
				ProcedureReturn #False
			ElseIf *LatestWindow\Vkey = Control * #VK_CONTROL + Shift * #VK_SHIFT + Alt * #VK_MENU + Vkey
				Create(*LatestWindow\Vkey)
				MainWindow::InputArray(Vkey) = *LatestWindow\Window
				
				ProcedureReturn #False
			EndIf
		EndIf
		
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
	EndProcedure
	
	Procedure SetScale(NewScale)
		OriginY + WindowHeight
		Scale = NewScale / 100
		WindowWidth = #Window_Width * Scale
		WindowHeight = (#Window_Height - 20) * Scale
		Window_MovementTarget = (#Window_Height * Scale)
		OriginY - WindowHeight
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure Init()
		Protected Loop
		
		For Loop = 0 To $FF
			Preprocess(Loop) = Loop / $FF
		Next
		
		Blend\AlphaFormat = 1
		Blend\BlendOp = 0
		Blend\BlendFlags = 0
		
		Image_BitmapInfo\bmiHeader\biSize = SizeOf(BITMAPINFOHEADER)
		Image_BitmapInfo\bmiHeader\biPlanes = 1
		Image_BitmapInfo\bmiHeader\biBitCount = 32
		
		For Loop = '0' To '9'
			VKeyData(Loop)\Text = Chr(Loop)
			VKeyData(Loop)\Width = 60
			VKeyData(Loop)\Offset = 32
			
			;Numpad :
			VKeyData(Loop + 48)\Text = Chr(Loop)
			VKeyData(Loop + 48)\Width = 60
			VKeyData(Loop + 48)\Offset = 32
		Next
		
		For Loop = 1 To  9
			VKeyData(111 + Loop)\Text = "F" + Loop
			VKeyData(111 + Loop)\Width = 78
			VKeyData(111 + Loop)\Offset = 32
		Next
		
		For Loop = 0 To 14
			VKeyData(121 + loop)\Text = "F" + Str(10 + Loop)
			VKeyData(121 + loop)\Width = 78
			VKeyData(121 + loop)\Offset = 24
		Next
		
		For Loop = 'A' To 'Z'
			VKeyData(Loop)\Text = Chr(Loop)
			VKeyData(Loop)\Width = 60
		Next
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
					FreeImage(*WindowData\OriginalImage)
					
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
		StartVectorDrawing(ImageVectorOutput(*WindowData\OriginalImage))
		
		If VKey < 5
			SaveVectorState()
			
			AddPathBox(0, 0, 27 * Scale, 61 * Scale)
			ClipPath()
			
			MovePathCursor((*WindowData\Offset + 27) * Scale, 27 * Scale)
			AddPathLine(-23 * Scale, 0, #PB_Path_Relative)
			AddPathArc(-3 * Scale, 28 * Scale, 22 * Scale, 30 * Scale, 10 * Scale, #PB_Path_Relative)
			AddPathCurve(0, 0, 15 * Scale, 5 * Scale, 30 * Scale, 0,  #PB_Path_Relative)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2)))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			StrokePath(4 * Scale)
			
			MovePathCursor((*WindowData\Offset + 27) * Scale, 27 * Scale)
			AddPathLine(-23 * Scale, 0, #PB_Path_Relative)
			AddPathArc(3 * Scale, -22 * Scale, 15 * Scale, -25 * Scale, 10 * Scale, #PB_Path_Relative)
			AddPathLine(13 * Scale, 0, #PB_Path_Relative)
			ClosePath()
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2 + 3 * Bool(VKey = #VK_LBUTTON))))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			StrokePath(4 * Scale)
			
			RestoreVectorState()
			SaveVectorState()
			
			FlipCoordinatesX(27 * Scale)
			
			AddPathBox(0, 0, 27 * Scale, 61 * Scale)
			ClipPath()
			
			MovePathCursor((*WindowData\Offset + 27) * Scale, 27 * Scale)
			AddPathLine(-23 * Scale, 0, #PB_Path_Relative)
			AddPathArc(-3 * Scale, 28 * Scale, 22 * Scale, 30 * Scale, 10 * Scale, #PB_Path_Relative)
			AddPathCurve(0, 0, 15 * Scale, 5 * Scale, 30 * Scale, 0,  #PB_Path_Relative)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2)))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			StrokePath(4 * Scale)
			
			MovePathCursor((*WindowData\Offset + 27) * Scale, 27 * Scale)
			AddPathLine(-23 * Scale, 0, #PB_Path_Relative)
			AddPathArc(3 * Scale, -22 * Scale, 15 * Scale, -25 * Scale, 10 * Scale, #PB_Path_Relative)
			AddPathLine(13 * Scale, 0, #PB_Path_Relative)
			ClosePath()
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2 + 3 * Bool(VKey = #VK_RBUTTON))))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			StrokePath(4 * Scale)
			
			RestoreVectorState()
			SaveVectorState()
			
			AddPathCircle(27 * Scale, 12 * Scale, 6 * Scale)
			AddPathCircle(27 * Scale, 19 * Scale, 6 * Scale)
			AddPathBox(21 * Scale, 12 * Scale, 12 * Scale, 7 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			FillPath(#PB_Path_Winding)
			
			AddPathCircle(27 * Scale, 12 * Scale, 4 * Scale)
			AddPathCircle(27 * Scale, 17 * Scale, 4 * Scale)
			AddPathBox(23 * Scale, 12 * Scale, 8 * Scale, 5 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2 + 3 * Bool(VKey = #VK_MBUTTON))))
			FillPath(#PB_Path_Winding)
			
		Else
			VectorFont(General::TitleFont, 30 * Scale)
			
			General::AddPathRoundedBox((*WindowData\Offset) * Scale, 0, VKeyData(VKey)\Width * Scale, 60 * Scale, 7 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_0)))
			FillPath()
			
			General::AddPathRoundedBox((*WindowData\Offset + 4) * Scale, 4 * Scale, (VKeyData(VKey)\Width - 8) * Scale, 52 * Scale, 4 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_1)))
			FillPath()
			
			General::AddPathRoundedBox((*WindowData\Offset + 7) * Scale, 7 * Scale, (VKeyData(VKey)\Width - 14) * Scale, 46 * Scale, 2 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_2)))
			FillPath()
			
			General::AddPathRoundedBox((*WindowData\Offset + 10) * Scale, 10 * Scale, (VKeyData(VKey)\Width - 20) * Scale, 40 * Scale, 2 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_3)))
			FillPath()
			
			MovePathCursor((*WindowData\Offset + VKeyData(VKey)\Offset - 10)  * Scale, 15  * Scale)
			
			VectorSourceColor(General::SetAlpha(255, General::ColorScheme(General::Preferences(General::#Pref_DarkMode), General::#Color_Keyboard_4)))
			DrawVectorText(VKeyData(VKey)\Text)
			
			FillPath()
		EndIf
		StopVectorDrawing()
		
		If IsImage(*WindowData\Image)
			FreeImage(*WindowData\Image)
		EndIf
		
		*WindowData\Image = CopyImage(*WindowData\OriginalImage, #PB_Any)
		*WindowData\ImageID = ImageID(*WindowData\Image)
		*WindowData\Offset + VKeyData(VKey)\Width + 5
		*WindowData\Vkey + VKey
		InitAlphaBlening(*WindowData)
	EndProcedure
	;}
EndModule
; IDE Options = PureBasic 6.00 Beta 9 (Windows - x64)
; CursorPosition = 677
; FirstLine = 114
; Folding = BEIw
; EnableXP