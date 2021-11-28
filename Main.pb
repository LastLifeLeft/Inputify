IncludePath "Libraries"
IncludeFile "FlatMenu/FlatMenu.pbi"

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "PopupWindow.pbi"

General::Init()
MainWindow::Open()

Repeat
	WaitWindowEvent()
ForEver
; IDE Options = PureBasic 6.00 Beta 1 (Windows - x64)
; CursorPosition = 8
; EnableXP