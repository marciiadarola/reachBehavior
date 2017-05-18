function getAlignment(filename,out,distractorWriteCode,moviefps)

% Note that microSD (Arduino) output is timed in ms
% Whereas video is timed in frames per sec

% If started video after Arduino, use distractor to align
alignmentGUI(filename);
endoffname=regexp(filename,'\.');
a=load([filename(1:endoffname(end)-1) '_distractorLED.mat']);
LEDsavehandles=a.LEDsavehandles;
% Find alignment with Arduino output data
changeInLEDTimes=out.eventLogTimes(out.eventLog==distractorWriteCode);
firstOn=find(out.distractorStart==1,1,'first');
lastOff=find(out.distractorStart==0,1,'last');
changeInLEDTimes=changeInLEDTimes(firstOn:lastOff);
onDurations=changeInLEDTimes(2:end)-changeInLEDTimes(1:end-1); % in ms
movie_onDurations=(LEDsavehandles.off-LEDsavehandles.on(1:length(LEDsavehandles.off))).*(1/moviefps);

