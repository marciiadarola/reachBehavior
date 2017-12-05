function [out,zoneVals,reaches,pellets,eat,paw]=extractEventsFromMovie(zonesFile, movieFile)

% Read intensity in user-defined zones over course of movie
zoneVals=readIntensityValues(zonesFile, movieFile);

% Get reach data
reaches=getReaches(zoneVals.reachZone);

% Get pellet data
pellets=getPelletInPlace(zoneVals.pelletZone);

% Get chewing data
eat=getChewing(zoneVals.eatZone);

% Get paw at mouth data
paw=getPawAtMouth(zoneVals.eatZone);

[~,out]=codeEvents(reaches,pellets,eat,paw,zoneVals.perchZone);