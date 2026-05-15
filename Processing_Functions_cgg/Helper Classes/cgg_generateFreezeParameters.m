classdef cgg_generateFreezeParameters < cgg_generateDynamicParameters
    properties
        DynamicFreezing = struct();
        FactorEncoder = 1;
        FactorDecoder = 1;
        FactorClassifier = 1;
        CurrentFactorEncoder = 1;
        CurrentFactorDecoder = 1;
        CurrentFactorClassifier = 1;
    end

    methods
        function FreezeParameters = cgg_generateFreezeParameters(args)

            arguments
                args.DynamicFreezing = "Unset";
                args.FactorEncoder = 1;
                args.FactorDecoder = 1;
                args.FactorClassifier = 1;
            end
            
            % Initialize the superclass with prefixes specific to freeze
            % factors
            FreezeParameters@cgg_generateDynamicParameters("Factor", "DynamicFreezing");

            % Let the superclass handle ALL property initializations automatically
            FreezeParameters.initializeAllProperties(args);
        end

        % ---------------------------------------------------------
        % Wrapper Methods for Backwards Compatibility
        % ---------------------------------------------------------
        function FreezeParameters = cgg_updateAllFreezeParameters(FreezeParameters,Epoch)
            FreezeParameters = FreezeParameters.updateAllParameters(Epoch);
        end

        function CurrentParameter = cgg_updateSelectFreezeParameter(FreezeParameters,Epoch,ParameterName)
            CurrentParameter = FreezeParameters.updateSelectParameter(Epoch, ParameterName);
        end

        function [Figure_Freeze,t] = cgg_plotFreezeParameterOverEpochs(FreezeParameters,NumEpochs)
            [Figure_Freeze,t] = FreezeParameters.plotParametersOverEpochs(NumEpochs);
        end
    end
end