classdef cgg_generateLoadParameters < handle
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
        function LoadParameters = cgg_generateLoadParameters(args)

            arguments
                args.DynamicAugmentation = "Unset";
                args.STDChannelOffset = "Unset";
                args.STDWhiteNoise = "Unset";
                args.STDRandomWalk = "Unset";
                args.STDTimeShift = "Unset";
                args.WantSeparateTimeShift = "Unset";
            end

            cfg = PARAMETERS_cgg_runAutoEncoder();
            % DynamicAugmentation
            this_Property = "DynamicAugmentation";
            LoadParameters = cgg_initializeProperties(LoadParameters,...
                this_Property,args,cfg,'DefaultArgumentValue',"Unset");

            % STDChannelOffset
            this_Property = "STDChannelOffset";
            LoadParameters = cgg_initializeProperties(LoadParameters,...
                this_Property,args,cfg,'AdditionalPrefixes',"Current", ...
                'DefaultArgumentValue',"Unset");

            % STDWhiteNoise
            this_Property = "STDWhiteNoise";
            LoadParameters = cgg_initializeProperties(LoadParameters,...
                this_Property,args,cfg,'AdditionalPrefixes',"Current", ...
                'DefaultArgumentValue',"Unset");

            % STDRandomWalk
            this_Property = "STDRandomWalk";
            LoadParameters = cgg_initializeProperties(LoadParameters,...
                this_Property,args,cfg,'AdditionalPrefixes',"Current", ...
                'DefaultArgumentValue',"Unset");

            % STDTimeShift
            this_Property = "STDTimeShift";
            LoadParameters = cgg_initializeProperties(LoadParameters,...
                this_Property,args,cfg,'AdditionalPrefixes',"Current", ...
                'DefaultArgumentValue',"Unset");

            % WantSeparateTimeShift
            this_Property = "WantSeparateTimeShift";
            LoadParameters = cgg_initializeProperties(LoadParameters,...
                this_Property,args,cfg,'DefaultArgumentValue',"Unset");

        end

        function LoadParameters = cgg_updateAllLoadParameters(LoadParameters,Epoch)

            UpdateableParameters = cgg_getUpdateableParameters(...
                LoadParameters,"DynamicAugmentation",...
                'CurrentValuePrefix',"Current");

            for widx = 1:length(UpdateableParameters)
                ParameterFieldName = UpdateableParameters{widx};
                STDName = "STD" + string(ParameterFieldName);
                CurrentParameterName = "Current" + STDName;

                LoadParameters.(CurrentParameterName) = ...
                cgg_updateSelectLoadParameter(LoadParameters,Epoch, ...
                STDName);
            end
        end

        function CurrentParameter = cgg_updateSelectLoadParameter(LoadParameters,Epoch,ParameterName)

            if contains(ParameterName,"STD")
                ParameterSTDName = ParameterName;
                ParameterFieldName = erase(ParameterName,"STD");
            else
                ParameterSTDName = "STD" + string(ParameterName);
                ParameterFieldName = ParameterName;
            end

            this_Parameter = LoadParameters.(ParameterSTDName);

            if cgg_hasIndividualDynamicParameters(LoadParameters, ...
                    "DynamicAugmentation")
                this_DynamicParameters = ...
                    LoadParameters.DynamicAugmentation.(ParameterFieldName);
            else
                this_DynamicParameters = LoadParameters.DynamicAugmentation;
            end

            this_EpochPoints = this_DynamicParameters.EpochPoints;
            this_MagnitudePoints = this_DynamicParameters.MagnitudePoints;

            CurrentParameter = cgg_calculateDynamicValue(this_Parameter, this_EpochPoints, this_MagnitudePoints, Epoch);

        end

        function [Figure_Load,t] = cgg_plotLoadParameterOverEpochs( ...
                LoadParameters,NumEpochs)

            AllProperties = properties(LoadParameters);
            AllCurrentParameters = AllProperties(contains(AllProperties,"Current"));
            PlotParameters = NaN(length(AllCurrentParameters),NumEpochs);
            for eidx = 1:NumEpochs
                cgg_updateAllLoadParameters(LoadParameters,eidx);
                for widx = 1:length(AllCurrentParameters)
                    PlotParameters(widx,eidx) = LoadParameters.(AllCurrentParameters{widx});
                end
            end

            
            % Create tiled layout with one row per weight (M = number of rows)
            Figure_Load = figure;
            M = size(PlotParameters,1);
            t = tiledlayout(M,1,'TileSpacing','compact','Padding','compact');
            x = 1:NumEpochs;
            for ridx = 1:M
                ax = nexttile;
                plot(ax,x,PlotParameters(ridx,:),'LineWidth',1.2)
                title(ax,AllCurrentParameters{ridx},'Interpreter','none')
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