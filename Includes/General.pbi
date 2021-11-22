DeclareModule General
	#AppName = "Inputify"
	#Version = 0.1
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
; CursorPosition = 8
; Folding = 4
; EnableXP