% ----- prepare trial

disp( '******************************' )
fprintf('BLOCK %d/%d, TRIAL %d/%d\n',BLOCK,n.blocks,trial,n.trialsBlock);


lastSample = 0;
sampleIDX = zeros(1,NumberOfScans);
nseg = 0;

disp('waiting for trig.trial...')
while ~ismember( io64(trig.io.obj, trig.io.address(1)), trig.trial ); end
rt.trigger(TRIAL) = io64(trig.io.obj, trig.io.address(1));


trialCond = floor(rt.trigger(TRIAL)/10);
targetLoc = mod(rt.trigger(TRIAL),10);

disp('connected... ')
fprintf('Condition: %s, Cued position: %s\n',str.trialType{trialCond+1},str.loc{targetLoc});

tic
while true
    % ---- read from the ring buffer
    nSamples = readBufferSamples( cfg.host, cfg.port.stream );
    
    if lastSample == nSamples
        continue
    else
        lastSample = nSamples;
        sampleIDX = max(sampleIDX) + 1 : max(sampleIDX) + NumberOfScans;
    end
    
    if max( sampleIDX ) <= nx.trial
      
        rt.data(sampleIDX,:,TRIAL) = readBufferData( [nSamples-NumberOfScans+1 nSamples]-1, cfg.host, cfg.port.stream);
        
        % ---- real time analysis
        
        if max( sampleIDX ) >= rt.idxSeg(1,2) && nseg < n.seg % first end index
            
            nseg = nseg+1;
            
            % ------ get last second of data
            timeidx = rt.idxSeg(nseg,1):rt.idxSeg(nseg,2);
            EEG = rt.data(timeidx,idx.channelsOI,TRIAL);
            EEG = detrend(EEG,'linear');
            EEG(:,range(EEG)>200) = NaN; % remove artefacts
            
            % FFT
            AMP = abs(fft(EEG,nx.seg));
            AMP = AMP(1:length(freq.seg),:)./nx.seg;
            AMP(2:end-1,:) = 2*AMP(2:end-1,:); % correction of the DC & Nyquist component
            
            AMP = reshape(AMP(idx.freqSeg',:),n.Hz,N.channelsOIPlayer,N.players); % hz x channel x player
            
            rt.amp(nseg,:,TRIAL,:) = squeeze(mean(AMP,2,'omitnan')); % average across channels
           
            if TRIAL > n.trialsBlock % test
                for P = 1:N.players
                    for HH = 1:n.Hz     
                        rt.percentile(nseg,HH,TRIAL,P) = sum( rt.distribution(:,HH,P) < rt.amp(nseg,HH,TRIAL,P) ) / n.samples * 100;
                    end
                    
                    for COMBO = 1:n.axis                      
                        rt.selectivity(nseg,COMBO,TRIAL,P) = rt.percentile(nseg,COMBO,TRIAL,P)-rt.percentile(nseg,COMBO+2,TRIAL,P);
                    end
                    
                end
                
                feedbackSig = squeeze(rt.selectivity(nseg,:,TRIAL,:)); % axis x player
                feedbackSig(abs(feedbackSig) <= threshold) = 0; % deadzone
                if trialCond == 2 % joint
                    feedbackSig = repmat(mean(feedbackSig,2,'omitnan'),1,2);
                end
                
                feedbackSig(isnan(feedbackSig)) = 0;
                
                rt.feedbackSig(nseg,:,TRIAL,:) = feedbackSig;
                hdr.buf = single( feedbackSig )';
                buffer('put_dat', hdr, cfg.host, cfg.port.unity ) 
            end
        end
  
    else % end of trial   
        tmp = readBufferData( [nSamples-NumberOfScans+1 nSamples]-1, cfg.host, cfg.port.stream );
        rt.data(min(sampleIDX):end,:,TRIAL) = tmp(1:nx.trial - min(sampleIDX) + 1,:);
    end
    
    % ----- look for stop trigger
    if  io64(trig.io.obj, trig.io.address(1)) == trig.stopAnalysis % stop signal
        rt.break(TRIAL) = min(max(sampleIDX),nx.trial);
        rt.breakSeg(TRIAL) = nseg;
        break
    end
end
rt.trialLen(TRIAL) = toc;