%% DATA_cggAllSessionLearningModelVariables
% Run without Connection to ACCRE

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

Epoch = 'Decision';

FieldsToRemove = {'Value_ObjectsNotPresented_WM'};

%%

for sidx=1:length(cfg)
    
    this_cfg = cfg(sidx);
    LM_Data_Table = cgg_procSingleSessionLearningModelVariables(FieldsToRemove,this_cfg);
    UpdateFunction = @(x) cgg_combineLearningModelAndTarget(x,LM_Data_Table);

    inputfolder=cfg(sidx).inputfolder;
    outdatadir=cfg(sidx).outdatadir;

cgg_updateSessionTargetStructure(UpdateFunction,Epoch,inputfolder,outdatadir);

end

%%
% % % % sel_Session = 1;
% % % % this_cfg = cfg(sel_Session);
% % % % 
% % % % [cfg_Epoch] = cgg_generateEpochFolders(Epoch,'inputfolder',this_cfg.inputfolder,'outdatadir',this_cfg.outdatadir);
% % % % 
% % % % TargetPath=cfg_Epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Target.path;
% % % % TargetPathNameExt=[TargetPath filesep 'Target_Information.mat'];
% % % % 
% % % % m_Target=matfile(TargetPathNameExt,"Writable",false);
% % % % Target=m_Target.Target;
% % % % 
% % % % LM_Data_Table = cgg_procSingleSessionLearningModelVariables(FieldsToRemove,this_cfg);
% % % % NewTargetFunc = @(x) cgg_combineLearningModelAndTarget(x,LM_Data_Table);
% % % % 
% % % % NewTarget = cgg_combineLearningModelAndTarget(Target,LM_Data_Table);
% % % % NewTarget_tmp = NewTargetFunc(Target);

% %%
% 
% [inputfolder_LM,outputfolder_LM,temporaryfolder_LM,~] = ...
%     cgg_getBaseFolders('WantTEBA',true);
% 
% outputfolder_LM = [outputfolder_LM filesep 'Data_Neural'];
% 
% LMPathNameExt = [outputfolder_LM filesep 'Learning_Model_Variables' ...
%     filesep 'FeatureValues_RLWMModelValues_01.mat'];
% 
% m_LM = matfile(LMPathNameExt,"Writable",false);
% 
% LM_FieldNames = fieldnames(m_LM);
% DataIDX = contains(LM_FieldNames,'Data');
% LM_Data_FieldNames = LM_FieldNames(DataIDX);
% NumData = length(LM_Data_FieldNames);
% 
% LM_Data_Cell = cell(1,NumData);
% 
% for didx = 1:NumData
%     this_LM_Data = m_LM.(LM_Data_FieldNames{didx});
%     this_LM_Data = rmfield(this_LM_Data,FieldsToRemove);
% LM_Data_Cell{didx} = this_LM_Data;
% end
% 
% %%
% sel_Session = 1;
% sel_Data = 2;
% this_cfg = cfg(sel_Session);
% 
% [cfg_Epoch] = cgg_generateEpochFolders(Epoch,'inputfolder',this_cfg.inputfolder,'outdatadir',this_cfg.outdatadir);
% 
% this_LearningModelName = cfg(sel_Session).LearningModelName;
% this_ExperimentName = cfg(sel_Session).ExperimentName;
% this_SessionName = cfg(sel_Session).SessionName;
% this_InData = LM_Data_Cell{sel_Data};
% 
% TargetPath=cfg_Epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Target.path;
% TargetPathNameExt=[TargetPath filesep 'Target_Information.mat'];
% 
% m_Target=matfile(TargetPathNameExt,"Writable",false);
% Target=m_Target.Target;
% 
% Target_Table = struct2table(Target);
% 
% RewardOutcome = varfun(@(x) strcmp(x,'True'),Target_Table,"InputVariables","CorrectTrial");
% RewardOutcome = renamevars(RewardOutcome,'Fun_CorrectTrial','RewardOutcome');
% 
% Target_Table = [Target_Table,RewardOutcome];
% 
% LM_Data_Table = cgg_procLearningModelVariables(this_InData,this_LearningModelName);
% 
% Block = LM_Data_Table(:,"blocknumindx");
% Block = renamevars(Block,'blocknumindx','Block');
% TrialInBlock = LM_Data_Table(:,"trialindx");
% TrialInBlock = renamevars(TrialInBlock,'trialindx','TrialInBlock');
% 
% LM_Data_Table = [LM_Data_Table, Block, TrialInBlock];
% 
% T_Target = outerjoin(Target_Table,LM_Data_Table,'Keys',{'RewardOutcome','Block','TrialInBlock'},'MergeKeys',true);
% T_Target = sortrows(T_Target,"TrialNumber","ascend");
% 
% T_Target=rmmissing(T_Target,'DataVariables',"TrialNumber");
% 
% T_Target = table2struct(T_Target);
% 
% %%
% 
% this_SessionFolder=[outputfolder_LM filesep this_ExperimentName ...
%     filesep this_SessionName];
% this_TrialInformationFolder = [this_SessionFolder filesep 'Trial_Information'];
% this_TrialVariableNameExt = sprintf('TrialVariables_%s.mat',this_SessionName);
% this_TrialVariablePathNameExt = [this_TrialInformationFolder filesep this_TrialVariableNameExt];
% 
% m_TrialVariable = matfile(this_TrialVariablePathNameExt,"Writable",false);
% TrialVariables = m_TrialVariable.trialVariables;
% TrialVariables_Table = struct2table(TrialVariables);
% 
% RewardOutcome = varfun(@(x) strcmp(x,'True'),TrialVariables_Table,"InputVariables","CorrectTrial");
% RewardOutcome = renamevars(RewardOutcome,'Fun_CorrectTrial','RewardOutcome');
% 
% TrialVariables_Table = [TrialVariables_Table,RewardOutcome];
% 
% % LM_Data_Table = cgg_procLearningModelVariables(this_InData,this_LearningModelName);
% % 
% % Block = LM_Data_Table(:,"blocknumindx");
% % Block = renamevars(Block,'blocknumindx','Block');
% % TrialInBlock = LM_Data_Table(:,"trialindx");
% % TrialInBlock = renamevars(TrialInBlock,'trialindx','TrialInBlock');
% 
% % LM_Data_Table = [LM_Data_Table, Block, TrialInBlock];
% 
% 
% T_TrialVariables = outerjoin(TrialVariables_Table,LM_Data_Table,'Keys',{'RewardOutcome','Block','TrialInBlock'},'MergeKeys',true);
% T_TrialVariables = sortrows(T_TrialVariables,"TrialNumber","ascend");
