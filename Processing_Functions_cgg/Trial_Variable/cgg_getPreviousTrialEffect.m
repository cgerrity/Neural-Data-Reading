function PreviousTrialEffect = cgg_getPreviousTrialEffect(Identifiers_Table)
%CGG_GETPREVIOUSTRIALEFFECT Summary of this function goes here
%   Detailed explanation goes here

PreviousOutcome = Identifiers_Table.("Previous Outcome Corrected");
CurrentOutcome = Identifiers_Table.("Correct Trial");

PreviousTrialEffect = CurrentOutcome*2 + PreviousOutcome + 1;
PreviousTrialEffect(isnan(PreviousTrialEffect)) = 0;
end

