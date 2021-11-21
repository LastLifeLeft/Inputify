IncludePath "Libraries"
IncludeFile "ImagePlugin.pbi"

ImagePlugin::UseSystemImageDecoder()

IncludePath "Includes"
IncludeFile "General.pbi"
IncludeFile "MainWindow.pbi"
IncludeFile "PopupWindow.pbi"

MainWindow::Open()

Repeat
	WaitWindowEvent()
ForEver
; IDE Options = PureBasic 6.00 Alpha 5 (Windows - x64)
; CursorPosition = 10
; EnableXP