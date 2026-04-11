function SignificanceTable = cgg_procPermutationTesting(FullTable, varargin)
% CGG_PROCPERMUTATIONTESTING Calculates p-values for all pairwise row comparisons.
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%% Generate Test Data if run as script
if ~isfunction
    if ~(exist('FullTable','var'))
        fprintf('??? Generating test FullTable...\n');
        rng('default'); % For reproducible test results
        
        % Group A and B are paired (same session numbers). Group C is unpaired.
        % Expected Outcomes:
        % A vs B (Paired): Significant difference (Means 0.5 vs 0.8)
        % A vs C (Unpaired): Not significant (Means 0.5 vs 0.5)
        % B vs C (Unpaired): Significant difference (Means 0.8 vs 0.5)
        Test_Accuracy = {randn(20,1)*0.05 + 0.5; ... % Group A (Mean 0.5)
                         randn(20,1)*0.05 + 0.8; ... % Group B (Mean 0.8)
                         randn(25,1)*0.05 + 0.5};    % Group C (Mean 0.5)
        
        Test_SessionNum = {(1:20)'; (1:20)'; (101:125)'};
        
        FullTable = table();
        FullTable.Accuracy = Test_Accuracy;
        FullTable.("Session Number") = Test_SessionNum;
        FullTable.Properties.RowNames = {'GroupA'; 'GroupB'; 'GroupC'};
        
        % Force WantDebug to true for the test run so outputs are visible
        WantDebug = true; 
    end
end

if isfunction
NumIterations = CheckVararginPairs('NumIterations', 1000, varargin{:});
else
if ~(exist('NumIterations','var'))
NumIterations=1000;
end
end

if isfunction
Alpha = CheckVararginPairs('Alpha', 0.05, varargin{:});
else
if ~(exist('Alpha','var'))
Alpha=0.05;
end
end

if isfunction
WantDebug = CheckVararginPairs('WantDebug', false, varargin{:});
else
if ~(exist('WantDebug','var'))
WantDebug=false;
end
end

if isfunction
TargetVariable = CheckVararginPairs('TargetVariable', 'Accuracy', varargin{:});
else
if ~(exist('TargetVariable','var'))
TargetVariable='Accuracy';
end
end

if isfunction
Tail = CheckVararginPairs('Tail', 'both', varargin{:});
else
if ~(exist('Tail','var'))
Tail='both';
end
end

TableVariables = [["P Value", "double"]; ...
    ["Group Name 1", "string"]; ...
    ["Bar Name 1", "string"]; ...
    ["Group Name 2", "string"]; ...
    ["Bar Name 2", "string"]];
NumVariables = size(TableVariables,1);
DefaultSignificanceTable = table('Size',[0,NumVariables],... 
    'VariableNames', TableVariables(:,1),...
    'VariableTypes', TableVariables(:,2));

if isfunction
SignificanceTable = CheckVararginPairs('SignificanceTable', DefaultSignificanceTable, varargin{:});
else
if ~(exist('SignificanceTable','var'))
SignificanceTable=DefaultSignificanceTable;
end
end

%% Initialize Variables
if height(FullTable) <2
    AllComparisons = NaN(0,2);
else
    AllComparisons = nchoosek(1:height(FullTable), 2);
end

if WantDebug
    fprintf('??? Starting Permutation Testing for %d comparisons.\n', size(AllComparisons, 1));
end

if ~isfunction
    TestFig = figure('Name', 'Permutation Test Verification', 'NumberTitle', 'off');
    TestFig.Position = [100, 100, 800, 600];
    tlo = tiledlayout('flow', 'TileSpacing', 'compact');
    title(tlo, 'Permutation Test Null Distributions');
end

%% Loop Through Comparisons
for fidx = 1:size(AllComparisons, 1)
    this_Comparison = AllComparisons(fidx, :);
    Row_1 = FullTable(this_Comparison(1), :);
    Row_2 = FullTable(this_Comparison(2), :);
    
    Name_1 = Row_1.Properties.RowNames{1};
    Name_2 = Row_2.Properties.RowNames{1};
    
    Data_1 = Row_1.(TargetVariable){1};
    Data_2 = Row_2.(TargetVariable){1};
    
    SessionNumber_1 = Row_1.("Session Number"){1};
    SessionNumber_2 = Row_2.("Session Number"){1};
    
    IsPaired = (length(Data_1) == length(Data_2)) && ...
               all(SessionNumber_1 == SessionNumber_2);
    
    if IsPaired
        DataDifference = Data_1 - Data_2;
        MeanDataDifference = mean(DataDifference);
    else
        MeanDataDifference = mean(Data_1) - mean(Data_2);
    end
    
    %% Obtain Composite Distribution
    CompositeNullDistribution = NaN(NumIterations, 1);
    
    parfor nidx = 1:NumIterations
        if ~IsPaired
            % Pool all data together (ensure column vectors for concatenation)
            CombinedData = [Data_1(:); Data_2(:)];
            
            % Randomly shuffle the combined data
            PermutedData = CombinedData(randperm(length(CombinedData)));
            
            % Split back into groups matching original sizes
            this_Data_1 = PermutedData(1:length(Data_1));
            this_Data_2 = PermutedData(length(Data_1)+1:end);
            
            CompositeNullDistribution(nidx) = mean(this_Data_1) - mean(this_Data_2);
        else
            % Sign-flipping permutation: Use randi to strictly generate only +1 and -1.
            % This is mathematically equivalent to randomly swapping paired labels.
            PermutationSigns = randi([0, 1], length(Data_1), 1) * 2 - 1;
            
            this_DataDifference = DataDifference(:) .* PermutationSigns;
            CompositeNullDistribution(nidx) = mean(this_DataDifference);
        end
    end
    
    %% Get P-Value
    switch lower(Tail)
        case {'both', 'two-tailed'}
            P_Value = (sum(abs(CompositeNullDistribution) > abs(MeanDataDifference))) / length(CompositeNullDistribution);
        case {'right', 'greater'}
            P_Value = (sum(CompositeNullDistribution > MeanDataDifference)) / length(CompositeNullDistribution);
        case {'left', 'less'}
            P_Value = (sum(CompositeNullDistribution < MeanDataDifference)) / length(CompositeNullDistribution);
        otherwise
            error('Unknown tail option. Use ''both'', ''right'', or ''left''.');
    end
    
    if WantDebug
        fprintf('??? Comparison %d: %s vs %s | P-Value: %f\n', fidx, Name_1, Name_2, P_Value);
    end
    
    if P_Value < Alpha
        SignificanceTable(height(SignificanceTable)+1, :) = {P_Value, "", Name_1, "", Name_2};
    end
    
    if ~isfunction
        nexttile(tlo);
        histogram(CompositeNullDistribution, 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
        hold on;
        obs_line = xline(MeanDataDifference, 'r-', 'LineWidth', 2);
        
        % Format the title to show the groups, paired status, and p-value
        title(sprintf('%s vs %s\nPaired: %d | P-Value: %.4f', Name_1, Name_2, IsPaired, P_Value), ...
            'Interpreter', 'none', 'FontWeight', 'normal');
        xlabel(sprintf('Difference in %s', TargetVariable));
        ylabel('Frequency');
        legend(obs_line, 'Observed Difference', 'Location', 'best');
        hold off;
    end
end

end