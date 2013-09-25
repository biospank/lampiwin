#Include <Constants.au3>
#NoTrayIcon

Opt("TrayMenuMode",2)   ; Default tray menu items (Script Paused/Exit) will not be shown.
Opt("TrayAutoPause",0)
Opt("TrayOnEventMode",1) ; con questa modalita TrayGetMsg() non viene utilizzata
Opt("WinTitleMatchMode", 2)

Global Const $CURRENT_VERSION = 30

; classi windows
Global Const $skype_clsid = "[CLASS:TCallNotificationWindow]" ; Skype
Global Const $camfrog6_ita_title1 = "(Online)" ; Camfrog 6
Global Const $camfrog6_ita_title2 = "(Assente)" ; Camfrog 6
Global Const $camfrog6_eng_title1 = "(Away)" ; Camfrog 6
Global Const $oovoo = "ooVoo.exe" ; ooVoo
Global Const $msn_clsid = "[CLASS:MSBLPopupMsgWClass]" ;  Msn
Global Const $msn_video_call = "[CLASS:IMWindowClass]" ; Msn
Global Const $yahoo_clsid = "[CLASS:YSlidingTrayWnd]" ; Yahoo
Global Const $fb_ita_title = "chiamando" ; Facebook
Global Const $fb_eng_title = "calling" ; Facebook

; create the autostart shortcut
;~ If(FileExists(@StartupCommonDir & "\Lamp.lnk") = 0) Then
;~ 	FileCreateShortcut(@ScriptFullPath, @StartupCommonDir & "\Lamp.lnk")
;~ EndIf

TraySetState()

TraySetIcon("bulb.ico")
TraySetToolTip("Lamp!")

Global $testitem = TrayCreateItem("Test lamp")
TrayItemSetOnEvent($testitem,"Test")

Global $resetitem = TrayCreateItem("Reset")
TrayItemSetOnEvent($resetitem,"Reset")

TrayCreateItem("")

Global $autostartitem = TrayCreateItem("Autostart")
If( FileExists(@StartupDir & '\lamp.lnk') ) Then
	TrayItemSetState($autostartitem, ($TRAY_CHECKED + $TRAY_ENABLE))
Else
	TrayItemSetState($autostartitem, ($TRAY_UNCHECKED + $TRAY_ENABLE))
EndIf
TrayItemSetOnEvent($autostartitem,"Autostart")

;~ If(@Compiled) Then
;~ 	If( Not FileExists(@StartupDir & '\lamp.lnk') ) Then
;~ 		FileCreateShortcut(@AutoItExe, @StartupDir & "\lamp.lnk", @WorkingDir)
;~ 	EndIf
;~ EndIf

sleep(30000)

CheckForUpdates()

; ciclo infinito
While 1
	Sleep(50)

	If(Chiamata()) Then
		
		Notify()
		
		Do
			;MsgBox(4096, "Allora!? ", "sleeping..")
			Sleep(5000)
		Until NotWinPresent()
	EndIf

WEnd

Func ExitScript()
    Exit
EndFunc

Func Test()
	;Local $val = RunWait(@WindowsDir & "\Notepad.exe", @WindowsDir, @SW_MAXIMIZE)
	; script waits until Notepad closes
	;MsgBox(0, "Program returned with exit code:", $val)

    Notify()
	;TrayItemSetState($testitem, ($TRAY_UNCHECKED + $TRAY_ENABLE))
EndFunc

Func Info($val)
	MsgBox(4096, "Error " & $val, "Unable to find Lamp device: check lan cable connection")
EndFunc

Func InfoDownload($val)
	TrayTip("A new version is available", "Please download at: https://dl.dropboxusercontent.com/u/621599/work/Lamp-3.0-setup.exe", 10, 1)
	;MsgBox(4096, "Download ", "A new varsion is available.\nPlease download at: https://dl.dropboxusercontent.com/u/621599/work/Lamp-3.0-setup.exe")
EndFunc

Func Autostart()
  If(TrayItemGetState($autostartitem) = ($TRAY_CHECKED + $TRAY_ENABLE)) Then
		FileCreateShortcut(@AutoItExe, @StartupDir & "\lamp.lnk", @WorkingDir)
	Else
		FileDelete(@StartupDir & "\lamp.lnk")
	EndIf
EndFunc

Func Notify()
	;MsgBox(4096, "Allora!? ", "chiamata")
	Local $val = RunWait(@ComSpec & " /c " & 'lampicli.exe notify_event', "", @SW_HIDE)
	;MsgBox(0, "Program returned with exit code:", $val)
	If($val > 0) Then
		Info($val)
	EndIf
EndFunc

Func Reset()
	;MsgBox(4096, "Allora!? ", "chiamata")
	Local $val = RunWait(@ComSpec & " /c " & 'lampicli.exe reset_event', "", @SW_HIDE)
	;MsgBox(0, "Program returned with exit code:", $val)
	If($val > 0) Then
		Info($val)
	EndIf
EndFunc

Func CheckForUpdates()
	;ConsoleWrite("Checking for updates..." & @CRLF)
	Local $val = RunWait(@ComSpec & " /c " & 'lampicli.exe check_for_updates', "", @SW_HIDE)
	;ConsoleWrite("returned val=" & $val & @CRLF)
	If($val > 0 And $val < 3) Then
		Info($val)
	EndIf

	If($val > 0) Then
		If($val > $CURRENT_VERSION) Then
			InfoDownload($val)
		EndIf
	EndIf
EndFunc

Func Chiamata()
	$present = 0
	$present += WinExists($skype_clsid)
	; camfrog 6.x
	If(WinExists($camfrog6_ita_title1) And BitAnd(WinGetState($camfrog6_ita_title1), 16)) Then
		$present += 1
	EndIf
	If(WinExists($camfrog6_ita_title2) And BitAnd(WinGetState($camfrog6_ita_title2), 16)) Then
		$present += 1
	EndIf
	If(WinExists($camfrog6_eng_title1) And BitAnd(WinGetState($camfrog6_eng_title1), 16)) Then
		$present += 1
	EndIf
	$present += WinExists($fb_ita_title)
	$present += WinExists($fb_eng_title)
	;ooVoo 3.x
	If(OovooRinging()) Then
		$present += 1
	EndIf
	$present += WinExists($msn_clsid)
	;$present += WinExists($msn_video_call)
	$present += WinExists($yahoo_clsid)
	;ConsoleWrite("$present=" & $present & @CRLF)
	Return $present > 0
EndFunc

Func NotWinPresent()
	$present = 0
	$present += WinExists($skype_clsid)
	$present += WinExists($camfrog6_ita_title1)
	$present += WinExists($camfrog6_ita_title2)
	$present += WinExists($camfrog6_eng_title1)
	$present += WinExists($fb_ita_title)
	$present += WinExists($fb_eng_title)
	;ooVoo 3.x
	If(OovooRinging()) Then
		$present += 1
	EndIf
	$present += WinExists($msn_clsid)
	;$present += WinExists($msn_video_call)
	$present += WinExists($yahoo_clsid)
	Return $present = 0
EndFunc

Func OovooRinging()
	If(ProcessExists($oovoo)) Then
		$size = WinGetClientSize("[active]")
		;ConsoleWrite("$size=" & $size[0] & ", " & $size[1] & @CRLF)
		If($size <> 0) Then
			If(($size[0] > 466 And $size[0] < 486) And ($size[1] > 190 And $size[1] < 203)) Then
				Return 1
			EndIf
		EndIf
	EndIf
	Return 0
EndFunc


