@echo off
SETLOCAL EnableExtensions

set EXE=miner.exe
set DELAY=30
set RUNBAT=fypool_EU.bat

echo Monitoring process %EXE%
echo Delay set to %DELAY% seconds
echo Execution batch file set to %RUNBAT%
echo ! Do not forget to add --eexit 3 as parameter in %RUNBAT%

echo %date% - %time% : Application started >> runlog.txt
call %RUNBAT%

:loop

FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %EXE%"') DO IF %%x == %EXE% goto END

echo %date% - %time% : Crash detected, restarting >> runlog.txt
timeout 60 >nul
call %RUNBAT%
goto END
:END
timeout %DELAY% >nul
goto loop