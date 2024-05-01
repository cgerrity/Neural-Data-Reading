function Data = cgg_loadDataArrayTMP(FileName,DataWidth,WindowStride)
%CGG_LOADDATAARRAYTMP Summary of this function goes here
%   Detailed explanation goes here
Data=load(FileName);

Data=Data.Data;
[NumChannels,NumSamples,NumProbes]=size(Data);

this_DataWidth=DataWidth;
FinalStartIDX=NumSamples+1-this_DataWidth;
this_WindowStride=WindowStride;
Start_IDX=1;
StartPoint_IDX=Start_IDX:this_WindowStride:FinalStartIDX;
NumWindows=length(StartPoint_IDX);

% What Data to get
this_Data=NaN(NumChannels,this_DataWidth,NumProbes,NumWindows);
if this_DataWidth<NumSamples
for widx=1:NumWindows
this_StartingIDX=StartPoint_IDX(widx);
this_Data(:,:,:,widx)=Data(:,this_StartingIDX:this_StartingIDX+this_DataWidth-1,:);
end
else
this_Data=NaN(NumChannels,this_DataWidth,NumProbes);
end

Data=this_Data;
end

