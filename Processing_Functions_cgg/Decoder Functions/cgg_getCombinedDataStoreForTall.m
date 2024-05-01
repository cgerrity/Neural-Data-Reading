function [Combined_ds] = cgg_getCombinedDataStoreForTall(DataWidth,StartingIDX,EndingIDX,WindowStride,cfg,varargin)
%CGG_GETCOMBINEDDATASTOREFORTALL Summary of this function goes here
%   Detailed explanation goes here


DataAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Data.path;
TargetAggregateDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;

%%
ChannelRemoval = CheckVararginPairs('ChannelRemoval', [], varargin{:});
WantRandomize = CheckVararginPairs('WantRandomize', false, varargin{:});

%%

Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,false,WantRandomize,true,true,varargin{:});
Target_Fun=@(x) cgg_loadTargetArray(x,varargin{:});

Data_ds = fileDatastore(DataAggregateDir,"ReadFcn",Data_Fun);
Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",Target_Fun);

%%
Combined_ds=combine(Data_ds,Target_ds);

end

