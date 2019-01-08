disp('------- fetching behavioural data from Unity --------')
GetPerformance

%% Fliptime
fliptime = cellfun(@(x) diff(x(:,F.time)),frameMatrix,'UniformOutput',false);

TIT = [ experiment.session '.fliptime' ];
h = figure('visible',options.visible);

fliptime = cell2mat(fliptime);
fliptime = fliptime*1000;

subplot(2,1,1)
plot(fliptime)
title(TIT)
ylabel('Fliptime (ms)')
xlabel('Frames')

subplot(2,1,2)
histogram(fliptime,'normalization','probability');
ylabel('Probability')
xlabel('Fliptime (ms)')

saveas(h, [ direct.results TIT '.png' ] )
close(h)
%% Behavioural
disp('------- post-experiment analysis --------')
acc = struct('tbl',cell(N.players,1));
t2t = struct('h',cell(N.players,1));
d2t = struct('h',cell(N.players,1));

TIT = [ experiment.session '.accuracy.test' ];
[h,p] = SuperTitle(TIT,options.visible);
for P = 1:N.players
    % ---- accuracy (acc)
    success = trialM(:,T.(['success' num2str(P)]));
    [acc(P).tbl,acc(P).chi2,acc(P).p] = crosstab(task,success);
    acc(P).label = horzcat(str.taskType,{'miss';'hit'});
    
    % plot
    
    subplot(N.players,3,(P-1)*3+1,'Parent',p);
    bb = bar(acc(P).tbl(:,2)./(n.testTrials/n.taskType)*100,'FaceColor',colour.player(P,:),'EdgeColor',[.5 .5 .5]);
    bb.FaceColor = 'flat';
    bb.CData(2,:) = colour.player(3,:);
    ylabel('hit target (percent)')
    ylim([0 100])
    xticklabels(str.taskType)
    title(sprintf('Success rate by task type (%s)',str.player{P}))
    
    % ---- time to target for successful trials (t2t)
    success = logical(success);
    v1 = task(success);
    v2 = trialM(success,T.(['time' num2str(P)]));
    
    if ~all(v1) && any(v1)
        [t2t(P).r,t2t(P).h,t2t(P).p,t2t(P).ci] = pointbiserial(v1,v2);
    end
    % plot
    subplot(N.players,3,(P-1)*3+2,'Parent',p);
    boxplot(v2,v1,'ColorGroup',v1,'Color',colour.player([P,3],:))
    ylabel('Time (s)')
    ylim([2 21])
    xticklabels(str.taskType)
    title(sprintf('Time to target in successful trials (%s)',str.player{P}))
    
    % ---- distance to target for unsuccessful trials (d2t)
    v1 = task(~success);
    v2 = trialM(~success,T.(['distance' num2str(P)]));
    if ~all(v1) && any(v1)
        [d2t(P).r,d2t(P).h,d2t(P).p,d2t(P).ci] = pointbiserial(v1,v2);
    end
    
    % plot
    subplot(N.players,3,(P-1)*3+3,'Parent',p);
    boxplot(v2,v1,'ColorGroup',v1,'Color',colour.player([P,3],:))
    ylabel('Distance')
    ylim([0 40])
    xticklabels(str.taskType)
    title(sprintf('Distance to target in unsuccessful trials (%s)',str.player{P}))
end

saveas(h, [ direct.results TIT '.png' ] )
close(h)

%% Trajectory
mon.ref = 144;
Len = floor((s.movement-1)*mon.ref)+1;
tra.X = NaN(n.testTrials/n.targetLoc/n.taskType,Len,n.taskType,n.targetLoc,N.players);
tra.Y = NaN(n.testTrials/n.targetLoc/n.taskType,Len,n.taskType,n.targetLoc,N.players);
tra.avg = NaN(2,Len,n.taskType,N.players);
tra.mse = NaN(n.taskType,N.players); % Root Mean Squared Error/n
tra.trialMSE = NaN(n.testTrials/n.targetLoc/n.taskType,n.taskType,n.targetLoc,N.players);

for P = 1:N.players
    for TASK = 1:n.taskType
        tmpTra = NaN(2,Len,n.testTrials/n.targetLoc/n.taskType,n.targetLoc);
        for jj = 1:n.targetLoc
            LOC = idx.targetLoc(jj);
            trial2use = find(rt.trigger==TASK*10+LOC);
            
            theta = 2*pi-loc.TH(LOC);
            rotateM = [cos(theta) -sin(theta); sin(theta) cos(theta)];
            
            for TRIAL = 1:length(trial2use)
                temp = frameMatrix{trial2use(TRIAL)};
                x = temp(mon.ref:end-1,F.(['x' num2str(P)]));
                y = temp(mon.ref:end-1,F.(['y' num2str(P)]));
                if length(x) > Len
                    tra.X(TRIAL,:,TASK,jj,P) = x(1:Len);
                    tra.Y(TRIAL,:,TASK,jj,P) = y(1:Len);
                else
                    tra.X(TRIAL,:,TASK,jj,P) = vertcat(x,ones(Len-length(x),1)*x(end));
                    tra.Y(TRIAL,:,TASK,jj,P) = vertcat(y,ones(Len-length(y),1)*y(end));
                end
                temp2 = vertcat(tra.X(TRIAL,:,TASK,jj,P),tra.Y(TRIAL,:,TASK,jj,P));
                
                tmpTra(:,:,TRIAL,jj) = rotateM * temp2;
            end
        end
        tmpTra = reshape(tmpTra,2,Len,n.testTrials/n.taskType);
        tmpTra(2,:,:) = abs(tmpTra(2,:,:));
        tra.avg(:,:,TASK,P) = mean(tmpTra,3,'omitnan');
        tra.mse(TASK,P) = mean((tra.avg(2,:,TASK,P)).^2);
    end
end
%% Plot
TIT = [ experiment.session '.trajectory.test' ];
[h,p] = SuperTitle(TIT,options.visible);

for P = 1:N.players
    for TASK = idx.taskType
        subplot(N.players,n.taskType,(P-1)*n.taskType + TASK,'Parent',p);
        title([str.player{P} ', ' str.taskType{TASK}])
        xlim([-35 35])
        ylim([-35 35])
        pbaspect([1 1 1])
        hold on
        
        for jj = 1:n.targetLoc
            LOC = idx.targetLoc(jj);
            xc = loc.x(LOC);
            yc = loc.y(LOC);
            rr = 5;
            xx = rr*sin(-pi:0.1*pi:pi) + xc;
            yy = rr*cos(-pi:0.1*pi:pi) + yc;
            plot(xx, yy,'Color',colour.loc(jj,:),'LineWidth',2,'LineStyle','--')
            trial2use = find(rt.trigger==TASK*10+LOC);
            for TRIAL = 1:length(trial2use)
                x = tra.X(TRIAL,:,TASK,jj);
                y = tra.Y(TRIAL,:,TASK,jj);
                plot(x,y,'Color',colour.loc(jj,:))
            end
        end
    end
end
saveas(h, [ direct.results TIT '.png' ] )
close(h)
%%
TIT = [ experiment.session '.avgtrajectory.test' ];
h = figure('Visible',options.visible);
hold on
for P = 1:N.players+1
    if P < N.players+1
        xx = tra.avg(1,:,1,P);
        yy = tra.avg(2,:,1,P);
    else
        xx = tra.avg(1,:,2,1);
        yy = tra.avg(2,:,2,1);
    end
    
    plot(xx,yy,'Color',colour.player(P,:),'LineWidth',2)
end
xlabel('X (unit)')
ylabel('Y (unit)')
legend({'P1-Solo';'P2-Solo';'Joint'})
title(TIT)

saveas(h, [ direct.results TIT '.png' ] )
close(h)

%% Connectivity
success = any(trialM(:,[T.success1,T.success2]),2);
connectivity.circcorr = NaN(n.testTrials,1);
connectivity.MI = NaN(n.testTrials,1);
connectivity.trialLen = min(trialM(:,[T.time1,T.time2]),[],2);
connectivity.trialNx = round(connectivity.trialLen .* fs);
connectivity.trialSeg = round((connectivity.trialLen-1).*(fs/NumberOfScans));

%% ----- Selectivity and circular correlation
for TRIAL = 1:n.testTrials
    tmp = squeeze(rt.selectivity(1:connectivity.trialSeg(TRIAL),:,TRIAL+n.trialsBlock,:)); % seg x dimension x player
    dat = squeeze(tmp(:,1,:)) + 1i*squeeze(tmp(:,2,:)); % construct velocity vectors
    ang_dat = angle(dat); % get movement direction
    ang_dat(any(isnan(ang_dat), 2), :) = [];
    tmpcorr = circ_corrcc(ang_dat(:,1), ang_dat(:,2));
    % adjust for trial length (normalisation via permutation)
    connectivity.circcorr(TRIAL) = tmpcorr;
end
TIT = [ experiment.session '.circular_correlation.test' ];
[h,p] = SuperTitle(TIT,options.visible);

subplot(1,2,1,'Parent',p);
boxplot(connectivity.circcorr,task,'Colors','br');
title('Correlation by Task')
ylabel('Circular correlation coefficient')
xticklabels(str.taskType)

subplot(1,2,2,'Parent',p);
boxplot(connectivity.circcorr(task==2),success(task==2),'Colors','k')
title('Correlation of Joint Task by Success')
xticklabels({'Unsuccessful';'Successful'})

saveas(h, [ direct.results TIT '.png' ] )
close(h)

%% Baseline Evaluation
baseline.head = NaN(n.Hz,N.channelPlayer,N.players);
baseline.FFT = NaN(length(freq.trial),n.Hz,N.players);
baseline.STFT = NaN(length(freq.seg),n.Hz,N.players);
baseline.idxBest = NaN(n.Hz,N.players);
baseline.SNR = NaN(n.Hz,N.players);

amp = NaN(length(freq.seg),N.players,n.seg-2*fs/NumberOfScans,n.trialsBlock);
for TRIAL = 1:n.trialsBlock
    
    for nseg = 1:n.seg-2*fs/NumberOfScans
        SEG = round(nseg + fs/NumberOfScans);
        % ------ get last second of data
        timeidx = rt.idxSeg(SEG,1):rt.idxSeg(SEG,2);
        EEG = rt.data(timeidx,idx.channelsOI,TRIAL);
        EEG = detrend(EEG,'linear');
        EEG(:,range(EEG)>200) = NaN;
        
        % FFT
        AMP = abs(fft(EEG,nx.seg));
        AMP = AMP(1:length(freq.seg),:)./nx.seg;
        AMP(2:end-1,:) = 2*AMP(2:end-1,:); % correction of the DC & Nyquist component
        AMP = reshape(AMP,length(freq.seg),N.channelsOIPlayer,N.players);
        AMP = squeeze(mean(AMP,2,'omitnan'));
        
        amp(:,:,nseg,TRIAL) = AMP;
    end
end

amp = squeeze(mean(amp,3,'omitnan'));

for HH = 1:n.Hz
    trial2use = rt.trigger == 2*HH-1;
    baseline.STFT(:,HH,:) = mean(amp(:,:,trial2use),3,'omitnan');
end

for P = 1:N.players
    % ERP
    for HH = 1:n.Hz
        foi = idx.freqTrial(HH,1);
        trial2use = rt.trigger == trig.trial(1,2*HH-1);
        
        % ----- erp
        erp = mean( rt.data(:,idx.channelPlayer(:,P),trial2use), 3,'omitnan'); % pnts x channel
        erp(~any(~isnan(erp),2),:) = 0; % remove all NaN rows
        erp = detrend(erp,'linear');
        % ----- FFT
        amp = abs( fft(erp, nx.trial) )./nx.trial;
        amp = amp(1:length(freq.trial),:);
        amp(2:end-1,:) = amp(2:end-1,:)*2;
        
        % ----- get results of interest
        baseline.head(HH,:,P) = amp(foi,:);
        % SNR for each channel
        signal = 2 * n.noise * amp(foi,:);
        noise = sum(amp(foi+[-n.noise:-1,+1:n.noise],:));
        [~,yy] = sort((signal./noise).^2, 'descend');
        yy = yy(yy<5);
        baseline.idxBest(HH,P) = yy(1);
        baseline.FFT(:,HH,P) = amp(:, baseline.idxBest(HH,P));
        baseline.SNR(HH,P) = rt.snr(baseline.idxBest(HH,P),HH,P);
    end
end

if mean(baseline.SNR(:,1)) > mean(baseline.SNR(:,2))
    baseline.LoHi = [2 1];
else
    baseline.LoHi = [1 2];
end
