function out = compare_classification(trueLabels,testLabels,eventID,plotConfusionMatrix,eventLabels)
% out = compare_classification(trueLabels,testLabels,eventID,plotConfusionMatrix)
% out = compare_classification(trueLabels,testLabels,eventID,plotConfusionMatrix,eventLabels)

%% settings
if ~isrow(trueLabels); trueLabels = trueLabels'; end
if ~isrow(testLabels); testLabels = testLabels'; end

if nargin < 3 || isempty(eventID)
    eventID = unique([trueLabels,testLabel]);
end

if nargin < 5
    eventLabels = {};
    for il=1:numel(eventID)
        eventLabels{il} = num2str(eventID);
    end
end

nevt = numel(eventID);

%% downsample
del = isnan(trueLabels) | isnan(testLabels);
trueLabels(del) = [];
testLabels(del) = [];

%% sensitivity/ specificty
sensitivity = nan(nevt,1);
specificity = nan(nevt,1);
accuracy = nan(nevt,1);
ppv = nan(nevt,1);
npv = nan(nevt,1);
for iv=1:nevt
    ievent = eventID(iv);
    
    % performance
    tp = sum( trueLabels==ievent & testLabels==ievent );
    fp = sum( trueLabels~=ievent & testLabels==ievent );
    tn = sum( trueLabels~=ievent & testLabels~=ievent );
    fn = sum( trueLabels==ievent & testLabels~=ievent );

    sensitivity(ievent) = tp/(tp+fn);
    specificity(ievent) = tn/(tn+fp);
    accuracy(ievent) = (tp+tn) ./ (tp+tn+fp+fn);
    ppv(ievent) = tp ./ (tp+fp);
    npv(ievent) = tn ./ (tn+fn);
    str = sprintf('**** %s\nsensitivity = %.3g\nspecificty = %.3g\naccuracy = %.3g',...
        eventLabels{ievent},sensitivity(ievent),specificity(ievent),accuracy(ievent));
    disp(str)
end


%% confusion matrix
sel = true(size(trueLabels));
trueLabels2 = trueLabels(sel);
testLabels2 = testLabels(sel);

c = zeros(numel(eventID));
for ii=1:numel(eventID)
    for jj=1:numel(eventID)
        sel = trueLabels2==eventID(ii) & testLabels2==eventID(jj);
        c(ii,jj) = sum(sel);
    end
end

%normalize
dim = 2;
c_norm = bsxfun(@rdivide, c,sum(c,dim));


%% cohen's Kappa

outk = kappa(c,0,0.05,0);



%% output
out = [];
out.confusion = c;
out.confusion_norm = c_norm;
out.label = eventLabels;
out.sensitivity = sensitivity;
out.specificity = specificity;
out.accuracy = accuracy;
out.ppv = ppv;
out.npv = npv;
out.cohenk = outk;

%plot
if plotConfusionMatrix
    mask = c~=0;
    figure
    imagesc(c_norm,'alphadata',mask)
    colorbar
    set(gca,'fontsize',14,'xtick',eventID,'xticklabel',eventLabels, 'ytick',eventID,'yticklabel',eventLabels)
    xlabel('test')
    ylabel('true')
    title('confusion matrix')
    
    %overlay counts
    for ii=1:size(c,1)
        for jj=1:size(c,2)
            text(jj,ii,num2str(c(ii,jj)))
        end
    end
end

