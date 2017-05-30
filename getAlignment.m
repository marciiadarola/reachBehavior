function getAlignment(filename,out,startedVideoAfterArduino,distractorWriteCode,moviefps,totalFramesInExpt,handles)

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
arduino_timestep=out.allTrialTimes(1,2)-out.allTrialTimes(1,1); % in ms
temptimes=(out.allTrialTimes+repmat(out.trialStartTimes',1,size(out.allTrialTimes,2)))';
temptimes=temptimes(1:end);
temp=temp(1:end);
arduino_LED=temp(~isnan(temptimes));
arduino_times=temptimes(~isnan(temptimes));

% Find alignment
% First down-sample arduino LED
arduino_dec=100;
arduino_LED=decimate(arduino_LED,arduino_dec);
arduino_times=decimate(double(arduino_times),arduino_dec);

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
    disp(j);
    currscale=tryscales(j);
%     movie_LED=resample(backup_movie_LED,currscale*10,10);
    movie_LED=resample(backup_movie_LED,currscale*(1/tryinc),(1/tryinc));
    for i=1:maxDelay
        if mod(i,500)==0
%             disp(i);
        end
        temp_movie=[nan(1,i) movie_LED];
%         temp_arduino=arduino_LED(1:length(temp_movie));
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

best_movie=[nan(1,mi_col) resample(backup_movie_LED,tryscales(mi_row)*(1/tryinc),(1/tryinc))];
best_arduino=[backup_arduino_LED nan(1,length(best_movie)-length(backup_arduino_LED))];
if length(best_arduino)>length(best_movie)
    best_movie=[best_movie nan(1,length(best_arduino)-length(best_movie))];
end
figure();
plot(best_movie,'Color','b');
hold on;
plot(best_arduino,'Color','r');

% Then re-align sub-sections of movie to arduino code??
alignSegments=750; % in number of indices
mov_distractor=[];
arduino_distractor=[];
firstInd=find(~isnan(best_movie) & ~isnan(best_arduino),1,'first');
lastBoth=min([find(~isnan(best_movie),1,'last') find(~isnan(best_arduino),1,'last')]);
segmentInds=firstInd:alignSegments:lastBoth;
mov_distractor=[mov_distractor nan(1,firstInd-1)];
arduino_distractor=[arduino_distractor nan(1,firstInd-1)];
segmentDelays=nan(1,length(segmentInds));
for i=1:floor(lastBoth/alignSegments)
    currInd=segmentInds(i);
    [temp1,temp2,D]=alignsignals(best_movie(currInd:currInd+alignSegments-1),best_arduino(currInd:currInd+alignSegments-1));
    segmentDelays(i)=D;
    if length(temp1)>length(temp2)
        temp2=[temp2 zeros(1,length(temp1)-length(temp2))];
    elseif length(temp2)>length(temp1)
        temp1=[temp1 zeros(1,length(temp2)-length(temp1))];
    end
    mov_distractor=[mov_distractor temp1];
    arduino_distractor=[arduino_distractor temp2];
end
figure();
plot(mov_distractor,'Color','b');
hold on;
plot(arduino_distractor,'Color','r');

% Align other signals in same fashion as LED distractor


disp('hi');
end

function alignLikeDistractor(decind,
    
