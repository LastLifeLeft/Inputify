IncludePath "MarkDownModule"
IncludeFile "MarkDownModule.pbi"

IncludePath "UI-Toolkit/Library"
IncludeFile "UI-Toolkit.pbi"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "PopupWindow.pbi"

General::Init()
MainWindow::Open()

Repeat
	WaitWindowEvent()
ForEver
; IDE Options = PureBasic 6.00 Beta 10 (Windows - x64)
; CursorPosition = 12
; EnableXP