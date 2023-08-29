function Target = cgg_loadTargetArray(FileName,Dimension)
%CGG_LOADDATAARRAY Summary of this function goes here
%   Detailed explanation goes here

Target=load(FileName);
Target=Target.Target;

Target=Target.SelectedObjectDimVals;

% switch Target(Dimension)
%     case 0
%         Target=[0];
%     case 3
%         Target=[3];
%     case 5
%         Target=[5];
%     case 7
%         Target=[7];
%     case 8
%         Target=[8];
% end

Target=Target(Dimension);
Target=categorical(Target);

end

