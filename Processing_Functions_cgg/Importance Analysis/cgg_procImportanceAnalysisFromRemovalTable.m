function IA_Table = cgg_procImportanceAnalysisFromRemovalTable(RemovalTable, InDatastore, Encoder, Classifier, varargin)
%CGG_PROCIMPORTANCEANALYSISFROMREMOVALTABLE Summary of this function goes here
%   Detailed explanation goes here

cfg_IA = PARAMETERS_cggImportanceAnalysis();
%%

isfunction=exist('varargin','var');

if isfunction
ClassNames = CheckVararginPairs('ClassNames', {}, varargin{:});
else
if ~(exist('ClassNames','var'))
ClassNames={};
end
end

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', cfg_IA.maxworkerMiniBatchSize, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=cfg_IA.maxworkerMiniBatchSize;
end
end

if isfunction
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','CBT',''}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','CBT',''};
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
MinimumWorkers = CheckVararginPairs('MinimumWorkers', cfg_IA.MinimumWorkers_IA, varargin{:});
else
if ~(exist('MinimumWorkers','var'))
MinimumWorkers = cfg_IA.MinimumWorkers_IA;
end
end
%%
cgg_getParallelPool('RequireChange', true,'WantThreads',true);
%% Adjust mini-batch size for the number of workers
maxworkerMiniBatchSize = cgg_getValueBasedOnNumberOfWorkers(maxworkerMiniBatchSize,MinimumWorkers);
maxworkerMiniBatchSize = round(maxworkerMiniBatchSize);
%% Get Mini-Batch Queue

MaxMbq = minibatchqueue(InDatastore,...
        MiniBatchSize=maxworkerMiniBatchSize,...
        MiniBatchFormat=DataFormat);

%% Get Network Output Information

if isempty(ClassNames)
    [ClassNames,~,~,~,~] = cgg_getClassesFromDataStore(InDatastore);
end

NumDimensions = length(ClassNames);
OutputNames_Classifier = Classifier.OutputNames;
LossType_Classifier = repmat({'CrossEntropy'},1,NumDimensions);
LossType_Classifier(contains(OutputNames_Classifier,'CTC')) = {'CTC'};

%%
[~,totalMemoryGB] = cgg_getMemoryInformation('DisplayIndents',3);
%% Generate Waitbar

NumBatches = ceil(numpartitions(InDatastore)/maxworkerMiniBatchSize);
NumIA = height(RemovalTable);
NumIter = NumBatches*NumIA;
waitbar = parallel.pool.Constant(cgg_getWaitBar(...
    'All_Iterations',NumIter,'Process','Test Importance Analysis', ...
    'DisplayIndents', 3));

%% Initialize Values

CM_Table = cell([NumIA 1]);
IA_Table = RemovalTable;
IA_Table.CM_Table = CM_Table;

wantLoss = false;
Normalization_Factor = 0;
Loss_Classification_PerDimension = NaN;

ChannelRemoval = IA_Table.ChannelRemoved;
AreaRemoval = IA_Table.AreaRemoved;
LatentRemoval = IA_Table.LatentRemoved;
%% Get Mini-Batch Data

while hasdata(MaxMbq)

[X,T,DataNumber] = next(MaxMbq);
% Encoder=resetState(Encoder);
Encoder=cgg_resetState(Encoder);
[Y_Encoded] = predict(Encoder,X);

X_Parallel = parallel.pool.Constant(X);
Y_Encoded_Parallel = parallel.pool.Constant(Y_Encoded);
% if totalMemoryGB < 50
% cgg_getMemoryInformation();
% end
%% Pass Through Removals

parfor ridx = 1:NumIA
    % cgg_getMemoryInformation();
    this_ChannelRemoval = ChannelRemoval{ridx,:};
    this_AreaRemoval = AreaRemoval{ridx,:};
    this_LatentRemoval = LatentRemoval{ridx,:};

    HasChannelAreaRemoval = ~(any(isnan(this_ChannelRemoval)) ...
        || any(isnan(this_AreaRemoval)));
    HasLatentRemoval = ~any(isnan(this_LatentRemoval));

    % Encoder Pass
    if HasChannelAreaRemoval
        this_X = X_Parallel.Value;
        for acidx = 1:length(this_ChannelRemoval)
            this_cidx = this_ChannelRemoval(acidx);
            this_aidx = this_AreaRemoval(acidx);
            this_X(this_cidx,:,this_aidx,:,:) = 0;
        end
        [this_Y_Encoded] = cgg_procNetworkPass(this_X,Encoder);
    else
        this_Y_Encoded = Y_Encoded_Parallel.Value;
    end

    if HasLatentRemoval
        this_Y_Encoded(this_LatentRemoval,:,:) = 0;
    end

    % Classifier Pass
    [Y_Classified,~] = cgg_procNetworkPass(this_Y_Encoded,Classifier,'OutputNames',OutputNames_Classifier);

    %% Get CM_Table

    this_CM_Table = CM_Table{ridx};

    [~,this_CM_Table] = cgg_getClassifierOutputsFromProbabilities(...
    T,Y_Classified,ClassNames,DataNumber,...
    Loss_Classification_PerDimension,this_CM_Table,Normalization_Factor,...
    'IsQuaddle',IsQuaddle,'wantLoss',wantLoss,...
    'LossType',LossType_Classifier);

    CM_Table{ridx}=this_CM_Table;
    waitbar.Value.update();
end
end
%% Add CM_Table to IA_Table

IA_Table.CM_Table=CM_Table;
end

