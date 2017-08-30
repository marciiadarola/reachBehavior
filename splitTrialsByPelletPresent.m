function pelletPresentThisTrial=splitTrialsByPelletPresent(tbt)

pointsFromPreviousTrial=100; % should match value in plotCueTriggeredBehavior.m

pelletPresentThisTrial=zeros(1,size(tbt.cue_tbt,1));
for i=1:size(tbt.cue_tbt,1)
    firstReachInd=find(tbt.reachStarts_tbt(i,pointsFromPreviousTrial:end)>0.5,1,'first');
    if tbt.reach_wout_pellet_tbt(i,pointsFromPreviousTrial+firstReachInd-1)>0.5 & ~any(tbt.reach_pelletPresent_tbt(i,30:pointsFromPreviousTrial)>0)
        % no pellet this trial
        pelletPresentThisTrial(i)=0;
    else
        % pellet is present this trial
        pelletPresentThisTrial(i)=1;
    end
end