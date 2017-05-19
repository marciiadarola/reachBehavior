function getAlignment(filename,out,startedVideoAfterArduino,distractorWriteCode,moviefps,totalFramesInExpt)

% Note that microSD (Arduino) output is timed in ms
% Whereas video is timed in frames per sec

% If started video after Arduino, use distractor to align
if startedVideoAfterArduino==1
    alignmentGUI(filename);
    endoffname=regexp(filename,'\.');
    a=load([filename(1:endoffname(end)-1) '_distractorLED.mat']);
    LEDsavehandles=a.LEDsavehandles;
    % Find alignment with Arduino output data
    changeInLEDTimes=out.eventLogTimes(out.eventLog==distractorWriteCode);
    onInds=find(out.distractorStart==1);
    offInds=find(out.distractorStart==0);
    onDurations=changeInLEDTimes(offInds)-changeInLEDTimes(onInds); % in ms
    if LEDsavehandles.LEDstartson==0
        movie_onDurations=(LEDsavehandles.off-LEDsavehandles.on(1:length(LEDsavehandles.off))).*(1/moviefps);
    else
        movie_onDurations=(LEDsavehandles.off(2:end)-LEDsavehandles.on(1:length(LEDsavehandles.off(2:end)))).*(1/moviefps);
    end
    % Guess when movie started based on total time duration of movie vs
    % duration recorded by Arduino
    movieDuration=totalFramesInExpt*(1/moviefps); % in seconds
    outDuration=max(out.eventLogTimes)/1000; % in seconds
    delayIntoVideo=(outDuration-movieDuration)*1000; % in milliseconds
    nBefore=length(out.eventLogTimes(out.eventLog==distractorWriteCode & out.eventLogTimes<delayIntoVideo));
    
    
    
