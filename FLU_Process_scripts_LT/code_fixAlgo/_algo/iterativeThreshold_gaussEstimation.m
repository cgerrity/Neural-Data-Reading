function varargout = iterativeThreshold_gaussEstimation(x,initThresh,err,alph,maxIter)
% thresh = iterativeThreshold_gaussEstimation(x)
% thresh = iterativeThreshold_gaussEstimation(x,initThresh)
% thresh = iterativeThreshold_gaussEstimation(x,initThresh,err)
% thresh = iterativeThreshold_gaussEstimation(x,initThresh,err,alph)
% thresh = iterativeThreshold_gaussEstimation(x,initThresh,err,alph,maxIter)
% [thresh,threshHist] = iterativeThreshold_gaussEstimation(...)
%
% threshold for "outlier" detection by estimating mean/std of background
% activity
%
% Reference:
% Charupanit, Lopour. 2017. A Simple Statistical Method for the Automatic Detection
% of Ripples in Human Intracranial EEG. Brain Topography
%
% Ben Voloh, 2018

%check inputs
if nargin <2 || isempty(initThresh)
    initThresh = max(abs(x));
end
if nargin <3 || isempty(err)
    err = abs(max(x)-min(x))*0.001;
end
if nargin <4 || isempty(alph)
    alph = 0.001;
end
if nargin < 5
    maxIter = [];
end
if nargout > 1
    storeThreshHist = 1;
    threshHist = [];
else
    storeThreshHist = 0;
end

%iterative thresh detection
xx = linspace(min(x)*3, max(x)*3,5000);
thresh = initThresh;
currErr = err*2;
icount=0;
while currErr > err
    if storeThreshHist
        threshHist(numel(threshHist)+1,1) = thresh;
    end
    
    %estimate the gaussian with the data below the threshold
    tmp = x( abs(x) < thresh );
    [mu,sd] = normfit(tmp); 
    p = normcdf(xx,mu,sd);
    cump = 1-p;
    newThresh = xx( find(cump<alph/2,1) ); %assumning 2-tailed, thefore take a half of the alpha

    %update threshold
    currErr = abs(newThresh - thresh);
    thresh = newThresh;
    
    % iteration count
    icount=icount+1;
    if ~isempty(maxIter) && icount >= maxIter
        warning('reached maximum iteration but did not converge')
        currErr = err*2;
        thresh = nan;
    end
end

%plot results
if 0
    lim=get(gca,'xlim');
    t = linspace(lim(1),lim(2),2000);
    y=normpdf(t,mu,sd);
    figure
    [N,C]=hist(x,1000);
    N = N./trapz(C,N);
    
    bar(C,N)
    hold all
    plot(t,y,'r-','linewidth',1)
    set_bigfig(gcf,[0.7 0.7])
    plotcueline('x',[-thresh,thresh])

    pause
    close(gcf)
end

%output
varargout{1} = thresh;
if nargout>1
    varargout{2} = threshHist;
end