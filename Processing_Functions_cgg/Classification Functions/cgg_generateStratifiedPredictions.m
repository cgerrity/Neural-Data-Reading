function Prediction = cgg_generateStratifiedPredictions(ClassNames,ClassPercent,NumPredictions,varargin)
%CGG_GENERATESTRATIFIEDPREDICTIONS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

%%

NumClasses = length(ClassNames);

Prediction = rand(NumPredictions,NumClasses);

for cidx = 1:NumClasses
    this_ClassNames = ClassNames{cidx};
    this_ClassPercent = ClassPercent{cidx};
    this_Edges = cumsum(this_ClassPercent);
    this_Edges = this_Edges/this_Edges(end);
    this_Edges = [-Inf;this_Edges(1:end-1);Inf];
    [Prediction(:,cidx),~] = discretize(Prediction(:,cidx),this_Edges);
    Prediction(:,cidx) = this_ClassNames(Prediction(:,cidx));
end
%%

if IsQuaddle
wantZeroFeatureDetector=false;
ClassFraction = cellfun(@(x) x/100,ClassPercent,"UniformOutput",false);

QuaddleInterpreterFunc = @(this_Prediction) cgg_procQuaddleInterpreter(this_Prediction,ClassNames,ClassFraction,wantZeroFeatureDetector,'WantRandom',true);

Prediction = arrayfun(@(p) QuaddleInterpreterFunc(Prediction(p,:)), (1:size(Prediction,1))', 'UniformOutput', false);
Prediction = cell2mat(Prediction);

end
end

