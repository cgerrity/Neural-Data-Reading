function [outputArg1,outputArg2] = cgg_plotAllWindowsFromDataStore(InDataStore,DataWidth,WindowStride)
%CGG_PLOTALLWINDOWSFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here


sel_data=1;
SamplingFrequency=1000;


NumDataStore=numpartitions(InDataStore);

this_DataStore=partition(InDataStore,NumDataStore,sel_data);

this_Values=read(this_DataStore);

this_Data=this_Values{1};
[NumChannels,NumSamples,NumAreas,NumWindows]=size(this_Data);

%%

close all

Time_Start=-1.5;
Time_End=1.5;
Time=Time_Start:1/SamplingFrequency:Time_End;

sel_Channel=randi(NumChannels,1);
sel_Area=randi(NumAreas,1);

hold on

for widx=1:NumWindows

    this_StartIDX=(widx-1)*WindowStride+1;
    this_EndIDX=this_StartIDX+DataWidth-1;
    this_Range=this_StartIDX:this_EndIDX;
    this_Time=Time(this_Range);

    this_DataWindow=this_Data(sel_Channel,:,sel_Area,widx);

    plot(this_Time,this_DataWindow);

end

hold off
ylim([-4,4]);

