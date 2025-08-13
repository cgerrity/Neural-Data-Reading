function [IAPathName,RemovalTablePathName] = ...
    cgg_generateImportanceAnalysisFileNames(Method,NumRemoved,...
    RemovalType,Fold,EpochDir,SessionName,MatchType,TrialFilter, ...
    TargetFilter)
%CGG_GENERATEIMPORTANCEANALYSISFILENAMES Summary of this function goes here
%   Detailed explanation goes here

IAPath = fullfile(EpochDir.Results,'Analysis','Importance Analysis',...
    RemovalType,SessionName,TrialFilter,TargetFilter,Method,'Fold %d');
IAPath = sprintf(IAPath,Fold);


switch Method
    case 'Rank'
        IAName = sprintf('IA_Table_%s',MatchType);
        RemovalTableName = sprintf('RemovalTable_%s.mat',MatchType);
    otherwise
        IAName = sprintf('IA_Table-%d_%s',NumRemoved,MatchType);
        RemovalTableName = sprintf('RemovalTable-%d_%s.mat',NumRemoved,MatchType);
end

IAPathName = fullfile(IAPath,IAName);
RemovalTablePathName = fullfile(IAPath,RemovalTableName);

IAPathName = char(IAPathName);
RemovalTablePathName = char(RemovalTablePathName);

end

