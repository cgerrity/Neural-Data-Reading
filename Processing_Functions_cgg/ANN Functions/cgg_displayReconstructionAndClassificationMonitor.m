function cgg_displayReconstructionAndClassificationMonitor(data,monitor)
%CGG_DISPLAYRECONSTRUCTIONMONITORFULL Summary of this function goes here
%   Detailed explanation goes here
% isfunction=exist('varargin','var');

ClassNames = data{1};
Iteration = data{2};

Y_Classification_Training=data{3};
Y_Reconstruction_Training=data{4};
Y_Classification_Validation=data{5};
Y_Reconstruction_Validation=data{6};

T_Classification_Training=data{7};
T_Reconstruction_Training=data{8};
T_Classification_Validation=data{9};
T_Reconstruction_Validation=data{10};

NumReconstructionMonitorExamples=data{11};
IsOptimal=data{12};

[~,~,~,NumBatches,~]=size(Y_Reconstruction_Training);

%%

ExampleNumber = 0;
for idx = 1:NumReconstructionMonitorExamples
    this_BatchIDX=mod(idx-1,NumBatches)+1;
    ExampleNumber = ExampleNumber + 1;
cgg_displayReconstructionMonitor(monitor,Y_Classification_Training,Y_Reconstruction_Training,T_Classification_Training,T_Reconstruction_Training,Y_Classification_Validation,Y_Reconstruction_Validation,T_Classification_Validation,T_Reconstruction_Validation,ClassNames,Iteration,this_BatchIDX,false,ExampleNumber);
end
resetExampleTerm(monitor);

ExampleNumber = 0;
if IsOptimal
for idx = 1:NumReconstructionMonitorExamples
    this_BatchIDX=mod(idx-1,NumBatches)+1;
    ExampleNumber = ExampleNumber + 1;
cgg_displayReconstructionMonitor(monitor,Y_Classification_Training,Y_Reconstruction_Training,T_Classification_Training,T_Reconstruction_Training,Y_Classification_Validation,Y_Reconstruction_Validation,T_Classification_Validation,T_Reconstruction_Validation,ClassNames,Iteration,this_BatchIDX,IsOptimal,ExampleNumber);
end
resetExampleTerm(monitor);
end

end

