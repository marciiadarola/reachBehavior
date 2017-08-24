function plotExptOutput(tbt,excludePawOnWheelTrials)

addTimeFromCueMax=0.125+0.033;
nbins=100; % bins for final histogram

cue_tbt=tbt.cue_tbt;
distractor_tbt=tbt.distractor_tbt;
pelletLoaded_tbt=tbt.pelletLoaded_tbt;
pelletPresented_tbt=tbt.pelletPresented_tbt;
reachStarts_tbt=tbt.reachStarts_tbt;
reach_ongoing_tbt=tbt.reach_ongoing_tbt;
success_tbt=tbt.success_tbt;
drop_tbt=tbt.drop_tbt;
miss_tbt=tbt.miss_tbt;
eating_tbt=tbt.eating_tbt;
times_tbt=tbt.times_tbt;
movieframeinds_tbt=tbt.movieframeinds_tbt;
reach_wout_pellet_tbt=tbt.reach_wout_pellet_tbt;
paw_from_wheel_tbt=tbt.paw_from_wheel_tbt;
success_pawOnWheel_tbt=tbt.success_pawOnWheel_tbt;
drop_pawOnWheel_tbt=tbt.drop_pawOnWheel_tbt;
miss_pawOnWheel_tbt=tbt.miss_pawOnWheel_tbt;
reach_pelletPresent_tbt=tbt.reach_pelletPresent_tbt;


times_tbt=times_tbt-repmat(nanmin(times_tbt,[],2),1,size(times_tbt,2));
timespertrial=nanmean(times_tbt,1);
% timespertrial=1:length(timespertrial);

% Exclude trials where paw was on wheel while wheel turning
if excludePawOnWheelTrials==1
    % Find trials where paw was on wheel while wheel turning
    plot_cues=[];
    for i=1:size(cue_tbt,1)
        presentInd=find(pelletPresented_tbt(i,:)>0.5,1,'first');
        cueInd=find(cue_tbt(i,:)>0.5,1,'first');
        pawWasOnWheel=0;
        if any(paw_from_wheel_tbt(i,presentInd:cueInd)>0.5)
            pawWasOnWheel=1;
        else
            plot_cues=[plot_cues i];
        end
    end
else
    plot_cues=1:size(cue_tbt,1);
end

% Plot
figure();
ha=tight_subplot(11,1,[0.06 0.03],[0.05 0.05],[0.1 0.03]);
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
plot(timespertrial,nanmean(reach_wout_pellet_tbt(plot_cues,:),1));
title('reach pellet absent');

currha=ha(10);
axes(currha);
plot(timespertrial,nanmean(eating_tbt(plot_cues,:),1));
title('eating');

currha=ha(11);
axes(currha);
plot(timespertrial,nanmean(pelletLoaded_tbt(plot_cues,:),1));
title('pelletLoaded');


% Also plot experiment as events in a scatter plot
cue_color='b';
% reach_color='k';
success_color='g';
drop_color='r';
drop_outline='none';
miss_color='c';
miss_outline='none';
nopellet_outline=[0.8 0.8 0.8];
nopellet_color=[0.8 0.8 0.8];
wheel_turns_color='k';
pawwheel_color='y';

event_thresh=0.2;


figure();
% for i=1:size(cue_tbt,1)
k=1;
timesOfSuccess_givenPellet=[];
timesOfReach_givenPellet=[];
timesOfReach_starts=[];
for i=plot_cues
    % Plot paw from wheel reach events
    event_ind=find(success_pawOnWheel_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[k k],[],'MarkerEdgeColor',success_color,...
              'MarkerFaceColor',pawwheel_color,...
              'LineWidth',1.5);
          hold on;
    end
    
    event_ind=find(drop_pawOnWheel_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[k k],[],'MarkerEdgeColor',drop_color,...
              'MarkerFaceColor',pawwheel_color,...
              'LineWidth',1.5);
    end
    
    event_ind=find(miss_pawOnWheel_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[k k],[],'MarkerEdgeColor',miss_color,...
              'MarkerFaceColor',pawwheel_color,...
              'LineWidth',1.5);
    end
    
    % Plot reach despite no pellet events
    event_ind=find(reach_wout_pellet_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[k k],[],'MarkerEdgeColor',nopellet_outline,...
              'MarkerFaceColor',nopellet_color,...
              'LineWidth',1.5);
    end
    % Plot cue events
    eventThresh=0.5;
    event_ind=find(cue_tbt(i,:)>event_thresh,1,'first');
%     event_ind=find(cue_tbt(i,:)>event_thresh);
    if isempty(event_ind)
        error('no cue for this trial'); 
    end
%     for j=1:length(event_ind)
%         scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[k k],[],cue_color,'filled');
%     end
    scatter([timespertrial(event_ind)-addTimeFromCueMax timespertrial(event_ind)-addTimeFromCueMax],[k k],[],cue_color,'filled');
    currcuetime=timespertrial(event_ind)-addTimeFromCueMax;
    hold on;
    event_thresh=0.2;
    % Plot reach start events
%     event_ind=find(reachStarts_tbt(i,:)>event_thresh);
    if excludePawOnWheelTrials==1
        timesOfReach_givenPellet=[timesOfReach_givenPellet timespertrial(reachStarts_tbt(i,:)>event_thresh & paw_from_wheel_tbt(i,:)<event_thresh & reach_pelletPresent_tbt(i,:)>event_thresh)];
    else
        timesOfReach_givenPellet=[timesOfReach_givenPellet timespertrial(reachStarts_tbt(i,:)>event_thresh & reach_pelletPresent_tbt(i,:)>event_thresh)];
    end
    timesOfReach_starts=[timesOfReach_starts timespertrial(reachStarts_tbt(i,:)>event_thresh)-currcuetime];
%     for j=1:length(event_ind)
%         scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[i i],[],reach_color,'filled');
%     end
    % Plot wheel begins to turn events
    event_thresh=0.5;
    event_ind=find(pelletPresented_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j))-0.2 timespertrial(event_ind(j))-0.2],[k k],[],wheel_turns_color,'filled');
    end
    event_thresh=0.2;
    % Plot success events
    event_ind=find(success_tbt(i,:)>event_thresh);
    timesOfSuccess_givenPellet=[timesOfSuccess_givenPellet timespertrial(event_ind)];
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[k k],[],success_color,'filled');
    end
    % Plot drop events
    event_ind=find(drop_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[k k],[],'MarkerEdgeColor',drop_outline,...
              'MarkerFaceColor',drop_color,...
              'LineWidth',1.5);
    end
    % Plot miss events
    event_ind=find(miss_tbt(i,:)>event_thresh);
    for j=1:length(event_ind)
        scatter([timespertrial(event_ind(j)) timespertrial(event_ind(j))],[k k],[],'MarkerEdgeColor',miss_outline,...
              'MarkerFaceColor',miss_color,...
              'LineWidth',1.5);
    end
    k=k+1;
end

% Plot histogram of reach starts relative to cue
temp=nanmean(cue_tbt(plot_cues,:),1);
[~,mi]=max(temp);
cuetime=timespertrial(mi);
% [n,x]=hist(timesOfReach_starts,100);
[n,x]=hist(timesOfReach_starts+cuetime,nbins);
figure();
plot(x,n);
ma=max(n);
hold on;
plot(timespertrial,temp.*(ma/max(temp)),'Color','r');
title('Histogram of all reach starts');
temp=nanmean(pelletPresented_tbt(plot_cues,:),1);
plot(timespertrial,temp.*(ma/max(temp)),'Color','k');