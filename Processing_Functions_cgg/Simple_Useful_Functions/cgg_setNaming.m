function Name = cgg_setNaming(Name,varargin)
%CGG_SETNAMING Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SurroundDeliminator = CheckVararginPairs('SurroundDeliminator', {'',''}, varargin{:});
else
if ~(exist('SurroundDeliminator','var'))
SurroundDeliminator={'',''};
end
end

if isfunction
WantUnderline = CheckVararginPairs('WantUnderline', true, varargin{:});
else
if ~(exist('WantUnderline','var'))
WantUnderline=true;
end
end


if ~(isempty(Name) || strcmp(Name,""))
    Name = replace(Name,' ','-');
if startsWith(Name,'_')
    if ischar(Name)
    Name(1) = [];
    elseif isstring(Name)
    Name{1}(1) = [];
    end
end
    if numel(SurroundDeliminator) > 0 && ~isempty(SurroundDeliminator{1})
        if ischar(Name)
            Name = [char(SurroundDeliminator{1}), Name];
        elseif isstring(Name)
            Name = string(SurroundDeliminator{1}) + Name;
        end
    end
    if numel(SurroundDeliminator) > 1 && ~isempty(SurroundDeliminator{2})
        if ischar(Name)
            Name = [Name, char(SurroundDeliminator{2})];
        elseif isstring(Name)
            Name = Name + string(SurroundDeliminator{2});
        end
    end
    Name = replace(Name,'_','-');
    if ~WantUnderline
    elseif ischar(Name)
    Name = ['_' Name];
    elseif isstring(Name)
    Name = "_" + Name;
    end
    
end

end

