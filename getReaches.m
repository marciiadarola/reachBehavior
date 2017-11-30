function out=getReaches(reachData)

% reachData is intensity in user-defined reach zone
out.rawData=reachData;

% user-set constants
maxReachFrequency=6; % in Hz, the maximum frequency at which mouse can reach
movie_fps=30; % movie frame rate, in frames per second
reachThresh=5; % after non-parametric transformation of reachData
holdThreshold=10; % in seconds -- if any reach lasts longer than 10 s, this is not a reach -- this is a hold
plotOutput=1; % if 1, plot output, else do not plot

minReachPeriod=1/maxReachFrequency; % in seconds
movieFramePeriod=1/movie_fps; % in seconds
minIndsBetweenReach=floor(minReachPeriod/movieFramePeriod);

reachData=nonparamZscore(reachData); % non-parametric Z score
isReach=reachData>reachThresh;

% Find peaks
[~,reachPeakLocs,reachWidths]=findpeaks(reachData,'MinPeakDistance',minIndsBetweenReach,'MinPeakHeight',reachThresh,'WidthReference','halfheight');
reachPeaks=zeros(size(reachData));
reachPeaks(reachPeakLocs)=1;
currReachWidth=zeros(size(reachData));
currReachWidth(reachPeakLocs)=reachWidths;

% Find reach stretches lasting longer than holdThreshold
holdIndsThresh=floor(holdThreshold/movieFramePeriod);
isHold=zeros(1,length(reachData));
holdLengths=zeros(1,length(reachData));
currHoldLength=0;
holdStarts=zeros(1,length(reachData));
for i=1:length(isHold)-(holdIndsThresh-1)
    if all(reachData(i:i+(holdIndsThresh-1))>reachThresh)
        isHold(i:i+(holdsIndsThresh-1))=1;
        currHoldLength=currHoldLength+1;
    else
        if currHoldLength>0
            holdLengths(i+1-currHoldLength:i+(holdsIndsThresh-1))=currHoldLength+holdIndsThresh-1;
            holdStarts(i+1-currHoldLength)=1;
            currHoldLength=0;
        end
    end
end

% If reach is in a hold, delete reach
isReach=single((isReach==1) & (isHold==0));
reachPeaks=single((reachPeaks==1) & (isHold==0));
currReachWidth(isHold==1)=holdLengths(isHold==1);

% Map nans
isReach(isnan(reachData)==1)=nan;
reachPeaks(isnan(reachData)==1)=nan;
currReachWidth(isnan(reachData)==1)=nan;
isHold(isnan(reachData)==1)=nan;
holdStarts(isnan(reachData)==1)=nan;
holdLengths(isnan(reachData)==1)=nan;

out.isReach=isReach;
out.reachPeaks=reachPeaks;
out.currReachWidth=currReachWidth;
out.isHold=isHold;
out.holdStarts=holdStarts;
out.holdLengths=holdLengths;

if plotOutput==1
   figure(); 
   plot(reachData);
   hold on;
   plot(out.isReach.*max(reachData),'Color','r');
   plot(out.reachPeaks.*max(reachData),'Color','k');
   plot(out.isHold.*max(reachData),'Color','g');
end