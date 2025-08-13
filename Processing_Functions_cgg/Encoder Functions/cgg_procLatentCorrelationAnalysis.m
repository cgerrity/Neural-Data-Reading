function [Correlation,P_Value] = cgg_procLatentCorrelationAnalysis(InDatastore,Encoder,varargin)
%CGG_PROCLATENTCORRELATIONANALYSIS Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 10, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=10;
end
end

if isfunction
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','BT',''}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','BT',''};
end
end

%%

MaxMbq = minibatchqueue(InDatastore,...
        MiniBatchSize=maxworkerMiniBatchSize,...
        MiniBatchFormat=DataFormat);

%%

Y_Encoded = [];
T = [];
%%

while hasdata(MaxMbq)

[X,this_T,~] = next(MaxMbq);
% Encoder=resetState(Encoder);
Encoder=cgg_resetState(Encoder);
[this_Y_Encoded] = predict(Encoder,X);

%%
    if isempty(Y_Encoded)
        Y_Encoded = this_Y_Encoded;
    else
        CatDimension = finddim(this_Y_Encoded,"B");
        Y_Encoded = cat(CatDimension,Y_Encoded,this_Y_Encoded);
    end
    if isempty(T)
        T = this_T;
    else
        CatDimension = finddim(T,"B");
        T = cat(CatDimension,T,this_T);
    end

end
%%

TrialDim = finddim(Y_Encoded,"B");

Y_Encoded = cgg_extractData(Y_Encoded);
T = cgg_extractData(T);

Y_Permute_Order = 1:ndims(Y_Encoded);
Y_Permute_Order(TrialDim) = [];
Y_Permute_Order = [Y_Permute_Order, TrialDim];

Y_Encoded = permute(Y_Encoded,Y_Permute_Order);

%%

[~,~,~,~,~,~,Correlation,P_Value,~] = ...
    cgg_procTrialVariableRegression(Y_Encoded,T,1);

%
end

