Module PopupWindow
	EnableExplicit
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
		UseModule VK
	CompilerEndIf
	;{ Private variables, structures and constants
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
	
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS					; Widths are measured in Init(): these labels are Mac only
		VKeyData(#VK_MENU)\Text = "⌥ Opt"
		VKeyData(#VK_LWIN)\Text = "⌘ Cmd"
		VKeyData(#VK_LWIN)\Offset = 24
	CompilerEndIf
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
		Moving.b													; Set while the window is being pushed to a new slot, so the shared mover can skip settled windows.
		FadeStep.a
		X.l
		Status.b
		Height.l
		Width.l
		Vkey.l
		Offset.i
		Image.i
		CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
			Layer.i												; The content view's CALayer, which shows the popup image
		CompilerEndIf
		OriginalImage.i												; We must keep a copy of the original image for proper alphablending calculation down the line.
		ImageID.i
		Alpha.a
		Combo.a
	EndStructure
	
	Global FrameDuration = 31										; The duration of a movement frame. Windows quantises timers to the ~15.6ms tick, so a 33ms
																	; timer really fires every 46.9ms (21fps); 31 lands on the 2nd tick = 31.25ms (32fps).
	Global FrameCount = 9											; The number of step in a movement animation.
	Global OriginX, OriginY											; The apparition coordinates of a new window
	Global WindowWidth = #Window_Width
	Global WindowHeight = #Window_Height
	Global Window_MovementTarget = WindowHeight + 10
	Global Scale.d = 1
	Global *LatestWindow.WindowData = 0
	Global MovementWindow, MovementActive							; A single hidden window drives the movement of every popup at once (see HandlerMovement).
	Global NewList WindowList.WindowData()
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		Global Dim Preprocess.f($FF), Blend.BLENDFUNCTION, Image_BitmapInfo.BITMAPINFO, ContextOffset.POINT
	CompilerElse
		Global PixelRatio.d = 1										; Positions and sizes stay in pixels as on Windows, but Cocoa places windows in points.
	CompilerEndIf
	
	; Private procedures declaration
	Declare HandlerTimer()
	Declare HandlerMovement()
	Declare StartMovement()
	Declare.d Ease_CubicOut(Time.d, Original.d, Target.d, Duration.d)
	Declare.d Ease_CubicIn(Time.d, Original.d, Target.d, Duration.d)
	Declare Init()
	Declare ReleaseModifiers(Window, KeepVkey)
	Declare InitAlphaBlening(*WindowData.WindowData)
	Declare SetAlpha(*WindowData.WindowData)
	Declare DrawKey(VKey, *WindowData.WindowData)
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
		Declare PlaceWindow(*WindowData.WindowData)
	CompilerEndIf
	
	Init()
	;}
	
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
			
			UITK::AddPathRoundedBox((*LatestWindow\Offset) * Scale, 12 * Scale, 30 * Scale + VectorTextWidth("x"+*LatestWindow\Combo), 36 * Scale, 4 * Scale)
			VectorSourceColor(General::SetAlpha(255, General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_3)))
			FillPath()
			
			VectorSourceColor(General::SetAlpha(255, General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_4)))
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
				WindowList()\Moving = #True
			Next
			
			StartMovement()
			
			CompilerIf #PB_Compiler_OS = #PB_OS_Windows
				Window = OpenWindow(#PB_Any, 0, 0, WindowWidth, WindowHeight, General::#AppName, #PB_Window_Invisible | #PB_Window_BorderLess | #PB_Window_NoActivate | #PB_Window_NoGadgets, MainWindow::WindowID)
			CompilerElse ; No owner: a Cocoa child window drags its parent on screen, and moves with it.
				Window = OpenWindow(#PB_Any, OriginX / PixelRatio, OriginY / PixelRatio, WindowWidth / PixelRatio, WindowHeight / PixelRatio, General::#AppName, #PB_Window_Invisible | #PB_Window_BorderLess | #PB_Window_NoActivate | #PB_Window_NoGadgets)
			CompilerEndIf
			
			If Window
				DisableWindow(Window, #True)
				
				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
					; The origin and every later move are in SetWindowPos_ units (pixels in a DPI aware build), while
					; OpenWindow takes points: opened at the origin, a popup lands 25% lower at 125% scaling, below the
					; screen, and only shows up once the next input pushes it into view.
					SetWindowPos_(WindowID(Window), 0, OriginX, OriginY, 0, 0, #SWP_NOSIZE | #SWP_NOZORDER | #SWP_NOACTIVATE)
				CompilerEndIf
				
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
				
				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
					; #PB_Window_NoActivate only applies to the initial show, it isn't a persistent style, so the popup
					; stays activable for its whole life. #WS_EX_NOACTIVATE is what actually keeps it out of the
					; activation chain, and #WS_EX_TRANSPARENT stops a click on the key art from activating the owner.
					SetWindowLongPtr_(*LatestWindow\WindowID, #GWL_EXSTYLE, GetWindowLongPtr_(*LatestWindow\WindowID, #GWL_EXSTYLE) | #WS_EX_LAYERED | #WS_EX_NOACTIVATE | #WS_EX_TOOLWINDOW | #WS_EX_TRANSPARENT)
				CompilerElse
					; A clear, shadowless, click-through window above everything, on every Space and over full screen apps.
					CocoaMessage(0, *LatestWindow\WindowID, "setCollectionBehavior:", 1 | 16 | 64 | 256)	; CanJoinAllSpaces | Stationary | IgnoresCycle | FullScreenAuxiliary
					*LatestWindow\Layer = ImageLayer(*LatestWindow\WindowID)
					SetAlpha(*LatestWindow)
				CompilerEndIf
				
				SetWindowData(Window, *LatestWindow)
				
				DrawKey(VKey, *LatestWindow)
				
				StickyWindow(Window, #True)
				CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
					CocoaMessage(0, *LatestWindow\WindowID, "setLevel:", 101)	; NSPopUpMenuWindowLevel, StickyWindow's floating level sits below other apps' panels
				CompilerEndIf
				BindEvent(#PB_Event_Timer, @HandlerTimer(), Window)
				
				; Set up the alpha blending
				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
					HideWindow(Window, #False, #PB_Window_NoActivate)
				CompilerElse
					CocoaMessage(0, *LatestWindow\WindowID, "orderFrontRegardless")	; Shown without activating Inputify: the user's app keeps the keyboard
				CompilerEndIf
				
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
		CompilerIf #PB_Compiler_OS = #PB_OS_MacOS					; Given in points, like everything Cocoa answers
			X * PixelRatio
			Y * PixelRatio
		CompilerEndIf
		OriginX = X
		OriginY = Y - WindowHeight
	EndProcedure
	
	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
		Procedure.d PixelRatio()
			ProcedureReturn PixelRatio
		EndProcedure
	CompilerEndIf
	
	Procedure ShortCut(Control, Shift, Alt, Command, Vkey)
		; Held: the modifiers other than Vkey, as the sum a popup showing them carries. All: every held modifier.
		; Command is the Mac's own modifier, never set on Windows.
		Protected Held = (Control * Bool(Not Vkey = #VK_CONTROL)) * #VK_CONTROL + (Shift * Bool(Not Vkey = #VK_SHIFT)) * #VK_SHIFT + (Alt * Bool(Not Vkey = #VK_MENU)) * #VK_MENU + (Command * Bool(Not Vkey = #VK_LWIN)) * #VK_LWIN
		Protected All = Control * #VK_CONTROL + Shift * #VK_SHIFT + Alt * #VK_MENU + Command * #VK_LWIN
		
		If *LatestWindow And *LatestWindow\Status < #Dying
			If (General::Preferences(General::#Pref_Combo) Or (*LatestWindow And *LatestWindow\Vkey = Held)) ; Yeah, unreadable condition (╯°□°）╯︵ ┻━┻
				If *LatestWindow\Vkey = Held And *LatestWindow\Combo = 1
					ReleaseModifiers(*LatestWindow\Window, Vkey)
					MainWindow::InputArray(Vkey) = *LatestWindow\Window

					AddKey(*LatestWindow\Window, Vkey)
					
					ProcedureReturn #False
				ElseIf *LatestWindow\Vkey = All + Vkey
					Create(*LatestWindow\Vkey)
					MainWindow::InputArray(Vkey) = *LatestWindow\Window
					
					ProcedureReturn #False
				EndIf
			ElseIf Not (*LatestWindow\Vkey > All)
				Create(Held)
				ReleaseModifiers(*LatestWindow\Window, Vkey)
				MainWindow::InputArray(Vkey) = *LatestWindow\Window
				AddKey(*LatestWindow\Window, Vkey)
				ProcedureReturn #False
			Else
				AddWindowTimer(*LatestWindow\Window, #Timer_Duration, General::Preferences(General::#Pref_Duration))
				*LatestWindow = 0
			EndIf
		EndIf
		
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
		
		If Command
			If MainWindow::InputArray(Vkey)
				AddKey(MainWindow::InputArray(Vkey), #VK_LWIN)
			Else
				MainWindow::InputArray(Vkey) = Create(#VK_LWIN)
			EndIf
		EndIf

		; Released only now: until the popups above are built we do not know which window ends up
		; carrying the modifiers, and disowning a slot that holds a different popup would strand it.
		ReleaseModifiers(MainWindow::InputArray(Vkey), Vkey)

		AddKey(MainWindow::InputArray(Vkey), Vkey)
	EndProcedure
	
	Procedure SetScale(NewScale)
		OriginY + WindowHeight
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			Scale = NewScale / 100 * DesktopResolutionX()				; The popups are drawn in pixels: a DPI aware build must scale them itself.
		CompilerElse
			Scale = NewScale / 100 * PixelRatio						; Drawn at the backing scale, so the popups are sharp on a Retina screen.
		CompilerEndIf
		WindowWidth = #Window_Width * Scale
		WindowHeight = (#Window_Height - 20) * Scale
		Window_MovementTarget = (#Window_Height * Scale)
		OriginY - WindowHeight
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure Init()
		Protected Loop
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			For Loop = 0 To $FF
				Preprocess(Loop) = Loop / $FF
			Next
			
			Blend\AlphaFormat = 1
			Blend\BlendOp = 0
			Blend\BlendFlags = 0
			
			Image_BitmapInfo\bmiHeader\biSize = SizeOf(BITMAPINFOHEADER)
			Image_BitmapInfo\bmiHeader\biPlanes = 1
			Image_BitmapInfo\bmiHeader\biBitCount = 32
		CompilerElse
			Protected Screen = CocoaMessage(0, 0, "NSScreen mainScreen")
			If Screen
				CocoaMessage(@PixelRatio, Screen, "backingScaleFactor")
			EndIf
		CompilerEndIf
		
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
		
		CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
			; The widths and offsets above were fitted to the Windows font: a label that outgrows its key gets a wider one.
			Protected Image = CreateImage(#PB_Any, 1, 1, 32, #PB_Image_Transparent)
			StartVectorDrawing(ImageVectorOutput(Image))
			VectorFont(General::TitleFont, 30)
			For Loop = 0 To $FF
				If VKeyData(Loop)\Text <> "" And VKeyData(Loop)\Width < VectorTextWidth(VKeyData(Loop)\Text) + 40
					VKeyData(Loop)\Width = Round(VectorTextWidth(VKeyData(Loop)\Text), #PB_Round_Up) + 40
				EndIf
			Next
			StopVectorDrawing()
			FreeImage(Image)
		CompilerEndIf
	EndProcedure
	
	; A shortcut hands the modifiers over to the popup that displays them, so the modifier slots that
	; pointed at that popup must be cleared - otherwise releasing Ctrl and then the letter would hide
	; the same window twice. Only that window may be disowned though: a slot holding a *different*
	; popup (Shift or Alt pressed before Ctrl, so it never became *LatestWindow) has to keep its owner.
	; Nothing else would ever release it - only Hide() arms #Timer_Duration - and it would stay on
	; screen until Inputify quits. KeepVkey guards the slot the caller is about to take ownership of,
	; since Vkey is itself a modifier when a shortcut is built out of modifiers alone.
	Procedure ReleaseModifiers(Window, KeepVkey)
		If KeepVkey <> #VK_CONTROL And MainWindow::InputArray(#VK_CONTROL) = Window
			MainWindow::InputArray(#VK_CONTROL) = #False
		EndIf

		If KeepVkey <> #VK_SHIFT And MainWindow::InputArray(#VK_SHIFT) = Window
			MainWindow::InputArray(#VK_SHIFT) = #False
		EndIf

		If KeepVkey <> #VK_MENU And MainWindow::InputArray(#VK_MENU) = Window
			MainWindow::InputArray(#VK_MENU) = #False
		EndIf
		
		If KeepVkey <> #VK_LWIN And MainWindow::InputArray(#VK_LWIN) = Window
			MainWindow::InputArray(#VK_LWIN) = #False
		EndIf
	EndProcedure

	CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
	; Makes WindowID a clear, shadowless, click-through window and returns the layer that shows its image, which Core
	; Animation scales from pixels to the window's point size. It must be a sublayer: AppKit owns the content view's own
	; layer and replaces its contents with the view's (empty) drawing when the window is first displayed.
	Procedure ImageLayer(WindowID)
		Protected ContentView = CocoaMessage(0, WindowID, "contentView"), Layer = CocoaMessage(0, 0, "CALayer layer"), Bounds.NSRect
		
		CocoaMessage(0, WindowID, "setOpaque:", #NO)
		CocoaMessage(0, WindowID, "setBackgroundColor:", CocoaMessage(0, 0, "NSColor clearColor"))
		CocoaMessage(0, WindowID, "setHasShadow:", #NO)
		CocoaMessage(0, WindowID, "setIgnoresMouseEvents:", #YES)
		CocoaMessage(0, ContentView, "setWantsLayer:", #YES)
		
		CocoaMessage(@Bounds, ContentView, "bounds")
		CocoaMessage(0, Layer, "setFrame:@", @Bounds)
		CocoaMessage(0, Layer, "setAutoresizingMask:", 2 | 16)		; Width and height sizable
		CocoaMessage(0, CocoaMessage(0, ContentView, "layer"), "addSublayer:", Layer)
		
		ProcedureReturn Layer
	EndProcedure
	
	Procedure InitAlphaBlening(*WindowData.WindowData)
		; Core Animation blends the image itself. The layer retains the NSImage, so it outlives the PB image.
		CocoaMessage(0, *WindowData\Layer, "setContents:", *WindowData\ImageID)
	EndProcedure
	
	Procedure SetAlpha(*WindowData.WindowData)
		Protected Alpha.d = *WindowData\Alpha / 255
		
		CocoaMessage(0, *WindowData\WindowID, "setAlphaValue:@", @Alpha)
	EndProcedure
	
	Procedure PlaceWindow(*WindowData.WindowData)
		Protected Frame.NSRect, Screen = CocoaMessage(0, CocoaMessage(0, 0, "NSScreen screens"), "objectAtIndex:", 0)
		Protected ScreenFrame.NSRect
		
		; Cocoa's origin is the bottom left corner of the main screen, and setFrameOrigin is cheaper than ResizeWindow's
		; full frame update for a window that only moves.
		CocoaMessage(@ScreenFrame, Screen, "frame")
		CocoaMessage(@Frame, *WindowData\WindowID, "frame")
		Frame\origin\x = *WindowData\X / PixelRatio
		Frame\origin\y = ScreenFrame\size\height - *WindowData\CurrentPosition / PixelRatio - Frame\size\height
		CocoaMessage(0, *WindowData\WindowID, "setFrameOrigin:@", @Frame\origin)
	EndProcedure
	CompilerElse
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
		
		; OldDC is the bitmap SelectObject_ displaced, not a DC - only ImageDC must be released.
		SelectObject_(ImageDC, OldDC)
		
		DeleteDC_(ImageDC)
	EndProcedure
	
	Procedure SetAlpha(*WindowData.WindowData)
		Blend\SourceConstantAlpha = *WindowData\Alpha
		
		UpdateLayeredWindow_(*WindowData\WindowID, 0, 0, 0, 0, 0, 0, @Blend, 2)
	EndProcedure
	CompilerEndIf
	
	Procedure HandlerTimer()
		Protected Window = EventWindow(), Loop
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
					
					; A popup can be shared by several held keys (a shortcut), and Hide() through one of them leaves the others
					; pointing at it: releasing one of those after the fade would hide a closed window. The same goes for
					; *LatestWindow when the newest popup dies before older ones.
					For Loop = 0 To 255
						If MainWindow::InputArray(Loop) = Window
							MainWindow::InputArray(Loop) = #False
						EndIf
					Next
					
					If *LatestWindow = *WindowData
						*LatestWindow = 0
					EndIf
					
					ChangeCurrentElement(WindowList(), *WindowData)
					If DeleteElement(WindowList(), #True)
						Repeat  ; Check if later objects should be moved back down.
							If WindowList()\CurrentPosition < Y
								WindowList()\OriginalPosition = WindowList()\CurrentPosition
								WindowList()\MovementTarget + Window_MovementTarget
								WindowList()\MovementStep = 0
								WindowList()\Moving = #True
							EndIf
						Until Not PreviousElement(WindowList())
						
						StartMovement()
					EndIf
					
					CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
						; Moving a window queues an accessibility notification that AppKit posts to it later, while moving
						; another one. Freed at once by CloseWindow, the popup receives it dead and Inputify crashes (with any
						; accessibility client running): the NSWindow is kept alive until the notifications have gone out.
						Protected NSWindow = WindowID(Window), ReleaseDelay.d = 2
						CocoaMessage(0, NSWindow, "retain")
						CocoaMessage(0, NSWindow, "performSelector:", sel_registerName_("release"), "withObject:", #Null, "afterDelay:@", @ReleaseDelay)
					CompilerEndIf
					CloseWindow(Window)
				Else
					
					*WindowData\Alpha = Ease_CubicIn(*WindowData\FadeStep, 0, 255, 7)
					SetAlpha(*WindowData)
				EndIf
				
			Case #Timer_Apparition
				AddWindowTimer(Window, #Timer_FadeInAnimation, FrameDuration)
				RemoveWindowTimer(Window, #Timer_Apparition)
		EndSelect
	EndProcedure
	
	Procedure HandlerMovement()
		Protected hDeferred, StillMoving
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			hDeferred = BeginDeferWindowPos_(ListSize(WindowList()))
		CompilerEndIf
		
		ForEach WindowList()
			If WindowList()\Moving
				WindowList()\MovementStep + 1
				
				If WindowList()\MovementStep = FrameCount
					WindowList()\OriginalPosition = WindowList()\MovementTarget
					WindowList()\CurrentPosition = WindowList()\MovementTarget
					WindowList()\Moving = #False
				Else
					WindowList()\CurrentPosition = Ease_CubicOut(WindowList()\MovementStep, WindowList()\OriginalPosition, WindowList()\MovementTarget, FrameCount)
					StillMoving = #True
				EndIf
				
				CompilerIf #PB_Compiler_OS = #PB_OS_Windows
					; #SWP_NOACTIVATE is mandatory: without it every animation frame activates the popup and
					; steals the foreground from the app the user is typing in.
					If hDeferred
						hDeferred = DeferWindowPos_(hDeferred, WindowList()\WindowID, 0, WindowList()\X, WindowList()\CurrentPosition, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER|#SWP_NOREDRAW|#SWP_NOACTIVATE)
					Else ; The batch could not be created, fall back to moving the popups one by one.
						SetWindowPos_(WindowList()\WindowID, 0, WindowList()\X, WindowList()\CurrentPosition, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER|#SWP_NOREDRAW|#SWP_NOACTIVATE)
					EndIf
				CompilerElse
					PlaceWindow(@WindowList())
				CompilerEndIf
			EndIf
		Next
		
		CompilerIf #PB_Compiler_OS = #PB_OS_Windows
			If hDeferred
				EndDeferWindowPos_(hDeferred)
			EndIf
		CompilerEndIf
		
		If Not StillMoving
			MovementActive = #False
			RemoveWindowTimer(MovementWindow, #Timer_Movement)
		EndIf
	EndProcedure
	
	Procedure StartMovement()
		If Not MovementWindow
			MovementWindow = OpenWindow(#PB_Any, 0, 0, 1, 1, "", #PB_Window_Invisible | #PB_Window_NoActivate)
			BindEvent(#PB_Event_Timer, @HandlerMovement(), MovementWindow)
		EndIf
		
		; Not restarting a running timer: a fast burst of keys would keep resetting it and stall the animation.
		If Not MovementActive
			MovementActive = #True
			AddWindowTimer(MovementWindow, #Timer_Movement, FrameDuration)
		EndIf
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
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_2))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_0))
			StrokePath(4 * Scale)
			
			MovePathCursor((*WindowData\Offset + 27) * Scale, 27 * Scale)
			AddPathLine(-23 * Scale, 0, #PB_Path_Relative)
			AddPathArc(3 * Scale, -22 * Scale, 15 * Scale, -25 * Scale, 10 * Scale, #PB_Path_Relative)
			AddPathLine(13 * Scale, 0, #PB_Path_Relative)
			ClosePath()
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_2 + 3 * Bool(VKey = #VK_LBUTTON)))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_0))
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
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_2))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_0))
			StrokePath(4 * Scale)
			
			MovePathCursor((*WindowData\Offset + 27) * Scale, 27 * Scale)
			AddPathLine(-23 * Scale, 0, #PB_Path_Relative)
			AddPathArc(3 * Scale, -22 * Scale, 15 * Scale, -25 * Scale, 10 * Scale, #PB_Path_Relative)
			AddPathLine(13 * Scale, 0, #PB_Path_Relative)
			ClosePath()
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_2 + 3 * Bool(VKey = #VK_RBUTTON)))
			FillPath(#PB_Path_Preserve)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_0))
			StrokePath(4 * Scale)
			
			RestoreVectorState()
			SaveVectorState()
			
			AddPathCircle(27 * Scale, 12 * Scale, 6 * Scale)
			AddPathCircle(27 * Scale, 19 * Scale, 6 * Scale)
			AddPathBox(21 * Scale, 12 * Scale, 12 * Scale, 7 * Scale)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_0))
			FillPath(#PB_Path_Winding)
			
			AddPathCircle(27 * Scale, 12 * Scale, 4 * Scale)
			AddPathCircle(27 * Scale, 17 * Scale, 4 * Scale)
			AddPathBox(23 * Scale, 12 * Scale, 8 * Scale, 5 * Scale)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_2 + 3 * Bool(VKey = #VK_MBUTTON)))
			FillPath(#PB_Path_Winding)
			
		Else
			VectorFont(General::TitleFont, 30 * Scale)
			
			UITK::AddPathRoundedBox((*WindowData\Offset) * Scale, 0, VKeyData(VKey)\Width * Scale, 60 * Scale, 7 * Scale)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_0))
			FillPath()
			
			UITK::AddPathRoundedBox((*WindowData\Offset + 4) * Scale, 4 * Scale, (VKeyData(VKey)\Width - 8) * Scale, 52 * Scale, 4 * Scale)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_1))
			FillPath()
			
			UITK::AddPathRoundedBox((*WindowData\Offset + 7) * Scale, 7 * Scale, (VKeyData(VKey)\Width - 14) * Scale, 46 * Scale, 2 * Scale)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_2))
			FillPath()
			
			UITK::AddPathRoundedBox((*WindowData\Offset + 10) * Scale, 10 * Scale, (VKeyData(VKey)\Width - 20) * Scale, 40 * Scale, 2 * Scale)
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_3))
			FillPath()
			
			CompilerIf #PB_Compiler_OS = #PB_OS_MacOS					; The fitted offsets centre the Windows font only
				MovePathCursor((*WindowData\Offset + VKeyData(VKey)\Width * 0.5) * Scale - VectorTextWidth(VKeyData(VKey)\Text) * 0.5, 30 * Scale - VectorTextHeight(VKeyData(VKey)\Text) * 0.5)
			CompilerElse
				MovePathCursor((*WindowData\Offset + VKeyData(VKey)\Offset - 10)  * Scale, 15  * Scale)
			CompilerEndIf
			
			VectorSourceColor(General::KeyScheme(General::Preferences(General::#Pref_InputColor), General::#Color_Keyboard_4))
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
; IDE Options = PureBasic 6.40 (Windows - x64)
; CursorPosition = 747
; Folding = BAAA9
; EnableXP