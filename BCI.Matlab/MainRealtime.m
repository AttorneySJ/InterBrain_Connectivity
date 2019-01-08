%% initialise experiment
restoredefaultpath;
input('press enter')

% clear everything
fclose all;
close all
clear mex
clear
clc

% set seed state
reset(RandStream.getGlobalStream,sum(100*clock))
seed_state = rng;

% add directories
direct.main = [ cd '\' ];
direct.data = [direct.main 'Data\'];
direct.results = [direct.main 'Results\'];
mkdir(direct.data);
mkdir(direct.results);

direct.toolbox = [direct.main 'CommonMatlabFunctions\RealtimeToolbox\'];
direct.buffer = [ direct.toolbox 'interComputerBuffer\realtimeBuffer\'];
direct.io64 =   [ direct.toolbox  'io64\'];
direct.hat = [ direct.toolbox 'hat\' ];
direct.topo = [direct.toolbox 'gtecTopo\'];

addpath(genpath(direct.main))
%% load settings

load('recordingSettings.mat') % fs = 1200 Hz; Number of scans = 8
load('experiment.mat','experiment') % information about the current session

disp(['******* Experiment Session: ' experiment.session ' *******'])
%% setup
SetupCurrentExperiment
SetupVariables
SetupTiming
SetupPort

%% pre-allocate variables
rt.data = NaN(nx.trial,N.channels2acquire,n.trials);
rt.trigger = NaN(n.trials,1);
rt.amp = NaN(n.seg,n.Hz,n.trials,N.players);

% baseline
rt.distribution = NaN(n.samples,n.Hz,N.players);
rt.snr = NaN(N.channelsOIPlayer,n.Hz,N.players);
rt.idxBest = NaN(N.channelsOIPlayer,n.Hz,N.players);

% test
rt.break = ones(n.trials,1)*nx.trial;
rt.breakSeg = ones(n.trials,1)*n.seg;
rt.percentile = NaN( n.seg, n.Hz, n.trials, N.players );
rt.selectivity = NaN( n.seg, n.axis, n.trials, N.players);
rt.feedbackSig = NaN(n.seg, n.axis, n.trials, N.players);

%% timing
rt.trialLen = NaN(n.trials,1);

%% feedback buffer
hdr = startBuffer( direct, cfg.host, cfg.port.unity, N.players, n.axis, 0, 9 ); % single precision

%% run trials!
io64(trig.io.obj, trig.io.address(1), 0)
for TRIAL = 1:n.trials
    BLOCK = ceil(TRIAL/n.trialsBlock);
    trial = TRIAL - (BLOCK-1)*n.trialsBlock;
    if trial == 1
        disp('----------------------')
        disp( 'waiting for trig.initAnalysis...' )
        readNreset(trig,trig.initAnalysis)
    end

    TrialRunner

    if TRIAL == n.trialsBlock
        BaselineAnalysis
    end
    io64(trig.io.obj, trig.io.address(1), 0); % ----- send signal to continue
end

disp( 'waiting for Unity saving performance data...' )
while io64(trig.io.obj, trig.io.address(1))~=trig.initAnalysis;end

disp( 'stopping data acquisition...' )
io64(trig.io.obj, trig.io.address(1), trig.stopRecording)

experiment.clock{2} = clock;
PostExperimentAnalysis

%% save EEG
disp('------- saving realtime data -------')
tic;
save( [ direct.data experiment.session '.realtime.mat' ],'baseline', 'direct', 'experiment', ...
    'rt','seed_state','trialM','connectivity','tra');
toc

disp('done!')
