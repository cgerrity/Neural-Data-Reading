function [FirstHiddenSize,NumberOfLayers] = cgg_getHiddenSizeInformation(HiddenSizeString)
%CGG_GETHIDDENSIZEINFORMATION Summary of this function goes here
%   Detailed explanation goes here
    % Extract all numbers in brackets
    HiddenSizes = regexp(HiddenSizeString, '\[(\d+)\]', 'tokens');
    
    % Count how many brackets there are
    NumberOfLayers = length(HiddenSizes);
    
    % Extract the first number (if any)
    if NumberOfLayers > 0
        FirstHiddenSize = str2double(HiddenSizes{1}{1});
    else
        FirstHiddenSize = NaN; % Return NaN if no brackets found
    end
end

