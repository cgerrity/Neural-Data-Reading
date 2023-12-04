function cgg_plotImportanceAnalysis(Difference_Accuracy,DecoderType,InSavePlotCFG)
%CGG_PLOTIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here


X_Name_Size=18;
Y_Name_Size=18;
Title_Size=24;

Label_Size=14;

Tick_Size=8;

want_rotate=false;
want_rescale=true;

%%

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order = cfg_param.Probe_Order;

Probe_Order=replace(Probe_Order,'_',' ');

%%
fig_activity=figure;
fig_activity.WindowState='maximized';
fig_activity.PaperSize=[4 10.5];

figure(fig_activity);
    
clf(fig_activity);

[NumChannels,NumProbes,NumFolds] = size(Difference_Accuracy);

if NumFolds>1
Difference_Accuracy = mean(Difference_Accuracy,3);
end

if want_rescale
Difference_Accuracy=Difference_Accuracy*1000;
end

Z_Lower=abs(min(Difference_Accuracy(:)));
Z_Upper=abs(max(Difference_Accuracy(:)));

Abs_Z=max([Z_Lower,Z_Upper]);

Z_Lower=-Abs_Z;
Z_Upper=Abs_Z;

%%

if want_rotate
    imagesc(1:NumChannels,1:NumProbes,Difference_Accuracy');
    daspect([1 1 1]);
else
    imagesc(1:NumProbes,1:NumChannels,Difference_Accuracy);
    fig_activity.CurrentAxes.YDir='normal';
    daspect([1 2 1]);
end

fig_activity.CurrentAxes.XDir='normal';
fig_activity.CurrentAxes.XAxis.TickLength=[0,0];
fig_activity.CurrentAxes.YAxis.TickLength=[0,0];
fig_activity.CurrentAxes.XAxis.FontSize=Label_Size;
fig_activity.CurrentAxes.YAxis.FontSize=Label_Size;
% fig_activity.CurrentAxes.XAxis.Exponent
view(2);
c = colorbar('vert','FontSize',Label_Size,'Direction','reverse');
colormap(flipud(parula))
if want_rescale
c.Label.String = 'Change in Accuracy (x1000)';
else
c.Label.String = 'Change in Accuracy';
end
c.Label.Rotation = 270;
c.Label.FontSize = Y_Name_Size;
% clim([Z_Lower,Z_Upper]);



%%

title('Importance Analysis','FontSize',Title_Size);

if want_rotate
yticks(1:NumProbes);
yticklabels(Probe_Order);
ylabel('Probe Area','FontSize',X_Name_Size);
xlabel('Channel Number','FontSize',Y_Name_Size);
xticks([1,Tick_Size:Tick_Size:NumChannels]);
else
xticks(1:NumProbes);
xticklabels(Probe_Order);
xtickangle(45);
xlabel('Probe Area','FontSize',X_Name_Size);
ylabel('Channel Number','FontSize',Y_Name_Size);
yticks([1,Tick_Size:Tick_Size:NumChannels]);
end


%%

this_figure_save_name=[InSavePlotCFG.path filesep sprintf('Importance_Analysis_%s',DecoderType)];

saveas(fig_activity,this_figure_save_name,'pdf');

close all

end

