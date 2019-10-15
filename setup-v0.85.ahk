#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Version := 0.85


; Menu, Tray, icon, C:\TC\BIN\Eggplant.ico
Gui, Font, S12 CDefault, Verdana
Gui, Add, Text, x12 y59 w490 h80 , Eggplant DOSBox is a simple tool`, allowing you to compile and run asm files directly from your Notepad++.`n`nPlease choose your DOSBox version:
Gui, Font, S18 CDefault, Verdana
Gui, Add, Text, x32 y9 w450 h40 +Center, Welcome to Eggplant DOSBox!
Gui, Add, Button, Default x187 y209 w140 h50 gINSTALL, Install
Gui, Add, Button, x207 y269 w100 h40 gCANCEL, Cancel
Gui, Add, Button, x217 y319 w80 h30 gAbout, About
Gui, Add, ListBox, x164 y139 w190 h62 +Center vVersion, 0.74||0.74-2
; Generated using SmartGUI Creator for SciTE
Gui, Show, w523 h378, Eggplant DOSBox Installter v%Version%
return

INSTALL:
Gui, Submit, NoHide
GuiControlGet, Version
FileInstall, C:\Users\elnns\Google Drive\לימודים\סמסטר 2\אתמ\EggplantDOSBox\v0.85\EggplantDOSBox.exe, C:\TC\BIN\EggplantDOSBox.exe, 1
FileInstall, C:\TC\BIN\Eggplant.ico, C:\TC\BIN\Eggplant.ico
FileInstall, c:\TC\BIN\EggplantDOSBox_Logo.png, c:\TC\BIN\EggplantDOSBox_Logo.png
sleep 100
FileCreateShortcut, C:\TC\BIN\EggplantDOSBox.exe, %A_Desktop%\EggplantDOSBox.lnk,,,,C:\TC\BIN\Eggplant.ico

FileInstall, C:\Users\elnns\Google Drive\לימודים\סמסטר 2\אתמ\EggplantDOSBox\v0.85\shortcuts.xml, %A_AppData%\notepad++\shortcuts.xml, 1
FileInstall, C:\Users\elnns\Google Drive\לימודים\סמסטר 2\אתמ\EggplantDOSBox\v0.85\ReadMe.txt, %A_WorkingDir%\ReadMe.txt

if Version = 0.74
	FileInstall, C:\Users\elnns\Google Drive\לימודים\סמסטר 2\אתמ\EggplantDOSBox\v0.85\dosbox-0.74.conf, C:\Users\%A_UserName%\AppData\Local\DOSBox\dosbox-0.74.conf, 1
if Version = 0.74-2
	FileInstall, C:\Users\elnns\Google Drive\לימודים\סמסטר 2\אתמ\EggplantDOSBox\v0.85\dosbox-0.74.conf, C:\Users\%A_UserName%\AppData\Local\DOSBox\dosbox-0.74-2.conf, 1

FileCreateDir, C:\TC\BIN\SCRIPTS
sleep 500

Msgbox,
(
Done!

Use Instractions:

	- Open Eggplant DOSBox or Press Alt+F5 on Notepad++
	- Choose file\s to run
	
Created by Elchanan Shuky Shukrun
Ort Braude College of Engineering
elnn.sh@gmail.com
2018
Source code available by request
)
Run, %A_WorkingDir%\ReadMe.txt
ExitApp

ABOUT:
Msgbox,, Eggplant DOSBox v%Version%,
(
Created by Elchanan Shuky Shukrun
Ort Braude College of Engineering
elnn.sh@gmail.com
2018
Source code available by request
)
return

CANCEL:
GuiClose:
GuiEscape:
ExitApp