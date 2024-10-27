REM This batch script ("D_order_spectra.bat") is a dependency of "A_archive_maldispectra.bat".
REM It orders maldi spectra based on year and lab internal identifier.
REM Structure of ordered spectra is as follows:
REM Directory: "C:\temp_maldi_ordered_%1"
REM Subdirectories: years of measurement
REM Subsubdirectories: lab internal identifiers. Spectra are stored in these directories.

REM Input1: Directory with raw maldi spectra inside (created by "B_backup_to_localdrive.bat")
REM Input2: Text file listing lab internal identifiers, years of measurement and paths to spectra (created by "C_create_key.bat"). In the following refered to as "key file".

REM "A_archive_maldispectra.bat" passes two arguments to this script:
REM %1: chosen identifier of current Maldi-PC.
REM %2: path to maldi archive
REM %3: high speed-drive for temporal data storage

REM Authors Dylan Winterflood together with ChatGPT, Laboratory Medicine USB, 4031 Basel, SWITZERLAND
REM Date 17.10.2023
REM *************************************************************************************************************************************************************************************************************************************************************************************************************

@echo off
setlocal enabledelayedexpansion

REM make sure that script is not executed with non sufficient arguments 
IF "%1"=="" (
    	echo Aborting. This script must be called by A_archive_maldispectra.bat which passes essential arguments to it. 
	pause
    	exit /b
)

REM save where "key file" is stored (created by C_create_key.bat)
set "key=%3temp_maldi_misc_%1\key.txt"

REM check if new data is available, if not so, key text file does not exist
IF NOT EXIST "%3temp_maldi_misc_%1\key.txt" (
    echo No new data available for archiving. Aborting.
    pause
    exit /b
)

REM create folder (%3temp_maldi_ordered_%1) for saving ordered spectra on local drive
REM check if this folder exists
IF EXIST "%3temp_maldi_ordered_%1" (
    	echo The directory "%3temp_maldi_ordered_%1" already exists. For running this program it must not exist. Aborting.
	pause
    	exit /b
)
md "%3temp_maldi_ordered_%1"

REM save path to ordered spectra
set "ordered=%3temp_maldi_ordered_%1"

REM Loop through lines of key file
REM lab internal identifier, year and path to spectra are one line and separated by tabulator
REM assign these to tokens %%a, %%b, %%c and varA, varB and varC
for /f "usebackq tokens=1-3 delims=	" %%a in ("%key%") do (
	REM varA: lab internal identifier
	set varA=%%a
	REM varB: year of measurement
    	set varB=%%b
	REM varC: path to spectra
    	set varC=%%c
	REM check if there are three tokens, if not so this is not a valid measurement and will not be sorted
    	if not "!varA!"=="" if not "!varB!"=="" if not "!varC!"=="" (
		
		REM if no spectra with current measurement year %%b there yet, create folder "%%b"
		if not exist "%ordered%\%%b" mkdir "%ordered%\%%b"

		REM if no spectra with current lab internal identifier %%a thereyet, create folder "%%a"
		if not exist "%ordered%\%%b\%%a" mkdir "%ordered%\%%b\%%a"
		
		set archiveCount=0
		if exist "%2\%1\%%b\%%a" (
		REM count how many spectra are already in archive "%2\%1\%%b\%%a"
		for /d %%q in ("%2\%1\%%b\%%a\*") do (
    		set /a archiveCount+=1
		)
		)
		
		REM count how many spectra are already in folder "%%a"
		set folderCount=0
		for /d %%q in ("%ordered%\%%b\%%a\*") do (
    		set /a folderCount+=1
		)
		)

		REM add one to count and count how many spectra in archive, folderCount now is number of the current spectrum
		set /a folderCount=!archiveCount! + !folderCount! +1
		
		REM create folder for current spectrum
    		mkdir "%ordered%\%%b\%%a\spectra_!folderCount!"

    		REM copy current spectrum to this folder
    		xcopy /E /I "%%c" "%ordered%\%%b\%%a\spectra_!folderCount!"
    		echo "%%c"
	)
)
endlocal