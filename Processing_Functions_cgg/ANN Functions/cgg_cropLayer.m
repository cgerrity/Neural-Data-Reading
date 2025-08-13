classdef cgg_cropLayer < nnet.layer.Layer
    properties
        InputSize
        NumCrop
        AllCrop
        IsCropSettable
        CropIndices
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
            layer.IsCropSettable = true;
            layer.CropIndices = cell(1);
        end
        function Z = predict(layer, X)
            
            if layer.IsCropSettable
            idx = repmat({':'}, 1, length(size(X)));

            for cidx = 1:layer.NumCrop
                this_CropStart = layer.AllCrop(cidx,1)+1;
                this_CropEnd = size(X,cidx)-layer.AllCrop(cidx,2);
                %
                Zeros = cgg_extractData(X == 0);
                ZeroDimensions = 1:length(size(X));
                ZeroDimensions(cidx) = [];
                Zeros = find(all(Zeros,ZeroDimensions));
                ZeroSequences = cgg_getConsecutiveSequence(Zeros);
                StartZeros = ZeroSequences(cellfun(@(x) any(x == 1), ZeroSequences));
                EndZeros = ZeroSequences(cellfun(@(x) any(x == size(X,cidx)), ZeroSequences));

                LowerNonZero = max(cat(1,0,StartZeros{:}))+1;
                UpperNonZero = min(cat(1,size(X,cidx)+1,EndZeros{:}))-1;

                CropMoveLower = LowerNonZero-this_CropStart;
                CropMoveUpper = UpperNonZero-this_CropEnd;

                if sign(CropMoveLower) == sign(CropMoveUpper)
                    CropMove = sign(CropMoveLower)*min(abs([CropMoveLower,CropMoveUpper]));
                    this_CropStart = this_CropStart + CropMove;
                    this_CropEnd = this_CropEnd + CropMove;
                end

                idx{cidx} = this_CropStart:this_CropEnd;
            end
            else
                idx = layer.CropIndices;
            end
            Z = X(idx{:});
        end
        function Z = forward(layer, X)

            if layer.IsCropSettable
            idx = repmat({':'}, 1, length(size(X)));

            for cidx = 1:layer.NumCrop
                %
                this_CropStart = layer.AllCrop(cidx,1)+1;
                this_CropEnd = size(X,cidx)-layer.AllCrop(cidx,2);
                %
                Zeros = cgg_extractData(X == 0);
                ZeroDimensions = 1:length(size(X));
                ZeroDimensions(cidx) = [];
                Zeros = find(all(Zeros,ZeroDimensions));
                ZeroSequences = cgg_getConsecutiveSequence(Zeros);
                StartZeros = ZeroSequences(cellfun(@(x) any(x == 1), ZeroSequences));
                EndZeros = ZeroSequences(cellfun(@(x) any(x == size(X,cidx)), ZeroSequences));

                LowerNonZero = max(cat(1,0,StartZeros{:}))+1;
                UpperNonZero = min(cat(1,size(X,cidx)+1,EndZeros{:}))-1;

                CropMoveLower = LowerNonZero-this_CropStart;
                CropMoveUpper = UpperNonZero-this_CropEnd;

                if sign(CropMoveLower) == sign(CropMoveUpper)
                    CropMove = sign(CropMoveLower)*min(abs([CropMoveLower,CropMoveUpper]));
                    this_CropStart = this_CropStart + CropMove;
                    this_CropEnd = this_CropEnd + CropMove;
                end

                idx{cidx} = this_CropStart:this_CropEnd;
            end
            else
                idx = layer.CropIndices;
            end
            Z = X(idx{:});
        end
    end
    
end
