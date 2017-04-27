function varargout = expressionCoverageGUI(varargin)
% EXPRESSIONCOVERAGEGUI MATLAB code for expressionCoverageGUI.fig
%      EXPRESSIONCOVERAGEGUI, by itself, creates a new EXPRESSIONCOVERAGEGUI or raises the existing
%      singleton*.
%
%      H = EXPRESSIONCOVERAGEGUI returns the handle to a new EXPRESSIONCOVERAGEGUI or the handle to
%      the existing singleton*.
%
%      EXPRESSIONCOVERAGEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPRESSIONCOVERAGEGUI.M with the given input arguments.
%
%      EXPRESSIONCOVERAGEGUI('Property','Value',...) creates a new EXPRESSIONCOVERAGEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before expressionCoverageGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to expressionCoverageGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help expressionCoverageGUI

% Last Modified by GUIDE v2.5 03-Jan-2014 18:42:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @expressionCoverageGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @expressionCoverageGUI_OutputFcn, ...
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


% --- Executes just before expressionCoverageGUI is made visible.
function expressionCoverageGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to expressionCoverageGUI (see VARARGIN)

% Choose default command line output for expressionCoverageGUI
handles.output = hObject;

slice=varargin{1};
h=imagesc(slice);
handles.h=h;
handles.slice=slice;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes expressionCoverageGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = expressionCoverageGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
threshMin=get(hObject,'Min'); % 0
threshMax=get(hObject,'Max'); % 1
currThresh=get(hObject,'Value');
colorThresh=255*(1-currThresh);
slice=handles.slice;
h=handles.h;
greenPix=slice(:,:,2);
redPix=slice(:,:,1);
updateSlice=slice;
redPix(greenPix(1:end)>colorThresh)=255;
updateSlice(:,:,1)=redPix;
handles.updateSlice=updateSlice;
imagesc(updateSlice);

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'isDrawing')
    handles.isDrawing=0;
    isDrawing=0;
    handles.vertices=[];
    vertices=[];
    handles.whichline=[];
    whichline=[];
else
    isDrawing=handles.isDrawing;
    vertices=handles.vertices;
    whichline=handles.whichline;
end
if isDrawing==0
    % Start new line
    if isempty(whichline)
        lastLine=0;
    else
        lastLine=max(whichline);
    end
    currLine=lastLine+1;
else
    currLine=max(whichline);
end
% currVertex=get(hObject,'CurrentPoint');
[currVertex_x,currVertex_y]=ginput(1);
currVertex=[currVertex_x currVertex_y];
vertices=[vertices; currVertex];
whichline=[whichline; currLine];
if isDrawing==1
    prevVertex=vertices(size(vertices,1)-1,:);
    line([prevVertex(1) currVertex(1)],[prevVertex(2) currVertex(2)]);
end

% Update handles structure
isDrawing=1;
handles.isDrawing=isDrawing;
handles.vertices=vertices;
handles.whichline=whichline;
guidata(hObject, handles);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'updateSlice')
    vertices=handles.vertices;
    patchHand=patch(vertices(:,1),vertices(:,2),'c');
    set(patchHand,'FaceAlpha',0.2);
    updateSlice=handles.updateSlice;
    [cols,rows]=find(updateSlice(:,:,1)>254);
    isin=inpolygon(rows,cols,vertices(:,1),vertices(:,2));
    [k,v]=convhull(vertices(:,1),vertices(:,2));
    disp(sum(isin));
    disp(v);
    disp(sum(isin)/v);
end

