

clc; clear; close all;

NumChannels=10;
NumSamples=3001;
NumAreas=6;
NumData=1000;

Time_Start=-1.5;
Time_End=1.5;

NoiseLevel=0.05;

%%

FrequencyValues=[20,20,20,20];

%%

SyntheticDir='/data/users/gerritcg/Data_Neural/Aggregate Data/Epoched Data/Synthetic';

DataDir=[SyntheticDir filesep 'Data'];
DataNormalizedDir=[SyntheticDir filesep 'Data_Normalized'];
TargetDir=[SyntheticDir filesep 'Target'];

Data_PathNameExt=[DataDir filesep 'Synthetic_Data_%07d.mat'];
DataNormalized_PathNameExt=[DataNormalizedDir filesep 'Synthetic_Data_%07d.mat'];
Target_PathNameExt=[TargetDir filesep 'Target_%07d.mat'];

%%

ClassNames=cell(1,4);

ClassNames{1}=0;
ClassNames{2}=0;
ClassNames{3}=0;
ClassNames{4}=[0,1,2,3];

Dimension_1=repmat(ClassNames{1},[1,NumData/length(ClassNames{1})]);
Dimension_2=repmat(ClassNames{2},[1,NumData/length(ClassNames{2})]);
Dimension_3=repmat(ClassNames{3},[1,NumData/length(ClassNames{3})]);
Dimension_4=repmat(ClassNames{4},[1,NumData/length(ClassNames{4})]);

%%

Time=linspace(Time_Start,Time_End,NumSamples);
Data=NaN(NumChannels,NumSamples,NumAreas,NumData);


parfor didx=1:NumData

this_Sample_Data=NaN(NumChannels,NumSamples,NumAreas);

this_Dimension_2=Dimension_2(didx);
this_Dimension_3=Dimension_3(didx);

this_Waveform=Dimension_4(didx);
this_Frequency=Dimension_1(didx);

this_SelectedObjectDimVals=[this_Frequency;this_Dimension_2;...
    this_Dimension_3;0;this_Waveform];
this_SessionName='Synthetic';

switch this_Frequency
    case 0
        this_Frequency=FrequencyValues(1);
    otherwise
        this_Frequency=1;
end


for cidx=1:NumChannels
    for aidx=1:NumAreas
        this_Time=(Time+randn(1))*(2*pi*this_Frequency);

switch this_Waveform
    case 0
        this_Channel_Data=sin(this_Time);
    case 1
        this_Channel_Data=square(this_Time);
    case 2
        this_Channel_Data=sawtooth(this_Time);
    case 3
        this_Channel_Data=sawtooth(this_Time,0.5);
end

this_Sample_Data(cidx,:,aidx)=this_Channel_Data;

    end
end

this_Target_PathNameExt = sprintf(Target_PathNameExt,didx);

this_Target=struct();
this_Target.SelectedObjectDimVals=this_SelectedObjectDimVals;
this_Target.SessionName=this_SessionName;

SaveVariables={this_Target};
SaveVariablesName={'Target'};
SavePathNameExt=this_Target_PathNameExt;

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

this_Data_PathNameExt = sprintf(Data_PathNameExt,didx);
this_DataNormalized_PathNameExt = sprintf(DataNormalized_PathNameExt,didx);

this_Data=this_Sample_Data+randn(size(this_Sample_Data)).*NoiseLevel;

SaveVariables={this_Data};
SaveVariablesName={'Data'};
SavePathNameExt=this_Data_PathNameExt;

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

SavePathNameExt=this_DataNormalized_PathNameExt;

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

Data(:,:,:,didx)=this_Data;

end




% 
% figure;
% plot(Time,Data(1,:,1,1));
% figure;
% plot(Time,Data(1,:,1,2));
% figure;
% plot(Time,Data(1,:,1,3));
% figure;
% plot(Time,Data(1,:,1,4));


