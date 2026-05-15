classdef cgg_generateLoadParameters_v2 < cgg_generateDynamicParameters
    properties
        DynamicAugmentation = struct();
        STDChannelOffset = NaN;
        STDWhiteNoise = NaN;
        STDRandomWalk = NaN;
        STDTimeShift = NaN;
        WantSeparateTimeShift=false;
        CurrentSTDChannelOffset = NaN;
        CurrentSTDWhiteNoise = NaN;
        CurrentSTDRandomWalk = NaN;
        CurrentSTDTimeShift = NaN;
    end

    methods
        function LoadParameters = cgg_generateLoadParameters_v2(args)

            arguments
                args.DynamicAugmentation = "Unset";
                args.STDChannelOffset = "Unset";
                args.STDWhiteNoise = "Unset";
                args.STDRandomWalk = "Unset";
                args.STDTimeShift = "Unset";
                args.WantSeparateTimeShift = "Unset";
            end
            
            % Initialize the superclass with prefixes specific to load parameters
            LoadParameters@cgg_generateDynamicParameters("STD", "DynamicAugmentation");

            % Let the superclass handle ALL property initializations automatically
            LoadParameters.initializeAllProperties(args);
        end

        % ---------------------------------------------------------
        % Wrapper Methods for Backwards Compatibility
        % ---------------------------------------------------------
        function LoadParameters = cgg_updateAllLoadParameters(LoadParameters,Epoch)
            LoadParameters = LoadParameters.updateAllParameters(Epoch);
        end

        function CurrentParameter = cgg_updateSelectLoadParameter(LoadParameters,Epoch,ParameterName)
            CurrentParameter = LoadParameters.updateSelectParameter(Epoch, ParameterName);
        end

        function [Figure_Load,t] = cgg_plotLoadParameterOverEpochs(LoadParameters,NumEpochs)
            [Figure_Load,t] = LoadParameters.plotParametersOverEpochs(NumEpochs);
        end
    end
end