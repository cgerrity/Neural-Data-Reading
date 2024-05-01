function Prediction = cgg_getRandomPrediction(ClassNames)
%CGG_GETRANDOMPREDICTION Summary of this function goes here
%   Detailed explanation goes here

QuaddleDimMax=3; % Maximum dimensionality of the quaddles
QuaddleDimMin=1; % Minimum dimensionality of the quaddles

NumDimension=length(ClassNames);

Prediction=NaN(1,NumDimension);

IncreaseFeatures=true;
DecreaseFeatures=true;

while IncreaseFeatures||DecreaseFeatures

    for fdidx=1:NumDimension
    this_Classes=ClassNames{fdidx};
    NumClasses=length(this_Classes);
    
    Prediction(fdidx)=this_Classes(randi(NumClasses));
    end
    
    if NumDimension==4
    QuaddleCheck=~(Prediction==[0,0,0,0]);
    NumDim=sum(QuaddleCheck);
    
    DecreaseFeatures=NumDim>QuaddleDimMax;
    IncreaseFeatures=NumDim<QuaddleDimMin;
    else
        IncreaseFeatures=false;
        DecreaseFeatures=false;
    end

end

end

