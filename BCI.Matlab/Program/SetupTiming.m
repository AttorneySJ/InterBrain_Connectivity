%% Trial Timing
% rest(task cue & target) --> movement --> feedback
s.rest = 1;
s.training = 20;
s.movement = 20; % maximum movement time per trial
s.feedback = 1;
s.trial = s.training;

%% Segment
s.seg = 1; 
s.interval = NumberOfScans/fs;

% Time points
FIELDS = fieldnames(s);
for FF = 1:length(FIELDS)
    nx.( FIELDS {FF} ) = round( s.( FIELDS {FF} ) * fs );    
end
clear FIELDS FF

% Time vector
t.preMove = (-(nx.rest)+1:0)' ./fs;
t.postMove = (1 : nx.training)' ./fs;
t.trial = [t.preMove; t.postMove];
t.seg = (0 : nx.seg-1)' ./ fs;

% segment time points for short-time Fourier transform
beginidx = 1 : nx.interval : nx.movement - nx.seg +1;
n.seg = length(beginidx);
rt.idxSeg = NaN(n.seg,2); % stat/stop
rt.idxSeg(:,1) = beginidx;
rt.idxSeg(:,2) = beginidx + nx.seg - 1;
clear beginidx

rt.movetimes = t.trial(rt.idxSeg(:,2)); % end time point of each segment 

% STFT parameters
freq.seg = (0:nx.seg/2)'*fs/nx.seg; % frequency resolution = 1 Hz, range = 0-600 Hz

% Trial FFT parameters (training)
freq.trial = (0:nx.training/2)'*fs/nx.training; % frequency resolution = 0.05 Hz, range = 0-600 Hz
n.noise = 2; % half of the number of surrounding frequencies to use for estimating SNR

% get the index of fundamental frequencies in the two frequency vectors
idx.freqSeg = dsearchn( freq.seg, Hz.fundamental');
idx.freqTrial = dsearchn( freq.trial, Hz.fundamental');
