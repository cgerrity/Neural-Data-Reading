function varS = get_Variables4Regress(data,BLinfo,variable,numTrls)

varS = NaN(size(numTrls,1),1);
switch variable
    case 'outcome'
        varS(data.tr_align.trialOutcome == 0 & data.tr_align.isChoice_HighReward == 1) = 1;          % correct trial
        varS((data.tr_align.trialOutcome == 0 | data.tr_align.trialOutcome == 6) & data.tr_align.isChoice_HighReward == 0) = 2;  % error trial
    case 'priorTrl - correct'
        tmp_varS = NaN(size(numTrls,1),1);
        tmp_varS(data.tr_align.trialOutcome == 0 & data.tr_align.isChoice_HighReward == 1) = 1;          % correct trial
        tmp_varS((data.tr_align.trialOutcome == 0 | data.tr_align.trialOutcome == 6) & data.tr_align.isChoice_HighReward == 0) = 0;  % error trial
        choiceTrlInds = find(~isnan(tmp_varS));
        choiceTrls = tmp_varS(choiceTrlInds);
        correctPostErrorTrls = strfind(choiceTrls',[0 1])+1;
        correctPostCorrectTrls = strfind(choiceTrls',[1 1])+1;
        varS(choiceTrlInds(correctPostErrorTrls)) = choiceTrls(correctPostErrorTrls);
        varS(choiceTrlInds(correctPostCorrectTrls)) = choiceTrls(correctPostCorrectTrls)+1;
    case 'priorTrl - error'
        tmp_varS = NaN(size(numTrls,1),1);
        tmp_varS(data.tr_align.trialOutcome == 0 & data.tr_align.isChoice_HighReward == 1) = 1;          % correct trial
        tmp_varS((data.tr_align.trialOutcome == 0 | data.tr_align.trialOutcome == 6) & data.tr_align.isChoice_HighReward == 0) = 0;  % error trial
        choiceTrlInds = find(~isnan(tmp_varS));
        choiceTrls = tmp_varS(choiceTrlInds);
        errorPostCorrectTrls = strfind(choiceTrls',[1 0])+1;
        errorPostErrorTrls = strfind(choiceTrls',[0 0])+1;
        varS(choiceTrlInds(errorPostCorrectTrls)) = choiceTrls(errorPostCorrectTrls)+1;
        varS(choiceTrlInds(errorPostErrorTrls)) = choiceTrls(errorPostErrorTrls);
    case 'chosen color'
        varS(data.tr_align.Choice_Color == 1) = 1;           % chosen color 1
        varS(data.tr_align.Choice_Color == 2) = 2;           % chosen color 2
    case 'target color'
        varS((data.tr_align.T1_Color == 1 & data.tr_align.T1_is_HighReward == 1) | (data.tr_align.T2_Color == 1 & data.tr_align.T2_is_HighReward == 1)) = 1;   % target is color 1
        varS((data.tr_align.T1_Color == 2 & data.tr_align.T1_is_HighReward == 1) | (data.tr_align.T2_Color == 2 & data.tr_align.T2_is_HighReward == 1)) = 2;   % target is color 2
    case 'distractor color'
        varS((data.tr_align.T1_Color == 1 & data.tr_align.T1_is_HighReward == 0) | (data.tr_align.T2_Color == 1 & data.tr_align.T2_is_HighReward == 0)) = 1;   % distractor is color 1
        varS((data.tr_align.T1_Color == 2 & data.tr_align.T1_is_HighReward == 0) | (data.tr_align.T2_Color == 2 & data.tr_align.T2_is_HighReward == 0)) = 2;   % distractor is color 2
    case 'chosen motion'
        varS(data.tr_align.Choice_ShapeAction == 1) = 1;           % chosen action down
        varS(data.tr_align.Choice_ShapeAction == 2) = 2;           % chosen action up
    case 'target motion'
        varS((data.tr_align.T1_ShapeAction == 1 & data.tr_align.T1_is_HighReward == 1) | (data.tr_align.T2_ShapeAction == 1 & data.tr_align.T2_is_HighReward == 1)) = 1;   % target motion down
        varS((data.tr_align.T1_ShapeAction == 2 & data.tr_align.T1_is_HighReward == 1) | (data.tr_align.T2_ShapeAction == 2 & data.tr_align.T2_is_HighReward == 1)) = 2;   % target motion up
    case 'distractor motion'
        varS((data.tr_align.T1_ShapeAction == 1 & data.tr_align.T1_is_HighReward == 0) | (data.tr_align.T2_ShapeAction == 1 & data.tr_align.T2_is_HighReward == 0)) = 1;   % distractor motion down
        varS((data.tr_align.T1_ShapeAction == 2 & data.tr_align.T1_is_HighReward == 0) | (data.tr_align.T2_ShapeAction == 2 & data.tr_align.T2_is_HighReward == 0)) = 2;   % distractor motion up
    case 'chosen location'
        varS(data.tr_align.Choice_Location == 1) = 1;           % chosen location left
        varS(data.tr_align.Choice_Location == 2) = 2;           % chosen location right
    case 'target location'
        varS(data.tr_align.T1_is_HighReward == 1) = 1;           % target location left
        varS(data.tr_align.T2_is_HighReward == 1) = 2;           % target location right
    case 'distractor location'
        varS(data.tr_align.T1_is_HighReward == 0) = 1;           % distractor location left
        varS(data.tr_align.T2_is_HighReward == 0) = 2;           % distractor location right       
    case 'chosen dimming'
        varS(~isnan(data.tr_align.response_TargetMotionDir_Dim1)) = 1;           % chosen dimming 1
        varS(~isnan(data.tr_align.response_TargetMotionDir_Dim2)) = 2;           % chosen dimming 2
    case 'target dimming'
        varS(data.tr_align.firstDim_is_HighReward == 1) = 1;           % target dimming 1
        varS(data.tr_align.firstDim_is_HighReward == 0) = 2;           % target dimming 2
    case 'distractor dimming'
        varS(data.tr_align.firstDim_is_HighReward == 0) = 1;           % distractor dimming 1
        varS(data.tr_align.firstDim_is_HighReward == 1) = 2;           % distractor dimming 2    
    case 'RPE'
        varS = data.RL_align.RPE;       % RL parameter
    case 'RPEpos'
        varS = data.RL_align.RPEpos;        % RL parameter
    case 'RPEneg'
        varS = data.RL_align.RPEneg;        % RL parameter
    case 'choiceProbChosenStim'
        varS = data.RL_align.choiceProbabilityChosenStimulus;       % RL parameter
    case 'ValChosenCorrect'
        varS = data.RL_align.ValChosenCorrect;      % RL parameter
    case 'ValChosenError'
        varS = data.RL_align.ValChosenIncorrect;        % RL parameter
    case {'learning progress', 'learning - correct', 'learning - error', 'RPE - preLP', 'RPEpos - preLP', 'RPEneg - preLP',...
            'choiceProbChosenStim - preLP', 'ValChosenCorrect - preLP', 'ValChosenError - preLP',...
            'RPE - postLP', 'RPEpos - postLP', 'RPEneg - postLP','choiceProbChosenStim - postLP', ...
            'ValChosenCorrect - postLP', 'ValChosenError - postLP','RPE - pretrl10', 'RPEpos - pretrl10', 'RPEneg - pretrl10',...
            'choiceProbChosenStim - pretrl10','ValChosenCorrect - pretrl10', 'ValChosenError - pretrl10',...
            'RPE - posttrl10', 'RPEpos - posttrl10', 'RPEneg - posttrl10','choiceProbChosenStim - posttrl10', ...
            'ValChosenCorrect - posttrl10', 'ValChosenError - posttrl10','trlNum - error', 'trlNum - correct',...
            'learning10 - correct','learning10 - error','outcome - duringLearn','outcome - afterLearn','outcome - duringLearn10','outcome - afterLearn10',...
            'preLP - Error', 'preLP - correct', 'postLP - Error', 'postLP - correct', 'LPcentered - error', 'LPcentered - correct'}
        [ori_trlIdx_dL, ori_trlIdx_aL, ori_trlIdx_pre10, ori_trlIdx_post10,...
            refLP_error, refLP_correct, trlNum_error, trlNum_correct, ori_trlIdx_errors, ori_trlIdx_corrects] = deal([]);
        
        outcome = NaN(size(data.tr_align.trialOutcome));
        outcome(data.tr_align.trialOutcome == 0 & data.tr_align.isChoice_HighReward == 1) = 1;          % CORRECT TRIAL
        outcome((data.tr_align.trialOutcome == 0 | data.tr_align.trialOutcome == 6) & data.tr_align.isChoice_HighReward == 0) = 2; % ERROR TRIAL
        for iBl = 1:size(BLinfo.BL,2)                   % determine for every block which trials during and after learning
            if ~isnan(BLinfo.iLearn(iBl))
                dL = BLinfo.BL{iBl}.trl_ind(1:BLinfo.iLearn(iBl)-1); %trialIdx --> trl_ind
                aL = BLinfo.BL{iBl}.trl_ind(BLinfo.iLearn(iBl):end); %trialIdx --> trl_ind
                ori_trlIdx_dL = cat(1,ori_trlIdx_dL,dL);
                ori_trlIdx_aL = cat(1,ori_trlIdx_aL,aL);
                
                if numel(BLinfo.BL{iBl}.trl_ind) > 80 % Responses capped at 80
                    [~,newResponsesInd,~] = intersect(data.hd_align.TrlNum,BLinfo.BL{iBl}.trl_ind);
                    BLinfo.BL{iBl}.Responses = outcome(newResponsesInd)';
                    BLinfo.BL{iBl}.Responses(BLinfo.BL{iBl}.Responses == 2) = 0;
                end
                
                dL_error = -numel(find(BLinfo.BL{iBl}.Responses(1:BLinfo.iLearn(iBl)-1) == 0)):-1;
                dL_correct = -numel(find(BLinfo.BL{iBl}.Responses(1:BLinfo.iLearn(iBl)-1) == 1)):-1;
                aL_error = 1:numel(find(BLinfo.BL{iBl}.Responses(BLinfo.iLearn(iBl):end) == 0));
                aL_correct = 1:numel(find(BLinfo.BL{iBl}.Responses(BLinfo.iLearn(iBl):end) == 1));
                
                refLP_error = cat(1,refLP_error,[dL_error aL_error]');
                refLP_correct = cat(1,refLP_correct,[dL_correct aL_correct]');
                trlNum_error = cat(1,trlNum_error,find(BLinfo.BL{iBl}.Responses == 0)');
                trlNum_correct = cat(1,trlNum_correct,find(BLinfo.BL{iBl}.Responses == 1)');
                ori_trlIdx_errors = cat(1,ori_trlIdx_errors,BLinfo.BL{iBl}.trl_ind(find(BLinfo.BL{iBl}.Responses == 0)));
                ori_trlIdx_corrects = cat(1,ori_trlIdx_corrects,BLinfo.BL{iBl}.trl_ind(find(BLinfo.BL{iBl}.Responses == 1)));
                
                pre10 = BLinfo.BL{iBl}.trl_ind(1:10);
                post10 = BLinfo.BL{iBl}.trl_ind(11:end);
                ori_trlIdx_pre10 = cat(1,ori_trlIdx_pre10,pre10);
                ori_trlIdx_post10 = cat(1,ori_trlIdx_post10,post10);
            end
            
        end
        % get back trial indices that match sdf_align trials
        [a,trlIdx_dL,c]= intersect(data.hd_align.TrlNum,ori_trlIdx_dL);
        [a,trlIdx_aL,c]= intersect(data.hd_align.TrlNum,ori_trlIdx_aL);
        [~,trlIdx_pre10,~]= intersect(data.hd_align.TrlNum,ori_trlIdx_pre10);
        [~,trlIdx_post10,~]= intersect(data.hd_align.TrlNum,ori_trlIdx_post10);
        [~,trlIdx_errors,~]= intersect(data.hd_align.TrlNum,ori_trlIdx_errors);
        [~,trlIdx_corrects,~]= intersect(data.hd_align.TrlNum,ori_trlIdx_corrects);
        
        % get the outcome of the learning trials for varibles specific to outcome
        dL_out = outcome(trlIdx_dL);
        aL_out = outcome(trlIdx_aL);
        pre10_out = outcome(trlIdx_pre10);
        post10_out = outcome(trlIdx_post10);
        switch variable          
            case 'learning progress'          % during or after learning
                varS(trlIdx_dL) = 1;                 % during learning
                varS(trlIdx_aL) = 2;                 % after learning
            case 'learning - correct'
                varS(trlIdx_dL(dL_out==1)) = 1;                 % during learning - correct trial
                varS(trlIdx_aL(aL_out==1)) = 2;                 % after learning - correct trial
            case 'learning - error'
                varS(trlIdx_dL(dL_out==2)) = 1;                 % during learning - error trial
                varS(trlIdx_aL(aL_out==2)) = 2;                 % after learning - error trial
            case 'preLP - Error'
                varS(trlIdx_dL(dL_out==2)) = refLP_error(refLP_error < 0); % error trls ranked pre LP
            case 'preLP - correct'
                varS(trlIdx_dL(dL_out==1)) = refLP_correct(refLP_correct < 0); % correct trls ranked pre LP
            case 'postLP - Error'
                varS(trlIdx_aL(aL_out==2)) = refLP_error(refLP_error > 0); % error trls ranked post LP
            case 'postLP - correct'
                varS(trlIdx_aL(aL_out==1)) = refLP_correct(refLP_correct > 0); % correct trls ranked post LP
            case 'LPcentered - error'
                varS(trlIdx_dL(dL_out==2)) = abs(refLP_error(refLP_error < 0)); % error trls ranked pre LP
                varS(trlIdx_aL(aL_out==2)) = refLP_error(refLP_error > 0); % error trls ranked post LP
            case 'LPcentered - correct'
                varS(trlIdx_dL(dL_out==1)) = abs(refLP_correct(refLP_correct < 0)); % correct trls ranked pre LP
                varS(trlIdx_aL(aL_out==1)) = refLP_correct(refLP_correct > 0); % correct trls ranked post LP
            case 'trlNum - error'
                varS(trlIdx_errors) = trlNum_error; % trl num in block - error
            case 'trlNum - correct'
                varS(trlIdx_corrects) = trlNum_correct; % trl num in block - correct
            case 'RPE - preLP'
                varS(trlIdx_dL) = data.RL_align.RPE(trlIdx_dL); % during learning only
            case 'RPEpos - preLP'
                varS(trlIdx_dL) = data.RL_align.RPEpos(trlIdx_dL); % during learning only
            case 'RPEneg - preLP'
                varS(trlIdx_dL) = data.RL_align.RPEneg(trlIdx_dL); % during learning only
            case 'choiceProbChosenStim - preLP'
                varS(trlIdx_dL) = data.RL_align.choiceProbabilityChosenStimulus(trlIdx_dL); % during learning only
            case 'ValChosenCorrect - preLP'
                varS(trlIdx_dL) = data.RL_align.ValChosenCorrect(trlIdx_dL); % during learning only
            case 'ValChosenError - preLP'
                varS(trlIdx_dL) = data.RL_align.ValChosenIncorrect(trlIdx_dL); % during learning only
            case 'RPE - postLP'
                varS(trlIdx_aL) = data.RL_align.RPE(trlIdx_aL); % after learning only
            case 'RPEpos - postLP'
                varS(trlIdx_aL) = data.RL_align.RPEpos(trlIdx_aL); % after learning only
            case 'RPEneg - postLP'
                varS(trlIdx_aL) = data.RL_align.RPEneg(trlIdx_aL); % after learning only
            case 'choiceProbChosenStim - postLP'
                varS(trlIdx_aL) = data.RL_align.choiceProbabilityChosenStimulus(trlIdx_aL); % after learning only
            case 'ValChosenCorrect - postLP'
                varS(trlIdx_aL) = data.RL_align.ValChosenCorrect(trlIdx_aL); % after learning only
            case 'ValChosenError - postLP'
                varS(trlIdx_aL) = data.RL_align.ValChosenIncorrect(trlIdx_aL); % after learning only
            case 'RPE - pretrl10'
                varS(trlIdx_pre10) = data.RL_align.RPE(trlIdx_pre10); % during learning only
            case 'RPEpos - pretrl10'
                varS(trlIdx_pre10) = data.RL_align.RPEpos(trlIdx_pre10); % during learning only
            case 'RPEneg - pretrl10'
                varS(trlIdx_pre10) = data.RL_align.RPEneg(trlIdx_pre10); % during learning only
            case 'choiceProbChosenStim - pretrl10'
                varS(trlIdx_pre10) = data.RL_align.choiceProbabilityChosenStimulus(trlIdx_pre10); % during learning only
            case 'ValChosenCorrect - pretrl10'
                varS(trlIdx_pre10) = data.RL_align.ValChosenCorrect(trlIdx_pre10); % during learning only
            case 'ValChosenError - pretrl10'
                varS(trlIdx_pre10) = data.RL_align.ValChosenIncorrect(trlIdx_pre10); % during learning only
            case 'RPE - posttrl10'
                varS(trlIdx_post10) = data.RL_align.RPE(trlIdx_post10); % after learning only
            case 'RPEpos - posttrl10'
                varS(trlIdx_post10) = data.RL_align.RPEpos(trlIdx_post10); % after learning only
            case 'RPEneg - posttrl10'
                varS(trlIdx_post10) = data.RL_align.RPEneg(trlIdx_post10); % after learning only
            case 'choiceProbChosenStim - posttrl10'
                varS(trlIdx_post10) = data.RL_align.choiceProbabilityChosenStimulus(trlIdx_post10); % after learning only
            case 'ValChosenCorrect - posttrl10'
                varS(trlIdx_post10) = data.RL_align.ValChosenCorrect(trlIdx_post10); % after learning only
            case 'ValChosenError - posttrl10'
                varS(trlIdx_post10) = data.RL_align.ValChosenIncorrect(trlIdx_post10); % after learning only
            case 'outcome - duringLearn'
                varS(trlIdx_dL) = dL_out;
            case 'outcome - afterLearn'
                varS(trlIdx_aL) = aL_out;
            case 'outcome - duringLearn10'
                varS(trlIdx_pre10) = pre10_out;
            case 'outcome - afterLearn10'
                varS(trlIdx_post10) = post10_out;
            case 'learning10 - correct'
                varS(trlIdx_pre10(pre10_out==1)) = 1;
                varS(trlIdx_post10(post10_out==1)) = 2;
            case 'learning10 - error'
                varS(trlIdx_pre10(pre10_out==2)) = 1;
                varS(trlIdx_post10(post10_out==2)) = 2;
        end
end
 




