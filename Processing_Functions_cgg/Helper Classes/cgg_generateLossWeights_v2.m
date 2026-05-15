classdef cgg_generateLossWeights_v2 < cgg_generateDynamicParameters
    properties
        DynamicWeighting = struct();
        WeightReconstruction = NaN;
        WeightKL = NaN;
        WeightClassification = NaN;
        WeightOffsetAndScale = 0;
        WeightConfidence = 0;
        CurrentWeightReconstruction = NaN;
        CurrentWeightKL = NaN;
        CurrentWeightClassification = NaN;
        CurrentWeightOffsetAndScale = 0;
        CurrentWeightConfidence = 0;
    end

    methods
        function WeightParameters = cgg_generateLossWeights_v2(args)

            arguments
                args.DynamicWeighting = "Unset";
                args.WeightReconstruction = "Unset";
                args.WeightKL = "Unset";
                args.WeightClassification = "Unset";
                args.WeightOffsetAndScale = "Unset";
                args.WeightConfidence = "Unset";
            end
            
            % Initialize the superclass with prefixes specific to loss weights
            WeightParameters@cgg_generateDynamicParameters("Weight", "DynamicWeighting");

            % Let the superclass handle ALL property initializations automatically
            WeightParameters.initializeAllProperties(args);
        end

        % ---------------------------------------------------------
        % Wrapper Methods for Backwards Compatibility
        % ---------------------------------------------------------
        function WeightParameters = cgg_updateAllLossWeights(WeightParameters,Epoch)
            WeightParameters = WeightParameters.updateAllParameters(Epoch);
        end

        function CurrentWeight = cgg_updateSelectLossWeight(WeightParameters,Epoch,ParameterName)
            CurrentWeight = WeightParameters.updateSelectParameter(Epoch, ParameterName);
        end

        function [Figure_Weights,t] = cgg_plotWeightsOverEpochs(WeightParameters,NumEpochs)
            [Figure_Weights,t] = WeightParameters.plotParametersOverEpochs(NumEpochs);
        end

    end
end