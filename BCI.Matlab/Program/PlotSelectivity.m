restoredefaultpath;
addpath 'C:\Users\labpc\Desktop\Engine2'
CloseMaster
AddDirectories
load('recordingSettings.mat')
SetupPort
SetupVariables
%%
fs = 1200;
s = 1;
NumberOfScans = s*fs;
freq = (0:fs-1)/s;

FFT.xLimit = [1 30];
FFT.yLimit = [0 40];
%% Figure settings
TIT = 'Real-Time Signal';
picsize = [0.15 0.1 0.7 0.8];
f = figure('WindowStyle','normal','Units','normalized','Position',picsize);
p = uipanel('Parent',f,'BorderType','none');
p.Title = TIT;
p.TitlePosition = 'centertop';
p.FontSize = 14;
p.FontName = 'Arial';
p.FontWeight = 'bold';
% ---- FFT
ax1 = axes(p,'Position',[0.08,0.55,0.85,0.4]);
grid(ax1,'on')
ax1.Title.String = 'FFT';
ax1.XLabel.String = 'Frequency (Hz)';
ax1.YLabel.String = 'Amplitude (\muV)';
ax1.XLimMode = 'manual';
ax1.XLim = FFT.xLimit;
ax1.YLimMode = 'manual';
ax1.YLim = FFT.yLimit;
ax1.XTick = sort(Hz.fundamental);
ax1.NextPlot = 'replacechildren';
% ---- Selectivity
ax2 = polaraxes(p,'Position',[0.05,0.05,0.4,0.4]);
ax2.Title.String ='Selectivity';
ax2.ThetaTick = [0 90 180 270];
ax2.ThetaTickLabel = str.Hz;
ax2.RTick = max(threshold(:));
ax2.RLimMode = 'manual';
ax2.RLim = [0 100];
theta = [0 0 pi/2 pi/2];
ax2.NextPlot = 'replacechildren';
% ---- Direction
ax3 = polaraxes(p,'Position',[0.55,0.05,0.4,0.4]);
ax3.Title.String ='Direction';
ax3.ThetaTick = 0:45:315;
ax3.ThetaTickLabel = str.loc;
ax3.RTick = [];
ax3.RLim = [0 1.1];
ax3.NextPlot = 'replacechildren';
%% Loop
lastSample = 0;
while true
    % FFT
    try
        nSamples = readBufferSamples( cfg.host, cfg.port.stream );
        EEG = readBufferData( [nSamples-NumberOfScans+1 nSamples]-1, cfg.host, cfg.port.stream);
    catch 
    end

    EEG = EEG(:,1:end-1);
    EEG = detrend(EEG,'linear');
    AMP = abs(fft(EEG,NumberOfScans))./NumberOfScans;
    AMP(2:end-1,:) = 2*AMP(2:end-1,:);
    plot(ax1,freq,AMP)
    drawnow
    % Selectivity
    try
        nSamples2 = readBufferSamples( cfg.host, cfg.port.feedback );
        if lastSample == nSamples2
            continue
        else
            lastSample = nSamples2;
            feedbackSig = readBufferData( [nSamples2-1 nSamples2]-1, cfg.host, cfg.port.feedback);
        end
    catch
        feedbackSig = zeros( 2, N.players );
    end
 
    feedbackSig(isnan(feedbackSig)) = 0;
    cla(ax2)
    hold(ax2,'on')
    for P = 1:N.players
        polarplot(ax2,theta,[0, feedbackSig(1,P),0, feedbackSig(2,P)],'LineWidth',6-P*2)
    end
    
    % Direction
    direction = zeros(2,N.players);
    cla(ax3)
    hold(ax3,'on')
    for D = 1:2
        direction(D,feedbackSig(D,:) > threshold) = 1;
        direction(D,feedbackSig(D,:) < -threshold) = -1;
    end
    for P = 1:N.players
        if any(direction(:,P))
            TH = wrapTo2Pi(atan2(direction(2,P),direction(1,P)));
            polarplot(ax3,[TH TH],[0,1],'LineWidth',6-P*2)
        end
    end
    drawnow
end