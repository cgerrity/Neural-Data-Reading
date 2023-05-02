function PlotForwardCurveData_FLU(forwardCurveData, dv, acc)

subplot(2,1,1)
ForwardCurveSubPlot(forwardCurveData.(dv), acc, 'P85', 'P70')
legend({'P85', 'P70'}, 'location', 'best');
subplot(2,1,2)
ForwardCurveSubPlot(forwardCurveData.(dv), acc, 'D2', 'D5')
legend({'D2', 'D5'}, 'location', 'best');


function ForwardCurveSubPlot(data, acc, c1, c2)

errorbar(data.(c1).(acc).Mean, data.(c1).(acc).SEM);
hold on
errorbar(data.(c2).(acc).Mean, data.(c2).(acc).SEM);
xlabel('Trial In Block')
