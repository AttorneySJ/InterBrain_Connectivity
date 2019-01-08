% Update the data and results folder for the current session
direct.data = [direct.main 'Data\' experiment.session '\'];
direct.results = [direct.main 'Results\' experiment.session '\'];

mkdir(direct.data)
mkdir(direct.results)
addpath(direct.data)
addpath(direct.results)

% write experiment session ID to the text file for sharing with Unity
expFile = fopen([direct.main 'session.txt'],'w');
fprintf(expFile,'%s',experiment.session);
fclose(expFile);
clear expFile