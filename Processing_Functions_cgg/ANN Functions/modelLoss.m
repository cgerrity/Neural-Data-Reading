function [loss,gradients,state] = modelLoss(net,X,T,LossType,varargin)

isfunction=exist('varargin','var');

if isfunction
wantPredict = CheckVararginPairs('wantPredict', false, varargin{:});
else
if ~(exist('wantPredict','var'))
wantPredict=false;
end
end

if wantPredict
[Y,state] = predict(net,X);
else
[Y,state] = forward(net,X);
end

switch LossType
    case 'Regression'
loss = mse(Y,T);
    case 'Classification'
loss = crossentropy(Y,T);
end

gradients = dlgradient(loss,net.Learnables);

end