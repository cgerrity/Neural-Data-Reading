classdef cgg_generateDynamicParameters < handle
    % cgg_generateDynamicParameters Superclass for scheduling dynamic variables
    
    properties
        DynamicStructName = "";
        CommonParameterName = "";
    end

    methods
        function obj = cgg_generateDynamicParameters(Prefix, StructName)
            % Constructor: initialize the common names and prefixes used by 
            % cgg_getUpdateableParameters and the dynamic parameter lookups.
            obj.CommonParameterName = Prefix;
            obj.DynamicStructName = StructName;
        end

        function obj = initializeAllProperties(obj, args)
            % Automatically loop through provided arguments and initialize them.
            % It dynamically checks if a "Current[Name]" property exists to 
            % determine if it needs the AdditionalPrefix flag.
            
            cfg = PARAMETERS_cgg_runAutoEncoder();
            fields = fieldnames(args);
            
            for i = 1:numel(fields)
                propName = string(fields{i});
                
                % Check if the class has a 'Current...' version of this property
                if isprop(obj, "Current" + propName)
                    obj = cgg_initializeProperties(obj, propName, args, cfg, ...
                        'AdditionalPrefixes', "Current", ...
                        'DefaultArgumentValue', "Unset");
                else
                    obj = cgg_initializeProperties(obj, propName, args, cfg, ...
                        'DefaultArgumentValue', "Unset");
                end
            end
        end

        function obj = updateAllParameters(obj, Epoch)
            % Generic method to update all parameters using the defined prefix
            UpdateableParameters = cgg_getUpdateableParameters(...
                obj, obj.DynamicStructName, ...
                'CurrentValuePrefix', "Current");

            for widx = 1:length(UpdateableParameters)
                ParameterFieldName = UpdateableParameters{widx};
                ParamName = obj.CommonParameterName + string(ParameterFieldName);
                CurrentParamName = "Current" + ParamName;

                obj.(CurrentParamName) = ...
                    obj.updateSelectParameter(Epoch, ParamName);
            end
        end

        function CurrentValue = updateSelectParameter(obj, Epoch, ParameterName)
            % Generic parameter selection, utilizing the logic to dynamically
            % extract structure targets whether they are root-level or individual.
            
            Prefix = obj.CommonParameterName;
            
            if contains(ParameterName, Prefix)
                FullParamName = ParameterName;
                FieldName = erase(ParameterName, Prefix);
            else
                FullParamName = Prefix + string(ParameterName);
                FieldName = ParameterName;
            end

            BaseValue = obj.(FullParamName);

            % Uses the selected logic to route to the correct nested struct
            if cgg_hasIndividualDynamicParameters(obj, obj.DynamicStructName)
                this_DynamicParameters = obj.(obj.DynamicStructName).(FieldName);
            else
                this_DynamicParameters = obj.(obj.DynamicStructName);
            end

            this_EpochPoints = this_DynamicParameters.EpochPoints;
            this_MagnitudePoints = this_DynamicParameters.MagnitudePoints;

            CurrentValue = cgg_calculateDynamicValue(BaseValue, this_EpochPoints, this_MagnitudePoints, Epoch);
        end

        function [FigureHandle, t] = plotParametersOverEpochs(obj, NumEpochs)
            % Generic plotting method for all parameters starting with "Current"
            AllProperties = properties(obj);
            AllCurrentParams = AllProperties(contains(AllProperties, "Current"));
            PlotValues = NaN(length(AllCurrentParams), NumEpochs);
            
            for eidx = 1:NumEpochs
                obj.updateAllParameters(eidx);
                for widx = 1:length(AllCurrentParams)
                    PlotValues(widx, eidx) = obj.(AllCurrentParams{widx});
                end
            end
            
            % Create tiled layout with one row per parameter (M = number of rows)
            FigureHandle = figure;
            M = size(PlotValues, 1);
            t = tiledlayout(M, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
            x = 1:NumEpochs;
            for ridx = 1:M
                ax = nexttile;
                plot(ax, x, PlotValues(ridx, :), 'LineWidth', 1.2)
                title(ax, AllCurrentParams{ridx}, 'Interpreter', 'none')
                if ridx < M
                    ax.XTickLabel = [];
                else
                    xlabel(ax, 'Epoch')
                end
                grid(ax, 'on')
            end
        end
    end
end