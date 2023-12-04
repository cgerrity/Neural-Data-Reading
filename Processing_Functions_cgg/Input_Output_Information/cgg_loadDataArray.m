function [Data,Probe_Order_Random] = cgg_loadDataArray(FileName,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector)
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

Probe_Total=length(Probe_Names);

[Probe_Areas,~,Probe_Dimensions]=unique(Probe_Names);

Probe_Order_Random=repmat((1:Probe_Total)',[1,NumWindows]);

if WantRandomize
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

%% What Data to get
this_Data=NaN(NumChannels,this_DataWidth,NumProbes,NumWindows);
if this_DataWidth<NumSamples
parfor pidx=1:NumWindows
this_StartingIDX=StartPoint_IDX(pidx);
this_Order=Probe_Order_Random(:,pidx);
this_Data(:,:,:,pidx)=Data(:,this_StartingIDX:this_StartingIDX+this_DataWidth-1,this_Order);
end
else
this_Data=NaN(NumChannels,this_DataWidth,NumProbes);
end

%% Remove Channels

if ~isempty(ChannelRemoval)
    [NumChannelsRemoval,~]=size(ChannelRemoval);
    for ridx=1:NumChannelsRemoval
    this_Data(ChannelRemoval(ridx,1),:,ChannelRemoval(ridx,2),:)=0;
    end
end

%%

if Want1DVector
    this_Data= permute(this_Data,[4 1 2 3]);
    this_Data= reshape(this_Data,NumWindows,[]);
    Data=this_Data;
end

%%

if WantDisp
disp(size(Data));
end

end