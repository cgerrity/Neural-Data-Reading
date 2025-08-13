classdef cgg_splitLayer < nnet.layer.Layer
    properties
        InputSize
        SplitDimension
        NumNewSplits
        WantDisplay
        SplitSize
    end
    properties (Learnable)
    end
    methods
        function layer = cgg_splitLayer(name,InputSize,SplitDimension,args)

            % Parse inputs
            arguments
                name (1,1) string
                InputSize
                SplitDimension
                args.NumNewSplits (1,1) {mustBeInteger} = 0
                args.OutputNames (1,:) string {} = "-" 
                % Probably a better way to do this than "-"
            end


            layer.Name = name;
            layer.InputSize = InputSize;
            layer.WantDisplay = false;
            layer.SplitDimension = SplitDimension;
            if args.NumNewSplits == 0
                layer.NumNewSplits = InputSize(SplitDimension);
            else
                layer.NumNewSplits = args.NumNewSplits;
            end
            
            layer.SplitSize = ...
                floor(InputSize(SplitDimension)/layer.NumNewSplits);

            if strcmp(args.OutputNames,"-")
            this_OutputNames = strings(1,layer.NumNewSplits);
            for oidx = 1:layer.NumNewSplits
            this_OutputNames(oidx) = sprintf("out%d",oidx);
            end
            else
                this_OutputNames = args.OutputNames;
            end

            layer.OutputNames = this_OutputNames;
        end
        function [varargout] = predict(layer, X)
            
            this_Out = cell(1,layer.NumNewSplits);
            idx = repmat({':'}, 1, length(size(X)));

            Base_Range = 1:layer.SplitSize;
            for oidx = 1:layer.NumNewSplits
                this_Range = Base_Range + (oidx-1)*layer.SplitSize;
                idx{layer.SplitDimension} = this_Range;
                this_Out{oidx} = X(idx{:});
            end
            varargout = this_Out;

        end
        function [varargout] = forward(layer, X)

            this_Out = cell(1,layer.NumNewSplits);
            idx = repmat({':'}, 1, length(size(X)));

            Base_Range = 1:layer.SplitSize;
            for oidx = 1:layer.NumNewSplits
                this_Range = Base_Range + (oidx-1)*layer.SplitSize;
                idx{layer.SplitDimension} = this_Range;
                this_Out{oidx} = X(idx{:});
            end
            varargout = this_Out;
        end
    end
    
end
