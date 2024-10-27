REM This batch script ("C_create_key.bat") is a dependency of "A_archive_maldispectra.bat".
REM Main input: directory with raw maldi spectra inside.
REM For each spectrum this script extracts lab internal identifier and year of measurement using the jq json parser (V. 1.6, downloaded from https://jqlang.github.io/jq/download/). 
REM Output: Lab internal identifier, year and path to maldi spectrum printed into a text file. 

REM "A_archive_maldispectra.bat" passes multiple arguments to this script:
REM %1: path to jq json parser executable
REM %2: chosen identifier of current Maldi-PC.
REM %3: high speed-drive for temporal data storage

REM Authors Dylan Winterflood together with ChatGPT, Laboratory Medicine USB, 4031 Basel, SWITZERLAND
REM Date 17.10.2023

REM *************************************************************************************************************************************************************************************************************************************************************************************************************
@echo off
setlocal enabledelayedexpansion

REM make sure that script is not executed with non sufficient arguments 
IF "%2"=="" (
    	echo Aborting. This script must be called by A_archive_maldispectra.bat which passes essential arguments to it. 
	pause
    	exit /b
)

REM "B_backup_to_localdrive.bat" copied raw spectra into "%3temp_maldi_rawdata_%2"
REM use this directory as input
set "directory=%3temp_maldi_rawdata_%2"

REM create folder (%3temp_maldi_misc_%2) to save output and jq json parser executable on local drive
REM check if this folder exists  
IF EXIST "%3temp_maldi_misc_%2" (
    	echo The directory "%3temp_maldi_misc_%2" already exists. For running this program it must not exist. Aborting.
	pause
    	exit /b	
)
md "%3temp_maldi_misc_%2"

REM set were output should be stored
set "outputFile=%3temp_maldi_misc_%2\key.txt"

REM copy jq json parser executable to local drive
xcopy %1 "%3temp_maldi_misc_%2"

REM define path to jq json parser executable on local drive
set "path_jq=%3temp_maldi_misc_%2"

REM iterate over all subdirectories in "directory"
REM each subdirectory represents one maldi measurement
REM one maldi measurement consists of multiple measured maldi target spots

for /d %%i in ("%directory%\*") do (
	pushd "%%i"
	REM use jq to extract year of measurement from json file "statusInfo.json" (json object inside, year is in value of key "TimestampS"), save year in variable "year"
	for /f "tokens=1 delims=-" %%a in ('%path_jq%\jq-win64.exe -r ".TimestampS" statusInfo.json') do (set "year=%%a")
    	REM loop over all subdirectories
	REM each subdirectory represent the measurement of one maldi spot
	for /d %%l in (".\*") do (
		pushd "%%l"
		REM use jq to extract lab internal identifier from json file "info" (json object inside, lab internal identifier is value of key "AnalyteId"), save identifier in variable "output"
		for /f "delims=" %%x in ('%path_jq%\jq-win64.exe -a ".AnalyteId" info') do (set "output=%%x"
			REM remove characters that may cause problems in a path
			set "output=!output:\n=!"
			set "output=!output: =!"
			set "output=!output:,=!"
			set "output=!output:;=!"
			set "output=!output:^=!"
			set "output=!output:(=!"
			set "output=!output:)=!"
			set "output=!output:<=!"
			set "output=!output:>=!"        
			set "output=!output:'=!"         
			set "output=!output:"=!"         
			set "output=!output:\=!"         
			set "output=!output:/=!"         
			set "output=!output:|=!"        
			set "output=!output:?=!"         
			set "output=!output:`=!"        
			REM append lab internal identifier, year of measurement and path to spectra (separated by tabulator) to one line in txt file (outputFile) 
			<nul set /p="!output!	" >> %outputFile%
			<nul set /p="!year!	" >>%outputFile%)
			echo %%~fl>>%outputFile%
			echo %%i
			echo %%l 
			popd
		)
	popd
)
