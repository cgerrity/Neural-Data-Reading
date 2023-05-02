allBlockData.Dim = allBlockData.NumActiveDims;
allBlockData.Sto = 1-allBlockData.HighRewardValue;
allBlockData.IvE = allBlockData.ID_ED;

blockModels.LP = NewBlockResults(allBlockData, 'LP');
blockModels.ProportionLps = NewBlockResults(allBlockData, 'IsLearned');
blockModels.PostLpAcc = NewBlockResults(allBlockData, 'PostLpAcc');