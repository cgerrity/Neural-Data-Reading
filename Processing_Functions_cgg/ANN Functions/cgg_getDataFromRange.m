function this_Data = cgg_getDataFromRange(Data,Range,TimeShiftIDX)
%CGG_GETDATAFROMRANGE Summary of this function goes here
%   Detailed explanation goes here

% this_Range = Range;
%     if ~isnan(TimeShiftIDX)
%         this_Range = this_Range + TimeShiftIDX;
%         this_Range(this_Range<1) = 1;
%         this_Range(this_Range>NumSamples) = NumSamples;
%     end
% 
% this_Data(:,:,:,widx)=Data(:,this_Range,Order);

%%

% Sizes
[C, N, P] = size(Data);
S = Range(:)';          % 1 x nR
% nR = numel(S);

% Reshape shifts to [C, 1, P]
% NOTE: This assumes TimeShiftIDX is ordered with channels varying fastest within each probe.
if isscalar(TimeShiftIDX)
shift3 = TimeShiftIDX;
else
shiftCP = reshape(TimeShiftIDX, [C, P]);
shift3  = reshape(shiftCP, [C, 1, P]);
end

% Build sample indices per (channel,probe)
Sidx = S + shift3;           % [C, nR, P]

% Handle boundaries (choose one)
% 1) Clip to [1, N]
Sidx = max(1, min(N, Sidx));

% 2) Or wrap around:
% Sidx = mod(Sidx-1, N) + 1;

% 3) Or mark OOB as NaN later:
% mask = Sidx < 1 | Sidx > N;
% Sidx = max(1, min(N, Sidx));

% Pull data using linear indices (memory-friendly)
cIdx  = reshape(1:C, [C, 1, 1]);            % [C,1,1]
pOff  = reshape(0:P-1, [1, 1, P]) * (C*N);  % [1,1,P] offsets
linIdx = cIdx + (Sidx - 1) .* C + pOff;     % [C, nR, P]

this_Data = Data(linIdx);                   % [C, nR, P]

% If you chose the 'mask' option above:
% this_Data(mask) = NaN;


end

