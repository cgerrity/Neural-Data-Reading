function [Prediction] = cgg_getPredictionsFromNetOutput(TargetProbabilities,ClassNames)
%CGG_GETPREDICTIONSFROMNETOUTPUT Summary of this function goes here
%   Detailed explanation goes here

NumDimensions=length(TargetProbabilities);
[~,NumBatch,NumWindow]=size(TargetProbabilities{1});
%%

NumExamples=NumBatch*NumWindow;

Prediction=NaN(NumExamples,NumDimensions);
ClassConfidenceTMP=cell(1,NumDimensions);

for didx=1:NumDimensions

%     this_Y_Full=Y_Classification_Validation{didx};
%     this_Y=[];
%     for eidx=1:NumExamples
%         this_BatchIDX=IDX_Batch(eidx);
%         this_WindowIDX=IDX_Window(eidx);
%     this_Y_tmp=this_Y_Full(:,this_BatchIDX,this_WindowIDX);
%     this_Y=[this_Y,this_Y_tmp];
%     end

    this_Y=TargetProbabilities{didx};

this_Y_Decoded = onehotdecode(this_Y,ClassNames{didx},1);
this_Prediction=ClassNames{didx}(this_Y_Decoded(:));

Prediction(:,didx)=this_Prediction;

this_ClassConfidenceTMP=double(extractdata(this_Y));
this_ClassConfidenceTMP=this_ClassConfidenceTMP(:,:);
ClassConfidenceTMP{didx}=this_ClassConfidenceTMP;
end

%%

wantZeroFeatureDetector=false;

for eidx=1:NumExamples
    this_Prediction=Prediction(eidx,:);
    this_ClassConfidence=cellfun(@(x) x(:,eidx), ClassConfidenceTMP,"UniformOutput",false);

[this_Prediction] = cgg_procQuaddleInterpreter(this_Prediction,ClassNames,this_ClassConfidence,wantZeroFeatureDetector);
    Prediction(eidx,:)=this_Prediction;
end

end

