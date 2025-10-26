function [GradientsOut, clipInfo] = cgg_clipGlobalGradients(GradientsIn, GradientThreshold)
%CGG_CLIPGLOBALGRADIENTS Clip all subnetworks using a single global norm.
% - Iterates all top-level fields of GradientsIn dynamically.
% - Expects each block to have a .Value that is either a cell array of arrays
%   (dlarray/gpuArray/numeric) or a single array.
% - Uses cgg_extractData to convert scalars for logging and the if condition.
%
% Inputs:
%   GradientsIn         struct with one field per subnetwork. Each field is a
%                       struct containing .Value with gradients.
%   GradientThreshold   scalar threshold for global L2 norm clipping.
%
% Outputs:
%   GradientsOut        same structure as input, uniformly scaled if clipped.
%   clipInfo            struct with didClip, globalNorm, scale, threshold.

    epsVal = 1e-7;
    GradientsOut = GradientsIn;
    clipInfo = struct('didClip',false,'globalNorm',NaN,'scale',1.0,'threshold',GradientThreshold);

    if isempty(GradientsIn) || isempty(GradientThreshold) || ~isfinite(GradientThreshold) || GradientThreshold <= 0
        return
    end

    % Collect all top-level fields dynamically
    fields = fieldnames(GradientsIn);
    if isempty(fields)
        return
    end

    % 1) Compute one global L2 norm across all blocks’ gradients (on-device)
    globalL2sq = 0;
    for f = 1:numel(fields)
        block = GradientsIn.(fields{f});
        if ~isstruct(block) || ~isfield(block,'Value') || isempty(block.Value)
            continue
        end

        GV = block.Value;
        if iscell(GV)
            for i = 1:numel(GV)
                if ~isempty(GV{i})
                    gi = GV{i};
                    globalL2sq = globalL2sq + sum(gi(:).*gi(:));
                end
            end
        else
            gi = GV;
            if ~isempty(gi)
                globalL2sq = globalL2sq + sum(gi(:).*gi(:));
            end
        end
    end

    globalL2 = sqrt(globalL2sq);
    % Use your helper to turn this into a plain double for logging and branching
    globalL2_host = cgg_extractData(globalL2);
    clipInfo.globalNorm = globalL2_host;

    % 2) If above threshold, scale every gradient by the same factor
    if isfinite(globalL2_host) && (globalL2_host > GradientThreshold)
        s = GradientThreshold / (globalL2_host + epsVal);
        clipInfo.scale = s;
        clipInfo.didClip = true;

        for f = 1:numel(fields)
            block = GradientsOut.(fields{f});
            if ~isstruct(block) || ~isfield(block,'Value') || isempty(block.Value)
                continue
            end

            GV = block.Value;
            if iscell(GV)
                for i = 1:numel(GV)
                    if ~isempty(GV{i})
                        GV{i} = GV{i} * s;
                    end
                end
            else
                if ~isempty(GV)
                    GV = GV * s;
                end
            end
            GradientsOut.(fields{f}).Value = GV;
        end
    end
end