%% Effect of Task on Connectivity
rc = reshape(GD_Test_connectivityR,nPair,n.testTrials/n.taskType,N.players+1);
rc = squeeze(mean(rc,2,'omitnan'));

rc = rc(:,[2 3]);

GR_rc_skew(1) = skewness(rc(:,1));
GR_rc_skew(2) = skewness(rc(:,2));

diff_rc = rc(:,2)-rc(:,1);
ranks = tiedrank(abs(diff_rc));
diff_rc = sign(diff_rc);
GR_mean_rank = grpstats(ranks,diff_rc);
[~,GR_Task_Con.p,~,GR_Task_Con.t] = ttest(rc(:,1),rc(:,2));

%% Plot
picsize = [5 5 9 8];
TIT = 'Results_Connectivity_TaskType';
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

colour.task = [.8,.8,.8;.8,.8,.8];

% boxplot(rc,'Colors','k')
% hh = findobj(gca,'Tag','Box');
% for j=1:length(hh)
%     patch(get(hh(j),'XData'),get(hh(j),'YData'),colour.task(j,:),'FaceAlpha',.7);
% end
ctrs = 1:n.taskType;
con_avg = squeeze(mean(rc,1,'omitnan'));
con_sem = squeeze(std(rc,1,'omitnan')/sqrt(nPair));

bar(ctrs,con_avg,'FaceColor','flat','CData',colour.task);
hold on
errorbar(ctrs,con_avg,con_sem, '.k','LineWidth',2)

xlim([0.5 n.taskType+0.5])
xticklabels(str.taskType)
ylabel('Circular Correlation Coefficient')
APAaxis(gca);
box off
%%
saveas(h,[direct.groupRes TIT '.png'])
close(h)

%% within-pair
rc2 = reshape(GD_Test_connectivityR,nPair,n.testTrials/n.taskType,N.players+1);

p_within = NaN(nPair,1);
t_within = cell(nPair,1);

for PAIR = 1:nPair
 [~,p_within(PAIR),~,t_within{PAIR}] = ttest(rc2(PAIR,:,1),rc2(PAIR,:,3));
end
sig_within = sum(p_within<.05);
%% Figure7: Effects of Connectivity on Behavioural Outcomes
str.outcome = {'Success Rate';'Movement Time';'Distance to the Target';'Trajectory Dispersion'};

GR_Con_Behave.r = NaN(4,4);
GR_Con_Behave.p = NaN(4,4);

control = mean(squeeze(mean(GD_Baseline_SNR,2,'omitnan')),2);

tt = GD_Test_time;
tt(tt>20) = NaN;

IV = rc;
for DD = 1:4
    switch DD
        case 1
            DV = squeeze(mean(reshape(GD_Test_success,nPair,[],N.players+1),2,'omitnan'));
        case 2
            DV = squeeze(mean(reshape(tt,nPair,[],N.players+1),2,'omitnan'));
        case 3
            DV = squeeze(mean(reshape(GD_Test_d2t,nPair,[],N.players+1),2,'omitnan'));
        case 4
            DV = squeeze(mean(reshape(GD_Test_d2l,nPair,[],N.players+1),2,'omitnan')); 
    end

    for P = 1:4
        if P<3
            TASK = 1;
        else
            TASK = 2;
        end
        
        if P<4
            [GR_Con_Behave.r(DD,P),GR_Con_Behave.p(DD,P)] = corr(IV(:,TASK),DV(:,P),'Rows','complete','Type','p');
        else
            [GR_Con_Behave.r(DD,P),GR_Con_Behave.p(DD,P)] = partialcorr(IV(:,2),DV(:,3),control,'Rows','complete','Type','p');
        end
    end
end

%% Effects of Joint Connectivity on Behavioural Outcomes
picsize = [5 5 20 16];
TIT = 'Results_Connectivity_Behaviour';
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

IV = rc(:,2);
for DD = 1:4
    switch DD
        case 1
            DV = squeeze(mean(reshape(GD_Test_success,nPair,[],N.players+1),2,'omitnan')).*100;
        case 2
            DV = squeeze(mean(reshape(tt,nPair,[],N.players+1),2,'omitnan'));
        case 3
            DV = squeeze(mean(reshape(GD_Test_d2t,nPair,[],N.players+1),2,'omitnan'));
        case 4
            DV = squeeze(mean(reshape(GD_Test_d2l,nPair,[],N.players+1),2,'omitnan')); 
    end
    DV = DV(:,3);
        nanRow = any(isnan([IV,DV]),2);
        xx = IV(~nanRow);
        yy = DV(~nanRow);
        
        subplot(2,2,DD)
        scatter(xx,yy,30,'filled','MarkerFaceColor',[.5,.5,.5])
        hold on
        coef_fit = polyfit(xx,yy,1);
        y_fit = polyval(coef_fit,xlim);
        plot(xlim,y_fit,'--k','LineWidth',2);
        hold off
        xlabel('Inter-Brain Connectivity')
        ylabel(str.outcome{DD})
        switch DD
            case 1
                ylim([0 100]);
            case 2
                ylim([0 20]);
        end
        APAaxis(gca);
end

%%  
saveas(h,[direct.groupRes TIT '.png'])
close(h)

%% Figure9: Trial Level Correlation
Connect = reshape(GD_Test_connectivityR,nPair,n.testTrials/n.taskType,N.players+1);
Connect = Connect(:,:,3);
GR_triallevel.r = NaN(nPair,4);
GR_triallevel.p = NaN(nPair,4);

for PAIR = 1:nPair
    IV = Connect(PAIR,:)';
    for DD = 1:4
        switch DD
        case 1
            DV = reshape(GD_Test_success(PAIR,:,:,3),[],1);
        case 2
            DV = reshape(GD_Test_time(PAIR,:,:,3),[],1);
        case 3
            DV = reshape(GD_Test_d2t(PAIR,:,:,3),[],1);
        case 4
            DV = reshape(GD_Test_d2l(PAIR,:,:,3),[],1);
        end
    
         [GR_triallevel.r(PAIR,DD),GR_triallevel.p(PAIR,DD)] = corr(IV,DV,'Rows','complete');
    end  
end


GR_triallevel.M = squeeze(mean(GR_triallevel.r,1,'omitnan'));
GR_triallevel.SEM = squeeze(std(GR_triallevel.r,1,'omitnan'))./sqrt(nPair);
GR_triallevel.sig = squeeze(sum(GR_triallevel.p<.05));

r2 = GR_triallevel.r;
r2(GR_triallevel.p>.05) = NaN;
GR_triallevel.M2 = squeeze(mean(r2,1,'omitnan'));