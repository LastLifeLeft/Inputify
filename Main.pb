﻿IncludePath "Libraries"
CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
	IncludeFile "ImagePlugin.pbi"
	
	ImagePlugin::UseSystemImageDecoder()
CompilerElse	
	UsePNGImageDecoder()
CompilerEndIf
IncludeFile "FlatMenu/FlatMenu.pbi"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "PopupWindow.pbi"

MainWindow::Open()

Repeat
	WaitWindowEvent()
ForEver
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 8
; Folding = -
; EnableXP