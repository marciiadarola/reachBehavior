function aligned=getAlignment(filename,out,startedVideoAfterArduino,distractorWriteCode,moviefps,totalFramesInExpt,handles)

% Note that microSD (Arduino) output is timed in ms
% Whereas video is timed in frames per sec

% Try to align based on distractor LED from movie and Arduino output
temp_LED=handles.LEDvals;
threshForOnVsOff=mean(temp_LED);
figure();
movie_times=0:(1/moviefps)*1000:(length(temp_LED)-1)*((1/moviefps)*1000);
plot(movie_times,temp_LED,'Color','b');
hold on;
line([0 (length(temp_LED)-1)*((1/moviefps)*1000)],[threshForOnVsOff threshForOnVsOff],'Color','r');
title('Threshold for distinguishing LED on vs off');

% Get when LED was on in movie vs off
movie_LED=temp_LED>threshForOnVsOff;

% Find best alignment of distractor LED in movie and Arduino output -- note
% different sampling rates
temp=out.distractorOn';
% arduino_timestep=out.allTrialTimes(1,2)-out.allTrialTimes(1,1); % in ms
temptimes=(out.allTrialTimes+repmat(out.trialStartTimes',1,size(out.allTrialTimes,2)))';
temptimes=temptimes(1:end);
temp=temp(1:end);
arduino_LED=temp(~isnan(temptimes));
arduino_times=temptimes(~isnan(temptimes));

% Find alignment
% First down-sample arduino LED
arduino_dec=100;
arduino_LED=decimate(arduino_LED,arduino_dec);

movie_dec=3;
movie_LED=decimate(double(movie_LED),movie_dec);
movie_times=decimate(movie_times,movie_dec);

% Test signal alignment and scaling
maxDelay=length(arduino_LED)-length(movie_LED);
minscale=1; % scale movie wrt arduino time
maxscale=2.5;
tryinc=0.05;
tryscales=minscale:tryinc:maxscale;
sumdiffs=nan(length(tryscales),maxDelay);
backup_movie_LED=movie_LED;
backup_arduino_LED=arduino_LED;
for j=1:length(tryscales)
    if mod(j,10)==0
        disp('Processing ...');
%         disp(j);
    end
    currscale=tryscales(j);
    movie_LED=resample(backup_movie_LED,currscale*(1/tryinc),(1/tryinc));
    for i=1:maxDelay
        if mod(i,500)==0
%             disp(i);
        end
        temp_movie=[nan(1,i) movie_LED];
        temp_arduino=[arduino_LED nan(1,length(temp_movie)-length(arduino_LED))];
        if length(temp_arduino)>length(temp_movie)
            temp_movie=[temp_movie nan(1,length(temp_arduino)-length(temp_movie))];
        end
        sumdiffs(j,i)=nansum(abs(temp_movie-temp_arduino));
    end
end
[minval,mi]=min(sumdiffs(:));
[mi_row,mi_col]=ind2sub(size(sumdiffs),mi);

figure(); 
imagesc(sumdiffs);
title('Finding best alignment');

frontShift=mi_col;
scaleBy=tryscales(mi_row);
resampFac=1/tryinc;
best_movie=[nan(1,mi_col) resample(backup_movie_LED,tryscales(mi_row)*(1/tryinc),(1/tryinc))];
shouldBeLength=length(best_movie);
best_arduino=[backup_arduino_LED nan(1,length(best_movie)-length(backup_arduino_LED))];
movieToLength=length(best_arduino);
if length(best_arduino)>length(best_movie)
    best_movie=[best_movie nan(1,length(best_arduino)-length(best_movie))];
end
figure();
plot(best_movie,'Color','b');
hold on;
plot(best_arduino,'Color','r');

% disp('in original alignment');
% disp(length(best_arduino))

% Then re-align sub-sections of movie to arduino code
alignSegments=750; % in number of indices
mov_distractor=[];
arduino_distractor=[];
firstInd=find(~isnan(best_movie) & ~isnan(best_arduino),1,'first');
lastBoth=min([find(~isnan(best_movie),1,'last') find(~isnan(best_arduino),1,'last')]);
segmentInds=firstInd:alignSegments:lastBoth;
mov_distractor=[mov_distractor nan(1,firstInd-1)];
arduino_distractor=[arduino_distractor nan(1,firstInd-1)];
segmentDelays=nan(1,length(segmentInds));
addZeros_movie=nan(1,length(segmentInds));
addZeros_arduino=nan(1,length(segmentInds));
for i=1:length(segmentInds)-1
    currInd=segmentInds(i);
    [temp1,temp2,D]=alignsignals(best_movie(currInd:currInd+alignSegments-1),best_arduino(currInd:currInd+alignSegments-1));
    segmentDelays(i)=D;
    if length(temp1)>length(temp2)
        addZeros_arduino(i)=length(temp1)-length(temp2);
        temp2=[temp2 zeros(1,length(temp1)-length(temp2))];
        addZeros_movie(i)=0;
    elseif length(temp2)>length(temp1)
        addZeros_movie(i)=length(temp2)-length(temp1);
        temp1=[temp1 zeros(1,length(temp2)-length(temp1))];
        addZeros_arduino(i)=0;
    else
        addZeros_movie(i)=0;
        addZeros_arduino(i)=0;
    end
    mov_distractor=[mov_distractor temp1];
    arduino_distractor=[arduino_distractor temp2];
end
figure();
plot(mov_distractor,'Color','b');
hold on;
plot(arduino_distractor,'Color','r');
aligned.movie_distractor=mov_distractor;
aligned.arduino_distractor=arduino_distractor;

% Align other signals in same fashion as LED distractor
% From Arduino
temp=out.cueOn';
temp=temp(1:end);
cue=temp(~isnan(temptimes));
cue=alignLikeDistractor(cue,0,arduino_dec,frontShift,shouldBeLength,movieToLength,alignSegments,segmentInds,segmentDelays,addZeros_arduino,scaleBy,resampFac); 
aligned.cue=cue;
temp=out.pelletLoaded';
temp=temp(1:end);
pelletLoaded=temp(~isnan(temptimes));
pelletLoaded=alignLikeDistractor(pelletLoaded,0,arduino_dec,frontShift,shouldBeLength,movieToLength,alignSegments,segmentInds,segmentDelays,addZeros_arduino,scaleBy,resampFac); 
aligned.pelletLoaded=pelletLoaded;
temp=out.pelletPresented';
temp=temp(1:end);
pelletPresented=temp(~isnan(temptimes));
pelletPresented=alignLikeDistractor(pelletPresented,0,arduino_dec,frontShift,shouldBeLength,movieToLength,alignSegments,segmentInds,segmentDelays,addZeros_arduino,scaleBy,resampFac); 
aligned.pelletPresented=pelletPresented;
temp=out.encoderTrialVals';
temp=temp(1:end);
encoder=temp(~isnan(temptimes));
encoder=alignLikeDistractor(encoder,0,arduino_dec,frontShift,shouldBeLength,movieToLength,alignSegments,segmentInds,segmentDelays,addZeros_arduino,scaleBy,resampFac); 
aligned.encoder=encoder;
temp=out.nDropsPerTrial';
temp=temp(1:end);
drops=temp(~isnan(temptimes));
drops=alignLikeDistractor(drops,0,arduino_dec,frontShift,shouldBeLength,movieToLength,alignSegments,segmentInds,segmentDelays,addZeros_arduino,scaleBy,resampFac); 
aligned.drops=drops;
temp=out.nMissesPerTrial';
temp=temp(1:end);
misses=temp(~isnan(temptimes));
misses=alignLikeDistractor(misses,0,arduino_dec,frontShift,shouldBeLength,movieToLength,alignSegments,segmentInds,segmentDelays,addZeros_arduino,scaleBy,resampFac); 
aligned.misses=misses;
timesfromarduino=alignLikeDistractor(double(arduino_times),0,arduino_dec,frontShift,shouldBeLength,movieToLength,alignSegments,segmentInds,segmentDelays,addZeros_arduino,scaleBy,resampFac); 
aligned.timesfromarduino=timesfromarduino;
% From movie
movieframeinds=double(1:length(handles.LEDvals));
movieframeinds=alignLikeDistractor(movieframeinds,1,movie_dec,frontShift,shouldBeLength,movieToLength,alignSegments,segmentInds,segmentDelays,addZeros_movie,scaleBy,resampFac);
aligned.movieframeinds=movieframeinds;

% Plot results
figure();
ha=tight_subplot(7,1,[0.06 0.03],[0.08 0.1],[0.1 0.01]);
currha=ha(1);
axes(currha);
plot(aligned.cue,'Color','r');
xlabel('Cue');
set(currha,'XTickLabel','');
% set(currha,'YTickLabel','');
title('Results of alignment');

currha=ha(2);
axes(currha);
plot(aligned.movie_distractor,'Color','b');
hold on;
plot(aligned.arduino_distractor,'Color','r');
xlabel('Distractor');
set(currha,'XTickLabel','');
% set(currha,'YTickLabel','');

currha=ha(3);
axes(currha);
plot(aligned.movieframeinds,'Color','b');
xlabel('Movie frames');
set(currha,'XTickLabel','');
% set(currha,'YTickLabel','');

currha=ha(4);
axes(currha);
plot(aligned.pelletLoaded,'Color','r');
xlabel('Pellet loaded');
set(currha,'XTickLabel','');
% set(currha,'YTickLabel','');

currha=ha(5);
axes(currha);
plot(aligned.pelletPresented,'Color','r');
xlabel('Pellet presented');
set(currha,'XTickLabel','');
% set(currha,'YTickLabel','');

currha=ha(6);
axes(currha);
plot(aligned.timesfromarduino./1000,'Color','r');
xlabel('Times from arduino');
set(currha,'XTickLabel','');
% set(currha,'YTickLabel','');

currha=ha(7);
axes(currha);
plot(aligned.movieframeinds.*(1/moviefps),'Color','b');
xlabel('Times from movie');
set(currha,'XTickLabel','');
% set(currha,'YTickLabel','');
end

function outsignal=alignLikeDistractor(signal,scaleThisSignal,decind,frontShift,shouldBeLength,movieToLength,alignSegments,segmentInds,segmentDelays,addZeros,scaleBy,resampFac)

% If like movie, scaleThisSignal=1
% else scaleThisSignal=0

signal=decimate(signal,decind);
if scaleThisSignal==1
    % Like movie
    signal=[nan(1,frontShift) resample(signal,scaleBy*resampFac,resampFac)];
    if movieToLength>length(signal)
        signal=[signal nan(1,movieToLength-length(signal))];
    end
else
    % Like arduino
    signal=[signal nan(1,shouldBeLength-length(signal))];
end

% [Xa,Ya] = alignsignals(X,Y)
% X is movie, Y is arduino
% If Y is delayed with respect to X, then D is positive and X is delayed by D samples.
% If Y is advanced with respect to X, then D is negative and Y is delayed by –D samples.

% disp('in second alignment');
% disp(length(signal))

outsignal=[];
firstInd=segmentInds(1);
outsignal=[outsignal nan(1,firstInd-1)];
for i=1:length(segmentInds)-1
    currInd=segmentInds(i);
    currChunk=signal(currInd:currInd+alignSegments-1);
    if scaleThisSignal==1
        % Like movie
        if segmentDelays(i)>0
            % Delay is positive, so movie was shifted
            currChunk=[nan(1,segmentDelays(i)) currChunk];
        else
            % Delay is negative, so arduino was shifted
        end
    else
        % Like arduino
        if segmentDelays(i)>0
            % Delay is positive, so movie was shifted
        else
            % Delay is negative, so arduino was shifted
            currChunk=[nan(1,-segmentDelays(i)) currChunk];
        end
    end
    currChunk=[currChunk nan(1,addZeros(i))];
    outsignal=[outsignal currChunk];
end

end
