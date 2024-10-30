function [InputTable,CoefficientNames,PlotTable] = cgg_procRegressionResultsFromProcessing(Epoch,varargin)
%CGG_PROCREGRESSIONRESULTSFROMPROCESSING Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
WantPlot = CheckVararginPairs('WantPlot', false, varargin{:});
else
if ~(exist('WantPlot','var'))
WantPlot=false;
end
end

if isfunction
wantPaperSized = CheckVararginPairs('wantPaperSized', true, varargin{:});
else
if ~(exist('wantPaperSized','var'))
wantPaperSized=true;
end
end

if isfunction
WantBonferroni = CheckVararginPairs('WantBonferroni', false, varargin{:});
else
if ~(exist('WantBonferroni','var'))
WantBonferroni=false;
end
end

%%
AreaNameCheck={'ACC','PFC','CD'};
PlottingSubFolders = {'Combined','Single'};

%%

[~,outputfolder_base,temporaryfolder_base,~] = cgg_getBaseFolders();

MainDir=[outputfolder_base filesep 'Data_Neural'];
ResultsDir=[temporaryfolder_base filesep 'Data_Neural'];

% RemovedChannelsDir = [MainDir filesep 'Variables' filesep 'Summary'];

% BadChannelsPathNameExt = [RemovedChannelsDir filesep 'BadChannels.mat'];
% NotSignificantChannelsPathNameExt = [RemovedChannelsDir filesep ...
%     'NotSignificantChannels.mat'];

% BadChannels = load(BadChannelsPathNameExt);
% NotSignificantChannels = load(NotSignificantChannelsPathNameExt);
% 
% CommonRemovedChannels = [BadChannels.CommonDisconnectedChannels, ...
%     NotSignificantChannels.CommonNotSignificant];

%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Processing','PlotSubFolder',PlottingSubFolders);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

PlotPath=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_2.path;

[cfg_PlotData, ~] = cgg_generateSessionAggregationFolders( ...
    'TargetDir',MainDir,'Folder','Variables','SubFolder','Regression');

PlotDatacfg=cfg_PlotData.TargetDir.Aggregate_Data.Folder.SubFolder;


% cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',Epoch,'PlotFolder','Processing','PlotSubFolder',PlottingSubFolders);
% cfg_Save.ResultsDir=cfg_Results.TargetDir;
% 
% [cfg_Target] = cgg_generateSessionAggregationFolders('TargetDir',MainDir,...
%     'Folder','Variables','SubFolder','Regression');
% 
% [cfg_PlotData, ~] = cgg_generateSessionAggregationFolders('TargetDir',MainDir);
% 
% cfg_Save.ResultsDir=cfg_Results.TargetDir;
% 
% PlotDatacfg=cfg_PlotData.TargetDir.Aggregate_Data.Plots;

%%
[cfg_Session] = DATA_cggAllSessionInformationConfiguration;
% SessionsName={cfg_Session.SessionName}';
SessionsName_Hyphen={cfg_Session.SessionName}';
% SessionsName=replace(SessionsName,'-','_');

NumSessions=length(cfg_Session);

%%

if WantPlot
if wantPaperSized
InFigure=figure;
InFigure.Units="inches";
InFigure.Position=[0,0,3,3];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
clf(InFigure);
else
InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
% InFigure.Visible='off';
clf(InFigure);
end
end

InputTable=cell(1,length(AreaNameCheck));

%%

for sidx=1:NumSessions

% this_SessionName=SessionsName{sidx};
this_SessionName_Hyphen=SessionsName_Hyphen{sidx};

InSavePathNameExt=[PlotDatacfg.path filesep this_SessionName_Hyphen '-Regression_Results_%s' '.mat'];

[AreaNames,~] = PARAMETERS_cgg_getSessionProbeInformation(this_SessionName_Hyphen);
%%

for aidx=1:length(AreaNames)
    this_AreaName=AreaNames{aidx};
    this_PlotDataPathNameExt=sprintf(InSavePathNameExt,this_AreaName);

    %%
    if WantPlot
        cgg_plotSignificantProcessingPerProbe(this_PlotDataPathNameExt,'PlotPath',PlotPath,'InFigure',InFigure,'Epoch',Epoch);
    end

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % [InputTable{acidx},this_CoefficientNames] = cgg_getAreaRegressionValues(this_InputTable,this_PlotDataPathNameExt,this_AreaNameCheck,'CommonRemovedChannels',CommonRemovedChannels);
        [InputTable{acidx},this_CoefficientNames] = cgg_getAreaRegressionValues(this_InputTable,this_PlotDataPathNameExt,this_AreaNameCheck);
        if ~isempty(this_CoefficientNames)
            CoefficientNames = this_CoefficientNames;
        end
    end
end % End Loop through areas

end % End Loop through Sessions


%%

TableVariables = [["PlotData", "cell"]; ...
    ["Area", "string"]; ...
    ["Monkey", "string"]; ...
    ["Model_Variable", "string"]];

NumVariables = size(TableVariables,1);
PlotTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

PlotTableIDX = 0;


cfg_Parameters = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);
Significance_Value = cfg_Parameters.Significance_Value;
Coefficient_Names = cfg_Parameters.Regression_Names;
%%
for aidx = 1:length(InputTable)
    %%
    this_InputTable=InputTable{aidx};
    this_AreaName = AreaNameCheck{aidx};
    CriteriaArray = this_InputTable.CriteriaArray;
    P_Value_Coefficients = this_InputTable.P_Value_Coefficients;
    % P_Value = this_InputTable.P_Value;
NaNValues = isnan(CriteriaArray);
NumNotNaNValues = sum(~NaNValues,"all");
%%
% P_Value = m_PlotData.P_Value;
% P_Value(NaNValues) = NaN;
this_Significance_Value = Significance_Value;
if WantBonferroni
this_Significance_Value = Significance_Value/NumNotNaNValues;
end
CriteriaCoefficients = P_Value_Coefficients < this_Significance_Value;
CriteriaCoefficients = double(CriteriaCoefficients);
for vidx = 1:size(CriteriaCoefficients,3)
    this_CriteriaCoefficients = CriteriaCoefficients(:,:,vidx);
    this_CriteriaCoefficients(NaNValues) = NaN;
    CriteriaCoefficients(:,:,vidx) = this_CriteriaCoefficients;
end

%%

[NumChannels,~] = size(CriteriaArray);

[Model,Model_STD,Model_STE,Model_CI] = ...
    cgg_getMeanSTDSeries(CriteriaArray,'NumCollapseDimension',NumChannels);

this_PlotData = struct();
this_PlotData.ProportionAll = Model;
this_PlotData.All_STD = Model_STD;
this_PlotData.All_STE = Model_STE;
this_PlotData.All_CI = Model_CI;

%%

PlotTableIDX = PlotTableIDX + 1;
PlotTable(PlotTableIDX,:) = ...
    {{this_PlotData},this_AreaName,"All",'Model'};

%%

NumCoefficients = size(CriteriaCoefficients,3);
for cidx = 1:NumCoefficients
VariableName = char(Coefficient_Names(cidx));

this_CriteriaCoefficients = CriteriaCoefficients(:,:,cidx);
[NumChannels,~] = size(this_CriteriaCoefficients);

[Coefficient,Coefficient_STD,Coefficient_STE,Coefficient_CI] = ...
    cgg_getMeanSTDSeries(this_CriteriaCoefficients,'NumCollapseDimension',NumChannels);


this_PlotData = struct();
this_PlotData.ProportionAll = Coefficient;
this_PlotData.All_STD = Coefficient_STD;
this_PlotData.All_STE = Coefficient_STE;
this_PlotData.All_CI = Coefficient_CI;

PlotTableIDX = PlotTableIDX + 1;
PlotTable(PlotTableIDX,:) = ...
    {{this_PlotData},this_AreaName,"All",VariableName};

end

%%
[MonkeyNamesIDX,MonkeyNames] = findgroups(this_InputTable.MonkeyName);

for midx = 1:length(MonkeyNames)
this_CriteriaArray = CriteriaArray(MonkeyNamesIDX == midx, :);
CriteriaCoefficients_Monkey = CriteriaCoefficients(MonkeyNamesIDX == midx, :,:);

[NumChannels,~] = size(this_CriteriaArray);

[Model,Model_STD,Model_STE,Model_CI] = ...
    cgg_getMeanSTDSeries(CriteriaArray,'NumCollapseDimension',NumChannels);

this_PlotData = struct();
this_PlotData.ProportionAll = Model;
this_PlotData.All_STD = Model_STD;
this_PlotData.All_STE = Model_STE;
this_PlotData.All_CI = Model_CI;

PlotTableIDX = PlotTableIDX + 1;
PlotTable(PlotTableIDX,:) = ...
    {{this_PlotData},this_AreaName,MonkeyNames(midx),'Model'};

%%

NumCoefficients = size(CriteriaCoefficients_Monkey,3);
for cidx = 1:NumCoefficients
VariableName = char(Coefficient_Names(cidx));

this_CriteriaCoefficients_Monkey = CriteriaCoefficients_Monkey(:,:,cidx);
[NumChannels,~] = size(this_CriteriaCoefficients_Monkey);

[Coefficient,Coefficient_STD,Coefficient_STE,Coefficient_CI] = ...
    cgg_getMeanSTDSeries(this_CriteriaCoefficients_Monkey,'NumCollapseDimension',NumChannels);

this_PlotData = struct();
this_PlotData.ProportionAll = Coefficient;
this_PlotData.All_STD = Coefficient_STD;
this_PlotData.All_STE = Coefficient_STE;
this_PlotData.All_CI = Coefficient_CI;

PlotTableIDX = PlotTableIDX + 1;
PlotTable(PlotTableIDX,:) = ...
    {{this_PlotData},this_AreaName,MonkeyNames(midx),VariableName};

end

%%
end

end

end

