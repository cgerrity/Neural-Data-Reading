

clc; clear; close all;

%%

Epoch = 'Synthetic_Simple';

NumChannels=2;
NumSamples=3001;
NumAreas=3;
NumData=200;

WantSave = true;
WantPlot = false;
NumNaN = 2;

Time_Start=-1.5;
Time_End=1.5;

% NoiseLevel=0.5; % Synthetic_3
NoiseLevel=0;

%%

FrequencyValues = [3,4,5,6];
AmplitudeValues = [0.5,1,1.5,2];
NumPatterns = 4;

PatternFrequency = 0.0005;
% PatternSTD = 0.025; % Synthetic_3
PatternSTD = 0.0025;
% PatternAmplitude = 1.5; % Synthetic_3
PatternAmplitude = 5;

%% Noise

Noise_Amplitude=1;
Noise_Spread=2;
Noise_Center=-0.4;
Noise_Maximum = 1;

NoiseLevelArea = [1,1.5,2,2.5,3,3.5];

LowPassFrequency = 10;

%%

NaNChannel = randi(NumChannels,NumNaN);
NaNArea = randi(NumAreas,NumNaN);

%%

cfg_Session = DATA_cggAllSessionInformationConfiguration;

TargetDir=cfg_Session(1).outdatadir;
ResultsDir=cfg_Session(1).temporarydir;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,'Epoch',Epoch,'Data_Normalized',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,'Epoch',Epoch,'Data_Normalized',true);
cfg.ResultsDir=cfg_tmp.TargetDir;

SyntheticDir = cgg_getDirectory(cfg.TargetDir,'Epoch');

%%

% SyntheticDir='/data/users/gerritcg/Data_Neural/Aggregate Data/Epoched Data/Synthetic';

DataDir=[SyntheticDir filesep 'Data'];
DataNormalizedDir=[SyntheticDir filesep 'Data_Normalized'];
TargetDir=[SyntheticDir filesep 'Target'];

Data_PathNameExt=[DataDir filesep 'Synthetic_Data_%07d.mat'];
DataNormalized_PathNameExt=[DataNormalizedDir filesep 'Synthetic_Data_%07d.mat'];
Target_PathNameExt=[TargetDir filesep 'Target_%07d.mat'];

%%
Time=linspace(Time_Start,Time_End,NumSamples);

FrequencyDiff = diff(FrequencyValues);
FrequencyNoiseLevel = mean([FrequencyDiff(1),diff(FrequencyValues);diff(FrequencyValues),FrequencyDiff(end)],1);
FrequencyNoiseLevel = FrequencyNoiseLevel/2;
AmplitudeDiff = diff(AmplitudeValues);
AmplitudeNoiseLevel = mean([AmplitudeDiff(1),diff(AmplitudeValues);diff(AmplitudeValues),AmplitudeDiff(end)],1);
AmplitudeNoiseLevel = AmplitudeNoiseLevel/2;

PatternNoiseLevel = PatternAmplitude/2;

%%

PatternCode = cell(1,NumPatterns);
PatternValues = cell(1,NumPatterns);
for cidx = 1:NumPatterns
[PatternCode{cidx},PatternValues{cidx}] = cgg_generateSyntheticCrossAreaPattern(NumChannels,NumAreas,Time,PatternFrequency,PatternSTD);
end

%%

NumClass_1 = length(FrequencyValues);
NumClass_2 = length(AmplitudeValues);
NumClass_3 = NumPatterns;
% NumClass_4 = length();

ClassNames=cell(1,4);

ClassNames{1}=1:NumClass_1;
ClassNames{2}=1:NumClass_2;
ClassNames{3}=1:NumClass_3;
ClassNames{4}=[0,1,2,3];

Dimension_1=repmat(ClassNames{1},[1,NumData/length(ClassNames{1})]);
Dimension_2=repmat(ClassNames{2},[1,NumData/length(ClassNames{2})]);
Dimension_3=repmat(ClassNames{3},[1,NumData/length(ClassNames{3})]);
Dimension_4=repmat(ClassNames{4},[1,NumData/length(ClassNames{4})]);

Dimension_1 = Dimension_1(randperm(NumData));
Dimension_2 = Dimension_2(randperm(NumData));
Dimension_3 = Dimension_3(randperm(NumData));
Dimension_4 = Dimension_4(randperm(NumData));

%%
gcp;
%%
% Data=NaN(NumChannels,NumSamples,NumAreas,NumData);

%%

FrequencyValues_Parallel = parallel.pool.Constant(FrequencyValues);
AmplitudeValues_Parallel = parallel.pool.Constant(AmplitudeValues);
PatternValues_Parallel = parallel.pool.Constant(PatternValues);

FrequencyNoiseLevel_Parallel = parallel.pool.Constant(FrequencyNoiseLevel);
AmplitudeNoiseLevel_Parallel = parallel.pool.Constant(AmplitudeNoiseLevel);
PatternNoiseLevel_Parallel = parallel.pool.Constant(PatternNoiseLevel);

NaNChannel_Parallel = parallel.pool.Constant(NaNChannel);
NaNArea_Parallel = parallel.pool.Constant(NaNArea);

parfor didx=1:NumData

this_Sample_Data=NaN(NumChannels,NumSamples,NumAreas);

this_Waveform=Dimension_4(didx);
this_FrequencyDimension=Dimension_1(didx);
this_AmplitudeDimension=Dimension_2(didx);
this_PatternChoice=Dimension_3(didx);

this_SelectedObjectDimVals=[this_FrequencyDimension;this_AmplitudeDimension;...
    this_PatternChoice;0;this_Waveform];
this_SessionName='Synthetic';

this_Frequency = FrequencyValues_Parallel.Value(this_FrequencyDimension);
this_Amplitude = AmplitudeValues_Parallel.Value(this_AmplitudeDimension);
this_PatternOverall = PatternValues_Parallel.Value{this_PatternChoice};
this_FrequencyNoiseLevel = FrequencyNoiseLevel_Parallel.Value(this_FrequencyDimension);
this_AmplitudeNoiseLevel = AmplitudeNoiseLevel_Parallel.Value(this_AmplitudeDimension);
this_PatternNoiseLevel = PatternNoiseLevel_Parallel.Value;

for cidx=1:NumChannels
    for aidx=1:NumAreas

        this_Frequency = this_Frequency + randn(1).*this_FrequencyNoiseLevel;
        this_Amplitude = this_Amplitude + randn(1).*this_AmplitudeNoiseLevel;
        this_Pattern = this_PatternOverall(cidx,:,aidx).*PatternAmplitude;
        % this_Pattern = this_Pattern - mean(this_Pattern);
        this_Pattern = this_Pattern + randn(1).*this_PatternNoiseLevel;

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
    otherwise
        this_Channel_Data = NaN(size(this_Time));
end

this_Channel_Data = this_Channel_Data.*this_Amplitude+this_Pattern;

this_Sample_Data(cidx,:,aidx)=this_Channel_Data;

    end
end

this_Target_PathNameExt = sprintf(Target_PathNameExt,didx);

this_ProbeProcessing = struct;
this_ProbeProcessing.ACC_001 = true;
this_ProbeProcessing.ACC_002 = true;
this_ProbeProcessing.PFC_001 = true;
this_ProbeProcessing.PFC_002 = true;
this_ProbeProcessing.CD_001 = true;
this_ProbeProcessing.CD_002 = true;

this_Target=struct();
this_Target.SelectedObjectDimVals=this_SelectedObjectDimVals;
this_Target.SessionName=this_SessionName;
this_Target.CorrectTrial='True';
this_Target.PreviousTrialCorrect='True';
this_Target.Dimensionality=4;
this_Target.Gain=3;
this_Target.Loss=-1;
this_Target.TrialsFromLP=0;
this_Target.ProbeProcessing=this_ProbeProcessing;
this_Target.TargetFeature=1;
this_Target.ReactionTime=1;
this_Target.TrialChosen=true;
this_Target.SharedFeatureCoding=1;
this_Target.SharedFeature=1;

SaveVariables={this_Target};
SaveVariablesName={'Target'};
SavePathNameExt=this_Target_PathNameExt;

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

this_Data_PathNameExt = sprintf(Data_PathNameExt,didx);
this_DataNormalized_PathNameExt = sprintf(DataNormalized_PathNameExt,didx);

this_Noise = cgg_generateSyntheticNoise(NumAreas,NumChannels,NoiseLevel,Time,Noise_Amplitude,Noise_Spread,Noise_Center,Noise_Maximum,NoiseLevelArea,LowPassFrequency);

this_Data=this_Sample_Data+this_Noise;

Par_NaNChannel = NaNChannel_Parallel.Value;
Par_NaNArea = NaNArea_Parallel.Value;

for nidx = 1:NumNaN
    this_NaNChannel = Par_NaNChannel(nidx);
    this_NaNArea = Par_NaNArea(nidx);
this_Data(this_NaNChannel,:,this_NaNArea) = NaN;
end

if WantPlot
PlotCount = 0;
figure;
for aidx = 1:NumAreas
    for cidx = 1:NumChannels
plot(Time,this_Data(cidx,:,aidx)+PlotCount*4);
PlotCount = PlotCount+1;
if PlotCount == 1
hold on
end
    end
end
hold off
end

if WantSave

SaveVariables={this_Data};
SaveVariablesName={'Data'};
SavePathNameExt=this_Data_PathNameExt;

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

% SavePathNameExt=this_DataNormalized_PathNameExt;
% 
% cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

end

% Data(:,:,:,didx)=this_Data;

end

%%
if WantSave
cgg_getKFoldPartitions('Epoch',Epoch,'SessionSubset','Synthetic');
cgg_procNormalizationInformation(Epoch);
end

%%
% figure;
% Noise = randn(NumChannels,NumSamples,NumAreas).*NoiseLevel;
% plot(Time,Noise(1,:,1)); ylim([-1,1]);
% figure;
% plot(Time,Data(1,:,1,2));
% figure;
% plot(Time,Data(1,:,1,3));
% figure;
% plot(Time,Data(1,:,1,4));

% %%
% close all
% 
% NumSamples = 100000;
% Outlier_1_Value = 90;
% Outlier_2_Value = -10;
% 
% TestSample = randn(1,NumSamples)+10;
% TestSample(1) = Outlier_1_Value;
% TestSample(2) = Outlier_2_Value;
% 
% TestSample_Max = max(TestSample);
% TestSample_Min = min(TestSample);
% TestSample_Mean = mean(TestSample);
% 
% TestSample_D_MeanMin = TestSample_Mean-TestSample_Min;
% TestSample_D_MaxMin = TestSample_Max-TestSample_Min;
% TestSample_Correction = TestSample_D_MeanMin/TestSample_D_MaxMin;
% 
% TestSample_MinMax = (TestSample-TestSample_Min)/(TestSample_Max-TestSample_Min);
% TestSample_MeanMinMax = (TestSample-(TestSample_Mean-TestSample_D_MaxMin/2))/(TestSample_Max-TestSample_Min);
% 
% TestSample_MinMax_Mean = mean(TestSample_MinMax);
% TestSample_MeanMinMax_Mean = mean(TestSample_MeanMinMax);
% 
% TestSample_MinMax_Corrected = TestSample_MinMax + 0.5 - TestSample_Correction;
% TestSample_MinMax_Corrected_Mean = mean(TestSample_MinMax_Corrected);
% 
% disp({TestSample_Mean,TestSample_MinMax_Mean,TestSample_MinMax_Corrected_Mean,TestSample_MeanMinMax_Mean})
% 
% histogram(TestSample_MeanMinMax)
