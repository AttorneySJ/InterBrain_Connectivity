%% Current Experiment
try
    load('experiment.mat','experiment')
catch
    experiment.number = 0;
end

if options.SaveEEG == 1    
	experiment.number = experiment.number + 1;
end

experiment.clock = cell(1,2);
experiment.clock{1} = clock;
experiment.session = ['S' num2str(experiment.number,'%02u') '.' datestr(now,'yy.mmm.dd.HH.MM.SS')];

experiment.direct = [ direct.DataResultsRoot experiment.session '\' ];
mkdir( experiment.direct )

if options.SaveEEG
    experiment.dataFile = [ experiment.direct experiment.session '.bin' ];
    fid = fopen( experiment.dataFile, 'w');
end

save( 'experiment.mat', 'experiment' )
