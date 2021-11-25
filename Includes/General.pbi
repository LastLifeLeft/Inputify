DeclareModule General
	; Public variables, structures and constants
	#AppName = "Inputify"
	#Version = 0.1
	#Event_Update = #PB_Event_FirstCustomValue
	
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
		
		#Color_Keyboard_0
		#Color_Keyboard_1
		#Color_Keyboard_2
		#Color_Keyboard_3
		#Color_Keyboard_4
		
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
	
	ColorScheme(#Color_Mode_Light, #Color_Keyboard_0)			= SetAlpha(255, FixColor($404040))
	ColorScheme(#Color_Mode_Light, #Color_Keyboard_1)			= SetAlpha(255, FixColor($D7D7D7))
	ColorScheme(#Color_Mode_Light, #Color_Keyboard_2)			= SetAlpha(255, FixColor($FFFFFF))
	ColorScheme(#Color_Mode_Light, #Color_Keyboard_3)			= SetAlpha(255, FixColor($F5F5F5))
	ColorScheme(#Color_Mode_Dark, #Color_Keyboard_4)			= SetAlpha(255, FixColor($414141))
	
	ColorScheme(#Color_Mode_Dark, #Color_Type_BackCold) 		= FixColor($2F3136)
	ColorScheme(#Color_Mode_Dark, #Color_Type_BackHot )			= FixColor($393C43)
	ColorScheme(#Color_Mode_Dark, #Color_Type_FrontCold)		= FixColor($8E9297)
	ColorScheme(#Color_Mode_Dark, #Color_Type_FrontHot)			= FixColor($FFFFFF)
	ColorScheme(#Color_Mode_Dark, #Color_Type_FrontDisabled)	= FixColor($4F545C)
	
	ColorScheme(#Color_Mode_Dark, #Color_Type_ToggleOff)		= ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOff)		
	ColorScheme(#Color_Mode_Dark, #Color_Type_ToggleOn)			= ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOn)		
	ColorScheme(#Color_Mode_Dark, #Color_Type_ToggleFront)		= ColorScheme(#Color_Mode_Light, #Color_Type_ToggleFront)		
	ColorScheme(#Color_Mode_Dark, #Color_Type_Trackbar) 		= ColorScheme(#Color_Mode_Light, #Color_Type_Trackbar) 
	
	ColorScheme(#Color_Mode_Dark, #Color_Keyboard_0)			= SetAlpha(255, FixColor($1D1D1D))
	ColorScheme(#Color_Mode_Dark, #Color_Keyboard_1)			= SetAlpha(255, FixColor($353535))
	ColorScheme(#Color_Mode_Dark, #Color_Keyboard_2)			= SetAlpha(255, FixColor($696969))
	ColorScheme(#Color_Mode_Dark, #Color_Keyboard_3)			= SetAlpha(255, FixColor($595959))
	ColorScheme(#Color_Mode_Dark, #Color_Keyboard_4)			= SetAlpha(255, FixColor($CDCDCD))
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
	
	Declare AddPathRoundedBox(x.d, y.d, Width, Height, Radius, Flag = #PB_Path_Default)
	Declare UpdateThread(Null)
EndDeclareModule

DeclareModule MainWindow
	; Public variables, structures and constants
	Global Ctrl, Shift, Alt
	Global WindowID
	Global Dim InputArray.i(255)
	
	; Public procedures declaration
	Declare Open()
EndDeclareModule

DeclareModule PopupWindow
	; Public variables, structures and constants
	
	
	; Public procedures declaration
	Declare Create(VKey)
	Declare Hide(Window)
	Declare SetPopupOrigin(X, Y)
	Declare ShortCut(Control, Shift, Alt, Vkey)
	Declare AddKey(Window, VKey)
	Declare SetScale(NewScale)
EndDeclareModule

Module General
	EnableExplicit
	
	Procedure AddPathRoundedBox(x.d, y.d, Width, Height, Radius, Flag = #PB_Path_Default)
		MovePathCursor(x, y + Radius, Flag)
		
		AddPathArc(0, Height - radius, Width, Height - radius, Radius, #PB_Path_Relative)
		AddPathArc(Width - Radius, 0, Width - Radius, - Height, Radius, #PB_Path_Relative)
		AddPathArc(0, Radius - Height, -Width, Radius - Height, Radius, #PB_Path_Relative)
		AddPathArc(Radius - Width, 0, Radius - Width, Height, Radius, #PB_Path_Relative)
		ClosePath()
	EndProcedure
	
	Procedure UpdateThread(Null)
		Protected Text.s, URL.s, HTTPRequest, LineCount, Loop
		HTTPRequest = HTTPRequest(#PB_HTTP_Get, "https://github.com/LastLifeLeft/Inputify/releases/latest")
		If HTTPRequest
			
			Text.s = HTTPInfo(HTTPRequest, #PB_HTTP_Headers )
			
			LineCount = CountString(Text, #CRLF$)
			
			For loop = 1 To LineCount
				If StringField(StringField(Text, loop, #CRLF$), 1, ":") = "Location"
					URL.s = StringField(StringField(Text, loop, #CRLF$), 2, "Location:")
					If Val(StringField(URL, CountString(URL, "/") + 1, "/")) > #Version
						PostEvent(#Event_Update)
					EndIf
					Break
				EndIf
			Next
			
			FinishHTTP(HTTPRequest)
		Else
			FinishHTTP(HTTPRequest)
		EndIf
	EndProcedure
EndModule
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 172
; Folding = B5+
; EnableXP