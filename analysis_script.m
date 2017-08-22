%% Which experiment to analyze
nameOfMicroSD='C:\Users\Kim\Documents\MATLAB\Final analysis\20170503\OUTPUT.txt';
nameOfVideoFile='C:\Users\Kim\Documents\MATLAB\Final analysis\20170503\2017-04-14 07-14-06-C.avi';
control=true; % if this is a control where pellet not loaded every time

%% Get data from Arduino output file        
endoffname=regexp(nameOfMicroSD,'\');            
out=parseSerialOut(nameOfMicroSD,[nameOfMicroSD(1:endoffname(end)) 'parsedOutput.mat'],control);

%% Load user-classified reach data from movie
endoffname=regexp(nameOfVideoFile,'\.');          
a=load([nameOfVideoFile(1:endoffname(end)-1) '_savehandles.mat']);
savehandles=a.savehandles;

%% Do alignment of Arduino and movie data
aligned=getAlignment(out,30,savehandles);

%% Save integrated data
endofVfname=regexp(nameOfVideoFile,'\.');      
[status]=mkdir([nameOfVideoFile(1:endofVfname(end)-1) '_processed_data']);
finaldata=integrateSDoutWithReaches(savehandles,out,30,aligned,[nameOfVideoFile(1:endofVfname(end)-1) '_processed_data']);

%% Make data figures
tbt=plotCueTriggeredBehavior(finaldata,'cue',1);
