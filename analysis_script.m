%% Which experiment to analyze
nameOfMicroSD='C:\Users\Kim\Documents\MATLAB\Final analysis\bl_4_new 20170630\OUTPUT.txt';
nameOfVideoFile='C:\Users\Kim\Documents\MATLAB\Final analysis\bl_4_new 20170630\1980-07-09 10-32-37-C.avi';
control=true; % if this is a control where pellet not loaded every time
isInSecondHalf=0; % if this movie is in the second half of arduino output file

%% Get data from Arduino output file        
endoffname=regexp(nameOfMicroSD,'\');            
out=parseSerialOut(nameOfMicroSD,[nameOfMicroSD(1:endoffname(end)) 'parsedOutput.mat'],control);

%% Load user-classified reach data from movie
endoffname=regexp(nameOfVideoFile,'\.');          
a=load([nameOfVideoFile(1:endoffname(end)-1) '_savehandles.mat']);
savehandles=a.savehandles;

%% Break apart coded reaches?
[part1,part2]=breakApartCodedReaches(savehandles,8969);
savehandles=part2;

%% Do alignment of Arduino and movie data
aligned=getAlignment(out,30,savehandles,isInSecondHalf);

%% Save integrated data
endofVfname=regexp(nameOfVideoFile,'\.');      
[status]=mkdir([nameOfVideoFile(1:endofVfname(end)-1) '_processed_data']);
finaldata=integrateSDoutWithReaches(savehandles,out,30,aligned,[nameOfVideoFile(1:endofVfname(end)-1) '_processed_data']);

%% Make data figures
tbt=plotCueTriggeredBehavior(finaldata,'cue',1);
save([nameOfVideoFile(1:endofVfname(end)-1) '_processed_data\tbt.mat'],'tbt');

%% Combine trial-by-trial data cross video files
tbt=combineExptPieces('C:\Users\Kim\Documents\MATLAB\Final analysis\bl_4_new 20170630');
plotExptOutput(tbt,1);