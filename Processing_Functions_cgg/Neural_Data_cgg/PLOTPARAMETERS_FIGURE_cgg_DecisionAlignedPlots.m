%% PLOTPARAMETERS_FIGURE_cgg_DecisionAlignedPlots


%%
TrialDuration_Minimum=10;
TrialVariableTrialNumber=[trialVariables(:).TrialNumber];
NumTrialVariable=length(TrialVariableTrialNumber);

% Baseline
TrialCondition_Baseline=cell(NumTrialVariable,1);
TrialCondition_Baseline(:,1)={trialVariables(:).AbortCode};
TrialCondition_Baseline(:,2)={trialVariables(:).TrialTime};
TrialCondition_Baseline(:,2)=cellfun(@(x){~isempty(x) && x >= TrialDuration_Minimum}, TrialCondition_Baseline(:,2));

MatchValue_Baseline=cell(1);
MatchValue_Baseline{1,1}=0;
MatchValue_Baseline{1,2}=0;
% Single Criteria

Single_TrialCondition_Rewarded=cell(NumTrialVariable,1);
Single_TrialCondition_Unrewarded=cell(NumTrialVariable,1);
Single_TrialCondition_Rewarded(:,1)=[trialVariables(:).CorrectTrial];
Single_TrialCondition_Unrewarded(:,1)=[trialVariables(:).CorrectTrial];

Single_MatchValue_Rewarded=cell(1);
Single_MatchValue_Unrewarded=cell(1);
Single_MatchValue_Rewarded{1}='True';
Single_MatchValue_Unrewarded{1}='False';

% Rewarded
TrialCondition_Rewarded=TrialCondition_Baseline;
TrialCondition_Rewarded(:,3)=[trialVariables(:).CorrectTrial];

MatchValue_Rewarded=MatchValue_Baseline;
MatchValue_Rewarded{1,3}='True';
% Unrewarded
TrialCondition_Unrewarded=TrialCondition_Rewarded;

MatchValue_Unrewarded=MatchValue_Baseline;
MatchValue_Unrewarded{1,3}='False';

% After Learning Point
TrialCondition_Learned=TrialCondition_Baseline;
TrialCondition_Learned(:,3)={trialVariables(:).TrialsFromLP};
TrialCondition_Learned(:,3)=cellfun(@(x){~isempty(x) && x >= 0}, TrialCondition_Learned(:,3));

MatchValue_Learned=MatchValue_Baseline;
MatchValue_Learned{1,3}=1;

% Before Learning Point
TrialCondition_Notlearned=TrialCondition_Learned;

MatchValue_Notlearned=MatchValue_Baseline;
MatchValue_Notlearned{1,3}=0;
% Attentional Load 1
TrialCondition_Attention_1=TrialCondition_Baseline;
TrialCondition_Attention_1(:,3)={trialVariables(:).Dimensionality};

MatchValue_Attention_1=MatchValue_Baseline;
MatchValue_Attention_1{1,3}=1;
% Attentional Load 2
TrialCondition_Attention_2=TrialCondition_Baseline;
TrialCondition_Attention_2(:,3)={trialVariables(:).Dimensionality};

MatchValue_Attention_2=MatchValue_Baseline;
MatchValue_Attention_2{1,3}=2;
% Attentional Load 3
TrialCondition_Attention_3=TrialCondition_Baseline;
TrialCondition_Attention_3(:,3)={trialVariables(:).Dimensionality};

MatchValue_Attention_3=MatchValue_Baseline;
MatchValue_Attention_3{1,3}=3;
% Motivation Gain (3)
TrialCondition_Gain=TrialCondition_Baseline;
TrialCondition_Gain(:,3)={trialVariables(:).Gain};

MatchValue_Gain=MatchValue_Baseline;
MatchValue_Gain{1,3}=3;

% Motivation Loss (3)
TrialCondition_Loss=TrialCondition_Baseline;
TrialCondition_Loss(:,3)={trialVariables(:).Loss};

MatchValue_Loss=MatchValue_Baseline;
MatchValue_Loss{1,3}=-3;

% Motivational Load (2,-1)
TrialCondition_Motivation_1=TrialCondition_Baseline;
TrialCondition_Motivation_1(:,3)={trialVariables(:).Gain};
TrialCondition_Motivation_1(:,4)={trialVariables(:).Loss};

MatchValue_Motivation_1=MatchValue_Baseline;
MatchValue_Motivation_1{1,3}=2;
MatchValue_Motivation_1{1,4}=-1;
% Motivational Load (2,-3)
TrialCondition_Motivation_2=TrialCondition_Baseline;
TrialCondition_Motivation_2(:,3)={trialVariables(:).Gain};
TrialCondition_Motivation_2(:,4)={trialVariables(:).Loss};

MatchValue_Motivation_2=MatchValue_Baseline;
MatchValue_Motivation_2{1,3}=2;
MatchValue_Motivation_2{1,4}=-3;
% Motivational Load (3,-1)
TrialCondition_Motivation_3=TrialCondition_Baseline;
TrialCondition_Motivation_3(:,3)={trialVariables(:).Gain};
TrialCondition_Motivation_3(:,4)={trialVariables(:).Loss};

MatchValue_Motivation_3=MatchValue_Baseline;
MatchValue_Motivation_3{1,3}=3;
MatchValue_Motivation_3{1,4}=-1;
% Motivational Load (3,-3)
TrialCondition_Motivation_4=TrialCondition_Baseline;
TrialCondition_Motivation_4(:,3)={trialVariables(:).Gain};
TrialCondition_Motivation_4(:,4)={trialVariables(:).Loss};

MatchValue_Motivation_4=MatchValue_Baseline;
MatchValue_Motivation_4{1,3}=3;
MatchValue_Motivation_4{1,4}=-3;
% Previous Trial 1 (R)
TrialCondition_Previous_1=TrialCondition_Baseline;
TrialCondition_Previous_1(:,3)=[trialVariables(:).PreviousTrialCorrect];

MatchValue_Previous_1=MatchValue_Baseline;
% MatchValue_Previous_1{1,3}='True';
MatchValue_Previous_1{1,3}='True';
% Previous Trial 2 (U)
TrialCondition_Previous_2=TrialCondition_Baseline;
TrialCondition_Previous_2(:,3)=[trialVariables(:).PreviousTrialCorrect];

MatchValue_Previous_2=MatchValue_Baseline;
% MatchValue_Previous_2{1,3}='True';
MatchValue_Previous_2{1,3}='False';
% % Previous Trial 3 (RU)
% TrialCondition_Previous_3=TrialCondition_Baseline;
% TrialCondition_Previous_3(:,3)=[trialVariables(:).CorrectTrial];
% TrialCondition_Previous_3(:,4)=[trialVariables(:).PreviousTrialCorrect];
% 
% MatchValue_Previous_3=MatchValue_Baseline;
% MatchValue_Previous_3{1,3}='False';
% MatchValue_Previous_3{1,4}='True';
% % Previous Trial 4 (UU)
% TrialCondition_Previous_4=TrialCondition_Baseline;
% TrialCondition_Previous_4(:,3)=[trialVariables(:).CorrectTrial];
% TrialCondition_Previous_4(:,4)=[trialVariables(:).PreviousTrialCorrect];
% 
% MatchValue_Previous_4=MatchValue_Baseline;
% MatchValue_Previous_4{1,3}='False';
% MatchValue_Previous_4{1,4}='False';
%
TrialCondition_Learned_Rewarded=TrialCondition_Learned;
TrialCondition_Notlearned_Rewarded=TrialCondition_Notlearned;
TrialCondition_Learned_Unrewarded=TrialCondition_Learned;
TrialCondition_Notlearned_Unrewarded=TrialCondition_Notlearned;

TrialCondition_Learned_Rewarded(:,4)=[trialVariables(:).CorrectTrial];
TrialCondition_Notlearned_Rewarded(:,4)=[trialVariables(:).CorrectTrial];
TrialCondition_Learned_Unrewarded(:,4)=[trialVariables(:).CorrectTrial];
TrialCondition_Notlearned_Unrewarded(:,4)=[trialVariables(:).CorrectTrial];

MatchValue_Learned_Rewarded=MatchValue_Learned;
MatchValue_Notlearned_Rewarded=MatchValue_Notlearned;
MatchValue_Learned_Unrewarded=MatchValue_Learned;
MatchValue_Notlearned_Unrewarded=MatchValue_Notlearned;

MatchValue_Learned_Rewarded{1,4}='True';
MatchValue_Notlearned_Rewarded{1,4}='True';
MatchValue_Learned_Unrewarded{1,4}='False';
MatchValue_Notlearned_Unrewarded{1,4}='False';


MatchValue=cell(1);
TrialCondition=cell(1);
MatchValue_Learning=cell(1);
TrialCondition_Learning=cell(1);
MatchValue_Attention=cell(1);
TrialCondition_Attention=cell(1);
MatchValue_Motivation=cell(1);
TrialCondition_Motivation=cell(1);
MatchValue_Previous=cell(1);
TrialCondition_Previous=cell(1);
MatchValue_Learning_Rewarded=cell(1);
TrialCondition_Learning_Rewarded=cell(1);
MatchValue_Learning_Unrewarded=cell(1);
TrialCondition_Learning_Unrewarded=cell(1);

MatchValue{1}=MatchValue_Rewarded;
MatchValue{2}=MatchValue_Unrewarded;
TrialCondition{1}=TrialCondition_Rewarded;
TrialCondition{2}=TrialCondition_Unrewarded;

MatchValue_Learning{1}=MatchValue_Learned;
MatchValue_Learning{2}=MatchValue_Notlearned;
TrialCondition_Learning{1}=TrialCondition_Learned;
TrialCondition_Learning{2}=TrialCondition_Notlearned;

MatchValue_Attention{1}=MatchValue_Attention_1;
MatchValue_Attention{2}=MatchValue_Attention_2;
MatchValue_Attention{3}=MatchValue_Attention_3;
TrialCondition_Attention{1}=TrialCondition_Attention_1;
TrialCondition_Attention{2}=TrialCondition_Attention_2;
TrialCondition_Attention{3}=TrialCondition_Attention_3;

MatchValue_Motivation{1}=MatchValue_Motivation_1;
MatchValue_Motivation{2}=MatchValue_Motivation_2;
MatchValue_Motivation{3}=MatchValue_Motivation_3;
MatchValue_Motivation{4}=MatchValue_Motivation_4;
TrialCondition_Motivation{1}=TrialCondition_Motivation_1;
TrialCondition_Motivation{2}=TrialCondition_Motivation_2;
TrialCondition_Motivation{3}=TrialCondition_Motivation_3;
TrialCondition_Motivation{4}=TrialCondition_Motivation_4;

MatchValue_Previous{1}=MatchValue_Previous_1;
MatchValue_Previous{2}=MatchValue_Previous_2;
% MatchValue_Previous{3}=MatchValue_Previous_3;
% MatchValue_Previous{4}=MatchValue_Previous_4;
TrialCondition_Previous{1}=TrialCondition_Previous_1;
TrialCondition_Previous{2}=TrialCondition_Previous_2;
% TrialCondition_Previous{3}=TrialCondition_Previous_3;
% TrialCondition_Previous{4}=TrialCondition_Previous_4;

MatchValue_Learning_Rewarded{1}=MatchValue_Learned_Rewarded;
MatchValue_Learning_Rewarded{2}=MatchValue_Notlearned_Rewarded;
TrialCondition_Learning_Rewarded{1}=TrialCondition_Learned_Rewarded;
TrialCondition_Learning_Rewarded{2}=TrialCondition_Notlearned_Rewarded;

MatchValue_Learning_Unrewarded{1}=MatchValue_Learned_Unrewarded;
MatchValue_Learning_Unrewarded{2}=MatchValue_Notlearned_Unrewarded;
TrialCondition_Learning_Unrewarded{1}=TrialCondition_Learned_Unrewarded;
TrialCondition_Learning_Unrewarded{2}=TrialCondition_Notlearned_Unrewarded;

TrialCondition_All=cell(1);
MatchValue_All=cell(1);

TrialCondition_All{1}=TrialCondition;
MatchValue_All{1}=MatchValue;

TrialCondition_All{2}=TrialCondition_Learning;
MatchValue_All{2}=MatchValue_Learning;

TrialCondition_All{3}=TrialCondition_Attention;
MatchValue_All{3}=MatchValue_Attention;

TrialCondition_All{4}=TrialCondition_Motivation;
MatchValue_All{4}=MatchValue_Motivation;

TrialCondition_All{5}=TrialCondition_Previous;
MatchValue_All{5}=MatchValue_Previous;

% TrialCondition_All{6}=TrialCondition_Learning_Rewarded;
% MatchValue_All{6}=MatchValue_Learning_Rewarded;
% 
% TrialCondition_All{7}=TrialCondition_Learning_Unrewarded;
% MatchValue_All{7}=MatchValue_Learning_Unrewarded;

NumCond=length(TrialCondition_All);
%%
for fidx=1:NumAllFeatures
    
    TrialCondition_Chosen=TrialCondition_Baseline;
    TrialCondition_NOTChosen=TrialCondition_Baseline;
    MatchValue_Chosen=MatchValue_Baseline;
    MatchValue_NOTChosen=MatchValue_Baseline;
    TrialCondition_Chosen(:,3)=TrialCondition_Feature{fidx};
    TrialCondition_NOTChosen(:,3)=cellfun(@(x){~isempty(x) && ~(x == MatchValue_Feature{fidx})}, TrialCondition_Chosen(:,3));
    MatchValue_Chosen{1,3}=MatchValue_Feature{fidx};
    MatchValue_NOTChosen{1,3}=1;
    
    TrialCondition_Chosen_Feature=cell(1);
    MatchValue_Chosen_Feature=cell(1);
    
    TrialCondition_Chosen_Feature{1}=TrialCondition_Chosen;
    TrialCondition_Chosen_Feature{2}=TrialCondition_NOTChosen;
    MatchValue_Chosen_Feature{1}=MatchValue_Chosen;
    MatchValue_Chosen_Feature{2}=MatchValue_NOTChosen;
    
    
    TrialCondition_All{NumCond+fidx}=TrialCondition_Chosen_Feature;
    MatchValue_All{NumCond+fidx}=MatchValue_Chosen_Feature;
end

TrialCondition_Chosen=cell(1,NumAllFeatures);
MatchValue_Chosen=cell(1,NumAllFeatures);

for fidx=1:NumAllFeatures
    TrialCondition_Chosen_tmp=TrialCondition_Baseline;
    MatchValue_Chosen_tmp=MatchValue_Baseline;
    TrialCondition_Chosen_tmp(:,3)=TrialCondition_Feature{fidx};
    MatchValue_Chosen_tmp{1,3}=MatchValue_Feature{fidx};
    
    TrialCondition_Chosen{fidx}=TrialCondition_Chosen_tmp;
    MatchValue_Chosen{fidx}=MatchValue_Chosen_tmp;
end


%%

Smooth_Factor_Global=250;
InYLim_Global=[-0.2,0.2];
InSavePlotCFG_Global=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;

Color_Blue=[0,0.4470,0.7410];
Color_Orange=[0.8500,0.3250,0.0980];
Color_Green=[0.4660,0.6740,0.1880];
Color_Purple=[0.4940,0.1840,0.5560];
Color_Red=[0.8510,0.0667,0.0824];

if exist('Segmented_Baseline','var')
[FullBaseline] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition_Baseline,MatchValue_Baseline,TrialVariableTrialNumber,Segmented_Baseline,TrialNumbers_Baseline);
end

NumFigures=length(MatchValue_All);

InData_Legend_Name_All=cell(1);
InBaseline_Legend_Name_All=cell(1);
InData_X_Name_All=cell(1);
InBaseline_X_Name_All=cell(1);
InData_Title_All=cell(1);
InBaseline_Title_All=cell(1);
InYLim_All=cell(1);
Smooth_Factor_All=cell(1);
InSavePlotCFG_All=cell(1);
InSaveName_All=cell(1);
InSaveDescriptor_All=cell(1);
Plot_Colors_All=cell(1);

InData_Legend_Name_Error={'Rewarded','Unrewarded'};
InBaseline_Legend_Name_Error={'Rewarded','Unrewarded'};
InData_X_Name_Error='Time From Choice Recorded(sec)';
InBaseline_X_Name_Error='Time From Start of Trial(sec)';
InData_Title_Error='Rewarded vs Unrewarded';
InBaseline_Title_Error='Rewarded vs Unrewarded';
InYLim_Error=InYLim_Global;
Smooth_Factor_Error=Smooth_Factor_Global;
InSavePlotCFG_Error=InSavePlotCFG_Global.Correct_vs_Error;
InSaveName_Error='Correct_vs_Incorrect_Decision_Aligned_Channel_%s';
InSaveDescriptor_Error={'Rewarded','Unrewarded'};
Plot_Colors_Error={Color_Blue,Color_Red};


InData_Legend_Name_All{1}=InData_Legend_Name_Error;
InBaseline_Legend_Name_All{1}=InBaseline_Legend_Name_Error;
InData_X_Name_All{1}=InData_X_Name_Error;
InBaseline_X_Name_All{1}=InBaseline_X_Name_Error;
InData_Title_All{1}=InData_Title_Error;
InBaseline_Title_All{1}=InBaseline_Title_Error;
InYLim_All{1}=InYLim_Error;
Smooth_Factor_All{1}=Smooth_Factor_Error;
InSavePlotCFG_All{1}=InSavePlotCFG_Error;
InSaveName_All{1}=InSaveName_Error;
InSaveDescriptor_All{1}=InSaveDescriptor_Error;
Plot_Colors_All{1}=Plot_Colors_Error;

%%
InData_Legend_Name_Learning={'After LP','Before LP'};
InBaseline_Legend_Name_Learning={'After LP','Before LP'};
InData_X_Name_Learning='Time From Choice Recorded(sec)';
InBaseline_X_Name_Learning='Time From Start of Trial(sec)';
InData_Title_Learning='After Learning vs Before Learning';
InBaseline_Title_Learning='After Learning vs Before Learning';
InYLim_Learning=InYLim_Global;
Smooth_Factor_Learning=Smooth_Factor_Global;
InSavePlotCFG_Learning=InSavePlotCFG_Global.Learning;
InSaveName_Learning='Before_After_Learning_Decision_Aligned_Channel_%s';
InSaveDescriptor_Learning={'After','Before'};
Plot_Colors_Learning={Color_Blue,Color_Red};


InData_Legend_Name_All{2}=InData_Legend_Name_Learning;
InBaseline_Legend_Name_All{2}=InBaseline_Legend_Name_Learning;
InData_X_Name_All{2}=InData_X_Name_Learning;
InBaseline_X_Name_All{2}=InBaseline_X_Name_Learning;
InData_Title_All{2}=InData_Title_Learning;
InBaseline_Title_All{2}=InBaseline_Title_Learning;
InYLim_All{2}=InYLim_Learning;
Smooth_Factor_All{2}=Smooth_Factor_Learning;
InSavePlotCFG_All{2}=InSavePlotCFG_Learning;
InSaveName_All{2}=InSaveName_Learning;
InSaveDescriptor_All{2}=InSaveDescriptor_Learning;
Plot_Colors_All{2}=Plot_Colors_Learning;

%%
InData_Legend_Name_Attention={'1-D','2-D','3-D'};
InBaseline_Legend_Name_Attention={'1-D','2-D','3-D'};
InData_X_Name_Attention='Time From Choice Recorded(sec)';
InBaseline_X_Name_Attention='Time From Start of Trial(sec)';
InData_Title_Attention='Attentional Load';
InBaseline_Title_Attention='Attentional Load';
InYLim_Attention=InYLim_Global;
Smooth_Factor_Attention=Smooth_Factor_Global;
InSavePlotCFG_Attention=InSavePlotCFG_Global.Attentional_Load;
InSaveName_Attention='Attention_Decision_Aligned_Channel_%s';
InSaveDescriptor_Attention={'1-D','2-D','3-D'};
Plot_Colors_Attention={Color_Blue,Color_Red,Color_Green};


InData_Legend_Name_All{3}=InData_Legend_Name_Attention;
InBaseline_Legend_Name_All{3}=InBaseline_Legend_Name_Attention;
InData_X_Name_All{3}=InData_X_Name_Attention;
InBaseline_X_Name_All{3}=InBaseline_X_Name_Attention;
InData_Title_All{3}=InData_Title_Attention;
InBaseline_Title_All{3}=InBaseline_Title_Attention;
InYLim_All{3}=InYLim_Attention;
Smooth_Factor_All{3}=Smooth_Factor_Attention;
InSavePlotCFG_All{3}=InSavePlotCFG_Attention;
InSaveName_All{3}=InSaveName_Attention;
InSaveDescriptor_All{3}=InSaveDescriptor_Attention;
Plot_Colors_All{3}=Plot_Colors_Attention;

%%
InData_Legend_Name_Motivation={'Gain:2 Loss:1','Gain:2 Loss:3','Gain:3 Loss:1','Gain:3 Loss:3'};
InBaseline_Legend_Name_Motivation={'Gain:2 Loss:1','Gain:2 Loss:3','Gain:3 Loss:1','Gain:3 Loss:3'};
InData_X_Name_Motivation='Time From Choice Recorded(sec)';
InBaseline_X_Name_Motivation='Time From Start of Trial(sec)';
InData_Title_Motivation='Motivational Load';
InBaseline_Title_Motivation='Motivational Load';
InYLim_Motivation=InYLim_Global;
Smooth_Factor_Motivation=Smooth_Factor_Global;
InSavePlotCFG_Motivation=InSavePlotCFG_Global.Motivational_Context;
InSaveName_Motivation='Motivation_Decision_Aligned_Channel_%s';
InSaveDescriptor_Motivation={'Gain_2_Loss_1','Gain_2_Loss_3','Gain_3_Loss_1','Gain_3_Loss_3'};
Plot_Colors_Motivation={Color_Blue,Color_Red,Color_Green,Color_Purple};


InData_Legend_Name_All{4}=InData_Legend_Name_Motivation;
InBaseline_Legend_Name_All{4}=InBaseline_Legend_Name_Motivation;
InData_X_Name_All{4}=InData_X_Name_Motivation;
InBaseline_X_Name_All{4}=InBaseline_X_Name_Motivation;
InData_Title_All{4}=InData_Title_Motivation;
InBaseline_Title_All{4}=InBaseline_Title_Motivation;
InYLim_All{4}=InYLim_Motivation;
Smooth_Factor_All{4}=Smooth_Factor_Motivation;
InSavePlotCFG_All{4}=InSavePlotCFG_Motivation;
InSaveName_All{4}=InSaveName_Motivation;
InSaveDescriptor_All{4}=InSaveDescriptor_Motivation;
Plot_Colors_All{4}=Plot_Colors_Motivation;


%%
InData_Legend_Name_Previous={'(Rewarded)','(Unrewarded)'};
InBaseline_Legend_Name_Previous={'(Rewarded)','(Unrewarded)'};
InData_X_Name_Previous='Time From Choice Recorded(sec)';
InBaseline_X_Name_Previous='Time From Start of Trial(sec)';
InData_Title_Previous='Previous Trial Rewarded vs Unrewarded';
InBaseline_Title_Previous='Previous Trial Rewarded vs Unrewarded';
InYLim_Previous=InYLim_Global;
Smooth_Factor_Previous=Smooth_Factor_Global;
InSavePlotCFG_Previous=InSavePlotCFG_Global.Previous_Trial_Outcome;
InSaveName_Previous='Previous_Outcome_Decision_Aligned_Channel_%s';
InSaveDescriptor_Previous={'Previous_Rewarded','Previous_Unrewarded'};
Plot_Colors_Previous={Color_Blue,Color_Red};


InData_Legend_Name_All{5}=InData_Legend_Name_Previous;
InBaseline_Legend_Name_All{5}=InBaseline_Legend_Name_Previous;
InData_X_Name_All{5}=InData_X_Name_Previous;
InBaseline_X_Name_All{5}=InBaseline_X_Name_Previous;
InData_Title_All{5}=InData_Title_Previous;
InBaseline_Title_All{5}=InBaseline_Title_Previous;
InYLim_All{5}=InYLim_Previous;
Smooth_Factor_All{5}=Smooth_Factor_Previous;
InSavePlotCFG_All{5}=InSavePlotCFG_Previous;
InSaveName_All{5}=InSaveName_Previous;
InSaveDescriptor_All{5}=InSaveDescriptor_Previous;
Plot_Colors_All{5}=Plot_Colors_Previous;

% %%
% InData_Legend_Name_Learning_Rewarded={'AfterLP','BeforeLP'};
% InBaseline_Legend_Name_Learning_Rewarded={'AfterLP','BeforeLP'};
% InData_X_Name_Learning_Rewarded='Time From Choice Recorded(sec)';
% InBaseline_X_Name_Learning_Rewarded='Time From Start of Trial(sec)';
% InData_Title_Learning_Rewarded='After Learning vs Before Learning Rewarded';
% InBaseline_Title_Learning_Rewarded='After Learning vs Before Learning Rewarded';
% InYLim_Learning_Rewarded=InYLim_Global;
% Smooth_Factor_Learning_Rewarded=Smooth_Factor_Global;
% InSaveName_Learning_Rewarded=[cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment.Learning.Rewarded.path ...
%     filesep 'Before_After_Learning_Rewarded_Decision_Aligned_Channel_%s'];
% Plot_Colors_Learning_Rewarded={'#0072BD','#D95319'};
% 
% 
% InData_Legend_Name_All{6}=InData_Legend_Name_Learning_Rewarded;
% InBaseline_Legend_Name_All{6}=InBaseline_Legend_Name_Learning_Rewarded;
% InData_X_Name_All{6}=InData_X_Name_Learning_Rewarded;
% InBaseline_X_Name_All{6}=InBaseline_X_Name_Learning_Rewarded;
% InData_Title_All{6}=InData_Title_Learning_Rewarded;
% InBaseline_Title_All{6}=InBaseline_Title_Learning_Rewarded;
% InYLim_All{6}=InYLim_Learning_Rewarded;
% Smooth_Factor_All{6}=Smooth_Factor_Learning_Rewarded;
% InSaveName_All{6}=InSaveName_Learning_Rewarded;
% Plot_Colors_All{6}=Plot_Colors_Learning_Rewarded;

% %%
% InData_Legend_Name_Learning_Unrewarded={'AfterLP','BeforeLP'};
% InBaseline_Legend_Name_Learning_Unrewarded={'AfterLP','BeforeLP'};
% InData_X_Name_Learning_Unrewarded='Time From Choice Recorded(sec)';
% InBaseline_X_Name_Learning_Unrewarded='Time From Start of Trial(sec)';
% InData_Title_Learning_Unrewarded='After Learning vs Before Learning Unrewarded';
% InBaseline_Title_Learning_Unrewarded='After Learning vs Before Learning Unrewarded';
% InYLim_Learning_Unrewarded=InYLim_Global;
% Smooth_Factor_Learning_Unrewarded=Smooth_Factor_Global;
% InSaveName_Learning_Unrewarded=[cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment.Learning.Unrewarded.path ...
%     filesep 'Before_After_Learning_Unrewarded_Decision_Aligned_Channel_%s'];
% Plot_Colors_Learning_Unrewarded={'#0072BD','#D95319'};
% 
% 
% InData_Legend_Name_All{7}=InData_Legend_Name_Learning_Unrewarded;
% InBaseline_Legend_Name_All{7}=InBaseline_Legend_Name_Learning_Unrewarded;
% InData_X_Name_All{7}=InData_X_Name_Learning_Unrewarded;
% InBaseline_X_Name_All{7}=InBaseline_X_Name_Learning_Unrewarded;
% InData_Title_All{7}=InData_Title_Learning_Unrewarded;
% InBaseline_Title_All{7}=InBaseline_Title_Learning_Unrewarded;
% InYLim_All{7}=InYLim_Learning_Unrewarded;
% Smooth_Factor_All{7}=Smooth_Factor_Learning_Unrewarded;
% InSaveName_All{7}=InSaveName_Learning_Unrewarded;
% Plot_Colors_All{7}=Plot_Colors_Learning_Unrewarded;

%%
for fidx=1:NumAllFeatures
this_FeatureDimension=All_FeatureDimensions{fidx};
this_FeatureValue=All_FeatureValues{fidx};
this_FeatureField=sprintf('Feature_%d',fidx);

InData_Legend_Name_Feature={'Chosen','Unchosen'};
InBaseline_Legend_Name_Feature={'Chosen','Unchosen'};
InData_X_Name_Feature='Time From Choice Recorded(sec)';
InBaseline_X_Name_Feature='Time From Start of Trial(sec)';
InData_Title_Feature=['Chosen vs Unchosen' sprintf('Dimension:%d Feature:%d',this_FeatureDimension,this_FeatureValue)];
InBaseline_Title_Feature=['Chosen vs Unchosen' sprintf('Dimension:%d Feature:%d',this_FeatureDimension,this_FeatureValue)];
InYLim_Feature=InYLim_Global;
Smooth_Factor_Feature=Smooth_Factor_Global;
InSavePlotCFG_Feature=InSavePlotCFG_Global.Chosen_Feature.(this_FeatureField);
InSaveName_Feature=['Chosen_vs_Unchosen_Decision_Aligned_Channel_%s' sprintf('_Dimension_%d_Feature_%d',this_FeatureDimension,this_FeatureValue)];
InSaveDescriptor_Feature={'Chosen','Unchosen'};
Plot_Colors_Feature={Color_Blue,Color_Red};

InData_Legend_Name_All{fidx+NumCond}=InData_Legend_Name_Feature;
InBaseline_Legend_Name_All{fidx+NumCond}=InBaseline_Legend_Name_Feature;
InData_X_Name_All{fidx+NumCond}=InData_X_Name_Feature;
InBaseline_X_Name_All{fidx+NumCond}=InBaseline_X_Name_Feature;
InData_Title_All{fidx+NumCond}=InData_Title_Feature;
InBaseline_Title_All{fidx+NumCond}=InBaseline_Title_Feature;
InYLim_All{fidx+NumCond}=InYLim_Feature;
Smooth_Factor_All{fidx+NumCond}=Smooth_Factor_Feature;
InSavePlotCFG_All{fidx+NumCond}=InSavePlotCFG_Feature;
InSaveName_All{fidx+NumCond}=InSaveName_Feature;
InSaveDescriptor_All{fidx+NumCond}=InSaveDescriptor_Feature;
Plot_Colors_All{fidx+NumCond}=Plot_Colors_Feature;
end