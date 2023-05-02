path = '/Users/ben/Desktop/prepare_test_datasets2_split';
cd(path)

%settings
reclassify = 1;
gazeArgs = 'tx300';

% reclassify, but dont over-write manual classification
if reclassify
    targ = {'_milad','_marcus'};
    
    for it=1:numel(targ)
        disp(['**********  ' targ{it} '  **********'])
        files = dir([path '/' targ{it} '/MonkeyGame*']);
        for id=1:numel(files)
           name = files(id).name;
           disp(name)
           fullpath = [path '/' targ{it} '/' name];
           load(fullpath)
           
           rawGazeData = subjectData.Runtime.RawGazeData;
           frameData = subjectData.Runtime.FrameData;

           %rough approximation of start of ITI period,
            if 1
                sel = find( [frameData.EventCode] >= 20 & [frameData.EventCode] < 40 ); %iti start
                %soemtiems a double code gets sent? delete the first of these...
                %this will get rid of a few supposed trials
                code = frameData.EventCode(sel);
                bad = find( diff(code)==0 ); 
                sel(bad) = [];
                tmpTime = frameData.EyetrackerTimeStamp(sel);
                
                %since we downsampled this data, remove some shit
                t = rawGazeData.device_time_stamp;
                selt = tmpTime>=t(1) & tmpTime <= t(end);
                tmpTime(~selt) = []; 
                
                trialStartIndices = nan(numel(tmpTime),1);
                for n=1:numel(tmpTime)
                    trialStartIndices(n) = nearest(rawGazeData.device_time_stamp,tmpTime(n));
                end
                
                % since we randomly dpwnsampled, first "trial" may not start at the beginning. manually add 1
                if trialStartIndices(1) > 1
                    trialStartIndices = [1; trialStartIndices];
                end
            end
            
            %classify
            [eyeEvents, gazeData, cfg_gaze] = ana_extractEyeEvents_new(rawGazeData, '', gazeArgs,trialStartIndices);
            subjectData.ProcessedEyeData.EyeEvents = eyeEvents;
            subjectData.ProcessedEyeData.GazeData = gazeData;
            subjectData.ProcessedEyeData.cfg_gaze = cfg_gaze;

            %re-save
            save(fullpath,'subjectData')

        end
    end
end



%average agreement, per human

%average agreement between humans