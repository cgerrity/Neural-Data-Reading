function NeighborhoodValue = cgg_getTableNeighborhood(InputTable,NeighborhoodSize,NeighborhoodFunc,varargin)
%CGG_ADDTABLENEIGHBORHOODCOLUMN Summary of this function goes here
%   Detailed explanation goes here

NumRows = height(InputTable);

%%

NeighborhoodValue = cell(NumRows,1);

parfor ridx = 1:NumRows

    this_AreaSessionName = InputTable.AreaSessionName(ridx);
    this_AreaSessionIDX = InputTable.AreaSessionName == this_AreaSessionName;
    this_AreaSessionTable = InputTable(this_AreaSessionIDX,:);
    this_CenterChannel = InputTable.ChannelNumbers(ridx);
    this_Neighborhood = (this_CenterChannel-NeighborhoodSize):(this_CenterChannel+NeighborhoodSize);
    
    this_NeighborhoodIDX = ismember(this_AreaSessionTable.ChannelNumbers,this_Neighborhood);
    this_NeighborhoodTable = this_AreaSessionTable(this_NeighborhoodIDX,:);

    this_NeighborhoodValue = NeighborhoodFunc(this_NeighborhoodTable);
    NeighborhoodValue{ridx} = this_NeighborhoodValue;
end


end

