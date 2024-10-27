classdef cgg_splitLayer < nnet.layer.Layer
    properties
        InputSize
        SplitDimension
        NumNewSplits
        WantDisplay
    end
    properties (Learnable)
    end
    methods
        function layer = cgg_splitLayer(name,InputSize,SplitDimension)
            layer.Name = name;
            layer.InputSize = InputSize;
            layer.WantDisplay = false;
            layer.SplitDimension = SplitDimension;
            layer.NumNewSplits = InputSize(SplitDimension);
            
            this_OutputNames = strings(1,layer.NumNewSplits);
            for oidx = 1:layer.NumNewSplits
            this_OutputNames(oidx) = sprintf("out%d",oidx);
            end

            layer.OutputNames = this_OutputNames;
        end
        function [varargout] = predict(layer, X)
            
            this_Out = cell(1,layer.NumNewSplits);
            idx = repmat({':'}, 1, length(size(X)));

            for oidx = 1:layer.NumNewSplits
                idx{layer.SplitDimension} = oidx;
                this_Out{oidx} = X(idx{:});
            end
            varargout = this_Out;

        end
        function [varargout] = forward(layer, X)

            this_Out = cell(1,layer.NumNewSplits);
            idx = repmat({':'}, 1, length(size(X)));

            for oidx = 1:layer.NumNewSplits
                idx{layer.SplitDimension} = oidx;
                this_Out{oidx} = X(idx{:});
            end
            varargout = this_Out;
        end
    end
    
end
