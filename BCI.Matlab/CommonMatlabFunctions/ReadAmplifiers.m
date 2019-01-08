%% clean up

if exist( 'gds_interface', 'var' ) % turn off if running
    try
        gds_interface.StopDataAcquisition();
    catch
    end
    delete( gds_interface ); clear gds_interface;
end

input('press enter')

fclose all;
close all
clear mex
clear
clc

% set seed state
reset(RandStream.getGlobalStream,sum(100*clock))
seed_state = rng;

% add directories
cd ../
direct.main = [ cd '\' ];
cd([direct.main 'CommonMatlabFunctions\']);
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


%% options
options.ResetBuffers = 1;
options.WaitStart = 1; % set to true if running feedback main
options.SaveEEG = 1;

%% setups
SetupPort
SetupExperiment

%% Configure Amplifier settings

RecordingSettings
save( 'recordingSettings.mat', 'fs', 'NumberOfScans', 'idx', 'N', 'str','options' )


%% EEG broadcast buffer!

if options.ResetBuffers
    
    !taskkill /F /IM buffer.exe /T
    !taskkill /F /IM cmd.exe /T
    
end

hdr = startBuffer( direct, cfg.host, cfg.port.stream, N.channels2acquire, NumberOfScans, fs, 9 ); % single precision


%% start acquisition

disp('starting aquisition...')
tic; gds_interface.StartDataAcquisition(); toc


%% ----- Start Experiment

if options.WaitStart
    
    disp( 'waiting for trig.startRecording...' )
    
    while io64( trig.io.obj, trig.io.address(1) ) ~= trig.startRecording
        [scans_received, data] = gds_interface.GetData( NumberOfScans ); % read to prevent buffer overflow
    end
    
    io64( trig.io.obj, trig.io.address(1), 0 ) % reset
    
end


%%

disp('connected!')
disp('collecting, saving & transmitting data...');

while true
    
    [scans_received, data] = gds_interface.GetData( NumberOfScans ); % size of data reflects the number of synchronized amplifiers
    switch N.connected_devices
        case 1
            data2send = data;
        case 2
            data2send = data(:,[1:N.elec, end-N.elec:end-1,N.elec+1]); %reorganise data to ensure trigger channel is in the last column
    end
    if options.photodiode
        try
        nSamples = readBufferSamples( cfg.host, cfg.port.photodiode );
        EEG = readBufferData( [nSamples nSamples]-1, cfg.host, cfg.port.photodiode);
        catch
        end
        data2send(:,1:4) = EEG;
    end
    hdr.buf = single(data2send');
    
    % ----- put data in ring buffer
    buffer( 'put_dat', hdr, cfg.host, cfg.port.stream )
    
    % ----- write data to file
    if options.SaveEEG
        fwrite( fid, hdr.buf, 'float32' );
    end
    
    % ----- trig.stopRecording
    if io64( trig.io.obj, trig.io.address(1) ) == trig.stopRecording
        break
    end
    
end


%% stop acquisition

disp('stopping acquisition...')

tic
gds_interface.StopDataAcquisition();
delete(gds_interface);
clear gds_interface;

!taskkill /F /IM buffer.exe /T
!taskkill /F /IM cmd.exe /T
toc
beep; pause(.5);  beep


%% save experiment

if options.SaveEEG
    
    fclose(fid);
    fclose('all');
    
    experiment.clock{2} = clock;
    save( [experiment.direct experiment.session '.read.mat'] )
    
    
    %% open data
    
    fid = fopen( experiment.dataFile, 'rb');
    DATA2 = fread(fid, [N.channels2acquire inf], 'float32')';
    fclose(fid);
    
    
    %% plot
    
    figure;
    ax(1) = subplot(2,1,1);
    plot(DATA2(:,1:4))
    ax(2) = subplot(2,1,2);
    plot(DATA2(:,end))
    
    linkaxes(ax,'x')
    
end


disp('done!')
