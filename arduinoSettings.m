function settings=arduinoSettings()

% For parseSerialOut.m

settings.loadEveryTrial=1; % if 1, pellet is loaded exactly once per trial, else set to 0
settings.usingopto=1; % if 1, using opto
settings.noEncoder=1; % no encoder on behavior rig

settings.maxITI=13000; % maximum duration of trial in ms
settings.showExampleTrial=1; % 1 if want to show example trial

% State of behavior rig on 12/6/2017
settings.beginTrialWrite=0;
settings.loaderWriteCode=1;
settings.pelletsWriteCode=2;
settings.optoWriteCode=3;
settings.cueWriteCode=4;
settings.distractorWriteCode=5;
settings.interlockWriteCode=6;

settings.dropWriteCode=1000; % unused
settings.missWriteCode=1000; % unused
settings.encoderWriteCode=1000; % unused

% Fix for bug in Arduino output
% Fixed Arduino code on 12/8/2017
% Expected timing of various trial events
settings.expectedTime.cue=1514; % in ms with respect to trial onset
settings.expectedTime.beginPelletWheel=27; % in ms with respect to trial onset



% Previous state of behavior rig
% settings.usingopto=0; % if 1, using opto
% settings.noEncoder=1; % no encoder on behavior rig
% 
% settings.maxITI=30000; % maximum duration of trial in ms
% settings.showExampleTrial=1;
%
% settings.beginTrialWrite=0;
% settings.loaderWriteCode=1;
% settings.pelletsWriteCode=2;
% settings.encoderWriteCode=3;
% settings.cueWriteCode=4;
% settings.distractorWriteCode=5;
% settings.dropWriteCode=6;
% settings.missWriteCode=7; 
% 
% settings.optoWriteCode=1000; % unused
% settings.interlockWriteCode=1000; % unused
