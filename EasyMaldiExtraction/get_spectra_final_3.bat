REM This script extracts maldi spectra from the (ordered-) archive.

REM Input: text file listing year and lab internal identifier of spectra to extract
REM text file structure: on one line: year \whitespace "lab internal identifier" (new line for next entry)
REM example:
REM 2020 802871
REM Output: spectra of lab internal identifiers
REM file structure in output folder: 
REM directory: "Maldi-Tof connected computer identifier (data origin)
REM subdirectory: year of measurement
REM subsubdirectory: laboratory internal identifier-isolateID
REM subsubsubdirectory: technical replicate number (spectra_n)

REM Instructions:
REM 1.) Create query text file.
REM 2.) Create folder for output. 
REM 3.) Define paths in the "Definition Section" below. ä', 'ö','ü or other special characters are not allowed inside the paths! 
REM 4.) Run this bat file

REM Authors Dylan Winterflood together with ChatGPT, Laboratory Medicine USB, 4031 Basel, SWITZERLAND
REM Date 23.10.2023
REM *************************************************************************************************************************************************************************************************************************************************************************************************************
REM Definition section

REM define path to query txt file
set "file=X:\20230224_actsch_dylan_m_winterflood\maldi_paper_pyogenes_example\query_pyogenes.txt"

REM define path to output folder
set "directory_to_files=P:\extraction_pyogenes"

REM define path to (ordered-) maldi archive folder
set "directory_to_ordered_files=P:\maldi_archiv\archive_data"

REM **************************************************************************************************************************************************************************************************************************************************************************************************************

@echo off
setlocal enabledelayedexpansion

REM loop over lines of query text file
for /f "usebackq tokens=1-2" %%a in ("%file%") do (	
	REM this is the year
	echo Element 1: %%a
	REM this is the lab internal identifier
	echo Element 2: %%b

	REM following section extracts spectra
	REM use counter if there are multiple spectra for one analyte
	REM loop over all Maldi-PCs inside Maldi-Archive
	for /D %%c in (%directory_to_ordered_files%\*) do (
		REM save Maldi-PC identifier
		set pcname=%%~nc
		REM loop over all directories of given year and given lab internal identifier
		for /D %%d in (%%c\%%a\%%b*) do (
        			set "fullPath=%%d"
				REM Extract the directory name from fullPath
    				for %%i in ("!fullPath!") do set "dirName=%%~nxi"
				REM make folder to output spectra		
				mkdir "%directory_to_files%\!pcname!\%%a\!dirName!"
				REM copy spectra into output directory, skip (/D) if dir already exists (doublicates in query file)
				xcopy /E /D "!fullPath!" "%directory_to_files%\!pcname!\%%a\!dirName!"
		)
	)
)