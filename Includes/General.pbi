DeclareModule General
	; Public variables, structures and constants
	#AppName = "Inputify"
	#Version = 0.9
	#Event_Update = UITK::#Event_FirstAvailableCustomValue
	
	;{ Colors
	Enumeration ; Colors type
		#Color_Type_BackCold
		#Color_Type_BackHot 
		#Color_Type_FrontCold
		#Color_Type_FrontHot
		#Color_Type_Trackbar
		#Color_Type_ToggleOff
		#Color_Type_ToggleOn
		#Color_Type_ToggleFront
		
		#_Color_Type_COUNT
	EndEnumeration
	
	Enumeration ; Key colors
		#Color_Keyboard_0
		#Color_Keyboard_1
		#Color_Keyboard_2
		#Color_Keyboard_3
		#Color_Keyboard_4
		#Color_Mouse
		
		#_KeyColor_Type_COUNT
	EndEnumeration
	
	Enumeration ; Color scheme name
		#Scheme_Dark
		#Scheme_Light
		#Scheme_Pink
		#Scheme_Blue
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
	Global Dim KeyScheme(3, #_KeyColor_Type_COUNT - 1)
	
	ColorScheme(#Color_Mode_Light, #Color_Type_BackCold) 		= SetAlpha(255, FixColor($F2F3F5))
	ColorScheme(#Color_Mode_Light, #Color_Type_BackHot )		= SetAlpha(255, FixColor($D4D7DC))
	ColorScheme(#Color_Mode_Light, #Color_Type_FrontCold)		= SetAlpha(255, FixColor($6A7480))
	ColorScheme(#Color_Mode_Light, #Color_Type_FrontHot)		= SetAlpha(255, FixColor($000000))
	ColorScheme(#Color_Mode_Light, #Color_Type_Trackbar)		= SetAlpha(255, FixColor($CCCDCE))
	
	ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOff)		= SetAlpha(255, FixColor($72767D))
	ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOn)		= SetAlpha(255, FixColor($3AA55D))
	ColorScheme(#Color_Mode_Light, #Color_Type_ToggleFront)		= SetAlpha(255, FixColor($FFFFFF))
	
	ColorScheme(#Color_Mode_Dark, #Color_Type_BackCold) 		= SetAlpha(255, FixColor($2F3136))
	ColorScheme(#Color_Mode_Dark, #Color_Type_BackHot )			= SetAlpha(255, FixColor($393C43))
	ColorScheme(#Color_Mode_Dark, #Color_Type_FrontCold)		= SetAlpha(255, FixColor($8E9297))
	ColorScheme(#Color_Mode_Dark, #Color_Type_FrontHot)			= SetAlpha(255, FixColor($FFFFFF))
	ColorScheme(#Color_Mode_Dark, #Color_Type_Trackbar)			= SetAlpha(255, FixColor($4F545C))
	
	ColorScheme(#Color_Mode_Dark, #Color_Type_ToggleOff)		= ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOff)		
	ColorScheme(#Color_Mode_Dark, #Color_Type_ToggleOn)			= ColorScheme(#Color_Mode_Light, #Color_Type_ToggleOn)		
	ColorScheme(#Color_Mode_Dark, #Color_Type_ToggleFront)		= ColorScheme(#Color_Mode_Light, #Color_Type_ToggleFront)		
	
	KeyScheme(#Scheme_Dark, #Color_Keyboard_0)					= SetAlpha(255, FixColor($1D1D1D))
	KeyScheme(#Scheme_Dark, #Color_Keyboard_1)					= SetAlpha(255, FixColor($353535))
	KeyScheme(#Scheme_Dark, #Color_Keyboard_2)					= SetAlpha(255, FixColor($696969))
	KeyScheme(#Scheme_Dark, #Color_Keyboard_3)					= SetAlpha(255, FixColor($595959))
	KeyScheme(#Scheme_Dark, #Color_Keyboard_4)					= SetAlpha(255, FixColor($CDCDCD))
	KeyScheme(#Scheme_Dark, #Color_Mouse)						= SetAlpha(255, FixColor($CDCDCD))
	                                                
	KeyScheme(#Scheme_Light, #Color_Keyboard_0)					= SetAlpha(255, FixColor($404040))
	KeyScheme(#Scheme_Light, #Color_Keyboard_1)					= SetAlpha(255, FixColor($D7D7D7))
	KeyScheme(#Scheme_Light, #Color_Keyboard_2)					= SetAlpha(255, FixColor($FFFFFF))
	KeyScheme(#Scheme_Light, #Color_Keyboard_3)					= SetAlpha(255, FixColor($F5F5F5))
	KeyScheme(#Scheme_Light, #Color_Keyboard_4)					= SetAlpha(255, FixColor($414141))
	KeyScheme(#Scheme_Light, #Color_Mouse)						= SetAlpha(255, FixColor($E02727))
	                                                
	KeyScheme(#Scheme_Pink, #Color_Keyboard_0)					= SetAlpha(255, FixColor($e0218a))
	KeyScheme(#Scheme_Pink, #Color_Keyboard_1)					= SetAlpha(255, FixColor($ed5c9b))
	KeyScheme(#Scheme_Pink, #Color_Keyboard_2)					= SetAlpha(255, FixColor($f7b9d7))
	KeyScheme(#Scheme_Pink, #Color_Keyboard_3)					= SetAlpha(255, FixColor($f18dbc))
	KeyScheme(#Scheme_Pink, #Color_Keyboard_4)					= SetAlpha(255, FixColor($FFFFFF))
	KeyScheme(#Scheme_Pink, #Color_Mouse)						= SetAlpha(255, FixColor($ed5c9b))
	                                                
	KeyScheme(#Scheme_Blue, #Color_Keyboard_0)					= SetAlpha(255, FixColor($2153DF))
	KeyScheme(#Scheme_Blue, #Color_Keyboard_1)					= SetAlpha(255, FixColor($5C71EC))
	KeyScheme(#Scheme_Blue, #Color_Keyboard_2)					= SetAlpha(255, FixColor($B8C4F6))
	KeyScheme(#Scheme_Blue, #Color_Keyboard_3)					= SetAlpha(255, FixColor($8C9FF0))
	KeyScheme(#Scheme_Blue, #Color_Keyboard_4)					= SetAlpha(255, FixColor($FFFFFF))
	KeyScheme(#Scheme_Blue, #Color_Mouse)						= SetAlpha(255, FixColor($5C71EC))
	
	;}
	
	;{ Fonts
	Global OptionFont = FontID(LoadFont(#PB_Any, "Calibry", 9, #PB_Font_HighQuality))
	Global TitleFont = FontID(LoadFont(#PB_Any, "Calibry", 9, #PB_Font_HighQuality | #PB_Font_Bold))
	;}
	
	;{ Preferences
	Enumeration
		#Pref_DarkMode
		#Pref_Scale
		#Pref_TrackMouse
		#Pref_Keyboard
		#Pref_Duration
		#Pref_Combo
		#Pref_CheckUpdate
		#Pref_InputColor
		
		#_Pref_COUNT
	EndEnumeration
	
	Global Dim Preferences(#_Pref_COUNT - 1)
	Global FirstStart, PreferenceFile.s
	;}
	
	Declare Init()
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
	UsePNGImageDecoder()
	
	Procedure UpdateThread(Null)
		Protected Text.s, URL.s, HTTPRequest, LineCount, Loop
		HTTPRequest = HTTPRequest(#PB_HTTP_Get, "https://github.com/LastLifeLeft/Inputify/releases/latest")
		
		If HTTPRequest
			Text.s = HTTPInfo(HTTPRequest, #PB_HTTP_Headers)
			LineCount = CountString(Text, #CRLF$)
			
			For loop = 1 To LineCount
				If StringField(StringField(Text, loop, #CRLF$), 1, ":") = "Location"
					URL.s = StringField(StringField(Text, loop, #CRLF$), 2, "Location:")
					If ValF(StringField(URL, CountString(URL, "/") + 1, "/")) > #Version
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
	
	Procedure Init()
		Protected AppData.s = GetEnvironmentVariable("APPDATA"), CurrentDirectory.s = GetCurrentDirectory()
		
		If FileSize(CurrentDirectory + "Preference.ini") > 0 Or LCase(ProgramParameter()) = "-portable"
			PreferenceFile = CurrentDirectory + "Preference.ini"
		Else
			If FileSize(AppData + "/❤x1/Inputify/Preference.ini") = -1
				CreateDirectory(AppData + "/❤x1")
				CreateDirectory(AppData + "/❤x1/Inputify")
				FirstStart = #True
			EndIf
			PreferenceFile = AppData + "/❤x1/Inputify/Preference.ini"
		EndIf
		
		OpenPreferences(PreferenceFile)
		
		PreferenceGroup("Appearance")
		Preferences(#Pref_DarkMode) = ReadPreferenceLong("DarkMode", #Color_Mode_Dark)
		Preferences(#Pref_Scale) = ReadPreferenceLong("Scale", 100)
		Preferences(#Pref_InputColor) = ReadPreferenceLong("InputColor", #Scheme_Dark)
		
		PreferenceGroup("Behavior")
		Preferences(#Pref_Keyboard) = ReadPreferenceLong("Keyboard", #True)
		Preferences(#Pref_TrackMouse) = ReadPreferenceLong("Mouse", #False)
		Preferences(#Pref_Duration) = ReadPreferenceLong("Duration", 1200)				
		Preferences(#Pref_Combo) = ReadPreferenceLong("Combo", #True)
		
		PreferenceGroup("Misc")
		Preferences(#Pref_CheckUpdate) = ReadPreferenceLong("Update", #True)
		
		ClosePreferences()
		
		PopupWindow::SetScale(Preferences(#Pref_Scale))
		
		If Preferences(#Pref_CheckUpdate)
			CreateThread(@UpdateThread(), #Null)
		EndIf
		
		InitJoystick()
		
	EndProcedure
EndModule
; IDE Options = PureBasic 6.00 Beta 10 (Windows - x64)
; CursorPosition = 209
; FirstLine = 1
; Folding = 60+
; EnableXP