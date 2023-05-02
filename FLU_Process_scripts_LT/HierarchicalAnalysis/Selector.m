classdef Selector
    %Selectors select rows of data from a table or matrix, according to
    %whatever criteria the user desires.
    %This is intended to be used with an AnalysisLevel object, so that any
    %given level can pass its current selection down to lower levels
    
    %The intended use is for a given AnalysisLevel object to obtain a
    %logical vector of length N, where N = the number of rows in its data
    %table/matrix. The unique elements of this row in the data column
    %specified by the VarRef property will then be used to identify rows
    %that will be analysed by another AnalysisLevel
    
    %call: Selector(selectFunc, data, selectArgs, varRef, varargin)
    %selectFunc: handle to the function used to select rows
    %data: table/matrix of interest
    %selectArgs: (cell) any other arguments necessary for selectFunc
    %varRef: (string/int) reference to table/matrix column that contains
    %variable of interest
    %varargin: if necessary, reference to table/matrix column in lower
    %level of data that contains variable of interest
    
    properties
        %selection is a logical vector that refers to rows of the table or
        %array of data passed to the constructor
        Selection
        %VarRefCurrentLevel and VarRefLowerLevel are both cells containing strings (if data 
        %is in table form) or integers (if data is a matrix), referring 
        %to a data column. 
        %They will be used to find the unique values in the data at the
        %rows specified by Selection. E.g. if the SelectFunc chooses
        %subjects based on some criteria, the VarRef would point to the
        %column of the data that contained subject identifiers, and this
        %would be used to find all the unique subjects in the rows
        %identified by Selection.
        %If the current and lower AnalysisLevels use different data tables
        %or matrices, then we need to keep a separate reference to the 
        %appropriate column of the lower level. If only the first is
        %passed, it is assumed that the data is the same for both levels
        %(or at least the same column reference is appropriate for both
        %levels, e.g. if they are different tables but have the same
        %variable names)
        VarRefCurrentLevel
        VarRefLowerLevel
    end
    methods
        function obj = Selector(selectFunc, data, selectArgs, varRef, varargin)
            %check inputs are appropriate
            if isa(selectFunc, 'function_handle')
                if iscell(selectArgs)
                    %store the selection (logical vector)
                    if ~isempty(selectArgs)
                        obj.Selection = selectFunc(data, selectArgs);
                    else
                        obj.Selection = selectFunc(data);
                    end
                else
                    error('Second argument to Selector constructor must be a cell array.');
                end
            elseif isa(selectFunc, 'char')
                switch lower(selectFunc)
                    case 'all'
                        obj.Selection = true(size(data,1),1);
                    otherwise 
                        error('If first argument to Selector constructor is a string, it must be one of the following: "all".');
                end
            else
                error('First argument to Selector constructor must be a function handle or a string.');
            end
            obj.VarRefCurrentLevel = varRef;
            if ~isempty(varargin)
                obj.VarRefLowerLevel = varargin{1};
            end
%             if ischar(varRef) || (isnumeric(varRef) && floor(varRef) == varRef)
%                 obj.VarRefCurrentLevel = varRef;
%             else
%                 error('Third argument to Selector constructor must be a string or an integer.');
%             end
%             if isempty(varargin)
%                 obj.VarRefLowerLevel = varRef;
%             elseif ischar(varargin{1}) || (isnumeric(varargin{1}) && floor(varargin{1}) == varargin{1})
%                 obj.VarRefLowerLevel = varargin{1};
%             else
%                 error('Fourth argument to Selector constructor must be a string or an integer.');
%             end
        end
    end
end