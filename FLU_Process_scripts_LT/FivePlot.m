
function FivePlot(data, sem, smoothSize, varargin)

for i = 1:5
    data(:,i) = smooth(data(:,i),smoothSize);
    sem(:,i) = smooth(sem(:,i),smoothSize);
end
% figure, hold on, plot(data(:,1),'k-');
% hold on, plot(data(:,2),'r-');
% hold on, plot(data(:,3),'b-');
% hold on, plot(data(:,4),'m-');
% hold on, plot(data(:,5),'g-');
% legend({'All', 'AS','AN','SS','SN'})
out = zeros(1,5);
figure, hold on, 
tmp = shadedErrorBar(1:size(data,1),data(:,1),sem(:,1),'k-',1);
out(1) = tmp.mainLine;
tmp = shadedErrorBar(1:size(data,1),data(:,2),sem(:,2),'r-',1);
out(2) = tmp.mainLine;
tmp = shadedErrorBar(1:size(data,1),data(:,3),sem(:,3),'b-',1);
out(3) = tmp.mainLine;
tmp = shadedErrorBar(1:size(data,1),data(:,4),sem(:,4),'m-',1);
out(4) = tmp.mainLine;
tmp = shadedErrorBar(1:size(data,1),data(:,5),sem(:,5),'g-',1);
out(5) = tmp.mainLine;
legend(out, {'All', 'AS','AN','SS','SN'})

if length(varargin) > 1
    xlabel(varargin{1});
    ylabel(varargin{2});
    title(varargin{3});
end