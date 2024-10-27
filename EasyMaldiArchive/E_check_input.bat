REM This script checks if the date inputed to "A_archive_maldispectra.bat" is formatted correctly

REM "A_archive_maldispectra.bat" passes one argument to this script:
REM %1: date of yesterday (format: 20231017)

REM Authors Dylan Winterflood together with ChatGPT, Laboratory Medicine USB, 4031 Basel, SWITZERLAND
REM Date 23.10.2023
REM *************************************************************************************************************************************************************************************************************************************************************************************************************

REM make sure that script is not executed with non sufficient arguments 
IF "%1"=="" (
    	echo Aborting. This script must be called by A_archive_maldispectra.bat which passes essential arguments to it. 
	pause
    	exit /b
)

set "input=%1"
echo %input%

REM get the eigth character
set eigth=%input:~7,1%
REM get the ninth character
set ninth=%input:~8,1%
REM get the first two characters
set yearPrefix=%input:~0,2%

REM check if the input date is to short (shorter than 8 characters)
if not defined eigth (
set TERMINATE_PRIMARY=1
)

REM check if input date is to long (longer than 8 characters) 
if defined ninth (
set TERMINATE_PRIMARY=1
)

REM check if input date starts with 20 (for year 2023, 2024 etc...)
if not "%yearPrefix%" == "20" (
set TERMINATE_PRIMARY=1
)