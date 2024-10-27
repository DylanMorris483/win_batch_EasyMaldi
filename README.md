# EasyMaldi
EasyMaldi enables laboratory-internal-indentifier (LII) based access and retrieval of spectral data of Burker Biotyper® systems on computers with no installation permissions and therefore is tailored for the usage in clinical laboratories. 

The goal for this software was fourfold: (i) No installation required on a windows machine, (ii) no human interaction required, (iii) data is organized according to LIIs minimal impact on performance of the system. Runtime considerations were not made, since the software is expected to run when the machine is idle.

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


## Instructions



