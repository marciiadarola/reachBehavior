function [reachTypes,reaches]=codeEvents(reaches,pelletInPlace,perchData,eatData)

% Event types
% Reach, but no pellet available
% Reach, but reach does not begin from perch
% Miss: reach but pellet does not move
% Grab: reach and pellet moves
% Eat: grab and paws at mouth
% Drop: grab but no paws at mouth

% Settings
pelletSettledForTime=0.066; % time in seconds for pellet to be at proper reach position, before reach begins
movie_fps=30; % movie frame rate in frames per second
fromPerchWindow=0.5; % in seconds, how long the paw must be at perch (i.e., not reaching) before reach, for reach to count as beginning from perch
% Reach type code
missType=1;
grabType=2; % note that grab type should always be overwritten as either eatType or dropType
eatType=3;
dropType=4;
chewFrequency=[4 6]; % frequency range at which mouse chews in Hz
chewingThresh=5; % in non-parametric Z score metrics, threshold for power in chewing frequency range above which mouse is chewing
% chewDurationForEat=5; % in seconds, how long mouse has to be chewing for this to be considered
timeFromReachToMouth=1; % in seconds, reach is only "successful" if paw is raised to mouth within this time window
timeFromReachToChew=2; % in seconds, reach is only "succesful" if chewing within this time window

% For each reach, determine what type of reach it is

pelletSettledForInds=ceil(pelletSettledForTime/(1/movie_fps));
fromPerchInds=ceil(fromPerchWindow/(1/movie_fps));
reachToMouthInds=ceil(timeFromReachToMouth/(1/movie_fps));
reachToChewInds=ceil(timeFromReachToChew/(1/movie_fps));

reachInds=find(reaches.reachPeaks==1);

% Find reach beginnings
reachBegins=nan(1,length(reachInds));
for i=1:length(reachInds)
    % When does this reach begin?
    reachBegins(i)=findReachBeginning(reaches,reachInds(i));
end
reaches.reachBegins=reachBegins;

% Find reach endings
reachEnds=nan(1,length(reachInds));
for i=1:length(reachInds)
    % When does this reach end?
    reachEnds(i)=findReachEnding(reaches,reachInds(i));
end
reaches.reachEnds=reachEnds;

% Find chewing epochs
eat=getChewing(eatData, movie_fps, chewFrequency, chewingThresh);

% Find times when mouse raises paw to mouth
pawMouth=getPawAtMouth(eatData);

reachTypes=nan(1,length(reachInds));
pelletThere=nan(1,length(reachInds));
reachFromPerch=nan(1,length(reachInds));
raisedPaw=nan(1,length(reachInds));
atePellet=nan(1,length(reachInds));
for i=1:length(reachInds)
    % Is a pellet available before this reach begins?
    if all(pelletInPlace.pelletPresent(reachBegins(i)-pelletSettledForInds-1:reachBegins(i)-1)==1)
        % yes
        pelletThere(i)=1;
    else
        % no
        pelletThere(i)=0;
    end
    
    % Does reach begin from perch?
    if any(reaches.isReach(reachBegins(i)-fromPerchInds-1:reachBegins(i)-1)==1)
        % no
        reachFromPerch(i)=0;
    else
        % yes
        reachFromPerch(i)=1;
    end
    
    if (pelletThere(i)==0)
        continue
    end
    
    % Does mouse move the pellet? i.e., grab or miss
    % Is pellet gone at the end of the reach?
    if pelletInPlace.pelletPresent(reachEnds(i)+1)==1
        % mouse did not move pellet, so miss
        reachTypes(i)=missType;
    else
        % mouse did move pellet, so grab
        reachTypes(i)=grabType;
    end
    
    % Did mouse raise paw to mouth?
    if any(pawMouth.isPawAtMouth(reachEnds(i):reachEnds(i)+reachToMouthInds)==1)
        % yes
        raisedPaw(i)=1;
    else
        raisedPaw(i)=0;
    end
     
    % Did mouse eat after this reach?
    if any(eat.isChewing(reachEnds(i):reachEnds(i)+reachToChewInds)==1)
        % yes
        atePellet(i)=1;
    else
        atePellet(i)=0;
    end
    
    % Successful eat or drop?
    if (reachTypes(i)==grabType) && (raisedPaw(i)==1) && (atePellet(i)==1)
       % Assign succesful reach only to one reach per paw-to-mouth/eat
       % Find reach closest in time to paw-to-mouth/eat
       
        
    else
        reachTypes(i)=dropType;
    end
end



end

function out=findReachBeginning(reaches,currReachInd)

if reaches.isReach(currReachInd)==0
    % is not reach
    out=nan;
    return
end
for i=currReachInd-1:-1:1
    if reaches.isReach(i)==0
        % no longer in this reach
        out=i+1;
        return
    end
end
out=1;

end

function out=findReachEnding(reaches,currReachInd)

if reaches.isReach(currReachInd)==0
    % is not reach
    out=nan;
    return
end
for i=currReachInd+1:length(reaches.isReach)
    if reaches.isReach(i)==0
        % no longer in this reach
        out=i-1;
        return
    end
end
out=length(reaches.isReach);

end
