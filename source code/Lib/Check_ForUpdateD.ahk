; Credit: https://autohotkey.com/board/topic/72559-func-self-script-updater/page-1	
Check_ForUpdate(_ReplaceCurrentScript = 1, _SuppressMsgBox = 0, _CallbackFunction = "", ByRef _Information = "")
{
	;Version.ini file format - this is just an example of what the version.ini file would look like
	;
	;[Info]
	;Version=2.1
	;URL=192.168.1.106/files/No-Idle/No-Idle.exe
	;MD5=00000000000000000000000000000000 or omit this key completly to skip the MD5 file validation
	
	Static Script_Name := "EggplantDOSBox" 
	, Version_Number := 0.85 ;The script's version number
	, Update_URL := "http://cba.ric.mybluehost.me/Eggplant_DOSBox/Version.ini"
	, Retry_Count := 3 ;Retry count for if/when anything goes wrong
	
	Random,Filler,10000000,99999999
	Version_File := A_Temp . "\" . Filler . ".ini"
	, Temp_FileName := A_Temp . "\" . Filler . ".tmp"
	, VBS_FileName := A_Temp . "\" . Filler . ".vbs"
	
	Loop,% Retry_Count
	{
		_Information := ""
		
		UrlDownloadToFile,%Update_URL%,%Version_File%
		
		IniRead,Version,%Version_File%,Info,Version,N/A
		IniRead, ChangeLog,%Version_File%,ChangeLog,WhatNew,""
		If (Version = "N/A"){
			FileDelete,%Version_File%
			
			If (A_Index = Retry_Count)
				_Information .= "The version info file doesn't have a ""Version"" key in the ""Info"" section or the file can't be downloaded."
			Else
				Sleep,500
			
			Continue
		}
		
		If (Version > Version_Number){
			If (_SuppressMsgBox != 1 and _SuppressMsgBox != 3){
				MsgBox,0x4,New version available,There is a new version of %Script_Name% available.`nCurrent version: %Version_Number%`nNew version: %Version%`nCHANGELOG:`n%ChangeLog%`n`nWould you like to download it now?
				
				IfMsgBox,Yes
					MsgBox_Result := 1
			}
			
			If (_SuppressMsgBox or MsgBox_Result){
				SplashTextOn, 400, 100, Updader, Downloading... Plese wait
				IniRead,URL,%Version_File%,Info,URL,N/A
				
				If (URL = "N/A")
					_Information .= "The version info file doesn't have a valid URL key."
				Else {
					SplitPath,URL,,,Extension
					
					If (Extension = "ahk" And A_AHKPath = "")
						_Information .= "The new version of the script is an .ahk filetype and you do not have AutoHotKey installed on this computer.`r`nReplacing the current script is not supported."
					Else If (Extension != "exe" And Extension != "ahk")
						_Information .= "The new file to download is not an .EXE or an .AHK file type. Replacing the current script is not supported."
					Else {
						
						;~ SplashTextOn, 400, 300, Updader, Downloading...
						IniRead,MD5,%Version_File%,Info,MD5,N/A
						
						Loop,% Retry_Count ; Validate (check MD5) and download update file 
						{
							UrlDownloadToFile,%URL%,%Temp_FileName%
							
							IfExist,%Temp_FileName%
							{
								If (MD5 = "N/A"){
									_Information := "The version info file doesn't have a valid MD5 key."
									, Success := True
									Break
								} Else {
									Ptr := A_PtrSize ? "Ptr" : "UInt"
									, H := DllCall("CreateFile",Ptr,&Temp_FileName,"UInt",0x80000000,"UInt",3,"UInt",0,"UInt",3,"UInt",0,"UInt",0)
									, DllCall("GetFileSizeEx",Ptr,H,"Int64*",FileSize)
									, FileSize := FileSize = -1 ? 0 : FileSize
									
									If (FileSize != 0){
										VarSetCapacity(Data,FileSize,0)
										, DllCall("ReadFile",Ptr,H,Ptr,&Data,"UInt",FileSize,"UInt",0,"UInt",0)
										, DllCall("CloseHandle",Ptr,H)
										, VarSetCapacity(MD5_CTX,104,0)
										, DllCall("advapi32\MD5Init",Ptr,&MD5_CTX)
										, DllCall("advapi32\MD5Update",Ptr,&MD5_CTX,Ptr,&Data,"UInt",FileSize)
										, DllCall("advapi32\MD5Final",Ptr,&MD5_CTX)
										
										FileMD5 := ""
										Loop % StrLen(Hex:="123456789ABCDEF0")
											N := NumGet(MD5_CTX,87+A_Index,"Char"), FileMD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
										
										VarSetCapacity(Data,FileSize,0)
										, VarSetCapacity(Data,0)
										
										If (FileMD5 != MD5){
											FileDelete,%Temp_FileName%
											
											If (A_Index = Retry_Count)
												_Information .= "The MD5 hash of the downloaded file does not match the MD5 hash in the version info file."
											Else										
												Sleep,500
											
											Continue
										} Else
											Success := True
									} Else {
										DllCall("CloseHandle",Ptr,H)
										Success := True
									}
								}
							} Else {
								If (A_Index = Retry_Count)
									_Information .= "Unable to download the latest version of the file from " . URL . "."
								Else
									Sleep,500
								Continue
							}
						}
					}
				}
				SplashTextOff
			}
		} Else
			_Information := "No update was found."
		
		FileDelete,%Version_File%
		Break
	}
	; Create batch file to replace old script
	If (_ReplaceCurrentScript And Success){
		SplitPath,A_ScriptFullPath,fName,Dir,,Name
		BatchFile=
		(
		Ping 127.0.0.1
		xcopy %Temp_FileName% %A_ScriptFullPath% /y
		%A_ScriptFullPath%
		Del Update.bat
		)
			
		FileDelete,update.bat ;Housecleaning
		FileAppend,%BatchFile%,update.bat ;Create the bat
		MsgBox, Preparing to update - Please stand by! ;Alert the user that the app will be down for a few seconds
		Run,update.bat,,hide ;Run it (hidden)
		ExitApp
	}
	
	_Information := _Information = "" ? "None" : _Information
	
	Return Return_Val
}