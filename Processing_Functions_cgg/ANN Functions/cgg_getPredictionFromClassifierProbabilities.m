function [Window_Prediction,Window_TrueValue,lossClassification,...
    Aggregation_Prediction,Aggregation_TrueValue,loss_Confidence, ...
    loss_TrialConfidence,loss_TaskConfidence] = ...
    cgg_getPredictionFromClassifierProbabilities(T,Y,ClassNames,varargin)
%CGG_GETPREDICTIONFROMCLASSIFIERPROBABILITIES Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
wantLoss = CheckVararginPairs('wantLoss', true, varargin{:});
else
if ~(exist('wantLoss','var'))
wantLoss=true;
end
end

if isfunction
Weights = CheckVararginPairs('Weights', cell(0), varargin{:});
else
if ~(exist('Weights','var'))
Weights=cell(0);
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
NumTimeSteps = CheckVararginPairs('NumTimeSteps', size(Y{1},finddim(Y{1},"T")), varargin{:});
else
if ~(exist('NumTimeSteps','var'))
NumTimeSteps=size(Y{1},finddim(Y{1},"T"));
end
end

if isfunction
NumTrials = CheckVararginPairs('NumBatches', size(Y{1},finddim(Y{1},"B")), varargin{:});
else
if ~(exist('NumBatches','var'))
NumTrials=size(Y{1},finddim(Y{1},"B"));
end
end

if isfunction
LossType = CheckVararginPairs('LossType', 'CrossEntropy', varargin{:});
else
if ~(exist('LossType','var'))
LossType='CrossEntropy';
end
end

if isfunction
MultipleInstanceLearningType = CheckVararginPairs('MultipleInstanceLearningType', 'None', varargin{:});
else
if ~(exist('MultipleInstanceLearningType','var'))
MultipleInstanceLearningType='None';
end
end

if isfunction
TrialConfidence = CheckVararginPairs('TrialConfidence', [], varargin{:});
else
if ~(exist('TrialConfidence','var'))
TrialConfidence=[];
end
end

if isfunction
TaskConfidence = CheckVararginPairs('TaskConfidence', {}, varargin{:});
else
if ~(exist('TaskConfidence','var'))
TaskConfidence={};
end
end

if isfunction
DatasetConfidence = CheckVararginPairs('DatasetConfidence', [], varargin{:});
else
if ~(exist('DatasetConfidence','var'))
DatasetConfidence=[];
end
end

if isfunction
BatchFraction = CheckVararginPairs('BatchFraction', 1, varargin{:});
else
if ~(exist('BatchFraction','var'))
BatchFraction=1;
end
end
%%

IsWeightedLoss = iscell(Weights) && ~isempty(Weights);
NumDimensions=length(ClassNames);

% lossClassification=0;
% lossClassification=cell(1,NumDimensions);
lossClassification=dlarray(NaN(1,NumDimensions));
loss_Confidence=dlarray(NaN(1,NumDimensions));
loss_TrialConfidence=dlarray(NaN(1,NumDimensions));
loss_TaskConfidence=dlarray(NaN(1,NumDimensions));

Window_ClassConfidence=cell(1,NumDimensions);
Window_Prediction = NaN(NumDimensions,NumTrials,NumTimeSteps);
Window_TrueValue = NaN(NumDimensions,NumTrials,NumTimeSteps);

Aggregation_ClassConfidence=cell(1,NumDimensions);
Aggregation_Prediction = NaN(NumDimensions,NumTrials,1);
Aggregation_TrueValue = NaN(NumDimensions,NumTrials,1);

%%

if ~iscell(LossType)
LossType = repmat({LossType},1,NumDimensions);
end

%%

if isdlarray(TrialConfidence)
    % HasTrialConfidence = true;
    TrialConfidence = cgg_getLastSequenceValue(TrialConfidence);
end
if iscell(TaskConfidence) && length(TaskConfidence) == NumDimensions
    % HasTaskConfidence = true;
    TaskConfidence = cellfun(@(x) cgg_getLastSequenceValue(x),TaskConfidence,"UniformOutput",false);
else
    TaskConfidence = cell(1,NumDimensions);
end

%%

for didx=1:NumDimensions

    this_Y=Y{didx};
    this_T=T(didx,:,:);
    this_ClassNames=ClassNames{didx};
    this_NumClassNames=length(this_ClassNames);

    this_LossType = LossType{didx};

    if IsWeightedLoss
        this_Weights = Weights{didx};
    else
        this_Weights = NaN;
    end

    this_T_Encoded=onehotencode(this_T,1,'ClassNames',ClassNames{didx});

    SummationDimension_Y = [finddim(this_Y, 'S'), finddim(this_Y, 'T')];
    Confidence_Aggregation = sum(this_Y, SummationDimension_Y);

    this_T_Encoded_Repeated=repmat(this_T_Encoded,1,1,NumTimeSteps);
    this_T_Encoded_Repeated=dlarray(this_T_Encoded_Repeated,this_Y.dims);

    T_Aggregation=repmat(this_T_Encoded,1,1,1);
    T_Aggregation=dlarray(T_Aggregation,Confidence_Aggregation.dims);
    switch MultipleInstanceLearningType
        case 'MIL'
            this_Y_Loss = Confidence_Aggregation;
            this_T_Loss = T_Aggregation;
        case 'None'
            this_Y_Loss = this_Y;
            this_T_Loss = this_T_Encoded_Repeated;
            % SummationDimension_Confidence_Aggregation = [finddim(Confidence_Aggregation, 'S'), finddim(Confidence_Aggregation, 'C'), finddim(Confidence_Aggregation, 'T')];
            % SummationDimension_T_Aggregation = [finddim(T_Aggregation, 'S'), finddim(T_Aggregation, 'C'), finddim(T_Aggregation, 'T')];
            % Confidence_Aggregation = Confidence_Aggregation./ sum(cgg_extractData(Confidence_Aggregation),SummationDimension_Confidence_Aggregation);
            % T_Aggregation = T_Aggregation./ sum(cgg_extractData(T_Aggregation),SummationDimension_T_Aggregation);
        otherwise
            this_Y_Loss = this_Y;
            this_T_Loss = this_T_Encoded_Repeated;
            % SummationDimension_Confidence_Aggregation = [finddim(Confidence_Aggregation, 'S'), finddim(Confidence_Aggregation, 'C'), finddim(Confidence_Aggregation, 'T')];
            % SummationDimension_T_Aggregation = [finddim(T_Aggregation, 'S'), finddim(T_Aggregation, 'C'), finddim(T_Aggregation, 'T')];
            % Confidence_Aggregation = Confidence_Aggregation./ sum(cgg_extractData(Confidence_Aggregation),SummationDimension_Confidence_Aggregation);
            % T_Aggregation = T_Aggregation./ sum(cgg_extractData(T_Aggregation),SummationDimension_T_Aggregation);
    end

    SummationDimension_Confidence_Aggregation = [finddim(Confidence_Aggregation, 'S'), finddim(Confidence_Aggregation, 'C'), finddim(Confidence_Aggregation, 'T')];
    SummationDimension_T_Aggregation = [finddim(T_Aggregation, 'S'), finddim(T_Aggregation, 'C'), finddim(T_Aggregation, 'T')];
    Confidence_Aggregation = cgg_extractData(Confidence_Aggregation);
    T_Aggregation = cgg_extractData(T_Aggregation);
    Confidence_Aggregation = Confidence_Aggregation./ sum(Confidence_Aggregation,SummationDimension_Confidence_Aggregation);
    T_Aggregation = T_Aggregation./ sum(T_Aggregation,SummationDimension_T_Aggregation);

switch this_LossType
    case 'CTC'
        
        this_T_Encoded=onehotencode(this_T,1,'ClassNames',this_ClassNames);
        this_T_CTC = onehotdecode(this_T_Encoded,1:this_NumClassNames,1);
        this_T_CTC=double(this_T_CTC);

        this_T_CTC=dlarray(this_T_CTC,'TB');

        this_Y=dlarray(this_Y,'CBT');
        this_TMask=true(size(this_T_CTC));
        this_YMask=true(size(this_Y));

        loss = ctc(this_Y,this_T_CTC,this_YMask,this_TMask,'BlankIndex','last');

        [TargetSequence,TargetProbabilities_New] = cgg_getTargetSequenceFromCTC(this_Y,this_ClassNames);

        this_ClassConfidenceTMP=double(cgg_extractData(TargetProbabilities_New));
        this_ClassConfidenceTMP=this_ClassConfidenceTMP(:,:);
        ClassConfidenceTMP{didx}=this_ClassConfidenceTMP;

        this_T_Encoded_Repeated=repmat(this_T_Encoded,1,1,NumTimeSteps);
        this_T_Encoded_Repeated=dlarray(this_T_Rep,this_Y.dims);

        this_T_Decoded = squeeze(onehotdecode(this_T_Encoded_Repeated,ClassNames{didx},1));

        this_TrueValue=ClassNames{didx}(this_T_Decoded(:));
        this_Prediction=TargetSequence(:);

    case 'CrossEntropy'

        if wantLoss
            [loss,this_loss_Confidence,this_loss_TrialConfidence,...
                this_loss_TaskConfidence] = cgg_calcClassificationLoss(...
                this_T_Loss,this_Y_Loss,'LossType',this_LossType,...
                'Weights',this_Weights,'TrialConfidence',TrialConfidence,...
                'DatasetConfidence',DatasetConfidence, ...
                'BatchFraction',BatchFraction,...
                'TaskConfidence',TaskConfidence{didx});
        % if isnan(this_Weights)
        % % loss = crossentropy(this_Y,this_T_Encoded_Repeated);
        % loss = crossentropy(this_Y_Loss,this_T_Loss);
        % else
        % % loss = crossentropy(this_Y,this_T_Encoded_Repeated,this_Weights);
        % loss = crossentropy(this_Y_Loss,this_T_Loss,this_Weights);
        % end
        end

    case 'Classification'

        if wantLoss
            [loss,this_loss_Confidence,this_loss_TrialConfidence,...
                this_loss_TaskConfidence] = cgg_calcClassificationLoss(...
                this_T_Loss,this_Y_Loss,'LossType',this_LossType,...
                'Weights',this_Weights,'TrialConfidence',TrialConfidence,...
                'DatasetConfidence',DatasetConfidence, ...
                'BatchFraction',BatchFraction,...
                'TaskConfidence',TaskConfidence{didx});
        % if isnan(this_Weights)
        % % loss = crossentropy(this_Y,this_T_Encoded_Repeated);
        % loss = crossentropy(this_Y_Loss,this_T_Loss);
        % else
        % % loss = crossentropy(this_Y,this_T_Encoded_Repeated,this_Weights);
        % loss = crossentropy(this_Y_Loss,this_T_Loss,this_Weights);
        % end
        end

    otherwise

        if wantLoss
            [loss,this_loss_Confidence,this_loss_TrialConfidence,...
                this_loss_TaskConfidence] = cgg_calcClassificationLoss(...
                this_T_Loss,this_Y_Loss,'LossType',this_LossType,...
                'Weights',this_Weights,'TrialConfidence',TrialConfidence,...
                'DatasetConfidence',DatasetConfidence, ...
                'BatchFraction',BatchFraction,...
                'TaskConfidence',TaskConfidence{didx});
        % if isnan(this_Weights)
        % % loss = crossentropy(this_Y,this_T_Encoded_Repeated);
        % loss = crossentropy(this_Y_Loss,this_T_Loss);
        % else
        % % loss = crossentropy(this_Y,this_T_Encoded_Repeated,this_Weights);
        % loss = crossentropy(this_Y_Loss,this_T_Loss,this_Weights);
        % end
        end

end

this_Window_ClassConfidence=double(cgg_extractData(this_Y));
Window_ClassConfidence{didx}=this_Window_ClassConfidence;

this_T_Decoded = onehotdecode(this_T_Encoded_Repeated,ClassNames{didx},1);
this_Y_Decoded = onehotdecode(this_Y,ClassNames{didx},1);

this_Window_TrueValue=ClassNames{didx}(this_T_Decoded);
this_Window_Prediction=ClassNames{didx}(this_Y_Decoded);

Window_TrueValue(didx,:,:) = this_Window_TrueValue;
Window_Prediction(didx,:,:) = this_Window_Prediction;

%%
this_Aggregation_ClassConfidence=double(cgg_extractData(Confidence_Aggregation));
Aggregation_ClassConfidence{didx}=this_Aggregation_ClassConfidence;

try
this_T_Decoded = onehotdecode(T_Aggregation,ClassNames{didx},1);
catch
    T_Aggregation = T_Aggregation - 0.01;
disp(T_Aggregation);
this_T_Decoded = onehotdecode(T_Aggregation,ClassNames{didx},1);
end
try
this_Y_Decoded = onehotdecode(Confidence_Aggregation,ClassNames{didx},1);
catch
    Confidence_Aggregation = Confidence_Aggregation - 0.01;
disp(Confidence_Aggregation);
this_Y_Decoded = onehotdecode(Confidence_Aggregation,ClassNames{didx},1);
end

this_Aggregation_TrueValue=ClassNames{didx}(this_T_Decoded);
this_Aggregation_Prediction=ClassNames{didx}(this_Y_Decoded);

Aggregation_TrueValue(didx,:,:) = this_Aggregation_TrueValue;
Aggregation_Prediction(didx,:,:) = this_Aggregation_Prediction;

%%

if wantLoss
% lossClassification=lossClassification+loss;
% lossClassification{didx} = loss;
lossClassification(didx) = loss;
loss_Confidence(didx) = this_loss_Confidence;
loss_TrialConfidence(didx) = this_loss_TrialConfidence;
loss_TaskConfidence(didx) = this_loss_TaskConfidence;
end

end

%%

% if wantLoss
% loss_Confidence = sum(loss_Confidence,"all");
% end

%%

if IsQuaddle
    wantZeroFeatureDetector=false;
    for bidx=1:NumTrials
        for tidx=1:NumTimeSteps
            this_Window_Prediction = Window_Prediction(:,bidx,tidx)';
            this_Window_ClassConfidence = cellfun(@(x) x(:,bidx,tidx), Window_ClassConfidence,"UniformOutput",false);
        
            [this_Window_Prediction] = cgg_procQuaddleInterpreter(this_Window_Prediction,ClassNames,this_Window_ClassConfidence,wantZeroFeatureDetector);
            Window_Prediction(:,bidx,tidx) = this_Window_Prediction';
        end
        this_Aggregation_Prediction = Aggregation_Prediction(:,bidx,1)';
            this_Aggregation_ClassConfidence = cellfun(@(x) x(:,bidx,1), Aggregation_ClassConfidence,"UniformOutput",false);
        [this_Aggregation_Prediction] = cgg_procQuaddleInterpreter(this_Aggregation_Prediction,ClassNames,this_Aggregation_ClassConfidence,wantZeroFeatureDetector);
            Aggregation_Prediction(:,bidx,1) = this_Aggregation_Prediction';
    end
end

end

