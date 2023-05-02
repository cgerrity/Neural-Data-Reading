clear
clc

N=2^18;
x=randn(1,N);

% get signal parameters for filtering:
sp=get_signal_parameters(...
    'sampling_rate',1000,... % sampling rate
    'number_points_time_domain',length(x));

% make saccade accl filter g
clear g
  g.center_frequency=30; % Hz
  g.fractional_bandwidth=1;
  g.chirp_rate=0;
  g=make_chirplet(...
      'chirplet_structure',g,...
      'signal_parameters',sp);

target=-imag(g.time_domain);  
fig=figure;
%plot(g.ptime,abs(g.time_domain),':k');
%hold on;
plot(g.ptime,target,'k');
hold off;
xlabel('Time (sec)');

% make synthetic signal with target embedded num_sac times
num_sac=100;
raw=zeros(1,1000);
for n=1:num_sac
    disp(n)
    fix_dur=500+randi(500,1,1);
    fixation=zeros(1,fix_dur);
    raw=[raw fixation target];
end
raw(sp.number_points_time_domain)=0;

figure;
inds=1:30000;
plot(sp.time_support(inds),raw(inds));
  
% filter to find sacc times
fsignal=gabor_filter(raw,sp.sampling_rate,g.center_frequency,g.fractional_bandwidth);
trace=abs(fsignal);

figure;
inds=1:5000;
tt=sp.time_support(inds);
praw=raw(inds);
ptrace=trace(inds);
plot(tt,praw,'r');
hold on;
plot(tt,ptrace,'k');
hold off;


