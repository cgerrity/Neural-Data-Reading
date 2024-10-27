function DataNormalized = cgg_procNormalizeGlobalZScore(Data,NormalizationTable)
%CGG_NORMALIZEGLOBALMINMAX Summary of this function goes here
%   Detailed explanation goes here

[~,NumSamples,~]=size(Data);

Mean_Combined_Function = @(Mean1,Mean2,Count1,Count2) ...
    (1./(Count1+Count2)).*(Mean1.*Count1+Mean2.*Count2);

Var_Combined_Function = @(Mean1,Mean2,Var1,Var2,Count1,Count2) ...
    (1./(Count1+Count2-1)).*(Var1*(Count1-1)+Var2.*(Count2-1))+...
    ((Count1.*Count2.*((Mean1-Mean2).^2)./((Count1+Count2).*(Count1+Count2-1))));

MeanChannels = NormalizationTable{:,"Mean"};
STDChannels = NormalizationTable{:,"STD"};

MeanData = 0;
VarData = 0;
CountData = 0;

for idx = 1:length(MeanChannels)
    this_Mean = MeanChannels(idx);
    this_STD = STDChannels(idx);
    this_Var = this_STD.^2;
    if ~isnan(this_Mean)
    VarData = Var_Combined_Function(MeanData,this_Mean,VarData,this_Var,CountData,NumSamples);
    MeanData = Mean_Combined_Function(MeanData,this_Mean,CountData,NumSamples);
    CountData = CountData + NumSamples;
    end
end

STDData = sqrt(VarData);

DataNormalized = (Data-MeanData)./(STDData);

end

