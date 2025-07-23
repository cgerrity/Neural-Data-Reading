function [LossInformation_Out,CM_Table,Gradients,State] = ...
    cgg_procGradientAggregation(ModelLoss,DataStore,Encoder,Decoder,...
    Classifier,LossInformation,WantUpdateLossPrior,WeightKL_Anneal,...
    MaxGradSize)
%CGG_PROCGRADIENTAGGREGATION Summary of this function goes here
%   Detailed explanation goes here

if isnan(MaxGradSize) || isempty(MaxGradSize)
[LossInformation_Out,CM_Table,Gradients,State] = ...
            dlfeval(ModelLoss,DataStore,...
            Encoder,Decoder,Classifier,...
            LossInformation,WantUpdateLossPrior,WeightKL_Anneal);
elseif numpartitions(DataStore) == MaxGradSize
[LossInformation_Out,CM_Table,Gradients,State] = ...
            dlfeval(ModelLoss,DataStore,...
            Encoder,Decoder,Classifier,...
            LossInformation,WantUpdateLossPrior,WeightKL_Anneal);
else
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
    for bidx = 1:NumBatches
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
end
end

