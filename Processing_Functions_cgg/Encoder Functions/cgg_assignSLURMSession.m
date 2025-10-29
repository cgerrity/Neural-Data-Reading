function [Fold,cfg_Encoder] = cgg_assignSLURMSession(Fold,SessionRunIDX,cfg_Session,cfg_Encoder)
%CGG_ASSIGNSLURMSESSION Summary of this function goes here
%   Detailed explanation goes here
if isnan(SessionRunIDX)
    return
end
% Fold = mod(SessionRunIDX-1,10)+1;
% SessionIDX = floor((SessionRunIDX-1)/10)+1;

NumSessions = length(cfg_Session);
SessionIDX = mod(SessionRunIDX-1,NumSessions)+1;
Fold = floor((SessionRunIDX-1)/NumSessions)+1;

cfg_Encoder.Subset = replace(cfg_Session(SessionIDX).SessionName,'-','_');
cfg_Encoder.NumEpochsFull = cfg_Encoder.NumEpochsFull_Final;
cfg_Encoder.NumEpochsSession = cfg_Encoder.NumEpochsFull;
cfg_Encoder.WantSaveOptimalNet = true;

%%
Description = sprintf('Base Case - Fold %d - Session %s',Fold,cfg_Encoder.Subset);
SLURMDescription = '>>> Current SLURM Aim is %s\n';

fprintf(SLURMDescription,Description);

end

