@echo off
pushd "%~dp0"
if exist watch-folder.pid (
	echo Watch-Folder.pid exists, only one instance is allowed.
	echo Exiting.
	goto :eof
)

call :GetTime
echo %year%-%month%-%day% %hour%:%min%:%sec% ***** Start *****>>watch-folder.log


title Watch-Folder.vbs
for /F "Tokens=3" %%I in ('.\tools\getpids.exe') do set WatchFolderPID=%%I
echo %WatchFolderPID%>Watch-Folder.pid

echo Process ID (PID): %WatchFolderPID%, see Watch-Folder.pid
echo Show window:      _show.cmd
echo Hide window:      _hide.cmd
echo Kill script:      _kill.cmd
echo.
echo Starting Watch-Folder.vbs.
echo.

call :GetTime


REM echo %year%-%month%-%day% %hour%:%min%:%sec% Set process priority>>watch-folder.log
REM .\tools\nircmdc.exe setprocesspriority /%WatchFolderPID% realtime

call :GetTime
echo %year%-%month%-%day% %hour%:%min%:%sec% Call _hide.cmd>>watch-folder.log
call _hide.cmd

cscript //nologo Watch-Folder.vbs 2>Watch-Folder.error
if exist PowerEvent-Tasks.error call :GetTime
if exist PowerEvent-Tasks.error set /p fehler=<Watch-Folder.error
if exist PowerEvent-Tasks.error echo %year%-%month%-%day% %hour%:%min%:%sec% %fehler%>>Watch-Folder.log
if exist PowerEvent-Tasks.error set fehler=
if exist PowerEvent-Tasks.error del /f /q Watch-Folder.error


call :GetTime
echo %year%-%month%-%day% %hour%:%min%:%sec% Delete Watch-Folder.pid>>Watch-Folder.log
del /f /q Watch-Folder.pid

call :GetTime
echo %year%-%month%-%day% %hour%:%min%:%sec% ***** Ende *****>>watch-folder.log

goto :end

:GetTime
REM Get date and time, independent from system language
FOR /F "skip=1 tokens=1-6 delims= " %%A IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
	IF %%A GTR 0 (
		SET Day=%%A
		SET Hour=%%B
		SET Min=%%C
		SET Month=%%D
		SET Sec=%%E
		SET Year=%%F
		)
)

if %month% LSS 10 set "month=0%month%"
if %day% LSS 10 set "day=0%day%"
if %hour% LSS 10 set "hour=0%hour%"
if %min% LSS 10 set "min=0%min%"
if %sec% LSS 10 set "sec=0%sec%"
goto :eof


:end
exit