REM This batch file ("A_archive_maldispectra.bat") archives Maldi spectras as described in the paper paper xy.

REM Instructions:
REM 1.) Define paths and identifiers in the "Definition Section" below. ä', 'ö','ü or other special characters are not allowed inside the paths!
REM 2.) Make sure that batch script dependencies (B_backup_to_localdrive.bat, C_create_key.bat, D_order_spectra.bat, E_check_input.bat) are in the same directory than this script (A_archive_maldispectra.bat).
REM 3.) call this script (A_archive_maldispectra.bat) with date of yesterday as argument (Date format: 20231017) in the command line
REM Example call: A_archive_maldispectra.bat 20231017  

REM Methods: This script uses the jq json parser (V. 1.6, downloaded from https://jqlang.github.io/jq/download/). Make sure that path to executable is defined in the "Definition Section"

REM Authors Dylan Winterflood together with ChatGPT, Laboratory Medicine USB, 4031 Basel, SWITZERLAND
REM Date 17.10.2023
REM *************************************************************************************************************************************************************************************************************************************************************************************************************
REM Definition section

REM define path to raw spectra archive (Maldi backup)
set "source=C:\localmaldi_paper_test\delta_data\PC1"

REM define a high speed-drive (preferably C:\) with sufficient space for temporal data storage.
set "temp_drive=C:\"

REM chose a Maldi-PC identifier 
set "pc_ident=PC1"

REM define path to log file (saves timepoints of data archiving). If not initialised yet: create text file with date of first maldi measurement, format: 20120101 for first of Jan. 2012
set "log=C:\localmaldi_paper_test\archiv\log_files\log_pc1.txt"

REM define path to jq json parser executable(jq-win64) 
set "where_jsonparser=X:\20230224_actsch_dylan_m_winterflood\get_maldi_spectras\extraction_bats\jq-win64.exe"

REM define path to ordered spectra archive (entire archive, not path to archive of current PC (subdirectory of entire archive)). If not initialised yet: created folder (named "chosen Maldi-PC identifier") inside maldi-archive folder.
set "path_to_archive=C:\localmaldi_paper_test\archiv\data"

REM **************************************************************************************************************************************************************************************************************************************************************************************************************

@echo off
setlocal enabledelayedexpansion

REM capture starting time
for /f "tokens=1-4 delims=:." %%a in ("!time!") do (
    set /a "start=(((%%a*60)+%%b)*60+%%c)*100+%%d")

REM make sure that script is not executed with non sufficient arguments 
IF %1=="" (
    	echo Aborting. This script must be called from the command line with the date of yesterday as argument (use format 20240101 for 1. Jan. 2024)
	echo %1
	pause)

REM call script E_check_input.bat
REM arguments %1: date of yesterday (format: 20231017)
REM checks if input (date of yesterday) is formatted correctly
call E_check_input.bat %1
if defined TERMINATE_PRIMARY (
echo Date of yesterday not in correct format. Use format 20231023 for 23th of October 2023. Aborting.
pause
exit /b
)

REM call script B_backup_to_localdrive.bat
REM arguments: %1: date of yesterday (format: 20231017), %source%: path to raw spectra archive , %log%: path to log file (saves timepoints of data archiving), %pc_ident%: Maldi-PC identifier, %temp_drive%: high speed-drive for temporal data storage
REM copies raw data from last extraction until yesterday to local drive
call B_backup_to_localdrive.bat %1 %source% %log% %pc_ident% %temp_drive%
if defined TERMINATE_PRIMARY (
exit /b
)

REM call script C_create_key.bat
REM arguments: %where_jsonparser%: path to jq json parser executable, %pc_ident%: Maldi-PC identifier, %temp_drive%: high speed-drive for temporal data storage
REM creates txt file with key on local drive
call C_create_key.bat %where_jsonparser% %pc_ident% %temp_drive%

REM call script D_order_spectra.bat
REM arguments: %pc_ident%: Maldi-PC identifier, %path_to_archive%: defined path to ordered spectra archive, %temp_drive%: high speed-drive for temporal data storage
REM orders spectra based on created key (by "script C_create_key.bat")
call D_order_spectra.bat %pc_ident% %path_to_archive% %temp_drive%

REM check if new data is available, if not so, delete local files and terminate script
IF NOT EXIST "%temp_drive%temp_maldi_ordered_%pc_ident%" (
	rd /S /Q "%temp_drive%temp_maldi_rawdata_%pc_ident%"
	rd /S /Q "%temp_drive%temp_maldi_misc_%pc_ident%"
    	exit /b
)

if not exist "%path_to_archive%\%pc_ident%" mkdir "%path_to_archive%\%pc_ident%"

REM copy ordered maldi from local hard drive into archive
xcopy "%temp_drive%temp_maldi_ordered_%pc_ident%\*" "%path_to_archive%\%pc_ident%" /E

REM  Remove directories used for sorting on local drive
rd /S /Q "%temp_drive%temp_maldi_rawdata_%pc_ident%"
rd /S /Q "%temp_drive%temp_maldi_misc_%pc_ident%"
rd /S /Q "%temp_drive%temp_maldi_ordered_%pc_ident%"

REM capture end time and calculate run time
for /f "tokens=1-4 delims=:.," %%a in ("!time!") do (
    set /a "end=(((%%a*60)+%%b)*60+%%c)*100+%%d"
)
set /a "duration=!end!-!start!"

REM convert to secs
set /a "seconds=!duration!/100"
echo Runtime: !seconds! seconds