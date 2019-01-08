%% Parallel port
trig.io.obj = io64; % eeg trigger create an instance of the io32 object
trig.status = io64(trig.io.obj); % eeg trigger initialise the inpout32.dll system driver
trig.io.address = [hex2dec('2FF8'),hex2dec('21')]; % physical address of the destinatio I/O port; 378 is standard LPT1 output port address
io64(trig.io.obj, trig.io.address(1), 0); % set the trigger port to 0 - i.e. no trigger
io64(trig.io.obj, trig.io.address(2), 0); % set the trigger port to 0 - i.e. no trigger
trig.length = 5; % 3 ms long trigger


%% Triggers

trig.restTrial = 99;

trig.initAnalysis = 252;
trig.stopAnalysis = 253;

trig.startRecording = 254;
trig.stopRecording = 255;

%% Buffer
cfg.host = '127.0.0.1';
cfg.port.unity = 9999; % port to communicate with Unity
cfg.port.stream = 5555; % port to communicate between two Matlab sessions
