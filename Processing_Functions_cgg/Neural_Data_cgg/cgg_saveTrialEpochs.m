function cgg_saveTrialEpochs(Input,Probe_Area,trialVariables,Epoch,cfg)
%CGG_SAVETRIALEPOCHS Summary of this function goes here
%   Detailed explanation goes here

%%

Probe_Order={'ACC_001','ACC_002','PFC_001','PFC_002','CD_001','CD_002'};

NumProbes=length(Probe_Order);

tmp_ProbeNumber=1:NumProbes;

this_ProbeNumber=strcmp(Probe_Order,Probe_Area);
this_ProbeNumber=tmp_ProbeNumber(this_ProbeNumber);

%%

DataDir=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch.Data.path;
TargetDir=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch.Target.path;

Data_SaveName='%s_Data_%d.mat';
Target_SaveName='Target_Information.mat';
ProbeProcessing_SaveName='Probe_Processing_Information.mat';

Data_SaveNameFull=[DataDir filesep Data_SaveName];
Target_SaveNameFull=[TargetDir filesep Target_SaveName];
ProbeProcessing_SaveNameFull=[TargetDir filesep ProbeProcessing_SaveName];

TrialNumbers=Input(2).TrialNumber;

[NumChannels,NumSamples,NumData]=size(Input(2).Trials);

Disconnected_Channels=Input(3).Connected_Channels;
NotSignificant_Channels=Input(3).Significant_Channels;

%%

Target_IDX=false(1,length(trialVariables));

%% Update Information Setup

q = parallel.pool.DataQueue;
afterEach(q, @nUpdateWaitbar);

All_Iterations = NumData;
Iteration_Count = 0;

formatSpec = '*** Current Epoch Saving Progress is: %.2f%%%%\n';
Current_Message=sprintf(formatSpec,0);
% disp(Current_Message);
fprintf(Current_Message);

%%

parfor didx=1:NumData
    this_TrialNumber=TrialNumbers(didx);
    this_Data=Input(2).Trials(:,:,didx);
    this_Data_SaveName=sprintf(Data_SaveNameFull,Epoch,didx);
    [this_NumChannels,this_NumSamples]=size(this_Data);
    
    this_Data(Disconnected_Channels,:)=NaN;
    this_Data(NotSignificant_Channels,:)=NaN;
    
    this_trialVariablesNumber=[trialVariables.TrialNumber]==this_TrialNumber;
    
    if ~(exist(this_Data_SaveName,'file'))
        m = matfile(this_Data_SaveName,'Writable',true);
        m.Data=NaN(this_NumChannels,this_NumSamples,NumProbes);
    else
        m = matfile(this_Data_SaveName,'Writable',true);
    end
    
    m.Data(:,:,this_ProbeNumber)=this_Data;
    Target_IDX=Target_IDX|this_trialVariablesNumber;
    
    send(q, didx);
end

%% Save the Target Information for Decoding

Target=trialVariables(Target_IDX);

    if ~(exist(Target_SaveNameFull,'file'))
        m_Target = matfile(Target_SaveNameFull,'Writable',true);
        m_Target.Target=Target;
    end
    
%% Save the Probe Processing Information
% This will identify which probes have been processed and do not need to be
% reprocessed. Can also be used to indicate a probe should be reprocessed
% if the value is set to false.
    
    if exist(ProbeProcessing_SaveNameFull,'file')
        m_Probe = matfile(ProbeProcessing_SaveNameFull,'Writable',true);
        ProbeProcessing=m_Probe.ProbeProcessing;
    else
        ProbeProcessing=struct();
        for pidx=1:NumProbes
        ProbeProcessing.(Probe_Order{pidx})=false;
        end
    end
    
    ProbeProcessing.(Probe_Area)=true;
    
    m_Probe = matfile(ProbeProcessing_SaveNameFull,'Writable',true);
    m_Probe.ProbeProcessing=ProbeProcessing;
    
    
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

