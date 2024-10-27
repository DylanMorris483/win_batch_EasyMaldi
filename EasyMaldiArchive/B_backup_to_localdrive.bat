REM This batch script ("B_backup_to_localdrive.bat") is a dependency of "A_archive_maldispectra.bat".
REM Maldi spectra of given timeframe (last archiving date until yesterday) are copied from given raw spectra archive to the local disk.

REM "A_archive_maldispectra.bat" passes multiple arguments to this script:
REM %1: date of yesterday (format: 20231017)
REM %2: path to raw spectra archive
REM %3: path to log file (saves timepoints of data archiving)
REM %4: chosen identifier of current Maldi-PC.
REM %5: high speed-drive for temporal data storage

REM Authors Dylan Winterflood together with ChatGPT, Laboratory Medicine USB, 4031 Basel, SWITZERLAND
REM Date 17.10.2023
REM *************************************************************************************************************************************************************************************************************************************************************************************************************

REM make sure that script is not executed with non sufficient arguments 
IF "%4"=="" (
    	echo Aborting. This script must be called by A_archive_maldispectra.bat which passes essential arguments to it. 
	pause
    	exit /b
)

REM create directory on local disk to save spectra. Before creating check if directory already exists.
IF EXIST "%5temp_maldi_rawdata_%4" (
	echo The directory "%5temp_maldi_rawdata_%4" already exists. For running this program it must not exist. Aborting.
	pause
	TERMINATE_PRIMARY=1
    	exit /b)
md "%5temp_maldi_rawdata_%4"

REM get date when spectra were archived last time (last element of log file listing dates of spectra archiving) 
set "lastline="
for /f "delims=" %%a in (%3) do (
    set "lastline=%%a"
)

REM copy spectra of given timeframe(from last archiving until yesterday) from raw spectra archive to local disk
robocopy %2 "%5temp_maldi_rawdata_%4" /S /MINAGE:%1 /MAXAGE:!lastline!

REM save the date of today in the log file (log file lists dates of spectra archiving)
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set datetime=%%a
	echo %datetime:~0,8% >> %3