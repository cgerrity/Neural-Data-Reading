function [AllOutData,TrialNumbers,Data_Unsmoothed] = cgg_getAllTrialDataFromTimeSegments_v2(Start_IDX,End_IDX,fullfilename,Smooth_Factor,varargin)
%CGG_GETALLTRIALDATAFROMTIMESEGMENTS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%% Varargin Options

if isfunction
SmoothType = CheckVararginPairs('SmoothType', 'gaussian', varargin{:});
else
if ~(exist('SmoothType','var'))
SmoothType='gaussian';
end
end

if isfunction
PassBand = CheckVararginPairs('PassBand', NaN, varargin{:});
else
if ~(exist('PassBand','var'))
PassBand=NaN;
end
end

if isfunction
SamplingFrequency = CheckVararginPairs('SamplingFrequency', 1000, varargin{:});
else
if ~(exist('SamplingFrequency','var'))
SamplingFrequency=1000;
end
end
%%

if isfunction
[cfg] = cgg_generateNeuralDataFoldersTopLevel(varargin{:});
elseif (exist('inputfolder','var'))&&(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('inputfolder',...
    inputfolder,'outdatadir',outdatadir);
elseif (exist('inputfolder','var'))&&~(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('inputfolder',inputfolder);
elseif ~(exist('inputfolder','var'))&&(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('outdatadir',outdatadir);
else
[cfg] = cgg_generateNeuralDataFoldersTopLevel;
end

outdatafile_TrialInformation=...
   sprintf([cfg.outdatadir_TrialInformation filesep ...
   'Trial_Definition_%s.mat'],cfg.SessionName);

m_rectrialdefs = load(outdatafile_TrialInformation);
rectrialdefs=m_rectrialdefs.rectrialdefs;

NumSectionsPerTrial=cellfun(@(x) sum(~isnan(x)),Start_IDX);
NumSections=sum(NumSectionsPerTrial);

[NumTrials,~]=size(rectrialdefs);

AllOutData_tmp=cell(NumTrials,1);
TrialNumbers_tmp=NaN(NumTrials,1);
NumChannels_tmp=NaN(NumTrials,1);
NumSamples_tmp=NaN(NumTrials,1);
% AllOutData_tmp=cell(NumSections);
% TrialNumbers=NaN(NumSections,1);

%% Update Information Setup

q = parallel.pool.DataQueue;
afterEach(q, @nUpdateWaitbar);

All_Iterations = NumTrials;
Iteration_Count = 0;

formatSpec = '*** Current Data Segmentation Progress is: %.2f%%%%\n';
Current_Message=sprintf(formatSpec,0);
% disp(Current_Message);
fprintf(Current_Message);
%%
parfor tidx=1:NumTrials
    this_trial_index=rectrialdefs(tidx,8);
    TrialNumbers_tmp(tidx)=this_trial_index;
    this_NumSections=NumSectionsPerTrial(tidx);
    
    if iscell(Start_IDX)
    this_Start_IDX=Start_IDX{tidx};
    else   
    this_Start_IDX=Start_IDX(tidx);
    end
    if iscell(End_IDX)
    this_End_IDX=End_IDX{tidx};
    else   
    this_End_IDX=End_IDX(tidx);
    end
%%     disp(tidx)

    this_AllOutData_tmp=cell(this_NumSections,1);
    this_Data_Unsmoothed=cell(this_NumSections,1);
    
    this_NumChannels_tmp=0;
    this_NumSamples_tmp=0;

    for sidx=1:this_NumSections
        [this_AllOutData_tmp{sidx},this_Data_Unsmoothed{sidx}] = cgg_getSingleTrialDataFromTimeSegments_v2(...
    this_Start_IDX(sidx),this_End_IDX(sidx),fullfilename,this_trial_index,...
    Smooth_Factor,'SmoothType',SmoothType,'PassBand',PassBand,'SamplingFrequency',SamplingFrequency);

    [this_NumChannels,this_NumSamples]=size(this_AllOutData_tmp{sidx});
    this_NumChannels_tmp=max([this_NumChannels_tmp,this_NumChannels]);
    this_NumSamples_tmp=max([this_NumSamples_tmp,this_NumSamples]);
    end
    
% [AllOutData_tmp{tidx},Data_Unsmoothed{tidx}] = cgg_getSingleTrialDataFromTimeSegments_v2(...
%     this_Start_IDX,this_End_IDX,fullfilename,this_trial_index,...
%     Smooth_Factor);
AllOutData_tmp{tidx}=this_AllOutData_tmp;
Data_Unsmoothed{tidx}=this_Data_Unsmoothed;

% [NumChannels_tmp(tidx),NumSamples_tmp(tidx)]=size(AllOutData_tmp{tidx});
NumChannels_tmp(tidx)=this_NumChannels_tmp;
NumSamples_tmp(tidx)=this_NumSamples_tmp;
%%
send(q, tidx);
end
%%
NumChannels=max(NumChannels_tmp);
NumSamples=max(NumSamples_tmp);

% AllOutData=NaN(NumChannels,NumSamples,NumTrials);
% OutData_Unsmoothed=NaN(1,NumSamples,NumTrials);
AllOutData=cell(NumSections,1);
OutData_Unsmoothed=cell(NumSections,1);
TrialNumbers=NaN(NumSections,1);
SectionCounter=1;
%%
for tidx=1:NumTrials
    
    this_AllOutData=AllOutData_tmp{tidx};
    this_Data_Unsmoothed=Data_Unsmoothed{tidx};
    this_NumSections=NumSectionsPerTrial(tidx);
    this_TrialNumber=TrialNumbers_tmp(tidx);
    
    for sidx=1:this_NumSections
        AllOutData{SectionCounter}=this_AllOutData{sidx};
        OutData_Unsmoothed{SectionCounter}=this_Data_Unsmoothed{sidx};
        TrialNumbers(SectionCounter)=this_TrialNumber;
        SectionCounter=SectionCounter+1;
    end
    %%
%     [this_NumChannels,this_NumSamples]=size(AllOutData_tmp{tidx});
% 
%     AllOutData(1:this_NumChannels,1:this_NumSamples,tidx)=...
%         AllOutData_tmp{tidx};
%     OutData_Unsmoothed(1,1:this_NumSamples,tidx)=...
%         Data_Unsmoothed{tidx};
 
end

function nUpdateWaitbar(~)
    Iteration_Count = Iteration_Count + 1;
    Current_Progress=Iteration_Count/All_Iterations*100;
%     Delete_Message=repmat('\b',1,length(Current_Message)+1);
    Delete_Message=repmat(sprintf('\b'),1,length(Current_Message)-1);
%     fprintf(Delete_Message);
    Current_Message=sprintf(formatSpec,Current_Progress);
%     disp(Current_Message);
    fprintf([Delete_Message,Current_Message]);
end


end

