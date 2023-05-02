function [AllOutData,TrialNumbers] = cgg_getAllTrialDataFromTimeSegments(Start_IDX,End_IDX,fullfilename,varargin)
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
%%
parfor tidx=1:NumTrials
    this_trial_index=rectrialdefs(tidx,8);
    TrialNumbers(tidx)=this_trial_index;
    
    this_Start_IDX=Start_IDX(tidx);
    this_End_IDX=End_IDX(tidx);
    disp(tidx)
    
[AllOutData_tmp{tidx}] = cgg_getSingleTrialDataFromTimeSegments(...
    this_Start_IDX,this_End_IDX,fullfilename,this_trial_index);

[NumChannels_tmp(tidx),NumSamples_tmp(tidx)]=size(AllOutData_tmp{tidx});
      
end

NumChannels=max(NumChannels_tmp);
NumSamples=max(NumSamples_tmp);

AllOutData=NaN(NumChannels,NumSamples,NumTrials);

for tidx=1:NumTrials
    disp(tidx)
    
    [this_NumChannels,this_NumSamples]=size(AllOutData_tmp{tidx});

    AllOutData(1:this_NumChannels,1:this_NumSamples,tidx)=...
        AllOutData_tmp{tidx};
 
end


end

