function DataNormalized = cgg_procNormalizeAreaZScore(Data,NormalizationTable)
%CGG_PROCNORMALIZEAREAMINMAX Summary of this function goes here
%   Detailed explanation goes here

[NumChannels,NumSamples,NumProbes]=size(Data);

Mean_Combined_Function = @(Mean1,Mean2,Count1,Count2) ...
    (1./(Count1+Count2)).*(Mean1.*Count1+Mean2.*Count2);

Var_Combined_Function = @(Mean1,Mean2,Var1,Var2,Count1,Count2) ...
    (1./(Count1+Count2-1)).*(Var1*(Count1-1)+Var2.*(Count2-1))+...
    ((Count1.*Count2.*((Mean1-Mean2).^2)./((Count1+Count2).*(Count1+Count2-1))));

MeanAreas = NaN(1,1,NumProbes);
VarsAreas = NaN(1,1,NumProbes);
AreaIDX = unique(NormalizationTable{:,"Area"});

for aidx = 1:length(AreaIDX)
    this_AreaIDX = NormalizationTable{:,"Area"} == AreaIDX(aidx);
    this_Means = NormalizationTable{this_AreaIDX,"Mean"};
    this_STDs = NormalizationTable{this_AreaIDX,"STD"};
    this_Vars = this_STDs.^2;
    this_MeansArea = 0;
    this_VarsArea = 0;
    this_AreaCount = 0;
    for cidx = 1:length(this_Means)
        if ~isnan(this_Means(cidx))
    this_VarsArea = Var_Combined_Function(this_MeansArea,this_Means(cidx),this_VarsArea,this_Vars(cidx),this_AreaCount,NumSamples);
    this_MeansArea = Mean_Combined_Function(this_MeansArea,this_Means(cidx),this_AreaCount,NumSamples);
    this_AreaCount = this_AreaCount + NumSamples;
        end
    end
MeanAreas(aidx) = this_MeansArea;
VarsAreas(aidx) = this_VarsArea;
end

STDAreas = sqrt(VarsAreas);

MeanData = NaN(1,1,NumProbes);
STDData = NaN(1,1,NumProbes);

IDX = sub2ind([1,1,NumProbes],AreaIDX);

MeanData(IDX) = MeanAreas;
STDData(IDX) = STDAreas;

MeanFull = repmat(MeanData,[NumChannels,NumSamples,1]);
STDFull = repmat(STDData,[NumChannels,NumSamples,1]);

DataNormalized = (Data-MeanFull)./(STDFull);

end

