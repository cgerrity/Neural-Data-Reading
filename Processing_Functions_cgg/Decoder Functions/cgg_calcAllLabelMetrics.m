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
MacroDimensionF1=NaN(NumDimension,1);

MacroDimensionTotalAccuracy=NaN(NumDimension,1);

for didx=1:NumDimension
    DimensionCM=FullClassCM{1,didx}{1};
    [NumClasses,~]=size(DimensionCM);

    MacroClassAccuracy=NaN(NumClasses,1);
    MacroClassPrecision=NaN(NumClasses,1);
    MacroClassRecall=NaN(NumClasses,1);
    MacroClassF1=NaN(NumClasses,1);

    MacroClassTP=NaN(NumClasses,1);
    MacroClassTN=NaN(NumClasses,1);
    MacroClassFP=NaN(NumClasses,1);
    MacroClassFN=NaN(NumClasses,1);

    for cidx=1:NumClasses
        ClassCM=DimensionCM(cidx,:);
        ClassName=ClassCM.Properties.RowNames{1};
        
        TP=ClassCM.TP;
        TN=ClassCM.TN;
        FP=ClassCM.FP;
        FN=ClassCM.FN;

        ClassAccuracy=(TP+TN)/(TP+TN+FP+FN);
        ClassPrecision=(TP)/(TP+FP);
        ClassRecall=(TP)/(TP+FN);
        ClassF1=2*(ClassPrecision*ClassRecall)/...
            (ClassPrecision+ClassRecall);

        Global_TP=Global_TP+TP;
        Global_TN=Global_TN+TN;
        Global_FP=Global_FP+FP;
        Global_FN=Global_FN+FN;

        MacroClassAccuracy(cidx)=ClassAccuracy;
        MacroClassPrecision(cidx)=ClassPrecision;
        MacroClassRecall(cidx)=ClassRecall;
        MacroClassF1(cidx)=ClassF1;

        MacroClassTP(cidx)=TP;
        MacroClassTN(cidx)=TN;
        MacroClassFP(cidx)=FP;
        MacroClassFN(cidx)=FN;

        MacroClassTotal=TP+TN+FP+FN;
    end

    MacroDimensionTotalAccuracy(didx)=sum(MacroClassTP)/MacroClassTotal;

    MacroDimensionAccuracy(didx)=mean(MacroClassAccuracy);
    MacroDimensionPrecision(didx)=mean(MacroClassPrecision);
    MacroDimensionRecall(didx)=mean(MacroClassRecall);
    MacroDimensionF1(didx)=mean(MacroClassF1);

end

MicroAccuracy=(Global_TP+Global_TN)/(Global_TP+Global_TN+Global_FP+Global_FN);
MicroPrecision=(Global_TP)/(Global_TP+Global_FP);
MicroRecall=(Global_TP)/(Global_TP+Global_FN);
MicroF1=2*(MicroPrecision*MicroRecall)/(MicroPrecision+MicroRecall);

MacroTotalAccuracy=mean(MacroDimensionTotalAccuracy);

MacroAccuracy=mean(MacroDimensionAccuracy);
MacroPrecision=mean(MacroDimensionPrecision);
MacroRecall=mean(MacroDimensionRecall);
MacroF1=mean(MacroDimensionF1);

%%

LabelMetrics=struct();

LabelMetrics.MicroAccuracy=MicroAccuracy;
LabelMetrics.MicroPrecision=MicroPrecision;
LabelMetrics.MicroRecall=MicroRecall;
LabelMetrics.MicroF1=MicroF1;

LabelMetrics.MacroAccuracy=MacroAccuracy;
LabelMetrics.MacroPrecision=MacroPrecision;
LabelMetrics.MacroRecall=MacroRecall;
LabelMetrics.MacroF1=MacroF1;

LabelMetrics.MacroTotalAccuracy=MacroTotalAccuracy;

end

