%% Read CSV Files
formatSpec = '%s';
nHeader = 12;

FNAME = [direct.data experiment.session '.trialMatrix.csv'];
fid = fopen(FNAME,'r');
header = textscan(fid, formatSpec, nHeader,'Delimiter',',');
fclose(fid);
trialHeader = header{1};
trialMatrix = csvread(FNAME,1,0); % skip header line

for FF = 1:nHeader
    T.(trialHeader{FF}) = FF;
end

nHeader = 16;

FNAME = [direct.data experiment.session '.frameMatrix.csv'];
fid = fopen(FNAME,'r');
header = textscan(fid, formatSpec, nHeader,'Delimiter',',');
fclose(fid);
frameHeader = header{1};
fullFrame = csvread(FNAME,1,0); % skip header line

for FF = 1:nHeader
    F.(frameHeader{FF}) = FF;
end

%% Extract trial data from frameMatrix
frameMatrix = cell(n.trials,1);

for TRIAL = 1:n.trials
    line2use = fullFrame(:,F.trial) == TRIAL & fullFrame(:,F.state) == state.Trial; 
    frameMatrix{TRIAL} = fullFrame(line2use,:);
end

trialM = trialMatrix(n.trialsBlock+1:end,:); % only test trials
task = trialM(:,T.taskType);
solo_success = sum(trialM(task==1,[T.success1 T.success2]));

clear FNAME fid header lineSpec line2use nHeader formatSpec TRIAL FF fullFrame frameHeader trialHeader
disp('got performance data.')