function [GradientsNew, clipInfo] = cgg_getClippedGradient(Gradients,GradientThreshold,ClipType)
%CGG_GETCLIPPEDGRADIENT Summary of this function goes here
%   Detailed explanation goes here

GradientsNew = Gradients;
clipInfo = struct('didClip',false,'globalNorm',NaN,'scale',1.0,'threshold',GradientThreshold);

switch ClipType
    case 'Global'
        % fprintf('??? Global Gradient Clipping to %.2f\n',GradientThreshold);
        [GradientsNew, clipInfo] = cgg_clipGlobalGradients(GradientsNew, GradientThreshold);
    case 'SubNetwork'
        % fprintf('??? SubNetwork Gradient Clipping to %.2f\n',GradientThreshold);
        fields = fieldnames(GradientsNew);
        for fidx = 1:length(fields)
            this_Gradient = GradientsNew.(fields{fidx});
            this_Gradient = cgg_calcGradientThreshold(this_Gradient,GradientThreshold);
            GradientsNew.(fields{fidx}) = this_Gradient;
        end
    otherwise
end

end

