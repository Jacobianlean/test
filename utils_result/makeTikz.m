function makeTikz(saveName)
% This code need the "matlab2tikz" folder

curFolder = pwd;

% Matlab2tikz
cd('C:\Users\532986\Google Drive\1.Research\3.Code\PlottingTools\matlab2tikz\src')

fileName = strcat(saveName,'.tex');
% Generates a tex file to be included in your manuscript
matlab2tikz(fileName,'showInfo', false,'checkForUpdates',false); 

cd(curFolder);
end