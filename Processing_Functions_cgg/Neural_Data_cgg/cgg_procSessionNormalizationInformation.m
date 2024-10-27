function cgg_procSessionNormalizationInformation(Epoch,inputfolder,outdatadir,SessionName)
%CGG_PROCSESSIONNORMALIZATION Summary of this function goes here
%   Detailed explanation goes here

[cfg_epoch] = cgg_generateEpochFolders(Epoch,'inputfolder',inputfolder,'outdatadir',outdatadir,'NormalizationInformation',true);

DataDir = cgg_getDirectory(cfg_epoch,'Data');
NormalizationInformationDir = ...
    cgg_getDirectory(cfg_epoch,'NormalizationInformation');

%%

NormalizationTablePathNameExt = [NormalizationInformationDir filesep 'NormalizationTable.mat'];
DataHistogramPathNameExt = [NormalizationInformationDir filesep 'DataHistogram.mat'];

if isfile(NormalizationTablePathNameExt)
    m_NormalizationTable=matfile(NormalizationTablePathNameExt,"Writable",true);
    NormalizationTable=m_NormalizationTable.NormalizationTable;
else
    NormalizationVariables = [["Mean", "double"]; ...
			["STD", "double"]; ...
			["Max", "double"]; ...
			["Min", "double"]; ...
            ["Area", "double"]; ...
            ["Channel", "double"]; ...
            ["Session", "string"]];
    NormalizationTable = table('Size',[0,size(NormalizationVariables,1)],... 
	    'VariableNames', NormalizationVariables(:,1),...
	    'VariableTypes', NormalizationVariables(:,2));
end
if isfile(DataHistogramPathNameExt)
    m_DataHistogram=matfile(DataHistogramPathNameExt,"Writable",true);
    DataHistogram=m_DataHistogram.DataHistogram;
    BinEdges=DataHistogram.BinEdges;
else
    DataHistogram = struct();
    BinEdgeStart = -10;
    BinEdgeEnd = 10;
    NumBins = 1000;
    BinEdges = linspace(BinEdgeStart, BinEdgeEnd, NumBins);
    DataHistogram.BinEdges = BinEdges;
end


%%

DataWidth='All';
WindowStride=50;

ChannelRemoval=[];
WantDisp=false;
WantRandomize=false;
WantNaNZeroed=true;
Want1DVector=false;
StartingIDX=1;
EndingIDX=1;

Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector);
Data_ds = fileDatastore(DataDir,"ReadFcn",Data_Fun);

%%
[NumChannels,~,NumAreas]=size(preview(Data_ds));
NumTrials=numpartitions(Data_ds);
reset(Data_ds);

Data_Mean=zeros(NumChannels,1,NumAreas);
Data_Var=zeros(NumChannels,1,NumAreas);
Data_Max=-Inf(NumChannels,1,NumAreas);
Data_Min=Inf(NumChannels,1,NumAreas);
Data_Median=NaN(NumChannels,1,NumAreas);

HistCounts = zeros(1, length(BinEdges) - 1);

TotalCount = 0;

Mean_Combined_Function = @(Mean1,Mean2,Count1,Count2) ...
    (1./(Count1+Count2)).*(Mean1.*Count1+Mean2.*Count2);

Var_Combined_Function = @(Mean1,Mean2,Var1,Var2,Count1,Count2) ...
    (1./(Count1+Count2-1)).*(Var1*(Count1-1)+Var2.*(Count2-1))+...
    ((Count1.*Count2.*((Mean1-Mean2).^2)./((Count1+Count2).*(Count1+Count2-1))));

for tidx = 1:NumTrials
    this_Data = read(Data_ds);
    % this_Data = Data{tidx};

    this_Count = size(this_Data,2);
    
    this_Data_Mean=mean(this_Data,2);
    this_Data_Var=var(this_Data,[],2);
    this_Data_Max=max(this_Data,[],2);
    this_Data_Min=min(this_Data,[],2);

    this_HistCounts = histcounts(this_Data, BinEdges);

    Data_Mean = Mean_Combined_Function(Data_Mean,this_Data_Mean,TotalCount,this_Count);
    Data_Var = Var_Combined_Function(Data_Mean,this_Data_Mean,Data_Var,this_Data_Var,TotalCount,this_Count);
    Data_Max = max([Data_Max,this_Data_Max],[],2);
    Data_Min = min([Data_Min,this_Data_Min],[],2);

    HistCounts = HistCounts + this_HistCounts;

    TotalCount = TotalCount + this_Count;

end

Data_STD = sqrt(Data_Var);
DataHistogram.(SessionName) = HistCounts;

%% Normalization Table

NumVariables = size(NormalizationTable,2);

NormalizationTableIDX = 0;
for aidx = 1:NumAreas
    for cidx = 1:NumChannels
        NormalizationTableIDX = NormalizationTableIDX + 1;
        this_Data = cell(1,NumVariables);
        this_Data{1} = Data_Mean(cidx,1,aidx);
        this_Data{2} = Data_STD(cidx,1,aidx);
        this_Data{3} = Data_Max(cidx,1,aidx);
        this_Data{4} = Data_Min(cidx,1,aidx);
        this_Data{5} = Data_Median(cidx,1,aidx);
        this_Data{6} = aidx;
        this_Data{7} = cidx;
        this_Data{8} = SessionName;

        NormalizationTable(NormalizationTableIDX,:) = this_Data;
    end
end

%%

NormalizationTableSaveVariables={NormalizationTable};
NormalizationTableSaveVariablesName={'NormalizationTable'};
cgg_saveVariableUsingMatfile(NormalizationTableSaveVariables,NormalizationTableSaveVariablesName,NormalizationTablePathNameExt);

DataHistogramSaveVariables={DataHistogram};
DataHistogramSaveVariablesName={'DataHistogram'};
cgg_saveVariableUsingMatfile(DataHistogramSaveVariables,DataHistogramSaveVariablesName,DataHistogramPathNameExt);

end

