%% DATA_cggDecoding

clc; clear; close all;

% cgg_getKFoldPartitions;

Fold_Start=1;
Fold_End=4;

for fidx=Fold_Start:Fold_End
Fold=fidx;

cgg_runDecoder(Fold)
end
