%% Players and Channels
N.players = 2;
N.channelPlayer = (N.channels2acquire-1)/N.players;
N.channelsOIPlayer = 4;

str.player = cell(N.players,1);
idx.channelPlayer = NaN(N.channelPlayer,N.players);
idx.channelsOIPlayer = NaN(N.channelsOIPlayer,N.players);

for P = 1:N.players
    str.player{P} = ['P' num2str(P)];
    idx.channelPlayer(:,P) = (1:N.channelPlayer) + (P-1)*N.channelPlayer;
    idx.channelsOIPlayer(:,P) = (1:N.channelsOIPlayer) + (P-1)*N.channelPlayer;
end

N.channelsOI = N.channelsOIPlayer * N.players;
idx.channelsOI = idx.channelsOIPlayer(:);

str.control = {'Low SNR';'High SNR';'Joint'};
%% Conditions
% stimuli frequencies
Hz.fundamental = [7 11 5 9]; % right, top, left, bottom
n.Hz = length(Hz.fundamental);
str.Hz = sprintfc('%1dHz',Hz.fundamental);

str.axis = {'Horizontal','Vertical'};
n.axis = length(str.axis);
% checkboard position
str.checkerboardPos = {'Right' 'Top' 'Left' 'Bottom'};
n.checkerboardPos = length( str.checkerboardPos );

% trial type
str.trialType = {'Baseline';'Solo';'Joint'};
n.trialType = length( str.trialType );

% task type
str.taskType = {'Solo';'Joint'};
n.taskType = length( str.taskType );

% locations
str.loc = {'Right';'UR';'Top';'UL';'Left';'LL';'Bottom';'LR'};
n.loc = length( str.loc );
loc.R = 30;
loc.TH = linspace(0,2*pi,n.loc+1);
loc.TH = loc.TH(1:end-1);
loc.x = loc.R .* cos(loc.TH);
loc.y = loc.R .* sin(loc.TH);
loc.minD = 5; % criticalDistance

%% threshold
threshold = 18;

%% Triggers
trig.trial = [1:n.loc;(1:n.loc)+10;(1:n.loc)+20];
state.BlockRest = 0;
state.Inactive = 1;
state.TrialRest = 2;
state.Trial = 3;
state.Feedback = 4;

%% Colours
colour.player = [150 150 150; 150 150 150; 40 40 40]./255; % High SNR,Low SNR,joint
colour.hz = NaN(3,3,n.axis);
colour.hz(:,:,1) = [0 114 178;0 114 178;200 200 200]./255; % right,left,deadzone
colour.hz(:,:,2) = [213 94 0;213 94 0;200 200 200]./255; % top,bottom,deadzone
colour.flicker = [0 114 178;213 94 0;0 114 178;213 94 0]./255; % right,up,left,down
colour.loc = [230,159,0;86,180,233;240,228,66;204,121,167]./255; % NE, NW, SW, SE

%% Block Structure
n.blocks = 11; % 1 baseline block + 10 test blocks
n.rep = 4; % each condition will be repeated 4 times in each block

idx.targetLoc = [2 4 6 8]; % 4 potential target locations (upper/lower right/left)
n.targetLoc = length(idx.targetLoc);

n.trialsBlock = n.rep*length(idx.targetLoc); % number of trials per block
n.trials = n.trialsBlock * n.blocks; % total number of trials (including baseline)
n.testTrials = n.trialsBlock * (n.blocks-1); % total number of test trials

n.trialsCond = n.testTrials/n.taskType/n.targetLoc; % number of trials under each condition (task type x target location)