cfg = [];
cfg.resamplefs = 1000;
cfg.time       = [];
cfg.demean     = ft_getopt(cfg, 'demean',     'no');
cfg.feedback   = ft_getopt(cfg, 'feedback',   'text');

data = [];
nsmp = 10000;
data.fsample = 120;
data.trial = {rand(1,nsmp)};
data.time = {0:1/data.fsample:(nsmp-1)/data.fsample};

data2 = ft_resampledata_bv(cfg,data);

figure;
plot(data.time{1},data.trial{1},'*-')
hold all
plot(data2.time{1},data2.trial{1},'o-')
