function fullfilename = cgg_generateActivityFullFileName(varargin)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

%% Directories

if isfunction
[cfg] = cgg_generateNeuralDataFoldersTopLevel(varargin{:});
elseif (exist('inputfolder','var'))&&(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('inputfolder',...
    inputfolder,'outdatadir',outdatadir);
elseif (exist('inputfolder','var'))&&~(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('inputfolder',inputfolder);
elseif ~(exist('inputfolder','var'))&&(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('outdatadir',outdatadir);
else
[cfg] = cgg_generateNeuralDataFoldersTopLevel;
end

if isfunction
Activity_Type = CheckVararginPairs('Activity_Type', '', varargin{:});
else
if ~(exist('Activity_Type','var'))
    Activity_Type=[];
end
end
if isempty(Activity_Type)
    prompt = {'Enter Activity Type (e.g. MUA)'};
    dlgtitle = 'Input for Activity Type';
    dims = [1 35];
    definput = {'MUA'};
    Activity_Type = inputdlg(prompt,dlgtitle,dims,definput);
    Activity_Type = Activity_Type{1};
end

if isfunction
probe_area = CheckVararginPairs('probe_area', '', varargin{:});
else
if ~(exist('probe_area','var'))
    probe_area=[];
end
end
if isempty(probe_area)
    prompt = {'Enter Probe Area Name (e.g. ACC_001)'};
    dlgtitle = 'Input for Probe Area';
    dims = [1 35];
    definput = {'ACC_001'};
    probe_area = inputdlg(prompt,dlgtitle,dims,definput);
    probe_area = probe_area{1};
end


outdatadir_Area=[cfg.outdatadir_Activity, filesep, probe_area];
outdatadir_Signal=[outdatadir_Area, filesep, Activity_Type];

fullfilename=[outdatadir_Signal filesep Activity_Type '_Trial_%d.mat'];

end

