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

General::Init()
MainWindow::Open()

Repeat
	WaitWindowEvent()
ForEver
; IDE Options = PureBasic 6.21 Beta 10 (Windows - x64)
; CursorPosition = 13
; Folding = -
; EnableXP