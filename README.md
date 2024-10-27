# EasyMaldi
EasyMaldi streamlines spectral data extraction and diagnostic integration from Bruker Biotyper® Maldi-Tof MS Systems. 

The goal for this software was threefold: (i) No installation required on a windows machine (often the case within the clinical laboratory setting), (ii) no human interaction required, (iii) data is organized according to LIIs minimal impact on performance of the system. Runtime considerations were not made, since the software is expected to run when the machine is idle.
## Table of contents
- [Citation](#Citation)
- [Version](#Version)
- [Authors](#Authors)
- [Affiliation](#Affiliation)
- [Dependencies](#Dependencies)
- [Background](#Background)
- [Instructions](#Instructions)
  -[EasyMaldiArchive](#EasyMaldiArchive)
    -[Initialisation](#Initialisation)
    -[Send Data to Archive](#Send-Data-to-Archive)
  -[EasyMaldiExtract](#EasyMaldiExtract)
    -[Create Query text file](#Create-Query-text-file)
    -[Extract Spectra](#Extract-Spectra)
## Citation
To cite this work, please cite: 

## Version
1.0

## Authors:
Dylan M. Winterflood and Pascal Schlaepfer

## Affiliation: 
Affiliation: Laboratory Medicine, University Hospital Basel, 4031 Basel, SWITZERLAND

## Dependencies:
jq json parser (V. 1.6): https://jqlang.github.io/jq/download/


## Background
Since the early 2010s, matrix-assisted laser desorption ionization-time of flight mass spectrometry  has been broadly implemented in clinical laboratories and today is routinely used to identify the causal agent in case of bacteria or fungi. This work resulted in a vast amount of available spectral data related to patient and diagnostic data.
Multiple techniques exist to prepare samples that allow then to use this method for identification of microorganisms (Tsuchida & Nakayama, 2022). For example bacterial colonies can be smeared onto a steel plate (target spots), optional using on-plate extraction with formic acid, with subsequent coverage with a matrix [of what?]. This sample is then used for Matrix-assisted laser desorption ionisation (Maldi). In this process cell-components, among them ribosomal and other proteins, are evaporated and ionized. The molecules are then analysed using time-of-flight (Tof) mass spectrometry (MS). Identification methods typically focus on 2-20 kDa range of which resulting spectra are used as a fingerprint to match with spectral databases that then lead to species identification. 
Maldi-ToF MS data are not limited to species identification, but attract growing attention as an application to identify other attributes of the microorganism. There are efforts to predict resistance against antimicrobial compounds or the ability to form biofilms, biotyping, ability to produce or presence of toxins or more general, biomarker identification which all are emerging research fields (Bittar et al., 2009; Lu et al., 2012; Rodríguez-Temporal et al., 2023; Singhal et al., 2015). Exemplary is the development of Maldi-Tof based methicillin resistant staphylococcus aureus (MRSA) prediction using machine learning (ML) frameworks which led to the identification and validation of MRSA spectra markers. 
MS spectra of entire colonies contain innumerable peaks and hence are difficult to interpret (Lu et al., 2012; Yu et al., 2022). ML can help to identify correlations  between presence (or absence) of peaks and phenotypic attributes of the sample (Lu et al., 2012; Yu et al., 2022). However, ML typically depends on large amounts of structured data where spectra need to be associated with diagnostic data such as phenotypic antibiotic susceptibility testing (PAST) (Weis et al., 2022). Despite both being routinely collected in clinical laboratories, the two sets of data are held separately, often on individual devices in non-human readable format and are not associated to each other (Weis et al., 2020).
Within the clinical laboratory setting, linking of the two or more datasets is achieved through labelling samples with laboratory internal identifiers (LII’s). Identification results and quality scores are typically linked directly to data of the patient, for example in databases or Laboratory information systems. However, the raw data, spectra, are not. Therefore, to perform ML on data within this setting, there is an need for LII dependent bulk retrieval of spectral data so that both data types can be associated and processed together.
In our clinical laboratory we use Biotyper®-Maldi-Tof MS systems by the manufactor Bruker-Daltonics. This system keeps raw spectral data locally on Maldi-Tof connected computers (MTCC) or on MTCC-connected external hard drives in the Bruker XMASS format (fid files). On the MTCC drive, the spectral data are embedded in a directory structure universal to all Bruker Biotyper® systems (Fig 1). Subdirectories of the main data directory (MaldiBiotyperRealTimeClassification) are named with unique Bruker ProjectUids which refer to a measurement run typically consisting of the results of the analysis of multiple target spots. Each sub-subdirectory for each target spot is named with a Bruker AnalyteUid; the folder then contains spectral data from the target spot. Additionally the two files ('statusInfo.json' and 'info') (fig 1) consist of json objects that contain measurement time stamps, as well as analyte metadata. In summary the Bruker directory structure for data storage is based on Biotyper® generated ID’s, to ensure uniqueness for each datapoint. However, this organization of data prevents efficient LII based bulk retrieval of spectral data.
 
Figure 1 The Bruker Biotyper® directory structure for storing spectral data. Subdirectories within the main data directory (MaldiBiotyperRealtimeClassification), are each named with a unique BurkerProjectUid and refer to one measurement run. Sub-subdirectories are named with a unique Bruker AnalyteUid which refer to one target spot and contain its spectral data. Measurement time stamps and analyte metadata are stored within the 'statusInfo.json' and 'info' files.
The Bruker directory structure can be analyzed by third party software, for example it allows for further processing using open-source software packages such as the R implemented “MALDIquant” (Daltonics, 2011; Gibb & Strimmer, 2012). Although “MALDIquant” allows for different export options, re-organizing the raw data by LII’s instead of the MALDI-Tof MS’s unique-identifier is to our knowledge currently not possible. Surprisingly, bulk retrieval methods performing this simple task seem not to exists as the manufacturer was unable to provide one readily on request.
Reformatting the data and directory structure such that it is organized according to LII’s is further complicated by limited user access to the machine. For example  hospital, clinical laboratory or manufacturer regulations due to cyber security and data safety concerns may limit the ability to install software on MTCC . 
To circumvent this issue, we present our software EasyMaldi, a simple, zero-install and easy-to-use windows application. EasyMaldi ensures LII based access and retrieval of spectral data on computers with no installation permissions and therefore is tailored for the usage in clinical laboratories. Ultimately, EasyMaldi advances assembly of large datasets of spectral data linked to related diagnostic data which is crucial for further advancements in Maldi-Tof MS spectra based research and is ideal to provide the data in a format that is easily accessible for ML approaches. Running the software can be fully automatized and the archived data can serve as a backup of raw-data.


## Instructions:
EasyMaldi consists of two modules: (i) EasyMaldiArchive and (ii) EasyMaldiExtraction. EasyMaldiArchive gathers spectral data that was created between its last execution timepoint and yesterday. It then re-organises the data and adds it to the spectra archive. The second module, EasyMaldiExtract acts as a filter for the data and extracts spectra from the archive in bulk using user-provided LII’s.

### EasyMaldiArchive:
EasyMaldiArchive is designed to send data from one MTCC drive to the archive. However, data from multiple MTCC’s can be integrated within a single archive by setting up a separate EasyMaldiArchive module for each MTCC which may or may not run in parallel.

#### Initialisation:
EasyMaldiArchive comprises of five batch-scripts (A_archive_maldispectra[.bat?], B_backup_to_localdrive.bat, C_create_key.bat, D_order_spectra.bat, and E_check_input.bat) which are stored in the EasyMaldi application directory. 
Manual initialisation steps are required for setting up EasyMaldiArchive (Fig. 2). First, create a spectra-archive-directory which may be initialised on any network drive which has sufficient storage space (approximately 315 MB/1000 Spectra) and is connected to the MTCC. Within this archive, create a subdirectory 'log_files' in which a text file named 'log_your_MTCC_indentifier' must be initialised. This text file serves as a log file and is initialised by writing the date of first Maldi measurements to the file (use format 20120101 for 1. January 2012 and end with a whitespace).
In the archive directory, also create a “data” directory and indicate its path in the definition section of “A_archive_maldispectra”.
Additional required script modifications include the path to the MTCC data directory (line xy), the path to the jq json parser (line xy), defining a MTCC-identifier (line xy) and indicating an appropriate high-speed drive (ideally C:\) with sufficient space (approximately 315 MB/1000 Spectra) for transitory data storage. 

#### Send Data to Archive:
Transferring spectral data from the MTCC to the archive is initiated by calling 'A_archive_maldispectra.bat' along the date of yesterday as an argument (use format for 1. January 2012). Example command (When executed on December 30th, 2023:
A_archive_maldispectra.bat 20231229

A_archive_maldispectra then calls several scripts in succession to each other (E_check_input.bat, B_backup_to_localdrive.bat, C_create_key.bat and D_order_spectra.bat) 

E_check_input.bat tests if the provided date of yesterday has the expected format (eight digits, fifth digit either one or zero, seventh digit either one, two, three or zero). 

B_backup_to_localdrive.bat retrieves the date of last archiving (or date of first measurement during first execution) from the log file, saves the date of today there, and copies all data generated between last archiving and yesterday to the defined high-speed drive. Ensure sufficient space on this drive (~315 MB/1000 Spectra).

C_create_key.bat uses the jq parser (xy) and the ‘info’ json object (fig xy) to translate Bruker AnalyteUid’s into LII’s and prints these identifiers along paths to their spectra, and years of measurement into a text file. The year of measurement is extracted from the json-object 'statusInfo.json' within the Bruker data structure (fig xy).

D_order_spectra.bat uses the generated text file as a dictionary to reorganise the spectral data structure (Fig xy). The resulting structure is based on the MTCC-identifier, the year of spectra measurement, the LII, the isolate identifier and on the technical replicate number (spectra_n).

A_archive_maldispectra finally sends this data structure to the Maldi archive and deletes all directories used for reorganisation on the high-speed drive.

### EasyMaldiExtract:
The EasyMaldiExtract module comprises of the script get_maldispectra.bat and uses a user-provided query text file that lists years of spectra measurements along LII’s and extracts associated spectral data from the archive (Figure xy). EasyMaldiExtract will consider data of all MTCC’s integrated within the archive.

#### Create Query text file:
The query text file defines which analyte associated spectra are to be retrieved from the archive. Each line lists one analyte and consists of the measurement year followed by its LII using a whitespace as delimeter. An example file is stored at XYZ.

#### Extract Spectra
Get_maldispectra.bat extracts spectral data using the query text file. Three script lines of the definition section must be modified before execution, including the path to the query file [this should be input when starting the file], the path to the archive [again input], and the path to the designated output directory [input]. If no file and paths are given, it uses the default input in the config.txt file. The execution of this script extracts spectra from the archive and the resulting directory structure is equivalent as in the archive (Fig. xy bottom).


