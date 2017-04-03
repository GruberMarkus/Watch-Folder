@echo off
pushd "%~dp0"

call :GetTime
echo %year%-%month%-%day% %hour%:%min%:%sec% _kill.cmd>>watch-folder.log

if exist watch-folder.pid (
for /f %%i in (watch-folder.pid) do taskkill /pid %%i /t /f
del /f /q watch-folder.pid
)

if exist watch-folder.error del /f /q watch-folder.error

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

