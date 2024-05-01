function cgg_displayValidationProgressClassifier(data,monitor)
%CGG_DISPLAYVALIDATIONPROGRESSCLASSIFIER Summary of this function goes here
%   Detailed explanation goes here


lossValidation = data(1);
accuracyValidation = data(2);
iteration = data(3);

recordMetrics(monitor,iteration, ...
    ValidationLoss=lossValidation, ...
    ValidationAccuracy=accuracyValidation);

drawnow;

end

