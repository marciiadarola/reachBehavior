function out=getPawAtMouth(eatData)

% Settings
pawAtMouthThresh=15;
maxPawAtMouthFreq=5; % in Hz, the maximum frequency at which mouse can repeatedly raise paw to mouth
movie_fps=30; % movie frame rate in frames per second
plotOutput=1; % if 1, plot output, else do not plot

minRaisePeriod=1/maxPawAtMouthFreq; % in seconds
movieFramePeriod=1/movie_fps; % in seconds
minIndsBetweenMouth=floor(minRaisePeriod/movieFramePeriod);

% Find times when mouse raises paw/pellet to mouth
eatZoneData=nonparamZscore(eatData); % non-parametric Z score
isPawAtMouth=single(eatZoneData>pawAtMouthThresh);

% Find peaks
[~,raisePeakLocs,raiseWidths]=findpeaks(eatZoneData,'MinPeakDistance',minIndsBetweenMouth,'MinPeakHeight',pawAtMouthThresh,'WidthReference','halfheight');
raisePeaks=zeros(size(eatZoneData));
raisePeaks(raisePeakLocs)=1;
currRaiseWidth=zeros(size(eatZoneData));
currRaiseWidth(raisePeakLocs)=raiseWidths;

% Map nans
isPawAtMouth(isnan(eatData)==1)=nan;
raisePeaks(isnan(eatData)==1)=nan;
currRaiseWidth(isnan(eatData)==1)=nan;

out.isPawAtMouth=isPawAtMouth;
out.raisePeaks=raisePeaks;
out.currRaiseWidth=currRaiseWidth;

if plotOutput==1
   figure(); 
   plot(eatZoneData);
   hold on;
   plot(out.isPawAtMouth.*max(eatZoneData),'Color','r');
   plot(out.raisePeaks.*max(eatZoneData),'Color','k');
end