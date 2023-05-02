classdef Processor
    %class designed to process data in some way
    properties
        ProcessFunc
        ProcessArgs
        OutputSize
    end
    methods
        function obj = Processor(processFunc, processArgs, outputSize)
            if isa(processFunc, 'function_handle')
                obj.ProcessFunc = processFunc;
            else
                error('First argument to Processor constructor must be a function handle.');
            end
            if iscell(processArgs)
                obj.ProcessArgs = processArgs;
            else
                error('Second argument to Processor constructor must be a cell array.');
            end
            if (isnumeric(outputSize) && floor(outputSize) == outputSize)
                obj.OutputSize = outputSize;
            else
                error('Third argument to Processor constructor must be an integer.');
            end
        end
        
        function output = RunProcessor(self, data, varargin)
            if isempty(varargin) %using whatever arguments were passed to the Selector constructor
                if ~isempty(self.ProcessArgs)
                    output = self.ProcessFunc(data, self.ProcessArgs{:});
                else
                    output = self.ProcessFunc(data);
                end
            else %using temporary arguments appended as a cell to the RunSelector call
                output = self.ProcessFunc(data, varargin{:});
            end
        end
    end
end