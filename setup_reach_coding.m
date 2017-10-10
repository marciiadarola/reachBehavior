function varargout = setup_reach_coding(varargin)
% SETUP_REACH_CODING MATLAB code for setup_reach_coding.fig
%      SETUP_REACH_CODING, by itself, creates a new SETUP_REACH_CODING or raises the existing
%      singleton*.
%
%      H = SETUP_REACH_CODING returns the handle to a new SETUP_REACH_CODING or the handle to
%      the existing singleton*.
%
%      SETUP_REACH_CODING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETUP_REACH_CODING.M with the given input arguments.
%
%      SETUP_REACH_CODING('Property','Value',...) creates a new SETUP_REACH_CODING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setup_reach_coding_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setup_reach_coding_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setup_reach_coding

% Last Modified by GUIDE v2.5 09-Oct-2017 16:58:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setup_reach_coding_OpeningFcn, ...
                   'gui_OutputFcn',  @setup_reach_coding_OutputFcn, ...
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


% --- Executes just before setup_reach_coding is made visible.
function setup_reach_coding_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setup_reach_coding (see VARARGIN)

% Define some global variables for communication with perchZoneGUI
global zoneVertices
global continueAnalysis

continueAnalysis=0;

% Settings
framesPerChunk=500;
n_consec=1;
% frames_before_firstReachFrame=2;
frames_before_firstReachFrame=30;
frames_after_firstReachFrame=50;
movie_fps=30;
nFramesBetweenReaches=5;
% sizeoneback=100;
sizeoneback=300;
discardFirstNFrames=1;
fps_noreach=60;
% fps_reach=17;
fps_reach=13;
perch_pellet_delay=0.133; % in seconds
perch_pellet_delay_ind=floor(perch_pellet_delay/(1/movie_fps)); % in indices wrt fps
perch_pellet_delay_ind=[perch_pellet_delay_ind-3 perch_pellet_delay_ind-2 perch_pellet_delay_ind-1 perch_pellet_delay_ind perch_pellet_delay_ind+1 perch_pellet_delay_ind+2 perch_pellet_delay_ind+3];

% Choose default command line output for setup_reach_coding
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
handles.logReachN=[];
handles.curr_start_done=[];
handles.curr_pellet_done=[];
handles.curr_eat_done=[]; 
handles.frames_before_firstReachFrame=[];
handles.frames_after_firstReachFrame=[];
handles.nFramesBetweenReaches=[];
handles.didReachForThisChunk=[];
handles.movieChunk=[];
handles.startsAtFrame=[];
handles.framesPerChunk=framesPerChunk;
handles.allReachesTally=[];
handles.startedOver=[];
handles.sizeOfLastChunk=[];
handles.sizeoneback=[];
handles.isin2=[];
handles.LEDvals=[];
handles.eatRegimeVals=[];
handles.perchRegimeVals=[];
handles.pelletRegimeVals=[];
handles.pelletStopVals=[];
handles.addIn=0;
handles.showedMoreVideo=0;
handles.pelletMissing=[];
handles.pawStartsOnWheel=[];
handles.fps_reach=fps_reach;
handles.fps_noreach=fps_noreach;
handles.changeBetweenFrames=[];
handles.perc10_change=[];

% Close all open figures except setup_reach_coding GUI
set(hObject, 'HandleVisibility', 'off');
close all;
set(hObject, 'HandleVisibility', 'on');

% Get file name of video with reaches
filename=varargin{1};
perchdata=varargin{2}; % filename of .mat file containing information about perch zone and reach threshold
discardFirstNFrames=varargin{3};

% Check whether user has already defined perch zone for this movie
addingOn=0;
if ~isempty(perchdata)
    a=load(perchdata);
    perch=a.perch;
    useAsThresh=perch.useAsThresh;
    n_consec=perch.n_consec;
    isin=perch.isin;
    stepByAmount=perch.stepByAmount;
    isin3=perch.pelletIsIn;
    isin4=perch.isin4;
    isin5=perch.isin5;
    
    addonbutton=questdlg('Overwrite existing analysis or continue where you left off?','Overwrite','Overwrite','Continue','Continue');
    switch addonbutton
        case 'Overwrite'
            % start over at beginning
            addingOn=0;
        case 'Continue'
            addingOn=1;
            endoffname=regexp(filename,'\.');
            a=load([filename(1:endoffname(end)-1) '_savehandles.mat']);
            previous_savehandles=a.savehandles;            
            if isempty(discardFirstNFrames)
                discardFirstNFrames=previous_savehandles.startsAtFrame(end)+-1;
            end
    end
end
if isempty(discardFirstNFrames)
    discardFirstNFrames=1;
end


if isempty(perchdata)
    % Instructions to user
    continuebutton=questdlg('Pause movie at a frame with both paws on perch and, if possible, with pellet in final presented position. Then press "enter" at command line. Understood?','Instructions 1','Yes','Cancel','Cancel');
    switch continuebutton
        case 'Yes'
        case 'Cancel'
            return
    end
end

% Set up approach for indexing movie chunks into whole movie
if addingOn==1
    movieChunk=previous_savehandles.movieChunk;
    startsAtFrame=previous_savehandles.startsAtFrame;
    didReachForThisChunk=previous_savehandles.startsAtFrame;
else
    movieChunk=[];
    startsAtFrame=[];
    didReachForThisChunk=[];
end

% Read beginning of movie and discard unused frames
videoFReader = vision.VideoFileReader(filename,'PlayCount',1,'ImageColorSpace','YCbCr 4:2:2');
n=discardFirstNFrames; % How many frames to read initially
% parsedFilenameEnd=regexp(filename,'.');
% parsedFilenameStart=regexp(filename,'\');
% handles.filename_foroutput=[outdir 'movie_' filename(parsedFilenameStart(end)+1:parsedFilenameEnd(1)) '_frame'];
if discardFirstNFrames>0
%     movieChunk=[movieChunk 1];
%     startsAtFrame=[startsAtFrame 1];
    for i=1:n
        [frame,~,~,EOF]=step(videoFReader);
        if EOF==true
%             n=i-1;
%             allframes=allframes(:,:,i-1);
            break
        end
%         if i==1
%             allframes=nan([size(frame,1) size(frame,2) n]);
%         end
%         allframes(:,:,i)=frame;
    end
    startsAtFrame=[startsAtFrame n+1];
    if isempty(movieChunk)
        movieChunk=[movieChunk 1];
    else
        movieChunk=[movieChunk movieChunk(end)+1];
    end
%     save([outdir 'movie_' filename(parsedFilenameStart(end)+1:parsedFilenameEnd(1)) '_frame' num2str(startsAtFrame(end-1)) '.mat'],'allframes');
%     handles.oneback=allframes(:,:,end-sizeoneback+1:end);
end

n=framesPerChunk; % How many frames to read initially
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
if ~isempty(startsAtFrame)
    startsAtFrame=[startsAtFrame startsAtFrame(end)+n];
else
    startsAtFrame=[startsAtFrame n+1];
end
movieChunk=[movieChunk movieChunk(end)+1];
% save([outdir 'movie_' filename(parsedFilenameStart(end)+1:parsedFilenameEnd(1)) '_frame' num2str(startsAtFrame(end-1)) '.mat'],'allframes');
% handles.oneback=allframes(:,:,end-sizeoneback+1:end);

if addingOn==0
    handles.LEDvals=[];
    handles.eatRegimeVals=[];
    handles.perchRegimeVals=[];
    handles.pelletRegimeVals=[];
    handles.pelletStopVals=[];
    handles.changeBetweenFrames=[];
else
    handles=copyAllFields(handles,previous_savehandles);
    handles.LEDvals=previous_savehandles.LEDvals;
    handles.eatRegimeVals=previous_savehandles.eatRegimeVals;
    handles.perchRegimeVals=previous_savehandles.perchRegimeVals;
    handles.pelletRegimeVals=previous_savehandles.pelletRegimeVals;
    handles.pelletStopVals=previous_savehandles.pelletStopVals;
    handles.changeBetweenFrames=previous_savehandles.changeBetweenFrames;
end
if isempty(perchdata)
    % Play movie until both hands are on perch
    fig=implay(allframes,30);
    handles.addIn=0;
    fig.Parent.Position=[100 100 800 800];
    pause;
    currentFrameNumber=fig.data.Controls.CurrentFrame;
    lastFrameDisplayed=startsAtFrame(end-1)+size(allframes,3)-1;
    firstFrameDisplayed=startsAtFrame(end-1);
    
    % Close implay fig, reopen an image so user can draw in perch area
    disp('Stopped at frame number');
    disp(currentFrameNumber);
    close(fig);
    perchFig=perchZoneGUI(allframes(:,:,currentFrameNumber),'Draw a polygon enclosing the perch zone on the image. Press "Done" after have defined vertices.');
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
    LEDFig=perchZoneGUI(allframes(:,:,currentFrameNumber),'Draw a polygon enclosing the distractor LED zone on the image. Press "Done" after have defined vertices.');
    disp('Press "enter" once have defined LED zone.');
    pause;
    LEDVertices=zoneVertices;
    
    if continueAnalysis==1
        disp('LED zone succesfully defined.');
    else
        disp('Failed to define LED zone.');
    end
    
    close(LEDFig);
    
    % Get pellet zone
    pelletFig=perchZoneGUI(allframes(:,:,currentFrameNumber),'Draw a polygon enclosing the area surrounding but NOT including the pellet. Press "Done" after have defined vertices.');
    disp('Press "enter" once have defined area surrounding but NOT including the pellet.');
    pause;
    pelletVertices=zoneVertices;
    
    if continueAnalysis==1
        disp('Pellet zone succesfully defined.');
    else
        disp('Failed to define pellet zone.');
    end
    
    close(pelletFig);
    
    % Get eat zone
    eatFig=perchZoneGUI(allframes(:,:,currentFrameNumber),'Draw a polygon enclosing the region where mouse paws go when mouse eats. Press "Done" after have defined vertices.');
    disp('Press "enter" once have defined eating zone.');
    pause;
    eatVertices=zoneVertices;
    
    if continueAnalysis==1
        disp('Eating zone succesfully defined.');
    else
        disp('Failed to define eating zone.');
    end
    
    close(eatFig);
    
    % Get actual pellet spot, once pellet is stopped
    pelletStopFig=perchZoneGUI(allframes(:,:,currentFrameNumber),'Draw a polygon enclosing the stopped pellet. Press "Done" after have defined vertices.');
    disp('Press "enter" once have defined pellet stopped zone.');
    pause;
    pelletStopVertices=zoneVertices;
    
    if continueAnalysis==1
        disp('Pellet stopped zone succesfully defined.');
    else
        disp('Failed to define pellet stopped zone.');
    end
    
    close(pelletStopFig);
    
    % Clean up global variables
    clear continueAnalysis
    clear zoneVertices
    
    % Get LED zone intensity over all frames 
%     [k2,v2]=convhull(LEDVertices(:,1),LEDVertices(:,2));
    [cols2,rows2]=find(ones(size(allframes,1),size(allframes,2))>0);
    isin2=inpolygon(rows2,cols2,LEDVertices(:,1),LEDVertices(:,2));
    temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
    summedIntensityLED=sum(temp(isin2,:),1);
    handles.LEDvals=[handles.LEDvals summedIntensityLED];
    
    % Get pellet stop zone intensity over all frames 
%     [k2,v2]=convhull(pelletStopVertices(:,1),pelletStopVertices(:,2));
    [cols2,rows2]=find(ones(size(allframes,1),size(allframes,2))>0);
    isin5=inpolygon(rows2,cols2,pelletStopVertices(:,1),pelletStopVertices(:,2));
    pelletStopIntensity=sum(temp(isin5,:),1);
    handles.pelletStopVals=[handles.pelletStopVals pelletStopIntensity];
    
    % Get distribution of intensity in perch zone over beginning of movie
%     [k,v]=convhull(pelletVertices(:,1),pelletVertices(:,2));
    [cols,rows]=find(ones(size(allframes,1),size(allframes,2))>0);
    isin3=inpolygon(rows,cols,pelletVertices(:,1),pelletVertices(:,2));
    pelletIntensity=sum(temp(isin3,:),1);
    handles.pelletRegimeVals=[handles.pelletRegimeVals pelletIntensity];
    
%     [k,v]=convhull(eatVertices(:,1),eatVertices(:,2));
    [cols,rows]=find(ones(size(allframes,1),size(allframes,2))>0);
    isin4=inpolygon(rows,cols,eatVertices(:,1),eatVertices(:,2));
    eatIntensity=sum(temp(isin4,:),1);
    handles.eatRegimeVals=[handles.eatRegimeVals eatIntensity];
    
%     [k,v]=convhull(perchVertices(:,1),perchVertices(:,2));
    [cols,rows]=find(ones(size(allframes,1),size(allframes,2))>0);
    isin=inpolygon(rows,cols,perchVertices(:,1),perchVertices(:,2));
    summedIntensity_perch=sum(temp(isin,:),1);
    handles.perchRegimeVals=[handles.perchRegimeVals summedIntensity_perch];  
    
    % Get change between frames
    changeBetweenFrames=nanmean(nanmean(diff(allframes,1,3),1),2);
    changeBetweenFrames=[reshape(changeBetweenFrames,1,size(changeBetweenFrames,3)) 0];
    handles.changeBetweenFrames=[handles.changeBetweenFrames changeBetweenFrames];
    
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
        fig=implay(allframes(:,:,currentSegment(1):currentSegment(2)),50);
        handles.addIn=0;
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
                handles.oneback=allframes(:,:,end-sizeoneback+1:end);
                n=framesPerChunk; % How many frames to read now
                currentSegment=[1 n];
                for j=1:n
                    [frame,~,~,EOF]=step(videoFReader);
                    if EOF==true
                        n=j-1;
                        allframes=allframes(:,:,j-1);
                        break
                    end
                    allframes(:,:,j)=frame;
                end
                startsAtFrame=[startsAtFrame startsAtFrame(end)+n];
                movieChunk=[movieChunk movieChunk(end)+1];
%                 save([handles.filename_foroutput num2str(startsAtFrame(end-1)) '.mat'],'allframes');
%                 handles.oneback=allframes(:,:,end-sizeoneback+1:end);
                
                % Get LED zone intensity over all frames
                temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
                summedIntensityLED=sum(temp(isin2,:),1);
                handles.LEDvals=[handles.LEDvals summedIntensityLED]; 
                tempie=sum(temp(isin4,:),1);
                handles.eatRegimeVals=[handles.eatRegimeVals tempie];
                tempie=sum(temp(isin,:),1);
                handles.perchRegimeVals=[handles.perchRegimeVals tempie];
                tempie=sum(temp(isin3,:),1);
                handles.pelletRegimeVals=[handles.pelletRegimeVals tempie];
                tempie=sum(temp(isin5,:),1);
                handles.pelletStopVals=[handles.pelletStopVals tempie];
                
                % Get change between frames
                changeBetweenFrames=nanmean(nanmean(diff(allframes,1,3),1),2);
                changeBetweenFrames=[reshape(changeBetweenFrames,1,size(changeBetweenFrames,3)) 0];
                handles.changeBetweenFrames=[handles.changeBetweenFrames changeBetweenFrames];

        end
        if EOF==true
            error('Not enough frames to get a reach in this movie');
        end
    end
    
    % Get distribution of intensity in perch zone over beginning of movie
%     [k,v]=convhull(pelletVertices(:,1),pelletVertices(:,2));
%     [cols,rows]=find(ones(size(allframes,1),size(allframes,2))>0);
%     isin3=inpolygon(rows,cols,pelletVertices(:,1),pelletVertices(:,2));
    temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
    pelletIntensity=sum(temp(isin3,:),1);
    
%     [k,v]=convhull(eatVertices(:,1),eatVertices(:,2));
%     [cols,rows]=find(ones(size(allframes,1),size(allframes,2))>0);
%     isin4=inpolygon(rows,cols,eatVertices(:,1),eatVertices(:,2));
%     temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
    eatIntensity=sum(temp(isin4,:),1);
    
%     [k,v]=convhull(perchVertices(:,1),perchVertices(:,2));
%     [cols,rows]=find(ones(size(allframes,1),size(allframes,2))>0);
%     isin=inpolygon(rows,cols,perchVertices(:,1),perchVertices(:,2));
    summedIntensity_perch=sum(temp(isin,:),1);
    
    % Get change between frames
    changeBetweenFrames=nanmean(nanmean(diff(allframes,1,3),1),2);
    changeBetweenFrames=[reshape(changeBetweenFrames,1,size(changeBetweenFrames,3)) 0];
    
    all_summedIntensity=zeros(length(perch_pellet_delay_ind),length(pelletIntensity));
    for j=1:length(perch_pellet_delay_ind)
        tempie2=[nanmean(eatIntensity)*ones(1,perch_pellet_delay_ind(j)+4) eatIntensity(1:end-(perch_pellet_delay_ind(j)+4))];
        tempie=[nanmean(summedIntensity_perch)*ones(1,perch_pellet_delay_ind(j)) summedIntensity_perch(1:end-perch_pellet_delay_ind(j))];
        summedIntensity=10*pelletIntensity-tempie+(0.3*tempie2);
        summedIntensity=-summedIntensity;
        all_summedIntensity(j,:)=summedIntensity;
    end
    perc10_change=-0.9*nanstd(changeBetweenFrames);
    handles.perc10_change=perc10_change;
    summedIntensity=(nanmean(all_summedIntensity,1)-nanmean(nanmean(all_summedIntensity,1),2))+(100000*changeBetweenFrames);
%     summedIntensity=nanmean(all_summedIntensity,1);
    % Calibrate reach detection
    % Start by using threshold 1 standard deviation below the mean
    % If frame defined as containing paws on perch is within 1 std of the mean
    if abs(summedIntensity(currentFrameNumber)-mean(summedIntensity))<std(summedIntensity)
        useAsMean=mean(summedIntensity);
    else
        useAsMean=summedIntensity(currentFrameNumber);
    end
%     useAsThresh=useAsMean-1.5*std(summedIntensity);
    useAsThresh=useAsMean-2*std(summedIntensity);
    rng shuffle;
    works=0;
    counter=1;
    stepByAmount=0.25*std(summedIntensity);
    while works==0
        if counter>10
            break
        end
        
        [useAsThresh,works,isUserApprovedReach,stepByAmount]=calibrateReachDetection(summedIntensity,allframes,useAsThresh,counter,stepByAmount);
        counter=counter+1;
    end
    
    if works==0
        if sum(isUserApprovedReach)>(2/3)*length(isUserApprovedReach)
            % Continue
        else
            error('Check reach detection');
        end
    elseif works==1
        % Continue
    end
    
    % Display results of threshold setting
    handles.summedIntensity=summedIntensity;
    figure();
    plot(-summedIntensity);
    hold on;
    line([1 length(summedIntensity)],[-useAsThresh -useAsThresh],'Color','r');
else
    if addingOn==0
        isin2=perch.LEDisin;
        handles.LEDvals=perch.LEDvals;
        handles.eatRegimeVals=perch.eatRegimeVals;
        handles.perchRegimeVals=perch.perchRegimeVals;
        handles.pelletRegimeVals=perch.pelletRegimeVals;
        handles.pelletStopVals=perch.pelletStopVals;
        if length(size(perch.changeBetweenFrames))==3
            handles.changeBetweenFrames=[reshape(perch.changeBetweenFrames,1,size(perch.changeBetweenFrames,3)) 0];
        else
            handles.changeBetweenFrames=perch.changeBetweenFrames;
        end
        handles.perc10_change=perch.perc10_change;
    else
        % continuing analysis
        temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
        
        summedIntensityLED=sum(temp(previous_savehandles.isin2,:),1);
        handles.LEDvals=[handles.LEDvals summedIntensityLED];
        
        eatIntensity=sum(temp(previous_savehandles.isin4,:),1); 
        handles.eatRegimeVals=[handles.eatRegimeVals eatIntensity];
        
        summedIntensity_perch=sum(temp(previous_savehandles.isin,:),1);
        handles.perchRegimeVals=[handles.perchRegimeVals summedIntensity_perch];
        
        pelletIntensity=sum(temp(previous_savehandles.isin3,:),1);
        handles.pelletRegimeVals=[handles.pelletRegimeVals pelletIntensity];
        
        pelletStopIntensity=sum(temp(previous_savehandles.isin5,:),1);
        handles.pelletStopVals=[handles.pelletStopVals pelletStopIntensity];
        
        changeBetweenFrames=nanmean(nanmean(diff(allframes,1,3),1),2);
        changeBetweenFrames=[reshape(changeBetweenFrames,1,size(changeBetweenFrames,3)) 0];
        handles.changeBetweenFrames=[handles.changeBetweenFrames changeBetweenFrames];
    end
end

% Save perch data
if isempty(perchdata)
    perch.useAsThresh=useAsThresh;
    perch.stepByAmount=stepByAmount;
    perch.n_consec=n_consec;
    perch.isin=isin;
    perch.LEDisin=isin2;
    perch.LEDvals=handles.LEDvals;
    perch.eatRegimeVals=handles.eatRegimeVals;
    perch.perchRegimeVals=handles.perchRegimeVals;
    perch.pelletRegimeVals=handles.pelletRegimeVals; 
    perch.pelletStopVals=handles.pelletStopVals;
    perch.changeBetweenFrames=handles.changeBetweenFrames;
    perch.pelletIsIn=isin3;
    perch.isin5=isin5;
    perch.isin4=isin4;
    perch.perc10_change=handles.perc10_change;
    endoffname=regexp(filename,'\.');
    save([filename(1:endoffname(end)-1) '_perch.mat'],'perch');
end

return

% Then look for changes in paw zone to identify potential reach
% Have user indicate start of reach, time when paw contacts pellet, and
% whether reach was succesful

% Set up handles
if addingOn==0
    handles.useAsThresh=useAsThresh;
    handles.discardFirstNFrames=discardFirstNFrames;
    handles.stepByAmount=stepByAmount;
    handles.filename=filename;
    handles.n_consec=n_consec;
    handles.isin=isin;
    handles.isin3=isin3;
    handles.isin4=isin4;
    handles.isin5=isin5;
    handles.perch_pellet_delay_ind=perch_pellet_delay_ind;
    handles.reachStarts=[];
    handles.pelletTouched=[];
    handles.pelletTime=[];
    handles.atePellet=[];
    handles.eatTime=[];
    handles.logReachN=[];
    handles.reachIsDone=false;
    handles.curr_start_done=false;
    handles.curr_pellet_done=false;
    handles.curr_eat_done=false;
    handles.allframes=allframes;
    handles.frames_before_firstReachFrame=frames_before_firstReachFrame;
    handles.frames_after_firstReachFrame=frames_after_firstReachFrame;
    handles.nFramesBetweenReaches=nFramesBetweenReaches;
    handles.videoFReader=videoFReader;
    handles.didReachForThisChunk=didReachForThisChunk;
    handles.movieChunk=movieChunk;
    handles.startsAtFrame=startsAtFrame;
    handles.framesPerChunk=framesPerChunk;
    handles.allReachesTally=1;
    handles.EOF=EOF;
    handles.startedOver=[];
    handles.sizeOfLastChunk=[];
    handles.endoffname=regexp(filename,'\.');
    handles.sizeoneback=sizeoneback;
    handles.isin2=isin2;
    handles.lookedAtFrame=[];
    handles.computerThinksNoReach=0;
    handles.summedIntensity=[];
else
    handles.EOF=EOF;
    handles.perch_pellet_delay_ind=perch_pellet_delay_ind;
    handles.framesPerChunk=framesPerChunk;
    handles.startsAtFrame=startsAtFrame;
    handles.movieChunk=movieChunk;
    handles.allReachesTally=previous_savehandles.allReachesTally;
    handles.didReachForThisChunk=didReachForThisChunk;
    handles.reachIsDone=false;
    handles.curr_start_done=false;
    handles.curr_pellet_done=false;
    handles.curr_eat_done=false;
    handles.allframes=allframes;
    handles.frames_before_firstReachFrame=frames_before_firstReachFrame;
    handles.frames_after_firstReachFrame=frames_after_firstReachFrame;
    handles.nFramesBetweenReaches=nFramesBetweenReaches;
    handles.videoFReader=videoFReader;
end

% Find reaches in current movie chunk, then move to next movie chunk, etc.
disp('Find the frame associated with each of the following events for this reach and press matching button while movie is stopped at that frame.'); 
[reachingStretch,handles.summedIntensity]=findCurrentReaches(allframes,useAsThresh,n_consec,isin,isin3,isin4,perch_pellet_delay_ind,handles.perc10_change,handles);
% if isempty(reachingStretch)
%     % No reaches found for this movie chunk, get next movie chunk
%     containsReach=0;
%     while containsReach==0
%         [handles,containsReach]=findMovieChunkWithReach(handles);
%     end
%     allframes=handles.allframes;
%     reachingStretch=handles.reachingStretch;
% end

% Display current reach
if isempty(reachingStretch)
    startInd=1;
    endInd=size(allframes,3);
    fig=implay(allframes(:,:,startInd:endInd),fps_noreach); % Play movie more quickly if reach is probably not present
    handles.addIn=0;
    handles.computerThinksNoReach=1;
    fig.Parent.Position=[100 100 800 800];
    lastFrameDisplayed=startsAtFrame(end-1)+endInd-1;
    firstFrameDisplayed=startsAtFrame(end-1)+startInd-1;
else
    if reachingStretch(1)-frames_before_firstReachFrame<1
        startInd=1;
    else
        startInd=reachingStretch(1)-frames_before_firstReachFrame;
    end
    if reachingStretch(1)+frames_after_firstReachFrame>size(allframes,3)
        endInd=size(allframes,3);
    else
        endInd=reachingStretch(1)+frames_after_firstReachFrame;
    end
%     fig=implay(allframes(:,:,startInd:endInd),fps_reach); % Play movie slowly if reach may be present
    % Play from beginning so user sees all frames
    startInd=1;
    fig=implay(allframes(:,:,startInd:endInd),fps_reach); % Play movie slowly if reach may be present
    handles.addIn=0;
    handles.computerThinksNoReach=0;
    fig.Parent.Position=[100 100 800 800];
    lastFrameDisplayed=startsAtFrame(end-1)+endInd-1;
    firstFrameDisplayed=startsAtFrame(end-1)+startInd-1;
end
handles.lookedAtFrame=[handles.lookedAtFrame zeros(1,size(allframes,3))];
handles.lookedAtFrame(firstFrameDisplayed:lastFrameDisplayed)=1;

handles.fig=fig;
handles.reachingStretch=reachingStretch;
handles.lastFrameDisplayed=lastFrameDisplayed;
handles.firstFrameDisplayed=firstFrameDisplayed;
handles.reach=createReach(handles.allReachesTally);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setup_reach_coding wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function curr=copyAllFields(curr,previous)

f=fieldnames(previous);
for i=1:length(f)
    curr.(f{i})=previous.(f{i});
end


function finishFunction(handles)

if ~isfield(handles,'useAsThresh')
%     delete(hObject);
    return
end
 
% Choose what to save 
savehandles.discardFirstNFrames=handles.discardFirstNFrames;
savehandles.useAsThresh=handles.useAsThresh;
savehandles.stepByAmount=handles.stepByAmount;
savehandles.filename=handles.filename;
savehandles.n_consec=handles.n_consec;
savehandles.perch_pellet_delay_ind=handles.perch_pellet_delay_ind;
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
savehandles.isin3=handles.isin3;
savehandles.isin4=handles.isin4;
savehandles.isin5=handles.isin5;
savehandles.LEDvals=handles.LEDvals;
savehandles.changeBetweenFrames=handles.changeBetweenFrames;
savehandles.eatRegimeVals=handles.eatRegimeVals;
savehandles.perchRegimeVals=handles.perchRegimeVals;
savehandles.pelletRegimeVals=handles.pelletRegimeVals;
savehandles.pelletStopVals=handles.pelletStopVals;
savehandles.pelletMissing=handles.pelletMissing;
savehandles.pawStartsOnWheel=handles.pawStartsOnWheel;
savehandles.lookedAtFrame=handles.lookedAtFrame;
savehandles.perc10_change=handles.perc10_change;
savehandles.logReachN=handles.logReachN;
savehandles.allframes=handles.allframes;
savehandles.EOF=handles.EOF;
savehandles.endoffname=handles.endoffname;
savehandles.computerThinksNoReach=handles.computerThinksNoReach;
savehandles.summedIntensity=handles.summedIntensity;


if ~isfield(handles,'endoffname')
    handles.endoffname=[];
    return
end
    
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
% chunks, if so, end
if ~isempty(EOF)
    if EOF==true
%         finishFunction(handles);
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
if EOF==true
    finishFunction(handles);
end
        
% Check whether we've already looked for reaches in this movie chunk
noReachesYet=movieChunk(~ismember(movieChunk,didReachForThisChunk));
if isempty(noReachesYet)
    % Finished
    finishFunction(handles);
end

% Read a movie segment
n=framesPerChunk; % How many frames to read now
handles.oneback=allframes(:,:,end-sizeoneback+1:end);
currentSegment=[1 n];
% tic
for j=1:n
    [frame,~,~,EOF]=step(videoFReader);
%     disp(toc);
    if EOF==true
        n=j-1;
        allframes=allframes(:,:,j-1);
        sizeOfLastChunk=j-1;
        break
    end
    allframes(:,:,j)=frame;
end
if EOF==true
    finishFunction(handles);
end

% handles.oneback=allframes(:,:,end-sizeoneback+1:end);
% Get LED zone intensity over all frames
temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
summedIntensityLED=sum(temp(isin2,:),1);
handles.LEDvals=[handles.LEDvals summedIntensityLED];

tempie=sum(temp(handles.isin4,:),1);
handles.eatRegimeVals=[handles.eatRegimeVals tempie];
tempie=sum(temp(handles.isin,:),1);
handles.perchRegimeVals=[handles.perchRegimeVals tempie];
tempie=sum(temp(handles.isin3,:),1);
handles.pelletRegimeVals=[handles.pelletRegimeVals tempie];
tempie=sum(temp(handles.isin5,:),1);
handles.pelletStopVals=[handles.pelletStopVals tempie];

% Get change between frames
changeBetweenFrames=nanmean(nanmean(diff(allframes,1,3),1),2);
changeBetweenFrames=[reshape(changeBetweenFrames,1,size(changeBetweenFrames,3)) 0];
if isempty(changeBetweenFrames)
    finishFunction(handles);
end
handles.changeBetweenFrames=[handles.changeBetweenFrames changeBetweenFrames];

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
% save([handles.filename_foroutput num2str(startsAtFrame(end-1)) '.mat'],'allframes');

% Update handles
handles.videoFReader=videoFReader;
handles.allframes=allframes;
handles.startsAtFrame=startsAtFrame;
handles.movieChunk=movieChunk;
handles.EOF=EOF;
handles.startedOver=startedOver;
handles.sizeOfLastChunk=sizeOfLastChunk;

function [handles,containsReach,summedIntensity]=findMovieChunkWithReach(handles)

didReachForThisChunk=handles.didReachForThisChunk;
movieChunk=handles.movieChunk;

% Save that reaches have been found for this movie chunk
didReachForThisChunk=[didReachForThisChunk movieChunk(end)];

% Read next movie segment
handles=updateMovie(handles);

% Get new values from updated handles
allframes=handles.allframes;
videoFReader=handles.videoFReader;
% startsAtFrame=handles.startsAtFrame;
movieChunk=handles.movieChunk;

% Find new candidate reach frames
[reachingStretch,summedIntensity]=findCurrentReaches(allframes,handles.useAsThresh,handles.n_consec,handles.isin,handles.isin3,handles.isin4,handles.perch_pellet_delay_ind,handles.perc10_change,handles);

% Check if there is any candidate reach in this movie chunk
if isempty(reachingStretch)
    containsReach=false;
    disp('Movie chunk may lack reach');
else
    containsReach=true;
end

% Update handles
handles.allframes=allframes;
handles.videoFReader=videoFReader;
% handles.startsAtFrame=startsAtFrame;
handles.movieChunk=movieChunk;
handles.reachingStretch=reachingStretch;

function handles=logReach(handles)

reach=handles.reach;
handles.atePellet=[handles.atePellet reach.atePellet];
handles.eatTime=[handles.eatTime reach.eatTime];
handles.pelletTouched=[handles.pelletTouched reach.pelletTouched];
handles.pelletTime=[handles.pelletTime reach.pelletTime];
handles.reachStarts=[handles.reachStarts reach.reachStarts];
handles.pawStartsOnWheel=[handles.pawStartsOnWheel reach.pawStartsOnWheel];
handles.logReachN=[handles.logReachN reach.reachN];
handles.pelletMissing=[handles.pelletMissing reach.pelletIsMissing];


function handles=updateReach(handles)

if handles.addIn==0
%     disp('Done');

    % Increment total reaches
    handles.allReachesTally=handles.allReachesTally+1;
    % Increment reach detected count
    set(handles.reachTallyBox,'String',['Reach ' num2str(handles.allReachesTally)]);
    
    % Log reach
    handles=logReach(handles);
    
    % Reset reach
    handles.reach=createReach(handles.allReachesTally);
end

% Display next reach movie

% Get variables
reachingStretch=handles.reachingStretch;
allframes=handles.allframes;
frames_before_firstReachFrame=handles.frames_before_firstReachFrame;
frames_after_firstReachFrame=handles.frames_after_firstReachFrame;
didReachForThisChunk=handles.didReachForThisChunk;
movieChunk=handles.movieChunk;
startsAtFrame=handles.startsAtFrame;
lastFrameDisplayed=handles.lastFrameDisplayed;
firstFrameDisplayed=handles.firstFrameDisplayed;

if ((~isnan(handles.atePellet(end)) && isempty(reachingStretch)) || (handles.computerThinksNoReach==1 && ~isnan(handles.atePellet(end)))) && (handles.addIn==0)
    % Last movie frame contained a reach, according to user
    % and computer failed to detect this reach
    handles.useAsThresh=handles.useAsThresh+handles.stepByAmount;
    disp('Increasing reach detection threshold');
    
    if ~isempty(handles.summedIntensity)
%         figure();
%         plot(handles.summedIntensity);
%         hold on;
%         line([1 length(handles.summedIntensity)],[handles.useAsThresh handles.useAsThresh],'Color','r');
    end
elseif (isnan(handles.atePellet(end)) && handles.computerThinksNoReach==0) && (handles.addIn==0)
    % Last movie did not contain a reach, but 
    % computer thought this was a reach
    handles.useAsThresh=handles.useAsThresh-handles.stepByAmount;
    disp('Decreasing reach detection threshold');
    
    if ~isempty(handles.summedIntensity)
%         figure();
%         plot(handles.summedIntensity);
%         hold on;
%         line([1 length(handles.summedIntensity)],[handles.useAsThresh handles.useAsThresh],'Color','r');
    end
end

% Check whether next detected reach frames are within nFramesBetweenReaches
% of current reach frame or within scope of just detected reach
nFramesBetweenReaches=handles.nFramesBetweenReaches;
timeOfLastEat=handles.eatTime(end);
timeOfLastPellet=handles.pelletTime(end);
% loseAllReachesBefore=max([timeOfLastEat-startsAtFrame(end-1)+1 timeOfLastPellet-startsAtFrame(end-1)+1]);
loseAllReachesBefore=lastFrameDisplayed-startsAtFrame(end-1)+2;
if isempty(reachingStretch)
    loseAllReachesBefore=lastFrameDisplayed-startsAtFrame(end-1)+2;
%     loseAllReachesBefore=max([timeOfLastEat-startsAtFrame(end-1)+1 timeOfLastPellet-startsAtFrame(end-1)+1]);
elseif handles.addIn==0
    % Note that reachingStretch is an index into allframes
    % first index of allframes is startsAtFrame(end-1) wrt whole movie
    % and firstFrameDisplayed=startsAtFrame(end-1)+startInd-1
    if isnan(handles.atePellet(end)) % Last movie frame was a "no reach"
        % so skip all the way to end of this movie frame
        loseAllReachesBefore=lastFrameDisplayed-startsAtFrame(end-1)+2;
    elseif ~isnan(timeOfLastEat) || ~isnan(timeOfLastPellet)
        loseAllReachesBefore=max([timeOfLastEat-startsAtFrame(end-1)+1 timeOfLastPellet-startsAtFrame(end-1)+1 reachingStretch(1)+nFramesBetweenReaches]);
    else
        loseAllReachesBefore=reachingStretch(1)+nFramesBetweenReaches;
    end
end
if isnan(handles.atePellet(end)) % Last movie frame was a "no reach"
    loseAllReachesBefore=lastFrameDisplayed-startsAtFrame(end-1)+2;
end
reachingStretch=reachingStretch(reachingStretch>loseAllReachesBefore);
handles.reachingStretch=reachingStretch;

% If have reached end of this movie chunk, read next movie segment
getMoreMovie=0;
if handles.addIn==1
    getMoreMovie=1;
elseif loseAllReachesBefore>size(allframes,3)-5 
    getMoreMovie=1;
end
if getMoreMovie==1
    containsReach=0;
%     while containsReach==0
        [handles,containsReach,handles.summedIntensity]=findMovieChunkWithReach(handles);
        if handles.addIn==1
            containsReach=1; % this chunk contains end of reach from previous movie chunk
        end
%     end
    loseAllReachesBefore=0;
    if containsReach==0
        reachingStretch=[];
    end
end

allframes=handles.allframes;
reachingStretch=handles.reachingStretch;
startsAtFrame=handles.startsAtFrame;

close(handles.fig);

% Update implay
playAtFastSpeed=0;
if handles.addIn==0
    startInd=loseAllReachesBefore+1;
    if isempty(reachingStretch)
        startInd=loseAllReachesBefore+1;
        handles.computerThinksNoReach=1;
    elseif reachingStretch(1)-frames_before_firstReachFrame<1
        startInd=1;
        handles.computerThinksNoReach=0;
    else
        startInd=reachingStretch(1)-frames_before_firstReachFrame;
        handles.computerThinksNoReach=0;
    end
    
    endInd=size(allframes,3);
    if isempty(reachingStretch)
        endInd=size(allframes,3);
    elseif reachingStretch(1)+frames_after_firstReachFrame>size(allframes,3)
        endInd=size(allframes,3);
    else
        endInd=reachingStretch(1)+frames_after_firstReachFrame;
    end
    
    % Be sure that user sees all frames
    if ~isempty(reachingStretch)
        if startInd-loseAllReachesBefore>40
            % First play a "no reach" movie for time until this first reach
            handles.computerThinksNoReach=1;
            endInd=startInd;
            startInd=loseAllReachesBefore+1;
            playAtFastSpeed=1;
        else
            startInd=loseAllReachesBefore+1;
        end
    end
    
    if isempty(reachingStretch)
        disp('Computer sees no reach');
        fig=implay(allframes(:,:,startInd:endInd),handles.fps_noreach);
        handles.addIn=0;
    else
        disp('reachingStretch');
        disp(reachingStretch);
        disp('showing');
        disp(startInd);
        disp(endInd);
        if playAtFastSpeed==1
            fig=implay(allframes(:,:,startInd:endInd),handles.fps_noreach);
            handles.addIn=0;
        else
            fig=implay(allframes(:,:,startInd:endInd),handles.fps_reach);
            handles.addIn=0;
        end
    end
    lastFrameDisplayed=startsAtFrame(end-1)+endInd-1;
    firstFrameDisplayed=startsAtFrame(end-1)+startInd-1;
else
    % add in reach from former movie chunk
    more_framesAfterReach=50;
    fig=implay(cat(3,handles.whatToAddIn,allframes(:,:,1:more_framesAfterReach)),handles.fps_reach);
    firstFrameDisplayed=(startsAtFrame(end-1)+1-1)-size(handles.whatToAddIn,3)+1;
    lastFrameDisplayed=startsAtFrame(end-1)+more_framesAfterReach;
    handles.addIn=0;
end
fig.Parent.Position=[100 100 800 800];
handles.fig=fig;
handles.lastFrameDisplayed=lastFrameDisplayed;
handles.firstFrameDisplayed=firstFrameDisplayed;
if firstFrameDisplayed<1
    firstFrameDisplayed=1;
end
handles.lookedAtFrame(firstFrameDisplayed:lastFrameDisplayed)=1;
    
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

% Reset reach progress variables
% reset to beginning of coding this reach
handles.reach=resetReachState(handles.reach);
handles.reach=resetReachProgress(handles.reach);

function [reachingStretch,summedIntensity]=findCurrentReaches(allframes,useAsThresh,n_consec,isin,isin3,isin4,perch_pellet_delay_ind,perc10_change,handles)

% summedIntensity=nan(1,n);
temp=reshape(allframes,size(allframes,1)*size(allframes,2),size(allframes,3));
pelletIntensity=sum(temp(isin3,:),1);
summedIntensity_perch=sum(temp(isin,:),1);
eatIntensity=sum(temp(isin4,:),1);

changeBetweenFrames=nanmean(nanmean(diff(allframes,1,3),1),2);
changeBetweenFrames=[reshape(changeBetweenFrames,1,size(changeBetweenFrames,3)) 0];
    
all_summedIntensity=zeros(length(perch_pellet_delay_ind),length(pelletIntensity));
if size(allframes,3)<handles.framesPerChunk
    disp('Looks like movie is done. Close all figures to end.');
    pause;
else
    for j=1:length(perch_pellet_delay_ind)
        tempie2=[nanmean(eatIntensity)*ones(1,perch_pellet_delay_ind(j)+4) eatIntensity(1:end-(perch_pellet_delay_ind(j)+4))];
        tempie=[nanmean(summedIntensity_perch)*ones(1,perch_pellet_delay_ind(j)) summedIntensity_perch(1:end-perch_pellet_delay_ind(j))];
        %     summedIntensity=pelletIntensity./tempie;
        summedIntensity=10*pelletIntensity-tempie+(0.3*tempie2);
        summedIntensity=-summedIntensity;
        all_summedIntensity(j,:)=summedIntensity;
    end
    % summedIntensity=nanmean(all_summedIntensity,1);
    summedIntensity=(nanmean(all_summedIntensity,1)-nanmean(nanmean(all_summedIntensity,1),2))+(100000*changeBetweenFrames);
    
    % for i=1:n
    %     temp=intensityFromRGB(allframes(:,:,i));
    %     summedIntensity(i)=sum(temp(isin));
    % end
    
    
    % reachFrames=summedIntensity<useAsThresh;
    
    % Get peaks only
    [~,locs]=findpeaks(-summedIntensity);
    locs=locs(summedIntensity(locs)<useAsThresh);
    isReaching=zeros(size(summedIntensity));
    isReaching(locs)=1;
    reachFrames=isReaching;
    
    % Real reach should be at least n_consec consecutive reach frames
    runningSum=zeros(size(reachFrames));
    for i=1:n_consec
        runningSum(1:end-(i-1))=runningSum(1:end-(i-1))+reachFrames(i:end);
    end
    reachingStretch=find(runningSum>=n_consec);
end

function [useAsThresh,works,isUserApprovedReach,stepByAmount]=calibrateReachDetection(summedIntensity,allframes,useAsThresh,counter,stepByAmount)

if isempty(stepByAmount)
    stepByAmount=0.25*std(summedIntensity);
end

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
function varargout = setup_reach_coding_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if ~isfield(handles,'output')
    handles.output=[];
end
varargout{1} = handles.output;


% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If already hit this button, ignore second press
if handles.reach.curr_start_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.reach=putFrameNumber(handles.reach,firstFrameDisplayed+currFrame-1,hObject.Tag);

% Set start button to done
set(handles.text3,'String','Done');
set(handles.text3,'ForegroundColor','g');
handles.reach=updateReachProgress(handles.reach,hObject.Tag);

% Check whether this reach is done
if reachIsDone(handles)==true
    handles=updateReach(handles);
end

guidata(hObject, handles);

function out=reachIsDone(handles)

if handles.reach.curr_start_done==true && handles.reach.curr_pellet_done==true && handles.reach.curr_eat_done==true
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
if handles.reach.curr_pellet_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.reach=putFrameNumber(handles.reach,firstFrameDisplayed+currFrame-1,hObject.Tag);

% Set pellet button to done
set(handles.text4,'String','Done');
set(handles.text4,'ForegroundColor','g');
handles.reach=updateReachProgress(handles.reach,hObject.Tag);

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
if handles.reach.curr_pellet_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.reach=putFrameNumber(handles.reach,firstFrameDisplayed+currFrame-1,hObject.Tag);

% Set pellet button to done
set(handles.text4,'String','Done');
set(handles.text4,'ForegroundColor','g');
handles.reach=updateReachProgress(handles.reach,hObject.Tag);

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
if handles.reach.curr_eat_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.reach=putFrameNumber(handles.reach,firstFrameDisplayed+currFrame-1,hObject.Tag);

% Set eat button to done
set(handles.text5,'String','Done');
set(handles.text5,'ForegroundColor','g');
handles.reach=updateReachProgress(handles.reach,hObject.Tag);

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
if handles.reach.curr_eat_done==true
    return
end

% Get current frame number in movie player
firstFrameDisplayed=handles.firstFrameDisplayed;
currFrame=handles.fig.data.Controls.CurrentFrame;
handles.reach=putFrameNumber(handles.reach,firstFrameDisplayed+currFrame-1,hObject.Tag);

% Set eat button to done
set(handles.text5,'String','Done');
set(handles.text5,'ForegroundColor','g');
handles.reach=updateReachProgress(handles.reach,hObject.Tag);

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

if currFrame==(handles.lastFrameDisplayed-handles.firstFrameDisplayed+1)
    handles.reach=resetReachState(handles.reach);
    handles.reach=resetReachProgress(handles.reach);
    handles=updateReach(handles);
    guidata(hObject, handles);
else
    disp('Will only accept No Reach classification if movie is stopped at last frame');
end


function reach=resetReachProgress(reach)

reach.curr_eat_done=false;
reach.curr_pellet_done=false;
reach.curr_start_done=false;


function reach=updateReachProgress(reach,tag)

switch tag
    case 'startbutton' % reach is starting
        reach.curr_start_done=true;
    case 'pelletbutton' % mouse touches pellet
        reach.curr_pellet_done=true;
    case 'missbutton' % reach does not touch pellet
        reach.curr_pellet_done=true;
    case 'eatbutton' % mouse eats pellet
        reach.curr_eat_done=true;
    case 'dropbutton' % mouse drops pellet
        reach.curr_eat_done=true;
    otherwise
        error('Do not recognize tag passed to updateReachProgress');
end 



function reach=putFrameNumber(reach,frameN,tag)

switch tag
    case 'startbutton' % reach is starting
        reach.reachStarts=frameN;
    case 'pelletbutton' % mouse touches pellet
        reach.pelletTime=frameN;
        reach.pelletTouched=1;
    case 'missbutton' % reach does not touch pellet
        reach.pelletTime=frameN;
        reach.pelletTouched=0;
    case 'eatbutton' % mouse eats pellet
        reach.eatTime=frameN;
        reach.atePellet=1;
    case 'dropbutton' % mouse drops pellet
        reach.eatTime=frameN;
        reach.atePellet=0;
    otherwise
        error('Do not recognize tag passed to putFrameNumber');
end


function reach=updateReachState(reach,field_name,val)
    
reach.(field_name)=val;
    

function reach=resetReachState(reach)

reach.atePellet=nan;
reach.eatTime=nan;
reach.pelletTouched=nan;
reach.pelletTime=nan;
reach.reachStarts=nan;
reach.pelletIsMissing=0;
reach.pawStartsOnWheel=0;


function reach=createReach(reachN)

% set fields to defaults
reach.atePellet=nan;
reach.eatTime=nan;
reach.pelletTouched=nan;
reach.pelletTime=nan;
reach.reachStarts=nan;
reach.pelletIsMissing=0;
reach.reachN=reachN;
reach.pawStartsOnWheel=0;
reach.curr_eat_done=false;
reach.curr_pellet_done=false;
reach.curr_start_done=false;


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

% reset to beginning of coding this reach
handles.reach=resetReachState(handles.reach);
handles.reach=resetReachProgress(handles.reach);

more_framesBeforeReach=50;
more_framesAfterReach=50;

allframes=handles.allframes;
reachingStretch=handles.reachingStretch;
sizeoneback=handles.sizeoneback;
if ~isfield(handles,'oneback')
    handles.oneback=[];
end
oneback=handles.oneback;
startsAtFrame=handles.startsAtFrame;

handles.addIn=0;

% Update implay
startInd=handles.firstFrameDisplayed+1-startsAtFrame(end-1);
endInd=handles.lastFrameDisplayed+1-startsAtFrame(end-1);
startInd_forMovie=startInd;
endInd_forMovie=endInd;
if startInd-more_framesBeforeReach<1
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
            startInd=startInd-sizeoneback;
            startInd_forMovie=startInd+sizeoneback;
            endInd_forMovie=endInd+sizeoneback;
            if ~isempty(reachingStretch)
                reachingStretch=reachingStretch+sizeoneback;
            end
            if more_framesBeforeReach>sizeoneback
                error('more_framesBeforeReach should be less than sizeoneback');
            end
        end
    end
else
    if isempty(oneback)
    else
        startInd_forMovie=startInd_forMovie-more_framesBeforeReach;
        startInd=startInd-more_framesBeforeReach;
    end
end

if endInd_forMovie+more_framesAfterReach>size(allframes,3)
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
        handles.whatToAddIn=allframes(:,:,startInd_forMovie:endInd_forMovie);
    end
else
    endInd_forMovie=endInd_forMovie+more_framesAfterReach;
    endInd=endInd+more_framesAfterReach;
end

if handles.addIn==0
    close(handles.fig);
    if ~isempty(reachingStretch)
        disp(reachingStretch(1));
    end
    fig=implay(allframes(:,:,startInd_forMovie:endInd_forMovie),50);
    handles.addIn=0;
    fig.Parent.Position=[100 100 800 800];
    handles.fig=fig;
    firstFrameDisplayed=startsAtFrame(end-1)+startInd-1;
    lastFrameDisplayed=startsAtFrame(end-1)+endInd-1;
    handles.lastFrameDisplayed=lastFrameDisplayed;
    handles.firstFrameDisplayed=firstFrameDisplayed;
    
    % Reset GUI
    handles=resetGUI(handles);
else
    firstFrameDisplayed=startsAtFrame(end-1)+startInd-1;
    lastFrameDisplayed=startsAtFrame(end-1)+endInd-1;
    handles.lastFrameDisplayed=lastFrameDisplayed;
    handles.firstFrameDisplayed=firstFrameDisplayed;
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

handles.reach=resetReachState(handles.reach);
handles.reach=resetReachProgress(handles.reach);

% Reset GUI 
handles=resetGUI(handles);

guidata(hObject, handles);


% --- Executes on button press in pelletmissingbutton.
function pelletmissingbutton_Callback(hObject, eventdata, handles)
% hObject    handle to pelletmissingbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.reach=updateReachState(handles.reach,'pelletIsMissing',1);

guidata(hObject, handles);


% --- Executes on button press in pawonwheel.
function pawonwheel_Callback(hObject, eventdata, handles)
% hObject    handle to pawonwheel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.reach=updateReachState(handles.reach,'pawStartsOnWheel',1);

guidata(hObject, handles);
