function [P_Value,R_Value,P_Value_Coefficients,CoefficientNames] = cgg_procTrialVariableRegression(InData,MatchArray,InIncrement)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


this_FitaData=InData;

[NumChannels,NumSamplesData,~]=size(this_FitaData);

[~,NumMatchArray]=size(MatchArray);

Regress_Period=1;
Increment_Amount=InIncrement;
Increment_Values=1:Increment_Amount:NumSamplesData;
NumIncrements=length(Increment_Values);
%%
P_Value=NaN(NumChannels,NumIncrements,1);
R_Value=NaN(NumChannels,NumIncrements,1);
P_Value_Coefficients=NaN(NumChannels,NumIncrements,NumMatchArray+1);
% P_Value_Coefficients=NaN(NumChannels,NumIncrements,NumMatchArray+2);
%% Update Information Setup

q = parallel.pool.DataQueue;
afterEach(q, @nUpdateWaitbar);

All_Iterations = NumIncrements*NumChannels;
Iteration_Count = 0;

formatSpec = '*** Current Trial Variable Regression Progress is: %.2f%%%%\n';
Current_Message=sprintf(formatSpec,0);
% disp(Current_Message);
fprintf(Current_Message);

%%

parfor sidx=1:NumIncrements
    
    this_sidx=Increment_Values(sidx);
    
this_DataSection_Start=this_sidx-floor(Regress_Period/2);
this_DataSection_End=this_sidx+floor(Regress_Period/2)-(rem(Regress_Period, 2) == 0);

if this_DataSection_Start<1
    this_DataSection_Start=1;
end
if this_DataSection_End>NumSamplesData
    this_DataSection_End=NumSamplesData;
end

this_DataSection=this_DataSection_Start:this_DataSection_End;

FitData_sel=this_FitaData(:,this_DataSection,:);

FitData_sel=mean(FitData_sel,2);

FitData_sel=squeeze(FitData_sel);

for cidx=1:NumChannels

this_Channel=cidx;

FitData_sel_channel=diag(diag(FitData_sel(this_Channel,:)));

mdl = fitlm(MatchArray,FitData_sel_channel,'CategoricalVars',1:NumMatchArray);

mdl_summary=anova(mdl,'summary');

P_Value_Coefficients(cidx,sidx,:)=mdl.Coefficients.pValue;

P_Value(cidx,sidx)=mdl_summary.pValue(2);

R_Value(cidx,sidx)=mdl.Rsquared.Ordinary;

send(q, sidx);
end

end

Data_tmp=this_FitaData(:,1,:);
Data_tmp=mean(Data_tmp,2);
Data_tmp=squeeze(Data_tmp);
Data_tmp=diag(diag(Data_tmp(1,:)));
mdl = fitlm(MatchArray,Data_tmp,'CategoricalVars',1:NumMatchArray);
CoefficientNames=mdl.CoefficientNames;

function nUpdateWaitbar(~)
    Iteration_Count = Iteration_Count + 1;
    Current_Progress=Iteration_Count/All_Iterations*100;
%     Delete_Message=repmat('\b',1,length(Current_Message)+1);
    Delete_Message=repmat(sprintf('\b'),1,length(Current_Message)-1);
%     fprintf(Delete_Message);
    Current_Message=sprintf(formatSpec,Current_Progress);
%     disp(Current_Message);
    fprintf([Delete_Message,Current_Message]);
end


end

