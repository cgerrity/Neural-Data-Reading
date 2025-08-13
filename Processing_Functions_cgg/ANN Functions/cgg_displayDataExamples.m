function cgg_displayDataExamples(InputNet,XTraining,TTraining,XValidation,TValidation,ClassNames,OutputInformation,Iteration,InFigure,varargin)
%CGG_DISPLAYDATAEXAMPLES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
RangeAll = CheckVararginPairs('RangeAll', [-4,4], varargin{:});
else
if ~(exist('RangeAll','var'))
RangeAll=[-4,4];
end
end

if isfunction
HistBinCount = CheckVararginPairs('HistBinCount', 50, varargin{:});
else
if ~(exist('HistBinCount','var'))
HistBinCount=50;
end
end

if isfunction
HistBinCount_Classifier = CheckVararginPairs('HistBinCount_Classifier', 40, varargin{:});
else
if ~(exist('HistBinCount_Classifier','var'))
HistBinCount_Classifier=40;
end
end

if isfunction
FaceAlpha_Classifier = CheckVararginPairs('FaceAlpha_Classifier', 0.1, varargin{:});
else
if ~(exist('FaceAlpha_Classifier','var'))
FaceAlpha_Classifier=0.1;
end
end

if isfunction
EdgeAlpha_Classifier = CheckVararginPairs('EdgeAlpha_Classifier', 0.3, varargin{:});
else
if ~(exist('EdgeAlpha_Classifier','var'))
EdgeAlpha_Classifier=0.3;
end
end

if isfunction
WantActivations = CheckVararginPairs('WantActivations', false, varargin{:});
else
if ~(exist('WantActivations','var'))
WantActivations=false;
end
end
%%

% figure(InFigure);
% clf;
clf(InFigure);
%%

% [NumChannels,NumSamples,NumAreas,NumBatches,NumWindows]=size(XTraining);
[NumChannels,~,NumAreas,NumBatches,NumWindows]=size(XTraining);

NumExamples=NumBatches;
BatchIDX=1:NumExamples;
ChannelIDX=randi(NumChannels,[1,NumExamples]);
AreaIDX=randi(NumAreas,[1,NumExamples]);
WindowIDX_Training=randi(NumWindows,[1,NumExamples]);
WindowIDX_Validation=WindowIDX_Training;

%%

NumClassifiers=length(OutputInformation.Classifier);
% NumReconstruction=length(OutputInformation.Reconstruction);

AllOutputNames=[OutputInformation.Classifier, OutputInformation.Reconstruction];

NumOutputs=length(AllOutputNames);
Y_Training=cell(NumOutputs,1);
Y_Validation=cell(NumOutputs,1);

% InputNet=resetState(InputNet);
InputNet=cgg_resetState(InputNet);
[Y_Training{:},~] = predict(InputNet,XTraining,Outputs=AllOutputNames);
% InputNet=resetState(InputNet);
InputNet=cgg_resetState(InputNet);
[Y_Validation{:},~] = predict(InputNet,XValidation,Outputs=AllOutputNames);

Y_Classification_Training=Y_Training(1:NumClassifiers);
Y_Reconstruction_Training=Y_Training{NumClassifiers+1:end};
Y_Classification_Validation=Y_Validation(1:NumClassifiers);
Y_Reconstruction_Validation=Y_Validation{NumClassifiers+1:end};

%%

selectionFun_Training=@(x_array) dlarray(cell2mat(arrayfun(@(x1,x2) cgg_extractData(x_array(:,x1,x2)),BatchIDX,WindowIDX_Training,"UniformOutput",false)),'CBT');
TargetProbabilities_Training=cellfun(@(x) selectionFun_Training(x),Y_Classification_Training,"UniformOutput",false);

selectionFun_Validation=@(x_array) dlarray(cell2mat(arrayfun(@(x1,x2) cgg_extractData(x_array(:,x1,x2)),BatchIDX,WindowIDX_Validation,"UniformOutput",false)),'CBT');
TargetProbabilities_Validation=cellfun(@(x) selectionFun_Validation(x),Y_Classification_Validation,"UniformOutput",false);

%%

if NumClassifiers~=0
[Prediction_Training] = cgg_getPredictionsFromNetOutput(TargetProbabilities_Training,ClassNames);
[Prediction_Validation] = cgg_getPredictionsFromNetOutput(TargetProbabilities_Validation,ClassNames);
end

%%

% [~,GroupTotal_Training,Groups_Training]=unique(Prediction_Training,"rows");
% [~,GroupTotal_Validation,Groups_Validation]=unique(Prediction_Validation,"rows");
% 
% GroupTotal_Training=length(GroupTotal_Training);
% GroupTotal_Validation=length(GroupTotal_Validation);

%%

NumClassifierColumns=ceil(NumClassifiers/2);
NumClassifierRows=min([ceil(NumClassifiers/2),2]);

% NumColumns=NumExamples+1+NumClassifierColumns;

% Tiled_Plot=tiledlayout(2,NumColumns);
% 
% Example_Height=1;
Example_Width=1;

NumAdditionalColumns=max([NumClassifierColumns,2]);
NumColumns=(NumExamples)*Example_Width+NumAdditionalColumns;
NumRows=(NumClassifierRows==1)*2+(NumClassifierRows==2)*3*2+(NumClassifierRows==0)*2;

Tiled_Plot=tiledlayout(NumRows,NumColumns);

RowsPerExample=NumRows/2;
ColumnsPerExample=(NumColumns-NumAdditionalColumns)/NumExamples;

RowsPerAdditional=NumRows/((NumClassifierRows==1)*2+(NumClassifierRows==2)*3+(NumClassifierRows==0)*2);
ColumnsPerAdditional=1;

% Tiled_Plot=tiledlayout(2,NumExamples);

%%

Title_Plot=sprintf('Iteration %d',Iteration);

title(Tiled_Plot,Title_Plot);

for eidx=1:NumExamples
    %Training
sel_Channel=ChannelIDX(eidx);
sel_Area=AreaIDX(eidx);
sel_Batch=BatchIDX(eidx);
sel_Window=WindowIDX_Training(eidx);

if NumClassifiers~=0
FeaturesTrueTraining=TTraining(:,sel_Batch,:);
FeaturesPredictionTraining=Prediction_Training(sel_Batch,:);
end

this_Y=XTraining(sel_Channel,:,sel_Area,sel_Batch,sel_Window);
this_Y_Reconstruction=Y_Reconstruction_Training(sel_Channel,:,sel_Area,sel_Batch,sel_Window);
this_X_Plot=1:length(this_Y);

this_TileIDX=tilenum(Tiled_Plot,1,(eidx-1)*ColumnsPerExample+1);

nexttile(this_TileIDX,[RowsPerExample,ColumnsPerExample]);
plot(this_X_Plot,this_Y,this_X_Plot,this_Y_Reconstruction);

if ~isempty(RangeAll)
    ylim(RangeAll);
end

if NumClassifiers~=0
% this_Title=sprintf('True: [%d,%d,%d,%d] Prediction: [%d,%d,%d,%d], Area: %d',FeaturesTrueTraining,FeaturesPredictionTraining,sel_Area);
this_Title={sprintf('True: [%d,%d,%d,%d]',FeaturesTrueTraining), sprintf('Prediction: [%d,%d,%d,%d]',FeaturesPredictionTraining), sprintf('Area: %d, Window: %d%%',sel_Area,round(sel_Window/NumWindows*100))};
% this_Title={sprintf('True: [%d,%d,%d,%d] Prediction: [%d,%d,%d,%d]',FeaturesTrueTraining,FeaturesPredictionTraining), sprintf('Area: %d, Window: %d%%',sel_Area,round(sel_Window/NumWindows*100))};
title(this_Title);
end

if eidx==1
ylabel('Training');
end

% Validation
sel_Channel=ChannelIDX(eidx);
sel_Area=AreaIDX(eidx);
sel_Window=WindowIDX_Validation(eidx);

if NumClassifiers~=0
FeaturesTrueValidation=TValidation(:,sel_Batch,:);
FeaturesPredictionValidation=Prediction_Validation(sel_Batch,:);
end

this_Y=XValidation(sel_Channel,:,sel_Area,sel_Batch,sel_Window);
this_Y_Reconstruction=Y_Reconstruction_Validation(sel_Channel,:,sel_Area,sel_Batch,sel_Window);
this_X_Plot=1:length(this_Y);

this_TileIDX=tilenum(Tiled_Plot,RowsPerExample+1,(eidx-1)*ColumnsPerExample+1);

% nexttile(eidx+NumColumns,[RowsPerExample,ColumnsPerExample]);
nexttile(this_TileIDX,[RowsPerExample,ColumnsPerExample]);
plot(this_X_Plot,this_Y,this_X_Plot,this_Y_Reconstruction);

if ~isempty(RangeAll)
    ylim(RangeAll);
end

if NumClassifiers~=0
% this_Title=sprintf('True: [%d,%d,%d,%d] Prediction: [%d,%d,%d,%d], Area: %d',FeaturesTrueValidation,FeaturesPredictionValidation,sel_Area);
this_Title={sprintf('True: [%d,%d,%d,%d]',FeaturesTrueValidation), sprintf('Prediction: [%d,%d,%d,%d]',FeaturesPredictionValidation), sprintf('Area: %d, Window: %d%%',sel_Area,round(sel_Window/NumWindows*100))};
% this_Title={sprintf('True: [%d,%d,%d,%d] Prediction: [%d,%d,%d,%d]',FeaturesTrueValidation,FeaturesPredictionValidation), sprintf('Area: %d, Window: %d%%',sel_Area,round(sel_Window/NumWindows*100))};
title(this_Title);
end

if eidx==1
ylabel('Validation');
end

end

%%

IsSkip=any(contains({InputNet.Layers(:).Name},"concatenation_Skip"));
IsRecurrent=any(contains(InputNet.Learnables.Parameter,"Recurrent"));
IsConvolutional=any(contains({InputNet.Layers(:).Name},"convolutional"));

OutputIDX=InputNet.Learnables.Layer=="fc_Decoder_Out";
if IsConvolutional
OutputIDX=contains(InputNet.Learnables.Layer,"point-wise_convolutional_Decoder_1");
end
WeightIDX=InputNet.Learnables.Parameter=="Weights";
OutputWeightIDX=OutputIDX & WeightIDX;

BottleNeckIDX=contains(InputNet.Learnables.Layer,"Encoder");
BottleNeckWeightIDX=BottleNeckIDX & WeightIDX;
BottleNeckWeightIDX=find(BottleNeckWeightIDX,1,'last');

RecurrentWeightIDX=contains(InputNet.Learnables.Parameter,"Recurrent");
BottleNeckRecurrentWeightIDX=BottleNeckIDX & RecurrentWeightIDX;
BottleNeckRecurrentWeightIDX=find(BottleNeckRecurrentWeightIDX,1,'last');

OutputWeights=InputNet.Learnables.Value(OutputWeightIDX,1);
OutputWeights = cellfun(@(x) double(cgg_extractData(x)), OutputWeights, 'UniformOutput', false);
OutputWeights = cell2mat(OutputWeights);
if IsRecurrent
BottleNeckWeights=double(cgg_extractData(InputNet.Learnables.Value{BottleNeckRecurrentWeightIDX,1}));
else
BottleNeckWeights=double(cgg_extractData(InputNet.Learnables.Value{BottleNeckWeightIDX,1}));
end

if IsSkip
    [~,NumHiddenOut] = size(OutputWeights);
    ReconstructionPathIDX=1:floor(NumHiddenOut/2);
    SkipPathIDX=ReconstructionPathIDX+floor(NumHiddenOut/2);
    
    ReconstructionWeights=OutputWeights(:,ReconstructionPathIDX);
    SkipWeights=OutputWeights(:,SkipPathIDX);
else
    ReconstructionWeights=OutputWeights;
end

if WantActivations
    BottleNeckActivationIDX=contains({InputNet.Layers(:).Name},"crop_Decoder_1");
    BottleNeckActivationIDX = find(BottleNeckActivationIDX,1,'last');
    % InputNet=resetState(InputNet);
    InputNet=cgg_resetState(InputNet);
    [Y_Activation_Training,~] = predict(InputNet,XTraining,Outputs=InputNet.Layers(BottleNeckActivationIDX).Name);
    Y_Activation_Training = cgg_extractData(Y_Activation_Training);
end

this_TileIDX=tilenum(Tiled_Plot,1,ColumnsPerExample*NumExamples+1);

nexttile(this_TileIDX,[RowsPerAdditional,ColumnsPerAdditional]);

h_first=histogram(ReconstructionWeights,HistBinCount,'Normalization','pdf');
title({'Reconstruction Path', 'Output Weights'});

ylim([0,ceil(max(h_first.Values/5))*5]);

this_TileIDX=tilenum(Tiled_Plot,1,ColumnsPerExample*NumExamples+ColumnsPerAdditional+1);

% nexttile(NumColumns+NumExamples+1);
nexttile(this_TileIDX,[RowsPerAdditional,ColumnsPerAdditional]);

if WantActivations
    h_second=histogram(Y_Activation_Training,'Normalization','pdf');
    title({'BottleNeck', 'Activations'});
elseif IsSkip
    h_second=histogram(SkipWeights,h_first.BinEdges,'Normalization','pdf');
    title({'Skip Path', 'Output Weights'});
elseif IsRecurrent
    h_second=histogram(BottleNeckWeights,h_first.BinEdges,'Normalization','pdf');
    title({'Recurrent Bottleneck', 'Output Weights'});
else
    h_second=histogram(BottleNeckWeights,h_first.BinEdges,'Normalization','pdf');
    title({'Bottleneck', 'Output Weights'});
end

% histogram(ReconstructionWeights,h_first.BinEdges,'Normalization','pdf');
% title({'Reconstruction Path', 'Output Weights'});
if ~WantActivations
ylim([0,ceil(max(h_first.Values/5))*5]);
end
%%

AllClassifierHist_Cell=cell(1,NumClassifiers);
AllClassifierHist_Max=-Inf;
AllClassifierHist_Min=Inf;
AllClassifierHistValue_Max=0;

for cidx=1:NumClassifiers
this_ConnectionIDX=InputNet.Connections.Destination==OutputInformation.Classifier(cidx);
this_LayerName=InputNet.Connections.Source(this_ConnectionIDX);

this_OutputIDX=InputNet.Learnables.Layer==this_LayerName;
this_OutputWeightIDX=this_OutputIDX & WeightIDX;

this_OutputWeights=double(cgg_extractData(InputNet.Learnables.Value{this_OutputWeightIDX,1}));

[this_NumClasses,~] = size(this_OutputWeights);

AllClassifierHist_Cell{cidx}=cell(1,this_NumClasses);

this_ColumninClassifier=mod(cidx-1,NumClassifierColumns)+1;
this_RowinClassifier=round(cidx/2/NumClassifierColumns,...
    TieBreaker="minusinf")+1;

tilenum(Tiled_Plot,this_RowinClassifier,(NumExamples+1)+this_ColumninClassifier);

% this_TileIDX=tilenum(Tiled_Plot,this_RowinClassifier,(NumExamples+1)+...
%     this_ColumninClassifier);

this_TileIDX=tilenum(Tiled_Plot,this_RowinClassifier*RowsPerAdditional+1,...
    ColumnsPerExample*NumExamples+this_ColumninClassifier);

nexttile(this_TileIDX,[RowsPerAdditional,ColumnsPerAdditional]);

for ccidx=1:this_NumClasses
    if ccidx==2
        hold on
    end

this_hist=histogram(this_OutputWeights(ccidx,:),HistBinCount_Classifier,...
    'Normalization','pdf','FaceAlpha',FaceAlpha_Classifier,...
    'EdgeAlpha',EdgeAlpha_Classifier);
AllClassifierHist_Min=min([AllClassifierHist_Min,this_hist.BinLimits(1)]);
AllClassifierHist_Max=max([AllClassifierHist_Max,this_hist.BinLimits(2)]);
AllClassifierHistValue_Max=max([AllClassifierHistValue_Max,this_hist.Values]);
AllClassifierHist_Cell{cidx}{ccidx}=this_hist;
end

hold off
title({sprintf('Dimension %d',cidx), 'Output Weights'});
ylim([0,12]);

end

ClassifierBinLimits=[AllClassifierHist_Min,AllClassifierHist_Max];
ClassifierBinRange=AllClassifierHist_Max-AllClassifierHist_Min;
ClassifierBinWidth=ClassifierBinRange/HistBinCount_Classifier;

for cidx=1:NumClassifiers
    this_NumClasses=length(AllClassifierHist_Cell{cidx});
    for ccidx=1:this_NumClasses
        AllClassifierHist_Cell{cidx}{ccidx}.BinLimits=ClassifierBinLimits;
        AllClassifierHist_Cell{cidx}{ccidx}.BinWidth=ClassifierBinWidth;
    end
end

drawnow;

% InFigure.Visible = 'off';
end

