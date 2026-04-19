classdef cgg_generateLossWeights < handle
    properties
        DynamicWeighting = struct();
        WeightReconstruction = NaN;
        WeightKL = NaN;
        WeightClassification = NaN;
        WeightOffsetAndScale = 0;
        CurrentWeightReconstruction = NaN;
        CurrentWeightKL = NaN;
        CurrentWeightClassification = NaN;
        CurrentWeightOffsetAndScale = 0;
        CommonParameterName = "Weight";
    end

    methods
        function WeightParameters = cgg_generateLossWeights(args)

            arguments
                args.DynamicWeighting = "Unset";
                args.WeightReconstruction = "Unset";
                args.WeightKL = "Unset";
                args.WeightClassification = "Unset";
                args.WeightOffsetAndScale = "Unset";
            end

            cfg = PARAMETERS_cgg_runAutoEncoder();

            % DynamicWeighting
            this_Property = "DynamicWeighting";
            WeightParameters = cgg_initializeProperties(WeightParameters,...
                this_Property,args,cfg,'DefaultArgumentValue',"Unset");
            
            % WeightReconstruction
            this_Property = "WeightReconstruction";
            WeightParameters = cgg_initializeProperties(WeightParameters,...
                this_Property,args,cfg,'AdditionalPrefixes',"Current", ...
                'DefaultArgumentValue',"Unset");

            % WeightKL
            this_Property = "WeightKL";
            WeightParameters = cgg_initializeProperties(WeightParameters,...
                this_Property,args,cfg,'AdditionalPrefixes',"Current", ...
                'DefaultArgumentValue',"Unset");

            % WeightClassification
            this_Property = "WeightClassification";
            WeightParameters = cgg_initializeProperties(WeightParameters,...
                this_Property,args,cfg,'AdditionalPrefixes',"Current", ...
                'DefaultArgumentValue',"Unset");

            % WeightOffsetAndScale
            this_Property = "WeightOffsetAndScale";
            WeightParameters = cgg_initializeProperties(WeightParameters,...
                this_Property,args,cfg,'AdditionalPrefixes',"Current", ...
                'DefaultArgumentValue',"Unset");
        end

        function WeightParameters = cgg_updateAllLossWeights(WeightParameters,Epoch)

            UpdateableParameters = cgg_getUpdateableParameters(...
                WeightParameters,"DynamicWeighting",...
                'CurrentValuePrefix',"Current");

            for widx = 1:length(UpdateableParameters)
                ParameterFieldName = UpdateableParameters{widx};
                WeightName = "Weight" + string(ParameterFieldName);
                CurrentWeightName = "Current" + WeightName;

                WeightParameters.(CurrentWeightName) = ...
                cgg_updateSelectLossWeight(WeightParameters,Epoch, ...
                WeightName);
            end
        end

        function CurrentWeight = cgg_updateSelectLossWeight(WeightParameters,Epoch,ParameterName)

            if contains(ParameterName,"Weight")
                ParameterWeightName = ParameterName;
                ParameterFieldName = erase(ParameterName,"Weight");
            else
                ParameterWeightName = "Weight" + string(ParameterName);
                ParameterFieldName = ParameterName;
            end

            this_Weight = WeightParameters.(ParameterWeightName);

            if cgg_hasIndividualDynamicParameters(WeightParameters, ...
                    "DynamicWeighting")
                this_DynamicParameters = ...
                    WeightParameters.DynamicWeighting.(ParameterFieldName);
            else
                this_DynamicParameters = WeightParameters.DynamicWeighting;
            end

            this_EpochPoints = this_DynamicParameters.EpochPoints;
            this_MagnitudePoints = this_DynamicParameters.MagnitudePoints;

            CurrentWeight = cgg_calculateDynamicValue(this_Weight, this_EpochPoints, this_MagnitudePoints, Epoch);

        end

        function [Figure_Weights,t] = cgg_plotWeightsOverEpochs( ...
                WeightParameters,NumEpochs)

            AllProperties = properties(WeightParameters);
            AllCurrentWeights = AllProperties(contains(AllProperties,"Current"));
            PlotWeights = NaN(length(AllCurrentWeights),NumEpochs);
            for eidx = 1:NumEpochs
                cgg_updateAllLossWeights(WeightParameters,eidx);
                for widx = 1:length(AllCurrentWeights)
                    PlotWeights(widx,eidx) = WeightParameters.(AllCurrentWeights{widx});
                end
            end

            
            % Create tiled layout with one row per weight (M = number of rows)
            Figure_Weights = figure;
            M = size(PlotWeights,1);
            t = tiledlayout(M,1,'TileSpacing','compact','Padding','compact');
            x = 1:NumEpochs;
            for ridx = 1:M
                ax = nexttile;
                plot(ax,x,PlotWeights(ridx,:),'LineWidth',1.2)
                title(ax,AllCurrentWeights{ridx},'Interpreter','none')
                if ridx < M
                    ax.XTickLabel = [];
                else
                    xlabel(ax,'Epoch')
                end
                grid(ax,'on')
            end

        end

    end
end