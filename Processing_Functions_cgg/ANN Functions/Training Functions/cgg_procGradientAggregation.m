function [LossInformation_Out,CM_Table,Gradients,State] = ...
    cgg_procGradientAggregation(ModelLoss,DataStore,Encoder,Decoder,...
    Classifier,LossInformation,WantUpdateLossPrior,WeightKL_Anneal,...
    MaxGradSize,varargin)
%CGG_PROCGRADIENTAGGREGATION Summary of this function goes here
%   Detailed explanation goes here

WantLossAggregation = false;

if isnan(MaxGradSize) || isempty(MaxGradSize)
[LossInformation_Out,CM_Table,Gradients,State] = ...
            dlfeval(ModelLoss,DataStore,...
            Encoder,Decoder,Classifier,...
            LossInformation,WantUpdateLossPrior,WeightKL_Anneal);
elseif numpartitions(DataStore) <= MaxGradSize || WantLossAggregation
[LossInformation_Out,CM_Table,Gradients,State] = ...
            dlfeval(ModelLoss,DataStore,...
            Encoder,Decoder,Classifier,...
            LossInformation,WantUpdateLossPrior,WeightKL_Anneal);
else

isfunction=exist('varargin','var');

if isfunction
WantParallel = CheckVararginPairs('WantParallel', true, varargin{:});
if canUseGPU
WantParallel = false;
end
else
if ~(exist('WantParallel','var'))
WantParallel=true;
end
end
%%
    HasDecoder = ~isempty(Decoder);
    HasClassifier = ~isempty(Classifier);
    SizeDataStore = numpartitions(DataStore);
    %% Initialization

    LossInformation_Out = [];
    CM_Table = [];
    Gradients = struct();
    Gradients.Encoder.Value = [];
    State = struct();
    State.Encoder = Encoder.State;
    if HasDecoder
    Gradients.Decoder.Value = [];
    State.Decoder = Decoder.State;
    end
    if HasClassifier
    Gradients.Classifier.Value = [];
    State.Classifier = Classifier.State;
    end

    %%
[MiniBatchTable,NumBatches] = ...
    cgg_procAllSessionMiniBatchTable(DataStore,MaxGradSize,false);
    if ~WantParallel
    for bidx = 1:NumBatches
        fprintf('??? Current gradient aggregation pass through is %d\n',bidx);
        [this_DataStore,~,~] = ...
        cgg_getCurrentIterationDataStore(MiniBatchTable,bidx,DataStore);
        
        NormalizationFactor = numpartitions(this_DataStore)/SizeDataStore;

        [this_LossInformation,this_CM_Table,this_Gradients,this_State] = ...
                    dlfeval(ModelLoss,this_DataStore,...
                    Encoder,Decoder,Classifier,...
                    LossInformation,WantUpdateLossPrior,WeightKL_Anneal);
    
        % Update Loss Information
        if isstruct(LossInformation_Out)
            LossInformationFunc = @(x1,x2) x1 + x2*NormalizationFactor;
            LossInformation_Out = cgg_applyFieldFun(LossInformationFunc,LossInformation_Out,this_LossInformation);
        else
            LossInformationFunc = @(x1,x2) x1*NormalizationFactor;
            LossInformation_Out = cgg_applyFieldFun(LossInformationFunc,this_LossInformation,this_LossInformation);
        end

        % Update CM_Table
        if istable(CM_Table)
            CM_Table = [CM_Table; this_CM_Table];
        else
            CM_Table = this_CM_Table;
        end

        % Update Gradients

        GradientAggregator = @(gradients,priorgradient) cgg_aggregateGradients(gradients,priorgradient,NormalizationFactor);

        if isempty(Gradients.Encoder.Value)
            GradientAggregator = @(gradients,priorgradient) cgg_aggregateGradients(gradients,[],NormalizationFactor);
        end

        Gradients.Encoder = dlupdate(GradientAggregator,this_Gradients.Encoder,Gradients.Encoder);
        if HasDecoder
        Gradients.Decoder = dlupdate(GradientAggregator,this_Gradients.Decoder,Gradients.Decoder);
        end
        if HasClassifier
        Gradients.Classifier = dlupdate(GradientAggregator,this_Gradients.Classifier,Gradients.Classifier);
        end
        % Update State

        State.Encoder = cgg_updateStateWithFunction(this_State.Encoder,State.Encoder,GradientAggregator);

        if HasDecoder
        State.Decoder = cgg_updateStateWithFunction(this_State.Decoder,State.Decoder,GradientAggregator);
        end
        if HasClassifier
        State.Classifier = cgg_updateStateWithFunction(this_State.Classifier,State.Classifier,GradientAggregator);
        end
    
    end

    else 

        LossInformation_Out_tmp = cell(NumBatches,1);
        CM_Table_tmp = cell(NumBatches,1);
        Gradients_tmp = cell(NumBatches,1);
        State_tmp = cell(NumBatches,1);
        NormalizationFactor_tmp = cell(NumBatches,1);
        % ParallelNeeded = true;

    % while ParallelNeeded
        % try

    parfor bidx = 1:NumBatches
        fprintf('??? Current gradient aggregation pass through is %d\n',bidx);
        [this_DataStore,~,~] = ...
        cgg_getCurrentIterationDataStore(MiniBatchTable,bidx,DataStore);
        
        NormalizationFactor_tmp{bidx} = numpartitions(this_DataStore)/SizeDataStore;

        [this_LossInformation,this_CM_Table,this_Gradients,this_State] = ...
                    dlfeval(ModelLoss,this_DataStore,...
                    Encoder,Decoder,Classifier,...
                    LossInformation,WantUpdateLossPrior,WeightKL_Anneal);

        LossInformation_Out_tmp{bidx} = this_LossInformation;
        CM_Table_tmp{bidx} = this_CM_Table;
        Gradients_tmp{bidx} = this_Gradients;
        State_tmp{bidx} = this_State;

        % LossInformationFunc = @(x1,x2) x1*NormalizationFactor;
        % LossInformation_Out_tmp{bidx} = cgg_applyFieldFun(LossInformationFunc,this_LossInformation,this_LossInformation);
        % 
        % CM_Table_tmp{bidx} = this_CM_Table;
        % 
        % GradientAggregator = @(gradients,priorgradient) cgg_aggregateGradients(gradients,[],NormalizationFactor);
        % Gradients_tmp{bidx}.Encoder = dlupdate(GradientAggregator,this_Gradients.Encoder,this_Gradients.Encoder);
        % if HasDecoder
        % Gradients_tmp{bidx}.Decoder = dlupdate(GradientAggregator,this_Gradients.Decoder,this_Gradients.Decoder);
        % end
        % if HasClassifier
        % Gradients_tmp{bidx}.Classifier = dlupdate(GradientAggregator,this_Gradients.Classifier,this_Gradients.Classifier);
        % end
        % 
        % State_tmp{bidx}.Encoder = cgg_updateStateWithFunction(this_State.Encoder,this_State.Encoder,GradientAggregator);
        % if HasDecoder
        % State_tmp{bidx}.Decoder = cgg_updateStateWithFunction(this_State.Decoder,this_State.Decoder,GradientAggregator);
        % end
        % if HasClassifier
        % State_tmp{bidx}.Classifier = cgg_updateStateWithFunction(this_State.Classifier,this_State.Classifier,GradientAggregator);
        % end

    end

    for bidx = 1:NumBatches
    
        this_LossInformation = LossInformation_Out_tmp{bidx};
        this_CM_Table = CM_Table_tmp{bidx};
        this_Gradients = Gradients_tmp{bidx};
        this_State = State_tmp{bidx};
        NormalizationFactor = NormalizationFactor_tmp{bidx};


        % Update Loss Information
        if isstruct(LossInformation_Out)
            LossInformationFunc = @(x1,x2) x1 + x2*NormalizationFactor;
            LossInformation_Out = cgg_applyFieldFun(LossInformationFunc,LossInformation_Out,this_LossInformation);
        else
            LossInformationFunc = @(x1,x2) x1*NormalizationFactor;
            LossInformation_Out = cgg_applyFieldFun(LossInformationFunc,this_LossInformation,this_LossInformation);
        end

        % Update CM_Table
        if istable(CM_Table)
            CM_Table = [CM_Table; this_CM_Table];
        else
            CM_Table = this_CM_Table;
        end

        % Update Gradients

        GradientAggregator = @(gradients,priorgradient) cgg_aggregateGradients(gradients,priorgradient,NormalizationFactor);

        if isempty(Gradients.Encoder.Value)
            GradientAggregator = @(gradients,priorgradient) cgg_aggregateGradients(gradients,[],NormalizationFactor);
        end

        Gradients.Encoder = dlupdate(GradientAggregator,this_Gradients.Encoder,Gradients.Encoder);
        if HasDecoder
        Gradients.Decoder = dlupdate(GradientAggregator,this_Gradients.Decoder,Gradients.Decoder);
        end
        if HasClassifier
        Gradients.Classifier = dlupdate(GradientAggregator,this_Gradients.Classifier,Gradients.Classifier);
        end
        % Update State

        State.Encoder = cgg_updateStateWithFunction(this_State.Encoder,State.Encoder,GradientAggregator);

        if HasDecoder
        State.Decoder = cgg_updateStateWithFunction(this_State.Decoder,State.Decoder,GradientAggregator);
        end
        if HasClassifier
        State.Classifier = cgg_updateStateWithFunction(this_State.Classifier,State.Classifier,GradientAggregator);
        end
    
    end
    % ParallelNeeded = false;
    % % disp('Finished');
    % fprintf('~~~ Parallel Gradient Aggregation was successful\n');
    % % profile viewer
    % % pause(10000);
    %     catch
    %         % disp('Failed');
    %         fprintf('~~~ Parallel Gradient Aggregation FAILED\n');
    %     end
    % end
    end

end
    % if ~canUseGPU
    %     profile viewer
    %     pause(10000);
    % end
end

