function PCAInformation = cgg_getPCAForLayer(InData,varargin)
% function [outputArg1,outputArg2] = cgg_getPCAForLayer(EpochDir,SessionName,Fold,cfg_Encoder,varargin)
%CGG_GETPCAFORLAYER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantPerTime = CheckVararginPairs('WantPerTime', true, varargin{:});
else
if ~(exist('WantPerTime','var'))
WantPerTime=true;
end
end

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 10, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=10;
end
end

if isfunction
WantPreFetch = CheckVararginPairs('WantPreFetch', true, varargin{:});
else
if ~(exist('WantPreFetch','var'))
WantPreFetch=true;
end
end

%% Get Data

IsDataStore = isa(InData,'matlab.io.Datastore');
IsMiniBatch = isa(InData,'minibatchqueue');

if IsDataStore

    % Get Format
    NumWindows=1;
    DataFormat={'SSCTB','CBT',''};

    Values_Examples=read(InData);
    Example_Data=Values_Examples{1};
    DataSize=size(Example_Data);
    
    if length(DataSize)>3
    NumWindows=DataSize(4);
    end

    NumDimensions = length(Values_Examples{2});

    if NumWindows==1
    DataFormat{1}='SSCBT';
    end
    if NumDimensions <= 1
        DataFormat{2}='BCT';
    end

    % Construct MiniBatch

    if ~isMATLABReleaseOlderThan("R2024a")
        PreprocessingEnvironment = "serial";
        if WantPreFetch
            PreprocessingEnvironment = "parallel";
        end
    MiniBatchQueue = minibatchqueue(InData,...
            MiniBatchSize=maxworkerMiniBatchSize,...
            MiniBatchFormat=DataFormat,...
            PreprocessingEnvironment=PreprocessingEnvironment,...
            OutputEnvironment="auto");
    else
    MiniBatchQueue = minibatchqueue(InData,...
            MiniBatchSize=maxworkerMiniBatchSize,...
            MiniBatchFormat=DataFormat,...
            DispatchInBackground=WantPreFetch,...
            OutputEnvironment="auto");
    end
    % MiniBatchQueue = minibatchqueue(InData,...
    %     MiniBatchSize=maxworkerMiniBatchSize, ...
    %     MiniBatchFormat=DataFormat,...
    %     PreprocessingEnvironment="parallel",...
    %     OutputEnvironment="auto");
    X_Input = [];
    while hasdata(MiniBatchQueue)
    [this_X,~,~] = next(MiniBatchQueue);
        if isempty(X_Input)
            X_Input = this_X;
        else
            X_Input = cat(finddim(X_Input,'B'),X_Input,this_X);
        end
        % fprintf('!!! DataStore One more Loop\n');
    end

elseif IsMiniBatch
        X_Input = [];
    while hasdata(InData)
    [this_X,~,~] = next(InData);
        if isempty(X_Input)
            X_Input = this_X;
        else
            X_Input = cat(finddim(X_Input,'B'),X_Input,this_X);
        end
        % fprintf('!!! MiniBatch One more Loop\n');
    end
else
    X_Input = InData;
end

%%



X = cgg_extractData(X_Input);
[PermuteDimensions,ReshapeSize] = cgg_getPCALayerInformation(X_Input,...
        'WantPerTime',WantPerTime);
X = cgg_setNaNToValue(X,0);
explainedVarianceThreshold = 0.95;
if WantPerTime

    FormatInformation = cgg_getDataFormatInformation(X_Input);
 
    T = FormatInformation.Size.Time;
    % B = FormatInformation.Size.Batch;
    % S = prod(FormatInformation.Size.Spatial);
    % C = FormatInformation.Size.Channel;
    % Initialize
    PCCoefficients = cell(T, 1);
    PCMean = cell(T, 1);
    OutputDimensionAll = zeros(T, 1);

    idx = repmat({':'}, 1, length(size(X)));
    % PermuteDimensions = [FormatInformation.Dimension.Batch,...
    %                      FormatInformation.Dimension.Spatial,...
    %                      FormatInformation.Dimension.Channel,...
    %                      FormatInformation.Dimension.Time];


    
    % For each time point
    for t = 1:T
        % First permute to get batch dimension first before reshaping
        % [S1, S2, C, B] -> [B, S1, S2, C]
        idx{FormatInformation.Dimension.Time} = t;
        timeData = permute(X(idx{:}), PermuteDimensions);
        
        % Reshape properly: Each row is a sample (B samples), each column is a feature (S1*S2*C features)
        reshapedData = reshape(timeData, ReshapeSize);
        
        % Compute PCA
        [coeffs, ~, ~, ~, explained, mu] = pca(reshapedData);
        
        % Find number of components needed
        cumVar = cumsum(explained);
        dims = find(cumVar >= explainedVarianceThreshold*100, 1, 'first');
        
        % Store results
        PCCoefficients{t} = coeffs;
        PCMean{t} = mu;
        OutputDimensionAll(t) = dims;
    end

else
%%    
    % data is in SSCBT format: [S1, S2, C, B, T]
    % FormatInformation = cgg_getDataFormatInformation(X_Input);
    % PermuteDimensions = [FormatInformation.Dimension.Batch,...
    %                      FormatInformation.Dimension.Time,...
    %                      FormatInformation.Dimension.Spatial,...
    %                      FormatInformation.Dimension.Channel];
    % T = FormatInformation.Size.Time;
    % B = FormatInformation.Size.Batch;
    % S = prod(FormatInformation.Size.Spatial);
    % C = FormatInformation.Size.Channel;
    
    % First permute to get batch and time dimensions first
    % [S1, S2, C, T, B] -> [B, T, S1, S2, C]
    permutedData = permute(X, PermuteDimensions);
    
    % Reshape: Each row is a sample (B*T samples), each column is a feature (S1*S2*C features)
    reshapedData = reshape(permutedData, ReshapeSize);
    
    % Compute PCA
    [coeffs, ~, ~, ~, explained, mu] = pca(reshapedData);
    
    % Find number of components needed
    cumVar = cumsum(explained);
    OutputDimensionAll = find(cumVar >= explainedVarianceThreshold*100, 1, 'first');
    
    PCCoefficients = coeffs;
    PCMean = mu;
end

    %%
FormatInformation = cgg_getDataFormatInformation(X_Input);
SpatialDimensions = FormatInformation.Size.Spatial;
OriginalChannels = FormatInformation.Size.Channel;
ApplyPerTimePoint = WantPerTime;
OutputDimension = max(OutputDimensionAll);

PCAInformation = struct();

PCAInformation.PCCoefficients = PCCoefficients(:, 1:OutputDimension);
PCAInformation.PCMean = PCMean;
PCAInformation.OutputDimension = OutputDimension;
PCAInformation.OutputDimensionAll = OutputDimensionAll;
PCAInformation.ApplyPerTimePoint = ApplyPerTimePoint;
PCAInformation.SpatialDimensions = SpatialDimensions;
PCAInformation.OriginalChannels = OriginalChannels;

end

