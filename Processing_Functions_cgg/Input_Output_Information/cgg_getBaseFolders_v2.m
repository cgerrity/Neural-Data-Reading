function [inputfolder_base, outputfolder_base, temporaryfolder_base, CurrentSystem] = cgg_getBaseFolders_v2(varargin)
% cgg_getBaseFolders
% Returns base folders (input, output, temporary) and a system label by
% matching the invoking machine against a JSON or CSV config.
%
% Default config location:
%   ../Parameters/cgg_basefolders_config.json relative to this .m file
%
% Usage:
%   [inBase, outBase, tmpBase, sys] = cgg_getBaseFolders( ...
%       'WantTEBA', false, 'UseUI', true, 'ConfigPath', '', ...
%       'SaveNewProfile', true, 'SetupMultiple', false, 'OverwriteDuplicates', true)
%
% Parameters (Name-Value):
%   - WantTEBA            : logical (default false) — hint to select TEBA/TEBA-like profile
%   - UseUI               : logical (default true) — use UI prompts when info is missing
%   - ConfigPath          : char/string (default auto) — full path to config (json or csv)
%   - SaveNewProfile      : logical (default true) — offer to save new profile when prompting
%   - SetupMultiple       : logical (default false) — run multi-profile setup wizard
%   - OverwriteDuplicates : logical (default true) — when saving, overwrite profiles with same match+system
%
% Behavior:
%   - Missing folders mean "not available" (no creation). Only existing directories are accepted.

% Parse inputs
p = inputParser;
addParameter(p,'WantTEBA',false,@islogical);
addParameter(p,'UseUI',true,@islogical);
addParameter(p,'ConfigPath','',@(s)ischar(s)||isstring(s));
addParameter(p,'SaveNewProfile',true,@islogical);
addParameter(p,'SetupMultiple',false,@islogical);
addParameter(p,'OverwriteDuplicates',true,@islogical);
parse(p,varargin{:});
opt = p.Results;

% Gather machine info
mi = getMachineInfo();
mi.wantTEBA = opt.WantTEBA;

% Locate configuration (default ../Parameters)
cfgPath = locateConfigFile(opt.ConfigPath);
config = loadConfig(cfgPath);  % returns struct with .profiles (array of profile structs)
if ~isfield(config,'profiles') || isempty(config.profiles)
    config.profiles = [];
end

% Seed legacy-equivalent defaults if config file missing or empty
if (~isfile(cfgPath) || isempty(config.profiles))
    legacy = seedDefaultProfilesFromLegacy(mi);
    if ~isempty(legacy)
        config.profiles = mergeProfiles(config.profiles, legacy, true); % overwrite by default
        try
            saveConfig(cfgPath, config);
        catch ME
            warning('Failed to save seeded config: %s', ME.message);
        end
    end
end

[inputfolder_base, outputfolder_base, temporaryfolder_base, CurrentSystem] = deal('', '', '', '');

% Optional: multi-profile setup wizard
if opt.SetupMultiple && opt.UseUI
    newProfiles = promptUserForMultipleProfiles(mi);
    if ~isempty(newProfiles)
        config.profiles = mergeProfiles(config.profiles, newProfiles, opt.OverwriteDuplicates);
        try
            saveConfig(cfgPath, config);
        catch ME
            warning('Failed to save config: %s', ME.message);
        end
    end
end

% Attempt profile selection
[prof, ~] = selectBestProfile(config.profiles, mi);

% If matched, resolve paths and validate (existence only)
if ~isempty(prof)
    [inputfolder_base, outputfolder_base, temporaryfolder_base] = applyPaths(prof.paths, mi);
    CurrentSystem = ensureStringField(prof, 'system', 'Unspecified');
    ok = validateProfile(prof, inputfolder_base, outputfolder_base, temporaryfolder_base, mi);
    if ~ok
        warning('Matched profile "%s" is not available (one or more folders do not exist).', ensureStringField(prof,'name','(unnamed)'));
        prof = []; % treat as no match to trigger prompt
        [inputfolder_base, outputfolder_base, temporaryfolder_base, CurrentSystem] = deal('', '', '', '');
    end
end

% Prompt if needed
if isempty(prof)
    if opt.UseUI
        % Offer a choice: single profile or multi-profile setup
        choice = questdlg('No matching profile found. What would you like to do?', ...
                          'Configure profiles', 'Set up one profile','Set up multiple profiles','Cancel','Set up one profile');
        if strcmpi(choice,'Set up multiple profiles')
            newProfiles = promptUserForMultipleProfiles(mi);
            if ~isempty(newProfiles)
                config.profiles = mergeProfiles(config.profiles, newProfiles, opt.OverwriteDuplicates);
                try
                    saveConfig(cfgPath, config);
                catch ME
                    warning('Failed to save config: %s', ME.message);
                end
            end
        elseif strcmpi(choice,'Cancel')
            % user cancelled; fall back to single setup prompt as last resort
        end
        % If still nothing matched, do a single-profile guided setup
        [inputfolder_base, outputfolder_base, temporaryfolder_base, CurrentSystem, profNew] = promptUserForInfo(mi);
        if opt.SaveNewProfile && ~isempty(profNew)
            config.profiles = mergeProfiles(config.profiles, profNew, opt.OverwriteDuplicates);
            try
                saveConfig(cfgPath, config);
            catch ME
                warning('Failed to save config: %s', ME.message);
            end
        end
    else
        [inputfolder_base, outputfolder_base, temporaryfolder_base, CurrentSystem, profNew] = promptCLI(mi);
        if opt.SaveNewProfile && ~isempty(profNew)
            config.profiles = mergeProfiles(config.profiles, profNew, opt.OverwriteDuplicates);
            try
                saveConfig(cfgPath, config);
            catch ME
                warning('Failed to save config: %s', ME.message);
            end
        end
    end

    % Try selection again after new profiles were added
    [prof, ~] = selectBestProfile(config.profiles, mi);
    if ~isempty(prof)
        [inputfolder_base, outputfolder_base, temporaryfolder_base] = applyPaths(prof.paths, mi);
        CurrentSystem = ensureStringField(prof, 'system', 'Unspecified');
        ok = validateProfile(prof, inputfolder_base, outputfolder_base, temporaryfolder_base, mi);
        if ~ok
            warning('Matched profile "%s" is not available (one or more folders do not exist).', ensureStringField(prof,'name','(unnamed)'));
            [inputfolder_base, outputfolder_base, temporaryfolder_base, CurrentSystem] = deal('', '', '', '');
        end
    end
end

% ===== Helper functions =====

function mi = getMachineInfo()
    if ispc
        os = 'windows';
        username = getenv('USERNAME');
        host = getenv('COMPUTERNAME');
        homeDir = getenv('USERPROFILE');
    elseif ismac
        os = 'mac';
        username = getenv('USER');
        if isempty(username), username = getenv('USERNAME'); end
        host = getenv('HOSTNAME');
        if isempty(host), host = tryGetHost(); end
        homeDir = getenv('HOME');
    else
        os = 'linux';
        username = getenv('USER');
        if isempty(username), username = getenv('USERNAME'); end
        host = getenv('HOSTNAME');
        if isempty(host), host = tryGetHost(); end
        homeDir = getenv('HOME');
    end
    if isempty(homeDir)
        homeDir = char(java.lang.System.getProperty('user.home'));
    end
    if isempty(host)
        host = 'unknown';
    end
    mi = struct('os',lower(os), 'username',string(username), 'hostname',string(host), 'homeDir',string(homeDir));
end

function h = tryGetHost()
    h = '';
    try
        h = char(java.net.InetAddress.getLocalHost.getHostName);
    catch
        h = '';
    end
end

function d = defaultConfigDir()
    % One folder up from this function, then 'Parameters'
    here = fileparts(mfilename('fullpath'));
    parentDir = fileparts(here);
    d = fullfile(parentDir, 'Parameters');
end

function cfgPath = locateConfigFile(userPath)
    % If user supplied a path, use it directly (even if it doesn't exist yet)
    if ~isempty(userPath)
        cfgPath = string(userPath);
        return;
    end
    paramDir = defaultConfigDir();
    here = fileparts(mfilename('fullpath'));
    candidates = string.empty(1,0);

    % Prefer ../Parameters
    candidates(end+1) = fullfile(paramDir, 'cgg_basefolders_config.json');
    candidates(end+1) = fullfile(paramDir, 'cgg_basefolders_config.csv');
    % Then next to the function
    candidates(end+1) = fullfile(here, 'cgg_basefolders_config.json');
    candidates(end+1) = fullfile(here, 'cgg_basefolders_config.csv');
    % Then MATLAB prefdir
    candidates(end+1) = fullfile(prefdir, 'cgg_basefolders_config.json');
    candidates(end+1) = fullfile(prefdir, 'cgg_basefolders_config.csv');

    mask = arrayfun(@(p) isfile(p), candidates);
    if any(mask)
        cfgPath = candidates(find(mask,1,'first'));
    else
        % Default target to ../Parameters JSON (will be created on save)
        cfgPath = fullfile(paramDir, 'cgg_basefolders_config.json');
    end
end

function config = loadConfig(path)
    config = struct('profiles',[]);
    if ~isfile(path), return; end
    [~,~,ext] = fileparts(path);
    try
        switch lower(ext)
            case '.json'
                txt = fileread(path);
                j = jsondecode(txt);
                if isfield(j,'profiles')
                    config.profiles = normalizeProfiles(j.profiles);
                elseif isstruct(j) && ~isfield(j,'profiles')
                    % assume direct array of profiles
                    config.profiles = normalizeProfiles(j);
                end
            case '.csv'
                T = readtable(path, 'TextType','string');
                config.profiles = profilesFromTable(T);
            otherwise
                warning('Unsupported config extension: %s', ext);
        end
    catch ME
        warning('Failed to load config (%s): %s', path, ME.message);
    end
end

function profiles = normalizeProfiles(p)
    if isempty(p), profiles = []; return; end
    if ~isstruct(p), error('Profiles must be struct array'); end
    profiles = p;
    for i=1:numel(profiles)
        if ~isfield(profiles(i),'priority'), profiles(i).priority = 0; end
        if ~isfield(profiles(i),'match'), profiles(i).match = struct; end
        if ~isfield(profiles(i),'paths'), profiles(i).paths = struct; end
        if ~isfield(profiles(i),'tests'), profiles(i).tests = struct; end
        % Normalize types
        fieldsToString = {'name','system'};
        for k=1:numel(fieldsToString)
            f = fieldsToString{k};
            if isfield(profiles(i),f), profiles(i).(f) = string(profiles(i).(f)); end
        end
    end
end

function profiles = profilesFromTable(T)
    profiles = struct('name',{},'system',{},'match',{},'paths',{},'tests',{},'priority',{});
    if isempty(T), return; end
    cols = lower(string(T.Properties.VariableNames));
    getcol = @(name) T{:, find(cols==lower(name), 1, 'first')};
    colOrEmpty = @(name) iff(any(cols==lower(name)), getcol(name), repmat("",height(T),1));
    pri   = iff(any(cols=="priority"), double(T{:,find(cols=="priority",1)}), zeros(height(T),1));
    syst  = colOrEmpty('system');
    os    = colOrEmpty('os');
    uname = colOrEmpty('username');
    hname = colOrEmpty('hostname');
    wteba = colOrEmpty('wantteba');
    inP   = colOrEmpty('input');
    outP  = colOrEmpty('output');
    tmpP  = colOrEmpty('temp');
    exChk = colOrEmpty('existscheck'); % semicolon-separated paths to mustExist

    for i=1:height(T)
        match = struct();
        if strlength(os(i))>0, match.os = os(i); end
        if strlength(uname(i))>0, match.username = uname(i); end
        if strlength(hname(i))>0, match.hostname = hname(i); end
        if strlength(wteba(i))>0
            v = lower(strtrim(wteba(i)));
            if any(v==["true","1","yes"])
                match.wantTEBA = true;
            elseif any(v==["false","0","no"])
                match.wantTEBA = false;
            else
                match.wantTEBA = "*"; % wildcard
            end
        end
        paths = struct('input',inP(i),'output',outP(i),'temp',tmpP(i));
        tests = struct();
        if strlength(exChk(i))>0
            tests.mustExist = strtrim(split(exChk(i), ';'));
        end
        profiles(i).name = iff(any(cols=="name"), T{i,find(cols=="name",1)}, "");
        profiles(i).system = syst(i);
        profiles(i).match = match;
        profiles(i).paths = paths;
        profiles(i).tests = tests;
        profiles(i).priority = pri(i);
    end
end

function y = iff(cond, a, b)
    if cond, y = a; else, y = b; end
end

function [prof, reason] = selectBestProfile(profiles, mi)
    bestScore = -inf; bestIdx = 0; reason = "";
    for i = 1:numel(profiles)
        m = profiles(i).match;
        score = 0; ok = true;
        if isfield(m,'os'),        [ok,score] = matchField(m.os, mi.os, score);        end
        if ok && isfield(m,'username'), [ok,score] = matchField(m.username, mi.username, score); end
        if ok && isfield(m,'hostname'), [ok,score] = matchField(m.hostname, mi.hostname, score); end
        if ok && isfield(m,'wantTEBA'), [ok,score] = matchField(m.wantTEBA, mi.wantTEBA, score); end
        if ok
            if isfield(profiles(i),'priority')
                score = score + double(profiles(i).priority);
            end
            if score > bestScore
                bestScore = score; bestIdx = i;
            end
        end
    end
    if bestIdx>0
        prof = profiles(bestIdx);
    else
        prof = [];
        reason = "No profile matched.";
    end
end

function [ok,score] = matchField(pattern, value, score)
    ok = true;
    if isstring(pattern) || ischar(pattern)
        pat = string(pattern);
        if pat == "*" || strlength(pat)==0
            score = score + 0.5; % wildcard contributes low score
        else
            if strcmpi(pat, string(value))
                score = score + 2;
            else
                if contains(pat, "*")
                    rx = "^" + regexptranslate('wildcard', pat) + "$";
                    if ~isempty(regexp(string(value), rx, 'once'))
                        score = score + 1.5;
                    else
                        ok = false;
                    end
                else
                    ok = false;
                end
            end
        end
    elseif islogical(pattern)
        if isequal(pattern, logical(value))
            score = score + 2;
        else
            ok = false;
        end
    else
        ok = false;
    end
end

function [inBase, outBase, tmpBase] = applyPaths(paths, mi)
    dict = containers.Map;
    dict('username') = char(mi.username);
    dict('hostname') = char(mi.hostname);
    dict('homeDir')  = char(mi.homeDir);
    dict('os')       = char(mi.os);
    inBase  = substituteTokens(ensureStringField(paths,'input',''), dict);
    outBase = substituteTokens(ensureStringField(paths,'output',''), dict);
    tmpBase = substituteTokens(ensureStringField(paths,'temp',''), dict);
end

function ok = validateProfile(prof, inBase, outBase, tmpBase, mi)
    % Profile is valid only if all base paths exist and (if provided)
    % all mustExist paths exist (no auto-creation).
    pathsToCheck = string.empty(1,0);

    if ~isempty(inBase),  pathsToCheck(end+1) = string(inBase);  end
    if ~isempty(outBase), pathsToCheck(end+1) = string(outBase); end
    if ~isempty(tmpBase), pathsToCheck(end+1) = string(tmpBase); end

    if isfield(prof,'tests') && isfield(prof.tests,'mustExist') && ~isempty(prof.tests.mustExist)
        reqs = string(prof.tests.mustExist);
        % Substitute tokens for mustExist checks
        dict = containers.Map( ...
            {'username','hostname','homeDir','os'}, ...
            {char(mi.username), char(mi.hostname), char(mi.homeDir), char(mi.os)});
        for i = 1:numel(reqs)
            req = substituteTokens(reqs(i), dict);
            if ~isempty(req)
                pathsToCheck(end+1) = string(req);
            end
        end
    end

    pathsToCheck = unique(pathsToCheck(pathsToCheck ~= ""));
    ok = ~isempty(pathsToCheck) && all(arrayfun(@(p) isfolder(char(p)), pathsToCheck));
end

function s = ensureStringField(st, field, defaultVal)
    if isfield(st, field)
        v = st.(field);
        if isstring(v) || ischar(v)
            s = char(v);
        else
            s = char(string(v));
        end
    else
        s = char(defaultVal);
    end
end

function out = substituteTokens(in, dict)
    s = char(string(in));
    toks = regexp(s, '\{([^\}]+)\}', 'tokens');
    if isempty(toks), out = s; return; end
    for k = 1:numel(toks)
        key = toks{k}{1};
        if isKey(dict, key)
            s = strrep(s, ['{' key '}'], dict(key));
        end
    end
    out = s;
end

function saveConfig(path, config)
    % Ensure write to ../Parameters by default
    [folder,name,ext] = fileparts(path);
    if isempty(folder)
        folder = defaultConfigDir();
    end
    if ~isfolder(folder)
        mkdir(folder);
    end
    if isempty(ext)
        target = fullfile(folder, 'cgg_basefolders_config.json');
        ext = '.json';
    else
        target = fullfile(folder, [name ext]);
    end

    switch lower(ext)
        case '.json'
            txt = jsonencode(config);
            try
                txt = jsonencode(config, 'PrettyPrint', true);
            catch
            end
            fid = fopen(target,'w');
            if fid<0, error('Cannot open config for writing: %s', target); end
            fwrite(fid, txt, 'char'); fclose(fid);
        case '.csv'
            % Convert profiles to table
            rows = [];
            for i=1:numel(config.profiles)
                pr = config.profiles(i);
                os = valOrEmpty(pr,'match','os');
                un = valOrEmpty(pr,'match','username');
                hn = valOrEmpty(pr,'match','hostname');
                wt = valOrEmpty(pr,'match','wantTEBA');
                inp = valOrEmpty(pr,'paths','input');
                out = valOrEmpty(pr,'paths','output');
                tmp = valOrEmpty(pr,'paths','temp');
                exs = '';
                if isfield(pr,'tests') && isfield(pr.tests,'mustExist') && ~isempty(pr.tests.mustExist)
                    exs = strjoin(string(pr.tests.mustExist), ';');
                end
                rows = [rows; {getfieldOr(pr,'name',"") getfieldOr(pr,'system',"") os un hn wt inp out tmp getfieldOr(pr,'priority',0) exs}]; %#ok<AGROW>
            end
            if isempty(rows)
                T = cell2table(cell(0,11), 'VariableNames',{'name','system','os','username','hostname','wantTEBA','input','output','temp','priority','existsCheck'});
            else
                T = cell2table(rows, 'VariableNames',{'name','system','os','username','hostname','wantTEBA','input','output','temp','priority','existsCheck'});
            end
            writetable(T, target);
        otherwise
            error('Unsupported config extension for saving: %s', ext);
    end
end

function v = valOrEmpty(st, fld1, fld2)
    v = "";
    if nargin==2
        if isfield(st,fld1), v = string(st.(fld1)); end
    else
        if isfield(st,fld1) && isfield(st.(fld1),fld2)
            v = string(st.(fld1).(fld2));
        end
    end
end

function v = getfieldOr(st, fld, def)
    if isfield(st,fld), v = st.(fld); else, v = def; end
end

function profiles = mergeProfiles(existing, incoming, overwrite)
    if ~iscell(incoming) && ~isstruct(incoming)
        profiles = existing; return;
    end
    if isstruct(incoming), incoming = num2cell(incoming); end
    % Signature: system|os|username|hostname|wantTEBA
    function s = sig(p)
        m = struct('os',"", 'username',"", 'hostname',"", 'wantTEBA',"");
        if isfield(p,'match')
            f = fieldnames(m);
            for kk=1:numel(f)
                if isfield(p.match,f{kk}), m.(f{kk}) = string(p.match.(f{kk})); end
            end
        end
        w = m.wantTEBA;
        if islogical(w), w = string(w); end
        s = lower(sprintf('%s|%s|%s|%s|%s', ...
            ensureStringField(p,'system',''), m.os, m.username, m.hostname, w));
    end
    map = containers.Map;
    out = struct('name',{},'system',{},'match',{},'paths',{},'tests',{},'priority',{});
    % seed with existing
    for i=1:numel(existing)
        k = sig(existing(i));
        map(k) = i;
        out(end+1) = existing(i); %#ok<AGROW>
    end
    % merge incoming
    for j=1:numel(incoming)
        p = incoming{j};
        k = sig(p);
        if isKey(map,k)
            if overwrite
                idx = map(k);
                out(idx) = p;
            else
                out(end+1) = p; %#ok<AGROW>
            end
        else
            out(end+1) = p; %#ok<AGROW>
            map(k) = numel(out);
        end
    end
    profiles = out;
end

% ===== UI helpers =====

function [inB, outB, tmpB, sys, newProf] = promptUserForInfo(mi)
    % Select system with a clear prompt
    choices = {'Personal Computer','TEBA','ACCRE','Other'};
    defaultIdx = 1;
    try
        [idx, tf] = listdlg('PromptString', 'Select the system that best describes this MATLAB session:', ...
                            'SelectionMode', 'single', 'ListString', choices, ...
                            'InitialValue', defaultIdx, 'Name', 'System selection');
        if ~tf || isempty(idx)
            sys = choices{defaultIdx};
        else
            sys = choices{idx};
        end
    catch
        sys = choices{defaultIdx};
    end

    % Detailed, explicit prompts for each folder
    inDetails = sprintf([ ...
        'Please select the BASE INPUT folder (READS).\n' ...
        'This is the top-level folder where your raw data are stored or mounted.\n' ...
        'Examples:\n' ...
        '  - Mac: /Volumes/Womelsdorf Lab\n' ...
        '  - TEBA: /data\n' ...
        '  - ACCRE: /home/%s or /data/womelsdorflab\n'], mi.username);
    outDetails = sprintf([ ...
        'Please select the BASE OUTPUT folder (WRITES).\n' ...
        'This is the top-level folder where results/derivatives should be written.\n' ...
        'Examples:\n' ...
        '  - Mac: ~/Documents/ACCRE or /Volumes/%s''s home\n' ...
        '  - TEBA: /data/users/%s\n' ...
        '  - ACCRE: /home/%s\n'], mi.username, mi.username, mi.username);
    tmpDetails = sprintf([ ...
        'Please select the BASE TEMPORARY folder (CACHE/SCRATCH).\n' ...
        'Use a writable, preferably fast/local location for intermediates and cache.\n' ...
        'Examples:\n' ...
        '  - Mac: ~/Documents/ACCREDATA or /Volumes/%s''s home\n' ...
        '  - TEBA: /data/users/%s\n' ...
        '  - ACCRE: /data/womelsdorflab/%s\n'], mi.username, mi.username, mi.username);

    startIn  = startDirGuess(sys, mi, "input");
    startOut = startDirGuess(sys, mi, "output");
    startTmp = startDirGuess(sys, mi, "temp");

    inB  = askDir('Select INPUT folder base',  inDetails,  startIn);
    outB = askDir('Select OUTPUT folder base', outDetails, startOut);
    tmpB = askDir('Select TEMPORARY folder base', tmpDetails, startTmp);

    if any(cellfun(@isempty,{inB,outB,tmpB}))
        newProf = []; return;
    end

    newProf = buildProfileFromUser(mi, sys, inB, outB, tmpB, [], []);
end

function newProfiles = promptUserForMultipleProfiles(mi)
    % Step 1: choose which systems to configure
    systems = {'Personal Computer','TEBA','ACCRE','Other'};
    [idx, tf] = listdlg('PromptString', 'Select one or more systems to configure now:', ...
                        'SelectionMode', 'multiple', 'ListString', systems, ...
                        'InitialValue', 1, 'Name', 'Multi-profile setup');
    if ~tf || isempty(idx)
        newProfiles = []; return;
    end
    selected = systems(idx);
    newProfiles = [];
    for ii = 1:numel(selected)
        sys = selected{ii};

        % Step 2: ask scope/matching
        scopeChoices = {'This device only (exact hostname and username)', ...
                        'Any host (same username)', ...
                        'Any user/host (OS-level match)'};
        [sIdx, okS] = listdlg('PromptString', sprintf('Match scope for %s', sys), ...
                              'SelectionMode','single', 'ListString', scopeChoices, ...
                              'InitialValue', 1, 'Name', 'Match scope');
        if ~okS || isempty(sIdx), sIdx = 1; end

        % Derive default match based on scope + system
        match = struct();
        switch string(sys)
            case "TEBA"
                match.os = "linux"; match.wantTEBA = true;
            case "ACCRE"
                match.os = "linux";
            otherwise
                match.os = mi.os;
        end
        switch sIdx
            case 1
                match.username = mi.username; match.hostname = mi.hostname;
            case 2
                match.username = mi.username; % hostname wildcard
            case 3
                % no username/hostname fields (wildcards)
        end

        % Optional hostname pattern for ACCRE/TEBA to help selection
        if any(string(sys)==["ACCRE","TEBA"])
            answ = inputdlg({'Optional hostname pattern (e.g., accre*, panfs*, teba*). Leave blank to match any:'}, ...
                            sprintf('%s host pattern', sys), 1, {''});
            if ~isempty(answ) && strlength(string(answ{1}))>0
                match.hostname = string(answ{1});
            end
        end

        % Step 3: pick folders with explicit, guided prompts
        inDetails = sprintf([ ...
            'Select the BASE INPUT folder for %s.\n' ...
            'This is where you READ data from (top-level of raw/mounted data).\n' ...
            'Examples:\n' ...
            '  - Personal Computer: /Volumes/Womelsdorf Lab\n' ...
            '  - TEBA: /data\n' ...
            '  - ACCRE: /home/%s or /data/womelsdorflab\n'], sys, mi.username);
        outDetails = sprintf([ ...
            'Select the BASE OUTPUT folder for %s.\n' ...
            'This is where you WRITE results/derivatives.\n' ...
            'Examples:\n' ...
            '  - Personal Computer: ~/Documents/ACCRE or /Volumes/%s''s home\n' ...
            '  - TEBA: /data/users/%s\n' ...
            '  - ACCRE: /home/%s\n'], sys, mi.username, mi.username, mi.username);
        tmpDetails = sprintf([ ...
            'Select the BASE TEMPORARY folder for %s.\n' ...
            'Use a writable, fast location for intermediates and cache.\n' ...
            'Examples:\n' ...
            '  - Personal Computer: ~/Documents/ACCREDATA or /Volumes/%s''s home\n' ...
            '  - TEBA: /data/users/%s\n' ...
            '  - ACCRE: /data/womelsdorflab/%s\n'], sys, mi.username, mi.username, mi.username);

        startIn  = startDirGuess(sys, mi, "input");
        startOut = startDirGuess(sys, mi, "output");
        startTmp = startDirGuess(sys, mi, "temp");

        inB  = askDir(sprintf('[%s] Select INPUT folder base', sys),  inDetails,  startIn);
        outB = askDir(sprintf('[%s] Select OUTPUT folder base', sys), outDetails, startOut);
        tmpB = askDir(sprintf('[%s] Select TEMPORARY folder base', sys), tmpDetails, startTmp);

        if any(cellfun(@isempty,{inB,outB,tmpB}))
            % user aborted this profile; skip adding it
            continue;
        end

        % Step 4: optional mustExist checks (e.g., to detect mounts)
        msg = sprintf([ ...
            'Optional: Enter one or more "must-exist" directories for this profile.\n' ...
            'The profile will only be used if ALL listed paths exist on this machine.\n' ...
            'Tip: for detecting a mount (e.g., ~/Documents/ACCRE), put that path here.\n' ...
            'Use semicolons to separate multiple paths. Tokens like {username} are supported.\n' ...
            'Leave empty to skip.\n\n' ...
            'Example: /Users/{username}/Documents/ACCRE']);
        answ = inputdlg({'Must-exist paths (optional, semicolon-separated):'}, ...
                        sprintf('%s: Must-exist checks', sys), 1, {''});
        mustExist = [];
        if ~isempty(answ)
            ae = strtrim(string(answ{1}));
            if strlength(ae) > 0
                mustExist = strtrim(split(ae, ';'));
            end
        end

        % Step 5: priority
        defPri = defaultPriorityForSystem(sys);
        answ = inputdlg({sprintf('Priority for %s (higher wins):', sys)}, ...
                        sprintf('%s: Priority', sys), 1, {num2str(defPri)});
        pri = defPri;
        if ~isempty(answ)
            pv = str2double(answ{1});
            if ~isnan(pv), pri = pv; end
        end

        % Optional custom name
        pnameDef = sprintf('%s@%s (%s)', mi.username, mi.hostname, sys);
        answ = inputdlg({'Profile name (optional):'}, sprintf('%s: Name', sys), 1, {pnameDef});
        pname = pnameDef; if ~isempty(answ) && strlength(string(answ{1}))>0, pname = string(answ{1}); end

        % Build profile (with tokenization for portability)
        prof = buildProfileFromUser(mi, sys, inB, outB, tmpB, match, mustExist);
        prof.priority = pri;
        prof.name = pname;

        newProfiles = [newProfiles, prof]; %#ok<AGROW>
    end
end

function pri = defaultPriorityForSystem(sys)
    switch string(sys)
        case "Personal Computer", pri = 90;
        case "TEBA",              pri = 80;
        case "ACCRE",             pri = 75;
        otherwise,                pri = 60;
    end
end

function d = startDirGuess(sys, mi, which)
    switch string(sys)
        case "TEBA"
            switch which
                case "input",  d = '/data';
                case {"output","temp"}, d = fullfile('/data/users', char(mi.username));
                otherwise, d = char(mi.homeDir);
            end
        case "ACCRE"
            switch which
                case "input",  d = fullfile('/home', char(mi.username));
                case "output", d = fullfile('/home', char(mi.username));
                case "temp",   d = fullfile('/data/womelsdorflab', char(mi.username));
                otherwise, d = char(mi.homeDir);
            end
        otherwise
            d = char(mi.homeDir);
    end
end

function dirOut = askDir(titleStr, details, startPath)
    dirOut = '';
    while true
        try
            try
                uiwait(msgbox(details, titleStr, 'help', 'modal'));
            catch
                uiwait(msgbox(details, titleStr, 'help'));
            end
            if nargin < 3 || isempty(startPath) || ~isfolder(startPath)
                startPath = pwd;
            end
            p = uigetdir(startPath, titleStr);
            if isnumeric(p) && p==0
                choice = questdlg('You cancelled the selection. What next?', ...
                                  'Cancel selection', 'Choose Again','Abort','Choose Again');
                if ~strcmpi(choice,'Choose Again')
                    dirOut = ''; return;
                end
            elseif isfolder(p)
                dirOut = char(p); return;
            else
                uiwait(warndlg('Selected path does not exist. Please choose an existing folder.', 'Invalid selection', 'modal'));
            end
        catch
            % Headless or UI failure: fall back to CLI
            while true
                fprintf('\n%s\n%s\n', titleStr, details);
                fprintf('Type or paste an existing folder path (or press Enter to abort):\n> ');
                entered = strtrim(input('','s'));
                if isempty(entered)
                    dirOut = ''; return;
                elseif isfolder(entered)
                    dirOut = entered; return;
                else
                    fprintf('That path does not exist. Please try again.\n');
                end
            end
        end
    end
end

function [inB, outB, tmpB, sys, newProf] = promptCLI(mi)
    fprintf('\nNo matching config found. You can set up a single profile via CLI.\n\n');
    fprintf('System options: Personal Computer | TEBA | ACCRE | Other\n');
    sys = input('System: ','s'); if isempty(sys), sys = 'Personal Computer'; end

    inB  = promptExistingPath(sprintf('Input folder base (existing) [%s example: %s]: ', sys, startDirGuess(sys, mi, "input")));
    if isempty(inB), newProf = []; return; end
    outB = promptExistingPath(sprintf('Output folder base (existing) [%s example: %s]: ', sys, startDirGuess(sys, mi, "output")));
    if isempty(outB), newProf = []; return; end
    tmpB = promptExistingPath(sprintf('Temporary folder base (existing) [%s example: %s]: ', sys, startDirGuess(sys, mi, "temp")));
    if isempty(tmpB), newProf = []; return; end

    % Simple match: this device only
    match = struct('os',mi.os,'username',mi.username,'hostname',mi.hostname);
    newProf = buildProfileFromUser(mi, sys, inB, outB, tmpB, match, inB);
end

function pth = promptExistingPath(promptText)
    while true
        pth = strtrim(input(promptText,'s'));
        if isempty(pth)
            fprintf('Aborted.\n');
            return;
        elseif isfolder(pth)
            return;
        else
            fprintf('Path does not exist. Please provide an existing folder, or press Enter to abort.\n');
        end
    end
end

function prof = buildProfileFromUser(mi, sys, inB, outB, tmpB, match, mustExist)
    if nargin < 6 || isempty(match)
        match = struct('os',mi.os,'username',mi.username,'hostname',mi.hostname);
    end
    if nargin < 7 || isempty(mustExist)
        mustExist = string(inB);
    end

    % Tokenize paths for portability
    inB  = tokenizePath(string(inB),  mi);
    outB = tokenizePath(string(outB), mi);
    tmpB = tokenizePath(string(tmpB), mi);
    if isstring(mustExist) || ischar(mustExist)
        me = string(mustExist);
    else
        me = string(mustExist(:)');
    end
    me = arrayfun(@(s) tokenizePath(s, mi), me);

    prof = struct();
    prof.name = sprintf('%s@%s (%s)', mi.username, mi.hostname, sys);
    prof.system = string(sys);
    prof.match = match;
    prof.paths = struct('input',inB,'output',outB,'temp',tmpB);
    prof.tests = struct('mustExist', me);
    prof.priority = 50;
end

function out = tokenizePath(p, mi)
    % Replace common user-specific segments with tokens
    s = char(p);
    hd = char(mi.homeDir);
    if ~isempty(hd)
        s = strrep(s, hd, '{homeDir}');
    end
    % Normalize different OS user locations
    u = char(mi.username);
    patterns = {['/Users/' u], ['/home/' u], ['C:\Users\' u], ['D:\Users\' u]};
    for i=1:numel(patterns)
        s = strrep(s, patterns{i}, strrep(patterns{i}, u, '{username}'));
    end
    out = string(s);
end

function defaults = seedDefaultProfilesFromLegacy(mi)
    % Seed profiles based on the legacy hard-coded logic provided
    defaults = [];

    % Legacy: Personal Computer (Mac) for user 'cgerrity' with ACCRE mounted
    p1 = struct();
    p1.name = "Mac cgerrity with ACCRE mounted";
    p1.system = "Personal Computer";
    p1.match = struct('os',"mac",'username',"cgerrity",'wantTEBA',false);
    p1.paths = struct( ...
        'input', "/Users/{username}/Documents/ACCRE", ...
        'output', "/Users/{username}/Documents/ACCRE", ...
        'temp', "/Users/{username}/Documents/ACCREDATA");
    p1.tests = struct('mustExist', "/Users/{username}/Documents/ACCRE");
    p1.priority = 120;

    % Legacy: Personal Computer (Mac) fallback for 'cgerrity' via mounted volumes
    % Note: path uses "gerritcg's home" as in the snippet you shared.
    p2 = struct();
    p2.name = "Mac cgerrity via mounted volumes";
    p2.system = "Personal Computer";
    p2.match = struct('os',"mac",'username',"cgerrity");
    p2.paths = struct( ...
        'input', "/Volumes/Womelsdorf Lab", ...
        'output', "/Volumes/gerritcg''s home", ...
        'temp', "/Volumes/gerritcg''s home");
    p2.tests = struct('mustExist', "/Volumes/Womelsdorf Lab");
    p2.priority = 90;

    % Legacy: Personal Computer (Mac) for 'newuser'
    p3 = struct();
    p3.name = "Mac newuser via mounted volumes";
    p3.system = "Personal Computer";
    p3.match = struct('os',"mac",'username',"newuser");
    p3.paths = struct( ...
        'input', "/Volumes/Womelsdorf Lab", ...
        'output', "/Volumes/gerritcg''s home", ...
        'temp', "/Volumes/gerritcg''s home");
    p3.tests = struct('mustExist', "/Volumes/Womelsdorf Lab");
    p3.priority = 70;

    % Legacy: TEBA (Linux, wantTEBA=true)
    p4 = struct();
    p4.name = "TEBA default";
    p4.system = "TEBA";
    p4.match = struct('os',"linux",'wantTEBA',true);
    p4.paths = struct( ...
        'input', "/data", ...
        'output', "/data/users/{username}", ...
        'temp', "/data/users/{username}");
    p4.tests = struct('mustExist', "/data");
    p4.priority = 80;

    % Legacy: ACCRE (Linux) - hostname accre*
    p5 = struct();
    p5.name = "ACCRE default (accre hosts)";
    p5.system = "ACCRE";
    p5.match = struct('os',"linux",'hostname',"accre*");
    p5.paths = struct( ...
        'input', "/home/{username}", ...
        'output', "/home/{username}", ...
        'temp', "/data/womelsdorflab/{username}");
    p5.tests = struct('mustExist', "/home/{username}");
    p5.priority = 75;

    % Legacy: ACCRE (Linux) - hostname panfs*
    p6 = p5;
    p6.name = "ACCRE default (panfs hosts)";
    p6.match.hostname = "panfs*";

    defaults = [p1,p2,p3,p4,p5,p6];
end

end % main function