function cgg_runACCREMount
%CGG_RUNACCREMOUNT Summary of this function goes here
%   Detailed explanation goes here

BigPauseTime = 10;
LittlePauseTime = 1;

if isfolder('/Applications/ACCRE_Mount.app')

[inputfolder_base,outputfolder_base,temporaryfolder_base,...
    ~] = cgg_getBaseFolders();

ismounted = isfolder(fullfile(inputfolder_base,'Data_Neural')) && ...
    isfolder(fullfile(outputfolder_base,'Data_Neural')) && ...
    isfolder(fullfile(temporaryfolder_base,'Data_Neural'));
if ~ismounted
[~,~] = system('open -a /Applications/ACCRE_Mount.app');
pause(BigPauseTime);
else
    return
end

[inputfolder_base,outputfolder_base,temporaryfolder_base,...
    ~] = cgg_getBaseFolders();

ismounted = isfolder(fullfile(inputfolder_base,'Data_Neural')) && ...
    isfolder(fullfile(outputfolder_base,'Data_Neural')) && ...
    isfolder(fullfile(temporaryfolder_base,'Data_Neural'));
while ~ismounted

    pause(LittlePauseTime);

    [inputfolder_base,outputfolder_base,temporaryfolder_base,...
    ~] = cgg_getBaseFolders();

    ismounted = isfolder(fullfile(inputfolder_base,'Data_Neural')) && ...
    isfolder(fullfile(outputfolder_base,'Data_Neural')) && ...
    isfolder(fullfile(temporaryfolder_base,'Data_Neural'));
    
    pause(BigPauseTime);
end

end

end