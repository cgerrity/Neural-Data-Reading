function out = compare_gaze_classifier_human(subjectData,trackerType,plotConfusionMatrix)
% out = compare_gaze_classifier_human(subjectData,trackerType,plotConfusionMatrix)

%% load
if 0 
path = '/users/ben/desktop/prepare_test_datasets/_ben';
file = 'MonkeyGamesB_1_1__Subject1__13_06_2017__15_38_57__SubjectDataStruct.mat';

load([path '/' file])
end

[screenX,screenY,fsample] = get_experiment_parameters(trackerType);
    
%extract
dat = subjectData.ProcessedEyeData;
gaze = dat.GazeData;
t = gaze.EyetrackerTimestamp * 10^-6;
manclass = gaze.ManualClassification;
class = gaze.Classification;

%% downsample
%toi = [t(1), t(1)+60];
toi = [t(1)-1,t(1)-1]; %dont delet anything
del = t>=toi(1) & t<=toi(2);
del = del | isnan(manclass) | isnan(class);
manclass(del) = [];
class(del) = [];

%% sensitivity/ specificty
label = {'sac','pso','fix','sm','uncl','wierd'};
sensitivity = nan(4,1);
specificity = nan(4,1);
accuracy = nan(4,1);
ppv = nan(4,1);
npv = nan(4,1);
for ievent=1:4
    % performance
    tp = sum( manclass==ievent & class==ievent );
    fn = sum( manclass~=ievent & class==ievent );
    tn = sum( manclass~=ievent & class~=ievent );
    fp = sum( manclass==ievent & class~=ievent );

    sensitivity(ievent) = tp/(tp+fn);
    specificity(ievent) = tn/(tn+fp);
    accuracy(ievent) = (tp+tn) ./ (tp+tn+fp+fn);
    ppv(ievent) = tp ./ (tp+fp);
    npv(ievent) = tn ./ (tn+fn);
    str = sprintf('**** %s\nsensitivity = %.3g\nspecificty = %.3g\naccuracy = %.3g',...
        label{ievent},sensitivity(ievent),specificity(ievent),accuracy(ievent));
    disp(str)
end

%% cohen's Kappa

%% confusion matrix
sel = true(size(manclass));
manclass2 = manclass(sel);
class2 = class(sel);

%u = unique([manclass2,class2]);
%u(isnan(u)) = [];
evts = 1:4;

c = zeros(numel(evts));
for ii=1:numel(evts)
    for jj=1:numel(evts)
        sel = manclass2==evts(ii) & class2==evts(jj);
        c(ii,jj) = sum(sel);
    end
end

%normalize
dim = 2;
c_norm = bsxfun(@rdivide, c,sum(c,dim));

%output
out = [];
out.confusion = c;
out.confusion_norm = c_norm;
out.label = label;
out.sensitivity = sensitivity;
out.specificity = specificity;
out.accuracy = accuracy;
out.ppv = ppv;
out.npv = npv;

%plot
if plotConfusionMatrix
    mask = c~=0;
    figure
    imagesc(c_norm,'alphadata',mask)
    colorbar
    set(gca,'fontsize',14,'xtick',evts,'xticklabel',label(1:4), 'ytick',evts,'yticklabel',label(1:4))
    xlabel('algo')
    ylabel('human')
    title('gaze classification confusion matrix')
    
    %overlay counts
    for ii=1:size(c,1)
        for jj=1:size(c,2)
            text(jj,ii,num2str(c(ii,jj)))
        end
    end
    
end

