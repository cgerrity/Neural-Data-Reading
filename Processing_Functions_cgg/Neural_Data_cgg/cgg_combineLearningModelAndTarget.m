function NewTarget = cgg_combineLearningModelAndTarget(Target,LM_Data_Table)
%CGG_COMBINELEARNINGMODELANDTARGET Summary of this function goes here
%   Detailed explanation goes here



Target_Table = struct2table(Target);

RewardOutcome = varfun(@(x) strcmp(x,'True'),Target_Table,"InputVariables","CorrectTrial");
RewardOutcome = renamevars(RewardOutcome,'Fun_CorrectTrial','RewardOutcome');

Target_Table = [Target_Table,RewardOutcome];

Block = LM_Data_Table(:,"blocknumindx");
Block = renamevars(Block,'blocknumindx','Block');
TrialInBlock = LM_Data_Table(:,"trialindx");
TrialInBlock = renamevars(TrialInBlock,'trialindx','TrialInBlock');

LM_Data_Table = [LM_Data_Table, Block, TrialInBlock];

NewTarget = outerjoin(Target_Table,LM_Data_Table,'Keys',{'RewardOutcome','Block','TrialInBlock'},'MergeKeys',true);
NewTarget = sortrows(NewTarget,"TrialNumber","ascend");

NewTarget=rmmissing(NewTarget,'DataVariables',"TrialNumber");

NewTarget = table2struct(NewTarget);

end

