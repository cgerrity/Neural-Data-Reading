function out = get_class_map(key)
% out = get_class_map(key)
%
% maps key to its class
% - if key is a string, returns the number code
% - if key is a number, returns the corresponding string
%
% if key is empty, return the entire dictionary

%define the dictionary
classTypes = {'Saccade',1;
    'PSO',2;
    'Fixation',3;
    'SmoothPursuit',4;
    'Unclassified',5};

if nargin == 0
    out = classTypes;
    return
end
    

if isnumeric(key)
    ii = find(ismember([classTypes{:,2}],key));
    ind = 1;
elseif ischar(key)
    ii = find( ~cellfun(@isempty, strfind(classTypes(:,1),key) ) );
    ind = 2;
end

if isempty(ii)
    out = [];
else
    out = classTypes{ii,ind};
end
