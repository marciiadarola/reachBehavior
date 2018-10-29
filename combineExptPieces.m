function [alltbt,allmetadata]=combineExptPieces(expt_dir,useAsCue,cueDuration,doRealign)

% cueDuration in seconds

% Also read in data from these files if they exist
tryForFiles={'optoOnHere', 'nth_session','optoThresh'};
for i=1:length(tryForFiles)
    tryFilesOut.(tryForFiles{i})=[];
end

ls=dir(expt_dir);
j=1;
tbt=[];
alltbt=[];
mouseid=[];
sessid=[];
sess_datetime=[];
prevname=[];
k=0;
for i=1:length(ls)
    thisname=ls(i).name;
    thisisdir=ls(i).isdir;
    if ~isempty(regexp(thisname,'processed_data')) && thisisdir==1
        
%         a=load([expt_dir '\' thisname '\tbt_resampled.mat']);
        a=load([expt_dir '\' thisname '\tbt.mat']);
        tbt{j}=a.tbt;
        if exist([expt_dir '\' thisname '\mouse_id.mat'], 'file')==2
            a=load([expt_dir '\' thisname '\mouse_id.mat']);
            mouseid(j)=a.mouse_id;
        else
            mouseid(j)=nan;
        end
        
        for tryCount=1:length(tryForFiles)
            currTryFile=tryForFiles{tryCount};
            if exist([expt_dir '\' thisname '\' currTryFile '.mat'], 'file')==2
                a=load([expt_dir '\' thisname '\' currTryFile '.mat']);
                temp=tryFilesOut.(currTryFile);
                temp(j)=a.(currTryFile);
                tryFilesOut.(currTryFile)=temp;
            else
                temp=tryFilesOut.(currTryFile);
                temp(j)=nan;
                tryFilesOut.(currTryFile)=temp;
            end
        end
        
        if isempty(prevname)
            k=k+1;
        else
            r=regexp(thisname,' ');
            if isempty(regexp(prevname,thisname(1:r-1)))
                k=k+1; % new date
            else
                % dates match -- in same session if mouse id is the same
                if j~=1
                    if isnan(mouseid(j)) && isnan(mouseid(j-1))
                        % assume all the same mouse
                    elseif mouseid(j)~=mouseid(j-1)
                        % different mice
                        k=k+1;
                    else
                        % same mice, same date : thus, same session
                    end
                end
            end
        end
        
        sessid(j)=k;
        r=regexp(thisname,'C');
        sess_datetime{j}=thisname(1:r-2);
        j=j+1;
        prevname=thisname;
    end
end

metadata=cell(1,length(tbt));
for i=1:length(tbt)
    metadata{i}.mouseid=mouseid(i).*ones(size(tbt{i}.times,1),1);
    for j=1:length(tryForFiles)
        currTryFile=tryForFiles{j};
        temp=tryFilesOut.(currTryFile);
        metadata{i}.(currTryFile)=temp(i).*ones(size(tbt{i}.times,1),1);
    end
    metadata{i}.sessid=sessid(i).*ones(size(tbt{i}.times,1),1);
    metadata{i}.sess_datetime=cell(size(tbt{i}.times,1),1);
    for j=1:length(metadata{i}.sess_datetime)
        metadata{i}.sess_datetime{j}=sess_datetime{i};
    end
    % Fix
    if isempty(regexp(metadata{i}.sess_datetime{1},'2018'))
        metadata{i}.sess_datetime=fixChineseDVRDatetime(metadata{i}.sess_datetime);
    end
end

if isempty(tbt)
    disp('No tbt data saved in this directory');
    return
end

f=fieldnames(tbt{1});
for i=1:length(f)
    alltbt.(f{i})=[];
end

f_meta=fieldnames(metadata{1});
for i=1:length(f_meta)
    allmetadata.(f_meta{i})=[];
end

for i=1:length(tbt)
    curr_tbt=tbt{i};
    curr_metadata=metadata{i};
    if i==1
        % first tbt
        for j=1:length(f)
            alltbt.(f{j})=curr_tbt.(f{j});
        end
        % first metadata
        for j=1:length(f_meta)
            allmetadata.(f_meta{j})=curr_metadata.(f_meta{j});
        end
    else
        if size(alltbt.(f{1}),2)<size(curr_tbt.(f{1}),2)
            % expand size, fill with nans
            expandBy=size(curr_tbt.(f{1}),2)-size(alltbt.(f{1}),2);
            for j=1:length(f)
                alltbt.(f{j})=[alltbt.(f{j}) nan(size(alltbt.(f{j}),1),expandBy)];
            end
        elseif size(alltbt.(f{1}),2)>size(curr_tbt.(f{1}),2)
            expandBy=size(alltbt.(f{1}),2)-size(curr_tbt.(f{1}),2);
            for j=1:length(f)
                if isfield(curr_tbt,f{j})
                    curr_tbt.(f{j})=[curr_tbt.(f{j}) nan(size(curr_tbt.(f{j}),1),expandBy)];
                end
            end
        end
        % concat
        for j=1:length(f)
            if isfield(curr_tbt,f{j})
                alltbt.(f{j})=[alltbt.(f{j}); curr_tbt.(f{j})];
            end
        end
        for j=1:length(f_meta)
            if isfield(curr_metadata,f_meta{j})
                allmetadata.(f_meta{j})=[allmetadata.(f_meta{j}); curr_metadata.(f_meta{j})];
            end
        end
    end
end

if doRealign==1
    alltbt=realignToCue_usingCueZone(alltbt,useAsCue,cueDuration);
end

% % Set all reaches to 1's
% Assumption is that mouse cannot perform 2 reaches within the same time
% bin (i.e., time bin is small enough to ensure this)
f=fieldnames(alltbt);
for i=1:length(f)
    if ~isempty(strfind(f{i},'reach'))
        temp=alltbt.(f{i});
        temp(temp>0)=1;
        alltbt.(f{i})=temp;
    end
end

alltbt.reachStarts_noPawOnWheel=alltbt.reachStarts;
settings=RTanalysis_settings;
lowThresh=settings.lowThresh;
alltbt.reachStarts_noPawOnWheel(alltbt.pawOnWheel>lowThresh)=0;

% If optoThresh is specified, re-get opto on
if isfield(allmetadata,'optoThresh')
    alltbt.optoOn=alltbt.optoZone>repmat(allmetadata.optoThresh,1,size(alltbt.optoZone,2));
end


function realign_tbt=realignToCue_usingCueZone(tbt,useAsCue,cueDuration)

settings=RTanalysis_settings;
lowThresh=settings.lowThresh;

% was each cue detection at the beginning or end of cue?
cueDurationInds=floor(cueDuration/mode(diff(nanmean(tbt.times,1))));

% line up cues

% find first cue ind on
cue=tbt.(useAsCue);
[~,cueind]=max(nanmean(cue,1));

cueZone=tbt.cueZone;

f=fieldnames(tbt);
for i=1:length(f)
    realign_tbt.(f{i})=nan(size(tbt.(f{i})));
end

realign_check=nan(size(cue,1),2*cueDurationInds+1);
fi=nan(1,size(cue,1));
for i=1:size(cue,1)
    temp=find(cue(i,:)>lowThresh,1,'first');
    % if cue is missing from this trial, drop this trial
    if isempty(temp)
        fi(i)=nan;
    else
        fi(i)=temp;
        % what does cue zone look like surrounding this point?
        if temp-cueDurationInds<1 || temp+cueDurationInds>size(cueZone,2)
            continue
        end
        if nanmean(cueZone(i,temp-cueDurationInds:temp))<nanmean(cueZone(i,temp:temp+cueDurationInds)) % this is beginning of cue
            % leave alone
        else % this is end of cue
            fi(i)=temp-(cueDurationInds-2);
        end
        if fi(i)-cueDurationInds<1 || fi(i)+cueDurationInds>size(cueZone,2)
            continue
        end
        realign_check(i,:)=cueZone(i,fi(i)-cueDurationInds:fi(i)+cueDurationInds); % this is with fixed temp
    end
end

% realign cue and rest of fields
for i=1:length(f)
    currfield=tbt.(f{i});
    newfield=nan(size(currfield));
    if size(currfield,1)~=size(tbt.(useAsCue),1)
        % skip this
        continue
    end
    for j=1:size(cue,1)
        % realign each trial
        if isnan(fi(j))
            % exclude this trial
            % nan out
            temp=nan(size(currfield(j,:)));
        elseif fi(j)==cueind
            % already aligned
            temp=currfield(j,:);
        elseif fi(j)<cueind
            % shift back in time
            temp=[nan(1,cueind-fi(j)) currfield(j,1:end-(cueind-fi(j)))];
        elseif fi(j)>cueind
            % shift forward in time
            temp=[currfield(j,1+(fi(j)-cueind):end) nan(1,fi(j)-cueind)];
        end
        newfield(j,:)=temp;
    end
    % save into tbt
    realign_tbt.(f{i})=newfield;
end
            
% check alignment
figure(); 
plot(realign_tbt.(useAsCue)');
title('Re-aligned cues');

% Make cue uniform across trials, now that aligned
av=nanmean(realign_tbt.(useAsCue),1);
ma=max(av);
av(av<ma)=0;
realign_tbt.(useAsCue)=repmat(av,size(realign_tbt.(useAsCue),1),1);

figure();
plot(realign_check');
title('Re-aligned cue zone');
        