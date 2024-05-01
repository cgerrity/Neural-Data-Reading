classdef reshapeLayer < nnet.layer.Layer
    properties
        InputSize
        DataFormat
        SetupSize
        BatchDimension
        TimeDimension
        TimeSize
        WantDisplay
    end
    properties (Learnable)
    end
    methods
        function layer = reshapeLayer(name,InputSize,DataFormat)
            layer.Name = name;
            layer.InputSize = InputSize;
            layer.DataFormat = DataFormat;
            layer.WantDisplay = false;

            SetupSizeIndices_Spatial=DataFormat=='S';
            SetupSizeIndices_Channel=DataFormat=='C';
            layer.SetupSize = layer.InputSize(SetupSizeIndices_Spatial);
            layer.SetupSize = [layer.SetupSize,layer.InputSize(SetupSizeIndices_Channel)];

            BatchDimensionIDX=DataFormat=='B';
            layer.BatchDimension = find(BatchDimensionIDX==1);

            TimeDimensionIDX=DataFormat=='T';
            layer.TimeDimension = find(TimeDimensionIDX==1);
            layer.TimeSize = layer.InputSize(TimeDimensionIDX);
        end
        function [Z] = predict(layer, X)

            this_Size=size(X);
            if layer.WantDisplay
            Message_Before=sprintf('Before: Size %s, Dimensions %s',num2str(this_Size),X.dims);
            disp(Message_Before);
            end
            this_Size1D=prod(this_Size,"all");

            SetupSize1D= prod(layer.SetupSize,"all");

            if this_Size1D==SetupSize1D
            Z = dlarray(X,layer.DataFormat);
            Z = reshape(Z,layer.SetupSize);
            else
            % Z = dlarray(X,'SSCBT');
            BatchSize=this_Size(layer.TimeDimension);
            FullSize=[layer.SetupSize,BatchSize,layer.TimeSize];
            if layer.WantDisplay
            Message_During=sprintf('Attemping to reshape to: Size %s',num2str(FullSize));
            disp(Message_During);
            end
            Z = reshape(X,FullSize);
            end
            % Z = dlarray(Z,'SSCBT');

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
            this_Size1D=prod(this_Size,"all");

            SetupSize1D= prod(layer.SetupSize,"all");

            if this_Size1D==SetupSize1D
            Z = dlarray(X,layer.DataFormat);
            Z = reshape(Z,layer.SetupSize);
            else
            % Z = dlarray(X,'SSCBT');
            BatchSize=this_Size(layer.TimeDimension);
            FullSize=[layer.SetupSize,BatchSize,layer.TimeSize];
            if layer.WantDisplay
            Message_During=sprintf('Attemping to reshape to: Size %s',num2str(FullSize));
            disp(Message_During);
            end
            Z = reshape(X,FullSize);
            end
            % Z = dlarray(Z,'SSCBT');

            if layer.WantDisplay
            Message_After=sprintf('After: Size %s, Dimensions %s',num2str(size(Z)),Z.dims);
            disp(Message_After);
            end
        end
    end
    
end