function varargout = alignmentGUI(varargin)
% ALIGNMENTGUI MATLAB code for alignmentGUI.fig
%      ALIGNMENTGUI, by itself, creates a new ALIGNMENTGUI or raises the existing
%      singleton*.
%
%      H = ALIGNMENTGUI returns the handle to a new ALIGNMENTGUI or the handle to
%      the existing singleton*.
%
%      ALIGNMENTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALIGNMENTGUI.M with the given input arguments.
%
%      ALIGNMENTGUI('Property','Value',...) creates a new ALIGNMENTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before alignmentGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to alignmentGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help alignmentGUI

% Last Modified by GUIDE v2.5 18-May-2017 14:56:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @alignmentGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @alignmentGUI_OutputFcn, ...
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


% --- Executes just before alignmentGUI is made visible.
function alignmentGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to alignmentGUI (see VARARGIN)

% Set up variables
framesPerChunk=3000;

% Choose default command line output for findReaches
handles.output = hObject;

% Close all open figures except GUI
set(hObject, 'HandleVisibility', 'off');
close all;
set(hObject, 'HandleVisibility', 'on');

% Get file name of video with reaches
filename=varargin{1};

% Instructions to user
continuebutton=questdlg('Click On when distractor LED turns on. Click Off when it turns off. Understood?','Instructions 1','Yes','Cancel','Cancel');
switch continuebutton
    case 'Yes'
    case 'Cancel'
        return
end

% Set up approach for indexing movie chunks into whole movie
movieChunk=[];
startsAtFrame=[];

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

% Play movie
fig=implay(allframes);
fig.Parent.Position=[100 100 800 800];
pause;

% Set up handles
handles.filename=filename;
handles.allframes=allframes;
handles.videoFReader=videoFReader;
handles.movieChunk=movieChunk;
handles.startsAtFrame=startsAtFrame;
handles.framesPerChunk=framesPerChunk;
handles.EOF=[];
handles.startedOver=[];
handles.sizeOfLastChunk=[];
handles.endoffname=regexp(filename,'\.');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes alignmentGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = alignmentGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in onbutton.
function onbutton_Callback(hObject, eventdata, handles)
% hObject    handle to onbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get current frame number in movie player
currFrame=handles.fig.data.Controls.CurrentFrame;

handles.on=[handles.on currFrame];

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in offbutton.
function offbutton_Callback(hObject, eventdata, handles)
% hObject    handle to offbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get current frame number in movie player
currFrame=handles.fig.data.Controls.CurrentFrame;

handles.off=[handles.off currFrame];

% Update handles structure
guidata(hObject, handles);

function finishFunction(handles)

endoffname=handles.endoffname;
filename=handles.filename;

LEDsavehandles.on=handles.on;
LEDsavehandles.off=handles.off;

% To execute once have found reaches in all of movie
save([filename(1:endoffname(end)-1) '_distractorLED.mat'],'LEDsavehandles');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Saves data before closing figure
finishFunction(handles);

delete(hObject);
