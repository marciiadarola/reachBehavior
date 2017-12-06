function settings=autoReachAnalysisSettings()

% user-set constants

% For all
settings.movie_fps=30; % movie frame rate in frames per second

% For getReaches.m
settings.reach.maxReachFrequency=6; % in Hz, the maximum frequency at which mouse can reach
settings.reach.movie_fps=30; % movie frame rate, in frames per second
settings.reach.reachThresh=5; % after non-parametric transformation of reachData
settings.reach.holdThreshold=10; % in seconds -- if any reach lasts longer than 10 s, this is not a reach -- this is a hold
settings.reach.plotOutput=1; % if 1, plot output of reach analysis, else do not plot

% For getPelletInPlace.m
settings.pellet.nScaledMAD=3; % how many scaled median absolute deviations away from median for data point to be called an outlier
settings.pellet.plotOutput=1; % if 1, plot output, else do not plot

% For getChewing.m
settings.chew.added_path='C:\Users\Kim\Documents\MATLAB\chronux_2_11'; % path to Chronux
settings.chew.chewFrequency=[4 6]; % frequency range at which mouse chews in Hz
settings.chew.chewingThresh=5; % in non-parametric Z score metrics, threshold for power in chewing frequency range above which mouse is chewing
settings.chew.tapers=[10 12]; % Chronux mtspecgramc tapers to use for identifying chewing at chewFrequency
settings.chew.fpass=[2 15]; % in Hz, the range for Chronux mtspecgramc
settings.chew.chewingWindow=[7 1]; % in seconds, first element: window for Chronux mtspecgramc to use to calculate power at chewing frequency
                                   % in seconds, second element: step for Chronux mtspecgramc to use to slide window across data
settings.chew.plotOutput=1; % if 1, plot output, else do not plot
                                   
% For pawAtMouth.m
settings.paw.pawAtMouthThresh=15; % intensity threshold for determining when paw is raised to mouth
settings.paw.maxPawAtMouthFreq=5; % in Hz, the maximum frequency at which mouse can repeatedly raise paw to mouth
settings.paw.plotOutput=1; % if 1, plot output, else do not plot 

% For codeEvents.m
settings.pelletSettledForTime=0.066; % time in seconds for pellet to be at proper reach position, before reach begins
settings.fromPerchWindow=0.5; % in seconds, how long the paw must be at perch (i.e., not reaching) before reach, for reach to count as beginning from perch
% Reach type code
settings.missType=1;
settings.grabType=2; % note that grab type should always be overwritten as either eatType or dropType
settings.eatType=3;
settings.dropType=4;
settings.timeFromReachToMouth=1; % in seconds, reach is only "successful" if paw is raised to mouth within this time window
settings.timeFromReachToChew=2; % in seconds, reach is only "succesful" if chewing within this time window
