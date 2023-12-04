function [Identifiers,IdentifierName,TrialVariable] = cgg_getTrialVariablesFromDatastore(InDatastore,TrialVariableName,varargin)
%CGG_GETTRIALVARIABLESFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Identifiers = CheckVararginPairs('Identifiers', '', varargin{:});
else
if ~(exist('Identifiers','var'))
Identifiers='';
end
end

if isfunction
IdentifierName = CheckVararginPairs('IdentifierName', '', varargin{:});
else
if ~(exist('IdentifierName','var'))
IdentifierName='';
end
end

%%

if isempty(Identifiers)||isempty(IdentifierName)
InDatastore_tmp=InDatastore;
Target_ds=InDatastore_tmp.UnderlyingDatastores{2};

Target_Fun=@(x) cgg_loadTargetArray(x);

Target_ds.ReadFcn=Target_Fun;

% UniqueDataIdentifiers=gather(tall(Target_ds));
UniqueDataIdentifiers=read(Target_ds);

[NumTrials,~]=size(UniqueDataIdentifiers);

if NumTrials>1
Identifiers=cellfun(@(x) x{1},UniqueDataIdentifiers,'UniformOutput',false);
IdentifierName=UniqueDataIdentifiers{1}{2};
else
Identifiers=UniqueDataIdentifiers{1};
IdentifierName=UniqueDataIdentifiers{2};
end


end

%%

[NumTrials,~]=size(Identifiers);

IdentifierIDX=strcmp(IdentifierName,TrialVariableName);
if NumTrials>1
TrialVariable=cellfun(@(x) x(IdentifierIDX),Identifiers,'UniformOutput',true);
else
TrialVariable=Identifiers(IdentifierIDX);
end

end

