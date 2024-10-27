function Data_Table = cgg_procLearningModelVariables(InData,LearningModelName)
%CGG_PROCLEARNINGMODELVARIABLES Summary of this function goes here
%   Detailed explanation goes here


SessionIDX = strcmp(InData.datasetname,LearningModelName);

InData_Session = structfun(@(x) makeTallArray(x),InData,'UniformOutput',false);

InData_Session = structfun(@(x) x(SessionIDX,:),InData_Session,'UniformOutput',false);

Data_Table = struct2table(InData_Session);


    function x = makeTallArray(x)

            if size(x,1) < size(x,2)
                x = x';
            end
    end


end

