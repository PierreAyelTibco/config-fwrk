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

if "%~2" == "" goto usage
set APP_CONFIG=%2

if "%~3" == "" goto usage
set GLOBAL_CONFIG=%3

set APP=%TEMP%\%RANDOM%.xml
set GLOBAL=%TEMP%\%RANDOM%.xml

if EXIST "%INPUT%\META-INF\TIBCO.xml" goto application

REM ###########################################################################
REM ### Update one profile file

:profile

set OUTPUT=%4
if "%~4" == "" set OUTPUT=%TEMP%\%RANDOM%.substvar

call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\create-AppConfig-from-ODS-ant.xml -DODS=%APP_CONFIG% -DOUTPUT=%APP%
call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\create-AppConfig-from-ODS-ant.xml -DODS=%GLOBAL_CONFIG% -DOUTPUT=%GLOBAL%
for %%F in (%INPUT%) do call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\import-ant.xml -DPROFILE_IN=%%F -DPROFILE_OUT=%OUTPUT% -DAPP_APPCONFIG=%APP% -DGLOBAL_APPCONFIG=%GLOBAL% -DENV=%%~nF
rem del /f /q %APP%
rem del /f /q %GLOBAL%

echo Profile has been updated: %OUTPUT%

goto end

REM ###########################################################################
REM ### Update all profile files within an application

:application
call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\create-AppConfig-from-ODS-ant.xml -DODS=%APP_CONFIG% -DOUTPUT=%APP%
call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\create-AppConfig-from-ODS-ant.xml -DODS=%GLOBAL_CONFIG% -DOUTPUT=%GLOBAL%
for %%F in (%INPUT%\META-INF\*.substvar) do call %ANT_HOME%\bin\ant -f %DIRSCRIPT%\..\lib\import-ant.xml -DPROFILE_IN=%%F -DPROFILE_OUT=%%F -DAPP_APPCONFIG=%APP% -DGLOBAL_APPCONFIG=%GLOBAL% -DENV=%%~nF
rem del /f /q %APP%
rem del /f /q %GLOBAL%
goto end

REM ###########################################################################

:usage
echo.
echo Usage: %0 input-profile app-config-file global-config-file [output-profile]
echo.
echo Options:
echo.
echo input-profile:      The existing .substvar or .profile file or application folder to read profiles from.
echo.
echo app-config-file:    The existing Excel spreadsheet file for the application settings.
echo                     This file can be the same as global-config-file. 
echo.
echo global-config-file: The existing Excel spreadsheet file for the global settings.
echo                     This file can be the same as app-config-file.       
echo.
echo output-profile:     The target profile file.
echo.
goto end

REM ###########################################################################

:end
endlocal

REM ###########################################################################
REM ###  END OF FILE  #########################################################
REM ###########################################################################
