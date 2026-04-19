function InputClass = cgg_initializeProperties(InputClass,PropertyName,Arguments,cfg,varargin)
%CGG_INITIALIZEPROPERTIES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
AdditionalPrefixes = CheckVararginPairs('AdditionalPrefixes', '', varargin{:});
else
if ~(exist('AdditionalPrefixes','var'))
AdditionalPrefixes='';
end
end

if isfunction
DefaultArgumentValue = CheckVararginPairs('DefaultArgumentValue', "Unset", varargin{:});
else
if ~(exist('DefaultArgumentValue','var'))
DefaultArgumentValue="Unset";
end
end
%% Check for Additional Prefix Properties

AdditionalPrefixes = string(AdditionalPrefixes);
HasAdditionalPrefixes = ~(isempty(AdditionalPrefixes) || ...
    strcmp(AdditionalPrefixes,""));

%% Check for Default Argument Value
% If the argument value is the default for the class, then the initilized
% property should come from cfg instead.

ArgumentValue = Arguments.(PropertyName);

if isstring(DefaultArgumentValue)
    HasDefaultArgumentValue = ~strcmp(ArgumentValue,DefaultArgumentValue);
elseif isscalar(DefaultArgumentValue) && isnan(DefaultArgumentValue)
    HasDefaultArgumentValue = ~isnan(ArgumentValue);
elseif isscalar(DefaultArgumentValue) && isempty(DefaultArgumentValue)
    HasDefaultArgumentValue = ~isempty(ArgumentValue);
elseif isscalar(DefaultArgumentValue)
    HasDefaultArgumentValue = ~ArgumentValue == DefaultArgumentValue;
elseif isstruct(DefaultArgumentValue)
    HasDefaultArgumentValue = ~isempty(fieldnames(args.(PropertyName)));
else
    HasDefaultArgumentValue = false;
end
%% Check CFG value

HasCFGValue = isfield(cfg,PropertyName);
CFGValue = [];
if HasCFGValue
CFGValue = cfg.(PropertyName);
end

%% Assign Values to Properties

    if HasDefaultArgumentValue
        InputClass.(PropertyName) = ArgumentValue;
        if HasAdditionalPrefixes
            for aidx = 1:length(AdditionalPrefixes)
                InputClass.(AdditionalPrefixes(aidx) + PropertyName) = ArgumentValue;
            end
        end
    elseif HasCFGValue
        InputClass.(PropertyName) = CFGValue;
        if HasAdditionalPrefixes
            for aidx = 1:length(AdditionalPrefixes)
                InputClass.(AdditionalPrefixes(aidx) + PropertyName) = CFGValue;
            end
        end
    end
end