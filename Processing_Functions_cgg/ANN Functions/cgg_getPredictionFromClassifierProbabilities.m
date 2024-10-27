function [Window_Prediction,Window_TrueValue,lossClassification] = cgg_getPredictionFromClassifierProbabilities(T,Y,ClassNames,varargin)
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
%%

IsWeightedLoss = iscell(Weights) && ~isempty(Weights);
NumDimensions=length(ClassNames);

% lossClassification=0;
% lossClassification=cell(1,NumDimensions);
lossClassification=dlarray(NaN(1,NumDimensions));

Window_ClassConfidence=cell(1,NumDimensions);
Window_Prediction = NaN(NumDimensions,NumTrials,NumTimeSteps);
Window_TrueValue = NaN(NumDimensions,NumTrials,NumTimeSteps);

%%

if ~iscell(LossType)
LossType = repmat({LossType},1,NumDimensions);
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

    this_T_Encoded_Repeated=repmat(this_T_Encoded,1,1,NumTimeSteps);
    this_T_Encoded_Repeated=dlarray(this_T_Encoded_Repeated,this_Y.dims);

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

        this_ClassConfidenceTMP=double(extractdata(TargetProbabilities_New));
        this_ClassConfidenceTMP=this_ClassConfidenceTMP(:,:);
        ClassConfidenceTMP{didx}=this_ClassConfidenceTMP;

        this_T_Encoded_Repeated=repmat(this_T_Encoded,1,1,NumTimeSteps);
        this_T_Encoded_Repeated=dlarray(this_T_Rep,this_Y.dims);

        this_T_Decoded = squeeze(onehotdecode(this_T_Encoded_Repeated,ClassNames{didx},1));

        this_TrueValue=ClassNames{didx}(this_T_Decoded(:));
        this_Prediction=TargetSequence(:);

    case 'CrossEntropy'

        if wantLoss
        if isnan(this_Weights)
        loss = crossentropy(this_Y,this_T_Encoded_Repeated);
        else
        loss = crossentropy(this_Y,this_T_Encoded_Repeated,this_Weights);
        end
        end

    case 'Classification'

        if wantLoss
        if isnan(this_Weights)
        loss = crossentropy(this_Y,this_T_Encoded_Repeated);
        else
        loss = crossentropy(this_Y,this_T_Encoded_Repeated,this_Weights);
        end
        end

    otherwise

        if wantLoss
        if isnan(this_Weights)
        loss = crossentropy(this_Y,this_T_Encoded_Repeated);
        else
        loss = crossentropy(this_Y,this_T_Encoded_Repeated,this_Weights);
        end
        end

end

this_Window_ClassConfidence=double(extractdata(this_Y));
Window_ClassConfidence{didx}=this_Window_ClassConfidence;

this_T_Decoded = onehotdecode(this_T_Encoded_Repeated,ClassNames{didx},1);
this_Y_Decoded = onehotdecode(this_Y,ClassNames{didx},1);

this_Window_TrueValue=ClassNames{didx}(this_T_Decoded);
this_Window_Prediction=ClassNames{didx}(this_Y_Decoded);

Window_TrueValue(didx,:,:) = this_Window_TrueValue;
Window_Prediction(didx,:,:) = this_Window_Prediction;

if wantLoss
% lossClassification=lossClassification+loss;
% lossClassification{didx} = loss;
lossClassification(didx) = loss;
end

end

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
    end
end


end

