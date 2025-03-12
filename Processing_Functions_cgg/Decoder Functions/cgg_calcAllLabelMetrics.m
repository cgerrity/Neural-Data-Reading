function LabelMetrics = cgg_calcAllLabelMetrics(FullClassCM)
%CGG_CALCALLLABELMETRICS Summary of this function goes here
%   Detailed explanation goes here

[~,NumDimension]=size(FullClassCM);

Global_TP=0;
Global_TN=0;
Global_FP=0;
Global_FN=0;

MacroDimensionAccuracy=NaN(NumDimension,1);
MacroDimensionPrecision=NaN(NumDimension,1);
MacroDimensionRecall=NaN(NumDimension,1);
MacroDimensionSpecificity=NaN(NumDimension,1);
MacroDimensionF1=NaN(NumDimension,1);
MacroDimensionBalancedAccuracy=NaN(NumDimension,1);

MacroDimensionTotalAccuracy=NaN(NumDimension,1);

IsValidCM = true;
IsValidDimension = true(NumDimension,1);
%%
for didx=1:NumDimension
    DimensionCM=FullClassCM{1,didx}{1};
    [NumClasses,~]=size(DimensionCM);

    MacroClassAccuracy=NaN(NumClasses,1);
    MacroClassPrecision=NaN(NumClasses,1);
    MacroClassRecall=NaN(NumClasses,1);
    MacroClassSpecificity=NaN(NumClasses,1);
    MacroClassF1=NaN(NumClasses,1);
    MacroClassBalancedAccuracy=NaN(NumClasses,1);

    MacroClassTP=NaN(NumClasses,1);
    MacroClassTN=NaN(NumClasses,1);
    MacroClassFP=NaN(NumClasses,1);
    MacroClassFN=NaN(NumClasses,1);
%%
    for cidx=1:NumClasses
        ClassCM=DimensionCM(cidx,:);
        ClassName=ClassCM.Properties.RowNames{1};
        
        TP=ClassCM.TP;
        TN=ClassCM.TN;
        FP=ClassCM.FP;
        FN=ClassCM.FN;

        if TP+TN+FP+FN < 1
            IsValidCM = false;
            IsValidDimension(didx) = false;
        end

        IsPresent = true;
        if TP+FN == 0
            IsPresent = false;
        end

        ClassAccuracy=(TP+TN)/(TP+TN+FP+FN);
        ClassPrecision=(TP)/(TP+FP);
        ClassRecall=(TP)/(TP+FN);
        ClassSpecificity=(TN)/(TN+FP);
        ClassF1=2*(ClassPrecision*ClassRecall)/...
            (ClassPrecision+ClassRecall);
        % ClassBalancedAccuracy=0.5*(ClassRecall+ClassSpecificity);
        ClassBalancedAccuracy=ClassRecall;

        if ~IsPresent
            ClassPrecision = NaN;
            ClassRecall = NaN;
            ClassF1 = NaN;
            ClassBalancedAccuracy = NaN;
        end

        Global_TP=Global_TP+TP;
        Global_TN=Global_TN+TN;
        Global_FP=Global_FP+FP;
        Global_FN=Global_FN+FN;

%        if isnan(ClassPrecision) && IsValidCM
%        ClassPrecision = 0;
%        end
%        if isnan(ClassRecall) && IsValidCM
%        ClassRecall = 0;
%        end
%        if isnan(ClassF1) && IsValidCM
%        ClassF1 = 0;
%        end

        MacroClassAccuracy(cidx)=ClassAccuracy;
        MacroClassPrecision(cidx)=ClassPrecision;
        MacroClassRecall(cidx)=ClassRecall;
        MacroClassSpecificity(cidx)=ClassSpecificity;
        MacroClassF1(cidx)=ClassF1;
        MacroClassBalancedAccuracy(cidx)=ClassBalancedAccuracy;

        MacroClassTP(cidx)=TP;
        MacroClassTN(cidx)=TN;
        MacroClassFP(cidx)=FP;
        MacroClassFN(cidx)=FN;

        MacroClassTotal=TP+TN+FP+FN;
    end

    %%

    MacroDimensionTotalAccuracy(didx)=sum(MacroClassTP)/MacroClassTotal;

    MacroDimensionAccuracy(didx)=mean(MacroClassAccuracy,"omitnan");
    MacroDimensionPrecision(didx)=mean(MacroClassPrecision,"omitnan");
    MacroDimensionRecall(didx)=mean(MacroClassRecall,"omitnan");
    MacroDimensionSpecificity(didx)=mean(MacroClassSpecificity,"omitnan");
    % MacroDimensionAccuracy(didx)=mean(MacroClassAccuracy);
    % MacroDimensionPrecision(didx)=mean(MacroClassPrecision);
    % MacroDimensionRecall(didx)=mean(MacroClassRecall);
    % MacroDimensionSpecificity(didx)=mean(MacroClassSpecificity);
    MacroDimensionF1(didx)=mean(MacroClassF1,"omitnan");
    MacroDimensionBalancedAccuracy(didx)=mean(MacroClassBalancedAccuracy,"omitnan");

end

MicroAccuracy=(Global_TP+Global_TN)/(Global_TP+Global_TN+Global_FP+Global_FN);
MicroPrecision=(Global_TP)/(Global_TP+Global_FP);
MicroRecall=(Global_TP)/(Global_TP+Global_FN);
MicroF1=2*(MicroPrecision*MicroRecall)/(MicroPrecision+MicroRecall);

MacroTotalAccuracy=mean(MacroDimensionTotalAccuracy);

MacroAccuracy=mean(MacroDimensionAccuracy);
MacroPrecision=mean(MacroDimensionPrecision);
MacroRecall=mean(MacroDimensionRecall);
MacroSpecificity=mean(MacroDimensionSpecificity);
MacroF1=mean(MacroDimensionF1);
MacroBalancedAccuracy=mean(MacroDimensionBalancedAccuracy);

%% Fix catastrophic predictions

if isnan(MacroTotalAccuracy) && IsValidCM
    MacroTotalAccuracy = 0;
else
    MacroTotalAccuracy=mean(MacroDimensionTotalAccuracy,"all","omitmissing");
end

if isnan(MacroAccuracy) && IsValidCM
    MacroAccuracy = 0;
else
    MacroAccuracy=mean(MacroDimensionAccuracy,"all","omitmissing");
end

if isnan(MacroPrecision) && IsValidCM
    MacroPrecision = 0;
else
    MacroPrecision=mean(MacroDimensionPrecision,"all","omitmissing");
end

if isnan(MacroRecall) && IsValidCM
    MacroRecall = 0;
else
    MacroRecall=mean(MacroDimensionRecall,"all","omitmissing");
end

if isnan(MacroSpecificity) && IsValidCM
    MacroSpecificity = 0;
else
    MacroSpecificity=mean(MacroDimensionSpecificity,"all","omitmissing");
end

if isnan(MacroF1) && IsValidCM
    MacroF1 = 0;
else
    MacroF1=mean(MacroDimensionF1,"all","omitmissing");
end

if isnan(MacroBalancedAccuracy) && IsValidCM
    MacroBalancedAccuracy = 0;
else
    MacroBalancedAccuracy=mean(MacroDimensionBalancedAccuracy,"all","omitmissing");
end

%%

LabelMetrics=struct();

LabelMetrics.MicroAccuracy=MicroAccuracy;
LabelMetrics.MicroPrecision=MicroPrecision;
LabelMetrics.MicroRecall=MicroRecall;
LabelMetrics.MicroF1=MicroF1;

LabelMetrics.MacroAccuracy=MacroAccuracy;
LabelMetrics.MacroPrecision=MacroPrecision;
LabelMetrics.MacroRecall=MacroRecall;
LabelMetrics.MacroSpecificity=MacroSpecificity;
LabelMetrics.MacroF1=MacroF1;
LabelMetrics.MacroBalancedAccuracy=MacroBalancedAccuracy;

LabelMetrics.MacroTotalAccuracy=MacroTotalAccuracy;

end

