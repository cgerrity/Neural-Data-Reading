%% DATA_cggDecoding

clc; clear; close all;

% cgg_getKFoldPartitions;

Fold_Start=5;
Fold_End=7;

for fidx=Fold_Start:Fold_End
Fold=fidx;

cgg_runDecoder(Fold)
end
