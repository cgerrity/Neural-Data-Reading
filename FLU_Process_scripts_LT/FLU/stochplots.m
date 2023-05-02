

subplot(2,2,1)
errorbar(fluData.Acc.o15.TrialInBlock.Mean(1:30), fluData.Acc.o15.TrialInBlock.SEM(1:30))
hold on
errorbar(fluData.Acc.o30.TrialInBlock.Mean(1:30), fluData.Acc.o30.TrialInBlock.SEM(1:30))
set(gca, 'fontsize', 18)
xlabel('Trial In Block')
ylabel('Accuracy')

legend({'0.15', '0.30'}, 'location', 'best');

subplot(2,2,2)
errorbar(fluData.ReachTime.o15.TrialInBlock.Mean(1:30), fluData.ReachTime.o15.TrialInBlock.SEM(1:30))
hold on
errorbar(fluData.ReachTime.o30.TrialInBlock.Mean(1:30), fluData.ReachTime.o30.TrialInBlock.SEM(1:30))
set(gca, 'fontsize', 18)
xlabel('Trial In Block')
ylabel('Reach Time (s)')


subplot(2,2,3)
errorbar(fluData.TotalFixations.o15.TrialInBlock.Mean(1:30), fluData.TotalFixations.o15.TrialInBlock.SEM(1:30))
hold on
errorbar(fluData.TotalFixations.o30.TrialInBlock.Mean(1:30), fluData.TotalFixations.o30.TrialInBlock.SEM(1:30))
set(gca, 'fontsize', 18)
xlabel('Trial In Block')
ylabel('Total Fixations')


subplot(2,2,4)
errorbar(fluData.ChosenBias.o15.TrialInBlock.Mean(1:30), fluData.ChosenBias.o15.TrialInBlock.SEM(1:30))
hold on
errorbar(fluData.ChosenBias.o30.TrialInBlock.Mean(1:30), fluData.ChosenBias.o30.TrialInBlock.SEM(1:30))
set(gca, 'fontsize', 18)
xlabel('Trial In Block')
ylabel('Chosen Fixation Bias')

