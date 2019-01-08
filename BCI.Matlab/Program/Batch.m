clear
clc
close all

addpath('..\Program\function')
addpath('..\Program\stats')

direct.main = '..\';
direct.group = [direct.main 'Group\'];dataFolder = '..\Data\';
list = ls([dataFolder 'S*']);

load('common.mat')
nPair = size(list,1);

%% Configuration
cfg.output = [direct.main '\Analysis\GroupAnalysis\'];
GD_LoHi = NaN(nPair,2);
GD_Baseline_FFT = NaN(nPair,length(freq.trial),n.Hz,N.players);
GD_Baseline_STFT = NaN(nPair,length(freq.seg),n.Hz,N.players);
GD_Baseline_idxBest = NaN(nPair,n.Hz,N.players);
GD_Baseline_SNR = NaN(nPair,n.Hz,N.players);
GD_Baseline_Head = NaN(nPair,n.Hz,N.channelPlayer,N.players);

GD_Baseline_Accuracy = NaN(nPair,n.Hz,N.players+1);

nTrial = n.testTrials/n.taskType/n.targetLoc;
GD_Test_success = NaN(nPair,nTrial,n.targetLoc,N.players+1);
GD_Test_time = NaN(nPair,nTrial,n.targetLoc,N.players+1);
GD_Test_dist = NaN(nPair,nTrial,n.targetLoc,N.players+1);
GD_Test_trajectory = cell(nPair,nTrial,n.targetLoc,N.players+1);
GD_Test_rotatedtrajectory = cell(nPair,nTrial,n.targetLoc,N.players+1);
    
GD_Test_d2t = NaN(nPair,nTrial,n.targetLoc,N.players+1);
GD_Test_d2l = NaN(nPair,nTrial,n.targetLoc,N.players+1);
GD_Test_connectivityR = NaN(nPair,nTrial,n.targetLoc,N.players+1);
GD_Test_connectivityP = NaN(nPair,nTrial,n.targetLoc,N.players+1);
%% For Loop
for PAIR = 1:nPair
    % PAIR
    dataFile = [dataFolder list(PAIR,:) '\' list(PAIR,:) '.realtime.mat'];
    disp('*************************')
    disp(['Pair ' num2str(PAIR)])
    load(dataFile,'rt','baseline','tra','trialM')
    
    %% Group Data
    disp('------- saving baseline data for group analysis --------')
    
    if mean(baseline.SNR(:,1)) > mean(baseline.SNR(:,2))
        LoHi = [ 2 1 ];
    else
        LoHi = [ 1 2 ];
    end
    % Baseline
    GD_LoHi(PAIR,:) = LoHi;
    GD_Baseline_FFT(PAIR,:,:,:) = baseline.FFT;
    GD_Baseline_STFT(PAIR,:,:,:) = baseline.STFT;
    GD_Baseline_idxBest(PAIR,:,:) = baseline.idxBest;
    GD_Baseline_SNR(PAIR,:,:) = baseline.SNR(:,LoHi);
    GD_Baseline_Head(PAIR,:,:,:) = baseline.head;
    
    GD_Baseline_Accuracy(PAIR,:,:) = baseline.accuracy(:,[LoHi 3]);
    
    % Trajectory
    trialFrame = (s.movement-s.seg) * 144 + 1;
    d2t = NaN(trialFrame,n.testTrials,N.players);
    d2l = NaN(trialFrame,n.testTrials,N.players);
    for TRIAL = 1:n.testTrials
        for P = 1:N.players
            TRA = tra.rotatedXY{TRIAL,P};
            nDP = size(TRA,2);
            d2t(1:nDP,TRIAL,P) = sqrt((TRA(1,:) - loc.R).^2 + TRA(2,:).^2);
            d2l(1:nDP,TRIAL,P) = abs(TRA(2,:));
        end
    end
    
    d2t = squeeze(mean(d2t,1,'omitnan'));
    d2l = squeeze(sqrt(mean(d2l.^2,1,'omitnan')));
    % Connectivity
    
    trialConnectivityR = NaN(n.testTrials,1);
    trialConnectivityP = NaN(n.testTrials,1);
    
    FS = fs/NumberOfScans; % sampling rate for selectivity scores
    trialLen = min(trialM(:,[T.time1,T.time2]),[],2);
    trialSeg = floor((trialLen - s.seg) .* FS);
    
    for TRIAL = 1:n.testTrials
        
        tmp = squeeze(rt.selectivity(1:trialSeg(TRIAL),:,TRIAL+n.trialsBlock,:)); % seg x dimension x player
        
        dat = squeeze(tmp(:,1,:)) + 1i*squeeze(tmp(:,2,:)); % construct velocity vectors (seg x player)
        dat(any(isnan(dat), 2), :) = []; % remove nan
        
        ang_dat = angle(dat); % get movement direction
        [trialConnectivityR(TRIAL),trialConnectivityP(TRIAL)] = circ_corrcc(ang_dat(:,1), ang_dat(:,2));
    end
    % Test - Behaviour
    disp('------- saving test data for group analysis --------')
    
    task = trialM(:,T.taskType);
    target = trialM(:,T.targetLoc);
      
    for ii = 1:N.players+1
        % Success Rate
        if ii < 3
            TASK = 1;
            P = LoHi(ii);
        else
            TASK = 2;
            P = 1;
        end
        
        for jj = 1:n.targetLoc
            LOC = 2*jj;
            trial2use = task==TASK & target==LOC;
            
            GD_Test_success(PAIR,:,jj,ii) = trialM(trial2use,T.(['success' num2str(P)]));
            GD_Test_time(PAIR,:,jj,ii) = trialM(trial2use,T.(['time' num2str(P)]));
            GD_Test_dist(PAIR,:,jj,ii) = trialM(trial2use,T.(['distance' num2str(P)]));
            
            GD_Test_trajectory(PAIR,:,jj,ii) = tra.XY(trial2use,P);
            GD_Test_rotatedtrajectory(PAIR,:,jj,ii) = tra.rotatedXY(trial2use,P);
            GD_Test_d2t(PAIR,:,jj,ii) = d2t(trial2use,P);
            GD_Test_d2l(PAIR,:,jj,ii) = d2l(trial2use,P);
            
            GD_Test_connectivityR(PAIR,:,jj,ii) = trialConnectivityR(trial2use);
            GD_Test_connectivityP(PAIR,:,jj,ii) = trialConnectivityP(trial2use);
        end
    end    
end

%%
save([cfg.output 'group_data.mat'],'GD*')
disp('done')