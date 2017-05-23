function varargout = findReaches(varargin)
% FINDREACHES MATLAB code for findReaches.fig
%      FINDREACHES, by itself, creates a new FINDREACHES or raises the existing
%      singleton*.
%
%      H = FINDREACHES returns the handle to a new FINDREACHES or the handle to
%      the existing singleton*.
%
%      FINDREACHES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINDREACHES.M with the given input arguments.
%
%      FINDREACHES('Property','Value',...) creates a new FINDREACHES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before findReaches_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to findReaches_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help findReaches

% Last Modified by GUIDE v2.5 22-May-2017 18:05:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @findReaches_OpeningFcn, ...
                   'gui_OutputFcn',  @findReaches_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before findReaches is made visible.
function findReaches_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to findReaches (see VARARGIN)

% Define some global variables for communication with perchZoneGUI
global zoneVertices
global continueAnalysis

continueAnalysis=0;

% Settings
framesPerChunk=500;
n_consec=3;
frames_before_firstReachFrame=2;
frames_after_firstReachFrame=50;
nFramesBetweenReaches=10;
sizeoneback=100;

% Choose default command line output for findReaches
handles.output = hObject;

% Set up handles
handles.useAsThresh=[];
handles.filename=[];
handles.n_consec=[];
handles.isin=[];
handles.reachStarts=[];
handles.pelletTouched=[];
handles.pelletTime=[];
handles.atePellet=[];
handles.eatTime=[];
handles.reachIsDone=[];
handles.curr_start_done=[];
handles.curr_pellet_done=[];
handles.curr_eat_done=[]; 
handles.frames_before_firstReachFrame=[];
handles.frames_after_firstReachFrame=[];
handles.nFramesBetweenReaches=[];
handles.didReachForThisChunk=[];
handles.movieChunk=[];
handles.startsAtFrame=[];
handles.framesPerChunk=[];
handles.allReachesTally=[];
handles.startedOver=[];
handles.sizeOfLastChunk=[];
handles.sizeoneback=[];
handles.isin2=[];
handles.LEDvals=[];
handles.addIn=0;
handles.reachStarts_belongToReach=[];
handles.pelletTouched_belongToReach=[];
handles.pelletTime_belongToReach=[];
handles.atePellet_belongToReach=[];
handles.eatTime_belongToReach=[];
handles.showedMoreVideo=0;
handles.pelletIsMissing=0;
handles.pelletPresent=[];

% Close all open figures except findReaches GUI
set(hObject, 'HandleVisibility', 'off');
close all;
set(hObject, 'HandleVisibility', 'on');

% Get file name of video with reaches
filename=varargin{1};
perchdata=varargin{2}; % filename of .mat file containing information about perch zone and reach threshold

% Check whether user has already defined perch zone for this movie
if ~isempty(perchdata)
    a=load(perchdata);
    perch=a.perch;
    useAsThresh=perch.useAsThresh;
    n_consec=perch.n_consec;
    isin=perch.isin;
end

if isempty(perchdata)
    % Instructions to user
    continuebutton=questdlg('Pause movie at a frame with both paws on perch. Then press "enter" at command line. Understood?','Instructions 1','Yes','Cancel','Cancel');
    switch continuebutton
        case 'Yes'
        case 'Cancel'
            return
    end
end

% Set up approach for indexing movie chunks into whole movie
movieChunk=[];
startsAtFrame=[];
didReachForThisChunk=[];

% Read beginning of movie
videoFReader = vision.VideoFileReader(filename,'PlayCount',1,'ImageColorSpace','YCbCr 4:2:2');
n=framesPerChunk; % How many frames to read initially
movieChunk=[movieChunk 1];
startsAtFrame=[startsAtFrame 1];
for i=1:n
    [frame,~,~,EOF]=step(videoFReader);
    if EOF==true
        n=i-1;
        allframes=allframes(:,:,i-1);
        break
    end
    if i==1
        allframes=nan([size(frame,1) size(frame,2) n]);
    end
    allframes(:,:,i)=frame;
end
startsAtFrame=[startsAtFrame n+1];
movieChunk=[movieChunk movieChunk(end)+1];
handles.oneback=allframes(:,:,end-sizeoneback);

handles.LEDvals=[];
if isempty(perchdata)
    % Play movie until both hands are on perch
    fig=implay(allframes);
    fig.Parent.Position=[100 100 800 800];
    pause;
    currentFrameNumber=fig.data.Controls.CurrentFrame;
    lastFrameDisplayed=startsAtFrame(end-1)+size(allframes,3)-1;
    firstFrameDisplayed=startsAtFrame(end-1);
    
    % Close implay fig, reopen an image so user can draw in perch area
    disp('Stopped at frame number');
    disp(currentFrameNumber);
    close(fig);
    perchFig=perchZoneGUI(allframes(:,:,currentFrameNumber));
    disp('Press "enter" once have defined perch zone.');
    pause;
    perchVertices=zoneVertices;
    
    if continueAnalysis==1
        disp('Perch zone succesfully defined.');
    else
        disp('Failed to define perch zone.');
    end
    
    close(perchFig);
    
    % Get distractor LED zone
    LEDFig=perchZoneGUI(allframes(:,:,currentFrameNumber));
    disp('Press "enter" once have defined LED zone.');
    pause;
    LEDVertices=zoneVertices;
    
    if continueAnalysis==1
        disp('LED zone succesfully defined.');
    else
        disp('Failed to define LED zone.');
    end
    
    close(LEDFig);
    
    % Clean up global variables
    clear continueAnalysis
    clear zoneVertices
    
    % Get LED zone intensity over all frames 
    [k2,v2]=convhull(LEDVertices(:,1),LEDVertices(:,2));
    [cols2,rows2]=find(ones(size(allframes,1),size(allframes,2))>0);
    isin2=inpolygon(rows2,cols2,LEDVertices(:,1),LEDVertices(:,2));
    temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
    summedIntensityLED=sum(temp(isin2,:),1);
    handles.LEDvals=[handles.LEDvals summedIntensityLED];
    
    % Check that current movie segment includes a reach
    % Instructions to user
    continuebutton=questdlg('Check whether video segment contains a reach. Then press "enter" at command line. Understood?','Instructions 2','Yes','Cancel','Cancel');
    switch continuebutton
        case 'Yes'
        case 'Cancel'
            return
    end
    
    currentSegment=[1 size(allframes,3)];
    gotReach=0;
    for i=1:6
        fig=implay(allframes(:,:,currentSegment(1):currentSegment(2)));
        fig.Parent.Position=[100 100 800 800];
        fig.Parent.Name='Check whether video segment contains a reach.';
        disp('Check whether video segment contains a reach.');
        pause;
        lastFrameDisplayed=startsAtFrame(end-1)+currentSegment(2)-1;
        firstFrameDisplayed=startsAtFrame(end-1)+currentSegment(1)-1;
        
        reachbutton=MFquestdlg([500 100],'Does this video segment contain a reach?','Enter yes or no','Yes','No','No');
        if isempty(reachbutton)
            error('Exit in looking for reach');
        end
        switch reachbutton
            case 'Yes'
                close(fig);
                gotReach=1;
                break
            case 'No'
                close(fig);
                gotReach=0;
                % Read a movie segment
                n=framesPerChunk; % How many frames to read now
                currentSegment=[1 n];
                for j=1:n
                    [frame,EOF]=step(videoFReader);
                    if EOF==true
                        n=j-1;
                        allframes=allframes(:,:,j-1);
                        break
                    end
                    allframes(:,:,j)=frame;
                end
                startsAtFrame=[startsAtFrame startsAtFrame(end)+n];
                movieChunk=[movieChunk movieChunk(end)+1];
                handles.oneback=allframes(:,:,end-sizeoneback);
                
                % Get LED zone intensity over all frames
                temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
                summedIntensityLED=sum(temp(isin2,:),1);
                handles.LEDvals=[handles.LEDvals summedIntensityLED];
        end
        if EOF==true
            error('Not enough frames to get a reach in this movie');
        end
    end
    
    % Get distribution of intensity in perch zone over beginning of movie
    [k,v]=convhull(perchVertices(:,1),perchVertices(:,2));
    [cols,rows]=find(ones(size(allframes,1),size(allframes,2))>0);
    isin=inpolygon(rows,cols,perchVertices(:,1),perchVertices(:,2));
    temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
    summedIntensity=sum(temp(isin,:),1);
    % Calibrate reach detection
    % Start by using threshold 1 standard deviation below the mean
    % If frame defined as containing paws on perch is within 1 std of the mean
    if abs(summedIntensity(currentFrameNumber)-mean(summedIntensity))<std(summedIntensity)
        useAsMean=mean(summedIntensity);
    else
        useAsMean=summedIntensity(currentFrameNumber);
    end
    useAsThresh=useAsMean-1*std(summedIntensity);
    rng shuffle;
    works=0;
    counter=1;
    while works==0
        if counter>10
            break
        end
        [useAsThresh,works,isUserApprovedReach]=calibrateReachDetection(summedIntensity,allframes,useAsThresh,counter);
        counter=counter+1;
    end
    
    if works==0
        error('Check reach detection');
    elseif works==1
        % Continue
    end
else
    isin2=perch.LEDisin;
    handles.LEDvals=perch.LEDvals;
end

% Save perch data
if isempty(perchdata)
    perch.useAsThresh=useAsThresh;
    perch.n_consec=n_consec;
    perch.isin=isin;
    perch.LEDisin=isin2;
    perch.LEDvals=handles.LEDvals;
    endoffname=regexp(filename,'\.');
    save([filename(1:endoffname(end)-1) '_perch.mat'],'perch');
end

% Then look for changes in paw zone to identify potential reach
% Have user indicate start of reach, time when paw contacts pellet, and
% whether reach was succesful

% Set up handles
handles.useAsThresh=useAsThresh;
handles.filename=filename;
handles.n_consec=n_consec;
handles.isin=isin;
handles.reachStarts=[];
handles.pelletTouched=[];
handles.pelletTime=[];
handles.atePellet=[];
handles.eatTime=[];
handles.reachIsDone=false;
handles.curr_start_done=false;
handles.curr_pellet_done=false;
handles.curr_eat_done=false; 
handles.reachN=1;
handles.allframes=allframes;
handles.frames_before_firstReachFrame=frames_before_firstReachFrame;
handles.frames_after_firstReachFrame=frames_after_firstReachFrame;
handles.nFramesBetweenReaches=nFramesBetweenReaches;
handles.videoFReader=videoFReader;
handles.didReachForThisChunk=didReachForThisChunk;
handles.movieChunk=movieChunk;
handles.startsAtFrame=startsAtFrame;
handles.framesPerChunk=framesPerChunk;
handles.allReachesTally=0;
handles.EOF=EOF;
handles.startedOver=[];
handles.sizeOfLastChunk=[];
handles.endoffname=regexp(filename,'\.');
handles.sizeoneback=sizeoneback;
handles.isin2=isin2;

% Find reaches in current movie chunk, then move to next movie chunk, etc.
disp('Find the frame associated with each of the following events for this reach and press matching button while movie is stopped at that frame.'); 
reachingStretch=findCurrentReaches(n,allframes,useAsThresh,n_consec,isin);
if isempty(reachingStretch)
    % No reaches found for this movie chunk, get next movie chunk
    containsReach=0;
    while containsReach==0
        [handles,containsReach]=findMovieChunkWithReach(handles);
    end
    allframes=handles.allframes;
    reachingStretch=handles.reachingStretch;
end

% Display current reach
reachN=1;
if reachingStretch(reachN)-frames_before_firstReachFrame<1
    startInd=1;
else
    startInd=reachingStretch(reachN)-frames_before_firstReachFrame;
end
if reachingStretch(reachN)+frames_after_firstReachFrame>size(allframes,3)
    endInd=size(allframes,3);
else
    endInd=reachingStretch(reachN)+frames_after_firstReachFrame;
end
fig=implay(allframes(:,:,startInd:endInd));
fig.Parent.Position=[100 100 800 800];
lastFrameDisplayed=startsAtFrame(end-1)+endInd-1;
firstFrameDisplayed=startsAtFrame(end-1)+startInd-1;

handles.fig=fig;
handles.reachingStretch=reachingStretch;
handles.lastFrameDisplayed=lastFrameDisplayed;
handles.firstFrameDisplayed=firstFrameDisplayed;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes findReaches wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function finishFunction(handles)

% Choose what to save
savehandles.useAsThresh=handles.useAsThresh;
savehandles.filename=handles.filename;
savehandles.n_consec=handles.n_consec;
savehandles.isin=handles.isin;
savehandles.reachStarts=handles.reachStarts;
savehandles.pelletTouched=handles.pelletTouched;
savehandles.pelletTime=handles.pelletTime;
savehandles.atePellet=handles.atePellet;
savehandles.eatTime=handles.eatTime;
savehandles.reachIsDone=handles.reachIsDone;
savehandles.curr_start_done=handles.curr_start_done;
savehandles.curr_pellet_done=handles.curr_pellet_done;
savehandles.curr_eat_done=handles.curr_eat_done; 
savehandles.frames_before_firstReachFrame=handles.frames_before_firstReachFrame;
savehandles.frames_after_firstReachFrame=handles.frames_after_firstReachFrame;
savehandles.nFramesBetweenReaches=handles.nFramesBetweenReaches;
savehandles.didReachForThisChunk=handles.didReachForThisChunk;
savehandles.movieChunk=handles.movieChunk;
savehandles.startsAtFrame=handles.startsAtFrame;
savehandles.framesPerChunk=handles.framesPerChunk;
savehandles.allReachesTally=handles.allReachesTally;
savehandles.startedOver=handles.startedOver;
savehandles.sizeOfLastChunk=handles.sizeOfLastChunk;
savehandles.sizeoneback=handles.sizeoneback;
savehandles.isin2=handles.isin2;
savehandles.LEDvals=handles.LEDvals;

endoffname=handles.endoffname;
filename=handles.filename;

% To execute once have found reaches in all of movie
save([filename(1:endoffname(end)-1) '_savehandles.mat'],'savehandles');

function handles=updateMovie(handles)

EOF=handles.EOF;
startedOver=handles.startedOver;
sizeOfLastChunk=handles.sizeOfLastChunk;
framesPerChunk=handles.framesPerChunk;
videoFReader=handles.videoFReader;
allframes=handles.allframes;
startsAtFrame=handles.startsAtFrame;
movieChunk=handles.movieChunk;
didReachForThisChunk=handles.didReachForThisChunk;
sizeoneback=handles.sizeoneback;
isin2=handles.isin2;
LEDvals=handles.LEDvals;

% If reached end of file, check whether have gotten reaches in all movie
% chunks, if so, end, otherwise, start over
if ~isempty(EOF)
    if EOF==true
        noReachesYet=movieChunk(~ismember(movieChunk,didReachForThisChunk));
        if isempty(noReachesYet)
            % Done with all of movie -- finish
            finishFunction(handles);
        else
            % Start over at beginning of movie
            % Because set PlayCount to 2 for videoFReader, continuing stepping
            % should start over at beginning of movie
            startedOver=true;
        end
    end
end
        
% Check whether we've already looked for reaches in this movie chunk
noReachesYet=movieChunk(~ismember(movieChunk,didReachForThisChunk));
if isempty(noReachesYet)
    % Finished
    finishFunction(handles);
end

% Read a movie segment
n=framesPerChunk; % How many frames to read now
currentSegment=[1 n];
% tic
for j=1:n
    [frame,EOF]=step(videoFReader);
%     disp(toc);
    if EOF==true
        n=j-1;
        allframes=allframes(:,:,j-1);
        sizeOfLastChunk=j-1;
        break
    end
    allframes(:,:,j)=frame;
end
handles.oneback=allframes(:,:,end-sizeoneback+1);
% Get LED zone intensity over all frames
temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
summedIntensityLED=sum(temp(isin2,:),1);
handles.LEDvals=[handles.LEDvals summedIntensityLED];
if ~isempty(startedOver)
    if startedOver==true
        startsAtFrame=[startsAtFrame startsAtFrame(end)+sizeOfLastChunk];
        movieChunk=[movieChunk 1];
        % Reset
        startedOver=false;
    else
        startsAtFrame=[startsAtFrame startsAtFrame(end)+n];
        movieChunk=[movieChunk movieChunk(end)+1];
    end
else
    startsAtFrame=[startsAtFrame startsAtFrame(end)+n];
    movieChunk=[movieChunk movieChunk(end)+1]; 
end
handles.oneback=allframes(:,:,end-sizeoneback);

% Update handles
handles.videoFReader=videoFReader;
handles.allframes=allframes;
handles.startsAtFrame=startsAtFrame;
handles.movieChunk=movieChunk;
handles.EOF=EOF;
handles.startedOver=startedOver;
handles.sizeOfLastChunk=sizeOfLastChunk;

function [handles,containsReach]=findMovieChunkWithReach(handles)

didReachForThisChunk=handles.didReachForThisChunk;
movieChunk=handles.movieChunk;

% Save that reaches have been found for this movie chunk
didReachForThisChunk=[didReachForThisChunk movieChunk(end)];

% Read next movie segment
handles=updateMovie(handles);

% Get new values from updated handles
allframes=handles.allframes;
videoFReader=handles.videoFReader;
startsAtFrame=handles.startsAtFrame;
movieChunk=handles.movieChunk;

% Find new candidate reach frames
reachingStretch=findCurrentReaches(handles.framesPerChunk,allframes,handles.useAsThresh,handles.n_consec,handles.isin);
reachN=1;

% Check if there is any candidate reach in this movie chunk
if isempty(reachingStretch)
    containsReach=false;
    disp('Movie chunk lacked reach');
else
    containsReach=true;
end

% Update handles
handles.allframes=allframes;
handles.videoFReader=videoFReader;
handles.startsAtFrame=startsAtFrame;
handles.movieChunk=movieChunk;
handles.reachingStretch=reachingStretch;
handles.reachN=reachN;

function handles=updateReach(handles)

if handles.addIn==0
    disp('Reach detected');

    % Increment total reaches
    handles.allReachesTally=handles.allReachesTally+1;
    
    % Log whether pellet was present
    handles.pelletPresent=[handles.pelletPresent handles.pelletIsMissing];
    % Reset pellet present to default
    handles.pelletIsMissing=0;
end

% Display next reach movie

% Get variables
reachingStretch=handles.reachingStretch;
reachN=handles.reachN;
allframes=handles.allframes;
frames_before_firstReachFrame=handles.frames_before_firstReachFrame;
frames_after_firstReachFrame=handles.frames_after_firstReachFrame;
didReachForThisChunk=handles.didReachForThisChunk;
movieChunk=handles.movieChunk;
startsAtFrame=handles.startsAtFrame;
lastFrameDisplayed=handles.lastFrameDisplayed;
firstFrameDisplayed=handles.firstFrameDisplayed;

% Check whether next detected reach frames are within nFramesBetweenReaches
% of current reach frame or within scope of just detected reach
nFramesBetweenReaches=handles.nFramesBetweenReaches;
timeOfLastEat=handles.eatTime(end);
timeOfLastPellet=handles.pelletTime(end);
if isempty(reachingStretch)
elseif handles.addIn==0
    % Note that reachingStretch is an index into allframes
    % first index of allframes is startsAtFrame(end-1) wrt whole movie
    % and firstFrameDisplayed=startsAtFrame(end-1)+startInd-1
    if isnan(handles.atePellet(end)) % Last movie frame was a "no reach"
        % so skip all the way to end of this movie frame
        loseAllReachesBefore=lastFrameDisplayed-startsAtFrame(end-1)+2;
    elseif ~isnan(timeOfLastEat) || ~isnan(timeOfLastPellet)
        loseAllReachesBefore=max([timeOfLastEat-startsAtFrame(end-1)+1 timeOfLastPellet-startsAtFrame(end-1)+1 reachingStretch(reachN)+nFramesBetweenReaches]);
    else
        loseAllReachesBefore=reachingStretch(reachN)+nFramesBetweenReaches;
    end
    reachingStretch=reachingStretch(reachingStretch>loseAllReachesBefore);
    handles.reachingStretch=reachingStretch;
    reachN=1;
    handles.reachN=reachN;
end

% If reachingStretch is now empty, read next movie segment
if isempty(reachingStretch) || handles.addIn==1
    containsReach=0;
    while containsReach==0
        [handles,containsReach]=findMovieChunkWithReach(handles);
        if handles.addIn==1
            containsReach=1; % this chunk contains end of reach from previous movie chunk
        end
    end
end

allframes=handles.allframes;
reachingStretch=handles.reachingStretch;
reachN=handles.reachN;
startsAtFrame=handles.startsAtFrame;

close(handles.fig);

% Update implay
if handles.addIn==0
    if reachingStretch(reachN)-frames_before_firstReachFrame<1
        startInd=1;
    else
        startInd=reachingStretch(reachN)-frames_before_firstReachFrame;
    end
    if reachingStretch(reachN)+frames_after_firstReachFrame>size(allframes,3)
        endInd=size(allframes,3);
    else
        endInd=reachingStretch(reachN)+frames_after_firstReachFrame;
    end
    disp(reachingStretch(reachN));
    fig=implay(allframes(:,:,startInd:endInd));
    lastFrameDisplayed=startsAtFrame(end-1)+endInd-1;
    firstFrameDisplayed=startsAtFrame(end-1)+startInd-1;
else
    % add in reach from former movie chunk
    more_framesAfterReach=100;
    fig=implay(cat(3,handles.whatToAddIn,allframes(:,:,1:more_framesAfterReach)));
    firstFrameDisplayed=-size(handles.whatToAddIn,3)+1;
    lastFrameDisplayed=1+more_framesAfterReach-1;
    handles.addIn=0;
end
fig.Parent.Position=[100 100 800 800];
handles.fig=fig;
handles.lastFrameDisplayed=lastFrameDisplayed;
handles.firstFrameDisplayed=firstFrameDisplayed;
    
% Reset GUI for next reach
handles=resetGUI(handles);

function handles=resetGUI(handles)

if handles.addIn==0
    handles.showedMoreVideo=0;
end

% Set button to waiting
set(handles.text3,'String','Waiting');
set(handles.text3,'ForegroundColor','r');
set(handles.text4,'String','Waiting');
set(handles.text4,'ForegroundColor','r');
set(handles.text5,'String','Waiting');
set(handles.text5,'ForegroundColor','r');

% Increment reach detected count
set(handles.reachTallyBox,'String',['Reach ' num2str(handles.allReachesTally+1)]);

% Reset reach progress variables
handles.reachIsDone=false;
handles.curr_start_done=false;
handles.curr_pellet_done=false;
handles.curr_eat_done=false;

function reachingStretch=findCurrentReaches(n,allframes,useAsThresh,n_consec,isin)

% summedIntensity=nan(1,n);
temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
summedIntensity=sum(temp(isin,:),1);
% for i=1:n
%     temp=intensityFromRGB(allframes(:,:,i));
%     summedIntensity(i)=sum(temp(isin));
% end
reachFrames=summedIntensity<useAsThresh;

% Real reach should be at least n_consec consecutive reach frames
runningSum=zeros(size(reachFrames));
for i=1:n_consec
    runningSum(1:end-(i-1))=runningSum(1:end-(i-1))+reachFrames(i:end);
end
reachingStretch=find(runningSum>=n_consec);

function [useAsThresh,works,isUserApprovedReach]=calibrateReachDetection(summedIntensity,allframes,useAsThresh,counter)

% Show user candidate reach frames -- iterate threshold
candidateFrames=find(summedIntensity<useAsThresh);
if length(candidateFrames)<7
    useAsThresh=useAsThresh+0.25*std(summedIntensity);
end
n=length(candidateFrames);
testInOrder=randperm(length(candidateFrames));
candidateFrames=candidateFrames(testInOrder);
isUserApprovedReach=nan(1,length(candidateFrames));
triedNMore=0;
tryingMore=0;
works=0;
for i=1:n
    if i>length(candidateFrames)
        break
    end
    f=figure();
    imagesc(allframes(:,:,candidateFrames(i)));
    colormap gray; 
    if tryingMore==1
        triedNMore=triedNMore+1;
    end
    reachbutton=MFquestdlg([100 100],'Mouse is reaching?','Enter yes or no','Yes','No','No');
    if isempty(reachbutton)
        error('Exit in calibration of reach detection');
    end
    switch reachbutton
        case 'Yes'
            isUserApprovedReach(i)=1;
        case 'No'
            isUserApprovedReach(i)=0;
    end
    close(f);
    % Test whether reach detection threshold is working
    if ((tryingMore==1 && triedNMore>5) || (nansum(isUserApprovedReach==1)>=5 && counter>5)) && nansum(isUserApprovedReach==1)/sum(~isnan(isUserApprovedReach))>5/7
        % Works at least 5 out of 7 times
        % Working well enough
        works=1;
        break
    elseif ((tryingMore==1 && triedNMore>5) || nansum(isUserApprovedReach==1)>=7) && nansum(isUserApprovedReach==1)/sum(~isnan(isUserApprovedReach))>5/7
        % Works at least 5 out of 7 times
        % Working well enough
        works=1;
        break
    elseif nansum(isUserApprovedReach==0)>5 && nansum(isUserApprovedReach==1)/sum(~isnan(isUserApprovedReach))<5/7
        % Too many non-reach, try lowering threshold by 1/4 of std 
        if tryingMore==0 || triedNMore>5
            useAsThresh=useAsThresh-0.25*std(summedIntensity)-rand*0.125*std(summedIntensity);
            disp('Decreasing reach threshold');
            tryingMore=1;
            triedNMore=0;
            isUserApprovedReach(1:i-1)=nan;
        end
    elseif nansum(isUserApprovedReach)>4 && nansum(isUserApprovedReach==1)/sum(~isnan(isUserApprovedReach))>5/7
        % Threshold might be too low
        if tryingMore==0 || triedNMore>5
            useAsThresh=useAsThresh+0.25*std(summedIntensity)+rand*0.125*std(summedIntensity);
            disp('Increasing reach threshold');
            tryingMore=1;
            triedNMore=0;
            isUserApprovedReach(1:i-1)=nan;
        end
    end
end

function intensity=intensityFromRGB(frame)

intensity=0.299*frame(:,:,1)+0.587*frame(:,:,2)+0.114*frame(:,:,3);

% --- Outputs from this function are returned to the command line.
function varargout = findReaches_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If already hit this button, ignore second press
if handles.curr_start_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.reachStarts=[handles.reachStarts firstFrameDisplayed+currFrame-1];
handles.reachStarts_belongToReach=[handles.reachStarts_belongToReach handles.allReachesTally];

% Set start button to done
set(handles.text3,'String','Done');
set(handles.text3,'ForegroundColor','g');
handles.curr_start_done=true;

% Check whether this reach is done
if reachIsDone(handles)==true
    handles=updateReach(handles);
end

guidata(hObject, handles);

function out=reachIsDone(handles)

if handles.curr_start_done==true && handles.curr_pellet_done==true && handles.curr_eat_done==true
    out=true;
    return
else
    out=false;
    return
end

% --- Executes on button press in pelletbutton.
function pelletbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pelletbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If already hit this button, ignore second press
if handles.curr_pellet_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.pelletTouched=[handles.pelletTouched 1];
handles.pelletTime=[handles.pelletTime firstFrameDisplayed+currFrame-1];
handles.pelletTouched_belongToReach=[handles.pelletTouched_belongToReach handles.allReachesTally];
handles.pelletTime_belongToReach=[handles.pelletTime_belongToReach handles.allReachesTally];

% Set pellet button to done
set(handles.text4,'String','Done');
set(handles.text4,'ForegroundColor','g');
handles.curr_pellet_done=true;

% Check whether this reach is done
if reachIsDone(handles)==true
    handles=updateReach(handles);
end

guidata(hObject, handles);

% --- Executes on button press in missbutton.
function missbutton_Callback(hObject, eventdata, handles)
% hObject    handle to missbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If already hit this button, ignore second press
if handles.curr_pellet_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.pelletTouched=[handles.pelletTouched 0];
handles.pelletTime=[handles.pelletTime firstFrameDisplayed+currFrame-1];
handles.pelletTouched_belongToReach=[handles.pelletTouched_belongToReach handles.allReachesTally];
handles.pelletTime_belongToReach=[handles.pelletTime_belongToReach handles.allReachesTally];

% Set pellet button to done
set(handles.text4,'String','Done');
set(handles.text4,'ForegroundColor','g');
handles.curr_pellet_done=true;

% Check whether this reach is done
if reachIsDone(handles)==true
    handles=updateReach(handles);
end

guidata(hObject, handles);

% --- Executes on button press in eatbutton.
function eatbutton_Callback(hObject, eventdata, handles)
% hObject    handle to eatbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If already hit this button, ignore second press
if handles.curr_eat_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.atePellet=[handles.atePellet 1];
handles.eatTime=[handles.eatTime firstFrameDisplayed+currFrame-1];
handles.atePellet_belongToReach=[handles.atePellet_belongToReach handles.allReachesTally];
handles.eatTime_belongToReach=[handles.eatTime_belongToReach handles.allReachesTally];

% Set eat button to done
set(handles.text5,'String','Done');
set(handles.text5,'ForegroundColor','g');
handles.curr_eat_done=true;

% Check whether this reach is done
if reachIsDone(handles)==true
    handles=updateReach(handles);
end

guidata(hObject, handles);

% --- Executes on button press in dropbutton.
function dropbutton_Callback(hObject, eventdata, handles)
% hObject    handle to dropbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If already hit this button, ignore second press
if handles.curr_eat_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.atePellet=[handles.atePellet 0];
handles.eatTime=[handles.eatTime firstFrameDisplayed+currFrame-1];
handles.atePellet_belongToReach=[handles.atePellet_belongToReach handles.allReachesTally];
handles.eatTime_belongToReach=[handles.eatTime_belongToReach handles.allReachesTally];

% Set eat button to done
set(handles.text5,'String','Done');
set(handles.text5,'ForegroundColor','g');
handles.curr_eat_done=true;

% Check whether this reach is done
if reachIsDone(handles)==true
    handles=updateReach(handles);
end

guidata(hObject, handles);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Only accept this "No Reach" classification if movie player is stopped at
% last frame
currFrame=handles.fig.data.Controls.CurrentFrame;

if currFrame==size(handles.allframes,3)
    handles.atePellet=[handles.atePellet nan];
    handles.eatTime=[handles.eatTime nan];
    handles.pelletTouched=[handles.pelletTouched nan];
    handles.pelletTime=[handles.pelletTime nan];
    handles.reachStarts=[handles.reachStarts nan];
    
    handles=updateReach(handles);
    
    guidata(hObject, handles);
else
    disp('Will only accept No Reach classification if movie is stopped at last frame');
end


% --- Executes on button press in morevideobutton.
function morevideobutton_Callback(hObject, eventdata, handles)
% hObject    handle to morevideobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.showedMoreVideo==0
    handles.showedMoreVideo=1; % pressed this button once for this reach
else
    % user only gets to press this button once per reach
    disp('Cannot further expand the video segment -- please indicate reach in this segment or No Reach.');
    return
end

more_framesBeforeReach=50;
more_framesAfterReach=100;

allframes=handles.allframes;
reachingStretch=handles.reachingStretch;
reachN=handles.reachN;
frames_before_firstReachFrame=handles.frames_before_firstReachFrame; 
sizeoneback=handles.sizeoneback;
oneback=handles.oneback;
startsAtFrame=handles.startsAtFrame;

% Update implay
if reachingStretch(reachN)-more_framesBeforeReach<1
    if isempty(oneback)
    else
        if length(size(oneback))<3
            disp('oneback wrong size');
        else
            % This movie chunk started in the middle of the reach
            % Add end of last movie chunk
            temp=nan(size(allframes,1),size(allframes,2),size(allframes,3)+sizeoneback);
            temp(:,:,end-size(allframes,3)+1:end)=allframes;
            temp(:,:,1:end-size(allframes,3))=oneback(:,:,end-sizeoneback+1:end);
            allframes=temp;
            reachingStretch=reachingStretch+sizeoneback;
            if more_framesBeforeReach>sizeoneback
                error('more_framesBeforeReach should be less than sizeoneback');
            end
        end
    end
end
startInd=reachingStretch(reachN)-more_framesBeforeReach;
if reachingStretch(reachN)+more_framesAfterReach>size(allframes,3)
    didEndInd=0;
    % Reach extends beyond end of movie chunk 
    % Move on to next movie chunk, keeping track of fact that need to add
    % in frames from current movie chunk
    EOF=handles.EOF;
    if ~isempty(EOF)
        if EOF==true
            % Already read to end of file
            endInd=size(allframes,3);
            didEndInd=1;
        end
    end
    if didEndInd==0 
        handles.addIn=1;
        handles.whatToAddIn=allframes(:,:,startInd:end);
    end
else
    endInd=reachingStretch(reachN)+more_framesAfterReach;
end

if handles.addIn==0
    close(handles.fig);
    
    disp(reachingStretch(reachN));
    fig=implay(allframes(:,:,startInd:endInd));
    fig.Parent.Position=[100 100 800 800];
    handles.fig=fig;
    lastFrameDisplayed=startsAtFrame(end-1)+endInd-1;
    firstFrameDisplayed=startsAtFrame(end-1)+startInd-1;
    handles.lastFrameDisplayed=lastFrameDisplayed;
    handles.firstFrameDisplayed=firstFrameDisplayed;
    
    % Reset GUI
    handles=resetGUI(handles);
else
    handles=updateReach(handles);
end

guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

% Saves data before closing figure
finishFunction(handles);

delete(hObject);


% --- Executes on button press in retrybutton.
function retrybutton_Callback(hObject, eventdata, handles)
% hObject    handle to retrybutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reset to beginning of coding this reach
currReachN=handles.allReachesTally;

handles.reachStarts(handles.reachStarts_belongToReach==currReachN)=[];
handles.pelletTouched(handles.pelletTouched_belongToReach==currReachN)=[];
handles.pelletTime(handles.pelletTime_belongToReach==currReachN)=[];
handles.atePellet(handles.atePellet_belongToReach==currReachN)=[];
handles.eatTime(handles.eatTime_belongToReach==currReachN)=[];

handles.curr_eat_done=false;
handles.curr_pellet_done=false;
handles.curr_start_done=false;

handles.pelletIsMissing=0;

% Reset GUI 
handles=resetGUI(handles);

guidata(hObject, handles);


% --- Executes on button press in pelletmissingbutton.
function pelletmissingbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pelletmissingbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.pelletIsMissing=1;

guidata(hObject, handles);
