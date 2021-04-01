@echo off
setlocal
REM ###########################################################################

REM ###########################################################################
REM ###  YOU CAN MODIFY THE FOLLOWING VARIABLES
REM ###########################################################################

REM ###########################################################################
REM ###  DO NOT MODIFY THE REST OF THE SCRIPT
REM ###########################################################################

set DIRSCRIPT=%0\..
set ANT_HOME=%DIRSCRIPT%\..\tpcl\apache-ant-1.10.9

if "%~1" == "" goto usage
set INPUT=%1

set TEMPLATE=%2
if "%~2" == "" set TEMPLATE=%DIRSCRIPT%\..\templates\ods.ods

set OUTPUT=%3
if "%~3" == "" set OUTPUT=%TEMP%\%RANDOM%.ods

set QUIET=%4

if "%~x1" == ".application" goto application
if "%~x1" == ".substvar" goto profile
if "%~x1" == ".ear" goto ear
goto all

REM ###########################################################################
REM ###  Export configuration from one profile file

:profile
call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\export-ant.xml -DAPPCONFIG=%INPUT% -DMODULE_CONFIG=%DIRSCRIPT%\..\templates\module.bwm -DTEMPLATE=%TEMPLATE% -DODS=%OUTPUT% "-DDATE=%date% %time%"
if NOT "%QUIET%" == "--quiet" (start %OUTPUT%)
goto end

REM ###########################################################################
REM ###  Export configuration from one application folder

:application
set TMPL=%TEMP%\%RANDOM%.ods
copy %TEMPLATE% %TMPL%

for %%f in (%INPUT%\META-INF\*.substvar) do (call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\export-ant.xml -DAPPCONFIG=%%f -DMODULE_CONFIG=%INPUT%/../%~n1/META-INF/module.bwm -DTEMPLATE=%TMPL% -DODS=%OUTPUT% "-DDATE=%date% %time%"
move %OUTPUT% %TMPL%
)
copy %TMPL% %OUTPUT%
if NOT "%QUIET%" == "--quiet" (start %OUTPUT%)
goto end

REM ###########################################################################
REM ###  Export configuration from ALL profile files inside one EAR 

:ear
set FOLDER=%TEMP%\%RANDOM%
call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\unzip-ant.xml -DINPUT=%INPUT% -DOUTPUT=%FOLDER%

set TMPL=%TEMP%\%RANDOM%.ods
copy %TEMPLATE% %TMPL%

for %%f in (%FOLDER%\META-INF\*.substvar) do (call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\export-ant.xml -DAPPCONFIG=%%f -DMODULE_CONFIG=%DIRSCRIPT%/../templates/module.bwm -DTEMPLATE=%TMPL% -DODS=%OUTPUT% "-DDATE=%date% %time%"
move %OUTPUT% %TMPL%
)
copy %TMPL% %OUTPUT%
if NOT "%QUIET%" == "--quiet" (start %OUTPUT%)

goto end

REM ###########################################################################
REM ###  Export configuration from ALL application folders

:all
set TMPL=%TEMP%\%RANDOM%.ods
copy %TEMPLATE% %TMPL%

for /D /R "%INPUT%" %%f in (*.application) do call %DIRSCRIPT%\export.bat %%f %TMPL% %TMPL% --quiet
copy %TMPL% %OUTPUT%
if NOT "%QUIET%" == "--quiet" (start %OUTPUT%)
goto end

REM ###########################################################################

:usage
echo Usage: %0 input-profile [template-ods] [output-ods] [--quiet]

--quiet: Does not open the spreadsheet file at the end of the export.

REM ###########################################################################

:end
endlocal

REM ###########################################################################
REM ###  END OF FILE  #########################################################
REM ###########################################################################
