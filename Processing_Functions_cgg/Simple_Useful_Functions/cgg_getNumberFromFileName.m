function [FileNumber,NumberWidth] = cgg_getNumberFromFileName(FileName)
%CGG_GETNUMBERFROMFILENAME Summary of this function goes here
%   Detailed explanation goes here


if iscell(FileName)
    FileName=FileName{1};
end

[~,FileName,~]=fileparts(FileName);

NumberStrings = regexp(FileName, '\d+', 'match');

% Data or Target number is formatted as the last part of the name so take
% the last possible number.

NumberString=NumberStrings{end};

NumberWidth=numel(NumberString);

FileNumber=str2double(NumberString);

end

