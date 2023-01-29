IncludeFile "SDL_For_PB/sdl2/SDL.pbi"
IncludePath "UI-Toolkit/Library"
IncludeFile "UI-Toolkit.pbi"

IncludePath "MarkDownModule"
IncludeFile "MarkDownModule.pbi"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "PopupWindow.pbi"
IncludeFile "LayoutWindow.pbi"

CompilerIf #PB_Compiler_32Bit
	CompilerError "32 bits isn't supported"
CompilerEndIf

General::Init()
MainWindow::Open()

Repeat
	WaitWindowEvent(16)
	MainWindow::SDL_Event()
ForEver
; IDE Options = PureBasic 6.01 LTS beta 1 (Windows - x64)
; Folding = +
; EnableXP