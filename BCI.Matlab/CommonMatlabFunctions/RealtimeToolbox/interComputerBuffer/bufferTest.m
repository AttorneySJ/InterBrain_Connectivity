close all
clear
clc


%% directories

direct.bufferDRP = 'bufferDRP\';
direct.realtime_hack = 'realtimeHack.10.11.17\';

addpath( direct.bufferDRP )
addpath( direct.realtime_hack )


%% buffer settings

cfg.host = '10.36.73.240';
cfg.port= 2017;

% cfg.host = '192.168.56.1';
% cfg.port = 9999;

N.channels2acquire = 6;
NumberOfScans = 1;
fs = 1200;


%% EEG broadcast buffer!

!taskkill /F /IM buffer.exe /T
!taskkill /F /IM cmd.exe /T

hdr = startBuffer( direct, cfg, N.channels2acquire, NumberOfScans, fs, 9 ); % single precision


%% send some data



for DD = 1:inf
    
    data = single( rand( NumberOfScans, N.channels2acquire ) );

    % ----- put data in ring buffer
    hdr.buf = data';
    buffer( 'put_dat', hdr, cfg.host, cfg.port )

    disp( data )

end





