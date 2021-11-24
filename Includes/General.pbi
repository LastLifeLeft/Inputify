DeclareModule General
	; Public variables, structures and constants
	#AppName = "Inputify"
	#Version = 0.1
	
	;{ Colors
	Enumeration ; Colors type
		#Color_Type_BackCold
		#Color_Type_BackHot 
		#Color_Type_FrontCold
		#Color_Type_FrontHot
		#Color_Type_FrontDisabled
		#Color_Type_ToggleOff
		#Color_Type_ToggleOn
		#Color_Type_ToggleFront
		#Color_Type_Trackbar
		
		#_Color_Type_COUNT
	EndEnumeration
	
	#Color_Mode_Light = 0
	#Color_Mode_Dark = 1
	
	CompilerIf #PB_Compiler_OS = #PB_OS_Windows
		Macro FixColor(Color)
			RGB(Blue(Color), Green(Color), Red(Color))
		EndMacro
		Macro SetAlpha(Alpha, Color)
			Alpha << 24 + Color
		EndMacro
	CompilerElse
		Macro FixColor(Color)
			Color
		EndMacro
		Macro SetAlpha(Alpha, Color) ; Not tested...
			Color << 8 + Alpha
		EndMacro
	CompilerEndIf
	
	Global Dim ColorScheme(1, #_Color_Type_COUNT - 1)
	
	ColorScheme(#Color_Mode_Light, #Color_Type_BackCold) 		= FixColor($F2F3F5)
	ColorScheme(#Color_Mode_Light, #Color_Type_BackHot )		= FixColor($D4D7DC)
	ColorScheme(#Color_Mode_Light, #Color_Type_FrontCold)		= FixColor($6A7480)
	ColorScheme(#Color_Mode_Light, #Color_Type_FrontHot)		= FixColor($000000)
	ColorScheme(#Color_Mode_Light, #Color_Type_FrontDisabled)	= FixColor($DCDDDE)
	ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOff)		= SetAlpha(255, FixColor($72767D))
	ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOn)		= SetAlpha(255, FixColor($3AA55D))
	ColorScheme(#Color_Mode_Light, #Color_Type_ToggleFront)		= SetAlpha(255, FixColor($FFFFFF))
	ColorScheme(#Color_Mode_Light, #Color_Type_Trackbar) 		= SetAlpha(255, FixColor($5765F2))
	
	ColorScheme(#Color_Mode_Dark, #Color_Type_BackCold) 		= FixColor($2F3136)
	ColorScheme(#Color_Mode_Dark, #Color_Type_BackHot )			= FixColor($393C43)
	ColorScheme(#Color_Mode_Dark, #Color_Type_FrontCold)		= FixColor($8E9297)
	ColorScheme(#Color_Mode_Dark, #Color_Type_FrontHot)			= FixColor($FFFFFF)
	ColorScheme(#Color_Mode_Dark, #Color_Type_FrontDisabled)	= FixColor($4F545C)
	ColorScheme(#Color_Mode_Dark, #Color_Type_ToggleOff)		= ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOff)		
	ColorScheme(#Color_Mode_Dark, #Color_Type_ToggleOn)			= ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOn)		
	ColorScheme(#Color_Mode_Dark, #Color_Type_ToggleFront)		= ColorScheme(#Color_Mode_Light, #Color_Type_ToggleFront)		
	ColorScheme(#Color_Mode_Dark, #Color_Type_Trackbar) 		= ColorScheme(#Color_Mode_Light, #Color_Type_Trackbar) 		
	;}
	
	;{ Fonts
	Global OptionFont = FontID(LoadFont(#PB_Any, "Calibry", 9, #PB_Font_HighQuality))
	Global TitleFont = FontID(LoadFont(#PB_Any, "Calibry", 9, #PB_Font_HighQuality | #PB_Font_Bold))
	;}
	
	;{ Preferences
	Enumeration
		#Pref_DarkMode
		#Pref_Scale
		#Pref_Mouse
		#Pref_Duration
		#Pref_Combo
		#Pref_CheckUpdate
		
		#_Pref_COUNT
	EndEnumeration
	
	Global Dim Preferences(#_Pref_COUNT - 1)
	
	Preferences(#Pref_DarkMode) = #Color_Mode_Dark
	Preferences(#Pref_Scale) = 100
	Preferences(#Pref_Mouse) = #False
	Preferences(#Pref_Duration) = 1200									; The time left to a window once its key has been released
	Preferences(#Pref_Combo) = #True
	Preferences(#Pref_CheckUpdate) = #True
	;}
EndDeclareModule

DeclareModule MainWindow
	; Public variables, structures and constants
	Global WindowID
	
	; Public procedures declaration
	Declare Open()
EndDeclareModule

DeclareModule PopupWindow
	; Public variables, structures and constants
	
	
	; Public procedures declaration
	Declare Create(VKey)
	Declare Hide(Window)
	Declare SetPopupOrigin(X, Y)
EndDeclareModule

Module General
	EnableExplicit
	
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 45
; Folding = H9-
; EnableXP