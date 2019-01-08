% Baseline Analysis
disp('Please wait for baseline analysis...')
%% Distribution
n.samples = n.trialsBlock * n.seg;
rt.distribution = reshape(permute(rt.amp(:,:,1:n.trialsBlock,:),[1 3 2 4]),n.samples,n.Hz,N.players);
%% Topoplot
load gtecChanlocs
idx.electrodeIDs = cellfun(@find,cellfun(@(x) strcmp(gtecChanlocs.labels,x),str.chan(1:N.channelsOIPlayer),'UniformOutput',false));

gtecChanlocs.labels = gtecChanlocs.labels( idx.electrodeIDs );
gtecChanlocs.x = gtecChanlocs.x( idx.electrodeIDs );
gtecChanlocs.y = gtecChanlocs.y( idx.electrodeIDs );

zoom.x = [681  1107];
zoom.y = [127  517];


%% Common variables

toi = rt.idxSeg(1,1):rt.idxSeg(end,2);
picsize = [0.15 0.1 0.7 0.8];
xx = -100:100;
Hz2use = true(1,n.Hz);

% Wavelet settings
freq.wavelet = min( Hz.fundamental ) - 2 : max(.2,1/s.training) : max( Hz.fundamental ) + 2;
ncycle = linspace(5,8,length(freq.wavelet));

for P = 1:N.players

    idxBest = NaN( n.Hz,N.channelsOIPlayer );
    amp2use = NaN( length(freq.trial),n.Hz );
    head = NaN(n.Hz,N.channelsOIPlayer);
    erp2use = NaN(nx.trial,n.Hz);
    tf = NaN(length(freq.wavelet),nx.trial,n.Hz);

    %% ERP

    for HH = 1:n.Hz
        foi = idx.freqTrial(HH);
        trial2use = rt.trigger == trig.trial(1,2*HH-1);
        if ~any(trial2use)
            Hz2use(HH) = false;
            continue
        end

        % ----- erp
        erp = mean( rt.data(:,idx.channelsOIPlayer(:,P),trial2use), 3,'omitnan'); % pnts x channel
        erp(~any(~isnan(erp),2),:) = 0; % remove all NaN rows
        erp = detrend(erp,'linear');
        % ----- FFT
        amp = abs( fft(erp, nx.trial) )./nx.trial;
        amp = amp(1:length(freq.trial),:);
        amp(2:end-1,:) = amp(2:end-1,:)*2;

        % ----- get results of interest
        head(HH,:) = amp(foi,:);

        % SNR for each channel
        signal = 2 * n.noise * amp(foi,:);
        noise = sum(amp(foi+[-n.noise:-1,+1:n.noise],:));
        rt.snr(:,HH,P) = (signal./noise).^2;
        [~,yy] = sort(rt.snr(:,HH,P), 'descend');
        rt.idxBest(:,HH,P) = yy( 1:N.channelsOIPlayer );

        erp2use(:,HH) = mean( erp(:, rt.idxBest(:,HH,P)), 2); % average across best channels
        amp2use(:,HH) = mean( amp(:, rt.idxBest(:,HH,P)), 2);

        % wavelet convolution
        complex_dat = wavelet_sj( erp2use(:,HH),freq.wavelet, ncycle, fs);
        tf(:,:,HH) = abs(complex_dat);
    end

    % Plotting
    for HH = find(Hz2use)
        TIT = [ experiment.session '.' str.player{P} '.' str.Hz{HH} '.baseline' ];
        col2use = colour.hz(ceil(HH/2),:,2-mod(HH,2));
        [h,p] = SuperTitle(TIT,options.visible);
        if HH < 3
            FREQ = [HH,HH+2];
        else
            FREQ = [HH,HH-2];
        end

        % ---- topoplot
        for fi = 1:2
            subplot(4,2,fi,'Parent',p);
            title( [ num2str( Hz.fundamental(FREQ(fi)) ) ' Hz' ] )
            try
                gtecTopo( head(FREQ(fi),:), gtecChanlocs, 'on', rt.idxBest(:,FREQ(fi)), flipud(colormap('hot')), [ min( head(FREQ(fi),:) ) max( head(FREQ(fi),:) ) ], 5, zoom )
            catch
            end
        end

        % ---- fft
        subplot(4,2,3:4,'Parent',p);
        plot( freq.trial, amp2use(:,HH), 'Color',col2use )
        xlim( [2 max(Hz.fundamental)*3 + 1] )
        xlabel( 'Frequency (Hz)' )
        ylabel( 'Amplitude (\muV)' )

        col = {'r' 'b'};
        % harmonics
        for fi = 1:2
            foi = idx.freqTrial(FREQ(fi),:);
            xt = freq.trial(foi);
            yt = amp2use(foi,HH);
            mystr = sprintfc('%0.1f',Hz.harmonics(FREQ(fi),:));
            text( xt, yt, mystr, 'horizontalalignment', 'center', 'verticalalignment', 'middle', 'color', col{fi} )
        end

        subplot(4,2,5:6,'Parent',p);
        plot( t.postMove, erp2use(:,HH),'Color',col2use )
        xlabel( 'Time (s)' )
        ylabel('Voltage (\muV)')
        xlim([0 s.trial])
        colorbar('Visible','off')


        ax = subplot(4,2,7:8,'Parent',p,'ytick',sort(Hz.fundamental));
        contourf( t.postMove, freq.wavelet, tf(:,:,HH),20,'linecolor','none' )
        colormap('jet')
        xlabel( 'Time (s)' )
        ylabel( 'Frequency (Hz)' )
        xlim([0 s.trial])
        colorbar

        saveas(h, [ direct.results TIT '.png' ] )
        close(h)
    end

    %% Distribution

    h = figure('WindowStyle','normal','Units','normalized','Position',picsize,'visible',options.visible);

    TIT = [ experiment.session '.' str.player{P} '.rtDist.baseline' ];
    for HH = find(Hz2use)
        ax(HH) = subplot(2,n.axis,HH);
        h1 = histogram( rt.distribution(:,HH,P), 50,'Normalization','probability');
        h1(1).FaceColor = colour.hz(ceil(HH/2),:,2-mod(HH,2));
        h1(1).EdgeColor = 'none';
        xlabel('Amplitude (\muV)')
        ylabel('Probability')
        title(str.Hz{HH})
    end

    linkaxes( ax, 'xy' )
    saveas(h, [ direct.results TIT '.png' ] )
    close(h)
    clear h1
    %% Selectivity
    Combo2use = (1:n.axis) + (find(Hz2use,1,'first')-1);

    for HH = find(Hz2use)
        rt.percentile(:,HH,1:n.trialsBlock,P) = reshape(tiedrank(rt.distribution(:,HH,P)),n.seg,n.trialsBlock)/ n.samples * 100;
    end

    for COMBO = Combo2use
        rt.selectivity(:,COMBO,1:n.trialsBlock,P) = rt.percentile(:,COMBO,1:n.trialsBlock,P) - rt.percentile(:,COMBO+2,1:n.trialsBlock,P);
    end

    %% Plot

    HH = NaN(2,1);
    TIT = [ experiment.session '.' str.player{P} '.selectivityDist.baseline' ];
    [h,p] = SuperTitle(TIT,options.visible);
    for COMBO = Combo2use
        sel2plot = reshape((rt.selectivity(:,COMBO,1:n.trialsBlock,P)),[],1);
        subplot(2,1,COMBO,'Parent',p)
        h1 = histogram(sel2plot, 50,'Normalization','probability');
        h1(1).FaceColor = colour.hz(1,:,COMBO);
        h1(1).EdgeColor = 'none';

        yl = ylim;
        xl = [-threshold, threshold];
        xl = repmat(xl',1,2);
        for LL = 1:length(xl)
            line(xl(LL,:),yl,'Color',[.5 .5 .5],'LineStyle','--')
        end
        xticks([-100 -50 -threshold, 0, threshold 50 100])
        title(str.train{COMBO})
        xlabel('selectivity')
        ylabel('probability')
    end
    saveas(h, [ direct.results TIT '.png' ] )
    close(h)
    clear h1

    for COMBO = Combo2use
        HH(1) = COMBO;
        HH(2) = COMBO+2;

        h = figure('WindowStyle','normal','Units','normalized','Position',picsize,'visible',options.visible);
        TIT = [ experiment.session '.' str.player{P} '.' str.train{COMBO} '.selectivity.baseline' ];
        for fi = 1:2
            subplot(2,1,fi,'Parent',h)
            hold on
            trial2use = rt.trigger == trig.trial(1,2*HH(fi)-1);

            yy = rt.selectivity(:,COMBO,trial2use,P);
            yy = reshape(yy,[],1);
            xx = 1:length(yy);

            vv = false(3,length(yy));
            vv(1,:) = yy>threshold;
            vv(2,:) = yy<-threshold;
            vv(3,:) = abs(yy)<= threshold;

            for ii = 1:3
                x1 = xx;
                x1(~vv(ii,:))=NaN;
                y1 = yy;
                y1(~vv(ii,:))=NaN;
                pp(ii) = plot(x1, y1,'LineWidth',1,'Color',colour.hz(ii,:,COMBO));
            end

            title(['Baseline Selectivty: ' str.Hz{HH(fi)}])

            xl = xlim;
            yl = [-threshold, 0, threshold];
            yl = repmat(yl',1,2);
            for LL = 1:length(yl)
                line(xl,yl(LL,:),'Color',[.5 .5 .5],'LineStyle','--')
            end
            yticks([-100 -50 -threshold, 0, threshold 50 100])

            ylim([-100 100])
            xlim([xx(1) xx(end)])
            legend([pp(1),pp(2),pp(3)],{str.Hz{HH(1)},str.Hz{HH(2)},'dead zone'})

        end
        saveas(h, [ direct.results TIT '.png' ] )
        close(h)
        clear h p xx yy x1 x2 x3 y1 y2 y3 p1 p2 p3
    end
    clear sel2plot h1
end

%% Selectivity Accuracy
baseline.accuracy = NaN(n.Hz,N.players+1);

TIT = [ experiment.session '.accuracy.baseline' ];
[h,p] = SuperTitle(TIT,options.visible,[0.1,0.2,0.8,0.6]);
col2use = [colour.hz(1:2,:,1);colour.hz(1:2,:,2)];

for P = 1:N.players + 1
    for HH = 1:n.Hz
        COMBO = 2-mod(HH,2);
        trial2use = rt.trigger == trig.trial(1,2*HH-1);

        if P == N.players + 1
            sel2use1 = reshape(mean(rt.selectivity(:,COMBO,trial2use,:),4,'omitnan'),[],1);
            sel2use2 = reshape(mean(rt.selectivity(:,COMBO,~trial2use(1:n.trialsBlock),:),4,'omitnan'),[],1);
            txt = 'Joint';
        else
            sel2use1 = reshape(rt.selectivity(:,COMBO,trial2use,P),[],1);
            sel2use2 = reshape(rt.selectivity(:,COMBO,~trial2use(1:n.trialsBlock),P),[],1);
            txt = str.player(P);
        end
        switch ceil(HH/2)
            case 1
                TP = sum(sel2use1 > threshold);
                FP = sum(sel2use2 > threshold);
                FN = sum(sel2use1 <= threshold);
                TN = sum(sel2use2 <= threshold);
            case 2
                TP = sum(sel2use1 <- threshold);
                FP = sum(sel2use2 <- threshold);
                FN = sum(sel2use1 >= -threshold);
                TN = sum(sel2use2 >= -threshold);
        end

        baseline.accuracy(HH,P) = (TP+TN)/(TP + FN + TN + FP);
    end

    subplot(1,3,P,'Parent',p)
    bar(baseline.accuracy(:,P),'FaceColor','flat','CData',col2use);
    xticklabels(str.Hz)
    xlabel('Cued Frequency')
    ylabel('Accuracy')
    title(txt)
    ylim([0 1])

end
saveas(h, [ direct.results TIT '.png' ] )
close(h)
%%
clear amp2use amp ax erp erp2use freqoi complex_dat zoom mystr nSample tf pp vv
disp('Baseline analysis finished.')
