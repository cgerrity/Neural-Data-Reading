function [OutputIDX,OutputNames] = cgg_procDataSegmentationGroups(Dimension_Each,CorrectTrial,PreviousTrialCorrect,Dimensionality,Gain,Loss,Learned,ProbeProcessing,TargetFeature,ReactionTime,TrialChosen,SessionName,DataNumber,SharedFeatureCoding)
%CGG_PROCDATASEGMENTATIONGROUPS Summary of this function goes here
%   Detailed explanation goes here

OutputIDX=NaN;
OutputNames=string;
Counter_IDX=0;

% Selected Object Dimensions
for didx=1:length(Dimension_Each)
    Counter_IDX=Counter_IDX+1;
    OutputIDX(didx)=Dimension_Each(didx);
    OutputNames(didx)=sprintf("Dimension %d",didx);
end

% Correct Trial
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=CorrectTrial;
OutputNames(Counter_IDX)="Correct Trial";

% Previous Trial
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=PreviousTrialCorrect;
OutputNames(Counter_IDX)="Previous Trial";

% Dimensionality
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=Dimensionality;
OutputNames(Counter_IDX)="Dimensionality";

% Gain
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=Gain;
OutputNames(Counter_IDX)="Gain";

% Loss
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=Loss;
OutputNames(Counter_IDX)="Loss";

% Learned
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=Learned;
OutputNames(Counter_IDX)="Learned";

% Probe Areas

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order=cfg_param.Probe_Order;

AreasInSession=fieldnames(ProbeProcessing);

for pidx=1:length(Probe_Order)
Counter_IDX=Counter_IDX+1;
this_Area=Probe_Order{pidx};
OutputIDX(Counter_IDX)=any(strcmp(this_Area,AreasInSession));
OutputNames(Counter_IDX)=string(this_Area);
end

% Target Feature
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=TargetFeature;
OutputNames(Counter_IDX)="Target Feature";

% Reaction Time
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=ReactionTime;
OutputNames(Counter_IDX)="Reaction Time";

% TrialChosen
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=TrialChosen;
OutputNames(Counter_IDX)="Trial Chosen";

% SessionName

[cfg] = DATA_cggAllSessionInformationConfiguration;
AllSessionNames=replace({cfg.SessionName},'-','_');
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=find(strcmp(AllSessionNames,SessionName));
OutputNames(Counter_IDX)="Session Name";

% DataNumber
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=DataNumber;
OutputNames(Counter_IDX)="Data Number";

% SharedFeatureCoding
Counter_IDX=Counter_IDX+1;
OutputIDX(Counter_IDX)=SharedFeatureCoding;
OutputNames(Counter_IDX)="Shared Feature Coding";

end

