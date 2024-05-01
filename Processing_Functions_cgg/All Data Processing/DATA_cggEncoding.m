%% DATA_cggDecoding

clc; clear; close all;

Fold_Start=1;
Fold_End=10;

for fidx=Fold_Start:Fold_End
Fold=fidx;

cgg_runAutoEncoder(Fold);
end