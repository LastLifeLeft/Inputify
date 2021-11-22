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
	
	#Window_Width = 230
	#Window_Height = 80
	#Window_MovementTarget = 10 + #Window_Height
	
	#ApparitionDelay = 100											; Delay until the window start appearing
	
	Structure WindowData
		Window.i
		WindowID.i
		MovementTarget.l
		OriginalPosition.l
		CurrentPosition.l
		MovementStep.l
		FadeStep.l
		X.l
		Hold.b
	EndStructure
	
	ExamineDesktops()
	Global WindowDuration = 1200									; The time left to a window once its key has been released
	Global FrameDuration = 33										; The duration of a movement frame. 33ms =~ two frames on a 60fps screen
	Global FrameCount = 9											; The number of step in a movement animation.
	Global OriginX													; The horizontal apparition spot of a new window
	Global OriginY = DesktopHeight(0) - #Window_Height				; The vertical apparition spot of a new window
	Global NewList WindowList.WindowData()
	
	; Private procedures declaration
	Declare HandlerTimer()
	Declare.d Ease_CubicOut(Time.d, Original.d, Target.d, Duration.d)
	Declare.d Ease_CubicIn(Time.d, Original.d, Target.d, Duration.d)
	
	;{ Public procedures
	Procedure Create(VKey)
		Protected Window, Count
		
		; Move the other windows up.
		ForEach WindowList()
			If WindowList()\Hold
				Count + 1
			Else
				WindowList()\OriginalPosition = WindowList()\CurrentPosition
				WindowList()\MovementTarget - #Window_MovementTarget
				WindowList()\MovementStep = 0
				AddWindowTimer(WindowList()\Window, #Timer_Movement, FrameDuration)
			EndIf
		Next
		
		Window = OpenWindow(#PB_Any, OriginX, OriginY - Count * #Window_MovementTarget, #Window_Width, #Window_Height, "Input", #PB_Window_Invisible | #PB_Window_BorderLess, MainWindow::WindowID)
		
		If Window
			; Set up the window data
			SetWindowData(Window, AddElement(WindowList()))
			WindowList()\Window = Window
			WindowList()\WindowID = WindowID(Window)
			WindowList()\CurrentPosition = OriginY - Count * #Window_MovementTarget
			WindowList()\MovementTarget = WindowList()\CurrentPosition
			WindowList()\X = OriginX
			WindowList()\Hold = #True
			
			StickyWindow(Window, #True)
			SetWindowLongPtr_(WindowList()\WindowID,#GWL_EXSTYLE,#WS_EX_LAYERED)
			SetLayeredWindowAttributes_(WindowList()\WindowID,0,0,#LWA_ALPHA)
			HideWindow(Window, #False)
			BindEvent(#PB_Event_Timer, @HandlerTimer(), Window)
			
			; Delay the apparition (helps for Hold and Combo)
			AddWindowTimer(Window, #Timer_Apparition, #ApparitionDelay)
		EndIf
		
		ProcedureReturn Window
	EndProcedure
	
	Procedure Hide(Window)
		Protected *WindowData.WindowData = GetWindowData(Window)
		
 		AddWindowTimer(Window, #Timer_Duration, WindowDuration + (FrameCount - *WindowData\MovementStep) * FrameDuration)
		*WindowData\Hold = #False
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure HandlerTimer()
		Protected Window = EventWindow()
		Protected *WindowData.WindowData = GetWindowData(Window)
		
		Select EventTimer()
			Case #Timer_Duration
				AddWindowTimer(Window, #Timer_FadeOutAnimation, FrameDuration)
				
			Case #Timer_FadeInAnimation
				*WindowData\FadeStep + 1
				
				If *WindowData\FadeStep = 7
					SetLayeredWindowAttributes_(*WindowData\WindowID,0,255,#LWA_ALPHA)
					RemoveWindowTimer(Window, #Timer_FadeInAnimation)
				Else
					SetLayeredWindowAttributes_(*WindowData\WindowID,0,Ease_CubicOut(*WindowData\FadeStep, 0, 255, 7),#LWA_ALPHA)
				EndIf
				
			Case #Timer_FadeOutAnimation
				*WindowData\FadeStep - 1
				
				If *WindowData\FadeStep = 0
					Protected Y = *WindowData\CurrentPosition
					UnbindEvent(#PB_Event_Timer, @HandlerTimer(), Window)
					ChangeCurrentElement(WindowList(), GetWindowData(Window))
					DeleteElement(WindowList())
					
					While NextElement(WindowList()) ; Check if later objects should be moved back down.
						If WindowList()\CurrentPosition < Y
							WindowList()\OriginalPosition = WindowList()\CurrentPosition
							WindowList()\MovementTarget + #Window_MovementTarget
							WindowList()\MovementStep = 0
							AddWindowTimer(WindowList()\Window, #Timer_Movement, FrameDuration)
						EndIf
					Wend
					
					CloseWindow(Window)
				Else
					SetLayeredWindowAttributes_(*WindowData\WindowID,0,Ease_CubicIn(*WindowData\FadeStep, 0, 255, 7),#LWA_ALPHA)
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
				
				SetWindowPos_(*WindowData\WindowID, 0, *WindowData\X, *WindowData\CurrentPosition, 0, 0, #SWP_NOSIZE|#SWP_NOZORDER)
				
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
	
	;}
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 119
; FirstLine = 70
; Folding = -9
; EnableXP