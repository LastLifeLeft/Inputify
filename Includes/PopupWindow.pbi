Module PopupWindow
	EnableExplicit
	; Private variables, structures and constants
	Enumeration ;Timer
		#Timer_Duration
		#Timer_Animation
		#Timer_Movement
	EndEnumeration
	
	#Window_Width = 230
	#Window_Height = 80
	
	Structure WindowData
		Target.i
		AnimationDuration.l
		AnimationSterp.l
	EndStructure
	
	ExamineDesktops()
	Global WindowDuration = 1200									; The time left to a window once its key has been released
	Global AnimationDuration = 250									; The fade in/out animation duration
	Global OriginX													; The horizontal apparition spot of a new window
	Global OriginY = DesktopHeight(0) - #Window_Height				; The vertical apparition spot of a new window
	
	; Private procedures declaration
	Declare HandlerTimer()
	
	;{ Public procedures
	Procedure Create(VKey)
		Protected Window
		
		Window = OpenWindow(#PB_Any, OriginX, OriginY, #Window_Width, #Window_Height, "Input", #PB_Window_Invisible | #PB_Window_BorderLess)
		AnimateWindow_(WindowID(Window), AnimationDuration, #AW_BLEND)
		
		ProcedureReturn Window
	EndProcedure
	
	Procedure Hide(Window)
		AddWindowTimer(Window, #Timer_Duration, WindowDuration)
		BindEvent(#PB_Event_Timer, @HandlerTimer(), Window)
	EndProcedure
	;}
	
	;{ Private procedures
	Procedure HandlerTimer()
		Protected Window = EventWindow(), Timer = EventTimer()
		
		If Timer = #Timer_Duration
			AnimateWindow_(WindowID(Window), AnimationDuration, #AW_BLEND | #AW_HIDE)
			AddWindowTimer(Window, #Timer_Animation, AnimationDuration)
		ElseIf Timer = #Timer_Animation
			UnbindEvent(#PB_Event_Timer, @HandlerTimer(), Window)
			CloseWindow(Window)
		Else
			
		EndIf
	EndProcedure
	;}
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 58
; Folding = --
; EnableXP