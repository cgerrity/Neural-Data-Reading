function loss_OffsetAndScale = cgg_lossOffsetAndScale(X,Y_Encoded,Decoder,State,varargin)
%CGG_LOSSOFFSETANDSCALE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
wantPredict = CheckVararginPairs('wantPredict', true, varargin{:});
else
if ~(exist('wantPredict','var'))
wantPredict=true;
end
end

if isfunction
WantGradient = CheckVararginPairs('WantGradient', false, varargin{:});
else
if ~(exist('WantGradient','var'))
WantGradient=false;
end
end

if isfunction
AugmentEquation = CheckVararginPairs('AugmentEquation', 'mX+b+X', varargin{:});
else
if ~(exist('AugmentEquation','var'))
AugmentEquation='mX+b+X';
end
end

epsilon = dlarray(0.00001);
loss_Scale = dlarray(0);
loss_Offset = dlarray(0);

SpatialDimensions = finddim(X,'S');
ChannelDimension = finddim(X,'C');

Mask_NaN = ~any(isnan(X),SpatialDimensions(end));

switch AugmentEquation
    case 'm(X+b)'
        T_Scale = range(X,SpatialDimensions(end));
        T_Offset = median(X,SpatialDimensions(end))./(T_Scale + epsilon);
    case 'mX+b+X'
        T_Scale = range(X,SpatialDimensions(end))-1;
        T_Offset = median(X,SpatialDimensions(end));
    otherwise
        T_Scale = range(X,SpatialDimensions(end))-1;
        T_Offset = median(X,SpatialDimensions(end));
end

LayerNames_Decoder = {Decoder.Layers(:).Name};

OutputHint_Scale = "reshape_scale_Augment";
OutputNames = LayerNames_Decoder(contains(LayerNames_Decoder,OutputHint_Scale));
Y_Decoded=cell(length(OutputNames),1);

if ~isempty(Y_Decoded)
    Decoder=resetState(Decoder);
    Decoder = cgg_updateState(Decoder,State.Decoder);
if wantPredict
    [Y_Decoded{:},~] = predict(Decoder,Y_Encoded,Outputs=OutputNames);
else
    [Y_Decoded{:},~] = forward(Decoder,Y_Encoded,Outputs=OutputNames);
end

if length(OutputNames) > 1
AreaNumbers = cellfun(@str2num,extractAfter(OutputNames,"Area-"));
[~,SortIDX] = sort(AreaNumbers);
Y_Decoded(SortIDX) = Y_Decoded;
Y_Scale = cat(ChannelDimension,Y_Decoded{:});
end
loss_Scale = 0.5*l2loss(Y_Scale,T_Scale,Mask=Mask_NaN);
end

OutputHint_Offset = "reshape_scale_Augment";
OutputNames = LayerNames_Decoder(contains(LayerNames_Decoder,OutputHint_Offset));
Y_Decoded=cell(length(OutputNames),1);

if ~isempty(Y_Decoded)
    Decoder=resetState(Decoder);
    Decoder = cgg_updateState(Decoder,State.Decoder);
if wantPredict
    [Y_Decoded{:},~] = predict(Decoder,Y_Encoded,Outputs=OutputNames);
else
    [Y_Decoded{:},~] = forward(Decoder,Y_Encoded,Outputs=OutputNames);
end

if length(OutputNames) > 1
AreaNumbers = cellfun(@str2num,extractAfter(OutputNames,"Area-"));
[~,SortIDX] = sort(AreaNumbers);
Y_Decoded(SortIDX) = Y_Decoded;
Y_Offset = cat(ChannelDimension,Y_Decoded{:});
end
loss_Offset = 0.5*l2loss(Y_Offset,T_Offset,Mask=Mask_NaN);
end

loss_OffsetAndScale = loss_Scale + loss_Offset;

if WantGradient
    loss_OffsetAndScale = cgg_extractData(loss_OffsetAndScale);
end

end

