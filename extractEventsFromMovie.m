function [out,zoneVals,reaches,pellets,eat,paw,fidget,settings]=extractEventsFromMovie(zonesFile, movieFile, zoneVals)

settings=autoReachAnalysisSettings(); % get current settings for this analysis
settings.zonesFile=zonesFile;
settings.movieFile=movieFile; 

% Read intensity in user-defined zones over course of movie
if isempty(zoneVals)
    zoneVals=readIntensityValues(zonesFile, movieFile);
    readZoneVals=1;
else
    readZoneVals=0;
end

% Save zone data
if settings.saveZoneData==1 && readZoneVals==1
    endoffname=regexp(movieFile,'\.');
    save([movieFile(1:endoffname(end)-1) '_zoneVals.mat'],'zoneVals');
end

% Save analysis settings
if settings.saveZoneData==1
    endoffname=regexp(movieFile,'\.');
    save([movieFile(1:endoffname(end)-1) '_settings.mat'],'settings');
end

% Discard first n frames
f=fieldnames(zoneVals);
for i=1:length(f)
    temp=zoneVals.(f{i});
    zoneVals.(f{i})=temp(settings.discardFirstNFrames+1:end);
end

% Get reach data
reaches=getReaches(zoneVals.reachZone);

% Get pellet data
pellets=getPelletInPlace(zoneVals.pelletZone);

% Get chewing data
eat=getChewing(zoneVals.eatZone);

% Get paw at mouth data
paw=getPawAtMouth(zoneVals.eatZone);

% Get fidgeting in perch zone data
fidget=getFidget(zoneVals.perchZone);

% Get licking
if isfield(zoneVals,'lickZone')
    licks=getLicks(zoneVals.lickZone);
    eat.licks=licks;
end

% Remove "eating" classification while mouse is licking
% eat=removeLicksFromEat(eat);

% Check if mouse is grooming
if settings.checkForGrooming==1
    eat=checkForGrooming(eat,settings);
    pause;
end

[~,out]=codeEvents(reaches,pellets,eat,paw,fidget); 

% Save output
if settings.saveZoneData==1
    endoffname=regexp(movieFile,'\.');
    save([movieFile(1:endoffname(end)-1) '_events.mat'],'out');
    save([movieFile(1:endoffname(end)-1) '_reaches.mat'],'reaches');
    save([movieFile(1:endoffname(end)-1) '_pellets.mat'],'pellets');
    save([movieFile(1:endoffname(end)-1) '_eat.mat'],'eat');
    save([movieFile(1:endoffname(end)-1) '_paw.mat'],'paw');
    save([movieFile(1:endoffname(end)-1) '_fidget.mat'],'fidget');
end

end