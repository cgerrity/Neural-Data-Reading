function RowNames = cgg_getSplitTableRowNames(TrialFilter,TypeValues)
%CGG_GETSPLITTABLEROWNAMES Summary of this function goes here
%   Detailed explanation goes here

if all(~strcmp(TrialFilter,'All') & ~strcmp(TrialFilter,'Target Feature'))
    [NumTypes,NumColumns]=size(TypeValues);
else
    TypeValues=0;
    [NumTypes,NumColumns]=size(TypeValues);
        if strcmp(TrialFilter,'Target Feature')
        TypeValues=0;
        NumTypes=1;
        end
end
%%
if iscell(TrialFilter)
    

elseif ischar(TrialFilter)
    TrialFilter = {TrialFilter};
elseif isstring(TrialFilter)
    
end
% 
% RowNames = strings(NumTypes,1);
% 
% for cidx = 1:NumColumns
%     this_TrialFilter = TrialFilter{cidx};
%     if cidx > 1
%         ExtraTerm = "/";
%     else
%         ExtraTerm = "";
%     end
%     for tidx = 1:NumTypes
%         this_TypeValues = TypeValues(tidx,cidx);
% RowNames(tidx,:) = RowNames(tidx,:) + ExtraTerm + sprintf("%s:%d",this_TrialFilter,this_TypeValues);
%     end
% end

%% Rename to better names
TypeValues_String = string(TypeValues);
for cidx = 1:NumColumns
    this_TrialFilter = TrialFilter{cidx};

    if cidx > 1
        ExtraTerm = "/";
    else
        ExtraTerm = "";
    end
    for tidx = 1:NumTypes
        this_TypeValues = TypeValues(tidx,cidx);
TypeValues_String(tidx,cidx) = ExtraTerm + sprintf("%s:%d",this_TrialFilter,this_TypeValues);
    end
this_TypeValues = TypeValues(:,cidx);
    switch this_TrialFilter
        case 'Dimensionality'
            TypeValues_String(this_TypeValues == 1,cidx) = '1-D';
            TypeValues_String(this_TypeValues == 2,cidx) = '2-D';
            TypeValues_String(this_TypeValues == 3,cidx) = '3-D';
        case 'Gain'
            TypeValues_String(this_TypeValues == 2,cidx) = 'Gain 2';
            TypeValues_String(this_TypeValues == 3,cidx) = 'Gain 3';
        case 'Loss'
            TypeValues_String(this_TypeValues == -1,cidx) = 'Loss -1';
            TypeValues_String(this_TypeValues == -3,cidx) = 'Loss -3';
        case 'Correct Trial'
            TypeValues_String(this_TypeValues == 1,cidx) = 'Correct';
            TypeValues_String(this_TypeValues == 0,cidx) = 'Error';
        case 'Previous Trial'
            TypeValues_String(this_TypeValues == 1,cidx) = 'Correct';
            TypeValues_String(this_TypeValues == 0,cidx) = 'Error';
        case 'Previous Outcome Corrected'
            TypeValues_String(this_TypeValues == 1,cidx) = 'Correct';
            TypeValues_String(this_TypeValues == 0,cidx) = 'Error';
        case 'Previous'
            TypeValues_String(this_TypeValues == 1,cidx) = 'Correct';
            TypeValues_String(this_TypeValues == 0,cidx) = 'Error';
        case 'Learned'
            TypeValues_String(this_TypeValues == 1,cidx) = 'Learned';
            TypeValues_String(this_TypeValues == 0,cidx) = 'Learning';
            TypeValues_String(this_TypeValues == -1,cidx) = 'Not Learned';
        case 'All'
            TypeValues_String(this_TypeValues == 0,cidx) = 'Overall';
        case 'Trials From Learning Point Category'
            TypeValues_String(this_TypeValues == 1,cidx) = 'Not Learned';
            TypeValues_String(this_TypeValues == 2,cidx) = 'fewer than 5';
            TypeValues_String(this_TypeValues == 3,cidx) = '-5 to -1';
            TypeValues_String(this_TypeValues == 4,cidx) = '0 to 9';
            TypeValues_String(this_TypeValues == 5,cidx) = '10 to 19';
            TypeValues_String(this_TypeValues == 6,cidx) = 'more than 20';
        case 'Multi Trials From Learning Point'
            [~,TrialBinName] = cgg_calcTrialsFromLPMultipleCategories([]);
            for tidx = 1:length(TrialBinName)
            TypeValues_String(this_TypeValues == tidx,cidx) = TrialBinName{tidx};
            end
        otherwise
            VariableInformation = PARAMETERS_cgg_VariableInformation(this_TrialFilter);
            for vidx = 1:height(VariableInformation)
                TypeValues_String(this_TypeValues == ...
                    VariableInformation.("Numeric Label")(vidx),cidx) = ...
                    VariableInformation.("Label")(vidx);
            end
    end
end

RowNames = join(TypeValues_String,2);

end

