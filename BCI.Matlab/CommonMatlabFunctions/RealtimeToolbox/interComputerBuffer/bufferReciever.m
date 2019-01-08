clear
close all
clc

%% directories

direct.bufferDRP = 'bufferDRP\';
direct.realtime_hack = 'realtimeHack.10.11.17\';

addpath( direct.bufferDRP )
addpath( direct.realtime_hack )%%

cfg.host = '10.36.73.241';
cfg.port = 2017;

NumberOfScans = 1;
fs = 1200;

%% ----- read from the ring buffer

lastSample = NaN;
sampleIDX = (1:NumberOfScans) - NumberOfScans*ones( 1, NumberOfScans );

while true
    
    nSamples = readBufferSamples( cfg );
    
    if lastSample == nSamples % prevent reading same data twice (not sure if necessary)
        continue
    else
        lastSample = nSamples;
        sampleIDX = sampleIDX + NumberOfScans*ones( 1, NumberOfScans );
        
        tmp = readBufferData( [nSamples-NumberOfScans+1 nSamples]-1, cfg );
        
        disp(tmp)
        
    end
    
   
    
end


%%


%%
