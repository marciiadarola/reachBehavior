function [out,zoneVals,reaches,pellets,eat,paw,fidget,settings]=extractEventsFromMovie(zonesFile, movieFile)

settings=autoReachAnalysisSettings(); % get current settings for this analysis
settings.zonesFile=zonesFile;
settings.movieFile=movieFile;

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

% Get fidgeting in perch zone data
fidget=getFidget(zoneVals.perchZone);

[~,out]=codeEvents(reaches,pellets,eat,paw,fidget);