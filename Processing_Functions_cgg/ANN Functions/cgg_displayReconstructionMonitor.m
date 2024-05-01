function cgg_displayReconstructionMonitor(monitor,Y_Classification_Training,Y_Reconstruction_Training,T_Classification_Training,T_Reconstruction_Training,Y_Classification_Validation,Y_Reconstruction_Validation,T_Classification_Validation,T_Reconstruction_Validation,ClassNames,Iteration,BatchIDX)
%CGG_DISPLAYRECONSTRUCTIONMONITOR Summary of this function goes here
%   Detailed explanation goes here

[NumChannels,~,NumAreas,NumBatches,~]=size(Y_Reconstruction_Training);

this_Channel = randi(NumChannels);
this_Area = randi(NumAreas);
% this_Batch = randi(NumBatches);
this_Batch = BatchIDX;

this_Y_Reconstruction_Training = Y_Reconstruction_Training(this_Channel,:,this_Area,this_Batch,:);
this_Y_Reconstruction_Training = double(extractdata(this_Y_Reconstruction_Training));
this_Y_Reconstruction_Training = squeeze(this_Y_Reconstruction_Training);
this_Y_Reconstruction_Training = num2cell(this_Y_Reconstruction_Training,1);

this_T_Reconstruction_Training = T_Reconstruction_Training(this_Channel,:,this_Area,this_Batch,:);
this_T_Reconstruction_Training = double(extractdata(this_T_Reconstruction_Training));
this_T_Reconstruction_Training = squeeze(this_T_Reconstruction_Training);
this_T_Reconstruction_Training = num2cell(this_T_Reconstruction_Training,1);

this_Y_Reconstruction_Validation = Y_Reconstruction_Validation(this_Channel,:,this_Area,this_Batch,:);
this_Y_Reconstruction_Validation = double(extractdata(this_Y_Reconstruction_Validation));
this_Y_Reconstruction_Validation = squeeze(this_Y_Reconstruction_Validation);
this_Y_Reconstruction_Validation = num2cell(this_Y_Reconstruction_Validation,1);

this_T_Reconstruction_Validation = T_Reconstruction_Validation(this_Channel,:,this_Area,this_Batch,:);
this_T_Reconstruction_Validation = double(extractdata(this_T_Reconstruction_Validation));
this_T_Reconstruction_Validation = squeeze(this_T_Reconstruction_Validation);
this_T_Reconstruction_Validation = num2cell(this_T_Reconstruction_Validation,1);

%%

PlotUpdate_Training = struct();
PlotUpdate_Validation = struct();

PlotUpdate_Training.GroundTruth = this_T_Reconstruction_Training;
PlotUpdate_Training.Reconstruction = this_Y_Reconstruction_Training;

PlotUpdate_Validation.GroundTruth = this_T_Reconstruction_Validation;
PlotUpdate_Validation.Reconstruction = this_Y_Reconstruction_Validation;

%%

updatePlotReconstruction(monitor,"ReconstructionTraining",PlotUpdate_Training);
updatePlotReconstruction(monitor,"ReconstructionValidation",PlotUpdate_Validation);

%%

NumDimensions = length(ClassNames);


for didx = 1:NumDimensions

   NumClasses = length(ClassNames{didx});

   this_Data_Classification_Training = Y_Classification_Training{didx};
   this_Data_Classification_Training = this_Data_Classification_Training(:,this_Batch,:);
   this_Data_Classification_Training = double(extractdata(this_Data_Classification_Training));

   this_Data_Classification_Validation = Y_Classification_Validation{didx};
   this_Data_Classification_Validation = this_Data_Classification_Validation(:,this_Batch,:);
   this_Data_Classification_Validation = double(extractdata(this_Data_Classification_Validation));

   PlotUpdate_Training = [];
   PlotUpdate_Validation = [];
  
   for cidx = 1:NumClasses
        this_PlotUpdate_Training = table({squeeze(this_Data_Classification_Training(cidx,:,:))},ClassNames{didx}(cidx),'VariableNames',{'Data','Name'});
        PlotUpdate_Training = [PlotUpdate_Training;this_PlotUpdate_Training];
        this_PlotUpdate_Validation = table({squeeze(this_Data_Classification_Validation(cidx,:,:))},ClassNames{didx}(cidx),'VariableNames',{'Data','Name'});
        PlotUpdate_Validation = [PlotUpdate_Validation;this_PlotUpdate_Validation];
   end

    % PlotUpdate_Validation = 

    %%

updatePlotSingleClassification(monitor,"DimensionTraining",PlotUpdate_Training,didx);
updatePlotSingleClassification(monitor,"DimensionValidation",PlotUpdate_Validation,didx);

end

%%

% disp(T_Classification_Training.dims)
% disp(size(T_Classification_Training))

if NumDimensions~=0
FeaturesTrueTraining=squeeze(extractdata(T_Classification_Training(:,this_Batch,:)));
FeaturesTrueValidation=squeeze(extractdata(T_Classification_Validation(:,this_Batch,:)));
end

SubTitle_Training = 'Training: [%d';
SubTitle_Validation = 'Validation: [%d';
for didx = 2:NumDimensions
    SubTitle_Training = [SubTitle_Training ',%d'];
    SubTitle_Validation = [SubTitle_Validation ',%d'];
end
SubTitle_Training = [SubTitle_Training ']'];
SubTitle_Validation = [SubTitle_Validation ']'];

this_Title={sprintf(SubTitle_Training,FeaturesTrueTraining), sprintf(SubTitle_Validation,FeaturesTrueValidation), sprintf('Area: %d, Channel: %d',this_Area,this_Channel)};

%%
updatePlotTitle(monitor,this_Title)

%%

%%

updateIteration(monitor,Iteration);
savePlot(monitor);

end

