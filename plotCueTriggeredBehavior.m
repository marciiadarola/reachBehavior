function tbt=plotCueTriggeredBehavior(data,nameOfCue)

% nameOfCue should be 'cue' for real cue
% 'arduino_distractor' for distractor

cue=data.(nameOfCue); 

[pks,locs]=findpeaks(cue);
% cueInds=find(cue>0.5);
cueInds=locs(pks>0.5);
cueIndITIs=diff(cueInds);
smallestTrial=min(cueIndITIs(cueIndITIs>10));

% Get data
distractor=data.arduino_distractor;
pelletLoaded=data.pelletLoaded;
pelletPresented=data.pelletPresented;
reachStarts=data.reachStarts;
reach_ongoing=data.reach_ongoing;
success=data.success_reachStarts;
drop=data.drop_reachStarts;
miss=data.miss_reachStarts;
eating=data.eating;
timesFromArduino=data.timesfromarduino; % in ms
timesFromArduino=timesFromArduino./1000; % in seconds
movieframeinds=data.movieframeinds;

% Trial-by-trial, tbt
cue_tbt=nan(length(cueInds),max(cueIndITIs));
distractor_tbt=nan(length(cueInds),max(cueIndITIs));
pelletLoaded_tbt=nan(length(cueInds),max(cueIndITIs));
pelletPresented_tbt=nan(length(cueInds),max(cueIndITIs));
reachStarts_tbt=nan(length(cueInds),max(cueIndITIs));
reach_ongoing_tbt=nan(length(cueInds),max(cueIndITIs));
success_tbt=nan(length(cueInds),max(cueIndITIs));
drop_tbt=nan(length(cueInds),max(cueIndITIs));
miss_tbt=nan(length(cueInds),max(cueIndITIs));
eating_tbt=nan(length(cueInds),max(cueIndITIs));
times_tbt=nan(length(cueInds),max(cueIndITIs));
movieframeinds_tbt=nan(length(cueInds),max(cueIndITIs));

for i=1:length(cueInds)
    if i==length(cueInds)
        theseInds=cueInds(i):length(cue);
    else
        theseInds=cueInds(i):cueInds(i+1)-1;
    end
    cue_tbt(i,1:length(theseInds))=cue(theseInds);
    distractor_tbt(i,1:length(theseInds))=distractor(theseInds);
    pelletLoaded_tbt(i,1:length(theseInds))=pelletLoaded(theseInds);
    pelletPresented_tbt(i,1:length(theseInds))=pelletPresented(theseInds);
    reachStarts_tbt(i,1:length(theseInds))=reachStarts(theseInds);
    reach_ongoing_tbt(i,1:length(theseInds))=reach_ongoing(theseInds);
    success_tbt(i,1:length(theseInds))=success(theseInds);
    drop_tbt(i,1:length(theseInds))=drop(theseInds);
    miss_tbt(i,1:length(theseInds))=miss(theseInds);
    eating_tbt(i,1:length(theseInds))=eating(theseInds); 
    times_tbt(i,1:length(theseInds))=timesFromArduino(theseInds); 
    movieframeinds_tbt(i,1:length(theseInds))=movieframeinds(theseInds); 
end

% cue_tbt=cue_tbt(:,1:smallestTrial);
% distractor_tbt=distractor_tbt(:,1:smallestTrial);
% pelletLoaded_tbt=pelletLoaded_tbt(:,1:smallestTrial);
% pelletPresented_tbt=pelletPresented_tbt(:,1:smallestTrial);
% reachStarts_tbt=reachStarts_tbt(:,1:smallestTrial);
% reach_ongoing_tbt=reach_ongoing_tbt(:,1:smallestTrial);
% success_tbt=success_tbt(:,1:smallestTrial);
% drop_tbt=drop_tbt(:,1:smallestTrial);
% miss_tbt=miss_tbt(:,1:smallestTrial);
% eating_tbt=eating_tbt(:,1:smallestTrial);
% times_tbt=times_tbt(:,1:smallestTrial);
% movieframeinds_tbt=movieframeinds_tbt(:,1:smallestTrial);

% Zero out
cue_tbt(isnan(cue_tbt))=0;
distractor_tbt(isnan(distractor_tbt))=0;
pelletLoaded_tbt(isnan(pelletLoaded_tbt))=0;
pelletPresented_tbt(isnan(pelletPresented_tbt))=0;
reachStarts_tbt(isnan(reachStarts_tbt))=0;
reach_ongoing_tbt(isnan(reach_ongoing_tbt))=0;
success_tbt(isnan(success_tbt))=0;
drop_tbt(isnan(drop_tbt))=0;
miss_tbt(isnan(miss_tbt))=0;
eating_tbt(isnan(eating_tbt))=0;

% Take only trials where movie video also available
% isemptytrials=isnan(nanmean(movieframeinds_tbt,2));
% cue_tbt=cue_tbt(~isemptytrials,:);
% distractor_tbt=distractor_tbt(~isemptytrials,:);
% pelletLoaded_tbt=pelletLoaded_tbt(~isemptytrials,:);
% pelletPresented_tbt=pelletPresented_tbt(~isemptytrials,:);
% reachStarts_tbt=reachStarts_tbt(~isemptytrials,:);
% reach_ongoing_tbt=reach_ongoing_tbt(~isemptytrials,:);
% success_tbt=success_tbt(~isemptytrials,:);
% drop_tbt=drop_tbt(~isemptytrials,:);
% miss_tbt=miss_tbt(~isemptytrials,:);
% eating_tbt=eating_tbt(~isemptytrials,:);
% times_tbt=times_tbt(~isemptytrials,:);
% movieframeinds_tbt=movieframeinds_tbt(~isemptytrials,:);

tbt.cue_tbt=cue_tbt;
tbt.distractor_tbt=distractor_tbt;
tbt.pelletLoaded_tbt=pelletLoaded_tbt;
tbt.pelletPresented_tbt=pelletPresented_tbt;
tbt.reachStarts_tbt=reachStarts_tbt;
tbt.reach_ongoing_tbt=reach_ongoing_tbt;
tbt.success_tbt=success_tbt;
tbt.drop_tbt=drop_tbt;
tbt.miss_tbt=miss_tbt;
tbt.eating_tbt=eating_tbt;
tbt.times_tbt=times_tbt;
tbt.movieframeinds_tbt=movieframeinds_tbt;

times_tbt=times_tbt-repmat(nanmin(times_tbt,[],2),1,size(times_tbt,2));
timespertrial=nanmean(times_tbt,1);
% timespertrial=1:length(timespertrial);

% Plot
plot_cues=1:size(cue_tbt,1);
figure();
ha=tight_subplot(10,1,[0.06 0.03],[0.05 0.05],[0.1 0.03]);
currha=ha(1);
axes(currha);
plot(timespertrial,nanmean(cue_tbt(plot_cues,:),1));
title('cue');

currha=ha(2);
axes(currha);
plot(timespertrial,nanmean(reachStarts_tbt(plot_cues,:),1));
title('reachStarts');

currha=ha(3);
axes(currha);
plot(timespertrial,nanmean(distractor_tbt(plot_cues,:),1));
title('distractor');

currha=ha(4);
axes(currha);
plot(timespertrial,nanmean(reach_ongoing_tbt(plot_cues,:),1));
title('reach ongoing');

currha=ha(5);
axes(currha);
plot(timespertrial,nanmean(success_tbt(plot_cues,:),1));
title('success');

currha=ha(6);
axes(currha);
plot(timespertrial,nanmean(pelletPresented_tbt(plot_cues,:),1));
title('pelletPresented');

currha=ha(7);
axes(currha);
plot(timespertrial,nanmean(drop_tbt(plot_cues,:),1));
title('drop');

currha=ha(8);
axes(currha);
plot(timespertrial,nanmean(miss_tbt(plot_cues,:),1));
title('miss');

currha=ha(9);
axes(currha);
plot(timespertrial,nanmean(eating_tbt(plot_cues,:),1));
title('eating');

currha=ha(10);
axes(currha);
plot(timespertrial,nanmean(pelletLoaded_tbt(plot_cues,:),1));
title('pelletLoaded');


% Also plot experiment as events in a scatter plot
cue_color='b';
reach_color='k';
success_color='g';
drop_color='r';
drop_outline='k';
miss_color='r';
miss_outline='c';

event_thresh=0.5;

figure();
% for i=1:size(cue_tbt,1)
for i=plot_cues
    % Plot cue events
    event_ind=find(cue_tbt(i,:)>event_thresh,1,'first');
    scatter([timespertrial(event_ind) timespertrial(event_ind)],[i i],[],cue_color,'filled');
    hold on;
    % Plot reach start events
    event_ind=find(reachStarts_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[i i],[],reach_color,'filled');
    end
    % Plot success events
    event_ind=find(success_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[i i],[],success_color,'filled');
    end
    % Plot drop events
    event_ind=find(drop_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[i i],[],'MarkerEdgeColor',drop_outline,...
              'MarkerFaceColor',drop_color,...
              'LineWidth',1.5);
    end
    % Plot miss events
    event_ind=find(miss_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[i i],[],'MarkerEdgeColor',miss_outline,...
              'MarkerFaceColor',miss_color,...
              'LineWidth',1.5);
    end
end
