All code for Neural Decoder by Charles Gerrity are found in this repository. By convention functions are named using the initials of the original author (i.e. "cgg_")

To run on different data or different machines adjustment of parameters files and the function cgg_getBaseFolders are required.

Scripts for preprocessing and processing are run using DATA_cggAllSessionPreProcessing_v2 and DATA_cggAllSessionProcessing respectively. Once the data from all sessions has been processed it is aggregated into one folder using DATA_cggAllSessionEpochedDataAggregation.

To run a model use the function cgg_runAutoEncoder with Name Value inputs using optional user specified model variables that can be found in PARAMETERS_cgg_runAutoEncoder. This will run a single fold of model training and provide training figures.

Code for generation of figures is in the script FIGURE_cggAllNetworkEncoderResults

This will generate:
1) Bar plots for peak accuracy using cgg_plotOverallAccuracy.
2) Bar plots for peak accuracy split by trial filters (e.g. Dimensionality) using cgg_plotSplitAccuracy
3) Accuracy over time plots using cgg_plotWindowedAccuracy
4) Accuracy over time plots split by trial filters using cgg_plotSplitWindowedAccuracy
5) Importance analysis plots using cgg_plotOverallImportanceAnalysis
6) Parameter sweep plots using cgg_plotParameterSweep
