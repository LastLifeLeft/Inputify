﻿IncludePath "UI-Toolkit/Library"
IncludeFile "UI-Toolkit.pbi"

IncludePath "MarkDownModule"
IncludeFile "MarkDownModule.pbi"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "PopupWindow.pbi"

CompilerIf #PB_Compiler_32Bit
	CompilerError "32 bits isn't supported"
CompilerEndIf

General::Init()
MainWindow::Open()

Repeat
	WaitWindowEvent()
ForEver
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 14
; Folding = +
; EnableXP