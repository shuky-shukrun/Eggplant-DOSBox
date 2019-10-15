#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#NoTrayIcon
Menu, Tray, icon, C:\TC\BIN\Eggplant.ico
#Include <EggplantDOSBoxLib>
#Include <Check_ForUpdateD>

Version := 0.85

defaultDirPath := "C:\TC\BIN\SCRIPTS"
filesNamesArr := [] ; declare array for files names
nainFile =
dirPath =
mainFile =
flagC =
ModelLarge := false

SetTitleMatchMode, 2 ; make IfWinExist to find notepad++
IfWinExist, Notepad++
{
	WinActivate
	SetKeyboardLayout()
	sleep 200
	dirPath := GetFilePath()
	mainFile := GetFileName(dirPath)
	SplitPath, dirPath,, ScriptFiles
	ScriptFiles = %ScriptFiles%`n%mainFile%
}
SetTitleMatchMode, 1 ; make RunDosbox() ignore folders that contain dosbox on its name

Gui, Font, S16 CDefault Bold, Verdana
Gui, Add, Picture, x0 y30 w450 h476 , c:\TC\BIN\EggplantDOSBox_Logo.png
Gui, Add, Text, x76 y9 w290 h70 +Center, Please choose from the following options:
Gui, Add, Button, x52 y179 w150 h70 Default vCOMPnR gCOMPnR, Compile && Run
Gui, Add, Button, x242 y179 w150 h70 gCOMPnD, Compile && Debug
Gui, Add, Button, x52 y259 w150 h70 vRUN gRUN, Run
Gui, Add, Button, x242 y259 w150 h70 gDEBUG, Debug
Gui, Add, Button, x52 y339 w150 h70 gCOMP, Compile
Gui, Add, Button, x242 y339 w150 h70 gCANCEL, Cancel
Gui, Add, Button, x175 y499 w100 h40 gABOUT, About
Gui, Font, S8 CDefault, Verdana
Gui, Add, Edit, x52 y89 w240 h80 vFilesToRun, 
Gui, Add, Button, x302 y89 w90 h80 gCHOOSE_FILES, Choose Files
Gui, Font, S12 CDefault, Verdana
Gui, Font, S16 CDefault, Verdana
Gui, Add, Button, x150 y419 w150 h70 gUPDATE, Check for updates
; Generated using SmartGUI Creator for SciTE
Gui, Show, w450 h550, Eggplant DOSBox - v%Version%

GuiControlGet, FilesToRun
flagC := ValidateFiles(ScriptFiles, filesNamesArr, dirPath, ModelLarge)
GuiControl,, FilesToRun, %ScriptFiles% ; show the selected files on screen
return

CHOOSE_FILES:
FileSelectFile, ScriptFiles, M1, , , (*.c; *.asm) ; choose multiple files dialog
flagC := ValidateFiles(ScriptFiles, filesNamesArr, dirPath, ModelLarge)
GuiControl,, FilesToRun, %ScriptFiles%
return

COMPnR:
vCOMPnR := 1
COMPnD:
if filesNamesArr.Length() = 0
{
	MsgBox,16,Error, Please choose files to run.
	return
}
SetKeyboardLayout() ; Set keyboard Layout to English
RunDOSBox() ; run Dosbox
if flagC
{
	SetCScriptDir(filesNamesArr, defaultDirPath, dirPath)
	CompileMultCFiles(filesNamesArr, ModelLarge)
	if vCOMPnR
		RunCScript(filesNamesArr[1])
	else
		DebugCScrict(filesNamesArr[1])
}
else
{
	SetAsmScriptDir(filesNamesArr, defaultDirPath, dirPath)
	CompileMultAsmFiles(filesNamesArr)
	if vCOMPnR
		RunAsmScript(filesNamesArr[1])
	else
		DebugAsmScrict(filesNamesArr[1])
}
ExitApp

RUN:
vRUN := 1
DEBUG:
if filesNamesArr.Length() = 0
{
	MsgBox,16,Error, Please choose files to run.
	return
}
SetKeyboardLayout() ; Set keyboard Layout to English
fileName := filesNamesArr[1]
if flagC
	StringTrimRight, fileName, fileName, 2
else
	StringTrimRight, fileName, fileName, 4
RunDOSBox()
send cd{Space}%fileName%{Enter}
sleep 100
if vRUN
	if flagC
		RunCScript(fileName . ".c")
	else
		RunAsmScript(fileName)
else
	if flagC
		DebugCScrict(fileName . ".c")
	else
		DebugAsmScrict(fileName)
ExitApp

COMP:
if filesNamesArr.Length() = 0
{
	MsgBox,16,Error, Please choose files to run.
	return
}
SetKeyboardLayout() ; Set keyboard Layout to English
RunDOSBox() ; run Dosbox
if flagC
{
	SetCScriptDir(filesNamesArr, defaultDirPath, dirPath)
	CompileMultCFiles(filesNamesArr, ModelLarge)
}
else
{
	SetAsmScriptDir(filesNamesArr, defaultDirPath, dirPath)
	CompileMultAsmFiles(filesNamesArr)
}
ExitApp

UPDATE:
updateFile := Check_ForUpdate(1,0,"",err)
	MsgBox, %err% %updateFile%
return

ABOUT:
MsgBox, 64, About Eggplant DOSBox v%Version%, Created by Elchanan Shuky Shukrun`nOrt Braude College of Engineering`nelnn.sh@gmail.com`n2018`nSource code available by request
return

CANCEL:
GuiClose:
GuiEscape:
ExitApp