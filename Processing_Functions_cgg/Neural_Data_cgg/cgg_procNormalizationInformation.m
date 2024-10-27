function cgg_procNormalizationInformation(Epoch)
%CGG_PROCSESSIONNORMALIZATION Summary of this function goes here
%   Detailed explanation goes here

cfg_Session = DATA_cggAllSessionInformationConfiguration;

outdatadir=cfg_Session(1).outdatadir;
TargetDir=outdatadir;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,'Epoch',Epoch,'NormalizationInformation',true);

DataDir = cgg_getDirectory(cfg,'Data');
TargetAggregateDir = cgg_getDirectory(cfg,'Target');
NormalizationInformationDir = ...
    cgg_getDirectory(cfg,'NormalizationInformation');

%%

NormalizationInformationPathNameExt = [NormalizationInformationDir filesep 'NormalizationInformation.mat'];
DataHistogramPathNameExt = [NormalizationInformationDir filesep 'DataHistogram.mat'];

if isfile(NormalizationInformationPathNameExt)
    m_NormalizationInformation=matfile(NormalizationInformationPathNameExt,"Writable",true);
    NormalizationInformation=m_NormalizationInformation.NormalizationInformation;
else
    NormalizationInformation = struct();
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
NormalizationVariables = [["Mean", "double"]; ...
		["STD", "double"]; ...
		["Max", "double"]; ...
		["Min", "double"]; ...
        ["Area", "double"]; ...
        ["Channel", "double"]; ...
        ["Session", "string"]];

NumVariables = size(NormalizationVariables,1);

%%

DataWidth='All';
WindowStride=50;

ChannelRemoval=[];
WantDisp=false;
WantRandomize=false;
WantNaNZeroed=false;
Want1DVector=false;
StartingIDX=1;
EndingIDX=1;

Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector);
Data_ds = fileDatastore(DataDir,"ReadFcn",Data_Fun);

TargetSession_Fun=@(x) cgg_loadTargetArray(x,'SessionName',true);
SessionNameDataStore = fileDatastore(TargetAggregateDir,"ReadFcn",TargetSession_Fun);

%%
SessionsList=gather(tall(SessionNameDataStore));

SessionNames=unique(SessionsList);
NumSessions=length(SessionNames);

DataHistogram_Cell = cell(1,NumSessions);
NormalizationTable_Cell = cell(1,NumSessions);

%%

NormalizationVariables_Parallel = parallel.pool.Constant(NormalizationVariables);

parfor seidx = 1:NumSessions

    this_SessionName = SessionNames{seidx};
    this_SessionIDX = strcmp(SessionsList,SessionNames{seidx});

    this_DataStore = subset(Data_ds,this_SessionIDX);

[NumChannels,~,NumAreas]=size(preview(this_DataStore));
NumTrials=numpartitions(this_DataStore);
reset(this_DataStore);

Data_Mean=zeros(NumChannels,1,NumAreas);
Data_Var=zeros(NumChannels,1,NumAreas);
Data_Max=-Inf(NumChannels,1,NumAreas);
Data_Min=Inf(NumChannels,1,NumAreas);

HistCounts = zeros(1, length(BinEdges) - 1);

TotalCount = 0;

Mean_Combined_Function = @(Mean1,Mean2,Count1,Count2) ...
    (1./(Count1+Count2)).*(Mean1.*Count1+Mean2.*Count2);

Var_Combined_Function = @(Mean1,Mean2,Var1,Var2,Count1,Count2) ...
    (1./(Count1+Count2-1)).*(Var1*(Count1-1)+Var2.*(Count2-1))+...
    ((Count1.*Count2.*((Mean1-Mean2).^2)./((Count1+Count2).*(Count1+Count2-1))));

for tidx = 1:NumTrials
    this_Data = read(this_DataStore);
    % this_Data = Data{tidx};

    this_Count = size(this_Data,2);
    
    this_Data_Mean=mean(this_Data,2,"omitnan");
    this_Data_Var=var(this_Data,[],2,"omitnan");
    this_Data_Max=max(this_Data,[],2,"omitnan");
    this_Data_Min=min(this_Data,[],2,"omitnan");

    this_HistCounts = histcounts(this_Data, BinEdges);

    Data_Mean = Mean_Combined_Function(Data_Mean,this_Data_Mean,TotalCount,this_Count);
    Data_Var = Var_Combined_Function(Data_Mean,this_Data_Mean,Data_Var,this_Data_Var,TotalCount,this_Count);
    Data_Max = max([Data_Max,this_Data_Max],[],2,"omitnan");
    Data_Min = min([Data_Min,this_Data_Min],[],2,"omitnan");

    HistCounts = HistCounts + this_HistCounts;

    TotalCount = TotalCount + this_Count;

end

Data_STD = sqrt(Data_Var);
DataHistogram_Cell{seidx} = HistCounts;

%% Normalization Table

this_NormalizationVariables = NormalizationVariables_Parallel.Value;

NormalizationTable = table('Size',[0,NumVariables],... 
	    'VariableNames', this_NormalizationVariables(:,1),...
	    'VariableTypes', this_NormalizationVariables(:,2));

NormalizationTableIDX = 0;
for aidx = 1:NumAreas
    for cidx = 1:NumChannels
        NormalizationTableIDX = NormalizationTableIDX + 1;
        this_Data = cell(1,NumVariables);
        DataIDX = 1;
        this_Data{DataIDX} = Data_Mean(cidx,1,aidx); DataIDX = DataIDX + 1;
        this_Data{DataIDX} = Data_STD(cidx,1,aidx); DataIDX = DataIDX + 1;
        this_Data{DataIDX} = Data_Max(cidx,1,aidx); DataIDX = DataIDX + 1;
        this_Data{DataIDX} = Data_Min(cidx,1,aidx); DataIDX = DataIDX + 1;
        this_Data{DataIDX} = aidx; DataIDX = DataIDX + 1;
        this_Data{DataIDX} = cidx; DataIDX = DataIDX + 1;
        this_Data{DataIDX} = this_SessionName;

        NormalizationTable(NormalizationTableIDX,:) = this_Data;
    end
end

NormalizationTable_Cell{seidx} = NormalizationTable;

end
%%
for seidx = 1:NumSessions
    this_SessionName = SessionNames{seidx};

DataHistogram.(this_SessionName) = DataHistogram_Cell{seidx};
NormalizationInformation.(this_SessionName) = NormalizationTable_Cell{seidx};
end

%%

NormalizationInformationSaveVariables={NormalizationInformation};
NormalizationInformationSaveVariablesName={'NormalizationInformation'};
cgg_saveVariableUsingMatfile(NormalizationInformationSaveVariables,NormalizationInformationSaveVariablesName,NormalizationInformationPathNameExt);

DataHistogramSaveVariables={DataHistogram};
DataHistogramSaveVariablesName={'DataHistogram'};
cgg_saveVariableUsingMatfile(DataHistogramSaveVariables,DataHistogramSaveVariablesName,DataHistogramPathNameExt);

end

