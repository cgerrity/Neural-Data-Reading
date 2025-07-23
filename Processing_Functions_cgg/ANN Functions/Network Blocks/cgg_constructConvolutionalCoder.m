function CoderBlock = cgg_constructConvolutionalCoder(FilterSizes,FilterHiddenSizes,InputSize,varargin)
%CGG_CONSTRUCTCONVOLUTIONALCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantSplitAreas = CheckVararginPairs('WantSplitAreas', true, varargin{:});
else
if ~(exist('WantSplitAreas','var'))
WantSplitAreas=true;
end
end

if isfunction
Stride = CheckVararginPairs('Stride', 2, varargin{:});
else
if ~(exist('Stride','var'))
Stride=2;
end
end

if isfunction
Coder = CheckVararginPairs('Coder', 'Encoder', varargin{:});
else
if ~(exist('Coder','var'))
Coder='Encoder';
end
end

if isfunction
FinalActivation = CheckVararginPairs('FinalActivation', 'None', varargin{:});
else
if ~(exist('FinalActivation','var'))
FinalActivation='None';
end
end

if isfunction
Activation = CheckVararginPairs('Activation', 'ReLU', varargin{:});
else
if ~(exist('Activation','var'))
Activation='ReLU';
end
end

if isfunction
WantLearnableScale = CheckVararginPairs('WantLearnableScale', true, varargin{:});
else
if ~(exist('WantLearnableScale','var'))
WantLearnableScale=true;
end
end

if isfunction
WantLearnableOffset = CheckVararginPairs('WantLearnableOffset', true, varargin{:});
else
if ~(exist('WantLearnableOffset','var'))
WantLearnableOffset=true;
end
end

if isfunction
UniqueDimension = CheckVararginPairs('UniqueDimension', [1,3], varargin{:});
else
if ~(exist('UniqueDimension','var'))
UniqueDimension=[1,3];
end
end

if isfunction
HiddenSizeAugment = CheckVararginPairs('HiddenSizeAugment', 250, varargin{:});
else
if ~(exist('HiddenSizeAugment','var'))
HiddenSizeAugment=250;
end
end

if isfunction
TimeFilterProportion = CheckVararginPairs('TimeFilterProportion', 0.5, varargin{:});
else
if ~(exist('TimeFilterProportion','var'))
TimeFilterProportion=0.5;
end
end
%%

CropSizes = cgg_getCropAmount(InputSize(1:2),Stride,length(FilterHiddenSizes));

NumFilters = length(FilterSizes);
Coder_Name = sprintf("_%s",Coder);
if iscell(FilterSizes)
    RepeatFilterSize = FilterSizes{end};
else
    RepeatFilterSize = FilterSizes(end);
end

TimeFilterSize = 1:length(InputSize);
TimeFilterSize(UniqueDimension) = [];
TimeFilterSize = max([1,round(InputSize(TimeFilterSize)*TimeFilterProportion)]);
TimeFilterSize = [TimeFilterSize,TimeFilterSize];
TimeFilterSize(UniqueDimension==1 | UniqueDimension==2) = 1;
%%

if ~WantSplitAreas
    CoderBlock = cgg_constructSingleAreaConvolutionalCoder(FilterSizes,FilterHiddenSizes,NaN,'Stride',Stride,'CropSizes',CropSizes,varargin{:});
    CombinationName="convolutioncombination" + Coder_Name;
    CombinationRepeatConvolutionName="repeatconvolutioncombination" + Coder_Name;
    % CombinationRepeatNormalizationName="repeatnormalizationcombination" + Coder_Name;
    CombinationActivationName="activationcombination" + Coder_Name;
    CombinationNormalizationName="normalizationcombination" + Coder_Name;
    CombinationActivationLayer = [];
    switch FinalActivation
        case 'Sigmoid'
            CombinationActivationLayer = [sigmoidLayer("Name", CombinationActivationName)
                batchNormalizationLayer("Name",CombinationNormalizationName)
                % layerNormalizationLayer("Name",CombinationNormalizationName)
                ];
        case 'Tanh'
            CombinationActivationLayer = [tanhLayer("Name", CombinationActivationName)
                batchNormalizationLayer("Name",CombinationNormalizationName)
                % layerNormalizationLayer("Name",CombinationNormalizationName)
                ];
        case 'Convolutional'
            CombinationActivationBeforeName="activationbeforecombination" + Coder_Name;
            CombinationActivationAfterName="activationaftercombination" + Coder_Name;
            CombinationFinalName="convolutionfinalcombination" + Coder_Name;
            switch Activation
                case 'SoftSign'
                    this_Layer_Before = softplusLayer("Name",CombinationActivationBeforeName);
                    this_Layer_After = softplusLayer("Name",CombinationActivationAfterName);
                case 'ReLU'
                    this_Layer_Before = reluLayer("Name",CombinationActivationBeforeName);
                    this_Layer_After = reluLayer("Name",CombinationActivationAfterName);
                case 'Leaky ReLU'
                    this_Layer_Before = leakyReluLayer("Name",CombinationActivationBeforeName);
                    this_Layer_After = leakyReluLayer("Name",CombinationActivationAfterName);
                case 'GeLU'
                    this_Layer_Before = geluLayer("Name",CombinationActivationBeforeName);
                    this_Layer_After = geluLayer("Name",CombinationActivationAfterName);
                otherwise
                    this_Layer_Before = [];
                    this_Layer_After = [];
            end
            CombinationActivationLayer = [this_Layer_Before
                convolution2dLayer(RepeatFilterSize,FilterHiddenSizes(1),"Name",CombinationFinalName,"Padding",'same',"WeightsInitializer","he")
                % batchNormalizationLayer("Name",CombinationNormalizationName)
                this_Layer_After];
        case 'None'
    end
    % CombinationLayer = [convolution2dLayer(1,InputSize(3),"Name",CombinationName,"Padding",'same',"WeightsInitializer","he")
    %     CombinationActivationLayer];
    CombinationLayer = [convolution2dLayer(RepeatFilterSize,FilterHiddenSizes(1),"Name",CombinationRepeatConvolutionName,"Padding",'same',"WeightsInitializer","he")
        % batchNormalizationLayer("Name",CombinationRepeatNormalizationName)
        CombinationActivationLayer
        convolution2dLayer(1,InputSize(3),"Name",CombinationName,"Padding",'same',"WeightsInitializer","he")];
    CombinationLG = layerGraph(CombinationLayer);
    CoderBlock = cgg_combineLayerGraphs(CoderBlock,CombinationLG);
else

SplitDimension = 3;
NumAreas = InputSize(SplitDimension);
%% Split Areas to perform covolution independently across areas

AreaConcatenationName="concatenationArea" + Coder_Name;
AreaConcatenationLayer = depthConcatenationLayer(NumAreas,"Name",AreaConcatenationName);
CoderBlock = layerGraph(AreaConcatenationLayer);
%%

for aidx = 1:NumAreas

    AreaIDX = aidx;
    Area_Name = sprintf("_Area-%d",AreaIDX);
    
AreaBlocks = cgg_constructSingleAreaConvolutionalCoder(FilterSizes,FilterHiddenSizes,AreaIDX,'Stride',Stride,'CropSizes',CropSizes,varargin{:});

switch Coder
    case 'Decoder'
CombinationName="convolutioncombination" + Coder_Name + Area_Name;
CombinationRepeatConvolutionName="repeatconvolutioncombination" + Coder_Name + Area_Name;
% CombinationRepeatNormalizationName="repeatnormalizationcombination" + Coder_Name + Area_Name;
CombinationActivationName="activationcombination" + Coder_Name + Area_Name;
CombinationNormalizationName="normalizationcombination" + Coder_Name + Area_Name;
CombinationActivationLayer = [];
this_Source = CombinationName;
switch FinalActivation
    case 'Sigmoid'
        CombinationActivationLayer = [sigmoidLayer("Name", CombinationActivationName)
            batchNormalizationLayer("Name",CombinationNormalizationName)];
            % layerNormalizationLayer("Name",CombinationNormalizationName)];
        % this_Source = CombinationNormalizationName;
    case 'Tanh'
        CombinationActivationLayer = [tanhLayer("Name", CombinationActivationName)
            batchNormalizationLayer("Name",CombinationNormalizationName)];
            % layerNormalizationLayer("Name",CombinationNormalizationName)];
        % this_Source = CombinationNormalizationName;
    case 'Convolutional'
        CombinationActivationBeforeName="activationbeforecombination" + Coder_Name + Area_Name;
        CombinationActivationAfterName="activationaftercombination" + Coder_Name + Area_Name;
        CombinationFinalName="convolutionfinalcombination" + Coder_Name + Area_Name;
        switch Activation
            case 'SoftSign'
                this_Layer_Before = softplusLayer("Name",CombinationActivationBeforeName);
                this_Layer_After = softplusLayer("Name",CombinationActivationAfterName);
            case 'ReLU'
                this_Layer_Before = reluLayer("Name",CombinationActivationBeforeName);
                this_Layer_After = reluLayer("Name",CombinationActivationAfterName);
            case 'Leaky ReLU'
                this_Layer_Before = leakyReluLayer("Name",CombinationActivationBeforeName);
                this_Layer_After = leakyReluLayer("Name",CombinationActivationAfterName);
            case 'GeLU'
                this_Layer_Before = geluLayer("Name",CombinationActivationBeforeName);
                this_Layer_After = geluLayer("Name",CombinationActivationAfterName);
            otherwise
                this_Layer_Before = [];
                this_Layer_After = [];
        end
        CombinationActivationLayer = [this_Layer_Before
                convolution2dLayer(RepeatFilterSize,FilterHiddenSizes(1),"Name",CombinationFinalName,"Padding",'same',"WeightsInitializer","he")
                % batchNormalizationLayer("Name",CombinationNormalizationName)
                this_Layer_After];
            % CombinationActivationLayer = [convolution2dLayer(RepeatFilterSize,FilterHiddenSizes(1),"Name",CombinationActivationName,"Padding",'same',"WeightsInitializer","he")];
            % this_Source = CombinationActivationName;
    case 'None'
end

% CombinationLayer = [convolution2dLayer(1,1,"Name",CombinationName,"Padding",'same',"WeightsInitializer","he")
%     CombinationActivationLayer];
CombinationLayer = [convolution2dLayer(RepeatFilterSize,FilterHiddenSizes(1),"Name",CombinationRepeatConvolutionName,"Padding",'same',"WeightsInitializer","he")
    % batchNormalizationLayer("Name",CombinationRepeatNormalizationName)
    CombinationActivationLayer
    convolution2dLayer(TimeFilterSize,1,"Name",CombinationName,"Padding",'same',"WeightsInitializer","he")];
CombinationLG = layerGraph(CombinationLayer);
if WantLearnableOffset || WantLearnableScale
% [~,Source,~,~] = cgg_identifyUnconnectedLayers(CombinationLG);
% FIXME: Adjust InputSize to account for other options
AugmentBlock = cgg_generateAugmentBlock(HiddenSizeAugment,[InputSize(1:2),1],WantLearnableScale,WantLearnableOffset,"Decoder" + Coder_Name + Area_Name,'UniqueDimension',UniqueDimension,varargin{:});
CombinationLG = cgg_combineLayerGraphs(CombinationLG,AugmentBlock);
this_Source = "output_Augment_Decoder" + Coder_Name + Area_Name;
NameAugmentTarget = "target_Augment_Decoder" + Coder_Name + Area_Name;
NameAugmentLearnable = "learnable_Augment_Decoder" + Coder_Name + Area_Name;
CombinationLG = connectLayers(CombinationLG,CombinationRepeatConvolutionName,NameAugmentLearnable);
CombinationLG = connectLayers(CombinationLG,CombinationName,NameAugmentTarget);
end

AreaBlocks = cgg_connectLayerGraphs(AreaBlocks,CombinationLG);
    otherwise
        if NumFilters > 1
        this_Source="concatenationFilter" + Coder_Name + Area_Name;
        else
        % [~,this_Source,~,~] = cgg_identifyUnconnectedLayers(AreaBlocks);
        [~,this_Source] = cgg_identifyUnconnectedLayers(AreaBlocks);
        this_Source = this_Source{1};
        end  
end

CoderBlock = cgg_combineLayerGraphs(CoderBlock,AreaBlocks);

% if NumFilters > 1
% this_Source="concatenationFilter" + Coder_Name + Area_Name;
% else
% [~,this_Source,~,~] = cgg_identifyUnconnectedLayers(AreaBlocks);
% this_Source = this_Source{1};
% end

this_Destination = AreaConcatenationName + sprintf("/in%d",aidx);
CoderBlock = connectLayers(CoderBlock,this_Source,this_Destination);

end

%%

% [AreaInputs,~,~,~] = cgg_identifyUnconnectedLayers(CoderBlock);
[AreaInputs,~] = cgg_identifyUnconnectedLayers(CoderBlock);
AreaSplitName="splitArea";
SplitLayerInputSize = InputSize;
switch Coder
    case 'Decoder'
SplitLayerInputSize(SplitDimension) = SplitLayerInputSize(SplitDimension)*FilterHiddenSizes(end);
end
AreaSplitLayer = cgg_splitLayer(AreaSplitName,SplitLayerInputSize,SplitDimension,"NumNewSplits",NumAreas);
% switch Coder
%     case 'Encoder'
%         AreaSplitLayer = cgg_splitLayer(AreaSplitName,InputSize,SplitDimension);
%     case 'Decoder'
%         AreaSplitLayer = functionLayer(@(X) X,Formattable=true,Acceleratable=true,Name=AreaSplitName);
%     otherwise
%         AreaSplitLayer = cgg_splitLayer(AreaSplitName,InputSize,SplitDimension);
% end

AreaSplitLG = layerGraph(AreaSplitLayer);

CoderBlock = cgg_combineLayerGraphs(CoderBlock,AreaSplitLG);

for aidx = 1:NumAreas

    this_AreaName = sprintf("_Area-%d",aidx);
    this_AreaInput = contains(AreaInputs,this_AreaName);
    this_AreaInput = AreaInputs(this_AreaInput);

    % switch Coder
    %     case 'Encoder'
    %         this_SourceIDX = aidx;
    %     case 'Decoder'
    %         this_SourceIDX = [];
    %     otherwise
    %         this_SourceIDX = aidx;
    % end
    this_SourceIDX = aidx;
    this_Source = AreaSplitName + sprintf("/out%d",this_SourceIDX);

    for iidx = 1:length(this_AreaInput)
        this_Destination = this_AreaInput{iidx};
        CoderBlock = connectLayers(CoderBlock,...
            this_Source,this_Destination);
    end

end

end

end

