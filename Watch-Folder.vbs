Option Explicit
dim FolderToWatch, Sink, Wmi, escapedPath
dim LogFile
dim PiPDuration, PiPDisableTime
dim LogMsgString, fso, fsofile
dim ohttp, httpUser, httpPassword, httpPiPDisable, httpPiPEnable
dim arrNames

'Which folder should be watched for new files?
FolderToWatch="C:\temp"

'How long should PiP (Picture in Picture) be shown?
PiPDuration=20

'URL to enable PiP (Picture in Picture)
httpPiPEnable="http://www.orf.at/x.asp?a=1"

'URL to disable PiP (Picture in Picture)
httpPiPDisable="http://www.derstandar.at/y.asp?f=7"

'User and password for the http addresses
httpUser=""
httpPassword=""

'Name of the log file
LogFile="Watch-Folder.log"



'LogMsg("***** Start *****")

Set Sink = WScript.CreateObject("WbemScripting.SWbemSink","Sink_")
Set Wmi = GetObject("winmgmts://./root/cimv2")


Wmi.ExecNotificationQueryAsync Sink, FileCreationQueryString(FolderToWatch)

LogMsg("Waiting for file creation in " & FolderToWatch)

Do
	if PiPDisableTIme<>"" then
		if now() >= PiPDisableTime then
			LogMsg("Disabling PiP (Picture in Picture)")
			HTTPPost httpPiPDisable
			PiPDisableTime=""
			LogMsg("Waiting for file creation in " & FolderToWatch)
		end if
	end if
	WScript.Sleep 1000
Loop


function FileCreationQueryString(canonicalFolderPath)
	escapedPath = replace(canonicalFolderPath,"\","\\\\")
	FileCreationQueryString = _
		("SELECT * FROM __InstanceCreationEvent WITHIN 1 WHERE " _
		& "TargetInstance ISA 'CIM_DirectoryContainsFile' and " _
		& "TargetInstance.GroupComponent=" _
		& "'Win32_Directory.Name=""" & escapedPath & """'")
end function


Sub Sink_OnObjectReady(ByVal objWbemObject, ByVal objWbemAsyncContext)
	arrNames = Split(wmi.Get(objWbemObject.targetInstance.PartComponent).name, "\")
	LogMsg("New file """ & arrNames(ubound(arrNames)) & """ detected")
	LogMsg("Enabling PiP (Picture in Picture)")
	HTTPPost httpPiPEnable
	PiPDisableTime=dateadd("s", PiPDuration, now())
	LogMsg("PiP (Picture in Picture) will be disabled at " & PiPDisableTime)
End Sub


Sub LogMsg(msg)
	LogMsgString=Right("0" & DatePart("h",time), 2) & ":" & Right("0" & DatePart("n",time), 2) & ":" & Right("0" & DatePart("s",time), 2) & " " & msg
	if len(LogMsgString)>79 then
		wscript.echo left(LogMsgstring,76) & "..."
	else
		wscript.echo LogMsgstring
	end if
	If Len(LogFile)>0 Then
		set fso = CreateObject("Scripting.FileSystemObject")
		set fsofile = fso.OpenTextFile(LogFile, 8, true)
		fsofile.writeline DatePart("yyyy",Date) & "-" & Right("0" & DatePart("m",Date), 2) & "-" & Right("0" & DatePart("d",Date), 2) & " " & LogMsgString
		fsofile.close
		set fsofile = nothing
		Set fso = nothing
	End If
End Sub


Function HTTPPost(sUrl)
	set oHTTP=WScript.CreateObject("MSXML2.ServerXMLHTTP") 
	oHTTP.open "Get", sUrl, false, httpUser, httpPassword
	oHTTP.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
	on error resume next
	err.clear
	oHTTP.send
	if err.number<>0 then
		LogMsg("Error: " & err.source & "; " & err.number & "; " & err.description)
	end if
	on error goto 0
	HTTPPost = oHTTP.responseText
End Function
