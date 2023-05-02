
%Current block dimensionality
analysisDetails.BlockClasses.Dimensionality.Names = {'All', '2D', '5D'};
analysisDetails.BlockClasses.Dimensionality.Selectors = {@(x) true(size(x,1),1), @(x) TableSelector(x, 'NumActiveDims', @(y) y == 2), @(x) TableSelector(x, 'NumActiveDims', @(y) y == 5)};
%Current block stochasticity
analysisDetails.BlockClasses.Stochasticity.Names = {'All', '15', '30'};
analysisDetails.BlockClasses.Stochasticity.Selectors = {@(x) true(size(x,1),1), @(x) TableSelector(x, 'HighRewardValue', @(y) y == 0.85), @(x) TableSelector(x, 'HighRewardValue', @(y) y == 0.70)};
%Current block intradimensional/extradimensional relationship to
%previous block
analysisDetails.BlockClasses.ID_ED.Names = {'All', 'ID', 'ED'};
analysisDetails.BlockClasses.ID_ED.Selectors = {@(x) true(size(x,1),1), @(x) TableSelector(x, 'ID_ED', @(y) y == 1), @(x) TableSelector(x, 'ID_ED', @(y) y == 0)};%Current block intradimensional/extradimensional relationship to
%Current block learning status
analysisDetails.BlockClasses.LearningStatus.Names = {'All', 'Learned', 'Unlearned'};
analysisDetails.BlockClasses.LearningStatus.Selectors = {@(x) true(size(x,1),1), @(x) TableSelector(x, 'LP', @(y) ~isnan(y)), @(x) TableSelector(x, 'LP', @(y) isnan(y))};


%Current trial accuracy
analysisDetails.TrialClasses.Accuracy.Names = {'All', 'Corr', 'Inc'};
analysisDetails.TrialClasses.Accuracy.Selectors = {@(x) true(size(x,1),1), @(x) TableSelector(x, 'Acc', @(y) y == 1), @(x) TableSelector(x, 'Acc', @(y) y == 0)};
%Learning status of current trial context
analysisDetails.TrialClasses.LearningStatus.Names = {'All', 'Unlearned', 'PreLP', 'PostLP'};
analysisDetails.TrialClasses.LearningStatus.Selectors = {@(x) true(size(x,1),1), @(x) TableSelector(x, 'LearningStatus', @(y) isnan(y)),...
    @(x) TableSelector(x, 'LearningStatus', @(y) y == 0), @(x) TableSelector(x, 'LearningStatus', @(y) y == 1)};

