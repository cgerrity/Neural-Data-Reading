function varargout = resample_time(t1,f1,f2)
% t2 = resample_time(t1,f1,f2)
% 
% Resamples time "t1" from sampling frequncy "f1" to "f2". Does this by
% factorizxing sampling frequencies f1 and f2 and looking for common 
% points to interpolate between. 
% - Accounts for noise and drift in time by iteratively loooking for next
% nearest time point


% % f1 = 120;
% % f2 = 1000;
% % 
% % t1 = 0:1/f1:5/f1;
% % r = rand(1,numel(t1));
% % %t1 = t1 + cumsum(r)./numel(r); %add random drift

fcom = gcd(f1,f2); % common factor
if fcom==1
    error('greatest common denomitor is 1')
end

%use multiples of the gcd as reference points
ttmp = t1;
t2 = [];

%nsmp = f2/f+1;
st = ttmp(1);
flag = 1;
waypoints = st;
while flag && numel(ttmp)>1
    %find next (multiple) of common point
    %[~,ii] = min( abs( mod(ttmp(2:end) - st,1/fcom*10^3) ) );
    %    ii = ii+1;
    d = diff( abs( mod(ttmp - ttmp(1),1/fcom*10^3) ) );
    ii = find(d<0,1);
    if isempty(ii); ii = numel(ttmp); end
    fn = ttmp(ii);
    
    %adjust the finish time to account for (1) noisy sampling, and (2)
    %possible short segments at the end
    lim = [st,fn];
    nsmp = round(diff(lim)*f2) + 1;
    fn = st + (nsmp-1)/f2;
    lim = [st,fn]; %update
    
    %interpolate time between last and next common points
    if ii~=numel(t1) %fn>st
        % add the new warped segment
        ind = linspace(1,ii,nsmp);
        seg = interp1([1,ii],lim,ind);
        if st>t1(1); seg = seg(2:end); end % dont include teh same point twice
        %seg = seg(1:end-1);
        t2 = [t2,seg];
        
        %update
        waypoints = [waypoints,fn];

        st = fn;
        ttmp = ttmp(ii:end);
    else
        flag = 0;
    end
end

% % % what is the avergae error?
% % ttmp2 = t2;
% % dtmp = nan(size(t1));
% % for ii=1:numel(t1)
% %    a = t1(ii);
% %    [~,imn] = min(abs(ttmp2-a));
% %    dtmp(ii) = ttmp2(imn)-a;
% %    ttmp2(1:imn) = []; %make it run faster
% % end
% % mu = nanmean(dtmp);
% % se = nanstd(dtmp) ./ sqrt(numel(dtmp));
% % disp('error in interpolated time, %.5g +/- %.5g SE',mu,se)

%output
if isrow(t1) ~= isrow(t2); t2 = t2'; end

varargout{1} = t2;
if nargout>1; varargout{2} = waypoints; end