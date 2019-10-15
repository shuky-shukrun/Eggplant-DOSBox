; v0.85

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetKeyboardLayout(){
	SetFormat, Integer, H
	WinGet, WinID,, A
	ThreadID:=DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
	InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
	StringTrimLeft, InputLocaleID, InputLocaleID, 5
	while (InputLocaleID != "0409") && (InputLocaleID != "0809") && (InputLocaleID != "0c09") && (InputLocaleID != "1009") && (InputLocaleID != "1409") && (InputLocaleID != "1409")
	{
		send #{Space}
		sleep 200
		InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
		StringTrimLeft, InputLocaleID, InputLocaleID, 5
		if A_Index > 5
		{
			MsgBox,4, Warning, Is your keyboard layout set to English?
			IfMsgBox Yes
				Break
			else
			{
				MsgBox,,Error, 
				(
				Please change your keyboard layout to English and try again
				)
				ExitApp
			}
		}
	}
	sleep 200
}

GetFilePath(){
	send ^s ; save the script
	sleep 500
	ifWinExist Save As ; if the script wasn't saved before
		WinWaitClose
	
	clipboard =
	sleep 100
	send !+^m
	sleep 100
	filePath := Clipboard
	return filePath
}

GetFileName(filePath){
	if StrLen(filePath) < 7
	{
		fileName :=
		return fileName
	}
	SplitPath filePath, fileName
	if StrLen(fileName) > 12
	{
		MsgBox,16,Eror!, %fileName%: Script name is allowed up to 8 characters`nPlease rename your script.
		return	
	}
	return fileName
}

RunDOSBox(){
	IfWinExist, DOSBox 0.74 ; if DosBox is already open - use it
	{
		WinActivate
		sleep 100
		send cd C:\TC\
		sleep 50
		send BIN\SCRIPTS\
		sleep 50
		send {Enter}
		sleep 100	
	}
	else
	{
		try
			run, C:\Program Files (x86)\DOSBox-0.74\DOSBox.exe
		catch e
			try
				run, C:\Program Files (x86)\DOSBox-0.74-2\DOSBox.exe
			catch e
			{
				MsgBox,,Error!, Error! Cant find DOSBox.
				ExitApp	
			}
		sleep 2000 ; wait for DosBox to open
	}
}

ValidateFiles(ByRef ScriptFiles, ByRef filesNamesArr, ByRef dirPath, ByRef ModelLarge){
	if ScriptFiles =
		return
	Loop, parse, ScriptFiles, `n 
	{
		if A_Index = 1
			dirPath := A_LoopField
		else
			filesNamesArr[A_Index-1] := A_LoopField ; A_Index = 1 - first loop for dirPath
	}
	mainCounter = 0
	Sort filesNamesArr
	Loop % filesNamesArr.Length() ; run over the array
	{
		fileName := filesNamesArr[A_Index]
		if StrLen(fileName) > 12
		{
			MsgBox,16,Eror!, %fileName%: Script name is allowed up to 8 characters`nPlease rename your script.
			ScriptFiles :=
			filesNamesArr := []
			return	
		}
		
		
		if (inStr(ScriptFiles, ".c", CaseSensitive := false))
			flagC := true
		
		FileCopy %dirPath%\%fileName% , %dirPath%\%fileName%.txt
		sleep, 100
		FileRead mainFile, %dirPath%\%fileName%.txt
		if (inStr(mainFile, "4ch", CaseSensitive := false)) ; search asm main file
		{
			mainCounter++
			mainFile := filesNamesArr[A_Index]
			filesNamesArr.RemoveAt(A_Index)
			filesNamesArr.InsertAt(1, mainFile)
		}
		else if (inStr(mainFile, "main()", CaseSensitive := false)) ; search c main file
		{
			mainCounter++
			mainFile := filesNamesArr[A_Index]
			filesNamesArr.RemoveAt(A_Index)
			filesNamesArr.InsertAt(1, mainFile)
		}
		;~ FileDelete %dirPath%\%fileName%.txt
	}
	
	Loop % filesNamesArr.Length() ; run over the array
	{
		fileName := filesNamesArr[A_Index]
		FileRead mainFile, %dirPath%\%fileName%.txt
		if (flagC = true)
			if (inStr(mainFile, ".MODEL LARGE", CaseSensitive := false)) ; serach model large
				ModelLarge := true
		FileDelete %dirPath%\%fileName%.txt
	}
	
	if mainCounter != 1
	{
	MsgBox, 16, Error - main file, ERROR!`nToo many or none main file were detected.
	ScriptFiles :=
	filesNamesArr := []
	return
	}
	return flagC
}

SetCScriptDir(ByRef filesNamesArr, ByRef defaultDirPath, ByRef dirPath){
	ScriptDir := filesNamesArr[1]
	StringTrimRight, ScriptDir, ScriptDir, 2 ; remove .c from file name
	FileCreateDir %defaultDirPath%\%ScriptDir%
	send cd{Space}
	sleep 50
	send %ScriptDir%{Enter}
	Loop % filesNamesArr.Length() ; run over the array
	{
		fileName := filesNamesArr[A_Index]
		FileCopy, %dirPath%\%filename%, %defaultDirPath%\%ScriptDir%\, 1
		sleep 200
	}
	sleep 500
}

SetAsmScriptDir(ByRef filesNamesArr, ByRef defaultDirPath, ByRef dirPath){
	ScriptDir := filesNamesArr[1]
	StringTrimRight, ScriptDir, ScriptDir, 4
	FileCreateDir %defaultDirPath%\%ScriptDir%
	send cd{Space}
	sleep 50
	send %ScriptDir%{Enter}
	Loop % filesNamesArr.Length() ; run over the array
	{
		fileName := filesNamesArr[A_Index]
		FileCopy, %dirPath%\%filename%, %defaultDirPath%\%ScriptDir%\, 1
		sleep 200
		StringTrimRight, fileName, fileName, 4 ; remove .asm from file name
		filesNamesArr[A_Index] := fileName
	}
}

CompileMultCFiles(ByRef filesNamesArr, ByRef ModelLarge){
	send ^{F4} ; Ctrl+F4 refresh DOSBox file system
	sleep 100
	send, tcc -v
	sleep 50
	if (ModelLarge = true)
		send {Space}-ml
	Loop % filesNamesArr.Length() ; run over the array
	{
		fileName := filesNamesArr[A_Index]
		send, {Space}
		sleep 50
		send %fileName%
		sleep 50
	}
	send {Enter}
	sleep 1000
}

CompileMultAsmFiles(ByRef filesNamesArr){
	send ^{F4} ; Ctrl+F4 refresh DOSBox file system
	sleep 100
	Loop % filesNamesArr.Length() ; run over the array
	{
		fileName := filesNamesArr[A_Index]
		send tasm /zi /z{Space}
		sleep 30
		send %fileName%
		sleep 30
		send {Enter}
		sleep 1000
	}
	
	send, tlink /v
	sleep 50
	Loop % filesNamesArr.Length() ; run over the array
	{
		fileName := filesNamesArr[A_Index]
		send, {Space}
		sleep 50
		send %fileName%
		sleep 50
	}
	send {Enter}
	sleep 1000
}

RunCScript(mainFile) {
	send !x ; Alt+x to clear the DOSBox window
	sleep 100
	StringTrimRight, mainFile, mainFile, 2 ; remove .c from file name
	send, %mainFile%{Enter} ; run the program
}

RunAsmScript(mainFile) {
	send !x ; Alt+x to clear the DOSBox window
	sleep 100

	send, %mainFile%{Enter} ; run the program
}

DebugCScrict(mainFile) {
	send !x ; Alt+x to clear the DOSBox window
	sleep 100
	StringTrimRight, mainFile, mainFile, 2 ; remove .c from file name
	send, td %mainFile%{Enter} ; run td fileName for debuging
	sleep 500

	send, !v v !v r ; set variables and registers on debug screen
}

DebugAsmScrict(mainFile) {
	send !x ; Alt+x to clear the DOSBox window
	sleep 100

	send, td %mainFile%{Enter} ; run td fileName for debuging
	sleep 500

	send, !v v !v r ; set variables and registers on debug screen
}

