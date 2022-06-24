IncludePath "MarkDownModule"
IncludeFile "MarkDownModule.pbi"

IncludePath "UI-Toolkit/Library"
IncludeFile "UI-Toolkit.pbi"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "PopupWindow.pbi"

CompilerIf #PB_Compiler_32Bit
	CompilerError "32 bits isn't supported"
CompilerEndIf

CompilerIf #PB_Compiler_Backend = #PB_Backend_C
	CompilerError "C backend can't be used until this is fixed : https://www.purebasic.fr/english/viewtopic.php?t=79366 "
CompilerEndIf

General::Init()
MainWindow::Open()

Repeat
	WaitWindowEvent()
ForEver
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 18
; Folding = 9
; EnableXP