function BackwardCurvesFLU_GL(data, dv)

subplot(3,1,1)
errorbar(data.(dv).D2.Mean, data.(dv).D2.SEM);
hold on
errorbar(data.(dv).D5.Mean, data.(dv).D5.SEM);
legend({'D2', 'D5'}, 'location', 'best')
ylabel(dv)
xticks([1 6 11 16 21])
xticklabels({'-10', '-5', '0', '5', '10'})
xlabel('Trials from LP')

subplot(3,1,2)

errorbar(data.(dv).Positive.Mean, data.(dv).Positive.SEM);
hold on
errorbar(data.(dv).Negative.Mean, data.(dv).Negative.SEM);
errorbar(data.(dv).Neutral.Mean, data.(dv).Neutral.SEM);
legend({'Positive', 'Negative', 'Neutral'}, 'location', 'best')
ylabel(dv)
xticks([1 6 11 16 21])
xticklabels({'-10', '-5', '0', '5', '10'})
xlabel('Trials from LP')

subplot(3,1,3)
errorbar(data.(dv).D2_Pos.Mean, data.(dv).D2_Pos.SEM);
hold on
errorbar(data.(dv).D2_Neg.Mean, data.(dv).D2_Neg.SEM);
errorbar(data.(dv).D2_Neut.Mean, data.(dv).D2_Neut.SEM);
errorbar(data.(dv).D5_Pos.Mean, data.(dv).D5_Pos.SEM);
errorbar(data.(dv).D5_Neg.Mean, data.(dv).D5_Neg.SEM);
errorbar(data.(dv).D5_Neut.Mean, data.(dv).D5_Neut.SEM);
legend({'D2-Positive', 'D2-Negative', 'D2-Neutral', 'D5-Positive', 'D5-Negative', 'D5-Neutral'}, 'location', 'best')
ylabel(dv)
xticks([1 6 11 16 21])
xticklabels({'-10', '-5', '0', '5', '10'})
xlabel('Trials from LP')