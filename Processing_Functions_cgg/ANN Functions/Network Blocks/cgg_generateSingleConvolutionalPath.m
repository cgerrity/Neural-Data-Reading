function CoderBlocks = cgg_generateSingleConvolutionalPath(FilterSize,FilterHiddenSizes,FilterNumber,AreaIDX,varargin)
%CGG_GENERATESINGLECONVOLUTIONALPATH Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
CropSizes = CheckVararginPairs('CropSizes', [], varargin{:});
else
if ~(exist('CropSizes','var'))
CropSizes=[];
end
end

if isfunction
Coder = CheckVararginPairs('Coder', 'Encoder', varargin{:});
else
if ~(exist('Coder','var'))
Coder='Encoder';
end
end

if isfunction
Stride = CheckVararginPairs('Stride', 2, varargin{:});
else
if ~(exist('Stride','var'))
Stride=2;
end
end

if isfunction
WantResNet = CheckVararginPairs('WantResNet', false, varargin{:});
else
if ~(exist('WantResNet','var'))
WantResNet=false;
end
end

% functionLayer(@(X) dlresize(X,'Scale',2))

%%

NumLevels = length(FilterHiddenSizes);

if isempty(CropSizes)
    CropSizes = {[0,0]};
    CropSizes = repmat(CropSizes,NumLevels,1);
end

CoderBlocks = [];

for lidx = 1:NumLevels
    this_NumFilters = FilterHiddenSizes(lidx);
    this_CropAmount = CropSizes{lidx};
this_CoderBlock = cgg_generateSimpleConvolutionalBlock(FilterSize,this_NumFilters,lidx,FilterNumber,AreaIDX,'CropAmount',this_CropAmount,varargin{:});


if WantResNet
CoderBlock_Name = cgg_generateCoderBlockName(Coder,AreaIDX,FilterNumber,lidx);
Name_Residual = "conv_residual" + CoderBlock_Name;
% OutResidual_Name = Name_Residual;
% Name_Depth = "channelrepeat" + CoderBlock_Name;

% this_Residual = convolution2dLayer(1,this_NumFilters,"Name",Name_Residual,"Padding",'same','Stride',Stride);

switch Coder
    case 'Decoder'
        CropName="crop_residual" + CoderBlock_Name;
        this_Residual = [transposedConv2dLayer(1,this_NumFilters,"Name",Name_Residual,'Stride',Stride,"Cropping","same")
            cgg_cropLayer(CropName,this_CropAmount)];
        % this_Residual = [functionLayer(@(X) dlresize(X,'Scale',Stride),'Name',Name_Residual)
        %     cgg_cropLayer(CropName,CropAmount)
        %     depthConcatenationLayer(this_NumFilters,'Name',Name_Depth)];
        % OutResidual_Name = CropName;
    otherwise
        this_Residual = convolution2dLayer(1,this_NumFilters,"Name",Name_Residual,"Padding",'same','Stride',Stride);
% this_Residual = [averagePooling2dLayer(Stride,'Stride',Stride,'Name',Name_Residual,'Padding','same')
%     depthConcatenationLayer(this_NumFilters,'Name',Name_Depth)];
end

this_CoderBlock_LG = layerGraph(this_CoderBlock);
this_Residual = layerGraph(this_Residual);

% for fidx = 2:this_NumFilters
%     this_Destination = sprintf("%s/in%d",Name_Depth,fidx);
% this_Residual = connectLayers(this_Residual,OutResidual_Name,this_Destination);
% end

this_CoderBlock_LG = cgg_connectLayerGraphs(this_Residual,this_CoderBlock_LG,'DestinationHint','addition');
% [Destination,Source,~,~] = cgg_identifyUnconnectedLayers(this_CoderBlock_LG);
% disp(Source);
% disp(Destination);
end
% this_ResidualPath = layerGraph(averagePooling2dLayer(2,'Stride',2,'Name',ResPathName));

switch Coder
    case 'Decoder'
        if WantResNet
            if lidx == 1
                CoderBlocks = this_CoderBlock_LG;
            else
                [~,Source,~,~] = cgg_identifyUnconnectedLayers(this_CoderBlock_LG);
                [Destination,~,~,~] = cgg_identifyUnconnectedLayers(CoderBlocks);
                CoderBlocks = cgg_combineLayerGraphs(this_CoderBlock_LG,CoderBlocks);
                CoderBlocks = connectLayers(CoderBlocks,Source{1},Destination{1});
                CoderBlocks = connectLayers(CoderBlocks,Source{1},Destination{2});
            end
        else
        CoderBlocks = [this_CoderBlock
                 CoderBlocks];
        end
    otherwise
        if WantResNet
            if lidx == 1
                CoderBlocks = this_CoderBlock_LG;
            else
                [Destination,~,~,~] = cgg_identifyUnconnectedLayers(this_CoderBlock_LG);
                [~,Source,~,~] = cgg_identifyUnconnectedLayers(CoderBlocks);
                CoderBlocks = cgg_combineLayerGraphs(CoderBlocks,this_CoderBlock_LG);
                % disp(Source);
                % disp(Destination);
                CoderBlocks = connectLayers(CoderBlocks,Source{1},Destination{1});
                CoderBlocks = connectLayers(CoderBlocks,Source{1},Destination{2});
            end
        else
        CoderBlocks = [CoderBlocks
                         this_CoderBlock];
        end
end
end


end

