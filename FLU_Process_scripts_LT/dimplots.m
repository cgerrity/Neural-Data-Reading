
figure
subplot(1,2,1)
errorbar(fluData.Acc.D2.TrialInBlock.Mean(1:30), fluData.Acc.D2.TrialInBlock.SEM(1:30))
hold on
errorbar(fluData.Acc.D5.TrialInBlock.Mean(1:30), fluData.Acc.D5.TrialInBlock.SEM(1:30))
set(gca, 'fontsize', 18)
xlabel('Trial In Block')
ylabel('Accuracy')
legend({'D2', 'D5'}, 'location', 'best');


% subplot(2,2,2)
% errorbar(fluData.ReachTime.D2.TrialInBlock.Mean(1:30), fluData.ReachTime.D2.TrialInBlock.SEM(1:30))
% hold on
% errorbar(fluData.ReachTime.D5.TrialInBlock.Mean(1:30), fluData.ReachTime.D5.TrialInBlock.SEM(1:30))
% set(gca, 'fontsize', 18)
% xlabel('Trial In Block')
% ylabel('Reach Time (s)')
% 
% 
% subplot(2,2,3)
% errorbar(fluData.TotalFixations.D2.TrialInBlock.Mean(1:30), fluData.TotalFixations.D2.TrialInBlock.SEM(1:30))
% hold on
% errorbar(fluData.TotalFixations.D5.TrialInBlock.Mean(1:30), fluData.TotalFixations.D5.TrialInBlock.SEM(1:30))
% set(gca, 'fontsize', 18)
% xlabel('Trial In Block')
% ylabel('Total Fixations')


subplot(1,2,2)
errorbar(fluData.ChosenBias.D2.TrialInBlock.Mean(1:30), fluData.ChosenBias.D2.TrialInBlock.SEM(1:30))
hold on
errorbar([0 fluData.ChosenBias.D5.TrialInBlock.Mean(2:30)], fluData.ChosenBias.D5.TrialInBlock.SEM(1:30))
set(gca, 'fontsize', 18)
xlabel('Trial In Block')
ylabel('Chosen Fixation Bias')
ylim([-0.2 0.4])

