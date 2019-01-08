CloseMaster
AddDirectories
SetupPort

load('recordingSettings.mat');
channelLabel = [ str.chan {'Trigger'} str.chan ];

%% dsp.TimeScope (based on N.amplifiers)

scope.nChannels = N.channels2acquire;

scope.s = 10;
scope.fs = fs;
scope.x = scope.s*fs;

scope.LayoutDimensions = [ ceil(scope.nChannels/2) 2 ];
scope.LayoutDimensions = [ N.channels2acquire 1 ];

scope.chanIDX = cell( 1, N.amplifiers );
scope.handle = cell( 1, N.amplifiers );
scope.command = cell( 1, N.amplifiers );

scope.handle = dsp.TimeScope(	scope.nChannels, scope.fs, 'BufferLength', scope.x, 'TimeAxisLabels', 'Bottom', ...
                                'TimeSpan', scope.s, 'LayoutDimensions', scope.LayoutDimensions, ...
                                'ReduceUpdates', true, 'SampleRate', scope.fs, 'TimeAxisLabels', 'none', 'Name', 'EEG', ...
                                'TimeSpanOverrunAction', 'Wrap', 'AxesScaling', 'Manual' );

scope.chanIDX = 1 : scope.nChannels;

for CC = scope.chanIDX

    if CC == max(scope.chanIDX) % trigger
        yLimit = [ 0 255 ];
    else
        yLimit = [0 255];
    end

    set( scope.handle, 'ActiveDisplay', CC, 'YLabel', channelLabel{CC}, 'AxesScaling', 'Manual', 'ShowGrid', false, 'YLimits', yLimit )

    if CC == min( scope.chanIDX )
        scope.command = 'step( scope.handle, ';
    end

    if CC == max( scope.chanIDX )
        scope.command = [ scope.command 'data(:,' num2str(CC) ') );' ];
    else
        scope.command = [ scope.command 'data(:,' num2str(CC) '), ' ];
    end

end


%% get data stream

DATA = [];
sampleIDX = NaN;

%%

while true
    %----- read from the ring buffer

    try
        nSamples = readBufferSamples(  cfg.host, cfg.port.stream  );
    catch
        continue
    end


    if sampleIDX == nSamples
       continue
    else
        sampleIDX = nSamples;
    end

    try
       data = readBufferData( [nSamples-NumberOfScans+1 nSamples]-1, cfg.host, cfg.port.stream );
    catch

    end

   % data = [ data(:,1:N.elec) data(:,end) data(:,N.elec+1:end-1) ];


%     plot(data(:,1))
%     drawnow

    eval( scope.command )
end
