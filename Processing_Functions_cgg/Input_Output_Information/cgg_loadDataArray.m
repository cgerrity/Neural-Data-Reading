function Data = cgg_loadDataArray(FileName)
%CGG_LOADDATAARRAY Summary of this function goes here
%   Detailed explanation goes here

Data=load(FileName);
Data=Data.Data(:,1:500,:);

Data=Data;

end

