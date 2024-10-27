classdef reshapeLayer_2 < nnet.layer.Layer
    properties
        InputSize
        BatchDimension
        TimeDimension
        WantDisplay
    end
    properties (Learnable)
    end
    methods
        function layer = reshapeLayer_2(name,InputSize)
            layer.Name = name;
            layer.InputSize = InputSize;
            layer.WantDisplay = false;

            % SpatialDimension = 1:(length(InputSize)-1);
            % ChannelDimension = length(InputSize);
            % 
            % SpatialSize = InputSize(SpatialDimension);
            % ChannelSize = InputSize(ChannelDimension);

            layer.BatchDimension = numel(InputSize)+1;
            layer.TimeDimension = numel(InputSize)+2;
        end
        function [Z] = predict(layer, X)

            this_Size=size(X);
            if layer.WantDisplay
            Message_Before=sprintf('Before: Size %s, Dimensions %s',num2str(this_Size),X.dims);
            disp(Message_Before);
            end

            if numel(this_Size)==numel(layer.InputSize)
            Z = reshape(X,layer.InputSize);
            else
            BatchSize=this_Size(layer.BatchDimension);
            TimeSize=this_Size(layer.TimeDimension);
            FullSize=[layer.InputSize,BatchSize,TimeSize];
            if layer.WantDisplay
            Message_During=sprintf('Attemping to reshape to: Size %s',num2str(FullSize));
            disp(Message_During);
            end
            Z = reshape(X,FullSize);
            end

            if layer.WantDisplay
            Message_After=sprintf('After: Size %s, Dimensions %s',num2str(size(Z)),Z.dims);
            disp(Message_After);
            end
        end
        function [Z] = forward(layer, X)

            this_Size=size(X);
            if layer.WantDisplay
            Message_Before=sprintf('Before: Size %s, Dimensions %s',num2str(this_Size),X.dims);
            disp(Message_Before);
            end

            if numel(this_Size)==numel(layer.InputSize)
            Z = reshape(X,layer.InputSize);
            else
            BatchSize=this_Size(layer.BatchDimension);
            TimeSize=this_Size(layer.TimeDimension);
            FullSize=[layer.InputSize,BatchSize,TimeSize];
            if layer.WantDisplay
            Message_During=sprintf('Attemping to reshape to: Size %s',num2str(FullSize));
            disp(Message_During);
            end
            Z = reshape(X,FullSize);
            end

            if layer.WantDisplay
            Message_After=sprintf('After: Size %s, Dimensions %s',num2str(size(Z)),Z.dims);
            disp(Message_After);
            end
        end
    end
    
end
