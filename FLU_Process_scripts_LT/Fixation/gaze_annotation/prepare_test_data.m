%paths
%path = '/Volumes/DATA/DATA_MG/Data_copy/Main Task - Summer 2017/Data-postReplay';
path = '/Volumes/DATA_21/TWH';
cd(path)

savepath = '/users/ben/desktop/prepare_test_datasets_twh';
if ~exist(savepath); mkdir(savepath); end

%settings
testTime = 120; %seconds
minGoodData = 0.8; %proportion
maxOffsetTime = 10; %seconds
fsample = 120;
    
%init
files = dir('*TWH*');
files(~[files.isdir]) = [];

for id=1:numel(files)
    %load in
    name = files(id).name;
    fprintf(['\n' num2str(id) ': ' name])
    load([name '/ProcessedData/' name '__SubjectDataStruct.mat'])
    
    %extract data
    gaze = subjectData.ProcessedEyeData.GazeData;
    eyeIn = subjectData.Runtime.RawGazeData;

    %try, t = gaze.ProcessedTime; catch, t = gaze.EyetrackerTimestamp; end
    t = gaze.EyetrackerTimestamp * 10^-6;
    xs = gaze.XSmooth;
    d = gaze.Distance;
    c = gaze.Classification;

    %start session at first period with enough classified data

    p = 0;
    ii = randi(ceil(fsample*maxOffsetTime)); %start with some jitter into the sessio
    while p < minGoodData && ii < numel(c)
        st = t(ii);
        ist = nearest(t,st);
        ifn = nearest(t,st + testTime);
        
        %tmp = ~ismember( c(ist:ifn), [0 5] );
        tmp = ~isnan(xs(ist:ifn));
        p = sum(tmp) ./ (ifn-ist);
        ii = ii+1;
    end
    
    if p >= minGoodData
        %clean up the data to re-save
        gaze = gaze(ist:ifn,:);
        eyeIn = eyeIn(ist:ifn,:);

        subjectData.ProcessedEyeData.GazeData = gaze;
        subjectData.Runtime.RawGazeData = eyeIn;
        subjectData.warning = 'did not do thorough clean of every part of subjectData when down-sampling for test preparation';
        subjectData.toi_downsample = [t(ist),t(ifn)];

        %re-save
        fprintf('...saving')
        sname = [savepath '/' name '__SubjectDataStruct.mat'];
        save(sname,'subjectData')
    else
        warning('couldnt find a good enough segment to analyze in:\n%s',name)
    end
end
fprintf('\n')
