function gazeData = ParseGazeDataOld(folder, filestring, scriptPath, varargin)

cd(folder)
fileInfo = dir(filestring);
[fileNames,~] = sort_nat({fileInfo.name}');
cd(scriptPath)


if ~isempty(varargin)
    badTrials = ~cellfun('isempty',strfind(fileNames, ['Trial_' num2str(varargin{1})]));
    fileNames(badTrials) = [];
end

rawArray = [];

importFilter = '{''right_pupil_validity'': %f, ''right_gaze_point_on_display_area'': (%f, %f), ''left_gaze_origin_validity'': %f, ''system_time_stamp'': %fL, ''right_gaze_origin_in_user_coordinate_system'': (%f, %f, %f), ''left_gaze_point_in_user_coordinate_system'': (%f, %f, %f), ''left_gaze_origin_in_user_coordinate_system'': (%f, %f, %f), ''left_pupil_validity'': %f, ''right_pupil_diameter'': %f, ''left_gaze_origin_in_trackbox_coordinate_system'': (%f, %f, %f), ''right_gaze_point_in_user_coordinate_system'': (%f, %f, %f), ''left_pupil_diameter'': %f, ''right_gaze_origin_validity'': %f, ''left_gaze_point_validity'': %f, ''right_gaze_point_validity'': %f, ''left_gaze_point_on_display_area'': (%f, %f), ''right_gaze_origin_in_trackbox_coordinate_system'': (%f, %f, %f), ''device_time_stamp'': %fL}';
variableNames = {'right_pupil_validity', 'right_gaze_point_on_display_area', 'left_gaze_origin_validity', 'system_time_stamp', 'right_gaze_origin_in_user_coordinate_system', 'left_gaze_point_in_user_coordinate_system', 'left_gaze_origin_in_user_coordinate_system', 'left_pupil_validity', 'right_pupil_diameter', 'left_gaze_origin_in_trackbox_coordinate_system', 'right_gaze_point_in_user_coordinate_system', 'left_pupil_diameter', 'right_gaze_origin_validity', 'left_gaze_point_validity', 'right_gaze_point_validity', 'left_gaze_point_on_display_area', 'right_gaze_origin_in_trackbox_coordinate_system', 'device_time_stamp'};
%variableNames = [variableNames, 'trial']; %this is useful

[~,folderName,~] = fileparts(folder);
reverseStr = '';
nfiles = numel(fileNames);
for i = 1:nfiles
    %print percentage of file reading
    percentDone = 100 * i / size(fileNames,1);
    msg = sprintf(['\tReading files from ' folderName ' folder, %3.1f percent finished.'], percentDone); %Don't forget this semicolon
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
    
    fid = fopen([folder filesep fileNames{i}], 'rt');
    %tmp = cell2mat(textscan(fid, importFilter));
    %tmp = cat(2,tmp,ones(size(tmp,1),1))*i;
    rawArray = [rawArray; cell2mat(textscan(fid, importFilter))];
    fclose(fid);
%     {'right_pupil_validity': %f, 'right_gaze_point_on_display_area': (0.5673869252204895, 0.015081126242876053), 'left_gaze_origin_validity': 1, 
% 'system_time_stamp': 1497906995984675L, 'right_gaze_origin_in_user_coordinate_system': (51.43767166137695, 50.11038589477539, 598.5707397460938), 
% 'left_gaze_point_in_user_coordinate_system': (24.3734130859375, 251.69015502929688, 76.16464233398438), 
% 'left_gaze_origin_in_user_coordinate_system': (-9.577058792114258, 47.36538314819336, 605.3380737304688), 'left_pupil_validity': 1, 'right_pupil_diameter': -1.0, 
% 'left_gaze_origin_in_trackbox_coordinate_system': (0.5226014256477356, 0.38821977376937866, 0.35112690925598145), 
% 'right_gaze_point_in_user_coordinate_system': (32.076171875, 257.47540283203125, 78.27030181884766), 'left_pupil_diameter': -1.0, 'right_gaze_origin_validity': 1, 
% 'left_gaze_point_validity': 1, 'right_gaze_point_validity': 1, 'left_gaze_point_on_display_area': (0.5512046813964844, 0.03876010328531265), 
% 'right_gaze_origin_in_trackbox_coordinate_system': (0.37723690271377563, 0.38040465116500854, 0.3285691440105438), 'device_time_stamp': 4709174359L}
  
end

% right_pupil_validity = rawArray(:,1);
% right_gaze_point_on_display_area = rawArray(:,2:3);
% left_gaze_origin_validity = rawArray(:,4);
% system_time_stamp = rawArray(:,5);
% right_gaze_origin_in_user_coordinate_system = rawArray(:,6:8);
% left_gaze_point_in_user_coordinate_system = rawArray(:,9:10);
% left_gaze_origin_in_user_coordinate_system = rawArray(:,11:13);
% left_pupil_validity = rawArray(:,14);
% right_pupil_diameter = rawArray(:,15);
% left_gaze_origin_in_trackbox_coordinate_system = rawArray(:,16:18);
% right_gaze_point_in_user_coordinate_system = rawArray(:,19:21);
% left_pupil_diameter = rawArray(:,22);
% right_gaze_origin_validity = rawArray(:,23);
% left_gaze_point_validity = rawArray(:,24);
% right_gaze_point_validity = rawArray(:,25);
% left_gaze_point_on_display_area = rawArray(:,26:27);
% right_gaze_origin_in_trackbox_coordinate_system = rawArray(:,28:31);
% device_time_stamp = rawArray(:,32);

% gazeData = cell2table({rawArray(:,1), rawArray(:,2:3), rawArray(:,4), rawArray(:,5), rawArray(:,6:8), rawArray(:,9:10), rawArray(:,11:13), rawArray(:,14),...
%     rawArray(:,15), rawArray(:,16:18), rawArray(:,19:21), rawArray(:,22), rawArray(:,23), rawArray(:,24), rawArray(:,25),...
%     rawArray(:,26:27), rawArray(:,28:31), rawArray(:,32)}, 'VariableNames', variableNames);

rawCell = mat2cell(rawArray, ones(1,size(rawArray,1)), [1, 2, 1, 1, 3, 3, 3, 1, 1, 3, 3, 1, 1, 1 ,1 , 2, 3, 1]);
%rawCell = mat2cell(rawArray, ones(1,size(rawArray,1)), [1, 2, 1, 1, 3, 3, 3, 1, 1, 3, 3, 1, 1, 1 ,1 , 2, 3, 1, 1]);
gazeData = cell2table(rawCell, 'VariableNames', variableNames);
xxx1=1;
% gazeData = array2table(rawArray, 'VariableNames', variableNames);
% 
% function variableNames = ExtractVariableNames(sampleText)
% 
% line = sampleText(2:end-1); %remove {}
% splitLine = strsplit(line, ', ');
% variableNames = {};
% 
% for i = 1:length(splitLine)
%     splitData = strsplit(splitLine{i}, ': ')
%     variableNames = [variableNames splitData{0}(2:end-1)];
% end
% 
% function sampleData = ParseGazeSample(sampleText, variableNames)
% line = sampleText(2:end-1); %remove {}
% splitLine = strsplit(line, ', ');
% 
% variableNames = {};

