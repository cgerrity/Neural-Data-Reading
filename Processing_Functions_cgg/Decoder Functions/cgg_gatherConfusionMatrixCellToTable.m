function CM_Table = cgg_gatherConfusionMatrixCellToTable(CM_Cell)
%CGG_GATHERCONFUSIONMATRIXCELLTOTABLE Summary of this function goes here
%   Detailed explanation goes here


NumDatastore=numel(CM_Cell);
MaxWindows=max(cellfun(@(x) numel(x),CM_Cell));

for didx=1:NumDatastore
    for widx=1:MaxWindows
        try
        thisValues=CM_Cell{didx}{widx};
        this_WindowName=sprintf('Window_%d',widx);
        this_DataNumber=thisValues(3);
        this_TrueValue=thisValues(1);
        this_PredictedValue=thisValues(2);
        if widx==1
        this_CM_Table = table(this_DataNumber,this_TrueValue,...
      this_PredictedValue,'VariableNames',{'DataNumber','TrueValue',this_WindowName});
        else
        this_CM_Table.(this_WindowName)=this_PredictedValue;
        end
        catch
        end
    end
    if exist('CM_Table','var')
    CM_Table = cgg_getCombineTablesWithMissingColumns(CM_Table,this_CM_Table);
    else
    CM_Table=this_CM_Table;
    end
end

end

