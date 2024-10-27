function OutputTable = cgg_addTableNeighborhoodColumn(InputTable,NeighborhoodSize,NeighborhoodFunc,varargin)
%CGG_ADDTABLENEIGHBORHOODCOLUMN Summary of this function goes here
%   Detailed explanation goes here

OutputTable = InputTable;

NumRows = height(OutputTable);

%%

Name_NeighborhoodTable = sprintf("NeighborhoodSize_%d",NeighborhoodSize);

NeighborhoodValue = cell(NumRows,1);

parfor ridx = 1:NumRows

    this_AreaSessionName = OutputTable.AreaSessionName(ridx);
    this_AreaSessionIDX = OutputTable.AreaSessionName == this_AreaSessionName;
    this_AreaSessionTable = OutputTable(this_AreaSessionIDX,:);
    this_CenterChannel = OutputTable.ChannelNumbers(ridx);
    this_Neighborhood = (this_CenterChannel-NeighborhoodSize):(this_CenterChannel+NeighborhoodSize);
    
    this_NeighborhoodIDX = ismember(this_AreaSessionTable.ChannelNumbers,this_Neighborhood);
    this_NeighborhoodTable = this_AreaSessionTable(this_NeighborhoodIDX,:);

    this_NeighborhoodValue = NeighborhoodFunc(this_NeighborhoodTable);
    NeighborhoodValue{ridx} = this_NeighborhoodValue;
end
% disp({length(NeighborhoodValue),NumRows})
OutputTable.(Name_NeighborhoodTable) = NeighborhoodValue;

end

