function PreviousOutcome = cgg_getCorrectedPreviousOutcome(Identifiers_Table,ZeroNaN)
%CGG_GETCORRECTEDPREVIOUSOUTCOME Summary of this function goes here
%   Detailed explanation goes here

Block = Identifiers_Table.("Block");
BlockDiff = [1;diff(Block)];
NAPreviousOutcome = BlockDiff ~= 0;

PreviousOutcome = Identifiers_Table.("Previous Trial");
if ZeroNaN
PreviousOutcome(NAPreviousOutcome) = 0;
else
PreviousOutcome(NAPreviousOutcome) = NaN;
end

% Identifiers_Table.("Previous Outcome Corrected") = PreviousOutcome;

end

