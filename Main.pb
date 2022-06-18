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
; IDE Options = PureBasic 6.00 Beta 9 (Windows - x64)
; CursorPosition = 1
; EnableXP