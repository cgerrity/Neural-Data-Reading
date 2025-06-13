function [Data,Probe_Order_Random] = cgg_loadDataArray(FileName,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector,varargin)
%CGG_LOADDATAARRAY Summary of this function goes here
%   Detailed explanation goes here

Data=load(FileName);
SmallDataWidth=100;
Data=Data.Data;

if WantDisp
[~,Name,~]=fileparts(FileName);
disp(Name);
end

[NumChannels,NumSamples,NumProbes]=size(Data);

isfunction=exist('varargin','var');

if isfunction
ARModelOrder = CheckVararginPairs('ARModelOrder', '', varargin{:});
else
if ~(exist('ARModelOrder','var'))
ARModelOrder='';
end
end

if isfunction
STDChannelOffset = CheckVararginPairs('STDChannelOffset', NaN, varargin{:});
else
if ~(exist('STDChannelOffset','var'))
STDChannelOffset=NaN;
end
end

if isfunction
STDWhiteNoise = CheckVararginPairs('STDWhiteNoise', NaN, varargin{:});
else
if ~(exist('STDWhiteNoise','var'))
STDWhiteNoise=NaN;
end
end

if isfunction
STDRandomWalk = CheckVararginPairs('STDRandomWalk', NaN, varargin{:});
else
if ~(exist('STDRandomWalk','var'))
STDRandomWalk=NaN;
end
end

if isfunction
Normalization = CheckVararginPairs('Normalization', 'None', varargin{:});
else
if ~(exist('Normalization','var'))
Normalization='None';
end
end

if isfunction
NormalizationTable = CheckVararginPairs('NormalizationTable', '', varargin{:});
else
if ~(exist('NormalizationTable','var'))
NormalizationTable='';
end
end

if isfunction
NormalizationInformation = CheckVararginPairs('NormalizationInformation', '', varargin{:});
else
if ~(exist('NormalizationInformation','var'))
NormalizationInformation='';
end
end

%% Normalize Data
if ~strcmp(Normalization,'None')
    if isempty(NormalizationTable)
        NormalizationTable = cgg_getNormalizationTableFromDataName(FileName,'NormalizationInformation',NormalizationInformation);
    end
Data = cgg_selectNormalization(Data,NormalizationTable,Normalization);
end
%% Data Width
if isequal(DataWidth,'All')
this_DataWidth=NumSamples;
elseif isscalar(DataWidth)
this_DataWidth=DataWidth;
else
this_DataWidth=SmallDataWidth;
end

%% Final Possible Start Index
FinalStartIDX=NumSamples+1-this_DataWidth;

%% Window Stride
if isequal(WindowStride,'All')
this_WindowStride=1;
elseif isscalar(WindowStride)
this_WindowStride=WindowStride;
else
this_WindowStride=randi(this_DataWidth);
end

%% Ending Index
if isequal(EndingIDX,'All')
% Don't do anything!
elseif isscalar(EndingIDX) && ~isequal(DataWidth,'All')
FinalStartIDX=EndingIDX;
else
FinalStartIDX=randi(FinalStartIDX);
end

%% Starting Index
if isequal(StartingIDX,'All')
Start_IDX=1;
elseif isscalar(StartingIDX) && ~isequal(DataWidth,'All')
Start_IDX=StartingIDX;
else
Start_IDX=randi(FinalStartIDX);
end

%% All Start Indices

StartPoint_IDX=Start_IDX:this_WindowStride:FinalStartIDX;

%%
if this_DataWidth<NumSamples
NumWindows=length(StartPoint_IDX);
else
NumWindows=1;
end

%% Randomize the Probes


cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');

Probe_Order=cfg_param.Probe_Order;

Probe_Names=extractBefore(Probe_Order,'_');

Probe_Total_Recording=length(Probe_Names);
Probe_Total=NumProbes;

[Probe_Areas,~,Probe_Dimensions]=unique(Probe_Names);

Probe_Order_Random=repmat((1:Probe_Total)',[1,NumWindows]);

if WantRandomize && Probe_Total == Probe_Total_Recording
for widx=1:NumWindows
for cidx=1:length(Probe_Areas)

    this_Area_Dimensions=find(Probe_Dimensions==cidx);
    
    this_Area_Order=this_Area_Dimensions(randperm(length(this_Area_Dimensions)));
    
    Probe_Order_Random(this_Area_Dimensions,widx)=this_Area_Order;
    
end
end
end

%% Zero NaN

if WantNaNZeroed
    Data(isnan(Data))=0;
end

%% Data Augmentation

DataAugmentationSignal = cgg_generateDataAugmentationSignal(NumChannels,...
    NumSamples,NumProbes,STDChannelOffset,STDWhiteNoise,STDRandomWalk);

Data = Data + DataAugmentationSignal;

%% What Data to get
this_Data=NaN(NumChannels,this_DataWidth,NumProbes,NumWindows);
if this_DataWidth<NumSamples
parfor widx=1:NumWindows
this_StartingIDX=StartPoint_IDX(widx);
this_Order=Probe_Order_Random(:,widx);
this_Data(:,:,:,widx)=Data(:,this_StartingIDX:this_StartingIDX+this_DataWidth-1,this_Order);
end
else
this_Data=NaN(NumChannels,this_DataWidth,NumProbes);
this_Order=Probe_Order_Random(:);
this_Data(:,:,:)=Data(:,:,this_Order);
end

%% Remove Channels

if ~isempty(ChannelRemoval)
    [NumChannelsRemoval,~]=size(ChannelRemoval);
    for ridx=1:NumChannelsRemoval
    this_Data(ChannelRemoval(ridx,1),:,ChannelRemoval(ridx,2),:)=0;
    end
end

%% AR Model

if ~isempty(ARModelOrder)
this_Data_tmp=cell(NumProbes*NumWindows,1);
[pidx_Grid,widx_Grid]=meshgrid(1:NumProbes,1:NumWindows);
parfor pwidx=1:numel(pidx_Grid)
    this_pidx=pidx_Grid(pwidx);
    this_widx=widx_Grid(pwidx);

    warning('off','all');
    this_Data_tmp{pwidx} = arcov(this_Data(:,:,this_pidx,this_widx)',ARModelOrder);
    warning('on','all');
end
this_DataAR_tmp=NaN(NumChannels,ARModelOrder,NumProbes,NumWindows);

for pwidx=1:numel(pidx_Grid)
    this_pidx=pidx_Grid(pwidx);
    this_widx=widx_Grid(pwidx);
this_DataAR_tmp(:,:,this_pidx,this_widx)=this_Data_tmp{pwidx}(:,2:end);
end
this_Data=this_DataAR_tmp;
end

%%

if Want1DVector
    this_Data= permute(this_Data,[4 1 2 3]);
    this_Data= reshape(this_Data,NumWindows,[]);
end

%%

Data=this_Data;
%%

if WantDisp
disp(size(Data));
end

end