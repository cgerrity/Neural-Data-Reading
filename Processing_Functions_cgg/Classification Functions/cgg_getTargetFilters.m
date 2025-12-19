function Identifiers_Table = cgg_getTargetFilters(Identifiers_Table,TargetFilter)
%CGG_GETTARGETFILTERS Summary of this function goes here
%   Detailed explanation goes here

%% Get the True Values

TrueValue = Identifiers_Table{:,"TrueValue"};

TargetFilterBoolean = false(size(TrueValue));
%%

% TargetFilter = "Label 2 ~ Class 0";

% Pattern_Label = '(label|class)\D*(\d+)';
% Matches = regexp(TargetFilter, Pattern_Label, 'tokens', 'ignorecase');
% Terms = cellfun(@(x) strcat(upper(x{1}(1)), lower(x{1}(2:end))), ...
%     Matches, 'UniformOutput', false);
% TermValues = cellfun(@(x) str2double(x{2}), Matches);

Pattern_Label = '(label)\D*(\d+)';
Matches = regexp(TargetFilter, Pattern_Label, 'tokens', 'ignorecase');
ValueLabel = cellfun(@(x) str2double(x{2}), Matches);
Pattern_Label = '(class)\D*(\d+)';
Matches = regexp(TargetFilter, Pattern_Label, 'tokens', 'ignorecase');
ValueClass = cellfun(@(x) str2double(x{2}), Matches);

if ~isempty(ValueLabel) && ~isempty(ValueClass)
    TargetFilterBoolean(:,ValueLabel) = TrueValue(:,ValueLabel) == ValueClass;
elseif ~isempty(ValueLabel) && isempty(ValueClass)
    TargetFilterBoolean(:,ValueLabel) = true;
elseif isempty(ValueLabel) && ~isempty(ValueClass)
    TargetFilterBoolean = TrueValue == ValueClass;
end

%%
if ~isempty(char(TargetFilter))
Identifiers_Table.(TargetFilter) = TargetFilterBoolean;
end

end

