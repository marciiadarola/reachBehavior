function out=getChewing(eatData, movie_fps, chewFrequency, chewingThresh)

% Note that isChewing only returns 1 for long bouts of chewing consistent with
% pellet consumption, ignoring vacuous chewing

% Add path to Chronux
added_path='C:\Users\Kim\Documents\MATLAB\chronux_2_11';
addpath(genpath(added_path));

params.Fs=movie_fps;
params.tapers=[10 12];
params.fpass=[2 15]; % in Hz

[S,t,f]=mtspecgramc(eatData(~isnan(eatData)),[7 1],params);
chewingpower=nanmean(S(:,f>=chewFrequency(1) & f<=chewFrequency(2)),2);
chewingpower=nonparamZscore(chewingpower);

frameTimes=0:(1/movie_fps):(length(eatData(~isnan(eatData)))-1)*(1/movie_fps);
chewingInFrames=mapToFrames(chewingpower,t,frameTimes);

out.isChewing=eatData;
out.isChewing(~isnan(eatData))=chewingInFrames>chewingThresh;
out.chewingInFrames=eatData;
out.chewingInFrames(~isnan(eatData))=chewingInFrames;
out.chewingpower=chewingpower;

% Remove path to Chronux
rmpath(genpath(added_path));

end

function dataByFrames=mapToFrames(data,times,frameTimes)

dataByFrames=nan(size(frameTimes));

for i=1:length(times)
    [~,mi]=min(abs(times(i)-frameTimes));
    dataByFrames(mi)=data(i);
end

dataByFrames=fillInNans(dataByFrames);

end

function data=fillInNans(data)

inds=find(~isnan(data));
for i=1:length(inds)
    currind=inds(i);
    if i==1
        % fill in before
        data(1:currind-1)=data(currind);
    elseif i==length(inds)
        halfLength=floor((currind-inds(i-1))/2);
        data(inds(i-1)+1:inds(i-1)+1+halfLength)=data(inds(i-1));
        data(inds(i-1)+2+halfLength:currind-1)=data(currind);
        % fill in after
        data(currind+1:end)=data(currind);
    else
        % fill in with recent
        halfLength=floor((currind-inds(i-1))/2);
        data(inds(i-1)+1:inds(i-1)+1+halfLength)=data(inds(i-1));
        data(inds(i-1)+2+halfLength:currind-1)=data(currind);
    end
end
if any(isnan(data))
    error('Failed to replace all nans');
end
        

end