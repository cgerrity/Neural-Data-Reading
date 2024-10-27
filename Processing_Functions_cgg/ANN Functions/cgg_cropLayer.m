classdef cgg_cropLayer < nnet.layer.Layer
    properties
        InputSize
        NumCrop
        AllCrop
    end
    properties (Learnable)
    end
    methods
        function layer = cgg_cropLayer(name,CropAmount)
            layer.Name = name;
            layer.NumCrop = length(CropAmount);
            AllCrop = NaN(layer.NumCrop,2);
            for cidx = 1:layer.NumCrop
                AllCrop(cidx,:) = [floor(CropAmount(cidx)/2),ceil(CropAmount(cidx)/2)];
            end
            layer.AllCrop = AllCrop;
        end
        function Z = predict(layer, X)
            
            idx = repmat({':'}, 1, length(size(X)));

            for cidx = 1:layer.NumCrop
                this_CropStart = layer.AllCrop(cidx,1)+1;
                this_CropEnd = size(X,cidx)-layer.AllCrop(cidx,2);
                idx{cidx} = this_CropStart:this_CropEnd;
            end
            Z = X(idx{:});
        end
        function Z = forward(layer, X)

            idx = repmat({':'}, 1, length(size(X)));

            for cidx = 1:layer.NumCrop
                this_CropStart = layer.AllCrop(cidx,1)+1;
                this_CropEnd = size(X,cidx)-layer.AllCrop(cidx,2);
                idx{cidx} = this_CropStart:this_CropEnd;
            end
            Z = X(idx{:});
        end
    end
    
end
