%% Key variables stored in common.mat

% fs: sampling frequency (1200 Hz)
% NumberOfScans: buffering block size

% N: Numbers related to recording settings
    % elec: number of electrodes per device
    % connected_devices: number of connected devices
    % channelsacquire: number of total channels acquired (including trigger
    % channel)
    % players: number of participants recorded simutaneously
    % channelPlayer: number of channels per participant
    % channelsOIPlayer: number of channels of interest per participant (O1,Oz,O2,POz)
    % channelsOI: total number of channels of interest
    % amplifiers: number of amplifiers in the lab
    % gUSBampChannels: maximal number of channels available per amplifier

% n: Numbers related to the experiment design
    % taskType: solo and joint
    % Hz: fundmental frequencies (7Hz, 11Hz, 5Hz, 9Hz)
    % checkerboardPos: checkerboard positions (right, top, left, bottom)
    % axis: horizontal and vertical
    % targetLoc: target locations (upper right, upper left, lower right, lower left)
    
    % blocks: number of blocks (1 baseline block + 10 test blocks)
    % rep: number of repetition for each condition within one block
    % trialsCond: total number of trials for each condition
    % trialsBlock: number of trials per block
    % trials: total number of trials
    % testTrials: number of test trials
    % seg: maximum number of segments per trial
    
% s: time in seconds
% idx: indexes
% trig: trigger number for communication via the parallel trigger
% t: time vectors
% str: name of the variables

%% Key variables stored in individual datafiles (PairXX.realtime.mat)
% baseline: baseline data
    % accuracy: baseline classification accuracy [4 checkerboard positions (right,up,left,bottom) x 3 BCI
    % control types (P1 Solo,P2 Solo,Joint)]
    % head: amplitude (4 checkboard positions x 7 channels x 2 players)
    % FFT: trial FFT amplitude (frequencies x 4 checkerboard positions x 2 players)
    % STFT: short-time Fourier transform amplitude (frequencies x 4 checkerboard positions x 2 players)
    % LoHi: [1 2] if P1 has lower SNR, [2 1] if P1 has higher SNR
    % idxBest: channel index sorted by SNR (4 channels of interest x 2 players)
    % SNR: channel SNR (4 channels of interest x 2 players)

% rt: real-time data
    % data: real-time EEG data (time points x all channels including trigger channel x trials)
    % trigger: trial trigger
    % amp: real-time STFT amplitude (segments x frequencies of interest x trials x players)
    % distribution: baseline amplitude distribution (samples x frequencies of interest x player)
    % break: trial break time points
    % percentile: the percentile scores for each frequency of interest (segments x frequencies of interest x
    % trials x players)
    % selectivity: the selectivity scores for each axis (segments x axes x trials x players)
    % feedbackSig: feedback signals sent to Unity after thresholding (segments x axes x trials x players)

% trialM: performance information in test trials fetched from Unity
    % each column represents one variable, each row represents one trial
    % column1: trial number
    % column2: block number
    % column3: task type (1 = solo 2 = joint)
    % column4: target location (2 = upper right, 4 = upper left, 6 = lower left, 8 = lower right)
    % column5: start time
    % column6: end time
    % column7 & 10: P1 & P2 trial performance (1 = success, 0 = failure)
    % column8 & 11: P1 & P2 movement time (in seconds)
    % column9 & 12: P1 & P2 final distance to target (in metres)

% tra: frame by frame trajectory
    % XY: actual trajectory (trial x player)
    % rotatedXY: trajectory after being rotated to fall on the x axis
    % trialRMSE: trajectory dispersion
