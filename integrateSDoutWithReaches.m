function alignment=integrateSDoutWithReaches(reaches,out,moviefps,alignment,savedir)

% Will need to fix some file alignments by lining up cue onsets and offsets
if isempty(alignment)
    alignment=getAlignment([],out,[],[],moviefps,[],reaches);
    save([savedir '\alignment.mat'], 'alignment');
end

% Remove incomplete reach detections
% isnotnaninds=~isnan(mean([reaches.reachStarts' reaches.pelletTime' reaches.eatTime' reaches.pelletPresent'],2)) & (reaches.pelletTime'-reaches.reachStarts'>=0);
isnotnaninds=~isnan(mean([reaches.reachStarts' reaches.pelletTime' reaches.eatTime'],2)) & (reaches.pelletTime'-reaches.reachStarts'>=0);
reaches.reachStarts=reaches.reachStarts(isnotnaninds);
reaches.pelletTouched=reaches.pelletTouched(isnotnaninds);
reaches.pelletTime=reaches.pelletTime(isnotnaninds);
reaches.atePellet=reaches.atePellet(isnotnaninds);
reaches.eatTime=reaches.eatTime(isnotnaninds);
reaches.pelletMissing=reaches.pelletMissing(isnotnaninds);
% Flip pellet present because actually saved 1 if pellet MISSING
reaches.pelletMissing=reaches.pelletMissing==0;

% % Make sure reach time, then pellet time, then eat time all line up
% take_reachStarts=nan(size(reaches.reachStarts));
% take_pelletTimes=nan(size(reaches.reachStarts));
% take_eatTimes=nan(size(reaches.reachStarts));
% for i=1:length(reaches.reachStarts)
%     if ~isnan(reaches.reachStarts(i))
%         take_reachStarts(i)=reaches.reachStarts(i);
%         take_pelletTimes(i)=reaches.pelletTime(find(reaches.pelletTime>=reaches.reachStarts(i),1,'first'));
%         take_eatTimes(i)=reaches.eatTime(find(reaches.eatTime>=reaches.reachStarts(i),1,'first'));
%     end
% end
% reaches.reachStarts=take_reachStarts;
% reaches.pelletTime=take_pelletTimes;
% reaches.eatTime=take_eatTimes;

% Fix lengths
% minlength=min([length(reaches.reachStarts) length(reaches.pelletTouched) length(reaches.pelletTime) length(reaches.atePellet) length(reaches.eatTime)]);
% reaches.reachStarts=reaches.reachStarts(1:minlength);
% reaches.pelletTouched=reaches.pelletTouched(1:minlength);
% reaches.pelletTime=reaches.pelletTime(1:minlength);
% reaches.atePellet=reaches.atePellet(1:minlength);
% reaches.eatTime=reaches.eatTime(1:minlength);

% Add other events 
movframes=alignment.movieframeinds;
% Initiation of reach
alignment.reachStarts=restructureEvent(reaches.reachStarts, movframes);
% End of reach
alignment.reachEnds=restructureEvent(reaches.pelletTime, movframes);
% Successful reach (mouse eats pellet) -- initiation of successful reach
alignment.success_reachStarts=restructureEvent(reaches.reachStarts(reaches.atePellet==1 & reaches.pelletMissing==1), movframes);
% Drop (paw touches pellet, but mouse drops pellet before eating it) --
% initiation of reach
alignment.drop_reachStarts=restructureEvent(reaches.reachStarts(reaches.pelletTouched==1 & reaches.atePellet==0 & reaches.pelletMissing==1), movframes);
% Miss (paw never touches pellet) -- initiation of reach
alignment.miss_reachStarts=restructureEvent(reaches.reachStarts(reaches.pelletTouched==0 & reaches.pelletMissing==1), movframes);
% Reach despite no pellet -- initiation of reach
alignment.pelletmissingreach_reachStarts=restructureEvent(reaches.reachStarts(reaches.pelletMissing==0), movframes);
% Eat time
alignment.eating=restructureEvent(reaches.eatTime(reaches.atePellet==1), movframes);
% Reach ongoing
alignment.reach_ongoing=zeros(1,length(movframes));
reachIsStarting=find(alignment.reachStarts>0.5);
reachIsEnding=find(alignment.reachEnds>0.5);
for i=1:length(reachIsStarting)
   alignment.reach_ongoing(reachIsStarting(i):reachIsEnding(i))=1;
end

% Save data
save([savedir '\final_aligned_data.mat'],'alignment');

end

function eventVector=restructureEvent(eventFrames, movieFrames)

eventFrames=eventFrames(~isnan(eventFrames));
eventVector=zeros(1,length(movieFrames));
for i=1:length(eventFrames)
%    [~,mi]=min(abs(movieFrames-eventFrames(i)));
   temp=movieFrames-eventFrames(i);
   temp(temp<0)=max(temp)+10000;
   [~,mi]=min(temp); 
   eventVector(mi)=1;    
end

end
