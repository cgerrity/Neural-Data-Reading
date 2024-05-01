%% DATA_cggDecoding

clc; clear; close all;

% cgg_getKFoldPartitions;

Fold_Start=1;
Fold_End=10;

Decoder='Logistic';
WindowStride=10;

% warning('on','all');

for fidx=Fold_Start:Fold_End
Fold=fidx;

cgg_runDecoder_v3(Fold,Decoder,'WindowStride',WindowStride);
end
