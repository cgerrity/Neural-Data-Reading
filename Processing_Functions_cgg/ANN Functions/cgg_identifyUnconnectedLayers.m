function [Inputs,Outputs,CountInputs,CountOutputs] = cgg_identifyUnconnectedLayers(LayerGraph)
%CGG_IDENTIFYUNCONNECTEDLAYERS Summary of this function goes here
%   Detailed explanation goes here


Layers = LayerGraph.Layers;
Source = LayerGraph.Connections.Source;
Destination = LayerGraph.Connections.Destination;
Names = {Layers(:).Name}';


%%
NumLayers = length(Layers);
InputNames = cell(NumLayers,1);
OutputNames = cell(NumLayers,1);
NumInputs = NaN(NumLayers,1);
NumOutputs = NaN(NumLayers,1);
NumInputs_Used = NaN(NumLayers,1);
NumOutputs_Used = NaN(NumLayers,1);

for lidx = 1:NumLayers

this_InputName = Layers(lidx).InputNames;
if length(this_InputName) > 1
    this_InputName = cellfun(@(x) [Names{lidx}, '/' x],this_InputName,"UniformOutput",false);
else
    this_InputName = Names{lidx};
end
InputNames{lidx} = this_InputName;

this_OutputName = Layers(lidx).OutputNames;
if length(this_OutputName) > 1
    this_OutputName = cellfun(@(x) [Names{lidx}, '/' x],this_OutputName,"UniformOutput",false);
else
    this_OutputName = Names{lidx};
end
OutputNames{lidx} = this_OutputName;

end

%%

if ~iscellstr(InputNames)
InputNames = [InputNames{:}];
InputNames = InputNames';
end
if ~iscellstr(OutputNames)
OutputNames = [OutputNames{:}];
OutputNames = OutputNames';
end

%%

InputNamesRemovalIDX = contains(InputNames,'/') & ~contains(InputNames,'/in');
OutputNamesRemovalIDX = contains(OutputNames,'/') & ~contains(OutputNames,'/out');
InputNames(InputNamesRemovalIDX) = [];
OutputNames(OutputNamesRemovalIDX) = [];
%%

NumInputs_Used = cellfun(@(x) sum(contains(Destination,x)),InputNames);
NumOutputs_Used = cellfun(@(x) sum(contains(Source,x)),OutputNames);

%%

% for lidx = 1:NumLayers
% % NumInputs(lidx) = Layers(lidx).NumInputs;
% % NumOutputs(lidx) = Layers(lidx).NumOutputs;
% 
% NumInputs(lidx) = sum(contains(Layers(lidx).InputNames,'in'));
% NumOutputs(lidx) = sum(contains(Layers(lidx).OutputNames,'out'));
% 
% % FIXME: Identify that some may have multiple that are used multiple times.
% % out1 may go to multiple different layers, but out2 may be unassigned.
% % Checking for the individual outputs would be more accurate to identify
% % which layers are fully unconnected
% NumInputs_Used(lidx) = sum(contains(Destination,Names{lidx}));
% NumOutputs_Used(lidx) = sum(contains(Source,Names{lidx}));
% end

%%

% NumInputs_Unused = NumInputs - NumInputs_Used;
% NumOutputs_Unused = NumOutputs - NumOutputs_Used;
% 
% IDXInputs_Unused = find(NumInputs_Unused);
% IDXOutputs_Unused = find(NumOutputs_Unused > 0);

IDXInputs_Unused = NumInputs_Used < 1;
IDXOutputs_Unused = NumOutputs_Used < 1;

% NameInputs_Unused = Names(IDXInputs_Unused);
% NameOutputs_Unused = Names(IDXOutputs_Unused);

NameInputs_Unused = InputNames(IDXInputs_Unused);
NameOutputs_Unused = OutputNames(IDXOutputs_Unused);

% CountInputs_Unused = NumInputs_Unused(IDXInputs_Unused);
% CountOutputs_Unused = NumOutputs_Unused(IDXOutputs_Unused);

%%

Inputs = NameInputs_Unused;
Outputs = NameOutputs_Unused;

% CountInputs = CountInputs_Unused;
% CountOutputs = CountOutputs_Unused;

CountInputs = NaN;
CountOutputs = NaN;

end

