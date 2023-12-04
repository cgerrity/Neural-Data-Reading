function [X_tall,Y_tall] = cgg_getTallDecoderInputs(Combined_ds)
%CGG_GETTALLDECODERINPUTS Summary of this function goes here
%   Detailed explanation goes here


Combined_tall=tall(Combined_ds);

Data_tall=Combined_tall(:,1);
Target_tall=Combined_tall(:,2);

X_tall=cell2mat(Data_tall);

Data_Sizes = cellfun(@(x) size(x), Data_tall, 'UniformOutput', false);
Data_Sizes = cellfun(@(x) x(1), Data_Sizes, 'UniformOutput', false);

Y_tall = cellfun(@(x,y) repmat(x,y,1),Target_tall,Data_Sizes, 'UniformOutput', false);
Y_tall = cell2mat(Y_tall);

end

