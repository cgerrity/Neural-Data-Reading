function ForwardCurvesFLU(data, dv)

subplot(3,1,1)
errorbar(data.(dv).D2.Mean, data.(dv).D2.SEM);
hold on
errorbar(data.(dv).D5.Mean, data.(dv).D5.SEM);
legend({'D2', 'D5'}, 'location', 'best')
ylabel(dv)
xticks([5 10 15 20])
xlabel('Trial in Block')

subplot(3,1,2)

errorbar(data.(dv).P85.Mean, data.(dv).P85.SEM);
hold on
errorbar(data.(dv).P70.Mean, data.(dv).P70.SEM);
legend({'P85', 'P70'}, 'location', 'best')
ylabel(dv)
xticks([5 10 15 20])
xlabel('Trial in Block')

subplot(3,1,3)
errorbar(data.(dv).P85_D2.Mean, data.(dv).P85_D2.SEM);
hold on
errorbar(data.(dv).P85_D5.Mean, data.(dv).P85_D5.SEM);
errorbar(data.(dv).P70_D2.Mean, data.(dv).P70_D2.SEM);
errorbar(data.(dv).P70_D5.Mean, data.(dv).P70_D5.SEM);
legend({'P85-D2', 'P85-D5', 'P70-D2', 'P70-D5'}, 'location', 'best')
ylabel(dv)
xticks([5 10 15 20])
xlabel('Trial in Block')