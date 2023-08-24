function [AllOutData,TrialNumbers,Data_Unsmoothed] = cgg_getAllTrialDataFromTimeSegments_v2(Start_IDX,End_IDX,fullfilename,Smooth_Factor,varargin)
%CGG_GETALLTRIALDATAFROMTIMESEGMENTS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');
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

[NumTrials,~]=size(rectrialdefs);

AllOutData_tmp=cell(NumTrials);
TrialNumbers=NaN(NumTrials,1);

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
    TrialNumbers(tidx)=this_trial_index;
    
    this_Start_IDX=Start_IDX(tidx);
    this_End_IDX=End_IDX(tidx);
%     disp(tidx)
    
[AllOutData_tmp{tidx},Data_Unsmoothed{tidx}] = cgg_getSingleTrialDataFromTimeSegments_v2(...
    this_Start_IDX,this_End_IDX,fullfilename,this_trial_index,...
    Smooth_Factor);

[NumChannels_tmp(tidx),NumSamples_tmp(tidx)]=size(AllOutData_tmp{tidx});

send(q, tidx);
end

NumChannels=max(NumChannels_tmp);
NumSamples=max(NumSamples_tmp);

AllOutData=NaN(NumChannels,NumSamples,NumTrials);
OutData_Unsmoothed=NaN(1,NumSamples,NumTrials);

for tidx=1:NumTrials
%     disp(tidx)
    
    [this_NumChannels,this_NumSamples]=size(AllOutData_tmp{tidx});

    AllOutData(1:this_NumChannels,1:this_NumSamples,tidx)=...
        AllOutData_tmp{tidx};
    OutData_Unsmoothed(1,1:this_NumSamples,tidx)=...
        Data_Unsmoothed{tidx};
 
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

